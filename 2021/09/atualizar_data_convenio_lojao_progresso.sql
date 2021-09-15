begin
   update crapcdr set DTRENCON=DTRENCON-40 where cdcooper=1 and nrdconta=2238500;
   commit;
exception
  WHEN others THEN
    raise_application_error(-20501, SQLERRM);
end;  
/
