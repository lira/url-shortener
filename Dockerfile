# Build stage
FROM golang:1.22-alpine AS builder

# Install essential build dependencies
RUN apk add --no-cache gcc musl-dev

# Set the working directory
WORKDIR /app

# Copy only the dependency files
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code
COPY . .

# Build the application with optimizations
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o url-shortener

# Final stage
FROM alpine:latest

# Add CA certificates for HTTPS
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy only the built executable from builder
COPY --from=builder /app/url-shortener .

# Expose the port
EXPOSE 8080

# Run the executable
CMD ["./url-shortener"]