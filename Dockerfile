FROM node:9

# Create app directory
WORKDIR /app/server
#ADD . /app
LABEL maintainer="prince.mathew@itcinfotech.com"

RUN npm install -g grunt 
RUN npm install -g express
RUN npm install -g forever

EXPOSE 5000
#CMD [ "npm", "start" ]
#CMD [ "node", "server" ]
