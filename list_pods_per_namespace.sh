for ns in $(kubectl get namespaces -l <key>=<value> --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
do
  printf "\nNAMESPACE: $ns\n"
  kubectl get pods -n $ns;
done
