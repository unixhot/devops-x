# DevOps-X 基于Kubernetes的全开源DevOps工具链

- 使用SaltStack进行基础设施自动化
- 使用NFS/Ceph进行数据存储
- 使用Helm管理所有应用

## 版本明细 v1.0 Beta

- 集成Redmine、Gitlab、Jenkins、SonarQube、Nexus
- 目前测试通过系统CentOS 7.4，Kubernetes版本v1.10.3

## 案例架构图

  ![架构图](https://github.com/unixhot/devops-x/blob/master/docs/devops-x.png)

## 演示环境
    本项目演示环境资源由京东云赞助！ 京东云-预见无限可能  https://www.jdcloud.com/ 

## DevOps-X 部署

### 1.准备Kubernetes集群

1. 请参考自动化的部署https://github.com/unixhot/salt-kubernetes
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
192.168.56.12  jenkins.example.com
192.168.56.12  sonar.example.com
192.168.56.12  gitlab.example.com
192.168.56.12  nexus.example.com
192.168.56.12  redmine.example.com
192.168.56.12  ldapadmin.example.com
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

### 培训教学

- 目前DevOps学院已经上线《基于Kubernetes构建企业容器云》的【入门实战篇】和【进阶提高篇】
- 【DevOps学院】 http://www.devopsedu.com/

