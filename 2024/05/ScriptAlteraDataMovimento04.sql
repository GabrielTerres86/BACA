BEGIN

  UPDATE cobranca.tbcobran_arquivo_acmp615_detalhe d
     SET d.dtmovimento = to_date('21052024', 'DDMMYYYY')
   WHERE d.idarquivo_acmp615_detalhe = '641A8206EE154232A157B17800E2E44A';

  UPDATE cobranca.tbcobran_arquivo_acmp615_lote l
     SET l.dtmovimento = to_date('21052024', 'DDMMYYYY')
   WHERE l.idarquivo_acmp615_lote = '5FC84D47D2C544F38CFFB17800E2E44A';

  UPDATE cobranca.tbcobran_arquivo_acmp615_header h
     SET h.dtmovimento = to_date('21052024', 'DDMMYYYY')
   WHERE h.idarquivo_acmp615_header = '6E3AD2ECB56C4587AF04B17800E2E44A';

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Script data movto');
END;
