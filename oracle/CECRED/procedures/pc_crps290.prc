CREATE OR REPLACE PROCEDURE CECRED.pc_crps290 (pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
   /* ..........................................................................

   Programa: PC_CRPS290                 -               Antigo: Fontes/crps290.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Maio/2000.                      Ultima atualizacao: 31/01/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 5.
               Efetuar os lancamentos automaticos no sistema de cheques em
               custodia e titulos compensaveis.
               Emite relatorio 238.

               Valores para insitlau: 1  ==> a processar
                                      2  ==> processada
                                      3  ==> com erro

   Alteracoes: 23/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               17/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               11/07/2001 - Alterado para adaptar o nome de campo (Edson).

               08/10/2003 - Atualizar craplcm.dtrefere (Margarete).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e craprej (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               16/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).

               02/11/2005 - Uso da procedure digbbx.p para conversao de campo
                            inteiro para caracter (SQLWorks - Andre).

               11/11/2005 - Acertar leitura do crapfdc (Magui).

               10/12/2005 - Atualizar craprej.nrdctitg (Magui).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               13/02/2007 - Alterar consultas com indice crapfdc1 (David).

               07/03/2007 - Ajustes para o Bancoob (Magui).

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)

               17/07/2009 - incluido no for each a condição -
                            craplau.dsorigem <> 'PG555' - Precise - paulo

               02/06/2011 - incluido no for each a condição -
                            craplau.dsorigem <> 'TAA' (Evandro).

               03/10/2011 - Ignorado dsorigem = 'CARTAOBB' na leitura da
                            craplau. (Fabricio)

               24/10/2012 - Tratamento para os cheques das contas migradas
                            (Viacredi -> Alto Vale), realizado na procedure
                            proc_trata_custodia. (Fabricio)

               23/01/2013 - Criar de rejeicao para as criticas 680 e 681 apos
                            leitura da craplot (David).

               03/06/2013 - Incluido no FOR EACH craplau a condicao -
                            craplau.dsorigem <> 'BLOQJUD' (Andre Santos - SUPERO)

               20/01/2014 - Efetuada correção na leitura da tabela craptco da
                            procedure 'proc_trata_custodia' (Diego).

               24/01/2014 - Incluir VALIDATE craplot, craplcm, craprej (Lucas R)
                            Incluido 'RELEASE craptco' para garantir que o
                            programa nao pegue um registro lido anteriormente.
                            (Fabricio)

               31/03/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> 'DAUT BANCOOB' (Lucas).

               28/09/2015 - Incluido nas consultas da craplau
                            craplau.dsorigem <> 'CAIXA' (Lombardi).

               30/05/2016 - Incluir criticas 251, 695, 410, 95 no relatorio e
                            atualizar o insitlau para 3(Cancelado) (Lucas Ranghetti #449799)
                            
               31/01/2016 - Conversão Progress para PLSQL (Jonata-MOUTS) 
			   
			   04/11/2016 - Cheques custodiados deverao ter o numero do bordero
                            igual a zero. (Projeto 300 - Rafael)	
							                            
               28/08/2017 - Ajustes na consulta da tabela crapcst na procedure 
                            pc_trata_custodia. (Lombardi)
							                            
    ............................................................................. */

   ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Constantes do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS290';
    vr_cdagenci CONSTANT PLS_INTEGER := 1;
    vr_cdbccxlt CONSTANT PLS_INTEGER := 100;  

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    vr_des_txt         VARCHAR2(32767);
    
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_rel_dshistor       VARCHAR2(1000);
    vr_caminho_integra VARCHAR2(1000);
    
    ----------------variaveis do relatório
    vr_rel_dsintegr varchar2(1000);
    vr_qtd_rejeitad NUMBER;
    
    -- Variaveis genericas
    vr_cdcopant CRAPCOP.cdcooper%TYPE;
    
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

    -- Buscar lotes para os agendamentos 
    CURSOR cr_crablot(pr_cdcooper craplot.cdcooper%TYPE
                     ,pr_dtmvtolt craplot.dtmvtolt%TYPE
                     ,pr_dtmvtopr craplot.dtmvtopg%TYPE)IS
      -- 019 - Custodia de Cheques
      -- 020 - Titulos
      SELECT dtmvtolt
            ,cdagenci
            ,cdbccxlt
            ,nrdolote
            ,tplotmov
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtopg  > pr_dtmvtolt
         AND craPlot.dtmvtopg <= pr_dtmvtopr
         AND craplot.tplotmov in (19,20); 

    -- Busca dos agendamentos em CC pendentes de processamento
    CURSOR cr_craplau(pr_cdcooper craplot.cdcooper%TYPE,
                      pr_dtmvtolt craplau.dtmvtolt%TYPE,
                      pr_cdagenci craplau.cdagenci%type,
                      pr_cdbccxlt craplau.cdbccxlt%type,
                      pr_nrdolote craplau.nrdolote%type) is

      SELECT ROWID
            ,vllanaut
            ,cdcritic
            ,cdhistor
            ,nrdconta
            ,nrdctabb
            ,nrdctitg
            ,nrseqdig
            ,nrdocmto
            ,cdseqtel
            ,dtdebito
            ,insitlau
            ,dtmvtolt
            ,cdagenci
            ,cdbccxlt
            ,nrdolote 
        from craplau
       WHERE cdcooper  = pr_cdcooper       
         AND dtmvtolt  = pr_dtmvtolt       
         AND cdagenci  = pr_cdagenci       
         AND cdbccxlt  = pr_cdbccxlt      
         AND nrdolote  = pr_nrdolote       
         AND insitlau  = 1 --> A processar             
         AND dsorigem NOT IN('CAIXA','INTERNET','TAA','PG555','CARTAOBB','BLOQJUD','DAUT BANCOOB');

    -- Checagem de existência da conta do Cooperado
    CURSOR cr_crapass(pr_cdcooper craplot.cdcooper%TYPE
                     ,pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT dtelimin
            ,cdsitdtl
        FROM crapass
       WHERE cdcooper = pr_cdcooper   
         AND nrdconta = pr_nrdconta;
     rw_crapass cr_crapass%ROWTYPE;
     
    -- Checagem de conta transferência
    CURSOR cr_craptrf(pr_cdcooper craplot.cdcooper%TYPE
                     ,pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT nrsconta
        FROM craptrf
       WHERE cdcooper = pr_cdcooper  
         AND nrdconta = pr_nrdconta
         AND tptransa = 1; --> Transferencia
     
    -- Checagem de lotes para gravação
    CURSOR cr_craplot(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt craplot.dtmvtolt%TYPE 
                     ,pr_nrdolote craplot.nrdolote%TYPE) IS
      SELECT rowid nrrowid
            ,dtmvtolt
            ,cdagenci
            ,cdbccxlt
            ,cdbccxpg
            ,nrdolote
            ,tplotmov
            ,qtinfoln
            ,qtcompln
            ,vlinfodb
            ,vlcompdb
            ,vlcompcr
            ,vlinfocr
            ,nrseqdig
            ,dtmvtopg
        FROM craplot 
       WHERE cdcooper = pr_cdcooper 
         AND dtmvtolt = pr_dtmvtolt 
         AND cdagenci = vr_cdagenci          
         AND cdbccxlt = vr_cdbccxlt  
         AND nrdolote = pr_nrdolote;  
    -- Variaveis para Custodia         
    rw_craplot_cst  cr_craplot%ROWTYPE;  
    vr_nrdolote_cst PLS_INTEGER;
    rw_craplot_mig  cr_craplot%ROWTYPE;  
    -- Variaveis para Titulos 
    rw_craplot_tit cr_craplot%ROWTYPE;
    vr_nrdolote_tit PLS_INTEGER;  
    -- Rowtype genérico para aproveitamento de código
    rw_craplot     cr_craplot%ROWTYPE;

    -- Registro rejeitados para o relatório
    CURSOR cr_craprej(pr_cdcooper craprej.cdcooper%TYPE
                     ,pr_dtmvtopr craprej.dtmvtolt%TYPE
                     ,pr_cdagenci craprej.cdagenci%TYPE
                     ,pr_cdbccxlt craprej.cdbccxlt%TYPE
                     ,pr_nrdolote craprej.nrdolote%type)is
      SELECT cdcritic
            ,tpintegr
            ,nraplica
            ,cdpesqbb
            ,vllanmto
        FROM craprej
       WHERE cdcooper = pr_cdcooper 
         AND dtmvtolt = pr_dtmvtopr  
         AND cdagenci = pr_cdagenci  
         AND cdbccxlt = pr_cdbccxlt  
         AND nrdolote = pr_nrdolote    
         AND tpintegr IN(19,20);


--------------------------- SUBROTINAS INTERNAS --------------------------

    -- Rotina para criação do lote
    PROCEDURE pc_valida_lote(pr_cdcooper   IN crapcop.cdcooper%TYPE 
                            ,pr_nrdolote   IN craplot.nrdolote%TYPE
                            ,pr_dtmvtopr   IN crapdat.dtmvtopr%TYPE
                            ,pr_rw_craplot OUT cr_craplot%ROWTYPE                  
                            ,pr_dscritic   OUT VARCHAR2) IS
    BEGIN
      -- Verificar se existe registro
      OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => pr_dtmvtopr
                     ,pr_nrdolote => pr_nrdolote);
      FETCH cr_craplot
       INTO pr_rw_craplot;
      -- Se não existe 
      IF cr_craplot%NOTFOUND THEN                
        -- Fechar o cursor
        CLOSE cr_craplot;                    
        -- Tentaremos criar o registro do lote
        BEGIN
          INSERT INTO craplot (cdcooper
                              ,dtmvtolt
                              ,cdagenci
                              ,cdbccxlt
                              ,nrdolote
                              ,tplotmov)
                        VALUES(pr_cdcooper  -- cdcooper
                              ,pr_dtmvtopr  -- dtmvtolt
                              ,vr_cdagenci  -- cdagenci
                              ,vr_cdbccxlt  -- cdbccxlt
                              ,pr_nrdolote  -- nrdolote
                              ,1)           -- tplotmov
                     RETURNING rowid
                              ,dtmvtolt
                              ,cdagenci
                              ,cdbccxlt
                              ,cdbccxpg
                              ,nrdolote
                              ,tplotmov
                              ,qtinfoln 
                              ,qtcompln 
                              ,vlinfodb 
                              ,vlcompdb
                              ,nrseqdig
                              ,vlcompcr
                              ,vlinfocr
                              ,dtmvtopg
                          INTO pr_rw_craplot.nrrowid 
                              ,pr_rw_craplot.dtmvtolt
                              ,pr_rw_craplot.cdagenci
                              ,pr_rw_craplot.cdbccxlt
                              ,pr_rw_craplot.cdbccxpg
                              ,pr_rw_craplot.nrdolote
                              ,pr_rw_craplot.tplotmov
                              ,pr_rw_craplot.qtinfoln 
                              ,pr_rw_craplot.qtcompln 
                              ,pr_rw_craplot.vlinfodb 
                              ,pr_rw_craplot.vlcompdb
                              ,pr_rw_craplot.nrseqdig
                              ,pr_rw_craplot.vlcompcr
                              ,pr_rw_craplot.vlinfocr
                              ,pr_rw_craplot.dtmvtopg;
        EXCEPTION
          WHEN dup_val_on_index THEN
            -- Lote já existe, critica 59
            vr_dscritic := gene0001.fn_busca_critica(59) || ' - LOTE = ' || to_char(pr_nrdolote,'fm000g000');
            RAISE vr_exc_saida;
          WHEN others THEN 
            -- Erro não tratado 
            vr_dscritic := ' na insercao do lote '||pr_nrdolote|| ' --> ' || sqlerrm;
            RAISE vr_exc_saida;
        END;          
      END IF;
    EXCEPTION 
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro tratado na busca/criacao de Lote '||pr_nrdolote||' --> '||vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na busca/criacao do lote '||pr_nrdolote||' --> '||SQLERRM;  
    END;          

    -- Procedimento para gravação dos registros rejeitos	
	  PROCEDURE pc_proc_rejeitados(pr_cdcooper IN craprej.cdcooper%TYPE
                                ,pr_dtmvtolt IN craprej.dtmvtolt%TYPE
                                ,pr_cdagenci IN craprej.cdagenci%TYPE
                                ,pr_cdbccxlt IN craprej.cdbccxlt%TYPE
                                ,pr_nrdolote IN craprej.nrdolote%TYPE
                                ,pr_tplotmov IN craprej.tplotmov%TYPE
                                ,pr_cdhistor IN craprej.cdhistor%TYPE
                                ,pr_nraplica IN craprej.nraplica%TYPE
                                ,pr_nrdconta IN craprej.nrdconta%TYPE
                                ,pr_nrdctabb IN craprej.nrdctabb%TYPE
                                ,pr_nrdctitg IN craprej.nrdctitg%TYPE
                                ,pr_nrseqdig IN craprej.nrseqdig%TYPE
                                ,pr_nrdocmto IN craprej.nrdocmto%TYPE
                                ,pr_vllanmto IN craprej.vllanmto%TYPE
                                ,pr_cdpesqbb IN craprej.cdpesqbb%TYPE
                                ,pr_tpintegr IN craplot.tplotmov%TYPE
                                ,pr_cdcritic IN craprej.cdcritic%TYPE
                                ,pr_dscritic OUT varchar2) IS
    BEGIN
	  -- Criar registro na tabela de rejeição
	  INSERT INTO craprej (cdcooper
                        ,dtmvtolt
                        ,cdagenci
                        ,cdbccxlt
                        ,nrdolote
                        ,tplotmov
                        ,cdhistor
                        ,nraplica
                        ,nrdconta
                        ,nrdctabb
                        ,nrdctitg
                        ,nrseqdig
                        ,nrdocmto
                        ,vllanmto
                        ,cdpesqbb
                        ,cdcritic
                        ,tpintegr)
                  VALUES(pr_cdcooper
                        ,pr_dtmvtolt
                        ,pr_cdagenci
                        ,pr_cdbccxlt
                        ,pr_nrdolote
                        ,pr_tplotmov
                        ,pr_cdhistor
                        ,pr_nraplica
                        ,pr_nrdconta
                        ,pr_nrdctabb
                        ,pr_nrdctitg
                        ,pr_nrseqdig
                        ,pr_nrdocmto
                        ,pr_vllanmto
                        ,pr_cdpesqbb
                        ,pr_cdcritic
                        ,pr_tpintegr);
	  EXCEPTION 
      WHEN OTHERS THEN
        pr_dscritic := 'Erro nao tratado na criacao de registro rejeito --> '||SQLERRM;  
    END;

    -- Rotina específica para tratamento de custodia
    PROCEDURE pc_trata_custodia(pr_cdcooper    in number
                               ,pr_cdcopant    in number
                               ,pr_craplau     IN cr_craplau%ROWTYPE
                               ,pr_tpintegr    IN craplot.tplotmov%TYPE
                               ,pr_craplot     IN OUT cr_craplot%rowtype
                               ,pr_craplot_mig IN OUT cr_craplot%rowtype
                               ,pr_dscritic OUT VARCHAR2) IS
      -- Checar existencia custodia
      CURSOR cr_crapcst(pr_cdcooper crapcst.cdcooper%type
                       ,pr_dtmvtolt crapcst.dtmvtolt%type
                       ,pr_cdagenci crapcst.cdagenci%type
                       ,pr_cdbccxlt crapcst.cdbccxlt%type
                       ,pr_nrdolote crapcst.nrdolote%type
                       ,pr_cdcmpchq crapcst.cdcmpchq%type
                       ,pr_cdbanchq crapcst.cdbanchq%type
                       ,pr_cdagechq crapcst.cdagechq%type
                       ,pr_nrctachq crapcst.nrctachq%type
                       ,pr_nrcheque crapcst.nrcheque%type) is

        SELECT ROWID
              ,nrdconta
              ,cdbanchq
              ,cdagechq
              ,nrctachq
              ,nrcheque 
          FROM crapcst
         WHERE crapcst.cdcooper = pr_cdcooper
           AND crapcst.dtmvtolt = pr_dtmvtolt
           AND crapcst.cdagenci = pr_cdagenci
           AND crapcst.cdbccxlt = pr_cdbccxlt
           AND crapcst.nrdolote = pr_nrdolote
           AND crapcst.cdcmpchq = pr_cdcmpchq
           AND crapcst.cdbanchq = pr_cdbanchq
           AND crapcst.cdagechq = pr_cdagechq
           AND crapcst.nrctachq = pr_nrctachq
           AND crapcst.nrcheque = pr_nrcheque
           AND NOT EXISTS (
             SELECT 1
               FROM crapcdb cdb
              WHERE cdb.cdcooper = crapcst.cdcooper
                AND cdb.nrdconta = crapcst.nrdconta
                AND cdb.dtlibera = crapcst.dtlibera
                AND cdb.dtlibbdc IS NOT NULL
                AND cdb.cdcmpchq = crapcst.cdcmpchq
                AND cdb.cdbanchq = crapcst.cdbanchq
                AND cdb.cdagechq = crapcst.cdagechq
                AND cdb.nrctachq = crapcst.nrctachq
                AND cdb.nrcheque = crapcst.nrcheque 
                AND cdb.dtdevolu IS NULL);
      rw_crapcst cr_crapcst%ROWTYPE;
          
      --Cadastro de folhas de cheques emitidos para o cooperado.
      Cursor cr_crapfdc(pr_cdcooper crapfdc.cdcooper%type,
                        pr_cdbanchq crapfdc.cdbanchq%type,
                        pr_cdagechq crapfdc.cdagechq%type,
                        pr_nrctachq crapfdc.nrctachq%type,
                        pr_nrcheque crapfdc.nrcheque%type) is

       select rowid
             ,dtemschq
             ,tpcheque
             ,dtretchq
             ,incheque
             ,vlcheque
             ,cdbanchq
             ,cdagechq
             ,nrctachq 
         from crapfdc
        WHERE cdcooper = pr_cdcooper       
          AND cdbanchq = pr_cdbanchq       
          AND cdagechq = pr_cdagechq       
          AND nrctachq = pr_nrctachq       
          AND nrcheque = pr_nrcheque;
      rw_crapfdc cr_crapfdc%ROWTYPE;

      -- Verificar se é conta migrada
      cursor cr_craptco(pr_nrctachq crapcst.nrctachq%type) IS
        select cdcooper 
              ,nrdconta
          from craptco
         where cdcopant = pr_cdcopant          
           and nrctaant = pr_nrctachq
           and tpctatrf = 1                     
           and flgativo = 1;
      rw_craptco cr_craptco%rowtype;
      
      -- Verificar se já não existe lançamento 
      cursor cr_craplcm(pr_cdcooper craplcm.cdcooper%type,
                        pr_dtmvtopr craplcm.dtmvtolt%type,
                        pr_cdagenci craplcm.cdagenci%type,
                        pr_cdbccxlt craplcm.cdbccxlt%type,
                        pr_nrdolote craplcm.nrdolote%type,
                        pr_nrdctabb craplcm.nrdctabb%type,
                        pr_nrdocmto craplcm.nrdocmto%type)is
        select 1 
          from craplcm
         where cdcooper = pr_cdcooper 
           AND dtmvtolt = pr_dtmvtopr 
           AND cdagenci = pr_cdagenci
           AND cdbccxlt = pr_cdbccxlt
           AND nrdolote = pr_nrdolote
           AND nrdctabb = pr_nrdctabb
           AND nrdocmto = pr_nrdocmto;
      vr_temlcm number; 
      vr_nrdocmto craplcm.nrdocmto%TYPE;
       
       
      -- Variaveis para desmembramento do registro custódia
      vr_dtmvtolt  DATE;
      vr_cdagenci  NUMBER;
      vr_cdbccxlt  NUMBER;
      vr_nrdolote  NUMBER;
      vr_cdcmpchq  NUMBER;
      vr_cdbanchq  NUMBER;
      vr_cdagechq  NUMBER;
      vr_nrctachq  NUMBER;
      vr_nrcheque  NUMBER;
       
      -- Variaveis genéricas 
      vr_flgentra boolean;
       
       
    BEGIN 
      -- Efetuar a separação dos valores 
      vr_dtmvtolt := to_date(SUBSTR(pr_craplau.cdseqtel,1,10),'dd/mm/rrrr');
      vr_cdagenci := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,12,3));
      vr_cdbccxlt := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,16,3));
      vr_nrdolote := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,20,6));
      vr_cdcmpchq := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,27,3));
      vr_cdbanchq := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,31,3));
      vr_cdagechq := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,35,4));
      vr_nrctachq := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,40,8));
      vr_nrcheque := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,49,6));
      
      -- Busca cadastro da custodia 
      OPEN cr_crapcst(pr_cdcooper 
                     ,vr_dtmvtolt
                     ,vr_cdagenci
                     ,vr_cdbccxlt
                     ,vr_nrdolote
                     ,vr_cdcmpchq
                     ,vr_cdbanchq
                     ,vr_cdagechq
                     ,vr_nrctachq
                     ,vr_nrcheque);
      FETCH cr_crapcst
      INTO rw_crapcst;
      IF cr_crapcst%NOTFOUND THEN
        CLOSE cr_crapcst;
        -- Atualizar o agendamento como "Com erro"
        begin
          update craplau
             set insitlau = 3
                ,dtdebito = pr_craplot.dtmvtolt
                ,cdcritic = 680
           where craplau.rowid = pr_craplau.rowid;
        exception
          when others then
            vr_dscritic := 'Problema ao alterar dados craplau '||sqlerrm;
            RAISE vr_exc_saida;
        end;
         
        -- Criar registro rejeitado 
        pc_proc_rejeitados(pr_cdcooper => pr_cdcooper
                          ,pr_dtmvtolt => pr_craplot.dtmvtolt
                          ,pr_cdagenci => pr_craplot.cdagenci
                          ,pr_cdbccxlt => pr_craplot.cdbccxlt
                          ,pr_nrdolote => pr_craplot.nrdolote
                          ,pr_tplotmov => pr_craplot.tplotmov
                          ,pr_cdhistor => pr_craplau.cdhistor
                          ,pr_nraplica => 0
                          ,pr_nrdconta => pr_craplau.nrdconta
                          ,pr_nrdctabb => pr_craplau.nrdctabb
                          ,pr_nrdctitg => pr_craplau.nrdctitg
                          ,pr_nrseqdig => pr_craplau.nrseqdig
                          ,pr_nrdocmto => pr_craplau.nrdocmto
                          ,pr_vllanmto => pr_craplau.vllanaut
                          ,pr_cdpesqbb => pr_craplau.cdseqtel
                          ,pr_tpintegr => pr_tpintegr
                          ,pr_cdcritic => 680
                          ,pr_dscritic => vr_dscritic);
        -- Se houve critica
        IF vr_dscritic IS NOT NULL THEN 
           RAISE vr_exc_saida;
        END IF; 
      ELSE 
        CLOSE cr_crapcst; 
        -- Iniciar controle         
        vr_flgentra := TRUE;
        
        -- Somente considerar Historicos 21 e 26 
        IF pr_craplau.cdhistor NOT IN (21,26) THEN
          vr_cdcritic := 245;
        ELSE 
          -- Busca a folha de cheque em custódia
          OPEN cr_crapfdc(pr_cdcooper
                         ,rw_crapcst.cdbanchq
                         ,rw_crapcst.cdagechq
                         ,rw_crapcst.nrctachq
                         ,rw_crapcst.nrcheque);
          FETCH cr_crapfdc
           INTO rw_crapfdc;
          -- Se não encontrar 
          IF cr_crapfdc%NOTFOUND THEN
            close cr_crapfdc;
            -- Verificar se é conta migrada
            rw_craptco := null;
            open cr_craptco(rw_crapcst.nrctachq);
            fetch cr_craptco
             into rw_craptco;
            -- Se encontrar
            IF cr_craptco%FOUND THEN 
              close cr_craptco; 
              -- Buscar folha de cheque na cooperativa destino
              OPEN cr_crapfdc(pr_cdcopant
                             ,rw_crapcst.cdbanchq
                             ,rw_crapcst.cdagechq
                             ,rw_craptco.nrdconta
                             ,rw_crapcst.nrcheque);
              FETCH cr_crapfdc
               INTO rw_crapfdc;
            ELSE
              close cr_craptco; 
            END IF;
          END IF;
          -- Se encontrou FDC 
          IF cr_crapfdc%FOUND THEN 
            close cr_crapfdc;
            -- 
            IF rw_crapfdc.dtemschq is null THEN
              vr_cdcritic := 108;
            ELSIF rw_crapfdc.tpcheque = 2 THEN
              vr_cdcritic := 646;
            ELSIF rw_crapfdc.dtretchq is null THEN
              vr_cdcritic := 109;
            ELSIF rw_crapfdc.incheque in (5,6,7) THEN
              vr_cdcritic := 97;
            ELSIF rw_crapfdc.incheque = 8 THEN
              vr_cdcritic := 320;
            ELSIF rw_crapfdc.tpcheque = 3 AND rw_crapfdc.incheque = 1 THEN
              vr_cdcritic := 96;
            ELSIF rw_crapfdc.tpcheque = 3 AND rw_crapfdc.vlcheque <> pr_craplau.vllanaut THEN
              vr_cdcritic := 269;
            END IF;
          ELSE 
            close cr_crapfdc;
            -- Gerar critica 108
            vr_cdcritic := 108;
          END IF; 
        END IF;
        -- Se ainda não gerou critica 
        if vr_cdcritic = 0 then
          -- Verifica se tem LCM já para a mesma chave 
          vr_temlcm := 0;
          OPEN cr_craplcm(pr_cdcooper
                         ,pr_craplot.dtmvtolt
                         ,pr_craplot.cdagenci
                         ,pr_craplot.cdbccxlt
                         ,pr_craplot.nrdolote
                         ,pr_craplau.nrdctabb
                         ,pr_craplau.nrdocmto);
          FETCH cr_craplcm
           INTO vr_temlcm;
          CLOSE cr_craplcm;
          
          -- Se não achou 
          IF vr_temlcm = 0 THEN 
            IF pr_craplau.cdhistor = 26 AND rw_crapfdc.incheque = 2 THEN
              vr_cdcritic := 287;
            ELSIF pr_craplau.cdhistor = 21 AND rw_crapfdc.incheque = 2 THEN
              vr_cdcritic := 257;
            ELSIF pr_craplau.cdhistor = 21 AND rw_crapfdc.incheque = 1 THEN
              vr_cdcritic := 96;
            END IF;
          ELSE
            vr_cdcritic := 92;
          END IF;
        END IF;
        -- Se encontrou critica 
        IF vr_cdcritic > 0 THEN
          -- Criar rejeitados 
          pc_proc_rejeitados(pr_cdcooper => pr_cdcooper
                            ,pr_dtmvtolt => pr_craplot.dtmvtolt
                            ,pr_cdagenci => pr_craplot.cdagenci
                            ,pr_cdbccxlt => pr_craplot.cdbccxlt
                            ,pr_nrdolote => pr_craplot.nrdolote
                            ,pr_tplotmov => pr_craplot.tplotmov
                            ,pr_cdhistor => pr_craplau.cdhistor
                            ,pr_nraplica => rw_crapcst.nrdconta
                            ,pr_nrdconta => pr_craplau.nrdconta
                            ,pr_nrdctabb => pr_craplau.nrdctabb
                            ,pr_nrdctitg => pr_craplau.nrdctitg
                            ,pr_nrseqdig => pr_craplau.nrseqdig
                            ,pr_nrdocmto => pr_craplau.nrdocmto
                            ,pr_vllanmto => pr_craplau.vllanaut
                            ,pr_cdpesqbb => pr_craplau.cdseqtel
                            ,pr_tpintegr => pr_tpintegr
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
          -- Se houve critica
          IF vr_dscritic IS NOT NULL THEN 
             RAISE vr_exc_saida;
          END IF;   
          -- Criticas 257 e 287 poderemos continuar 
          IF vr_cdcritic in (257,287) THEN
            vr_flgentra := TRUE;
          ELSE
            vr_flgentra := FALSE;
          END IF;
        END IF;
        -- Ultima validação 
        IF vr_flgentra THEN
          -- Somente se conta migrada e Custodia Viacredi Cta 85448
          IF rw_craptco.nrdconta <> 0 AND pr_cdcooper = 1 AND rw_crapcst.nrdconta = 85448 THEN
            -- Cancelar o agendamento como Erro 
            begin
              update craplau
                 set dtdebito = pr_craplot.dtmvtolt
                    ,cdcritic = vr_cdcritic
                    ,insitlau = 3
               where craplau.rowid = pr_craplau.rowid;
            exception
              when others then
                vr_dscritic := 'Problema ao alterar dados craplau --> '||sqlerrm;                       
                RAISE vr_exc_saida;
            end;
          ELSE -- Outros casos 
            -- Somente se conta migrada 
            IF rw_craptco.nrdconta <> 0 THEN               
              -- Verificar se o lote na coop destino ainda não foi criado
              IF pr_craplot_mig.nrRowid IS NULL THEN 
                -- Chamar rotina para criação do LOTE na conta Migrada
                pc_valida_lote(pr_cdcooper   => rw_craptco.cdcooper
                              ,pr_nrdolote   => pr_craplot.nrdolote --> Mesmo lote da custodia
                              ,pr_dtmvtopr   => pr_craplot.dtmvtolt
                              ,pr_rw_craplot => pr_craplot_mig
                              ,pr_dscritic   => vr_dscritic);
                -- Se gerou erro 
                IF vr_dscritic IS NOT NULL THEN 
                  -- 
                  RAISE vr_exc_saida;
                END IF;
              END IF;  
              -- Procurar LCM disponível na Coop migrada
              vr_nrdocmto := pr_craplau.nrdocmto;
              LOOP 
                vr_temlcm := 0;
                OPEN cr_craplcm(rw_craptco.cdcooper
                               ,pr_craplot_mig.dtmvtolt
                               ,pr_craplot_mig.cdagenci
                               ,pr_craplot_mig.cdbccxlt
                               ,pr_craplot_mig.nrdolote
                               ,pr_craplau.nrdctabb
                               ,vr_nrdocmto);
                FETCH cr_craplcm
                 INTO vr_temlcm;
                CLOSE cr_craplcm;
                -- Sair quando não encontrou 
                EXIT WHEN vr_temlcm = 0;
                -- Se encontrou, vamos incrementar o numero do documento 
                vr_nrdocmto := vr_nrdocmto + 1000000;
              END LOOP;
              
              -- Criar o registro de debito da CC          
              begin
                insert into craplcm(craplcm.dtmvtolt
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
                                   ,craplcm.cdcooper
                                   ,craplcm.cdbanchq
                                   ,craplcm.cdagechq
                                   ,craplcm.nrctachq
                                   ,craplcm.cdpesqbb)
                             values(pr_craplot_mig.dtmvtolt
                                   ,pr_craplot_mig.dtmvtolt
                                   ,pr_craplot_mig.cdagenci
                                   ,pr_craplot_mig.cdbccxlt
                                   ,pr_craplot_mig.nrdolote
                                   ,pr_craplau.nrdconta 
                                   ,pr_craplau.nrdctabb
                                   ,pr_craplau.nrdctitg
                                   ,pr_craplau.vllanaut
                                   ,pr_craplau.cdhistor
                                   ,pr_craplau.vllanaut
                                   ,pr_craplot_mig.nrseqdig + 1
                                   ,rw_craptco.cdcooper
                                   ,rw_crapfdc.cdbanchq
                                   ,rw_crapfdc.cdagechq
                                   ,rw_crapfdc.nrctachq
                                   ,'LANCAMENTO DE CONTA MIGRADA');
              EXCEPTION 
                WHEN OTHERS THEN 
                  -- Gerar criticas
                  vr_dscritic := 'Erro ao criar registro de debito na conta corrente --> '||sqlerrm;
                  RAISE vr_exc_saida;
              END;
              -- Atualizar LOTE
              pr_craplot_mig.qtinfoln := pr_craplot_mig.qtinfoln + 1;
              pr_craplot_mig.qtcompln := pr_craplot_mig.qtcompln + 1;
              pr_craplot_mig.vlinfodb := pr_craplot_mig.vlinfodb + pr_craplau.vllanaut;
              pr_craplot_mig.vlcompdb := pr_craplot_mig.vlcompdb + pr_craplau.vllanaut;
            ELSE 
              -- Criar o registro de debito da CC          
              begin
                insert into craplcm(craplcm.dtmvtolt
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
                                   ,craplcm.cdcooper
                                   ,craplcm.cdbanchq
                                   ,craplcm.cdagechq
                                   ,craplcm.nrctachq
                                   ,craplcm.cdpesqbb)
                             values(pr_craplot.dtmvtolt
                                   ,pr_craplot.dtmvtolt
                                   ,pr_craplot.cdagenci
                                   ,pr_craplot.cdbccxlt
                                   ,pr_craplot.nrdolote
                                   ,pr_craplau.nrdconta 
                                   ,pr_craplau.nrdctabb
                                   ,pr_craplau.nrdctitg
                                   ,pr_craplau.nrdocmto
                                   ,pr_craplau.cdhistor
                                   ,pr_craplau.vllanaut
                                   ,pr_craplot.nrseqdig + 1
                                   ,pr_cdcooper
                                   ,rw_crapfdc.cdbanchq
                                   ,rw_crapfdc.cdagechq
                                   ,rw_crapfdc.nrctachq
                                   ,to_char(pr_craplau.dtmvtolt,'DD/MM/RRRR')||'-' ||
                                    TO_CHAR(pr_craplau.cdagenci,'fm000')       ||'-' ||
                                    TO_CHAR(pr_craplau.cdbccxlt,'fm000')       ||'-' ||
                                    TO_CHAR(pr_craplau.nrdolote,'fm000000')    ||'-' ||
                                    to_char(pr_craplau.nrseqdig,'fm00000'));
              EXCEPTION 
                WHEN OTHERS THEN 
                  -- Gerar criticas
                  vr_dscritic := 'Erro ao criar registro de debito na conta corrente --> '||sqlerrm;
                  RAISE vr_exc_saida;
              END;
              -- Atualizar LOTE
              pr_craplot.nrseqdig := pr_craplot.nrseqdig + 1;
              pr_craplot.qtinfoln := pr_craplot.qtinfoln + 1;
              pr_craplot.qtcompln := pr_craplot.qtcompln + 1;
              pr_craplot.vlinfodb := pr_craplot.vlinfodb + pr_craplau.vllanaut;
              pr_craplot.vlcompdb := pr_craplot.vlcompdb + pr_craplau.vllanaut;
            END IF;
            -- Lógica comum independente de conta migrada ou não             
            -- Atualizar agendamento como debitada 
            begin
              update craplau
                 set dtdebito = pr_craplot.dtmvtolt
                    ,insitlau = 2
               where craplau.rowid = pr_craplau.rowid;
            exception
              when others then
                vr_dscritic := 'Problema ao alterar dados craplau --> '||sqlerrm;                                           
                RAISE vr_exc_saida;
            end;
            -- Atualizar situação da custódia 
            begin
              update crapcst
                 set crapcst.insitchq = 4
               where crapcst.rowid = rw_crapcst.rowid;
            exception
              when others then
                vr_dscritic := 'Problema ao alterar dados crapcst '||sqlerrm;
                RAISE vr_exc_saida;
            end;    
            -- Somente para os históricos 21 e 26            
            IF pr_craplau.cdhistor IN(21,26) THEN
              begin
               update crapfdc
                  set incheque = rw_crapfdc.incheque + 5
                     ,dtliqchq = pr_craplot.dtmvtolt 
                     ,vlcheque = pr_craplau.vllanaut
                  where crapfdc.rowid = rw_crapfdc.rowid;
               exception
                 when others then
                   vr_dscritic := 'Problema ao alterar dados crapfdc -->'||sqlerrm;       
                   RAISE vr_exc_saida;
              end;
            END IF; -- Fim testes históricos 21 e 26
          END IF; -- Fim testes cfme migração ou não 
        ELSE
          BEGIN
            -- Atualizar o lançamento como "com erro"
            update craplau
               set insitlau = 3
                  ,dtdebito = pr_craplot.dtmvtolt
                  ,cdcritic = vr_cdcritic
             where craplau.rowid = pr_craplau.rowid;
            exception
              when others then
                vr_dscritic := 'Problema ao atualizar dados craplau para erro --> '||sqlerrm;
                raise vr_exc_saida;
          END;
        END IF;
      END IF;
	  EXCEPTION 
      WHEN vr_exc_saida THEN 
        pr_dscritic := 'Erro tratado no debito da Custodia --> '||vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro no debito da Custodia --> '||SQLERRM;  
    END pc_trata_custodia;
  
    -- Procedimento específico para tratamento de agendamento de titulos 
    PROCEDURE pc_trata_titulo(pr_cdcooper in number
                             ,pr_craplau  in cr_craplau%ROWTYPE
                             ,pr_tpintegr IN craplot.tplotmov%TYPE
                             ,pr_craplot  IN OUT cr_craplot%rowtype
                             ,pr_dscritic OUT varchar2) is
      -- variaveis auxiliares para desmembramento do registro 
      vr_dtmvtolt date;
      vr_cdagenci number;
      vr_cdbccxlt number;
      vr_nrdolote number;
      vr_dscodbar number;

      -- Busca dados do titulo 
      CURSOR cr_craptit (pr_cdcooper craptit.cdcooper%type 
                        ,pr_dtmvtolt craptit.dtmvtolt%type
                        ,pr_cdagenci craptit.cdagenci%type
                        ,pr_cdbccxlt craptit.cdbccxlt%type
                        ,pr_nrdolote craptit.nrdolote%type
                        ,pr_dscodbar craptit.dscodbar%type) IS
        SELECT craptit.rowid
          FROM craptit
         WHERE cdcooper = pr_cdcooper   
           AND dtmvtolt = pr_dtmvtolt
           AND cdagenci = pr_cdagenci
           AND cdbccxlt = pr_cdbccxlt
           AND nrdolote = pr_nrdolote
           AND dscodbar = pr_dscodbar;
      vr_rowid rowid;
      
    BEGIN
      -- Separação dos valores   
      vr_dtmvtolt := TO_DATE(SUBSTR(pr_craplau.cdseqtel,4,2)||'/'||
                             SUBSTR(pr_craplau.cdseqtel,1,2)||'/'||
                             SUBSTR(pr_craplau.cdseqtel,7,4),'DD/MM/RRRR');
      vr_cdagenci := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,12,3));
      vr_cdbccxlt := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,16,3));
      vr_nrdolote := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,20,6));
      vr_dscodbar := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,27,44));

      -- Busca dos dados do titulo do agendamento
      OPEN cr_craptit(pr_cdcooper
                     ,vr_dtmvtolt
                     ,vr_cdagenci
                     ,vr_cdbccxlt
                     ,vr_nrdolote
                     ,vr_dscodbar);
      FETCH cr_craptit
       INTO vr_rowid;
      -- Se não encontrar      
      IF cr_craptit%NOTFOUND THEN
        CLOSE cr_craptit;
        -- Gerar erro no agendamento 
        BEGIN
          UPDATE craplau
             SET insitlau = 3
                ,dtdebito = pr_craplot.dtmvtolt
                ,cdcritic = 681
           WHERE ROWID = pr_craplau.ROWID;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao alterar dados craplau titulo - para 3 --> '||sqlerrm;
            RAISE vr_exc_saida;
        END;
        -- Enviar critica 681 para os rejeitos        
        pc_proc_rejeitados(pr_cdcooper => pr_cdcooper
                          ,pr_dtmvtolt => pr_craplot.dtmvtolt
                          ,pr_cdagenci => pr_craplot.cdagenci
                          ,pr_cdbccxlt => pr_craplot.cdbccxlt
                          ,pr_nrdolote => pr_craplot.nrdolote
                          ,pr_tplotmov => pr_craplot.tplotmov
                          ,pr_cdhistor => pr_craplau.cdhistor
                          ,pr_nraplica => 0
                          ,pr_nrdconta => pr_craplau.nrdconta
                          ,pr_nrdctabb => pr_craplau.nrdctabb
                          ,pr_nrdctitg => pr_craplau.nrdctitg
                          ,pr_nrseqdig => pr_craplau.nrseqdig
                          ,pr_nrdocmto => pr_craplau.nrdocmto
                          ,pr_vllanmto => pr_craplau.vllanaut
                          ,pr_cdpesqbb => pr_craplau.cdseqtel
                          ,pr_tpintegr => pr_tpintegr
                          ,pr_cdcritic => 681
                          ,pr_dscritic => vr_dscritic);
        -- Se houve critica
        IF vr_dscritic IS NOT NULL THEN 
          RAISE vr_exc_saida;
        END IF; 
      ELSE 
        CLOSE cr_craptit; 
        -- Inserir o registro na conta corrente do Cooperado
        BEGIN
          INSERT INTO craplcm (dtmvtolt
                              ,cdagenci
                              ,cdbccxlt
                              ,nrdolote
                              ,nrdconta
                              ,nrdctabb
                              ,nrdctitg
                              ,nrdocmto
                              ,cdhistor
                              ,vllanmto
                              ,nrseqdig
                              ,cdcooper
                              ,cdpesqbb)
                       values (pr_craplot.dtmvtolt
                              ,pr_craplot.cdagenci
                              ,pr_craplot.cdbccxlt
                              ,pr_craplot.nrdolote
                              ,pr_craplau.nrdconta
                              ,pr_craplau.nrdconta
                              ,to_char(pr_craplau.nrdconta,'99999999')
                              ,pr_craplau.nrdocmto
                              ,pr_craplau.cdhistor
                              ,pr_craplau.vllanaut
                              ,pr_craplot.nrseqdig + 1
                              ,pr_cdcooper
                              ,to_char(pr_craplau.dtmvtolt,'99/99/9999') || '-' || to_char(pr_craplau.cdagenci,'fm000') || '-' || to_char(pr_craplau.cdbccxlt,'fm000')|| '-' || to_char(pr_craplau.nrdolote,'fm000000') || '-' || to_char(pr_craplau.nrseqdig,'fm00000'));
        EXCEPTION 
          WHEN OTHERS THEN
            -- Erro na gravação da LCM
            vr_dscritic := 'Erro na gravacao LCM Titulo --> '||sqlerrm;
            RAISE vr_exc_saida;
        end;
        
        -- Atualizar o Lote
        pr_craplot.qtinfoln := pr_craplot.qtinfoln + 1;
        pr_craplot.qtcompln := pr_craplot.qtcompln + 1;
        pr_craplot.vlinfodb := pr_craplot.vlinfodb + pr_craplau.vllanaut;
        pr_craplot.vlcompdb := pr_craplot.vlcompdb + pr_craplau.vllanaut;
        pr_craplot.nrseqdig := pr_craplot.nrseqdig + 1;
        
        -- Atualizar o agendamento 
        begin
          update craplau
             set dtdebito = pr_craplot.dtmvtolt
                ,insitlau = 2 --> Debitado
            where craplau.rowid = pr_craplau.rowid;
          exception
            when others then
              vr_dscritic := 'Problema ao alterar dados craplau '||sqlerrm;
              RAISE vr_exc_saida;
        end;
        
        -- Atualizar o registo do título 
        BEGIN
          update craptit
             set insittit = 2
           where rowid = vr_rowid;
        EXCEPTION
          when others then
            vr_dscritic := 'Problema ao atualizar titulo para processado --> '||sqlerrm;
            RAISE vr_exc_saida;
        END;
      END IF;      
	  EXCEPTION 
      WHEN vr_exc_saida THEN 
        pr_dscritic := 'Erro tratado no debito do titulo --> '||vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro no debito do Titulo --> '||SQLERRM;  
    END pc_trata_titulo;
      
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

    -- Armazena a cooperativa anterior no caso de verificar a TCO
    IF pr_cdcooper = 1 THEN
      vr_cdcopant := 2;
    ELSIF pr_cdcooper = 16 THEN
      vr_cdcopant := 1;
    END IF;
    
    -- Busca dos lotes de:
    --  019 - Custodia de Cheques
    --  020 - Titulos
    FOR rw_crablot IN cr_crablot (pr_cdcooper => pr_cdcooper,
                                  pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                  pr_dtmvtopr => rw_crapdat.dtmvtopr) LOOP

      -- Checar se ainda não foi criado lote para cada tipo
      IF rw_crablot.tplotmov = 19 AND vr_nrdolote_cst IS NULL THEN
        -- Efetuar a busca ou criação do lote
        vr_nrdolote_cst := 4500;          
        pc_valida_lote(pr_cdcooper   => pr_cdcooper
                      ,pr_nrdolote   => vr_nrdolote_cst
                      ,pr_dtmvtopr   => rw_crapdat.dtmvtopr
                      ,pr_rw_craplot => rw_craplot_cst
                      ,pr_dscritic   => vr_dscritic);
      ELSIF rw_crablot.tplotmov = 20 AND vr_nrdolote_tit IS NULL THEN
        -- Efetuar a busca ou criação do lote 
        vr_nrdolote_tit := 4600;        
        pc_valida_lote(pr_cdcooper   => pr_cdcooper
                      ,pr_nrdolote   => vr_nrdolote_tit
                      ,pr_dtmvtopr   => rw_crapdat.dtmvtopr
                      ,pr_rw_craplot => rw_craplot_tit
                      ,pr_dscritic   => vr_dscritic);   
      END IF;
      -- Havendo erro
      IF vr_dscritic IS NOT NULL THEN 
        RAISE vr_exc_saida;
      END IF;
    
      -- Busca dos agendamentos vinculados ao LOTE a processar
      FOR rw_craplau in cr_craplau(pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => rw_crablot.dtmvtolt
                                  ,pr_cdagenci => rw_crablot.cdagenci
                                  ,pr_cdbccxlt => rw_crablot.cdbccxlt
                                  ,pr_nrdolote => rw_crablot.nrdolote) loop
       
        -- Garantir a existência do cooperado
        vr_cdcritic := 0;
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => rw_craplau.nrdconta);
        FETCH cr_crapass
         INTO rw_crapass;
        -- Se não encontrar
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          -- Gerar critica 251
          vr_cdcritic := 251;
        ELSE 
          CLOSE cr_crapass;  
          -- Checar situações da conta
          IF rw_crapass.dtelimin IS NOT NULL THEN
            -- Gerar critica 410
            vr_cdcritic := 410;
          ELSIF rw_crapass.cdsitdtl IN(5,6,7,8) THEN
            -- Gerar critica 695
            vr_cdcritic := 695;  
          ELSIF rw_crapass.cdsitdtl IN(2,4) THEN
            -- Checar transferência e se houver substituir a conta da LAU
            OPEN cr_craptrf(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_craplau.nrdconta);
            FETCH cr_craptrf
             INTO rw_craplau.nrdconta; 
            -- Se não encontrar
            IF cr_craptrf%NOTFOUND THEN
              -- Gerar critica 95;
              vr_cdcritic := 95;
            END IF;
            CLOSE cr_craptrf;
          END IF;        
        END IF;
        
        -- Se encontrou critica nos testes acima
        IF vr_cdcritic > 0 THEN 
          -- Atualizar o agendamento para "com erro"
          BEGIN
            UPDATE craplau
               SET insitlau = 3
                  ,dtdebito = rw_crapdat.dtmvtopr
                  ,cdcritic = vr_cdcritic
            WHERE ROWID = rw_craplau.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao alterar dados craplau '||sqlerrm;
              RAISE vr_exc_saida;
          END;
          -- Copiar o rowtype apenas para facilitar a criação dos rejeitos 
          IF rw_crablot.tplotmov = 19 THEN
            rw_craplot := rw_craplot_cst;
          ELSE
            rw_craplot := rw_craplot_tit;                      
          END IF;
          
          -- Criar registro rejeitado
          pc_proc_rejeitados(pr_cdcooper => pr_cdcooper
                            ,pr_dtmvtolt => rw_craplot.dtmvtolt
                            ,pr_cdagenci => rw_craplot.cdagenci
                            ,pr_cdbccxlt => rw_craplot.cdbccxlt
                            ,pr_nrdolote => rw_craplot.nrdolote
                            ,pr_tplotmov => rw_craplot.tplotmov
                            ,pr_cdhistor => rw_craplau.cdhistor
                            ,pr_nraplica => 0
                            ,pr_nrdconta => rw_craplau.nrdconta
                            ,pr_nrdctabb => rw_craplau.nrdctabb
                            ,pr_nrdctitg => rw_craplau.nrdctitg
                            ,pr_nrseqdig => rw_craplau.nrseqdig
                            ,pr_nrdocmto => rw_craplau.nrdocmto
                            ,pr_vllanmto => rw_craplau.vllanaut
                            ,pr_cdpesqbb => rw_craplau.cdseqtel
                            ,pr_tpintegr => rw_crablot.tplotmov
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
          -- Se houve critica
          IF vr_dscritic IS NOT NULL THEN 
            RAISE vr_exc_saida;
          END IF;          
        ELSE --> Não houve critica
          vr_cdcritic := 0;
          -- Chamar rotina específica
          IF rw_crablot.tplotmov = 19 THEN
             pc_trata_custodia (pr_cdcooper    => pr_cdcooper
                               ,pr_cdcopant    => vr_cdcopant
                               ,pr_craplau     => rw_craplau
                               ,pr_tpintegr    => rw_crablot.tplotmov
                               ,pr_craplot     => rw_craplot_cst
                               ,pr_craplot_mig => rw_craplot_mig
                               ,pr_dscritic    => vr_dscritic);
          ELSE 
             pc_trata_titulo (pr_cdcooper => pr_cdcooper
                             ,pr_craplau  => rw_craplau
                             ,pr_tpintegr    => rw_crablot.tplotmov
                             ,pr_craplot  => rw_craplot_tit
                             ,pr_dscritic => vr_dscritic);
          END IF;
          -- Se houve erro 
          IF vr_dscritic IS NOT NULL THEN 
            -- Sair
            RAISE vr_exc_saida;
          END IF;
        END IF;
      END LOOP; -- Fim Leitura agendamentos 
    END LOOP; -- Fim Leitura Lotes
        
    -- Se houve criação de registros 
    IF nvl(vr_nrdolote_cst,0) + nvl(vr_nrdolote_tit,0) > 0 THEN 
      
      -- Atualizar a CRAPLOT Custodia após o processamento, pois os valores estão apenas em memória
      IF vr_nrdolote_cst IS NOT NULL THEN 
        BEGIN 
          UPDATE craplot 
             SET qtinfoln = rw_craplot_cst.qtinfoln
                ,qtcompln = rw_craplot_cst.qtcompln
                ,vlinfodb = rw_craplot_cst.vlinfodb
                ,vlcompdb = rw_craplot_cst.vlcompdb
                ,nrseqdig = rw_craplot_cst.nrseqdig
           WHERE rowid = rw_craplot_cst.nrrowid;
        EXCEPTION
          WHEN OTHERS THEN 
            vr_dscritic := 'Erro ao atualizar o lote CST após processamento --> '||sqlerrm;
            RAISE vr_exc_saida;
        END;    
      END IF;    
      
      -- Atualizar a CRAPLOT Titulos após o processamento, pois os valores estão apenas em memória
      IF vr_nrdolote_tit IS NOT NULL THEN 
        BEGIN 
          UPDATE craplot 
             SET qtinfoln = rw_craplot_tit.qtinfoln
                ,qtcompln = rw_craplot_tit.qtcompln
                ,vlinfodb = rw_craplot_tit.vlinfodb
                ,vlcompdb = rw_craplot_tit.vlcompdb
                ,nrseqdig = rw_craplot_tit.nrseqdig
           WHERE rowid = rw_craplot_tit.nrrowid;
        EXCEPTION
          WHEN OTHERS THEN 
            vr_dscritic := 'Erro ao atualizar o lote TIT após processamento --> '||sqlerrm;
            RAISE vr_exc_saida;
        END;
      END IF;  
      
      -- Atualizar a CRAPLOT Migração após o processamento, pois os valores estão apenas em memória
      IF rw_craplot_mig.nrRowid IS NOT NULL THEN 
        BEGIN 
          UPDATE craplot 
             SET qtinfoln = rw_craplot_mig.qtinfoln
                ,qtcompln = rw_craplot_mig.qtcompln
                ,vlinfodb = rw_craplot_mig.vlinfodb
                ,vlcompdb = rw_craplot_mig.vlcompdb
                ,nrseqdig = rw_craplot_mig.nrseqdig
           WHERE rowid = rw_craplot_mig.nrrowid;
        EXCEPTION
          WHEN OTHERS THEN 
            vr_dscritic := 'Erro ao atualizar o lote MIG após processamento --> '||sqlerrm;
            RAISE vr_exc_saida;
        END;
      END IF;  
      
      -- Iniciar dados para relatório              
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Inicilizar as informações do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                             ,pr_texto_completo => vr_des_txt
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><crrl238 qtlote="'||to_char(nvl(vr_nrdolote_cst,0) + nvl(vr_nrdolote_tit,0))||'">');
 
      -- Efetuar laço para processar os dois tipos de integração 
      FOR vr_idx IN 1..2 LOOP 
        vr_qtd_rejeitad := 0;
        -- Copiamos o rowtype do LOTE para o genérico
        -- Primeiro custodia, depois titulos
        IF vr_idx = 1 THEN
          rw_craplot := rw_craplot_cst;
          vr_rel_dsintegr := 'CHEQUES EM CUSTODIA ' || upper(rw_crapcop.nmrescop);
        ELSE 
          rw_craplot := rw_craplot_tit;
          vr_rel_dsintegr := 'TITULOS COMPENSAVEIS';
        END IF;
        
        -- Enviar capa do Lote somente se existir informações no mesmo
        IF rw_craplot.nrrowid IS NOT NULL THEN         
        
          gene0002.pc_escreve_xml(pr_xml           => vr_des_xml
                                 ,pr_texto_completo => vr_des_txt
                                 ,pr_texto_novo     => '<lote>
                                                          <reldspesqbb>'|| vr_rel_dsintegr                            ||'</reldspesqbb>
                                                          <dtmvtolt>'   || to_char(rw_craplot.dtmvtolt,'DD/MM/RRRR')  ||'</dtmvtolt>
                                                          <cdagenci>'   || rw_craplot.cdagenci                        ||'</cdagenci>
                                                          <cdbccxlt>'   || rw_craplot.cdbccxlt                        ||'</cdbccxlt>
                                                          <nrdolote>'   || to_char(rw_craplot.nrdolote,'fm999g990')   ||'</nrdolote>
                                                          <tplotmov>'   || rw_craplot.tplotmov                        ||'</tplotmov><rejeitados>');
          

          -- Busca dos registros rejeitados para envio ao relatório
          FOR rw_corpo_rel in cr_craprej(pr_cdcooper
                                        ,rw_craplot.dtmvtolt
                                        ,rw_craplot.cdagenci
                                        ,rw_craplot.cdbccxlt
                                        ,rw_craplot.nrdolote) loop
            -- Busca descrição da critica
            vr_dscritic := gene0001.fn_busca_critica(rw_corpo_rel.cdcritic);
            -- Para as criticas 257 e 287, incluir destaque
            IF rw_corpo_rel.cdcritic  in (257,287) THEN
              vr_dscritic := '* ' || vr_dscritic;
            END IF;
            
            -- Montagem do histórico
            IF rw_corpo_rel.tpintegr = 19   THEN
              vr_rel_dshistor := TO_CHAR(gene0002.fn_mask(rw_corpo_rel.nraplica,'zzz.zzz.9')) ||
                                 ' ==> ' || TRIM(rw_corpo_rel.cdpesqbb) || '    ' ||
                                 to_char(rw_corpo_rel.vllanmto,'fm999G999G999G999G990d00') ||
                                 ' --> ' || vr_dscritic;
            ELSE
              vr_rel_dshistor := TRIM(rw_corpo_rel.cdpesqbb) || '    ' ||
                                 to_char(rw_corpo_rel.vllanmto,'fm999G999G999G999G990d00') ||
                                 ' --> ' || vr_dscritic;
            END IF;
            
            -- Incrementar quantidade de rejeitos
            vr_qtd_rejeitad := vr_qtd_rejeitad + 1;
            
            
            -- Envio do registro para o XML
            gene0002.pc_escreve_xml(pr_xml          => vr_des_xml
                                   ,pr_texto_completo => vr_des_txt
                                   ,pr_texto_novo     => '<rejeitado>
                                                            <dshistor>' || substr(ltrim(vr_rel_dshistor),1,132) ||'</dshistor>
                                                        </rejeitado>');
         end loop;
         
          -- Finalizar tag de rejeitados e Lote
          gene0002.pc_escreve_xml(pr_xml           => vr_des_xml
                                 ,pr_texto_completo => vr_des_txt
                                 ,pr_texto_novo     => '</rejeitados> 
                                                        <rel_qtdifeln>'|| rw_craplot.qtinfoln                            ||'</rel_qtdifeln>
                                                        <rel_vldifedb>'|| to_char(rw_craplot.vlinfodb,'fm999G999G999G999G990d00')||'</rel_vldifedb>
                                                        <rel_vldifecr>'|| to_char(rw_craplot.vlinfocr,'fm999G999G999G999G990d00') ||'</rel_vldifecr>
                                                        <vlinfodb>'|| to_char(rw_craplot.vlcompdb,'fm999G999G999G999G990d00') ||'</vlinfodb>
                                                        <vlinfocr>'|| to_char(rw_craplot.vlcompcr,'fm999G999G999G999G990d00') ||'</vlinfocr>
                                                        <qtinfoln>'|| rw_craplot.qtcompln                                     ||'</qtinfoln>
                                                        <tqtd>'    || (rw_craplot.qtcompln - rw_craplot.qtinfoln)                  ||'</tqtd>
                                                        <tdb>'    ||  to_char((rw_craplot.vlcompdb - rw_craplot.vlinfodb),'fm999G999G999G999G990d00') ||'</tdb>
                                                        <tcr>'    ||  to_char((rw_craplot.vlcompcr - rw_craplot.vlinfocr),'fm999G999G999G999G990d00') ||'</tcr>
                                                        <qtrejeit>' || vr_qtd_rejeitad || '</qtrejeit> 
                                                       </lote>');
        END IF; -- Fim se houver informações
        
      END LOOP; -- Fim laço LOTES

      -- Finaliza XML do relatório
      gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                             ,pr_texto_completo => vr_des_txt
                             ,pr_texto_novo     => '</crrl238>'
                             ,pr_fecha_xml      => TRUE);                               
                               
      -- Busca do diretório base da cooperativa para PDF
      vr_caminho_integra := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

      -- Efetuar solicitação de geração de relatório --
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl238/lote'    --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl238.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Sem parametros
                                 ,pr_dsarqsaid => vr_caminho_integra||'/crrl238.lst' --> Arquivo final com código da agência
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_flg_gerar => 'N'                 --> gerar na hora
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro

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

  END pc_crps290;
/
