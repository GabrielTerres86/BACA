-- INICIO Tela Atenda/Produtos Mobile
DECLARE
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17);
  
  CURSOR cr_craptel is
    SELECT max(nrordrot) + 1 nrordrot FROM craptel;
  rw_craptel cr_craptel%rowtype;

  pr_cdcooper INTEGER;
  
BEGIN
  
  open cr_craptel;
  fetch cr_craptel into rw_craptel;
  close cr_craptel;

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
      SELECT 'ATENDA',
             1,
             '@',
             'Produtos Mobile',
             'Produtos Mobile',
             0,
             1, -- bloqueio da tela 
             'PRODUTOS MOBILE',
             'ACESSO',
             2,
             pr_cdcooper, -- cooperativa
             1,
             0,
             rw_craptel.nrordrot,
             1,
             '',
             2
        FROM crapcop
       WHERE cdcooper = pr_cdcooper;
      
  END LOOP;
END;
