PL/SQL Developer Test script 3.0
137
DECLARE
    vr_ind_arquiv utl_file.file_type;     --> Handle do arquivo
    vr_ind_arqlog utl_file.file_type;     --> Handle do arquivo
    vr_des_text   VARCHAR2(2000);         --> Conteúdo da Linha do Arquivo    
    vr_registro   gene0002.typ_split;     --> Array para guardar o split dos dados contidos no arquivo

    vr_tab_retorno   lanc0001.typ_reg_retorno;
    vr_incrineg      INTEGER;      -- Indicador de crítica do negócio

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_dscritic   VARCHAR2(4000);
    vr_cdcritic   NUMBER;
    
    vr_cdagenci   NUMBER;
    vr_nrdconta  NUMBER;
    vr_vllanmto  NUMBER;
    
    vr_contador   NUMBER := 10000;
BEGIN
    
    gene0001.pc_informa_acesso(pr_module => 'ESTORNO_CRPS750',
                               pr_action => 'ESTORNO_CRPS750');


    gene0001.pc_abre_arquivo(pr_nmdireto => GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                     ,pr_cdcooper => '0'
                                                                     ,pr_cdacesso => 'ROOT_DIRCOOP') || '/arquivos' --> Diretório do arquivo
                            ,pr_nmarquiv => 'lancamentos_indevidos.csv'  --> Nome do arquivo
                            ,pr_tipabert => 'R'               --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_ind_arquiv     --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);     --> Erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    --Criar arquivo de log
    gene0001.pc_abre_arquivo(pr_nmdireto => GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                     ,pr_cdcooper => '0'
                                                                     ,pr_cdacesso => 'ROOT_DIRCOOP') || '/arquivos' --> Diretorio do arquivo
                            ,pr_nmarquiv => 'lancamentos_log.txt'             --> Nome do arquivo
                            ,pr_tipabert => 'W'                        --> modo de abertura (r,w,a)
                            ,pr_utlfileh => vr_ind_arqlog              --> handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);              --> erro
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN        
       RAISE vr_exc_saida;
    END IF;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Inicio Processo');  
    
    
    -- Se o arquivo estiver aberto, percorre o mesmo e guarda todas as linhas
    IF  utl_file.IS_OPEN(vr_ind_arquiv) THEN
      
      -- Lê primeira linha do arquivo aberto
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                                  ,pr_des_text => vr_des_text); --> Texto lido

      vr_registro := gene0002.fn_quebra_string(pr_string  => vr_des_text
                                              ,pr_delimit => ';');

      -- Ler demais linhas do arquivo
      LOOP
        BEGIN
          -- Lê a linha do arquivo aberto
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                                      ,pr_des_text => vr_des_text); --> Texto lido
          
          vr_registro := gene0002.fn_quebra_string(pr_string  => vr_des_text
                                                  ,pr_delimit => ';');

          -- inserir lancto
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 
          'conta = ' || vr_registro(2) ||
          ' valor = ' || replace(vr_registro(11),',' , '.'));

           vr_contador := vr_contador + 1;
           
           vr_cdagenci := to_number(vr_registro(3));
           vr_nrdconta := to_number(vr_registro(2));
           vr_vllanmto := GENE0002.fn_char_para_number(vr_registro(11));-- (replace(vr_registro(11),',' , '.')); --to_number(vr_registro(11));

           --CDCOOPER, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCTABB, NRDOCMTO
           --CDCOOPER, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRSEQDIG
           LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => 1             -- cdcooper
                                             ,pr_dtmvtolt => to_date('22/12/2021','dd/mm/rrrr')     -- dtmvtolt
                                             ,pr_cdagenci => vr_cdagenci    -- cdagenci
                                             ,pr_cdbccxlt => 100     -- cdbccxlt
                                             ,pr_nrdolote => 600031  -- nrdolote
                                             ,pr_nrdconta => vr_nrdconta     -- nrdconta
                                             ,pr_nrdctabb => vr_nrdconta     -- nrdctabb
                                             ,pr_nrdctitg => to_char(vr_nrdconta,'fm00000000') -- nrdctitg
                                             ,pr_nrdocmto => to_char(vr_contador)            -- nrdocmto
                                             ,pr_cdhistor => 3871                    -- cdhistor
                                             ,pr_inprolot => 1
--                                             ,pr_nrseqdig => vr_contador             -- Nvl(rw_craplot.nrseqdig,0) + 1 -- nrseqdig
                                             ,pr_vllanmto => vr_vllanmto   -- vllanmto
                                             ,pr_cdpesqbb => ''                     -- cdpesqbb
                                             ,pr_vldoipmf => 0                       -- vldoipmf
                                             -- OUTPUT --
                                             ,pr_tab_retorno => vr_tab_retorno
                                             ,pr_incrineg => vr_incrineg
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
      
          IF nvl(vr_cdcritic, 0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN -- não encontrar mais linhas
            EXIT;
          WHEN OTHERS THEN
            btch0001.pc_log_internal_exception(3);
        END;  
      END LOOP;
    END IF;        

    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Fim Processo com sucesso');  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog); --> Handle do arquivo aberto;  

    COMMIT;    

EXCEPTION
  WHEN vr_exc_saida THEN
    --LOG
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);  
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Fim Processo com erro');  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog); --> Handle do arquivo aberto;  
    ROLLBACK;
  WHEN OTHERS THEN
    btch0001.pc_log_internal_exception(3);
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Fim Processo com erro');  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog); --> Handle do arquivo aberto;  
    ROLLBACK; 
END;
0
1
vr_registro
