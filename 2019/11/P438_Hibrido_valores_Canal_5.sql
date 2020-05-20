-- insere valores máximos para contratação hibrida
begin
  for RW_TSCP in (select * from TBEPR_SEGMENTO_CANAIS_PERM where CDCANAL=3) loop
    begin
      RW_TSCP.CDCANAL := 5;
      insert into TBEPR_SEGMENTO_CANAIS_PERM values RW_TSCP;
    exception
      when dup_val_on_index then
        continue;
    end;
  end loop;
  commit;
end;