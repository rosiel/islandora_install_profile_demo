#!/usr/bin/with-contenv bash
# Install Drupal
drush si -y --account-name=admin --account-pass="${DRUPAL_DEFAULT_ACCOUNT_PASSWORD}"
# Add admin role to admin
drush user-add-role "administrator" admin
drush en search_api_solr_defaults -y
# Run support utilities
source /etc/islandora/utilities.sh
chmod +x /etc/islandora/site_init.sh && source /etc/islandora/site_init.sh  && for_all_sites provision_site
