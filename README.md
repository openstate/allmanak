# Install

```bash
docker-compose up -d
```
This works with our internally used [nginx-load-balancer](https://github.com/openstate/nginx-load-balancer), by defining the proper networks in (with `docker-compose.override.yml`).

`docker-compose-jwildernginx-production.yml` is provided to work with [nginx-proxy](https://github.com/jwilder/nginx-proxy) by [Jason Wilder aka jwilder](https://github.com/jwilder):

```bash
docker-compose -f docker-compose.yml -f docker-compose-jwildernginx-production.yml up -d
```

## Email

Check email: http://localhost/mail/

## Static logos / images

Are scraped via [logo-finder](https://github.com/openstate/logo-finder).

E.g.
```bash
curl 'https://rest-api.allmanak.nl/v0/overheidsorganisatie?einddatum=is.null&select=systemid,website:contact->internet' \
| jq 'map(.systemid as $id | [.website?]|flatten|map({key:(.value? // .), value: $id})[0])|group_by(.key)|map({url:.[0].key,systemids:map(.value)})|map(select(.url!=null))' \
| yarn -s scrape > output.json
```
After which some cleaning has to be done for results that include multiple logo's.

# Upgrades

`v0` to `v1`:
```bash
docker-compose exec db psql -U postgres allmanak -f /upgrade/new-ootype-values.pg.sql
docker-compose exec db psql -U postgres allmanak --set ON_ERROR_STOP=on -f /upgrade/v0-to-v1.pg.sql
docker-compose restart api-rest-v0
docker-compose restart api-rest-v1
```

# Development

```bash
docker-compose -f docker-compose.yml -f docker-compose-dev.yml up -d
```
And go to http://localhost/ (auto reloaded with new builds).

Some services (v0, import & static build) are disabled in development mode for resource/performance reasons.
To run them individually:
```bash
# V0
docker-compose -f docker-compose.yml -f docker-compose-dev.yml run -d --no-deps --use-aliases --name allmanak_api-rest-v0_manual api-rest-v0 /bin/sh -c "exec postgrest /etc/postgrest.conf"
# import data, see https://almanak.overheid.nl/archive/ for valid file name options, by default exportOO.xml is used
docker-compose -f docker-compose.yml run --rm --no-deps --use-aliases import-cron importdata.sh [manual [exportOO.xml|YYYYMMDD.xml]]
# build static
docker-compose -f docker-compose.yml run --rm --no-deps --use-aliases build-static yarn export+process
```

See build issues
```bash
docker-compose logs -f app
```

To login to the database
```bash
docker-compose exec db psql -U postgres allmanak
```

Note that all tables and views are scoped in schema's: `almanak`, `enrich`, `kiesraad` and `api_vX`.
Some usefull psql commands:
`\dn` list all schema's
`\dt [pattern]` list all tables
`\dv [pattern]` list all views
`\d [pattern]` describes a specific view/table.
E.g.:
```sql
\dn
\dt almanak.*
\dt kiesraad.*
\dv api_v1.*
\d api_v0.overheidsorganisatie
```

## Custom PostgREST in `v1`

We have made some custimized docker image for PostgREST based on the 6.0.0 master:
```bash
# Custom build PostgREST
git clone https://github.com/openstate/postgrest.git
cd postgrest
git checkout enum-arrays
docker build -f docker/distro_release/Dockerfile.ubuntu -t postgrest_builder .
# note the ~/.stack folder will become about 3.5G in size, after quite some compiling
# $(pwd)/.stack-work will be about 163MB, the binary will be 45MB and the docker tar 112MB
docker run --rm -it -v $HOME/.stack:/root/.stack -v $(pwd):/source -v $(pwd)/docker/dist/:/root/.local/bin/ postgrest_builder build --allow-different-user --install-ghc --copy-bins

# Instead of download postgREST, use the binary just build
sed -z -r 's/\nARG POSTGREST_VERSION\n//;s@\nRUN BUILD_DEPS([^\n]*|\n[^\n]+)*@\nCOPY dist/postgrest /usr/local/bin/postgrest@g' docker/Dockerfile | docker build -f - -t postgrest:v6.0.0-enum-arrays docker

# Export docker image to tar (since building takes some time + space, you might not want to do this on your production server)
docker save postgrest:v6.0.0-enum-arrays -o postgrest_v6.0.0-enum-arrays.tar
# scp the tar to your production server and load the binary
docker load -i postgrest_v6.0.0-enum-arrays.tar
```