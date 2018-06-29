CREATE OR REPLACE PROCEDURE CECRED.pc_crps534 (
                                   pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                  ,pr_nmtelant IN VARCHAR2                --> Nome da tela
                                  ,pr_flgresta IN PLS_INTEGER             --> Flag padr�o para utiliza��o de restart
                                  ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                  ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                  ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

  /* ..........................................................................

   Programa: PC_CRPS534                  Antigo: Fontes/crps534.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Dezembro/2009.                  Ultima atualizacao: 05/01/2018
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 1.
               Integrar arquivos de DOC's/Depositos - Sua Remessa.
               Emite relatorio 527.

   Alteracoes: 31/05/2010 - Permitir que o programa rode diferenciadamente para
                            coop 3, lendo todos os arquivos 3*.RET, importar os
                            dados e gerar um relatorio. Quando for outra coop,
                            continuar o funcionamento atual (Guilherme/Supero)

               10/06/2010 - Exibir as informacoes dos DOCs Integrados (Ze).

               16/06/2010 - Acertos Gerais (Ze).

               06/07/2010 - Incluso Validacao para COMPEFORA (Jonatas/Supero)

               13/09/2010 - Acerto p/ gerar relatorio no diretorio rlnsv
                            (Vitor)

               13/12/2010 - Inclusao de Transferencia de PAC quando coop 2
                            (Guilherme/Supero)

               10/01/2011 - Alteracao do total do rel. 526_99 (Ze).

               18/01/2011 - Incluido os e-mails:
                            - fabiano@viacredi.coop.br
                            - moraes@viacredi.coop.br
                            (Adriano).

               24/02/2011 - Alterado layout do reatorio crrl563 (Henrique).

               07/04/2011 - Quando tipo de doc 2 e campo 105,2 igual a 50
                            criticar o cpf/cnpj (Magui).

               03/06/2011 - Alterado destinat�rio do envio de email na procedure
                            gera_relatorio_203_99;
                            De: thiago.delfes@viacredi.coop.br
                            Para: brusque@viacredi.coop.br. (Fabricio)

               19/10/2011 - Corrigir FORMAT para campo nrdocmto (David).

               21/12/2011 - Corrigido warnings (Tiago).

               18/06/2012 - Alteracao na leitura da craptco (David Kruger).

               04/07/2012 - Retirado email fabiano@viacredi.com.br do
                            recebimento do relat�rio (Guilherme Maba).

               24/10/2012 - Layout do relatorio de rejeitados campo conta de
                            8 para 13 posi��es - rel 527 (Tiago/ZE).

               03/01/2013 - Adaptacao da Migracao AltoVale (Ze).

               18/02/2013 - Zerar variavel glb_cdcritic - Trf. 44680 (Ze).

               28/08/2013 - Nova forma de chamar as ag�ncias, de PAC agora
                            a escrita ser� PA (Andr� Euz�bio - Supero).

               10/09/2013 - Incluida critica 64(conta encerrada) (Diego).

               23/10/2013 - Correcao critica 64-tratar conta migrada (Diego).

               13/11/2013 - Tratamento para Migracao para Viacredi (Ze).

               20/01/2014 - Convers�o Progress >> Oracle PL/SQL ( Renato - Supero)
               
               21/03/2014 - Ajustes nas grava��es da craprej devido estouro ao inserir
                            o campo nrctaint pois a maskara no oracle mantem os espa�os
                            (Marcos-Supero)
                            
               06/05/2014 - Criada variavel vr_nrlottco para manter o numero do lote
                            na procedure pc_processamento_tco. (Reinert)
               
               13/05/2014 - Ajuste no tratamento de leitura de arquivos vazios (Odirlei-Amcom)
               
               19/06/2014 - Cria nova procedure pc_cria_ddc para gravacao
                            de devolucao DOC da Compensacao - Projeto
                            automatiza compe (Tiago/Aline)
                            
               22/09/2014 - Incluir tratamentos para incorpora��o Concredi pela Via
                            e Credimilsul pela SCRCred (Marcos-Supero)             
               
               02/12/2014 - Ajustar controle de alertas quando a integra��o com ou sem 
                            rejeitados, al�m de remo��o da mensagem duplicada quando 
                            ocorre a montagem do relat�rio _999 (Marcos-Supero)

               31/08/2015 - Projeto para tratamento dos programas que geram 
                            criticas que necessitam de lancamentos manuais 
                            pela contabilidade. (Jaison/Marcos-Supero)

               31/08/2016 - Adicionar valida��o para o campo de CPF recebido no arquivo ser
                            diferente do CPF do titular da conta (Douglas - Chamado 476269)

               06/10/2016 - Ajuste na leitura do CPF do destintario quando processar a linha
                            do arquivo (Douglas - Chamado 533206)

               10/10/2016 - Altera��o do diret�rio para gera��o de arquivo cont�bil.
                            P308 (Ricardo Linhares).

               02/12/2016 - Incorpora��o Transulcred (Guilherme/SUPERO)

               24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
                            crapass, crapttl, crapjur 
                           (Adriano - P339).

               01/09/2017 - SD737676 - Para evitar duplicidade devido o Matera mudar
                            o nome do arquivo apos processamento, iremos gerar o arquivo
                            _Criticas com o sufixo do crrl gerado por este (Marcos-Supero)

               20/11/2017 - Inclus�o padr�o pc_set_modulo
                            (Setar o par�metro pr_module = CRPS594.nome_procedures e pr_action = NULL)
                          - Inclus�o da chamada de procedure em exception others
                          - Colocado logs no padr�o
                          - Padroniza��o mensagens insert/update/delete
                            (Ana - Envolti - Chamado 789851)
                            
               05/01/2018 - Corrigido data usada no cursor dos registros rejeitados para 
                            que tanto no processo quanto na compefora sejam buscados os registros
                            corretamente
                            (Adriano - SD 825150).
				
			   23/01/2018 - A Incorpora��o Transulcred, feita em 02/12/2016 por Guilherme - SUPERO 
							foi sobrescrita. O c�digo foi recuperado nesta vers�o para que as DOCs 
							incorporadas da Transulcred voltem a ser executadas. 
							(Gabriel - Mouts - Chamado 765829)                              
  ............................................................................ */


  ------------------------------- CURSORES ---------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT cop.cdcooper
         , cop.nmrescop
         , cop.cdagectl
         , cop.cdbcoctl
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;

  -- Buscar informa��es da tabela gen�rica
  CURSOR cr_craptab(pr_nmsistem  craptab.nmsistem%TYPE
                   ,pr_tptabela  craptab.tptabela%TYPE
                   ,pr_cdempres  craptab.cdempres%TYPE
                   ,pr_cdacesso  craptab.cdacesso%TYPE
                   ,pr_tpregist  craptab.tpregist%TYPE) IS
    SELECT craptab.dstextab
      FROM craptab
     WHERE craptab.cdcooper = pr_cdcooper
       AND craptab.nmsistem = pr_nmsistem
       AND craptab.tptabela = pr_tptabela
       AND craptab.cdempres = pr_cdempres
       AND craptab.cdacesso = pr_cdacesso
       AND craptab.tpregist = pr_tpregist;

  -- Buscar o registro da CRAPLOT
  CURSOR cr_craplot(pr_cdcooper   craplot.cdcooper%TYPE
                   ,pr_dtmvtolt   craplot.dtmvtolt%TYPE
                   ,pr_cdagenci   craplot.cdagenci%TYPE
                   ,pr_cdbccxlt   craplot.cdbccxlt%TYPE
                   ,pr_nrdolote   craplot.nrdolote%TYPE  ) IS
    SELECT craplot.rowid dsrowid
         , craplot.dtmvtolt
         , craplot.cdagenci
         , craplot.cdbccxlt
         , craplot.nrdolote
      FROM craplot
     WHERE craplot.cdcooper = pr_cdcooper
       AND craplot.dtmvtolt = pr_dtmvtolt
       AND craplot.cdagenci = pr_cdagenci
       AND craplot.cdbccxlt = pr_cdbccxlt
       AND craplot.nrdolote = pr_nrdolote;

  -- Buscar lan�amentos em depositos a vista
  CURSOR cr_craplcm(pr_cdcooper  craplcm.cdcooper%TYPE
                   ,pr_dtmvtolt  craplcm.dtmvtolt%TYPE
                   ,pr_cdagenci  craplcm.cdagenci%TYPE
                   ,pr_cdbccxlt  craplcm.cdbccxlt%TYPE
                   ,pr_nrdolote  craplcm.nrdolote%TYPE
                   ,pr_nrdconta  craplcm.nrdctabb%TYPE
                   ,pr_nrdocmto  craplcm.nrdocmto%TYPE) IS
    SELECT 1
      FROM craplcm
     WHERE craplcm.cdcooper = pr_cdcooper
       AND craplcm.dtmvtolt = pr_dtmvtolt
       AND craplcm.cdagenci = pr_cdagenci
       AND craplcm.cdbccxlt = pr_cdbccxlt
       AND craplcm.nrdolote = pr_nrdolote
       AND craplcm.nrdctabb = pr_nrdconta
       AND craplcm.nrdocmto = pr_nrdocmto;

  --------------------------------- TIPOS ---------------------------------
  TYPE typ_rcdoctco IS RECORD (cdcooper NUMBER
                              ,nrdconta NUMBER
                              ,nrdctabb NUMBER
                              ,cdagenci NUMBER
                              ,cdbccxlt NUMBER
                              ,tplotmov NUMBER
                              ,nrdocmto NUMBER
                              ,cdbandoc NUMBER
                              ,nrlotdoc NUMBER
                              ,sqlotdoc NUMBER
                              ,cdcmpdoc NUMBER
                              ,cdagedoc NUMBER
                              ,nrctadoc NUMBER
                              ,cdhistor NUMBER
                              ,vllanmto NUMBER
                              ,nrseqarq NUMBER
                              ,cdpesqbb VARCHAR2(4000)
                              ,cdbandep NUMBER
                              ,cdcmpdep NUMBER
                              ,cdagedep NUMBER
                              ,nrctadep NUMBER
                              ,cdbccrcb NUMBER
                              ,cdagercb NUMBER
                              ,dvagenci VARCHAR2(1)
                              ,nrcctrcb NUMBER
                              ,tpdctacr NUMBER
                              ,cdfinrcb NUMBER
                              ,nmpesemi VARCHAR2(40)
                              ,cpfcgemi NUMBER
                              ,tpdctadb NUMBER
                              ,tpdoctrf VARCHAR2(1)
                              ,nmdestin VARCHAR2(40)
                              ,cpfdesti NUMBER);
  TYPE typ_tbdoctco IS TABLE OF typ_rcdoctco INDEX BY BINARY_INTEGER;

  ------------------------------- REGISTROS -------------------------------
  rw_tbdoctco       typ_tbdoctco;
  rw_crapcop        cr_crapcop%ROWTYPE;
  rw_crapcop_incorp cr_crapcop%ROWTYPE;
  rw_craplot        cr_craplot%ROWTYPE;

  ------------------------------- VARIAVEIS -------------------------------
  -- C�digo do programa
  vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS534';
  -- Data de movimento, m�s de referencia e demais datas de controle
  vr_dtmvtolt     DATE;
  vr_dtmvtoan     DATE;
  vr_dtleiarq     DATE;
  vr_dtauxili     VARCHAR2(8);
  -- Valor tabela gen�rica
  vr_dstextab     craptab.dstextab%TYPE;
  -- Vari�veis de dados gerais do programa
  vr_nrdconta        crapass.nrdconta%TYPE;
  vr_cdagearq        crapddc.cdagenci%TYPE;
  vr_nrcpfemi        crapddc.nrcpfemi%TYPE;
  vr_cpfremet        NUMBER;
  vr_cpfdesti        NUMBER;
  vr_tpdedocs        NUMBER;
  vr_nrctaint        VARCHAR2(20);
  vr_nrdocmto        craprej.nrdocmto%TYPE;
  vr_nrseqarq        craprej.nrseqdig%TYPE;
  vr_cdpesqbb        craprej.cdpesqbb%TYPE;
  vr_vllanmto        craprej.vllanmto%TYPE;
  vr_nrdolote        NUMBER;
  vr_dshistor        craprej.dshistor%TYPE;
  vr_indebcre        craprej.indebcre%TYPE;
  vr_cdagenci        NUMBER := 1;
  vr_tplotmov        NUMBER := 1;
  vr_cdcmpori        crapddc.cdcmpori%TYPE;
  vr_nrdconta_incorp crapass.nrdconta%TYPE;
  --
  vr_tpdsdocs     VARCHAR2(1);
  vr_dsrelcpf     VARCHAR2(20);
  vr_dsdrowid     VARCHAR2(50);
  --
  vr_nrdcont2     NUMBER;

  vr_cdbccrcb     NUMBER;
  vr_cdagercb     NUMBER;
  --
  vr_vltotreg     NUMBER;
  --
  vr_nrdummy      NUMBER; -- Vari�vel number auxiliar
  --
  vr_cdpeslcm     craplcm.cdpesqbb%TYPE;
  vr_nmdestin     craprej.dshistor%TYPE;
  vr_cdbandoc     craplcm.cdbanchq%TYPE;
  vr_cdcmpdoc     craplcm.cdcmpchq%TYPE;
  vr_cdagedoc     craplcm.cdagechq%TYPE;
  vr_nrctadoc     craplcm.nrctachq%TYPE;
  vr_cdhistor     NUMBER;
  vr_critiass     NUMBER;
  vr_dsselect     VARCHAR2(2000);
  vr_cursor       SYS_REFCURSOR; -- Cursor dinamico
  -- Informa��es de arquivos e relat�rios
  vr_nmsubint        CONSTANT VARCHAR2(10) := 'integra/';
  vr_nmsubrel        CONSTANT VARCHAR2(10) := 'rl/';
  vr_nmarquiv        VARCHAR2(100);
  vr_nmarquiv_incorp VARCHAR2(100);
  vr_dsdireto        VARCHAR2(100);
  vr_dsdirarq        VARCHAR2(200);
  vr_dsdirrel        VARCHAR2(200);
  vr_listaarq        VARCHAR2(30000);
  vr_listaarq_incorp VARCHAR2(30000); 
  vr_tbarquiv        GENE0002.typ_split := GENE0002.typ_split();
  vr_indchave        VARCHAR2(100);
  -- Rolbacks para erros, ignorar o resto do processo e rollback
  -- Tratamento de erros
  vr_typ_saida    VARCHAR2(100);
  vr_des_saida    VARCHAR2(2000);
  vr_exc_fimprg   EXCEPTION;
  vr_exc_saida    EXCEPTION;
  vr_cdcritic     PLS_INTEGER;
  vr_dscritic     VARCHAR2(4000);
  vr_dsobserv     VARCHAR2(100);
  vr_nrcpfstl     crapttl.nrcpfcgc%TYPE;
  vr_nrcpfttl     crapttl.nrcpfcgc%TYPE;
  
  -- vari�veis para controle de arquivos
   vr_dircon VARCHAR2(200);
   vr_arqcon VARCHAR2(200);
   vc_dircon CONSTANT VARCHAR2(30) := 'arquivos_contabeis/ayllos'; 
   vc_cdacesso CONSTANT VARCHAR2(24) := 'ROOT_SISTEMAS';
   vc_cdtodascooperativas INTEGER := 0;        
  
  --------------------------- ROTINAS INTERNAS ----------------------------

  --> Controla log proc_batch, atualizando par�metros conforme tipo de ocorr�ncia
  PROCEDURE pc_gera_log(pr_cdcooper_in   IN crapcop.cdcooper%TYPE,
                        pr_dstiplog      IN VARCHAR2, -- 'I' in�cio; 'F' fim; 'E' erro
                        pr_dscritic      IN VARCHAR2 DEFAULT NULL,
                        pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 0,
                        pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%type DEFAULT 0,
                        pr_ind_tipo_log  IN tbgen_prglog_ocorrencia.tpocorrencia%type DEFAULT 2) IS

    -----------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_log
    --  Sistema  : Rotina para gravar logs em tabelas
    --  Sigla    : CRED
    --  Autor    : Ana L�cia E. Volles - Envolti
    --  Data     : Novembro/2017           Ultima atualizacao: 20/11/2017
    --  Chamado  : 789851
    --
    -- Dados referentes ao programa:
    -- Frequencia: Rotina executada em qualquer frequencia.
    -- Objetivo  : Controla grava��o de log em tabelas.
    --
    -- Alteracoes:  
    --             
    ------------------------------------------------------------------------------------------------------------   
  BEGIN     
    --> Controlar gera��o de log de execu��o dos jobs
    --Como executa na cadeira, utiliza pc_gera_log_batch
    btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper                      
                              ,pr_ind_tipo_log  => pr_ind_tipo_log
                              ,pr_nmarqlog      => 'proc_batch.log'                 
                              ,pr_dstiplog      => NVL(pr_dstiplog,'E')             
                              ,pr_cdprograma    => vr_cdprogra                      
                              ,pr_tpexecucao    => 1 -- batch                       
                              ,pr_cdcriticidade => pr_cdcriticidade                      
                              ,pr_cdmensagem    => pr_cdmensagem                      
                              ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - ' 
                                                  || vr_cdprogra || ' --> '|| pr_dscritic);
  EXCEPTION  
    WHEN OTHERS THEN  
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
  END pc_gera_log;
  
  -- Fun��o para verificar o indebcre conforme o tipo de documento
  FUNCTION fn_tipo_documento(pr_tpdedocs IN NUMBER) RETURN VARCHAR2 IS

  BEGIN
    -- Verificar indicador conforme o tipo de documento
    IF    pr_tpdedocs = 2 THEN
      RETURN 'A';
    ELSIF pr_tpdedocs = 3 THEN
      RETURN 'B';
    ELSIF pr_tpdedocs = 4 THEN
      RETURN 'C';
    ELSIF pr_tpdedocs = 5 THEN
      RETURN 'D';
    ELSIF pr_tpdedocs = 6 THEN
      RETURN 'E';
    ELSE
      RETURN to_char(pr_tpdedocs);
    END IF;
  END fn_tipo_documento;
  
  -- Procedure para verificar conta integrada
  PROCEDURE pc_verifica_conta_integra(pr_out_fgeratco OUT BOOLEAN
                                     ,pr_out_inctaint OUT BOOLEAN
                                     ,pr_out_cdcooper OUT NUMBER
                                     ,pr_out_nrdconta OUT NUMBER)  IS

    -- Cursores
    CURSOR cr_craptco IS
      SELECT craptco.cdcooper
           , craptco.nrdconta
        FROM craptco
       WHERE craptco.cdcopant = pr_cdcooper
         AND craptco.nrctaant = vr_nrdconta
         AND craptco.tpctatrf = 1
         AND craptco.flgativo = 1; -- TRUE.

    CURSOR cr_crapass (pr_cdcooper IN NUMBER
                      ,pr_nrdconta IN NUMBER) IS
      SELECT ass.cdcooper
           , ass.nrdconta
           , ass.nrcpfcgc
           , ass.inpessoa         
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_ass cr_crapass%ROWTYPE;

	CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
	                 ,pr_nrdconta IN crapttl.nrdconta%TYPE
					 ,pr_idseqttl IN crapttl.idseqttl%TYPE) IS
  SELECT crapttl.nrcpfcgc
    FROM crapttl
	 WHERE crapttl.cdcooper = pr_cdcooper
	   AND crapttl.nrdconta = pr_nrdconta
	   AND crapttl.idseqttl = pr_idseqttl;
  	rw_crapttl cr_crapttl%ROWTYPE;

    vr_cdcrirej NUMBER;

  BEGIN

    -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_verifica_conta_integra', pr_action => NULL);

    -- Verifica se a cooperativa � a 1 ou a 2
    IF pr_cdcooper IN (1,2) THEN

      -- Buscar por contas transferidas entre cooperativas
      OPEN  cr_craptco;
      FETCH cr_craptco INTO pr_out_cdcooper
                          , pr_out_nrdconta;
      -- Verificar se foram retornado registros
      IF cr_craptco%FOUND THEN

        -- Validar o CPF da conta
        OPEN cr_crapass (pr_cdcooper => pr_out_cdcooper
                        ,pr_nrdconta => pr_out_nrdconta);
        FETCH cr_crapass INTO rw_ass;
        CLOSE cr_crapass;
        
        vr_nrcpfstl := 0;
        vr_nrcpfttl := 0;

        IF rw_ass.inpessoa = 1 THEN

          OPEN cr_crapttl(pr_cdcooper => rw_ass.cdcooper
                         ,pr_nrdconta => rw_ass.nrdconta
                         ,pr_idseqttl => 2);

          FETCH cr_crapttl INTO rw_crapttl;

          IF cr_crapttl%FOUND THEN

            vr_nrcpfstl := rw_crapttl.nrcpfcgc;

          END IF;

          CLOSE cr_crapttl;

          OPEN cr_crapttl(pr_cdcooper => rw_ass.cdcooper
                         ,pr_nrdconta => rw_ass.nrdconta
                 ,pr_idseqttl => 3);

          FETCH cr_crapttl INTO rw_crapttl;

          IF cr_crapttl%FOUND THEN

            vr_nrcpfttl := rw_crapttl.nrcpfcgc;

          END IF;

          CLOSE cr_crapttl;

        END IF;
            
        -- Verifica o cpf
        IF NOT ((vr_cpfdesti = rw_ass.nrcpfcgc)   OR
                (vr_cpfdesti = vr_nrcpfstl)     OR
                (vr_cpfdesti = vr_nrcpfttl))    THEN

          vr_cdcrirej := 301; -- 301 - DADOS NAO CONFEREM!                
          vr_dshistor := RPAD(vr_nmdestin,40,' ')||
                         'CPF Remetente '|| vr_cpfremet ||
                         ' CPF Destinatario '|| vr_cpfdesti;
          -- Se o CPF est� incorreto nao cria o lancamento da TCO
          pr_out_fgeratco := FALSE;
        ELSE
          vr_cdcrirej := 999;
          vr_dshistor := vr_nmdestin;
          -- Se o CPF pertence ao titular lancao o valor da TCO
          pr_out_fgeratco := TRUE;
        END IF;

        -- Verificar indicador conforme o tipo de documento
        vr_indebcre := fn_tipo_documento(vr_tpdedocs);

        BEGIN
          -- Insere o registro na CRAPREJ
          INSERT INTO craprej(cdcritic
                             ,nrdconta
                             ,vllanmto
                             ,cdpesqbb
                             ,dshistor
                             ,nrseqdig
                             ,nrdocmto
                             ,indebcre
                             ,dtrefere
                             ,vldaviso
                             ,cdcooper
                             ,nrdctitg)
                      VALUES (vr_cdcrirej -- cdcritic
                             ,vr_nrdconta -- nrdconta
                             ,vr_vllanmto -- vllanmto
                             ,vr_cdpesqbb -- cdpesqbb
                             ,vr_dshistor -- dshistor
                             ,vr_nrseqarq -- nrseqdig
                             ,vr_nrdocmto -- nrdocmto
                             ,vr_indebcre -- indebcre
                             ,vr_dtauxili -- dtrefere
                             ,vr_dsrelcpf -- vldaviso
                             ,pr_cdcooper -- cdcooper
                             ,LTRIM(GENE0002.fn_mask(TO_NUMBER(vr_nrctaint),'zzzzzz.zzz.zzz.z'))); -- nrdctitg
        EXCEPTION
          WHEN OTHERS THEN
            -- Cr�tica: Erro Oracle
            vr_cdcritic := 1034;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                           ' craprej[1]: cdcritic:' || vr_cdcrirej ||
                           ', nrdconta:' || vr_nrdconta || ', vllanmto:' || vr_vllanmto ||
                           ', cdpesqbb:' || vr_cdpesqbb || ', dshistor:' || vr_dshistor ||
                           ', nrseqdig:' || vr_nrseqarq || ', nrdocmto:' || vr_nrdocmto ||
                           ', indebcre:' || vr_indebcre || ', dtrefere:' || vr_dtauxili ||
                           ', vldaviso:' || vr_dsrelcpf || ', cdcooper:' || pr_cdcooper ||
                           ', nrdctitg:' ||LTRIM(TO_NUMBER(vr_nrctaint)) ||
                           '. '|| sqlerrm;
          -- Envio centralizado de log de erro
          pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic,
                      pr_cdcriticidade => 2,
                      pr_cdmensagem    => vr_cdcritic,
                      pr_ind_tipo_log  => 3);

          --Inclus�o na tabela de erros Oracle - Chamado 789851
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        END;
            
        -- Se o CPF pertence ao titular lancao o valor da TCO
        pr_out_inctaint := TRUE;          
      ELSE
        -- Retorno
        pr_out_inctaint := FALSE;
        pr_out_fgeratco := FALSE;
      END IF; -- cr_craptco%FOUND
    ELSE
      pr_out_inctaint := FALSE;
      pr_out_fgeratco := FALSE;
    END IF; --pr_cdcooper IN (1,2)

  END pc_verifica_conta_integra;

  -- Procedure para gravar devolucao DOC da Compensacao
  PROCEDURE pc_cria_ddc(pr_cdcooper IN  crapddc.cdcooper%TYPE -->cooperativa
                       ,pr_cdagenci IN  crapddc.cdagenci%TYPE -->PA
                       ,pr_nrdocmto IN  crapddc.nrdocmto%TYPE -->Numero Doc.                       
                       ,pr_vldocmto IN  crapddc.vldocmto%TYPE -->Valor documento
                       ,pr_nrdconta IN  crapddc.nrdconta%TYPE -->Numero da conta
                       ,pr_nmfavore IN  crapddc.nmfavore%TYPE -->Nome favorecido
                       ,pr_nrcpffav IN  crapddc.nrcpffav%TYPE -->Nro cpf favorecido
                       ,pr_cdcritic IN  crapddc.cdcritic%TYPE -->Codigo critica
                       ,pr_cdbandoc IN  crapddc.cdbandoc%TYPE -->Codigo banco
                       ,pr_cdagedoc IN  crapddc.cdagedoc%TYPE -->Agencia banco
                       ,pr_nrctadoc IN  crapddc.nrctadoc%TYPE -->Nro conta banco
                       ,pr_nmemiten IN  crapddc.nmemiten%TYPE -->Nome emitente
                       ,pr_nrcpfemi IN  crapddc.nrcpfemi%TYPE -->Nro cpf emitente
                       ,pr_dslayout IN  crapddc.dslayout%TYPE -->layout do arq
                       ,pr_cdcmpori IN  crapddc.cdcmpori%TYPE --> Compe origem
                       ,pr_dsdrowid OUT VARCHAR2) IS  --> retorna o Rowid do registro inserido
    vr_dslayout VARCHAR2(255);   
    vr_dtmvtaux crapdat.dtmvtolt%TYPE;

  BEGIN   
    -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_cria_ddc', pr_action => NULL);

    vr_dslayout := substr(pr_dslayout, 1, 238);
    
    IF pr_cdcooper = 3 THEN
       vr_dslayout := vr_dslayout || '53';
    ELSE
       vr_dslayout := vr_dslayout || '57';
    END IF;

    vr_dslayout := vr_dslayout || substr(pr_dslayout, 241, 14);
    
    -->Formatar data  
    vr_dtmvtaux := to_date(SUBSTR(vr_dslayout,219,2)||SUBSTR(vr_dslayout,221,2)||SUBSTR(vr_dslayout,215,4),'mmddrrrr');

    BEGIN
      /*Inserir dados na crapddc*/
      INSERT INTO crapddc(cdcooper
                         ,cdagenci
                         ,nrdocmto
                         ,dtmvtolt
                         ,vldocmto                       
                         ,nrdconta
                         ,nmfavore
                         ,nrcpffav
                         ,cdcritic
                         ,cdbandoc
                         ,cdagedoc
                         ,nrctadoc
                         ,nmemiten
                         ,nrcpfemi
                         ,cdmotdev
                         ,flgdevol
                         ,cdoperad
                         ,dslayout
                         ,flgpcctl
                         ,cdcmpori)
                   VALUES(pr_cdcooper --> cdcooper
                         ,pr_cdagenci --> cdagenci
                         ,pr_nrdocmto --> nrdocmto
                         ,vr_dtmvtaux --> dtmvtolt
                         ,pr_vldocmto --> vldocmto
                         ,pr_nrdconta --> nrdconta
                         ,pr_nmfavore --> nmfavore
                         ,pr_nrcpffav --> nrcpffav
                         ,pr_cdcritic --> cdcritic
                         ,pr_cdbandoc --> cdbandoc
                         ,pr_cdagedoc --> cdagedoc
                         ,pr_nrctadoc --> nrctadoc
                         ,pr_nmemiten --> nmemiten
                         ,pr_nrcpfemi --> nrcpfemi
                         ,DECODE(pr_cdcooper,3,53,57) --> cdmotdev
                         ,1             --> flgdevol
                         ,'1'           --> cdoperad
                         ,SUBSTR(vr_dslayout,1,255) --> dslayout
                         ,0 --> flgpcctl
                         ,pr_cdcmpori) --> cdcmpori 
           RETURNING ROWID INTO pr_dsdrowid;
    EXCEPTION
      WHEN OTHERS THEN
        -- Cr�tica: Erro Oracle
        vr_cdcritic := 1034;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                       ' crapddc: cdcooper:' || pr_cdcooper ||
                       ', cdagenci:' || pr_cdagenci ||', nrdocmto:' || pr_nrdocmto ||
                       ', dtmvtolt:' || vr_dtmvtaux ||', vldocmto:' || pr_vldocmto ||
                       ', nrdconta:' || pr_nrdconta ||', nmfavore:' || trim(pr_nmfavore) ||
                       ', nrcpffav:' || pr_nrcpffav ||', cdcritic:' || pr_cdcritic ||
                       ', cdbandoc:' || pr_cdbandoc ||', cdagedoc:' || pr_cdagedoc ||
                       ', nrctadoc:' || pr_nrctadoc ||', nmemiten:' || trim(pr_nmemiten) ||
                       ', nrcpfemi:' || pr_nrcpfemi ||', cdmotdev: se cdcooper=3 -> 53, sen�o -> 57' ||
                       ', flgdevol:1, cdoperad:1, dslayout:' || SUBSTR(vr_dslayout,1,255) ||
                       ', flgpcctl:0, cdcmpori:'    || pr_cdcmpori || ', pr_dsdrowid:' || pr_dsdrowid
                       ||'. '|| sqlerrm;
        -- Envio centralizado de log de erro
        pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => vr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => vr_cdcritic,
                    pr_ind_tipo_log  => 3);

        --Inclus�o na tabela de erros Oracle - Chamado 789851
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

    END;

  END pc_cria_ddc;

  -- Cria o registro na tabela gen�rica GNCPDOC - Compensacao Documentos da Central
  PROCEDURE pc_cria_generico(pr_cdcritic IN gncpdoc.cdcritic%TYPE
                            ,pr_cdagenci IN gncpdoc.cdagenci%TYPE
                            ,pr_nmarquiv IN gncpdoc.nmarquiv%TYPE
                            ,pr_cdagectl IN crapcop.cdagectl%TYPE
                            ,pr_nrdconta IN crapass.nrdconta%TYPE
                            ,pr_dslinha  IN VARCHAR2 ) IS

  BEGIN
    -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_cria_generico', pr_action => NULL);

    /* CRIA��O DA TABELA GEN�RICA - GNCPDOC */
    INSERT INTO gncpdoc(cdcooper
                       ,cdagenci
                       ,dtmvtolt
                       ,dtliquid
                       ,cdcmpchq
                       ,cdbccrcb
                       ,cdagercb
                       ,dvagenci
                       ,nrcctrcb
                       ,nrdocmto
                       ,vldocmto
                       ,nmpesrcb
                       ,cpfcgrcb
                       ,tpdctacr
                       ,cdfinrcb
                       ,cdagectl
                       ,nrdconta
                       ,nmpesemi
                       ,cpfcgemi
                       ,tpdctadb
                       ,tpdoctrf
                       ,qtdregen
                       ,nmarquiv
                       ,cdoperad
                       ,hrtransa
                       ,cdtipreg
                       ,flgconci
                       ,flgpcctl
                       ,nrseqarq
                       ,cdcritic
                       ,cdmotdev)
                 VALUES(pr_cdcooper                         -- cdcooper
                       ,pr_cdagenci                         -- cdagenci
                       ,vr_dtleiarq                         -- dtmvtolt
                       ,vr_dtmvtolt                         -- dtliquid
                       ,vr_cdcmpdoc                         -- cdcmpchq
                       ,to_number(SUBSTR(pr_dslinha,4,3))   -- cdbccrcb
                       ,to_number(SUBSTR(pr_dslinha,7,4))   -- cdagercb
                       ,SUBSTR(pr_dslinha,11,1)             -- dvagenci
                       ,to_number(SUBSTR(pr_dslinha,12,13)) -- nrcctrcb
                       ,vr_nrdocmto                         -- nrdocmto
                       ,vr_vllanmto                         -- vldocmto
                       ,vr_nmdestin                         -- nmpesrcb
                       ,to_number(vr_dsrelcpf)              -- cpfcgrcb
                       ,to_number(SUBSTR(pr_dslinha,103,2)) -- tpdctacr
                       ,to_number(SUBSTR(pr_dslinha,105,2)) -- cdfinrcb
                       ,pr_cdagectl                         -- cdagectl
                       ,pr_nrdconta                         -- nrdconta
                       ,SUBSTR(pr_dslinha,142,40)           -- nmpesemi
                       ,to_number(SUBSTR(pr_dslinha,182,14))-- cpfcgemi
                       ,to_number(SUBSTR(pr_dslinha,196,2)) -- tpdctadb
                       ,SUBSTR(pr_dslinha,203,1)            -- tpdoctrf
                       ,vr_vltotreg                         -- qtdregen
                       ,pr_nmarquiv                         -- nmarquiv
                       ,'1'                                 -- cdoperad
                       ,GENE0002.fn_busca_time              -- hrtransa
                       ,decode(pr_cdcritic,0, 4, 3)         -- cdtipreg
                       ,0                                   -- flgconci
                       ,0                                   -- flgpcctl
                       ,vr_nrseqarq                         -- nrseqarq
                       ,pr_cdcritic                         -- cdcritic
                       ,0);                                 -- cdmotdev
  EXCEPTION
    WHEN OTHERS THEN
      -- Cr�tica: Erro Oracle
      vr_cdcritic := 1034;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' gncpdoc[1]: cdcooper:' || pr_cdcooper ||
                     ', cdagenci:' || pr_cdagenci ||', dtmvtolt:' || vr_dtleiarq ||
                     ', dtliquid:' || vr_dtmvtolt ||', cdcmpchq:' || vr_cdcmpdoc ||
                     ', cdbccrcb:' || to_number(SUBSTR(pr_dslinha,4,3))          ||
                     ', cdagercb:' || to_number(SUBSTR(pr_dslinha,7,4))          ||
                     ', dvagenci:' || SUBSTR(pr_dslinha,11,1)                    ||
                     ', nrcctrcb:' || to_number(SUBSTR(pr_dslinha,12,13))        ||
                     ', nrdocmto:' || vr_nrdocmto ||', vldocmto:' || vr_vllanmto ||
                     ', nmpesrcb:' || vr_nmdestin  ||', cpfcgrcb:' || to_number(vr_dsrelcpf) ||
                     ', tpdctacr:' || to_number(SUBSTR(pr_dslinha,103,2))         ||
                     ', cdfinrcb:' || to_number(SUBSTR(pr_dslinha,105,2))         ||
                     ', cdagectl:' || pr_cdagectl  ||', nrdconta:' || pr_nrdconta ||
                     ', nmpesemi:' || SUBSTR(pr_dslinha,142,40)                   ||
                     ', cpfcgemi:' || to_number(SUBSTR(pr_dslinha,182,14))        ||
                     ', tpdctadb:' || to_number(SUBSTR(pr_dslinha,196,2))         ||
                     ', tpdoctrf:' || SUBSTR(pr_dslinha,203,1)                    ||
                     ', qtdregen:' || vr_vltotreg  ||', nmarquiv:' || pr_nmarquiv ||
                     ', cdoperad:1, hrtransa:'     || GENE0002.fn_busca_time      ||
                     ', cdtipreg: se cdcritic=0 -> 4, senao -> 3,'                ||
                     ', flgconci:0, flgpcctl:0'    ||', nrseqarq:' || vr_nrseqarq ||
                     ', cdcritic:' || pr_cdcritic  ||', cdmotdev:0. '|| sqlerrm;
      -- Envio centralizado de log de erro
      pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => vr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => vr_cdcritic,
                  pr_ind_tipo_log  => 3);

      --Inclus�o na tabela de erros Oracle - Chamado 789851
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

  END pc_cria_generico;
  
  -- Cria o registro na tabela gen�rica GNCPDOC - Compensacao Documentos da Central
  PROCEDURE pc_cria_generico_tco(pr_cdcritic IN gncpdoc.cdcritic%TYPE
                                ,pr_nmarquiv IN gncpdoc.nmarquiv%TYPE
                                ,pr_rcdoctco IN typ_rcdoctco ) IS

  BEGIN
    -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_cria_generico_tco', pr_action => NULL);

    /* CRIA��O DA TABELA GEN�RICA - GNCPDOC */
    INSERT INTO gncpdoc(cdcooper
                       ,cdagenci
                       ,dtmvtolt
                       ,dtliquid
                       ,cdagectl
                       ,nrdconta
                       ,cdcmpchq
                       ,cdbccrcb
                       ,cdagercb
                       ,dvagenci
                       ,nrcctrcb
                       ,nrdocmto
                       ,vldocmto
                       ,nmpesrcb
                       ,cpfcgrcb
                       ,tpdctacr
                       ,cdfinrcb
                       ,nmpesemi
                       ,cpfcgemi
                       ,tpdctadb
                       ,tpdoctrf
                       ,qtdregen
                       ,nmarquiv
                       ,nrseqarq
                       ,cdoperad
                       ,hrtransa
                       ,cdtipreg
                       ,flgconci
                       ,flgpcctl
                       ,cdcritic
                       ,cdmotdev)
                 VALUES(pr_rcdoctco.cdcooper   -- cdcooper
                       ,pr_rcdoctco.cdagenci   -- cdagenci
                       ,vr_dtleiarq            -- dtmvtolt
                       ,vr_dtmvtolt            -- dtliquid
                       ,rw_crapcop.cdagectl    -- cdagectl
                       ,pr_rcdoctco.nrdconta   -- nrdconta
                       ,pr_rcdoctco.cdcmpdoc   -- cdcmpchq
                       ,pr_rcdoctco.cdbccrcb   -- cdbccrcb
                       ,pr_rcdoctco.cdagercb   -- cdagercb
                       ,pr_rcdoctco.dvagenci   -- dvagenci
                       ,pr_rcdoctco.nrcctrcb   -- nrcctrcb
                       ,vr_nrdocmto            -- nrdocmto
                       ,pr_rcdoctco.vllanmto   -- vldocmto
                       ,pr_rcdoctco.nmdestin   -- nmpesrcb
                       ,pr_rcdoctco.cpfdesti   -- cpfcgrcb
                       ,pr_rcdoctco.tpdctacr   -- tpdctacr
                       ,pr_rcdoctco.cdfinrcb   -- cdfinrcb
                       ,pr_rcdoctco.nmpesemi   -- nmpesemi
                       ,pr_rcdoctco.cpfcgemi   -- cpfcgemi
                       ,pr_rcdoctco.tpdctadb   -- tpdctadb
                       ,pr_rcdoctco.tpdoctrf   -- tpdoctrf
                       ,vr_vltotreg            -- qtdregen
                       ,pr_nmarquiv            -- nmarquiv
                       ,pr_rcdoctco.nrseqarq   -- nrseqarq
                       ,'1'                    -- cdoperad
                       ,GENE0002.fn_busca_time -- hrtransa
                       ,DECODE(pr_cdcritic, 0, 4, 3) -- cdtipreg
                       ,0                      -- flgconci
                       ,0                      -- flgpcctl
                       ,pr_cdcritic            -- cdcritic
                       ,0);                    -- cdmotdev
  EXCEPTION
    WHEN OTHERS THEN
      -- Cr�tica: Erro Oracle
      vr_cdcritic := 1034;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' gncpdoc[2]: cdcooper:' || pr_rcdoctco.cdcooper ||
                     ', cdagenci:' || pr_rcdoctco.cdagenci   || ', dtmvtolt:' || vr_dtleiarq          ||
                     ', dtliquid:' || vr_dtmvtolt            || ', cdagectl:' || rw_crapcop.cdagectl  ||
                     ', nrdconta:' || pr_rcdoctco.nrdconta   || ', cdcmpchq:' || pr_rcdoctco.cdcmpdoc ||
                     ', cdbccrcb:' || pr_rcdoctco.cdbccrcb   || ', cdagercb:' || pr_rcdoctco.cdagercb ||
                     ', dvagenci:' || pr_rcdoctco.dvagenci   || ', nrcctrcb:' || pr_rcdoctco.nrcctrcb ||
                     ', nrdocmto:' || vr_nrdocmto            || ', vldocmto:' || pr_rcdoctco.vllanmto ||
                     ', nmpesrcb:' || pr_rcdoctco.nmdestin   || ', cpfcgrcb:' || pr_rcdoctco.cpfdesti ||
                     ', tpdctacr:' || pr_rcdoctco.tpdctacr   || ', cdfinrcb:' || pr_rcdoctco.cdfinrcb ||
                     ', nmpesemi:' || pr_rcdoctco.nmpesemi   || ', cpfcgemi:' || pr_rcdoctco.cpfcgemi ||
                     ', tpdctadb:' || pr_rcdoctco.tpdctadb   || ', tpdoctrf:' || pr_rcdoctco.tpdoctrf ||
                     ', qtdregen:' || vr_vltotreg            || ', nmarquiv:' || pr_nmarquiv          ||
                     ', nrseqarq:' || pr_rcdoctco.nrseqarq   || ', cdoperad:1'||
                     ', hrtransa:' || GENE0002.fn_busca_time ||
                     ', cdtipreg: se cdcritic=0 -> 4, senao -> 3' || ', flgconci:0, flgpcctl:0'     ||
                     ', cdcritic:' || pr_cdcritic            || ', cdmotdev:0. '|| sqlerrm;
      -- Envio centralizado de log de erro
      pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => vr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => vr_cdcritic,
                  pr_ind_tipo_log  => 3);

      --Inclus�o na tabela de erros Oracle - Chamado 789851
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

  END pc_cria_generico_tco;

  -- Processar os dados dos documentos TCO
  PROCEDURE pc_processamento_tco(pr_nmarquiv IN gncpdoc.nmarquiv%TYPE) IS

    -- Vari�veis
    vr_nrlotetc      NUMBER;
    vr_nrlottco      NUMBER;

  BEGIN

    -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_processamento_tco', pr_action => NULL);

    -- Percorre toda a tabela de mem�ria de Docs TCO
    FOR vr_indoctco IN nvl(rw_tbdoctco.FIRST,0)..nvl(rw_tbdoctco.LAST,-1) LOOP

      -- Inicializa��o das variaveis
      vr_nrlotetc := 7009;

      -- Se for o primeiro registro
      IF vr_indoctco = rw_tbdoctco.FIRST() THEN

        LOOP -- la�o para calculo do nrlotetc

          -- Buscar registro na CRAPLOT
          OPEN  cr_craplot(rw_tbdoctco(vr_indoctco).cdcooper   -- pr_cdcooper
                          ,vr_dtmvtolt                         -- pr_dtmvtolt
                          ,rw_tbdoctco(vr_indoctco).cdagenci   -- pr_cdagenci
                          ,rw_tbdoctco(vr_indoctco).cdbccxlt   -- pr_cdbccxlt
                          ,vr_nrlotetc); -- pr_nrdolote
          FETCH cr_craplot INTO rw_craplot;

          -- Se encontrar o registro
          IF cr_craplot%FOUND THEN
            vr_nrlotetc := vr_nrlotetc + 1;
          ELSE
            vr_nrlottco := vr_nrlotetc;
            -- Fecha o cursor e sai do la�o
            CLOSE cr_craplot;
            EXIT;
          END IF;

          -- FEchar o cursor para a pr�xima itera��o
          CLOSE cr_craplot;
        END LOOP;

        BEGIN
          -- Limpa o registro para guardar os dados inseridos;
          rw_craplot := NULL;

          -- Insere o novo registro de lote
          INSERT INTO craplot(dtmvtolt
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,tplotmov
                             ,cdcooper)
                      VALUES (vr_dtmvtolt                         -- dtmvtolt
                             ,rw_tbdoctco(vr_indoctco).cdagenci   -- cdagenci
                             ,rw_tbdoctco(vr_indoctco).cdbccxlt   -- cdbccxlt
                             ,vr_nrlottco                         -- nrdolote
                             ,rw_tbdoctco(vr_indoctco).tplotmov   -- tplotmov
                             ,rw_tbdoctco(vr_indoctco).cdcooper)  -- cdcooper
                            RETURNING ROWID INTO rw_craplot.dsrowid;

          -- Guardar os dados inseridos no registro
          rw_craplot.dtmvtolt := vr_dtmvtolt;
          rw_craplot.cdagenci := rw_tbdoctco(vr_indoctco).cdagenci;
          rw_craplot.cdbccxlt := rw_tbdoctco(vr_indoctco).cdbccxlt;
          rw_craplot.nrdolote := vr_nrlottco;
        EXCEPTION
          WHEN OTHERS THEN
            -- Cr�tica: Erro Oracle
            vr_cdcritic := 1034;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                           ' craplot[1]: dtmvtolt:' || vr_dtmvtolt               ||
                           ', cdagenci:' || rw_tbdoctco(vr_indoctco).cdagenci    ||
                           ', cdbccxlt:' || rw_tbdoctco(vr_indoctco).cdbccxlt    ||
                           ', nrdolote:' || vr_nrlottco                          ||
                           ', tplotmov:' || rw_tbdoctco(vr_indoctco).tplotmov    ||
                           ', cdcooper:' || rw_tbdoctco(vr_indoctco).cdcooper    || '. '|| sqlerrm;
          -- Envio centralizado de log de erro
          pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic,
                      pr_cdcriticidade => 2,
                      pr_cdmensagem    => vr_cdcritic,
                      pr_ind_tipo_log  => 3);

          --Inclus�o na tabela de erros Oracle - Chamado 789851
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        END;

      ELSE

        -- buscar o registro de capa de lote
        OPEN  cr_craplot(rw_tbdoctco(vr_indoctco).cdcooper   -- pr_cdcooper
                        ,vr_dtmvtolt                         -- pr_dtmvtolt
                        ,rw_tbdoctco(vr_indoctco).cdagenci   -- pr_cdagenci
                        ,rw_tbdoctco(vr_indoctco).cdbccxlt   -- pr_cdbccxlt
                        ,vr_nrlottco);                       -- pr_nrdolote
        FETCH cr_craplot INTO rw_craplot;

        -- Se n�o encontrar o registro
        IF cr_craplot%NOTFOUND THEN
          vr_cdcritic := 60; -- 060 - Lote inexistente
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                        || ' Arquivo:' || pr_nmarquiv
                        || ' Lote:'    || vr_nrlottco
                        || ' Seq:'     || to_char(vr_nrseqarq,'999g990');
          -- Envio centralizado de log de erro
          pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic,
                      pr_cdcriticidade => 1,
                      pr_cdmensagem    => vr_cdcritic);

          -- Fecha o cursor e pula para o pr�ximo registro
          CLOSE cr_craplot;
          --
          CONTINUE;

        END IF;

        -- Fecha o cursor
        CLOSE cr_craplot;

      END IF;

      LOOP
        -- buscar o registro de lan�amento
        OPEN  cr_craplcm(rw_tbdoctco(vr_indoctco).cdcooper -- pr_cdcooper
                        ,vr_dtmvtolt                       -- pr_dtmvtolt
                        ,rw_tbdoctco(vr_indoctco).cdagenci-- pr_cdagenci
                        ,rw_tbdoctco(vr_indoctco).cdbccxlt -- pr_cdbccxlt
                        ,vr_nrlottco                       -- pr_nrdolote
                        ,rw_tbdoctco(vr_indoctco).nrdctabb -- pr_nrdconta
                        ,vr_nrdocmto);                     -- pr_nrdocmto
        FETCH cr_craplcm INTO vr_nrdummy;

        -- Verifica se encontrou registro
        IF cr_craplcm%FOUND THEN
          vr_nrdocmto := vr_nrdocmto + 1000000;
        ELSE
          -- fecha o cursor e sai do loop
          CLOSE cr_craplcm;
          EXIT;
        END IF;

        -- Fechar o cursor para a proxima itera��o
        CLOSE cr_craplcm;
      END LOOP;

      BEGIN

        -- Inserir o lan�amento
        INSERT INTO craplcm(cdcooper
                           ,dtmvtolt
                           ,dtrefere
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
                           ,cdpesqbb
                           ,cdbanchq
                           ,cdcmpchq
                           ,cdagechq
                           ,nrctachq
                           ,sqlotchq)
                     VALUES(rw_tbdoctco(vr_indoctco).cdcooper     -- cdcooper
                           ,rw_craplot.dtmvtolt                   -- dtmvtolt
                           ,vr_dtleiarq                           -- dtrefere
                           ,rw_craplot.cdagenci                   -- cdagenci
                           ,rw_craplot.cdbccxlt                   -- cdbccxlt
                           ,rw_craplot.nrdolote                   -- nrdolote
                           ,rw_tbdoctco(vr_indoctco).nrdconta     -- nrdconta
                           ,rw_tbdoctco(vr_indoctco).nrdctabb     -- nrdctabb
                           ,GENE0002.fn_mask(rw_tbdoctco(vr_indoctco).nrdconta,'zzzzzz.zzz.zzz.z') -- nrdctitg
                           ,vr_nrdocmto                           -- nrdocmto
                           ,rw_tbdoctco(vr_indoctco).cdhistor     -- cdhistor
                           ,rw_tbdoctco(vr_indoctco).vllanmto     -- vllanmto
                           ,rw_tbdoctco(vr_indoctco).nrseqarq     -- nrseqdig
                           ,vr_cdpeslcm                           -- cdpesqbb
                           ,rw_tbdoctco(vr_indoctco).cdbandoc     -- cdbanchq
                           ,rw_tbdoctco(vr_indoctco).cdcmpdoc     -- cdcmpchq
                           ,rw_tbdoctco(vr_indoctco).cdagedoc     -- cdagechq
                           ,rw_tbdoctco(vr_indoctco).nrctadoc     -- nrctachq
                           ,rw_tbdoctco(vr_indoctco).sqlotdoc );  -- sqlotchq
      EXCEPTION
        WHEN OTHERS THEN
          -- Cr�tica: Erro Oracle
          vr_cdcritic := 1034;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' craplcm[1]: cdcooper: '|| rw_tbdoctco(vr_indoctco).cdcooper ||
                         ', dtmvtolt: '|| rw_craplot.dtmvtolt               ||
                         ', dtrefere: '|| vr_dtleiarq                       ||
                         ', cdagenci: '|| rw_craplot.cdagenci               ||
                         ', cdbccxlt: '|| rw_craplot.cdbccxlt               ||
                         ', nrdolote: '|| rw_craplot.nrdolote               ||
                         ', nrdconta: '|| rw_tbdoctco(vr_indoctco).nrdconta ||
                         ', nrdctabb: '|| rw_tbdoctco(vr_indoctco).nrdctabb ||
                         ', nrdctitg: '|| rw_tbdoctco(vr_indoctco).nrdconta ||
                         ', nrdocmto: '|| vr_nrdocmto                       ||
                         ', cdhistor: '|| rw_tbdoctco(vr_indoctco).cdhistor ||
                         ', vllanmto: '|| rw_tbdoctco(vr_indoctco).vllanmto ||
                         ', nrseqdig: '|| rw_tbdoctco(vr_indoctco).nrseqarq ||
                         ', cdpesqbb: '|| vr_cdpeslcm                       ||
                         ', cdbanchq: '|| rw_tbdoctco(vr_indoctco).cdbandoc ||
                         ', cdcmpchq: '|| rw_tbdoctco(vr_indoctco).cdcmpdoc ||
                         ', cdagechq: '|| rw_tbdoctco(vr_indoctco).cdagedoc ||
                         ', nrctachq: '|| rw_tbdoctco(vr_indoctco).nrctadoc ||
                         ', sqlotchq: '|| rw_tbdoctco(vr_indoctco).sqlotdoc || '. '|| sqlerrm;
          -- Envio centralizado de log de erro
          pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic,
                      pr_cdcriticidade => 2,
                      pr_cdmensagem    => vr_cdcritic,
                      pr_ind_tipo_log  => 3);

          --Inclus�o na tabela de erros Oracle - Chamado 789851
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      END;

      BEGIN
        -- Atualizar dados da CRAPLOT
        UPDATE CRAPLOT
           SET craplot.qtinfoln = NVL(craplot.qtinfoln,0) + 1
             , craplot.qtcompln = NVL(craplot.qtcompln,0) + 1
             , craplot.vlinfocr = NVL(craplot.vlinfocr,0) + rw_tbdoctco(vr_indoctco).vllanmto
             , craplot.vlcompcr = NVL(craplot.vlcompcr,0) + rw_tbdoctco(vr_indoctco).vllanmto
             , craplot.nrseqdig = rw_tbdoctco(vr_indoctco).nrseqarq
         WHERE craplot.rowid    = rw_craplot.dsrowid;
      EXCEPTION
        WHEN OTHERS THEN
          -- Cr�tica: Erro Oracle
          vr_cdcritic := 1035;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' craplot[1]: qtinfoln: + 1' || ', qtcompln: + 1'      ||
                         ', vlinfocr: + '  || rw_tbdoctco(vr_indoctco).vllanmto ||
                         ', vlcompcr: + '  || rw_tbdoctco(vr_indoctco).vllanmto ||
                         ', nrseqdig:'     || rw_tbdoctco(vr_indoctco).nrseqarq ||
                         ' com rowid:'     || rw_craplot.dsrowid ||'. '|| sqlerrm;
          -- Envio centralizado de log de erro
          pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic,
                      pr_cdcriticidade => 2,
                      pr_cdmensagem    => vr_cdcritic,
                      pr_ind_tipo_log  => 3);

          --Inclus�o na tabela de erros Oracle - Chamado 789851
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      END;

      -- Criar registro gen�rico de documento TCO
      pc_cria_generico_tco(pr_cdcritic  => 0
                          ,pr_nmarquiv  => pr_nmarquiv
                          ,pr_rcdoctco  => rw_tbdoctco(vr_indoctco) );

      -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
      GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_processamento_tco', pr_action => NULL);

    END LOOP; -- DOCs TCO

  END pc_processamento_tco;

  -- Criar o registro com os dados dos documentos TCO
  PROCEDURE pc_cria_doctos_tco(pr_cdcooper   IN NUMBER
                              ,pr_nrdconta   IN NUMBER
                              ,pr_nrdctabb   IN NUMBER
                              ,pr_dslinha    IN VARCHAR2) IS
    -- Vari�veis locais
    vr_nrchave    BINARY_INTEGER;

  BEGIN

    -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_cria_doctos_tco', pr_action => NULL);

    -- Chave do registro
    vr_nrchave := rw_tbdoctco.COUNT() + 1;

    -- Inclui os dados no registro
    rw_tbdoctco(vr_nrchave).cdcooper := pr_cdcooper;
    rw_tbdoctco(vr_nrchave).nrdconta := pr_nrdconta;
    rw_tbdoctco(vr_nrchave).nrdctabb := pr_nrdctabb;
    rw_tbdoctco(vr_nrchave).cdagenci := vr_cdagenci;
    rw_tbdoctco(vr_nrchave).cdbccxlt := rw_crapcop.cdbcoctl;
    rw_tbdoctco(vr_nrchave).tplotmov := vr_tplotmov;
    rw_tbdoctco(vr_nrchave).nrdocmto := vr_nrdocmto;
    rw_tbdoctco(vr_nrchave).cdbandoc := vr_cdbandoc;
    rw_tbdoctco(vr_nrchave).cdcmpdoc := vr_cdcmpdoc;
    rw_tbdoctco(vr_nrchave).cdagedoc := vr_cdagedoc;
    rw_tbdoctco(vr_nrchave).nrctadoc := vr_nrctadoc;
    rw_tbdoctco(vr_nrchave).cdhistor := vr_cdhistor;
    rw_tbdoctco(vr_nrchave).vllanmto := vr_vllanmto;
    rw_tbdoctco(vr_nrchave).nrseqarq := vr_nrseqarq;
    rw_tbdoctco(vr_nrchave).cdpesqbb := vr_cdpeslcm;

    rw_tbdoctco(vr_nrchave).cdbccrcb := TO_NUMBER(SUBSTR(pr_dslinha,4,3));
    rw_tbdoctco(vr_nrchave).cdagercb := TO_NUMBER(SUBSTR(pr_dslinha,7,4));
    rw_tbdoctco(vr_nrchave).dvagenci := SUBSTR(pr_dslinha,11,1);
    rw_tbdoctco(vr_nrchave).nrcctrcb := TO_NUMBER(SUBSTR(pr_dslinha,12,13));
    rw_tbdoctco(vr_nrchave).tpdctacr := TO_NUMBER(SUBSTR(pr_dslinha,103,2));
    rw_tbdoctco(vr_nrchave).cdfinrcb := TO_NUMBER(SUBSTR(pr_dslinha,105,2));
    rw_tbdoctco(vr_nrchave).nmpesemi := SUBSTR(pr_dslinha,142,40);
    rw_tbdoctco(vr_nrchave).cpfcgemi := TO_NUMBER(SUBSTR(pr_dslinha,182,14));
    rw_tbdoctco(vr_nrchave).tpdctadb := TO_NUMBER(SUBSTR(pr_dslinha,196,2));
    rw_tbdoctco(vr_nrchave).tpdoctrf := SUBSTR(pr_dslinha,203,1);
    rw_tbdoctco(vr_nrchave).nmdestin := SUBSTR(pr_dslinha,49,40);
    rw_tbdoctco(vr_nrchave).cpfdesti := TO_NUMBER(SUBSTR(pr_dslinha,89,14));

  END pc_cria_doctos_tco;
  
  -- Rotina respons�vel pelo processamento das integra��es para a cecred
  PROCEDURE pc_integra_cecred(pr_tbarquiv    IN GENE0002.typ_split )  IS

    -- Tipos
    -- Record para o relat�rio
    TYPE typ_rcrelato IS RECORD(cdbandoc  NUMBER
                               ,cdageemi  NUMBER
                               ,cdmotdev  NUMBER
                               ,tpdedocs  VARCHAR2(1)
                               ,cdbccrcb  NUMBER
                               ,cdagercb  NUMBER
                               ,nrcctrcb  NUMBER
                               ,cpfdesti  VARCHAR2(20)
                               ,nrdocmto  NUMBER
                               ,nmdestin  VARCHAR2(40)
                               ,vllanmto  NUMBER
                               ,nmarquiv  VARCHAR2(50) );

    -- Tabela de mem�ria para informa��es do relat�rio
    TYPE typ_tbrelato IS TABLE OF typ_rcrelato INDEX BY VARCHAR2(100);
    TYPE typ_arquivo IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

    -- Vari�veis locais
    vr_tbrelato    typ_tbrelato;
    vr_flgrejei    BOOLEAN;
    vr_vlcredit    NUMBER;
    -- Arquivo lido
    vr_utlfileh    UTL_FILE.file_type;
    -- Array para guardar as linhas dos arquivos
    vr_arquivo     typ_arquivo;
    -- Vari�vel criada para manter o nome do arquivo e apresentar na cr�tica 191
    --Chamado 789851 - 24/11/2017
    vr_nmarquiv_indice VARCHAR2(200) := NULL;
    
  BEGIN

    -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_integra_cecred', pr_action => NULL);

    -- Limpa o registro de dados do relat�rio
    vr_tbrelato.DELETE;

    -- Percorrer os arquivos
    FOR vr_nrindice IN pr_tbarquiv.FIRST..pr_tbarquiv.LAST LOOP
      -- Inicializa
      vr_flgrejei := FALSE;
      vr_vlcredit := 0;
      vr_vltotreg := 0;

      -- Abrir o arquivo
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdirarq
                              ,pr_nmarquiv => pr_tbarquiv(vr_nrindice)
                              ,pr_tipabert => 'R'
                              ,pr_utlfileh => vr_utlfileh
                              ,pr_des_erro => vr_dscritic);

      -- Verifica se houve erro ao abrir o arquivo
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      --Chamado 789851 - 24/11/2017
      vr_nmarquiv_indice := pr_tbarquiv(vr_nrindice);

      -- Limpar o registro de mem�ria, Caso possua registros
      IF vr_arquivo.COUNT() > 0 THEN
        vr_arquivo.DELETE;
      END IF;

      -- Se o arquivo estiver aberto, percorre o mesmo e guarda todas as linhas
      -- em um registro de mem�ria
      IF  utl_file.IS_OPEN(vr_utlfileh) THEN
        -- Ler todas as linhas do arquivo
        LOOP
          BEGIN
            -- Guarda todas as linhas do arquivo no array
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh --> Handle do arquivo aberto
                                        ,pr_des_text => vr_arquivo(vr_arquivo.count()+1)); --> Texto lido
          EXCEPTION
            WHEN no_data_found THEN -- n�o encontrar mais linhas
              EXIT;
            WHEN OTHERS THEN
              vr_cdcritic := 1053; -- Erro no arquivo
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' ['||pr_tbarquiv(vr_nrindice)||']: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END LOOP;

        -- Fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh); --> Handle do arquivo aberto;
      END IF;
      --
      -- Remover as linhas em branco do arquivo
      -- Enquanto a ultima linha possuir menos de 100 posi��es
      WHILE (length(vr_arquivo(vr_arquivo.last())) < 100 AND vr_arquivo.COUNT() > 0) LOOP
        -- Exclui a ultima linha lida no arquivo
        vr_arquivo.delete(vr_arquivo.last());
      END LOOP;

      -- Verifica se h� linhas no arquivo
      IF vr_arquivo.count() > 0 THEN

        -- Verifica se o arquivo est� completo
        IF SUBSTR(vr_arquivo(vr_arquivo.LAST()),1,10) <> '9999999999' THEN
          -- Gerar a Cr�tica
          vr_cdcritic := 258; -- Nao ha arquivo da COMPBB para integrar
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          -- Envio centralizado de log de erro
          pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic,
                      pr_cdcriticidade => 1,
                      pr_cdmensagem    => vr_cdcritic);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        END IF;

        -- Excluir a ultima linha, pois j� foi processada
        vr_arquivo.DELETE(vr_arquivo.LAST());

        -- Verifica a primeira linha do arquivo
        IF SUBSTR(vr_arquivo(vr_arquivo.first()),1,10) <> '0000000000' THEN
          -- Gerar a Cr�tica
          vr_cdcritic := 468; -- 468 - tipo de registro errado
        ELSIF SUBSTR(vr_arquivo(vr_arquivo.first()),21,6) <> 'DCR615' THEN
          -- Gerar a Cr�tica
          vr_cdcritic := 181; -- 181 - Falta registro de controle no arquivo.
        END IF;

        BEGIN
          vr_cdcmpori := NVL(TO_NUMBER(SUBSTR(vr_arquivo(vr_arquivo.first()),39,3)),0);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 1052; -- Erro ao converter compe de origem do arquivo
            -- Buscar a descri��o
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            RAISE vr_exc_saida;
        END;    

        -- Se tem cr�tica
        IF NVL(vr_cdcritic,0) <> 0 THEN

          -- Buscar a descri��o da cr�tica
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                         || ' - Integrando via AILOS - '
                         || 'Arquivo: ' || pr_tbarquiv(vr_nrindice);
          -- Envio centralizado de log de erro
          pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic,
                      pr_cdcriticidade => 1,
                      pr_cdmensagem    => vr_cdcritic);

          -- Reinicializar a vari�vel de cr�tica
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
          -- Processar o pr�ximo arquivo
          CONTINUE;
          --
        END IF;

        -- Critica de processo: 219 - INTEGRANDO ARQUIVO
        vr_cdcritic := 219;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                      || '. Arquivo: ' || pr_tbarquiv(vr_nrindice);

        -- Envio centralizado de log de erro
        pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                    pr_dstiplog      => 'O',
                    pr_dscritic      => vr_dscritic,
                    pr_cdcriticidade => 0,
                    pr_cdmensagem    => vr_cdcritic,
                    pr_ind_tipo_log  => 1);

        -- Reinicializar a vari�vel de cr�tica
        vr_cdcritic := NULL;

        -- Percorrer todas as linhas do arquivo a partir da segunda linha
        FOR vr_indlinha IN vr_arquivo.NEXT(vr_arquivo.FIRST)..vr_arquivo.LAST LOOP
          -- Bloco para processamento da linha
          DECLARE

            -- Vari�veis
            vr_dslinha    CONSTANT VARCHAR2(500) := vr_arquivo(vr_indlinha); -- Linha a ser processada
            --
            vr_tpdsdocs   VARCHAR2(1);
            vr_dsrelcpf   VARCHAR2(20);
            --
            vr_cdbandoc   NUMBER;
            vr_nrdcont2   NUMBER;
            vr_cdbccrcb   NUMBER;
            vr_cdagercb   NUMBER;
            vr_nrseqchv   NUMBER;
            --
            vr_nrdconta   NUMBER;
            vr_cdagedoc   NUMBER;
            vr_nrctadoc   NUMBER;
            vr_nmemiten   VARCHAR2(100);
            vr_nrcpfemi   NUMBER;

          BEGIN

            -- Inicializar vari�vel
            vr_cpfremet := 0;

            -- Ler as informa��es do arquivo
            vr_nrseqarq := TO_NUMBER(SUBSTR(vr_dslinha ,250, 6));
            vr_cdbandoc := TO_NUMBER(SUBSTR(vr_dslinha ,121, 3));
            vr_tpdedocs := TO_NUMBER(SUBSTR(vr_dslinha ,203, 1));
            vr_nrdcont2 := TO_NUMBER(SUBSTR(vr_dslinha , 12,13));
            vr_cpfdesti := TO_NUMBER(SUBSTR(vr_dslinha , 89,14));
            vr_nrdocmto := TO_NUMBER(SUBSTR(vr_dslinha , 25, 6));
            vr_nmdestin := SUBSTR(vr_dslinha , 49,40);
            vr_vllanmto := (TO_NUMBER(SUBSTR(vr_dslinha, 31,18)) / 100);
            vr_cdbccrcb := TO_NUMBER(SUBSTR(vr_dslinha ,  4, 3));
            vr_cdagercb := TO_NUMBER(SUBSTR(vr_dslinha ,  7, 4));            
            vr_nrdconta := TO_NUMBER(SUBSTR(vr_dslinha ,17,08));
            vr_cdagedoc := TO_NUMBER(SUBSTR(vr_dslinha ,124,4));
            vr_nrctadoc := TO_NUMBER(SUBSTR(vr_dslinha,129,13));
            vr_nmemiten := SUBSTR(vr_dslinha,142,40);
            vr_nrcpfemi := TO_NUMBER(SUBSTR(vr_dslinha,182,14));

            -- Verificar o tipo de documento
            IF vr_tpdedocs = 2 THEN
              vr_tpdsdocs := 'A';
            ELSIF vr_tpdedocs = 3 THEN
              vr_tpdsdocs := 'B';
            ELSIF vr_tpdedocs = 4 THEN
              vr_tpdsdocs := 'C';
            ELSIF vr_tpdedocs = 5 THEN
              vr_tpdsdocs := 'D';
            ELSIF vr_tpdedocs = 6 THEN
              vr_tpdsdocs := 'E';
            ELSE
              vr_tpdsdocs := TO_CHAR(vr_tpdedocs);
            END IF;

            -- Verifica se � um cpf ou um CNPJ
            IF length(vr_cpfdesti) = 11 THEN
              -- Aplica m�scara para CPF
              vr_dsrelcpf := GENE0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_cpfdesti
                                                      ,pr_inpessoa => 1);
            ELSE
              -- Aplica m�scara para CNPJ
              vr_dsrelcpf := GENE0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_cpfdesti
                                                      ,pr_inpessoa => 2);
            END IF;

            -- Zera o n�mero auxiliar da chave
            vr_nrseqchv := 0;

            /* Incluir as informa��es no registro de mem�ria */
            LOOP
              --Incrementa o sequencial
              vr_nrseqchv := vr_nrseqchv + 1;

              -- Montar a chave para o registro
              vr_indchave := LPAD(vr_cdbandoc, 3, 0)||
                             LPAD(vr_cdbccrcb, 3, 0)||
                             LPAD(vr_cdagercb, 4, 0)||
                             LPAD(vr_nrdcont2,13, 0)||
                             LPAD(vr_nrseqchv, 4, 0) ;

              -- Caso o registro n�o exista... sai do loop
              EXIT WHEN NOT vr_tbrelato.EXISTS(vr_indchave);
            END LOOP;

            pc_cria_ddc(pr_cdcooper => 3             -- cdcooper (CECRED)
                       ,pr_cdagenci => vr_cdagercb   -- cdagenci
                       ,pr_nrdocmto => vr_nrdocmto   -- nrdocmto
                       ,pr_vldocmto => vr_vllanmto   -- vldocmto
                       ,pr_nrdconta => vr_nrdconta   -- nrdconta
                       ,pr_nmfavore => vr_nmdestin   -- nmfavore
                       ,pr_nrcpffav => vr_cpfdesti   -- nrcpffav
                       ,pr_cdcritic => vr_critiass   -- cdcritic
                       ,pr_cdbandoc => vr_cdbandoc   -- cdbandoc
                       ,pr_cdagedoc => vr_cdagedoc   -- cdagedoc
                       ,pr_nrctadoc => vr_nrctadoc   -- nrctadoc
                       ,pr_nmemiten => vr_nmemiten   -- nmemiten
                       ,pr_nrcpfemi => vr_nrcpfemi   -- nrcpfemi
                       ,pr_dslayout => vr_dslinha    -- dslayout
                       ,pr_cdcmpori => vr_cdcmpori   -- cdcmpori  
                       ,pr_dsdrowid => vr_dsdrowid);

            -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
            GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_integra_cecred', pr_action => NULL);

            -- Atualizar registro
            vr_tbrelato(vr_indchave).cdbandoc := vr_cdbandoc;
            vr_tbrelato(vr_indchave).cdageemi := TO_NUMBER(SUBSTR(vr_dslinha ,124, 3));
            vr_tbrelato(vr_indchave).cdmotdev := 0;
            vr_tbrelato(vr_indchave).tpdedocs := vr_tpdsdocs;
            vr_tbrelato(vr_indchave).cdbccrcb := vr_cdbccrcb;
            vr_tbrelato(vr_indchave).cdagercb := vr_cdagercb;
            vr_tbrelato(vr_indchave).nrcctrcb := vr_nrdcont2;
            vr_tbrelato(vr_indchave).cpfdesti := vr_dsrelcpf;
            vr_tbrelato(vr_indchave).nrdocmto := vr_nrdocmto;
            vr_tbrelato(vr_indchave).nmdestin := vr_nmdestin;
            vr_tbrelato(vr_indchave).vllanmto := vr_vllanmto;
            vr_tbrelato(vr_indchave).nmarquiv := vr_nmsubrel||pr_tbarquiv(vr_nrindice);

          END;
        END LOOP;  -- Linhas do arquivo

        /* Move o arquivo lido para o diret�rio salvar */
        gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_dsdirarq||pr_tbarquiv(vr_nrindice)||' '||vr_dsdireto||'/salvar 2> /dev/null'
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_des_saida);

        -- Se retornar uma indica��o de erro
        IF NVL(vr_typ_saida,' ') = 'ERR' THEN
          vr_cdcritic := 1054; -- Erro pc_OScommand_Shell
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_des_saida;
          -- Envio centralizado de log de erro
          pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic,
                      pr_cdcriticidade => 1,
                      pr_cdmensagem    => vr_cdcritic);
	      ELSE
          -- Grava��o a cada arquivo processado
          COMMIT;
        END IF;

      END IF;

    END LOOP; -- Fim da leitura dos arquivos

    /*** GERA��O DO RELAT�RIO COM OS DADOS PROCESSADOS ***/
    -- Se h� registros para serem inseridos no relat�rio
    IF vr_tbrelato.COUNT() > 0 THEN

      -- Bloco respons�vel pela estrutura��o do XML para gera��o do relat�rio
      DECLARE

        -- Vari�veis
        vr_clobxml     CLOB;
        vr_des_erro    VARCHAR2(4000);
        vr_dspathcop   VARCHAR2(80);

        -- Subrotina para escrever texto na vari�vel CLOB do XML
        PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                                 ,pr_desdados IN VARCHAR2) IS
        BEGIN
          dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
        END;

      BEGIN

        -- Preparar o CLOB para armazenar as infos do arquivo
        dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
        pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?>'||chr(10)||
                                   '<crrl563 dstitulo="SOLICITACAO DE DEVOLUCAO DE DOC ELETRONICO" '||
                                   '  dtrefere="'||to_char(vr_dtmvtolt,'DD/MM/YYYY')||'" >'||chr(10));

        -- Verifica se h� informa��es no registro de mem�ria
        IF vr_tbrelato.COUNT() > 0 THEN

          -- Primeiro �ndice
          vr_indchave := vr_tbrelato.FIRST;

          -- Percorre as informa��es guardadas na mem�ria para montar o XML
          LOOP

            -- Titulo
            pc_escreve_clob(vr_clobxml,'  <devolucao> '||chr(10)||
                                       '    <cdbandoc>'||vr_tbrelato(vr_indchave).cdbandoc||'</cdbandoc>'||chr(10)||
                                       '    <cdageemi>'||vr_tbrelato(vr_indchave).cdageemi||'</cdageemi>'||chr(10)||
                                       '    <cdmotdev>'||vr_tbrelato(vr_indchave).cdmotdev||'</cdmotdev>'||chr(10)||
                                       '    <tpdedocs>'||vr_tbrelato(vr_indchave).tpdedocs||'</tpdedocs>'||chr(10)||
                                       '    <cdbccrcb>'||vr_tbrelato(vr_indchave).cdbccrcb||'</cdbccrcb>'||chr(10)||
                                       '    <cdagercb>'||vr_tbrelato(vr_indchave).cdagercb||'</cdagercb>'||chr(10)||
                                       '    <nrcctrcb>'||GENE0002.fn_mask(vr_tbrelato(vr_indchave).nrcctrcb,'zzzzz.zzzz.zzz.z')||'</nrcctrcb>'||chr(10)||
                                       '    <cpfdesti>'||vr_tbrelato(vr_indchave).cpfdesti||'</cpfdesti>'||chr(10)||
                                       '    <nrdocmto>'||to_char(vr_tbrelato(vr_indchave).nrdocmto,'FM999G999G999')||'</nrdocmto>'||chr(10)||
                                       '    <nmdestin>'||GENE0007.fn_caract_controle(TRIM(SUBSTR(vr_tbrelato(vr_indchave).nmdestin,0,38)))||'</nmdestin>'||chr(10)||
                                       '    <vllanmto>'||to_char(vr_tbrelato(vr_indchave).vllanmto,'FM9G999G999G990D00')||'</vllanmto>'||chr(10)||
                                       '  </devolucao>');

            -- Sai quando chegar no �ltimo registro
            EXIT WHEN vr_indchave = vr_tbrelato.LAST;
            -- Pr�ximo registro
            vr_indchave := vr_tbrelato.NEXT(vr_indchave);
          END LOOP;
        END IF;

        -- Fecha a tag geral
        pc_escreve_clob(vr_clobxml,chr(10)||'</crrl563>');

        -- Limpa a variavel de controle de c�pia do relat�rio
        vr_dspathcop := NULL;

        -- Verifica a tela
        IF pr_nmtelant = 'COMPEFORA' THEN
          -- Buscar o diret�rio padrao da cooperativa conectada + /rlnsv
          vr_dspathcop := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => 'rlnsv');
        END IF;

        -- Submeter o relat�rio 563
        GENE0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                  --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra                  --> Programa chamador
                                   ,pr_dtmvtolt  => vr_dtmvtolt                  --> Data do movimento atual
                                   ,pr_dsxml     => vr_clobxml                   --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl563/devolucao'         --> N� base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl563.jasper'             --> Arquivo de layout do iReport
                                   ,pr_dsparams  => null                         --> Sem par�metros
                                   ,pr_dsarqsaid => vr_dsdirrel||'crrl563.lst'   --> Arquivo final com o path
                                   ,pr_qtcoluna  => 132                          --> 132 colunas
                                   ,pr_sqcabrel  => 2                            --> Sequencia
                                   ,pr_flg_gerar => 'N'                          --> Gera�ao na hora
                                   ,pr_flg_impri => 'S'                          --> Chamar a impress�o (Imprim.p)
                                   ,pr_nmformul  => NULL                         --> Nome do formul�rio para impress�o
                                   ,pr_dspathcop => vr_dspathcop                 --> Lista sep. por ';' de diret�rios a copiar o relat�rio
                                   ,pr_cdrelato  => 563                          --> C�digo fixo para o relat�rio (nao busca pelo sqcabrel)
                                   ,pr_nrcopias  => 1                            --> N�mero de c�pias
                                   ,pr_des_erro  => vr_des_erro);                --> Sa�da com erro

        -- Liberando a mem�ria alocada pro CLOB
        dbms_lob.close(vr_clobxml);
        dbms_lob.freetemporary(vr_clobxml);

        -- Verifica se ocorreram erros na gera��o do XML
        IF vr_des_erro IS NOT NULL THEN
          vr_dscritic := vr_des_erro;

          -- Gerar exce��o
          RAISE vr_exc_saida;
        END IF;

      END;
    END IF; -- vr_relato.COUNT() > 0

    -- Critica de processo: 191 - ARQUIVO INTEGRADO COM REJEITADOS
    vr_cdcritic := 191;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                   || '. Arquivo: ' || vr_nmarquiv_indice;

    -- Envio centralizado de log de erro
    pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                pr_dstiplog      => 'E',
                pr_dscritic      => vr_dscritic,
                pr_cdcriticidade => 1,
                pr_cdmensagem    => vr_cdcritic);

    -- Reinicializar a vari�vel de cr�tica
    vr_cdcritic := NULL;

  END pc_integra_cecred;
  
  -- Rotina para realizar a integra��o das cooperativas
  PROCEDURE pc_integra_cooperativa(pr_tbarquiv    IN GENE0002.typ_split )  IS

    -- Tipos
    -- Record para o relat�rio
    TYPE typ_rcrelato IS RECORD(cdcooper  NUMBER
                               ,nrdconta  NUMBER
                               ,nrdctabb  NUMBER
                               ,cdagenci  NUMBER
                               ,cdbccxlt  NUMBER
                               ,tplotmov  NUMBER
                               ,nrdocmto  NUMBER
                               ,cdbandoc  NUMBER
                               ,nrlotdoc  NUMBER
                               ,sqlotdoc  NUMBER
                               ,cdcmpdoc  NUMBER
                               ,cdagedoc  NUMBER
                               ,nrctadoc  NUMBER
                               ,cdhistor  NUMBER
                               ,vllanmto  NUMBER
                               ,nrseqarq  NUMBER
                               ,cdpesqbb  VARCHAR2(1)
                               ,cdbandep  NUMBER
                               ,cdcmpdep  NUMBER
                               ,cdagedep  NUMBER
                               ,nrctadep  NUMBER
                               ,cdbccrcb  NUMBER
                               ,cdagercb  NUMBER
                               ,dvagenci  VARCHAR2(1)
                               ,nrcctrcb  NUMBER
                               ,tpdctacr  NUMBER
                               ,cdfinrcb  NUMBER
                               ,nmpesemi  VARCHAR2(40)
                               ,cpfcgemi  NUMBER
                               ,tpdctadb  NUMBER
                               ,tpdoctrf  VARCHAR2(1)
                               ,nmdestin  VARCHAR2(40)
                               ,cpfdesti  NUMBER);

    -- Tabela de mem�ria para informa��es do relat�rio
    TYPE typ_tbrelato IS TABLE OF typ_rcrelato INDEX BY VARCHAR2(100);

    TYPE typ_arquivo IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

    -- Vari�veis locais
    vr_tbrelato    typ_tbrelato;
    vr_vltotreg    NUMBER;
    vr_flgfirst    BOOLEAN;
    vr_flgrejei    BOOLEAN;
    vr_flgregis    BOOLEAN := FALSE;
    vr_qtregrec    NUMBER;
    vr_qtcompln    NUMBER;
    vr_vlcompcr    NUMBER;
    vr_arqproce    VARCHAR2(100);
    
    -- Arquivo lido
    vr_utlfileh    UTL_FILE.file_type;
    -- Array para guardar as linhas dos arquivos
    vr_arquivo     typ_arquivo;
    -- Flag para indicar incorpora��o ou n�o
    vr_flgincorp   BOOLEAN;

  BEGIN

    -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_integra_cooperativa', pr_action => NULL);

    -- Limpa o registro de dados do relat�rio
    vr_tbrelato.DELETE;

    -- Percorrer os arquivos
    FOR vr_nrindice IN pr_tbarquiv.FIRST..pr_tbarquiv.LAST LOOP
      
      /* Limpar variavel de controle de rejei��o */
      vr_flgrejei := FALSE;
    
      -- Se a cooperativa atual possuir incorpora��o
      -- E o arquivo � um arquivo de cooperativa incorporada
      IF rw_crapcop_incorp.cdcooper IS NOT NULL AND pr_tbarquiv(vr_nrindice) LIKE '3'|| TO_CHAR(rw_crapcop_incorp.cdagectl,'FM0009') || '%.RET' THEN
        -- Indicar que h� incorpora��o no arquivo atual
        vr_flgincorp       := TRUE;
      ELSE
        -- N�o h� incorpora��o
        vr_flgincorp       := FALSE;
        vr_nrdconta_incorp := NULL;
      END IF;            
    
      -- Limpa o registro de mem�ria
      rw_tbdoctco.DELETE();

      -- Abrir o arquivo
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdirarq
                              ,pr_nmarquiv => pr_tbarquiv(vr_nrindice)
                              ,pr_tipabert => 'R'
                              ,pr_utlfileh => vr_utlfileh
                              ,pr_des_erro => vr_dscritic);

      -- Verifica se houve erro ao abrir o arquivo
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Limpar o registro de mem�ria, Caso possua registros
      IF vr_arquivo.COUNT() > 0 THEN
        vr_arquivo.DELETE;
      END IF;
      -- Se o arquivo estiver aberto, percorre o mesmo e guarda todas as linhas
      -- em um registro de mem�ria
      IF  utl_file.IS_OPEN(vr_utlfileh) THEN

        -- Ler todas as linhas do arquivo
        LOOP
          BEGIN
            -- Guarda todas as linhas do arquivo no array
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh --> Handle do arquivo aberto
                                        ,pr_des_text => vr_arquivo(vr_arquivo.count()+1)); --> Texto lido
          EXCEPTION
            WHEN no_data_found THEN -- n�o encontrar mais linhas
              EXIT;
            WHEN OTHERS THEN
              vr_cdcritic := 1053; -- Erro no arquivo
              -- Buscar a descri��o
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' ['||pr_tbarquiv(vr_nrindice)||']: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END LOOP;

        -- Fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh); --> Handle do arquivo aberto;
      END IF;
      --
      -- Remover as linhas em branco do arquivo
      -- Enquanto a ultima linha possuir menos de 100 posi��es
      WHILE vr_arquivo.COUNT() > 0 AND (length(vr_arquivo(vr_arquivo.last())) < 100 ) LOOP
        -- Exclui a ultima linha lida no arquivo
        vr_arquivo.delete(vr_arquivo.last());
      END LOOP;

      -- Reinicializar as vari�veis
      vr_qtcompln := 0;
      vr_vlcompcr := 0;

      -- Verifica se h� linhas no arquivo
      IF vr_arquivo.count() > 0 THEN

        -- Verifica se o arquivo est� completo
       IF SUBSTR(vr_arquivo(vr_arquivo.last()),1,10) <> '9999999999' THEN
          -- Gerar a Cr�tica
          vr_cdcritic := 258; -- Nao ha arquivo da COMPBB para integrar
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          -- Envio centralizado de log de erro
          pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic,
                      pr_cdcriticidade => 1,
                      pr_cdmensagem    => vr_cdcritic);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        ELSE
          -- Guarda o valor
          vr_vltotreg := TO_NUMBER(SUBSTR(vr_arquivo(vr_arquivo.LAST()), 71,6));
        END IF;

        -- Verifica a primeira linha do arquivo
        IF SUBSTR(vr_arquivo(vr_arquivo.first()),1,10) <> '0000000000' THEN
          -- Gerar a Cr�tica - 468 - tipo de registro errado
          vr_cdcritic := 468;
        ELSIF SUBSTR(vr_arquivo(vr_arquivo.first()),21,6) <> 'DCR615' THEN
          -- Gerar a Cr�tica - 181 - Falta registro de controle no arquivo.
          vr_cdcritic := 181;
        ELSIF NOT vr_flgincorp AND SUBSTR(vr_arquivo(vr_arquivo.first()),27,4) <> to_char(rw_crapcop.cdagectl,'FM0000') THEN
          -- Gerar a Cr�tica - 057 - BANCO NAO CADASTRADO
          -- Obs: N�o � arquivo incorporado, foi usado a rw_crapcop.cdagectl (Conectada)
          vr_cdcritic := 057;  
        ELSIF vr_flgincorp AND SUBSTR(vr_arquivo(vr_arquivo.first()),27,4) <> to_char(rw_crapcop_incorp.cdagectl,'FM0000') THEN
          -- Gerar a Cr�tica - 057 - BANCO NAO CADASTRADO
          -- Obs: � arquivo incorporado, foi usado a rw_crapcop_incorp.cdagectl (Coop Incorporada)
          vr_cdcritic := 057;
        ELSIF SUBSTR(vr_arquivo(vr_arquivo.first()),31,8) <> vr_dtauxili THEN
          -- Gerar a Cr�tica
          vr_cdcritic := 013; -- 013 - Data errada
        END IF;

        BEGIN
          vr_cdcmpori := NVL(TO_NUMBER(SUBSTR(vr_arquivo(vr_arquivo.first()),39,3)),0);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 1052; -- Erro ao converter compe de origem do arquivo
            -- Buscar a descri��o
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            RAISE vr_exc_saida;
        END;    
        
        -- Se tem cr�tica
        IF NVL(vr_cdcritic,0) <> 0 THEN
          -- Buscar a descri��o da cr�tica
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                         || ' Arquivo:' || pr_tbarquiv(vr_nrindice);
          -- Envio centralizado de log de erro
          pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic,
                      pr_cdcriticidade => 1,
                      pr_cdmensagem    => vr_cdcritic);
          -- Reinicializar a vari�vel de cr�tica
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
          -- Processar o pr�ximo arquivo
          CONTINUE;
          --
        END IF;

        -- Critica de processo: 219 - INTEGRANDO ARQUIVO
        vr_cdcritic := 219;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                       ||'. Arquivo: ' || pr_tbarquiv(vr_nrindice);
          -- Envio centralizado de log de erro
          pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic,
                      pr_cdcriticidade => 0,
                      pr_cdmensagem    => vr_cdcritic,
                      pr_ind_tipo_log  => 1);

        -- Reinicializar a vari�vel de cr�tica e de controle de primeiro registro
        vr_cdcritic := NULL;
        vr_flgfirst := TRUE;
        vr_arqproce := pr_tbarquiv(vr_nrindice);

        -----------------------------------------------------------------------------------------
        -- Cria um ponto de salvamento, pois caso o programa seja abortado, faz o rollback
        SAVEPOINT falta_tab_convenio;
        -----------------------------------------------------------------------------------------

        -- Percorrer todas as linhas do arquivo a partir da segunda linha
        FOR vr_indlinha IN vr_arquivo.NEXT(vr_arquivo.FIRST)..vr_arquivo.LAST LOOP
          -- Bloco para processamento da linha
          DECLARE
            -- Cursores
            -- Busca informa��es do associado
            CURSOR cr_crapass(pr_nrdconta   crapass.nrdconta%TYPE) IS
              SELECT crapass.dtdemiss
                   , crapass.cdsitdtl
                   , crapass.nrdconta
                   , crapass.nrcpfcgc
                   , crapass.cdagenci
                   , crapass.inpessoa
                   , crapass.cdcooper
                FROM crapass
               WHERE crapass.cdcooper = pr_cdcooper
                 AND crapass.nrdconta = pr_nrdconta;

            CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
                             ,pr_nrdconta IN crapttl.nrdconta%TYPE
                       ,pr_idseqttl IN crapttl.idseqttl%TYPE)IS
              SELECT crapttl.nrcpfcgc
                FROM crapttl
               WHERE crapttl.cdcooper = pr_cdcooper
                 AND crapttl.nrdconta = pr_nrdconta
                 AND crapttl.idseqttl = pr_idseqttl;
	            rw_crapttl cr_crapttl%ROWTYPE;

            -- Buscar informa��es de Transferencia e Duplicacao de Matricula
            CURSOR cr_craptrf(pr_nrdconta  craptrf.nrdconta%TYPE) IS
              SELECT craptrf.nrsconta
                FROM craptrf
               WHERE craptrf.cdcooper = pr_cdcooper
                 AND craptrf.nrdconta = pr_nrdconta
                 AND craptrf.tptransa = 1;

            -- Buscar dados da tabela gen�rica - e deixando o registro em lock para ser atualizado
            CURSOR cr_craptab IS
              SELECT craptab.dstextab
                FROM craptab
               WHERE craptab.cdcooper = pr_cdcooper
                 AND craptab.nmsistem = 'CRED'
                 AND craptab.tptabela = 'GENERI'
                 AND craptab.cdempres = 00
                 AND craptab.cdacesso = 'NUMLOTEBCO'
                 AND craptab.tpregist = 001
                 FOR UPDATE OF craptab.dstextab;
            
            -- Busca da nova conta p�s incorpora��o
            CURSOR cr_craptco(pr_cdcopant crapcop.cdcooper%TYPE
                             ,pr_nrctaant craptco.nrctaant%TYPE) IS
              SELECT nrdconta
                FROM craptco
               WHERE cdcopant = pr_cdcopant 
                 AND nrctaant = pr_nrctaant;               
            
            -- Vari�veis
            vr_dslinha       CONSTANT VARCHAR2(500) := vr_arquivo(vr_indlinha); -- Linha a ser processada
            vr_dstextab      craptab.dstextab%TYPE;
            vr_fgeratco      BOOLEAN;
            vr_inctaint      BOOLEAN;
            vr_aux_cdcooper  NUMBER;
            vr_aux_nrdconta  NUMBER;
            vr_nrsconta      craptrf.nrsconta%TYPE;
            vr_indebcre      craprej.indebcre%TYPE;
            rw_crapass       cr_crapass%ROWTYPE;

          BEGIN
            
            -- Inicializa��es
            vr_cpfremet := 0;

            -- Ler as informa��es do arquivo
            vr_nrseqarq := TO_NUMBER(SUBSTR(vr_dslinha ,250, 6));

            -- Verifica se chegou a ultima linha do arquivo
            IF SUBSTR(vr_dslinha,1,10) = '9999999999' THEN
              -- Inserir registro na CRAPREJ
              BEGIN
                -- Cadastro de rejeitados na integracao - D23
                INSERT INTO craprej(cdcooper
                                   ,dtrefere
                                   ,nrdconta
                                   ,nrseqdig
                                   ,vllanmto)
                            VALUES (pr_cdcooper                                    -- cdcooper
                                   ,vr_dtauxili                                    -- dtrefere
                                   ,999999999                                      -- nrdconta
                                   ,vr_nrseqarq                                    -- nrseqdig
                                   ,(to_number(SUBSTR(vr_dslinha,79,18)) / 100) ); -- vllanmto
              EXCEPTION
                WHEN OTHERS THEN
                  -- Cr�tica: Erro Oracle
                  vr_cdcritic := 1034;
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                                 ' craprej[2]: cdcooper:' || pr_cdcooper ||
                                 ', dtrefere:' || vr_dtauxili ||
                                 ', nrdconta: 999999999, nrseqdig:' || vr_nrseqarq ||
                                 ', vllanmto:' ||(SUBSTR(vr_dslinha,79,18) / 100) ||
                                 '. '|| sqlerrm;
                  -- Envio centralizado de log de erro
                  pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                              pr_dstiplog      => 'E',
                              pr_dscritic      => vr_dscritic,
                              pr_cdcriticidade => 2,
                              pr_cdmensagem    => vr_cdcritic,
                              pr_ind_tipo_log  => 3);

                  --Inclus�o na tabela de erros Oracle - Chamado 789851
                  CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              END;

              -- Se n�o processou registro nenhum
              IF NOT vr_flgfirst THEN
                -- Buscar informa��es da tabela gen�rica
                OPEN  cr_craptab;
                FETCH cr_craptab INTO vr_dstextab;
                -- Se n�o encontrar registro de convenio
                IF cr_craptab%NOTFOUND THEN
                  vr_cdcritic := 472; -- 472 - Falta tabela de convenio
                  -- Buscar a descri��o
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                  -- Envio centralizado de log de erro
                  pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                              pr_dstiplog      => 'E',
                              pr_dscritic      => vr_dscritic,
                              pr_cdcriticidade => 1,
                              pr_cdmensagem    => vr_cdcritic);
                  -- Fecha o cursor antes de finalizar
                  CLOSE cr_craptab;

                  -- Finaliza com fimprg
                  RAISE vr_exc_fimprg;
                END IF;

                -- Atualizar o registro da CRAPTAB
                BEGIN
                  UPDATE craptab
                     SET craptab.dstextab = decode(vr_nrdolote,7019,'7010',to_char(vr_nrdolote+1,'9999'))
                   WHERE CURRENT OF cr_craptab;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Cr�tica: Erro Oracle
                    vr_cdcritic := 1035;
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                   ' craptab: dstextab: se nrdolote=7019 -> 7010, senao -> '|| to_char(vr_nrdolote+1,'9999') || 
                                   ' com nmsistem:CRED, tptabela:GENERI, cdempres:00, cdacesso:NUMLOTEBCO, tpregist:001'     || 
                                   '. '|| sqlerrm;
                    -- Envio centralizado de log de erro
                    pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                                pr_dstiplog      => 'E',
                                pr_dscritic      => vr_dscritic,
                                pr_cdcriticidade => 2,
                                pr_cdmensagem    => vr_cdcritic,
                                pr_ind_tipo_log  => 3);

                    --Inclus�o na tabela de erros Oracle - Chamado 789851
                    CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                END;

                -- Fechar o cursor
                CLOSE cr_craptab;
              END IF;

              -- Sai do Loop do arquivo
              EXIT;

            END IF; -- Linha 9999999999

            -- Ler as informa��es e tratar poss�veis excess�es de leitura
            BEGIN

              vr_cdagearq := to_number(SUBSTR(vr_dslinha,7,4));
              vr_nrcpfemi := to_number(SUBSTR(vr_dslinha,182,14));
              vr_nrdconta := to_number(SUBSTR(vr_dslinha,17,08));
              vr_nrctaint := SUBSTR(vr_dslinha,12,13);
              vr_nrdocmto := to_number(SUBSTR(vr_dslinha,25,6));
              vr_vllanmto := (to_number(SUBSTR(vr_dslinha,31,18)) / 100);
              vr_nrseqarq := to_number(SUBSTR(vr_dslinha,250,6));
              vr_cdpesqbb := SUBSTR(vr_dslinha,121,3)||'-'||SUBSTR(vr_dslinha,124,5)||'-'||SUBSTR(vr_dslinha,142,40);
              vr_cdpeslcm := SUBSTR(vr_dslinha,142,40);
              vr_nmdestin := SUBSTR(vr_dslinha,49,40);      /* nome */
              vr_tpdedocs := to_number(SUBSTR(vr_dslinha,203,1)); /* tipo c, d */
              vr_cdbandoc := to_number(SUBSTR(vr_dslinha,121,3));
              vr_cdcmpdoc := to_number(SUBSTR(vr_dslinha,118,3));
              vr_cdagedoc := to_number(SUBSTR(vr_dslinha,124,4));
              vr_nrctadoc := to_number(SUBSTR(vr_dslinha,129,13));
              vr_dsrelcpf := SUBSTR(vr_dslinha,89,14);     
              -- Leitura do CPF de destino
              vr_cpfdesti := to_number(SUBSTR(vr_dslinha,89,14));

              -- Se o arquivo vem de cooperativa incorporada
              IF vr_flgincorp THEN
                -- Buscar c�digo de conta transferida substituindo
                -- as informa��es provenientes do registro lido
                vr_nrdconta_incorp := NULL;
                OPEN cr_craptco(pr_cdcopant => rw_crapcop_incorp.cdcooper
                               ,pr_nrctaant => vr_nrdconta);
                FETCH cr_craptco
                 INTO vr_nrdconta_incorp;
                CLOSE cr_craptco;
                -- Substituir os caracteres da conta antiga com a conta nova
                -- no campo de conta integra��o
                vr_nrctaint := REPLACE(vr_nrctaint,lpad(vr_nrdconta,length(vr_nrdconta_incorp),'0'),vr_nrdconta_incorp);              
              END IF;
                       
            EXCEPTION
              WHEN OTHERS THEN
                -- Cr�tica: 843 - Funcao com caracteres invalido
                vr_cdcritic := 843;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                               || '. Arquivo:' || pr_tbarquiv(vr_nrindice)
                               || ', Seq:' || to_char(vr_nrseqarq,'999G990');
                -- Envio centralizado de log de erro
                pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                            pr_dstiplog      => 'E',
                            pr_dscritic      => vr_dscritic,
                            pr_cdcriticidade => 2,
                            pr_cdmensagem    => vr_cdcritic,
                            pr_ind_tipo_log  => 3); --erro gerado em others

                --Inclus�o na tabela de erros Oracle - Chamado 789851
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

                -- Cria o registro na tabela gen�rica GNCPDOC - Compensacao Documentos da Central
                -- Observa��o: Usando campos da incorpora��o em caso do arquivo for
                IF vr_flgincorp THEN
                  pc_cria_generico(pr_cdcritic => vr_cdcritic
                                  ,pr_cdagenci => 0
                                  ,pr_nmarquiv => pr_tbarquiv(vr_nrindice)
                                  ,pr_cdagectl => rw_crapcop_incorp.cdagectl
                                  ,pr_nrdconta => vr_nrdconta_incorp
                                  ,pr_dslinha  => vr_dslinha);
                ELSE
                  pc_cria_generico(pr_cdcritic => vr_cdcritic
                                  ,pr_cdagenci => 0
                                  ,pr_nmarquiv => pr_tbarquiv(vr_nrindice)
                                  ,pr_cdagectl => rw_crapcop.cdagectl
                                  ,pr_nrdconta => vr_nrdconta
                                  ,pr_dslinha  => vr_dslinha);
                END IF;                  

                -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
                GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_integra_cooperativa', pr_action => NULL);
                
                -- Inicializa a vari�vel de cr�tica
                vr_cdcritic := 0;
                -- Pr�xima linha
                CONTINUE;
            END;
            -- Neste primeiro momento tratar somente com historico de DOC.
            -- Ha possibilidade de separar por Imp. Renda e TEC conf. prg. 252
            vr_cdhistor := 575;
            -- Vari�vel para guardar criticas do associado
            vr_critiass := 0;

            -- Buscar as informa��es do associado
            OPEN  cr_crapass(nvl(vr_nrdconta_incorp,vr_nrdconta));
            FETCH cr_crapass INTO rw_crapass;
            -- Verifica se o registro foi encontrado e se a data de demiss�o est� nula
            IF cr_crapass%FOUND AND rw_crapass.dtdemiss IS NOT NULL THEN
              vr_critiass := 64; -- 064 - Conta encerrada
            ELSIF cr_crapass%NOTFOUND OR length(to_number(vr_nrctaint)) > 8 THEN
              vr_critiass := 9;  -- 009 - Associado nao cadastrado
            END IF;

            -- Fecha o cursor
            CLOSE cr_crapass;

            -- Verifica se houveram cr�ticas quanto ao associado
            IF NVL(vr_critiass,0) > 0 THEN
              pc_cria_ddc(pr_cdcooper => pr_cdcooper                         -- cdcooper
                         ,pr_cdagenci => vr_cdagearq                         -- cdagenci
                         ,pr_nrdocmto => vr_nrdocmto                         -- nrdocmto
                         ,pr_vldocmto => vr_vllanmto                         -- vldocmto
                         ,pr_nrdconta => nvl(vr_nrdconta_incorp,vr_nrdconta) -- nrdconta
                         ,pr_nmfavore => vr_nmdestin                         -- nmfavore
                         ,pr_nrcpffav => vr_dsrelcpf                         -- nrcpffav
                         ,pr_cdcritic => vr_critiass                         -- cdcritic
                         ,pr_cdbandoc => vr_cdbandoc                         -- cdbandoc
                         ,pr_cdagedoc => vr_cdagedoc                         -- cdagedoc
                         ,pr_nrctadoc => vr_nrctadoc                         -- nrctadoc
                         ,pr_nmemiten => vr_cdpeslcm                         -- nmemiten
                         ,pr_nrcpfemi => vr_nrcpfemi                         -- nrcpfemi
                         ,pr_dslayout => vr_dslinha                          -- dslayout
                         ,pr_cdcmpori => vr_cdcmpori                         -- cdcmpori 
                         ,pr_dsdrowid => vr_dsdrowid);

              -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
              GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_integra_cooperativa', pr_action => NULL);

              -- Se a cr�tica � de conta encerrada desde que n�o seja incorpora��o
              IF vr_critiass = 64 AND NOT vr_flgincorp THEN

                -- Verificar conta integrada
                pc_verifica_conta_integra(pr_out_fgeratco => vr_fgeratco
                                         ,pr_out_inctaint => vr_inctaint
                                         ,pr_out_cdcooper => vr_aux_cdcooper
                                         ,pr_out_nrdconta => vr_aux_nrdconta);

                -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
                GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_integra_cooperativa', pr_action => NULL);

                -- Verificar conta integrada
                IF vr_inctaint THEN
                  -- Verifica se gera lancamento da TCO
                  IF vr_fgeratco THEN
                    -- Cria documento TCO
                    pc_cria_doctos_tco(pr_cdcooper => vr_aux_cdcooper
                                      ,pr_nrdconta => vr_aux_nrdconta
                                      ,pr_nrdctabb => vr_aux_nrdconta
                                      ,pr_dslinha  => vr_dslinha);

                    -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
                    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_integra_cooperativa', pr_action => NULL);
                    
                    -- Eliminar Tabela devolucao DOC da Compensacao.
                    BEGIN
                      DELETE 
                        FROM crapddc 
                       WHERE ROWID = vr_dsdrowid;
                    EXCEPTION
                      WHEN OTHERS THEN
                        -- Cr�tica: Erro Oracle
                        vr_cdcritic := 1037;
                        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' crapddc: com ROWID:'||vr_dsdrowid
                                      ||'. '||SQLERRM;
                        -- Envio centralizado de log de erro
                        pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                                    pr_dstiplog      => 'E',
                                    pr_dscritic      => vr_dscritic,
                                    pr_cdcriticidade => 2,
                                    pr_cdmensagem    => vr_cdcritic,
                                    pr_ind_tipo_log  => 3);

                        --Inclus�o na tabela de erros Oracle - Chamado 789851
                        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                    END;
                  END IF;
                  
                  -- Pr�ximo registro
                  CONTINUE;
                END IF;
              END IF; -- vr_critiass = 64

              -- Verificar indicador conforme o tipo de documento
              vr_indebcre := fn_tipo_documento(vr_tpdedocs);

              -- Inserir dados na CRAPREJ
              BEGIN
                INSERT INTO craprej(dtrefere
                                   ,nrdconta
                                   ,nrdctitg
                                   ,dshistor
                                   ,nrdocmto
                                   ,vllanmto
                                   ,nrseqdig
                                   ,cdpesqbb
                                   ,cdcooper
                                   ,indebcre
                                   ,cdcritic
                                   ,vldaviso)
                            VALUES (vr_dtauxili -- dtrefere
                                   ,nvl(vr_nrdconta_incorp,vr_nrdconta) -- nrdconta
                                   ,LTRIM(GENE0002.fn_mask(TO_NUMBER(vr_nrctaint),'zzzzzz.zzz.zzz.z')) -- nrdctitg
                                   ,vr_nmdestin -- dshistor
                                   ,vr_nrdocmto -- nrdocmto
                                   ,vr_vllanmto -- vllanmto
                                   ,vr_nrseqarq -- nrseqdig
                                   ,vr_cdpesqbb -- cdpesqbb
                                   ,pr_cdcooper -- cdcooper
                                   ,vr_indebcre -- indebcre
                                   ,vr_critiass -- cdcritic
                                   ,TO_NUMBER(vr_dsrelcpf)); -- vldaviso
              EXCEPTION
                WHEN OTHERS THEN
                  -- Cr�tica: Erro Oracle
                  vr_cdcritic := 1034;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                 ' craprej[3]: dtrefere:' || vr_dtauxili ||
                                 ', nrdconta:' || nvl(vr_nrdconta_incorp,vr_nrdconta) ||
                                 ', nrdctitg:' || LTRIM(TO_NUMBER(vr_nrctaint)) ||
                                 ', dshistor:' || vr_nmdestin || ', nrdocmto:' || vr_nrdocmto ||
                                 ', vllanmto:' || vr_vllanmto || ', nrseqdig:' || vr_nrseqarq ||
                                 ', cdpesqbb:' || vr_cdpesqbb || ', cdcooper:' || pr_cdcooper ||
                                 ', indebcre:' || vr_indebcre || ', cdcritic:' || vr_critiass ||
                                 ', vldaviso:' || vr_dsrelcpf ||'. '|| sqlerrm;
                  -- Envio centralizado de log de erro
                  pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                              pr_dstiplog      => 'E',
                              pr_dscritic      => vr_dscritic,
                              pr_cdcriticidade => 2,
                              pr_cdmensagem    => vr_cdcritic,
                              pr_ind_tipo_log  => 3);

                --Inclus�o na tabela de erros Oracle - Chamado 789851
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              END;

              -- Cria o registro na tabela gen�rica GNCPDOC - Compensacao Documentos da Central
              -- Observa��o: Usando campos da incorpora��o em caso do arquivo for
              IF vr_flgincorp THEN
                pc_cria_generico(pr_cdcritic => vr_critiass
                                ,pr_cdagenci => 0
                                ,pr_nmarquiv => pr_tbarquiv(vr_nrindice)
                                ,pr_cdagectl => rw_crapcop_incorp.cdagectl
                                ,pr_nrdconta => vr_nrdconta_incorp
                                ,pr_dslinha  => vr_dslinha);
              ELSE
                pc_cria_generico(pr_cdcritic => vr_critiass
                                ,pr_cdagenci => 0
                                ,pr_nmarquiv => pr_tbarquiv(vr_nrindice)
                                ,pr_cdagectl => rw_crapcop.cdagectl
                                ,pr_nrdconta => vr_nrdconta
                                ,pr_dslinha  => vr_dslinha);
              END IF;                  
              -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
              GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_integra_cooperativa', pr_action => NULL);

              -- Pr�ximo registro
              CONTINUE;

            END IF;  -- vr_critiass <> 0

            -- Verificar o Codigo da situacao do titular.
            IF rw_crapass.cdsitdtl IN (2,4,5,6,7,8)   THEN
              -- Busca informa��es de Transferencia e Duplicacao de Matricula
              OPEN  cr_craptrf(vr_nrdconta);
              FETCH cr_craptrf INTO vr_nrsconta;
              -- Se encontrar informa��o
              IF cr_craptrf%FOUND THEN
                vr_nrdconta := vr_nrsconta;
              END IF;
              -- Fechar o curso
              CLOSE cr_craptrf;
            END IF;

            vr_nrcpfstl:= 0;
            vr_nrcpfttl:= 0;

            IF rw_crapass.inpessoa = 1 THEN
              OPEN cr_crapttl(pr_cdcooper => rw_crapass.cdcooper
                             ,pr_nrdconta => rw_crapass.nrdconta
                             ,pr_idseqttl => 2);

              FETCH cr_crapttl INTO rw_crapttl;

              IF cr_crapttl%FOUND THEN
                vr_nrcpfstl:= rw_crapttl.nrcpfcgc;
              END IF;
              CLOSE cr_crapttl;

              OPEN cr_crapttl(pr_cdcooper => rw_crapass.cdcooper
                             ,pr_nrdconta => rw_crapass.nrdconta
                             ,pr_idseqttl => 3);

              FETCH cr_crapttl INTO rw_crapttl;

              IF cr_crapttl%FOUND THEN
                vr_nrcpfttl:= rw_crapttl.nrcpfcgc;
              END IF;
              CLOSE cr_crapttl;
            END IF;

            -- Verificar os tipos de documentos
            IF vr_tpdedocs IN (4,6,9) OR
               (to_number(SUBSTR(vr_dslinha,105,2)) = 50 AND vr_tpdedocs = 2) THEN
              vr_cpfdesti := to_number(SUBSTR(vr_dslinha,89,14));
              -- Verifica o cpf
              IF NOT ((vr_cpfdesti = rw_crapass.nrcpfcgc)   OR
                      (vr_cpfdesti = vr_nrcpfstl)           OR
                      (vr_cpfdesti = vr_nrcpfttl))          THEN
                vr_cdcritic := 301; -- 301 - DADOS NAO CONFEREM!                
                      
              END IF;
            END IF;

            -- Se o tipo de documento for igual a 5
            IF vr_tpdedocs = 5 THEN
              vr_cpfdesti := to_number(SUBSTR(vr_dslinha,89,14));
              vr_cpfremet := to_number(SUBSTR(vr_dslinha,182,14));

              -- Se os CPFs forem o mesmo
              IF vr_cpfdesti = vr_cpfremet THEN
                -- Verificar o CPF com o do associado
                IF rw_crapass.nrcpfcgc <> vr_cpfdesti  THEN
                  vr_cdcritic := 301;
                END IF;
              ELSE
                --
                IF NOT (((vr_cpfdesti = rw_crapass.nrcpfcgc)    OR
                         (vr_cpfdesti = vr_nrcpfstl))         AND
                        ((vr_cpfremet = rw_crapass.nrcpfcgc)    OR
                         (vr_cpfremet = vr_nrcpfstl)))        THEN
                  vr_cdcritic := 301;
                END IF;
              END IF;

            END IF;

            -- Verificar dado
            IF to_number(SUBSTR(vr_dslinha, 230, 3)) > 0 THEN
                vr_cdcritic := 513;
            END IF;


            -- Verifica se houve cr�tica
            IF NVL(vr_cdcritic,0) > 0 THEN

              -- Se n�o � incorpora��o
              IF NOT vr_flgincorp THEN
                -- Verificar a conta migrada
                pc_verifica_conta_integra(pr_out_fgeratco => vr_fgeratco
                                         ,pr_out_inctaint => vr_inctaint
                                         ,pr_out_cdcooper => vr_aux_cdcooper
                                         ,pr_out_nrdconta => vr_aux_nrdconta);

                -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
                GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_integra_cooperativa', pr_action => NULL);

                -- Verificar conta integrada
                IF vr_inctaint THEN
                  -- Verifica se gera a TCO
                  IF vr_fgeratco THEN
                    -- Cria documento TCO
                    pc_cria_doctos_tco(pr_cdcooper => vr_aux_cdcooper
                                      ,pr_nrdconta => vr_aux_nrdconta
                                      ,pr_nrdctabb => vr_aux_nrdconta
                                      ,pr_dslinha  => vr_dslinha);

                    -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
                    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_integra_cooperativa', pr_action => NULL);
                  END IF;
                  -- Pr�ximo registro
                  CONTINUE;
                END IF;
              END IF;  

              -- Verificar indicador conforme o tipo de documento
              vr_indebcre := fn_tipo_documento(vr_tpdedocs);

              -- Inserir dados na CRAPREJ
              BEGIN
                INSERT INTO craprej(dtrefere
                                   ,nrdconta
                                   ,nrdctitg
                                   ,nrdocmto
                                   ,vllanmto
                                   ,nrseqdig
                                   ,cdcritic
                                   ,cdpesqbb
                                   ,cdcooper
                                   ,indebcre
                                   ,dshistor
                                   ,vldaviso)
                            VALUES (vr_dtauxili -- dtrefere
                                   ,nvl(vr_nrdconta_incorp,vr_nrdconta) -- nrdconta
                                   ,LTRIM(GENE0002.fn_mask(TO_NUMBER(vr_nrctaint),'zzzzzz.zzz.zzz.z')) -- nrdctitg
                                   ,vr_nrdocmto -- nrdocmto
                                   ,vr_vllanmto -- vllanmto
                                   ,vr_nrseqarq -- nrseqdig
                                   ,vr_cdcritic -- cdcritic
                                   ,vr_cdpesqbb -- cdpesqbb
                                   ,pr_cdcooper -- cdcooper
                                   ,vr_indebcre -- indebcre
                                   -- dshistor
                                   ,DECODE(vr_cdcritic
                                              ,301, RPAD(vr_nmdestin,40,' ')||
                                                    'CPF Remetente '|| vr_cpfremet ||
                                                    ' CPF Destinatario '|| vr_cpfdesti
                                                  , vr_nmdestin )
                                   ,TO_NUMBER(vr_dsrelcpf)); -- vldaviso
              EXCEPTION
                WHEN OTHERS THEN
                  -- Cr�tica: Erro Oracle
                  vr_cdcritic := 1034;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                 ' craprej[4]' || '. dtrefere:' || vr_dtauxili ||
                                 ', nrdconta:' || nvl(vr_nrdconta_incorp,vr_nrdconta) ||
                                 ', nrdctitg:' || LTRIM(TO_NUMBER(vr_nrctaint)) ||
                                 ', nrdocmto:' || vr_nrdocmto || ', vllanmto:' || vr_vllanmto || 
                                 ', nrseqdig:' || vr_nrseqarq || ', cdcritic:' || vr_cdcritic || 
                                 ', cdpesqbb:' || vr_cdpesqbb || ', cdcooper:' || pr_cdcooper || 
                                 ', indebcre:' || vr_indebcre ||
                                 ', dshistor:se vr_cdcritic=301 -> '||RPAD(vr_nmdestin,40,' ')||
                                 ' CPF Remetente '|| vr_cpfremet ||' CPF Destinatario '|| vr_cpfdesti ||
                                 ' senao -> '||vr_nmdestin ||', vldaviso:'|| TO_NUMBER(vr_dsrelcpf)   ||
                                 '. '|| sqlerrm;
                  -- Envio centralizado de log de erro
                  pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                              pr_dstiplog      => 'E',
                              pr_dscritic      => vr_dscritic,
                              pr_cdcriticidade => 2,
                              pr_cdmensagem    => vr_cdcritic,
                              pr_ind_tipo_log  => 3);

                --Inclus�o na tabela de erros Oracle - Chamado 789851
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              END;
            -- Criar Tabela devolucao DOC da Compensacao.
            pc_cria_ddc(pr_cdcooper => pr_cdcooper   -- cdcooper (CECRED)-- Alterado para cooperativa do parametro
                       ,pr_cdagenci => vr_cdagearq   -- cdagenci
                       ,pr_nrdocmto => vr_nrdocmto   -- nrdocmto
                       ,pr_vldocmto => vr_vllanmto   -- vldocmto
                       ,pr_nrdconta => nvl(vr_nrdconta_incorp,vr_nrdconta)   -- nrdconta
                       ,pr_nmfavore => vr_nmdestin   -- nmfavore
                       ,pr_nrcpffav => vr_cpfdesti   -- nrcpffav
                       ,pr_cdcritic => vr_cdcritic   -- cdcritic
                       ,pr_cdbandoc => vr_cdbandoc   -- cdbandoc
                       ,pr_cdagedoc => vr_cdagedoc   -- cdagedoc
                       ,pr_nrctadoc => vr_nrctadoc   -- nrctadoc
                       ,pr_nmemiten => vr_cdpeslcm   -- nmemiten
                       ,pr_nrcpfemi => vr_nrcpfemi   -- nrcpfemi
                       ,pr_dslayout => vr_dslinha    -- dslayout
                       ,pr_cdcmpori => vr_cdcmpori   -- cdcmpori
                       ,pr_dsdrowid => vr_dsdrowid);

            -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
            GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_integra_cooperativa', pr_action => NULL);

            -- Cria o registro na tabela gen�rica GNCPDOC - Compensacao Documentos da Central
            -- Observa��o: Usando campos da incorpora��o em caso do arquivo for
            IF vr_flgincorp THEN
              pc_cria_generico(pr_cdcritic => vr_cdcritic
                              ,pr_cdagenci => rw_crapass.cdagenci
                              ,pr_nmarquiv => pr_tbarquiv(vr_nrindice)
                              ,pr_cdagectl => rw_crapcop_incorp.cdagectl
                              ,pr_nrdconta => vr_nrdconta_incorp
                              ,pr_dslinha  => vr_dslinha);
            ELSE
              pc_cria_generico(pr_cdcritic => vr_cdcritic
                              ,pr_cdagenci => rw_crapass.cdagenci
                              ,pr_nmarquiv => pr_tbarquiv(vr_nrindice)
                              ,pr_cdagectl => rw_crapcop.cdagectl
                              ,pr_nrdconta => vr_nrdconta
                              ,pr_dslinha  => vr_dslinha);
            END IF;  

            -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
            GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_integra_cooperativa', pr_action => NULL);

            -- Limpar as criticas
            vr_cdcritic := 0;

            -- Pr�ximo registro
            CONTINUE;

          END IF;
                
          -- Se n�o � incorpora��o
          IF NOT vr_flgincorp THEN
            -- Limpar as vari�veis
            vr_inctaint     := NULL;
            vr_aux_cdcooper := NULL;
            vr_aux_nrdconta := NULL;

            -- Verificar a conta migrada
            pc_verifica_conta_integra(pr_out_fgeratco => vr_fgeratco
                                     ,pr_out_inctaint => vr_inctaint
                                     ,pr_out_cdcooper => vr_aux_cdcooper
                                     ,pr_out_nrdconta => vr_aux_nrdconta);

            -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
            GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_integra_cooperativa', pr_action => NULL);

            -- Valida a conta migrada
            IF vr_inctaint THEN
                    
              IF vr_fgeratco THEN
                -- Criar o registro do doc
                pc_cria_doctos_tco(vr_aux_cdcooper
                                  ,vr_aux_nrdconta
                                  ,vr_aux_nrdconta
                                  ,vr_dslinha);
              END IF;
                    
              -- Pr�ximo registro
              CONTINUE;
            END IF;
          END IF;  

          -- Verifica se � o primeiro registro a chegar a este ponto
          IF vr_flgfirst THEN

            -- Buscar informa��es da tabela gen�rica
            OPEN  cr_craptab;
            FETCH cr_craptab INTO vr_dstextab;
            -- Se n�o encontrar registro de convenio
            IF cr_craptab%NOTFOUND THEN
              vr_cdcritic := 472; -- 472 - Falta tabela de convenio
              -- Buscar a descri��o
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                             ||' Arquivo:' || pr_tbarquiv(vr_nrindice)
                             ||', Seq: ' || to_char(vr_nrseqarq,'999g990');
              -- Envio centralizado de log de erro
              pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                          pr_dstiplog      => 'E',
                          pr_dscritic      => vr_dscritic,
                          pr_cdcriticidade => 1,
                          pr_cdmensagem    => vr_cdcritic);

              -- Fecha o cursor antes de abortar o procedimento
              CLOSE cr_craptab;

              -------------------------------------------------------------
              -- Neste caso desfaz as altera��es e sair da procedure
              ROLLBACK TO SAVEPOINT falta_tab_convenio;
              RETURN;
              -------------------------------------------------------------
            END IF;

            -- Fecha o cursor
            CLOSE cr_craptab;

            -- Definir o n�mero do lote
            vr_nrdolote := to_number(vr_dstextab);

            LOOP

              -- buscar o registro de capa de lote
              OPEN  cr_craplot(pr_cdcooper
                              ,vr_dtmvtolt
                              ,vr_cdagenci
                              ,rw_crapcop.cdbcoctl
                              ,vr_nrdolote);
              FETCH cr_craplot INTO rw_craplot;

              -- Verifica se encontrou registro
              IF cr_craplot%FOUND THEN
                vr_nrdolote := vr_nrdolote + 1;
              ELSE
                -- fecha o cursor e sai do loop
                CLOSE cr_craplot;
                EXIT;
              END IF;

              -- Fechar o cursor para a proxima itera��o
              CLOSE cr_craplot;

            END LOOP;

            BEGIN

              -- Limpa o registro para guardar os dados inseridos;
              rw_craplot := NULL;

              -- insere o novo registro de lote
              INSERT INTO craplot(dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,tplotmov
                                 ,cdcooper)
                           VALUES(vr_dtmvtolt   -- dtmvtolt
                                 ,vr_cdagenci   -- cdagenci
                                 ,rw_crapcop.cdbcoctl -- cdbccxlt
                                 ,vr_nrdolote   -- nrdolote
                                 ,vr_tplotmov   -- tplotmov
                                 ,pr_cdcooper)  -- cdcooper
                          RETURNING ROWID INTO rw_craplot.dsrowid;

              -- Guardar os dados inseridos no registro
              rw_craplot.dtmvtolt := vr_dtmvtolt;
              rw_craplot.cdagenci := vr_cdagenci;
              rw_craplot.cdbccxlt := rw_crapcop.cdbcoctl;
              rw_craplot.nrdolote := vr_nrdolote;
            EXCEPTION
              WHEN OTHERS THEN
                -- Cr�tica: Erro Oracle
                vr_cdcritic := 1034;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                               ' craplot[2]: dtmvtolt:' || vr_dtmvtolt ||
                               ', cdagenci:' || vr_cdagenci || ', cdbccxlt:' || rw_crapcop.cdbcoctl ||
                               ', nrdolote:' || vr_nrdolote || ', tplotmov:' || vr_tplotmov         ||
                               ', cdcooper:' || pr_cdcooper || '. '||sqlerrm;
                -- Envio centralizado de log de erro
                pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                            pr_dstiplog      => 'E',
                            pr_dscritic      => vr_dscritic,
                            pr_cdcriticidade => 2,
                            pr_cdmensagem    => vr_cdcritic,
                            pr_ind_tipo_log  => 3);

              --Inclus�o na tabela de erros Oracle - Chamado 789851
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            END;

            -- Indica que o pr�ximo registro n�o � o primeiro
            vr_flgfirst := FALSE;

          ELSE --  se n�o for o primeiro

            -- buscar o registro de capa de lote
            OPEN  cr_craplot(pr_cdcooper
                            ,vr_dtmvtolt
                            ,vr_cdagenci
                            ,rw_crapcop.cdbcoctl
                            ,vr_nrdolote);
            FETCH cr_craplot INTO rw_craplot;

            -- Se n�o encontrar o registro
            IF cr_craplot%NOTFOUND THEN
              vr_cdcritic := 60; -- 060 - Lote inexistente
              -- Buscar a descri��o
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                            || ' Arquivo:' || pr_tbarquiv(vr_nrindice)
                            || ', Lote:'    || vr_nrdolote
                            || ', Seq:'     || to_char(vr_nrseqarq,'999g990');
              -- Envio centralizado de log de erro
              pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                          pr_dstiplog      => 'E',
                          pr_dscritic      => vr_dscritic,
                          pr_cdcriticidade => 1,
                          pr_cdmensagem    => vr_cdcritic);

              -- Fecha o cursor antes de abortar o procedimento
              CLOSE cr_craplot;

              -------------------------------------------------------------
              -- Neste caso desfaz as altera��es e sair da procedure
              ROLLBACK TO SAVEPOINT falta_tab_convenio;
              RETURN;
              -------------------------------------------------------------
            END IF;

            CLOSE cr_craplot;

          END IF; -- vr_flgfirst

          LOOP
            -- buscar o registro de lan�amento
            OPEN  cr_craplcm(pr_cdcooper         -- pr_cdcooper
                            ,vr_dtmvtolt         -- pr_dtmvtolt
                            ,vr_cdagenci         -- pr_cdagenci
                            ,rw_crapcop.cdbcoctl -- pr_cdbccxlt
                            ,vr_nrdolote         -- pr_nrdolote
                            ,nvl(vr_nrdconta_incorp,vr_nrdconta) -- pr_nrdconta
                            ,vr_nrdocmto);       -- pr_nrdocmto
            FETCH cr_craplcm INTO vr_nrdummy;

            -- Verifica se encontrou registro
            IF cr_craplcm%FOUND THEN
              vr_nrdocmto := vr_nrdocmto + 1000000;
            ELSE
              -- fecha o cursor e sai do loop
              CLOSE cr_craplcm;
              EXIT;
            END IF;

            -- Fechar o cursor para a proxima itera��o
            CLOSE cr_craplcm;
          END LOOP;

          BEGIN
            -- Inserir o lan�amento
            INSERT INTO craplcm(cdcooper
                               ,dtmvtolt
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
                               ,cdpesqbb
                               ,cdbanchq
                               ,cdcmpchq
                               ,cdagechq
                               ,nrctachq
                               ,sqlotchq)
                         VALUES(pr_cdcooper          -- cdcooper
                               ,rw_craplot.dtmvtolt  -- dtmvtolt
                               ,rw_craplot.cdagenci  -- cdagenci
                               ,rw_craplot.cdbccxlt  -- cdbccxlt
                               ,rw_craplot.nrdolote  -- nrdolote
                               ,nvl(vr_nrdconta_incorp,vr_nrdconta)          -- nrdconta
                               ,nvl(vr_nrdconta_incorp,vr_nrdconta)          -- nrdctabb
                               ,GENE0002.fn_mask(nvl(vr_nrdconta_incorp,vr_nrdconta),'zzzzzz.zzz.zzz.z') -- nrdctitg
                               ,vr_nrdocmto          -- nrdocmto
                               ,vr_cdhistor          -- cdhistor
                               ,vr_vllanmto          -- vllanmto
                               ,vr_nrseqarq          -- nrseqdig
                               ,vr_cdpeslcm          -- cdpesqbb
                               ,vr_cdbandoc          -- cdbanchq
                               ,vr_cdcmpdoc          -- cdcmpchq
                               ,vr_cdagedoc          -- cdagechq
                               ,vr_nrctadoc          -- nrctachq
                               ,vr_nrseqarq );       -- sqlotchq
          EXCEPTION
            WHEN OTHERS THEN
              -- Cr�tica: Erro Oracle
              vr_cdcritic := 1034;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                             ' craplcm [2]: cdcooper: '||pr_cdcooper ||
                             ', dtmvtolt: '|| rw_craplot.dtmvtolt ||
                             ', cdagenci: '|| rw_craplot.cdagenci ||
                             ', cdbccxlt: '|| rw_craplot.cdbccxlt ||
                             ', nrdolote: '|| rw_craplot.nrdolote ||
                             ', nrdconta: '|| nvl(vr_nrdconta_incorp,vr_nrdconta) ||
                             ', nrdctabb: '|| nvl(vr_nrdconta_incorp,vr_nrdconta) ||
                             ', nrdctitg: '|| nvl(vr_nrdconta_incorp,vr_nrdconta) ||
                             ', nrdocmto: '|| vr_nrdocmto ||
                             ', cdhistor: '|| vr_cdhistor ||
                             ', vllanmto: '|| vr_vllanmto ||
                             ', nrseqdig: '|| vr_nrseqarq ||
                             ', cdpesqbb: '|| vr_cdpeslcm ||
                             ', cdbanchq: '|| vr_cdbandoc ||
                             ', cdcmpchq: '|| vr_cdcmpdoc ||
                             ', cdagechq: '|| vr_cdagedoc ||
                             ', nrctachq: '|| vr_nrctadoc ||
                             ', sqlotchq: '|| vr_nrseqarq ||'. '|| sqlerrm;
            -- Envio centralizado de log de erro
            pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                        pr_dstiplog      => 'E',
                        pr_dscritic      => vr_dscritic,
                        pr_cdcriticidade => 2,
                        pr_cdmensagem    => vr_cdcritic,
                        pr_ind_tipo_log  => 3);

            --Inclus�o na tabela de erros Oracle - Chamado 789851
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          END;

          BEGIN
            -- Atualizar dados da CRAPLOT
            UPDATE CRAPLOT
               SET craplot.qtinfoln = NVL(craplot.qtinfoln,0) + 1
                 , craplot.qtcompln = NVL(craplot.qtcompln,0) + 1
                 , craplot.vlinfocr = NVL(craplot.vlinfocr,0) + vr_vllanmto
                 , craplot.vlcompcr = NVL(craplot.vlcompcr,0) + vr_vllanmto
                 , craplot.nrseqdig = vr_nrseqarq
             WHERE craplot.rowid    = rw_craplot.dsrowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Cr�tica: Erro Oracle
              vr_cdcritic := 1035;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                             ' craplot[2]. qtinfoln: + 1' ||
                             ', qtcompln: + 1' ||
                             ', vlinfocr: + '  || vr_vllanmto ||
                             ', vlcompcr: + '  || vr_vllanmto ||
                             ', nrseqdig:'     || vr_nrseqarq ||
                             ' com rowid:'     || rw_craplot.dsrowid ||'. '|| sqlerrm;
              -- Envio centralizado de log de erro
              pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                          pr_dstiplog      => 'E',
                          pr_dscritic      => vr_dscritic,
                          pr_cdcriticidade => 2,
                          pr_cdmensagem    => vr_cdcritic,
                          pr_ind_tipo_log  => 3);

            --Inclus�o na tabela de erros Oracle - Chamado 789851
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          END;

          -- Totalizadores
          vr_qtcompln := NVL(vr_qtcompln,0) + 1;
          vr_vlcompcr := NVL(vr_vlcompcr,0) + vr_vllanmto;

          -- Observa��o: Usando campos da incorpora��o em caso do arquivo for
          IF vr_flgincorp THEN
            pc_cria_generico(pr_cdcritic => 0
                            ,pr_cdagenci => rw_crapass.cdagenci
                            ,pr_nmarquiv => pr_tbarquiv(vr_nrindice)
                            ,pr_cdagectl => rw_crapcop_incorp.cdagectl
                            ,pr_nrdconta => vr_nrdconta_incorp
                            ,pr_dslinha  => vr_dslinha);
          ELSE
            pc_cria_generico(pr_cdcritic => 0
                            ,pr_cdagenci => rw_crapass.cdagenci
                            ,pr_nmarquiv => pr_tbarquiv(vr_nrindice)
                            ,pr_cdagectl => rw_crapcop.cdagectl
                            ,pr_nrdconta => vr_nrdconta
                            ,pr_dslinha  => vr_dslinha);
          END IF;                 
          -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
          GENE0001.pc_set_modulo(pr_module => 'PC_CRPS534.pc_integra_cooperativa', pr_action => NULL);

            -- Verificar hist�rico
            IF vr_cdcritic = 301 THEN
              vr_dshistor := RPAD(vr_nmdestin,40,' ')||
                                'CPF Remetente '|| vr_cpfremet ||
                                ' CPF Destinatario '|| vr_cpfdesti;
            ELSE
              vr_dshistor := vr_nmdestin;
            END IF;

            -- Verificar indicador conforme o tipo de documento
            vr_indebcre := fn_tipo_documento(vr_tpdedocs);
                
            BEGIN
              -- Cria no craprej para Listar as Informacoes do DOC
              INSERT INTO craprej(cdcritic
                                 ,nrdconta
                                 ,vllanmto
                                 ,cdpesqbb
                                 ,dshistor
                                 ,nrseqdig
                                 ,nrdocmto
                                 ,indebcre
                                 ,dtrefere
                                 ,vldaviso
                                 ,cdcooper
                                 ,nrdctitg)
                          VALUES (0         -- cdcritic
                                 ,nvl(vr_nrdconta_incorp,vr_nrdconta) -- nrdconta
                                 ,vr_vllanmto -- vllanmto
                                 ,vr_cdpesqbb -- cdpesqbb
                                 ,vr_dshistor -- dshistor
                                 ,vr_nrseqarq -- nrseqdig
                                 ,vr_nrdocmto -- nrdocmto
                                 ,vr_indebcre -- indebcre
                                 ,vr_dtauxili -- dtrefere
                                 ,to_number(vr_dsrelcpf) -- vldaviso
                                 ,pr_cdcooper -- cdcooper
                                 ,LTRIM(GENE0002.fn_mask(TO_NUMBER(vr_nrctaint),'zzzzzz.zzz.zzz.z'))); -- nrdctitg
            EXCEPTION
              WHEN OTHERS THEN
                -- Cr�tica: Erro Oracle
                vr_cdcritic := 1034;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                               ' craprej[5]: cdcritic:0' || 
                               ', nrdconta:' || nvl(vr_nrdconta_incorp,vr_nrdconta)         ||
                               ', vllanmto:' || vr_vllanmto || ', cdpesqbb:' || vr_cdpesqbb ||
                               ', dshistor:' || vr_dshistor || ', nrseqdig:' || vr_nrseqarq || 
                               ', nrdocmto:' || vr_nrdocmto || ', indebcre:' || vr_indebcre || 
                               ', dtrefere:' || vr_dtauxili || ', vldaviso:' || to_number(vr_dsrelcpf) || 
                               ', cdcooper:' || pr_cdcooper ||
                               ', nrdctitg:' || LTRIM(TO_NUMBER(vr_nrctaint)) ||
                               '. '||sqlerrm;
                -- Envio centralizado de log de erro
                pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                            pr_dstiplog      => 'E',
                            pr_dscritic      => vr_dscritic,
                            pr_cdcriticidade => 2,
                            pr_cdmensagem    => vr_cdcritic,
                            pr_ind_tipo_log  => 3);

              --Inclus�o na tabela de erros Oracle - Chamado 789851
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            END;
          END;

        END LOOP;  -- Linhas do arquivo

        -- Desde que n�o seja incorpora��o
        IF NOT vr_flgincorp THEN
          -- Se for a cooperativa 1 ou 2
          IF pr_cdcooper IN (1,2) THEN
            -- Chama a rotina para processar os dados relacionados aos TCO
            pc_processamento_tco(pr_nmarquiv => pr_tbarquiv(vr_nrindice));
          END IF;
        END IF;

        -- Move o arquivo lido para o diret�rio salvar 
        gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_dsdirarq||pr_tbarquiv(vr_nrindice)||' '||vr_dsdireto||'/salvar 2> /dev/null'
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_des_saida);

        -- Se retornar uma indica��o de erro
        IF NVL(vr_typ_saida,' ') = 'ERR' THEN
          vr_cdcritic := 1054; -- Erro pc_OScommand_Shell
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_des_saida;
          -- Envio centralizado de log de erro
          pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic,
                      pr_cdcriticidade => 1,
                      pr_cdmensagem    => vr_cdcritic);
        ELSE
          -- Efetuar grava��o a cada arquivo processo movido a salvar
          COMMIT;     
        END IF;
            
      END IF;

  /*** GERA��O DO RELAT�RIO COM OS DADOS PROCESSADOS ***/
  -- Bloco respons�vel pela estrutura��o do XML para gera��o do relat�rio
  DECLARE

    -- CURSORES
    -- Cursor para buscar os dados para o relat�rio
    CURSOR cr_craprej(pr_cdcritic  IN NUMBER) IS
          SELECT craprej.nrdconta
               , craprej.cdcritic
               , craprej.vllanmto
               , craprej.nrdctitg
               , craprej.indebcre
               , craprej.cdpesqbb
               , craprej.dshistor
               , craprej.nrdocmto
               , craprej.vldaviso
               , craprej.nrseqdig
            FROM craprej
           WHERE craprej.cdcooper = pr_cdcooper
             AND craprej.dtrefere = vr_dtauxili
             AND (craprej.cdcritic = pr_cdcritic OR
                    pr_cdcritic = 0)
           ORDER BY craprej.nrdconta
                  , craprej.cdpesqbb
                  , craprej.dshistor
                  , craprej.vllanmto DESC;

    -- Busca contas transferidas entre cooperativas
    CURSOR cr_craptco(pr_nrdconta   craptco.nrdconta%TYPE) IS
      SELECT 1
        FROM craptco
       WHERE craptco.cdcopant = pr_cdcooper
         AND craptco.nrctaant = pr_nrdconta
         AND craptco.tpctatrf = 1
         AND craptco.flgativo = 1; -- TRUE.

    -- VARI�VEIS
    vr_clobxml     CLOB;
    vr_clobcri     CLOB;

    vr_des_erro    VARCHAR2(4000);
    vr_stsnrcal    BOOLEAN;
    vr_inpessoa    NUMBER;
    vr_dspathcop   VARCHAR2(80);
    vr_nmrelato    VARCHAR2(80);
    -- Informa��es envio de e-mail
    vr_dsmailcop   crapprm.dstexprm%TYPE;
    vr_dsassmail   VARCHAR2(100);
    vr_dscormail   VARCHAR2(2000);
    -- Totalizadores
    vr_qtregrej    NUMBER := 0;
    vr_vlregrej    NUMBER := 0;
    vr_qtregint     NUMBER := 0;
    vr_vlregint    NUMBER := 0;
    vr_vlregrec     NUMBER := 0;

    -- Subrotina para escrever texto na vari�vel CLOB do XML
    PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                             ,pr_desdados IN VARCHAR2) IS
    BEGIN
      dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
    END;

  BEGIN

    -- Inicializar as vari�veis
    vr_qtregrec := 0;
    vr_qtregint := 0;
    vr_qtregrej := 0;
    vr_vlregrec := 0;
    vr_vlregint := 0;
    vr_vlregrej := 0;
    vr_cdcritic := 0;
    vr_flgfirst := TRUE;

    -- Preparar o CLOB para armazenar as infos do arquivo
    dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
    pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?>'||chr(10)||
                               '<crps527 dsarquiv="integra/'||pr_tbarquiv(vr_nrindice)||'" '||
                               '  dtrefere="'||to_char(vr_dtmvtolt,'DD/MM/YYYY')||'" '||
                               '  cdagenci="'||vr_cdagenci||'"'            ||
                               '  cdbccxlt="'||rw_crapcop.cdbcoctl||'" '   ||
                               '  nrdolote="'||to_char(vr_nrdolote,'FM999G999G999')||'" '           ||
                               '  tplotmov="'||to_char(vr_tplotmov,'FM00')||'" >'||chr(10));

    -- Preparar o CLOB para armazenar as infos do arquivo
    dbms_lob.createtemporary(vr_clobcri, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_clobcri, dbms_lob.lob_readwrite);

    -- Percorre as informa��es guardadas na mem�ria para montar o XML
    FOR rw_craprej IN cr_craprej( 0 ) LOOP -- Passa zero para desconsiderar o filtro de cr�tica

      -- Verifica o numero da conta
      IF rw_craprej.nrdconta < 999999999  THEN
        -- Inicializa as vari�veis de cr�tica e observa��o
        vr_dscritic := NULL;
        vr_dsobserv := NULL;
        -- Se o cadastro foi feito com cr�tica
        IF rw_craprej.cdcritic > 0 THEN
          -- Seta a flag de rejeitado
          vr_flgrejei := TRUE;
          -- Guarda o c�digo da cr�tica
          vr_cdcritic := rw_craprej.cdcritic;
          -- Verifica se o c�digo da cr�tica � 999, se n�o for busca a descri��o
          IF vr_cdcritic = 999 THEN
            vr_dscritic := 'Associado VIACREDI';
          ELSE
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;

          -- Atualiza totalizadores...
          vr_qtregrej := vr_qtregrej + 1;
          vr_vlregrej := vr_vlregrej + NVL(rw_craprej.vllanmto,0);

          -- Corta a string no tamanho maximo e retirando o c�digo da critica da mesma
          vr_dscritic := SUBSTR(vr_dscritic, 7, 59);

          -- Caso esteja dentro da lista abaixo
          IF vr_cdcritic IN (9,64,301) THEN
            pc_escreve_clob(vr_clobcri,'50' || TO_CHAR(vr_dtmvtolt,'DDMMRR') || ',' || TO_CHAR(vr_dtmvtolt,'DDMMRR') ||
                                       ',1455,4894,' || TO_CHAR(rw_craprej.vllanmto,'fm9999999990d00','NLS_NUMERIC_CHARACTERS=.,') ||
                                       ',157,"DOC NAO INTEGRADO NA CONTA DO COOPERADO DEVIDO INCONSISTENCIA DE DADOS (CONFORME CRITICA RELATORIO 527)"' || chr(10));
          END IF;

        END IF;

        -- Verificar se � um CPF ou CNPJ e formatar o mesmo
        IF length(rw_craprej.vldaviso) > 11 THEN
          -- formata e guarda o CNPJ
          vr_dsrelcpf := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_craprej.vldaviso
                                                  ,pr_inpessoa => 2);
        ELSE
          -- Rotina para validar a informa��o de CPF ou CNPJ
          gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => rw_craprej.vldaviso
                                     ,pr_stsnrcal => vr_stsnrcal
                                     ,pr_inpessoa => vr_inpessoa);

          -- Se validou
          IF vr_stsnrcal THEN
            -- CPF
            vr_dsrelcpf := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_craprej.vldaviso
                                                    ,pr_inpessoa => vr_inpessoa);
          END IF;

        END IF;

        -- Se h� critica dif TCO
        IF vr_cdcritic <> 999 THEN
          -- Para arquivo de incorpora��o
		  IF  rw_crapcop_incorp.cdcooper IS NOT NULL
          AND pr_tbarquiv(vr_nrindice) LIKE '3'|| TO_CHAR(rw_crapcop_incorp.cdagectl,'FM0009') || '%.RET' THEN

			-- Adicionar a descri��o cfme coop integrada
				CASE rw_crapcop_incorp.cdcooper
					WHEN 4  THEN 
						vr_dsobserv := 'Ass. Concredi';
					WHEN 15 THEN
						vr_dsobserv := 'Ass. Credimilsul';  
					WHEN 17 THEN
						vr_dsobserv := 'Ass. Transulcred';
				END CASE;
          
		  -- PAra transfer�ncias entre Cooperativas
          ELSIF pr_cdcooper IN (1,2) THEN
            -- Busca informa��es de contas transferidas
            OPEN  cr_craptco(rw_craprej.nrdconta);
            FETCH cr_craptco INTO vr_nrdummy;
            -- Se encontrar registros
            IF cr_craptco%FOUND THEN
              IF pr_cdcooper = 2 THEN
                vr_dsobserv := 'Ass. VIACREDI';
              ELSE
                vr_dsobserv := 'Ass. ALTOVALE';
              END IF;
            END IF;

            CLOSE cr_craptco;
          END IF;            
        END IF;

        -- Montar o XML
        pc_escreve_clob(vr_clobxml,'  <lancto> '||chr(10)||
                                   '    <nrdctitg>'|| TRIM(rw_craprej.nrdctitg) ||'</nrdctitg>'||chr(10)||
                                   '    <dshistor>'|| GENE0007.fn_caract_controle(substr(rw_craprej.dshistor,0,24)) ||'</dshistor>'||chr(10)||
                                   '    <indebcre>'|| rw_craprej.indebcre ||'</indebcre>'||chr(10)||
                                   '    <nrdocmto>'|| to_char(rw_craprej.nrdocmto,'FM999G999G999') ||'</nrdocmto>'||chr(10)||
                                   '    <cdpesqbb>'|| GENE0007.fn_caract_controle(substr(rw_craprej.cdpesqbb,0,35)) ||'</cdpesqbb>'||chr(10)||
                                   '    <vllanmto>'|| to_char(rw_craprej.vllanmto,'FM999G999G999G990D00') ||'</vllanmto>'||chr(10)||
                                   '    <dscritic>'|| substr(vr_dscritic,0,24)||'</dscritic>'||chr(10)||
                                   '    <dsobserv>'|| substr(vr_dsobserv,0,24)||'</dsobserv>'||chr(10)||
                                   '    <dscpfcgc>'||     vr_dsrelcpf     ||'</dscpfcgc>'||chr(10));

        -- Verifica se h� hist�rico
        IF TRIM(substr(rw_craprej.dshistor,40,20)) IS NOT NULL THEN
          pc_escreve_clob(vr_clobxml,'    <dsinform>'|| substr(rw_craprej.dshistor,41,60) ||'</dsinform>'||chr(10));
        ELSE
          pc_escreve_clob(vr_clobxml,'    <dsinform></dsinform>'||chr(10));
        END IF;

        -- Fecha o registro de lan�amento
        pc_escreve_clob(vr_clobxml,'  </lancto>');

      ELSE
        -- Totais
        vr_qtregrec := (rw_craprej.nrseqdig - 2);
        vr_qtregint := vr_qtcompln;
        vr_vlregrec := rw_craprej.vllanmto;
        vr_vlregint := vr_vlcompcr;

        -- Montar o total
        pc_escreve_clob(vr_clobxml,'  <total> '||chr(10)||
                                   '    <qtregrec>'||to_char(vr_qtregrec,'FM9G999G999G999G990')||'</qtregrec>'||chr(10)||
                                   '    <qtregint>'||to_char(vr_qtregint,'FM9G999G999G999G990')||'</qtregint>'||chr(10)||
                                   '    <qtregrej>'||to_char(vr_qtregrej,'FM9G999G999G999G990')||'</qtregrej>'||chr(10)||
                                   '    <vlregrec>'||to_char(vr_vlregrec,'FM9G999G999G999G990D00')||'</vlregrec>'||chr(10)||
                                   '    <vlregint>'||to_char(vr_vlregint,'FM9G999G999G999G990D00')||'</vlregint>'||chr(10)||
                                   '    <vlregrej>'||to_char(vr_vlregrej,'FM9G999G999G999G990D00')||'</vlregrej>'||chr(10)||
                                   '  </total> ');
      END IF;
    END LOOP;

    -- Fecha a tag geral
    pc_escreve_clob(vr_clobxml,chr(10)||'</crps527>');

    -- Verifica a flag de rejeitado
    IF vr_flgrejei THEN
      vr_cdcritic := 191; -- 191 - ARQUIVO INTEGRADO COM REJEITADOS
    ELSE
      vr_cdcritic := 190; -- 190 - ARQUIVO INTEGRADO COM SUCESSO
    END IF;

    -- Buscar a descri��o
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                   || '. Arquivo:' || pr_tbarquiv(vr_nrindice);

    -- Envio centralizado de log de erro
    pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                pr_dstiplog      => 'E',
                pr_dscritic      => vr_dscritic,
                pr_cdcriticidade => 1,
                pr_cdmensagem    => vr_cdcritic);
    -- Limpa as criticas
    vr_cdcritic := 0;

    -- Limpa a variavel de controle de c�pia do relat�rio
    vr_dspathcop := NULL;

    -- Verifica a tela
    IF pr_nmtelant = 'COMPEFORA' THEN
      -- Buscar o diret�rio padrao da cooperativa conectada + /rlnsv
      vr_dspathcop := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nmsubdir => 'rlnsv');
    END IF;

    -- define o nome do relat�rio
    vr_nmrelato := 'crrl527_'
                  ||to_char(vr_nrindice,'FM00')
                  ||'.lst';

    -- Submeter o relat�rio 527
    GENE0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                               ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                               ,pr_dtmvtolt  => vr_dtmvtolt                          --> Data do movimento atual
                               ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/crps527/lancto'                    --> N� base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl527.jasper'                     --> Arquivo de layout do iReport
                               ,pr_dsparams  => null                                 --> Sem par�metros
                               ,pr_dsarqsaid => vr_dsdirrel||vr_nmrelato             --> Arquivo final com o path
                               ,pr_qtcoluna  => 132                                  --> 132 colunas
                               ,pr_sqcabrel  => 1                                    --> Sequencia
                               ,pr_flg_gerar => 'N'                                  --> Gera�ao na hora
                               ,pr_flg_impri => 'S'                                  --> Chamar a impress�o (Imprim.p)
                               ,pr_nmformul  => NULL                                 --> Nome do formul�rio para impress�o
                               ,pr_dspathcop => vr_dspathcop                         --> Lista sep. por ';' de diret�rios a copiar o relat�rio
                               ,pr_nrcopias  => 1                                    --> N�mero de c�pias
                               ,pr_des_erro  => vr_des_erro);                        --> Sa�da com erro

    -- Liberando a mem�ria alocada pro CLOB
    dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml);

    -- Verifica se ocorreram erros na gera��o do XML
    IF vr_des_erro IS NOT NULL THEN

      vr_dscritic := vr_des_erro;

      -- Gerar exce��o
      RAISE vr_exc_saida;
    END IF;

    -- Se possuir conteudo de critica no CLOB
    IF LENGTH(vr_clobcri) > 0 THEN
      -- Busca o diret�rio para contabilidade
      vr_dircon := gene0001.fn_param_sistema('CRED', vc_cdtodascooperativas, vc_cdacesso);
      vr_dircon := vr_dircon || vc_dircon;
      vr_arqcon := TO_CHAR(vr_dtmvtolt,'RRMMDD')||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_CRITICAS_527.txt';

      -- Chama a geracao do TXT
      GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper              --> Cooperativa conectada
                                         ,pr_cdprogra  => vr_cdprogra              --> Programa chamador
                                         ,pr_dtmvtolt  => vr_dtmvtolt              --> Data do movimento atual
                                         ,pr_dsxml     => vr_clobcri               --> Arquivo XML de dados
                                         ,pr_dsarqsaid => vr_dsdireto || '/contab/' || vr_arqcon    --> Arquivo final com o path
                                         ,pr_cdrelato  => NULL                     --> C�digo fixo para o relat�rio
                                         ,pr_flg_gerar => 'N'                      --> Apenas submeter
                                         ,pr_dspathcop => vr_dircon                --> Copiar para a Micros
                                         ,pr_fldoscop  => 'S'                      --> Efetuar c�pia com Ux2Dos                                             
                                         ,pr_des_erro  => vr_des_erro);            --> Sa�da com erro
                                     
                                             
    END IF;

    -- Liberando a mem�ria alocada pro CLOB
    dbms_lob.close(vr_clobcri);
    dbms_lob.freetemporary(vr_clobcri);

    -- Verifica se ocorreram erros na geracao do TXT
    IF vr_des_erro IS NOT NULL THEN
      vr_cdcritic := 1050; -- Erro ao gerar o arquivo
      -- Buscar a descri��o
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_arqcon || ': ' || vr_des_erro;
      -- Envio centralizado de log de erro
      pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => vr_dscritic,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => vr_cdcritic);
    END IF;

    /***** RELAT�RIO DE REJEITADOS TCO 999 *****/
        
    -- Gerar apenas para as cooperativas 1 ou 2
    -- Desde que o arquivo atual n�o seja de incorpora��o
    IF pr_cdcooper IN (1,2) AND NOT vr_flgincorp THEN

      -- Zerar as vari�veis
      vr_qtregrec := 0;
      vr_qtregint := 0;
      vr_vlregrec := 0;
      vr_vlregint := 0;
      vr_cdcritic := 0;
      vr_flgfirst := TRUE;
          
      -- Seta flag de controle de registros vazios
      vr_flgregis := FALSE;

      -- Preparar o CLOB para armazenar as infos do arquivo
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?>'||chr(10)||
                                 '<crps527 dsarquiv="integra/'||pr_tbarquiv(vr_nrindice)||'" '||
                                 '  dtrefere="'||to_char(vr_dtmvtolt,'DD/MM/YYYY')||'" '||
                                 '  cdagenci="'||vr_cdagenci||'"'            ||
                                 '  cdbccxlt="'||rw_crapcop.cdbcoctl||'" '   ||
                                 '  nrdolote="'||to_char(vr_nrdolote,'FM999G999')||'" '||
                                 '  tplotmov="'||to_char(vr_tplotmov,'FM00')||'" >'||chr(10));

      -- Percorre as informa��es guardadas na mem�ria para montar o XML
      FOR rw_craprej IN cr_craprej(999) LOOP -- Retornar apenas registro com critica igual a 999
        -- Seta flag de controle de registros vazios
        vr_flgregis := TRUE;
        -- Guarda o c�digo da cr�tica
        vr_cdcritic := rw_craprej.cdcritic;
        -- Verifica se o c�digo da cr�tica � 999, se n�o for busca a descri��o
        IF pr_cdcooper = 2 THEN
          vr_dscritic := 'Associado VIACREDI';
        ELSE
          vr_dscritic := 'Associado ALTOVALE';
        END IF;

        -- Atualiza totalizadores...
        vr_qtregint := vr_qtregint + 1;
        vr_qtregrec := vr_qtregrec + 1;
        vr_vlregint := NVL(vr_vlregint,0) + rw_craprej.vllanmto;
        vr_vlregrec := NVL(vr_vlregrec,0) + rw_craprej.vllanmto;

        -- Verificar se � um CPF ou CNPJ e formatar o mesmo
        IF length(rw_craprej.vldaviso) > 11 THEN
          -- formata e guarda o CNPJ
          vr_dsrelcpf := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_craprej.vldaviso
                                                  ,pr_inpessoa => 2);
        ELSE
          -- Rotina para validar a informa��o de CPF ou CNPJ
          gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => rw_craprej.vldaviso
                                     ,pr_stsnrcal => vr_stsnrcal
                                     ,pr_inpessoa => vr_inpessoa);

          -- Se validou
          IF vr_stsnrcal THEN
            -- CPF
            vr_dsrelcpf := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_craprej.vldaviso
                                                    ,pr_inpessoa => 1);
          ELSE
            -- CNPJ
            vr_dsrelcpf := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_craprej.vldaviso
                                                    ,pr_inpessoa => 2);
          END IF;

        END IF;

        -- Montar o XML
        pc_escreve_clob(vr_clobxml,'  <lancto> '||chr(10)||
                                   '    <nrdctitg>'|| TRIM(rw_craprej.nrdctitg) ||'</nrdctitg>'||chr(10)||
                                   '    <dshistor>'|| GENE0007.fn_caract_controle(substr(rw_craprej.dshistor,0,24)) ||'</dshistor>'||chr(10)||
                                   '    <indebcre>'|| rw_craprej.indebcre ||'</indebcre>'||chr(10)||
                                   '    <nrdocmto>'|| to_char(rw_craprej.nrdocmto,'FM999G999G999') ||'</nrdocmto>'||chr(10)||
                                   '    <cdpesqbb>'|| GENE0007.fn_caract_controle(substr(rw_craprej.cdpesqbb,0,35)) ||'</cdpesqbb>'||chr(10)||
                                   '    <vllanmto>'|| to_char(rw_craprej.vllanmto,'FM999G999G999G990D00') ||'</vllanmto>'||chr(10)||
                                   '    <dscritic>'|| substr(vr_dscritic,0,24) ||'</dscritic>'||chr(10)||
                                   '    <dscpfcgc>'||     vr_dsrelcpf     ||'</dscpfcgc>'||chr(10));

        -- Verifica se h� hist�rico
        IF TRIM(substr(rw_craprej.dshistor,40,20)) IS NOT NULL THEN
          pc_escreve_clob(vr_clobxml,'    <dsinform>'|| substr(rw_craprej.dshistor,41,60) ||'</dsinform>'||chr(10));
        END IF;

        -- Fecha o registro de lan�amento
        pc_escreve_clob(vr_clobxml,'  </lancto>');
      END LOOP;

      -- Se n�o inseriu registros no xml
      IF NOT vr_flgregis THEN

        -- Montar o XML
        pc_escreve_clob(vr_clobxml,'  <lancto></lancto>');

      END IF;

      -- Totais
      vr_qtregrej := 0;
      vr_vlregrej := 0;

      -- Montar o total
      pc_escreve_clob(vr_clobxml,'  <total> '||chr(10)||
                                 '    <qtregrec>'||to_char(vr_qtregrec,'FM9G999G999G999G990')||'</qtregrec>'||chr(10)||
                                 '    <qtregint>'||to_char(vr_qtregint,'FM9G999G999G999G990')||'</qtregint>'||chr(10)||
                                 '    <qtregrej>'||to_char(vr_qtregrej,'FM9G999G999G999G990')||'</qtregrej>'||chr(10)||
                                 '    <vlregrec>'||to_char(vr_vlregrec,'FM9G999G999G999G990D00')||'</vlregrec>'||chr(10)||
                                 '    <vlregint>'||to_char(vr_vlregint,'FM9G999G999G999G990D00')||'</vlregint>'||chr(10)||
                                 '    <vlregrej>'||to_char(vr_vlregrej,'FM9G999G999G999G990D00')||'</vlregrej>'||chr(10)||
                                 '  </total> ');

      -- Fecha a tag geral
      pc_escreve_clob(vr_clobxml,chr(10)||'</crps527>');

      -- Limpa as criticas
      vr_cdcritic := 0;

      -- Limpa a variavel de controle de c�pia do relat�rio
      vr_dspathcop := NULL;

      -- Verifica a tela
      IF pr_nmtelant = 'COMPEFORA' THEN
        -- Buscar o diret�rio padrao da cooperativa conectada + /rlnsv
        vr_dspathcop := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => 'rlnsv');
      END IF;

      -- define o nome do relat�rio
      vr_nmrelato := 'crrl527_'
                    ||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')
                    ||'_'
                    ||to_char(vr_nrindice,'FM00')
                    ||'.lst';

      -- Buscar os endere�os de e-mail para envio do relat�rio
      vr_dsmailcop := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL527_EMAIL');

      -- Montar o assunto do e-mail
      vr_dsassmail := 'Relat�rio de Integra��o DOCs AILOS';

      -- Montar o corpo do e-mail
      vr_dscormail := NULL; -- Em branco

      -- Submeter o relat�rio 527
      GENE0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => vr_dtmvtolt                          --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crps527/lancto'                    --> N� base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl527.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem par�metros
                                 ,pr_dsarqsaid => vr_dsdirrel||vr_nmrelato             --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_sqcabrel  => 1                                    --> Sequencia
                                 ,pr_flg_gerar => 'N'                                  --> Gera�ao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impress�o (Imprim.p)
                                 ,pr_nmformul  => NULL                                 --> Nome do formul�rio para impress�o
                                 ,pr_dspathcop => vr_dspathcop                         --> Lista sep. por ';' de diret�rios a copiar o relat�rio
                                 ,pr_nrcopias  => 1                                    --> N�mero de c�pias
                                 ,pr_dsmailcop => vr_dsmailcop                         --> Lista sep. por ';' de emails para envio do relat�rio
                                 ,pr_dsassmail => vr_dsassmail                         --> Assunto do e-mail que enviar� o relat�rio
                                 ,pr_dscormail => vr_dscormail                         --> HTML corpo do email que enviar� o relat�rio
                                 ,pr_fldosmail => 'S'                                  --> Converter anexo para DOS antes de enviar
                                 ,pr_dscmaxmail => ' | tr -d "\032"'                   --> Complemento do comando converte-arquivo
                                 ,pr_des_erro  => vr_des_erro);                        --> Sa�da com erro

      -- Liberando a mem�ria alocada pro CLOB
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);

      -- Verifica se ocorreram erros na gera��o do XML
      IF vr_des_erro IS NOT NULL THEN

        vr_dscritic := vr_des_erro;

        -- Gerar exce��o
        RAISE vr_exc_saida;
      END IF;
    END IF; -- pr_cdcooper IN (1,2)
  END; -- Bloco de gera��o do relat�rio

    -- Limpara todas as informa��es do processamento
    BEGIN
      DELETE craprej
       WHERE craprej.cdcooper = pr_cdcooper
         AND craprej.dtrefere = vr_dtauxili;
    EXCEPTION
      WHEN OTHERS THEN
        -- Cr�tica: Erro Oracle
        vr_cdcritic := 1037;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' craprej: com cdcooper:'||pr_cdcooper
                       ||', dtrefere:'||vr_dtauxili||'. '||SQLERRM;
        -- Envio centralizado de log de erro
        pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => vr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => vr_cdcritic,
                    pr_ind_tipo_log  => 3);

      --Inclus�o na tabela de erros Oracle - Chamado 789851
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    END;

  END LOOP; -- Fim da leitura dos arquivos

  END pc_integra_cooperativa;

  ---------------------------------------
  -- Inicio Bloco Principal PC_CRPS534
  ---------------------------------------

