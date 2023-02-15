FROM ubuntu:20.04 as base
  ENV TARGETARCH=linux-arm64

  RUN set -ex \
   && DEBIAN_FRONTEND=noninteractive apt-get update \
   && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
   && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
        apt-transport-https \
        apt-utils \
        ca-certificates \
        curl \
        docker.io \
        git \
        iputils-ping \
        jq \
        lsb-release \
        software-properties-common

  RUN set -ex \
   && curl -sL https://aka.ms/InstallAzureCLIDeb | bash

  WORKDIR /azp

FROM base as installer
  ARG AZP_URL

  COPY agent/installer /bin/agent-installer
  RUN --mount=type=secret,id=AZP_TOKEN set -ex \
   && bash /bin/agent-installer

FROM base as agent
  COPY --from=installer /azp .
  COPY ./agent/start.sh .
  RUN chmod +x start.sh
  RUN ls -Al .

  ENTRYPOINT [ "./start.sh" ]
