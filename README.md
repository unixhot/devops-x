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

所有的镜像均放置在了百度云盘，下载地址: https://pan.baidu.com/s/1P4nV8R06jBgfBVEsm9WPgg

### 3.执行安装脚本
```
[root@linux-node1 ~]# cd devops-x
[root@linux-node1 devops-x]# ./install.sh deploy
```

### 4.配置访问解析

由于使用了Ingress，所以需要配置的hosts解析，实际生产使用，请绑定DNS。
将192.168.56.12 替换为Node IP。
C:\Windows\System32\drivers\etc\hosts
```
192.168.56.12  jenkins.example.com
192.168.56.12  sonar.example.com
192.168.56.12  gitlab.example.com
192.168.56.12  nexus.example.com
192.168.56.12  redmine.example.com
```

### 5.查看访问详情

查看安装的应用
```
[root@linux-node1 ~]# helm ls
```
查看访问详情
```
[root@linux-node1 ~]# helm status redmine

```
