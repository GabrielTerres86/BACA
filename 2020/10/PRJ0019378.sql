-- Created on 10/09/2020 by T0032717 
DECLARE
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', rw_crapcop.cdcooper, 'EXTRATO_PREJ_PP', 'Parametro para impressao de extrato de prejuizo para contratos PP', '1');
  END LOOP;
  COMMIT;
END;
/
--STRY0010753
--Ana Volles - 06/10/2020
BEGIN
--  SELECT * FROM craptel a WHERE a.nmdatela = 'PREJU';

  UPDATE craptel a
  SET a.cdopptel = '@,C,P,F'
     ,a.tlrestel = 'CON. TRF. PRJ.'
     ,a.lsopptel = 'ACESSO,CONSULTA,FORCAR,FORCAR C/C'
  WHERE a.nmdatela = 'PREJU';
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
