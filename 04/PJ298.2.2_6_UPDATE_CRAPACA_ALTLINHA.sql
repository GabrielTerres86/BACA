declare

begin
  UPDATE CRAPACA 
  SET LSTPARAM = LSTPARAM || ',pr_vlperidx'
  WHERE NMDEACAO = 'ALTLINHA'
    AND NMPACKAG = 'TELA_LCREDI';

  COMMIT;
end;
