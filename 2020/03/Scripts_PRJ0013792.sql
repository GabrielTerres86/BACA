-- Scripts DML Projetos: PRJ0013792 - Inclusão do cheque especial na esteira de crédito

-- armazenar tela para interface web
INSERT INTO CRAPRDR (NMPROGRA, DTSOLICI) values ('LIMI0003', sysdate);
COMMIT;


--------------------- Crapaca ---------------------
INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('VERIFICA_CONTING_LIMCHEQ','LIMI0003','pc_conting_limcheq_web','pr_cdcooper',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('ENVIAR_ESTEIRA_LIMITE','LIMI0003','pc_analisar_proposta','pr_tpenvest,pr_nrctrlim,pr_tpctrlim,pr_nrdconta,pr_dtmovito',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('SENHA_ENVIAR_ESTEIRA_LIMITE','LIMI0003','pc_enviar_proposta_manual','pr_nrctrlim,pr_tpctrlim,pr_nrdconta,pr_dtmovito',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('BUSCA_MOTIVOS_ANULA_LIMITE','LIMI0003','pc_busca_moti_anula','pr_tpproduto,pr_nrdconta,pr_nrctrato,pr_tpctrlim',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('GRAVA_MOTIVO_ANULA_LIMITE','LIMI0003','pc_grava_moti_anula','pr_tpproduto,pr_nrdconta,pr_nrctrato,pr_tpctrlim,pr_cdmotivo,pr_dsmotivo,pr_dsobservacao',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('GERA_IMPRESSAO_LIMITE','LIMI0003','pc_gera_impressao','pr_nrdconta,pr_idseqttl,pr_idimpres,pr_tpctrlim,pr_nrctrlim,pr_dsiduser,pr_flgerlog',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));

COMMIT;

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
         AND trim(upper(ope.cdoperad)) IN (SELECT a.cdoperad
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
         AND trim(upper(ope.cdoperad)) IN (SELECT a.cdoperad
                                             FROM crapace a
                                            WHERE a.NMDATELA = 'ATENDA'
                                              AND a.cddopcao = 'C' 
                                              AND a.NMROTINA = 'LIMITE CRED'
                                              AND a.cdcooper = cop.cdcooper);                                            
  ------Fim Realizar cadastro de permissoes para botão 'Detalhes Propostas' (D) ------

  END LOOP;

  COMMIT;
END;
---------------------

