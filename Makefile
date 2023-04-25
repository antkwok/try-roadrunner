file := version.txt
include .env.developer

gen_changelog:
	@echo "generate changelog"
	git-chglog --sort semver > CHANGELOG.md

md2pdf:
	@echo "md 2 pdf"
	md-to-pdf approval_log.md && md-to-pdf CHANGELOG.md

build_prod:
	$(eval version=`cat ${file}`)
	@echo "Build production docker image for $(version)"
	docker build -f Prod.Dockerfile -t singtao-registry.cn-hongkong.cr.aliyuncs.com/testing/web-api-bff:$(version) .

build_prod_m1:
	$(eval version=`cat ${file}`)
	@echo "Build production docker image for $(version)"
	docker buildx build --platform=linux/amd64 -f Prod.Dockerfile -t singtao-registry.cn-hongkong.cr.aliyuncs.com/testing/web-api-bff:$(version) .

push_prod:
	$(eval version=`cat ${file}`)
	@echo "Push image for $(version)"
	docker login --username=$(DOCKER_LOGIN_USERNAME) singtao-registry.cn-hongkong.cr.aliyuncs.com && \
	docker push singtao-registry.cn-hongkong.cr.aliyuncs.com/testing/web-api-bff:$(version)
