CREATE OR REPLACE PROCEDURE CECRED.pc_crps593 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
    /* .............................................................................

       Programa: pc_crps593 (Fontes/crps593.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Ze Eduardo
       Data    : Marco/2011                       Ultima atualizacao: 07/05/2019

       Dados referentes ao programa:

       Frequencia: Diario (on-line).
       Objetivo  : Emitir Relacao de Cheques Nao Digitalizados de cada PAC.
                   Relatorio 593.

       Alteracoes: 17/05/2011 - Criacao do relatorio crrl593_99. Resumo geral, em
                                quantidade de cheques, de todos os PAC's.
                                (Fabricio)

                   19/05/2011 - Incorporado no crrl593_99 a relacao dos cheques que
                                devem ser liberados em até 3 (tres) dias uteis.
                                (Fabricio)

                   18/07/2011 - Tratamento para nao listar cheques da própria
                                cooperativa quando for Viacredi (Elton/Ze).

                   15/09/2011 - Somente considerar a sit. da previa como 0
                                (nao gerado) - devido a ABBC nao enviar diariamente
                                a planilha com os cheques a compensar E do Kofax
                                Server nao copiar as imagens de cust/desc no
                                servidor de imagens (porem transmite p/ ABBC) (Ze).

                   18/10/2011 - Incluir a Data de Aprov. do Bordero na selecao dos
                                cheques de Desconto (Ze).

                   13/02/2012 - Alteracao para que todas as coops possam digitalizar
                                cheques da propria cooperativa (ZE).

                   20/04/2012 - Listar todos os cheques de custodia e desconto que
                                nao estiverem em situacao de processado - 3 (Elton).

                   04/10/2012 - Alterado periodo de abrangencia do relatorio 593
                                de 7 dias para 15 dias (Elton).

                   26/03/2013 - Alterado ordenacao no relatorio para cheques de
                                custodia (Elton).

                   09/09/2013 - Nova forma de chamar as agencias, de PAC agora
                                a escrita será PA (André Euzébio - Supero).

                   06/11/2013 - Alterado totalizador de PAs de 99 para 999.
                                (Reinert)

                   12/06/2014 - Conversão Progress -> Oracle (Odirlei/AMcom)
                   
                   09/07/2014 - #176849 Format de nrboder (numero do bordero) 
                                aumentado para 7 digitos (Carlos)

				           27/01/2018 - #780914 Removido cheques digitalizados (Andrey)
                   
                   07/05/0219 - Ajuste para remover espaços em branco ao formatar
                                o número do lote e número do cheque ao montar o xml
                                para geração do relatório
                                (Inc0014133 - Adriano).
                            
    ............................................................................ */

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS593';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
    -- Buscar Custodia de cheques
    CURSOR cr_crapcst (pr_cdcooper crapcst.cdcooper%type,
                       pr_dtmvtolt crapcst.dtlibera%type,
                       pr_dtlimite crapcst.dtlibera%type)IS
      SELECT cst.dtlibera,
             cst.nrdconta,
             cst.dtmvtolt,
             cst.cdagenci,
             cst.nrdolote,
             cst.cdcmpchq,
             cst.cdbanchq,
             cst.cdagechq,
             cst.nrctachq,
             cst.nrcheque,
             cst.vlcheque,
             nvl(age.nmresage,'NAO ENCONTRADO') nmresage
        FROM crapcst cst,
             crapage age
       WHERE age.cdcooper(+) = cst.cdcooper
         AND age.cdagenci(+) = cst.cdagenci
         AND age.cdcooper(+) = pr_cdcooper
         AND cst.cdcooper    = pr_cdcooper
         AND cst.dtlibera    > pr_dtmvtolt
         AND cst.dtlibera   <= pr_dtlimite
         AND cst.insitprv    < 2 -- 0 = Nao Enviado, 1 = Gerado
         AND cst.insitchq   in (0,2); -- 0=nao processado, 2=processado
      
    -- Buscar Cheques contidos do Bordero de desconto de cheques
    CURSOR cr_crapcdb (pr_cdcooper crapcst.cdcooper%type,
                       pr_dtmvtolt crapcst.dtlibera%type,
                       pr_dtlimite crapcst.dtlibera%type)IS
      SELECT cdb.dtlibera,
             cdb.nrdconta,
             cdb.dtmvtolt,
             cdb.cdagenci,
             cdb.nrdolote,
             cdb.cdcmpchq,
             cdb.cdbanchq,
             cdb.cdagechq,
             cdb.nrctachq,
             cdb.nrcheque,
             cdb.vlcheque,
             cdb.dtlibbdc,
             cdb.nrborder,
             nvl(age.nmresage,'NAO ENCONTRADO') nmresage
        FROM crapcdb cdb,
             crapage age
       WHERE age.cdcooper(+) = cdb.cdcooper
         AND age.cdagenci(+) = cdb.cdagenci
         AND age.cdcooper(+) = pr_cdcooper
         AND cdb.cdcooper    = pr_cdcooper
         AND cdb.dtlibera    > pr_dtmvtolt
         AND cdb.dtlibera   <= pr_dtlimite
         AND cdb.insitprv    < 3 -- 0=Nao Enviado,1=Gerado,2=Digitalizado
         AND cdb.dtlibbdc   is not null
         AND cdb.insitchq   in (0,2); -- 0=nao processado, 2=processado
           
      
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    --Definicao do tipo de registro para armazenar os cheques em custodia
    TYPE typ_reg_custdesc IS
    RECORD ( nrdconta  crapcst.nrdconta%type, 
             dtmvtolt  crapcst.dtmvtolt%type,  
             cdagenci  crapcst.cdagenci%type, 
             nmresage  crapage.nmresage%type, 
             dtlibera  crapcst.dtlibera%type,  
             nrdolote  crapcst.nrdolote%type,  
             cdcmpchq  crapcst.cdcmpchq%type,  
             cdbanchq  crapcst.cdbanchq%type,  
             cdagechq  crapcst.cdagechq%type,  
             nrctachq  crapcst.nrctachq%type,  
             nrcheque  crapcst.nrcheque%type,  
             vlcheque  crapcst.vlcheque%type,  
             dtlibbdc  crapcdb.dtlibbdc%type,                  
             nrborder  crapcdb.nrborder%type, 
             tpcheque  INTEGER,
             tptabela  INTEGER);  /* 1=Custodia/2=Desconto */
      
    --Definicao do tipo de tabela para armazenar os cheques em custodia
    TYPE typ_tab_custdesc IS
      TABLE OF typ_reg_custdesc
      INDEX BY varchar2(100); -- cdagenci(5) + tpcheque(1) + tptabela(1) + dtlibera(8)
                             -- nrdolote(10)+ cdcmpchq(10) + cdbanchq(10) + cdagechq(10) + nrcheque(10)
    vr_tab_custdesc typ_tab_custdesc;
      
    --Definicao do tipo de registro para armazenar o resumo das agencias
    TYPE typ_reg_resumo IS
    RECORD (cdagenci  INTEGER, 
            chqurgcs  INTEGER, 
            qtchqcst  INTEGER, 
            chqurgds  INTEGER, 
            qtchqcdb  INTEGER, 
            qtdtotal  INTEGER, 
            nmresage  VARCHAR(100));
      
    --Definicao do tipo de tabela para armazenar o resumo das agencias
    TYPE typ_tab_resumo IS
      TABLE OF typ_reg_resumo
      INDEX BY PLS_INTEGER; -- cdagenci(5)
        
    vr_tab_resumo typ_tab_resumo;         

                  
    ------------------------------- VARIAVEIS -------------------------------
    -- Data limite da custodia
    vr_dtlimite   DATE;
    -- data minimo
    vr_dtminimo   DATE;
    -- contar dias
    vr_qtddmini   NUMBER;
    
    -- Indice da temp table
    vr_index      varchar2(100);
    -- variaveis de controle
    vr_cdagenci NUMBER;
    vr_tpcheque NUMBER;
    vr_tptabela NUMBER; 
      
    -- Variáveis para armazenar as informações em XML      
    vr_des_xml         CLOB;  
    vr_des_xml_res     CLOB; -- resumo               
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);     
    vr_texto_compres   VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_nom_direto      VARCHAR2(100);   
    -- nome do relatorio    
    vr_nmarqimp        VARCHAR2(100); 
    -- indicador se deve incluir informação no resumo
    vr_flgresum        BOOLEAN;
    -- controle se inseriu cheque no resumo
    vr_flgregis        BOOLEAN := FALSE;
      
    -- Data Liberacao Projeto 300
    vr_dtlibprj DATE;
      
    --------------------------- SUBROTINAS INTERNAS --------------------------
      
    -- Subrotina para escrever texto na variável CLOB do XML
    procedure pc_escreve_xml(pr_des_dados in varchar2,
                             pr_fecha_xml in boolean default false, -- descarregar buffer
                             pr_resumo    in boolean default false, -- incluir informação no resumo
                             pr_smresumo  in boolean default false  -- incluir nodo somente no resumo
                             ) is
    begin
      -- verificar se deve somente incluir no resumo
      IF NOT pr_smresumo THEN
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      END IF;
      -- incluir informação no xml do resumo
      IF pr_resumo THEN
        gene0002.pc_escreve_xml(vr_des_xml_res, vr_texto_compres, pr_des_dados, pr_fecha_xml);
      END IF;  
    end;
      
      
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
    vr_dtlimite := rw_crapdat.dtmvtolt + 15;
    vr_dtminimo := rw_crapdat.dtmvtopr;
    vr_qtddmini := 0;        

    -- se for cooperativa 1
    IF pr_cdcooper = 1 THEN
       
      LOOP
        -- acrecentar um dia na data
        vr_dtminimo := vr_dtminimo + 1;
        
        IF vr_dtminimo <> gene0005.fn_valida_dia_util( pr_cdcooper => pr_cdcooper, 
                                                      pr_dtmvtolt => vr_dtminimo, 
                                                      pr_tipo => 'P', 
                                                      pr_feriado => TRUE ) THEN
          -- se for feriado ou final de semana buscar nova data
          continue;
        ELSE
          -- contar dias uteis
          vr_qtddmini := vr_qtddmini + 1;
        END IF;
        -- se calculou dois dias, sair do loop
        IF vr_qtddmini = 2 THEN
          exit;
        END IF;                                                             
      END LOOP;-- fim loop
    END IF;  
      

    -- Buscar data parametro de referencia liberacao projeto
    vr_dtlibprj :=	to_date(GENE0001.fn_param_sistema (pr_cdcooper => 0
                                                      ,pr_nmsistem => 'CRED'
                                                      ,pr_cdacesso => 'DT_BLOQ_ARQ_DSC_CHQ')
                                                      ,'DD/MM/RRRR');

      
    -- Buscar cheques em custodia
    FOR rw_crapcst in cr_crapcst ( pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                   pr_dtlimite => vr_dtlimite ) LOOP
                                     
        
      IF rw_crapcst.dtlibera <= rw_crapdat.dtmvtopr THEN
        -- definir index do registro
        vr_index := lpad(rw_crapcst.cdagenci,5,'0') ||'1'/*tpcheque*/||1/*tptabela*/|| 
                    lpad(rw_crapcst.dtlibera,8,'0') ||lpad(rw_crapcst.nrdolote,10,'0')||
                    lpad(rw_crapcst.cdcmpchq,10,'0')||lpad(rw_crapcst.cdbanchq,10,'0')||
                    lpad(rw_crapcst.cdagechq,10,'0')||lpad(rw_crapcst.nrctachq,10,'0')||
                    lpad(rw_crapcst.nrcheque,10,'0');
        -- atribuir valores a temp table
        vr_tab_custdesc(vr_index).nrdconta := rw_crapcst.nrdconta;
        vr_tab_custdesc(vr_index).dtmvtolt := rw_crapcst.dtmvtolt;
        vr_tab_custdesc(vr_index).cdagenci := rw_crapcst.cdagenci;
        vr_tab_custdesc(vr_index).nmresage := rw_crapcst.nmresage;
        vr_tab_custdesc(vr_index).dtlibera := rw_crapcst.dtlibera;
        vr_tab_custdesc(vr_index).nrdolote := rw_crapcst.nrdolote; 
        vr_tab_custdesc(vr_index).cdcmpchq := rw_crapcst.cdcmpchq;
        vr_tab_custdesc(vr_index).cdbanchq := rw_crapcst.cdbanchq; 
        vr_tab_custdesc(vr_index).cdagechq := rw_crapcst.cdagechq; 
        vr_tab_custdesc(vr_index).nrctachq := rw_crapcst.nrctachq; 
        vr_tab_custdesc(vr_index).nrcheque := rw_crapcst.nrcheque; 
        vr_tab_custdesc(vr_index).vlcheque := rw_crapcst.vlcheque;
        vr_tab_custdesc(vr_index).tptabela := 1;
        vr_tab_custdesc(vr_index).tpcheque := 1;   /*Urgente*/
      ELSE
        -- definir index do registro
        vr_index := lpad(rw_crapcst.cdagenci,5,'0') ||'2'/*tpcheque*/||1/*tptabela*/|| 
                    lpad(rw_crapcst.dtlibera,8,'0') ||lpad(rw_crapcst.nrdolote,10,'0')||
                    lpad(rw_crapcst.cdcmpchq,10,'0')||lpad(rw_crapcst.cdbanchq,10,'0')||
                    lpad(rw_crapcst.cdagechq,10,'0')||lpad(rw_crapcst.nrctachq,10,'0')||
                    lpad(rw_crapcst.nrcheque,10,'0');
        -- atribuir valores a temp table
        vr_tab_custdesc(vr_index).nrdconta := rw_crapcst.nrdconta;
        vr_tab_custdesc(vr_index).dtmvtolt := rw_crapcst.dtmvtolt;
        vr_tab_custdesc(vr_index).cdagenci := rw_crapcst.cdagenci;
        vr_tab_custdesc(vr_index).nmresage := rw_crapcst.nmresage;
        vr_tab_custdesc(vr_index).dtlibera := rw_crapcst.dtlibera;
        vr_tab_custdesc(vr_index).nrdolote := rw_crapcst.nrdolote; 
        vr_tab_custdesc(vr_index).cdcmpchq := rw_crapcst.cdcmpchq;
        vr_tab_custdesc(vr_index).cdbanchq := rw_crapcst.cdbanchq; 
        vr_tab_custdesc(vr_index).cdagechq := rw_crapcst.cdagechq; 
        vr_tab_custdesc(vr_index).nrctachq := rw_crapcst.nrctachq; 
        vr_tab_custdesc(vr_index).nrcheque := rw_crapcst.nrcheque; 
        vr_tab_custdesc(vr_index).vlcheque := rw_crapcst.vlcheque;
        vr_tab_custdesc(vr_index).tptabela := 1;
        vr_tab_custdesc(vr_index).tpcheque := 2; 
      END IF; 
      
    END LOOP; -- Fim loop crapcst   
      
    -- Buscar Cheques contidos do Bordero de desconto de cheques
    FOR rw_crapcdb in cr_crapcdb ( pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                   pr_dtlimite => vr_dtlimite ) LOOP
                                     
      IF rw_crapcdb.dtlibbdc >= vr_dtlibprj THEN
        CONTINUE;
      END IF;

      IF rw_crapcdb.dtlibera <= rw_crapdat.dtmvtopr THEN
        -- definir index do registro
        vr_index := lpad(rw_crapcdb.cdagenci,5,'0') ||'1'/*tpcheque*/||2/*tptabela*/|| 
                    lpad(rw_crapcdb.dtlibera,8,'0') ||
                    lpad(rw_crapcdb.cdcmpchq,10,'0')||lpad(rw_crapcdb.cdbanchq,10,'0')||
                    -- no cdb, a ordenação é alterada, pois não considera o numero de lote
                    lpad(rw_crapcdb.cdagechq,10,'0')||lpad(rw_crapcdb.nrctachq,10,'0')||                    
                    lpad(rw_crapcdb.nrcheque,10,'0')||lpad(rw_crapcdb.nrdolote,10,'0');
        -- atribuir valores a temp table
        vr_tab_custdesc(vr_index).nrdconta := rw_crapcdb.nrdconta;
        vr_tab_custdesc(vr_index).dtmvtolt := rw_crapcdb.dtmvtolt;
        vr_tab_custdesc(vr_index).cdagenci := rw_crapcdb.cdagenci;
        vr_tab_custdesc(vr_index).nmresage := rw_crapcdb.nmresage;
        vr_tab_custdesc(vr_index).dtlibera := rw_crapcdb.dtlibera;
        vr_tab_custdesc(vr_index).nrdolote := rw_crapcdb.nrdolote; 
        vr_tab_custdesc(vr_index).cdcmpchq := rw_crapcdb.cdcmpchq;
        vr_tab_custdesc(vr_index).dtlibbdc := rw_crapcdb.dtlibbdc;
        vr_tab_custdesc(vr_index).nrborder := rw_crapcdb.nrborder;
        vr_tab_custdesc(vr_index).cdbanchq := rw_crapcdb.cdbanchq; 
        vr_tab_custdesc(vr_index).cdagechq := rw_crapcdb.cdagechq; 
        vr_tab_custdesc(vr_index).nrctachq := rw_crapcdb.nrctachq; 
        vr_tab_custdesc(vr_index).nrcheque := rw_crapcdb.nrcheque; 
        vr_tab_custdesc(vr_index).vlcheque := rw_crapcdb.vlcheque;
        vr_tab_custdesc(vr_index).tptabela := 2;
        vr_tab_custdesc(vr_index).tpcheque := 1;   /*Urgente*/
      ELSE
        -- definir index do registro
        vr_index := lpad(rw_crapcdb.cdagenci,5,'0') ||'2'/*tpcheque*/||2/*tptabela*/|| 
                    lpad(rw_crapcdb.dtlibera,8,'0') ||
                    lpad(rw_crapcdb.cdcmpchq,10,'0')||lpad(rw_crapcdb.cdbanchq,10,'0')||
                    -- no cdb, a ordenação é alterada, pois não considera o numero de lote
                    lpad(rw_crapcdb.cdagechq,10,'0')||lpad(rw_crapcdb.nrctachq,10,'0')||                    
                    lpad(rw_crapcdb.nrcheque,10,'0')||lpad(rw_crapcdb.nrdolote,10,'0');
        -- atribuir valores a temp table
        vr_tab_custdesc(vr_index).nrdconta := rw_crapcdb.nrdconta;
        vr_tab_custdesc(vr_index).dtmvtolt := rw_crapcdb.dtmvtolt;
        vr_tab_custdesc(vr_index).cdagenci := rw_crapcdb.cdagenci;
        vr_tab_custdesc(vr_index).nmresage := rw_crapcdb.nmresage;
        vr_tab_custdesc(vr_index).dtlibera := rw_crapcdb.dtlibera;
        vr_tab_custdesc(vr_index).nrdolote := rw_crapcdb.nrdolote; 
        vr_tab_custdesc(vr_index).cdcmpchq := rw_crapcdb.cdcmpchq;
        vr_tab_custdesc(vr_index).dtlibbdc := rw_crapcdb.dtlibbdc;
        vr_tab_custdesc(vr_index).nrborder := rw_crapcdb.nrborder;
        vr_tab_custdesc(vr_index).cdbanchq := rw_crapcdb.cdbanchq; 
        vr_tab_custdesc(vr_index).cdagechq := rw_crapcdb.cdagechq; 
        vr_tab_custdesc(vr_index).nrctachq := rw_crapcdb.nrctachq; 
        vr_tab_custdesc(vr_index).nrcheque := rw_crapcdb.nrcheque; 
        vr_tab_custdesc(vr_index).vlcheque := rw_crapcdb.vlcheque;
        vr_tab_custdesc(vr_index).tptabela := 2;
        vr_tab_custdesc(vr_index).tpcheque := 2; 
      END IF; 
      
    END LOOP; -- Fim loop rw_crapcdb                  
      
    -- iniciar controle da agencia
    vr_cdagenci := -1;
      
    -- Busca do diretório base da cooperativa
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
      
    
    -- Inicializar o CLOB de resumo
    vr_des_xml_res := null;
    dbms_lob.createtemporary(vr_des_xml_res, true);
    dbms_lob.open(vr_des_xml_res, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML do resumo
    vr_texto_compres := null;
        
    -- Ler TempTable
    vr_index := vr_tab_custdesc.first;
      
    -- enquanto existir index, deve ler os registros
    WHILE vr_index IS NOT NULL LOOP              
        
      vr_flgresum := false;
      -- definir flag se deve incluir informação no resumo
      IF vr_tab_custdesc(vr_index).dtlibera <= vr_dtminimo THEN
         vr_flgresum := true;
      END IF;
        
      -- Controlar 1º registro de cada agencia
      IF vr_cdagenci <> vr_tab_custdesc(vr_index).cdagenci THEN
          
        -- inicalizar valores
        vr_cdagenci :=  vr_tab_custdesc(vr_index).cdagenci;
        vr_tpcheque := -1;
        vr_tptabela := -1;
           
        -- Inicializar o CLOB
        vr_des_xml := null;
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informações do XML
        vr_texto_completo := null;
          
        -- Definir nome do relatorio
        vr_nmarqimp := 'crrl593_'||TO_CHAR(vr_tab_custdesc(vr_index).cdagenci, 'fm000')||'.lst';
        
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl593>');
        pc_escreve_xml('<agencia 
                             cdagenci="'||vr_tab_custdesc(vr_index).cdagenci||'"
                             dtmvtopr="'||to_char(rw_crapdat.dtmvtopr,'DD/MM/RRRR')||'"
                             nmresage="'||to_char(vr_tab_custdesc(vr_index).cdagenci,'990')||
                                          ' - '|| vr_tab_custdesc(vr_index).nmresage||'">',
                        -- incluir no resumo
                        pr_resumo => TRUE);          
          
        
        -- Criar registro de resumo
        vr_tab_resumo(vr_cdagenci).cdagenci := vr_tab_custdesc(vr_index).cdagenci;
        vr_tab_resumo(vr_cdagenci).nmresage := substr(gene0002.fn_mask(vr_tab_custdesc(vr_index).cdagenci,'ZZ9')||
                                                      ' - '|| vr_tab_custdesc(vr_index).nmresage,1,20);
        vr_tab_resumo(vr_cdagenci).qtdtotal := 0;
         
      END IF;  
        
      -- gerar quebras por tipo cheque 
      IF vr_tpcheque <> vr_tab_custdesc(vr_index).tpcheque THEN
        --se não for o primeiro
        IF vr_tpcheque <> -1 THEN
          pc_escreve_xml('</tptabela> </tpcheque> ',
                        -- incluir no resumo
                        pr_resumo => TRUE);
          --iniciar variavel para não fechar a tag novamente
          vr_tptabela := -1;               
        END IF;
        -- gerar nodo de tipo de cheque
        pc_escreve_xml('<tpcheque tpcheque="'||vr_tab_custdesc(vr_index).tpcheque||'">',
                      -- incluir no resumo
                      pr_resumo => TRUE);
          
        vr_tpcheque := vr_tab_custdesc(vr_index).tpcheque;
        
      END IF;  
          
      -- gerar quebras por tipo de tabela 
      IF vr_tptabela <> vr_tab_custdesc(vr_index).tptabela THEN
        --se não for o primeiro
        IF vr_tptabela <> -1 THEN
          
          -- se ao fechar a tag ainda não incluiu nenhum registro no resumo
          -- incluir nodo vazio
          IF NOT vr_flgresum THEN
            pc_escreve_xml('<cheque/>',
                           -- incluir no resumo
                           pr_resumo => TRUE,
                           -- incluir somente no resumo
                           pr_smresumo => TRUE);
          END IF;
          
          pc_escreve_xml('</tptabela>',
                         -- incluir no resumo
                         pr_resumo => TRUE);
        END IF;
        -- gerar nodo de tipo de cheque
        pc_escreve_xml('<tptabela tptabela="'||vr_tab_custdesc(vr_index).tptabela||'">',
                       -- incluir no resumo
                       pr_resumo => TRUE);
          
        vr_tptabela := vr_tab_custdesc(vr_index).tptabela;
        -- iniciar variavel de controle se inseriu cheque no resumo
        vr_flgregis := FALSE;
        
      END IF; 
        
  
      pc_escreve_xml('<cheque>
                        <nrdconta>'|| gene0002.fn_mask_conta(vr_tab_custdesc(vr_index).nrdconta) ||'</nrdconta>
                        <dtmvtolt>'|| to_char(vr_tab_custdesc(vr_index).dtmvtolt,'DD/MM/RRRR')   ||'</dtmvtolt>
                        <dtlibera>'|| to_char(vr_tab_custdesc(vr_index).dtlibera,'DD/MM/RRRR')   ||'</dtlibera>
                        <nrdolote>'|| trim(gene0002.fn_mask_contrato(vr_tab_custdesc(vr_index).nrdolote)) ||'</nrdolote>
                        <dtlibbdc>'|| to_char(vr_tab_custdesc(vr_index).dtlibbdc,'DD/MM/RRRR')   ||'</dtlibbdc>
                        <nrborder>'|| gene0002.fn_mask(vr_tab_custdesc(vr_index).nrborder,'zzzzzz9') ||'</nrborder>
                        <cdcmpchq>'|| gene0002.fn_mask(vr_tab_custdesc(vr_index).cdcmpchq,'999') ||'</cdcmpchq>
                        <cdbanchq>'|| gene0002.fn_mask(vr_tab_custdesc(vr_index).cdbanchq,'999') ||'</cdbanchq>
                        <cdagechq>'|| gene0002.fn_mask(vr_tab_custdesc(vr_index).cdagechq,'9999')||'</cdagechq>
                        <nrctachq>'|| vr_tab_custdesc(vr_index).nrctachq                         ||'</nrctachq>
                        <nrcheque>'|| trim(gene0002.fn_mask_contrato(vr_tab_custdesc(vr_index).nrcheque)) ||'</nrcheque>
                        <vlcheque>'|| vr_tab_custdesc(vr_index).vlcheque                         ||'</vlcheque>
                      </cheque>',
                      -- incluir no resumo
                      pr_resumo => vr_flgresum);
      
      -- Se inseriu cheque no nodo, marcar true
      IF vr_flgresum THEN
        vr_flgregis := TRUE; 
      END IF;                        
      
      -- contar quantidade de cheques em custodia urgente
      IF vr_tab_custdesc(vr_index).dtlibera = rw_crapdat.dtmvtopr AND
         vr_tab_custdesc(vr_index).tpcheque = 1            AND
         vr_tab_custdesc(vr_index).tptabela = 1            THEN 
        vr_tab_resumo(vr_cdagenci).chqurgcs := nvl(vr_tab_resumo(vr_cdagenci).chqurgcs,0) + 1;
             
      -- contar quantidade de cheques em desconto normal  
      ELSIF vr_tab_custdesc(vr_index).dtlibera <> rw_crapdat.dtmvtopr AND
        vr_tab_custdesc(vr_index).tpcheque = 2             AND
        vr_tab_custdesc(vr_index).tptabela = 1             THEN
        vr_tab_resumo(vr_cdagenci).qtchqcst := nvl(vr_tab_resumo(vr_cdagenci).qtchqcst,0) + 1; 
        
      -- contar quantidade de cheques em desconto urgente
      ELSIF vr_tab_custdesc(vr_index).dtlibera = rw_crapdat.dtmvtopr AND
        vr_tab_custdesc(vr_index).tpcheque = 1            AND
        vr_tab_custdesc(vr_index).tptabela = 2            THEN
        vr_tab_resumo(vr_cdagenci).chqurgds := nvl(vr_tab_resumo(vr_cdagenci).chqurgds,0) + 1; 
      -- contar quantidade de cheques em custodia normal  
      ELSIF vr_tab_custdesc(vr_index).dtlibera <> rw_crapdat.dtmvtopr AND
        vr_tab_custdesc(vr_index).tpcheque = 2             AND
        vr_tab_custdesc(vr_index).tptabela = 2             THEN
        vr_tab_resumo(vr_cdagenci).qtchqcdb := nvl(vr_tab_resumo(vr_cdagenci).qtchqcdb,0) + 1;  
      END IF;
      
      vr_tab_resumo(vr_cdagenci).qtdtotal := nvl(vr_tab_resumo(vr_cdagenci).chqurgcs,0) + 
                                             nvl(vr_tab_resumo(vr_cdagenci).qtchqcst,0) +
                                             nvl(vr_tab_resumo(vr_cdagenci).chqurgds,0) +
                                             nvl(vr_tab_resumo(vr_cdagenci).qtchqcdb,0);
      
      -- buscar proximo
      vr_index := vr_tab_custdesc.next(vr_index);
      
      -- Se for o ultimo ou a agencia mudou
      IF vr_index IS NULL OR 
        (vr_cdagenci <> vr_tab_custdesc(vr_index).cdagenci) THEN
        
        -- se ao fechar a tag ainda não incluiu nenhum registro no resumo
        -- incluir nodo vazio
        IF NOT vr_flgresum THEN
          pc_escreve_xml('<cheque/>',
                         -- incluir no resumo
                         pr_resumo => TRUE,
                         -- incluir somente no resumo
                         pr_smresumo => TRUE);
        END IF;
          
        -- fechar tags
        pc_escreve_xml('</tptabela> </tpcheque> </agencia>',                       
                       -- incluir no resumo
                       pr_resumo    => TRUE,
                       pr_fecha_xml => TRUE); 
                           
        -- fechar tags e descarregar buffer
        pc_escreve_xml('</crrl593>',
                       pr_fecha_xml => TRUE);        
        
        -- gerar o relatorio
        -- Solicitar impressao de todas as agencias
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl593'          --> No base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl593.jasper'    --> Arquivo de layout do iReport
                                   ,pr_dsparams  => null                --> Enviar como parametro apenas a agencia
                                   ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nmarqimp --> Arquivo final com codigo da agencia
                                   ,pr_qtcoluna  => 132                 --> 132 colunas
                                   ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                                   ,pr_flg_gerar => 'N'                 --> gerar na hora
                                   ,pr_nmformul  => '132dh'             --> Nome do formulario para impress?o                                   
                                   ,pr_sqcabrel  => 1
                                   ,pr_nrcopias  => 1                   --> Numero de copias
                                   ,pr_des_erro  => vr_dscritic);       --> Saida com erro

        IF vr_dscritic IS NOT NULL THEN
          -- Gerar excecao
          raise vr_exc_saida;
        END IF;
        
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
             
      END IF;  
      
    END LOOP;  
    
    /* crrl593_999 - RESUMO GERAL - em quantidade de cheques */    
    -- Definir nome do relatorio
    vr_nmarqimp := 'crrl593_'||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')||'.lst';
        
    -- Inicializar o CLOB
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := null;
    
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl593>
                          <resumo>');          
    
    -- varrer temp tables de resumo
    vr_index := vr_tab_resumo.first;
    WHILE vr_index is not null LOOP
      -- incluir informações no xml
      pc_escreve_xml('<resagen>
                        <nmresage>'|| vr_tab_resumo(vr_index).nmresage ||'</nmresage>
                        <chqurgcs>'|| nvl(vr_tab_resumo(vr_index).chqurgcs,0) ||'</chqurgcs>
                        <qtchqcst>'|| nvl(vr_tab_resumo(vr_index).qtchqcst,0) ||'</qtchqcst>
                        <chqurgds>'|| nvl(vr_tab_resumo(vr_index).chqurgds,0) ||'</chqurgds>
                        <qtchqcdb>'|| nvl(vr_tab_resumo(vr_index).qtchqcdb,0) ||'</qtchqcdb>
                        <qtdtotal>'|| vr_tab_resumo(vr_index).qtdtotal ||'</qtdtotal>
                      </resagen>'); 
                      
      vr_index := vr_tab_resumo.next(vr_index);  
    END LOOP;  
    
    -- fechar nodo de resumo
    pc_escreve_xml('</resumo>',pr_fecha_xml => TRUE);
    
    -- acrescentar no xml, os detalhes por agencia
    vr_des_xml := vr_des_xml||vr_des_xml_res||'</crrl593>';    
    
    -- Solicitar impressao de todas as agencias
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                               ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                               ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/crrl593'          --> No base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl593_total.jasper'    --> Arquivo de layout do iReport
                               ,pr_dsparams  => null                --> Enviar como parametro apenas a agencia
                               ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nmarqimp --> Arquivo final com codigo da agencia
                               ,pr_qtcoluna  => 132                 --> 132 colunas
                               ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                               ,pr_flg_gerar => 'N'                 --> gerar na hora
                               ,pr_nmformul  => '132dh'             --> Nome do formulario para impress?o                                   
                               ,pr_sqcabrel  => 1
                               ,pr_nrcopias  => 1                   --> Numero de copias
                               ,pr_des_erro  => vr_dscritic);       --> Saida com erro

    IF vr_dscritic IS NOT NULL THEN
      -- Gerar excecao
      raise vr_exc_saida;
    END IF;
      
    -- Liberando a memória alocada pro CLOB
    dbms_lob.freetemporary(vr_des_xml);
        
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
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
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
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;

  END pc_crps593;
/
