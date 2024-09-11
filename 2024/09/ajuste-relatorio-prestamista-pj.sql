begin
  delete CECRED.CRAPREL r where r.cdrelato = 1006;
  update CECRED.CRAPREL r set r.cdrelato = 1006 where r.cdrelato = 1007;
  commit;
end;
