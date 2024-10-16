BEGIN
  update cecred.tbtarif_contas_pacote t set t.dtadesao = TO_DATE('01/04/2024', 'DD/MM/YYYY'), t.dtinicio_vigencia = TO_DATE('01/04/2024', 'DD/MM/YYYY') where t.cdcooper = 1 and t.nrdconta = 97554090 and t.cdpacote = 166 ;
  COMMIT;
END;