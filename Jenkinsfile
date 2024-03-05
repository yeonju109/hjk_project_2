pipeline {
    agent any

    tools {
        maven 'Maven3' 
    }

    environment{
        REGION = 'ap-northeast-2'
        EKS_API = 'https://E754151AE3AFC1D81379C15E57E6395C.gr7.ap-northeast-2.eks.amazonaws.com'
        EKS_CLUSTER_NAME = 'eks-cluster'
        EKS_JENKINS_CREDENTIAL_ID = 'kubectl-deploy-credentials'
        ECR_PATH = '992382680302.dkr.ecr.ap-northeast-2.amazonaws.com'
        NGINX_ECR_IMAGE = 'nginx'
        TOMCAT_ECR_IMAGE = 'tomcat'
        AWS_CREDENTIAL_ID = 'aws-credential'
        githubCredential = 'github'
        gitEmail = 'yeonju7548@naver.com'
        gitName = 'yeonju109'
    }
    stages {
        // 깃허브 계정으로 레포지토리를 클론한다.
        stage('Checkout Application Git Branch') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: githubCredential, url: 'https://github.com/yeonju109/hjk_project_2.git']]])
            }
            // steps 가 끝날 경우 실행한다.
            // steps 가 실패할 경우에는 failure 를 실행하고 성공할 경우에는 success 를 실행한다.
            post {
                failure {
                echo 'Repository clone failure' 
                }
                success {
                echo 'Repository clone success' 
                }
            }
        }
        stage('Docker Build'){
            steps {
                script{
                    docker.withRegistry("https://${ECR_PATH}", "ecr:${REGION}:${AWS_CREDENTIAL_ID}"){
                    nginx_image = docker.build("${ECR_PATH}/${NGINX_ECR_IMAGE}")
                    tomcat_image = docker.build("${ECR_PATH}/${TOMCAT_ECR_IMAGE}")
                    }
                }
            }
        }
        stage('Push to ECR'){
            steps {     
                script{                       
                    docker.withRegistry("https://${ECR_PATH}", "ecr:${REGION}:${AWS_CREDENTIAL_ID}"){
                    nginx_image.push("v${env.BUILD_NUMBER}")
                    docker.withRegistry("https://${ECR_PATH}", "ecr:${REGION}:${AWS_CREDENTIAL_ID}"){
                    tomcat_image.push("v${env.BUILD_NUMBER}")
                    }
                    }
                }
            }
        }
        stage('CleanUp Images'){
            steps{
                sh"""
                docker rmi ${ECR_PATH}/${NGINX_ECR_IMAGE}:v$BUILD_NUMBER
                docker rmi ${ECR_PATH}/${NGINX_ECR_IMAGE}:latest
                docker rmi ${ECR_PATH}/${TOMCAT_ECR_IMAGE}:v$BUILD_NUMBER
                docker rmi ${ECR_PATH}/${TOMCAT_ECR_IMAGE}:latest
                """
            }
        }
        stage('K8S Manifest Update') {
            steps {
                // git 계정 로그인, 해당 레포지토리의 main 브랜치에서 클론
                git credentialsId: githubCredential,
                    url: 'https://github.com/yeonju109/hjk_project_2.git',
                    branch: 'main'  
        
                // 이미지 태그 변경 후 메인 브랜치에 푸시
                sh "git config --global user.email ${gitEmail}"
                sh "git config --global user.name ${gitName}"
                // nginx-deploy.yaml 파일 내에서 'nginx:' 이라는 문자열을 찾아 해당 문자열을 'nginx:${currentBuild.number}' 로 대체하는 작업 수행 
                sh "sed -i 's/nginx:.*/nginx:v${env.BUILD_NUMBER}/g' nginx-deploy.yaml"
                // tomcat-deploy.yaml 파일 내에서 'tomcat:' 이라는 문자열을 찾아 해당 문자열을 'tomcat:${currentBuild.number}' 로 대체하는 작업 수행 
                sh "sed -i 's/tomcat:.*/tomcat:v${env.BUILD_NUMBER}/g' tomcat-deploy.yaml"
                sh "git add ."
                sh "git commit -m 'fix:${ECR_PATH}/${NGINX_ECR_IMAGE} v${env.BUILD_NUMBER} image versioning'"
                sh "git branch -M main"
                sh "git remote remove origin"
                sh "git remote add origin git@github.com:yeonju109/hjk_project_2.git"
                sh "git push -u origin main"
            }
            post {
                failure {
                echo 'K8S Manifest Update failure'
                slackSend (color: '#FF0000', message: "FAILED: K8S Manifest Update '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
                }
                success {
                echo 'K8s Manifest Update success'
                slackSend (color: '#0AC9FF', message: "SUCCESS: K8S Manifest Update '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
                }
            }
        }
    }
}
