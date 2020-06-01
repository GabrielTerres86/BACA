----------------------------------------------------------------------------------------
-- INICIO DML TELA CHQMOB

DECLARE
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17);

  pr_cdcooper INTEGER;
BEGIN

  FOR i IN coop.FIRST .. coop.LAST LOOP
    pr_cdcooper := coop(i);
    -- Insere a tela
    INSERT INTO craptel
      (nmdatela,
       nrmodulo,
       cdopptel,
       tldatela,
       tlrestel,
       flgteldf,
       flgtelbl,
       nmrotina,
       lsopptel,
       inacesso,
       cdcooper,
       idsistem,
       idevento,
       nrordrot,
       nrdnivel,
       nmrotpai,
       idambtel)
      SELECT 'CHQMOB',
             5,
             'L,P,E',
             'Cheque Mobile',
             'Cheque Mobile',
             0,
             1, -- bloqueio da tela 
             ' ',
             'LIBERACAO,PARAMETROS,ESTORNO',
             1,
             pr_cdcooper, -- cooperativa
             1,
             0,
             0,
             0,
             '',
             2
        FROM crapcop
       WHERE cdcooper = pr_cdcooper;
  
    -- Permissões de consulta para os usuários pré-definidos pela CECRED                       
    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace)
      SELECT 'CHQMOB', 'L', ope.cdoperad, ' ', cop.cdcooper, 1, 0, 2
        FROM crapcop cop, crapope ope
       WHERE cop.cdcooper IN (pr_cdcooper)
         AND ope.cdsitope = 1
         AND cop.cdcooper = ope.cdcooper
         AND trim(upper(ope.cdoperad)) = '1';
  
    -- Permissões de consulta para os usuários pré-definidos pela CECRED
    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace)
      SELECT 'CHQMOB', 'P', ope.cdoperad, ' ', cop.cdcooper, 1, 0, 2
        FROM crapcop cop, crapope ope
       WHERE cop.cdcooper IN (pr_cdcooper)
         AND ope.cdsitope = 1
         AND cop.cdcooper = ope.cdcooper
         AND trim(upper(ope.cdoperad)) = '1';
  
    -- Permissões de consulta para os usuários pré-definidos pela CECRED                       
    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace)
      SELECT 'CHQMOB', 'E', ope.cdoperad, ' ', cop.cdcooper, 1, 0, 2
        FROM crapcop cop, crapope ope
       WHERE cop.cdcooper IN (pr_cdcooper)
         AND ope.cdsitope = 1
         AND cop.cdcooper = ope.cdcooper
         AND trim(upper(ope.cdoperad)) = '1';

           
    -- Insere o registro de cadastro do programa
    INSERT INTO crapprg
      (nmsistem,
       cdprogra,
       dsprogra##1,
       dsprogra##2,
       dsprogra##3,
       dsprogra##4,
       nrsolici,
       nrordprg,
       inctrprg,
       cdrelato##1,
       cdrelato##2,
       cdrelato##3,
       cdrelato##4,
       cdrelato##5,
       inlibprg,
       cdcooper)
      SELECT 'CRED',
             'CHQMOB',
             'Cheque Mobile',
             '.',
             '.',
             '.',
             50,
             (select max(crapprg.nrordprg) + 1
                from crapprg
               where crapprg.cdcooper = crapcop.cdcooper
                 and crapprg.nrsolici = 50),
             1,
             0,
             0,
             0,
             0,
             0,
             1,
             cdcooper
        FROM crapcop
       WHERE cdcooper IN (pr_cdcooper);
  
  END LOOP;

END;
