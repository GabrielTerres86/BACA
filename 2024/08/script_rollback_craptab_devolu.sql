BEGIN
  
DELETE  from cecred.craptab 
                      where cdcooper = 12
                        and nmsistem = 'CRED'
                        and tptabela = 'GENERI'
                        and cdempres = 0
                        and cdacesso = 'BUSCADEVOLU'
						and tpregist = 17078652;  
commit;                   
END;
      
