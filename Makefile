DOCKER_IMAGE_NAME = reduxblogserver_web

ifdef local
	local_or_docker =
else
	local_or_docker = docker exec -it $(DOCKER_IMAGE_NAME)
endif


test_all:
	$(local_or_docker) env RAILS_ENV=test rspec spec

startup:
	bundle exec guard -i -P bundler rails

deploy: test_all
	git push origin master
	git push heroku master
