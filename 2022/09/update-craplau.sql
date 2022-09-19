BEGIN  
  UPDATE cecred.craplau 
     SET insitlau = 3, dtdebito = TRUNC(SYSDATE)
   WHERE craplau.cdtiptra IN (4, 22)
     AND craplau.dtmvtopg = Trunc(SYSDATE)
     AND craplau.insitlau = 1
     AND craplau.dsorigem IN ('INTERNET', 'TAA', 'PORTABILIDAD', 'AIMARO')
     AND craplau.tpdvalor = 0
     AND craplau.cdcooper IN (1, 16);

  UPDATE cecred.craplau 
     SET insitlau = 3, dtdebito = TRUNC(SYSDATE)
   WHERE craplau.cdtiptra IN (4, 22)
     AND craplau.dtmvtopg = Trunc(SYSDATE)
     AND craplau.insitlau = 1
     AND craplau.dsorigem IN ('INTERNET', 'TAA', 'PORTABILIDAD', 'AIMARO')
     AND craplau.tpdvalor = 0;

  COMMIT;
END;