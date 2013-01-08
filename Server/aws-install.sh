sudo -s
sudo yum install python27
cd tornado-2.3/
sudo python27 setup.py install
cd ..
git clone git://github.com/bitly/asyncmongo.git
cd asyncmongo/
python27 setup.py install
cd ..
wget http://pypi.python.org/packages/source/p/pymongo/pymongo-2.4.1.tar.gz#md5=be358dece09bc57561573db35bc75eb0
tar -zxvf pymongo-2.4.1.tar.gz
cd pymongo-2.4.1
python27 setup.py install
cd ..
yum install memcached
echo configure memcached ...
vim /etc/sysconfig/memcached

