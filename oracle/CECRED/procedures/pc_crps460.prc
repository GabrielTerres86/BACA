CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS460(pr_cdcooper  IN craptab.cdcooper%TYPE --> Cooperativa solicitada
                                             ,pr_flgresta  IN PLS_INTEGER            --> Flag 0/1 para utilizar restart na chamada
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Crítica encontrada
                                             ,pr_dscritic OUT VARCHAR2)  IS         --> Texto de erro/critica encontrada

/* .............................................................................

   Programa: Fontes/crps460.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio       
   Data    : Dezembro/2005.                  Ultima atualizacao: 24/07/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Atende a solicitacao 082    Ordem 67.
               Gerar arquivo de pedido de cheques B. Brasil (Conta Integracao)
               para impressao na CECRED.
               Relatorios :  432, 433 e 434 (binario do cheque).

   Alteracoes: 25/01/2006 - Acerto no relatorio de criticas, estava listando
                            criticas de requisicoes anteriores.
                            O relatorio que sai as 13:30 nao estava salvando
                            no MTGED (Julio)

               09/02/2006 - Criada mensagem referente pedido taloes no
                            diretorio /micros/cecred/pedido (Diego).
                            
               17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               07/03/2006 - Acerto mensagem pedido taloes (Diego).

               30/03/2006 - Alterado diretorio de mensagem referente pedido
                            taloes (Diego).
                            
               02/01/2007 - Alterado para enviar talonarios do convenio Bancoob
                            (Ze).

               19/03/2007 - Padronizacao das colunas dos relatorios (Ze).
               
               16/04/2007 - Tratar sequencia do nro pedido atraves do gnsequt
                            Sequencia unica para todas as cooperativas (Ze).

               17/08/2007 - Incluida variaveis para armazenar as datas de
                            aberturas de conta mais antigas do cooperado no SFN
                            (Elton).

               07/11/2007 - Nao imprimir relatorios zerados (Julio).

               15/08/2008 - Aceitar qualquer compe (Magui).

               15/09/2008 - Acertado para gerar relatorio em PDF na Intranet
                            (Diego).

               02/12/2008 - Usar crapcop.cdageitg para banco = 1 e calcular 
                            digito da agencia (Guilherme).

               04/12/2009 - Imprimir 1 via do crrl433 com duas capas(Guilherme)

               30/09/2009 - Adaptacoes projeto IF CECRED (Guilherme).

               17/05/2009 - Tratar os cheques IF CECRED(Guilherme).

               10/02/2011 - Utilizar campo "Nome no talao" - crapttl (Diego).

               06/10/2011 - Incluir a data de confecção no arquivo de dados
                            (Isara - RKAM).

               15/10/2012 - Incluido tratamento para nome da logo de cheque da 
                            cooperativa Viacredi Alto Vale (Diego).             

               11/04/2013 - Ajuste no arquivo de controle para o crrl433
                            (Daniele).

               13/05/2013 - Ajuste no arquivo de controle para o crrl433 (Ze).

               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Andre Euzebio - Supero).

               02/01/2014 - Retirado comando unix que diz respeito a
                            "Fila de impressao" (Tiago). 

               26/05/2014 - Retirado mensagem do log, "NAO HA REQUISICOES PARA 
                            CHEQUES AVULSO E/OU TB", conforme chamado: 144959, 
                            data: 02/04/2014
                            do log: crrl999_viacredi_02042014. Jéssica (DB1).

               06/06/2014 - Alterado o caminho dos relatorios, de salvar/ para
                            rl/. Tambem criada rotina para copiar os relatorios
                            apenas no fim para o salvar/  (Guilherme/SUPERO)
               
               11/06/2014 - Conversão Progress >> Oracle (Renato - Supero)
               
               05/03/2015 - Ajustar erro no processo, referente a duas solicitações
                            de cheque realizado no mesmo dia pelo mesmo cooperado.
                            Devido a erro na forma de calculo da sequencia de cheques
                            o programa estava apresentando estouro de chave ( Renato - Darosci )
                            
                            
               07/04/2015 - Incluso tratamento para salva alteração na gnsequt 
                            para evitar lock (Daniel)    
                            
               10/04/2015 - Realizado tratamento com pragma para não deixar a gnsequt
                            com lock, após a atualização do número do pedido ( Renato - Supero )

               24/07/2017 - Alterar cdoedptl para idorgexp.
                            PRJ339-CRM  (Odirlei-AMcom)             

			   24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).


............................................................................. */

  -- CURSORES
  -- Buscar informações da cooperativa
  CURSOR cr_crapcop IS
    SELECT crapcop.dsdircop
         , crapcop.nmrescop
         , LPAD(crapcop.cdbcoctl,3,0) cdbcoctl
         , crapcop.cdagectl
         , crapcop.cdagebcb
         , crapcop.cdageitg
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
       
  -- Buscar os dados do PA
  CURSOR cr_crapage(pr_cdagenci crapage.cdagenci%TYPE ) IS
    SELECT crapage.nmresage
      FROM crapage
     WHERE crapage.cdcooper = pr_cdcooper
       AND crapage.cdagenci = pr_cdagenci;
   
   
  -- Buscar os relatórios do programa
  CURSOR cr_crapprg IS
     SELECT crapprg.cdrelato##1
          , crapprg.cdrelato##2
          , crapprg.cdrelato##3
          , crapprg.cdrelato##4
          , crapprg.cdrelato##5
       FROM crapprg
      WHERE crapprg.cdcooper        = pr_cdcooper 
        AND UPPER(crapprg.cdprogra) = 'CRPS460'
        AND UPPER(crapprg.nmsistem) = 'CRED';
  
  -- REGISTROS
  TYPE typ_cdrelatos  IS TABLE OF craprel.cdrelato%TYPE INDEX BY PLS_INTEGER;
  -- Relatórios 432 e 433 e final do 433
  TYPE typ_crrl433    IS RECORD (idtipo    NUMBER
                                ,cdagenci  NUMBER
                                ,nmresage  VARCHAR2(30)
                                ,nrpedido  NUMBER
                                ,nrseqage  NUMBER
                                ,dsrelato  VARCHAR2(25)
                                ,nrdconta  NUMBER
                                ,nrctaitg  NUMBER
                                ,nrtalchq  NUMBER
                                ,nrinichq  NUMBER
                                ,nrfinchq  NUMBER
                                ,nmprimtl  VARCHAR2(100)
                                ,nmsegntl  VARCHAR2(100)
                                ,dtdemiss  DATE
                                ,dstipcta  VARCHAR2(50)
                                ,dssitdct  VARCHAR2(50)
                                ,qtreqtal  NUMBER
                                ,dscritic  VARCHAR2(50));
  TYPE typ_qtag433    IS RECORD (qttalage  NUMBER
                                ,qttalrej  NUMBER);
  TYPE typ_tbcrrl433  IS TABLE OF typ_crrl433 INDEX BY BINARY_INTEGER;
  TYPE typ_tbqtag433  IS TABLE OF typ_qtag433 INDEX BY BINARY_INTEGER;
  rw_crapcop          cr_crapcop%ROWTYPE;
  
  
  -- VARIÁVEIS  
  -- Código do programa
  vr_cdprogra      CONSTANT VARCHAR2(10) := 'CRPS460';
  -- Datas de movimento e controle
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;
  -- Dados BANCOOB
  vr_tpctaini      NUMBER;
  vr_tpctafim      NUMBER;
  vr_cdbanchq      NUMBER;
  vr_cdagechq      NUMBER;
  vr_nrcalcul      NUMBER;
  vr_cddigage      NUMBER;
  -- Diretório da cooperativa
  vr_dsdestin      VARCHAR2(100);
  -- Tabelas de memória de dados do relatório
  vr_relat433      typ_tbcrrl433;
  vr_qtdrl433      typ_tbqtag433;
  -- Flag para verificação do digito
  vr_flvrfdig      BOOLEAN;
  vr_flgdados      BOOLEAN;
  -- Variável de críticas
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(4000);
  -- Tratamento de erros
  vr_exc_saida     EXCEPTION;
  vr_exc_fimprg    EXCEPTION;

  -- Variáveis relativas aos arquivos
  vr_tab_cdrelato  typ_cdrelatos;
  
  --------------------------------------------------------------------------------
  -- Gerar talonario
  PROCEDURE pc_gera_talonario(pr_cdcooper IN     NUMBER
                             ,pr_dtmvtolt IN     DATE
                             ,pr_cdrelato IN     typ_cdrelatos
                             ,pr_inproces IN     NUMBER
                             ,pr_tpctaini IN     NUMBER
                             ,pr_tpctafim IN     NUMBER
                             ,pr_cdbanchq IN     NUMBER
                             ,pr_cdagenci IN OUT NUMBER
                             ,pr_cdcritic    OUT NUMBER
                             ,pr_dscritic    OUT VARCHAR2)  IS
                                   
    -- Requisições a serem atendidas, juntamente com o registro do banco informado
    CURSOR cr_crapreq IS
      SELECT crapreq.nrdconta
           , crapreq.rowid  idcrapreq
           , crapass.cdbcochq
           , crapass.flgctitg
           , crapass.nrdctitg
           , crapass.cdsitdct
           , crapass.cdsitdtl
           , crapass.inlbacen
           , crapass.nrflcheq
           , crapass.flchqitg
           , crapreq.qtreqtal
           , crapass.nmprimtl
           , crapass.inpessoa
           , crapass.tpdocptl
           , crapass.nrdocptl
           , org.cdorgao_expedidor cdoedptl
           , crapass.cdufdptl
           , crapreq.tprequis
           , crapass.cdagenci
           , crapreq.tpforchq
           , crapass.nrcpfcgc
           , crapass.dtabtcct
           , crapass.dtadmiss
           , crapass.cdtipcta
           , crapass.rowid   rowidass
           , ROW_NUMBER () over (PARTITION BY crapreq.tprequis ORDER BY crapreq.tprequis ) qttprequis
           , COUNT(1) over (PARTITION BY crapreq.tprequis) qttottpreq
           , (crapass.nrflcheq + 1)                nrflaini -- Folha inicial do talão
           , (crapass.nrflcheq + crapreq.qtreqtal) nrflafim -- Folha final do talão
        FROM crapass
           , crapreq
           , tbgen_orgao_expedidor org  
       WHERE crapass.cdcooper = crapreq.cdcooper
         AND crapass.nrdconta = crapreq.nrdconta 
         AND crapass.idorgexp = org.idorgao_expedidor(+)
         AND crapass.cdbcochq = pr_cdbanchq
         AND crapreq.cdcooper = pr_cdcooper     
         AND crapreq.insitreq = 1
         AND crapreq.cdtipcta BETWEEN pr_tpctaini AND pr_tpctafim
         AND ((crapreq.tprequis = 5 AND crapreq.tpforchq = 'A4') OR
              (crapreq.tprequis = 2 AND crapreq.tpforchq = 'TB'))
       ORDER BY crapreq.tprequis
              , crapreq.cdagenci
              , crapreq.nrdconta;
    
    -- Buscar novamente informaçoes da ASS
    CURSOR cr_nrflcheq(pr_rowid IN VARCHAR2) IS
      SELECT t.nrflcheq
        FROM crapass t
       WHERE t.rowid = pr_rowid;
    
    -- Requisições não atendidas
    CURSOR cr_crapreq_naoatd(pr_dtmvtolt  DATE) IS
      SELECT crapreq.nrdconta 
           , crapreq.rowid  idcrapreq
           , crapreq.cdagenci
           , crapreq.cdcritic
           , crapass.cdbcochq
           , crapass.flgctitg
           , crapass.nrdctitg
           , crapass.cdsitdct
           , crapass.cdsitdtl
           , crapass.inlbacen
           , crapass.nrflcheq
           , crapreq.qtreqtal
           , crapass.nmprimtl
           , crapass.inpessoa
           , crapass.tpdocptl
           , crapass.nrdocptl
           , org.cdorgao_expedidor cdoedptl
           , crapass.cdufdptl
           , crapass.cdtipcta
           , crapass.dtdemiss
           , ROW_NUMBER () over (PARTITION BY crapreq.tprequis ORDER BY crapreq.tprequis ) qttprequis
           , COUNT(1) over (PARTITION BY crapreq.tprequis) qttottpreq
        FROM crapass
           , crapreq           
           , tbgen_orgao_expedidor org  
       WHERE crapass.cdcooper = crapreq.cdcooper
         AND crapass.nrdconta = crapreq.nrdconta 
         AND crapass.cdbcochq = pr_cdbanchq
         AND crapreq.cdcooper = pr_cdcooper   
         AND crapreq.dtpedido = pr_dtmvtolt    
         AND crapreq.insitreq = 3
         AND crapreq.tprequis IN (2,5)  
         AND crapass.idorgexp = org.idorgao_expedidor(+)
       ORDER BY crapreq.tprequis
              , crapreq.cdagenci
              , crapreq.nrdconta;
    
    -- Buscar dados da agencia
    CURSOR cr_crapage(pr_cdagenci IN crapage.cdagenci%TYPE) IS
      SELECT crapage.nmresage
           , crapage.cdcomchq
           , crapage.cdagenci
           , crapage.dsinform##1
           , crapage.dsinform##2
           , crapage.dsinform##3
        FROM crapage
       WHERE crapage.cdcooper = pr_cdcooper     
         AND crapage.cdagenci = pr_cdagenci;
    rw_crapage   cr_crapage%ROWTYPE;
   
    -- Buscar data de abertura da conta corrente no Sistema Financeiro Nacional
    CURSOR cr_crapsfn(pr_nrcpfcgc  IN crapsfn.nrcpfcgc%TYPE) IS
      SELECT crapsfn.dtabtcct
        FROM crapsfn 
       WHERE crapsfn.cdcooper = pr_cdcooper     
         AND crapsfn.nrcpfcgc = pr_nrcpfcgc 
         AND crapsfn.tpregist = 1
       ORDER BY crapsfn.dtabtcct DESC;
    rw_crapsfn   cr_crapsfn%ROWTYPE;
    
    -- Buscar os dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cdcooper
           , nmrescop
           , dsendcop
           , nrendcop
           , nmbairro
           , nmcidade
           , cdufdcop
           , nrtelvoz
        FROM crapcop t
       WHERE t.cdcooper = pr_cdcooper;
    rw_crapcop   cr_crapcop%ROWTYPE;
    
    -- Buscar informação de titulares de conta
    CURSOR cr_crapttl(pr_nrdconta  crapttl.nrdconta%TYPE
                     ,pr_idseqttl  crapttl.idseqttl%TYPE) IS
      SELECT crapttl.nmtalttl
            ,crapttl.nmextttl
        FROM crapttl 
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta   
         AND crapttl.idseqttl = pr_idseqttl; -- Titular
    rw_crapttl     cr_crapttl%ROWTYPE;
    
    -- Buscar dados pessoa juridica
    CURSOR cr_crapjur(pr_nrdconta   crapttl.nrdconta%TYPE) IS
      SELECT crapjur.nmtalttl
        FROM crapjur 
       WHERE crapjur.cdcooper = pr_cdcooper  
         AND crapjur.nrdconta = pr_nrdconta;
    rw_crapjur   cr_crapjur%ROWTYPE;
    
    -- Buscar folhas de cheques emitidos para o cooperado.
    CURSOR cr_crapfdc(pr_nrdconta   crapfdc.nrdconta%TYPE
                     ,pr_nrpedido   crapfdc.nrpedido%TYPE
                     ,pq_tpcheque   crapfdc.tpcheque%TYPE
                     ,pr_nrflaini   crapfdc.nrcheque%TYPE
                     ,pr_nrflafim   crapfdc.nrcheque%TYPE ) IS
      SELECT crapfdc.nrdctitg
           , crapfdc.nrcheque
           , crapfdc.cdcmpchq
           , crapfdc.cdbanchq
           , crapfdc.nrdigchq
           , crapfdc.cdagechq
           , crapfdc.dsdocmc7
           , crapfdc.nrseqems
        FROM crapfdc
       WHERE crapfdc.cdcooper = pr_cdcooper     
         AND crapfdc.nrdconta = pr_nrdconta
         AND crapfdc.nrpedido = pr_nrpedido
         AND crapfdc.tpcheque = pq_tpcheque     
         AND crapfdc.dtemschq IS NULL
         AND crapfdc.nrcheque BETWEEN pr_nrflaini AND pr_nrflafim
       ORDER BY crapfdc.cdcooper
              , crapfdc.nrdconta
              , crapfdc.nrpedido
              , crapfdc.nrcheque;

    -- Buscar pelo tipo da conta
    CURSOR cr_craptip(pr_cdtipcta  craptip.cdtipcta%TYPE) IS
      SELECT dstipcta
        FROM craptip
       WHERE craptip.cdcooper = pr_cdcooper    
         AND craptip.cdtipcta = pr_cdtipcta;
    rw_craptip   cr_craptip%ROWTYPE;
    
    -- Buscar informações no cadastro de bancos
    CURSOR cr_crapban(pr_cdbanchq crapban.cdbccxlt%TYPE) IS
      SELECT crapban.nmresbcc
        FROM crapban
       WHERE crapban.cdbccxlt = pr_cdbanchq;
    rw_crapban   cr_crapban%ROWTYPE;
    
    -- Buscar as informações para o relatório
    CURSOR cr_craprel(pr_cdrelato  IN NUMBER) IS
      SELECT tprelato
           , nmrelato
        FROM craprel 
       WHERE craprel.cdcooper = pr_cdcooper 
         AND craprel.cdrelato = pr_cdrelato;
    rw_craprel   cr_craprel%ROWTYPE;
    
    -- Tipos/Registros
    TYPE typ_tbarquivos IS TABLE OF VARCHAR2(500) INDEX BY PLS_INTEGER;
    
    -- Variáveis
    -- Variáveis auxiliares
    vr_flvrfdig      BOOLEAN := FALSE;
    vr_nrindice      NUMBER;
    vr_cdcomchq      NUMBER; 
    -- Imagens
    vr_dsimgcop      VARCHAR2(100);
    -- Número do pedido
    vr_nrpedido      NUMBER;
    -- Variáveis auxiliares de relatório
    vr_qtfolhas      NUMBER;
    vr_qtfolhtb      NUMBER;
    vr_qtrejger      NUMBER;
    vr_qttalrej      NUMBER;
    vr_dssitdct      VARCHAR2(20);
    vr_nrcpfcgc      VARCHAR2(25);
    vr_qtdtaltb      NUMBER;
    vr_qttalger      NUMBER;
    vr_cdrelato      VARCHAR2(25);
    -- Diretório para geração de relatórios e arquivos
    vr_txtcompleto   VARCHAR2(32600);    --> Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_des_xml       CLOB;               --> XML do relatorio
    vr_dsdirlog      VARCHAR2(100);
    vr_utlfileh      UTL_FILE.file_type; -- handle arquivo
    -- Auxiliares para update
    vr_upd_insitreq  crapreq.insitreq%TYPE;
    vr_upd_cdcritic  crapreq.cdcritic%TYPE;
    vr_tpdocptl      crapass.tpdocptl%TYPE;
    vr_cdoedptl      tbgen_orgao_expedidor.cdorgao_expedidor%TYPE;
    vr_cdufdptl      crapass.cdufdptl%TYPE;
    vr_nrdocptl      crapass.nrdocptl%TYPE;
    -- Arquivos e diretórios                 
    vr_nmarqimp      typ_tbarquivos;
    vr_nmdireto      typ_tbarquivos;
    -- Demais variáveis
    vr_dschqesp      VARCHAR2(20);
    vr_dspathcop     VARCHAR2(1000);
    vr_tpcheque      NUMBER;
    vr_nrdctitg      NUMBER;
    vr_qtreqtal      NUMBER;
    vr_nrflcheq      NUMBER;
    vr_nrtalchq      NUMBER;
    vr_cddigtc1      NUMBER;
    vr_cddigtc2      NUMBER;
    vr_nrdigchq      NUMBER;
    vr_tprelato      NUMBER;
    vr_nmrelato      craprel.nmrelato%TYPE;
    vr_dsdbanco      VARCHAR2(50);
    vr_nmtitdes      VARCHAR2(100);
    vr_confecca      VARCHAR2(100);
    vr_nmarqchq      VARCHAR2(100);
    vr_nmdirchq      VARCHAR2(100);
    vr_dsdocmc7      VARCHAR2(500);
    vr_dstmpcta      VARCHAR2(50);
    vr_dscpfcgc      VARCHAR2(50);
    vr_nmprital      VARCHAR2(100);
    vr_nmsegtal      VARCHAR2(100);
    vr_dsconta1      VARCHAR2(100);
    vr_dsconta2      VARCHAR2(100);
    vr_dsconta3      VARCHAR2(100);
    vr_dsconta4      VARCHAR2(100);
    vr_dsctaitg      VARCHAR2(20);
    vr_nmarqtmp      VARCHAR2(50);
    vr_nmarqpdf      VARCHAR2(50);
    vr_dsender1      crapage.dsinform##1%TYPE;
    vr_dsender2      crapage.dsinform##2%TYPE;
    vr_dsender3      crapage.dsinform##3%TYPE;
    vr_dtabtcct      DATE;
    vr_dtabtcc2      DATE;
    -- Comando para executar o formprint
    vr_dscomand      VARCHAR2(500);
    -- Tratamento de erros do formprint
    vr_typ_said      VARCHAR2(50);
    vr_des_erro      VARCHAR2(2000);
    
    -- Verifica o digito da conta
    FUNCTION fn_ver_contaitg(pr_nrdctitg IN VARCHAR2) RETURN NUMBER IS 
    BEGIN
      -- Se o número for nulo
      IF NVL(pr_nrdctitg,0) = 0 THEN
        RETURN 0;
      ELSIF SUBSTR(pr_nrdctitg,LENGTH(pr_nrdctitg)) IN (1,2,3,4,5,6,7,8,9,0) THEN
        RETURN pr_nrdctitg;
      ELSE
        -- Retornar conta com dígito zero
        RETURN SUBSTR(pr_nrdctitg,1,LENGTH(pr_nrdctitg)-1)||'0';
      END IF;
    END fn_ver_contaitg; /* FUNCTION */
    
    -- verifica o CMC
    FUNCTION fn_cmc7(pr_nrindice NUMBER
                    ,pr_dsdocmc7 VARCHAR2) RETURN VARCHAR2 IS
      -- Variáveis
      vr_caract    VARCHAR2(1);
    
    BEGIN
      -- Separa o caracter a ser analizado
      vr_caract := SUBSTR(pr_dsdocmc7, pr_nrindice, 1);
   
      -- Verifica o caracter
      IF vr_caract = '<' THEN 
        RETURN 'laser/cmc7/cmc7-a.pcx';
      ELSIF vr_caract = '>' THEN 
        RETURN 'laser/cmc7/cmc7-b.pcx';
      ELSIF vr_caract = ':' THEN 
        RETURN 'laser/cmc7/cmc7-c.pcx';
      ELSE
        RETURN 'laser/cmc7/cmc7-'||vr_caract||'.pcx';
      END IF;
      
   END fn_cmc7;
   
   -- Controla a alteração da gnsequt
   PROCEDURE pc_altera_gnsequt IS
     
     -- Pragma - abre nova sessão para tratar a atualização
     PRAGMA AUTONOMOUS_TRANSACTION;
   
   BEGIN
     
     -- Tenta atualizar o registro de controle de sequencia
     UPDATE gnsequt
        SET gnsequt.vlsequtl = NVL(gnsequt.vlsequtl,0) + 1
      WHERE gnsequt.cdsequtl = 001
      RETURNING gnsequt.vlsequtl INTO vr_nrpedido;

     -- Se não alterar registros, ou alterar mais de 1
     IF SQL%ROWCOUNT = 0 THEN
       -- Faz rollback das informações
       ROLLBACK;
       -- Define o erro
       pr_cdcritic := 151;
       -- Critica 151 - Registro de restart nao encontrado
       RETURN;
     END IF;
     
     -- Comita os dados desta sessão
     COMMIT;
   EXCEPTION 
     WHEN OTHERS THEN 
       -- Retornar erro do update
       vr_dscritic := 'Erro ao atualizar GNSEQUT: '||SQLERRM;
       ROLLBACK; 
   END pc_altera_gnsequt;
   
  BEGIN
    
    -- buscar dados da cooperativa (não valida se existe, pois já foi validado no início do programa)
    OPEN  cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    CLOSE cr_crapcop;
    
    -- Rotina para controlar a atualização da gnsequt, sem que a mesma fique em lock
    pc_altera_gnsequt;
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    ELSIF NVL(pr_cdcritic,0) > 0 THEN
      -- Buscar a descrição da crítica
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      -- Envio centralizado de log de erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || pr_dscritic ); 
      
      -- Não retornar o erro... informar apenas no log
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      
      -- Sair do procedimento
      RETURN;
    END IF; -- SQL%ROWCOUNT

    -- Iniciar variáveis auxiliares de relatório
    vr_qtfolhas := 0;
    vr_qtfolhtb := 0;
    vr_qttalger := 0;
    vr_qtdtaltb := 0;
    
    -- Limpa a tabela de memória de arquivos
    vr_nmarqimp.DELETE;
    
    -- Limpa a tabela de memória de relatório
    vr_relat433.DELETE;
  
    -- Criar os arquivos
    vr_nmarqimp(1) := 'crrl432_'||to_char(vr_nrpedido, 'FM00000')||'.lst';
    vr_nmarqimp(2) := 'crrl433_'||to_char(vr_nrpedido, 'FM00000')||'.lst';
    vr_nmarqimp(3) := 'crrl434_'||to_char(vr_nrpedido, 'FM00000');
    
    -- Definir os diretórios conforme o inproces
    IF pr_inproces = 1  THEN
      vr_nmdireto(1) := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => 'rlnsv');
      -- Igual para arquivo 1 e 2
      vr_nmdireto(2) := vr_nmdireto(1);
    ELSE
      vr_nmdireto(1) := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => 'rl');
      -- Igual para arquivo 1 e 2
      vr_nmdireto(2) := vr_nmdireto(1);
    END IF;
    
    -- Arquivo 3
    vr_nmdireto(3) := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nmsubdir => 'salvar');
    
    -- Arquivo formPrint
    vr_nmdirchq    := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nmsubdir => 'arq');
     
    -- Definir o nome e caminho do arquivo PCX
    IF pr_cdcooper = 16  THEN                  
      vr_dsimgcop := 'laser/cmc7/viacredialtovale.pcx'; 
    ELSE
      vr_dsimgcop := 'laser/cmc7/'||lower(rw_crapcop.nmrescop)||'.pcx';
    END IF;
    
    -- Percorrer as requisições do banco informado, a serem atendidas 
    FOR rw_crapreq IN cr_crapreq LOOP
      
      -- Se não existe o registro para a agencia
      IF NOT vr_qtdrl433.EXISTS(rw_crapreq.cdagenci) THEN
        -- Quantidade de registros por agencia - quebra
        vr_qtdrl433(rw_crapreq.cdagenci).qttalage := 0;
        vr_qtdrl433(rw_crapreq.cdagenci).qttalrej := 0;
      END IF;      
    
      -- Se o tipo de conta inicio for igual a 12
      IF pr_tpctaini = 12 THEN
        -- Definir o nome do arquivo
        vr_nmarqchq := 'pd'||TO_CHAR(pr_cdcooper, 'FM000')||'-itg-'||TO_CHAR(vr_nrpedido, 'FM000000')||'-CECRED';
      ELSE
        -- Se o banco do Cheque for 756
        IF rw_crapreq.cdbcochq = 756  THEN
          vr_nmarqchq := 'pd'||TO_CHAR(pr_cdcooper, 'FM000')||'-bcb-'||to_char(vr_nrpedido, 'FM000000')||'-CECRED';
        ELSE
          vr_nmarqchq := 'pd'||TO_CHAR(pr_cdcooper, 'FM000')||'-ctr-'||TO_CHAR(vr_nrpedido, 'FM000000')||'-CECRED';
        END IF;
      END IF;
      -- Se o tipo da requisição for igual a 2
      IF rw_crapreq.tprequis = 2  THEN
        vr_nmarqchq := vr_nmarqchq || '-TB';
      END IF;        
      
      
      -- Se for o primeiro registro do tipo de requisição
      IF rw_crapreq.qttprequis = 1 THEN
        
        -- Cria o arquivo 
        GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirchq --> Diretorio do arquivo
                                ,pr_nmarquiv => vr_nmarqchq    --> Nome do arquivo
                                ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_utlfileh    --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);
        
        -- Se retornou erro
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Monta mensagem de erro
          vr_dscritic := 'Erro ao gerar arquivo '||vr_nmarqimp(3)||': '||vr_dscritic;
          -- Encerra o programa
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
      
      -- Novo índice para a tabela de memória
      vr_nrindice := NVL(vr_relat433.COUNT(),0) + 1;
      vr_flgdados := FALSE;
      
      -- Tipo de exibição 1 - para controle a nivel de iReport
      vr_relat433(vr_nrindice).idtipo   := 1;
      vr_relat433(vr_nrindice).cdagenci := pr_cdagenci; -- Inicializa com a agencia do parametro
      vr_relat433(vr_nrindice).nrpedido := vr_nrpedido;
      
      -- Buscar informações da agencia
      OPEN  cr_crapage(rw_crapreq.cdagenci);
      FETCH cr_crapage INTO rw_crapage;
      
      -- Se a agencia for diferente
      IF rw_crapreq.cdagenci <> pr_cdagenci THEN
        
        -- Guarda agencia para relatório
        vr_relat433(vr_nrindice).cdagenci := rw_crapreq.cdagenci;  
      
        -- Se não encontrou a agencia
        IF cr_crapage%NOTFOUND THEN
          vr_relat433(vr_nrindice).nmresage := LPAD('*',15,'*');
          vr_cdcomchq := 16;
        ELSE
          vr_relat433(vr_nrindice).nmresage := rw_crapage.nmresage;
          vr_cdcomchq := rw_crapage.cdcomchq;
        END IF;
      END IF;
      
      -- Fecha o cursor que busca dados da agencia
      CLOSE cr_crapage;
      
      -- Inicializa
      vr_relat433(vr_nrindice).nrseqage := 1;
      vr_relat433(vr_nrindice).cdagenci := rw_crapage.cdagenci;
      vr_cdcritic    := 0;
      
      -- Se o tipo de requisição for 2 - Cheque transferencia
      IF rw_crapreq.tprequis = 2 THEN
        -- Texto relatório
        vr_relat433(vr_nrindice).dsrelato := 'REQUISICOES CHEQUE TB ATENDIDAS:';
      ELSE
        -- Texto relatório
        vr_relat433(vr_nrindice).dsrelato := 'REQUISICOES ATENDIDAS:';
      END IF;

      -- Se for tipo 5
      IF rw_crapreq.tprequis = 5 THEN
        vr_tpcheque := 1;
      ELSE 
        vr_tpcheque := 2;
      END IF;
      
      -- Se tipo da conta inicio igual a 12
      IF vr_tpctaini = 12 THEN
        -- Verifica a situação da conta integração
        IF rw_crapreq.flgctitg <> 2 OR NVL(rw_crapreq.nrdctitg,0) = 0 THEN
          vr_cdcritic := 837;
        END IF;
      END IF;
      
      -- Se não encontrar crítica
      IF vr_cdcritic = 0 THEN 
        -- Verifica a situação da conta
        IF rw_crapreq.cdsitdct <> 1 THEN
          vr_cdcritic := 64;
        -- Verifica a situação do titular
        ELSIF rw_crapreq.cdsitdtl IN (5,6,7,8) THEN
          vr_cdcritic := 695;
        ELSIF rw_crapreq.cdsitdtl IN (2,4,6,8) THEN
          vr_cdcritic := 95;
        -- Verifica existencia do associado na lista do Banco Central.
        ELSIF rw_crapreq.inlbacen <> 0 THEN
          vr_cdcritic := 720;
        END IF;
      END IF;
      
      -- Se não encontrar crítica
      IF vr_cdcritic = 0 THEN 
        -- Se tipo da conta inicio igual a 12
        IF vr_tpctaini = 12 THEN
          vr_nrdctitg := fn_ver_contaitg(rw_crapreq.nrdctitg);
        ELSE
          vr_nrdctitg := rw_crapreq.nrdconta;
        END IF;
        
        -- Buscar novamente o valor do nrflcheq, pois o mesmo pode ter sido atualizado ( Renato - Supero )
        OPEN  cr_nrflcheq(rw_crapreq.rowidass);
        FETCH cr_nrflcheq INTO rw_crapreq.nrflcheq;
        CLOSE cr_nrflcheq;
        
        -- Atualiza as folhas a serem impressas
        rw_crapreq.nrflaini := (rw_crapreq.nrflcheq + 1);
        rw_crapreq.nrflafim := (rw_crapreq.nrflcheq + rw_crapreq.qtreqtal);
        
        -- Atualizar variáveis
        vr_nrflcheq    := rw_crapreq.nrflcheq + 1; -- Numero da ultima folha de talao emitida.
        vr_nrtalchq    := rw_crapreq.flchqitg + 1; -- Numero da ultima folha de talao emitida.
        vr_confecca    := 'Confeccao: '||to_char(pr_dtmvtolt,'FMMM/YYYY');
        vr_relat433(vr_nrindice).nrinichq := vr_nrflcheq;
        
        -- Calcula C1
        vr_nrcalcul := to_number(to_char(vr_cdcomchq,'FM000')
                               ||to_char(vr_cdbanchq,'FM000')
                               ||to_char(vr_cdagechq,'FM0000')
                               ||to_char(vr_cddigage,'FM0' ) );
       
        -- Calcular e conferir o digito verificador pelo modulo onze
        vr_flvrfdig := GENE0005.fn_calc_digito(vr_nrcalcul);
      
        vr_cddigtc1 := SUBSTR(vr_nrcalcul, LENGTH(vr_nrcalcul), 1);

        -- Calcula C2
        vr_nrcalcul := to_number(to_char(vr_nrdctitg,'FM00000000')||'0');

        -- Calcular e conferir o digito verificador pelo modulo onze
        vr_flvrfdig := GENE0005.fn_calc_digito(vr_nrcalcul);
        
        vr_cddigtc2 := SUBSTR(vr_nrcalcul, LENGTH(vr_nrcalcul), 1);
          
        -- Percorrer os registros conforme a quantidade de talonarios requisitados.
        FOR vr_qtreqtal IN 1..rw_crapreq.qtreqtal LOOP
          
          -- Setar o indicador de dados para true
          vr_flgdados := TRUE;
                    
          -- Calcula Digito do Cheque
          vr_nrcalcul := (vr_nrflcheq * 10);
          
          -- Calcular e conferir o digito verificador pelo modulo onze
          vr_flvrfdig := GENE0005.fn_calc_digito(vr_nrcalcul);
          
          vr_nrdigchq := SUBSTR(vr_nrcalcul, LENGTH(vr_nrcalcul), 1);
         
          -- Calcula CMC-7 do Cheque
          CHEQ0001.pc_calc_cmc7_difcompe(pr_cdbanchq => vr_cdbanchq
                                        ,pr_cdcmpchq => rw_crapage.cdcomchq
                                        ,pr_cdagechq => vr_cdagechq
                                        ,pr_nrctachq => vr_nrdctitg
                                        ,pr_nrcheque => vr_nrflcheq
                                        ,pr_tpcheque => vr_tpcheque
                                        ,pr_dsdocmc7 => vr_dsdocmc7
                                        ,pr_des_erro => vr_dscritic);
          
          -- Verificar se houve algum erro ao executar a rotina
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          BEGIN
            -- Inserir as folhas de cheques emitidos para o cooperado
            INSERT INTO crapfdc(nrdconta
                               ,nrdctabb
                               ,nrctachq
                               ,nrdctitg    
                               ,nrpedido
                               ,nrcheque
                               ,nrseqems
                               ,nrdigchq
                               ,tpcheque
                               ,dtemschq
                               ,dsdocmc7
                               ,cdagechq
                               ,cdbanchq
                               ,cdcmpchq
                               ,cdcooper
                               ,tpforchq
                               ,dtconchq)
                         VALUES(rw_crapreq.nrdconta                      -- nrdconta
                               ,vr_nrdctitg                              -- nrdctabb
                               ,vr_nrdctitg                              -- nrctachq
                               ,CASE to_char(vr_tpctaini)                         -- nrdctitg
                                    WHEN '12' THEN to_char(rw_crapreq.nrdctitg)   
                                    ELSE ' '                             
                                END                                  
                               ,vr_nrpedido                              -- nrpedido
                               ,vr_nrflcheq                              -- nrcheque
                               ,vr_nrtalchq                              -- nrseqems
                               ,vr_nrdigchq                              -- nrdigchq
                               ,vr_tpcheque                              -- tpcheque
                               ,NULL                                     -- dtemschq
                               ,vr_dsdocmc7                              -- dsdocmc7
                               ,vr_cdagechq                              -- cdagechq
                               ,vr_cdbanchq                              -- cdbanchq
                               ,vr_cdcomchq                           -- cdcmpchq
                               ,pr_cdcooper                              -- cdcooper
                               ,rw_crapreq.tpforchq                      -- tpforchq
                               ,vr_dtmvtolt);                            -- dtconchq
          EXCEPTION 
            WHEN OTHERS THEN
              -- Monta mensagem de erro
              vr_dscritic := 'Erro ao inserir CRAPFDC: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
                               
          -- Atualizar as variáveis de controle
          vr_nrflcheq := vr_nrflcheq + 1;
          vr_nrtalchq := rw_crapreq.flchqitg + 1;
          
          -- Tipo da requisição  
          IF rw_crapreq.tprequis = 5 THEN
            vr_qtfolhas := vr_qtfolhas + 1;
          ELSE 
            vr_qtfolhtb := vr_qtfolhtb + 1;
          END IF;
        END LOOP;
        
        -- Calcular o número inicial do cheque
        vr_nrcalcul := vr_relat433(vr_nrindice).nrinichq * 10;
          
        -- Calcular e conferir o digito verificador pelo modulo onze
        vr_flvrfdig := GENE0005.fn_calc_digito(vr_nrcalcul);
          
        vr_relat433(vr_nrindice).nrinichq := vr_nrcalcul;
        
        -- Calcular o número final do cheque
        vr_nrcalcul := (vr_nrflcheq - 1) * 10;
        -- Calcular e conferir o digito verificador pelo modulo onze
        vr_flvrfdig := GENE0005.fn_calc_digito(vr_nrcalcul);
          
        vr_relat433(vr_nrindice).nrfinchq := vr_nrcalcul;
        
        -- Atualiza as variáveis
        vr_relat433(vr_nrindice).nrdconta := rw_crapreq.nrdconta;
        
        -- Verifica o tipo de conta
        IF vr_tpctaini = 12 THEN
          vr_relat433(vr_nrindice).nrctaitg := rw_crapreq.nrdctitg;
        ELSE 
          vr_relat433(vr_nrindice).nrctaitg := rw_crapreq.nrdconta;
        END IF;
       
        vr_relat433(vr_nrindice).nrtalchq := vr_nrtalchq;
        vr_relat433(vr_nrindice).nmprimtl := rw_crapreq.nmprimtl;
        vr_qtdrl433(rw_crapage.cdagenci).qttalage := NVL(vr_qtdrl433(rw_crapage.cdagenci).qttalage,0) + 1;
        
        -- Verifica o tipo de requisição                     
        IF rw_crapreq.tprequis = 5 THEN
          vr_qttalger := NVL(vr_qttalger,0) + 1;
        ELSE 
          vr_qtdtaltb := NVL(vr_qtdtaltb,0) + 1;
        END IF;
        
        -- Formatar conforme o tipo da pessoa - fisica/juridica
        vr_nrcpfcgc := RPAD(GENE0002.fn_mask_cpf_cnpj(rw_crapreq.nrcpfcgc
                                                     ,rw_crapreq.inpessoa),18,' ');
         
        -- Limpar as variáveis de data
        vr_dtabtcct := NULL;
        vr_dtabtcc2 := NULL;
                
        -- Busca data na tabela do Sist. Financeiro.
        OPEN  cr_crapsfn(rw_crapreq.nrcpfcgc);
        FETCH cr_crapsfn INTO rw_crapsfn;
        -- Se encontrar registros 
        IF cr_crapsfn%FOUND THEN
          vr_dtabtcc2 := rw_crapsfn.dtabtcct;
        END IF;
        CLOSE cr_crapsfn;
    
        -- verifica a data
        IF rw_crapreq.dtabtcct IS NOT NULL AND
           rw_crapreq.dtabtcct < rw_crapreq.dtadmiss THEN
          vr_dtabtcct := rw_crapreq.dtabtcct;
        ELSE
          vr_dtabtcct := rw_crapreq.dtadmiss;
        END IF;
                   
        -- verifica a outra data
        IF vr_dtabtcc2 IS NOT NULL AND vr_dtabtcc2 < vr_dtabtcct THEN
          vr_dstmpcta := 'Cliente Bancario desde '||(to_char(vr_dtabtcc2,'mm/yyyy'));
        ELSE
          vr_dstmpcta := '       Cooperado desde '||(to_char(vr_dtabtcct,'mm/yyyy'));
        END IF;
        
        -- Inicializar variáveis
        vr_dschqesp := NULL;
        vr_tpdocptl := NULL;
        vr_nrdocptl := NULL;
        vr_cdoedptl := NULL;
        vr_cdufdptl := NULL;
        
        -- Verifica se é pessoa fisica ou jurídica
        IF rw_crapreq.inpessoa = 1 THEN
          vr_dscpfcgc := 'CPF: ';
        ELSE
          vr_dscpfcgc := 'CNPJ:';
        END IF;
        
        vr_nmprital := NULL;
        vr_nmsegtal := NULL;
          
        -- Verifica se todos os campos de endereço estão em branco      
        IF TRIM(rw_crapage.dsinform##1) IS NULL AND
           TRIM(rw_crapage.dsinform##2) IS NULL AND
           TRIM(rw_crapage.dsinform##3) IS NULL THEN
          -- Definir endereço
          vr_dsender1 := TRIM(rw_crapcop.dsendcop)||', '||GENE0002.fn_mask(rw_crapcop.nrendcop,'zz,zz9');
          vr_dsender2 := TRIM(rw_crapcop.nmbairro)||' - '||TRIM(rw_crapcop.nmcidade)||' - '||TRIM(rw_crapcop.cdufdcop);
          vr_dsender3 := 'Fone: '||TRIM(rw_crapcop.nrtelvoz);
        ELSE
          vr_dsender1 := rw_crapage.dsinform##1;
          vr_dsender2 := rw_crapage.dsinform##2;
          vr_dsender3 := rw_crapage.dsinform##3;
        END IF;
        
        -- Conforme o tipo de conta
        IF rw_crapreq.cdtipcta IN (9, 11, 13, 15) THEN
          vr_dschqesp := 'CHEQUE ESPECIAL';
        END IF;
        
        -- Verifica se eh pessoa fisica ou juridica
        IF rw_crapreq.inpessoa = 1 THEN
          
          vr_tpdocptl := rw_crapreq.tpdocptl;
          vr_nrdocptl := rw_crapreq.nrdocptl;
          vr_cdoedptl := rw_crapreq.cdoedptl;
          vr_cdufdptl := rw_crapreq.cdufdptl;
          
          -- Buscar dados de titulares da conta - 1º Titular
          OPEN  cr_crapttl(rw_crapreq.nrdconta, 1);
          FETCH cr_crapttl INTO rw_crapttl;
          -- Se encontrar registro
          IF cr_crapttl%FOUND THEN
            -- Se nome do titular para o talao de cheques não for nulo
            IF TRIM(rw_crapttl.nmtalttl) IS NOT NULL THEN
              vr_nmprital := TRIM(rw_crapttl.nmtalttl);
            ELSE
              vr_nmprital := rw_crapreq.nmprimtl;
            END IF;
          END IF;
          CLOSE cr_crapttl;

          -- Buscar dados de titulares da conta - 2º Titular
          OPEN  cr_crapttl(rw_crapreq.nrdconta, 2);

          FETCH cr_crapttl INTO rw_crapttl;

          -- Se encontrar registro
          IF cr_crapttl%FOUND THEN
            -- Se nome do titular para o talao de cheques não for nulo
            IF TRIM(rw_crapttl.nmtalttl) IS NOT NULL THEN
              vr_nmsegtal := TRIM(rw_crapttl.nmtalttl);
            ELSE
              vr_nmsegtal := TRIM(rw_crapttl.nmextttl);
            END IF;

			vr_relat433(vr_nrindice).nmsegntl := TRIM(rw_crapttl.nmextttl);

          END IF;

          CLOSE cr_crapttl;

		  IF rw_crapreq.tprequis = 2 THEN
	        vr_nmtitdes := TRIM(rw_crapreq.nmprimtl)||' '||TRIM(rw_crapttl.nmextttl);
		  ELSE     
			vr_nmtitdes := NULL;
		  END IF;

        ELSE
          --  Buscar dados de pessoas juridicas
          OPEN  cr_crapjur(rw_crapreq.nrdconta);
          FETCH cr_crapjur INTO rw_crapjur;
         
          -- Se encontrar os dados
          IF cr_crapjur%FOUND THEN
            -- Se nome do titular para o talao de cheques não for nulo
            IF TRIM(rw_crapjur.nmtalttl) IS NOT NULL THEN
              vr_nmprital := TRIM(rw_crapjur.nmtalttl);
            ELSE
              vr_nmprital := rw_crapreq.nmprimtl;
            END IF;
           
            -- Guarda Nome do segundo titular
            vr_nmsegtal := NULL;

          END IF;
          
          -- Fecha o cursor
          CLOSE cr_crapjur;

		  IF rw_crapreq.tprequis = 2 THEN
	        vr_nmtitdes := TRIM(rw_crapreq.nmprimtl);
		  ELSE     
			vr_nmtitdes := NULL;
        END IF;

        END IF;

        vr_dsconta1 := vr_nmprital;
         
        -- Verificar o tipo de conta                      
        IF rw_crapreq.cdtipcta IN (8,9,12,13)  THEN
          vr_dsconta2 := vr_dscpfcgc||
                         vr_nrcpfcgc||
                         '       '||
                         GENE0002.fn_mask_conta(rw_crapreq.nrdconta);
          vr_dsconta3 := vr_tpdocptl||' '||
                         SUBSTR(TRIM(vr_nrdocptl),1,15)||' '||
                         TRIM(vr_cdoedptl)||' '||
                         TRIM(vr_cdufdptl);
          vr_dsconta4 := NULL;
        ELSE
          vr_dsconta2 := vr_nmsegtal;
          vr_dsconta3 := vr_dscpfcgc||
                         vr_nrcpfcgc||
                         '       '||
                         GENE0002.fn_mask_conta(rw_crapreq.nrdconta);
          vr_dsconta4 := vr_tpdocptl||' '||
                         SUBSTR(TRIM(vr_nrdocptl),1,15)||' '||
                         TRIM(vr_cdoedptl)||' '||
                         TRIM(vr_cdufdptl);
        END IF;   
        
        -- Limpa as variáveis
        vr_upd_insitreq := NULL;
        vr_upd_cdcritic := NULL;
        
        -- Se há talonarios requisitados
        IF rw_crapreq.qtreqtal > 0 THEN
          -- Percorrer os registros de folhas de cheques emitidos para o cooperado
          FOR rw_crapfdc IN cr_crapfdc(rw_crapreq.nrdconta -- pr_nrdconta
                                      ,vr_nrpedido         -- pr_nrpedido
                                      ,vr_tpcheque         -- pq_tpcheque
                                      ,rw_crapreq.nrflaini -- Número inicial do cheque
                                      ,rw_crapreq.nrflafim  ) LOOP -- Número final do cheque
             
            -- Tipo conta inicial         
            IF pr_tpctaini = 12 THEN
              -- Guarda a conta integração
              vr_dsctaitg := TRIM(GENE0002.fn_mask_conta(rw_crapfdc.nrdctitg));
            ELSE
              vr_dsctaitg := TRIM(GENE0002.fn_mask_conta(rw_crapreq.nrdconta)); 
            END IF;
                            
            -- Escrever no arquivo
            -- NUM. SERIE
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => '001');
            -- NUM. CHEQUE
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(rw_crapfdc.nrcheque, 'FM000G000')||'-'||
                                                          to_char(rw_crapfdc.nrdigchq, 'FM0') );
            -- COD. COMP.
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(rw_crapfdc.cdcmpchq, 'FM000'));
            -- BANCO
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(rw_crapfdc.cdbanchq, 'FM000'));
            -- AGENCIA
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(rw_crapfdc.cdagechq, 'FM0000'));
            -- DIG. AGENCIA
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_cddigage));
            -- C1
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_cddigtc1));
            -- CONTA ITG
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_dsctaitg));
            -- C2
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_cddigtc2));
            -- NUM. SERIE
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => '001');
            -- NRD. CHEQUE
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(rw_crapfdc.nrcheque,'FM000000'));
            -- C3
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(rw_crapfdc.nrdigchq));
            -- CHQ ESPECIAL
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_dschqesp));
            -- Nome titulares
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_nmtitdes));
            -- COOPER. DESDE
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_dstmpcta));
            -- RUA COOP 
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_dsender1));
            -- BAIRRO / CID
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_dsender2));
            -- FONE E CEP
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_dsender3));
            -- Confecçao
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_confecca));
            -- NOME Prim.
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_dsconta1));
            -- Tit ou Doc
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_dsconta2));
            -- Documento
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_dsconta3));
            -- Documento
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_dsconta4));
            -- Logo cooper
            GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => to_char(vr_dsimgcop));
            -- Loop para escrever o CMC7
            FOR ind IN 1..34 LOOP
              -- Escreve o CMC7 no arquivo, conforme o índice
              GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                            ,pr_des_text => fn_cmc7(ind, rw_crapfdc.dsdocmc7) );
            END LOOP;
        
            -- Atualizar a CRAPASS
            BEGIN
              UPDATE crapass
                 SET crapass.nrflcheq = rw_crapfdc.nrcheque
                   , crapass.flchqitg = rw_crapfdc.nrseqems
               WHERE crapass.rowid = rw_crapreq.rowidass;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar CRAPASS: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
            
            -- Atualizar a situação
            vr_upd_insitreq := 2;
          END LOOP;
        ELSE
          vr_upd_insitreq := 3;
          vr_upd_cdcritic := pr_cdcritic;
          vr_qttalrej  := vr_qttalrej + rw_crapreq.qtreqtal;
          vr_qtrejger  := vr_qtrejger + rw_crapreq.qtreqtal;
        END IF;
         
        -- Atualizar as Requisicoes de talonarios
        BEGIN
          UPDATE crapreq
             SET crapreq.dtpedido = pr_dtmvtolt
               , crapreq.nrpedido = vr_nrpedido
               , crapreq.insitreq = NVL(vr_upd_insitreq , crapreq.insitreq)
               , crapreq.cdcritic = NVL(vr_upd_cdcritic , crapreq.cdcritic)
           WHERE crapreq.rowid    = rw_crapreq.idcrapreq;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar CRAPREQ: '||SQLERRM;
            RAISE vr_exc_saida; -- Para a cadeia para que seja verificado o problema
        END;
      END IF;

