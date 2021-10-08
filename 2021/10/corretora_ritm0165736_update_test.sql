BEGIN
	UPDATE craplau u
		 SET u.dtmvtopg = TO_DATE(SYSDATE,'DD/MM/RRRR')
	 WHERE u.cdcooper = 1
		 AND u.nrdconta = 8683387
		 AND u.cdhistor = 2074
		 AND u.insitlau = 3
		 AND u.nrseqdig = 20663;
	COMMIT;
EXCEPTION WHEN OTHERS THEN
	ROLLBACK;
END;
/
BEGIN
	UPDATE craplau u
		 SET u.dtmvtopg = TO_DATE(SYSDATE,'DD/MM/RRRR')
	 WHERE u.cdcooper = 1
		 AND u.nrdconta = 11456345
		 AND u.cdhistor = 2074
		 AND u.insitlau = 3
		 AND u.nrseqdig = 13801;
	COMMIT;
EXCEPTION WHEN OTHERS THEN
	ROLLBACK;
END;
/
BEGIN
	UPDATE craplau u
		 SET u.dtmvtopg = TO_DATE(SYSDATE,'DD/MM/RRRR')
	 WHERE u.cdcooper = 1
		 AND u.nrdconta = 10544003
		 AND u.cdhistor = 2074
		 AND u.insitlau = 3
		 AND u.nrseqdig = 18040;
	COMMIT;
EXCEPTION WHEN OTHERS THEN
	ROLLBACK;
END;
/
BEGIN
	UPDATE craplau u
		 SET u.dtmvtopg = TO_DATE(SYSDATE,'DD/MM/RRRR')
	 WHERE u.cdcooper = 1
		 AND u.nrdconta = 7325428
		 AND u.cdhistor = 2074
		 AND u.insitlau = 3
		 AND u.nrseqdig = 8733;
	COMMIT;
EXCEPTION WHEN OTHERS THEN
	ROLLBACK;
END;
/
BEGIN
	UPDATE tbseg_producao_sigas s
   SET s.tpproposta = 'CANCELAMENTO'
 WHERE s.cden2 = 1
   AND s.nrdconta = 8683387
   AND s.nrapolice_certificado = '930207051354' 
   AND s.id = 662781235095;
	COMMIT;
EXCEPTION WHEN OTHERS THEN
	ROLLBACK;
END;
/
BEGIN
	UPDATE tbseg_producao_sigas s
   SET s.tpproposta = 'CANCELAMENTO'
 WHERE s.cden2 = 1
   AND s.nrdconta = 11456345
   AND s.nrapolice_certificado = '930207696347' 
   AND s.id = 173324504855;
	COMMIT;
EXCEPTION WHEN OTHERS THEN
	ROLLBACK;
END;
/