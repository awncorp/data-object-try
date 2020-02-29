package Data::Object::Try;

use 5.014;

use strict;
use warnings;
use routines;

use Moo;
use Try::Tiny ();

# VERSION

# ATTRIBUTES

has 'invocant' => (
  is => 'ro'
);

has 'arguments' => (
  is => 'ro'
);

has 'on_try' => (
  is => 'rw'
);

has 'on_catch' => (
  is => 'rw'
);

has 'on_default' => (
  is => 'rw'
);

has 'on_finally' => (
  is => 'rw'
);

# BUILD

method BUILD($args) {
  $self->{'on_catch'} = [] if !$args->{'on_catch'};

  return $args;
}

# METHODS

method call($callback) {
  $self->on_try($self->callback($callback));

  return $self;
}

method callback($callback) {
  require Carp;

  unless (UNIVERSAL::isa($callback, 'CODE')) {
    my $method = $self->invocant
      ? $self->invocant->can($callback) : $self->can($callback);
      Carp::confess(sprintf(
        qq(Can't locate object method "%s" on package "%s"),
        ($callback, ref $self)
      )) if !$method;
    $callback = sub { goto $method };
  }

  return $callback;
}

method catch($class, $callback) {
  push @{$self->on_catch}, [$class, $self->callback($callback)];

  return $self;
}

method default($callback) {
  $self->on_default($self->callback($callback));

  return $self;
}

method execute($callback, @args) {
  unshift @args, @{$self->arguments}
    if $self->arguments && @{$self->arguments};
  unshift @args, $self->invocant
    if $self->invocant;

  return $callback->(@args);
}

method finally($callback) {
  $self->on_finally($self->callback($callback));

  return $self;
}

method maybe() {
  $self->on_default(sub{''});

  return $self;
}

method no_catch() {
  $self->on_catch([]);

  return $self;
}

method no_default() {
  $self->on_default(undef);

  return $self;
}

method no_finally() {
  $self->on_finally(undef);

  return $self;
}

method no_try() {
  $self->on_try(undef);

  return $self;
}

method result(@args) {
  require Carp;

  my $returned;

  Try::Tiny::try(sub {
    my $tryer = $self->on_try;

    $returned = $self->execute($tryer, @args);
  }, Try::Tiny::catch(sub {
    my $caught = $_;
    my $catchers = $self->on_catch;
    my $default = $self->on_default;

    for my $catcher (@$catchers) {
      if (UNIVERSAL::isa($caught, $catcher->[0])) {
        $returned = $catcher->[1]->($caught);
        last;
      }
    }

    if(!$returned) {
      $returned = $default->($caught) if $default;
      Carp::confess($caught) if not defined $returned;
    }
  }, Try::Tiny::finally(sub {
    my $finally = $self->on_finally;

    $self->execute($finally, @args) if $finally;
  })));

  return $returned;
}

1;
