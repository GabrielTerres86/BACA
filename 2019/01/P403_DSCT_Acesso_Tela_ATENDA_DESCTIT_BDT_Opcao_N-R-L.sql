  /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela ATENDA->DESCONTOS->TITULOS->BORDEROS - Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 6
    Autor       : (Paulo Penteado GFT) 
    Data        : 17/01/2019
    Objetivo    : Realiza o cadastro das novas funcionalidades da tela ATENDA->DESCONTOS->TÍTULOS->BORDERÔS para as
                  ações N = ANALISE, R = REJEITAR e L = LIBERACAO

    SELECT * FROM craptel WHERE nmrotina = 'DSC TITS - BORDERO' AND nmdatela = 'ATENDA' AND cdcooper = 1
    cdopptel: @     ,N      ,C       ,E       ,M        ,L        ,D       ,P    ,I      ,R       ,A      ,E      ,X
    lsopptel: ACESSO,ANALISE,CONSULTA,EXCLUSAO,IMPRESSAO,LIBERACAO,PREJUIZO,PAGAR,INCLUIR,REJEITAR,ALTERAR,EXCLUIR,EXTRATO
  ---------------------------------------------------------------------------------------------------------------------*/ 
DECLARE 
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(1,5,10,13,14); -- EX: Cooperativas(1,3,7,11);
  
  pr_cdcooper INTEGER;
