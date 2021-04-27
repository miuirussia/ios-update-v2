FROM alpine:latest

ADD ./crontab.txt /crontab.txt
RUN /usr/bin/crontab /crontab.txt

WORKDIR /root
ADD bootstrap.sh /tmp/
RUN sh -e /tmp/bootstrap.sh
ENV \
  NIX_PATH=nixpkgs=/root/.nix-defexpr/channels/nixpkgs \
  PATH=/root/.nix-profile/bin:/root/.nix-profile/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
  NIX_SSL_CERT_FILE=/root/.nix-profile/etc/ssl/certs/ca-bundle.crt \
  SSL_CERT_FILE=/root/.nix-profile/etc/ssl/certs/ca-bundle.crt

WORKDIR /opt/app
ADD ./default.nix ./package.json ./yarn.lock ./index.ts ./tsconfig.json /opt/app/
RUN nix-env -f /opt/app/default.nix -i

CMD ["/usr/sbin/crond", "-f"]
