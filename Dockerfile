# ---------- Stage 1: Build Angular App ----------
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Default build environment
ARG BUILD_ENV=dev

# Build Angular app based on BUILD_ENV
RUN if [ "$BUILD_ENV" = "production" ]; then \
      npm run build -- --configuration production; \
    else \
      npm run build -- --configuration dev; \
    fi

# ---------- Stage 2: Serve with Nginx ----------
FROM nginx:alpine

# Default build environment again in Stage 2
ARG BUILD_ENV=dev

# Remove default nginx html
RUN rm -rf /usr/share/nginx/html/*

# Copy built Angular app from builder stage
COPY --from=builder /app/dist/ /usr/share/nginx/html/

# If you want only the selected folder, you can do this:
# RUN if [ "$BUILD_ENV" = "production" ]; then \
#       cp -r /usr/share/nginx/html/myapp/* /usr/share/nginx/html/; \
#     else \
#       cp -r /usr/share/nginx/html/myapp-dev/* /usr/share/nginx/html/; \
#     fi

# Copy custom nginx config (optional)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
