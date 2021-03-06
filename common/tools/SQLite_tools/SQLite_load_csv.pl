#!/bin/sh
#! -*-perl-*-
eval 'exec env PERL_PERTURB_KEYS=0 PERL_HASH_SEED=0 perl -x -S $0 ${1+"$@"}'
    if 0;

# -*- mode: Perl; tab-width: 2; indent-tabs-mode: nil -*- # For Emacs
#
# $Id$
#
# SQLite CSV loader
#
# Author(s): Martial Michel
#
# This software was developed at the National Institute of Standards and Technology by
# employees and/or contractors of the Federal Government in the course of their official duties.
# Pursuant to Title 17 Section 105 of the United States Code this software is not subject to 
# copyright protection within the United States and is in the public domain.
#
# "SQLite_load_csv" is an experimental system.
# NIST assumes no responsibility whatsoever for its use by any party, and makes no guarantees,
# expressed or implied, about its quality, reliability, or any other characteristic.
#
# We would appreciate acknowledgement if the software is used.  This software can be
# redistributed and/or modified freely provided that any derivative works bear some notice
# that they are derived from it, and any modified versions bear some notice that they
# have been modified.
#
# THIS SOFTWARE IS PROVIDED "AS IS."  With regard to this software, NIST MAKES NO EXPRESS
# OR IMPLIED WARRANTY AS TO ANY MATTER WHATSOEVER, INCLUDING MERCHANTABILITY,
# OR FITNESS FOR A PARTICULAR PURPOSE.

use strict;

# Note: Designed for UNIX style environments (ie use cygwin under Windows).

##########
# Check we have every module (perl wise)

my (@f4bv, $f4d, $f4rn);
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

  use Cwd 'abs_path';
  use File::Basename 'dirname';
  $f4d = dirname(abs_path($0));
  push @f4bv, ("$f4d/../../../common/lib");
}
use lib (@f4bv);

sub eo2pe {
  my $oe = join(" ", @_);
  return( ($oe !~ m%^Can\'t\s+locate%) ? "\n----- Original Error:\n $oe\n-----" : "");
}

## Then try to load everything
my $have_everything = 1;
my $partofthistool = "It should have been part of this tools' files.";
my $warn_msg = "";
sub _warn_add { $warn_msg .= "[Warning] " . join(" ", @_) ."\n"; }

# Part of this tool
foreach my $pn ("MMisc", "MtSQLite") {
  unless (eval "use $pn; 1") {
    my $pe = &eo2pe($@);
    &_warn_add("\"$pn\" is not available in your Perl installation. ", $partofthistool, $pe);
    $have_everything = 0;
  }
}
my $versionkey = MMisc::slurp_file(dirname(abs_path($0)) . "/../../../.f4de_version");
my $versionid = "SQLite CSV loader ($versionkey)";

# usualy part of the Perl Core
foreach my $pn ("Getopt::Long") {
  unless (eval "use $pn; 1") {
    &_warn_add("\"$pn\" is not available on your Perl installation. ", "Please look it up on CPAN [http://search.cpan.org/]\n");
    $have_everything = 0;
  }
}

# Something missing ? Abort
if (! $have_everything) {
  print "\n$warn_msg\nERROR: Some Perl Modules are missing, aborting\n";
  exit(1);
}

# Use the long mode of Getopt
Getopt::Long::Configure(qw(auto_abbrev no_ignore_case));

########################################
# Options processing

my $usage = &set_usage();

# Default values for variables
my @tmpc = ();
my $nullmode = 0;

# Av  : ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz  #
# Used:              N              c    h             v      #

my %opt = ();
GetOptions
  (
   \%opt,
   'help',
   'version',
   'columnsname=s'=> \@tmpc,
   'NULLfields' => \$nullmode,
  ) or MMisc::error_quit("Wrong option(s) on the command line, aborting\n\n$usage\n");
MMisc::ok_quit("\n$usage\n") if (($opt{'help'}) || (scalar @ARGV == 0));
MMisc::ok_quit("$versionid\n") if ($opt{'version'});
MMisc::error_quit("Missing one of dbfile/csvfile/tablename\n\n$usage") 
  if (scalar @ARGV < 3);

my ($dbfile, $csvfile, $tablename) = @ARGV;

my @colsname = ();
for (my $i = 0; $i < scalar @tmpc; $i++) {
  push @colsname, split(m%\,%, $tmpc[$i]);
}

##
my $err = MMisc::check_file_w($dbfile);
MMisc::error_quit("Problem with DB file ($dbfile): $err")
  if (! MMisc::is_blank($err));

##
my $err = MMisc::check_file_r($csvfile);
MMisc::error_quit("Problem with CSV file ($csvfile): $err")
  if (! MMisc::is_blank($err));

##
my ($t) = MtSQLite::fix_entries($tablename);
MMisc::error_quit("Asked tablename ($tablename) does not comply with name requirements (should have been: \'$t\')")
  if ($t ne $tablename);

my @tmpc = MtSQLite::fix_entries(@colsname);
my @bad = ();
for (my $i = 0; $i < scalar @colsname; $i++) {
  push(@bad, $colsname[$i])
    if ($tmpc[$i] ne $colsname[$i]);
}
MMisc::error_quit("The following requested column names are improperly formatted: " . join(", ", @bad))
  if (scalar @bad > 0);

##
my ($err, $dbh) = MtSQLite::get_dbh($dbfile);
MMisc::error_quit("Problem using DB ($dbfile): $err")
  if (! MMisc::is_blank($err));

my ($err, $inserted) = MtSQLite::insertCSV_handler($dbh, $csvfile, $tablename,
                                                   $nullmode, @colsname);
MMisc::error_quit("Problem inserting CSV file ($csvfile) into DB ($dbfile)'s table ($tablename): $err")
  if (! MMisc::is_blank($err));

print "\nInserted $inserted rows\n";

MtSQLite::release_dbh($dbh);

MMisc::ok_quit("Done");

####################


sub set_usage {  
  my $tmp=<<EOF
$versionid

$0 [--help | --version] [--columnsname col1,col2[,...]] [--NULLfields] dbfile csvfile tablename

Will load a given csvfile into the SQLite dbfile's table called tablename.

NOTE: dbfile must already exist with a properly created table named tablename in it
NOTE: default is to copy the column names from the first row of cvsfile

Where:
  --help     This help message
  --version  Version information
  --columnsname  Discard the information provided in the first row of csvfile and force the column names
  --NULLfields   Empty fields will be inserted as the NULL value (the default is to insert them as the empty value of the defined type, ie '' for TEXTs)

EOF
;

  return($tmp);
}
