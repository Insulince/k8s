# K8s

### Preamble:
This project is for testing Kubernetes via Minikube. You need `docker`, `kubectl`, and `minikube`. I reccomend also installing the Angular CLI (Angular 2+, not Angular.js) and trying out this project to see what it does.


### Set up Docker:
First thing you are required to have is docker. This can be downloaded online and is easy to install, I believe it may be availble through homebrew as well. Anyway, once it is installed, you need to build an image of the project. Images are like snapshots of the project, and when you want to use it, it is "started" and put inside a container. So think of images as non-running containers, and containers as running images.

To make an image of a project, you need a Dockerfile to execute docker on (I already provided one in this project at the root), and then you need to do:

`docker build -t ~name~:~version~ .` where `~name~` is the name you want to give the image and `~version~` is a version tag (such as "`v1.0.0`"). Note the "." at the end of the command, this is needed!

If your dockerfile is accurate and all goes well, you will have an image in your docker-machine. Check for it by doing:

`docker images`

You will see a list of your existing images, and one should have the `REPOSITORY` field as `~name~`, this is the image we just built.

Next we need to send this image off to the docker registry, but we haven't set that up yet. See the below section to set up the registry then return here.

Once your registry is set up, do:

`docker tag ~name~:~version~ localhost:5000/~name~:~version~`

this "tags" your image to have the registry's location. Think of it as slapping a shipping label onto your image, but the image hasn't been shipped to the registry yet. Next we need to preform the actual shipping by doing:

`docker push localhost:5000/~name~:~version~`

Once this completes, you will have successfully pushed an image into your registry. Check at the url posted in the following section.

You are now ready to set up `minikube`.

### Set up your Docker Registry:
In order for this to work you need a docker registry, which is just a place for you to store your images on besides on the docker-machine. You can use dockerhub for this, but I opted to use a private registry for more control. It only requires mild changes to the procedure. To get your registry up and running do:

`docker run -d -p 5000:5000 --name registry registry:2`

Once this executes successfully, you will have a registry running at `http://localhost:5000`. To view what images are in the registry, hit `http://localhost:5000/v2/_catalog`.

### To properly set up minikube:
First things first, you will need to fetch your machines private IP. This is not `localhost`, and this is not the ip you would find by googling it. It is what identifies your machine to your local network. This IP will be denoted throughout this document as `~machine ip~`. For macs, I used the IP located under `System Preferences...` > `Network`, and then it appears under "Status: Connected" in the right-hand pane.

You need to install `minikube`, I believe this can be done through brew, but if not it is a simple google to figure it out. 

I am not sure if the command line `kubectl` comes with `minikube`, but you will need to have this tool in addition to `minikube`. It is how you interact with kubernetes via command line.

- `minikube start --insecure-registry="docker.local:5000"` starts the VM (and signals to docker that `docker.local:5000` is the address of an insecure docker registry).
- `minikube stop` stops the VM.
- `minikube delete` completely deletes the VM.
- `minikube ssh` sends you into a shell in the VM.

Once you have done a `minkube start` you will need to `minikube ssh` into the vm and then do:
- `sudo chmod 666 /etc/hosts` (makes the hosts file writable for you)
- `sudo vi /etc/hosts` (opens the hosts file for writing)
- add to the end of the file:
  - `~machine ip~ docker.local` (adds an entry that aliases the term "docker.local" to be ~machine ip~)
- `exit` to leave the shell and return to you local machine.

If all was done successfully, you should now have a running instance of kubernetes inside the minikube VM which is looking at "docker.local:5000" for a source of images (the registry), and has the address "docker.local:5000" listed as an insecure registry, and has the term "docker.local" aliased with ~machine ip~.

Simply populate your local registry (on your machine, not the VM) with your images, refer to them in your YAML files as being located at "`docker.local:5000/~name~:~version~`", and execute your `kubectl` commands. All should be well.

### Kubectl commands
To create the deployment (don't do this until everything before this is set up):
- `kubectl create -f deployment.yaml`

To create the service for the pods that created:
- `kubectl create -f service.yaml`
