pipeline {
    agent any
    stages {
        stage("Checkout") {
            steps {
                git 'https://github.com/ariharasudhanr/DevOps-CI-CD.git'
            }
        }
        stage("Copy files from Jenkins to Ansible & K8s") {
            steps {
                sh 'scp /var/lib/jenkins/workspace/registers/index.html ubuntu@10.0.1.182:/home/ubuntu/'
                sh 'scp /var/lib/jenkins/workspace/registers/Dockerfile ubuntu@10.0.1.182:/home/ubuntu/'
                sh 'scp /var/lib/jenkins/workspace/registers/ansible.yml ubuntu@10.0.1.182:/home/ubuntu/'
                sh 'scp /var/lib/jenkins/workspace/registers/deployment.yml ubuntu@10.0.1.246:/home/ubuntu/'
                sh 'scp /var/lib/jenkins/workspace/registers/service.yml ubuntu@10.0.1.246:/home/ubuntu/'
            }
        }
        stage("Create Docker image from Dockerfile") {
            steps {
                sh 'ssh ubuntu@10.0.1.182 cd /home/ubuntu/'
                sh 'ssh ubuntu@10.0.1.182 docker image build -t ariharasudhanr/$JOB_NAME:v1.$BUILD_ID .'
                sh 'ssh ubuntu@10.0.1.182 docker image build -t ariharasudhanr/$JOB_NAME:latest .'
            }
        }
        stage("Push Docker image to DockerHub") {
            steps {
                withCredentials([string(credentialsId: 'DockerHub', variable: 'docker_password')]) {
                    sh 'ssh ubuntu@10.0.1.182 docker login -u ariharasudhanr -p ${docker_password}'
                    sh 'ssh ubuntu@10.0.1.182 docker image push ariharasudhanr/$JOB_NAME:v1.$BUILD_ID'
                    sh 'ssh ubuntu@10.0.1.182 docker image push ariharasudhanr/$JOB_NAME:latest'
                }
            }
        }
        stage("Prune Docker images") {
            steps {
                sh 'ssh ubuntu@10.0.1.182 docker image prune -af'
                sh 'ssh ubuntu@10.0.1.182 docker logout'
            }
        }
        stage("Execute K8s via Ansible") {
            steps {
                sh 'ssh ubuntu@10.0.1.182 cd /home/ubuntu'
                sh 'ssh ubuntu@10.0.1.182 ansible-playbook ansible.yml'
            }
        }
       
    }
    post {
        always {
            script {
                def jobName = env.JOB_NAME
                def buildNumber = env.BUILD_NUMBER
                def pipelineStatus = currentBuild.result ?: 'SUCCESS'
                def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'

                def body = """
                    <html>
                    <body>
                    <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                    <h2>${jobName} - Build ${buildNumber}</h2>
                    <div style="background-color: ${bannerColor}; padding: 10px;">
                    <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                    </div>
                    <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                    </div>
                    </body>
                    </html>
                """

                emailext (
                    subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                    body: body,
                    to: 'ariharasudhanr1@gmail.com',
                    from: 'jenkins@example.com',
                    replyTo: 'jenkins@example.com',
                    mimeType: 'text/html'
                )
            }
        }
    }
}
