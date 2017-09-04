CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS392(pr_cdcooper  IN craptab.cdcooper%TYPE --> Cooperativa solicitada
                                      ,pr_flgresta  IN PLS_INTEGER            --> Flag 0/1 para utilizar restart na chamada
                                      ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Crítica encontrada
                                      ,pr_dscritic OUT VARCHAR2)  IS         --> Texto de erro/critica encontrada
/* ............................................................................
 
   Programa: PC_CRPS392            Antigo: Fontes/crps392.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Abril/2004.                     Ultima atualizacao: 25/04/2017

   Dados referentes ao programa:

   Frequencia: Trimestral (Batch - Background).
   Objetivo  : Emite: extratos rdca/poup.progr. trimestral na laser (351).
               Solicitacao: 96
               Ordem: 73
               Relatorio: 351
               Tipo Documento: 9
               Formulario: Extrato-trimapl.
                
   Alteracoes: 22/09/2004 -Incluidos historicos 492/493/494/495/496(CI)(Mirtes)

               05/10/2004 - Incluido Conta de Investimento, aumentado o
                            tamanho do campo Nro da Aplicacao e incluidos
                            historicos 482, 484, 485, 486, 487, 488, 489, 
                            490, 491  (Evandro). 
               09/02/2005 - Incluidos historicos 647/648(Conta investimento)
                            (Mirtes)
               22/03/2005 - Retirado Lancamentos Conta Investimento(Mirtes)

               29/04/2005 - Mudado para gerar os arquivos no "rl/";
                            Incluido o nro do dacastro do cooperado na empresa
                            (Evandro).
                            
               31/03/2006 - Concertada clausula OR do FOR EACH, pondo entre
                            parenteses (Diego).

               26/07/2006 - Campo vlslfmes substituido por vlsdextr (Magui).

               01/08/2006 - Incluida verificacao do tpemiext referente aos
                            lancamentos das tabelas craplap e craplpp (David).
                            
               09/04/2007 - Alterado de FormXpress para FormPrint (Diego)
                            
               30/05/2007 - Chamada do programa 'fontes/gera_formprint.p'
                            para executar a geracao e impressao dos
                            formularios em background (Julio)

               22/06/2007 - Alterado para somente verificar as aplicacoes RDCA30
                            e RDCA60 (Elton).
               
               31/10/2007 - Usar nmdsecao a partir do ttl.nmdsecao (Guilherme).
               
               29/05/2008 - alterado para nao emitir extrato poup.prog. qdo 
                            situacao = 5 (resg. pelo vcto) - Rosangela
               
               20/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "for each" da tabela CRAPHIS.
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               06/02/2009 - Movida definicao da variavel aux_nmdatspt para
                            includes/var_informativos.i (Diego).
                            
               03/04/2012 - Substituir nmrescop por dsdircop no 
                            fontes/gera_formprint.p (ZE).

               17/09/2013 - Conversão Progress >> Oracle PL/SQL (Renato - Supero).
              
			   25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
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
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;

  -- Buscar parametro da solicitação
  CURSOR cr_dsparame(pr_cdprogra  crapprg.cdprogra%TYPE) IS
    SELECT crapsol.dsparame
      FROM crapsol crapsol
         , crapprg crapprg
      WHERE crapsol.nrsolici = crapprg.nrsolici
        AND crapsol.cdcooper = crapprg.cdcooper
        AND crapprg.cdcooper = pr_cdcooper
        AND crapprg.cdprogra = pr_cdprogra; 
  
  -- Buscar os registros de historico
  CURSOR cr_craphis IS
    SELECT craphis.cdhistor
      FROM craphis craphis
     WHERE craphis.cdcooper  = pr_cdcooper
       AND craphis.cdhistor IN (113,116,118,119,121,126,143,144,176,178,179,183,262
                               ,264,861,862,868,871,150,151,158,863,870,492,493,494
                               ,495,496,482,484,485,486,487,488,489,490,491,647,648);

  -- Buscar os registros dos associados
  CURSOR cr_crapass(pr_dtiniper   DATE
                   ,pr_dtfimper   DATE) IS
    SELECT crapass.nrdconta
         , crapass.inpessoa
         , crapass.cdsecext
         , crapass.cdagenci
         , crapass.nrcpfcgc
         , crapass.cdcooper
         , crapass.nmprimtl
         , crapass.nrctainv
      FROM crapass 
     WHERE crapass.cdcooper = pr_cdcooper
       AND NVL(crapass.dtdemiss,pr_dtiniper) >= pr_dtiniper
       AND ( 
             -- Trazer apenas associados com dados no cadastro de aplicacoes RDCA, onde:
             -- ** O tipo de impressao do extrato for 2-todas
             -- ** O tipo de aplicação seja 3-RDCA ou 5-RDCAII
             -- ** O valor de saldo do RDCA seja maior que zero ou o periodo esteja    
             --    no intervalo
             EXISTS (SELECT 1
                       FROM craprda
                      WHERE craprda.cdcooper  = crapass.cdcooper
                        AND craprda.nrdconta  = crapass.nrdconta
                        AND craprda.tpemiext  = 2
                        AND craprda.tpaplica IN (3,5) 
                        AND (craprda.vlsdrdca  > 0 
                          OR craprda.dtiniper  BETWEEN pr_dtiniper AND pr_dtfimper )) OR
             /* OU */
             -- Associados com registros de poupança programada, onde:
             -- ** O tipo de impressao do extrato for 2-todas
             -- ** Valor do saldo da poupanca programada seja diferente de zero
             -- ** A situação não seja cancelada nem vencida
             -- ** A data de cancelamento seja maior que a do inicio do período
             -- ** A data de inicio da Poupança seja menor que o fim do periodo
             -- ** A quantidade de prestações pagar maior que zero
             EXISTS (SELECT 1
                       FROM craprpp
                      WHERE craprpp.cdcooper = crapass.cdcooper
                        AND craprpp.nrdconta = crapass.nrdconta
                        AND craprpp.tpemiext  = 2 
                        AND (craprpp.vlsdrdpp <> 0
                          OR craprpp.cdsitrpp NOT IN (3,4) 
                          OR craprpp.dtcancel >= pr_dtiniper)
                        AND (craprpp.dtinirpp <= pr_dtfimper
                          OR craprpp.vlsdrdpp <> 0)
                        AND (craprpp.vlsdrdpp <> 0
                          OR craprpp.qtprepag <> 0)
                        AND craprpp.cdsitrpp  <> 5 ) )
      ORDER BY crapass.cdcooper
             , crapass.cdagenci
             , crapass.cdsecext
             , crapass.nrdconta
             , crapass.progress_recid;

  -- Buscar a empresa do titular 
  CURSOR cr_crapttl(pr_cdcooper   crapttl.cdcooper%TYPE
				   ,pr_nrdconta   crapttl.nrdconta%TYPE
				   ,pr_idseqttl   crapttl.idseqttl%TYPE) IS
    SELECT crapttl.cdempres
	      ,crapttl.nmextttl
      FROM crapttl 
     WHERE crapttl.cdcooper = pr_cdcooper
       AND crapttl.nrdconta = pr_nrdconta   
       AND crapttl.idseqttl = pr_idseqttl; 
  
  -- Buscar dados pessoa juridica
  CURSOR cr_crapjur(pr_nrdconta   crapttl.nrdconta%TYPE) IS
    SELECT crapjur.cdempres
      FROM crapjur 
     WHERE crapjur.cdcooper = pr_cdcooper  
       AND crapjur.nrdconta = pr_nrdconta;
  
  -- Buscar o cadastro do destino do extrato
  CURSOR cr_crapdes(pr_cdsecext  crapdes.cdsecext%TYPE
                   ,pr_cdagenci  crapdes.cdagenci%TYPE) IS
    SELECT crapdes.nmsecext
      FROM crapdes 
     WHERE crapdes.cdcooper = pr_cdcooper      
       AND crapdes.cdsecext = pr_cdsecext  
       AND crapdes.cdagenci = pr_cdagenci;
  
  -- Buscar dados da empresa
  CURSOR cr_crapemp(pr_cdempres crapemp.cdempres%TYPE ) IS
    SELECT crapemp.nmresemp
      FROM crapemp 
     WHERE crapemp.cdcooper = pr_cdcooper
       AND crapemp.cdempres = pr_cdempres;
  
  -- Busca o saldo das contas investimento
  CURSOR cr_crapsli(pr_nrdconta  crapsli.nrdconta%TYPE
                   ,pr_dtmvtolt  DATE) IS
    SELECT crapsli.vlsddisp
      FROM crapsli 
     WHERE crapsli.cdcooper = pr_cdcooper
       AND crapsli.nrdconta = pr_nrdconta
       AND trunc(crapsli.dtrefere,'MM') = trunc(pr_dtmvtolt,'MM');
  
  -- Buscar os dados do cadastro de aplicacoes RDCA para o associado, onde:
  -- ** O tipo de impressao do extrato for 2-todas
  -- ** O tipo de aplicação seja 3-RDCA ou 5-RDCAII
  -- ** O valor de saldo do RDCA seja maior que zero ou o periodo esteja    
  --    no intervalo
  CURSOR cr_craprda1(pr_nrdconta  crapsli.nrdconta%TYPE
                    ,pr_dtiniper  DATE
                    ,pr_dtfimper  DATE) IS
    SELECT craprda.vlsdrdca
         , craprda.dtiniper
         , craprda.tpaplica
         , craprda.vlsdextr
         , craprda.dtmvtolt
         , craprda.nraplica
         , craprda.vlaplica
         , craprda.vlrgtacu
      FROM craprda
     WHERE craprda.cdcooper  = pr_cdcooper
       AND craprda.nrdconta  = pr_nrdconta
       AND craprda.tpemiext  = 2
       AND craprda.tpaplica IN (3,5) 
       AND (craprda.vlsdrdca  > 0 
         OR craprda.dtiniper  BETWEEN pr_dtiniper AND pr_dtfimper )
     ORDER BY cdcooper
            , nrdconta
            , dtmvtolt
            , nraplica
            , progress_recid;
  
  -- Buscar os registros poupanças programadas dos associados, onde:
  -- ** O tipo de impressao do extrato for 2-todas
  -- ** Valor do saldo da poupanca programada seja diferente de zero
  -- ** A situação não seja cancelada nem vencida
  -- ** A data de cancelamento seja maior que a do inicio do período
  -- ** A data de inicio da Poupança seja menor que o fim do periodo
  -- ** A quantidade de prestações pagar maior que zero
  CURSOR cr_craprpp(pr_nrdconta craprpp.nrdconta%TYPE
                   ,pr_dtiniper DATE
                   ,pr_dtfimper DATE) IS
    SELECT craprpp.nrctrrpp
         , craprpp.tpemiext
         , craprpp.vlsdrdpp
         , craprpp.cdsitrpp
         , craprpp.dtcancel
         , craprpp.dtinirpp
         , craprpp.qtprepag
         , craprpp.vlsdextr
         , craprpp.dtmvtolt
         , craprpp.nrdconta
         , craprpp.vlrgtacu
      FROM craprpp
     WHERE craprpp.cdcooper  = pr_cdcooper
       AND craprpp.nrdconta  = pr_nrdconta
       AND craprpp.tpemiext  = 2 
       AND (craprpp.vlsdrdpp <> 0
         OR craprpp.cdsitrpp NOT IN (3,4) 
         OR craprpp.dtcancel >= pr_dtiniper)
       AND (craprpp.dtinirpp <= pr_dtfimper
         OR craprpp.vlsdrdpp <> 0)  
       AND (craprpp.vlsdrdpp <> 0
         OR craprpp.qtprepag <> 0)
       AND craprpp.cdsitrpp  <> 5 
     ORDER BY craprpp.cdcooper
            , craprpp.nrdconta
            , craprpp.nrctrrpp;
  
  -- Buscar os lancamentos de aplicacoes de poupanca programada.
  CURSOR cr_craplpp1(pr_nrdconta  craplpp.nrdconta%TYPE
                    ,pr_nrctrrpp  craplpp.nrctrrpp%TYPE ) IS
    SELECT dtmvtolt 
      FROM craplpp 
     WHERE craplpp.cdcooper = pr_cdcooper       
       AND craplpp.nrdconta = pr_nrdconta   
       AND craplpp.nrctrrpp = pr_nrctrrpp
     ORDER BY craplpp.progress_recid;
  
  -- Buscar os lancamentos de aplicacoes RDCA
  CURSOR cr_craplap(pr_nrdconta  craplap.nrdconta%TYPE
                   ,pr_dtiniper  DATE
                   ,pr_dtfimper  DATE) IS
    SELECT craplap.dtmvtolt
         , craplap.nraplica
         , craplap.cdhistor
         , craplap.vllanmto
      FROM craplap 
     WHERE craplap.cdcooper  = pr_cdcooper       
       AND craplap.nrdconta  = pr_nrdconta   
       AND craplap.dtmvtolt BETWEEN pr_dtiniper AND pr_dtfimper
       AND craplap.cdhistor IN (113,116,118,119,121,126,143,144,176,178,179,183,262
                               ,264,861,862,868,871,150,151,158,863,870,492,493,494
                               ,495,496,482,484,485,486,487,488,489,490,491,647,648)
     ORDER BY craplap.cdcooper
            , craplap.nrdconta
            , craplap.dtmvtolt
            , craplap.cdhistor
            , craplap.nrdocmto
            , craplap.progress_recid;
  
  -- Buscar os dados do cadastro de aplicacoes RDCA.
  CURSOR cr_craprda2(pr_nrdconta  crapsli.nrdconta%TYPE
                    ,pr_nraplica  craprda.nraplica%TYPE) IS 
    SELECT tpemiext
      FROM craprda
     WHERE craprda.cdcooper = pr_cdcooper     
       AND craprda.nrdconta = pr_nrdconta 
       AND craprda.nraplica = pr_nraplica
     ORDER BY craprda.cdcooper
            , craprda.nrdconta
            , craprda.nraplica;
  
  -- Buscar os lancamentos de aplicacoes de poupanca programada.
  CURSOR cr_craplpp2(pr_nrdconta  craplpp.nrdconta%TYPE
                    ,pr_dtiniper  craplpp.dtmvtolt%TYPE
                    ,pr_dtfimper  craplpp.dtmvtolt%TYPE) IS
    SELECT craplpp.cdhistor
         , craplpp.vllanmto
         , craplpp.nrctrrpp
      FROM craplpp 
     WHERE craplpp.cdcooper  = pr_cdcooper
       AND craplpp.nrdconta  = pr_nrdconta
       AND craplpp.dtmvtolt BETWEEN pr_dtiniper AND pr_dtfimper
       AND craplpp.cdhistor IN (113,116,118,119,121,126,143,144,176,178,179,183,262
                               ,264,861,862,868,871,150,151,158,863,870,492,493,494
                               ,495,496,482,484,485,486,487,488,489,490,491,647,648)
     ORDER BY craplpp.cdcooper
            , craplpp.nrdconta
            , craplpp.dtmvtolt
            , craplpp.cdhistor
            , craplpp.nrdocmto
            , craplpp.progress_recid;  
  
  -- Buscar o cadastro de poupanca programada
  CURSOR cr_craprpp2(pr_nrdconta  craplpp.nrdconta%TYPE
                    ,pr_nrctrrpp  craplpp.nrctrrpp%TYPE ) IS 
    SELECT craprpp.tpemiext
      FROM craprpp
     WHERE craprpp.cdcooper = pr_cdcooper
       AND craprpp.nrdconta = pr_nrdconta
       AND craprpp.nrctrrpp = pr_nrctrrpp
     ORDER BY craprpp.cdcooper
            , craprpp.nrdconta
            , craprpp.nrctrrpp;
  
  -- REGISTROS
  rw_crapcop          cr_crapcop%ROWTYPE;  
  rw_crapttl          cr_crapttl%ROWTYPE;
  rw_crapjur          cr_crapjur%ROWTYPE;
  rw_crapemp          cr_crapemp%ROWTYPE;
  rw_glb_crapass      cr_crapass%ROWTYPE;

  -- TIPOS
  TYPE typ_histor  IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  TYPE typ_valores IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
  
  -- VARIÁVEIS  
  -- Código do programa
  vr_cdprogra      CONSTANT VARCHAR2(10) := 'CRPS392';
  -- Datas de movimento e controle
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;
  vr_dtiniper      DATE;
  vr_dtfimper      DATE;
  -- Instancias e chave para manter os formulário
  vr_tab_cratext   form0001.typ_tab_cratext;
  vr_chv_cratext   VARCHAR2(40); -- Chave com Cooperativa(10) + Agencia(5) + Sessão(5) + Conta(10) + Ordem(10)
  -- Variáveis relativas aos arquivos
  vr_qtmaxarq      CONSTANT NUMBER :=	500;
  vr_nmarqdat      VARCHAR2(100);
  vr_nmarqimp      VARCHAR2(100);
  vr_nmscript      VARCHAR2(100);
  vr_imlogoin      VARCHAR2(200);
  vr_imlogoex      VARCHAR2(200); 
  vr_imgvazio      VARCHAR2(200);
  vr_impostal      VARCHAR2(200);
  vr_nrarquiv      NUMBER;
  -- Parametro da solicitação
  vr_dsparame      crapsol.dsparame%TYPE;
  -- Informações do histórico
  vr_tbhistor      typ_histor;
  -- Contador de registros do arquivo
  vr_qtregarq      NUMBER;
  -- Código da empresa do associado
  vr_cdempres      crapttl.cdempres%TYPE;
  --Variaveis auxiliares, de controle e contadores
  vr_flgaplic      BOOLEAN;      
  vr_totresga      NUMBER := 0;
  vr_nrfolhas      NUMBER := 0;       
  vr_totaplic      NUMBER := 0;
  vr_vldebito      NUMBER := 0;
  vr_totdebit      NUMBER := 0;
  vr_totcredi      NUMBER := 0;
  vr_qtdaplic      NUMBER := 0;
  vr_nrctainv      NUMBER := 0;
  vr_contador      NUMBER := 0;
  vr_nmdatspt      VARCHAR2(50);
  vr_nmimpspt      VARCHAR2(50);
  -- Descrição destino extrato
  vr_nmsecext      crapdes.nmsecext%TYPE;
  -- Descrição da empresa
  vr_nmresemp      crapemp.nmresemp%TYPE;
  -- Valor de saldo da conta investimento
  vr_vlltotci      crapsli.vlsddisp%TYPE := 0;
  -- Número ordem
  vr_nrdordem      NUMBER;
  -- Nome da secao onde o associado trabalha.
  vr_nmdsecao      VARCHAR2(25);
  -- CPF ou CNPJ formatado
  vr_dscpfcgc      VARCHAR2(30);
  -- Descrição da aplicação
  vr_dsaplica      VARCHAR2(100);
  -- Valor do saldo para emissao de extrato.
  vr_vlsdextr      craprda.vlsdextr%TYPE;
  -- Data do movimento de lancamentos de aplicacoes de poupanca programada
  vr_dtmvtppr      craplpp.dtmvtolt%TYPE;
  -- Tipo de impressão do extrato
  vr_tpemiext      craprda.tpemiext%TYPE;
  -- Array auxiliar para guardar valores
  vr_tbcredit      typ_valores;       
  vr_tbdebito      typ_valores;
  -- Diretório das cooperativas
  vr_dsdireto      VARCHAR2(200);
  -- Tipo de saída do comando Host
  vr_typ_said      VARCHAR2(100);
  -- Indicador de execução do script
  vr_flgexect      NUMBER;
  -- Variável de críticas
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(4000);
  -- Tratamento de erros
  vr_exc_saida     EXCEPTION;
  vr_exc_fimprg    EXCEPTION;
  vr_nmsegntl      crapttl.nmextttl%TYPE;

  /***************************** PROCEDIMENTOS INTERNOS *****************************/
  -- Imprimir o destino
  PROCEDURE pc_imprime_destino IS
     
  BEGIN

    -- Data
    vr_tab_cratext(vr_chv_cratext).dsintern(80) := TO_CHAR(vr_dtmvtolt,'DD/MM/YYYY');

    IF vr_qtdaplic = 50 THEN
      vr_dsaplica := 'CONTINUA';
      vr_tab_cratext(vr_chv_cratext).dsintern(60) := vr_dsaplica;
      vr_tab_cratext(vr_chv_cratext).dsintern(81) := NULL;
    ELSE

      vr_tab_cratext(vr_chv_cratext).dsintern(81) := 'Nro Conta Investimento: '||
                                                     TRIM(gene0002.fn_mask(rw_glb_crapass.nrctainv,'99.999.999.9'))||
                                                     '   Saldo nao aplicado em  '||
                                                     TO_CHAR(vr_dtmvtolt,'DD/MM/YYYY')||
                                                     ' :  '||
                                                     TO_CHAR(vr_vlltotci,'999G999G990D00MI');
    END IF;

    -- Finaliza
    vr_tab_cratext(vr_chv_cratext).dsintern(82) := '#';
    
  END pc_imprime_destino;
  /**********************************************************************************/
  -- Imprimir o cabeçalho
  PROCEDURE pc_imprime_cabecalho IS
  
    -- Buscar os dados do PA
    CURSOR cr_crapage(pr_cdagenci crapage.cdagenci%TYPE ) IS
      SELECT crapage.nmresage
        FROM crapage
       WHERE crapage.cdcooper = pr_cdcooper
         AND crapage.cdagenci = pr_cdagenci;
    
    -- REGISTROS
    rw_crapage     cr_crapage%ROWTYPE;
    
    -- VARIÁVEIS
    -- Descrição da agendia
    vr_dsagenci      VARCHAR2(100);
    
  BEGIN
    
    -- Limpar
    vr_dsagenci := NULL;
  
    -- Verifica a quantidade
    IF vr_qtdaplic = 50 THEN
      
      -- Chama rotina de impressão
      pc_imprime_destino;
      
      -- Zera a variável
      vr_qtdaplic := 0;
      -- Atualiza o número da ordem
      vr_nrdordem := vr_nrdordem + 1;
    END IF;  
    
    -- Buscar informação PA
    OPEN  cr_crapage(rw_glb_crapass.cdagenci);
    FETCH cr_crapage INTO rw_crapage;
    
    -- 
    IF NOT vr_flgaplic THEN

      -- Se for pessoa física
      IF rw_glb_crapass.inpessoa = 1 THEN
        -- Formata como CPF
        vr_dscpfcgc := TRIM(gene0002.fn_mask(rw_glb_crapass.nrcpfcgc,'999.999.999-99'));
      ELSE
        -- Formata como CNPJ
        vr_dscpfcgc := TRIM(gene0002.fn_mask(rw_glb_crapass.nrcpfcgc,'99.999.999/9999-99'));
      END IF;
      
      -- Se encontrou um registro
      IF cr_crapage%FOUND THEN
        -- Monta a descrição da agencia
        vr_dsagenci := LPAD(rw_glb_crapass.cdagenci,4,'0')||' - '||rw_crapage.nmresage;
      ELSE
        -- Monta a descrição da agencia
        vr_dsagenci := LPAD(rw_glb_crapass.cdagenci,4,'0')||' - Nao cadastrada';
      END IF;
       
    END IF;
      
    -- Fecha o cursor
    CLOSE cr_crapage;
      
    -- Add contadores
    vr_nrfolhas := vr_nrfolhas + 1;
    vr_qtregarq := vr_qtregarq + 1;

    -- Monta a chave para o registro de memória
    vr_chv_cratext := (LPAD(rw_glb_crapass.cdcooper,10,'0')
                     ||LPAD(rw_glb_crapass.cdagenci, 5,'0')
                     ||LPAD(rw_glb_crapass.cdsecext, 5,'0')
                     ||LPAD(rw_glb_crapass.nrdconta,10,'0')
                     ||LPAD(vr_nrdordem          ,10,'0'));
      
    vr_tab_cratext(vr_chv_cratext).nmsecext    := vr_nmdsecao;
    vr_tab_cratext(vr_chv_cratext).nmprimtl    := rw_glb_crapass.nmprimtl;
    vr_tab_cratext(vr_chv_cratext).nmempres    := rw_crapemp.nmresemp;
    vr_tab_cratext(vr_chv_cratext).nrdconta    := rw_glb_crapass.nrdconta;
    vr_tab_cratext(vr_chv_cratext).nmagenci    := rw_crapage.nmresage;
    vr_tab_cratext(vr_chv_cratext).indespac    := 2;  /* SECAO */
    vr_tab_cratext(vr_chv_cratext).dtemissa    := vr_dtmvtolt;
    vr_tab_cratext(vr_chv_cratext).nrdordem    := vr_nrdordem;
    vr_tab_cratext(vr_chv_cratext).tpdocmto    := 9;
    vr_tab_cratext(vr_chv_cratext).nrseqint    := vr_qtregarq ;
    vr_tab_cratext(vr_chv_cratext).dsintern(1) := SUBSTR(rw_glb_crapass.nmprimtl,1,40);
    vr_tab_cratext(vr_chv_cratext).dsintern(2) := SUBSTR(vr_nmsegntl,1,40);
    vr_tab_cratext(vr_chv_cratext).dsintern(3) := vr_dscpfcgc ;
    vr_tab_cratext(vr_chv_cratext).dsintern(4) := gene0002.fn_mask(rw_glb_crapass.nrdconta,'zzzz.zz9.9');
    vr_tab_cratext(vr_chv_cratext).dsintern(5) := vr_dsagenci;
    vr_tab_cratext(vr_chv_cratext).dsintern(6) := LPAD(vr_nrfolhas,3,'0');
    vr_tab_cratext(vr_chv_cratext).dsintern(7) := TO_CHAR(vr_dtiniper,'DD/MM/YYYY')||' A '||TO_CHAR(vr_dtfimper,'DD/MM/YYYY');
    vr_tab_cratext(vr_chv_cratext).dsintern(8) := TO_CHAR(vr_dtmvtolt,'DD/MM/YYYY');
    vr_tab_cratext(vr_chv_cratext).dsintern(9) := TO_CHAR(vr_dtmvtolt,'DD/MM/YYYY');
      
    -- Guarda a ultima posição grava para a dsintern
    vr_contador        := 9;
      
    vr_flgaplic := TRUE;
      
  EXCEPTION
    WHEN OTHERS THEN
      -- Mensagem de erro
      vr_dscritic := 'Erro PC_IMPRIME_CABECALHO: '||SQLERRM;
      RAISE vr_exc_saida;
  END pc_imprime_cabecalho;
  /**********************************************************************************/
  
