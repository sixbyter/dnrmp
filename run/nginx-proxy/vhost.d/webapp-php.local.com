server {
        listen 80;

        index index.html index.htm index.php;
        server_name webapp-php.local.com;
        root    /var/www/html;

        access_log /var/log/nginx/webapp-php.com-access.log;
        error_log  /var/log/nginx/webapp-php.com-error.log;
        charset utf-8;

        location / {
            try_files $uri $uri/ /index.html /index.php?$query_string;
        }
        location = /favicon.ico { log_not_found off; access_log off; }
        location = /robots.txt  { access_log off; log_not_found off; }
        error_page 404 /index.php;

        location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass webapp-php.local.com;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_index index.php;
            include fastcgi_params;
            #fastcgi_param LARA_ENV local; # Environment variable for laravel
            #fastcgi_param HTTPS off;
        }

        # Deny .htaccess file access
        location ~ /\.ht {
            deny all;
        }
}
