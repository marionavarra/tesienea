sealed trait Category
case object Meteo extends Category
case object NonMeteo extends Category
case class LabeledText(id: Long,text: String,category: Category)
val sqlContext = new org.apache.spark.sql.SQLContext(sc)
import spark.implicits._
case class Article(id: Long,text: String,category: Category)
val articles = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").load("/home/mario/Dropbox/Personali/tesi/codice/dati/maltempo.csv")
val topic2Label: Boolean => Double = isSci => if (isSci) 1 else 0
val toLabel = udf(topic2Label)
val labelled = articles.withColumn("label", toLabel($"topic".like("%true%"))).cache
val Array(trainDF, testDF) = labelled.randomSplit(Array(0.75, 0.25))
import org.apache.spark.ml.feature.RegexTokenizer
val tokenizer = new RegexTokenizer()
  .setInputCol("text")
  .setOutputCol("words")

import org.apache.spark.ml.feature.HashingTF
val hashingTF = new HashingTF()
  .setInputCol(tokenizer.getOutputCol)  // it does not wire transformers -- it's just a column name
  .setOutputCol("features")
  .setNumFeatures(5000)

import org.apache.spark.ml.classification.LogisticRegression
val lr = new LogisticRegression().setMaxIter(20).setRegParam(0.01)

import org.apache.spark.ml.Pipeline
val pipeline = new Pipeline().setStages(Array(tokenizer, hashingTF, lr))
val model = pipeline.fit(trainDF)

val trainPredictions = model.transform(trainDF)
val testPredictions = model.transform(testDF)
trainPredictions.select('id, 'topic, 'text, 'label, 'prediction).show
trainPredictions.printSchema


import org.apache.spark.ml.evaluation.BinaryClassificationEvaluator
val evaluator = new BinaryClassificationEvaluator().setMetricName("areaUnderROC")

import org.apache.spark.ml.param.ParamMap
val evaluatorParams = ParamMap(evaluator.metricName -> "areaUnderROC")
val areaTrain = evaluator.evaluate(trainPredictions, evaluatorParams)
val areaTest = evaluator.evaluate(testPredictions, evaluatorParams)


















