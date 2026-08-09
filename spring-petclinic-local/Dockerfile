FROM eclipse-temurin:21-jre
WORKDIR /app

# Copy the freshly compiled JAR from spring-petclinic-local/target/
COPY target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]