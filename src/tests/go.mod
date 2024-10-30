module github.com/GrzegorzSychta/cubbit/src/tests

go 1.17

replace github.com/GrzegorzSychta/cubbit/src/{{ENV}}/go-hello-app => ../{{ENV}}/go-hello-app

require github.com/GrzegorzSychta/cubbit/src/{{ENV}}/go-hello-app v0.0.0
