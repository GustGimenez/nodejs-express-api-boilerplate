FROM node:18-alpine AS app_development

WORKDIR /app

EXPOSE 3000

COPY package.json yarn.lock ./

COPY . .

RUN yarn install

CMD [ "yarn", "start:dev" ]

# ---------------- 
FROM node:18-alpine AS app_build

WORKDIR /build

COPY package.json yarn.lock ./

RUN yarn install --pure-lockfile

COPY . .

RUN yarn build

# ----------------
FROM app_build AS app_dependencies

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install --pure-lockfile --production

# ----------------
FROM app_dependencies AS app_production

WORKDIR /app

COPY --from=app_build /build/dist /app/dist
COPY --from=app_dependencies /app/node_modules /app/node_modules

EXPOSE 3000

CMD [ "yarn", "start:prod" ]
