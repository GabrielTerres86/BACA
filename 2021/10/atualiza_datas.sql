begin
update CREDITO.TBEPR_PARCELAS_CRED_IMOB parc 
   set parc.dtvencto = to_date('15/10/2021','dd/mm/rrrr')
where nrparcel = 0 and cdcooper =1; 
update CREDITO.TBEPR_PARCELAS_CRED_IMOB parc 
   set parc.dtvencto = to_date('18/10/2021','dd/mm/rrrr')
where nrparcel = 0 and cdcooper =16; 
commit;
exception
 when others then
  null;
end;