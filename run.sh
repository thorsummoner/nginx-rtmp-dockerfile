docker run -v $PWD/nginx.conf:/etc/nginx/nginx.conf -p 1935:1935 -p 8000:8000 --rm nginx-rmtp /usr/sbin/nginx
