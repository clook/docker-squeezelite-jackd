# docker-squeezelite-jackd

Squeezelite with jackd Dockerfile, Alpine flavour.

## Usage

### Kubernetes

**Warning! The default user for this container is root. Run at your own risk!**

```
kubectl apply -f << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: squeezelite-jackd
    node: speakers
  name: squeezelite-jackd-speakers
spec:
  replicas: 1
  selector:
    matchLabels:
      app: squeezelite-jackd
      node: speakers
  template:
    metadata:
      labels:
        app: squeezelite-jackd
        node: speakers
    spec:
      containers:
      - image: clook/squeezelite-jackd:1.9-alpine
        env:
        - name: SOUNDDEVICE
          value: hw:0
        - name: CLIENTNAME
          value: Speakers
        - name: SERVER
          value: 10.0.0.5
	- name: JACK_NO_AUDIO_RESERVATION
	  value: "1"
        name: squeezelite-jackd
        command: ["sh"]
	args: ['-c', 'tail -f /dev/null']
        securityContext:
          privileged: true
        volumeMounts:
        - mountPath: /dev/shm
          name: dshm
      tolerations:
      - key: "role"
        operator: "Equal"
        value: "speakers"
        effect: "NoSchedule"
      nodeSelector:
        kubernetes.io/hostname: speakers
      volumes:
      - name: dshm
      	emptyDir:
	  medium: Memory
```


## TODO

Non-root user, entrypoint with a JACK session manager
