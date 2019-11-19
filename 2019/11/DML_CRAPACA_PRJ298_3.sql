BEGIN
	--
	UPDATE crapaca aca
		 SET aca.lstparam = aca.lstparam || ',pr_totatual'
	 WHERE aca.nmdeacao = 'EMPR0011_GERA_PAGTO_POS';
  --
  COMMIT;
	--
END;
