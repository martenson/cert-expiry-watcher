#!/bin/bash
CURRENT_TIME=$(date "+%s")
WARNING_TIME=$(echo "$CURRENT_TIME + (60 * 60 * 24 * 90)" | bc)
printf "<testsuite tests=\"%s\">" $(wc -l sites.txt | sed 's/ .*//g')
for fqdn in `cat sites.txt`; do
	notAfter=$(openssl s_client -showcerts -connect $fqdn:443 < /dev/null 2> /dev/null | openssl x509 -noout -enddate | sed 's/notAfter=//g')
	notAfterZ=$(date --date="$notAfter" "+%s")

	if [ "$notAfterZ" -lt "$WARNING_TIME" ]; then
		printf "<testcase classname=\"%s\" name=\"ExpiryTest\">" $fqdn
		printf "<failure type=\"FailingSoon\">Certificate for %s will expire on %s %s %s %s %s</failure>" $fqdn $notAfter
		printf "</testcase>"
	else
		printf "<testcase classname=\"%s\" name=\"ExpiryTest\"/>" $fqdn
	fi
done

printf "</testsuite>"
