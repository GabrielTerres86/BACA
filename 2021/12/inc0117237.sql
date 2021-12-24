declare
  --leitura arquivo
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'/cpd/bacas';
  vr_nmarqimp        VARCHAR2(100)  := 'liquidados_errados.csv';   
  vr_ind_arquiv      utl_file.file_type;
  vr_linha           varchar2(5000);
  vr_pos1            number;
  vr_pos2            number;
  vr_pos3            number;
  vr_pos4            number;
  vr_pos6            number;
  vr_pos7            number;
  vr_pos15           number;
  vr_tot_lem         craplem.vllanmto%type;
  vr_tot_ris         crapris.vldivida%type;
  
  vr_nrdconta        crapepr.nrdconta%type;
  vr_nrctremp        crapepr.nrctremp%type;
  vr_cdcooper        crapepr.cdcooper%type;
  vr_lanctoaj        crapepr.vlsdevat%type;
  vr_modalida        craplcr.dsoperac%type;
  vr_cdhistor        craplcm.cdhistor%type;
  
  vr_des_reto      varchar(3);
  vr_tab_erro      GENE0001.typ_tab_erro;
  
  vr_dscritic VARCHAR2(32767);
  
  vr_exc_saida EXCEPTION;
  
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  rw_crapdat       BTCH0001.cr_crapdat%ROWTYPE;
BEGIN
  --ABRIR arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'R'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN  
    dbms_output.put_line( vr_dscritic);    
    RAISE vr_exc_saida;
  END IF;   
  
  /*leitura do cabeçalho*/
  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                              ,pr_des_text => vr_linha);
  LOOP
      BEGIN
        -- loop para ler a linha do arquivo
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                                    ,pr_des_text => vr_linha); --> Texto lido
        EXCEPTION
           WHEN no_data_found THEN 
              EXIT;
      END;
      
      vr_pos1  := instr(vr_linha,';',1,1);
      vr_pos2  := instr(vr_linha,';',1,2);
      vr_pos3  := instr(vr_linha,';',1,3);
      vr_pos4  := instr(vr_linha,';',1,4);
      vr_pos6  := instr(vr_linha,';',1,6);
      vr_pos7  := instr(vr_linha,';',1,7);
      vr_pos15 := instr(vr_linha,';',1,16);
      
      vr_cdcooper := gene0002.fn_char_para_number(TRIM(substr(vr_linha,vr_pos1+1,(vr_pos2-vr_pos1)-1)));
      vr_nrdconta := gene0002.fn_char_para_number(TRIM(substr(vr_linha,vr_pos2+1,(vr_pos3-vr_pos2)-1)));
      vr_nrctremp := gene0002.fn_char_para_number(TRIM(substr(vr_linha,vr_pos3+1,(vr_pos4-vr_pos3)-1)));
      vr_lanctoaj := gene0002.fn_char_para_number(TRIM(substr(vr_linha,vr_pos6+1,(vr_pos7-vr_pos6)-1)));
      vr_modalida := TRIM(substr(vr_linha,vr_pos15+1));
      
      IF vr_modalida = 'EMPRESTIMO' THEN 
        vr_cdhistor := 2350;
      ELSE
         vr_cdhistor := 2351;
      END IF;
      
      OPEN  btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
  
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_nrdconta => vr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;
      
      --Nas operações de empréstimos liquidadas, realizar o histórico 2350 na conta do Cooperado;
      --Nas operações de financiamentos liquidadas, realizar o histórico 2351 na conta do Cooperado;
                                                                 
      EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => vr_cdcooper   --> Cooperativa conectada
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Movimento atual
                                    ,pr_cdagenci => rw_crapass.cdagenci   --> Codigo da agencia
                                    ,pr_cdbccxlt => 100           --> Numero do caixa
                                    ,pr_cdoperad => 1   --> Codigo do operador
                                    ,pr_cdpactra => rw_crapass.cdagenci   --> PA da transacao
                                    ,pr_nrdolote => 600031        --> Numero do Lote
                                    ,pr_nrdconta => vr_nrdconta   --> Número da conta
                                    ,pr_cdhistor => vr_cdhistor  --> Codigo historico
                                    ,pr_vllanmto => vr_lanctoaj   
                                    ,pr_nrparepr => 0   
                                    ,pr_nrctremp => vr_nrctremp   --> Numero do contrato de emprestimo
                                    ,pr_nrseqava => 0   --> Pagamento: Sequencia do avalista
                                    ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                    ,pr_tab_erro => vr_tab_erro); --> Tabela com possives erros
                                        
     IF vr_des_reto <> 'OK' THEN
        RAISE vr_exc_saida;
     END IF;

   END LOOP;
   COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    dbms_output.put_line( sqlerrm);
    dbms_output.put_line( sqlcode);
END;
