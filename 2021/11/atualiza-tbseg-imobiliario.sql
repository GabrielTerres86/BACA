begin
  update cecred.tbseg_cred_imobiliario o set o.dtgeracao = to_date('13/10/2021','dd/mm/rrrr');
  commit;
exception 
  when others then
   rollback;
end;
/
