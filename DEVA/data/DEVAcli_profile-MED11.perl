# DEVA_cli Profile Configuration file

$VAR1 = [
          '--UsedMetricParameters',
          'CostMiss=1',
          '--UsedMetricParameters',
          'Ptarg=0.5',
          '--UsedMetricParameters',
          'CostFA=1',
          '--taskName',
          'MED',
          '--blockName',
          'EventID',
          '--PrintedBlock',
          'EventID',
          '--derivedSys',
          'DEVAcli_dividedSys_MED11.sql',
          '--FilterCMDfile',
          'DEVAcli_filter-MED11.sql',
          '--JudgementThresholdPerBlock',
          'DEVAcli_scithr-MED11.sql',
          '--KexactlyXderivedSys',
          2,
          '--KQderivedSys',
          'DEVAcli_pfs_MED11-KQderivedSys.perl',
          '--KSysConstraints',
          'DEVAcli_pfs_MED11-KSysConstraints.perl',
          '--KMDConstraints',
          'DEVAcli_pfs_MED11-KMDConstraints.perl'
        ];