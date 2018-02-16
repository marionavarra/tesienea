import org.apache.spark.sql.functions.udf
import org.apache.spark.sql.functions.col
import org.apache.spark.sql.{SparkSession, SQLContext}
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.ml.feature.HashingTF
import org.apache.spark.ml.feature.RegexTokenizer
import org.apache.spark.ml.classification.MultilayerPerceptronClassifier
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator
import org.apache.spark.mllib.evaluation.MulticlassMetrics

object Perceptron {
def main(args: Array[String]) { 
  val sc = new SparkContext()
  val sqlContext = new org.apache.spark.sql.SQLContext(sc)
  @transient lazy val spark = SparkSession
    .builder()
    .master("spark://master:7777")
    .getOrCreate()
  import spark.implicits._
  val filename = args(0)
  val sparkSession = SparkSession.builder().master("local").appName("Kmean maltempo").config("spark.some.config.option", "some-value").getOrCreate()
  val dataset = sparkSession.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/home/dimartino/Documenti/mario/codice/tesienea/submit/"+filename+".csv")
  val topic2Label: Boolean => Int = isSci => if (isSci) 1 else 0
  val toLabel = udf(topic2Label)
  val labelled = dataset.withColumn("label", toLabel(col("topic").like("%true%"))).cache
  val tokenizer = new RegexTokenizer().setInputCol("text").setOutputCol("words")
  
  val hashingTF = new HashingTF().setInputCol(tokenizer.getOutputCol).setOutputCol("features").setNumFeatures(100)
  
  val word = tokenizer.transform(labelled)   
  val featurized = hashingTF.transform(word)
  val data = featurized.select("id", "label", "features")
  
  val splits = data.randomSplit(Array(0.8, 0.2), seed = 1234L)
  val train = splits(0)
  val test = splits(1)
  val layers = Array[Int](100, 200, 50, 10, 2)
  val trainer = new MultilayerPerceptronClassifier().setLayers(layers).setBlockSize(128).setSeed(1234L).setMaxIter(5000)
  val model = trainer.fit(train)
  val result = model.transform(test)
  val evaluator = new MulticlassClassificationEvaluator().setMetricName("accuracy")
  val predictionAndLabels = result.select("prediction", "label")
  println("Test set accuracy = " + evaluator.evaluate(predictionAndLabels))
  val predictionAndLabels2 = result.select("prediction", "label").as[(Double, Double)].rdd
  val metrics = new MulticlassMetrics(predictionAndLabels2)
  println("Confusion matrix = ")
  println(metrics.confusionMatrix)
  println("Accuracy with metrics = "+metrics.accuracy)
  
  println("Recall with metrics = "+metrics.recall(0.0))
  println("False Positive % with metrics = "+metrics.falsePositiveRate(0.0))

  result.printSchema
  val risultati = result.select("id", "prediction", "label")
  
  println("Other metrix handmade calculated")

  
  
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
  }
}
