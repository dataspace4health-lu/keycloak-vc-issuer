FROM quay.io/keycloak/keycloak:23.0.7
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin
ENV KC_SPI_THEME_ADMIN_DEFAULT=siop-2
ENV VCISSUER_WALTID_ADDRESS=http://localhost
ENV VCISSUER_WALTID_SIGNATORY_PORT=6001
ADD target/vc-issuer-1.0.3.jar /opt/keycloak/providers/vc-issuer-1.0.3.jar
