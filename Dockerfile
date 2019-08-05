FROM golang as gobuilder
ENV GO111MODULE=on
ENV CGO_ENABLED=0
RUN go get -u github.com/mitchellh/gox

FROM gobuilder as src-builder
WORKDIR $GOPATH/src/github.com/GoogleCloudPlatform/terraformer

# Fetch dependencies first; they are less susceptible to change on every build
# and will therefore be cached for speeding up the next build
COPY ./go.mod ./go.sum ./
RUN go mod download

# Build the code
COPY . .
RUN gox \
    -osarch linux/amd64 \
    -output "/out/{{.OS}}_{{.Arch}}/${PWD##*/}" \
    .

# Other tools downloader
FROM debian as other-tools

# Create smaller comntainer
FROM debian
RUN apt-get update -y 
RUN apt-get install -y \
	unzip \
        curl \
        gnupg-agent \
        jq \
        dos2unix \
        jq \
        tree \
        nmap \
        dnsutils \
        vim
RUN curl -L https://releases.hashicorp.com/terraform/0.12.5/terraform_0.12.5_linux_amd64.zip -o pkg.zip \
	&& unzip pkg.zip \
	&& mv terraform /usr/local/bin/ \
        && rm pkg.zip
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
	&& curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - \
	&& apt-get update -y && apt-get install google-cloud-sdk -y

COPY --from=src-builder /out/linux_amd64/terraformer /usr/local/bin/terraformer

CMD ["terraformer"]

