#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

use YAML::PP;
use YAML::PP::Highlight;

my ($file) = @ARGV;

my $ypp = YAML::PP->new(
    boolean => 'JSON::PP',
);
my @docs = eval { $ypp->load_file($file) };
my $error = $@;
my $tokens = $ypp->loader->parser->tokens;
if ($error) {
    my $remaining_tokens = $ypp->loader->parser->lexer->next_tokens;
    push @$tokens, map {
        { name => 'ERROR', value => $_->{value} } } @$remaining_tokens;
    my $remaining = $ypp->loader->parser->lexer->reader->read;
    push @$tokens, { name => 'ERROR', value => $remaining };
}

my $high = YAML::PP::Highlight->htmlcolored($tokens);
say $high;
