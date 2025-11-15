# charts

Helm chart collection with GitHub Actions–driven linting and publishing.

## Repository layout

- `charts/<name>` – individual charts (currently `zerotier` and `openconnect`)
- `dist/` – local build artifacts (`helm package` output, ignored by git)
- `.github/workflows/helm.yaml` – CI lint/package on PRs
- `.github/workflows/release.yaml` – packages + publishes charts to GitHub Pages via chart-releaser

## CI/CD workflows

1. **helm.yaml** – runs on pushes/PRs touching `charts/**`. It installs Helm, lints `charts/zerotier`, builds dependencies (if any), and packages into `dist/` for inspection or manual download.
2. **release.yaml** – runs when you publish a GitHub Release. It lints every chart under `charts/`, then invokes [`helm/chart-releaser-action`](https://github.com/helm/chart-releaser-action) to:
   - Package changed charts
   - Upload `.tgz` files to the Release assets
   - Regenerate `index.yaml` on the `gh-pages` branch so the repo can be consumed as a Helm repository

Both workflows reuse Helm v3.14.4 for consistency.

## Publishing “by the book”

1. **Enable GitHub Pages**
   - Create an empty `gh-pages` branch once (`git checkout --orphan gh-pages && git commit --allow-empty -m "init gh-pages" && git push origin gh-pages`).
   - In repo settings → Pages, select the `gh-pages` branch and `/` root.
2. **Prepare a release**
   - Bump the chart version in `charts/<name>/Chart.yaml`.
   - Commit/tag your work; tags normally follow `<chart>-<version>` (for example `zerotier-0.1.0`) so releases map cleanly to chart versions.
3. **Publish**
   - Draft a GitHub Release with the matching tag and click _Publish_.
   - The `Release Charts` workflow packages only the charts that changed since the previous release and updates the Pages-backed index automatically.
4. **Consume the repo**
   ```bash
   helm repo add personal https://<github-username>.github.io/charts
   helm repo update
   helm install homenet personal/zerotier --version 0.1.0
   ```

With this setup, additional charts can live under `charts/` and will join the repo automatically as long as their versions change before publishing.
