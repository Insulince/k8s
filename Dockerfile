FROM node:6.11.0-alpine AS ng-build

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json /usr/src/app
RUN npm install

COPY . /usr/src/app

RUN node_modules/\@angular/cli/bin/ng build --prod

FROM nginx:alpine
COPY default.conf /etc/nginx/conf.d/default.conf
COPY --from=ng-build /usr/src/app/dist /usr/share/nginx/html
EXPOSE 80
