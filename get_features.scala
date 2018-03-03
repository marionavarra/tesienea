import spark.implicits._
import org.apache.spark.ml.feature.RegexTokenizer
import org.apache.spark.ml.classification.LogisticRegression
import org.apache.spark.ml.classification.LogisticRegressionModel
import org.apache.spark.ml.feature.HashingTF
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.evaluation.BinaryClassificationEvaluator
import org.apache.spark.ml.param.ParamMap
import org.apache.spark.ml.tuning.ParamGridBuilder
import org.apache.spark.ml.tuning.CrossValidator
import org.apache.spark.ml.param._
import org.apache.spark.ml._

val articles = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").load("./maltempo.csv")
val topic2Label: Boolean => Double = isSci => if (isSci) 1 else 0
val toLabel = udf(topic2Label)
val labelled = articles.withColumn("label", toLabel($"topic".like("%true%"))).cache
//val Array(trainDF, testDF) = labelled.randomSplit(Array(0.75, 0.25))

val tokenizer = new RegexTokenizer().setInputCol("text").setOutputCol("words")

val wordsData = tokenizer.transform(labelled)

val hashingTF = new HashingTF().setInputCol(tokenizer.getOutputCol).setOutputCol("features").setNumFeatures(260)

val featurizedData = hashingTF.transform(wordsData)

