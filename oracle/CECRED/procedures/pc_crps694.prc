CREATE OR REPLACE PROCEDURE CECRED.pc_crps694(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                      ,pr_flgresta IN PLS_INTEGER --> Flag padr?o para utilizac?o de restart
                                      ,pr_stprogra OUT PLS_INTEGER --> Saida de termino da execuc?o
                                      ,pr_infimsol OUT PLS_INTEGER --> Saida de termino da solicitac?o
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS --> Texto de erro/critica encontrada
BEGIN
  /* ............................................................................

    Programa: pc_crps694
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Daniel Zimmermann
    Data    : Abril/2015                      Ultima atualizacao: 04/12/2015

    Dados referentes ao programa:

    Frequencia: Diario.
    Objetivo  : Responsavel por processar arquivo retorno PG.
                Gera relatorio crrl701

    Alteracoes:

    22/07/2015 - Ajuste no motivo de bloqueio dos boletos impressos da PG. (Rafael)
    
    28/07/2015 - Ajuste no indice da varivavel vr_tab_relatorio. (Rafael)    

    04/12/2015 - Utilizado funcao para retirar acento do "Motivo devolucao" e
                 "Motivo bloqueio" do relatorio 701 pois estava ocorrendo
                 erro com esses caracteres especiais (Tiago/Rodrigo SD368657).
  .......................................................................... */

  DECLARE
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Codigo do Programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS694';

    -- Tratamento de Erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_exc_next   EXCEPTION;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Declarando handle do Arquivo
    vr_ind_arquivo utl_file.file_type;
    vr_des_erro VARCHAR2(4000);

    -- Variaveis para armazenar as informações em XML
    vr_des_xml       CLOB;

    -- Variavel para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);

    -- Variaveis Diversas
    vr_ultimo_retorno NUMBER;
    vr_nmarquiv VARCHAR(100);
    vr_nrsequen NUMBER;
    vr_nmdireto VARCHAR2(4000);
    vr_nmdirrel VARCHAR2(4000);
    vr_nmdirslv VARCHAR2(4000);
    vr_dscorpo  VARCHAR2(4000);
    vr_des_destino VARCHAR2(4000);
    vr_dsmensag VARCHAR2(100);
    vr_nmarqimp VARCHAR2(400) := 'crrl701';

    vr_nrremret NUMBER;

    vr_cdocorre NUMBER;
    vr_cdmotivo VARCHAR2(10);

    vr_cdcooper NUMBER;

    vr_des_linha VARCHAR2(1000);

    vr_rowidcce ROWID;
    vr_rowidcob ROWID;


    vr_indice PLS_INTEGER;
    vr_indice_2 PLS_INTEGER := 0;
    vr_indice_arq PLS_INTEGER := 0;
    vr_indice_rel VARCHAR(40);

    vr_nrodojob INTEGER;
    vr_nrdscore NUMBER;

    vr_flgemail BOOLEAN;
    vr_flg_gera_rel BOOLEAN;

    vr_dsbloque VARCHAR2(1000);
    vr_dsdevolu VARCHAR2(1000);
    vr_dsdscore VARCHAR2(1000);
    vr_inpostag NUMBER;
    vr_dtemiexp crapcob.dtemiexp%TYPE;

    vr_inemiexp NUMBER;

    -- Tabela de String
    vr_tab_string        gene0002.typ_split;

    -- Tabela temporaria para os convenios
    TYPE typ_reg_crapcco IS
     RECORD(cdcooper crapcco.cdcooper%TYPE
           ,nrconven crapcco.nrconven%TYPE);
    TYPE typ_tab_crapcco IS
      TABLE OF typ_reg_crapcco
        INDEX BY PLS_INTEGER;
    -- Vetor para armazenar os convenios
    vr_tab_crapcco typ_tab_crapcco;

    -- Tabela temporaria para os titulos
    TYPE typ_reg_arquivo IS
     RECORD(cdcooper crapcob.cdcooper%TYPE
           ,nrodojob INTEGER
           ,nrcnvcob crapcob.nrcnvcob%TYPE
           ,nrnosnum crapcob.nrnosnum%TYPE
           ,nrdconta crapcob.nrdconta%TYPE
           ,nrdocmto crapcob.nrdocmto%TYPE
           ,nmarquiv VARCHAR2(200)
           ,nrdscore INTEGER
           ,dsdevolu VARCHAR(100)
           ,dsbloque VARCHAR(100)
           ,inpostag INTEGER);
    TYPE typ_tab_arquivo IS
      TABLE OF typ_reg_arquivo
        INDEX BY PLS_INTEGER;
    TYPE typ_tab_coop IS
      TABLE OF typ_tab_arquivo
        INDEX BY PLS_INTEGER;
    -- Vetor para armazenar os titulos
    vr_tab_arquivo typ_tab_coop;

    -- Tabela temporaria para o relatorio
    TYPE typ_reg_relatorio IS
     RECORD(cdcooper crapcob.cdcooper%TYPE
           ,nrnosnum crapcob.nrnosnum%TYPE
           ,nrcnvcob crapcob.nrcnvcob%TYPE
           ,nrdconta crapcob.nrdconta%TYPE
           ,cdagenci crapass.cdagenci%TYPE
           ,vltitulo crapcob.vltitulo%TYPE
           ,nrodojob INTEGER
           ,nrdscore INTEGER
           ,dsdevolu VARCHAR(100)
           ,dsbloque VARCHAR(100)
           ,inpostag VARCHAR(1));
    TYPE typ_tab_relatorio IS
      TABLE OF typ_reg_relatorio
        INDEX BY VARCHAR2(40);
    -- Vetor para armazenar os os titulos
    vr_tab_relatorio typ_tab_relatorio;

    -- PL/TABLE titulos não encontrados
    TYPE typ_reg_crapcob IS
     RECORD(cdcooper crapcob.cdcooper%TYPE
           ,nmarquiv VARCHAR2(200)
           ,nrcnvcob crapcob.nrcnvcob%TYPE
           ,nrnosnum crapcob.nrnosnum%TYPE
           ,nrdconta crapcob.nrdconta%TYPE
           ,nrdocmto crapcob.nrdocmto%TYPE);
    TYPE typ_tab_crapcob IS
      TABLE OF typ_reg_crapcob
        INDEX BY PLS_INTEGER;
    -- Vetor para armazenar os os titulos
    vr_tab_crapcob typ_tab_crapcob;



    ------------------------------- CURSORES ---------------------------------

    -- Busca Dados das Cooperativa (Cecred)
    CURSOR cr_crabcop IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.nmextcop,
             cop.dsdircop,
             cop.nrdocnpj,
             cop.dsnomscr,
             cop.dstelscr,
             cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;

    rw_crabcop cr_crabcop%ROWTYPE;

    -- Busca Dados das Cooperativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.nmextcop,
             cop.dsdircop,
             cop.nrdocnpj,
             cop.dsnomscr,
             cop.dstelscr,
             cop.cdagectl,
             cop.cdbcoctl
        FROM crapcop cop
       WHERE cop.cdcooper <> 3
         AND cop.flgativo = 1;

    -- Busca Dados das Cooperativas
    CURSOR cr_crapcco IS
      SELECT cco.cdcooper,
             cco.nrconven
        FROM crapcco cco
       WHERE cco.cddbanco = 085
         AND cco.dsorgarq NOT IN ('MIGRACAO','INCORPORACAO');

    -- Busca Nunero Remessa/Retorno
    CURSOR cr_crapcce(pr_cdcooper IN crapcee.cdcooper%TYPE) IS
      SELECT NVL(MAX(cee.nrremret),0) + 1 max_nrremret
        FROM crapcee cee
       WHERE cee.cdcooper = pr_cdcooper
         AND cee.intipmvt = 2; -- Retorno
    rw_crapcee cr_crapcce%ROWTYPE;

    -- Busca Registros Cobranca
    CURSOR cr_crapcob(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrcnvcob IN crapcob.nrcnvcob%TYPE,
                      pr_nrdconta IN crapcob.nrdconta%TYPE,
                      pr_nrdocmto IN crapcob.nrdocmto%TYPE) IS
      SELECT cob.cdcooper
            ,cob.rowid
            ,cob.nrdocmto
            ,cob.nrdconta
            ,cob.nrcnvcob
            ,cob.nrnosnum
            ,cob.vltitulo
            ,ass.cdagenci
        FROM crapcob cob,
             crapcco cco,
             crapass ass
       WHERE cob.cdcooper = pr_cdcooper
         AND cob.cdbandoc = cco.cddbanco
         AND cob.nrdctabb = cco.nrdctabb
         AND cob.nrcnvcob = pr_nrcnvcob
         AND cob.nrdconta = pr_nrdconta
         AND cob.nrdocmto = pr_nrdocmto
         AND cco.cdcooper = cob.cdcooper
         AND cco.nrconven = cob.nrcnvcob
         AND ass.cdcooper = cob.cdcooper
         AND ass.nrdconta = cob.nrdconta;
    rw_crapcob cr_crapcob%ROWTYPE;

    -- Cursor Generico de Calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    rw_crabdat btch0001.cr_crapdat%ROWTYPE;

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variavel CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS

    BEGIN
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir Nome do Modulo Logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crabcop;
    FETCH cr_crabcop INTO rw_crabcop;
    -- Se não encontrar
    IF cr_crabcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crabcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crabcop;
    END IF;

    -- Leitura do calendario da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crabcop.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crabdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    -- Validac?es Iniciais do Programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => 3
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Caso tenha Erro
    IF vr_cdcritic <> 0 THEN
      -- Envio Centralizado de LOG de Erro
      RAISE vr_exc_saida;
    END IF;

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

    -- Nome do Relatorio
    vr_nmarqimp  := 'crrl701.lst';

    -- buscar emails de destino
    vr_des_destino := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdcooper => 3, /* cecred */
                                                pr_cdacesso => 'CRPS694_EMAIL');

    -- Chamada Rotina que efetua busca arquivo. 
    COBR0004.pc_download_webservice_pg(rw_crabdat.dtmvtoan -- Data de abertura do Job - Inicial
                                      ,rw_crabdat.dtmvtolt -- Data de abertura do Job - Final
                                      ,vr_nmarquiv -- Nome do arquivo baixado do webservice
                                      ,vr_dscritic);
                                      
    --vr_nmarquiv := 'PG2.ret'; usado pra testes
    --vr_dscritic := '';                                      
   
    IF TRIM(vr_nmarquiv) IS NULL THEN
      RAISE vr_exc_fimprg;
    END IF;

    -- Efetua Carga dos Convenios
    FOR rw_crapcco IN cr_crapcco LOOP
      vr_tab_crapcco(rw_crapcco.nrconven).cdcooper := rw_crapcco.cdcooper;
    END LOOP;

    -- Diretorio Salvar
    vr_nmdirslv := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                         pr_cdcooper => 3, /* cecred */
                                         pr_nmsubdir => 'salvar');


    -- Define o diretorio do arquivo
    vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => 3 /* cecred */
                                        ,pr_nmsubdir => 'arq') ;



    -- Abrir Arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto            --> Diretorio do arquivo
                            ,pr_nmarquiv => vr_nmarquiv            --> Nome do arquivo
                            ,pr_tipabert => 'R'                    --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_ind_arquivo         --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro);          --> Erro
    IF vr_des_erro IS NOT NULL THEN
      vr_dscritic := vr_des_erro;
      --Levantar Excecao
      RAISE vr_exc_saida;
    END IF;

    -- Se o arquivo estiver aberto
    IF  utl_file.IS_OPEN(vr_ind_arquivo) THEN

      -- Percorrer as linhas do arquivo
      BEGIN
        LOOP

          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquivo
                                      ,pr_des_text => vr_des_linha);

          -- Quebrar Informacoes da String e colocar no vetor
          vr_des_linha := REPLACE(vr_des_linha,chr(13),'');          
          vr_tab_string := gene0002.fn_quebra_string(vr_des_linha,';');

          vr_indice := to_number(replace(vr_tab_string(3),'"',''));

          -- JOB;Contratante;Convenio;Nosso Numero;CPFCNPJ;Endereco;Bairro;Cidade;UF;CEP;Score;Motivo Devolucao;Motivo Bloqueio;Postagem
          IF vr_tab_crapcco.EXISTS(vr_indice) THEN

            vr_cdcooper := vr_tab_crapcco(vr_indice).cdcooper;

            vr_indice_arq := vr_indice_arq + 1;
                        
            vr_tab_arquivo(vr_cdcooper)(vr_indice_arq).nrodojob := replace(vr_tab_string(1),'"','');  -- Job
            vr_tab_arquivo(vr_cdcooper)(vr_indice_arq).nrcnvcob := vr_indice;  -- Convenio
            vr_tab_arquivo(vr_cdcooper)(vr_indice_arq).nrnosnum := replace(vr_tab_string(4),'"','');  -- Nosso Numero
            vr_tab_arquivo(vr_cdcooper)(vr_indice_arq).nrdscore := replace(vr_tab_string(11),'"','');  -- Score
            vr_tab_arquivo(vr_cdcooper)(vr_indice_arq).dsdevolu := gene0007.fn_caract_acento(pr_texto => replace(UPPER(vr_tab_string(12)),'"','')); -- Motivo Devolução
            vr_tab_arquivo(vr_cdcooper)(vr_indice_arq).dsbloque := gene0007.fn_caract_acento(pr_texto => replace(UPPER(vr_tab_string(13)),'"','')); -- Motivo Bloqueio
            vr_tab_arquivo(vr_cdcooper)(vr_indice_arq).inpostag := replace(vr_tab_string(14),'"',''); -- Postagem
            vr_tab_arquivo(vr_cdcooper)(vr_indice_arq).cdcooper := vr_cdcooper;       -- Cooperativa
            vr_tab_arquivo(vr_cdcooper)(vr_indice_arq).nmarquiv := vr_nmarquiv;

            vr_tab_arquivo(vr_cdcooper)(vr_indice_arq).nrdconta := to_number(substr(vr_tab_arquivo(vr_cdcooper)(vr_indice_arq).nrnosnum,1,8));
            vr_tab_arquivo(vr_cdcooper)(vr_indice_arq).nrdocmto := to_number(substr(vr_tab_arquivo(vr_cdcooper)(vr_indice_arq).nrnosnum,9,9));

          END IF;

        END LOOP; -- Fim LOOP linhas do arquivo
      EXCEPTION
        WHEN no_data_found THEN
          -- Acabou a leitura
          NULL;
      END;

      -- Fechar o arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo); --> Handle do arquivo aberto;

    END IF;


    FOR rw_crapcop IN cr_crapcop LOOP

      vr_nrsequen := 0;
      vr_tab_relatorio.DELETE;

      vr_flg_gera_rel := FALSE;

      -- Diretorio Geração Relatorio
      vr_nmdirrel := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                           pr_cdcooper => rw_crapcop.cdcooper,
                                           pr_nmsubdir => 'rl');

      IF vr_tab_arquivo.EXISTS(rw_crapcop.cdcooper) THEN

        -- Leitura do calendario da cooperativa
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        -- Se não encontrar
        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois efetuaremos raise
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic:= 1;
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;

        BEGIN

          -- Busca Numero da Ultima Retorno
          OPEN cr_crapcce(pr_cdcooper => rw_crapcop.cdcooper);
          FETCH cr_crapcce INTO rw_crapcee;

          -- Fecha Cursor
          CLOSE cr_crapcce;

          -- Numero de Retorno
          vr_ultimo_retorno := rw_crapcee.max_nrremret;

          -- Inserir Header da Remessa
          INSERT INTO crapcee(cdcooper
                              ,nrremret
                              ,intipmvt
                              ,nmarquiv
                              ,cdoperad
                              ,dtmvtolt
                              ,dttransa
                              ,hrtransa
                              ,insitmvt)

                      VALUES  (rw_crapcop.cdcooper
                              ,vr_ultimo_retorno
                              ,2 -- Retorno
                              ,vr_nmarquiv
                              ,1 -- Super Usuario
                              ,rw_crabdat.dtmvtolt
                              ,NULL
                              ,NULL
                              ,0)
                      RETURNING ROWID
                      INTO vr_rowidcce;

          EXCEPTION
            WHEN OTHERS THEN
             vr_dscritic := 'Erro ao inserir na tabela crapcee. '|| SQLERRM;
             --Sair do programa
             RAISE vr_exc_saida;
          END;
      ELSE
        -- Proxima Cooperativa
        CONTINUE;
      END IF;

      -- Monta Indice
      vr_indice := vr_tab_arquivo(rw_crapcop.cdcooper).first;
      WHILE vr_indice IS NOT NULL LOOP

        -- Verifica se a cooperativa esta cadastrada
        OPEN cr_crapcob(pr_cdcooper => rw_crapcop.cdcooper
                       ,pr_nrcnvcob => vr_tab_arquivo(rw_crapcop.cdcooper)(vr_indice).nrcnvcob
                       ,pr_nrdconta => vr_tab_arquivo(rw_crapcop.cdcooper)(vr_indice).nrdconta
                       ,pr_nrdocmto => vr_tab_arquivo(rw_crapcop.cdcooper)(vr_indice).nrdocmto);
        FETCH cr_crapcob INTO rw_crapcob;
        -- Se não encontrar
        IF cr_crapcob%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_crapcob;

          vr_indice_2 := vr_indice_2 + 1;

          -- Inclui Registro na PL/Table de Titulos não Localizados.
          vr_tab_crapcob(vr_indice_2).cdcooper := rw_crapcop.cdcooper;
          vr_tab_crapcob(vr_indice_2).nmarquiv := vr_tab_arquivo(rw_crapcop.cdcooper)(vr_indice).nmarquiv;
          vr_tab_crapcob(vr_indice_2).nrcnvcob := vr_tab_arquivo(rw_crapcop.cdcooper)(vr_indice).nrcnvcob;
          vr_tab_crapcob(vr_indice_2).nrnosnum := vr_tab_arquivo(rw_crapcop.cdcooper)(vr_indice).nrnosnum;
          vr_tab_crapcob(vr_indice_2).nrdconta := vr_tab_arquivo(rw_crapcop.cdcooper)(vr_indice).nrdconta;
          vr_tab_crapcob(vr_indice_2).nrdocmto := vr_tab_arquivo(rw_crapcop.cdcooper)(vr_indice).nrdocmto;

          -- Proximo Registro
          vr_indice := vr_tab_arquivo(rw_crapcop.cdcooper).next(vr_indice);

          -- Proximo Registro
          CONTINUE;

        ELSE
          -- Fechar o cursor
          CLOSE cr_crapcob;

          vr_cdcooper := rw_crapcob.cdcooper;
          vr_rowidcob := rw_crapcob.rowid;

          -- Monta indice da PL/TABLE
          vr_indice_rel := LPAD(rw_crapcob.cdagenci,5,'0')  ||
                           LPAD(rw_crapcob.nrdconta,10,'0') ||
                           LPAD(rw_crapcob.nrcnvcob,7,'0') ||
                           LPAD(rw_crapcob.nrdocmto,9,'0');


          -- PA, Conta/DV, Convenio, Nosso Numero, Vlr Titulo, Score, Mot Devolucao, Mot Bloq
          vr_tab_relatorio(vr_indice_rel).cdagenci := rw_crapcob.cdagenci ;
          vr_tab_relatorio(vr_indice_rel).nrdconta := rw_crapcob.nrdconta ;
          vr_tab_relatorio(vr_indice_rel).nrcnvcob := rw_crapcob.nrcnvcob ;
          vr_tab_relatorio(vr_indice_rel).nrnosnum := rw_crapcob.nrnosnum ;
          vr_tab_relatorio(vr_indice_rel).vltitulo := rw_crapcob.vltitulo ;
          vr_tab_relatorio(vr_indice_rel).nrodojob := vr_tab_arquivo(vr_cdcooper)(vr_indice).nrodojob ;          
          vr_tab_relatorio(vr_indice_rel).nrdscore := vr_tab_arquivo(vr_cdcooper)(vr_indice).nrdscore ;
          vr_tab_relatorio(vr_indice_rel).dsdevolu := vr_tab_arquivo(vr_cdcooper)(vr_indice).dsdevolu ;
          vr_tab_relatorio(vr_indice_rel).dsbloque := vr_tab_arquivo(vr_cdcooper)(vr_indice).dsbloque ;
          
          IF vr_tab_arquivo(vr_cdcooper)(vr_indice).inpostag = 1 THEN 
             vr_tab_relatorio(vr_indice_rel).inpostag := 'S';
          ELSE
             vr_tab_relatorio(vr_indice_rel).inpostag := ' ';
          END IF;

          vr_flg_gera_rel := TRUE;

        END IF;

        vr_nrodojob := vr_tab_arquivo(vr_cdcooper)(vr_indice).nrodojob;
        vr_nrdscore := vr_tab_arquivo(vr_cdcooper)(vr_indice).nrdscore;
        vr_dsbloque := upper(vr_tab_arquivo(vr_cdcooper)(vr_indice).dsbloque);
        vr_dsdevolu := upper(vr_tab_arquivo(vr_cdcooper)(vr_indice).dsdevolu);
        vr_inpostag := vr_tab_arquivo(vr_cdcooper)(vr_indice).inpostag;

        -- Inicializa as Variaveis
        vr_dtemiexp := NULL;
        vr_inemiexp := NULL;

        -- Titulo devolvido
        IF TRIM(vr_nrdscore) IS NOT NULL THEN

          CASE vr_nrdscore
            WHEN '0402' THEN
              vr_dsdscore := 'MUDOU-SE';
              vr_cdmotivo := '01';
            WHEN '0406' THEN
              vr_dsdscore := 'ENDERECO INSUFICIENTE';
              vr_cdmotivo := '02';              
            WHEN '0407' THEN
              vr_dsdscore := 'NAO EXISTE O N INDICADO';
              vr_cdmotivo := '03';              
            WHEN '0404' THEN
              vr_dsdscore := 'DESCONHECIDO';
              vr_cdmotivo := '04';              
            WHEN '0606' THEN
              vr_dsdscore := 'RECUSADO';
              vr_cdmotivo := '05';              
            WHEN '0901' THEN
              vr_dsdscore := 'NAO PROCURADO';
              vr_cdmotivo := '06';              
            WHEN '0902' THEN
              vr_dsdscore := 'AUSENTE';
              vr_cdmotivo := '07';              
            WHEN '0903' THEN
              vr_dsdscore := 'FALECIDO';
              vr_cdmotivo := '08';              
            WHEN '0999' THEN
              vr_dsdscore := 'OUTROS';
              vr_cdmotivo := '09';                        
          END CASE;

          vr_inemiexp := 5;
          vr_dsmensag := 'Titulo devolvido. Job ' || to_char(vr_nrodojob) || ' Motivo: ' || vr_dsdscore;

          vr_cdocorre := 91; -- Ocorrencia do Pagador

          -- Preparar Lote de Retorno Cooperado
          PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => vr_rowidcob          -- ROWID da cobranca
                                             ,pr_cdocorre => vr_cdocorre          -- Codigo Ocorrencia
                                             ,pr_dsmotivo => NULL                 -- Descricao Motivo
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data Movimento
                                             ,pr_cdoperad => '1'                  -- Codigo Operador
                                             ,pr_nrremret => vr_nrremret          -- Numero Remessa
                                             ,pr_cdcritic => vr_cdcritic          -- Codigo Critica
                                             ,pr_dscritic => vr_dscritic);        -- Descricao Critica
                                             
          PAGA0001.pc_prepara_retorno_cooperativa (pr_idtabcob => vr_rowidcob   --ROWID da cobranca
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --Data Movimento
                                                  ,pr_dtocorre => rw_crapdat.dtmvtolt   --Data Ocorrencia
                                                  ,pr_cdoperad => '1'   --Codigo Operador
                                                  ,pr_vlabatim => 0   --Valor Abatimento
                                                  ,pr_vldescto => 0   --Valor Desconto
                                                  ,pr_vljurmul => 0   --Valor juros multa
                                                  ,pr_vlrpagto => 0   --Valor pagamento
                                                  ,pr_flgdesct => FALSE   --Flag para titulo descontado
                                                  ,pr_flcredit => FALSE   --Flag Credito
                                                  ,pr_nrretcoo => vr_nrremret --Numero Retorno Cooperativa
                                                  ,pr_cdmotivo => vr_cdmotivo   --Codigo Motivo
                                                  ,pr_cdocorre => vr_cdocorre   --Codigo Ocorrencia
                                                  ,pr_cdbanpag => rw_crapcop.cdbcoctl   --Codigo banco pagamento
                                                  ,pr_cdagepag => rw_crapcop.cdagectl   --Codigo Agencia pagamento
                                                  ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                                  ,pr_dscritic => vr_dscritic); --Descricao Critica
                                             

        ELSIF (TRIM(vr_dsbloque) = 'DUVIDOSO' OR
               TRIM(vr_dsbloque) = 'NAO POSTAR' OR
               TRIM(vr_dsbloque) = 'ENDERECO SEM NUMERO' OR 
               (TRIM(vr_dsbloque) IS NOT NULL AND TRIM(vr_dsbloque) NOT IN ('CORRIGIDO','INALTERADO'))) AND
               (vr_inpostag = 0) THEN

            vr_inemiexp := 6;
            vr_dsmensag := 'Titulo bloqueado pela PG. Job ' || to_char(vr_nrodojob) || ' Motivo: ' || vr_dsbloque;

            vr_cdocorre := 91; -- Titulo não Enviado

            -- Preparar Lote de Retorno Cooperado
            PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => vr_rowidcob          -- ROWID da cobranca
                                               ,pr_cdocorre => vr_cdocorre          -- Codigo Ocorrencia
                                               ,pr_dsmotivo => 'P2'                 -- Descricao Motivo
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data Movimento
                                               ,pr_cdoperad => '1'                  -- Codigo Operador
                                               ,pr_nrremret => vr_nrremret          -- Numero Remessa
                                               ,pr_cdcritic => vr_cdcritic          -- Codigo Critica
                                               ,pr_dscritic => vr_dscritic);        -- Descricao Critica
                                               
            PAGA0001.pc_prepara_retorno_cooperativa (pr_idtabcob => vr_rowidcob   --ROWID da cobranca
                                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --Data Movimento
                                                    ,pr_dtocorre => rw_crapdat.dtmvtolt   --Data Ocorrencia
                                                    ,pr_cdoperad => '1'   --Codigo Operador
                                                    ,pr_vlabatim => 0   --Valor Abatimento
                                                    ,pr_vldescto => 0   --Valor Desconto
                                                    ,pr_vljurmul => 0   --Valor juros multa
                                                    ,pr_vlrpagto => 0   --Valor pagamento
                                                    ,pr_flgdesct => FALSE   --Flag para titulo descontado
                                                    ,pr_flcredit => FALSE   --Flag Credito
                                                    ,pr_nrretcoo => vr_nrremret --Numero Retorno Cooperativa
                                                    ,pr_cdmotivo => '09'   --Codigo Motivo = Outros
                                                    ,pr_cdocorre => 91     --Codigo Ocorrencia
                                                    ,pr_cdbanpag => rw_crapcop.cdbcoctl   --Codigo banco pagamento
                                                    ,pr_cdagepag => rw_crapcop.cdagectl   --Codigo Agencia pagamento
                                                    ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                                    ,pr_dscritic => vr_dscritic); --Descricao Critica
                                               
        ELSE
            -- Titulo processado
            IF vr_inpostag = 0 THEN
               vr_inemiexp := 3;
               vr_dsmensag := 'Titulo processado pela PG - Job ' || to_char(vr_nrodojob);
            -- Titulo postado
            ELSIF vr_inpostag = 1 THEN
               vr_inemiexp := 4;
               vr_dsmensag := 'Titulo postado pela PG - Job ' || to_char(vr_nrodojob);               
            END if;            
        END IF;

         BEGIN
          UPDATE crapcob
             SET crapcob.inemiexp = NVL(vr_inemiexp,crapcob.inemiexp)
                ,crapcob.dtemiexp = NVL(vr_dtemiexp,crapcob.dtemiexp)
           WHERE crapcob.rowid = vr_rowidcob;

          -- Criar Log Cobranca
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => vr_rowidcob         --ROWID da Cobranca
                                       ,pr_cdoperad => 1                   --Operador
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                       ,pr_dsmensag => vr_dsmensag         --Descricao Mensagem
                                       ,pr_des_erro => vr_des_erro         --Indicador erro
                                       ,pr_dscritic => vr_dscritic);       --Descricao erro
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_next;
          END IF;


        EXCEPTION
          WHEN OTHERS THEN
           vr_dscritic := 'Erro ao atualizar tabela crapcob. '|| SQLERRM;
           --Sair do programa
           RAISE vr_exc_next;
        END;

        -- Incrementa Numero Sequencial
        vr_nrsequen := vr_nrsequen + 1;

        BEGIN
          -- Inserir Detalhe da Remessa
          INSERT INTO crapdee(cdcooper
                             ,nrremret
                             ,intipmvt
                             ,nrdconta
                             ,nrcnvcob
                             ,nrdocmto
                             ,nrsequen
                             ,cdocorre
                             ,cdocrpag)
                     VALUES (rw_crapcob.cdcooper
                            ,vr_ultimo_retorno
                            ,2 -- Retorno
                            ,rw_crapcob.nrdconta
                            ,rw_crapcob.nrcnvcob
                            ,rw_crapcob.nrdocmto
                            ,vr_nrsequen
                            ,vr_cdocorre
                            ,vr_nrdscore);

        EXCEPTION
            WHEN OTHERS THEN
             vr_dscritic := 'Erro ao inserir na tabela crapdee. '|| SQLERRM;
             --Sair do programa
             RAISE vr_exc_saida;
        END;


        -- Proximo Registro
        vr_indice := vr_tab_arquivo(rw_crapcop.cdcooper).next(vr_indice);
      END LOOP;

      IF vr_nrsequen > 0 THEN

        -- Atualiza o campo cdidejob com o valor retornado.
        BEGIN
          UPDATE crapcee
             SET crapcee.dttransa = rw_crapdat.dtmvtolt
                ,crapcee.hrtransa = to_number(to_char(SYSDATE,'SSSSS'))
           WHERE crapcee.rowid = vr_rowidcce;

        EXCEPTION
          WHEN OTHERS THEN
           vr_dscritic := 'Erro ao atualizar tabela crapcee. '|| SQLERRM;
           --Sair do programa
           RAISE vr_exc_saida;
        END;

      END IF;

      IF  vr_flg_gera_rel = TRUE THEN
        -- Gerar Relatorio

        -- Inicializar o CLOB
        vr_des_xml := NULL;
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        -- Inicilizar as informações do XML
        vr_texto_completo := NULL;
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz><crrl701>');

        pc_escreve_xml(
             '<arquivo>' ||
               '<nmarquiv>'||  vr_nmarquiv  ||'</nmarquiv>'||
             '</arquivo>' ||
             '<titulos>');

        vr_indice_rel := vr_tab_relatorio.first;
        WHILE vr_indice_rel IS NOT NULL LOOP
          pc_escreve_xml(
           '<titulo>' ||
             '<cdagenci>'||  vr_tab_relatorio(vr_indice_rel).cdagenci                         ||'</cdagenci>'||
             '<nrdconta>'||  gene0002.fn_mask_conta(vr_tab_relatorio(vr_indice_rel).nrdconta) ||'</nrdconta>'||
             '<nrcnvcob>'||  vr_tab_relatorio(vr_indice_rel).nrcnvcob                         ||'</nrcnvcob>'||
             '<nrnosnum>'||  vr_tab_relatorio(vr_indice_rel).nrnosnum                         ||'</nrnosnum>'||
             '<vltitulo>'||  vr_tab_relatorio(vr_indice_rel).vltitulo                         ||'</vltitulo>'||
             '<nrdscore>'||  vr_tab_relatorio(vr_indice_rel).nrdscore                         ||'</nrdscore>'||
             '<dsdevolu>'||  vr_tab_relatorio(vr_indice_rel).dsdevolu                         ||'</dsdevolu>'||
             '<dsbloque>'||  vr_tab_relatorio(vr_indice_rel).dsbloque                         ||'</dsbloque>'||
             '<inpostag>'||  vr_tab_relatorio(vr_indice_rel).inpostag                         ||'</inpostag>'||
           '</titulo>');

          vr_indice_rel := vr_tab_relatorio.next(vr_indice_rel);
        END LOOP;

        pc_escreve_xml(
           '</titulos>' ||
           '<total>' ||           
--             '<qtdtotal>'||  vr_qtdtotal    ||'</qtdtotal>'||
--             '<vltitulo>'||  vr_vlrtotal    ||'</vltitulo>'||
           '</total>');


        pc_escreve_xml('</crrl701></raiz>',TRUE);

        /*
        -- Gerar o xml para teste
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                     ,pr_caminho  => vr_nmdirrel
                                     ,pr_arquivo  => vr_nmarqimp || '.xml'
                                     ,pr_des_erro => vr_dscritic);
        */

        gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop.cdcooper,            --> Cooperativa conectada
                                    pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                    pr_dtmvtolt  => rw_crabdat.dtmvtolt,            --> Data do movimento atual
                                    pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                    pr_dsxmlnode => '/raiz/crrl701/titulos/titulo', --> Nó base do XML para leitura dos dados
                                    pr_dsjasper  => 'crrl701.jasper',               --> Arquivo de layout do iReport
                                    pr_dsparams  => NULL,                           --> Enviar como parâmetro apenas a agência
                                    pr_dsarqsaid => vr_nmdirrel || '/' || vr_nmarqimp, --> Arquivo final com código da agência
                                    pr_flg_gerar => 'S',
                                    pr_qtcoluna  => 132,
                                    pr_flg_impri => 'S',                            --> Chamar a impressão (Imprim.p)
                                    pr_nmformul  => '132col',                       --> Nome do formulário para impressão
                                    pr_nrcopias  => 1,                              --> Número de cópias para impressão
                                    pr_des_erro  => vr_dscritic);                   --> Saída com erro

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);

      END IF;

    END LOOP; -- cr_crapcoop
    
     -- Montar o cabeçalho do html e o alerta
    vr_dscorpo := '<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >';
    vr_dscorpo := vr_dscorpo || 'Segue listagem de titulos nao localizados no retorno PG.';
    vr_dscorpo := vr_dscorpo || '</meta>';

    vr_dscorpo := vr_dscorpo || '<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >';
    vr_dscorpo := vr_dscorpo || '<table border="1" style="width:500px; margin: 10px auto; font-family: Tahoma,sans-serif; font-size: 12px; color: #686868;" >';
    -- Montando header
    vr_dscorpo := vr_dscorpo || '<th>Coop.</th>';
    vr_dscorpo := vr_dscorpo || '<th>Arquivo</th>';
    vr_dscorpo := vr_dscorpo || '<th>Convenio</th>';
    vr_dscorpo := vr_dscorpo || '<th>Conta</th>';
    vr_dscorpo := vr_dscorpo || '<th>Nosso Nro.</th>';
    vr_dscorpo := vr_dscorpo || '<th>Documento</th>';

    vr_flgemail := FALSE;

    -- Gerar Relatorio Email
    vr_indice := vr_tab_crapcob.first;
    WHILE vr_indice IS NOT NULL LOOP
       -- Para cada registro, montar sua tr
      vr_dscorpo := vr_dscorpo || '<tr>';

      -- E os detalhes do registro
      vr_dscorpo := vr_dscorpo || '<td>'||to_char(vr_tab_crapcob(vr_indice).cdcooper) ||'</td>';
      vr_dscorpo := vr_dscorpo || '<td>'||to_char(vr_tab_crapcob(vr_indice).nmarquiv) ||'</td>';
      vr_dscorpo := vr_dscorpo || '<td>'||to_char(vr_tab_crapcob(vr_indice).nrcnvcob) ||'</td>';
      vr_dscorpo := vr_dscorpo || '<td>'||to_char(vr_tab_crapcob(vr_indice).nrdconta) ||'</td>';
      vr_dscorpo := vr_dscorpo || '<td>'||to_char(vr_tab_crapcob(vr_indice).nrnosnum) ||'</td>';
      vr_dscorpo := vr_dscorpo || '<td>'||to_char(vr_tab_crapcob(vr_indice).nrdocmto) ||'</td>';

      -- Encerrar a tr
      vr_dscorpo := vr_dscorpo || '</tr>';

      vr_flgemail := TRUE;

      vr_indice := vr_tab_crapcob.next(vr_indice);
    END LOOP;

    vr_dscorpo := vr_dscorpo || '</table>';
    vr_dscorpo := vr_dscorpo || '</meta>';

    IF vr_flgemail = TRUE AND vr_des_destino IS NOT NULL THEN

      -- Enviar e-mail informando erro
      GENE0003.pc_solicita_email(pr_cdcooper        => 3 /* cecred */
                                ,pr_cdprogra        => vr_cdprogra
                                ,pr_des_destino     => vr_des_destino
                                ,pr_des_assunto     => 'Cobrança - TITULOS NAO LOCALIZADOS - RETORNO PG'
                                ,pr_des_corpo       => vr_dscorpo
                                ,pr_des_anexo       => NULL
                                ,pr_des_erro        => vr_dscritic);

      -- Verificar se houve erro ao solicitar e-mail
      IF vr_dscritic IS NOT NULL THEN
        -- Não gerar critica
        vr_cdcritic := 0;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3 /* cecred */
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic );
      END IF;

    END IF;

        
    -- Mover o arquivo retorno para a pasta /usr/coop/<cooperativa>/salvar
    gene0001.pc_OScommand_Shell('mv ' || vr_nmdireto || '/' || vr_nmarquiv || ' ' ||
                                 vr_nmdirslv || '/' || vr_nmarquiv);


    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Finaliza Execucão do Programa
    btch0001.pc_valida_fimprg(pr_cdcooper => 3, /* cecred */
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- Salvar informações
    COMMIT;

  EXCEPTION
  WHEN vr_exc_fimprg THEN

    -- Se retornou apenas o codigo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Busca descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;

    -- Se foi gerado critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN

      -- Envio Centralizado de Log de Erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3, /* cecred */
                                 pr_ind_tipo_log => 2, -- ERRO TRATATO
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                    ' -' || vr_cdprogra || ' --> ' ||
                                                    vr_dscritic);

    END IF;

    -- Chamos o pc_valida_fimprg para encerrar o processo sem parar a cadeia
    BTCH0001.pc_valida_fimprg(pr_cdcooper => 3, /* cecred */
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- Salva informações no banco de dados
    COMMIT;

  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas codigo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos codigo e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic, 0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
  END;

END pc_crps694;
/

