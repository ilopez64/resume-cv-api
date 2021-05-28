# Resume-CV-API

This is an REST API that, when called, returns my resume in a JSON format. I had recently taken a Go 
course and wanted to use my newly acquired knowledge to build something fun. Terraform and Circle CI
were new technologies I had also wanted to learn so, with some reading of the documentation, I was able to use both to build this project. 

Current features:

- [x] Resume REST API call
- [x] CI/CD with CircleCI
- [ ] Unit testing 

## Deployment

The API can be called here: resume.irvinglopez.xyz

To test, run the following in a terminal: 

    $ curl -L resume.irvinglopez.xyx

## Code walkthrough

Go was used for the main implementation of this project, as seen in main.go. The AWK SDK are needed
To build this project so those are collected with the go get command in the terminal.

A struct was created based off the structure of my resume.

The function getResume() was then created to fill the Resume struct with the contents of my real resume. 

The function formatResume() receives a Resume struct and returns the content of that struct in a JSON format

The function handleRequest() use AWS Gateway to handle requests from AWS Lambda

The project is then ran in the main() function by running handleRequest()

Terraform was used to set up the infrastructure of my project. The main.tf file creates both the
AWS Lambda and AWS Gateway infrastructure.

For CI/CD, Circle CI was includes. The Circle CI config file defines the test, build, and deploy workflows. A main_test file was created but has yet to fully be implemented; it will always pass. The build workflow installs dependencies, builds the executable according to an included Makefile, and compresses it into a zip file. The deploy workflow deploys the zip file to AWS Lambda and returns a URL endpoint at which the API can be called from. 

Every update to the project repository triggers terraform plan to update the infrastructure, runs test, and deploys the app to AWS. 

