BEGIN
  UPDATE tbgen_notif_automatica_prm
     SET dsmotivo_mensagem = '<br/>#valordisponivelcdc - Valor disponível ao cooperado (Ex.: 3.500,00)',
         nmfuncao_contas   = 'credito.obterConsultaContasPreAprvCdc'
   WHERE cdorigem_mensagem = 15;
   COMMIT;
END;