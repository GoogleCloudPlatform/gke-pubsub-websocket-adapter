FROM node:18-alpine
WORKDIR /app
ARG NODE_ENV=production
ENV NODE_ENV $NODE_ENV
RUN npm install pulltop --omit=dev
RUN apk add dumb-init
USER 1000
CMD ["sh", "-c", "dumb-init node /app/node_modules/pulltop/pulltop.js $SYMBOL > $STREAM"]
