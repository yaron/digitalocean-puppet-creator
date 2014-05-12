#!/usr/bin/perl

use Local::DigitalOcean;
use Local::Puppet;

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
  print "The new droplets will be created under one domain. ";
  $master_domain = $do->choose_option("domains", "Domain");
}

if ($action == 1) {
  my $droplet_name = userInput("What should the new droplet be called? Only valid hostname characters are allowed. (a-z, A-Z, 0-9, . and -).");
  $droplet_name =~ s/^\s+|\s+$//g;
  $master = $do->create_droplet($droplet_name, 1);
  # Fetch the master again, because the droplet we got does not
  # contain an ip address.
  $master = $do->get_by_name("droplets", $master->name);
  $master_domain->create_record(
    record_type => 'A',
    data => $master->ip_address,
    name => $master->name,
  );
  print "Created A record for " . $master->name . "\n";
  $puppet = new Local::Puppet($master);
  $puppet->make_master();
}

if ($action == 2) {
  my $number_puppets = userInput("How many puppets do you want to create?");
  @puppets = ();
  for( $i = 0; $i < $number_puppets; $i = $i + 1 ){
    my $last = ($i == ($number_puppets - 1));
    my $droplet_name = userInput("What should the new droplet (number " . $i . ") be called? Only valid hostname characters are allowed. (a-z, A-Z, 0-9, . and -)");
    $droplet_name =~ s/^\s+|\s+$//g;
    $puppets[$i] = $do->get_by_name("droplets", $droplet_name);
    #$puppets[$i] = $do->create_droplet($droplet_name, $last);
    print "Created " . $droplet_name . "\n";
  }

  for my $puppet (@puppets) {
    # Fetch the puppet again, because the droplets we got do not
    # contain an ip address.
    $puppet = $do->get_by_name("droplets", $puppet->name);
    $master_domain->create_record(
      record_type => 'A',
      data => $puppet->ip_address,
      name => $puppet->name,
    );
    print "Created A record for " . $puppet->name . "\n";
    $puppet = new Local::Puppet($puppet);
    $puppet->make_puppet();
  }
}


if ($action == 3) {
  $droplet = $do->choose_option("droplets", "Droplet");
  $droplet->destroy();
}

sub userInput{
  my $question = shift;
  print $question . "\n";
  my $answer = <>;
  chomp($anwer);
  return $answer;
}
