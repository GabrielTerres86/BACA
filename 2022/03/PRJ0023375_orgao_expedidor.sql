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
   select cecred.org.idorgao_expedidor origem
        , 54 destino
     from cecred.tbgen_orgao_expedidor org
    where org.idorgao_expedidor in ( 51 )
   union all
   select org.idorgao_expedidor origem
        , 52 destino
     from cecred.tbgen_orgao_expedidor org
    where org.idorgao_expedidor in ( 53 );            
 
begin
  

  BEGIN     
       INSERT INTO cecred.TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 67 
                                         , 'OUTROS'
                                         , 'Outros');
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                          
                                         
                                         

   BEGIN
       INSERT INTO cecred.TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 68 
                                         , 'CGPI/DIREXPF'
                                         , 'Coordenacao Geral De Policia De Imigracao Da Policia Federal');   
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                            
                                         

    BEGIN
       INSERT INTO cecred.TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 69 
                                         , 'CRC'
                                         , 'Cartorio De Registro Civil Das Pessoas Naturais');   
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                                                                                          
      
  
   BEGIN
       INSERT INTO cecred.TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 70
                                         , 'MD'
                                         , 'Ministerio Da Defesa'); 
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                          

 
   BEGIN
       INSERT INTO cecred.TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 71
                                         , 'SSDS'
                                         , 'Secretaria Da Seguranca E Da Defesa Social'); 
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                          
                                         
  
   BEGIN
       INSERT INTO cecred.TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 72
                                         , 'SEDS'
                                         , 'Secretaria De Estado Da Defesa Social');
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                           

  
   BEGIN
       INSERT INTO cecred.TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 73
                                         , 'PC'
                                         , 'Policia Civil'); 
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                          


   BEGIN
       INSERT INTO cecred.TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 74 
                                         , 'PTC'
                                         , 'Policia Tecnico-Cientifica'); 
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                          

 
    BEGIN
       INSERT INTO cecred.TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 75 
                                         , 'SESDC'
                                         , 'Secretaria De Estado Da Seguranca, Defesa E Cidadania'); 
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                          

 
   Begin
       INSERT INTO cecred.TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 76 
                                         , 'SPTC'
                                         , 'Superintendencia Da Policia Tecnico-Cientifica'); 
    EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                         
                                     
 
   UPDATE cecred.TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'DETRAN'
        , NMORGAO_EXPEDIDOR = 'Departamento Estadual De Transito'
    WHERE IDORGAO_EXPEDIDOR = 6;                                  

 
   UPDATE cecred.TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'CRESS'
        , NMORGAO_EXPEDIDOR = 'Conselho Regional De Servico Social'
    WHERE IDORGAO_EXPEDIDOR = 10;  
    
 
   UPDATE cecred.TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'MTE'
        , NMORGAO_EXPEDIDOR = 'Ministerio Do Trabalho E Emprego'
    WHERE IDORGAO_EXPEDIDOR = 27;   
     
     

   UPDATE cecred.TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'MAER'
    WHERE IDORGAO_EXPEDIDOR = 45;       
    
 
   UPDATE cecred.TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'PF'
    WHERE IDORGAO_EXPEDIDOR = 52;     
    
   
   UPDATE cecred.TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'PM'
    WHERE IDORGAO_EXPEDIDOR = 54;     
    
  
   UPDATE cecred.TBGEN_ORGAO_EXPEDIDOR
      SET NMORGAO_EXPEDIDOR = 'Secretaria De Estado De Justica E Seguranca Publica'
    WHERE IDORGAO_EXPEDIDOR = 58;    
    
   
   UPDATE cecred.TBGEN_ORGAO_EXPEDIDOR
      SET NMORGAO_EXPEDIDOR = 'Secretaria De Estado De Seguranca Publica'
    WHERE IDORGAO_EXPEDIDOR = 61;      
    
  
   UPDATE cecred.TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'CONRE'
    WHERE IDORGAO_EXPEDIDOR = 13;     

   
   UPDATE cecred.TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'CREFITO'
    WHERE IDORGAO_EXPEDIDOR = 16;      
    
 
   UPDATE cecred.TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'CONRERP'
    WHERE IDORGAO_EXPEDIDOR = 22;     
    
   
   UPDATE cecred.TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'CORE'
    WHERE IDORGAO_EXPEDIDOR = 24;        

 
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
       
  
     exception
       when others then
         null; 
     end;
   End loop;
   
   commit;
   

  
end;