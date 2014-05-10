#!/usr/bin/perl

use Local::DigitalOcean;
use Local::SSH;

print "Please choose an action to perform.\n";
print "1). Create a puppet master.\n";
print "2). Create one or more puppets.\n";
my $action = userInput("3). Destroy a Droplet.");
if ($action != 1 && $action != 2 && $action != 3) {
  print "No valid action detected.\n";
  exit 0;
}

my $do = new Local::DigitalOcean();

if ($action == 1 || $action == 2) {
  my $master_domain = userInput("Enter the domain to put the new droplet(s) under (should already exist on the dns tab in digitalocean).");
}

if ($action == 1) {
  my $droplet_name = userInput("What should the new droplet be called? Only valid hostname characters are allowed. (a-z, A-Z, 0-9, . and -).");
  $droplet_name =~ s/^\s+|\s+$//g;
  $master = $do->create_droplet($droplet_name, 1);
  $domain = $do->get_by_name("domains", $master_domain);
  # Fetch the master again, because the droplet we got does not
  # contain an ip address.
  $master = $do->get_by_name("droplets", $master->name);
  $domain->create_record(
    record_type => 'A',
    data => $master->ip_address,
    name => $master->name,
  );
  print "Created A record for " . $master->name . "\n";
  $ssh = new Local::SSH($master->ip_address, identity_files => ["/home/yaron/.ssh/id_rsa.pub"]);
  $ssh->install_deb_package("https://apt.puppetlabs.com/puppetlabs-release-" . $ssh->getVersionName() . ".deb");
  $ssh->install_package("puppetmaster-passenger");
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
}

if ($action == 2) {
  my $number_puppets = userInput("How many puppets do you want to create?");
  @puppets = ();
  for( $i = 0; $i < $number_puppets; $i = $i + 1 ){
    my $last = ($i == ($number_puppets - 1));
    my $droplet_name = userInput("What should the new droplet (number " . $i . ") be called? Only valid hostname characters are allowed. (a-z, A-Z, 0-9, . and -)");
    $droplet_name =~ s/^\s+|\s+$//g;
    $puppets[$i] = $do->create_droplet($droplet_name, $last);
    print "Created " . $droplet_name . "\n";
  }

  $domain = $do->get_by_name("domains", $master_domain);
  for my $puppet (@puppets) {
    # Fetch the puppet again, because the droplets we got do not
    # contain an ip address.
    $puppet = $do->get_by_name("droplets", $puppet->name);
    $domain->create_record(
      record_type => 'A',
      data => $puppet->ip_address,
      name => $puppet->name,
    );
    print "Created A record for " . $puppet->name . "\n";
    $ssh = new Local::SSH($puppet->ip_address, identity_files => ["/home/yaron/.ssh/id_rsa.pub"]);
    $ssh->install_deb_package("https://apt.puppetlabs.com/puppetlabs-release-" . $ssh->getVersionName() . ".deb");
    $ssh->install_package("puppet");
  }
}


if ($action == 3) {
  
  $droplet_id = $do->choose_option("droplets", "Droplet");
  $droplet = $do->{_do}->droplet($droplet_id);
  $droplet->destroy();
}

sub userInput{
  my $question = shift;
  print $question . "\n";
  my $answer = <>;
  chomp($anwer);
  return $answer;
}
