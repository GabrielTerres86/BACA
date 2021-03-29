DECLARE 
  vr_max_prod NUMBER(5);
BEGIN 
      SELECT MAX(cdproduto)+1 INTO vr_max_prod FROM tbcc_produto;
    
      INSERT INTO tbcc_produto
      SELECT NVL(vr_max_prod,56)    cdproduto,
             'LIMITE CREDITO PRE-APROVADO' dsproduto,
             a.flgitem_soa,
             a.flgutiliza_interface_padrao,
             a.flgenvia_sms,
             a.flgcobra_tarifa,
             a.idfaixa_valor,
             a.flgproduto_api
      FROM tbcc_produto a
      WHERE a.cdproduto = 25;
      

      INSERT INTO tbcc_operacoes_produto (CDPRODUTO, CDOPERAC_PRODUTO, DSOPERAC_PRODUTO, TPCONTROLE)
      VALUES  (NVL(vr_max_prod,56), 1, 'Limite Credito Pre-Aprovado Liberado', '2');

      COMMIT;

      
END;
/

DECLARE

  CURSOR cr_motivos IS
    SELECT *
      FROM tbgen_motivo a
     WHERE a.cdproduto = 25
	 ORDER BY a.idmotivo ;

  vr_idmotivo NUMBER(5);
  vr_cdproduto NUMBER(5);
BEGIN

  SELECT MAX(idmotivo)
    INTO vr_idmotivo
    FROM tbgen_motivo;
    
  SELECT a.cdproduto
    INTO vr_cdproduto
    FROM tbcc_produto a
   WHERE a.dsproduto = 'LIMITE CREDITO PRE-APROVADO';

  FOR rw_motivo IN cr_motivos LOOP
  
    vr_idmotivo := vr_idmotivo + 1;
    INSERT INTO tbgen_motivo
      (idmotivo
      ,dsmotivo
      ,cdproduto
      ,flgreserva_sistema
      ,flgativo
      ,flgexibe
      ,flgtipo)
    VALUES
      (vr_idmotivo
      ,rw_motivo.dsmotivo
      ,vr_cdproduto -- limite credito pre-aprovado
      ,rw_motivo.flgreserva_sistema
      ,rw_motivo.flgativo
      ,rw_motivo.flgexibe
      ,rw_motivo.flgtipo);
  
  END LOOP;
  COMMIT;
END;
/

UPDATE crapprm
SET crapprm.dsvlrprm = 'SASP'
WHERE crapprm.cdacesso = 'DBLINK_SAS_DESEN_RO'
OR crapprm.cdacesso = 'DBLINK_SAS_DESEN_RW'
;


UPDATE crapaca a
SET a.lstparam = a.lstparam||',pr_cdproduto'
WHERE a.nmdeacao = 'COMBO_MOTIVOS';

UPDATE crapaca a
SET a.lstparam = a.lstparam||',pr_cdproduto'
WHERE a.nmdeacao = 'GRAVA_PARAM_PREAPV';
 
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

