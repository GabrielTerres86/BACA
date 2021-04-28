BEGIN
	
  INSERT INTO crapprm (
         nmsistem,
         cdcooper,
         cdacesso,
         dstexprm,
         dsvlrprm
  ) VALUES (
         'CRED',
         3,
         'FLAG_SLC_CONTINGENCIA',
         'Habilitar/Desabilitar contingencia SLC. 0 = Desabilitada; 1 = Habilitada',
         '0'
  );

COMMIT;
END;
