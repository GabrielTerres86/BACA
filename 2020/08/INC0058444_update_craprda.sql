
BEGIN
  UPDATE craprda rda
     SET rda.insaqtot = 1
   WHERE rda.cdcooper = 16
     AND rda.nrdconta = 216933
     AND rda.nraplica in (171369,171236,203041,88065
					     ,164599,67239,286911,211659
						 ,224872,252832,252982,269022);
  COMMIT;
END;   
 

