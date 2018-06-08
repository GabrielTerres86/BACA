CREATE OR REPLACE PACKAGE cecred.CHEQ0001 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CHEQ0001
  --  Sistema  : Rotinas focadas no sistema de Cheques
  --  Sigla    : GENE
  --  Autor    : Marcos Ernani Martini - Supero
  --  Data     : Maio/2013.                   Ultima atualizacao: 13/09/2013
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas auxiliares para o sistema de cheques
  --
  --   Alteracoes: 13/09/2013 - Incluido o procedimento pc_numtal (Edison - AMcom)
  --
  --               03/02/2015 - Movida a procedure pc_obtem_depos_identificad 
  --                            para a package extr0001. (Alisson - AMcom)
  --
  --               22/12/2015 - Ajustado a lista de alineas que nao podem ser tarifadas
  --                            conforme revisao de alineas e processo de devolucao de cheque 
  --                            (Douglas - Melhoria 100)
	--
	--               04/07/2016 - Adicionados busca_taloes_car para gera��o de relat�rio
  --                            (Lucas Lunelli - PROJ290 Cartao CECRED no CaixaOnline)													 
	--
  --               04/05/2018 - Adicionado novo parametro opcional na rotina "pc_gera_devolucao_cheque"
  --                            para permitir inserir devolu��o j� processada (pr_insitdev = 1).
  --                            Somente iremos usar o parametro para devolu��es que n�o forem de taxas (<> 46).
  --                            (Wagner/Susten��o - Chamado #861675).
  --
  --                29/05/2018 - Inclusao de rotinas para baixa de arquivos CCF do FTP da ABBC. Chamado SCTASK0012791 (Heitor - Mouts)
  ---------------------------------------------------------------------------------------------------------------

  -- Definicao to tipo de array para teste da cdalinea na crepdev
  TYPE typ_tab_cdalinea IS VARRAY(24) OF NUMBER(2);
  -- Vetor de mem�ria com as alineas que nao podem ser tarifadas
  vr_vet_cdalinea typ_tab_cdalinea:= typ_tab_cdalinea(20,25,26,27,28,30,33,34,35,37,38,39,40,41,42,43,44,48,49,59,61,64,71,72);

  /* Retonar se a alinea informada est� ou n�o no vetor */
  FUNCTION fn_existe_alinea (pr_cdalinea NUMBER) RETURN BOOLEAN;       --> Codigo da alinea a ser verificada

  /* Rotina para criar registros de devolucao/taxa de cheques. */
  PROCEDURE pc_gera_devolucao_cheque  (pr_cdcooper IN crapdev.cdcooper%TYPE    --> C�digo da cooperativa
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE    --> Data do movimento
                                      ,pr_cdbccxlt IN crapdev.cdbccxlt%TYPE    --> C�digo do banco/caixa do lote
                                      ,pr_cdbcoctl IN crapdev.cdbccxlt%TYPE    --> C�digo do banco centralizador
                                      ,pr_inchqdev NUMBER                      --> Indicador de Cheque devolvido
                                      ,pr_nrdconta IN crapdev.nrdconta%TYPE    --> N�mero da conta processada
                                      ,pr_nrdocmto IN crapdev.nrcheque%TYPE    --> N�mero do cheque
                                      ,pr_nrdctitg IN crapdev.nrdctitg%TYPE    --> N�mero da conta integra��o
                                      ,pr_vllanmto IN crapdev.vllanmto%TYPE    --> Valor do lan�amento
                                      ,pr_cdalinea IN crapdev.cdalinea%TYPE    --> C�digo da Alinea
                                      ,pr_cdhistor IN crapdev.cdhistor%TYPE    --> C�digo do Hist�rico
                                      ,pr_cdoperad IN crapdev.cdoperad%TYPE    --> C�digo do Operador
                                      ,pr_cdagechq IN crapfdc.cdagechq%TYPE    --> C�digo da agencia do cheque
                                      ,pr_nrctachq IN crapfdc.nrctachq%TYPE    --> N�mero da conta do cheque
                                      ,pr_cdprogra IN VARCHAR2                 --> C�digo do programa que est� executando
                                      ,pr_nrdrecid IN crapfdc.progress_recid%TYPE --> N�mero do recid do progress
                                      ,pr_vlchqvlb IN NUMBER                      --> Valor VLB do cheque
                                      ,pr_insitdev IN crapdev.insitdev%TYPE DEFAULT 0 --> Situacao: 0 - a devolver, 1 - devolvido.
                                      ,pr_cdcritic IN OUT NUMBER                  --> C�digo da critica gerado pela rotina
                                      ,pr_des_erro IN OUT VARCHAR2);              --> Descri��o do erro ocorrido na rotina

  /* Rotina para verificar possiveis fraudes de cheque */
  PROCEDURE pc_verifica_fraude_cheque (pr_cdcooper IN crapdev.cdcooper%TYPE      --> Cooperativa
                                      ,pr_cdagectl IN crapfdc.cdagechq%TYPE      --> C�digo da Agencia do Cheque
                                      ,pr_nrctachq IN craprej.nrdconta%TYPE      --> Numero da Conta do Cheque
                                      ,pr_dtrefere IN craprej.dtrefere%TYPE      --> Data de Referencia
                                      ,pr_nrdconta IN craprej.nrdconta%TYPE      --> Numero da Conta
                                      ,pr_nrdocmto IN craprej.nrdocmto%TYPE      --> Numero do Documento
                                      ,pr_vllanmto IN craprej.vllanmto%TYPE      --> Valor do Lan�amento
                                      ,pr_nrseqdig IN craprej.nrseqdig%TYPE      --> Numero sequencial
                                      ,pr_cdpesqbb IN craprej.cdpesqbb%TYPE      --> C�digo Pesquisa
                                      ,pr_des_erro OUT VARCHAR2);                --> Descri��o de erro

  /* Procedure para gerar tabela de busca de cheques BBrasil */
  PROCEDURE pc_gera_cheques(pr_nrtipoop    IN NUMBER                                --> Tipo de opera��o
                           ,pr_cdcooper    IN NUMBER                                --> C�digo cooperativa
                           ,pr_lscontas    IN VARCHAR2                              --> Lista de contas
                           ,pr_nriniseq    IN NUMBER                                --> Inicial da sequencia
                           ,pr_nrregist    IN NUMBER                                --> Numero registro
                           ,pr_auxnrregist IN OUT NUMBER                            --> Auxiliar do n�mero do registro
                           ,pr_qtregist    IN OUT NUMBER                            --> Quantidade registros
                           ,pr_tab_cheques IN OUT NOCOPY gene0007.typ_mult_array    --> Pl table de cheques
                           ,pr_nrcheque    IN crapfdc.nrcheque%TYPE                 --> N�mero cheque
                           ,pr_nrdigchq    IN crapfdc.nrdigchq%TYPE                 --> D�gito cheque
                           ,pr_cdbanchq    IN crapfdc.cdbanchq%TYPE                 --> C�digo banco cheque
                           ,pr_nrseqems    IN crapfdc.nrseqems%TYPE                 --> N�mero da sequencia
                           ,pr_tpforchq    IN crapfdc.tpforchq%TYPE                 --> Tipo cheque
                           ,pr_nrdctitg    IN crapfdc.nrdctitg%TYPE                 --> N�mero tag
                           ,pr_nrpedido    IN crapfdc.nrpedido%TYPE                 --> N�mero pedido
                           ,pr_vlcheque    IN crapfdc.vlcheque%TYPE                 --> Valor do cheque
                           ,pr_cdtpdchq    IN crapfdc.cdtpdchq%TYPE                 --> Tipo do cheque
                           ,pr_cdbandep    IN crapfdc.cdbandep%TYPE                 --> C�digo bandeira
                           ,pr_cdagedep    IN crapfdc.cdagedep%TYPE                 --> C�digo agencia
                           ,pr_nrctadep    IN crapfdc.nrctadep%TYPE                 --> N�mero conta
                           ,pr_cdbantic    IN crapfdc.cdbantic%TYPE                 --> C�digo tipo do banco
                           ,pr_cdagetic    IN crapfdc.cdagetic%TYPE                 --> C�digo tipo da agencia
                           ,pr_nrctatic    IN crapfdc.nrctatic%TYPE                 --> c�digo tipo da conta
                           ,pr_dtlibtic    IN crapfdc.dtlibtic%TYPE                 --> Data libera��o
                           ,pr_tpcheque    IN crapfdc.tpcheque%TYPE                 --> Tipo do cheque
                           ,pr_incheque    IN crapfdc.incheque%TYPE                 --> Entrada cheque
                           ,pr_dtemschq    IN crapfdc.dtemschq%TYPE                 --> Data limite
                           ,pr_dtretchq    IN crapfdc.dtretchq%TYPE                 --> Data retirada
                           ,pr_dtliqchq    IN crapfdc.dtliqchq%TYPE                 --> Data liquida��o
                           ,pr_nrdctabb    IN crapfdc.nrdctabb%TYPE                 --> N�mero da conta BB
                           ,pr_cdagechq    IN crapfdc.cdagechq%TYPE                 --> C�digo agencia cheque
                           ,pr_nrctachq    IN crapfdc.nrctachq%TYPE                 --> N�mero conta cheque
                           ,pr_dsdocmc7    IN crapfdc.dsdocmc7%TYPE                 --> Descri��o documento CMC - 7
                           ,pr_cdcmpchq    IN crapfdc.cdcmpchq%TYPE                 --> Campo cheque
                           ,pr_cdageaco    IN crapfdc.cdageaco%TYPE                 --> Agencia Acolhedora
                           ,pr_fim         OUT BOOLEAN                              --> Controle de sa�da da execu��o externa
                           ,pr_des_erro    OUT VARCHAR2);                           --> Retorno de erro

  /* Calcular o CMC-7 do cheque */
  PROCEDURE pc_calc_cmc7_difcompe(pr_cdbanchq IN NUMBER         --> C�digo do banco
                                 ,pr_cdcmpchq IN NUMBER         --> C�digo compensa��o
                                 ,pr_cdagechq IN NUMBER         --> C�digo agencia
                                 ,pr_nrctachq IN NUMBER         --> N�mero conta cheque
                                 ,pr_nrcheque IN NUMBER         --> N�mero cheque
                                 ,pr_tpcheque IN NUMBER         --> tipo de cheque
                                 ,pr_dsdocmc7 OUT VARCHAR2      --> Descri��o CMC-7
                                 ,pr_des_erro OUT VARCHAR2);    --> Erros no processo

  -- Calcular a quantidade de taloes e a posi��o do cheque no tal�o
  PROCEDURE pc_numtal( pr_nrfolhas  IN NUMBER   --> n�mero de folhas do talon�rio
                      ,pr_nrcalcul  IN NUMBER   --> n�mero da primeira/�ltima folha de cheque emitida nesse pedido
                      ,pr_nrtalchq OUT NUMBER   --> n�mero do tal�o
                      ,pr_nrposchq OUT NUMBER); --> posi��o do cheque

  
  --  Calcular os digitos do CMC-7
  PROCEDURE pc_dig_cmc7 (pr_dsdocmc7 IN  VARCHAR2   -- Documento cmc7
                        ,pr_nrdcampo OUT NUMBER     -- Numero do campo
                        ,pr_lsdigctr OUT VARCHAR2); -- Lista de digitos

  --Subrotina para obter cheques depositados
  PROCEDURE pc_obtem_cheques_deposito (pr_cdcooper     IN crapcop.cdcooper%TYPE              --Codigo Cooperativa
                                        ,pr_cdagenci     IN crapass.cdagenci%TYPE              --Codigo Agencia
                                        ,pr_nrdcaixa     IN INTEGER                            --Numero do Caixa
                                        ,pr_cdoperad     IN VARCHAR2                           --Codigo Operador
                                        ,pr_nmdatela     IN VARCHAR2                           --Nome da Tela
                                        ,pr_idorigem     IN INTEGER                            --Origem dos Dados
                                        ,pr_nrdconta     IN crapass.nrdconta%TYPE              --Numero da Conta do Associado
                                        ,pr_idseqttl     IN INTEGER                            --Sequencial do Titular
                                        ,pr_dtiniper     IN DATE                               --Data Inicio periodo   
                                        ,pr_dtfimper     IN DATE                               --Data Final periodo
                                        ,pr_flgpagin     IN BOOLEAN                            --Imprimir pagina
                                        ,pr_iniregis     IN INTEGER                            --Indicador Registro
                                        ,pr_qtregpag     IN INTEGER                            --Quantidade Registros Pagos
                                        ,pr_flgerlog     IN BOOLEAN                            --Imprimir log
                                        ,pr_qtregist     OUT INTEGER                           --Quantidade Registros
                                        ,pr_des_reto     OUT VARCHAR2                          --Retorno OK ou NOK
                                        ,pr_tab_erro     OUT gene0001.typ_tab_erro             --Tabela de Erros
                                        ,pr_tab_extrato_cheque OUT extr0002.typ_tab_extrato_cheque);    --Vetor para o retorno das informa��es
                                        
                                          
    -- TELA: CHEQUE - Matriz de Cheques
    PROCEDURE pc_busca_cheque(pr_cdcooper  IN     NUMBER           --> C�digo cooperativa
                             ,pr_nrtipoop  IN     NUMBER           --> Tipo de opera��o
                             ,pr_nrdconta  IN     NUMBER           --> N�mero da conta
                             ,pr_nrcheque  IN     NUMBER           --> N�mero de cheque
                             ,pr_nrregist  IN     NUMBER           --> N�mero de registro
                             ,pr_nriniseq  IN     NUMBER           --> Inicial da sequencia
                             ,pr_xmllog    IN     VARCHAR2         --> XML com informa��es de LOG
                             ,pr_cdcritic     OUT PLS_INTEGER      --> C�digo da cr�tica
                             ,pr_dscritic     OUT VARCHAR2         --> Descri��o da cr�tica
                             ,pr_retxml    IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                             ,pr_nmdcampo     OUT VARCHAR2         --> Nome do campo com erro
                             ,pr_des_erro     OUT VARCHAR2);       --> Erros do processo
  
    -- TELA: CHEQUE - Matriz de Cheques - Buscar a conta
    PROCEDURE pc_verif_conta(pr_xmllog    IN     VARCHAR2         --> XML com informa��es de LOG
                            ,pr_cdcritic     OUT PLS_INTEGER      --> C�digo da cr�tica
                            ,pr_dscritic     OUT VARCHAR2         --> Descri��o da cr�tica
                            ,pr_retxml    IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                            ,pr_nmdcampo     OUT VARCHAR2         --> Nome do campo com erro
                            ,pr_des_erro     OUT VARCHAR2);       --> Erros do processo

    -- Verificar possivel fraude dos cheques de outras instituicoes com sinistros (UNICRED).                       
    PROCEDURE pc_ver_fraude_chq_extern (pr_cdcooper IN NUMBER                                  --> Cooperativa
                                      ,pr_cdprogra IN VARCHAR2                                --> Programa chamador
                                       ,pr_cdbanco  IN tbchq_sinistro_outrasif.cdbanco%TYPE    --> N�mero do Banco do Chque
                                       ,pr_nrcheque IN tbchq_sinistro_outrasif.nrcheque%TYPE   --> Numero do Cheque
                                       ,pr_nrctachq IN tbchq_sinistro_outrasif.nrcontachq%TYPE --> Numero da Conta do Cheque
                                       ,pr_cdoperad IN tbchq_sinistro_outrasif.cdoperad%TYPE   --> Operador 
                                       ,pr_cdagenci IN tbchq_sinistro_outrasif.cdagencia%TYPE  --> C�digo da Agencia do Cheque
                                       ,pr_des_erro OUT VARCHAR2);                             --> Descri��o do erro 

  /* Rotina para criar registros de devolucao/taxa de cheques. */
  PROCEDURE pc_gera_devolu_cheque_car (pr_cdcooper  IN crapdev.cdcooper%TYPE    --> C�digo da cooperativa
                                      ,pr_dtmvtolt  IN VARCHAR2                 --> Data do movimento
                                      ,pr_cdbccxlt  IN crapdev.cdbccxlt%TYPE    --> C�digo do banco/caixa do lote
                                      ,pr_cdbcoctl  IN crapdev.cdbccxlt%TYPE    --> C�digo do banco centralizador
                                      ,pr_inchqdev  IN NUMBER                   --> Indicador de Cheque devolvido
                                      ,pr_nrdconta  IN crapdev.nrdconta%TYPE    --> N�mero da conta processada
                                      ,pr_nrdocmto  IN crapdev.nrcheque%TYPE    --> N�mero do cheque
                                      ,pr_nrdctitg  IN crapdev.nrdctitg%TYPE    --> N�mero da conta integra��o
                                      ,pr_vllanmto  IN crapdev.vllanmto%TYPE    --> Valor do lan�amento
                                      ,pr_cdalinea  IN crapdev.cdalinea%TYPE    --> C�digo da Alinea
                                      ,pr_cdhistor  IN crapdev.cdhistor%TYPE    --> C�digo do Hist�rico
                                      ,pr_cdoperad  IN crapdev.cdoperad%TYPE    --> C�digo do Operador
                                      ,pr_cdagechq  IN crapfdc.cdagechq%TYPE    --> C�digo da agencia do cheque
                                      ,pr_nrctachq  IN crapfdc.nrctachq%TYPE    --> N�mero da conta do cheque
                                      ,pr_cdprogra  IN VARCHAR2                 --> C�digo do programa que est� executando
                                      ,pr_nrdrecid  IN crapfdc.progress_recid%TYPE --> N�mero do recid do progress
                                      ,pr_vlchqvlb  IN NUMBER                      --> Valor VLB do cheque
                                      ,pr_cdcritic OUT NUMBER                  --> C�digo da critica gerado pela rotina
                                      ,pr_des_erro OUT VARCHAR2);              --> Descri��o do erro ocorrido na rotina

	PROCEDURE pc_busca_talonarios_car (pr_cdcooper  IN crapcop.cdcooper%TYPE
		                              ,pr_dtini     IN DATE 
									  ,pr_dtfim     IN DATE 
									  ,pr_cdagenci  IN crapage.cdagenci%TYPE
		                              ,pr_clobxmlc  OUT CLOB                  --XML com informa��es de LOG
									  ,pr_des_erro  OUT VARCHAR2              --> Status erro
                                      ,pr_dscritic  OUT VARCHAR2);            --> Retorno de erro																			

  PROCEDURE pc_busca_ccf_transabbc;

END CHEQ0001;
/
CREATE OR REPLACE PACKAGE BODY cecred.CHEQ0001 AS
  /* ---------------------------------------------------------------------------------------------------------------

    Programa : CHEQ0001
    Sistema  : Rotinas focadas no sistema de Cheques
    Sigla    : GENE
    Autor    : Marcos Ernani Martini - Supero
    Data     : Maio/2013.                   Ultima atualizacao: 24/11/2017

   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Centralizar rotinas auxiliares para o sistema de cheques 
  
   Alteracao: 24/08/2015 - Incluir nova procedure pc_ver_fraude_chq_extern
                           Melhoria 217 (Lucas Ranghetti #320543)
                                                     
              10/06/2016 - Ajustado para gerar os registros conforme era gerado no 
                           fonte progress (Lucas Ranghetti #422753)
													 
      			  04/07/2016 - Adicionados busca_taloes_car para gera��o de relat�rio
                            (Lucas Lunelli - PROJ290 Cartao CECRED no CaixaOnline)
                            
              13/10/2016 - #497744 Modificada a consulta de cheque sinistrado na rotina 
                           pc_ver_fraude_chq_extern pois a parte do cmc7 que pertence a
                           conta tbm contem o c�digo de seguran�a, que poder� variar (Carlos)
                           
              25/04/2017 - Na procedure pc_busca_cheque incluir >= na busca do todos pr_nrtipoop = 5 para 
                           trazer todos os cheques a partir do informado (Lucas Ranghetti #625222)
                           
              11/10/2017 - Na procedure pc_busca_cheque mudar ordenacao do select pra trazer os 
                           ultimos cheques emitidos primeiro qdo a opcao for TODOS na tela (Tiago #725346)

              19/10/2017 - Ajuste para pegar corretamente a observa��o do cheque
			               (Adriano - SD 774552)
                     
              24/11/2017 - Quando usar a opcao todos e filtrar pelo nr cheque
                           deve ordenar a lista pelo numero do cheque (Tiago/Adriano)
                     
  --------------------------------------------------------------------------------------------------------------- */


  -- Variaveis globais
  vr_cdprogra crapprg.cdprogra%TYPE;

  /* Retonar se a alinea informada est� ou n�o no vetor */
  FUNCTION fn_existe_alinea (pr_cdalinea NUMBER) RETURN BOOLEAN IS
    -- ..........................................................................
    --
    --  Programa : fn_existe_alinea
    --  Sistema  : Processos Batch
    --  Sigla    : BTCH
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Janeiro/2013.                   Ultima atualizacao: 13/09/2013
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Verificar se a alinea passada como parametro se encontra no array
    --
    --   Alteracoes: 13/09/2013 - Incluido o procedimento pc_numtal (Edison - AMcom)
    --
    -- .............................................................................
  BEGIN
    --Verificar se tem itens no vetor
    IF vr_vet_cdalinea.Count > 0 THEN
      --Percorrer o vetor
      FOR IDX IN vr_vet_cdalinea.FIRST..vr_vet_cdalinea.LAST LOOP
        --Se encontou
        IF vr_vet_cdalinea(IDX) = pr_cdalinea THEN
          RETURN(TRUE);
        END IF;
      END LOOP;
      RETURN(FALSE);
    END IF;
  END fn_existe_alinea;

  /* Rotina para criar registros de devolucao/taxa de cheques. */
  PROCEDURE pc_gera_devolucao_cheque  (pr_cdcooper IN crapdev.cdcooper%TYPE
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                      ,pr_cdbccxlt IN crapdev.cdbccxlt%TYPE
                                      ,pr_cdbcoctl IN crapdev.cdbccxlt%TYPE
                                      ,pr_inchqdev IN NUMBER
                                      ,pr_nrdconta IN crapdev.nrdconta%TYPE
                                      ,pr_nrdocmto IN crapdev.nrcheque%TYPE
                                      ,pr_nrdctitg IN crapdev.nrdctitg%TYPE
                                      ,pr_vllanmto IN crapdev.vllanmto%TYPE
                                      ,pr_cdalinea IN crapdev.cdalinea%TYPE
                                      ,pr_cdhistor IN crapdev.cdhistor%TYPE
                                      ,pr_cdoperad IN crapdev.cdoperad%TYPE
                                      ,pr_cdagechq IN crapfdc.cdagechq%TYPE
                                      ,pr_nrctachq IN crapfdc.nrctachq%TYPE
                                      ,pr_cdprogra IN VARCHAR2
                                      ,pr_nrdrecid IN crapfdc.progress_recid%TYPE
                                      ,pr_vlchqvlb IN NUMBER
                                      ,pr_insitdev IN crapdev.insitdev%TYPE DEFAULT 0
                                      ,pr_cdcritic IN OUT NUMBER
                                      ,pr_des_erro IN OUT VARCHAR2) IS
  BEGIN
/* .............................................................................

   Programa: pc_gera_devolucao_cheque  Antigo Fontes/geradev.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/94.                     Ultima atualizacao: 21/06/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para criar registros de devolucao/taxa de cheques.

   Alteracoes: 16/05/95 - Alterado para incluir o parametro aux_cdalinea
                          (Edson).

               21/01/96 - Alterado para nao gerar taxa de devolucao para as
                          alineas 28 e 29 (Deborah).

               24/01/97 - Alterado para tratar historico 191 no lugar do
                          47 (Deborah).

               22/06/99 - Tratar novos parametros para devolucao(Odair)

               28/08/2001 - Tratar alinea 20 (Deborah).

               11/10/2004 - Tratar alinea 72 (Ze).

               17/12/2004 - Tratar RECID do craplcm (Edson).

               22/04/2005 - Tratar alinea 32 (Edson).

               27/06/2005 - Melhorar a forma como mostra a SOMA dos lotes
                            na pesquisa da devolucao (Edson).

               01/07/2005 - Alimentado campo cdcooper da tabela crapdev (Diego).

               11/07/2005 - Melhorar a forma como mostra a SOMA dos lotes
                            na pesquisa da devolucao (Edson).

               01/11/2005 - Tratar conta integracao (Edson).

               09/12/2005 - Tratamento da estratura do crapfdc (ZE).

               22/12/2005 - Identificacao se eh conta integracao (ZE).

               10/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               15/12/2006 - Tratar Alinea 35 para nao cobrar tarifa (Ze).

               12/02/2007 - Efetuada alteracao para nova estrutura crapdev
                            (Diego).

               06/03/2007 - Ajustes para o Bancoob (Magui).

               03/08/2007 - Tratar Alinea 30 para nao cobrar tarifa (Ze).

               30/03/2010 - Passa a utilizar o par_cdcooper ao inves do
                            glb_cdcooper (Ze).

               25/06/2009 - Inclusao de tratamento para Devolucoes banco CECRED
                            (Guilherme/Supero).

               06/06/2011 - Tratamento para a alinea 37 e 39 - Truncagem (Ze).

               07/07/2011 - Nao tarifar devolucao de alinea 31 (Diego).

               03/08/2012 - Enviar email quando inchqdev = 1 ou 3 e cdbanchq = 1
                            ou 756. (Fabricio)

               06/08/2012 - Adicionado parametro de entrada par_cdprogra.
                            (Fabricio)

               20/12/2012 - Adaptacao para a Migracao AltoVale (Ze).

               18/12/2012 - Convers�o Progress -> Oracle  (Alisson - AMcom)
               
               16/01/2014 - Tratamento Migracao Acredi/Viacredi (Gabriel). 
               
               20/02/2014 - Ajustado o insert da crapdev para o historico 46.
                            Estava fixo 'TCO' e foi mudado para receber a variavel vr_aux_cdpesqui 

			   12/02/2016 - Alterado o formato para as datas utilizadas
						   (Adriano).

               23/03/2016 - Ajustar o substr e o formato da data que esta gravada
                            no campo craplcm.cdpesqbb (Douglas - Melhoria 100 Alineas)
                            
               21/06/2017 - Remo��o de 2 condi��es que tratam o envio de e-mail referente
                            a cheques VLB. PRJ367 - Compe Sessao Unica (Lombardi)
............................................................................. */
    DECLARE

      /* Declaracao de Cursores */

      --Selecionar informacoes dos lancamentos
      CURSOR cr_craplcm (pr_progress_recid IN craplcm.progress_recid%TYPE) IS
        SELECT craplcm.cdpesqbb
              ,craplcm.cdagenci
              ,craplcm.cdbccxlt
              ,craplcm.nrdolote
        FROM craplcm craplcm
        WHERE craplcm.progress_recid = pr_progress_recid;
      rw_craplcm cr_craplcm%ROWTYPE;

      --Selecionar informacoes dos lotes
      CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                        ,pr_cdagenci IN craplot.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT  craplot.dtmvtolt
               ,craplot.cdagenci
               ,craplot.cdbccxlt
               ,craplot.nrdolote
               ,craplot.vlcompcc
               ,craplot.vlcompdb
        FROM craplot  craplot
        WHERE craplot.cdcooper = pr_cdcooper
        AND   craplot.dtmvtolt = pr_dtmvtolt
        AND   craplot.cdagenci = pr_cdagenci
        AND   craplot.cdbccxlt = pr_cdbccxlt
        AND   craplot.nrdolote = pr_nrdolote;
      rw_craplot  cr_craplot%ROWTYPE;

      --Selecionar informacoes de debito
      CURSOR cr_crapcdb (pr_cdcooper IN crapcdb.cdcooper%TYPE
                        ,pr_dtmvtolt IN crapcdb.dtmvtolt%TYPE
                        ,pr_cdagenci IN crapcdb.cdagenci%TYPE
                        ,pr_cdbccxlt IN crapcdb.cdbccxlt%TYPE
                        ,pr_nrdolote IN crapcdb.nrdolote%TYPE
                        ,pr_nrseqdig IN crapcdb.nrseqdig%TYPE) IS
        SELECT crapcdb.vlcheque
              ,crapcdb.cdcmpchq
              ,crapcdb.cdbanchq
              ,crapcdb.cdagechq
              ,crapcdb.nrctachq
              ,crapcdb.nrcheque
              ,crapcdb.dtmvtolt
        FROM crapcdb  crapcdb
        WHERE  crapcdb.cdcooper = pr_cdcooper
        AND    crapcdb.dtmvtolt = pr_dtmvtolt
        AND    crapcdb.cdagenci = pr_cdagenci
        AND    crapcdb.cdbccxlt = pr_cdbccxlt
        AND    crapcdb.nrdolote = pr_nrdolote
        AND    crapcdb.nrseqdig = pr_nrseqdig;
      rw_crapcdb cr_crapcdb%ROWTYPE;

      --Selecionar informacoes de debito
     CURSOR cr_crapcdb2 (pr_cdcooper IN crapcdb.cdcooper%TYPE
                        ,pr_dtmvtolt IN crapcdb.dtmvtolt%TYPE
                        ,pr_cdagenci IN crapcdb.cdagenci%TYPE
                        ,pr_cdbccxlt IN crapcdb.cdbccxlt%TYPE
                        ,pr_nrdolote IN crapcdb.nrdolote%TYPE
                        ,pr_inchqcop IN crapcdb.inchqcop%TYPE) IS
        SELECT crapcdb.vlcheque
              ,crapcdb.cdcmpchq
              ,crapcdb.cdbanchq
              ,crapcdb.cdagechq
              ,crapcdb.nrctachq
              ,crapcdb.nrcheque
              ,crapcdb.dtmvtolt
              ,crapcdb.inchqcop
        FROM crapcdb  crapcdb
        WHERE  crapcdb.cdcooper = pr_cdcooper
        AND    crapcdb.dtmvtolt = pr_dtmvtolt
        AND    crapcdb.cdagenci = pr_cdagenci
        AND    crapcdb.cdbccxlt = pr_cdbccxlt
        AND    crapcdb.nrdolote = pr_nrdolote
        AND    crapcdb.inchqcop = pr_inchqcop;
      rw_crapcdb2 cr_crapcdb2%ROWTYPE;

      --Selecionar informacoes de custodia
      CURSOR cr_crapcst (pr_cdcooper IN crapcst.cdcooper%TYPE
                        ,pr_dtmvtolt IN crapcst.dtmvtolt%TYPE
                        ,pr_cdagenci IN crapcst.cdagenci%TYPE
                        ,pr_cdbccxlt IN crapcst.cdbccxlt%TYPE
                        ,pr_nrdolote IN crapcst.nrdolote%TYPE
                        ,pr_inchqcop IN crapcst.inchqcop%TYPE) IS
        SELECT crapcst.vlcheque
              ,crapcst.inchqcop
        FROM crapcst  crapcst
        WHERE  crapcst.cdcooper = pr_cdcooper
        AND    crapcst.dtmvtolt = pr_dtmvtolt
        AND    crapcst.cdagenci = pr_cdagenci
        AND    crapcst.cdbccxlt = pr_cdbccxlt
        AND    crapcst.nrdolote = pr_nrdolote
        AND    crapcst.inchqcop = pr_inchqcop;
      rw_crapcst cr_crapcst%ROWTYPE;
    

      CURSOR cr_crapcst2 (pr_cdcooper IN crapcst.cdcooper%TYPE
                         ,pr_cdcmpchq IN crapcst.cdcmpchq%TYPE
                         ,pr_cdbanchq IN crapcst.cdbanchq%TYPE
                         ,pr_cdagechq IN crapcst.cdagechq%TYPE
                         ,pr_nrctachq IN crapcst.nrctachq%TYPE
                         ,pr_nrcheque IN crapcst.nrcheque%TYPE
                         ,pr_dtdevolu IN crapcst.dtdevolu%TYPE) IS
        SELECT crapcst.dtmvtolt
              ,crapcst.cdagenci
              ,crapcst.cdbccxlt
              ,crapcst.nrdolote
              ,crapcst.nrseqdig
        FROM crapcst  crapcst
        WHERE crapcst.cdcooper = pr_cdcooper
        AND   crapcst.cdcmpchq = pr_cdcmpchq
        AND   crapcst.cdbanchq = pr_cdbanchq
        AND   crapcst.cdagechq = pr_cdagechq
        AND   crapcst.nrctachq = pr_nrctachq
        AND   crapcst.nrcheque = pr_nrcheque
        AND   crapcst.dtdevolu = pr_dtdevolu;
      rw_crapcst2 cr_crapcst2%ROWTYPE;

      --Selecionar Transferencias entre cooperativas
      CURSOR cr_craptco (pr_cdcopant IN craptco.cdcopant%TYPE
                        ,pr_nrctaant IN craptco.nrctaant%TYPE
                        ,pr_tpctatrf IN craptco.tpctatrf%TYPE
                        ,pr_flgativo IN craptco.flgativo%TYPE) IS
        SELECT craptco.cdcopant
              ,craptco.nrctaant
              ,craptco.nrdconta
              ,craptco.cdageant
        FROM craptco craptco
        WHERE craptco.cdcopant = pr_cdcopant
        AND   craptco.nrctaant = pr_nrctaant
        AND   craptco.tpctatrf = pr_tpctatrf
        AND   craptco.flgativo = pr_flgativo
        AND   ROWNUM = 1;
      rw_craptco cr_craptco%ROWTYPE;

      /* Selecionar devolu��es de cheque ou taxas de devolu��o */
      CURSOR cr_crapdev (pr_cdcooper IN crapdev.cdcooper%TYPE
                        ,pr_cdbanchq IN crapdev.cdbanchq%TYPE
                        ,pr_cdagechq IN crapdev.cdagechq%TYPE
                        ,pr_nrctachq IN crapdev.nrctachq%TYPE
                        ,pr_nrcheque IN crapdev.nrcheque%TYPE
                        ,pr_cdhistor IN crapdev.cdhistor%TYPE) IS
        SELECT rowid
        FROM crapdev crapdev
        WHERE crapdev.cdcooper = pr_cdcooper
        AND   crapdev.cdbanchq = pr_cdbanchq
        AND   crapdev.cdagechq = pr_cdagechq
        AND   crapdev.nrctachq = pr_nrctachq
        AND   crapdev.nrcheque = pr_nrcheque
        AND   crapdev.cdhistor = pr_cdhistor;
      rw_crapdev  cr_crapdev%ROWTYPE;


      /* Selecionar devolu��es de cheque ou taxas de devolu��o */
      CURSOR cr_crapdev_union (pr_cdcooper IN crapdev.cdcooper%TYPE
                              ,pr_cdbanchq IN crapdev.cdbanchq%TYPE
                              ,pr_cdagechq IN crapdev.cdagechq%TYPE
                              ,pr_nrctachq IN crapdev.nrctachq%TYPE
                              ,pr_nrcheque IN crapdev.nrcheque%TYPE
                              ,pr_cdhistor IN crapdev.cdhistor%TYPE) IS
        SELECT rowid
        FROM crapdev crapdev
        WHERE crapdev.cdcooper = pr_cdcooper
        AND   crapdev.cdbanchq = pr_cdbanchq
        AND   crapdev.cdagechq = pr_cdagechq
        AND   crapdev.nrctachq = pr_nrctachq
        AND   crapdev.nrcheque = pr_nrcheque
        AND   crapdev.cdhistor = pr_cdhistor
        UNION ALL
        SELECT rowid
        FROM crapdev crapdev
        WHERE crapdev.cdcooper = pr_cdcooper
        AND   crapdev.cdbanchq = pr_cdbanchq
        AND   crapdev.cdagechq = pr_cdagechq
        AND   crapdev.nrctachq = pr_nrctachq
        AND   crapdev.nrcheque = pr_nrcheque
        AND   crapdev.cdhistor = 46;
      rw_crapdev_union  cr_crapdev_union%ROWTYPE;

      
      /* Declara��o de variaveis locais*/
      vr_ind_dtmvtolt  DATE;
      vr_indctitg      INTEGER;
      vr_ind_cdagenci  INTEGER;
      vr_ind_cdbccxlt  INTEGER;
      vr_ind_nrdolote  INTEGER;
      vr_ind_nrseqdig  INTEGER;
      vr_aux_vldasoma  NUMBER;
      vr_aux_cdbanchq  INTEGER;
      vr_aux_vlchqvlb  NUMBER;
      vr_nrdctabb      NUMBER;
      vr_des_erro      VARCHAR2(4000);
      vr_email_dest    VARCHAR2(1000);
      vr_aux_conteudo  VARCHAR2(1000);
      vr_aux_cdpesqui  VARCHAR2(100);
      vr_des_assunto   VARCHAR2(100);
      vr_exc_sair      EXCEPTION;
      vr_exc_erro      EXCEPTION;

    BEGIN

       --Atribuir valor da variavel para parametro
       vr_aux_vlchqvlb:= Nvl(pr_vlchqvlb,0);


       --Inicializar variaveis
       pr_cdcritic:= 0;
       vr_des_erro:= NULL;
       vr_aux_cdpesqui:= NULL;

       IF pr_cdbccxlt = 756 THEN
         vr_aux_cdbanchq:= 756;
       ELSE
         IF pr_cdbccxlt = pr_cdbcoctl THEN
           vr_aux_cdbanchq:= pr_cdbcoctl;
         ELSE
           vr_aux_cdbanchq:= 1;
         END IF;
       END IF;

       --Se o recid foi informado
       IF pr_nrdrecid > 0 THEN
         --Selecionar informacoes dos lancamentos
         OPEN cr_craplcm (pr_progress_recid => pr_nrdrecid);
         --Posicionar no proximo registro
         FETCH cr_craplcm INTO rw_craplcm;
         --Se encontrou registro
         IF cr_craplcm%FOUND THEN
           -- Verificar Cheque custodia/desconto
           IF rw_craplcm.cdagenci = 1      AND
              rw_craplcm.cdbccxlt = 100    AND
              (rw_craplcm.nrdolote = 4500   OR rw_craplcm.nrdolote = 4501)  THEN
             vr_aux_cdpesqui:= rw_craplcm.cdpesqbb;

             -- Ajustar o substr da data 
             vr_ind_dtmvtolt:= To_Date(SUBSTR(rw_craplcm.cdpesqbb,01,10),'DD/MM/RRRR');

             vr_ind_cdagenci:= TO_NUMBER(SUBSTR(rw_craplcm.cdpesqbb,12,03));
             vr_ind_cdbccxlt:= TO_NUMBER(SUBSTR(rw_craplcm.cdpesqbb,16,03));
             vr_ind_nrdolote:= TO_NUMBER(SUBSTR(rw_craplcm.cdpesqbb,20,06));
             vr_ind_nrseqdig:= TO_NUMBER(SUBSTR(rw_craplcm.cdpesqbb,27,05));
             vr_aux_vldasoma:= 0;

             --Selecionar informacoes dos lotes
             OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                             ,pr_dtmvtolt => vr_ind_dtmvtolt
                             ,pr_cdagenci => vr_ind_cdagenci
                             ,pr_cdbccxlt => vr_ind_cdbccxlt
                             ,pr_nrdolote => vr_ind_nrdolote);
             --Posicionar no proximo registro
             FETCH cr_craplot INTO rw_craplot;
             --Se encontrou registro
             IF cr_craplot%FOUND THEN
               --Se for custodia
               IF  rw_craplcm.nrdolote = 4500 THEN
                 --Selecionar informacoes de Custodia
                 FOR rw_crapcst IN cr_crapcst (pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                              ,pr_cdagenci => rw_craplot.cdagenci
                                              ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                              ,pr_nrdolote => rw_craplot.nrdolote
                                              ,pr_inchqcop => 1) LOOP
                   vr_aux_vldasoma:= Nvl(vr_aux_vldasoma,0) + rw_crapcst.vlcheque;
                 END LOOP; --rw_crapcst
                 vr_aux_cdpesqui:= vr_aux_cdpesqui || ' SOMA = '||LTrim(RTRIM(gene0002.fn_mask(vr_aux_vldasoma,'zzz.zzz.zz9,99')));
               ELSIF rw_craplcm.nrdolote = 4501 THEN --Desconto
                 --Selecionar informacoes de desconto
                 OPEN cr_crapcdb (pr_cdcooper => pr_cdcooper
                                 ,pr_dtmvtolt => vr_ind_dtmvtolt
                                 ,pr_cdagenci => vr_ind_cdagenci
                                 ,pr_cdbccxlt => vr_ind_cdbccxlt
                                 ,pr_nrdolote => vr_ind_nrdolote
                                 ,pr_nrseqdig => vr_ind_nrseqdig);
                 --Posicionar no proximo registro
                 FETCH cr_crapcdb INTO rw_crapcdb;
                 --Se encontrou registro
                 IF cr_crapcdb%FOUND THEN
                   --Selecionar informacoes de Custodia
                   OPEN cr_crapcst2 (pr_cdcooper => pr_cdcooper
                                    ,pr_cdcmpchq => rw_crapcdb.cdcmpchq
                                    ,pr_cdbanchq => rw_crapcdb.cdbanchq
                                    ,pr_cdagechq => rw_crapcdb.cdagechq
                                    ,pr_nrctachq => rw_crapcdb.nrctachq
                                    ,pr_nrcheque => rw_crapcdb.nrcheque
                                    ,pr_dtdevolu => rw_crapcdb.dtmvtolt);
                   --Posicionar no proximo registro
                   FETCH cr_crapcst2 INTO rw_crapcst2;
                   --Se encontrou
                   IF cr_crapcst2%NOTFOUND THEN
                     --Selecionar cheques do bordero de desconto
                     FOR rw_crapcdb2 IN cr_crapcdb2 (pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                                    ,pr_cdagenci => rw_craplot.cdagenci
                                                    ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                                    ,pr_nrdolote => rw_craplot.nrdolote
                                                    ,pr_inchqcop => 1) LOOP
                       vr_aux_vldasoma:= vr_aux_vldasoma + rw_crapcdb2.vlcheque;
                     END LOOP;
                   ELSE
                     vr_ind_dtmvtolt:= rw_crapcst2.dtmvtolt;
                     vr_ind_cdagenci:= rw_crapcst2.cdagenci;
                     vr_ind_cdbccxlt:= rw_crapcst2.cdbccxlt;
                     vr_ind_nrdolote:= rw_crapcst2.nrdolote;
                     vr_aux_cdpesqui:= To_Char(vr_ind_dtmvtolt,'DD/MM/RRRR')||'-'||
                                       To_Char(vr_ind_cdagenci,'999') ||'-'||
                                       To_Char(vr_ind_cdbccxlt,'999') ||'-'||
                                       TO_CHAR(vr_ind_nrdolote,'999999')||'-'||
                                       TO_CHAR(rw_crapcst2.nrseqdig,'99999');
                     vr_aux_vldasoma:= 0;
                     --Selecionar informacoes de Custodia
                     FOR rw_crapcst IN cr_crapcst (pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => vr_ind_dtmvtolt
                                                  ,pr_cdagenci => vr_ind_cdagenci
                                                  ,pr_cdbccxlt => vr_ind_cdbccxlt
                                                  ,pr_nrdolote => vr_ind_nrdolote
                                                  ,pr_inchqcop => 1) LOOP
                       vr_aux_vldasoma:= Nvl(vr_aux_vldasoma,0) + rw_crapcst.vlcheque;
                     END LOOP; --rw_crapcst
                   END IF;
                   vr_aux_cdpesqui:= vr_aux_cdpesqui || ' SOMA = '||LTrim(RTRIM(gene0002.fn_mask(vr_aux_vldasoma,'zzz.zzz.zz9,99')));
                   --Fechar Cursor
                   CLOSE cr_crapcst2;

                 END IF; --cr_crapcdb%FOUND
                 --Fechar cursor
                 CLOSE cr_crapcdb;
               ELSE
                 IF rw_craplcm.nrdolote = 4500 THEN
                   vr_aux_cdpesqui:= vr_aux_cdpesqui ||' SOMA = '||LTrim(RTrim(gene0002.fn_mask(rw_craplot.vlcompcc,'zzz.zzz.zz9,99')));
                 ELSE
                   vr_aux_cdpesqui:= vr_aux_cdpesqui ||' SOMA = '||LTrim(RTrim(gene0002.fn_mask(rw_craplot.vlcompdb,'zzz.zzz.zz9,99')));
                 END IF;
               END IF; --rw_craplcm.nrdolote = 4500
             ELSE
               vr_aux_cdpesqui:= vr_aux_cdpesqui || ' LOTE JA BAIXADO';
             END IF;  --cr_craplot%FOUND
             --Fechar cursor
             CLOSE cr_craplot;

           END IF; --rw_craplcm.cdagenci = 1
         END IF; --cr_craplcm%FOUND
         --Fechar Cursor
         CLOSE cr_craplcm;
       END IF; --pr_nrdrecid > 0

       /*  Tratamento para a TCO - Contas Migradas  */
       IF  pr_cdcooper = 1  OR
           pr_cdcooper = 2  THEN
         --Selecionar transferencias de conta
         OPEN cr_craptco (pr_cdcopant => pr_cdcooper
                         ,pr_nrctaant => pr_nrdconta
                         ,pr_tpctatrf => 1
                         ,pr_flgativo => 1);
         --Posicionar no proximo registro
         FETCH cr_craptco INTO rw_craptco;
         
         IF cr_craptco%FOUND THEN    
           vr_aux_cdpesqui:= 'TCO';  
           -- Se conta migrada
           IF  pr_cdcooper = 2  
           AND rw_craptco.cdageant IN (2,4,6,7,11)  THEN
             vr_nrdctabb := rw_craptco.nrdconta;
           ELSE
             vr_nrdctabb := pr_nrctachq;
           END IF;       
         ELSE     
           vr_nrdctabb := pr_nrctachq;  
         END IF;       
         --Fechar cursor
         CLOSE cr_craptco;   
       ELSE
         vr_nrdctabb := pr_nrctachq;
       END IF;
       
       --Se for cheque normal
       IF pr_inchqdev = 1   THEN  /* cheque normal */

         --Selecionar devolucoes de cheques
         OPEN cr_crapdev_union (pr_cdcooper => pr_cdcooper
                               ,pr_cdbanchq => vr_aux_cdbanchq
                               ,pr_cdagechq => pr_cdagechq
                               ,pr_nrctachq => pr_nrctachq
                               ,pr_nrcheque => pr_nrdocmto
                               ,pr_cdhistor => pr_cdhistor);
         --Posicionar no proximo registro
         FETCH cr_crapdev_union INTO rw_crapdev_union;
         --Se encontrou
         IF cr_crapdev_union%FOUND THEN
           pr_cdcritic:= 415;
           --sair da rotina
           RAISE vr_exc_sair;
         END IF;
         --Fechar cursor
         CLOSE cr_crapdev_union;
         
         --Verificar se � conta integra��o
         IF nvl(pr_nrdctitg, ' ') = ' ' THEN
           vr_indctitg:= 0;
         ELSE
           vr_indctitg:= 1;
         END IF;

         /* Se n�o for uma das alineas listadas insere devolu��o historico 46 */
         IF NOT fn_existe_alinea(pr_cdalinea) THEN
          
           /* Inserir devolu��o de cheque historico 46 */
           BEGIN
             INSERT INTO crapdev (cdcooper
                                 ,dtmvtolt
                                 ,cdbccxlt
                                 ,nrdconta
                                 ,nrdctabb
                                 ,nrdctitg
                                 ,nrcheque
                                 ,vllanmto
                                 ,cdalinea
                                 ,cdoperad
                                 ,cdhistor
                                 ,cdpesqui
                                 ,insitdev
                                 ,cdbanchq
                                 ,cdagechq
                                 ,nrctachq
                                 ,indctitg)
                         VALUES  (pr_cdcooper
                                 ,pr_dtmvtolt
                                 ,pr_cdbccxlt
                                 ,pr_nrdconta
                                 ,vr_nrdctabb
                                 ,pr_nrdctitg
                                 ,pr_nrdocmto
                                 ,pr_vllanmto
                                 ,pr_cdalinea
                                 ,pr_cdoperad
                                 ,46
                                 ,nvl(vr_aux_cdpesqui,' ') --,'TCO' (Edison - Amcom)
                                 ,0
                                 ,vr_aux_cdbanchq
                                 ,pr_cdagechq
                                 ,pr_nrctachq
                                 ,vr_indctitg);
           EXCEPTION
             WHEN OTHERS THEN
               vr_des_erro:= 'Erro ao inserir na tabela crapdev. Rotina CHEQ0001.pc_gera_devolucao_cheque: '||SQLERRM;
               RAISE vr_exc_erro;
           END;
         END IF; --IF NOT fn_existe_alinea(pr_cdalinea) THEN


         /* Inserir devolu��o de cheque hist�rico do par�metro */
         BEGIN
           INSERT INTO crapdev (cdcooper
                               ,dtmvtolt
                               ,cdbccxlt
                               ,nrdconta
                               ,nrdctabb
                               ,nrdctitg
                               ,nrcheque
                               ,vllanmto
                               ,cdalinea
                               ,cdoperad
                               ,cdhistor
                               ,cdpesqui
                               ,insitdev
                               ,cdbanchq
                               ,cdagechq
                               ,nrctachq
                               ,indctitg)
                       VALUES  (pr_cdcooper
                               ,pr_dtmvtolt
                               ,pr_cdbccxlt
                               ,pr_nrdconta
                               ,vr_nrdctabb
                               ,pr_nrdctitg
                               ,pr_nrdocmto
                               ,pr_vllanmto
                               ,pr_cdalinea
                               ,pr_cdoperad
                               ,pr_cdhistor
                               ,nvl(vr_aux_cdpesqui,' ')                               
                               ,pr_insitdev --> Respeita o que vir no parametro.
                               ,vr_aux_cdbanchq
                               ,pr_cdagechq
                               ,pr_nrctachq
                               ,vr_indctitg);
         EXCEPTION
           WHEN OTHERS THEN
             vr_des_erro:= 'Erro ao inserir na tabela crapdev. Rotina CHEQ0001.pc_pi_cria_dev: '||sqlerrm;
             RAISE vr_exc_erro;
         END;

       ELSIF pr_inchqdev = 2 OR  pr_inchqdev = 4  THEN

         --Selecionar devolucoes de cheques
         OPEN cr_crapdev (pr_cdcooper => pr_cdcooper
                         ,pr_cdbanchq => vr_aux_cdbanchq
                         ,pr_cdagechq => pr_cdagechq
                         ,pr_nrctachq => pr_nrctachq
                         ,pr_nrcheque => pr_nrdocmto
                         ,pr_cdhistor => 46);
         --Posicionar no proximo registro
         FETCH cr_crapdev INTO rw_crapdev;
         --Se encontrou
         IF cr_crapdev%FOUND THEN
           pr_cdcritic:= 415;
           --sair da rotina
           RAISE vr_exc_sair;
         END IF;

         /* Se n�o for uma das alineas listadas insere devolu��o historico 46 */
         IF NOT fn_existe_alinea(pr_cdalinea) THEN

           --Verificar se � conta integra��o
           IF nvl(pr_nrdctitg,' ') = ' ' THEN
             vr_indctitg:= 0;
           ELSE
             vr_indctitg:= 1;
           END IF;

           /* Inserir devolu��o de cheque historico 46 */
           BEGIN
             INSERT INTO crapdev (cdcooper
                                 ,dtmvtolt
                                 ,cdbccxlt
                                 ,nrdconta
                                 ,nrdctabb
                                 ,nrdctitg
                                 ,nrcheque
                                 ,vllanmto
                                 ,cdalinea
                                 ,cdoperad
                                 ,cdhistor
                                 ,cdpesqui
                                 ,insitdev
                                 ,cdbanchq
                                 ,cdagechq
                                 ,nrctachq
                                 ,indctitg)
                         VALUES  (pr_cdcooper
                                 ,pr_dtmvtolt
                                 ,pr_cdbccxlt
                                 ,pr_nrdconta
                                 ,vr_nrdctabb
                                 ,pr_nrdctitg
                                 ,pr_nrdocmto
                                 ,pr_vllanmto
                                 ,pr_cdalinea
                                 ,pr_cdoperad
                                 ,46
                                 ,nvl(vr_aux_cdpesqui,' ')
                                 ,0
                                 ,vr_aux_cdbanchq
                                 ,pr_cdagechq
                                 ,pr_nrctachq
                                 ,vr_indctitg);
           EXCEPTION
             WHEN OTHERS THEN
               vr_des_erro:= 'Erro ao inserir na tabela crapdev. Rotina CHEQ0001.pc_gera_devolucao_cheque: '||SQLERRM;
               RAISE vr_exc_erro;
           END;
         END IF; --IF NOT fn_existe_alinea(pr_cdalinea) THEN
         --Fechar Cursor
         CLOSE cr_crapdev;


       ELSIF pr_inchqdev = 3  THEN  /* Transferencia */

         --Selecionar devolucoes de cheques
         OPEN cr_crapdev_union (pr_cdcooper => pr_cdcooper
                               ,pr_cdbanchq => vr_aux_cdbanchq
                               ,pr_cdagechq => pr_cdagechq
                               ,pr_nrctachq => pr_nrctachq
                               ,pr_nrcheque => pr_nrdocmto
                               ,pr_cdhistor => pr_cdhistor);
         --Posicionar no proximo registro
         FETCH cr_crapdev_union INTO rw_crapdev_union;
         --Se encontrou
         IF cr_crapdev_union%FOUND THEN
           pr_cdcritic:= 415;
           --sair da rotina
           RAISE vr_exc_sair;
         END IF;
         --Fechar Cursor
         CLOSE cr_crapdev_union;

         --Verificar se � conta integra��o
         IF nvl(pr_nrdctitg, ' ') =  ' ' THEN
           vr_indctitg:= 0;
         ELSE
           vr_indctitg:= 1;
         END IF;
         
         /* Se n�o for uma das alineas listadas insere devolu��o historico 46 */
         IF NOT fn_existe_alinea(pr_cdalinea) THEN 

           /* Inserir devolu��o de cheque historico 46 */
           BEGIN
             INSERT INTO crapdev (cdcooper
                                 ,dtmvtolt
                                 ,cdbccxlt
                                 ,nrdconta
                                 ,nrdctabb
                                 ,nrdctitg
                                 ,nrcheque
                                 ,vllanmto
                                 ,cdalinea
                                 ,cdoperad
                                 ,cdhistor
                                 ,cdpesqui
                                 ,insitdev
                                 ,cdbanchq
                                 ,cdagechq
                                 ,nrctachq
                                 ,indctitg)
                         VALUES  (pr_cdcooper
                                 ,pr_dtmvtolt
                                 ,pr_cdbccxlt
                                 ,pr_nrdconta
                                 ,vr_nrdctabb
                                 ,pr_nrdctitg
                                 ,pr_nrdocmto
                                 ,pr_vllanmto
                                 ,pr_cdalinea
                                 ,pr_cdoperad
                                 ,46
                                 ,nvl(vr_aux_cdpesqui,' ')
                                 ,0
                                 ,vr_aux_cdbanchq
                                 ,pr_cdagechq
                                 ,pr_nrctachq
                                 ,vr_indctitg);
           EXCEPTION
             WHEN OTHERS THEN
               vr_des_erro:= 'Erro ao inserir na tabela crapdev. Rotina CHEQ0001.pc_gera_devolucao_cheque: '||SQLERRM;
               RAISE vr_exc_erro;
           END;
         END IF; --IF NOT fn_existe_alinea(pr_cdalinea) THEN

         /* Inserir devolu��o de cheque hist�rico do par�metro */
         BEGIN
           INSERT INTO crapdev (cdcooper
                               ,dtmvtolt
                               ,cdbccxlt
                               ,nrdconta
                               ,nrdctabb
                               ,nrdctitg
                               ,nrcheque
                               ,vllanmto
                               ,cdalinea
                               ,cdoperad
                               ,cdhistor
                               ,cdpesqui
                               ,insitdev
                               ,cdbanchq
                               ,cdagechq
                               ,nrctachq
                               ,indctitg)
                       VALUES  (pr_cdcooper
                               ,pr_dtmvtolt
                               ,pr_cdbccxlt
                               ,pr_nrdconta
                               ,vr_nrdctabb
                               ,pr_nrdctitg
                               ,pr_nrdocmto
                               ,pr_vllanmto
                               ,pr_cdalinea
                               ,pr_cdoperad
                               ,pr_cdhistor
                               ,nvl(vr_aux_cdpesqui,' ')
                               ,pr_insitdev --> Respeita o que vir no parametro.
                               ,vr_aux_cdbanchq
                               ,pr_cdagechq
                               ,pr_nrctachq
                               ,vr_indctitg);
         EXCEPTION
           WHEN OTHERS THEN
             vr_des_erro:= 'Erro ao inserir na tabela crapdev. Rotina CHEQ0001.pc_gera_devolucao_cheque: '||sqlerrm;
             RAISE vr_exc_erro;
         END;

       ELSIF pr_inchqdev = 5  THEN

         BEGIN
           --Excluir registros de devolucao
           DELETE FROM crapdev
           WHERE crapdev.cdcooper = pr_cdcooper
           AND   crapdev.cdbanchq = vr_aux_cdbanchq
           AND   crapdev.cdagechq = pr_cdagechq
           AND   crapdev.nrctachq = pr_nrctachq
           AND   crapdev.nrcheque = pr_nrdocmto
           AND   crapdev.cdhistor = pr_cdhistor;

           --Se nao conseguiu deletar
           IF SQL%ROWCOUNT = 0 THEN
             pr_cdcritic:= 416;
             --sair da rotina
             RAISE vr_exc_sair;
           END IF;

         EXCEPTION
           WHEN OTHERS THEN
             --Montar mensagem de erro
             vr_des_erro:= 'Erro ao deletar tabela crapdev. '||SQLERRM;
             --sair da rotina
             RAISE vr_exc_sair;
         END;

         /* Se n�o for uma das alineas listadas insere devolu��o historico 46 */
         IF NOT fn_existe_alinea(pr_cdalinea) THEN
           BEGIN
             --Excluir registros selecionados
             DELETE FROM crapdev
             WHERE crapdev.cdcooper = pr_cdcooper
             AND   crapdev.cdbanchq = vr_aux_cdbanchq
             AND   crapdev.cdagechq = pr_cdagechq
             AND   crapdev.nrctachq = pr_nrctachq
             AND   crapdev.nrcheque = pr_nrdocmto
             AND   crapdev.cdhistor = 46;
           EXCEPTION
           WHEN OTHERS THEN
             --Montar mensagem de erro
             vr_des_erro:= 'Erro ao deletar tabela crapdev. '||SQLERRM;
             --sair da rotina
             RAISE vr_exc_sair;
           END;
         END IF;

       ELSIF pr_inchqdev = 6 OR pr_inchqdev = 8 THEN

         BEGIN
           --Excluir registros de devolucao
           DELETE FROM crapdev
           WHERE crapdev.cdcooper = pr_cdcooper
           AND   crapdev.cdbanchq = vr_aux_cdbanchq
           AND   crapdev.cdagechq = pr_cdagechq
           AND   crapdev.nrctachq = pr_nrctachq
           AND   crapdev.nrcheque = pr_nrdocmto
           AND   crapdev.cdhistor = pr_cdhistor;

           --Se nao conseguiu deletar
           IF SQL%ROWCOUNT = 0 THEN
             pr_cdcritic:= 416;
             --sair da rotina
             RAISE vr_exc_sair;
           END IF;
         EXCEPTION
           WHEN OTHERS THEN
             --Montar mensagem de erro
             vr_des_erro:= 'Erro ao deletar tabela crapdev. '||SQLERRM;
             --sair da rotina
             RAISE vr_exc_sair;
         END;

         /* Se n�o for uma das alineas listadas insere devolu��o historico 46 */
         IF NOT fn_existe_alinea(pr_cdalinea) THEN
           BEGIN
             --Excluir registros selecionados
             DELETE FROM crapdev
             WHERE crapdev.cdcooper = pr_cdcooper
             AND   crapdev.cdbanchq = vr_aux_cdbanchq
             AND   crapdev.cdagechq = pr_cdagechq
             AND   crapdev.nrctachq = pr_nrctachq
             AND   crapdev.nrcheque = pr_nrdocmto
             AND   crapdev.cdhistor = 46;
           EXCEPTION
             WHEN OTHERS THEN
               --Montar mensagem de erro
               vr_des_erro:= 'Erro ao deletar tabela crapdev. '||SQLERRM;
               --sair da rotina
               RAISE vr_exc_sair;
           END;
         END IF;

       ELSIF pr_inchqdev = 7 THEN

         BEGIN
           --Excluir registros de devolucao
           DELETE FROM crapdev
           WHERE crapdev.cdcooper = pr_cdcooper
           AND   crapdev.cdbanchq = vr_aux_cdbanchq
           AND   crapdev.cdagechq = pr_cdagechq
           AND   crapdev.nrctachq = pr_nrctachq
           AND   crapdev.nrcheque = pr_nrdocmto
           AND   crapdev.cdhistor = pr_cdhistor;

           --Se nao conseguiu deletar
           IF SQL%ROWCOUNT = 0 THEN
             pr_cdcritic:= 416;
             --sair da rotina
             RAISE vr_exc_sair;
           END IF;
         EXCEPTION
           WHEN OTHERS THEN
             --Montar mensagem de erro
             vr_des_erro:= 'Erro ao deletar tabela crapdev. '||SQLERRM;
             --sair da rotina
             RAISE vr_exc_sair;
         END;

         /* Se n�o for uma das alineas listadas insere devolu��o historico 46 */
         IF NOT fn_existe_alinea(pr_cdalinea) THEN
           BEGIN
             --Excluir registros selecionados
             DELETE FROM crapdev
             WHERE crapdev.cdcooper = pr_cdcooper
             AND   crapdev.cdbanchq = vr_aux_cdbanchq
             AND   crapdev.cdagechq = pr_cdagechq
             AND   crapdev.nrctachq = pr_nrctachq
             AND   crapdev.nrcheque = pr_nrdocmto
             AND   crapdev.cdhistor = 46;
           EXCEPTION
           WHEN OTHERS THEN
             --Montar mensagem de erro
             vr_des_erro:= 'Erro ao deletar tabela crapdev. '||SQLERRM;
             --sair da rotina
             RAISE vr_exc_sair;
           END;
         END IF;

       END IF; --pr_inchqdev

    EXCEPTION
      WHEN vr_exc_sair THEN
        pr_cdcritic := NVL(pr_cdcritic,0);
        pr_des_erro := vr_des_erro;
      WHEN vr_exc_erro THEN
        pr_cdcritic := NVL(pr_cdcritic,0);
        pr_des_erro := vr_des_erro;
      WHEN OTHERS THEN
        pr_cdcritic := NVL(pr_cdcritic,0);
        pr_des_erro := 'Erro na rotina CHEQ0001.pc_gera_devolucao_cheque. '||sqlerrm;
    END;
  END pc_gera_devolucao_cheque;

    /* Rotina para verificar possiveis fraudes em cheque */
  PROCEDURE pc_verifica_fraude_cheque (pr_cdcooper IN crapdev.cdcooper%TYPE      --> Cooperativa
                                      ,pr_cdagectl IN crapfdc.cdagechq%TYPE      --> C�digo da Agencia do Cheque
                                      ,pr_nrctachq IN craprej.nrdconta%TYPE      --> Numero da Conta do Cheque
                                      ,pr_dtrefere IN craprej.dtrefere%TYPE      --> Data de Referencia
                                      ,pr_nrdconta IN craprej.nrdconta%TYPE      --> Numero da Conta
                                      ,pr_nrdocmto IN craprej.nrdocmto%TYPE      --> Numero do Documento
                                      ,pr_vllanmto IN craprej.vllanmto%TYPE      --> Valor do Lan�amento
                                      ,pr_nrseqdig IN craprej.nrseqdig%TYPE      --> Numero sequencial
                                      ,pr_cdpesqbb IN craprej.cdpesqbb%TYPE      --> C�digo Pesquisa
                                      ,pr_des_erro OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................

    Programa: pc_verifica_fraude_cheque - Antiga Includes/verifica_fraude_cheque.i
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Fabricio
    Data    : Agosto/2012                          Ultima alteracao: 29/04/2014

    Dados referentes ao programa:

    Frequencia: Diario (Batch)
    Objetivo  : Verificar possivel fraude dos cheques listados abaixo (SAFRA).

    Alteracoes:  22/08/2012 - Ajustado para zerar o glb_cdcritic apos a criacao
                             do craprej (Ze).
                 19/12/2012 - Convers�o Progress -> Oracle  (Alisson - AMcom)
                 
                 09/01/2014 - Removido verificacao de contas dos cheques
                              roubados do Safra e adicionado verificao de contas
                              dos cheques roubados do Itau de Balneario
                              Camboriu e do Bradesco. (Fabricio)  
                              
                 10/03/2014 - Adicionado contas relacionados ao roubo de cheques do
                              Bradesco e Itau em Joinville 21/02/2014. (Gabriel)
                              
                 29/04/2014 - Adicionado contas de cheques roubados do Bradesco e
                              Itau em Balneario Camboriu em 22/04/2014.
                              (Jorge/Rosangela) SD 151736 - Roubo malote             
                              
                 13/06/2014 - Incluido tabela crapsch com as contas em que ocorreram
                              sinistros (Andrino-RKAM)
                             
    ............................................................................. */
     DECLARE
       
       -- Busca sobre a tabela de sinistros de cheques
       CURSOR cr_crapsch IS
         SELECT dsmotivo
           FROM crapsch
          WHERE cdagectl = pr_cdagectl
            AND nrctachq = pr_nrctachq
          ORDER BY dtmvtolt DESC;
       
       vr_cdcritic  NUMBER:= 0;
       vr_dsmotivo  crapsch.dsmotivo%TYPE;
       
     BEGIN

       --Inicializa variavel de erro
       pr_des_erro:= NULL;
       
       -- Verifica se a conta possui historico de sinistro
       OPEN cr_crapsch;
       FETCH cr_crapsch INTO vr_dsmotivo;
       
       IF cr_crapsch%FOUND THEN
         vr_cdcritic:= 948; -- Sinistro de cheque
       END IF;
       CLOSE cr_crapsch;


      IF vr_cdcritic IN (948,963) THEN
        --Inserir na tabela de rejeitados na integra��o (CRAPREJ)

        BEGIN
          INSERT INTO craprej (cdcooper
                              ,dtrefere
                              ,nrdconta
                              ,nrdocmto
                              ,vllanmto
                              ,nrseqdig
                              ,cdcritic
                              ,cdpesqbb
                              ,dshistor)
                      VALUES  (pr_cdcooper
                              ,pr_dtrefere
                              ,pr_nrdconta
                              ,pr_nrdocmto
                              ,pr_vllanmto
                              ,pr_nrseqdig
                              ,vr_cdcritic
                              ,pr_cdpesqbb
                              ,vr_dsmotivo);
        EXCEPTION
          WHEN OTHERS THEN
            pr_des_erro:= 'Erro na rotina CHEQ0001.pc_verifica_fraude_cheque ao inserir na tabela craprej. '||sqlerrm;
        END;
      END IF;
    END;
  END pc_verifica_fraude_cheque;

  /* Procedure para gerar tabela de busca de cheques BBrasil*/
  PROCEDURE pc_gera_cheques(pr_nrtipoop    IN NUMBER                                --> Tipo de opera��o
                           ,pr_cdcooper    IN NUMBER                                --> C�digo cooperativa
                           ,pr_lscontas    IN VARCHAR2                              --> Lista de contas
                           ,pr_nriniseq    IN NUMBER                                --> Inicial da sequencia
                           ,pr_nrregist    IN NUMBER                                --> Numero registro
                           ,pr_auxnrregist IN OUT NUMBER                            --> Auxiliar do n�mero do registro
                           ,pr_qtregist    IN OUT NUMBER                            --> Quantidade registros
                           ,pr_tab_cheques IN OUT NOCOPY gene0007.typ_mult_array    --> Pl table de cheques
                           ,pr_nrcheque    IN crapfdc.nrcheque%TYPE                 --> N�mero cheque
                           ,pr_nrdigchq    IN crapfdc.nrdigchq%TYPE                 --> D�gito cheque
                           ,pr_cdbanchq    IN crapfdc.cdbanchq%TYPE                 --> C�digo banco cheque
                           ,pr_nrseqems    IN crapfdc.nrseqems%TYPE                 --> N�mero da sequencia
                           ,pr_tpforchq    IN crapfdc.tpforchq%TYPE                 --> Tipo cheque
                           ,pr_nrdctitg    IN crapfdc.nrdctitg%TYPE                 --> N�mero tag
                           ,pr_nrpedido    IN crapfdc.nrpedido%TYPE                 --> N�mero pedido
                           ,pr_vlcheque    IN crapfdc.vlcheque%TYPE                 --> Valor do cheque
                           ,pr_cdtpdchq    IN crapfdc.cdtpdchq%TYPE                 --> Tipo do cheque
                           ,pr_cdbandep    IN crapfdc.cdbandep%TYPE                 --> C�digo bandeira
                           ,pr_cdagedep    IN crapfdc.cdagedep%TYPE                 --> C�digo agencia
                           ,pr_nrctadep    IN crapfdc.nrctadep%TYPE                 --> N�mero conta
                           ,pr_cdbantic    IN crapfdc.cdbantic%TYPE                 --> Declara��o tipo do banco
                           ,pr_cdagetic    IN crapfdc.cdagetic%TYPE                 --> Declara��o tipo da agencia
                           ,pr_nrctatic    IN crapfdc.nrctatic%TYPE                 --> c�digo tipo da conta
                           ,pr_dtlibtic    IN crapfdc.dtlibtic%TYPE                 --> Data libera��o
                           ,pr_tpcheque    IN crapfdc.tpcheque%TYPE                 --> Tipo do cheque
                           ,pr_incheque    IN crapfdc.incheque%TYPE                 --> Entrada cheque
                           ,pr_dtemschq    IN crapfdc.dtemschq%TYPE                 --> Data limite
                           ,pr_dtretchq    IN crapfdc.dtretchq%TYPE                 --> Data retirada
                           ,pr_dtliqchq    IN crapfdc.dtliqchq%TYPE                 --> Data liquida��o
                           ,pr_nrdctabb    IN crapfdc.nrdctabb%TYPE                 --> N�mero da conta BB
                           ,pr_cdagechq    IN crapfdc.cdagechq%TYPE                 --> Declara��o agencia cheque
                           ,pr_nrctachq    IN crapfdc.nrctachq%TYPE                 --> N�mero conta cheque
                           ,pr_dsdocmc7    IN crapfdc.dsdocmc7%TYPE                 --> Descri��o documento CMC - 7
                           ,pr_cdcmpchq    IN crapfdc.cdcmpchq%TYPE                 --> Campo cheque
                           ,pr_cdageaco    IN crapfdc.cdageaco%TYPE                 --> Agencia Acolhedora
                           ,pr_fim         OUT BOOLEAN                              --> Controle de sa�da da execu��o externa
                           ,pr_des_erro    OUT VARCHAR2) IS                         --> Retorno de erro
  /* .............................................................................

   Programa: pc_gera_cheques            Antigo: b1wgen0040.p --> gera-tt-cheque
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : WEB
   Autor   : David
   Data    : Maio/2013.                        Ultima atualizacao: 20/10/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Popula PL Table com informa��es acerca dos cheques (Web).

   Alteracoes: 20/05/2013 - Convers�o Progress >> Oracle (PLSQL) (Petter-Supero)
               
               27/10/2014 - Inclus�o do campo cdagechq e cdageaco na PL table 
                            pr_tab_cheques (Lucas R. e Vanessa) 

               10/06/2016 - Ajustado para gerar os registros conforme era gerado no 
                            fonte progress (Lucas Ranghetti #422753)

               19/10/2017 - Ajsute para pegar corretamente a observa��o do cheque
			               (Adriano - SD 774552)
  ............................................................................. */
  BEGIN
    DECLARE
      vr_nrchqcdv     NUMBER;                --> N�mero cheque
      vr_dsdocmc7     VARCHAR2(4000);        --> Documentos
      vr_fim          EXCEPTION;             --> Finaliza execu��o e retorna finaliza��o para externo
      vr_index        PLS_INTEGER;           --> Indice para PL Table
      vr_sql          VARCHAR2(4000);        --> Vari�vel para SQL din�mico
      vr_cursor       NUMBER;                --> ID do cursor din�mico
      vr_nrseqems     crapfdc.nrseqems%TYPE; --> Campo de retorno do cursor din�mico
      vr_exec         NUMBER;                --> ID da execu��o din�mico
      vr_exc_erro     EXCEPTION;             --> Controle de exce��o

      /* Busca informa��es sobre o pedido */
      CURSOR cr_crapped(pr_cdcooper  IN NUMBER                      --> Declara��o cooperativa
                       ,pr_nrpedido  IN crapped.nrpedido%TYPE) IS   --> N�mero do pedido
        SELECT to_char(cd.dtsolped, 'DD/MM/RRRR') dtsolped
              ,to_char(cd.dtrecped, 'DD/MM/RRRR') dtrecped
        FROM crapped cd
        WHERE cd.cdcooper = pr_cdcooper
          AND cd.nrpedido = pr_nrpedido
          AND rownum = 1
        ORDER BY cd.progress_recid;
      rw_crapped cr_crapped%ROWTYPE;

      /* Busca informa��es sobre cheques */
      CURSOR cr_crapcor(pr_cdcooper  IN NUMBER                     --> Declara��o cooperativa
                       ,pr_cdbanchq  IN crapcor.cdbanchq%TYPE      --> Declara��o banco do cheque
                       ,pr_cdagechq  IN crapcor.cdagechq%TYPE      --> Declara��o ag�ncia do cheque
                       ,pr_nrctachq  IN crapcor.nrctachq%TYPE      --> N�mero conta do cheque
                       ,pr_nrchqcdv  IN crapcor.nrcheque%TYPE) IS  --> N�mero do cheque
        SELECT co.cdhistor
              ,to_char(co.dtmvtolt, 'DD/MM/RRRR') dtmvtolt
              ,co.cdoperad
              ,to_char(co.dtemscor, 'DD/MM/RRRR') dtemscor
              ,to_char(co.dtvalcor, 'DD/MM/RRRR') dtvalcor
              ,COUNT(1) over() contador
        FROM crapcor co
        WHERE co.cdcooper = pr_cdcooper
          AND co.cdbanchq = pr_cdbanchq
          AND co.cdagechq = pr_cdagechq
          AND co.nrctachq = pr_nrctachq
          AND co.nrcheque = pr_nrchqcdv
          AND co.flgativo = 1;
      rw_crapcor cr_crapcor%ROWTYPE;

      /* Busca informa��es de hist�rico */
      CURSOR cr_craphis(pr_cdcooper  IN NUMBER                     --> Declara��o cooperativa
                       ,pr_cdhistor  IN craphis.cdhistor%TYPE) IS  --> Hist�rico
        SELECT ci.dshistor
        FROM craphis ci
        WHERE ci.cdcooper = pr_cdcooper
          AND ci.cdhistor = pr_cdhistor;
      rw_craphis cr_craphis%ROWTYPE;

    BEGIN
      -- Controle de finaliza��o
      pr_fim := FALSE;

      -- Incrementa valor da quantidade de registros
      pr_qtregist := nvl(pr_qtregist, 0) + 1;

      -- controles da pagina��o
      IF (pr_qtregist < pr_nriniseq) OR (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
        pr_fim := TRUE;
        RAISE vr_fim;
      END IF;

      -- In�cio da grava��o da PL Table
      IF pr_auxnrregist > 0 THEN
        vr_index := nvl(pr_tab_cheques.count, 0) + 1;

        -- Criar registro na PL Table
        pr_tab_cheques(vr_index)('cdbanchq') := pr_cdbanchq;
        pr_tab_cheques(vr_index)('nrcheque') := to_char(pr_nrcheque) || to_char(pr_nrdigchq);
        pr_tab_cheques(vr_index)('nrseqems') := pr_nrseqems;
        pr_tab_cheques(vr_index)('tpforchq') := pr_tpforchq;
        pr_tab_cheques(vr_index)('nrdctitg') := pr_nrdctitg;
        pr_tab_cheques(vr_index)('nrpedido') := pr_nrpedido;
        pr_tab_cheques(vr_index)('vlcheque') := pr_vlcheque;
        pr_tab_cheques(vr_index)('cdtpdchq') := pr_cdtpdchq;
        pr_tab_cheques(vr_index)('cdbandep') := pr_cdbandep;
        pr_tab_cheques(vr_index)('cdagedep') := pr_cdagedep;
        pr_tab_cheques(vr_index)('nrctadep') := pr_nrctadep;
        pr_tab_cheques(vr_index)('nrdigchq') := pr_nrdigchq;
        pr_tab_cheques(vr_index)('cdbantic') := pr_cdbantic;
        pr_tab_cheques(vr_index)('cdagetic') := pr_cdagetic;
        pr_tab_cheques(vr_index)('nrctatic') := pr_nrctatic;
        pr_tab_cheques(vr_index)('dtlibtic') := to_char(pr_dtlibtic, 'DD/MM/RRRR');
        pr_tab_cheques(vr_index)('cdagechq') := pr_cdagechq;
        pr_tab_cheques(vr_index)('cdageaco') := pr_cdageaco;
        

        -- Validar o tipo do cheque
        IF pr_tpcheque = 1 THEN
          pr_tab_cheques(vr_index)('tpcheque') := '  ';
        ELSIF pr_tpcheque = 2 THEN
          pr_tab_cheques(vr_index)('tpcheque') := 'TB';
        ELSIF pr_tpcheque = 3 THEN
          pr_tab_cheques(vr_index)('tpcheque') := 'CS';
        ELSE
          pr_tab_cheques(vr_index)('tpcheque') := '  ';
        END IF;

        -- Validar indicador do cheque
        IF pr_incheque = 1 OR pr_incheque = 2 THEN
          pr_tab_cheques(vr_index)('dsobserv') := 'Contra-Ordem';
        ELSIF pr_incheque = 8 THEN
          pr_tab_cheques(vr_index)('dsobserv') := 'Cancelado';
        ELSE
          pr_tab_cheques(vr_index)('dsobserv') := ' ';
        END IF;

        -- Validar data do cheque
        IF pr_dtemschq IS NULL THEN

          -- Buscar informa��es do pedido
          OPEN cr_crapped(pr_cdcooper, pr_nrpedido);
          FETCH cr_crapped INTO rw_crapped;

          -- Verifica se forma encontrados registros
          IF cr_crapped%FOUND THEN
            pr_tab_cheques(vr_index)('dsobserv') := nvl(trim(pr_tab_cheques(vr_index)('dsobserv')),'Ped. ' || trim(to_char(pr_nrpedido, '99999999')));
            pr_tab_cheques(vr_index)('dtemschq') := rw_crapped.dtsolped;
          END IF;
        ELSE
          pr_tab_cheques(vr_index)('dtemschq') := to_char(pr_dtemschq, 'DD/MM/RRRR');
        END IF;

        -- Valida data de retorno
        IF NOT pr_dtretchq = to_date('01/01/0001', 'DD/MM/RRRR') THEN
          pr_tab_cheques(vr_index)('dtretchq') := to_char(pr_dtretchq, 'DD/MM/RRRR');
        END IF;

        -- Valida data de liquida��o do cheque
        IF NOT pr_dtliqchq = to_date('01/01/0001', 'DD/MM/RRRR') THEN
          pr_tab_cheques(vr_index)('dtliqchq') := to_char(pr_dtliqchq, 'DD/MM/RRRR');
        END IF;

        -- Valida para observa��o de recolhimento
        IF (gene0002.fn_existe_valor(pr_base     => pr_lscontas
                                    ,pr_busca    => pr_nrdctabb
                                    ,pr_delimite => ',')='S')
           AND pr_dtliqchq IS NULL AND pr_incheque = 0 THEN
          pr_tab_cheques(vr_index)('dsobserv') := 'Recolher';
        END IF;

        -- Inicializa a montagem de SQL dinamico
        vr_sql := 'select * from ( ' ||
                  'select nrseqems ' ||
                  'from crapfdc ' ||
                  'where cdcooper = ' || pr_cdcooper || ' ' ||
                  'and cdbanchq = ' || pr_cdbanchq || ' ' ||
                  'and cdagechq = ' || pr_cdagechq || ' ' ||
                  'and nrctachq = ' || pr_nrctachq || ' ' ||
                  'and nrcheque < ' || pr_nrcheque || ' ' ;

        -- Validar tipo de opera��o
        CASE pr_nrtipoop
          WHEN 1 THEN /*  Em uso  */
            vr_sql := vr_sql || 'and dtemschq is not null ' ||
                                'and dtretchq is not null ' ||
                                'and dtliqchq is null';
          WHEN 2 THEN /*  Arquivo  */
            vr_sql := vr_sql || 'and dtemschq is not null ' ||
                                'and dtretchq is null';
          WHEN 3 THEN /*  Solicitados  */
            vr_sql := vr_sql || 'and dtemschq is null ' ||
                                'and dtretchq is null';
          WHEN 4 THEN /*  Compensados  */
            vr_sql := vr_sql || 'and dtemschq is not null ' ||
                                'and dtretchq is not null ' ||
                                'and dtliqchq is not null';
          ELSE
            NULL; /*  TODOS */
        END CASE;

        vr_sql := vr_sql || ' order by progress_recid desc) where rownum = 1';

        -- Assinatura da execu��o do cursor
        vr_cursor := dbms_sql.open_cursor;
        -- Parser do SQL din�mico
        dbms_sql.parse(vr_cursor,  vr_sql, 1);
        -- Define o retorno da coluna
        dbms_sql.define_column(vr_cursor, 1, vr_nrseqems);
        -- Executa o cursor din�mico
        vr_exec := dbms_sql.execute(vr_cursor);

        -- Verifica se o cursor obteve retorno
        IF dbms_sql.fetch_rows(vr_cursor) > 0 THEN
          -- Obtem o valor do retorno do campo
          dbms_sql.column_value(vr_cursor, 1, vr_nrseqems);

          -- Verifica sequencia
          IF vr_nrseqems <> pr_nrseqems THEN
            pr_tab_cheques(vr_index)('flgsubtd') := 'yes';
          ELSE
            pr_tab_cheques(vr_index)('flgsubtd') := 'no';
          END IF;
        ELSE
          pr_tab_cheques(vr_index)('flgsubtd') := 'no';
        END IF;

        -- Atribuir valores para as vari�veis
        pr_tab_cheques(vr_index)('dscordem') := 'SEM CONTRA-ORDEM';
        pr_tab_cheques(vr_index)('dtmvtolt') := NULL;
        vr_nrchqcdv := gene0002.fn_char_para_number(to_char(pr_nrcheque) || to_char(pr_nrdigchq));

        -- Validar indicador do cheque
        IF pr_incheque IN (1,2,6,7) THEN
          -- Busca informa��es de cheques
          OPEN cr_crapcor(pr_cdcooper, pr_cdbanchq, pr_cdagechq, pr_nrctachq, vr_nrchqcdv);
          FETCH cr_crapcor INTO rw_crapcor;

          -- Verifica se retornou apenas um registro
          IF cr_crapcor%FOUND THEN 
            IF rw_crapcor.contador = 1 THEN
            -- Busca informa��es de hist�rico
            OPEN cr_craphis(pr_cdcooper, rw_crapcor.cdhistor);
            FETCH cr_craphis INTO rw_craphis;

            -- Valida datas para incluir data de movimento na PL Table
            IF rw_crapcor.dtmvtolt IS NOT NULL THEN
              pr_tab_cheques(vr_index)('dtmvtolt') := 'Inclusao: ' || rw_crapcor.dtmvtolt || ' - Cod. Operador: ' || rw_crapcor.cdoperad;
            ELSE
              pr_tab_cheques(vr_index)('dtmvtolt') := '                     - Cod. Operador: ' || rw_crapcor.cdoperad;
              END IF;
               
              pr_tab_cheques(vr_index)('dscordem') := 'Emissao : ' || rw_crapcor.dtemscor || ' - ' || rw_crapcor.cdhistor || ' - ';

              -- Verifica se retornou registros
              IF cr_craphis%FOUND THEN
                pr_tab_cheques(vr_index)('dscordem') := pr_tab_cheques(vr_index)('dscordem') || SUBSTR(rw_craphis.dshistor, 0, 24);
              ELSE
                pr_tab_cheques(vr_index)('dscordem') := pr_tab_cheques(vr_index)('dscordem') || ' ';
              END IF;

              pr_tab_cheques(vr_index)('dscordem') := pr_tab_cheques(vr_index)('dscordem') || ' Validade: ';

              -- Valida data valor
              IF rw_crapcor.dtvalcor IS NULL THEN
                pr_tab_cheques(vr_index)('dscordem') := pr_tab_cheques(vr_index)('dscordem') || ' Indeterminado';
              ELSE
                pr_tab_cheques(vr_index)('dscordem') := pr_tab_cheques(vr_index)('dscordem') || rw_crapcor.dtvalcor;
              END IF; 

            CLOSE cr_craphis;
          END IF;
          ELSE
            IF pr_incheque IN(1,2) THEN            
              pr_tab_cheques(vr_index)('dsobserv') := ' ';
            END IF;
          END IF;
          CLOSE cr_crapcor;
        END IF;

        -- Calcula valor da CPMF
        pr_tab_cheques(vr_index)('vldacpmf') := trunc(pr_vlcheque * 0.0038, 2);

        -- Verifica se localizou registro
        -- Verifica se o cursor j� est� aberto
        IF NOT cr_crapped%ISOPEN THEN
          -- Buscar informa��es do pedido
          OPEN cr_crapped(pr_cdcooper, pr_nrpedido);
          FETCH cr_crapped INTO rw_crapped;
        END IF;

        IF cr_crapped%FOUND THEN
          pr_tab_cheques(vr_index)('dtsolped') := rw_crapped.dtsolped;
          pr_tab_cheques(vr_index)('dtrecped') := rw_crapped.dtrecped;
        END IF;

        -- Valida documento
        IF nvl(pr_dsdocmc7, ' ') = ' ' THEN
          IF pr_dtemschq > to_date('01/01/2005', 'DD/MM/RRRR') THEN
            -- Calcula o cmc-7 do cheque
            pc_calc_cmc7_difcompe(pr_cdbanchq => pr_cdbanchq
                                 ,pr_cdcmpchq => pr_cdcmpchq
                                 ,pr_cdagechq => pr_cdagechq
                                 ,pr_nrctachq => pr_nrdctabb
                                 ,pr_nrcheque => pr_nrcheque
                                 ,pr_tpcheque => pr_tpcheque
                                 ,pr_dsdocmc7 => vr_dsdocmc7
                                 ,pr_des_erro => pr_des_erro);

            -- Verifica se retorno erro
            IF pr_des_erro IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;

            -- Atribui valor de retorno
            pr_tab_cheques(vr_index)('dsdocmc7') := vr_dsdocmc7;
          ELSE
            pr_tab_cheques(vr_index)('dsdocmc7') := 'NAO DISPONIVEL';
          END IF;
        ELSE
          pr_tab_cheques(vr_index)('dsdocmc7') := pr_dsdocmc7;
        END IF;

        -- verifica tamanho da descri��o
        IF length(pr_tab_cheques(vr_index)('dscordem')) > 53 THEN
          pr_tab_cheques(vr_index)('dscorde1') := substr(pr_tab_cheques(vr_index)('dscordem'), 55, 50);
        END IF;
      END IF;

      -- Decremento do par�metro de controle
      pr_auxnrregist := pr_auxnrregist - 1;
    EXCEPTION
      WHEN vr_fim THEN
        pr_fim := TRUE;
      WHEN vr_exc_erro THEN
        pr_des_erro := 'Erro em CHEQ0001.pc_gera_cheques: ' || pr_des_erro;
      WHEN OTHERS THEN
        pr_des_erro := 'Erro em CHEQ0001.pc_gera_cheques: ' || SQLERRM;
    END;
  END pc_gera_cheques;

  /* Calcular o CMC-7 do cheque */
  PROCEDURE pc_calc_cmc7_difcompe(pr_cdbanchq IN NUMBER         --> Declara��o do banco
                                 ,pr_cdcmpchq IN NUMBER         --> Declara��o compensa��o
                                 ,pr_cdagechq IN NUMBER         --> Declara��o agencia
                                 ,pr_nrctachq IN NUMBER         --> N�mero conta cheque
                                 ,pr_nrcheque IN NUMBER         --> N�mero cheque
                                 ,pr_tpcheque IN NUMBER         --> tipo de cheque
                                 ,pr_dsdocmc7 OUT VARCHAR2      --> Descri��o CMC-7
                                 ,pr_des_erro OUT VARCHAR2) IS  --> Erros no processo
  /* .............................................................................

   Programa: pc_calc_cmc7_difcompe            Antigo: b1wgen0040.p --> calc_cmc7_difcompe
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : WEB
   Autor   : David
   Data    : Maio/2013.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Calcular o CMC-7 do cheque.

   Alteracoes: 22/05/2013 - Convers�o Progress >> Oracle (PLSQL) (Petter-Supero)

  ............................................................................. */
  BEGIN
    DECLARE
      vr_nrcampo1      NUMBER(20,2);             --> Valor do c�lculo do campo1
      vr_nrcampo2      NUMBER(20,2);             --> Valor do c�lculo do campo2
      vr_nrcampo3      NUMBER(20,2);             --> Valor do c�lculo do campo3
      vr_dsdocmc7      VARCHAR2(4000);           --> Auxiliar para CMC-7
      vr_nrcalcul      NUMBER(20,2);             --> Valor do c�lculo
      vr_nrdigito      NUMBER;                   --> D�gito
      vr_digtpchq      VARCHAR2(50);             --> D�gito do cheque
      vr_stsnrcal      BOOLEAN;                  --> Flag de controle
      vr_grpsetec      NUMBER;                   --> Grupo
      vr_dscmpchq      VARCHAR2(4);              --> Compensa��o cheque
      vr_exc_erro      EXCEPTION;                --> Controle de erros personalizado

    BEGIN
      -- Cheque TB
      IF pr_tpcheque = 2 THEN
        vr_digtpchq := '9';
      ELSE
        vr_digtpchq := '5';
      END IF;

      -- Banco do Brasil
      IF pr_cdbanchq = 1 THEN
        vr_grpsetec := 7;
      ELSE
        vr_grpsetec := 0;
      END IF;

      -- Inicializar vari�vel
      vr_dscmpchq := '<' || to_char(pr_cdcmpchq, 'fm000');
      vr_dsdocmc7 := '<' || to_char(pr_cdbanchq,'fm000') || to_char(pr_cdagechq, 'fm0000') ||
                     '0' || vr_dscmpchq || to_char(pr_nrcheque, 'fm000000') || vr_digtpchq || '>0' ||
                     to_char(vr_grpsetec, 'fm0') || '0' || to_char(pr_nrctachq, 'fm00000000') || '0:';
      vr_nrcampo1 := gene0002.fn_char_para_number(substr(vr_dsdocmc7, 2, 8));
      vr_nrcampo2 := gene0002.fn_char_para_number(substr(vr_dsdocmc7, 11, 10));
      vr_nrcampo3 := gene0002.fn_char_para_number(substr(vr_dsdocmc7, 22, 12));

      -- Calcula o digito do terceiro campo - DV 1
      vr_nrcalcul := vr_nrcampo1;
      cada0001.pc_digm10(pr_nrcalcul => vr_nrcalcul
                        ,pr_nrdigito => vr_nrdigito
                        ,pr_stsnrcal => vr_stsnrcal
                        ,pr_des_erro => pr_des_erro);

      -- Verifica se ocorreram erros no processo
      IF pr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Atribui valor do c�lculo
      vr_nrcampo1 := vr_nrcalcul;

      -- Calcula o digito do primeiro campo - DV 2
      vr_nrcalcul := vr_nrcampo2 * 10;
      cada0001.pc_digm10(pr_nrcalcul => vr_nrcalcul
                        ,pr_nrdigito => vr_nrdigito
                        ,pr_stsnrcal => vr_stsnrcal
                        ,pr_des_erro => pr_des_erro);

      -- Verifica se ocorreram erros no processo
      IF pr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Atribui valor do c�lculo
      vr_nrcampo2 := vr_nrcalcul;

      -- Calcula digito - DV 3
      vr_nrcalcul := gene0002.fn_char_para_number(substr(to_char(vr_nrcampo3, 'fm000000000000'), 2, 11));
      cada0001.pc_digm10(pr_nrcalcul => vr_nrcalcul
                        ,pr_nrdigito => vr_nrdigito
                        ,pr_stsnrcal => vr_stsnrcal
                        ,pr_des_erro => pr_des_erro);

      -- Verifica se ocorreram erros no processo
      IF pr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Atribui valor do c�lculo
      vr_nrcampo3 := vr_nrcalcul;

      pr_dsdocmc7 := '<' || substr(to_char(vr_nrcampo1, 'fm00000000'), 1, 7) ||
                     substr(to_char(vr_nrcampo2, 'fm00000000000'), 11, 1) ||
                     '<' || substr(to_char(vr_nrcampo2, 'fm00000000000'), 1, 10) ||
                     '>' || substr(to_char(vr_nrcampo1, 'fm000000000'), 9, 1) ||
                     substr(to_char(vr_nrcampo3, 'fm000000000000'), 2, 11) || ':';

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'Erro em CHEQ0001.pc_calc_cmc7_difcompe: ' || pr_des_erro;
      WHEN OTHERS THEN
        pr_des_erro := 'Erro em CHEQ0001.pc_calc_cmc7_difcompe: ' || SQLERRM;
    END;
  END pc_calc_cmc7_difcompe;

  -- Calcular a quantidade de taloes e a posi��o do cheque no tal�o
  PROCEDURE pc_numtal( pr_nrfolhas  IN NUMBER -- n�mero de folhas do talon�rio
                      ,pr_nrcalcul  IN NUMBER -- n�mero da primeira/�ltima folha de cheque emitida nesse pedido
                      ,pr_nrtalchq OUT NUMBER -- n�mero do tal�o
                      ,pr_nrposchq OUT NUMBER -- posi��o do cheque
                      ) IS
  /* .............................................................................

     Programa: pc_numtal  (Antigo: Fontes/numtal.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Deborah/Edson
     Data    : Setembro/91.                        Ultima atualizacao: 13/09/13

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Calcular a partir do numero do cheque o numero do talao e a
                 posicao do cheque dentro do mesmo.

  Alteracoes: 13/09/2013 - Convers�o Progress >> Oracle (PLSQL) (Edison - AMcom)

  ............................................................................. */

  BEGIN

    DECLARE
      -- armazena o n�mero do cheque
      vr_auxnrcalcul NUMBER;
      -- quantidade de folhas do talon�rio
      vr_auxnrfolhas NUMBER;
      -- variaveeis auxiliares
      vr_calculo     NUMBER;
      vr_resto       NUMBER;
      -- vari�vel de retorno
      vr_auxnrtalchq NUMBER;
      vr_auxnrposchq NUMBER;
    BEGIN
      -- Inicializando
      vr_auxnrfolhas := pr_nrfolhas;
      vr_auxnrcalcul := pr_nrcalcul;
      -- Se o n�mero de folhas do talon�rio estiver zerado
      -- utiliza padr�o de 20 folhas
      IF nvl(vr_auxnrfolhas,0) = 0 THEN
        vr_auxnrfolhas := 20;
      END IF;

      -- Verifica a quantidade de taloes necess�rio levando em conta o n�mero
      -- do cheque e a quantidade de folhas por tal�o
      vr_calculo  := trunc(to_number(substr(lpad(vr_auxnrcalcul,8,'0'),1,7)) / vr_auxnrfolhas,0);
      -- calcula o resto da divis�o
      vr_resto    := mod(to_number(substr(lpad(vr_auxnrcalcul,8,'0'),1,7)), vr_auxnrfolhas);

      IF vr_resto = 0 THEN
        -- se n�o tem resto � porque a quantidade de folhas vai couber
        -- na quantidade exata de tal�es
        vr_auxnrtalchq := vr_calculo;
      ELSE
        -- se tem resto � porque a quantidade de folhas exige um talon�rio a mais
        vr_auxnrtalchq := vr_calculo + 1;
      END IF;

      IF vr_resto = 0 THEN
        -- se n�o tem resto recebe a quantidade exata de folhas
        vr_auxnrposchq := vr_auxnrfolhas;
      ELSE
        -- se tem resto � porque a quantidade de folhas exige um talon�rio a mais
        vr_auxnrposchq := vr_resto;
      END IF;

      -- Retornando a quantidade de tal�es e a posi��o das folhas
      pr_nrtalchq := vr_auxnrtalchq;
      pr_nrposchq := vr_auxnrposchq;

    END;
  END pc_numtal;
 
  --  Calcular os digitos do CMC-7
  PROCEDURE pc_dig_cmc7 (pr_dsdocmc7 IN  VARCHAR2   -- Documento cmc7
                        ,pr_nrdcampo OUT NUMBER     -- Numero do campo
                        ,pr_lsdigctr OUT VARCHAR2)  -- Lista de digitos
  IS
  /* .............................................................................

   Programa: pc_dig_cmc7 (Antigo -> Fontes/cmc7.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                         Ultima atualizacao: 19/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Entrar com o CMC-7 manualmente.

   Alteracoes: 19/12/2013 - Conversao Progress -> Oracle (Gabriel).
   
               20/03/2014 - Ajustes nas mascaras do vr_nrcampo3 (Odirlei-AMcom)

............................................................................. */
  BEGIN

    DECLARE

      vr_nrcalcul NUMBER;         -- Digitos dos campos CMC7
      vr_nrdigito NUMBER;         -- Digito que retorna do modulo 10
      vr_stsnrcal BOOLEAN;        -- Retorno da verificacao do modulo 10
      pr_des_erro VARCHAR2(100);  -- Descricao de erro
      vr_nrcampo1 NUMBER;         -- 1a parte do CMC7
      vr_nrcampo2 NUMBER;         -- 2a parte do CMC7
      vr_nrcampo3 NUMBER;         -- 3a parte do CMC7
      exc_nrdcampo_1 EXCEPTION;   -- Retornar nrdcampo = 1
      exc_nrdcampo_3 EXCEPTION;   -- Retornar nrdcampo = 3

    BEGIN

      -- Conteudo do par_dsdocmc7 = <00100950<0168086015>870000575178:
      vr_nrcampo1 := to_number(substr(pr_dsdocmc7,2,8));
      vr_nrcampo2 := to_number(substr(pr_dsdocmc7,11,10));
      vr_nrcampo3 := to_number(substr(pr_dsdocmc7,22,12));

      pr_nrdcampo := 0;

      -- Calcula o digito do terceiro campo  - DV 1
      vr_nrcalcul := vr_nrcampo1;

      -- Calcular e conferir o digito verificador pelo modulo dez.
      cada0001.pc_digm10(pr_nrcalcul => vr_nrcalcul
                        ,pr_nrdigito => vr_nrdigito
                        ,pr_stsnrcal => vr_stsnrcal
                        ,pr_des_erro => pr_des_erro);

      -- Juntar a lista de digitos
      pr_lsdigctr := to_char(vr_nrdigito);

      -- Verificar com o 1ero digitdo da 3a parte do cmc7
      IF  vr_nrdigito <> to_number(substr(gene0002.fn_mask(vr_nrcampo3,'999999999999'),1,1))  THEN
        RAISE exc_nrdcampo_3;
      END IF;

      -- Calcula o digito do primeiro campo  - DV 2
      vr_nrcalcul := vr_nrcampo2 * 10;

      -- Calcular e conferir o digito verificador pelo modulo dez.
      cada0001.pc_digm10(pr_nrcalcul => vr_nrcalcul
                        ,pr_nrdigito => vr_nrdigito
                        ,pr_stsnrcal => vr_stsnrcal
                        ,pr_des_erro => pr_des_erro);

      -- Juntar a lista de digitos
      pr_lsdigctr := pr_lsdigctr || ',' || to_char(vr_nrdigito,'0');

      -- Verificar com o ultiumo digito da 1era parte do cmc7
      IF  vr_nrdigito <> to_number(substr(to_char(vr_nrcampo1),length(to_char(vr_nrcampo1)),1))   THEN
        RAISE exc_nrdcampo_1;
      END IF;

      --  Calcula digito DV 3
      vr_nrcalcul := to_number(substr(gene0002.fn_mask(vr_nrcampo3,'999999999999'),2,11));

      -- Calcular e conferir o digito verificador pelo modulo dez.
      cada0001.pc_digm10(pr_nrcalcul => vr_nrcalcul
                        ,pr_nrdigito => vr_nrdigito
                        ,pr_stsnrcal => vr_stsnrcal
                        ,pr_des_erro => pr_des_erro);

      -- Juntar a lista de digitos
      pr_lsdigctr := pr_lsdigctr || ',' || to_char(vr_nrdigito,'0');

      IF   NOT vr_stsnrcal   THEN
        RAISE exc_nrdcampo_3;
      END IF;

    -- Tratamento de exception dependendo o numero do campo
    EXCEPTION

      WHEN exc_nrdcampo_1  THEN
        pr_nrdcampo := 1;

      WHEN exc_nrdcampo_3  THEN
        pr_nrdcampo := 3;

      WHEN OTHERS THEN
        pr_nrdcampo := 1;

    END;

  END pc_dig_cmc7;                       

    --Subrotina para obter cheques depositados
    PROCEDURE pc_obtem_cheques_deposito (pr_cdcooper     IN crapcop.cdcooper%TYPE              --Codigo Cooperativa
                                        ,pr_cdagenci     IN crapass.cdagenci%TYPE              --Codigo Agencia
                                        ,pr_nrdcaixa     IN INTEGER                            --Numero do Caixa
                                        ,pr_cdoperad     IN VARCHAR2                           --Codigo Operador
                                        ,pr_nmdatela     IN VARCHAR2                           --Nome da Tela
                                        ,pr_idorigem     IN INTEGER                            --Origem dos Dados
                                        ,pr_nrdconta     IN crapass.nrdconta%TYPE              --Numero da Conta do Associado
                                        ,pr_idseqttl     IN INTEGER                            --Sequencial do Titular
                                        ,pr_dtiniper     IN DATE                               --Data Inicio periodo   
                                        ,pr_dtfimper     IN DATE                               --Data Final periodo
                                        ,pr_flgpagin     IN BOOLEAN                            --Imprimir pagina
                                        ,pr_iniregis     IN INTEGER                            --Indicador Registro
                                        ,pr_qtregpag     IN INTEGER                            --Quantidade Registros Pagos
                                        ,pr_flgerlog     IN BOOLEAN                            --Imprimir log
                                        ,pr_qtregist     OUT INTEGER                           --Quantidade Registros
                                        ,pr_des_reto     OUT VARCHAR2                          --Retorno OK ou NOK
                                        ,pr_tab_erro     OUT gene0001.typ_tab_erro             --Tabela de Erros
                                        ,pr_tab_extrato_cheque OUT extr0002.typ_tab_extrato_cheque) IS  --Vetor para o retorno das informa��es
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_obtem_cheques_deposito            Antigo: procedures/b1wgen0001.p/obtem-cheques-deposito
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2014                           Ultima atualizacao: 02/07/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo   : Procedure para obter cheques depositados do associado
  --
  -- Altera��es : 02/07/2014 - Convers�o Progress -> Oracle (Alisson - AMcom)
  --              
  ---------------------------------------------------------------------------------------------------------------
      --Selecionar Cheques Descontados
      CURSOR cr_crapchd (pr_cdcooper IN crapchd.cdcooper%TYPE
                        ,pr_nrdconta IN crapchd.nrdconta%TYPE
                        ,pr_dtiniper IN crapchd.dtmvtolt%TYPE
                        ,pr_dtfimper IN crapchd.dtmvtolt%TYPE) IS
        SELECT crapchd.dtmvtolt
              ,crapchd.nrdocmto
              ,crapchd.cdbanchq
              ,crapchd.cdagechq
              ,crapchd.nrctachq
              ,crapchd.nrcheque
              ,crapchd.nrddigc3
              ,crapchd.vlcheque
              ,row_number() OVER(PARTITION BY crapchd.dtmvtolt 
                                 ORDER BY crapchd.dtmvtolt)     nrseqdat                             
              ,Count(1) OVER (PARTITION BY crapchd.dtmvtolt)    qttotdat 
              ,row_number() OVER(PARTITION BY crapchd.dtmvtolt,crapchd.nrdocmto 
                                 ORDER BY crapchd.dtmvtolt,crapchd.nrdocmto)  nrseqdoc                             
              ,Count(1) OVER (PARTITION BY crapchd.dtmvtolt,crapchd.nrdocmto) qttotdoc 
        FROM crapchd crapchd     
        WHERE crapchd.cdcooper = pr_cdcooper 
        AND   crapchd.nrdconta = pr_nrdconta 
        AND   crapchd.cdbccxlt <> 700          
        AND   crapchd.dtmvtolt >= pr_dtiniper 
        AND   crapchd.dtmvtolt <= pr_dtfimper 
        AND   crapchd.nrdocmto > 0
        ORDER BY crapchd.dtmvtolt
                ,crapchd.nrdocmto
                ,crapchd.cdbanchq
                ,crapchd.cdagechq
                ,crapchd.nrctachq
                ,crapchd.nrcheque;  
      --Variaveis Locais
      vr_fimregis INTEGER;
      vr_index    INTEGER;
      vr_vltotchq NUMBER;
      vr_dtmvtolt VARCHAR2(10);
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecoes
      vr_exc_erro EXCEPTION;
    BEGIN
      --Limpar tabelas memoria
      pr_tab_erro.DELETE;
      pr_tab_extrato_cheque.DELETE;
      
      --Inicializar transacao
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa:= 'Listar cheques em deposito.';
      --Fim registro
      vr_fimregis:= nvl(pr_iniregis,0) + nvl(pr_qtregpag,0);
      
      --Buscar Cheques Descontados
      FOR rw_crapchd IN cr_crapchd (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_dtiniper => pr_dtiniper
                                   ,pr_dtfimper => pr_dtfimper) LOOP
        --Incrementar quantidade
        pr_qtregist:= nvl(pr_qtregist,0) + 1;
        --Primeiro registro data ou primeiro registro documento ou quantidade registro igual inicial
        IF rw_crapchd.nrseqdat = 1 OR 
           rw_crapchd.nrseqdoc = 1 OR 
           pr_qtregist = pr_iniregis THEN
          vr_dtmvtolt:= to_char(rw_crapchd.dtmvtolt,'DD/MM/YYYY');
          vr_vltotchq:= rw_crapchd.vlcheque;
        ELSE
          vr_dtmvtolt:= NULL;
          vr_vltotchq:= nvl(vr_vltotchq,0) + rw_crapchd.vlcheque;  
        END IF; 
        --Nao pagina
        IF NOT pr_flgpagin OR 
           (pr_qtregist >= pr_iniregis AND pr_qtregist < vr_fimregis) THEN
          --Inserir dados tabela memoria extrato cheques
          vr_index:= pr_tab_extrato_cheque.COUNT+1;
          pr_tab_extrato_cheque(vr_index).dtmvtolt:= vr_dtmvtolt; 
          pr_tab_extrato_cheque(vr_index).nrdocmto:= rw_crapchd.nrdocmto;
          pr_tab_extrato_cheque(vr_index).cdbanchq:= rw_crapchd.cdbanchq;
          pr_tab_extrato_cheque(vr_index).cdagechq:= rw_crapchd.cdagechq;
          pr_tab_extrato_cheque(vr_index).nrctachq:= rw_crapchd.nrctachq;
          pr_tab_extrato_cheque(vr_index).nrcheque:= rw_crapchd.nrcheque;
          pr_tab_extrato_cheque(vr_index).nrddigc3:= rw_crapchd.nrddigc3;
          pr_tab_extrato_cheque(vr_index).vlcheque:= rw_crapchd.vlcheque;
          --Ultima Data ou ultimo Documento
          IF rw_crapchd.nrseqdat = rw_crapchd.qttotdat OR
             rw_crapchd.nrseqdoc = rw_crapchd.qttotdoc OR
             (pr_flgpagin AND pr_qtregist = (vr_fimregis - 1)) THEN
            --Valor Total Cheque 
            pr_tab_extrato_cheque(vr_index).vltotchq:= vr_vltotchq;
          ELSE
            --Valor Total Cheque 
            pr_tab_extrato_cheque(vr_index).vltotchq:= 0;
          END IF;          
        END IF;  
      END LOOP;
      
      -- Se foi solicitado gera��o de LOG
      IF pr_flgerlog THEN
        -- Chamar gera��o de LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;    
      --Retorno OK
      pr_des_reto:= 'OK';  
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        vr_dscritic := 'Erro na rotina pc_obtem_cheques_deposito';
        -- Chamar rotina de grava��o de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado gera��o de LOG
        IF pr_flgerlog THEN
          -- Chamar gera��o de LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => GENE0001.vr_vet_des_origens(pr_idorigem)
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;  
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Chamar rotina de grava��o de erro
        vr_dscritic := 'Erro na pc_obtem_cheques_deposito --> '|| sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado gera��o de LOG
        IF pr_flgerlog THEN
          -- Chamar gera��o de LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => GENE0001.vr_vet_des_origens(pr_idorigem)
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;    
    END pc_obtem_cheques_deposito; 
    
                        
  -- TELA: CHEQUE - Matriz de Cheques
  PROCEDURE pc_busca_cheque(pr_cdcooper  IN     NUMBER           --> C�digo cooperativa
                           ,pr_nrtipoop  IN     NUMBER           --> Tipo de opera��o
                           ,pr_nrdconta  IN     NUMBER           --> N�mero da conta
                           ,pr_nrcheque  IN     NUMBER           --> N�mero de cheque
                           ,pr_nrregist  IN     NUMBER           --> N�mero de registro
                           ,pr_nriniseq  IN     NUMBER           --> Inicial da sequencia
                           ,pr_xmllog    IN     VARCHAR2         --> XML com informa��es de LOG
                           ,pr_cdcritic     OUT PLS_INTEGER      --> C�digo da cr�tica
                           ,pr_dscritic     OUT VARCHAR2         --> Descri��o da cr�tica
                           ,pr_retxml    IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                           ,pr_nmdcampo     OUT VARCHAR2         --> Nome do campo com erro
                           ,pr_des_erro     OUT VARCHAR2) IS     --> Erros do processo
    /* ..........................................................................
    --
    --  Programa : pc_busca_cheque    (Antigo /generico/procedures/b1wgen0040.p --> busca-cheques)
    --  Sistema  : Rotinas para cadastros Web
    --  Sigla    : CHEQUE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: 24/11/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar informa��es a respeito dos cheques (Web).
    --
    --   Alteracoes: 22/05/2013 - Convers�o Progress-Oracle. Petter - Supero
    --
    --               22/07/2014 - Migrar a procedure para a package e ajustar 
    --                            a mesma. ( Renato - Supero )
    --               27/10/2014 - Inclus�o da tag cdagechq e cdageaco em pc_gera_tag 
    --                          	(Lucas R. e Vanessa) 
    
                     25/04/2017 - Incluir >= na busca do todos pr_nrtipoop = 5 para 
                                  trazer todos os cheques a partir do informado (Lucas Ranghetti #625222)
                                  
                     11/10/2017 - Mudar ordenacao do select pra trazer os ultimos cheques
                                  emitidos primeiro qdo a opcao for TODOS na tela (Tiago #725346)
                                  
                     24/11/2017 - Quando usar a opcao todos e filtrar pelo nr cheque
                                  deve ordenar a lista pelo numero do cheque (Tiago/Adriano)
     .............................................................................*/
    
    -- Vari�veis
    vr_nrregist    NUMBER;                        --> N�mero do registro
    vr_lscontas    VARCHAR2(400);                 --> Lista de contas
    vr_exc_erro    EXCEPTION;                     --> Controle de erros de processo
    
    vr_sql         VARCHAR2(4000);                --> SQL din�mico
    vr_nrcheque    crapfdc.nrcheque%TYPE;         --> N�mero cheque
    vr_nrdigchq    crapfdc.nrdigchq%TYPE;         --> D�gito cheque
    vr_cdbanchq    crapfdc.cdbanchq%TYPE;         --> C�digo banco cheque
    vr_nrseqems    crapfdc.nrseqems%TYPE;         --> N�mero da sequencia
    vr_tpforchq    crapfdc.tpforchq%TYPE;         --> Tipo cheque
    vr_nrdctitg    crapfdc.nrdctitg%TYPE;         --> N�mero tag
    vr_nrpedido    crapfdc.nrpedido%TYPE;         --> N�mero pedido
    vr_vlcheque    crapfdc.vlcheque%TYPE;         --> Valor do cheque
    vr_cdtpdchq    crapfdc.cdtpdchq%TYPE;         --> Tipo do cheque
    vr_cdbandep    crapfdc.cdbandep%TYPE;         --> C�digo bandeira
    vr_cdagedep    crapfdc.cdagedep%TYPE;         --> C�digo agencia
    vr_nrctadep    crapfdc.nrctadep%TYPE;         --> N�mero conta
    vr_cdbantic    crapfdc.cdbantic%TYPE;         --> C�digo tipo do banco
    vr_cdagetic    crapfdc.cdagetic%TYPE;         --> C�digo tipo da agencia
    vr_nrctatic    crapfdc.nrctatic%TYPE;         --> c�digo tipo da conta
    vr_dtlibtic    crapfdc.dtlibtic%TYPE;         --> Data libera��o
    vr_tpcheque    crapfdc.tpcheque%TYPE;         --> Tipo do cheque
    vr_incheque    crapfdc.incheque%TYPE;         --> Entrada cheque
    vr_dtemschq    crapfdc.dtemschq%TYPE;         --> Data limite
    vr_dtretchq    crapfdc.dtretchq%TYPE;         --> Data retirada
    vr_dtliqchq    crapfdc.dtliqchq%TYPE;         --> Data liquida��o
    vr_nrdctabb    crapfdc.nrdctabb%TYPE;         --> N�mero da conta BB
    vr_cdagechq    crapfdc.cdagechq%TYPE;         --> C�digo agencia cheque
    vr_nrctachq    crapfdc.nrctachq%TYPE;         --> N�mero conta cheque
    vr_dsdocmc7    crapfdc.dsdocmc7%TYPE;         --> Descri��o documento CMC - 7
    vr_cdcmpchq    crapfdc.cdcmpchq%TYPE;         --> Campo cheque
    vr_cdageaco    crapfdc.cdageaco%TYPE;         --> Agencia acolhedora
    vr_cursor      NUMBER;                        --> ID da execu��o DBMS
    vr_exec        NUMBER;                        --> Identifica��o da execu��o
    vr_fetch       NUMBER;                        --> Identifica��o do FETCH (itera��o do LOOP)
    vr_tab_cheque  gene0007.typ_mult_array;       --> PL Table para armazenar dados de cheques
    vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG�s do XML
    vr_finaliza    BOOLEAN;                       --> Executa interrup��o do LOOP por comando externo
    vr_qtregist    PLS_INTEGER;                   --> Quantidade de registros processados

  BEGIN
    -- Carga inicial das vari�veis
    pr_dscritic := '';
    pr_cdcritic := 0;
    vr_nrregist := pr_nrregist;

    -- Busca dados das contas BBrasil
    cada0001.pc_BuscaCtaCe(pr_cdcooper => pr_cdcooper
                          ,pr_tpregist => 0
                          ,pr_lscontas => vr_lscontas
                          ,pr_dscritic => pr_dscritic
                          ,pr_des_erro => pr_des_erro);

    -- Verifica se ocorreram erros
    IF pr_des_erro IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Verifica se ocorreram cr�ticas
    IF pr_dscritic IS NOT NULL THEN
      GOTO verifica_critica; -- ATEN��O: GOTO desviando a execu��o do programa para <<verifica_critica>>
    END IF;

    -- Parte comum do SQL din�mico
    vr_sql := 'select /*+ INDEX (crapfdc CRAPFDC##CRAPFDC2) */' ||
               'nrcheque ' ||
               ',nrdigchq ' ||
               ',cdbanchq ' ||
               ',nrseqems ' ||
               ',tpforchq ' ||
               ',nrdctitg ' ||
               ',nrpedido ' ||
               ',vlcheque ' ||
               ',cdtpdchq ' ||
               ',cdbandep ' ||
               ',cdagedep ' ||
               ',nrctadep ' ||
               ',cdbantic ' ||
               ',cdagetic ' ||
               ',nrctatic ' ||
               ',dtlibtic ' ||
               ',tpcheque ' ||
               ',incheque ' ||
               ',dtemschq ' ||
               ',dtretchq ' ||
               ',dtliqchq ' ||
               ',nrdctabb ' ||
               ',cdagechq ' ||
               ',nrctachq ' ||
               ',dsdocmc7 ' ||
               ',cdcmpchq ' ||
               ',cdageaco ' ||
               'from crapfdc ' ||
               'where cdcooper = ' || pr_cdcooper || ' ' ||
               'and nrdconta = ' || pr_nrdconta || ' ';

    -- Valida fluxo do processamento
    CASE pr_nrtipoop
      WHEN 1 THEN
        vr_sql := vr_sql || 'and dtliqchq is null ' ||
                            'and dtretchq is not null ' ||
                            'order by nrctachq desc, nrseqems desc, nrcheque desc';
      WHEN 2 THEN
        vr_sql := vr_sql || 'and dtretchq is null ' ||
                            'and dtemschq is not null ' ||
                            'order by nrctachq desc, nrseqems desc, nrcheque desc';
      WHEN 3 THEN
        vr_sql := vr_sql || 'and dtemschq is null ' ||
                            'order by nrctachq desc, nrseqems desc, nrcheque desc';
      WHEN 4 THEN
        vr_sql := vr_sql || 'and dtliqchq is not null ' ||
                            'and incheque = 5 ' ||
                            'order by nrctachq desc, nrseqems desc, nrcheque desc';
      WHEN 5 THEN
        IF pr_nrcheque > 0 THEN
          vr_sql := vr_sql || 'and nrcheque >= ' || pr_nrcheque || ' order by nrcheque';
        ELSE
          vr_sql := vr_sql || 'order by dtemschq desc, nrcheque desc';  
        END IF;
    END CASE;

    -- Buscar ID da execu��o DBMS
    vr_cursor := dbms_sql.open_cursor;
    -- Parser do SQL din�mico
    dbms_sql.parse(vr_cursor,  vr_sql, 1);
    -- Define os retornos da coluna
    dbms_sql.define_column(vr_cursor, 1, vr_nrcheque);
    dbms_sql.define_column(vr_cursor, 2, vr_nrdigchq);
    dbms_sql.define_column(vr_cursor, 3, vr_cdbanchq);
    dbms_sql.define_column(vr_cursor, 4, vr_nrseqems);
    dbms_sql.define_column(vr_cursor, 5, vr_tpforchq, 10);
    dbms_sql.define_column(vr_cursor, 6, vr_nrdctitg, 16);
    dbms_sql.define_column(vr_cursor, 7, vr_nrpedido);
    dbms_sql.define_column(vr_cursor, 8, vr_vlcheque);
    dbms_sql.define_column(vr_cursor, 9, vr_cdtpdchq);
    dbms_sql.define_column(vr_cursor, 10, vr_cdbandep);
    dbms_sql.define_column(vr_cursor, 11, vr_cdagedep);
    dbms_sql.define_column(vr_cursor, 12, vr_nrctadep);
    dbms_sql.define_column(vr_cursor, 13, vr_cdbantic);
    dbms_sql.define_column(vr_cursor, 14, vr_cdagetic);
    dbms_sql.define_column(vr_cursor, 15, vr_nrctatic);
    dbms_sql.define_column(vr_cursor, 16, vr_dtlibtic);
    dbms_sql.define_column(vr_cursor, 17, vr_tpcheque);
    dbms_sql.define_column(vr_cursor, 18, vr_incheque);
    dbms_sql.define_column(vr_cursor, 19, vr_dtemschq);
    dbms_sql.define_column(vr_cursor, 20, vr_dtretchq);
    dbms_sql.define_column(vr_cursor, 21, vr_dtliqchq);
    dbms_sql.define_column(vr_cursor, 22, vr_nrdctabb);
    dbms_sql.define_column(vr_cursor, 23, vr_cdagechq);
    dbms_sql.define_column(vr_cursor, 24, vr_nrctachq);
    dbms_sql.define_column(vr_cursor, 25, vr_dsdocmc7, 60);
    dbms_sql.define_column(vr_cursor, 26, vr_cdcmpchq);
    dbms_sql.define_column(vr_cursor, 27, vr_cdageaco);
    

    -- Executa o cursor din�mico
    vr_exec := dbms_sql.EXECUTE(vr_cursor);

    -- Realizar FETCH sob os resultados retornados
    LOOP
      vr_fetch := dbms_sql.fetch_rows(vr_cursor);

      EXIT WHEN vr_fetch = 0;

      -- Carregar valores das vari�veis de coluna
      dbms_sql.column_value(vr_cursor, 1, vr_nrcheque);
      dbms_sql.column_value(vr_cursor, 2, vr_nrdigchq);
      dbms_sql.column_value(vr_cursor, 3, vr_cdbanchq);
      dbms_sql.column_value(vr_cursor, 4, vr_nrseqems);
      dbms_sql.column_value(vr_cursor, 5, vr_tpforchq);
      dbms_sql.column_value(vr_cursor, 6, vr_nrdctitg);
      dbms_sql.column_value(vr_cursor, 7, vr_nrpedido);
      dbms_sql.column_value(vr_cursor, 8, vr_vlcheque);
      dbms_sql.column_value(vr_cursor, 9, vr_cdtpdchq);
      dbms_sql.column_value(vr_cursor, 10, vr_cdbandep);
      dbms_sql.column_value(vr_cursor, 11, vr_cdagedep);
      dbms_sql.column_value(vr_cursor, 12, vr_nrctadep);
      dbms_sql.column_value(vr_cursor, 13, vr_cdbantic);
      dbms_sql.column_value(vr_cursor, 14, vr_cdagetic);
      dbms_sql.column_value(vr_cursor, 15, vr_nrctatic);
      dbms_sql.column_value(vr_cursor, 16, vr_dtlibtic);
      dbms_sql.column_value(vr_cursor, 17, vr_tpcheque);
      dbms_sql.column_value(vr_cursor, 18, vr_incheque);
      dbms_sql.column_value(vr_cursor, 19, vr_dtemschq);
      dbms_sql.column_value(vr_cursor, 20, vr_dtretchq);
      dbms_sql.column_value(vr_cursor, 21, vr_dtliqchq);
      dbms_sql.column_value(vr_cursor, 22, vr_nrdctabb);
      dbms_sql.column_value(vr_cursor, 23, vr_cdagechq);
      dbms_sql.column_value(vr_cursor, 24, vr_nrctachq);
      dbms_sql.column_value(vr_cursor, 25, vr_dsdocmc7);
      dbms_sql.column_value(vr_cursor, 26, vr_cdcmpchq);
      dbms_sql.column_value(vr_cursor, 27, vr_cdageaco);

      -- Chamar procedure para gerar PL Table de listagem dos cheques
      cheq0001.pc_gera_cheques(pr_nrtipoop    => pr_nrtipoop
                              ,pr_cdcooper    => pr_cdcooper
                              ,pr_lscontas    => vr_lscontas
                              ,pr_nriniseq    => pr_nriniseq
                              ,pr_nrregist    => pr_nrregist
                              ,pr_auxnrregist => vr_nrregist
                              ,pr_qtregist    => vr_qtregist
                              ,pr_tab_cheques => vr_tab_cheque
                              ,pr_nrcheque    => vr_nrcheque
                              ,pr_nrdigchq    => vr_nrdigchq
                              ,pr_cdbanchq    => vr_cdbanchq
                              ,pr_nrseqems    => vr_nrseqems
                              ,pr_tpforchq    => vr_tpforchq
                              ,pr_nrdctitg    => vr_nrdctitg
                              ,pr_nrpedido    => vr_nrpedido
                              ,pr_vlcheque    => vr_vlcheque
                              ,pr_cdtpdchq    => vr_cdtpdchq
                              ,pr_cdbandep    => vr_cdbandep
                              ,pr_cdagedep    => vr_cdagedep
                              ,pr_nrctadep    => vr_nrctadep
                              ,pr_cdbantic    => vr_cdbantic
                              ,pr_cdagetic    => vr_cdagetic
                              ,pr_nrctatic    => vr_nrctatic
                              ,pr_dtlibtic    => vr_dtlibtic
                              ,pr_tpcheque    => vr_tpcheque
                              ,pr_incheque    => vr_incheque
                              ,pr_dtemschq    => vr_dtemschq
                              ,pr_dtretchq    => vr_dtretchq
                              ,pr_dtliqchq    => vr_dtliqchq
                              ,pr_nrdctabb    => vr_nrdctabb
                              ,pr_cdagechq    => vr_cdagechq
                              ,pr_nrctachq    => vr_nrctachq
                              ,pr_dsdocmc7    => vr_dsdocmc7
                              ,pr_cdcmpchq    => vr_cdcmpchq
                              ,pr_cdageaco    => vr_cdageaco
                              ,pr_fim         => vr_finaliza
                              ,pr_des_erro    => pr_des_erro);

      -- Verifica se ocorreram erros de execu��o
      IF pr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;
    
    -- Label definindo o ponto de continua��o do GOTO
    <<verifica_critica>>
    
    -- Verificar se gerou c�digo ou descri��o de cr�tica
    IF pr_cdcritic <> 0 OR pr_dscritic IS NOT NULL THEN
      -- Gera erros para propaga��o XML
      IF pr_dscritic IS NULL THEN
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      END IF;

      -- Retorno de erro
      pr_des_erro := 'NOK';

      RAISE vr_exc_erro;
    END IF;

    -- Retorno de sucesso
    pr_des_erro := 'OK';

    -- Carrega as TAG�s do XML
    gene0007.pc_gera_tag(pr_nome_tag  => 'cdbanchq', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'nrcheque', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'nrseqems', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'tpcheque', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'tpforchq', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'dsobserv', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'dtemschq', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'dtretchq', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'dtliqchq', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'nrdctitg', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'nrpedido', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'dtsolped', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'dtrecped', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'dsdocmc7', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'dscordem', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'dscorde1', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'dtmvtolt', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'vlcheque', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'vldacpmf', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'cdtpdchq', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'cdbandep', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'cdagedep', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'nrctadep', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'flgsubtd', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'nrdigchq', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'cdbantic', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'cdagetic', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'nrctatic', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'cdagechq', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'cdageaco', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'dtlibtic', pr_tab_tag   => vr_tab_tags);
    
    

    -- Criar cabe�alho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    -- Criar nodo filho
    pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                       ,'/Root'
                                       ,XMLTYPE('<Dados qtregist="' || vr_qtregist || '"></Dados>'));

    -- Forma XML de retorno para casos de sucesso (listar dados)
    gene0007.pc_gera_xml(pr_tab_dados => vr_tab_cheque
                        ,pr_tab_tag   => vr_tab_tags
                        ,pr_XMLType   => pr_retxml
                        ,pr_path_tag  => '/Root/Dados'
                        ,pr_tag_no    => 'Registro'
                        ,pr_des_erro  => pr_des_erro);

    -- Verifica se ocorreram erros
    IF pr_des_erro IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Finaliza com status de sucesso
    pr_des_erro := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_des_erro := pr_des_erro;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');

    WHEN OTHERS THEN
      pr_des_erro := 'Erro geral: ' || SQLERRM;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_busca_cheque;
 
  -- TELA: CHEQUE - Matriz de Cheques - Buscar a conta
  PROCEDURE pc_verif_conta(pr_xmllog    IN     VARCHAR2         --> XML com informa��es de LOG
                          ,pr_cdcritic     OUT PLS_INTEGER      --> C�digo da cr�tica
                          ,pr_dscritic     OUT VARCHAR2         --> Descri��o da cr�tica
                          ,pr_retxml    IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                          ,pr_nmdcampo     OUT VARCHAR2         --> Nome do campo com erro
                          ,pr_des_erro     OUT VARCHAR2) IS     --> Erros do processo
    -- ..........................................................................
    --
    --  Programa : pc_verif_conta    (Antigo /generico/procedures/b1wgen0040.p --> verifica-conta)
    --  Sistema  : Rotinas para cadastros Web
    --  Sigla    : CHEQUE
    --  Autor    : Renato Darosci
    --  Data     : Agosto/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar informa��es a respeito dos cheques (Web).
    --
    --   Alteracoes: 01/08/2014 - Convers�o Progress >> Oracle. Renato - Supero
    --
    -- .............................................................................
    -- Cursores 
    -- Buscar dados do associado
    CURSOR cr_crapass(pr_cdcooper  IN crapass.cdcooper%TYPE
                     ,pr_nrdconta  IN crapass.nrdconta%TYPE) IS
      SELECT t.nmprimtl
        FROM crapass    t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta;
    rw_crapass     cr_crapass%ROWTYPE;
    
    -- Buscar transferencias
    CURSOR cr_craptrf(pr_cdcooper  IN craptrf.cdcooper%TYPE
                     ,pr_nrdconta  IN craptrf.nrdconta%TYPE) IS
      SELECT craptrf.nrsconta
        FROM craptrf 
       WHERE craptrf.cdcooper = pr_cdcooper
         AND craptrf.nrdconta = pr_nrdconta
         AND craptrf.tptransa = 1
         AND craptrf.insittrs = 2;
    rw_craptrf     cr_craptrf%ROWTYPE;
    
    -- Buscar a quantidade de requisi��es de talon�rios
    CURSOR cr_crapreq(pr_cdcooper  IN crapreq.cdcooper%TYPE
                     ,pr_nrdconta  IN crapreq.nrdconta%TYPE) IS
      SELECT NVL(SUM(NVL(crapreq.qtreqtal,0) * 20),0)  qtrequis
        FROM crapreq 
       WHERE crapreq.cdcooper = pr_cdcooper
         AND crapreq.nrdconta = pr_nrdconta
         AND crapreq.insitreq = 1
         AND crapreq.tprequis = 1;
    
    -- Vari�veis
    vr_qtregist    CONSTANT NUMBER := 1;
    
    vr_cdcooper    crapcop.cdcooper%TYPE;   --> C�digo da cooperativa
    vr_cdoperad    crapope.cdoperad%TYPE;   --> C�digo do operador
    vr_cdagenci    crapage.cdagenci%TYPE;   --> C�digo da agencia
    vr_nrdconta    crapass.nrdconta%TYPE;   --> N�mero de conta
    vr_tab_tags    gene0007.typ_tab_tagxml; --> PL Table para armazenar TAG�s do XML
    vr_tab_dados   gene0007.typ_mult_array; --> PL Table para armazenar valores
    
    vr_nmprimtl    VARCHAR2(200);
    vr_dsmsgcnt    VARCHAR2(200);
    vr_qtrequis    NUMBER;
    
    vr_tabderro    GENE0001.typ_tab_erro;
    
    vr_exc_erro    EXCEPTION;    --> Controle de erros de processo
    vr_retorno     EXCEPTION;    --> Exception para encerrar a execu��o da rotina
    
    -- Retornar o valor do nodo tratando casos nulos
    FUNCTION fn_extract(pr_nodo  VARCHAR2) RETURN VARCHAR2 IS
      
    BEGIN
      -- Extrai e retorna o valor... retornando null em caso de erro ao ler
      RETURN TRIM(pr_retxml.extract(pr_nodo).getstringval());
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
        
  BEGIN

    -- Carga inicial das vari�veis
    pr_dscritic := '';
    
    pr_cdcritic := 0;
    
    -- Limpar tabela de erros
    vr_tabderro.DELETE;
    
    -- Extrair as informa��es do XML
    vr_cdcooper := fn_extract('/Root/Dados/cdcooper/text()');
    vr_cdoperad := fn_extract('/Root/Dados/cdoperad/text()');
    vr_cdagenci := fn_extract('/Root/Dados/cdagenci/text()');
    vr_nrdconta := fn_extract('/Root/Dados/nrdconta/text()');
    
    -- Validacao de operador e conta migrada
    CADA0001.pc_valida_operador_migrado(pr_cdcooper => vr_cdcooper
                                       ,pr_cdoperad => vr_cdoperad
                                       ,pr_cdagenci => vr_cdagenci
                                       ,pr_nrdconta => vr_nrdconta
                                       ,pr_tab_erro => vr_tabderro);

    -- Verifica se houve o retorno de erros
    IF vr_tabderro.count > 0 THEN
      -- Retornar a mensagem de erro nos parametros
      pr_cdcritic := vr_tabderro(vr_tabderro.FIRST).cdcritic;
      pr_dscritic := vr_tabderro(vr_tabderro.FIRST).dscritic;
      
      -- Limpar tabela de erros
      vr_tabderro.DELETE;
      
      RAISE vr_exc_erro;
    END IF;

    -- Se tem n�mero de conta
    IF NVL(vr_nrdconta,0) > 0 THEN
      
      -- Buscar pelo associado
      OPEN  cr_crapass(vr_cdcooper, vr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      
      -- Se n�o encontrar o registro
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor antes de encerrar a execu��o
        CLOSE cr_crapass;
      
        -- Retornar a mensagem de erro nos parametros
        pr_cdcritic := 9;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      
        RAISE vr_exc_erro;
      END IF;
      
      -- Fechar o cursor 
      CLOSE cr_crapass;
      
      -- Guarda o nome 
      vr_nmprimtl := rw_crapass.nmprimtl;
      
      -- Buscar por transferencia
      OPEN  cr_craptrf(vr_cdcooper, vr_nrdconta);
      FETCH cr_craptrf INTO rw_craptrf;
      -- Se encontrar algum registro de transferencia
      IF cr_craptrf%FOUND THEN
        -- Mensagem de transferencia da conta
        vr_dsmsgcnt := 'Conta transferida para '||TRIM(GENE0002.fn_mask_conta(rw_craptrf.nrsconta));
      END IF;    
      
      CLOSE cr_craptrf;
      
      -- Buscar a quantidade de requisi��es de talion�rios
      OPEN  cr_crapreq(vr_cdcooper, vr_nrdconta);
      FETCH cr_crapreq INTO vr_qtrequis;
      CLOSE cr_crapreq;
    ELSE
      -- Quando n�o encontrar conta utiliza descri��o padr�o
      vr_nmprimtl := '*** TALONARIOS AVULSOS ***';
    END IF;
    
    -- Retorno de sucesso
    pr_des_erro := 'OK';

    -- Carrega as TAG�s do XML
    gene0007.pc_gera_tag(pr_nome_tag  => 'nmprimtl', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'qtrequis', pr_tab_tag   => vr_tab_tags);
    gene0007.pc_gera_tag(pr_nome_tag  => 'dsmsgcnt', pr_tab_tag   => vr_tab_tags);
    
    -- Valores a serem enviados 
    vr_tab_dados(1)('nmprimtl') := vr_nmprimtl;
    vr_tab_dados(1)('qtrequis') := vr_qtrequis;
    vr_tab_dados(1)('dsmsgcnt') := vr_dsmsgcnt;
    
    -- Criar cabe�alho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    -- Forma XML de retorno para casos de sucesso (listar dados)
    gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                        ,pr_tab_tag   => vr_tab_tags
                        ,pr_XMLType   => pr_retxml
                        ,pr_path_tag  => '/Root'
                        ,pr_tag_no    => 'Dados'
                        ,pr_des_erro  => pr_des_erro);

    -- Verifica se ocorreram erros
    IF pr_des_erro IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Finaliza com status de sucesso
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_des_erro := pr_des_erro;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');

    WHEN OTHERS THEN
      pr_des_erro := 'Erro geral: ' || SQLERRM;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_verif_conta;
             
  PROCEDURE pc_ver_fraude_chq_extern (pr_cdcooper IN NUMBER                                  --> Cooperativa
                                     ,pr_cdprogra IN VARCHAR2                                --> Programa chamador
                                     ,pr_cdbanco  IN tbchq_sinistro_outrasif.cdbanco%TYPE    --> N�mero do Banco do Chque
                                     ,pr_nrcheque IN tbchq_sinistro_outrasif.nrcheque%TYPE   --> Numero do Cheque
                                     ,pr_nrctachq IN tbchq_sinistro_outrasif.nrcontachq%TYPE --> Numero da Conta do Cheque
                                     ,pr_cdoperad IN tbchq_sinistro_outrasif.cdoperad%TYPE   --> Operador 
                                     ,pr_cdagenci IN tbchq_sinistro_outrasif.cdagencia%TYPE  --> C�digo da Agencia do Cheque
                                     ,pr_des_erro OUT VARCHAR2) IS                           --> Descri��o do erro 
  BEGIN
    /* .............................................................................

    Programa: pc_ver_fraude_chq_extern
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Ranghetti
    Data    : Agosto/2015                          Ultima alteracao: 27/12/2017

    Dados referentes ao programa:

    Frequencia: Diario (Batch)
    Objetivo  : Verificar possivel fraude dos cheques de outras instituicoes com sinistros (UNICRED).

    Alteracoes: 27/12/2017 - Adicionar o N�mero da Agencia do Cheque como parametro e buscar 
                             a informa��o de cheque sinistrado com a informa��o da agencia
                             do cheque (Douglas - Chamado 820177)
    ............................................................................. */
    DECLARE
      -- buscar cheques de outras instituicoes com sinistros
      CURSOR cr_tbchq (pr_cdbanco  IN tbchq_sinistro_outrasif.cdbanco%TYPE,
                       pr_nrcheque IN tbchq_sinistro_outrasif.nrcheque%TYPE,
                       pr_cdagechq IN tbchq_sinistro_outrasif.cdagencia%TYPE,
                       pr_nrctachq IN tbchq_sinistro_outrasif.nrcontachq%TYPE) IS
        SELECT tbchq.nrcheque,
               tbchq.nrcontachq,
               tbchq.cdbanco
          FROM tbchq_sinistro_outrasif tbchq
         WHERE tbchq.cdbanco    = pr_cdbanco
           AND tbchq.nrcheque   = pr_nrcheque
           AND tbchq.cdagencia  = pr_cdagechq
           /* nr da conta cadastrada LIKE qlqr str terminando no Conta completa do cmc7  */
           AND regexp_like(pr_nrctachq, '.*'||tbchq.nrcontachq||'$');
           
         rw_tbchq cr_tbchq%ROWTYPE;     
       
      vr_cdcritic  NUMBER:= 0;
      vr_dscritic VARCHAR2(100);
      vr_emaildst VARCHAR2(50);
      vr_conteudo VARCHAR2(150);
      vr_exc_saida EXCEPTION;
       
    BEGIN
      -- Inicia sem erro
      pr_des_erro := '';
      
      --Inicializa variavel de erro
      pr_des_erro:= NULL;
       
      -- Verificar cheque contem fraude
      OPEN cr_tbchq (pr_cdbanco  => pr_cdbanco,
                     pr_nrcheque => pr_nrcheque,
                     pr_cdagechq => pr_cdagenci,
                     pr_nrctachq => pr_nrctachq);
      FETCH cr_tbchq INTO rw_tbchq;
      -- caso tenha fraude
      IF cr_tbchq%FOUND THEN
        vr_cdcritic:= 948; -- Sinistro de cheque
      END IF;
      -- fechar cursor aberto
      CLOSE cr_tbchq;         
      
      -- Caso a critica seja a mesma gerada anteriormente (948)
      IF vr_cdcritic IN (948) THEN        
        -- Gravar email destino
        vr_emaildst := 'segurancacorporativa@cecred.coop.br';
        -- Conteudo do email
        vr_conteudo := 'Banco: '    || pr_cdbanco  || chr(13) || 
                       'Conta: '    || pr_nrctachq || chr(13) ||
                       'PA: '       || pr_cdagenci || chr(13) ||
                       'Operador: ' || pr_cdoperad;
                       
        -- Caso tenha sinistro, retorna erro abaixo
        pr_des_erro:= 'Atencao! Operacao nao autorizada. Cheque envolvido em sinistro.';
        
        -- Enviar e-mail dos dados deste sinistro
        gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                  ,pr_cdprogra        => pr_cdprogra
                                  ,pr_des_destino     => vr_emaildst
                                  ,pr_des_assunto     => 'Cheque UNICRED envolvido em sinistro'
                                  ,pr_des_corpo       => vr_conteudo
                                  ,pr_des_anexo       => NULL
                                  ,pr_des_erro        => vr_dscritic);
        -- Caso encontre alguma critica no envio do email                          
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
      END IF;
    EXCEPTION
      WHEN vr_exc_saida  THEN
        pr_des_erro := vr_dscritic;
      WHEN OTHERS THEN
        pr_des_erro := 'Erro geral: ' || SQLERRM;
    END;
    
  END pc_ver_fraude_chq_extern;


  /* Rotina para criar registros de devolucao/taxa de cheques. */
  PROCEDURE pc_gera_devolu_cheque_car (pr_cdcooper  IN crapdev.cdcooper%TYPE    --> C�digo da cooperativa
                                      ,pr_dtmvtolt  IN VARCHAR2                 --> Data do movimento
                                      ,pr_cdbccxlt  IN crapdev.cdbccxlt%TYPE    --> C�digo do banco/caixa do lote
                                      ,pr_cdbcoctl  IN crapdev.cdbccxlt%TYPE    --> C�digo do banco centralizador
                                      ,pr_inchqdev  IN NUMBER                   --> Indicador de Cheque devolvido
                                      ,pr_nrdconta  IN crapdev.nrdconta%TYPE    --> N�mero da conta processada
                                      ,pr_nrdocmto  IN crapdev.nrcheque%TYPE    --> N�mero do cheque
                                      ,pr_nrdctitg  IN crapdev.nrdctitg%TYPE    --> N�mero da conta integra��o
                                      ,pr_vllanmto  IN crapdev.vllanmto%TYPE    --> Valor do lan�amento
                                      ,pr_cdalinea  IN crapdev.cdalinea%TYPE    --> C�digo da Alinea
                                      ,pr_cdhistor  IN crapdev.cdhistor%TYPE    --> C�digo do Hist�rico
                                      ,pr_cdoperad  IN crapdev.cdoperad%TYPE    --> C�digo do Operador
                                      ,pr_cdagechq  IN crapfdc.cdagechq%TYPE    --> C�digo da agencia do cheque
                                      ,pr_nrctachq  IN crapfdc.nrctachq%TYPE    --> N�mero da conta do cheque
                                      ,pr_cdprogra  IN VARCHAR2                 --> C�digo do programa que est� executando
                                      ,pr_nrdrecid  IN crapfdc.progress_recid%TYPE --> N�mero do recid do progress
                                      ,pr_vlchqvlb  IN NUMBER                      --> Valor VLB do cheque
                                      ,pr_cdcritic OUT NUMBER                  --> C�digo da critica gerado pela rotina
                                      ,pr_des_erro OUT VARCHAR2) IS            --> Descri��o do erro ocorrido na rotina
  BEGIN
