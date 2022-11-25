## Folder Description

This folder contains manifests that install and configure IstioD within the GKE Cluster

### Notes

- The Istio namespace (istio-system by default) must be created manually as we are deploying Istio without the use of the CLI.
- The manifests relating to [IstioD](https://istio.io/latest/) were generated using the "[istioctl](https://istio.io/latest/docs/setup/install/istioctl/)" cli tool in an [offline mode](https://istio.io/latest/docs/setup/install/istioctl/#generate-a-manifest-before-installation).  