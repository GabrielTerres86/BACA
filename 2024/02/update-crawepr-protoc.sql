BEGIN 
  UPDATE Crawepr Wpr
	SET    Wpr.Dsprotoc = 'PoliticaRenegociacaoFacilitadaPF_621315800'
	WHERE  Wpr.Cdcooper = 13
	AND    Wpr.Nrdconta = 99431050
	AND    Wpr.Nrctremp = 322686;
   
 COMMIT;
 
END;
