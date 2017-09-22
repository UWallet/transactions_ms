docker-compose build
docker-compose run --rm transactions_ms rails db:create
docker-compose run --rm transactions_ms rails db:migrate
docker-compose up
