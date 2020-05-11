declare
  
  cursor cr_crapcop is
    select cdcooper
      from crapcop 
     where flgativo=1;
  rw_crapcop cr_crapcop%rowtype;

  cursor cr_crappat is
    select max(p.cdpartar)+1 cdpartar
      from crappat p;
  rw_crappat cr_crappat%rowtype;
  
  vr_nmpartar crappat.nmpartar%type := 'HABILITA ROTINA REVITALIZADA - PC_CRPS672 (S/N)';
  vr_tpdedado crappat.tpdedado%type := 2;
  vr_cdprodut crappat.cdprodut%type := 0;
  vr_dsconteu crappco.dsconteu%type := 'S';

begin

  OPEN cr_crappat;
  FETCH cr_crappat INTO rw_crappat;
  CLOSE cr_crappat;
  
  BEGIN
    insert into crappat 
      (cdpartar,nmpartar,tpdedado,cdprodut)
      values
      (rw_crappat.cdpartar, vr_nmpartar, vr_tpdedado, vr_cdprodut);
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
        (rw_crappat.cdpartar, rw_crapcop.cdcooper, vr_dsconteu);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
        dbms_output.put_line('Erro ao criar registro (crappco): ' || SQLERRM);
    END;

  END LOOP;

  dbms_output.put_line('Cadastro com sucesso!!!');
  commit;

end;
