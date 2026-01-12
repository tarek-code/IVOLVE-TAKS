FROM maven:3.9.6-eclipse-temurin-17
WORKDIR /tarek
COPY Docker-1/ .
RUN mvn clean package
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "target/demo-0.0.1-SNAPSHOT.jar"]
