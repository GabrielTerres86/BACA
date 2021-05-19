DECLARE

CURSOR crPessoa IS
  SELECT a.idcalris_pessoa
	   , b.tppessoa
       , b.nrcpfcgc
	   , b.nmpessoa
    FROM tbcalris_pessoa a
       , tbcadast_pessoa b
   WHERE b.idpessoa = a.idpessoa
     AND a.tpcalculadora NOT IN (3, 4);

TYPE tbCursor IS TABLE OF crPessoa%ROWTYPE INDEX BY PLS_INTEGER;
tbPessoa tbCursor;

BEGIN

OPEN crPessoa;
LOOP
  FETCH crPessoa BULK COLLECT INTO tbPessoa LIMIT 1000;
  EXIT WHEN tbPessoa.COUNT = 0;
  
  FORALL i IN tbPessoa.FIRST..tbPessoa.LAST
    UPDATE tbcalris_pessoa
       SET nrcpfcgc = tbPessoa(i).nrcpfcgc
	     , tpcalculadora = tbPessoa(i).tppessoa
		 , nmpessoa = tbPessoa(i).nmpessoa
     WHERE idcalris_pessoa = tbPessoa(i).idcalris_pessoa;
  COMMIT;

  FORALL i IN tbPessoa.FIRST..tbPessoa.LAST
    UPDATE tbcalris_tanque
       SET tpcalculadora = tbPessoa(i).tppessoa
     WHERE nrcpfcgc = tbPessoa(i).nrcpfcgc;
  COMMIT;
END LOOP;
CLOSE crPessoa;

END;
/