BEGIN
  
  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS392',
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
  
  -- Buscar diretório base da cooperativa
  vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Coop
                                      ,pr_cdcooper => pr_cdcooper);
  
  -- Definir os dados dos arquivos
  vr_nmarqdat := 'crrl351_'||TO_CHAR(vr_dtmvtolt,'DDMM')||'_';
  vr_nmarqimp := 'crrl351_';
  vr_nmscript := 'crrl351.sh';
  vr_imlogoin := /*vr_dsdireto||'/*/'laser/imagens/logo_'||TRIM(LOWER(rw_crapcop.nmrescop))||'_externo.pcx';
  vr_imlogoex := /*vr_dsdireto||'/*/'laser/imagens/logo_'||TRIM(LOWER(rw_crapcop.nmrescop))||'_externo.pcx';
  vr_imgvazio := /*vr_dsdireto||'/*/'laser/imagens/vazio_grande.pcx';
  vr_impostal := /*vr_dsdireto||'/*/'laser/imagens/chancela_ect_cecred_grande.pcx'; 
  
  -- Limpar as variáveis
  vr_dtiniper := NULL;
  vr_dtfimper := NULL;
  vr_dsparame := NULL;
  
  -- Buscar a data do periodo no parametro
  OPEN  cr_dsparame(vr_cdprogra);
  FETCH cr_dsparame INTO vr_dsparame;
  CLOSE cr_dsparame;
  
  -- Separar os parametros
  vr_dtiniper := TO_DATE(gene0002.fn_busca_entrada(1,vr_dsparame,','),'DD/MM/YYYY');
  vr_dtfimper := TO_DATE(gene0002.fn_busca_entrada(2,vr_dsparame,','),'DD/MM/YYYY');

  -- Limpa o registro de memória dos registros que irão ser impressos
  vr_tab_cratext.DELETE;

  -- Limpa o registro de memória dos históricos
  vr_tbhistor.DELETE;

  -- Buscar registros de históricos
  FOR rg_craphis IN cr_craphis LOOP
    
    -- Verifica o histórico
    IF    rg_craphis.cdhistor IN (113           /* Aplicacao rdca30 */
                                 ,176)     THEN /* Aplicacao rdca60 */
      vr_tbhistor(1) := 'Aplicacoes Rdca';
    
    ELSIF rg_craphis.cdhistor IN (116           /* rendimento rdca30 */
                                 ,179)     THEN /* rendimento rdca60 */
      vr_tbhistor(2) := 'Rendimentos Rdca';
    
    ELSIF rg_craphis.cdhistor IN (118,492       /* resgate rdca30*/
                                 ,126,493       /* sem rendim rdca30 */
                                 ,178,494,183   /* resgate rdca60 */
                                 ,495)     THEN /* sem rendim rdca60 */
      vr_tbhistor(3) := 'Resgates Rdca';
    
    ELSIF rg_craphis.cdhistor = 119        THEN /* dif taxa maior */
      vr_tbhistor(4) := 'Diferenca Taxa a Maior Rdca';
    
    ELSIF rg_craphis.cdhistor = 121        THEN /* dif taxa menor */
      vr_tbhistor(5) := 'Diferenca Taxa a Menor Rdca';
    
    ELSIF rg_craphis.cdhistor = 143        THEN /* resgate unificacao */
      vr_tbhistor(6) := 'Resgates para Unificacao Rdca';
    
    ELSIF rg_craphis.cdhistor = 144        THEN /* unificacao */
      vr_tbhistor(7) := 'Unificacoes Rdca';
    
    ELSIF rg_craphis.cdhistor IN (861           /* irrf rendimento rdca30 */
                                 ,862           /* irrf rendimento rdca60 */
                                 ,868           /* irrf abono rdca30 */
                                 ,871)     THEN /* irrf abono rdca60 */
      vr_tbhistor(8) := 'IRRF sobre Rdca';
    
    ELSIF rg_craphis.cdhistor = 150        THEN /* credito do plano */
      vr_tbhistor(9) := 'Credito Plano Poupanca Programada';
    
    ELSIF rg_craphis.cdhistor = 151        THEN /* rendimento */
      vr_tbhistor(10):= 'Redimentos Poupanca Programada';
    
    ELSIF rg_craphis.cdhistor IN (158,496) THEN /* resgate */
      vr_tbhistor(11):= 'Resgates Poupanca Programada';
    
    ELSIF rg_craphis.cdhistor IN (863           /* irrf sobre rendimento */
                                 ,870)     THEN /* irrf sobre abono */
      vr_tbhistor(12):= 'IRRF sobre Poupanca Programada';
    END IF;
    
  END LOOP;

  -- Zera a variavel/contador de registro
  vr_qtregarq := 0;
  
  -- Buscar os registros dos associados
  FOR rw_crapass IN cr_crapass(vr_dtiniper, vr_dtfimper) LOOP

    -- Popula o registro global
    rw_glb_crapass := rw_crapass;

    -- Limpa a variável
    vr_cdempres := NULL;
    vr_nmsecext := NULL;
  	vr_nmsegntl := NULL;
  	vr_nmdsecao := NULL;
    
    -- Buscar o cadastro de Destinos de extratos
    OPEN  cr_crapdes(rw_crapass.cdsecext
                    ,rw_crapass.cdagenci);

    FETCH cr_crapdes INTO vr_nmsecext; 

    CLOSE cr_crapdes;
    
    -- Buscar o código da empresa quando pessoa física
    --> Tipo de pessoa (1 - fisica, 2 - juridica, 3 - cheque adm.).
    IF rw_crapass.inpessoa = 1 THEN
      
      -- Busca os cadastros dos titulares da conta
      OPEN  cr_crapttl(pr_cdcooper => rw_crapass.cdcooper
	                  ,pr_nrdconta => rw_crapass.nrdconta
					  ,pr_idseqttl => 1);
      
      FETCH cr_crapttl INTO rw_crapttl;
      
	  CLOSE cr_crapttl;  

        vr_nmdsecao := vr_nmsecext;
      
      -- Guardar empresa
      vr_cdempres := rw_crapttl.cdempres;
      
      -- Busca os cadastros dos titulares da conta
      OPEN  cr_crapttl(pr_cdcooper => rw_crapass.cdcooper
	                  ,pr_nrdconta => rw_crapass.nrdconta
					  ,pr_idseqttl => 2);
      
	  FETCH cr_crapttl INTO rw_crapttl;
      
      CLOSE cr_crapttl;  

	  vr_nmsegntl := rw_crapttl.nmextttl;
         
    ELSE
      -- Busca os cadastros de pessoas juridicas.
      OPEN  cr_crapjur(rw_crapass.nrdconta);
      FETCH cr_crapjur INTO rw_crapjur;
      
      IF cr_crapjur%FOUND THEN
        -- Guardar empresa
        vr_cdempres := rw_crapjur.cdempres;
      END IF;
      
      CLOSE cr_crapjur;
    END IF;
        
    -- Inicializar as variáveis
    vr_flgaplic := FALSE;
    vr_totresga := 0;
    vr_nrfolhas := 0;       
    vr_totaplic := 0;
    vr_vldebito := 0;
    vr_totdebit := 0;
    vr_totcredi := 0;
    vr_qtdaplic := 0;
    vr_vlltotci := 0;
    vr_nrctainv := 0;  
    vr_vlltotci := 0;
    
    -- Limpar os registros de memória de valores de créditos e débitos
    vr_tbcredit.DELETE;
    vr_tbdebito.DELETE;
    
    -- Reinicializar 
    FOR ind IN 1..12 LOOP
      vr_tbcredit(ind) := 0;
      vr_tbdebito(ind) := 0;
    END LOOP;
        
    -- Buscar o cadastro de empresas
    OPEN  cr_crapemp(vr_cdempres);
    FETCH cr_crapemp INTO rw_crapemp;
    CLOSE cr_crapemp;
    
    vr_nmresemp := rw_crapemp.nmresemp;
    
    -- Buscar o saldo da conta investimento
    OPEN  cr_crapsli(rw_crapass.nrdconta, vr_dtmvtolt);
    FETCH cr_crapsli INTO vr_vlltotci;
    CLOSE cr_crapsli;
    
    -- Contador de folhas de extrato por cooperado
    vr_nrdordem := 1;
    
    -- Buscar dados do cadastro de aplicacoes RDCA.
    FOR rw_craprda IN cr_craprda1(rw_crapass.nrdconta,vr_dtiniper,vr_dtfimper) LOOP
    
      -- Se o valor do saldo do RDCA for maior ou igual a zero e 
      -- a data de inicio do periodo estiver no intervalo.
      IF rw_craprda.vlsdrdca <= 0 AND 
         rw_craprda.dtiniper NOT BETWEEN vr_dtiniper AND vr_dtfimper THEN
        CONTINUE; -- próximo
      END IF;

      -- Verifica controle
      IF NOT vr_flgaplic OR vr_qtdaplic = 50 THEN
        -- Chama a rotina
        pc_imprime_cabecalho;
      END IF;
      
      -- Monta a chave para o registro de memória
      vr_chv_cratext := LPAD(rw_crapass.cdcooper,10,'0')
                      ||LPAD(rw_crapass.cdagenci, 5,'0')
                      ||LPAD(rw_crapass.cdsecext, 5,'0')
                      ||LPAD(rw_crapass.nrdconta,10,'0')
                      ||LPAD(vr_nrdordem        ,10,'0');
      
      -- Verificar se o registro foi criado
      IF NOT vr_tab_cratext.EXISTS(vr_chv_cratext) THEN
        -- Montar mensagem de critica
        vr_cdcritic := 11;
        RAISE vr_exc_fimprg;
      END IF;
      
      -- Limpar
      vr_dsaplica := NULL;
     
      -- Se o tipo de aplicação for RDCA
      IF rw_craprda.tpaplica = 3 THEN
        vr_dsaplica := 'RDCA30';
      ELSE
        vr_dsaplica := 'RDCA60';     
      END IF;
      
      -- Se o valor do saldo para emissao de extrato for menor que zero
      IF rw_craprda.vlsdextr < 0 THEN
        vr_vlsdextr := 0;
      ELSE
        vr_vlsdextr := rw_craprda.vlsdextr;
      END IF;
      
      -- Incrementa o contador
      vr_contador := vr_contador + 1; /* Lancamentos Extrato*/
     
      vr_tab_cratext(vr_chv_cratext).dsintern(vr_contador) := 
                       TO_CHAR(rw_craprda.dtmvtolt,'DD/MM/YYYY')||'  '||
                       gene0002.fn_mask(rw_craprda.nraplica,'z.zzz.zz9')||'   '||
                       RPAD(vr_dsaplica,8,' ')||
                       TO_CHAR(rw_craprda.vlaplica,'99G999G990D00')||'   '||
                       TO_CHAR(rw_craprda.vlrgtacu,'99G999G990D00')||'  '||
                       TO_CHAR(vr_vlsdextr,'99G999G990D00');
        
      vr_totresga := vr_totresga + rw_craprda.vlrgtacu;
      vr_totaplic := vr_totaplic + vr_vlsdextr;
      vr_qtdaplic := vr_qtdaplic + 1;
      
    END LOOP;  -- cr_craprda1

    -- Percorrer os cadastros de poupanças programadas
    FOR rw_craprpp IN cr_craprpp(rw_crapass.nrdconta,vr_dtiniper,vr_dtfimper) LOOP
       
      -- Se não for impressao de todos os extratos 
      IF rw_craprpp.tpemiext <> 2 THEN
        CONTINUE;  -- Próximo
      END IF;
          
      -- Se o valor saldo é zero, a situação for cancelado ou vencido e foi cancelado 
      -- antes do inicio do periodo
      IF rw_craprpp.vlsdrdpp  = 0           AND
         rw_craprpp.cdsitrpp IN (3,4)       AND 
         rw_craprpp.dtcancel  < vr_dtiniper THEN
        CONTINUE;  -- Próximo
      END IF;
      
      -- Se a data de inicio da poupanca programada é maior que o fim do periodo
      -- e o valor é igual a zero
      IF rw_craprpp.dtinirpp > vr_dtfimper AND
         rw_craprpp.vlsdrdpp = 0           THEN
        CONTINUE;  -- Próximo
      END IF;
      
      -- Se o valor da poupança e a quantidade de prestacoes pagas 
      -- no plano, são iguais a zero 
      IF rw_craprpp.vlsdrdpp = 0  AND
         rw_craprpp.qtprepag = 0  THEN
        CONTINUE;  -- Próximo
      END IF;

      -- Se a situação da poupança é resgatada pelo vencimento
      IF rw_craprpp.cdsitrpp = 5 THEN 
        CONTINUE;  -- Próximo
      END IF;

      -- Verifica controle
      IF NOT vr_flgaplic OR vr_qtdaplic = 50 THEN
        -- Chama a rotina
        pc_imprime_cabecalho;
      END IF;
      
      -- Monta a chave para o registro de memória
      vr_chv_cratext := LPAD(rw_crapass.cdcooper,10,'0')
                      ||LPAD(rw_crapass.cdagenci, 5,'0')
                      ||LPAD(rw_crapass.cdsecext, 5,'0')
                      ||LPAD(rw_crapass.nrdconta,10,'0')
                      ||LPAD(vr_nrdordem        ,10,'0');
      
      -- Verificar se o registro foi criado
      IF NOT vr_tab_cratext.EXISTS(vr_chv_cratext) THEN
        -- Montar mensagem de critica
        vr_cdcritic := 11;
        RAISE vr_exc_fimprg;
      END IF;
      
      -- Define a aplicação
      vr_dsaplica := 'P.PROG';
      
      -- Se o valor do saldo para emissao de extrato for menor que zero
      IF rw_craprpp.vlsdextr < 0 THEN
        vr_vlsdextr := 0;
      ELSE
        vr_vlsdextr := rw_craprpp.vlsdextr;
      END IF;

      -- Buscar os lançamentos de aplicações em poupança programada
      OPEN  cr_craplpp1(rw_craprpp.nrdconta, rw_craprpp.nrctrrpp);
      FETCH cr_craplpp1 INTO vr_dtmvtppr;

      -- Se foram encontrados registros
      IF cr_craplpp1%FOUND THEN
        -- Se a data retornada for menor que a do cadastro da poupanca programada
        IF vr_dtmvtppr > rw_craprpp.dtmvtolt THEN
          vr_dtmvtppr := rw_craprpp.dtmvtolt;
        END IF;
      ELSE 
        vr_dtmvtppr := rw_craprpp.dtmvtolt;
      END IF;
      
      CLOSE cr_craplpp1;
      
      -- Incrementa o contador
      vr_contador := vr_contador + 1; /* Lancamentos Extrato*/
      
      vr_tab_cratext(vr_chv_cratext).dsintern(vr_contador) := 
                       TO_CHAR(vr_dtmvtppr,'DD/MM/YYYY')||'  '||
                       gene0002.fn_mask(rw_craprpp.nrctrrpp,'z.zzz.zz9')||'   '||
                       RPAD(vr_dsaplica,25,' ')||
                       TO_CHAR(rw_craprpp.vlrgtacu,'99G999G990D00')||'  '||
                       TO_CHAR(vr_vlsdextr,'99G999G990D00');
     
      -- Totalizadores
      vr_totresga := vr_totresga + rw_craprpp.vlrgtacu;
      vr_totaplic := vr_totaplic + vr_vlsdextr;
      vr_qtdaplic := vr_qtdaplic + 1;
      
    END LOOP;  -- cr_craprpp
          
    -- Verifica a flag de aplicação
    IF NOT vr_flgaplic THEN
      CONTINUE;  -- Próximo
    END IF;
    
    -- Buscar lancamentos de aplicacoes RDCA
    FOR rw_craplap IN cr_craplap(rw_crapass.nrdconta,vr_dtiniper,vr_dtfimper) LOOP
        
      -- Limpar
      vr_tpemiext := NULL;
    
      -- Buscar o cadastro de aplicacoes RDCA
      OPEN  cr_craprda2(rw_crapass.nrdconta, rw_craplap.nraplica);
      FETCH cr_craprda2 INTO vr_tpemiext;
      CLOSE cr_craprda2;
      
      -- Se não for impressao de todos os extratos
      IF NVL(vr_tpemiext,-1) <> 2 THEN
        CONTINUE;  -- Próximo
      END IF;
      
      -- Atualiza os totais conforme o histórico
      IF    rw_craplap.cdhistor IN (113,176) THEN 
        vr_tbcredit(1) := vr_tbcredit(1) + NVL(rw_craplap.vllanmto,0);
        vr_totcredi    := vr_totcredi    + NVL(rw_craplap.vllanmto,0);
      ELSIF rw_craplap.cdhistor IN (116,179) THEN
        vr_tbcredit(2) := vr_tbcredit(2) + NVL(rw_craplap.vllanmto,0);
        vr_totcredi    := vr_totcredi    + NVL(rw_craplap.vllanmto,0);
      ELSIF rw_craplap.cdhistor IN (118,492,126,493,178,494,183,495)  THEN 
        vr_tbdebito(3) := vr_tbdebito(3) + NVL(rw_craplap.vllanmto,0);
        vr_totdebit    := vr_totdebit    + NVL(rw_craplap.vllanmto,0);
      ELSIF rw_craplap.cdhistor = 119        THEN 
        vr_tbcredit(4) := vr_tbcredit(4) + NVL(rw_craplap.vllanmto,0);
        vr_totcredi    := vr_totcredi    + NVL(rw_craplap.vllanmto,0);
      ELSIF rw_craplap.cdhistor = 121        THEN 
        vr_tbdebito(5) := vr_tbdebito(5) + NVL(rw_craplap.vllanmto,0);
        vr_totdebit    := vr_totdebit    + NVL(rw_craplap.vllanmto,0);
      ELSIF rw_craplap.cdhistor = 143        THEN 
        vr_tbdebito(6) := vr_tbdebito(6) + NVL(rw_craplap.vllanmto,0);
        vr_totdebit    := vr_totdebit    + NVL(rw_craplap.vllanmto,0);
      ELSIF rw_craplap.cdhistor = 144        THEN 
        vr_tbcredit(7) := vr_tbcredit(7) + NVL(rw_craplap.vllanmto,0);
        vr_totcredi    := vr_totcredi    + NVL(rw_craplap.vllanmto,0);
      ELSIF rw_craplap.cdhistor IN (861,862,868,871)                  THEN
        vr_tbdebito(8) := vr_tbdebito(8) + NVL(rw_craplap.vllanmto,0);
        vr_totdebit    := vr_totdebit    + NVL(rw_craplap.vllanmto,0);
      END IF;

    END LOOP;  -- cr_craplap
     
    -- Percorrer os lancamentos de aplicacoes de poupanca programada.
    FOR rw_craplpp IN cr_craplpp2(rw_crapass.nrdconta,vr_dtiniper,vr_dtfimper) LOOP
    
      -- Limpar
      vr_tpemiext := NULL;
    
      -- Buscar o cadastro de poupanca programada
      OPEN  cr_craprpp2(rw_crapass.nrdconta,rw_craplpp.nrctrrpp);
      FETCH cr_craprpp2 INTO vr_tpemiext;
      CLOSE cr_craprpp2;
      
      -- Se não for impressao de todos os extratos 
      IF NVL(vr_tpemiext,-1) <> 2 THEN
        CONTINUE;  -- Próximo
      END IF;
      
      IF    rw_craplpp.cdhistor = 150         THEN
        vr_tbcredit(9) := vr_tbcredit(9) + NVL(rw_craplpp.vllanmto,0);
        vr_totcredi    := vr_totcredi    + NVL(rw_craplpp.vllanmto,0);
      ELSIF rw_craplpp.cdhistor = 151         THEN 
        vr_tbcredit(10):= vr_tbcredit(10) + NVL(rw_craplpp.vllanmto,0);
        vr_totcredi    := vr_totcredi     + NVL(rw_craplpp.vllanmto,0);
      ELSIF rw_craplpp.cdhistor IN (158,496)  THEN 
        vr_tbdebito(11):= vr_tbdebito(11) + NVL(rw_craplpp.vllanmto,0);
        vr_totdebit    := vr_totdebit     + NVL(rw_craplpp.vllanmto,0);
      ELSIF rw_craplpp.cdhistor IN (863,870)  THEN
        vr_tbdebito(12):= vr_tbdebito(12) + NVL(rw_craplpp.vllanmto,0);
        vr_totdebit    := vr_totdebit     + NVL(rw_craplpp.vllanmto,0);
      END IF;
    
    END LOOP; -- cr_craplpp2
         
    -- Ajusta controles
    vr_qtdaplic := 0;
    vr_dsaplica := 'TOTAIS';
    
    -- Atualizar informações
    vr_tab_cratext(vr_chv_cratext).dsintern(60) := vr_dsaplica;
    vr_tab_cratext(vr_chv_cratext).dsintern(61) := to_char(vr_totresga,'99G999G990D00')||'  '||
                                                   to_char(vr_totaplic,'99G999G990D00');
    vr_tab_cratext(vr_chv_cratext).dsintern(62) := to_char(vr_dtiniper,'DD/MM/YYYY')||'       '||
                                                   to_char(vr_dtfimper,'DD/MM/YYYY');
    -- Atualizar o contador de controle
    vr_contador := 63;
         
    -- Iteração para tratar os totais
    FOR ind IN 1..12 LOOP
    
      -- Se o valor do crédito e do débito forem zero
      IF vr_tbcredit(ind) = 0 AND vr_tbdebito(ind) = 0 THEN
        CONTINUE; -- PRÓXIMO
      END IF;
      
      -- Gravar no registro de memória os totalizadores
      vr_tab_cratext(vr_chv_cratext).dsintern(vr_contador) :=
                           RPAD(vr_tbhistor(ind),41,' ');
      
      -- Se o valor do débito for diferentes de zero
      IF vr_tbdebito(ind) <> 0 THEN 
        -- Grava o valor de débitos
        vr_tab_cratext(vr_chv_cratext).dsintern(vr_contador) := vr_tab_cratext(vr_chv_cratext).dsintern(vr_contador)||
                                                        to_char(vr_tbdebito(ind),'99G999G990D00');
      ELSE
        -- Grava espaços em branco
        vr_tab_cratext(vr_chv_cratext).dsintern(vr_contador) := vr_tab_cratext(vr_chv_cratext).dsintern(vr_contador)||
                                                        '                     ';
      END IF;
      
      -- Se o valor do crédito for diferentes de zero
      IF vr_tbcredit(ind) <> 0 THEN 
        -- Grava o valor de crédito
        vr_tab_cratext(vr_chv_cratext).dsintern(vr_contador) := vr_tab_cratext(vr_chv_cratext).dsintern(vr_contador)||
                                                        to_char(vr_tbcredit(ind),'99G999G990D00');
      ELSE
        -- Grava espaços em branco
        vr_tab_cratext(vr_chv_cratext).dsintern(vr_contador) := vr_tab_cratext(vr_chv_cratext).dsintern(vr_contador)||
                                                        '                     ';
      END IF;
     
      -- Incrementa o contador de controle
      vr_contador := vr_contador + 1; 
      
    END LOOP;
     
    -- Se o total do débito for diferente de zero
    IF vr_totdebit <> 0  THEN 
      -- Grava o total de débito
      vr_tab_cratext(vr_chv_cratext).dsintern(79) := to_char(vr_totdebit,'99G999G990D00')||'       ';
    ELSE
      -- Grava espaços
      vr_tab_cratext(vr_chv_cratext).dsintern(79) := '                     ';
    END IF;
    
    -- Se o total do crédito for diferente de zero
    IF vr_totcredi <> 0  THEN
      -- Grava o total do crédito
      vr_tab_cratext(vr_chv_cratext).dsintern(79) := vr_tab_cratext(vr_chv_cratext).dsintern(79)||
                                                     to_char(vr_totcredi,'99G999G990D00');
    ELSE
      -- Grava espaços
      vr_tab_cratext(vr_chv_cratext).dsintern(79) := vr_tab_cratext(vr_chv_cratext).dsintern(79)||
                                                     '                     ';
    END IF;
 
    -- Chama a rotina de impressão do destino
    pc_imprime_destino;
    
  END LOOP; -- CR_CRAPASS -- ASSOCIADOS

  -- Chamar a rotina de geração do arquivo com os extratos
  form0001.pc_gera_dados_inform_1(pr_cdcooper    => pr_cdcooper
                                 ,pr_cdacesso    => NULL
                                 ,pr_qtmaxarq    => vr_qtmaxarq
                                 ,pr_nrarquiv    => vr_nrarquiv
                                 ,pr_dsdireto    => vr_dsdireto||'/arq' 
                                 ,pr_nmarqdat    => vr_nmarqdat
                                 ,pr_tab_cratext => vr_tab_cratext
                                 ,pr_imlogoex    => vr_imlogoex    
                                 ,pr_imlogoin    => vr_imlogoin 
                                 ,pr_impostal    => vr_impostal 
                                 ,pr_imcorre1    => NULL
                                 ,pr_imgvazio    => vr_imgvazio
                                 ,pr_des_erro    => vr_dscritic);
                            
  -- Testar saida com erro
  IF vr_dscritic IS NOT NULL THEN
    -- Gerar exceção
    vr_cdcritic := 0;
    RAISE vr_exc_saida;
  END IF;

  -- Se a quantidade for diferente de zero
  IF vr_qtregarq <> 0 THEN

    -- Remove possíveis arquivos antigos do diretório
    gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdireto||'/arq/'||vr_nmscript||' 2> /dev/null'
                               ,pr_typ_saida   => vr_typ_said
                               ,pr_des_saida   => vr_dscritic);
      
    -- Testar erro
    IF vr_typ_said = 'ERR' THEN
      -- Adicionar o erro na variavel de erros
      vr_dscritic := 'Erro ao excluir arquivo --> '||vr_dscritic;
      RAISE vr_exc_saida;    
    END IF;
    
    -- Remove a lista de comandos LP a seremn executados
    FORM0001.vr_tbcommand.DELETE;
    FORM0001.vr_tbscript.DELETE;
    
    -- Iteração para todos os arquivos
    WHILE vr_nrarquiv > 0 LOOP
      -- Formar o nome dos arquivos                                 
      vr_nmdatspt := TRIM(vr_nmarqdat)||to_char(vr_nrarquiv, 'FM00')||'.dat';
      vr_nmimpspt := TRIM(vr_nmarqimp)||to_char(vr_nrarquiv, 'FM00')||'.lst';
      
      -- Se for o ultimo arquivo
      IF vr_nrarquiv = 1 THEN
        -- Executar o script
        vr_flgexect := 1;
      ELSE
        -- Apenas inclui os comandos no arquivo
        vr_flgexect := 0;
      END IF;
  
      -- Criar e executar script para geracao e impressao de formularios FormPrint
      FORM0001.pc_gera_formprint(pr_nmscript => vr_nmscript
                                ,pr_dsformsk => 'laser/crrl351.lfm'
                                ,pr_nmarqdat => vr_nmdatspt
                                ,pr_nmarqimp => vr_nmimpspt
                                ,pr_dsdestin => vr_dsdireto||'/'
                                ,pr_dssubarq => 'arq/'
                                ,pr_dssubrel => 'rl/'
                                ,pr_nmforimp => 'Extrato-trimapl'
                                ,pr_flgexect => vr_flgexect
                                ,pr_des_erro => vr_dscritic);
  
      -- Se ocorrer erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Atualiza o contador de arquivos
      vr_nrarquiv := vr_nrarquiv - 1;
      
    END LOOP;
      
  ELSE
    -- Remove possíveis arquivos antigos do diretório
    gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdireto||vr_nmarqdat||'* 2> /dev/null'
                               ,pr_typ_saida   => vr_typ_said
                               ,pr_des_saida   => vr_dscritic);
      
    -- Testar erro
    IF vr_typ_said = 'ERR' THEN
      -- Adicionar o erro na variavel de erros
      vr_dscritic := 'Erro ao excluir arquivos dat --> '||vr_dscritic;
      RAISE vr_exc_saida;    
    END IF;
 
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
END PC_CRPS392;
/
