DECLARE

  vr_dtrefere         DATE := to_date('01/09/2023', 'DD/MM/RRRR');
  vr_dtrefere_ris     DATE := to_date('31/08/2023', 'DD/MM/RRRR');
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop a
     WHERE a.flgativo = 1
       AND a.cdcooper IN (16)
     ORDER BY a.cdcooper DESC;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  vc_cdacesso CONSTANT VARCHAR2(24) := 'DIR_ARQ_CONTAB_X';
  vc_cdtodascooperativas INTEGER := 0;

  TYPE vr_venc IS RECORD(
      dias INTEGER);

  TYPE typ_vencto IS TABLE OF vr_venc INDEX BY BINARY_INTEGER;
      vr_vencto typ_vencto;


  TYPE typ_decimal IS RECORD(
      valor  NUMBER(25, 2) := 0
     ,dsc    VARCHAR(25));

  TYPE typ_arr_decimal
    IS TABLE OF typ_decimal
      INDEX BY BINARY_INTEGER;

  TYPE typ_decimal_pfpj IS RECORD(
      valorpf  NUMBER(25, 2) := 0
     ,dscpf    VARCHAR(25)
     ,valorpj  NUMBER(25, 2) := 0
     ,dscpj    VARCHAR(25)
     ,valormei NUMBER(25, 2) := 0
     ,dscmei   VARCHAR(25));

  TYPE typ_arr_decimal_pfpj
    IS TABLE OF typ_decimal_pfpj
      INDEX BY BINARY_INTEGER;

  vr_nom_arquivo VARCHAR2(100);
  vr_des_xml     CLOB;
  vr_dstexto     VARCHAR2(32700);
  vr_nom_direto  VARCHAR2(400);
  
  vr_dscritic         VARCHAR2(4000);
  vr_exc_erro         EXCEPTION;
  vr_retfile          VARCHAR2(500);
  vr_cdcritic         NUMBER;
  
  vr_dtmvtolt            cecred.crapdat.dtmvtolt%type;
  vr_dtmvtopr            cecred.crapdat.dtmvtopr%type;
  vr_dtultdia            cecred.crapdat.dtultdia%type;
  vr_dtultdia_prxmes     cecred.crapdat.dtultdia%type;
  
  rw_crapdat datascooperativa;
  
    PROCEDURE gerarRelatorioAjusteFiname(pr_cdcooper  IN cecred.crapcop.cdcooper%TYPE
                                      ,pr_dtrefere  IN cecred.crapdat.dtmvtolt%TYPE -- data da central que será gerado o arquivo
                                      ,pr_dscritic OUT cecred.crapcri.dscritic%TYPE) IS
  /* ............................................................................

     Autor      : Darlei Zillmer
     Data       : 14/08/2023
     Dominio    : Gestão de Risco
     Subdominio : Central de risco
     Objetivo   : Gerar relatorio de ajuste de finame, retirado da crps280_i
     Alteracoes :

    ............................................................................ */

    ---> Variaveis <---
    vr_cdprograma VARCHAR2(100) := 'gerarRelatorioAjusteFiname';
    vr_dscomple   VARCHAR2(2000);

    vr_exc_erro   EXCEPTION;
    vr_cdcritic   NUMBER;
    vr_dscritic   VARCHAR2(4000);

    vr_nmarqfin         VARCHAR2(200);
    vr_nom_diretorio    VARCHAR2(200);
    vr_nom_dir_copia    VARCHAR2(200);
    vr_input_file       UTL_FILE.file_type;
    vr_setlinha         VARCHAR2(400);
    vr_typ_said         VARCHAR2(4);
    vr_chave_nivris     VARCHAR2(10);
    vr_tot_libctnfiname NUMBER := 0;
    vr_tot_prvperdafiname NUMBER := 0;

    vr_percentu         NUMBER(5,2); --> Percentual auxiliar
    vr_vlpercen         NUMBER;      --> Valor auxiliar para calcular o atraso
    vr_vlpreatr         NUMBER;      --> Valor perstação em atraso
    vr_dsnivris         VARCHAR2(2); --> Nivel do risco atual
    vr_contador         INTEGER;     -- Contador para a tabela de riscos

    vr_destino          NUMBER;
    vr_origem           NUMBER;

    -- Definição de registro para totalização por nível de risco de FINAME
    TYPE typ_reg_finame_nivris IS RECORD(vlslddev NUMBER);  -- Valor acumulado saldo devedor

    -- Definicao do tipo de tabela totalização por nível de risco de FINAME
    TYPE typ_tab_finame_nivris IS TABLE OF typ_reg_finame_nivris INDEX BY cecred.crawepr.dsnivris%type;

    -- Vetor para armazenar a totalização por nível de risco de FINAME
    vr_tab_finame_nivris typ_tab_finame_nivris;

    -- Definição do tipo de registro para englobar descrições e percentuais dos riscos A, B, C, etc...
    -- Obs: Na versao antiga do programa, cada campo era um vetor, na nova, todos os campos
    --      ficam presentes num unico registro da tabela vr_tab_risco
    TYPE typ_reg_risco IS
       RECORD(dsdrisco VARCHAR2(2)   -- "x(02)"
             ,percentu NUMBER(5,2)); -- "zz9.99"

    -- Definicao do tipo de tabela de riscos
    TYPE typ_tab_risco IS TABLE OF typ_reg_risco INDEX BY PLS_INTEGER;
    -- Vetor para armazenar os dados de riscos
    vr_tab_risco typ_tab_risco;

    ---> Cursores <---
    rw_crapdat datascooperativa := datascooperativa(pr_cdcooper);

    CURSOR cr_finame(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                    ,pr_dtrefere IN cecred.crapdat.dtmvtolt%TYPE
                    ,pr_dtmvtolt IN cecred.crapdat.dtmvtolt%TYPE) IS
      SELECT r.vldivida
            ,0 vljura60
            ,0 vljurantpp
            ,r.innivris
            ,r.nrdconta
            ,r.nrctremp
            ,r.cdmodali
            ,r.dtinictr
            ,(SELECT SUM(v.vldivida)
                FROM gestaoderisco.tbrisco_crapvri v
               WHERE v.cdcooper = r.cdcooper
                 AND v.nrdconta = r.nrdconta
                 AND v.dtrefere = r.dtrefere
                 AND v.cdmodali = r.cdmodali
                 AND v.nrctremp = r.nrctremp
                 AND v.nrseqctr = r.nrseqctr
                 AND v.cdvencto BETWEEN 110 AND 290) vltotdiv
        FROM gestaoderisco.tbrisco_crapris r
            ,cecred.craplim l
       WHERE l.cdcooper = r.cdcooper
         AND l.nrdconta = r.nrdconta
         AND l.nrctrlim = r.nrctremp
         AND r.cdcooper = pr_cdcooper
         AND r.dtrefere = pr_dtrefere
         AND r.cdmodali = 201
         AND l.tpctrlim = 1  --> Cheque especial
         AND l.insitlim = 2  --> Ativo
         AND l.cddlinha = 2;
    rw_finame cr_finame%ROWTYPE;

    -- Cursor genérico de parametrização --
    CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_nmsistem IN craptab.nmsistem%TYPE
                     ,pr_tptabela IN craptab.tptabela%TYPE
                     ,pr_cdempres IN craptab.cdempres%TYPE
                     ,pr_cdacesso IN craptab.cdacesso%TYPE
                     ,pr_tpregist IN craptab.tpregist%TYPE) IS
      SELECT tab.dstextab
            ,tab.tpregist
        FROM cecred.craptab tab
       WHERE tab.cdcooper        = pr_cdcooper
         AND UPPER(tab.nmsistem) = pr_nmsistem
         AND UPPER(tab.tptabela) = pr_tptabela
         AND tab.cdempres        = pr_cdempres
         AND UPPER(tab.cdacesso) = pr_cdacesso
         AND tab.tpregist        >= pr_tpregist
       ORDER BY tab.progress_recid;
    rw_craptab cr_craptab%ROWTYPE;

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

    -- Retorna linha gerencial arquivo Radar ou Matera
    FUNCTION fn_set_gerencial(pr_cdagenci in number
                             ,pr_vlagenci in number)
    RETURN VARCHAR2 IS
    BEGIN
      RETURN lpad(pr_cdagenci,3,0) || ',' ||TRIM(TO_CHAR(pr_vlagenci,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
    END fn_set_gerencial;
  BEGIN

    -- Nome do arquivo a ser gerado
    vr_nmarqfin := to_char(pr_dtrefere, 'yymmdd')||'_'||lpad(pr_cdcooper,2,0)||'_AJUSTE_FINAME_NOVA_CENTRAL.txt';

    vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => 'contab');
    -- Busca do diretório onde o Radar ou Matera pegará o arquivo
    vr_nom_dir_copia := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                 ,pr_cdcooper => 0
                                                 ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
    -- Tenta abrir o arquivo de log em modo gravacao
    cecred.gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                            ,pr_nmarquiv => vr_nmarqfin          --> Nome do arquivo
                            ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);        --> Erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Leitura das descricoes de risco A,B,C etc e percentuais
    FOR rw_craptab IN cr_craptab(pr_cdcooper => pr_cdcooper
                                ,pr_nmsistem => 'CRED'
                                ,pr_tptabela => 'GENERI'
                                ,pr_cdempres => 00
                                ,pr_cdacesso => 'PROVISAOCL'
                                ,pr_tpregist => 0) LOOP
      -- Para cada registro, buscar o contador atual na posição 12
      vr_contador := SUBSTR(rw_craptab.dstextab,12,2);
      -- Adicionar na tabela as informações de descrição e percentuais
      vr_tab_risco(vr_contador).dsdrisco := TRIM(SUBSTR(rw_craptab.dstextab,8,3));
      vr_tab_risco(vr_contador).percentu := SUBSTR(rw_craptab.dstextab,1,6);
    END LOOP;

    -- Alimentar variavel para nao ser preciso criar registro na PROVISAOCL
    vr_tab_risco(10).dsdrisco := 'HH';
    vr_tab_risco(10).percentu := 0;

    FOR rw_finame IN cr_finame(pr_cdcooper => pr_cdcooper
                              ,pr_dtrefere => pr_dtrefere
                              ,pr_dtmvtolt => pr_dtrefere) LOOP
      -- Guardar percentual
      vr_percentu := vr_tab_risco(rw_finame.innivris).percentu;
      -- Calcular o percentual para o atraso com base nos percentuais da tabela
      vr_vlpercen := vr_percentu / 100;

      -- Calcular o valor de prestação em atraso
      vr_vlpreatr := ROUND( (rw_finame.vltotdiv - rw_finame.vljura60
                                                - nvl(rw_finame.vljurantpp, 0) -- PRJ577 -- O cálculo da provisão deve considerar o Valor do Juros+60 Anterior
                            ) * vr_vlpercen ,2);

      GESTAODERISCO.calcularProvisaoRiscoAtual(pr_cdcooper => pr_cdcooper,
                                               pr_nrdconta => rw_finame.nrdconta,
                                               pr_nrctremp => rw_finame.nrctremp,
                                               pr_cdmodali => rw_finame.cdmodali,
                                               pr_vlpreatr => vr_vlpreatr,
                                               pr_dscritic => vr_dscritic);

      IF rw_finame.dtinictr >= TRUNC(pr_dtrefere,'mm') AND rw_finame.dtinictr <= pr_dtrefere THEN
        vr_tot_libctnfiname   := vr_tot_libctnfiname + rw_finame.vldivida;
      END IF;

      vr_tot_prvperdafiname := vr_tot_prvperdafiname + vr_vlpreatr;

      vr_dsnivris := vr_tab_risco(rw_finame.innivris).dsdrisco;
      --Agupar valores microcrédito das filiadas por nível de risco
      IF vr_tab_finame_nivris.exists(vr_dsnivris) THEN
        vr_tab_finame_nivris(vr_dsnivris).vlslddev := vr_tab_finame_nivris(vr_dsnivris).vlslddev + rw_finame.vltotdiv;
      ELSE
        vr_tab_finame_nivris(vr_dsnivris).vlslddev := rw_finame.vltotdiv;
      END IF;

    END LOOP;

    -- Valor liberação contrato finame
    IF vr_tot_libctnfiname > 0 THEN
      vr_setlinha := fn_set_cabecalho('20'
                                     ,pr_dtrefere
                                     ,pr_dtrefere
                                     ,1432
                                     ,1631
                                     ,vr_tot_libctnfiname
                                     ,'"AJUSTE CONTABIL REF. LIBERACAO DE RECURSO BNDES - FINAME"');

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto para escrita

      vr_setlinha := fn_set_gerencial('999',vr_tot_libctnfiname);

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto para escrita

    END IF;

    -- Valor provisão de perda contrato finame
    IF vr_tot_prvperdafiname > 0 THEN
      -- Linhas de provisão
      vr_setlinha := fn_set_cabecalho('20'
                                     ,pr_dtrefere
                                     ,pr_dtrefere
                                     ,1722
                                     ,1435
                                     ,vr_tot_prvperdafiname
                                     ,'"AJUSTE CONTABIL – PROVISAO BNDES FINAME"');

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto para escrita

      vr_setlinha := fn_set_gerencial('999',vr_tot_prvperdafiname);

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto para escrita

      --Linhas de reversão
      vr_setlinha := fn_set_cabecalho('20'
                                     ,vr_dtmvtopr
                                     ,vr_dtmvtopr
                                     ,1435
                                     ,1722
                                     ,vr_tot_prvperdafiname
                                     ,'"REVERSAO AJUSTE CONTABIL – PROVISAO BNDES FINAME"');

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto para escrita

      vr_setlinha := fn_set_gerencial('999',vr_tot_prvperdafiname);

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto para escrita

    END IF;

    --
    vr_chave_nivris := vr_tab_finame_nivris.first;
    LOOP
      EXIT WHEN vr_chave_nivris IS NULL;
      --Gera no arquivo linhas referente a valor de liberação de contrato
      IF vr_tab_finame_nivris(vr_chave_nivris).vlslddev > 0 THEN

        IF vr_chave_nivris IN ('A','AA') THEN
          vr_destino := 3321;  --provisão
          vr_origem  := 3321;  --reversão
        ELSIF vr_chave_nivris = 'B' THEN
          vr_destino := 3332; --provisão
          vr_origem  := 3332; --reversão
        ELSIF vr_chave_nivris = 'C' THEN
          vr_destino := 3342; --provisão
          vr_origem  := 3342; --reversão
        ELSIF vr_chave_nivris = 'D' THEN
          vr_destino := 3352; --provisão
          vr_origem  := 3352; --reversão
        ELSIF vr_chave_nivris = 'E' THEN
          vr_destino := 3362; --provisão
          vr_origem  := 3362; --reversão
        ELSIF vr_chave_nivris = 'F' THEN
          vr_destino := 3372; --provisão
          vr_origem  := 3372; --reversão
        ELSIF vr_chave_nivris = 'G' THEN
          vr_destino := 3382; --provisão
          vr_origem  := 3382; --reversão
        ELSIF vr_chave_nivris IN ('H','HH') THEN
          vr_destino := 3392; --provisão
          vr_origem  := 3392; --reversão
        END IF;

        -- Gerar linhas de PROVISÃO
        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_dtrefere
                                       ,pr_dtrefere
                                       ,9302
                                       ,vr_destino
                                       ,vr_tab_finame_nivris(vr_chave_nivris).vlslddev
                                       ,'"CLASSIFICACAO DE RISCO DE REPASSES BNDES FINAME DEVIDO AJUSTES DO DOCUMENTO 4010 ENVIANDO AO BACEN"');

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        -- Gerar linhas de REVERSÃO
        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_dtrefere
                                       ,vr_dtmvtopr
                                       ,vr_origem
                                       ,9302
                                       ,vr_tab_finame_nivris(vr_chave_nivris).vlslddev
                                       ,'"REVERSAO DE AJUSTE DE CLASSIFICACAO DE RISCO DE REPASSES BNDES FINAME DEVIDO AJUSTES DO DOCUMENTO 4010 ENVIANDO AO BACEN"');

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

      END IF;

      vr_chave_nivris := vr_tab_finame_nivris.next(vr_chave_nivris);
    END LOOP;

    -- Fechar Arquivo
    BEGIN
      cecred.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
        -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
          vr_dscritic := 'Problema ao fechar o arquivo <'||vr_nom_diretorio||'/'||vr_nmarqfin||'>: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Copia o arquivo gerado para o diretório final convertendo para DOS
    cecred.gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqfin||' > '||vr_nom_dir_copia||'/'||vr_nmarqfin||' 2>/dev/null'
                               ,pr_typ_saida   => vr_typ_said
                               ,pr_des_saida   => vr_dscritic);
    -- Testar erro
    IF vr_typ_said = 'ERR' THEN
      vr_dscritic := 'Erro ao copiar o arquivo '||vr_nmarqfin||': '||vr_dscritic;
      RAISE vr_exc_erro;
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

  END gerarRelatorioAjusteFiname;

  PROCEDURE gerarRelatorioAjusteMicrocredito(pr_cdcooper  IN cecred.crapcop.cdcooper%TYPE
                                            ,pr_dtrefere  IN cecred.crapdat.dtmvtolt%TYPE -- data da central que será gerado o arquivo
                                            ,pr_dscritic OUT cecred.crapcri.dscritic%TYPE) IS
  /* ............................................................................

     Autor      : Darlei Zillmer
     Data       : 10/08/2023
     Dominio    : Gestão de Risco
     Subdominio : Central de risco
     Objetivo   : Gerar relatorio de ajuste de microcredito, retirado da crps280_i
     Alteracoes :

    ............................................................................ */

    ---> Variaveis <---
    vr_cdprograma VARCHAR2(100) := 'gerarRelatorioAjusteMicrocredito';
    vr_dscomple   VARCHAR2(2000);

    vr_exc_erro   EXCEPTION;
    vr_cdcritic   NUMBER;
    vr_dscritic   VARCHAR2(4000);

    vr_nmarqmic         VARCHAR2(200);
    vr_nom_diretorio    VARCHAR2(200);
    vr_nom_dir_copia    VARCHAR2(200);
    vr_chave_finalidade VARCHAR2(50);
    vr_chave_nivris     VARCHAR2(10);
    vr_input_file       UTL_FILE.file_type;             --> Handle Utl File
    vr_setlinha         VARCHAR2(400);                  --> Linhas do arquivo
    vr_typ_said         VARCHAR2(4);
    vr_contador         INTEGER;     -- Contador para a tabela de riscos
    --
    vr_destino          NUMBER;
    vr_origem           NUMBER;
    vr_descricao        VARCHAR2(400);
    --
    vr_percentu         NUMBER(5,2); --> Percentual auxiliar
    vr_vlpercen         NUMBER;      --> Valor auxiliar para calcular o atraso
    vr_vlpreatr         NUMBER;      --> Valor perstação em atraso
    vr_dsnivris         VARCHAR2(2); --> Nivel do risco atual
    v_pese_vldivida     NUMBER := 0;   -- Valor acumulado saldo devedor
    v_pese_vlaprrec     NUMBER := 0;   -- Valor acumulado apropriação de receitas
    v_pese_vlprvper     NUMBER := 0;   -- Valor acumulado provisão de perdas

    TYPE typ_reg_pese_nivris IS RECORD(vlslddev NUMBER);  -- Valor acumulado saldo devedor

    -- Definicao do tipo de tabela totalização por nível de risco de microcrédito
    TYPE typ_tab_pese_nivris IS TABLE OF typ_reg_pese_nivris INDEX BY cecred.crawepr.dsnivris%type;
    -- Vetor para armazenar a totalização por nível de risco de microcrédito
    vr_tab_pese_nivris typ_tab_pese_nivris;

    -- Definição de registro para totalização por finalidade de microcrédito
    TYPE typ_reg_miccred_fin IS
      RECORD(vllibctr    NUMBER   -- Valor acumulado liberação de contratos
            ,vlaprrec    NUMBER   -- Valor acumulado apropriação de receitas
            ,vlprvper    NUMBER   -- Valor acumulado provisão de perdas
            ,vldebpar91  NUMBER   -- Valor acumulado débito de parcelas historico 91
            ,vldebpar95  NUMBER   -- Valor acumulado débito de parcelas historico 95
            ,vldebpar441 NUMBER); -- Valor acumulado débito de parcelas historico 441

    -- Definicao do tipo de tabela totalização por finalidade de microcrédito
    TYPE typ_tab_miccred_fin IS TABLE OF typ_reg_miccred_fin INDEX BY VARCHAR2(5);
    -- Vetor para armazenar a totalização por finalidade de microcrédito
    vr_tab_miccred_fin typ_tab_miccred_fin;

    -- Definição de registro para totalização por nível de risco de microcrédito
    TYPE typ_reg_miccred_nivris IS
      RECORD(vlslddev NUMBER);  -- Valor acumulado saldo devedor

    -- Definicao do tipo de tabela totalização por nível de risco de microcrédito
    TYPE typ_tab_miccred_nivris IS TABLE OF typ_reg_miccred_nivris INDEX BY cecred.crawepr.dsnivris%type;
    -- Vetor para armazenar a totalização por nível de risco de microcrédito
    vr_tab_miccred_nivris typ_tab_miccred_nivris;

    -- Definição do tipo de registro para englobar descrições e percentuais dos riscos A, B, C, etc...
    -- Obs: Na versao antiga do programa, cada campo era um vetor, na nova, todos os campos
    --      ficam presentes num unico registro da tabela vr_tab_risco
    TYPE typ_reg_risco IS
       RECORD(dsdrisco VARCHAR2(2)   -- "x(02)"
             ,percentu NUMBER(5,2)); -- "zz9.99"

    -- Definicao do tipo de tabela de riscos
    TYPE typ_tab_risco IS TABLE OF typ_reg_risco INDEX BY PLS_INTEGER;
    -- Vetor para armazenar os dados de riscos
    vr_tab_risco typ_tab_risco;

    ---> Cursores <---
    rw_crapdat datascooperativa := datascooperativa(pr_cdcooper);

    CURSOR cr_ajuste(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                    ,pr_dtrefere IN cecred.crapdat.dtmvtolt%TYPE) IS
      SELECT (r.vldivida + nvl(j.vljura60, 0) + nvl(j.vljurantpp, 0)) vldivida
            ,0 vljura60
            ,0 vljurantpp
            ,r.nrdconta
            ,r.nrctremp
            ,r.dtinictr
            ,e.vlemprst
            ,e.vljurmes
            ,e.cdfinemp
            ,r.innivris
            ,(SELECT SUM(v.vldivida)
                FROM gestaoderisco.tbrisco_crapvri v
               WHERE v.cdcooper = r.cdcooper
                 AND v.nrdconta = r.nrdconta
                 AND v.dtrefere = r.dtrefere
                 AND v.cdmodali = r.cdmodali
                 AND v.nrctremp = r.nrctremp
                 AND v.nrseqctr = r.nrseqctr
                 AND v.cdvencto BETWEEN 110 AND 290) vltotdiv
        FROM gestaoderisco.tbrisco_crapris r
            ,cecred.crapepr e
            ,cecred.craplcr l
            ,gestaoderisco.tbrisco_juros_emprestimo j
         WHERE r.cdcooper = e.cdcooper
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
           AND e.tpemprst = 0
           AND ((e.cdfinemp IN (1,4) AND l.cdusolcr = 1) OR (e.cdfinemp IN (2,3) AND l.cdusolcr = 0))
           AND l.dsorgrec <> ' '
           AND e.inprejuz = 0;
    rw_ajuste cr_ajuste%ROWTYPE;

    -- Cursor genérico de parametrização --
    CURSOR cr_craptab(pr_cdcooper IN cecred.craptab.cdcooper%TYPE
                     ,pr_nmsistem IN cecred.craptab.nmsistem%TYPE
                     ,pr_tptabela IN cecred.craptab.tptabela%TYPE
                     ,pr_cdempres IN cecred.craptab.cdempres%TYPE
                     ,pr_cdacesso IN cecred.craptab.cdacesso%TYPE
                     ,pr_tpregist IN cecred.craptab.tpregist%TYPE) IS
      SELECT tab.dstextab
            ,tab.tpregist
        FROM cecred.craptab tab
       WHERE tab.cdcooper        = pr_cdcooper
         AND UPPER(tab.nmsistem) = pr_nmsistem
         AND UPPER(tab.tptabela) = pr_tptabela
         AND tab.cdempres        = pr_cdempres
         AND UPPER(tab.cdacesso) = pr_cdacesso
         AND tab.tpregist        >= pr_tpregist
       ORDER BY tab.progress_recid;
    rw_craptab cr_craptab%ROWTYPE;

    CURSOR cr_craplem(pr_cdcooper IN cecred.craplem.cdcooper%TYPE
                     ,pr_nrdconta IN cecred.craplem.nrdconta%TYPE
                     ,pr_nrctremp IN cecred.craplem.nrctremp%TYPE
                     ,pr_dtrefere IN cecred.crapdat.dtmvtolt%TYPE) IS
      SELECT lem.cdhistor
            ,NVL(SUM(lem.vllanmto),0) vllanmto
        FROM cecred.craplem lem
       WHERE lem.cdcooper = pr_cdcooper
         AND lem.nrdconta = pr_nrdconta
         AND lem.nrctremp = pr_nrctremp
         AND lem.dtmvtolt BETWEEN TRUNC(pr_dtrefere,'MM') AND pr_dtrefere
         AND lem.cdhistor in (91,95,441) --> Pagamentos / juros
       GROUP BY lem.cdhistor;

    CURSOR cr_pese(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                  ,pr_dtrefere IN cecred.crapdat.dtmvtolt%TYPE) IS
      SELECT (r.vldivida + nvl(j.vljura60, 0) + nvl(j.vljurantpp, 0)) vldivida
            ,e.vljurmes
            ,r.innivris
            ,0 vljura60
            ,r.nrdconta
            ,r.nrctremp
            ,r.cdmodali
            ,0 vljurantpp
            ,(SELECT SUM(v.vldivida)
                FROM gestaoderisco.tbrisco_crapvri v
               WHERE v.cdcooper = r.cdcooper
                 AND v.nrdconta = r.nrdconta
                 AND v.dtrefere = r.dtrefere
                 AND v.cdmodali = r.cdmodali
                 AND v.nrctremp = r.nrctremp
                 AND v.nrseqctr = r.nrseqctr
                 AND v.cdvencto BETWEEN 110 AND 290) vltotdiv -- ja sem o jura60
        FROM gestaoderisco.tbrisco_crapris r
            ,cecred.crapepr e
            ,cecred.craplcr l
            ,gestaoderisco.tbrisco_juros_emprestimo j
       WHERE r.cdcooper = e.cdcooper
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
         AND l.cdusolcr = 3
         AND e.inprejuz = 0;
    rw_pese cr_pese%ROWTYPE;

    ---> Subprogramas <---
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

    -- Retorna linha gerencial arquivo Radar ou Matera
    FUNCTION fn_set_gerencial(pr_cdagenci in number
                             ,pr_vlagenci in number)
    RETURN VARCHAR2 IS
    BEGIN
      RETURN lpad(pr_cdagenci,3,0) || ',' ||TRIM(TO_CHAR(pr_vlagenci,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
    END fn_set_gerencial;
  BEGIN
    vr_tab_miccred_nivris.delete;
    vr_tab_miccred_fin.delete;

    -- Nome do arquivo a ser gerado
    vr_nmarqmic := to_char(pr_dtrefere, 'yymmdd')||'_'||lpad(pr_cdcooper,2,0)||'_AJUSTE_MICROCREDITO_NOVA_CENTRAL.txt';
    vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => 'contab');
    -- Busca do diretório onde o Radar ou Matera pegará o arquivo
    vr_nom_dir_copia := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                 ,pr_cdcooper => 0
                                                 ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
    -- Tenta abrir o arquivo de log em modo gravacao
    cecred.gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                            ,pr_nmarquiv => vr_nmarqmic          --> Nome do arquivo
                            ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);        --> Erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Leitura das descricoes de risco A,B,C etc e percentuais
    FOR rw_craptab IN cr_craptab(pr_cdcooper => pr_cdcooper
                                ,pr_nmsistem => 'CRED'
                                ,pr_tptabela => 'GENERI'
                                ,pr_cdempres => 00
                                ,pr_cdacesso => 'PROVISAOCL'
                                ,pr_tpregist => 0) LOOP
      -- Para cada registro, buscar o contador atual na posição 12
      vr_contador := SUBSTR(rw_craptab.dstextab,12,2);
      -- Adicionar na tabela as informações de descrição e percentuais
      vr_tab_risco(vr_contador).dsdrisco := TRIM(SUBSTR(rw_craptab.dstextab,8,3));
      vr_tab_risco(vr_contador).percentu := SUBSTR(rw_craptab.dstextab,1,6);
    END LOOP;

    -- Alimentar variavel para nao ser preciso criar registro na PROVISAOCL
    vr_tab_risco(10).dsdrisco := 'HH';
    vr_tab_risco(10).percentu := 0;

    FOR rw_ajuste IN cr_ajuste(pr_cdcooper => pr_cdcooper
                              ,pr_dtrefere => pr_dtrefere) LOOP
      -- Garantir que a finalidade exista na PL Table
      IF NOT vr_tab_miccred_fin.exists(rw_ajuste.cdfinemp) THEN
        vr_tab_miccred_fin(rw_ajuste.cdfinemp).vllibctr    := 0;
        vr_tab_miccred_fin(rw_ajuste.cdfinemp).vlaprrec    := 0;
        vr_tab_miccred_fin(rw_ajuste.cdfinemp).vlprvper    := 0;
        vr_tab_miccred_fin(rw_ajuste.cdfinemp).vldebpar91  := 0;
        vr_tab_miccred_fin(rw_ajuste.cdfinemp).vldebpar95  := 0;
        vr_tab_miccred_fin(rw_ajuste.cdfinemp).vldebpar441 := 0;
      END IF;
      --Apenas contratos liberados no mês
      IF rw_ajuste.dtinictr BETWEEN TRUNC(pr_dtrefere,'mm') AND pr_dtrefere THEN
        vr_tab_miccred_fin(rw_ajuste.cdfinemp).vllibctr := vr_tab_miccred_fin(rw_ajuste.cdfinemp).vllibctr + rw_ajuste.vlemprst;
      END IF;

      -- Guardar percentual
      vr_percentu := vr_tab_risco(rw_ajuste.innivris).percentu;
      -- Calcular o percentual para o atraso com base nos percentuais da tabela
      vr_vlpercen := vr_percentu / 100;

      -- Calcular o valor de prestação em atraso
      vr_vlpreatr := ROUND( (rw_ajuste.vltotdiv - rw_ajuste.vljura60
                                                - nvl(rw_ajuste.vljurantpp, 0) -- PRJ577 -- O cálculo da provisão deve considerar o Valor do Juros+60 Anterior
                            ) * vr_vlpercen ,2);

      vr_tab_miccred_fin(rw_ajuste.cdfinemp).vlaprrec := vr_tab_miccred_fin(rw_ajuste.cdfinemp).vlaprrec + rw_ajuste.vljurmes;
      vr_tab_miccred_fin(rw_ajuste.cdfinemp).vlprvper := vr_tab_miccred_fin(rw_ajuste.cdfinemp).vlprvper + vr_vlpreatr;

      -- Busca valor de parcelas pagas
      FOR rw_craplem in cr_craplem(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => rw_ajuste.nrdconta
                                  ,pr_nrctremp => rw_ajuste.nrctremp
                                  ,pr_dtrefere => pr_dtrefere) LOOP
        IF rw_craplem.cdhistor = 91 then
          vr_tab_miccred_fin(rw_ajuste.cdfinemp).vldebpar91 := vr_tab_miccred_fin(rw_ajuste.cdfinemp).vldebpar91 + rw_craplem.vllanmto;
        ELSIF rw_craplem.cdhistor = 95 then
          vr_tab_miccred_fin(rw_ajuste.cdfinemp).vldebpar95 := vr_tab_miccred_fin(rw_ajuste.cdfinemp).vldebpar95 + rw_craplem.vllanmto;
        ELSE
          vr_tab_miccred_fin(rw_ajuste.cdfinemp).vldebpar441 := vr_tab_miccred_fin(rw_ajuste.cdfinemp).vldebpar441 + rw_craplem.vllanmto;
        END IF;
      END LOOP;

      vr_dsnivris := vr_tab_risco(rw_ajuste.innivris).dsdrisco;
      --Agupar valores microcrédito das filiadas por nível de risco
      IF rw_ajuste.cdfinemp IN (1,4) THEN
        IF vr_tab_miccred_nivris.exists(vr_dsnivris) THEN
          vr_tab_miccred_nivris(vr_dsnivris).vlslddev := vr_tab_miccred_nivris(vr_dsnivris).vlslddev + rw_ajuste.vldivida;
        ELSE
          vr_tab_miccred_nivris(vr_dsnivris).vlslddev := rw_ajuste.vldivida;
        END IF;
      END IF;
    END LOOP;

    FOR rw_pese IN cr_pese(pr_cdcooper => pr_cdcooper
                          ,pr_dtrefere => pr_dtrefere) LOOP
      -- Guardar percentual
      vr_percentu := vr_tab_risco(rw_pese.innivris).percentu;
      -- Calcular o percentual para o atraso com base nos percentuais da tabela
      vr_vlpercen := vr_percentu / 100;

      -- Calcular o valor de prestação em atraso
      vr_vlpreatr := ROUND( (rw_pese.vltotdiv - rw_pese.vljura60
                                                - nvl(rw_pese.vljurantpp, 0) -- PRJ577 -- O cálculo da provisão deve considerar o Valor do Juros+60 Anterior
                            ) * vr_vlpercen ,2);

      GESTAODERISCO.calcularProvisaoRiscoAtual(pr_cdcooper => pr_cdcooper,
                                               pr_nrdconta => rw_pese.nrdconta,
                                               pr_nrctremp => rw_pese.nrctremp,
                                               pr_cdmodali => rw_pese.cdmodali,
                                               pr_vlpreatr => vr_vlpreatr,
                                               pr_dscritic => vr_dscritic);

      v_pese_vldivida := v_pese_vldivida + rw_pese.vldivida;
      v_pese_vlaprrec := v_pese_vlaprrec + rw_pese.vljurmes;
      v_pese_vlprvper := v_pese_vlprvper + vr_vlpreatr;

      vr_dsnivris := vr_tab_risco(rw_pese.innivris).dsdrisco;
      --Agupar valores microcrédito das filiadas por nível de risco
      IF vr_tab_pese_nivris.exists(vr_dsnivris) THEN
        vr_tab_pese_nivris(vr_dsnivris).vlslddev := vr_tab_pese_nivris(vr_dsnivris).vlslddev + rw_pese.vldivida;
      ELSE
        vr_tab_pese_nivris(vr_dsnivris).vlslddev := rw_pese.vldivida;
      END IF;

    END LOOP;

    vr_chave_finalidade := vr_tab_miccred_fin.first;
    LOOP
      EXIT WHEN vr_chave_finalidade IS NULL;

      --Gera no arquivo linhas referente a valor de liberação de contrato
      IF vr_tab_miccred_fin(vr_chave_finalidade).vllibctr > 0 THEN

        IF vr_chave_finalidade = 1 THEN
          vr_origem := 1437;
          vr_descricao := '"AJUSTE CONTABIL REF. LIBERACAO DE RECURSO MICROCREDITO CEF"';
        ELSIF vr_chave_finalidade = 2 THEN
          vr_origem := 1780;
          vr_descricao := '"AJUSTE CONTABIL REF. LIBERACAO DE RECURSO CCB IMOBILIZADO REFAP"';
        ELSIF vr_chave_finalidade = 3 THEN
          vr_origem := 1621;
          vr_descricao := '"AJUSTE CONTABIL REF. LIBERACAO DE RECURSO CCB MAIS CREDITO"';
        ELSIF vr_chave_finalidade = 4 THEN
          vr_origem := 1440;
          vr_descricao := '"AJUSTE CONTABIL REF. LIBERACAO DE RECURSO MICROCREDITO BNDES"';
        END IF;

        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_dtrefere
                                       ,pr_dtrefere
                                       ,vr_origem
                                       ,1662
                                       ,vr_tab_miccred_fin(vr_chave_finalidade).vllibctr
                                       ,vr_descricao);

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        IF vr_chave_finalidade IN (1,4) THEN
          vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vllibctr);
        ELSE
          vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vllibctr);
        END IF;

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita
      END IF;

      --Gera no arquivo linhas referente a valor de apropriação de contrato
      IF vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec > 0 THEN
        IF vr_chave_finalidade = 1 THEN
          vr_origem := 1437;
          vr_destino := 7302;
          vr_descricao := '"AJUSTE CONTABIL REF. JUROS MICROCREDITO CEF"';
        ELSIF vr_chave_finalidade = 2 THEN
          vr_origem := 1780;
          vr_destino := 7112;
          vr_descricao := '"AJUSTE CONTABIL - JUROS CCB IMOBILIZADO REFAP (INVESTIMENTOS)"';
        ELSIF vr_chave_finalidade = 3 THEN
          vr_origem := 1621;
          vr_destino := 7116;
          vr_descricao := '"AJUSTE CONTABIL - JUROS CCB MAIS CREDITO"';
        ELSIF vr_chave_finalidade = 4 THEN
          vr_origem := 1440;
          vr_destino := 7306;
          vr_descricao := '"AJUSTE CONTABIL REF. JUROS MICROCREDITO BNDES"';
        END IF;

        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_dtrefere
                                       ,pr_dtrefere
                                       ,vr_origem
                                       ,1662
                                       ,vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec
                                       ,vr_descricao);

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        IF vr_chave_finalidade IN (1,4) THEN
          vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec);
        ELSE
          vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec);
        END IF;

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        --Escreve novamente as linhas para outra conta de débito e crédito
        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_dtrefere
                                       ,pr_dtrefere
                                       ,7141
                                       ,vr_destino
                                       ,vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec
                                       ,vr_descricao);

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        IF vr_chave_finalidade IN (1,4) THEN
          vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec);
        ELSE
          vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec);
        END IF;

        --Escreve duas vezes a linha gerencial
        FOR i IN 1..2 LOOP
          cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
        END LOOP;
      END IF;

      --Gera no arquivo linhas referente a valor de provisão de contrato
      IF vr_tab_miccred_fin(vr_chave_finalidade).vlprvper > 0 THEN
        IF vr_chave_finalidade = 1 THEN
          --para provisão
          vr_destino := 1438;
          --para reversao
          vr_origem := 1438;
          vr_descricao := '"AJUSTE CONTABIL - PROVISAO CEF"';
        ELSIF vr_chave_finalidade = 2 THEN
          --para provisão
          vr_destino := 1702;
          --para reversao
          vr_origem  := 1702;
          vr_descricao := '"AJUSTE CONTABIL - PROVISAO CCB IMOBILIZADO REFAP"';
        ELSIF vr_chave_finalidade = 4 THEN
          --para provisão
          vr_destino := 1441;
          --para reversao
          vr_origem  := 1441;
          vr_descricao := '"AJUSTE CONTABIL - PROVISAO BNDES"';
        END IF;

        --Cria linhas de provisão
        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_dtrefere
                                       ,pr_dtrefere
                                       ,1731
                                       ,vr_destino
                                       ,vr_tab_miccred_fin(vr_chave_finalidade).vlprvper
                                       ,vr_descricao);

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        IF vr_chave_finalidade IN (1,4) THEN
          vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vlprvper);
        ELSE
          vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vlprvper);
        END IF;

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        --Cria linhas de reversão
        vr_setlinha := fn_set_cabecalho('20'
                                        ,vr_dtmvtopr
                                        ,vr_dtmvtopr
                                        ,vr_origem
                                        ,1731
                                        ,vr_tab_miccred_fin(vr_chave_finalidade).vlprvper
                                        ,replace(vr_descricao,'PROVISAO','REVERSAO'));

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        IF vr_chave_finalidade IN (1,4) THEN
          vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vlprvper);
        ELSE
          vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vlprvper);
        END IF;

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

      END IF;

      -- Gera no arquivo linhas referente a valor de pagamento de parcelas de contrato
      IF vr_tab_miccred_fin(vr_chave_finalidade).vldebpar91 > 0 THEN

        IF vr_chave_finalidade = 1 THEN
          vr_destino := 1437;
          vr_descricao := '"AJUSTE CONTABIL - PAGTO. JUROS MICROCREDITO CEF"';
        ELSIF vr_chave_finalidade = 2 THEN
          vr_destino := 1780;
          vr_descricao := '"AJUSTE CONTABIL - PAGTO. JUROS CCB IMOBILIZADO REFAP"';
        ELSIF vr_chave_finalidade = 3 THEN
          vr_destino := 1621;
          vr_descricao := '"AJUSTE CONTABIL - PAGTO. JUROS CCB MAIS CREDITO"';
        ELSIF vr_chave_finalidade = 4 THEN
          vr_destino := 1440;
          vr_descricao := '"AJUSTE CONTABIL - PAGTO. JUROS MICROCREDITO BNDES"';
        END IF;

        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_dtrefere
                                       ,pr_dtrefere
                                       ,1662
                                       ,vr_destino
                                       ,vr_tab_miccred_fin(vr_chave_finalidade).vldebpar91
                                       ,vr_descricao);

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        IF vr_chave_finalidade IN (1,4) THEN
          vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar91);
        ELSE
          vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar91);
        END IF;

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita
      END IF;

      -- Gera no arquivo linhas referente a valor de pagamento de parcelas de contrato
      IF vr_tab_miccred_fin(vr_chave_finalidade).vldebpar95 > 0 THEN

        IF vr_chave_finalidade = 1 THEN
          vr_destino := 1437;
          vr_descricao := '"AJUSTE CONTABIL - PAGTO. MENSAL MICROCREDITO CEF"';
        ELSIF vr_chave_finalidade = 2 THEN
          vr_destino := 1780;
          vr_descricao := '"AJUSTE CONTABIL - PAGTO. MENSAL CCB IMOBILIZADO REFAP"';
        ELSIF vr_chave_finalidade = 3 THEN
          vr_destino := 1621;
          vr_descricao := '"AJUSTE CONTABIL - PAGTO. MENSAL CCB MAIS CREDITO"';
        ELSIF vr_chave_finalidade = 4 THEN
          vr_destino := 1440;
          vr_descricao := '"AJUSTE CONTABIL - PAGTO. MENSAL MICROCREDITO BNDES"';
        END IF;

        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_dtrefere
                                       ,pr_dtrefere
                                       ,1662
                                       ,vr_destino
                                       ,vr_tab_miccred_fin(vr_chave_finalidade).vldebpar95
                                       ,vr_descricao);

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        IF vr_chave_finalidade IN (1,4) THEN
          vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar95);
        ELSE
          vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar95);
        END IF;

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita
      END IF;

      -- Gera no arquivo linhas referente a valor de pagamento de parcelas de contrato
      IF vr_tab_miccred_fin(vr_chave_finalidade).vldebpar441 > 0 THEN

        IF vr_chave_finalidade = 1 THEN
          vr_origem  := 7306;
          vr_destino := 7302;
          vr_descricao := '(AJUSTE DE SALDO - MICROCREDITO CEF - AJUSTE CONTABIL)"';
        ELSIF vr_chave_finalidade = 2 THEN
          vr_origem  := 7306;
          vr_destino := 7112;
          vr_descricao := '(AJUSTE DE SALDO - CCB IMOBILIZADO REFAP - AJUSTE CONTABIL)"';
        ELSIF vr_chave_finalidade = 3 THEN
          vr_origem  := 7306;
          vr_destino := 7116;
          vr_descricao := '(AJUSTE DE SALDO - CCB MAIS CREDITO - AJUSTE CONTABIL)"';
        ELSIF vr_chave_finalidade = 4 THEN
          vr_origem  := 1440;
          vr_destino := 1662;
          vr_descricao := '(AJUSTE DE SALDO - MICROCREDITO BNDES - AJUSTE CONTABIL)"';
        END IF;

        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_dtrefere
                                       ,pr_dtrefere
                                       ,vr_origem
                                       ,vr_destino
                                       ,vr_tab_miccred_fin(vr_chave_finalidade).vldebpar441
                                       ,'"EMPRESTIMOS EFETUADOS PARA ASSOCIADOS - (0441) JUROS SOBRE EMPRESTIMOS ' || vr_descricao);

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        IF vr_chave_finalidade IN (1,4) THEN
          vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar441);
        ELSE
          vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar441);
        END IF;

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita
      END IF;

      vr_chave_finalidade := vr_tab_miccred_fin.next(vr_chave_finalidade);

    END LOOP;

    vr_chave_nivris := vr_tab_miccred_nivris.first;
    LOOP
      EXIT WHEN vr_chave_nivris IS NULL;
      --Gera no arquivo linhas referente a valor de liberação de contrato
      IF vr_tab_miccred_nivris(vr_chave_nivris).vlslddev > 0 THEN
        IF vr_chave_nivris IN ('A','AA') THEN
          vr_destino := 3321;  --provisão
          vr_origem  := 3321;  --reversão
        ELSIF vr_chave_nivris = 'B' THEN
          vr_destino := 3332; --provisão
          vr_origem  := 3332; --reversão
        ELSIF vr_chave_nivris = 'C' THEN
          vr_destino := 3342; --provisão
          vr_origem  := 3342; --reversão
        ELSIF vr_chave_nivris = 'D' THEN
          vr_destino := 3352; --provisão
          vr_origem  := 3352; --reversão
        ELSIF vr_chave_nivris = 'E' THEN
          vr_destino := 3362; --provisão
          vr_origem  := 3362; --reversão
        ELSIF vr_chave_nivris = 'F' THEN
          vr_destino := 3372; --provisão
          vr_origem  := 3372; --reversão
        ELSIF vr_chave_nivris = 'G' THEN
          vr_destino := 3382; --provisão
          vr_origem  := 3382; --reversão
        ELSIF vr_chave_nivris IN ('H','HH') THEN
          vr_destino := 3392; --provisão
          vr_origem  := 3392; --reversão
        END IF;

        --Gerar linhas de PROVISÃO
        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_dtrefere
                                       ,pr_dtrefere
                                       ,9302
                                       ,vr_destino
                                       ,vr_tab_miccred_nivris(vr_chave_nivris).vlslddev
                                       ,'"CLASSIFICACAO DE RISCO DE REPASSES CEF E BNDES DEVIDO AJUSTES DO DOCUMENTO 4010 ENVIANDO AO BACEN"');

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        --Gerar linhas de REVERSÃO
        vr_setlinha := fn_set_cabecalho('20'
                                       ,vr_dtmvtopr
                                       ,vr_dtmvtopr
                                       ,vr_origem
                                       ,9302
                                       ,vr_tab_miccred_nivris(vr_chave_nivris).vlslddev
                                       ,'"REVERSAO DE AJUSTE DE CLASSIFICACAO DE RISCO DE REPASSES CEF E BNDES DEVIDO AJUSTES DO DOCUMENTO 4010 ENVIANDO AO BACEN"');

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

      END IF;

      vr_chave_nivris := vr_tab_miccred_nivris.next(vr_chave_nivris);
    END LOOP;

    /* PROGRAMA PESE BNDES */
    IF v_pese_vldivida > 0 THEN
      vr_origem    := 1444;
      vr_destino   := 1667;
      vr_descricao := '"RECLASSIFICACAO CONTABIL REF. REPASSE BNDES PESE"';

      vr_setlinha := fn_set_cabecalho('20'
                                     ,pr_dtrefere
                                     ,pr_dtrefere
                                     ,vr_origem
                                     ,vr_destino
                                     ,v_pese_vldivida
                                     ,vr_descricao);

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto para escrita

      vr_setlinha := fn_set_gerencial('999',v_pese_vldivida);

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

      --Cria linha de reversao
      vr_descricao := '"REVERSAO RECLASSIFICACAO CONTABIL REF. REPASSE BNDES PESE"';

      vr_setlinha := fn_set_cabecalho('20'
                                     ,vr_dtmvtopr
                                     ,vr_dtmvtopr
                                     ,vr_destino
                                     ,vr_origem
                                     ,v_pese_vldivida
                                     ,vr_descricao);

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto para escrita

      vr_setlinha := fn_set_gerencial('999',v_pese_vldivida);

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita
    END IF;

    --Gera no arquivo linhas referente a valor de provisão de contrato
    IF v_pese_vlprvper > 0 THEN
      vr_origem    := 1733;
      vr_destino   := 1446;
      vr_descricao := '"RECLASSIFICACAO CONTABIL REF. REPASSE BNDES PESE"';

      --Cria linhas de provisão
      vr_setlinha := fn_set_cabecalho('20'
                                     ,pr_dtrefere
                                     ,pr_dtrefere
                                     ,vr_origem
                                     ,vr_destino
                                     ,v_pese_vlprvper
                                     ,vr_descricao);

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto para escrita

      vr_setlinha := fn_set_gerencial('999',v_pese_vlprvper);

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto para escrita

      --Cria linhas de reversão
      vr_setlinha := fn_set_cabecalho('20'
                                     ,vr_dtmvtopr
                                     ,vr_dtmvtopr
                                     ,vr_destino
                                     ,vr_origem
                                     ,v_pese_vlprvper
                                     ,replace(vr_descricao,'RECLASSIFICACAO','REVERSAO RECLASSIFICACAO'));

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto para escrita

      vr_setlinha := fn_set_gerencial('999',v_pese_vlprvper);

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita
    END IF;

    --Gera no arquivo linhas referente a valor de apropriação de contrato
    IF v_pese_vlaprrec > 0 THEN
      vr_origem    := 7135;
      vr_destino   := 7289;
      vr_descricao := '"RECLASSIFICACAO CONTABIL REF. RENDAS SOBRE REPASSE BNDES PESE"';

      vr_setlinha := fn_set_cabecalho('20'
                                     ,pr_dtrefere
                                     ,pr_dtrefere
                                     ,vr_origem
                                     ,vr_destino
                                     ,v_pese_vlaprrec
                                     ,vr_descricao);

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto para escrita

      vr_setlinha := fn_set_gerencial('999',v_pese_vlaprrec);

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto para escrita

      --Criar segundo linha pois ambas as contas possuem rateio por gerencial
      vr_setlinha := fn_set_gerencial('999',v_pese_vlaprrec);

      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto para escrita
    END IF;

    vr_chave_nivris := vr_tab_pese_nivris.first;
    LOOP
      EXIT WHEN vr_chave_nivris IS NULL;

      --Gera no arquivo linhas referente a valor de liberação de contrato
      IF vr_tab_pese_nivris(vr_chave_nivris).vlslddev > 0 THEN
        IF vr_chave_nivris IN ('A','AA') THEN
          vr_destino := 3321;  --provisão
          vr_origem  := 3321;  --reversão
        ELSIF vr_chave_nivris = 'B' THEN
          vr_destino := 3332; --provisão
          vr_origem  := 3332; --reversão
        ELSIF vr_chave_nivris = 'C' THEN
          vr_destino := 3342; --provisão
          vr_origem  := 3342; --reversão
        ELSIF vr_chave_nivris = 'D' THEN
          vr_destino := 3352; --provisão
          vr_origem  := 3352; --reversão
        ELSIF vr_chave_nivris = 'E' THEN
          vr_destino := 3362; --provisão
          vr_origem  := 3362; --reversão
        ELSIF vr_chave_nivris = 'F' THEN
          vr_destino := 3372; --provisão
          vr_origem  := 3372; --reversão
        ELSIF vr_chave_nivris = 'G' THEN
          vr_destino := 3382; --provisão
          vr_origem  := 3382; --reversão
        ELSIF vr_chave_nivris IN ('H','HH') THEN
          vr_destino := 3392; --provisão
          vr_origem  := 3392; --reversão
        END IF;

        --Gerar linhas de PROVISÃO
        vr_setlinha := fn_set_cabecalho('20'
                                       ,pr_dtrefere
                                       ,pr_dtrefere
                                       ,9302
                                       ,vr_destino
                                       ,vr_tab_pese_nivris(vr_chave_nivris).vlslddev
                                       ,'"RECLASSIFICACAO CONTABIL REF. REPASSE BNDES PESE"');

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita

        --Gerar linhas de REVERSÃO
        vr_setlinha := fn_set_cabecalho('20'
                                       ,vr_dtmvtopr
                                       ,vr_dtmvtopr
                                       ,vr_origem
                                       ,9302
                                       ,vr_tab_pese_nivris(vr_chave_nivris).vlslddev
                                       ,'"REVERSAO RECLASSIFICACAO CONTABIL REF. REPASSE BNDES PESE"');

        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto para escrita
      END IF;

      vr_chave_nivris := vr_tab_pese_nivris.next(vr_chave_nivris);
    END LOOP;

    BEGIN
      cecred.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception;

         vr_dscritic := 'Problema ao fechar o arquivo <'||vr_nom_diretorio||'/'||vr_nmarqmic||'>: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;

    cecred.gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqmic||' > '||vr_nom_dir_copia||'/'||vr_nmarqmic||' 2>/dev/null'
                               ,pr_typ_saida   => vr_typ_said
                               ,pr_des_saida   => vr_dscritic);
    -- Testar erro
    IF vr_typ_said = 'ERR' THEN
      vr_dscritic := 'Erro ao copiar o arquivo '||vr_nmarqmic||': '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    vr_tab_miccred_nivris.delete;
    vr_tab_miccred_fin.delete;

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN

      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN

        vr_dscritic := obterCritica(vr_cdcritic);
      END IF;

      pr_dscritic := vr_dscritic ||': '||vr_dscomple;

      sistema.excecaoInterna(pr_cdcooper => pr_cdcooper
                            ,pr_compleme => vr_dscomple || pr_dscritic);

    WHEN OTHERS THEN

      pr_dscritic := 'Erro na : ' || vr_cdprograma || ': ' || SQLERRM;

      sistema.excecaoInterna(pr_cdcooper => pr_cdcooper
                            ,pr_compleme => vr_dscomple || pr_dscritic);

      sistema.Gravarlogprograma(pr_cdcooper      => pr_cdcooper
                               ,pr_ind_tipo_log  => 3 
                               ,pr_des_log       => pr_dscritic
                               ,pr_cdprograma    => vr_cdprograma
                               ,pr_tpexecucao    => 1);

  END gerarRelatorioAjusteMicrocredito;

  
begin
  

  GESTAODERISCO.obterCalendario(pr_cdcooper   => 3
                               ,pr_dtrefere   => vr_dtrefere
                               ,pr_rw_crapdat => rw_crapdat
                               ,pr_cdcritic   => vr_cdcritic
                               ,pr_dscritic   => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  vr_dtmvtolt := rw_crapdat.dtmvtoan;

  vr_dtmvtopr := rw_crapdat.dtmvtolt;

  vr_dtultdia := last_day(vr_dtmvtolt);
  vr_dtultdia_prxmes := last_day(vr_dtmvtopr);

  gerarRelatorioAjusteFiname(pr_cdcooper => 3
                            ,pr_dtrefere => vr_dtultdia
                            ,pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  gerarRelatorioAjusteMicrocredito(pr_cdcooper => 3
                                  ,pr_dtrefere => vr_dtultdia
                                  ,pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  COMMIT;
  
  
EXCEPTION 
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20000, vr_dscritic);
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
END;
