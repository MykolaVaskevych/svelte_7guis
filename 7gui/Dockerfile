FROM oven/bun

WORKDIR /app
COPY 7gui/package.json package.json
RUN bun install

COPY . .
RUN bun run build

EXPOSE 3000
ENTRYPOINT ["bun", "./7gui/build"]