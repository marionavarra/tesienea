sealed trait Category
case object Meteo extends Category
case object NonMeteo extends Category
case class LabeledText(id: Long,text: String,category: Category)
val sqlContext = new org.apache.spark.sql.SQLContext(sc)
import spark.implicits._
case class Article(id: Long,text: String,category: Category)
val articles = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").load("maltempo.csv")
val topic2Label: Boolean => Double = isSci => if (isSci) 1 else 0
val toLabel = udf(topic2Label)
val labelled = articles.withColumn("label", toLabel($"topic".like("%true%"))).cache
val Array(trainDF, testDF) = labelled.randomSplit(Array(0.75, 0.25))
import org.apache.spark.ml.feature.RegexTokenizer
val tokenizer = new RegexTokenizer().setInputCol("text").setOutputCol("words")

import org.apache.spark.ml.feature.HashingTF
val hashingTF = new HashingTF().setInputCol(tokenizer.getOutputCol).setOutputCol("features").setNumFeatures(5000)

import org.apache.spark.ml.classification.LogisticRegression
val lr = new LogisticRegression().setMaxIter(20).setRegParam(0.1)

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

import org.apache.spark.ml.tuning.ParamGridBuilder
val paramGrid = new ParamGridBuilder()
  .addGrid(hashingTF.numFeatures, Array(100, 1000))
  .addGrid(lr.regParam, Array(0.05, 0.2))
  .addGrid(lr.maxIter, Array(5, 10, 15))
  .build


import org.apache.spark.ml.tuning.CrossValidator
import org.apache.spark.ml.param._
val cv = new CrossValidator()
  .setEstimator(pipeline)
  .setEstimatorParamMaps(paramGrid)
  .setEvaluator(evaluator)
  .setNumFolds(10)

val cvModel = cv.fit(trainDF)

val cvPredictions = cvModel.transform(testDF)

cvPredictions.select('topic, 'text, 'prediction).show
evaluator.evaluate(cvPredictions, evaluatorParams)

val bestModel = cvModel.bestModel













