BEGIN
  UPDATE cobranca.tbcobran_ocorrencia_liquidacao t
     SET t.dtmovimento_sistema = to_date('16/10/2023','dd/mm/yyyy')
   WHERE t.idocorrencia_liquidacao IN (HEXTORAW('21336A8B0E2849E088C4B0C000A1CF10')
                                      ,HEXTORAW('252FB0ED5BEC42BE91FDB0BA0083EE7C')
                                      ,HEXTORAW('012AEF7B8E1C44E9AA22B0C300BD9F0E')
                                      ,HEXTORAW('05D152DA112E48559BADB0C300BDAC3B')
                                      ,HEXTORAW('1A0F8431C30E42B785B6B0C300BDA3AE')
                                      ,HEXTORAW('3A2641EA5C664FB2ACF7B0BA0083F1A5')
                                      ,HEXTORAW('F235ABA10E824D378A9CB0BA0083F371'));
  COMMIT;
END;
