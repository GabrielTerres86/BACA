CREATE OR REPLACE PROCEDURE CECRED.pc_crps693(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                      ,pr_flgresta IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
BEGIN 
  /* ............................................................................

    Programa: PC_CRPS693
    Sistema : Cobrança - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Daniel Zimmermann
    Data    : Maio/2015                      Ultima atualizacao: 14/11/2018

    Dados referentes ao programa:

    Frequencia: Diario.
    Objetivo  : Responsavel por gerar o arquivo PG.
                Gera o relatorio crrl700 

    Alteracoes: 25/06/2015 - Gerar e-mail a área de cobrança quando houver problemas de 
                             transmissão de arquivos à PG. (Rafael)
                           - Quando houver erro de transmissão, copiar arquivo para a pasta
                             /micros/cecred/cobranca. (Rafael)
                             
                25/07/2015 - Ajuste no procedimento da chamada da rotina webservice. Chamar
                             a rotina somente quando existem títulos a serem enviados. (Rafael)

				13/10/2016 - Ao buscar o bairro, se estiver nulo, utilizar um espaco em branco,
				             pois estava causando problemas no layout do arquivo.
							 Heitor (Mouts) - Chamado 534526

				17/11/2016 - Melhorar mensagem de erro retornada no e-mail referente ao UPLOAD de 
                             arquivos para a PG. Heitor (Mouts) - Chamado 546884

               24/06/2017 - Retirado rotina de geracao de retorno ao cooperado pois agora
                            está centralizado na rotina de geraçao de boletos na
                            package COBR0006 e b1wnet0001.p (P340 - Rafael).
               
               14/11/2018 - Complementado as informações dos emails de erro (Tiago - INC0026209)             

  .......................................................................... */

  DECLARE
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Codigo do Programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS693';

    -- Tratamento de Erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_exc_next   EXCEPTION;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_erro_envio VARCHAR2(4000);
    
    -- Tratamento Mensagens Titulo
    vr_inform gene0002.typ_split;
    
    -- Declarando handle do Arquivo
    vr_ind_arquivo utl_file.file_type;
    vr_des_erro VARCHAR2(4000);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml       CLOB;
    
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);

    -- Variaveis Diversas
    vr_ultimo_remesa NUMBER;
    vr_nmarquiv VARCHAR(100);
    vr_flg_gera_arq BOOLEAN;
    vr_nrsequen NUMBER;
    vr_nmdireto VARCHAR2(4000);
    vr_nmdirrel VARCHAR2(4000);
    vr_nmdirslv VARCHAR2(4000);
    vr_nmdirmic VARCHAR2(4000);
    vr_dscorpo  VARCHAR2(4000);
    vr_des_destino VARCHAR2(4000);
    vr_dsmensag VARCHAR2(100);
    vr_setlinha VARCHAR2(400);
    vr_cdageman NUMBER;
    vr_nrdolote NUMBER;
    vr_qtd_registro NUMBER;
    vr_nro_seq_lote NUMBER;
    vr_cddespec VARCHAR2(02);
    vr_cdprotes VARCHAR2(02);
    vr_uso_empresa VARCHAR(25);
    vr_dias_protesto VARCHAR(02);
    vr_cddescto VARCHAR(1);
    vr_dtdescto VARCHAR(8);
    vr_endereco VARCHAR2(400);
    vr_nmarqimp VARCHAR2(400);
    
    vr_rowidcce ROWID;
    vr_rowidcob ROWID;
    
    vr_qtdtotal  NUMBER;
    vr_vlrtotal  NUMBER;
    
    vr_indice VARCHAR(25);
    
    vr_nrcalcul NUMBER;
    vr_flgdigok1 BOOLEAN;
    -- Codigo Identificação do Job
    vr_cdidejob VARCHAR2(40);
 
    -- Tabela temporaria para os titulos
    TYPE typ_reg_crapcob IS
     RECORD(cdcooper crapcob.cdcooper%TYPE
           ,cdbandoc crapcob.cdbandoc%TYPE
           ,nrdctabb crapcob.nrdctabb%TYPE
           ,nrcnvcob crapcob.nrcnvcob%TYPE
           ,nrdconta crapcob.nrdconta%TYPE
           ,nrdocmto crapcob.nrdocmto%TYPE
           ,cdagenci crapass.cdagenci%TYPE
           ,vltitulo crapcob.vltitulo%TYPE);
    TYPE typ_tab_crapcob IS
      TABLE OF typ_reg_crapcob
        INDEX BY PLS_INTEGER;
    -- Vetor para armazenar os os titulos
    vr_tab_crapcob typ_tab_crapcob;
    
    
    -- Tabela temporaria para o relatorio
    TYPE typ_reg_relatorio IS
     RECORD(cdcooper crapcob.cdcooper%TYPE
           ,nrcnvcob crapcob.nrcnvcob%TYPE
           ,nrdconta crapcob.nrdconta%TYPE
           ,cdagenci crapass.cdagenci%TYPE
           ,vltitulo crapcob.vltitulo%TYPE
           ,qtdtotal NUMBER);
    TYPE typ_tab_relatorio IS
      TABLE OF typ_reg_relatorio
        INDEX BY VARCHAR2(25);
    -- Vetor para armazenar os os titulos
    vr_tab_relatorio typ_tab_relatorio;
    
    -- Array par Segmento S - Mensagens
    TYPE type_tab_mensagem IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
    -- Array de Mensagens
    vr_tab_mensagem type_tab_mensagem;
    
    
    -- Tabela temporaria dados email
    TYPE typ_reg_email IS
     RECORD(cdcooper crapcob.cdcooper%TYPE
           ,nmarquiv VARCHAR2(200)
           ,vltitulo crapcob.vltitulo%TYPE
           ,qtdtotal NUMBER);
    TYPE typ_tab_email IS
      TABLE OF typ_reg_email
        INDEX BY PLS_INTEGER;
    -- Vetor para armazenar os os titulos
    vr_tab_email typ_tab_email;
    -- Vetor para armazenar as tarifas de geracao dos boletos;
    vr_tab_lcm_consolidada PAGA0001.typ_tab_lcm_consolidada;

    ------------------------------- CURSORES ---------------------------------

    -- Busca Dados das Cooperativas
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
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
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
       WHERE cop.cdcooper = pr_cdcooper
         AND cop.flgativo = 1;
         
    --Selecionar informacoes convenios ativos
    CURSOR cr_crapcco_ativo (pr_cdcooper IN crapcco.cdcooper%type
                            ,pr_cddbanco IN crapcco.cddbanco%type) IS
      SELECT crapcco.cdcooper
            ,crapcco.nrconven
            ,crapcco.nrdctabb
            ,crapcco.cddbanco
            ,crapcco.cdagenci
            ,crapcco.cdbccxlt
            ,crapcco.nrdolote
      FROM crapcco
      WHERE crapcco.cdcooper = pr_cdcooper
      AND   crapcco.cddbanco = pr_cddbanco
      AND   crapcco.flgregis = 1;
    rw_crapcco cr_crapcco_ativo%ROWTYPE;     
         
    -- Busca Numero Remessa/Retorno
    CURSOR cr_crapcce(pr_cdcooper IN crapcee.cdcooper%TYPE) IS
      SELECT NVL(MAX(cee.nrremret),0) + 1 max_nrremret
        FROM crapcee cee
       WHERE cee.cdcooper = pr_cdcooper;
    rw_crapcee cr_crapcce%ROWTYPE;   
    
    --Selecionar os dados da tabela de Associados
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta
            ,ass.cdagenci
            ,ass.nrcpfcgc
            ,ass.inpessoa
            ,ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE; 

    -- Busca Registros Cobrança
    CURSOR cr_crapcob(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_dtmvtoan IN crapcob.dtvencto%TYPE,
                      pr_dtmvtolt IN crapcob.dtvencto%TYPE) IS
      SELECT cob.cdcooper
            ,cob.cdbandoc
            ,cob.nrdctabb
            ,cob.nrcnvcob
            ,cob.nrdconta
            ,cob.nrdocmto
            ,cob.cddespec
            ,cob.nrnosnum
            ,cob.dtvencto
            ,cob.vltitulo
            ,cob.flgdprot
            ,cob.vlabatim
            ,cob.vldescto
            ,cob.qtdiaprt
            ,cob.dtdocmto
            ,cob.tpjurmor
            ,cob.vljurdia
            ,cob.nrinssac
            ,cob.cdtpinav
            ,cob.nrinsava
            ,cob.nmdavali
            ,cob.vlrmulta
            ,cob.tpdmulta
            ,cob.dsinform
            ,cob.dsdoccop
            ,cob.dtmvtolt
            ,cob.rowid
            ,ROW_NUMBER () OVER (PARTITION BY cob.nrdconta,cob.nrcnvcob ORDER BY cob.nrdconta,cob.nrcnvcob) nrseq
            ,COUNT(1) OVER (PARTITION BY cob.nrdconta,cob.nrcnvcob ORDER BY cob.nrdconta,cob.nrcnvcob) qtreg
        FROM crapcob cob,
             crapcco cco,
             crapceb ceb
       WHERE cob.cdcooper = pr_cdcooper
         AND cob.dtvencto >= pr_dtmvtolt
