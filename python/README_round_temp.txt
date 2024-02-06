#Change working directory
cd /volume1/downloads/evohome

#Make new directory
mkdir pip

#Download 'pip'
wget https://raw.githubusercontent.com/pypa/pip/master/contrib/get-pip.py

#Install 'pip'
python get-pip.py

#Install Evohome client
python /volume1/@appstore/domoticz/var/scripts/python/evohome/setup.py install
