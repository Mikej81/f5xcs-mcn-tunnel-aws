#!/usr/bin/env bash

#Need to check OS / Platform
osName=`uname -s`
case $osName in
  Linux*)   export machine="Linux" ;;
  Darwin*)  export machine="Mac" ;;
  *)        export machine="UNKNOWN:$osName" ;;
esac

echo $machine

if [[ "$machine" == "Mac" ]]; then
  echo "OSX Detected, need to Install / Update Brew and jq..."
  #Need to update brew and make sure jq is installed to process json
  echo "updating & upgrading brew..."
  brew update || brew update
  brew upgrade

  if brew ls --versions jq > /dev/null; then
    # The package is installed
    echo "jq installed proceeding..."
  else
    echo "installing jq..."
    brew install jq
  fi
elif [[ "$machine" == "Linux" ]]; then
  if [ -f /etc/redhat-release ]; then
    yum -y update
    yum -y install jq
  fi
  if [ -f /etc/lsb-release ]; then
    apt-get --assume-yes update
    apt-get --assume-yes install jq
  fi
fi

# Map AWS Cred ENV

export VOLT_API_P12_FILE=/api-creds.p12
export VES_P12_PASSWORD=123456789

#export VOLT_API_CERT=
#export VOLT_API_KEY=
#export VOLT_API_URL=
