#/bin/sh
docker run \
    -v $PWD/nginx.conf:/etc/nginx/nginx.conf \
    -v $PWD/www/:/var/www/ \
    -p 1935:1935 \
    -p 80:80 \
    --rm \
    nginx-rmtp /usr/sbin/nginx
