#
# munishmehta/petclinic-mysql
#
FROM munishmehta/maven3-tomcat7
MAINTAINER Munish Mehta <munish.mehta27@gmail.com>

WORKDIR /home/dandelion
COPY . .

# Build the sample application
# Deploy it to Tomcat

RUN mvn -DskipTests package 
RUN cp target/petclinic.war /usr/local/tomcat/webapps/
