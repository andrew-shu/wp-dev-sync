## Bash script for deploying database from production to dev

### Description
Simple import db from production to dev server.

### Usage
1. Download archive and unpack/or clone into dev root directory.
2. Make executable
````
sudo chmod +x dbimport.sh
````
3. Define `WP_HOME` and `WP_SITEURL` variables in dev `wp-config.php` file:
````
define( 'WP_HOME', 'https://dev.example.com' );
define( 'WP_SITEURL', 'https://dev.example.com' );
````
4. Run import script, when you start new task to get actual data:
````
sh ./dbimport.sh
````

You don't need to set any credentials, all data extracting from your dev/prod `wp-config.php` files.

### Notes
This script use `/var/www/html/wp-config.php` as production config and `/var/www/dev/wp-config.php` as development. If your structure is different, modify following lines with correct path to production `wp-config.php`:
````
PROD_DB_NAME=`cat ../html/wp-config.php | grep DB_NAME | cut -d \' -f 4`
PROD_DB_HOST=`cat ../html/wp-config.php | grep DB_HOST | cut -d \' -f 4`
PROD_DB_USER=`cat ../html/wp-config.php | grep DB_USER | cut -d \' -f 4`
PROD_DB_PASS=`cat ../html/wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`
````

