BEGIN

  UPDATE cobranca.tbcobran_arquivo_acmp615_detalhe d
     SET d.dtmovimento = to_date('20052024', 'DDMMYYYY')
   WHERE d.idarquivo_acmp615_detalhe = 'D097B9789E0B4E36ADE7B17700BBCFC6';

  UPDATE cobranca.tbcobran_arquivo_acmp615_lote l
     SET l.dtmovimento = to_date('20052024', 'DDMMYYYY')
   WHERE l.idarquivo_acmp615_lote = '3237883C3C814A18A3BCB17700BBCFC6';

  UPDATE cobranca.tbcobran_arquivo_acmp615_header h
     SET h.dtmovimento = to_date('20052024', 'DDMMYYYY')
   WHERE h.idarquivo_acmp615_header = 'D097B9789E0B4E36ADE7B17700BBCFC6';

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Script data movto');
END;
