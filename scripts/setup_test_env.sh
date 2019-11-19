set -ex

# adds a test token to use in end to end test
docker-compose exec service-token-cache-app sh -c "rails runner \"Support::ServiceTokenCache.put('slug', 'token-for-slug')\""

docker-compose exec localstack sh -c "AWS_ACCESS_KEY_ID=qwerty AWS_SECRET_KEY=qwerty AWS_SECRET_ACCESS_KEY=qwerty aws --endpoint-url=http://localhost:4572 s3 mb s3://filestore-bucket"
docker-compose exec localstack sh -c "AWS_ACCESS_KEY_ID=qwerty AWS_SECRET_KEY=qwerty AWS_SECRET_ACCESS_KEY=qwerty aws --endpoint-url=http://localhost:4572 s3api put-bucket-acl --bucket filestore-bucket --acl public-read"
docker-compose exec localstack sh -c "AWS_ACCESS_KEY_ID=qwerty AWS_SECRET_KEY=qwerty AWS_SECRET_ACCESS_KEY=qwerty aws --endpoint-url=http://localhost:4572 s3 mb s3://external-filestore-bucket"
docker-compose exec localstack sh -c "AWS_ACCESS_KEY_ID=qwerty AWS_SECRET_KEY=qwerty AWS_SECRET_ACCESS_KEY=qwerty aws --endpoint-url=http://localhost:4572 s3api put-bucket-acl --bucket external-filestore-bucket --acl public-read"
