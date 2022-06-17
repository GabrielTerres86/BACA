begin
  UPDATE CECRED.CRAPACA 
     SET LSTPARAM = LSTPARAM || ', pr_flfinanciasegprestamista'
   WHERE NMDEACAO = 'SIMULA_GRAVA_SIMULACAO';
  COMMIT;
exception
  when others then
    rollback;
    raise_application_error(-20500, SQLERRM);
end;


