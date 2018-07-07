#!/bin/bash

if [ $# -ne 3 ] ; then
    echo "Usage: $0 SLACK_GROUP|@SLACK_USER SUBJECT MESSAGE"
    exit 1
fi

urlencode() {
    # urlencode <string>
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c"
        esac
    done
}

# jenkins token
TOKEN="xoxp-4702843418-1926338295..."
CHANNEL="$1"
USERNAME="Zabbix"
ICON="%3Azabbix2%3A"
FILE="$(tempfile)"

case $2 in
    PROBLEM* )
        TEXT=":exclamation: *${2}* ${3}"
        ;;
    OK* )
        TEXT=":heavy_check_mark: *${2}* ${3}"
        ;;
    * )
        TEXT="*${2}* ${3}"
        ;;
esac

TEXT=$(echo $TEXT | sed -r 's/\\n/\n/g')
TEXT=$(urlencode "$TEXT")
CHANNEL=$(urlencode "$CHANNEL")

curl -s "https://slack.com/api/chat.postMessage?token=${TOKEN}&channel=${CHANNEL}&text=${TEXT}&pretty=1&username=${USERNAME}&icon_emoji=${ICON}" > $FILE

if [[ "$(jq -r '.ok' $FILE)" == "true" ]]; then
    rm -f $FILE
    exit 0
else
    jq -r '.error' $FILE >&2
    rm -f $FILE
    exit 1
fi
