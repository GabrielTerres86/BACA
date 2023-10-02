DECLARE
  
  vr_dtrefere_ris     DATE := to_date('30/09/2023', 'DD/MM/RRRR');
  vr_dscritic         VARCHAR2(4000);  
  vr_exc_erro         EXCEPTION;  
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop a
     WHERE a.flgativo = 1
       AND a.cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16)
     ORDER BY a.cdcooper DESC;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  PROCEDURE gerarRelatorioCompensacaoMicrocredito(pr_cdcooper  IN cecred.crapcop.cdcooper%TYPE
                                                 ,pr_dtrefere  IN cecred.crapdat.dtmvtolt%TYPE -- data da central que será gerado o arquivo
                                                 ,pr_dscritic OUT cecred.crapcri.dscritic%TYPE) IS

    
    ---> Variaveis <---
    vr_cdprograma VARCHAR2(100) := 'gerarRelatorioCompensacaoMicrocredito';
    vr_dscomple   VARCHAR2(2000);
    
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   NUMBER;
    vr_dscritic   VARCHAR2(4000);
    
    vr_txt_compmicro     VARCHAR2(500);
    vr_nmarquiv          VARCHAR2(200);
    vr_input_file        UTL_FILE.file_type;
    vr_typ_said          VARCHAR2(4);
    vr_nom_diretorio     VARCHAR2(200); 
    vr_nom_dir_copia     VARCHAR2(200); 
    
    vr_tot_vltttlcr_dim            NUMBER := 0;
    vr_tot_vltttlcr_dim_outros     NUMBER := 0;
    vr_totatraso90_dim             NUMBER := 0;
    vr_totatraso90_dim_outros      NUMBER := 0;
    vr_tot_vlj60at90d_dim          NUMBER := 0;
    vr_tot_vlj60ac90d_dim          NUMBER := 0;
    vr_tot_vlj60at90d_dim_outros   NUMBER := 0;
    vr_tot_vlj60ac90d_dim_outros   NUMBER := 0;
    
    ---> Cursores <---
    rw_crapdat datascooperativa := datascooperativa(pr_cdcooper);
    
    CURSOR cr_microcredito(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                          ,pr_dtrefere IN cecred.crapdat.dtmvtolt%TYPE) IS
      SELECT l.dsorgrec
            ,r.qtdiaatr
            ,(r.vldivida + nvl(j.vljura60, 0) + nvl(j.vljurantpp,0)) vldivida
            ,nvl(j.vljura60, 0) vljura60
            ,nvl(j.vljurantpp,0) vljurantpp
            ,r.nrdconta
            ,r.nrctremp
        FROM cecred.crapass a
            ,gestaoderisco.tbrisco_crapris r
            ,cecred.crapepr e
            ,cecred.craplcr l
            ,gestaoderisco.tbrisco_juros_emprestimo j
         WHERE r.cdcooper = a.cdcooper
           AND r.nrdconta = a.nrdconta
           AND r.cdcooper = e.cdcooper
           AND r.nrdconta = e.nrdconta
           AND r.nrctremp = e.nrctremp
           AND e.cdcooper = l.cdcooper
           AND e.cdlcremp = l.cdlcremp
           AND r.cdcooper = j.cdcooper(+)
           AND r.nrdconta = j.nrdconta(+)
           AND r.nrctremp = j.nrctremp(+)
           AND r.dtrefere = j.dtrefere(+)
           AND r.cdcooper = pr_cdcooper
           AND r.dtrefere = pr_dtrefere
           AND r.inddocto = 1
           AND r.vldivida > 0
           AND r.cdmodali IN (299,499)
           AND l.cdusolcr = 1
           AND l.dsorgrec IN ('MICROCREDITO PNMPO CAIXA', 'MICROCREDITO PNMPO DIM', 'MICROCREDITO DIM')
           AND e.inprejuz = 0;
    rw_microcredito cr_microcredito%ROWTYPE;
    
    -- Retorna linha cabeçalho arquivo Radar ou Matera
    FUNCTION fn_set_cabecalho(pr_inilinha IN VARCHAR2
                             ,pr_dtarqmv  IN DATE
                             ,pr_dtarqui  IN DATE
                             ,pr_origem   IN NUMBER      --> Conta Origem
                             ,pr_destino  IN NUMBER      --> Conta Destino
                             ,pr_vltotal  IN NUMBER      --> Soma total de todas as agencias
                             ,pr_dsconta  IN VARCHAR2)   --> Descricao da conta
     RETURN VARCHAR2 IS
    BEGIN
      RETURN pr_inilinha --> Identificacao inicial da linha
              ||TO_CHAR(pr_dtarqmv,'YYMMDD')||',' --> Data AAMMDD do Arquivo
              ||TO_CHAR(pr_dtarqui,'DDMMYY')||',' --> Data DDMMAA
              ||pr_origem||','                    --> Conta Origem
              ||pr_destino||','                   --> Conta Destino
              ||TRIM(TO_CHAR(pr_vltotal,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','
              ||'5210'||','
              ||pr_dsconta;
    END fn_set_cabecalho;
  BEGIN
    
    FOR rw_microcredito IN cr_microcredito(pr_cdcooper => pr_cdcooper
                                          ,pr_dtrefere => pr_dtrefere) LOOP
      IF rw_microcredito.qtdiaatr <= 90 THEN
        IF rw_microcredito.dsorgrec = 'MICROCREDITO DIM' THEN
          vr_tot_vltttlcr_dim := vr_tot_vltttlcr_dim + rw_microcredito.vldivida; -- Acumulo total da linha
          vr_tot_vlj60at90d_dim := vr_tot_vlj60at90d_dim + rw_microcredito.vljura60 + rw_microcredito.vljurantpp;
        ELSIF rw_microcredito.dsorgrec IN ('MICROCREDITO PNMPO CAIXA','MICROCREDITO PNMPO DIM') THEN
          vr_tot_vltttlcr_dim_outros := vr_tot_vltttlcr_dim_outros + rw_microcredito.vldivida; -- Acumulo total da linha
          vr_tot_vlj60at90d_dim_outros := vr_tot_vlj60at90d_dim_outros + rw_microcredito.vljura60 + rw_microcredito.vljurantpp;
        END IF;
      ELSE
        IF rw_microcredito.dsorgrec = 'MICROCREDITO DIM' THEN
          vr_totatraso90_dim := vr_totatraso90_dim + rw_microcredito.vldivida;
          vr_tot_vlj60ac90d_dim := vr_tot_vlj60ac90d_dim + rw_microcredito.vljura60 + rw_microcredito.vljurantpp;
        ELSIF rw_microcredito.dsorgrec IN ('MICROCREDITO PNMPO CAIXA','MICROCREDITO PNMPO DIM') THEN
          vr_totatraso90_dim_outros := vr_totatraso90_dim_outros + rw_microcredito.vldivida;
          vr_tot_vlj60ac90d_dim_outros := vr_tot_vlj60ac90d_dim_outros + rw_microcredito.vljura60 + rw_microcredito.vljurantpp;
        END IF;
      END IF;
    END LOOP;
    
    -- PRJ Microcredito
    IF (nvl(vr_tot_vltttlcr_dim,0)          + 
        nvl(vr_tot_vltttlcr_dim_outros,0)   + 
        nvl(vr_totatraso90_dim,0)           + 
        nvl(vr_totatraso90_dim_outros,0)    +
        nvl(vr_tot_vlj60at90d_dim,0)        +
        nvl(vr_tot_vlj60ac90d_dim,0)        +
        nvl(vr_tot_vlj60at90d_dim_outros,0) +
        nvl(vr_tot_vlj60ac90d_dim_outros,0)  
        ) > 0 THEN

      -- Nome do arquivo a ser gerado
      vr_nmarquiv := to_char(rw_crapdat.dtmvtolt, 'yymmdd')||'_'||lpad(pr_cdcooper,2,0)||'_MICROCREDITO_COMPENSACAO_NOVA_CENTRAL.txt';
      vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => 'contab');
      -- Busca do diretório onde o Radar ou Matera pegará o arquivo
      vr_nom_dir_copia := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdcooper => 0
                                                   ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');

      -- Tenta abrir o arquivo de log em modo gravacao
      cecred.gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nmarquiv          --> Nome do arquivo
                              ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);        --> Erro
      IF vr_dscritic IS NOT NULL THEN
        -- Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      -- Linhas PNMPO DIM E CAIXA
      -- 1ª linha
      -- PRJ Microcredito
      vr_txt_compmicro := fn_set_cabecalho('50'
                                          ,rw_crapdat.dtmvtolt
                                          ,rw_crapdat.dtmvtolt
                                          ,'3965'
                                          ,'9264'
                                          ,vr_tot_vltttlcr_dim_outros
                                          ,'"SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA – VENCIDOS ATE 90 DIAS"');

      cecred.GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                    ,pr_des_text => vr_txt_compmicro);

      -- 2ª linha
      -- PRJ Microcredito
      vr_txt_compmicro := fn_set_cabecalho('50'
                                          ,rw_crapdat.dtmvtolt
                                          ,rw_crapdat.dtmvtolt
                                          ,'3968'
                                          ,'9264'
                                          ,vr_totatraso90_dim_outros
                                          ,'"SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA – VENCIDOS A MAIS DE 90 DIAS"');

      cecred.GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                    ,pr_des_text => vr_txt_compmicro);

      -- 3ª linha
      -- PRJ Microcredito
      vr_txt_compmicro := fn_set_cabecalho('50'
                                          ,rw_crapdat.dtmvtopr
                                          ,rw_crapdat.dtmvtopr
                                          ,'9264'
                                          ,'3965'
                                          ,vr_tot_vltttlcr_dim_outros
                                          ,'"REVERSAO DO SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA – VENCIDOS ATE 90 DIAS"');

      cecred.GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                    ,pr_des_text => vr_txt_compmicro);

      -- 4ª linha
      -- PRJ Microcredito
      vr_txt_compmicro := fn_set_cabecalho('50'
                                          ,rw_crapdat.dtmvtopr
                                          ,rw_crapdat.dtmvtopr
                                          ,'9264'
                                          ,'3968'
                                          ,vr_totatraso90_dim_outros
                                          ,'"REVERSAO DO SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA – VENCIDOS A MAIS DE 90 DIAS"');

      cecred.GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                    ,pr_des_text => vr_txt_compmicro);

      -- 1ª linha RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA
      -- PRJ Microcredito Juro +60 acima 90 dias
      vr_txt_compmicro := fn_set_cabecalho('50'
                                          ,rw_crapdat.dtmvtolt
                                          ,rw_crapdat.dtmvtolt
                                          ,'9264'
                                          ,'3965'
                                          ,vr_tot_vlj60at90d_dim_outros
                                          ,'"JUROS 60 SOBRE SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA – VENCIDOS ATE 90 DIAS"');

      cecred.GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                    ,pr_des_text => vr_txt_compmicro);
                                          
      -- 2ª linha RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA
      -- PRJ Microcredito Juro +60 acima 90 dias
      vr_txt_compmicro := fn_set_cabecalho('50'
                                          ,rw_crapdat.dtmvtolt
                                          ,rw_crapdat.dtmvtolt
                                          ,'9264'
                                          ,'3968'
                                          ,vr_tot_vlj60ac90d_dim_outros
                                          ,'"JUROS 60 SOBRE SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA – VENCIDOS A MAIS DE 90 DIAS"');

      cecred.GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                    ,pr_des_text => vr_txt_compmicro);

      -- 3ª linha RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA
      -- PRJ Microcredito Juro +60 acima 90 dias
      vr_txt_compmicro := fn_set_cabecalho('50'
                                          ,rw_crapdat.dtmvtopr
                                          ,rw_crapdat.dtmvtopr
                                          ,'3965'
                                          ,'9264'
                                          ,vr_tot_vlj60at90d_dim_outros
                                          ,'"REVERSAO JUROS 60 SOBRE SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA – VENCIDOS ATE 90 DIAS"');

      cecred.GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                    ,pr_des_text => vr_txt_compmicro);
                                          
      -- 4ª linha RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA
      -- PRJ Microcredito Juro +60 acima 90 dias
      vr_txt_compmicro := fn_set_cabecalho('50'
                                          ,rw_crapdat.dtmvtopr
                                          ,rw_crapdat.dtmvtopr
                                          ,'3968'
                                          ,'9264'
                                          ,vr_tot_vlj60ac90d_dim_outros
                                          ,'"REVERSAO JUROS 60 SOBRE SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA – VENCIDOS A MAIS DE 90 DIAS"');

      cecred.GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                    ,pr_des_text => vr_txt_compmicro);
                                          
      -- Fechar Arquivo
      BEGIN
        cecred.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception;
          -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
          vr_dscritic := 'Problema ao fechar o arquivo <'||vr_nom_diretorio||'/'||vr_nmarquiv||'>: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Copia o arquivo gerado para o diretório final convertendo para DOS
      cecred.gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarquiv||' > '||vr_nom_dir_copia||'/novacentral/'||vr_nmarquiv||' 2>/dev/null'
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_dscritic);
      -- Testar erro
      IF vr_typ_said = 'ERR' THEN
        vr_dscritic := 'Erro ao copiar o arquivo '||vr_nmarquiv||': '||vr_dscritic;
        RAISE vr_exc_erro;
      END IF;

    END IF;
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN

      -- Se foi retornado apenas codigo
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        -- Buscar a descricao
        vr_dscritic := obterCritica(vr_cdcritic);
      END IF;
      -- Devolvemos codigo e critica encontradas
      pr_dscritic := vr_dscritic ||': '||vr_dscomple;

      sistema.excecaoInterna(pr_cdcooper => pr_cdcooper
                            ,pr_compleme => vr_dscomple || pr_dscritic);

    WHEN OTHERS THEN

      pr_dscritic := 'Erro na : ' || vr_cdprograma || ': ' || SQLERRM;

      sistema.excecaoInterna(pr_cdcooper => pr_cdcooper
                            ,pr_compleme => vr_dscomple || pr_dscritic);

      sistema.Gravarlogprograma(pr_cdcooper      => pr_cdcooper
                               ,pr_ind_tipo_log  => 3 --Erro
                               ,pr_des_log       => pr_dscritic
                               ,pr_cdprograma    => vr_cdprograma
                               ,pr_tpexecucao    => 1);

  END gerarRelatorioCompensacaoMicrocredito;

BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP
    
    gerarRelatorioCompensacaoMicrocredito(pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_dtrefere => vr_dtrefere_ris
                                         ,pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    COMMIT;

  END LOOP;
  
EXCEPTION 
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20000, vr_dscritic);
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
END;
