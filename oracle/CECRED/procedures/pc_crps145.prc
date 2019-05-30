CREATE OR REPLACE PROCEDURE CECRED.pc_crps145 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps145 (fontes/crps145.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Marco/96.                       Ultima atualizacao: 02/05/2018

       Dados referentes ao programa:

       Frequencia: Diario.
       Objetivo  : Atende a solicitacao 001.
                   Efetuar os debitos dos valores aplicados referentes a Poupanca
                   Programada.
                   Emite relatorio 120. 

       Alteracoes: 21/10/96 - Alterado para verificar se ja foi feito aviso para
                              nao emitir outro. (Odair).

                   14/01/97 - Alterado para tratar CPMF (Odair).

                   04/02/97 - Arrumar calculo de saldo (Odair).

                   27/08/97 - Alterado para incluir o campo flgproce na criacao
                              do crapavs (Deborah).

                   29/09/97 - Tratar flgproce (Odair).

                   16/02/98 - Alterar a data final do CPMF (Odair)

                   18/02/98 - Alterado para guardar o valor abonado (Deborah).

                   27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                   29/06/98 - Alterado para NAO tratar historico 289 (Edson).

                   25/01/99 - Alterado para tratar abono IOF (Deborah).

                   02/06/1999 - Tratar CPMF (Deborah).

                   08/02/2001 - Aplicacoes RDCA60 e Poup. Progr. apos o dia 28 do
                                mes. (Eduardo).

                   27/05/2002 - Nao gerar mais o pedido de impressao (Deborah). 

                   26/03/2003 - Incluir tratamento da Concredi (Margarete).

                   20/02/2004 - Nao emitir mais avisos de debito (Deborah).
                   
                   13/04/2004 - Tratar tab_indabono (Margarete).

                   15/09/2004 - Tratamento  Conta Investimento(Mirtes).

                   29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                                craplcm, craplpp, craprej, craplci e do buffer
                                crablot (Diego).
                     
                   09/09/2005 - Efetuado acerto indicador debito(indebito)(Mirtes)
                   
                   16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
                   
                   09/08/2007 - Cancelar as PPR a partir de 2008 (Guilherme).
                    
                   19/11/2007 - Comentada alteracao 2008 a pedido do Ivo (Magui). 

                   21/02/2008 - Mostrar turno da crapttl.cdturnos (Gabriel).

                   21/07/2008 - Inclusao do cdcooper no FIND craphis (Mirtes).
                   
                   31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
                   
                   19/10/2009 - Alteracao Codigo Historico (Kbase).
                   
                   11/01/2011 - Definido o format "x(40)" nmprimtl (Kbase - Gilnei).
                                                                   
                   28/07/2011 - Data do debito dever ser sempre a do mes
                                seguinte (Magui).
                            
                   21/12/2011 - Aumentado o format do campo cdhistor 
                                de "999" para "9999" (Tiago).
                                
                   11/01/2012 - Ajuste na alteracao de 28/07/2011, quando data de
                                debito for em dezembro e rodar em janeiro (David).
                   
                   09/09/2013 - Nova forma de chamar as agencias, de PAC agora 
                                a escrita será PA (André Euzébio - Supero).
                                
                   15/01/2014 - Inclusao de VALIDATE craplot, craplcm, craplpp,
                                craprej, crablot e craplci (Carlos)
                                
                   20/03/2014 - Conversão Progress >> PLSQL (Edison-AMcom).

                   24/04/2017 - Nao considerar valores bloqueados para composicao do saldo disponivel
                                Heitor (Mouts) - Melhoria 440

                   24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
                                       crapass, crapttl, crapjur 
                                              (Adriano - P339).
                   
                   09/03/2018 - Alteração na forma de gravação da craplpp, utilizar sequence para gerar nrseqdig
                                Projeto Ligeirinho - Jonatas Jaqmam (AMcom)                                 

                   02/05/2018 - Ajuste no nome do arquivo gerado no relatorio (Projeto Debitador Unico - Fabiano B. Dias - AMcom).        

                   12/10/2018 - Relatório crrl1120 publicado na intranet - pr_flg_impri = "S" - Proj. 411.2 (CIS Corporate)    

                   12/10/2018 - Tratamento de Flag de Teimosinha e Debito Parcial - Proj. 411.2 (CIS Corporate)    

                   17/04/2019 - Ajuste para carregar nos planos a flag indebito corretamente (Anderson)
    ............................................................................. */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS145';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

       --Variaveis de Controle de Restart
       vr_nrctares  INTEGER:= 0;
       vr_inrestar  INTEGER:= 0;
       vr_dsrestar  crapres.dsrestar%TYPE;
	   vr_dsorigem VARCHAR2(500) := 'AIMARO,CAIXA,INTERNET,TAA,AIMARO WEB,URA';
       vr_nrdrowid  ROWID;

      -- Temp Table
      vr_tab_care APLI0005.typ_tab_care;

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
      
      --informaoes de poupanca programada
      CURSOR cr_craprpp( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrctares IN craprpp.nrdconta%TYPE
                        ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE
                        ,pr_dtdebito IN DATE) IS
        SELECT craprpp.nrdconta 
              ,craprpp.cdsitrpp
              ,craprpp.dtdebito
              ,craprpp.dtrnirpp
              ,craprpp.vlprerpp
              ,craprpp.nrctrrpp
              ,craprpp.vlprepag
              ,craprpp.vlsppant
              ,craprpp.qtprepag
              ,craprpp.vlabcpmf
              ,craprpp.vlabdiof
              ,craprpp.dtinirpp
              ,craprpp.dtfimper
              ,craprpp.dtvctopp
              ,craprpp.indebito
              ,craprpp.flgctain
              ,craprpp.cdbccxlt
              ,craprpp.cdprodut
              ,(SELECT tbcapt_config_planos_apl_prog.flgteimosinha 
              FROM tbcapt_config_planos_apl_prog 
              WHERE tbcapt_config_planos_apl_prog.cdcooper = craprpp.cdcooper 
              AND tbcapt_config_planos_apl_prog.cdprodut = craprpp.cdprodut) flgteimosinha
              ,(SELECT tbcapt_config_planos_apl_prog.flgdebito_parcial 
              FROM tbcapt_config_planos_apl_prog 
              WHERE tbcapt_config_planos_apl_prog.cdcooper = craprpp.cdcooper 
              AND tbcapt_config_planos_apl_prog.cdprodut = craprpp.cdprodut) flgdebito_parcial
              ,(SELECT tbcapt_config_planos_apl_prog.vlminimo 
              FROM tbcapt_config_planos_apl_prog 
              WHERE tbcapt_config_planos_apl_prog.cdcooper = craprpp.cdcooper 
              AND tbcapt_config_planos_apl_prog.cdprodut = craprpp.cdprodut) vlminimo
              ,craprpp.rowid
        FROM   craprpp
        WHERE  craprpp.cdcooper  = pr_cdcooper 
        AND    craprpp.nrdconta >= pr_nrctares 
        AND    craprpp.nrctrrpp  > pr_nrctrrpp 
        AND   (craprpp.cdsitrpp  = 1 OR craprpp.cdsitrpp  = 2)
        AND    craprpp.dtdebito <= pr_dtdebito
        AND    craprpp.indebito  = 0
        AND    craprpp.cdprodut > 0;

      --seleciona os saldos das contas dos cooperados
      CURSOR cr_crapsld ( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapsld.nrdconta
              ,crapsld.vlsdblfp 
              ,crapsld.vlsdbloq 
              ,crapsld.vlsdblpr 
              ,crapsld.vlsddisp
              ,crapsld.vlipmfap
              ,crapsld.vlipmfpg
              ,crapsld.rowid
        FROM   crapsld       
        WHERE crapsld.cdcooper = pr_cdcooper;
        
      --seleciona os cooperados
      CURSOR cr_crapass ( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapass.nrdconta
              ,crapass.inpessoa
              ,crapass.vllimcre
              ,crapass.cdagenci
              ,crapass.cdsecext
              ,crapass.nrramemp
              ,crapass.nmprimtl
        FROM   crapass       
        WHERE crapass.cdcooper = pr_cdcooper;
      
      -- cadastro de titulares da conta
      CURSOR cr_crapttl (pr_cdcooper IN crapcop.cdcooper%TYPE) IS 
        SELECT crapttl.cdempres
              ,crapttl.nrdconta
              ,crapttl.cdturnos
        FROM   crapttl 
        WHERE  crapttl.cdcooper = pr_cdcooper      
        AND    crapttl.idseqttl = 1;

      -- cadastro de pessoas juridicas
      CURSOR cr_crapjur (pr_cdcooper IN crapcop.cdcooper%TYPE) IS 
        SELECT crapjur.cdempres
              ,crapjur.nrdconta
        FROM   crapjur 
        WHERE  crapjur.cdcooper = pr_cdcooper;      
        
      --cadastro de lancamentos da conta do associado com 
      --historico diferente de 289
      CURSOR cr_craplcm ( pr_cdcooper IN crapcop.cdcooper%TYPE 
                         ,pr_nrdconta IN craplcm.nrdconta%TYPE
                         ,pr_dtmvtolt IN DATE) IS
        SELECT craplcm.cdhistor
              ,craplcm.vllanmto
              ,craplcm.rowid
        FROM   craplcm 
        WHERE  craplcm.cdcooper = pr_cdcooper     
        AND    craplcm.nrdconta = pr_nrdconta 
        AND    craplcm.dtmvtolt = pr_dtmvtolt     
        AND    craplcm.cdhistor <> 289
        ORDER BY cdcooper
                ,nrdconta
                ,dtmvtolt
                ,cdhistor
                ,nrdocmto;

      --cadastro de historicos da cooperativa
      CURSOR cr_craphis(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT craphis.cdhistor
              ,craphis.inhistor
              ,craphis.indoipmf
        FROM   craphis
        WHERE  craphis.cdcooper = pr_cdcooper;

      --informacoes de aviso de debito em conta-corrente
      CURSOR cr_crapavs ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE
                         ,pr_dtrefere IN DATE
                         ,pr_cdempres IN NUMBER
                         ,pr_cdagenci IN crapass.cdagenci%TYPE
                         ,pr_cdsecext IN crapass.cdsecext%TYPE
                         ,pr_nrdocmto IN craprpp.nrctrrpp%TYPE) IS
        SELECT crapavs.rowid
        FROM   crapavs 
        WHERE  crapavs.cdcooper = pr_cdcooper     
        AND    crapavs.nrdconta = pr_nrdconta 
        AND    crapavs.dtrefere = pr_dtrefere     
        AND    crapavs.cdhistor = 160              
        AND    crapavs.cdempres = pr_cdempres     
        AND    crapavs.cdagenci = pr_cdagenci 
        AND    crapavs.cdsecext = pr_cdsecext 
        AND    crapavs.dtdebito IS NULL                
        AND    crapavs.nrdocmto = pr_nrdocmto 
        AND    crapavs.tpdaviso = 1;
      --rowtype de avisos  
      rw_crapavs cr_crapavs%ROWTYPE;

      --seleciona arquivos rejeitados na integracao do banco/caixa 145
      --com codigo de rejeicao informando debito nao efetuado
      CURSOR cr_craprej(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT craprej.cdagenci
              ,craprej.nrdconta
              ,craprej.nraplica
              ,craprej.dtmvtolt
              ,craprej.vllanmto
              ,crapage.nmresage
              ,craprej.rowid
        FROM   craprej
              ,crapage 
        WHERE  craprej.cdcooper = pr_cdcooper 
        AND    craprej.cdbccxlt = 145          
        AND    craprej.cdcritic = 485 --485 - Debito nao efetuado.
        AND    craprej.cdcooper = crapage.cdcooper(+)
        AND    craprej.cdagenci = crapage.cdagenci(+)
        ORDER BY craprej.cdagenci
                ,craprej.nrdconta
                ,craprej.nraplica;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      --estrutura de registro para armazenar os saldos das contas
      TYPE typ_reg_crapsld IS
        RECORD( nrdconta crapsld.nrdconta%TYPE
               ,vlsdblfp crapsld.vlsdblfp%TYPE 
               ,vlsdbloq crapsld.vlsdbloq%TYPE 
               ,vlsdblpr crapsld.vlsdblpr%TYPE 
               ,vlsddisp crapsld.vlsddisp%TYPE
               ,vlipmfap crapsld.vlipmfap%TYPE
               ,vlipmfpg crapsld.vlipmfpg%TYPE
               ,id       ROWID
        );
      
      -- tipo de registro para armazenar os saldos das contas
      TYPE typ_tab_crapsld IS TABLE OF typ_reg_crapsld INDEX BY PLS_INTEGER; 
        
      --tabela temporaria para armazenar os saldos das contas
      vr_tab_crapsld typ_tab_crapsld;
      
      --estrutura de registro para armazenar os cooperados
      TYPE typ_reg_crapass IS
        RECORD( nrdconta crapass.nrdconta%TYPE
               ,inpessoa crapass.inpessoa%TYPE
               ,vllimcre crapass.vllimcre%TYPE
               ,cdagenci crapass.cdagenci%TYPE
               ,cdsecext crapass.cdsecext%TYPE
               ,nrramemp crapass.nrramemp%TYPE
               ,nmprimtl crapass.nmprimtl%TYPE
        );
      
      -- tipo de registro para armazenar os cooperados
      TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER; 
        
      --tabela temporaria para armazenar os cooperados
      vr_tab_crapass typ_tab_crapass;

      --tipo para armazenar a estrutura do cadastro de titulares
      TYPE typ_reg_crapttl IS 
        RECORD( cdempres crapttl.cdempres%TYPE
               ,cdturnos crapttl.cdturnos%TYPE
        );
      --estrutura do cadastro de titulares
      TYPE typ_tab_crapttl IS TABLE OF typ_reg_crapttl INDEX BY PLS_INTEGER;
      --tabela temporaria para armazenar as informacoes dos titulares
      vr_tab_crapttl typ_tab_crapttl; 

      --estrutura para armazenar o cadastro de pessoas juridicas
      TYPE typ_reg_crapjur IS 
        RECORD( cdempres crapjur.cdempres%TYPE
        );
      --tipo de registro do cadastro de pessoas juridicas
      TYPE typ_tab_crapjur IS TABLE OF typ_reg_crapjur INDEX BY PLS_INTEGER;
      --tabela temporaria para armazenar as informacoes de pessoas juridicas
      vr_tab_crapjur typ_tab_crapjur; 

      --estrutura para armazenar o cadastro de historicos
      TYPE typ_reg_craphis IS         
        RECORD( cdhistor craphis.cdhistor%TYPE
               ,inhistor craphis.inhistor%TYPE 
               ,indoipmf craphis.indoipmf%TYPE
        );
        
      --tipo de registro para armazenar o cadastro de historicos
      TYPE typ_tab_craphis IS TABLE OF typ_reg_craphis INDEX BY PLS_INTEGER;         
      
      --tabela temporaria para armazenar historicos
      vr_tab_craphis typ_tab_craphis;

      ------------------------------- VARIAVEIS -------------------------------
      vr_dtrefere     DATE;
      vr_dstextab     craptab.dstextab%TYPE;
      vr_tab_dtiniiof DATE;
      vr_tab_dtfimiof DATE;
      vr_nraplica     NUMBER;
      vr_tab_txiofrda NUMBER;
      vr_dtinipmf     DATE;
      vr_dtfimpmf     DATE;
      vr_txcpmfcc     NUMBER;
      vr_txrdcpmf     NUMBER;
      vr_indabono     INTEGER;
      vr_dtiniabo     DATE;
      vr_cdsitrpp     craprpp.cdsitrpp%TYPE;
      vr_vlsldtot     NUMBER;
      vr_vlprerpp     NUMBER;
      vr_vlaplica     NUMBER;

      vr_cdhistor     NUMBER;
      vr_inhistor     craphis.inhistor%TYPE;
      vr_indoipmf     craphis.indoipmf%TYPE;
      vr_txdoipmf     craphis.txdoipmf%TYPE;
      vr_cdempres     crapttl.cdempres%TYPE;
      vr_nrdocmto     VARCHAR(30);
      vr_vlabcpmf     craprpp.vlabcpmf%TYPE;
      vr_vlabdiof     craprpp.vlabdiof%TYPE;
      vr_geraavis     BOOLEAN;
      vr_indebito     INTEGER;
      vr_dtdebito     craprpp.dtdebito%TYPE;
      vr_dtultdeb     craprpp.dtdebito%TYPE;
      vr_cdturnos     crapttl.cdturnos%TYPE;
      vr_path_arquivo VARCHAR2(500);
      vr_commit       NUMBER;
      
      -- variaveis de escrita CLOB
      vr_des_xml         CLOB;
      vr_texto_completo  VARCHAR2(32600);
            
      --------------------------- SUBROTINAS INTERNAS --------------------------

      --limpa as tabelas temporarias
      PROCEDURE pc_limpa_tabela IS
      BEGIN
        --limpando a tabela temporaria
        vr_tab_crapsld.delete;
        --limpando a tabela temporaria de associados
        vr_tab_crapass.delete;
        --limpa a tabela de titulares
        vr_tab_crapttl.delete;
        --limpa a tabela de pessoas juridicas
        vr_tab_crapjur.delete;
        --limpa a tabela de historicos
        vr_tab_craphis.delete;
      END;  
      
    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
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
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
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

      /* Tratamento e retorno de valores de restart */
      BTCH0001 .pc_valida_restart(pr_cdcooper => pr_cdcooper
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
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      --busca o primeiro dia do mês
      vr_dtrefere := TRUNC(rw_crapdat.dtmvtolt,'MONTH') - 1;
      
      /*  Tabela com a taxa do IOF */
      vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'USUARI'
                                                ,pr_cdempres => 11
                                                ,pr_cdacesso => 'CTRIOFRDCA'
                                                ,pr_tpregist => 1);

      -- se nao encontrar o parametro, aborta a execucao
      IF TRIM(vr_dstextab) IS NULL THEN
        -- gera critica 626 - Falta tabela da aliquota do IOF sobre emprestimos
        vr_cdcritic := 626;
        -- finaliza a execucao
        RAISE vr_exc_saida;
      END IF;

      --periodo inicial da iof
      vr_tab_dtiniiof := TO_DATE(SUBSTR(vr_dstextab,1,10), 'DD/MM/YYYY');

      --periodo final da iof                        
      vr_tab_dtfimiof := TO_DATE(SUBSTR(vr_dstextab,12,10), 'DD/MM/YYYY');
                              
      --ajusta valor da tarifa de iof conforme periodo selecionado
      IF rw_crapdat.dtmvtolt >= vr_tab_dtiniiof AND 
         rw_crapdat.dtmvtolt <= vr_tab_dtfimiof THEN 
        vr_tab_txiofrda := TO_NUMBER(SUBSTR(vr_dstextab,23,16));
      ELSE 
        vr_tab_txiofrda := 0;
      END IF;  

      --busca informacoes da cpmf
      GENE0005.pc_busca_cpmf( pr_cdcooper => pr_cdcooper
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                             ,pr_dtinipmf => vr_dtinipmf
                             ,pr_dtfimpmf => vr_dtfimpmf
                             ,pr_txcpmfcc => vr_txcpmfcc 
                             ,pr_txrdcpmf => vr_txrdcpmf
                             ,pr_indabono => vr_indabono
                             ,pr_dtiniabo => vr_dtiniabo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
      /*tabelas temporarias*/

      --limpando as tabelas temporarias
      pc_limpa_tabela;
      
      --carregando a tabela de saldos
      FOR rw_crapsld IN cr_crapsld(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapsld(rw_crapsld.nrdconta).nrdconta := rw_crapsld.nrdconta;
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblfp := rw_crapsld.vlsdblfp;
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsdbloq := rw_crapsld.vlsdbloq;
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblpr := rw_crapsld.vlsdblpr;
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsddisp := rw_crapsld.vlsddisp;
        vr_tab_crapsld(rw_crapsld.nrdconta).vlipmfap := rw_crapsld.vlipmfap;
        vr_tab_crapsld(rw_crapsld.nrdconta).vlipmfpg := rw_crapsld.vlipmfpg;
        vr_tab_crapsld(rw_crapsld.nrdconta).id       := rw_crapsld.rowid;
      END LOOP;

      --seleciona os cooperados
      FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapass(rw_crapass.nrdconta).nrdconta := rw_crapass.nrdconta;
        vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
        vr_tab_crapass(rw_crapass.nrdconta).vllimcre := rw_crapass.vllimcre;
        vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
        vr_tab_crapass(rw_crapass.nrdconta).cdsecext := rw_crapass.cdsecext;
        vr_tab_crapass(rw_crapass.nrdconta).nrramemp := rw_crapass.nrramemp;
        vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
      END LOOP;      
      
      --carrega a tabela temporaria de titulares
      FOR rw_crapttl IN cr_crapttl(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapttl(rw_crapttl.nrdconta).cdempres := rw_crapttl.cdempres;
        vr_tab_crapttl(rw_crapttl.nrdconta).cdturnos := rw_crapttl.cdturnos;
      END LOOP;  

      --carrega a tabela temporaria de pessoas juridicas
      FOR rw_crapjur IN cr_crapjur(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapjur(rw_crapjur.nrdconta).cdempres := rw_crapjur.cdempres;
      END LOOP;  
      
      --carrega a tabela de historicos
      FOR rw_craphis IN cr_craphis(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_craphis(rw_craphis.cdhistor).cdhistor := rw_craphis.cdhistor;
        vr_tab_craphis(rw_craphis.cdhistor).inhistor := rw_craphis.inhistor;
        vr_tab_craphis(rw_craphis.cdhistor).indoipmf := rw_craphis.indoipmf;
      END LOOP; 


      --inicializando a variavel de controle de commit para o restart
      vr_commit := 0;
      --percorre os lancamentos de poupanca programada
      FOR rw_craprpp IN cr_craprpp( pr_cdcooper => pr_cdcooper
                                   ,pr_nrctares => nvl(vr_nrctares,0)
                                   ,pr_nrctrrpp => nvl(vr_nrctares,0)
                                   ,pr_dtdebito => rw_crapdat.dtmvtolt) 
      LOOP
        -- Limpa variaveis de critica
        vr_cdcritic := NULL;
        vr_dscritic := NULL;

        --armazenando a situacao poupanca programada 
        vr_cdsitrpp := rw_craprpp.cdsitrpp;

        --se situacao da poupanca programada igual a 2-suspenso e 
        --a data do debito igual a data de reinicio do debito do plano.
        IF vr_cdsitrpp = 2 AND rw_craprpp.dtdebito = rw_craprpp.dtrnirpp THEN
          --muda a situacao para 1-ativo
          vr_cdsitrpp := 1;
        END IF;

        --se poupanca programada estiver ativa
        IF vr_cdsitrpp  = 1 THEN
          /* Calcula o Saldo */
          
          /*FIND crapsld OF craprpp NO-LOCK NO-ERROR.*/
          IF NOT vr_tab_crapsld.EXISTS(rw_craprpp.nrdconta) THEN 
            --010 - Associado sem registro de saldo!!! - ERRO DO SISTEMA!!!
            vr_cdcritic := 10;
            
            --gerando a excecao
            RAISE vr_exc_saida;
          END IF;

          --Se o associado existir
          IF vr_tab_crapass.EXISTS(rw_craprpp.nrdconta) THEN
            --verifica se eh pessoa fisica
            IF vr_tab_crapass(rw_craprpp.nrdconta).inpessoa = 1 THEN 
              --verifica se o titular estiver cadastrado
              IF vr_tab_crapttl.EXISTS(rw_craprpp.nrdconta) THEN
                --armazena o codigo da empresa
                vr_cdempres := vr_tab_crapttl(rw_craprpp.nrdconta).cdempres;
              END IF;     
            ELSE--busca no cadastro de pessoa juridica
              IF vr_tab_crapjur.EXISTS(rw_craprpp.nrdconta) THEN
                --armazena o codigo da empresa
                vr_cdempres := vr_tab_crapjur(rw_craprpp.nrdconta).cdempres;
              END IF;     
            END IF;
          ELSE
            --critica 251 - Associado nao encontrado no crapass. ERRO DE SISTEMA.
            vr_cdcritic := 251;
            --abortando a execucao do programa
            RAISE vr_exc_saida;
          END IF;
          
          --acumulando o valor total do saldo
          vr_vlsldtot := vr_tab_crapsld(rw_craprpp.nrdconta).vlsddisp +
                         vr_tab_crapsld(rw_craprpp.nrdconta).vlipmfap - 
                         vr_tab_crapsld(rw_craprpp.nrdconta).vlipmfpg;

          --inicializando a variavel de controle
          vr_cdhistor := 0;
          
          --verifica todos os lancamentos do associado com historicos 
          --diferente de 289
          FOR rw_craplcm IN cr_craplcm( pr_cdcooper =>  pr_cdcooper
                                       ,pr_nrdconta =>  rw_craprpp.nrdconta
                                       ,pr_dtmvtolt =>  rw_crapdat.dtmvtolt) 
          LOOP
            --verifica se é quebra de historico
            IF vr_cdhistor <> rw_craplcm.cdhistor THEN

              --verifica se o historico existe
              IF NOT vr_tab_craphis.EXISTS(rw_craplcm.cdhistor) THEN
                --083 - Historico desconhecido no lancamento.
                vr_cdcritic := 83;
                
                -- Buscar a descrição
                vr_dscritic := LPAD(rw_craplcm.cdhistor,4,'0') || ' ' || gene0001.fn_busca_critica(vr_cdcritic);

                --atribui o codigo do historico para a variavel de controle
                vr_cdhistor := rw_craplcm.cdhistor;
                
                --reinicializa a variaveis
                vr_inhistor := 0;
                vr_indoipmf := 0;
                vr_txdoipmf := 0;
                
                --ajusta o codigo da critica para o valor inicial
                vr_cdcritic := 0; 
              ELSE
                --atualizando as variaveis de controle
                vr_cdhistor := rw_craplcm.cdhistor;
                vr_inhistor := vr_tab_craphis(rw_craplcm.cdhistor).inhistor;
                vr_indoipmf := vr_tab_craphis(rw_craplcm.cdhistor).indoipmf;
                vr_txdoipmf := vr_txcpmfcc;

                --se o abono = 0 e historico estiver na lista abaixo 
                IF vr_indabono = 0 AND rw_craplcm.cdhistor IN (114,127,160,177) THEN
                  vr_indoipmf := 1;
                  vr_txdoipmf := 0;
                END IF;           
              END IF;  
            END IF;
            --se abono zero e historico dentro da lista abaixo
            IF vr_indabono = 0   AND
               (rw_craplcm.cdhistor = 186 OR
                rw_craplcm.cdhistor = 498 OR
                rw_craplcm.cdhistor = 187 OR
                rw_craplcm.cdhistor = 500) THEN
              --acumula o saldo    
              vr_vlsldtot := nvl(vr_vlsldtot,0) - (TRUNC((rw_craplcm.vllanmto * vr_txcpmfcc),2));
            END IF;
            
            --verifica o indicador de indicador de incidencia do IPMF  
            IF vr_inhistor = 1 THEN
              /* Inicia tratamento CPMF */
              IF vr_indoipmf = 2 THEN
                --acumula o saldo
                vr_vlsldtot := nvl(vr_vlsldtot,0) + (TRUNC(rw_craplcm.vllanmto *(1 + vr_txdoipmf),2));
              ELSE
                /* Termina tratamento CPMF */
                vr_vlsldtot := nvl(vr_vlsldtot,0) + rw_craplcm.vllanmto;
              END IF;
            END IF;
             
            IF vr_inhistor = 11 THEN
              /* Inicia tratamento CPMF */
              IF vr_indoipmf = 2 THEN
                --acumula o saldo
                vr_vlsldtot := nvl(vr_vlsldtot,0) - (TRUNC(rw_craplcm.vllanmto * (1 + vr_txdoipmf),2));
              ELSE
                /* Termina tratamento CPMF */
                vr_vlsldtot := nvl(vr_vlsldtot,0) - rw_craplcm.vllanmto;
              END IF;
            END IF;  
          END LOOP;  /* For each craplcm */

          -- valdia se existe saldo pendente de aporte
          IF (rw_craprpp.vlsppant > 0) THEN
              vr_vlprerpp :=  rw_craprpp.vlsppant;
          ELSE
              vr_vlprerpp := rw_craprpp.vlprerpp;
          END IF;
      
          --se o valor da prestacao da poupanca programada for menor ou igual ao saldo acumulado
          IF vr_vlprerpp <= vr_vlsldtot THEN
             vr_vlaplica := vr_vlprerpp;
          ELSE
             IF ((rw_craprpp.flgdebito_parcial = 1) AND (rw_craprpp.vlminimo <= vr_vlsldtot)) THEN
                vr_vlaplica := vr_vlsldtot;
             ELSE
                vr_vlaplica := 0;
             END IF;
          END IF;

          IF vr_vlaplica > 0 THEN
              -- Inserir nova aplicação 
              -- Leitura de carencias do produto informado
              apli0005.pc_obtem_carencias(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                         ,pr_cdprodut => rw_craprpp.cdprodut   -- Codigo do Produto 
                                         ,pr_cdcritic => vr_cdcritic   -- Codigo da Critica
                                         ,pr_dscritic => vr_dscritic   -- Descricao da Critica
                                         ,pr_tab_care => vr_tab_care); -- Tabela com registros de Carencia do produto    

               IF vr_dscritic IS NULL THEN
                   SAVEPOINT APLICA_APL_PROG;
                   apli0005.pc_cadastra_aplic(pr_cdcooper => pr_cdcooper,
                                              pr_cdoperad => '1',
                                              pr_nmdatela => 'CRPS145',
                                              pr_idorigem => 5,
                                              pr_nrdconta => rw_craprpp.nrdconta,
                                              pr_idseqttl => 1,
                                              pr_nrdcaixa => rw_craprpp.cdbccxlt,
                                              pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                              pr_cdprodut => rw_craprpp.cdprodut,
                                              pr_qtdiaapl => vr_tab_care(1).qtdiaprz,
                                              pr_dtvencto => rw_crapdat.dtmvtolt + vr_tab_care(1).qtdiaprz,
                                              pr_qtdiacar => vr_tab_care(1).qtdiacar,
                                              pr_qtdiaprz => vr_tab_care(1).qtdiaprz,
                                              pr_vlaplica => vr_vlaplica,
                                              pr_iddebcti => 0,
                                              pr_idorirec => 0,
                                              pr_idgerlog => 1,
                                              pr_nrctrrpp => rw_craprpp.nrctrrpp, -- Número da RPP
                                              pr_nraplica => vr_nraplica,
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic);
                  IF (vr_cdcritic IS NOT NULL) OR (vr_dscritic IS NOT NULL) THEN
                    /* Se deu critica nessa conta, vamos desfazer o processo dela e logar */
                    ROLLBACK TO APLICA_APL_PROG;
                    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                        ,pr_cdoperad => '1'
                                        ,pr_dscritic => vr_dscritic
                                        ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => 5,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                                        ,pr_dstransa => 'INCLUSAO APLICACAO PROGRAMADA'
                                        ,pr_dttransa => TRUNC(SYSDATE)
                                        ,pr_flgtrans => 1 --> TRUE
                                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                        ,pr_idseqttl => 1
                                        ,pr_nmdatela => 'CRPS145'
                                        ,pr_nrdconta => rw_craprpp.nrdconta
                                        ,pr_nrdrowid => vr_nrdrowid);
                  END IF;
              END IF;  
            END IF;

          --se o valor da prestacao da poupanca programada for menor ou igual ao saldo acumulado
          IF ((vr_vlaplica > 0) AND (vr_dscritic IS NULL)) THEN
            --atualiza a tabela craprpp
            BEGIN
              UPDATE craprpp SET vlprepag = rw_craprpp.vlprepag + vr_vlaplica
                                ,qtprepag = rw_craprpp.qtprepag + 1
                                ,vlabcpmf = vr_vlabcpmf
                                ,vlabdiof = vr_vlabdiof
              WHERE ROWID = rw_craprpp.rowid;                             
            EXCEPTION                                
              WHEN OTHERS THEN
                --descricao da critica
                vr_dscritic := 'Erro ao atualizar a tabela craprpp. '||SQLERRM;
                --aborta a execucao
                RAISE vr_exc_saida;
            END;  
            --informa que deve ser gerado o aviso
            vr_geraavis := TRUE;
            
            --verifica os avisos de debito
            OPEN cr_crapavs ( pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => rw_craprpp.nrdconta
                             ,pr_dtrefere => vr_dtrefere
                             ,pr_cdempres => vr_cdempres
                             ,pr_cdagenci => vr_tab_crapass(rw_craprpp.nrdconta).cdagenci
                             ,pr_cdsecext => vr_tab_crapass(rw_craprpp.nrdconta).cdsecext
                             ,pr_nrdocmto => rw_craprpp.nrctrrpp);
            FETCH cr_crapavs INTO rw_crapavs;
            
            --se existir o aviso de debito
            IF cr_crapavs%FOUND THEN
              --marca para não gerar o aviso
              vr_geraavis := FALSE;
            END IF;  
            --fecha o cursor  
            CLOSE cr_crapavs;

          ELSE -- erro na inclusão da aplicação
                               
            --criando novo registro de lancamentos de aplicaoes de poupanca programada
            BEGIN
              INSERT INTO craprej( dtmvtolt
                                  ,cdagenci
                                  ,cdbccxlt
                                  ,nrdconta
                                  ,nraplica
                                  ,vllanmto
                                  ,cdcritic
                                  ,cdcooper
              ) VALUES ( rw_craprpp.dtdebito                          --craprej.dtmvtolt
                        ,vr_tab_crapass(rw_craprpp.nrdconta).cdagenci --craprej.cdagenci
                        ,145                                          --craprej.cdbccxlt
                        ,rw_craprpp.nrdconta                          --craprej.nrdconta
                        ,rw_craprpp.nrctrrpp                          --craprej.nraplica
                        ,vr_vlprerpp                         --craprej.vllanmto
                        ,485                                          --craprej.cdcritic
                        ,pr_cdcooper                                  --craprej.cdcooper
              ); 
            EXCEPTION
              WHEN OTHERS THEN
                --descricao da critica
                vr_dscritic := 'Erro ao criar registro na tabela craprej. '||SQLERRM;
                --aborta a execucao
                RAISE vr_exc_saida;
            END;  

          END IF;  --IF vr_vlprerpp <= vr_vlsldtot THEN
        END IF; -- Poupanca ativa

        IF TO_NUMBER(TO_CHAR(rw_craprpp.dtinirpp, 'DD')) < 11 THEN 
          --verifica os avisos de debito
          OPEN cr_crapavs ( pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_craprpp.nrdconta
                           ,pr_dtrefere => vr_dtrefere
                           ,pr_cdempres => vr_cdempres
                           ,pr_cdagenci => vr_tab_crapass(rw_craprpp.nrdconta).cdagenci
                           ,pr_cdsecext => vr_tab_crapass(rw_craprpp.nrdconta).cdsecext
                           ,pr_nrdocmto => rw_craprpp.nrctrrpp);
          FETCH cr_crapavs INTO rw_crapavs;
              
          --se existir o aviso de debito
          IF cr_crapavs%FOUND THEN
            --fecha o cursor  
            CLOSE cr_crapavs;
            
            --atualizando o flag da tabela de avisos de debito para true
            BEGIN
              UPDATE crapavs SET crapavs.flgproce = 1
              WHERE  crapavs.rowid = rw_crapavs.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                --descricao da critica
                vr_dscritic := 'Erro ao atualizar crapavs. '||SQLERRM;
                --aborta a execucao
                RAISE vr_exc_saida;
              END; 
               
          ELSE
            --fecha o cursor  
            CLOSE cr_crapavs;
          END IF;  
        END IF;--IF TO_NUMBER(TO_CHAR(rw_craprpp.dtinirpp, 'DD')) < 11 THEN 
        
        /* Regra antiga do vr_indebito
        -- se o mes/ano do debito for igual a data do movimento
        IF TO_CHAR(rw_craprpp.dtdebito,'MMYYYY') = TO_CHAR(rw_crapdat.dtmvtolt,'MMYYYY') THEN  
          vr_indebito := 0;
        --se a data do debito eh menor que a data do movimento e maior que a 
        --data do movimento do ultimo movimento
        ELSIF rw_craprpp.dtdebito < rw_crapdat.dtmvtolt AND
              rw_craprpp.dtdebito > rw_crapdat.dtmvtoan THEN  
          vr_indebito := 0;  
        ELSE  
          vr_indebito := 1;  
        END IF;   */
        
        /* Carrega nova data de proximo debito */
        vr_dtdebito := add_months(rw_craprpp.dtdebito,1);

        /* Precaucao: a proxima data de debito sempre devera ser superior a data atual,
           caso contrario podemos ficar raspando a conta muitas vezes ate que a data fique maior que a atual */
        IF rw_crapdat.dtmvtolt > vr_dtdebito THEN
          LOOP 
            EXIT WHEN rw_crapdat.dtmvtolt < vr_dtdebito;
            vr_dtdebito := add_months(vr_dtdebito,1);
          END LOOP;
        END IF;

        /* Ultimo dia para debito da parcela atual = dia anterior ao proximo debito*/
        vr_dtultdeb := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt  => (vr_dtdebito - 1)
                                                  ,pr_tipo      => 'A'
                                                  ,pr_feriado   => true
                                                  ,pr_excultdia => true);
        
        --atualizado a tabela de poupanca programada
        IF vr_dscritic IS NULL THEN
          BEGIN
            IF (rw_craprpp.flgteimosinha = 1)      AND  -- teimosinha ativa
               (rw_crapdat.dtmvtolt < vr_dtultdeb) AND  -- até data ultima data possivel de debito, antes de virar o mes             
               (vr_vlaplica < vr_vlprerpp)         THEN -- debitou parcial
                
                UPDATE craprpp SET dtaltrpp = rw_crapdat.dtmvtolt
                                  ,vlsppant = vr_vlprerpp - vr_vlaplica
                WHERE craprpp.rowid = rw_craprpp.rowid;                    
                
            ELSE              
                /* Sempre que mudar a data do debito para o mes seguinte 
                   o indebito devera ser zerado */  
                vr_indebito := 0;
            
                UPDATE craprpp SET indebito = vr_indebito
                                  ,cdsitrpp = vr_cdsitrpp
                                  ,dtdebito = vr_dtdebito
                                  ,vlsppant = 0
                WHERE craprpp.rowid = rw_craprpp.rowid;                    
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              --gerando a critica
              vr_dscritic := 'Erro ao atualizar a tabela craprpp para a conta '||rw_craprpp.nrdconta||'. '||SQLERRM;
              --abortando o sistema
              RAISE vr_exc_saida;
            END;                  
        END IF;
        
        --se o programa controla restart, atualiza o numero da conta processada
        IF pr_flgresta = 1 THEN
          --Atualizar tabela de restart
          BEGIN
            
            UPDATE crapres SET crapres.nrdconta = LPAD(rw_craprpp.nrdconta,7,'0')
            WHERE crapres.cdcooper = pr_cdcooper
            AND   upper(crapres.cdprogra) = vr_cdprogra;
            
            --Se nao atualizou nada
            IF SQL%ROWCOUNT = 0 THEN
              --Buscar mensagem de erro da critica
              vr_cdcritic := 151;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' CONTA = '||gene0002.fn_mask_conta(rw_craprpp.nrdconta);
              --Sair do programa
              RAISE vr_exc_saida;
            END IF;
            
          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela crapres. '||SQLERRM;
            --Sair do programa
            RAISE vr_exc_saida;
          END;

          -- faz commit a cada mil registros
          IF MOD(vr_commit, 1000) = 0 THEN
            --grava as informacoes processadas ateh o momento
            COMMIT;
          END IF;  
        END IF;  
        
        --contador para controlar o commit do controle de restart
        vr_commit := vr_commit + 1;
        
      END LOOP;--FOR rw_craprpp IN cr_craprpp( pr_cdcooper => pr_cdcooper                             

      --------------------------------------------------------------
      -- iniciando a geracao do relatorio crrl120.lst
      --------------------------------------------------------------
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      
      -- iniciando o xml
      gene0002.pc_escreve_xml(vr_des_xml,
                              vr_texto_completo,
                              '<?xml version="1.0" encoding="utf-8"?><crrl120>'||chr(13));
      
      --busca os debitos rejeitados
      FOR rw_craprej IN cr_craprej(pr_cdcooper => pr_cdcooper)
      LOOP
        --inicializando a variavel
        vr_cdturnos := NULL;
        
        --verifica se o associado esta cadastrado
        IF NOT vr_tab_crapass.EXISTS(rw_craprej.nrdconta) THEN
          --gerando critica
          vr_cdcritic := 9; --009 - Associado nao cadastrado.
          -- abortando a execucao do programa 
          RAISE vr_exc_saida;          
        END IF;  

        --verifica se eh pessoa fisica
        IF vr_tab_crapass(rw_craprej.nrdconta).inpessoa = 1 THEN 
          --verifica se o titular estiver cadastrado
          IF vr_tab_crapttl.EXISTS(rw_craprej.nrdconta) THEN
            --armazena o codigo da empresa
            vr_cdempres := vr_tab_crapttl(rw_craprej.nrdconta).cdempres;
            vr_cdturnos := vr_tab_crapttl(rw_craprej.nrdconta).cdturnos;
          END IF;     
        ELSE--busca no cadastro de pessoa juridica
          IF vr_tab_crapjur.EXISTS(rw_craprej.nrdconta) THEN
            --armazena o codigo da empresa
            vr_cdempres := vr_tab_crapjur(rw_craprej.nrdconta).cdempres;
          END IF;     
        END IF;
        -- gerando as informacoes
        gene0002.pc_escreve_xml(vr_des_xml,
                                vr_texto_completo,
                                '<registro idregistro="'||rw_craprej.rowid||'">'||
                                  '<cdagenci>'||rw_craprej.cdagenci||'</cdagenci>'||
                                  '<dsagenci>'||lpad(rw_craprej.cdagenci,3,' ')||' - '||nvl(rw_craprej.nmresage,'PA NAO CADASTRADO')||'</dsagenci>'||
                                  '<nrdconta>'||TO_CHAR(rw_craprej.nrdconta,'9999G999G9')||'</nrdconta>'||
                                  '<cdempres>'||vr_cdempres||'</cdempres>'||
                                  '<cdturnos>'||vr_cdturnos||'</cdturnos>'||
                                  '<dtmvtolt>'||rw_craprej.dtmvtolt||'</dtmvtolt>'||
                                  '<nrramemp>'||nvl(vr_tab_crapass(rw_craprej.nrdconta).nrramemp,'0')||'</nrramemp>'||
                                  '<nraplica>'||gene0002.fn_mask(rw_craprej.nraplica,'zzz.zzz.zz9')||'</nraplica>'||
                                  '<vllanmto>'||rw_craprej.vllanmto||'</vllanmto>'||
                                  '<nmprimtl>'||vr_tab_crapass(rw_craprej.nrdconta).nmprimtl||'</nmprimtl>'||
                                '</registro>'||chr(13));
      END LOOP;  
      
      --excluindo informacoes da tabela de rejeicoes
      BEGIN
        DELETE FROM craprej 
        WHERE craprej.cdcooper = pr_cdcooper 
        AND   craprej.cdbccxlt = 145          
        AND   craprej.cdcritic = 485; --485 - Debito nao efetuado.
      EXCEPTION
        WHEN OTHERS THEN
          --gerando critica
          vr_dscritic := 'Erro ao excluir os registro de debitos rejeitados. '||SQLERRM;
          --abortando a execucao
          RAISE vr_exc_saida;
      END;  

      --finalizando o xml
      gene0002.pc_escreve_xml(vr_des_xml,
                              vr_texto_completo,
                              '</crrl120>'||chr(13), TRUE);
      
      -- Busca do diretório base da cooperativa e a subpasta de relatórios
      vr_path_arquivo := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_nmsubdir => '/rl'); --> Gerado no diretorio /rl
      -- Gerando o relatório 
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdprogra  => vr_cdprogra
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dsxml     => vr_des_xml
                                 ,pr_dsxmlnode => '/crrl120/registro'
                                 ,pr_dsjasper  => 'crrl120.jasper'
                                 ,pr_dsparams  => ''
                                 ,pr_dsarqsaid => vr_path_arquivo || '/crrl120_'||to_char( gene0002.fn_busca_time )||'.lst'
                                 ,pr_flg_gerar => 'N'
                                 ,pr_qtcoluna  => 132
                                 ,pr_sqcabrel  => 1
                                 ,pr_flg_impri => 'S'
                                 ,pr_nmformul  => ''
                                 ,pr_nrcopias  => 1
                                 ,pr_des_erro  => vr_dscritic);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      --Zerar tabela de memoria auxiliar
      pc_limpa_tabela;

      /* Eliminação dos registros de restart */
      BTCH0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_flgresta => pr_flgresta
                                 ,pr_des_erro => vr_dscritic);
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Exceção
        RAISE vr_exc_saida;
      END IF;
      
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN

        --Zerar tabela de memoria auxiliar
        pc_limpa_tabela;
        
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
        --Zerar tabela de memoria auxiliar
        pc_limpa_tabela;

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
        --Zerar tabela de memoria auxiliar
        pc_limpa_tabela;

        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps145;
