begin
  update crapcrm c
     set c.cdsitcar = 1 --Solicitado
   where c.cdcooper = 1
     and c.dtemscar = '10/07/2020'
  commit;
end;
