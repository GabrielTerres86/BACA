BEGIN

  UPDATE pagamento.tbvans_van v
     SET v.dspasta_envia =    '/usr/connect/nexxera/envia'
        ,v.dspasta_enviados = '/usr/connect/nexxera/enviados'
        ,v.dspasta_recebe = '/usr/connect/nexxera/recebe'
        ,v.dspasta_recebidos = '/usr/connect/nexxera/recebidos'
   WHERE v.nmvan = 'Nexxera';  
   
   COMMIT;
   
END;
