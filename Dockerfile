FROM debian:sid

RUN apt update -y \
    	&& apt upgrade -y \
    	&& apt install -y wget unzip qrencode node

ADD entrypoint.sh /entrypoint.sh
ADD w2t.js /w2t.js
ADD package.json /package.json
RUN chmod +x /entrypoint.sh /w2t.js /package.json
RUN npm install && npm install -g pm2
CMD /entrypoint.sh
