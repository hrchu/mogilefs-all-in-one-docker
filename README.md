# mogilefs-all-in-one-docker
MAIO - MogileFS All In One for developers

## Howto
    ~ docker pull docker.pkg.github.com/hrchu/mogilefs-all-in-one-docker/mogilefs-all-in-one:v1.0.0
    ~ docker run -e DOMAIN_NAME=testdomain -e CLASS_NAMES="testclass1 testclass2" -t -d -p 7001:7001 -p 7500:7500 --name maio docker.pkg.github.com/hrchu/mogilefs-all-in-one-docker/mogilefs-all-in-one:v1.0.0

Now MogileFS is ready to war on port 7001! 😎
