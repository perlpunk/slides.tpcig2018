# YAML::XS
$YAML::XS::Boolean = "JSON::PP"; # since v0.67
$VAR1 = {
          'bool false' => bless( do{\(my $o = 0)}, 'JSON::PP::Boolean' ),
          'bool true' => bless( do{\(my $o = 1)}, 'JSON::PP::Boolean' )
        };
