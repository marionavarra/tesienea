import org.apache.spark.ml.PipelineModel 
import org.apache.spark.sql.{SparkSession, SQLContext}
import org.apache.spark.{SparkConf, SparkContext}

object ClassifierLogReg {
  def main(args: Array[String]) { 
    val sc = new SparkContext()
    val sameModel = PipelineModel.load("../submit/maltempo_spark-logistic-regression-model")
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)
    val df = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").load("test_output.txt") 
    val result = sameModel.transform(df)
	val predizione = result.select("prediction")
    println("Risultato " + predizione.head.getDouble(0))

  }
}

