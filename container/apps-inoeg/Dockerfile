FROM  ghcr.io/kiebitz-oss/apps-inoeg:main as origin

ADD  https://raw.githubusercontent.com/thomasfricke/container-hardening/main/harden /harden

USER 0
WORKDIR /

RUN chmod +x /harden

RUN mkdir /tmp/harden

RUN /harden -d /usr/sbin/nginx \
             -f /etc/nginx  /var/log/nginx/ /var/run/nginx.pid /var/cache/nginx  /etc/passwd /etc/group \
                /usr/share/nginx /usr/share/licenses/ /var/run /app /tmp \
             -c /var/log/nginx/ /var/cache/nginx /var/run

FROM scratch

COPY --from=origin /tmp/harden/ /

USER 101

WORKDIR /app

EXPOSE 3000

ENTRYPOINT ["/usr/sbin/nginx","-g","daemon off;"]
