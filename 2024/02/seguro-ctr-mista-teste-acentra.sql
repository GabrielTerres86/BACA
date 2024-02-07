begin

UPDATE cecred.tbseg_parametros_prst p
SET p.dtctrmista = to_date('26/01/2024','dd/mm/yyyy')
WHERE p.idseqpar = 1003;
	 
commit;
end;	 