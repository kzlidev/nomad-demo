#!/bin/bash
# This script is used to add a trusted, private CA certificate to an OS's certificate store. This allows you to
# establish TLS connections to services that use TLS certs signed by that CA without getting x509 certificate errors.
# This script has been tested with the following operating systems:
#
# 1. Ubuntu 16.04
# 2. Ubuntu 18.04
# 3. Amazon Linux 2

set -e

readonly DEFAULT_DEST_FILE_NAME="custom.crt"

readonly UPDATE_CA_CERTS_PATH="/usr/local/share/ca-certificates"
readonly UPDATE_CA_TRUST_PATH="/etc/pki/ca-trust/source/anchors"

readonly SCRIPT_NAME="$(basename "$0")"

function print_usage {
  echo
  echo "Usage: update-certificate-store [OPTIONS]"
  echo
  echo "Add a trusted, private CA certificate to an OS's certificate store. This script has been tested with Ubuntu 16.04 and Amazon Linux 2."
  echo
  echo "Options:"
  echo
  echo -e "  --cert-file-path\tThe path to the CA certificate public key to add to the OS certificate store. Required."
  echo -e "  --dest-file-name\tCopy --cert-file-path to a file with this name in a shared cert folder. The extension MUST be .crt. Optional. Default: $DEFAULT_DEST_FILE_NAME."
  echo
  echo "Example:"
  echo
  echo "  update-certificate-store --cert-file /opt/vault/tls/ca.crt.pem"
}

function log {
  local -r level="$1"
  local -r message="$2"
  local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  >&2 echo -e "${timestamp} [${level}] [$SCRIPT_NAME] ${message}"
}

function log_info {
  local -r message="$1"
  log "INFO" "$message"
}

function log_warn {
  local -r message="$1"
  log "WARN" "$message"
}

function log_error {
  local -r message="$1"
  log "ERROR" "$message"
}

function command_exists {
  local -r command_name="$1"
  [[ -n "$(command -v $command_name)" ]]
}

function update_certificate_store {
  local -r cert_file_path="$1"
  local -r dest_file_name="$2"

  log_info "Adding CA public key $cert_file_path to OS certificate store"

  if $(command_exists "update-ca-certificates"); then
    cp "$cert_file_path" "$UPDATE_CA_CERTS_PATH/$dest_file_name"
    update-ca-certificates
  elif $(command_exists "update-ca-trust"); then
    update-ca-trust enable
    cp "$cert_file_path" "$UPDATE_CA_TRUST_PATH/$dest_file_name"
    update-ca-trust extract
  else
    log_warn "Did not find the update-ca-certificates or update-ca-trust commands. Cannot update OS certificate store."
  fi
}

function assert_not_empty {
  local -r arg_name="$1"
  local -r arg_value="$2"

  if [[ -z "$arg_value" ]]; then
    log_error "The value for '$arg_name' cannot be empty"
    print_usage
    exit 1
  fi
}

function update {
  local cert_file_path
  local dest_file_name="$DEFAULT_DEST_FILE_NAME"

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --cert-file-path)
        cert_file_path="$2"
        shift
        ;;
      --dest-file-name)
        dest_file_name="$2"
        shift
        ;;
      --help)
        print_usage
        exit
        ;;
      *)
        log_error "Unrecognized argument: $key"
        print_usage
        exit 1
        ;;
    esac

    shift
  done

  assert_not_empty "--cert-file-path" "$cert_file_path"
  assert_not_empty "--dest-file-name" "$dest_file_name"

  update_certificate_store "$cert_file_path" "$dest_file_name"
}

update "$@"