import org.apache.spark.sql.functions.udf
import org.apache.spark.sql.functions.col
import org.apache.spark.sql.{SparkSession, SQLContext}
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.ml.feature.RegexTokenizer
import org.apache.spark.ml.classification.LogisticRegression 
import org.apache.spark.ml.feature.HashingTF 
import org.apache.spark.ml.Pipeline 
import org.apache.spark.ml.evaluation.BinaryClassificationEvaluator 
import org.apache.spark.ml.param.ParamMap
import org.apache.spark.mllib.evaluation.MulticlassMetrics

val sqlContext = new org.apache.spark.sql.SQLContext(sc)
val filename = "maltempo"
val articles = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").load("/home/dimartino/Documenti/mario/codice/tesienea/dati/stop_word+parole_frequenti+forme_flesse+maggiori_30_parole/"+filename+".csv")
val topic2Label: Boolean => Double = isSci => if (isSci) 1 else 0
val toLabel = udf(topic2Label)
val labelled = articles.withColumn("label", toLabel(col("topic").like("%true%"))).cache
val tokenizer = new RegexTokenizer().setInputCol("text").setOutputCol("words")
  
val hashingTF = new HashingTF().setInputCol(tokenizer.getOutputCol).setOutputCol("features").setNumFeatures(498)
  
val word = tokenizer.transform(labelled)   
val featurized = hashingTF.transform(word)

val lr = new LogisticRegression().setMaxIter(10000).setRegParam(0.0028).setThreshold(0.5).setTol(1.0E-3)  
val pipeline = new Pipeline().setStages(Array(tokenizer, hashingTF, lr))
val model = pipeline.fit(trainDF)
val testPredictions = model.transform(testDF)
    
val evaluatorParams = ParamMap(evaluator.metricName -> "areaUnderROC")
val areaTest = evaluator.evaluate(testPredictions, evaluatorParams)

