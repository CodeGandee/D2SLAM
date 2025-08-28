# JetPack 6.2 Migration Guide

## 📂 Files Moved to `jetpack62/` Subdirectory

The following JetPack 6.2 related files have been reorganized into the `jetpack62/` subdirectory for better management:

### Removed Files (now in `jetpack62/`):
- ❌ `build_jetpack62.sh` → ✅ `jetpack62/quickstart.sh` or `jetpack62/manage.sh`
- ❌ `README_JETPACK62.md` → ✅ `jetpack62/README.md` (comprehensive guide)
- ❌ `VERIFICATION_JETPACK62.md` → ✅ `jetpack62/README.md` (includes verification info)
- ❌ `Dockerfile.jetson_orin_jetpack62` → ✅ `jetpack62/docker-compose.yml` (better approach)

### What to Use Instead:

#### Old Way:
```bash
./build_jetpack62.sh
```

#### New Way:
```bash
cd jetpack62
./quickstart.sh           # Quick setup
# OR
./manage.sh help          # Full options
```

### Benefits of New Organization:

1. **Docker Compose**: Better container orchestration
2. **Multiple Build Options**: Full, minimal, and development builds
3. **Management Scripts**: Comprehensive tooling for build/run/debug
4. **Development Tools**: Built-in development utilities
5. **Better Documentation**: Organized guides and troubleshooting
6. **Validation**: Built-in setup validation

### Quick Migration:

If you were using the old build process:

```bash
# Old process
./build_jetpack62.sh

# New process
cd jetpack62
./quickstart.sh
```

### For Advanced Users:

```bash
cd jetpack62
./manage.sh build d2slam-minimal    # Build minimal version
./manage.sh up d2slam-dev          # Start development container
./manage.sh exec d2slam-dev        # Enter container
./validate.sh                      # Validate setup
```

The new organization provides much better developer experience and maintainability!
