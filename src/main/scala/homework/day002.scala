package homework

import scalikejdbc.{DB, SQL}
import scalikejdbc.config.DBs
/*
使用scalikejdbc 连接 mysql 进行增删改查
*/
case class User(id:Int,name:String,age:Int)
object day002 {
  def main (args: Array[String]): Unit = {
    DBs.setupAll()
    var user:List[User] = List(User(2,"lisi",24),User(3,"wangwu",30))
    InsertM(user)
    var users = SelectM()
    for (user <- users){
      println("id:" + user.id + "---name:" + user.name + "---age:" + user.age)
    }
  }
  //增
  def InsertM(user:List[User]): Unit = {
      DB.localTx { implicit session =>
        for (i <- user){
          SQL("insert into user values (?,?,?)").bind(i.id,i.name,i.age).update().apply()
        }
      }
  }
  //删
  def DeleteM(id:Int): Unit ={
    DB.autoCommit{ implicit session =>
      SQL("delete from user where id = (?)").bind(id).update().apply()
    }
  }
  //查
  def SelectM(): List[User] = {
    DB.readOnly { implicit session =>
      SQL("select * from user").map(rs => User(rs.int("id"),rs.string("name"),rs.int("age"))).list().apply()
    }
  }
  //改
  def UpdateM(): Unit ={
    DB.autoCommit{implicit session =>
      SQL("update user set age = (?) where id = (?)").bind(28,1).update().apply()
    }
  }
}