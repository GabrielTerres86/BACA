BEGIN

  UPDATE CECRED.CRAPLAU L 
     SET L.INSITLAU = 3, 
         l.dtdebito = to_date(l.dtmvtolt, 'dd/mm/yyyy'), 
         l.cdcritic = 1073, 
         l.dscritic = '1073 - Nao foi possivel debitar o agendamento.' 
   WHERE L.CDCOOPER = 1 AND L.INSITLAU = 1 AND L.DTMVTOPG = TO_DATE('16/08/2022', 'DD/MM/YYYY') 
     AND L.DSORIGEM IN 'CAIXA' AND L.CDHISTOR = 540;

  INSERT INTO cecred.craplgm (CDCOOPER, NRDCONTA, IDSEQTTL, NRSEQUEN, DTTRANSA, HRTRANSA, DSTRANSA, DSORIGEM, NMDATELA, FLGTRANS, DSCRITIC, CDOPERAD, NMENDTER)
  VALUES (1, 853828, 1, 1, to_date(TRUNC(SYSDATE), 'dd-mm-yyyy'), 60000, 'Cancelar Agendamento Convenio (INC0206662)', 'AIMARO WEB', 'CONTAS', 1, ' ', '1', ' '); 

  UPDATE CECRED.CRAPLAU L 
     SET L.INSITLAU = 2, 
         L.DTDEBITO = TO_DATE('16/08/2022', 'DD/MM/YYYY') 
   WHERE L.CDCOOPER = 1 AND L.INSITLAU = 1 AND L.DTMVTOPG = TO_DATE('16/08/2022', 'DD/MM/YYYY') 
     AND L.DSORIGEM IN 'DEBAUT' AND L.CDHISTOR = 3292; 
   
   COMMIT;
END;