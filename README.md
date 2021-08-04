# Build ECR image action

This action will build an image and upload it to the respective ECR repository.

## Env var needs

- AWS_REGION

- AWS_ACCOUNT


## Example usage

```
on: [push]

jobs:
  build:
    runs-on: self-hosted
    name: Build
    env:
      AWS_ACCOUNT: <AWS ACCOUNT ID>
      AWS_REGION: <AWS REGION>
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Build/publish image to AWS ECR
        uses: nicolasdonoso/build-action@v1.0
      
```