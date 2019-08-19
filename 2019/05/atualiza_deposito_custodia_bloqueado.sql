BEGIN
  update crapdpb 
     set dtliblan = sysdate + 1 
   where cdcooper = 14 
     and nrdconta = 9679 
     and dtmvtolt = '16/01/2019' 
     and nrdocmto = 197239;
  COMMIT;
  EXCEPTION
    WHEN others THEN
      cecred.pc_internal_exception;
      ROLLBACK;
END;