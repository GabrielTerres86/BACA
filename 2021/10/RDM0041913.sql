begin 

  update crapprm 
     set dsvlrprm = 'A'
   WHERE cdacesso = 'FLG_PAG_FGTS_CXON' 
     AND cdcooper = 9;

  commit; 
  
end; 