FROM golang as gobuilder
ENV GO111MODULE=on
ENV CGO_ENABLED=0
RUN go get -u github.com/mitchellh/gox

FROM gobuilder as code-builder
WORKDIR $GOPATH/src/github.com/GoogleCloudPlatform/terraformer

# Fetch dependencies first; they are less susceptible to change on every build
# and will therefore be cached for speeding up the next build
COPY ./go.mod ./go.sum ./
RUN go mod download

# Build the code
COPY . .

# RUN go build -o /out/terraformer ./main.go

#RUN gox \
#    -osarch linux/amd64 \
#    -osarch windows/amd64 \
#    -osarch darwin/amd64 \
#    -output "/out/{{.OS}}_{{.Arch}}/${PWD##*/}" \
#    .


#FROM debian
#COPY --from=code-builder /out/linux_amd64/terraformer /terraformer
#ENTRYPOINT ["/terraformer"]

