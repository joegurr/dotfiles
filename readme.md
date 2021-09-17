# Useful Docker Commands

docker container run -d -it --name postgres -e POSTGRES_PASSWORD=password -v ~/docker-volumes/postgres/data:/var/lib/postgresql/data -p 5432:5432 postgres:11

docker container run --name redis -d -v /docker-volumes/redis/data:/data -p 6379:6379 redis:5.0.7 redis-server --appendonly yes