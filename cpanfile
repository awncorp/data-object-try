requires "Moo" => "0";
requires "Try::Tiny" => "0.30";
requires "perl" => "5.014";
requires "routines" => "0";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "Moo" => "0";
  requires "Test::Auto" => "0.05";
  requires "Try::Tiny" => "0.30";
  requires "perl" => "5.014";
  requires "routines" => "0";
  requires "strict" => "0";
  requires "warnings" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};
