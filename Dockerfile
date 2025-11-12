# ---------- Stage 1: Build Angular ----------
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
ARG BUILD_ENV=dev
RUN if [ "$BUILD_ENV" = "dev" ]; then \
      npm run build -- --configuration dev; \
    else \
      npm run build -- --configuration production; \
    fi

# ---------- Stage 2: Serve ----------
FROM nginx:alpine
ARG BUILD_ENV

# Copy built files
COPY --from=builder /app/dist/myapp-${BUILD_ENV} /usr/share/nginx/html

# Copy custom nginx config 
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
