begin
    UPDATE crapprm SET dsvlrprm = '1' WHERE cdacesso = 'QT_VLMXREMO_RENCAN' AND cdcooper = 1;
  
    COMMIT;
end;    
