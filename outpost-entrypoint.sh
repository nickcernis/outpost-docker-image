#!/bin/bash
# Override default WordPress entrypoint
# Muting idea from https://github.com/docker-library/wordpress/issues/130#issuecomment-272198161

# mute CMD from official WordPress image
sed -i -e 's/^exec "$@"/#exec "$@"/g' /usr/local/bin/docker-entrypoint.sh

# execute bash script from official WordPress image
source /usr/local/bin/docker-entrypoint.sh

# Set up WordPress if required
if ! $(wp core is-installed); then
    wp core install --url=http://local.outpost.rocks --title=Outpost --admin_user=outpost --admin_password=outpost --admin_email=changeme@example.com
    wp rewrite structure "/%postname%/"
    wp plugin delete hello-dolly
fi

# execute CMD
exec "$@"
