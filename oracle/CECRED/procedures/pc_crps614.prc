CREATE OR REPLACE PROCEDURE CECRED.pc_crps614(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                             ,pr_cdoperad  IN crapope.cdoperad%TYPE  --> Codigo operador
                                             ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart                                             
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  
  /* .............................................................................

     Programa: pc_crps614 (fontes/crps614.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Fabricio
     Data    : Janeiro/2012                       Ultima atualizacao: 13/06/2018

     Dados referentes ao programa:

     Frequencia: Diario (Batch).
     Objetivo  : Criar lancamento de debito na conta do cooperado, referente
                 a mensalidade do cartao transportadora PAMCARD.

     Alteracoes: 03/02/2012 - Ajuste para debitar as mensalidades para quando 
                               for dia 1 - primeiro (Adriano).
                    
                 14/01/2014 - Alteracao referente a integracao Progress X 
                               Dataserver Oracle 
                               Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                                    
                 05/08/2014 - Alteraçăo da Nomeclatura para PA (Vanessa).
                   
                 06/04/2015 - Alterado para que as criticas 09 e 75 fossem
                               retiradas do proc_batch.log e transferidas para
                               proc_message.log acrescentando a data na frente
                               do log (SD273423 Tiago/Fabricio).
                                 
                 05/12/2017 - Arrumar leitura da crappam para buscarmos da forma
                              correta na condicao "OR", foi incluido parenteses 
                              (Lucas Ranghetti #804628)

                 30/04/2018 - Conversão Progress para PLSQL (Odirlei/AMcom)
                 
                 13/06/2018 - PRJ450 - Regulatorios de Credito - Centralizacao do lancamento em conta corrente (Fabiano B. Dias - AMcom). 
                 
  ............................................................................ */


    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS614';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    -- Tabela de retorno LANC0001 (PRJ450 13/06/2018).
    vr_tab_retorno  lanc0001.typ_reg_retorno;
    vr_incrineg     NUMBER;
    vr_fldebita     BOOLEAN;
    
    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.cdbcoctl
            ,cop.vlmenpam
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Listar debitos PAMCARD
    CURSOR cr_crappam (pr_cdcooper crapneg.cdcooper%TYPE,
                       pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                       pr_dtmvtoan crapdat.dtmvtolt%TYPE) IS
      SELECT pam.dddebpam,
             pam.nrdconta,
             pam.flgpamca
        FROM crappam pam
       WHERE pam.cdcooper = pr_cdcooper
         AND pam.flgpamca = 1 -- TRUE
         AND ((pam.dddebpam > to_char(pr_dtmvtoan,'DD') AND
               pam.dddebpam <= to_char(pr_dtmvtolt,'DD')) OR
              (pam.dddebpam = 1 AND
               pam.dddebpam = to_char(pr_dtmvtolt,'DD'))
             )
          ORDER BY pam.cdcooper, pam.nrdconta;

    --> Busca dos dados do associado 
    CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta
            ,crapass.nmprimtl
            ,crapass.inpessoa
            ,crapass.cdagenci
            ,crapass.dtdemiss
            ,crapass.nrdctitg
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
       AND   crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
 
    --Registro do tipo tabela
    rw_craplot craplot%ROWTYPE;
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------   
    
    TYPE typ_rec_relat616 
         IS RECORD(cdagenci crapass.cdagenci%TYPE,
                   nrdconta crapass.nrdconta%TYPE,
                   nmprimtl crapass.nmprimtl%TYPE);
         
    TYPE typ_tab_relat616 IS TABLE OF typ_rec_relat616
       INDEX BY VARCHAR2(20);
     
    vr_tab_relat616 typ_tab_relat616;


    ------------------------------- VARIAVEIS -------------------------------
    vr_nmarqimp   VARCHAR2(100) ; -- Nome do relatorio
    vr_nmarqlog   VARCHAR2(300) := NULL;
    vr_dddebpam   crappam.dddebpam%TYPE;
    vr_contador   NUMBER := 1;
    vr_idx        VARCHAR2(20);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_nom_direto  VARCHAR2(100);


    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
    
    --> Gerar log message
    PROCEDURE pc_gera_log_message (pr_cdcooper IN NUMBER,
                                   pr_desdelog IN VARCHAR2) IS
    BEGIN
    
      IF vr_nmarqlog IS NULL THEN
        vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                 pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
      END IF;
    
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || pr_desdelog );
    
    END pc_gera_log_message;
    
    --> Gerar Relatorio
    PROCEDURE pc_gera_relatorio_616 (pr_tab_rel616 IN typ_tab_relat616 ,
                                     pr_dddebpam   IN NUMBER,
                                     pr_vlmenpam   IN NUMBER,
                                     pr_dscritic  OUT VARCHAR2)IS
    
    
    BEGIN
    
    
      -- Leitura da PL/Table e geração do arquivo XML
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?>'||
                       '<crrl616 dddebpam="'||pr_dddebpam||'"
                                 vlmenpam="'||pr_vlmenpam||'" >');
      
    
      vr_idx := pr_tab_rel616.first;
      -- Listar dados para o relatorio
      WHILE vr_idx IS NOT NULL LOOP
        pc_escreve_xml('<registro>
                           <cdagenci>'||pr_tab_rel616(vr_idx).cdagenci                        ||'</cdagenci>
                           <nrdconta>'||gene0002.fn_mask_conta(pr_tab_rel616(vr_idx).nrdconta)||'</nrdconta>
                           <nmprimtl>'||pr_tab_rel616(vr_idx).nmprimtl                        ||'</nmprimtl>
                        </registro>');
       
        vr_idx := pr_tab_rel616.next(vr_idx);
      END LOOP;
      
      
      -- Finalizar o agrupador do relatório
      pc_escreve_xml('</crrl616>',TRUE);      
      
      vr_nmarqimp := 'crrl616_'||to_char(rw_crapdat.dtmvtolt,'DDMMRRRR')||'.lst'; -- Nome do relatorio

      -- Busca do diretório base da cooperativa para PDF
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

      -- Efetuar solicitação de geração de relatório --
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl616/registro' --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl616.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Sem parametros
                                 ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nmarqimp --> Arquivo final com código da agência
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_flg_gerar => 'N'                 --> gerar PDF
                                 ,pr_nrvergrl  => 1                   --> Versao do gerador de relatorio
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gerar relatorio crrl616: '||SQLERRM;
    END pc_gera_relatorio_616;

    
  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;

    -- Se não encontrar
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

    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

    
    vr_tab_relat616.delete;
         
    -- Listar debitos PAMCARD
    FOR rw_crappam IN cr_crappam ( pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                   pr_dtmvtoan => rw_crapdat.dtmvtoan) LOOP
                                   
      vr_dddebpam := rw_crappam.dddebpam;
      
      -- Validar cooperado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => rw_crappam.nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        --> definir critica
        vr_cdcritic := 9;
        vr_dscritic :=  gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        
        --> Gerar log message
        pc_gera_log_message (pr_cdcooper => pr_cdcooper,
                             pr_desdelog => vr_dscritic );
        
        vr_cdcritic := NULL;
        vr_dscritic := NULL;       
                      
        --> Buscar proximo registro
        continue;                     
        
      ELSE
        CLOSE cr_crapass;
      END IF;  
      
      IF rw_crapass.dtdemiss IS NOT NULL THEN
      
        --> Definir critica
        vr_cdcritic := 75;
        vr_dscritic :=  gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        
        --> Gerar log message
        pc_gera_log_message (pr_cdcooper => pr_cdcooper,
                             pr_desdelog => vr_dscritic );
        
        vr_cdcritic := NULL;
        vr_dscritic := NULL;       
                      
        --> Buscar proximo registro
        continue;
      
      END IF;

      /* Identifica se pode ou não efetuar o lançamento na conta do cooperado */
      vr_fldebita := LANC0001.fn_pode_debitar(pr_cdcooper => pr_cdcooper,
                                              pr_nrdconta => rw_crappam.nrdconta,
                                              pr_cdhistor => 1027);
      /* se não puder efetuar o lançamento */
      IF vr_fldebita = false THEN
         /*A ação CONTINUE despreza as ações dentro de um loop e segue para o próximo registro, portanto, teremos situações em que ela não poderá ser utilizada */
         continue;
      END IF;

      -- PRJ450 - 13/06/2018.
      lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       , pr_cdagenci => 1
                                       , pr_cdbccxlt => 100
                                       , pr_nrdolote => 9065
                                       , pr_nrdconta => rw_crappam.nrdconta
                                       , pr_nrdocmto => vr_contador
                                       , pr_cdhistor => 1027 --> MENSALIDADE PAMCARD
                                       , pr_nrseqdig => rw_craplot.nrseqdig--1
                                       , pr_vllanmto => rw_crapcop.vlmenpam
                                       , pr_nrdctabb => rw_crappam.nrdconta
                                       --, pr_cdpesqbb => vr_cdpeslcm
                                       --, pr_vldoipmf IN  craplcm.vldoipmf%TYPE default 0
                                       --, pr_nrautdoc IN  craplcm.nrautdoc%TYPE default 0
                                       --, pr_nrsequni IN  craplcm.nrsequni%TYPE default 0
                                       --, pr_cdbanchq => rw_tbdoctco(vr_indoctco).cdbandoc
                                       --, pr_cdcmpchq => rw_tbdoctco(vr_indoctco).cdcmpdoc
                                       --, pr_cdagechq => rw_tbdoctco(vr_indoctco).cdagedoc
                                       --, pr_nrctachq => rw_tbdoctco(vr_indoctco).nrctadoc
                                       --, pr_nrlotchq IN  craplcm.nrlotchq%TYPE default 0
                                       --, pr_sqlotchq => rw_tbdoctco(vr_indoctco).sqlotdoc
                                       --, pr_dtrefere => vr_dtleiarq
                                       , pr_hrtransa => gene0002.fn_busca_time
                                       , pr_cdoperad => pr_cdoperad
                                       --, pr_dsidenti IN  craplcm.dsidenti%TYPE default ' '
                                       , pr_cdcooper => pr_cdcooper
                                       , pr_nrdctitg => rw_crapass.nrdctitg
                                       --, pr_dscedent IN  craplcm.dscedent%TYPE default ' '
                                       --, pr_cdcoptfn IN  craplcm.cdcoptfn%TYPE default 0
                                       --, pr_cdagetfn IN  craplcm.cdagetfn%TYPE default 0
                                       --, pr_nrterfin IN  craplcm.nrterfin%TYPE default 0
                                       --, pr_nrparepr IN  craplcm.nrparepr%TYPE default 0
                                       --, pr_nrseqava IN  craplcm.nrseqava%TYPE default 0
                                       --, pr_nraplica IN  craplcm.nraplica%TYPE default 0
                                       --, pr_cdorigem IN  craplcm.cdorigem%TYPE default 0
                                       --, pr_idlautom IN  craplcm.idlautom%TYPE default 0
                                       -------------------------------------------------
                                       -- Dados do lote (Opcional)
                                       -------------------------------------------------
                                       --, pr_inprolot  => 1 -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                       --, pr_tplotmov  => 1
                                       , pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                       , pr_incrineg  => vr_incrineg      -- OUT Indicador de crítica de negócio
                                       , pr_cdcritic  => vr_cdcritic      -- OUT
                                       , pr_dscritic  => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lançamento (CRAPLCM, conta transitória, etc)

      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        -- Se vr_incrineg = 0, se trata de um erro de Banco de Dados e deve abortar a sua execução
        IF  vr_incrineg = 0 THEN  
          RAISE vr_exc_saida;	
        ELSE
          -- Neste caso se trata de uma crítica de Negócio e o lançamento não pode ser efetuado
          -- Para CREDITO: Utilizar o CONTINUE ou gerar uma mensagem de retorno(se for chamado por uma tela); 
          -- Para DEBITO: Será necessário identificar se a rotina ignora esta inconsistência(CONTINUE) ou se devemos tomar alguma ação(efetuar algum cancelamento por exemplo, gerar mensagem de retorno ou abortar o programa)
          CONTINUE;  
        END IF;  
      END IF;
      

      
      -- Atualiza a capa do lote
      BEGIN
        UPDATE craplot
           SET craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1,
               craplot.qtcompln = nvl(craplot.qtcompln,0) + 1,
               craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1,
               craplot.vlcompdb = nvl(craplot.vlcompdb,0) + nvl(rw_crapcop.vlmenpam,0),
               craplot.vlinfodb = nvl(craplot.vlinfodb,0) + nvl(rw_crapcop.vlmenpam,0)
        WHERE craplot.cdcooper = pr_cdcooper
        AND   craplot.dtmvtolt = rw_crapdat.dtmvtolt
        AND   craplot.cdagenci = 1
        AND   craplot.cdbccxlt = 100
        AND   craplot.nrdolote = 9065
        RETURNING
           craplot.cdcooper,
           craplot.dtmvtolt,
           craplot.cdagenci,
           craplot.cdbccxlt,
           craplot.nrdolote, 
           craplot.nrseqdig,
           craplot.cdoperad
        INTO 
           rw_craplot.cdcooper,
           rw_craplot.dtmvtolt,
           rw_craplot.cdagenci,
           rw_craplot.cdbccxlt,
           rw_craplot.nrdolote, 
           rw_craplot.nrseqdig,
           rw_craplot.cdoperad;
           
        --Se nao atualizou
        IF sql%rowcount = 0 THEN
          BEGIN
            INSERT INTO craplot
               (cdcooper,
                dtmvtolt,
                cdagenci,
                cdbccxlt,
                nrdolote,
                tplotmov,
                nrseqdig,
                qtcompln,
                qtinfoln,
                vlcompdb,
                vlinfodb,
                cdhistor,
                cdoperad)
            VALUES
               (pr_cdcooper,
                rw_crapdat.dtmvtolt,
                1,
                100,
                9065,
                1, --tplotmov
                1, --nrseqdig
                1, --qtcompln
                1, --qtinfoln
                nvl(rw_crapcop.vlmenpam,0), --vlcompdb
                nvl(rw_crapcop.vlmenpam,0), --vlinfodb
                0, 
                pr_cdoperad)
              RETURNING
                craplot.cdcooper,
                craplot.dtmvtolt,
                craplot.cdagenci,
                craplot.cdbccxlt,
                craplot.nrdolote, 
                craplot.nrseqdig,
                craplot.cdoperad
              INTO 
                rw_craplot.cdcooper,
                rw_craplot.dtmvtolt,
                rw_craplot.cdagenci,
                rw_craplot.cdbccxlt,
                rw_craplot.nrdolote, 
                rw_craplot.nrseqdig,
                rw_craplot.cdoperad;
          EXCEPTION
           WHEN OTHERS THEN
             vr_dscritic := 'Erro ao inserir craplot: '||SQLERRM;
             RAISE vr_exc_saida;
          END;
        END IF;  
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar craplot: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
/* PRJ450 13/06/2018 - INICIO       
      --> Gravar lancamento
      BEGIN
        INSERT INTO craplcm
               ( dtmvtolt
                ,cdagenci
                ,cdbccxlt
                ,nrdolote
                ,cdoperad
                ,nrdconta
                ,nrdctabb
                ,nrdctitg
                ,vllanmto
                ,cdhistor
                ,nrseqdig
                ,nrdocmto
                ,cdcooper
                ,hrtransa)
         VALUES( rw_craplot.dtmvtolt          -- dtmvtolt
                ,rw_craplot.cdagenci          -- cdagenci
                ,rw_craplot.cdbccxlt          -- cdbccxlt
                ,rw_craplot.nrdolote          -- nrdolote
                ,rw_craplot.cdoperad          -- cdoperad
                ,rw_crappam.nrdconta          -- nrdconta
                ,rw_crappam.nrdconta          -- nrdctabb
                ,rw_crapass.nrdctitg          -- nrdctitg
                ,rw_crapcop.vlmenpam          -- vllanmto
                ,1027 --> MENSALIDADE PAMCARD -- cdhistor
                ,rw_craplot.nrseqdig          -- nrseqdig
                ,vr_contador                  -- nrdocmto
                ,pr_cdcooper                  -- cdcooper
                ,gene0002.fn_busca_time);      -- hrtransa
 
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir lancamento: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
-- PRJ450 13/06/2018 - FIM */    
      vr_contador := vr_contador + 1;
      
      vr_idx := lpad(rw_crapass.cdagenci, 5,'0')||
                lpad(rw_crapass.nrdconta,10,'0');

      
      vr_tab_relat616(vr_idx).cdagenci := rw_crapass.cdagenci;
      vr_tab_relat616(vr_idx).nrdconta := rw_crapass.nrdconta;
      vr_tab_relat616(vr_idx).nmprimtl := rw_crapass.nmprimtl;

                            
    END LOOP; -- FIM LOOP crappam                               

    IF vr_dddebpam = 0 THEN
      vr_dddebpam := to_char(rw_crapdat.dtmvtolt,'DD');
    END IF;
    
    --> Gerar relatorio crrl616
    pc_gera_relatorio_616(pr_tab_rel616 => vr_tab_relat616,
                          pr_dddebpam   => vr_dddebpam,
                          pr_vlmenpam   => rw_crapcop.vlmenpam,
                          pr_dscritic   => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
     
   

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informações atualizadas
    COMMIT;
      
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;


  END pc_crps614;
/
