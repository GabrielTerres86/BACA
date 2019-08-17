begin
  update crapcrm 
     set dtemscar = '23/04/2019' 
   where cdcooper = 1 
     and dtemscar = '24/04/2019' 
     and cdsitcar != '1'
     and dtcancel = '29/04/2019'
     and nrdconta = 1996282;
  commit;

  EXCEPTION
    WHEN others THEN
      CECRED.pc_internal_exception;
end;