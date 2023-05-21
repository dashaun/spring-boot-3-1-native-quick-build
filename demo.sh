#!/usr/bin/env bash
. demo-magic.sh
export TYPE_SPEED=100
export DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"
TEMP_DIR=upgrade-example

function initSDKman() {
  source "$HOME/.sdkman/bin/sdkman-init.sh"
}

function createAppWithInitializr {
  # hide the evidence
  rm -rf $TEMP_DIR
  mkdir $TEMP_DIR
  cd $TEMP_DIR || exit
  clear
  pei "java -version"
  pei "curl https://start.spring.io/starter.tgz -d dependencies=web,actuator -d javaVersion=17 -d bootVersion=3.1.0 -d type=maven-project | tar -xzf - || exit"
}

function validateApp {
  pei "./mvnw -q clean package spring-boot:start -DskipTests"
  pei "http :8080/actuator/health"
  pei "vmmap $(jps | grep DemoApplication | cut -d ' ' -f 1) | grep Physical"
  pei "./mvnw spring-boot:stop -Dspring-boot.stop.fork"
}

function nativeValidate {
  pei "./mvnw -Pnative native:compile -DskipTests"
  pei "./target/demo &"
  pei "http :8080/actuator/health"
  pei "export NPID=$(pgrep demo)"
  pei "vmmap $NPID | grep Physical"
  pei "kill -9 $NPID"
}

function quickNativeValidate {
  pei "GRAALVM_QUICK_BUILD=true ./mvnw -Pnative native:compile -DskipTests"
  pei "./target/demo &"
  pei "http :8080/actuator/health"
  pei "export NPID=$(pgrep demo)"
  pei "vmmap $NPID | grep Physical"
  pei "kill -9 $NPID"
}

initSDKman
createAppWithInitializr
quickNativeValidate
nativeValidate