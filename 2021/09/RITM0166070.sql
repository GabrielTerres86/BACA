declare 
  
  vr_nmdireto    VARCHAR2(100);
  vr_nmarquiv    VARCHAR2(50) := 'rendas.csv';  
  vr_nmarqbkp    VARCHAR2(50) := 'ROLLBACK_rendas.sql';
  vr_input_file  UTL_FILE.FILE_TYPE;
  vr_texto_completo  VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_contlinha   INTEGER := 0;  
  vr_crapalt_progress_recid  VARCHAR2(30);
  vr_ind_arquiv      utl_file.file_type;  

---------
  vr_cdcooper INTEGER;
  vr_nrdconta NUMBER;
  
  vr_conta     VarChar2(14);
  vr_cpfcnpj   VarChar2(14);
  vr_valor     Number(18,2);
  vr_Data      Date;
  vr_DataAnt   Date;  
  vr_retorno   Integer;
  vr_sitAnt    Integer;
  vs_dsaltera  CLOB;
  
  vr_tprendi1  integer;
  vr_tprendi2  integer; 
  vr_tprendi3  integer;
  vr_tprendi4  integer;
  vr_tprendi5  integer;
  vr_tprendi6  integer;   
  vr_vrrendi1  Number(18,2);
  vr_vrrendi2  Number(18,2);  
  vr_vrrendi3  Number(18,2);
  vr_vrrendi4  Number(18,2);
  vr_vrrendi5  Number(18,2);
  vr_vrrendi6  Number(18,2); 
  vr_campo     varchar2(20);
  vr_id        integer;   
  vr_dttransa  DATE;
  vr_hrtransa  VARCHAR2(5); 
  
  
  vr_dtelimin crapass.dtelimin%TYPE;

  vr_des_xml         CLOB := NULL;
  vr_des_alt         CLOB := NULL;
  vr_des_ret         CLOB := NULL;
  vr_setlinha    VARCHAR2(10000);

  vr_dscritic    crapcri.dscritic%TYPE;

  vr_exc_saida   EXCEPTION;

  PROCEDURE pc_escreve_alt(pr_des_dados IN VARCHAR2
                          ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_alt
                           ,vr_texto_completo
                           ,pr_des_dados
                           ,pr_fecha_xml);
  END; 
  
  -- Arquivo de retorno da execução
  PROCEDURE pc_escreve_ret(pr_des_dados IN VARCHAR2
                          ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_ret
                           ,vr_texto_completo_ret
                           ,pr_des_dados
                           ,pr_fecha_xml);
  END; 


