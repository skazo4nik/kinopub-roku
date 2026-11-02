#!/bin/sh
# Использование: ./deploy.sh <IP Roku> <пароль разработчика>
set -e
cd "$(dirname "$0")"
rm -f kinopub.zip
zip -qr kinopub.zip manifest source components images
curl --digest -u "rokudev:$2" -F mysubmit=Install -F "archive=@kinopub.zip" "http://$1/plugin_install"
