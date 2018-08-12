# YAML::PP
my $ypp = YAML::PP::Loader->new(boolean => "JSON::PP");
$VAR1 = {
          'bool false' => bless( do{\(my $o = 0)}, 'JSON::PP::Boolean' ),
          'bool true' => bless( do{\(my $o = 1)}, 'JSON::PP::Boolean' )
        };