begin
  
  -- Buscar caminho do micros
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0166070/';
    
  -- Abrir o arquivo PESSOA FISICA
  gene0001.pc_abre_arquivo (pr_nmdireto => vr_nmdireto    --> Diretório do arquivo
                           ,pr_nmarquiv => vr_nmarquiv    --> Nome do arquivo
                           ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                           ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                           ,pr_des_erro => vr_dscritic);  --> Erro
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqbkp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de critica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exc_saida;
  END IF;  
  

  vr_des_ret := NULL;

  -- Laco para leitura de linhas do arquivo
  LOOP
    -- Carrega handle do arquivo
    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                ,pr_des_text => vr_setlinha); --> Texto lido         
    vr_contlinha:= vr_contlinha + 1;
          
    -- ignorar primeira linha
    IF vr_contlinha = 1 THEN
      continue;
    END IF;

    -- Retirar quebra de linha
    vr_setlinha := REPLACE(REPLACE(vr_setlinha,CHR(10)),CHR(13));
    
    vr_conta     := TRIM(gene0002.fn_busca_entrada(2,vr_setlinha,';'));
    vr_cpfcnpj   := TRIM(gene0002.fn_busca_entrada(3,vr_setlinha,';'));
    vr_valor     := TRIM(gene0002.fn_busca_entrada(5,vr_setlinha,';'));   
    
    BEGIN

      BEGIN 
            
            SELECT TPDRENDI##1
                 , TPDRENDI##2
                 , TPDRENDI##3
                 , TPDRENDI##4
                 , TPDRENDI##5
                 , TPDRENDI##6      
                 , VLDRENDI##1
                 , VLDRENDI##2
                 , VLDRENDI##3
                 , VLDRENDI##4
                 , VLDRENDI##5
                 , VLDRENDI##6
              INTO vr_tprendi1
                 , vr_tprendi2  
                 , vr_tprendi3
                 , vr_tprendi4
                 , vr_tprendi5
                 , vr_tprendi6    
                 , vr_vrrendi1
                 , vr_vrrendi2  
                 , vr_vrrendi3
                 , vr_vrrendi4
                 , vr_vrrendi5
                 , vr_vrrendi6           
        FROM CRAPTTL 
       WHERE CDCOOPER = 7 
         AND NRDCONTA = vr_conta 
         AND NRCPFCGC = vr_cpfcnpj;
         
       --ATUALIZA RENDIMENTO
       
       If vr_tprendi1 = 0 then
          vr_campo := 'TPDRENDI##1'; 
          UPDATE CRAPTTL SET TPDRENDI##1 = 4 , VLDRENDI##1 = vr_valor WHERE CDCOOPER = 7 AND NRDCONTA = vr_conta AND NRCPFCGC = vr_cpfcnpj;
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'UPDATE crapttl SET TPDRENDI##1 = 0 , VLDRENDI##1 = 0 WHERE CDCOOPER = 7 AND NRDCONTA = ' || vr_conta || ' AND NRCPFCGC = ' || vr_cpfcnpj || ';');
       elsif vr_tprendi2 = 0 then
          vr_campo := 'TPDRENDI##2';         
          UPDATE CRAPTTL SET TPDRENDI##2 = 4 , VLDRENDI##2 = vr_valor WHERE CDCOOPER = 7 AND NRDCONTA = vr_conta AND NRCPFCGC = vr_cpfcnpj;
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'UPDATE crapttl SET TPDRENDI##2 = 0 , VLDRENDI##2 = 0 WHERE CDCOOPER = 7 AND NRDCONTA = ' || vr_conta || ' AND NRCPFCGC = ' || vr_cpfcnpj || ';');
       elsif vr_tprendi3 = 0 then
          vr_campo := 'TPDRENDI##3';         
          UPDATE CRAPTTL SET TPDRENDI##3 = 4 , VLDRENDI##3 = vr_valor WHERE CDCOOPER = 7 AND NRDCONTA = vr_conta AND NRCPFCGC = vr_cpfcnpj;
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'UPDATE crapttl SET TPDRENDI##3 = 0 , VLDRENDI##3 = 0 WHERE CDCOOPER = 7 AND NRDCONTA = ' || vr_conta || ' AND NRCPFCGC = ' || vr_cpfcnpj || ';');
       elsif vr_tprendi4 = 0 then
          vr_campo := 'TPDRENDI##4';         
          UPDATE CRAPTTL SET TPDRENDI##4 = 4 , VLDRENDI##4 = vr_valor WHERE CDCOOPER = 7 AND NRDCONTA = vr_conta AND NRCPFCGC = vr_cpfcnpj;
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'UPDATE crapttl SET TPDRENDI##4 = 0 , VLDRENDI##4 = 0 WHERE CDCOOPER = 7 AND NRDCONTA = ' || vr_conta || ' AND NRCPFCGC = ' || vr_cpfcnpj || ';');
       elsif vr_tprendi5 = 0 then
          vr_campo := 'TPDRENDI##5';         
          UPDATE CRAPTTL SET TPDRENDI##5 = 4 , VLDRENDI##5 = vr_valor WHERE CDCOOPER = 7 AND NRDCONTA = vr_conta AND NRCPFCGC = vr_cpfcnpj;
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'UPDATE crapttl SET TPDRENDI##5 = 0 , VLDRENDI##5 = 0 WHERE CDCOOPER = 7 AND NRDCONTA = ' || vr_conta || ' AND NRCPFCGC = ' || vr_cpfcnpj || ';');
       elsif vr_tprendi6 = 0 then
          vr_campo := 'TPDRENDI##6'; 
          UPDATE CRAPTTL SET TPDRENDI##6 = 4 , VLDRENDI##6 = vr_valor WHERE CDCOOPER = 7 AND NRDCONTA = vr_conta AND NRCPFCGC = vr_cpfcnpj;
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'UPDATE crapttl SET TPDRENDI##6 = 0 , VLDRENDI##6 = 0 WHERE CDCOOPER = 7 AND NRDCONTA = ' || vr_conta || ' AND NRCPFCGC = ' || vr_cpfcnpj || ';');
       end if;
 
      -- GRAVA ALTERA
       BEGIN
            SELECT DSALTERA
              INTO vs_dsaltera
              FROM CRAPALT
             WHERE CDCOOPER = 7 
               AND NRDCONTA = vr_conta 
               AND TPALTERA = 2 
               AND DTALTERA = ( SELECT DTMVTOLT FROM CRAPDAT WHERE CDCOOPER = 7 );     
   
       
         UPDATE CRAPALT 
            SET DSALTERA = vs_dsaltera || ', atualizacao outros rendimentos' 
          WHERE CDCOOPER = 7 
            AND NRDCONTA = vr_conta 
            AND TPALTERA = 2 
            AND DTALTERA = ( SELECT DTMVTOLT FROM CRAPDAT WHERE CDCOOPER = 7 );
            
             

          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'UPDATE CRAPALT SET DSALTERA = ' || vs_dsaltera ||' WHERE CDCOOPER = 7 AND TPALTERA = 2 AND DTALTERA = TRUNC( SYSDATE ) AND NRDCONTA = ' || vr_conta || ';');

       EXCEPTION
          WHEN OTHERS THEN 
          INSERT INTO CRAPALT ( CDCOOPER
                              , NRDCONTA
                              , TPALTERA
                              , FLGCTITG
                              , DTALTERA
                              , CDOPERAD
                              , DSALTERA )
                        VALUES ( 7
                               , vr_conta
                               , 2
                               , 3
                               , ( SELECT DTMVTOLT FROM CRAPDAT WHERE CDCOOPER = 7 )
                               , 1
                               , 'atualizacao outros rendimentos' )
                          returning PROGRESS_RECID into vr_id;         

          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'DELETE FROM CRAPALT WHERE PROGRESS_RECID = ' || vr_id || ';');

       END;
       
       --GRAVA VERLOG
        vr_dttransa := trunc(sysdate);
        vr_hrtransa := to_char(sysdate,'SSSSS');

        INSERT INTO cecred.craplgm(cdcooper
          ,nrdconta
          ,idseqttl
          ,nrsequen
          ,dttransa
          ,hrtransa
          ,dstransa
          ,dsorigem
          ,nmdatela
          ,flgtrans
          ,dscritic
          ,cdoperad
          ,nmendter)
        VALUES
          (7
          ,vr_conta
          ,1
          ,1
          ,vr_dttransa
          ,vr_hrtransa
          ,'atualizacao de rendimento complementar'
          ,'AIMARO'
          ,''
          ,1
          ,' '
          ,1
          ,' ') returning PROGRESS_RECID into vr_id;         

          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'DELETE FROM CRAPLGM WHERE PROGRESS_RECID = ' || vr_id || ';');
        
        INSERT INTO cecred.craplgi(cdcooper
          ,nrdconta
          ,idseqttl
          ,nrsequen
          ,dttransa
          ,hrtransa
          ,nrseqcmp
          ,nmdcampo
          ,dsdadant
          ,dsdadatu)
        VALUES
          (7
          ,vr_conta
          ,1
          ,1
          ,vr_dttransa
          ,vr_hrtransa
          ,1
          ,vr_campo
          ,0
          ,vr_valor) returning PROGRESS_RECID into vr_id;         

          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'DELETE FROM CRAPLGI WHERE PROGRESS_RECID = ' || vr_id || ';');       

       
       commit;
       
        
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception(pr_cdcooper => 0, pr_compleme => 'cdcooper: ' || vr_cdcooper || ' nrdconta:' || vr_nrdconta);
      END;
      


    END;
  END LOOP; -- Loop Arquivo

   EXCEPTION 
  WHEN no_data_found THEN
    -- Fechar o arquivo
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');                            
  
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;   
    
  WHEN vr_exc_saida THEN
  --  dbms_output.put_line(vr_dscritic);
    -- Fechar o arquivo
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto; 
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    -- Fechar o arquivo
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto; 

end;    
