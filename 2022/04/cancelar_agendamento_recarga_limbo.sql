DECLARE
pr_cdcritic  PLS_INTEGER;
pr_dscritic  VARCHAR2(4000);
BEGIN 
  cecred.RCEL0001.pc_cancela_agendamento_recarga(pr_cdcooper => 1,
                                                 pr_nrdconta => 3056040,
                                                 pr_idseqttl => 1,
                                                 pr_idorigem => 1,
                                                 pr_idoperacao => 1297446,
                                                 pr_nmprogra => 'RECCEL',
                                                 pr_cdcritic => pr_cdcritic,
                                                 pr_dscritic => pr_dscritic);
  dbms_output.put_line(pr_dscritic);
  COMMIT;                                                 
END;
