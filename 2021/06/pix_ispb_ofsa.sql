/*
Gerar carga de PIX sem banco (ISPB) para o OFSAA ultimos 24 meses
*/
declare 
  -- Local variables here
  vr_dsdireto   VARCHAR2(4000) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                           ,pr_cdcooper => 0
                                                           ,pr_cdacesso => 'ROOT_DIRCOOP')||'cecred/arq/';
  vr_nmarquiv   VARCHAR2(100)  := 'fraudes_ted.csv';
  vr_handle_arq utl_file.file_type;
  vr_linha_arq  VARCHAR2(2000);
  vr_vet_dados  gene0002.typ_split;
  vr_texto_carga CLOB;
  vr_texto_carga_aux VARCHAR2(32767);
  vr_dscritic VARCHAR2(4000);

  --Definicao do tipo de tabela para contas bloqueadas
  TYPE typ_tab_cpf_cnpj IS
    TABLE OF NUMBER
    INDEX BY VARCHAR2(14);

  vr_list_cpf_cnpj typ_tab_cpf_cnpj;

CURSOR cr_teds IS
  SELECT DISTINCT decode(a.TPPESSOA_PAGADOR,1,lpad(a.NRCPF_CNPJ_PAGADOR,11,'0'),lpad(a.NRCPF_CNPJ_PAGADOR,14,'0')) CNPJ_CPFCLIDEBTD
	   , decode(a.TPPESSOA_RECEBEDOR,1,lpad(a.NRCPF_CNPJ_RECEBEDOR,11,'0'),lpad(a.NRCPF_CNPJ_RECEBEDOR,14,'0')) CNPJ_CPFCLICREDTD
	   , a.IDISPB_RECEBEDOR CDT_ISPB_ID
	   , TO_CHAR(a.NRCONTA_RECEBEDOR) CTCREDTD
	   , 'Approved' STATUS
	   , 'OFSADMN' MODIFIED_BY
	   , to_char(TRUNC(SYSDATE),'RRRR-MM-DD"T"HH24:MI:SS') MODIFIED_DT
	   , 'OFSADMN' APPROVED_BY
	   , to_char(TRUNC(SYSDATE),'RRRR-MM-DD"T"HH24:MI:SS') APPROVED_DT
	   , 'Carga sistema' CMMNTS
	   , to_char(TRUNC(SYSDATE),'RRRR-MM-DD"T"HH24:MI:SS') START_DT
	   , to_char(to_date('31/12/2999', 'DD/MM/RRRR'), 'RRRR-MM-DD"T"HH24:MI:SS') END_DT
	   , 0 SCORE
	FROM tbpix_transacao a
   WHERE a.IDTIPO_TRANSACAO = 'P'
	 AND a.IDSITUACAO = 'P'
	 AND a.DHTRANSACAO BETWEEN ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -24) AND SYSDATE
	 AND a.CDBCCXLT_RECEBEDOR = 0
	 AND a.IDISPB_RECEBEDOR != 0;

CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
			   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
	SELECT ass.nrcpfcgc
	  FROM crapass ass
	 WHERE ass.cdcooper = pr_cdcooper
	   AND ass.nrdconta = pr_nrdconta;

  rw_crapass cr_crapass%ROWTYPE;
  
BEGIN
  
  dbms_output.enable(null);

  gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto    --> Diretório do arquivo
                          ,pr_nmarquiv => vr_nmarquiv   --> Nome do arquivo
                          ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_handle_arq  --> Handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);  --> Erro

  IF utl_file.IS_OPEN(vr_handle_arq) then
    BEGIN
      LOOP
          
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_handle_arq,
                                     pr_des_text => vr_linha_arq);
                                     
        vr_vet_dados := gene0002.fn_quebra_string(pr_string => vr_linha_arq, pr_delimit => ';');
        
        BEGIN
        
          OPEN cr_crapass(pr_cdcooper => to_number(TRIM(vr_vet_dados(1)))
                         ,pr_nrdconta => gene0002.fn_char_para_number(TRIM(vr_vet_dados(2))));
          FETCH cr_crapass INTO rw_crapass;
          CLOSE cr_crapass;
          
          IF NOT vr_list_cpf_cnpj.EXISTS(rw_crapass.nrcpfcgc) THEN
             vr_list_cpf_cnpj(to_char(rw_crapass.nrcpfcgc)) := rw_crapass.nrcpfcgc;
          END IF;
          
          EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'fraude#1 ' || vr_linha_arq);
        END;
      END LOOP;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Fim das linhas do arquivo
        NULL;      
      WHEN OTHERS THEN
        cecred.pc_internal_exception(pr_cdcooper => 3, pr_compleme => vr_linha_arq);
    END;
  END IF;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq);
  
  -- Montar o início da tabela (Num clob para evitar estouro)
  dbms_lob.createtemporary(vr_texto_carga, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_texto_carga,dbms_lob.lob_readwrite);

  gene0002.pc_escreve_xml(vr_texto_carga,vr_texto_carga_aux, 'CNPJ_CPFCLIDEBTD;' ||
                                                             'CNPJ_CPFCLICREDTD;' ||
                                                             'CDT_ISPB_ID;' ||
                                                             'CTCREDTD;' ||
                                                             'STATUS;' ||
                                                             'MODIFIED_BY;' ||
                                                             'MODIFIED_DT;' ||
                                                             'APPROVED_BY;' ||
                                                             'APPROVED_DT;' ||
                                                             'CMMNTS;' ||
                                                             'START_DT;' ||
															 'END_DT;' ||
                                                             'SCORE'  || CHR(10));

  -- Test statements here
  FOR rw_teds IN cr_teds LOOP
    
    IF vr_list_cpf_cnpj.EXISTS(rw_teds.cnpj_cpfclidebtd)  OR
       vr_list_cpf_cnpj.EXISTS(rw_teds.cnpj_cpfclicredtd) THEN
       dbms_output.put_line(rw_teds.cnpj_cpfclidebtd || ' ou ' || rw_teds.cnpj_cpfclicredtd || ' pulado');
       CONTINUE;
    END IF;

    gene0002.pc_escreve_xml(vr_texto_carga,vr_texto_carga_aux, rw_teds.CNPJ_CPFCLIDEBTD || ';' ||
                                                               rw_teds.CNPJ_CPFCLICREDTD || ';' ||
                                                               rw_teds.CDT_ISPB_ID || ';' ||
                                                               rw_teds.CTCREDTD || ';' ||
                                                               rw_teds.STATUS || ';' ||
                                                               rw_teds.MODIFIED_BY || ';' ||
                                                               rw_teds.MODIFIED_DT || ';' ||
                                                               rw_teds.APPROVED_BY || ';' ||
                                                               rw_teds.APPROVED_DT || ';' ||
                                                               rw_teds.CMMNTS || ';' ||
                                                               rw_teds.START_DT || ';' ||
															   rw_teds.END_DT || ';' ||
                                                               rw_teds.SCORE || CHR(10));
  END LOOP;
  
  gene0002.pc_escreve_xml(vr_texto_carga,vr_texto_carga_aux,'',true);
  -- Gerar o arquivo na pasta converte
  gene0002.pc_clob_para_arquivo(pr_clob     => vr_texto_carga
                               ,pr_caminho  => gene0001.fn_diretorio('C',3,'arq')
                               ,pr_arquivo  => 'fraudes_pix_banco_zero.csv'
                               ,pr_des_erro => vr_dscritic);
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_texto_carga);
  dbms_lob.freetemporary(vr_texto_carga);
  commit;
end;