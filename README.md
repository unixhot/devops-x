# DevOps-X 基于Kubernetes的全开源DevOps工具链

- 使用SaltStack进行基础设施自动化
- 使用NFS/Ceph进行数据存储
- 使用Helm管理所有应用

## 版本明细 v1.0 Beta

- 集成Redmine、Gitlab、Jenkins、SonarQube、Nexus

## 案例架构图

  ![架构图](https://github.com/unixhot/devops-x/blob/master/docs/devops-x.png)

## DevOps-X 部署

### 1.准备Kubernetes集群

请参考https://github.com/unixhot/salt-kubernetes进行自动化的部署

### 2.下载所有的镜像文件

所有的镜像均放置在了百度云盘，下载地址：

### 3.执行安装脚本
```
[root@linux-node1 ~]# cd devops-x
[root@linux-node1 devops-x]# ./install.sh 
```



