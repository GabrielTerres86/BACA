BEGIN

	UPDATE craptel tel
	   SET tel.cdopptel = tel.cdopptel||',G',
	       tel.lsopptel = tel.lsopptel||',GRUPO MUNICIPAL'
	 WHERE tel.nmdatela = 'CADCOP';

	 COMMIT;


END;