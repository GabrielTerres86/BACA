BEGIN
	FOR coop IN (SELECT cdcooper FROM crapcop c WHERE c.flgativo = 1) LOOP
		  INSERT INTO crapace (
			       nmdatela,
						 cddopcao,
						 cdoperad,
						 nmrotina,
						 cdcooper,
						 nrmodulo,
						 idevento,
						 idambace
			) VALUES (
			       'CARCRD',
						 'A',
						 'f0031296',
						 'APRCAR',
						 coop.cdcooper,
						 1,
						 1,
						 2
			);
	END LOOP;
  
	COMMIT;
END;