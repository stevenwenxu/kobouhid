# Kobo Clara BW UHID Kernel Module

This repository provides a minimal Docker-based build setup and GitHub Actions workflow to cross-compile the UHID kernel module (`uhid.ko`) for the Kobo Clara BW e-reader.

This was partially vibe coded based on the instructions in [this repository](https://github.com/jmacindoe/kobo-kernel-modules/tree/main), and [this repository](https://github.com/tylpk1216/kobo-libra2-uhid-module) with goose and gpt-4o.

## Contents

- `Dockerfile` - builds an Ubuntu 22.04 image, fetches the Kobo Clara 2E kernel source, applies small patch fixes, and compiles only the HID subsystem modules.
- `.github/workflows/build.yml` - GitHub Actions workflow that builds the Docker image, extracts `uhid.ko`, and uploads it as an artifact.
- `config` - the kernel configuration used on the device (uncompressed).

## Usage

### Locally with Docker

```bash
# Clone this repo
git clone https://github.com/yourusername/kobo-kernel-uhid.git
cd kobo-kernel-uhid

# Build the Docker image
docker build -t kobo-hid-builder .

# Run the container and extract uhid.ko
docker create --name extract kobo-hid-builder
docker cp extract:/build/output/uhid.ko ./uhid.ko
docker rm extract

# Now you can deploy uhid.ko to your Kobo (e.g., via SSH + scp)
```

### GitHub Actions

On every push to `main` (and on PRs), the `Build UHID Module` workflow runs and produces an `uhid-module` artifact containing `uhid.ko`.

To view/download the artifact:

**Downloading Artifacts**

1. Go to the **Actions** tab at the top of the repository.
2. Select the latest **Build UHID Module** run.
3. In the right sidebar under **Artifacts**, click on **uhid-module**.
4. Download the `uhid.ko` file from the artifact.



## License

This repository (**excluding** the original Linux kernel source) is licensed under the GNU General Public License v2.0 (GPL-2.0-only).

The patches applied to the upstream kernel are small fixes to allow cross-compilation; the resulting modules are derived works of the Linux kernel, which is itself licensed under GPL-2.0-only.

See the [LICENSE](LICENSE) file for full details.
