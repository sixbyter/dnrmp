DNRMP
===

其实就是 docker + nginx + redis + mysql + php 的一个本地开发环境....

## 安装
使用之前必须安装docker 和 docker-compose 请查阅docker官方文档
如果你发现安装docker-compose网络非常慢,可以使用这个资源地址

```
curl -L http://138.128.192.63/docker-compose > /usr/local/bin/docker-compose
```

## 使用
```
cd /path/to/run
docker-compose up -d
```
设置 hosts
```
# x.xx.x.x 是你运行docker环境的ip地址,比如我用boot2docker 的ip地址是 192.168.59.103
x.xx.x.x    webapp-php.local.com
```
然后访问 `http://webapp-php.local.com` 就能看的phpinfo()的信息.

## 详细
```
# nginx 使用的镜像是 jwilder/nginx-proxy, 所有的配置文件都暴露了出来,重新编写了镜像的nginx.tmpl文件
nginx-proxy:
    image: 'jwilder/nginx-proxy'
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /path/to/run/nginx-proxy/nginx.conf:/etc/nginx/nginx.conf
      - /path/to/run/nginx-proxy/vhost.d:/etc/nginx/vhost.d:ro
      - /path/to/run/nginx-proxy/certs:/etc/nginx/certs
      - /path/to/run/nginx-proxy/nginx.tmpl:/app/nginx.tmpl
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - /path/to/run//www:/var/www/html:rw

# php 使用的镜像是我家的 sixbyte/fpm56:0.1 , 大部分的配置文件都暴露出来
php:
    image: 'sixbyte/fpm56:0.1'
    links:
      - "mysql-base:mysqldocker"
      - "redis-base:redisdocker"
    volumes:
      - /path/to/run//www:/var/www/html:rw
      - /path/to/run/php5.6/php-fpm.conf:/usr/local/etc/php-fpm.conf
      - /path/to/run/php5.6/php.ini:/usr/local/etc/php/php.ini:ro
    environment:
      - VIRTUAL_HOST=webapp-php.local.com,*.local.com
      - VIRTUAL_PORT=9000

# 目前流行的laravel框架 使用的镜像是我家的 sixbyte/laravel5:0.1 大部分的配置文件都暴露出来
laravel:
    image: 'sixbyte/laravel5:0.1'
    links:
      - "mysql-base:mysqldocker"
      - "redis-base:redisdocker"
    volumes:
      - /path/to/run//www:/var/www/html:rw
      - /path/to/run/laravel5.1/php-fpm.conf:/usr/local/etc/php-fpm.conf
      - /path/to/run/laravel5.1/php.ini:/usr/local/etc/php/php.ini:ro
    environment:
      - VIRTUAL_HOST=laravel5.laravel.com,*.laravel.com
      - VIRTUAL_PORT=9000

# mysql 使用的是 mysql:5.7 账号 root 密码 root
mysql-base:
    image: 'mysql:5.7'
    environment:
      - MYSQL_ROOT_PASSWORD=root

# redis 使用的是 redis:3.0.3
redis-base:
    image: 'redis:3.0.3'

# 你可以不断的外接服务,比如beanstalkd,mongodb 等,非常的方便
```