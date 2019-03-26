# Install

```bash
docker-compose up -d
```

## Email

## Static logos / images


# Development

```bash
docker-compose -f docker-compose-dev.yml up -d
docker-compose -f docker-compose-dev.yml stop build-static
```
And go to http://localhost/ (auto reloaded with new builds).

If `build-static` is started, it will run a sapper export if `build_static` is touched, and switch nginx to use static instead of the node container.

See build issues
```bash
docker-compose -f docker-compose-dev.yml logs -f app
```

Check email: http://localhost/mail/