
Delete crapace ace
where upper(ace.nmdatela) = 'SEGEMP';


INSERT INTO crapace
  (nmdatela,
   cddopcao,
   cdoperad,
   nmrotina,
   cdcooper,
   nrmodulo,
   idevento,
   idambace)
  SELECT 'SEGEMP' nmdatela,
         'A' cddopcao,
         ope.cdoperad cdoperad,
         ' ' nmrotina,
         cop.cdcooper cdcooper,
         1 nrmodulo,
         1 idevento,
         2 idambace
    FROM crapcop cop, crapope ope
   WHERE cop.cdcooper = ope.cdcooper
     AND upper(ope.cdoperad) IN ('F0030513',
                                 'F0032630',
                                 'F0032631',
                                 'F0030542',
                                 'F0030567',
                                 'F0031993',
                                 'F0031810',
                                 'F0030584',
                                 'F0030401',
                                 'F0030978',
                                 'F0030539',
                                 'F0030616',
                                 'F0030481',
                                 'F0030688',
                                 'F0032005',
                                 'F0032386',
                                 'F0030306',
                                 'F0032632',
                                 'F0030066',
                                 'F0030835',
                                 'F0030517',
                                 'F0030689',
                                 'F0032113',
                                 'F0031090');


INSERT INTO crapace
  (nmdatela,
   cddopcao,
   cdoperad,
   nmrotina,
   cdcooper,
   nrmodulo,
   idevento,
   idambace)
  SELECT 'SEGEMP' nmdatela,
         'C' cddopcao,
         ope.cdoperad cdoperad,
         ' ' nmrotina,
         cop.cdcooper cdcooper,
         1 nrmodulo,
         1 idevento,
         2 idambace
    FROM crapcop cop, crapope ope
   WHERE cop.cdcooper = ope.cdcooper
     AND upper(ope.cdoperad) IN ('F0030513',
                                 'F0032630',
                                 'F0032631',
                                 'F0030542',
                                 'F0030567',
                                 'F0031993',
                                 'F0031810',
                                 'F0030584',
                                 'F0030401',
                                 'F0030978',
                                 'F0030539',
                                 'F0030616',
                                 'F0030481',
                                 'F0030688',
                                 'F0032005',
                                 'F0032386',
                                 'F0030306',
                                 'F0032632',
                                 'F0030066',
                                 'F0030835',
                                 'F0030517',
                                 'F0030689',
                                 'F0032113',
                                 'F0031090');

COMMIT;
