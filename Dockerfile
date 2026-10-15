FROM alpine:3.20

# Install only what the scripts need (bash, ping, free, hostname tools)
RUN apk add --no-cache bash procps iputils

WORKDIR /app
COPY app/ /app/
RUN chmod +x /app/*.sh

HEALTHCHECK --interval=30s --timeout=5s CMD ["/app/health-check.sh"]

ENTRYPOINT ["/app/diagnostic.sh"]
CMD ["help"]