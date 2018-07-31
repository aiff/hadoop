package homework

import java.io.{File, FileReader}

import scala.collection.mutable.ListBuffer
import scala.io.Source

/*
使用 scala 写一个 worldcount
/Users/yasin/Documents/codes/idea/hadoop/src/main/scala/homework/day004.scala
*/
object day004 {
    def main(args: Array[String]): Unit = {
        var wordList = new ListBuffer[String]
        try{
            val source = Source.fromFile("/Users/yasin/Documents/codes/idea/hadoop/src/main/resources/wordcount.log")
            var lines = source.getLines()
            for (ele <- lines){
                wordList.append(ele)
            }
            source.close()
        }
        var wordcount = wordList.flatMap(_.split(" ")).map((_,1)).groupBy(_._1).map(t => (t._1,t._2.size))
        print(wordcount)
    }
}