BEGIN -- Principal

  -- Incluir nome do m�dulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra);

  -- Verifica se a cooperativa conectada esta cadastrada
  OPEN  cr_crapcop(pr_cdcooper);
  FETCH cr_crapcop INTO rw_crapcop;
  -- Se n�o encontrar
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor pois haver� raise
    CLOSE cr_crapcop;
    -- Montar mensagem de critica
    vr_cdcritic := 651;
    RAISE vr_exc_saida;
  END IF;
  -- Apenas fechar o cursor
  CLOSE cr_crapcop;

  -- Leitura do calend�rio da cooperativa
  OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
  -- Se n�o encontrar
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE btch0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE
    -- Guarda a data
    vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
    vr_dtmvtoan := btch0001.rw_crapdat.dtmvtoan;
  END IF;
  -- Fechar o cursor
  CLOSE btch0001.cr_crapdat;

  -- Log de in�cio da execu��o
  pc_gera_log(pr_cdcooper_in   => rw_crapcop.cdcooper,
              pr_dstiplog      => 'I');

  -- Valida��es iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);

  -- Se a variavel de erro � <> 0
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  -- Verifica se a Cooperativa esta preparada para executa COMPE 85 - ABBC
  OPEN  cr_craptab('CRED','GENERI',0,'EXECUTAABBC', 0);
  FETCH cr_craptab INTO vr_dstextab;
  CLOSE cr_craptab;

  -- Se o valor retornado for SIM
  IF TRIM(NVL(vr_dstextab,'NAO')) <> 'SIM' THEN
     raise vr_exc_fimprg;
  END IF;
  
  -- Buscar informa��es das Cooperativas Incorporadas a 
  -- Viacredi (Concredi) e ScrCred (Credimilsul) e Transpocred (Transulcred)
  IF pr_cdcooper IN(1,9,13) THEN
    -- Buscar informa��es da cooperativa Incorporada
    CASE pr_cdcooper
      WHEN  1 THEN
		OPEN cr_crapcop(pr_cdcooper => 4); --> Incorpora��o Concredi
      WHEN 13 THEN
		OPEN cr_crapcop(pr_cdcooper => 15); --> Incorpora��o CredimilSul
      WHEN  9 THEN
        OPEN cr_crapcop(pr_cdcooper => 17);  -- TRANSPOCRED --> TRANSULCRED
    END CASE;
	
	-- Buscar informa��es da mesma
    FETCH cr_crapcop INTO rw_crapcop_incorp;
    CLOSE cr_crapcop;
  END IF;

  -- Se CECRED, integra todos os arquivos que n�o foram identificadas a Agencia e a Coop.
  -- Padr�o do nome de arquivo para busca no diret�rio
  IF pr_cdcooper = 3 THEN
    vr_nmarquiv := '3%.RET';
    vr_nmarquiv_incorp := NULL;
  ELSE
    vr_nmarquiv := '3'||to_char(rw_crapcop.cdagectl,'FM0000')||'%.RET';
    -- Se houver cooperativa incorporadas
    IF rw_crapcop_incorp.cdcooper IS NOT NULL THEN
      -- Buscaremos os arquivos da cooperativa incorporada tamb�m
      vr_nmarquiv_incorp := '3'||to_char(rw_crapcop_incorp.cdagectl,'FM0000')||'%.RET';
    END IF;
  END IF;

  -- Busca o diret�rio da cooperativa
  vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                      ,pr_cdcooper => pr_cdcooper);

  -- Monta diret�rio completo para a pasta integra
  vr_dsdirarq := vr_dsdireto||'/'||vr_nmsubint;

  -- Monta diret�rio completo para a pasta de relat�rio
  vr_dsdirrel := vr_dsdireto||'/'||vr_nmsubrel;

  -- Buscar todos os arquivos do diret�rio
  gene0001.pc_lista_arquivos(pr_path     => vr_dsdirarq
                            ,pr_pesq     => vr_nmarquiv
                            ,pr_listarq  => vr_listaarq
                            ,pr_des_erro => vr_dscritic);

  -- Se retornar cr�tica
  IF vr_dscritic IS NOT NULL THEN
    -- Saida
    RAISE vr_exc_saida;
  END IF;

  -- Se houver cooperativa incorporada 
  IF vr_nmarquiv_incorp IS NOT NULL THEN
    -- Traz�-los tamb�m 
    gene0001.pc_lista_arquivos(pr_path     => vr_dsdirarq
                              ,pr_pesq     => vr_nmarquiv_incorp
                              ,pr_listarq  => vr_listaarq_incorp
                              ,pr_des_erro => vr_dscritic);

    -- Se retornar cr�tica
    IF vr_dscritic IS NOT NULL THEN
      -- Saida
      RAISE vr_exc_saida;
    END IF;
    -- Se encontrou algum arquivo incorporado
    IF TRIM(vr_listaarq_incorp) IS NOT NULL THEN
      -- Se j� existe algum arquivo na lista principal
      IF TRIM(vr_listaarq) IS NOT NULL THEN
        -- Adicionamos o incorporado a lista principal
        vr_listaarq := vr_listaarq || ',' || vr_listaarq_incorp;
      ELSE
        -- Existe apenas os arquivos incorporados
        vr_listaarq := vr_listaarq_incorp;
      END IF;  
    END IF;
    
  END IF;

  -- Guardar todos os arquivos em mem�ria
  vr_tbarquiv := GENE0002.fn_quebra_string(pr_string  => vr_listaarq
                                          ,pr_delimit => ',');

  -- Verificar se algum arquivo foi encontrado
  IF vr_tbarquiv.COUNT() = 0 THEN
    -- Seta a cr�tica: 182 - Arquivo nao existe
    vr_cdcritic := 182;
    -- Finaliza o programa, sem erro
    RAISE vr_exc_fimprg;
  END IF;

  -- Ordenar o nome dos arquivos conforme o padr�o Unix, onde n�meros vem antes de letras
  -- Montar select dinamico
  vr_dsselect := 'SELECT * FROM (';

  -- Percorre os arquivos encontrados
  FOR ind IN vr_tbarquiv.FIRST..vr_tbarquiv.LAST LOOP
    
    -- Montar o trecho do select dinamico
    vr_dsselect := vr_dsselect || 'SELECT '''||vr_tbarquiv(ind)||''' str from dual ';

    -- Se for o ultimo sai do loop
    EXIT WHEN ind = vr_tbarquiv.LAST;

    -- Adicionar o union ao select
    vr_dsselect := vr_dsselect || ' UNION ';
  END LOOP;

  -- Finaliza a montagem do select dinamico
  vr_dsselect := vr_dsselect || ') ORDER BY  NLSSORT(str, ''NLS_SORT=BINARY_AI'') ';

  -- Limpar a tab de arquivos, para receber os mesmos com nova ordena��o
  vr_tbarquiv := GENE0002.typ_split();
  -- Limpar a vari�vel com o nome do arquivo
  vr_nmarquiv := NULL;

  -- Executar o select dinamico com o nome dos arquivos
  --Abre o cursor com o select da vari�vel
  OPEN vr_cursor FOR vr_dsselect;
  -- Percorrer registros retornados
  LOOP
    -- Joga os valores das colunas no registro de mem�ria
    FETCH vr_cursor INTO vr_nmarquiv;

    -- Caso n�o tenha mais dados sai do cursor
    EXIT WHEN vr_cursor%NOTFOUND;

    -- Inserir o novo elemento no registro de mem�ria
    vr_tbarquiv.EXTEND;
    -- Guarda o nome do arquivo, ordenado
    vr_tbarquiv(vr_tbarquiv.COUNT) := vr_nmarquiv;
  END LOOP;

  -- Fecha o cursor
  CLOSE vr_cursor;

  -- Definir as datas de leitura, conforme tela
  IF pr_nmtelant = 'COMPEFORA' THEN
    vr_dtleiarq := vr_dtmvtoan;
    vr_dtauxili := to_char(vr_dtmvtoan,'YYYYMMDD');
  ELSE
    vr_dtleiarq := vr_dtmvtolt;
    vr_dtauxili := to_char(vr_dtmvtolt,'YYYYMMDD');
  END IF;

  -- Se CECRED, integra todos os arquivos que n�o foram identificadas a Agencia e a Coop.
  IF pr_cdcooper = 3 THEN
    pc_integra_cecred(pr_tbarquiv => vr_tbarquiv);
  ELSE
    pc_integra_cooperativa(pr_tbarquiv => vr_tbarquiv);
  END IF;
  -- Inclus�o do m�dulo e a��o logado - Chamado 789851 - 20/11/2017
  GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

  -- Log de t�rmino da execu��o
  pc_gera_log(pr_cdcooper_in   => rw_crapcop.cdcooper,
              pr_dstiplog      => 'F');

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informacoes no banco de dados
  COMMIT;
    
EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas c�digo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descri��o
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => vr_dscritic,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => vr_cdcritic);
    END IF;

    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Efetuar commit pois gravaremos o que foi processo at� ent�o
    COMMIT;  

  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas c�digo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descri��o
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos c�digo e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;

    -- Log de erro in�cio da execu��o
    pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                pr_dstiplog      => 'E',
                pr_dscritic      => pr_dscritic,
                pr_cdcriticidade => 1,
                pr_cdmensagem    => pr_cdcritic);

    -- Efetuar rollback
    ROLLBACK;

  WHEN OTHERS THEN
    -- Efetuar retorno do erro n�o tratado
    pr_cdcritic := 9999;
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||SQLErrm;  
    
    -- Log de erro in�cio da execu��o
    pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                pr_dstiplog      => 'E',
                pr_dscritic      => pr_dscritic,
                pr_cdcriticidade => 2,
                pr_cdmensagem    => pr_cdcritic,
                pr_ind_tipo_log  => 3);

    --Inclus�o na tabela de erros Oracle - Chamado 789851
    CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    -- Efetuar rollback
    ROLLBACK;

END pc_crps534;
/
