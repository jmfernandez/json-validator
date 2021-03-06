use lib '.';
use t::Helper;
use Mojo::Util 'decode';
use Test::More;

my $palindrome_schema = {
  type       => 'object',
  properties => {v => {type => 'string', format => 'palindrome'}}
};

{
  my $check_palindrome = sub {
    return $_[0] eq reverse($_[0]) ? undef : 'Not a palindrome.';
  };

  validate_custom_format_ok {v => 'Able was I ere I saw elbA'},
    $palindrome_schema, 'palindrome', $check_palindrome;

  validate_custom_format_ok {v => 'Amoeba'}, $palindrome_schema, 'palindrome',
    $check_palindrome, E('/v', 'Not a palindrome.');
}

my $divisible_schema = {
  type => 'object',
  properties =>
    {v => {type => 'integer', format => 'divisible', factors => [3, 5]}}
};

{
  my $check_divisible = sub {
    my $factors = $_[1]->{factors};
    foreach my $factor (@{$factors}) {
      return 'Not divisible by ' . $factor . '.' if ($_[0] % $factor != 0);
    }

    return undef;
  };

  validate_custom_format_ok {v => 15}, $divisible_schema, 'divisible',
    $check_divisible;

  validate_custom_format_ok {v => 21}, $divisible_schema, 'divisible',
    $check_divisible, E('/v', 'Not divisible by 5.');

  validate_custom_format_ok {v => 20}, $divisible_schema, 'divisible',
    $check_divisible, E('/v', 'Not divisible by 3.');
}

done_testing;