----------------------------------------------------------------------------------------------------------

      -- Se for o ultimo registro do tipo de requisição
      IF rw_crapreq.qttprequis = rw_crapreq.qttottpreq   THEN
        
        -- Se o arquivo estiver aberto
        IF UTL_FILE.is_open(vr_utlfileh) THEN
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
        END IF;
        
        -- Executa o comando Shell para excluir o arquivo shell
        gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdestin||'/arq/crrl460.sh'
                                   ,pr_flg_aguard  => 'S'
                                   ,pr_typ_saida   => vr_typ_said
                                   ,pr_des_saida   => vr_des_erro);
        
        -- Limpa a variável de comando
        vr_dscomand := NULL;
             
        -- Se for uma requisição do tipo 2 (Cheque transferencia)
        IF rw_crapreq.tprequis = 2 THEN
          -- Se a quantidade for maior que zero
          IF vr_qtfolhtb > 0 THEN
            -- monta o comando para execução do FormPrint
            vr_dscomand := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                    ,pr_cdacesso => 'SCRIPT_EXEC_SHELL')||
                           ' FormPrint -f '||vr_dsdestin||'/laser/cmc7/chequetb.lfm'||
                           ' \< '||vr_nmdirchq||'/'||vr_nmarqchq||' \> '||vr_nmdireto(3)||'/'||
                           vr_nmarqimp(3)||'-TB.txt 2>>/tmp/FormPrint.tmp';            
          END IF;
        ELSE
          -- Se a quantidade for maior que zero
          IF vr_qtfolhas > 0 THEN
            -- monta o comando para execução do FormPrint
            vr_dscomand := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                    ,pr_cdacesso => 'SCRIPT_EXEC_SHELL')||
                           ' FormPrint -f '||vr_dsdestin||'/laser/cmc7/cheque.lfm'||
                           ' \< '||vr_nmdirchq||'/'||vr_nmarqchq||' \> '||vr_nmdireto(3)||'/'||
                           vr_nmarqimp(3)||'.txt'; --  2>>/tmp/FormPrint.tmp

          END IF;
        END IF;
        
        -- Se tem comando a ser executado
        IF vr_dscomand IS NOT NULL THEN
          -- Executa o comando Shell
          gene0001.pc_OScommand_Shell(pr_des_comando => vr_dscomand
                                     ,pr_flg_aguard  => 'S'
                                     ,pr_typ_saida   => vr_typ_said
                                     ,pr_des_saida   => vr_des_erro);
          
          -- Não tratar erros do FormPrint
          vr_typ_said := NULL;
          vr_des_erro := NULL;
          
          /* O formPrint sempre retorna Erro, mesmo quando informa sucesso,
           dessa forma essa validação não pode ser executada !     ( Renato - Supero )
          -- Verifica se houve retorno de erro                
          IF vr_des_erro IS NOT NULL THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao executar FormPrint: '||vr_des_erro;
            -- Encerra a execução da rotina
            RAISE vr_exc_saida;
          END IF;*/
          
          -- Executa o comando Shell para mover o arquivo
          gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmdirchq||'/'||vr_nmarqchq||' '||vr_dsdestin||'/salvar/'||vr_nmarqchq
                                     ,pr_flg_aguard  => 'S'
                                     ,pr_typ_saida   => vr_typ_said
                                     ,pr_des_saida   => vr_des_erro);

        END IF;
      END IF; --  rw_crapreq.qttprequis = rw_crapreq.qttottpreq               
     
      -- Se a flag indicado dados estiver como false, apaga o registro
      IF NOT vr_flgdados THEN
        vr_relat433.DELETE(vr_nrindice);
      END IF;

    END LOOP; /* FOR EACH crapreq */       
    
    -- verifica a quantidade de dados
    IF (vr_qtfolhas + vr_qtfolhtb) = 0 THEN
      -- gerar os arquivos mesmo não tendo conteúdo
      FOR ind IN 1..2 LOOP
        -- Limpar variáveis
        vr_utlfileh := NULL;
        vr_dscritic := NULL;
        -- Deve gerar os arquivos para o pedido mesmo em branco
        GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto(ind)
                                ,pr_nmarquiv => vr_nmarqimp(ind)
                                ,pr_tipabert => 'W'
                                ,pr_utlfileh => vr_utlfileh
                                ,pr_des_erro => vr_dscritic);
        -- Fechar o arquivo
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
      END LOOP;
      
      -- Abandona o procedimento
      RETURN;
      
    END IF;
    
    /*  Emissao do relatorio das requisicoes nao atendidas  */
    IF vr_qttalrej > 0 THEN
      -- Percorrer as requisicoes de talonarios não atendidas
      FOR rw_crapreq IN cr_crapreq_naoatd(pr_dtmvtolt) LOOP

        -- Novo índice para a tabela de memória
        vr_nrindice := NVL(vr_relat433.COUNT(),0) + 1;
        
        -- Tipo de exibição 2 - para controle a nivel de iReport
        vr_relat433(vr_nrindice).idtipo := 2;
        vr_relat433(vr_nrindice).cdagenci := pr_cdagenci; -- Inicializa com a agencia do parametro
        
        -- Se for o primeiro registro
        --IF rw_crapreq.qttprequis = 1 THEN
          
        OPEN  cr_crapage(rw_crapreq.cdagenci);
        FETCH cr_crapage INTO rw_crapage;
          
        -- Se a agencia for diferente
        IF rw_crapreq.cdagenci <> pr_cdagenci THEN
            
          -- Guarda agencia para relatório
          vr_relat433(vr_nrindice).cdagenci := rw_crapreq.cdagenci;  
          
          -- Se não encontrou a agencia
          IF cr_crapage%NOTFOUND THEN
            vr_relat433(vr_nrindice).nmresage := LPAD('*',15,'*');
          ELSE
            vr_relat433(vr_nrindice).nmresage := rw_crapage.nmresage;
          END IF;
        END IF;
          
        -- Fecha o cursor que busca dados da agencia
        CLOSE cr_crapage;

        -- Inicializa as variáveis
        vr_relat433(vr_nrindice).nrseqage := 1;
        vr_relat433(vr_nrindice).dsrelato := 'REQUISICOES NAO ATENDIDAS:';
        --vr_qtdrl433(rw_crapreq.cdagenci).qttalage := 0;
        --vr_qtdrl433(rw_crapreq.cdagenci).qttalrej := 0;
        
        -- Popular variáveis
        vr_cdcritic := rw_crapreq.cdcritic;
        -- Buscar a descrição da critica
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        -- Se a critica for igual a 009 - Associado nao cadastrado
        IF vr_cdcritic = 9 THEN
          -- Envio centralizado de log de erro
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic || ' Conta = ' 
                                                      || GENE0002.fn_mask_conta(rw_crapreq.nrdconta) ); 

        END IF;

        -- Variáveis relatório
        vr_relat433(vr_nrindice).nmprimtl := rw_crapreq.nmprimtl;
        vr_relat433(vr_nrindice).dtdemiss := rw_crapreq.dtdemiss;
        
        -- Buscar pelo tipo da conta
        OPEN  cr_craptip(rw_crapreq.cdtipcta);
        FETCH cr_craptip INTO rw_craptip;
        -- Se não encontrar registros
        IF cr_craptip%NOTFOUND THEN
          vr_relat433(vr_nrindice).dstipcta := NULL;
        ELSE
          vr_relat433(vr_nrindice).dstipcta := to_char(rw_crapreq.cdtipcta,'00')||'-'||rw_craptip.dstipcta;
        END IF;
        
        -- Inicializa a variável com o valor comum de toda a lógica do IF abaixo
        vr_dssitdct := to_char(rw_crapreq.cdsitdct,'0')||'-';
        
        -- Verifica o codigo da situacao da conta
        IF rw_crapreq.cdsitdct = 1  THEN
          vr_dssitdct := vr_dssitdct||'NORMAL';
        ELSIF rw_crapreq.cdsitdct = 2 THEN
          vr_dssitdct := vr_dssitdct||'ENC.P/ASSOCIADO';
        ELSIF rw_crapreq.cdsitdct = 3 THEN
          vr_dssitdct := vr_dssitdct||'ENC. PELA COOP';
        ELSIF rw_crapreq.cdsitdct = 4 THEN
          vr_dssitdct := vr_dssitdct||'ENC.P/DEMISSAO';
        ELSIF rw_crapreq.cdsitdct = 5 THEN
          vr_dssitdct := vr_dssitdct||'NAO APROVADA';
        ELSIF rw_crapreq.cdsitdct = 6 THEN
          vr_dssitdct := vr_dssitdct||'NORMAL S/TALAO';
        ELSIF rw_crapreq.cdsitdct = 9 THEN
          vr_dssitdct := vr_dssitdct||'ENC.P/O MOTIVO';
        ELSE
          vr_dssitdct := NULL;
        END IF;
        
        -- Valor para o relatório
        vr_relat433(vr_nrindice).dssitdct := vr_dssitdct;
        
        -- Guardar valores para relatório
        vr_relat433(vr_nrindice).nrdconta := rw_crapreq.nrdconta;
        vr_relat433(vr_nrindice).qtreqtal := rw_crapreq.qtreqtal;
        vr_relat433(vr_nrindice).dscritic := vr_dscritic;
        vr_qtdrl433(rw_crapreq.cdagenci).qttalrej := NVL(vr_qtdrl433(rw_crapreq.cdagenci).qttalrej,0) + rw_crapreq.qtreqtal;

      END LOOP;
    END IF;
      
    IF pr_tpctaini = 12 THEN
      vr_dsdbanco := 'BANCO DO BRASIL';
    ELSIF vr_cdbanchq = 756  THEN
      vr_dsdbanco := 'BANCOOB';
    ELSE
      -- Busca o registro do banco
      OPEN  cr_crapban(vr_cdbanchq);
      FETCH cr_crapban INTO rw_crapban;
      -- Se encontrar o registro do banco
      IF cr_crapban%FOUND THEN
        vr_dsdbanco := rw_crapban.nmresbcc;
      END IF;
      -- Fechar o cursor
      CLOSE cr_crapban;
    END IF;
    
    -- Busca do diretorio base da cooperativa
    vr_dspathcop := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => 'salvar');
    
    -- Verifica se deve gerar relatório para os arquivos
    IF (vr_qtdtaltb > 0) THEN
      -- Se o Inprocess for igual a 1
      IF pr_inproces = 1 THEN
        -- Busca o outro diretório para cópia 
        vr_dspathcop := vr_dspathcop||';'||gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                                ,pr_cdcooper => pr_cdcooper
                                                                ,pr_nmsubdir => 'rl');
      END IF;
    END IF;
    
    -- Montar o XML do CRRL432
    -- Inicializar o CLOB
    vr_des_xml := null;
    vr_txtcompleto:= NULL;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    -- Inicializa o XML
    gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompleto,
                            '<?xml version="1.0" encoding="utf-8"?><pedido>');
                              
    -- Dados relatório
    gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompleto,
                            '<nrpedido>'||to_char(vr_nrpedido,'FM999G999G999')||'</nrpedido>'||
                            '<dtmvtolt>'||to_char(vr_dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                            '<dsdbanco>'||SUBSTR(vr_dsdbanco,1,15)||'</dsdbanco>'||  -- 15 POSIÇÕES APENAS
                            '<qtfolhtb>'||vr_qtfolhtb||'</qtfolhtb>'||
                            '<qtdtaltb>'||vr_qtdtaltb||'</qtdtaltb>');
    
    -- Fecha XML 
    gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompleto,
                            '</pedido>', TRUE);

    -- Chamada do iReport para gerar o arquivo de saida
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                pr_dtmvtolt  => vr_dtmvtolt,                    --> Data do movimento atual
                                pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/pedido',                      --> No base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl432.jasper',               --> Arquivo de layout do iReport
                                pr_dsparams  => null,                           --> Nao enviar parametro
                                pr_dsarqsaid => vr_nmdireto(1)||'/'||vr_nmarqimp(1),--> Arquivo final
                                pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                pr_nmformul  => NULL,                           --> Nome do formulario
                                pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                pr_nrcopias  => 1,                              --> Numero de copias
                                pr_dspathcop => vr_dspathcop,                   --> Copiar o relatório após gerar
                                pr_flgremarq => 'S',                            --> Remover o arquivo após cópia
                                pr_des_erro  => vr_dscritic);                   --> Saida com erro

    -- Se ocorrer erros
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Montar o XML do CRRL433
    -- Inicializar o CLOB
    vr_des_xml := null;
    vr_txtcompleto:= NULL;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    -- Inicializa o XML
    gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompleto,
                            '<?xml version="1.0" encoding="utf-8"?><crrl433>');
                              
    -- Inicia agencias
    gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompleto, '<agencias>');
    
    -- Escreve os dados da tabela de memória no XML
    -- Se há registros
    IF vr_relat433.count() > 0 THEN
      -- Primeiro índice
      vr_nrindice := vr_relat433.FIRST;
      -- Percorre
      LOOP
        -- Dados relatório
        gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompleto,
                            '<agencia idtipo="'||vr_relat433(vr_nrindice).idtipo||'"  >'||
                            '  <cdagenci>'||vr_relat433(vr_nrindice).cdagenci||'</cdagenci>'||
                            '  <nmresage>'||vr_relat433(vr_nrindice).nmresage||'</nmresage>'||
                            '  <nrpedido>'||to_char(vr_relat433(vr_nrindice).nrpedido,'FM99G999G999')||'</nrpedido>'||
                            '  <nrseqage>'||vr_relat433(vr_nrindice).nrseqage||'</nrseqage>'||
                            '  <qttalage>'||vr_qtdrl433(vr_relat433(vr_nrindice).cdagenci).qttalage||'</qttalage>'||
                            '  <qttalrej>'||vr_qtdrl433(vr_relat433(vr_nrindice).cdagenci).qttalrej||'</qttalrej>'||
                            '  <dsrelato>'||vr_relat433(vr_nrindice).dsrelato||'</dsrelato>'||
                            '  <nrdconta>'||GENE0002.fn_mask_conta(vr_relat433(vr_nrindice).nrdconta)||'</nrdconta>'||
                            '  <nrctaitg>'||GENE0002.fn_mask(vr_relat433(vr_nrindice).nrctaitg,'9.999.999-9')||'</nrctaitg>'||
                            '  <nrtalchq>'||vr_relat433(vr_nrindice).nrtalchq||'</nrtalchq>'||
                            '  <nrinichq>'||TRIM(GENE0002.fn_mask(vr_relat433(vr_nrindice).nrinichq,'zzz.zzz.z'))||'</nrinichq>'||
                            '  <nrfinchq>'||TRIM(GENE0002.fn_mask(vr_relat433(vr_nrindice).nrfinchq,'zzz.zzz.z'))||'</nrfinchq>'||
                            '  <nmprimtl>'||vr_relat433(vr_nrindice).nmprimtl||'</nmprimtl>'||
                            '  <nmsegntl>'||vr_relat433(vr_nrindice).nmsegntl||'</nmsegntl>'||
                            '  <dtdemiss>'||vr_relat433(vr_nrindice).dtdemiss||'</dtdemiss>'||
                            '  <dstipcta>'||vr_relat433(vr_nrindice).dstipcta||'</dstipcta>'||
                            '  <dssitdct>'||vr_relat433(vr_nrindice).dssitdct||'</dssitdct>'||
                            '  <qtreqtal>'||vr_relat433(vr_nrindice).qtreqtal||'</qtreqtal>'||
                            '  <dscritic>'||vr_relat433(vr_nrindice).dscritic||'</dscritic>'||
                            '</agencia> ');
        
        -- Encerra quando chegar no ultimo registro
        EXIT WHEN vr_nrindice = vr_relat433.LAST;
        -- Próximo indice
        vr_nrindice := vr_relat433.NEXT(vr_nrindice);
      END LOOP;
    END IF;  
    
    -- Finaliza agencias
    gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompleto, '</agencias>');
    
    -- Informações de pedido
    gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompleto
                                             , '<pedido>'||
                                               '  <nrpedido>'||to_char(vr_nrpedido,'FM99G999G999')||'</nrpedido>'||
                                               '  <dtmvtolt>'||to_char(vr_dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                                               '  <dsdbanco>'||SUBSTR(vr_dsdbanco,1,15)||'</dsdbanco>'||
                                               '  <qtdtaltb>'||nvl(vr_qtfolhas,0)||'</qtdtaltb>'||
                                               '  <qttalger>'||nvl(vr_qttalger,0)||'</qttalger>'||
                                               '</pedido>');
    
    -- Fecha XML 
    gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompleto,
                            '</crrl433>', TRUE);
    
    -- Busca do diretorio base da cooperativa
    vr_dspathcop := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => 'salvar');
    
    -- Verifica se deve gerar relatório para os arquivos
    IF (vr_qttalger > 0)  THEN   
      -- Se o Inprocess for igual a 1
      IF pr_inproces = 1 THEN
        vr_dspathcop := vr_dspathcop||';'||gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                                ,pr_cdcooper => pr_cdcooper
                                                                ,pr_nmsubdir => 'rl');
      END IF;
    END IF;
    
    -- Chamada do iReport para gerar o arquivo de saida
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                pr_dtmvtolt  => vr_dtmvtolt,                    --> Data do movimento atual
                                pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/crrl433/agencias/agencia',    --> No base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl433.jasper',               --> Arquivo de layout do iReport
                                pr_dsparams  => null,                           --> Nao enviar parametro
                                pr_dsarqsaid => vr_nmdireto(2)||'/'||vr_nmarqimp(2), --> Arquivo final
                                pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                pr_nmformul  => NULL,                           --> Nome do formulario
                                pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                pr_nrcopias  => 1,                              --> Numero de copias
                                pr_dspathcop => vr_dspathcop,                   --> Copiar o relatório após gerar
                                pr_flgremarq => 'S',                            --> Remover o arquivo após cópia
                                pr_des_erro  => vr_dscritic);                   --> Saida com erro

    -- Se ocorrer erros
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    --  Buscar o diretório para gerar log de pedido de talões
    vr_dsdirlog := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdacesso => 'CRPS460_DIR_PEDIDOTALOES');

    -- Abrir o arquivo
    GENE0001.pc_abre_arquivo(pr_nmdireto => vr_dsdirlog
                            ,pr_nmarquiv => 'pedidotaloes'||to_char(pr_dtmvtolt,'MMYYYY')
                            ,pr_tipabert => 'A' -- append
                            ,pr_utlfileh => vr_utlfileh
                            ,pr_des_erro => vr_dscritic);
                           
    -- Se retornou erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Monta mensagem de erro
      vr_dscritic := 'Erro ao abrir arquivo pedidotaloes'||to_char(pr_dtmvtolt,'MMYYYY')||': '||vr_dscritic;
      -- Encerra o programa
      RAISE vr_exc_saida;
    END IF;
    
    -- Escreve a linha no arquivo
    GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                  ,pr_des_text => to_char(pr_dtmvtolt,'DD/MM/YY')||';'||
                                                  rw_crapcop.nmrescop ||';'||
                                                  to_char(vr_nrpedido)||';'||
                                                  to_char(vr_qtfolhas) );
    
    -- Fechar o arquivo
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);

    -- Converter o arquivo com o ux2dos
    gene0001.pc_OScommand_Shell('ux2dos '||vr_dsdirlog||'/pedidotaloes'||to_char(pr_dtmvtolt,'MMYYYY')||
                                ' > '||vr_dsdirlog||'/pedidotaloes'||to_char(pr_dtmvtolt,'MMYYYY')||'.txt 2>/dev/null');
    
    IF (vr_qttalger + vr_qtdtaltb) > 0   THEN
      BEGIN
        -- Inserir o registro de pedido de talionario
        INSERT INTO crapped(cdcooper
                           ,cdbanchq
                           ,nrpedido
                           ,nrseqped
                           ,dtsolped
                           ,nrdctabb
                           ,nrinichq
                           ,nrfinchq
                           ,qtflschq)
                    VALUES (pr_cdcooper
                           ,vr_cdbanchq
                           ,vr_nrpedido
                           ,1
                           ,pr_dtmvtolt
                           ,0
                           ,0
                           ,NVL(vr_qttalger,0) + NVL(vr_qtdtaltb,0)
                           ,NVL(vr_qtfolhas,0) + NVL(vr_qtfolhtb,0));
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir CRAPPED: '||SQLERRM;
          RAISE vr_exc_saida;      
      END;  /*  Fim da transacao  */
    END IF;  
   
    FOR vr_contador IN 1..2 LOOP
      -- Verifica se deve gerar relatório
      IF (vr_contador = 1 AND vr_qtdtaltb > 0)  OR 
         (vr_contador = 2 AND vr_qttalger > 0)  THEN   
        -- Tipo e nome do relatório                              
        vr_tprelato := 0;
        vr_nmrelato := NULL;
                
        -- Buscar informações para o relatório
        OPEN  cr_craprel( pr_cdrelato(vr_contador) );
        FETCH cr_craprel INTO rw_craprel;
        -- Se encontrar registros
        IF cr_craprel%FOUND THEN
          -- Se o tipo de relatório for igual a 2
          IF rw_craprel.tprelato = 2 THEN
            vr_tprelato := 1;
          END IF;
          -- Nome do relatório
          vr_nmrelato := rw_craprel.nmrelato;
        END IF;
        
        -- Pegar o nome do arquivo
        vr_cdrelato := vr_nmarqimp(vr_contador);
        
        -- Separar o nome do arquivo
        LOOP
          -- Tira barra
          vr_cdrelato := SUBSTR(vr_cdrelato, instr(vr_cdrelato,'/') + 1 );
          -- Sai quando não encontrar mais nenhuma barra
          EXIT WHEN instr(vr_nmarqimp(vr_contador),'/') = 0;
        END LOOP;

        vr_nmarqtmp := 'tmppdf/'||vr_cdrelato||'.txt';
        vr_nmarqpdf := SUBSTR(vr_cdrelato,1,LENGTH(vr_cdrelato) - 4)||'.pdf';
        
        -- Limpa o handle de arquivos
        vr_utlfileh := NULL;
        
        -- Cria o arquivo 
        GENE0001.pc_abre_arquivo(pr_nmdireto => vr_dsdestin||'/tmppdf' --> Diretorio do arquivo
                                ,pr_nmarquiv => vr_nmarqtmp    --> Nome do arquivo
                                ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_utlfileh    --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);  
        
        IF vr_dscritic IS NOT NULL THEN
          -- Descrição do erro
          vr_dscritic := 'Erro ao criar arquivo na tmppdf: '||vr_dscritic;
          
          RAISE vr_exc_saida;
        END IF;
        
        -- Escreve a linha no arquivo
        GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => RPAD(rw_crapcop.nmrescop,20,' ')|| ';' ||
                                                      to_char(pr_dtmvtolt,'YYYY')     || ';' ||
                                                      to_char(pr_dtmvtolt,'MM')       || ';' ||
                                                      to_char(pr_dtmvtolt,'DD')       || ';' ||
                                                      GENE0002.fn_mask(vr_tprelato,'z9') || ';' ||
                                                      RPAD(vr_nmarqpdf,40,' ')        || ';' ||
                                                      RPAD(UPPER(vr_nmrelato),50,' ') || ';' );
                         
        -- Fecha o arquivo
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
        
        -- Gera o arquivo PDF
        /*GENE0002.pc_cria_PDF(pr_cdcooper => pr_cdcooper
                            ,pr_nmorigem => gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                                 ,pr_cdcooper => pr_cdcooper
                                                                 ,pr_nmsubdir => 'rl')||'/'||vr_nmarqimp(vr_contador)
                            ,pr_ingerenc => 'NAO'
                            ,pr_tirelato => '132col'
                            ,pr_dtrefere => pr_dtmvtolt
                            ,pr_nmsaida  => vr_nmarqimp(vr_contador)
                            ,pr_des_erro => vr_dscritic);
         
        IF vr_dscritic IS NOT NULL THEN
          -- Descrição do erro
          vr_dscritic := 'Erro ao criar arquivo PDF: '||vr_dscritic;
          
          RAISE vr_exc_saida;
        END IF;*/
        
      END IF;
    END LOOP;  /*  Fim do DO .. TO  */  
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
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
  END pc_gera_talonario;
    
