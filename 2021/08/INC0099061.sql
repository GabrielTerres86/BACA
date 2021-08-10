BEGIN
	--INC0099061 - Acentra 16/07 Emprést pós fix - conta em prejuízo
	--cc/ 127744 42383 - removendo lançamentos do dia 16/07 no valor de R$ :42,83
	
   DELETE FROM craplem lem
   WHERE lem.cdcooper = 5
     AND lem.nrdconta = 127744
     AND lem.nrctremp = 14792
     AND lem.dtmvtolt = to_date('16/07/2021','dd/mm/rrrr')
     AND lem.vllanmto = 42.83; 
	 
   COMMIT;
	 
END;

