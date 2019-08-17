UPDATE crapcob cob
   SET cob.cdtpinsc = 1
 WHERE cob.cdcooper = 1
   AND cob.nrcnvcob = 101004
   AND cob.nrdconta = 8791740
   AND cob.dtmvtolt = '26/02/2019'
   AND cob.nrdocmto IN (739,740,741)
   AND cob.cdtpinsc = 2;

COMMIT;