BEGIN
  FOR i IN coop.FIRST .. coop.LAST
  LOOP
    pr_cdcooper := coop(i);

    INSERT INTO crapace
        (nmdatela,
         cddopcao,
         cdoperad,   
         nmrotina,   
         cdcooper,   
         nrmodulo,   
         idevento,   
         idambace)
        SELECT 'ATENDA', 
               'N', -- ANALISE
               ope.cdoperad,
               'DSC TITS - BORDERO',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               2
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.cdcooper        IN (pr_cdcooper)
           AND ope.cdsitope        = 1 
           AND ope.cdcooper        = cop.cdcooper
           AND acn.cdcooper        = ope.cdcooper
           AND UPPER(acn.cdoperad) = UPPER(ope.cdoperad)
           AND UPPER(acn.cddopcao) = 'I'
           AND UPPER(acn.nmdatela) = 'LANBDT'
           AND acn.idambace        = 1
           AND NOT EXISTS( SELECT 1
                             FROM crapace ace
                            WHERE ace.cdcooper        = acn.cdcooper
                              AND UPPER(ace.nmdatela) = 'ATENDA'
                              AND UPPER(ace.nmrotina) = 'DSC TITS - BORDERO'
                              AND UPPER(ace.cddopcao) = 'N'
                              AND UPPER(ace.cdoperad) = UPPER(acn.cdoperad)
                              AND ace.idambace        = 2 )
         UNION    
        SELECT 'ATENDA', 
               'N', -- ANALISE
               ope.cdoperad,
               'DSC TITS - BORDERO',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               acn.idambace
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.cdcooper        IN (pr_cdcooper)
           AND ope.cdsitope        = 1 
           AND ope.cdcooper        = cop.cdcooper
           AND acn.cdcooper        = ope.cdcooper
           AND UPPER(acn.cdoperad) = UPPER(ope.cdoperad)
           AND UPPER(ope.cdoperad) IN ('F0030584', 'F0030978') -- permissões para a área de negócio 
           AND UPPER(acn.cddopcao) = '@'
           AND UPPER(acn.nmdatela) = 'ATENDA'
           AND UPPER(acn.nmrotina) = 'DSC TITS - BORDERO'
           AND acn.idambace        = 2
           AND NOT EXISTS( SELECT 1
                             FROM crapace ace
                            WHERE ace.cdcooper        = acn.cdcooper
                              AND UPPER(ace.nmdatela) = 'ATENDA'
                              AND UPPER(ace.nmrotina) = 'DSC TITS - BORDERO'
                              AND UPPER(ace.cddopcao) = 'N'
                              AND UPPER(ace.cdoperad) = UPPER(acn.cdoperad)
                              AND ace.idambace        = 2 );

    INSERT INTO crapace
        (nmdatela,
         cddopcao,
         cdoperad,   
         nmrotina,   
         cdcooper,   
         nrmodulo,   
         idevento,   
         idambace)
        SELECT 'ATENDA', 
               'R', -- REJEITAR
               ope.cdoperad,
               'DSC TITS - BORDERO',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               2
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.cdcooper        IN (pr_cdcooper)
           AND ope.cdsitope        = 1 
           AND ope.cdcooper        = cop.cdcooper
           AND acn.cdcooper        = ope.cdcooper
           AND UPPER(acn.cdoperad) = UPPER(ope.cdoperad)
           AND UPPER(acn.cddopcao) = 'I'
           AND UPPER(acn.nmdatela) = 'LANBDT'
           AND UPPER(acn.idambace) = 1
           AND NOT EXISTS( SELECT 1
                             FROM crapace ace
                            WHERE ace.cdcooper        = acn.cdcooper
                              AND UPPER(ace.nmdatela) = 'ATENDA'
                              AND UPPER(ace.nmrotina) = 'DSC TITS - BORDERO'
                              AND UPPER(ace.cddopcao) = 'R'
                              AND UPPER(ace.cdoperad) = UPPER(acn.cdoperad)
                              AND ace.idambace        = 2 )
         UNION    
        SELECT 'ATENDA', 
               'R', -- REJEITAR
               ope.cdoperad,
               'DSC TITS - BORDERO',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               acn.idambace
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.cdcooper        IN (pr_cdcooper)
           AND ope.cdsitope        = 1 
           AND ope.cdcooper        = cop.cdcooper
           AND acn.cdcooper        = ope.cdcooper
           AND UPPER(acn.cdoperad) = UPPER(ope.cdoperad)
           AND UPPER(ope.cdoperad) IN ('F0030584', 'F0030978') -- permissões para a área de negócio 
           AND UPPER(acn.cddopcao) = '@'
           AND UPPER(acn.nmdatela) = 'ATENDA'
           AND UPPER(acn.nmrotina) = 'DSC TITS - BORDERO'
           AND acn.idambace        = 2
           AND NOT EXISTS( SELECT 1
                             FROM crapace ace
                            WHERE ace.cdcooper        = acn.cdcooper
                              AND UPPER(ace.nmdatela) = 'ATENDA'
                              AND UPPER(ace.nmrotina) = 'DSC TITS - BORDERO'
                              AND UPPER(ace.cddopcao) = 'R'
                              AND UPPER(ace.cdoperad) = UPPER(acn.cdoperad)
                              AND ace.idambace        = 2 );

    INSERT INTO crapace
        (nmdatela,
         cddopcao,
         cdoperad,   
         nmrotina,   
         cdcooper,   
         nrmodulo,   
         idevento,   
         idambace)
        SELECT 'ATENDA', 
               'L', -- LIBERACAO
               ope.cdoperad,
               'DSC TITS - BORDERO',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               2
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.cdcooper        IN (pr_cdcooper)
           AND ope.cdsitope        = 1 
           AND ope.cdcooper        = cop.cdcooper
           AND acn.cdcooper        = ope.cdcooper
           AND UPPER(acn.cdoperad) = UPPER(ope.cdoperad)
           AND UPPER(acn.cddopcao) = 'I'
           AND UPPER(acn.nmdatela) = 'LANBDT'
           AND acn.idambace        = 1
           AND NOT EXISTS( SELECT 1
                             FROM crapace ace
                            WHERE ace.cdcooper        = acn.cdcooper
                              AND UPPER(ace.nmdatela) = 'ATENDA'
                              AND UPPER(ace.nmrotina) = 'DSC TITS - BORDERO'
                              AND UPPER(ace.cddopcao) = 'L'
                              AND UPPER(ace.cdoperad) = UPPER(acn.cdoperad)
                              AND ace.idambace        = 2 )
         UNION    
        SELECT 'ATENDA', 
               'L', -- LIBERACAO
               ope.cdoperad,
               'DSC TITS - BORDERO',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               acn.idambace
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.cdcooper        IN (pr_cdcooper)
           AND ope.cdsitope        = 1 
           AND ope.cdcooper        = cop.cdcooper
           AND acn.cdcooper        = ope.cdcooper
           AND UPPER(acn.cdoperad) = UPPER(ope.cdoperad)
           AND UPPER(ope.cdoperad) IN ('F0030584', 'F0030978') -- permissões para a área de negócio 
           AND UPPER(acn.cddopcao) = '@'
           AND UPPER(acn.nmdatela) = 'ATENDA'
           AND UPPER(acn.nmrotina) = 'DSC TITS - BORDERO'
           AND acn.idambace        = 2
           AND NOT EXISTS( SELECT 1
                             FROM crapace ace
                            WHERE ace.cdcooper        = acn.cdcooper
                              AND UPPER(ace.nmdatela) = 'ATENDA'
                              AND UPPER(ace.nmrotina) = 'DSC TITS - BORDERO'
                              AND UPPER(ace.cddopcao) = 'L'
                              AND UPPER(ace.cdoperad) = UPPER(acn.cdoperad)
                              AND ace.idambace        = 2 );
  END LOOP;

  COMMIT;
end;
