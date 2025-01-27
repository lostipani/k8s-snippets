LABEL=
tot=0
for ns in $(kubectl get namespaces -l <label>=$LABEL --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
  do 
  n=$(kubectl get pods -n $ns --field-selector=status.phase!=Succeeded,status.phase!=Failed --output json | jq -j '.items | length')
  tot=$((tot+n))
  echo "$ns: $n pods"
done
echo "Total: $tot pods";
