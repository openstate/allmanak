FROM node:12.22.0-alpine
LABEL maintainer="Open State Foundation <developers@openstate.eu>" \
	  version="0.2.2" \
      description="Docker that fetches https://almanak.overheid.nl/archive/exportOO.xml converts it to JSON, does some processing and imports it to PostgreSQL."
RUN apk add --no-cache \
	curl \
	jq \
	libxml2-utils \
	libxslt \
	postgresql-client \
&& yarn global add eslint \
&& mkdir -p work \
&& echo -e \
"@reboot /usr/local/bin/importdata.sh reboot\n" \
"05 01,09-22 * * * /usr/local/bin/importdata.sh cron" > /etc/crontabs/root
# See https://crontab.guru/#05_01,09-22_*_*_*
#  this is based on the fact that since 2018 97+% is <= 21:03 UTCm the last 3% is updated at 21:34, 00-01 and 08-16.
COPY ./importdata.sh /usr/local/bin/importdata.sh
#COPY ./oo-export.xsd /work
#COPY ./autojson.xslt /work
#COPY ./flatten-structure.jq /work
#COPY ./clone-schema.pg.sql /work
#COPY ./update.pg.sql /work
#COPY ./create-search-index.jq /work
WORKDIR /work
CMD ["crond", "-f"]
