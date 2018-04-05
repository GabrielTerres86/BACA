CREATE OR REPLACE PACKAGE CECRED.cxon0022 AS

/*..............................................................................

   Programa: cxon0022                        Antigo: siscaixa/web/dbo/b1crap22.p
   Sistema : Caixa On-line
   Sigla   : CRED
   Autor   : Elton
   Data    : Outubro/2011                      Ultima atualizacao: 16/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Transferencia e deposito entre cooperativas.

   Alteracoes: 15/12/2011 - Retirado comentarios (Elton).

               12/04/2013 - Transferencia intercooperativa (Gabriel). s

               28/06/2013 - Conversao Progress para Oracle (Alisson - AMcom)

               11/07/2013 Alterações na procedurerealiza-transferencia:
                          - Tratado undo de transação para chamada da procedure
                            grava-autenticacao-internet.
                          - Campo craplcm.hrtransa alimentado com TIME (Lucas).

               14/10/2013 - Incluido parametro cdprogra nas procedures da
                            b1wgen0153 que carregamdados da tarifa(Tiago).

               01/11/2013 - Conversao Progress para Oracle (Alisson - AMcom)
                          - Adequação das alteracoes progress de Outubro
                          
               16/04/2014 - Incluido a funcao fn_sequence para a busca do maior
                            valor no insert da crapldt (Andrino - RKAM)
                            
               12/06/2014 - Transferencia e deposito entre cooperativas
                            Convertendo procedures da rotina 22:
                            realiza_deposito_cheque              => pc_realiza_dep_cheq
                            realiza-deposito-cheque-migrado      => pc_realiz_dep_cheque_mig
                            realiza-deposito-cheque-migrado-host => pc_realiz_dep_chq_mig_host
                            (Andre Santos - SUPERO)             

               16/06/2016 - Correcao para o uso correto do indice da CRAPTAB em
                            varias procedures desta package.(Carlos Rafael Tanholi).                                                             

               28/03/2016 - Adicionados parâmetros para geraçao de LOG
                           (Lucas Lunelli - PROJ290 Cartao CECRED no CaixaOnline)														       

..............................................................................*/

  -- Definicao de TEMP TABLE pra cheques.
  TYPE typ_reg_cheques IS
    RECORD(dtlibcom crapmdw.dtlibcom%TYPE
          ,nrdocmto crapmdw.nrdocmto%TYPE
          ,vlcompel crapmdw.vlcompel%TYPE
          ,nrsequen INTEGER
          ,nrseqlcm INTEGER);
          
  -- Definicao de tipo de registro que vai armazenar o extrato RDC
  TYPE typ_tab_chq IS
    TABLE OF typ_reg_cheques
    INDEX BY VARCHAR2(20);
   
  /* Gera Log de Transacao InterCooperaticas */ 
  PROCEDURE pc_gera_log (pr_cooper       IN INTEGER --Codigo Cooperativa
                        ,pr_cod_agencia  IN INTEGER --Codigo Agencia
                        ,pr_nro_caixa    IN INTEGER --Numero do caixa
                        ,pr_operador     IN VARCHAR2 --Codigo Operador
                        ,pr_cooper_dest  IN INTEGER  --Codigo Cooperativa
                        ,pr_nrdcontade   IN INTEGER  --Numero Conta destino
                        ,pr_nrdcontapara IN INTEGER  --Conta de Destino
                        ,pr_tpoperac     IN INTEGER  --Tipo de Operacao
                        ,pr_valor        IN NUMBER   --Valor da transacao
                        ,pr_nrdocmto     IN INTEGER  --Numero Documento
                        ,pr_cdpacrem     IN INTEGER  -- Cod Agencia Rem.
                        ,pr_cdcritic     OUT INTEGER       --C¿digo do erro
                        ,pr_dscritic     OUT VARCHAR2);  --Descricao do erro 

  /* Procedure para realizar transferencia */
  PROCEDURE pc_realiza_transferencia (pr_cooper             IN INTEGER --Codigo Cooperativa
                                     ,pr_cod_agencia        IN INTEGER --Codigo Agencia
                                     ,pr_nro_caixa          IN INTEGER --Numero do caixa
                                     ,pr_cod_operador       IN VARCHAR2 --Codigo Operador
                                     ,pr_idorigem           IN INTEGER  --Origem transacao
                                     ,pr_cooper_dest        IN INTEGER  --Codigo Cooperativa
                                     ,pr_nrdcontade         IN INTEGER  --Numero Conta destino
                                     ,pr_idseqttl           IN INTEGER  --Sequencial do Titular
                                     ,pr_nrdcontapara       IN INTEGER  --Conta de Destino
                                     ,pr_valor              IN OUT NUMBER   --Valor da transacao
                                     ,pr_nrsequni           IN INTEGER  --Numero Sequencial
                                     ,pr_idagenda           IN INTEGER  --Indicador Agendamento
                                     ,pr_cdcoptfn           IN INTEGER  --Codigo Cooperativa
                                     ,pr_nrterfin           IN INTEGER  --Numero do terminal
									 ,pr_flmobile           IN INTEGER  --Indicador Mobile
									 ,pr_idtipcar           IN INTEGER  --Indicador Tipo Cartão Utilizado
									 ,pr_nrcartao           IN NUMBER   --Numero Cartao																		 
                                     ,pr_literal_autentica  OUT VARCHAR2 --Numero literal autenticacao
                                     ,pr_ult_seq_autentica  OUT INTEGER  --Sequencial autenticacao
                                     ,pr_nro_docto          OUT NUMBER   --Numero do Documento
                                     ,pr_nro_docto_cred     OUT NUMBER   --Numero documento credito
                                     ,pr_cdlantar           OUT craplat.cdlantar%type --C¿digo lancamento tarifa
                                     ,pr_reg_lcm_deb        OUT ROWID    --ROWID do registro lancamento debito
                                     ,pr_reg_lcm_cre        OUT ROWID    --ROWID do registro lancamento credito
                                     ,pr_nrultaut           OUT INTEGER  --Numero Ultima Autorizacao
                                     ,pr_cdcritic           OUT INTEGER     --C¿digo do erro
                                     ,pr_dscritic           OUT VARCHAR2);   --Descricao do erro
                                
  /* Procedure para realizar deposito de cheques entre cooperativas */     
  PROCEDURE pc_realiza_dep_cheq (pr_cooper            IN VARCHAR2    --> Codigo Cooperativa
                                ,pr_cod_agencia       IN INTEGER     --> Codigo Agencia
                                ,pr_nro_caixa         IN INTEGER     --> Codigo do Caixa
                                ,pr_cod_operador      IN VARCHAR2    --> Codigo Operador
                                ,pr_cooper_dest       IN VARCHAR2    --> Cooperativa de Destino
                                ,pr_nro_conta         IN INTEGER     --> Nro da Conta
                                ,pr_nro_conta_de      IN INTEGER     --> Nro da Conta origem
                                ,pr_valor             IN NUMBER      --> Valor
                                ,pr_identifica        IN VARCHAR2    --> Identificador de Deposito
                                ,pr_vestorno          IN INTEGER     --> Flag Estorno. False
                                ,pr_nro_docmto        OUT NUMBER     --> Nro Documento
                                
                                ,pr_literal_autentica OUT VARCHAR2   --> Literal Autenticacao
                                ,pr_ult_seq_autentica OUT INTEGER    --> Ultima Seq de Autenticacao
                                ,pr_retorno           OUT VARCHAR2   --> Retorna OK ou NOK
                                ,pr_cdcritic          OUT INTEGER    --> Cod Critica
                                ,pr_dscritic          OUT VARCHAR2); --> Des Critica
                                       
  PROCEDURE pc_realiz_dep_cheque_mig (pr_cooper            IN VARCHAR2    --> Codigo Cooperativa
                                     ,pr_cooper_migrada    IN VARCHAR2    --> Codigo Cooperativa Migrada
                                     ,pr_cod_agencia       IN INTEGER     --> Codigo Agencia
                                     ,pr_nro_caixa         IN INTEGER     --> Codigo do Caixa
                                     ,pr_cod_operador      IN VARCHAR2    --> Codigo Operador
                                     ,pr_cooper_dest       IN VARCHAR2    --> Cooperativa de Destino
                                     ,pr_nro_conta         IN INTEGER     --> Nro da Conta
                                     ,pr_nro_conta_de      IN INTEGER     --> Nro da Conta origem
                                     ,pr_valor             IN NUMBER      --> Valor
                                     ,pr_identifica        IN VARCHAR2    --> Identificador de Deposito
                                     ,pr_vestorno          IN INTEGER     --> Flag Estorno. False
                                     ,pr_nro_docmto        OUT NUMBER     --> Nro Documento
                                     ,pr_literal_autentica OUT VARCHAR2   --> Literal Autenticacao
                                     ,pr_ult_seq_autentica OUT INTEGER    --> Ultima Seq de Autenticacao
                                     ,pr_retorno           OUT VARCHAR2   --> Retorna OK ou NOK
                                     ,pr_cdcritic          OUT INTEGER    --> Cod Critica
                                     ,pr_dscritic          OUT VARCHAR2); --> Des Critica
                                          
  PROCEDURE pc_realiz_dep_chq_mig_host (pr_cooper            IN VARCHAR2    --> Codigo Cooperativa
                                       ,pr_cooper_migrada    IN VARCHAR2    --> Codigo Cooperativa Migrada
                                       ,pr_cod_agencia       IN INTEGER     --> Codigo Agencia
                                       ,pr_nro_caixa         IN INTEGER     --> Codigo do Caixa
                                       ,pr_cod_operador      IN VARCHAR2    --> Codigo Operador
                                       ,pr_cooper_dest       IN VARCHAR2    --> Cooperativa de Destino
                                       ,pr_nro_conta         IN INTEGER     --> Nro da Conta
                                       ,pr_nro_conta_de      IN INTEGER     -->  Nro da Conta origem
                                       ,pr_valor             IN NUMBER      --> Valor
                                       ,pr_identifica        IN VARCHAR2    --> Identificador de Deposito
                                       ,pr_vestorno          IN INTEGER     --> Flag Estorno. False
                                       ,pr_nro_docmto        OUT NUMBER     --> Nro Documento
                                       ,pr_literal_autentica OUT VARCHAR2   --> Literal Autenticacao
                                       ,pr_ult_seq_autentica OUT INTEGER    --> Ultima Seq de Autenticacao
                                       ,pr_retorno           OUT VARCHAR2   --> Retorna OK ou NOK
                                       ,pr_cdcritic          OUT INTEGER    --> Cod Critica
                                       ,pr_dscritic          OUT VARCHAR2); --> Des Critica

END CXON0022;
/
CREATE OR REPLACE PACKAGE BODY CECRED.cxon0022 AS

  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CXON0022
  --  Sistema  : Procedimentos e funcoes das transacoes do caixa online
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Junho/2013.                   Ultima atualizacao: 12/12/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos e funcoes das transacoes do caixa online
  
  -- Alteracoes: 12/06/2014 - Transferencia e deposito entre cooperativas
                           (Andre Santos - SUPERO).   
                           
  --             10/07/2014 - Corrigido o retorno da procedure PC_REALIZA_TRANSFERENCIA. Não estava retornando o erro.
 
  --             16/07/2014 - Corrigido o problema de unique constraint que ocorria ao selecionar\inserir 
  --                          um lote quando a transferencia é intercoop. Se buscava o lote pela origem e não 
  --                          se encontrava, ao inserir se passava a cooperativa destino, e não a que tinha sido usada na busca (origem)
                          
                 12/06/2014 - Transferencia e deposito entre cooperativas
                              Convertendo procedures da rotina 22:
                              realiza_deposito_cheque              => pc_realiza_dep_cheq
                              realiza-deposito-cheque-migrado      => pc_realiz_dep_cheque_mig
                              realiza-deposito-cheque-migrado-host => pc_realiz_dep_chq_mig_host
                              (Andre Santos - SUPERO)
                            
                 10/08/2015 - Incluir regra para evitar que sejam efetivadas
                              2 transferencias iguais enviadas pelo ambiente 
                              mobile (Dionathan).
                 
                                                                   
                 22/03/2016 - Ajuste na mensagem de alerta que identifica transferências duplicadas
                              conforme solicitado no chamado 421403. (Kelvin)                                                                   
                              
                 16/06/2016 - Correcao para o uso correto do indice da CRAPTAB em
                              varias procedures desta package.(Carlos Rafael Tanholi).       
                              
                 23/06/2016 - Correcao no cursor da crapbcx utilizando o indice correto
                              sobre o campo cdopecxa.(Carlos Rafael Tanholi).

				 26/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                       crapass, crapttl, crapjur (Adriano - P339).

                 12/12/2017 - Passar como texto o campo nrcartao na chamada da procedure 
                              pc_gera_log_ope_cartao (Lucas Ranghetti #810576)
                14/02/2018 - Projeto Ligeirinho. Alterado para gravar na tabela de lotes (craplot) somente no final
                            da execução do CRPS509 => INTERNET E TAA. (Fabiano Girardi AMcom)
  ---------------------------------------------------------------------------------------------------------------*/

  /* Busca dos dados da cooperativa */
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.nmrescop
          ,crapcop.nmextcop
          ,crapcop.nrtelura
          ,crapcop.dsdircop
          ,crapcop.cdbcoctl
          ,crapcop.cdagectl
          ,crapcop.flgoppag
          ,crapcop.flgopstr
          ,crapcop.inioppag
          ,crapcop.fimoppag
          ,crapcop.iniopstr
          ,crapcop.fimopstr
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  /* Buscar dados das agencias */
  CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%type
                    ,pr_cdagenci IN crapage.cdagenci%type) IS
    SELECT crapage.nmresage
          ,crapage.qtddaglf
    FROM crapage
    WHERE crapage.cdcooper = pr_cdcooper
    AND   crapage.cdagenci = pr_cdagenci;
  rw_crapage cr_crapage%ROWTYPE;

  /* Busca dos dados do associado */
  CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.cdcooper 
	      ,crapass.nrdconta
          ,crapass.nmprimtl
          ,crapass.inpessoa
          ,crapass.cdagenci
          ,crapass.vllimcre
          ,crapass.nrcpfcgc
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
     AND   crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  --Selecionar informacoes dos terminais
  CURSOR cr_craptfn (pr_cdcoptfn IN craptfn.cdcooper%type
                    ,pr_nrterfin IN craptfn.nrterfin%type) IS
    SELECT craptfn.nrultaut
          ,craptfn.cdcooper
          ,craptfn.cdagenci
          ,craptfn.nrterfin
          ,craptfn.cdoperad
          ,craptfn.ROWID
    FROM craptfn
    WHERE craptfn.cdcooper = pr_cdcoptfn
    AND   craptfn.nrterfin = pr_nrterfin;
  rw_craptfn cr_craptfn%ROWTYPE;

  -- Selecionar informacoes dos lotes
  CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                    ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                    ,pr_cdagenci IN craplot.cdagenci%TYPE
                    ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                    ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT craplot.dtmvtolt
          ,craplot.cdagenci
          ,craplot.cdbccxlt
          ,craplot.nrdolote
          ,craplot.nrseqdig
          ,craplot.tplotmov
          ,craplot.cdhistor
          ,craplot.cdoperad
          ,craplot.qtcompln
          ,craplot.qtinfoln
          ,craplot.vlcompcr
          ,craplot.vlinfocr
          ,craplot.rowid
    FROM   craplot craplot
    WHERE  craplot.cdcooper = pr_cdcooper
    AND    craplot.dtmvtolt = pr_dtmvtolt
    AND    craplot.cdagenci = pr_cdagenci
    AND    craplot.cdbccxlt = pr_cdbccxlt
    AND    craplot.nrdolote = pr_nrdolote
    FOR UPDATE NOWAIT;
  rw_craplot_ori cr_craplot%ROWTYPE;
  rw_craplot_dst cr_craplot%ROWTYPE;


  /* Procedure para gerar log */
  PROCEDURE pc_gera_log (pr_cooper       IN INTEGER --Codigo Cooperativa
                        ,pr_cod_agencia  IN INTEGER --Codigo Agencia
                        ,pr_nro_caixa    IN INTEGER --Numero do caixa
                        ,pr_operador     IN VARCHAR2 --Codigo Operador
                        ,pr_cooper_dest  IN INTEGER  --Codigo Cooperativa
                        ,pr_nrdcontade   IN INTEGER  --Numero Conta destino
                        ,pr_nrdcontapara IN INTEGER  --Conta de Destino
                        ,pr_tpoperac     IN INTEGER  --Tipo de Operacao
                        ,pr_valor        IN NUMBER   --Valor da transacao
                        ,pr_nrdocmto     IN INTEGER  --Numero Documento
                        ,pr_cdpacrem     IN INTEGER  --Cod Agencia
                        ,pr_cdcritic     OUT INTEGER       --C¿digo do erro
                        ,pr_dscritic     OUT VARCHAR2) IS   --Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_log             Antigo: dbo/b1crap22.p/gera-log
  --  Sistema  : Procedure para gravar log
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: 07/08/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para gravar log

  -- Alteracoes: 26/03/2014 - Retirar controle de sequencia na crapldt (Gabriel).
  
  --             07/08/2014 - Incluido parametro pr_cdpacrem para diferenciar TAA
  --                          do Caixa-Online. (Andre Santos - SUPERO)
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE

      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      --Tipo de Dados para cursor cooperativa
      rw_crabcop  cr_crapcop%ROWTYPE;
      --Tipo de Dados para cursor data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Se a cooperativa origem nao existir
      OPEN cr_crapcop(pr_cdcooper => pr_cooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        pr_cdcritic:= 651;
        pr_dscritic:= 'Registro de cooperativa origem nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      --Se a cooperativa destino nao existir
      OPEN cr_crapcop(pr_cdcooper => pr_cooper_dest);
      FETCH cr_crapcop INTO rw_crabcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        pr_cdcritic:= 0;
        pr_dscritic:= 'Registro de cooperativa destino nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n¿o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      --Criar registro log depositos e transferencias entre cooperativas
      BEGIN
        INSERT INTO crapldt
          (crapldt.cdcooper
          ,crapldt.cdagerem
          ,crapldt.nrctarem
          ,crapldt.cdagedst
          ,crapldt.nrctadst
          ,crapldt.tpoperac
          ,crapldt.cdoperad
          ,crapldt.cdpacrem
          ,crapldt.dttransa
          ,crapldt.hrtransa
          ,crapldt.vllanmto
          ,crapldt.nrdocmto
          ,crapldt.nrsequen)
        VALUES
          (rw_crapcop.cdcooper
          ,rw_crapcop.cdagectl
          ,pr_nrdcontade
          ,rw_crabcop.cdagectl
          ,pr_nrdcontapara
          ,pr_tpoperac
          ,pr_operador
          ,pr_cdpacrem
          ,rw_crapdat.dtmvtocd
          ,gene0002.fn_busca_time
          ,pr_valor
          ,pr_nrdocmto
          ,fn_sequence('CRAPLDT','NRSEQUEN',rw_crapcop.cdcooper || ';' ||
                                            rw_crapcop.cdagectl || ';' ||
                                            pr_nrdcontade       || ';' ||
                                            pr_tpoperac));
      EXCEPTION
        WHEN Others THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao inserir na tabela crapldt. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0022.pc_gera_log. '||SQLERRM;
    END;
  END pc_gera_log;


  /* Procedure para realizar transferencia */
  PROCEDURE pc_realiza_transferencia (pr_cooper             IN INTEGER --Codigo Cooperativa
                                     ,pr_cod_agencia        IN INTEGER --Codigo Agencia
                                     ,pr_nro_caixa          IN INTEGER --Numero do caixa
                                     ,pr_cod_operador       IN VARCHAR2 --Codigo Operador
                                     ,pr_idorigem           IN INTEGER  --Origem transacao
                                     ,pr_cooper_dest        IN INTEGER  --Codigo Cooperativa
                                     ,pr_nrdcontade         IN INTEGER  --Numero Conta destino
                                     ,pr_idseqttl           IN INTEGER  --Sequencial do Titular
                                     ,pr_nrdcontapara       IN INTEGER  --Conta de Destino
                                     ,pr_valor              IN OUT NUMBER   --Valor da transacao
                                     ,pr_nrsequni           IN INTEGER  --Numero Sequencial
                                     ,pr_idagenda           IN INTEGER  --Indicador Agendamento
                                     ,pr_cdcoptfn           IN INTEGER  --Codigo Cooperativa
                                     ,pr_nrterfin           IN INTEGER  --Numero do terminal
 									                   ,pr_flmobile           IN INTEGER  --Indicador Mobile
									                   ,pr_idtipcar           IN INTEGER  --Indicador Tipo Cartão Utilizado
									                   ,pr_nrcartao           IN NUMBER   --Numero Cartao
                                     ,pr_literal_autentica  OUT VARCHAR2 --Numero literal autenticacao
                                     ,pr_ult_seq_autentica  OUT INTEGER  --Sequencial autenticacao
                                     ,pr_nro_docto          OUT NUMBER   --Numero do Documento
                                     ,pr_nro_docto_cred     OUT NUMBER   --Numero documento credito
                                     ,pr_cdlantar           OUT craplat.cdlantar%type --C¿digo lancamento tarifa
                                     ,pr_reg_lcm_deb        OUT ROWID    --ROWID do registro lancamento debito
                                     ,pr_reg_lcm_cre        OUT ROWID    --ROWID do registro lancamento credito
                                     ,pr_nrultaut           OUT INTEGER  --Numero Ultima Autorizacao
                                     ,pr_cdcritic           OUT INTEGER     --C¿digo do erro
                                     ,pr_dscritic           OUT VARCHAR2) IS   --Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_realiza_transferencia    Antigo: dbo/b1crap22.p/realiza-transferencia
  --  Sistema  : Procedure para realizar transferencia
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: 12/12/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para realizar transferencia
  -- Atualizacoes:
  --                 11/07/2013   Alteracoes na procedure realiza-transferencia:
  --                        - Tratado undo de transa¿¿o para chamada da procedure
  --                          grava-autenticacao-internet.
  --                        - Campo craplcm.hrtransa alimentado com TIME (Lucas).
  --
  --                 28/08/2013 - Adequacao das alteracoes progress - Alisson (AMcom)
  --
  --                 24/10/2014 - Ajustes ao realiar insert na craplot para retornar todas as informações
  --                              que seriam lidas pelo cursor - SD 205294(Odirlei/Amcom)
  --
  --
  --                 02/09/2015 - Correção conversao para testar se existe duplicidade do histor 1009 antes
  --                              de gerar o registro (Odirlei-AMcom)
  --
  --                 06/10/2015 - Ajustes para tratar insert e update na tabela craplot, diminuindo o tempo de lock
  --                              (Odirlei-AMcom)
  --
  --                 04/02/2016 - Aumento no tempo de verificacao de Transferencia duplicada. 
  --                              De 30 seg. para 10 min. (Jorge/David) - SD 397867     
  --
  --                14/11/2016 - Alterado cdorigem 9 para 10, novo cdorigem especifico para mobile
  --                             PRJ335 - Analise de Fraude(Odirlei-AMcom)
  --
  --                 12/12/2017 - Passar como texto o campo nrcartao na chamada da procedure 
  --                              pc_gera_log_ope_cartao (Lucas Ranghetti #810576)
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE

      --Tipo de tabela para vetor literal
      TYPE typ_tab_literal IS table of VARCHAR2(100) index by PLS_INTEGER;
      --Vetor de memoria do literal
      vr_tab_literal typ_tab_literal;
      --Cursores Locais

      --Selecionar informacoes dos boletins dos caixas
      CURSOR cr_crapbcx (pr_cdcooper IN crapbcx.cdcooper%type
                        ,pr_dtmvtolt IN crapbcx.dtmvtolt%type
                        ,pr_cdagenci IN crapbcx.cdagenci%type
                        ,pr_nrdcaixa IN crapbcx.nrdcaixa%type
                        ,pr_cdopecxa IN crapbcx.cdopecxa%type
                        ,pr_cdsitbcx IN crapbcx.cdsitbcx%type) IS
        SELECT crapbcx.qtcompln
              ,crapbcx.nrdmaqui
              ,crapbcx.ROWID
        FROM crapbcx
        WHERE crapbcx.cdcooper = pr_cdcooper
        AND   crapbcx.dtmvtolt = pr_dtmvtolt
        AND   crapbcx.cdagenci = pr_cdagenci
        AND   crapbcx.nrdcaixa = pr_nrdcaixa
        AND   UPPER(crapbcx.cdopecxa) = UPPER(pr_cdopecxa)
        AND   crapbcx.cdsitbcx = pr_cdsitbcx;
      rw_crapbcx cr_crapbcx%ROWTYPE;

      --Selecionar informacoes sequencial unico
      CURSOR cr_crapnsu (pr_cdcooper IN crapcop.cdcooper%type) IS
        SELECT crapnsu.cdcooper
              ,crapnsu.nrsequni
              ,crapnsu.rowid
        FROM crapnsu
        WHERE crapnsu.cdcooper = pr_cdcooper;
      rw_crapnsu cr_crapnsu%ROWTYPE;

      --Selecionar informacoes dos lancamentos
      CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%type
                        ,pr_dtmvtolt IN craplcm.dtmvtolt%type
                        ,pr_cdagenci IN craplcm.cdagenci%type
                        ,pr_cdbccxlt IN craplcm.cdbccxlt%type
                        ,pr_nrdolote IN craplcm.nrdolote%type
                        ,pr_nrseqdig IN craplcm.nrseqdig%type) IS
        SELECT craplcm.cdcooper
              ,craplcm.cdcoptfn
              ,craplcm.cdagetfn
              ,craplcm.nrterfin
              ,craplcm.nrsequni
              ,craplcm.nrdocmto
              ,craplcm.nrautdoc
              ,craplcm.cdpesqbb
              ,craplcm.dsidenti
			  ,craplcm.cdhistor
              ,craplcm.rowid
        FROM craplcm
        WHERE  craplcm.cdcooper = pr_cdcooper
        AND    craplcm.dtmvtolt = pr_dtmvtolt
        AND    craplcm.cdagenci = pr_cdagenci
        AND    craplcm.cdbccxlt = pr_cdbccxlt
        AND    craplcm.nrdolote = pr_nrdolote
        AND    craplcm.nrseqdig = pr_nrseqdig;
      rw_craplcm cr_craplcm%ROWTYPE;
      
     CURSOR cr_craplcm_dup(pr_cdcooper IN craplcm.cdcooper%TYPE
                          ,pr_nrdconta IN craplcm.nrdconta%TYPE
                          ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                          ,pr_vllanmto IN craplcm.vllanmto%TYPE
                          ,pr_cdagectl IN crapcop.cdagectl%TYPE
                          ,pr_nrdctabb IN craplcm.nrdctabb%TYPE) IS
      SELECT MAX(lcm.hrtransa)
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.nrdconta = pr_nrdconta
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.cdhistor = 1009            
         AND lcm.vllanmto = pr_vllanmto
         AND to_number(SUBSTR(lcm.cdpesqbb,10)) = pr_cdagectl
         AND lcm.nrdctabb = pr_nrdctabb;
      vr_hrtransa_dup craplcm.hrtransa%TYPE;

      --Selecionar informacoes dos bancos
      CURSOR cr_crapban (pr_cdbccxlt IN crapban.cdbccxlt%type) IS
        SELECT crapban.nmresbcc
        FROM crapban
        WHERE crapban.cdbccxlt = pr_cdbccxlt;
      rw_crapban cr_crapban%ROWTYPE;

      --Selecionar informacoes das agencias bancarias
      CURSOR cr_crapagb (pr_cdageban IN crapagb.cdageban%type
                        ,pr_cddbanco IN crapagb.cddbanco%type) IS
        SELECT crapagb.nmageban
        FROM crapagb
        WHERE crapagb.cdageban = pr_cdageban
        AND   crapagb.cddbanco = pr_cddbanco;
      rw_crapagb cr_crapagb%ROWTYPE;

	  CURSOR cr_crapttl(pr_cdcooper crapttl.cdcooper%TYPE
	                   ,pr_nrdconta crapttl.nrdconta%TYPE)IS
	  SELECT crapttl.nmextttl
	        ,crapttl.nrcpfcgc
	    FROM crapttl
	   WHERE crapttl.cdcooper = pr_cdcooper
	     AND crapttl.nrdconta = pr_nrdconta
		 AND crapttl.idseqttl = 2;
	  rw_crapttl cr_crapttl%ROWTYPE;

      --Variaveis Locais
      vr_desc_banco        crapban.nmresbcc%type;
      vr_desc_agencia1     VARCHAR2(38);
      vr_desc_agencia2     VARCHAR2(38);
      vr_vltarifa          NUMBER;
      vr_nrdcaixa          NUMBER;
      vr_flg_vertexto      BOOLEAN;
      vr_nrterfin          craptfn.nrterfin%type;
      vr_cdcoptfn          craptfn.cdcooper%type;
      vr_cdagetfn          craptfn.cdagenci%type;
      vr_cgc_para_1        crapass.nrcpfcgc%TYPE;
      vr_cgc_para_2        crapttl.nrcpfcgc%TYPE;
      vr_index             INTEGER;
      vr_cdorigem          INTEGER;			
      vr_nro_lote          INTEGER;
      vr_cdhisdeb          INTEGER;
      vr_cdhistor          INTEGER;
      vr_cdhisest          INTEGER;
      vr_cdfvlcop          INTEGER;
      vr_texto_2_via       LONG;
      vr_literal           VARCHAR2(1000);
      vr_literal_lcm       VARCHAR2(1000);
      vr_ult_sequencia     INTEGER;
      vr_ult_sequencia_lcm INTEGER;
      vr_registro_lcm_cre  ROWID;
      vr_registro_lcm_deb  ROWID;
	  vr_nmsegntl          crapttl.nmextttl%TYPE;

      --Tipo de Dados para cursor cooperativa
      rw_crabcop  cr_crapcop%ROWTYPE;
      --Tipo de Dados para cursor data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
      --Tipo de Dados para cursor associado
      rw_crabass  cr_crapass%ROWTYPE;
      --Variaveis de Erro
      vr_tab_erro GENE0001.typ_tab_erro;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      
      -- Procedimento para inserir o lote e não deixar tabela lockada
      PROCEDURE pc_insere_lote (pr_cdcooper IN craplot.cdcooper%TYPE,
                                pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                                pr_cdagenci IN craplot.cdagenci%TYPE,
                                pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                                pr_nrdolote IN craplot.nrdolote%TYPE,
                                pr_cdoperad IN craplot.cdoperad%TYPE,
                                pr_nrdcaixa IN craplot.nrdcaixa%TYPE,
                                pr_tplotmov IN craplot.tplotmov%TYPE,
                                pr_cdhistor IN craplot.cdhistor%TYPE,
                                pr_craplot  OUT cr_craplot%ROWTYPE,
                                pr_dscritic OUT VARCHAR2)IS

        -- Pragma - abre nova sessao para tratar a atualizacao
        PRAGMA AUTONOMOUS_TRANSACTION;
        -- criar rowtype controle
        rw_craplot_ctl cr_craplot%ROWTYPE;

      BEGIN

        /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */ 
        FOR i IN 1..100 LOOP
          BEGIN
            -- Leitura do lote
            OPEN cr_craplot (pr_cdcooper  => pr_cdcooper,
                             pr_dtmvtolt  => pr_dtmvtolt,
                             pr_cdagenci  => pr_cdagenci,
                             pr_cdbccxlt  => pr_cdbccxlt,
                             pr_nrdolote  => pr_nrdolote);
            FETCH cr_craplot INTO rw_craplot_ctl;
            pr_dscritic := NULL;
            EXIT;
          EXCEPTION
            WHEN OTHERS THEN
               IF cr_craplot%ISOPEN THEN
                 CLOSE cr_craplot;
               END IF;

               -- setar critica caso for o ultimo
               IF i = 100 THEN
                 pr_dscritic:= pr_dscritic||'Registro de lote '||pr_nrdolote||' em uso. Tente novamente.';
               END IF;
               -- aguardar 0,5 seg. antes de tentar novamente
               sys.dbms_lock.sleep(0.1);
          END;
        END LOOP;

        -- se encontrou erro ao buscar lote, abortar programa
        IF pr_dscritic IS NOT NULL THEN
          ROLLBACK;
          RETURN;
        END IF;

        IF cr_craplot%NOTFOUND THEN
          -- criar registros de lote na tabela
          INSERT INTO craplot
                  (craplot.cdcooper
                  ,craplot.dtmvtolt
                  ,craplot.cdagenci
                  ,craplot.cdbccxlt
                  ,craplot.nrdolote
                  ,craplot.nrseqdig
                  ,craplot.tplotmov
                  ,craplot.cdoperad
                  ,craplot.cdhistor
                  ,craplot.nrdcaixa
                  ,craplot.cdopecxa)
          VALUES  (pr_cdcooper
                  ,pr_dtmvtolt
                  ,pr_cdagenci
                  ,pr_cdbccxlt
                  ,pr_nrdolote
                  ,1  -- craplot.nrseqdig
                  ,pr_tplotmov
                  ,pr_cdoperad
                  ,pr_cdhistor
                  ,pr_nrdcaixa
                  ,pr_cdoperad)
             RETURNING  craplot.ROWID
                       ,craplot.nrdolote
                       ,craplot.nrseqdig
                       ,craplot.cdbccxlt
                       ,craplot.tplotmov
                       ,craplot.dtmvtolt
                       ,craplot.cdagenci
                       ,craplot.cdhistor
                       ,craplot.cdoperad
                       ,craplot.qtcompln
                       ,craplot.qtinfoln
                       ,craplot.vlcompcr
                       ,craplot.vlinfocr
                   INTO rw_craplot_ctl.ROWID
                      , rw_craplot_ctl.nrdolote
                      , rw_craplot_ctl.nrseqdig
                      , rw_craplot_ctl.cdbccxlt
                      , rw_craplot_ctl.tplotmov
                      , rw_craplot_ctl.dtmvtolt
                      , rw_craplot_ctl.cdagenci
                      , rw_craplot_ctl.cdhistor
                      , rw_craplot_ctl.cdoperad
                      , rw_craplot_ctl.qtcompln
                      , rw_craplot_ctl.qtinfoln
                      , rw_craplot_ctl.vlcompcr
                      , rw_craplot_ctl.vlinfocr;
        ELSE
          -- ou atualizar o nrseqdig para reservar posição
          UPDATE craplot
             SET craplot.nrseqdig = Nvl(craplot.nrseqdig,0) + 1
           WHERE craplot.ROWID = rw_craplot_ctl.ROWID
           RETURNING craplot.nrseqdig INTO rw_craplot_ctl.nrseqdig;
        END IF;

        CLOSE cr_craplot;
        
        -- retornar informações para o programa chamador
        pr_craplot := rw_craplot_ctl;

        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          IF cr_craplot%ISOPEN THEN
            CLOSE cr_craplot;
          END IF;
          ROLLBACK;
          -- se ocorreu algum erro durante a criac?o
          pr_dscritic := 'Erro ao gravar craplot('|| pr_nrdolote||'): '||SQLERRM;
      END pc_insere_lote;
      
      
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      /* Tratamento de erros para internet e TAA */
      IF pr_idorigem = 2 THEN  /* Caixa online */
        vr_nrdcaixa:= pr_nro_caixa;
      ELSE                         /** Internet / TAA **/
         vr_nrdcaixa:= to_number(To_Char(pr_nrdcontade) || To_Char(pr_idseqttl));
      END IF;
      
      -- Save point
      SAVEPOINT real_trans;
      
      --Se a cooperativa origem nao existir
      OPEN cr_crapcop(pr_cdcooper => pr_cooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
         vr_cdcritic:= 651;
         vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         -- Desfaz as alterações
         ROLLBACK TO real_trans;
         RAISE vr_exc_erro;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;
      --Se a cooperativa destino nao existir
      OPEN cr_crapcop(pr_cdcooper => pr_cooper_dest);
      FETCH cr_crapcop INTO rw_crabcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Cooperativa de destino nao cadastrada.';
        -- Desfaz as alterações
        ROLLBACK TO real_trans;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n¿o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Desfaz as alterações
        ROLLBACK TO real_trans;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;      
      
      /*** Informacoes da conta de origem **/
      OPEN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper
                     ,pr_nrdconta => pr_nrdcontade);
      FETCH cr_crapass INTO rw_crapass;
      --Se nao encontrou associado
      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic:= 9;
        vr_dscritic:=  gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        --Fechar Cursor
        CLOSE cr_crapass;
        -- Desfaz as alterações
        ROLLBACK TO real_trans;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;
      /** Informacoes da conta de destino **/
      OPEN cr_crapass(pr_cdcooper => rw_crabcop.cdcooper
                     ,pr_nrdconta => pr_nrdcontapara);
      FETCH cr_crapass INTO rw_crabass;
      --Se nao encontrou associado
      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Conta de destino nao cadastrada.';
        --Fechar Cursor
        CLOSE cr_crapass;
        -- Desfaz as alterações
        ROLLBACK TO real_trans;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;
      /* Validar para criar o lancamento ao fim da procedure */
      --Selecionar informacoes dos boletins dos caixas
      OPEN cr_crapbcx (pr_cdcooper => rw_crapcop.cdcooper
                      ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                      ,pr_cdagenci => pr_cod_agencia
                      ,pr_nrdcaixa => pr_nro_caixa
                      ,pr_cdopecxa => pr_cod_operador
                      ,pr_cdsitbcx => 1);
      --Posicionar no proximo registro
      FETCH cr_crapbcx INTO rw_crapbcx;
      --Se nao encontrar
      IF cr_crapbcx%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapbcx;
        vr_dscritic := '698 - Boletim de caixa nao esta aberto. Coop:'|| rw_crapcop.cdcooper || ' Dt:'|| rw_crapdat.dtmvtocd || ' Ag:' || pr_cod_agencia || ' Cx:' || pr_nro_caixa || ' Op:' || pr_cod_operador;
        -- Desfaz as alterações
        ROLLBACK TO real_trans;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapbcx;

      /* TAA e numero do terminal prenchido */
      IF pr_idorigem  = 4 AND pr_nrterfin <> 0 THEN
        --Encontrar o numero do terminal
        OPEN cr_craptfn (pr_cdcoptfn => pr_cdcoptfn
                        ,pr_nrterfin => pr_nrterfin);
        --Posicionar no proximo registro
        FETCH cr_craptfn INTO rw_craptfn;
        --Se nao encontrar
        IF cr_craptfn%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_craptfn;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Terminal Financeiro nao cadastrado.';
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          --Numero terminal
          vr_nrterfin:= rw_craptfn.nrterfin;
          --Cooperativa do terminal
          vr_cdcoptfn:= rw_craptfn.cdcooper;
          --Agencia do terminal
          vr_cdagetfn:= rw_craptfn.cdagenci;
        END IF;
        --Fechar Cursor
        CLOSE cr_craptfn;
      ELSIF pr_idorigem = 4 THEN
        --Codigo Cooperativa transferencia
        vr_cdcoptfn:= pr_cdcoptfn;
      END IF;

      /*** Transferencia para mesma cooperativa ***/
      IF  pr_cooper = pr_cooper_dest THEN
        --Numero do lote
        vr_nro_lote:= 11000 + pr_nro_caixa;
        vr_flg_vertexto:= FALSE;

        if not paga0001.fn_exec_paralelo then 
          --Selecionar informacoes do lote ou cria-lo caso nao exista
          pc_insere_lote (pr_cdcooper => rw_crabcop.cdcooper,
                          pr_dtmvtolt => rw_crapdat.dtmvtocd,
                          pr_cdagenci => pr_cod_agencia,
                          pr_cdbccxlt => 11,
                          pr_nrdolote => vr_nro_lote,
                          pr_cdoperad => pr_cod_operador,
                          pr_nrdcaixa => pr_nro_caixa,
                          pr_tplotmov => 1,
                          pr_cdhistor => 0,
                          pr_craplot  => rw_craplot_ori,
                          pr_dscritic => vr_dscritic);
                        
        else
          paga0001.pc_insere_lote_wrk(pr_cdcooper => rw_crabcop.cdcooper,
                                      pr_dtmvtolt => rw_crapdat.dtmvtocd,
                                      pr_cdagenci => pr_cod_agencia,
                                      pr_cdbccxlt => 11,
                                      pr_nrdolote => vr_nro_lote,
                                      pr_cdoperad => pr_cod_operador,
                                      pr_nrdcaixa => pr_nro_caixa,
                                      pr_tplotmov => 1,
                                      pr_cdhistor => 0,
                                      pr_cdbccxpg => null,
                                      pr_nmrotina => 'CXON0022.PC_REALIZA_TRANSFERENCIA');
          
          rw_craplot_ori.dtmvtolt := rw_crapdat.dtmvtocd;
          rw_craplot_ori.cdagenci := pr_cod_agencia;
          rw_craplot_ori.cdbccxlt := 11;
          rw_craplot_ori.nrdolote := vr_nro_lote;
          rw_craplot_ori.cdoperad := pr_cod_operador;
               
          rw_craplot_ori.nrseqdig := paga0001.fn_seq_parale_craplcm; 
        end if;                                             
        -- se encontrou erro ao buscar lote, abortar programa
        IF vr_dscritic IS NOT NULL THEN
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
                        
        --Determinar numero documento
        pr_nro_docto:= nvl(rw_craplot_ori.nrseqdig,0);
                                
        /*--- Grava Autenticacao PG --*/
        CXON0000.pc_grava_autenticacao_internet (pr_cooper       => pr_cooper      --Codigo Cooperativa
                                                ,pr_nrdconta     => pr_nrdcontade  --Numero da Conta
                                                ,pr_idseqttl     => pr_idseqttl    --Sequencial do titular
                                                ,pr_cod_agencia  => pr_cod_agencia  --Codigo Agencia
                                                ,pr_nro_caixa    => pr_nro_caixa    --Numero do caixa
                                                ,pr_cod_operador => pr_cod_operador --Codigo Operador
                                                ,pr_valor        => pr_valor        --Valor da transacao
                                                ,pr_docto        => pr_nro_docto    --Numero documento
                                                ,pr_operacao     => TRUE            --Indicador Operacao Debito
                                                ,pr_status       => '1'             --Status da Operacao - Online
                                                ,pr_estorno      => FALSE           --Indicador Estorno
                                                ,pr_histor       => 1014            --Historico Debito
                                                ,pr_data_off     => NULL            --Data Transacao
                                                ,pr_sequen_off   => 0               --Sequencia
                                                ,pr_hora_off     => 0               --Hora transacao
                                                ,pr_seq_aut_off  => 0               --Sequencia automatica
                                                ,pr_cdempres     => NULL            --Descricao Observacao
                                                ,pr_literal      => vr_literal_lcm     --Descricao literal lcm
                                                ,pr_sequencia    => vr_ult_sequencia_lcm    --Sequencia
                                                ,pr_registro     => pr_reg_lcm_deb    --ROWID do registro debito
                                                ,pr_cdcritic     => vr_cdcritic    --C¿digo do erro
                                                ,pr_dscritic     => vr_dscritic);  --Descricao do erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        /** Lancamento conta origem **/
        --Selecionar informacoes lancamentos
        OPEN cr_craplcm (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                        ,pr_cdagenci => To_Number(pr_cod_agencia)
                        ,pr_cdbccxlt => 11
                        ,pr_nrdolote => vr_nro_lote
                        ,pr_nrseqdig => nvl(rw_craplot_ori.nrseqdig,0) );
        --Posicionar no proximo registro
        FETCH cr_craplcm INTO rw_craplcm;
        --Se nao encontrar
        IF cr_craplcm%FOUND THEN
          --Fechar Cursor
          CLOSE cr_craplcm;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Lancamento ja existente.';
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_craplcm;

        /* Cria o lancamento do DEBITO */
        BEGIN
          INSERT INTO craplcm
             (craplcm.cdcooper
             ,craplcm.dtmvtolt
             ,craplcm.cdagenci
             ,craplcm.cdbccxlt
             ,craplcm.nrdolote
             ,craplcm.nrdconta
             ,craplcm.nrdocmto
             ,craplcm.vllanmto
             ,craplcm.cdhistor
             ,craplcm.nrseqdig
             ,craplcm.nrsequni
             ,craplcm.nrdctabb
             ,craplcm.nrautdoc
             ,craplcm.cdpesqbb
             ,craplcm.nrdctitg
             ,craplcm.cdcoptfn
             ,craplcm.cdagetfn
             ,craplcm.nrterfin
             ,craplcm.hrtransa
             ,craplcm.cdoperad)
          VALUES
             (rw_crapcop.cdcooper             --cdcooper
             ,rw_crapdat.dtmvtocd             --dtmvtolt
             ,pr_cod_agencia                  --cdagenci
             ,11                              --cdbccxlt
             ,vr_nro_lote                     --nrdolote
             ,pr_nrdcontade                   --nrdconta
             ,pr_nro_docto                    --nrdocmto
             ,pr_valor                        --vllanmto
             ,1014                            --cdhistor
             ,nvl(rw_craplot_ori.nrseqdig,0)      --nrseqdig
             ,nvl(rw_craplot_ori.nrseqdig,0)      --nrsequni
             ,pr_nrdcontapara                 --nrdctabb
             ,nvl(vr_ult_sequencia_lcm,0)     --nrautdoc
             ,'CRAP22'                        --cdpesqbb
             ,0                               --nrdctitg
             ,rw_crapcop.cdcooper             --cdcoptfn
             ,pr_cod_agencia                  --cdagetfn
             ,0                               --nrterfin
             ,GENE0002.fn_busca_time          --hrtransa
             ,pr_cod_operador)                --cdoperad
          RETURNING craplcm.ROWID
                   ,craplcm.cdpesqbb
                   ,craplcm.cdcoptfn
                   ,craplcm.cdagetfn
                   ,craplcm.nrterfin
                   ,craplcm.nrsequni
                   ,craplcm.nrautdoc
				   ,craplcm.cdhistor
          INTO rw_craplcm.ROWID
               ,rw_craplcm.cdpesqbb
               ,rw_craplcm.cdcoptfn
               ,rw_craplcm.cdagetfn
               ,rw_craplcm.nrterfin
               ,rw_craplcm.nrsequni
               ,rw_craplcm.nrautdoc
			   ,rw_craplcm.cdhistor;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao inserir na tabela craplcm. '||sqlerrm;
            -- Desfaz as alterações
            ROLLBACK TO real_trans;
            --Levantar Excecao
           RAISE vr_exc_erro;
        END;

		vr_cdhisdeb := rw_craplcm.cdhistor;

        IF pr_idagenda > 1 THEN
          rw_craplcm.cdpesqbb:= rw_craplcm.cdpesqbb ||' AGENDADO';
        END IF;
        IF pr_idorigem = 4 THEN
          --Informacoes terminal fianceiro
          rw_craplcm.cdcoptfn:= vr_cdcoptfn;
          rw_craplcm.cdagetfn:= vr_cdagetfn;
          rw_craplcm.nrterfin:= vr_nrterfin;

          IF rw_craplcm.nrterfin <> 0 THEN
            BEGIN
              UPDATE craptfn SET nrultaut = craptfn.nrultaut + 1
              WHERE craptfn.ROWID = rw_craptfn.ROWID
              RETURNING craptfn.nrultaut INTO rw_craptfn.nrultaut;
            EXCEPTION
              WHEN Others THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar tabela craptfn.'||sqlerrm;
                -- Desfaz as alterações
                ROLLBACK TO real_trans;
                --Levantar Excecao
                RAISE vr_exc_erro;
            END;
            rw_craplcm.nrsequni:= pr_nrsequni;
            rw_craplcm.nrautdoc:= rw_craptfn.nrultaut;
            pr_nrultaut:= rw_craptfn.nrultaut;
          END IF;
        END IF;

        --Atualizar tabela craplcm
        BEGIN
          UPDATE craplcm SET craplcm.cdpesqbb = rw_craplcm.cdpesqbb
                            ,craplcm.cdcoptfn = rw_craplcm.cdcoptfn
                            ,craplcm.cdagetfn = rw_craplcm.cdagetfn
                            ,craplcm.nrterfin = rw_craplcm.nrterfin
                            ,craplcm.nrsequni = rw_craplcm.nrsequni
                            ,craplcm.nrautdoc = nvl(rw_craplcm.nrautdoc,0)
          WHERE craplcm.ROWID = rw_craplcm.ROWID;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela craplcm.'||sqlerrm;
            -- Desfaz as alterações
            ROLLBACK TO real_trans;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;

        /**** Lancamento conta destino ****/
        
        -- Selecionar informacoes do lote ou cria-lo caso nao exista
        -- Necessario para incrementar nrseqdig
        if not paga0001.fn_exec_paralelo then
          pc_insere_lote (pr_cdcooper => rw_crabcop.cdcooper,
                          pr_dtmvtolt => rw_crapdat.dtmvtocd,
                          pr_cdagenci => pr_cod_agencia,
                          pr_cdbccxlt => 11,
                          pr_nrdolote => vr_nro_lote,
                          pr_cdoperad => pr_cod_operador,
                          pr_nrdcaixa => pr_nro_caixa,
                          pr_tplotmov => 1,
                          pr_cdhistor => 0,
                          pr_craplot  => rw_craplot_dst,
                          pr_dscritic => vr_dscritic);
         else
         
           paga0001.pc_insere_lote_wrk (pr_cdcooper => rw_crabcop.cdcooper,
                                        pr_dtmvtolt => rw_crapdat.dtmvtocd,
                                        pr_cdagenci => pr_cod_agencia,
                                        pr_cdbccxlt => 11,
                                        pr_nrdolote => vr_nro_lote,
                                        pr_cdoperad => pr_cod_operador,
                                        pr_nrdcaixa => pr_nro_caixa,
                                        pr_tplotmov => 1,
                                        pr_cdhistor => 0,
                                        pr_cdbccxpg => null,
                                        pr_nmrotina => 'CXON0022.PC_REALIZA_TRANSFERENCIA');
        
           rw_craplot_dst.dtmvtolt := rw_crapdat.dtmvtocd;
           rw_craplot_dst.cdagenci := pr_cod_agencia;
           rw_craplot_dst.cdbccxlt := 11;
           rw_craplot_dst.nrdolote := vr_nro_lote;
           rw_craplot_dst.cdoperad := pr_cod_operador;
           rw_craplot_dst.tplotmov := 1;
           rw_craplot_dst.cdhistor := 0;
           
           rw_craplot_dst.nrseqdig := paga0001.fn_seq_parale_craplcm; 
         end if;
                        
        -- se encontrou erro ao buscar lote, abortar programa
        IF vr_dscritic IS NOT NULL THEN
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        
        --Selecionar informacoes lancamentos
        OPEN cr_craplcm (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                        ,pr_cdagenci => To_Number(pr_cod_agencia)
                        ,pr_cdbccxlt => 11
                        ,pr_nrdolote => vr_nro_lote
                        ,pr_nrseqdig => Nvl(rw_craplot_dst.nrseqdig,0));
        --Posicionar no proximo registro
        FETCH cr_craplcm INTO rw_craplcm;
        --Se nao encontrar
        IF cr_craplcm%FOUND THEN
          --Fechar Cursor
          CLOSE cr_craplcm;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Lancamento ja existente.';
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_craplcm;

        /*--- Grava Autenticacao RC --*/
        CXON0000.pc_grava_autenticacao_internet (pr_cooper       => pr_cooper      --Codigo Cooperativa
                                                ,pr_nrdconta     => pr_nrdcontade  --Numero da Conta
                                                ,pr_idseqttl     => pr_idseqttl    --Sequencial do titular
                                                ,pr_cod_agencia  => pr_cod_agencia  --Codigo Agencia
                                                ,pr_nro_caixa    => pr_nro_caixa    --Numero do caixa
                                                ,pr_cod_operador => pr_cod_operador --Codigo Operador
                                                ,pr_valor        => pr_valor        --Valor da transacao
                                                ,pr_docto        => pr_nro_docto   --Numero documento
                                                ,pr_operacao     => FALSE            --Indicador Operacao Debito
                                                ,pr_status       => '1'            --Status da Operacao - Online
                                                ,pr_estorno      => FALSE          --Indicador Estorno
                                                ,pr_histor       => 1015          --Historico Credito
                                                ,pr_data_off     => NULL           --Data Transacao
                                                ,pr_sequen_off   => 0              --Sequencia
                                                ,pr_hora_off     => 0              --Hora transacao
                                                ,pr_seq_aut_off  => 0              --Sequencia automatica
                                                ,pr_cdempres     => NULL           --Descricao Observacao
                                                ,pr_literal      => vr_literal     --Descricao literal lcm
                                                ,pr_sequencia    => vr_ult_sequencia    --Sequencia
                                                ,pr_registro     => pr_reg_lcm_cre    --ROWID do registro debito
                                                ,pr_cdcritic     => vr_cdcritic    --C¿digo do erro
                                                ,pr_dscritic     => vr_dscritic);  --Descricao do erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        /* Cria o lancamento do CREDITO*/
        BEGIN
          INSERT INTO craplcm
             (craplcm.cdcooper
             ,craplcm.dtmvtolt
             ,craplcm.cdagenci
             ,craplcm.cdbccxlt
             ,craplcm.nrdolote
             ,craplcm.nrdconta
             ,craplcm.nrdocmto
             ,craplcm.vllanmto
             ,craplcm.cdhistor
             ,craplcm.nrseqdig
             ,craplcm.nrsequni
             ,craplcm.nrdctabb
             ,craplcm.nrautdoc
             ,craplcm.cdpesqbb
             ,craplcm.cdcoptfn
             ,craplcm.cdagetfn
             ,craplcm.nrterfin
             ,craplcm.hrtransa
             ,craplcm.cdoperad)
          VALUES
             (rw_crapcop.cdcooper        --cdcooper
             ,rw_crapdat.dtmvtocd        --dtmvtolt
             ,pr_cod_agencia             --cdagenci
             ,11                         --cdbccxlt
             ,vr_nro_lote                --nrdolote
             ,pr_nrdcontapara            --nrdconta
             ,pr_nro_docto               --nrdocmto
             ,pr_valor                   --vllanmto
             ,1015                       --cdhistor
             ,Nvl(rw_craplot_dst.nrseqdig,0) --nrseqdig
             ,Nvl(rw_craplot_dst.nrseqdig,0) --nrsequni
             ,pr_nrdcontade              --nrdctabb
             ,nvl(vr_ult_sequencia,0)    --nrautdoc
             ,'CRAP22'                   --cdpesqbb
             ,rw_crapcop.cdcooper        --cdcoptfn
             ,pr_cod_agencia             --cdagetfn
             ,0                          --nrterfin
             ,GENE0002.fn_busca_time     --hrtransa
             ,pr_cod_operador)           --cdoperad
          RETURNING craplcm.ROWID
                   ,craplcm.cdpesqbb
                   ,craplcm.cdcoptfn
                   ,craplcm.cdagetfn
                   ,craplcm.nrterfin
                   ,craplcm.nrsequni
                   ,craplcm.nrautdoc
          INTO rw_craplcm.ROWID
               ,rw_craplcm.cdpesqbb
               ,rw_craplcm.cdcoptfn
               ,rw_craplcm.cdagetfn
               ,rw_craplcm.nrterfin
               ,rw_craplcm.nrsequni
               ,rw_craplcm.nrautdoc;

        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao inserir na tabela craplcm. '||sqlerrm;
            -- Desfaz as alterações
            ROLLBACK TO real_trans;
            --Levantar Excecao
           RAISE vr_exc_erro;
        END;
        --For agendado
        IF pr_idagenda > 1 THEN
          rw_craplcm.cdpesqbb:= rw_craplcm.cdpesqbb ||' AGENDADO';
        END IF;
        IF pr_idorigem = 4 THEN
          --Informacoes terminal fianceiro
          rw_craplcm.cdcoptfn:= vr_cdcoptfn;
          rw_craplcm.cdagetfn:= vr_cdagetfn;
          rw_craplcm.nrterfin:= vr_nrterfin;
          --Existe numero terminal fincanceiro
          IF rw_craplcm.nrterfin <> 0 THEN
            BEGIN
              UPDATE craptfn SET nrultaut = Nvl(craptfn.nrultaut,0) + 1
              WHERE craptfn.ROWID = rw_craptfn.ROWID
              RETURNING craptfn.nrultaut INTO rw_craptfn.nrultaut;
            EXCEPTION
              WHEN Others THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar tabela craptfn.'||sqlerrm;
                -- Desfaz as alterações
                ROLLBACK TO real_trans;
                --Levantar Excecao
                RAISE vr_exc_erro;
            END;
            rw_craplcm.nrsequni:= pr_nrsequni;
            rw_craplcm.nrautdoc:= nvl(rw_craptfn.nrultaut,0);
            pr_nrultaut:= rw_craptfn.nrultaut;
          END IF;
        END IF;

        --Atualizar tabela craplcm
        BEGIN
          UPDATE craplcm SET craplcm.cdpesqbb = rw_craplcm.cdpesqbb
                            ,craplcm.cdcoptfn = rw_craplcm.cdcoptfn
                            ,craplcm.cdagetfn = rw_craplcm.cdagetfn
                            ,craplcm.nrterfin = rw_craplcm.nrterfin
                            ,craplcm.nrsequni = rw_craplcm.nrsequni
                            ,craplcm.nrautdoc = rw_craplcm.nrautdoc
          WHERE craplcm.ROWID = rw_craplcm.ROWID;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela craplcm.'||sqlerrm;
            -- Desfaz as alterações
            ROLLBACK TO real_trans;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;

        
        -- Chamar geracao de LOG
        cxon0022.pc_gera_log(pr_cooper       => pr_cooper        --Codigo Cooperativa
                            ,pr_cod_agencia  => pr_cod_agencia   --Codigo Agencia
                            ,pr_nro_caixa    => pr_nro_caixa     --Numero do caixa
                            ,pr_operador     => pr_cod_operador  --Codigo Operador
                            ,pr_cooper_dest  => pr_cooper_dest   --Codigo Cooperativa
                            ,pr_nrdcontade   => pr_nrdcontade    --Numero Conta destino
                            ,pr_nrdcontapara => pr_nrdcontapara  --Conta de Destino
                            ,pr_tpoperac     => 4                --Transferencia mesma coop
                            ,pr_valor        => pr_valor         --Valor da transacao
                            ,pr_nrdocmto     => pr_nro_docto     --Numero Documento
                            ,pr_cdpacrem     => 0
                            ,pr_cdcritic     => vr_cdcritic      --C¿digo do erro
                            ,pr_dscritic     => vr_dscritic);    --Descricao erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      
      ELSE  /** Transferencia para cooperativa diferente **/

        --Numero do lote
        vr_nro_lote:= 29000 + pr_nro_caixa;
        --Texto
        vr_flg_vertexto:= TRUE;

        /* Validar para criar o lancamento ao fim da procedure */
        --Selecionar informacoes dos boletins dos caixas
        OPEN cr_crapbcx (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                        ,pr_cdagenci => pr_cod_agencia
                        ,pr_nrdcaixa => pr_nro_caixa
                        ,pr_cdopecxa => pr_cod_operador
                        ,pr_cdsitbcx => 1);
        --Posicionar no proximo registro
        FETCH cr_crapbcx INTO rw_crapbcx;
        --Se nao encontrar
        IF cr_crapbcx%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapbcx;
          vr_cdcritic:= 698;
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapbcx;
    
        if not paga0001.fn_exec_paralelo then
          /*** Informacao da cooperativa de origem ***/
          --Selecionar informacoes do lote ou cria-lo caso nao exista
          pc_insere_lote (pr_cdcooper => rw_crapcop.cdcooper,
                          pr_dtmvtolt => rw_crapdat.dtmvtocd,
                          pr_cdagenci => pr_cod_agencia,
                          pr_cdbccxlt => 11,
                          pr_nrdolote => vr_nro_lote,
                          pr_cdoperad => pr_cod_operador,
                          pr_nrdcaixa => pr_nro_caixa,
                          pr_tplotmov => 1,
                          pr_cdhistor => 0,
                          pr_craplot  => rw_craplot_ori,
                          pr_dscritic => vr_dscritic);
        ELSE
          paga0001.pc_insere_lote_wrk (pr_cdcooper => rw_crapcop.cdcooper,
                                       pr_dtmvtolt => rw_crapdat.dtmvtocd,
                                       pr_cdagenci => pr_cod_agencia,
                                       pr_cdbccxlt => 11,
                                       pr_nrdolote => vr_nro_lote,
                                       pr_cdoperad => pr_cod_operador,
                                       pr_nrdcaixa => pr_nro_caixa,
                                       pr_tplotmov => 1,
                                       pr_cdhistor => 0,
                                       pr_cdbccxpg => null,
                                       pr_nmrotina => 'CXON0022.PC_REALIZA_TRANSFERENCIA');
          
          rw_craplot_ori.cdbccxlt := 11;
          rw_craplot_ori.nrdolote := vr_nro_lote;
          rw_craplot_ori.cdoperad := pr_cod_operador;
          rw_craplot_ori.tplotmov := 1;
          rw_craplot_ori.cdhistor := 0;
          
          rw_craplot_ori.nrseqdig := paga0001.fn_seq_parale_craplcm; 
        END IF;                
        -- se encontrou erro ao buscar lote, abortar programa
        IF vr_dscritic IS NOT NULL THEN
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        
        --Determinar numero documento
        pr_nro_docto:= nvl(rw_craplot_ori.nrseqdig,0);
        
        /*** Informacao da cooperativa de origem ***/
        BEGIN
          --Inserir Lancamentos extra-sistema do boletim caixa
          INSERT INTO craplcx
            (craplcx.cdcooper
            ,craplcx.dtmvtolt
            ,craplcx.cdagenci
            ,craplcx.nrdcaixa
            ,craplcx.cdopecxa
            ,craplcx.nrdocmto
            ,craplcx.nrseqdig
            ,craplcx.nrdmaqui
            ,craplcx.cdhistor
            ,craplcx.dsdcompl
            ,craplcx.vldocmto
            ,craplcx.nrautdoc)
          VALUES
            (rw_crapcop.cdcooper
            ,rw_crapdat.dtmvtocd
            ,pr_cod_agencia
            ,pr_nro_caixa
            ,pr_cod_operador
            ,pr_nro_docto
            ,Nvl(rw_crapbcx.qtcompln,0) + 1
            ,rw_crapbcx.nrdmaqui
            ,1016 /* Credito*/
            ,'Agencia:'||GENE0002.fn_mask(rw_crabcop.cdagectl,'9999')||
             ' Conta/DV:'||GENE0002.fn_mask_conta(pr_nrdcontapara)
            ,pr_valor
            ,NVL(vr_ult_sequencia,0));
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao inserir na tabela craplcx.'||sqlerrm;
            -- Desfaz as alterações
            ROLLBACK TO real_trans;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
        --Atualizar tabela crapbcx
        BEGIN
          UPDATE crapbcx SET crapbcx.qtcompln = nvl(crapbcx.qtcompln,0) + 1
          WHERE crapbcx.ROWID = rw_crapbcx.ROWID;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela crapbcx.'||sqlerrm;
            -- Desfaz as alterações
            ROLLBACK TO real_trans;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
        /*--- Grava Autenticacao PG --*/
        CXON0000.pc_grava_autenticacao_internet (pr_cooper       => pr_cooper      --Codigo Cooperativa
                                                ,pr_nrdconta     => pr_nrdcontade  --Numero da Conta
                                                ,pr_idseqttl     => pr_idseqttl    --Sequencial do titular
                                                ,pr_cod_agencia  => pr_cod_agencia  --Codigo Agencia
                                                ,pr_nro_caixa    => pr_nro_caixa    --Numero do caixa
                                                ,pr_cod_operador => pr_cod_operador --Codigo Operador
                                                ,pr_valor        => pr_valor        --Valor da transacao
                                                ,pr_docto        => pr_nro_docto   --Numero documento
                                                ,pr_operacao     => TRUE            --Indicador Operacao Debito
                                                ,pr_status       => '1'            --Status da Operacao - Online
                                                ,pr_estorno      => FALSE          --Indicador Estorno
                                                ,pr_histor       => 1009           --Historico Debito
                                                ,pr_data_off     => NULL           --Data Transacao
                                                ,pr_sequen_off   => 0              --Sequencia
                                                ,pr_hora_off     => 0              --Hora transacao
                                                ,pr_seq_aut_off  => 0              --Sequencia automatica
                                                ,pr_cdempres     => NULL           --Descricao Observacao
                                                ,pr_literal      => vr_literal_lcm     --Descricao literal lcm
                                                ,pr_sequencia    => vr_ult_sequencia_lcm  --Sequencia
                                                ,pr_registro     => pr_reg_lcm_deb    --ROWID do registro debito
                                                ,pr_cdcritic     => vr_cdcritic    --C¿digo do erro
                                                ,pr_dscritic     => vr_dscritic);  --Descricao do erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        /*--- Verifica se Lancamento ja Existe ---*/
        OPEN cr_craplcm (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                        ,pr_cdagenci => To_Number(pr_cod_agencia)
                        ,pr_cdbccxlt => rw_craplot_ori.cdbccxlt
                        ,pr_nrdolote => vr_nro_lote
                        ,pr_nrseqdig => nvl(rw_craplot_ori.nrseqdig,0));
        --Posicionar no proximo registro
        FETCH cr_craplcm INTO rw_craplcm;
        --Se nao encontrar
        IF cr_craplcm%FOUND THEN
          --Fechar Cursor
          CLOSE cr_craplcm;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Lancamento ja existente.';
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_craplcm;

        /** Lancamento cooperativa origem **/

        IF (pr_idagenda = 1) THEN
            OPEN cr_craplcm_dup(pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_nrdconta => pr_nrdcontade
                               ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                               ,pr_vllanmto => pr_valor
                               ,pr_cdagectl => rw_crabcop.cdagectl
                               ,pr_nrdctabb => pr_nrdcontapara);
            --Posicionar no proximo registro
            FETCH cr_craplcm_dup INTO vr_hrtransa_dup;
              --Se encontrar
              IF cr_craplcm_dup%FOUND THEN
                --Compara os segundos do último lançamento para não haver duplicidade
                IF (((SYSDATE-TRUNC(SYSDATE))*(24*60*60)) - vr_hrtransa_dup) <= 600 THEN
                  
                  vr_cdcritic := 0;
                  vr_dscritic := 'Ja existe transferencia de mesmo valor e favorecido. Consulte seu extrato.';
                  -- Desfaz as alterações
                  ROLLBACK TO real_trans;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                    
                END IF;
              END IF;	
            --Fechar Cursor
            CLOSE cr_craplcm_dup;
        END IF;

        /* Cria o lancamento do DEBITO */
        BEGIN
          INSERT INTO craplcm
             (craplcm.cdcooper
             ,craplcm.dtmvtolt
             ,craplcm.cdagenci
             ,craplcm.cdbccxlt
             ,craplcm.nrdolote
             ,craplcm.nrdconta
             ,craplcm.nrdocmto
             ,craplcm.vllanmto
             ,craplcm.cdhistor
             ,craplcm.nrseqdig
             ,craplcm.nrsequni
             ,craplcm.nrdctabb
             ,craplcm.nrautdoc
             ,craplcm.cdpesqbb
             ,craplcm.nrdctitg
             ,craplcm.cdcoptfn
             ,craplcm.cdagetfn
             ,craplcm.nrterfin
             ,craplcm.dsidenti
             ,craplcm.hrtransa
             ,craplcm.cdoperad)
          VALUES
             (rw_crapcop.cdcooper
             ,rw_crapdat.dtmvtocd
             ,pr_cod_agencia
             ,rw_craplot_ori.cdbccxlt
             ,vr_nro_lote
             ,pr_nrdcontade
             ,pr_nro_docto
             ,pr_valor
             ,1009 /* Debito */                                                   --cdhistor
             ,nvl(rw_craplot_ori.nrseqdig,0)                                          --nrseqdig
             ,nvl(rw_craplot_ori.nrseqdig,0)                                          --nrsequni
             ,pr_nrdcontapara                                                     --nrdctabb
             ,nvl(vr_ult_sequencia_lcm,0)                                                --nrautdoc
             ,'CRAP22 - '||gene0002.fn_mask(rw_crabcop.cdagectl,'9999')           --cdpesqbb
             ,'0'                                                                 --nrdctitg
             ,rw_crabcop.cdcooper                                                 --cdcoptfn
             ,rw_crabass.cdagenci                                                 --cdagetfn
             ,0                                                                   --nrterfin
             ,'Agencia: '|| GENE0002.fn_mask(rw_crabcop.cdagectl,'9999')||        --dsidenti
             ' Conta/DV: '|| GENE0002.fn_mask_conta(pr_nrdcontapara)
             ,GENE0002.fn_busca_time                                              --hrtransa
             ,pr_cod_operador)                                                    --cdoperad
          RETURNING craplcm.ROWID
                   ,craplcm.cdpesqbb
                   ,craplcm.cdcoptfn
                   ,craplcm.cdagetfn
                   ,craplcm.nrterfin
                   ,craplcm.nrsequni
                   ,craplcm.nrautdoc
				   ,craplcm.cdhistor
          INTO rw_craplcm.ROWID
               ,rw_craplcm.cdpesqbb
               ,rw_craplcm.cdcoptfn
               ,rw_craplcm.cdagetfn
               ,rw_craplcm.nrterfin
               ,rw_craplcm.nrsequni
               ,rw_craplcm.nrautdoc
			   ,rw_craplcm.cdhistor;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao inserir na tabela craplcm. '||sqlerrm;
            -- Desfaz as alterações
            ROLLBACK TO real_trans;
            --Levantar Excecao
           RAISE vr_exc_erro;
        END;
				
		vr_cdhisdeb := rw_craplcm.cdhistor;
				
        --Agendamento
        IF pr_idagenda > 1 THEN
          rw_craplcm.cdpesqbb:= rw_craplcm.cdpesqbb ||' AGENDADO';
        END IF;
        --TAA
        IF pr_idorigem = 4 THEN
          --Informacoes terminal fianceiro
          rw_craplcm.cdcoptfn:= vr_cdcoptfn;
          rw_craplcm.cdagetfn:= vr_cdagetfn;
          rw_craplcm.nrterfin:= vr_nrterfin;
          --Numero terminal <> 0
          IF rw_craplcm.nrterfin <> 0 THEN
            BEGIN
              UPDATE craptfn SET nrultaut = Nvl(craptfn.nrultaut,0) + 1
              WHERE craptfn.ROWID = rw_craptfn.ROWID
              RETURNING craptfn.nrultaut INTO rw_craptfn.nrultaut;
            EXCEPTION
              WHEN Others THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar tabela craptfn.'||sqlerrm;
                -- Desfaz as alterações
                ROLLBACK TO real_trans;
                --Levantar Excecao
                RAISE vr_exc_erro;
            END;
            rw_craplcm.nrsequni:= pr_nrsequni;
            rw_craplcm.nrautdoc:= nvl(rw_craptfn.nrultaut,0);
            pr_nrultaut:= rw_craptfn.nrultaut;
          END IF;
        END IF;

        --Atualizar tabela craplcm
        BEGIN
          UPDATE craplcm SET craplcm.cdpesqbb = rw_craplcm.cdpesqbb
                            ,craplcm.cdcoptfn = rw_craplcm.cdcoptfn
                            ,craplcm.cdagetfn = rw_craplcm.cdagetfn
                            ,craplcm.nrterfin = rw_craplcm.nrterfin
                            ,craplcm.nrsequni = rw_craplcm.nrsequni
                            ,craplcm.nrautdoc = rw_craplcm.nrautdoc
          WHERE craplcm.ROWID = rw_craplcm.ROWID;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela craplcm.'||sqlerrm;
            -- Desfaz as alterações
            ROLLBACK TO real_trans;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;

        /********* Lancamento da tarifa **********/
        /** Obtem valor e historico da tarifa **/

        --Buscar a tarifa
        TARI0001.pc_busca_tar_transf_intercoop (pr_cdcooper => rw_crapcop.cdcooper --Codigo Cooperativa
                                               ,pr_cdagenci => pr_cod_agencia      --Codigo Agencia
                                               ,pr_nrdconta => pr_nrdcontade       --Numero da Conta
                                               ,pr_vllanmto => pr_valor            --Valor Lancamento
                                               ,pr_vltarifa => vr_vltarifa         --Valor Tarifa
                                               ,pr_cdhistor => vr_cdhistor         --Historico da tarifa
                                               ,pr_cdhisest => vr_cdhisest         --Historico estorno
                                               ,pr_cdfvlcop => vr_cdfvlcop         --Codigo faixa valor cooperativa
                                               ,pr_cdcritic => vr_cdcritic         --C¿digo do erro
                                               ,pr_dscritic => vr_dscritic);       --Descricao do erro
        --Se Ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        /** Tratamento para tarifa **/
        IF  Nvl(vr_vltarifa,0) <> 0 THEN

          --Realizar lancamento tarifa
          TARI0001.pc_lan_tarifa_online (pr_cdcooper => rw_crapcop.cdcooper  --Codigo Cooperativa
                                        ,pr_cdagenci => pr_cod_agencia       --Codigo Agencia destino
                                        ,pr_nrdconta => pr_nrdcontade        --Numero da Conta Destino
                                        ,pr_cdbccxlt => 100                  --Codigo banco/caixa
                                        ,pr_nrdolote => 10119                --Numero do Lote
                                        ,pr_tplotmov => 1                    --Tipo Lote
                                        ,pr_cdoperad => pr_cod_operador      --Codigo Operador
                                        ,pr_dtmvtlat => rw_crapdat.dtmvtolt  --Data Tarifa
                                        ,pr_dtmvtlcm => rw_crapdat.dtmvtocd  --Data lancamento
                                        ,pr_nrdctabb => pr_nrdcontapara      --Numero Conta BB
                                        ,pr_nrdctitg => '0'                  --Conta Integracao
                                        ,pr_cdhistor => vr_cdhistor          --Codigo Historico
                                        ,pr_cdpesqbb => rw_craplcm.cdpesqbb  --Codigo pesquisa
                                        ,pr_cdbanchq => 0                    --Codigo Banco Cheque
                                        ,pr_cdagechq => 0                    --Codigo Agencia Cheque
                                        ,pr_nrctachq => 0                    --Numero Conta Cheque
                                        ,pr_flgaviso => FALSE                --Flag Aviso
                                        ,pr_tpdaviso => 0                    --Tipo Aviso
                                        ,pr_vltarifa => vr_vltarifa          --Valor tarifa
                                        ,pr_nrdocmto => 0                    --Numero Documento
                                        ,pr_cdcoptfn => rw_craplcm.cdcoptfn  --Codigo Cooperativa Terminal
                                        ,pr_cdagetfn => rw_craplcm.cdagetfn  --Codigo Agencia Terminal
                                        ,pr_nrterfin => rw_craplcm.nrterfin  --Numero Terminal Financeiro
                                        ,pr_nrsequni => rw_craplcm.nrsequni  --Numero Sequencial Unico
                                        ,pr_nrautdoc => rw_craplcm.nrautdoc  --Numero Autenticacao Documento
                                        ,pr_dsidenti => rw_craplcm.dsidenti  --Descricao Identificacao
                                        ,pr_cdfvlcop => vr_cdfvlcop          --Codigo Faixa Valor Cooperativa
                                        ,pr_inproces => rw_crapdat.inproces  --Indicador Processo
                                        ,pr_cdlantar => pr_cdlantar          --Codigo Lancamento tarifa
                                        ,pr_tab_erro => vr_tab_erro          --Tabela de erro
                                        ,pr_cdcritic => vr_cdcritic          --C¿digo do erro
                                        ,pr_dscritic => vr_dscritic);        --Descricao do erro

          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Se tem informacoes no vetor erro
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic:= 0;
              vr_dscritic:= vr_tab_erro(1).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Nao foi possivel lancar a tarifa.';
            END IF;
            -- Desfaz as alterações
            ROLLBACK TO real_trans;
            --Levantar Exececao
            RAISE vr_exc_erro;
          END IF;
        END IF; --vr_vltarifa <> 0

        /***** Conta de destino *****/
        --Selecionar informacoes do lote ou cria-lo caso nao exista
        if not PAGA0001.fn_exec_paralelo then
          pc_insere_lote (pr_cdcooper => rw_crabcop.cdcooper,
                          pr_dtmvtolt => rw_crapdat.dtmvtocd,
                          pr_cdagenci => pr_cod_agencia,
                          pr_cdbccxlt => 100,
                          pr_nrdolote => 10120,
                          pr_cdoperad => 0,
                          pr_nrdcaixa => 0,
                          pr_tplotmov => 1,
                          pr_cdhistor => 0,
                          pr_craplot  => rw_craplot_dst,
                          pr_dscritic => vr_dscritic);
        ELSE
          PAGA0001.pc_insere_lote_wrk (pr_cdcooper => rw_crabcop.cdcooper,
                                       pr_dtmvtolt => rw_crapdat.dtmvtocd,
                                       pr_cdagenci => pr_cod_agencia,
                                       pr_cdbccxlt => 100,
                                       pr_nrdolote => 10120,
                                       pr_cdoperad => 0,
                                       pr_nrdcaixa => 0,
                                       pr_tplotmov => 1,
                                       pr_cdhistor => 0,
                                       pr_cdbccxpg => null,
                                       pr_nmrotina => 'CXON0022.PC_REALIZA_TRANSFERENCIA');
         
           
           rw_craplot_dst.dtmvtolt := rw_crapdat.dtmvtocd;
           rw_craplot_dst.cdagenci := pr_cod_agencia;
           rw_craplot_dst.cdbccxlt := 100;
           rw_craplot_dst.nrdolote := 10120;
           rw_craplot_dst.cdoperad := 0;
           rw_craplot_dst.tplotmov := 1;
           rw_craplot_dst.cdhistor := 0;
           
           rw_craplot_dst.nrseqdig := PAGA0001.fn_seq_parale_craplcm;                 
        END IF;                
        -- se encontrou erro ao buscar lote, abortar programa
        IF vr_dscritic IS NOT NULL THEN
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        
        --Retornar documento credito
        pr_nro_docto_cred:= Nvl(rw_craplot_dst.nrseqdig,0);        

        /*--- Grava Autenticacao RC --*/
        CXON0000.pc_grava_autenticacao_internet (pr_cooper       => pr_cooper      --Codigo Cooperativa
                                                ,pr_nrdconta     => pr_nrdcontade  --Numero da Conta
                                                ,pr_idseqttl     => pr_idseqttl    --Sequencial do titular
                                                ,pr_cod_agencia  => pr_cod_agencia  --Codigo Agencia
                                                ,pr_nro_caixa    => pr_nro_caixa    --Numero do caixa
                                                ,pr_cod_operador => pr_cod_operador --Codigo Operador
                                                ,pr_valor        => pr_valor        --Valor da transacao
                                                ,pr_docto        => pr_nro_docto_cred   --Numero documento
                                                ,pr_operacao     => FALSE            --Indicador Operacao Debito
                                                ,pr_status       => '1'            --Status da Operacao - Online
                                                ,pr_estorno      => FALSE          --Indicador Estorno
                                                ,pr_histor       => 1011          --Historico Credito
                                                ,pr_data_off     => NULL           --Data Transacao
                                                ,pr_sequen_off   => 0              --Sequencia
                                                ,pr_hora_off     => 0              --Hora transacao
                                                ,pr_seq_aut_off  => 0              --Sequencia automatica
                                                ,pr_cdempres     => NULL           --Descricao Observacao
                                                ,pr_literal      => vr_literal     --Descricao literal lcm
                                                ,pr_sequencia    => vr_ult_sequencia    --Sequencia
                                                ,pr_registro     => pr_reg_lcm_cre --ROWID do registro debito
                                                ,pr_cdcritic     => vr_cdcritic    --C¿digo do erro
                                                ,pr_dscritic     => vr_dscritic);  --Descricao do erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        --Selecionar informacoes lancamentos
        OPEN cr_craplcm (pr_cdcooper => rw_crabcop.cdcooper
                        ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                        ,pr_cdagenci => To_Number(pr_cod_agencia)
                        ,pr_cdbccxlt => 100
                        ,pr_nrdolote => rw_craplot_dst.nrdolote
                        ,pr_nrseqdig => Nvl(rw_craplot_dst.nrseqdig,0));
        --Posicionar no proximo registro
        FETCH cr_craplcm INTO rw_craplcm;
        --Se nao encontrar
        IF cr_craplcm%FOUND THEN
          --Fechar Cursor
          CLOSE cr_craplcm;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Lancamento ja existente.';
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_craplcm;

        /** Lancamento na conta destino **/
        BEGIN
          INSERT INTO craplcm
             (craplcm.cdcooper
             ,craplcm.dtmvtolt
             ,craplcm.cdagenci
             ,craplcm.cdbccxlt
             ,craplcm.nrdolote
             ,craplcm.nrdconta
             ,craplcm.nrdocmto
             ,craplcm.vllanmto
             ,craplcm.cdhistor
             ,craplcm.nrseqdig
             ,craplcm.nrsequni
             ,craplcm.nrdctabb
             ,craplcm.nrautdoc
             ,craplcm.cdpesqbb
             ,craplcm.nrdctitg
             ,craplcm.cdcoptfn
             ,craplcm.cdagetfn
             ,craplcm.nrterfin
             ,craplcm.dsidenti
             ,craplcm.hrtransa
             ,craplcm.cdoperad)
          VALUES
             (rw_crabcop.cdcooper                                       --cdcooper
             ,rw_crapdat.dtmvtocd                                       --dtmvtocd
             ,pr_cod_agencia                                            --cdagenci
             ,100                                                       --cdbccxlt
             ,rw_craplot_dst.nrdolote                                   --nrdolote
             ,pr_nrdcontapara                                           --nrdconta
             ,pr_nro_docto_cred                                         --nrdocmto
             ,pr_valor                                                  --vllanmto
             ,1011                                                      --cdhistor
             ,Nvl(rw_craplot_dst.nrseqdig,0)                            --nrseqdig
             ,Nvl(rw_craplot_dst.nrseqdig,0)                            --nrsequni
             ,pr_nrdcontade                                             --nrdctabb
             ,nvl(vr_ult_sequencia,0)                                          --nrautdoc
             ,'CRAP22 - '||gene0002.fn_mask(rw_crapcop.cdagectl,'9999') --cdpesqbb
             ,' '                                                       --nrdctitg
             ,rw_crapcop.cdcooper                                       --cdcoptfn
             ,pr_cod_agencia                                            --cdagetfn
             ,0                                                       --nrterfin
             ,'Agencia: '||gene0002.fn_mask(rw_crapcop.cdagectl,'9999')||
              ' Conta/DV: '|| GENE0002.fn_mask_conta(pr_nrdcontade)     --dsidenti
             ,GENE0002.fn_busca_time                                    --hrtransa
             ,pr_cod_operador)                                          --cdoperad
          RETURNING craplcm.ROWID
                   ,craplcm.cdpesqbb
                   ,craplcm.cdcoptfn
                   ,craplcm.cdagetfn
                   ,craplcm.nrterfin
                   ,craplcm.nrsequni
                   ,craplcm.nrautdoc
                   ,craplcm.nrdocmto
          INTO rw_craplcm.ROWID
               ,rw_craplcm.cdpesqbb
               ,rw_craplcm.cdcoptfn
               ,rw_craplcm.cdagetfn
               ,rw_craplcm.nrterfin
               ,rw_craplcm.nrsequni
               ,rw_craplcm.nrautdoc
               ,rw_craplcm.nrdocmto;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao inserir na tabela craplcm. '||sqlerrm;
            -- Desfaz as alterações
            ROLLBACK TO real_trans;
            --Levantar Excecao
           RAISE vr_exc_erro;
        END;
        --Agendado
        IF pr_idagenda > 1 THEN
          rw_craplcm.cdpesqbb:= rw_craplcm.cdpesqbb ||' AGENDADO';
        END IF;
        --TAA
        IF pr_idorigem = 4 THEN
          --Informacoes terminal fianceiro
          rw_craplcm.cdcoptfn:= vr_cdcoptfn;
          rw_craplcm.cdagetfn:= vr_cdagetfn;
          rw_craplcm.nrterfin:= vr_nrterfin;

          IF rw_craplcm.nrterfin <> 0 THEN
            BEGIN
              UPDATE craptfn SET nrultaut = craptfn.nrultaut + 1
              WHERE craptfn.ROWID = rw_craptfn.ROWID
              RETURNING craptfn.nrultaut INTO rw_craptfn.nrultaut;
            EXCEPTION
              WHEN Others THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar tabela craptfn.'||sqlerrm;
                -- Desfaz as alterações
                ROLLBACK TO real_trans;
                --Levantar Excecao
                RAISE vr_exc_erro;
            END;
            rw_craplcm.nrsequni:= pr_nrsequni;
            rw_craplcm.nrautdoc:= nvl(rw_craptfn.nrultaut,0);
            pr_nrultaut:= rw_craptfn.nrultaut;
          END IF;
        END IF;

        --Atualizar tabela craplcm
        BEGIN
          UPDATE craplcm SET craplcm.cdpesqbb = rw_craplcm.cdpesqbb
                            ,craplcm.cdcoptfn = rw_craplcm.cdcoptfn
                            ,craplcm.cdagetfn = rw_craplcm.cdagetfn
                            ,craplcm.nrterfin = rw_craplcm.nrterfin
                            ,craplcm.nrsequni = rw_craplcm.nrsequni
                            ,craplcm.nrautdoc = rw_craplcm.nrautdoc
          WHERE craplcm.ROWID = rw_craplcm.ROWID;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela craplcm.'||sqlerrm;
            -- Desfaz as alterações
            ROLLBACK TO real_trans;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
        
        -- Chamar geracao de LOG
        CXON0022.pc_gera_log(pr_cooper       => pr_cooper        --Codigo Cooperativa
                            ,pr_cod_agencia  => pr_cod_agencia   --Codigo Agencia
                            ,pr_nro_caixa    => pr_nro_caixa     --Numero do caixa
                            ,pr_operador     => pr_cod_operador  --Codigo Operador
                            ,pr_cooper_dest  => pr_cooper_dest   --Codigo Cooperativa
                            ,pr_nrdcontade   => pr_nrdcontade    --Numero Conta destino
                            ,pr_nrdcontapara => pr_nrdcontapara  --Conta de Destino
                            ,pr_tpoperac     => 2                --Transferencia coop diferente
                            ,pr_valor        => pr_valor         --Valor da transacao
                            ,pr_nrdocmto     => pr_nro_docto     --Numero Documento
                            ,pr_cdpacrem     => 0
                            ,pr_cdcritic     => vr_cdcritic      --C¿digo do erro
                            ,pr_dscritic     => vr_dscritic);    --Descricao erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
		  --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;

      /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/

      /** Cooperativa Remetente **/

      --Selecionar Banco
      OPEN cr_crapban (pr_cdbccxlt => rw_crapcop.cdbcoctl);
      --Posicionar no proximo registro
      FETCH cr_crapban INTO rw_crapban;
      --Se nao encontrar
      IF cr_crapban%FOUND THEN
        vr_desc_banco:= rw_crapban.nmresbcc;
      ELSE
        vr_desc_banco:= ' ';
      END IF;
      --Fechar Cursor
      CLOSE cr_crapban;
      --Selecionar informacoes das agencias bancarias
      OPEN cr_crapagb (pr_cdageban => rw_crapcop.cdagectl
                      ,pr_cddbanco => rw_crapcop.cdbcoctl);
      --Posicionar no proximo registro
      FETCH cr_crapagb INTO rw_crapagb;
      --Se nao encontrar
      IF cr_crapagb%FOUND THEN
        vr_desc_agencia1:= rw_crapagb.nmageban;
      ELSE
        vr_desc_agencia1:= ' ';
      END IF;
      --Fechar Cursor
      CLOSE cr_crapagb;

      /** Cooperativa Destinatario **/
      OPEN cr_crapagb (pr_cdageban => rw_crabcop.cdagectl
                      ,pr_cddbanco => rw_crabcop.cdbcoctl);
      --Posicionar no proximo registro
      FETCH cr_crapagb INTO rw_crapagb;
      --Se nao encontrar
      IF cr_crapagb%FOUND THEN
        vr_desc_agencia2:= rw_crapagb.nmageban;
      ELSE
        vr_desc_agencia2:= ' ';
      END IF;
      --Fechar Cursor
      CLOSE cr_crapagb;

      --Selecionar informacoes da agencia
      OPEN cr_crapage (pr_cdcooper => rw_crapcop.cdcooper
                      ,pr_cdagenci => pr_cod_agencia);
      --Posicionar no proximo registro
      FETCH cr_crapage INTO rw_crapage;
      --Se nao encontrar
      IF cr_crapage%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapage;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Agencia nao encontrada.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapage;
      --Numero do CPF
      vr_cgc_para_1:= rw_crabass.nrcpfcgc;

	  IF rw_crabass.inpessoa = 1 THEN

	    OPEN cr_crapttl(pr_cdcooper => rw_crabass.cdcooper
		               ,pr_nrdconta => rw_crabass.nrdconta);

		FETCH cr_crapttl INTO rw_crapttl;

	    IF cr_crapttl%FOUND THEN
          
		  vr_cgc_para_2:= rw_crapttl.nrcpfcgc;
		  vr_nmsegntl  := rw_crapttl.nmextttl;

		END IF;

		CLOSE cr_crapttl;

	  END IF;

      --Limpar vetor
      vr_tab_literal.DELETE;

      --Populando vetor
      vr_index:= 1;
      vr_tab_literal(vr_index):= TRIM(rw_crapcop.nmrescop) ||' - '||TRIM(rw_crapcop.nmextcop);
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= ' ';
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= to_char(rw_crapdat.dtmvtocd,'DD/MM/YY')|| ' '||
                          To_Char(SYSDATE,'HH24:MI:SS')||' PAC '||to_char(pr_cod_agencia,'FM000')||
                          '  CAIXA: '||pr_nro_caixa|| '/'||SUBSTR(pr_cod_operador,1,10);
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= '      ** COMPROVANTE  TRANSFERENCIA ** ';
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= 'REMETENTE: ';
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= 'BANCO...: '|| rw_crapcop.cdbcoctl||' - '||vr_desc_banco;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= 'AGENCIA.: '||rw_crapcop.cdagectl||' - '||vr_desc_agencia1;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= 'CONTA...: '||TRIM(gene0002.fn_mask_conta(pr_nrdcontade));
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= 'TITULAR1: '|| rw_crapass.nmprimtl;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= 'DESTINATARIO:';
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= 'BANCO...: '||TRIM(to_char(rw_crapcop.cdbcoctl,'FM000')||' - '||TRIM(vr_desc_banco));
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= 'AGENCIA.: '||TRIM(rw_crabcop.cdagectl)||' - '||TRIM(vr_desc_agencia2);
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= 'CONTA...: '||TRIM(gene0002.fn_mask_conta(pr_nrdcontapara));
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= 'TITULAR1: '||rw_crabass.nmprimtl;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= 'TITULAR2: '||vr_nmsegntl;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= 'CPF/CNPJ: '||'TITULAR1: '||vr_cgc_para_1;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= '          '||'TITULAR2: '||vr_cgc_para_2;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= vr_literal;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= 'VALOR R$ '||LPAD(to_char(pr_valor,'fm999g990d00'),10,' ');
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;

      --Se deve mostrar texto
      IF vr_flg_vertexto THEN
        vr_index:= vr_index+1;
        vr_tab_literal(vr_index):= 'AUTORIZO A COOPERATIVA A DEBITAR EM MINHA CONTA ';
        vr_index:= vr_index+1;
        vr_tab_literal(vr_index):= 'E A COOPERATIVA DE  DESTINO  CREDITAR  CONFORME ';
        vr_index:= vr_index+1;
        vr_tab_literal(vr_index):= 'DADOS INFORMADOS ACIMA';
        --Se tem tarifa
        IF vr_vltarifa <> 0 THEN
          vr_tab_literal(vr_index):= vr_tab_literal(vr_index)||', ACRESCIDO DA TARIFA  DE ';
          vr_index:= vr_index+1;
          vr_tab_literal(vr_index):= 'PRESTACAO DESTE SERVICO.';
        ELSE
          vr_tab_literal(vr_index):= vr_tab_literal(vr_index)||'.';
        END IF;
      END IF;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= vr_literal_lcm;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL;
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= LPad('-',48,'-');
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= '         ASSINATURA DO REMETENTE                ';
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL; -- Linha em branco 1/9
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL; -- Linha em branco 2/9
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL; -- Linha em branco 3/9
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL; -- Linha em branco 4/9
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL; -- Linha em branco 5/9
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL; -- Linha em branco 6/9
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL; -- Linha em branco 7/9
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL; -- Linha em branco 8/9
      vr_index:= vr_index+1;
      vr_tab_literal(vr_index):= NULL; -- Linha em branco 9/9
      
      --Inicializar autenticacao
      pr_literal_autentica:= NULL;

      --Concatenar valores do vetor na string
      FOR idx IN 1..vr_index LOOP
        pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(idx),'  '),48,' ');
      END LOOP;

      --Segunda via
      vr_texto_2_via:= pr_literal_autentica;

      --Concatenar 2via no literal
      pr_literal_autentica:= pr_literal_autentica||vr_texto_2_via;
      --Retornar Ultima Sequencia Autenticacao
      pr_ult_seq_autentica:= vr_ult_sequencia;

      /* Autenticacao REC */
      BEGIN
        UPDATE crapaut SET crapaut.dslitera = pr_literal_autentica
        WHERE crapaut.ROWID = pr_reg_lcm_cre;
        --Se nao atualizou registro
        IF SQL%ROWCOUNT = 0 THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro Sistema - CRAPAUT nao Encontrado';
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      EXCEPTION
        WHEN Others THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar tabela crapaut.'||sqlerrm;
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;

      /* Autenticacao PAG */
      BEGIN
        UPDATE crapaut SET crapaut.dslitera = pr_literal_autentica
        WHERE crapaut.ROWID = pr_reg_lcm_deb;
        --Se nao atualizou registro
        IF SQL%ROWCOUNT = 0 THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro Sistema - CRAPAUT nao Encontrado';
          -- Desfaz as alterações
           ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      EXCEPTION
        WHEN Others THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar tabela crapaut.'||sqlerrm;
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
      
      -------> ATUALIZAR LOTES <--------- 
      IF not PAGA0001.fn_exec_paralelo then 
        IF cxon0020.fn_verifica_lote_uso(pr_rowid => rw_craplot_ori.rowid) = 1 THEN
          vr_dscritic:= 'Registro de lote '||rw_craplot_ori.nrdolote||' em uso. Tente novamente.';  
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
          
        --Atualizar tabela craplot
        BEGIN
          UPDATE craplot SET craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                            ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                            ,craplot.vlcompdb = nvl(craplot.vlcompdb,0) + pr_valor
                            ,craplot.vlinfodb = nvl(craplot.vlinfodb,0) + pr_valor
          WHERE craplot.ROWID = rw_craplot_ori.ROWID
          RETURNING craplot.nrseqdig INTO rw_craplot_ori.nrseqdig;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela craplot.'||sqlerrm;
            -- Desfaz as alterações
            ROLLBACK TO real_trans;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END IF;  
      -------> Atualizar lotes
      IF not PAGA0001.fn_exec_paralelo then 
        IF cxon0020.fn_verifica_lote_uso(pr_rowid => rw_craplot_dst.rowid) = 1 THEN
          vr_dscritic:= 'Registro de lote '||rw_craplot_dst.nrdolote||' em uso. Tente novamente.';  
          -- Desfaz as alterações
          ROLLBACK TO real_trans;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Atualizar tabela craplot
        BEGIN
          UPDATE craplot SET craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                            ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                            ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + pr_valor
                            ,craplot.vlinfocr = nvl(craplot.vlinfocr,0) + pr_valor
          WHERE craplot.ROWID = rw_craplot_dst.ROWID;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela craplot.'||sqlerrm;
            -- Desfaz as alterações
            ROLLBACK TO real_trans;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END IF;
	IF pr_flmobile = 1 THEN
		vr_cdorigem := 10; --> MOBILE
	ELSE 
		vr_cdorigem := pr_idorigem;
	END IF;
	-- Geracao de log para operacoes que podem utilizar o cartao ORIGEM	
	CADA0004.pc_gera_log_ope_cartao( pr_cdcooper 		    => rw_crapcop.cdcooper -- Codigo da cooperativa
									                ,pr_nrdconta 	      => pr_nrdcontade       -- Numero da conta
									                ,pr_indoperacao 	  => 4                   -- Operacao realizada no log (1-Saque/2-Doc/3-Ted/4-Transferencia/5-Talao de cheque) Alterar Andrino
									                ,pr_cdorigem 	      => vr_cdorigem         -- Origem do lancamento (1-Ayllos/2-Caixa/3-Internet/4-Cash/5-Ayllos WEB/6-URA/7-Batch/8-Mensageria)
									                ,pr_indtipo_cartao 	=> pr_idtipcar         -- Tipo de cartao utilizado. (0-Sem cartao/1-Magnetico/2-Cartao Cecred) Alterar Andrino
									                ,pr_nrdocmto 	      => pr_nro_docto        -- Numero do documento utilizado no lancamento
									                ,pr_cdhistor 	      => vr_cdhisdeb         -- Codigo do historico utilizado no lancamento
									                ,pr_nrcartao 	      => to_char(pr_nrcartao) -- Numero do cartao utilizado. Zeros quando nao existe cartao
									                ,pr_vllanmto 	      => pr_valor            -- Valor do lancamento
									                ,pr_cdoperad 	      => pr_cod_operador     -- Codigo do operador
									                ,pr_cdbccrcb 	      => 0                   -- Codigo do banco de destino para os casos de TED e DOC
									                ,pr_cdfinrcb 	      => 0                   -- Codigo da finalidade para operacoes de TED e DOC
									                ,pr_cdpatrab        => pr_cod_agencia 
                                  ,pr_nrseqems        => 0 
                                  ,pr_nmreceptor      => ''
                                  ,pr_nrcpf_receptor  => 0
									                ,pr_dscritic        => vr_dscritic);       -- Descricao do erro quando houver
	IF nvl(vr_cdcritic,0) <> 0 OR trim(vr_dscritic) IS NOT NULL THEN			
		vr_cdcritic:= 0;			
		 -- Desfaz as alterações
		ROLLBACK TO real_trans;
		--Levantar Excecao
		RAISE vr_exc_erro;
	END IF;
      
    EXCEPTION
       WHEN vr_exc_erro THEN
         --Retornar erro
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
         --Criar erro
         cxon0000.pc_cria_erro(pr_cdcooper => pr_cooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_cod_erro => vr_cdcritic
                              ,pr_dsc_erro => vr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);         
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0022.pc_realiza_transferencia. '||SQLERRM;
    END;
  END pc_realiza_transferencia;
  
  PROCEDURE pc_realiza_dep_cheq (pr_cooper            IN VARCHAR2      --> Codigo Cooperativa
                                ,pr_cod_agencia       IN INTEGER       --> Codigo Agencia
                                ,pr_nro_caixa         IN INTEGER       --> Codigo do Caixa
                                ,pr_cod_operador      IN VARCHAR2      --> Codigo Operador
                                ,pr_cooper_dest       IN VARCHAR2      --> Cooperativa de Destino
                                ,pr_nro_conta         IN INTEGER       --> Nro da Conta
                                ,pr_nro_conta_de      IN INTEGER       --> Nro da Conta origem
                                ,pr_valor             IN NUMBER        --> Valor
                                ,pr_identifica        IN VARCHAR2      --> Identificador de Deposito
                                ,pr_vestorno          IN INTEGER       --> Flag Estorno. False
                                ,pr_nro_docmto        OUT NUMBER       --> Nro Documento
                                ,pr_literal_autentica OUT VARCHAR2     --> Literal Autenticacao
                                ,pr_ult_seq_autentica OUT INTEGER      --> Ultima Seq de Autenticacao
                                ,pr_retorno           OUT VARCHAR2     --> Retorna OK ou NOK
                                ,pr_cdcritic          OUT INTEGER      --> Cod Critica
                                ,pr_dscritic          OUT VARCHAR2) IS --> Des Critica
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_realiza_dep_cheq Fonte: dbo/b1crap22.p/realiza_deposito_cheque
    Sistema  : Procedure para realizar deposito de cheques entre cooperativas
    Sigla    : CRED
    Autor    : Andre Santos - SUPERO
    Data     : Junho/2014.                   Ultima atualizacao: 26/04/2017
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : 

   Alteracoes: 14/12/2016 - Corrigida atribuicao da variavel vr_aux_nrctachq para incorporacao (Diego).

	           26/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
						   (Adriano - P339).

  ---------------------------------------------------------------------------------------------------------------*/

  
  --Tipo de tabela para vetor literal
  TYPE typ_tab_literal IS table of VARCHAR2(100) index by PLS_INTEGER;
  --Vetor de memoria do literal
  vr_tab_literal typ_tab_literal;
  
  /* Busca o codigo da Coop. Destino passando como parametro o nome resumido da Coop. */
  CURSOR cr_cod_coop_dest(p_nmrescop IN VARCHAR2) IS
    SELECT cop.cdcooper
          ,cop.cdagectl
          ,cop.cdagebcb
          ,cop.cdbcoctl
          ,cop.cdagedbb
          ,cop.nmrescop
      FROM crapcop cop
     WHERE UPPER(cop.nmrescop) = UPPER(p_nmrescop);
  rw_cod_coop_dest cr_cod_coop_dest%ROWTYPE;
  
  /* Busca o codigo da Coop. Origem passando como parametro o nome resumido da Coop. */
  CURSOR cr_cod_coop_orig(p_nmrescop IN VARCHAR2) IS
    SELECT cop.cdcooper
          ,cop.cdagectl
          ,cop.cdagebcb
          ,cop.cdbcoctl
          ,cop.cdagedbb
          ,cop.nmrescop
          ,cop.nmextcop
      FROM crapcop cop
     WHERE UPPER(cop.nmrescop) = UPPER(p_nmrescop) ;
  rw_cod_coop_orig cr_cod_coop_orig%ROWTYPE;
  
  /* Busca a Data Conforme o Código da Cooperativa de Origem */
  CURSOR cr_dat_cop(p_coop IN INTEGER)IS
     SELECT dat.dtmvtolt
           ,dat.dtmvtocd
       FROM crapdat dat
      WHERE dat.cdcooper = p_coop;
  rw_dat_cop cr_dat_cop%ROWTYPE;
  
  /* Verifica Transferencia e Duplicacao de Matricula -- Associado de Destino */
  CURSOR cr_verifica_ass(p_coop IN INTEGER
                        ,p_nrdconta IN NUMBER)IS
     SELECT ass.cdsitdtl
           ,ass.nrdconta
           ,ass.cdtipcta
           ,ass.cdbcochq
           ,ass.nmprimtl
           ,ass.cdagenci
           ,ass.cdcooper
		   ,ass.inpessoa
       FROM crapass ass
      WHERE ass.cdcooper = p_coop
        AND ass.nrdconta = p_nrdconta;
  rw_verifica_ass cr_verifica_ass%ROWTYPE;
  
  /* Verifica Associado de Destino */
  CURSOR cr_tdm_ass(p_coop IN INTEGER
                   ,p_nrdconta IN NUMBER)IS
     SELECT ass.cdsitdtl
           ,ass.nrdconta
           ,ass.cdtipcta
           ,ass.cdbcochq
           ,ass.nmprimtl
           ,ass.cdagenci
       FROM crapass ass
      WHERE ass.cdcooper = p_coop
        AND ass.nrdconta = p_nrdconta
        AND ass.cdsitdtl IN(2,4,6,8);
  rw_tdm_ass cr_tdm_ass%ROWTYPE;
  
  /* Verifica Transferencia de Conta */
  CURSOR cr_tdc_ass(p_coop IN INTEGER
                   ,p_nrdconta IN NUMBER)IS
     SELECT ass.cdsitdtl
           ,ass.nrdconta
           ,ass.cdtipcta
           ,ass.cdbcochq
           ,ass.nmprimtl
           ,ass.cdagenci
		   ,ass.cdcooper
       FROM crapass ass
      WHERE ass.cdcooper = p_coop
        AND ass.nrdconta = p_nrdconta
        AND ass.cdsitdtl IN(2,4,6,8);
  rw_tdc_ass cr_tdc_ass%ROWTYPE;

  /* Verifica Transferencia e Duplicacao de Matricula */  
  CURSOR cr_verifica_trf(p_coop     IN INTEGER
                        ,p_nrdconta IN NUMBER)IS
      SELECT trf.nrsconta
        FROM craptrf trf
       WHERE trf.cdcooper = p_coop
         AND trf.nrdconta = p_nrdconta
         AND trf.tptransa = 1
         AND trf.insittrs = 2;
  rw_verifica_trf cr_verifica_trf%ROWTYPE;
     
  /* Verifica tab de Resumos de Lancamentos Depositos */
  CURSOR cr_verifica_mrw(p_coop IN INTEGER
                        ,p_cdagenci IN INTEGER
                        ,p_nrocaixa IN INTEGER)IS
      SELECT mrw.vlchqipr
            ,mrw.vlchqspr
            ,mrw.vlchqifp
            ,mrw.vlchqsfp
            ,mrw.vlchqcop
        FROM crapmrw mrw
       WHERE mrw.cdcooper = p_coop
         AND mrw.cdagenci = p_cdagenci
         AND mrw.nrdcaixa = p_nrocaixa;
  rw_verifica_mrw cr_verifica_mrw%ROWTYPE;
  
  /* Popula tt-cheques de acordo com os lancamentos de depositos */
  CURSOR cr_popula_ttcheque(p_coop IN INTEGER
                        ,p_cdagenci IN INTEGER
                        ,p_nrocaixa IN INTEGER)IS
      SELECT mdw.dtlibcom
            ,mdw.nrdocmto
            ,mdw.cdhistor
            ,SUM(mdw.vlcompel) vlcompel
        FROM crapmdw mdw
       WHERE mdw.cdcooper = p_coop
         AND mdw.cdagenci = p_cdagenci
         AND mdw.nrdcaixa = p_nrocaixa
         AND mdw.cdhistor IN (3,4) -- (3 - Praca, 4 - Fora Praca)
      GROUP BY mdw.dtlibcom
              ,mdw.nrdocmto
              ,mdw.cdhistor;
  rw_popula_ttcheque cr_popula_ttcheque%ROWTYPE;
  
  /* Verifica tabela de Lancamentos Depositos */
  CURSOR cr_verifica_mdw(p_coop IN INTEGER
                        ,p_cdagenci IN INTEGER
                        ,p_nrocaixa IN INTEGER)IS
      SELECT mdw.lsdigctr
            ,mdw.dtlibcom
            ,mdw.nrdocmto
            ,mdw.vlcompel
            ,mdw.cdhistor
            ,mdw.nrctabdb
            ,mdw.cdcmpchq
            ,mdw.cdbanchq
            ,mdw.cdagechq
            ,mdw.nrctachq
            ,mdw.nrcheque
            ,mdw.tpdmovto
            ,mdw.dsdocmc7
            ,mdw.cdtipchq
            ,mdw.nrddigc1
            ,mdw.nrddigc2
            ,mdw.nrddigc3
            ,mdw.nrctaaux
            ,mdw.cdopelib
            ,mdw.nrautdoc
            ,rowid
        FROM crapmdw mdw
       WHERE mdw.cdcooper = p_coop
         AND mdw.cdagenci = p_cdagenci
         AND mdw.nrdcaixa = p_nrocaixa;
  rw_verifica_mdw cr_verifica_mdw%ROWTYPE;
  
  CURSOR cr_nrautdoc_mdw(p_rowid IN ROWID)IS
      SELECT mdw.nrautdoc
            ,rowid
        FROM crapmdw mdw
       WHERE mdw.rowid = p_rowid;
  rw_nrautdoc_mdw cr_nrautdoc_mdw%ROWTYPE;
  
  /* Verifica Resumo de Cheque para verificar se necessita
  verificar horario de corte */
  CURSOR cr_verif_hora_corte(p_coop IN INTEGER
                            ,p_cdagenci IN INTEGER
                            ,p_nrdcaixa IN INTEGER)IS
      SELECT mrw.vlchqipr
            ,mrw.vlchqspr
            ,mrw.vlchqifp
            ,mrw.vlchqsfp
            ,mrw.vlchqcop
        FROM crapmrw mrw
       WHERE mrw.cdcooper = p_coop
         AND mrw.cdagenci = p_cdagenci
         AND mrw.nrdcaixa = p_nrdcaixa
         AND mrw.vlchqipr <> 0 
         AND mrw.vlchqspr <> 0 
         AND mrw.vlchqifp <> 0 
         AND mrw.vlchqsfp <> 0;
  rw_verif_hora_corte cr_verif_hora_corte%ROWTYPE; 

  /* Verifica se existe registro na CRAPLOT */
  CURSOR cr_existe_lot(p_cdcooper IN INTEGER
                      ,p_dtmvtolt IN DATE
                      ,p_cdagenci IN INTEGER
                      ,p_cdbccxlt IN INTEGER
                      ,p_nrdolote IN INTEGER)IS
      SELECT lot.cdcooper
            ,lot.dtmvtolt
            ,lot.cdagenci
            ,lot.cdbccxlt
            ,lot.nrdolote
            ,lot.cdopecxa
        FROM craplot lot
       WHERE lot.cdcooper = p_cdcooper
         AND lot.dtmvtolt = p_dtmvtolt
         AND lot.cdagenci = p_cdagenci
         AND lot.cdbccxlt = p_cdbccxlt
         AND lot.nrdolote = p_nrdolote;
  rw_existe_lot cr_existe_lot%ROWTYPE;
  
  /* Buscar os Totais de Cheque Cooperativa */
  CURSOR cr_tot_chq_coop(p_coop IN INTEGER
                          ,p_cdagenci IN INTEGER
                          ,p_nrocaixa IN INTEGER)IS
      SELECT mrw.vlchqipr
            ,mrw.vlchqspr
            ,mrw.vlchqifp
            ,mrw.vlchqsfp
            ,mrw.vlchqcop
        FROM crapmrw mrw
       WHERE mrw.cdcooper = p_coop
         AND mrw.cdagenci = p_cdagenci
         AND mrw.nrdcaixa = p_nrocaixa;
  rw_tot_chq_coop cr_tot_chq_coop%ROWTYPE;
  
  /* Verifica se existe LCM - 6 Parametros */
  CURSOR cr_existe_lcm(p_cdcooper INTEGER
                      ,p_dtmvtolt DATE
                      ,p_cdagenci INTEGER
                      ,p_cdbccxlt INTEGER
                      ,p_nrdolote INTEGER
                      ,p_nrseqdig INTEGER) IS
     SELECT lcm.cdcooper
           ,lcm.dtmvtolt
           ,lcm.cdagenci
           ,lcm.cdbccxlt
           ,lcm.nrdolote
           ,lcm.nrseqdig
       FROM craplcm lcm
      WHERE lcm.cdcooper = p_cdcooper
        AND lcm.dtmvtolt = p_dtmvtolt
        AND lcm.cdagenci = p_cdagenci
        AND lcm.cdbccxlt = p_cdbccxlt
        AND lcm.nrdolote = p_nrdolote
        AND lcm.nrseqdig = p_nrseqdig;
  rw_existe_lcm cr_existe_lcm%ROWTYPE;
  
  /* Verifica se existe LCM - 7 Parametros */  
  CURSOR cr_existe_lcm1(p_cdcooper INTEGER
                       ,p_dtmvtolt DATE
                       ,p_cdagenci INTEGER
                       ,p_cdbccxlt INTEGER
                       ,p_nrdolote INTEGER
                       ,p_nrdctabb INTEGER
                       ,p_nrdocmto INTEGER) IS
     SELECT lcm.cdcooper
           ,lcm.dtmvtolt
           ,lcm.cdagenci
           ,lcm.cdbccxlt
           ,lcm.nrdolote
           ,lcm.nrdctabb
           ,lcm.nrdocmto
       FROM craplcm lcm
      WHERE lcm.cdcooper = p_cdcooper
        AND lcm.dtmvtolt = p_dtmvtolt
        AND lcm.cdagenci = p_cdagenci
        AND lcm.cdbccxlt = p_cdbccxlt
        AND lcm.nrdolote = p_nrdolote
        AND lcm.nrdctabb = p_nrdctabb
        AND lcm.nrdocmto = p_nrdocmto;
  rw_existe_lcm1 cr_existe_lcm1%ROWTYPE;
  
  -- Busca a ultma sequencia de dig
  CURSOR cr_consulta_lot (p_cdcooper IN craplot.cdcooper%TYPE
                         ,p_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,p_cdagenci IN craplot.cdagenci%TYPE
                         ,p_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,p_nrdolote IN craplot.nrdolote%TYPE) IS
     SELECT MAX(lot.nrseqdig) + 1 nrseqdig
       FROM craplot lot
       WHERE lot.cdcooper = p_cdcooper
         AND lot.dtmvtolt = p_dtmvtolt
         AND lot.cdagenci = p_cdagenci
         AND lot.cdbccxlt = p_cdbccxlt
         AND lot.nrdolote = p_nrdolote;
  rw_consulta_lot cr_consulta_lot%ROWTYPE;
  
  -- Verifica dados da cooperativa acolhedora
  CURSOR cr_consulta_chd (p_cdcooper IN crapchd.cdcooper%TYPE
                         ,p_dtmvtolt IN crapchd.dtmvtolt%TYPE
                         ,p_cdcmpchq IN crapchd.cdcmpchq%TYPE
                         ,p_cdbanchq IN crapchd.cdbanchq%TYPE
                         ,p_cdagechq IN crapchd.cdagechq%TYPE
                         ,p_nrctachq IN crapchd.nrctachq%TYPE
                         ,p_nrcheque IN crapchd.nrcheque%TYPE) IS
    SELECT chd.cdcooper
          ,chd.dtmvtolt
          ,chd.cdcmpchq
          ,chd.cdbanchq
          ,chd.cdagechq
          ,chd.nrctachq
          ,chd.nrcheque
          ,chd.cdagenci
          ,chd.cdbccxlt
          ,chd.nrdocmto
          ,chd.cdoperad
          ,chd.cdsitatu
          ,chd.dsdocmc7
          ,chd.inchqcop
          ,chd.insitchq
          ,chd.cdtipchq
          ,chd.nrdconta
          ,chd.nrddigc1
          ,chd.nrddigc2
          ,chd.nrddigc3
          ,chd.nrddigv1
          ,chd.nrddigv2
          ,chd.nrddigv3
          ,chd.nrdolote
          ,chd.tpdmovto
          ,chd.nrterfin
          ,chd.vlcheque
          ,chd.cdagedst
          ,chd.nrctadst                  
      FROM crapchd chd
     WHERE chd.cdcooper = p_cdcooper
       AND chd.dtmvtolt = p_dtmvtolt
       AND chd.cdcmpchq = p_cdcmpchq
       AND chd.cdbanchq = p_cdbanchq
       AND chd.cdagechq = p_cdagechq
       AND chd.nrctachq = p_nrctachq
       AND chd.nrcheque = p_nrcheque;
  rw_consulta_chd cr_consulta_chd%ROWTYPE;
  
  -- Busca novamente os dados da acolhedora
  CURSOR cr_rowid_chd(p_rowid IN ROWID) IS
    SELECT chd.cdcooper
          ,chd.dtmvtolt
          ,chd.cdcmpchq
          ,chd.cdbanchq
          ,chd.cdagechq
          ,chd.nrctachq
          ,chd.nrcheque
          ,chd.cdagenci
          ,chd.cdbccxlt
          ,chd.nrdocmto
          ,chd.cdoperad
          ,chd.cdsitatu
          ,chd.dsdocmc7
          ,chd.inchqcop
          ,chd.insitchq
          ,chd.cdtipchq
          ,chd.nrdconta
          ,chd.nrddigc1
          ,chd.nrddigc2
          ,chd.nrddigc3
          ,chd.nrddigv1
          ,chd.nrddigv2
          ,chd.nrddigv3
          ,chd.nrdolote
          ,chd.tpdmovto
          ,chd.nrterfin
          ,chd.vlcheque
          ,chd.cdagedst
          ,chd.nrctadst                  
      FROM crapchd chd
     WHERE ROWID = p_rowid;
  rw_rowid_chd cr_rowid_chd%ROWTYPE;
  
  -- Verfica Folha de Cheque da Cooperatica do Cheque
  CURSOR cr_verifica_fdc (p_cdcooper IN crapfdc.cdcooper%TYPE
                         ,p_cdbanchq IN crapfdc.cdbanchq%TYPE
                         ,p_cdagechq IN crapfdc.cdcmpchq%TYPE
                         ,p_nrctachq IN crapfdc.cdbanchq%TYPE
                         ,p_nrcheque IN crapfdc.cdagechq%TYPE) IS
     SELECT fdc.incheque
           ,fdc.dtliqchq
           ,fdc.cdoperad
           ,fdc.vlcheque
           ,fdc.cdbanchq
           ,fdc.cdagechq
           ,fdc.nrctachq
           ,fdc.tpcheque
       FROM crapfdc fdc
      WHERE fdc.cdcooper = p_cdcooper
        AND fdc.cdbanchq = p_cdbanchq
        AND fdc.cdagechq = p_cdagechq
        AND fdc.nrctachq = p_nrctachq
        AND fdc.nrcheque = p_nrcheque;
  rw_verifica_fdc cr_verifica_fdc%ROWTYPE;
  
  /* Verifica se existe registro na CRAPBCX */
  CURSOR cr_existe_bcx(p_cdcooper IN INTEGER
                      ,p_dtmvtolt IN DATE
                      ,p_cdagenci IN INTEGER
                      ,p_nrdcaixa IN INTEGER
                      ,p_cdopecxa IN VARCHAR2)IS
      SELECT bcx.qtcompln
            ,bcx.nrdmaqui
            ,bcx.qtchqprv
        FROM crapbcx bcx
       WHERE bcx.cdcooper = p_cdcooper
         AND bcx.dtmvtolt = p_dtmvtolt
         AND bcx.cdagenci = p_cdagenci
         AND bcx.nrdcaixa = p_nrdcaixa
         AND UPPER(bcx.cdopecxa) = UPPER(p_cdopecxa);
  rw_existe_bcx cr_existe_bcx%ROWTYPE;

  CURSOR cr_crapttl(pr_cdcooper crapttl.cdcooper%TYPE
	               ,pr_nrdconta crapttl.nrdconta%TYPE)IS
  SELECT crapttl.nmextttl
    FROM crapttl
   WHERE crapttl.cdcooper = pr_cdcooper
	 AND crapttl.nrdconta = pr_nrdconta
	 AND crapttl.idseqttl = 2;

  -- Variaveis Erro
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
  
  -- Variaveis
  pr_typ_tab_chq  typ_tab_chq;
  vr_lsdigctr     gene0002.typ_split;
  
  vr_dsdctitg            VARCHAR2(200) := '';
  vr_stsnrcal            INTEGER       := 0;
  vr_achou_horario_corte BOOLEAN       := FALSE;
  vr_i_nro_lote          NUMBER(10)    := 0;
  vr_c_docto_salvo       VARCHAR2(200) := '';
  vr_cdpacrem            PLS_INTEGER;
  vr_c_docto             VARCHAR2(200) := '';
  vr_tpdmovto            INTEGER       := 0;
  vr_i_nro_docto         INTEGER       := 0;
  vr_p_literal           VARCHAR2(32000) := '';
  vr_p_ult_sequencia     INTEGER       := 0;
  vr_p_registro          ROWID;
  vr_rowid_chd           ROWID;
  vr_aux_p_literal       VARCHAR2(32000) := '';
  vr_aux_p_ult_seq       INTEGER       := 0;  
  vr_aux_p_registro      ROWID;
  vr_de_valor_total      NUMBER(13,2)  := 0;
  vr_de_cooperativa      NUMBER(13,2)  := 0;
  vr_de_chq_intercoopc   NUMBER(13,2)  := 0;
  vr_de_maior_praca      NUMBER(13,2)  := 0;
  vr_de_menor_praca      NUMBER(13,2)  := 0;
  vr_de_maior_fpraca     NUMBER(13,2)  := 0;
  vr_de_menor_fpraca     NUMBER(13,2)  := 0;
  vr_index               VARCHAR2(21)  := '';
  vr_index2              NUMBER        := 0;
  vr_i_seq_386           INTEGER       := 0;
  vr_nrsequen            INTEGER       := 0;
  vr_glb_dsdctitg        VARCHAR2(200) := '';
  vr_literal             VARCHAR2(32000) := '';
  vr_nmsegntl            crapttl.nmextttl%TYPE;
    
  vr_nrtrfcta     craptrf.nrsconta%TYPE := 0;
  vr_nrdconta     craptrf.nrsconta%TYPE := 0;
  vr_nro_conta    craptrf.nrsconta%TYPE := 0;
  vr_aux_cdhistor craplcm.cdhistor%TYPE;
  vr_aux_inchqcop crapchd.inchqcop%TYPE;
  vr_aux_nrctachq crapchd.nrctachq%TYPE;
  vr_aux_nrddigv1 crapchd.nrddigv1%TYPE;
  vr_aux_nrddigv2 crapchd.nrddigv2%TYPE;
  vr_aux_nrddigv3 crapchd.nrddigv3%TYPE;
  vr_aux_nrseqdig crapmdw.nrseqdig%TYPE;  
  vr_aux_cdbandep crapfdc.cdbandep%TYPE;
  vr_aux_cdagedep crapfdc.cdagedep%TYPE;

  -- Guardar registro dstextab
  vr_dstextab craptab.dstextab%TYPE;

  BEGIN

     -- Busca Cod. Coop de DESTINO
     OPEN cr_cod_coop_dest(pr_cooper_dest);
     FETCH cr_cod_coop_dest INTO rw_cod_coop_dest;
     CLOSE cr_cod_coop_dest;

     -- Busca Cod. Coop de ORIGEM
     OPEN cr_cod_coop_orig(pr_cooper);
     FETCH cr_cod_coop_orig INTO rw_cod_coop_orig;
     CLOSE cr_cod_coop_orig;

     -- Busca Data do Sistema
     OPEN cr_dat_cop(rw_cod_coop_orig.cdcooper);
     FETCH cr_dat_cop INTO rw_dat_cop;
     CLOSE cr_dat_cop;

     /* Gravar o Nro da Conta para possivel manipulacao
     do nro da conta utilizar a variavel */   
     vr_nro_conta := pr_nro_conta;

     -- Verifica a conta do associado
     OPEN cr_verifica_ass(rw_cod_coop_dest.cdcooper
                         ,vr_nro_conta);
     FETCH cr_verifica_ass INTO rw_verifica_ass;
     CLOSE cr_verifica_ass;

	 IF rw_verifica_ass.inpessoa = 1 THEN

	   OPEN cr_crapttl(pr_cdcooper => rw_verifica_ass.cdcooper
	                  ,pr_nrdconta => rw_verifica_ass.nrdconta);

	   FETCH cr_crapttl INTO vr_nmsegntl;

	   CLOSE cr_crapttl;

	 END IF;

     -- Verifica Transferencia e Duplicacao de Matricula - Associado de Destino
     OPEN cr_tdm_ass(rw_cod_coop_dest.cdcooper
                    ,vr_nro_conta);
     FETCH cr_tdm_ass INTO rw_tdm_ass;
        IF cr_tdm_ass%FOUND THEN
           OPEN cr_verifica_trf(rw_cod_coop_dest.cdcooper
                               ,rw_tdm_ass.nrdconta);
           FETCH cr_verifica_trf INTO rw_verifica_trf;
              IF cr_verifica_trf%FOUND THEN
                 vr_nrtrfcta  := rw_verifica_trf.nrsconta;
                 vr_nrdconta  := rw_verifica_trf.nrsconta;
                 vr_nro_conta := rw_verifica_trf.nrsconta;
              END IF;
           CLOSE cr_verifica_trf;           
        END IF;             
     CLOSE cr_tdm_ass;

     CXON0000.pc_elimina_erro(pr_cooper      => rw_cod_coop_orig.cdcooper
                             ,pr_cod_agencia => pr_cod_agencia
                             ,pr_nro_caixa   => pr_nro_caixa
                             ,pr_cdcritic    => vr_cdcritic
                             ,pr_dscritic    => vr_dscritic);
     -- Se ocorreu erro
     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
     
        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => pr_nro_caixa
                             ,pr_cod_erro => pr_cdcritic
                             ,pr_dsc_erro => pr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                             
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := vr_dscritic;
           RAISE vr_exc_erro;          
        END IF;
        
        RAISE vr_exc_erro;
     END IF;

     --  Verifica tabela de Resumos de Lancamentos Depositos
     OPEN cr_verifica_mrw(rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia
                         ,pr_nro_caixa);
     FETCH cr_verifica_mrw INTO rw_verifica_mrw;
        IF cr_verifica_mrw%NOTFOUND THEN
           pr_cdcritic := 0;
           pr_dscritic := 'Nao existem valores a serem Depositados';
           
           cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                ,pr_cdagenci => pr_cod_agencia
                                ,pr_nrdcaixa => pr_nro_caixa
                                ,pr_cod_erro => pr_cdcritic
                                ,pr_dsc_erro => pr_dscritic
                                ,pr_flg_erro => TRUE
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
                                
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
              RAISE vr_exc_erro;
           END IF;
           
           RAISE vr_exc_erro;
        END IF;
     CLOSE cr_verifica_mrw;
     
     --  Verifica tabela de Lancamentos Depositos
     OPEN cr_verifica_mdw(rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia
                         ,pr_nro_caixa);
     FETCH cr_verifica_mdw INTO rw_verifica_mdw;
        
        vr_lsdigctr := gene0002.fn_quebra_string(pr_string  => rw_verifica_mdw.lsdigctr
                                                ,pr_delimit => ',');
                                 
        IF vr_lsdigctr.COUNT() <> 3 THEN
           pr_cdcritic := 0;
           pr_dscritic := 'Avise INF(ENTRY) = ' ||
                          TO_CHAR(rw_verifica_mdw.lsdigctr) ||' - '||
                          TO_CHAR(rw_verifica_mdw.nrcheque);
                          
           cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                ,pr_cdagenci => pr_cod_agencia
                                ,pr_nrdcaixa => pr_nro_caixa
                                ,pr_cod_erro => pr_cdcritic
                                ,pr_dsc_erro => pr_dscritic
                                ,pr_flg_erro => TRUE
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
                                
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
              RAISE vr_exc_erro;
           END IF;
           
           RAISE vr_exc_erro;
        END IF;
     CLOSE cr_verifica_mdw;
     
     vr_nrtrfcta := 0;
     vr_nrdconta := vr_nro_conta;
     
     -- Verifica se Houve Transferencia de Conta
     OPEN cr_tdc_ass(rw_cod_coop_dest.cdcooper
                    ,vr_nrdconta);
     FETCH cr_tdc_ass INTO rw_tdc_ass;
        IF cr_tdc_ass%FOUND THEN
           OPEN cr_verifica_trf(rw_cod_coop_dest.cdcooper
                               ,rw_tdc_ass.nrdconta);
           FETCH cr_verifica_trf INTO rw_verifica_trf;
              IF cr_verifica_trf%FOUND THEN
                 vr_nrtrfcta  := rw_verifica_trf.nrsconta;
                 vr_nrdconta  := rw_verifica_trf.nrsconta;                
              END IF;
           CLOSE cr_verifica_trf;       
        END IF;             
     CLOSE cr_tdc_ass;
     
     -- Se houve transferencia de conta, grava na variavel
     IF vr_nrtrfcta > 0 THEN
        vr_nrdconta := vr_nrtrfcta;
     END IF;
     
     -- Gravar o Nro da Conta e utilizar a variavel
     vr_nro_conta := vr_nrdconta;

     -- Verifica horario de Corte - Coop do Caixa
     vr_achou_horario_corte := FALSE;
     FOR rw_verif_hora_corte IN cr_verif_hora_corte(rw_cod_coop_orig.cdcooper
                                                   ,pr_cod_agencia
                                                   ,pr_nro_caixa) LOOP
        vr_achou_horario_corte := TRUE; -- Registro encontrado    
     END LOOP;
     
     -- Se encontrou registro. Valida horario de Corte - Coop do Caixa
     IF vr_achou_horario_corte THEN
        
          -- Buscar configuração na tabela
          vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 0
                                                   ,pr_cdacesso => 'HRTRCOMPEL'
                                                   ,pr_tpregist => pr_cod_agencia);        
            
           IF TRIM(vr_dstextab) IS NULL THEN 
              pr_cdcritic := 676;
              pr_dscritic := '';
              
              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => pr_nro_caixa
                                   ,pr_cod_erro => pr_cdcritic
                                   ,pr_dsc_erro => pr_dscritic
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
                                   
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic;
                 RAISE vr_exc_erro;
              END IF;
              
              RAISE vr_exc_erro;
           END IF;
           
           IF TO_NUMBER(SUBSTR(vr_dstextab,1,1)) <> 0 THEN
              pr_cdcritic := 677;
              pr_dscritic := '';
              
              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => pr_nro_caixa
                                   ,pr_cod_erro => pr_cdcritic
                                   ,pr_dsc_erro => pr_dscritic
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
                                   
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic;
                 RAISE vr_exc_erro;
              END IF;
              
              RAISE vr_exc_erro;
           END IF;
           
           IF TO_NUMBER(SUBSTR(vr_dstextab,3,5)) <= TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')) THEN
              pr_cdcritic := 676;
              pr_dscritic := '';
              
              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => pr_nro_caixa
                                   ,pr_cod_erro => pr_cdcritic
                                   ,pr_dsc_erro => pr_dscritic
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
                                   
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic;
                 RAISE vr_exc_erro;
              END IF;
              
              RAISE vr_exc_erro;
           END IF;
           
     END IF; -- Verifica Horario de Corte
     
     -- Criacao do LOTE de DESTINO (CREDITO)
     vr_i_nro_lote    := 10118;
     vr_c_docto_salvo := TO_CHAR(SYSDATE,'SSSSS');
     
     -- Verifica se existe lote
     OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                       ,rw_dat_cop.dtmvtocd
                       ,1   /* FIXO */
                       ,100 /* FIXO */
                       ,vr_i_nro_lote);
     FETCH cr_existe_lot INTO rw_existe_lot;
        IF cr_existe_lot%NOTFOUND THEN
           -- Se nao existir cria a capa de lote
           BEGIN
              INSERT INTO craplot(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,tplotmov
                                 ,nrdcaixa
                                 ,cdopecxa)
              VALUES (rw_cod_coop_dest.cdcooper
                     ,rw_dat_cop.dtmvtocd
                     ,1
                     ,100
                     ,vr_i_nro_lote
                     ,1
                     ,pr_nro_caixa
                     ,pr_cod_operador);              
           EXCEPTION
              WHEN OTHERS THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Erro ao inserir na CRAPLOT : '||sqlerrm;
                                  
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
                                      
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                    RAISE vr_exc_erro;
                 END IF;
              
                 RAISE vr_exc_erro;
           END;
        END IF;
     CLOSE cr_existe_lot;

     vr_de_valor_total    := 0;
     vr_de_cooperativa    := 0;
     vr_de_chq_intercoopc := 0;
     vr_de_maior_praca    := 0;
     vr_de_menor_praca    := 0;
     vr_de_maior_fpraca   := 0;
     vr_de_menor_fpraca   := 0;

     -- RESUMO
     -- Buscar os Totais de Cheque Cooperativa
     OPEN cr_tot_chq_coop(rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia
                         ,pr_nro_caixa);
     FETCH cr_tot_chq_coop INTO rw_tot_chq_coop;
        IF cr_tot_chq_coop%FOUND THEN
           vr_de_cooperativa    := rw_tot_chq_coop.vlchqcop;
           vr_de_valor_total    := vr_de_cooperativa;           
        END IF;
     CLOSE cr_tot_chq_coop;
     
     -- Buscar configuração na tabela
     vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'MAIORESCHQ'
                                              ,pr_tpregist => 1);
            
     IF TRIM(vr_dstextab) IS NOT NULL THEN                          
            
        -- Buscar os totais de Cheques
        FOR rw_verifica_mdw IN cr_verifica_mdw(rw_cod_coop_orig.cdcooper
                                              ,pr_cod_agencia
                                              ,pr_nro_caixa) LOOP
           -- Montar chave de busca
           vr_index :=  TO_CHAR(rw_verifica_mdw.dtlibcom,'DD/MM/RRRR')||
                        TO_CHAR(LPAD(rw_verifica_mdw.nrdocmto,10,0));
           
           -- Se a chave ainda não existir
           IF pr_typ_tab_chq.count = 0 OR NOT pr_typ_tab_chq.exists(vr_index) THEN
             pr_typ_tab_chq(vr_index).vlcompel := 0; -- Inicializa o campo de valor
           END IF;

           -- Define o tipo do docmto (1-Menor Praca-Maior/2-Praca,1-Menor Fora Praca/2-Maior Fora Praca)
           IF rw_verifica_mdw.vlcompel < TO_NUMBER(SUBSTR(vr_dstextab,1,15)) THEN               
              vr_tpdmovto := 2;             
           ELSE
              vr_tpdmovto := 1;
           END IF;
            
            IF rw_verifica_mdw.cdhistor = 3 THEN -- Praca
               IF vr_tpdmovto = 2 THEN -- Menor Praca
                  pr_typ_tab_chq(vr_index).dtlibcom := rw_verifica_mdw.dtlibcom;
                  pr_typ_tab_chq(vr_index).vlcompel := pr_typ_tab_chq(vr_index).vlcompel + rw_verifica_mdw.vlcompel;
                  pr_typ_tab_chq(vr_index).nrdocmto := 3;
                  vr_de_menor_praca                 := vr_de_menor_praca + rw_verifica_mdw.vlcompel;
               ELSE -- Maior Praca
                  pr_typ_tab_chq(vr_index).dtlibcom := rw_verifica_mdw.dtlibcom;
                  pr_typ_tab_chq(vr_index).vlcompel := pr_typ_tab_chq(vr_index).vlcompel + rw_verifica_mdw.vlcompel;
                  pr_typ_tab_chq(vr_index).nrdocmto := 4;
                  vr_de_maior_praca                 := vr_de_maior_praca + rw_verifica_mdw.vlcompel;
               END IF;                 
            ELSE -- Fora Praca
               IF rw_verifica_mdw.cdhistor = 4 THEN
                  IF vr_tpdmovto = 2 THEN -- Menor Fora Praca
                     pr_typ_tab_chq(vr_index).dtlibcom := rw_verifica_mdw.dtlibcom;
                     pr_typ_tab_chq(vr_index).vlcompel := pr_typ_tab_chq(vr_index).vlcompel + rw_verifica_mdw.vlcompel;
                     pr_typ_tab_chq(vr_index).nrdocmto := 5;
                     vr_de_menor_fpraca                := vr_de_menor_fpraca + rw_verifica_mdw.vlcompel;
                  ELSE -- Maior Fora Praca
                     pr_typ_tab_chq(vr_index).dtlibcom := rw_verifica_mdw.dtlibcom;
                     pr_typ_tab_chq(vr_index).vlcompel := pr_typ_tab_chq(vr_index).vlcompel + rw_verifica_mdw.vlcompel;
                     pr_typ_tab_chq(vr_index).nrdocmto := 6;
                     vr_de_maior_fpraca                := vr_de_maior_fpraca + rw_verifica_mdw.vlcompel;
                  END IF;  
               END IF;
            END IF;                                                   
                                                                                                                 
        END LOOP;
        -- Fim da montagem do Resumo
          
     END IF; /* IF TRIM(vr_dstextab) IS NOT NULL AND ... */
     
     vr_de_valor_total := vr_de_valor_total
                        + vr_de_menor_fpraca + vr_de_menor_praca
                        + vr_de_maior_fpraca + vr_de_maior_praca;
                        
     /** Se veio da Rotina 61 **/
     IF NVL(pr_identifica,' ') LIKE '%Deposito de envelope%'  THEN
        vr_cdpacrem := 91; /* TAA */
     ELSE
        vr_cdpacrem := pr_cod_agencia;
     END IF;
     
     -- Cria registro na CRAPLDT - Para o valor total da transacao
     CXON0022.pc_gera_log(pr_cooper       => rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia  => pr_cod_agencia
                         ,pr_nro_caixa    => pr_nro_caixa
                         ,pr_operador     => pr_cod_operador
                         ,pr_cooper_dest  => rw_cod_coop_dest.cdcooper
                         ,pr_nrdcontade   => pr_nro_conta_de
                         ,pr_nrdcontapara => pr_nro_conta
                         ,pr_tpoperac     => 5 -- Dep em Cheque
                         ,pr_valor        => vr_de_valor_total
                         ,pr_nrdocmto     =>  TO_NUMBER(vr_c_docto_salvo)
                         ,pr_cdpacrem     => vr_cdpacrem
                         ,pr_cdcritic     => vr_cdcritic   -- Codigo do erro
                         ,pr_dscritic     => vr_dscritic); -- Descricao da Critica
                         
     -- Se ocorreu erro
     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
     
        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => pr_nro_caixa
                             ,pr_cod_erro => pr_cdcritic
                             ,pr_dsc_erro => pr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                             
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := vr_dscritic;
           RAISE vr_exc_erro;
        END IF;
        
        RAISE vr_exc_erro;
     END IF;

     vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo);
     pr_nro_docmto  := TO_NUMBER(vr_c_docto_salvo);
     
     -- Grava Autenticacao Arquivo/Spool
     CXON0000.pc_grava_autenticacao(pr_cooper       => rw_cod_coop_orig.cdcooper
                                   ,pr_cod_agencia  => pr_cod_agencia
                                   ,pr_nro_caixa    => pr_nro_caixa
                                   ,pr_cod_operador => pr_cod_operador
                                   ,pr_valor        => vr_de_valor_total
                                   ,pr_docto        => TO_NUMBER(vr_i_nro_docto)
                                   ,pr_operacao     => FALSE -- YES (PG), NO (RC)
                                   ,pr_status       => '1' -- On-line
                                   ,pr_estorno      => FALSE -- Nao estorno
                                   ,pr_histor       => 700
                                   ,pr_data_off     => NULL 
                                   ,pr_sequen_off   => 0 -- Seq. off-line
                                   ,pr_hora_off     => 0 -- hora off-line
                                   ,pr_seq_aut_off  => 0 -- Seq.orig.Off-line
                                   ,pr_literal      => vr_p_literal
                                   ,pr_sequencia    => vr_p_ult_sequencia
                                   ,pr_registro     => vr_p_registro
                                   ,pr_cdcritic     => vr_cdcritic
                                   ,pr_dscritic     => vr_dscritic);
     -- Se ocorreu erro
     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
     
        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => pr_nro_caixa
                             ,pr_cod_erro => pr_cdcritic
                             ,pr_dsc_erro => pr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                             
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := vr_dscritic;
           RAISE vr_exc_erro;
        END IF;
        
        RAISE vr_exc_erro;
     END IF;
     
     OPEN cr_existe_bcx(rw_cod_coop_orig.cdcooper
                       ,rw_dat_cop.dtmvtolt
                       ,pr_cod_agencia
                       ,pr_nro_caixa
                       ,pr_cod_operador);
     FETCH cr_existe_bcx INTO rw_existe_bcx;
       -- Informacao da cooperativa de origem
       BEGIN
          INSERT INTO craplcx(cdcooper
                             ,dtmvtolt
                             ,cdagenci
                             ,nrdcaixa
                             ,cdopecxa
                             ,nrdocmto
                             ,nrseqdig
                             ,nrdmaqui
                             ,cdhistor
                             ,dsdcompl
                             ,vldocmto
                             ,nrautdoc)
          VALUES (rw_cod_coop_orig.cdcooper
                 ,rw_dat_cop.dtmvtolt
                 ,pr_cod_agencia
                 ,pr_nro_caixa
                 ,pr_cod_operador
                 ,TO_NUMBER(vr_i_nro_docto)
                 ,rw_existe_bcx.qtcompln + 1
                 ,rw_existe_bcx.nrdmaqui
                 ,1528
                 ,'Agencia:'||gene0002.fn_mask(rw_cod_coop_dest.cdagectl,'zzz9')||
                  ' Conta/DV:'||gene0002.fn_mask(pr_nro_conta,'zzzz.zzz.9')
                 ,vr_de_valor_total
                 ,vr_p_ult_sequencia);              
       EXCEPTION
          WHEN OTHERS THEN
             pr_cdcritic := 0;
             pr_dscritic := 'Erro ao inserir na CRAPLCX : '||sqlerrm;
                              
             cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                  ,pr_cdagenci => pr_cod_agencia
                                  ,pr_nrdcaixa => pr_nro_caixa
                                  ,pr_cod_erro => pr_cdcritic
                                  ,pr_dsc_erro => pr_dscritic
                                  ,pr_flg_erro => TRUE
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
                                  
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
                RAISE vr_exc_erro;
             END IF;
          
             RAISE vr_exc_erro;
       END;
     CLOSE cr_existe_bcx;
     
     OPEN cr_verifica_mrw(rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia
                         ,pr_nro_caixa);
     FETCH cr_verifica_mrw INTO rw_verifica_mrw;
        IF cr_verifica_mrw%FOUND THEN
           
           -- Formata conta integracao
           GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => vr_nro_conta
                                         ,pr_dscalcul => vr_dsdctitg
                                         ,pr_stsnrcal => vr_stsnrcal
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
           -- Se ocorreu erro
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
     
              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => pr_nro_caixa
                                   ,pr_cod_erro => pr_cdcritic
                                   ,pr_dsc_erro => pr_dscritic
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
                             
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic;
                 RAISE vr_exc_erro;
              END IF;
        
              RAISE vr_exc_erro;
           END IF;
                      
           /* Dinheiro - Nao eh tratato nessa procedure */
                      
           IF rw_verifica_mrw.vlchqcop <> 0 THEN
             
              vr_c_docto := vr_c_docto_salvo || '01' ||'2'; -- 'Sequencial' fixo 01
              
              -- Busca o ultima sequencia de digito
              OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                                  ,rw_dat_cop.dtmvtocd
                                  ,1   -- FIXO
                                  ,100 -- FIXO
                                  ,vr_i_nro_lote);
              FETCH cr_consulta_lot INTO rw_consulta_lot;
              CLOSE cr_consulta_lot;
              
              -- Verifica se Lancamento ja Existe no Dest.
              OPEN cr_existe_lcm(rw_cod_coop_dest.cdcooper
                                ,rw_dat_cop.dtmvtolt
                                ,1
                                ,100
                                ,vr_i_nro_lote
                                ,rw_consulta_lot.nrseqdig); -- Já está encrementado + 1 no CURSOR cr_consulta_lot
              FETCH cr_existe_lcm INTO rw_existe_lcm;
                 IF cr_existe_lcm%FOUND THEN
                    pr_cdcritic := 0;
                    pr_dscritic := 'Lancamento  ja existente';
                                      
                    cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                         ,pr_cdagenci => pr_cod_agencia
                                         ,pr_nrdcaixa => pr_nro_caixa
                                         ,pr_cod_erro => pr_cdcritic
                                         ,pr_dsc_erro => pr_dscritic
                                         ,pr_flg_erro => TRUE
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
   
                    -- Levantar excecao
                    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                       pr_cdcritic := vr_cdcritic;
                       pr_dscritic := vr_dscritic;
                       RAISE vr_exc_erro;
                    END IF;

                    RAISE vr_exc_erro;
                 END IF;              
              CLOSE cr_existe_lcm;
              
              OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                                ,rw_dat_cop.dtmvtolt
                                ,1
                                ,100
                                ,vr_i_nro_lote
                                ,pr_nro_conta
                                ,vr_c_docto);
              FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
                 IF cr_existe_lcm1%FOUND THEN
                    pr_cdcritic := 0;
                    pr_dscritic := 'Lancamento(Primario) ja existente';
                                      
                    cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                         ,pr_cdagenci => pr_cod_agencia
                                         ,pr_nrdcaixa => pr_nro_caixa
                                         ,pr_cod_erro => pr_cdcritic
                                         ,pr_dsc_erro => pr_dscritic
                                         ,pr_flg_erro => TRUE
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic); 
                    -- Levantar excecao
                    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                       pr_cdcritic := vr_cdcritic;
                       pr_dscritic := vr_dscritic;
                       RAISE vr_exc_erro;
                    END IF;

                    RAISE vr_exc_erro;
                 END IF;              
              CLOSE cr_existe_lcm1;
              
              -- Chegou aqui eh porque nao existir lcm, entao cria registro de lcm
              BEGIN
                 INSERT INTO craplcm(cdcooper
                                    ,dtmvtolt
                                    ,cdagenci
                                    ,cdbccxlt
                                    ,dsidenti
                                    ,nrdolote
                                    ,nrdconta
                                    ,nrdocmto
                                    ,vllanmto
                                    ,cdhistor
                                    ,nrseqdig
                                    ,nrdctabb
                                    ,nrautdoc
                                    ,cdpesqbb
                                    ,nrdctitg
                                    ,cdcoptfn
                                    ,cdagetfn
                                    ,nrterfin
                                    ,cdoperad)
                 VALUES (rw_cod_coop_dest.cdcooper
                        ,rw_dat_cop.dtmvtolt
                        ,1
                        ,100
                        ,pr_identifica
                        ,vr_i_nro_lote
                        ,pr_nro_conta
                        ,TO_NUMBER(vr_c_docto)
                        ,rw_verifica_mrw.vlchqcop
                        ,1524 -- 386 - CR.TRF.CH.INT
                        ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                        ,pr_nro_conta
                        ,vr_p_ult_sequencia
                        ,'CRAP22'
                        ,vr_glb_dsdctitg
                        ,rw_cod_coop_orig.cdcooper
                        ,pr_cod_agencia
                        ,pr_nro_caixa
                        ,pr_cod_operador);              
              EXCEPTION
                 WHEN OTHERS THEN
                    pr_cdcritic := 0;
                    pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
                                  
                    cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                         ,pr_cdagenci => pr_cod_agencia
                                         ,pr_nrdcaixa => pr_nro_caixa
                                         ,pr_cod_erro => pr_cdcritic
                                         ,pr_dsc_erro => pr_dscritic
                                         ,pr_flg_erro => TRUE
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                    -- Levantar excecao
                    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                       pr_cdcritic := vr_cdcritic;
                       pr_dscritic := vr_dscritic;
                       RAISE vr_exc_erro;
                    END IF;

                    RAISE vr_exc_erro;
              END;
              
              vr_i_seq_386 := rw_consulta_lot.nrseqdig;
     
              -- Verifica se existe lote
              OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                                ,rw_dat_cop.dtmvtocd
                                ,1   /* FIXO */
                                ,100 /* FIXO */
                                ,vr_i_nro_lote);
              FETCH cr_existe_lot INTO rw_existe_lot;
                 IF cr_existe_lot%FOUND THEN
                    -- Se nao existir cria a capa de lote
                    BEGIN
                       UPDATE craplot lot
                          SET lot.nrseqdig = lot.nrseqdig + 1
                             ,lot.qtcompln = lot.qtcompln + 1
                             ,lot.qtinfoln = lot.qtinfoln + 1
                             ,lot.vlcompcr = lot.vlcompcr + rw_verifica_mrw.vlchqcop
                             ,lot.vlinfocr = lot.vlinfocr + rw_verifica_mrw.vlchqcop
                        WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                          AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                          AND lot.cdagenci = 1
                          AND lot.cdbccxlt = 100
                          AND lot.nrdolote = vr_i_nro_lote;             
                    EXCEPTION
                       WHEN OTHERS THEN
                          pr_cdcritic := 0;
                          pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                           
                          cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                               ,pr_cdagenci => pr_cod_agencia
                                               ,pr_nrdcaixa => pr_nro_caixa
                                               ,pr_cod_erro => pr_cdcritic
                                               ,pr_dsc_erro => pr_dscritic
                                               ,pr_flg_erro => TRUE
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic); 
                          -- Levantar excecao
                          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                             pr_cdcritic := vr_cdcritic;
                             pr_dscritic := vr_dscritic;
                             RAISE vr_exc_erro;
                          END IF;
                          
                          RAISE vr_exc_erro;                          
                     END;                     
                  END IF;
               CLOSE cr_existe_lot;                            
           END IF;                  
        END IF;
     CLOSE cr_verifica_mrw;
     
     vr_nrsequen := 0;
     
     -- Cheque MENOR PRACA
     vr_index := pr_typ_tab_chq.first(); -- Posiciona no primeiro registro
     WHILE vr_index IS NOT NULL LOOP
        IF pr_typ_tab_chq(vr_index).nrdocmto = 3 THEN
          
           /* Sequencial utilizado para separar um lançamento
           em conta para cada data nao ocorrendo duplicidade de chave */
           vr_nrsequen := vr_nrsequen + 1;
           vr_c_docto  := vr_c_docto_salvo || to_char(gene0002.fn_mask(pr_dsorigi => vr_nrsequen, pr_dsforma => '99' )) || pr_typ_tab_chq(vr_index).nrdocmto;
           
           /* Numero de sequencia sera utilizado para identificar cada
           cheque(crapchd) do lancamento total da data */
           pr_typ_tab_chq(vr_index).nrsequen := vr_nrsequen;
           
           -- Busca o ultima sequencia de digito
           OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                               ,rw_dat_cop.dtmvtocd
                               ,1   -- FIXO
                               ,100 -- FIXO
                               ,vr_i_nro_lote);
           FETCH cr_consulta_lot INTO rw_consulta_lot;
           CLOSE cr_consulta_lot;
              
           -- Verifica se Lancamento ja Existe no Dest.
           OPEN cr_existe_lcm(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,1
                             ,100
                             ,vr_i_nro_lote
                             ,rw_consulta_lot.nrseqdig); -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           FETCH cr_existe_lcm INTO rw_existe_lcm;
              IF cr_existe_lcm%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento  ja existente';
                                      
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;              
           CLOSE cr_existe_lcm;
              
           OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                              ,rw_dat_cop.dtmvtolt
                              ,1
                              ,100
                              ,vr_i_nro_lote
                              ,pr_nro_conta
                              ,vr_c_docto);
           FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
              IF cr_existe_lcm1%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento(Primario) ja existente';
                                     
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 

                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;            
           CLOSE cr_existe_lcm1;
              
           -- Chegou aqui eh porque nao existir lcm, entao cria registro de lcm
           BEGIN
              INSERT INTO craplcm(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,dsidenti
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrdocmto
                                 ,vllanmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,nrdctabb
                                 ,nrautdoc
                                 ,cdpesqbb
                                 ,nrdctitg
                                 ,cdcoptfn
                                 ,cdagetfn
                                 ,nrterfin
                                 ,cdoperad)
              VALUES (rw_cod_coop_dest.cdcooper
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,pr_identifica
                     ,vr_i_nro_lote
                     ,pr_nro_conta
                     ,TO_NUMBER(vr_c_docto)
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1526  /* 3 DEP.CHQ.PR. */
                     ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                     ,pr_nro_conta
                     ,vr_p_ult_sequencia
                     ,'CRAP22'
                     ,vr_glb_dsdctitg
                     ,rw_cod_coop_orig.cdcooper
                     ,pr_cod_agencia
                     ,pr_nro_caixa
                     ,pr_cod_operador);
                     
                     -- Guarda o sequencial usado no lancamento
                     pr_typ_tab_chq(vr_index).nrseqlcm := rw_consulta_lot.nrseqdig; -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic;
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
           END;
           
           -- Verifica se existe lote
           OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtocd
                             ,1   /* FIXO */
                             ,100 /* FIXO */
                             ,vr_i_nro_lote);
           FETCH cr_existe_lot INTO rw_existe_lot;
              IF cr_existe_lot%FOUND THEN
                 BEGIN
                    UPDATE craplot lot
                       SET lot.nrseqdig = lot.nrseqdig + 1
                          ,lot.qtcompln = lot.qtcompln + 1
                          ,lot.qtinfoln = lot.qtinfoln + 1
                          ,lot.vlcompcr = lot.vlcompcr + pr_typ_tab_chq(vr_index).vlcompel
                          ,lot.vlinfocr = lot.vlinfocr + pr_typ_tab_chq(vr_index).vlcompel
                     WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                       AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                       AND lot.cdagenci = 1
                       AND lot.cdbccxlt = 100
                       AND lot.nrdolote = vr_i_nro_lote;             
                 EXCEPTION
                    WHEN OTHERS THEN
                       pr_cdcritic := 0;
                       pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                  
                       cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                            ,pr_cdagenci => pr_cod_agencia
                                            ,pr_nrdcaixa => pr_nro_caixa
                                            ,pr_cod_erro => pr_cdcritic
                                            ,pr_dsc_erro => pr_dscritic
                                            ,pr_flg_erro => TRUE
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic); 
                       -- Levantar excecao
                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          pr_cdcritic := vr_cdcritic;
                          pr_dscritic := vr_dscritic;
                          RAISE vr_exc_erro;
                       END IF;

                       RAISE vr_exc_erro;

                 END;
              END IF;
           CLOSE cr_existe_lot;
           
           -- Cria registro de Deposito Bloqueado
           BEGIN
              INSERT INTO crapdpb(nrdconta
                                 ,dtliblan
                                 ,cdhistor
                                 ,nrdocmto
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,vllanmto
                                 ,inlibera
                                 ,cdcooper)
              VALUES (pr_nro_conta
                     ,pr_typ_tab_chq(vr_index).dtlibcom
                     ,1526 -- 3
                     ,TO_NUMBER(vr_c_docto)
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,vr_i_nro_lote
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1
                     ,rw_cod_coop_dest.cdcooper);
           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPDPB : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic;
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
           END;           
        END IF;        
        vr_index:= pr_typ_tab_chq.NEXT(vr_index); -- Proximo registro
        
     END LOOP; -- Fim cheques menor praca
     
     vr_nrsequen := 0;
     
     -- Cheque MAIOR PRACA
     vr_index := pr_typ_tab_chq.first(); -- Posiciona no primeiro registro
     WHILE vr_index IS NOT NULL LOOP
        IF pr_typ_tab_chq(vr_index).nrdocmto = 4 THEN
          
           /* Sequencial utilizado para separar um lançamento
           para cada data nao ocorrendo duplicidade de chave */

           vr_nrsequen := vr_nrsequen + 1;
           vr_c_docto  := vr_c_docto_salvo || to_char(gene0002.fn_mask(pr_dsorigi => vr_nrsequen, pr_dsforma => '99' )) || pr_typ_tab_chq(vr_index).nrdocmto;
           
           pr_typ_tab_chq(vr_index).nrsequen := vr_nrsequen;
           
           -- Busca o ultima sequencia de digito
           OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                               ,rw_dat_cop.dtmvtocd
                               ,1   -- FIXO
                               ,100 -- FIXO
                               ,vr_i_nro_lote);
           FETCH cr_consulta_lot INTO rw_consulta_lot;
           CLOSE cr_consulta_lot;
              
           -- Verifica se Lancamento ja Existe no Dest.
           OPEN cr_existe_lcm(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,1
                             ,100
                             ,vr_i_nro_lote
                             ,rw_consulta_lot.nrseqdig); -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           FETCH cr_existe_lcm INTO rw_existe_lcm;
              IF cr_existe_lcm%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento  ja existente';
                                      
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;              
           CLOSE cr_existe_lcm;
              
           OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                              ,rw_dat_cop.dtmvtolt
                              ,1
                              ,100
                              ,vr_i_nro_lote
                              ,pr_nro_conta
                              ,vr_c_docto);
           FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
              IF cr_existe_lcm1%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento(Primario) ja existente';
                                     
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
           
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
                   
              END IF;            
           CLOSE cr_existe_lcm1;
              
           -- Chegou aqui eh porque nao existir lcm, entao cria registro de lcm
           BEGIN
              INSERT INTO craplcm(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,dsidenti
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrdocmto
                                 ,vllanmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,nrdctabb
                                 ,nrautdoc
                                 ,cdpesqbb
                                 ,nrdctitg
                                 ,cdcoptfn
                                 ,cdagetfn
                                 ,nrterfin
                                 ,cdoperad)
              VALUES (rw_cod_coop_dest.cdcooper
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,pr_identifica
                     ,vr_i_nro_lote
                     ,pr_nro_conta
                     ,TO_NUMBER(vr_c_docto)
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1526  /* 3 DEP.CHQ.PR. */
                     ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                     ,pr_nro_conta
                     ,vr_p_ult_sequencia
                     ,'CRAP22'
                     ,vr_glb_dsdctitg
                     ,rw_cod_coop_orig.cdcooper
                     ,pr_cod_agencia
                     ,pr_nro_caixa
                     ,pr_cod_operador);
                     
                     -- Guarda o sequencial usado no lancamento
                     pr_typ_tab_chq(vr_index).nrseqlcm := rw_consulta_lot.nrseqdig; -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                                        
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;

           END;
           
           -- Verifica se existe lote
           OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtocd
                             ,1   /* FIXO */
                             ,100 /* FIXO */
                             ,vr_i_nro_lote);
           FETCH cr_existe_lot INTO rw_existe_lot;
              IF cr_existe_lot%FOUND THEN
                 BEGIN
                    UPDATE craplot lot
                       SET lot.nrseqdig = lot.nrseqdig + 1
                          ,lot.qtcompln = lot.qtcompln + 1
                          ,lot.qtinfoln = lot.qtinfoln + 1
                          ,lot.vlcompcr = lot.vlcompcr + pr_typ_tab_chq(vr_index).vlcompel
                          ,lot.vlinfocr = lot.vlinfocr + pr_typ_tab_chq(vr_index).vlcompel
                     WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                       AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                       AND lot.cdagenci = 1
                       AND lot.cdbccxlt = 100
                       AND lot.nrdolote = vr_i_nro_lote;             
                 EXCEPTION
                    WHEN OTHERS THEN
                       pr_cdcritic := 0;
                       pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                  
                       cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                            ,pr_cdagenci => pr_cod_agencia
                                            ,pr_nrdcaixa => pr_nro_caixa
                                            ,pr_cod_erro => pr_cdcritic
                                            ,pr_dsc_erro => pr_dscritic
                                            ,pr_flg_erro => TRUE
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic); 
                       -- Levantar excecao
                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          pr_cdcritic := vr_cdcritic;
                          pr_dscritic := vr_dscritic;
                          RAISE vr_exc_erro;
                       END IF;

                       RAISE vr_exc_erro;

                 END;

              END IF;

           CLOSE cr_existe_lot;
           
           -- Cria registro de Deposito Bloqueado
           BEGIN
              INSERT INTO crapdpb(nrdconta
                                 ,dtliblan
                                 ,cdhistor
                                 ,nrdocmto
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,vllanmto
                                 ,inlibera
                                 ,cdcooper)
              VALUES (pr_nro_conta
                     ,pr_typ_tab_chq(vr_index).dtlibcom
                     ,1526 -- 3
                     ,TO_NUMBER(vr_c_docto)
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,vr_i_nro_lote
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1
                     ,rw_cod_coop_dest.cdcooper);
           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPDPB: '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic;
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;

           END;
           
        END IF;        
        vr_index:= pr_typ_tab_chq.NEXT(vr_index); -- Proximo registro
        
     END LOOP; -- Fim cheques maior praca
     
     vr_nrsequen := 0;
     
     -- Cheque MENOR FORA PRACA
     vr_index := pr_typ_tab_chq.first(); -- Posiciona no primeiro registro
     WHILE vr_index IS NOT NULL LOOP
        IF pr_typ_tab_chq(vr_index).nrdocmto = 5 THEN
          
           /* Sequencial utilizado para separar um lançamento
           para cada data nao ocorrendo duplicidade de chave */


           vr_nrsequen := vr_nrsequen + 1;
           vr_c_docto  := vr_c_docto_salvo || to_char(gene0002.fn_mask(pr_dsorigi => vr_nrsequen, pr_dsforma => '99' )) || pr_typ_tab_chq(vr_index).nrdocmto;
           pr_typ_tab_chq(vr_index).nrsequen := vr_nrsequen;
           
           -- Busca o ultima sequencia de digito
           OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                               ,rw_dat_cop.dtmvtocd
                               ,1   -- FIXO
                               ,100 -- FIXO
                               ,vr_i_nro_lote);
           FETCH cr_consulta_lot INTO rw_consulta_lot;
           CLOSE cr_consulta_lot;
              
           -- Verifica se Lancamento ja Existe no Dest.
           OPEN cr_existe_lcm(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,1
                             ,100
                             ,vr_i_nro_lote
                             ,rw_consulta_lot.nrseqdig); -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           FETCH cr_existe_lcm INTO rw_existe_lcm;
              IF cr_existe_lcm%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento  ja existente';
                                      
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
                 
              END IF;              
           CLOSE cr_existe_lcm;
              
           OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                              ,rw_dat_cop.dtmvtolt
                              ,1
                              ,100
                              ,vr_i_nro_lote
                              ,pr_nro_conta
                              ,vr_c_docto);
           FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
              IF cr_existe_lcm1%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento(Primario) ja existente';
                                     
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;            
           CLOSE cr_existe_lcm1;
              
           -- Chegou aqui eh porque nao existir lcm, entao cria registro de lcm
           BEGIN
              INSERT INTO craplcm(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,dsidenti
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrdocmto
                                 ,vllanmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,nrdctabb
                                 ,nrautdoc
                                 ,cdpesqbb
                                 ,nrdctitg
                                 ,cdcoptfn
                                 ,cdagetfn
                                 ,nrterfin
                                 ,cdoperad)
              VALUES (rw_cod_coop_dest.cdcooper
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,pr_identifica
                     ,vr_i_nro_lote
                     ,pr_nro_conta
                     ,TO_NUMBER(vr_c_docto)
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1523  /** 4 - DEP.CHQ.FPR. **/
                     ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                     ,pr_nro_conta
                     ,vr_p_ult_sequencia
                     ,'CRAP22'
                     ,vr_glb_dsdctitg
                     ,rw_cod_coop_orig.cdcooper
                     ,pr_cod_agencia
                     ,pr_nro_caixa
                     ,pr_cod_operador);
                                          
                     -- Guarda o sequencial usado no lancamento
                     pr_typ_tab_chq(vr_index).nrseqlcm := rw_consulta_lot.nrseqdig; -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic;
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
           END;
           
           -- Verifica se existe lote
           OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtocd
                             ,1   /* FIXO */
                             ,100 /* FIXO */
                             ,vr_i_nro_lote);
           FETCH cr_existe_lot INTO rw_existe_lot;
              IF cr_existe_lot%FOUND THEN
                 BEGIN
                    UPDATE craplot lot
                       SET lot.nrseqdig = lot.nrseqdig + 1
                          ,lot.qtcompln = lot.qtcompln + 1
                          ,lot.qtinfoln = lot.qtinfoln + 1
                          ,lot.vlcompcr = lot.vlcompcr + pr_typ_tab_chq(vr_index).vlcompel
                          ,lot.vlinfocr = lot.vlinfocr + pr_typ_tab_chq(vr_index).vlcompel
                     WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                       AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                       AND lot.cdagenci = 1
                       AND lot.cdbccxlt = 100
                       AND lot.nrdolote = vr_i_nro_lote;             
                 EXCEPTION
                    WHEN OTHERS THEN
                       pr_cdcritic := 0;
                       pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                  
                       cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                            ,pr_cdagenci => pr_cod_agencia
                                            ,pr_nrdcaixa => pr_nro_caixa
                                            ,pr_cod_erro => pr_cdcritic
                                            ,pr_dsc_erro => pr_dscritic
                                            ,pr_flg_erro => TRUE
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic); 
                       -- Levantar excecao
                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          pr_cdcritic := vr_cdcritic;
                          pr_dscritic := vr_dscritic;
                          RAISE vr_exc_erro;
                       END IF;

                       RAISE vr_exc_erro;

                 END;
              END IF;
           CLOSE cr_existe_lot;
           
           -- Cria registro de Deposito Bloqueado
           BEGIN
              INSERT INTO crapdpb(nrdconta
                                 ,dtliblan
                                 ,cdhistor
                                 ,nrdocmto
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,vllanmto
                                 ,inlibera
                                 ,cdcooper)
              VALUES (pr_nro_conta
                     ,pr_typ_tab_chq(vr_index).dtlibcom
                     ,1523 -- 4
                     ,TO_NUMBER(vr_c_docto)
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,vr_i_nro_lote
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1
                     ,rw_cod_coop_dest.cdcooper);                                
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPDPB : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic;
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
           END;
           
        END IF;        
        vr_index:= pr_typ_tab_chq.NEXT(vr_index); -- Proximo registro
        
     END LOOP; -- Fim cheques menor fora praca
     
     vr_nrsequen := 0;
     
     -- Cheque MAIOR FORA PRACA
     vr_index := pr_typ_tab_chq.first(); -- Posiciona no primeiro registro
     WHILE vr_index IS NOT NULL LOOP
        IF pr_typ_tab_chq(vr_index).nrdocmto = 6 THEN

           /* Sequencial utilizado para separar um lançamento
           para cada data nao ocorrendo duplicidade de chave */

           vr_nrsequen := vr_nrsequen + 1;
           vr_c_docto  := vr_c_docto_salvo || to_char(gene0002.fn_mask(pr_dsorigi => vr_nrsequen, pr_dsforma => '99' )) || pr_typ_tab_chq(vr_index).nrdocmto;
           pr_typ_tab_chq(vr_index).nrsequen := vr_nrsequen;

           -- Busca o ultima sequencia de digito
           OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                               ,rw_dat_cop.dtmvtocd
                               ,1   -- FIXO
                               ,100 -- FIXO
                               ,vr_i_nro_lote);
           FETCH cr_consulta_lot INTO rw_consulta_lot;
           CLOSE cr_consulta_lot;

           -- Verifica se Lancamento ja Existe no Dest.
           OPEN cr_existe_lcm(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,1
                             ,100
                             ,vr_i_nro_lote
                             ,rw_consulta_lot.nrseqdig); -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           FETCH cr_existe_lcm INTO rw_existe_lcm;
              IF cr_existe_lcm%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento  ja existente';

                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;              
           CLOSE cr_existe_lcm;

           OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                              ,rw_dat_cop.dtmvtolt
                              ,1
                              ,100
                              ,vr_i_nro_lote
                              ,pr_nro_conta
                              ,vr_c_docto);
           FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
              IF cr_existe_lcm1%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento(Primario) ja existente';
                                     
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;            
           CLOSE cr_existe_lcm1;
              
           -- Chegou aqui eh porque nao existir lcm, entao cria registro de lcm
           BEGIN
              INSERT INTO craplcm(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,dsidenti
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrdocmto
                                 ,vllanmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,nrdctabb
                                 ,nrautdoc
                                 ,cdpesqbb
                                 ,nrdctitg
                                 ,cdcoptfn
                                 ,cdagetfn
                                 ,nrterfin
                                 ,cdoperad)
              VALUES (rw_cod_coop_dest.cdcooper
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,pr_identifica
                     ,vr_i_nro_lote
                     ,pr_nro_conta
                     ,TO_NUMBER(vr_c_docto)
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1523  /** 4 - DEP.CHQ.FPR. **/
                     ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                     ,pr_nro_conta
                     ,vr_p_ult_sequencia
                     ,'CRAP22'
                     ,vr_glb_dsdctitg
                     ,rw_cod_coop_orig.cdcooper
                     ,pr_cod_agencia
                     ,pr_nro_caixa
                     ,pr_cod_operador);

                     -- Guarda o sequencial usado no lancamento
                     pr_typ_tab_chq(vr_index).nrseqlcm := rw_consulta_lot.nrseqdig; -- Já está encrementado + 1 no CURSOR cr_consulta_lot

           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;

                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic;
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;

           END;

           -- Verifica se existe lote
           OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtocd
                             ,1   /* FIXO */
                             ,100 /* FIXO */
                             ,vr_i_nro_lote);
           FETCH cr_existe_lot INTO rw_existe_lot;
              IF cr_existe_lot%FOUND THEN
                 BEGIN
                    UPDATE craplot lot
                       SET lot.nrseqdig = lot.nrseqdig + 1
                          ,lot.qtcompln = lot.qtcompln + 1
                          ,lot.qtinfoln = lot.qtinfoln + 1
                          ,lot.vlcompcr = lot.vlcompcr + pr_typ_tab_chq(vr_index).vlcompel
                          ,lot.vlinfocr = lot.vlinfocr + pr_typ_tab_chq(vr_index).vlcompel
                     WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                       AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                       AND lot.cdagenci = 1
                       AND lot.cdbccxlt = 100
                       AND lot.nrdolote = vr_i_nro_lote;             
                 EXCEPTION
                    WHEN OTHERS THEN
                       pr_cdcritic := 0;
                       pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                  
                       cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                            ,pr_cdagenci => pr_cod_agencia
                                            ,pr_nrdcaixa => pr_nro_caixa
                                            ,pr_cod_erro => pr_cdcritic
                                            ,pr_dsc_erro => pr_dscritic
                                            ,pr_flg_erro => TRUE
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic); 
                       -- Levantar excecao
                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          pr_cdcritic := vr_cdcritic;
                          pr_dscritic := vr_dscritic;
                          RAISE vr_exc_erro;
                       END IF;

                       RAISE vr_exc_erro;
                 END;                 
              END IF;
              
           CLOSE cr_existe_lot;
           
           -- Cria registro de Deposito Bloqueado
           BEGIN
              INSERT INTO crapdpb(nrdconta
                                 ,dtliblan
                                 ,cdhistor
                                 ,nrdocmto
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,vllanmto
                                 ,inlibera
                                 ,cdcooper)
              VALUES (pr_nro_conta
                     ,pr_typ_tab_chq(vr_index).dtlibcom
                     ,1523 -- 4
                     ,TO_NUMBER(vr_c_docto)
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,vr_i_nro_lote
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1
                     ,rw_cod_coop_dest.cdcooper);           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao atualizar na CRAPDPB : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic;
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
           END;
           
        END IF;        
        vr_index:= pr_typ_tab_chq.NEXT(vr_index); -- Proximo registro
        
     END LOOP; -- Fim cheques maior fora praca
     
     -- Criacao do LOTE de ORIGEM (DEBITO)
     vr_i_nro_lote    := 11000 + pr_nro_caixa;
     
     -- Verifica se existe lote
     OPEN cr_existe_lot(rw_cod_coop_orig.cdcooper
                       ,rw_dat_cop.dtmvtolt
                       ,pr_cod_agencia   /* FIXO */
                       ,11 /* FIXO */
                       ,vr_i_nro_lote);
     FETCH cr_existe_lot INTO rw_existe_lot;
        IF cr_existe_lot%NOTFOUND THEN
           -- Se nao existir cria a capa de lote
           BEGIN
              INSERT INTO craplot(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,tplotmov
                                 ,nrdcaixa
                                 ,cdopecxa
                                 ,cdhistor
                                 ,cdoperad)
              VALUES (rw_cod_coop_orig.cdcooper
                     ,rw_dat_cop.dtmvtolt
                     ,pr_cod_agencia
                     ,11
                     ,vr_i_nro_lote
                     ,1
                     ,pr_nro_caixa
                     ,pr_cod_operador
                     ,0
                     ,pr_cod_operador);
           EXCEPTION
              WHEN OTHERS THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Erro ao inserir na CRAPLOT: '||sqlerrm;
                                  
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
           END;
        END IF;
     CLOSE cr_existe_lot;
          
     /*** Criacao da CHD - Cheques Acolhidos  ***/
     FOR rw_verifica_mdw IN cr_verifica_mdw(rw_cod_coop_orig.cdcooper
                                           ,pr_cod_agencia
                                           ,pr_nro_caixa) LOOP
                                           
         -- Busca o ultima sequencia de digito
         OPEN cr_consulta_lot(rw_cod_coop_orig.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,pr_cod_agencia   /* FIXO */
                             ,11 /* FIXO */
                             ,vr_i_nro_lote);
         FETCH cr_consulta_lot INTO rw_consulta_lot;
         CLOSE cr_consulta_lot;
                                           
         -- Formata conta integracao
         GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => rw_verifica_mdw.nrctabdb
                                       ,pr_dscalcul => vr_dsdctitg
                                       ,pr_stsnrcal => vr_stsnrcal
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
                                       
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
            RAISE vr_exc_erro;
         END IF;
                                       
         OPEN cr_consulta_chd(rw_cod_coop_orig.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,rw_verifica_mdw.cdcmpchq
                             ,rw_verifica_mdw.cdbanchq
                             ,rw_verifica_mdw.cdagechq
                             ,rw_verifica_mdw.nrctachq
                             ,rw_verifica_mdw.nrcheque);
         FETCH cr_consulta_chd INTO rw_consulta_chd;
            IF cr_consulta_chd%FOUND THEN
              
               pr_cdcritic := 92;
               pr_dscritic := '';

               cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                    ,pr_cdagenci => pr_cod_agencia
                                    ,pr_nrdcaixa => pr_nro_caixa
                                    ,pr_cod_erro => pr_cdcritic
                                    ,pr_dsc_erro => pr_dscritic
                                    ,pr_flg_erro => TRUE
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
               
               -- Levantar excecao
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  pr_cdcritic := vr_cdcritic;
                  pr_dscritic := vr_dscritic;
                  RAISE vr_exc_erro;
               END IF;

               RAISE vr_exc_erro;
                                    
            ELSE -- Nao encontrou registro CHD. Entao cria registro
                                    
               IF rw_verifica_mdw.cdhistor = 386 THEN -- DEP.CHQ.COOP.
                  vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo ||'02'||'2');
               END IF;
               
               -- Encontrou registro
               IF pr_typ_tab_chq.exists(TO_CHAR(rw_verifica_mdw.dtlibcom,'DD/MM/RRRR')||
                                        TO_CHAR(LPAD(rw_verifica_mdw.nrdocmto,10,0))) THEN
                  -- Montar chave de busca
                  vr_index :=  TO_CHAR(rw_verifica_mdw.dtlibcom,'DD/MM/RRRR')||
                               TO_CHAR(LPAD(rw_verifica_mdw.nrdocmto,10,0));

                  IF rw_verifica_mdw.cdhistor = 3 THEN -- PRACA MENOR
                     IF rw_verifica_mdw.tpdmovto = 2 THEN
                        vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo||to_char(gene0002.fn_mask(pr_dsorigi => pr_typ_tab_chq(vr_index).nrsequen, pr_dsforma => '99' ))||'3');
                     ELSE
                        vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo||to_char(gene0002.fn_mask(pr_dsorigi => pr_typ_tab_chq(vr_index).nrsequen, pr_dsforma => '99' ))||'4');
                     END IF;
                  ELSE
                     IF rw_verifica_mdw.cdhistor = 4 THEN -- FORA PRACA MENOR
                        IF rw_verifica_mdw.tpdmovto = 2 THEN
                           vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo||to_char(gene0002.fn_mask(pr_dsorigi => pr_typ_tab_chq(vr_index).nrsequen, pr_dsforma => '99' ))||'5');
                        ELSE
                           vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo||to_char(gene0002.fn_mask(pr_dsorigi => pr_typ_tab_chq(vr_index).nrsequen, pr_dsforma => '99' ))||'6');
                        END IF;
                     END IF;
                  END IF;
                  
                  IF rw_verifica_mdw.cdhistor <> 386 THEN
                     vr_aux_nrseqdig := pr_typ_tab_chq(vr_index).nrseqlcm;
                  END IF;
                  
               END IF;
               
               IF NVL(rw_verifica_mdw.nrctaaux,0) > 0 THEN 
                  vr_aux_inchqcop := 1;
               ELSE
                  vr_aux_inchqcop := 0;
               END IF;
               
               IF vr_aux_inchqcop = 1 THEN 
                  /* cheque da cooperativa: quando for conta incorporada 
                     e cheque talao antigo, devera atribuir a conta cheque antiga */ 
                  vr_aux_nrctachq := rw_verifica_mdw.nrctabdb;
               ELSE
                  vr_aux_nrctachq := rw_verifica_mdw.nrctachq;
               END IF;
               
               IF NVL(rw_verifica_mdw.cdhistor,0) = 386 THEN
                  vr_aux_nrseqdig := vr_i_seq_386;
               ELSE
                 
                  /** Incrementa contagem de cheques para a previa **/
                  CXON0000.pc_atualiza_previa_cxa(pr_cooper       => pr_cooper
                                                 ,pr_cod_agencia  => pr_cod_agencia
                                                 ,pr_nro_caixa    => pr_nro_caixa
                                                 ,pr_cod_operador => pr_cod_operador
                                                 ,pr_dtmvtolt     => rw_dat_cop.dtmvtolt
                                                 ,pr_operacao     => 1 -- Inclusao
                                                 ,pr_retorno      => pr_retorno
                                                 ,pr_cdcritic     => vr_cdcritic
                                                 ,pr_dscritic     => vr_dscritic);
                                        
                  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                     pr_cdcritic := vr_cdcritic;
                     pr_dscritic := vr_dscritic;
                         
                     cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                          ,pr_cdagenci => pr_cod_agencia
                                          ,pr_nrdcaixa => pr_nro_caixa
                                          ,pr_cod_erro => pr_cdcritic
                                          ,pr_dsc_erro => pr_dscritic
                                          ,pr_flg_erro => TRUE
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
                                                
                      -- Levantar excecao
                      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                         pr_cdcritic := vr_cdcritic;
                         pr_dscritic := vr_dscritic;
                         RAISE vr_exc_erro;
                      END IF;

                      RAISE vr_exc_erro;                          
                  END IF;                            
               END IF;
               
               vr_aux_nrddigv1 := TO_NUMBER(TO_CHAR(gene0002.fn_busca_entrada(1,rw_verifica_mdw.lsdigctr,',')));
               vr_aux_nrddigv2 := TO_NUMBER(TO_CHAR(gene0002.fn_busca_entrada(2,rw_verifica_mdw.lsdigctr,',')));
               vr_aux_nrddigv3 := TO_NUMBER(TO_CHAR(gene0002.fn_busca_entrada(3,rw_verifica_mdw.lsdigctr,',')));
                              
               /** Criacao CHD na Acolhedora **/
               BEGIN
                  INSERT INTO crapchd(cdcooper
                                     ,cdagechq
                                     ,cdbanchq
                                     ,cdagenci
                                     ,cdbccxlt
                                     ,nrdocmto
                                     ,cdcmpchq
                                     ,cdoperad
                                     ,cdsitatu
                                     ,dsdocmc7
                                     ,dtmvtolt
                                     ,inchqcop
                                     ,insitchq
                                     ,cdtipchq
                                     ,nrcheque
                                     ,nrctachq
                                     ,nrdconta
                                     ,nrddigc1
                                     ,nrddigc2
                                     ,nrddigc3
                                     ,nrddigv1
                                     ,nrddigv2
                                     ,nrddigv3
                                     ,nrdolote
                                     ,tpdmovto
                                     ,nrterfin
                                     ,vlcheque
                                     ,cdagedst
                                     ,nrctadst
                                     ,nrseqdig)
                  VALUES (rw_cod_coop_orig.cdcooper
                         ,rw_verifica_mdw.cdagechq
                         ,rw_verifica_mdw.cdbanchq
                         ,pr_cod_agencia
                         ,11
                         ,TO_NUMBER(vr_i_nro_docto)
                         ,rw_verifica_mdw.cdcmpchq
                         ,pr_cod_operador
                         ,1
                         ,rw_verifica_mdw.dsdocmc7
                         ,rw_dat_cop.dtmvtolt
                         ,vr_aux_inchqcop
                         ,0
                         ,rw_verifica_mdw.cdtipchq
                         ,rw_verifica_mdw.nrcheque
                         ,vr_aux_nrctachq
                         ,vr_nro_conta
                         ,rw_verifica_mdw.nrddigc1
                         ,rw_verifica_mdw.nrddigc2
                         ,rw_verifica_mdw.nrddigc3
                         ,vr_aux_nrddigv1
                         ,vr_aux_nrddigv2
                         ,vr_aux_nrddigv3
                         ,vr_i_nro_lote
                         ,rw_verifica_mdw.tpdmovto
                         ,0
                         ,rw_verifica_mdw.vlcompel
                         ,rw_cod_coop_dest.cdagectl /* Dep.Intercoop. */
                         ,pr_nro_conta /* Dep.Intercoop. */
                         ,vr_aux_nrseqdig)
                  RETURNING ROWID
                       INTO vr_rowid_chd;
               EXCEPTION
                  WHEN OTHERS THEN
                       pr_cdcritic := 0;
                       pr_dscritic := 'Erro ao inserir na CRAPCHQ: '||sqlerrm;
                                      
                       cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                            ,pr_cdagenci => pr_cod_agencia
                                            ,pr_nrdcaixa => pr_nro_caixa
                                            ,pr_cod_erro => pr_cdcritic
                                            ,pr_dsc_erro => pr_dscritic
                                            ,pr_flg_erro => TRUE
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
                       -- Levantar excecao
                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          pr_cdcritic := vr_cdcritic;
                          pr_dscritic := vr_dscritic;
                          RAISE vr_exc_erro;
                       END IF;

                       RAISE vr_exc_erro;
               END;
               
            END IF;
         CLOSE cr_consulta_chd;
         
         /** Cheques Nao Coop - Vai p/ Proximo MDW **/
         IF NVL(rw_verifica_mdw.cdhistor,0) <> 386 THEN
            NULL;
         ELSE
            
            /* Efetua Lancamentos de DEBITO nos CHEQUES COOP */
            /* guarda infos da ultima autenticacao 700 */            

            vr_aux_p_literal  := vr_p_literal;
            vr_aux_p_ult_seq  := vr_p_ult_sequencia;
            vr_aux_p_registro := vr_p_registro;
            
            CXON0051.pc_autentica_cheque(pr_cooper          => pr_cooper
                                        ,pr_cod_agencia     => pr_cod_agencia
                                        ,pr_nro_conta       => pr_nro_conta
                                        ,pr_vestorno        => pr_vestorno
                                        ,pr_nro_caixa       => pr_nro_caixa
                                        ,pr_cod_operador    => pr_cod_operador
                                        ,pr_dtmvtolt        => rw_dat_cop.dtmvtolt
                                        ,pr_nro_docmto      => pr_nro_docmto
                                        ,pr_rowid           => rw_verifica_mdw.rowid
                                        ,pr_p_literal       => vr_p_literal
                                        ,pr_p_ult_sequencia => vr_p_ult_sequencia
                                        ,pr_retorno         => pr_retorno       
                                        ,pr_cdcritic        => vr_cdcritic
                                        ,pr_dscritic        => vr_dscritic);
                                        
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := vr_dscritic;
               RAISE vr_exc_erro;
            END IF;
            
            -- volta infos da ultima autenticacao 700
            vr_p_literal         := vr_aux_p_literal;
            vr_p_ult_sequencia   := vr_aux_p_ult_seq;
            vr_p_registro        := vr_aux_p_registro;
            
            -- Busca o nro da autenticacao
            OPEN cr_nrautdoc_mdw(rw_verifica_mdw.rowid);
            FETCH cr_nrautdoc_mdw INTO rw_nrautdoc_mdw;
            CLOSE cr_nrautdoc_mdw;
            
            -- Formata conta integracao
            GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => vr_nro_conta
                                          ,pr_dscalcul => vr_dsdctitg
                                          ,pr_stsnrcal => vr_stsnrcal
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
            -- Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := vr_dscritic;
               
               cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                    ,pr_cdagenci => pr_cod_agencia
                                    ,pr_nrdcaixa => pr_nro_caixa
                                    ,pr_cod_erro => pr_cdcritic
                                    ,pr_dsc_erro => pr_dscritic
                                    ,pr_flg_erro => TRUE
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
               
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  pr_cdcritic := vr_cdcritic;
                  pr_dscritic := vr_dscritic;
                  RAISE vr_exc_erro;
               END IF;
               
               RAISE vr_exc_erro;
            END IF;
            
            OPEN cr_rowid_chd(vr_rowid_chd);
            FETCH cr_rowid_chd INTO rw_rowid_chd;
            CLOSE cr_rowid_chd;
            
            OPEN cr_verifica_fdc(rw_rowid_chd.cdcooper
                                ,rw_rowid_chd.cdbanchq
                                ,rw_rowid_chd.cdagechq
                                ,rw_rowid_chd.nrctachq
                                ,rw_rowid_chd.nrcheque);
            FETCH cr_verifica_fdc INTO rw_verifica_fdc;
               IF cr_verifica_fdc%FOUND THEN
                  BEGIN
                    
                    /* Atualiza os campos de acordo com o tipo
                    da conta do associado que recebe o cheque */
                    
                    IF rw_verifica_ass.cdtipcta >= 8  AND
                       rw_verifica_ass.cdtipcta <= 11 THEN                       
                       
                       IF rw_verifica_ass.cdbcochq = 756 THEN -- BANCOOB
                          vr_aux_cdbandep := 756;
                          vr_aux_cdagedep := rw_cod_coop_dest.cdagebcb;
                       ELSE
                          vr_aux_cdbandep := rw_cod_coop_dest.cdbcoctl;
                          vr_aux_cdagedep := rw_cod_coop_dest.cdagectl;
                       END IF;
                    ELSE
                       -- BANCO DO BRASIL - SEM DIGITO
                       vr_aux_cdbandep := 1;
                       vr_aux_cdagedep := SUBSTR(rw_cod_coop_dest.cdagedbb,LENGTH(rw_cod_coop_dest.cdagedbb)-1);
                    END IF;                      
                  
                    UPDATE crapfdc fdc
                       SET fdc.incheque = fdc.incheque + 5
                          ,fdc.dtliqchq = rw_dat_cop.dtmvtolt
                          ,fdc.cdoperad = pr_cod_operador
                          ,fdc.vlcheque = rw_verifica_mdw.vlcompel
                          ,fdc.nrctadep = rw_verifica_ass.nrdconta
                          ,fdc.cdbandep = vr_aux_cdbandep
                          ,fdc.cdagedep = vr_aux_cdagedep
                     WHERE fdc.cdcooper = rw_rowid_chd.cdcooper
                       AND fdc.cdbanchq = rw_rowid_chd.cdbanchq
                       AND fdc.cdagechq = rw_rowid_chd.cdagechq
                       AND fdc.nrctachq = rw_rowid_chd.nrctachq
                       AND fdc.nrcheque = rw_rowid_chd.nrcheque;             
                  EXCEPTION
                     WHEN OTHERS THEN
                        pr_cdcritic := 0;
                        pr_dscritic := 'Erro ao atualizar CRAPFDC : '||sqlerrm;
                                         
                        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                             ,pr_cdagenci => pr_cod_agencia
                                             ,pr_nrdcaixa => pr_nro_caixa
                                             ,pr_cod_erro => pr_cdcritic
                                             ,pr_dsc_erro => pr_dscritic
                                             ,pr_flg_erro => TRUE
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic); 
                        -- Levantar excecao
                        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                           pr_cdcritic := vr_cdcritic;
                           pr_dscritic := vr_dscritic;
                           RAISE vr_exc_erro;
                        END IF;
                        RAISE vr_exc_erro;
                        
                  END;
                  
               ELSE -- Nao encontrou regsitro fdc
                   pr_cdcritic := 108;
                   pr_dscritic := '';
                                         
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic); 
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic;
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
               END IF;
            CLOSE cr_verifica_fdc;
            
            /* Pagamento Cheque */
            BEGIN
               
               IF  rw_verifica_fdc.tpcheque = 1  THEN
                   vr_aux_cdhistor := 21;
               ELSE
                   vr_aux_cdhistor := 26;
               END IF;

               INSERT INTO craplcm(cdcooper
                                  ,dtmvtolt
                                  ,cdagenci
                                  ,cdbccxlt
                                  ,dsidenti
                                  ,nrdolote
                                  ,nrdconta
                                  ,nrdocmto
                                  ,vllanmto
                                  ,cdhistor
                                  ,nrseqdig
                                  ,nrdctabb
                                  ,nrautdoc
                                  ,cdpesqbb
                                  ,nrdctitg)
               VALUES (rw_cod_coop_orig.cdcooper
                      ,rw_dat_cop.dtmvtolt
                      ,pr_cod_agencia
                      ,11
                      ,pr_identifica
                      ,vr_i_nro_lote
                      ,rw_verifica_mdw.nrctaaux
                      ,TO_NUMBER(rw_verifica_mdw.nrcheque||rw_verifica_mdw.nrddigc3)
                      ,rw_verifica_mdw.vlcompel
                      ,vr_aux_cdhistor
                      ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                      ,rw_verifica_mdw.nrctabdb
                      ,rw_nrautdoc_mdw.nrautdoc
                      ,TO_CHAR('CRAP22,'||rw_verifica_mdw.cdopelib)
                      ,vr_dsdctitg);
            EXCEPTION
               WHEN OTHERS THEN
                    pr_cdcritic := 0;
                    pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
 
                    cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                         ,pr_cdagenci => pr_cod_agencia
                                         ,pr_nrdcaixa => pr_nro_caixa
                                         ,pr_cod_erro => pr_cdcritic
                                         ,pr_dsc_erro => pr_dscritic
                                         ,pr_flg_erro => TRUE
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                    -- Levantar excecao
                    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                       pr_cdcritic := vr_cdcritic;
                       pr_dscritic := vr_dscritic;
                       RAISE vr_exc_erro;
                    END IF;

                    RAISE vr_exc_erro;
            END;

            -- Verifica se existe lote
            OPEN cr_existe_lot(rw_cod_coop_orig.cdcooper
                              ,rw_dat_cop.dtmvtolt
                              ,pr_cod_agencia /* FIXO */
                              ,11 /* FIXO */
                              ,vr_i_nro_lote);
            FETCH cr_existe_lot INTO rw_existe_lot;
               IF cr_existe_lot%FOUND THEN
                  BEGIN
                     UPDATE craplot lot
                        SET lot.nrseqdig = lot.nrseqdig + 1
                           ,lot.qtcompln = lot.qtcompln + 1
                           ,lot.qtinfoln = lot.qtinfoln + 1
                           ,lot.vlcompdb = lot.vlcompdb + rw_verifica_mdw.vlcompel
                           ,lot.vlinfodb = lot.vlinfodb + rw_verifica_mdw.vlcompel
                      WHERE lot.cdcooper = rw_cod_coop_orig.cdcooper
                        AND lot.dtmvtolt = rw_dat_cop.dtmvtolt
                        AND lot.cdagenci = pr_cod_agencia
                        AND lot.cdbccxlt = 11
                        AND lot.nrdolote = vr_i_nro_lote;             
                  EXCEPTION
                     WHEN OTHERS THEN
                        pr_cdcritic := 0;
                        pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                   
                        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                             ,pr_cdagenci => pr_cod_agencia
                                             ,pr_nrdcaixa => pr_nro_caixa
                                             ,pr_cod_erro => pr_cdcritic
                                             ,pr_dsc_erro => pr_dscritic
                                             ,pr_flg_erro => TRUE
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic); 
                        -- Levantar excecao
                        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                           pr_cdcritic := vr_cdcritic;
                           pr_dscritic := vr_dscritic;
                           RAISE vr_exc_erro;
                        END IF;

                        RAISE vr_exc_erro;
                  END;               
               END IF;
            CLOSE cr_existe_lot;

         END IF;

     END LOOP; -- Fim do FOR CRAPMDW
     
     IF vr_de_valor_total = 0 THEN
        pr_cdcritic := 296;
        pr_dscritic := '';

        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => pr_nro_caixa
                             ,pr_cod_erro => pr_cdcritic
                             ,pr_dsc_erro => pr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                             
        -- Levantar excecao
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := vr_dscritic;
           RAISE vr_exc_erro;
        END IF;
        RAISE vr_exc_erro;
     END IF;
     
     pr_literal_autentica := '';
     
     /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/

     /** Cooperativa Remetente **/
     
     --Populando vetor
     vr_tab_literal.DELETE;
     vr_tab_literal(1):= TRIM(rw_cod_coop_orig.nmrescop) ||' - '||TRIM(rw_cod_coop_orig.nmextcop);
     vr_tab_literal(2):= ' ';
     vr_tab_literal(3):= TO_CHAR(rw_dat_cop.dtmvtolt,'DD/MM/RR')  ||' '||
                         TO_CHAR(SYSDATE,'HH24:MI:SS') || ' PA  ' ||
                         TRIM(TO_CHAR(gene0002.fn_mask(pr_cod_agencia,'999'))) || '  CAIXA: '  ||
                         TO_CHAR(gene0002.fn_mask(pr_nro_caixa,'Z99')) || '/' ||
                         SUBSTR(pr_cod_operador,1,10);
     vr_tab_literal(4):= ' ';
     vr_tab_literal(5):= '      ** COMPROVANTE DE DEPOSITO '||TRIM(TO_CHAR(SUBSTR(vr_i_nro_docto,1,5),'999G999'))|| ' **';
     vr_tab_literal(6):= ' ';
     vr_tab_literal(7):= 'AGENCIA: '||TRIM(TO_CHAR(rw_cod_coop_dest.cdagectl,'9999')) || ' - ' ||TRIM(rw_cod_coop_dest.nmrescop);
     vr_tab_literal(8):= 'CONTA: '||TRIM(TO_CHAR(pr_nro_conta,'9999G999G9')) ||
                         '   PA: ' || TRIM(TO_CHAR(rw_verifica_ass.cdagenci));
     vr_tab_literal(9):=  '       ' || TRIM(rw_verifica_ass.nmprimtl); -- NOME TITULAR 1
     vr_tab_literal(10):= '       ' || TRIM(vr_nmsegntl); -- NOME TITULAR 2
     vr_tab_literal(11):= ' ';
     
     IF NVL(pr_identifica,' ') <> ' ' THEN
        vr_tab_literal(12):= 'DEPOSITO POR ';
        vr_tab_literal(13):= TRIM(pr_identifica);
        vr_tab_literal(14):= ' ';
     ELSE
        vr_tab_literal(12):= ' ';
        vr_tab_literal(13):= ' ';
        vr_tab_literal(14):= ' ';   
     END IF;
     
     vr_tab_literal(15):= '   TIPO DE DEPOSITO     VALOR EM R$ LIBERACAO EM';
     vr_tab_literal(16):= '------------------------------------------------';

     IF vr_de_cooperativa  > 0 THEN
        vr_tab_literal(17):= 'CHEQ.COOPERATIVA...: ' ||
                             TO_CHAR(vr_de_cooperativa,'999G999G999D99');     
     END IF;

     vr_tab_literal(22):= ' ';
     vr_tab_literal(23):= 'TOTAL DEPOSITADO...: '||
                          TO_CHAR(vr_de_valor_total,'999G999G999D99');
     vr_tab_literal(24):= ' ';
     vr_tab_literal(25):= vr_p_literal;
     vr_tab_literal(26):= ' ';
     vr_tab_literal(27):= ' ';
     vr_tab_literal(28):= ' ';
     vr_tab_literal(29):= ' ';
     vr_tab_literal(30):= ' ';
     vr_tab_literal(31):= ' ';
     vr_tab_literal(32):= ' ';
     vr_tab_literal(33):= ' ';
     vr_tab_literal(34):= ' ';
     vr_tab_literal(35):= ' ';

     -- Inicializa Variavel
     pr_literal_autentica := NULL;

     pr_literal_autentica:= RPAD(NVL(vr_tab_literal(1),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(2),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(3),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(4),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(5),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(6),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(7),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(8),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(9),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(10),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(11),'  '),48,' ');

     IF NVL(vr_tab_literal(13),' ') <> ' ' THEN
        pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(12),'  '),48,' ');
        pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(13),'  '),48,' ');
        pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(14),'  '),48,' ');
     END IF;

     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(15),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(16),'  '),48,' ');

     IF vr_de_cooperativa  > 0 THEN
        pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(17),'  '),48,' ');
     END IF;

     vr_index := pr_typ_tab_chq.first(); -- Posiciona no primeiro registro
     WHILE vr_index IS NOT NULL LOOP
       
        IF pr_typ_tab_chq(vr_index).nrdocmto = 3 THEN
           pr_literal_autentica := pr_literal_autentica || RPAD('CHEQ.PRACA MENOR...: '||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).vlcompel,'999G999G999D99') ||
                                                           '   ' ||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).dtlibcom,'DD/MM/RR')
                                                           ,48,' ');
        END IF;
        IF pr_typ_tab_chq(vr_index).nrdocmto = 4 THEN
           pr_literal_autentica := pr_literal_autentica || RPAD('CHEQ.PRACA MAIOR...: '||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).vlcompel,'999G999G999D99') ||
                                                           '   ' ||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).dtlibcom,'DD/MM/RR')
                                                           ,48,' ');
        END IF;
        IF pr_typ_tab_chq(vr_index).nrdocmto = 5 THEN
           pr_literal_autentica := pr_literal_autentica || RPAD('CHEQ.F.PRACA MENOR.: '||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).vlcompel,'999G999G999D99') ||
                                                           '   ' ||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).dtlibcom,'DD/MM/RR')
                                                           ,48,' ');
        END IF;
        IF pr_typ_tab_chq(vr_index).nrdocmto = 6 THEN
           pr_literal_autentica := pr_literal_autentica || RPAD('CHEQ.F.PRACA MAIOR.: '||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).vlcompel,'999G999G999D99') ||
                                                           '   ' ||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).dtlibcom,'DD/MM/RR')
                                                           ,48,' ');
        END IF;       
        vr_index:= pr_typ_tab_chq.NEXT(vr_index); -- Proximo registro
        
     END LOOP; -- Fim cheques maior fora praca

     /* Obs: Existe um limitacao do PROGRESS que não suporta a quantidada maxima de uma
     variavel VARCHAR2(32627), a solucao foi definir um tamanho para o parametro no 
     Dicionario de Dados para resolver o estouro da variavel VARCHAR2 */
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(22),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(23),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(24),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(25),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(26),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(27),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(28),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(29),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(30),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(31),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(32),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(33),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(34),'  '),48,' ');
     /* O dataserver elimina os espaçoes em branco a esquerda de uma string, a solução
     encontrada foi colocar um caracter curinga para ser substituido por um espaço em
     branco no lado do progress. Dessa forma não é desconsiderado os espaços em branco. */
     pr_literal_autentica:= pr_literal_autentica||LPAD(NVL('#','  '),48,' ');
     
     pr_ult_seq_autentica := vr_p_ult_sequencia;

     /* Autenticacao REC */
     BEGIN
        UPDATE crapaut
           SET crapaut.dslitera = pr_literal_autentica
         WHERE crapaut.ROWID = vr_p_registro;
       
        --Se nao atualizou registro
        IF SQL%ROWCOUNT = 0 THEN
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro Sistema - CRAPAUT nao Encontrado';
           RAISE vr_exc_erro;
        END IF;

     EXCEPTION
        WHEN Others THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro ao atualizar tabela crapaut.'||sqlerrm;
         RAISE vr_exc_erro;
     END;
     
     pr_retorno  := 'OK';
     COMMIT;
   
  EXCEPTION
     WHEN vr_exc_erro THEN
        ROLLBACK; -- Desfaz as operacoes
        pr_retorno           := 'NOK';
        pr_literal_autentica := NULL;
        pr_ult_seq_autentica := NULL;
        pr_nro_docmto        := NULL;
        
        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => pr_nro_caixa
                             ,pr_cod_erro => pr_cdcritic
                             ,pr_dsc_erro => pr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                             
                -- Levantar excecao
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;            
         END IF;

     WHEN OTHERS THEN
         ROLLBACK;
         pr_retorno           := 'NOK';
         pr_literal_autentica := NULL;
         pr_ult_seq_autentica := NULL;
         pr_nro_docmto        := NULL;
         pr_cdcritic          := 0;
         pr_dscritic          := 'Erro na rotina CXON0022.pc_realiza_dep_cheq. '||SQLERRM;
         
         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => pr_nro_caixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
                              
         -- Levantar excecao
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;            
         END IF;  

  END pc_realiza_dep_cheq;
  
  PROCEDURE pc_realiz_dep_cheque_mig (pr_cooper            IN VARCHAR2      --> Codigo Cooperativa
                                     ,pr_cooper_migrada    IN VARCHAR2      --> Codigo Cooperativa Migrada
                                     ,pr_cod_agencia       IN INTEGER       --> Codigo Agencia
                                     ,pr_nro_caixa         IN INTEGER       --> Codigo do Caixa
                                     ,pr_cod_operador      IN VARCHAR2      --> Codigo Operador
                                     ,pr_cooper_dest       IN VARCHAR2      --> Cooperativa de Destino
                                     ,pr_nro_conta         IN INTEGER       --> Nro da Conta
                                     ,pr_nro_conta_de      IN INTEGER       --> Nro da Conta origem
                                     ,pr_valor             IN NUMBER        --> Valor
                                     ,pr_identifica        IN VARCHAR2      --> Identificador de Deposito
                                     ,pr_vestorno          IN INTEGER       --> Flag Estorno. False
                                     ,pr_nro_docmto        OUT NUMBER       --> Nro Documento
                                     ,pr_literal_autentica OUT VARCHAR2     --> Literal Autenticacao
                                     ,pr_ult_seq_autentica OUT INTEGER      --> Ultima Seq de Autenticacao
                                     ,pr_retorno           OUT VARCHAR2     --> Retorna OK ou NOK
                                     ,pr_cdcritic          OUT INTEGER      --> Cod Critica
                                     ,pr_dscritic          OUT VARCHAR2) IS --> Des Critica
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_realiza_dep_cheque_migrado Fonte: dbo/b1crap22.p/realiza-deposito-cheque-migrado
  --  Sistema  : Procedure para realizar deposito de cheques entre cooperativas
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Junho/2014.                   Ultima atualizacao: 26/04/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : 

  -- Alteracoes: 26/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                  crapass, crapttl, crapjur 
							 (Adriano - P339).
  ---------------------------------------------------------------------------------------------------------------*/
  
  --Tipo de tabela para vetor literal
  TYPE typ_tab_literal IS table of VARCHAR2(100) index by PLS_INTEGER;
  --Vetor de memoria do literal
  vr_tab_literal typ_tab_literal;
  
  /* Busca o codigo da Coop. passando como parametro o nome resumido da Coop. */
  CURSOR cr_cod_coop_dest(p_nmrescop IN VARCHAR2) IS
    SELECT cop.cdcooper
          ,cop.cdagectl
          ,cop.cdagebcb
          ,cop.cdbcoctl
          ,cop.cdagedbb
          ,cop.nmrescop
      FROM crapcop cop
     WHERE UPPER(cop.nmrescop) = UPPER(p_nmrescop);
  rw_cod_coop_dest cr_cod_coop_dest%ROWTYPE;
  
  /* Busca o codigo da Coop. passando como parametro o nome resumido da Coop. */
  CURSOR cr_cod_coop_orig(p_nmrescop IN VARCHAR2) IS
    SELECT cop.cdcooper
          ,cop.cdagectl
          ,cop.cdagebcb
          ,cop.cdbcoctl
          ,cop.cdagedbb
          ,cop.nmrescop
          ,cop.nmextcop
      FROM crapcop cop
     WHERE UPPER(cop.nmrescop) = UPPER(p_nmrescop);
  rw_cod_coop_orig cr_cod_coop_orig%ROWTYPE;
  
  /* Busca o codigo da Coop. passando como parametro o nome resumido da Coop. */
  CURSOR cr_cod_coop_migr(p_nmrescop IN VARCHAR2) IS
    SELECT cop.cdcooper
          ,cop.cdagectl
          ,cop.cdagebcb
          ,cop.cdbcoctl
          ,cop.cdagedbb
          ,cop.nmrescop
      FROM crapcop cop
     WHERE UPPER(cop.nmrescop) = UPPER(p_nmrescop);
  rw_cod_coop_migr cr_cod_coop_migr%ROWTYPE;
  
  /* Busca a Data Conforme o Código da Cooperativa */
  CURSOR cr_dat_cop(p_coop IN INTEGER)IS
     SELECT dat.dtmvtolt
           ,dat.dtmvtocd
       FROM crapdat dat
      WHERE dat.cdcooper = p_coop;
  rw_dat_cop cr_dat_cop%ROWTYPE;
  
  /* Verifica Transferencia e Duplicacao de Matricula -- Associado de Destino */
  CURSOR cr_verifica_ass(p_coop IN INTEGER
                        ,p_nrdconta IN NUMBER)IS
     SELECT ass.cdsitdtl
           ,ass.nrdconta
           ,ass.cdtipcta
           ,ass.cdbcochq
           ,ass.nmprimtl
           ,ass.cdagenci
           ,ass.inpessoa
           ,ass.cdcooper
       FROM crapass ass
      WHERE ass.cdcooper = p_coop
        AND ass.nrdconta = p_nrdconta;
  rw_verifica_ass cr_verifica_ass%ROWTYPE;
  
  /* Verifica Transferencia e Duplicacao de Matricula -- Associado de Destino */
  CURSOR cr_tdm_ass(p_coop IN INTEGER
                   ,p_nrdconta IN INTEGER)IS
     SELECT ass.cdsitdtl
           ,ass.nrdconta
           ,ass.cdtipcta
           ,ass.cdbcochq
           ,ass.nmprimtl
           ,ass.cdagenci
       FROM crapass ass
      WHERE ass.cdcooper = p_coop
        AND ass.nrdconta = p_nrdconta
        AND ass.cdsitdtl IN(2,4,6,8);
  rw_tdm_ass cr_tdm_ass%ROWTYPE;
  
  /* Verifica Transferencia de Conta */
  CURSOR cr_tdc_ass(p_coop IN INTEGER
                   ,p_nrdconta IN INTEGER)IS
     SELECT ass.cdsitdtl
           ,ass.nrdconta
           ,ass.cdtipcta
           ,ass.cdbcochq
           ,ass.nmprimtl
           ,ass.cdagenci
		   ,ass.cdcooper
       FROM crapass ass
      WHERE ass.cdcooper = p_coop
        AND ass.nrdconta = p_nrdconta
        AND ass.cdsitdtl IN(2,4,6,8);
  rw_tdc_ass cr_tdc_ass%ROWTYPE;

  /* Verifica Transferencia e Duplicacao de Matricula */  
  CURSOR cr_verifica_trf(p_coop     IN INTEGER
                        ,p_nrdconta IN INTEGER)IS
      SELECT trf.nrsconta
        FROM craptrf trf
       WHERE trf.cdcooper = p_coop
         AND trf.nrdconta = p_nrdconta
         AND trf.tptransa = 1
         AND trf.insittrs = 2;
  rw_verifica_trf cr_verifica_trf%ROWTYPE;
     
  /* Verifica tab de Resumos de Lancamentos Depositos */
  CURSOR cr_verifica_mrw(p_coop IN INTEGER
                        ,p_cdagenci IN INTEGER
                        ,p_nrocaixa IN INTEGER)IS
      SELECT mrw.vlchqipr
            ,mrw.vlchqspr
            ,mrw.vlchqifp
            ,mrw.vlchqsfp
            ,mrw.vlchqcop
        FROM crapmrw mrw
       WHERE mrw.cdcooper = p_coop
         AND mrw.cdagenci = p_cdagenci
         AND mrw.nrdcaixa = p_nrocaixa;
  rw_verifica_mrw cr_verifica_mrw%ROWTYPE;
  
  /* Popula tt-cheques */
  CURSOR cr_popula_ttcheque(p_coop IN INTEGER
                        ,p_cdagenci IN INTEGER
                        ,p_nrocaixa IN INTEGER)IS
      SELECT mdw.dtlibcom
            ,mdw.nrdocmto
            ,mdw.cdhistor
            ,SUM(mdw.vlcompel) vlcompel
        FROM crapmdw mdw
       WHERE mdw.cdcooper = p_coop
         AND mdw.cdagenci = p_cdagenci
         AND mdw.nrdcaixa = p_nrocaixa
         AND mdw.cdhistor IN (3,4) -- (3 - Praca, 4 - Fora Praca)
      GROUP BY mdw.dtlibcom
              ,mdw.nrdocmto
              ,mdw.cdhistor;
  rw_popula_ttcheque cr_popula_ttcheque%ROWTYPE;
  
  /* Verifica tabela de Lancamentos Depositos */
  CURSOR cr_verifica_mdw(p_coop IN INTEGER
                        ,p_cdagenci IN INTEGER
                        ,p_nrocaixa IN INTEGER)IS
      SELECT mdw.lsdigctr
            ,mdw.dtlibcom
            ,mdw.nrdocmto
            ,mdw.vlcompel
            ,mdw.cdhistor
            ,mdw.nrctabdb
            ,mdw.cdcmpchq
            ,mdw.cdbanchq
            ,mdw.cdagechq
            ,mdw.nrctachq
            ,mdw.nrcheque
            ,mdw.tpdmovto
            ,mdw.nrctaaux
            ,mdw.nrddigc1            
            ,mdw.nrddigc2            
            ,mdw.nrddigc3
            ,mdw.cdtipchq
            ,mdw.dsdocmc7
            ,mdw.cdopelib
            ,mdw.nrautdoc
            ,rowid
        FROM crapmdw mdw
       WHERE mdw.cdcooper = p_coop
         AND mdw.cdagenci = p_cdagenci
         AND mdw.nrdcaixa = p_nrocaixa;
  rw_verifica_mdw cr_verifica_mdw%ROWTYPE;
  
  CURSOR cr_nrautdoc_mdw(p_rowid IN ROWID)IS
      SELECT mdw.nrautdoc
            ,rowid
        FROM crapmdw mdw
       WHERE mdw.rowid = p_rowid;
  rw_nrautdoc_mdw cr_nrautdoc_mdw%ROWTYPE;
  
  /* Verifica Resumo de Cheque para verificar se necessita
  verificar horario de corte */
  CURSOR cr_verif_hora_corte(p_coop IN INTEGER
                            ,p_cdagenci IN INTEGER
                            ,p_nrdcaixa IN INTEGER)IS
      SELECT mrw.vlchqipr
            ,mrw.vlchqspr
            ,mrw.vlchqifp
            ,mrw.vlchqsfp
            ,mrw.vlchqcop
        FROM crapmrw mrw
       WHERE mrw.cdcooper = p_coop
         AND mrw.cdagenci = p_cdagenci
         AND mrw.nrdcaixa = p_nrdcaixa
         AND mrw.vlchqipr <> 0 
         AND mrw.vlchqspr <> 0 
         AND mrw.vlchqifp <> 0 
         AND mrw.vlchqsfp <> 0;
  rw_verif_hora_corte cr_verif_hora_corte%ROWTYPE; 

  
  /* Verifica se existe registro na CRAPLOT */
  CURSOR cr_existe_lot(p_cdcooper IN INTEGER
                      ,p_dtmvtolt IN DATE
                      ,p_cdagenci IN INTEGER
                      ,p_cdbccxlt IN INTEGER
                      ,p_nrdolote IN INTEGER)IS
      SELECT lot.cdcooper
            ,lot.dtmvtolt
            ,lot.cdagenci
            ,lot.cdbccxlt
            ,lot.nrdolote
            ,lot.cdopecxa
        FROM craplot lot
       WHERE lot.cdcooper = p_cdcooper
         AND lot.dtmvtolt = p_dtmvtolt
         AND lot.cdagenci = p_cdagenci
         AND lot.cdbccxlt = p_cdbccxlt
         AND lot.nrdolote = p_nrdolote;
  rw_existe_lot cr_existe_lot%ROWTYPE;
  
  /* Buscar os Totais de Cheque Cooperativa */
  CURSOR cr_tot_chq_coop(p_coop IN INTEGER
                          ,p_cdagenci IN INTEGER
                          ,p_nrocaixa IN INTEGER)IS
      SELECT mrw.vlchqipr
            ,mrw.vlchqspr
            ,mrw.vlchqifp
            ,mrw.vlchqsfp
            ,mrw.vlchqcop
        FROM crapmrw mrw
       WHERE mrw.cdcooper = p_coop
         AND mrw.cdagenci = p_cdagenci
         AND mrw.nrdcaixa = p_nrocaixa;
  rw_tot_chq_coop cr_tot_chq_coop%ROWTYPE;
  
  /* Verifica se existe LCM - 6 Parametros */
  CURSOR cr_existe_lcm(p_cdcooper INTEGER
                      ,p_dtmvtolt DATE
                      ,p_cdagenci INTEGER
                      ,p_cdbccxlt INTEGER
                      ,p_nrdolote INTEGER
                      ,p_nrseqdig INTEGER) IS
     SELECT lcm.cdcooper
           ,lcm.dtmvtolt
           ,lcm.cdagenci
           ,lcm.cdbccxlt
           ,lcm.nrdolote
           ,lcm.nrseqdig
       FROM craplcm lcm
      WHERE lcm.cdcooper = p_cdcooper
        AND lcm.dtmvtolt = p_dtmvtolt
        AND lcm.cdagenci = p_cdagenci
        AND lcm.cdbccxlt = p_cdbccxlt
        AND lcm.nrdolote = p_nrdolote
        AND lcm.nrseqdig = p_nrseqdig;
  rw_existe_lcm cr_existe_lcm%ROWTYPE;
  
  /* Verifica se existe LCM - 7 Parametros */  
  CURSOR cr_existe_lcm1(p_cdcooper INTEGER
                       ,p_dtmvtolt DATE
                       ,p_cdagenci INTEGER
                       ,p_cdbccxlt INTEGER
                       ,p_nrdolote INTEGER
                       ,p_nrdctabb INTEGER
                       ,p_nrdocmto INTEGER) IS
     SELECT lcm.cdcooper
           ,lcm.dtmvtolt
           ,lcm.cdagenci
           ,lcm.cdbccxlt
           ,lcm.nrdolote
           ,lcm.nrdctabb
           ,lcm.nrdocmto
       FROM craplcm lcm
      WHERE lcm.cdcooper = p_cdcooper
        AND lcm.dtmvtolt = p_dtmvtolt
        AND lcm.cdagenci = p_cdagenci
        AND lcm.cdbccxlt = p_cdbccxlt
        AND lcm.nrdolote = p_nrdolote
        AND lcm.nrdctabb = p_nrdctabb
        AND lcm.nrdocmto = p_nrdocmto;
  rw_existe_lcm1 cr_existe_lcm1%ROWTYPE;
  
  -- Busca a ultma sequencia de dig
  CURSOR cr_consulta_lot (p_cdcooper IN craplot.cdcooper%TYPE
                         ,p_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,p_cdagenci IN craplot.cdagenci%TYPE
                         ,p_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,p_nrdolote IN craplot.nrdolote%TYPE) IS
     SELECT MAX(lot.nrseqdig) + 1 nrseqdig
       FROM craplot lot
       WHERE lot.cdcooper = p_cdcooper
         AND lot.dtmvtolt = p_dtmvtolt
         AND lot.cdagenci = p_cdagenci
         AND lot.cdbccxlt = p_cdbccxlt
         AND lot.nrdolote = p_nrdolote;
  rw_consulta_lot cr_consulta_lot%ROWTYPE;
  
  -- Busca a ultma sequencia de dig
  CURSOR cr_consulta_chd (p_cdcooper IN crapchd.cdcooper%TYPE
                         ,p_dtmvtolt IN crapchd.dtmvtolt%TYPE
                         ,p_cdcmpchq IN crapchd.cdcmpchq%TYPE
                         ,p_cdbanchq IN crapchd.cdbanchq%TYPE
                         ,p_cdagechq IN crapchd.cdagechq%TYPE
                         ,p_nrctachq IN crapchd.nrctachq%TYPE
                         ,p_nrcheque IN crapchd.nrcheque%TYPE) IS
    SELECT chd.cdcooper
          ,chd.dtmvtolt
          ,chd.cdcmpchq
          ,chd.cdbanchq
          ,chd.cdagechq
          ,chd.nrctachq
          ,chd.nrcheque
          ,chd.cdagenci
          ,chd.cdbccxlt
          ,chd.nrdocmto
          ,chd.cdoperad
          ,chd.cdsitatu
          ,chd.dsdocmc7
          ,chd.inchqcop
          ,chd.insitchq
          ,chd.cdtipchq
          ,chd.nrdconta
          ,chd.nrddigc1
          ,chd.nrddigc2
          ,chd.nrddigc3
          ,chd.nrddigv1
          ,chd.nrddigv2
          ,chd.nrddigv3
          ,chd.nrdolote
          ,chd.tpdmovto
          ,chd.nrterfin
          ,chd.vlcheque
          ,chd.cdagedst
          ,chd.nrctadst                  
      FROM crapchd chd
     WHERE chd.cdcooper = p_cdcooper
       AND chd.dtmvtolt = p_dtmvtolt
       AND chd.cdcmpchq = p_cdcmpchq
       AND chd.cdbanchq = p_cdbanchq
       AND chd.cdagechq = p_cdagechq
       AND chd.nrctachq = p_nrctachq
       AND chd.nrcheque = p_nrcheque;
  rw_consulta_chd cr_consulta_chd%ROWTYPE;
  
  -- Busca novamente os dados da acolhedora
  CURSOR cr_rowid_chd(p_rowid IN ROWID) IS
    SELECT chd.cdcooper
          ,chd.dtmvtolt
          ,chd.cdcmpchq
          ,chd.cdbanchq
          ,chd.cdagechq
          ,chd.nrctachq
          ,chd.nrcheque
          ,chd.cdagenci
          ,chd.cdbccxlt
          ,chd.nrdocmto
          ,chd.cdoperad
          ,chd.cdsitatu
          ,chd.dsdocmc7
          ,chd.inchqcop
          ,chd.insitchq
          ,chd.cdtipchq
          ,chd.nrdconta
          ,chd.nrddigc1
          ,chd.nrddigc2
          ,chd.nrddigc3
          ,chd.nrddigv1
          ,chd.nrddigv2
          ,chd.nrddigv3
          ,chd.nrdolote
          ,chd.tpdmovto
          ,chd.nrterfin
          ,chd.vlcheque
          ,chd.cdagedst
          ,chd.nrctadst                  
      FROM crapchd chd
     WHERE ROWID = p_rowid;
  rw_rowid_chd cr_rowid_chd%ROWTYPE;
  
  -- Verfica Folha de Cheque da Cooperatica do Cheque
  CURSOR cr_verifica_fdc (p_cdcooper IN crapfdc.cdcooper%TYPE
                         ,p_cdbanchq IN crapfdc.cdbanchq%TYPE
                         ,p_cdagechq IN crapfdc.cdcmpchq%TYPE
                         ,p_nrctachq IN crapfdc.cdbanchq%TYPE
                         ,p_nrcheque IN crapfdc.cdagechq%TYPE) IS
     SELECT fdc.incheque
           ,fdc.dtliqchq
           ,fdc.cdoperad
           ,fdc.vlcheque
           ,fdc.cdbanchq
           ,fdc.cdagechq
           ,fdc.nrctachq
           ,fdc.tpcheque
           ,fdc.cdcooper
           ,fdc.nrdconta
       FROM crapfdc fdc
      WHERE fdc.cdcooper = p_cdcooper
        AND fdc.cdbanchq = p_cdbanchq
        AND fdc.cdagechq = p_cdagechq
        AND fdc.nrctachq = p_nrctachq
        AND fdc.nrcheque = p_nrcheque;
  rw_verifica_fdc cr_verifica_fdc%ROWTYPE;
  
  CURSOR cr_verifica_tco (p_coop_ant IN craptco.cdcopant%TYPE
                         ,p_ncta_ant IN craptco.nrctaant%TYPE) IS
     SELECT tco.cdageant
           ,tco.cdagenci
           ,tco.cdcooper
           ,tco.cdcopant
           ,tco.flgativo
           ,tco.nrcarant
           ,tco.nrcartao
           ,tco.nrctaant
           ,tco.nrdctitg
           ,tco.tpctatrf
           ,tco.nrdconta
       FROM craptco tco
      WHERE tco.cdcopant = p_coop_ant
        AND tco.nrctaant = p_ncta_ant
        AND tco.tpctatrf = 1
        AND tco.flgativo = 1;
  rw_verifica_tco cr_verifica_tco%ROWTYPE;
  
  /* Verifica se existe registro na CRAPBCX */
  CURSOR cr_existe_bcx(p_cdcooper IN INTEGER
                      ,p_dtmvtolt IN DATE
                      ,p_cdagenci IN INTEGER
                      ,p_nrdcaixa IN INTEGER
                      ,p_cdopecxa IN VARCHAR2)IS
      SELECT bcx.qtcompln
            ,bcx.nrdmaqui
            ,bcx.qtchqprv
        FROM crapbcx bcx
       WHERE bcx.cdcooper = p_cdcooper
         AND bcx.dtmvtolt = p_dtmvtolt
         AND bcx.cdagenci = p_cdagenci
         AND bcx.nrdcaixa = p_nrdcaixa
         AND UPPER(bcx.cdopecxa) = UPPER(p_cdopecxa);
  rw_existe_bcx cr_existe_bcx%ROWTYPE;

  CURSOR cr_crapttl(pr_cdcooper crapttl.cdcooper%TYPE
	               ,pr_nrdconta crapttl.nrdconta%TYPE)IS
  SELECT crapttl.nmextttl
	FROM crapttl
   WHERE crapttl.cdcooper = pr_cdcooper
	 AND crapttl.nrdconta = pr_nrdconta
	 AND crapttl.idseqttl = 2;

  -- Variaveis Erro
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
  
  -- Variaveis
  pr_typ_tab_chq typ_tab_chq;
  pr_tab_erro GENE0001.typ_tab_erro;
  
  vr_nrtrfcta  craptrf.nrsconta%TYPE := 0;
  vr_nrdconta  craptrf.nrsconta%TYPE := 0;
  vr_nro_conta craptrf.nrsconta%TYPE := 0;
  vr_dsdctitg VARCHAR2(200)          := '';
  vr_stsnrcal INTEGER                := 0;
  vr_achou_horario_corte BOOLEAN     := FALSE;
  vr_i_nro_lote NUMBER(10)           := 0;
  vr_c_docto_salvo VARCHAR2(200)     := '';
  vr_cdpacrem PLS_INTEGER;
  vr_c_docto VARCHAR2(200)           := '';
  vr_tpdmovto INTEGER                := 0;
  vr_i_nro_docto INTEGER             := 0;
  vr_p_literal VARCHAR2(32000)       := '';
  vr_p_ult_sequencia INTEGER         := 0;
  vr_glb_dsdctitg    VARCHAR2(200)   := '';
  vr_p_registro ROWID;
  
  vr_aux_p_literal  VARCHAR2(32000)  := '';
  vr_aux_p_ult_seq  INTEGER          := 0;
  vr_aux_p_registro ROWID;
  vr_aux_cdbandep   crapfdc.cdbandep%TYPE;
  vr_aux_cdagedep   crapfdc.cdagedep%TYPE;
  vr_lsdigctr          gene0002.typ_split;
  
  vr_aux_cdhistor   craplcm.cdhistor%TYPE;
  
  vr_de_valor_total    NUMBER(13,2) := 0;
  vr_de_cooperativa    NUMBER(13,2) := 0;
  vr_de_chq_intercoopc NUMBER(13,2) := 0;
  vr_de_maior_praca    NUMBER(13,2) := 0;
  vr_de_menor_praca    NUMBER(13,2) := 0;
  vr_de_maior_fpraca   NUMBER(13,2) := 0;
  vr_de_menor_fpraca   NUMBER(13,2) := 0;
  vr_index             VARCHAR2(21)  := '';
  vr_i_seq_386         INTEGER      := 0;
  vr_nrsequen          INTEGER      := 0;
  vr_literal        VARCHAR2(5000)  := '';
  vr_rowid_chd           ROWID;
  vr_nmsegntl          crapttl.nmextttl%TYPE;
  
  vr_aux_inchqcop crapchd.inchqcop%TYPE;
  vr_aux_nrctachq crapchd.nrctachq%TYPE;
  vr_aux_nrddigv1 crapchd.nrddigv1%TYPE;
  vr_aux_nrddigv2 crapchd.nrddigv2%TYPE;
  vr_aux_nrddigv3 crapchd.nrddigv3%TYPE;
  vr_aux_nrseqdig crapmdw.nrseqdig%TYPE;

  -- Guardar registro dstextab  
  vr_dstextab craptab.dstextab%TYPE;

  BEGIN

     -- Busca Cod. Coop de DESTINO
     OPEN cr_cod_coop_dest(pr_cooper_dest);
     FETCH cr_cod_coop_dest INTO rw_cod_coop_dest;
     CLOSE cr_cod_coop_dest;
     
     -- Busca Cod. Coop de ORIGEM
     OPEN cr_cod_coop_orig(pr_cooper);
     FETCH cr_cod_coop_orig INTO rw_cod_coop_orig;
     CLOSE cr_cod_coop_orig;
     
     -- Busca Cod. Coop MIGRADA
     OPEN cr_cod_coop_migr(pr_cooper_migrada);
     FETCH cr_cod_coop_migr INTO rw_cod_coop_migr;
     CLOSE cr_cod_coop_migr;
     
     -- Busca Data do Sistema
     OPEN cr_dat_cop(rw_cod_coop_orig.cdcooper);
     FETCH cr_dat_cop INTO rw_dat_cop;
     CLOSE cr_dat_cop;
     
     /* Gravar o Nro da Conta para possivel manipulacao
     do nro da conta utilizar a variavel */   
     vr_nro_conta := pr_nro_conta;
     
     -- Verifica a conta do associado
     OPEN cr_verifica_ass(rw_cod_coop_dest.cdcooper
                         ,vr_nro_conta);
     FETCH cr_verifica_ass INTO rw_verifica_ass;
     CLOSE cr_verifica_ass;
       
	 IF rw_verifica_ass.inpessoa = 1 THEN

	   OPEN cr_crapttl(pr_cdcooper => rw_verifica_ass.cdcooper
	                  ,pr_nrdconta => rw_verifica_ass.nrdconta);

	   FETCH cr_crapttl INTO vr_nmsegntl;

	   CLOSE cr_crapttl;

	 END IF;
       
     -- Verifica Transferencia e Duplicacao de Matricula - Associado de Destino
     OPEN cr_tdm_ass(rw_cod_coop_dest.cdcooper
                    ,vr_nro_conta);
     FETCH cr_tdm_ass INTO rw_tdm_ass;
        IF cr_tdm_ass%FOUND THEN
           OPEN cr_verifica_trf(rw_cod_coop_dest.cdcooper
                               ,rw_tdm_ass.nrdconta);
           FETCH cr_verifica_trf INTO rw_verifica_trf;
              IF cr_verifica_trf%FOUND THEN
                 vr_nrtrfcta  := rw_verifica_trf.nrsconta;
                 vr_nrdconta  := rw_verifica_trf.nrsconta;
                 vr_nro_conta := rw_verifica_trf.nrsconta;
              END IF;
           CLOSE cr_verifica_trf;           
        END IF;             
     CLOSE cr_tdm_ass;
     
     CXON0000.pc_elimina_erro(pr_cooper      => rw_cod_coop_orig.cdcooper
                             ,pr_cod_agencia => pr_cod_agencia
                             ,pr_nro_caixa   => pr_nro_caixa
                             ,pr_cdcritic    => vr_cdcritic
                             ,pr_dscritic    => vr_dscritic);
     -- Se ocorreu erro
     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;  
     
        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => pr_nro_caixa
                             ,pr_cod_erro => pr_cdcritic
                             ,pr_dsc_erro => pr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                            
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := vr_dscritic;
           RAISE vr_exc_erro;
        END IF;
        
        RAISE vr_exc_erro;
     END IF;
     
     --  Verifica tabela de Resumos de Lancamentos Depositos
     OPEN cr_verifica_mrw(rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia
                         ,pr_nro_caixa);
     FETCH cr_verifica_mrw INTO rw_verifica_mrw;
        IF cr_verifica_mrw%NOTFOUND THEN
           pr_cdcritic := 0;
           pr_dscritic := 'Nao existem valores a serem Depositados';
           
           cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                ,pr_cdagenci => pr_cod_agencia
                                ,pr_nrdcaixa => pr_nro_caixa
                                ,pr_cod_erro => pr_cdcritic
                                ,pr_dsc_erro => pr_dscritic
                                ,pr_flg_erro => TRUE
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
                                
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
              RAISE vr_exc_erro;
           END IF;

           RAISE vr_exc_erro;
        END IF;
     CLOSE cr_verifica_mrw;
     
     --  Verifica tabela de Lancamentos Depositos
     OPEN cr_verifica_mdw(rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia
                         ,pr_nro_caixa);
     FETCH cr_verifica_mdw INTO rw_verifica_mdw;
     
        vr_lsdigctr := gene0002.fn_quebra_string(pr_string  => rw_verifica_mdw.lsdigctr
                                                ,pr_delimit => ',');
                                 
        vr_lsdigctr := gene0002.fn_quebra_string(pr_string  => rw_verifica_mdw.lsdigctr
                                                ,pr_delimit => ',');
                                 
        IF vr_lsdigctr.COUNT() <> 3 THEN
           pr_cdcritic := 0;
           pr_dscritic := 'Avise INF(ENTRY) = ' ||
                          TO_CHAR(rw_verifica_mdw.lsdigctr) ||' - '||
                          TO_CHAR(rw_verifica_mdw.nrcheque);
                          
           cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                ,pr_cdagenci => pr_cod_agencia
                                ,pr_nrdcaixa => pr_nro_caixa
                                ,pr_cod_erro => pr_cdcritic
                                ,pr_dsc_erro => pr_dscritic
                                ,pr_flg_erro => TRUE
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
              RAISE vr_exc_erro;
           END IF;

           RAISE vr_exc_erro;
        END IF;
     CLOSE cr_verifica_mdw;
     
     vr_nrtrfcta := 0;
     vr_nrdconta := vr_nro_conta;
     
     -- Verifica se Houve Transferencia de Conta
     OPEN cr_tdc_ass(rw_cod_coop_dest.cdcooper
                    ,vr_nrdconta);
     FETCH cr_tdc_ass INTO rw_tdc_ass;
        IF cr_tdc_ass%FOUND THEN
           OPEN cr_verifica_trf(rw_cod_coop_dest.cdcooper
                               ,rw_tdc_ass.nrdconta);
           FETCH cr_verifica_trf INTO rw_verifica_trf;
              IF cr_verifica_trf%FOUND THEN
                 vr_nrtrfcta  := rw_verifica_trf.nrsconta;
                 vr_nrdconta  := rw_verifica_trf.nrsconta;                
              END IF;
           CLOSE cr_verifica_trf;       
        END IF;             
     CLOSE cr_tdc_ass;
     
     -- Se houve transferencia de conta, grava na variavel
     IF vr_nrtrfcta > 0 THEN
        vr_nrdconta := vr_nrtrfcta;
     END IF;
     
     -- Gravar o Nro da Conta e utilizar a variavel
     vr_nro_conta := vr_nrdconta;

     -- Verifica horario de Corte - Coop do Caixa
     vr_achou_horario_corte := FALSE;
     FOR rw_verif_hora_corte IN cr_verif_hora_corte(rw_cod_coop_orig.cdcooper
                                                   ,pr_cod_agencia
                                                   ,pr_nro_caixa) LOOP
        vr_achou_horario_corte := TRUE; -- Registro encontrado    
     END LOOP;
     
     -- Se encontrou registro. Valida horario de Corte - Coop do Caixa
     IF vr_achou_horario_corte THEN

         -- Buscar configuração na tabela
         vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                  ,pr_nmsistem => 'CRED'
                                                  ,pr_tptabela => 'GENERI'
                                                  ,pr_cdempres => 0
                                                  ,pr_cdacesso => 'HRTRCOMPEL'
                                                  ,pr_tpregist => pr_cod_agencia);                            
                            
                            

        
           IF TRIM(vr_dstextab) IS NULL THEN 
              pr_cdcritic := 676;
              pr_dscritic := '';
              
              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => pr_nro_caixa
                                   ,pr_cod_erro => pr_cdcritic
                                   ,pr_dsc_erro => pr_dscritic
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
                                   
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic;
                 RAISE vr_exc_erro;
              END IF;

              RAISE vr_exc_erro;
           END IF;
           
           IF TO_NUMBER(SUBSTR(vr_dstextab,1,1)) <> 0 THEN
              pr_cdcritic := 677;
              pr_dscritic := '';
              
              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => pr_nro_caixa
                                   ,pr_cod_erro => pr_cdcritic
                                   ,pr_dsc_erro => pr_dscritic
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic;
                 RAISE vr_exc_erro;
              END IF;

              RAISE vr_exc_erro;
           END IF;
           
           IF TO_NUMBER(SUBSTR(vr_dstextab,3,5)) <= TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')) THEN
              pr_cdcritic := 676;
              pr_dscritic := '';
              
              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => pr_nro_caixa
                                   ,pr_cod_erro => pr_cdcritic
                                   ,pr_dsc_erro => pr_dscritic
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic;
                 RAISE vr_exc_erro;
              END IF;

              RAISE vr_exc_erro;
           END IF;
           
     END IF; -- Verifica Horario de Corte
     
     -- Criacao do LOTE de DESTINO (CREDITO)
     vr_i_nro_lote    := 10118;
     vr_c_docto_salvo := TO_CHAR(SYSDATE,'SSSSS');
     
     -- Verifica se existe lote
     OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                       ,rw_dat_cop.dtmvtocd
                       ,1   /* FIXO */
                       ,100 /* FIXO */
                       ,vr_i_nro_lote);
     FETCH cr_existe_lot INTO rw_existe_lot;
        IF cr_existe_lot%NOTFOUND THEN
           -- Se nao existir cria a capa de lote
           BEGIN
              INSERT INTO craplot(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,tplotmov
                                 ,nrdcaixa
                                 ,cdopecxa)
              VALUES (rw_cod_coop_dest.cdcooper
                     ,rw_dat_cop.dtmvtocd
                     ,1
                     ,100
                     ,vr_i_nro_lote
                     ,1
                     ,pr_nro_caixa
                     ,pr_cod_operador);              
           EXCEPTION
              WHEN OTHERS THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Erro ao inserir na CRAPLOT : '||sqlerrm;
                                  
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);

                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
           END;
        END IF;
     CLOSE cr_existe_lot;

     vr_de_valor_total    := 0;
     vr_de_cooperativa    := 0;
     vr_de_chq_intercoopc := 0;
     vr_de_maior_praca    := 0;
     vr_de_menor_praca    := 0;
     vr_de_maior_fpraca   := 0;
     vr_de_menor_fpraca   := 0;

     -- RESUMO
     -- Buscar os Totais de Cheque Cooperativa
     OPEN cr_tot_chq_coop(rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia
                         ,pr_nro_caixa);
     FETCH cr_tot_chq_coop INTO rw_tot_chq_coop;
        IF cr_tot_chq_coop%FOUND THEN
           vr_de_cooperativa    := rw_tot_chq_coop.vlchqcop;
           vr_de_valor_total    := vr_de_cooperativa;           
        END IF;
     CLOSE cr_tot_chq_coop;
     
      -- Buscar configuração na tabela
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'MAIORESCHQ'
                                               ,pr_tpregist => 1);                                                     
     
        -- Buscar os totais de Cheques
        FOR rw_verifica_mdw IN cr_verifica_mdw(rw_cod_coop_orig.cdcooper
                                              ,pr_cod_agencia
                                              ,pr_nro_caixa) LOOP
            
           -- Montar chave de busca
           vr_index :=  TO_CHAR(rw_verifica_mdw.dtlibcom,'DD/MM/RRRR')||
                        TO_CHAR(LPAD(rw_verifica_mdw.nrdocmto,10,0));
           
           -- Se a chave ainda não existir
           IF pr_typ_tab_chq.count = 0 OR NOT pr_typ_tab_chq.exists(vr_index) THEN
             pr_typ_tab_chq(vr_index).vlcompel := 0; -- Inicializa o campo de valor
           END IF;

           -- Define o tipo do docmto (1-Menor Praca-Maior/2-Praca,1-Menor Fora Praca/2-Maior Fora Praca)
           IF rw_verifica_mdw.vlcompel < TO_NUMBER(SUBSTR(vr_dstextab,1,15)) THEN               
              vr_tpdmovto := 2;             
           ELSE
              vr_tpdmovto := 1;
           END IF;
            
            IF rw_verifica_mdw.cdhistor = 3 THEN -- Praca
               IF vr_tpdmovto = 2 THEN -- Menor Praca
                  pr_typ_tab_chq(vr_index).dtlibcom := rw_verifica_mdw.dtlibcom;
                  pr_typ_tab_chq(vr_index).vlcompel := pr_typ_tab_chq(vr_index).vlcompel + rw_verifica_mdw.vlcompel;
                  pr_typ_tab_chq(vr_index).nrdocmto := 3;
                  vr_de_menor_praca                 := vr_de_menor_praca + rw_verifica_mdw.vlcompel;
               ELSE -- Maior Praca
                  pr_typ_tab_chq(vr_index).dtlibcom := rw_verifica_mdw.dtlibcom;
                  pr_typ_tab_chq(vr_index).vlcompel := pr_typ_tab_chq(vr_index).vlcompel + rw_verifica_mdw.vlcompel;
                  pr_typ_tab_chq(vr_index).nrdocmto := 4;
                  vr_de_maior_praca                 := vr_de_maior_praca + rw_verifica_mdw.vlcompel;
               END IF;                 
            ELSE -- Fora Praca
               IF rw_verifica_mdw.cdhistor = 4 THEN
                  IF vr_tpdmovto = 2 THEN -- Menor Fora Praca
                     pr_typ_tab_chq(vr_index).dtlibcom := rw_verifica_mdw.dtlibcom;
                     pr_typ_tab_chq(vr_index).vlcompel := pr_typ_tab_chq(vr_index).vlcompel + rw_verifica_mdw.vlcompel;
                     pr_typ_tab_chq(vr_index).nrdocmto := 5;
                     vr_de_menor_fpraca                := vr_de_menor_fpraca + rw_verifica_mdw.vlcompel;
                  ELSE -- Maior Fora Praca
                     pr_typ_tab_chq(vr_index).dtlibcom := rw_verifica_mdw.dtlibcom;
                     pr_typ_tab_chq(vr_index).vlcompel := pr_typ_tab_chq(vr_index).vlcompel + rw_verifica_mdw.vlcompel;
                     pr_typ_tab_chq(vr_index).nrdocmto := 6;
                     vr_de_maior_fpraca                := vr_de_maior_fpraca + rw_verifica_mdw.vlcompel;
                  END IF;  
               END IF;
            END IF;                                                   
                                                                                                                 
        END LOOP;
        -- Fim da montagem do Resumo
          
     vr_de_valor_total := vr_de_valor_total
                        + vr_de_menor_fpraca + vr_de_menor_praca
                        + vr_de_maior_fpraca + vr_de_maior_praca;
                        
     /** Se veio da Rotina 61 **/
     IF NVL(pr_identifica,' ') LIKE '%Deposito de envelope%'  THEN
        vr_cdpacrem := 91; /* TAA */
     ELSE
        vr_cdpacrem := pr_cod_agencia;
     END IF;                             
     
     -- Cria registro na CRAPLDT - Para o valor total da transacao
     CXON0022.pc_gera_log(pr_cooper       => rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia  => pr_cod_agencia
                         ,pr_nro_caixa    => pr_nro_caixa
                         ,pr_operador     => pr_cod_operador
                         ,pr_cooper_dest  => rw_cod_coop_dest.cdcooper
                         ,pr_nrdcontade   => pr_nro_conta_de
                         ,pr_nrdcontapara => vr_nro_conta
                         ,pr_tpoperac     => 5 -- Dep em Cheque
                         ,pr_valor        => vr_de_valor_total
                         ,pr_nrdocmto     => TO_NUMBER(vr_c_docto_salvo)
                         ,pr_cdpacrem     => vr_cdpacrem
                         ,pr_cdcritic     => vr_cdcritic   -- Codigo do erro
                         ,pr_dscritic     => vr_dscritic); -- Descricao da Critica
                         
     -- Se ocorreu erro
     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => pr_nro_caixa
                             ,pr_cod_erro => vr_cdcritic
                             ,pr_dsc_erro => vr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := vr_dscritic;
           RAISE vr_exc_erro;
        END IF;

        RAISE vr_exc_erro;
     END IF;

     vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo);
     pr_nro_docmto  := TO_NUMBER(vr_c_docto_salvo);
     
     -- Grava Autenticacao Arquivo/Spool
     CXON0000.pc_grava_autenticacao(pr_cooper       => rw_cod_coop_orig.cdcooper
                                   ,pr_cod_agencia  => pr_cod_agencia
                                   ,pr_nro_caixa    => pr_nro_caixa
                                   ,pr_cod_operador => pr_cod_operador
                                   ,pr_valor        => vr_de_valor_total
                                   ,pr_docto        => TO_NUMBER(vr_i_nro_docto)
                                   ,pr_operacao     => FALSE -- YES (PG), NO (RC)
                                   ,pr_status       => '1' -- On-line
                                   ,pr_estorno      => FALSE -- Nao estorno
                                   ,pr_histor       => 700
                                   ,pr_data_off     => NULL 
                                   ,pr_sequen_off   => 0 -- Seq. off-line
                                   ,pr_hora_off     => 0 -- hora off-line
                                   ,pr_seq_aut_off  => 0 -- Seq.orig.Off-line
                                   ,pr_literal      => vr_p_literal
                                   ,pr_sequencia    => vr_p_ult_sequencia
                                   ,pr_registro     => vr_p_registro
                                   ,pr_cdcritic     => vr_cdcritic
                                   ,pr_dscritic     => vr_dscritic);
     -- Se ocorreu erro
     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => pr_nro_caixa
                             ,pr_cod_erro => vr_cdcritic
                             ,pr_dsc_erro => vr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := vr_dscritic;
           RAISE vr_exc_erro;
        END IF;

        RAISE vr_exc_erro;
     END IF;
     
     OPEN cr_existe_bcx(rw_cod_coop_orig.cdcooper
                       ,rw_dat_cop.dtmvtolt
                       ,pr_cod_agencia
                       ,pr_nro_caixa
                       ,pr_cod_operador);
     FETCH cr_existe_bcx INTO rw_existe_bcx;
       -- Informacao da cooperativa de origem
       BEGIN
          INSERT INTO craplcx(cdcooper
                             ,dtmvtolt
                             ,cdagenci
                             ,nrdcaixa
                             ,cdopecxa
                             ,nrdocmto
                             ,nrseqdig
                             ,nrdmaqui
                             ,cdhistor
                             ,dsdcompl
                             ,vldocmto
                             ,nrautdoc)
          VALUES (rw_cod_coop_orig.cdcooper
                 ,rw_dat_cop.dtmvtolt
                 ,pr_cod_agencia
                 ,pr_nro_caixa
                 ,pr_cod_operador
                 ,TO_NUMBER(vr_i_nro_docto)
                 ,rw_existe_bcx.qtcompln + 1
                 ,rw_existe_bcx.nrdmaqui
                 ,1528
                 ,'Agencia:'||gene0002.fn_mask(rw_cod_coop_dest.cdagectl,'zzz9')||
                  ' Conta/DV:'||gene0002.fn_mask(vr_nro_conta,'zzzz.zzz.9')
                 ,vr_de_valor_total
                 ,vr_p_ult_sequencia);              
       EXCEPTION
          WHEN OTHERS THEN
             pr_cdcritic := 0;
             pr_dscritic := 'Erro ao inserir na CRAPLCX : '||sqlerrm;
                              
             cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                  ,pr_cdagenci => pr_cod_agencia
                                  ,pr_nrdcaixa => pr_nro_caixa
                                  ,pr_cod_erro => pr_cdcritic
                                  ,pr_dsc_erro => pr_dscritic
                                  ,pr_flg_erro => TRUE
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
                                  
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
                RAISE vr_exc_erro;
             END IF;
          
             RAISE vr_exc_erro;
       END;
     CLOSE cr_existe_bcx;
     
     OPEN cr_verifica_mrw(rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia
                         ,pr_nro_caixa);
     FETCH cr_verifica_mrw INTO rw_verifica_mrw;
        IF cr_verifica_mrw%FOUND THEN
           
           -- Formata conta integracao
           GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => vr_nro_conta
                                         ,pr_dscalcul => vr_dsdctitg
                                         ,pr_stsnrcal => vr_stsnrcal
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
           -- Se ocorreu erro
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
              
              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => pr_nro_caixa
                                   ,pr_cod_erro => vr_cdcritic
                                   ,pr_dsc_erro => vr_dscritic
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
                                   
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic;
                 RAISE vr_exc_erro;
              END IF;

              RAISE vr_exc_erro;
           END IF;
                      
           /* Dinheiro - Nao eh tratato nessa procedure */
                      
           IF rw_verifica_mrw.vlchqcop <> 0 THEN
             
              vr_c_docto := vr_c_docto_salvo || '01' ||'2'; -- 'Sequencial' fixo 01
              
              -- Busca o ultima sequencia de digito
              OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                                  ,rw_dat_cop.dtmvtocd
                                  ,1   -- FIXO
                                  ,100 -- FIXO
                                  ,vr_i_nro_lote);
              FETCH cr_consulta_lot INTO rw_consulta_lot;
              CLOSE cr_consulta_lot;
              
              -- Verifica se Lancamento ja Existe no Dest.
              OPEN cr_existe_lcm(rw_cod_coop_dest.cdcooper
                                ,rw_dat_cop.dtmvtolt
                                ,1
                                ,100
                                ,vr_i_nro_lote
                                ,rw_consulta_lot.nrseqdig); -- Já está encrementado + 1 no CURSOR cr_consulta_lot
              FETCH cr_existe_lcm INTO rw_existe_lcm;
                 IF cr_existe_lcm%FOUND THEN
                    pr_cdcritic := 0;
                    pr_dscritic := 'Lancamento  ja existente';
                                      
                    cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                         ,pr_cdagenci => pr_cod_agencia
                                         ,pr_nrdcaixa => pr_nro_caixa
                                         ,pr_cod_erro => pr_cdcritic
                                         ,pr_dsc_erro => pr_dscritic
                                         ,pr_flg_erro => TRUE
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic); 
                    -- Levantar excecao
                    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                       pr_cdcritic := vr_cdcritic;
                       pr_dscritic := vr_dscritic;
                       RAISE vr_exc_erro;
                    END IF;

                    RAISE vr_exc_erro;
                 END IF;              
              CLOSE cr_existe_lcm;
              
              OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                                ,rw_dat_cop.dtmvtolt
                                ,1
                                ,100
                                ,vr_i_nro_lote
                                ,vr_nro_conta
                                ,vr_c_docto);
              FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
                 IF cr_existe_lcm1%FOUND THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'Lancamento(Primario) ja existente';
                                      
                    cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                         ,pr_cdagenci => pr_cod_agencia
                                         ,pr_nrdcaixa => pr_nro_caixa
                                         ,pr_cod_erro => vr_cdcritic
                                         ,pr_dsc_erro => vr_dscritic
                                         ,pr_flg_erro => TRUE
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic); 
                    -- Levantar excecao
                    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                       pr_cdcritic := vr_cdcritic;
                       pr_dscritic := vr_dscritic; 
                       RAISE vr_exc_erro;
                    END IF;

                    RAISE vr_exc_erro;
                 END IF;              
              CLOSE cr_existe_lcm1;
              
              -- Chegou aqui eh porque nao existir lcm, entao cria registro de lcm
              BEGIN
                 INSERT INTO craplcm(cdcooper
                                    ,dtmvtolt
                                    ,cdagenci
                                    ,cdbccxlt
                                    ,dsidenti
                                    ,nrdolote
                                    ,nrdconta
                                    ,nrdocmto
                                    ,vllanmto
                                    ,cdhistor
                                    ,nrseqdig
                                    ,nrdctabb
                                    ,nrautdoc
                                    ,cdpesqbb
                                    ,nrdctitg
                                    ,cdcoptfn
                                    ,cdagetfn
                                    ,nrterfin
                                    ,cdoperad)
                 VALUES (rw_cod_coop_dest.cdcooper
                        ,rw_dat_cop.dtmvtolt
                        ,1
                        ,100
                        ,pr_identifica
                        ,vr_i_nro_lote
                        ,vr_nro_conta
                        ,TO_NUMBER(vr_c_docto)
                        ,rw_verifica_mrw.vlchqcop
                        ,1524 -- 386 - CR.TRF.CH.INT
                        ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                        ,vr_nro_conta
                        ,vr_p_ult_sequencia
                        ,'CRAP22'
                        ,vr_glb_dsdctitg
                        ,rw_cod_coop_orig.cdcooper
                        ,pr_cod_agencia
                        ,pr_nro_caixa
                        ,pr_cod_operador);              
              EXCEPTION
                 WHEN OTHERS THEN
                    pr_cdcritic := 0;
                    pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
                                  
                    cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                         ,pr_cdagenci => pr_cod_agencia
                                         ,pr_nrdcaixa => pr_nro_caixa
                                         ,pr_cod_erro => pr_cdcritic
                                         ,pr_dsc_erro => pr_dscritic
                                         ,pr_flg_erro => TRUE
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                    -- Levantar excecao
                    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                       pr_cdcritic := vr_cdcritic;
                       pr_dscritic := vr_dscritic; 
                       RAISE vr_exc_erro;
                    END IF;

                    RAISE vr_exc_erro;
              END;
              
              vr_i_seq_386 := rw_consulta_lot.nrseqdig;
     
              -- Verifica se existe lote
              OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                                ,rw_dat_cop.dtmvtocd
                                ,1   /* FIXO */
                                ,100 /* FIXO */
                                ,vr_i_nro_lote);
              FETCH cr_existe_lot INTO rw_existe_lot;
                 IF cr_existe_lot%FOUND THEN
                    -- Se nao existir cria a capa de lote
                    BEGIN
                       UPDATE craplot lot
                          SET lot.nrseqdig = lot.nrseqdig + 1
                             ,lot.qtcompln = lot.qtcompln + 1
                             ,lot.qtinfoln = lot.qtinfoln + 1
                             ,lot.vlcompcr = lot.vlcompcr + rw_verifica_mrw.vlchqcop
                             ,lot.vlinfocr = lot.vlinfocr + rw_verifica_mrw.vlchqcop
                        WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                          AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                          AND lot.cdagenci = 1
                          AND lot.cdbccxlt = 100
                          AND lot.nrdolote = vr_i_nro_lote;             
                    EXCEPTION
                       WHEN OTHERS THEN
                          pr_cdcritic := 0;
                          pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                           
                          cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                               ,pr_cdagenci => pr_cod_agencia
                                               ,pr_nrdcaixa => pr_nro_caixa
                                               ,pr_cod_erro => pr_cdcritic
                                               ,pr_dsc_erro => pr_dscritic
                                               ,pr_flg_erro => TRUE
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
                                               
                          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                             pr_cdcritic := vr_cdcritic;
                             pr_dscritic := vr_dscritic; 
                             RAISE vr_exc_erro;
                          END IF;

                          RAISE vr_exc_erro;
                    END;

                 END IF;

              CLOSE cr_existe_lot;             
              
           END IF;
                  
        END IF;
     CLOSE cr_verifica_mrw;
     
     vr_nrsequen := 0;
     
     -- Cheque MENOR PRACA
     vr_index := pr_typ_tab_chq.first(); -- Posiciona no primeiro registro
     WHILE vr_index IS NOT NULL LOOP
        IF pr_typ_tab_chq(vr_index).nrdocmto = 3 THEN
          
           /* Sequencial utilizado para separar um lançamento
           em conta para cada data nao ocorrendo duplicidade de chave */
           vr_nrsequen := vr_nrsequen + 1;
           vr_c_docto  := vr_c_docto_salvo || to_char(gene0002.fn_mask(pr_dsorigi => vr_nrsequen, pr_dsforma => '99' )) || pr_typ_tab_chq(vr_index).nrdocmto;
           
           /* Numero de sequencia sera utilizado para identificar cada
           cheque(crapchd) do lancamento total da data */
           pr_typ_tab_chq(vr_index).nrsequen := vr_nrsequen;
           
           -- Busca o ultima sequencia de digito
           OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                               ,rw_dat_cop.dtmvtocd
                               ,1   -- FIXO
                               ,100 -- FIXO
                               ,vr_i_nro_lote);
           FETCH cr_consulta_lot INTO rw_consulta_lot;
           CLOSE cr_consulta_lot;
              
           -- Verifica se Lancamento ja Existe no Dest.
           OPEN cr_existe_lcm(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,1
                             ,100
                             ,vr_i_nro_lote
                             ,rw_consulta_lot.nrseqdig); -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           FETCH cr_existe_lcm INTO rw_existe_lcm;
              IF cr_existe_lcm%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento  ja existente';
                                      
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;              
           CLOSE cr_existe_lcm;
              
           OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                              ,rw_dat_cop.dtmvtolt
                              ,1
                              ,100
                              ,vr_i_nro_lote
                              ,vr_nro_conta
                              ,vr_c_docto);
           FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
              IF cr_existe_lcm1%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento(Primario) ja existente';
                                     
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
           
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;              
            
           CLOSE cr_existe_lcm1;
              
           -- Chegou aqui eh porque nao existir lcm, entao cria registro de lcm
           BEGIN
              INSERT INTO craplcm(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,dsidenti
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrdocmto
                                 ,vllanmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,nrdctabb
                                 ,nrautdoc
                                 ,cdpesqbb
                                 ,nrdctitg
                                 ,cdcoptfn
                                 ,cdagetfn
                                 ,nrterfin
                                 ,cdoperad)
              VALUES (rw_cod_coop_dest.cdcooper
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,pr_identifica
                     ,vr_i_nro_lote
                     ,vr_nro_conta
                     ,TO_NUMBER(vr_c_docto)
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1526  /* 3 DEP.CHQ.PR. */
                     ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                     ,vr_nro_conta
                     ,vr_p_ult_sequencia
                     ,'CRAP22'
                     ,vr_glb_dsdctitg
                     ,rw_cod_coop_orig.cdcooper
                     ,pr_cod_agencia
                     ,pr_nro_caixa
                     ,pr_cod_operador);
                     
                     -- Guarda o sequencial usado no lancamento
                     pr_typ_tab_chq(vr_index).nrseqlcm := rw_consulta_lot.nrseqdig; -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;
                   
                   RAISE vr_exc_erro;
           END;
           
           -- Verifica se existe lote
           OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtocd
                             ,1   /* FIXO */
                             ,100 /* FIXO */
                             ,vr_i_nro_lote);
           FETCH cr_existe_lot INTO rw_existe_lot;
              IF cr_existe_lot%FOUND THEN
                 BEGIN
                    UPDATE craplot lot
                       SET lot.nrseqdig = lot.nrseqdig + 1
                          ,lot.qtcompln = lot.qtcompln + 1
                          ,lot.qtinfoln = lot.qtinfoln + 1
                          ,lot.vlcompcr = lot.vlcompcr + pr_typ_tab_chq(vr_index).vlcompel
                          ,lot.vlinfocr = lot.vlinfocr + pr_typ_tab_chq(vr_index).vlcompel
                     WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                       AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                       AND lot.cdagenci = 1
                       AND lot.cdbccxlt = 100
                       AND lot.nrdolote = vr_i_nro_lote;             
                 EXCEPTION
                    WHEN OTHERS THEN
                       pr_cdcritic := 0;
                       pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                  
                       cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                            ,pr_cdagenci => pr_cod_agencia
                                            ,pr_nrdcaixa => pr_nro_caixa
                                            ,pr_cod_erro => pr_cdcritic
                                            ,pr_dsc_erro => pr_dscritic
                                            ,pr_flg_erro => TRUE
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic); 
                       
                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          pr_cdcritic := vr_cdcritic;
                          pr_dscritic := vr_dscritic; 
                          RAISE vr_exc_erro;
                       END IF;
                       
                       RAISE vr_exc_erro;
                 END;
              END IF;
           CLOSE cr_existe_lot;
           
           -- Cria registro de Deposito Bloqueado
           BEGIN
              INSERT INTO crapdpb(nrdconta
                                 ,dtliblan
                                 ,cdhistor
                                 ,nrdocmto
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,vllanmto
                                 ,inlibera
                                 ,cdcooper)
              VALUES (vr_nro_conta
                     ,pr_typ_tab_chq(vr_index).dtlibcom
                     ,1526 -- 3
                     ,TO_NUMBER(vr_c_docto)
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,vr_i_nro_lote
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1
                     ,rw_cod_coop_dest.cdcooper);
           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPDPB : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;
                       
                   RAISE vr_exc_erro;
           END;
           
        END IF;        
        vr_index:= pr_typ_tab_chq.NEXT(vr_index); -- Proximo registro
        
     END LOOP; -- Fim cheques menor praca
     
     vr_nrsequen := 0;
     
     -- Cheque MAIOR PRACA
     vr_index := pr_typ_tab_chq.first(); -- Posiciona no primeiro registro
     WHILE vr_index IS NOT NULL LOOP
        IF pr_typ_tab_chq(vr_index).nrdocmto = 4 THEN
          
           /* Sequencial utilizado para separar um lançamento
           para cada data nao ocorrendo duplicidade de chave */

           vr_nrsequen := vr_nrsequen + 1;
           vr_c_docto  := vr_c_docto_salvo || to_char(gene0002.fn_mask(pr_dsorigi => vr_nrsequen, pr_dsforma => '99' )) || pr_typ_tab_chq(vr_index).nrdocmto;
           
           pr_typ_tab_chq(vr_index).nrsequen := vr_nrsequen;
           
           -- Busca o ultima sequencia de digito
           OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                               ,rw_dat_cop.dtmvtocd
                               ,1   -- FIXO
                               ,100 -- FIXO
                               ,vr_i_nro_lote);
           FETCH cr_consulta_lot INTO rw_consulta_lot;
           CLOSE cr_consulta_lot;
              
           -- Verifica se Lancamento ja Existe no Dest.
           OPEN cr_existe_lcm(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,1
                             ,100
                             ,vr_i_nro_lote
                             ,rw_consulta_lot.nrseqdig); -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           FETCH cr_existe_lcm INTO rw_existe_lcm;
              IF cr_existe_lcm%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento  ja existente';
                                      
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;
                       
                 RAISE vr_exc_erro;
              END IF;              
           CLOSE cr_existe_lcm;
              
           OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                              ,rw_dat_cop.dtmvtolt
                              ,1
                              ,100
                              ,vr_i_nro_lote
                              ,vr_nro_conta
                              ,vr_c_docto);
           FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
              IF cr_existe_lcm1%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento(Primario) ja existente';
                                     
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
           
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;
                       
                 RAISE vr_exc_erro;
              END IF;            
           CLOSE cr_existe_lcm1;
              
           -- Chegou aqui eh porque nao existir lcm, entao cria registro de lcm
           BEGIN
              INSERT INTO craplcm(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,dsidenti
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrdocmto
                                 ,vllanmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,nrdctabb
                                 ,nrautdoc
                                 ,cdpesqbb
                                 ,nrdctitg
                                 ,cdcoptfn
                                 ,cdagetfn
                                 ,nrterfin
                                 ,cdoperad)
              VALUES (rw_cod_coop_dest.cdcooper
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,pr_identifica
                     ,vr_i_nro_lote
                     ,vr_nro_conta
                     ,TO_NUMBER(vr_c_docto)
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1526  /* 3 DEP.CHQ.PR. */
                     ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                     ,vr_nro_conta
                     ,vr_p_ult_sequencia
                     ,'CRAP22'
                     ,vr_glb_dsdctitg
                     ,rw_cod_coop_orig.cdcooper
                     ,pr_cod_agencia
                     ,pr_nro_caixa
                     ,pr_cod_operador);
                     
                     -- Guarda o sequencial usado no lancamento
                     pr_typ_tab_chq(vr_index).nrseqlcm := rw_consulta_lot.nrseqdig; -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;
                        
                   RAISE vr_exc_erro;
           END;
           
           -- Verifica se existe lote
           OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtocd
                             ,1   /* FIXO */
                             ,100 /* FIXO */
                             ,vr_i_nro_lote);
           FETCH cr_existe_lot INTO rw_existe_lot;
              IF cr_existe_lot%FOUND THEN
                 BEGIN
                    UPDATE craplot lot
                       SET lot.nrseqdig = lot.nrseqdig + 1
                          ,lot.qtcompln = lot.qtcompln + 1
                          ,lot.qtinfoln = lot.qtinfoln + 1
                          ,lot.vlcompcr = lot.vlcompcr + pr_typ_tab_chq(vr_index).vlcompel
                          ,lot.vlinfocr = lot.vlinfocr + pr_typ_tab_chq(vr_index).vlcompel
                     WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                       AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                       AND lot.cdagenci = 1
                       AND lot.cdbccxlt = 100
                       AND lot.nrdolote = vr_i_nro_lote;             
                 EXCEPTION
                    WHEN OTHERS THEN
                       pr_cdcritic := 0;
                       pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                  
                       cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                            ,pr_cdagenci => pr_cod_agencia
                                            ,pr_nrdcaixa => pr_nro_caixa
                                            ,pr_cod_erro => pr_cdcritic
                                            ,pr_dsc_erro => pr_dscritic
                                            ,pr_flg_erro => TRUE
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic); 
                       
                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          pr_cdcritic := vr_cdcritic;
                          pr_dscritic := vr_dscritic; 
                          RAISE vr_exc_erro;
                       END IF;
                        
                       RAISE vr_exc_erro;
                 END;
              END IF;
           CLOSE cr_existe_lot;
           
           -- Cria registro de Deposito Bloqueado
           BEGIN
              INSERT INTO crapdpb(nrdconta
                                 ,dtliblan
                                 ,cdhistor
                                 ,nrdocmto
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,vllanmto
                                 ,inlibera
                                 ,cdcooper)
              VALUES (vr_nro_conta
                     ,pr_typ_tab_chq(vr_index).dtlibcom
                     ,1526 -- 3
                     ,TO_NUMBER(vr_c_docto)
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,vr_i_nro_lote
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1
                     ,rw_cod_coop_dest.cdcooper);
           
           EXCEPTION
              WHEN OTHERS THEN
                   vr_cdcritic := 0;
                   vr_dscritic := 'Erro ao inserir na CRAPDPB: '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => vr_cdcritic
                                        ,pr_dsc_erro => vr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;
                       
                   RAISE vr_exc_erro;
           END;           
        END IF;        
        vr_index:= pr_typ_tab_chq.NEXT(vr_index); -- Proximo registro
        
     END LOOP; -- Fim cheques maior praca
     
     vr_nrsequen := 0;
     
     -- Cheque MENOR FORA PRACA
     vr_index := pr_typ_tab_chq.first(); -- Posiciona no primeiro registro
     WHILE vr_index IS NOT NULL LOOP
        IF pr_typ_tab_chq(vr_index).nrdocmto = 5 THEN
          
           /* Sequencial utilizado para separar um lançamento
           para cada data nao ocorrendo duplicidade de chave */


           vr_nrsequen := vr_nrsequen + 1;
           vr_c_docto  := vr_c_docto_salvo || to_char(gene0002.fn_mask(pr_dsorigi => vr_nrsequen, pr_dsforma => '99' )) || pr_typ_tab_chq(vr_index).nrdocmto;
           pr_typ_tab_chq(vr_index).nrsequen := vr_nrsequen;
           
           -- Busca o ultima sequencia de digito
           OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                               ,rw_dat_cop.dtmvtocd
                               ,1   -- FIXO
                               ,100 -- FIXO
                               ,vr_i_nro_lote);
           FETCH cr_consulta_lot INTO rw_consulta_lot;
           CLOSE cr_consulta_lot;
              
           -- Verifica se Lancamento ja Existe no Dest.
           OPEN cr_existe_lcm(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,1
                             ,100
                             ,vr_i_nro_lote
                             ,rw_consulta_lot.nrseqdig); -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           FETCH cr_existe_lcm INTO rw_existe_lcm;
              IF cr_existe_lcm%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento  ja existente';
                                      
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;
                       
                 RAISE vr_exc_erro;
              END IF;              
           CLOSE cr_existe_lcm;
              
           OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                              ,rw_dat_cop.dtmvtolt
                              ,1
                              ,100
                              ,vr_i_nro_lote
                              ,vr_nro_conta
                              ,vr_c_docto);
           FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
              IF cr_existe_lcm1%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento(Primario) ja existente';
                                     
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
           
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;
                       
                 RAISE vr_exc_erro;
              END IF;            
           CLOSE cr_existe_lcm1;
              
           -- Chegou aqui eh porque nao existir lcm, entao cria registro de lcm
           BEGIN
              INSERT INTO craplcm(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,dsidenti
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrdocmto
                                 ,vllanmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,nrdctabb
                                 ,nrautdoc
                                 ,cdpesqbb
                                 ,nrdctitg
                                 ,cdcoptfn
                                 ,cdagetfn
                                 ,nrterfin
                                 ,cdoperad)
              VALUES (rw_cod_coop_dest.cdcooper
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,pr_identifica
                     ,vr_i_nro_lote
                     ,vr_nro_conta
                     ,TO_NUMBER(vr_c_docto)
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1523  /** 4 - DEP.CHQ.FPR. **/
                     ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                     ,vr_nro_conta
                     ,vr_p_ult_sequencia
                     ,'CRAP22'
                     ,vr_glb_dsdctitg
                     ,rw_cod_coop_orig.cdcooper
                     ,pr_cod_agencia
                     ,pr_nro_caixa
                     ,pr_cod_operador);
                                          
                     -- Guarda o sequencial usado no lancamento
                     pr_typ_tab_chq(vr_index).nrseqlcm := rw_consulta_lot.nrseqdig; -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;
                       
                   RAISE vr_exc_erro;
           END;
           
           -- Verifica se existe lote
           OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtocd
                             ,1   /* FIXO */
                             ,100 /* FIXO */
                             ,vr_i_nro_lote);
           FETCH cr_existe_lot INTO rw_existe_lot;
              IF cr_existe_lot%FOUND THEN
                 BEGIN
                    UPDATE craplot lot
                       SET lot.nrseqdig = lot.nrseqdig + 1
                          ,lot.qtcompln = lot.qtcompln + 1
                          ,lot.qtinfoln = lot.qtinfoln + 1
                          ,lot.vlcompcr = lot.vlcompcr + pr_typ_tab_chq(vr_index).vlcompel
                          ,lot.vlinfocr = lot.vlinfocr + pr_typ_tab_chq(vr_index).vlcompel
                     WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                       AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                       AND lot.cdagenci = 1
                       AND lot.cdbccxlt = 100
                       AND lot.nrdolote = vr_i_nro_lote;             
                 EXCEPTION
                    WHEN OTHERS THEN
                       vr_cdcritic := 0;
                       vr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                  
                       cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                            ,pr_cdagenci => pr_cod_agencia
                                            ,pr_nrdcaixa => pr_nro_caixa
                                            ,pr_cod_erro => vr_cdcritic
                                            ,pr_dsc_erro => vr_dscritic
                                            ,pr_flg_erro => TRUE
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          pr_cdcritic := vr_cdcritic;
                          pr_dscritic := vr_dscritic; 
                          RAISE vr_exc_erro;
                       END IF;                       

                       RAISE vr_exc_erro;
                 END;
              END IF;
           CLOSE cr_existe_lot;
           
           -- Cria registro de Deposito Bloqueado
           BEGIN
              INSERT INTO crapdpb(nrdconta
                                 ,dtliblan
                                 ,cdhistor
                                 ,nrdocmto
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,vllanmto
                                 ,inlibera
                                 ,cdcooper)
              VALUES (vr_nro_conta
                     ,pr_typ_tab_chq(vr_index).dtlibcom
                     ,1523 -- 4
                     ,TO_NUMBER(vr_c_docto)
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,vr_i_nro_lote
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1
                     ,rw_cod_coop_dest.cdcooper);                                
           EXCEPTION
              WHEN OTHERS THEN
                   vr_cdcritic := 0;
                   vr_dscritic := 'Erro ao inserir na CRAPDPB : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => vr_cdcritic
                                        ,pr_dsc_erro => vr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;                       

                   RAISE vr_exc_erro;
           END;
           
        END IF;        
        vr_index:= pr_typ_tab_chq.NEXT(vr_index); -- Proximo registro
        
     END LOOP; -- Fim cheques menor fora praca
     
     vr_nrsequen := 0;
     
     -- Cheque MAIOR FORA PRACA
     vr_index := pr_typ_tab_chq.first(); -- Posiciona no primeiro registro
     WHILE vr_index IS NOT NULL LOOP
        IF pr_typ_tab_chq(vr_index).nrdocmto = 6 THEN

           /* Sequencial utilizado para separar um lançamento
           para cada data nao ocorrendo duplicidade de chave */

           vr_nrsequen := vr_nrsequen + 1;
           vr_c_docto  := vr_c_docto_salvo || to_char(gene0002.fn_mask(pr_dsorigi => vr_nrsequen, pr_dsforma => '99' )) || pr_typ_tab_chq(vr_index).nrdocmto;
           pr_typ_tab_chq(vr_index).nrsequen := vr_nrsequen;

           -- Busca o ultima sequencia de digito
           OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                               ,rw_dat_cop.dtmvtocd
                               ,1   -- FIXO
                               ,100 -- FIXO
                               ,vr_i_nro_lote);
           FETCH cr_consulta_lot INTO rw_consulta_lot;
           CLOSE cr_consulta_lot;

           -- Verifica se Lancamento ja Existe no Dest.
           OPEN cr_existe_lcm(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,1
                             ,100
                             ,vr_i_nro_lote
                             ,rw_consulta_lot.nrseqdig); -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           FETCH cr_existe_lcm INTO rw_existe_lcm;
              IF cr_existe_lcm%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento  ja existente';

                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;                       

                 RAISE vr_exc_erro;
              END IF;              
           CLOSE cr_existe_lcm;

           OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                              ,rw_dat_cop.dtmvtolt
                              ,1
                              ,100
                              ,vr_i_nro_lote
                              ,vr_nro_conta
                              ,vr_c_docto);
           FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
              IF cr_existe_lcm1%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento(Primario) ja existente';
                                    
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;                       

                 RAISE vr_exc_erro;
              END IF;            
           CLOSE cr_existe_lcm1;
              
           -- Chegou aqui eh porque nao existir lcm, entao cria registro de lcm
           BEGIN
              INSERT INTO craplcm(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,dsidenti
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrdocmto
                                 ,vllanmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,nrdctabb
                                 ,nrautdoc
                                 ,cdpesqbb
                                 ,nrdctitg
                                 ,cdcoptfn
                                 ,cdagetfn
                                 ,nrterfin
                                 ,cdoperad)
              VALUES (rw_cod_coop_dest.cdcooper
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,pr_identifica
                     ,vr_i_nro_lote
                     ,vr_nro_conta
                     ,TO_NUMBER(vr_c_docto)
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1523  /** 4 - DEP.CHQ.FPR. **/
                     ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                     ,vr_nro_conta
                     ,vr_p_ult_sequencia
                     ,'CRAP22'
                     ,vr_glb_dsdctitg
                     ,rw_cod_coop_orig.cdcooper
                     ,pr_cod_agencia
                     ,pr_nro_caixa
                     ,pr_cod_operador);

                     -- Guarda o sequencial usado no lancamento
                     pr_typ_tab_chq(vr_index).nrseqlcm := rw_consulta_lot.nrseqdig; -- Já está encrementado + 1 no CURSOR cr_consulta_lot

           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;

                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
           END;

           -- Verifica se existe lote
           OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtocd
                             ,1   /* FIXO */
                             ,100 /* FIXO */
                             ,vr_i_nro_lote);
           FETCH cr_existe_lot INTO rw_existe_lot;
              IF cr_existe_lot%FOUND THEN
                 BEGIN
                    UPDATE craplot lot
                       SET lot.nrseqdig = lot.nrseqdig + 1
                          ,lot.qtcompln = lot.qtcompln + 1
                          ,lot.qtinfoln = lot.qtinfoln + 1
                          ,lot.vlcompcr = lot.vlcompcr + pr_typ_tab_chq(vr_index).vlcompel
                          ,lot.vlinfocr = lot.vlinfocr + pr_typ_tab_chq(vr_index).vlcompel
                     WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                       AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                       AND lot.cdagenci = 1
                       AND lot.cdbccxlt = 100
                       AND lot.nrdolote = vr_i_nro_lote;             
                 EXCEPTION
                    WHEN OTHERS THEN
                       pr_cdcritic := 0;
                       pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                  
                       cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                            ,pr_cdagenci => pr_cod_agencia
                                            ,pr_nrdcaixa => pr_nro_caixa
                                            ,pr_cod_erro => pr_cdcritic
                                            ,pr_dsc_erro => pr_dscritic
                                            ,pr_flg_erro => TRUE
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          pr_cdcritic := vr_cdcritic;
                          pr_dscritic := vr_dscritic; 
                          RAISE vr_exc_erro;
                       END IF;

                       RAISE vr_exc_erro;
                 END;                 
              END IF;
              
           CLOSE cr_existe_lot;
           
           -- Cria registro de Deposito Bloqueado
           BEGIN
              INSERT INTO crapdpb(nrdconta
                                 ,dtliblan
                                 ,cdhistor
                                 ,nrdocmto
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,vllanmto
                                 ,inlibera
                                 ,cdcooper)
              VALUES (vr_nro_conta
                     ,pr_typ_tab_chq(vr_index).dtlibcom
                     ,1523 -- 4
                     ,TO_NUMBER(vr_c_docto)
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,vr_i_nro_lote
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1
                     ,rw_cod_coop_dest.cdcooper);           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao atualizar na CRAPDPB : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
           END;
           
        END IF;        
        vr_index:= pr_typ_tab_chq.NEXT(vr_index); -- Proximo registro
        
     END LOOP; -- Fim cheques maior fora praca
     
     -- Criacao do LOTE de ORIGEM (DEBITO)
     vr_i_nro_lote    := 11000 + pr_nro_caixa;
     
     -- Verifica se existe lote
     OPEN cr_existe_lot(rw_cod_coop_orig.cdcooper
                       ,rw_dat_cop.dtmvtocd
                       ,pr_cod_agencia   /* FIXO */
                       ,11 /* FIXO */
                       ,vr_i_nro_lote);
     FETCH cr_existe_lot INTO rw_existe_lot;
        IF cr_existe_lot%NOTFOUND THEN
           -- Se nao existir cria a capa de lote
           BEGIN
              INSERT INTO craplot(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,tplotmov
                                 ,nrdcaixa
                                 ,cdopecxa
                                 ,cdhistor
                                 ,cdoperad)
              VALUES (rw_cod_coop_orig.cdcooper
                     ,rw_dat_cop.dtmvtocd
                     ,pr_cod_agencia
                     ,11
                     ,vr_i_nro_lote
                     ,1
                     ,pr_nro_caixa
                     ,pr_cod_operador
                     ,0
                     ,pr_cod_operador);
           EXCEPTION
              WHEN OTHERS THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Erro ao inserir na CRAPLOT: '||sqlerrm;
                                  
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
           END;
        END IF;
     CLOSE cr_existe_lot;
     
     /*** Criacao da CHD - Cheques Acolhidos  ***/
     FOR rw_verifica_mdw IN cr_verifica_mdw(rw_cod_coop_orig.cdcooper
                                           ,pr_cod_agencia
                                           ,pr_nro_caixa) LOOP
                                           
         -- Busca o ultima sequencia de digito
         OPEN cr_consulta_lot(rw_cod_coop_orig.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,pr_cod_agencia   /* FIXO */
                             ,11 /* FIXO */
                             ,vr_i_nro_lote);
         FETCH cr_consulta_lot INTO rw_consulta_lot;
         CLOSE cr_consulta_lot;
                                           
         -- Formata conta integracao
         GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => rw_verifica_mdw.nrctabdb
                                       ,pr_dscalcul => vr_dsdctitg
                                       ,pr_stsnrcal => vr_stsnrcal
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
                                       
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
            RAISE vr_exc_erro;
         END IF;
                                       
         OPEN cr_consulta_chd(rw_cod_coop_orig.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,rw_verifica_mdw.cdcmpchq
                             ,rw_verifica_mdw.cdbanchq
                             ,rw_verifica_mdw.cdagechq
                             ,rw_verifica_mdw.nrctachq
                             ,rw_verifica_mdw.nrcheque);
         FETCH cr_consulta_chd INTO rw_consulta_chd;
            IF cr_consulta_chd%FOUND THEN
              
               pr_cdcritic := 92;
               pr_dscritic := '';

               cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                    ,pr_cdagenci => pr_cod_agencia
                                    ,pr_nrdcaixa => pr_nro_caixa
                                    ,pr_cod_erro => pr_cdcritic
                                    ,pr_dsc_erro => pr_dscritic
                                    ,pr_flg_erro => TRUE
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
               
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  pr_cdcritic := vr_cdcritic;
                  pr_dscritic := vr_dscritic; 
                  RAISE vr_exc_erro;
               END IF;

               RAISE vr_exc_erro;
                                    
            ELSE -- Nao encontrou registro CHD. Entao cria registro
                                    
               IF rw_verifica_mdw.cdhistor = 386 THEN -- DEP.CHQ.COOP.
                  vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo ||'02'||'2');
               END IF;
               
               -- Encontrou registro
               IF pr_typ_tab_chq.exists(TO_CHAR(rw_verifica_mdw.dtlibcom,'DD/MM/RRRR')||
                                        TO_CHAR(LPAD(rw_verifica_mdw.nrdocmto,10,0))) THEN
                  -- Montar chave de busca
                  vr_index :=  TO_CHAR(rw_verifica_mdw.dtlibcom,'DD/MM/RRRR')||
                               TO_CHAR(LPAD(rw_verifica_mdw.nrdocmto,10,0));

                  IF rw_verifica_mdw.cdhistor = 3 THEN -- PRACA MENOR
                     IF rw_verifica_mdw.tpdmovto = 2 THEN
                        vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo||to_char(gene0002.fn_mask(pr_dsorigi => pr_typ_tab_chq(vr_index).nrsequen, pr_dsforma => '99' ))||'3');
                     ELSE
                        vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo||to_char(gene0002.fn_mask(pr_dsorigi => pr_typ_tab_chq(vr_index).nrsequen, pr_dsforma => '99' ))||'4');
                     END IF;
                  ELSE
                     IF rw_verifica_mdw.cdhistor = 4 THEN -- FORA PRACA MENOR
                        IF rw_verifica_mdw.tpdmovto = 2 THEN
                           vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo||to_char(gene0002.fn_mask(pr_dsorigi => pr_typ_tab_chq(vr_index).nrsequen, pr_dsforma => '99' ))||'5');
                        ELSE
                           vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo||to_char(gene0002.fn_mask(pr_dsorigi => pr_typ_tab_chq(vr_index).nrsequen, pr_dsforma => '99' ))||'6');
                        END IF;
                     END IF;
                  END IF;
                  
                  IF rw_verifica_mdw.cdhistor <> 386 THEN
                     vr_aux_nrseqdig := pr_typ_tab_chq(vr_index).nrseqlcm;
                  END IF;
                  
               END IF;
               
               IF rw_verifica_mdw.nrctaaux > 0 THEN 
                  vr_aux_inchqcop := 1;
               ELSE
                  vr_aux_inchqcop := 0;
               END IF;
               
               IF NVL(rw_consulta_chd.insitchq,0) = 1 THEN
                  vr_aux_nrctachq := rw_verifica_mdw.nrctabdb;
               ELSE
                  vr_aux_nrctachq := rw_verifica_mdw.nrctachq;
               END IF;
               
               IF rw_verifica_mdw.cdhistor = 386 THEN
                  vr_aux_nrseqdig := vr_i_seq_386;
               ELSE
                  
                  /** Incrementa contagem de cheques para a previa **/
                  CXON0000.pc_atualiza_previa_cxa(pr_cooper       => pr_cooper
                                        ,pr_cod_agencia  => pr_cod_agencia
                                        ,pr_nro_caixa    => pr_nro_caixa
                                        ,pr_cod_operador => pr_cod_operador
                                        ,pr_dtmvtolt     => rw_dat_cop.dtmvtolt
                                        ,pr_operacao     => 1 -- Inclusao
                                        ,pr_retorno      => pr_retorno
                                        ,pr_cdcritic     => vr_cdcritic
                                        ,pr_dscritic     => vr_dscritic);
                                        
                  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                     pr_cdcritic := vr_cdcritic;
                     pr_dscritic := vr_dscritic;
                         
                     cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                          ,pr_cdagenci => pr_cod_agencia
                                          ,pr_nrdcaixa => pr_nro_caixa
                                          ,pr_cod_erro => pr_cdcritic
                                          ,pr_dsc_erro => pr_dscritic
                                          ,pr_flg_erro => TRUE
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
                                                
                     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                        pr_cdcritic := vr_cdcritic;
                        pr_dscritic := vr_dscritic; 
                        RAISE vr_exc_erro;
                     END IF;

                     RAISE vr_exc_erro; 
                           
                  END IF;   
                               
               END IF;
               
               vr_aux_nrddigv1 := TO_NUMBER(TO_CHAR(gene0002.fn_busca_entrada(1,rw_verifica_mdw.lsdigctr,',')));
               vr_aux_nrddigv2 := TO_NUMBER(TO_CHAR(gene0002.fn_busca_entrada(2,rw_verifica_mdw.lsdigctr,',')));
               vr_aux_nrddigv3 := TO_NUMBER(TO_CHAR(gene0002.fn_busca_entrada(3,rw_verifica_mdw.lsdigctr,',')));
               
               /** Criacao CHD na Acolhedora **/
               BEGIN
                  INSERT INTO crapchd(cdcooper
                                     ,cdagechq
                                     ,cdbanchq
                                     ,cdagenci
                                     ,cdbccxlt
                                     ,nrdocmto
                                     ,cdcmpchq
                                     ,cdoperad
                                     ,cdsitatu
                                     ,dsdocmc7
                                     ,dtmvtolt
                                     ,inchqcop
                                     ,insitchq
                                     ,cdtipchq
                                     ,nrcheque
                                     ,nrctachq
                                     ,nrdconta
                                     ,nrddigc1
                                     ,nrddigc2
                                     ,nrddigc3
                                     ,nrddigv1
                                     ,nrddigv2
                                     ,nrddigv3
                                     ,nrdolote
                                     ,tpdmovto
                                     ,nrterfin
                                     ,vlcheque
                                     ,cdagedst
                                     ,nrctadst
                                     ,nrseqdig)
                  VALUES (rw_cod_coop_orig.cdcooper
                         ,rw_verifica_mdw.cdagechq
                         ,rw_verifica_mdw.cdbanchq
                         ,pr_cod_agencia
                         ,11
                         ,TO_NUMBER(vr_i_nro_docto)
                         ,rw_verifica_mdw.cdcmpchq
                         ,pr_cod_operador
                         ,1
                         ,rw_verifica_mdw.dsdocmc7
                         ,rw_dat_cop.dtmvtolt
                         ,vr_aux_inchqcop
                         ,0
                         ,rw_verifica_mdw.cdtipchq
                         ,rw_verifica_mdw.nrcheque
                         ,vr_aux_nrctachq
                         ,vr_nro_conta
                         ,rw_verifica_mdw.nrddigc1
                         ,rw_verifica_mdw.nrddigc2
                         ,rw_verifica_mdw.nrddigc3
                         ,vr_aux_nrddigv1
                         ,vr_aux_nrddigv2
                         ,vr_aux_nrddigv3
                         ,vr_i_nro_lote
                         ,rw_verifica_mdw.tpdmovto
                         ,0
                         ,rw_verifica_mdw.vlcompel
                         ,rw_cod_coop_dest.cdagectl /* Dep.Intercoop. */
                         ,vr_nro_conta /* Dep.Intercoop. */
                         ,vr_aux_nrseqdig)  /* Sequencia dos lancamentos */
                  RETURNING ROWID
                       INTO vr_rowid_chd;
               EXCEPTION
                  WHEN OTHERS THEN
                       pr_cdcritic := 0;
                       pr_dscritic := 'Erro ao inserir na CRAPCHQ: '||sqlerrm;
                                      
                       cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                            ,pr_cdagenci => pr_cod_agencia
                                            ,pr_nrdcaixa => pr_nro_caixa
                                            ,pr_cod_erro => pr_cdcritic
                                            ,pr_dsc_erro => pr_dscritic
                                            ,pr_flg_erro => TRUE
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
                       -- Levantar excecao
                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          pr_cdcritic := vr_cdcritic;
                          pr_dscritic := vr_dscritic; 
                          RAISE vr_exc_erro;
                       END IF;

                       RAISE vr_exc_erro; 
               END;
               
            END IF;
         CLOSE cr_consulta_chd;
         
         /** Cheques Nao Coop - Vai p/ Proximo MDW **/
         IF rw_verifica_mdw.cdhistor <> 386 THEN
            NULL;
         ELSE
            
            /* Efetua Lancamentos de DEBITO nos CHEQUES COOP */
            /* guarda infos da ultima autenticacao 700 */            

            vr_aux_p_literal  := vr_p_literal;
            vr_aux_p_ult_seq  := vr_p_ult_sequencia;
            vr_aux_p_registro := vr_p_registro;
            
            CXON0051.pc_autentica_cheque(pr_cooper          => pr_cooper
                                        ,pr_cod_agencia     => pr_cod_agencia
                                        ,pr_nro_conta       => vr_nro_conta
                                        ,pr_vestorno        => pr_vestorno
                                        ,pr_nro_caixa       => pr_nro_caixa
                                        ,pr_cod_operador    => pr_cod_operador
                                        ,pr_dtmvtolt        => rw_dat_cop.dtmvtolt
                                        ,pr_nro_docmto      => pr_nro_docmto
                                        ,pr_rowid           => rw_verifica_mdw.rowid
                                        ,pr_p_literal       => vr_p_literal
                                        ,pr_p_ult_sequencia => vr_p_ult_sequencia
                                        ,pr_retorno         => pr_retorno       
                                        ,pr_cdcritic        => vr_cdcritic
                                        ,pr_dscritic        => vr_dscritic);
            
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := vr_dscritic;
               RAISE vr_exc_erro;
            END IF;

            -- volta infos da ultima autenticacao 700
            vr_p_literal         := vr_aux_p_literal;
            vr_p_ult_sequencia   := vr_aux_p_ult_seq;
            vr_p_registro        := vr_aux_p_registro;
            
             -- Busca o nro da autenticacao
            OPEN cr_nrautdoc_mdw(rw_verifica_mdw.rowid);
            FETCH cr_nrautdoc_mdw INTO rw_nrautdoc_mdw;
            CLOSE cr_nrautdoc_mdw;
            
            -- Formata conta integracao
            GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => vr_nro_conta
                                          ,pr_dscalcul => vr_dsdctitg
                                          ,pr_stsnrcal => vr_stsnrcal
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
            -- Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := vr_dscritic;

               cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                    ,pr_cdagenci => pr_cod_agencia
                                    ,pr_nrdcaixa => pr_nro_caixa
                                    ,pr_cod_erro => pr_cdcritic
                                    ,pr_dsc_erro => pr_dscritic
                                    ,pr_flg_erro => TRUE
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  pr_cdcritic := vr_cdcritic;
                  pr_dscritic := vr_dscritic; 
                  RAISE vr_exc_erro;
               END IF;

               RAISE vr_exc_erro;
            END IF;
            
            OPEN cr_rowid_chd(vr_rowid_chd);
            FETCH cr_rowid_chd INTO rw_rowid_chd;
            CLOSE cr_rowid_chd; 
            
            OPEN cr_verifica_fdc(rw_rowid_chd.cdcooper
                                ,rw_rowid_chd.cdbanchq
                                ,rw_rowid_chd.cdagechq
                                ,rw_rowid_chd.nrctachq
                                ,rw_rowid_chd.nrcheque);
            FETCH cr_verifica_fdc INTO rw_verifica_fdc;
               IF cr_verifica_fdc%FOUND THEN
                  BEGIN
                    
                    /* Atualiza os campos de acordo com o tipo
                    da conta do associado que recebe o cheque */
                    
                    IF rw_verifica_ass.cdtipcta >= 8  AND
                       rw_verifica_ass.cdtipcta <= 11 THEN                       
                       
                       IF rw_verifica_ass.cdbcochq = 756 THEN -- BANCOOB
                          vr_aux_cdbandep := 756;
                          vr_aux_cdagedep := rw_cod_coop_dest.cdagebcb;
                       ELSE
                          vr_aux_cdbandep := rw_cod_coop_dest.cdbcoctl;
                          vr_aux_cdagedep := rw_cod_coop_dest.cdagectl;
                       END IF;
                    ELSE
                       -- BANCO DO BRASIL - SEM DIGITO
                       vr_aux_cdbandep := 1;
                       vr_aux_cdagedep := SUBSTR(rw_cod_coop_dest.cdagedbb,LENGTH(rw_cod_coop_dest.cdagedbb)-1);
                    END IF;                      
                  
                    UPDATE crapfdc fdc
                       SET fdc.incheque = fdc.incheque + 5
                          ,fdc.dtliqchq = rw_dat_cop.dtmvtolt
                          ,fdc.cdoperad = pr_cod_operador
                          ,fdc.vlcheque = rw_verifica_mdw.vlcompel
                          ,fdc.nrctadep = pr_nro_conta
                          ,fdc.cdbandep = vr_aux_cdbandep
                          ,fdc.cdagedep = vr_aux_cdagedep
                     WHERE fdc.cdcooper = rw_rowid_chd.cdcooper
                       AND fdc.cdbanchq = rw_rowid_chd.cdbanchq
                       AND fdc.cdagechq = rw_rowid_chd.cdagechq
                       AND fdc.nrctachq = rw_rowid_chd.nrctachq
                       AND fdc.nrcheque = rw_rowid_chd.nrcheque;              
                  EXCEPTION
                     WHEN OTHERS THEN
                        pr_cdcritic := 0;
                        pr_dscritic := 'Erro ao atualizar CRAPFDC : '||sqlerrm;
                                         
                        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                             ,pr_cdagenci => pr_cod_agencia
                                             ,pr_nrdcaixa => pr_nro_caixa
                                             ,pr_cod_erro => pr_cdcritic
                                             ,pr_dsc_erro => pr_dscritic
                                             ,pr_flg_erro => TRUE
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
                                             
                        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                           pr_cdcritic := vr_cdcritic;
                           pr_dscritic := vr_dscritic; 
                           RAISE vr_exc_erro;
                        END IF;

                        RAISE vr_exc_erro;
                  END;
                  
                  /* Pagamento Cheque */
                  BEGIN
                           
                     IF  rw_verifica_fdc.tpcheque = 1  THEN
                         vr_aux_cdhistor := 21;
                     ELSE
                         vr_aux_cdhistor := 26;
                     END IF;

                     INSERT INTO craplcm(cdcooper
                                        ,dtmvtolt
                                        ,cdagenci
                                        ,cdbccxlt
                                        ,dsidenti
                                        ,nrdolote
                                        ,nrdconta
                                        ,nrdocmto
                                        ,vllanmto
                                        ,cdhistor
                                        ,nrseqdig
                                        ,nrdctabb
                                        ,nrautdoc
                                        ,cdpesqbb
                                        ,nrdctitg)
                     VALUES (rw_cod_coop_orig.cdcooper
                            ,rw_dat_cop.dtmvtolt
                            ,pr_cod_agencia
                            ,11
                            ,pr_identifica
                            ,vr_i_nro_lote
                            ,rw_verifica_mdw.nrctaaux
                            ,TO_NUMBER(rw_verifica_mdw.nrcheque||rw_verifica_mdw.nrddigc3)
                            ,rw_verifica_mdw.vlcompel
                            ,vr_aux_cdhistor
                            ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                            ,rw_verifica_mdw.nrctabdb
                            ,rw_nrautdoc_mdw.nrautdoc
                            ,'CRAP22,'||rw_verifica_mdw.cdopelib
                            ,vr_dsdctitg);
                  EXCEPTION
                     WHEN OTHERS THEN
                          pr_cdcritic := 0;
                          pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
             
                          cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                               ,pr_cdagenci => pr_cod_agencia
                                               ,pr_nrdcaixa => pr_nro_caixa
                                               ,pr_cod_erro => pr_cdcritic
                                               ,pr_dsc_erro => pr_dscritic
                                               ,pr_flg_erro => TRUE
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
                          -- Levantar excecao
                          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                             pr_cdcritic := vr_cdcritic;
                             pr_dscritic := vr_dscritic; 
                             RAISE vr_exc_erro;
                          END IF;

                          RAISE vr_exc_erro;
                  END;

                  -- Verifica se existe lote
                  OPEN cr_existe_lot(rw_cod_coop_orig.cdcooper
                                    ,rw_dat_cop.dtmvtocd
                                    ,pr_cod_agencia   /* FIXO */
                                    ,11 /* FIXO */
                                    ,vr_i_nro_lote);
                  FETCH cr_existe_lot INTO rw_existe_lot;
                     IF cr_existe_lot%FOUND THEN
                        BEGIN
                           UPDATE craplot lot
                              SET lot.nrseqdig = lot.nrseqdig + 1
                                 ,lot.qtcompln = lot.qtcompln + 1
                                 ,lot.qtinfoln = lot.qtinfoln + 1
                                 ,lot.vlcompdb = lot.vlcompdb + rw_verifica_mdw.vlcompel
                                 ,lot.vlinfodb = lot.vlinfodb + rw_verifica_mdw.vlcompel
                            WHERE lot.cdcooper = rw_cod_coop_orig.cdcooper
                              AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                              AND lot.cdagenci = pr_cod_agencia
                              AND lot.cdbccxlt = 11
                              AND lot.nrdolote = vr_i_nro_lote;             
                        EXCEPTION
                           WHEN OTHERS THEN
                              pr_cdcritic := 0;
                              pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                               
                              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                   ,pr_cdagenci => pr_cod_agencia
                                                   ,pr_nrdcaixa => pr_nro_caixa
                                                   ,pr_cod_erro => pr_cdcritic
                                                   ,pr_dsc_erro => pr_dscritic
                                                   ,pr_flg_erro => TRUE
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);
                                                   
                              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                 pr_cdcritic := vr_cdcritic;
                                 pr_dscritic := vr_dscritic; 
                                 RAISE vr_exc_erro;
                              END IF;

                              RAISE vr_exc_erro;
                        END;                 
                           
                     END IF;
                  CLOSE cr_existe_lot;
                  
               ELSE -- Nao encontrou regsitro fdc
                 
                  IF cr_verifica_fdc%ISOPEN THEN
                     CLOSE cr_verifica_fdc;
                  END IF;

                  /* verifica se o cheque eh da cooperativa migrada */
                  OPEN cr_verifica_fdc(rw_cod_coop_migr.cdcooper
                                      ,rw_rowid_chd.cdbanchq
                                      ,rw_rowid_chd.cdagechq
                                      ,rw_rowid_chd.nrctachq
                                      ,rw_rowid_chd.nrcheque);
                  FETCH cr_verifica_fdc INTO rw_verifica_fdc;
                     IF cr_verifica_fdc%FOUND THEN
                        
                        OPEN cr_verifica_tco(rw_verifica_fdc.cdcooper
                                            ,rw_verifica_fdc.nrdconta);
                        FETCH cr_verifica_tco INTO rw_verifica_tco;
                           IF cr_verifica_tco%FOUND THEN
                              
                              BEGIN
                    
                                /* Atualiza os campos de acordo com o tipo
                                da conta do associado que recebe o cheque */
                                
                                IF rw_verifica_ass.cdtipcta >= 8  AND
                                   rw_verifica_ass.cdtipcta <= 11 THEN                       
                                   
                                   IF rw_verifica_ass.cdbcochq = 756 THEN -- BANCOOB
                                      vr_aux_cdbandep := 756;
                                      vr_aux_cdagedep := rw_cod_coop_dest.cdagebcb;
                                   ELSE
                                      vr_aux_cdbandep := rw_cod_coop_dest.cdbcoctl;
                                      vr_aux_cdagedep := rw_cod_coop_dest.cdagectl;
                                   END IF;

                                ELSE
                                   -- BANCO DO BRASIL - SEM DIGITO
                                   vr_aux_cdbandep := 1;
                                   vr_aux_cdagedep := SUBSTR(rw_cod_coop_dest.cdagedbb,LENGTH(rw_cod_coop_dest.cdagedbb)-1);
                                END IF;
                              
                                UPDATE crapfdc fdc
                                   SET fdc.incheque = fdc.incheque + 5
                                      ,fdc.dtliqchq = rw_dat_cop.dtmvtolt
                                      ,fdc.cdoperad = '1' /* SUPER-USUARIO para migracao */
                                      ,fdc.vlcheque = rw_verifica_mdw.vlcompel
                                      ,fdc.nrctadep = pr_nro_conta
                                      ,fdc.cdbandep = vr_aux_cdbandep
                                      ,fdc.cdagedep = vr_aux_cdagedep
                                 WHERE fdc.cdcooper = rw_cod_coop_migr.cdcooper
                                   AND fdc.cdbanchq = rw_rowid_chd.cdbanchq
                                   AND fdc.cdagechq = rw_rowid_chd.cdagechq
                                   AND fdc.nrctachq = rw_rowid_chd.nrctachq
                                   AND fdc.nrcheque = rw_rowid_chd.nrcheque;             
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    pr_cdcritic := 0;
                                    pr_dscritic := 'Erro ao atualizar CRAPFDC : '||sqlerrm;
                                                     
                                    cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                         ,pr_cdagenci => pr_cod_agencia
                                                         ,pr_nrdcaixa => pr_nro_caixa
                                                         ,pr_cod_erro => pr_cdcritic
                                                         ,pr_dsc_erro => pr_dscritic
                                                         ,pr_flg_erro => TRUE
                                                         ,pr_cdcritic => vr_cdcritic
                                                         ,pr_dscritic => vr_dscritic);
                                                         
                                    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                       pr_cdcritic := vr_cdcritic;
                                       pr_dscritic := vr_dscritic; 
                                       RAISE vr_exc_erro;
                                    END IF;

                                    RAISE vr_exc_erro;
                              END;
                              
                              -- Verifica se existe lote
                              OPEN cr_existe_lot(rw_cod_coop_orig.cdcooper
                                                ,rw_dat_cop.dtmvtocd
                                                ,pr_cod_agencia   /* FIXO */
                                                ,11 /* FIXO */
                                                ,vr_i_nro_lote);
                              FETCH cr_existe_lot INTO rw_existe_lot;
                                 IF cr_existe_lot%FOUND THEN
                                   
                                    /* Pagamento Cheque */
                                    BEGIN
                                             
                                       IF  rw_verifica_fdc.tpcheque = 1  THEN
                                           vr_aux_cdhistor := 21;
                                       ELSE
                                           vr_aux_cdhistor := 26;
                                       END IF;

                                       INSERT INTO craplcm(cdcooper
                                                          ,dtmvtolt
                                                          ,cdagenci
                                                          ,cdbccxlt
                                                          ,dsidenti
                                                          ,nrdolote
                                                          ,nrdconta
                                                          ,nrdocmto
                                                          ,vllanmto
                                                          ,cdhistor
                                                          ,nrseqdig
                                                          ,nrdctabb
                                                          ,nrautdoc
                                                          ,cdpesqbb
                                                          ,nrdctitg)
                                       VALUES (rw_cod_coop_orig.cdcooper
                                              ,rw_dat_cop.dtmvtolt
                                              ,rw_existe_lot.cdagenci
                                              ,rw_existe_lot.cdbccxlt
                                              ,pr_identifica
                                              ,rw_existe_lot.nrdolote
                                              ,rw_verifica_tco.nrdconta
                                              ,TO_NUMBER(rw_verifica_mdw.nrcheque||rw_verifica_mdw.nrddigc3)
                                              ,rw_verifica_mdw.vlcompel
                                              ,vr_aux_cdhistor
                                              ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                                              ,rw_verifica_mdw.nrctabdb
                                              ,rw_nrautdoc_mdw.nrautdoc
                                              ,'CRAP22,'||rw_verifica_mdw.cdopelib
                                              ,vr_dsdctitg);
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                            pr_cdcritic := 0;
                                            pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
                               
                                            cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                                 ,pr_cdagenci => pr_cod_agencia
                                                                 ,pr_nrdcaixa => pr_nro_caixa
                                                                 ,pr_cod_erro => pr_cdcritic
                                                                 ,pr_dsc_erro => pr_dscritic
                                                                 ,pr_flg_erro => TRUE
                                                                 ,pr_cdcritic => vr_cdcritic
                                                                 ,pr_dscritic => vr_dscritic);
                                            -- Levantar excecao
                                            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                               pr_cdcritic := vr_cdcritic;
                                               pr_dscritic := vr_dscritic; 
                                               RAISE vr_exc_erro;
                                            END IF;

                                            RAISE vr_exc_erro;
                                    END;
                                    
                                    BEGIN
                                       UPDATE craplot lot
                                          SET lot.nrseqdig = lot.nrseqdig + 1
                                             ,lot.qtcompln = lot.qtcompln + 1
                                             ,lot.qtinfoln = lot.qtinfoln + 1
                                             ,lot.vlcompdb = lot.vlcompdb + rw_verifica_mdw.vlcompel
                                             ,lot.vlinfodb = lot.vlinfodb + rw_verifica_mdw.vlcompel
                                        WHERE lot.cdcooper = rw_cod_coop_orig.cdcooper
                                          AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                                          AND lot.cdagenci = pr_cod_agencia
                                          AND lot.cdbccxlt = 11
                                          AND lot.nrdolote = vr_i_nro_lote
                                          AND lot.tplotmov = 1
                                          AND lot.nrdcaixa = pr_nro_caixa
                                          AND lot.cdopecxa = pr_cod_operador;             
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                          pr_cdcritic := 0;
                                          pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                                           
                                          cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                               ,pr_cdagenci => pr_cod_agencia
                                                               ,pr_nrdcaixa => pr_nro_caixa
                                                               ,pr_cod_erro => pr_cdcritic
                                                               ,pr_dsc_erro => pr_dscritic
                                                               ,pr_flg_erro => TRUE
                                                               ,pr_cdcritic => vr_cdcritic
                                                               ,pr_dscritic => vr_dscritic);

                                          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                             pr_cdcritic := vr_cdcritic;
                                             pr_dscritic := vr_dscritic; 
                                             RAISE vr_exc_erro;
                                          END IF;

                                          RAISE vr_exc_erro;
                                    END;                 
                                       
                                 END IF;
                              CLOSE cr_existe_lot;
                           
                           END IF;                       
                        CLOSE cr_verifica_tco;
                     
                     END IF;
                  
                  IF cr_verifica_fdc%ISOPEN THEN
                     CLOSE cr_verifica_fdc;
                  END IF;
                  
               END IF;
               
            IF cr_verifica_fdc%ISOPEN THEN
               CLOSE cr_verifica_fdc;
            END IF;

         END IF;

     END LOOP; -- Fim do FOR CRAPMDW
     
     IF vr_de_valor_total = 0 THEN
        pr_cdcritic := 296;
        pr_dscritic := '';

        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => pr_nro_caixa
                             ,pr_cod_erro => pr_cdcritic
                             ,pr_dsc_erro => pr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                             
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := vr_dscritic; 
           RAISE vr_exc_erro;
        END IF;

        RAISE vr_exc_erro;
     END IF;
     
     pr_literal_autentica := '';
     
     /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/

     /** Cooperativa Remetente **/
     
     --Populando vetor
     vr_tab_literal.DELETE;
     vr_tab_literal(1):= TRIM(rw_cod_coop_orig.nmrescop) ||' - '||TRIM(rw_cod_coop_orig.nmextcop);
     vr_tab_literal(2):= ' ';
     vr_tab_literal(3):= TO_CHAR(rw_dat_cop.dtmvtolt,'DD/MM/RR')  ||' '||
                         TO_CHAR(SYSDATE,'HH24:MI:SS') || ' PA  ' ||
                         TRIM(TO_CHAR(gene0002.fn_mask(pr_cod_agencia,'999'))) || '  CAIXA: '  ||
                         TO_CHAR(gene0002.fn_mask(pr_nro_caixa,'Z99')) || '/' ||
                         SUBSTR(pr_cod_operador,1,10);
     vr_tab_literal(4):= ' ';
     vr_tab_literal(5):= '      ** COMPROVANTE DE DEPOSITO '||TRIM(TO_CHAR(SUBSTR(vr_i_nro_docto,1,5),'999G999'))|| ' **';
     vr_tab_literal(6):= ' ';
     vr_tab_literal(7):= 'AGENCIA: '||TRIM(TO_CHAR(rw_cod_coop_dest.cdagectl,'9999')) || ' - ' ||TRIM(rw_cod_coop_dest.nmrescop);
     vr_tab_literal(8):= 'CONTA: '||TRIM(TO_CHAR(vr_nro_conta,'9999G999G9')) ||
                         '   PA: ' || TRIM(TO_CHAR(rw_verifica_ass.cdagenci));
     vr_tab_literal(9):=  '       ' || TRIM(rw_verifica_ass.nmprimtl); -- NOME TITULAR 1
     vr_tab_literal(10):= '       ' || TRIM(vr_nmsegntl); -- NOME TITULAR 2
     vr_tab_literal(11):= ' ';
     
     IF NVL(pr_identifica,' ') <> ' ' THEN
        vr_tab_literal(12):= 'DEPOSITO POR ';
        vr_tab_literal(13):= TRIM(pr_identifica);
        vr_tab_literal(14):= ' ';
     ELSE
        vr_tab_literal(12):= ' ';
        vr_tab_literal(13):= ' ';
        vr_tab_literal(14):= ' ';   
     END IF;
     
     vr_tab_literal(15):= '   TIPO DE DEPOSITO     VALOR EM R$ LIBERACAO EM';
     vr_tab_literal(16):= '------------------------------------------------';
     
     IF vr_de_cooperativa  > 0 THEN
        vr_tab_literal(17):= 'CHEQ.COOPERATIVA...: ' ||
                             TO_CHAR(vr_de_cooperativa,'999G999G999D99');
     END IF;
     
     vr_tab_literal(22):= ' ';
     vr_tab_literal(23):= 'TOTAL DEPOSITADO...: '||
                          TO_CHAR(vr_de_valor_total,'999G999G999D99');
     vr_tab_literal(24):= ' ';
     vr_tab_literal(25):= vr_p_literal;
     vr_tab_literal(26):= ' ';
     vr_tab_literal(27):= ' ';
     vr_tab_literal(28):= ' ';
     vr_tab_literal(29):= ' ';
     vr_tab_literal(30):= ' ';
     vr_tab_literal(31):= ' ';
     vr_tab_literal(32):= ' ';
     vr_tab_literal(33):= ' ';
     vr_tab_literal(34):= ' ';
     vr_tab_literal(35):= ' ';
     
     -- Inicializa Variavel
     pr_literal_autentica := NULL;
     
     pr_literal_autentica:= RPAD(NVL(vr_tab_literal(1),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(2),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(3),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(4),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(5),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(6),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(7),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(8),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(9),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(10),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(11),'  '),48,' ');
     
     IF NVL(vr_tab_literal(13),' ') <> ' ' THEN
        pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(12),'  '),48,' ');
        pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(13),'  '),48,' ');
        pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(14),'  '),48,' ');
     END IF;
     
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(15),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(16),'  '),48,' ');
     
     IF vr_de_cooperativa  > 0 THEN
        pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(17),'  '),48,' ');
     END IF;
     
     vr_index := pr_typ_tab_chq.first(); -- Posiciona no primeiro registro
     WHILE vr_index IS NOT NULL LOOP
       
        IF pr_typ_tab_chq(vr_index).nrdocmto = 3 THEN
           pr_literal_autentica := pr_literal_autentica || RPAD('CHEQ.PRACA MENOR...: '||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).vlcompel,'999G999G999D99') ||
                                                           '   ' ||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).dtlibcom,'DD/MM/RR')
                                                           ,48,' ');
        END IF;
        IF pr_typ_tab_chq(vr_index).nrdocmto = 4 THEN
           pr_literal_autentica := pr_literal_autentica || RPAD('CHEQ.PRACA MAIOR...: '||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).vlcompel,'999G999G999D99') ||
                                                           '   ' ||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).dtlibcom,'DD/MM/RR')
                                                           ,48,' ');
        END IF;
        IF pr_typ_tab_chq(vr_index).nrdocmto = 5 THEN
           pr_literal_autentica := pr_literal_autentica || RPAD('CHEQ.F.PRACA MENOR.: '||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).vlcompel,'999G999G999D99') ||
                                                           '   ' ||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).dtlibcom,'DD/MM/RR')
                                                           ,48,' ');
        END IF;
        IF pr_typ_tab_chq(vr_index).nrdocmto = 6 THEN
           pr_literal_autentica := pr_literal_autentica || RPAD('CHEQ.F.PRACA MAIOR.: '||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).vlcompel,'999G999G999D99') ||
                                                           '   ' ||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).dtlibcom,'DD/MM/RR')
                                                           ,48,' ');
        END IF;       
        vr_index:= pr_typ_tab_chq.NEXT(vr_index); -- Proximo registro
        
     END LOOP; -- Fim cheques maior fora praca
     
     /* Obs: Existe um limitacao do PROGRESS que não suporta a quantidada maxima de uma
     variavel VARCHAR2(32627), a solucao foi definir um tamanho para o parametro no 
     Dicionario de Dados para resolver o estouro da variavel VARCHAR2 */
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(22),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(23),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(24),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(25),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(26),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(27),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(28),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(29),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(30),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(31),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(32),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(33),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(34),'  '),48,' ');
     /* O dataserver elimina os espaçoes em branco a esquerdas de uma string, a solução
     encontrada foi colocar um caracter curinga para ser substituido por um espaço em
     branco no lado do progress. Dessa forma não é desconsiderado os espaços me branco. */
     pr_literal_autentica:= pr_literal_autentica||LPAD(NVL('#','  '),48,' ');
     
     pr_ult_seq_autentica := vr_p_ult_sequencia;
     
     /* Autenticacao REC */
     BEGIN
        UPDATE crapaut
           SET crapaut.dslitera = pr_literal_autentica
         WHERE crapaut.ROWID = vr_p_registro;
       
        --Se nao atualizou registro
        IF SQL%ROWCOUNT = 0 THEN
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro Sistema - CRAPAUT nao Encontrado';
           RAISE vr_exc_erro; 
        END IF;
         
     EXCEPTION
        WHEN Others THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro ao atualizar tabela crapaut.'||sqlerrm;
         RAISE vr_exc_erro;
     END;
     
     pr_retorno  := 'OK';
     COMMIT;
     
  EXCEPTION
     WHEN vr_exc_erro THEN
        ROLLBACK; -- Desfaz as operacoes
        pr_retorno           := 'NOK';
        pr_literal_autentica := NULL;
        pr_ult_seq_autentica := NULL;
        pr_nro_docmto        := NULL;
        
        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => pr_nro_caixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
                              
         -- Levantar excecao
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;            
         END IF;

     WHEN OTHERS THEN
         ROLLBACK;
         pr_retorno           := 'NOK';
         pr_literal_autentica := NULL;
         pr_ult_seq_autentica := NULL;
         pr_nro_docmto        := NULL;
         pr_cdcritic          := 0;
         pr_dscritic          := 'Erro na rotina CXON0022.pc_realiz_dep_cheque_mig. '||SQLERRM;
         
         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => pr_nro_caixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
                              
         -- Levantar excecao
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;            
         END IF; 

    
  END pc_realiz_dep_cheque_mig;
  
  PROCEDURE pc_realiz_dep_chq_mig_host (pr_cooper            IN VARCHAR2      --> Codigo Cooperativa
                                       ,pr_cooper_migrada    IN VARCHAR2      --> Codigo Cooperativa Migrada
                                       ,pr_cod_agencia       IN INTEGER       --> Codigo Agencia
                                       ,pr_nro_caixa         IN INTEGER       --> Codigo do Caixa
                                       ,pr_cod_operador      IN VARCHAR2      --> Codigo Operador
                                       ,pr_cooper_dest       IN VARCHAR2      --> Cooperativa de Destino
                                       ,pr_nro_conta         IN INTEGER       --> Nro da Conta
                                       ,pr_nro_conta_de      IN INTEGER       -->  Nro da Conta origem
                                       ,pr_valor             IN NUMBER        --> Valor
                                       ,pr_identifica        IN VARCHAR2      --> Identificador de Deposito
                                       ,pr_vestorno          IN INTEGER       --> Flag Estorno. False
                                       ,pr_nro_docmto        OUT NUMBER       --> Nro Documento
                                       ,pr_literal_autentica OUT VARCHAR2     --> Literal Autenticacao
                                       ,pr_ult_seq_autentica OUT INTEGER      --> Ultima Seq de Autenticacao
                                       ,pr_retorno           OUT VARCHAR2     --> Retorna OK ou NOK
                                       ,pr_cdcritic          OUT INTEGER      --> Cod Critica
                                       ,pr_dscritic          OUT VARCHAR2) IS --> Des Critica
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_realiza_dep_chq_mig_host Fonte: dbo/b1crap22.p/realiza-deposito-cheque-migrado-host
  --  Sistema  : Procedure para realizar deposito de cheques entre cooperativas
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Junho/2014.                   Ultima atualizacao: 26/04/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : 

  -- Alteracoes: 26/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
 			                  crapass, crapttl, crapjur 
							  (Adriano - P339).
  ---------------------------------------------------------------------------------------------------------------*/
  
  --Tipo de tabela para vetor literal
  TYPE typ_tab_literal IS table of VARCHAR2(100) index by PLS_INTEGER;
  --Vetor de memoria do literal
  vr_tab_literal typ_tab_literal;
  
  /* Busca o codigo da Coop. passando como parametro o nome resumido da Coop. */
  CURSOR cr_cod_coop_dest(p_nmrescop IN VARCHAR2) IS
    SELECT cop.cdcooper
          ,cop.cdagectl
          ,cop.cdagebcb
          ,cop.cdbcoctl
          ,cop.cdagedbb
          ,cop.nmrescop
      FROM crapcop cop
     WHERE UPPER(cop.nmrescop) = UPPER(p_nmrescop);
  rw_cod_coop_dest cr_cod_coop_dest%ROWTYPE;
    
  /* Busca o codigo da Coop. passando como parametro o nome resumido da Coop. */
  CURSOR cr_cod_coop_orig(p_nmrescop IN VARCHAR2) IS
    SELECT cop.cdcooper
          ,cop.cdagectl
          ,cop.cdagebcb
          ,cop.cdbcoctl
          ,cop.cdagedbb
          ,cop.nmrescop
          ,cop.nmextcop
      FROM crapcop cop
     WHERE UPPER(cop.nmrescop) = UPPER(p_nmrescop);
  rw_cod_coop_orig cr_cod_coop_orig%ROWTYPE;
  
  /* Busca o codigo da Coop. passando como parametro o nome resumido da Coop. */
  CURSOR cr_cod_coop_migr(p_nmrescop IN VARCHAR2) IS
    SELECT cop.cdcooper
          ,cop.cdagectl
          ,cop.cdagebcb
          ,cop.cdbcoctl
          ,cop.cdagedbb
          ,cop.nmrescop
          ,cop.nmextcop
      FROM crapcop cop
     WHERE UPPER(cop.nmrescop) = UPPER(p_nmrescop);
  rw_cod_coop_migr cr_cod_coop_migr%ROWTYPE;
  
  /* Busca a Data Conforme o Código da Cooperativa */
  CURSOR cr_dat_cop(p_coop IN INTEGER)IS
     SELECT dat.dtmvtolt
           ,dat.dtmvtocd
       FROM crapdat dat
      WHERE dat.cdcooper = p_coop;
  rw_dat_cop cr_dat_cop%ROWTYPE;
  
  /* Verifica Transferencia e Duplicacao de Matricula -- Associado de Destino */
  CURSOR cr_verifica_ass(p_coop IN INTEGER
                        ,p_nrdconta IN NUMBER)IS
     SELECT ass.cdsitdtl
           ,ass.nrdconta
           ,ass.cdtipcta
           ,ass.cdbcochq
           ,ass.nmprimtl
           ,ass.cdagenci
           ,ass.inpessoa
           ,ass.cdcooper
       FROM crapass ass
      WHERE ass.cdcooper = p_coop
        AND ass.nrdconta = p_nrdconta;
  rw_verifica_ass cr_verifica_ass%ROWTYPE;
  
  /* Verifica Transferencia e Duplicacao de Matricula -- Associado de Destino */
  CURSOR cr_tdm_ass(p_coop IN INTEGER
                   ,p_nrdconta IN INTEGER)IS
     SELECT ass.cdsitdtl
           ,ass.nrdconta
           ,ass.cdtipcta
           ,ass.cdbcochq
           ,ass.nmprimtl
           ,ass.cdagenci
       FROM crapass ass
      WHERE ass.cdcooper = p_coop
        AND ass.nrdconta = p_nrdconta
        AND ass.cdsitdtl IN(2,4,6,8);
  rw_tdm_ass cr_tdm_ass%ROWTYPE;
  
  /* Verifica Transferencia de Conta */
  CURSOR cr_tdc_ass(p_coop IN INTEGER
                   ,p_nrdconta IN INTEGER)IS
     SELECT ass.cdsitdtl
           ,ass.nrdconta
           ,ass.cdtipcta
           ,ass.cdbcochq
           ,ass.nmprimtl
           ,ass.cdagenci
       FROM crapass ass
      WHERE ass.cdcooper = p_coop
        AND ass.nrdconta = p_nrdconta
        AND ass.cdsitdtl IN(2,4,6,8);
  rw_tdc_ass cr_tdc_ass%ROWTYPE;

  /* Verifica Transferencia e Duplicacao de Matricula */  
  CURSOR cr_verifica_trf(p_coop     IN INTEGER
                        ,p_nrdconta IN INTEGER)IS
      SELECT trf.nrsconta
        FROM craptrf trf
       WHERE trf.cdcooper = p_coop
         AND trf.nrdconta = p_nrdconta
         AND trf.tptransa = 1
         AND trf.insittrs = 2;
  rw_verifica_trf cr_verifica_trf%ROWTYPE;
     
  /* Verifica tab de Resumos de Lancamentos Depositos */
  CURSOR cr_verifica_mrw(p_coop IN INTEGER
                        ,p_cdagenci IN INTEGER
                        ,p_nrocaixa IN INTEGER)IS
      SELECT mrw.vlchqipr
            ,mrw.vlchqspr
            ,mrw.vlchqifp
            ,mrw.vlchqsfp
            ,mrw.vlchqcop
        FROM crapmrw mrw
       WHERE mrw.cdcooper = p_coop
         AND mrw.cdagenci = p_cdagenci
         AND mrw.nrdcaixa = p_nrocaixa;
  rw_verifica_mrw cr_verifica_mrw%ROWTYPE;
  
  /* Popula tt-cheques */
  CURSOR cr_popula_ttcheque(p_coop IN INTEGER
                        ,p_cdagenci IN INTEGER
                        ,p_nrocaixa IN INTEGER)IS
      SELECT mdw.dtlibcom
            ,mdw.nrdocmto
            ,mdw.cdhistor
            ,SUM(mdw.vlcompel) vlcompel
        FROM crapmdw mdw
       WHERE mdw.cdcooper = p_coop
         AND mdw.cdagenci = p_cdagenci
         AND mdw.nrdcaixa = p_nrocaixa
         AND mdw.cdhistor IN (3,4) -- (3 - Praca, 4 - Fora Praca)
      GROUP BY mdw.dtlibcom
              ,mdw.nrdocmto
              ,mdw.cdhistor;
  rw_popula_ttcheque cr_popula_ttcheque%ROWTYPE;
  
  /* Verifica tabela de Lancamentos Depositos */
  CURSOR cr_verifica_mdw(p_coop IN INTEGER
                        ,p_cdagenci IN INTEGER
                        ,p_nrocaixa IN INTEGER)IS
      SELECT mdw.lsdigctr
            ,mdw.dtlibcom
            ,mdw.nrdocmto
            ,mdw.vlcompel
            ,mdw.cdhistor
            ,mdw.nrctabdb
            ,mdw.cdcmpchq
            ,mdw.cdbanchq
            ,mdw.cdagechq
            ,mdw.nrctachq
            ,mdw.nrcheque
            ,mdw.tpdmovto
            ,mdw.nrctaaux
            ,mdw.nrddigc1
            ,mdw.nrddigc2
            ,mdw.nrddigc3
            ,mdw.cdtipchq
            ,mdw.dsdocmc7
            ,mdw.cdopelib
            ,mdw.nrautdoc
            ,rowid
        FROM crapmdw mdw
       WHERE mdw.cdcooper = p_coop
         AND mdw.cdagenci = p_cdagenci
         AND mdw.nrdcaixa = p_nrocaixa;
  rw_verifica_mdw cr_verifica_mdw%ROWTYPE;
  
  CURSOR cr_nrautdoc_mdw(p_rowid IN ROWID)IS
      SELECT mdw.nrautdoc
            ,rowid
        FROM crapmdw mdw
       WHERE mdw.rowid = p_rowid;
  rw_nrautdoc_mdw cr_nrautdoc_mdw%ROWTYPE;
  
  /* Verifica Resumo de Cheque para verificar se necessita
  verificar horario de corte */
  CURSOR cr_verif_hora_corte(p_coop IN INTEGER
                            ,p_cdagenci IN INTEGER
                            ,p_nrdcaixa IN INTEGER)IS
      SELECT mrw.vlchqipr
            ,mrw.vlchqspr
            ,mrw.vlchqifp
            ,mrw.vlchqsfp
            ,mrw.vlchqcop
        FROM crapmrw mrw
       WHERE mrw.cdcooper = p_coop
         AND mrw.cdagenci = p_cdagenci
         AND mrw.nrdcaixa = p_nrdcaixa
         AND mrw.vlchqipr <> 0 
         AND mrw.vlchqspr <> 0 
         AND mrw.vlchqifp <> 0 
         AND mrw.vlchqsfp <> 0;
  rw_verif_hora_corte cr_verif_hora_corte%ROWTYPE; 

  vr_dstextab craptab.dstextab%TYPE;
  
  /* Verifica se existe registro na CRAPLOT */
  CURSOR cr_existe_lot(p_cdcooper IN INTEGER
                      ,p_dtmvtolt IN DATE
                      ,p_cdagenci IN INTEGER
                      ,p_cdbccxlt IN INTEGER
                      ,p_nrdolote IN INTEGER)IS
      SELECT lot.cdcooper
            ,lot.dtmvtolt
            ,lot.cdagenci
            ,lot.cdbccxlt
            ,lot.nrdolote
            ,lot.cdopecxa
        FROM craplot lot
       WHERE lot.cdcooper = p_cdcooper
         AND lot.dtmvtolt = p_dtmvtolt
         AND lot.cdagenci = p_cdagenci
         AND lot.cdbccxlt = p_cdbccxlt
         AND lot.nrdolote = p_nrdolote;
  rw_existe_lot cr_existe_lot%ROWTYPE;
  
  /* Verifica se existe registro na CRAPLOT */
  CURSOR cr_existe_lot2(p_cdcooper IN INTEGER
                       ,p_dtmvtolt IN DATE
                       ,p_cdagenci IN INTEGER
                       ,p_cdbccxlt IN INTEGER
                       ,p_nrdolote IN INTEGER)IS
      SELECT lot.cdcooper
            ,lot.dtmvtolt
            ,lot.cdagenci
            ,lot.cdbccxlt
            ,lot.nrdolote
            ,lot.cdopecxa
            ,lot.nrseqdig
        FROM craplot lot
       WHERE lot.cdcooper = p_cdcooper
         AND lot.dtmvtolt = p_dtmvtolt
         AND lot.cdagenci = p_cdagenci
         AND lot.cdbccxlt = p_cdbccxlt
         AND lot.nrdolote = p_nrdolote;
  rw_existe_lot2 cr_existe_lot2%ROWTYPE;
  
  /* Verifica se existe registro na CRAPBCX */
  CURSOR cr_existe_bcx(p_cdcooper IN INTEGER
                      ,p_dtmvtolt IN DATE
                      ,p_cdagenci IN INTEGER
                      ,p_nrdcaixa IN INTEGER
                      ,p_cdopecxa IN VARCHAR2)IS
      SELECT bcx.qtcompln
            ,bcx.nrdmaqui
        FROM crapbcx bcx
       WHERE bcx.cdcooper = p_cdcooper
         AND bcx.dtmvtolt = p_dtmvtolt
         AND bcx.cdagenci = p_cdagenci
         AND bcx.nrdcaixa = p_nrdcaixa
         AND UPPER(bcx.cdopecxa) = UPPER(p_cdopecxa)
         AND bcx.cdsitbcx = 1;
  rw_existe_bcx cr_existe_bcx%ROWTYPE;
  
  /* Verifica se existe registro na CRAPBCX */
  CURSOR cr_crapbcx(p_cdcooper IN INTEGER
                      ,p_dtmvtolt IN DATE
                      ,p_cdagenci IN INTEGER
                      ,p_nrdcaixa IN INTEGER
                      ,p_cdopecxa IN VARCHAR2)IS
      SELECT bcx.qtcompln
            ,bcx.nrdmaqui
            ,bcx.qtchqprv
        FROM crapbcx bcx
       WHERE bcx.cdcooper = p_cdcooper
         AND bcx.dtmvtolt = p_dtmvtolt
         AND bcx.cdagenci = p_cdagenci
         AND bcx.nrdcaixa = p_nrdcaixa
         AND UPPER(bcx.cdopecxa) = UPPER(p_cdopecxa);
  rw_crapbcx cr_crapbcx%ROWTYPE; 
  
  /* Buscar os Totais de Cheque Cooperativa */
  CURSOR cr_tot_chq_coop(p_coop IN INTEGER
                          ,p_cdagenci IN INTEGER
                          ,p_nrocaixa IN INTEGER)IS
      SELECT mrw.vlchqipr
            ,mrw.vlchqspr
            ,mrw.vlchqifp
            ,mrw.vlchqsfp
            ,mrw.vlchqcop
        FROM crapmrw mrw
       WHERE mrw.cdcooper = p_coop
         AND mrw.cdagenci = p_cdagenci
         AND mrw.nrdcaixa = p_nrocaixa;
  rw_tot_chq_coop cr_tot_chq_coop%ROWTYPE;
  
  /* Verifica se existe LCM - 6 Parametros */
  CURSOR cr_existe_lcm(p_cdcooper INTEGER
                      ,p_dtmvtolt DATE
                      ,p_cdagenci INTEGER
                      ,p_cdbccxlt INTEGER
                      ,p_nrdolote INTEGER
                      ,p_nrseqdig INTEGER) IS
     SELECT lcm.cdcooper
           ,lcm.dtmvtolt
           ,lcm.cdagenci
           ,lcm.cdbccxlt
           ,lcm.nrdolote
           ,lcm.nrseqdig
       FROM craplcm lcm
      WHERE lcm.cdcooper = p_cdcooper
        AND lcm.dtmvtolt = p_dtmvtolt
        AND lcm.cdagenci = p_cdagenci
        AND lcm.cdbccxlt = p_cdbccxlt
        AND lcm.nrdolote = p_nrdolote
        AND lcm.nrseqdig = p_nrseqdig;
  rw_existe_lcm cr_existe_lcm%ROWTYPE;
  
  /* Verifica se existe LCM - 7 Parametros */  
  CURSOR cr_existe_lcm1(p_cdcooper INTEGER
                       ,p_dtmvtolt DATE
                       ,p_cdagenci INTEGER
                       ,p_cdbccxlt INTEGER
                       ,p_nrdolote INTEGER
                       ,p_nrdctabb INTEGER
                       ,p_nrdocmto INTEGER) IS
     SELECT lcm.cdcooper
           ,lcm.dtmvtolt
           ,lcm.cdagenci
           ,lcm.cdbccxlt
           ,lcm.nrdolote
           ,lcm.nrdctabb
           ,lcm.nrdocmto
       FROM craplcm lcm
      WHERE lcm.cdcooper = p_cdcooper
        AND lcm.dtmvtolt = p_dtmvtolt
        AND lcm.cdagenci = p_cdagenci
        AND lcm.cdbccxlt = p_cdbccxlt
        AND lcm.nrdolote = p_nrdolote
        AND lcm.nrdctabb = p_nrdctabb
        AND lcm.nrdocmto = p_nrdocmto;
  rw_existe_lcm1 cr_existe_lcm1%ROWTYPE;
  
  -- Busca a ultma sequencia de dig
  CURSOR cr_consulta_lot (p_cdcooper IN craplot.cdcooper%TYPE
                         ,p_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,p_cdagenci IN craplot.cdagenci%TYPE
                         ,p_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,p_nrdolote IN craplot.nrdolote%TYPE) IS
     SELECT MAX(lot.nrseqdig) + 1 nrseqdig
       FROM craplot lot
       WHERE lot.cdcooper = p_cdcooper
         AND lot.dtmvtolt = p_dtmvtolt
         AND lot.cdagenci = p_cdagenci
         AND lot.cdbccxlt = p_cdbccxlt
         AND lot.nrdolote = p_nrdolote;
  rw_consulta_lot cr_consulta_lot%ROWTYPE;
  
  CURSOR cr_verifica_tco (p_coop_ant IN craptco.cdcopant%TYPE
                         ,p_ncta_ant IN craptco.nrctaant%TYPE) IS
     SELECT tco.cdageant
           ,tco.cdagenci
           ,tco.cdcooper
           ,tco.cdcopant
           ,tco.flgativo
           ,tco.nrcarant
           ,tco.nrcartao
           ,tco.nrctaant
           ,tco.nrdctitg
           ,tco.tpctatrf
           ,tco.nrdconta
       FROM craptco tco
      WHERE tco.cdcopant = p_coop_ant
        AND tco.nrctaant = p_ncta_ant
        AND tco.tpctatrf = 1
        AND tco.flgativo = 1;
  rw_verifica_tco cr_verifica_tco%ROWTYPE;
  
  -- Busca a ultma sequencia de dig
  CURSOR cr_consulta_chd (p_cdcooper IN crapchd.cdcooper%TYPE
                         ,p_dtmvtolt IN crapchd.dtmvtolt%TYPE
                         ,p_cdcmpchq IN crapchd.cdcmpchq%TYPE
                         ,p_cdbanchq IN crapchd.cdbanchq%TYPE
                         ,p_cdagechq IN crapchd.cdagechq%TYPE
                         ,p_nrctachq IN crapchd.nrctachq%TYPE
                         ,p_nrcheque IN crapchd.nrcheque%TYPE) IS
    SELECT chd.cdcooper
          ,chd.dtmvtolt
          ,chd.cdcmpchq
          ,chd.cdbanchq
          ,chd.cdagechq
          ,chd.nrctachq
          ,chd.nrcheque
          ,chd.cdagenci
          ,chd.cdbccxlt
          ,chd.nrdocmto
          ,chd.cdoperad
          ,chd.cdsitatu
          ,chd.dsdocmc7
          ,chd.inchqcop
          ,chd.insitchq
          ,chd.cdtipchq
          ,chd.nrdconta
          ,chd.nrddigc1
          ,chd.nrddigc2
          ,chd.nrddigc3
          ,chd.nrddigv1
          ,chd.nrddigv2
          ,chd.nrddigv3
          ,chd.nrdolote
          ,chd.tpdmovto
          ,chd.nrterfin
          ,chd.vlcheque
          ,chd.cdagedst
          ,chd.nrctadst                  
      FROM crapchd chd
     WHERE chd.cdcooper = p_cdcooper
       AND chd.dtmvtolt = p_dtmvtolt
       AND chd.cdcmpchq = p_cdcmpchq
       AND chd.cdbanchq = p_cdbanchq
       AND chd.cdagechq = p_cdagechq
       AND chd.nrctachq = p_nrctachq
       AND chd.nrcheque = p_nrcheque;
  rw_consulta_chd cr_consulta_chd%ROWTYPE;
  
  -- Busca novamente os dados da acolhedora
  CURSOR cr_rowid_chd(p_rowid IN ROWID) IS
    SELECT chd.cdcooper
          ,chd.dtmvtolt
          ,chd.cdcmpchq
          ,chd.cdbanchq
          ,chd.cdagechq
          ,chd.nrctachq
          ,chd.nrcheque
          ,chd.cdagenci
          ,chd.cdbccxlt
          ,chd.nrdocmto
          ,chd.cdoperad
          ,chd.cdsitatu
          ,chd.dsdocmc7
          ,chd.inchqcop
          ,chd.insitchq
          ,chd.cdtipchq
          ,chd.nrdconta
          ,chd.nrddigc1
          ,chd.nrddigc2
          ,chd.nrddigc3
          ,chd.nrddigv1
          ,chd.nrddigv2
          ,chd.nrddigv3
          ,chd.nrdolote
          ,chd.tpdmovto
          ,chd.nrterfin
          ,chd.vlcheque
          ,chd.cdagedst
          ,chd.nrctadst                  
      FROM crapchd chd
     WHERE ROWID = p_rowid;
  rw_rowid_chd cr_rowid_chd%ROWTYPE;
  
  CURSOR cr_verifica_fdc (p_cdcooper IN crapfdc.cdcooper%TYPE
                         ,p_cdbanchq IN crapfdc.cdbanchq%TYPE
                         ,p_cdagechq IN crapfdc.cdcmpchq%TYPE
                         ,p_nrctachq IN crapfdc.cdbanchq%TYPE
                         ,p_nrcheque IN crapfdc.cdagechq%TYPE) IS
     SELECT fdc.incheque
           ,fdc.dtliqchq
           ,fdc.cdoperad
           ,fdc.vlcheque
           ,fdc.cdbanchq
           ,fdc.cdagechq
           ,fdc.nrctachq
           ,fdc.tpcheque
           ,fdc.cdcooper
           ,fdc.nrdconta
       FROM crapfdc fdc
      WHERE fdc.cdcooper = p_cdcooper
        AND fdc.cdbanchq = p_cdbanchq
        AND fdc.cdagechq = p_cdagechq
        AND fdc.nrctachq = p_nrctachq
        AND fdc.nrcheque = p_nrcheque;
  rw_verifica_fdc cr_verifica_fdc%ROWTYPE;  

  CURSOR cr_crapttl(pr_cdcooper crapttl.cdcooper%TYPE
	               ,pr_nrdconta crapttl.nrdconta%TYPE)IS
  SELECT crapttl.nmextttl
	FROM crapttl
   WHERE crapttl.cdcooper = pr_cdcooper
	 AND crapttl.nrdconta = pr_nrdconta
	 AND crapttl.idseqttl = 2;
 
  -- Variaveis Erro
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
  
  -- Variaveis
  pr_typ_tab_chq typ_tab_chq;
  pr_tab_erro GENE0001.typ_tab_erro;
  
  vr_nrtrfcta  craptrf.nrsconta%TYPE := 0;
  vr_nrdconta  craptrf.nrsconta%TYPE := 0;
  vr_nro_conta craptrf.nrsconta%TYPE := 0;
  vr_dsdctitg VARCHAR2(200)          := '';
  vr_stsnrcal INTEGER                := 0;
  vr_achou_horario_corte BOOLEAN     := FALSE;
  vr_i_nro_lote NUMBER(10)           := 0;
  vr_c_docto_salvo VARCHAR2(200)     := '';
  vr_cdpacrem PLS_INTEGER;  
  vr_c_docto VARCHAR2(200)           := '';
  vr_tpdmovto INTEGER                := 0;
  vr_i_nro_docto INTEGER             := 0;
  vr_p_literal VARCHAR2(32000)       := '';
  vr_p_ult_sequencia INTEGER         := 0;
  vr_glb_dsdctitg    VARCHAR2(200)   := '';
  vr_literal         VARCHAR(5000)   := '';
  vr_p_registro ROWID;
  
  vr_aux_p_literal  VARCHAR2(32000)  := '';
  vr_aux_p_ult_seq  INTEGER          := 0;
  vr_aux_p_registro ROWID;
  vr_aux_cdbandep   crapfdc.cdbandep%TYPE;
  vr_aux_cdagedep   crapfdc.cdagedep%TYPE;
  vr_lsdigctr       gene0002.typ_split;
  
  vr_aux_cdhistor   craplcm.cdhistor%TYPE;
  
  vr_de_valor_total    NUMBER(13,2) := 0;
  vr_de_cooperativa    NUMBER(13,2) := 0;
  vr_de_chq_intercoopc NUMBER(13,2) := 0;
  vr_de_maior_praca    NUMBER(13,2) := 0;
  vr_de_menor_praca    NUMBER(13,2) := 0;
  vr_de_maior_fpraca   NUMBER(13,2) := 0;
  vr_de_menor_fpraca   NUMBER(13,2) := 0;
  vr_index             VARCHAR2(21)  := '';
  vr_i_seq_386         INTEGER      := 0;
  vr_nrsequen          INTEGER      := 0;
  vr_rowid_chd         ROWID;
  
  vr_aux_inchqcop crapchd.inchqcop%TYPE;
  vr_aux_nrctachq crapchd.nrctachq%TYPE;
  vr_aux_nrddigv1 crapchd.nrddigv1%TYPE;
  vr_aux_nrddigv2 crapchd.nrddigv2%TYPE;
  vr_aux_nrddigv3 crapchd.nrddigv3%TYPE;
  vr_aux_nrseqdig crapmdw.nrseqdig%TYPE;
  vr_nmsegntl crapttl.nmextttl%TYPE;
    
  BEGIN
    
     -- Busca Cod. Coop de DESTINO
     OPEN cr_cod_coop_dest(pr_cooper_dest);
     FETCH cr_cod_coop_dest INTO rw_cod_coop_dest;
     CLOSE cr_cod_coop_dest;
     
     -- Busca Cod. Coop de ORIGEM
     OPEN cr_cod_coop_orig(pr_cooper);
     FETCH cr_cod_coop_orig INTO rw_cod_coop_orig;
     CLOSE cr_cod_coop_orig;
     
     -- Busca Cod. Coop MIGRADA
     OPEN cr_cod_coop_migr(pr_cooper_migrada);
     FETCH cr_cod_coop_migr INTO rw_cod_coop_migr;
     CLOSE cr_cod_coop_migr;
     
     -- Busca Data do Sistema
     OPEN cr_dat_cop(rw_cod_coop_orig.cdcooper);
     FETCH cr_dat_cop INTO rw_dat_cop;
     CLOSE cr_dat_cop;
     
     /* Gravar o Nro da Conta para possivel manipulacao
     do nro da conta utilizar a variavel */   
     vr_nro_conta := pr_nro_conta;
     
     -- Verifica a conta do associado
     OPEN cr_verifica_ass(rw_cod_coop_dest.cdcooper
                         ,vr_nro_conta);
     FETCH cr_verifica_ass INTO rw_verifica_ass;
     CLOSE cr_verifica_ass;
  
     IF rw_verifica_ass.inpessoa = 1 THEN

	   OPEN cr_crapttl(pr_cdcooper => rw_verifica_ass.cdcooper
	                  ,pr_nrdconta => rw_verifica_ass.nrdconta);

	   FETCH cr_crapttl INTO vr_nmsegntl;

	   CLOSE cr_crapttl;

	 END IF;
  
     -- Verifica Transferencia e Duplicacao de Matricula - Associado de Destino
     OPEN cr_tdm_ass(rw_cod_coop_dest.cdcooper
                    ,vr_nro_conta);
     FETCH cr_tdm_ass INTO rw_tdm_ass;
        IF cr_tdm_ass%FOUND THEN
           OPEN cr_verifica_trf(rw_cod_coop_dest.cdcooper
                               ,rw_tdm_ass.nrdconta);
           FETCH cr_verifica_trf INTO rw_verifica_trf;
              IF cr_verifica_trf%FOUND THEN
                 vr_nrtrfcta  := rw_verifica_trf.nrsconta;
                 vr_nrdconta  := rw_verifica_trf.nrsconta;
                 vr_nro_conta := rw_verifica_trf.nrsconta;
              END IF;
           CLOSE cr_verifica_trf;           
        END IF;             
     CLOSE cr_tdm_ass;
     
     CXON0000.pc_elimina_erro(pr_cooper      => rw_cod_coop_orig.cdcooper
                             ,pr_cod_agencia => pr_cod_agencia
                             ,pr_nro_caixa   => pr_nro_caixa
                             ,pr_cdcritic    => vr_cdcritic
                             ,pr_dscritic    => vr_dscritic);
     -- Se ocorreu erro
     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => pr_nro_caixa
                             ,pr_cod_erro => pr_cdcritic
                             ,pr_dsc_erro => pr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := vr_dscritic; 
           RAISE vr_exc_erro;
        END IF;

        RAISE vr_exc_erro;
     END IF;
     
     --  Verifica tabela de Resumos de Lancamentos Depositos
     OPEN cr_verifica_mrw(rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia
                         ,pr_nro_caixa);
     FETCH cr_verifica_mrw INTO rw_verifica_mrw;
        IF cr_verifica_mrw%NOTFOUND THEN
           pr_cdcritic := 0;
           pr_dscritic := 'Nao existem valores a serem Depositados';
           
           cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                ,pr_cdagenci => pr_cod_agencia
                                ,pr_nrdcaixa => pr_nro_caixa
                                ,pr_cod_erro => pr_cdcritic
                                ,pr_dsc_erro => pr_dscritic
                                ,pr_flg_erro => TRUE
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
                                
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic; 
              RAISE vr_exc_erro;
           END IF;

           RAISE vr_exc_erro;
        END IF;
     CLOSE cr_verifica_mrw;
     
     --  Verifica tabela de Lancamentos Depositos
     OPEN cr_verifica_mdw(rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia
                         ,pr_nro_caixa);
     FETCH cr_verifica_mdw INTO rw_verifica_mdw;
        
        vr_lsdigctr := gene0002.fn_quebra_string(pr_string  => rw_verifica_mdw.lsdigctr
                                                ,pr_delimit => ',');
                                 
        IF vr_lsdigctr.COUNT() <> 3 THEN
           pr_cdcritic := 0;
           pr_dscritic := 'Avise INF(ENTRY) = ' ||
                          TO_CHAR(rw_verifica_mdw.lsdigctr) ||' - '||
                          TO_CHAR(rw_verifica_mdw.nrcheque);
                          
           cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                ,pr_cdagenci => pr_cod_agencia
                                ,pr_nrdcaixa => pr_nro_caixa
                                ,pr_cod_erro => pr_cdcritic
                                ,pr_dsc_erro => pr_dscritic
                                ,pr_flg_erro => TRUE
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic; 
              RAISE vr_exc_erro;
           END IF;

           RAISE vr_exc_erro;
        END IF;
     CLOSE cr_verifica_mdw;
     
     vr_nrtrfcta := 0;
     vr_nrdconta := vr_nro_conta;
     
     -- Verifica se Houve Transferencia de Conta
     OPEN cr_tdc_ass(rw_cod_coop_dest.cdcooper
                    ,vr_nrdconta);
     FETCH cr_tdc_ass INTO rw_tdc_ass;
        IF cr_tdc_ass%FOUND THEN
           OPEN cr_verifica_trf(rw_cod_coop_dest.cdcooper
                               ,rw_tdc_ass.nrdconta);
           FETCH cr_verifica_trf INTO rw_verifica_trf;
              IF cr_verifica_trf%FOUND THEN
                 vr_nrtrfcta  := rw_verifica_trf.nrsconta;
                 vr_nrdconta  := rw_verifica_trf.nrsconta;                
              END IF;
           CLOSE cr_verifica_trf;       
        END IF;             
     CLOSE cr_tdc_ass;
     
     -- Se houve transferencia de conta, grava na variavel
     IF vr_nrtrfcta > 0 THEN
        vr_nrdconta := vr_nrtrfcta;
     END IF;
     
     -- Gravar o Nro da Conta e utilizar a variavel
     vr_nro_conta := vr_nrdconta;

     -- Verifica horario de Corte - Coop do Caixa
     vr_achou_horario_corte := FALSE;
     FOR rw_verif_hora_corte IN cr_verif_hora_corte(rw_cod_coop_orig.cdcooper
                                                   ,pr_cod_agencia
                                                   ,pr_nro_caixa) LOOP
        vr_achou_horario_corte := TRUE; -- Registro encontrado    
     END LOOP;
     
     -- Se encontrou registro. Valida horario de Corte - Coop do Caixa
     IF vr_achou_horario_corte THEN

        -- Buscar configuração na tabela
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRTRCOMPEL'
                                                 ,pr_tpregist => pr_cod_agencia);                            
        
           IF TRIM(vr_dstextab) IS NULL THEN 
              pr_cdcritic := 676;
              pr_dscritic := '';
              
              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => pr_nro_caixa
                                   ,pr_cod_erro => pr_cdcritic
                                   ,pr_dsc_erro => pr_dscritic
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic; 
                 RAISE vr_exc_erro;
              END IF;

              RAISE vr_exc_erro;
           END IF;
           
           IF TO_NUMBER(SUBSTR(vr_dstextab,1,1)) <> 0 THEN
              pr_cdcritic := 677;
              pr_dscritic := '';
              
              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => pr_nro_caixa
                                   ,pr_cod_erro => pr_cdcritic
                                   ,pr_dsc_erro => pr_dscritic
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
                                   
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic; 
                 RAISE vr_exc_erro;
              END IF;

              RAISE vr_exc_erro;
           END IF;
           
           IF TO_NUMBER(SUBSTR(vr_dstextab,3,5)) <= TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')) THEN
              pr_cdcritic := 676;
              pr_dscritic := '';
              
              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => pr_nro_caixa
                                   ,pr_cod_erro => pr_cdcritic
                                   ,pr_dsc_erro => pr_dscritic
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic; 
                 RAISE vr_exc_erro;
              END IF;

              RAISE vr_exc_erro;
           END IF;
           
     END IF; -- Verifica Horario de Corte
     
     -- Criacao do LOTE de DESTINO (CREDITO)
     vr_i_nro_lote    := 10118;
     vr_c_docto_salvo := TO_CHAR(SYSDATE,'SSSSS');
     
     -- Verifica se existe lote
     OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                       ,rw_dat_cop.dtmvtocd
                       ,1   /* FIXO */
                       ,100 /* FIXO */
                       ,vr_i_nro_lote);
     FETCH cr_existe_lot INTO rw_existe_lot;
        IF cr_existe_lot%NOTFOUND THEN
           -- Se nao existir cria a capa de lote
           BEGIN
              INSERT INTO craplot(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,tplotmov
                                 ,nrdcaixa
                                 ,cdopecxa)
              VALUES (rw_cod_coop_dest.cdcooper
                     ,rw_dat_cop.dtmvtocd
                     ,1
                     ,100
                     ,vr_i_nro_lote
                     ,1
                     ,pr_nro_caixa
                     ,pr_cod_operador);              
           EXCEPTION
              WHEN OTHERS THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Erro ao inserir na CRAPLOT : '||sqlerrm;
                                  
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);

                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
           END;
        END IF;
     CLOSE cr_existe_lot;

     vr_de_valor_total    := 0;
     vr_de_cooperativa    := 0;
     vr_de_chq_intercoopc := 0;
     vr_de_maior_praca    := 0;
     vr_de_menor_praca    := 0;
     vr_de_maior_fpraca   := 0;
     vr_de_menor_fpraca   := 0;

     -- RESUMO
     -- Buscar os Totais de Cheque Cooperativa
     OPEN cr_tot_chq_coop(rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia
                         ,pr_nro_caixa);
     FETCH cr_tot_chq_coop INTO rw_tot_chq_coop;
        IF cr_tot_chq_coop%FOUND THEN
           vr_de_cooperativa    := rw_tot_chq_coop.vlchqcop;
           vr_de_valor_total    := vr_de_cooperativa;           
        END IF;
     CLOSE cr_tot_chq_coop;
     
        -- Buscar configuração na tabela
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'MAIORESCHQ'
                                                 ,pr_tpregist => 1);
     
     
     
        -- Buscar os totais de Cheques
        FOR rw_verifica_mdw IN cr_verifica_mdw(rw_cod_coop_orig.cdcooper
                                              ,pr_cod_agencia
                                              ,pr_nro_caixa) LOOP
                                                    
            -- Montar chave de busca
           vr_index :=  TO_CHAR(rw_verifica_mdw.dtlibcom,'DD/MM/RRRR')||
                        TO_CHAR(LPAD(rw_verifica_mdw.nrdocmto,10,0));
           
           -- Se a chave ainda não existir
           IF pr_typ_tab_chq.count = 0 OR NOT pr_typ_tab_chq.exists(vr_index) THEN
             pr_typ_tab_chq(vr_index).vlcompel := 0; -- Inicializa o campo de valor
           END IF;

           -- Define o tipo do docmto (1-Menor Praca-Maior/2-Praca,1-Menor Fora Praca/2-Maior Fora Praca)
           IF rw_verifica_mdw.vlcompel < TO_NUMBER(SUBSTR(vr_dstextab,1,15)) THEN               
              vr_tpdmovto := 2;             
           ELSE
              vr_tpdmovto := 1;
           END IF;
            
            IF rw_verifica_mdw.cdhistor = 3 THEN -- Praca
               IF vr_tpdmovto = 2 THEN -- Menor Praca
                  pr_typ_tab_chq(vr_index).dtlibcom := rw_verifica_mdw.dtlibcom;
                  pr_typ_tab_chq(vr_index).vlcompel := pr_typ_tab_chq(vr_index).vlcompel + rw_verifica_mdw.vlcompel;
                  pr_typ_tab_chq(vr_index).nrdocmto := 3;
                  vr_de_menor_praca                 := vr_de_menor_praca + rw_verifica_mdw.vlcompel;
               ELSE -- Maior Praca
                  pr_typ_tab_chq(vr_index).dtlibcom := rw_verifica_mdw.dtlibcom;
                  pr_typ_tab_chq(vr_index).vlcompel := pr_typ_tab_chq(vr_index).vlcompel + rw_verifica_mdw.vlcompel;
                  pr_typ_tab_chq(vr_index).nrdocmto := 4;
                  vr_de_maior_praca                 := vr_de_maior_praca + rw_verifica_mdw.vlcompel;
               END IF;                 
            ELSE -- Fora Praca
               IF rw_verifica_mdw.cdhistor = 4 THEN
                  IF vr_tpdmovto = 2 THEN -- Menor Fora Praca
                     pr_typ_tab_chq(vr_index).dtlibcom := rw_verifica_mdw.dtlibcom;
                     pr_typ_tab_chq(vr_index).vlcompel := pr_typ_tab_chq(vr_index).vlcompel + rw_verifica_mdw.vlcompel;
                     pr_typ_tab_chq(vr_index).nrdocmto := 5;
                     vr_de_menor_fpraca                := vr_de_menor_fpraca + rw_verifica_mdw.vlcompel;
                  ELSE -- Maior Fora Praca
                     pr_typ_tab_chq(vr_index).dtlibcom := rw_verifica_mdw.dtlibcom;
                     pr_typ_tab_chq(vr_index).vlcompel := pr_typ_tab_chq(vr_index).vlcompel + rw_verifica_mdw.vlcompel;
                     pr_typ_tab_chq(vr_index).nrdocmto := 6;
                     vr_de_maior_fpraca                := vr_de_maior_fpraca + rw_verifica_mdw.vlcompel;
                  END IF;  
               END IF;
            END IF;                                                   
                                                                                                                 
        END LOOP;
        -- Fim da montagem do Resumo
          
     vr_de_valor_total := vr_de_valor_total
                        + vr_de_menor_fpraca + vr_de_menor_praca
                        + vr_de_maior_fpraca + vr_de_maior_praca;
                        
     /** Se veio da Rotina 61 **/
     IF NVL(pr_identifica,' ') LIKE '%Deposito de envelope%'  THEN
        vr_cdpacrem := 91; /* TAA */
     ELSE
        vr_cdpacrem := pr_cod_agencia;
     END IF;                               
     
     -- Cria registro na CRAPLDT - Para o valor total da transacao
     CXON0022.pc_gera_log(pr_cooper       => rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia  => pr_cod_agencia
                         ,pr_nro_caixa    => pr_nro_caixa
                         ,pr_operador     => pr_cod_operador
                         ,pr_cooper_dest  => rw_cod_coop_dest.cdcooper
                         ,pr_nrdcontade   => pr_nro_conta_de
                         ,pr_nrdcontapara => pr_nro_conta
                         ,pr_tpoperac     => 5 -- Dep em Cheque
                         ,pr_valor        => vr_de_valor_total
                         ,pr_nrdocmto     => TO_NUMBER(vr_c_docto_salvo)
                         ,pr_cdpacrem     => vr_cdpacrem
                         ,pr_cdcritic     => vr_cdcritic   -- Codigo do erro
                         ,pr_dscritic     => vr_dscritic); -- Descricao da Critica
                         
     -- Se ocorreu erro
     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => pr_nro_caixa
                             ,pr_cod_erro => vr_cdcritic
                             ,pr_dsc_erro => vr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        RAISE vr_exc_erro;
     END IF;

     vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo);
     pr_nro_docmto  := TO_NUMBER(vr_c_docto_salvo);
     
     -- Grava Autenticacao Arquivo/Spool
     CXON0000.pc_grava_autenticacao(pr_cooper       => rw_cod_coop_orig.cdcooper
                                   ,pr_cod_agencia  => pr_cod_agencia
                                   ,pr_nro_caixa    => pr_nro_caixa
                                   ,pr_cod_operador => pr_cod_operador
                                   ,pr_valor        => vr_de_valor_total
                                   ,pr_docto        => TO_NUMBER(vr_i_nro_docto)
                                   ,pr_operacao     => FALSE -- YES (PG), NO (RC)
                                   ,pr_status       => '1' -- On-line
                                   ,pr_estorno      => FALSE -- Nao estorno
                                   ,pr_histor       => 700
                                   ,pr_data_off     => NULL 
                                   ,pr_sequen_off   => 0 -- Seq. off-line
                                   ,pr_hora_off     => 0 -- hora off-line
                                   ,pr_seq_aut_off  => 0 -- Seq.orig.Off-line
                                   ,pr_literal      => vr_p_literal
                                   ,pr_sequencia    => vr_p_ult_sequencia
                                   ,pr_registro     => vr_p_registro
                                   ,pr_cdcritic     => vr_cdcritic
                                   ,pr_dscritic     => vr_dscritic);
     -- Se ocorreu erro
     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;  
     
        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => pr_nro_caixa
                             ,pr_cod_erro => vr_cdcritic
                             ,pr_dsc_erro => vr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := vr_dscritic; 
           RAISE vr_exc_erro;
        END IF;

        RAISE vr_exc_erro;                             
     END IF;
     
     OPEN cr_crapbcx(rw_cod_coop_orig.cdcooper
                       ,rw_dat_cop.dtmvtolt
                       ,pr_cod_agencia
                       ,pr_nro_caixa
                       ,pr_cod_operador);
     FETCH cr_crapbcx INTO rw_crapbcx;
       -- Informacao da cooperativa de origem
       BEGIN
          INSERT INTO craplcx(cdcooper
                             ,dtmvtolt
                             ,cdagenci
                             ,nrdcaixa
                             ,cdopecxa
                             ,nrdocmto
                             ,nrseqdig
                             ,nrdmaqui
                             ,cdhistor
                             ,dsdcompl
                             ,vldocmto
                             ,nrautdoc)
          VALUES (rw_cod_coop_orig.cdcooper
                 ,rw_dat_cop.dtmvtolt
                 ,pr_cod_agencia
                 ,pr_nro_caixa
                 ,pr_cod_operador
                 ,TO_NUMBER(vr_i_nro_docto)
                 ,rw_existe_bcx.qtcompln + 1
                 ,rw_existe_bcx.nrdmaqui
                 ,1528
                 ,'Agencia:'||gene0002.fn_mask(rw_cod_coop_dest.cdagectl,'zzz9')||
                  ' Conta/DV:'||gene0002.fn_mask(pr_nro_conta,'zzzz.zzz.9')
                 ,vr_de_valor_total
                 ,vr_p_ult_sequencia);              
       EXCEPTION
          WHEN OTHERS THEN
             pr_cdcritic := 0;
             pr_dscritic := 'Erro ao inserir na CRAPLCX : '||sqlerrm;
                              
             cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                  ,pr_cdagenci => pr_cod_agencia
                                  ,pr_nrdcaixa => pr_nro_caixa
                                  ,pr_cod_erro => pr_cdcritic
                                  ,pr_dsc_erro => pr_dscritic
                                  ,pr_flg_erro => TRUE
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
                                  
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
                RAISE vr_exc_erro;
             END IF;
          
             RAISE vr_exc_erro;
       END;
     CLOSE cr_crapbcx;
     
     OPEN cr_verifica_mrw(rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia
                         ,pr_nro_caixa);
     FETCH cr_verifica_mrw INTO rw_verifica_mrw;
        IF cr_verifica_mrw%FOUND THEN
           
           -- Formata conta integracao
           GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => vr_nro_conta
                                         ,pr_dscalcul => vr_dsdctitg
                                         ,pr_stsnrcal => vr_stsnrcal
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
           -- Se ocorreu erro
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
              
              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => pr_nro_caixa
                                   ,pr_cod_erro => pr_cdcritic
                                   ,pr_dsc_erro => pr_dscritic
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);

              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic; 
                 RAISE vr_exc_erro;
              END IF;

              RAISE vr_exc_erro;
           END IF;
                      
           /* Dinheiro - Nao eh tratato nessa procedure */
                      
           IF rw_verifica_mrw.vlchqcop <> 0 THEN
             
              vr_c_docto := vr_c_docto_salvo || '01' ||'2'; -- 'Sequencial' fixo 01
              
              -- Busca o ultima sequencia de digito
              OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                                  ,rw_dat_cop.dtmvtocd
                                  ,1   -- FIXO
                                  ,100 -- FIXO
                                  ,vr_i_nro_lote);
              FETCH cr_consulta_lot INTO rw_consulta_lot;
              CLOSE cr_consulta_lot;
              
              -- Verifica se Lancamento ja Existe no Dest.
              OPEN cr_existe_lcm(rw_cod_coop_dest.cdcooper
                                ,rw_dat_cop.dtmvtolt
                                ,1
                                ,100
                                ,vr_i_nro_lote
                                ,rw_consulta_lot.nrseqdig); -- Já está encrementado + 1 no CURSOR cr_consulta_lot
              FETCH cr_existe_lcm INTO rw_existe_lcm;
                 IF cr_existe_lcm%FOUND THEN
                    pr_cdcritic := 0;
                    pr_dscritic := 'Lancamento  ja existente';
                                      
                    cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                         ,pr_cdagenci => pr_cod_agencia
                                         ,pr_nrdcaixa => pr_nro_caixa
                                         ,pr_cod_erro => pr_cdcritic
                                         ,pr_dsc_erro => pr_dscritic
                                         ,pr_flg_erro => TRUE
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic); 
                    -- Levantar excecao
                    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                       pr_cdcritic := vr_cdcritic;
                       pr_dscritic := vr_dscritic; 
                       RAISE vr_exc_erro;
                    END IF;

                    RAISE vr_exc_erro;
                 END IF;              
              CLOSE cr_existe_lcm;
              
              OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                                ,rw_dat_cop.dtmvtolt
                                ,1
                                ,100
                                ,vr_i_nro_lote
                                ,pr_nro_conta
                                ,vr_c_docto);
              FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
                 IF cr_existe_lcm1%FOUND THEN
                    pr_cdcritic := 0;
                    pr_dscritic := 'Lancamento(Primario) ja existente';
                                      
                    cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                         ,pr_cdagenci => pr_cod_agencia
                                         ,pr_nrdcaixa => pr_nro_caixa
                                         ,pr_cod_erro => pr_cdcritic
                                         ,pr_dsc_erro => pr_dscritic
                                         ,pr_flg_erro => TRUE
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic); 
                    -- Levantar excecao
                    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                       pr_cdcritic := vr_cdcritic;
                       pr_dscritic := vr_dscritic; 
                       RAISE vr_exc_erro;
                    END IF;

                    RAISE vr_exc_erro;
                 END IF;              
              CLOSE cr_existe_lcm1;
              
              -- Chegou aqui eh porque nao existir lcm, entao cria registro de lcm
              BEGIN
                 INSERT INTO craplcm(cdcooper
                                    ,dtmvtolt
                                    ,cdagenci
                                    ,cdbccxlt
                                    ,dsidenti
                                    ,nrdolote
                                    ,nrdconta
                                    ,nrdocmto
                                    ,vllanmto
                                    ,cdhistor
                                    ,nrseqdig
                                    ,nrdctabb
                                    ,nrautdoc
                                    ,cdpesqbb
                                    ,nrdctitg
                                    ,cdcoptfn
                                    ,cdagetfn
                                    ,nrterfin
                                    ,cdoperad)
                 VALUES (rw_cod_coop_dest.cdcooper
                        ,rw_dat_cop.dtmvtolt
                        ,1
                        ,100
                        ,pr_identifica
                        ,vr_i_nro_lote
                        ,pr_nro_conta
                        ,TO_NUMBER(vr_c_docto)
                        ,rw_verifica_mrw.vlchqcop
                        ,1524 -- 386 - CR.TRF.CH.INT
                        ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                        ,pr_nro_conta
                        ,vr_p_ult_sequencia
                        ,'CRAP22'
                        ,vr_glb_dsdctitg
                        ,rw_cod_coop_orig.cdcooper
                        ,pr_cod_agencia
                        ,pr_nro_caixa
                        ,pr_cod_operador);              
              EXCEPTION
                 WHEN OTHERS THEN
                    pr_cdcritic := 0;
                    pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
                                  
                    cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                         ,pr_cdagenci => pr_cod_agencia
                                         ,pr_nrdcaixa => pr_nro_caixa
                                         ,pr_cod_erro => pr_cdcritic
                                         ,pr_dsc_erro => pr_dscritic
                                         ,pr_flg_erro => TRUE
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                    -- Levantar excecao
                    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                       pr_cdcritic := vr_cdcritic;
                       pr_dscritic := vr_dscritic; 
                       RAISE vr_exc_erro;
                    END IF;

                    RAISE vr_exc_erro;
              END;
              
              vr_i_seq_386 := rw_consulta_lot.nrseqdig;
     
              -- Verifica se existe lote
              OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                                ,rw_dat_cop.dtmvtocd
                                ,1   /* FIXO */
                                ,100 /* FIXO */
                                ,vr_i_nro_lote);
              FETCH cr_existe_lot INTO rw_existe_lot;
                 IF cr_existe_lot%FOUND THEN
                    -- Se nao existir cria a capa de lote
                    BEGIN
                       UPDATE craplot lot
                          SET lot.nrseqdig = lot.nrseqdig + 1
                             ,lot.qtcompln = lot.qtcompln + 1
                             ,lot.qtinfoln = lot.qtinfoln + 1
                             ,lot.vlcompcr = lot.vlcompcr + rw_verifica_mrw.vlchqcop
                             ,lot.vlinfocr = lot.vlinfocr + rw_verifica_mrw.vlchqcop
                        WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                          AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                          AND lot.cdagenci = 1
                          AND lot.cdbccxlt = 100
                          AND lot.nrdolote = vr_i_nro_lote;             
                    EXCEPTION
                       WHEN OTHERS THEN
                          pr_cdcritic := 0;
                          pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                           
                          cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                               ,pr_cdagenci => pr_cod_agencia
                                               ,pr_nrdcaixa => pr_nro_caixa
                                               ,pr_cod_erro => pr_cdcritic
                                               ,pr_dsc_erro => pr_dscritic
                                               ,pr_flg_erro => TRUE
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
                                               
                          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                             pr_cdcritic := vr_cdcritic;
                             pr_dscritic := vr_dscritic; 
                             RAISE vr_exc_erro;
                          END IF;

                          RAISE vr_exc_erro;
                    END;

                 END IF;

              CLOSE cr_existe_lot;
              
           END IF;
                  
        END IF;
     CLOSE cr_verifica_mrw;
     
     vr_nrsequen := 0;
     
     -- Cheque MENOR PRACA
     vr_index := pr_typ_tab_chq.first(); -- Posiciona no primeiro registro
     WHILE vr_index IS NOT NULL LOOP
        IF pr_typ_tab_chq(vr_index).nrdocmto = 3 THEN
          
           /* Sequencial utilizado para separar um lançamento
           em conta para cada data nao ocorrendo duplicidade de chave */
           vr_nrsequen := vr_nrsequen + 1;
           vr_c_docto  := vr_c_docto_salvo || to_char(gene0002.fn_mask(pr_dsorigi => vr_nrsequen, pr_dsforma => '99' )) || pr_typ_tab_chq(vr_index).nrdocmto;
           
           /* Numero de sequencia sera utilizado para identificar cada
           cheque(crapchd) do lancamento total da data */
           pr_typ_tab_chq(vr_index).nrsequen := vr_nrsequen;
           
           -- Busca o ultima sequencia de digito
           OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                               ,rw_dat_cop.dtmvtocd
                               ,1   -- FIXO
                               ,100 -- FIXO
                               ,vr_i_nro_lote);
           FETCH cr_consulta_lot INTO rw_consulta_lot;
           CLOSE cr_consulta_lot;
              
           -- Verifica se Lancamento ja Existe no Dest.
           OPEN cr_existe_lcm(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,1
                             ,100
                             ,vr_i_nro_lote
                             ,rw_consulta_lot.nrseqdig); -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           FETCH cr_existe_lcm INTO rw_existe_lcm;
              IF cr_existe_lcm%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento  ja existente';
                                      
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;              
           CLOSE cr_existe_lcm;
              
           OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                              ,rw_dat_cop.dtmvtolt
                              ,1
                              ,100
                              ,vr_i_nro_lote
                              ,pr_nro_conta
                              ,vr_c_docto);
           FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
              IF cr_existe_lcm1%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento(Primario) ja existente';
                                     
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
           
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;              
            
           CLOSE cr_existe_lcm1;
              
           -- Chegou aqui eh porque nao existir lcm, entao cria registro de lcm
           BEGIN
              INSERT INTO craplcm(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,dsidenti
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrdocmto
                                 ,vllanmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,nrdctabb
                                 ,nrautdoc
                                 ,cdpesqbb
                                 ,nrdctitg
                                 ,cdcoptfn
                                 ,cdagetfn
                                 ,nrterfin
                                 ,cdoperad)
              VALUES (rw_cod_coop_dest.cdcooper
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,pr_identifica
                     ,vr_i_nro_lote
                     ,pr_nro_conta
                     ,TO_NUMBER(vr_c_docto)
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1526  /* 3 DEP.CHQ.PR. */
                     ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                     ,pr_nro_conta
                     ,vr_p_ult_sequencia
                     ,'CRAP22'
                     ,vr_glb_dsdctitg
                     ,rw_cod_coop_orig.cdcooper
                     ,pr_cod_agencia
                     ,pr_nro_caixa
                     ,pr_cod_operador);
                     
                     -- Guarda o sequencial usado no lancamento
                     pr_typ_tab_chq(vr_index).nrseqlcm := rw_consulta_lot.nrseqdig; -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
           END;
           
           -- Verifica se existe lote
           OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtocd
                             ,1   /* FIXO */
                             ,100 /* FIXO */
                             ,vr_i_nro_lote);
           FETCH cr_existe_lot INTO rw_existe_lot;
              IF cr_existe_lot%FOUND THEN
                 BEGIN
                    UPDATE craplot lot
                       SET lot.nrseqdig = lot.nrseqdig + 1
                          ,lot.qtcompln = lot.qtcompln + 1
                          ,lot.qtinfoln = lot.qtinfoln + 1
                          ,lot.vlcompcr = lot.vlcompcr + pr_typ_tab_chq(vr_index).vlcompel
                          ,lot.vlinfocr = lot.vlinfocr + pr_typ_tab_chq(vr_index).vlcompel
                     WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                       AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                       AND lot.cdagenci = 1
                       AND lot.cdbccxlt = 100
                       AND lot.nrdolote = vr_i_nro_lote;             
                 EXCEPTION
                    WHEN OTHERS THEN
                       pr_cdcritic := 0;
                       pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                  
                       cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                            ,pr_cdagenci => pr_cod_agencia
                                            ,pr_nrdcaixa => pr_nro_caixa
                                            ,pr_cod_erro => pr_cdcritic
                                            ,pr_dsc_erro => pr_dscritic
                                            ,pr_flg_erro => TRUE
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          pr_cdcritic := vr_cdcritic;
                          pr_dscritic := vr_dscritic; 
                          RAISE vr_exc_erro;
                       END IF;

                       RAISE vr_exc_erro;

                 END;
              END IF;
           CLOSE cr_existe_lot;
           
           -- Cria registro de Deposito Bloqueado
           BEGIN
              INSERT INTO crapdpb(nrdconta
                                 ,dtliblan
                                 ,cdhistor
                                 ,nrdocmto
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,vllanmto
                                 ,inlibera
                                 ,cdcooper)
              VALUES (pr_nro_conta
                     ,pr_typ_tab_chq(vr_index).dtlibcom
                     ,1526 -- 3
                     ,TO_NUMBER(vr_c_docto)
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,vr_i_nro_lote
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1
                     ,rw_cod_coop_dest.cdcooper);
           
           EXCEPTION
              WHEN OTHERS THEN
                   vr_cdcritic := 0;
                   vr_dscritic := 'Erro ao inserir na CRAPDPB : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => vr_cdcritic
                                        ,pr_dsc_erro => vr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
           END;
           
        END IF;        
        vr_index:= pr_typ_tab_chq.NEXT(vr_index); -- Proximo registro
        
     END LOOP; -- Fim cheques menor praca
     
     vr_nrsequen := 0;
     
     -- Cheque MAIOR PRACA
     vr_index := pr_typ_tab_chq.first(); -- Posiciona no primeiro registro
     WHILE vr_index IS NOT NULL LOOP
        IF pr_typ_tab_chq(vr_index).nrdocmto = 4 THEN
          
           /* Sequencial utilizado para separar um lançamento
           para cada data nao ocorrendo duplicidade de chave */

           vr_nrsequen := vr_nrsequen + 1;
           vr_c_docto  := vr_c_docto_salvo || to_char(gene0002.fn_mask(pr_dsorigi => vr_nrsequen, pr_dsforma => '99' )) || pr_typ_tab_chq(vr_index).nrdocmto;
           
           pr_typ_tab_chq(vr_index).nrsequen := vr_nrsequen;
           
           -- Busca o ultima sequencia de digito
           OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                               ,rw_dat_cop.dtmvtocd
                               ,1   -- FIXO
                               ,100 -- FIXO
                               ,vr_i_nro_lote);
           FETCH cr_consulta_lot INTO rw_consulta_lot;
           CLOSE cr_consulta_lot;
              
           -- Verifica se Lancamento ja Existe no Dest.
           OPEN cr_existe_lcm(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,1
                             ,100
                             ,vr_i_nro_lote
                             ,rw_consulta_lot.nrseqdig); -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           FETCH cr_existe_lcm INTO rw_existe_lcm;
              IF cr_existe_lcm%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento  ja existente';
                                      
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 RAISE vr_exc_erro;
              END IF;              
           CLOSE cr_existe_lcm;
              
           OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                              ,rw_dat_cop.dtmvtolt
                              ,1
                              ,100
                              ,vr_i_nro_lote
                              ,pr_nro_conta
                              ,vr_c_docto);
           FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
              IF cr_existe_lcm1%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento(Primario) ja existente';
                                     
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
           
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;            
           CLOSE cr_existe_lcm1;
              
           -- Chegou aqui eh porque nao existir lcm, entao cria registro de lcm
           BEGIN
              INSERT INTO craplcm(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,dsidenti
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrdocmto
                                 ,vllanmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,nrdctabb
                                 ,nrautdoc
                                 ,cdpesqbb
                                 ,nrdctitg
                                 ,cdcoptfn
                                 ,cdagetfn
                                 ,nrterfin
                                 ,cdoperad)
              VALUES (rw_cod_coop_dest.cdcooper
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,pr_identifica
                     ,vr_i_nro_lote
                     ,pr_nro_conta
                     ,TO_NUMBER(vr_c_docto)
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1526  /* 3 DEP.CHQ.PR. */
                     ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                     ,pr_nro_conta
                     ,vr_p_ult_sequencia
                     ,'CRAP22'
                     ,vr_glb_dsdctitg
                     ,rw_cod_coop_orig.cdcooper
                     ,pr_cod_agencia
                     ,pr_nro_caixa
                     ,pr_cod_operador);
                     
                     -- Guarda o sequencial usado no lancamento
                     pr_typ_tab_chq(vr_index).nrseqlcm := rw_consulta_lot.nrseqdig; -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
           END;
           
           -- Verifica se existe lote
           OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtocd
                             ,1   /* FIXO */
                             ,100 /* FIXO */
                             ,vr_i_nro_lote);
           FETCH cr_existe_lot INTO rw_existe_lot;
              IF cr_existe_lot%FOUND THEN
                 BEGIN
                    UPDATE craplot lot
                       SET lot.nrseqdig = lot.nrseqdig + 1
                          ,lot.qtcompln = lot.qtcompln + 1
                          ,lot.qtinfoln = lot.qtinfoln + 1
                          ,lot.vlcompcr = lot.vlcompcr + pr_typ_tab_chq(vr_index).vlcompel
                          ,lot.vlinfocr = lot.vlinfocr + pr_typ_tab_chq(vr_index).vlcompel
                     WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                       AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                       AND lot.cdagenci = 1
                       AND lot.cdbccxlt = 100
                       AND lot.nrdolote = vr_i_nro_lote;             
                 EXCEPTION
                    WHEN OTHERS THEN
                       pr_cdcritic := 0;
                       pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;

                       cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                            ,pr_cdagenci => pr_cod_agencia
                                            ,pr_nrdcaixa => pr_nro_caixa
                                            ,pr_cod_erro => pr_cdcritic
                                            ,pr_dsc_erro => pr_dscritic
                                            ,pr_flg_erro => TRUE
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          pr_cdcritic := vr_cdcritic;
                          pr_dscritic := vr_dscritic; 
                          RAISE vr_exc_erro;
                       END IF;

                       RAISE vr_exc_erro;
                 END;

              END IF;

           CLOSE cr_existe_lot;
           
           -- Cria registro de Deposito Bloqueado
           BEGIN
              INSERT INTO crapdpb(nrdconta
                                 ,dtliblan
                                 ,cdhistor
                                 ,nrdocmto
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,vllanmto
                                 ,inlibera
                                 ,cdcooper)
              VALUES (pr_nro_conta
                     ,pr_typ_tab_chq(vr_index).dtlibcom
                     ,1526 -- 3
                     ,TO_NUMBER(vr_c_docto)
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,vr_i_nro_lote
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1
                     ,rw_cod_coop_dest.cdcooper);
           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPDPB: '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
           END;
           
        END IF;        
        vr_index:= pr_typ_tab_chq.NEXT(vr_index); -- Proximo registro
        
     END LOOP; -- Fim cheques maior praca
     
     vr_nrsequen := 0;
     
     -- Cheque MENOR FORA PRACA
     vr_index := pr_typ_tab_chq.first(); -- Posiciona no primeiro registro
     WHILE vr_index IS NOT NULL LOOP
        IF pr_typ_tab_chq(vr_index).nrdocmto = 5 THEN
          
           /* Sequencial utilizado para separar um lançamento
           para cada data nao ocorrendo duplicidade de chave */


           vr_nrsequen := vr_nrsequen + 1;
           vr_c_docto  := vr_c_docto_salvo || to_char(gene0002.fn_mask(pr_dsorigi => vr_nrsequen, pr_dsforma => '99' )) || pr_typ_tab_chq(vr_index).nrdocmto;
           pr_typ_tab_chq(vr_index).nrsequen := vr_nrsequen;
           
           -- Busca o ultima sequencia de digito
           OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                               ,rw_dat_cop.dtmvtocd
                               ,1   -- FIXO
                               ,100 -- FIXO
                               ,vr_i_nro_lote);
           FETCH cr_consulta_lot INTO rw_consulta_lot;
           CLOSE cr_consulta_lot;
              
           -- Verifica se Lancamento ja Existe no Dest.
           OPEN cr_existe_lcm(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,1
                             ,100
                             ,vr_i_nro_lote
                             ,rw_consulta_lot.nrseqdig); -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           FETCH cr_existe_lcm INTO rw_existe_lcm;
              IF cr_existe_lcm%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento  ja existente';
                                      
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;              
           CLOSE cr_existe_lcm;
              
           OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                              ,rw_dat_cop.dtmvtolt
                              ,1
                              ,100
                              ,vr_i_nro_lote
                              ,pr_nro_conta
                              ,vr_c_docto);
           FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
              IF cr_existe_lcm1%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento(Primario) ja existente';
                                     
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
           
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;            
           CLOSE cr_existe_lcm1;
              
           -- Chegou aqui eh porque nao existir lcm, entao cria registro de lcm
           BEGIN
              INSERT INTO craplcm(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,dsidenti
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrdocmto
                                 ,vllanmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,nrdctabb
                                 ,nrautdoc
                                 ,cdpesqbb
                                 ,nrdctitg
                                 ,cdcoptfn
                                 ,cdagetfn
                                 ,nrterfin
                                 ,cdoperad)
              VALUES (rw_cod_coop_dest.cdcooper
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,pr_identifica
                     ,vr_i_nro_lote
                     ,pr_nro_conta
                     ,TO_NUMBER(vr_c_docto)
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1523  /** 4 - DEP.CHQ.FPR. **/
                     ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                     ,pr_nro_conta
                     ,vr_p_ult_sequencia
                     ,'CRAP22'
                     ,vr_glb_dsdctitg
                     ,rw_cod_coop_orig.cdcooper
                     ,pr_cod_agencia
                     ,pr_nro_caixa
                     ,pr_cod_operador);
                                          
                     -- Guarda o sequencial usado no lancamento
                     pr_typ_tab_chq(vr_index).nrseqlcm := rw_consulta_lot.nrseqdig; -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
           END;
           
           -- Verifica se existe lote
           OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtocd
                             ,1   /* FIXO */
                             ,100 /* FIXO */
                             ,vr_i_nro_lote);
           FETCH cr_existe_lot INTO rw_existe_lot;
              IF cr_existe_lot%FOUND THEN
                 BEGIN
                    UPDATE craplot lot
                       SET lot.nrseqdig = lot.nrseqdig + 1
                          ,lot.qtcompln = lot.qtcompln + 1
                          ,lot.qtinfoln = lot.qtinfoln + 1
                          ,lot.vlcompcr = lot.vlcompcr + pr_typ_tab_chq(vr_index).vlcompel
                          ,lot.vlinfocr = lot.vlinfocr + pr_typ_tab_chq(vr_index).vlcompel
                     WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                       AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                       AND lot.cdagenci = 1
                       AND lot.cdbccxlt = 100
                       AND lot.nrdolote = vr_i_nro_lote;             
                 EXCEPTION
                    WHEN OTHERS THEN
                       pr_cdcritic := 0;
                       pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                  
                       cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                            ,pr_cdagenci => pr_cod_agencia
                                            ,pr_nrdcaixa => pr_nro_caixa
                                            ,pr_cod_erro => pr_cdcritic
                                            ,pr_dsc_erro => pr_dscritic
                                            ,pr_flg_erro => TRUE
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic); 
                       
                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          pr_cdcritic := vr_cdcritic;
                          pr_dscritic := vr_dscritic; 
                          RAISE vr_exc_erro;
                       END IF;

                       RAISE vr_exc_erro;
                 END;
              END IF;
           CLOSE cr_existe_lot;
           
           -- Cria registro de Deposito Bloqueado
           BEGIN
              INSERT INTO crapdpb(nrdconta
                                 ,dtliblan
                                 ,cdhistor
                                 ,nrdocmto
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,vllanmto
                                 ,inlibera
                                 ,cdcooper)
              VALUES (pr_nro_conta
                     ,pr_typ_tab_chq(vr_index).dtlibcom
                     ,1523 -- 4
                     ,TO_NUMBER(vr_c_docto)
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,vr_i_nro_lote
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1
                     ,rw_cod_coop_dest.cdcooper);                                
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPDPB : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
           END;
           
        END IF;        
        vr_index:= pr_typ_tab_chq.NEXT(vr_index); -- Proximo registro
        
     END LOOP; -- Fim cheques menor fora praca
     
     vr_nrsequen := 0;
     
     -- Cheque MAIOR FORA PRACA
     vr_index := pr_typ_tab_chq.first(); -- Posiciona no primeiro registro
     WHILE vr_index IS NOT NULL LOOP
        IF pr_typ_tab_chq(vr_index).nrdocmto = 6 THEN

           /* Sequencial utilizado para separar um lançamento
           para cada data nao ocorrendo duplicidade de chave */

           vr_nrsequen := vr_nrsequen + 1;
           vr_c_docto  := vr_c_docto_salvo || to_char(gene0002.fn_mask(pr_dsorigi => vr_nrsequen, pr_dsforma => '99' )) || pr_typ_tab_chq(vr_index).nrdocmto;
           pr_typ_tab_chq(vr_index).nrsequen := vr_nrsequen;

           -- Busca o ultima sequencia de digito
           OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                               ,rw_dat_cop.dtmvtocd
                               ,1   -- FIXO
                               ,100 -- FIXO
                               ,vr_i_nro_lote);
           FETCH cr_consulta_lot INTO rw_consulta_lot;
           CLOSE cr_consulta_lot;

           -- Verifica se Lancamento ja Existe no Dest.
           OPEN cr_existe_lcm(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,1
                             ,100
                             ,vr_i_nro_lote
                             ,rw_consulta_lot.nrseqdig); -- Já está encrementado + 1 no CURSOR cr_consulta_lot
           FETCH cr_existe_lcm INTO rw_existe_lcm;
              IF cr_existe_lcm%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento  ja existente';

                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;              
           CLOSE cr_existe_lcm;

           OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                              ,rw_dat_cop.dtmvtolt
                              ,1
                              ,100
                              ,vr_i_nro_lote
                              ,pr_nro_conta
                              ,vr_c_docto);
           FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
              IF cr_existe_lcm1%FOUND THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Lancamento(Primario) ja existente';
                                     
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic); 
                 -- Levantar excecao
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;            
           CLOSE cr_existe_lcm1;
              
           -- Chegou aqui eh porque nao existir lcm, entao cria registro de lcm
           BEGIN
              INSERT INTO craplcm(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,dsidenti
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrdocmto
                                 ,vllanmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,nrdctabb
                                 ,nrautdoc
                                 ,cdpesqbb
                                 ,nrdctitg
                                 ,cdcoptfn
                                 ,cdagetfn
                                 ,nrterfin
                                 ,cdoperad)
              VALUES (rw_cod_coop_dest.cdcooper
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,pr_identifica
                     ,vr_i_nro_lote
                     ,pr_nro_conta
                     ,TO_NUMBER(vr_c_docto)
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1523  /** 4 - DEP.CHQ.FPR. **/
                     ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                     ,pr_nro_conta
                     ,vr_p_ult_sequencia
                     ,'CRAP22'
                     ,vr_glb_dsdctitg
                     ,rw_cod_coop_orig.cdcooper
                     ,pr_cod_agencia
                     ,pr_nro_caixa
                     ,pr_cod_operador);

                     -- Guarda o sequencial usado no lancamento
                     pr_typ_tab_chq(vr_index).nrseqlcm := rw_consulta_lot.nrseqdig; -- Já está encrementado + 1 no CURSOR cr_consulta_lot

           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;

                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
           END;

           -- Verifica se existe lote
           OPEN cr_existe_lot(rw_cod_coop_dest.cdcooper
                             ,rw_dat_cop.dtmvtocd
                             ,1   /* FIXO */
                             ,100 /* FIXO */
                             ,vr_i_nro_lote);
           FETCH cr_existe_lot INTO rw_existe_lot;
              IF cr_existe_lot%FOUND THEN
                 BEGIN
                    UPDATE craplot lot
                       SET lot.nrseqdig = lot.nrseqdig + 1
                          ,lot.qtcompln = lot.qtcompln + 1
                          ,lot.qtinfoln = lot.qtinfoln + 1
                          ,lot.vlcompcr = lot.vlcompcr + pr_typ_tab_chq(vr_index).vlcompel
                          ,lot.vlinfocr = lot.vlinfocr + pr_typ_tab_chq(vr_index).vlcompel
                     WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                       AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                       AND lot.cdagenci = 1
                       AND lot.cdbccxlt = 100
                       AND lot.nrdolote = vr_i_nro_lote;             
                 EXCEPTION
                    WHEN OTHERS THEN
                       pr_cdcritic := 0;
                       pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                  
                       cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                            ,pr_cdagenci => pr_cod_agencia
                                            ,pr_nrdcaixa => pr_nro_caixa
                                            ,pr_cod_erro => pr_cdcritic
                                            ,pr_dsc_erro => pr_dscritic
                                            ,pr_flg_erro => TRUE
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
                                            
                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          pr_cdcritic := vr_cdcritic;
                          pr_dscritic := vr_dscritic; 
                          RAISE vr_exc_erro;
                       END IF;

                       RAISE vr_exc_erro;
                 END;                 
              END IF;
              
           CLOSE cr_existe_lot;
           
           -- Cria registro de Deposito Bloqueado
           BEGIN
              INSERT INTO crapdpb(nrdconta
                                 ,dtliblan
                                 ,cdhistor
                                 ,nrdocmto
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,vllanmto
                                 ,inlibera
                                 ,cdcooper)
              VALUES (pr_nro_conta
                     ,pr_typ_tab_chq(vr_index).dtlibcom
                     ,1523 -- 4
                     ,TO_NUMBER(vr_c_docto)
                     ,rw_dat_cop.dtmvtolt
                     ,1
                     ,100
                     ,vr_i_nro_lote
                     ,pr_typ_tab_chq(vr_index).vlcompel
                     ,1
                     ,rw_cod_coop_dest.cdcooper);           
           EXCEPTION
              WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao atualizar na CRAPDPB : '||sqlerrm;
                                  
                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   -- Levantar excecao
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic; 
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
           END;
           
        END IF;        
        vr_index:= pr_typ_tab_chq.NEXT(vr_index); -- Proximo registro
        
     END LOOP; -- Fim cheques maior fora praca
     
     -- Criacao do LOTE de ORIGEM (DEBITO)
     vr_i_nro_lote    := 11000 + pr_nro_caixa;
     
     -- Verifica se existe lote
     OPEN cr_existe_lot(rw_cod_coop_orig.cdcooper
                       ,rw_dat_cop.dtmvtolt
                       ,pr_cod_agencia   /* FIXO */
                       ,11 /* FIXO */
                       ,vr_i_nro_lote);
     FETCH cr_existe_lot INTO rw_existe_lot;
        IF cr_existe_lot%NOTFOUND THEN
           -- Se nao existir cria a capa de lote
           BEGIN
              INSERT INTO craplot(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,tplotmov
                                 ,nrdcaixa
                                 ,cdopecxa
                                 ,cdhistor
                                 ,cdoperad)
              VALUES (rw_cod_coop_orig.cdcooper
                     ,rw_dat_cop.dtmvtolt
                     ,pr_cod_agencia
                     ,11
                     ,vr_i_nro_lote
                     ,1
                     ,pr_nro_caixa
                     ,pr_cod_operador
                     ,0
                     ,pr_cod_operador);
           EXCEPTION
              WHEN OTHERS THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Erro ao inserir na CRAPLOT: '||sqlerrm;
                                  
                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);

                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic; 
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
           END;
        END IF;
     CLOSE cr_existe_lot;
     
     /*** Criacao da CHD - Cheques Acolhidos  ***/
     FOR rw_verifica_mdw IN cr_verifica_mdw(rw_cod_coop_orig.cdcooper
                                           ,pr_cod_agencia
                                           ,pr_nro_caixa) LOOP
                                           
         -- Busca o ultima sequencia de digito
         OPEN cr_consulta_lot(rw_cod_coop_orig.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,pr_cod_agencia   /* FIXO */
                             ,11 /* FIXO */
                             ,vr_i_nro_lote);
         FETCH cr_consulta_lot INTO rw_consulta_lot;
         CLOSE cr_consulta_lot;
                                           
         -- Formata conta integracao
         GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => rw_verifica_mdw.nrctabdb
                                       ,pr_dscalcul => vr_dsdctitg
                                       ,pr_stsnrcal => vr_stsnrcal
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
                                       
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
            RAISE vr_exc_erro;
         END IF;
                                       
         OPEN cr_consulta_chd(rw_cod_coop_orig.cdcooper
                             ,rw_dat_cop.dtmvtolt
                             ,rw_verifica_mdw.cdcmpchq
                             ,rw_verifica_mdw.cdbanchq
                             ,rw_verifica_mdw.cdagechq
                             ,rw_verifica_mdw.nrctachq
                             ,rw_verifica_mdw.nrcheque);
         FETCH cr_consulta_chd INTO rw_consulta_chd;
            IF cr_consulta_chd%FOUND THEN
              
               pr_cdcritic := 92;
               pr_dscritic := '';

               cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                    ,pr_cdagenci => pr_cod_agencia
                                    ,pr_nrdcaixa => pr_nro_caixa
                                    ,pr_cod_erro => pr_cdcritic
                                    ,pr_dsc_erro => pr_dscritic
                                    ,pr_flg_erro => TRUE
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
               
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  pr_cdcritic := vr_cdcritic;
                  pr_dscritic := vr_dscritic; 
                  RAISE vr_exc_erro;
               END IF;

               RAISE vr_exc_erro;
                                    
            ELSE -- Nao encontrou registro CHD. Entao cria registro
                                    
               IF rw_verifica_mdw.cdhistor = 386 THEN -- DEP.CHQ.COOP.
                  vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo ||'02'||'2');
               END IF;
               
               -- Encontrou registro
               IF pr_typ_tab_chq.exists(TO_CHAR(rw_verifica_mdw.dtlibcom,'DD/MM/RRRR')||
                                        TO_CHAR(LPAD(rw_verifica_mdw.nrdocmto,10,0))) THEN
                  -- Montar chave de busca
                  vr_index :=  TO_CHAR(rw_verifica_mdw.dtlibcom,'DD/MM/RRRR')||
                               TO_CHAR(LPAD(rw_verifica_mdw.nrdocmto,10,0));

                  IF rw_verifica_mdw.cdhistor = 3 THEN -- PRACA MENOR
                     IF rw_verifica_mdw.tpdmovto = 2 THEN
                        vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo||to_char(gene0002.fn_mask(pr_dsorigi => pr_typ_tab_chq(vr_index).nrsequen, pr_dsforma => '99' ))||'3');
                     ELSE
                        vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo||to_char(gene0002.fn_mask(pr_dsorigi => pr_typ_tab_chq(vr_index).nrsequen, pr_dsforma => '99' ))||'4');
                     END IF;
                  ELSE
                     IF rw_verifica_mdw.cdhistor = 4 THEN -- FORA PRACA MENOR
                        IF rw_verifica_mdw.tpdmovto = 2 THEN
                           vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo||to_char(gene0002.fn_mask(pr_dsorigi => pr_typ_tab_chq(vr_index).nrsequen, pr_dsforma => '99' ))||'5');
                        ELSE
                           vr_i_nro_docto := TO_NUMBER(vr_c_docto_salvo||to_char(gene0002.fn_mask(pr_dsorigi => pr_typ_tab_chq(vr_index).nrsequen, pr_dsforma => '99' ))||'6');
                        END IF;
                     END IF;
                  END IF;
                  
                  IF rw_verifica_mdw.cdhistor <> 386 THEN
                     vr_aux_nrseqdig := pr_typ_tab_chq(vr_index).nrseqlcm;
                  END IF;
                  
               END IF;
               
               IF rw_verifica_mdw.nrctaaux > 0 THEN 
                  vr_aux_inchqcop := 1;
               ELSE
                  vr_aux_inchqcop := 0;
               END IF;
               
               IF NVL(rw_consulta_chd.insitchq,0) = 1 THEN
                  vr_aux_nrctachq := rw_verifica_mdw.nrctabdb;
               ELSE
                  vr_aux_nrctachq := rw_verifica_mdw.nrctachq;
               END IF;
               
               IF rw_verifica_mdw.cdhistor = 386 THEN
                  vr_aux_nrseqdig := vr_i_seq_386;
               ELSE
                  /** Incrementa contagem de cheques para a previa **/
                  CXON0000.pc_atualiza_previa_cxa(pr_cooper       => pr_cooper
                                        ,pr_cod_agencia  => pr_cod_agencia
                                        ,pr_nro_caixa    => pr_nro_caixa
                                        ,pr_cod_operador => pr_cod_operador
                                        ,pr_dtmvtolt     => rw_dat_cop.dtmvtolt
                                        ,pr_operacao     => 1 -- Inclusao
                                        ,pr_retorno      => pr_retorno
                                        ,pr_cdcritic     => vr_cdcritic
                                        ,pr_dscritic     => vr_dscritic);
                                        
                  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                     pr_cdcritic := vr_cdcritic;
                     pr_dscritic := vr_dscritic;
                         
                     cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                          ,pr_cdagenci => pr_cod_agencia
                                          ,pr_nrdcaixa => pr_nro_caixa
                                          ,pr_cod_erro => pr_cdcritic
                                          ,pr_dsc_erro => pr_dscritic
                                          ,pr_flg_erro => TRUE
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
                                                
                     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                        pr_cdcritic := vr_cdcritic;
                        pr_dscritic := vr_dscritic; 
                        RAISE vr_exc_erro;
                     END IF;

                     RAISE vr_exc_erro;
                           
                  END IF;                
               END IF;
               
               vr_aux_nrddigv1 := TO_NUMBER(TO_CHAR(gene0002.fn_busca_entrada(1,rw_verifica_mdw.lsdigctr,',')));
               vr_aux_nrddigv2 := TO_NUMBER(TO_CHAR(gene0002.fn_busca_entrada(2,rw_verifica_mdw.lsdigctr,',')));
               vr_aux_nrddigv3 := TO_NUMBER(TO_CHAR(gene0002.fn_busca_entrada(3,rw_verifica_mdw.lsdigctr,',')));
               
               /** Criacao CHD na Acolhedora **/
               BEGIN
                  INSERT INTO crapchd(cdcooper
                                     ,cdagechq
                                     ,cdbanchq
                                     ,cdagenci
                                     ,cdbccxlt
                                     ,nrdocmto
                                     ,cdcmpchq
                                     ,cdoperad
                                     ,cdsitatu
                                     ,dsdocmc7
                                     ,dtmvtolt
                                     ,inchqcop
                                     ,insitchq
                                     ,cdtipchq
                                     ,nrcheque
                                     ,nrctachq
                                     ,nrdconta
                                     ,nrddigc1
                                     ,nrddigc2
                                     ,nrddigc3
                                     ,nrddigv1
                                     ,nrddigv2
                                     ,nrddigv3
                                     ,nrdolote
                                     ,tpdmovto
                                     ,nrterfin
                                     ,vlcheque
                                     ,cdagedst
                                     ,nrctadst
                                     ,nrseqdig)
                  VALUES (rw_cod_coop_orig.cdcooper
                         ,rw_verifica_mdw.cdagechq
                         ,rw_verifica_mdw.cdbanchq
                         ,pr_cod_agencia
                         ,11
                         ,TO_NUMBER(vr_i_nro_docto)
                         ,rw_verifica_mdw.cdcmpchq
                         ,pr_cod_operador
                         ,1
                         ,rw_verifica_mdw.dsdocmc7
                         ,rw_dat_cop.dtmvtolt
                         ,vr_aux_inchqcop
                         ,0
                         ,rw_verifica_mdw.cdtipchq
                         ,rw_verifica_mdw.nrcheque
                         ,vr_aux_nrctachq
                         ,vr_nro_conta
                         ,rw_verifica_mdw.nrddigc1
                         ,rw_verifica_mdw.nrddigc2
                         ,rw_verifica_mdw.nrddigc3
                         ,vr_aux_nrddigv1
                         ,vr_aux_nrddigv2
                         ,vr_aux_nrddigv3
                         ,vr_i_nro_lote
                         ,rw_verifica_mdw.tpdmovto
                         ,0
                         ,rw_verifica_mdw.vlcompel
                         ,rw_cod_coop_dest.cdagectl /* Dep.Intercoop. */
                         ,pr_nro_conta /* Dep.Intercoop. */
                         ,vr_aux_nrseqdig)  /* Sequencia dos lancamentos */
                  RETURNING ROWID
                       INTO vr_rowid_chd;
               EXCEPTION
                  WHEN OTHERS THEN
                       pr_cdcritic := 0;
                       pr_dscritic := 'Erro ao inserir na CRAPCHQ: '||sqlerrm;
                                      
                       cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                            ,pr_cdagenci => pr_cod_agencia
                                            ,pr_nrdcaixa => pr_nro_caixa
                                            ,pr_cod_erro => pr_cdcritic
                                            ,pr_dsc_erro => pr_dscritic
                                            ,pr_flg_erro => TRUE
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
                       -- Levantar excecao
                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          pr_cdcritic := vr_cdcritic;
                          pr_dscritic := vr_dscritic; 
                          RAISE vr_exc_erro;
                       END IF;

                       RAISE vr_exc_erro;
               END;
               
            END IF;
         CLOSE cr_consulta_chd;
         
         /** Cheques Nao Coop - Vai p/ Proximo MDW **/
         IF rw_verifica_mdw.cdhistor <> 386 THEN
            NULL;
         ELSE
            
            /* Efetua Lancamentos de DEBITO nos CHEQUES COOP */
            /* guarda infos da ultima autenticacao 700 */            

            vr_aux_p_literal  := vr_p_literal;
            vr_aux_p_ult_seq  := vr_p_ult_sequencia;
            vr_aux_p_registro := vr_p_registro;
            
            CXON0051.pc_autentica_cheque(pr_cooper          => pr_cooper
                                        ,pr_cod_agencia     => pr_cod_agencia
                                        ,pr_nro_conta       => pr_nro_conta
                                        ,pr_vestorno        => pr_vestorno
                                        ,pr_nro_caixa       => pr_nro_caixa
                                        ,pr_cod_operador    => pr_cod_operador
                                        ,pr_dtmvtolt        => rw_dat_cop.dtmvtolt
                                        ,pr_nro_docmto      => pr_nro_docmto
                                        ,pr_rowid           => rw_verifica_mdw.rowid
                                        ,pr_p_literal       => vr_p_literal
                                        ,pr_p_ult_sequencia => vr_p_ult_sequencia
                                        ,pr_retorno         => pr_retorno       
                                        ,pr_cdcritic        => vr_cdcritic
                                        ,pr_dscritic        => vr_dscritic);
                                        
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := vr_dscritic; 
               RAISE vr_exc_erro;
            END IF;

            -- volta infos da ultima autenticacao 700
            vr_p_literal         := vr_aux_p_literal;
            vr_p_ult_sequencia   := vr_aux_p_ult_seq;
            vr_p_registro        := vr_aux_p_registro;
            
             -- Busca o nro da autenticacao
            OPEN cr_nrautdoc_mdw(rw_verifica_mdw.rowid);
            FETCH cr_nrautdoc_mdw INTO rw_nrautdoc_mdw;
            CLOSE cr_nrautdoc_mdw;
            
            -- Formata conta integracao
            GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => vr_nro_conta
                                          ,pr_dscalcul => vr_dsdctitg
                                          ,pr_stsnrcal => vr_stsnrcal
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
            -- Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               pr_cdcritic := pr_cdcritic;
               pr_dscritic := pr_dscritic;

               cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                    ,pr_cdagenci => pr_cod_agencia
                                    ,pr_nrdcaixa => pr_nro_caixa
                                    ,pr_cod_erro => vr_cdcritic
                                    ,pr_dsc_erro => vr_dscritic
                                    ,pr_flg_erro => TRUE
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  pr_cdcritic := vr_cdcritic;
                  pr_dscritic := vr_dscritic; 
                  RAISE vr_exc_erro;
               END IF;

               RAISE vr_exc_erro;
            END IF;
            
            OPEN cr_rowid_chd(vr_rowid_chd);
            FETCH cr_rowid_chd INTO rw_rowid_chd;
            CLOSE cr_rowid_chd;
            
            OPEN cr_verifica_fdc(rw_cod_coop_orig.cdcooper
                                ,rw_rowid_chd.cdbanchq
                                ,rw_rowid_chd.cdagechq
                                ,rw_rowid_chd.nrctachq
                                ,rw_rowid_chd.nrcheque);
            FETCH cr_verifica_fdc INTO rw_verifica_fdc;
               IF cr_verifica_fdc%FOUND THEN
                 
                  IF cr_verifica_fdc%ISOPEN THEN
                     CLOSE cr_verifica_fdc;
                  END IF;
                  
                  /**verificar se o cheque eh de uma conta que foi migrada**/
                  OPEN cr_verifica_tco(rw_verifica_fdc.cdcooper
                                      ,rw_verifica_fdc.nrdconta);
                  FETCH cr_verifica_tco INTO rw_verifica_tco;                     
                     IF cr_verifica_tco%FOUND THEN
                              
                        -- Verifica se existe lote
                        OPEN cr_existe_lot2(rw_cod_coop_migr.cdcooper
                                           ,rw_dat_cop.dtmvtocd
                                           ,rw_verifica_tco.cdagenci
                                           ,100
                                           ,205000 + rw_verifica_tco.cdagenci);
                        FETCH cr_existe_lot2 INTO rw_existe_lot2;
                           IF cr_existe_lot2%NOTFOUND THEN                                    
                              BEGIN
                                 INSERT INTO craplot(cdcooper
                                                    ,dtmvtolt
                                                    ,cdagenci
                                                    ,cdbccxlt
                                                    ,nrdolote
                                                    ,tplotmov
                                                    ,cdoperad
                                                    ,cdhistor)
                                 VALUES (rw_cod_coop_migr.cdcooper
                                        ,rw_dat_cop.dtmvtolt
                                        ,rw_verifica_tco.cdagenci
                                        ,100
                                        ,205000 + rw_verifica_tco.cdagenci
                                        ,1
                                        ,'1' /* SUPER-USUARIO para migracao */
                                        ,0   /* 700 */
                                        ); /* Sequencia dos lancamentos */
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    pr_cdcritic := 0;
                                    pr_dscritic := 'Erro ao inserir na CRAPLOT: '||sqlerrm;
                                                          
                                    cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                         ,pr_cdagenci => pr_cod_agencia
                                                         ,pr_nrdcaixa => pr_nro_caixa
                                                         ,pr_cod_erro => pr_cdcritic
                                                         ,pr_dsc_erro => pr_dscritic
                                                         ,pr_flg_erro => TRUE
                                                         ,pr_cdcritic => vr_cdcritic
                                                         ,pr_dscritic => vr_dscritic);
                                    -- Levantar excecao
                                    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                       pr_cdcritic := vr_cdcritic;
                                       pr_dscritic := vr_dscritic; 
                                       RAISE vr_exc_erro;
                                    END IF;

                                    RAISE vr_exc_erro;
                              END;
                           END IF;      
                        CLOSE cr_existe_lot2;
                        
                        -- Verifica novamente se existe o lote
                        OPEN cr_existe_lot2(rw_cod_coop_migr.cdcooper
                                           ,rw_dat_cop.dtmvtocd
                                           ,rw_verifica_tco.cdagenci
                                           ,100
                                           ,205000 + rw_verifica_tco.cdagenci);
                        FETCH cr_existe_lot2 INTO rw_existe_lot2;
                        CLOSE cr_existe_lot2;
                        
                        OPEN cr_existe_bcx(rw_cod_coop_orig.cdcooper
                                          ,rw_dat_cop.dtmvtolt
                                          ,pr_cod_agencia
                                          ,pr_nro_caixa
                                          ,pr_cod_operador);
                        FETCH cr_existe_bcx INTO rw_existe_bcx;
                           IF cr_existe_bcx%NOTFOUND THEN
                              pr_cdcritic := 687;
                              pr_dscritic := '';
                                                                  
                              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                   ,pr_cdagenci => pr_cod_agencia
                                                   ,pr_nrdcaixa => pr_nro_caixa
                                                   ,pr_cod_erro => pr_cdcritic
                                                   ,pr_dsc_erro => pr_dscritic
                                                   ,pr_flg_erro => TRUE
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);
                              -- Levantar excecao
                              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                 pr_cdcritic := vr_cdcritic;
                                 pr_dscritic := vr_dscritic; 
                                 RAISE vr_exc_erro;
                              END IF;

                              RAISE vr_exc_erro;
                           END IF;
                        CLOSE cr_existe_bcx;
                         
                        /* Utilizado como base bcaixal.i */              
                        BEGIN
                           INSERT INTO craplcx(cdcooper
                                              ,dtmvtolt
                                              ,cdagenci
                                              ,nrdcaixa
                                              ,cdopecxa
                                              ,nrdocmto
                                              ,nrseqdig
                                              ,nrdmaqui
                                              ,cdhistor
                                              ,dsdcompl
                                              ,vldocmto)
                           VALUES (rw_cod_coop_orig.cdcooper
                                  ,rw_dat_cop.dtmvtolt
                                  ,pr_cod_agencia
                                  ,pr_nro_caixa
                                  ,pr_cod_operador
                                  ,TO_NUMBER(TO_CHAR(rw_verifica_mdw.nrcheque)||TO_CHAR(rw_verifica_mdw.nrddigc3))
                                  ,rw_existe_bcx.qtcompln + 1
                                  ,rw_existe_bcx.nrdmaqui
                                  ,704
                                  ,'Saque da conta sobreposta '||GENE0002.fn_mask(rw_rowid_chd.nrctachq,'ZZZZ.ZZZ.Z')
                                  ,rw_verifica_mdw.vlcompel
                                  );
                        EXCEPTION
                           WHEN OTHERS THEN
                              pr_cdcritic := 0;
                              pr_dscritic := 'Erro ao inserir na CRAPLCX: '||sqlerrm;
                                                 
                              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                   ,pr_cdagenci => pr_cod_agencia
                                                   ,pr_nrdcaixa => pr_nro_caixa
                                                   ,pr_cod_erro => pr_cdcritic
                                                   ,pr_dsc_erro => pr_dscritic
                                                   ,pr_flg_erro => TRUE
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);
                              -- Levantar excecao
                              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                 pr_cdcritic := vr_cdcritic;
                                 pr_dscritic := vr_dscritic; 
                                 RAISE vr_exc_erro;
                              END IF;

                              RAISE vr_exc_erro;
                        END;
                        
                        BEGIN     
                           UPDATE crapbcx bcx
                              SET bcx.qtcompln = bcx.qtcompln + 1
                            WHERE bcx.cdcooper = rw_cod_coop_orig.cdcooper 
                              AND bcx.dtmvtolt = rw_dat_cop.dtmvtolt
                              AND bcx.cdagenci = pr_cod_agencia
                              AND bcx.nrdcaixa = pr_nro_caixa
                              AND bcx.cdopecxa = pr_cod_operador                                                
                              AND bcx.cdsitbcx = 1;          
                        EXCEPTION
                           WHEN OTHERS THEN
                              pr_cdcritic := 0;
                              pr_dscritic := 'Erro ao atualizar CRABCX: '||sqlerrm;
                                               
                              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                   ,pr_cdagenci => pr_cod_agencia
                                                   ,pr_nrdcaixa => pr_nro_caixa
                                                   ,pr_cod_erro => pr_cdcritic
                                                   ,pr_dsc_erro => pr_dscritic
                                                   ,pr_flg_erro => TRUE
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

                              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                 pr_cdcritic := vr_cdcritic;
                                 pr_dscritic := vr_dscritic; 
                                 RAISE vr_exc_erro;
                              END IF;

                              RAISE vr_exc_erro;
                        END;
                                       
                        /* Atualiza os campos de acordo com o tipo
                        da conta do associado que recebe o cheque */
                                          
                        IF rw_verifica_ass.cdtipcta >= 8  AND
                           rw_verifica_ass.cdtipcta <= 11 THEN                       
                                             
                           IF rw_verifica_ass.cdbcochq = 756 THEN -- BANCOOB
                              vr_aux_cdbandep := 756;
                              vr_aux_cdagedep := rw_cod_coop_dest.cdagebcb;
                           ELSE
                              vr_aux_cdbandep := rw_cod_coop_dest.cdbcoctl;
                              vr_aux_cdagedep := rw_cod_coop_dest.cdagectl;
                           END IF;
                        ELSE
                           -- BANCO DO BRASIL - SEM DIGITO
                           vr_aux_cdbandep := 1;
                           vr_aux_cdagedep := SUBSTR(rw_cod_coop_dest.cdagedbb,LENGTH(rw_cod_coop_dest.cdagedbb)-1);
                        END IF;
                                     
                        BEGIN     
                           UPDATE crapfdc fdc
                              SET fdc.incheque = fdc.incheque + 5
                                 ,fdc.dtliqchq = rw_dat_cop.dtmvtolt
                                 ,fdc.cdoperad = pr_cod_operador
                                 ,fdc.vlcheque = rw_verifica_mdw.vlcompel
                                 ,fdc.nrctadep = rw_verifica_ass.nrdconta
                                 ,fdc.cdbandep = vr_aux_cdbandep
                                 ,fdc.cdagedep = vr_aux_cdagedep
                           WHERE fdc.cdcooper = rw_rowid_chd.cdcooper
                             AND fdc.cdbanchq = rw_rowid_chd.cdbanchq
                             AND fdc.cdagechq = rw_rowid_chd.cdagechq
                             AND fdc.nrctachq = rw_rowid_chd.nrctachq
                             AND fdc.nrcheque = rw_rowid_chd.nrcheque;             
                        EXCEPTION
                           WHEN OTHERS THEN
                              pr_cdcritic := 0;
                              pr_dscritic := 'Erro ao atualizar CRAPFDC : '||sqlerrm;
                                               
                              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                   ,pr_cdagenci => pr_cod_agencia
                                                   ,pr_nrdcaixa => pr_nro_caixa
                                                   ,pr_cod_erro => pr_cdcritic
                                                   ,pr_dsc_erro => pr_dscritic
                                                   ,pr_flg_erro => TRUE
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

                              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                 pr_cdcritic := vr_cdcritic;
                                 pr_dscritic := vr_dscritic; 
                                 RAISE vr_exc_erro;
                              END IF;

                              RAISE vr_exc_erro;
                        END;
                                                                                                            
                        /* Pagamento Cheque */
                        BEGIN
                                           
                           IF rw_verifica_fdc.tpcheque = 1  THEN
                              vr_aux_cdhistor := 521;
                           ELSE
                              vr_aux_cdhistor := 26;
                           END IF;

                           INSERT INTO craplcm(cdcooper
                                              ,dtmvtolt
                                              ,cdagenci
                                              ,cdbccxlt
                                              ,dsidenti
                                              ,nrdolote
                                              ,nrdconta
                                              ,nrdocmto
                                              ,vllanmto
                                              ,cdhistor
                                              ,nrseqdig
                                              ,nrdctabb
                                              ,nrautdoc
                                              ,cdpesqbb
                                              ,nrdctitg)
                           VALUES (rw_existe_lot2.cdcooper
                                  ,rw_dat_cop.dtmvtolt
                                  ,rw_existe_lot2.cdagenci
                                  ,rw_existe_lot2.cdbccxlt
                                  ,pr_identifica
                                  ,rw_existe_lot2.nrdolote
                                  ,rw_verifica_tco.nrdconta
                                  ,TO_NUMBER(TO_CHAR(rw_verifica_mdw.nrcheque)||TO_CHAR(rw_verifica_mdw.nrddigc3))
                                  ,rw_verifica_mdw.vlcompel
                                  ,vr_aux_cdhistor
                                  ,rw_existe_lot2.nrseqdig + 1 
                                  ,rw_verifica_mdw.nrctabdb
                                  ,rw_nrautdoc_mdw.nrautdoc
                                  ,'CRAP22,'||rw_verifica_mdw.cdopelib
                                  ,vr_dsdctitg
                                  );
                        EXCEPTION
                           WHEN OTHERS THEN
                                pr_cdcritic := 0;
                                pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
                           
                                cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                     ,pr_cdagenci => pr_cod_agencia
                                                     ,pr_nrdcaixa => pr_nro_caixa
                                                     ,pr_cod_erro => pr_cdcritic
                                                     ,pr_dsc_erro => pr_dscritic
                                                     ,pr_flg_erro => TRUE
                                                     ,pr_cdcritic => vr_cdcritic
                                                     ,pr_dscritic => vr_dscritic);
                                -- Levantar excecao
                                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                   pr_cdcritic := vr_cdcritic;
                                   pr_dscritic := vr_dscritic; 
                                   RAISE vr_exc_erro;
                                END IF;

                                RAISE vr_exc_erro;
                        END;

                        BEGIN
                           UPDATE craplot lot
                              SET lot.nrseqdig = lot.nrseqdig + 1
                                 ,lot.qtcompln = lot.qtcompln + 1
                                 ,lot.qtinfoln = lot.qtinfoln + 1
                                 ,lot.vlcompdb = lot.vlcompdb + rw_verifica_mdw.vlcompel
                                 ,lot.vlinfodb = lot.vlinfodb + rw_verifica_mdw.vlcompel
                            WHERE lot.cdcooper = rw_cod_coop_migr.cdcooper
                              AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                              AND lot.cdagenci = rw_verifica_tco.cdagenci
                              AND lot.cdbccxlt = 100
                              AND lot.nrdolote = 205000 + rw_verifica_tco.cdagenci;             
                        EXCEPTION
                           WHEN OTHERS THEN
                              pr_cdcritic := 0;
                              pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                               
                              cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                   ,pr_cdagenci => pr_cod_agencia
                                                   ,pr_nrdcaixa => pr_nro_caixa
                                                   ,pr_cod_erro => pr_cdcritic
                                                   ,pr_dsc_erro => pr_dscritic
                                                   ,pr_flg_erro => TRUE
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

                              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                 pr_cdcritic := vr_cdcritic;
                                 pr_dscritic := vr_dscritic; 
                                 RAISE vr_exc_erro;
                              END IF;

                              RAISE vr_exc_erro;
                        END;
                               
                     ELSE
                             
                        /* Atualiza os campos de acordo com o tipo
                        da conta do associado que recebe o cheque */
                                          
                        IF rw_verifica_ass.cdtipcta >= 8  AND
                           rw_verifica_ass.cdtipcta <= 11 THEN                       
                                             
                           IF rw_verifica_ass.cdbcochq = 756 THEN -- BANCOOB
                              vr_aux_cdbandep := 756;
                              vr_aux_cdagedep := rw_cod_coop_dest.cdagebcb;
                           ELSE
                              vr_aux_cdbandep := rw_cod_coop_dest.cdbcoctl;
                              vr_aux_cdagedep := rw_cod_coop_dest.cdagectl;
                           END IF;
                        ELSE
                           -- BANCO DO BRASIL - SEM DIGITO
                           vr_aux_cdbandep := 1;
                           vr_aux_cdagedep := SUBSTR(rw_cod_coop_dest.cdagedbb,LENGTH(rw_cod_coop_dest.cdagedbb)-1);
                        END IF;                      
                        
                        BEGIN
                                          
                           UPDATE crapfdc fdc
                              SET fdc.incheque = fdc.incheque + 5
                                 ,fdc.dtliqchq = rw_dat_cop.dtmvtolt
                                 ,fdc.cdoperad = pr_cod_operador
                                 ,fdc.vlcheque = rw_verifica_mdw.vlcompel
                                 ,fdc.nrctadep = rw_verifica_ass.nrdconta
                                 ,fdc.cdbandep = vr_aux_cdbandep
                                 ,fdc.cdagedep = vr_aux_cdagedep
                            WHERE fdc.cdcooper = rw_rowid_chd.cdcooper
                              AND fdc.cdbanchq = rw_rowid_chd.cdbanchq
                              AND fdc.cdagechq = rw_rowid_chd.cdagechq
                              AND fdc.nrctachq = rw_rowid_chd.nrctachq
                              AND fdc.nrcheque = rw_rowid_chd.nrcheque;              
                         EXCEPTION
                            WHEN OTHERS THEN
                               vr_cdcritic := 0;
                               vr_dscritic := 'Erro ao atualizar CRAPFDC : '||sqlerrm;
                                                               
                               cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                    ,pr_cdagenci => pr_cod_agencia
                                                    ,pr_nrdcaixa => pr_nro_caixa
                                                    ,pr_cod_erro => vr_cdcritic
                                                    ,pr_dsc_erro => vr_dscritic
                                                    ,pr_flg_erro => TRUE
                                                    ,pr_cdcritic => vr_cdcritic
                                                    ,pr_dscritic => vr_dscritic);
                               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                  pr_cdcritic := vr_cdcritic;
                                  pr_dscritic := vr_dscritic; 
                                  RAISE vr_exc_erro;
                               END IF;

                               RAISE vr_exc_erro;
                         END;
                                                                                                            
                         /* Pagamento Cheque */
                         BEGIN
                                           
                            IF  rw_verifica_fdc.tpcheque = 1  THEN
                                vr_aux_cdhistor := 21;
                            ELSE
                                vr_aux_cdhistor := 26;
                            END IF;

                            INSERT INTO craplcm(cdcooper
                                               ,dtmvtolt
                                               ,cdagenci
                                               ,cdbccxlt
                                               ,dsidenti
                                               ,nrdolote
                                               ,nrdconta
                                               ,nrdocmto
                                               ,vllanmto
                                               ,cdhistor
                                               ,nrseqdig
                                               ,nrdctabb
                                               ,nrautdoc
                                               ,cdpesqbb
                                               ,nrdctitg)
                            VALUES (rw_cod_coop_orig.cdcooper
                                   ,rw_dat_cop.dtmvtolt
                                   ,pr_cod_agencia
                                   ,11
                                   ,pr_identifica
                                   ,vr_i_nro_lote
                                   ,rw_verifica_mdw.nrctaaux
                                   ,TO_NUMBER(TO_CHAR(rw_verifica_mdw.nrcheque)||TO_CHAR(rw_verifica_mdw.nrddigc3))
                                   ,rw_verifica_mdw.vlcompel
                                   ,vr_aux_cdhistor
                                   ,rw_consulta_lot.nrseqdig -- Já está encrementado + 1 no CURSOR cr_consulta_lot
                                   ,rw_verifica_mdw.nrctabdb
                                   ,rw_nrautdoc_mdw.nrautdoc
                                   ,'CRAP22,'||rw_verifica_mdw.cdopelib
                                   ,vr_dsdctitg);
                         EXCEPTION
                            WHEN OTHERS THEN
                                 pr_cdcritic := 0;
                                 pr_dscritic := 'Erro ao inserir na CRAPLCM : '||sqlerrm;
                         
                                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                      ,pr_cdagenci => pr_cod_agencia
                                                      ,pr_nrdcaixa => pr_nro_caixa
                                                      ,pr_cod_erro => pr_cdcritic
                                                      ,pr_dsc_erro => pr_dscritic
                                                      ,pr_flg_erro => TRUE
                                                      ,pr_cdcritic => vr_cdcritic
                                                      ,pr_dscritic => vr_dscritic);
                                 -- Levantar excecao
                                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                    pr_cdcritic := vr_cdcritic;
                                    pr_dscritic := vr_dscritic; 
                                    RAISE vr_exc_erro;
                                 END IF;

                                 RAISE vr_exc_erro;
                         END;

                         BEGIN
                            UPDATE craplot lot
                               SET lot.nrseqdig = lot.nrseqdig + 1
                                  ,lot.qtcompln = lot.qtcompln + 1
                                  ,lot.qtinfoln = lot.qtinfoln + 1
                                  ,lot.vlcompdb = lot.vlcompdb + rw_verifica_mdw.vlcompel
                                  ,lot.vlinfodb = lot.vlinfodb + rw_verifica_mdw.vlcompel
                             WHERE lot.cdcooper = rw_cod_coop_orig.cdcooper
                               AND lot.dtmvtolt = rw_dat_cop.dtmvtocd
                               AND lot.cdagenci = pr_cod_agencia
                               AND lot.cdbccxlt = 11
                               AND lot.nrdolote = vr_i_nro_lote;  
                         EXCEPTION
                            WHEN OTHERS THEN
                               pr_cdcritic := 0;
                               pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;
                                                        
                               cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                    ,pr_cdagenci => pr_cod_agencia
                                                    ,pr_nrdcaixa => pr_nro_caixa
                                                    ,pr_cod_erro => pr_cdcritic
                                                    ,pr_dsc_erro => pr_dscritic
                                                    ,pr_flg_erro => TRUE
                                                    ,pr_cdcritic => vr_cdcritic
                                                    ,pr_dscritic => vr_dscritic); 
                               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                  pr_cdcritic := vr_cdcritic;
                                  pr_dscritic := vr_dscritic; 
                                  RAISE vr_exc_erro;
                               END IF;

                               RAISE vr_exc_erro;
                         END;                 
                                                    
                      END IF;                       
                   CLOSE cr_verifica_tco;
                     
               END IF;
                     
            IF cr_verifica_fdc%ISOPEN THEN
               CLOSE cr_verifica_fdc;
            END IF;

         END IF;

     END LOOP; -- Fim do FOR CRAPMDW
     
     IF vr_de_valor_total = 0 THEN
        pr_cdcritic := 296;
        pr_dscritic := '';

        cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => pr_nro_caixa
                             ,pr_cod_erro => pr_cdcritic
                             ,pr_dsc_erro => pr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                             
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := vr_dscritic; 
           RAISE vr_exc_erro;
        END IF;
 
        RAISE vr_exc_erro;
     END IF;
     
     pr_literal_autentica := '';
     
     /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/

     /** Cooperativa Remetente **/
     
     --Populando vetor
     vr_tab_literal.DELETE;
     vr_tab_literal(1):= TRIM(rw_cod_coop_orig.nmrescop) ||' - '||TRIM(rw_cod_coop_orig.nmextcop);
     vr_tab_literal(2):= ' ';
     vr_tab_literal(3):= TO_CHAR(rw_dat_cop.dtmvtolt,'DD/MM/RR')  ||' '||
                         TO_CHAR(SYSDATE,'HH24:MI:SS') || ' PA  ' ||
                         TRIM(TO_CHAR(gene0002.fn_mask(pr_cod_agencia,'999'))) || '  CAIXA: '  ||
                         TO_CHAR(gene0002.fn_mask(pr_nro_caixa,'Z99')) || '/' ||
                         SUBSTR(pr_cod_operador,1,10);
     vr_tab_literal(4):= ' ';
     vr_tab_literal(5):= '      ** COMPROVANTE DE DEPOSITO '||TRIM(TO_CHAR(SUBSTR(vr_i_nro_docto,1,5),'999G999'))|| ' **';
     vr_tab_literal(6):= ' ';
     vr_tab_literal(7):= 'AGENCIA: '||TRIM(TO_CHAR(rw_cod_coop_dest.cdagectl,'9999')) || ' - ' ||TRIM(rw_cod_coop_dest.nmrescop);
     vr_tab_literal(8):= 'CONTA: '||TRIM(TO_CHAR(pr_nro_conta,'9999G999G9')) ||
                         '   PA: ' || TRIM(TO_CHAR(rw_verifica_ass.cdagenci));
     vr_tab_literal(9):=  '       ' || TRIM(rw_verifica_ass.nmprimtl); -- NOME TITULAR 1
     vr_tab_literal(10):= '       ' || TRIM(vr_nmsegntl); -- NOME TITULAR 2
     vr_tab_literal(11):= ' ';
     
     IF NVL(pr_identifica,' ') <> ' ' THEN
        vr_tab_literal(12):= 'DEPOSITO POR ';
        vr_tab_literal(13):= TRIM(pr_identifica);
        vr_tab_literal(14):= ' ';
     ELSE
        vr_tab_literal(12):= ' ';
        vr_tab_literal(13):= ' ';
        vr_tab_literal(14):= ' ';   
     END IF;
     
     vr_tab_literal(15):= '   TIPO DE DEPOSITO     VALOR EM R$ LIBERACAO EM';
     vr_tab_literal(16):= '------------------------------------------------';
     
     IF vr_de_cooperativa  > 0 THEN
        vr_tab_literal(17):= 'CHEQ.COOPERATIVA...: ' ||
                             TO_CHAR(vr_de_cooperativa,'999G999G999D99');
     END IF;
     
     vr_tab_literal(22):= ' ';
     vr_tab_literal(23):= 'TOTAL DEPOSITADO...: '||
                          TO_CHAR(vr_de_valor_total,'999G999G999D99');
     vr_tab_literal(24):= ' ';
     vr_tab_literal(25):= vr_p_literal;
     vr_tab_literal(26):= ' ';
     vr_tab_literal(27):= ' ';
     vr_tab_literal(28):= ' ';
     vr_tab_literal(29):= ' ';
     vr_tab_literal(30):= ' ';
     vr_tab_literal(31):= ' ';
     vr_tab_literal(32):= ' ';
     vr_tab_literal(33):= ' ';
     vr_tab_literal(34):= ' ';
     vr_tab_literal(35):= ' ';
     
     -- Inicializa Variavel
     pr_literal_autentica := NULL;
     
     pr_literal_autentica:= RPAD(NVL(vr_tab_literal(1),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(2),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(3),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(4),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(5),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(6),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(7),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(8),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(9),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(10),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(11),'  '),48,' ');
     
     IF NVL(vr_tab_literal(13),' ') <> ' ' THEN
        pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(12),'  '),48,' ');
        pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(13),'  '),48,' ');
        pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(14),'  '),48,' ');
     END IF;
     
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(15),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(16),'  '),48,' ');
     
     IF vr_de_cooperativa  > 0 THEN
        pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(17),'  '),48,' ');
     END IF;
     
     vr_index := pr_typ_tab_chq.first(); -- Posiciona no primeiro registro
     WHILE vr_index IS NOT NULL LOOP
       
        IF pr_typ_tab_chq(vr_index).nrdocmto = 3 THEN
           pr_literal_autentica := pr_literal_autentica || RPAD('CHEQ.PRACA MENOR...: '||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).vlcompel,'999G999G999D99') ||
                                                           '   ' ||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).dtlibcom,'DD/MM/RR')
                                                           ,48,' ');
        END IF;
        IF pr_typ_tab_chq(vr_index).nrdocmto = 4 THEN
           pr_literal_autentica := pr_literal_autentica || RPAD('CHEQ.PRACA MAIOR...: '||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).vlcompel,'999G999G999D99') ||
                                                           '   ' ||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).dtlibcom,'DD/MM/RR')
                                                           ,48,' ');
        END IF;
        IF pr_typ_tab_chq(vr_index).nrdocmto = 5 THEN
           pr_literal_autentica := pr_literal_autentica || RPAD('CHEQ.F.PRACA MENOR.: '||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).vlcompel,'999G999G999D99') ||
                                                           '   ' ||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).dtlibcom,'DD/MM/RR')
                                                           ,48,' ');
        END IF;
        IF pr_typ_tab_chq(vr_index).nrdocmto = 6 THEN
           pr_literal_autentica := pr_literal_autentica || RPAD('CHEQ.F.PRACA MAIOR.: '||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).vlcompel,'999G999G999D99') ||
                                                           '   ' ||
                                                           TO_CHAR(pr_typ_tab_chq(vr_index).dtlibcom,'DD/MM/RR')
                                                           ,48,' ');
        END IF;       
        vr_index:= pr_typ_tab_chq.NEXT(vr_index); -- Proximo registro
        
     END LOOP; -- Fim cheques maior fora praca
     
     /* Obs: Existe um limitacao do PROGRESS que não suporta a quantidada maxima de uma
     variavel VARCHAR2(32627), a solucao foi definir um tamanho para o parametro no 
     Dicionario de Dados para resolver o estouro da variavel VARCHAR2 */     
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(22),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(23),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(24),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(25),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(26),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(27),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(28),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(29),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(30),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(31),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(32),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(33),'  '),48,' ');
     pr_literal_autentica:= pr_literal_autentica||RPAD(NVL(vr_tab_literal(34),'  '),48,' ');
     /* O dataserver elimina os espaçoes em branco a esquerda de uma string, a solução
     encontrada foi colocar um caracter curinga para ser substituido por um espaço em
     branco no lado do progress. Dessa forma não é desconsiderado os espaços em branco. */
     pr_literal_autentica:= pr_literal_autentica||LPAD(NVL('#','  '),48,' ');
     
     pr_ult_seq_autentica := vr_p_ult_sequencia;
     
     /* Autenticacao REC */
     BEGIN
        UPDATE crapaut
           SET crapaut.dslitera = pr_literal_autentica
         WHERE crapaut.ROWID = vr_p_registro;
       
        --Se nao atualizou registro
        IF SQL%ROWCOUNT = 0 THEN
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro Sistema - CRAPAUT nao Encontrado';
           RAISE vr_exc_erro;
        END IF;
         
     EXCEPTION
        WHEN Others THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro ao atualizar tabela crapaut.'||sqlerrm;
         RAISE vr_exc_erro;
     END;
     
     pr_retorno  := 'OK';
     COMMIT;
     
  EXCEPTION
     WHEN vr_exc_erro THEN
         ROLLBACK; -- Desfaz as operacoes
         pr_retorno           := 'NOK';
         pr_literal_autentica := NULL;
         pr_ult_seq_autentica := NULL;
         pr_nro_docmto        := NULL;
         
         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => pr_nro_caixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
                              
         -- Levantar excecao
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;            
         END IF;

     WHEN OTHERS THEN
         ROLLBACK;
         pr_retorno           := 'NOK';
         pr_literal_autentica := NULL;
         pr_ult_seq_autentica := NULL;
         pr_nro_docmto        := NULL;
         pr_cdcritic          := 0;
         pr_dscritic          := 'Erro na rotina CXON0022.pc_realiz_dep_chq_mig_host. '||SQLERRM;
         
         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => pr_nro_caixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
                              
         -- Levantar excecao
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;            
         END IF;

  END pc_realiz_dep_chq_mig_host;
  
END CXON0022;
/
