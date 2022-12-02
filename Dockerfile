FROM alpine:latest

ENV CLOUD_SDK_VERSION 410.0.0
ENV TERRAFORM_VERSION=1.3.5
ENV HELM_VERSION=3.10.2

ENV PATH /google-cloud-sdk/bin:$PATH
RUN apk --no-cache add \
        curl \
        python3 \
        py-pip \
        py-crcmod \
        bash \
        libc6-compat \
        openssh-client \
        apache2-utils \
        git \
        jq \
    && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    ln -s /lib /lib64 && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud components install kubectl && \
    gcloud components install docker-credential-gcr --quiet && \
    docker-credential-gcr configure-docker

RUN pip install jinja2

#RUN wget --quiet https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
#    && tar -xzf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
#    && mv linux-amd64/helm /usr/bin \
#    && rm -rf linux-amd64 

RUN wget --quiet https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && rm -rf /tmp/* \
  && rm -rf /var/cache/apk/* \
  && rm -rf /var/tmp/*