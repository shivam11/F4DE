#!/bin/sh
#! -*-perl-*-
eval 'exec env PERL_PERTURB_KEYS=0 PERL_HASH_SEED=0 perl -x -S $0 ${1+"$@"}'
  if 0;

#
# $Id$
#
# Concatenate two CSV files
#
# Author:    Martial Michel
#
# This software was developed at the National Institute of Standards and Technology by
# employees and/or contractors of the Federal Government in the course of their official duties.
# Pursuant to Title 17 Section 105 of the United States Code this software is not subject to 
# copyright protection within the United States and is in the public domain.
#
# "Concatenate two CSV files" is an experimental system.
# NIST assumes no responsibility whatsoever for its use by any party.
#
# THIS SOFTWARE IS PROVIDED "AS IS."  With regard to this software, NIST MAKES NO EXPRESS
# OR IMPLIED WARRANTY AS TO ANY MATTER WHATSOEVER, INCLUDING MERCHANTABILITY,
# OR FITNESS FOR A PARTICULAR PURPOSE.

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

# Note: Designed for UNIX style environments (ie use cygwin under Windows).

########################################

my $usage = "$0 file1.csv file2.csv outfile.csv\n\nProgram will copy content from multiple CSV files to one output CSV file (it will copy the CSV header of the first file only)\nNote: the script will not try to do any check on the number of columns in the input files\n";

die($usage) if (scalar @ARGV != 3);

my @list = ();
push @list, shift @ARGV;
push @list, shift @ARGV;

my $out = shift @ARGV;

my $first = 0;
my $lc = 0;
my $inc = 0;
foreach my $file (@list) {
    print "[$file]\n";

    # Copy header
    if (! $first) {
      `head -n 1 $file > $out`;
      $first = 1;
      my $nlc = &get_lc($out);
      my $a = $nlc - $lc;
      die("Header: Diff than one line added ($a)\n")
        if ($a != 1);
      $lc = $nlc;
    }

    `tail -n +2 $file >> $out`;
    my $elc = &get_lc($file) - 1;
    my $nlc = &get_lc($out);
    my $a = $nlc - $lc;
    die("Diff amount of line added ? expected : $elc / seen : $a\n")
      if ($a != $elc);
    print "   -> added $a lines\n";
    $lc = $nlc;
    $inc++;
}

print "Done ($inc files / $lc lines)\n";
exit(0);

#####

sub get_lc {
  my $file = shift @_;

  my $alc = `wc $file`;
  my $lc = 0;

  $lc = $1
    if ($alc =~ m%^\s*(\d+)\s+%);
  
  return ($lc);
}