BEGIN

  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra,
                             pr_action => vr_cdprogra);
  
  -- Verifica se a cooperativa esta cadastrada
  OPEN  cr_crapcop;
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

  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1 -- Fixo
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol 
                           ,pr_cdcritic => vr_cdcritic);
                   
  -- Se retornou algum erro
  IF vr_cdcritic <> 0 THEN
    -- Log de critica
    RAISE vr_exc_saida;
  END IF;
  
  -- Buscar as datas do movimento
  OPEN  btch0001.cr_crapdat(pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
  
  -- Se não encontrar o registro de movimento
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- 001 - Sistema sem data de movimento.
    vr_cdcritic := 1;

    CLOSE btch0001.cr_crapdat;
    -- Log de crítica
    RAISE vr_exc_saida;
  ELSE
    -- Atualizar as variáveis referente a datas
    vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
  END IF;
    
  CLOSE btch0001.cr_crapdat;
  
  -- BANCOOB 
  vr_tpctaini := 8;
  vr_tpctafim := 11;
  vr_cdbanchq := 756;
  vr_cdagechq := rw_crapcop.cdagebcb;
  
  -- Carregar a lista de relatórios gerados pelo programa
  FOR rw_crapprg IN cr_crapprg LOOP
    -- adiciona o relatório na tabela de memória
    vr_tab_cdrelato(1) := rw_crapprg.cdrelato##1;
    vr_tab_cdrelato(2) := rw_crapprg.cdrelato##2;
    vr_tab_cdrelato(3) := rw_crapprg.cdrelato##3;
    vr_tab_cdrelato(4) := rw_crapprg.cdrelato##4;
    vr_tab_cdrelato(5) := rw_crapprg.cdrelato##5;
    EXIT; -- Apenas o primeiro registro
  END LOOP;
  
  -- Buscar o diretório da cooperativa
  vr_dsdestin := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> Coop
                                      ,pr_cdcooper => pr_cdcooper);
  
  -- Ajustar a agencia aplicando a máscara e gerando um caracter zero como dígito
  vr_nrcalcul := TO_NUMBER(to_char(rw_crapcop.cdagebcb,'FM0000')||'0');

  -- Calcular e conferir o digito verificador pelo modulo onze
  vr_flvrfdig := GENE0005.fn_calc_digito(vr_nrcalcul);
  
  -- Separar o dígito do restante do numero calculado
  vr_cddigage := SUBSTR(vr_nrcalcul,LENGTH(vr_nrcalcul),1);
  
  -- Chamada da rotina
  pc_gera_talonario(pr_cdcooper => pr_cdcooper
                   ,pr_dtmvtolt => vr_dtmvtolt
                   ,pr_cdrelato => vr_tab_cdrelato
                   ,pr_inproces => btch0001.rw_crapdat.inproces
                   ,pr_tpctaini => vr_tpctaini
                   ,pr_tpctafim => vr_tpctafim
                   ,pr_cdbanchq => vr_cdbanchq
                   ,pr_cdagenci => vr_cdagechq
                   ,pr_cdcritic => vr_cdcritic
                   ,pr_dscritic => vr_dscritic);
  
  -- Verifica se houvrram erros na execução
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := '[1]-'||vr_dscritic; -- Gerar erros diferentes para cada chamada
    RAISE vr_exc_saida;
  END IF;
  
  -- CECRED
  vr_tpctaini := 8;
  vr_tpctafim := 11;
  vr_cdbanchq := rw_crapcop.cdbcoctl;
  vr_cdagechq := rw_crapcop.cdagectl;
  
  -- Ajustar a agencia aplicando a máscara e gerando um caracter zero como dígito
  vr_nrcalcul := TO_NUMBER(to_char(rw_crapcop.cdagectl,'FM0000')||'0');
 
  -- Calcular e conferir o digito verificador pelo modulo onze
  vr_flvrfdig := GENE0005.fn_calc_digito(vr_nrcalcul);
  
  -- Separar o dígito do restante do numero calculado
  vr_cddigage := SUBSTR(vr_nrcalcul,LENGTH(vr_nrcalcul),1);

  -- Chamada da rotina
  pc_gera_talonario(pr_cdcooper => pr_cdcooper
                   ,pr_dtmvtolt => vr_dtmvtolt
                   ,pr_cdrelato => vr_tab_cdrelato
                   ,pr_inproces => btch0001.rw_crapdat.inproces
                   ,pr_tpctaini => vr_tpctaini
                   ,pr_tpctafim => vr_tpctafim
                   ,pr_cdbanchq => vr_cdbanchq
                   ,pr_cdagenci => vr_cdagechq
                   ,pr_cdcritic => vr_cdcritic
                   ,pr_dscritic => vr_dscritic);
  
  -- Verifica se houvrram erros na execução
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := '[2]-'||vr_dscritic; -- Gerar erros diferentes para cada chamada
    RAISE vr_exc_saida;
  END IF;
  
 
  vr_tpctaini := 12;
  vr_tpctafim := 15;
  vr_cdbanchq := 1;
  vr_cdagechq := rw_crapcop.cdageitg;
  
  -- Ajustar a agencia aplicando a máscara e gerando um caracter zero como dígito
  vr_nrcalcul := TO_NUMBER(to_char(rw_crapcop.cdagectl,'FM0000')||'0');
 
  -- Calcular e conferir o digito verificador pelo modulo onze
  vr_flvrfdig := GENE0005.fn_calc_digito(vr_nrcalcul);
  
  -- Separar o dígito do restante do numero calculado
  vr_cddigage := SUBSTR(vr_nrcalcul,LENGTH(vr_nrcalcul),1);

  -- Chamada da rotina
  pc_gera_talonario(pr_cdcooper => pr_cdcooper
                   ,pr_dtmvtolt => vr_dtmvtolt
                   ,pr_cdrelato => vr_tab_cdrelato
                   ,pr_inproces => btch0001.rw_crapdat.inproces
                   ,pr_tpctaini => vr_tpctaini
                   ,pr_tpctafim => vr_tpctafim
                   ,pr_cdbanchq => vr_cdbanchq
                   ,pr_cdagenci => vr_cdagechq
                   ,pr_cdcritic => vr_cdcritic
                   ,pr_dscritic => vr_dscritic);
  
  -- Verifica se houvrram erros na execução
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := '[3]-'||vr_dscritic; -- Gerar erros diferentes para cada chamada
    RAISE vr_exc_saida;
  END IF;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  
  

  -- Salvar informações atualizada
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
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS460;
/
