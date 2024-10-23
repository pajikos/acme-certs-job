# Start from the go-acme/lego image
FROM goacme/lego:v4.19

# Install required tools
RUN apk add --no-cache bash wget openssl kubectl

# Set working directory
WORKDIR /app

# Copy the script into the container
COPY renew_certificates.sh /app/renew_certificates.sh

# Make the script executable
RUN chmod +x /app/renew_certificates.sh

# Set environment variables (can be overridden by user)
ENV LEGO_EMAIL="your-email@example.com"
ENV WEDOS_USERNAME="your-wedos-username"
ENV WEDOS_WAPI_PASSWORD="your-wedos-password"
ENV WEDOS_TTL=300
ENV WEDOS_POLLING_INTERVAL=180
ENV WEDOS_PROPAGATION_TIMEOUT=1800

# Copy the configuration file into the container
COPY domains.config /app/domains.config

# Entry point to run the script
ENTRYPOINT ["/app/renew_certificates.sh"]
