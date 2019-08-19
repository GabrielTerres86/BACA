/* INC0019989 - script para ajustar os envelopes que estão vinculados com o número de conta que não existe */ 

UPDATE crapenl
   SET crapenl.cdcooper = 1
      ,crapenl.nrdconta = 9234896
 WHERE crapenl.cdcooper = 1
   AND crapenl.nrseqenv = 14836277
   AND crapenl.cdcoptfn = 1
   AND crapenl.cdagetfn = 79
   AND crapenl.nrterfin = 298
   AND to_date(crapenl.dtmvtolt, 'dd/mm/rrrr') = to_date('21/05/2019', 'dd/mm/rrrr');
   
UPDATE crapenl
   SET crapenl.cdcooper = 1
      ,crapenl.nrdconta = 9865578
 WHERE crapenl.cdcooper = 1
   AND crapenl.nrseqenv = 15051084
   AND crapenl.cdcoptfn = 1
   AND crapenl.cdagetfn = 82
   AND crapenl.nrterfin = 322
   AND to_date(crapenl.dtmvtolt, 'dd/mm/rrrr') = to_date('10/06/2019', 'dd/mm/rrrr');
   
UPDATE crapenl
   SET crapenl.cdcooper = 1
      ,crapenl.nrdconta = 3859924
 WHERE crapenl.cdcooper = 1
   AND crapenl.nrseqenv = 15125401
   AND crapenl.cdcoptfn = 1
   AND crapenl.cdagetfn = 18
   AND crapenl.nrterfin = 333
   AND to_date(crapenl.dtmvtolt, 'dd/mm/rrrr') = to_date('14/06/2019', 'dd/mm/rrrr');
   
UPDATE crapenl
   SET crapenl.cdcooper = 1
      ,crapenl.nrdconta = 2902605
 WHERE crapenl.cdcooper = 1
   AND crapenl.nrseqenv = 15214142
   AND crapenl.cdcoptfn = 1
   AND crapenl.cdagetfn = 18
   AND crapenl.nrterfin = 333
   AND to_date(crapenl.dtmvtolt, 'dd/mm/rrrr') = to_date('24/06/2019', 'dd/mm/rrrr');
   
UPDATE crapenl
   SET crapenl.cdcooper = 1
      ,crapenl.nrdconta = 2902605
 WHERE crapenl.cdcooper = 1
   AND crapenl.nrseqenv = 15289719
   AND crapenl.cdcoptfn = 1
   AND crapenl.cdagetfn = 18
   AND crapenl.nrterfin = 334
   AND to_date(crapenl.dtmvtolt, 'dd/mm/rrrr') = to_date('02/07/2019', 'dd/mm/rrrr');
   
UPDATE crapenl
   SET crapenl.cdcooper = 1
      ,crapenl.nrdconta = 1940244
 WHERE crapenl.cdcooper = 1
   AND crapenl.nrseqenv = 15380530
   AND crapenl.cdcoptfn = 1
   AND crapenl.cdagetfn = 197
   AND crapenl.nrterfin = 360
   AND to_date(crapenl.dtmvtolt, 'dd/mm/rrrr') = to_date('08/07/2019', 'dd/mm/rrrr');
   
UPDATE crapenl
   SET crapenl.cdcooper = 1
      ,crapenl.nrdconta = 9524819
 WHERE crapenl.cdcooper = 1
   AND crapenl.nrseqenv = 15392307
   AND crapenl.cdcoptfn = 1
   AND crapenl.cdagetfn = 42
   AND crapenl.nrterfin = 287
   AND to_date(crapenl.dtmvtolt, 'dd/mm/rrrr') = to_date('09/07/2019', 'dd/mm/rrrr');
   
UPDATE crapenl
   SET crapenl.cdcooper = 1
      ,crapenl.nrdconta = 9235515
 WHERE crapenl.cdcooper = 1
   AND crapenl.nrseqenv = 15411017
   AND crapenl.cdcoptfn = 1
   AND crapenl.cdagetfn = 79
   AND crapenl.nrterfin = 298
   AND to_date(crapenl.dtmvtolt, 'dd/mm/rrrr') = to_date('10/07/2019', 'dd/mm/rrrr');
   
UPDATE crapenl
   SET crapenl.cdcooper = 1
      ,crapenl.nrdconta = 8021503
 WHERE crapenl.cdcooper = 1
   AND crapenl.nrseqenv = 15442097
   AND crapenl.cdcoptfn = 1
   AND crapenl.cdagetfn = 196
   AND crapenl.nrterfin = 326
   AND to_date(crapenl.dtmvtolt, 'dd/mm/rrrr') = to_date('11/07/2019', 'dd/mm/rrrr');
   
UPDATE crapenl
   SET crapenl.cdcooper = 1
      ,crapenl.nrdconta = 6349706
 WHERE crapenl.cdcooper = 16
   AND crapenl.nrseqenv = 15334008
   AND crapenl.cdcoptfn = 16
   AND crapenl.cdagetfn = 11
   AND crapenl.nrterfin = 27
   AND to_date(crapenl.dtmvtolt, 'dd/mm/rrrr') = to_date('05/07/2019', 'dd/mm/rrrr');
   
UPDATE crapenl
   SET crapenl.cdcooper = 16
      ,crapenl.nrdconta = 72010
 WHERE crapenl.cdcooper = 16
   AND crapenl.nrseqenv = 15430545
   AND crapenl.cdcoptfn = 1
   AND crapenl.cdagetfn = 68
   AND crapenl.nrterfin = 314
   AND to_date(crapenl.dtmvtolt, 'dd/mm/rrrr') = to_date('10/07/2019', 'dd/mm/rrrr');
   
UPDATE crapenl
   SET crapenl.cdcooper = 16
      ,crapenl.nrdconta = 72010
 WHERE crapenl.cdcooper = 16
   AND crapenl.nrseqenv = 15448692
   AND crapenl.cdcoptfn = 1
   AND crapenl.cdagetfn = 68
   AND crapenl.nrterfin = 314
   AND to_date(crapenl.dtmvtolt, 'dd/mm/rrrr') = to_date('11/07/2019', 'dd/mm/rrrr');

commit;
