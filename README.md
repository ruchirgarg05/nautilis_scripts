# Essentials for Nautilus

## Basics:
1. Register on [nautilus](https://nautilus.optiputer.net/). Follow the [acces
s guide](https://ucsd-prp.gitlab.io/userdocs/start/get-access/)
2. Request in [matrix](https://element.nrp-nautilus.io/) `Nautilus Support` channel to be transferred from guest account to user. In case you need to be a cluster admin, ask to be promoted to admin. (Not very sure if the cluster admin comes into picture for this)
3. Contact your cluster admin to add you to the namespace. In this case, I am the cluster admin and the namespace is `aryalab`.
4. Go through the [nautilus docs](https://ucsd-prp.gitlab.io/), especially `Start`, `Running/Beginner start`  and `Running/Batch jobs` sections.
5. Respect resource limits and requests especially for jobs.
6. Follow this guide if required for sample scripts.
7. `kubectl` does not work on Guest wifis, eg - UCSD-GUEST.

## [Kubernetes](https://kubernetes.io/docs/home/) tldr --
  - [Containers](https://kubernetes.io/docs/concepts/containers/) : Docker containers are isolated environments where you can load the os and packages of your choice which you specify in a Docker image. 
  - [Images](https://kubernetes.io/docs/concepts/containers/images/): These define how your container is created, ie, which os, packages to install, directories to mount, port exposures, etc. THese are created from a Dockerfile.
  - [Pods](https://kubernetes.io/docs/concepts/workloads/pods/) : Creates a container with os and hardware requirements of your choice for scratch work. Deleted in ~6 hours automatically. All local saved data is lost.
  - [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/) : Creates pods for running scripts. Run until scripts are completed. These need to be deleted manually once the script has run.
  - [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/): Deleted every 2 weeks. For dynamically handling multiple pods.
  - [Services](https://kubernetes.io/docs/concepts/services-networking/service/) : Expose a service, for instance api endpoints running on pods.
  - [PersistentVolumeClaim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) : Permanent storage which you attach to all your pods to save your results.
  - [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) : All private keys/tokens/passwords, which a pod might need access to, but you don't want to expose public access to.

## Pods
### Starting anything from YAML file (pod/job/pvc/deployment)
```
kubectl create -f PATH_TO_YAML_FILE
```

### Describe the status for any pod/job/pvc/deployment 
( Useful for inspecting crashes)
```
kubectl describe pods POD_NAME
```

### SSH into pod
```
kubectl exec -it POD_NAME --bash
```

### Port Forward
```
kubectl port-forward POD_NAME POD_PORT:LOCAL_PORT
```

### Delete pod
```
kubectl delete pod POD_NAME
```

### Delete persistent volume claim
``` 
kubectl delete pvc PVC_NAME
```
### Add your github/gitlab personal access token as a secret to clone private repos
Create a personal access token with atleast `read_repository` permissions from Github/Gitlab settings.

```
kubectl create secret generic SECRET_NAME --from-literal=user=GITHUB_USERNAME --from-literal=password=GITHUB_TOKEN
```
Use the `gpu_main.yaml` format and modify `SECRET_NAME` to use your username and token as environment variables


### Add your private key to repo as secret (can be used for private repos/to ssh with same key)
```
kubectl create secret generic SECRET_NAME --from-file=/path/to/private/key --from-file=/path/to/public/key
```
Use the `gpu_key.yaml` format and modify `SECRET_NAME` to get access to your public and private key inside the Pod
Then, to use public and private key, add it to `ssh-agent` inside the Pod. 
After ssh into the pod, do
```
eval "$(ssh-agent -s)"
ssh-add /path/to/private/key/on/pod
```

## Jobs
Use jobs to run longer scripts ( > 6 hours).

Edit the part in `job.yaml` by adding the required commands
inside `command` argument.
Alternately, you can also use a single `command` with multiple `args` specified as
``` 
  command: ["/bin/sh", "-c"]
  args:
    - echo starting;
      git clone https://$(GIT_USERNAME):$(GIT_PASSWORD)@gitlab.nrp-nautilus.io/harshv834/nautilus-scripts;
      cd nautilus-scripts;
      sh hello_world.sh
```
This command opens a bash shell and runs the commands mentioned in args. Use `;` to separate lines. Follows bash syntax completely.

Can also use a single command with no `args` as 
```
command : ['python' , 'python_script.py']
```

The current `job.yaml` file uses your personal access token to clone this
repo and run the script `hello_world.sh`

Create the job by
```
kubectl create -f job.yaml
```


Check the output of scripts using `kubectl` logs 
 First, get the  `POD_NAME` from
```
kubectl get pods --selector=job-name=JOB_NAME
```
Then, check the output of the script in 
```
kubectl get logs -f POD_NAME
```
**Delete your jobs when completed!**
```
kubectl delete jobs JOB_NAME
```
This deletes all associated pods with the job

## General config `.yaml` files --
- Persistent Storage (Posix) 200GB : `storage_base.yaml`
- GPU Pod with same persistent storage : `gpu_storage.yaml`
- Base GPU Pod without storage : `gpu_base.yaml`
- GPU Pod + persistent storage + personal access token : `gpu_main.yaml` 
- GPU Pod + persistent storage + ssh-key : `gpu_key.yaml`
- Job for GPU Pod + persistent storage + personal access token: `job.yaml`

## Using custom editors inside pods
- `vscode` : Use [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools) and [attach](https://code.visualstudio.com/docs/azure/kubernetes) a vscode environment to your pod. vscode does not detect `kubectl` installed from `snap`, so use `apt`, [link for this](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/). Highly recommend this for easy development inside pods.
- `vim` : either use an image with `vim` or install it either in the Dockerfile or manually after `ssh`.
- ADD_PROCEDURE_FOR_YOUR_TEXT_EDITOR
