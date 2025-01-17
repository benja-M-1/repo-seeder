FROM alpine:3.19

# Install crane using their official release
RUN wget -O crane.tar.gz https://github.com/google/go-containerregistry/releases/download/v0.20.2/go-containerregistry_Linux_x86_64.tar.gz && \
    tar -xvf crane.tar.gz crane && \
    mv crane /usr/local/bin/crane && \
    rm crane.tar.gz && \
    chmod +x /usr/local/bin/crane

# Copy the script
COPY seed.sh /usr/local/bin/seed.sh
RUN chmod +x /usr/local/bin/seed.sh

# Set the entrypoint to the script
ENTRYPOINT ["/bin/sh", "/usr/local/bin/seed.sh"] 