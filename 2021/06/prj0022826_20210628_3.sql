begin
    UPDATE crapprm SET dsvlrprm = '50000' WHERE cdacesso = 'QT_VLMXRECA_RENCAN' AND cdcooper = 13;
  
    COMMIT;
end;    
