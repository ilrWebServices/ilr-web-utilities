ilr-web-utilities
=================

A Symfony application to house miscellaneous utility tasks and support for small applications not suitable for hosting on Acquia.

Parts of this README file are taken with little or no modification from the README for the installaton of the Symfony Standard Edition (the default Symfony application).

1) Installing the Application Locally
-------------------------------------

This application is set up for installation via [Composer][1]

If you don't have Composer yet, download it following the instructions on
http://getcomposer.org/ or just run the following command:

    curl -s http://getcomposer.org/installer | php

Then, use the `install` command from the base directory of this repo:

    php composer.phar install

Composer will install the project, including Symfony and all its dependencies, most of which will end up in the '/vendor/' directory.

2) Providing Configuration Parameters
-------------------------------------

As part of the installation process, the install script will ask you to provide values for certain parameters needed by the application. The list of these values, as well as their default initial values, can be found at /app/config/parameters.yml.dist and the values you provide will be stored in /app/config/parameters.yml, which is not tracked by Git. This app uses the /vendor/incenteev library to manage the generation of that file based on the parameters.yml.dist template. In the case of an interactive install Composer install form the command line interface, the user is asked to enter values. In the case of a deployment to a server environment such as AWS Elastic Beanstalk, values for these parameters can be set as Apache environment variables prior to app deployment, since in that scenario there is no opportunity to provide them interactively on the command line.

2.1) Providing Configuration Parameters for ILR Profile Data Pulls
------------------------------------------------------------------

The values to provide for the iLR Profile data pule from Activity Insight, Cornell LDAP, and other sources can be found at: https://cornell.box.com/ilr-profile-data-pull-params.

3) Checking your System Configuration
-------------------------------------

Before working with the projecy, make sure that your local system is properly
configured for Symfony.

Execute the `check.php` script from the command line:

    php app/check.php

The script returns a status code of `0` if all mandatory requirements are met,
`1` otherwise.

Access the `config.php` script from a browser:

    http://localhost/path/to/symfony/app/web/config.php

If you get any warnings or recommendations, fix them before moving on.

4) Getting Oriented in Symfony
------------------------------

Congratulations! You're now ready to use Symfony to work on this application. For further instructions on how Symfony works and how this app is configured, please see the file README_FOR_SYMFONY.md in the root of this repo.

5) Deploying to AWS Elastic Beanstalk
-------------------------------------

To come...

[1]:  http://getcomposer.org/
