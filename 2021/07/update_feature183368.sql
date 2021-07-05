begin

update tbepr_cdc_usuario
set dtultalter_senha = sysdate
where idusuario in (
  select usr.idusuario
  from tbepr_cdc_usuario usr
  inner join crapass ass
  on decode(ass.inpessoa,1,lpad(ass.nrcpfcgc,11,'0'),lpad(ass.nrcpfcgc,14,'0')) = usr.dslogin
  inner join crapcdr cdr
  on cdr.cdcooper = ass.cdcooper
  and cdr.nrdconta = ass.nrdconta
  where usr.dtultalter_senha is null
  and cdr.dtacectr is not null
);

commit;

exception
  when others then
    rollback;
    raise_application_error(-20501, sqlerrm);
end;
/