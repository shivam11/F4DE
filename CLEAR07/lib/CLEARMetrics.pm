package CLEARMetrics;

# CLEARMetrics
#
# Author(s): Martial Michel
#
# This software was developed at the National Institute of Standards and Technology by
# employees and/or contractors of the Federal Government in the course of their official duties.
# Pursuant to Title 17 Section 105 of the United States Code this software is not subject to 
# copyright protection within the United States and is in the public domain.
#
# "CLEARMetrics.pm" is an experimental system.
# NIST assumes no responsibility whatsoever for its use by any party.
#
# THIS SOFTWARE IS PROVIDED "AS IS."  With regard to this software, NIST MAKES NO EXPRESSED
# OR IMPLIED WARRANTY AS TO ANY MATTER WHATSOEVER, INCLUDING MERCHANTABILITY,
# OR FITNESS FOR A PARTICULAR PURPOSE.

use strict;

my $version = "0.1b";

if ($version =~ m/b$/) {
  (my $cvs_version = '$Revision$') =~ s/[^\d\.]//g;
  $version = "$version (CVS: $cvs_version)";
}

my $versionid = "CLEARMetrics.pm Version: $version";


########################################

sub computeMOTA {
  my ($costMD, $sumMD, $costFA, $sumFA, $costIS, $sumIDsplit, $sumIDmerge, $cng) = @_;

  return(undef) if ($cng == 0);
  
  return(1 - ( $costMD*$sumMD + $costFA*$sumFA + $costIS*($sumIDsplit + $sumIDmerge)) / $cng);
}

########################################

1;