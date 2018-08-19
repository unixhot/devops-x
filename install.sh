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
    docker run -d -p 5000:5000 -v /data/docker-registry:/var/lib/registry --restart=always --name docker-registry registry.devopsedu.com:5000/k8s/registry:2.6.2
    echo "======> Docker Registry <======"
    docker ps | grep docker-registry
}

nfs-server-install(){
    yum install -y nfs-utils
    mkdir /data/volumes -p
    echo "/data/volumes 192.168.56.0/24(rw,no_root_squash,no_all_squash,sync,anonuid=501,anongid=501)" >> /etc/exports
    systemctl start nfs-server
}

push-images(){
    echo "======> Load Images Local <======"
    for i in `ls files/images`;
      do docker load -i ./files/images/"$i";
    done
    # Tag And Push To Registry
    for image in `docker images | awk '{print $1":"$2}' | grep -v "^REPOSITORY"`;do
        docker push $image
        docker rmi $image
    done
    echo "======> Registry Push Done <======"
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
    helm init -i registry.devopsedu.com:5000/k8s/tiller:v2.9.1 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
    kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
}

charts-install(){
    echo "======> App Install <======"
    sleep 5;
    kubectl label nodes 192.168.56.12 edgenode=true
    helm install --name plugins ./helm/plugins
    helm install --name redmine ./helm/redmine
    helm install --name gitlab ./helm/gitlab
    helm install --name jenkins ./helm/jenkins
    helm install --name sonarqube ./helm/sonarqube
    helm install --name sonatype-nexus ./helm/sonatype-nexus
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
