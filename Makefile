clean:
	go clean

install:
	go get -v -t -d ./...

test:
	go test -v ./...

compile:
	go build -o resume-api main.go