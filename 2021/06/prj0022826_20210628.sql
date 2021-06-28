begin
    UPDATE crapprm SET dsvlrprm = '1' WHERE cdacesso = 'QT_VLMXRECA_RENCAN' AND cdcooper = 1;
  
    COMMIT;
end;    
