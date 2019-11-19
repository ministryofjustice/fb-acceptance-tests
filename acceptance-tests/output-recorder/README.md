# Output recorder uses Wiremock 

- You can use the admin api to make assertions in your tests
http://wiremock.org/docs/api/

## Stub a new endpoint
Create a new file ending with .json in the `mappings` directory
```json
{
    "request": {
        "method": "GET",
        "url": "/some/thing"
    },
    "response": {
        "status": 200,
        "body": "Hello world!",
        "headers": {
            "Content-Type": "text/plain"
        }
    }
}
```

## Get calls to that endpoint
- view current mappings
```bash
curl localhost:3003/__admin/mappings 
```

- Get the requests of the above endpoint
```bash
curl -X POST localhost:3003/__admin/requests/find --data '{"method": "GET", "url": "/some/thing" }' 
```

- Reset recorded requests
```
curl -X POST localhost:3003/__admin/requests/reset
```

 - See http://wiremock.org/docs/api/ for more