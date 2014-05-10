use Net::SSH::Perl;
package Local::SSH;
sub new {
  my $class = shift;
  my $host = shift;
  my (%params) = @_;
  my $os = undef;
  my $version_id = undef;
  my $version_name = undef;
  
  print "Making connection to " . $host . "\n";
  $params{'strict_host_key_checking'} = "no";
  my $connection = Net::SSH::Perl->new($host, %params);
  $connection->login("root");
  
  ($uname, $err, $exit) = $connection->cmd("uname -a");
  ($os_release, $err, $exit) = $connection->cmd("cat /etc/os-release");
  if ($uname =~ /Debian/ || $uname =~ /Ubuntu/) {
    $os = "Debian";
    $os_release =~ m/VERSION="(\d+)\s+\((.+?)\)"/;
    ($version_id, $version_name) = ($1, $2);
  }
  else {
    print "This script currently only supports Debian and Ubuntu.";
  }
  
  my $self = {
    _connection => $connection,
    _os => $os,
    _version_id => $version_id,
    _version_name => $version_name,
  };

  bless $self, $class;
  return $self;
}
sub getVersionName {
  my $self = shift;
  return $self->{_version_name};
}
sub install_deb_package {
  my( $self, $url ) = @_;
  print "Downloading " . $url . "\n";
  ($out, $err, $exit) = $self->{_connection}->cmd("wget " . $url);
  ($filename) = ($url =~ /([^\/]*?)$/);
  $self->{_connection}->cmd("dpkg -i " . $filename);
  $self->{_connection}->cmd("apt-get update " . $filename);
  return $exit;
}
sub install_package {
  my( $self, $package ) = @_;
  print "Installing " . $package . "\n";
  $self->{_connection}->cmd("apt-get install -y " . $package);
}

1;
