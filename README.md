digitalocean-puppet-creator
===========================

Perl script to create puppets and a puppetmaster on digitalocean with ease.
##Requirements
Requires the following CPAN modules:
* [Config::Simple](http://search.cpan.org/~sherzodr/Config-Simple-4.59/)
* [Net::SSH::Perl](http://search.cpan.org/dist/Net-SSH-Perl/)
* [DigitalOcean](http://search.cpan.org/~srchulo/DigitalOcean-0.09/)

##Configuration
To use, enter your api key and client-id in a config file in the following format, and save it as DigitalOcean.conf:
```
ClientID  The_client_key_from_DigitalOcean
APIKey    YourDigitaloceanApiKey
```
