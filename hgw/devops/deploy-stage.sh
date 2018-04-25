#!/bin/bash

HOST="stage-gateway.casa.iq"
USER="root"
VERSION="0.0.1"
SSH_LOGIN="${USER}@${HOST}"

cp /home/runner/prod.secret.exs config/prod.secret.exs
source /home/runner/.kerl/installs/19/activate
mix local.hex --force
mix local.rebar --force
SSL_PORT=443 PORT=80 SSL=true MIX_ENV=prod mix do deps.get, compile, phx.digest, release --env=prod
scp -oStrictHostKeyChecking=no _build/prod/rel/hub_gateway/releases/${VERSION}/hub_gateway.tar.gz ${SSH_LOGIN}:/tmp
scp -oStrictHostKeyChecking=no devops/deploy.sh ${SSH_LOGIN}:/tmp

ssh -oStrictHostKeyChecking=no ${SSH_LOGIN} 'chmod +x /tmp/deploy.sh; bash /tmp/deploy.sh;'
