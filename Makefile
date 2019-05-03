DC  = sudo docker-compose
# make [ターゲット名]
# ターゲット:依存するファイル
# 		コマンド

# make build
build:
	@$(DC) build

# make run
up:
	@$(DC) up

# make down
down:
	@$(DC) down

# make bash
bash:
	@$(DC) run -p 80:3000 --rm app bash

# ローカルで実行
build4deploy:
	DOCKER_BUILDKIT=1 docker build -t notes-about-rails-webpacker_app:production --progress=plain --secret id=masterkey,src=config/master.key .

deploy:
	git push heroku `git rev-parse --abbrev-ref HEAD`:master
