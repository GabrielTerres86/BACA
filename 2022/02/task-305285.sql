BEGIN
  UPDATE tbgen_notif_automatica_prm
     SET dsmotivo_mensagem = 'Oferta de Limite de Crédito Pré-aprovado'
        ,dsvariaveis_mensagem = '<br/>#valordisponivelcdc - Valor disponível ao cooperado (Ex.: 3.500,00)'
   WHERE cdorigem_mensagem = 15;
   COMMIT;
END;