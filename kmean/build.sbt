name         := "kmeanmaltempo"
scalaVersion := "2.11.7"

libraryDependencies += "org.apache.spark" %% "spark-core" % "2.2.1"  
libraryDependencies += "org.apache.commons" % "commons-csv" % "1.2"
resolvers += "Akka Repository" at "http://repo.akka.io/releases/"
libraryDependencies += "org.apache.spark" %% "spark-sql" % "2.2.1"
libraryDependencies += "org.apache.spark" %% "spark-mllib" % "2.2.1"
