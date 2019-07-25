$ErrorActionPreference = "Stop"
$Env:DOCKER_BUILDKIT = 1

echo "---"
echo "!> Preping build image"
docker build -f Dockerfile.builder -t local/terraformer-builder .

echo "---"
echo "!> Ensure build dir"
mkdir -Force generated


echo "---"
echo "!> Building code"
docker run  `
-v ${PWD}/generated:/generated `
--rm -ti `
local/terraformer-builder `
gox -osarch windows/amd64 -output "/generated/windows/terraformer" `
.

echo "---"
echo "Executable placed in the [./generated/windows] directory"