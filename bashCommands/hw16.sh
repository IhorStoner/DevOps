#!/bin/bash
Q="$@"
URL='https://www.google.com/search?tbs=li:1&q='
AGENT="Mozilla/4.0"
#stream="https://www.google.com/intl/en_us/policies/privacy/ https://www.google.com/intl/en_us/policies/privacy/"
stream="$(curl -A "$AGENT" -skLm 10 "${URL}${Q//\ /+}" | grep -oP '\/url\?q=.+?&amp' | sed 's|/url?q=||; s|&amp||')"


echo -e "${stream//\%/\x}"
