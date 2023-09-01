FROM nginx:latest

LABEL maintainer="your_email@example.com"

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

