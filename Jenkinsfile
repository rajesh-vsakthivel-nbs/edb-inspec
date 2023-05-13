def BUILDSTATUS = 'INITIALVALUE'
pipeline {


    agent {
        kubernetes {

            cloud 'kubernetes-edbhub-dev'
            yaml """\
                apiVersion: v1
                kind: Pod
                metadata:
                  annotations:
                    cluster-autoscaler.kubernetes.io/safe-to-evict: "false"
                spec:
                  nodeSelector:
                    cbjAgent: true
                  tolerations:
                  - key: "cbjAgent"
                    operator: "Equal"
                    value: "true"
                    effect: "NoSchedule"
                  serviceAccountName: "jenkins"
                  containers:
                  - name: jnlp
                    image: ccoe-docker.artifactory.aws.nbscloud.co.uk/cloudbees-core-agent:1.18.0
                    resources:
                      requests:
                        memory: "500Mi"
                        cpu: "100m"
                      limits:
                        memory: "4Gi"
                        cpu: "2"
                  - name: test
                    image: edb-docker-dev-local.artifactory.aws.nbscloud.co.uk/pace-test/edbchefinspec
                    command:
                    - sleep
                    args:
                    - 99d
                    resources:
                      requests:
                        memory: "4Gi"
                        cpu: "2"
                      limits:
                        memory: "12Gi"
                        cpu: "8"
                    volumeMounts:
                    - mountPath: /tmp
                      name: temp-volume
                  volumes:
                  - name: temp-volume
                    emptyDir: {}
                  - name: ccoe-aws-cert
                    secret:
                      secretName: ccoe-aws-cert
                  - name: jenkins-docker-cfg
                    projected:
                      sources:
                      - secret:
                          name: artifactory-docker
                          items:
                            - key: .dockerconfigjson
                              path: config.json
            """.stripIndent()
        }
    }

    stages {
       
        stage('Run Tests') {

            steps {
                catchError(buildResult: "SUCCESS", stageResult: "SUCCESS") {
                    script {
                        container('test') {
                            try {
                                withCredentials([
                                        string(credentialsId: 'npm_token', variable: 'NPM_TOKEN'),
                                        string(credentialsId: 'lao_notprod_mongo_connection', variable: 'MONGO_CONNECTION_STRING'),
                                        usernamePassword(credentialsId: 'cco_browserstack_creds', usernameVariable: 'BROWSERSTACK_USER_NAME', passwordVariable: 'BROWSERSTACK_KEY')
                                ]) {

                                    sh '''
                                     export NODE_OPTIONS=--max-old-space-size=8192
                                     if [ -z "${npmRunCmd}" ]
                                     then
                                        echo "Running Branch Test Suite without ENV Variables"
                                        npm run browserStacktests-gui -- --environment="dev1" --componentOrPageName="**"  --ff="e2eLoanApplication"
                                     else
                                        echo "Running Regression Suite with ENV Variables"
                                        npm run ${npmRunCmd} -- --environment=${testEnvironment} --componentOrPageName=${componentOrPageName}  --ff=${featureFileName}

                                     fi
                                     cp -r tests/reports/json-results ${WORKSPACE}
                                     cp -a tests/reports/json-results/. ${WORKSPACE}/reports/BDD

                                     '''
                                }

                            }
                            finally {
                                //cucumber fileIncludePattern: 'reports/*.json'
                                BUILDSTATUS = sh(
                                        script: "node tests/utilities/resultAnalysis/resultAnalysis.js",
                                        returnStdout: true
                                ).trim()
                                archiveArtifacts 'tests/reports/**'
                                publishHTML(target: [allowMissing         : false,
                                                     alwaysLinkToLastBuild: true,
                                                     keepAll              : true,
                                                     reportDir            : 'tests/reports',
                                                     reportFiles          : 'index.html',
                                                     reportName           : 'Test Reports',
                                                     reportTitles         : 'Test Report'])
                            }
                        }
                    }
                }
            }


        } //End of Run Tests stage
        
    }
}
