FROM nginx:latest

RUN apt-get update && apt-get install -y \
    curl \
    netcat-openbsd \
    && apt-get clean

COPY default.conf /etc/nginx/conf.d/default.conf
COPY wait-for-services.sh /wait-for-services.sh

RUN chmod +x /wait-for-services.sh

CMD ["/wait-for-services.sh"]