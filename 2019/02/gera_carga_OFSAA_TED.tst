PL/SQL Developer Test script 3.0
171
-- Created on 31/10/2018 by F0030474 
declare 
  --vr_dsdireto        VARCHAR2(4000) := '/usr/coopd3/viacredi/rl'; -- Desenv3
  vr_dsdireto        VARCHAR2(4000) := '/usr/micros/cpd/bacas/SCTASK0049836'; -- Produção, criar uma nova pasta a cada carga
  vr_nmar_contas_exc VARCHAR2(100) := 'contas_excecoes.csv'; -- Arquivo com listagem de contas que não devem ser carregadas
  vr_nmarquiv_saida  VARCHAR2(100)  := 'carga_ted.csv';       -- Arquivo de saída para carga das TEDs no OFSAA
  vr_data_ini_teds   DATE := to_date('01/07/2017','dd/mm/yyyy');  
  vr_handle_arq      utl_file.file_type;
  vr_linha_arq       VARCHAR2(2000);
  vr_vet_dados       gene0002.typ_split;
  vr_trat_cabecalho  NUMBER;
  vr_trat_cab_ok     BOOLEAN;
  vr_qtd_linhas      NUMBER := 0;
  vr_texto_carga     CLOB := ' ';
  vr_texto_carga_aux VARCHAR2(32767) := ' ';
  vr_dscritic        VARCHAR2(4000);
		
  --Definicao do tipo de tabela para contas bloqueadas
  TYPE typ_tab_cpf_cnpj IS
    TABLE OF NUMBER
    INDEX BY VARCHAR2(14);
  vr_list_cpf_cnpj typ_tab_cpf_cnpj;

  CURSOR cr_teds IS
    SELECT DISTINCT decode(tvl.flgpesdb,1,lpad(tvl.cpfcgemi,11,'0'),lpad(tvl.cpfcgemi,14,'0')) CNPJ_CPFCLIDEBTD
                 ,decode(tvl.flgpescr,1,lpad(tvl.cpfcgrcb,11,'0'),lpad(tvl.cpfcgrcb,14,'0')) CNPJ_CPFCLICREDTD
                 ,tvl.cdbccrcb ISPBFICREDTD
                 ,tvl.cdagercb AGCREDTD
                 ,to_char(TRUNC(SYSDATE),'RRRR-MM-DD"T"HH24:MI:SS') START_DT
                 ,to_char(to_date('31/12/2999', 'DD/MM/RRRR'), 'RRRR-MM-DD"T"HH24:MI:SS') END_DT
                 ,0 SCORE
                 ,'Carga sistema' CMMNTS
                 ,'Approved' STATUS
                 ,'OFSADMN' MODIFIED_BY
                 ,to_char(TRUNC(SYSDATE),'RRRR-MM-DD"T"HH24:MI:SS') MODIFIED_DT
                 ,'OFSADMN' APPROVED_BY
                 ,to_char(TRUNC(SYSDATE),'RRRR-MM-DD"T"HH24:MI:SS') APPROVED_DT
    FROM craptvl tvl
   WHERE tvl.tpdoctrf = 3 -- TED
     AND tvl.dtmvtolt >= vr_data_ini_teds -- teds desde 
     AND substr(tvl.idopetrf,-1) IN ('M','I') -- Mobile e IB
     AND tvl.flgopfin = 1
   ORDER BY 1;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
	                 ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
	  SELECT decode(ass.inpessoa,1,lpad(ass.nrcpfcgc,11,'0'),lpad(ass.nrcpfcgc,14,'0')) nrcpfcgc    
		  FROM crapass ass
		 WHERE ass.cdcooper = pr_cdcooper
		   AND ass.nrdconta = pr_nrdconta;
	rw_crapass cr_crapass%ROWTYPE;
  
