FROM nginx:alpine

# Remove default nginx site
RUN rm -rf /usr/share/nginx/html/*

# Copy your UI files
COPY . /usr/share/nginx/html

EXPOSE 80