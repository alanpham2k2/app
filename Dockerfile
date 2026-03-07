FROM eclipse-temurin:17-jdk-jammy as builder

WORKDIR /app

# Ensure version locking
COPY .mvn/ .mvn

COPY mvnw pom.xml ./

RUN chmod +x mvnw

# Download all dependencies offline (will be cached unless pom.xml changes)
RUN ./mvnw dependency:go-offline

COPY src ./src

# Remove target files, compile & package into JAR file, skip test for speed
RUN ./mvnw clean package -DskipTests

FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Create a system user & group for security
RUN groupadd -r spring && useradd -r -g spring -s /bin/false spring

USER spring:spring

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 9966

ENTRYPOINT ["java", "-jar", "app.jar"]
