# Install

```bash
docker-compose up -d
```

## Email

## Static logos / images


# Development

```bash
docker-compose -f docker-compose-dev.yml up -d
```
And go to http://localhost/ (auto reloaded with new builds).

See build issues
```bash
docker-compose -f docker-compose-dev.yml logs -f app
```

Check email: http://localhost/mail/