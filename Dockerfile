FROM golang:1.23.1-bookworm AS build

WORKDIR /src

RUN apt-get update \
	&& apt-get install -y --no-install-recommends build-essential pkg-config libssl-dev ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=1 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/benakun .

FROM debian:bookworm-slim

RUN apt-get update \
	&& apt-get install -y --no-install-recommends ca-certificates libssl3 \
	&& rm -rf /var/lib/apt/lists/* \
	&& useradd --system --create-home --uid 10001 appuser

WORKDIR /app

COPY --from=build /out/benakun /app/benakun
COPY --from=build /src/svelte /app/svelte
COPY docker/app-entrypoint.sh /app/app-entrypoint.sh

RUN mkdir -p /app/uploads \
	&& chmod +x /app/benakun /app/app-entrypoint.sh \
	&& chown -R appuser:appuser /app

USER appuser

EXPOSE 1235

ENTRYPOINT ["/app/app-entrypoint.sh"]