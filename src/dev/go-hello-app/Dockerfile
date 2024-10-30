FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod ./

RUN go mod download

COPY . .

RUN go build -o go-hello-app .

FROM alpine:latest

WORKDIR /root/

COPY --from=builder /app/go-hello-app .

EXPOSE 8080

ENV PORT=8080

CMD ["./go-hello-app"]
