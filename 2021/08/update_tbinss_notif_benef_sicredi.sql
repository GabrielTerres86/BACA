BEGIN
  
UPDATE tbinss_notif_benef_sicredi a SET a.inconfleitusic = -1, a.dhconfleitusic = NULL, a.DSMSGRETCONFLEITU = 'FALHA_COM_SERVICO - Parâmetro(s) não informado(s). - 2021-09-01 11:19:11 - Status HTTP:422'
 WHERE a.IDNOTIFICACAO = 109863;
COMMIT;
END;
