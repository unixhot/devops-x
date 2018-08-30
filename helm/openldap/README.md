## A Helm Chart for OpenLDAP

## Installation
Install this in your cluster with [Helm](https://github.com/kubernetes/helm):

```
helm repo add cnct http://atlas.cnct.io
```
```
helm install cnct/openldap
```

Get Helm [here](https://github.com/kubernetes/helm/blob/master/docs/install.md).

Or add the following to your [K2](https://github.com/samsung-cnct/k2) configuration template:
```
helmConfigs:
  - &defaultHelm
    name: defaultHelm
    kind: helm
    repos:
      -
        name: atlas
        url: http://atlas.cnct.io
    charts:
      -
        name: openldap
        repo: atlas
        chart: openldap
        version: 0.1.0
        namespace: kube-auth
        values:
          OpenLdap:
            Domain: <Your LDAP base domain>
            AdminPassword: <Your admin password>
```

Get [K2](https://github.com/samsung-cnct/k2) to help you deploy a Kubernetes cluster.

## Assets

Kubernetes Assets in this chart.

**OpenLDAP**
OpenLDAP

see details in [official site](http://www.openldap.org/)

default values below

```
OpenLdap:
  Image: "docker.io/osixia/openldap"
  ImageTag: "1.1.7"
  ImagePullPolicy: "Always"
  Component: "openldap"

  Replicas: 1

  Cpu: "512m"
  Memory: "200Mi"

  Domain: "local.io"
  AdminPassword: "admin"
  Https: "false"
```

**phpLDAPadmin**
LDAP admin UI

see details in [official site](http://phpldapadmin.sourceforge.net/)

default values below

```
PhpLdapAdmin:
  Image: "docker.io/osixia/phpldapadmin"
  ImageTag: "0.6.12"
  ImagePullPolicy: "Always"
  Component: "phpadmin"

  Replicas: 1

  NodePort: 31080
  #LdapEndpoint: kube-1.local.io:30389

  Cpu: "512m"
  Memory: "200Mi"
```

## Test
1. From your browser, access to PHPAdmin
2. login to ldap
  Login DN :
    cn=admin,dc=local,dc=io
  Password :
    admin

3. You can import default example below

```
version: 1

# Entry 1: dc=local,dc=io
#dn: dc=local,dc=io
#dc: local
#o: Example Inc.
#objectclass: top
#objectclass: dcObject
#objectclass: organization

# Entry 2: cn=admin,dc=local,dc=io
#dn: cn=admin,dc=local,dc=io
#cn: admin
#description: LDAP administrator
#objectclass: simpleSecurityObject
#objectclass: organizationalRole
#userpassword: {SSHA}C8hnfmob9E2lt0ODMr11JCKYFsCgZwR/

# Entry 3: ou=groups,dc=local,dc=io
dn: ou=groups,dc=local,dc=io
objectclass: organizationalUnit
objectclass: top
ou: groups

# Entry 4: cn=cnct,ou=groups,dc=local,dc=io
dn: cn=cnct,ou=groups,dc=local,dc=io
cn: cnct
gidnumber: 500
memberuid: keyolk
objectclass: posixGroup
objectclass: top

# Entry 5: ou=users,dc=local,dc=io
dn: ou=users,dc=local,dc=io
objectclass: organizationalUnit
objectclass: top
ou: users

# Entry 6: uid=keyolk,ou=users,dc=local,dc=io
dn: uid=keyolk,ou=users,dc=local,dc=io
cn: keyolk
gidnumber: 500
givenname: chanhun
homedirectory: /home/keyolk
mail: keyolk@gmail.com
mobile: 010-6350-5811
objectclass: inetOrgPerson
objectclass: top
objectclass: posixAccount
pager: cn=admin,dc=local,dc=io
sn: keyolk
uid: keyolk
uidnumber: 1000
userpassword: <base64 encoded md5 hash value>
```

## To Do
- Support HA configuration
- Support TLS configuration

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## Credit

Created and maintained by the Samsung Cloud Native Computing Team.
