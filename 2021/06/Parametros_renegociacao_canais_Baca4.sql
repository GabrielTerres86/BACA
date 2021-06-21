begin
    UPDATE crapaca 
    SET lstparam   = replace(lstparam,',pr_vlmxcohi','')
    WHERE nmdeacao = 'TAB089_ALTERAR';
  
    COMMIT;
end;    
