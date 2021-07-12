
This script demonstrates how to setup Duo MFA on Okta auth login in a namespace and in root namespace

# Pre-req
- Vault
- Duo account
- Okta account

# How to use this repo

1. export environment variables:

```

export INTEGRATION_KEY=Duo_integration_key
export SECRET_KEY=Duo_secret_key
export API_HOSTNAME=DUO_API

export Okta_TOKEN=YOUR_TOKEN

```

2. run script:

```

$./sc5.sh

```
