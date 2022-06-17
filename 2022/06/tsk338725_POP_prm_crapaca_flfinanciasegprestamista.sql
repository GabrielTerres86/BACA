begin
  UPDATE CECRED.CRAPACA 
     SET LSTPARAM = substr(LSTPARAM,1,length(LSTPARAM) -29)
   WHERE NMDEACAO = 'SIMULA_GRAVA_SIMULACAO';
  COMMIT;
exception
  when others then
    rollback;
    raise_application_error(-20500, SQLERRM);
end;


