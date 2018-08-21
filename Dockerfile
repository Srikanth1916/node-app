FROM node:9

# Create app directory
WORKDIR /usr/src/app
COPY server/package*.json ./
LABEL maintainer="prince.mathew@itcinfotech.com"

RUN npm install -g grunt express
# For production
# RUN npm install -g --only=production

# Bundle app source
COPY . .

EXPOSE 8080
CMD [ "npm", "start" ]