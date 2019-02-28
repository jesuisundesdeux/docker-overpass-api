FROM ubuntu:18.04

MAINTAINER Bruno Adele <brunoadele@gmail.com>

# Installation documentation
# https://wiki.openstreetmap.org/wiki/Overpass_API/Installation

# Build deps
RUN apt-get update \
    && apt-get install -y g++ make expat libexpat1-dev zlib1g-dev 
    
# Build required packages
RUN apt-get install -y wget supervisor apache2 

# Only used in build session
ARG DEBIAN_FRONTEND=noninteractive
ARG OVERPASS_VERSION=0.7.55

# Used on all docker session
ENV DB_DIR=/data/db 
ENV OSM3_DIR=/opt/osm3
ENV FLUSH_SIZE=2
ENV PLANET_FILE=""
ENV PLANET_URL="https://download.geofabrik.de/europe/france/languedoc-roussillon-latest.osm.bz2"
    
# Donwload & compile overpass
RUN wget -O /usr/local/src/osm-3s_v${OVERPASS_VERSION}.tar.gz http://dev.overpass-api.de/releases/osm-3s_v${OVERPASS_VERSION}.tar.gz \
    && tar -zxvf /usr/local/src/osm-3s_v${OVERPASS_VERSION}.tar.gz -C /usr/local/src/ && rm /usr/local/src/osm-3s_v${OVERPASS_VERSION}.tar.gz
RUN cd /usr/local/src/osm-3s_v* && ./configure CXXFLAGS="-O2" --prefix=${OSM3_DIR} && make install && make clean

# Configure Supervisor
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure Apache
COPY conf/apache.conf  /etc/apache2/sites-available/000-default.conf
RUN a2enmod cgi && a2enmod ext_filter

COPY entrypoint.sh /bin
RUN chmod 755 /bin/entrypoint.sh

# Clean
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

VOLUME [ "/data" ]

ENTRYPOINT [ "/bin/entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]