FROM elixir:alpine as build
RUN apk add --no-cache git
WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force
ENV MIX_ENV=prod
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config
RUN mix deps.compile
COPY lib lib
RUN mix compile
COPY config/runtime.exs config/
RUN mix release

# Start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM elixir:alpine AS app
RUN apk add --no-cache openssl ncurses-libs libgcc libstdc++
WORKDIR /app
RUN mix local.hex --force
COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/own_hex ./
COPY --chown=nobody:nobody ./entrypoint.sh ./
RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
CMD ["start"]
