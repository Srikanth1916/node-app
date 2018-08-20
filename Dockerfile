FROM node:9
USER sudo
# Create app directory
WORKDIR /usr/src/app

LABEL maintainer="prince.mathew@itcinfotech.com"

RUN npm install -g grunt express
# For production
# RUN npm install -g --only=production

# Bundle app source
COPY . .

EXPOSE 8080
CMD [ "npm", "start" ]