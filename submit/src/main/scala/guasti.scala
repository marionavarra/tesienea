import org.apache.spark.sql.functions.udf
import org.apache.spark.sql.functions.col
import org.apache.spark.SparkContext
import org.apache.spark.ml.feature.RegexTokenizer
import org.apache.spark.ml.classification.LogisticRegression 
import org.apache.spark.ml.feature.HashingTF 
import org.apache.spark.ml.Pipeline 
import org.apache.spark.ml.evaluation.BinaryClassificationEvaluator 
import org.apache.spark.ml.param.ParamMap

object Guasti {
  def main(args: Array[String]) {
    val sc = new SparkContext()
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)
    val filename = args(0)
    val articles = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").load("./guasto"+filename+".csv")
    val topic2Label: Boolean => Double = isSci => if (isSci) 1 else 0
    val toLabel = udf(topic2Label)
    val labelled = articles.withColumn("label", toLabel(col("topic").like("%true%"))).cache
    val Array(trainDF, testDF) = labelled.randomSplit(Array(0.75, 0.25))
    
    val tokenizer = new RegexTokenizer().setInputCol("text").setOutputCol("words")
    
    val evaluator = new BinaryClassificationEvaluator().setMetricName("areaUnderROC")
    
    //model.clear(_)
    val hashingTF = new HashingTF().setInputCol(tokenizer.getOutputCol).setOutputCol("features").setNumFeatures(600)
    val lr = new LogisticRegression().setMaxIter(10000).setRegParam(0.0028).setThreshold(0.5).setTol(1.0E-3)  
    val pipeline = new Pipeline().setStages(Array(tokenizer, hashingTF, lr))
    val model = pipeline.fit(trainDF)
    val testPredictions = model.transform(testDF)
    
    val evaluatorParams = ParamMap(evaluator.metricName -> "areaUnderROC")
    val areaTest = evaluator.evaluate(testPredictions, evaluatorParams)
    val risultati = result.select("id", "prediction", "label")
    risultati.registerTempTable("predicted")
    val falseNeg = sqlContext.sql("SELECT COUNT(*) as c FROM predicted WHERE label = 1.0 and prediction = 0")
    val falsePos = sqlContext.sql("SELECT COUNT(*) as c FROM predicted WHERE label = 0.0 and prediction = 1")
    val trueNeg = sqlContext.sql("SELECT COUNT(*) as c FROM predicted WHERE label = 0.0 and prediction = 0")
    val truePos = sqlContext.sql("SELECT COUNT(*) as c FROM predicted WHERE label = 1.0 and prediction = 1")
    println("False Positive = " + falsePos.head.getLong(0))
    println("False Negative = " + falseNeg.head.getLong(0))
    println("True Positive = " + truePos.head.getLong(0))
    println("True Negative = " + trueNeg.head.getLong(0))
    risultati.write.mode("overwrite").format("com.databricks.spark.csv").save("./"+filename+"_result.csv")

    println("Success prediction rate: %s".format(areaTest))
    //96,48%
  }
}
