node {

    checkout scm
    env.DOCKER_API_VERSION="1.23"    
    appName = "hello-kenzan"
    registryHost = "127.0.0.1:30400/"
    imageName = "${registryHost}${appName}:latest"
    env.BUILDIMG=imageName

   stage "Cleanup"
        sh "kubectl delete service ${appName}"
        sh "kubectl delete deployment ${appName}"

    stage "Build"
    
        sh "docker build -t ${imageName} -f applications/hello-kenzan/Dockerfile applications/hello-kenzan"
    
    stage "Push"

        sh "docker push ${imageName}"

    stage "Deploy"

        kubernetesDeploy configs: "applications/${appName}/k8s/*.yaml", kubeconfigId: 'kenzan_kubeconfig'

}
