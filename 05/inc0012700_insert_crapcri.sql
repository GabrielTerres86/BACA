/* 13/05/2019 - inc0012700 Tratamento na rotina pc_inst_cancel_protesto_85 para n�o permitir cancelar as instru��es
                de protesto que est�o sem confirma��o de protesto (Carlos) */
INSERT INTO crapcri
  (cdcritic
  ,dscritic
  ,tpcritic
  ,flgchama)
VALUES
  (1464
  ,'1464 - T�tulo pendente de confirma��o no cart�rio, tente no pr�ximo dia �til.'
  ,1
  ,0);
COMMIT;
