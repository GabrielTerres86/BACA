DECLARE
  vr_max_prod NUMBER(5);
  vr_max_mensagem NUMBER(5);

  CURSOR cr_motivos IS
    SELECT *
      FROM tbgen_motivo a
     WHERE a.cdproduto = 25
     ORDER BY a.idmotivo;

  vr_idmotivo  NUMBER(5);
  vr_cdproduto NUMBER(5);

BEGIN

  INSERT INTO tbgen_notif_msg_origem
    (CDORIGEM_MENSAGEM,
     DSORIGEM_MENSAGEM,
     CDTIPO_MENSAGEM,
     HRINICIO_PUSH,
     HRFIM_PUSH,
     HRTEMPO_VALIDADE_PUSH)
    SELECT (SELECT MAX(notf.cdorigem_mensagem)
              FROM tbgen_notif_msg_origem notf) + 1 cdori,
           'Limite de Crédito Pré-aprovado CDC',
           ori.cdtipo_mensagem,
           ori.hrinicio_push,
           ori.hrfim_push,
           ori.hrtempo_validade_push
      FROM tbgen_notif_msg_origem ori
     WHERE ori.cdorigem_mensagem = 2;

  SELECT MAX(cdproduto) + 1 INTO vr_max_prod FROM tbcc_produto;

  INSERT INTO tbcc_produto
    SELECT vr_max_prod cdproduto,
           'LIMITE CREDITO PRE-APROVADO CDC' dsproduto,
           a.flgitem_soa,
           a.flgutiliza_interface_padrao,
           a.flgenvia_sms,
           a.flgcobra_tarifa,
           a.idfaixa_valor,
           a.flgproduto_api
      FROM tbcc_produto a
     WHERE a.cdproduto = 25;

  INSERT INTO tbcc_operacoes_produto
    (CDPRODUTO, CDOPERAC_PRODUTO, DSOPERAC_PRODUTO, TPCONTROLE)
  VALUES
    (vr_max_prod, 1, 'Limite Credito Pre-Aprovado Liberado CDC', '2');

  --- parte cadastramento dos motivos    
  SELECT MAX(idmotivo) INTO vr_idmotivo FROM tbgen_motivo;

  SELECT a.cdproduto
    INTO vr_cdproduto
    FROM tbcc_produto a
   WHERE a.dsproduto = 'LIMITE CREDITO PRE-APROVADO CDC';

  FOR rw_motivo IN cr_motivos LOOP
  
    vr_idmotivo := vr_idmotivo + 1;
    INSERT INTO tbgen_motivo
      (idmotivo,
       dsmotivo,
       cdproduto,
       flgreserva_sistema,
       flgativo,
       flgexibe,
       flgtipo)
    VALUES
      (vr_idmotivo,
       rw_motivo.dsmotivo,
       vr_cdproduto -- limite credito pre-aprovado
      ,
       rw_motivo.flgreserva_sistema,
       rw_motivo.flgativo,
       rw_motivo.flgexibe,
       rw_motivo.flgtipo);
  
  END LOOP;
  --cadastro da mensagem
  SELECT MAX(cdorigem_mensagem) + 1
    INTO vr_max_mensagem
    FROM tbgen_notif_automatica_prm;

  INSERT INTO tbgen_notif_automatica_prm
    (cdorigem_mensagem,
     cdmotivo_mensagem,
     dsmotivo_mensagem,
     cdmensagem,
     dsvariaveis_mensagem,
     inmensagem_ativa,
     intipo_repeticao,
     nrdias_semana,
     nrsemanas_repeticao,
     nrdias_mes,
     nrmeses_repeticao,
     hrenvio_mensagem,
     nmfuncao_contas,
     dhultima_execucao)
  VALUES
    (vr_max_mensagem,
     28,
     'Oferta de Limite de Crédito Pré-aprovado CDC',
     7070,
     '<br/>#valorcalculado - Valor total que foi calculado (Ex.: 5.000,00)<br/>#valorcontratado - Valor já contratado pelo cooperado (Ex.: 1.500,00)<br/>#valordisponivel - Valor disponível ao cooperado (Ex.: 3.500,00)',
     1,
     2,
     NULL,
     NULL,
     15,
     '1,2,3,4,5,6,7,8,9,10,11,12',
     32400,
     'CREDITO.obterConsultaContasLimPreAprv',
     SYSDATE);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao processar: ' || SQLERRM);
END;
/
