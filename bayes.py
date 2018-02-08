from pyspark.mllib.regression import LabeledPoint
from pyspark.ml.classification import NaiveBayes
from pyspark.ml.evaluation import MulticlassClassificationEvaluator
from pyspark.ml.feature import IndexToString, HashingTF, Tokenizer, StringIndexer, VectorIndexer
from pyspark.ml import Pipeline
from pyspark.sql import Row
from pyspark.ml Transformer



textFile = sc.textFile("/home/dimartino/Documenti/mario/dati/maltempo.csv")
data = textFile.map(lambda line: line.split(',', 2)).map(lambda p: Row(id=p[0], category=p[2], text=p[1]))
schemaSell = sqlContext.createDataFrame(data)
schemaSell.write.save("/home/dimartino/Documenti/mario/dati/sell.parquet", format="parquet")

schemaSell = sqlContext.read.load("/home/dimartino/Documenti/mario/dati/sell.parquet")

train_data, test_data = schemaSell.randomSplit([0.8, 0.2])

categoryIndexer = StringIndexer(inputCol="category", outputCol="label")
tokenizer = Tokenizer(inputCol="text", outputCol="words")
hashingTF = HashingTF(inputCol="words", outputCol="features", numFeatures=10000)
nb = NaiveBayes(smoothing=1.0, modelType="multinomial")

categoryConverter = IndexToString(inputCol="prediction", outputCol="predCategory", labels=["true","false"])
pipeline = Pipeline(stages=[categoryIndexer, tokenizer, hashingTF, nb, categoryConverter])

model = pipeline.fit(train_data)
pr = model.transform(test_data)

evaluator = MulticlassClassificationEvaluator(labelCol="label", predictionCol="prediction", metricName="f1")
metric = evaluator.evaluate(pr)

print "F1 metric = %g" % metric
