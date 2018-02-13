import spark.implicits._
import org.apache.spark.ml.feature.RegexTokenizer
import org.apache.spark.ml.classification.LogisticRegression
import org.apache.spark.ml.feature.HashingTF
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.evaluation.BinaryClassificationEvaluator
import org.apache.spark.ml.param.ParamMap

sealed trait Category
case object Meteo extends Category
case object NonMeteo extends Category
case class LabeledText(id: Long,text: String,category: Category)
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

case class Article(id: Long,text: String,category: Category)
val articles = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").load("./guasto.csv")
val topic2Label: Boolean => Double = isSci => if (isSci) 1 else 0
val toLabel = udf(topic2Label)
val labelled = articles.withColumn("label", toLabel($"topic".like("%true%"))).cache
val Array(trainDF, testDF) = labelled.randomSplit(Array(0.75, 0.25))

val tokenizer = new RegexTokenizer().setInputCol("text").setOutputCol("words")

val evaluator = new BinaryClassificationEvaluator().setMetricName("areaUnderROC")

//model.clear(_)
val hashingTF = new HashingTF().setInputCol(tokenizer.getOutputCol).setOutputCol("features").setNumFeatures(600)
val lr = new LogisticRegression().setMaxIter(10000).setRegParam(0.0028).setThreshold(0.5).setTol(1.0E-3)  
val pipeline = new Pipeline().setStages(Array(tokenizer, hashingTF, lr))
val model = pipeline.fit(trainDF)
val testPredictions = model.transform(testDF)
val areaTest = evaluator.evaluate(testPredictions, evaluatorParams)

val evaluatorParams = ParamMap(evaluator.metricName -> "areaUnderROC")
val areaTrain = evaluator.evaluate(trainPredictions, evaluatorParams)
val areaTest = evaluator.evaluate(testPredictions, evaluatorParams)


//96,48%




























