package MErrorH;

# M's Error Handler
#
# Author(s): Martial Michel
#
# This software was developed at the National Institute of Standards and Technology by
# employees and/or contractors of the Federal Government in the course of their official duties.
# Pursuant to Title 17 Section 105 of the United States Code this software is not subject to 
# copyright protection within the United States and is in the public domain.
#
# "MErrorH.pm" is an experimental system.
# NIST assumes no responsibility whatsoever for its use by any party.
#
# THIS SOFTWARE IS PROVIDED "AS IS."  With regard to this software, NIST MAKES NO EXPRESS
# OR IMPLIED WARRANTY AS TO ANY MATTER WHATSOEVER, INCLUDING MERCHANTABILITY,
# OR FITNESS FOR A PARTICULAR PURPOSE.


# $Id$

use strict;

use MMisc;

my $version     = "0.1b";

if ($version =~ m/b$/) {
  (my $cvs_version = '$Revision$') =~ s/[^\d\.]//g;
  $version = "$version (CVS: $cvs_version)";
}

my $versionid = "MErrorH.pm Version: $version";

## Constructor
sub new {
  my ($class, $header) = @_;

  my $self =
    {
     header   => $header,
     errormsg => "",
    };

  bless $self;
  return($self);
}

####################

sub get_version { return($versionid); }

##########

sub set_header {
  # arg 0: self
  # arg 1: header
  $_[0]->{header} = $_[1];

  return(1);
}

##########

sub _set_errormsg_txt {
  my ($oh, $add, $header) = @_;

  my $txt = "$oh$add";

  $txt = &_remove_header($txt, $header);

  return("") if (MMisc::is_blank($txt));

  $txt = "[$header] $txt" if (! MMisc::is_blank($header));

  return($txt);
}

#####

sub _remove_header {
  my ($txt, $header) = @_;

  $txt =~ s%\[$header\]\s+%%g if (! MMisc::is_blank($header));

  return($txt);
}

#####

sub set_errormsg {
  # arg 0: self
  # arg 1: text
  $_[0]->{errormsg} = &_set_errormsg_txt($_[0]->{errormsg}, $_[1], $_[0]->{header});
}

##########

sub errormsg {
  # arg 0: self
  return($_[0]->{errormsg});
}

#####

sub clean_errormsg {
  # arg 0: self
  return(&_remove_header($_[0]->{errormsg}));
}

##########

## returns 0 if no error, something else otherwise
sub error {
  # arg 0: self
  return(length($_[0]->{errormsg}));
}

##########

sub clear {
  # arg 0: self
  $_[0]->{errormsg} = "";
  return(1);
}


############################################################

1;
