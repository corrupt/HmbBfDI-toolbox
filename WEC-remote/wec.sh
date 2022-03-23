#!/bin/bash

if [ -f /etc/profile.d/nvm.sh ]; then
	. /etc/profile.d/nvm.sh
fi

WORKDIR="${PWD}"
DOMAIN=""
COOKIESTXT=""
TITLE=""
PROFILEDIR="${WORKDIR}/chromium-profile"
FIRSTPARTY=(
)
MUSTVISIT=(
)
VISITPAGES="50"
FPPARMS=""
MVPARMS=""
NOW=`date +%F_%H:%M`


for m in ${MUSTVISIT[@]}; do
	MVPARMS+=" -l ${m}"
done

for d in ${FIRSTPARTY[@]}; do
	FPPARMS+=" -f ${d}"
done

# browser profile setup
if [ ! -d "${PROFILEDIR}" ]; then
	mkdir -p "${PROFILEDIR}"
fi

nvm use 15 || exit 1

~/git/website-evidence-collector/node_modules/puppeteer/.local-chromium/linux-*/chrome-linux/chrome \
	--user-data-dir="${PROFILEDIR}" \
	--no-first-run \
	--no-default-browser-check \
	--app=${DOMAIN} 
#	--kiosk \

echo "press any key to continue..."
read

set -x

#website-evidence-collector \
node ~/git/website-evidence-collector/website-evidence-collector.js \
	"${DOMAIN}" \
	--quiet \
	--html \
	--overwrite \
	--browser-profile="${PROFILEDIR}" \
	${COOKIESTXT} \
	${FPPARMS} \
	${MVPARMS} \
	-t "${TITLE}" \
	-m ${VISITPAGES} \
	--headless=false \
	-- \
	--no-sandbox \
	> "${TITLE}-${NOW}.html"

mv output "output-${TITLE}-${NOW}"
