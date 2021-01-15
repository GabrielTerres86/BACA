BEGIN
 UPDATE craprda SET vlsdrdca = 0.01 WHERE cdcooper = 1 AND nrdconta = 7224001 AND nraplica IN (21,22);
 COMMIT;
END;