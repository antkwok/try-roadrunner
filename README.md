# Web Api BFF

## For Docker Development Environment
```bash
# cp the example .env, and change the content inside the .env files.
cp .env.example .env

# for build and recreate
docker-compose up --build --force-recreate --no-deps -d

# for down, it will destroy all container, but the volume still exist
docker-compose down
```

## For Docker Production Image build and push
```bash
# 1. docker build Production
#docker build -f Prod.Dockerfile -t prod/web-api-bff .
#docker build -f Prod.Dockerfile -t testing/web-api-bff .
docker build -f Prod.Dockerfile -t web-api-bff .

# 2. Log on to an instance of Container Registry Enterprise Edition
docker login --username=[your username] singtao-registry.cn-hongkong.cr.aliyuncs.com

# 3. Push image to the registry
docker login --username=[your username] singtao-registry.cn-hongkong.cr.aliyuncs.com
docker tag [ImageId] singtao-registry.cn-hongkong.cr.aliyuncs.com/testing/web-api-bff:[tag]
docker push singtao-registry.cn-hongkong.cr.aliyuncs.com/testing/web-api-bff:[tag]
```

## For Minikube only
```bash
# update the cache 
minikube cache list

# delete 
minikube cache delete {{web-api-bff:1.0}}

# add
minikube cache add {{web-api-bff:1.0}}
```

## For K8S deployment and volume creation
```bash
# 1. Create deployment (create pod)
kubectl apply -f ./k8s/1-deploy.yml
# 2. Create service
kubectl apply -f ./k8s/2-service.yml
# 3. Create ingress
kubectl apply -f ./k8s/3-ingress.yml
```

## For Operation Team
```bash
# for update Menu Drawer Table like SW-356
php artisan db:seed --class=MenuTableSeeder

php artisan db:seed --class=MenuDrawerTableSeeder

php artisan db:seed --class=TvMenuTableSeeder

php artisan db:seed --class=PlusMenuTableSeeder

# DONT RUN IN PRODUCTION!!!!
php artisan db:seed --class=TvZoneTableSeeder  

php artisan db:seed --class=TuesdayRewardSettingsTableSeeder
```


## License

The Lumen framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
