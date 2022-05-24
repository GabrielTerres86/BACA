begin
update tbepr_consig_parcelas_tmp a
set a.instatusproces = null
where a.cdcooper = 5
and a.dtmovimento = to_date('10/06/2022','DD/MM/YYYY')
and a.inparcelaliq <> 1;

  commit;

end;