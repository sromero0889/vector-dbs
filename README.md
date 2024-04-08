## Vector DBs
Local deployment of different vector databases using Minikube.


## Minikube: Getting Started

To install minikube check the [docs](https://minikube.sigs.k8s.io/docs/start/)

The configuration I'm using is the following:

- driver=podman
- rootless true
- container-runtime=containerd
[docs](https://minikube.sigs.k8s.io/docs/drivers/podman/)

## Commands

Get the status
```bash
minikube status
```

Start Cluster
```bash
minikube start
```

Stop Cluster
```bash
minikube stop
```

Get info about the nodes in your cluster
```bash
kubectl get nodes -o wide
```


[docs](https://minikube.sigs.k8s.io/docs/commands/tunnel/)
```bash
minikube tunnel
```


## Env Variables

Create a .env file to store your variables.
You will need one per database, run the following to create it automatically

**Generate pgvector .env file**
```bash
cat > pgvector/.env << EOF
# PgVector
POSTGRES_DB=dbname
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
EOF
```

Deployment scripts will create a secret per db referenced by the deployment.yml file


## Deployments

---

**Important!!**

Before you run any deployment script, **check your .env files**, if you want to use a different one just pass it to the script, by default it will use .env (Remember that each db has its own env file)

```bash
bash deploy_dbs.sh --env ".env_prod"
```

or 

```bash
bash deploy_dbs.sh -e ".env_prod"
```

---


## Deploy PgVector
To deploy pgvector, use --pgvector flag
```bash
bash deploy_dbs.sh --pgvector
```

## Deploy Multiple DBs

db_flag:
    --pgvector
    

```bash
bash deploy_dbs.sh --db_flag1 --db_flag2
```

## Test DB access
To get the external ip

```bash
kubectl get services
```

if you don't see it, [run](https://minikube.sigs.k8s.io/docs/commands/tunnel/):
```bash
minikube tunnel
```

### PgVector
**Check if the db is accepting connections**
```bash
pg_isready -d ${POSTGRES_DB} -h ${EXTERNAL_IP} -p 5432 -U ${POSTGRES_USER}
```
**Open a connection**
[docs](https://www.postgresql.org/docs/current/app-psql.html)
```bash
psql -d ${POSTGRES_DB} -h ${EXTERNAL_IP} -p 5432 -U ${POSTGRES_USER}
```


## Delete Resources

### PgVector
```bash
kubectl delete service pgvector && \
kubectl delete deployment pgvector  && \
kubectl delete pv pgvector-pv  && \
kubectl delete pvc pgvector-pvc  && \
kubectl delete secret pgvector-secrets
```