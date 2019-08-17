/* 13/05/2019 - inc0012700 Tratamento na rotina pc_inst_cancel_protesto_85 para não permitir cancelar as instruções
                de protesto que estão sem confirmação de protesto (Carlos) */
INSERT INTO crapcri
  (cdcritic
  ,dscritic
  ,tpcritic
  ,flgchama)
VALUES
  (1464
  ,'1464 - Título pendente de confirmação no cartório, tente no próximo dia útil.'
  ,1
  ,0);
COMMIT;
