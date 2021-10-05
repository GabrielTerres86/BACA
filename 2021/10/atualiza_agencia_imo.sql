begin
update credito.tbepr_contrato_imobiliario imo 
   set cdagenci = to_number(substr(cdagenci,-5))
 where length(cdagenci) > 3;
 commit;
exception
  when others then
    null;
end;