@Library(['utilities'])

String deploymentName() {
  if (env.BRANCH_NAME == 'master') {
    return 'charts'
  } else {
    return "charts-${urlSafeBranchName()}"
  }
}

def deployChartRepository() {
  sh "oc project ${OC_PROJECT}"
  sh 'helm init --upgrade --wait'
  sh 'helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com'
  sh 'helm repo add monocular https://kubernetes-helm.github.io/monocular'

  // Replace charts.cloud.skookum.com in requirements files with DEPLOYMENT_URL
  sh "find ./charts -type f -print0 | xargs -0 sed -i 's/charts\\.cloud\\.skookum\\.com/${DEPLOYMENT_NAME}.cloud.skookum.com/g'"

  String additionalArgs = ''
  if (isIntegrationBranch()) {
    additionalArgs += '--set chartmuseum.env.open.ALLOW_OVERWRITE=false'
  } else {
    additionalArgs += '--set chartmuseum.persistence.Enabled=false --set chartmuseum.env.open.ALLOW_OVERWRITE=true'
  }

  dir('charts/chart-repository') {
    sh 'helm package . --dependency-update'
    sh "helm upgrade --install ${DEPLOYMENT_NAME} . --set route.host=${DEPLOYMENT_ROUTE} ${additionalArgs} --wait --force --namespace helm-poc"
  }
}

boolean urlIsHealthy(Map config) {
    String validResponseCodes = config.validResponseCodes ? config.validResponseCodes : '100:599'
    int healthyStatusCode = config.healthyStatusCode ? config.healthyStatusCode : 200
    def response = httpRequest ignoreSslErrors: true, url: config.url, validResponseCodes: validResponseCodes

    return (response.status == healthyStatusCode)
}

def awaitDeploymentReadiness(Map config) {
    int seconds = config.timeoutSeconds ? config.timeoutSeconds : 90

    timeout(time: seconds, unit: 'SECONDS') {
        waitUntil {
            return urlIsHealthy(url: config.url)
        }
    }

    echo "Deployed to ${config.url}"
}

pipeline {
  agent { label 'nodejs-build' }
  environment {
    DEPLOYMENT_NAME=deploymentName()
    DEPLOYMENT_ROUTE="${DEPLOYMENT_NAME}.cloud.skookum.com"
    DEPLOYMENT_URL="https://${DEPLOYMENT_ROUTE}"
    TILLER_NAMESPACE='helm-poc'
    OC_PROJECT='helm-poc'
  }
  stages {
    stage('Lint') {
      steps {
        cancelPreviousBuilds()
        sh "scripts/lint/all-charts.sh"
      }
    }
    stage('Deploy Repository') {
      steps {
        deployChartRepository()
        awaitDeploymentReadiness url: DEPLOYMENT_URL
        helmInit repository: DEPLOYMENT_URL
      }
    }
    stage('Publish') {
      steps {
        sh "scripts/publish/all-charts.sh ${DEPLOYMENT_URL}"
      }
    }
  }
}
