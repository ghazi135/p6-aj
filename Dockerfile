# syntax=docker/dockerfile:1

# ================================
# Stage 1: Build with Gradle
# ================================
FROM eclipse-temurin:21-jdk AS build

WORKDIR /app

# Copy Gradle wrapper and build files
COPY gradlew gradlew
COPY gradle gradle
COPY build.gradle settings.gradle ./

# Download dependencies with cache mount (persists between builds)
RUN --mount=type=cache,target=/root/.gradle \
    chmod +x gradlew && ./gradlew dependencies --no-daemon

# Copy source code and build
COPY src src
RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew bootJar --no-daemon -x test

# ================================
# Stage 2: Runtime with JRE only
# ================================
FROM eclipse-temurin:21-jre

WORKDIR /app

# Copy the built Spring Boot fat jar from build stage
COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
