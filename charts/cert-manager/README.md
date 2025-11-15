# Cert-Manager Helm Chart

Deploys cert-manager Issuers and Certificates for managing TLS certificates.

## Usage

```bash
helm lint charts/cert-manager
helm install cert-manager charts/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set-file values.yaml=your-values.yaml
```

## Configuration

See `values.yaml` for the complete list of tunables. Key options include:

### Issuers

- `issuers` – List of issuers to create
  - `name` – Name of the cert-manager Issuer/ClusterIssuer resource
  - `kind` – Either `Issuer` or `ClusterIssuer`
  - `namespace` – Namespace for Issuer (only used if kind is Issuer, defaults to Release.Namespace)
  - `environment` – Let's Encrypt environment: `"staging"` or `"production"` (defaults to staging)
  - `server` – Optional: Override ACME server URL (if not set, uses URL based on environment)
  - `email` – Email address for Let's Encrypt registration
  - `cloudflare.apiKey` – Cloudflare API token/key
  - `cloudflare.email` – Cloudflare account email
  - `domains` – List of DNS zones/domains to be managed by this issuer

### Certificates

- `certificates` – List of certificates to create
  - `name` – Certificate name (required)
  - `secretName` – Optional: Secret name to store the certificate (defaults to certificate name)
  - `issuerRef.kind` – Kind of issuer: `Issuer` or `ClusterIssuer`
  - `issuerRef.name` – Name of the issuer
  - `dnsNames` – List of DNS names for the certificate

## Example

```yaml
issuers:
  - name: letsencrypt-prod
    kind: ClusterIssuer
    environment: production
    email: admin@example.com
    cloudflare:
      apiKey: "${CLOUDFLARE_API_KEY}"
      email: admin@example.com
    domains:
      - example.com
      - "*.example.com"

certificates:
  - name: vpn-cert
    secretName: vpn-tls
    issuerRef:
      kind: ClusterIssuer
      name: letsencrypt-prod
    dnsNames:
      - vpn.example.com
```

## Resources Created

- **Secrets**: `cloudflare-creds-{issuer.name}` – Contains Cloudflare API credentials for each issuer
- **Issuers/ClusterIssuers**: `{issuer.name}` – cert-manager Issuer resources with Cloudflare DNS01 solver
- **Certificates**: `{certificate.name}` – cert-manager Certificate resources
- **Certificate Secrets**: `{secretName}` – Secrets containing TLS certificates (created by cert-manager)

The ACME private key secrets (`letsencrypt-{issuer.name}-acme-key`) will be automatically created by cert-manager.
