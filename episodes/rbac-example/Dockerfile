#go aplibin base image
FROM golang:alpine
#Copy file from root on local to this path in container
#Creates dir and files if they do not exist
ADD . /go/src/app
#Set main path to this dir
WORKDIR /go/src/app
#Create env var for port
ENV PORT=8080
#Run go main.go
CMD ["go", "run", "main.go"]