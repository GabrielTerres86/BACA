begin 
  update crapprm p 
     set p.dsvlrprm = '8'
   where p.nmsistem = 'CRED'
     and p.cdcooper = 0
     and p.cdacesso ='NRMES_LIM_JURO_SOBRA';
  commit;
end;
