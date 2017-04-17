# Graphgist Portal

* [Technology](#markdown-header-technology)
* [Automated Setup (Recommended)](#markdown-header-automated-setup)
* [Manual Setup](#markdown-header-manual-setup)

## Technology

* Ruby 2.3.0
* Neo4j Community Edition

## Automated Setup

### Requirements

* Vagrant
* VirtualBox

### Setup

Start the virtual machine.  The first time the machine is started it will be created and configured which may take a while.

```
vagrant up
```

SSH to the VM

```
vagrant ssh
```

CD to the code directory.  This directory is synced with the directory on your computer.

```
cd /vagrant
```

Install the project requirements

```
bundle install
```

Set the environment

```
export GITHUB_KEY='<your_key>'
export GITHUB_SECRET='<your_secret>'
```

Start the rails server

```
rails s -b 192.168.99.13
```

Web Addresses:

* GraphGist Portal 192.168.99.13:3000
* Neo4j Database 192.168.99.13:7474

After some user(s) are created you can give a user admin privileges by running the following query in the neo4j database website linked above:

```
MATCH (u:User {username:'<username of a user>'}) SET u.admin = true RETURN u
```

If you need to reboot the database, use:

```
sudo systemctl restart neo4j
```

## Manual Setup

### Requirements

* RVM

### Setup

Install ruby

```
rvm install 2.3.0
rvm use 2.3.0
gem install bundler
```

Install the project requirements

```
bundle install
```

Ensure the Neo4j database is running and you have a github oauth application.

Set the environment

```
export GITHUB_KEY='<your_key>'
export GITHUB_SECRET='<your_secret>'
```

Start the rails server

```
rails s
```

You can now visit the website in your browser at localhost:3000

### Testing

First it needs the S3 bucket name to be set to pass some tests:

```
export S3_BUCKET_NAME=graphgist_test
```

To run tests:

```
bundle exec rake
```

If you'd like to run single test file then:

```
rspec ./spec/controllers/query_controller_spec.rb
```