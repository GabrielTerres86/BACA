BEGIN
  UPDATE cecred.craprel
     SET nmrelato = 'INSS - BENEFICIOS PARA AJUSTE CADASTRAL'
   WHERE cdcooper <= 17
     AND cdrelato = 827;
COMMIT;
END;
