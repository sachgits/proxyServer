FROM node:8

ADD package.json /package.json

# set node_modules to global
ENV NODE_PATH=/node_modules
ENV PATH=$PATH:/node_modules/.bin
RUN npm install

# set up working dir
WORKDIR /usr/src/app
ADD . /usr/src/app

# Set permissions for "node" user
RUN chown -R node:node /usr/src/app
RUN chown -R node:node /node_modules
RUN chmod 755 /usr/src/app

# https://unix.stackexchange.com/questions/104171/create-ssl-certificate-non-interactively
# We are okay creating generating this cert in the Dockerfile because the web server sits in a private
# subnet in AWS behind a load balancer with a CA signed cert
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	     -keyout /usr/src/app/certs/selfsigned.key \
	     -out /usr/src/app/certs/selfsigned.crt \
	     -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=localhost"

RUN chmod -R 755 /usr/src/app/certs

# Run the container under "node" user by default
USER node

ENV NODE_ENV production

EXPOSE 5000

CMD ["node", "src/index.js"]
