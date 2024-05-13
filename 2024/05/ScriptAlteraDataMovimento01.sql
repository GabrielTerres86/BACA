BEGIN

  UPDATE cobranca.tbcobran_arquivo_acmp615_detalhe d
     SET d.dtmovimento = to_date('10052024', 'DDMMYYYY')
   WHERE d.idarquivo_acmp615_detalhe = '668F574EB43344D8A090B16F00B13770';

  UPDATE cobranca.tbcobran_arquivo_acmp615_lote l
     SET l.dtmovimento = to_date('10052024', 'DDMMYYYY')
   WHERE l.idarquivo_acmp615_lote = 'FEC856245BD34AB9A5ADB16F00B13771';

  UPDATE cobranca.tbcobran_arquivo_acmp615_header h
     SET h.dtmovimento = to_date('10052024', 'DDMMYYYY')
   WHERE h.idarquivo_acmp615_header = '20CFD329D8CD4301BABDB16F00B13770';

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Script data movto');
END;
