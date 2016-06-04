FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

EXPOSE 1935
EXPOSE 80

# PPAs
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:mc3man/trusty-media

# System Update
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get clean

# build essential
RUN apt-get install -y build-essential
RUN apt-get install -y wget

# ffmpeg
RUN apt-get install -y ffmpeg

ENV NGINX_VERSION=1.4.6
ENV NGINX_RTMP_VERSION=1.1.6

# nginx dependencies
# RUN apt-get install -y libpcre3-dev zlib1g-dev libssl-dev
RUN apt-get build-dep -y nginx/$NGINX_VERSION
RUN apt-get install -y nginx-common
WORKDIR /usr/src
RUN apt-get source -y nginx/$NGINX_VERSION

# # get nginx-rtmp module
RUN wget -qO- https://github.com/arut/nginx-rtmp-module/archive/v$NGINX_RTMP_VERSION.tar.gz | tar xz

WORKDIR /usr/src/nginx-$NGINX_VERSION
# # compile nginx
RUN ./configure \
 --with-cc-opt="-g -O2 -fPIE -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2" \
 --with-ld-opt="-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-z,relro -Wl,-z,now" \
 --sbin-path=/usr/sbin/nginx \
 --prefix=/usr/share/nginx \
 --conf-path=/etc/nginx/nginx.conf \
 --http-log-path=/var/log/nginx/access.log \
 --error-log-path=/var/log/nginx/error.log \
 --lock-path=/var/lock/nginx.lock \
 --pid-path=/run/nginx.pid \
 --http-client-body-temp-path=/var/lib/nginx/body \
 --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
 --http-proxy-temp-path=/var/lib/nginx/proxy \
 --http-scgi-temp-path=/var/lib/nginx/scgi \
 --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
 --with-debug \
 --with-pcre-jit \
 --with-ipv6 \
 --with-http_ssl_module \
 --with-http_stub_status_module \
 --with-http_realip_module \
 --with-http_gzip_static_module \
 --without-http_browser_module \
 --without-http_geo_module \
 --without-http_limit_req_module \
 --without-http_limit_zone_module \
 --without-http_memcached_module \
 --without-http_referer_module \
 --without-http_scgi_module \
 --without-http_split_clients_module \
 --without-http_userid_module \
 --without-http_uwsgi_module \
 --add-module=/usr/src/nginx-rtmp-module-$NGINX_RTMP_VERSION

RUN make
RUN make install

ADD nginx.conf /etc/nginx/nginx.conf
ADD static /static

CMD "nginx"
