pipeline {
    agent {
        docker {
            image 'docker:latest'
            args '--privileged -v /var/run/docker.sock:/var/run/docker.sock --user root'
        }
    }
    environment {
        CI = 'true'
    }
    stages {
        stage('Build') {
            steps {
                script {
                    app = docker.build('dedyirama/react-app')
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    app.inside {
                        sh './jenkins/scripts/test.sh'
                    }
                }
            }
        }
        stage('Manual Approval') {
            steps {
                input message: 'Lanjutkan ke tahap Deploy?',
                    ok: 'Proceed'
            }
        }
        stage('Deploy') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub') {
                        app.push('latest')
                    }
                    withCredentials([sshUserPrivateKey(credentialsId: 'dicoding-submission-ssh', keyFileVariable: 'identity', usernameVariable: 'userName')]) {
                        def remote = [:]
                        remote.name = 'EC2 Deployment'
                        remote.host = '54.169.224.31'
                        remote.user = userName
                        remote.identityFile = identity
                        remote.allowAnyHosts = true

                        // Pull the Docker image and run the container on the remote server
                        sshCommand remote: remote, command: '''
                            docker pull dedyirama/react-app:latest
                            docker stop react-app || true
                            docker rm react-app || true
                            docker run -d --name react-app -p 3000:3000 dedyirama/react-app:latest
                        '''
                    }
                }
            }
        }
    }
}
