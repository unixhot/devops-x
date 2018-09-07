## DevOps-X with OpenLDAP

## Custom OpenLDAP for Product 

*注意： 以下配置是在执行DevOps-X工具链安装前配置的*

1. 自定义OpenLDAP配置

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

修改完之后，保存

2. 配置Gitlab对接OpenLDAP

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

3. 配置SonarQube对接OpenLDAP

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

4. 配置Jenkins对接OpenLDAP 

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

详细配置请参考：[Jenkins配置LDAP链接](https://wiki.jenkins.io/display/JENKINS/LDAP+Plugin)

5. 配置Redmine 和 Sonatype-nexus对接OpenLDAP

由于应用本身已支持配置OpenLDAP ,因此，在页面直接添加OpenLDAP 相关配置 即可。

6. 新增LDAP用户

请参考：`devops-x/helm/openldap/README.md` 中 TEST 部分。


## 开始安装

在上述配置完成后，即可开始安装DevOpx-X 工具链

**请开始你的安装** 

