FROM ubuntu:22.04

ARG TERRAFORM_VERSION="1.5.4"
ARG ANSIBLE_VERSION="8.2.0"
ARG AWSCLI_VERSION="2.13.5"
ARG YANDEXCLI_BERSION=""
ARG KUBECTL_VERSION="1.27.4"
ARG PACKER_VERSION="1.9.2"

ENV DEBIAN_FRONTEND=noninteractive
ENV AWSCLI_VERSION=${AWSCLI_VERSION}
ENV TERRAFORM_VERSION=${TERRAFORM_VERSION}
ENV PACKER_VERSION=${PACKER_VERSION}
RUN apt-get update \
    # pre-tools
    && apt-get install -y curl python3 python3-pip python3-boto python3-dev unzip  \
    # ansible
    && pip3 install ansible==${ANSIBLE_VERSION} \
    # aws-cli
    # && pip3 install --upgrade awscli==${AWSCLI_VERSION} \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip" -o "awscliv2.zip" \
        && unzip -o awscliv2.zip \
        && ./aws/install --update \
        && rm awscliv2.zip \
    # yc-cli
    && curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh -o yc-install.sh \
        && bash yc-install.sh -a \
        # && source "/$(whoami)/.bashrc" \
        && rm yc-install.sh \
    # kubectl
    && curl -LO https://dl.k8s.io/release/v{KUBECTL_VERSION}/bin/darwin/amd64/kubectl \
        && chmod +x ./kubectl \
        && mv ./kubectl /usr/local/bin/kubectl \
    # terraform
    && curl -LO https://hashicorp-releases.yandexcloud.net/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    # packer
    && curl -LO https://hashicorp-releases.yandexcloud.net/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
    # move all bins to /usr/local/bin
    && unzip '*.zip' -d /usr/local/bin \
    && rm *.zip

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/bin/bash"]