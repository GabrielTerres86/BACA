/* Libera acesso a tela PARDBT para os operadores do departamento 14 (PRODUTOS),
   somente da CECRED. */
declare 
  cursor cr_crapope is
	select cdoperad 
		from crapope
	 where cdcooper = 3
		 and cddepart in (14, 20);
	rw_crapope cr_crapope%ROWTYPE;
 
begin
  FOR rw_crapope IN cr_crapope LOOP
		insert into crapace (
			  nmdatela
			, cddopcao
			, cdoperad
			, nmrotina
			, cdcooper
			, nrmodulo
			, idevento
			, idambace
		)
		values (
			  'PARDBT'
			, '@'
			, rw_crapope.cdoperad
			, ' '
			, 3
			, 12
			, 0
			, 2
		);         	      
	END LOOP;
  
	COMMIT;
end;