/* .............................................................................

   Programa: pc_gera_devolu_cheque_prog
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas Quisinski
   Data    : Dezembro/2015                   Ultima atualizacao: 12/02/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para criar registros de devolucao/taxa de cheques.

   Alteracoes: 12/02/2016 - Alterado formato para as datas utilizadas
							(Adriano).
............................................................................. */
    DECLARE
      vr_dtmvtolt DATE;
    BEGIN
      
    vr_dtmvtolt := to_date(pr_dtmvtolt, 'dd/mm/rrrr');
    
    CHEQ0001.pc_gera_devolucao_cheque(pr_cdcooper => pr_cdcooper 
                                     ,pr_dtmvtolt => vr_dtmvtolt
                                     ,pr_cdbccxlt => pr_cdbccxlt
                                     ,pr_cdbcoctl => pr_cdbcoctl
                                     ,pr_inchqdev => pr_inchqdev
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrdocmto => pr_nrdocmto
                                     ,pr_nrdctitg => pr_nrdctitg
                                     ,pr_vllanmto => pr_vllanmto
                                     ,pr_cdalinea => pr_cdalinea
                                     ,pr_cdhistor => pr_cdhistor
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_cdagechq => pr_cdagechq
                                     ,pr_nrctachq => pr_nrctachq
                                     ,pr_cdprogra => pr_cdprogra
                                     ,pr_nrdrecid => pr_nrdrecid
                                     ,pr_vlchqvlb => pr_vlchqvlb
                                     ,pr_cdcritic => pr_cdcritic
                                     ,pr_des_erro => pr_des_erro);

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro na rotina CHEQ0001.pc_gera_devolu_cheque_car. '||sqlerrm;
    END;
  END pc_gera_devolu_cheque_car;
            
	PROCEDURE pc_busca_talonarios_car (pr_cdcooper  IN crapcop.cdcooper%TYPE
		                              ,pr_dtini     IN DATE 
									  ,pr_dtfim     IN DATE 
									  ,pr_cdagenci  IN crapage.cdagenci%TYPE
		                              ,pr_clobxmlc  OUT CLOB                  --XML com informa��es de LOG
                                      ,pr_des_erro  OUT VARCHAR2              --> Status erro
                                      ,pr_dscritic  OUT VARCHAR2) IS          --> Retorno de erro
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_busca_talonarios_car
    --   Sistema : Conta-Corrente - Cooperativa de Credito
    --   Sigla   : CRED
    --   Autor   : Lucas Lunelli
    --   Data    : Julho/2016                      Ultima atualizacao:           
    --
    --   Dados referentes ao programa:
    --   Frequencia: Diario (on-line)
    --   Objetivo  : Procedimento para busca de talon�rios (Rotina 38 Cx Online).
    --
    --   Alteracoes:                                                                     
    -- .............................................................................
    DECLARE
		
		  -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
			
			-- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
			
	  CURSOR cr_requisicao_talonarios (pr_cdcooper  IN NUMBER 
		                              ,pr_dtini     IN DATE
                                      ,pr_dtfim     IN DATE
		 							 ,pr_cdagenci  IN NUMBER) IS
	  SELECT a.cdpac_solicitacao,
			 gene0002.fn_mask_conta(a.nrdconta) nrdconta,
			 a.dtmvtolt,
			 b.nmprimtl,
			 a.nrseq_emissao_chq,
			 DECODE(trim(a.nmreceptor),NULL,'TIT','TER') etg,
			 DECODE(a.tpcartao,0,'RECIBO','CARTAO') Forma,
			 DECODE(a.tpcartao,0,' ',1,'MAGNETI','CECRED') tp_cartao,
			 gene0002.fn_mask_cpf_cnpj(a.nrcpf_receptor,1) cpf_terceiro,
			 a.nmreceptor,
			 to_char(to_date(a.hrtransacao,'SSSSS'),'HH24:MI') hora
	    FROM crapass b,
			 tbcrd_log_operacao a
	   WHERE b.cdcooper = a.cdcooper
		 AND b.nrdconta = a.nrdconta
		 AND a.indoperacao = 5 -- Solicitaco de taloes
		 AND a.nrseq_emissao_chq <> 0 -- Nao � formulario continuo
		 AND a.cdcooper = pr_cdcooper
         AND a.cdpac_solicitacao = decode(pr_cdagenci,0,a.cdpac_solicitacao,pr_cdagenci)
		 AND a.dtmvtolt BETWEEN pr_dtini AND pr_dtfim
	ORDER BY a.dtmvtolt, a.nrdconta, a.nrseq_emissao_chq;
				
	  CURSOR cr_requisicao_continuo (pr_cdcooper  IN NUMBER 
	 						        ,pr_dtini     IN DATE
								    ,pr_dtfim     IN DATE
								    ,pr_cdagenci  IN NUMBER) IS	
      SELECT a.cdpac_solicitacao ,
			 c.dtmvtolt,
	 		 gene0002.fn_mask_conta(a.nrdconta) nrdconta,
			 b.nmprimtl,
			 to_char(c.nrinichq,'FM99999.990') nrinichq,
			 to_char(c.nrfinchq,'FM99999.990') nrfinchq,
			 DECODE(trim(a.nmreceptor),NULL,'TIT','TER') etg,
			 DECODE(a.tpcartao,0,'RECIBO','CARTAO') Forma,
			 DECODE(a.tpcartao,0,' ',1,'Magnetico','CECRED') tp_cartao,
			 gene0002.fn_mask_cpf_cnpj(a.nrcpf_receptor,1) cpf_terceiro,
			 a.nmreceptor,
			 to_char(to_date(a.hrtransacao,'SSSSS'),'HH24:MI') hora
		FROM crapfdc d,
			 crapreq c,
			 crapass b,
			 tbcrd_log_operacao a
	   WHERE b.cdcooper = a.cdcooper
		 AND b.nrdconta = a.nrdconta
		 AND a.indoperacao = 5 -- Solicitaco de taloes
		 AND a.nrseq_emissao_chq = 0 -- Formulario continuo
		 AND a.cdcooper = pr_cdcooper
         AND a.cdpac_solicitacao = decode(pr_cdagenci,0,a.cdpac_solicitacao,pr_cdagenci)
		 AND c.dtmvtolt BETWEEN pr_dtini AND pr_dtfim
		 AND c.cdcooper = a.cdcooper
		 AND c.nrdconta = a.nrdconta
		 AND c.dtmvtolt = a.dtmvtolt
		 AND d.cdcooper = c.cdcooper
		 AND d.nrdconta = c.nrdconta
		 AND d.nrcheque = SUBSTR(c.nrinichq,1,LENGTH(c.nrinichq)-1)
		 AND d.dtretchq = c.dtmvtolt
         AND d.tpforchq = 'FC';			
						 
    BEGIN
		--Inicializa variavel de erro
		vr_dscritic := NULL;
		vr_cdcritic := 0;
			
		-- Criar documento XML
		dbms_lob.createtemporary(pr_clobxmlc, TRUE); 
		dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);       

		-- Insere o cabe�alho do XML 
		gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
							   ,pr_texto_completo => vr_xml_temp 
							   ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
														 																						 
	    FOR rw_requisicao_talonarios IN cr_requisicao_talonarios (pr_cdcooper => pr_cdcooper,
                                                                  pr_dtini    => pr_dtini,
																  pr_dtfim    => pr_dtfim,
																  pr_cdagenci => pr_cdagenci) LOOP
				-- Montar XML com registros de aplica��o
				gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
									   ,pr_texto_completo => vr_xml_temp 
									   ,pr_texto_novo     => '<taloes>'															                    
												  ||  '<cdagenci>' || NVL(TO_CHAR(rw_requisicao_talonarios.cdpac_solicitacao),'0') || '</cdagenci>'
                                                  ||  '<formcont>1</formcont>'
                                                  ||  '<dtmvtore>' || NVL(TO_CHAR(rw_requisicao_talonarios.dtmvtolt),'0')          || '</dtmvtore>'
                                                  ||  '<nrdconta>' || NVL(TO_CHAR(rw_requisicao_talonarios.nrdconta),'0')          || '</nrdconta>'
                                                  ||  '<nmprimtl>' || NVL(TO_CHAR(rw_requisicao_talonarios.nmprimtl),'0')          || '</nmprimtl>'
                                                  ||  '<nrdtalao>' || NVL(TO_CHAR(rw_requisicao_talonarios.nrseq_emissao_chq),'0') || '</nrdtalao>'
												  ||  '<nrini>0</nrini>'
                                                  ||  '<nrfim>0</nrfim>'
                                                  ||  '<tpentreg>' || NVL(TO_CHAR(rw_requisicao_talonarios.etg),'0')               || '</tpentreg>'
                                                  ||  '<tpdforma>' || NVL(TO_CHAR(rw_requisicao_talonarios.Forma),'0')             || '</tpdforma>'
                                                  ||  '<tpcartao>' || NVL(TO_CHAR(rw_requisicao_talonarios.tp_cartao),'0')         || '</tpcartao>'
                                                  ||  '<nrcpfter>' || NVL(TO_CHAR(rw_requisicao_talonarios.cpf_terceiro),'0')      || '</nrcpfter>'
                                                  ||  '<dsnomter>' || NVL(TO_CHAR(rw_requisicao_talonarios.nmreceptor),'0')        || '</dsnomter>'
                                                  ||  '<hrtransa>' || NVL(TO_CHAR(rw_requisicao_talonarios.hora),'0')              || '</hrtransa>'
												  || '</taloes>');  
      END LOOP;
														 
			FOR rw_requisicao_continuo IN cr_requisicao_continuo (pr_cdcooper => pr_cdcooper,
																  pr_dtini    => pr_dtini,
																  pr_dtfim    => pr_dtfim,
																  pr_cdagenci => pr_cdagenci) LOOP        
				-- Montar XML com registros 
				gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
									   ,pr_texto_completo => vr_xml_temp 
									   ,pr_texto_novo     => '<taloes>'															                    
										  		  ||  '<cdagenci>' || NVL(TO_CHAR(rw_requisicao_continuo.cdpac_solicitacao),'0')    || '</cdagenci>'
                                                  ||  '<formcont>2</formcont>'
                                                  ||  '<dtmvtore>' || NVL(TO_CHAR(rw_requisicao_continuo.dtmvtolt,'DD/MM/RRRR'),'') || '</dtmvtore>'
                                                  ||  '<nrdconta>' || NVL(TO_CHAR(rw_requisicao_continuo.nrdconta),'0')             || '</nrdconta>'
                                                  ||  '<nmprimtl>' || NVL(TO_CHAR(rw_requisicao_continuo.nmprimtl),'')              || '</nmprimtl>'
                                                  ||  '<nrdtalao>0</nrdtalao>'
                                                  ||  '<nrini>'    || NVL(TO_CHAR(rw_requisicao_continuo.nrinichq),'0')             || '</nrini>'
                                                  ||  '<nrfim>'    || NVL(TO_CHAR(rw_requisicao_continuo.nrfinchq),'0')             || '</nrfim>'
                                                  ||  '<tpentreg>' || NVL(TO_CHAR(rw_requisicao_continuo.etg),'0')                  || '</tpentreg>'
                                                  ||  '<tpdforma>' || NVL(TO_CHAR(rw_requisicao_continuo.Forma),'0')                || '</tpdforma>'
                                                  ||  '<tpcartao>' || NVL(TO_CHAR(rw_requisicao_continuo.tp_cartao),'0')            || '</tpcartao>'
                                                  ||  '<nrcpfter>' || NVL(TO_CHAR(rw_requisicao_continuo.cpf_terceiro),'0')         || '</nrcpfter>'
                                                  ||  '<dsnomter>' || NVL(TO_CHAR(rw_requisicao_continuo.nmreceptor),'')            || '</dsnomter>'
                                                  ||  '<hrtransa>' || NVL(TO_CHAR(rw_requisicao_continuo.hora),'0')                 || '</hrtransa>'
												  || '</taloes>');  
      END LOOP;
																	 
	  -- Encerrar a tag raiz 
	  gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
							 ,pr_texto_completo => vr_xml_temp 
							 ,pr_texto_novo     => '</root>' 
							 ,pr_fecha_xml      => TRUE);	
										 
	  pr_des_erro := 'OK';
			
    EXCEPTION
		WHEN vr_exc_saida THEN
			pr_des_erro := 'NOK';
			pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));
      WHEN OTHERS THEN
			pr_dscritic := 'Problemas ao buscar Talonarios. Erro na CHEQ0001.pc_busca_talonarios_car: '||sqlerrm;
    END;
  END pc_busca_talonarios_car;
            
  PROCEDURE pc_download_ftp(pr_serv_ftp   IN VARCHAR2     --> Servidor FTP
                           ,pr_user_ftp   IN VARCHAR2     --> Usuario
                           ,pr_pass_ftp   IN VARCHAR2     --> Senha
                           ,pr_nmarquiv   IN VARCHAR2     --> Nome do arquivo a ser buscado
                           ,pr_dir_local  IN VARCHAR2     --> Diretorio local
                           ,pr_dir_remoto IN VARCHAR2     --> diretorio remoto
                           ,pr_script_ftp IN VARCHAR2     --> Script FTP
                           ,pr_dscritic  OUT VARCHAR2) IS --> Descricao do erro
  BEGIN
  /* .............................................................................

  Programa: pc_download_ftp
  Sistema : Conciliacoes diarias e mensais.
  Sigla   : CRED
  Autor   : Lucas Afonso Lombardi Moreira
  Data    : Setembro/15.                    Ultima atualizacao: --/--/----

  Dados referentes ao programa:

  Frequencia: Sempre que for chamado

  Objetivo  : Faz download de arquivo em um servidor FTP.

  Observacao: -----

  Alteracoes:
  ..............................................................................*/
    DECLARE
      vr_comand_ftp VARCHAR2(1000);
      vr_typ_saida  VARCHAR2(3);
      vr_exc_saida  EXCEPTION;
    BEGIN

      -- Preparar o comando de conex�o e envio ao FTP
      vr_comand_ftp := pr_script_ftp
                    || ' -recebe'
                    || ' -srv '          || pr_serv_ftp
                    || ' -usr '          || pr_user_ftp
                    || ' -pass '         || pr_pass_ftp
                    || ' -arq '          || CHR(39) || pr_nmarquiv   || CHR(39)
                    || ' -dir_local '    || CHR(39) || pr_dir_local  || CHR(39)
                    || ' -dir_remoto '   || CHR(39) || pr_dir_remoto || CHR(39)
                    || ' -log /usr/coop/cecred/log/ftp_transabbc.log';

      -- Chama procedure de envio e recebimento via ftp
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comand_ftp
                           ,pr_flg_aguard  => 'S'
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => pr_dscritic);

      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        pr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comand_ftp ||
                      ' - Erro: ' || pr_dscritic;
        RAISE vr_exc_saida;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro Geral: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_download_ftp;
  
  PROCEDURE pc_busca_ccf_transabbc IS
  BEGIN
    /* .............................................................................

     Programa: pc_busca_ccf_transabbc
     Sistema : Conciliacoes diarias e mensais.
     Sigla   : CRED
     Autor   : Lucas Afonso Lombardi Moreira
     Data    : Setembro/15.                    Ultima atualizacao: 22/06/2015

     Dados referentes ao programa:

     Frequencia: Diariamente.

     Objetivo  : Conectar-se ao FTP da Transabbc e efetuar download de tr�s
                 arquivos diariamente.

     Observacao: -----

     Alteracoes:
     ..............................................................................*/

    DECLARE

      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(1000);
      vr_comando   VARCHAR2(4000);
      vr_typ_saida VARCHAR2(10);
      vr_des_erro  VARCHAR2(2000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      vr_serv_ftp    VARCHAR2(100);
      vr_user_ftp    VARCHAR2(100);
      vr_pass_ftp    VARCHAR2(100);
      
      vr_nmarquiv      VARCHAR2(100);
      vr_dir_local     VARCHAR2(100);
      vr_dir_remoto    VARCHAR2(100);

      vr_script_ftp    VARCHAR2(600);

      -- Cursor gen�rico de calend�rio
      rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;

      
    BEGIN
      -- Buscar a data do movimento
      OPEN btch0001.cr_crapdat(3);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Verificar se existe informa��o, e gerar erro caso n�o exista
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE btch0001.cr_crapdat;

        -- Gerar exce��o
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      END IF;
      CLOSE btch0001.cr_crapdat;

      -- Busca nome do servidor
      vr_serv_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'TRAN_BBC_SERV_FTP');
      -- Busca nome de usuario
      vr_user_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'TRAN_BBC_USER_FTP');
      -- Busca senha do usuario
      vr_pass_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'TRAN_BBC_PASS_FTP');

      vr_dir_remoto := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'TRAN_BBC_DIR_CCF');

      vr_dir_local := GENE0001.fn_diretorio(pr_tpdireto => 'M' --> /micros
                                            ,pr_cdcooper => 3   --> Cooperativa
                                            ,pr_nmsubdir => 'abbc');

      /* Remove os arquivos CCF dos dias anteriores */
      vr_comando:= 'rm '||vr_dir_local ||'/CCF*';

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_des_erro);
     
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic := 'Nao foi possivel executar comando unix. '||vr_comando||' - '||vr_des_erro;
        RAISE vr_exc_saida;
      END IF;

      vr_script_ftp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_SCRIPT_FTP');

      -- Forma o nome do arquivo CCG627XX.YYY
      --XX  -> Dia do movimento
      --YYY -> Sequencial da remessa, sera sempre 001
      --Se INPROCES = 1 ja acabou o batch, posso utilizar dtmvtoan, senao devo utilizar dtmvtolt
      IF rw_crapdat.inproces = 1 THEN
        vr_nmarquiv := 'CCF627' || to_char(rw_crapdat.dtmvtoan, 'DD') || '.001';
      ELSE
        vr_nmarquiv := 'CCF627' || to_char(rw_crapdat.dtmvtolt, 'DD') || '.001';
      END IF;

      pc_download_ftp(pr_serv_ftp   => vr_serv_ftp
                     ,pr_user_ftp   => vr_user_ftp
                     ,pr_pass_ftp   => vr_pass_ftp
                     ,pr_nmarquiv   => vr_nmarquiv
                     ,pr_dir_local  => vr_dir_local
                     ,pr_dir_remoto => vr_dir_remoto
                     ,pr_script_ftp => vr_script_ftp
                     ,pr_dscritic   => vr_dscritic);

      -- Se ocorrer algum erro
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
      
      vr_nmarquiv := 'CCF.ZIP';

      -- Executa o download do arquivo CCF.ZIP
      pc_download_ftp(pr_serv_ftp   => vr_serv_ftp
                     ,pr_user_ftp   => vr_user_ftp
                     ,pr_pass_ftp   => vr_pass_ftp
                     ,pr_nmarquiv   => vr_nmarquiv
                     ,pr_dir_local  => vr_dir_local
                     ,pr_dir_remoto => vr_dir_remoto
                     ,pr_script_ftp => vr_script_ftp
                     ,pr_dscritic   => vr_dscritic);

      -- Se ocorrer algum erro
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
      
      /*  Executar Extracao do arquivo zip */
      vr_comando:= 'unzip '||vr_dir_local||'/'||vr_nmarquiv ||' -d ' || vr_dir_local;

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_des_erro);

      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic := 'Nao foi possivel executar comando unix. '||vr_comando||' - '||vr_des_erro;
        RAISE vr_exc_saida;
      END IF;
      
      vr_comando:= 'rm '||vr_dir_local ||'/'||vr_nmarquiv||' 1> /dev/null';

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_des_erro);

      -- Gravar os comandos no banco
      COMMIT;
    EXCEPTION
      WHEN vr_exc_saida THEN

        btch0001.pc_gera_log_batch(pr_cdcooper     => 3 --> Sempre na Cecred
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'HH24:MI:SS') || 
                                                      ' - CONV0001.PC_BUSCA_CCF_TRANSABBC Erro ao efetuar download dos arquivos: ' || vr_dscritic
                                  ,pr_dstiplog   => 'E'
                                  ,pr_cdprograma => 'CONV0001');
        ROLLBACK;
      WHEN OTHERS THEN

        cecred.pc_internal_exception;
      
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3 --> Sempre na Cecred
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'HH24:MI:SS') || 
                                                      ' - CONV0001.PC_BUSCA_CCF_TRANSABBC Erro ao efetuar download dos arquivos: ' || SQLERRM
                                  ,pr_dstiplog   => 'E'
                                  ,pr_cdprograma => 'CONV0001');
        ROLLBACK;
    END;
  END pc_busca_ccf_transabbc;
END CHEQ0001;
/
