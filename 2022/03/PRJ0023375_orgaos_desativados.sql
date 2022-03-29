declare 
   i integer;
   
   CURSOR cr_outros is
   select org.idorgao_expedidor origem
        , 67 destino
     from cecred.tbgen_orgao_expedidor org
    where org.idorgao_expedidor in ( 1,3,4,5,29,30,31,34,35,36,37,38,39,40,42,44,56,57,59,60,62,63,64,65,26,32,33,41,43)  
                                   
   union all                                            
   select org.idorgao_expedidor origem
        , 27 destino
     from cecred.tbgen_orgao_expedidor org
    where org.idorgao_expedidor in ( 33 )
   union all
   select org.idorgao_expedidor origem
        , 54 destino
     from cecred.tbgen_orgao_expedidor org
    where org.idorgao_expedidor in ( 51 )
   union all
   select org.idorgao_expedidor origem
        , 52 destino
     from cecred.tbgen_orgao_expedidor org
    where org.idorgao_expedidor in ( 53 );            
 
begin
  
  
   FOR rw_outros IN cr_outros LOOP
     begin  
       
     UPDATE cecred.CRAPASS ASS
        SET ASS.IDORGEXP = rw_outros.destino
      WHERE ASS.IDORGEXP = rw_outros.origem; 

     UPDATE cecred.CRAPTTL TTL
        SET TTL.IDORGEXP = rw_outros.destino
      WHERE TTL.IDORGEXP = rw_outros.origem; 

     UPDATE cecred.CRAPAVT AVT
        SET AVT.IDORGEXP = rw_outros.destino
      WHERE AVT.IDORGEXP = rw_outros.origem; 

     UPDATE cecred.CRAPCRL CRL
        SET CRL.IDORGEXP = rw_outros.destino
      WHERE CRL.IDORGEXP = rw_outros.origem; 

     UPDATE cecred.CRAPCJE CJE
        SET CJE.IDORGEXP = rw_outros.destino
      WHERE CJE.IDORGEXP = rw_outros.origem; 

    UPDATE cecred.TBCADAST_PESSOA_FISICA FIS
       SET FIS.IDORGAO_EXPEDIDOR = rw_outros.destino
     WHERE FIS.IDORGAO_EXPEDIDOR = rw_outros.origem;         
  
     exception
       when others then
         rollback; 
     end;
   End loop;
   
   commit;
   
   begin
      DELETE FROM cecred.TBGEN_ORGAO_EXPEDIDOR WHERE IDORGAO_EXPEDIDOR IN  (1,3,4,5,29,30,31,33,34,35,36,37,38,39,40,42,44,51,53,56,57,59,60,62,63,64,65,26,32,33,41,43 );
   exception
       when others then
         rollback; 
    end;   

   COMMIT;
  
end;