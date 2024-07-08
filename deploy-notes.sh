# this is a rough and ready bash script with steps used to build 
# push this container to the private azure container registry

# here we run docker build to create the container image
# using the dockerfile specified in the current directory
# we give it a name and a tag with the format name:tag
# The platform tag ensures it can be built locally on a machine which uses Mac Silicon
docker build --platform linux/x86_64 -t gbmdeconvoluter:test .
docker build --platform linux/x86_64 -t gbmdeconvoluter:final_test .

# once built this image is available locally at the port we exposed 3838
# we can run a container instance of the image with
docker run -p 3838:3838 gbmdeconvoluter:test
docker run -p 3838:3838 gbmdeconvoluter:final_test

# Once the container is running we can check the application loads and functions correctly	
# by opening it in a web browser at the exposed port location:
http://localhost:3838/

# Once we have ensured the local docker image and container are working as intended we can then
# push this image to our private container registry on azure. To do this we will need to first install the
# Azure CLI which can be done using home-brew and then we can login to our private registry using the
# url which we have already pre-configured:

docker login gbmdeconvoluter.azurecr.io

# this will prompt us for a username and password that can be found on 
# the Azure container registry portal in the “Access keys” section

# now we create a new tag of the docker image pointing it at the container registry
# docker tag gbmconvoluter:2022-08-02 gbmdeconvoluter.azurecr.io/gbmconvoluter:2022-08-02

Docker tag gbmdeconvoluter:2024-07-08_gbmpurity_image gbmdeconvoluter.azurecr.io/gbmdeconvoluter:2024-07-08_gbmpurity_image

# once retagged we can push the image from our machine to the registry
#  docker push gbmdeconvoluter.azurecr.io/gbmconvoluter:2022-08-02

docker push gbmdeconvoluter.azurecr.io/gbmdeconvoluter:2024-07-08_gbmpurity_image

# the docker image is now available in the private container registry on azure and can be pointed to
# from the app service deployment options
# The last known deployment was:
Image tag: 9429082df816cd51093f32f79011ce9a1b9a4c45




