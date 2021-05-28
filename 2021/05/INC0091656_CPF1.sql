declare 
  
  vr_nmdireto    VARCHAR2(100);
  vr_nmarquiv    VARCHAR2(50) := 'CPF1.csv'; 
  vr_nmarqbkp    VARCHAR2(50) := 'ROLLBACK_cpf1.sql';
  vr_input_file  UTL_FILE.FILE_TYPE;
  vr_texto_completo  VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_contlinha   INTEGER := 0;  
  vr_crapalt_progress_recid  VARCHAR2(30);
  vr_ind_arquiv      utl_file.file_type;  

---------
  vr_cdcooper INTEGER;
  vr_nrdconta NUMBER;
  
  vr_tipo      VarChar2(2);
  vr_cpfcnpj   VarChar2(14);
  vr_Situacao  Varchar2(40);
  vr_Data      Date;
  vr_DataAnt   Date;  
  vr_retorno   Integer;
  vr_sitAnt    Integer;
  
  
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
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0091656/';
    
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
    
    vr_tipo      := TRIM(gene0002.fn_busca_entrada(1,vr_setlinha,';'));
    vr_cpfcnpj   := TRIM(gene0002.fn_busca_entrada(2,vr_setlinha,';'));
    vr_Situacao  := TRIM(gene0002.fn_busca_entrada(3,vr_setlinha,';'));   
    vr_Data      := TRUNC(TO_DATE(gene0002.fn_busca_entrada(4,vr_setlinha,';'),'DD/MM/YYYY HH24:MI')); 
    
      IF upper(vr_Situacao) = 'REGULAR' THEN
        vr_retorno := 1;
      ELSIF upper(vr_Situacao) like '%PENDENTE%' THEN
        vr_retorno := 2;
      ELSIF upper(vr_Situacao) = 'CANCELADA' THEN
        vr_retorno := 3;
      ELSIF upper(vr_Situacao) = 'NULA' THEN
        vr_retorno := 4;
      ELSIF upper(vr_Situacao) = 'SUSPENSA' THEN
        vr_retorno := 5;
      ELSIF upper(vr_Situacao) = 'TITULAR FALECIDO' THEN
        vr_retorno := 6;
      ELSIF upper(vr_Situacao) = 'BAIXADA' THEN
        vr_retorno := 7;
      ELSIF upper(vr_Situacao) = 'INAPTA' THEN
        vr_retorno := 8;
      ELSIF upper(vr_Situacao) = 'ATIVA' THEN
        vr_retorno := 9;
      ELSE
        vr_retorno := NULL;
      END IF;    

    
    BEGIN

      BEGIN 
        If vr_Situacao is not null then

            SELECT cdsitcpf, dtcnscpf
              INTO vr_sitAnt, vr_DataAnt
              FROM crapass  
             WHERE nrcpfcgc = vr_cpfcnpj
               AND rownum = 1; 
             
          --  If vr_sitAnt != vr_retorno Then 
               UPDATE crapass c
                  SET c.cdsitcpf = nvl(vr_retorno, c.cdsitcpf)
                    , c.dtcnscpf = vr_Data
                WHERE c.nrcpfcgc = vr_cpfcnpj;
				
               UPDATE crapttl t
                  SET t.cdsitcpf = nvl(vr_retorno, t.cdsitcpf)
                    , t.dtcnscpf = vr_Data
                WHERE t.nrcpfcgc = vr_cpfcnpj;				
            
               commit;
               -- Retornar data de elimin anterior
               gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'UPDATE crapass SET cdsitcpf = ' || vr_sitAnt || ', dtcnscpf = to_date(''' || TO_CHAR( vr_DataAnt, 'DD/MM/YYYY') || ''',''DD/MM/YYYY'') WHERE nrcpfcgc = ' || vr_cpfcnpj || ';'); 
               gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'UPDATE crapttl SET cdsitcpf = ' || vr_sitAnt || ', dtcnscpf = to_date(''' || TO_CHAR( vr_DataAnt, 'DD/MM/YYYY') || ''',''DD/MM/YYYY'') WHERE nrcpfcgc = ' || vr_cpfcnpj || ';'); 


        End if;
        
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
