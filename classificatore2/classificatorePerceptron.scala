import org.apache.spark.ml.PipelineModel 
import org.apache.spark.sql.{SparkSession, SQLContext}
import org.apache.spark.{SparkConf, SparkContext}

object ClassifierPerceptron {
  def main(args: Array[String]) { 
    val filename = args(0)
	val sc = new SparkContext()
    val sameModel = PipelineModel.load("/home/dimartino/Documenti/mario/codice/tesienea/web/classificatore/public/modelli/"+filename+"_spark-perceptron-model")
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)
    val df = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").load("/home/dimartino/Documenti/mario/codice/tesienea/web/classificatore/public/data/test_output.txt") 
    val result = sameModel.transform(df)
	val predizione = result.select("prediction")
    println(filename + ":" + predizione.head.getDouble(0))

  }
}

