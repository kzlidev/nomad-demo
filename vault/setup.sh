export VAULT_TOKEN=<VAULT_TOKEN>
export VAULT_ADDR=<VAULT_ADDR>
export VAULT_NAMESPACE=admin
export VAULT_FORMAT="json"
export COMMON_NAME="global.nomad"
export CLIENT_COMMON_NAME="client.global.nomad"
export SERVER_COMMON_NAME="server.global.nomad"
export PKI_PATH="nomad-pki"

# Enable PKI
vault secrets enable -path=$PKI_PATH pki

# Update the CRL location and issuing certificates
vault write $PKI_PATH/config/urls \
    issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
    crl_distribution_points="$VAULT_ADDR/v1/pki/crl"

# Configure CA certificate and private key
vault write $PKI_PATH/root/generate/internal \
    common_name=$COMMON_NAME \
    ttl=8760h

# Configure a role that maps a name in Vault to a procedure for generating a certificate
vault write $PKI_PATH/roles/my-demo \
    allowed_domains=$COMMON_NAME \
    allow_subdomains=true

# Generate a new credential for client
vault write $PKI_PATH/issue/my-demo \
      common_name=$CLIENT_COMMON_NAME \
      ttl="100h" \
      ip_sans="127.0.0.1" alt_names="localhost" > client-response.json

export CA_CHAIN=$(cat client-response.json | jq -r '.data.ca_chain[0]')
export PRIVATE_KEY=$(cat client-response.json | jq -r '.data.private_key')
export CERTIFICATE=$(cat client-response.json | jq -r '.data.certificate')

echo $CA_CHAIN > ../platform/certs/ca.crt
echo $PRIVATE_KEY > ../platform/certs/nomad-client.key
echo $CERTIFICATE > ../platform/certs/nomad-client.crt

rm client-response.json

# Generate a new credential
vault write $PKI_PATH/issue/my-demo \
      common_name=$SERVER_COMMON_NAME \
      ttl="100h" \
      ip_sans="127.0.0.1" alt_names="localhost" > server-response.json

export PRIVATE_KEY=$(cat server-response.json | jq -r '.data.private_key')
export CERTIFICATE=$(cat server-response.json | jq -r '.data.certificate')

echo $PRIVATE_KEY > ../platform/certs/nomad-server.key
echo $CERTIFICATE > ../platform/certs/nomad-server.crt

rm server-response.json