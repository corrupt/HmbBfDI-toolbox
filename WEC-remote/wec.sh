#!/bin/bash

WORKDIR="${PWD}"
DOMAIN=""
COOKIESTXT=""
TITLE=""
PROFILEDIR="${WORKDIR}/chromium-profile"
FIRSTPARTY=(
)
MUSTVISIT=(
)
VISITPAGES="15"
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

/usr/lib/node_modules/website-evidence-collector/node_modules/puppeteer/.local-chromium/linux-*/chrome-linux/chrome --user-data-dir="${PROFILEDIR}" ${DOMAIN}


set -x

website-evidence-collector \
	"${DOMAIN}" \
	--quiet \
	--html \
	--overwrite \
	--testssl \
	--browser-profile="${PROFILEDIR}" \
	${COOKIESTXT} \
	${FPPARMS} \
	${MVPARMS} \
	-t "${TITLE}" \
	-m ${VISITPAGES} \
	--headless=false \
	-F \
	-- \
	--no-sandbox \
	> "${TITLE}-${NOW}.html"

mv output "output-${TITLE}-${NOW}"
