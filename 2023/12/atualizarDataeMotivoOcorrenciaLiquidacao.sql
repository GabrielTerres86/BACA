BEGIN
  UPDATE cobranca.tbcobran_ocorrencia_liquidacao t
     SET t.cdmotivo_devolucao  = 82
       , t.dtmovimento_sistema = to_date('16/10/2023','dd/mm/yyyy')
   WHERE t.idocorrencia_liquidacao IN (HEXTORAW('50CEC2D2B5B5459FBCBDB0C300BDC994')
                                      ,HEXTORAW('AA2530F592274D79BAE5B0C1011C7AED')
                                      ,HEXTORAW('C20C655BC8F94194B6F3B0C1011C7D6D')
                                      ,HEXTORAW('D0A8899E153049F1A5D5B0BC00C69EC0')
                                      ,HEXTORAW('E9FBF345C8B840E18049B0C300BDCC02'));
  COMMIT;
END;
