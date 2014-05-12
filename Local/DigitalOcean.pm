use DigitalOcean;
use Config::Simple;

package Local::DigitalOcean;
sub new {
  my $class = shift;

  my $cfg = new Config::Simple('DigitalOcean.conf');
  my ($client_id, $api_key) = ($cfg->param("ClientID"), $cfg->param("APIKey"));
  my $self = {
    _do => DigitalOcean->new(
      client_id=> $client_id,
      api_key => $api_key,
    ),
  };

  bless $self, $class;
  return $self;
}
sub create_droplet {
  my( $self, $name, $wait ) = @_;

#@TODO load config from a file if possible, otherwise ask user.
  return $self->{_do}->create_droplet(
    name => $name,
    size_id => $self->choose_option("sizes", "Size")->id,
    image_id => $self->choose_option("images", "Image")->id,
    region_id => $self->choose_option("regions", "Region")->id,
    ssh_key_ids => $self->choose_option("ssh_keys", "SSH Key")->id,
    wait_on_event => $wait,
  );
}
sub get_by_name {
  my( $self, $type, $name ) = @_;
  my $objects = $self->{_do}->$type;
 
  for my $object (@{$objects}) {
    if ($object->name eq $name) {
      return $object;
    }
  }
  
  return FALSE;
}
sub choose_option {
  my ($self, $type, $type_human) = @_;
  my $objects = $self->{_do}->$type;
  print "Please choose a(n) " . $type_human . ".\n";
  for my $object (@{$objects}) {
    print $object->id . "). " . $object->name . "\n";
  }
  my $answer = <>;
  chomp($anwer);
  for my $object (@{$objects}) {
    if ($object->id == $answer) {
      return $object;
    }
  }
  
  return $self->choose_option($type, $type_human);
}
1;
