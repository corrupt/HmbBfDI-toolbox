#!/bin/bash

#shellcheck disable=SC1091
#shellcheck disable=SC2211

if [ -f /etc/profile.d/nvm.sh ]; then
	. /etc/profile.d/nvm.sh
fi

WORKDIR="${PWD}"
NOW=$(date +%F_%H:%M)
DOMAIN=""
COOKIESTXT=""
TITLE=""
PROFILEDIR="${WORKDIR}/chromium-profile-${NOW}-${TITLE}"
FIRSTPARTY=(
)
MUSTVISIT=(
)
VISITPAGES="50"


for m in "${!MUSTVISIT[@]}"; do
	MUSTVISIT[$m]="-l ${MUSTVISIT[$m]}"
done

for d in "${!FIRSTPARTY[@]}"; do
	FIRSTPARTY[$d]="-f ${FIRSTPARTY[$d]}"
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
	--no-sandbox \
	"${DOMAIN}" 
#	--app="${DOMAIN}" 
#	--kiosk \

echo "press any key to continue..."
read -r

set -x

#website-evidence-collector \
node ~/git/website-evidence-collector/bin/website-evidence-collector.js \
	"${DOMAIN}" \
	--html \
	--overwrite \
	--browser-profile="${PROFILEDIR}" \
	"${COOKIESTXT}" \
	"${FIRSTPARTY[@]}" \
	"${MUSTVISIT[@]}" \
	-t "${TITLE}" \
	-m ${VISITPAGES} \
	--headless=false \
	-- \
	--no-sandbox \
	> "${TITLE}-${NOW}.html"

mv output "output-${TITLE}-${NOW}"
