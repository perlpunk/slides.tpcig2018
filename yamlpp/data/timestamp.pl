use YAML::PP;
use DateTime;
my $yp = YAML::PP->new;
$yp->schema->add_resolver(
  tag => "tag:yaml.org,2002:timestamp",
  match => [ regex => qr/
      ^(\d{4})-(\d{2})-(\d{2})[ ]
      (\d{2}):(\d{2}):(\d{2})\z
      /x => sub {
      return DateTime->new(
        year => $_[0],   month => $_[1],
        day => $_[2],    hour => $_[3],
        minute => $_[4], second => $_[5],
      );
  }],
  implicit => 1, # allow matching without tag
);
my $data = $yp->load_file($ARGV[0]);
printf "%s\nfrom: %s\nto  : %s\n", $data->{start}->ymd,
$data->{start}->hms, $data->{end}->hms;
__END__
2018-08-16
from 10:40:00
to   11:00:00
