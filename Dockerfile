# Update Alpine packages (Fixes vulnerabilities in base image)
FROM alpine:latest AS security-update
RUN apk update && apk upgrade --no-cache libxml2

# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

# Apply security updates from security-update stage
COPY --from=security-update /lib /lib
COPY --from=security-update /usr/lib /usr/lib
COPY --from=security-update /usr/bin /usr/bin

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
