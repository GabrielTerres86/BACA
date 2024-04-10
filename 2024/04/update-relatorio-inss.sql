BEGIN
  UPDATE cecred.crapprg
     SET dsprogra##1 = 'BENEFICIOS INSS PARA AJUSTE DE CADASTRO (INSS - SICREDI)'
   WHERE cdcooper <= 17
     AND upper(cdprogra) = 'DIVINSS'
     AND upper(nmsistem) = 'CRED';
 
  UPDATE cecred.craprel
     SET nmrelato = 'INSS - BENEFICIOS INSS PARA AJUSTE DE CADASTRO'
   WHERE cdcooper <= 17
     AND cdrelato = 827;
 
  COMMIT;
END;
