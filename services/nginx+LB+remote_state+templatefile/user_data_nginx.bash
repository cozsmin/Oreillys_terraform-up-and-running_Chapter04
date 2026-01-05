#!/bin/bash

export aucarraccia="ACUCARRACCIA-internally"

printf "\n\n`date` :\n\n" >> /tmp/user_data
at=1
while [ $at -lt 1000 ] ; do
  /usr/bin/sudo  /usr/bin/bash -c "/usr/bin/apt -o Acquire::http::Timeout=\"600\" update && /usr/bin/sudo /usr/bin/apt install -y nginx dmidecode" >> /tmp/user_data 2>&1
  if [ $? -eq 0 ] ; then break ; fi
done
/usr/bin/sudo  /usr/bin/bash -c "/usr/bin/printf \"`hostname` [${vpc_name}] : `date` \n\n`dmidecode -t1`\n\n\" > /var/www/html/index.html " >> /tmp/user_data 2>&1
/usr/bin/sudo  /usr/bin/bash -c "/usr/bin/printf \"\n\nDB = ${db_address}:${db_port}\n\n\" >> /var/www/html/index.html" >> /tmp/user_data 2>&1

/usr/bin/sudo  /usr/bin/mkdir -p /var/www/html/acucaraccia/ >> /tmp/user_data 2>&1
/usr/bin/sudo  /usr/bin/bash -c "/usr/bin/printf \"ACUCARAAAACIIAAAAAAAAA\n\n\" > /var/www/html/acucaraccia/index.html " >> /tmp/user_data 2>&1
/usr/bin/sudo  /usr/bin/bash -c "/usr/bin/cat /var/www/html/index.html >> /var/www/html/acucaraccia/index.html " >> /tmp/user_data 2>&1
/usr/bin/sudo  /usr/bin/bash -c "/usr/bin/systemctl enable --now nginx" >> /tmp/user_data 2>&1
/usr/bin/sudo  /usr/bin/chown -R www-data:www-data /var/www >> /tmp/user_data 2>&1

/usr/bin/sudo  /usr/bin/bash -c "/usr/bin/printf \"aucarraccia=${aucarraccia}\" >> /var/www/html/index.html " >> /tmp/user_data 2>&1
/usr/bin/sudo  /usr/bin/bash -c "/usr/bin/printf \"aucarraccia=${aucarraccia}\" >> /var/www/html/acucaraccia/index.html " >> /tmp/user_data 2>&1

/usr/bin/sudo /usr/bin/sed 's/\n/&<br>/g' -z -i /var/www/html/index.html
/usr/bin/sudo /usr/bin/sed 's/\n/&<br>/g' -z -i /var/www/html/acucaraccia/index.html
printf "\n####################################\n\n" >> /tmp/user_data



