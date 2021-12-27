declare
  --leitura arquivo
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'/cpd/bacas/inc117237';
  vr_nmarqimp        VARCHAR2(100)  := 'liquidados_errados.csv';   
  vr_ind_arquiv      utl_file.file_type;
  vr_linha           varchar2(5000);
  vr_campo           GENE0002.typ_split;

  vr_cdcooper        crapepr.cdcooper%type;  
  vr_nrdconta        crapepr.nrdconta%type;
  vr_nrctremp        crapepr.nrctremp%type;
  vr_lanctoaj        crapepr.vlsdevat%type;
  vr_cdhistor        craplcm.cdhistor%type;
  vr_modalida        NUMBER;
    
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
  rw_crapass       cr_crapass%ROWTYPE;
  
  rw_crapdat       BTCH0001.cr_crapdat%ROWTYPE;
  
BEGIN

  -- Com base na data da central
  OPEN  btch0001.cr_crapdat(pr_cdcooper => 3);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;  

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
      
      vr_campo := GENE0002.fn_quebra_string(pr_string => vr_linha, pr_delimit => ';');

      vr_cdcooper := GENE0002.fn_char_para_number(vr_campo(2));
      vr_nrdconta := GENE0002.fn_char_para_number(vr_campo(3));
      vr_nrctremp := GENE0002.fn_char_para_number(vr_campo(4));
      vr_lanctoaj := GENE0002.fn_char_para_number(vr_campo(7));
      vr_modalida := GENE0002.fn_char_para_number(vr_campo(17));
      
      IF vr_modalida = 1 THEN 
        vr_cdhistor := 2350;
      ELSE
         vr_cdhistor := 2351;
      END IF;

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
    ROLLBACK;
END;
