begin
  update tbseg_prestamista set tpregist = 1 where tpregist = 3;
  commit;
end;
