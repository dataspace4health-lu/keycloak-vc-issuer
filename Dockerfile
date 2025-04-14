# Stage 1: Build the application
FROM maven:3.8.1 AS build
WORKDIR /app
COPY . .
RUN mvn -q clean package

# Stage 2: Create the final image
FROM quay.io/keycloak/keycloak:20.0.3
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin
#ENV KC_SPI_THEME_ADMIN_DEFAULT=siop-2
ENV VCISSUER_WALTID_ADDRESS=http://localhost
ENV VCISSUER_WALTID_SIGNATORY_PORT=6001
COPY --from=build /app/target/*.jar /opt/keycloak/providers/
RUN mv $(ls /opt/keycloak/providers/*.jar | head -n 1) /opt/keycloak/providers/vc-issuer-SNAPSHOT-2.jar
# ADD target/vc-issuer-SNAPSHOT-2.jar /opt/keycloak/providers/vc-issuer-SNAPSHOT-2.jar