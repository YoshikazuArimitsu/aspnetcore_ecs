
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 218226060097.dkr.ecr.ap-northeast-1.amazonaws.com

docker build -t webapp -f ./WebApplication1/Dockerfile .
docker tag webapp:latest 218226060097.dkr.ecr.ap-northeast-1.amazonaws.com/examplewebapp-ecr:latest
docker push 218226060097.dkr.ecr.ap-northeast-1.amazonaws.com/examplewebapp-ecr:latest
