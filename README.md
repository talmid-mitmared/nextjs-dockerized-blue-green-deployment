


https://github.com/user-attachments/assets/206bf346-6ddc-4bf4-950e-7626c0c2fde6


# Blue-Green Deployment with Docker + Nginx

This project is just testing a simple blue-green deployment for a static Next.js frontend.


The idea is:
Do not replace the live app directly.
Run the new version beside the old version.
Then switch traffic at the proxy layer.

<img width="1043" height="793" alt="image" src="https://github.com/user-attachments/assets/1e3f4a13-9805-46f8-9769-2b4968ea6736" />


<img width="1043" height="793" alt="image" src="https://github.com/user-attachments/assets/00094aa6-33d3-4813-beac-b2284770470b" />


### 1. Motivations: Why I Built This Repository

#### a. I had to study Docker because of work, so that was the main motivation.

#### b. I also tried to think about a restricted, hypothetical situation.

What if there was no Vercel, and no AWS infrastructure already prepared for deployment?

Something like: If...I’m in 2001, I don’t have much time, but I still need to make a deployment strategy as fast as possible.

The problem was that every time we deployed, users who were still using the previous version could get a bunch of errors, like missing pages or broken requests.

#### c. I also care about money. I’ve founded a company before, so I know infra is basically money. One server is money. More servers means more cost.

So I started thinking: what if we treat containers like servers, instead of only thinking about physical servers?

That idea came from this Google paper: https://storage.googleapis.com/gweb-research2023-media/pubtools/4449.pdf





### 2. Architecture

User
  ↓
Proxy Nginx
  ↓
blue-web OR green-web
  ↓
Static Next.js export served by Nginx

There are three runtime services:
proxy      = public reverse proxy
blue-web   = one app slot
green-web  = another app slot

Only `proxy` is exposed publicly.
`blue-web` and `green-web` are reachable only inside the Docker network.


### 3. How It Works

`blue-web` and `green-web` run different versions of the same app.

Example:

```txt
blue-web  = v1.0.0
green-web = v1.0.1
```

The proxy decides which one receives traffic:

```nginx
proxy_pass http://blue-web:8080;
```

To switch traffic:

```nginx
proxy_pass http://green-web:8080;
```

Then reload Nginx:

```bash
docker compose exec proxy nginx -s reload
```

If the new version fails, switch the proxy back to the old slot.


---

### 4. Appendix

#### Docker Resource Allocation in Blue-Green Deployment

##### Q. If we run two Docker containers on a single server, do we need to reserve only half of the server resources for the active container?
##### A. Not necessarily.

In a blue-green deployment setup, we may temporarily run two versions of the server on the same host: for example, `blue` and `green`. External traffic is routed only to the active version, while the inactive version stays idle or receives little to no traffic.

However, running two Docker containers does not automatically split the host machine’s CPU or memory equally between them.

Docker containers run on top of the host OS kernel. Containers are isolated using Linux namespaces and cgroups, but resources are not automatically divided like this:

```text
total server resources / number of containers
```

Instead, actual CPU and memory usage depends on the processes running inside each container and the traffic they receive.

So, simply having two containers does not mean each container automatically gets only 50% of the server resources.

#### Q. How can we control this?
#### A. Maybe via resource constraints on Container

Docker provides resource constraint options for containers, such as memory limits and CPU limits.

For example, if the inactive `blue` or `green` container is not receiving traffic, we can keep it running with minimal resource usage, or explicitly limit its resource allocation.

This means the active container can still use most of the server resources in normal operation, while the inactive container remains available for deployment or rollback purposes.

Reference:
https://docs.docker.com/engine/containers/resource_constraints/


