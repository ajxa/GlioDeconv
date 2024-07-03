# this is a rough and ready bash script with steps used to build 
# and deploy a container to a private azure container registry 

# here we run docker build to create the container image
# using the dockerfile specified in the current directory
# we give it a name and a tag with the format name:tag
docker build . -t gbmconvoluter:2022-08-02

# once built this image is available locally
# we can run a container instance of the image with
# docker run --rm -p 3838:3838 gbmconvoluter:2022-08-02

# next we use docker login to connect to our private registry
docker login gbmdeconvoluter.azurecr.io
# this will prompt for a password and username available on Azure

# now we create a new tag of the docker image pointing it at the container registry
docker tag gbmconvoluter:2022-08-02 gbmdeconvoluter.azurecr.io/gbmconvoluter:2022-08-02

# once retagged we can push the image from our machine to the registry
docker push gbmdeconvoluter.azurecr.io/gbmconvoluter:2022-08-02

# the docker image is now available in the private container registry on azure