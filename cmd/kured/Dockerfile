FROM ubuntu:16.04
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/cache/apt
ADD https://storage.googleapis.com/kubernetes-release/release/v1.7.6/bin/linux/amd64/kubectl /usr/bin/kubectl
RUN chmod 0755 /usr/bin/kubectl
COPY ./kured /usr/bin/kured
ENTRYPOINT ["/usr/bin/kured"]
