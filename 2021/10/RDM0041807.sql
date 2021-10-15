begin 

  update crapprm 
     set dsvlrprm = 'B'
   where cdacesso = 'FLG_PAG_FGTS_CXON'
     and cdcooper = 1; 

  update crapprm 
     set dsvlrprm = 'A'
   where cdacesso = 'FLG_PAG_FGTS_CXON'
     and cdcooper = 14; 

  commit; 
end; 