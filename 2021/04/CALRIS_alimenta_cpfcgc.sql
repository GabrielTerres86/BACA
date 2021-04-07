DECLARE

CURSOR crPessoa IS
  SELECT a.idcalris_pessoa
       , b.nrcpfcgc
    FROM tbcalris_pessoa a
       , tbcadast_pessoa b
   WHERE b.idpessoa = a.idpessoa;

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
     WHERE idcalris_pessoa = tbPessoa(i).idcalris_pessoa;
  COMMIT;
END LOOP;
CLOSE crPessoa;

END;
/