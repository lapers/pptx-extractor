# Use an Alpine Linux base image
FROM alpine:latest

# Install dependencies
RUN apk --no-cache add bash unzip xmlstarlet

# Create a directory for your XML files and images
WORKDIR /data

# Copy the script into the container
COPY src/pptx-extractor.sh /entrypoint.sh

# Make the script executable
RUN chmod +x /entrypoint.sh

# Set the entrypoint to your script
ENTRYPOINT ["/entrypoint.sh"]
 
