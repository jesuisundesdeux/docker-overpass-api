#!/bin/bash

data="/data"
db="${data}/db"
planet="${data}/planet.osm.bz2"
imported_successful="${db}/imported_successful"
nodemap="${db}/nodes.map"

# Remove oldest sockets
declare -a sockets=("${db}/osm3s_v0.7.55_osm_base" "${db}/osm3s_v0.7.55_areas")
for socket in ${sockets[@]}; do 
    if [ -e $socket ]; then
        echo "Remove $socket socket file"
        rm $socket 
    fi
done

# If not allready imported
if [ ! -e "$imported_successful" ]; then
    if [ "${data}/${PLANET_FILE}" != "" ]; then
        # Try copy local planet file
        if [ -e "${data}/${PLANET_FILE}" ]; then
            cp "${data}/${PLANET_FILE}" $planet
        else
            echo "planet file ${data}/${PLANET_FILE} not found"
        fi
    else
        # Try download planet file
        if [ ! -e "$planet" -a "${PLANET_URL}" != "" ]; then
            echo "Downloading the ${PLANET_URL} file" 
            wget -O $planet ${PLANET_URL}
        fi
    fi

    # Import planet
    if [ -e "$planet" ]; then
        echo "Remove oldest Db database"
        rm -rf $db

        echo "Copy rules"
        mkdir -p ${db}
        cp -r /usr/local/src/osm-3s_v*/rules ${db}/

        echo "Import planet.osm.bz2 into Db with --flush-size=${FLUSH_SIZE} option"
        time ${OSM3_DIR}/bin/init_osm3s.sh $planet ${DB_DIR} ${OSM3_DIR} --flush-size=${FLUSH_SIZE} && touch $imported_successful
    fi
fi

# Show imported Db status
if [ ! -e "$imported_successful" ]; then
    echo "[ERROR] it seem not $planet imported sucessfully "
    
    if [ ! -e "$nodemap" ]; then
        echo "[ERROR] it seem not sucessfully imported $nodemap not exist"
    fi
else
    ls -lh "$nodemap"
fi

# Launch CMD
exec "$@"