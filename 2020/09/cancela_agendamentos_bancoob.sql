UPDATE craplau SET insitlau = 3 WHERE cdcooper = 2 AND nrdconta = 858684 AND nrdocmto = 10000001 AND dtmvtopg = TRUNC(SYSDATE);
UPDATE craplau SET insitlau = 3 WHERE cdcooper = 14 AND nrdconta = 76333 AND nrdocmto = 10000003 AND dtmvtopg = TRUNC(SYSDATE);

UPDATE crapprm p
   SET p.dsvlrprm = '24/09/2020#2'
 WHERE p.cdcooper IN (2,14)
   AND p.cdacesso IN ('CTRL_CRPS688_EXEC','CTRL_DEBUNITAR_EXEC','CTRL_JOBAGERCEL_EXEC');
			
COMMIT;
