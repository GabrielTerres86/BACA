declare
  
  cursor cr_crapcop is
    select cdcooper
      from crapcop 
     where flgativo=1;
  rw_crapcop cr_crapcop%rowtype;

 
  
  vr_nmpartar crappat.nmpartar%type := 'HABILITAR VALIDAÇÃO DE EMPRESTIMOS EM ATRASO NO RECEBIMENTO DE VALOR';
  vr_tpdedado crappat.tpdedado%type := 2;
  vr_cdprodut crappat.cdprodut%type := 0;
  vr_dsconteu crappco.dsconteu%type := 'S';

begin

 
  BEGIN
    insert into crappat
      (cdpartar,nmpartar,tpdedado,cdprodut)
      values
      (262, vr_nmpartar, vr_tpdedado, vr_cdprodut);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
      dbms_output.put_line('Erro ao criar registro (crappat): ' || SQLERRM);
  END;
  
  FOR rw_crapcop in cr_crapcop LOOP
  
    BEGIN
      insert into crappco 
        (cdpartar,cdcooper,dsconteu)
        values
        (262, rw_crapcop.cdcooper, vr_dsconteu);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
        dbms_output.put_line('Erro ao criar registro (crappco): ' || SQLERRM);
    END;

  END LOOP;

  dbms_output.put_line('Cadastro feito!!!');
  commit;

end;
/
