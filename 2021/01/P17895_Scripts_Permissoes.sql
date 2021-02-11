-- Scripts DML Projetos: PRJ0017895 - Inclusão do limite de cheque e bordero de cheque no motor e esteira de crédito
-- Tipo: Permissões
--------------------- Permissoes ---------------------
DECLARE

BEGIN

  FOR rw_crapcop IN (SELECT cdcooper
                       FROM crapcop c
                      WHERE c.flgativo = 1) LOOP
  
    UPDATE craptel t
       SET t.lsopptel = REPLACE(t.lsopptel, 'CANCELAMENTO', 'CANCELAR CONTRATO')
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'ATENDA'
       AND UPPER(t.nmrotina) = 'DSC CHQS - LIMITE';
  
    UPDATE craptel t
       SET t.lsopptel = REPLACE(t.lsopptel, 'CONFIRMAR NOVO LIMITE', 'EFETIVAR')
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'ATENDA'
       AND UPPER(t.nmrotina) = 'DSC CHQS - LIMITE';
  
    INSERT INTO crapace
      (nmdatela
      ,cddopcao
      ,cdoperad
      ,nmrotina
      ,cdcooper
      ,nrmodulo
      ,idevento
      ,idambace)
      SELECT 'ATENDA'
            ,'L'
            ,ope.cdoperad
            ,'DSC CHQS - LIMITE'
            ,ope.cdcooper
            ,1
            ,0
            ,2
        FROM crapace ace
            ,crapope ope
       WHERE UPPER(ace.nmdatela) = 'ATENDA'
         AND UPPER(ace.cddopcao) = 'C'
         AND UPPER(ace.nmrotina) = 'DSC CHQS - LIMITE'
         AND ace.cdcooper = rw_crapcop.cdcooper
         AND ace.idambace = 2
         AND ope.cdcooper = ace.cdcooper
         AND UPPER(ope.cdoperad) = UPPER(ace.cdoperad)
         AND ope.cdsitope = 1
         AND NOT EXISTS (SELECT 1
                FROM crapace c
               WHERE c.cdcooper = ope.cdcooper
                 AND UPPER(c.nmdatela) = 'ATENDA'
                 AND UPPER(c.nmrotina) = 'DSC CHQS - LIMITE'
                 AND UPPER(c.cddopcao) = 'L'
                 AND UPPER(c.cdoperad) = UPPER(ope.cdoperad)
                 AND c.idambace = 2);
  
    ------ Inicio Realizar cadastro de permissoes para botão 'Anular'(Y) ------ 
  
    UPDATE craptel t
       SET t.cdopptel = t.cdopptel || ',Y'
          ,t.lsopptel = t.lsopptel || ',ANULAR'
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'ATENDA'
       AND UPPER(t.nmrotina) = 'DSC CHQS - LIMITE';
  
    -- Permissões de consulta  botão 'Anular'(Y) para os usuários                  
    INSERT INTO crapace
      (nmdatela
      ,cddopcao
      ,cdoperad
      ,nmrotina
      ,cdcooper
      ,nrmodulo
      ,idevento
      ,idambace)
      SELECT 'ATENDA'
            ,'Y'
            ,ope.cdoperad
            ,'DSC CHQS - LIMITE'
            ,ope.cdcooper
            ,1
            ,0
            ,2
        FROM crapace ace
            ,crapope ope
       WHERE UPPER(ace.nmdatela) = 'ATENDA'
         AND UPPER(ace.cddopcao) = 'L' -- Analisar
         AND UPPER(ace.nmrotina) = 'DSC CHQS - LIMITE'
         AND ace.cdcooper = rw_crapcop.cdcooper
         AND ace.idambace = 2
         AND ope.cdcooper = ace.cdcooper
         AND UPPER(ope.cdoperad) = UPPER(ace.cdoperad)
         AND ope.cdsitope = 1;
  
    ------Fim Realizar cadastro de permissoes para botão 'Anular'(Y) ------ 
  
    ------ Inicio Realizar cadastro de permissoes para botão 'Detalhes Propostas' (W) ------
    UPDATE craptel t
       SET t.cdopptel = cdopptel || ',W'
          ,t.lsopptel = lsopptel || ',DETALHAMENTO'
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'ATENDA'
       AND UPPER(t.nmrotina) = 'DSC CHQS - LIMITE';
  
    -- Permissões de consulta  botão 'Detalhes Propostas' (W) para os usuários                  
    INSERT INTO crapace
      (nmdatela
      ,cddopcao
      ,cdoperad
      ,nmrotina
      ,cdcooper
      ,nrmodulo
      ,idevento
      ,idambace)
      SELECT 'ATENDA'
            ,'W'
            ,ope.cdoperad
            ,'DSC CHQS - LIMITE'
            ,ope.cdcooper
            ,1
            ,0
            ,2
        FROM crapace ace
            ,crapope ope
       WHERE UPPER(ace.nmdatela) = 'ATENDA'
         AND UPPER(ace.cddopcao) = 'C'
         AND UPPER(ace.nmrotina) = 'DSC CHQS - LIMITE'
         AND ace.cdcooper = rw_crapcop.cdcooper
         AND ace.idambace = 2
         AND ope.cdcooper = ace.cdcooper
         AND UPPER(ope.cdoperad) = UPPER(ace.cdoperad)
         AND ope.cdsitope = 1;
  
    ------Fim Realizar cadastro de permissoes para botão 'Detalhes Propostas' (W) ------
  
    ------ Inicio Realizar cadastro de permissoes para botão 'Detalhes Propostas' (P) ------
    UPDATE craptel t
       SET t.cdopptel = cdopptel || ',P'
          ,t.lsopptel = lsopptel || ',CANCELAR PROPOSTA'
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'ATENDA'
       AND UPPER(t.nmrotina) = 'DSC CHQS - LIMITE';
  
    -- Permissões de consulta  botão 'Cancelar Proposta' (P) para os usuários                  
    INSERT INTO crapace
      (nmdatela
      ,cddopcao
      ,cdoperad
      ,nmrotina
      ,cdcooper
      ,nrmodulo
      ,idevento
      ,idambace)
      SELECT 'ATENDA'
            ,'P'
            ,ope.cdoperad
            ,'DSC CHQS - LIMITE'
            ,ope.cdcooper
            ,1
            ,0
            ,2
        FROM crapace ace
            ,crapope ope
       WHERE UPPER(ace.nmdatela) = 'ATENDA'
         AND UPPER(ace.cddopcao) = 'C'
         AND UPPER(ace.nmrotina) = 'DSC CHQS - LIMITE'
         AND ace.cdcooper = rw_crapcop.cdcooper
         AND ace.idambace = 2
         AND ope.cdcooper = ace.cdcooper
         AND UPPER(ope.cdoperad) = UPPER(ace.cdoperad)
         AND ope.cdsitope = 1;
  
  ------Fim Realizar cadastro de permissoes para botão 'Cancelar Proposta' (P) ------
  
  ------ Inicio Realizar cadastro de permissoes para botão 'Manutenção' (J) ------
    UPDATE craptel t
       SET t.cdopptel = cdopptel || ',J'
          ,t.lsopptel = lsopptel || ',MANUTENCAO'
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'ATENDA'
       AND UPPER(t.nmrotina) = 'DSC CHQS - LIMITE';
  
    -- Permissões de consulta  botão 'Manutenção' (J) para os usuários                  
    INSERT INTO crapace
      (nmdatela
      ,cddopcao
      ,cdoperad
      ,nmrotina
      ,cdcooper
      ,nrmodulo
      ,idevento
      ,idambace)
      SELECT 'ATENDA'
            ,'J'
            ,ope.cdoperad
            ,'DSC CHQS - LIMITE'
            ,ope.cdcooper
            ,1
            ,0
            ,2
        FROM crapace ace
            ,crapope ope
       WHERE UPPER(ace.nmdatela) = 'ATENDA'
         AND UPPER(ace.cddopcao) = 'I'
         AND UPPER(ace.nmrotina) = 'DSC CHQS - LIMITE'
         AND ace.cdcooper = rw_crapcop.cdcooper
         AND ace.idambace = 2
         AND ope.cdcooper = ace.cdcooper
         AND UPPER(ope.cdoperad) = UPPER(ace.cdoperad)
         AND ope.cdsitope = 1;
  
  ------Fim Realizar cadastro de permissoes para botão 'Manutenção' (J) ------
  
  END LOOP;

END;
/

COMMIT;
