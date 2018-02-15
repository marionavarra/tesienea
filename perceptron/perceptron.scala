import org.apache.spark.sql.{SparkSession, SQLContext}
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.ml.feature.HashingTF
import org.apache.spark.ml.feature.RegexTokenizer
import org.apache.spark.ml.classification.MultilayerPerceptronClassifier
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator

object Perceptron {
def main(args: Array[String]) {                                                                                          
val sparkSession = SparkSession.builder().master("local").appName("Kmean maltempo").config("spark.some.config.option", "some-value").getOrCreate()
val dataset = sparkSession.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/home/dimartino/Documenti/mario/codice/tesienea/submit/maltempo.csv")
val topic2Label: Boolean => Int = isSci => if (isSci) 1 else 0
val toLabel = udf(topic2Label)
val labelled = dataset.withColumn("label", toLabel($"topic".like("%true%"))).cache
val tokenizer = new RegexTokenizer().setInputCol("text").setOutputCol("words")

val hashingTF = new HashingTF().setInputCol(tokenizer.getOutputCol).setOutputCol("features").setNumFeatures(20)

val word = tokenizer.transform(labelled)   
val featurized = hashingTF.transform(word)
val data = featurized.select('label, 'features)

val splits = data.randomSplit(Array(0.6, 0.4), seed = 1234L)
val train = splits(0)
val test = splits(1)
val layers = Array[Int](20, 5, 4, 2)
val trainer = new MultilayerPerceptronClassifier().setLayers(layers).setBlockSize(128).setSeed(1234L).setMaxIter(100)
val model = trainer.fit(train)
val result = model.transform(test)
val evaluator = new MulticlassClassificationEvaluator().setMetricName("accuracy")
val predictionAndLabels = result.select("prediction", "label")
println("Test set accuracy = " + evaluator.evaluate(predictionAndLabels))
}
}
