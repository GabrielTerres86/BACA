DECLARE
/*
  Autor   : 
  Data    : Março/2021

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
             6,  -- tpproduto, --Desconto Cheque
             rw_crapcop.incomite, -- incomite,
             rw_crapcop.incontigen, -- incontigen,
             rw_crapcop.inanlautom,  -- inanlautom,
             'PoliticaBorderoChequesPF',  -- nmregmpf,
             'PoliticaBorderoChequesPJ', -- nmregmpj,
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



-- crapaca
INSERT INTO CRAPACA
  (NMDEACAO
  ,NMPACKAG
  ,NMPROCED
  ,LSTPARAM
  ,NRSEQRDR)
VALUES
  ('BUSCA_DETALHES_CHQ_BORDERO'
  ,'TELA_ATENDA_DESCTO'
  ,'pc_detalhes_chq_bordero_web'
  ,'pr_nrdconta,pr_nrborder,pr_chave'
  ,(SELECT a.nrseqrdr
     FROM CRAPRDR a
    WHERE a.nmprogra = 'TELA_ATENDA_DESCTO'
      AND ROWNUM = 1));

INSERT INTO CRAPACA
  (NMDEACAO
  ,NMPACKAG
  ,NMPROCED
  ,LSTPARAM
  ,NRSEQRDR)
VALUES
  ('CONSULTA_CHEQUE_BORDERO'
  ,'TELA_ATENDA_DESCTO'
  ,'pc_busca_cheques_bordero_web'
  ,'pr_nrdconta,pr_nrborder'
  ,(SELECT a.nrseqrdr
     FROM CRAPRDR a
    WHERE a.nmprogra = 'TELA_ATENDA_DESCTO'
      AND ROWNUM = 1));

INSERT INTO CRAPACA
  (NMDEACAO
  ,NMPACKAG
  ,NMPROCED
  ,LSTPARAM
  ,NRSEQRDR)
VALUES
  ('OBTER_LISTA_BORDERO_CHQ'
  ,'TELA_ATENDA_DESCTO'
  ,'pc_busca_borderos_chq_web'
  ,'pr_nrdconta'
  ,(SELECT a.nrseqrdr
     FROM CRAPRDR a
    WHERE a.nmprogra = 'TELA_ATENDA_DESCTO'
      AND ROWNUM = 1));

INSERT INTO CRAPACA
  (NMDEACAO
  ,NMPACKAG
  ,NMPROCED
  ,LSTPARAM
  ,NRSEQRDR)
VALUES
  ('EFETUAR_ANALISE_BORDERO'
  ,'TELA_ATENDA_DESCTO'
  ,'pc_efetua_analise_bordero_web'
  ,'pr_nrdconta,pr_nrborder'
  ,(SELECT a.nrseqrdr
     FROM CRAPRDR a
    WHERE a.nmprogra = 'TELA_ATENDA_DESCTO'
      AND ROWNUM = 1));

INSERT INTO CRAPACA
  (NMDEACAO
  ,NMPACKAG
  ,NMPROCED
  ,LSTPARAM
  ,NRSEQRDR)
VALUES
  ('TRATA_CRITICA_BLOQUEIO'
  ,'TELA_ATENDA_DESCTO'
  ,'pc_trata_critica_bloq_web'
  ,'pr_nrdconta,pr_nrborder,pr_remoChqe,pr_remoCust'
  ,(SELECT a.nrseqrdr
     FROM CRAPRDR a
    WHERE a.nmprogra = 'TELA_ATENDA_DESCTO'
      AND ROWNUM = 1));

INSERT INTO CRAPACA
  (NMDEACAO
  ,NMPACKAG
  ,NMPROCED
  ,LSTPARAM
  ,NRSEQRDR)
VALUES
  ('ENVIAR_BORDERO_ESTEIRA'
  ,'TELA_ATENDA_DESCTO'
  ,'pc_analisar_bordero_web'
  ,'pr_nrdconta,pr_nrborder,pr_tpenvest'
  ,(SELECT a.nrseqrdr
     FROM CRAPRDR a
    WHERE a.nmprogra = 'TELA_ATENDA_DESCTO'
      AND ROWNUM = 1));

INSERT INTO CRAPACA
  (NMDEACAO
  ,NMPACKAG
  ,NMPROCED
  ,LSTPARAM
  ,NRSEQRDR)
VALUES
  ('SENHA_ENVIAR_BORDER_ESTEIRA'
  ,'TELA_ATENDA_DESCTO'
  ,'pc_enviar_borde_analise_manual'
  ,'pr_nrborder,pr_nrdconta,pr_dtmovito'
  ,(SELECT a.nrseqrdr
     FROM CRAPRDR a
    WHERE a.nmprogra = 'TELA_ATENDA_DESCTO'
      AND ROWNUM = 1));

UPDATE crapaca a
   SET a.lstparam = a.lstparam || ',pr_vlminliq,pr_vlminliq_c,pr_qtminliq,pr_qtminliq_c'
 WHERE a.nmdeacao = 'TAB019_ALTERAR';



--- incluir tela Conaut - Consulta Reaproveitamento
INSERT INTO craprbi
  (cdcooper
  ,inprodut
  ,inpessoa
  ,qtdiarpv)
  (SELECT r.cdcooper
         ,8 inprodut -- bordero Cheque
         ,r.inpessoa
         ,r.qtdiarpv
     FROM craprbi r
    WHERE r.inprodut = 7);

COMMIT;


-- Novas Restrições / Travas análise
INSERT INTO tbdscc_ocorrencias
  (cdocorre
  ,dsocorre
  ,flgbloqueio)
VALUES
  (92
  ,'Proponente com restrição ALERTA/DCTROR'
  ,0);

INSERT INTO tbdscc_ocorrencias
  (cdocorre
  ,dsocorre
  ,flgbloqueio)
VALUES
  (93
  ,'Emitente interno com restrição ALERTA/DCTROR'
  ,0);
  
COMMIT;  
