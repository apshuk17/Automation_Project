This Automation Project contains a script that is responsible for

1. Check the install status of apache2
2. If not, will install the apache2 package.
3. If it's already installed then it will check the apache2 running status.
4. If apache 2 is not running then it will start the apache2.
5. It will also check the enabled status of apache2 and if it's not then it will enable the apache2 service.


This script will also tar the log files of apache2 stored in /var/tmp/apache2 and copy the tarred version to amazon s3 bucket.
