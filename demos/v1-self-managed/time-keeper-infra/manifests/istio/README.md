## Folder Description

This folder contains manifests that install and configure IstioD within the GKE Cluster

### Notes

- The Istio namespace (istio-system by default) must be created manually as we are deploying Istio without the use of the CLI.
- The manifests relating to [IstioD](https://istio.io/latest/) were generated using the "[istioctl](https://istio.io/latest/docs/setup/install/istioctl/)" cli tool in an [offline mode](https://istio.io/latest/docs/setup/install/istioctl/#generate-a-manifest-before-installation).  


### Modifications to Standard Install

Istio By Default installs a External Load Balancer in Google Cloud for the "istio-ingressgateway" Service.

Modifications to this service were made to change the LoadBalancer type specifically create an internal TCP Load Balancer. 

This was completed by adding the annotation: ```networking.gke.io/load-balancer-type: "Internal"```

```
apiVersion: v1
kind: Service
metadata:
  name: istio-ingressgateway
  namespace: istio-system
  annotations:
    networking.gke.io/load-balancer-type: "Internal"
  labels:
    app: istio-ingressgateway
    istio: ingressgateway
    release: istio
    istio.io/rev: default
    install.operator.istio.io/owning-resource: unknown
    operator.istio.io/component: "IngressGateways"
spec:
  type: LoadBalancer
  selector:
    app: istio-ingressgateway
    istio: ingressgateway
  ports:
    -
      name: status-port
      port: 15021
      protocol: TCP
      targetPort: 15021
    -
      name: http2
      port: 80
      protocol: TCP
      targetPort: 8080
    -
      name: https
      port: 443
      protocol: TCP
      targetPort: 8443
```