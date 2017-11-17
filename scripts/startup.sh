
#!/bin/bash

# /home/vcap/deps/0/node/bin/node
set -x

export http_proxy="http://thd-svr-proxy-qa.homedepot.com:9090"
export https_proxy="http://thd-svr-proxy-qa.homedepot.com:9090"
home_dir=$PWD

#allow npm to access npm registry
npm config set proxy $http_proxy
npm config set https-proxy $https_proxy

echo "Begin GCC install"
apt-get install gcc-6
echo "Installation complete"

#Uninstall previous versions of node-gyp and perform Cache Cleanup
cd /home/vcap/deps/0/node/lib/node_modules/npm/node_modules
npm uninstall  node-gyp
npm cache clean -f
npm install -g node-gyp
cd $home_dir
cp -R /home/vcap/deps/0/node/lib/node_modules/node-gyp /home/vcap/deps/0/node/lib/node_modules/npm/node_modules/

#Install Java
cd /home/vcap/app/
mkdir /home/vcap/app/java
cd /home/vcap/app/java
wget -nv --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz"
echo 'Copied the package'
tar -zxf jdk-8u131-linux-x64.tar.gz
cd jdk1.8.0_131/ 
update-alternatives --install /usr/bin/java java /home/vcap/app/java/jdk1.8.0_131/bin/java 100
update-alternatives --config java
update-alternatives --install /usr/bin/javac javac /home/vcap/app/java/jdk1.8.0_131/bin/javac 100
update-alternatives --config javac
update-alternatives --install /usr/bin/jar jar /home/vcap/app/java/jdk1.8.0_131/bin/jar 100
update-alternatives --config jar

export JAVA_HOME=/home/vcap/app/java/jdk1.8.0_131/
export PATH=$PATH:/home/vcap/app/java/jdk1.8.0_131/bin

java -version
echo "Java Installed Successfully"

cd $home_dir
unzip instantclient.zip
unzip instantclient_sdk.zip
cd instantclient
ln -s libclntsh.so.12.1 libclntsh.so
cd ..

export LD_LIBRARY_PATH=$home_dir/instantclient
echo $home_dir
export OCI_LIB_DIR=$home_dir/instantclient
export OCI_INC_DIR=$home_dir/instantclient/sdk/include

npm install oracledb

node server.js