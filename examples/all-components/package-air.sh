#!/bin/bash
ADT_PATH=~/Developer/flash/air/sdks/3.9_01030/bin/adt
SIMULATOR_SDK_PATH=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.0.sdk
CERT_PATH=PATH_TO_CERTIFICATE
CERT_PASS=CERTIFICATE_PASSWORD
PROVISIONING_PATH=MOBILE_PROVISION_FILE

source ../../../air.conf

echo $CERT_PATH

$ADT_PATH -package -target ipa-test-interpreter -provisioning-profile $PROVISIONING_PATH -storetype pkcs12 -keystore $CERT_PATH -storepass $CERT_PASS all-components all-components-app.xml all-components.swf -C ../ _assets