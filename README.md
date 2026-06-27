


https://github.com/user-attachments/assets/206bf346-6ddc-4bf4-950e-7626c0c2fde6


# Blue-Green Deployment with Docker + Nginx

This project is just testing a simple blue-green deployment for a static Next.js frontend.


The idea is:
Do not replace the live app directly.
Run the new version beside the old version.
Then switch traffic at the proxy layer.

<img width="1043" height="793" alt="image" src="https://github.com/user-attachments/assets/1e3f4a13-9805-46f8-9769-2b4968ea6736" />


<img width="1043" height="793" alt="image" src="https://github.com/user-attachments/assets/00094aa6-33d3-4813-beac-b2284770470b" />



---

## Architecture

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

---

## How It Works

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

