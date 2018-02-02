Declare
  --
  -- Todas as cooperativas
  --
  Cursor c1 is
    select b.cdcooper, b.nrctremp, b.nrdconta, b.cdlcremp, b.idquapro
    from crawepr b
    --where b.cdcooper = 16
    --and b.nrdconta   = 80280161
    order by 1, 2, 3;

reg_c1   c1%rowtype;

contador number := 0;

Begin
   for reg_C1 in c1 loop
      --
      -- Commit a cada 1000 para evitar estouro da Áreade Rollback;
      --
      if contador = 1000 then
         contador := 0;
         commit;
      end if;
      --
      update cecred.crapepr a 
          set a.idquaprc = reg_c1.idquapro
       where a.cdcooper = reg_c1.cdcooper
         and a.nrdconta = reg_c1.nrdconta
         and a.nrctremp = reg_c1.nrctremp;
      --   
      contador := contador + 1;
      --   
    end loop;
    -- para commit dos demais registros quando contador não chegou a 100;
    --
    commit;
End;
/