import spark.implicits._
import org.apache.spark.ml.feature.RegexTokenizer
import org.apache.spark.ml.classification.LogisticRegression
import org.apache.spark.ml.feature.HashingTF
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.evaluation.BinaryClassificationEvaluator
import org.apache.spark.ml.param.ParamMap
import org.apache.spark.ml.tuning.ParamGridBuilder
import org.apache.spark.ml.tuning.CrossValidator
import org.apache.spark.ml.param._


sealed trait Category
case object Meteo extends Category
case object NonMeteo extends Category
case class LabeledText(id: Long,text: String,category: Category)
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

case class Article(id: Long,text: String,category: Category)
val articles = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").load("./maltempo.csv")
val topic2Label: Boolean => Double = isSci => if (isSci) 1 else 0
val toLabel = udf(topic2Label)
val labelled = articles.withColumn("label", toLabel($"topic".like("%true%"))).cache
val Array(trainDF, testDF) = labelled.randomSplit(Array(0.75, 0.25))

val tokenizer = new RegexTokenizer().setInputCol("text").setOutputCol("words")


val hashingTF = new HashingTF().setInputCol(tokenizer.getOutputCol).setOutputCol("features").setNumFeatures(5000)


val lr = new LogisticRegression().setMaxIter(20).setRegParam(0.01)


val pipeline = new Pipeline().setStages(Array(tokenizer, hashingTF, lr))




val trainPredictions = model.transform(trainDF)
val testPredictions = model.transform(testDF)
trainPredictions.select('id, 'topic, 'text, 'label, 'prediction).show
trainPredictions.printSchema



val evaluator = new BinaryClassificationEvaluator().setMetricName("areaUnderROC")


val evaluatorParams = ParamMap(evaluator.metricName -> "areaUnderROC")
val areaTrain = evaluator.evaluate(trainPredictions, evaluatorParams)
val areaTest = evaluator.evaluate(testPredictions, evaluatorParams)

val paramGrid = new ParamGridBuilder().addGrid(hashingTF.numFeatures, Array(100, 1000)).addGrid(lr.regParam, Array(0.05, 0.2)).addGrid(lr.maxIter, Array(5, 10, 15)).build


val cv = new CrossValidator().setEstimator(pipeline).setEstimatorParamMaps(paramGrid).setEvaluator(evaluator).setNumFolds(10)

val cvModel = cv.fit(trainDF)

val cvPredictions = cvModel.transform(testDF)
cvPredictions.select('topic, 'text, 'prediction).show


evaluator.evaluate(cvPredictions, evaluatorParams)
cvPredictions.coalesce(1).write.option("header", "true").csv("sample_file.csv")
















