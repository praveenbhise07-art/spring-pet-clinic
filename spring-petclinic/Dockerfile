FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy the pre-built jar from the target folder
COPY target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]