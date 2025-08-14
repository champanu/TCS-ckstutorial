# Multi-stage Docker Build – Guide with Scenario

## 1. Introduction

**Multi-stage builds** in Docker allow you to:
- Use multiple `FROM` statements in one `Dockerfile`.
- Copy only the needed artifacts into the final image.
- Reduce **final image size**.
- Avoid shipping build tools and unnecessary dependencies.

---

## 2. Basic Structure

```dockerfile
# Stage 1: Build
FROM golang:1.22 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp main.go

# Stage 2: Runtime
FROM alpine:3.20
WORKDIR /app
COPY --from=builder /app/myapp .
CMD ["./myapp"]
````

---

## 3. Scenario – Go Web App

**Project Structure**

```
myapp/
 ├── main.go
 └── Dockerfile
```

**main.go**

```go
package main
import (
    "fmt"
    "net/http"
)
func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello from multi-stage build!")
}
func main() {
    http.HandleFunc("/", handler)
    http.ListenAndServe(":8080", nil)
}
```

---

### Step 1 – Multi-stage Dockerfile

```dockerfile
# Stage 1: Build
FROM golang:1.22 AS builder
WORKDIR /src
COPY . .
RUN go build -o server main.go

# Stage 2: Runtime
FROM alpine:3.20
WORKDIR /app
COPY --from=builder /src/server .
EXPOSE 8080
CMD ["./server"]
```

---

### Step 2 – Build & Run

```bash
docker build -t go-multi-stage .
docker run -d -p 8080:8080 go-multi-stage
```

Test:

```bash
curl http://localhost:8080
# Hello from multi-stage build!
```

---

## 4. Benefits

* **Size Reduction**
  Example:

  ```bash
  docker images go-multi-stage
  ```

  * Without multi-stage: \~800MB (full Go toolchain included).
  * With multi-stage: \~15MB (only compiled binary + minimal Alpine base).

* **Security**

  * Build tools are **not present** in runtime image → reduces attack surface.
  * Final image contains only what's needed for execution.

* **Performance**

  * Smaller images → faster deploys, pulls, and startups.

---

## 5. Advanced Example – Node.js with Builder Cache

```dockerfile
# Stage 1: Builder
FROM node:20 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:20-slim
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY package*.json ./
RUN npm ci --only=production
CMD ["node", "dist/index.js"]
```

---

## 6. Best Practices

* **Name stages** (`AS builder`) for clarity.
* Use **small base images** in the final stage (`alpine`, `distroless`).
* Copy only what’s needed (`COPY --from`).
* Use **build cache** for faster builds (copy dependency files first).
* For security, run as a **non-root** user in the final stage.

