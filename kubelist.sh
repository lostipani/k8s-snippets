#!/bin/bash

# List resources in all namespaces.
#
# ./kubelist.sh <product> <resource> [--nameonly]
# - product: product name of a given tenant
# - resource: k8s objects or "resources" for cpu, ram and disk consumption

PRODUCT_VAL=$1
PRODUCT_KEY=
RESOURCE=$2

if [ $RESOURCE == "pods" ]
then
    RESOURCE="pod" # cast "pods" to "pod" for the sake of unambiguity
    tot_pods=0
fi

for ns in $(kubectl get namespaces -l $PRODUCT_KEY=$PRODUCT_VAL --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
do
    printf "=====\nNAMESPACE: $ns\n"

    if [ $2 == "resources" ]
    then
        echo "Resources used/reserved:"
        kubectl describe namespaces $ns | grep --color=never -e "limits.cpu" -e "limits.memory" -e "storage"
        continue
    fi

    if [ $# -eq 3 ] && [ $3 == "--nameonly" ]
    then
        kubectl get $RESOURCE -n $ns --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}';
    else
        kubectl get $RESOURCE -n $ns;
    fi
    
    if [ $RESOURCE == "pod" ]
    then
        n_pods=$(kubectl get pods -n $ns --field-selector=status.phase!=Succeeded,status.phase!=Failed --output json | jq -j '.items | length')
        tot_pods=$((tot_pods+n_pods))
        printf "NUMBER OF PODS: $n_pods pods\n" 
    fi
done

if [ $RESOURCE == "pod" ]
then
    printf "=====\nTOTAL NUMBER OF PODS: $tot_pods pods\n"
fi
