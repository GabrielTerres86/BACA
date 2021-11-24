BEGIN
 UPDATE crawepr t SET t.tpdescto = 1 WHERE t.cdcooper=10 and t.nrdconta=141690 and t.nrctremp=12363;
 UPDATE crapepr t SET t.tpdescto = 1 WHERE t.cdcooper=10 and t.nrdconta=141690 and t.nrctremp=12363;
 COMMIT;
END;
