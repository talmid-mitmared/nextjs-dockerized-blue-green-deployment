FROM dhi.io/node:24-alpine3.22-dev AS builder

WORKDIR /usr/local/app

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .
RUN yarn build


# =========================================
# Stage 2: Prepare Nginx to Serve Static Files
# =========================================

FROM dhi.io/nginx:1.28.0-alpine3.21-dev AS runner

# Copy custom Nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Next.js static export output is /out
COPY --chown=nginx:nginx --from=builder /usr/local/app/out /usr/share/nginx/html

# Use a non-root user
USER nginx

# Nginx listens on 8080 inside this image
EXPOSE 8080

ENTRYPOINT ["nginx", "-c", "/etc/nginx/nginx.conf"]
CMD ["-g", "daemon off;"]