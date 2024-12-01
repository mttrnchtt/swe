# Use a multi-stage build for Go applications
FROM golang:1.23-alpine as builder

WORKDIR /app

# Copy go.mod and go.sum files first to leverage Docker's cache
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the rest of the application code
COPY . .

# Build the Go binary
RUN go build -o service ./cmd/service


# Use a minimal base image for the final build
FROM alpine:3.18

WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/service .
COPY --from=builder /app/docs ./docs
# Set the entry point to the binary
CMD ["./service"]
