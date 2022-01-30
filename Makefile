

buildmaster:
	docker-compose build master 

upmaster:
	docker-compose run --rm --service-ports --name master master

connectmaster:
	docker exec -it master psql -U hamed postgres

buildslave:
	docker-compose build slave 

upslave:
	docker-compose run --rm --service-ports --name slave slave

connectslave:
	docker exec -it slave psql -U hamed postgres


down:
	docker-compose down
