# Setup
```shell
export NOMAD_ADDR=<NOMAD_ADDR>

# If bootstrapped
export NOMAD_TOKEN=<TOKEN>
```

# Job Plan
```shell
nomad job plan tetris.nomad
```

# Run Nomad Job
```shell
nomad job run tetris.nomad
```

# Check Job Status
```shell
nomad job status tetris
```