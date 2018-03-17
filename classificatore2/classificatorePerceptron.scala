import org.apache.spark.ml.PipelineModel 
import org.apache.spark.sql.{SparkSession, SQLContext}
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.ml.feature.HashingTF
import org.apache.spark.ml.feature.RegexTokenizer

object ClassifierPerceptron {
  def main(args: Array[String]) { 
    val filename = args(0)
   // val sparkConf = new SparkConf().setAppName("SOME APP NAME").setMaster("local[*]").set("spark.executor.memory","1g");
    //val sparkConf = new SparkConf().setAppName("SOME APP NAME").setMaster("spark://babylon.casaccia.enea.it:7077").set("spark.executor.memory","1g");
	//val sc = new SparkContext(sparkConf)
	val sc = new SparkContext()
    val sameModel = PipelineModel.load("/home/dimartino/Documenti/mario/codice/tesienea/web/classificatore/public/modelli/"+filename+"_spark-perceptron-model")
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)
    val df = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").load("/home/dimartino/Documenti/mario/codice/tesienea/web/classificatore/public/data/test_output.txt") 
    val topic2Label: Boolean => Int = isSci => if (isSci) 1 else 0
    val tokenizer = new RegexTokenizer().setInputCol("text").setOutputCol("words")
    val hashingTF = new HashingTF().setInputCol(tokenizer.getOutputCol).setOutputCol("features").setNumFeatures(246)
    val word = tokenizer.transform(df)   
    val featurized = hashingTF.transform(word)
    val data = featurized.select("features")
    val result = sameModel.transform(data)
    val predizione = result.select("prediction")
    println(filename + ":" + predizione.head.getDouble(0))
  }
}

