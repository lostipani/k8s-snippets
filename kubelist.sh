#!/bin/bash

PRODUCT_VAL=$1
PRODUCT_KEY=product
RESOURCE=$2

if [ $RESOURCE == "pods" ]
then
    RESOURCE="pod"
    tot_pods=0
fi

for ns in $(kubectl get namespaces -l $PRODUCT_KEY=$PRODUCT_VAL --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
do
    printf "=====\nNAMESPACE: $ns\n"
    if [ $# -eq 3 ] && [ $3 == "--nameonly" ]
    then
        kubectl get $RESOURCE -n $ns --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}';
    else
        kubectl get $RESOURCE -n $ns;
    fi
    if [ $RESOURCE == "pod" ] || [ $RESOURCE == "pods" ]
    then
        n=$(kubectl get pods -n $ns --field-selector=status.phase!=Succeeded,status.phase!=Failed --output json | jq -j '.items | length')
        tot=$((tot+n))
        printf "NUMBER OF PODS: $n pods\n" 
    fi
done

if [ $RESOURCE == "pod" ] || [ $RESOURCE == "pods" ]
then
    printf "=====\nTOTAL NUMBER OF PODS: $tot pods\n"
fi
