declare 
   i integer;
   
   -- cria cursor para substituicao De-PARA
   CURSOR cr_outros is
   select org.idorgao_expedidor origem
        , 67 destino
     from tbgen_orgao_expedidor org
    where org.idorgao_expedidor in ( 1,3,4,5,29,30,31,34,35,36,37,38,39,40,42,44,56,57,59,60,62,63,64,65,26,32,33,41,43)  
   union all                                            
   select org.idorgao_expedidor origem
        , 27 destino
     from tbgen_orgao_expedidor org
    where org.idorgao_expedidor in ( 33 )
   union all
   select org.idorgao_expedidor origem
        , 54 destino
     from tbgen_orgao_expedidor org
    where org.idorgao_expedidor in ( 51 )
   union all
   select org.idorgao_expedidor origem
        , 52 destino
     from tbgen_orgao_expedidor org
    where org.idorgao_expedidor in ( 53 );            
 
begin
  
  -- Cadastra os novos orgaos expeditores
  --67 - OUTROS
  BEGIN     
       INSERT INTO TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 67 
                                         , 'OUTROS'
                                         , 'Outros');
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                          
                                         
                                         
   --68 - CGPI/DIREX/PF
   BEGIN
       INSERT INTO TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 68 
                                         , 'CGPI/DIREXPF'
                                         , 'Coordenacao Geral De Policia De Imigracao Da Policia Federal');   
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                            
                                         
    --69 - CRC
    BEGIN
       INSERT INTO TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 69 
                                         , 'CRC'
                                         , 'Cartorio De Registro Civil Das Pessoas Naturais');   
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                                                                                          
      
   --70 - MD
   BEGIN
       INSERT INTO TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 70
                                         , 'MD'
                                         , 'Ministerio Da Defesa'); 
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                          

   --71 - SSDS
   BEGIN
       INSERT INTO TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 71
                                         , 'SSDS'
                                         , 'Secretaria Da Seguranca E Da Defesa Social'); 
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                          
                                         
   --72 - SEDS
   BEGIN
       INSERT INTO TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 72
                                         , 'SEDS'
                                         , 'Secretaria De Estado Da Defesa Social');
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                           

   --73 - PC
   BEGIN
       INSERT INTO TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 73
                                         , 'PC'
                                         , 'Policia Civil'); 
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                          

   --74 - PTC
   BEGIN
       INSERT INTO TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 74 
                                         , 'PTC'
                                         , 'Policia Tecnico-Cientifica'); 
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                          

    --75 - SESDC
    BEGIN
       INSERT INTO TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 75 
                                         , 'SESDC'
                                         , 'Secretaria De Estado Da Seguranca, Defesa E Cidadania'); 
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                          

   --76 - SPTC
   Begin
       INSERT INTO TBGEN_ORGAO_EXPEDIDOR ( IDORGAO_EXPEDIDOR
                                         , CDORGAO_EXPEDIDOR
                                         , NMORGAO_EXPEDIDOR )
                                  VALUES ( 76 
                                         , 'SPTC'
                                         , 'Superintendencia Da Policia Tecnico-Cientifica'); 
    EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;                                         
                                     
   --Corrige o nome de alguns orgaos expeditores
   --DETRAN
   UPDATE TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'DETRAN'
        , NMORGAO_EXPEDIDOR = 'Departamento Estadual De Transito'
    WHERE IDORGAO_EXPEDIDOR = 6;                                  

   --CRESS
   UPDATE TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'CRESS'
        , NMORGAO_EXPEDIDOR = 'Conselho Regional De Servico Social'
    WHERE IDORGAO_EXPEDIDOR = 10;  
    
   --MTE
   UPDATE TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'MTE'
        , NMORGAO_EXPEDIDOR = 'Ministerio Do Trabalho E Emprego'
    WHERE IDORGAO_EXPEDIDOR = 27;   
     
     
   --MAER
   UPDATE TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'MAER'
    WHERE IDORGAO_EXPEDIDOR = 45;       
    
   --PF
   UPDATE TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'PF'
    WHERE IDORGAO_EXPEDIDOR = 52;     
    
   --PM
   UPDATE TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'PM'
    WHERE IDORGAO_EXPEDIDOR = 54;     
    
   --SEJUSP
   UPDATE TBGEN_ORGAO_EXPEDIDOR
      SET NMORGAO_EXPEDIDOR = 'Secretaria De Estado De Justica E Seguranca Publica'
    WHERE IDORGAO_EXPEDIDOR = 58;    
    
   --SESP
   UPDATE TBGEN_ORGAO_EXPEDIDOR
      SET NMORGAO_EXPEDIDOR = 'Secretaria De Estado De Seguranca Publica'
    WHERE IDORGAO_EXPEDIDOR = 61;      
    
   --CONRE
   UPDATE TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'CONRE'
    WHERE IDORGAO_EXPEDIDOR = 13;     

   --CREFITO
   UPDATE TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'CREFITO'
    WHERE IDORGAO_EXPEDIDOR = 16;      
    
   --CONRERP
   UPDATE TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'CONRERP'
    WHERE IDORGAO_EXPEDIDOR = 22;     
    
   --CORE
   UPDATE TBGEN_ORGAO_EXPEDIDOR
      SET CDORGAO_EXPEDIDOR = 'CORE'
    WHERE IDORGAO_EXPEDIDOR = 24;        

   -- Efetua a substituicao de diversos orgaos conforme De-PARA
   FOR rw_outros IN cr_outros LOOP
     begin  
       
     UPDATE CRAPASS ASS
        SET ASS.IDORGEXP = rw_outros.destino
      WHERE ASS.IDORGEXP = rw_outros.origem; 

     UPDATE CRAPTTL TTL
        SET TTL.IDORGEXP = rw_outros.destino
      WHERE TTL.IDORGEXP = rw_outros.origem; 

     UPDATE CRAPAVT AVT
        SET AVT.IDORGEXP = rw_outros.destino
      WHERE AVT.IDORGEXP = rw_outros.origem; 

     UPDATE CRAPCRL CRL
        SET CRL.IDORGEXP = rw_outros.destino
      WHERE CRL.IDORGEXP = rw_outros.origem; 

     UPDATE CRAPCJE CJE
        SET CJE.IDORGEXP = rw_outros.destino
      WHERE CJE.IDORGEXP = rw_outros.origem; 

    UPDATE TBCADAST_PESSOA_FISICA FIS
       SET FIS.IDORGAO_EXPEDIDOR = rw_outros.destino
     WHERE FIS.IDORGAO_EXPEDIDOR = rw_outros.origem;         
  
     exception
       when others then
         null; 
     end;
   End loop;
   
   commit;
   
   begin
      DELETE FROM TBGEN_ORGAO_EXPEDIDOR WHERE IDORGAO_EXPEDIDOR IN (1,3,4,5,29,30,31,34,35,36,37,38,39,40,42,44,56,57,59,60,62,63,64,65,26,32,33,41,43 );
   exception
      when others then
	    null;
	end;
	
   COMMIT;
  
end;
