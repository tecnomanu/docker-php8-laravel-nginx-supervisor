# Bases Image Docker PHP 8.2.4 Alpine with Supervisord

This image support run projects Laravel / Lumen. with Mysql and MongoDb

### How to create local Image
Open an Terminal and run this command to create latest and current version image. If this repository update, rerun this command to update versiones

```sh build_image.sh```

After that, set in you Dockerfile

```FROM incubit/php8-mysql-laravel-nginx:latest```

### What's includes this image:
This is a list with the functional application running inside this image for your Laravel/Lumen project.

- Supervisord
- Mysql
- FPM
- Nginx
- CronTab (running ever php artisan schedule:run)
- Extensions required for Laravel projets
- PHP 8.2.4

Tools preinstalled:

- NPM & Node
- Composer (to run composer install)
