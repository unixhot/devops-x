# DevOps-X 基于Kubernetes的全开源DevOps工具链

- 使用SaltStack进行基础设施自动化
- 使用NFS/Ceph进行数据存储
- 使用Helm管理所有应用
- 使用OpenLDAP进行统一认证和登录

## 版本明细 v1.0 Beta

- 集成Redmine、Gitlab、Jenkins、SonarQube、Nexus、OpenLDAP
- 目前测试通过系统CentOS 7.4，Kubernetes版本v1.10.3

## 案例架构图

  ![架构图](https://github.com/unixhot/devops-x/blob/master/docs/devops-x.png)

## DevOps-X 部署

### 1.准备Kubernetes集群

1. 请参考自动化的部署[https://github.com/unixhot/salt-kubernetes](https://github.com/unixhot/salt-kubernetes)
2. 三台虚拟机建议的最小内存是4G，内存过低会导致Pod无法调度。
3. DevOps-X会安装CoreDNS、Dashboard、Heapster、Ingress，只需要部署好Kubernetes集群即可。
3. 目前在Helm中配置的镜像地址为registry.devopsedu.com，所以需要在所有节点设置hosts解析。
```
[root@linux-node1 ~]# vim /etc/hosts
192.168.56.11 registry.devopsedu.com

[root@linux-node2 ~]# vim /etc/hosts
192.168.56.11 registry.devopsedu.com

[root@linux-node3 ~]# vim /etc/hosts
192.168.56.11 registry.devopsedu.com

```

### 2.下载所有的镜像文件

所有的镜像均放置在了百度云盘，大小2.33G，解压后大小5～6G，请确认好磁盘空间。至少需要20G的可用磁盘容量。

下载地址: https://pan.baidu.com/s/1V2ZFsj36tjn7ONee4_WgFw  

### 3.修改配置文件

```
[root@linux-node1 devops-x]# vim config/devopsx.conf 
#NFS server IP 目前仅支持把NFS启动在Master节点，可以自行修改。
nfs_server=192.168.56.11

#NFS client IP range  设置NFS访问权限
nfs_client="192.168.56.0/24"

#treafik node IP    #设置再哪个节点上启动Treafik，多个节点执行设置label即可。
edgenode="192.168.56.12"
```

### 4.执行安装脚本
```
[root@linux-node1 ~]# cd devops-x
[root@linux-node1 devops-x]# ./install.sh deploy
```

### 5.配置访问解析

由于使用了Ingress，所以需要配置的hosts解析，实际生产使用，请绑定DNS。
将192.168.56.12 替换为edgeNode IP。
C:\Windows\System32\drivers\etc\hosts
```
192.168.56.12  jenkins.devopsedu.com
192.168.56.12  sonar.devopsedu.com
192.168.56.12  gitlab.devopsedu.com
192.168.56.12  nexus.devopsedu.com
192.168.56.12  redmine.devopsedu.com
192.168.56.12  ldapadmin.devopsedu.com
```

### 6.查看访问详情

查看安装的应用
```
[root@linux-node1 ~]# helm ls
```
查看访问详情，可以根据输出，获取访问的用户名和密码。
```
[root@linux-node1 ~]# helm status redmine

```

# DevOps 演示案例

## Gitlab演示

### 演示项目

- 创建一个Group：devops
- 创建一个Project： devops-demo

### 演示用户

- 张三   用户名：zhangsan-dev  zhangsan@example.com  开发工程师
- 李四   用户名：lisi-master   lisi@example.com  开发经理

### 权限分配

- 将张三分配到devops-demo项目，角色Developer
- 将李四分配到devops-demo项目，角色Master

### Git演示

- 拉取代码并编写，上传代码。
- 启用Deploy Key

1. 使用张三登录

 - 生成证书  ssh-keygen -t rsa
 - 将证书添加到Gitlab上  cat .ssh/id_rsa.pub

2. 启用Deploy Key

### Gitlab演示

1. 创建Milestones，例如每个Sprint对应一个Milestone。创建v0.1
2. 创建Issue，可以使用Issue模版，格式化Issue描述信息。 选择Milestone
3. 创建Boards，通过KANBAN管理进度。


### 提交阶段(Commit Stage): 

* 目标：每次提交都可以自动触发进行单元测试、编译、质量扫描

* 触发条件：开发人员Push代码到Gitlab项目的develop分支，自动触发该阶段执行。

* 步骤：

- 拉取代码
- 单元测试
- 代码编译
- 质量扫描

```
node {
    stage('拉取代码'){
        echo "Code Pull"
    }
    stage('单元测试'){
        echo "Unit Test"
        sh '/usr/local/maven/bin/mvn test'
    }
    stage('代码编译'){
        sh '/usr/local/maven/bin/mvn compile'
    }
    stage('质量扫描'){
         echo 'SonarQube'
    }
}
```

### Jenkins集成Gitlab

1.使用root用户登录Gitlab，创建Access Token
2.Jenkins-系统管理-系统设置-Gitlab设置

### 提交阶段流水线自动触发

1.提交阶段Job设置构建触发器，选择分支过滤
2.Gitlab-项目-Setting-Integration-Webhook


### 集成测试阶段

* 目标：将代码打包构建，并自动化部署到测试环境，运行自动化测试

* 触发条件：当Master分支有Merge操作，自动触发。

* 步骤：

- 拉取代码
- 单元测试
- 构建打包
- 上传到制品库
- 部署审核
- 自动化部署测试环境
- 自动化测试

### 部署阶段

* 目标：部署代码到对应的环境上

* 触发条件：用户手工选择需要部署的环境进行触发

* 步骤：

   - 自动化部署选择的环境
   - 自动化冒烟测试




