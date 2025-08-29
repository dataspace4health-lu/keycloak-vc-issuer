#!/bin/bash

# Custom build script for keycloak-vc-issuer
set -e  # Exit on any error

# Default value for the hash variable
GIT_HOST="https://dev.azure.com/Dataspace4Health/DS4H/_git"

# Parse arguments
case "$1" in
  "")
    ;&
  --http)
    if [[ -n "$2" ]]; then
      GIT_TOKEN=$2
    else
      read -sp "Password for '$GIT_HOST': " GIT_TOKEN
      echo
    fi

    GIT_CON="--http"
    GIT_HOST="${GIT_HOST/https:\/\//https:\/\/$GIT_TOKEN@}"
    ;;
  --ssh)
    GIT_TOKEN=

    # export GIT_SSH_COMMAND="ssh -i $GIT_TOKEN -o StrictHostKeyChecking=accept-new"
    GIT_CON="--ssh"
    GIT_HOST="git@ssh.dev.azure.com:v3/Dataspace4Health/DS4H"
    
    mkdir -p /root/.ssh
    ssh-keyscan ssh.dev.azure.com >> /root/.ssh/known_hosts
    chmod 644 /root/.ssh/known_hosts
    ;;
  --help)
    echo "Usage: $0 [--http|--ssh]"
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
esac

get_dependency_version() {
  dep_name=$1
  version=$(grep -oP "(?<=<version.$dep_name>).*?(?=</version.$dep_name>)" ./pom.xml)
  echo $version
}

SD_JWT_VERSION=$(get_dependency_version "id.walt.waltid-sd-jwt-jvm")
SERVICE_MATRIX_VERSION=$(get_dependency_version "id.walt.WaltID-ServiceMatrix")
SSIKIT_VERSION=$(get_dependency_version "id.walt.waltid-ssikit")

rm -rf repos
mkdir -p repos
mkdir -p .m2/repository
cd repos 

echo "Cloning repo waltid-sd-jwt"
git clone $GIT_HOST/waltid-sd-jwt
cd waltid-sd-jwt
# Check if the tag exists
if git rev-parse "refs/tags/$SD_JWT_VERSION" >/dev/null 2>&1; then
    echo "Tag '$SD_JWT_VERSION' exists. Checking out..."
    git checkout "$SD_JWT_VERSION"
fi
echo "Build waltid-sd-jwt"
./build.sh $GIT_CON $GIT_TOKEN
mvn install:install-file -Dfile=build/libs/waltid-sd-jwt-jvm-$SD_JWT_VERSION.jar -DgroupId=id.walt -DartifactId=waltid-sd-jwt-jvm -Dversion=$SD_JWT_VERSION -Dpackaging=jar -DlocalRepositoryPath=../../.m2/repository
cd ..

echo "Cloning repo waltid-servicematrix"
git clone $GIT_HOST/waltid-servicematrix
cd waltid-servicematrix
# Check if the tag exists
if git rev-parse "refs/tags/$SERVICE_MATRIX_VERSION" >/dev/null 2>&1; then
    echo "Tag '$SERVICE_MATRIX_VERSION' exists. Checking out..."
    git checkout "$SERVICE_MATRIX_VERSION"
fi
echo "Build waltid-servicematrix"
./build.sh $GIT_CON $GIT_TOKEN
mvn install:install-file -Dfile=build/libs/WaltID-ServiceMatrix-$SERVICE_MATRIX_VERSION.jar -DgroupId=id.walt.servicematrix -DartifactId=WaltID-ServiceMatrix -Dversion=$SERVICE_MATRIX_VERSION -Dpackaging=jar -DlocalRepositoryPath=../../.m2/repository
cd ..

echo "Cloning repo waltid-ssikit"
git clone $GIT_HOST/waltid-ssikit
cd waltid-ssikit
# Check if the tag exists
if git rev-parse "refs/tags/$SSIKIT_VERSION" >/dev/null 2>&1; then
    echo "Tag '$SSIKIT_VERSION' exists. Checking out..."
    git checkout "$SSIKIT_VERSION"
fi
echo "Build waltid-ssikit"
./build.sh $GIT_CON $GIT_TOKEN
mvn install:install-file -Dfile=build/libs/waltid-ssikit-$SSIKIT_VERSION.jar -DgroupId=id.walt -DartifactId=waltid-ssikit -Dversion=$SSIKIT_VERSION -Dpackaging=jar -DlocalRepositoryPath=../../.m2/repository
cd ..

cd ..
rm -rf ./repos

echo "Build keycloak-vc-issuer"
mvn clean install -Dmaven.repo.local=./.m2/repository -Dmaven.test.skip=true
