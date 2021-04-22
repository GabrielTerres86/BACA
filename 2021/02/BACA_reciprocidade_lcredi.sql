BEGIN 
  UPDATE crapaca t
     SET t.lstparam = t.lstparam || ',pr_reccateg'
   WHERE t.nmdeacao IN ('INCLINHA', 'ALTLINHA');
  
  COMMIT;    
END;
