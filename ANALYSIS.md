# Docker/Podman Configuration Analysis for Ubuntu 24.04 WSL

## Critical Issues Found

### 1. ❌ **BLOCKING: .NET Dockerfile - Invalid Directory Structure**
**File:** `infra/dotnet/Dockerfile`

**Problem:**
```dockerfile
COPY ../apps/dotnet-service/MyApp/*.csproj ./MyApp/
WORKDIR /dotnet-services/MyApp  # ❌ Inconsistent path
RUN dotnet restore
COPY ../apps/dotnet-service/MyApp/. .
```

**Issues:**
- `WORKDIR /dotnet-services/MyApp` doesn't exist - docker/podman will create it, but .csproj files already copied to `./MyApp/`
- After WORKDIR change, relative paths are wrong
- `../apps/dotnet-service` directory is **EMPTY** in your workspace
- Project file: `../apps/dotnet-services/MyApp` (note: "services" vs "service")

**Fix:**
```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src

# Copy only project files first (better caching)
COPY ../apps/dotnet-services/MyApp/*.csproj ./
WORKDIR /src
RUN dotnet restore

# Copy rest of source
COPY ../apps/dotnet-services/MyApp/ .

RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0

WORKDIR /app
COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080

CMD ["dotnet", "MyApp.dll"]
```

---

### 2. ❌ **BLOCKING: Python Dockerfile - Invalid Path**
**File:** `infra/python/Dockerfile`

**Problem:**
```dockerfile
COPY ../apps/python-service/. .
```

**Issue:**
- Path references `python-service` (singular) but actual folder is likely `python-services` (plural)
- Directory structure has both `python-service/` and `python-services/` folders

**Fix:** (depends on which folder contains your app)
```dockerfile
# If using python-services:
COPY ../apps/python-services/. .
# OR if using python-service:
# Make sure python-service/ folder has app.py
```

---

### 3. ❌ **podman-compose.yml - Build Context Issues**

**Problem:**
All Dockerfiles use `../` relative paths, but podman-compose build context is set by `build:` directive.

```yaml
dotnet:
  build: ./dotnet  # Build context is ./infra/dotnet/
  # Dockerfile tries: ../apps/dotnet-services/MyApp
  # Relative to context: infra/dotnet/../apps/... ✓ (might work)
```

However, with `-f` flag in subdirectories, this can fail. The context path resolution varies.

**Recommendation:** Use explicit build context:
```yaml
dotnet:
  build:
    context: ..
    dockerfile: infra/dotnet/Dockerfile
```

---

### 4. ⚠️ **Health Checks - Potential Issues**

**nginx/Dockerfile:**
```dockerfile
CMD ["/wait-for-services.sh"]
```
- Missing `CMD ["nginx", "-g", "daemon off;"]` - script calls it, but good to have fallback

**Python healthcheck:**
```yaml
test: ["CMD", "curl", "-f", "http://localhost:5000"]
```
- ❌ Inside container, but app needs to be **running** and **responsive**
- FastAPI root `/` might not exist - should test specific endpoint

**Recommendation:**
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:5000/docs"]
  # OR check if app.py has a root endpoint
```

---

### 5. ⚠️ **podman-compose.yml - Port Mapping**

**Issue:** Nginx configured to listen on port 80 internally, mapped to 8080 externally.
```yaml
nginx:
  ports:
    - "8080:80"
```

**Check:** Your nginx config (`default.conf`) must listen on **80**, not 8080.
✓ Confirmed: `listen 80;` - This is correct.

---

### 6. ⚠️ **Network Issue - wait-for-services.sh**

**Current script uses port 9000 for PHP:**
```bash
while ! nc -z php 9000 2>/dev/null; do
```

**Check your setup:**
- PHP runs on port 9000 ✓ (default FPM port)
- But PHP FPM doesn't start with just `-t` test in healthcheck:
```yaml
healthcheck:
  test: ["CMD", "php-fpm", "-t"]  # ❌ Might not work
```

**Better health check:**
```yaml
healthcheck:
  test: ["CMD", "sh", "-c", "php-fpm -t && nc -w1 -z localhost 9000"]
  interval: 10s
  timeout: 5s
  retries: 3
```

---

## Summary of Changes Needed

| File | Issue | Severity | Fix |
|------|-------|----------|-----|
| `infra/dotnet/Dockerfile` | Wrong path + workdir mismatch | 🔴 Critical | Update path to `dotnet-services`, fix workdir logic |
| `infra/python/Dockerfile` | Wrong folder reference | 🔴 Critical | Verify folder name (services vs service) |
| `podman-compose.yml` | Build context paths | 🟡 Warning | Use explicit context path or fix relative paths |
| `infra/python/Dockerfile` | Healthcheck endpoint | 🟡 Warning | Test `/docs` or actual endpoint |
| `infra/php/Dockerfile` | Healthcheck command | 🟡 Warning | Improve health check for FPM |

---

## Recommended Fixes

### Fix 1: Update .NET Dockerfile
- Change `../apps/dotnet-service/` → `../apps/dotnet-services/`
- Remove confusing WORKDIR change
- Keep all copies in `/src`

### Fix 2: Update Python Dockerfile  
- Verify which folder exists (python-service vs python-services)
- Update COPY path accordingly

### Fix 3: Update podman-compose.yml Build Context (Optional but Recommended)
```yaml
services:
  dotnet:
    build:
      context: ..
      dockerfile: infra/dotnet/Dockerfile
    # ... rest of config
```

### Fix 4: Create Missing Source Files
Ensure these exist:
- `apps/python-services/app.py` (or python-service)
- `apps/php-services/` (has Laravel app)
- `apps/dotnet-services/MyApp/Program.cs` ✓ (confirmed exists)

---

## Testing Startup

Once fixed, run:
```bash
cd infra/
podman-compose down
podman-compose build
podman-compose up
```

Monitor for:
1. ✓ All images build without errors
2. ✓ Containers start in correct order
3. ✓ Health checks pass (green)
4. ✓ Services accessible via nginx proxy routes
5. ✓ No volume mount permission issues (WSL-specific)
