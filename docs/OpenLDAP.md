## DevOps-X with OpenLDAP

### 写在前面的话

DevOps-X 中使用到的组件对接OpenLDAP的方式不尽相同，有的可以通过安装前的配置定义即可对接上，而有的组件是内置对接OpenLDAP功能的，这部分组件就需要在安装完成后在相应页面进行配置修改。

* Gitlab、Sonarqube需安装前配置对接OpenLDAP
* Jenkins、Redmine、Nexus需安装后页面配置OpenLDAP

### 详细配置过程

--- 
安装前配置

* 自定义OpenLDAP配置
* Gitlab配置OpenLDAP
* Sonarqube配置OpenLDAP
* Jenkins配置OpenLDAP插件

DevOps-X安装

安装后配置

* Jenkins配置对接OpenLDAP
* Redmine配置对接OpenLDAP
* Nexus  配置对接OpenLDAP

OpenLDAP用户创建

* 用户创建

<br>

### 安装前配置
---

**自定义OpenLDAP配置**


修改文件`devops-x/helm/openldap/values.yaml`

```
  ...
  Domain: "devopsedu.com"      ## 生产使用的Domain
  AdminPassword: "admin"     ## 管理员账户密码
  Https: "false"             ## 是否启用HTTPS
  ...

  ...
PhpLdapAdmin:
  Image: "docker.io/osixia/phpldapadmin"
  ImageTag: "0.6.12"
  ImagePullPolicy: "Always"
  Component: "phpadmin"

  Replicas: 1
  ingress:
    enabled: true

    hosts:
      - ldapadmin.devopsedu.com   ## phpldapadmin访问域名
```

修改完之后，保存。

`使用上述openldap配置后生成的配置信息如下`

```
LDAP_HOST: openldap.default.svc.cluster.local
LDAP_PORT: 389
LDAP_BIND_DN: "cn=admin,dc=devopsedu,dc=com"
LDAP_PASS: "admin"
LDAP_BASE: "dc=devopsedu,dc=com"
```

<br>

**Gitlab配置OpenLDAP**

修改文件`devops-x/helm/gitlab/values.yaml`

```
config:
  
  ...
  ...
  LDAP_ENABLED: "true"
  LDAP_LABEL: "LDAP"
  LDAP_HOST: "openldap.default.svc.cluster.local"
  LDAP_PORT: "389"
  LDAP_UID: "uid"
  LDAP_METHOD: "plain"
  LDAP_VERIFY_SSL: "false"                        ## 是否支持SSL
  LDAP_BIND_DN: "cn=admin,dc=example,dc=com"      ## 修改为自定义的OpenLDAP配置 
  LDAP_PASS: "admin"                              ## 修改为自定义的OpenLDAP密码
  LDAP_TIMEOUT: "10"
  LDAP_ACTIVE_DIRECTORY: "false"
  LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN: "false"
  LDAP_BLOCK_AUTO_CREATED_USERS: "false"
  LDAP_BASE: "dc=example,dc=com"                  ## 修改为自定义的OpenLDAP配置
  LDAP_USER_FILTER: ""
```

修改完之后，保存

<br>

**Sonarqube配置OpenLDAP**

修改文件`devops-x/helm/sonarqube/values.yaml`

```
plugins:
  install: 
    - "https://github.com/SonarSource/sonar-ldap/releases/download/2.2-RC3/sonar-ldap-plugin-2.2.0.601.jar"   ## 添加安装时依赖的插件
  resources: {}

  ... 
  ...

sonarProperties: |
  sonar.security.realm=LDAP
  ldap.url=ldap://openldap.default.svc.cluster.local:389
  ldap.bindDn=cn=admin,dc=example,dc=com                ## 配置自定义的OpenLDAP配置
  ldap.bindPassword=admin                               ## 配置自定义的OpenLDAP密码
  ldap.user.baseDn=ou=users,dc=example,dc=com           ## 配置自定义的OpenLDAP配置
  ldap.user.request=(&(objectClass=inetOrgPerson)(uid={login}))
  ldap.user.realNameAttribute=cn
  ldap.user.emailAttribute=mail
  ldap.group.baseDn=ou=groups,dc=example,dc=com         ## 配置自定义的OpenLDAP配置
  ldap.group.request=(&(objectClass=posixGroup)(memberUid={uid}))

  ...
```

修改完之后，保存

<br>

**Jenkins配置OpenLDAP插件** 

修改文件`devops-x/helm/jenkins/values.yaml`

```
  ...  

  InstallPlugins:
    - kubernetes:1.6.3
    - workflow-aggregator:2.5
    - workflow-job:2.21
    - credentials-binding:1.16
    - git:3.9.0
    - gitlab:1.5.6
    - ldap:1.2.0                       ## 新增支持ldap插件
    - ldapemail-plugin:0.8             ## 新增支持ldap插件

  ...
```

<br>

### DevOps-X安装
---

请[返回首页](https://github.com/unixhot/devops-x)开始你的Devops-X安装

<br>

### 安装后配置
---

**Jenkins配置对接OpenLDAP**

在Jenkins页面打开”系统管理“中的"全局安全配置"，然后“启用安全”中 配置LDAP

![参考如图](https://github.com/DINNAS/devops-x/blob/master/docs/jenkins-ldap-config-01.png)

配置Server
```
ldap://openldap.default.svc.cluster.local:389
```
此处根据上述配置，使用默认端口389.

配置root DN
```
dc=devopsedu,dc=com
```

配置User search filter
```
uid={0}
```

配置Manager DN
```
cn=admin,dc=devopsedu,dc=com
```

配置Manager Password
```
admin
```

其他配置按照需求填写，以上配置详细解释，参照[Jenkins链接](https://wiki.jenkins.io/display/JENKINS/LDAP+Plugin)

上述配置完毕后，既可以在“安全组”中添加OpenLDAP中的用户到Jenkins中。

2. Redmine配置对接OpenLDAP


3. Nexus  配置对接OpenLDAP

请参考：`devops-x/helm/openldap/README.md` 中 TEST 部分。


