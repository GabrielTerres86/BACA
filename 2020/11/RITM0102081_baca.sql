DECLARE

  CURSOR cr_cooper IS(
    SELECT cop.cdcooper
          ,cop.nmrescop
      FROM crapcop cop
     WHERE cop.flgativo = 1);

  rw_cooper cr_cooper%ROWTYPE;
BEGIN
  dbms_output.put_line('COOPERATIVAS ALTERADAS PARCELA BALÃO');

  OPEN cr_cooper;
  LOOP
    FETCH cr_cooper
      INTO rw_cooper;
    EXIT WHEN cr_cooper%NOTFOUND;
  
    UPDATE crapprm prm
       SET dsvlrprm = 0
     WHERE cdacesso = 'COVID_QTDE_PARCELA_ADIAR'
       AND cdcooper = rw_cooper.cdcooper;
  
    dbms_output.put_line(rw_cooper.cdcooper || ' - ' || rw_cooper.nmrescop);
  END LOOP;

  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
