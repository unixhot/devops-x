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
. ./config/devopsx.conf

#Shell Env
SHELL_LOG="./logs/devopsx.log"

usage(){
echo $"Usage: $0 [ deploy ]"
}

red_color(){
    echo -e "\033[31m $1 \033[0m"
    LOGINFO=$1
    echo "$(date "+%Y-%m-%d") $(date "+%H-%M-%S") : ${LOGINFO} " >> ${SHELL_LOG}
}

green_color(){
    echo -e "\033[32m $1 \033[0m"
    LOGINFO=$1
    echo "$(date "+%Y-%m-%d") $(date "+%H-%M-%S") : ${LOGINFO} " >> ${SHELL_LOG}
}

check_k8s(){
    kube_status=`which kubectl`
    if [ "$?" -ne 0 ];then
        red_color "Cann't find kubectl command, please install kuberntes first!!!"
        exit 2
    else
       node_status=`kubectl get node|grep -v "grep" |grep "NotReady"|wc -l`
       if [ "$node_status" -ne 0 ];then
           red_color "Kuberetes node is not ready,please check it!!!"
           exit 3
       else
           cluster_status=`kubectl get cs|grep -v "grep"|grep "Unhealthy"|wc -l`
           if [ "$cluster_status" -ne 0 ];then
               red_color "Kubernetes cluster is not healthy,please check it!!!"
               exit 4
           else
               green_color "Kubernets cluster is ok!!!"
           fi
       fi
    fi
}


docker_registry_install(){
    docker --version
    if [ "$?" -ne 0 ];then
        action "docker installd failed" /bin/false
        exit 5
    fi
    docker load <./files/images/registry-2.6.2.tar
    mkdir /data/docker-registry -p && docker run -d -p 5000:5000 -v /data/docker-registry:/var/lib/registry --restart=always --name docker-registry registry.devopsedu.com:5000/k8s/registry:2.6.2
    green_color "======> Docker Registry <======"
    docker ps | grep docker-registry
}

load_config(){
    #nfs client provisioner
    sed -i "s/__nfs_server__/${nfs_server}/g" ./helm/plugins/values.yaml 
}


nfs_server_install(){
    yum install -y nfs-utils
    mkdir /data/volumes -p
    echo "/data/volumes ${nfs_client}(rw,no_root_squash,no_all_squash,sync,anonuid=501,anongid=501)" >> /etc/exports
    systemctl start nfs-server && systemctl enable nfs
}

push_images(){
    green_color "======> Load Images Local <======"
    for i in `ls files/images`;
      do docker load -i ./files/images/"$i";
    done
    # Tag And Push To Registry
    for image in `docker images | awk '{print $1":"$2}' | grep -v "^REPOSITORY"`;do
        docker push $image
        docker rmi $image
    done
    green_color "======> Registry Push Done <======"
}

helm_install(){
    HELM_PACKAGE="./files/packages/helm-v2.9.1-linux-amd64.tar.gz"
    helm_status=`which helm`
    if [ "$?" -eq 0 ];then
        action "helm already installed!!" /bin/false
    else
        tar xf $HELM_PACKAGE && /bin/cp ./linux-amd64/helm /usr/bin/
        action "helm install ok!!" /bin/true
    fi
}

tiller_install(){
    green_color "======> Tiller Install <======"
    kubectl create serviceaccount --namespace kube-system tiller
    kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    helm init -i registry.devopsedu.com:5000/k8s/tiller:v2.9.1 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
    kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
    sleep 5;
    tiller_status=""
    wait_time=0
    until [ "$tiller_status" == "Running" ] || [ "$wait_time" == "120" ];
    do
        sleep 5
        tiller_status=$(kubectl get pod -n kube-system|grep "tiller"|awk '{print $3}')
        wait_time=$(($wait_time+5))
    done
    if [ "$tiller_status" == "Running" ];then
       green_color "Tiller install ok in $wait_time seconds"
    else
       red_color "Tiller install failed"
       exit 6
    fi
}

charts_install(){
    green_color "======> App Install <======"
    kubectl label nodes ${edgenode} edgenode=true
    green_color "======> Plugins Install <======"
    helm install --name plugins ./helm/plugins
    green_color "======> OpenLDAP Install <======"
    helm install --name openldap ./helm/openldap
    green_color "======> Redmine Install <======"
    helm install --name redmine ./helm/redmine
    green_color "======> Gitlab Install <======"
    helm install --name gitlab ./helm/gitlab
    green_color "======> Jenkins Install <======"
    helm install --name jenkins ./helm/jenkins
    green_color "======> SonarQube Install <======"
    helm install --name sonarqube ./helm/sonarqube
    green_color "======> Nexus Install <======"
    helm install --name sonatype-nexus ./helm/sonatype-nexus
}

main(){
  case $1 in
    deploy)
        check_k8s;
        load_config;
    	docker_registry_install;
    	nfs_server_install;
    	push_images;
        helm_install;
    	tiller_install;
    	charts_install;
                ;;
    *) usage
        exit 1;
  esac
}

main $1
