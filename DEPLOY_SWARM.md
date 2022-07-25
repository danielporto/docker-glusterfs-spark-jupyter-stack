# Distributed deployment

this is split into two parts: first, the GlusterFS which are installed in the machines
and the stack deployment. 

## Quick start to GlusterFS

The deployment can be automatically done using ansible playbooks available.
Start defining the set of nodes that will be part of the DFS ensamble.

For that, update the `inventory.ini` file with the credentials (with sudo access)
to the remote nodes.

Make sure you have ssh access with keyfile to all these nodes.


### Test the connection
Open the container (which are not required, but has ansible and all tools installed for simplicity),
and run:
```
ansible all -m ping
```


To deploy an the GlusterFS cluster, run:
```
  docker-compose build
  docker-compose up
