#!/bin/bash
#set -x

# variabels 
# Files shared via azure netintunemac 
varpkg='https://netintunemac.z1.web.core.windows.net/ESjm-bSBY-zmVp-84NM-jh3S/Cortex%20XDR.pkg'
vartmppkg="/tmp/Cortex XDR.pkg"
varconf="https://netintunemac.z1.web.core.windows.net/ESjm-bSBY-zmVp-84NM-jh3S/Config.xml"
vartmpxml="/tmp/Config.xml"


# Detects if picture is present. 
if [[ -d '$HOME/Library/Containers/com.microsoft.teams2/Data/Library/Application Support/Microsoft/MSTeams/Backgrounds/Uploads/137B81D5-BF1D-463B-94EA-B06B1EF96F4A.png' ]]; then

echo off
rm "$vartmppkg" 
rm "$vartmpxml" 


exit 0

fi



curl "$varpkg" -s -L -I -o /dev/null -w '%{url_effective}' > /tmp/varpkg.txt
varpkga="$(< "/tmp/varpkg.txt")"
echo $vartest
curl -o "$vartmppkg" "$varpkga"

curl "$varconf" -s -L -I -o /dev/null -w '%{url_effective}' > /tmp/varconf.txt
varconfa="$(< "/tmp/varconf.txt")"
#echo $vartest
curl -o "$vartmpxml" "$varconfa"

sudo installer -pkg '/tmp/Cortex XDR.pkg' -target /Applications



exit 0