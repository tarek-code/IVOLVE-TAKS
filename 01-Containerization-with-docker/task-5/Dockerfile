FROM maven:3.9.12-eclipse-temurin-17-alpine AS build
WORKDIR /lab-5
COPY Docker-1/ .
RUN mvn clean package
FROM eclipse-temurin:17-jre-alpine
COPY --from=build lab-5/target/demo-0.0.1-SNAPSHOT.jar .
EXPOSE 8080
ENTRYPOINT ["java","-jar","demo-0.0.1-SNAPSHOT.jar"]