BEGIN
  dbms_output.enable(buffer_size => NULL);
  dbms_output.put_line('Tentou localizar o arquivo de carga das contas de exceção ('||vr_dsdireto||'/'||vr_nmar_contas_exc||').');  

  -- Carrega o arquivo de contas de exceção na memória para realizar os filtros.
  -- Início
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto    --> Diretório do arquivo
                          ,pr_nmarquiv => vr_nmar_contas_exc    --> Nome do arquivo
                          ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_handle_arq  --> Handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);  --> Erro
  IF vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('Erro pc_clob_para_arquivo '||vr_nmar_contas_exc||'. Erro: '||vr_dscritic);
  END IF;

  IF utl_file.IS_OPEN(vr_handle_arq) then
    BEGIN
      dbms_output.put_line('Iniciou a carga das contas de exceção.');
      LOOP
          
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_handle_arq,
                                     pr_des_text => vr_linha_arq);
                                     
        vr_vet_dados := gene0002.fn_quebra_string(pr_string => vr_linha_arq, pr_delimit => ';');

        -- Verifica se tem linha de cabeçalho no CSV
        IF vr_qtd_linhas = 0 THEN
          BEGIN
            vr_trat_cabecalho := to_number(TRIM(vr_vet_dados(1)));
            vr_trat_cab_ok    := TRUE;
          EXCEPTION 
            WHEN OTHERS THEN
              vr_trat_cab_ok    := FALSE; 
          END;
        ELSE
          vr_trat_cab_ok    := TRUE;
        END IF;  

        IF vr_trat_cab_ok THEN        
          OPEN cr_crapass(pr_cdcooper => to_number(REPLACE(REPLACE(TRIM(vr_vet_dados(1)),chr(10),NULL),chr(13),NULL))
                         ,pr_nrdconta => to_number(REPLACE(REPLACE(trim(vr_vet_dados(2)),chr(10),NULL),chr(13),NULL)));
          FETCH cr_crapass INTO rw_crapass;
          CLOSE cr_crapass;
          
          IF NOT vr_list_cpf_cnpj.EXISTS(rw_crapass.nrcpfcgc) THEN
             vr_list_cpf_cnpj(rw_crapass.nrcpfcgc) := rw_crapass.nrcpfcgc;
             dbms_output.put_line('Conta: '||rw_crapass.nrcpfcgc);
          END IF;
        END IF;
        
        vr_qtd_linhas := vr_qtd_linhas+1;        
      END LOOP;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Fim das linhas do arquivo
        NULL;      
    END;
  END IF;
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq);
  -- Fim carga de exceções.
  
  dbms_output.put_line('Finalizou a carga das contas de exceção (Total de contas '||(vr_qtd_linhas-1)||').');
  
  -- Montar o início da tabela (Num clob para evitar estouro)
  dbms_lob.createtemporary(vr_texto_carga, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_texto_carga,dbms_lob.lob_readwrite);

  -- Test statements here
  FOR rw_teds IN cr_teds LOOP
    
    -- se for uma conta de exceção não será feita a carga.
    IF vr_list_cpf_cnpj.EXISTS(rw_teds.cnpj_cpfclidebtd)  OR
       vr_list_cpf_cnpj.EXISTS(rw_teds.cnpj_cpfclicredtd) THEN
       dbms_output.put_line('Exc - '||rw_teds.cnpj_cpfclidebtd||' e '||rw_teds.cnpj_cpfclicredtd);
       CONTINUE;
    END IF;
  
    gene0002.pc_escreve_xml(vr_texto_carga,vr_texto_carga_aux, rw_teds.cnpj_cpfclidebtd  || ';' ||
                                                               rw_teds.cnpj_cpfclicredtd || ';' ||
                                                               rw_teds.ispbficredtd      || ';' ||
                                                               rw_teds.agcredtd          || ';' ||
                                                               rw_teds.start_dt          || ';' ||
                                                               rw_teds.end_dt            || ';' ||
                                                               rw_teds.score             || ';' ||
                                                               rw_teds.cmmnts            || ';' ||
                                                               rw_teds.status            || ';' ||
                                                               rw_teds.modified_by       || ';' ||
                                                               rw_teds.modified_dt       || ';' ||
                                                               rw_teds.approved_by       || ';' ||
                                                               rw_teds.approved_dt       || CHR(13));    
  END LOOP;
  
  gene0002.pc_escreve_xml(vr_texto_carga,vr_texto_carga_aux,'',true);
  
  dbms_output.put_line('Finalizou a carga das TEDs do período.');  
  dbms_output.put_line('Tentou criar o arquivo de dispositivos ('||vr_dsdireto||'/'||vr_nmarquiv_saida||').');  
  
  -- Gerar o arquivo na pasta converte
  gene0002.pc_clob_para_arquivo(pr_clob     => vr_texto_carga
                               ,pr_caminho  => vr_dsdireto
                               ,pr_arquivo  => vr_nmarquiv_saida
                               ,pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('Erro pc_clob_para_arquivo '||vr_nmarquiv_saida||'. Erro: '||vr_dscritic);
  END IF;
                               
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_texto_carga);
  dbms_lob.freetemporary(vr_texto_carga);

  dbms_output.put_line('Fim carga TEDs.');
  
  COMMIT;
  
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line('Erro geral '||SQLERRM);
end;
0
0
