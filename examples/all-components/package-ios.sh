#!/bin/bash
ADT_PATH=~/Developer/flash/flex/sdks/4.14.1/bin/adt
SIMULATOR_SDK_PATH=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.0.sdk
CERT_PATH=PATH_TO_CERTIFICATE
CERT_PASS=CERTIFICATE_PASSWORD
PROVISIONING_PATH=MOBILE_PROVISION_FILE

source ../../../air.conf

echo "packaging..."

$ADT_PATH -package -target ipa-test-interpreter -provisioning-profile $PROVISIONING_PATH -storetype pkcs12 -keystore $CERT_PATH -storepass $CERT_PASS all-components all-components-app.xml all-components.swf Default-Landscape.png -C ../ _assets