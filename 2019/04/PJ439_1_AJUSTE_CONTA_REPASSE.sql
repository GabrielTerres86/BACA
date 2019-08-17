begin
update tbepr_cdc_emprestimo e
   set cdcooper_cred=(select cdcooper from tbsite_cooperado_cdc c where c.idcooperado_cdc=e.idcooperado_cdc)
      ,nrdconta_cred=(select nrdconta from tbsite_cooperado_cdc c where c.idcooperado_cdc=e.idcooperado_cdc)
 where e.cdcooper=e.cdcooper_cred
   and e.nrdconta=e.nrdconta_cred;
commit;
end;

