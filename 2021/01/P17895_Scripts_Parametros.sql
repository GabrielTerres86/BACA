-- Scripts DML Projetos: - Inclusão do Desconto cheque especial na esteira de crédito
-- Tipo: Parametros

DECLARE
/*
  Autor   : 
  Data    : Março/2020

  Frequencia: Especifico

  Objetivo  : Rotina para popular nova tabela de parametros TBCRED_PARAMETRO_ANALISE, com tipo de produto 5 (Limite desconto cheque),
*/

  -- Variáveis
  vr_qtcooper NUMBER;
  vr_dscritic VARCHAR2(10000);

  CURSOR cr_crapcop IS
    SELECT   0 incontigen, --Não

           0 incomite, -- Não

           1  inanlautom, -- Sim
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'TIME_RESP_MOTOR_DESC') qtsstime,                                     
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'QTD_MES_HIST_DEVCHQ_DESC') qtmeschq,
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'QTD_MES_HIST_DC_A11_DESC') qtmeschqal11,
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'QTD_MES_HIST_DC_A12_DESC') qtmeschqal12,  
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'QTD_MES_HIST_EST_DESC') qtmesest,
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'QTD_MES_HIST_EMPRES_DESC') qtmesemp,
           --
           cdcooper,
           Initcap(nmrescop) nmrescop

      FROM crapcop cop
     WHERE cop.flgativo = 1
     ORDER BY cop.cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

begin
  FOR rw_crapcop  in cr_crapcop  LOOP
      -- Grava linha para as cooperativas
      BEGIN
        INSERT INTO CECRED.TBCRED_PARAMETRO_ANALISE (
              cdcooper,
              tpproduto,
              incomite,
              incontigen,
              inanlautom,
              nmregmpf,
              nmregmpj,
              qtsstime,
              qtmeschq,
              qtmeschqal11,
              qtmeschqal12,
              qtmesest,
              qtmesemp)        
        VALUES(
             rw_crapcop.cdcooper,  -- cdcooper,
             5,  -- tpproduto, --Desconto Cheque
             rw_crapcop.incomite, -- incomite,
             rw_crapcop.incontigen, -- incontigen,
             rw_crapcop.inanlautom,  -- inanlautom,
             'PoliticaDescontoChequesPF',  -- nmregmpf,
             'PoliticaDescontoChequesPJ', -- nmregmpj,
             rw_crapcop.qtsstime,  -- qtsstime,
             rw_crapcop.qtmeschq,  -- qtmeschq,
             NVL(rw_crapcop.qtmeschqal11,0), -- qtmeschqal11,
             NVL(rw_crapcop.qtmeschqal12,0), -- qtmeschqal12,
             rw_crapcop.qtmesest,  -- qtmesest,
             rw_crapcop.qtmesemp  -- qtmesemp
             )  ;     
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não inseriu linha na tab TBCRED_PARAMETRO_ANALISE - ' || SQLERRM;
          DBMS_OUTPUT.PUT_LINE (vr_dscritic);
          EXIT;
      END;
  END LOOP;
END;
/

commit;


--crapaca
INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('OBTEM_PROPOSTAS_DSCT_CHEQ','TELA_ATENDA_DESCTO','pc_obtem_propostas_chq_web','pr_nrdconta',
                      (SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_ATENDA_DESCTO' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('CONSULTA_CTR_LIM_DSCT_CHQ','TELA_ATENDA_DESCTO','pc_consultar_contrato_web','pr_nrdconta,pr_tpctrlim,pr_nrctrlim,pr_tpctrprp',
                      (SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_ATENDA_DESCTO' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('CANCELAR_CTR_LIM_DSCT_CHQ', 'LIMI0003', 'pc_cancelar_contrato_web', 'pr_nrdconta,pr_nrctrlim,pr_tpctrlim',
                      (SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1)); 
                      
INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('CONSULTA_LIMITE_MANUTENCAO','TELA_ATENDA_DESCTO','pc_busca_dados_limi_manut_web','pr_nrdconta,pr_nrctrlim,pr_tpctrlim',
                      (SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_ATENDA_DESCTO' AND ROWNUM = 1));    

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('OBTER_DADOS_DESCONTO_CHEQUE', 'TELA_ATENDA_DESCTO', 'pc_busca_dados_dscchq_web', 'pr_nrdconta,pr_idseqttl',
                      (SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_ATENDA_DESCTO' AND ROWNUM = 1));     					  

UPDATE crapaca a
   SET a.lstparam = 'pr_nrdconta,pr_nrctrlim,pr_tpctrlim'
 WHERE a.nmdeacao = 'ACEITAR_REJEICAO_LIM_TIT';

UPDATE crapaca a
   SET a.nmdeacao = 'VERIFICA_CONTING_LIMITE'
      ,a.lstparam = 'pr_tpctrlim'
      ,a.nmproced = 'pc_busca_sit_analise_web'
 WHERE a.nmdeacao = 'VERIFICA_CONTING_LIMCHEQ';

UPDATE crapaca a
   SET a.lstparam = a.lstparam || ',pr_tpctrlim'
 WHERE a.nmdeacao = 'OBTEM_PROPOSTA_ACIONA'
   AND a.nmproced = 'pc_obtem_proposta_aciona_web'; 

UPDATE crapaca a
   SET a.nmdeacao = 'VERIFICA_IMPRESSAO_LIMITE'
      ,a.nmpackag = 'LIMI0003'
      ,a.lstparam = a.lstparam || ',pr_tpctrlim'
      ,a.nmproced = 'pc_verifica_impressao_limite'
      ,a.nrseqrdr = (SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1)
 WHERE a.nmdeacao = 'VERIFICA_IMPRESSAO';

commit;
                      
