BEGIN
	UPDATE crapaca 
		 SET lstparam = lstparam || ',pr_aslc41,pr_aslc42,pr_aslc43'
	 WHERE nmdeacao = 'MANTER_GRADE_HORARIO_CIP';

	-- SLC041
	INSERT INTO crapprm (
		 nmsistem,
		 cdcooper,
		 cdacesso,
		 dstexprm,
		 dsvlrprm
	) VALUES (
		 'CRED',
		 0,
		 'HORARIO_SLC_41',
		 'Horario de inicio e fim para contigencia ASLC023 - retorno IF',
		 '00:30;10:00'
	);

	-- SLC042
	INSERT INTO crapprm (
		   nmsistem,
		   cdcooper,
		   cdacesso,
		   dstexprm,
		   dsvlrprm
	) VALUES (
		   'CRED',
		   0,
		   'HORARIO_SLC_42',
		   'Horario de inicio e fim para contigencia ASLC025 - retorno IF',
		   '00:30;10:00'
	);  
		
	-- SLC043 
	INSERT INTO crapprm (
		   nmsistem,
		   cdcooper,
		   cdacesso,
		   dstexprm,
		   dsvlrprm
	) VALUES (
		   'CRED',
		   0,
		   'HORARIO_SLC_43',
		   'Horario de inicio e fim para contigencia ASLC033 - retorno IF',
		   '08:00;15:15'
	);    
		 

	COMMIT; 

END;
