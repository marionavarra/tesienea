import org.apache.spark.ml.PipelineModel 
import org.apache.spark.sql.{SparkSession, SQLContext}
import org.apache.spark.{SparkConf, SparkContext}

object ClassifierLogReg {
  def main(args: Array[String]) { 
    val filename = args(0)
	val sc = new SparkContext()
    val sameModel = PipelineModel.load("../web/classificatore/public/modelli/"+filename+"_spark-logistic-regression-model")
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)
    val df = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").load("./test_output.txt") 
    val result = sameModel.transform(df)
	val predizione = result.select("prediction")
    println(filename + ":" + predizione.head.getDouble(0))

  }
}

