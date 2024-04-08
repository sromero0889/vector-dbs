#!/bin/bash
set -eu
set -a

export DEPLOYMENT_ENV_PATH=".env"

dbs_list=()

while [ $# -gt 0 ]; do
  case "$1" in
    --env|-e)
      export DEPLOYMENT_ENV_PATH="${2}"
      shift
      ;;
    --pgvector| -pgv)
      dbs_list+=("pgvector")
      ;;
    #todo! add flag per db
    *)
      printf "ERROR: Invalid param\n"
      exit 1
  esac
  shift
done


echo "Databases: ${dbs_list[*]}"


for db in "${dbs_list[@]}"
do
    echo "Deploy db: ${db}"
    deployment_path="$db/deployment.yml"
    env_path="$db/$DEPLOYMENT_ENV_PATH"
    db_secret_name="$db-secrets"
    echo "Secret $db_secret_name from $env_path"
    kubectl create secret generic "${db_secret_name}" --from-env-file="${env_path}" --dry-run=client -o yaml | kubectl apply -f -

    kubectl apply -f "$deployment_path"
    kubectl expose deployment "${db}" --type=LoadBalancer --name="${db}" --dry-run=client -o yaml | kubectl apply -f -

done

# Clean env vars
unset DEPLOYMENT_ENV_PATH
set +a




