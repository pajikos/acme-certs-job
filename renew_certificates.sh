#!/usr/bin/env bash

# Load configuration from file
declare -A CERT_CONFIG
while IFS='=' read -r domain namespaces; do
  CERT_CONFIG["$domain"]="$namespaces"
done < /app/domains.config

# Set environment variables for Lego
export LEGO_EMAIL="${LEGO_EMAIL}"
export WEDOS_USERNAME="${WEDOS_USERNAME}"
export WEDOS_WAPI_PASSWORD="${WEDOS_WAPI_PASSWORD}"
export WEDOS_TTL="${WEDOS_TTL}"
export WEDOS_POLLING_INTERVAL="${WEDOS_POLLING_INTERVAL}"
export WEDOS_PROPAGATION_TIMEOUT="${WEDOS_PROPAGATION_TIMEOUT}"

LEGO_CMD="/lego"
LEGO_PATH="./lego-files"

# Loop through the domain configurations
for domain in "${!CERT_CONFIG[@]}"; do
  namespaces="${CERT_CONFIG[$domain]}"
  IFS=',' read -ra namespace_arr <<< "$namespaces"
  secret_name="${domain//./-}"
  secret_name="${secret_name//\*/star}-tls"

  file_domain="${domain//\*/_}"

  if [ -f "${LEGO_PATH}/certificates/${file_domain}.crt" ]; then
    ${LEGO_CMD} --email="${LEGO_EMAIL}" --dns="wedos" --domains="${domain}" --path="${LEGO_PATH}" --accept-tos renew
    if [ $? -ne 0 ]; then
        echo "Error renewing certificate for ${domain}. Skipping to next domain."
        continue
    fi
  else
    echo "Certificate file for ${domain} not found in ${LEGO_PATH}/certificates. Generating new certificate instead."
    ${LEGO_CMD} --email="${LEGO_EMAIL}" --dns="wedos" --domains="${domain}" --path="${LEGO_PATH}" --accept-tos run
    if [ $? -ne 0 ]; then
        echo "Error generating certificate for ${domain}. Skipping to next domain."
        continue
    fi
  fi

  openssl x509 -in "${LEGO_PATH}/certificates/${file_domain}.crt" -noout
  if [ $? -ne 0 ]; then
      echo "Generated certificate for ${domain} is not valid. Skipping to next domain."
      continue
  fi

  echo "Creating Kubernetes secret for ${domain} in ${namespaces} namespace"
  for namespace in "${namespace_arr[@]}"; do
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: "${secret_name}"
  namespace: "${namespace}"
type: kubernetes.io/tls
data:
  tls.crt: "$(base64 < "${LEGO_PATH}/certificates/${file_domain}.crt" | tr -d '\n')"
  tls.key: "$(base64 < "${LEGO_PATH}/certificates/${file_domain}.key" | tr -d '\n')"
EOF
    if [ $? -ne 0 ]; then
        echo "Error creating Kubernetes secret for ${domain} in ${namespace}. Continuing with next namespace/domain."
    fi
  done
done
