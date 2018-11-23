# README

Bundle is an ecommerce solution for B2B sellers. It was our startup that we are now shutting down. This guide will help developers setup the open source project in their local environment. A version of the project is hosted on a live server at www.orderbundle.com for people to test out the entire product without installing anything. 

Here's a video walkthrough of the platform https://www.youtube.com/watch?v=z90QYecf1Vo

Demo login credentials for a supplier/seller are:
username: bundleemailtest@gmail.com
password: password

Demo login credentials for a buyer are (the demo store resides at the subdomain bundleemailtest.orderbundle.com):
username: orderbundleemaildemo@gmail.com
password: password

## Setup Instructions:

Requirements:
- Ruby on Rails
- PostgreSQL

## Setting up Rails:

All the Ruby and Rails requirements are bundled together and can be downloaded here http://railsinstaller.org/en

Download and install the package. This package will setup git, ruby and rails on your computer. 

Once the installation is completed, the installer automatically opens the rails environment configuration command prompt. Enter your name and email for the git configuration.

To setup Bundler, run this command:
```gem install bundler```

This short video can be used as a guide to setup Rails on Windows https://www.youtube.com/watch?v=OHgXELONyTQ

## Setting up PostgreSQL:

Choose your operating system and download PostgreSQL from here https://www.postgresql.org/download/

Once the download is complete, run the setup wizard. When asked, enter a password for the database's superuser. 

The stackbuilder need not be launched at the end of the installation because no additional tools are required.

Once the installation is complete, navigate to the bin folder in pgAdmin 4 folder in the PostgreSQL folder. 

Run pgAdmin4. This will open the pgAdmin GUI in your browser.

If you get an error stating that the "application server cannot be contacted". Right click and run as administrator. 

Navigate to the Login roles and create a user and provide the user with the privilege to create a database and to login. 

This video can be used a reference to setup PostgreSQL on Windows https://www.youtube.com/watch?v=e1MwsT5FJRQ

Enter the username and password in the database.yml file in the project folder. This connects the application to the database.

Now open the command prompt and go into the project folder. 

Run the following command to install all the dependencies:
```bundle install```

If there are any SSL issues with getting dependencies, the solution can be found here http://railsapps.github.io/openssl-certificate-verify-failed.html

For windows users the solution can be found here https://gist.github.com/fnichol/867550#file-win_fetch_cacerts-rb

To setup the database, run the following command:

```rake db:setup```

To make the database migrations:

```rake db:migrate```

Once the database is setup and the migrations are complete, you can run the application by entering

```rails s```

The application will now be running on localhost:3000
Navigate to localhost:3000 in your browser and start playing with the product!
