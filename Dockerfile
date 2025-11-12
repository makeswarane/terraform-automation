# ---------- Stage 1: Build Angular ----------
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
ARG BUILD_ENV=development
RUN npm run build -- --configuration $BUILD_ENV

# ---------- Stage 2: Serve ----------
FROM nginx:alpine
ARG BUILD_ENV

# Copy built files
COPY --from=builder /app/dist/myapp /usr/share/nginx/html

# Copy custom nginx config 
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
