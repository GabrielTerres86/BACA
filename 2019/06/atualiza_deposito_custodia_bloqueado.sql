BEGIN
  update crapdpb 
     set dtliblan = to_char(SYSDATE + 1,'DD/MM/RRRR') 
   where cdcooper = 14 
     and nrdconta = 9679 
     and dtmvtolt = '16/01/2019' 
     and nrdocmto = 197239;

  update crapdpb 
     set dtliblan = to_char(SYSDATE + 1,'DD/MM/RRRR') 
   where cdcooper = 6 
     and nrdconta = 124346 
     and dtmvtolt = '17/01/2019' 
     and nrdocmto = 174759;

  COMMIT;
  EXCEPTION
    WHEN others THEN
      cecred.pc_internal_exception;
      ROLLBACK;
END;
