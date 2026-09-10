FROM alpine:latest

COPY emit-message.sh /usr/local/bin/emit-message.sh
RUN chmod +x /usr/local/bin/emit-message.sh

ENTRYPOINT ["/usr/local/bin/emit-message.sh"]