--         AND cob.dtmvtolt <= pr_dtmvtolt
         AND cob.incobran = 0
         AND cob.inemiten = 3 -- Cooperativa emite e expede 
         AND cob.inemiexp = 1 -- Indicador emite e expede – A Enviar
         AND cco.cddbanco = 085
         AND cco.cdcooper = cob.cdcooper
         AND ceb.cdcooper = cco.cdcooper
         AND ceb.nrconven = cco.nrconven
         AND cob.nrdconta = ceb.nrdconta
         AND cob.nrcnvcob = ceb.nrconven
         AND cob.dsinform NOT LIKE 'LIQAPOSB%'
         ORDER BY cob.nrdconta
                 ,cob.nrcnvcob;
                 
      
    -- Selecionar os dados da tabela de Associados
    CURSOR cr_crapsab (pr_cdcooper IN crapsab.cdcooper%TYPE
                      ,pr_nrdconta IN crapsab.nrdconta%TYPE
                      ,pr_nrinssac IN crapsab.nrinssac%TYPE) IS
      SELECT sab.nrdconta
            ,sab.dsendsac
            ,sab.cdtpinsc
            ,nvl(sab.nmbaisac,' ') nmbaisac
            ,sab.nrendsac
            ,sab.nrinssac
            ,sab.complend
            ,sab.nmdsacad
            ,sab.nrcepsac
            ,sab.nmcidsac
            ,sab.cdufsaca
        FROM crapsab sab
       WHERE sab.cdcooper = pr_cdcooper
         AND sab.nrdconta = pr_nrdconta
         AND sab.nrinssac = pr_nrinssac;
    rw_crapsab cr_crapsab%ROWTYPE;

    -- Cursor Genérico de Calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    rw_crabdat btch0001.cr_crapdat%ROWTYPE;
    
    vr_ret_nrremret INTEGER;

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
      
    BEGIN
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir Nome do Módulo Logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);
                               
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crabcop;
    FETCH cr_crabcop INTO rw_crabcop;
    -- Se não encontrar
    IF cr_crabcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crabcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crabcop;
    END IF;  
    
    -- Leitura do calendário da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crabcop.cdcooper);
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
                                 
    -- Validações Iniciais do Programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
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
    vr_nmarqimp  := 'crrl700.lst';
    
    -- buscar emails de destino
    vr_des_destino := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                pr_cdcooper => pr_cdcooper, 
                                                pr_cdacesso => 'CRPS693_EMAIL');                                               

    FOR rw_crapcop IN cr_crapcop (pr_cdcooper => pr_cdcooper) LOOP 
           
      BEGIN
       
        -- Leitura do calendário da cooperativa
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
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
        
        -- Inicializar o CLOB
        vr_des_xml := NULL;
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
                      
        -- Busca Numero da Ultima Remessa 
        OPEN cr_crapcce(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH cr_crapcce INTO rw_crapcee;
        
        CLOSE cr_crapcce;

        -- Numero de Retorno
        vr_ultimo_remesa := rw_crapcee.max_nrremret;
        
        -- Monta Nome do Arquivo       
        vr_nmarquiv := 'PG_' || upper(rw_crapcop.dsdircop)            || '_' ||
                       to_char(rw_crabdat.dtmvtolt,'YYYYMMDD') || '_' ||
                       TRIM(to_char(vr_ultimo_remesa,'000000'))      || '.REM';  
          
        -- Inicilizar as informações do XML
        vr_texto_completo := NULL;
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz><crrl700>');
             
        pc_escreve_xml(
             '<arquivo>' ||
               '<nmarquiv>'||  vr_nmarquiv  ||'</nmarquiv>'|| 
             '</arquivo>' ||
             '<contas>');               
              
        -- Controle de Geração do Arquivo
        vr_flg_gera_arq := FALSE;
        
        -- Sequencial Registro Detalhe
        vr_nrsequen  := 0;
        
        -- Numero do Lote
        vr_nrdolote  := 0;
        
        -- Valores Totais Relatorio
        vr_qtdtotal  := 0;
        vr_vlrtotal  := 0;
        
        -- Quantidade Total de Linhas Arquivo
        vr_qtd_registro := 0;
        
        -- Limpa Tabelas
        vr_tab_crapcob.DELETE;
        vr_tab_relatorio.DELETE;
        vr_tab_lcm_consolidada.DELETE;
        
        -- Diretorio Geração Arquivo
        vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                             pr_cdcooper => 3, --rw_crapcop.cdcooper,
                                             pr_nmsubdir => 'arq');
        -- Diretorio Geração Relatorio
        vr_nmdirrel := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                             pr_cdcooper => rw_crapcop.cdcooper,
                                             pr_nmsubdir => 'rl');  
        -- Diretorio Salvar                                    
        vr_nmdirslv := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                             pr_cdcooper => rw_crapcop.cdcooper,
                                             pr_nmsubdir => 'salvar');                                                                      

        -- Diretorio MICROS
        vr_nmdirmic := gene0001.fn_diretorio(pr_tpdireto => 'M',
                                             pr_cdcooper => 3, --rw_crapcop.cdcooper,
                                             pr_nmsubdir => 'cobranca');
                                                            
        -- Leitura de Titulos a serem Enviados
        FOR rw_crapcob IN cr_crapcob(pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_dtmvtoan => rw_crabdat.dtmvtoan
                                    ,pr_dtmvtolt => rw_crabdat.dtmvtolt) LOOP                                      

          -- Gera Registro Header Apenas se Possui Titulos e Apenas uma Vez.  
          IF vr_flg_gera_arq = FALSE THEN
             
            -- Flag de Controle se Arquivo deve ser Gerado                      
            vr_flg_gera_arq := TRUE;
                                  
             
            BEGIN
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
                                ,vr_ultimo_remesa
                                ,1 -- Remessa
                                ,vr_nmarquiv
                                ,1 -- Super Usuario
                                ,rw_crabdat.dtmvtolt
                                ,NULL
                                ,NULL
                                ,1)
                        RETURNING ROWID
                        INTO vr_rowidcce;

            EXCEPTION
              WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir na tabela crapcee. '|| SQLERRM;
               --Sair do programa
               RAISE vr_exc_saida;
            END; 
             
            -- Abre arquivo em modo de escrita (W)
            GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto         --> Diretório do arquivo
                                    ,pr_nmarquiv => vr_nmarquiv         --> Nome do arquivo
                                    ,pr_tipabert => 'W'                 --> Modo de abertura (R,W,A)
                                    ,pr_utlfileh => vr_ind_arquivo      --> Handle do arquivo aberto
                                    ,pr_des_erro => vr_dscritic);       --> Erro  
                                    
                                              
            IF vr_dscritic IS NOT NULL THEN
              -- Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
            
            vr_qtd_registro := vr_qtd_registro + 1;
            
            -- Calcula primeiro digito de controle
            vr_nrcalcul := to_number(gene0002.fn_mask(rw_crapcop.cdagectl,'9999') || '0');
           
            vr_flgdigok1 := GENE0005.fn_calc_digito (pr_nrcalcul => vr_nrcalcul);

            vr_setlinha:= '085'                                                   || -- 01.0 - Banco
              '0000'                                                              || -- 02.0 - Lote 
              '0'                                                                 || -- 03.0 - Tipo Registro
              LPAD(' ',9,' ')                                                     || -- 04.0 - Brancos
              '2'                                                                 || -- 05.0 - Tp Inscricao 
              gene0002.fn_mask(rw_crapcop.nrdocnpj,'99999999999999')              || -- 06.0 - CNPJ/CPF 
              LPAD(' ', 20,' ')                                                   || -- 07.0 - Convenio
              gene0002.fn_mask(vr_nrcalcul,'999999')                              || -- 08.0 - Age Mantenedora
              LPAD(' ', 13,' ')                                                   || -- 10.0 - Conta/Digito
              LPAD(' ',1,' ')                                                     || -- 12.0 - Dig Verf Age/Cta
              substr(rpad(rw_crapcop.nmextcop,30,' '),1,30)                       || -- 13.0 - Nome Empresa
              LPAD('AILOS',30,' ')                                                || -- 14.0 - Nome Banco
              LPAD(' ',10,' ')                                                    || -- 15.0 - Brancos
              '1'                                                                 || -- 16.0 - Código Remessa/Retorno
              to_char(SYSDATE,'DDMMYYYY')                                         || -- 17.0 - Data de Geração do Arquivo
              gene0002.fn_mask( to_char(SYSDATE,'HH24MISS'),'999999')             || -- 18.0 - Hora de Geração do Arquivo
              gene0002.fn_mask(vr_ultimo_remesa,'999999')                         || -- 19.0 - Numero Sequencial do Arquivo
              '088'                                                               || -- 20.0 - Layout do Arquivo
              '00000'                                                             || -- 21.0 - Densidade de Gravação do Arquivo
              LPAD(' ',20,' ')                                                    || -- 22.0 - Uso Reservado do Banco
              LPAD(' ',20,' ')                                                    || -- 23.0 - Uso Reservado da Empresa
              LPAD(' ',29,' ')                                                    || -- 24.0 - Uso Exclusivo FEBRABAN
              CHR(13);
    
            -- Escrever Linha do Header do Arquivo CNAB240 - Item 1.0
            GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);
           
          END IF; 
          
          -- Verifica se o cooperado esta cadastrada
          OPEN cr_crapass(pr_cdcooper => rw_crapcob.cdcooper
                         ,pr_nrdconta => rw_crapcob.nrdconta);
          FETCH cr_crapass INTO rw_crapass;
          
          -- Se não encontrar
          IF cr_crapass%NOTFOUND THEN
            -- Fechar o cursor pois haverá raise
            CLOSE cr_crapass;
            vr_des_erro := 'Cooperado nao cadastrado.'; 
            RAISE vr_exc_saida;
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_crapass;
          END IF;    
          
          -- Primeiro Registro da Conta/Convenio
          IF rw_crapcob.nrseq = 1 THEN
            
            ------------- HEADER DO LOTE -------------
            
            -- Inicializa Nro. Sequencial do Lote
            vr_nro_seq_lote := 0;
                    
            -- Agencia Mantenedora
            vr_cdageman:= to_number(gene0002.fn_mask(rw_crapcop.cdagectl,'9999')||'0');
            
            -- Adicionar o mesmo ajuste do header do arquivo;
            vr_flgdigok1 := GENE0005.fn_calc_digito (pr_nrcalcul => vr_cdageman);
            
            -- Numero do Lote
            vr_nrdolote := vr_nrdolote + 1;
            
            -- Quantidade Total de Linhas no Arquivo
            vr_qtd_registro := vr_qtd_registro + 1;

            vr_setlinha:= '085'                                               || -- 01.1 - Banco
              gene0002.fn_mask(vr_nrdolote,'9999')                            || -- 02.1 - Lote 
              '1'                                                             || -- 03.1 - Tipo Registro
              'T'                                                             || -- 04.1 - Tipo de Operação
              '06'                                                            || -- 05.1 - Tipo de Serviço        
              LPAD(' ',2,' ')                                                 || -- 06.1 - Uso Exclusivo FEBRABAN
              '010'                                                           || -- 07.1 - Versao do Arquivo
              LPAD(' ',1,' ')                                                 || -- 08.1 - Uso Exclusivo FEBRABAN
              rw_crapass.inpessoa                                             || -- 09.1 - Tipo de Inscricao Empresa 
              gene0002.fn_mask(rw_crapass.nrcpfcgc,'999999999999999')         || -- 10.1 - CNPJ/CPF da Empresa
              LPAD(gene0002.fn_mask(rw_crapcob.nrcnvcob,'9999999999'),20,' ') || -- 11.1 - Convenio
              gene0002.fn_mask(vr_cdageman,'999999')                          || -- 12.1 - Agencia Mantenedora da Conta
              gene0002.fn_mask(rw_crapass.nrdconta,'9999999999999')           || -- 14.1 - Conta/Digito
              LPAD(' ',1,' ')                                                 || -- 16.1 - Digito Verfificador Ag/Conta
              substr(rpad(rw_crapass.nmprimtl,30,' '),1,30)                   || -- 17.1 - Nome da Empresa
              LPAD(' ',40,' ')                                                || -- 18.1 - Informacao 1
              LPAD(' ',40,' ')                                                || -- 19.1 - Informacao 2
              gene0002.fn_mask(vr_ultimo_remesa,'99999999')                   || -- 20.1 - Numero Sequencial do Arquivo
              to_char(SYSDATE,'DDMMYYYY')                                     || -- 21.1 - Data de Gravação Remessa/Retorno
              LPAD(' ',8,' ')                                                 || -- 22.1 - Data do Credito
              LPAD(' ',33,' ')                                                || -- 23.1 - Uso Exclusivo FEBRABAN              
              CHR(13);
                
            -- Escreve Linha do header do Lote CNAB240
            GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);
            
          END IF;  
          
          -- Incrementa Numero Sequencial
          vr_nrsequen := vr_nrsequen + 1;
                         
          BEGIN
            -- Inserir Detalhe da Remessa
            INSERT INTO crapdee
              (cdcooper
               ,nrremret
               ,intipmvt
               ,nrdconta
               ,nrcnvcob
               ,nrdocmto
               ,nrsequen
               ,cdocorre)
            VALUES 
              (rw_crapcob.cdcooper
              ,vr_ultimo_remesa
              ,1 -- Remessa
              ,rw_crapcob.nrdconta
              ,rw_crapcob.nrcnvcob
              ,rw_crapcob.nrdocmto
              ,vr_nrsequen
              ,1);

          EXCEPTION
              WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir na tabela crapdee. '|| SQLERRM;
               --Sair do programa
               RAISE vr_exc_saida;
          END;
          
          -- Grava Registros na PL/Table
          vr_tab_crapcob(vr_nrsequen).cdcooper := rw_crapcob.cdcooper;
          vr_tab_crapcob(vr_nrsequen).cdbandoc := rw_crapcob.cdbandoc;
          vr_tab_crapcob(vr_nrsequen).nrdctabb := rw_crapcob.nrdctabb;
          vr_tab_crapcob(vr_nrsequen).nrcnvcob := rw_crapcob.nrcnvcob;
          vr_tab_crapcob(vr_nrsequen).nrdconta := rw_crapcob.nrdconta;
          vr_tab_crapcob(vr_nrsequen).nrdocmto := rw_crapcob.nrdocmto;
          vr_tab_crapcob(vr_nrsequen).cdagenci := rw_crapass.cdagenci;
          vr_tab_crapcob(vr_nrsequen).vltitulo := rw_crapcob.vltitulo;
          
          -- Monta indice da PL/TABLE
          vr_indice := LPAD(rw_crapass.cdagenci,5,'0')  ||
                       LPAD(rw_crapcob.nrdconta,10,'0') ||
                       LPAD(rw_crapcob.nrcnvcob,10,'0');
          
          -- PL/Table Gerar Relatorio
          IF vr_tab_relatorio.EXISTS(vr_indice) THEN
            vr_tab_relatorio(vr_indice).qtdtotal := vr_tab_relatorio(vr_indice).qtdtotal + 1;
            vr_tab_relatorio(vr_indice).vltitulo := vr_tab_relatorio(vr_indice).vltitulo + rw_crapcob.vltitulo;
          ELSE
            vr_tab_relatorio(vr_indice).cdagenci := rw_crapass.cdagenci;
            vr_tab_relatorio(vr_indice).nrdconta := rw_crapcob.nrdconta;
            vr_tab_relatorio(vr_indice).nrcnvcob := rw_crapcob.nrcnvcob;
            vr_tab_relatorio(vr_indice).qtdtotal := 1;
            vr_tab_relatorio(vr_indice).vltitulo := rw_crapcob.vltitulo;
          END IF; 
          
          -- Valores Totais Para Relatorio
          vr_qtdtotal  := vr_qtdtotal + 1;                    -- Qtd Titulos                                      
          vr_vlrtotal  := vr_vlrtotal + rw_crapcob.vltitulo;  -- Valor Total
          
          ------ REGISTRO DETALHE ------
          
          -- Quantidade Total de Linhas no Arquivo
          vr_qtd_registro := vr_qtd_registro + 1;
          
          -- Nro. Sequencial no Lote
          vr_nro_seq_lote := vr_nro_seq_lote + 1;
          
          
          CASE rw_crapcob.cddespec
            WHEN 1 THEN
              vr_cddespec := '02';
            WHEN 2 THEN
              vr_cddespec := '04';
            WHEN 3 THEN
              vr_cddespec := '12';
            WHEN 4 THEN
              vr_cddespec := '21';  
            WHEN 5 THEN
              vr_cddespec := '23';
            WHEN 6 THEN
              vr_cddespec := '17';        
            WHEN 7 THEN
              vr_cddespec := '99';
          ELSE
            -- Deve Assumir o Valor de 99
            vr_cddespec := '99';    
          END CASE;
          
          IF rw_crapcob.flgdprot = 1 THEN
            vr_cdprotes := '1'; -- Protestar
          ELSE
            vr_cdprotes := '3'; -- Não Protestar
          END IF;  
          
          -- Monta Campo Uso da Empresa
          vr_uso_empresa := gene0002.fn_mask(rw_crapcob.nrcnvcob, '9999999') || 
                            gene0002.fn_mask(rw_crapcob.nrdconta, '99999999') || 
                            gene0002.fn_mask(rw_crapcob.nrdocmto, '999999999');
                            
          -- Nro Dias Protesto
          --IF rw_crapcob.qtdiaprt = 5 AND rw_crapcob.flgdprot = 1 THEN
          --   vr_dias_protesto := '06';
          --ELSE 
          IF rw_crapcob.qtdiaprt >= 5 AND rw_crapcob.flgdprot = 1 THEN
             vr_dias_protesto := gene0002.fn_mask(rw_crapcob.qtdiaprt,'99');
          ELSE 
            vr_dias_protesto := '00';
          END IF;
          --END IF;   
          
          -- Codigo do Desconto
          IF rw_crapcob.vldescto > 0 THEN
            vr_cddescto := '1'; 
          ELSE
            vr_cddescto := '0';
          END IF;  
          
          -- Data Desconto
          IF rw_crapcob.vldescto > 0 THEN 
            vr_dtdescto := to_char(rw_crapcob.dtvencto,'DDMMYYYY');
          ELSE 
            vr_dtdescto := ' ';
          END IF;  
                      
          -- Registro Detalhe - Segmento P  
          vr_setlinha:= '085'                                                     || -- 01.3P - Banco
            gene0002.fn_mask(vr_nrdolote,'9999')                                  || -- 02.3P - Lote 
            '3'                                                                   || -- 03.3P - Tipo Registro
            gene0002.fn_mask(vr_nro_seq_lote,'99999')                             || -- 04.3P - Nro. do Registro
            'P'                                                                   || -- 05.3P - Segmento      
            LPAD(' ',1,' ')                                                       || -- 06.3P - Uso Exclusivo FEBRABAN
            '01'                                                                  || -- 07.3P - Codigo de Movimento Remessa
            gene0002.fn_mask(vr_cdageman,'999999')                                || -- 08.3P - Agencia Mantenedora da Conta
            gene0002.fn_mask(rw_crapass.nrdconta,'9999999999999')                 || -- 10.3P - Número da Conta Corrente
            '0'                                                                   || -- 12.3P - Dígito Verificador da Ag/Conta
            LPAD(rw_crapcob.nrnosnum,20,' ')                                      || -- 13.3P - Nosso Numero
            '1'                                                                   || -- 14.3P - Carteira 
            '1'                                                                   || -- 15.3P - Forma de Cadastr. do Título no Banco    
            '1'                                                                   || -- 16.3P - Tipo de Documento
            '1'                                                                   || -- 17.3P - Identificação da Emissão do Bloqueto
            '1'                                                                   || -- 18.3P - Identificação da Distribuição
            RPAD(rw_crapcob.dsdoccop,15, ' ')                                     || -- 19.3P Nro do Documento
            to_char(rw_crapcob.dtvencto,'DDMMYYYY')                               || -- 20.3P Vencimento
            gene0002.fn_mask(NVL(rw_crapcob.vltitulo,0) * 100,'999999999999999')  || -- 21.3P Valor do Título
            gene0002.fn_mask(vr_cdageman,'999999')                                || -- 22.3P Ag. Cobradora
            vr_cddespec                                                           || -- 24.3P Espécie de Título
            'N'                                                                   || -- 25.3P Aceite
            LPAD(NVL(to_char(rw_crapcob.dtdocmto,'DDMMYYYY'),' '),08,' ')         || -- 26.3P - Data Emissão do Título
            gene0002.fn_mask(rw_crapcob.tpjurmor,'9')                             || -- 27.3P - Código do Juros de Mora
            LPAD(' ',08,' ')                                                      || -- 28.3P - Data Juros Mora
            gene0002.fn_mask(NVL(rw_crapcob.vljurdia,0) * 100,'999999999999999')  || -- 29.3P - Juros de Mora por Dia/Taxa
            vr_cddescto                                                           || -- 30.3P - Código do Desconto 1
            LPAD(vr_dtdescto,08,' ')                                              || -- 31.3P - Data do Desconto 1
            gene0002.fn_mask(NVL(rw_crapcob.vldescto,0) * 100,'999999999999999')  || -- 32.3P - Valor/Percentual a ser Concedido
            LPAD(' ',15,' ')                                                      || -- 33.3P - Vlr IOF
            gene0002.fn_mask(NVL(rw_crapcob.vlabatim,0) * 100,'999999999999999')  || -- 34.3P - Vlr Abatimento
            LPAD(vr_uso_empresa,25,' ')                                           || -- 35.3P - Uso Empresa Cedente
            vr_cdprotes                                                           || -- 36.3P - Código p/ Protesto
            vr_dias_protesto                                                      || -- 37.3P - Prazo p/ Protesto
            '2'                                                                   || -- 38.3P - Código p/ Baixa/Devolução
            '000'                                                                 || -- 39.3P - Prazo p/ Baixa/Devolução
            '09'                                                                  || -- 40.3P - Código da Moeda
            LPAD(' ',10,' ')                                                      || -- 41.3P - Número do Contrato
            LPAD(' ',1,' ')                                                       || -- 42.3P - Uso livre banco/empresa
            CHR(13);
                
          -- Escreve Linha
          GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);
          
          -- Verifica dados do Sacado
          OPEN cr_crapsab(pr_cdcooper => rw_crapcob.cdcooper
                         ,pr_nrdconta => rw_crapcob.nrdconta
                         ,pr_nrinssac => rw_crapcob.nrinssac);
          FETCH cr_crapsab INTO rw_crapsab;
          
          -- Se não encontrar
          IF cr_crapsab%NOTFOUND THEN
            -- Fechar o cursor pois haverá raise
            CLOSE cr_crapsab;
            vr_des_erro := 'Sacado nao cadastrado.'; 
            RAISE vr_exc_saida;
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_crapsab;
          END IF; 
          
          -- Quantidade Total de Linhas no Arquivo
          vr_qtd_registro := vr_qtd_registro + 1;
          
          -- Nro. Sequencial no Lote
          vr_nro_seq_lote := vr_nro_seq_lote + 1;
          
          -- Monta Campo Endereço
          vr_endereco := rw_crapsab.dsendsac || ' ' || 
                         rw_crapsab.nrendsac || '-' || 
                         rw_crapsab.complend;
          vr_endereco := substr(vr_endereco,1,40);               
                    
          -- Registro Detalhe - Segmento Q  
          vr_setlinha:= '085'                                        || -- 01.3Q - Banco
            gene0002.fn_mask(vr_nrdolote,'9999')                     || -- 02.3Q - Lote 
            '3'                                                      || -- 03.3Q - Tipo Registro
            gene0002.fn_mask(vr_nro_seq_lote,'99999')                || -- 04.3Q - Nro. do Registro
            'Q'                                                      || -- 05.3Q - Segmento      
            LPAD(' ',1,' ')                                          || -- 06.3Q - Uso Exclusivo FEBRABAN
            '01'                                                     || -- 07.3Q - Codigo de Movimento Remessa
            gene0002.fn_mask(rw_crapsab.cdtpinsc,'9')                || -- 08.3Q - Tipo de Inscrição
            gene0002.fn_mask(rw_crapsab.nrinssac,'999999999999999')  || -- 09.3Q - Número de Inscrição
            substr(rpad(rw_crapsab.nmdsacad,40,' '),1,40)            || -- 10.3Q - Nome
            LPAD(vr_endereco,40,' ')                                 || -- 11.3Q - Endereço
            substr(rpad(rw_crapsab.nmbaisac,15,' '),1,15)            || -- 12.3Q - Bairro 
            gene0002.fn_mask(rw_crapsab.nrcepsac,'99999999')         || -- 13.3Q - CEP    
            substr(rpad(rw_crapsab.nmcidsac,15,' '),1,15)            || -- 15.3Q - Cidade
            substr(rpad(rw_crapsab.cdufsaca,02,' '),1,02)            || -- 16.3Q - UF
            gene0002.fn_mask(rw_crapcob.cdtpinav,'9')                || -- 17.3Q - Tipo de Inscrição
            gene0002.fn_mask(rw_crapcob.nrinsava,'999999999999999')  || -- 18.3Q - Numero da Inscrição
            substr(rpad(rw_crapcob.nmdavali,40,' '),1,40)            || -- 19.3Q - Nome do Avalista
            '000'                                                    || -- 20.3Q - Banco Correspondente
            LPAD(' ',20,' ')                                         || -- 21.3Q - Nosso Núm. Bco. Correpondente
            LPAD(' ',8,' ')                                          || -- 22.3Q - Uso Exclusivo FEBRABAN/CNAB
            CHR(13);
                
          -- Escreve Linha
          GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);
          
          IF rw_crapcob.vlrmulta > 0 THEN
            
            -- Quantidade Total de Linhas no Arquivo
            vr_qtd_registro := vr_qtd_registro + 1;
            
            -- Nro. Sequencial no Lote
            vr_nro_seq_lote := vr_nro_seq_lote + 1;
            
            -- Registro Detalhe - Segmento R  
            vr_setlinha:= '085'                                             || -- 01.3R - Banco
              gene0002.fn_mask(vr_nrdolote,'9999')                          || -- 02.3R - Lote 
              '3'                                                           || -- 03.3R - Tipo Registro
              gene0002.fn_mask(vr_nro_seq_lote,'99999')                     || -- 04.3R - Nro. do Registro
              'R'                                                           || -- 05.3R - Segmento      
              LPAD(' ',1,' ')                                               || -- 06.3R - Uso Exclusivo FEBRABAN
              '01'                                                          || -- 07.3R - Codigo de Movimento Remessa
              '0'                                                           || -- 08.3R - Código do Desconto 2
              LPAD(' ',08,' ')                                              || -- 09.3R - Data do Desconto 2
              LPAD(' ',15,' ')                                              || -- 10.3R - Valor/Percentual a ser Concedido
              '0'                                                           || -- 11.3R - Código do Desconto 3
              LPAD(' ',08,' ')                                              || -- 12.3R - Data do Desconto 3
              LPAD(' ',15,' ')                                              || -- 13.3R - Valor/Percentual a ser Concedido
              gene0002.fn_mask(rw_crapcob.tpdmulta,'9')                     || -- 14.3R - Codigo da Multa
              LPAD(' ',08,' ')                                              || -- 15.3R - Data da Multa
              gene0002.fn_mask(rw_crapcob.vlrmulta * 100,'999999999999999') || -- 16.3R - Valor/Percentual a Ser Aplicado
              LPAD(' ',10,' ')                                              || -- 17.3R - Informação ao Sacado                               
              LPAD(' ',40,' ')                                              || -- 18.3R - Mensagem 3
              LPAD(' ',40,' ')                                              || -- 19.3R - Mensagem 4
              LPAD(' ',20,' ')                                              || -- 20.3R - Uso Exclusivo FEBRABAN/CNAB
              LPAD(' ',08,' ')                                              || -- 21.3R - Cód. Ocor. do Sacado                                
              LPAD('0',03,'0')                                              || -- 22.3R - Cód. do Banco na Conta do Débito
              LPAD('0',05,'0')                                              || -- 23.3R - Código da Agência do Débito
              LPAD(' ',01,' ')                                              || -- 24.3R - Dígito Verificador da Agência
              LPAD('0',12,'0')                                              || -- 25.3R - Conta Corrente para Débito
              LPAD(' ',01,' ')                                              || -- 26.3R - Dígito Verificador da Conta
              LPAD(' ',01,' ')                                              || -- 27.3R - Dígito Verificador Ag/Conta
              '2'                                                           || -- 28.3R - Aviso para Débito Automático   
              LPAD(' ',9,' ')                                               || -- 29.3R - Uso Exclusivo FEBRABAN/CNAB
              CHR(13);
                
            -- Escreve Linha
            GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);
        
          END IF;
          
          -- Registro Detalhe - Segmento S  
                    
          -- Limpa Variaveis
          vr_tab_mensagem.DELETE;
          vr_tab_mensagem(1) := ' ';
          vr_tab_mensagem(2) := ' ';
          vr_tab_mensagem(3) := ' ';
          vr_tab_mensagem(4) := ' ';
 
          -- Busca Mensagem
          vr_inform := gene0002.fn_quebra_string(replace(rw_crapcob.dsinform,'__','_'), '_');
           
          -- Executa Apenas se Possuir Mensagem 
          IF vr_inform.count > 0 THEN
            
            FOR idx IN 1..vr_inform.count LOOP
              IF nvl(gene0002.fn_busca_entrada(1, vr_inform(idx), '#'),' ') <> ' ' THEN
                vr_tab_mensagem(idx) := gene0002.fn_busca_entrada(1, vr_inform(idx), '#');
              END IF;
            END LOOP;
            
            -- Quantidade Total de Linhas no Arquivo
            vr_qtd_registro := vr_qtd_registro + 1;
              
            -- Nro. Sequencial no Lote
            vr_nro_seq_lote := vr_nro_seq_lote + 1;
          
          
            -- O Layout Aplicado sera Diferente do Padrão FEBRABAN
            -- Iremos Usar 4 Mensagens de 50 posições e não 5 de 40 posições
            -- O valor da Identificação da Impressão será 4 
            
            -- Registro Detalhe - Segmento S  
            vr_setlinha:= '085'                               || -- 01.3S - Banco
              gene0002.fn_mask(vr_nrdolote,'9999')            || -- 02.3S - Lote 
              '3'                                             || -- 03.3S - Tipo Registro
              gene0002.fn_mask(vr_nro_seq_lote,'99999')       || -- 04.3S - Nro. do Registro
              'S'                                             || -- 05.3S - Segmento      
              LPAD(' ',1,' ')                                 || -- 06.3S - Uso Exclusivo FEBRABAN
              '01'                                            || -- 07.3S - Codigo de Movimento Remessa
              '4'                                             || -- 08.3S - Identificação da Impressão
              LPAD(NVL(vr_tab_mensagem(1),' '),50,' ')        || -- 09.3S - Mensagem 5
              LPAD(NVL(vr_tab_mensagem(2),' '),50,' ')        || -- 10.3S - Mensagem 6
              LPAD(NVL(vr_tab_mensagem(3),' '),50,' ')        || -- 11.3S - Mensagem 7
              LPAD(NVL(vr_tab_mensagem(4),' '),50,' ')        || -- 12.3S - Mensagem 8
              ''                                              || -- 13.3S - Mensagem 9
              LPAD(' ',22,' ')                                || -- 14.3S - Uso Exclusivo FEBRABAN/CNAB
              CHR(13);
                          
            -- Escreve Linha
            GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);              
          
          END IF;
          
          -- Quando Ultimo Registro da Conta/Convenio Escreve Trailer do Lote
          IF rw_crapcob.nrseq = rw_crapcob.qtreg THEN
                                    
            -- Quantidade Total de Linhas no Arquivo
            vr_qtd_registro := vr_qtd_registro + 1;
          
            -- Trailer do Lote
            vr_setlinha:= '085'                            || -- 01.5 - Banco
              '0001'                                       || -- 02.5 - Lote de Serviço
              '5'                                          || -- 03.5 - Registro Trailer de Lote
              LPAD(' ',9,' ')                              || -- 04.5 - Uso Exclusivo FEBRABAN
              gene0002.fn_mask(vr_nro_seq_lote,'999999')   || -- 05.5 - Qtd Registros do Lote
              LPAD(' ',06,' ')                             || -- 06.5 - Quantidade de Títulos em Cobrança
              LPAD(' ',17,' ')                             || -- 07.5 - Valor Total dosTítulos em Carteiras
              LPAD(' ',06,' ')                             || -- 08.5 - Quantidade de Títulos em Cobrança
              LPAD(' ',17,' ')                             || -- 09.5 - Valor Total dosTítulos em Carteiras
              LPAD(' ',06,' ')                             || -- 10.5 - Quantidade de Títulos em Cobrança
              LPAD(' ',17,' ')                             || -- 11.5 - Quantidade de Títulos em Carteiras                   
              LPAD(' ',06,' ')                             || -- 12.5 - Quantidade de Títulos em Cobrança
              LPAD(' ',17,' ')                             || -- 13.5 - Valor Total dosTítulos em Carteiras
              LPAD(' ',08,' ')                             || -- 14.5 - Número do Aviso de Lançamento
              LPAD(' ',117,' ')                            || -- 15.5 - Uso Exclusivo FEBRABAN/CNAB
              CHR(13);      
                          
            -- Escreve Linha do Trailer de Lote CNAB240 - Item 1.5
            GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);
          END IF;
          
        END LOOP;   -- Fim loop crapcob 
        
        -- Verifica se foi Gerado Arquivo
        IF vr_flg_gera_arq = TRUE THEN
          
          ------------- TRAILER DO ARQUIVO -------------
          -- Quantidade Total de Linhas no Arquivo
          vr_qtd_registro := vr_qtd_registro + 1;
          
          vr_setlinha:= '085'                          || -- 01.9 - Banco
            '9999'                                     || -- 02.9 - Lote de Serviço 
            '9'                                        || -- 03.9 - Tipo Registro
            LPAD(' ',9,' ')                            || -- 04.9 - Uso Exclusivo FEBRABAN
            gene0002.fn_mask(vr_nrdolote,'999999')     || -- 05.9 - Qtd de Lotes do Arquivo
            gene0002.fn_mask(vr_qtd_registro,'999999') || -- 06.9 - Qtd Registros do Arquivo
            gene0002.fn_mask(vr_nrdolote,'999999')     || -- 07.9 - Qtd Contas p/ Conciliar
            LPAD(' ',205,' ')                          || -- 08.9 - Uso Exclusivo FEBRABAN
            CHR(13);
          
          -- Escreve Linha do Trailer de Arquivo CNAB240 - Item 1.9
          GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);
          
                                                       
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);  
        
        
          -- Grava data/hora da Geração do Arquivo.          
          BEGIN
            UPDATE crapcee
              SET crapcee.dttransa = trunc(SYSDATE)
                 ,crapcee.hrtransa = to_number(to_char(SYSDATE,'SSSSS'))
             WHERE crapcee.rowid = vr_rowidcce;   
          
          EXCEPTION
            WHEN OTHERS THEN
             vr_dscritic := 'Erro ao atualizar tabela crapcee. '|| SQLERRM;
             --Sair do programa
             RAISE vr_exc_saida;
          END;

          -- Chamar o script que irá acessar WebService da PG e transmitir o arquivo;
          COBR0004.pc_upload_webservice_pg(vr_nmarquiv
                                          ,vr_erro_envio);
          
          
          -- Caso Retorne Erro
          IF TRIM(vr_erro_envio) IS NOT NULL THEN
            vr_dsmensag := 'Titulo sera enviado p/ impressao manualmente';
            
            -- Atualiza o campo insitmvt para "Não Enviado" 
            BEGIN
              UPDATE crapcee
                 SET crapcee.insitmvt = 4
               WHERE crapcee.rowid = vr_rowidcce;   
            
            EXCEPTION
              WHEN OTHERS THEN
               vr_dscritic := 'Erro ao atualizar tabela crapcee. '|| SQLERRM;
               --Sair do programa
               RAISE vr_exc_saida;
            END;
            
            -- Mover o arquivo gerado para a pasta /micros/cecred/cobranca
            gene0001.pc_OScommand_Shell('mv ' || vr_nmdireto || '/' || vr_nmarquiv || ' ' || 
                                        vr_nmdirmic || '/' || vr_nmarquiv);
                                        
            -- Limpa variavel
            vr_dscritic := NULL;
                                                          
            -- Enviar e-mail informando erro
            GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                      ,pr_cdprogra        => vr_cdprogra
                                      ,pr_des_destino     => vr_des_destino
                                      ,pr_des_assunto     => 'Erro ao transmitir Arquivo PG '
                                      ,pr_des_corpo       => 'Erro ao transmitir Arquivo PG - ' || rw_crapcop.nmrescop || ' - ' || TO_CHAR(rw_crabdat.dtmvtolt,'DD/MM/RRRR') || ' - ' || vr_nmarquiv || chr(13) || vr_erro_envio
                                      ,pr_des_anexo       => NULL
                                      ,pr_des_erro        => vr_dscritic);

            -- Verificar se houve erro ao solicitar e-mail
            IF vr_dscritic IS NOT NULL THEN
              -- Não gerar critica
              vr_cdcritic := 0;
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic );
            END IF;                                      
            
          ELSE
            vr_dsmensag := 'Boleto enviado para impressao e postagem nos correios';
            
            -- Mover o arquivo gerado para a pasta /usr/coop/<cooperativa>/salvar
            gene0001.pc_OScommand_Shell('mv ' || vr_nmdireto || '/' || vr_nmarquiv || ' ' || 
                                        vr_nmdirslv || '/' || vr_nmarquiv);
                                        
            -- Atualiza o campo cdidejob com o valor retornado. -- Daniel
            BEGIN
              UPDATE crapcee
                 SET crapcee.cdidejob = vr_cdidejob -- Codigo do JOB
                    ,crapcee.insitmvt = 2 -- Enviado 
                    ,crapcee.dttransa = rw_crabdat.dtmvtolt
                    ,crapcee.hrtransa = to_number(to_char(SYSDATE,'SSSSS'))
               WHERE crapcee.rowid = vr_rowidcce;   
            
            EXCEPTION
              WHEN OTHERS THEN
               vr_dscritic := 'Erro ao atualizar tabela crapcee. '|| SQLERRM;
               --Sair do programa
               RAISE vr_exc_saida;
            END;                            
                                      
          END IF;  
          
          -- Atualiza Titulos
          FOR idx IN 1..vr_tab_crapcob.Count LOOP 
            
            BEGIN
              UPDATE crapcob
                 SET crapcob.inemiexp = 2
                    ,crapcob.dtemiexp = rw_crabdat.dtmvtolt
               WHERE crapcob.cdcooper = vr_tab_crapcob(idx).cdcooper 
                 AND crapcob.cdbandoc = vr_tab_crapcob(idx).cdbandoc 
                 AND crapcob.nrdctabb = vr_tab_crapcob(idx).nrdctabb 
                 AND crapcob.nrcnvcob = vr_tab_crapcob(idx).nrcnvcob 
                 AND crapcob.nrdconta = vr_tab_crapcob(idx).nrdconta 
                 AND crapcob.nrdocmto = vr_tab_crapcob(idx).nrdocmto
              RETURNING ROWID
                   INTO vr_rowidcob;
                      
              -- Criar Log Cobranca 

              PAGA0001.pc_cria_log_cobranca(pr_idtabcob => vr_rowidcob         --ROWID da Cobranca
                                           ,pr_cdoperad => 1                   --Operador
                                           ,pr_dtmvtolt => rw_crabdat.dtmvtolt --Data movimento
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
          
          END LOOP;  
        
        END IF;
   
        IF vr_flg_gera_arq = TRUE THEN
          
          -- Gerar Relatorio
          vr_indice := vr_tab_relatorio.first;  
          WHILE vr_indice IS NOT NULL LOOP  
            pc_escreve_xml(
             '<conta>' ||
               '<cdagenci>'||  vr_tab_relatorio(vr_indice).cdagenci                         ||'</cdagenci>'|| 
               '<nrdconta>'||  gene0002.fn_mask_conta(vr_tab_relatorio(vr_indice).nrdconta) ||'</nrdconta>'|| 
               '<nrcnvcob>'||  vr_tab_relatorio(vr_indice).nrcnvcob                         ||'</nrcnvcob>'|| 
               '<qtdtotal>'||  vr_tab_relatorio(vr_indice).qtdtotal                         ||'</qtdtotal>'|| 
               '<vltitulo>'||  vr_tab_relatorio(vr_indice).vltitulo                         ||'</vltitulo>'|| 
             '</conta>');
             
            vr_indice := vr_tab_relatorio.next(vr_indice);
          END LOOP;
          
          pc_escreve_xml(
             '</contas>' || 
             '<total>' ||
               '<qtdtotal>'||  vr_qtdtotal    ||'</qtdtotal>'|| 
               '<vltitulo>'||  vr_vlrtotal    ||'</vltitulo>'|| 
             '</total>');
          
          
          pc_escreve_xml('</crrl700></raiz>',TRUE);               
          
          -- Ao terminar de ler os registros, iremos gravar o XML para arquivo totalizador--
          gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop.cdcooper,          --> Cooperativa conectada
                                      pr_cdprogra  => vr_cdprogra,                  --> Programa chamador
                                      pr_dtmvtolt  => rw_crabdat.dtmvtolt,          --> Data do movimento atual
                                      pr_dsxml     => vr_des_xml,                   --> Arquivo XML de dados (CLOB)
                                      pr_dsxmlnode => '/raiz/crrl700/contas/conta', --> Nó base do XML para leitura dos dados
                                      pr_dsjasper  => 'crrl700.jasper',             --> Arquivo de layout do iReport
                                      pr_dsparams  => NULL,                         --> Enviar como parâmetro apenas a agência
                                      pr_dsarqsaid => vr_nmdirrel || '/' || vr_nmarqimp, --> Arquivo final com código da agência
                                      pr_flg_gerar => 'S',
                                      pr_qtcoluna  => 80,
                                      pr_flg_impri => 'S',                           --> Chamar a impressão (Imprim.p)
                                      pr_nmformul  => '80col',                       --> Nome do formulário para impressão
                                      pr_nrcopias  => 1,                             --> Número de cópias para impressão
                                      pr_des_erro  => vr_dscritic);                  --> Saída com erro
          /*
          -- Gerar o xml para teste
          gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                       ,pr_caminho  => vr_nmdireto 
                                       ,pr_arquivo  => vr_nmarqimp || to_char(rw_crapcop.cdcooper) || '.xml'
                                       ,pr_des_erro => vr_dscritic);
          */   
          
          vr_tab_email(rw_crapcop.cdcooper).cdcooper := rw_crapcop.cdcooper;
          vr_tab_email(rw_crapcop.cdcooper).nmarquiv := vr_nmarquiv;
          vr_tab_email(rw_crapcop.cdcooper).vltitulo := vr_qtdtotal;
          vr_tab_email(rw_crapcop.cdcooper).qtdtotal := vr_vlrtotal;
                    
                                             
        END IF;                               
        
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);   
        
        /* Busca todos os convenios da IF CECRED que foram gerados pela internet */
        FOR rw_crapcco IN cr_crapcco_ativo (pr_cdcooper => rw_crapcop.cdcooper
                                            ,pr_cddbanco => rw_crapcop.cdbcoctl) LOOP        
        
            PAGA0001.pc_realiza_lancto_cooperado (pr_cdcooper => rw_crapcco.cdcooper --Codigo Cooperativa
                                                 ,pr_dtmvtolt => rw_crabdat.dtmvtolt --Data Movimento
                                                 ,pr_cdagenci => rw_crapcco.cdagenci --Codigo Agencia
                                                 ,pr_cdbccxlt => rw_crapcco.cdbccxlt --Codigo banco caixa
                                                 ,pr_nrdolote => rw_crapcco.nrdolote --Numero do Lote
                                                 ,pr_cdpesqbb => rw_crapcco.nrconven --Codigo Convenio
                                                 ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                                 ,pr_dscritic => vr_dscritic         --Descricao Critica
                                                 ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada);        --Tabela Lancamentos
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;        
             
        END LOOP;
   
        -- Salva Informações Para Cada Cooperativa Processada
        -- COMMIT;
        
      EXCEPTION
        WHEN vr_exc_next THEN
          
          -- Verifica se o arquivo esta aberto
          IF utl_file.IS_OPEN(vr_ind_arquivo) THEN
            -- Fechar o arquivo
            GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo); 
          END IF;
          
          -- Descrição do Erro
          IF vr_dscritic IS NULL THEN
             vr_dscritic := 'Erro na Geracao arquivo de impressao PG ';
          END IF;   
          
          -- Envio Centralizado de Log de Erro
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- ERRO TRATATO
                                     pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                        ' -' || vr_cdprogra || ' --> ' ||
                                                        vr_dscritic  || ' -' || rw_crapcop.nmrescop);
          -- Limpa variavel
          vr_dscritic := NULL;
                                                        
          -- Enviar e-mail informando erro
          GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => vr_cdprogra
                                    ,pr_des_destino     => vr_des_destino
                                    ,pr_des_assunto     => 'Erro na Geracao Arquivo PG '
                                    ,pr_des_corpo       => 'Erro na Geracao Arquivo de Impressao PG - ' || rw_crapcop.nmrescop || ' - ' || TO_CHAR(rw_crabdat.dtmvtolt,'DD/MM/RRRR') || ' - ' || vr_nmarquiv
                                    ,pr_des_anexo       => NULL
                                    ,pr_des_erro        => vr_dscritic);

          -- Verificar se houve erro ao solicitar e-mail
          IF vr_dscritic IS NOT NULL THEN
            -- Não gerar critica
            vr_cdcritic := 0;
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic );
          END IF;                                              
                                                        
          -- Desfaz  
          ROLLBACK;
      END;  
                     
    END LOOP; -- Fim LOOP crapcop  
    
    -- Montar o cabeçalho do html e o alerta
    vr_dscorpo := '<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >';
    vr_dscorpo := vr_dscorpo || 'Segue listagem de arquivos enviados PG.';
    vr_dscorpo := vr_dscorpo || '</meta>';

    vr_dscorpo := vr_dscorpo || '<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >';
    vr_dscorpo := vr_dscorpo || '<table border="1" style="width:500px; margin: 10px auto; font-family: Tahoma,sans-serif; font-size: 12px; color: #686868;" >';
    -- Montando header
    vr_dscorpo := vr_dscorpo || '<th>Coop.</th>';
    vr_dscorpo := vr_dscorpo || '<th>Arquivo</th>';
    vr_dscorpo := vr_dscorpo || '<th>Quantidade</th>';
    vr_dscorpo := vr_dscorpo || '<th>Valor</th>';
    
    -- Gerar Relatorio Email
    vr_indice := vr_tab_email.first;  
    WHILE vr_indice IS NOT NULL LOOP  
      --  Cooperativa | Arquivo | Qtd de boletos | Vlr total dos boletos;    
    
      -- Para cada registro, montar sua tr
      vr_dscorpo := vr_dscorpo || '<tr>';
      -- E os detalhes do registro
      vr_dscorpo := vr_dscorpo || '<td>'||to_char(vr_tab_email(vr_indice).cdcooper) ||'</td>';
      vr_dscorpo := vr_dscorpo || '<td>'||to_char(vr_tab_email(vr_indice).nmarquiv) ||'</td>';
      vr_dscorpo := vr_dscorpo || '<td>'||to_char(vr_tab_email(vr_indice).vltitulo) ||'</td>';
      vr_dscorpo := vr_dscorpo || '<td>'||to_char(vr_tab_email(vr_indice).qtdtotal) ||'</td>';
      -- Encerrar a tr
      vr_dscorpo := vr_dscorpo || '</tr>';
             
      vr_indice := vr_tab_email.next(vr_indice);
    END LOOP;
    
    vr_dscorpo := vr_dscorpo || '</table>';
    vr_dscorpo := vr_dscorpo || '</meta>';  
    
    -- Enviar e-mail informando erro
    GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                              ,pr_cdprogra        => vr_cdprogra
                              ,pr_des_destino     => vr_des_destino
                              ,pr_des_assunto     => 'Cobrança - Remessa PG'
                              ,pr_des_corpo       => vr_dscorpo
                              ,pr_des_anexo       => NULL
                              ,pr_des_erro        => vr_dscritic);

    -- Verificar se houve erro ao solicitar e-mail
    IF vr_dscritic IS NOT NULL THEN
      -- Não gerar critica
      vr_cdcritic := 0;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic );
    END IF;      
     

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Finaliza Execução do Programa
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- Salvar Informações
    COMMIT;

  EXCEPTION
  WHEN vr_exc_fimprg THEN

    -- Se retornou apenas o codigo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Busca Descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;

    -- Se foi gerado critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN

      -- Envio Centralizado de Log de Erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- ERRO TRATATO
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                    ' -' || vr_cdprogra || ' --> ' ||
                                                    vr_dscritic);

    END IF;

    -- Chamos o pc_valida_fimprg para encerrar o processo sem parar a cadeia
    BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- Salva informações no banco de dados
    COMMIT;
      
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
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

END pc_crps693;
/
