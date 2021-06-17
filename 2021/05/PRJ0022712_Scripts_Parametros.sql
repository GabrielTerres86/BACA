-- PRJ0022712

--crapaca
INSERT INTO crapaca
  (nmdeacao
  ,nmpackag
  ,nmproced
  ,lstparam
  ,nrseqrdr)
VALUES
  ('LISTA_CARGAS_LIMITE'
  ,'TELA_IMPPRE'
  ,'pc_lista_cargas_limite'
  ,'pr_nrregist,pr_nriniseq,pr_tpctrlim'
  ,(SELECT a.nrseqrdr
     FROM craprdr a
    WHERE a.nmprogra = 'TELA_IMPPRE'
      AND ROWNUM = 1));
     
INSERT INTO crapaca
  (nmdeacao
  ,nmpackag
  ,nmproced
  ,lstparam
  ,nrseqrdr)
VALUES
  ('EXEC_CARGA_LIMITE'
  ,'TELA_IMPPRE'
  ,'pc_proc_carga_limite'
  ,'pr_idcarga,pr_tpctrlim,pr_cddopcao,pr_dsrejeicao'
  ,(SELECT a.nrseqrdr
     FROM craprdr a
    WHERE a.nmprogra = 'TELA_IMPPRE'
      AND ROWNUM = 1));

      
INSERT INTO crapaca
  (nmdeacao
  ,nmpackag
  ,nmproced
  ,lstparam
  ,nrseqrdr)
VALUES
  ('LISTA_DETALHE_CARGAS_LIMITE'
  ,'TELA_IMPPRE'
  ,'pc_lista_hist_cargas_limite'
  ,'pr_cdcooper,pr_idcarga,pr_tpctrlim,pr_tpcarga,pr_indsitua,pr_dtlibera,pr_dtliberafim,pr_dtvigencia,pr_dtvigenciafim,pr_skcarga,pr_dscarga,pr_tpretorn,pr_nrregist,pr_nriniseq'
  ,(SELECT a.nrseqrdr
     FROM craprdr a
    WHERE a.nmprogra = 'TELA_IMPPRE'
      AND ROWNUM = 1));       
     

UPDATE crapaca a
   SET a.lstparam = a.lstparam || ',pr_tpprodut'
 WHERE a.nmdeacao = 'BUSCA_CRAPPRE';

UPDATE crapaca a
   SET a.lstparam = a.lstparam || ',pr_tpprodut'
 WHERE a.nmdeacao = 'GRAVA_CRAPPRE';
 
UPDATE crapaca a
   SET a.lstparam = a.lstparam || ',pr_tpctrlim'
 WHERE a.nmdeacao = 'EXEC_BLOQ_CARGA';

UPDATE crapaca a
   SET a.lstparam = a.lstparam || ',pr_tpctrlim'
 WHERE a.nmdeacao = 'EXEC_EXCLU_MANUAL';

UPDATE crapaca a
SET a.lstparam = a.lstparam||',pr_cdproduto'
WHERE a.nmdeacao = 'COMBO_MOTIVOS';

UPDATE crapaca a
SET a.lstparam = a.lstparam||',pr_cdproduto'
WHERE a.nmdeacao = 'GRAVA_PARAM_PREAPV';

UPDATE crapaca a
   SET a.lstparam = a.lstparam || ',pr_preapvhib, pr_vlmaxhibfis, pr_vlmaxhibjur'
 WHERE a.nmdeacao = 'TAB089_ALTERAR';
 
insert into craprdr ( NMPROGRA, DTSOLICI)
values ( 'LIMI0004', TRUNC(SYSDATE));

INSERT INTO crapaca
  (nmdeacao
  ,nmpackag
  ,nmproced
  ,lstparam
  ,nrseqrdr)
VALUES
  ('RESUMO_PRE_APROVADO_LIM'
  ,'LIMI0004'
  ,'pc_resumo_pre_aprov_lim'
  ,'pr_nrdconta,pr_tpctrlim'
  ,(SELECT a.nrseqrdr
     FROM craprdr a
    WHERE a.nmprogra = 'LIMI0004'
      AND ROWNUM = 1));   

INSERT INTO crapaca
  (nmdeacao
  ,nmpackag
  ,nmproced
  ,lstparam
  ,nrseqrdr)
VALUES
  ('MOTIVOS_SEM_LIMITE_PREAPRV'
  ,'LIMI0004'
  ,'pc_motivos_sem_lim_preaprv'
  ,'pr_nrdconta,pr_tpctrlim'
  ,(SELECT a.nrseqrdr
     FROM craprdr a
    WHERE a.nmprogra = 'LIMI0004'
      AND ROWNUM = 1));  	  
 
COMMIT;

-- ENVNOT
-- Cadastro Origem das mensagens enviadas via Notificacoes/PUSH no InternetBank e Mobile
INSERT INTO tbgen_notif_msg_origem 
  (CDORIGEM_MENSAGEM
  ,DSORIGEM_MENSAGEM
  ,CDTIPO_MENSAGEM
  ,HRINICIO_PUSH
  ,HRFIM_PUSH
  ,HRTEMPO_VALIDADE_PUSH)
  SELECT (SELECT MAX(notf.cdorigem_mensagem)
            FROM tbgen_notif_msg_origem notf) + 1 cdori
        ,'Limite de Crédito Pré-aprovado'
        ,ori.cdtipo_mensagem
        ,ori.hrinicio_push
        ,ori.hrfim_push
        ,ori.hrtempo_validade_push
    FROM tbgen_notif_msg_origem ori
   WHERE ori.cdorigem_mensagem = 2;
COMMIT;

--Alterar o valor 'cdorigem_mensagem' que foi cadastrada em producao como 8, deve pegar novo valor gerado na tbgen_notif_msg_origem
-- Cadastro de mensagens para envio de Notificacoes/PUSH no InternetBank e Mobile
UPDATE tbgen_notif_msg_cadastro a 
   SET a.cdorigem_mensagem =
       (SELECT a.cdorigem_mensagem
          FROM tbgen_notif_msg_origem a
         WHERE a.dsorigem_mensagem = 'Limite de Crédito Pré-aprovado')  
 WHERE a.dstitulo_mensagem = 'Limite de Crédito Pré-aprovado';

-- Parametros para envio de mensagens automaticas via Notificacoes/PUSH no InternetBank e Mobile
UPDATE tbgen_notif_automatica_prm a
   SET a.cdorigem_mensagem   =
       (SELECT a.cdorigem_mensagem
          FROM tbgen_notif_msg_origem a
         WHERE a.dsorigem_mensagem = 'Limite de Crédito Pré-aprovado')
      ,a.dsmotivo_mensagem    = 'Oferta de Limite de Crédito Pré-aprovado'
      ,a.dsvariaveis_mensagem = '<br/>#valorcalculado - Valor total que foi calculado (Ex.: 5.000,00)<br/>#valorcontratado - Valor já contratado pelo cooperado (Ex.: 1.500,00)<br/>#valordisponivel - Valor disponível ao cooperado (Ex.: 3.500,00)'
      ,a.nmfuncao_contas = 'CREDITO.obterConsultaContasLimPreAprv'
 WHERE a.dsmotivo_mensagem = 'Limite de Crédito Pré-aprovado';
COMMIT;









