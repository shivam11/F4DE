#!/usr/bin/env perl
# -*- mode: Perl; tab-width: 2; indent-tabs-mode: nil -*- # For Emacs
#
# $Id$
#

BEGIN {
  if ( ($^V ge 5.18.0)
       && ( (! exists $ENV{PERL_HASH_SEED})
            || ($ENV{PERL_HASH_SEED} != 0)
            || (! exists $ENV{PERL_PERTURB_KEYS} )
            || ($ENV{PERL_PERTURB_KEYS} != 0) )
     ) {
    print "You are using a version of perl above 5.16 ($^V); you need to run perl as:\nPERL_PERTURB_KEYS=0 PERL_HASH_SEED=0 perl\n";
    exit 1;
  }
}

use strict;
use MMisc;

my $err = 0;

##########
print "** Checking for Perl Packages:\n";
my $ms = 1;

print "[F4DE Common Packages]\n";
$ms = &_chkpkg
  (
   # common/lib
   "F4DE_TestCore",
   "MErrorH",
   "MMisc",
   "ViperFramespan",
   "SimpleAutoTable",
   "CSVHelper"
  );
if ($ms > 0) {
  print "  ** ERROR: Not all packages found, you will not be able to run the programs, please install the missing ones\n\n";
  $err++;
} else {
  print "  Found all packages\n\n";
}

print "[F4DE's AVSS09 Packages]\n";
$ms = &_chkpkg
  (
   # AVSS09/lib
   "AVSS09ViperFile",
   "AVSStoCLEAR",
   "AVSS09ECF",
   "AVSS09HelperFunctions",
  );
if ($ms > 0) {
  print "  ** ERROR: Not all AVSS09 packages found, you will not be able to run the program, please install the missing ones\n\n";
  $err++;
} else {
  print "  Found all packages\n\n";
}

####################

MMisc::error_quit("\nSome issues, fix before attempting to run make check again\n") if ($err);

MMisc::ok_quit("\n** Pre-requisite testing done\n\n");

####################

sub _chkpkg {
  my @tocheck = @_;

  my $ms = scalar @tocheck;
  foreach my $i (@tocheck) {
    print "- $i : ";
    my $v = MMisc::check_package($i);
    my $t = $v ? "ok" : "**missing**";
    print "$t\n";
    $ms -= $v;
  }

  return($ms);
}
