use Local::SSH;
package Local::Puppet;
sub new {
  my $class = shift;
  my $droplet = shift;
  #@TODO Load type of puppets to create from config.
  
  my $ssh = new Local::SSH($droplet->ip_address);
  $ssh->install_deb_package("https://apt.puppetlabs.com/puppetlabs-release-" . $ssh->getVersionName() . ".deb");
  
  my $self = {
    _ssh => $ssh,
    _droplet => $droplet,
  };

  bless $self, $class;
  return $self;
}
sub make_master {
  my $self = shift;
  @TODO master installation
  #https://pm.puppetlabs.com/cgi-bin/download.cgi?ver=latest&dist=debian&rel=7&arch=amd64
  
  #$self->{_ssh}->install_package("puppetmaster-passenger");
  # install puppet-dashboard
  #edit /etc/puppet-dashboard/database.yml
  #mysql-server (inc. root user pass)
  #create dashboard mysql user and database
  #edit /etc/mysql/my.cnf max_allowed_packet = 32M
  #restart mysql
  #cd /usr/share/puppet-dashboard  && rake RAILS_ENV=production db:migrate
  # create htpasswd file in /etc/apache2/passwords
  # scp ./puppet-dashboard.conf /etc/apache2/sites-available/puppet-dashboard (replace --puppet-master-domain-- with FQDN)
  #a2ensite puppet-dashboard
  #service apache2 reload

  #@TODO save hostname to configuration file.
}
sub make_puppet {
  my $self = shift;
  #@TODO make dependent on puppet type.
  $self->{_ssh}->install_package("puppet");
  #@TODO agent configuration
}

1;
