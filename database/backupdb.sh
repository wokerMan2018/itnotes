#!/bin/sh
mysqldump -unextcloud -pnextcloud@pi nextcloud|gzip > /home/levin/db/nextcloud+%Y-%m-%d.sql.gz
cd /home/levin/db
rm -rf `find . -name '*.sql.gz' -mtime 7`
cp * /mnt/disk/nextcloud/db/
rm -rf `find /mnt/disk/nextcloud/db -name '*.sql.gz' -mtime 7`
