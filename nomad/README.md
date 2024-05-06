# Setup
```shell
export NOMAD_ADDR=<NOMAD_ADDR>:4646

# If bootstrapped
export NOMAD_TOKEN=<TOKEN>

# Currently the certificate that is created points to only 127.0.0.1
export NOMAD_SKIP_VERIFY=true
```

# Job Plan
```shell
nomad job plan webapp.nomad
```

# Run Nomad Job
```shell
nomad job run webapp.nomad
```

# Check Job Status
```shell
nomad job status tetris
```

# Stop jobs
```shell
nomad stop job tetris
```

# To access a container
```shell
nomad alloc exec <alloc_id> /bin/bash
```

# View system logs 
If there are problems with Nomad
```shell
journalctl -b -u nomad
```
We can also access the logs through the path specified in the agent config file. 

# View Metrics using API 
```shell
curl <nomad_url>/v1/metrics | jq
```

# Application Logs
All logs are written to `<path>/data/alloc/<task>/alloc/logs/<stdout/stderr>.index`
```shell
nomad alloc logs <alloc_id>
```