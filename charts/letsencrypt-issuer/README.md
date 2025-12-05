# Let's Encrypt Issuer Helm Chart

Deploys a cert-manager Issuer for Let's Encrypt with Cloudflare DNS01 solver.

## Usage

```bash
helm lint charts/letsencrypt-issuer
helm install staging charts/letsencrypt-issuer \
  --namespace cert-manager \
  --create-namespace \
  --set issuer.name=staging \
  --set issuer.environment=staging \
  --set certManager.email=admin@example.com \
  --set certManager.cloudflare.apiKey="${CLOUDFLARE_API_KEY}" \
  --set certManager.cloudflare.email=admin@example.com \
  --set domains[0]=example.com \
  --set domains[1]="*.example.com"
```

## Configuration

See `values.yaml` for the complete list of tunables. Key options include:

- `issuer.name` – Name of the cert-manager Issuer resource
- `issuer.environment` – Let's Encrypt environment: `"staging"` or `"production"` (defaults to staging)
- `issuer.server` – Optional: Override ACME server URL (if not set, uses URL based on environment)
- `certManager.email` – Email address for Let's Encrypt registration
- `certManager.cloudflare.apiKey` – Cloudflare API token/key
- `certManager.cloudflare.email` – Cloudflare account email
- `domains` – List of DNS zones/domains to be managed by this issuer

## Resources Created

- **Secret**: `cloudflare-creds-{issuer.name}` – Contains Cloudflare API credentials
- **Issuer**: `{issuer.name}` – cert-manager Issuer resource with Cloudflare DNS01 solver

The ACME private key secret (`letsencrypt-{issuer.name}-acme-key`) will be automatically created by cert-manager.

