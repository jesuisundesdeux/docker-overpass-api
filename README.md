# docker-overpass-api
A overpass API docker container

## Build
```
docker build -t docker-overpass-api .
```

## Run
```
docker run --rm -it \
    -e PLANET_URL="https://download.geofabrik.de/europe/france/languedoc-roussillon-latest.osm.bz2" \
    -e FLUSH_SIZE=4 \
    -p 80:80 -v $(pwd)/data:/data docker-overpass-api

# You can replace PLANET_URL by PLANET_FILE="languedoc-roussillon-latest.osm.bz2" (for use allready downloader local planet file)
# Choose a PLANET_URL from this website => http://download.geofabrik.de/
```

## Estimation import time
* [France](https://download.geofabrik.de/europe/france-latest.osm.bz2) => 230min(3h50)
* [Occitanie](https://download.geofabrik.de/europe/france/languedoc-roussillon-latest.osm.bz2) => 8m30
* [Monaco](https://download.geofabrik.de/europe/monaco-latest.osm.bz2) => 50s

## Run with Overpass Turbo UI

In the parameter option from http://overpass-turbo.eu/ change API server address to http://localhost/api/