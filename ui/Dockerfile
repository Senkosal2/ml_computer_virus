FROM httpd:alpine

# Remove default Apache site content
RUN rm -rf /usr/local/apache2/htdocs/*

# Copy your UI files
COPY . /usr/local/apache2/htdocs/

# Expose HTTP port
EXPOSE 80