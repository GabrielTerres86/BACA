BEGIN
    BEGIN
		update crapbdt 
		set DTLIQPRJ = null,
		  VLABOPRJ = 0,
		  DTULTPAG = null
		where nrdconta = 216194
		and nrborder = 28247;

		update craptdb
		set DTDPAGTO = null,
		  DTDEBITO = null,
		  VLPGJMPR = 0,
		  VLPGMUPR = 0,
		  VLSDPREJ = 4880,
		  VLIOFPPR = 0,
		  VLPGJRPR = 0,
		  VLPGJM60= 0
		where nrdconta = 216194
		and nrborder = 28247;

		delete from tbdsct_lancamento_bordero
		where nrdconta = 216194
		and nrborder = 28247
		and dtmvtolt = (select max(dtmvtolt) from tbdsct_lancamento_bordero
				where nrdconta = 216194
				and nrborder = 28247)
		and dtmvtolt >= '16/07/2020';               

		   
      COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;   

    END; 
END;
