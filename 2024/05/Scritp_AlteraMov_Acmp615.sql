BEGIN

  UPDATE cobranca.tbcobran_arquivo_acmp615_header h
     SET h.dtmovimento = TO_DATE('08052024','DDMMYYYY')
   WHERE h.dtmovimento = TO_DATE('09052024','DDMMYYYY')
     AND h.nrparcial_processador = 7;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Data parcial');
END;
