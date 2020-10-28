DECLARE
  --
  PROCEDURE baca_crps538_1(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                          ,pr_nmtelant    IN VARCHAR2 --> Nome tela anterior
                          ,pr_dsreproc    IN VARCHAR2 --> processo de REPROC
                          ,pr_nmarquiv    IN VARCHAR2 --> Nome arquivo
                          ,pr_tab_cratrej IN TYP_CRAPREJ_ARRAY --> Codigo da Critica
                           ) IS
  BEGIN
  
    /* .............................................................................
    
    Programa: PC_CRPS538_1                      Antigo: PC_CRPS538.PCK
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Belli / Envolti
    Data    : Agosto/2017.                   Ultima atualizacao: 26/04/2019
    
    Projeto:  Chamado 714566.
    
    Dados referentes ao programa:
    
    Frequencia: Diario (Batch).
    Objetivo: 
      Foi retirada essas rotinas do programa cprs538 
      para priorizar as liberações do sistema para os clientes.
      - atualiza protesto 
      - atualiza baixa decurso prazo
      - relatorio 686 - "MOVIMENTO FLOAT - 085"
    
    Alteracoes: 
    
    - Incluido controle de inicio e fim de programa - 
      ( Belli - Chamado 801477 - 24/11/2017 )
                     
    15/03/2018 - Ajustar os padrões:
               - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
               - Eliminando mensagens de erro e informação gravadas fixas
               (Belli - Envolti - Chamado 801483)  
    
    - Ajuste na criação de críticas, lógica do programa invertida.
      ( Andrey Formigari - Mouts #856928  - 04/04/2018 )
               
    - Incluído tratativa para efetivação de pagamento por recurso de prazo para boletos da COBTIT
      ( Paulo Penteado GFT - 03/08/2018)
                     
    08/10/2018 - Retorno de versão por sikmples suspeita de problema
               (Belli - Envolti - Chamado REQ0029352)           
    
    22/10/2018 - Ajuste no cursor da rotina de protesto automático (P352 - Cechet)
    
    26/04/2019 - inc0011095 no cursor cr_crapcob_aberto, filtrar apenas as cobranças não enviadas para cartório
                 e não protestadas (Carlos)        
    
    20/01/2020 - Inclusão do campo com a data limite de pagamento (Jefferson - MoutS)
    
    .............................................................................*/
  
    DECLARE
    
      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrtelura
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,cop.dsdircop
              ,cop.nrctactl
              ,cop.cdagedbb
              ,cop.cdageitg
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
    
      --Selecionar Motivos
      CURSOR cr_crapmot(pr_cdcooper IN crapmot.cdcooper%TYPE) IS
        SELECT crapmot.cddbanco
              ,crapmot.cdocorre
              ,crapmot.tpocorre
              ,crapmot.cdmotivo
              ,crapmot.dsmotivo
          FROM crapmot
         WHERE crapmot.cdcooper = pr_cdcooper;
    
      --Variaveis de Excecao
      vr_exc_final EXCEPTION;
      vr_exc_saida EXCEPTION;
    
      --Variaveis para retorno de erro
      pr_cdcritic INTEGER := 0;
      pr_dscritic VARCHAR2(4000);
    
      vr_cdcritic INTEGER := 0;
      vr_dscritic VARCHAR2(4000);
      vr_des_erro VARCHAR2(3);
    
      vr_qtdexec INTEGER := 0;
    
      -- Variavel para armazenar as informacoes em XML
      vr_des_xml CLOB;
      vr_dstexto VARCHAR2(32700);
    
      --Constantes
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS538_1';
      vr_cdoperad VARCHAR2(100);
    
      --Variaveis Locais    
      vr_dtmvtaux   DATE;
      vr_nmarqimp   VARCHAR2(100);
      vr_caminho_rl VARCHAR2(1000);
      -- Excluida vr_caminho_salvar pois não utilizada - 15/03/2018 - Chamado 801483 
      vr_nmarquiv VARCHAR2(100);
      vr_dtmvtpro DATE;
      vr_contador INTEGER;
    
      vr_rejeitad  BOOLEAN;
      vr_temlancto BOOLEAN;
    
      vr_qtdregis INTEGER := 0;
      vr_vlregist NUMBER := 0;
      vr_vldescon NUMBER := 0;
      vr_valjuros NUMBER := 0;
    
      vr_vloutdeb NUMBER := 0;
      vr_vloutcre NUMBER := 0;
      vr_valorpgo NUMBER := 0;
      vr_vltarifa NUMBER := 0;
    
      vr_qttotreg INTEGER := 0;
      vr_vltotreg NUMBER := 0;
      vr_vltotdes NUMBER := 0;
      vr_vltotjur NUMBER := 0;
      vr_vltotpag NUMBER := 0;
      vr_vltottar NUMBER := 0;
      vr_bancoage VARCHAR2(100);
      vr_dsmotrel VARCHAR2(100);
      vr_tplotmov INTEGER := 1;
      vr_dsocorre VARCHAR2(100);
      vr_qtregrec INTEGER := 0;
      vr_qtregicd INTEGER := 0;
      vr_qtregisd INTEGER := 0;
    
      vr_qtregrej INTEGER := 0;
      vr_vlregrec NUMBER := 0;
      vr_vlregicd NUMBER := 0;
      vr_vlregisd NUMBER := 0;
      vr_vlregrej NUMBER := 0;
    
      -- Excluida vr_tab_nmarqtel pois não utilizada - 15/03/2018 - Chamado 801483 
    
      -- Variavel para armazenar as informacoes em XML
      vr_clobcri CLOB;
    
      vr_desdados VARCHAR2(4000);
    
      vr_index_crapmot VARCHAR2(17);
      vr_index_cratrej VARCHAR2(20);
    
      --Definicao dos tipos de tabelas
      vr_typ_craprej_array TYP_CRAPREJ_ARRAY := TYP_CRAPREJ_ARRAY();
      TYPE typ_tab_crapmot IS TABLE OF crapmot.dsmotivo%TYPE INDEX BY VARCHAR2(17);
      vr_tab_crapmot typ_tab_crapmot;
    
      --variaveis para controle de arquivos
      vr_dircon VARCHAR2(200);
      vr_arqcon VARCHAR2(200);
      vc_dircon   CONSTANT VARCHAR2(30) := 'arquivos_contabeis/ayllos';
      vc_cdacesso CONSTANT VARCHAR2(24) := 'ROOT_SISTEMAS';
      vc_cdtodascooperativas INTEGER := 0;
    
      vr_caminho_puro VARCHAR2(1000);
    
      vr_des_erro2 VARCHAR2(4000);
    
      vr_inreproc BOOLEAN;
    
      --Registro do tipo calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
      --Tabela de lancamentos para consolidar
      vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
    
      vr_dstitdsc VARCHAR2(100);
    
      vr_dtmvtolt DATE;
    
      -- Ajuste log - 15/03/2018 - Chamado 801483 
      -- Controla Controla log em banco de dados
      PROCEDURE pc_controla_log_programa(pr_dstiplog IN VARCHAR2 -- I-início/ F-fim/ O-ocorrência/ E- rro
                                        ,pr_tpocorre IN NUMBER DEFAULT NULL -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensage
                                        ,pr_dscritic IN VARCHAR2 -- Descrição do Log
                                        ,pr_cdcritic IN tbgen_prglog_ocorrencia.cdmensagem%TYPE DEFAULT 0 -- Codigo da descrição do Log
                                        ,pr_cdcricid IN tbgen_prglog_ocorrencia.cdcriticidade%TYPE DEFAULT 2 -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                         ) IS
        vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
      BEGIN
        --> Controlar geração de log de execução dos jobs                                
        CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog
                              ,pr_tpocorrencia  => pr_tpocorre
                              ,pr_cdcriticidade => pr_cdcricid
                              ,pr_cdcooper      => pr_cdcooper
                              ,pr_dsmensagem    => pr_dscritic || ' pr_cdcooper:' || pr_cdcooper ||
                                                   ', pr_nmtelant:' || pr_nmtelant ||
                                                   ', vr_inreproc:' || CASE vr_inreproc
                                                     WHEN TRUE THEN
                                                      'true'
                                                     ELSE
                                                      'false'
                                                   END || ', pr_nmarquiv:' || pr_nmarquiv
                              ,pr_cdmensagem    => pr_cdcritic
                              ,pr_cdprograma    => vr_cdprogra
                              ,pr_idprglog      => vr_idprglog
                              ,pr_tpexecucao    => 2 -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                               );
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log  
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      END pc_controla_log_programa;
    
      --Funcao para listar motivos
      FUNCTION fn_lista_motivos(pr_dsmotivo IN VARCHAR2
                               ,pr_cddbanco IN INTEGER
                               ,pr_cdocorre IN INTEGER) RETURN VARCHAR2 IS
      BEGIN
        DECLARE
          --Variaveis Locais
          vr_dsmotrel crapmot.dsmotivo%TYPE;
          vr_pos      INTEGER := 1;
        BEGIN
          --Percorrer string dos motivos
          WHILE vr_pos <= LENGTH(TRIM(pr_dsmotivo))
          LOOP
            --Monta mensagem
            vr_dsmotrel := TRIM(SUBSTR(pr_dsmotivo, vr_pos, 2));
            --Montar Indice para acesso ao cadastro motivos
            vr_index_crapmot := lpad(pr_cddbanco, 5, '0') || lpad(pr_cdocorre, 5, '0') ||
                                lpad(2, 5, '0') || vr_dsmotrel;
            --Verificar se existe motivo
            IF vr_tab_crapmot.EXISTS(vr_index_crapmot) THEN
              vr_dsmotrel := vr_dsmotrel || ' - ' || vr_tab_crapmot(vr_index_crapmot);
            END IF;
            --Incrementar posicao
            vr_pos := vr_pos + 2;
          END LOOP;
          --Retornar descricao motivo
          RETURN(vr_dsmotrel);
        EXCEPTION
          WHEN OTHERS THEN
            RETURN NULL;
        END;
      END fn_lista_motivos;
    
      --Gerar Relatorio 605
      PROCEDURE pc_gera_relatorio_605(pr_cdcritic OUT INTEGER
                                     ,pr_dscritic OUT VARCHAR2) IS
        --Cursores Locais
        CURSOR cr_crapcco_relat(pr_cdcooper IN crapcco.cdcooper%TYPE
                               ,pr_cddbanco IN crapcco.cddbanco%TYPE) IS
          SELECT crapcco.dsorgarq
                ,crapcco.nrconven
                ,crapcco.nrdolote
                ,crapcco.cdagenci
                ,crapcco.cdbccxlt
            FROM crapcco
           WHERE crapcco.cdcooper = pr_cdcooper
             AND crapcco.cddbanco = pr_cddbanco;
        --Selecionar controle remessas titulos bancarios
        CURSOR cr_crapcre_relat(pr_cdcooper IN crapcop.cdcooper%TYPE
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                               ,pr_nrconven IN crapcco.nrconven%TYPE
                               ,pr_intipmvt IN crapcre.intipmvt%TYPE
                               ,pr_cddbanco IN crapcco.cddbanco%TYPE) IS
          SELECT crapcre.cdcooper
                ,crapcre.nrcnvcob
                ,crapcre.dtmvtolt
                ,crapcre.nrremret
                ,crapcco.nrdctabb
                ,crapcco.cddbanco
            FROM crapcre
                ,crapcco
           WHERE crapcre.cdcooper = pr_cdcooper
             AND crapcre.dtmvtolt = pr_dtmvtolt
             AND crapcre.nrcnvcob = pr_nrconven
             AND crapcre.intipmvt = pr_intipmvt
             AND crapcco.cddbanco = pr_cddbanco
             AND crapcco.cdcooper = crapcre.cdcooper
             AND crapcco.nrconven = crapcre.nrcnvcob;
      
        --Selecionar Retorno
        CURSOR cr_crapret(pr_cdcooper IN crapcre.cdcooper%TYPE
                         ,pr_nrcnvcob IN crapcre.nrcnvcob%TYPE
                         ,pr_dtocorre IN crapcre.dtmvtolt%TYPE
                         ,pr_nrremret IN crapcre.nrremret%TYPE
                         ,pr_nrdctabb IN crapcco.nrdctabb%TYPE
                         ,pr_cdbandoc IN crapcco.cddbanco%TYPE) IS
          SELECT crapret.cdcooper
                ,crapret.nrcnvcob
                ,crapret.nrdconta
                ,crapret.nrdocmto
                ,crapret.cdocorre
                ,crapret.vltitulo
                ,crapret.vldescto
                ,crapret.vlabatim
                ,crapret.vljurmul
                ,crapret.vloutdes
                ,crapret.vloutcre
                ,crapret.vlrpagto
                ,crapret.vltarass
                ,crapcob.cdbandoc
                ,crapcob.nrdctabb
                ,crapcob.indpagto
                ,COUNT(1) OVER(PARTITION BY crapret.cdocorre) nrtotoco
                ,Row_Number() OVER(PARTITION BY crapret.cdocorre ORDER BY crapret.cdocorre, crapcob.indpagto, crapret.nrdconta, crapret.nrdocmto) nrseqoco
                ,COUNT(1) OVER(PARTITION BY crapret.cdocorre, crapcob.indpagto) nrtotind
                ,Row_Number() OVER(PARTITION BY crapret.cdocorre, crapcob.indpagto ORDER BY crapret.cdocorre, crapcob.indpagto, crapret.nrdconta, crapret.nrdocmto) nrseqind
            FROM crapret
                ,crapcob
           WHERE crapret.cdcooper = pr_cdcooper
             AND crapret.nrcnvcob = pr_nrcnvcob
             AND crapret.dtocorre = pr_dtocorre
             AND crapret.nrremret = pr_nrremret
             AND crapcob.cdcooper = crapret.cdcooper
             AND crapcob.nrcnvcob = crapret.nrcnvcob
             AND crapcob.nrdconta = crapret.nrdconta
             AND crapcob.nrdctabb = pr_nrdctabb
             AND crapcob.cdbandoc = pr_cdbandoc
             AND crapcob.nrdocmto = crapret.nrdocmto
           ORDER BY crapret.cdocorre
                   ,crapcob.indpagto
                   ,crapret.nrdconta
                   ,crapret.nrdocmto;
      
        --Selecionar Retorno
        CURSOR cr_crapret_2(pr_cdcooper IN crapret.cdcooper%TYPE
                           ,pr_nrcnvcob IN crapret.nrcnvcob%TYPE
                           ,pr_dtocorre IN crapdat.dtmvtolt%TYPE
                           ,pr_nrremret IN crapret.nrremret%TYPE
                           ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                           ,pr_cddbanco IN crapcob.cdbandoc%TYPE) IS
          SELECT crapret.cdcooper
                ,crapret.nrcnvcob
                ,crapret.nrdconta
                ,crapret.nrdocmto
                ,decode(crapret.cdocorre
                       ,6
                       ,DECODE(crapcob.indpagto, 0, crapret.cdocorre, 6.5)
                       ,crapret.cdocorre) cdocorre
                ,crapret.vltitulo
                ,crapret.vldescto
                ,crapret.vlabatim
                ,crapret.vljurmul
                ,crapret.vloutdes
                ,crapret.vloutcre
                ,crapret.vlrpagto
                ,crapret.vltarass
                ,crapret.cdmotivo
                ,crapret.dtcredit
                ,crapcob.dsdoccop
                ,crapcob.dtvencto
                ,crapcob.cdbandoc
                ,crapcob.nrdctabb
                ,crapcob.indpagto
                ,crapcob.cdbanpag
                ,crapcob.cdagepag
                ,crapcob.dtdocmto
                ,crapass.cdagenci
                ,crapceb.qtdfloat
                ,COUNT(1) OVER(PARTITION BY decode(crapret.cdocorre, 6, DECODE(crapcob.indpagto, 0, crapret.cdocorre, 6.5), crapret.cdocorre)) nrtotoco
                ,Row_Number() OVER(PARTITION BY decode(crapret.cdocorre, 6, DECODE(crapcob.indpagto, 0, crapret.cdocorre, 6.5), crapret.cdocorre) ORDER BY decode(crapret.cdocorre, 6, DECODE(crapcob.indpagto, 0, crapret.cdocorre, 6.5), crapret.cdocorre), crapcob.indpagto, crapret.nrdconta, crapret.nrdocmto) nrseqoco
            FROM crapret
                ,crapceb
                ,crapcob
                ,crapass
           WHERE crapret.cdcooper = pr_cdcooper
             AND crapret.nrcnvcob = pr_nrcnvcob
             AND crapret.dtocorre = pr_dtocorre
             AND crapret.nrremret = pr_nrremret
             AND crapceb.cdcooper = crapret.cdcooper
             AND crapceb.nrdconta = crapret.nrdconta
             AND crapceb.nrconven = crapret.nrcnvcob
             AND crapcob.cdcooper = crapret.cdcooper
             AND crapcob.nrcnvcob = crapret.nrcnvcob
             AND crapcob.nrdconta = crapret.nrdconta
             AND crapcob.nrdctabb = pr_nrdctabb
             AND crapcob.cdbandoc = pr_cddbanco
             AND crapcob.nrdocmto = crapret.nrdocmto
             AND crapass.cdcooper = crapcob.cdcooper
             AND crapass.nrdconta = crapcob.nrdconta
           ORDER BY decode(crapret.cdocorre
                          ,6
                          ,DECODE(crapcob.indpagto, 0, crapret.cdocorre, 6.5)
                          ,crapret.cdocorre)
                   ,crapcob.indpagto
                   ,crapret.nrdconta
                   ,crapret.nrdocmto
                   ,nrseqoco;
      
        --Selecionar Titulos Bordero
        CURSOR cr_craptdb(pr_cdcooper IN crapcob.cdcooper%TYPE
                         ,pr_nrdconta IN crapcob.nrdconta%TYPE
                         ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                         ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                         ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                         ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
                         ,pr_insittit IN craptdb.insittit%TYPE) IS
          SELECT craptdb.cdcooper
                ,craptdb.rowid
                ,COUNT(*) over(PARTITION BY craptdb.cdcooper) qtdreg
            FROM craptdb
           WHERE craptdb.cdcooper = pr_cdcooper
             AND craptdb.nrdconta = pr_nrdconta
             AND craptdb.cdbandoc = pr_cdbandoc
             AND craptdb.nrdctabb = pr_nrdctabb
             AND craptdb.nrcnvcob = pr_nrcnvcob
             AND craptdb.nrdocmto = pr_nrdocmto
             AND craptdb.insittit = pr_insittit;
        rw_craptdb cr_craptdb%ROWTYPE;
      
        --Selecionar Ocorrencia
        CURSOR cr_crapoco(pr_cdcooper IN crapoco.cdcooper%TYPE
                         ,pr_cddbanco IN crapoco.cddbanco%TYPE
                         ,pr_cdocorre IN crapoco.cdocorre%TYPE
                         ,pr_tpocorre IN crapoco.tpocorre%TYPE) IS
          SELECT crapoco.dsocorre
            FROM crapoco
           WHERE crapoco.cdcooper = pr_cdcooper
             AND crapoco.cddbanco = pr_cddbanco
             AND crapoco.cdocorre = pr_cdocorre
             AND crapoco.tpocorre = pr_tpocorre;
        rw_crapoco cr_crapoco%ROWTYPE;
      
        --Variaveis Locais
        vr_dsparam   VARCHAR2(100);
        vr_cdocorre  crapoco.cdocorre%TYPE;
        vr_flgquebra BOOLEAN := FALSE;
      
        vr_dshistor VARCHAR2(4000) := NULL;
      BEGIN
        --Inicializar variaveis erro
        pr_cdcritic := NULL;
        pr_dscritic := NULL;
        --Inicializar variavel erro
        vr_cdcritic := 0;
        vr_contador := 1;
        --Posicionar parametros
        vr_nmarquiv := pr_nmarquiv;
      
        -- Preparar o CLOB para armazenar as infos do arquivo
        dbms_lob.createtemporary(vr_clobcri, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clobcri, dbms_lob.lob_readwrite);
      
        --Selecionar Convenios
        FOR rw_crapcco IN cr_crapcco_relat(pr_cdcooper => pr_cdcooper, pr_cddbanco => 85)
        LOOP
        
          --Zerar variaveis
          vr_qttotreg := 0;
          vr_vltotreg := 0;
          vr_vltotdes := 0;
          vr_vltotjur := 0;
          vr_vloutdeb := 0;
          vr_vloutcre := 0;
          vr_vltotpag := 0;
          vr_vltottar := 0;
          vr_qtdregis := 0;
          vr_vlregist := 0;
          vr_vldescon := 0;
          vr_valjuros := 0;
          vr_vloutdeb := 0;
          vr_vloutcre := 0;
          vr_valorpgo := 0;
          vr_vltarifa := 0;
          vr_qtregrec := 0;
          vr_qtregicd := 0;
          vr_vlregicd := 0;
        
          -- Quando for REPROC deve montar o nome do arquivo de forma diferenciada, 
          -- para evitar sobrepor arquivos de outras execuções
        
          vr_nmarqimp := 'crrl605_20201026_' || gene0002.fn_mask(rw_crapcco.nrconven, '9999999') || '_' ||
                         gene0002.fn_mask(vr_contador, '99') || '.lst';
          /*INC0065770
          IF vr_inreproc THEN
            -- Nome arquivo impressao
            vr_nmarqimp := 'crrl605_' || gene0002.fn_mask(rw_crapcco.nrconven, '9999999') || '_' ||
                           gene0002.fn_mask(vr_contador, '99') || '_REP_' || GENE0002.fn_busca_time ||
                           '.lst';
          ELSE
            -- Nome arquivo impressao
            vr_nmarqimp := 'crrl605_' || gene0002.fn_mask(rw_crapcco.nrconven, '9999999') || '_' ||
                           gene0002.fn_mask(vr_contador, '99') || '.lst';
          END IF;
          */
        
          --Incrementar contador
          vr_contador := vr_contador + 1;
          --Marcar como nao rejeitado
          vr_rejeitad := FALSE;
        
          -- Inicializar o CLOB
          dbms_lob.createtemporary(vr_des_xml, TRUE);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
          vr_dstexto := NULL;
          -- Inicilizar as informacoes do XML
          gene0002.pc_escreve_xml(vr_des_xml
                                 ,vr_dstexto
                                 ,'<?xml version="1.0" encoding="utf-8"?><crrl605><lancamentos nmarquiv="' ||
                                  vr_nmarquiv || '" dtmvtolt="' ||
                                  to_char(rw_crapdat.dtmvtolt, 'DD/MM/YYYY') || '" cdagenci="' ||
                                  rw_crapcco.cdagenci || '" cdbccxlt="' || rw_crapcco.cdbccxlt ||
                                  '" nrdolote="' || to_char(rw_crapcco.nrdolote, 'fm999g990') ||
                                  '" tplotmov="' || to_char(vr_tplotmov, 'fm09') || '" nrconven="' ||
                                  to_char(rw_crapcco.nrconven, 'fm00000000') || ' - ' ||
                                  rw_crapcco.dsorgarq || '">');
          -- Retorna nome do modulo logado
          GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
          --Marcar que nao teve lancamentos
          vr_temlancto := FALSE;
          IF vr_typ_craprej_array.FIRST IS NULL THEN
            NULL;
          ELSE
            --Selecionar os rejeitados           
            FOR vr_index_cratrej IN vr_typ_craprej_array.FIRST .. vr_typ_craprej_array.LAST
            LOOP
              --Verificar COOPERATIVA           
              IF vr_typ_craprej_array(vr_index_cratrej).cdcooper = pr_cdcooper THEN
                --Verificar convenio      
                IF SUBSTR(vr_typ_craprej_array(vr_index_cratrej).cdpesqbb, 20, 6) =
                   gene0002.fn_mask(rw_crapcco.nrconven, '999999') THEN
                  --Marcar rejeitado
                  vr_rejeitad := TRUE;
                  vr_cdcritic := vr_typ_craprej_array(vr_index_cratrej).cdcritic;
                  --Se possui erro
                  IF vr_cdcritic = 0 THEN
                    --Descricao Critica
                    -- Variavel não careega então não criada e não utilizada - Chamado 714566 - 11/08/2017
                    --vr_dscritic:= vr_typ_craprej_array(vr_index_cratrej).dshistor;
                    vr_dscritic := NULL;
                  ELSE
                    --Buscar Descricao Critica
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                  END IF;
                
                  -- Caso esteja dentro da lista abaixo
                  IF vr_cdcritic IN (9, 592, 595, 965, 966, 980) THEN
                    -- Monta a mensagem
                    vr_desdados := '50' || TO_CHAR(rw_crapdat.dtmvtolt, 'DDMMRR') || ',' ||
                                   TO_CHAR(rw_crapdat.dtmvtolt, 'DDMMRR') || ',1455,4894,' ||
                                   TO_CHAR(vr_typ_craprej_array(vr_index_cratrej).vllanmto
                                          ,'fm9999999990d00'
                                          ,'NLS_NUMERIC_CHARACTERS=.,') || ',5210,"' ||
                                   GENE0007.fn_caract_acento(UPPER(LTRIM(vr_dscritic
                                                                        ,lpad(vr_cdcritic, 3, 0) ||
                                                                         ' - '))) ||
                                   ' COOPERADO C/C ' ||
                                   GENE0002.fn_mask_conta(vr_typ_craprej_array(vr_index_cratrej).nrdconta) ||
                                   ' (CONFORME CRITICA RELATORIO 605_' ||
                                   GENE0002.fn_mask(vr_contador - 1, '99') || ')"' || chr(10);
                    -- Adiciona a linha ao arquivo de criticas
                    dbms_lob.writeappend(vr_clobcri, length(vr_desdados), vr_desdados);
                  END IF;
                
                  -- Variavel não careega então não criada e não utilizada - Chamado 714566 - 11/08/2017
                  --Determinar se o historico será ou nao mostrado
                  --IF vr_typ_craprej_array(vr_index_cratrej).cdcritic = 922  AND --Boleto pago com cheque 
                  --   trim(vr_typ_craprej_array(vr_index_cratrej).dshistor) IS NOT NULL THEN
                  --  NULL;
                  --ELSE
                  --  vr_typ_craprej_array(vr_index_cratrej).dshistor:= NULL;
                  --END IF;
                
                  --Marcar que tem lancamento
                  vr_temlancto := TRUE;
                  --Montar tag saldo contabil para arquivo XML
                  gene0002.pc_escreve_xml(vr_des_xml
                                         ,vr_dstexto
                                         ,'<lancto>
                  <nrseqdig>' ||
                                          to_char(vr_typ_craprej_array(vr_index_cratrej).nrseqdig
                                                 ,'fm999g990') || '</nrseqdig>
                  <nrdconta>' ||
                                          to_char(vr_typ_craprej_array(vr_index_cratrej).nrdconta
                                                 ,'fm9g999g999g9') || '</nrdconta>
                  <nrdocmto>' ||
                                          to_char(vr_typ_craprej_array(vr_index_cratrej).nrdocmto
                                                 ,'fm999g999g990') || '</nrdocmto>
                  <cdpesqbb>' ||
                                          substr(vr_typ_craprej_array(vr_index_cratrej).cdpesqbb
                                                ,1
                                                ,44) || '</cdpesqbb>
                  <vllanmto>' ||
                                          to_char(vr_typ_craprej_array(vr_index_cratrej).vllanmto
                                                 ,'fm999g999g990d00') ||
                                          '</vllanmto>
                  <cdbccxlt>' ||
                                          gene0002.fn_mask(vr_typ_craprej_array(vr_index_cratrej).cdbccxlt
                                                          ,'zz9') || '</cdbccxlt>
                  <cdagenci>' ||
                                          gene0002.fn_mask(vr_typ_craprej_array(vr_index_cratrej).cdagenci
                                                          ,'zzz9') || '</cdagenci>
                  <dscritic>' ||
                                          substr(vr_dscritic, 1, 54) ||
                                          '</dscritic>
                  <dshistor>' || vr_dshistor ||
                                          '</dshistor>
                </lancto>');
                  -- Variavel não careega então não criada e não utilizada - Chamado 714566 - 11/08/2017
                  -- Subistituida por uma variavel nula ( Motivo IREPORT gerador de relatório )
                  --<dshistor>'||vr_typ_craprej_array(vr_index_cratrej).dshistor||'</dshistor>
                  -- Retorna nome do modulo logado
                  GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
                END IF;
              END IF;
            END LOOP;
          END IF;
        
          --Determinar a data para sustar
          IF pr_nmtelant = 'COMPEFORA' THEN
            vr_dtmvtolt := to_date('26102020', 'ddmmyyyy');
            --INC0065770
            --vr_dtmvtolt := rw_crapdat.dtmvtoan;
          ELSE
            vr_dtmvtolt := rw_crapdat.dtmvtolt;
          END IF;
        
          -- Verifica se ocorreram erros na geracao do TXT
          IF vr_des_erro2 IS NOT NULL THEN
            -- Ajuste log - 15/03/2018 - Chamado 801483 
            vr_cdcritic := 1197;
            vr_dscritic := 'GERACAO DO ' || vr_arqcon || ': ' || vr_des_erro2 ||
                           ' - gene0002.pc_solicita_relato_arquivo';
            RAISE vr_exc_saida;
          END IF;
          -- Retorna nome do modulo logado
          GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
        
          --Inserir tag em branco caso nao tenha lancamentos para permitir a impressao
          --dos atributos da tag lancamentos
          IF NOT vr_temlancto THEN
            gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto, '<lancto></lancto>');
            --Nao imprimir cabecalho
            vr_dsparam := 'PR_IMPRIME##N';
          ELSE
            vr_dsparam := 'PR_IMPRIME##S';
          END IF;
        
          -- Finalizar tag XML
          gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto, '</lancamentos>');
        
          --Determinar a data para sustar
          IF pr_nmtelant = 'COMPEFORA' THEN
            vr_dtmvtaux := to_date('26102020', 'ddmmyyyy');
            --INC0065770
            --vr_dtmvtaux := rw_crapdat.dtmvtoan;
          ELSE
            vr_dtmvtaux := rw_crapdat.dtmvtolt;
          END IF;
          -- Retorna nome do modulo logado
          GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
        
          --Selecionar as Ocorrencias
          FOR rw_crapcre IN cr_crapcre_relat(pr_cdcooper => pr_cdcooper
                                            ,pr_dtmvtolt => vr_dtmvtaux
                                            ,pr_nrconven => rw_crapcco.nrconven
                                            ,pr_intipmvt => 2
                                            ,pr_cddbanco => 85)
          LOOP
          
            -- log relatorio 605
            -- Ajuste controle de Log - Chamado 714566 - 11/08/2017     
            vr_cdcritic := 340;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                           ' relatorio 605, convenio:' || to_char(rw_crapcco.nrconven);
            pc_controla_log_programa(pr_dstiplog => 'O'
                                    ,pr_tpocorre => 4
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_cdcricid => 0);
            vr_cdcritic := NULL;
            vr_dscritic := NULL;
            --Criar tag XML Grupos
            gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto, '<grupos>');
            -- Retorna nome do modulo logado             
            GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
          
            --Percorrer todas as ocorrencias
            FOR rw_crapret IN cr_crapret(pr_cdcooper => rw_crapcre.cdcooper
                                        ,pr_nrcnvcob => rw_crapcre.nrcnvcob
                                        ,pr_dtocorre => rw_crapcre.dtmvtolt
                                        ,pr_nrremret => rw_crapcre.nrremret
                                        ,pr_nrdctabb => rw_crapcre.nrdctabb
                                        ,pr_cdbandoc => rw_crapcre.cddbanco)
            LOOP
            
              --Incrementar qdade registros
              vr_qtdregis := nvl(vr_qtdregis, 0) + 1;
              vr_vlregist := nvl(vr_vlregist, 0) + nvl(rw_crapret.vltitulo, 0);
              vr_vldescon := nvl(vr_vldescon, 0) + nvl(rw_crapret.vldescto, 0) +
                             nvl(rw_crapret.vlabatim, 0);
              vr_valjuros := nvl(vr_valjuros, 0) + nvl(rw_crapret.vljurmul, 0);
              vr_vloutdeb := nvl(vr_vloutdeb, 0) + nvl(rw_crapret.vloutdes, 0);
              vr_vloutcre := nvl(vr_vloutcre, 0) + nvl(rw_crapret.vloutcre, 0);
              vr_valorpgo := nvl(vr_valorpgo, 0) + nvl(rw_crapret.vlrpagto, 0);
              vr_vltarifa := nvl(vr_vltarifa, 0) + nvl(rw_crapret.vltarass, 0);
            
              /* liquidacao e liquidacao apos baixa */
              IF rw_crapret.cdocorre IN (6, 17, 76, 77) THEN
                --Incrementar quantidade recebida
                vr_qtregrec := nvl(vr_qtregrec, 0) + 1;
                --Incrementar valor recebido
                vr_vlregrec := nvl(vr_vlregrec, 0) + nvl(rw_crapret.vlrpagto, 0);
                /* busca por titulo descontado pago */
                OPEN cr_craptdb(pr_cdcooper => rw_crapret.cdcooper
                               ,pr_nrdconta => rw_crapret.nrdconta
                               ,pr_cdbandoc => rw_crapret.cdbandoc
                               ,pr_nrdctabb => rw_crapret.nrdctabb
                               ,pr_nrcnvcob => rw_crapret.nrcnvcob
                               ,pr_nrdocmto => rw_crapret.nrdocmto
                               ,pr_insittit => 2); /* pago */
                FETCH cr_craptdb
                  INTO rw_craptdb;
                --Se encontrou e achou somente 1
                IF cr_craptdb%FOUND THEN
                  --IF rw_craptdb.qtdreg = 1 THEN
                  /* totais de registros integrados */
                  vr_qtregicd := nvl(vr_qtregicd, 0) + 1;
                  vr_vlregicd := nvl(vr_vlregicd, 0) + nvl(rw_crapret.vlrpagto, 0);
                  --END IF;
                END IF;
                --Fechar Cursor
                CLOSE cr_craptdb;
              END IF;
              --Se for Ultimo crapcob.indpagto
              IF rw_crapret.nrseqind = rw_crapret.nrtotind THEN
                IF rw_crapret.cdocorre IN (6, 76) AND rw_crapret.indpagto = 0 THEN
                  vr_flgquebra := TRUE;
                END IF;
              END IF;
              --Se for o Ultimo crapret.cdocorre ou quebrou
              IF rw_crapret.nrseqoco = rw_crapret.nrtotoco OR vr_flgquebra THEN
                --Selecionar Ocorrencias
                OPEN cr_crapoco(pr_cdcooper => rw_crapret.cdcooper
                               ,pr_cddbanco => rw_crapret.cdbandoc
                               ,pr_cdocorre => rw_crapret.cdocorre
                               ,pr_tpocorre => 2); /* Retorno */
                FETCH cr_crapoco
                  INTO rw_crapoco;
                --Se Encontrou
                IF cr_crapoco%FOUND THEN
                  IF (rw_crapret.indpagto > 0 AND rw_crapret.cdocorre IN (6, 76)) THEN
                    vr_dsocorre := rw_crapoco.dsocorre || ' (COOP)';
                  ELSE
                    vr_dsocorre := rw_crapoco.dsocorre;
                  END IF;
                END IF;
                --Fechar Cursor
                CLOSE cr_crapoco;
              
                --Montar tag saldo contabil para arquivo XML
                gene0002.pc_escreve_xml(vr_des_xml
                                       ,vr_dstexto
                                       ,'<grupo>
                     <cdocorre>' ||
                                        gene0002.fn_mask(rw_crapret.cdocorre, 'z9') ||
                                        '</cdocorre>
                     <dsocorre>' ||
                                        substr(vr_dsocorre, 1, 60) ||
                                        '</dsocorre>
                     <qtdregis>' || vr_qtdregis ||
                                        '</qtdregis>
                     <vlregist>' ||
                                        to_char(vr_vlregist, 'fm999g999g9990d00') ||
                                        '</vlregist>
                     <vldescon>' ||
                                        to_char(vr_vldescon, 'fm999g999g9990d00') ||
                                        '</vldescon>
                     <valjuros>' ||
                                        to_char(vr_valjuros, 'fm999g999g9990d00') ||
                                        '</valjuros>
                     <vloutdeb>' ||
                                        to_char(vr_vloutdeb, 'fm999g999g9990d00') ||
                                        '</vloutdeb>
                     <vloutcre>' ||
                                        to_char(vr_vloutcre, 'fm999g999g9990d00') ||
                                        '</vloutcre>
                     <valorpgo>' ||
                                        to_char(vr_valorpgo, 'fm999g999g9990d00') ||
                                        '</valorpgo>
                     <vltarifa>' ||
                                        to_char(vr_vltarifa, 'fm999g999g9990d00') ||
                                        '</vltarifa>
                   </grupo>');
                -- Retorna nome do modulo logado
                GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
              
                --Acumular Totais
                vr_qttotreg := nvl(vr_qttotreg, 0) + nvl(vr_qtdregis, 0);
                vr_vltotreg := nvl(vr_vltotreg, 0) + nvl(vr_vlregist, 0);
                vr_vltotdes := nvl(vr_vltotdes, 0) + nvl(vr_vldescon, 0);
                vr_vltotjur := nvl(vr_vltotjur, 0) + nvl(vr_valjuros, 0);
                vr_vloutdeb := nvl(vr_vloutdeb, 0) + nvl(vr_vloutdeb, 0);
                vr_vloutcre := nvl(vr_vloutcre, 0) + nvl(vr_vloutcre, 0);
                vr_vltotpag := nvl(vr_vltotpag, 0) + nvl(vr_valorpgo, 0);
                vr_vltottar := nvl(vr_vltottar, 0) + nvl(vr_vltarifa, 0);
                --Zerar Variaveis
                vr_qtdregis  := 0;
                vr_vlregist  := 0;
                vr_vldescon  := 0;
                vr_valjuros  := 0;
                vr_vloutdeb  := 0;
                vr_vloutcre  := 0;
                vr_valorpgo  := 0;
                vr_vltarifa  := 0;
                vr_flgquebra := FALSE;
              END IF;
            END LOOP; --rw_crapret
          
            -- Finalizar tag XML
            gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto, '</grupos><analitico>');
            -- Retorna nome do modulo logado
            GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
          
            --Quantidade total registros
            vr_qttotreg  := 0;
            vr_vltotreg  := 0;
            vr_vltotdes  := 0;
            vr_vltotjur  := 0;
            vr_vloutdeb  := 0;
            vr_vloutcre  := 0;
            vr_vltotpag  := 0;
            vr_vltottar  := 0;
            vr_flgquebra := FALSE;
          
            --Selecionar retornos
            FOR rw_crapret IN cr_crapret_2(pr_cdcooper => rw_crapcre.cdcooper
                                          ,pr_nrcnvcob => rw_crapcre.nrcnvcob
                                          ,pr_dtocorre => rw_crapcre.dtmvtolt
                                          ,pr_nrremret => rw_crapcre.nrremret
                                          ,pr_nrdctabb => rw_crapcre.nrdctabb
                                          ,pr_cddbanco => rw_crapcre.cddbanco)
            LOOP
            
              --Se for primeira ocorrencia
              IF rw_crapret.nrseqoco = 1 THEN
                --Se for liquidacao coop
                IF rw_crapret.cdocorre = 6.5 THEN
                  vr_cdocorre := 6;
                ELSE
                  vr_cdocorre := rw_crapret.cdocorre;
                END IF;
                --Selecionar Ocorrencias
                OPEN cr_crapoco(pr_cdcooper => rw_crapret.cdcooper
                               ,pr_cddbanco => rw_crapret.cdbandoc
                               ,pr_cdocorre => vr_cdocorre
                               ,pr_tpocorre => 2); /* Retorno */
                FETCH cr_crapoco
                  INTO rw_crapoco;
                --Montar Descricao da Ocorrencia
                IF rw_crapret.cdocorre = 6.5 THEN
                  vr_dsocorre := rw_crapoco.dsocorre || ' (COOP)';
                ELSE
                  vr_dsocorre := rw_crapoco.dsocorre;
                END IF;
                --Fechar Cursor
                CLOSE cr_crapoco;
                --Abrir tag ocorrencias
                gene0002.pc_escreve_xml(vr_des_xml
                                       ,vr_dstexto
                                       ,'<ocorrencias cdocorre="' || vr_cdocorre || '" dsocorre="' ||
                                        vr_dsocorre || '">');
                -- Retorna nome do modulo logado
                GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
              END IF;
            
              --Titulo nao descontado
              vr_dstitdsc := NULL;
              /* busca por titulo descontado pago */
              OPEN cr_craptdb(pr_cdcooper => rw_crapret.cdcooper
                             ,pr_nrdconta => rw_crapret.nrdconta
                             ,pr_cdbandoc => rw_crapret.cdbandoc
                             ,pr_nrdctabb => rw_crapret.nrdctabb
                             ,pr_nrcnvcob => rw_crapret.nrcnvcob
                             ,pr_nrdocmto => rw_crapret.nrdocmto
                             ,pr_insittit => 2); /* pago */
              FETCH cr_craptdb
                INTO rw_craptdb;
              --Se encontrou
              IF cr_craptdb%FOUND AND rw_craptdb.qtdreg = 1 THEN
                --IF cr_craptdb%FOUND THEN
                --Marcar como titulo descontado
                vr_dstitdsc := 'TD';
              END IF;
              --Fechar Cursor
              CLOSE cr_craptdb;
              --Acumuladores
              vr_qttotreg := nvl(vr_qttotreg, 0) + 1;
              vr_vltotreg := nvl(vr_vltotreg, 0) + nvl(rw_crapret.vltitulo, 0);
              vr_vldescon := nvl(rw_crapret.vldescto, 0) + nvl(rw_crapret.vlabatim, 0);
              vr_vltotdes := nvl(vr_vltotdes, 0) + vr_vldescon;
              vr_vltotjur := nvl(vr_vltotjur, 0) + nvl(rw_crapret.vljurmul, 0);
              vr_vloutdeb := nvl(vr_vloutdeb, 0) + nvl(rw_crapret.vloutdes, 0);
              vr_vloutcre := nvl(vr_vloutcre, 0) + nvl(rw_crapret.vloutcre, 0);
              vr_vltotpag := nvl(vr_vltotpag, 0) + nvl(rw_crapret.vlrpagto, 0);
              vr_vltottar := nvl(vr_vltottar, 0) + nvl(rw_crapret.vltarass, 0);
              --Pagamento ocorreu na cooperativa
              IF (rw_crapret.cdbanpag = 11 AND rw_crapret.cdagepag = 0) THEN
                vr_bancoage := 'COOP.';
              ELSE
                vr_bancoage := rw_crapret.cdbanpag || '/' || rw_crapret.cdagepag;
              END IF;
              /** Dados **/
              --Listar Motivos
              vr_dsmotrel := fn_lista_motivos(pr_dsmotivo => rw_crapret.cdmotivo
                                             ,pr_cddbanco => rw_crapcre.cddbanco
                                             ,pr_cdocorre => vr_cdocorre);
            
              --Montar tag saldo contabil para arquivo XML
              gene0002.pc_escreve_xml(vr_des_xml
                                     ,vr_dstexto
                                     ,'<oco>
                   <cdagenci>' ||
                                      gene0002.fn_mask(rw_crapret.cdagenci, 'zz9') ||
                                      '</cdagenci>
                   <nrdconta>' ||
                                      to_char(rw_crapret.nrdconta, 'fm9g999g999g9') ||
                                      '</nrdconta>
                   <nrdocmto>' ||
                                      to_char(rw_crapret.nrdocmto, 'fm999g999g990') ||
                                      '</nrdocmto>
                   <dstitdsc>' || vr_dstitdsc ||
                                      '</dstitdsc>
                   <dsdoccop>' || rw_crapret.dsdoccop ||
                                      '</dsdoccop>
                   <dtvencto>' ||
                                      to_char(rw_crapret.dtvencto, 'DD/MM/YY') ||
                                      '</dtvencto>
                   <vltitulo>' ||
                                      to_char(rw_crapret.vltitulo, 'fm999g999g990d00') ||
                                      '</vltitulo>
                   <vldescon>' ||
                                      to_char(vr_vldescon, 'fm999g999g990d00') ||
                                      '</vldescon>
                   <vljurmul>' ||
                                      to_char(rw_crapret.vljurmul, 'fm999g999g990d00') ||
                                      '</vljurmul>
                   <vloutdes>' ||
                                      to_char(rw_crapret.vloutdes, 'fm999g999g990d00') ||
                                      '</vloutdes>
                   <vloutcre>' ||
                                      to_char(rw_crapret.vloutcre, 'fm999g999g990d00') ||
                                      '</vloutcre>
                   <vlrpagto>' ||
                                      to_char(rw_crapret.vlrpagto, 'fm999g999g990d00') ||
                                      '</vlrpagto>
                   <dtcredit>' ||
                                      to_char(rw_crapret.dtcredit, 'DD/MM/YY') ||
                                      '</dtcredit>
                   <bancoage>' || vr_bancoage ||
                                      '</bancoage>
                   <vltarass>' ||
                                      to_char(rw_crapret.vltarass, 'fm999g999g990d00') ||
                                      '</vltarass>
                   <dsmotrel>' || SUBSTR(vr_dsmotrel, 1, 45) ||
                                      '</dsmotrel>
                   <dtdocmto>' ||
                                      to_char(rw_crapret.dtdocmto, 'DD/MM/YY') ||
                                      '</dtdocmto>
                   <qtdfloat>' ||
                                      to_char(rw_crapret.qtdfloat, 'fm99') ||
                                      '</qtdfloat>
                 </oco>');
            
              /* Totais */
              --Se for a ultima ocorrencia
              IF rw_crapret.nrseqoco = rw_crapret.nrtotoco THEN
                --Abrir tag ocorrencias
                gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto, '</ocorrencias>');
                --Zerar Variaveis
                vr_qttotreg := 0;
                vr_vltotreg := 0;
                vr_vltotdes := 0;
                vr_vltotjur := 0;
                vr_vloutdeb := 0;
                vr_vloutcre := 0;
                vr_vltotpag := 0;
                vr_vltottar := 0;
              END IF;
              -- Retorna nome do modulo logado
              GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
            END LOOP;
          
            --Totalizador final do relatorio
            vr_qtregisd := nvl(vr_qtregrec, 0) - nvl(vr_qtregicd, 0);
            vr_vlregisd := nvl(vr_vlregrec, 0) - nvl(vr_vlregicd, 0);
          
            -- Finalizar tag XML
            gene0002.pc_escreve_xml(vr_des_xml
                                   ,vr_dstexto
                                   ,'<total>
                 <qtregrec>' ||
                                    to_char(nvl(vr_qtregrec, 0), 'fm999g999g990') ||
                                    '</qtregrec>
                 <qtregicd>' ||
                                    to_char(nvl(vr_qtregicd, 0), 'fm999g999g990') ||
                                    '</qtregicd>
                 <qtregisd>' ||
                                    to_char(nvl(vr_qtregisd, 0), 'fm999g999g990') ||
                                    '</qtregisd>
                 <qtregrej>' ||
                                    to_char(nvl(vr_qtregrej, 0), 'fm999g999g990') ||
                                    '</qtregrej>
                 <vlregrec>' ||
                                    to_char(nvl(vr_vlregrec, 0), 'fm999g999g990d00') ||
                                    '</vlregrec>
                 <vlregicd>' ||
                                    to_char(nvl(vr_vlregicd, 0), 'fm999g999g990d00') ||
                                    '</vlregicd>
                 <vlregisd>' ||
                                    to_char(nvl(vr_vlregisd, 0), 'fm999g999g990d00') ||
                                    '</vlregisd>
                 <vlregrej>' ||
                                    to_char(nvl(vr_vlregrej, 0), 'fm999g999g990d00') ||
                                    '</vlregrej>
               </total></analitico>');
            -- Retorna nome do modulo logado
            GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
          
          END LOOP; --rw_crapcre
        
          -- Finalizar tag XML do relatorio
          gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto, '</crrl605>', TRUE);
          -- Retorna nome do modulo logado
          GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
        
          -- Efetuar solicitacao de geracao de relatorio crrl605 --
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl605' --> N? base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl605.jasper' --> Arquivo de layout do iReport
                                     ,pr_dsparams  => vr_dsparam --> Titulo do relat?rio
                                     ,pr_dsarqsaid => vr_caminho_rl || '/' || vr_nmarqimp --> Arquivo final
                                     ,pr_qtcoluna  => 234 --> 234 colunas
                                     ,pr_cdrelato  => 605 --> Codigo fixo do relatorio
                                     ,pr_sqcabrel  => 1 --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                     ,pr_flg_impri => 'S' --> Chamar a impress?o (Imprim.p)
                                     ,pr_nmformul  => '234dh' --> Nome do formul?rio para impress?o
                                     ,pr_nrcopias  => 1 --> N?mero de c?pias
                                     ,pr_flg_gerar => 'N' --> gerar PDF
                                     ,pr_des_erro  => vr_dscritic); --> Sa?da com erro
          -- Testar se houve erro
          IF vr_dscritic IS NOT NULL THEN
            -- Ajuste log - 15/03/2018 - Chamado 801483 
            vr_cdcritic := 1197;
            vr_dscritic := vr_dscritic || ' - gene0002.pc_solicita_relato';
            -- Gerar excecao
            RAISE vr_exc_saida;
          END IF;
          -- Retorna nome do modulo logado
          GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
        
          -- Liberando a mem?ria alocada pro CLOB
          dbms_lob.close(vr_des_xml);
          dbms_lob.freetemporary(vr_des_xml);
          vr_dstexto := NULL;
        END LOOP; --rw_crapcco
      
        -- Se possuir conteudo de critica no CLOB
        IF LENGTH(vr_clobcri) > 0 THEN
          -- Busca o diretório para contabilidade
          vr_dircon := gene0001.fn_param_sistema('CRED', vc_cdtodascooperativas, vc_cdacesso);
          vr_dircon := vr_dircon || vc_dircon;
          vr_arqcon := TO_CHAR(vr_dtmvtolt, 'RRMMDD') || '_' || LPAD(TO_CHAR(pr_cdcooper), 2, 0) ||
                       '_CRITICAS_605.txt';
        
          -- Chama a geracao do TXT
          GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                                             ,pr_cdprogra  => vr_cdprogra --> Programa chamador
                                             ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                             ,pr_dsxml     => vr_clobcri --> Arquivo XML de dados
                                             ,pr_dsarqsaid => vr_caminho_puro || '/contab/' ||
                                                              vr_arqcon --> Arquivo final com o path
                                             ,pr_cdrelato  => NULL --> Código fixo para o relatório
                                             ,pr_flg_gerar => 'N' --> Apenas submeter
                                             ,pr_dspathcop => vr_dircon
                                             ,pr_fldoscop  => 'S'
                                             ,pr_des_erro  => vr_des_erro2); --> Saída com erro
          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_clobcri);
          dbms_lob.freetemporary(vr_clobcri);
        
        END IF;
      
        -- Ajuste log - 15/03/2018 - Chamado 801483          
        --Escrever mensagem no Log
        IF vr_rejeitad THEN
          vr_cdcritic := 191;
          --Montar Mensagem Critica
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          -- Gerar excecao
          RAISE vr_exc_saida;
        ELSE
          vr_cdcritic := 190;
          --Montar Mensagem Critica
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' - ' ||
                         vr_nmarquiv;
          pc_controla_log_programa(pr_dstiplog => 'O'
                                  ,pr_tpocorre => 4
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        END IF;
      
      EXCEPTION
        --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
        WHEN vr_exc_saida THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic || ' pc_gera_relatorio_605';
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 9999;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                         ' pc_gera_relatorio_605 - ' || SQLERRM;
      END pc_gera_relatorio_605;
    
      -- Gera Relatorio 686
      PROCEDURE pc_gera_relatorio_686(pr_nmtelant IN VARCHAR2
                                     ,pr_cdcritic OUT INTEGER
                                     ,pr_dscritic OUT VARCHAR2) IS
      
        CURSOR cr_crapret_relat(pr_cdcooper IN crapret.cdcooper%TYPE
                               ,pr_dtdpagto IN crapret.dtocorre%TYPE) IS
          SELECT ret.nrcnvcob
                ,cco.dsorgarq
                ,ceb.qtdfloat
                ,COUNT(*) qtdregis
                ,SUM(ret.vlrpagto) vltotpag
                ,ret.dtcredit
            FROM crapret ret
                ,crapceb ceb
                ,crapcco cco
           WHERE ret.cdcooper = pr_cdcooper
             AND ret.dtocorre = pr_dtdpagto
             AND ceb.cdcooper = ret.cdcooper
             AND ceb.nrconven = ret.nrcnvcob
             AND ceb.nrdconta = ret.nrdconta
             AND ret.dtcredit IS NOT NULL
             AND ret.cdocorre IN (6, 17, 76, 77)
             AND ret.vlrpagto < 250000
             AND cco.cdcooper = ret.cdcooper
             AND cco.nrconven = ret.nrcnvcob
             AND cco.cddbanco = 85
           GROUP BY ceb.qtdfloat
                   ,cco.qtdfloat
                   ,cco.dsorgarq
                   ,ret.nrcnvcob
                   ,ret.dtcredit
           ORDER BY ceb.qtdfloat
                   ,cco.qtdfloat
                   ,ret.nrcnvcob;
      
        /* Buscar saldo pendentes do float */
        CURSOR cr_crapret_sld(pr_cdcooper IN crapret.cdcooper%TYPE
                             ,pr_dtdpagto IN crapret.dtocorre%TYPE
                             ,pr_dtmvtopr IN crapret.dtocorre%TYPE) IS
          SELECT ret.dtocorre
                ,ret.dtcredit
                ,ret.nrcnvcob
                ,ceb.qtdfloat
                ,COUNT(*) qtdregis
                ,SUM(ret.vlrpagto) vltotpag
            FROM crapret ret
                ,crapceb ceb
                ,crapcco cco
           WHERE ret.cdcooper = pr_cdcooper
             AND ret.dtocorre < pr_dtdpagto -- Eliminar os registros mostrados acima
             AND ret.dtcredit BETWEEN pr_dtmvtopr AND (pr_dtmvtopr + 10)
             AND ret.cdocorre IN (6, 17, 76, 77)
             AND ret.vlrpagto < 250000
             AND cco.cdcooper = ret.cdcooper
             AND cco.nrconven = ret.nrcnvcob
             AND ceb.cdcooper = ret.cdcooper
             AND ceb.nrconven = ret.nrcnvcob
             AND ceb.nrdconta = ret.nrdconta
             AND cco.cddbanco = 85
          --   AND ret.flcredit = 0
           GROUP BY ret.dtocorre
                   ,ret.dtcredit
                   ,ret.nrcnvcob
                   ,ceb.qtdfloat
           ORDER BY ceb.qtdfloat
                   ,ret.dtocorre
                   ,ret.dtcredit
                   ,ret.nrcnvcob;
      
        vr_dtdpagto_rel  DATE;
        vr_aux_float     INTEGER;
        vr_aux_float_sld INTEGER;
        vr_vlsldpen      crapret.vlrpagto%TYPE := 0;
        vr_aux_contador  NUMBER := 0;
      
      BEGIN
      
        IF pr_nmtelant = 'COMPEFORA' THEN
          --Dia Anterior
          vr_dtdpagto_rel := to_date('26102020', 'ddmmyyyy');
          --INC0065770
          --vr_dtdpagto_rel := rw_crapdat.dtmvtoan;
        ELSE
          --Data Atual
          vr_dtdpagto_rel := rw_crapdat.dtmvtolt;
        END IF;
      
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        vr_dstexto := NULL;
      
        -- Inicilizar as informacoes do XML
        gene0002.pc_escreve_xml(vr_des_xml
                               ,vr_dstexto
                               ,'<?xml version="1.0" encoding="utf-8"?><crrl686><lancamentos' ||
                                ' dtmvtolt="' || to_char(rw_crapdat.dtmvtolt, 'DD/MM/YYYY') || '">');
        -- Retorna nome do modulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
      
        vr_aux_float := NULL;
      
        --Selecionar Convenios
        FOR rw_crapret IN cr_crapret_relat(pr_cdcooper => pr_cdcooper
                                          ,pr_dtdpagto => vr_dtdpagto_rel)
        LOOP
        
          IF (vr_aux_float IS NOT NULL) AND (rw_crapret.qtdfloat <> vr_aux_float) THEN
            gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto, '</float>');
            -- Retorna nome do modulo logado
            GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
          END IF;
        
          IF (rw_crapret.qtdfloat <> vr_aux_float) OR (vr_aux_float IS NULL) THEN
            gene0002.pc_escreve_xml(vr_des_xml
                                   ,vr_dstexto
                                   ,'<float qtdddias="' || to_char(rw_crapret.qtdfloat) || '"
                     flsldpen="N" >');
            -- Retorna nome do modulo logado
            GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
            vr_aux_float := rw_crapret.qtdfloat;
          END IF;
        
          gene0002.pc_escreve_xml(vr_des_xml
                                 ,vr_dstexto
                                 ,'<convenio>
              <nrcnvcob>' || to_char(rw_crapret.nrcnvcob) ||
                                  '</nrcnvcob>
              <qtdfloat>' || to_char(rw_crapret.qtdfloat) ||
                                  '</qtdfloat>
              <qtdregis>' || to_char(rw_crapret.qtdregis) ||
                                  '</qtdregis>
              <vltotpag>' ||
                                  to_char(rw_crapret.vltotpag, 'fm999g999g990d00') ||
                                  '</vltotpag>
              <dtcredit>' ||
                                  to_char(rw_crapret.dtcredit, 'DD/MM/RRRR') ||
                                  '</dtcredit>
              <dtocorre>' ||
                                  to_char(vr_dtdpagto_rel, 'DD/MM/RRRR') ||
                                  '</dtocorre>
            </convenio>');
          -- Retorna nome do modulo logado
          GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
        
          IF rw_crapret.qtdfloat > 0 THEN
            vr_vlsldpen := vr_vlsldpen + rw_crapret.vltotpag;
          END IF;
        
        END LOOP;
      
        vr_aux_float_sld := NULL;
      
        --Buscar saldo pendente dopfloat para o relatorio
        FOR rw_crapret IN cr_crapret_sld(pr_cdcooper => pr_cdcooper
                                        ,pr_dtdpagto => vr_dtdpagto_rel
                                        ,pr_dtmvtopr => to_date('27102020', 'ddmmyyyy'))
        --INC0065770
        --,pr_dtmvtopr => rw_crapdat.dtmvtopr)
        LOOP
        
          vr_aux_contador := vr_aux_contador + 1;
        
          IF vr_aux_contador = 1 THEN
            -- Finalizar tag XML
            IF (vr_aux_float IS NOT NULL) THEN
              -- finalizar apenas se a variavel recebeu valor dentro do cursor
              gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto, '</float>');
              -- Retorna nome do modulo logado
              GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
            END IF;
          END IF;
        
          IF (vr_aux_float_sld IS NOT NULL) AND (rw_crapret.qtdfloat <> vr_aux_float_sld) THEN
            gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto, '</float>');
            -- Retorna nome do modulo logado
            GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
          END IF;
        
          IF (rw_crapret.qtdfloat <> vr_aux_float_sld) OR (vr_aux_float_sld IS NULL) THEN
            gene0002.pc_escreve_xml(vr_des_xml
                                   ,vr_dstexto
                                   ,'<float qtdddias="' || to_char(rw_crapret.qtdfloat) ||
                                    '" flsldpen="S" >');
            -- Retorna nome do modulo logado
            GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
            vr_aux_float_sld := rw_crapret.qtdfloat;
          END IF;
        
          gene0002.pc_escreve_xml(vr_des_xml
                                 ,vr_dstexto
                                 ,'<convenio>
          <nrcnvcob>' || to_char(rw_crapret.nrcnvcob) ||
                                  '</nrcnvcob>
          <qtdfloat>' || to_char(rw_crapret.qtdfloat) ||
                                  '</qtdfloat>
          <qtdregis>' || to_char(rw_crapret.qtdregis) ||
                                  '</qtdregis>
          <vltotpag>' ||
                                  to_char(rw_crapret.vltotpag, 'fm999g999g990d00') ||
                                  '</vltotpag>
          <dtcredit>' ||
                                  to_char(rw_crapret.dtcredit, 'DD/MM/RRRR') ||
                                  '</dtcredit>
          <dtocorre>' ||
                                  to_char(rw_crapret.dtocorre, 'DD/MM/RRRR') ||
                                  '</dtocorre>
        </convenio>');
          -- Retorna nome do modulo logado
          GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
        
          IF rw_crapret.qtdfloat > 0 THEN
            vr_vlsldpen := vr_vlsldpen + rw_crapret.vltotpag;
          END IF;
        
        END LOOP;
      
        IF (vr_aux_contador = 0 AND (vr_aux_float IS NOT NULL)) OR (vr_aux_float_sld IS NOT NULL) THEN
          -- Finalizar tag XML
          IF (vr_aux_float IS NOT NULL) THEN
            gene0002.pc_escreve_xml(vr_des_xml
                                   ,vr_dstexto
                                   ,'<convenio>
        <tot_vlsldpen>' ||
                                    to_char(vr_vlsldpen, 'fm999g999g990d00') || '</tot_vlsldpen>
      </convenio>');
            -- Retorna nome do modulo logado
            GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
            -- finalizar apenas se a variavel recebeu valor dentro do cursor
            gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto, '</float>');
            -- Retorna nome do modulo logado
            GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
          END IF;
        END IF;
      
        -- Finalizar tag XML
        gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto, '</lancamentos>');
      
        -- Finalizar tag XML do relatorio
        gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto, '</crrl686>', TRUE);
        -- Retorna nome do modulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
      
        -- Busca o diretorio da cooperativa conectada
        vr_caminho_rl := gene0001.fn_diretorio(pr_tpdireto => 'C' --> usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => 'rl');
        -- Retorna nome do modulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
      
        -- Quando for REPROC deve montar o nome do arquivo de forma diferenciada, 
        -- para evitar sobrepor arquivos de outras execuções
        vr_nmarqimp := 'crrl686_20201026.lst';
        /*inc0065770
        IF vr_inreproc THEN
          vr_nmarqimp := 'crrl686_REP_' || GENE0002.fn_busca_time() || '.lst';
        ELSE
          vr_nmarqimp := 'crrl686.lst';
        END IF;
        */
      
        -- Efetuar solicitacao de geracao de relatorio crrl686 --
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl686/lancamentos/float/convenio' --> Na base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl686.jasper' --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL --> Titulo do relatorio
                                   ,pr_dsarqsaid => vr_caminho_rl || '/' || vr_nmarqimp --> Arquivo final
                                   ,pr_qtcoluna  => 234 --> 234 colunas
                                   ,pr_cdrelato  => 686 --> Codigo fixo do relatorio
                                   ,pr_sqcabrel  => 1 --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                   ,pr_flg_impri => 'S' --> Chamar a impressao (Imprim.p)
                                   ,pr_nmformul  => '234dh' --> Nome do formulario para impress?o
                                   ,pr_nrcopias  => 1 --> Número de cópias
                                   ,pr_flg_gerar => 'S' --> gerar PDF
                                   ,pr_des_erro  => vr_dscritic); --> Sa?da com erro
      
        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          -- Ajuste log - 15/03/2018 - Chamado 801483
          -- Gerar excecao 
          vr_cdcritic := 1197;
          vr_dscritic := vr_dscritic || ' - gene0002.pc_solicita_relato';
          RAISE vr_exc_saida;
        END IF;
        -- Retorna nome do modulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
      
        -- Liberando a memoria alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        vr_dstexto := NULL;
      
      EXCEPTION
        --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
        WHEN vr_exc_saida THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic || ' pr_nmtelant:' || pr_nmtelant || ', pc_gera_relatorio_686';
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 9999;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) || ' pr_nmtelant:' ||
                         pr_nmtelant || ', pc_gera_relatorio_686 - ' || SQLERRM;
      END pc_gera_relatorio_686;
    
      -- Excluida pr_dtmvtolt pois não necessaria - 15/03/2018 - Chamado 801483                                             
      --atualiza protesto baixa 
      PROCEDURE pc_atualiza_protesto_baixa(pr_cdcooper IN crapcop.cdcooper%TYPE
                                          ,pr_cdcritic OUT INTEGER
                                          ,pr_dscritic OUT VARCHAR2) IS
        --Selecionar informacoes convenios ativos
        CURSOR cr_crapcco_ativo(pr_cdcooper IN crapcco.cdcooper%TYPE
                               ,pr_cddbanco IN crapcco.cddbanco%TYPE) IS
          SELECT crapcco.cdcooper
                ,crapcco.nrconven
                ,crapcco.nrdctabb
                ,crapcco.cddbanco
                ,crapcco.cdagenci
                ,crapcco.cdbccxlt
                ,crapcco.nrdolote
                ,crapcco.dsorgarq
            FROM crapcco
           WHERE crapcco.cdcooper = pr_cdcooper
             AND crapcco.cddbanco = pr_cddbanco
             AND crapcco.flgregis = 1;
      
        --Selecionar titulos para protesto
        CURSOR cr_crapcob_prot(pr_cdcooper IN crapcco.cdcooper%TYPE
                              ,pr_nrconven IN crapcco.nrconven%TYPE
                              ,pr_dtvencto IN crapcob.dtvencto%TYPE
                              ,pr_incobran IN crapcob.incobran%TYPE
                              ,pr_qtdiaprt IN crapcob.qtdiaprt%TYPE) IS
          SELECT crapcob.dtvencto
                ,crapcob.qtdiaprt
                ,crapcob.nrdconta
                ,crapcob.nrcnvcob
                ,crapcob.nrdocmto
                ,crapcob.cdtpinsc
                ,crapcob.flgdprot
                ,crapcob.flgregis
                ,crapcob.dtmvtolt
                ,crapcob.flgcbdda
                ,crapcob.cdcooper
                ,crapcob.inserasa
                ,crapceb.qtdecprz
                ,crapcob.rowid
            FROM crapcob
                ,crapceb
           WHERE crapceb.cdcooper = pr_cdcooper
             AND crapceb.nrconven = pr_nrconven
             AND crapcob.cdcooper = crapceb.cdcooper
             AND crapcob.nrdconta = crapceb.nrdconta
             AND crapcob.nrcnvcob = crapceb.nrconven
             AND crapcob.dtvencto = pr_dtvencto
             AND crapcob.qtdiaprt = pr_qtdiaprt
             AND crapcob.incobran = 0
             AND crapcob.insitcrt = 0; -- boletos sem instrucao de protesto comandada
      
        --Selecionar titulos baixa decurso prazo
        CURSOR cr_crapcob_aberto(pr_cdcooper IN crapcco.cdcooper%TYPE
                                ,pr_nrconven IN crapcco.nrconven%TYPE
                                ,pr_dtlipgto IN crapcob.dtlipgto%TYPE
                                ,pr_incobran IN crapcob.incobran%TYPE) IS
          SELECT crapcob.dtvencto
                ,crapcob.qtdiaprt
                ,crapcob.nrdconta
                ,crapcob.nrcnvcob
                ,crapcob.nrdocmto
                ,crapcob.cdtpinsc
                ,crapcob.flgdprot
                ,crapcob.flgregis
                ,crapcob.dtmvtolt
                ,crapcob.flgcbdda
                ,crapcob.cdcooper
                ,crapcob.inserasa
                ,crapcob.insitcrt
                ,crapceb.qtdecprz
                ,crapcob.rowid
            FROM crapcob
                ,crapceb
           WHERE crapceb.cdcooper = pr_cdcooper
             AND crapceb.nrconven = pr_nrconven
             AND crapcob.cdcooper = crapceb.cdcooper
             AND crapcob.nrdconta = crapceb.nrdconta
             AND crapcob.nrcnvcob = crapceb.nrconven
             AND crapcob.dtlipgto <= pr_dtlipgto
             AND crapcob.incobran = pr_incobran;
      
      BEGIN
      
        vr_cdoperad := '1';
      
        -- Não deve executar o 2o processamento quando for execução de arquivo REPROC (Renato Darosci - 11/10/2016)
      
        IF NOT vr_inreproc THEN
        
          -- Busca todos os convenios da IF CECRED que foram gerados pela internet
          FOR rw_crapcco IN cr_crapcco_ativo(pr_cdcooper => rw_crapcop.cdcooper
                                            ,pr_cddbanco => rw_crapcop.cdbcoctl)
          LOOP
          
            -- Ajuste log - 15/03/2018 - Chamado 801483
            vr_cdcritic := 1200; -- Processando baixas e protestos  : convenio 
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' convenio:' ||
                           to_char(rw_crapcco.nrconven);
            -- Incluido controle de Log - Chamado 714566 - 11/08/2017  
            pc_controla_log_programa(pr_dstiplog => 'O'
                                    ,pr_tpocorre => 4
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_cdcricid => 0);
            vr_cdcritic := NULL;
            vr_dscritic := NULL;
          
            IF pr_nmtelant = 'COMPEFORA' THEN
              --Data Atual
              --INC0065770
              --vr_dtmvtaux := rw_crapdat.dtmvtoan;
              --vr_dtmvtpro := rw_crapdat.dtmvtolt;
              vr_dtmvtaux := to_date('26102020', 'ddmmyyyy');
              vr_dtmvtpro := rw_crapdat.dtmvtolt;
            ELSE
              --Proximo Dia Util
              vr_dtmvtaux := rw_crapdat.dtmvtolt;
              vr_dtmvtpro := rw_crapdat.dtmvtopr;
            END IF;
          
            FOR idx IN 0 .. 7
            LOOP
            
              FOR idxprt IN 5 .. 15
              LOOP
              
                FOR rw_crapcob IN cr_crapcob_prot(pr_cdcooper => rw_crapcco.cdcooper
                                                 ,pr_nrconven => rw_crapcco.nrconven
                                                 ,pr_dtvencto => TRUNC(vr_dtmvtaux) - (idxprt + idx)
                                                 ,pr_incobran => 0 /*aberto*/
                                                 ,pr_qtdiaprt => idxprt)
                LOOP
                  /* que devem ser protestados */
                  IF nvl(rw_crapcob.flgdprot, 0) = 1 AND nvl(rw_crapcob.flgregis, 0) = 1 THEN
                    /* Validar se chegou no limite de protesto
                    Data de vencimento conta como data pro protesto */
                    IF (rw_crapcob.dtvencto + rw_crapcob.qtdiaprt) <= vr_dtmvtaux THEN
                      /* Gerar Protesto */
                      COBR0007.pc_inst_protestar(pr_cdcooper            => pr_cdcooper --Codigo Cooperativa
                                                ,pr_nrdconta            => rw_crapcob.nrdconta --Numero da Conta
                                                ,pr_nrcnvcob            => rw_crapcob.nrcnvcob --Numero Convenio
                                                ,pr_nrdocmto            => rw_crapcob.nrdocmto --Numero Documento
                                                ,pr_cdocorre            => 9 /* cdocorre */ --Codigo da ocorrencia
                                                ,pr_cdtpinsc            => rw_crapcob.cdtpinsc --Tipo Inscricao
                                                ,pr_dtmvtolt            => vr_dtmvtpro --Data pagamento
                                                ,pr_cdoperad            => vr_cdoperad --Operador
                                                ,pr_nrremass            => 0 --Numero da Remessa
                                                ,pr_tab_lat_consolidada => vr_tab_lat_consolidada --Tabela
                                                ,pr_cdcritic            => vr_cdcritic --Codigo da Critica
                                                ,pr_dscritic            => vr_dscritic); --Descricao da critica
                      -- Retorna nome do modulo logado
                      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
                      --Se ocorreu erro
                      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                        /* Alterado para não apresentar a critica no log, e sim salvar no log de cobrança */
                        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                                     ,pr_cdoperad => vr_cdoperad --Operador
                                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                                     ,pr_dsmensag => 'Protesto nao efetuado: ' ||
                                                                     vr_dscritic --Descricao Mensagem
                                                     ,pr_des_erro => vr_des_erro --Indicador erro
                                                     ,pr_dscritic => vr_dscritic);
                        -- Retorna nome do modulo logado
                        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
                        --Inicializar variavel erro
                        vr_cdcritic := NULL;
                        vr_dscritic := NULL;
                      END IF;
                    END IF;
                  END IF;
                END LOOP; -- rw_crapcob IN cr_crapcob_prot
              END LOOP; -- idxprt IN 5..15
            END LOOP; -- idx IN 0..7
          --
          /*INC0065770
                                                  FOR rw_crapcob IN cr_crapcob_aberto(pr_cdcooper => rw_crapcco.cdcooper
                                                                                     ,pr_nrconven => rw_crapcco.nrconven
                                                                                     ,pr_dtlipgto => TRUNC(rw_crapdat.dtmvtolt)
                                                                                     ,pr_incobran => 0)
                                                  LOOP
                                                  
                                                    IF rw_crapcco.dsorgarq IN ('EMPRESTIMO', 'DESCONTO DE TITULO') THEN
                                                      IF pr_nmtelant = 'COMPEFORA' THEN
                                                        vr_dtmvtpro := rw_crapdat.dtmvtoan;
                                                      ELSE
                                                        vr_dtmvtpro := rw_crapdat.dtmvtolt;
                                                      END IF;
                                                    ELSE
                                                      --Determinar a data do protesto
                                                      IF pr_nmtelant = 'COMPEFORA' THEN
                                                        vr_dtmvtpro := rw_crapdat.dtmvtolt;
                                                      ELSE
                                                        vr_dtmvtpro := rw_crapdat.dtmvtopr;
                                                      END IF;
                                                    END IF;
                                                  
                                                    --Baixar titulo por decurso de prazo
                                                    COBR0007.pc_inst_pedido_baixa_decurso(pr_cdcooper            => rw_crapcob.cdcooper --Codigo Cooperativa
                                                                                         ,pr_nrdconta            => rw_crapcob.nrdconta --Numero da Conta
                                                                                         ,pr_nrcnvcob            => rw_crapcob.nrcnvcob --Numero Convenio
                                                                                         ,pr_nrdocmto            => rw_crapcob.nrdocmto --Numero Documento
                                                                                         ,pr_cdocorre            => 2 --Codigo da ocorrencia
                                                                                         ,pr_dtmvtolt            => vr_dtmvtpro --Data pagamento
                                                                                         ,pr_cdoperad            => vr_cdoperad --Operador
                                                                                         ,pr_nrremass            => 0 --Numero da Remessa
                                                                                         ,pr_tab_lat_consolidada => vr_tab_lat_consolidada --Tabela
                                                                                         ,pr_cdcritic            => vr_cdcritic --Codigo da Critica
                                                                                         ,pr_dscritic            => vr_dscritic); --Descricao da critica
                                                    -- Retorna nome do modulo logado
                                                    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
                                                  
                                                    --Se ocorreu erro
                                                    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                                      -- Alterado para não apresentar a critica no log, e sim salvar no log de cobrança
                                                      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                                                                   ,pr_cdoperad => vr_cdoperad --Operador
                                                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                                                                   ,pr_dsmensag => 'Baixa por por decurso de prazo nao efetuada: ' ||
                                                                                                   vr_dscritic --Descricao Mensagem
                                                                                   ,pr_des_erro => vr_des_erro --Indicador erro
                                                                                   ,pr_dscritic => vr_dscritic);
                                                      -- Retorna nome do modulo logado
                                                      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
                                                    
                                                      --Inicializar variavel erro
                                                      vr_cdcritic := NULL;
                                                      vr_dscritic := NULL;
                                                    END IF;
                                                  
                                                  END LOOP; -- rw_crapcob IN cr_crapcob_aberto                     
                                                  */
          --
          END LOOP; -- rw_crapcco IN cr_crapcco_ativo
        
          -- Ajuste log - 15/03/2018 - Chamado 801483
          vr_cdcritic := 1066; -- Inicio Processo Lancamento Tarifas 
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' Lancamento Tarifas.';
          -- Incluido controle de Log - Chamado 714566 - 11/08/2017  
          pc_controla_log_programa(pr_dstiplog => 'O'
                                  ,pr_tpocorre => 4
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        
          -- Lancamento Tarifas
          PAGA0001.pc_efetua_lancto_tarifas_lat(pr_cdcooper            => pr_cdcooper --Codigo Cooperativa
                                               ,pr_dtmvtolt            => rw_crapdat.dtmvtolt --Data Movimento
                                               ,pr_tab_lat_consolidada => vr_tab_lat_consolidada --Tabela Lancamentos
                                               ,pr_cdcritic            => vr_cdcritic --Codigo Erro
                                               ,pr_dscritic            => vr_dscritic); --Descricao Erro
          --Se Ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
          -- Retorna nome do modulo logado
          GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
        
          -- Ajuste log - 15/03/2018 - Chamado 801483
          vr_cdcritic := 1067; -- Fim Processo Lancamento Tarifas 
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' Lancamento Tarifas.';
          -- Incluido controle de Log - Chamado 714566 - 11/08/2017  
          pc_controla_log_programa(pr_dstiplog => 'O'
                                  ,pr_tpocorre => 4
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        
        END IF; -- NOT vr_inreproc
      
      EXCEPTION
        --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
        WHEN vr_exc_saida THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic || ' pr_cdcooper:' || pr_cdcooper ||
                         ', pc_atualiza_protesto_baixa';
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 9999;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) || ' pr_cdcooper:' ||
                         pr_cdcooper || ', pc_atualiza_protesto_baixa - ' || SQLERRM;
      END pc_atualiza_protesto_baixa;
    
      -- pc_verifica_ja_executou
      PROCEDURE pc_verifica_ja_executou(pr_dtproces IN DATE
                                       ,pr_cdtipope IN VARCHAR2
                                       ,pr_cdprogra IN VARCHAR2
                                       ,pr_qtdexec  OUT INTEGER
                                       ,pr_cdcritic OUT INTEGER
                                       ,pr_dscritic OUT VARCHAR2) IS
        vr_flultexe INTEGER := NULL;
        vr_qtdexec  INTEGER := NULL;
        vr_cdcritic PLS_INTEGER := NULL;
        vr_dscritic VARCHAR2(4000) := NULL;
      BEGIN
        --> Verificar a execução
        CECRED.gene0001.pc_controle_exec(pr_cdcooper => pr_cdcooper --> Código da coopertiva
                                        ,pr_cdtipope => pr_cdtipope --> Tipo de operacao I-incrementar e C-Consultar
                                        ,pr_dtmvtolt => pr_dtproces --> Data do movimento
                                        ,pr_cdprogra => pr_cdprogra --> Codigo do programa
                                        ,pr_flultexe => vr_flultexe --> Retorna se é a ultima execução do procedimento
                                        ,pr_qtdexec  => vr_qtdexec --> Retorna a quantidade
                                        ,pr_cdcritic => vr_cdcritic --> Codigo da critica de erro
                                        ,pr_dscritic => vr_dscritic); --> descrição do erro se ocorrer
        pr_qtdexec := vr_qtdexec;
        --Trata retorno
        IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Retorna nome do modulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
      EXCEPTION
        --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
        -- apenas repassar as criticas
        WHEN vr_exc_saida THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic || ' pr_dtproces:' || pr_dtproces || ', pr_cdtipope:' ||
                         pr_cdtipope || ', pr_cdprogra:' || pr_cdprogra ||
                         ', pc_verifica_ja_executou';
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 9999;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) || ' pr_dtproces:' ||
                         pr_dtproces || ', pr_cdtipope:' || pr_cdtipope || ', pr_cdprogra:' ||
                         pr_cdprogra || ', pc_verifica_ja_executou - ' || SQLERRM;
      END pc_verifica_ja_executou;
    
      ---------------------------------------
      --                                           Inicio Bloco Principal 
      ---------------------------------------
    BEGIN
      --Limpar parametros saida
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
    
      --Posicionar parametros
      vr_typ_craprej_array := pr_tab_cratrej;
    
      IF pr_dsreproc = 'true' THEN
        vr_inreproc := TRUE;
      ELSE
        vr_inreproc := FALSE;
      END IF;
      -- Incluir nome do modulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
    
      -- Ajuste log - 15/03/2018 - Chamado 801483       
      -- Incluido controle de inicio de programa - Chamado 801477 - 24/11/2017
      pc_controla_log_programa(pr_dstiplog => 'I'
                              ,pr_tpocorre => 4
                              ,pr_dscritic => NULL
                              ,pr_cdcritic => NULL
                              ,pr_cdcricid => 2);
    
      --Se der um erro no CRPS538_1 Ficara registrado no Log com erro e vai abrir chamado Não vai parar a cadeia     
    
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
        INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
    
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat
        INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
    
      --Determinar a data para arquivo de retorno
      IF pr_nmtelant = 'COMPEFORA' THEN
        --Data Atual
        --INC0065770
        --vr_dtmvtaux := rw_crapdat.dtmvtoan;
        vr_dtmvtaux := to_date('26102020', 'ddmmyyyy');
      ELSE
        --Proximo Dia Util
        vr_dtmvtaux := rw_crapdat.dtmvtolt;
      END IF;
    
      /*INC0065770
          -- Verifica se programa anterior já executou
          pc_verifica_ja_executou(pr_dtproces => vr_dtmvtaux
                                 ,pr_cdtipope => 'C'
                                 ,pr_cdprogra => 'CRPS538'
                                 ,pr_qtdexec  => vr_qtdexec
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
        
          IF vr_qtdexec = 0 THEN
            --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
            --Levantar Excecao
            vr_cdcritic := 144; -- Faltou executar programa anterior
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' crps538';
            RAISE vr_exc_saida;
          END IF;
      */
    
      -- Verifica se programa já executou
      pc_verifica_ja_executou(pr_dtproces => vr_dtmvtaux
                             ,pr_cdtipope => 'I'
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_qtdexec  => vr_qtdexec
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
    
      --Carregar tabela memoria de motivos
      FOR rw_crapmot IN cr_crapmot(pr_cdcooper => pr_cdcooper)
      LOOP
        --Montar Indice para tabela
        vr_index_crapmot := lpad(rw_crapmot.cddbanco, 5, '0') || lpad(rw_crapmot.cdocorre, 5, '0') ||
                            lpad(rw_crapmot.tpocorre, 5, '0') || lpad(rw_crapmot.cdmotivo, 2, '0');
        vr_tab_crapmot(vr_index_crapmot) := rw_crapmot.dsmotivo;
      END LOOP;
    
      --Buscar Diretorio Integracao da Cooperativa
      vr_caminho_puro := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => NULL);
    
      -- Busca o diretorio da cooperativa conectada
      vr_caminho_rl := gene0001.fn_diretorio(pr_tpdireto => 'C' --> usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => NULL);
      -- Buscar o diretorio padrao da cooperativa conectada
      vr_caminho_rl := vr_caminho_rl || '/rl';
    
      --                 
      -- Excluida pr_dtmvtolt pois não necessaria - 15/03/2018 - Chamado 801483 
      -- Gera arq cooperado    
      pc_atualiza_protesto_baixa(pr_cdcooper => pr_cdcooper
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
    
      --Gerar relatorio 605
      pc_gera_relatorio_605(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
    
      --Gerar relatorio 686
      pc_gera_relatorio_686(pr_nmtelant => pr_nmtelant
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
    
      --Salvar informacoes no banco de dados       
      COMMIT;
    
      -- Ajuste log - 15/03/2018 - Chamado 801483       
      -- Incluido controle de fim de programa - Chamado 801477 - 24/11/2017
      pc_controla_log_programa(pr_dstiplog => 'F'
                              ,pr_tpocorre => 4
                              ,pr_dscritic => NULL
                              ,pr_cdcritic => NULL
                              ,pr_cdcricid => 2);
    
    EXCEPTION
      -- Controla log em banco de dados - 15/03/2018 - Chamado 801483
      WHEN vr_exc_saida THEN
        -- Devolvemos codigo e critica encontradas     
        pr_cdcritic := nvl(vr_cdcritic, 0);
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic, vr_dscritic) || ' pr_cdcooper:' ||
                       pr_cdcooper || ', pr_nmtelant:' || pr_nmtelant || ', pr_dsreproc:' ||
                       pr_dsreproc || ', pr_nmarquiv:' || pr_nmarquiv || ', PC_CRPS538_1';
        pc_controla_log_programa(pr_dstiplog => 'E'
                                ,pr_tpocorre => 2
                                ,pr_dscritic => pr_dscritic
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_cdcricid => 2);
        -- Efetuar rollback
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, pr_cdcritic || ' - ' || pr_dscritic);
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) || ' pr_cdcooper:' ||
                       pr_cdcooper || ', pr_nmtelant:' || pr_nmtelant || ', pr_dsreproc:' ||
                       pr_dsreproc || ', pr_nmarquiv:' || pr_nmarquiv || ', PC_CRPS538_1 - ' ||
                       SQLERRM;
        pc_controla_log_programa(pr_dstiplog => 'E'
                                ,pr_tpocorre => 2
                                ,pr_dscritic => pr_dscritic
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_cdcricid => 2);
        ----- Efetuar rollback
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, pr_cdcritic || ' - ' || pr_dscritic);
    END;
  END baca_crps538_1;
  --
