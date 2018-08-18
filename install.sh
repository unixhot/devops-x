#!/bin/bash
#********************************************
# Author:       DevOps-X
# Email:        shundong.zhao@linuxhot.com
# Organization: http://www.devopsedu.com/
# Description:  Docker Registry Install
#********************************************

#Shell variables
. /etc/init.d/functions
. /etc/profile

usage(){
echo $"Usage: $0 [ deploy ]"
}

docker-registry-install(){
    docker --version
    if [ "$?" -ne 0 ];then
        action "docker installd failed" /bin/false
        exit 1
    fi
    docker load <./files/images/registry-2.6.2.tar
    mkdir /data/docker-registry -p &&
    docker run -d -p 5000:5000 -v /data/docker-registry:/var/lib/registry --restart=always --name docker-registry registry.devopsedu.com:5000/devops/registry:2.6.2
    echo "==>Docker Registry<=="
    docker ps | grep docker-registry
}

nfs-server-install(){
    yum install -y nfs-utils
    echo "/data/volumes 192.168.99.0/24(rw,no_root_squash,no_all_squash,sync,anonuid=501,anongid=501)" >> /etc/exports
    systemctl start nfs-server
}

push-images(){
    #load images Local
    for i in `ls files/images`;
      do docker load -i ./files/images/"$i";
    done
    # Tag And Push To Registry
    # images load 后的默认是以 registry.devopsedu.com:5000/devops/xxxx 为repository的
    images_shortname=(
        nfs-client-provisioner \
        jenkins                \
        jnlp-slave-alpine      \
        gitlab                 \
        postgresql             \
        redis                  \
        minio                  \
        sonarqube              \
        redmine                \
        mysql                  \
        mariadb                \
        docker-nexus           \
        docker-nexus-backup    \
        docker-nexus-proxy     )

    for shortname in ${images_shortname[*]};
        do
        repository=$(docker images | grep $shortname | awk '{print $1}')
        tagname=$(docker images | grep $shortname | awk '{print $2}')
        localregistry="${repository}:${tagname}"
        echo "pushing $shortname ... now"
        echo "$localregistry"
        docker push $localregistry
        done
}

helm-install(){
    HELM_PACKAGE="./files/packages/helm-v2.9.1-linux-amd64.tar.gz"
    helm_status=`which helm`
    if [ "$?" -eq 0 ];then
        echo "helm already installed!!"
    else
        tar xf $HELM_PACKAGE && /bin/cp ./linux-amd64/helm /usr/bin/
        echo "helm install ok!!"
    fi
}

tiller-install(){
    kubectl create serviceaccount --namespace kube-system tiller
    kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    helm init -i registry.devopsedu.com:5000/devops/tiller:v2.9.1 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
    kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
}

charts-install(){
    for chart in `ls ./helm/`;
    do
        helm install --name $chart ./helm/$chart
    done 
}

main(){
  case $1 in
    deploy)
    	docker-registry-install;
    	nfs-server-install;
    	push-images;
        helm-install;
    	tiller-install;
    	charts-install;
                ;;
    *) usage
        exit 1;
  esac
}

main $1


