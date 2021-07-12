# this script demonstrates Duo MFA on okta auth login in root and namespace as in Ticket 

vault server -dev -dev-root-token-id="root" -log-level=TRACE&

set -aex

sleep 2

export VAULT_ADDR='http://127.0.0.1:8200'

vault auth enable okta

vault auth list -format=json | jq -r '.["okta/"].accessor' > accessor.txt

vault write sys/mfa/method/duo/vault_ent_duodev \
mount_accessor=$(cat accessor.txt) \
integration_key=$INTEGRATION_KEY \
secret_key=$SECRET_KEY \
api_hostname=$API_HOSTNAME

vault write auth/okta/config base_url="okta.com" organization="dev-69938356" token="$Okta_TOKEN"


cat > policy.sentinel <<EOF
import "mfa"
import "strings"
 
# Require Duo MFA validation to login via LDAP
duo_valid = rule {
    mfa.methods.vault_ent_duodev.valid
}
 
main = rule when strings.has_prefix(request.path, "auth/okta/login/") {
    duo_valid
}
EOF

POLICY=$(base64 policy.sentinel)

vault write sys/policies/egp/vault_ent_duodev \
        policy="${POLICY}" \
        paths="auth/okta/login/*" \
        enforcement_level="hard-mandatory"


vault login -method=okta username=sandynelax password=Test!1!2!3



vault login root

vault namespace create ns1

vault auth enable -namespace=ns1 okta

vault auth list -namespace=ns1 -format=json | jq -r '.["okta/"].accessor' > accessor2.txt


vault write sys/mfa/method/duo/vault_ent_duodev2 \
mount_accessor=$(cat accessor2.txt) \
integration_key=$INTEGRATION_KEY \
secret_key=$SECRET_KEY \
api_hostname=$API_HOSTNAME

vault write -namespace=ns1 auth/okta/config base_url="okta.com" organization="dev-69938356" token="$Okta_TOKEN"


cat > policy.sentinel <<EOF
import "mfa"
import "strings"
 
# Require Duo MFA validation to login via LDAP
duo_valid = rule {
    mfa.methods.vault_ent_duodev2.valid
}
 
main = rule when strings.has_prefix(request.path, "auth/okta/login/") {
    duo_valid
}
EOF

POLICY=$(base64 policy.sentinel)

vault write -namespace=ns1 sys/policies/egp/vault_ent_duodev2 \
        policy="${POLICY}" \
        paths="auth/okta/login/*" \
        enforcement_level="hard-mandatory"

vault login -namespace=ns1 -method=okta username=sandynelax password=Test!1!2!3
