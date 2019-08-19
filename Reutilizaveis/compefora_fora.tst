PL/SQL Developer Test script 3.0
7536
-- Created on 31/07/2019 by F0030344 
DECLARE  

  pg_stprogra PLS_INTEGER;            --> Saida de termino da execucao
  pg_infimsol PLS_INTEGER;            --> Saida de termino da solicitacao
  pg_cdcritic crapcri.cdcritic%TYPE;  --> Codigo da Critica
  pg_dscritic crapcri.dscritic%TYPE;  --> Descricao da Critica

  CURSOR cr_tdcoop IS
    SELECT *
      FROM crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3
    ORDER BY c.cdcooper;


--################################# 346 INICIO ################################################################
PROCEDURE PC_CRPS346(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                     ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                     ,pr_nmtelant  IN VARCHAR2               --> Tela chamadora
                     ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                     ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                     ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
  /* ..........................................................................

   Programa: PC_CRPS346                               Antigo : Fontes/crps346.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/2003.                         Ultima atualizacao: 12/07/2018

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Processar as integracoes da compensacao do Banco do Brasil via
               arquivo DEB558.
               Emite relatorio 291.
   ............................................................................. */

  -- Constantes do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS346';
  vr_cdagenci CONSTANT PLS_INTEGER := 1;
  vr_cdbccxlt CONSTANT PLS_INTEGER := 1;
  
  -- Tratamento de erros
  vr_exc_fimprg EXCEPTION;
  vr_exc_saida  EXCEPTION;

  vr_dscritic   varchar2(4000);
  vr_cdcritic   crapcri.cdcritic%TYPE := 0;

  /* Busca dos dados da cooperativa */
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.cdageitg
          ,cop.cdagebcb
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  /* Cursor generico de calendario */
  RW_CRAPDAT BTCH0001.CR_CRAPDAT%ROWTYPE;
  
  -- Variaveis auxiliares para o tratamento do arquivo
  vr_conteudo varchar2(2000);
  vr_nmdircop varchar2(200);
  vr_dtleiarq DATE;
  vr_flgarqui BOOLEAN;
  vr_dstextab craptab.dstextab%TYPE;
  vr_nomedarq varchar2(200);
  vr_dslisarq VARCHAR2(1000);
  vr_splisarq gene0002.typ_split;
  vr_typsaida varchar2(3);
  vr_dessaida varchar2(2000);
  vr_flgchqbb BOOLEAN;
  vr_vlchqvlb NUMBER;
  
  -- Valor dos maiores cheques do BB - 3000,00 - nao usa da tabela 
  -- pois a tabela eh usada em outros programas
  vr_vlmaichq NUMBER(18,2) := 3000; 

  -- Estrutura para separar numericos de campo texto separado por ","
  TYPE typ_tab_valores_n IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
  TYPE typ_tab_valores_t IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);  

  -- Operacoes a processar
  vr_tab_hstchq typ_tab_valores_t;
  vr_tab_hstblq typ_tab_valores_t;
  vr_tab_hstdep typ_tab_valores_t;
  vr_tab_hstcob typ_tab_valores_t;
  vr_dshstblq varchar2(1000);
  
  /*  codigo de agencia com digito calculado: ex. 3164-01 = 3164012  */
  vr_tab_lsagenci typ_tab_valores_n;
  
  -- Lista de contas dos convênios
  vr_tab_contas typ_tab_valores_n;
  vr_tab_conta2 typ_tab_valores_n; 
  vr_tab_conta3 typ_tab_valores_n;
  
  -- Controladores a cada loop de Cooperativa
  vr_nrdolote pls_integer;
  vr_nrdlinha pls_integer;
  vr_flgarqvz boolean;
  vr_flgfirst boolean;
  vr_flgentra boolean;
  vr_flgclote boolean;
  
  -- Arquivo e informações em leitura 
  vr_arqhandle utl_file.file_type;
  vr_dslinharq varchar2(4000);
  vr_nrdctabb number(8);
  vr_nrseqint PLS_INTEGER;
  vr_dshistor VARCHAR2(30);
  vr_nrdocmto PLS_INTEGER;
  vr_nrdocmt2 PLS_INTEGER;
  vr_nrcalcul PLS_INTEGER;
  vr_stsnrcal BOOLEAN;
  vr_stsnrcal_int PLS_INTEGER;
  vr_dsdctitg VARCHAR2(30);
  vr_vllanmto NUMBER(16,2);
  vr_dtmvtolt DATE;
  vr_indebcre CHAR(1);
  vr_cdpesqbb VARCHAR2(13);
  vr_dsageori VARCHAR2(7);
  vr_dtrefere DATE;
  vr_nrdconta PLS_INTEGER;
  vr_indevchq PLS_INTEGER;
  vr_cdalinea PLS_INTEGER := 0;
  vr_flgcontr BOOLEAN;
  vr_flgdepos BOOLEAN;
  vr_flgchequ BOOLEAN;
  vr_cobranca BOOLEAN;
  vr_dtliblan DATE;
  vr_cdhistor PLS_INTEGER;
  vr_nrdiautl PLS_INTEGER := 0;
  vr_dsintegr VARCHAR2(30);
  
  -- Totais para o relatório 
  vr_tot_qtintdeb PLS_INTEGER := 0;
  vr_tot_vlintdeb NUMBER      := 0;
  vr_tot_qtintcre PLS_INTEGER := 0;
  vr_tot_vlintcre NUMBER      := 0;
  
  --Chamado 696499
  --Variaveis de inclusão de log 
  vr_idprglog     tbgen_prglog.idprglog%TYPE := 0;      
   
  -- PJ450 - Regulatório de crédito
  vr_rcraplot       LANC0001.cr_craplot%ROWTYPE; 
  vr_incrineg       INTEGER;      --> Indicador de crítica de negócio para uso com a "pc_gerar_lancamento_conta"
  vr_tab_retorno    LANC0001.typ_reg_retorno;
  vr_fldebita       BOOLEAN DEFAULT TRUE;
     
  -- Tipos para gravação dos totais integrados 
  TYPE typ_reg_totais IS RECORD(vlcompdb NUMBER 
                               ,qtcompdb PLS_INTEGER
                               ,vlcompcr NUMBER
                               ,qtcompcr PLS_INTEGER);
  TYPE typ_tab_totais IS TABLE OF typ_reg_totais INDEX BY PLS_INTEGER;
  vr_tab_totais typ_tab_totais;
  
  -- Totais dos saldos
  vr_ger_vlbloque NUMBER;
  
  -- Variaveis de controle xml
  vr_xmlrel CLOB;
  vr_txtrel VARCHAR2(32767);
  
  -- Estrutura para as leitura de várias cooperativas (Incorporação)
  TYPE typ_reg_crapcop IS RECORD (cdcooper PLS_INTEGER
                                 ,cdconven PLS_INTEGER
                                 ,nmarquiv VARCHAR2(1000)
                                 ,nmarqimp VARCHAR2(1000));                                   
  TYPE typ_tab_crapcop IS TABLE OF typ_reg_crapcop INDEX BY PLS_INTEGER;
  vr_tab_crapcop typ_tab_crapcop;  
  
  -- Estrutura para alimentar os saldos das contas
  TYPE typ_reg_crawdpb IS RECORD (vldispon NUMBER
                                 ,vlblq001 NUMBER
                                 ,vlblq002 NUMBER
                                 ,vlblq003 NUMBER
                                 ,vlblq004 NUMBER
                                 ,vlblq999 NUMBER); 
  TYPE typ_tab_crawdpb IS TABLE OF typ_reg_crawdpb INDEX BY PLS_INTEGER;
  vr_tab_crawdpb typ_tab_crawdpb;
  
  -- Tipo para armazenar valores do lote
  TYPE typ_reg_craplot IS RECORD(nrrowid  rowid
                                ,dtmvtolt craplot.dtmvtolt%type
                                ,cdagenci craplot.cdagenci%type
                                ,cdbccxlt craplot.cdbccxlt%type
                                ,nrdolote craplot.nrdolote%type
                                ,tplotmov craplot.tplotmov%type
                                ,qtinfoln craplot.qtinfoln%type
                                ,qtcompln craplot.qtcompln%type
                                ,vlinfodb craplot.vlinfodb%type
                                ,vlcompdb craplot.vlcompdb%type
                                ,vlinfocr craplot.vlinfocr%type
                                ,vlcompcr craplot.vlcompcr%type
                                ,nrseqdig craplot.nrseqdig%type);
  rw_craplot typ_reg_craplot;
  
  -- Buscar Folhas de Cheque 
  CURSOR cr_crapfdc(pr_cdageitg NUMBER 
                   ,pr_nrctachq NUMBER 
                   ,pr_nrcheque NUMBER) IS
    SELECT nrdconta
          ,incheque
          ,vlcheque
          ,dtemschq
          ,dtretchq  
          ,tpcheque
          ,cdbanchq
          ,cdagechq
          ,nrctachq
          ,rowid 
      FROM crapfdc 
     WHERE cdcooper = pr_cdcooper 
       AND cdbanchq = 1
       AND cdagechq = pr_cdageitg 
       AND nrctachq = pr_nrctachq 
       AND nrcheque = pr_nrcheque;
  rw_crapfdc cr_crapfdc%Rowtype;
  
  -- Busca do cadastro de associados
  CURSOR cr_crapass(pr_nrdconta NUMBER) IS
    SELECT cdsitdtl
          ,dtelimin
          ,cdagenci
      FROM crapass
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%rowtype;
  
  -- Busca lançamento para o cheque no dia
  CURSOR cr_craplcm_cheque(pr_nrdolote craplcm.nrdolote%type
                          ,pr_nrdctabb craplcm.nrdctabb%type
                          ,pr_nrdocmto craplcm.nrdocmto%type) IS
    SELECT 1
      FROM craplcm 
     WHERE craplcm.cdcooper = pr_cdcooper
       AND craplcm.dtmvtolt = rw_crapdat.dtmvtolt
       AND craplcm.cdagenci = vr_cdagenci
       AND craplcm.cdbccxlt = vr_cdbccxlt
       AND craplcm.nrdolote = pr_nrdolote
       AND craplcm.nrdctabb = pr_nrdctabb
       AND craplcm.nrdocmto = pr_nrdocmto;             
  vr_flgexis NUMBER;
       
  CURSOR cr_craplcm_cheque_cor(pr_nrdconta craplcm.nrdconta%type
                              ,pr_nrdocmto craplcm.nrdocmto%type) IS
    SELECT dtmvtolt 
      FROM craplcm 
     WHERE craplcm.cdcooper = pr_cdcooper
       AND craplcm.nrdconta = pr_nrdconta
       AND craplcm.nrdocmto = pr_nrdocmto
       AND craplcm.cdhistor in(21,50)
     ORDER BY dtmvtolt DESC; 
  rw_craplcm_cor cr_craplcm_cheque_cor%ROWTYPE;
  
  -- Buscar contra ordem no cheque
  CURSOR cr_crapcor(pr_cdageitg NUMBER 
                   ,pr_nrdctabb NUMBER 
                   ,pr_nrdocmto NUMBER ) IS
    SELECT dtvalcor
          ,dtemscor
          ,cdhistor
      FROM crapcor 
     WHERE cdcooper = pr_cdcooper
       AND cdbanchq = 1                
       AND cdagechq = pr_cdageitg 
       AND nrctachq = pr_nrdctabb     
       AND nrcheque = pr_nrdocmto     
       AND flgativo = 1;
  rw_crapcor cr_crapcor%ROWTYPE;   
     
  -- Buscar negativação vinculada ao cheque 
  CURSOR cr_crapneg(pr_nrdconta craplcm.nrdconta%type
                   ,pr_nrdocmto craplcm.nrdocmto%type) IS
    SELECT 1
      FROM crapneg 
     WHERE cdcooper = pr_cdcooper 
       AND nrdconta = pr_nrdconta 
       AND nrdocmto = pr_nrdocmto 
       AND cdhisest = 1
       AND cdobserv in(12,13)
       AND dtfimest is null;
  
  -- Busca do indicador de D/C do Histórico
  CURSOR cr_craphis(pr_cdcooper NUMBER 
                   ,pr_cdhistor NUMBER) IS
    SELECT indebcre 
      FROM craphis 
     WHERE cdcooper = pr_cdcooper 
       AND cdhistor = pr_cdhistor;                        
  
  -- Busca dos registros rejeitos
  CURSOR cr_craprej(pr_cdcooper NUMBER 
                   ,pr_nrdolote NUMBER) IS 
    SELECT cdcritic
          ,nrseqdig
          ,dshistor
          ,nrdctabb
          ,dtrefere
          ,nrdocmto
          ,cdpesqbb
          ,vllanmto
          ,indebcre
          ,nrdconta
      FROM craprej 
     WHERE cdcooper = pr_cdcooper 
       AND dtmvtolt = rw_crapdat.dtmvtolt 
       AND cdagenci = vr_cdagenci
       AND cdbccxlt = vr_cdbccxlt
       AND nrdolote = pr_nrdolote
       AND tpintegr = 1
     ORDER BY dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,tpintegr
             ,nrdctabb
             ,dtdaviso
             ,nrdocmto
             ,nrseqdig;
  
  -- Leitura dos lancamentos integrados  --  Maiores cheques
  CURSOR cr_craplcm_integra(pr_nrdolote NUMBER) IS
    SELECT nrdctabb
          ,nrdocmto
          ,nrdconta
          ,cdhistor
          ,vllanmto
          ,cdpesqbb
          ,nrseqdig
      FROM craplcm 
     WHERE cdcooper  = pr_cdcooper   
       AND dtmvtolt  = rw_crapdat.dtmvtolt
       AND cdagenci  = vr_cdagenci
       AND cdbccxlt  = vr_cdbccxlt
       AND nrdolote  = pr_nrdolote
       AND cdhistor IN(50,59)         
       AND vllanmto >= vr_vlmaichq;
  
  -- Função genérica para converter valores num texto separado por "," para pltable numérica
  FUNCTION fn_converte_texto_vetor_n(pr_dstexto in varchar2) RETURN typ_tab_valores_n IS
    -- Tipos para transformação de lista texto em vetor
    vr_tab_split   gene0002.typ_split;
    vr_tab_valores typ_tab_valores_n;
  BEGIN
    -- Joga as contas em uma temp-table
    vr_tab_split := gene0002.fn_quebra_string(pr_dstexto,',');
    -- Varre a tabela criando registros na tabela de retorno 
    IF vr_tab_split.count() > 0 THEN
      -- Itera sobre o array para pesquisar seus objetos
      FOR idx IN 1..vr_tab_split.count() LOOP
        -- Criar o registro na tabela (tratar em bloco pra evitar erro no formato)
        vr_tab_valores(vr_tab_split(idx)) := vr_tab_split(idx);
      END LOOP;
    END IF;
    -- Retornar tabela convertida 
    RETURN vr_tab_valores;
  END;
  
  -- Função genérica para converter valores num texto separado por "," para pltable alfanumérica
  FUNCTION fn_converte_texto_vetor_t(pr_dstexto in varchar2) RETURN typ_tab_valores_t IS
    -- Tipos para transformação de lista texto em vetor
    vr_tab_split   gene0002.typ_split;
    vr_tab_valores typ_tab_valores_t;
  BEGIN
    -- Joga as contas em uma temp-table
    vr_tab_split := gene0002.fn_quebra_string(pr_dstexto,',');
    -- Varre a tabela criando registros na tabela de retorno 
    IF vr_tab_split.count() > 0 THEN
      -- Itera sobre o array para pesquisar seus objetos
      FOR idx IN 1..vr_tab_split.count() LOOP
        -- Criar o registro na tabela (tratar em bloco pra evitar erro no formato)
        vr_tab_valores(vr_tab_split(idx)) := vr_tab_split(idx);
      END LOOP;
    END IF;
    -- Retornar tabela convertida 
    RETURN vr_tab_valores;
  END;
  
  
  -- Subrotina para processamento dos saldos e gravacao em temp-table
  PROCEDURE pc_leitura_saldos(pr_dslinhar  IN VARCHAR2
                             ,pr_nrdctabb  IN pls_integer
                             ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    --Inclusão nome do módulo logado - Chamado 696499
    gene0001.pc_set_modulo(pr_module => 'PC_CRPS346'
                          ,pr_action => 'pc_leitura_saldos');

    -- Somente se houver Registro de Saldo
    IF substr(pr_dslinhar,42,1) = '0' OR substr(pr_dslinhar,42,1) = '2' THEN 
      -- Verifica se existe registro na temp-table
      IF NOT vr_tab_crawdpb.exists(pr_nrdctabb) THEN 
        -- Criarmos o registro zerado para evitar no-data-found 
        vr_tab_crawdpb(pr_nrdctabb).vldispon := 0;
        vr_tab_crawdpb(pr_nrdctabb).vlblq001 := 0;
        vr_tab_crawdpb(pr_nrdctabb).vlblq002 := 0;
        vr_tab_crawdpb(pr_nrdctabb).vlblq003 := 0;
        vr_tab_crawdpb(pr_nrdctabb).vlblq004 := 0;
        vr_tab_crawdpb(pr_nrdctabb).vlblq999 := 0;
      END IF;
      -- Para registro do tipo 2
      IF substr(pr_dslinhar,42,1) = '2' THEN
        -- Incrementer saldo disponível
        vr_tab_crawdpb(pr_nrdctabb).vldispon := vr_tab_crawdpb(pr_nrdctabb).vldispon +
                                                (to_number(nvl(trim(substr(pr_dslinhar,087,18)),0)) / 100);
      ELSE 
        -- Incrementar valores bloqueados
        vr_tab_crawdpb(pr_nrdctabb).vlblq001 := vr_tab_crawdpb(pr_nrdctabb).vlblq001 +
                                                (to_number(nvl(trim(substr(pr_dslinhar,157,17)),0)) / 100);
        vr_tab_crawdpb(pr_nrdctabb).vlblq002 := vr_tab_crawdpb(pr_nrdctabb).vlblq002 +
                                                (to_number(nvl(trim(substr(pr_dslinhar,140,17)),0)) / 100);
        vr_tab_crawdpb(pr_nrdctabb).vlblq003 := vr_tab_crawdpb(pr_nrdctabb).vlblq003 +
                                                (to_number(nvl(trim(substr(pr_dslinhar,123,17)),0)) / 100);
        vr_tab_crawdpb(pr_nrdctabb).vlblq004 := vr_tab_crawdpb(pr_nrdctabb).vlblq004 +
                                                (to_number(nvl(trim(substr(pr_dslinhar,106,17)),0)) / 100);
        vr_tab_crawdpb(pr_nrdctabb).vlblq999 := vr_tab_crawdpb(pr_nrdctabb).vlblq999 +
                                                (to_number(nvl(trim(substr(pr_dslinhar,043,17)),0)) / 100);
      END IF;                                          
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      --Inclusão na tabela de erros Oracle - Chamado 696499
      CECRED.pc_internal_exception( pr_cdcooper => NULL
                                   ,pr_compleme => pr_dscritic );

      pr_dscritic := 'Erro nao tratado na leitura do saldo --> '||sqlerrm;
  END;
  
BEGIN
  -- Incluir nome do modulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => null);
                            
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
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
  END IF;

  -- Leitura do calendario da cooperativa
  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat
   INTO rw_crapdat;
  -- Se nao encontrar
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE btch0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE btch0001.cr_crapdat;
  END IF;

  -- Validacoes iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);
  -- Se a variavel de erro e <> 0
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;
  
  -- Busca do diretório Integracao
  vr_nmdircop := gene0001.fn_diretorio('C',pr_cdcooper);
  
  -- Caso execução pela COMPEFORA
  IF pr_nmtelant = 'COMPEFORA' THEN
    vr_dtleiarq := rw_crapdat.dtmvtoan;    
  ELSE
    vr_dtleiarq := rw_crapdat.dtmvtolt;
  END IF;   
   
  -- Criar registros na Temp-Table de Cooperativas a processar
  vr_tab_crapcop(1).cdcooper := pr_cdcooper;
  
  -- Tratar incorporações
  IF pr_cdcooper = 1 THEN
    vr_tab_crapcop(2).cdcooper := 4;  /* Incorporacao Concredi */
  ELSIF pr_cdcooper = 13 THEN
    vr_tab_crapcop(2).cdcooper := 15; /* Incorporacao Credimilsul */
  ELSIF pr_cdcooper = 9 THEN
    vr_tab_crapcop(2).cdcooper := 17; /* Incorporacao Transulcred */
  END IF;
    
  -- inicializar variavel de controle se existe algum arquivo a ser processado
  vr_flgarqui := FALSE;
  
  -- Buscar todos os arquivos da pasta COMPBB conforme convenio da CRAPTAB
  FOR vr_idx IN 1..vr_tab_crapcop.COUNT LOOP
    -- Armazenar o nome do arquivo que deverá estar na Integra para o processo continuar
    vr_tab_crapcop(vr_idx).nmarquiv := 'deb558_346_' 
                                    || to_char(vr_dtleiarq,'rrrrmmdd')
                                    || '_' || to_char(vr_tab_crapcop(vr_idx).cdcooper,'fm00')||'.bb';

    -- Buscar o convênio conforme CRAPTAB
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => vr_tab_crapcop(vr_idx).cdcooper 
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'COMPEARQBB'
                                             ,pr_tpregist => 346);

    -- Se não encontrar
    IF trim(vr_dstextab) IS NULL THEN
      -- Gerar critica 55
      vr_cdcritic := 55;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' (COMPEARQBB)';
      RAISE vr_exc_saida;
    ELSE
      -- Guardar numero do convênio
      vr_tab_crapcop(vr_idx).cdconven := SUBSTR(vr_dstextab,1,9);

      -- Busca o arquivo DEB558 em um unico arquivo 
      vr_nomedarq := 'deb558%'||to_char(vr_dtleiarq,'DDMMRR')||'%'||to_char(vr_tab_crapcop(vr_idx).cdconven,'fm000000000') || '%';
      
      -- Busca os arquivos da pasta compbb
      gene0001.pc_lista_arquivos(vr_nmdircop||'/compbb', vr_nomedarq, vr_dslisarq, vr_dscritic);

      -- Se houver erro
      IF vr_dscritic IS NOT NULL THEN 
        RAISE vr_exc_saida;
      END IF;
      -- Separa a lista de arquivos em uma tabela com todos os encontrados
      vr_splisarq := gene0002.fn_quebra_string(vr_dslisarq, ',');
      -- Verifica se a quebra resultou em um array válido
      IF vr_splisarq.count() > 0 THEN
        -- Iterar sob cada arquivo encontrado
        FOR idx IN 1..vr_splisarq.count() LOOP
          -- Para cada arquivo, movê-lo para a integra renomeando-o
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'mv ' || vr_nmdircop||'/compbb/'||vr_splisarq(idx) || ' ' 
                                                              || vr_nmdircop||'/integra/'||vr_tab_crapcop(vr_idx).nmarquiv
                                     ,pr_typ_saida => vr_typsaida
                                     ,pr_des_saida => vr_dessaida);
          -- Havendo erro, finalizar
          IF vr_typsaida = 'ERR' THEN
            vr_dscritic := vr_dessaida;
            RAISE vr_exc_saida;
          END IF;        
        END LOOP;  
      END IF;
    END IF;  
  END LOOP;

  -- Se a tabela abaixo existir, deve processar os arquivos de deposito
  vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                           ,pr_nmsistem => 'CRED'
                                           ,pr_tptabela => 'GENERI'
                                           ,pr_cdempres => 0
                                           ,pr_cdacesso => 'COMPECHQBB'
                                           ,pr_tpregist => 0);

  IF trim(vr_dstextab) IS NULL THEN
    vr_flgchqbb := FALSE;
  ELSE
    vr_flgchqbb := TRUE;
  END IF;  
    
  -- Buscar valores VLB
  vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                           ,pr_nmsistem => 'CRED'
                                           ,pr_tptabela => 'GENERI'
                                           ,pr_cdempres => 0
                                           ,pr_cdacesso => 'VALORESVLB'
                                           ,pr_tpregist => 0);

  IF trim(vr_dstextab) IS NOT NULL THEN
    vr_vlchqvlb := to_number(gene0002.fn_busca_entrada(2,vr_dstextab,';'));
  ELSE
    vr_vlchqvlb := 0;
  END IF;  
    
  -- Carregar lista de agencias 
  vr_tab_lsagenci := fn_converte_texto_vetor_n('14077,16179,305057,3164012,405019,407020,410020,486019,562017,714020,828017'); 
    
  -- Montagem dos históricos para processamento
  vr_tab_hstchq := fn_converte_texto_vetor_t('0002,0102,0102,0103,0113,0300,0452,0033,0455,0456,0457,0458,0500');
    
  vr_dshstblq := '0511BL.1D UTIL,0512BL.2D UTIL,0513BL.3D UTIL,'
              || '0514BL.4D UTIL,0515BL.5D UTIL,0516BL.6D UTIL,'
              || '0517BL.7D UTIL,0518BL.8D UTIL,0519BL.9D UTIL,'
              || '0520DEP.BL.IND,'
              || '0911DEP.BL.1D,0912DEP.BL.2D,0913DEP.BL.3D,'
              || '0914DEP.BL.4D,0915DEP.BL.5D,0916DEP.BL.6D,'
              || '0917DEP.BL.7D,0918DEP.BL.8D,0919DEP.BL.9D,'
              || '0920DEP.BL.IND';
 
  vr_tab_hstblq := fn_converte_texto_vetor_t(vr_dshstblq);
                                           
  -- ATENCAO: O historico 623-DEP. COMPE nao sera tratado 
  vr_tab_hstdep := fn_converte_texto_vetor_t('0502DEPOSITO,0505DEP.CHEQUE,0830DEP.ONLINE,0870TRF.ONLINE,' || vr_dshstblq);

  -- Especifica da Cobrança
  vr_tab_hstcob := fn_converte_texto_vetor_t('0624COBRANCA');
     
  -- Iterar sobre todas as Coops da executação
  FOR vr_idx IN vr_tab_crapcop.first..vr_tab_crapcop.last LOOP
    -- Se não existir arquivo gravado no registro
    IF vr_tab_crapcop(vr_idx).nmarquiv IS NULL THEN
      -- Ir ao proximo registro
      CONTINUE;
    END IF;
      
    --  Le tabela com as contas convenio do Banco do Brasil - Geral .............
    vr_tab_contas := fn_converte_texto_vetor_n(gene0005.fn_busca_conta_centralizadora(vr_tab_crapcop(vr_idx).cdcooper,0));
    -- Le tabela com as contas convenio do Banco do Brasil - talao transf ......
    vr_tab_conta2 := fn_converte_texto_vetor_n(gene0005.fn_busca_conta_centralizadora(vr_tab_crapcop(vr_idx).cdcooper,2));
    -- Le tabela com as contas convenio do Banco do Brasil - chq.salario ....... 
    vr_tab_conta3 := fn_converte_texto_vetor_n(gene0005.fn_busca_conta_centralizadora(vr_tab_crapcop(vr_idx).cdcooper,3));
      
    -- Reiniciar variaveis para cada Coop
    vr_tab_crapcop(vr_idx).nmarqimp := 'crrl291_' || to_char(vr_tab_crapcop(vr_idx).cdcooper,'fm00') || '.lst';
    vr_cdcritic := 0;
    vr_nrdolote := 0;
    vr_flgarqvz := TRUE;
    vr_flgfirst := TRUE;
    vr_flgentra := TRUE;
    vr_nrdlinha := 0;
    vr_ger_vlbloque := 0;      
      
    -- Se por algum motivo o arquivo não mais existir, ele já deve ter sido processado
    IF NOT gene0001.fn_exis_arquivo(vr_nmdircop||'/integra/'||vr_tab_crapcop(vr_idx).nmarquiv) THEN
      -- Continuar para a próxima COOP
      CONTINUE;
    ELSE 
      -- Indicar que encontrou um arquivo para processamento
      vr_flgarqui := TRUE;
    END IF;
      
    -- Limpar tabela de saldos
    vr_tab_crawdpb.delete;
      
    --Geração de log de erro - Chamado 696499
    --Enviar critica 219 ao LOG
    vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                           ' --> ' || 'ALERTA: ' ||gene0001.fn_busca_critica(219) ||
                           ': '||vr_tab_crapcop(vr_idx).nmarquiv;
      
    cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                           pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                           pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                           pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia  => 4,            -- tbgen_prglog_ocorrencia - 4 - Mensagem
                           pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                           pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                           pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                           pr_nmarqlog      => NULL, 
                           pr_idprglog      => vr_idprglog);
      
    -- Efetuar abertura do arquivo 
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdircop||'/integra/'
                            ,pr_nmarquiv => vr_tab_crapcop(vr_idx).nmarquiv
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_arqhandle
                            ,pr_des_erro => vr_dscritic);
    -- Em caso de problema na abertura do arquivo 
    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Erro na abertura do arquivo --> ' || vr_tab_crapcop(vr_idx).nmarquiv|| ' --> ' ||vr_dscritic;
      RAISE vr_exc_saida;
    END IF;
      
    -- Efetuar laço para processamento das linhas do arquivo 
    BEGIN 
      LOOP 
        -- Leitura linha a linha           
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arqhandle
                                    ,pr_des_text => vr_dslinharq);
        -- Incrementar contador 
        vr_nrdlinha := vr_nrdlinha + 1;
        -- Ignorar Header e Trailler, ou seja, registros que não comecem com 1
        IF substr(vr_dslinharq,1,1) <> '1' THEN
          CONTINUE;
        END IF;
        -- Ignorar conta Cecred cancelada e que ainda vem no arquivo
        IF pr_cdcooper = 3 AND substr(vr_dslinharq,37,5) = '5027X' THEN
          CONTINUE;
        END IF;
        
        -- Inicializar variaveis
        vr_nrdconta := 0;
          
        -- Separar numero da conta (substituindo digito X por 0)
        BEGIN 
          IF SUBSTR(vr_dslinharq,41,01) = 'X' THEN
            vr_nrdctabb := SUBSTR(vr_dslinharq,33,08) || '0';
          ELSE     
            vr_nrdctabb := SUBSTR(vr_dslinharq,33,09);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := ' na leitura da conta ['||SUBSTR(vr_dslinharq,33,09)||']';
            raise vr_exc_saida;
        END;
        pc_leitura_saldos(vr_dslinharq,vr_nrdctabb,vr_dscritic);
        -- Ao encontrar erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Se a conta não estiver na listagem parametrizada
        IF NOT vr_tab_contas.exists(vr_nrdctabb) THEN 
          -- Pular 
          CONTINUE;
        END IF;
        -- Setar flag de encontro
        vr_flgarqvz := FALSE;
        -- Ignorar registro com 1 na posição 42
        IF substr(vr_dslinharq,42,1) <> '1' THEN
          CONTINUE;
        END IF;
          
        -- Leitura de informações para o processamento
        BEGIN 
          vr_nrseqint := substr(vr_dslinharq,195,6);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := ' na leitura da seqint ['||SUBSTR(vr_dslinharq,195,6)||']';
            raise vr_exc_saida;
        END;
        vr_dshistor := TRIM(substr(vr_dslinharq,46,29));
        BEGIN 
          vr_nrdocmto := TO_NUMBER(substr(vr_dslinharq,75,6)) * 10;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := ' na leitura do nrdocmto ['||SUBSTR(vr_dslinharq,75,6)||']';
            raise vr_exc_saida;
        END;  
        BEGIN   
          vr_vllanmto := TO_NUMBER(substr(vr_dslinharq,87,18)) / 100;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := ' na leitura do valor lancamento ['||SUBSTR(vr_dslinharq,87,18)||']';
            raise vr_exc_saida;
        END;              
        BEGIN 
          vr_dtmvtolt := to_date(substr(vr_dslinharq,182,2)||substr(vr_dslinharq,184,2)||substr(vr_dslinharq,186,4),'ddmmrrrr');
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := ' na leitura da data ['||substr(vr_dslinharq,182,2)||substr(vr_dslinharq,184,2)||substr(vr_dslinharq,186,4)||']';
            raise vr_exc_saida;
        END;              
        BEGIN 
          IF to_number(substr(vr_dslinharq,43,3)) > 100 AND to_number(substr(vr_dslinharq,43,3)) < 200 THEN 
            vr_indebcre := 'D';
          ELSE
            vr_indebcre := 'C';
          END IF;  
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := ' na leitura do tipo(D/C) ';
            raise vr_exc_saida;
        END;              
        vr_cdpesqbb := substr(vr_dslinharq,111,5) || '-000-' || substr(vr_dslinharq,120,3);                                
        vr_dsageori := substr(vr_dslinharq,116,4) || '.00';
        BEGIN 
          IF to_number(substr(vr_dslinharq,174,8)) > 0 THEN 
            vr_dtrefere := to_date(substr(vr_dslinharq,174,2)||substr(vr_dslinharq,176,2)||substr(vr_dslinharq,178,4),'ddmmrrrr');
          ELSE
            vr_dtrefere := NULL;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := ' na leitura da Data Referencia.';
            raise vr_exc_saida;
        END;
        -- Calculo novamente o digito verificador do numero do documento 
        vr_stsnrcal := GENE0005.fn_calc_digito (pr_nrcalcul => vr_nrdocmto);
        -- Validar datas do processamento
        IF pr_nmtelant = 'COMPEFORA' THEN
          IF vr_dtmvtolt <> rw_crapdat.dtmvtoan THEN
            CONTINUE;
          END IF;  
        ELSIF vr_dtmvtolt <> rw_crapdat.dtmvtolt THEN
          CONTINUE;
        END IF;  
          
        -- Na primeira execução da Coop
        IF vr_flgfirst THEN
          -- Le numero de lote a ser usado na integracao
          vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 0
                                                   ,pr_cdacesso => 'NUMLOTECBB'
                                                   ,pr_tpregist => 1);
          IF trim(vr_dstextab) IS NULL THEN
            -- Gerar critica 259
            vr_cdcritic := 259;
            raise vr_exc_saida;
          ELSE
            -- Gravar numero do lote e atualizar controle
            vr_nrdolote := to_number(vr_dstextab) + 1;
            vr_flgclote := true;
            vr_flgfirst := false;
          END IF;  
        END IF;
          
        -- Buscar os tipos de movimento da linha
        IF vr_tab_hstdep.exists(vr_dshistor) THEN 
          /* Depósitos */
          vr_flgdepos := TRUE;
          vr_flgchequ := FALSE;
        ELSIF vr_tab_hstchq.exists(SUBSTR(vr_dshistor,1,4)) THEN    
          /*  Cheque  */
          vr_flgdepos := FALSE;
          vr_flgchequ := TRUE;
        ELSE
          /* Outros */
          vr_cdcritic := 245;                              
          vr_flgdepos := FALSE;
          vr_flgchequ := TRUE;
        END IF;
          
        -- Verifica se movto cobranca 0624
        vr_cobranca := FALSE; 
        IF vr_cdcritic = 245 THEN 
          -- 245 - Historico nao processado.            
          IF vr_tab_hstcob.exists(vr_dshistor) THEN 
            /* 0624COBRANCA */
            vr_cobranca := TRUE;
          END IF;  
        END IF;
          
        -- Checar criticas 
        IF vr_cdcritic = 0  THEN
          -- Se não há numero de documento
          IF vr_nrdocmto = 0  THEN
            -- 022 - Numero do documento errado.
            vr_cdcritic := 22;
          ELSE
            -- Calcular digito verificador
            vr_nrcalcul := vr_nrdocmto;
            vr_stsnrcal := GENE0005.fn_calc_digito (pr_nrcalcul => vr_nrcalcul);
            -- Se deposito 
            IF vr_flgdepos THEN
              -- Se o digito calculo não faz parte da lista de agencias
              IF vr_tab_lsagenci.exists(vr_nrcalcul) THEN
                -- 577 - Verifique o numero da conta.
                vr_cdcritic := 577;
              ELSE
                -- Usar a conta calculada
                vr_nrdconta := vr_nrcalcul;
              END IF;  
            ELSE 
              IF NOT vr_stsnrcal THEN
                -- 008 - Digito errado.
                vr_cdcritic := 8;
              END IF;  
              -- Deve haver valor de lançamento
              IF vr_vllanmto = 0 THEN
                -- 091 - Valor do lancamento errado.
                vr_cdcritic := 91;
              END IF;  
            END IF;
          END IF;  
        END IF;
          
        -- Se não houve encontro de criticas E processamento de cheques
        IF vr_cdcritic = 0 AND vr_flgchequ THEN
          -- Calcular conta ITG
          gene0005.pc_conta_itg_digito_x (pr_nrcalcul => vr_nrdctabb
                                         ,pr_dscalcul => vr_dsdctitg
                                         ,pr_stsnrcal => vr_stsnrcal_int
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
          -- Sair em caso de erro
          IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          ELSE
            vr_cdcritic := 0;
          END IF;
            
          -- Montar novo numero de documento
          vr_nrdocmt2 := SUBSTR(to_char(vr_nrdocmto,'fm0000000'),1,6);
            
          -- Buscar Folhas de Cheque 
          OPEN cr_crapfdc(pr_cdageitg => rw_crapcop.cdageitg
                         ,pr_nrctachq => vr_nrdctabb
                         ,pr_nrcheque => vr_nrdocmt2);
          FETCH cr_crapfdc 
           INTO rw_crapfdc;
          -- Se não encontar
          IF cr_crapfdc%notfound THEN
            -- Fechar cursor
            CLOSE cr_crapfdc;
            -- Montar critica conforme situação
            IF vr_tab_conta3.exists(vr_nrdctabb) THEN
              -- 286 - Cheque salario nao existe.
              vr_cdcritic := 286;
            ELSE
              -- 108 - Talonario nao emitido.
              vr_cdcritic := 108;
            END IF;
          ELSE
            -- Continuar
            CLOSE cr_crapfdc;
          END IF;
          -- Somente se não encontrou critica
          IF vr_cdcritic = 0 THEN 
            vr_nrdconta := rw_crapfdc.nrdconta;
            -- Criticas padrão
            IF rw_crapfdc.incheque in(5,6,7) THEN
              -- 097 - Cheque ja entrou.
              vr_cdcritic := 97;
            ELSIF rw_crapfdc.incheque = 8   THEN
              -- 320 - Cheque cancelado.
              vr_cdcritic := 320;
            END IF;  
            -- Caso CHQ SAL
            IF vr_tab_conta3.exists(vr_nrdctabb) THEN
              IF rw_crapfdc.nrdconta = 0 THEN
                -- 286 - Cheque salario nao existe.
                vr_cdcritic := 286;
              ELSIF rw_crapfdc.incheque = 1 THEN
                -- 096 - Cheque com contra-ordem.
                vr_flgcontr := TRUE;
              ELSIF rw_crapfdc.vlcheque <> vr_vllanmto THEN
                -- 269 - Valor errado.
                vr_cdcritic := 269;
              END IF;     
            ELSE 
              -- Outros casos 
              IF rw_crapfdc.dtemschq IS NULL THEN
                -- 108 - Talonario nao emitido.
                vr_cdcritic := 108;
              ELSIF rw_crapfdc.dtretchq IS NULL THEN
                vr_cdcritic := 109;
              END IF;     
            END IF;              
          END IF;
        END IF;
        -- Se não encontrou critica
        IF vr_cdcritic = 0 THEN
          -- Busca associado 
          OPEN cr_crapass(vr_nrdconta);
          FETCH cr_crapass 
           INTO rw_crapass;
          -- Se não encontrar 
          IF cr_crapass%NOTFOUND THEN
            -- Fechar cursor e gerar critica 009
            CLOSE cr_crapass;
            vr_cdcritic := 9;
          ELSE
            -- Fechar cursor e testar outras situações
            CLOSE cr_crapass;
            IF rw_crapass.cdsitdtl IN (5,6,7,8) THEN
              -- 695 - ATENCAO! Houve prejuizo nessa conta
              vr_cdcritic := 695;
            ELSIF rw_crapass.cdsitdtl IN(2,4,6,8) THEN
              -- 095 - Titular da conta bloqueado.
              vr_cdcritic := 95;
            ELSIF rw_crapass.dtelimin IS NOT NULL THEN
              -- 410 - Associado excluido.
              vr_cdcritic := 410;
            END IF;
          END IF;            
        END IF;
          
        -- Se foi solicitada criação de lote
        IF vr_flgclote THEN
          -- Tentaremos criar o registro do lote
          BEGIN
            INSERT INTO craplot (cdcooper
                                ,dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov)
                          VALUES(pr_cdcooper  -- cdcooper
                                ,rw_crapdat.dtmvtolt  -- dtmvtolt
                                ,vr_cdagenci  -- cdagenci
                                ,vr_cdbccxlt  -- cdbccxlt
                                ,vr_nrdolote  -- nrdolote
                                ,1)           -- tplotmov
                       RETURNING rowid
                                ,dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov
                                ,qtinfoln 
                                ,qtcompln 
                                ,vlinfodb 
                                ,vlcompdb 
                                ,vlinfocr
                                ,vlcompcr
                            INTO rw_craplot.nrrowid 
                                ,rw_craplot.dtmvtolt
                                ,rw_craplot.cdagenci
                                ,rw_craplot.cdbccxlt
                                ,rw_craplot.nrdolote
                                ,rw_craplot.tplotmov
                                ,rw_craplot.qtinfoln 
                                ,rw_craplot.qtcompln 
                                ,rw_craplot.vlinfodb 
                                ,rw_craplot.vlcompdb 
                                ,rw_craplot.vlinfocr
                                ,rw_craplot.vlcompcr;
          EXCEPTION
            WHEN dup_val_on_index THEN
              -- Lote já existe, critica 59
              vr_cdcritic := 59;
              vr_dscritic := gene0001.fn_busca_critica(59) || ' COMPBB - LOTE = ' || to_char(vr_nrdolote,'fm000g000');
              RAISE vr_exc_saida;
            WHEN others THEN 
              -- Erro não tratado 
              vr_dscritic := ' na insercao do lote '||vr_nrdolote|| ' --> ' || sqlerrm;
              RAISE vr_exc_saida;
          END;  
          -- Atualizar CRAPTAB 
          BEGIN
            UPDATE craptab 
               SET dstextab = vr_nrdolote 
             WHERE cdcooper = pr_cdcooper
               AND UPPER(nmsistem) = 'CRED'
               AND UPPER(tptabela) = 'GENERI'
               AND cdempres = 0
               AND UPPER(cdacesso) = 'NUMLOTECBB'
               AND tpregist = 1;               
          EXCEPTION
            WHEN others THEN
              vr_dscritic := ' na atualizada da TAB de lote --> '||sqlerrm;
              RAISE vr_exc_saida;
          END;            
          -- Atualizar o controle indicando que houve criação do lote
          vr_flgclote := false;
        END IF;
        -- Não havendo critica e com flag de cheque
        IF vr_cdcritic = 0 AND vr_flgchequ THEN
          -- Busca se já existe lançamento para aquele cheque
          OPEN cr_craplcm_cheque(vr_nrdolote,vr_nrdctabb,vr_nrdocmto);
          FETCH cr_craplcm_cheque
           INTO vr_flgexis;
          -- Se encontrou
          IF cr_craplcm_cheque%FOUND THEN
            -- Fechar cursor e criticar 92
            CLOSE cr_craplcm_cheque;
            -- 092 - Lancamento ja existe
            vr_cdcritic := 92;
          ELSE 
            -- Fechar cursor e continuar as validações 
            CLOSE cr_craplcm_cheque;
            -- Para contas da lista 3
            IF vr_tab_conta3.exists(vr_nrdctabb) THEN
              IF rw_crapfdc.incheque = 2 THEN 
                -- Gerar critica 287
                -- 287 - Cheque salario com alerta!!!                  
                vr_cdcritic := 287;
              END IF;  
            -- Para contas da lista 2
            ELSIF vr_tab_conta2.exists(vr_nrdctabb) THEN
              IF rw_crapfdc.incheque = 2 THEN
                -- Gerar critica 257
                -- 257 - Cheque com alerta.
                vr_cdcritic := 257;
              ELSIF rw_crapfdc.incheque = 1 THEN
                -- Gerar critica 96
                -- 096 - Cheque com contra-ordem.                  
                vr_cdcritic := 096;
                vr_indevchq := 3;
              END IF;
            ELSE
              -- Testar cheque com alerta
              IF rw_crapfdc.incheque = 2 THEN
                -- Gerar critica 257
                -- 257 - Cheque com alerta.
                vr_cdcritic := 257;
              ELSIF rw_crapfdc.incheque = 1 THEN 
                -- Buscar lançamento nos históricos:
                -- 21 - CHEQUE
                -- 50  - CHEQUE COMP.
                OPEN cr_craplcm_cheque_cor(vr_nrdconta,vr_nrdocmto);
                FETCH cr_craplcm_cheque_cor
                 INTO rw_craplcm_cor;
                -- Se não encontrar
                IF cr_craplcm_cheque_cor%NOTFOUND THEN                   
                  -- Fechar cursor e gerar critica 96
                  CLOSE cr_craplcm_cheque_cor;
                  -- 096 - Cheque com contra-ordem.
                  vr_cdcritic := 96;
                  vr_indevchq := 1;
                  vr_cdalinea := 0;
                ELSE
                  -- Fechar cursor e continuar procurando
                  CLOSE cr_craplcm_cheque_cor;
                  -- Buscar contra-ordem no cheque 
                  OPEN cr_crapcor(rw_crapcop.cdageitg
                                 ,vr_nrdctabb
                                 ,vr_nrdocmto);
                  -- Se não encontrar contra ordem
                  IF cr_crapcor%NOTFOUND THEN                     
                    -- Fechar o cursor e gerar critica 439
                    CLOSE cr_crapcor;
                    -- 439 - Ch. C.Ordem - Apr. Indevida.
                    vr_cdcritic := 439;
                    vr_indevchq := 1;
                    vr_cdalinea := 49;                      
                  ELSE 
                    -- Fechar o cursor e continuar
                    CLOSE cr_crapcor;
                    -- Se a Contra Ordem está no futuro ainda 
                    IF rw_crapcor.dtvalcor >= rw_crapdat.dtmvtolt THEN
                      -- Gerar critica 96 
                      -- 096 - Cheque com contra-ordem.
                      vr_cdcritic := 96;
                      IF rw_crapfdc.tpcheque = 1 THEN 
                        vr_indevchq := 1;
                      ELSE 
                        vr_indevchq := 3;
                      END IF;                        
                      vr_cdalinea := 70;
                    -- Se a data do envio é superior ao ultimo lançamento 
                    ELSIF rw_crapcor.dtemscor > rw_craplcm_cor.dtmvtolt   THEN
                      -- Gerar critica 96
                      -- 096 - Cheque com contra-ordem.
                      vr_cdcritic := 96;
                      vr_indevchq := 1;
                      vr_cdalinea := 0;
                    -- Se não se enquadrar em nenhum caso                      
                    ELSE
                      -- gerar critica 439
                      -- 439 - Ch. C.Ordem - Apr. Indevida.
                      vr_cdcritic := 439;
                      vr_indevchq := 1;
                      vr_cdalinea := 43;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
        -- Monta a data de liberacao para depositos bloqueados 
        IF vr_cdcritic = 0 AND vr_flgdepos THEN 
          -- Testar bloqueio 
          IF vr_tab_hstblq.exists(vr_dshistor) THEN 
            -- Contagem dos dias uteis
            vr_nrdiautl := 0;
            -- Buscar caractere a caractere do histórico
            FOR vr_contador IN 1..LENGTH(vr_dshistor) LOOP
              -- Buscar a quantidade de dias do bloqueio
              vr_nrdiautl := INSTR(vr_dshistor,vr_contador||'D');
              -- Se encontrou 
              IF vr_nrdiautl > 0 THEN
                -- Guardar o contador 
                vr_nrdiautl := vr_contador;
                EXIT;
              END IF;
            END LOOP;
            -- Se não achou a quantidade de dias
            IF vr_nrdiautl = 0 THEN 
              -- Gerar critica 245;
              -- 245 - Historico nao processado.
              vr_cdcritic := 245;
            ELSE 
              -- Gerar histórico 170
              vr_cdhistor := 170;
              vr_dtliblan := rw_crapdat.dtmvtopr;
              -- Para casos de mais de 1 dia
              IF vr_nrdiautl > 1 THEN       
                -- Buscar a data da liberação conforme a quantidade de dias
                LOOP 
                  -- Sair quando finalizar a quantidade de dias de bloqueio
                  EXIT WHEN vr_nrdiautl = 1;
                  -- Adicionar um dia 
                  vr_dtliblan := vr_dtliblan + 1;
                  -- Chamar rotina que valida o dia em util, buscado seu próximo caso não seja
                  vr_dtliblan := gene0005.fn_valida_dia_util(pr_cdcooper,vr_dtliblan);
                  -- Decrementar pois encontramos mais um dia util 
                  vr_nrdiautl := vr_nrdiautl - 1;
                END LOOP;
              END IF;
            END IF; 
          ELSE 
            -- Gerar histórico 169 
            vr_cdhistor := 169;
            vr_dtliblan := null;
          END IF;
          -- Se chegou neste ponto sem critica
          IF vr_cdcritic = 0 THEN 
            -- Gerar critica 762 
            -- 762 - Deposito NAO processado.
            vr_cdcritic := 762;
          END IF;
        END IF;
          
        -- Se houve encontro de critica 
        IF vr_cdcritic > 0 OR  vr_flgcontr THEN
          -- Para contraordem
          IF vr_flgcontr THEN
            -- 096 - Cheque com contra-ordem.
            vr_cdcritic := 96;
          END IF;
          -- Para cobrança
          IF vr_cobranca THEN
            -- 784 - Processado via Cobranca
            vr_cdcritic := 784;
          END IF;
          -- Efetuar criação da CRAPREJ
          BEGIN 
            INSERT INTO CRAPREJ (cdcooper
                                ,dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov
                                ,nrdconta
                                ,nrdctabb
                                ,nrdctitg
                                ,dshistor
                                ,cdpesqbb
                                ,nrseqdig
                                ,nrdocmto
                                ,vllanmto
                                ,indebcre
                                ,dtrefere
                                ,cdcritic
                                ,dtdaviso
                                ,tpintegr)
                         VALUES (pr_cdcooper                              -- cdcooper
                                ,rw_craplot.dtmvtolt                      -- dtmvtolt
                                ,rw_craplot.cdagenci                      -- cdagenci
                                ,rw_craplot.cdbccxlt                      -- cdbccxlt
                                ,rw_craplot.nrdolote                      -- nrdolote
                                ,rw_craplot.tplotmov                      -- tplotmov
                                ,vr_nrdconta                              -- nrdconta
                                ,vr_nrdctabb                              -- nrdctabb
                                ,vr_dsdctitg                              -- nrdctitg
                                ,rpad(vr_dshistor,15,' ') || vr_dsageori  -- dshistor
                                ,vr_cdpesqbb                              -- cdpesqbb
                                ,vr_nrseqint                              -- nrseqdig
                                ,CASE vr_cdcritic
                                  WHEN 762 THEN vr_nrseqint
                                  WHEN 608 THEN vr_nrseqint
                                  ELSE vr_nrdocmto END                    -- nrdocmto
                                ,vr_vllanmto                              -- vllanmto
                                ,vr_indebcre                              -- indebcre
                                ,vr_dtrefere                              -- dtrefere
                                ,vr_cdcritic                              -- cdcritic
                                ,nvl(vr_dtrefere,rw_crapdat.dtmvtolt)     -- dtdaviso
                                ,1                      );                -- tpintegr
          EXCEPTION 
            WHEN OTHERS THEN 
              vr_dscritic := ' ao inserir registro de Rejeição --> ' ||sqlerrm;
              RAISE vr_exc_saida;
          END;
          -- Tratar criticas ignoráveis
          IF vr_cdcritic IN(96,137,172,257,287,439,608) THEN 
            -- Para critica 96 - Cheque com Contra Ordem 
            IF vr_cdcritic = 96 AND vr_tab_conta3.exists(vr_nrdctabb) THEN
              -- Critica pode ser limpa e não haverá entrada 
              vr_cdcritic := 0;
              vr_flgentra := FALSE;
            ELSE
              -- Limpar a critica e haverá entrada 
              vr_cdcritic := 0;
              vr_flgentra := TRUE;
            END IF;
          ELSE 
            -- Todas as outras podem ser limpas e não haverá entrada 
            vr_cdcritic := 0;
            vr_flgentra := FALSE;
          END IF;
        END IF;
          
        -- Verifica se há negativação no cheque 
        IF vr_flgchequ THEN 
          OPEN cr_crapneg(vr_nrdconta
                         ,vr_nrdocmto);
          FETCH cr_crapneg 
           INTO vr_flgexis;
          -- Se encontrar 
          IF cr_crapneg%FOUND THEN 
            IF rw_crapfdc.tpcheque = 1 THEN 
              vr_indevchq := 1;
            ELSE 
              vr_indevchq := 3;
            END IF;
            vr_cdalinea := 49;
            vr_flgentra := TRUE;
          END IF;
          -- Fechar cursor
          CLOSE cr_crapneg;
        END IF;
        -- Para entrada de cheques
        IF vr_flgentra AND vr_flgchequ THEN 
          -- Atualizar LOTE 
          rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
          rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
          rw_craplot.vlinfodb := rw_craplot.vlinfodb + nvl(vr_vllanmto,0);
          rw_craplot.vlcompdb := rw_craplot.vlcompdb + nvl(vr_vllanmto,0);
          rw_craplot.nrseqdig := vr_nrseqint;
          -- Criar lançamento na CC do Cooperado 
          -- BEGIN
            -- Tratando histórico 
            IF vr_tab_conta3.exists(vr_nrdctabb) THEN 
              vr_cdhistor := 56;
            ELSIF vr_tab_conta2.exists(vr_nrdctabb) THEN 
              vr_cdhistor := 59;
            ELSE   
              vr_cdhistor := 50;
            END IF;
           
          -- PJ450 - Regulatório de crédito
          -- Criando lançamento 
          LANC0001.pc_gerar_lancamento_conta (pr_dtmvtolt => rw_craplot.dtmvtolt
                                             ,pr_dtrefere => vr_dtleiarq 
                                             ,pr_cdagenci => rw_craplot.cdagenci
                                             ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                             ,pr_nrdolote => rw_craplot.nrdolote
                                             ,pr_nrdconta => vr_nrdconta
                                             ,pr_nrdctabb => vr_nrdctabb
                                             ,pr_nrdctitg => vr_dsdctitg 
                                             ,pr_nrdocmto => vr_nrdocmto
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_vllanmto => vr_vllanmto
                                             ,pr_nrseqdig => vr_nrseqint
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_cdpesqbb => vr_cdpesqbb
                                             ,pr_cdbanchq => rw_crapfdc.cdbanchq
                                             ,pr_cdagechq => rw_crapfdc.cdagechq
                                             ,pr_nrctachq => rw_crapfdc.nrctachq
                                             -- OUTPUT --
                                             ,pr_tab_retorno => vr_tab_retorno
                                             ,pr_incrineg => vr_incrineg
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);   
                                           
          IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
             IF vr_incrineg = 0 THEN 
                 RAISE vr_exc_saida;
             ELSE -- 
                BEGIN 
                  INSERT INTO CRAPREJ (cdcooper
                                      ,dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                      ,tplotmov
                                ,nrdconta
                                ,nrdctabb
                                ,nrdctitg
                                      ,dshistor
                                ,cdpesqbb
                                      ,nrseqdig
                                      ,nrdocmto
                                      ,vllanmto
                                      ,indebcre
                                      ,dtrefere
                                      ,cdcritic
                                      ,dtdaviso
                                      ,tpintegr)
                               VALUES (pr_cdcooper                              -- cdcooper
                                      ,rw_craplot.dtmvtolt                      -- dtmvtolt
                                      ,rw_craplot.cdagenci                      -- cdagenci
                                      ,rw_craplot.cdbccxlt                      -- cdbccxlt
                                      ,rw_craplot.nrdolote                      -- nrdolote
                                      ,rw_craplot.tplotmov                      -- tplotmov
                                      ,vr_nrdconta                              -- nrdconta
                                      ,vr_nrdctabb                              -- nrdctabb
                                      ,vr_dsdctitg                              -- nrdctitg
                                      ,rpad(vr_dshistor,15,' ') || vr_dsageori  -- dshistor
                                      ,vr_cdpesqbb                              -- cdpesqbb
                                      ,vr_nrseqint                              -- nrseqdig
                                      ,vr_nrdocmto                              -- nrdocmto
                                      ,vr_vllanmto                              -- vllanmto
                                      ,vr_indebcre                              -- indebcre
                                      ,vr_dtrefere                              -- dtrefere
                                      ,vr_cdcritic                              -- cdcritic
                                      ,nvl(vr_dtrefere,rw_crapdat.dtmvtolt)     -- dtdaviso
                                      ,1                      );                -- tpintegr
          EXCEPTION 
            WHEN OTHERS THEN 
                    vr_dscritic := ' ao inserir registro de Rejeição --> ' ||sqlerrm;
              RAISE vr_exc_saida;
          END;
                CONTINUE;
             END IF;  
          END IF; 
          
          
          -- Atualizar folha de cheque 
          BEGIN 
            UPDATE crapfdc 
               SET incheque = rw_crapfdc.incheque + 5
                  ,vlcheque = vr_vllanmto
                  ,dtliqchq = rw_crapdat.dtmvtolt 
                  ,cdagedep = substr(vr_dsageori,1,4)
             WHERE rowid = rw_crapfdc.rowid;
          EXCEPTION 
            WHEN OTHERS THEN 
              vr_dscritic := ' ao atualizar Folha de Cheque --> '||sqlerrm;
              RAISE vr_exc_saida; 
          END;
          -- Se for devolucao de cheque verifica o indicador de
          -- historico da contra-ordem. Se for 2, alimenta aux_cdalinea
          -- com 28 para nao gerar taxa de devolucao
          IF (vr_indevchq = 1 OR vr_indevchq = 3) AND vr_cdalinea = 0 THEN
            -- Buscar contra-ordem no cheque 
            OPEN cr_crapcor(rw_crapcop.cdageitg
                           ,vr_nrdctabb
                           ,vr_nrdocmto);
            -- Se não encontrar contra ordem
            IF cr_crapcor%NOTFOUND THEN                     
              -- Fechar o cursor e gerar critica 179 retornando 
              CLOSE cr_crapcor;
              vr_cdcritic := 179;
              vr_dscritic := gene0001.fn_busca_critica(179) || ' ' || gene0002.fn_mask_conta(vr_nrdconta)
                          || ' Docmto = '|| gene0002.fn_mask(vr_nrdocmto,'zzz.zzz.9')
                          || ' Cta Base = ' || gene0002.fn_mask_conta(vr_nrdctabb);
              RAISE vr_exc_saida;                
            ELSE 
              -- Fechar o cursor e continuar
              CLOSE cr_crapcor;
              -- Contra Ordem Provisoria
              IF rw_crapcor.dtvalcor >= rw_crapdat.dtmvtolt THEN
                vr_cdalinea := 70;
              ELSIF rw_crapcor.cdhistor = 835 THEN
                vr_cdalinea := 28;
              ELSIF rw_crapcor.cdhistor = 815 THEN
                vr_cdalinea := 21;
              ELSIF rw_crapcor.cdhistor = 818 THEN
                vr_cdalinea := 20;
              ELSE
                vr_cdalinea := 21;
              END IF;
            END IF;  
          END IF;
          -- Se há devolução
          IF vr_indevchq > 0 THEN 
            -- Gerar devolução 
            cheq0001.pc_gera_devolucao_cheque(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdbccxlt => 1 -- Fixo BB
                                             ,pr_cdbcoctl => 1 -- Fixo BB
                                             ,pr_inchqdev => vr_indevchq
                                             ,pr_nrdconta => vr_nrdconta 
                                             ,pr_nrdocmto => vr_nrdocmto 
                                             ,pr_nrdctitg => vr_dsdctitg 
                                             ,pr_vllanmto => vr_vllanmto 
                                             ,pr_cdalinea => vr_cdalinea 
                                             ,pr_cdhistor => (CASE vr_indevchq
                                                               WHEN 1 THEN 191
                                                               ELSE 78
                                                              END)
                                             ,pr_cdoperad => '1'
                                             ,pr_cdagechq => rw_crapcop.cdagebcb
                                             ,pr_nrctachq => vr_nrdctabb
                                             ,pr_cdprogra => vr_cdprogra
                                             ,pr_nrdrecid => 0
                                             ,pr_vlchqvlb => vr_vlchqvlb
                                             ,pr_cdcritic => vr_cdcritic 
                                             ,pr_des_erro => vr_dscritic);
            -- Testar erro na chamada
            IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN 
              -- Concatenar detalhes e sair 
              IF vr_dscritic IS NULL THEN 
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              END IF;
              vr_dscritic := vr_dscritic || ' ' || gene0002.fn_mask_conta(vr_nrdconta)
                          || ' Docmto = '|| gene0002.fn_mask(vr_nrdocmto,'zzz.zzz.9')
                          || ' Cta Base = ' || gene0002.fn_mask_conta(vr_nrdctabb);
              RAISE vr_exc_saida;
            ELSE
              vr_cdcritic := 0;
            END IF;              
          END IF;
          -- Buscar indicador de D/C do Histórico gravado
          OPEN cr_craphis(pr_cdcooper,vr_cdhistor);
          FETCH cr_craphis 
           INTO vr_indebcre;
          -- Se não encontrar
          IF cr_craphis%NOTFOUND THEN 
            CLOSE cr_craphis;
            -- Gerar critica 80 e retornar 
            vr_cdcritic := 80;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            vr_dscritic := vr_dscritic || ' HST = ' || vr_cdhistor;
            RAISE vr_exc_saida;
          ELSE
            CLOSE cr_craphis;
          END IF;            
            
          -- Se foi lançamento de Debito
          IF vr_indebcre = 'D' THEN               
            -- Acumular totalizadores da COMPBB
            IF NOT vr_tab_totais.EXISTS(vr_nrdctabb) THEN 
              vr_tab_totais(vr_nrdctabb).qtcompdb := 0;
              vr_tab_totais(vr_nrdctabb).vlcompdb := 0;
              vr_tab_totais(vr_nrdctabb).qtcompcr := 0;
              vr_tab_totais(vr_nrdctabb).vlcompcr := 0;
            END IF;               
            vr_tab_totais(vr_nrdctabb).vlcompdb := vr_tab_totais(vr_nrdctabb).vlcompdb + vr_vllanmto; 
            vr_tab_totais(vr_nrdctabb).qtcompdb := vr_tab_totais(vr_nrdctabb).qtcompdb + 1;
          END IF;
        -- Entrada de Depósitos  
        ELSIF vr_flgentra AND vr_flgdepos THEN          
          -- Buscar indicador de D/C do Histórico gravado
          OPEN cr_craphis(pr_cdcooper,vr_cdhistor);
          FETCH cr_craphis 
           INTO vr_indebcre;
          -- Se não encontrar
          IF cr_craphis%NOTFOUND THEN 
            CLOSE cr_craphis;
            -- Gerar critica 80 e retornar 
            vr_cdcritic := 80;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            vr_dscritic := vr_dscritic || ' HST = ' || vr_cdhistor;
            RAISE vr_exc_saida;
          ELSE
            CLOSE cr_craphis;
          END IF;             
          -- Para histórico 170
          -- DEPOS.BB BLOQ
          IF vr_cdhistor = 170 THEN
            -- Criar registros na tabela de Depositos Bloqueados
            BEGIN 
              INSERT INTO crapdpb (cdcooper 
                                  ,dtmvtolt
                                  ,cdagenci
                                  ,cdbccxlt
                                  ,nrdolote
                                  ,nrdconta
                                  ,dtliblan
                                  ,cdhistor
                                  ,nrdocmto
                                  ,vllanmto
                                  ,inlibera)
                            VALUES(pr_cdcooper            -- cdcooper 
                                  ,rw_craplot.dtmvtolt    -- dtmvtolt
                                  ,rw_craplot.cdagenci    -- cdagenci
                                  ,rw_craplot.cdbccxlt    -- cdbccxlt
                                  ,rw_craplot.nrdolote    -- nrdolote
                                  ,vr_nrdconta            -- nrdconta
                                  ,vr_dtliblan            -- dtliblan
                                  ,vr_cdhistor            -- cdhistor
                                  ,vr_nrseqint            -- nrdocmto
                                  ,vr_vllanmto            -- vllanmto
                                  ,1                  );  -- inlibera
            EXCEPTION
              WHEN OTHERS THEN 
                vr_dscritic := ' ao criar registro de Depósito Bloqueado --> '||sqlerrm;
                RAISE vr_exc_saida;
            END;
          END IF;
          -- Atualizar LOTE 
          rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
          rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
          rw_craplot.vlinfocr := rw_craplot.vlinfocr + nvl(vr_vllanmto,0);
          rw_craplot.vlcompcr := rw_craplot.vlcompcr + nvl(vr_vllanmto,0);
          rw_craplot.nrseqdig := vr_nrseqint;
          -- Criar lançamento na CC do Cooperado 
          
          -- PJ450 - Regulatório de crédito
          LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt => rw_craplot.dtmvtolt
                                            ,pr_cdagenci => rw_craplot.cdagenci
                                            ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                            ,pr_nrdolote => rw_craplot.nrdolote
                                            ,pr_nrdconta => vr_nrdconta
                                            ,pr_nrdctabb => vr_nrdctabb
                                            ,pr_nrdctitg => vr_dsdctitg 
                                            ,pr_nrdocmto => vr_nrseqint
                                            ,pr_cdhistor => vr_cdhistor
                                            ,pr_vllanmto => vr_vllanmto
                                            ,pr_nrseqdig => vr_nrseqint
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_cdpesqbb => vr_cdpesqbb
                                            -- OUTPUT --
                                            ,pr_tab_retorno => vr_tab_retorno
                                            ,pr_incrineg => vr_incrineg
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);   
                                           
          IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
          END IF;   

          
          -- Se foi lançamento de Credito
          IF vr_indebcre = 'C' THEN        
            -- Acumular totalizadores da COMPBB
            IF NOT vr_tab_totais.EXISTS(vr_nrdctabb) THEN 
              vr_tab_totais(vr_nrdctabb).qtcompdb := 0;
              vr_tab_totais(vr_nrdctabb).vlcompdb := 0;
              vr_tab_totais(vr_nrdctabb).qtcompcr := 0;
              vr_tab_totais(vr_nrdctabb).vlcompcr := 0;
            END IF;               
            vr_tab_totais(vr_nrdctabb).vlcompcr := vr_tab_totais(vr_nrdctabb).vlcompcr + vr_vllanmto; 
            vr_tab_totais(vr_nrdctabb).qtcompcr := vr_tab_totais(vr_nrdctabb).qtcompcr + 1;
          END IF;
        ELSE 
          -- Outras casos
          -- Acumular totalizadores da COMPBB
          IF NOT vr_tab_totais.EXISTS(99999999) THEN 
            vr_tab_totais(99999999).qtcompdb := 0;
            vr_tab_totais(99999999).vlcompdb := 0;
            vr_tab_totais(99999999).qtcompcr := 0;
            vr_tab_totais(99999999).vlcompcr := 0;
          END IF; 
          -- Alimentar totalizadores conforme tipo do lançamento (D/C)
          IF vr_indebcre = 'D' THEN 
            vr_tab_totais(99999999).vlcompdb := vr_tab_totais(99999999).vlcompdb + vr_vllanmto; 
            vr_tab_totais(99999999).qtcompdb := vr_tab_totais(99999999).qtcompdb + 1;
          ELSE 
            vr_tab_totais(99999999).vlcompcr := vr_tab_totais(99999999).vlcompcr + vr_vllanmto; 
            vr_tab_totais(99999999).qtcompcr := vr_tab_totais(99999999).qtcompcr + 1;
          END IF;
          -- Atualizar variavel de entrada
          vr_flgentra := true;
        END IF;
      END LOOP;
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Fechar handle do arquivo pendente 
        gene0001.pc_fecha_arquivo(vr_arqhandle);
        -- Adicionar o numero da linha ao erro 
        vr_dscritic := 'Erro tratado na linha '||vr_nrdlinha||' --> '|| vr_dscritic;
        -- Direcionar para saída
        RAISE vr_exc_saida; 
      WHEN no_data_found THEN
        NULL; --> Fim da leitura 
      WHEN OTHERS THEN
        -- Fechar handle do arquivo pendente 
        gene0001.pc_fecha_arquivo(vr_arqhandle);
        -- Adicionar o numero da linha ao erro 
        vr_dscritic := 'Erro nao tratado na linha '||vr_nrdlinha||' --> '|| sqlerrm;
        -- Direcionar para saída
        RAISE vr_exc_saida; 
    END;
      
    -- Fechar handle do arquivo pendente 
    gene0001.pc_fecha_arquivo(vr_arqhandle);
      
      
    -- Atualizar a CRAPLOT após o processamento, pois os valores estão apenas em memória
    BEGIN 
      UPDATE craplot 
         SET qtinfoln = rw_craplot.qtinfoln
            ,qtcompln = rw_craplot.qtcompln
            ,vlinfodb = rw_craplot.vlinfodb
            ,vlcompdb = rw_craplot.vlcompdb
            ,vlinfocr = rw_craplot.vlinfocr
            ,vlcompcr = rw_craplot.vlcompcr
            ,nrseqdig = rw_craplot.nrseqdig
       WHERE rowid = rw_craplot.nrrowid;
    EXCEPTION
      WHEN OTHERS THEN 
        vr_dscritic := 'Erro ao atualizar o lote após processamento --> '||sqlerrm;
        RAISE vr_exc_saida;
    END;
    -- Em caso de arquivo vazio
    IF vr_flgarqvz THEN 
      -- Se houve ativação da flag de cheque BB
      IF vr_flgchqbb THEN 
        -- Enviar critica 263 ao log
        -- 263 - ARQUIVO VAZIO;
        vr_cdcritic := 263;

        --Geração de log de erro - Chamado 696499
        vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                               ' --> ' || 'ERRO: ' ||gene0001.fn_busca_critica(263) ||
                               ' Cdcooper='||vr_tab_crapcop(vr_idx).cdcooper;

        cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                               pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                               pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                               pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               pr_tpocorrencia  => 2,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                               pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                               pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                               pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                               pr_nmarqlog      => NULL, 
                               pr_idprglog      => vr_idprglog);
      END IF;
    ELSE 
      -- Arquivo não está vazio, iniciaremos a montagem do relatório 
      dbms_lob.createtemporary(vr_xmlrel, TRUE);
      dbms_lob.open(vr_xmlrel, dbms_lob.lob_readwrite);

      -- Inicializa o xml jah enviando os dados de resumo geral 
      gene0002.pc_escreve_xml(vr_xmlrel,
                              vr_txtrel,
                             '<?xml version="1.0" encoding="utf-8"?>'||
                             '<root><totais>');
        
      -- Iterar sobre os registros acumulados de totalizadores
      vr_nrdctabb := vr_tab_totais.first;
      LOOP 
        EXIT WHEN vr_nrdctabb IS NULL;
        -- Montagem do texto padrão 
        IF vr_nrdctabb != 99999999 THEN 
          vr_dsintegr := 'INTEGRADOS NA CONTA '||GENE0002.FN_MASK_CONTA(vr_nrdctabb);
        ELSE
          vr_dsintegr := 'NAO INTEGRADOS';
        END IF;
        -- Enviar os dados desta conta 
        gene0002.pc_escreve_xml(vr_xmlrel
                               ,vr_txtrel
                               ,'<total dsdsintegr="'||vr_dsintegr||'" '||
                                      ' qtintdeb="'||TO_CHAR(vr_tab_totais(vr_nrdctabb).qtcompdb,'fm999g999g999g990')||'" '||
                                      ' vlintdeb="'||TO_CHAR(vr_tab_totais(vr_nrdctabb).vlcompdb,'fm999g999g999g990d00')||'"'||
                                      ' qtintcre="'||TO_CHAR(vr_tab_totais(vr_nrdctabb).qtcompcr,'fm999g999g999g990')||'" '||
                                      ' vlintcre="'||TO_CHAR(vr_tab_totais(vr_nrdctabb).vlcompcr,'fm999g999g999g990d00')||'"/>');    
        -- Acumular os totais 
        vr_tot_qtintdeb := vr_tot_qtintdeb + vr_tab_totais(vr_nrdctabb).qtcompdb;
        vr_tot_vlintdeb := vr_tot_vlintdeb + vr_tab_totais(vr_nrdctabb).vlcompdb;
        vr_tot_qtintcre := vr_tot_qtintcre + vr_tab_totais(vr_nrdctabb).qtcompcr;
        vr_tot_vlintcre := vr_tot_vlintcre + vr_tab_totais(vr_nrdctabb).vlcompcr;
        -- Buscar a próxima conta
        vr_nrdctabb := vr_tab_totais.next(vr_nrdctabb);
      END LOOP;
      -- Enviar o total geral Integrados + Não Integrados 
      gene0002.pc_escreve_xml(vr_xmlrel
                             ,vr_txtrel
                             ,'<total dsdsintegr="TOTAL DA COMPE" '||
                                    ' qtintdeb="'||TO_CHAR(vr_tot_qtintdeb,'fm999g999g999g990')||'" '||
                                    ' vlintdeb="'||TO_CHAR(vr_tot_vlintdeb,'fm999g999g999g990d00')||'"'||
                                    ' qtintcre="'||TO_CHAR(vr_tot_qtintcre,'fm999g999g999g990')||'" '||
                                    ' vlintcre="'||TO_CHAR(vr_tot_vlintcre,'fm999g999g999g990d00')||'"/>');    
      -- Encerrar tag totais e iniciar tag saldos 
      gene0002.pc_escreve_xml(vr_xmlrel,
                              vr_txtrel,
                             '</totais><saldos>');
      -- Saldos bloqueados nas contas --
      vr_nrdctabb := vr_tab_crawdpb.first;
      LOOP 
        EXIT WHEN vr_nrdctabb IS NULL;
        -- Acumular total bloqueado 
        vr_ger_vlbloque := vr_ger_vlbloque 
                         + vr_tab_crawdpb(vr_nrdctabb).vlblq001 + vr_tab_crawdpb(vr_nrdctabb).vlblq002
                         + vr_tab_crawdpb(vr_nrdctabb).vlblq003 + vr_tab_crawdpb(vr_nrdctabb).vlblq004
                         + vr_tab_crawdpb(vr_nrdctabb).vlblq999 + vr_tab_crawdpb(vr_nrdctabb).vldispon;
        -- Enviar para o XML 
        gene0002.pc_escreve_xml(vr_xmlrel
                               ,vr_txtrel
                               ,'<saldo nrdconta="'||gene0002.fn_mask_conta(vr_nrdctabb)||'"'||
                                      ' vldispon="'||TO_CHAR(vr_tab_crawdpb(vr_nrdctabb).vldispon,'fm999g999g999g990d00')||'" '||
                                      ' vlblq001="'||TO_CHAR(vr_tab_crawdpb(vr_nrdctabb).vlblq001,'fm999g999g999g990d00')||'" '||
                                      ' vlblq002="'||TO_CHAR(vr_tab_crawdpb(vr_nrdctabb).vlblq002,'fm999g999g999g990d00')||'" '||
                                      ' vlblq003="'||TO_CHAR(vr_tab_crawdpb(vr_nrdctabb).vlblq003,'fm999g999g999g990d00')||'" '||
                                      ' vlblq004="'||TO_CHAR(vr_tab_crawdpb(vr_nrdctabb).vlblq004,'fm999g999g999g990d00')||'" '||
                                      ' vlblq999="'||TO_CHAR(vr_tab_crawdpb(vr_nrdctabb).vlblq999,'fm999g999g999g990d00')||'"/>');
        -- Buscar a próxima conta
        vr_nrdctabb := vr_tab_crawdpb.next(vr_nrdctabb);
      END LOOP;
      /* Consulta ajustada para gravar os dados com base no processo 
         que será executado. DTMVTOLT - Processo Normal
                             DTMVTAON - Processo COMPEFORA.
                     
         Obs: O processo COMPEFORA eh executado quando os arquivos deb558*
         nao chegam a tempo de ser executado no processo NOTURNO. Falar
         com o Devid G. Kistner sobre mais detalhes desse processo.
             
         Esse ajuste foi discutido com o solicitante Fernando - Controles 
         Internos junto ao analista responsavel para gravar os dados 
         totalizadores no dia anterior para que os dados sejam mantidos visiveis
         no demostrativo na intranet. Antes essa variavel era gravada no
         mesmo dia que o processo noturno seria executado, com isso o registro
         era sobrescrito e a informacao era perdida. Para a area de controle
         esse valor nao eh critico, se trata de um demonstrativo do dia que
         eh mostrado no painel gerencial da intranet. */
      BEGIN 
        -- Tentaremos atualizar 
        UPDATE gntotpl
           SET vlslddbb = vr_ger_vlbloque
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt =  vr_dtleiarq;
        -- Se não afetou nenhum registro
        IF SQL%ROWCOUNT = 0 THEN 
          INSERT INTO gntotpl(cdcooper
                             ,dtmvtolt
                             ,vlslddbb)
                       VALUES(pr_cdcooper
                             ,vr_dtleiarq
                             ,vr_ger_vlbloque);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN 
          vr_dscritic := 'Erro ao gravar totais de Saldos --> '||sqlerrm;
          RAISE vr_exc_saida;
      END;        
      -- Encerrar tag Saldos e iniciar a Rejeitados 
      gene0002.pc_escreve_xml(vr_xmlrel
                             ,vr_txtrel
                             ,'</saldos><rejeitados>');
      -- Efetuar varredura nos registros da CRAPREJ para envio ao relatório 
      vr_cdcritic := 0;
      FOR rw_craprej IN cr_craprej(pr_cdcooper,vr_nrdolote) LOOP
        -- Buscar critica se diferente da anterior
        IF vr_cdcritic <> rw_craprej.cdcritic THEN 
          vr_cdcritic := rw_craprej.cdcritic;
          vr_dscritic := substr(gene0001.fn_busca_critica(rw_craprej.cdcritic),7,50);
          -- Adicionar asterisco em criticas específicas
          IF vr_cdcritic IN(96,137,172,257,287,439,508,608) THEN 
            vr_dscritic := '* '||vr_dscritic;
          END IF;
        END IF;
        -- Enviar o registro para o XML 
        gene0002.pc_escreve_xml(vr_xmlrel
                               ,vr_txtrel
                               ,'<rejeito nrseqdig="'||rw_craprej.nrseqdig||'"'||
                                        ' dshistor="'||substr(rw_craprej.dshistor,1,15)||'" '||
                                        ' nrdctabb="'||gene0002.fn_mask_conta(rw_craprej.nrdctabb)||'" '||
                                        ' dtrefere="'||rw_craprej.dtrefere||'" '||
                                        ' nrdocmto="'||gene0002.fn_mask_conta(rw_craprej.nrdocmto)||'" '||
                                        ' cdpesqbb="'||substr(rw_craprej.cdpesqbb,1,13)||'" '||
                                        ' vllanmto="'||TO_CHAR(rw_craprej.vllanmto,'fm999g999g999g990d00')||'" '||
                                        ' indebcre="'||rw_craprej.indebcre||'" '||
                                        ' nrdconta="'||gene0002.fn_mask_conta(rw_craprej.nrdconta)||'" '||
                                        ' dscritic="'||substr(vr_dscritic,1,29)||'" ');
        -- Para as criticas abaixo, incrementar quantidade de erros
        IF rw_craprej.cdcritic IN(96,137,172,257,287,439,508,608,762) THEN 
          gene0002.pc_escreve_xml(vr_xmlrel
                                 ,vr_txtrel
                                 ,' qtderros="1"/>');
        ELSE 
          gene0002.pc_escreve_xml(vr_xmlrel
                                 ,vr_txtrel
                                 ,' qtderros="0"/>');
        END IF;
      END LOOP;
      -- Encerrar a tag Rejeitados e iniciar a integrados 
      gene0002.pc_escreve_xml(vr_xmlrel
                             ,vr_txtrel
                             ,'</rejeitados>');
      -- Iniciar a tag Integrados 
      gene0002.pc_escreve_xml(vr_xmlrel,
                              vr_txtrel,
                             '<integrados '||
                                  ' vlmaichq="'||TO_CHAR(vr_vlmaichq,'fm999g999g999g990')||'" '||
                                  ' dtmvtolt="'||TO_CHAR(rw_craplot.dtmvtolt,'dd/mm/rrrr')||'"'||
                                  ' cdagenci="'||rw_craplot.cdagenci||'" '||
                                  ' cdbccxlt="'||rw_craplot.cdbccxlt||'" '||
                                  ' nrdolote="'||TO_CHAR(rw_craplot.nrdolote,'fm999g990')||'" '||
                                  ' qtcompln="'||TO_CHAR(rw_craplot.qtcompln,'fm999g999g999g990')||'" '||
                                  ' vlcompdb="'||TO_CHAR(rw_craplot.vlcompdb,'fm999g999g999g990d00')||'">');
        
      -- Leitura dos lancamentos integrados  --  Maiores cheques
      FOR rw_lcm IN cr_craplcm_integra(vr_nrdolote) LOOP
        -- Envia registro 
        gene0002.pc_escreve_xml(vr_xmlrel
                               ,vr_txtrel
                               ,'<integrado nrdctabb="'||gene0002.fn_mask_conta(rw_lcm.nrdctabb)||'"'||
                                          ' nrdocmto="'||trim(gene0002.fn_mask(rw_lcm.nrdocmto,'zzzz.zzz.zzz.9'))||'" '||
                                          ' nrdconta="'||gene0002.fn_mask_conta(rw_lcm.nrdconta)||'" '||
                                          ' cdhistor="'||TO_CHAR(rw_lcm.cdhistor,'fm9990')||'" '||
                                          ' vllanmto="'||TO_CHAR(rw_lcm.vllanmto,'fm999g999g999g990')||'" '||
                                          ' cdpesqbb="'||substr(rw_lcm.cdpesqbb,1,15)||'" '||
                                          ' nrseqdig="'||TO_CHAR(rw_lcm.nrseqdig,'fm999g990')||'" />');
      END LOOP;        
                               
      -- Solicitaremos o fechamento da tag integrados e root e do XML
      gene0002.pc_escreve_xml(vr_xmlrel
                             ,vr_txtrel
                             ,'</integrados></root>'
                             ,true);
                               
        -- Por fim, iremos solicitar a emissão do relatório 
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,         --> Data do movimento atual
                                  pr_dsxml     => vr_xmlrel,          --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/root',    --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl291.jasper',    --> Arquivo de layout do iReport
                                  pr_dsparams  => NULL,                --> nao enviar parametros
                                  pr_dsarqsaid =>  vr_nmdircop||'/rl/'||vr_tab_crapcop(vr_idx).nmarqimp, --> Arquivo final
                                  pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                  pr_qtcoluna  => 132,                  --> Quantidade de colunas
                                  pr_sqcabrel  => 1,                   --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)
                                  pr_nmformul  => '132dm',             --> Nome do formulário para impressão
                                  pr_nrcopias  => 1,                   --> Número de cópias para impressão
                                  pr_dspathcop => NULL,                --> Diretorio para copia dos arquivos
                                  pr_des_erro  => vr_dscritic);        --> Saida com erro

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memoria alocada para os CLOBs
      dbms_lob.close(vr_xmlrel);
      dbms_lob.freetemporary(vr_xmlrel);
        
    END IF;
      
    --Geração de log de erro - Chamado 696499
    --Inclusão validação e log 191 para integrações com críticas
    IF vr_dscritic IS NULL THEN
      --Enviar critica 190 ao LOG
      vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                             ' --> ' || 'ALERTA: ' ||gene0001.fn_busca_critica(190) ||
                             ': '||vr_tab_crapcop(vr_idx).nmarquiv;
    ELSE
      --Enviar critica 191 ao LOG
      vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                             ' --> ' || 'ALERTA: ' ||gene0001.fn_busca_critica(191) ||
                             ': '||vr_tab_crapcop(vr_idx).nmarquiv;
    END IF;
      
    cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                           pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                           pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                           pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia  => 4,            -- tbgen_prglog_ocorrencia - 4 - Mensagem
                           pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                           pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                           pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                           pr_nmarqlog      => NULL, 
                           pr_idprglog      => vr_idprglog);
      
    -- Move arquivo integrado para o diretorio salvar
    gene0001.pc_OSCommand_Shell(pr_des_comando => 'mv ' || vr_nmdircop||'/integra/'||vr_tab_crapcop(vr_idx).nmarquiv|| ' ' || vr_nmdircop||'/salvar'
                               ,pr_typ_saida => vr_typsaida
                               ,pr_des_saida => vr_dessaida);
    -- Havendo erro, finalizar
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic := 'Erro ao mover arquivo apos processar, alteracoes desfeitas --> ' || vr_dessaida;
      RAISE vr_exc_saida;
    ELSE 
      -- Commitar pois o arquivo foi processado e movido com sucesso 
      COMMIT;
    END IF;
  END LOOP;   
  
  -- Se nao encontrou nenhum arquivo para processar deve continuar o processo apenas alertando ao pessoal
  IF NOT vr_flgarqui THEN
    -- Enviar email para sistemas afim de avisar que o processo rodou sem COMPBB
    vr_conteudo := 'ATENCAO!!<br><br> Voce esta recebendo este e-mail pois o programa ' 
                || vr_cdprogra || ' acusou critica ' || vr_dscritic 
                || '<br><br>COOPERATIVA: ' || pr_cdcooper || ' - ' 
                || rw_crapcop.nmrescop || '.<br>Data: ' || to_char(rw_crapdat.dtmvtolt,'dd/mm/rrrr') 
                || '<br>Hora: ' || to_char(sysdate,'HH:MI:SS');
    -- Solicitar envio do email 
    gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                              ,pr_cdprogra        => 'PC_'||vr_cdprogra
                              ,pr_des_destino     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRPS346_EMAIL_COMPBB')
                              ,pr_des_assunto     => 'Processo da Cooperativa ' ||pr_cdcooper || ' sem COMPE BB'
                              ,pr_des_corpo       => vr_conteudo
                              ,pr_des_anexo       => null
                              ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                              ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                              ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                              ,pr_des_erro        => vr_dscritic);
    -- Encerrar o CRPS e continuar o processo 
    vr_cdcritic := 258;
    raise vr_exc_fimprg;     
  END IF; 
  
  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  COMMIT;
  
EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      --Geração de log de erro - Chamado 696499
      --Enviar critica 258 ao LOG
      vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                             ' --> ' || 'ERRO: ' ||vr_dscritic;

      cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                             pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                             pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                             pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             pr_tpocorrencia  => 2,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                             pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                             pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                             pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                             pr_nmarqlog      => NULL, 
                             pr_idprglog      => vr_idprglog);
    END IF;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;

    --Geração de log de erro - Chamado 696499
    vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                           ' --> ' || 'ERRO: ' ||vr_dscritic;

    cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                           pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                           pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                           pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia  => 2,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                           pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                           pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                           pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                           pr_nmarqlog      => NULL, 
                           pr_idprglog      => vr_idprglog);
 
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;

    --Geração de log de erro - Chamado 696499
    vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                           ' --> ' || 'ERRO: ' ||pr_dscritic;

    --Geração de log de erro - Chamado 696499
    cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                           pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                           pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                           pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia  => 2,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                           pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                           pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                           pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                           pr_nmarqlog      => NULL, 
                           pr_idprglog      => vr_idprglog);

    --Inclusão na tabela de erros Oracle - Chamado 696499
    CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                 ,pr_compleme => pr_dscritic );

    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS346;
--################################# 346 FIM    #################################################################


--################################# 444 INICIO #################################################################
  PROCEDURE PC_CRPS444 ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                        ,pr_flgresta IN PLS_INTEGER             --> Flag Restart
                        ,pr_nmtelant IN VARCHAR2                --> Tela Anterior
                        ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                        ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                        ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
  BEGIN

  DECLARE

     /* Tipos e registros da pc_crps444 */
     TYPE typ_reg_crawdpb IS
       RECORD (vldispon  NUMBER
              ,vlblq001  NUMBER
              ,vlblq002  NUMBER
              ,vlblq003  NUMBER
              ,vlblq004  NUMBER
              ,vlblq999  NUMBER);

     TYPE typ_reg_crawtot IS
       RECORD (vllancto  NUMBER
              ,qtlancto  INTEGER);

     TYPE typ_reg_crapass IS
       RECORD (nrdconta crapass.nrdconta%type
              ,nrdctitg crapass.nrdctitg%type
              ,cdsitdtl crapass.cdsitdtl%type
              ,dtelimin crapass.dtelimin%type
              ,vr_rowid rowid);

     TYPE typ_reg_craprej IS
       RECORD (cdcooper craprej.cdcooper%type
              ,dtrefere craprej.dtrefere%type
              ,nrdconta craprej.nrdconta%type
              ,nrdocmto craprej.nrdocmto%type
              ,vllanmto craprej.vllanmto%type
              ,nrseqdig craprej.nrseqdig%type
              ,cdcritic craprej.cdcritic%type
              ,cdpesqbb craprej.cdpesqbb%type
              ,dscritic VARCHAR2(4000));

     TYPE typ_reg_historico IS 
       RECORD (nrctaori NUMBER          
              ,nrctades NUMBER          
              ,dsrefere VARCHAR2(500));               
       
     TYPE typ_reg_conta_blq IS
       RECORD (cdcooper crapass.cdcooper%TYPE 
              ,nrdconta crapass.nrdconta%TYPE
              ,cdhistor craphis.cdhistor%TYPE
              ,vllanmto craplcm.vllanmto%TYPE);
       
              
     --Definicao dos tipos de tabelas
     TYPE typ_tab_crawdpb   IS TABLE OF typ_reg_crawdpb   INDEX BY PLS_INTEGER;
     TYPE typ_tab_crawtot   IS TABLE OF typ_reg_crawtot   INDEX BY VARCHAR2(30);
     TYPE typ_tab_nmarqint  IS TABLE OF VARCHAR2(100)     INDEX BY PLS_INTEGER;
     TYPE typ_tab_crapass   IS TABLE OF typ_reg_crapass   INDEX BY VARCHAR2(10);
     TYPE typ_tab_craprej   IS TABLE OF typ_reg_craprej   INDEX BY PLS_INTEGER;
     TYPE typ_tab_craphis   IS TABLE OF VARCHAR2(1)       INDEX BY PLS_INTEGER;
     TYPE typ_tab_craplcm   IS TABLE OF NUMBER            INDEX BY VARCHAR2(30);
     TYPE typ_tab_historico IS TABLE OF typ_reg_historico INDEX BY VARCHAR2(50);
     TYPE typ_tab_conta_blq IS TABLE OF typ_reg_conta_blq INDEX BY PLS_INTEGER;

     --Definicao das tabelas de memoria
     vr_tab_crawdpb   typ_tab_crawdpb;
     vr_tab_crawtot   typ_tab_crawtot;
     vr_tab_nmarqint  typ_tab_nmarqint;
     vr_tab_nmarqimp  typ_tab_nmarqint;
     vr_tab_nrdconta  typ_tab_crapass;
     vr_tab_nrdctitg  typ_tab_crapass;
     vr_tab_craprej   typ_tab_craprej;
     vr_tab_craphis   typ_tab_craphis;
     vr_tab_craplcm   typ_tab_craplcm;
     vr_tab_historico typ_tab_historico;
     vr_tab_conta_blq typ_tab_conta_blq;

     /* Cursores da rotina crps444 */

     -- Selecionar os dados da Cooperativa
     CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
       SELECT cop.cdcooper,
              cop.nmrescop,
              cop.nrtelura,
              cop.cdbcoctl,
              cop.cdagectl,
              cop.dsdircop,
              cop.nrctactl,
              cop.cdagedbb,
              cop.cdageitg
         FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;

     --Selecionar associados
     CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%type) IS
       SELECT /*+ INDEX (crapass crapass##crapass7) */
              crapass.nrdctitg,
              crapass.nrdconta,
              crapass.cdsitdtl,
              crapass.dtelimin,
              crapass.cdagenci,
              crapass.rowid
         FROM crapass crapass
        WHERE crapass.cdcooper = pr_cdcooper;
     rw_crapass cr_crapass%ROWTYPE;

     --Selecionar folhas Cheque
     CURSOR cr_crapfdc (pr_cdcooper IN crapfdc.cdcooper%type
                       ,pr_cdbanchq IN crapfdc.cdbanchq%type
                       ,pr_cdagechq IN crapfdc.cdagechq%type
                       ,pr_nrctachq IN crapfdc.nrctachq%type
                       ,pr_nrcheque IN crapfdc.nrcheque%type) IS
       SELECT /*+ index (crapfdc crapfdc##crapfdc1) */
              crapfdc.cdcooper
             ,crapfdc.cdcmpchq
             ,crapfdc.cdbanchq
             ,crapfdc.cdagechq
             ,crapfdc.nrctachq
             ,crapfdc.nrcheque
             ,crapfdc.nrdigchq
             ,crapfdc.nrdconta
             ,crapfdc.nrdctitg
             ,crapfdc.tpcheque
             ,crapfdc.incheque
             ,crapfdc.dtemschq
             ,crapfdc.dtretchq
             ,crapfdc.rowid
        FROM crapfdc
       WHERE crapfdc.cdcooper = pr_cdcooper
       AND   crapfdc.cdbanchq = pr_cdbanchq
       AND   crapfdc.cdagechq = pr_cdagechq
       AND   crapfdc.nrctachq = pr_nrctachq
       AND   crapfdc.nrcheque = pr_nrcheque;
     rw_crapfdc cr_crapfdc%ROWTYPE;

     --Selecionar transferencias entre cooperativas
     CURSOR cr_craptco (pr_cdcooper IN craptco.cdcooper%type
                       ,pr_nrdconta IN craptco.nrdconta%type) IS
       SELECT craptco.nrdconta
         FROM craptco
        WHERE craptco.cdcooper = pr_cdcooper
          AND craptco.nrdconta = pr_nrdconta
          AND craptco.tpctatrf = 1
          AND craptco.flgativo = 1;
     rw_craptco cr_craptco%ROWTYPE;

     --Selecionar transferencias entre cooperativas inativas
     CURSOR cr_craptco_i (pr_cdcooper IN craptco.cdcooper%type
                       ,pr_nrdconta IN craptco.nrdconta%type) IS
       SELECT craptco.nrdconta,
              craptco.nrctaant,
              craptco.cdageant,
              craptco.nrdctitg,
              craptco.cdcopant
         FROM craptco
        WHERE craptco.cdcooper = pr_cdcooper
          AND craptco.nrdconta = pr_nrdconta
          AND craptco.flgativo = 0; --inativa - false
     rw_craptco_i cr_craptco_i%ROWTYPE;

     --Localizar conta migrada pela conta itg
     CURSOR cr_craptco_itg (pr_cdcooper IN craptco.cdcooper%type
                           ,pr_nrdctitg IN craptco.nrdctitg%type
                           ,pr_cdcopant IN craptco.cdcopant%type) IS
       SELECT craptco.nrdconta,
              craptco.nrctaant,
              craptco.cdageant,
              craptco.nrdctitg,
              craptco.cdcopant
         FROM craptco
        WHERE craptco.cdcooper = pr_cdcooper
          AND craptco.nrdctitg = pr_nrdctitg
          AND craptco.cdcopant = pr_cdcopant;
     rw_craptco_itg cr_craptco_itg%ROWTYPE;

      -- buscar a cooperativa anteriro
      CURSOR cr_craptco_cop (pr_cdcooper craptco.cdcooper%type,
                             pr_crctaant craptco.nrctaant%type,
                             pr_cdcopant craptco.cdcopant%type)IS
       SELECT crapcop.cdcooper,
              crapcop.nmrescop
         FROM craptco, crapcop
        WHERE craptco.cdcooper = pr_cdcooper
          AND craptco.nrctaant = pr_crctaant
          AND craptco.cdcopant = pr_cdcopant -- se for as cooperativas migradas
          AND craptco.cdcopant = crapcop.cdcooper;
      rw_craptco_cop cr_craptco_cop%rowtype;

     --Buscar dados tabela generica
     CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%type
                       ,pr_nmsistem IN craptab.nmsistem%type
                       ,pr_tptabela IN craptab.tptabela%type
                       ,pr_cdempres IN craptab.cdempres%type
                       ,pr_cdacesso IN craptab.cdacesso%type
                       ,pr_tpregist IN craptab.tpregist%type) IS
       SELECT craptab.dstextab, craptab.rowid
         FROM craptab
        WHERE craptab.cdcooper = pr_cdcooper
          AND UPPER(craptab.nmsistem) = pr_nmsistem
          AND UPPER(craptab.tptabela) = pr_tptabela
          AND craptab.cdempres = pr_cdempres
          AND UPPER(craptab.cdacesso) = pr_cdacesso
          AND craptab.tpregist = pr_tpregist;
     rw_craptab cr_craptab%ROWTYPE;

     --Buscar informacoes de lote
     CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                       ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                       ,pr_cdagenci IN craplot.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
       SELECT  craplot.cdcooper
              ,craplot.dtmvtolt
              ,craplot.nrdolote
              ,craplot.cdagenci
              ,craplot.nrseqdig
              ,craplot.cdbccxlt
              ,craplot.tplotmov
              ,craplot.qtinfoln
              ,craplot.qtcompln
              ,craplot.vlinfodb
              ,craplot.vlcompdb
              ,craplot.rowid
       FROM craplot craplot
       WHERE craplot.cdcooper = pr_cdcooper
       AND   craplot.dtmvtolt = pr_dtmvtolt
       AND   craplot.cdagenci = pr_cdagenci
       AND   craplot.cdbccxlt = pr_cdbccxlt
       AND   craplot.nrdolote = pr_nrdolote;
       rw_craplot cr_craplot%ROWTYPE;

     --Selecionar lancamentos para carga cursor
     CURSOR cr_craplcm_carga (pr_cdcooper IN craplcm.cdcooper%type
                             ,pr_dtmvtolt IN craplcm.dtmvtolt%type
                             ,pr_cdagenci IN craplcm.cdagenci%type
                             ,pr_cdbccxlt IN craplcm.cdbccxlt%type) IS
       SELECT  craplcm.nrdolote
              ,craplcm.nrdctabb
              ,craplcm.nrdocmto
       FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
       AND   craplcm.dtmvtolt = pr_dtmvtolt
       AND   craplcm.cdagenci = pr_cdagenci
       AND   craplcm.cdbccxlt = pr_cdbccxlt;

     --Selecionar lancamentos
     CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%type
                       ,pr_dtmvtolt IN craplcm.dtmvtolt%type
                       ,pr_cdagenci IN craplcm.cdagenci%type
                       ,pr_cdbccxlt IN craplcm.cdbccxlt%type
                       ,pr_nrdolote IN craplcm.nrdolote%type
                       ,pr_nrdctabb IN craplcm.nrdctabb%type
                       ,pr_nrdocmto IN craplcm.nrdocmto%type) IS
       SELECT craplcm.dtmvtolt,
              craplcm.nrseqdig,
              craplcm.cdhistor
         FROM craplcm
        WHERE craplcm.cdcooper = pr_cdcooper
          AND craplcm.dtmvtolt = pr_dtmvtolt
          AND craplcm.cdagenci = pr_cdagenci
          AND craplcm.cdbccxlt = pr_cdbccxlt
          AND craplcm.nrdolote = pr_nrdolote
          AND craplcm.nrdctabb = pr_nrdctabb
          AND craplcm.nrdocmto = pr_nrdocmto;
     rw_craplcm cr_craplcm%ROWTYPE;

     --Selecionar lancamentos da conta
     CURSOR cr_craplcm2 (pr_cdcooper IN craplcm.cdcooper%type
                        ,pr_nrdconta IN craplcm.nrdconta%type
                        ,pr_nrdocmto IN craplcm.nrdocmto%type) IS
       SELECT /*+ index (craplcm craplcm##craplcm2) */
              craplcm.dtmvtolt
             ,craplcm.nrseqdig
             ,craplcm.cdhistor
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
       AND   craplcm.nrdconta = pr_nrdconta
       AND   craplcm.nrdocmto = pr_nrdocmto
       AND   craplcm.cdhistor IN (21,50)
       ORDER BY craplcm.progress_recid DESC;

     --Selecionar lancamentos CdPesqBB 21
     CURSOR cr_craplcm_21 (pr_cdcooper IN craplcm.cdcooper%type
                          ,pr_nrdconta IN craplcm.nrdconta%type
                          ,pr_nrdocmto IN craplcm.nrdocmto%type) IS
       SELECT craplcm.dtmvtolt
             ,craplcm.nrseqdig
             ,craplcm.cdhistor
       FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
       AND   craplcm.nrdconta = pr_nrdconta
       AND   craplcm.cdhistor IN (47,191,338,573)
       AND   craplcm.nrdocmto = pr_nrdocmto
       AND   craplcm.cdpesqbb = '21';
     --Selecionar Contra-ordens
     CURSOR cr_crapcor (pr_cdcooper IN crapcor.cdcooper%type
                       ,pr_cdbanchq IN crapcor.cdbanchq%type
                       ,pr_cdagechq IN crapcor.cdagechq%type
                       ,pr_nrctachq IN crapcor.nrctachq%type
                       ,pr_nrcheque IN crapcor.nrcheque%type
                       ,pr_flgativo IN crapcor.flgativo%type) IS
       SELECT crapcor.cdhistor
             ,crapcor.dtemscor
             ,crapcor.dtvalcor
       FROM crapcor
       WHERE crapcor.cdcooper = pr_cdcooper
       AND   crapcor.cdbanchq = pr_cdbanchq
       AND   crapcor.cdagechq = pr_cdagechq
       AND   crapcor.nrctachq = pr_nrctachq
       AND   crapcor.nrcheque = pr_nrcheque
       AND   crapcor.flgativo = pr_flgativo;
     rw_crapcor cr_crapcor%ROWTYPE;

     --Selecionar Custodia Cheques
     CURSOR cr_crapcst (pr_cdcooper IN crapcst.cdcooper%type
                       ,pr_cdcmpchq IN crapcst.cdcmpchq%type
                       ,pr_cdbanchq IN crapcst.cdbanchq%type
                       ,pr_cdagechq IN crapcst.cdagechq%type
                       ,pr_nrctachq IN crapcst.nrctachq%type
                       ,pr_nrcheque IN crapcst.nrcheque%type) IS
       SELECT crapcst.nrdconta
       FROM crapcst
       WHERE crapcst.cdcooper = pr_cdcooper
       AND   crapcst.cdcmpchq = pr_cdcmpchq
       AND   crapcst.cdbanchq = pr_cdbanchq
       AND   crapcst.cdagechq = pr_cdagechq
       AND   crapcst.nrctachq = pr_nrctachq
       AND   crapcst.nrcheque = pr_nrcheque;
     rw_crapcst cr_crapcst%ROWTYPE;

     --Selecionar Borderos
     CURSOR cr_crapcdb (pr_cdcooper IN crapcdb.cdcooper%type
                       ,pr_cdcmpchq IN crapcdb.cdcmpchq%type
                       ,pr_cdbanchq IN crapcdb.cdbanchq%type
                       ,pr_cdagechq IN crapcdb.cdagechq%type
                       ,pr_nrctachq IN crapcdb.nrctachq%type
                       ,pr_nrcheque IN crapcdb.nrcheque%type) IS
       SELECT crapcdb.cdcooper
             ,crapcdb.nrdconta
       FROM crapcdb
       WHERE crapcdb.cdcooper = pr_cdcooper
       AND   crapcdb.cdcmpchq = pr_cdcmpchq
       AND   crapcdb.cdbanchq = pr_cdbanchq
       AND   crapcdb.cdagechq = pr_cdagechq
       AND   crapcdb.nrctachq = pr_nrctachq
       AND   crapcdb.nrcheque = pr_nrcheque;
     rw_crapcdb cr_crapcdb%ROWTYPE;

     --Selecionar Saldos Negativos e Devolucao Cheques
     CURSOR cr_crapneg (pr_cdcooper IN crapneg.cdcooper%type
                       ,pr_nrdconta IN crapneg.nrdconta%type
                       ,pr_nrdocmto IN crapneg.nrdocmto%type) IS
       SELECT crapneg.dtfimest
       FROM crapneg
       WHERE crapneg.cdcooper = pr_cdcooper
       AND   crapneg.nrdconta = pr_nrdconta
       AND   crapneg.nrdocmto = pr_nrdocmto
       AND   crapneg.cdhisest = 1
       AND   crapneg.dtfimest IS NULL
       AND   crapneg.cdobserv IN (12,13);

     --Selecionar Historicos
     CURSOR cr_craphis (pr_cdcooper IN craphis.cdcooper%type) IS
       SELECT craphis.cdhistor
             ,craphis.indebcre
       FROM craphis
       WHERE craphis.cdcooper = pr_cdcooper;

     --Selecionar rejeitados
     CURSOR cr_craprej (pr_cdcooper IN craprej.cdcooper%type
                       ,pr_dtmvtolt IN craprej.dtmvtolt%type
                       ,pr_cdagenci IN craprej.cdagenci%type
                       ,pr_cdbccxlt IN craprej.cdbccxlt%type
                       ,pr_nrdolote IN craprej.nrdolote%type
                       ,pr_tplotmov IN craprej.tplotmov%type
                       ,pr_nrdctabb IN craprej.nrdctabb%type
                       ,pr_nrdocmto IN craprej.nrdocmto%type) IS
       SELECT craprej.cdcooper
         FROM craprej
        WHERE craprej.cdcooper = pr_cdcooper
          AND craprej.dtmvtolt = pr_dtmvtolt
          AND craprej.cdagenci = pr_cdagenci
          AND craprej.cdbccxlt = pr_cdbccxlt
          AND craprej.nrdolote = pr_nrdolote
          AND craprej.tplotmov = pr_tplotmov
          AND craprej.nrdctabb = pr_nrdctabb
          AND craprej.nrdocmto = pr_nrdocmto;
     rw_craprej cr_craprej%ROWTYPE;

     --Selecionar informacoes restart
     CURSOR cr_crapres (pr_cdcooper IN crapres.cdcooper%type
                       ,pr_cdprogra IN crapres.cdprogra%type) IS
       SELECT rowid
         FROM crapres
        WHERE crapres.cdcooper = pr_cdcooper
          AND crapres.cdprogra = pr_cdprogra;
     rw_crapres cr_crapres%ROWTYPE;

     --Selecionar valores compensados dos parametros
     CURSOR cr_craptab_tot(pr_cdcooper IN craptab.cdcooper%type
                          ,pr_nmsistem IN craptab.nmsistem%type
                          ,pr_tptabela IN craptab.tptabela%type
                          ,pr_cdempres IN craptab.cdempres%type) IS
       SELECT craptab.dstextab
             ,craptab.cdacesso
             ,craptab.tpregist
             ,Count(1) OVER (PARTITION BY craptab.cdacesso) qtdreg
             ,Row_Number() OVER (PARTITION BY craptab.cdacesso
                                 ORDER BY craptab.cdacesso,craptab.tpregist) seqreg
       FROM craptab
       WHERE craptab.cdcooper = pr_cdcooper
       AND  UPPER(craptab.nmsistem)  = pr_nmsistem
       AND  UPPER(craptab.tptabela)  = pr_tptabela
       AND  craptab.cdempres  = pr_cdempres;
     rw_craptab_tot cr_craptab_tot%ROWTYPE;

     --Selecionar informacoes relatorio gerencial
     CURSOR cr_gntotpl (pr_cdcooper IN gntotpl.cdcooper%type
                       ,pr_dtmvtolt IN gntotpl.dtmvtolt%type) IS
       SELECT rowid
       FROM gntotpl
       WHERE gntotpl.cdcooper = pr_cdcooper
       AND   gntotpl.dtmvtolt = pr_dtmvtolt;
     rw_gntotpl cr_gntotpl%ROWTYPE;

     --Selecionar Rejeitados para relatorio
     CURSOR  cr_craprej_tot (pr_cdcooper IN craprej.cdcooper%type
                            ,pr_dtmvtolt IN craprej.dtmvtolt%type
                            ,pr_cdagenci IN craprej.cdagenci%type
                            ,pr_cdbccxlt IN craprej.cdbccxlt%type
                            ,pr_nrdolote IN craprej.nrdolote%type
                            ,pr_tpintegr IN craprej.tpintegr%type) IS
       SELECT craprej.dshistor
             ,craprej.vllanmto
             ,craprej.cdcritic
             ,craprej.cdcooper
             ,craprej.dtrefere
             ,craprej.nrdconta
             ,craprej.nrdocmto
             ,craprej.nrseqdig
             ,craprej.cdpesqbb
             ,craprej.indebcre
             ,craprej.nrdctabb
             ,craprej.cdempres
       FROM craprej
       WHERE craprej.cdcooper = pr_cdcooper
       AND   craprej.dtmvtolt = pr_dtmvtolt
       -- criterio para tambem exibir os rejeitados por
       -- serem migrados
       -- não é necessario exibir as criticas 999 no relatorio
       -- crrl414_01 somente no crrl414_999
       AND ((craprej.cdagenci = pr_cdagenci and
             craprej.nrdolote = pr_nrdolote)/* or
             craprej.cdcritic = 999*/)
       AND   craprej.cdbccxlt = pr_cdbccxlt
       AND   craprej.tpintegr = pr_tpintegr
       AND   craprej.cdcritic NOT IN (670,863)
       ORDER BY craprej.dtmvtolt
               ,craprej.cdagenci
               ,craprej.cdbccxlt
               ,craprej.nrdolote
               ,craprej.tpintegr
               ,craprej.nrdctabb
               ,craprej.dtdaviso
               ,craprej.nrdocmto;

     --Selecionar lancamentos para relatorio
     CURSOR cr_craplcm_tot (pr_cdcooper  IN craplcm.cdcooper%type
                           ,pr_dtmvtolt  IN craplcm.dtmvtolt%type
                           ,pr_cdagenci  IN craplcm.cdagenci%type
                           ,pr_cdbccxlt  IN craplcm.cdbccxlt%type
                           ,pr_nrdolote  IN craplcm.nrdolote%type) IS
       SELECT craplcm.nrdctabb
             ,craplcm.nrdocmto
             ,craplcm.nrdconta
             ,craplcm.cdhistor
             ,craplcm.vllanmto
             ,craplcm.cdpesqbb
             ,craplcm.nrseqdig
       FROM craplcm
       WHERE craplcm.cdcooper  = pr_cdcooper
       AND   craplcm.dtmvtolt  = pr_dtmvtolt
       AND   craplcm.cdagenci  = pr_cdagenci
       AND   craplcm.cdbccxlt  = pr_cdbccxlt
       AND   craplcm.nrdolote  = pr_nrdolote
       AND   craplcm.cdhistor  IN (50,59);

     --Selecionar Rejeitados Retroativos
     CURSOR cr_craprej_ret (pr_cdcooper IN craprej.cdcooper%type
                           ,pr_dtmvtolt IN craprej.dtmvtolt%type
                           ,pr_cdagenci IN craprej.cdagenci%type
                           ,pr_cdbccxlt IN craprej.cdbccxlt%type
                           ,pr_nrdolote IN craprej.nrdolote%type
                           ,pr_cdcritic IN craprej.cdcritic%type) IS
       SELECT craprej.nrdctabb
             ,craprej.dshistor
             ,craprej.nrdocmto
             ,craprej.vllanmto
             ,craprej.indebcre
             ,craprej.dtrefere
       FROM craprej
       WHERE craprej.cdcooper = pr_cdcooper
       AND   craprej.dtmvtolt = pr_dtmvtolt
       AND   craprej.cdagenci = pr_cdagenci
       AND   craprej.cdbccxlt = pr_cdbccxlt
       AND   craprej.nrdolote = pr_nrdolote
       AND   craprej.cdcritic = pr_cdcritic
       ORDER BY craprej.dtmvtolt
               ,craprej.cdagenci
               ,craprej.cdbccxlt
               ,craprej.nrdolote
               ,craprej.tpintegr
               ,craprej.nrdctabb
               ,craprej.nrdocmto;
     --Registro do tipo calendario
     rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

     --Lista todas as agencias ativas
     CURSOR cr_crapage IS
       SELECT cdagenci,
              qt_agencia,
              ROWNUM linha
       FROM (SELECT cdagenci,
                    COUNT(*) OVER() qt_agencia
               FROM crapage age
              WHERE age.cdcooper = pr_cdcooper
                AND age.insitage = 1
                AND age.cdagenci NOT IN (90,91,95,999)
             ORDER BY cdagenci);

     --Variaveis Locais

     vr_regexist            BOOLEAN;
     vr_flgfirst            BOOLEAN;
     vr_flgclote            BOOLEAN;
     vr_flgentra            BOOLEAN;
     vr_flgerros            BOOLEAN;
     vr_flgarqvz            BOOLEAN;
     vr_flgdepos            BOOLEAN;
     vr_flgchequ            BOOLEAN;
     vr_flgestor            BOOLEAN;
     vr_flgdebit            BOOLEAN;
     vr_flgdevol            BOOLEAN;     
     vr_flgretor            BOOLEAN;
     vr_flgctitg            BOOLEAN;
     vr_flgctaok            BOOLEAN;
     vr_contador            INTEGER;
     vr_contablq            INTEGER := 0;
     vr_cdagenci            INTEGER:= 1;
     vr_cdbccxlt            INTEGER:= 1;
     vr_cdhistor            INTEGER;
     vr_nrdolote            INTEGER;
     vr_nrdiautl            INTEGER;
     vr_nrdctabb            INTEGER;
     vr_rel_nrdctabb        INTEGER;
     vr_nrdctitg_arq        crapass.nrdctitg%type;
     vr_fcraptco_itg        BOOLEAN := FALSE;
     vr_nrdconta            INTEGER;
     vr_nrseqint            INTEGER:= 0;
     vr_nrdocmto            INTEGER;
     vr_cdhislcm            INTEGER;
     vr_cdhisdev            INTEGER;
     vr_nrcopias            INTEGER;
     vr_vllanmto            NUMBER;
     vr_cdpesqbb            VARCHAR2(1000);
     vr_dshistor            VARCHAR2(1000);
     vr_indebcre            VARCHAR2(1);
     vr_dtrefere            VARCHAR2(10);
     vr_dsageori            VARCHAR2(1000);
     vr_nmarqrel            VARCHAR2(25);
     vr_dshstchq            VARCHAR2(1000);
     vr_dshstdep            VARCHAR2(1000);
     vr_dshstblq            VARCHAR2(1000);
     vr_dshstest            VARCHAR2(1000);
     vr_dsestblq            VARCHAR2(1000);
     vr_dshsttrf            VARCHAR2(1000);
     vr_dshstdeb            VARCHAR2(1000);
     vr_dshstdev            VARCHAR2(1000);
     vr_nrdctitg            VARCHAR2(1000);
     vr_dsidenti            VARCHAR2(1000);
     vr_listadir            VARCHAR2(4000);
     vr_setlinha            VARCHAR2(4000);
     vr_dtleiarq            DATE;
     vr_dtferiado           DATE;
     vr_dtdaviso            DATE;
     vr_dtmvtolt            DATE;
     vr_vlmaichq            NUMBER;
     vr_dtliblan            DATE;
     vr_indevchq            INTEGER;
     vr_cdalinea            INTEGER;
     vr_cdconven            INTEGER;
     vr_cdconven_04         INTEGER;
     vr_cdconven_15         INTEGER;
     vr_cdconven_17         INTEGER;
     vr_nrdocmt2            INTEGER;
     vr_flgfinal            BOOLEAN;
     vr_flgcraplcm          BOOLEAN;
     vr_stsnrcal            INTEGER;
     vr_nomedarq            VARCHAR2(1000);
     vr_dsdctitg            VARCHAR2(1000);
     vr_des_assunto         VARCHAR2(1000);
     vr_conteudo            VARCHAR2(1000);
     vr_email_dest          VARCHAR2(1000);
     vr_caminho_rl          VARCHAR2(1000);
     vr_caminho_integra     VARCHAR2(1000);
     vr_caminho_salvar      VARCHAR2(1000);
     vr_caminho_compbb      VARCHAR2(1000);
     vr_dstextab            VARCHAR2(1000);
     vr_dstextab_debito     VARCHAR2(1000);
     vr_dstextab_credito    VARCHAR2(1000);
     vr_dstextab_debito_9   VARCHAR2(1000);
     vr_dstextab_credito_9  VARCHAR2(1000);

     vr_comando             VARCHAR2(1000);
     vr_typ_saida           VARCHAR2(1000);
     vr_lsconta4            VARCHAR2(1000);
     vr_tot_dsintegr        VARCHAR2(1000);
     vr_rowid_lote          ROWID:= NULL;
     vr_rowid_debito        ROWID:= NULL;
     vr_rowid_credito       ROWID:= NULL;
     vr_rowid_debito_9      ROWID:= NULL;
     vr_rowid_credito_9     ROWID:= NULL;
     vr_vlchqvlb            NUMBER:= 0;
     vr_tot_qtcompdb        NUMBER:= 0;
     vr_tot_vlcompdb        NUMBER:= 0;
     vr_tot_qtcompcr        NUMBER:= 0;
     vr_tot_vlcompcr        NUMBER:= 0;
     vr_lot_qtcompln        NUMBER:= 0;
     vr_lot_vlcompdb        NUMBER:= 0;
     vr_tot_contareg        NUMBER:= 0;
     vr_tot_vllanmto        NUMBER:= 0;
     vr_tot_vllandep        NUMBER:= 0;
     vr_tot_qtlandep        NUMBER:= 0;
     vr_tot_nrdctabb        NUMBER:= 0;
     vr_rel_vlbloque        NUMBER:= 0;
     vr_ger_vlbloque        NUMBER:= 0;
     vr_ger_qtcompdb        NUMBER:= 0;
     vr_ger_qtcompcr        NUMBER:= 0;
     vr_ger_vlcompdb        NUMBER:= 0;
     vr_ger_vlcompcr        NUMBER:= 0;
     vr_flgtecsa            BOOLEAN;
     vr_cdempres            craprej.cdempres%type;
     vr_existe_arq          BOOLEAN := FALSE;

     --Variaveis de Controle de Restart
     vr_nrctares            INTEGER:= 0;
     vr_inrestar            INTEGER:= 0;
     vr_dsrestar            crapres.dsrestar%TYPE;

     vr_flgbatch            INTEGER;
     vr_cdprogra            VARCHAR2(10);

     --Variaveis para retorno de erro
     vr_cdcritic            INTEGER:= 0;
     vr_cdcritic2           INTEGER:= 0;
     vr_dscritic            VARCHAR2(4000);
     vr_dscritic2           VARCHAR2(4000);

     --Tabela para receber arquivos lidos no unix
     vr_tab_arquivo GENE0002.typ_split;

     --Variaveis de Excecao
     vr_exc_saida           EXCEPTION;
     vr_exc_fimprg          EXCEPTION;

     --Variaveis utilizadas nos indices
     vr_index_craprej       PLS_INTEGER;
     vr_index_crawdpb       PLS_INTEGER;
     vr_index_crawtot       varchar2(30);
     vr_index_crapass       VARCHAR2(10);
     vr_index_craplcm       VARCHAR2(30);

     -- Variavel para armazenar as informacoes em XML
     vr_des_xml             CLOB;
     vr_des_rej             CLOB;

     --Variaveis de Arquivo
     vr_input_file  utl_file.file_type;

     --Variáveis arquivo contábil
     vr_aux_contador       NUMBER := 0;
     vr_nom_diretorio      VARCHAR2(200); 
     vr_nom_dir_copia      VARCHAR2(200);
     vr_input_filectb      utl_file.file_type;  
     vr_nmarquiv           VARCHAR2(200);   
     vr_setlinha_ctb       VARCHAR2(4000); 
     vr_vllctacm           NUMBER;   
     vr_vllctage           NUMBER; 
     vr_typ_said           VARCHAR2(4);  

     vr_rw_craplot  lanc0001.cr_craplot%ROWTYPE;
     vr_tab_retorno lanc0001.typ_reg_retorno;
     vr_incrineg    INTEGER;
     vr_flbloque    INTEGER;

     PROCEDURE pc_ver_bloqueio(pr_cdcooper IN craphis.cdcooper%TYPE
                              ,pr_cdhistor IN craphis.cdhistor%TYPE
                              ,pr_nrdconta IN crapass.nrdconta%TYPE
                              ,pr_flbloque OUT NUMBER) IS
     BEGIN
       DECLARE 
          CURSOR cr_craphis(pr_cdcooper craphis.cdcooper%TYPE
                           ,pr_cdhistor craphis.cdhistor%TYPE) IS
            SELECT *
              FROM craphis h
             WHERE h.cdcooper = pr_cdcooper
               AND h.cdhistor = pr_cdhistor;
          rw_craphis cr_craphis%ROWTYPE;
          
          vr_id_conta_monitorada NUMBER;  
          
          vr_cdcritic crapcri.cdcritic%TYPE;
          vr_dscritic crapcri.dscritic%TYPE;
          vr_exc_erro EXCEPTION;      
          
       BEGIN
       
          OPEN cr_craphis(pr_cdcooper => pr_cdcooper
                         ,pr_cdhistor => pr_cdhistor);
          FETCH cr_craphis INTO rw_craphis;
          CLOSE cr_craphis;
       
          IF rw_craphis.indebcre = 'D' THEN -- se é débito

              blqj0002.pc_verifica_conta_bloqueio(pr_cdcooper => pr_cdcooper, -- rotina testa se conta monitorada ou não
                                                  pr_nrdconta => pr_nrdconta,
                                                  pr_id_conta_monitorada => vr_id_conta_monitorada,
                                                  pr_cdcritic => vr_cdcritic,
                                                  pr_dscritic => vr_dscritic);
              IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
              
              IF vr_id_conta_monitorada = 1 THEN -- Se conta monitorada    
                        
                IF rw_craphis.indutblq = 'N' AND rw_craphis.inhistor = 11 then -- se o histórico DEBITO não permite débitos
                   pr_flbloque := 1;
                END IF;
                
              END IF;
          END IF;
       EXCEPTION 
         WHEN vr_exc_erro THEN
           --deu ruim
           NULL;
         WHEN OTHERS THEN
           -- deu mais ruim ainda     
           NULL;
       
       END;
     END; 

     --Procedure para limpar os dados das tabelas de memoria
     PROCEDURE pc_limpa_tabela IS
     BEGIN
       vr_tab_crawdpb.DELETE;
       vr_tab_crawtot.DELETE;
       vr_tab_craprej.DELETE;
       vr_tab_craphis.DELETE;
       vr_tab_nrdconta.DELETE;
       vr_tab_nrdctitg.DELETE;
       vr_tab_nmarqint.DELETE;
       vr_tab_nmarqimp.DELETE;
       vr_tab_craplcm.DELETE;

     EXCEPTION
       WHEN OTHERS THEN
         --Variavel de erro recebe erro ocorrido
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao limpar tabelas de memoria. Rotina pc_crps444.pc_limpa_tabela. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END;

     --Escrever no arquivo CLOB
     PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2, pr_tipo IN INTEGER default 1) IS
     BEGIN
       --Escrever no arquivo XML
       IF pr_tipo = 1 THEN --XML para o relatorio
         dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
       ELSIF pr_tipo = 2 THEN -- XML para o arquivo
         dbms_lob.writeappend(vr_des_rej,length(pr_des_dados),pr_des_dados);
       END IF;
     END;

     -- Inicializa tabela de Historicos
     PROCEDURE pc_inicia_historico IS
     BEGIN
        vr_tab_historico.DELETE;

        vr_tab_historico('0231TAR MANUT C').nrctaori := 8306;
        vr_tab_historico('0231TAR MANUT C').nrctades := 1179;
        vr_tab_historico('0231TAR MANUT C').dsrefere := '"DEBITO C/C pr_nrdctabb B.BRASIL REF. TARIFA DE MANUTENCAO DE C/C"';

        vr_tab_historico('0110REBLOQUEIO').nrctaori := 1773;
        vr_tab_historico('0110REBLOQUEIO').nrctades := 1179;
        vr_tab_historico('0110REBLOQUEIO').dsrefere := '"DEBITO C/C pr_nrdctabb B.BRASIL REF. REBLOQUEIO NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0114DEV CH DEPO').nrctaori := 1411;
        vr_tab_historico('0114DEV CH DEPO').nrctades := 1179;
        vr_tab_historico('0114DEV CH DEPO').dsrefere := '"DEBITO C/C pr_nrdctabb B.BRASIL REF. DEVOLUCAO DE CHEQUES DE TERCEIROS DEPOSITADOS NA C/C pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0144TRANSF AGEN').nrctaori := 1773;
        vr_tab_historico('0144TRANSF AGEN').nrctades := 1179;
        vr_tab_historico('0144TRANSF AGEN').dsrefere := '"DEBITO C/C pr_nrdctabb B.BRASIL REF. TRANSFERENCIA AGENDADA NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0189PGTO CRED V').nrctaori := 1773;
        vr_tab_historico('0189PGTO CRED V').nrctades := 1179;
        vr_tab_historico('0189PGTO CRED V').dsrefere := '"DEBITO C/C pr_nrdctabb B.BRASIL REF. PGTO CRED V NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0199MONTREAL TU').nrctaori := 1773;
        vr_tab_historico('0199MONTREAL TU').nrctades := 1179;
        vr_tab_historico('0199MONTREAL TU').dsrefere := '"DEBITO C/C pr_nrdctabb B.BRASIL REF. MONTREAL TU NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0328PGTO CARTAO').nrctaori := 1773;
        vr_tab_historico('0328PGTO CARTAO').nrctades := 1179;
        vr_tab_historico('0328PGTO CARTAO').dsrefere := '"DEBITO C/C pr_nrdctabb B.BRASIL REF. PAGAMENTO DE CARTAO NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0331SAQUE NO TA').nrctaori := 1773;
        vr_tab_historico('0331SAQUE NO TA').nrctades := 1179;
        vr_tab_historico('0331SAQUE NO TA').dsrefere := '"DEBITO C/C pr_nrdctabb B.BRASIL REF. SAQUE NO TAA NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0364BB CONSORCI').nrctaori := 1773;
        vr_tab_historico('0364BB CONSORCI').nrctades := 1179;
        vr_tab_historico('0364BB CONSORCI').dsrefere := '"DEBITO C/C pr_nrdctabb B.BRASIL REF. CONSORCIO BB NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0500FIES JRS/AM').nrctaori := 1773;
        vr_tab_historico('0500FIES JRS/AM').nrctades := 1179;
        vr_tab_historico('0500FIES JRS/AM').dsrefere := '"DEBITO C/C pr_nrdctabb B.BRASIL REF. JUROS/AMORT. FIES NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0500MOVIM. DO D').nrctaori := 1773;
        vr_tab_historico('0500MOVIM. DO D').nrctades := 1179;
        vr_tab_historico('0500MOVIM. DO D').dsrefere := '"DEBITO C/C pr_nrdctabb B.BRASIL REF. MOVIMENTO DO DIA NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0603CHQ SEM FUN').nrctaori := 1179;
        vr_tab_historico('0603CHQ SEM FUN').nrctades := 1894;
        vr_tab_historico('0603CHQ SEM FUN').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. CHEQUE SEM FUNDOS NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0612RECEB FORNE').nrctaori := 1179;
        vr_tab_historico('0612RECEB FORNE').nrctades := 4894;
        vr_tab_historico('0612RECEB FORNE').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. RECEBIMENTO FORNECEDORES NAO INTEGRADA NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0623DOC-CRED CO').nrctaori := 1179;
        vr_tab_historico('0623DOC-CRED CO').nrctades := 4894;
        vr_tab_historico('0623DOC-CRED CO').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. DOC - CRED CO NAO INTEGRADA NA C/C ITG pr_nrctaitg - A REGULARIZAR"';                                                                                                        

        vr_tab_historico('0632OB 12 STN').nrctaori := 1179;
        vr_tab_historico('0632OB 12 STN').nrctades := 4894;
        vr_tab_historico('0632OB 12 STN').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. OB 12 STN NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';                                                                                                        

        vr_tab_historico('0633SEGURO').nrctaori := 1179;
        vr_tab_historico('0633SEGURO').nrctades := 4894;
        vr_tab_historico('0633SEGURO').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. SEGURO NAO INTEGRADA NA C/C ITG pr_nrctaitg - A REGULARIZAR"';                                                                                                        

        vr_tab_historico('0729TRANSFERENC').nrctaori := 1179;
        vr_tab_historico('0729TRANSFERENC').nrctades := 4894;
        vr_tab_historico('0729TRANSFERENC').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. TRANSFERENCIA NAO INTEGRADA NA C/C ITG pr_nrctaitg - A REGULARIZAR"';                                                                                                        

        vr_tab_historico('0732CIELO DEBIT').nrctaori := 1179;
        vr_tab_historico('0732CIELO DEBIT').nrctades := 4894;
        vr_tab_historico('0732CIELO DEBIT').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. CIELO DEBITO NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZARL"';                                                                                                        

        vr_tab_historico('0749BRASILCAP').nrctaori := 1179;
        vr_tab_historico('0749BRASILCAP').nrctades := 4894;
        vr_tab_historico('0749BRASILCAP').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. BRASIL CAP NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';                                                                                                        

        vr_tab_historico('0752CREDITO CDA').nrctaori := 1179;
        vr_tab_historico('0752CREDITO CDA').nrctades := 4894;
        vr_tab_historico('0752CREDITO CDA').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. CREDITO CDA NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';                                                                                                        

        vr_tab_historico('0796ESTORN-DBT').nrctaori := 1179;
        vr_tab_historico('0796ESTORN-DBT').nrctades := 4894;
        vr_tab_historico('0796ESTORN-DBT').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. ESTORNO DE DEBITO NÃO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';                                                                                                        

        vr_tab_historico('0830DEPOS.ONLIN').nrctaori := 1179;
        vr_tab_historico('0830DEPOS.ONLIN').nrctades := 4894;
        vr_tab_historico('0830DEPOS.ONLIN').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. DEPOSITO ON LINE NAO INTEGRADA NA C/C ITG pr_nrctaitg - A REGULARIZAR"';                                                                                                        

        vr_tab_historico('0870TRANSF.ON L').nrctaori := 1179;
        vr_tab_historico('0870TRANSF.ON L').nrctades := 4894;
        vr_tab_historico('0870TRANSF.ON L').dsrefere := '"DEBITO C/C pr_nrdctabb B.BRASIL REF. TRANSFERENCIA ON LINE NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';                                                                                                        

        vr_tab_historico('0900REDE HIPER').nrctaori := 1179;
        vr_tab_historico('0900REDE HIPER').nrctades := 4894;
        vr_tab_historico('0900REDE HIPER').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. REDE HIPER NAO INTEGRADA NA C/C ITG pr_nrctaitg - A REGULARIZAR"';                                                                                                        

        vr_tab_historico('795CONTR CDC I').nrctaori := 1179;
        vr_tab_historico('795CONTR CDC I').nrctades := 4894;
        vr_tab_historico('795CONTR CDC I').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. CREDITO CDA NAO INTEGRADO NA C/C ITG pr_nrctaitg - A REGULARIZAR"';  
        
        vr_tab_historico('0729TRANSF RECE').nrctaori := 1179;
        vr_tab_historico('0729TRANSF RECE').nrctades := 4894;
        vr_tab_historico('0729TRANSF RECE').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. TRANSFERENCIA NAO INTEGRADA NA C/C ITG pr_nrctaitg - A REGULARIZAR"';                                                                                                                

        vr_tab_historico('0976TED-CRED CO').nrctaori := 1179;
        vr_tab_historico('0976TED-CRED CO').nrctades := 4894;
        vr_tab_historico('0976TED-CRED CO').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. TED CREDITO NAO INTEGRADA AUTOMATICAMENTE NA C/C ITG pr_nrctaitg - A REGULARIZAR"';
        
        vr_tab_historico('0189PGTO CDC RE').nrctaori := 1773;
        vr_tab_historico('0189PGTO CDC RE').nrctades := 1179;
        vr_tab_historico('0189PGTO CDC RE').dsrefere := '"DEBITO C/C pr_nrdctabb B.BRASIL REF. PGTO CDC NAO INTEGRADO AUTOMATICAMENTE NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0500REVERSAO DU').nrctaori := 1773;
        vr_tab_historico('0500REVERSAO DU').nrctades := 1179;
        vr_tab_historico('0500REVERSAO DU').dsrefere := '"DEBITO C/C pr_nrdctabb B.BRASIL REF. REVERSAO DUPLICADA NAO INTEGRADA AUTOMATICAMENTE NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0632ORDEM BANCA').nrctaori := 1179;
        vr_tab_historico('0632ORDEM BANCA').nrctades := 4894;
        vr_tab_historico('0632ORDEM BANCA').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. ORDEM BANCARIA NAO INTEGRADA AUTOMATICAMENTE NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0900BRADESCO CR').nrctaori := 1179;
        vr_tab_historico('0900BRADESCO CR').nrctades := 4894;
        vr_tab_historico('0900BRADESCO CR').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. BRADESCO CREDITO NAO INTEGRADO AUTOMATICAMENTE NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0732CIELO CREDI').nrctaori := 1179;
        vr_tab_historico('0732CIELO CREDI').nrctades := 4894;
        vr_tab_historico('0732CIELO CREDI').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. CIELO CREDITO NAO INTEGRADO AUTOMATICAMENTE NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0900REDECARD DE').nrctaori := 1179;
        vr_tab_historico('0900REDECARD DE').nrctades := 4894;
        vr_tab_historico('0900REDECARD DE').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. REDECARD NAO INTEGRADO AUTOMATICAMENTE NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0886REMUNER. AC').nrctaori := 1179;
        vr_tab_historico('0886REMUNER. AC').nrctades := 4894;
        vr_tab_historico('0886REMUNER. AC').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. REMUNERACAO AC NAO INTEGRADO AUTOMATICAMENTE NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0900REDE VISA D').nrctaori := 1179;
        vr_tab_historico('0900REDE VISA D').nrctades := 4894;
        vr_tab_historico('0900REDE VISA D').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. REDE VISA NAO INTEGRADO AUTOMATICAMENTE NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0900REDE CREDIT').nrctaori := 1179;
        vr_tab_historico('0900REDE CREDIT').nrctades := 4894;
        vr_tab_historico('0900REDE CREDIT').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. REDE CREDITO NAO INTEGRADO AUTOMATICAMENTE NA C/C ITG pr_nrctaitg - A REGULARIZAR"';

        vr_tab_historico('0612CRED PAGSEG').nrctaori := 1179;
        vr_tab_historico('0612CRED PAGSEG').nrctades := 4894;
        vr_tab_historico('0612CRED PAGSEG').dsrefere := '"CREDITO C/C pr_nrdctabb B.BRASIL REF. CREDITO PAGSEGURO NAO INTEGRADO AUTOMATICAMENTE NA C/C ITG pr_nrctaitg - A REGULARIZAR"';
        
     END;

     --Funcao para verificar conta integracao
     FUNCTION fn_ver_contaitg (pr_nrdctitg IN VARCHAR2) return INTEGER IS
       vr_nrdctitg INTEGER;
     BEGIN
       --Se vier nulo retorna zero
       IF pr_nrdctitg IS NULL OR length(pr_nrdctitg) = 0 THEN
         RETURN(0);
       ELSE
         --Verificar se a conta termina com numero
         IF REGEXP_INSTR(SUBSTR(pr_nrdctitg,LENGTH(pr_nrdctitg),1), '[^[:digit:]]') = 0 THEN
           vr_nrdctitg:= to_number(pr_nrdctitg);
         ELSE
           vr_nrdctitg:= to_number(substr(pr_nrdctitg,1,length(pr_nrdctitg)-1)||'0');
         END IF;
         RETURN(vr_nrdctitg);
       END IF;
     EXCEPTION
       WHEN OTHERS THEN
         --Variavel de erro recebe erro ocorrido
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao verificar conta integracao. Rotina pc_crps444.fn_ver_contaitg. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END;

     --Funcao para retornar a Ultima conta convenio cadastrada
     FUNCTION fn_ultctaconve (pr_dstextab IN VARCHAR2) RETURN VARCHAR2 IS
       vr_dstextab craptab.dstextab%type;
     BEGIN
       --Se a posicao da virgula estiver no final do parametro
       IF instr(pr_dstextab,',',-1) = LENGTH(TRIM(pr_dstextab)) THEN
         vr_dstextab:= substr(pr_dstextab,1,LENGTH(TRIM(pr_dstextab))-1);
         vr_dstextab:= substr(vr_dstextab,Instr(vr_dstextab,',',-1)+1,10);
       ELSIF Instr(pr_dstextab,',',-1) > 0 THEN
         vr_dstextab:= substr(pr_dstextab,instr(pr_dstextab,',',-1)+1,10);
       ELSE
         vr_dstextab:= pr_dstextab;
       END IF;
       --Retornar string
       return(vr_dstextab);
     EXCEPTION
       WHEN OTHERS THEN
         --Variavel de erro recebe erro ocorrido
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao verificar ultima conta convenio. Rotina pc_crps444.fn_ultctaconve. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END;

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
       RETURN lpad(pr_cdagenci,3,0)||',' 
            ||TRIM(TO_CHAR(pr_vlagenci,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
     END fn_set_gerencial;      


     --Procedure para enviar email
     PROCEDURE pc_envia_email (pr_cdcooper IN crapcop.cdcooper%type
                              ,pr_nmrescop IN crapcop.nmrescop%type
                              ,pr_cdprogra IN VARCHAR2
                              ,pr_dtmvtolt IN DATE) IS
       vr_des_assunto VARCHAR2(1000);
       vr_email_dest  VARCHAR2(1000);
       vr_conteudo    VARCHAR2(1000);
     BEGIN
       vr_conteudo:= 'ATENCAO!!<br><br> Voce esta recebendo este e-mail pois o programa '||
                     vr_cdprogra || ' acusou critica ' || vr_dscritic ||
                     '<br><br>COOPERATIVA: ' || pr_cdcooper || ' - ' ||
                     pr_nmrescop || '.<br>Data: ' || to_char(pr_dtmvtolt,'DD/MM/YYYY') ||
                     '<br>Hora: '|| TO_CHAR(SYSDATE,'HH24:MI:SS');
       --Assunto do email
       vr_des_assunto:= 'Processo da Cooperativa '||pr_cdcooper|| ' sem COMPE BB';

       --Email Destino
       vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRPS444_SEM_COMPE_BB');
       --Enviar Email
       gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                 ,pr_cdprogra        => pr_cdprogra
                                 ,pr_des_destino     => vr_email_dest
                                 ,pr_des_assunto     => vr_des_assunto
                                 ,pr_des_corpo       => vr_conteudo
                                 ,pr_des_anexo       => NULL
                                 ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                 ,pr_flg_remete_coop => 'N' --> Se o envio serÃ¡ do e-mail da Cooperativa
                                 ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                 ,pr_des_erro        => vr_dscritic);

     EXCEPTION
       WHEN OTHERS THEN
         --Variavel de erro recebe erro ocorrido
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao enviar email. Rotina pc_crps444.pc_envia_email. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END;

     --Procedure para enviar email
     PROCEDURE pc_envia_email_blq (pr_cdcooper IN crapcop.cdcooper%type
                                  ,pr_nmrescop IN crapcop.nmrescop%type
                                  ,pr_cdprogra IN VARCHAR2
                                  ,pr_dtmvtolt IN DATE) IS
       vr_des_assunto VARCHAR2(1000);
       vr_email_dest  VARCHAR2(1000);
       vr_conteudo    VARCHAR2(4000);
     BEGIN
       vr_conteudo:= 'ATENCAO!!<br><br> Voce esta recebendo este e-mail pois o programa '||
                     vr_cdprogra || ' realizou movimentacoes para contas durante o horario de monitoramento BACENJUD'||
                     '<br><br>COOPERATIVA: ' || pr_cdcooper || ' - ' ||
                     pr_nmrescop || '.<br>Data: ' || to_char(pr_dtmvtolt,'DD/MM/YYYY') ||
                     '<br>Hora: '|| TO_CHAR(SYSDATE,'HH24:MI:SS');
       
       --tiago loop da temp table botando as contas.
       vr_conteudo := vr_conteudo||'<br>';       
       
       FOR vr_indx IN vr_tab_conta_blq.FIRST..vr_tab_conta_blq.LAST LOOP
       
         vr_conteudo := vr_conteudo || '<br> COOP: ' || vr_tab_conta_blq(vr_indx).cdcooper ||' CONTA:' || nvl(vr_tab_conta_blq(vr_indx).nrdconta, 0)||
                        ' HIST:' || nvl(vr_tab_conta_blq(vr_indx).cdhistor,0) || ' VALOR:' || TO_CHAR(nvl(vr_tab_conta_blq(vr_indx).vllanmto,0));
         
       END LOOP;      
       
       --Assunto do email
       vr_des_assunto:= 'Movimentacoes para a cooperativa '||pr_cdcooper|| ', Data: ' || to_char(pr_dtmvtolt,'DD/MM/YYYY') ||
                     ' Hora: '|| TO_CHAR(SYSDATE,'HH24:MI:SS');

       --Email Destino
       vr_email_dest:= 'bacenjud@ailos.coop.br';
       --Enviar Email
       gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                 ,pr_cdprogra        => pr_cdprogra
                                 ,pr_des_destino     => vr_email_dest
                                 ,pr_des_assunto     => vr_des_assunto
                                 ,pr_des_corpo       => vr_conteudo
                                 ,pr_des_anexo       => NULL
                                 ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                 ,pr_flg_remete_coop => 'N' --> Se o envio serÃ¡ do e-mail da Cooperativa
                                 ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                 ,pr_des_erro        => vr_dscritic);

     EXCEPTION
       WHEN OTHERS THEN
         --Variavel de erro recebe erro ocorrido
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao enviar email. Rotina pc_crps444.pc_envia_email. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END;


     --Saldos da Concredi
     PROCEDURE pc_saldos_indet_concredi (pr_dsdlinha IN VARCHAR2
                                        ,pr_nrdctabb IN INTEGER) IS
       vr_saldo NUMBER(25,2):= 0;
     BEGIN
       IF SUBSTR(pr_dsdlinha,42,1) = '0' THEN
         vr_saldo:= TO_NUMBER(SUBSTR(pr_dsdlinha,43,17)) / 100;
         --Verificar se existe
         IF vr_tab_crawdpb.EXISTS(pr_nrdctabb) THEN
           vr_tab_crawdpb(pr_nrdctabb).vlblq999:= vr_tab_crawdpb(pr_nrdctabb).vlblq999 + vr_saldo;
         ELSE
           vr_tab_crawdpb(pr_nrdctabb).vlblq999:= vr_saldo;
         END IF;
       END IF;
     EXCEPTION
       WHEN OTHERS THEN
         --Variavel de erro recebe erro ocorrido
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro na rotina pc_crps444.pc_saldos_indeterminado_concredi. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END;

     --Procedure para Atualizar os saldos
     PROCEDURE pc_atualiza_saldos (pr_dsdlinha IN VARCHAR2
                                  ,pr_nrdctabb IN INTEGER) IS
       --Variaveis locais
       vlblq001 number;
       vlblq002 number;
       vlblq003 number;
       vlblq004 number;
       vlblq999 number;
     BEGIN
       IF SUBSTR(pr_dsdlinha,42,1) = '0' THEN
         --Determinar os valores
         vlblq001:= TO_NUMBER(SUBSTR(pr_dsdlinha,157,17)) / 100;
         vlblq002:= TO_NUMBER(SUBSTR(pr_dsdlinha,140,17)) / 100;
         vlblq003:= TO_NUMBER(SUBSTR(pr_dsdlinha,123,17)) / 100;
         vlblq004:= TO_NUMBER(SUBSTR(pr_dsdlinha,106,17)) / 100;
         vlblq999:= TO_NUMBER(SUBSTR(pr_dsdlinha,043,17)) / 100;

         --Verificar se existe
         IF vr_tab_crawdpb.EXISTS(pr_nrdctabb) THEN
           vr_tab_crawdpb(pr_nrdctabb).vlblq001:= vr_tab_crawdpb(pr_nrdctabb).vlblq001 + vlblq001;
           vr_tab_crawdpb(pr_nrdctabb).vlblq002:= vr_tab_crawdpb(pr_nrdctabb).vlblq002 + vlblq002;
           vr_tab_crawdpb(pr_nrdctabb).vlblq003:= vr_tab_crawdpb(pr_nrdctabb).vlblq003 + vlblq003;
           vr_tab_crawdpb(pr_nrdctabb).vlblq004:= vr_tab_crawdpb(pr_nrdctabb).vlblq004 + vlblq004;
           vr_tab_crawdpb(pr_nrdctabb).vlblq999:= vr_tab_crawdpb(pr_nrdctabb).vlblq999 + vlblq999;
         ELSE
           vr_tab_crawdpb(pr_nrdctabb).vlblq001:= vlblq001;
           vr_tab_crawdpb(pr_nrdctabb).vlblq002:= vlblq002;
           vr_tab_crawdpb(pr_nrdctabb).vlblq003:= vlblq003;
           vr_tab_crawdpb(pr_nrdctabb).vlblq004:= vlblq004;
           vr_tab_crawdpb(pr_nrdctabb).vlblq999:= vlblq999;
         END IF;
       END IF;
     EXCEPTION
       WHEN OTHERS THEN
         --Variavel de erro recebe erro ocorrido
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro na rotina pc_crps444.pc_atualiza_saldos. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END;

     --Gerar Relatorio para Viacredi
     PROCEDURE pc_imprime_rel_414_99 (pr_cdcooper IN crapcop.cdcooper%type
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%type
                                     ,pr_caminho  IN VARCHAR2
                                     ,pr_nmarqrel IN VARCHAR2
                                     ,pr_cdcritic OUT INTEGER
                                     ,pr_dscritic OUT VARCHAR2) IS
       --Selecionar Rejeitados 999
       CURSOR cr_craprej_999 (pr_cdcooper IN crapcop.cdcooper%type
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%type) IS
         SELECT craprej.nrseqdig
               ,craprej.dshistor
               ,craprej.nrdctabb
               ,craprej.dtrefere
               ,craprej.nrdocmto
               ,craprej.cdpesqbb
               ,craprej.vllanmto
               ,craprej.indebcre
               ,craprej.nrdconta
               ,craprej.cdcritic
               ,craprej.dtmvtolt
               ,craprej.cdagenci
               ,craprej.cdbccxlt
               ,craprej.nrdolote
               ,craprej.nrdctitg
               ,craprej.cdcooper
               ,craprej.cdempres
         FROM craprej
         WHERE craprej.cdcooper = pr_cdcooper
         AND   craprej.dtmvtolt = pr_dtmvtolt
         AND   craprej.cdcritic = 999
         ORDER BY craprej.dtmvtolt
                 ,craprej.cdagenci
                 ,craprej.cdbccxlt
                 ,craprej.nrdolote
                 ,craprej.tpintegr
                 ,craprej.nrdctabb
                 ,craprej.nrdocmto;

       --Variaveis Locais
       vr_flgfirst      BOOLEAN:= TRUE;
       vr_flimprel      BOOLEAN:= FALSE;
       vr_nrcopias      INTEGER:= 0;
       vr_tot_vlncredi  NUMBER:= 0;
       vr_tot_vlndbito  NUMBER:= 0;
       vr_tot_cntrgrej  NUMBER:= 0;
       vr_tot_cntregis  NUMBER:= 0;
       vr_tot_vlncrrej  NUMBER:= 0;
       vr_tot_vlndbrej  NUMBER:= 0;
       vr_dsliblan      VARCHAR2(30);
       vr_msgcritic     VARCHAR2(30):= 'Cooperado da ACREDICOOP';

       -- Variavel para armazenar o clob referente ao log de erro
       vr_clob_rej  clob;
       vr_char_rej  varchar2(32600) := NULL;
       vr_dslinha   varchar2(32600) := NULL;

     BEGIN

       --Selecionar todos os rejeitados historico 999
       FOR rw_rej IN cr_craprej_999 (pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => pr_dtmvtolt) LOOP
         --Se for primeiro registro
         IF vr_flgfirst THEN
           vr_flgfirst:= FALSE;
           vr_flimprel:= TRUE;

           -- Inicializar o CLOB
           dbms_lob.createtemporary(vr_des_xml, TRUE);
           dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

           dbms_lob.createtemporary(vr_clob_rej, TRUE);
           dbms_lob.open(vr_clob_rej, dbms_lob.lob_readwrite);

           -- Inicilizar as informacoes do XML
           pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl414_tot><rejeitados>');
         END IF;

         --Incrementar contador registros
         vr_tot_cntregis:= nvl(vr_tot_cntregis,0) + 1;

         --Acumular Valor Lancamento
         IF rw_rej.indebcre = 'C' THEN
           vr_tot_vlncredi := vr_tot_vlncredi + rw_rej.vllanmto;
         ELSIF rw_rej.indebcre = 'D' THEN
           vr_tot_vlndbito := vr_tot_vlndbito + rw_rej.vllanmto;
         END IF;

         IF rw_rej.cdcritic = 999 THEN
           -- buscar dados da coop. antiga
           OPEN  cr_craptco_cop (pr_cdcooper => rw_rej.cdcooper,
                                 pr_crctaant => rw_rej.nrdconta,
                                 -- usado campo cdempres para guardar cdcopant
                                 pr_cdcopant => rw_rej.cdempres);
           FETCH cr_craptco_cop INTO rw_craptco_cop;

           IF cr_craptco_cop%FOUND THEN
             vr_msgcritic := 'Cooperado da '||rw_craptco_cop.nmrescop;
           ELSE
            vr_msgcritic := 'Cooperativa nao localizada';
           END IF;
           CLOSE cr_craptco_cop;
         END IF;
         /* Lunelli - Criação arquivo */
         vr_dshistor := rw_rej.dshistor;
         vr_cdhistor := 0;

         IF vr_nrdctabb = vr_rel_nrdctabb    AND
            INSTR(vr_dshsttrf,SUBSTR(vr_dshistor,01,04)) = 0 AND
            vr_dshistor not in ('0144TRANSF AGENDADA','0144TRANSFERENCIA','0729TRANSF RECEBIDA','0144TRANSF PERIODIC') THEN
           NULL;
         ELSIF INSTR(vr_dshstdep,SUBSTR(vr_dshistor,01,04)) > 0 THEN  /* Deposito */
           IF INSTR(vr_dshstblq,SUBSTR(vr_dshistor,01,04)) > 0 THEN /* Deposito Bloqueado */
              vr_nrdiautl := 0;
              CASE SUBSTR(vr_dshistor,01,04)
                  WHEN '0511' THEN vr_nrdiautl := 1;
                  WHEN '0512' THEN vr_nrdiautl := 2;
                  WHEN '0513' THEN vr_nrdiautl := 3;
                  WHEN '0514' THEN vr_nrdiautl := 4;
                  WHEN '0515' THEN vr_nrdiautl := 5;
                  WHEN '0516' THEN vr_nrdiautl := 6;
                  WHEN '0517' THEN vr_nrdiautl := 7;
                  WHEN '0518' THEN vr_nrdiautl := 8;
                  WHEN '0519' THEN vr_nrdiautl := 9;
                  WHEN '0520' THEN vr_nrdiautl := 20;
                  WHEN '0911' THEN vr_nrdiautl := 1;
                  WHEN '0912' THEN vr_nrdiautl := 2;
                  WHEN '0913' THEN vr_nrdiautl := 3;
                  WHEN '0914' THEN vr_nrdiautl := 4;
                  WHEN '0915' THEN vr_nrdiautl := 5;
                  WHEN '0916' THEN vr_nrdiautl := 6;
                  WHEN '0917' THEN vr_nrdiautl := 7;
                  WHEN '0918' THEN vr_nrdiautl := 8;
                  WHEN '0919' THEN vr_nrdiautl := 9;
                  WHEN '0920' THEN vr_nrdiautl := 20;
             END CASE;

            IF vr_nrdiautl = 1   THEN
              vr_dtliblan := rw_crapdat.dtmvtopr;
              vr_cdhistor := 170;
            ELSE
              vr_dtliblan := rw_crapdat.dtmvtopr;
              vr_cdhistor := 170;
              vr_contador := vr_nrdiautl;

              WHILE vr_contador > 1 loop

                 vr_dtliblan := vr_dtliblan + 1;

                 --verificar se é feriado ou sabado ou domingo
                 IF gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                pr_dtmvtolt => vr_dtliblan) <> vr_dtliblan THEN
                  continue;
                 END IF;
                 vr_contador := vr_contador - 1;

              END LOOP;  /*  Fim do DO WHILE  */

            END IF;

           ELSE
             CASE SUBSTR(vr_dshistor,01,04)
                 WHEN '0688' THEN vr_cdhistor := 646;
                 WHEN '0623' THEN vr_cdhistor := 314;
                 WHEN '0732' THEN vr_cdhistor := 584;
                 WHEN '0976' THEN vr_cdhistor := 651;
                 ELSE vr_cdhistor := 169;
             END CASE;

             vr_dtliblan := null;
             
             /*0612REDECARD CREDIT, 0900REDE CABAL DEBI, 0900REDE CB CREDITO, 
               0900REDE CREDITO   , 0900REDE DC CREDITO, 0900REDE HIPER CRED,
               0900REDE MA CREDITO, 0900REDE SICREDI CR, 0900REDE VENDAS DEB,
               0900REDE VI CREDITO, 0900REDE VISA DEBIT, 0900REDE-CS CR     ,
               0900REDECARD HP DEB, 0900REDECARD MA DEB, 0900REDECARD SI DEB,
               0900REDECARD VI DEB */
               
             IF SUBSTR(vr_dshistor,01,08) IN ('0612REDE','0900REDE') THEN  
               vr_cdhistor := 444;
             ELSIF SUBSTR(vr_dshistor,01,12) = '707BENEFICIO' THEN
               vr_cdhistor := 694;
             END IF;

           END IF; /* fim Deposito Bloqueado */
         ELSIF INSTR(vr_dshstest,SUBSTR(vr_dshistor,01,04)) > 0 THEN
           IF INSTR(vr_dsestblq,SUBSTR(vr_dshistor,01,04)) > 0 THEN
             vr_cdhistor := 297;    /* Est. Depositos Bloq. */
           ELSIF SUBSTR(vr_dshistor,01,04) in ('0780','0807','0828') THEN
             vr_cdhistor := 662;    /* Est. Debitos */
           ELSE
             vr_cdhistor := 290;    /* Est. Depositos */
           END IF;
         ELSIF INSTR(vr_dshstdeb,SUBSTR(vr_dshistor,01,04)) > 0 THEN /* Debitos */
           CASE SUBSTR(vr_dshistor,01,04)
             WHEN '0233' THEN vr_cdhistor := 614;
             WHEN '0331' THEN vr_cdhistor := 614;
             WHEN '0328' THEN vr_cdhistor := 658;
             WHEN '0234' THEN vr_cdhistor := 613;
             WHEN '0470' THEN vr_cdhistor := 668;
             WHEN '0474' THEN vr_cdhistor := 668;
             WHEN '0144' THEN vr_cdhistor := 471;
             ELSE vr_cdhistor := 661;
           END CASE;
         ELSIF SUBSTR(vr_dshistor,01,04) = '0114' THEN /* Devolucoes recebidas */              
              vr_cdhistor := 351;
           END IF;

         IF gene0002.fn_existe_valor(vr_dshstdeb,SUBSTR(vr_dshistor,01,04),',') = 'S' OR
            gene0002.fn_existe_valor(vr_dshstest,SUBSTR(vr_dshistor,01,04),',') = 'S' THEN
           IF vr_cdhistor = 297 THEN
             vr_cdhistor := 290;
           ELSIF vr_cdhistor not in (611,613,614,658,
                                     668,661,471,662) THEN
             vr_cdhistor := 290;
           END IF;
         END IF;

         IF nvl(vr_cdhistor,0) = 0 THEN

           vr_msgcritic := 'Historico nao encontrado.';
           vr_tot_cntrgrej := vr_tot_cntrgrej + 1;
           vr_tot_cntregis := vr_tot_cntregis - 1;

           IF rw_rej.indebcre = 'C' THEN
             vr_tot_vlncrrej := vr_tot_vlncrrej + rw_rej.vllanmto;
             vr_tot_vlncredi := vr_tot_vlncredi - rw_rej.vllanmto;
           ELSIF rw_rej.indebcre = 'D' THEN
             vr_tot_vlndbrej := vr_tot_vlndbrej + rw_rej.vllanmto;
             vr_tot_vlndbito := vr_tot_vlndbito - rw_rej.vllanmto;
           END IF;
         ELSE
           IF trim(rw_rej.dtrefere) is null THEN
             vr_dtrefere := ' ';
           END IF;
           IF  vr_dtliblan is null THEN
             vr_dsliblan := ' ';
           ELSE
             vr_dsliblan := vr_dtliblan;
           END IF;

           /* Gerar arquivo damigração da 4-concredi para 1-viacredi e
              15-credimilsul para 13-SCRCRED somente no perido que as duas ctas estao ativas */
           IF pr_cdcooper in (1,13) AND
             (rw_crapdat.dtmvtolt >= to_date('11/18/2014','MM/DD/RRRR')   AND
              rw_crapdat.dtmvtolt <= to_date('11/30/2014','MM/DD/RRRR'))  THEN
             -- montar arquivo de rejeitados
             vr_dslinha :=  to_char(rw_rej.dtmvtolt,'MM/DD/RRRR')          ||';'||
                            nvl(to_char(rw_rej.dtrefere,'MM/DD/RRRR'),' ') ||';'||
                            rw_rej.cdagenci ||';'||
                            rw_rej.cdbccxlt ||';'||
                            rw_rej.nrdolote ||';'||
                            rw_rej.nrdconta ||';'||
                            rw_rej.nrdctabb ||';'||
                            rw_rej.nrdctitg ||';'||
                            rw_rej.nrdocmto ||';'||
                            vr_cdhistor     ||';'||
                            rw_rej.vllanmto ||';'||
                            rw_rej.cdpesqbb ||';'||
                            rw_rej.cdcooper ||';'||
                            rw_rej.nrseqdig ||';'||
                            rw_rej.indebcre ||';'||
                            nvl(vr_dsliblan,' ') ||';';
             -- incluir no clob
             gene0002.pc_escreve_xml(vr_clob_rej,vr_char_rej,vr_dslinha||chr(13)||chr(10));
           END IF;

           
           /* Gerar arquivo da incorporacao da Transulcred para Transpocred
              somente no perido que as duas ctas estao ativas */
           IF pr_cdcooper = 9 AND
             (rw_crapdat.dtmvtolt >= to_date('12/12/2016','MM/DD/RRRR')   AND
              rw_crapdat.dtmvtolt <= to_date('12/31/2016','MM/DD/RRRR'))  THEN
             -- montar arquivo de rejeitados
             vr_dslinha :=  to_char(rw_rej.dtmvtolt,'MM/DD/RRRR')          ||';'||
                            nvl(to_char(rw_rej.dtrefere,'MM/DD/RRRR'),' ') ||';'||
                            rw_rej.cdagenci ||';'||
                            rw_rej.cdbccxlt ||';'||
                            rw_rej.nrdolote ||';'||
                            rw_rej.nrdconta ||';'||
                            rw_rej.nrdctabb ||';'||
                            rw_rej.nrdctitg ||';'||
                            rw_rej.nrdocmto ||';'||
                            vr_cdhistor     ||';'||
                            rw_rej.vllanmto ||';'||
                            rw_rej.cdpesqbb ||';'||
                            rw_rej.cdcooper ||';'||
                            rw_rej.nrseqdig ||';'||
                            rw_rej.indebcre ||';'||
                            nvl(vr_dsliblan,' ') ||';';
             -- incluir no clob
             gene0002.pc_escreve_xml(vr_clob_rej,vr_char_rej,vr_dslinha||chr(13)||chr(10));
           END IF;

         END IF;


         --Montar tag saldo contabil para arquivo XML
         pc_escreve_xml
           ('<rej dscritic="'||vr_msgcritic||'">
                <nrseqdig>'||gene0002.fn_mask(rw_rej.nrseqdig,'zzz.zz9')||'</nrseqdig>
                <dshistor>'||substr(rw_rej.dshistor,1,15)||'</dshistor>
                <nrdctabb>'||gene0002.fn_mask_conta(rw_rej.nrdctabb)||'</nrdctabb>
                <dtrefere>'||rw_rej.dtrefere||'</dtrefere>
                <nrdocmto>'||trim(gene0002.fn_mask(rw_rej.nrdocmto,'zzzzzz.zzz.9'))||'</nrdocmto>
                <cdpesqbb>'||substr(rw_rej.cdpesqbb,1,13)||'</cdpesqbb>
                <vllanmto>'||To_Char(rw_rej.vllanmto,'fm99999g999g990d00')||'</vllanmto>
                <indebcre>'||rw_rej.indebcre||'</indebcre>
                <nrdconta>'||gene0002.fn_mask_conta(rw_rej.nrdconta)||'</nrdconta>
             </rej>');

       END LOOP;

       --Se imprime relatorio
       IF vr_flimprel THEN

         pc_escreve_xml('<total>
                           <tot_cntregis>'|| vr_tot_cntregis  ||'</tot_cntregis>
                           <tot_cntrgrej>'|| vr_tot_cntrgrej  ||'</tot_cntrgrej>
                           <tot_vlncredi>'|| vr_tot_vlncredi  ||'</tot_vlncredi>
                           <tot_vlncrrej>'|| vr_tot_vlncrrej  ||'</tot_vlncrrej>
                           <tot_vlndbito>'|| vr_tot_vlndbito  ||'</tot_vlndbito>
                           <tot_vlndbrej>'|| vr_tot_vlndbrej  ||'</tot_vlndbrej>
                         </total>');

         -- Finalizar tag XML
         pc_escreve_xml('</rejeitados></crrl414_tot>');

         --Determinar Numero copias
         IF pr_cdcooper = 1 THEN
           vr_nrcopias:= 2;
         ELSE
           vr_nrcopias:= 1;
         END IF;

         /* Enviar Email TCO */

         --Montar Assunto
         vr_des_assunto:= 'Relatorio da Conta Integracao';

         --Recuperar emails de destino
         vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRPS444_RELATORIO_TCO');

         IF vr_email_dest IS NULL THEN
           --Montar mensagem de erro
           vr_dscritic:= 'NÃo foi encontrado destinatario para relatorio TCO.';
           --Levantar Excessao
           RAISE vr_exc_saida;
         END IF;

         -- Efetuar solicitacao de geracao de relatorio crrl288 --
         gene0002.pc_solicita_relato (pr_cdcooper  => pr_cdcooper                  --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                  --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt          --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml                   --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl414_tot/rejeitados/rej' --> N? base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl414_total.jasper'          --> Arquivo de layout do iReport
                                     ,pr_dsparams  => NULL                         --> Titulo do relat?rio
                                     ,pr_dsarqsaid => pr_caminho||'/'||pr_nmarqrel --> Arquivo final
                                     ,pr_qtcoluna  => 132                          --> 132 colunas
                                     ,pr_sqcabrel  => 1                            --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                     ,pr_flg_impri => 'S'                          --> Chamar a impress?o (Imprim.p)
                                     ,pr_nmformul  => '132dm'                      --> Nome do formul?rio para impress?o
                                     ,pr_nrcopias  => vr_nrcopias                  --> N?mero de c?pias
                                     ,pr_flg_gerar => 'N'                          --> gerar PDF
                                     ,pr_dsmailcop => vr_email_dest                --> Lista sep. por ';' de emails para envio do relatÃ³rio
                                     ,pr_dsassmail => vr_des_assunto               --> Assunto do e-mail que enviarÃ¡ o relatÃ³rio
                                     ,pr_dscormail => NULL                         --> HTML corpo do email que enviarÃ¡ o relatÃ³rio
                                     ,pr_fldosmail => 'S'                          --> Conversar anexo para DOS antes de enviar
                                     ,pr_dscmaxmail => ' | tr -d "\032"'           --> Complemento do comando converte-arquivo
                                     ,pr_des_erro  => vr_dscritic);                --> Sa?da com erro
         -- Testar se houve erro
         IF vr_dscritic IS NOT NULL THEN
           -- Gerar excecao
           RAISE vr_exc_saida;
         END IF;

         /* Gerar arquivo damigração da 4-concredi para 1-viacredi e
            15-credimilsul para 13-SCRCRED somente no perido que as duas ctas estao ativas */
         IF pr_cdcooper in (1,13) AND
           (rw_crapdat.dtmvtolt >= to_date('11/18/2014','MM/DD/RRRR')   AND
            rw_crapdat.dtmvtolt <= to_date('11/30/2014','MM/DD/RRRR'))  THEN

           -- descarregar buffer
           gene0002.pc_escreve_xml(vr_clob_rej,vr_char_rej,'',TRUE);

           /*geração temporaria do arquivo devido a migração da concredi e credimilsul*/
           gene0002.pc_clob_para_arquivo(pr_clob    => vr_clob_rej,
                                         pr_caminho => gene0001.fn_diretorio(pr_tpdireto => 'M' --> Micros
                                                                            ,pr_cdcooper => 3 --> cecred
                                                                            ,pr_nmsubdir => 'lan444'),
                                         pr_arquivo => 'RegistrosRejeitadosMigracao_'||lpad(pr_cdcooper,2,'0')||'.lst',
                                         pr_des_erro=> vr_dscritic);

         END IF;

         /* Gerar arquivo da incorporacao da Transulcred para Transpocred
              somente no perido que as duas ctas estao ativas */
         IF pr_cdcooper = 9 AND
           (rw_crapdat.dtmvtolt >= to_date('12/12/2016','MM/DD/RRRR')   AND
            rw_crapdat.dtmvtolt <= to_date('12/31/2016','MM/DD/RRRR'))  THEN

           -- descarregar buffer
           gene0002.pc_escreve_xml(vr_clob_rej,vr_char_rej,'',TRUE);

           /*geração temporaria do arquivo devido a migração da transulcred */
           gene0002.pc_clob_para_arquivo(pr_clob    => vr_clob_rej,
                                         pr_caminho => gene0001.fn_diretorio(pr_tpdireto => 'M' --> Micros
                                                                            ,pr_cdcooper => 3 --> cecred
                                                                            ,pr_nmsubdir => 'lan444'),
                                         pr_arquivo => 'RegistrosRejeitadosMigracao_'||lpad(pr_cdcooper,2,'0')||'.lst',
                                         pr_des_erro=> vr_dscritic);

         END IF;

         -- Liberando a mem?ria alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);
         -- Liberando a mem?ria alocada pro CLOB
         dbms_lob.close(vr_clob_rej);
         dbms_lob.freetemporary(vr_clob_rej);

       END IF;

     EXCEPTION
       WHEN vr_exc_saida THEN
         raise vr_exc_saida;
       WHEN OTHERS THEN
         --Variavel de erro recebe erro ocorrido
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina pc_crps444.pc_imprime_rel_414_99. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END;

   ---------------------------------------
   -- Inicio Bloco Principal pc_crps444
   ---------------------------------------
   BEGIN

     --Limpar parametros saida
     pr_cdcritic:= NULL;
     pr_dscritic:= NULL;

     vr_tab_conta_blq.DELETE;


     --Atribuir o nome do programa que esta executando
     vr_cdprogra:= 'CRPS444';

     -- Incluir nome do modulo logado
     GENE0001.pc_informa_acesso(pr_module => 'pc_crps444'
                               ,pr_action => NULL);

     -- Verifica se a cooperativa esta cadastrada
     OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
     -- Se não encontrar
     IF cr_crapcop%NOTFOUND THEN
       -- Fechar o cursor pois havera raise
       CLOSE cr_crapcop;
       -- Montar mensagem de critica
       vr_cdcritic:= 651;
       vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       RAISE vr_exc_saida;
     ELSE
       -- Apenas fechar o cursor
       CLOSE cr_crapcop;
     END IF;

     /*  Nao roda para CECRED  */
     IF pr_cdcooper = 3 OR  rw_crapcop.cdagedbb = 0 THEN
       --Sair do programa
       RAISE vr_exc_fimprg;
     END IF;

     -- Verifica se a data esta cadastrada
     OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
     FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
     -- Se nÃ£o encontrar
     IF BTCH0001.cr_crapdat%NOTFOUND THEN
       -- Fechar o cursor pois haverÃ¡ raise
       CLOSE BTCH0001.cr_crapdat;
       -- Montar mensagem de critica
       vr_cdcritic:= 1;
       vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       RAISE vr_exc_saida;
     ELSE
       -- Apenas fechar o cursor
       CLOSE BTCH0001.cr_crapdat;
     END IF;

     --Determinar batch = false
     vr_flgbatch:= 0;

     -- Validacoes iniciais do programa
     BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => vr_flgbatch
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);

     --Se retornou critica aborta programa
     IF vr_cdcritic <> 0 THEN
       --Descricao do erro recebe mensagam da critica
       vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       -- Envio centralizado de log de erro
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
       --Sair do programa
       RAISE vr_exc_saida;
     END IF;

     --Zerar tabelas de memoria auxiliar
     pc_limpa_tabela;

     --Carregar tabela de memoria de Associados
     FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP

       vr_index_crapass:= lpad(rw_crapass.nrdconta,10,'0');
       vr_tab_nrdconta(vr_index_crapass).vr_rowid:= rw_crapass.rowid;
       vr_tab_nrdconta(vr_index_crapass).nrdctitg:= rw_crapass.nrdctitg;
       vr_tab_nrdconta(vr_index_crapass).nrdconta:= rw_crapass.nrdconta;
       vr_tab_nrdconta(vr_index_crapass).cdsitdtl:= rw_crapass.cdsitdtl;
       vr_tab_nrdconta(vr_index_crapass).dtelimin:= rw_crapass.dtelimin;

       IF trim(rw_crapass.nrdctitg) IS NOT NULL AND length(rw_crapass.nrdctitg) > 1 THEN
         vr_index_crapass:= lpad(rw_crapass.nrdctitg,10,'0');
         vr_tab_nrdctitg(vr_index_crapass).vr_rowid:= rw_crapass.rowid;
         vr_tab_nrdctitg(vr_index_crapass).nrdctitg:= rw_crapass.nrdctitg;
         vr_tab_nrdctitg(vr_index_crapass).nrdconta:= rw_crapass.nrdconta;
         vr_tab_nrdctitg(vr_index_crapass).cdsitdtl:= rw_crapass.cdsitdtl;
         vr_tab_nrdctitg(vr_index_crapass).dtelimin:= rw_crapass.dtelimin;
       END IF;
     END LOOP;

     --Carregar tabela memoria Historico
     FOR rw_craphis IN cr_craphis (pr_cdcooper => pr_cdcooper) LOOP
       vr_tab_craphis(rw_craphis.cdhistor):= rw_craphis.indebcre;
     END LOOP;

     /*  Le tabela com as codigo do convenio do Banco do Brasil com a Coop.  */
     vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'COMPEARQBB'
                                             ,pr_tpregist => 444);

     --Se nao encontrou
     IF trim(vr_dstextab) IS NULL THEN
       vr_cdcritic:= 55;
       vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       --Complementar mensagem
       vr_dscritic := vr_dscritic||' (COMPEARQBB)';
       --Levantar Excecao
       RAISE vr_exc_saida;
     ELSE
       --Codigo Convenio
       vr_cdconven:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,9));
     END IF;

     /* para a cooperativa viacredi, é necessario importar também os arquivos
        da cooperativa 4, incorporada */
     IF pr_cdcooper = 1 THEN
       /*  Le tabela com as codigo do convenio do Banco do Brasil com a Coop.  */
       vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => 4
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'COMPEARQBB'
                                               ,pr_tpregist => 444);

       --Se nao encontrou
       IF trim(vr_dstextab) IS NULL THEN
         vr_cdcritic:= 55;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Complementar mensagem
         vr_dscritic := vr_dscritic||' (COMPEARQBB)';
         --Levantar Excecao
         RAISE vr_exc_saida;
       ELSE
         --Codigo Convenio da concredi
         vr_cdconven_04:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,9));
       END IF;
     END IF;

     /* para a cooperativa SCRCRED, é necessario importar também os arquivos
        da cooperativa 15, incorporada */
     IF pr_cdcooper = 13 THEN
       /*  Le tabela com as codigo do convenio do Banco do Brasil com a Coop.  */
       vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => 15
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'COMPEARQBB'
                                               ,pr_tpregist => 444);

       --Se nao encontrou
       IF trim(vr_dstextab) IS NULL THEN
         vr_cdcritic:= 55;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Complementar mensagem
         vr_dscritic := vr_dscritic||' (COMPEARQBB)';
         --Levantar Excecao
         RAISE vr_exc_saida;
       ELSE
         --Codigo Convenio da credimilsul
         vr_cdconven_15:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,9));
       END IF;
     END IF;

     /* para a cooperativa TRANSPOCRED, é necessario importar também os arquivos
        da cooperativa 17, incorporada */
     IF pr_cdcooper = 9 THEN
       /*  Le tabela com as codigo do convenio do Banco do Brasil com a Coop.  */
       vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => 17
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'COMPEARQBB'
                                               ,pr_tpregist => 444);

       --Se nao encontrou
       IF trim(vr_dstextab) IS NULL THEN
         vr_cdcritic:= 55;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Complementar mensagem
         vr_dscritic := vr_dscritic||' (COMPEARQBB)';
         --Levantar Excecao
         RAISE vr_exc_saida;
       ELSE
         --Codigo Convenio da Transulcred
         vr_cdconven_17:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,9));
       END IF;
     END IF;

     --Carregar lancamentos
     FOR rw_craplcm_carga IN cr_craplcm_carga (pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                              ,pr_cdagenci => vr_cdagenci
                                              ,pr_cdbccxlt => vr_cdbccxlt) LOOP
       --Montar Indice
       vr_index_craplcm:= LPad(rw_craplcm_carga.nrdolote,10,'0')||
                          LPad(rw_craplcm_carga.nrdctabb,10,'0')||
                          LPad(rw_craplcm_carga.nrdocmto,10,'0');
       vr_tab_craplcm(vr_index_craplcm):= 0;
     END LOOP;

     --Se for Compensacao externa
     IF pr_nmtelant = 'COMPEFORA' THEN
       --Data leitura arquivo
       vr_dtleiarq:= rw_crapdat.dtmvtoan;
     ELSE
       --Data leitura arquivo
       vr_dtleiarq:= rw_crapdat.dtmvtolt;
     END IF;
     
     /* Tratamento e retorno de valores de restart */
     BTCH0001.pc_valida_restart(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_flgresta => pr_flgresta
                               ,pr_nrctares => vr_nrctares
                               ,pr_dsrestar => vr_dsrestar
                               ,pr_inrestar => vr_inrestar
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_des_erro => vr_dscritic);
     --Se ocrreu erro na validacao do restart
     IF vr_dscritic IS NOT NULL THEN
       --Levantar Excecao
       RAISE vr_exc_saida;
     ELSE
       IF vr_inrestar > 0 AND vr_nrctares = 0 THEN
         vr_inrestar:= 0;
       END IF;
     END IF;

     -- inicializar variavel de controle de arquivo
     vr_existe_arq := FALSE;

     /*  Concatena os arquivos DEB558 em um unico arquivo  */
     --Se nao for restart
     IF vr_inrestar = 0 THEN
       -- Buscar o diretorio padrao da cooperativa conectada
       vr_caminho_integra:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsubdir => 'integra');
       -- Comando para remover arquivos no diretorio integracao
        vr_comando:= 'rm '||vr_caminho_integra||'/deb558* 2> /dev/null';

       --Executar o comando no unix
       GENE0001.pc_OScommand(pr_typ_comando => 'S'
                            ,pr_des_comando => vr_comando
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_dscritic);
       --Se ocorreu erro dar RAISE
       IF vr_typ_saida = 'ERR' THEN
         vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
         RAISE vr_exc_saida;
       END IF;

       -- Buscar o diretÃ³rio padrao da cooperativa conectada
       vr_caminho_compbb:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_nmsubdir => 'compbb');
       --Nome filtro pesquisa
       vr_nomedarq:= 'deb558.bco%' ||to_char(vr_dtleiarq,'DDMMYY')||'%'||
                     gene0002.fn_mask(vr_cdconven,'999999999')||'%';

       --Listar arquivos
       gene0001.pc_lista_arquivos(pr_path     => vr_caminho_compbb
                                 ,pr_pesq     => vr_nomedarq
                                 ,pr_listarq  => vr_listadir
                                 ,pr_des_erro => vr_dscritic);
       -- Se houve erro
       IF vr_dscritic IS NOT NULL THEN
         -- Apenas enviar ao log
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || vr_dscritic );
         -- Limpar a critica
         vr_dscritic := null;
       END IF;

       --Carregar a lista de arquivos na temp table
       vr_tab_arquivo:= GENE0002.fn_quebra_string(pr_string => vr_listadir);

       --Nome arquivo destino (consolidado)
       vr_nomedarq:= 'deb558_444_'||to_char(vr_dtleiarq,'YYYYMMDD')||'.bb';

       --Se encontrou arquivos
       IF vr_tab_arquivo.Count > 0 THEN
         --Percorrer todos os arquivos encontrados para gerar um unico arquivo deb558_444.
         FOR idx IN vr_tab_arquivo.FIRST..vr_tab_arquivo.LAST LOOP
           --Verificar se o arquivo existe
           IF NOT GENE0001.fn_exis_arquivo(vr_caminho_compbb||'/'||vr_tab_arquivo(idx)) THEN
             vr_cdcritic:= 258;
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

             --Enviar Email
             pc_envia_email (pr_cdcooper => rw_crapcop.cdcooper
                            ,pr_nmrescop => rw_crapcop.nmrescop
                            ,pr_cdprogra => vr_cdprogra
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt);

             --Levantar Excecao
             RAISE vr_exc_fimprg;
           ELSE
             --Concatenar o conteudo do arquivo lido no arquivo de destino
             vr_comando:= 'cat '||vr_caminho_compbb||'/'||vr_tab_arquivo(idx)||' >> '||
                          vr_caminho_integra||'/'||vr_nomedarq||' 2> /dev/null';

             --Executar o comando no unix
             GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic);
             --Se ocorreu erro dar RAISE
             IF vr_typ_saida = 'ERR' THEN
               vr_dscritic:= 'Não foi possivel executar comando unix. '||vr_comando;
               RAISE vr_exc_saida;
             END IF;
           END IF;

           -- Comando para remover o arquivo movido do diretorio compbb
           vr_comando:= 'rm '||vr_caminho_compbb||'/'||vr_tab_arquivo(idx)||' 2> /dev/null';

           --Executar o comando no unix
           GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_dscritic);
           --Se ocorreu erro dar RAISE
           IF vr_typ_saida = 'ERR' THEN
             vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
             RAISE vr_exc_saida;
           END IF;
           -- marcar que encontrou arquivo a ser processado
           vr_existe_arq := TRUE;

         END LOOP;
       END IF; --vr_tab_arquivo.count

       -----------------------------------------------------------
       -------------- VERIFICAR ARQUIVO CONCREDI -----------------
       -----------------------------------------------------------
       IF pr_cdcooper = 1 THEN
         --Nome filtro pesquisa
         vr_nomedarq:= 'deb558.bco%' ||to_char(vr_dtleiarq,'DDMMYY')||'%'||
                       gene0002.fn_mask(vr_cdconven_04,'999999999')||'%';

         --Listar arquivos
         gene0001.pc_lista_arquivos(pr_path    => vr_caminho_compbb
                                   ,pr_pesq    => vr_nomedarq
                                   ,pr_listarq => vr_listadir
                                   ,pr_des_erro => vr_dscritic);
         -- Se houve erro
         IF vr_dscritic IS NOT NULL THEN
           -- Apenas enviar ao log
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic );
           -- Limpar a critica
           vr_dscritic := null;
         END IF;

         -- limpar temptable de arquivos
         vr_tab_arquivo.delete;

         --Carregar a lista de arquivos na temp table
         vr_tab_arquivo:= GENE0002.fn_quebra_string(pr_string => vr_listadir);

         --Nome arquivo destino (consolidado)
         vr_nomedarq:= 'deb558_444_'||to_char(vr_dtleiarq,'YYYYMMDD')||'_CONCREDI.bb';

         --Se encontrou arquivos
         IF vr_tab_arquivo.Count > 0 THEN
           --Percorrer todos os arquivos encontrados para gerar um unico arquivo deb558_444
           -- para a concredi.
           FOR idx IN vr_tab_arquivo.FIRST..vr_tab_arquivo.LAST LOOP
             --Verificar se o arquivo existe
             IF GENE0001.fn_exis_arquivo(vr_caminho_compbb||'/'||vr_tab_arquivo(idx)) THEN
               --Concatenar o conteudo do arquivo lido no arquivo de destino
               vr_comando:= 'cat '||vr_caminho_compbb||'/'||vr_tab_arquivo(idx)||' >> '||
                            vr_caminho_integra||'/'||vr_nomedarq||' 2> /dev/null';

               --Executar o comando no unix
               GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                    ,pr_des_comando => vr_comando
                                    ,pr_typ_saida   => vr_typ_saida
                                    ,pr_des_saida   => vr_dscritic);
               --Se ocorreu erro dar RAISE
               IF vr_typ_saida = 'ERR' THEN
                 vr_dscritic:= 'Não foi possivel executar comando unix. '||vr_comando;
                 RAISE vr_exc_saida;
               END IF;
             END IF;

             -- Comando para remover o arquivo movido do diretorio compbb
             vr_comando:= 'rm '||vr_caminho_compbb||'/'||vr_tab_arquivo(idx)||' 2> /dev/null';

             --Executar o comando no unix
             GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic);
             --Se ocorreu erro dar RAISE
             IF vr_typ_saida = 'ERR' THEN
               vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
               RAISE vr_exc_saida;
             END IF;
           -- encontrou arquivo
           vr_existe_arq := TRUE;
           END LOOP;
         END IF; --vr_tab_arquivo.count
       END IF; --  fim verificação arquivos concredi


       -----------------------------------------------------------
       ------------- VERIFICAR ARQUIVO CREDIMILSUL ---------------
       -----------------------------------------------------------
       IF pr_cdcooper = 13 THEN
         --Nome filtro pesquisa
         vr_nomedarq:= 'deb558.bco%' ||to_char(vr_dtleiarq,'DDMMYY')||'%'||
                       gene0002.fn_mask(vr_cdconven_15,'999999999')||'%';

         --Listar arquivos
         gene0001.pc_lista_arquivos(pr_path    => vr_caminho_compbb
                                   ,pr_pesq    => vr_nomedarq
                                   ,pr_listarq => vr_listadir
                                   ,pr_des_erro => vr_dscritic);
         -- Se houve erro
         IF vr_dscritic IS NOT NULL THEN
           -- Apenas enviar ao log
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic );
           -- Limpar a critica
           vr_dscritic := null;
         END IF;

         -- limpar temptable de arquivos
         vr_tab_arquivo.delete;

         --Carregar a lista de arquivos na temp table
         vr_tab_arquivo:= GENE0002.fn_quebra_string(pr_string => vr_listadir);

         --Nome arquivo destino (consolidado)
         vr_nomedarq:= 'deb558_444_'||to_char(vr_dtleiarq,'YYYYMMDD')||'_CREDIMILSUL.bb';

         --Se encontrou arquivos
         IF vr_tab_arquivo.Count > 0 THEN
           --Percorrer todos os arquivos encontrados para gerar um unico arquivo deb558_444
           -- para a concredi.
           FOR idx IN vr_tab_arquivo.FIRST..vr_tab_arquivo.LAST LOOP
             --Verificar se o arquivo existe
             IF GENE0001.fn_exis_arquivo(vr_caminho_compbb||'/'||vr_tab_arquivo(idx)) THEN
               --Concatenar o conteudo do arquivo lido no arquivo de destino
               vr_comando:= 'cat '||vr_caminho_compbb||'/'||vr_tab_arquivo(idx)||' >> '||
                            vr_caminho_integra||'/'||vr_nomedarq||' 2> /dev/null';

               --Executar o comando no unix
               GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                    ,pr_des_comando => vr_comando
                                    ,pr_typ_saida   => vr_typ_saida
                                    ,pr_des_saida   => vr_dscritic);
               --Se ocorreu erro dar RAISE
               IF vr_typ_saida = 'ERR' THEN
                 vr_dscritic:= 'Não foi possivel executar comando unix. '||vr_comando;
                 RAISE vr_exc_saida;
               END IF;
             END IF;

             -- Comando para remover o arquivo movido do diretorio compbb
             vr_comando:= 'rm '||vr_caminho_compbb||'/'||vr_tab_arquivo(idx)||' 2> /dev/null';

             --Executar o comando no unix
             GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic);
             --Se ocorreu erro dar RAISE
             IF vr_typ_saida = 'ERR' THEN
               vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
               RAISE vr_exc_saida;
             END IF;

             -- encontrou arquivo
             vr_existe_arq := TRUE;
           END LOOP;
         END IF; --vr_tab_arquivo.count
       END IF; --  fim verificação arquivos credimilsul

       
       -----------------------------------------------------------
       ------------- VERIFICAR ARQUIVO TRANSULCRED ---------------
       -----------------------------------------------------------
       IF pr_cdcooper = 9 THEN
         --Nome filtro pesquisa
         vr_nomedarq:= 'deb558.bco%' ||to_char(vr_dtleiarq,'DDMMYY')||'%'||
                       gene0002.fn_mask(vr_cdconven_17,'999999999')||'%';

         --Listar arquivos
         gene0001.pc_lista_arquivos(pr_path    => vr_caminho_compbb
                                   ,pr_pesq    => vr_nomedarq
                                   ,pr_listarq => vr_listadir
                                   ,pr_des_erro => vr_dscritic);
         -- Se houve erro
         IF vr_dscritic IS NOT NULL THEN
           -- Apenas enviar ao log
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic );
           -- Limpar a critica
           vr_dscritic := null;
         END IF;

         -- limpar temptable de arquivos
         vr_tab_arquivo.delete;

         --Carregar a lista de arquivos na temp table
         vr_tab_arquivo:= GENE0002.fn_quebra_string(pr_string => vr_listadir);

         --Nome arquivo destino (consolidado)
         vr_nomedarq:= 'deb558_444_'||to_char(vr_dtleiarq,'YYYYMMDD')||'_TRANSULCRED.bb';

         --Se encontrou arquivos
         IF vr_tab_arquivo.Count > 0 THEN
           --Percorrer todos os arquivos encontrados para gerar um unico arquivo deb558_444
           -- para a transulcred.
           FOR idx IN vr_tab_arquivo.FIRST..vr_tab_arquivo.LAST LOOP
             --Verificar se o arquivo existe
             IF GENE0001.fn_exis_arquivo(vr_caminho_compbb||'/'||vr_tab_arquivo(idx)) THEN
               --Concatenar o conteudo do arquivo lido no arquivo de destino
               vr_comando:= 'cat '||vr_caminho_compbb||'/'||vr_tab_arquivo(idx)||' >> '||
                            vr_caminho_integra||'/'||vr_nomedarq||' 2> /dev/null';

               --Executar o comando no unix
               GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                    ,pr_des_comando => vr_comando
                                    ,pr_typ_saida   => vr_typ_saida
                                    ,pr_des_saida   => vr_dscritic);
               --Se ocorreu erro dar RAISE
               IF vr_typ_saida = 'ERR' THEN
                 vr_dscritic:= 'Não foi possivel executar comando unix. '||vr_comando;
                 RAISE vr_exc_saida;
               END IF;
             END IF;

             -- Comando para remover o arquivo movido do diretorio compbb
             vr_comando:= 'rm '||vr_caminho_compbb||'/'||vr_tab_arquivo(idx)||' 2> /dev/null';

             --Executar o comando no unix
             GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic);
             --Se ocorreu erro dar RAISE
             IF vr_typ_saida = 'ERR' THEN
               vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
               RAISE vr_exc_saida;
             END IF;

             -- encontrou arquivo
             vr_existe_arq := TRUE;
           END LOOP;
         END IF; --vr_tab_arquivo.count
       END IF; --  fim verificação arquivos transulcred

       -- Senão encontrou nenhum arquivo, deve abortar programa
       IF NOT vr_existe_arq THEN
         vr_cdcritic:= 258;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

         --Enviar Email
         pc_envia_email (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_nmrescop => rw_crapcop.nmrescop
                        ,pr_cdprogra => vr_cdprogra
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt);

         --Levantar Excecao
         RAISE vr_exc_fimprg;
       END IF;

     END IF; --vr_inrestar = 0

     /*  Le tabela para processar arquivos de deposito  */
     vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'COMPECHQBB'
                                             ,pr_tpregist => 0);

     /*  Le tabela para processar arquivos de deposito  */
     vr_dstextab:= NULL;
     vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'MAIORESCHQ'
                                             ,pr_tpregist => 1);
     --Se nao encontrou parametro
     IF trim(vr_dstextab) IS NULL THEN
       --Valor limite saldo negativo
       vr_vlmaichq:= 1;
     ELSE
       --Valor limite saldo negativo
       vr_vlmaichq:= gene0002.fn_char_para_number(substr(vr_dstextab,01,15));
     END IF;

     /*  Le tabela com as contas convenio do Banco do Brasil - CTA. ITG. ....... */
     vr_lsconta4:= gene0005.fn_busca_conta_centralizadora(pr_cdcooper => pr_cdcooper
                                                         ,pr_tpregist => 4);

     --Se a conta nao estiver nula
     IF trim(vr_lsconta4) IS NOT NULL THEN
       vr_rel_nrdctabb:= to_number(fn_ultctaconve(vr_lsconta4));
     END IF;

     /*   Verificar o valor VLB */
     vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'VALORESVLB'
                                             ,pr_tpregist => 0);
     --Se encontrou parametro
     IF trim(vr_dstextab) IS NOT NULL THEN
       --Valor cheque VLB
       vr_vlchqvlb:= gene0002.fn_char_para_number(
                        gene0002.fn_busca_entrada(2,vr_dstextab,';'));
     ELSE
       vr_vlchqvlb:= 0;
     END IF;

     /* .......................................................................... */
     --Historico Cheques
     vr_dshstchq:= '0002,0033,0102,0103,0113,0300,0452,0455,0456,0457,0458';
     --Historico Bloqueio
     vr_dshstblq:= '0511,0512,0513,0514,0515,0516,0517,0518,0519,0520,'||
                    '0911,0912,0913,0914,0915,0916,0917,0918,0919,0920';
     --Historicos Deposito
     vr_dshstdep:= '0502,0505,0510,0604,0615,0612,0623,0626,0632,0648,'||
                    '0656,0688,0677,0699,0707,0710,0732,0734,0756,0772,'||
                    '0781,0783,0787,0789,0805,0808,0810,0829,0830,0886,'||
                    '0870,0874,0875,0900,0901,0910,0957,0975,0976,0977,'||
                    '0978,'|| vr_dshstblq;
     --Historico Estorno Bloqueio
     vr_dsestblq:= '0411,0412,0413,0414,0415,0416,0417,0418,0419,0420';
     --Historico Estorno
     vr_dshstest:= '0080,0280,0780,0807,0828,'|| vr_dsestblq;

     /*  CUIDADO - os hist. de aux_dshsttrf NAO podera ser utilizado para
                   outras tipos de lancamento  */

     --Historico Transferencia
     vr_dshsttrf:= '0144,0229,0729';
     --Historico Debito
     vr_dshstdeb:= '0031,0109,0112,0118,0131,0133,0140,0143,0156,0157,'||
                   '0158,0159,0162,0168,0176,0177,0190,0195,0196,0204,'||
                   '0233,0234,0171,0240,0243,0302,0303,0328,0331,0343,'||
                   '0361,0362,0363,0365,0367,0368,0373,0374,0375,0376,'||
                   '0377,0378,0372,0380,0404,0436,0454,0465,0470,0474,1248';

     /*  Este Utilizado Somente para o Relatorio (Nao Cria Lanctos) */

     --Historico devolucao
     vr_dshstdev:= '0603,0686,0705,0718';
     vr_regexist:= FALSE;
     vr_flgfinal:= FALSE;
     vr_cdcritic:= 0;

     /*  Carrega para uma tabela os arquivos a serem integrados  */
     --Listar arquivos
     gene0001.pc_lista_arquivos(pr_path    => vr_caminho_integra
                               ,pr_pesq    => 'deb558_444%'
                               ,pr_listarq => vr_listadir
                               ,pr_des_erro => vr_dscritic);
     -- Se houve erro
     IF vr_dscritic IS NOT NULL THEN
       -- Apenas enviar ao log
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '
                                                  || vr_dscritic );
       -- Limpar a critica
       vr_dscritic := null;
     END IF;

     --Limpar tabela arquivos
     vr_tab_arquivo.DELETE;
     --Carregar a lista de arquivos na temp table
     vr_tab_arquivo:= GENE0002.fn_quebra_string(pr_string => vr_listadir);

     --Se encontrou arquivos
     IF vr_tab_arquivo.Count > 0 THEN
       --Percorrer cada arquivo encontrado
       FOR vr_index_arq IN vr_tab_arquivo.FIRST..vr_tab_arquivo.LAST LOOP

         -- Comando para listar a ultima linha do arquivo
         vr_comando:= 'tail -1 '||vr_caminho_integra||'/'||vr_tab_arquivo(vr_index_arq);

         --Executar o comando no unix
         GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_setlinha);
         --Se ocorreu erro dar RAISE
         IF vr_typ_saida = 'ERR' THEN
           vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
           RAISE vr_exc_saida;
         END IF;

         --Se for linha controle
         IF SUBSTR(vr_setlinha,1,1) != '9' THEN
           vr_cdcritic:= 468;
         END IF;

         --Se ocorreu erro
         IF vr_cdcritic = 0 THEN

           -- Comando para listar a primeira linha do arquivo
           vr_comando:= 'head -1 ' ||vr_caminho_integra||'/'||vr_tab_arquivo(vr_index_arq);

           --Executar o comando no unix
           GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_setlinha);
           --Se ocorreu erro dar RAISE
           IF vr_typ_saida = 'ERR' THEN
             vr_dscritic:= 'Não foi possivel executar comando unix. '||vr_comando;
             RAISE vr_exc_saida;
           END IF;

           --Se for linha controle
           IF SUBSTR(vr_setlinha,1,1) != '0' THEN
             vr_cdcritic:= 181;
           ELSE
             IF SUBSTR(vr_setlinha,95,2) != TO_CHAR(vr_dtleiarq,'DD') OR
                SUBSTR(vr_setlinha,97,2) != TO_CHAR(vr_dtleiarq,'MM') THEN
               vr_cdcritic:= 789;
             END IF;
           END IF;
         END IF;
         IF vr_cdcritic <> 0 THEN
           EXIT;
         END IF;
         --Registro Existe
         vr_regexist:= TRUE;
         vr_tab_nmarqint(vr_tab_nmarqint.count+1):= vr_tab_arquivo(vr_index_arq);
       END LOOP;
     END IF; --vr_tab_arquivo.count

     --Se nao existem arquivos para processar
     IF NOT vr_regexist THEN
       --Erro 258
       IF vr_cdcritic = 258  THEN
         --Enviar Email
         pc_envia_email (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_nmrescop => rw_crapcop.nmrescop
                        ,pr_cdprogra => vr_cdprogra
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
       END IF;
       --Sair sem abortar cadeia
       RAISE vr_exc_fimprg;
     END IF;

     --Buscar diretorio RL
     vr_caminho_rl:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'rl');

     /*  Arquivos a integrar  */
     FOR vr_contaarq IN 1..9 LOOP

       --Verificar se o arquivo fisico existe
       IF NOT vr_tab_nmarqint.EXISTS(vr_contaarq) OR vr_tab_nmarqint(vr_contaarq) IS NULL THEN
         --Proximo Registro
         CONTINUE;
       END IF;

       --Inicializar variaveis
       vr_cdcritic        := 0;
       vr_nrdolote        := 0;
       vr_lot_qtcompln    := 0;
       vr_lot_vlcompdb    := 0;
       vr_rowid_debito    := NULL;
       vr_rowid_credito   := NULL;
       vr_rowid_debito_9  := NULL;
       vr_rowid_credito_9 := NULL;

       vr_dstextab_debito   := NULL;
       vr_dstextab_credito  := NULL;
       vr_dstextab_debito_9 := NULL;
       vr_dstextab_credito_9:= NULL;

       vr_flgarqvz:= TRUE;
       vr_flgfirst:= TRUE;
       vr_flgentra:= TRUE;
       vr_flgretor:= FALSE;
       --Determinar nome arquivo
       vr_nmarqrel:= 'crrl414_'||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')||'.lst';
       vr_tab_nmarqimp(vr_contaarq):= 'crrl414_'||gene0002.fn_mask(vr_contaarq,'99');

       /*  Verifica se o arquivo a ser integrado existe em disco  */
       IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_caminho_integra||'/'||vr_tab_nmarqint(vr_contaarq)) THEN
         vr_cdcritic:= 182;
         vr_dscritic:=  gene0001.fn_busca_critica(vr_cdcritic);
         RAISE vr_exc_saida;
       END IF;

       --Se nao for restart
       IF vr_inrestar = 0 THEN
         --Eliminar registro craptab
         BEGIN
           DELETE craptab
           WHERE craptab.cdcooper = pr_cdcooper
           AND   craptab.nmsistem = 'CRED'
           AND   craptab.tptabela = 'COMPBB'
           AND   craptab.cdempres = 0;
         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic:= 0;
             vr_dscritic:= 'Erro ao excluir na craptab. '||sqlerrm;
             --Levantar Excecao
             RAISE vr_exc_saida;
         END;

         --Limpar tabela temporaria crawdpb
         vr_tab_crawdpb.DELETE;
         --Escreve no Log
         vr_cdcritic:= 219;
         vr_dscritic:=  gene0001.fn_busca_critica(vr_cdcritic);
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic || ' --> '
                                                     || vr_tab_nmarqint(vr_contaarq));
       END IF; --vr_inrestar = 0

       --Abrir o arquivo de dados
       gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho_integra  --> DiretÃ³rio do arquivo
                               ,pr_nmarquiv => vr_tab_nmarqint(vr_contaarq) --> Nome do arquivo
                               ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                               ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                               ,pr_des_erro => vr_dscritic);  --> Erro
       IF vr_dscritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;

       --Percorrer todas as linhas do arquivo
       LOOP
         --Conta Integrada
         vr_flgctitg:= FALSE;
         vr_flgtecsa:= FALSE;

         IF vr_inrestar <> 0 THEN
           --Enquanto o sequencial diferente conta resrtart
           WHILE vr_nrseqint <> vr_nrctares LOOP
             --Se for para retornar
             IF vr_flgretor THEN
               EXIT;
             END IF;
             -- Le os dados do arquivo e coloca na variavel vr_setlinha
             gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_setlinha); --> Texto lido
             --Sequencial integracao
             vr_nrseqint:= TO_NUMBER(SUBSTR(vr_setlinha,195,6));

             IF SUBSTR(vr_setlinha,1,1) = '1' THEN
                IF SUBSTR(vr_setlinha,33,9) = gene0002.fn_mask(vr_rel_nrdctabb,'999999999') THEN
                  --Proximo registro
                  CONTINUE;
                END IF;
                --Numero Conta BB
                vr_nrdctabb:= fn_ver_contaitg(SUBSTR(vr_setlinha,33,09));
                --Verificar se eh conta integracao, se nao for pula o registro
                IF NOT vr_tab_nrdctitg.EXISTS(lpad(SUBSTR(vr_setlinha,34,08),10,'0')) THEN
                  --Pular registro
                  CONTINUE;
                ELSE
                  vr_nrdctabb:= fn_ver_contaitg(SUBSTR(vr_setlinha,34,08));
                END IF;
             ELSE
               --Final arquivo
               vr_flgfinal:= SUBSTR(vr_setlinha,1,1) = '9';
             END IF;
           END LOOP; --WHILE
           --Retorno
           vr_flgretor:= TRUE;
           --Escrever no log
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || 'Posicionando-se no registro '
                                                       || gene0002.fn_mask_conta(vr_nrctares)||'.');
         END IF; --vr_inrestar <> 0

         -- Le os dados do arquivo e coloca na variavel vr_setlinha
         BEGIN
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido
         EXCEPTION
           WHEN no_data_found THEN
             --Chegou ao final arquivo, sair do loop
             EXIT;
         END;
         --Se for inicio ou fim arquivo
         IF SUBSTR(vr_setlinha,1,1) <> '1' THEN
           --Se for a ultima linha do arquivo
           IF SUBSTR(vr_setlinha,1,1) = '9' THEN
             --Final
             vr_flgfinal:= TRUE;
           END IF;
           --Proximo registro
           CONTINUE;
         END IF;

         vr_fcraptco_itg := FALSE;
         vr_nrdctitg_arq := SUBSTR(vr_setlinha,34,8);

         -- se for processo da scrcred e o
         -- arquivo importado for da  credimilsul
         IF pr_cdcooper = 13 AND
            vr_tab_nmarqint(vr_contaarq) like '%_CREDIMILSUL%' THEN

           vr_nrdctitg_arq := SUBSTR(vr_setlinha,34,8);

           -- Verificar se é uma conta migrada
           OPEN cr_craptco_itg (pr_cdcooper => pr_cdcooper
                               ,pr_nrdctitg => vr_nrdctitg_arq
                               ,pr_cdcopant => 15);
           FETCH cr_craptco_itg INTO rw_craptco_itg;

           -- se encontrar é necessario buscar a nova conta itg da conta
           -- na nova cooperativa
           IF cr_craptco_itg%FOUND THEN
             vr_fcraptco_itg := TRUE;
             IF vr_tab_nrdconta.exists(lpad(rw_craptco_itg.nrdconta,10,'0')) THEN
               vr_nrdctitg_arq := vr_tab_nrdconta(lpad(rw_craptco_itg.nrdconta,10,'0')).nrdctitg;
             END IF;
           END IF;
           CLOSE cr_craptco_itg;
         END IF;

         
         -- se for processo da transpocred e o
         -- arquivo importado for da transulcred
         IF pr_cdcooper = 9 AND
            vr_tab_nmarqint(vr_contaarq) like '%_TRANSULCRED%' THEN

           vr_nrdctitg_arq := SUBSTR(vr_setlinha,34,8);

           -- Verificar se é uma conta migrada
           OPEN cr_craptco_itg (pr_cdcooper => pr_cdcooper
                               ,pr_nrdctitg => vr_nrdctitg_arq
                               ,pr_cdcopant => 17);
           FETCH cr_craptco_itg INTO rw_craptco_itg;

           -- se encontrar é necessario buscar a nova conta itg da conta
           -- na nova cooperativa
           IF cr_craptco_itg%FOUND THEN
             vr_fcraptco_itg := TRUE;
             IF vr_tab_nrdconta.exists(lpad(rw_craptco_itg.nrdconta,10,'0')) THEN
               vr_nrdctitg_arq := vr_tab_nrdconta(lpad(rw_craptco_itg.nrdconta,10,'0')).nrdctitg;
             END IF;
           END IF;
           CLOSE cr_craptco_itg;
         END IF;

         /*  Conta da CECRED cancelada que ainda vem no arquivo  */
         IF SUBSTR(vr_setlinha,33,9) = gene0002.fn_mask(vr_rel_nrdctabb,'999999999') THEN
           --Se for cooperativa Concredi
           IF pr_cdcooper = 4 THEN
             /* Buscar Saldo Bloq. Indeterminado somente Concredi */
             pc_saldos_indet_concredi (pr_dsdlinha => vr_setlinha
                                      ,pr_nrdctabb => vr_rel_nrdctabb);
           END IF;
           IF SUBSTR(vr_setlinha,42,1) <> '1' THEN
             --Proximo registro
             CONTINUE;
           END IF;

           vr_nrdctabb:= TO_NUMBER(SUBSTR(vr_setlinha,33,09));
           vr_nrseqint:= TO_NUMBER(SUBSTR(vr_setlinha,195,06));
           vr_dshistor:= TRIM(SUBSTR(vr_setlinha,46,29));           
           vr_nrdocmto:= TO_NUMBER(SUBSTR(vr_setlinha,75,06));
           vr_vllanmto:= TO_NUMBER(SUBSTR(vr_setlinha,87,18)) / 100;
           vr_dtmvtolt:= TO_DATE(SUBSTR(vr_setlinha,184,2)||
                                 SUBSTR(vr_setlinha,182,2)||
                                 SUBSTR(vr_setlinha,186,4),'MMDDYYYY');
           IF TO_NUMBER(SUBSTR(vr_setlinha,43,3)) > 100 AND
              TO_NUMBER(SUBSTR(vr_setlinha,43,3)) < 200 THEN
             vr_indebcre:= 'D';
           ELSE
             vr_indebcre:= 'C';
           END IF;
           vr_cdpesqbb:= SUBSTR(vr_setlinha,111,5) || '-000-' ||SUBSTR(vr_setlinha,120,3);
           vr_dsageori:= SUBSTR(vr_setlinha,116,4) || '.00';
           vr_dtrefere:= NULL;
           IF TO_NUMBER(SUBSTR(vr_setlinha,174,8)) > 0 THEN
             vr_dtrefere:= TO_CHAR(TO_DATE(SUBSTR(vr_setlinha,176,2)||
                                   SUBSTR(vr_setlinha,174,2)||
                                   SUBSTR(vr_setlinha,178,4),'MMDDYYYY'),'DD.MM.YYYY');
           END IF;
           vr_flgarqvz:= FALSE;
           IF vr_nrdocmto <> 205048 THEN
             IF INSTR(vr_dshsttrf,SUBSTR(vr_dshistor,01,04)) > 0 THEN
               IF SUBSTR(vr_setlinha,123,1) <> '*' AND
                  vr_dshistor NOT IN ('0144TRANSF AGENDADA',
                                      '0144TRANSFERENCIA',
                                      '0729TRANSF RECEBIDA',
                                      '0144TRANSF PERIODIC') THEN
                   CONTINUE;
               END IF;
             END IF;
           END IF;
         ELSE
           vr_nrdctabb:= fn_ver_contaitg(SUBSTR(vr_setlinha,33,09));
           --Verificar se é conta integracao
           IF NOT vr_tab_nrdctitg.EXISTS(lpad(vr_nrdctitg_arq,10,'0')) THEN
             --Pular registro
             CONTINUE;
           ELSE
             vr_nrdctabb:= fn_ver_contaitg(vr_nrdctitg_arq);
           END IF;
           --Arquivo Vazio
           vr_flgarqvz:= FALSE;

           -- se for processo da viacredi e o arquivo importado for da concredi
           -- Não deve atualizar o saldo, do contrario atualizará
           IF NOT (pr_cdcooper = 1 AND
                   vr_tab_nmarqint(vr_contaarq) like '%_CONCREDI%') THEN
             --Atualizar Saldos
             pc_atualiza_saldos (pr_dsdlinha => vr_setlinha
                                ,pr_nrdctabb => vr_rel_nrdctabb);
           END IF;

           --Se nao for registro final
           IF SUBSTR(vr_setlinha, 42, 1) <> '1' THEN
             --Pular
             CONTINUE;
           END IF;
           --Numero Sequencia Interna
           vr_nrseqint:= TO_NUMBER(SUBSTR(vr_setlinha,195,06));
           vr_dshistor:= TRIM(SUBSTR(vr_setlinha,46,29));
           vr_nrdocmto:= TO_NUMBER(SUBSTR(vr_setlinha,75,06));
           vr_vllanmto:= TO_NUMBER(SUBSTR(vr_setlinha,87,18)) / 100;
           vr_dtmvtolt:= TO_DATE(SUBSTR(vr_setlinha,184,2)||
                                 SUBSTR(vr_setlinha,182,2)||
                                 SUBSTR(vr_setlinha,186,4),'MMDDYYYY');
           IF TO_NUMBER(SUBSTR(vr_setlinha,43,3)) > 100 AND
              TO_NUMBER(SUBSTR(vr_setlinha,43,3)) < 200 THEN
             vr_indebcre:= 'D';
           ELSE
             vr_indebcre:= 'C';
           END IF;

           vr_cdpesqbb:= SUBSTR(vr_setlinha,111,5) || '-000-' ||SUBSTR(vr_setlinha,120,3);
           vr_dsageori:= SUBSTR(vr_setlinha,116,4) || '.00';
           vr_dtrefere:= NULL;
           IF TO_NUMBER(SUBSTR(vr_setlinha,174,8)) > 0 THEN
             vr_dtrefere:= TO_CHAR(TO_DATE(SUBSTR(vr_setlinha,176,2)||
                                   SUBSTR(vr_setlinha,174,2)||
                                   SUBSTR(vr_setlinha,178,4),'MMDDYYYY'),'DD.MM.YYYY');
           ELSE
             vr_dtrefere:= NULL;
           END IF;
           /* Trf. Centralizado */
           IF INSTR(vr_dshsttrf,SUBSTR(vr_dshistor,01,04)) > 0 THEN
             IF vr_dshistor <> '0144TRF SEM CPMF'    AND
               vr_dshistor <> '0144TRANSF AGENDADA' AND
               vr_dshistor <> '0144TRANSFERENCIA'   AND
               vr_dshistor <> '0729TRANSF RECEBIDA'   AND
               vr_dshistor <> '0144TRANSF PERIODIC' THEN

                /* B.Brasil modificou historico TEC SALARIO*/
               IF vr_dshistor = '0729TRANSF.CTA.CENT' AND SUBSTR(vr_nrdctabb, 1, length(vr_nrdocmto)) = vr_nrdocmto THEN
                  vr_flgtecsa := TRUE;
               ELSE
                  --Proximo Registro
                  CONTINUE;
               END IF;
             END IF;
           END IF;

           --Verificar se o associado existe
           IF vr_tab_nrdctitg.EXISTS(lpad(vr_nrdctitg_arq,10,'0')) THEN
             BEGIN
               UPDATE crapass SET crapass.dtmvcitg = vr_dtleiarq
               WHERE crapass.ROWID = vr_tab_nrdctitg(lpad(vr_nrdctitg_arq,10,'0')).vr_rowid;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao atualizar tabela crapass. '||sqlerrm;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
             END;
           END IF;
         END IF;

         --Se for primeiro registro
         IF vr_flgfirst THEN
           /*  Le numero de lote a ser usado na integracao  */
           OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                           ,pr_nmsistem => 'CRED'
                           ,pr_tptabela => 'GENERI'
                           ,pr_cdempres => 0
                           ,pr_cdacesso => 'NUMLOTECBB'
                           ,pr_tpregist => 1);
           --Posicionar no primeiro registro
           FETCH cr_craptab INTO rw_craptab;
           --Se nao encontrou
           IF cr_craptab%NOTFOUND THEN
             --Fechar Cursor
             CLOSE cr_craptab;
             vr_cdcritic:= 259;
             vr_dscritic:=  gene0001.fn_busca_critica(vr_cdcritic);
             --Levantar Excecao
             RAISE vr_exc_saida;
           ELSE
             --Numero do lote recebe valor encontrado
             vr_nrdolote:= GENE0002.fn_char_para_number(rw_craptab.dstextab);
             --Guardar rowid da craptab para update
             vr_rowid_lote:= rw_craptab.rowid;
           END IF;
           --Fechar Cursor
           CLOSE cr_craptab;
           --Indicador restart = false
           IF vr_inrestar = 0 THEN
             --Flag criar lote
             vr_flgclote:= TRUE;
           END IF;
           --Flag primeiro recebe false
           vr_flgfirst:= FALSE;
         END IF;
         --Inicializar Variaveis
         vr_cdcritic:= 0;
         vr_nrdconta:= 0;
         vr_indevchq:= 0;
         vr_dsidenti:= NULL;

         /*   Outros Historicos Lancados na conta Centralizadora  */
         IF vr_nrdctabb = vr_rel_nrdctabb AND
            INSTR(vr_dshsttrf,SUBSTR(vr_dshistor,01,04)) = 0 AND
            vr_dshistor NOT IN ('0144TRANSF AGENDADA','0144TRANSFERENCIA','0729TRANSF RECEBIDA','0144TRANSF PERIODIC') THEN
           vr_cdcritic:= 245;
         ELSIF INSTR(vr_dshstdep,SUBSTR(vr_dshistor,01,04)) > 0 THEN /* Deposito */
           vr_flgdepos:= TRUE;
           vr_flgchequ:= FALSE;
           vr_flgestor:= FALSE;
           vr_flgdebit:= FALSE;
           vr_flgdevol:= FALSE;
         ELSIF INSTR(vr_dshstchq,SUBSTR(vr_dshistor,01,04)) > 0 THEN /* Cheque */
           vr_flgdepos:= FALSE;
           vr_flgchequ:= TRUE;
           vr_flgestor:= FALSE;
           vr_flgdebit:= FALSE;
           vr_flgdevol:= FALSE;
         ELSIF INSTR(vr_dshstest,SUBSTR(vr_dshistor,01,04)) > 0 THEN /* Estorno */
           vr_flgdepos:= FALSE;
           vr_flgchequ:= FALSE;
           vr_flgestor:= TRUE;
           vr_flgdebit:= FALSE;
           vr_flgdevol:= FALSE;
         ELSIF INSTR(vr_dshstdeb,SUBSTR(vr_dshistor,01,04)) > 0 THEN /* Debitos */
           vr_flgdepos:= FALSE;
           vr_flgchequ:= FALSE;
           vr_flgestor:= FALSE;
           vr_flgdebit:= TRUE;
           vr_flgdevol:= FALSE;
         ELSIF SUBSTR(vr_dshistor,01,04) = '0114' THEN /* Devolucoes recebidas 0114*/  
           vr_flgdepos:= FALSE;
           vr_flgchequ:= FALSE;
           vr_flgestor:= FALSE;
           vr_flgdebit:= FALSE;
           vr_flgdevol:= TRUE;             
         ELSE  /* Outros */
           vr_flgdepos:= FALSE;
           vr_flgchequ:= FALSE;
           vr_flgestor:= FALSE;
           vr_flgdebit:= FALSE;
           vr_flgdevol:= FALSE;
           vr_cdcritic:= 245;
         END IF;
         
         --Se nao ocorreu erro
         IF vr_cdcritic = 0 THEN
           --Se o numero documento esta vazio
           IF vr_nrdocmto = 0 THEN
             vr_cdcritic:= 22;
           ELSE
             --Se for deposito ou estorno
             IF vr_flgdepos OR vr_flgestor THEN
               --Numero da conta
               vr_nrdconta:= vr_nrdctabb;
             ELSE
               --Valor lancamento zerado
               IF vr_vllanmto = 0 THEN
                 vr_cdcritic:= 91;
               END IF;
             END IF;
           END IF;
         END IF;

         -- se for processo da viacredi e o
         -- arquivo importado for ca concredi
         IF pr_cdcooper = 1 AND
            vr_tab_nmarqint(vr_contaarq) like '%_CONCREDI%' THEN
           -- verificar se é uma conta migrada da coop 4
           --Localizar se é uma conta migrada pela conta itg
           OPEN cr_craptco_itg (pr_cdcooper => pr_cdcooper
                               ,pr_nrdctitg => vr_tab_nrdctitg(lpad(vr_nrdctitg_arq,10,'0')).nrdctitg
                               ,pr_cdcopant => 4);
           FETCH cr_craptco_itg INTO rw_craptco_itg;

           -- Se encontrou deve gerar critica
           IF cr_craptco_itg%FOUND THEN
             CLOSE cr_craptco_itg;

             BEGIN
               --Montar data aviso
               IF vr_dtrefere IS NOT NULL THEN
                 --Recebe data referencia
                 vr_dtdaviso:= to_date(SUBSTR(vr_dtrefere,1,10),'DD/MM/YYYY');
               ELSE
                 --Recebe data movimento
                 vr_dtdaviso:= rw_crapdat.dtmvtolt;
               END IF;

               INSERT INTO CRAPREJ
                           ( craprej.dtmvtolt,
                             craprej.nrdconta,
                             craprej.cdagenci,
                             craprej.nrdctabb,
                             craprej.cdbccxlt,
                             craprej.nrdctitg,
                             craprej.nrseqdig,
                             craprej.dshistor,
                             craprej.cdpesqbb,
                             craprej.nrdocmto,
                             craprej.vllanmto,
                             craprej.indebcre,
                             craprej.dtrefere,
                             craprej.cdcritic,
                             craprej.dtdaviso,
                             craprej.tpintegr,
                             craprej.cdcooper,
                             craprej.cdempres )
                     VALUES( rw_crapdat.dtmvtolt,             -- craprej.dtmvtolt
                             nvl(rw_craptco_itg.nrctaant,0),  -- craprej.nrdconta
                             nvl(rw_craptco_itg.cdageant,0),  -- craprej.cdagenci
                             nvl(rw_craptco_itg.nrctaant,0),  -- craprej.nrdctabb
                             1,                               -- craprej.cdbccxlt
                             rw_craptco_itg.nrdctitg,         -- craprej.nrdctitg
                             nvl(vr_nrseqint,0),              -- craprej.nrseqdig
                             RPad(vr_dshistor,30,' ')||vr_dsageori,   -- craprej.dshistor
                             nvl(vr_cdpesqbb,''),             -- craprej.cdpesqbb
                             nvl(vr_nrdocmto,0),              -- craprej.nrdocmto
                             nvl(vr_vllanmto,0),              -- craprej.vllanmto
                             vr_indebcre,            -- craprej.indebcre
                             vr_dtrefere,            -- craprej.dtrefere
                             999,                    -- craprej.cdcritic
                             vr_dtdaviso,            -- craprej.dtdaviso
                             vr_contaarq,            -- craprej.tpintegr
                             pr_cdcooper,            -- craprej.cdcooper
                             -- usado o campo cdempres para passar o cdcopant
                             nvl(rw_craptco_itg.cdcopant,0)); --craprej.cdempres

             END;
             --Pular registro
             CONTINUE;
           END IF;
           CLOSE cr_craptco_itg;
         END IF; -- Fim if do arquivo da concredi

         /* tratar migração da 4-concredi para 1-viacredi e
                              15-credimilsul para 13-SCRCRED */
         IF pr_cdcooper in (1,13) AND
           (rw_crapdat.dtmvtolt >= to_date('11/18/2014','MM/DD/RRRR')   AND
            rw_crapdat.dtmvtolt <= to_date('11/30/2014','MM/DD/RRRR'))  THEN
           --Localizar assosiado pelo numero integraçaõ
           IF vr_tab_nrdctitg.EXISTS(lpad(vr_nrdctitg_arq,10,'0'))  THEN

             --Selecionar transferencias entre cooperativas inativas
             OPEN cr_craptco_i (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => vr_tab_nrdctitg(lpad(vr_nrdctitg_arq,10,'0')).nrdconta);
             --Posicionar primeiro registro
             FETCH cr_craptco_i INTO rw_craptco_i;
             --Se encontrou
             IF cr_craptco_i%NOTFOUND THEN
               close cr_craptco_i;
             ELSE
               close cr_craptco_i;
               --Gravar rejeitado
               BEGIN
                 --Montar data aviso
                 IF trim(vr_dtrefere) IS NOT NULL THEN
                   --Recebe data referencia
                   vr_dtdaviso:= to_date(SUBSTR(vr_dtrefere,1,10),'DD/MM/YYYY');
                 ELSE
                   --Recebe data movimento
                   vr_dtdaviso:= rw_crapdat.dtmvtolt;
                 END IF;

                 INSERT INTO CRAPREJ
                             ( craprej.dtmvtolt,
                               craprej.nrdconta,
                               craprej.cdagenci,
                               craprej.nrdctabb,
                               craprej.cdbccxlt,
                               craprej.nrdctitg,
                               craprej.nrseqdig,
                               craprej.dshistor,
                               craprej.cdpesqbb,
                               craprej.nrdocmto,
                               craprej.vllanmto,
                               craprej.indebcre,
                               craprej.dtrefere,
                               craprej.cdcritic,
                               craprej.dtdaviso,
                               craprej.tpintegr,
                               craprej.cdcooper,
                               craprej.cdempres )
                       VALUES( rw_crapdat.dtmvtolt,    -- craprej.dtmvtolt
                               nvl(rw_craptco_i.nrctaant,0),  -- craprej.nrdconta
                               nvl(rw_craptco_i.cdageant,0),  -- craprej.cdagenci
                               nvl(rw_craptco_i.nrctaant,0),  -- craprej.nrdctabb
                               1,                      -- craprej.cdbccxlt
                               rw_craptco_i.nrdctitg,  -- craprej.nrdctitg
                               nvl(vr_nrseqint,0),            -- craprej.nrseqdig
                               RPad(vr_dshistor,30,' ')||vr_dsageori,   -- craprej.dshistor
                               nvl(vr_cdpesqbb,''),            -- craprej.cdpesqbb
                               nvl(vr_nrdocmto,0),            -- craprej.nrdocmto
                               nvl(vr_vllanmto,0),            -- craprej.vllanmto
                               vr_indebcre,            -- craprej.indebcre
                               vr_dtrefere,            -- craprej.dtrefere
                               999,                    -- craprej.cdcritic
                               vr_dtdaviso,            -- craprej.dtdaviso
                               vr_contaarq,            -- craprej.tpintegr
                               pr_cdcooper,            -- craprej.cdcooper
                               -- usado o campo cdempres para passar o cdcopant
                               nvl(rw_craptco_i.cdcopant,0)); --craprej.cdempres
               END;

               continue; -- proximo registro

             END IF;
           END IF; -- Fim vr_tab_nrdctitg
         END IF; -- Fim pr_cdcooper = 1

         
         /* tratar migração da 17-transulcred para 9-transpocred*/
         IF pr_cdcooper = 9 AND
           (rw_crapdat.dtmvtolt >= to_date('12/12/2016','MM/DD/RRRR')   AND
            rw_crapdat.dtmvtolt <= to_date('12/31/2016','MM/DD/RRRR'))  THEN
           --Localizar assosiado pelo numero integraçaõ
           IF vr_tab_nrdctitg.EXISTS(lpad(vr_nrdctitg_arq,10,'0'))  THEN

             --Selecionar transferencias entre cooperativas inativas
             OPEN cr_craptco_i (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => vr_tab_nrdctitg(lpad(vr_nrdctitg_arq,10,'0')).nrdconta);
             --Posicionar primeiro registro
             FETCH cr_craptco_i INTO rw_craptco_i;
             --Se encontrou
             IF cr_craptco_i%NOTFOUND THEN
               close cr_craptco_i;
             ELSE
               close cr_craptco_i;
               --Gravar rejeitado
               BEGIN
                 --Montar data aviso
                 IF trim(vr_dtrefere) IS NOT NULL THEN
                   --Recebe data referencia
                   vr_dtdaviso:= to_date(SUBSTR(vr_dtrefere,1,10),'DD/MM/YYYY');
                 ELSE
                   --Recebe data movimento
                   vr_dtdaviso:= rw_crapdat.dtmvtolt;
                 END IF;

                 INSERT INTO CRAPREJ
                             ( craprej.dtmvtolt,
                               craprej.nrdconta,
                               craprej.cdagenci,
                               craprej.nrdctabb,
                               craprej.cdbccxlt,
                               craprej.nrdctitg,
                               craprej.nrseqdig,
                               craprej.dshistor,
                               craprej.cdpesqbb,
                               craprej.nrdocmto,
                               craprej.vllanmto,
                               craprej.indebcre,
                               craprej.dtrefere,
                               craprej.cdcritic,
                               craprej.dtdaviso,
                               craprej.tpintegr,
                               craprej.cdcooper,
                               craprej.cdempres )
                       VALUES( rw_crapdat.dtmvtolt,    -- craprej.dtmvtolt
                               nvl(rw_craptco_i.nrctaant,0),  -- craprej.nrdconta
                               nvl(rw_craptco_i.cdageant,0),  -- craprej.cdagenci
                               nvl(rw_craptco_i.nrctaant,0),  -- craprej.nrdctabb
                               1,                      -- craprej.cdbccxlt
                               rw_craptco_i.nrdctitg,  -- craprej.nrdctitg
                               nvl(vr_nrseqint,0),            -- craprej.nrseqdig
                               RPad(vr_dshistor,30,' ')||vr_dsageori,   -- craprej.dshistor
                               nvl(vr_cdpesqbb,''),            -- craprej.cdpesqbb
                               nvl(vr_nrdocmto,0),            -- craprej.nrdocmto
                               nvl(vr_vllanmto,0),            -- craprej.vllanmto
                               vr_indebcre,            -- craprej.indebcre
                               vr_dtrefere,            -- craprej.dtrefere
                               999,                    -- craprej.cdcritic
                               vr_dtdaviso,            -- craprej.dtdaviso
                               vr_contaarq,            -- craprej.tpintegr
                               pr_cdcooper,            -- craprej.cdcooper
                               -- usado o campo cdempres para passar o cdcopant
                               nvl(rw_craptco_i.cdcopant,0)); --craprej.cdempres
               END;

               continue; -- proximo registro

             END IF;
           END IF; -- Fim vr_tab_nrdctitg
         END IF; -- Fim pr_cdcooper = 9

         --Se nao ocorreu erro e for cheque
         IF vr_cdcritic = 0 AND vr_flgchequ THEN
           /* Contas Normais */
           OPEN cr_crapfdc (pr_cdcooper => pr_cdcooper
                           ,pr_cdbanchq => 1
                           ,pr_cdagechq => rw_crapcop.cdageitg
                           ,pr_nrctachq => vr_nrdctabb
                           ,pr_nrcheque => vr_nrdocmto);
           --Posicionar no primeiro registro
           FETCH cr_crapfdc INTO rw_crapfdc;
           --Se encontrou
           IF cr_crapfdc%NOTFOUND THEN
             vr_cdcritic:= 108;
           ELSE
             vr_nrdocmto:= TO_NUMBER(gene0002.fn_mask(rw_crapfdc.nrcheque,'999999')||
                                     gene0002.fn_mask(rw_crapfdc.nrdigchq,'9'));
             vr_nrdconta:= rw_crapfdc.nrdconta;
             vr_nrdctitg:= rw_crapfdc.nrdctitg;
             IF rw_crapfdc.tpcheque = 3 THEN /* cheque salario */
               vr_cdcritic:= 289;
             ELSIF rw_crapfdc.dtemschq IS NULL THEN  /*Data emissao cheque*/
               vr_cdcritic:= 108;
             ELSIF rw_crapfdc.dtretchq IS NULL THEN  /*Data retirada cheque*/
               vr_cdcritic:= 109;
             ELSIF rw_crapfdc.incheque IN (5,6,7) THEN
               vr_cdcritic:= 97;
             ELSIF rw_crapfdc.incheque = 8 THEN
               vr_cdcritic:= 320;
             END IF;
           END IF;
           --Fechar Cursor
           CLOSE cr_crapfdc;
         END IF;

         IF vr_cdcritic = 0 THEN
           --Encontrou conta recebe false
           vr_flgctaok:= FALSE;
           --Deposito/Estorno/Debito
           IF vr_flgdepos OR vr_flgestor OR vr_flgdebit OR vr_flgdevol THEN
             --Montar numero da conta
             vr_index_crapass:= lpad(vr_nrdctitg_arq,10,'0');

             --Se nao existir
             IF vr_tab_nrdctitg.EXISTS(vr_index_crapass) THEN
               vr_flgctaok:= TRUE;
               rw_crapass.nrdconta:= vr_tab_nrdctitg(vr_index_crapass).nrdconta;
               rw_crapass.nrdctitg:= vr_tab_nrdctitg(vr_index_crapass).nrdctitg;
               rw_crapass.cdsitdtl:= vr_tab_nrdctitg(vr_index_crapass).cdsitdtl;
               rw_crapass.dtelimin:= vr_tab_nrdctitg(vr_index_crapass).dtelimin;
             END IF;
           ELSE
             --Selecionar associado
             vr_index_crapass:= lpad(vr_nrdconta,10,'0');
             --Se nao existir
             IF vr_tab_nrdconta.EXISTS(vr_index_crapass) THEN
               vr_flgctaok:= TRUE;
               rw_crapass.nrdconta:= vr_tab_nrdconta(vr_index_crapass).nrdconta;
               rw_crapass.nrdctitg:= vr_tab_nrdconta(vr_index_crapass).nrdctitg;
               rw_crapass.cdsitdtl:= vr_tab_nrdconta(vr_index_crapass).cdsitdtl;
               rw_crapass.dtelimin:= vr_tab_nrdconta(vr_index_crapass).dtelimin;
             END IF;
           END IF;
           --Se nao encontrou
           IF NOT vr_flgctaok THEN
             vr_cdcritic:= 9;
           ELSIF rw_crapass.cdsitdtl IN (5,6,7,8) THEN
             vr_cdcritic:= 695;
           ELSIF rw_crapass.cdsitdtl IN (2,4,6,8) THEN
             vr_cdcritic:= 95;
           ELSIF rw_crapass.dtelimin IS NOT NULL THEN
             vr_cdcritic:= 410;
           ELSE
             vr_nrdconta:= rw_crapass.nrdconta;
             vr_nrdctitg:= rw_crapass.nrdctitg;
           END IF;
         END IF;

         /* Somente Viacredi */
         IF pr_cdcooper = 1 AND vr_flgctaok THEN
           /* Critica apenas contas cadastradas no TCO */
           OPEN cr_craptco (pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_crapass.nrdconta);
           --Posicionar primeiro registro
           FETCH cr_craptco INTO rw_craptco;
           --Se encontrou
           IF cr_craptco%FOUND THEN
             /*  Criticar SOMENTE os CHEQUES  */
             IF rw_crapdat.dtmvtolt >= To_Date('01/01/2011','DD/MM/YYYY') THEN
               --Historico Cheques
               IF InStr(vr_dshstchq,SUBSTR(vr_dshistor,01,04)) > 0 THEN
                 vr_cdcritic:= 999;
               END IF;
             ELSE
               /*  Criticar TODOS os LANCAMENTOS  */
               vr_cdcritic:= 999;
             END IF;
             vr_nrdconta:= rw_crapass.nrdconta;
           END IF;
           --Fechar Cursor
           CLOSE cr_craptco;
         END IF;

         --Inicio transacao
         BEGIN
           --Criando savepoint
           SAVEPOINT save_trans1;

           IF vr_flgclote THEN
             vr_nrdolote:= nvl(vr_nrdolote,0) + 1;

             /* Leitura do lote */
             OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_cdbccxlt => vr_cdbccxlt
                             ,pr_nrdolote => vr_nrdolote);
             --Posicionar no proximo registro
             FETCH cr_craplot INTO rw_craplot;
             --Se nao encontrou registro
             IF cr_craplot%FOUND THEN
               --Fechar Cursor
               CLOSE cr_craplot;
               vr_cdcritic:= 59;
               vr_dscritic:=  gene0001.fn_busca_critica(vr_cdcritic);
               vr_dscritic:= vr_dscritic || ' COMPBB - LOTE = '|| gene0002.fn_mask(vr_nrdolote,'999,999');
               --Escrever mensagem log
               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic);
               --Levantar Excecao
               RAISE vr_exc_saida;
             ELSE
               --Fechar Cursor
               CLOSE cr_craplot;
               --Criar lote
               BEGIN
                 INSERT INTO craplot
                      (craplot.cdcooper
                      ,craplot.dtmvtolt
                      ,craplot.cdagenci
                      ,craplot.cdbccxlt
                      ,craplot.nrdolote
                      ,craplot.tplotmov)
                 VALUES
                      (pr_cdcooper
                      ,rw_crapdat.dtmvtolt
                      ,nvl(vr_cdagenci,0)
                      ,nvl(vr_cdbccxlt,0)
                      ,nvl(vr_nrdolote,0)
                      ,1)
                 RETURNING ROWID
                     ,craplot.dtmvtolt
                     ,craplot.cdagenci
                     ,craplot.cdbccxlt
                     ,craplot.nrdolote
                     ,craplot.tplotmov
                 INTO rw_craplot.rowid
                     ,rw_craplot.dtmvtolt
                     ,rw_craplot.cdagenci
                     ,rw_craplot.cdbccxlt
                     ,rw_craplot.nrdolote
                     ,rw_craplot.tplotmov;
               EXCEPTION
                 WHEN Dup_Val_On_Index THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Lote ja cadastrado.';
                   RAISE vr_exc_saida;
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao inserir na tabela de lotes. '||sqlerrm;
                   RAISE vr_exc_saida;
               END;
             END IF;
             --Atualizar tabela parametros
             BEGIN
               UPDATE craptab SET craptab.dstextab = to_char(vr_nrdolote,'fm0000')
               WHERE craptab.rowid = vr_rowid_lote;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao atualizar tabela craptab. '||sqlerrm;
                 RAISE vr_exc_saida;
             END;
             vr_flgclote:= FALSE;
           ELSE
             /* Leitura do lote */
             OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_cdbccxlt => vr_cdbccxlt
                             ,pr_nrdolote => vr_nrdolote);
             --Posicionar no proximo registro
             FETCH cr_craplot INTO rw_craplot;
             --Se nao encontrou registro
             IF cr_craplot%NOTFOUND THEN
               --Fechar Cursor
               CLOSE cr_craplot;
               vr_cdcritic:= 60;
               vr_dscritic:=  gene0001.fn_busca_critica(vr_cdcritic);
               vr_dscritic:= vr_dscritic || ' COMPBB - LOTE = '|| gene0002.fn_mask(vr_nrdolote,'999,999');
               --Escrever mensagem log
               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic);
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;
             --Fechar Cursor
             CLOSE cr_craplot;
           END IF;

           --Enquanto nao tiver critica e for cheque
           WHILE vr_cdcritic = 0 AND vr_flgchequ LOOP
             vr_index_craplcm:= LPad(vr_nrdolote,10,'0')||
                                LPad(vr_nrdctabb,10,'0')||
                                LPad(vr_nrdocmto,10,'0');
             --Se existir no vetor
             IF vr_tab_craplcm.EXISTS(vr_index_craplcm) THEN
               --Selecionar lancamentos
               OPEN cr_craplcm (pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cdagenci => vr_cdagenci
                               ,pr_cdbccxlt => vr_cdbccxlt
                               ,pr_nrdolote => vr_nrdolote
                               ,pr_nrdctabb => vr_nrdctabb
                               ,pr_nrdocmto => vr_nrdocmto);
               --Posicionar no primeiro registro
               FETCH cr_craplcm INTO rw_craplcm;
               --Se encontrou
               IF cr_craplcm%FOUND THEN
                 --Fechar Cursor
                 CLOSE cr_craplcm;
                 vr_cdcritic:= 92;
                 --Sair loop
                 EXIT;
               END IF;
               --Fechar Cursor
               IF cr_craplcm%ISOPEN THEN
                 CLOSE cr_craplcm;
               END IF;
             END IF;
             --Se tem alerta no cheque
             IF rw_crapfdc.incheque = 2 THEN
               vr_cdcritic:= 257;
             ELSE
               IF rw_crapfdc.incheque = 1 THEN
                 --Selecionar lancamentos
                 OPEN cr_craplcm2 (pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => vr_nrdconta
                                  ,pr_nrdocmto => vr_nrdocmto);
                 --Posicionar no primeiro registro
                 FETCH cr_craplcm2 INTO rw_craplcm;
                 --Se nao encontrou
                 IF cr_craplcm2%NOTFOUND THEN
                   vr_cdcritic:= 96;
                   vr_indevchq:= 1;
                   vr_cdalinea:= 0;
                 ELSE
                   --Selecionar Contra-ordens
                   OPEN cr_crapcor (pr_cdcooper => pr_cdcooper
                                   ,pr_cdbanchq => 1
                                   ,pr_cdagechq => rw_crapcop.cdageitg
                                   ,pr_nrctachq => vr_nrdctabb
                                   ,pr_nrcheque => vr_nrdocmto
                                   ,pr_flgativo => 1);
                   --Posicionar primeiro registro
                   FETCH cr_crapcor INTO rw_crapcor;
                   --Se nao encontrou
                   IF cr_crapcor%NOTFOUND THEN
                     vr_cdcritic:= 439;
                     vr_indevchq:= 1;
                     vr_cdalinea:= 0;
                   ELSIF rw_crapcor.dtvalcor >= rw_crapdat.dtmvtolt THEN
                     vr_cdcritic:= 96;
                     vr_indevchq:= 1;
                     vr_cdalinea:= 70;
                   ELSIF rw_crapcor.dtemscor > rw_craplcm.dtmvtolt THEN
                     vr_cdcritic:= 96;
                     vr_indevchq:= 1;
                     vr_cdalinea:= 0;
                   ELSE
                     vr_cdcritic:= 439;
                     vr_indevchq:= 1;
                     IF rw_crapcor.cdhistor = 835 THEN
                       vr_cdalinea:= 28;
                     ELSIF rw_crapcor.cdhistor = 815 THEN
                       vr_cdalinea:= 21;
                     ELSIF rw_crapcor.cdhistor = 818 THEN
                       vr_cdalinea:= 20;
                     ELSE
                       vr_cdalinea:= 21;
                     END IF;
                   END IF;
                   --Fechar Cursor
                   CLOSE cr_crapcor;
                 END IF;
                 --Fechar Cursor
                 CLOSE cr_craplcm2;
               END IF;
             END IF;
             --Sair
             EXIT;
           END LOOP;

           /*  Monta a data de liberacao para depositos bloqueados  */
           IF vr_cdcritic = 0 AND vr_flgdepos THEN
             /*  Deposito Bloqueado  */
             IF INSTR(vr_dshstblq,SUBSTR(vr_dshistor,01,04)) > 0 THEN
               --Zerar dias utilizados
               vr_nrdiautl:= 0;

               CASE SUBSTR(vr_dshistor,01,04)
                 WHEN '0511' THEN vr_nrdiautl:= 1;
                 WHEN '0512' THEN vr_nrdiautl:= 2;
                 WHEN '0513' THEN vr_nrdiautl:= 3;
                 WHEN '0514' THEN vr_nrdiautl:= 4;
                 WHEN '0515' THEN vr_nrdiautl:= 5;
                 WHEN '0516' THEN vr_nrdiautl:= 6;
                 WHEN '0517' THEN vr_nrdiautl:= 7;
                 WHEN '0518' THEN vr_nrdiautl:= 8;
                 WHEN '0519' THEN vr_nrdiautl:= 9;
                 WHEN '0520' THEN vr_nrdiautl:= 20;
                 WHEN '0911' THEN vr_nrdiautl:= 1;
                 WHEN '0912' THEN vr_nrdiautl:= 2;
                 WHEN '0913' THEN vr_nrdiautl:= 3;
                 WHEN '0914' THEN vr_nrdiautl:= 4;
                 WHEN '0915' THEN vr_nrdiautl:= 5;
                 WHEN '0916' THEN vr_nrdiautl:= 6;
                 WHEN '0917' THEN vr_nrdiautl:= 7;
                 WHEN '0918' THEN vr_nrdiautl:= 8;
                 WHEN '0919' THEN vr_nrdiautl:= 9;
                 WHEN '0920' THEN vr_nrdiautl:= 20;
               END CASE;
               --Se a qdade estiver zerada
               IF vr_nrdiautl = 0 THEN
                 vr_cdcritic:= 245;
               ELSIF vr_nrdiautl = 1 THEN
                 --Data Liberacao
                 vr_dtliblan:= rw_crapdat.dtmvtopr;
                 vr_cdhistor:= 170;
               ELSE
                 vr_cdhistor:= 170;
                 vr_dtliblan:= rw_crapdat.dtmvtopr;
                 vr_contador:= vr_nrdiautl;
                 --Procurar feriado
                 WHILE vr_contador > 1 LOOP
                   --Incrementar data liberacao
                   vr_dtliblan:= vr_dtliblan + 1;
                   vr_dtferiado:= gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                             ,pr_dtmvtolt => vr_dtliblan
                                                             ,pr_tipo => 'P');
                   --Se a data for diferente Ã© feriado ou fim semana
                   IF vr_dtferiado != vr_dtliblan THEN
                     CONTINUE;
                   END IF;
                   --Diminuir contador
                   vr_contador:= vr_contador-1;
                 END LOOP;
               END IF;
             ELSE
               CASE SUBSTR(vr_dshistor,01,04)
                 WHEN '0688' THEN vr_cdhistor:= 646;
                 WHEN '0623' THEN vr_cdhistor:= 314;
                 WHEN '0732' THEN vr_cdhistor:= 584;
                 WHEN '0204' THEN vr_cdhistor:= 584;
                 WHEN '0976' THEN vr_cdhistor:= 651;
                 ELSE vr_cdhistor:= 169;
               END CASE;
               --Data liberacao lancamento
               vr_dtliblan:= NULL;
               
             /*0612REDECARD CREDIT, 0900REDE CABAL DEBI, 0900REDE CB CREDITO, 
               0900REDE CREDITO   , 0900REDE DC CREDITO, 0900REDE HIPER CRED,
               0900REDE MA CREDITO, 0900REDE SICREDI CR, 0900REDE VENDAS DEB,
               0900REDE VI CREDITO, 0900REDE VISA DEBIT, 0900REDE-CS CR     ,
               0900REDECARD HP DEB, 0900REDECARD MA DEB, 0900REDECARD SI DEB,
               0900REDECARD VI DEB */
               
               IF SUBSTR(vr_dshistor,01,08) IN ('0612REDE','0900REDE') THEN
                 vr_cdhistor:= 444;
               ELSIF SUBSTR(vr_dshistor,01,12) = '707BENEFICIO' THEN
                 vr_cdhistor:= 694;
               END IF;
             END IF;
           END IF;

           /* Estorno */
           IF vr_cdcritic = 0 AND vr_flgestor THEN
             vr_nrdocmt2:= vr_nrdocmto;
             WHILE TRUE LOOP
               --Selecionar lancamentos
               OPEN cr_craplcm (pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cdagenci => vr_cdagenci
                               ,pr_cdbccxlt => vr_cdbccxlt
                               ,pr_nrdolote => vr_nrdolote
                               ,pr_nrdctabb => vr_nrdctabb
                               ,pr_nrdocmto => vr_nrdocmt2);
               --Posicionar no primeiro registro
               FETCH cr_craplcm INTO rw_craplcm;
               --Se encontrou
               IF cr_craplcm%FOUND THEN
                 --Fechar Cursor
                 CLOSE cr_craplcm;
                 --Incrementar lote
                 vr_nrdocmt2:= vr_nrdocmt2 + 1000000;
               ELSE
                 --Fechar Cursor
                 CLOSE cr_craplcm;
                 --Sair Loop
                 EXIT;
               END IF;
             END LOOP;
             --Setar numero documento baseado no encontrado
             vr_nrdocmto:= vr_nrdocmt2;
             vr_cdcritic:= 608;
             /* Est. Depositos Bloq. */
             IF Instr(vr_dsestblq,SUBSTR(vr_dshistor,01,04)) > 0 THEN
               vr_cdhistor:= 297;
             ELSIF SUBSTR(vr_dshistor,01,04) IN ('0780','0807','0828') THEN
               vr_cdhistor:= 662;    /* Est. Debitos */
             ELSE
               vr_cdhistor:= 290;    /* Est. Depositos */
             END IF;
           END IF;

           /* Debitos */
           IF vr_cdcritic = 0 AND vr_flgdebit THEN
             /******  Nao Esquecer de Alterar tambem a Linha 1875  *****/
             CASE SUBSTR(vr_dshistor,01,04)
               WHEN '0233' THEN vr_cdhistor:= 614;
               WHEN '0331' THEN vr_cdhistor:= 614;
               WHEN '0328' THEN vr_cdhistor:= 658;
               WHEN '0234' THEN vr_cdhistor:= 613;
               WHEN '0470' THEN vr_cdhistor:= 668;
               WHEN '0474' THEN vr_cdhistor:= 668;
               WHEN '0144' THEN vr_cdhistor:= 471;
               ELSE vr_cdhistor:= 661;
             END CASE;

             vr_nrdocmt2:= vr_nrdocmto;
             WHILE TRUE LOOP
               --Selecionar lancamentos
               OPEN cr_craplcm (pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cdagenci => vr_cdagenci
                               ,pr_cdbccxlt => vr_cdbccxlt
                               ,pr_nrdolote => vr_nrdolote
                               ,pr_nrdctabb => vr_nrdctabb
                               ,pr_nrdocmto => vr_nrdocmt2);
               --Posicionar no primeiro registro
               FETCH cr_craplcm INTO rw_craplcm;
               --Se encontrou
               IF cr_craplcm%FOUND THEN
                 --Fechar Cursor
                 CLOSE cr_craplcm;
                 --Incrementar lote
                 vr_nrdocmt2:= vr_nrdocmt2 + 1000000;
               ELSE
                 --Fechar Cursor
                 CLOSE cr_craplcm;
                 --Sair Loop
                 EXIT;
               END IF;
             END LOOP;
             vr_nrdocmto:= vr_nrdocmt2;
           END IF;

           /* Devolucoes recebidas 0114*/
           IF vr_cdcritic = 0 AND vr_flgdevol THEN             
                vr_cdhistor:= 351;
                vr_cdpesqbb:= ' '; /*Limpo o cdpesqbb para que qdo for este historico ele nao apareca no extrato*/

             vr_nrdocmt2:= vr_nrdocmto;
             WHILE TRUE LOOP
               --Selecionar lancamentos
               OPEN cr_craplcm (pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cdagenci => vr_cdagenci
                               ,pr_cdbccxlt => vr_cdbccxlt
                               ,pr_nrdolote => vr_nrdolote
                               ,pr_nrdctabb => vr_nrdctabb
                               ,pr_nrdocmto => vr_nrdocmt2);
               --Posicionar no primeiro registro
               FETCH cr_craplcm INTO rw_craplcm;
               --Se encontrou
               IF cr_craplcm%FOUND THEN
                 --Fechar Cursor
                 CLOSE cr_craplcm;
                 --Incrementar lote
                 vr_nrdocmt2:= vr_nrdocmt2 + 1000000;
               ELSE
                 --Fechar Cursor
                 CLOSE cr_craplcm;
                 --Sair Loop
                 EXIT;
               END IF;
             END LOOP;
             vr_nrdocmto:= vr_nrdocmt2;
             vr_cdcritic:= 981; /** Histórico Processado **/
           END IF;

           /* Cheques */
           IF vr_cdcritic = 0 AND vr_flgchequ THEN
             --Selecionar Custodia Cheques
             OPEN cr_crapcst (pr_cdcooper => rw_crapfdc.cdcooper
                             ,pr_cdcmpchq => rw_crapfdc.cdcmpchq
                             ,pr_cdbanchq => rw_crapfdc.cdbanchq
                             ,pr_cdagechq => rw_crapfdc.cdagechq
                             ,pr_nrctachq => rw_crapfdc.nrctachq
                             ,pr_nrcheque => rw_crapfdc.nrcheque);
             --Posicionar no primeiro registro
             FETCH cr_crapcst INTO rw_crapcst;
             --Se encontrou
             IF cr_crapcst%FOUND THEN
               vr_cdcritic:= 757;
               --Criar rejeitado
               vr_index_craprej:= vr_tab_craprej.count+1;
               vr_tab_craprej(vr_index_craprej).cdcooper:= pr_cdcooper;
               vr_tab_craprej(vr_index_craprej).dtrefere:= vr_dtrefere;
               vr_tab_craprej(vr_index_craprej).nrdconta:= vr_nrdconta;
               vr_tab_craprej(vr_index_craprej).nrdocmto:= vr_nrdocmto;
               vr_tab_craprej(vr_index_craprej).vllanmto:= vr_vllanmto;
               vr_tab_craprej(vr_index_craprej).nrseqdig:= vr_nrseqint;
               vr_tab_craprej(vr_index_craprej).cdcritic:= vr_cdcritic;
               vr_tab_craprej(vr_index_craprej).cdpesqbb:= vr_cdpesqbb;
               vr_tab_craprej(vr_index_craprej).dscritic:= 'Conta '||rw_crapcst.nrdconta;
             END IF;
             --Fechar Cursor
             CLOSE cr_crapcst;
             --Selecionar Borderos
             OPEN cr_crapcdb (pr_cdcooper => rw_crapfdc.cdcooper
                             ,pr_cdcmpchq => rw_crapfdc.cdcmpchq
                             ,pr_cdbanchq => rw_crapfdc.cdbanchq
                             ,pr_cdagechq => rw_crapfdc.cdagechq
                             ,pr_nrctachq => rw_crapfdc.nrctachq
                             ,pr_nrcheque => rw_crapfdc.nrcheque);
             --Posicionar no primeiro registro
             FETCH cr_crapcdb INTO rw_crapcdb;
             --Se Encontrou
             IF cr_crapcdb%FOUND THEN
               vr_cdcritic:= 811;
               --Criar rejeitado
               vr_index_craprej:= vr_tab_craprej.count+1;
               vr_tab_craprej(vr_index_craprej).cdcooper:= pr_cdcooper;
               vr_tab_craprej(vr_index_craprej).dtrefere:= vr_dtrefere;
               vr_tab_craprej(vr_index_craprej).nrdconta:= vr_nrdconta;
               vr_tab_craprej(vr_index_craprej).nrdocmto:= vr_nrdocmto;
               vr_tab_craprej(vr_index_craprej).vllanmto:= vr_vllanmto;
               vr_tab_craprej(vr_index_craprej).nrseqdig:= vr_nrseqint;
               vr_tab_craprej(vr_index_craprej).cdcritic:= vr_cdcritic;
               vr_tab_craprej(vr_index_craprej).cdpesqbb:= vr_cdpesqbb;
               vr_tab_craprej(vr_index_craprej).dscritic:= 'Conta '||rw_crapcdb.nrdconta;
             END IF;
             --Fechar Cursor
             CLOSE cr_crapcdb;
           END IF;
           --Se ocorreu erro
           IF vr_cdcritic > 0 THEN
             /* Formata conta integracao */
             GENE0005.pc_conta_itg_digito_x (pr_nrcalcul => vr_nrdctabb
                                            ,pr_dscalcul => vr_dsdctitg
                                            ,pr_stsnrcal => vr_stsnrcal
                                            ,pr_cdcritic => vr_cdcritic2
                                            ,pr_dscritic => vr_dscritic2);
             --Se ocorreu erro
             IF vr_cdcritic2 IS NOT NULL OR vr_dscritic2 IS NOT NULL THEN
               vr_cdcritic:= vr_cdcritic2;
               vr_dscritic:= vr_dscritic2;
               --Levantar exececao
               RAISE vr_exc_saida;
             END IF;

             BEGIN
               --Montar data aviso
               IF vr_dtrefere IS NOT NULL THEN
                 --Recebe data referencia
                 vr_dtdaviso:= to_date(SUBSTR(vr_dtrefere,4,2)||
                                      SUBSTR(vr_dtrefere,1,2)||
                                      SUBSTR(vr_dtrefere,7,4),'MMDDYYYY');
               ELSE
                 --Recebe data movimento
                 vr_dtdaviso:= rw_crapdat.dtmvtolt;
               END IF;

               /*TEC salario*/
               IF vr_flgtecsa THEN
                 vr_cdcritic := 0;
               END IF;

               --Inserir registro rejeicao
               INSERT INTO craprej
                 (craprej.dtmvtolt
                 ,craprej.cdagenci
                 ,craprej.cdbccxlt
                 ,craprej.nrdolote
                 ,craprej.tplotmov
                 ,craprej.nrdconta
                 ,craprej.nrdctabb
                 ,craprej.nrdctitg
                 ,craprej.dshistor
                 ,craprej.cdpesqbb
                 ,craprej.nrseqdig
                 ,craprej.nrdocmto
                 ,craprej.vllanmto
                 ,craprej.indebcre
                 ,craprej.dtrefere
                 ,craprej.cdcritic
                 ,craprej.dtdaviso
                 ,craprej.tpintegr
                 ,craprej.cdcooper)
               VALUES
                 (rw_craplot.dtmvtolt
                 ,rw_craplot.cdagenci
                 ,rw_craplot.cdbccxlt
                 ,rw_craplot.nrdolote
                 ,rw_craplot.tplotmov
                 ,nvl(vr_nrdconta,0)
                 ,nvl(vr_nrdctabb,0)
                 ,nvl(vr_dsdctitg,' ')
                 ,RPad(vr_dshistor,30,' ')||vr_dsageori
                 ,nvl(vr_cdpesqbb,' ')
                 ,nvl(vr_nrseqint,0)
                 ,nvl(vr_nrdocmto,0)
                 ,nvl(vr_vllanmto,0)
                 ,vr_indebcre
                 ,vr_dtrefere
                 ,nvl(vr_cdcritic,0)
                 ,vr_dtdaviso
                 ,vr_contaarq
                 ,pr_cdcooper);
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao inserir na tabela craprej. '||sqlerrm;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
             END;
             --Flag Entrada
             IF vr_cdcritic IN (96,137,172,257,287,439,608,981) THEN
               vr_flgentra:= TRUE;
             ELSE
               vr_flgentra:= FALSE;
             END IF;
             --Zerar critica
             vr_cdcritic:= 0;
           ELSE
             --Se for deposito ou debito
             IF vr_flgdepos OR vr_flgdebit THEN

               vr_nrdocmt2:= vr_nrdocmto;
               WHILE TRUE LOOP
                 --Selecionar lancamentos
                 OPEN cr_craplcm (pr_cdcooper => pr_cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_cdagenci => vr_cdagenci
                                 ,pr_cdbccxlt => vr_cdbccxlt
                                 ,pr_nrdolote => vr_nrdolote
                                 ,pr_nrdctabb => vr_nrdctabb
                                 ,pr_nrdocmto => vr_nrdocmt2);
                 --Posicionar no primeiro registro
                 FETCH cr_craplcm INTO rw_craplcm;
                 --Se encontrou
                 IF cr_craplcm%FOUND THEN
                   --Fechar Cursor
                   CLOSE cr_craplcm;
                   --Incrementar lote
                   vr_nrdocmt2:= vr_nrdocmt2 + 1000000;
                 ELSE
                   --Fechar Cursor
                   CLOSE cr_craplcm;
                   --Sair Loop
                   EXIT;
                 END IF;
               END LOOP;
               vr_nrdocmto:= vr_nrdocmt2;
             END IF;
           END IF;

           /* Cheque */
           IF vr_flgchequ THEN
             --Selecionar negativos
             FOR rw_crapneg IN cr_crapneg (pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => vr_nrdconta
                                          ,pr_nrdocmto => vr_nrdocmto) LOOP
               --Se for tipo 1
               IF  rw_crapfdc.tpcheque = 1 THEN
                 vr_indevchq:= 1;
               ELSE
                 vr_indevchq:= 3;
               END IF;
               vr_cdalinea:= 49;
               vr_flgentra:= TRUE;
               EXIT;
             END LOOP;
           END IF;

           /* Entrada e Cheque */
           IF vr_flgentra AND vr_flgchequ THEN
             BEGIN
               --Montar Historico
               IF rw_crapfdc.tpcheque = 1 THEN
                 vr_cdhislcm:= 50;
               ELSE
                 vr_cdhislcm:= 59;
               END IF;
/*
               lanc0001.pc_gerar_lancamento_conta(
                                 pr_dtmvtolt => rw_craplot.dtmvtolt,
                                 pr_dtrefere => vr_dtleiarq,
                                 pr_cdagenci => rw_craplot.cdagenci,
                                 pr_cdbccxlt => rw_craplot.cdbccxlt,
                                 pr_nrdolote => rw_craplot.nrdolote,
                                 pr_nrdconta => nvl(vr_nrdconta,0),
                                 pr_nrdctabb => nvl(vr_nrdctabb,0),
                                 pr_nrdctitg => nvl(vr_nrdctitg,' '),
                                 pr_nrdocmto => nvl(vr_nrdocmto,0),
                                 pr_cdhistor => nvl(vr_cdhislcm,0),
                                 pr_vllanmto => nvl(vr_vllanmto,0),
                                 pr_nrseqdig => nvl(vr_nrseqint,0),
                                 pr_cdpesqbb => nvl(vr_cdpesqbb,' '),
                                 pr_cdcooper => pr_cdcooper,
                                 pr_cdbanchq => rw_crapfdc.cdbanchq,
                                 pr_cdagechq => rw_crapfdc.cdagechq,
                                 pr_nrctachq => rw_crapfdc.nrctachq,
                                 pr_tab_retorno => vr_tab_retorno,
                                 pr_incrineg => vr_incrineg,
                                 pr_cdcritic => vr_cdcritic,
                                 pr_dscritic => vr_dscritic);
               if (nvl(vr_cdcritic,0) <> 0 or vr_dscritic is not null) then
                 RAISE vr_exc_saida;
               end if;

               rw_craplcm.nrseqdig:=nvl(vr_nrseqint,0);
               rw_craplcm.cdhistor:=nvl(vr_cdhislcm,0);
*/
               --grava na pl pra mandar email tiago;               
               vr_flbloque := 0;

               pc_ver_bloqueio(pr_cdcooper => pr_cdcooper
                              ,pr_cdhistor => nvl(vr_cdhislcm,0)
                              ,pr_nrdconta => nvl(vr_nrdconta,0)
                              ,pr_flbloque => vr_flbloque );

               IF vr_flbloque = 1 THEN

                 vr_tab_conta_blq(vr_contablq).cdcooper := pr_cdcooper;
                 vr_tab_conta_blq(vr_contablq).nrdconta := nvl(vr_nrdconta,0);
                 vr_tab_conta_blq(vr_contablq).cdhistor := nvl(vr_cdhislcm,0);
                 vr_tab_conta_blq(vr_contablq).vllanmto := nvl(vr_vllanmto,0);

                 vr_contablq := vr_contablq + 1;
                 
               END IF;               

               INSERT INTO craplcm
                 (craplcm.dtmvtolt
                 ,craplcm.dtrefere
                 ,craplcm.cdagenci
                 ,craplcm.cdbccxlt
                 ,craplcm.nrdolote
                 ,craplcm.nrdconta
                 ,craplcm.nrdctabb
                 ,craplcm.nrdctitg
                 ,craplcm.nrdocmto
                 ,craplcm.cdhistor
                 ,craplcm.vllanmto
                 ,craplcm.nrseqdig
                 ,craplcm.cdpesqbb
                 ,craplcm.cdcooper
                 ,craplcm.cdbanchq
                 ,craplcm.cdagechq
                 ,craplcm.nrctachq)
               VALUES
                 (rw_craplot.dtmvtolt
                 ,vr_dtleiarq
                 ,rw_craplot.cdagenci
                 ,rw_craplot.cdbccxlt
                 ,rw_craplot.nrdolote
                 ,nvl(vr_nrdconta,0)
                 ,nvl(vr_nrdctabb,0)
                 ,nvl(vr_nrdctitg,' ')
                 ,nvl(vr_nrdocmto,0)
                 ,nvl(vr_cdhislcm,0)
                 ,nvl(vr_vllanmto,0)
                 ,nvl(vr_nrseqint,0)
                 ,nvl(vr_cdpesqbb,' ')
                 ,pr_cdcooper
                 ,rw_crapfdc.cdbanchq
                 ,rw_crapfdc.cdagechq
                 ,rw_crapfdc.nrctachq)
               RETURNING craplcm.nrseqdig,craplcm.cdhistor
               INTO rw_craplcm.nrseqdig,rw_craplcm.cdhistor;
               
             EXCEPTION
               WHEN vr_exc_saida THEN
                 RAISE vr_exc_saida;
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao inserir lancamento. '||sqlerrm;
             END;

             --Atualizar Lote
             BEGIN
               UPDATE craplot SET craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                                 ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                                 ,craplot.vlinfodb = nvl(craplot.vlinfodb,0) + nvl(vr_vllanmto,0)
                                 ,craplot.vlcompdb = nvl(craplot.vlcompdb,0) + nvl(vr_vllanmto,0)
                                 ,craplot.nrseqdig = nvl(rw_craplcm.nrseqdig,0)
               WHERE craplot.rowid = rw_craplot.rowid;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao inserir atualizar lote. '||sqlerrm;
             END;

             --Atualizar Folha Cheque
             BEGIN
               UPDATE crapfdc SET crapfdc.dtliqchq = rw_crapdat.dtmvtolt
                                 ,crapfdc.vlcheque = nvl(vr_vllanmto,0)
                                 ,crapfdc.cdagedep = TO_NUMBER(SUBSTR(vr_setlinha,116,4))
                                 ,crapfdc.incheque = rw_crapfdc.incheque + 5
               WHERE crapfdc.rowid = rw_crapfdc.rowid;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao inserir atualizar Folha de Cheque. '||sqlerrm;
             END;

             /* Se for devolucao de cheque verifica o indicador de
                   historico da contra-ordem. Se for 2, alimenta aux_cdalinea
                   com 28 para nao gerar taxa de devolucao */

             IF vr_indevchq IN (1,3) AND vr_cdalinea = 0 THEN
               --Selecionar Contra-ordens
               OPEN cr_crapcor (pr_cdcooper => pr_cdcooper
                               ,pr_cdbanchq => 1
                               ,pr_cdagechq => rw_crapcop.cdageitg
                               ,pr_nrctachq => vr_nrdctabb
                               ,pr_nrcheque => vr_nrdocmto
                               ,pr_flgativo => 1);
               --Posicionar primeiro registro
               FETCH cr_crapcor INTO rw_crapcor;
               --Se nao encontrou
               IF cr_crapcor%NOTFOUND THEN
                 --Fechar Cursor
                 CLOSE cr_crapcor;
                 --Montagem mensagem critica
                 vr_cdcritic:= 179;
                 vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
                 vr_dscritic:= vr_dscritic || gene0002.fn_mask_conta(vr_nrdconta)||
                               ' Docmto = '|| gene0002.fn_mask_conta(vr_nrdocmto)||
                               ' Cta Base = '||gene0002.fn_mask_conta(vr_nrdctabb);
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               ELSE
                 --Fechar Cursor
                 CLOSE cr_crapcor;
                 /* Contra Ordem Provisoria */
                 IF rw_crapcor.dtvalcor >= rw_crapdat.dtmvtolt AND
                    rw_crapcor.dtvalcor IS NOT NULL THEN
                   vr_cdalinea:= 70;
                 ELSIF rw_crapcor.cdhistor = 835 THEN
                   vr_cdalinea:= 28;
                 ELSIF rw_crapcor.cdhistor = 818 THEN
                   vr_cdalinea:= 20;
                 ELSIF rw_crapcor.cdhistor = 815 THEN
                   vr_cdalinea:= 21;
                 ELSE
                   vr_cdalinea:= 21;
                 END IF;
               END IF;
             END IF;
             --Indicador devolucao Cheque
             IF vr_indevchq > 0 THEN
               /* Se ja existir devolucao com alinea 21, gerar na com a alinea 43 */
               IF vr_cdalinea = 21 THEN
                 --Selecionar ultimo lancamento
                 FOR rw_craplcm_21 IN cr_craplcm_21 (pr_cdcooper => pr_cdcooper
                                                    ,pr_nrdconta => vr_nrdconta
                                                    ,pr_nrdocmto => vr_nrdocmto) LOOP
                   vr_cdalinea:= 43;
                   rw_craplcm.cdhistor:= rw_craplcm_21.cdhistor;
                 END LOOP;
               END IF;
               --Montar Historico Devolucao
               IF vr_indevchq = 1 THEN
                 vr_cdhisdev:= 191;
               ELSE
                 vr_cdhisdev:= 78;
               END IF;
               --Gerar devolucao Cheque
               CHEQ0001.pc_gera_devolucao_cheque (pr_cdcooper => pr_cdcooper
                                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                 ,pr_cdbccxlt => 1 /*banco brasil*/
                                                 ,pr_cdbcoctl => 1 /*banco brasil*/
                                                 ,pr_inchqdev => vr_indevchq
                                                 ,pr_nrdconta => vr_nrdconta
                                                 ,pr_nrdocmto => vr_nrdocmto
                                                 ,pr_nrdctitg => vr_nrdctitg
                                                 ,pr_vllanmto => vr_vllanmto
                                                 ,pr_cdalinea => vr_cdalinea
                                                 ,pr_cdhistor => vr_cdhisdev
                                                 ,pr_cdoperad => '1'
                                                 ,pr_cdagechq => rw_crapcop.cdageitg
                                                 ,pr_nrctachq => vr_nrdctabb
                                                 ,pr_cdprogra => vr_cdprogra
                                                 ,pr_nrdrecid => 0
                                                 ,pr_vlchqvlb => vr_vlchqvlb
                                                 ,pr_cdcritic => vr_cdcritic2
                                                 ,pr_des_erro => vr_dscritic2);
               --Se ocorreu erro
               IF nvl(vr_cdcritic2,0) <> 0 OR trim(vr_dscritic2) IS NOT NULL THEN
                 vr_cdcritic:= vr_cdcritic2;
                 --Montar mensagem erro
                 vr_dscritic:= vr_dscritic2 ||'CONTA '||vr_nrdconta||
                                             ' DOCMTO '||vr_nrdocmto||
                                             ' CTA BASE '||vr_nrdctabb;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               END IF;
             END IF;
             --Verificar se o Historico Existe
             IF NOT vr_tab_craphis.EXISTS(rw_craplcm.cdhistor) THEN
               vr_cdcritic:= 80;
               vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
               --Montar mensagem erro
               vr_dscritic:= vr_dscritic ||'HST = '||gene0002.fn_mask(rw_craplcm.cdhistor,'9999');
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;
             /*  Debitos  */
             IF vr_tab_craphis(rw_craplcm.cdhistor) = 'D' THEN
               --Se nao existir parametro conta integracao BB
               IF vr_rowid_debito IS NULL THEN
                 --Selecionar valor tabela parametro dos debitos
                 OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                                 ,pr_nmsistem => 'CRED'
                                 ,pr_tptabela => 'COMPBB'
                                 ,pr_cdempres => 0
                                 ,pr_cdacesso => vr_rel_nrdctabb
                                 ,pr_tpregist => 1);
                 --Posicionar no primeiro registro
                 FETCH cr_craptab INTO rw_craptab;
                 --Se nao encontrou
                 IF cr_craptab%FOUND THEN
                   vr_rowid_debito:= rw_craptab.rowid;
                   vr_dstextab_debito:= rw_craptab.dstextab;
                 ELSE
                   BEGIN
                     INSERT INTO craptab
                       (craptab.nmsistem
                       ,craptab.tptabela
                       ,craptab.cdempres
                       ,craptab.cdacesso
                       ,craptab.tpregist
                       ,craptab.cdcooper
                       ,craptab.dstextab)
                     VALUES
                       ('CRED'
                       ,'COMPBB'
                       ,0
                       ,nvl(to_char(vr_rel_nrdctabb),' ')
                       ,1
                       ,pr_cdcooper
                       ,to_char(0,'fm000000000000d00')||' '||to_char(0,'fm000000'))
                      RETURNING ROWID,dstextab
                      INTO vr_rowid_debito, vr_dstextab_debito;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir debito na craptab. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_saida;
                   END;
                 END IF;

                 -- Se cursor está aberto -- Renato - supero - 25/04
                 IF cr_craptab%ISOPEN THEN
                   CLOSE cr_craptab; -- Fechar o cursor
                 END IF;
               END IF;

               --Atualizar valor compensado
               vr_tot_vlcompdb:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab_debito,01,15));
               vr_tot_qtcompdb:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab_debito,17,06));
               vr_tot_vlcompdb:= nvl(vr_tot_vlcompdb,0) + vr_vllanmto;
               vr_tot_qtcompdb:= nvl(vr_tot_qtcompdb,0) + 1;
               BEGIN
                 UPDATE craptab SET craptab.dstextab = to_char(vr_tot_vlcompdb,'fm000000000000d00')||' '||
                                                       to_char(vr_tot_qtcompdb,'fm000000')
                 WHERE rowid = vr_rowid_debito
                 RETURNING dstextab
                 INTO vr_dstextab_debito;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao atualizar valor compensado na tabela craptab. '||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_saida;
               END;
             END IF; --Debito
           ELSIF vr_flgentra AND vr_flgdepos THEN
             --Verificar se o Historico Existe
             IF NOT vr_tab_craphis.EXISTS(vr_cdhistor) THEN
               vr_cdcritic:= 80;
               vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
               --Montar mensagem erro
               vr_dscritic:= vr_dscritic ||'HST = '||gene0002.fn_mask(vr_cdhistor,'9999');
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;
             IF vr_cdhistor = 170 THEN
               BEGIN
                 INSERT INTO crapdpb
                   (crapdpb.dtmvtolt
                   ,crapdpb.cdagenci
                   ,crapdpb.cdbccxlt
                   ,crapdpb.nrdolote
                   ,crapdpb.nrdconta
                   ,crapdpb.dtliblan
                   ,crapdpb.cdhistor
                   ,crapdpb.nrdocmto
                   ,crapdpb.vllanmto
                   ,crapdpb.inlibera
                   ,crapdpb.cdcooper)
                 VALUES
                   (rw_craplot.dtmvtolt
                   ,rw_craplot.cdagenci
                   ,rw_craplot.cdbccxlt
                   ,rw_craplot.nrdolote
                   ,nvl(vr_nrdconta,0)
                   ,vr_dtliblan
                   ,nvl(vr_cdhistor,0)
                   ,nvl(vr_nrdocmto,0)
                   ,nvl(vr_vllanmto,0)
                   ,1
                   ,pr_cdcooper);
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao atualizar valor debito na tabela craptab. '||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_saida;
               END;
             END IF;
             --Inserir Lancamento
             BEGIN
/*
               lanc0001.pc_gerar_lancamento_conta(
                                 pr_dtmvtolt => rw_craplot.dtmvtolt,
                                 pr_dtrefere => vr_dtleiarq,
                                 pr_cdagenci => rw_craplot.cdagenci,
                                 pr_cdbccxlt => rw_craplot.cdbccxlt,
                                 pr_nrdolote => rw_craplot.nrdolote,
                                 pr_nrdconta => nvl(vr_nrdconta,0),
                                 pr_nrdctabb => nvl(vr_nrdctabb,0),
                                 pr_nrdctitg => nvl(vr_nrdctitg,' '),
                                 pr_nrdocmto => nvl(vr_nrdocmto,0),
                                 pr_cdhistor => nvl(vr_cdhistor,0),
                                 pr_vllanmto => nvl(vr_vllanmto,0),
                                 pr_nrseqdig => nvl(vr_nrseqint,0),
                                 pr_cdpesqbb => nvl(vr_cdpesqbb,' '),
                                 pr_cdcooper => pr_cdcooper,
                                 pr_tab_retorno => vr_tab_retorno,
                                 pr_incrineg => vr_incrineg,
                                 pr_cdcritic => vr_cdcritic,
                                 pr_dscritic => vr_dscritic);
               if (nvl(vr_cdcritic,0) <> 0 or vr_dscritic is not null) then
                 RAISE vr_exc_saida;
               end if;
               rw_craplcm.nrseqdig:=nvl(vr_nrseqint,0);
               rw_craplcm.cdhistor:=nvl(vr_cdhistor,0);               
               */

               --grava na pl pra mandar email tiago;
               vr_flbloque := 0;

               pc_ver_bloqueio(pr_cdcooper => pr_cdcooper
                              ,pr_cdhistor => nvl(vr_cdhistor,0)
                              ,pr_nrdconta => nvl(vr_nrdconta,0)
                              ,pr_flbloque => vr_flbloque );

               IF vr_flbloque = 1 THEN

                 vr_tab_conta_blq(vr_contablq).cdcooper := pr_cdcooper;
                 vr_tab_conta_blq(vr_contablq).nrdconta := nvl(vr_nrdconta,0);
                 vr_tab_conta_blq(vr_contablq).cdhistor := nvl(vr_cdhistor,0);
                 vr_tab_conta_blq(vr_contablq).vllanmto := nvl(vr_vllanmto,0);

                 vr_contablq := vr_contablq + 1;
                 
               END IF;

               
               INSERT INTO craplcm
                 (craplcm.dtmvtolt
                 ,craplcm.dtrefere
                 ,craplcm.cdagenci
                 ,craplcm.cdbccxlt
                 ,craplcm.nrdolote
                 ,craplcm.nrdconta
                 ,craplcm.nrdctabb
                 ,craplcm.nrdocmto
                 ,craplcm.nrdctitg
                 ,craplcm.cdhistor
                 ,craplcm.vllanmto
                 ,craplcm.nrseqdig
                 ,craplcm.cdpesqbb
                 ,craplcm.cdcooper)
               VALUES
                 (rw_craplot.dtmvtolt
                 ,vr_dtleiarq
                 ,rw_craplot.cdagenci
                 ,rw_craplot.cdbccxlt
                 ,rw_craplot.nrdolote
                 ,nvl(vr_nrdconta,0)
                 ,nvl(vr_nrdctabb,0)
                 ,nvl(vr_nrdocmto,0)
                 ,nvl(vr_nrdctitg,' ')
                 ,nvl(vr_cdhistor,0)
                 ,nvl(vr_vllanmto,0)
                 ,nvl(vr_nrseqint,0)
                 ,nvl(vr_cdpesqbb,' ')
                 ,pr_cdcooper)
               RETURNING craplcm.nrseqdig,craplcm.cdhistor
               INTO rw_craplcm.nrseqdig,rw_craplcm.cdhistor;

             EXCEPTION
               WHEN vr_exc_saida THEN
                 RAISE vr_exc_saida;
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao inserir lancamento debito. '||sqlerrm;
             END;
             --Atualizar Lote
             BEGIN
               UPDATE craplot SET craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                                 ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                                 ,craplot.vlinfocr = nvl(craplot.vlinfocr,0) + vr_vllanmto
                                 ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + vr_vllanmto
                                 ,craplot.nrseqdig = nvl(rw_craplcm.nrseqdig,0)
               WHERE craplot.rowid = rw_craplot.rowid;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao atualizar lote debito. '||sqlerrm;
             END;

             /*  Creditos  */
             IF vr_tab_craphis(vr_cdhistor) = 'C' THEN
               --Se nao existir parametro conta integracao BB
               IF vr_rowid_credito IS NULL THEN
                 --Selecionar valor tabela parametro dos debitos
                 OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                                 ,pr_nmsistem => 'CRED'
                                 ,pr_tptabela => 'COMPBB'
                                 ,pr_cdempres => 0
                                 ,pr_cdacesso => vr_rel_nrdctabb
                                 ,pr_tpregist => 2);
                 --Posicionar no primeiro registro
                 FETCH cr_craptab INTO rw_craptab;
                 --Se nao encontrou
                 IF cr_craptab%FOUND THEN
                   vr_rowid_credito:= rw_craptab.rowid;
                   vr_dstextab_credito:= rw_craptab.dstextab;
                 ELSE
                   BEGIN
                     INSERT INTO craptab
                       (craptab.nmsistem
                       ,craptab.tptabela
                       ,craptab.cdempres
                       ,craptab.cdacesso
                       ,craptab.tpregist
                       ,craptab.cdcooper
                       ,craptab.dstextab)
                     VALUES
                       ('CRED'
                       ,'COMPBB'
                       ,0
                       ,nvl(to_char(vr_rel_nrdctabb),' ')
                       ,2
                       ,pr_cdcooper
                       ,to_char(0,'fm000000000000d00')||' '||to_char(0,'fm000000'))
                      RETURNING ROWID,dstextab
                      INTO vr_rowid_credito,vr_dstextab_credito;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir credito na craptab. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_saida;
                   END;
                 END IF;
                 --Fechar Cursor
                 IF cr_craptab%ISOPEN THEN
                   CLOSE cr_craptab;
                 END IF;
               END IF; --vr_rowid_credito

               --Atualizar valor compensado
               vr_tot_vlcompcr:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab_credito,01,15));
               vr_tot_qtcompcr:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab_credito,17,06));
               vr_tot_vlcompcr:= nvl(vr_tot_vlcompcr,0) + vr_vllanmto;
               vr_tot_qtcompcr:= nvl(vr_tot_qtcompcr,0) + 1;
               BEGIN
                 UPDATE craptab SET craptab.dstextab = to_char(vr_tot_vlcompcr,'fm000000000000d00')||' '||
                                                       to_char(vr_tot_qtcompcr,'fm000000')
                 WHERE rowid = vr_rowid_credito
                 RETURNING dstextab
                 INTO vr_dstextab_credito;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao atualizar valor credito na tabela craptab. '||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_saida;
               END;
             END IF;
           ELSIF vr_flgentra AND (vr_flgestor OR vr_flgdebit OR vr_flgdevol) THEN
             --Verificar se o Historico Existe
             IF NOT vr_tab_craphis.EXISTS(vr_cdhistor) THEN
               vr_cdcritic:= 80;
               vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
               --Montar mensagem erro
               vr_dscritic:= vr_dscritic ||'HST = '||gene0002.fn_mask(vr_cdhistor,'9999');
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;
             --Mudar historico para 290 se for 297
             IF vr_cdhistor = 297 THEN
               vr_cdhistor:= 290;
             ELSIF vr_cdhistor NOT IN (351,611,613,614,658,668,661,471,662) THEN
               vr_cdhistor:= 290;
             END IF;
             --Inserir Lancamento
             BEGIN

               --grava na pl pra mandar email tiago;
               vr_flbloque := 0;

               pc_ver_bloqueio(pr_cdcooper => pr_cdcooper
                              ,pr_cdhistor => nvl(vr_cdhistor,0)
                              ,pr_nrdconta => nvl(vr_nrdconta,0)
                              ,pr_flbloque => vr_flbloque );

               IF vr_flbloque = 1 THEN

                 vr_tab_conta_blq(vr_contablq).cdcooper := pr_cdcooper;
                 vr_tab_conta_blq(vr_contablq).nrdconta := nvl(vr_nrdconta,0);
                 vr_tab_conta_blq(vr_contablq).cdhistor := nvl(vr_cdhistor,0);
                 vr_tab_conta_blq(vr_contablq).vllanmto := nvl(vr_vllanmto,0);

                 vr_contablq := vr_contablq + 1;
                 
               END IF;

               INSERT INTO craplcm
                 (craplcm.dtmvtolt
                 ,craplcm.dtrefere
                 ,craplcm.cdagenci
                 ,craplcm.cdbccxlt
                 ,craplcm.nrdolote
                 ,craplcm.nrdconta
                 ,craplcm.nrdctabb
                 ,craplcm.nrdocmto
                 ,craplcm.nrdctitg
                 ,craplcm.cdhistor
                 ,craplcm.vllanmto
                 ,craplcm.nrseqdig
                 ,craplcm.cdpesqbb
                 ,craplcm.cdcooper
                 ,craplcm.dsidenti)
               VALUES
                 (rw_craplot.dtmvtolt
                 ,vr_dtleiarq
                 ,rw_craplot.cdagenci
                 ,rw_craplot.cdbccxlt
                 ,rw_craplot.nrdolote
                 ,nvl(vr_nrdconta,0)
                 ,nvl(vr_nrdctabb,0)
                 ,nvl(vr_nrdocmto,0)
                 ,nvl(vr_nrdctitg,' ')
                 ,nvl(vr_cdhistor,0)
                 ,nvl(vr_vllanmto,0)
                 ,nvl(vr_nrseqint,0)
                 ,nvl(vr_cdpesqbb,' ')
                 ,nvl(pr_cdcooper,0)
                 ,nvl(vr_dsidenti,' '))
               RETURNING craplcm.nrseqdig,craplcm.cdhistor
               INTO rw_craplcm.nrseqdig,rw_craplcm.cdhistor;

             EXCEPTION
               
               WHEN vr_exc_saida THEN
                 RAISE vr_exc_saida;
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao inserir lancamento debito. '||sqlerrm;
             END;
             --Atualizar Lote
             BEGIN
               UPDATE craplot SET craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                                 ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                                 ,craplot.vlinfodb = nvl(craplot.vlinfodb,0) + vr_vllanmto
                                 ,craplot.vlcompdb = nvl(craplot.vlcompdb,0) + vr_vllanmto
                                 ,craplot.nrseqdig = nvl(rw_craplcm.nrseqdig,0)
               WHERE craplot.rowid = rw_craplot.rowid;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao atualizar lote debito. '||sqlerrm;
             END;

             /*  Debitos   */
             IF vr_tab_craphis(vr_cdhistor) = 'D' THEN
               --Se nao existir parametro conta integracao BB
               IF vr_rowid_debito IS NULL THEN
                 --Selecionar valor tabela parametro dos debitos
                 OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                                 ,pr_nmsistem => 'CRED'
                                 ,pr_tptabela => 'COMPBB'
                                 ,pr_cdempres => 0
                                 ,pr_cdacesso => vr_rel_nrdctabb
                                 ,pr_tpregist => 1);
                 --Posicionar no primeiro registro
                 FETCH cr_craptab INTO rw_craptab;
                 --Se nao encontrou
                 IF cr_craptab%FOUND THEN
                   vr_rowid_debito:= rw_craptab.rowid;
                   vr_dstextab_debito:= rw_craptab.dstextab;
                 ELSE
                   --Fechar Cursor
                   CLOSE cr_craptab;
                   BEGIN
                     INSERT INTO craptab
                       (craptab.nmsistem
                       ,craptab.tptabela
                       ,craptab.cdempres
                       ,craptab.cdacesso
                       ,craptab.tpregist
                       ,craptab.cdcooper
                       ,craptab.dstextab)
                     VALUES
                       ('CRED'
                       ,'COMPBB'
                       ,0
                       ,nvl(to_char(vr_rel_nrdctabb),' ')
                       ,1
                       ,pr_cdcooper
                       ,to_char(0,'fm000000000000d00')||' '||to_char(0,'fm000000'))
                      RETURNING ROWID,dstextab
                      INTO vr_rowid_debito, vr_dstextab_debito;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir debito na craptab. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_saida;
                   END;
                 END IF;
                 --Fechar Cursor
                 IF cr_craptab%ISOPEN THEN
                   CLOSE cr_craptab;
                 END IF;
               END IF; --vr_rowid_debito

               --Atualizar valor compensado
               vr_tot_vlcompdb:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab_debito,01,15));
               vr_tot_qtcompdb:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab_debito,17,06));
               vr_tot_vlcompdb:= nvl(vr_tot_vlcompdb,0) + vr_vllanmto;
               vr_tot_qtcompdb:= nvl(vr_tot_qtcompdb,0) + 1;
               BEGIN
                 UPDATE craptab SET craptab.dstextab = to_char(vr_tot_vlcompdb,'fm000000000000d00')||' '||
                                                       to_char(vr_tot_qtcompdb,'fm000000')
                 WHERE rowid = vr_rowid_debito
                 RETURNING dstextab INTO vr_dstextab_debito;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao atualizar valor compensado na tabela craptab. '||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_saida;
               END;
             END IF;
           ELSE
             IF vr_indebcre = 'D' THEN
               --Se nao existir parametro conta integracao BB
               IF vr_rowid_debito_9 IS NULL THEN
                 --Selecionar valor tabela parametro dos debitos
                 OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                                 ,pr_nmsistem => 'CRED'
                                 ,pr_tptabela => 'COMPBB'
                                 ,pr_cdempres => 0
                                 ,pr_cdacesso => '99999999'
                                 ,pr_tpregist => 1);
                 --Posicionar no primeiro registro
                 FETCH cr_craptab INTO rw_craptab;
                 --Se nao encontrou
                 IF cr_craptab%FOUND THEN
                   vr_dstextab_debito_9:= rw_craptab.dstextab;
                   vr_rowid_debito_9:= rw_craptab.rowid;
                 ELSE
                   --Fechar Cursor
                   CLOSE cr_craptab;
                   BEGIN
                     INSERT INTO craptab
                       (craptab.nmsistem
                       ,craptab.tptabela
                       ,craptab.cdempres
                       ,craptab.cdacesso
                       ,craptab.tpregist
                       ,craptab.cdcooper
                       ,craptab.dstextab)
                     VALUES
                       ('CRED'
                       ,'COMPBB'
                       ,0
                       ,'99999999'
                       ,1
                       ,pr_cdcooper
                       ,to_char(0,'fm000000000000d00')||' '||to_char(0,'fm000000'))
                      RETURNING ROWID,dstextab
                      INTO vr_rowid_debito_9, vr_dstextab_debito_9;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir debito na craptab. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_saida;
                   END;
                 END IF;
                 --Fechar Cursor
                 IF cr_craptab%ISOPEN THEN
                   CLOSE cr_craptab;
                 END IF;
               END IF; --vr_rowid_debito_9

               --Atualizar valor compensado
               vr_tot_vlcompdb:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab_debito_9,01,15));
               vr_tot_qtcompdb:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab_debito_9,17,06));
               vr_tot_vlcompdb:= nvl(vr_tot_vlcompdb,0) + vr_vllanmto;
               vr_tot_qtcompdb:= nvl(vr_tot_qtcompdb,0) + 1;
               BEGIN
                 UPDATE craptab SET craptab.dstextab = to_char(vr_tot_vlcompdb,'fm000000000000d00')||' '||
                                                       to_char(vr_tot_qtcompdb,'fm000000')
                 WHERE rowid = vr_rowid_debito_9
                 RETURNING dstextab
                 INTO vr_dstextab_debito_9;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao atualizar valor compensado na tabela craptab. '||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_saida;
               END;
             ELSIF vr_indebcre = 'C' THEN
               --Se nao existir parametro conta integracao BB
               IF vr_rowid_credito_9 IS NULL THEN
                 --Selecionar valor tabela parametro dos creditos
                 OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                                 ,pr_nmsistem => 'CRED'
                                 ,pr_tptabela => 'COMPBB'
                                 ,pr_cdempres => 0
                                 ,pr_cdacesso => '99999999'
                                 ,pr_tpregist => 2);
                 --Posicionar no primeiro registro
                 FETCH cr_craptab INTO rw_craptab;
                 --Se nao encontrou
                 IF cr_craptab%FOUND THEN
                   vr_dstextab_credito_9:= rw_craptab.dstextab;
                   vr_rowid_credito_9:= rw_craptab.rowid;
                 ELSE
                   --Fechar Cursor
                   CLOSE cr_craptab;
                   BEGIN
                     INSERT INTO craptab
                       (craptab.nmsistem
                       ,craptab.tptabela
                       ,craptab.cdempres
                       ,craptab.cdacesso
                       ,craptab.tpregist
                       ,craptab.cdcooper
                       ,craptab.dstextab)
                     VALUES
                       ('CRED'
                       ,'COMPBB'
                       ,0
                       ,'99999999'
                       ,2
                       ,pr_cdcooper
                       ,to_char(0,'fm000000000000d00')||' '||to_char(0,'fm000000'))
                      RETURNING ROWID,dstextab
                      INTO vr_rowid_credito_9,vr_dstextab_credito_9;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir credito na craptab. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_saida;
                   END;
                 END IF;
                 --Fechar Cursor
                 IF cr_craptab%ISOPEN THEN
                   CLOSE cr_craptab;
                 END IF;
               END IF; --vr_rowid_credito_9

               --Atualizar valor compensado
               vr_tot_vlcompcr:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab_credito_9,01,15));
               vr_tot_qtcompcr:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab_credito_9,17,06));
               vr_tot_vlcompcr:= nvl(vr_tot_vlcompcr,0) + vr_vllanmto;
               vr_tot_qtcompcr:= nvl(vr_tot_qtcompcr,0) + 1;
               BEGIN
                 UPDATE craptab SET craptab.dstextab = to_char(vr_tot_vlcompcr,'fm000000000000d00')||' '||
                                                       to_char(vr_tot_qtcompcr,'fm000000')
                 WHERE rowid = vr_rowid_credito_9
                 RETURNING dstextab
                  INTO vr_dstextab_credito_9;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao atualizar valor credito na tabela craptab. '||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_saida;
               END;
             END IF;
             --Entrada para true
             vr_flgentra:= TRUE;
           END IF;

           /*    Verifica se o Lancamento eh Retroativo   */
           IF vr_dtrefere IS NOT NULL AND vr_cdcritic = 0 THEN
             --Selecionar rejeitados
             OPEN cr_craprej (pr_cdcooper => pr_cdcooper
                             ,pr_dtmvtolt => rw_craplot.dtmvtolt
                             ,pr_cdagenci => rw_craplot.cdagenci
                             ,pr_cdbccxlt => rw_craplot.cdbccxlt
                             ,pr_nrdolote => rw_craplot.nrdolote
                             ,pr_tplotmov => rw_craplot.tplotmov
                             ,pr_nrdctabb => vr_nrdctabb
                             ,pr_nrdocmto => vr_nrdocmto);
             --Posicionar primeiro registro
             FETCH cr_craprej INTO rw_craprej;
             --Se nao encontrou
             IF cr_craprej%NOTFOUND THEN
               --Fechar Cursor
               CLOSE cr_craprej;
               --Inserir registro
               BEGIN
                 INSERT INTO craprej
                   (craprej.dtmvtolt
                   ,craprej.cdagenci
                   ,craprej.cdbccxlt
                   ,craprej.nrdolote
                   ,craprej.tplotmov
                   ,craprej.nrdctabb
                   ,craprej.nrdocmto
                   ,craprej.vllanmto
                   ,craprej.indebcre
                   ,craprej.dtrefere
                   ,craprej.dshistor
                   ,craprej.cdcritic
                   ,craprej.tpintegr
                   ,craprej.cdcooper)
                 VALUES
                   (rw_craplot.dtmvtolt
                   ,rw_craplot.cdagenci
                   ,rw_craplot.cdbccxlt
                   ,rw_craplot.nrdolote
                   ,rw_craplot.tplotmov
                   ,nvl(vr_nrdctabb,0)
                   ,nvl(vr_nrdocmto,0)
                   ,nvl(vr_vllanmto,0)
                   ,vr_indebcre
                   ,vr_dtrefere
                   ,nvl(vr_dshistor,' ')
                   ,863
                   ,vr_contaarq
                   ,pr_cdcooper);
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao inserir na tabela craprej. '||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_saida;
               END;
             END IF;
             --Fechar Cursor
             IF cr_craprej%ISOPEN THEN
               CLOSE cr_craprej;
             END IF;
           END IF;

           --Se for restart
           IF pr_flgresta = 1 THEN
             IF rw_crapres.rowid IS NULL THEN
               --Selecionar informacao restart
               OPEN cr_crapres (pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra);
               FETCH cr_crapres INTO rw_crapres;
               --Se nao encontrou
               IF cr_crapres%NOTFOUND THEN
                 --Fechar Cursor
                 CLOSE cr_crapres;
                 vr_cdcritic:= 151;
                 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               END IF;
               --Fechar Cursor
               CLOSE cr_crapres;
             ELSE
               BEGIN
                 UPDATE crapres SET crapres.nrdconta = vr_nrseqint
                 WHERE crapres.rowid = rw_crapres.rowid;
                 --Controle restart
                 vr_inrestar:= 0;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao atualizar na tabela crapres. '||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_saida;
               END;
             END IF;
           END IF;
         EXCEPTION
           WHEN vr_exc_saida THEN
             ROLLBACK to save_trans1;
             --Sair
             RAISE vr_exc_saida;
           WHEN OTHERS THEN
             ROLLBACK to save_trans1;
             vr_cdcritic:= 0;
             vr_dscritic:= sqlerrm;
             --Sair
             RAISE vr_exc_saida;
         END;
       END LOOP; --Linhas do Arquivo

       --Fechar Arquivo
       BEGIN
         gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
       EXCEPTION
         WHEN OTHERS THEN
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao fechar arquivo dados: '||vr_caminho_integra||'/'||vr_tab_nmarqint(vr_contaarq);
           --Levantar Excecao
           RAISE vr_exc_saida;
       END;

       --Arquivo nao estÃ¡ vazio
       IF NOT vr_flgarqvz THEN
         --Final
         IF NOT vr_flgfinal THEN
           vr_cdcritic:= 181;
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           --Concatenar final arquivo
           vr_dscritic := vr_dscritic || ' (Final de Arquivo)';
           --Levantar Excecao
           RAISE vr_exc_saida;
         END IF;
         /*  Emite resumo da integracao  */
         OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_cdagenci => vr_cdagenci
                         ,pr_cdbccxlt => vr_cdbccxlt
                         ,pr_nrdolote => vr_nrdolote);
         --Posicionar no proximo registro
         FETCH cr_craplot INTO rw_craplot;
         --Se nao encontrou registro
         IF cr_craplot%NOTFOUND AND vr_nrdolote > 0 THEN
           --Fechar Cursor
           CLOSE cr_craplot;
           vr_cdcritic:= 60;
           vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
           vr_dscritic:= vr_dscritic ||' COMPBB - LOTE = '||
                         gene0002.fn_mask(vr_nrdolote,'999,999');
           --Levantar Excecao
           RAISE vr_exc_saida;
         END IF;
         --Fechar Cursor
         CLOSE cr_craplot;
         --Setar flag Primeiro e erro
         vr_flgfirst:= TRUE;
         vr_flgerros:= FALSE;
         --Inicializar totais
         vr_tot_contareg:= 0;
         vr_tot_vllanmto:= 0;
         vr_tot_qtcompdb:= 0;
         vr_tot_vlcompdb:= 0;
         vr_tot_qtcompcr:= 0;
         vr_tot_vlcompcr:= 0;
         vr_tot_vllandep:= 0;
         vr_tot_qtlandep:= 0;
         vr_tot_dsintegr:= 'INTEGRADOS NA CONTA';

         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

         -- Inicilizar as informacoes do XML
         pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl414><resumos>');

         /*  Leitura dos totais compensados  */
         FOR rw_craptab_tot IN cr_craptab_tot(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'COMPBB'
                                             ,pr_cdempres => 0) LOOP
           --Se for Debito
           IF rw_craptab_tot.tpregist = 1 THEN
             vr_tot_vlcompdb:= gene0002.fn_char_para_number(SUBSTR(rw_craptab_tot.dstextab,1,15));
             vr_tot_qtcompdb:= gene0002.fn_char_para_number(SUBSTR(rw_craptab_tot.dstextab,17,6));
           ELSE
             vr_tot_vlcompcr:= gene0002.fn_char_para_number(SUBSTR(rw_craptab_tot.dstextab,1,15));
             vr_tot_qtcompcr:= gene0002.fn_char_para_number(SUBSTR(rw_craptab_tot.dstextab,17,6));
           END IF;
           --Se nao for o ultimo
           IF rw_craptab_tot.qtdreg != rw_craptab_tot.seqreg THEN
             CONTINUE;
           END IF;
           --Conta Integracao
           vr_tot_nrdctabb:= TO_NUMBER(rw_craptab_tot.cdacesso);

           --Totalizador para relatorio gerencial
           vr_ger_qtcompdb:= nvl(vr_ger_qtcompdb,0) + nvl(vr_tot_qtcompdb,0);
           vr_ger_qtcompcr:= nvl(vr_ger_qtcompcr,0) + nvl(vr_tot_qtcompcr,0);
           vr_ger_vlcompdb:= nvl(vr_ger_vlcompdb,0) + nvl(vr_tot_vlcompdb,0);
           vr_ger_vlcompcr:= nvl(vr_ger_vlcompcr,0) + nvl(vr_tot_vlcompcr,0);

           IF TO_NUMBER(rw_craptab_tot.cdacesso) = '99999999' THEN
             vr_tot_dsintegr:= 'NAO INTEGRADOS';
             vr_tot_nrdctabb:= NULL;
           END IF;

           --Montar tag saldo contabil para arquivo XML
           pc_escreve_xml
             ('<resumo>
                  <tot_dsintegr>'||vr_tot_dsintegr||'</tot_dsintegr>
                  <tot_nrdctabb>'||gene0002.fn_mask_conta(vr_tot_nrdctabb)||'</tot_nrdctabb>
                  <tot_qtcompdb>'||vr_tot_qtcompdb||'</tot_qtcompdb>
                  <tot_vlcompdb>'||vr_tot_vlcompdb||'</tot_vlcompdb>
                  <tot_qtcompcr>'||vr_tot_qtcompcr||'</tot_qtcompcr>
                  <tot_vlcompcr>'||vr_tot_vlcompcr||'</tot_vlcompcr>
               </resumo>');

           --Zerar Variaveis
           vr_tot_qtcompdb:= 0;
           vr_tot_vlcompdb:= 0;
           vr_tot_qtcompcr:= 0;
           vr_tot_vlcompcr:= 0;

         END LOOP; /*  Fim do FOR EACH  --  Leitura dos totais compensados  */

         -- Inicilizar as informacoes do XML
         pc_escreve_xml('</resumos><lista_saldos>');

         /*  Saldos bloqueados nas contas  */

         --Zerar totalizadores
         vr_ger_vlbloque:= 0;
         vr_rel_vlbloque:= 0;

         vr_index_crawdpb:= vr_tab_crawdpb.FIRST;
         WHILE vr_index_crawdpb IS NOT NULL LOOP
           --Somar valor total bloqueado
           vr_rel_vlbloque:= nvl(vr_tab_crawdpb(vr_index_crawdpb).vlblq001,0) +
                             nvl(vr_tab_crawdpb(vr_index_crawdpb).vlblq002,0) +
                             nvl(vr_tab_crawdpb(vr_index_crawdpb).vlblq003,0) +
                             nvl(vr_tab_crawdpb(vr_index_crawdpb).vlblq004,0) +
                             nvl(vr_tab_crawdpb(vr_index_crawdpb).vlblq999,0) +
                             nvl(vr_tab_crawdpb(vr_index_crawdpb).vldispon,0);
           --Total gerencial
           vr_ger_vlbloque:= nvl(vr_ger_vlbloque,0) + vr_rel_vlbloque;
           --Montar tag saldo contabil para arquivo XML
           pc_escreve_xml
             ('<saldo>
                  <nrdctabb>'||gene0002.fn_mask_conta(vr_index_crawdpb)||'</nrdctabb>
                  <vldispon>'||To_char(nvl(vr_tab_crawdpb(vr_index_crawdpb).vldispon,0),'fm999g999g990d00')||'</vldispon>
                  <vlblq001>'||To_Char(nvl(vr_tab_crawdpb(vr_index_crawdpb).vlblq001,0),'fm999g999g990d00')||'</vlblq001>
                  <vlblq002>'||To_Char(nvl(vr_tab_crawdpb(vr_index_crawdpb).vlblq002,0),'fm999g999g990d00')||'</vlblq002>
                  <vlblq003>'||To_Char(nvl(vr_tab_crawdpb(vr_index_crawdpb).vlblq003,0),'fm999g999g990d00')||'</vlblq003>
                  <vlblq004>'||To_Char(nvl(vr_tab_crawdpb(vr_index_crawdpb).vlblq004,0),'fm999g999g990d00')||'</vlblq004>
                  <vlblq999>'||To_Char(nvl(vr_tab_crawdpb(vr_index_crawdpb).vlblq999,0),'fm999g999g990d00')||'</vlblq999>
                  <vlbloque>'||To_Char(nvl(vr_rel_vlbloque,0),'fm999g999g990d00')||'</vlbloque>
               </saldo>');
           --Verificar final tabela memoria
           vr_index_crawdpb:= vr_tab_crawdpb.NEXT(vr_index_crawdpb);
         END LOOP;
         -- Inicilizar as informacoes do XML
         pc_escreve_xml('</lista_saldos><rejeitados>');

         /* Gravacao de dados no banco GENERICO - Relatorios Gerenciais */
         OPEN cr_gntotpl (pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
         --Posicionar primeiro registro
         FETCH cr_gntotpl INTO rw_gntotpl;
         --Se nao Encontrou
         IF cr_gntotpl%NOTFOUND THEN
           --Fechar Cursor
           CLOSE cr_gntotpl;
           --Criar registro
           BEGIN
             INSERT INTO gntotpl
               (gntotpl.cdcooper
               ,gntotpl.dtmvtolt
               ,gntotpl.vlslddbb)
             VALUES
               (pr_cdcooper
               ,rw_crapdat.dtmvtolt
               ,vr_ger_vlbloque);
           EXCEPTION
             WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao atualizar tabela gntotpl. '||sqlerrm;
               --Levantar Excecao
               RAISE vr_exc_saida;
           END;
         ELSE
           --Fechar Cursor
           CLOSE cr_gntotpl;
           BEGIN
             UPDATE gntotpl SET gntotpl.vlslddbb = gntotpl.vlslddbb + vr_ger_vlbloque
             WHERE gntotpl.rowid = rw_gntotpl.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao atualizar tabela gntotpl. '||sqlerrm;
               --Levantar Excecao
               RAISE vr_exc_saida;
           END;
         END IF;
         --Fechar Cursor
         IF cr_gntotpl%ISOPEN THEN
           CLOSE cr_gntotpl;
         END IF;

         vr_cdempres := -1 ;

         /* Rejeitados */
         FOR rw_craprej_tot IN cr_craprej_tot (pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                              ,pr_cdagenci => vr_cdagenci
                                              ,pr_cdbccxlt => vr_cdbccxlt
                                              ,pr_nrdolote => vr_nrdolote
                                              ,pr_tpintegr => vr_contaarq) LOOP
           /*   Utilizado para a Somatoria dos Valores de Devolucao  */
           vr_dshistor:= TRIM(SUBSTR(rw_craprej_tot.dshistor,1,15));
           
           IF INSTR(vr_dshstdev,SUBSTR(vr_dshistor,01,04)) > 0 OR 
              SUBSTR(vr_dshistor,01,04) = '0114' THEN
             --Se existir crawtot
             IF vr_tab_crawtot.EXISTS(vr_dshistor) THEN
               vr_tab_crawtot(vr_dshistor).qtlancto:= vr_tab_crawtot(vr_dshistor).qtlancto + 1;
               vr_tab_crawtot(vr_dshistor).vllancto:= vr_tab_crawtot(vr_dshistor).vllancto + rw_craprej_tot.vllanmto;
             ELSE
               vr_tab_crawtot(vr_dshistor).qtlancto:= 1;
               vr_tab_crawtot(vr_dshistor).vllancto:= rw_craprej_tot.vllanmto;
             END IF;
           END IF;
           --Se for o primeiro
           IF vr_flgfirst THEN
             
             --Inicia PL Table com lista de histórios e informações para cada um deles
             pc_inicia_historico;                                                          
           
             vr_flgfirst:= FALSE;
             vr_flgerros:= TRUE;
           END IF;
           --Critica diferente do rejeitado
           IF vr_cdcritic <> rw_craprej_tot.cdcritic or
              vr_cdempres <> rw_craprej_tot.cdempres THEN
             --Critica recebe o rejeitado
             vr_cdcritic:= rw_craprej_tot.cdcritic;
             vr_cdempres:= rw_craprej_tot.cdempres;

             IF vr_cdcritic = 999 then

               -- buscar dados da coop. antiga
               OPEN  cr_craptco_cop (pr_cdcooper => rw_craprej_tot.cdcooper,
                                     pr_crctaant => rw_craprej_tot.nrdconta,
                                     -- usado campo cdempres para guardar cdcopant
                                     pr_cdcopant => rw_craprej_tot.cdempres);
               FETCH cr_craptco_cop INTO rw_craptco_cop;

               IF cr_craptco_cop%FOUND THEN
                 vr_dscritic := 'Cooperado da '||rw_craptco_cop.nmrescop;
               ELSE
                vr_dscritic := 'Cooperativa nao localizada';
               END IF;
               CLOSE cr_craptco_cop;

             ELSE
               --Buscar descricao critica
               vr_dscritic:= substr(gene0001.fn_busca_critica(vr_cdcritic),7,50);
             END IF;
             IF rw_craprej_tot.cdcritic IN (96,137,172,257,287,439,508,608,981) THEN
               vr_dscritic:= '* '||vr_dscritic;
             END IF;
           END IF;
           IF rw_craprej_tot.cdcritic NOT IN (96,137,172,257,287,439,508,608,762,981) THEN
             --Incrementar total registros
             vr_tot_contareg:= 1;
           ELSE
             vr_tot_contareg:= 0;
           END IF;
           IF vr_cdcritic IN (811,757) THEN
             --Procurar erro da tabela de memoria tabela
             FOR idx IN vr_tab_craprej.FIRST..vr_tab_craprej.LAST LOOP
               IF vr_tab_craprej(idx).cdcooper = rw_craprej_tot.cdcooper AND
                  vr_tab_craprej(idx).dtrefere = rw_craprej_tot.dtrefere AND
                  vr_tab_craprej(idx).nrdconta = rw_craprej_tot.nrdconta AND
                  vr_tab_craprej(idx).nrdocmto = rw_craprej_tot.nrdocmto AND
                  vr_tab_craprej(idx).vllanmto = rw_craprej_tot.vllanmto AND
                  vr_tab_craprej(idx).nrseqdig = rw_craprej_tot.nrseqdig AND
                  vr_tab_craprej(idx).cdcritic = rw_craprej_tot.cdcritic AND
                  vr_tab_craprej(idx).cdpesqbb = rw_craprej_tot.cdpesqbb THEN
                 vr_dscritic:= vr_dscritic||vr_tab_craprej(idx).dscritic;
                 --Sair do Loop
                 EXIT;
               END IF;
             END LOOP;
           END IF;

           --tratando a tec salario não integrada na relacao de criticas
           IF vr_cdcritic = 0 THEN
             vr_dscritic := 'TEC salario nao integrada.';
           END IF;

           --Montar tag saldo contabil para arquivo XML
           pc_escreve_xml
             ('<rejeitado>
                  <nrseqdig>'||gene0002.fn_mask(rw_craprej_tot.nrseqdig,'zzz.zz9')||'</nrseqdig>
                  <dshistor>'||substr(rw_craprej_tot.dshistor,1,15)||'</dshistor>
                  <nrdctabb>'||gene0002.fn_mask_conta(rw_craprej_tot.nrdctabb)||'</nrdctabb>
                  <dtrefere>'||rw_craprej_tot.dtrefere||'</dtrefere>
                  <nrdocmto>'||gene0002.fn_mask(rw_craprej_tot.nrdocmto,'zzzzzz.zzz.9')||'</nrdocmto>
                  <cdpesqbb>'||substr(rw_craprej_tot.cdpesqbb,1,13)||'</cdpesqbb>
                  <vllanmto>'||to_char(rw_craprej_tot.vllanmto,'fm99999g999g990d00')||'</vllanmto>
                  <indebcre>'||rw_craprej_tot.indebcre||'</indebcre>
                  <nrdconta>'||gene0002.fn_mask_conta(rw_craprej_tot.nrdconta)||'</nrdconta>
                  <dscritic>'||substr(vr_dscritic,1,29)||'</dscritic>
                  <contareg>'||vr_tot_contareg||'</contareg>
               </rejeitado>');
           
           --Se histórico está na PL Table gera linha no arquivo para Radar/Matera    
           IF vr_tab_historico.exists(vr_dshistor) THEN   
             
             vr_aux_contador := vr_aux_contador + 1; 
             
             IF vr_aux_contador = 1 THEN

               -- Busca do diretório onde ficará o arquivo
               vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                         pr_cdcooper => pr_cdcooper,
                                                         pr_nmsubdir => 'contab');
           
               -- Busca do diretório onde o Radar ou Matera pegará o arquivo                                          
               vr_nom_dir_copia := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                            ,pr_cdcooper => 0
                                                            ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
                                                            
               
               vr_nmarquiv := to_char(rw_crapdat.dtmvtolt,'YYMMDD')||'_'||LPAD(pr_cdcooper,2,0)||'_CRITICAITG.txt';
               -- Tenta abrir o arquivo de log em modo gravacao
               gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                                       ,pr_nmarquiv => vr_nmarquiv          --> Nome do arquivo
                                       ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                                       ,pr_utlfileh => vr_input_filectb     --> Handle do arquivo aberto
                                       ,pr_des_erro => vr_dscritic);        --> Erro
               
               IF vr_dscritic IS NOT NULL THEN
                 vr_cdcritic := 0; 
                 RAISE vr_exc_saida;
               END IF;
                 
             END IF;
           
             vr_setlinha_ctb := fn_set_cabecalho('20'
                                                ,rw_crapdat.dtmvtolt
                                                ,rw_crapdat.dtmvtolt
                                                ,vr_tab_historico(vr_dshistor).nrctaori
                                                ,vr_tab_historico(vr_dshistor).nrctades
                                                ,rw_craprej_tot.vllanmto
                                                ,replace(replace(vr_tab_historico(vr_dshistor).dsrefere,
                                                                'pr_nrdctabb',
                                                                 TRIM(gene0002.fn_mask_conta(vr_rel_nrdctabb))),
                                                         'pr_nrctaitg',
                                                         TRIM(gene0002.fn_mask_conta(rw_craprej_tot.nrdctabb))));
                                               
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_filectb --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha_ctb); --> Texto para escrita
             
             --Criar linha gerencial para cada Agencia
             IF vr_dshistor = '0231TAR MANUT C'THEN
               
               --Ratear valor igualmente para cada agencia para gera linha gerencial
               FOR rw_crapage IN cr_crapage LOOP
                 --Calcula Rateio
                 IF rw_crapage.linha = 1 THEN  
                   vr_vllctage := ROUND((rw_craprej_tot.vllanmto / rw_crapage.qt_agencia),2);  
                 END IF; 
                 
                 --Verifica se valor rateado acumulado não fica maior ou menor que total do lançamento
                 --Caso haja diferença acerta no último PA
                 IF rw_crapage.qt_agencia = rw_crapage.linha THEN
                   IF (vr_vllctacm + vr_vllctage) <> rw_craprej_tot.vllanmto THEN
                     vr_vllctage := rw_craprej_tot.vllanmto - vr_vllctacm;
                   END IF; 
                 END IF; 
                 
                 --Gera linha gerencial
                 vr_setlinha_ctb := fn_set_gerencial(pr_cdagenci => rw_crapage.cdagenci
                                                    ,pr_vlagenci => vr_vllctage);
                                                    
                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_filectb --> Handle do arquivo aberto
                                               ,pr_des_text => vr_setlinha_ctb); --> Texto para escrita                                                    
                 
                 
                 vr_vllctacm := vr_vllctacm + vr_vllctage;
                 
               END LOOP;  
               
             END IF;
                     
           END IF;           
           
         END LOOP;
         
         -- Fechar Arquivo
         IF vr_aux_contador > 0 THEN
           BEGIN
              gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_filectb); --> Handle do arquivo aberto;
           EXCEPTION
              WHEN OTHERS THEN
              -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
              vr_cdcritic := 0;
              vr_dscritic := 'Problema ao fechar o arquivo <'||vr_nom_diretorio||'/'||vr_nmarquiv||'>: ' || SQLERRM;
              RAISE vr_exc_saida;
           END;
             
          -- Copia o arquivo gerado para o diretório final convertendo para DOS
          gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarquiv||' > '||vr_nom_dir_copia||'/'||vr_nmarquiv||' 2>/dev/null',
                                      pr_typ_saida   => vr_typ_said,
                                      pr_des_saida   => vr_dscritic);
          -- Testar erro
          if vr_typ_said = 'ERR' then
             vr_dscritic := 'Erro ao copiar o arquivo '||vr_nmarquiv||': '||vr_dscritic;
             raise vr_exc_saida;
          end if;
        END IF;

         
         -- Inicilizar as informacoes do XML
         pc_escreve_xml('</rejeitados>');

         --Se ocorreu erros
         IF vr_flgerros THEN
           vr_tot_contareg:= 0;
           vr_tot_vllanmto:= 0;
         END IF;

         /*   Somatoria dos Valores de Lanctos. de Devolucao Rejeitados  */
         pc_escreve_xml('<soma_criticas>');
         vr_index_crawtot := vr_tab_crawtot.first;
         while vr_index_crawtot is not null loop
           pc_escreve_xml('<soma_critica>'||
                            '<dshistor>'||vr_index_crawtot||'</dshistor>'||
                            '<qtlancto>'||to_char(vr_tab_crawtot(vr_index_crawtot).qtlancto, 'fm999G990')||'</qtlancto>'||
                            '<vllancto>'||to_char(vr_tab_crawtot(vr_index_crawtot).vllancto, 'fm99999g999g990d00')||'</vllancto>'||
                          '</soma_critica>');
           vr_index_crawtot := vr_tab_crawtot.next(vr_index_crawtot);
         end loop;
         pc_escreve_xml('</soma_criticas>');

         -- Inicilizar as informacoes do XML
         pc_escreve_xml('<maiores vlmaichq="'||To_Char(vr_vlmaichq,'fm999g990d00')||'" dtmvtolt="'||
                        to_char(rw_craplot.dtmvtolt,'DD/MM/YYYY')||'" cdagenci="'||
                        rw_craplot.cdagenci||'" cdbccxlt="'||
                        rw_craplot.cdbccxlt||'" nrdolote="'||
                        To_Char(rw_craplot.nrdolote,'999g999g990')||'" qtcompln="'||
                        gene0002.fn_mask(rw_craplot.qtcompln,'z.zzz.zz9')||'" vlcompdb="'||
                        to_char(rw_craplot.vlcompdb,'fm999g999g999g990d00')||'">');
         --Indicar que nao encontrou lcm
         vr_flgcraplcm:= FALSE;
         /*  Leitura dos lancamentos integrados  --  Maiores cheques  */
         FOR rw_craplcm_tot IN cr_craplcm_tot (pr_cdcooper  => pr_cdcooper
                                              ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                              ,pr_cdagenci  => vr_cdagenci
                                              ,pr_cdbccxlt  => vr_cdbccxlt
                                              ,pr_nrdolote  => vr_nrdolote) LOOP
           --Incrementar total registros e valor
           vr_tot_contareg:= Nvl(vr_tot_contareg,0) + 1;
           vr_tot_vllanmto:= Nvl(vr_tot_vllanmto,0) + rw_craplcm_tot.vllanmto;
           --Indicar que encontrou lcm
           vr_flgcraplcm:= TRUE;
           --Montar tag saldo contabil para arquivo XML
           pc_escreve_xml
           ('<maior>
                <nrdctabb>'||gene0002.fn_mask(rw_craplcm_tot.nrdctabb,'zzzz.zzz.9')||'</nrdctabb>
                <nrdocmto>'||gene0002.fn_mask(rw_craplcm_tot.nrdocmto,'zzzz.zzz.zzz.9')||'</nrdocmto>
                <nrdconta>'||gene0002.fn_mask(rw_craplcm_tot.nrdconta,'zzzz.zzz.9')||'</nrdconta>
                <cdhistor>'||gene0002.fn_mask(rw_craplcm_tot.cdhistor,'zzz9')||'</cdhistor>
                <vllanmto>'||to_char(rw_craplcm_tot.vllanmto,'fm999g999g999g999g990d00')||'</vllanmto>
                <cdpesqbb>'||substr(rw_craplcm_tot.cdpesqbb,1,15)||'</cdpesqbb>
                <nrseqdig>'||gene0002.fn_mask(rw_craplcm_tot.nrseqdig,'zzz.zz9')||'</nrseqdig>
             </maior>');
         END LOOP;

         --Se nao encontrou lcm
         IF NOT vr_flgcraplcm THEN
           --Criar tag sem dados para imprimir cabecalho
           pc_escreve_xml
           ('<maior>
                <nrdctabb></nrdctabb>
                <nrdocmto></nrdocmto>
                <nrdconta></nrdconta>
                <cdhistor></cdhistor>
                <vllanmto></vllanmto>
                <cdpesqbb></cdpesqbb>
                <nrseqdig></nrseqdig>
             </maior>');
         END IF;

         -- Inicilizar as informacoes do XML
         pc_escreve_xml('</maiores><retroativos>');

         /*   Listagem dos Lancamentos Retroativos   */
         FOR rw_craprej_ret IN cr_craprej_ret (pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                              ,pr_cdagenci => vr_cdagenci
                                              ,pr_cdbccxlt => vr_cdbccxlt
                                              ,pr_nrdolote => vr_nrdolote
                                              ,pr_cdcritic => 863) LOOP
           --Montar tag saldo contabil para arquivo XML
           pc_escreve_xml
           ('<retroativo>
                <nrdctabb>'||gene0002.fn_mask(rw_craprej_ret.nrdctabb,'zzzz.zzz.9')||'</nrdctabb>
                <cdhistor>'||substr(rw_craprej_ret.dshistor,1,15)||'</cdhistor>
                <nrdocmto>'||gene0002.fn_mask(rw_craprej_ret.nrdocmto,'zzzz.zzz.9')||'</nrdocmto>
                <vllanmto>'||to_char(rw_craprej_ret.vllanmto,'fm999g999g999g999g990d00')||'</vllanmto>
                <indebcre>'||substr(rw_craprej_ret.indebcre,1,1)||'</indebcre>
                <dtrefere>'||rw_craprej_ret.dtrefere||'</dtrefere>
             </retroativo>');
         END LOOP;
         -- Finalizar tag XML
         pc_escreve_xml('</retroativos></crrl414>');

         --Numero Copias
         IF pr_cdcooper = 1 THEN
           vr_nrcopias:= 2;
         ELSE
           vr_nrcopias:= 1;
         END IF;

         -- Efetuar solicitacao de geracao de relatorio crrl414 --
         gene0002.pc_solicita_relato (pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl414'          --> N? base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl414.jasper'    --> Arquivo de layout do iReport
                                     ,pr_dsparams  => NULL                --> Titulo do relat?rio
                                     ,pr_dsarqsaid => vr_caminho_rl||'/'||vr_tab_nmarqimp(vr_contaarq)||'.lst' --> Arquivo final
                                     ,pr_qtcoluna  => 132                 --> 132 colunas
                                     ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                     ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                                     ,pr_nmformul  => '132dm'             --> Nome do formul?rio para impress?o
                                     ,pr_nrcopias  => vr_nrcopias         --> N?mero de c?pias
                                     ,pr_flg_gerar => 'N'                 --> gerar PDF
                                     ,pr_des_erro  => vr_dscritic);       --> Sa?da com erro
         -- Testar se houve erro
         IF vr_dscritic IS NOT NULL THEN
           -- Gerar excecao
           RAISE vr_exc_saida;
         END IF;

         -- Liberando a mem?ria alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);

         IF vr_nrdolote > 0   THEN
           vr_lot_qtcompln:= nvl(vr_ger_qtcompdb,0) + nvl(vr_ger_qtcompcr,0);
           vr_lot_vlcompdb:= nvl(vr_ger_vlcompdb,0) + nvl(vr_ger_vlcompcr,0);
         ELSE
           vr_lot_qtcompln:= 0;
           vr_lot_vlcompdb:= 0;
         END IF;
       END IF;

       --Arquivo vazio
       IF vr_flgarqvz THEN
         vr_cdcritic:= 263;
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         --Complementar mensagem
         vr_dscritic:= vr_dscritic ||' '||vr_tab_nmarqint(vr_contaarq);
         --Escrever mensagem log
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic);
       ELSE
         -- Alterado para sempre exibir a mensagem de processado com sucesso. 
         -- No log nao interessa se possui rejeitados ou nao, apenas se o arquivo foi processado
         vr_cdcritic:= 190;
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         --Complementar mensagem
         vr_dscritic:= vr_dscritic ||' '||vr_tab_nmarqint(vr_contaarq);
         --Escrever mensagem log
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic);

         vr_cdcritic := 0;
         vr_dscritic := null;
       END IF;

       -- Buscar o diretÃ³rio padrao da cooperativa conectada
       vr_caminho_salvar:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_nmsubdir => 'salvar');

       /*  Move arquivo integrado para o diretorio salvar  */
       vr_comando:= 'mv '||vr_caminho_integra||'/'||vr_tab_nmarqint(vr_contaarq)||' '||vr_caminho_salvar;

       --Executar o comando no unix
       GENE0001.pc_OScommand(pr_typ_comando => 'S'
                            ,pr_des_comando => vr_comando
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_dscritic);
       --Se ocorreu erro dar RAISE
       IF vr_typ_saida = 'ERR' THEN
         vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
         RAISE vr_exc_saida;
       END IF;

       /*  Zera registro de restart  */
       BEGIN
         UPDATE crapres SET crapres.nrdconta = 0
         WHERE crapres.rowid = rw_crapres.rowid;
       EXCEPTION
         WHEN OTHERS THEN
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao atualizar a tabela crapres. '||sqlerrm;
           --Levantar Excecao
           RAISE vr_exc_saida;
       END;

       --Zerar variaveis restart
       vr_nrctares:= 0;
       vr_inrestar:= 0;

       -- limpar temptables que serão utilizadas
       -- para leitura de outro arquivo
       vr_tab_crawdpb.DELETE;
       vr_tab_crawtot.DELETE;
       vr_tab_craprej.DELETE;


       --Salvar informacoes no banco de dados
       COMMIT;

     END LOOP; /*  Fim do DO .. TO  --  Arquivos a integrar  */

     /* Gera relatorio somente para Viacredi, SCRCRED e Transpocred */
     IF pr_cdcooper in (1,13,9) THEN
       --Executar relatorio
       pc_imprime_rel_414_99 (pr_cdcooper => pr_cdcooper
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                             ,pr_caminho  => vr_caminho_rl
                             ,pr_nmarqrel => vr_nmarqrel
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
       --Se ocorreu erro
       IF vr_cdcritic IS NOT NULL or vr_dscritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;
    END IF;

     --Zerar tabelas de memoria auxiliar
     pc_limpa_tabela;

     -- LIMPAR CRAPREJ
     BEGIN
       DELETE craprej
        WHERE craprej.cdcooper = pr_cdcooper
          AND craprej.dtmvtolt = rw_crapdat.dtmvtolt;
     EXCEPTION
       WHEN OTHERS THEN
         vr_dscritic := 'Não foi possivel limpar tabela craprej: '||SQLerrm;
         raise vr_exc_saida;
     END;

     -- Encerrar controles de restart
     btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_flgresta => pr_flgresta
                                ,pr_des_erro => vr_dscritic);
     --Se ocorreu erro
     IF vr_dscritic IS NOT NULL THEN
       --Levantar Excecao
       RAISE vr_exc_saida;
     END IF;

     
     IF vr_tab_conta_blq.COUNT() > 0 THEN

       --manda email dos debitos bloqueados tiago 
       pc_envia_email_blq (pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_nmrescop => rw_crapcop.nmrescop
                          ,pr_cdprogra => vr_cdprogra
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt);    
                          
     END IF;                          

     -- Processo OK, devemos chamar a fimprg
     btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_stprogra => pr_stprogra);

     --Salvar informacoes no banco de dados
     COMMIT;

   EXCEPTION
     WHEN vr_exc_fimprg THEN
       -- Se foi retornado apenas codigo
       IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
         -- Buscar a descricao da critica
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       -- Se foi gerada critica para envio ao log
       IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || vr_dscritic );
       END IF;
       -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);
       --Limpar parametros
       pr_cdcritic:= 0;
       pr_dscritic:= NULL;
       -- Efetuar commit pois gravaremos o que foi processo atÃ© entÃ£o
       COMMIT;
     WHEN vr_exc_saida THEN
       -- Se foi retornado apenas codigo
       IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
         -- Buscar a descricao
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       -- Devolvemos cÃ³digo e critica encontradas
       pr_cdcritic := NVL(vr_cdcritic,0);
       pr_dscritic := vr_dscritic;
       -- Efetuar rollback
       ROLLBACK;
       --Zerar tabela de memoria auxiliar
       pc_limpa_tabela;
     WHEN OTHERS THEN
       -- Efetuar retorno do erro nÃ£o tratado
       pr_cdcritic := 0;
       pr_dscritic := sqlerrm;
       -- Efetuar rollback
       ROLLBACK;
       --Zerar tabela de memoria auxiliar
       pc_limpa_tabela;
   END;
 END pc_crps444;
--################################# 444 FIM #################################################################

BEGIN 

  FOR rw_tdcoop IN cr_tdcoop LOOP
    
    PC_CRPS346 (pr_cdcooper => rw_tdcoop.cdcooper
               ,pr_flgresta => 0
               ,pr_nmtelant => 'COMPEFORA'
               ,pr_stprogra => pg_stprogra    --> Saida de termino da execucao
               ,pr_infimsol => pg_infimsol    --> Saida de termino da solicitacao
               ,pr_cdcritic => pg_cdcritic    --> Codigo da Critica
               ,pr_dscritic => pg_dscritic);  --> Descricao da Critica
  
    PC_CRPS444 ( pr_cdcooper => rw_tdcoop.cdcooper
                ,pr_flgresta => 0
                ,pr_nmtelant => 'COMPEFORA'
                ,pr_stprogra => pg_stprogra    --> Saida de termino da execucao
                ,pr_infimsol => pg_infimsol    --> Saida de termino da solicitacao
                ,pr_cdcritic => pg_cdcritic    --> Codigo da Critica
                ,pr_dscritic => pg_dscritic);  --> Descricao da Critica
  END LOOP;
  
END;
0
0
