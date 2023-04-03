#!/bin/sh
export $(grep -v '^#' .env | xargs)

echo  "Building image $version";
docker image build -t incubit/php8-mysql-laravel-nginx:latest -t incubit/php8-mysql-laravel-nginx:$version .
