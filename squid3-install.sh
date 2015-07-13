#!/bin/bash

# This script is created for study purposed. Any mishandle creating will not be responsible.
# Used by your own risk
echo "Created By SyedMokhtar # https://www.facebook.com/syed.mokhtardahari"

cd

a="`netstat -i | cut -d' ' -f1 | grep eth0`";
b="`netstat -i | cut -d' ' -f1 | grep venet0:0`";

if [ "$a" == "eth0" ]; then
  ip="`/sbin/ifconfig eth0 | awk -F':| +' '/inet addr/{print $4}'`";
elif [ "$b" == "venet0:0" ]; then
  ip="`/sbin/ifconfig venet0:0 | awk -F':| +' '/inet addr/{print $4}'`";
fi

echo "Pls give your squid name?"
read s

apt-get install sudo
sudo apt-get --yes --force-yes update
sudo apt-get --yes --force-yes install apache2-utils
sudo apt-get --yes --force-yes install squid3

rm /etc/squid3/squid.conf

cat > /etc/squid3/squid.conf <<END
acl ip1 myip $ip
tcp_outgoing_address $ip ip1

visible_hostname $s
http_port 56665
icp_port 3130
forwarded_for off
range_offset_limit -1
hierarchy_stoplist cgi-bin ?
coredump_dir /var/spool/squid3
cache_dir ufs /var/spool/squid3 16384 16 256
error_directory /usr/share/squid3/errors/templates/
no_cache deny all
acl manager proto cache_object
acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16
acl localhost src 127.0.0.1
acl SSL_ports port 443
acl Safe_ports port 80 # http
acl Safe_ports port 21 # ftp
acl Safe_ports port 443 # https
acl Safe_ports port 1025-65535 # unregistered ports
acl Safe_ports port 280 # http-mgmt
acl Safe_ports port 488 # gss-http
acl Safe_ports port 591 # filemaker
acl Safe_ports port 777 # multiling http
acl CONNECT method CONNECT
#IP access control
#acl control_ip dst 104.238.150.62-104.238.150.62/255.255.255.255 # Your IP client @ not this installed server IPs
#http_access allow control_ip # Change to "http_access allow all" for transparent purposed
icp_access deny all
htcp_access deny all
http_access allow localnet
http_access allow localhost
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access deny all
refresh_pattern ^ftp:        		1440    20%    10080
refresh_pattern ^gopher:    		1440    0%    1440
refresh_pattern -i (/cgi-bin/|\?) 	0    0%    0
refresh_pattern .        		0    20%    4320
# Request Headers Forcing

request_header_access Allow allow all
request_header_access Authorization allow all
request_header_access WWW-Authenticate allow all
request_header_access Proxy-Authorization allow all
request_header_access Proxy-Authenticate allow all
request_header_access Cache-Control allow all
request_header_access Content-Encoding allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Expires allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Last-Modified allow all
request_header_access Location allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Charset allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Content-Language allow all
request_header_access Mime-Version allow all
request_header_access Retry-After allow all
request_header_access Title allow all
request_header_access Connection allow all
request_header_access Proxy-Connection allow all
request_header_access User-Agent allow all
request_header_access Cookie allow all
request_header_access All deny all

# Response Headers Spoofing

reply_header_access Via deny all
reply_header_access X-Cache deny all
reply_header_access X-Cache-Lookup deny all

END

squid3 -z

#htpasswd -b -c /etc/squid3/squid_passwd $u $p
service squid3 restart
cd

clear

echo " "
echo "***************************************************"
echo "   Squid proxy server set up has been completed."
echo " "
echo "***************************************************"
cat /etc/squid3/squid.conf |grep ^http_port
echo " "
echo " "
service squid3 status
rm ./squid-install_without_pass.sh
