### Maven常用设置

1.本地仓库默认存放位置：

```
[root@linux-node2 ~]# ls ~/.m2/repository/　
```

2.Maven 国内镜像设置

```
[root@linux-node2 ~]# vim /usr/local/apache-maven-3.6.1/conf/settings.xml 
<mirrors>
    <mirror>
      <id>alimaven</id>
      <mirrorOf>central</mirrorOf>
      <name>aliyun maven</name>
      <url>http://maven.aliyun.com/nexus/content/repositories/central/</url>
    </mirror>
  </mirrors>
```

### Maven常用命令

※注意：运行Maven命令时一定要进入pom.xml文件所在的目录！
- mvn compile 编译（编译后会生成target目录）
- mvn clean 　清理（删除target）
- mvn test 　 测试
- mvn package   打包（打包后存放在target目录）
- mvn install  发布项目提交到本地仓库
- mvn deploy   把本地jar发布到remote
