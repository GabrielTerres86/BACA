DECLARE

  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1;
		   
BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP
      -- Op  o 'T' Taxa Cumulatividade Grupo Economico
      INSERT INTO crapace (
			            NMDATELA
									, CDDOPCAO
									, CDOPERAD
									, NMROTINA
									, CDCOOPER
									, NRMODULO
									, IDEVENTO
									, IDAMBACE) values (
									'CONTAS'
									, 'T'
									, 'f0030519'
									, 'GRUPO ECONOMICO'
									, rw_crapcop.cdcooper
									, 1
									, 1
									, 2);
  END LOOP;
 
  
  COMMIT;
END;





