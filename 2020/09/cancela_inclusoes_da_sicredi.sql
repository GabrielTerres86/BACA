UPDATE crapscn SCN
  SET scn.Cdempcon = 0
WHERE scn.cdempres IN ('252','787','307','806','G16','TT','752','QA')
  AND scn.dsoparre = 'E'; -- DA
		
COMMIT;
