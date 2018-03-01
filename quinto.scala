import org.apache.spark.sql.functions.udf
import org.apache.spark.sql.functions.col
import org.apache.spark.sql.{SparkSession, SQLContext}
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.ml.feature.HashingTF
import org.apache.spark.ml.feature.RegexTokenizer
import org.apache.spark.ml.classification.MultilayerPerceptronClassifier
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator
import org.apache.spark.mllib.evaluation.MulticlassMetrics
import org.apache.spark.mllib.classification.{SVMModel, SVMWithSGD}
import org.apache.spark.mllib.evaluation.BinaryClassificationMetrics
import org.apache.spark.mllib.util.MLUtils



  val sqlContext = new org.apache.spark.sql.SQLContext(sc)
  import spark.implicits._
  val filename = "maltempo"
  val sparkSession = SparkSession.builder().master("local").appName("test").config("spark.some.config.option", "some-value").getOrCreate()

  val dataset = sparkSession.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/home/dimartino/Documenti/mario/codice/tesienea/submit/maltempo.csv")

  val splits = data.randomSplit(Array(0.8, 0.2), seed = 1234L)
  val training = splits(0)
  val test = splits(1)
  
val numIterations = 100
val model = SVMWithSGD.train(training, numIterations)

// Clear the default threshold.
model.clearThreshold()

// Compute raw scores on the test set.
val scoreAndLabels = test.map { point =>
  val score = model.predict(point.features)
  (score, point.label)
}

// Get evaluation metrics.
val metrics = new BinaryClassificationMetrics(scoreAndLabels)
val auROC = metrics.areaUnderROC()

println("Area under ROC = " + auROC)



