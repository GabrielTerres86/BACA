BEGIN
  UPDATE COBRANCA.tbcobran_arquivo_acmp615_header t 
     SET t.idciclo_liquidacao_pcr = 2
   WHERE ROWID = 'AABD15AAAAAB4PNAAM';
  
  COMMIT;
END;
