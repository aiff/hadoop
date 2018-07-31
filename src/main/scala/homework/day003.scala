package homework

import java.io.FileWriter
import java.text.SimpleDateFormat
import java.util.{Date, Random}

import scala.collection.mutable.ListBuffer
/*
定义一个日志范本,然后输出到文本当中
*/

object day003 {
  def main (args: Array[String]): Unit = {
    var listBuffer = new ListBuffer[Any]
    for ( i <- 1 to 100000 ) {
      listBuffer.append (domain () + "\t" + traffic () + "\t" + "[" + time () + "]" + "\n")
    }
    try{
      var filewrite = new FileWriter("/Users/yasin/Documents/codes/idea/g3-scala/resources/log.txt",true)
      for (ele <- listBuffer){
        filewrite.write(ele.toString)
      }
      filewrite.close()
    }
  }
  def domain (): String = {
    /*
    随机一个字符串
     */
    val domain = ListBuffer ("www.ruozedata.com", "www.zhibo8.com", "www.dongqiudi.com")
    var wc = (new Random ().nextInt (domain.length))
    domain(wc)
  }
  def traffic (): Long ={
    /*
    随机一个长整数
     */
    var traffic = (new Random().nextInt(1000000))
    traffic
  }
  def time (): String = {
    /*
    取出当前时间
     */
    var currtime = new SimpleDateFormat("yyyy-MM-dd").format(new Date())
    var minTime = new SimpleDateFormat("mm:ss").format(new Date())
    var count = (new Random().nextInt(24))
    var time = currtime + " " + count.toString + ":" + minTime
    time
  }
}
