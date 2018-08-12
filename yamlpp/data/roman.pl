use 5.010;
use YAML::PP;
my $yp = YAML::PP->new;
$yp->schema->add_resolver(
  tag => "tag:yaml.org,2002:int",
  match => [ regex
    => qr/^ ([IVXLCM]+) \z/x
    => sub {
        return {
            I=>1,  II=>2,  III=>3,  IV=>4, V=>5,
            VI=>6, VII=>7, VIII=>8, IX=>9, X=>10,
        }->{ $_[0] };
  }],
  implicit => 1, # allow matching without tag
);
my $data = $yp->load_string("seven: VII");
say $data->{seven};

__END__
7
