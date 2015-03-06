# Solr 5.0.0 vagrant ubuntu environment

This vagrant image will install a precise 64 ubuntu image with solr 5.0.0.

## Pre-requisites
Ensure you have the following tools installed:
* virtualbox - https://www.virtualbox.org/
* vagrant - http://www.vagrantup.com/
* URL to current solr-5.x.x.tgz (http://apache.mirror.digionline.de/lucene/solr/5.0.0/solr-5.0.0.tgz)
	* Update the `$solr_url` definition in `manifests/default.pp` if the url is out of date.
* librarian-puppet - https://github.com/rodjek/librarian-puppet
	* puppet installation is optional, the modules have been added as gitsubmodules and pushed to the repo. It's necessary only if you think the modules are outdated

## Vagrant Setup
###Do the following:
* $ ```vagrant box add precise64 http://files.vagrantup.com/precise64.box```
	* This will download the VM for you
* $ ```git clone https://github.com/tblsoft/vagrant-ubuntu-solr5.git```
	* clone this repoistory (it's your working vagrant location)
* **If librarian-puppet is installed**, grab the puppet modules:
	* $ ```cd vagrant-ubuntu-solr5/manifests```
	* $ ```librarian-puppet install```
	* $ ```cd ..```

* Otherwise, **if librarian-puppet is not installed**, clone the puppet modules
	* $ ```cd vagrant-ubuntu-solr5```
	* $ ```git submodule init```
  	* $ ```git submodule update```

* $ ```vagrant up```
	* brings up the VM with solr and java installed.
* $ ```vagrant ssh```
	* open solr admin consoloe [http://localhost:8888/solr]

## Deployment Details
* solr is starting automatically with init.d
* After provisioning the solr service have to be startet manually sudo ```/etc/init.d/solr start```
  * use ```sudo /etc/inid.d/solr start | stop | status``` to start, stop and retrieve the current status for solr
* Vagrant is setup to map port 8983 of the VM to port 8888 on your machine
	*  solr admin console [http://localhost:8888/solr]

## Package as a box for customizing in your projects
* After box is configured and provisioned, you can package and use this as your base box to speed up your subsequent reloads
* ```vagrant package```
* ```mv package.box precise64-solr5.box```
* ```vagrant box add precise64-solr5 precise64-solr5.box```
* Use ```precise64-solr5``` as the name of the box in your VagrantFile ```config.vm.box = "precise64-solr5"```

#Remarks
* The project was forked from [https://github.com/seshendra/vagrant-ubuntu-tomcat7]
