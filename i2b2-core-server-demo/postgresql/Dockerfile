FROM quay.io/wildfly/wildfly:37.0.1.Final-jdk21

LABEL maintainer="Kevin Bui"

ARG TEST_CASE_NUMBER

RUN curl -s -L -o /opt/jboss/wildfly/standalone/deployments/i2b2.war https://i2b2-demo.s3.us-east-1.amazonaws.com/i2b2-core-server-demo/postgresql/v1.8.3/i2b2-ontstore.war
COPY resources/opt/wildfly-37.0.1.Final/standalone/test_case/ontstore-ds.xml.${TEST_CASE_NUMBER} /opt/jboss/wildfly/standalone/deployments/ontstore-ds.xml
COPY resources/opt/wildfly-37.0.1.Final/standalone/deployments/ /opt/jboss/wildfly/standalone/deployments/
COPY resources/opt/wildfly-37.0.1.Final/standalone/configuration/standalone.xml /opt/jboss/wildfly/standalone/configuration/
