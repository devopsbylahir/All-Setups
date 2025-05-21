# Install Java 17 Amazon Corretto
sudo yum install java-17-amazon-corretto -y

# Set version variable
TOMCAT_VERSION=9.0.79

# Download Tomcat from Apache archive (more reliable)
wget https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Extract
tar -zxvf apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Backup tomcat-users.xml before editing
cp apache-tomcat-${TOMCAT_VERSION}/conf/tomcat-users.xml apache-tomcat-${TOMCAT_VERSION}/conf/tomcat-users.xml.bak

# Add roles and user safely by inserting before closing </tomcat-users>
sed -i '/<\/tomcat-users>/i \
  <role rolename="manager-gui"/>\n\
  <role rolename="manager-script"/>\n\
  <user username="tomcat" password="raham123" roles="manager-gui,manager-script"/>' apache-tomcat-${TOMCAT_VERSION}/conf/tomcat-users.xml

# Backup context.xml before editing
cp apache-tomcat-${TOMCAT_VERSION}/webapps/manager/META-INF/context.xml apache-tomcat-${TOMCAT_VERSION}/webapps/manager/META-INF/context.xml.bak

# Comment out the Context element so remote access is allowed for manager app
sed -i 's|<Context.*>|<!-- & -->|' apache-tomcat-${TOMCAT_VERSION}/webapps/manager/META-INF/context.xml

# Start Tomcat
sh apache-tomcat-${TOMCAT_VERSION}/bin/startup.sh
