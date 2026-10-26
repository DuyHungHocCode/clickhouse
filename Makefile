PROFILE ?= full

.PHONY: doctor config up down restart logs ps verify superset-init

doctor:
	./scripts/doctor.sh $(PROFILE)

config:
	docker compose --profile $(PROFILE) config

up:
	docker compose --profile $(PROFILE) up -d

down:
	docker compose --profile $(PROFILE) down

restart:
	docker compose --profile $(PROFILE) restart

logs:
	docker compose --profile $(PROFILE) logs -f

ps:
	docker compose --profile $(PROFILE) ps

verify:
	PROFILE=$(PROFILE) ./scripts/verify-infra.sh config

superset-init:
	docker compose --profile bi exec -T superset superset db upgrade
	docker compose --profile bi exec -T superset sh -c 'superset fab create-admin --username "$$SUPERSET_ADMIN_USERNAME" --firstname Admin --lastname User --email "$$SUPERSET_ADMIN_EMAIL" --password "$$SUPERSET_ADMIN_PASSWORD"'
	docker compose --profile bi exec -T superset superset init
