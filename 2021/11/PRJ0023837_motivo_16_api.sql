declare
  v_erro varchar2(2000);
begin

  FOR rec IN (select cdcooper From crapcop) LOOP
    BEGIN
    
      INSERT INTO crapmot
        (CDCOOPER,
         CDDBANCO,
         CDOCORRE,
         TPOCORRE,
         CDMOTIVO,
         DSMOTIVO,
         DSABREVI,
         CDOPERAD,
         DTALTERA,
         HRTRANSA)
      VALUES
        (rec.cdcooper,
         85,
         9,
         2,
         16,
         'Comanda Cliente Online API',
         ' ',
         1,
         TRUNC(SYSDATE),
         TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')));
    
    END;
  END LOOP;

  commit;

exception
  when others then
    sistema.excecaointerna(pr_compleme => 'prj0023837');
    v_erro := sqlerrm;
    rollback;
    dbms_output.put_line(v_erro);
    raise_application_error(-20003, v_erro);
end;
