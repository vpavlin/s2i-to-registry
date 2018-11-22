# s2i-to-registry

**s2i to registry** tool allows you to simply move images described by image streams from OpenShift internal registry to any external registry (Quay.io by default).

## How to run

First apply the app template

```
oc apply -f openshift/template.yaml
```

For actual deployment you can go to your OpenShift Catalog, find `s2i-to-registry` there and use the wizard for deployment. Or you can do it from commandline

```
oc process s2i-to-registry -p REGISTRY_AUTH=<auth-token> -p REPOSITORY=<target-repository> -p REGISTRY=<registry> | oc apply -f -
```

where
* `REGISTRY_AUTH` is a token as found in `.docker/config.json`
* `REGISTRY` is registry URL - e.g. quay.io or docker.io
* `REPOSITORY` is name of repository in the registry - e.g. `vpavlin` in `quay.io/vpavlin`
* optional `QUAY_API_TOKEN` will make sure all newly created image repositories will be public (Quay.io creates them as private by default). This uses https://github.com/koudaiii/qucli. API token can be generated by following https://docs.quay.io/api/.



A job in OpenShift will be triggered and all your images in the namespace described by ImageStreams will be pushed to target registry.