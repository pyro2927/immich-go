# Build stage
FROM golang:1.24-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git

# Set working directory
WORKDIR /build

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o immich-go

# Final stage
FROM alpine:3.19

# Add ca-certificates for HTTPS requests
RUN apk --no-cache add ca-certificates

# Create non-root user
RUN adduser -D -H -h /app appuser

WORKDIR /app

# Copy binary from builder
COPY --from=builder /build/immich-go .

# Set ownership
RUN chown -R appuser:appuser /app

# Use non-root user
USER appuser

# Set entrypoint
ENTRYPOINT ["./immich-go"]