BEGIN
update crapass set nrdconta = 8054916, nrcpfcgc = 31158234953 where cdcooper = 1 and nrdconta = 91945020;
update crapttl set nrdconta = 8054916, nrcpfcgc = 31158234953 where cdcooper = 1 and nrdconta = 91945020 and IDSEQTTL = 1 ;
update crapsnh set nrdconta = 8054916, nrcpfcgc = 31158234953 where cdcooper = 1 and nrdconta = 91945020;
COMMIT;
END;
