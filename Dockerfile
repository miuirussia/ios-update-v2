FROM node:lts-alpine
RUN apk --no-cache add g++ gcc libgcc libstdc++ linux-headers make python3 apk-cron && yarn global add node-gyp pnpm
ADD ./package.json ./pnpm-lock.yaml /opt/app/
WORKDIR /opt/app
RUN pnpm install --frozen-lockfile

ADD ./index.ts ./tsconfig.json /opt/app/
RUN pnpm build

ADD ./crontab.txt /crontab.txt
RUN /usr/bin/crontab /crontab.txt

CMD ["/usr/sbin/crond", "-f"]
