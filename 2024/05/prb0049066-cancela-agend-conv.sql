BEGIN
  UPDATE cecred.craplau c
     SET c.insitlau = 3, c.dtdebito = c.dtmvtopg
   WHERE c.insitlau = 1
     AND c.progress_recid IN (100368115, 100507508, 100523080, 100588522,
                              100392303, 100296113, 100606261, 100610657,
                              100610660, 100610662, 100610664, 100398752);
  COMMIT;
END;
