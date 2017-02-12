# WordPress, WP-CLI, and wp-config.php configuration for Outpost
# http://outpost.rocks
# Docker Hub: https://hub.docker.com/r/nickc/outpost/
# Github Repo: https://github.com/nickcernis/outpost-docker-image

FROM wordpress:php7.1-apache

# Add WP-CLI
# (Recipe from https://github.com/conetix/docker-wordpress-wp-cli )
# Add sudo in order to run wp-cli as the www-data user
RUN apt-get update && apt-get install -y sudo less

RUN curl -o /bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
COPY wp-su.sh /bin/wp
RUN chmod +x /bin/wp-cli.phar /bin/wp

# Modify wp-config with default URL: local.outpost.rocks
RUN sed -i -e "/DB_COLLATE/a define( 'WP_HOME', 'http://local.outpost.rocks/' );\ndefine( 'WP_SITEURL', 'http://local.outpost.rocks/' );" /usr/src/wordpress/wp-config-sample.php

# Enable debugging
RUN sed -i -e "s/WP_DEBUG', false/WP_DEBUG', true/" -e "/WP_DEBUG/a define('WP_DEBUG_LOG', true);\ndefine( 'SAVEQUERIES', true );\ndefine( 'JETPACK_DEV_DEBUG', true);" /usr/src/wordpress/wp-config-sample.php

# Increase memory and upload limits
RUN printf "upload_max_filesize = 64M\npost_max_size = 64M" > /usr/local/etc/php/conf.d/uploads.ini
RUN printf "memory_limit = 256M" > /usr/local/etc/php/conf.d/memory.ini

# Add an info.php to the WordPress root directory
COPY info.php /usr/src/wordpress/

# Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY outpost-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/outpost-entrypoint.sh

ENTRYPOINT ["outpost-entrypoint.sh"]
CMD ["apache2-foreground"]
