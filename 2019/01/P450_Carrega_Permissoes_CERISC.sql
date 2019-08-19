/* Libera acesso a tela CERISC para os operadores do departamento 14 (PRODUTOS) e 7 (CONTROLE),
   somente da CECRED. */
declare 
  cursor cr_crapcop is
  select cdcooper 
    from crapcop
   where flgativo = 1;
    rw_crapcop cr_crapcop%ROWTYPE; 
 
  cursor cr_crapope(pr_cdcooper in crapcop.cdcooper%TYPE, pr_cddepart in crapope.cddepart%TYPE) is
	select cdoperad 
		from crapope
	 where cdcooper = pr_cdcooper
		 and cddepart = pr_cddepart;
	rw_crapope cr_crapope%ROWTYPE;
 
begin
  --PARA CADA COOPERATIVA CADASTRADA
  FOR rw_crapcop IN cr_crapcop LOOP
    --FAZ O INSERT PARA OPERADORES DO GRUPO CONTROLE CONSULTAR
    FOR rw_crapope IN cr_crapope(rw_crapcop.cdcooper, 14) LOOP
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
          'CERISC'
        , 'C'
        , rw_crapope.cdoperad
        , ' '
        , rw_crapcop.cdcooper
        , 8
        , 0
        , 2
      );         	      
    END LOOP;
    -- FAZ O INSERT PARA OPERADORES DO GRUPO PRODUTO ALTERAR
    FOR rw_crapope IN cr_crapope(rw_crapcop.cdcooper, 7) LOOP
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
          'CERISC'
        , 'A'
        , rw_crapope.cdoperad
        , ' '
        , rw_crapcop.cdcooper
        , 8
        , 0
        , 2
      );     
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
          'CERISC'
        , 'C'
        , rw_crapope.cdoperad
        , ' '
        , rw_crapcop.cdcooper
        , 8
        , 0
        , 2
      );         	    	      
    END LOOP;
  
  END LOOP;
  
	COMMIT;
end;

