-- Scripts DML Projetos: PRJ0013792 - Inclusão do cheque especial na esteira de crédito
-- Tipo: Permissões
--------------------- Permissoes ---------------------
DECLARE
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17);

  pr_cdcooper INTEGER;
BEGIN
  
  
  FOR i IN coop.FIRST .. coop.LAST LOOP
    pr_cdcooper := coop(i);
    
    ------ Inicio Realizar cadastro de permissoes para botão 'Analisar'(L) ------ 
    UPDATE craptel
       SET cdopptel = cdopptel || ',L',
           lsopptel = lsopptel || ',ANALISE'
     WHERE cdcooper = pr_cdcooper
       AND nmdatela = 'ATENDA' 
       and nmrotina = 'LIMITE CRED';
  
    -- Permissões de consulta  botão 'Analisar'(L) para os usuários                  
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
             'L',
             ope.cdoperad,
             'LIMITE CRED',
             cop.cdcooper,
             1,
             0,
             2
        FROM crapcop cop, crapope ope
       WHERE cop.cdcooper IN (pr_cdcooper)
         AND ope.cdsitope = 1
         AND cop.cdcooper = ope.cdcooper
         AND trim(upper(ope.cdoperad)) IN (SELECT trim(upper(a.cdoperad))
                                             FROM crapace a
                                            WHERE a.NMDATELA = 'ATENDA'
                                              AND a.cddopcao = 'N' 
                                              AND a.NMROTINA = 'DSC TITS - PROPOSTA'
                                              AND a.cdcooper = cop.cdcooper);
  ------Fim Realizar cadastro de permissoes para botão 'Analisar'(L) ------ 
                                              
  ------ Inicio Realizar cadastro de permissoes para botão 'Detalhes Propostas' (D) ------
    UPDATE craptel
       SET cdopptel = cdopptel || ',D',
           lsopptel = lsopptel || ',DETALHAMENTO'
     WHERE cdcooper = pr_cdcooper
       AND nmdatela = 'ATENDA' 
       and nmrotina = 'LIMITE CRED';
  
    -- Permissões de consulta  botão 'Detalhes Propostas' (D) para os usuários                  
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
             'D',
             ope.cdoperad,
             'LIMITE CRED',
             cop.cdcooper,
             1,
             0,
             2
        FROM crapcop cop, crapope ope
       WHERE cop.cdcooper IN (pr_cdcooper)
         AND ope.cdsitope = 1
         AND cop.cdcooper = ope.cdcooper
         AND trim(upper(ope.cdoperad)) IN (SELECT trim(upper(a.cdoperad))
                                             FROM crapace a
                                            WHERE a.NMDATELA = 'ATENDA'
                                              AND a.cddopcao = 'C' 
                                              AND a.NMROTINA = 'LIMITE CRED'
                                              AND a.cdcooper = cop.cdcooper);                                            
  ------Fim Realizar cadastro de permissoes para botão 'Detalhes Propostas' (D) ------

  END LOOP;


END;
/

COMMIT;