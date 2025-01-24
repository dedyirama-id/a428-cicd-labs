pipeline {
    agent {
        docker {
            image 'node:16-buster-slim'
            args '-p 3000:3000'
        }
    }
    environment {
        CI = 'true'
    }
    stages {
        stage('Build') {
            steps {
                sh 'npm install'
            }
        }
        stage('Test') {
            steps {
                sh './jenkins/scripts/test.sh'
            }
        }
        stage('Manual Approval') {
            steps {
                input message: 'Lanjutkan ke tahap Deploy?',
                    ok: 'Proceed'
            }
        }
        stage('Deploy') {
            environment {
                DEPLOY_DIR = '/home/ec2-user/react-app'
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'dicoding-submission-ssh', keyFileVariable: 'identity', usernameVariable: 'userName')]) {
                    script {
                        def remote = [:] 
                        remote.name = 'EC2 Deployment'
                        remote.host = '54.169.224.31'
                        remote.user = userName
                        remote.identityFile = identity
                        remote.allowAnyHosts = true

                        // Create a temporary directory and copy files excluding node_modules
                        sh 'sudo apt-get update && sudo apt-get install -y rsync'
                        sh 'mkdir -p temp_project && rsync -av --exclude=node_modules ./ temp_project/'

                        // Create a tarball from the temporary directory
                        sh 'tar -czf project.tar.gz -C temp_project .'

                        // Upload the tarball to the target directory
                        sshPut remote: remote, from: 'project.tar.gz', into: "${env.DEPLOY_DIR}"

                        // Extract the tarball and run commands on the remote server
                        sshCommand remote: remote, command: """
                            cd ${env.DEPLOY_DIR}
                            tar -xzf project.tar.gz
                            rm project.tar.gz
                            ./jenkins/scripts/kill.sh
                            ./jenkins/scripts/deliver.sh
                        """
                    }
                }

                sleep(time: 1, unit: 'MINUTES')
            }
        }
    }
}
