declare
begin 
update cecred.tbgen_analise_fraude_param 
set flgativo = 1
where flgativo = 0;
commit;
end;
/