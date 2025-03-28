FROM node:22.0.0 AS build
WORKDIR /app
COPY . /app/
RUN npm clean-install
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx
EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