BEGIN
  --
  DECLARE
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS538';
    pr_cdcooper          crapcop.cdcooper%TYPE := 1;
    vr_typ_craprej_array TYP_CRAPREJ_ARRAY := TYP_CRAPREJ_ARRAY();
  
    vr_cdcritic INTEGER := 0;
    vr_dscritic VARCHAR2(4000);
  
    -- Busca dados para craprej
    CURSOR cr_craprej(pr_cdcooper    IN NUMBER
                     ,PR_cdprograma  IN VARCHAR2
                     ,pr_dsrelatorio IN VARCHAR2
                     ,pr_dtmvtolt    IN DATE) IS
      SELECT cdcooper
            ,cdprograma
            ,dsrelatorio
            ,dtmvtolt
            ,cdagenci
            ,nrdconta    nrdconta
            ,nrcnvcob    nrseqdig
            ,nrdocmto    nrdocmto
            ,nrctremp    cdbccxlt
            ,tpparcel    cdcritic
            ,vltitulo    vllanmto
            ,dscritic    cdpesqbb
        FROM TBGEN_BATCH_RELATORIO_WRK
       WHERE cdcooper = pr_cdcooper
         AND cdprograma = PR_cdprograma
         AND dsrelatorio = pr_dsrelatorio
         AND TO_CHAR(dtmvtolt, 'YYYYMMDD') = TO_CHAR(pr_dtmvtolt, 'YYYYMMDD')
       ORDER BY nrcnvcob
               ,nrdconta
               ,nrdocmto;
  
    --Procedimento para gravar dados na tabela memoria cratrej
    PROCEDURE pc_carga_cratrej IS
    BEGIN
      -- Refeita procedure - Chamado 714566 - 11/08/2017 
      DECLARE
        vr_index_cratrej NUMBER(20) := 0;
      BEGIN
        -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
        GENE0001.pc_set_modulo(pr_module => 'PC_' || vr_cdprogra || '.pc_carga_cratrej'
                              ,pr_action => NULL);
        --Percorrer toda a tabela do relatório
        FOR rw_craprej IN cr_craprej(pr_cdcooper    => pr_cdcooper
                                    ,pr_cdprograma  => vr_cdprogra
                                    ,pr_dsrelatorio => 'CRAPREJ'
                                    ,pr_dtmvtolt    => TO_DATE('26/10/2020', 'DD/MM/YYYY'))
        LOOP
        
          --Montar Indice
          vr_index_cratrej := vr_index_cratrej + 1;
          --Gravar dados na tabela memoria
          vr_typ_craprej_array.EXTEND;
          vr_typ_craprej_array(vr_index_cratrej) := TYP_CRAPREJ(rw_craprej.dtmvtolt
                                                               ,rw_craprej.cdagenci
                                                               ,rw_craprej.vllanmto
                                                               ,rw_craprej.nrseqdig
                                                               ,rw_craprej.cdpesqbb
                                                               ,rw_craprej.cdcritic
                                                               ,rw_craprej.cdcooper
                                                               ,rw_craprej.nrdconta
                                                               ,rw_craprej.cdbccxlt
                                                               ,rw_craprej.nrdocmto);
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
          --Variavel de erro recebe critica ocorrida
          vr_cdcritic := 9999;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         'CRPS538.pc_carga_cratrej' || '. ' || SQLERRM;
          -- Excluido RAISE vr_exc_saida - 15/03/2018 - Chamado 801483
      END;
    END pc_carga_cratrej;
  
  BEGIN
    --
    pc_carga_cratrej;
    --
    baca_crps538_1(pr_cdcooper    => 1
                  ,pr_nmtelant    => 'COMPEFORA'
                  ,pr_dsreproc    => 'false'
                  ,pr_nmarquiv    => '29999O26.RET'
                  ,pr_tab_cratrej => vr_typ_craprej_array);
    --
  END;
  --
END;
