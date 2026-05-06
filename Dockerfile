FROM node:20-alpine

WORKDIR /app

# Tạo user non-root
RUN addgroup -S nodejs && adduser -S nodejs -G nodejs

# Copy package.json từ src
COPY src/package*.json ./

# Install deps
RUN npm install --omit=dev && npm cache clean --force && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx

# Copy source code
COPY src/ ./src/

# Set quyền
RUN chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 3000

# Health check đúng endpoint
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/health || exit 1

#
CMD ["node", "src/main.js"]
