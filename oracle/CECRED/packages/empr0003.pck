CREATE OR REPLACE PACKAGE CECRED.EMPR0003 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0003
  --  Sistema  : Impressão de contratos de emprestimos
  --  Sigla    : EMPR
  --  Autor    : Andrino Carlos de Souza Junior (RKAM)
  --  Data     : agosto/2014.                   Ultima atualizacao: 20/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas para impressão de contratos de emprestimos
  --
  -- Alteracoes: 05/11/2014 - Incluir temp-table com os intevenientes garantidores (Andrino-RKAM)
  --
  --             05/01/2015 - (Chamado 229247) - Novo relatorio incluido nos contratos de emprestimos (Tiago Castro - RKAM).
  --
  --             03/08/2015 - Incluir verificação para que se o documento for de portabilidade então é usado ou o relatório 
  --                          'crrl100_18_portab' ou 'crrl100_05_portab'.(Lombardi)
  --
  --             26/11/2015 - Adicionado nova validacao de origem "MICROCREDITO PNMPO BNDES CECRED" na procedure 
  --                          pc_imprime_contrato_xml conforme solicitado no chamado 360165 (Kelvin)  
  --
  --             20/06/2016 - Correcao para o uso correto do indice da CRAPTAB na function fn_verifica_interv 
  --                          desta package.(Carlos Rafael Tanholi).  
  --
  --             24/08/2016 - (Projeto 343)
  --                        - Adicionada varíavel para verificação de  versão para 
  --                          impressão de novos parágros nos contratos de forma condicional; 
  --                          (Ricardo Linhares)    
  --
  --             01/09/2017 - Imprimir conta quando o avalista for cooperado
  --                          Heitor (Mouts) - Chamado 735958 
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Verifica da TAB016 se o interveniente esta habilitado
  FUNCTION fn_verifica_interv(pr_cdagenci IN crapass.cdagenci%TYPE
                             ,pr_cdcooper IN crapcop.cdcooper%TYPE
                             ) RETURN VARCHAR2;

  /* Verifica se o CPF/CNPJ informado como sendo proprietario do bem, faz
        parte do contrato sendo CONTRATANTE OU INTERVENIENTE ANUENTE */

  PROCEDURE pc_dados_proprietario (pr_nrcpfbem   IN crapass.nrcpfcgc%TYPE
                                  ,pr_cdcooper   IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta   IN crapass.nrdconta%TYPE
                                  ,pr_nrctremp   IN crawepr.nrctremp%TYPE
                                  ,pr_nmdavali   OUT VARCHAR2
                                  ,pr_dados_pess OUT VARCHAR2
                                  ,pr_dsendere   OUT VARCHAR2
                                  ,pr_nrnmconjug OUT VARCHAR2
                                  );

  PROCEDURE pc_busca_avalista (pr_cdcooper IN crapcop.cdcooper%TYPE
                              ,pr_nrdconta IN crapepr.nrdconta%TYPE
                              ,pr_nrctremp IN crapepr.nrctremp%TYPE
                              ,pr_nrseqava IN INTEGER
                              ,pr_nmdavali OUT crapavt.nmdavali%TYPE
                              ,pr_nrcpfcgc OUT VARCHAR2
                              ,pr_dsendres OUT VARCHAR2
                              ,pr_nrfonres OUT crapavt.nrfonres%TYPE
                              ,pr_nmconjug OUT crapavt.nmconjug%TYPE
                              ,pr_nrcpfcjg OUT VARCHAR2
                              );

  FUNCTION fn_verifica_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_dslcremp IN craplcr.dslcremp%TYPE)
                           RETURN VARCHAR2;

  PROCEDURE pc_busca_bens (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE
                          ,pr_nrctremp IN crawepr.nrctremp%TYPE
                          ,pr_cdagenci IN crapass.cdagenci%TYPE
                          );

  /* Rotina para impressao de contratos de emprestimo */
  PROCEDURE pc_imprime_contrato_xml(pr_cdcooper IN crapcop.cdcooper%TYPE              --> Codigo da Cooperativa
                                   ,pr_nrdconta IN crapepr.nrdconta%TYPE              --> Numero da conta do emprestimo
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE              --> Numero do contrato de emprestimo
                                   ,pr_inimpctr IN INTEGER DEFAULT 0                  --> Impressao de contratos nao negociaveis
                                   ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2                          --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);                        --> Erros do processo

  /* Rotina para acionar a geração de PRoposta PDF no Progress */
  PROCEDURE pc_gera_proposta_pdf(pr_cdcooper in crawepr.cdcooper%TYPE --> Código da cooperativa
                                ,pr_cdagenci in crawepr.nrdconta%TYPE --> Código da Agencia
                                ,pr_nrdcaixa in INTEGER               --> Numero do Caixa                                        
                                ,pr_nmdatela in VARCHAR2              --> Tela
                                ,pr_cdoperad in crapope.cdoperad%TYPE --> Código do Operador
                                ,pr_idorigem in PLS_INTEGER           --> Origem 
                                ,pr_nrdconta in crawepr.nrdconta%TYPE --> Numero da conta
                                ,pr_dtmvtolt in date                  --> Data atual
                                ,pr_dtmvtopr in date                  --> Data próxima
                                ,pr_nrctremp in crawepr.nrctremp%TYPE --> nro do contrato
                                ,pr_dsiduser in varchar2              --> ID da sessão ou id randomico
                                ,pr_nmarqpdf IN OUT varchar2 );          --> Caminho/Arquivo gerado

  /* Rotina para impressao do relatorio  crrl_42 */
  PROCEDURE pc_gera_perfil_empr(pr_cdcooper IN crawepr.cdcooper%TYPE  --> Código da cooperativa
                                ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                ,pr_nrctremp IN crawepr.nrctremp%TYPE --> nro do contrato
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT CLOB              --> Arquivo de retorno do XML
                                );

  /* Imprime o demonstrativo do contrato de emprestimo pre-aprovado */
  PROCEDURE pc_gera_demonst_pre_aprovado(pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da Cooperativa
                                        ,pr_cdagenci IN crawepr.nrdconta%TYPE --> Código da Agencia
                                        ,pr_nrdcaixa IN INTEGER               --> Numero do Caixa                                        
                                        ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do Operador
                                        ,pr_cdprogra IN crapprg.cdprogra%TYPE --> Código do Programa
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do Movimento
                                        ,pr_nmarqimp IN VARCHAR2              --> Caminho do arquivo 
                                        ,pr_nmarqpdf OUT VARCHAR2             --> Nome Arquivo PDF
                                        ,pr_des_reto OUT VARCHAR2);           --> Descrição do retorno

    /******************************************************************************/
	/**   Procedure para imprimir declaração de isenção do IOF                   **/
	/******************************************************************************/
	PROCEDURE pc_impr_dec_rec_ise_iof_xml(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da Cooperativa
										 ,pr_nrdconta IN crapepr.nrdconta%TYPE  --> Numero da conta
										 ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE  --> Numero do CPF
                                         ,pr_nrctrato IN crapepr.nrctremp%TYPE  --> Numero do contrato
										 ,pr_xmllog   IN VARCHAR2 			    --> XML com informações de LOG
										 ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da critica
										 ,pr_dscritic OUT VARCHAR2 				--> Descricao da critica
										 ,pr_retxml   IN OUT NOCOPY XMLType 	--> Arquivo de retorno do XML
										 ,pr_nmdcampo OUT VARCHAR2 				--> Nome do campo com erro
										 ,pr_des_erro OUT VARCHAR2);            --> Descrição do erro 

  /******************************************************************************/
  /**            Procedure para buscar operações dos avalistas.                **/
  /******************************************************************************/
  PROCEDURE pc_busca_operacoes(pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo da cooperativa
                              ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Numero da conta
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      --> Data de movimento
                              ,pr_vldscchq IN OUT crapcdb.vlcheque%TYPE  --> Valor de cheque
                              ,pr_vlutlchq IN OUT crapcdb.vlcheque%TYPE  --> Valor do ultimo cheque                              
                              ,pr_vldctitu IN OUT craptdb.vltitulo%TYPE  --> Valor de titulo de descont0
                              ,pr_vlutitit IN OUT craptdb.vltitulo%TYPE  --> Valor do ultimo titulo de desconto                                                                 
                              ------ OUT ------                                      
                              ,pr_tab_co_responsavel IN OUT empr0001.typ_tab_dados_epr --> Retorna dados
                              ,pr_dscritic     OUT VARCHAR2          --> Descrição da critica
                              ,pr_cdcritic     OUT INTEGER);         --> Codigo da critica

  /******************************************************************************/
  /**     Procedure para buscar operações dos avalistas - Chamada Progress     **/
  /******************************************************************************/
  PROCEDURE pc_busca_operacoes_prog (pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo da cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Numero da conta
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      --> Data de movimento
                                    ,pr_vldscchq IN OUT crapcdb.vlcheque%TYPE  --> Valor de cheque
                                    ,pr_vlutlchq IN OUT crapcdb.vlcheque%TYPE  --> Valor do ultimo cheque                              
                                    ,pr_vldctitu IN OUT craptdb.vltitulo%TYPE  --> Valor de titulo de descont0
                                    ,pr_vlutitit IN OUT craptdb.vltitulo%TYPE  --> Valor do ultimo titulo de desconto                                                                 
                                    ------ OUT ------                                      
                                    ,pr_xml_co_responsavel IN OUT CLOB     --> Retorna dados
                                    ,pr_dscritic     OUT VARCHAR2          --> Descrição da critica
                                    ,pr_cdcritic     OUT INTEGER);         --> Codigo da critica
                                    
  /******************************************************************************/
  /**            Procedure para retornar dados dos co-reponsaveis              **/
  /******************************************************************************/
  PROCEDURE pc_gera_co_responsavel
                              (pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo da cooperativa
                              ,pr_cdagenci IN crapage.cdagenci%TYPE      --> Codigo de agencia 
                              ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE      --> Numero do caixa
                              ,pr_cdoperad IN crapope.cdoperad%TYPE      --> Codigo do operador
                              ,pr_nmdatela IN craptel.nmdatela%TYPE      --> Nome da tela
                              ,pr_idorigem IN INTEGER                    --> Identificado de oriem
                              ,pr_cdprogra IN crapprg.cdprogra%TYPE      --> Codigo do programa 
                              ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Numero da conta
                              ,pr_idseqttl IN crapttl.idseqttl%TYPE      --> Sequencial do titular
                              ,pr_dtcalcul IN DATE                       --> Data do calculo                                                           
                              ,pr_flgerlog IN VARCHAR2                   --> identificador se deve gerar log S-Sim e N-Nao
                              ,pr_vldscchq IN OUT crapcdb.vlcheque%TYPE  --> Valor de cheque
                              ,pr_vlutlchq IN OUT crapcdb.vlcheque%TYPE  --> Valor do ultimo cheque                              
                              ,pr_vldctitu IN OUT craptdb.vltitulo%TYPE  --> Valor de titulo de descont0
                              ,pr_vlutitit IN OUT craptdb.vltitulo%TYPE  --> Valor do ultimo titulo de desconto                                                                 
                              ------ OUT ------                                      
                              ,pr_tab_co_responsavel IN OUT empr0001.typ_tab_dados_epr --> Retorna dados
                              ,pr_dscritic     OUT VARCHAR2          --> Descrição da critica
                              ,pr_cdcritic     OUT INTEGER);         --> Codigo da critica                                    
                              
  /******************************************************************************/
  /**   Procedure para retornar dados dos co-reponsaveis - Chamada progress    **/
  /******************************************************************************/
  PROCEDURE pc_gera_co_responsavel_prog
                              (pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo da cooperativa
                              ,pr_cdagenci IN crapage.cdagenci%TYPE      --> Codigo de agencia 
                              ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE      --> Numero do caixa
                              ,pr_cdoperad IN crapope.cdoperad%TYPE      --> Codigo do operador
                              ,pr_nmdatela IN craptel.nmdatela%TYPE      --> Nome da tela
                              ,pr_idorigem IN INTEGER                    --> Identificado de oriem
                              ,pr_cdprogra IN crapprg.cdprogra%TYPE      --> Codigo do programa 
                              ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Numero da conta
                              ,pr_idseqttl IN crapttl.idseqttl%TYPE      --> Sequencial do titular
                              ,pr_dtcalcul IN DATE                       --> Data do calculo                                                           
                              ,pr_flgerlog IN VARCHAR2                   --> identificador se deve gerar log S-Sim e N-Nao
                              ,pr_vldscchq IN OUT crapcdb.vlcheque%TYPE  --> Valor de cheque
                              ,pr_vlutlchq IN OUT crapcdb.vlcheque%TYPE  --> Valor do ultimo cheque                              
                              ,pr_vldctitu IN OUT craptdb.vltitulo%TYPE  --> Valor de titulo de descont0
                              ,pr_vlutitit IN OUT craptdb.vltitulo%TYPE  --> Valor do ultimo titulo de desconto                                                                 
                              ------ OUT ------                                      
                              ,pr_xml_co_responsavel OUT CLOB     --> Retorna dados
                              ,pr_dscritic     OUT VARCHAR2          --> Descrição da critica
                              ,pr_cdcritic     OUT INTEGER);         --> Codigo da critica                              
  /******************************************************************************/
  /**   Procedure para retornar relatório para WEb de contrato empréstimo com seguro prestamista  **/
  /******************************************************************************/                               
 PROCEDURE pc_imprime_contrato_prest(pr_cdcooper IN crapcop.cdcooper%TYPE              --> Codigo da Cooperativa
                                     ,pr_nrdconta IN crapepr.nrdconta%TYPE              --> Numero da conta do emprestimo
                                     ,pr_nrctremp IN crapepr.nrctremp%TYPE              --> Numero do contrato de emprestimo
                                     ,pr_inimpctr IN INTEGER DEFAULT 0                  --> Impressao de contratos nao negociaveis
                                     ,pr_nrctrseg IN crawseg.nrctrseg%TYPE  --> Proposta
                                     ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                          --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);                                               
END EMPR0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0003 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0003
  --  Sistema  : Impressão de contratos de emprestimos
  --  Sigla    : EMPR
  --  Autor    : Andrino Carlos de Souza Junior (RKAM)
  --  Data     : agosto/2014.                   Ultima atualizacao: 26/07/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas para impressão de contratos de emprestimos
  --
  -- Alteracoes: 05/11/2014 - Incluir temp-table com os intevenientes garantidores (Andrino-RKAM)
  --
  --             05/01/2015 - (Chamado 229247) - Novo relatorio incluido nos contratos de emprestimos (Tiago Castro - RKAM).
  --
  --             03/08/2015 - Incluir verificação para que se o documento for de portabilidade então é usado ou o relatório 
  --                          'crrl100_18_portab' ou 'crrl100_05_portab'.(Lombardi)
  --
  --             26/11/2015 - Adicionado nova validacao de origem "MICROCREDITO PNMPO BNDES CECRED" na procedure 
  --                          pc_imprime_contrato_xml conforme solicitado no chamado 360165 (Kelvin)                
  --
  --             20/01/2016 - Adicionei o parametro pr_idorigem na chamada da procedure pc_imprime_emprestimos_cet
  --                          dentro da procedure pc_imprime_contrato_xml.
  --                          (Carlos Rafael Tanholi - Projeto 261 Pré-aprovado fase 2)                          
  --
  --             20/06/2016 - Correcao para o uso correto do indice da CRAPTAB na function fn_verifica_interv 
  --                          desta package.(Carlos Rafael Tanholi).
  --
  --             25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
  --			              crapass, crapttl, crapjur 
  --			 			  (Adriano - P339).
  --
  --             26/06/2017 - Na procedure pc_imprime_contrato_xml foi retirada a chamada pc_XML_para_arquivo
  --                          pois era desnecessaria (Tiago/Rodrigo).
  --
  --             12/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
  --		                  crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
  --						 (Adriano - P339).
  --
  --              12/06/2018 - Projeto 413 - Mudanca de Marcas (Paulo Martins-Mout´s)
  --
  --              23/07/2018 - Alterado para verificar o campo nrplnovo, ufplnovo, nrrenovo na crapbpr, 
  --                           caso tenha valor nestes campos, deve ser pego este campo, caso contrario
  --                           pegar dos campos nrdplaca, ufdplaca, nrrenava, respectivamente.
  --                           (André Mout's) - (INC0019097).
  --
  --			  26/07/2018 - Ajuste no xml co-responsabilidade (Andrey Formigari - Mouts)
  --			  15/07/2019 - Ajuste apresentação Maquinas e Equipamentos (Paulo Martins - Mouts)
  ---------------------------------------------------------------------------------------------------------------


   ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      --guarda informacoes dos bens para xml
      TYPE typ_reg_bens IS
        RECORD ( nrcpfbem  crapbpr.nrcpfbem%TYPE
                ,dsbem     crapbpr.dsbemfin%TYPE
                ,dschassi  VARCHAR2(200)
                ,nrdplaca  VARCHAR2(15)
                ,nrrenava  VARCHAR2(40)
                ,dsanomod  VARCHAR2(40)
                ,dscorbem  VARCHAR2(150)
                ,avaliacao crapbpr.vlmerbem%TYPE
                ,proprietario   VARCHAR2(2000)
                ,dados_pessoais VARCHAR2(2000)
                ,endereco       VARCHAR2(300)
                ,conjuge        VARCHAR2(300)
                ,dscatbem  crapbpr.dscatbem%TYPE
                );
      TYPE typ_tab_bens IS
        TABLE OF typ_reg_bens
          INDEX BY VARCHAR2(163); --> 27 CPF do bem + 35 Chassi + 101 Bem
      vr_tab_bens typ_tab_bens;

      --guarda informacoes dos intervenientes garantidores
      TYPE typ_reg_interv IS
        RECORD ( inprimei VARCHAR2(01),
                 insegund VARCHAR2(02)
                );
      TYPE typ_tab_interv IS
        TABLE OF typ_reg_interv
          INDEX BY PLS_INTEGER;
      vr_tab_interv typ_tab_interv;

      vr_des_chave  VARCHAR2(163);
      vr_des_chave_interv PLS_INTEGER := 0;
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_flginterv  VARCHAR2(1) := '';

  FUNCTION fn_verifica_interv(pr_cdagenci IN crapass.cdagenci%TYPE
                             ,pr_cdcooper IN crapcop.cdcooper%TYPE
                             ) RETURN VARCHAR2 IS

  /* .............................................................................

       Programa: fn_verifica_interv
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago Castro (RKAM)
       Data    : Agosto/2014.                         Ultima atualizacao: 26/01/2015

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Verifica da TAB016 se o interveniente esta habilitado

       Alteracoes: 26/01/2015 - Alterado o formato do campo nrctremp para 8
                                caracters (Kelvin - 233714)

    ............................................................................. */

  -- tabela generica para busca de interveniente habilitado
  CURSOR cr_craptab IS
    SELECT  decode(substr(craptab.dstextab,56,03),'yes', 'TRUE', 'FALSE') habilitado
    FROM    craptab
    WHERE   craptab.cdcooper = pr_cdcooper
    AND     UPPER(craptab.nmsistem) = 'CRED'
    AND     UPPER(craptab.tptabela) = 'USUARI'
    AND     craptab.cdempres = 11
    AND     UPPER(craptab.cdacesso) = 'PROPOSTEPR'
    AND     craptab.tpregist IN (pr_cdagenci,0);

    vr_flg_inter VARCHAR2(5);-- flag de interveniente habilitado

  BEGIN
    OPEN cr_craptab; -- busca informacoes se interveniente esta habilitado
    FETCH cr_craptab INTO vr_flg_inter;
    CLOSE cr_craptab;
    RETURN nvl(vr_flg_inter, 'FALSE'); -- retorna true ou false

  END fn_verifica_interv;

  PROCEDURE pc_dados_proprietario (pr_nrcpfbem   IN crapass.nrcpfcgc%TYPE
                                  ,pr_cdcooper   IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta   IN crapass.nrdconta%TYPE
                                  ,pr_nrctremp   IN crawepr.nrctremp%TYPE
                                  ,pr_nmdavali   OUT VARCHAR2
                                  ,pr_dados_pess OUT VARCHAR2
                                  ,pr_dsendere   OUT VARCHAR2
                                  ,pr_nrnmconjug OUT VARCHAR2
                                  ) IS

  /* .............................................................................

       Programa: pc_dados_proprietario
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago Castro (RKAM)
       Data    : Agosto/2014.                         Ultima atualizacao: 12/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Verifica se o CPF/CNPJ informado como sendo proprietario do bem, faz
                   parte do contrato sendo CONTRATANTE OU INTERVENIENTE ANUENTE,
                   retorna os dados do interveniente e conjuge

       Alteracoes: 08/05/2017 - Case When para buscar CPF e CNPJ atraves do tamanho da
								string (Andrey - Mouts).
                   12/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                    crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
						    	(Adriano - P339).

                   15/01/2018 - Ajustes para exibir inf. do proprietario conforme solicitação do juridico.
                                PRJ298-FGTS(Odirlei-AMcom)

    ............................................................................. */



    -- busca nome do associado
  CURSOR cr_crapass(pr_cursor INTEGER) IS
    SELECT  crapass.nmprimtl nmprimtl,
            'Dados pessoais: '||decode(crapass.inpessoa,1,'CPF','CNPJ')||
            ' n.º '||gene0002.fn_mask_cpf_cnpj(crapass.nrcpfcgc, crapass.inpessoa)||
            decode(crapass.inpessoa,1,' RG n.º '||SUBSTR(TRIM(crapass.nrdocptl),1,15)||decode(trim(gnetcvl.rsestcvl), NULL, NULL ,', com o estado civil ')||
                                      gnetcvl.rsestcvl,'') dados_pessoais,
            'Endereço: '||crapenc.dsendere||', nº '||crapenc.nrendere||', bairro '||crapenc.nmbairro ||', da cidade de '||
            crapenc.nmcidade||'/'||crapenc.cdufende||', CEP '||gene0002.fn_mask_cep(crapenc.nrcepend) dsendere,
            DECODE(nvl(crapass_2.nmprimtl,TRIM(crapcje.nmconjug)),NULL,NULL,'Cônjuge: '||nvl(crapass_2.nmprimtl,crapcje.nmconjug)) ||
            DECODE(nvl(crapass_2.nrcpfcgc,NVL(crapcje.nrcpfcjg,0)),0,'',' CPF n.º '||gene0002.fn_mask_cpf_cnpj(nvl(crapass_2.nrcpfcgc,crapcje.nrcpfcjg),1))||
            DECODE(nvl(crapass_2.tpdocptl,crapcje.tpdoccje),'CI',' RG n.º '|| SUBSTR(TRIM(nvl(crapass_2.nrdocptl,crapcje.nrdoccje)),1,15),'')  nrnmconjug
    FROM  crapass crapass_2, -- Dados do conjuge
          crapcje,
          gnetcvl,
          crapttl,
          crapenc,
          crapass
    WHERE crapass.cdcooper = pr_cdcooper
    AND crapass.nrdconta = pr_nrdconta
    AND crapass.nrcpfcgc = pr_nrcpfbem
    AND crapenc.cdcooper (+) = crapass.cdcooper
    AND crapenc.nrdconta (+) = crapass.nrdconta
    AND crapenc.idseqttl (+) = 1
    AND crapenc.tpendass (+) = decode(crapass.inpessoa,1,10,9)
    AND crapttl.cdcooper (+) = crapass.cdcooper
    AND crapttl.nrdconta (+) = crapass.nrdconta
    AND crapttl.idseqttl (+) = 1
    AND gnetcvl.cdestcvl (+) = crapttl.cdestcvl
    AND crapcje.cdcooper (+) = crapttl.cdcooper
    AND crapcje.nrdconta (+) = crapttl.nrdconta
    AND crapcje.idseqttl (+) = crapttl.idseqttl
    AND crapass_2.cdcooper (+) = nvl(crapcje.cdcooper,0)
    AND crapass_2.nrdconta (+) = crapcje.nrctacje
    AND pr_cursor            = 1
    UNION
    SELECT  crapass.nmprimtl nmprimtl,
            'Dados pessoais: '||decode(crapass.inpessoa,1,'CPF','CNPJ')||
            ' n.º '||gene0002.fn_mask_cpf_cnpj(crapass.nrcpfcgc, crapass.inpessoa)||
            decode(crapass.inpessoa,1,' RG n.º '||SUBSTR(TRIM(crapass.nrdocptl),1,15)||decode(trim(gnetcvl.rsestcvl), NULL, NULL ,', com o estado civil ')||
                                      gnetcvl.rsestcvl,'') dados_pessoais,
            'Endereço: '||crapenc.dsendere||', nº '||crapenc.nrendere||', bairro '||crapenc.nmbairro ||', da cidade de '||
            crapenc.nmcidade||'/'||crapenc.cdufende||', CEP '||gene0002.fn_mask_cep(crapenc.nrcepend) dsendere,
            DECODE(nvl(crapass_2.nmprimtl,TRIM(crapcje.nmconjug)),NULL,NULL,'Cônjuge: '||nvl(crapass_2.nmprimtl,crapcje.nmconjug)) ||
            DECODE(nvl(crapass_2.nrcpfcgc,NVL(crapcje.nrcpfcjg,0)),0,'',' CPF n.º '||gene0002.fn_mask_cpf_cnpj(nvl(crapass_2.nrcpfcgc,crapcje.nrcpfcjg),1))||
            DECODE(nvl(crapass_2.tpdocptl,crapcje.tpdoccje),'CI',' RG n.º '|| SUBSTR(TRIM(nvl(crapass_2.nrdocptl,crapcje.nrdoccje)),1,15),'')  nrnmconjug
    FROM  crapass crapass_2, -- Dados do conjuge
          crapcje,
          gnetcvl,
          crapttl,
          crapenc,
          crapass
    WHERE crapass.cdcooper = pr_cdcooper
    AND crapass.nrdconta = pr_nrdconta
    AND crapenc.cdcooper (+) = crapass.cdcooper
    AND crapenc.nrdconta (+) = crapass.nrdconta
    AND crapenc.idseqttl (+) = 1
    AND crapenc.tpendass (+) = decode(crapass.inpessoa,1,10,9)
    AND crapttl.cdcooper (+) = crapass.cdcooper
    AND crapttl.nrdconta (+) = crapass.nrdconta
    AND crapttl.idseqttl (+) = 1
    AND gnetcvl.cdestcvl (+) = crapttl.cdestcvl
    AND crapcje.cdcooper (+) = crapttl.cdcooper
    AND crapcje.nrdconta (+) = crapttl.nrdconta
    AND crapcje.idseqttl (+) = crapttl.idseqttl
    AND crapass_2.cdcooper (+) = nvl(crapcje.cdcooper,0)
    AND crapass_2.nrdconta (+) = crapcje.nrctacje
    AND pr_cursor            = 2;
  rw_crapass cr_crapass%ROWTYPE;

    -- busca nome do avalista
    CURSOR cr_crapavt IS
       SELECT crapavt.nmdavali nmdavali,
              (CASE 
                 WHEN crapavt.inpessoa = 0 AND length(crapavt.nrcpfcgc) <= 11 THEN 1
                 WHEN crapavt.inpessoa = 0 AND length(crapavt.nrcpfcgc)  > 11 THEN 2
                 ELSE crapavt.inpessoa
               END) inpessoa,
              CASE WHEN crapavt.inpessoa <> 0 THEN /* Se estiver preenchido o inpessoa (1 ou 2) do avalista */
                  DECODE(NVL(crapavt.inpessoa,1),1,
                  'CPF n.º'||gene0002.fn_mask_cpf_cnpj(crapavt.nrcpfcgc, 1)||
                      --PJ438 - Não apresentar rg quando não possuir
                      CASE WHEN SUBSTR(TRIM(crapavt.nrdocava),1,15) <> '' THEN ' RG n.º '||SUBSTR(TRIM(crapavt.nrdocava),1,15) END ||
                      decode(nvl(trim(gnetcvl.dsestcvl),trim(gnetcvl_2.dsestcvl))
                                  ,NULL, NULL, ', com o estado civil ')||nvl(trim(gnetcvl.dsestcvl),trim(gnetcvl_2.dsestcvl)),
                  'CNPJ n.º '||gene0002.fn_mask_cpf_cnpj(crapavt.nrcpfcgc, 2))
              WHEN LENGTH(crapavt.nrcpfcgc) <= 11 THEN /* se não estiver preenchido (0) e for CPF length <= 11 */
                  'CPF n.º'||gene0002.fn_mask_cpf_cnpj(crapavt.nrcpfcgc, 1)||
                      ' RG n.º '||SUBSTR(TRIM(crapavt.nrdocava),1,15)||decode(nvl(trim(gnetcvl.dsestcvl),trim(gnetcvl_2.dsestcvl))
                                  ,NULL, NULL, ', com o estado civil ')||nvl(trim(gnetcvl.dsestcvl),trim(gnetcvl_2.dsestcvl))
              ELSE /* Se não estiver preenchido e for CNPJ */
                  'CNPJ n.º '||gene0002.fn_mask_cpf_cnpj(crapavt.nrcpfcgc, 2) 
              END dados_pessoais,
              'Endereço: '||crapavt.dsendres##1||', bairro '||crapavt.dsendres##2||
              ', da cidade de '||crapavt.nmcidade||'/'||crapavt.cdufresd||', CEP '||gene0002.fn_mask_cep(crapavt.nrcepend) dsendere,
              DECODE(TRIM(crapavt.nmconjug),NULL,NULL,'Cônjuge: '||crapavt.nmconjug) ||
              DECODE(NVL(crapavt.nrcpfcjg,0),0,'',' CPF n.º '||gene0002.fn_mask_cpf_cnpj(crapavt.nrcpfcjg,1))||
              DECODE(crapavt.tpdoccjg,'CI',' RG n.º '|| crapavt.nrdoccjg,'')  nrnmconjug,
              nvl(trim(gnetcvl.rsestcvl),trim(gnetcvl_2.rsestcvl)) rsestcvl,
              decode(nvl(crapavt.cdnacion,0),0,crapttl.cdnacion,crapavt.cdnacion) cdnacion,
              NVL(TRIM(crapavt.dsproftl),crapttl.dsproftl) dsproftl,
              NVL(TRIM(crapavt.nrdocava),crapttl.nrdocttl) nrdocptl,
              crapavt.dsendres##1,
              crapavt.dsendres##2,
              crapavt.nrcepend,
              crapavt.nmcidade,
              crapavt.cdufresd,
              crapavt.nrendere,
              crapavt.nrcpfcgc,
              crapavt.cdcooper,
              crapass.nrdconta nrdctato
      FROM  gnetcvl,
            gnetcvl gnetcvl_2,
            crapttl,
            crapass,
            crapavt
      WHERE gnetcvl.cdestcvl (+) = crapttl.cdestcvl
      AND   gnetcvl_2.cdestcvl (+) = crapavt.cdestcvl
      AND   crapavt.cdcooper = pr_cdcooper
      AND   crapavt.nrcpfcgc = pr_nrcpfbem
      AND   crapavt.nrdconta = pr_nrdconta
      AND   crapavt.nrctremp = pr_nrctremp
      AND   crapavt.tpctrato = 9
      AND   crapass.cdcooper (+) = crapavt.cdcooper
      AND   crapass.nrcpfcgc (+) = crapavt.nrcpfcgc
      AND   crapttl.cdcooper (+) = crapass.cdcooper
      AND   crapttl.nrdconta (+) = crapass.nrdconta
      AND   crapttl.idseqttl (+) = 1;
    rw_crapavt cr_crapavt%ROWTYPE;

    -- Cursor sobre o endereco do associado
    CURSOR cr_crapenc( pr_cdcooper crapenc.cdcooper%TYPE,
                       pr_nrdconta crapenc.nrdconta%TYPE,
                       pr_inpessoa crapass.inpessoa%TYPE) IS
      SELECT crapenc.dsendere,
             crapenc.nrendere,
             crapenc.nmbairro,
             crapenc.nmcidade,
             crapenc.cdufende,
             crapenc.nrcepend
        FROM crapenc
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND idseqttl = 1
         AND tpendass = CASE
                        WHEN pr_inpessoa = 1 THEN
                          10 --Residencial
                        ELSE
                          9 -- Comercial
                        END;
    rw_crapenc cr_crapenc%ROWTYPE;--armazena informacoes do cursor cr_crapenc
    
    --> Identificar tipo de emprestimo
    CURSOR cr_crapepr IS
      SELECT epr.tpemprst,
             lcr.tplcremp 
        FROM crawepr epr,
             craplcr lcr
       WHERE epr.cdcooper = lcr.cdcooper
         AND epr.cdlcremp = lcr.cdlcremp
         AND epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp; 
    rw_crapepr cr_crapepr%ROWTYPE;    

    
    vr_dsqualif  VARCHAR2(2000);
    vr_dsendere  VARCHAR2(1000);
    vr_dsnacion  crapnac.dsnacion%TYPE;         
      

  BEGIN
    
    --> Identificar tipo de emprestimo
    rw_crapepr := NULL;
    OPEN cr_crapepr;
    FETCH cr_crapepr INTO rw_crapepr;
    CLOSE cr_crapepr;  
  
    -- busca nome do associado proprietario do bem
    OPEN cr_crapass(1);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%FOUND THEN -- verifica se encontrou
      CLOSE cr_crapass;
      IF rw_crapepr.tpemprst = 2 THEN
        pr_nmdavali   := 'Nome Proprietário: '||rw_crapass.nmprimtl ||' - Emitente/Cooperado.';
      ELSE
        pr_nmdavali   := 'Nome Proprietário (interveniente garantidor): '||rw_crapass.nmprimtl;
      END IF;
      
      pr_dados_pess := rw_crapass.dados_pessoais;
      pr_dsendere   := rw_crapass.dsendere;
      pr_nrnmconjug := rw_crapass.nrnmconjug;
    ELSE -- se nao encontrou proprietario do bem, busca nome do proprietario da conta
      CLOSE cr_crapass;--busca nome do associado
      OPEN cr_crapavt; -- busca nome do avalista
      FETCH cr_crapavt INTO rw_crapavt;
      IF cr_crapavt%FOUND THEN -- verifica se encontrou avalista
        CLOSE cr_crapavt;

        -- Se ja passou uma vez, entao pode inserir na temp-table
        IF nvl(vr_flginterv,'N') = 'S' THEN

          -- Se ja existiu inclusao
          IF vr_tab_interv.first IS NOT NULL THEN
            -- Verifica se o indicador de segundo esta marcado
            IF vr_tab_interv(vr_tab_interv.last).insegund IS NULL THEN
              vr_tab_interv(vr_tab_interv.last).insegund := 'S';
            ELSE
              vr_tab_interv(vr_tab_interv.last+1).inprimei := 'S';
              vr_tab_interv(vr_tab_interv.last).insegund   := '';
            END IF;
          ELSE
            vr_tab_interv(1).inprimei := 'S';
            vr_tab_interv(1).insegund := '';
          END IF;
        END IF;
        vr_flginterv  := 'S';

        IF rw_crapepr.tpemprst = 2 THEN
          vr_dsqualif := NULL;
        
          --> montar desc endereço
          IF TRIM(rw_crapavt.dsendres##1) IS NOT NULL THEN
            vr_dsendere := rw_crapavt.dsendres##1 || ', '
                           || 'n° '|| rw_crapavt.nrendere || ', bairro ' || rw_crapavt.dsendres##2 || ', '
                           || 'da cidade de ' || rw_crapavt.nmcidade || '/' || rw_crapavt.cdufresd || ', '
                           || 'CEP ' || gene0002.fn_mask_cep(rw_crapavt.nrcepend);
          ELSIF nvl(rw_crapavt.nrdctato,0) <> 0 THEN 
            -- Busca os dados do endereco residencial do associado
            rw_crapenc := null;
            OPEN  cr_crapenc( pr_cdcooper => rw_crapavt.cdcooper,
                              pr_nrdconta => rw_crapavt.nrdctato,
                              pr_inpessoa => rw_crapavt.inpessoa);
            FETCH cr_crapenc INTO rw_crapenc;                
            CLOSE cr_crapenc;
                
            IF TRIM(rw_crapenc.dsendere) IS NOT NULL THEN
              vr_dsendere := rw_crapenc.dsendere || ', '
                          || 'n° '|| rw_crapenc.nrendere || ', bairro ' || rw_crapenc.nmbairro || ', '
                          || 'da cidade de ' || rw_crapenc.nmcidade || '/' || rw_crapenc.cdufende || ', '
                          || 'CEP ' || gene0002.fn_mask_cep(rw_crapenc.nrcepend);
            END IF;              
          END IF;  
          
          -- Verifica se o documento eh um CPF ou CNPJ
          IF rw_crapavt.inpessoa = 1 THEN              

            -- Busca a Nacionalidade
            vr_dsnacion := NULL;
            vr_dsnacion := cada0014.fn_desc_nacionalidade(pr_cdnacion => rw_crapavt.cdnacion,
                                                          pr_dscritic => vr_dscritic);

            -- monta descricao para o relatorio com os dados do emitente
            vr_dsqualif := (CASE WHEN TRIM(vr_dsnacion) IS NOT NULL THEN 'nacionalidade '||LOWER(vr_dsnacion) || ', ' ELSE '' END)
                        || (CASE WHEN TRIM(rw_crapavt.dsproftl) IS NOT NULL THEN LOWER(rw_crapavt.dsproftl) || ', ' ELSE '' END)
                        || (CASE WHEN TRIM(rw_crapavt.rsestcvl) IS NOT NULL THEN LOWER(rw_crapavt.rsestcvl) || ', ' ELSE '' END)
                        || 'inscrito(a) no CPF sob n° ' || gene0002.fn_mask_cpf_cnpj(rw_crapavt.nrcpfcgc, rw_crapavt.inpessoa) || ', '
                        || 'portador(a) do RG n° ' || rw_crapavt.nrdocptl;
                          
            IF TRIM(vr_dsendere) IS NOT NULL THEN
              vr_dsqualif := vr_dsqualif || ', residente e domiciliado(a) na '|| vr_dsendere;              
            END IF;
              
            IF nvl(rw_crapavt.nrdctato,0) <> 0 THEN 
              vr_dsqualif := vr_dsqualif || ', titular da conta corrente n° ' || TRIM(gene0002.fn_mask_conta(rw_crapavt.nrdctato));
            END IF;
                  
          ELSE
            -- monta descricao para o relatorio com os dados do emitente
            vr_dsqualif := ', inscrita no CNPJ sob n° '|| gene0002.fn_mask_cpf_cnpj(rw_crapavt.nrcpfcgc, rw_crapavt.inpessoa);
              
            IF TRIM(vr_dsendere) IS NOT NULL THEN
              vr_dsqualif := vr_dsqualif || ', com sede na '|| vr_dsendere;              
            END IF;
              
            IF nvl(rw_crapavt.nrdctato,0) <> 0 THEN 
              vr_dsqualif := vr_dsqualif || ', conta corrente n° ' || TRIM(gene0002.fn_mask_conta(rw_crapavt.nrdctato));
            END IF;
          END IF;
          
          
        
          pr_nmdavali   := 'Nome Proprietário: '||rw_crapavt.nmdavali ||'('||vr_dsqualif||'), na condição de interveniente garantidor.';
        ELSE
          pr_nmdavali   := 'Nome Proprietário (interveniente garantidor): '||rw_crapavt.nmdavali;
        END IF;
                
        pr_dados_pess := rw_crapavt.dados_pessoais;
        pr_dsendere   := rw_crapavt.dsendere;
        pr_nrnmconjug := rw_crapavt.nrnmconjug;

      ELSE -- se nao tiver avalista busca associado
        CLOSE cr_crapavt;
        OPEN cr_crapass(2);-- busca nome do associado
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%FOUND THEN
          CLOSE cr_crapass;
          IF rw_crapepr.tpemprst = 2 THEN
            pr_nmdavali   := 'Nome Proprietário: '||rw_crapass.nmprimtl ||' - Emitente/Cooperado.';
          ELSE
            pr_nmdavali   := 'Nome Proprietário (interveniente garantidor): '||rw_crapass.nmprimtl;
          END IF;
          
          pr_dados_pess := rw_crapass.dados_pessoais;
          pr_dsendere   := rw_crapass.dsendere;
          pr_nrnmconjug := rw_crapass.nrnmconjug;
        ELSE
          CLOSE cr_crapass;
          -- retorna nullo se nao encontrar dados
          pr_nmdavali   := NULL;
          pr_dados_pess := NULL;
          pr_dsendere   := NULL;
          pr_nrnmconjug := NULL;
        END IF;
      END IF;
    END IF;

  END pc_dados_proprietario;

  PROCEDURE pc_busca_avalista (pr_cdcooper IN crapcop.cdcooper%TYPE
                              ,pr_nrdconta IN crapepr.nrdconta%TYPE
                              ,pr_nrctremp IN crapepr.nrctremp%TYPE
                              ,pr_nrseqava IN INTEGER
                              ,pr_nmdavali OUT crapavt.nmdavali%TYPE
                              ,pr_nrcpfcgc OUT VARCHAR2
                              ,pr_dsendres OUT VARCHAR2
                              ,pr_nrfonres OUT crapavt.nrfonres%TYPE
                              ,pr_nmconjug OUT crapavt.nmconjug%TYPE
                              ,pr_nrcpfcjg OUT VARCHAR2
                              )IS

  -- Busca os dados sobre a tabela de avalistas
  CURSOR cr_crapavt IS
    SELECT crapavt.nmdavali,
           gene0002.fn_mask_cpf_cnpj(crapavt.nrcpfcgc,crapavt.inpessoa) nrcpfcgc,
           crapavt.dsendres##1 ||' '||crapavt.nrendere||', '||decode(trim(crapavt.complend),null,'',crapavt.complend||', ')||
                  crapavt.dsendres##2||' - '||crapavt.nmcidade||' - '||gene0002.fn_mask_cep(crapavt.nrcepend)||' - '||
                  crapavt.cdufresd dsendres,
           crapavt.nrfonres,
           crapavt.nmconjug,
           crapavt.nrcpfcjg
      FROM crapavt
    WHERE cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta
      AND nrctremp = pr_nrctremp
      AND tpctrato = 1
      AND nmdavali = (SELECT decode(pr_nrseqava,1,e.nmdaval1,e.nmdaval2) 
                        FROM crawepr e
                       WHERE e.cdcooper = crapavt.cdcooper
                         and e.nrdconta = crapavt.nrdconta
                         and e.nrctremp = crapavt.nrctremp); -- avalista

  CURSOR cr_crawepr_av IS
    SELECT nvl(crapass.nmprimtl,crawepr.nmdaval1) nmdaval1,
           gene0002.fn_mask_cpf_cnpj(crapass.nrcpfcgc, crapass.inpessoa)||' '||gene0002.fn_mask_conta(crapass.nrdconta) dscpfav1,
           decode(crapass.nrdconta,NULL,
              crawepr.dsendav1##1||', '||crawepr.dsendav1##2,
              crapenc.dsendere||', nº '||crapenc.nrendere||', bairro '||crapenc.nmbairro ||', da cidade de '||
                crapenc.nmcidade||'/'||crapenc.cdufende||', CEP '||gene0002.fn_mask_cep(crapenc.nrcepend)) dsendres_1,
           (SELECT craptfc.nrdddtfc||craptfc.nrtelefo FROM craptfc
                                          WHERE cdcooper = crapass.cdcooper
                                            AND nrdconta = crapass.nrdconta
                                            AND idseqttl = 1
                                            AND cdseqtfc = (SELECT MIN(cdseqtfc)
                                                              FROM craptfc
                                                             WHERE cdcooper = crapass.cdcooper
                                                               AND nrdconta = crapass.nrdconta
                                                               AND idseqttl = 1)) nrtelefo,
           nvl(nvl(crapass_cje.nmprimtl,crapcje.nmconjug),crawepr.nmcjgav1) nmcjgav1,
           gene0002.fn_mask_cpf_cnpj(nvl(crapass_cje.nrcpfcgc,crapcje.nrcpfcjg),1) nrcpfcjg_1,
           nvl(crapass_2.nmprimtl,crawepr.nmdaval2) nmdaval2,
           gene0002.fn_mask_cpf_cnpj(crapass_2.nrcpfcgc, crapass_2.inpessoa)||' '||gene0002.fn_mask_conta(crapass_2.nrdconta) dscpfav2,
           decode(crapass_2.nrdconta,NULL,
              crawepr.dsendav2##1||', '||crawepr.dsendav2##2,
              crapenc_2.dsendere||', nº '||crapenc_2.nrendere||', bairro '||crapenc_2.nmbairro ||', da cidade de '||
                crapenc_2.nmcidade||'/'||crapenc_2.cdufende||', CEP '||gene0002.fn_mask_cep(crapenc_2.nrcepend)) dsendres_2,
           (SELECT craptfc.nrdddtfc||craptfc.nrtelefo FROM craptfc
                                          WHERE cdcooper = crapass_2.cdcooper
                                            AND nrdconta = crapass_2.nrdconta
                                            AND idseqttl = 1
                                            AND cdseqtfc = (SELECT MIN(cdseqtfc)
                                                              FROM craptfc
                                                             WHERE cdcooper = crapass_2.cdcooper
                                                               AND nrdconta = crapass_2.nrdconta
                                                               AND idseqttl = 1)) nrtelefo_2,
           nvl(nvl(crapass_cje_2.nmprimtl,crapcje_2.nmconjug),crawepr.nmcjgav2) nmcjgav2,
           gene0002.fn_mask_cpf_cnpj(nvl(crapass_cje_2.nrcpfcgc,crapcje_2.nrcpfcjg),1) nrcpfcjg_2
      FROM crapenc crapenc_2, -- endereco do avalista 1
           crapass crapass_cje_2, -- Conjuge do associado quando o mesmo possui conta
           crapcje crapcje_2, -- conjuge do avalista 2
           crapass crapass_2, -- Associado do avalista 2
           crapass crapass_cje, -- Conjuge do associado quando o mesmo possui conta
           crapenc, -- endereco do avalista 1
           crapcje, -- conjuge do avalista 1
           crapass, -- Associado do avalista 1
           crawepr
     WHERE crawepr.cdcooper = pr_cdcooper
       AND crawepr.nrdconta = pr_nrdconta
       AND crawepr.nrctremp = pr_nrctremp
       AND crapass.cdcooper (+) = crawepr.cdcooper
       AND crapass.nrdconta (+) = crawepr.nrctaav1
       AND crapcje.cdcooper (+) = crawepr.cdcooper
       AND crapcje.nrdconta (+) = crawepr.nrctaav1
       AND crapcje.idseqttl (+) = 1
       AND crapenc.cdcooper (+) = crapass.cdcooper
       AND crapenc.nrdconta (+) = crapass.nrdconta
       AND crapenc.idseqttl (+) = 1
       AND crapenc.tpendass (+) = decode(crapass.inpessoa,1,10,9)
       AND crapass_cje.cdcooper (+) = crapcje.cdcooper
       AND crapass_cje.nrdconta (+) = crapcje.nrctacje
       AND crapass_2.cdcooper (+) = crawepr.cdcooper
       AND crapass_2.nrdconta (+) = crawepr.nrctaav2
       AND crapcje_2.cdcooper (+) = crawepr.cdcooper
       AND crapcje_2.nrdconta (+) = crawepr.nrctaav2
       AND crapcje_2.idseqttl (+) = 1
       AND crapass_cje_2.cdcooper (+) = crapcje_2.cdcooper
       AND crapass_cje_2.nrdconta (+) = crapcje_2.nrctacje
       AND crapenc_2.cdcooper (+) = crapass_2.cdcooper
       AND crapenc_2.nrdconta (+) = crapass_2.nrdconta
       AND crapenc_2.idseqttl (+) = 1
       AND crapenc_2.tpendass (+) = decode(crapass_2.inpessoa,1,10,9);
  rw_crawepr_av cr_crawepr_av%ROWTYPE;

  ww_nmdavali_org crapavt.nmdavali%TYPE;

BEGIN
  /*Alterado para respeitar a sequencia dos avalistas conforme emprestimo -- PRJ438*/
  FOR rw_crapavt IN cr_crapavt LOOP
    ww_nmdavali_org := rw_crapavt.nmdavali;
    --IF pr_nrseqava = cr_crapavt%ROWCOUNT THEN
      pr_nmdavali := rw_crapavt.nmdavali;
      pr_nrcpfcgc := rw_crapavt.nrcpfcgc;
      pr_dsendres := rw_crapavt.dsendres;
      pr_nrfonres := rw_crapavt.nrfonres;
      pr_nmconjug := rw_crapavt.nmconjug;
      pr_nrcpfcjg := rw_crapavt.nrcpfcjg;
    --END IF;
  END LOOP;

  -- Se nao encontrou, busca direto na tabela de emprestimos
  IF pr_nmdavali IS NULL THEN
    OPEN cr_crawepr_av;
    FETCH cr_crawepr_av INTO rw_crawepr_av;
    IF cr_crawepr_av%FOUND THEN
      IF (pr_nrseqava = 1 AND
          trim(rw_crawepr_av.nmdaval1) IS NOT NULL AND
          rw_crawepr_av.nmdaval1 <> nvl(ww_nmdavali_org,' ')) OR
         (pr_nrseqava = 2 AND
          trim(rw_crawepr_av.nmdaval2) IS NOT NULL AND
          trim(rw_crawepr_av.nmdaval1) IS NOT NULL AND
          rw_crawepr_av.nmdaval1 <> nvl(ww_nmdavali_org,' ') AND
          rw_crawepr_av.nmdaval2 = nvl(ww_nmdavali_org,' ')) THEN
        pr_nmdavali := rw_crawepr_av.nmdaval1;
        pr_nrcpfcgc := rw_crawepr_av.dscpfav1;
        pr_dsendres := rw_crawepr_av.dsendres_1;
        pr_nrfonres := rw_crawepr_av.nrtelefo;
        pr_nmconjug := rw_crawepr_av.nmcjgav1;
        pr_nrcpfcjg := rw_crawepr_av.nrcpfcjg_1;
      ELSIF rw_crawepr_av.nmdaval2 IS NOT NULL AND
         rw_crawepr_av.nmdaval2 <> nvl(ww_nmdavali_org,' ') THEN
        pr_nmdavali := rw_crawepr_av.nmdaval2;
        pr_nrcpfcgc := rw_crawepr_av.dscpfav2;
        pr_dsendres := rw_crawepr_av.dsendres_2;
        pr_nrfonres := rw_crawepr_av.nrtelefo_2;
        pr_nmconjug := rw_crawepr_av.nmcjgav2;
        pr_nrcpfcjg := rw_crawepr_av.nrcpfcjg_2;
      END IF;
    END IF;
    CLOSE cr_crawepr_av;
  END IF;

  END pc_busca_avalista;

  FUNCTION fn_verifica_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_dslcremp IN craplcr.dslcremp%TYPE)
                           RETURN VARCHAR2 IS
   /* .............................................................................

       Programa: fn_verifica_cdc
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago Castro (RKAM)
       Data    : Junho/2015.                         Ultima atualizacao: 11/06/2015

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Verificar se linha credito do contrato existe no cadastro de
                   parametros CDC.

       Alteracoes:

    ............................................................................. */

    v_linhacdc VARCHAR2(1000);
    vr_busca  VARCHAR2(100);
    vr_idx      NUMBER;
    vr_cdc VARCHAR2(1);

  BEGIN
    -- Busca o texto de linha CDC
    v_linhacdc := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                            pr_cdcooper =>  pr_cdcooper,
                                            pr_cdacesso =>  'LINHA_CDC')||';';

    IF v_linhacdc IS NOT NULL THEN
      LOOP
        -- Identifica ponto de quebra inicial
        vr_idx := instr(v_linhacdc, ';');
        -- Clausula de saída para o loop
        exit WHEN nvl(vr_idx, 0) = 0 OR vr_cdc = 'S';
        -- valor da string para pesquisa
        vr_busca := trim(substr(v_linhacdc, 1, vr_idx - 1));
        -- verifica se encontrou linha de credito existe no cadastro de CDC
        vr_cdc := gene0002.fn_contem(pr_dstexto => pr_dslcremp
                                   , pr_dsprocu => vr_busca);
        -- Atualiza a variável com a string integral eliminando o bloco quebrado
        v_linhacdc := substr(v_linhacdc, vr_idx + LENGTH(';'));
      END LOOP;
    END IF;
    -- retorna se linha eh CDC ou nao
    RETURN vr_cdc;

  END fn_verifica_cdc;


/* 27/03/2015 - Ajustado para utilizar o progress_recid da crapbpr em variavel de indice de ARRAY
                que guarda os bens alienados. (Jorge/Gielow) */

  PROCEDURE pc_busca_bens (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE
                          ,pr_nrctremp IN crawepr.nrctremp%TYPE
                          ,pr_cdagenci IN crapass.cdagenci%TYPE
                          ) IS
  -- cursor sobre o cadastro de bens do associado
    CURSOR cr_crapbpr IS
      SELECT  crapbpr.nrcpfbem,
              crapbpr.dschassi dschassi2,
              crapbpr.dsbemfin,
              crapbpr.vlmerbem,
              crapbpr.dscatbem,
              'Renavan: '|| case when nvl(crapbpr.nrrenovo, 0) <> 0 then crapbpr.nrrenovo else crapbpr.nrrenava end nrrenava,
              decode(crapbpr.dscatbem,'TERRENO','Endereco: ' ||crapbpr.dscorbem,
                                      'CASA','Endereco: ' ||crapbpr.dscorbem,
                                      'APARTAMENTO','Endereco: ' ||crapbpr.dscorbem,
                                      'MAQUINA DE COSTURA','Chassi/N Série: '||crapbpr.dschassi,
                                      'MAQUINA E EQUIPAMENTO','N Série: '||crapbpr.dschassi,
                                      'EQUIPAMENTO','Chassi/N Série: '||crapbpr.dschassi,
                                      'GALPAO','Endereco: '||crapbpr.dscorbem,
                                                    'Chassi: '||crapbpr.dschassi) dschassi,
              crapbpr.tpchassi,
              case when nvl(crapbpr.ufplnovo, ' ') <> ' ' then crapbpr.ufplnovo else crapbpr.ufdplaca end ufdplaca,
              'Placa: '|| case when nvl(crapbpr.nrplnovo, ' ') <> ' ' then crapbpr.nrplnovo else crapbpr.nrdplaca end nrdplaca,
              crapbpr.uflicenc,
              decode(crapbpr.dscatbem,'MAQUINA E EQUIPAMENTO','Ano: '||nvl(crapbpr.nranobem,crapbpr.nrmodbem),'Ano: '||crapbpr.nranobem||' Modelo: '||crapbpr.nrmodbem) dsanomod, -- Incluído decode - Paulo Mouts - 25/06/19
              'Cor: '||crapbpr.dscorbem dscorbem,
              progress_recid
      FROM    crapbpr
      WHERE   crapbpr.cdcooper = pr_cdcooper
      AND     crapbpr.nrdconta = pr_nrdconta
      AND     crapbpr.nrctrpro = pr_nrctremp
      AND     crapbpr.tpctrpro = 90
      AND     crapbpr.flgalien = 1
      ORDER BY crapbpr.progress_recid;

  vr_proprietario   VARCHAR2(2000);
  vr_dados_pessoais VARCHAR2(2000);
  vr_endereco       VARCHAR2(200);
  vr_conjuge        VARCHAR2(200);
  vr_flg_inter      VARCHAR2(5);    --> flag verificar de interveniente esta habilitado
  BEGIN
      -- busca bens da proposta
      FOR rw_crapbpr IN cr_crapbpr
      LOOP
        vr_proprietario   := NULL;
        vr_dados_pessoais := NULL;
        vr_endereco       := NULL;
        vr_conjuge        := NULL;

        -- Verifica se o CPF/CNPJ informado como sendo proprietario do bem, faz
        -- parte do contrato sendo CONTRATANTE OU INTERVENIENTE ANUENTE
        pc_dados_proprietario(pr_nrcpfbem    => rw_crapbpr.nrcpfbem
                           , pr_cdcooper    => pr_cdcooper
                           , pr_nrdconta    => pr_nrdconta
                           , pr_nrctremp    => pr_nrctremp
                           , pr_nmdavali    => vr_proprietario
                           , pr_dados_pess  => vr_dados_pessoais
                           , pr_dsendere    => vr_endereco
                           , pr_nrnmconjug  => vr_conjuge
                           );

        IF vr_proprietario IS NULL THEN -- caso nao encontr o proprietario
          /* verifica se o interveniente esta habilitado */
          vr_flg_inter := fn_verifica_interv(pr_cdagenci => pr_cdagenci --rw_crapavi_01.cdagenci
                                           , pr_cdcooper => pr_cdcooper
                                            );
          IF vr_flg_inter = 'FALSE' THEN -- nao encontrou ou interveniente nao nao faz parte do contrato
            vr_dscritic := 'O Proprietario do bem '||
                           TRIM(substr(rw_crapbpr.dsbemfin, 1, 18))||
                           'nao faz parte do contrato.'; --monta critica
            RAISE vr_exc_saida; -- encerra programa e retorna critica
          END IF;
        END IF;
        --popula temp table bens
        --vr_des_chave := lpad(rw_crapbpr.nrcpfbem,27,'0')||lpad(rw_crapbpr.dschassi2,35,'0')||lpad(rw_crapbpr.dsbemfin, 101, '0');
        vr_des_chave := rw_crapbpr.progress_recid;
        vr_tab_bens(vr_des_chave).nrcpfbem        := rw_crapbpr.nrcpfbem;
        vr_tab_bens(vr_des_chave).dsbem           := rw_crapbpr.dsbemfin;
        vr_tab_bens(vr_des_chave).dschassi        := rw_crapbpr.dschassi;
        vr_tab_bens(vr_des_chave).nrdplaca        := rw_crapbpr.nrdplaca;
        vr_tab_bens(vr_des_chave).nrrenava        := rw_crapbpr.nrrenava;
        vr_tab_bens(vr_des_chave).dsanomod        := rw_crapbpr.dsanomod;
        vr_tab_bens(vr_des_chave).dscorbem        := rw_crapbpr.dscorbem;
        vr_tab_bens(vr_des_chave).avaliacao       := rw_crapbpr.vlmerbem;
        vr_tab_bens(vr_des_chave).proprietario    := vr_proprietario;
        vr_tab_bens(vr_des_chave).dados_pessoais  := vr_dados_pessoais;
        vr_tab_bens(vr_des_chave).endereco        := vr_endereco;
        vr_tab_bens(vr_des_chave).conjuge         := vr_conjuge;
        vr_tab_bens(vr_des_chave).dscatbem        := rw_crapbpr.dscatbem;
      END LOOP;

  END pc_busca_bens;

  /* Monta o XML do contrato PP e TR */
  PROCEDURE pc_gera_xml_contrato_pp_tr(pr_cdcooper  IN crapepr.cdcooper%TYPE --> Codigo da Cooperativa
                                      ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Numero da conta do emprestimo
                                      ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Numero do contrato de emprestimo
                                      ,pr_inimpctr  IN INTEGER               --> Impressao de contratos nao negociaveis
                                      ,pr_dsjasper OUT VARCHAR2              --> Nome do Jasper
                                      ,pr_nmarqimp OUT VARCHAR2              --> Nome do arquivo PDF
                                      ,pr_des_xml  OUT CLOB                  --> XML gerado
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    /* .............................................................................

       Programa: pc_gera_xml_contrato_pp_tr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Junho/2017                         Ultima atualizacao: 12/04/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Gerar XML do contrato de emprestimo PP e TR

       Alteracoes: 12/04/2018 - P410 - Melhorias/Ajustes IOF (Marcos-Envolti)

            	   27/11/2018 - Correção dos parâmetros de taxa de juros para serem apresentados corretamente (proposta efetivada) na Opção Imprimir / Contratos da tela Atenda / Prestações.
				   Chamado INC0027935 - Gabriel (Mouts).

                   20/12/2018 - Correção da taxa CET para buscar da tabela de CET quando existir registro
								INC0029082 (Douglas Pagel / AMcom).

    ............................................................................. */

      -- Cursor sobre as informacoes de emprestimo
      CURSOR cr_crapepr IS
        SELECT crapepr.vltarifa,
               crapepr.vliofepr,
               crapepr.vlemprst
        FROM crapepr
        WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
        
      CURSOR cr_crawepr IS
        SELECT crawepr.cdfinemp,
               crawepr.cdlcremp,
               crawepr.dtmvtolt,
               crawepr.vlemprst,
               crawepr.qtpreemp,
               crawepr.vlpreemp,
               crawepr.dtvencto,
               crawepr.qttolatr,
               crawepr.percetop,
               crawepr.nrctaav1,
               crawepr.nrctaav2,
               crapass.inpessoa,
               crapass.nrcpfcgc,
               crapass.nrdocptl,
               crapass.cdagenci,
               crawepr.cdagenci cdageepr,
               crapass.nmprimtl,
               crawepr.tpemprst,
               crawepr.flgpagto,
               add_months(crawepr.dtvencto,crawepr.qtpreemp -1) dtultpag,
               crawepr.dtlibera,
               crawepr.dtdpagto,
               crawepr.txmensal,
               crapage.nmcidade,
               crapage.cdufdcop,
               crawepr.nrseqrrq,
               crawepr.idcobope,
               crawepr.txminima,
               ROUND((POWER(1 + (crawepr.txminima / 100),12) - 1) * 100,2) prjurano,
               -- Projeto 410 - 14/03/2018 - SM - incluir campos para calculo IOF e tarifa
               crawepr.idfiniof,
                crawepr.nrctrliq##1 || ',' ||
                crawepr.nrctrliq##2 || ',' ||
                crawepr.nrctrliq##3 || ',' ||
                crawepr.nrctrliq##4 || ',' ||
                crawepr.nrctrliq##5 || ',' ||
                crawepr.nrctrliq##6 || ',' ||
                crawepr.nrctrliq##7 || ',' ||
                crawepr.nrctrliq##8 || ',' ||
                crawepr.nrctrliq##9 || ',' ||
                crawepr.nrctrliq##10 dsctrliq,
                crawepr.dtaltpro -- Rafael Ferreira (Mouts) - Story 19674
          FROM crapage,
               crapass,
               crawepr
         WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta
           AND crawepr.nrctremp = pr_nrctremp
           AND crapass.cdcooper = crawepr.cdcooper
           AND crapass.nrdconta = crawepr.nrdconta
           AND crapage.cdcooper = crapass.cdcooper
           AND crapage.cdagenci = crapass.cdagenci;

      rw_crawepr cr_crawepr%ROWTYPE;--armazena informacoes do cursor cr_crawepr

      --cursor para buscar estado civil da pessoa fisica, jurida nao tem
      CURSOR cr_gnetcvl(pr_cdcooper IN crapttl.cdcooper%TYPE
			           ,pr_nrdconta IN crapttl.nrdconta%TYPE) IS
          SELECT gnetcvl.rsestcvl,
			     crapttl.dsproftl
          FROM  crapttl,
                gnetcvl
          WHERE crapttl.cdcooper = pr_cdcooper
          AND crapttl.nrdconta = pr_nrdconta
          AND crapttl.idseqttl = 1 -- Primeiro Titular
          AND gnetcvl.cdestcvl = crapttl.cdestcvl;
      rw_gnetcvl cr_gnetcvl%ROWTYPE;--armazena informacoes do cursor cr_gnetcvl

      -- Cursor sobre o cadastro de linhas de credito (tela LCREDI)
      CURSOR cr_craplcr(pr_cdlcremp craplcr.cdlcremp%TYPE) IS
        SELECT dsoperac,
               dslcremp,
               tplcremp,
               tpdescto,
               decode(cdusolcr,2,0,cdusolcr) cdusolcr, -- Se for Epr/Boletos, considera como normal
               txminima,
               ROUND((POWER(1 + (txminima / 100),12) - 1) * 100,2) prjurano,
               perjurmo,
               dsorgrec,
               tpctrato,
               txjurfix,
               flgcobmu
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;--armazena informacoes do cursor cr_craplcr

      -- Cursor sobre o endereco do associado
      CURSOR cr_crapenc(pr_inpessoa crapass.inpessoa%TYPE) IS
        SELECT crapenc.dsendere,
               crapenc.nrendere,
               crapenc.nmbairro,
               crapenc.nmcidade,
               crapenc.cdufende,
               crapenc.nrcepend
          FROM crapenc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND idseqttl = 1
           AND tpendass = CASE
                          WHEN pr_inpessoa = 1 THEN
                            10 --Residencial
                          ELSE
                            9 -- Comercial
                          END;
      rw_crapenc cr_crapenc%ROWTYPE;--armazena informacoes do cursor cr_crapenc

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmextcop
              ,cop.nmrescop
              ,cop.nrdocnpj
              ,cop.dsendcop
              ,cop.nrendcop
              ,cop.nmbairro
              ,cop.nrcepend
              ,cop.nmcidade
              ,cop.cdufdcop
              ,cop.nrtelura
              ,cop.nrtelouv
              ,cop.dsendweb
              ,cop.dsdircop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE; --armazena informacoes do cursor cr_crapcop

      -- Cursor sobre os associados para buscar os dados do avalista
      CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE
                       ,pr_inpessoa crapass.inpessoa%TYPE) IS
        SELECT crapass.nmprimtl,
               crapass.inpessoa,
               decode(crapass.inpessoa,1,'CPF:','CNPJ:') dspessoa,
               crapass.nrcpfcgc,
               crapenc.dsendere ||' no. '||crapenc.nrendere||', bairro ' ||rw_crapenc.nmbairro||
                 ', '||crapenc.nmcidade||'-'||crapenc.cdufende ||'-'||'CEP '||crapenc.nrcepend dsendere,
              (SELECT craptfc.nrdddtfc||' '||craptfc.nrtelefo FROM craptfc
                                          WHERE cdcooper = crapass.cdcooper
                                            AND nrdconta = crapass.nrdconta
                                            AND idseqttl = 1
                                            AND cdseqtfc = (SELECT MIN(cdseqtfc)
                                                              FROM craptfc
                                                             WHERE cdcooper = crapass.cdcooper
                                                               AND nrdconta = crapass.nrdconta
                                                               AND idseqttl = 1)) nrtelefo,
               crapass.cdagenci,
               crapcje.nmconjug ,
               crapcje.nrcpfcjg cpfcjg
          FROM crapenc,
               crapass,
               crapcje
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta
           AND crapenc.cdcooper = crapass.cdcooper
           AND crapenc.nrdconta = crapass.nrdconta
           AND crapcje.cdcooper (+) = crapass.cdcooper
           AND crapcje.nrdconta (+)= crapass.nrdconta
           AND crapenc.idseqttl = 1
           AND crapcje.idseqttl(+) = 1
           AND crapenc.tpendass = CASE
                                  WHEN pr_inpessoa = 1 THEN
                                    10  -- Residencial
                                  ELSE
                                    9 -- comercial
                                  END;
      rw_crapavi_01 cr_crapass%ROWTYPE; --armazena informacoes do cursor cr_crapass para avalista 1
      rw_crapavi_02 cr_crapass%ROWTYPE; --armazena informacoes do cursor cr_crapass para avalista 2

      -- Verificar se possui interveniente garantidor
	  CURSOR cr_cobertura(pr_idcobert IN tbgar_cobertura_operacao.idcobertura%TYPE) IS
        SELECT 1
          FROM tbgar_cobertura_operacao tco
         WHERE tco.idcobertura = pr_idcobert
		   AND tco.nrconta_terceiro > 0;
	  rw_cobertura cr_cobertura%ROWTYPE;

     -- Projeto 410 - 14/03/2018 - SM - buscar bens da proposta (Jean - Mout´S) 
     CURSOR cr_crapbpr IS 
        SELECT t.dscatbem
          FROM crapbpr t
         WHERE t.cdcooper = pr_cdcooper
               AND t.nrdconta = pr_nrdconta
               AND t.nrctrpro = pr_nrctremp;
         rw_crapbpr cr_crapbpr%ROWTYPE;
       
         
      -- Verificar se dados do CET já foram gravados
      CURSOR cr_tbepr_calculo_cet is
        SELECT *
          FROM tbepr_calculo_cet t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta
           AND t.nrctremp = pr_nrctremp;
      rw_tbepr_calculo_cet cr_tbepr_calculo_cet%ROWTYPE;
       
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Variaveis que serao convertidas para TAGs no XML
      vr_dstitulo   VARCHAR2(200);  --> Titulo do contrato
      vr_campo_01   VARCHAR2(500);  --> Campo com os dados do emitente
      vr_emitente   VARCHAR2(500);  --> Endereco do emitente da cooperativa
      vr_coment01   VARCHAR2(2000); --> Comentario 01
      vr_campo_02   VARCHAR2(2000); --> comentario 02
      vr_nmarqim    VARCHAR2(50);   --> nome do arquivo PDF
      vr_bens       INTEGER := 1; --> para listar informacoes de veiculos

      -- Variaveis gerais
      vr_texto_completo VARCHAR2(32600);           --> Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_des_xml        CLOB;                      --> XML do relatorio
      vr_tppessoa       VARCHAR2(04);              --> Tipo de documento: CPF ou CNPJ
      vr_prmulta        number(7,2);               --> Percentual de multa
      vr_digitalizacao  VARCHAR2(80);              --> Para uso da digitalizacao
      vr_dsjasper       VARCHAR2(100);              --> nome do jasper a ser usado
      vr_taxjream       NUMBER;                    --> juros remuneratorios 30d
      vr_taxjrean       NUMBER;                    --> juros remuneratorios 365d
      vr_dados_coop     VARCHAR(290);              --> dados de contato da coop, para uso na clausula "Solucao Amigavel"
      vr_cdc            crapprm.dsvlrprm%TYPE;     --> String com valores de linha CDC
      vr_negociavel     VARCHAR2(1);               --> Identificados para impressao dos textos "Para uso da digitalizacao" e "nao negociavel"
      vr_qrcode         VARCHAR2(100);             --> QR Code para uso da digitalizacao
      vr_cdtipdoc       INTEGER;                   --> Codigo do tipo de documento
      vr_dstextab       craptab.dstextab%TYPE;     --> Descritivo da tab
      vr_txanocet       NUMBER := 0;               --> taxa anual do cet
      -- Projeto 410 - 14/03/2018 - SM - Verificar informaçoes de IOF e tarifa
      vr_dscatbem       varchar2(1000);
      vr_vlemprst       number;
      vr_vlrdoiof       number;
      vr_vlrtarif       number;
      vr_vlrtares       number;
      vr_vltarbem       number;
      vr_vlpreclc       NUMBER := 0;                -- Parcela calcula
      vr_vliofpri       number;
      vr_vliofadi       number;
      vr_flgimune PLS_INTEGER;
      vr_tpctrato NUMBER := 0;                -- Tipo de contrato
      vr_cdhisbem NUMBER := 0;                -- Hostorico do bem
      vr_cdhistor NUMBER := 0;                -- Historico
      vr_cdusolcr NUMBER := 0;                -- Uso linha de credito
      vr_vlfinanc NUMBER := 0;
      vr_cdfvlcop crapfco.cdfvlcop%TYPE;


      -- Variáveis de portabilidade
      nrcnpjbase_if_origem VARCHAR2(100);
      nrcontrato_if_origem VARCHAR2(100);
      nomcredora_if_origem VARCHAR2(100);
      vr_retxml            xmltype;
      vr_portabilidade     BOOLEAN := FALSE;
      
      -- avalista e conjuge 1
      vr_nmdavali1      crapavt.nmdavali%TYPE;
      vr_nrcpfcgc1      VARCHAR2(50);
      vr_dsendres1      VARCHAR2(200);
      vr_nrfonres1      crapavt.nrfonres%TYPE;
      vr_nmconjug1      crapavt.nmconjug%TYPE;
      vr_nrcpfcjg1      VARCHAR2(50);
      --avalista e conjuge 2
      vr_nmdavali2      crapavt.nmdavali%TYPE;
      vr_nrcpfcgc2      VARCHAR2(50);
      vr_dsendres2      VARCHAR2(200);
      vr_nrfonres2      crapavt.nrfonres%TYPE;
      vr_nmconjug2      crapavt.nmconjug%TYPE;
      vr_nrcpfcjg2      VARCHAR2(50);

      -- controle versão
      vr_nrversao       NUMBER;

      -- Tabela temporaria para o descritivo dos avais
      TYPE typ_reg_avl IS RECORD(descricao VARCHAR2(4000));
      TYPE typ_tab_avl IS TABLE OF typ_reg_avl INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os riscos
      vr_tab_avl typ_tab_avl;
      vr_ind_add_item   INTEGER := 0;                 --> Indicador se possui terceiro garantidor (0-Nao / 1-Sim)
      vr_ind_aval       PLS_INTEGER;                  --> Indice da PL Table
      vr_tab_aval       DSCT0002.typ_tab_dados_avais; --> PL Table dos avalistas			
						
    BEGIN
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      vr_texto_completo := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Abre o cursor com as informacoes do emprestimo
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      -- Se nao encontrar o emprestimo finaliza o programa
      IF cr_crawepr%NOTFOUND THEN
        vr_dscritic := 'Emprestimo '||nvl(pr_nrctremp,0) ||' nao encontrado para impressao'; --monta critica
        CLOSE cr_crawepr;
        RAISE vr_exc_saida; -- encerra programa e retorna critica
      END IF;
      CLOSE cr_crawepr;

      -- Verifica a versão do contrato
      IF rw_crawepr.dtmvtolt < TO_DATE('26/10/2016','DD/MM/RRRR') THEN
        vr_nrversao := 0;
      ELSE
        vr_nrversao := 1;
      END IF;

			-- Se possuir cobertura e data for superior ao do novo contrato
			IF rw_crawepr.idcobope > 0 AND
				 rw_crawepr.dtmvtolt >= TO_DATE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
																																 ,pr_cdacesso => 'DT_VIG_IMP_CTR_V2'),'DD/MM/RRRR') THEN
				--> Garantia Operacoes de Credito
				OPEN  cr_cobertura(pr_idcobert => rw_crawepr.idcobope);
				FETCH cr_cobertura INTO rw_cobertura;
				-- Se encontrou
				IF cr_cobertura%FOUND THEN
					-- Atribui flag de interveniente garantidor
					vr_ind_add_item := 1;
				END IF;
				CLOSE cr_cobertura;
			END IF;								

      -- Checar se existe informações de CET gerado na efetivação
      OPEN cr_tbepr_calculo_cet;
      FETCH cr_tbepr_calculo_cet 
       INTO rw_tbepr_calculo_cet;
      IF cr_tbepr_calculo_cet%FOUND THEN
        -- Usaremos as informações da tabela
        vr_txanocet := rw_tbepr_calculo_cet.txanocet;
      ELSE
        vr_txanocet := rw_crawepr.percetop;
      END IF;						
      CLOSE cr_tbepr_calculo_cet;
      
      -- Busca os dados do cadastro de linhas de credito
      OPEN cr_craplcr(rw_crawepr.cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      -- Se nao encontrar o emprestimo finaliza o programa
      IF cr_craplcr%NOTFOUND THEN
        vr_dscritic := 'Linha de credito nao encontrada para impressao'; -- monta critica
        CLOSE cr_craplcr;
        RAISE vr_exc_saida;--encerra programa e retorna critica
      END IF;
      CLOSE cr_craplcr;

      vr_cdc := fn_verifica_cdc(pr_cdcooper => pr_cdcooper
                               ,pr_dslcremp => rw_craplcr.dslcremp);
      
      IF vr_cdc = 'S' THEN
        vr_dscritic := 'Impressao de CCB nao permitida para linhas de CDC'; -- monta critica
        RAISE vr_exc_saida;--encerra programa e retorna critica
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida; -- encerra programa e retorna critica 651
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Busca os dados do endereco residencial do associado
      OPEN cr_crapenc(rw_crawepr.inpessoa);
      FETCH cr_crapenc INTO rw_crapenc;
      -- Se nao encontrar o endereco finaliza o programa
      IF cr_crapenc%NOTFOUND THEN
        vr_dscritic := 'Endereco do associado nao encontrada para impressao'; -- monta critica
        CLOSE cr_crapenc;
        RAISE vr_exc_saida; -- encerra programa e retorna critica
      END IF;
      CLOSE cr_crapenc;
      -- Busca o avalista 1
      pc_busca_avalista(pr_cdcooper => pr_cdcooper
                      , pr_nrdconta => pr_nrdconta
                      , pr_nrctremp => pr_nrctremp
                      , pr_nrseqava => 1
                      , pr_nmdavali => vr_nmdavali1
                      , pr_nrcpfcgc => vr_nrcpfcgc1
                      , pr_dsendres => vr_dsendres1
                      , pr_nrfonres => vr_nrfonres1
                      , pr_nmconjug => vr_nmconjug1
                      , pr_nrcpfcjg => vr_nrcpfcjg1);

      -- Busca o avalista 2
      pc_busca_avalista(pr_cdcooper => pr_cdcooper
                      , pr_nrdconta => pr_nrdconta
                      , pr_nrctremp => pr_nrctremp
                      , pr_nrseqava => 2
                      , pr_nmdavali => vr_nmdavali2
                      , pr_nrcpfcgc => vr_nrcpfcgc2
                      , pr_dsendres => vr_dsendres2
                      , pr_nrfonres => vr_nrfonres2
                      , pr_nmconjug => vr_nmconjug2
                      , pr_nrcpfcjg => vr_nrcpfcjg2);

      -- Buscar dados de portabilidade
      CECRED.empr0006.pc_consulta_portabil_crt(pr_cdcooper   => pr_cdcooper
                                              ,pr_nrdconta   => pr_nrdconta
                                              ,pr_nrctremp   => pr_nrctremp
                                              ,pr_tpoperacao => 1
                                              ,pr_cdcritic   => vr_cdcritic
                                              ,pr_dscritic   => vr_dscritic
                                              ,pr_retxml     => vr_retxml);
                                               
      IF vr_retxml.existsNode('/Dados/inf/nrcnpjbase_if_origem') > 0 AND
         vr_retxml.existsNode('/Dados/inf/nrcontrato_if_origem') > 0 THEN
        vr_portabilidade := TRUE;
        nrcnpjbase_if_origem := TRIM(vr_retxml.extract('/Dados/inf/nrcnpjbase_if_origem/text()').getstringval());
        nrcontrato_if_origem := TRIM(vr_retxml.extract('/Dados/inf/nrcontrato_if_origem/text()').getstringval());
        nomcredora_if_origem := TRIM(vr_retxml.extract('/Dados/inf/nmif_origem/text()').getstringval());
      ELSE
        nrcnpjbase_if_origem := '';
        nrcontrato_if_origem := '';
        nomcredora_if_origem := '';
      END IF;
      
			-- Reseta as variaveis
			vr_tab_avl(1).descricao := '';
			vr_tab_avl(2).descricao := '';
					
			IF rw_crawepr.tpemprst = 1 AND --PP
				 vr_nrversao = 1         THEN
						 
				-- Listar avalistas de contratos
				DSCT0002.pc_lista_avalistas(pr_cdcooper => pr_cdcooper  --> Codigo da Cooperativa
																	 ,pr_cdagenci => 0            --> Codigo da agencia
																	 ,pr_nrdcaixa => 0            --> Numero do caixa do operador
																	 ,pr_cdoperad => '1'          --> Codigo do Operador
																	 ,pr_nmdatela => 'EMPR0003'   --> Nome da tela
																	 ,pr_idorigem => 0            --> Identificador de Origem
																	 ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
																	 ,pr_idseqttl => 1            --> Sequencial do titular
																	 ,pr_tpctrato => 1            --> Emprestimo  
																	 ,pr_nrctrato => pr_nrctremp  --> Numero do contrato
																	 ,pr_nrctaav1 => 0            --> Numero da conta do primeiro avalista
																	 ,pr_nrctaav2 => 0            --> Numero da conta do segundo avalista
																		--------> OUT <--------                                   
																	 ,pr_tab_dados_avais => vr_tab_aval   --> retorna dados do avalista
																	 ,pr_cdcritic        => vr_cdcritic   --> Código da crítica
																	 ,pr_dscritic        => vr_dscritic); --> Descrição da crítica
				-- Se retornou erro
				IF NVL(vr_cdcritic,0) > 0 OR 
					 TRIM(vr_dscritic) IS NOT NULL THEN
					RAISE vr_exc_saida;
				-- Se possuir terceiro garantidor
				ELSIF vr_tab_aval.COUNT > 0 THEN
					vr_ind_add_item := 1;
			        
					-- Buscar Primeiro registro
					vr_ind_aval := vr_tab_aval.FIRST;
					-- Percorrer todos os registros
					WHILE vr_ind_aval IS NOT NULL LOOP
						-- monta descricao para o relatorio com os dados do emitente
						IF vr_tab_aval(vr_ind_aval).inpessoa = 1 THEN
						-- Se possuir conta
						IF nvl(vr_tab_aval(vr_ind_aval).nrctaava,0) > 0 THEN
							-- Busca estado civil e profissao
							OPEN  cr_gnetcvl(pr_cdcooper => pr_cdcooper,
															 pr_nrdconta => vr_tab_aval(vr_ind_aval).nrctaava); 
							FETCH cr_gnetcvl INTO rw_gnetcvl;
							CLOSE cr_gnetcvl;
						END IF;

						vr_tab_avl(vr_ind_aval).descricao := '<terceiro_0' || vr_ind_aval || '>'
																		   || vr_tab_aval(vr_ind_aval).nmdavali || ', ' 
																		   || (CASE WHEN TRIM(vr_tab_aval(vr_ind_aval).dsnacion) IS NOT NULL THEN 'nacionalidade '||LOWER(vr_tab_aval(vr_ind_aval).dsnacion) || ', ' ELSE '' END)
																		   || (CASE WHEN nvl(vr_tab_aval(vr_ind_aval).nrctaava,0) > 0 AND TRIM(rw_gnetcvl.dsproftl) IS NOT NULL THEN LOWER(rw_gnetcvl.dsproftl) || ', ' ELSE '' END)
																		   || (CASE WHEN nvl(vr_tab_aval(vr_ind_aval).nrctaava,0) > 0 AND TRIM(rw_gnetcvl.rsestcvl) IS NOT NULL THEN LOWER(rw_gnetcvl.rsestcvl) || ', ' ELSE '' END)
																		   || 'inscrito no CPF/CNPJ n° ' || gene0002.fn_mask_cpf_cnpj(vr_tab_aval(vr_ind_aval).nrcpfcgc, vr_tab_aval(vr_ind_aval).inpessoa) || ', '
																		   || 'residente e domiciliado(a) na ' || vr_tab_aval(vr_ind_aval).dsendere || ', '
																		   || 'n° '|| vr_tab_aval(vr_ind_aval).nrendere || ', bairro ' || vr_tab_aval(vr_ind_aval).dsendcmp || ', '
																		   || 'da cidade de ' || vr_tab_aval(vr_ind_aval).nmcidade || '/' || vr_tab_aval(vr_ind_aval).cdufresd || ', '
																		   || 'CEP ' || gene0002.fn_mask_cep(vr_tab_aval(vr_ind_aval).nrcepend)
																		   || (CASE WHEN vr_tab_aval(vr_ind_aval).nrctaava > 0 THEN ', titular da conta corrente n° ' || TRIM(gene0002.fn_mask_conta(vr_tab_aval(vr_ind_aval).nrctaava)) ELSE '' END)
																							|| (CASE WHEN rw_crawepr.dtmvtolt >= TO_DATE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdacesso => 'DT_VIG_IMP_CTR_V2'),'DD/MM/RRRR') THEN ', na condição de DEVEDOR SOLIDÁRIO' ELSE '' END)
																		   || '.</terceiro_0' || vr_ind_aval || '>';
						ELSE
							vr_tab_avl(vr_ind_aval).descricao := '<terceiro_0' || vr_ind_aval || '>'
																			   || vr_tab_aval(vr_ind_aval).nmdavali || ', '
																			   || 'inscrita no CNPJ sob n° '|| gene0002.fn_mask_cpf_cnpj(vr_tab_aval(vr_ind_aval).nrcpfcgc, vr_tab_aval(vr_ind_aval).inpessoa)
																			   || ' com sede na ' || vr_tab_aval(vr_ind_aval).dsendere || ', n° ' || vr_tab_aval(vr_ind_aval).nrendere || ', '
																			   || 'bairro ' || vr_tab_aval(vr_ind_aval).dsendcmp || ', da cidade de ' || vr_tab_aval(vr_ind_aval).nmcidade || '/' || vr_tab_aval(vr_ind_aval).cdufresd || ', '
																			   || 'CEP ' || gene0002.fn_mask_cep(vr_tab_aval(vr_ind_aval).nrcepend) 
																			   || (CASE WHEN vr_tab_aval(vr_ind_aval).nrctaava > 0 THEN ', conta corrente n° ' || TRIM(gene0002.fn_mask_conta(vr_tab_aval(vr_ind_aval).nrctaava)) ELSE '' END)
																								|| (CASE WHEN rw_crawepr.dtmvtolt >= TO_DATE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdacesso => 'DT_VIG_IMP_CTR_V2'),'DD/MM/RRRR') THEN ', na condição de DEVEDOR SOLIDÁRIO' ELSE '' END)
																			   || '.</terceiro_0' || vr_ind_aval || '>';
						END IF;

						-- Proximo Registro
						vr_ind_aval := vr_tab_aval.NEXT(vr_ind_aval);
					END LOOP;
				END IF;
			END IF;
			
      /*IF rw_craplcr.tplcremp <> 1 THEN  -- tipo de linha de credito <> 1=Normal
          vr_dscritic := 'Contrato fora do layout padrao';
          RAISE vr_exc_saida; -- encerra programa e retorna critica
      END IF ;*/
      -- Verifica se o documento eh um CPF ou CNPJ
      IF rw_crawepr.inpessoa = 1 THEN
        vr_tppessoa := 'CPF';
        OPEN cr_gnetcvl(pr_cdcooper, pr_nrdconta); -- busca estado civil
        FETCH cr_gnetcvl INTO rw_gnetcvl;
        CLOSE cr_gnetcvl;
              -- monta descricao para o relatorio com os dados do emitente
        vr_campo_01 := 'inscrito no '||vr_tppessoa||' n.° '|| gene0002.fn_mask_cpf_cnpj(rw_crawepr.nrcpfcgc, rw_crawepr.inpessoa)||
                     ' e portador do RG n.° '||SUBSTR(TRIM(rw_crawepr.nrdocptl),1,15)||', com o estado civil '||rw_gnetcvl.rsestcvl||
                     ', residente e domiciliado na '||rw_crapenc.dsendere||', n.° '||rw_crapenc.nrendere||
                     ', bairro '||rw_crapenc.nmbairro|| ', da cidade de '||rw_crapenc.nmcidade||'/'||rw_crapenc.cdufende||
                     ', CEP '||gene0002.fn_mask_cep(rw_crapenc.nrcepend)||', também  qualificado na proposta de abertura de conta corrente indicada no subitem ' ||
					 (2 + vr_ind_add_item) || '.1, designado Emitente.';
      ELSE -- pessoa juridica nao tem estado civil
        vr_tppessoa := 'CNPJ';
        -- monta descricao para o relatorio com os dados do emitente
        vr_campo_01 := 'inscrita no '||vr_tppessoa||' sob n.° '|| gene0002.fn_mask_cpf_cnpj(rw_crawepr.nrcpfcgc, rw_crawepr.inpessoa)||
                     ' com sede na '||rw_crapenc.dsendere||', n.° '||rw_crapenc.nrendere||
                     ', bairro '||rw_crapenc.nmbairro|| ', da cidade de '||rw_crapenc.nmcidade||'/'||rw_crapenc.cdufende||
                     ', CEP '||gene0002.fn_mask_cep(rw_crapenc.nrcepend)||', também  qualificado na proposta de abertura de conta corrente indicada no subitem ' ||
					 (2 + vr_ind_add_item) || '.1, designado Emitente.';
      END IF;

      IF rw_craplcr.flgcobmu = 1 THEN
        -- Busca o percentual de multa
        vr_prmulta := gene0002.fn_char_para_number(substr(tabe0001.fn_busca_dstextab( pr_cdcooper => 3
                                                                                     ,pr_nmsistem => 'CRED'
                                                                                     ,pr_tptabela => 'USUARI'
                                                                                     ,pr_cdempres => 11
                                                                                     ,pr_cdacesso => 'PAREMPCTL'
                                                                                     ,pr_tpregist => 1),1,5));
      ELSE
        vr_prmulta := 0;

      END IF;

      -- Busca os dados do emitente
      vr_emitente := rw_crapcop.nmextcop||' - '||rw_crapcop.nmrescop||', sociedade cooperativa de crédito, inscrita no CNPJ sob no. '||
                     gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)||', estabelecida na '||
                     rw_crapcop.dsendcop||' no. ' ||rw_crapcop.nrendcop|| ', bairro ' ||rw_crapcop.nmbairro||
                     ', CEP: '||gene0002.fn_mask_cep(rw_crapcop.nrcepend)||', cidade de '||rw_crapcop.nmcidade||
                     '-'||rw_crapcop.cdufdcop;

      IF rw_crawepr.tpemprst = 0 THEN -- TR
        vr_taxjream := rw_craplcr.txjurfix;
      ELSIF  rw_crawepr.tpemprst = 1 THEN -- Pre-fixado
        vr_taxjream := rw_craplcr.perjurmo;
     END IF;

     IF  vr_taxjream > 0 THEN -- taxa juros > 0
        vr_taxjrean := ROUND((POWER(1 + (vr_taxjream / 100),12) - 1) * 100,2);--calculo juros ano
     ELSE
        vr_taxjrean := 0;
     END IF;

     -- relatorio crrl100_03
      IF rw_craplcr.tpctrato IN (1,4) AND -- modelo = 1 NORMAL ou 4 = APLICAÇÃO
        rw_craplcr.cdusolcr = 0 AND -- codigo de uso = 0 Normal
        rw_crawepr.tpemprst = 1 AND -- Tipo PP
        rw_crawepr.inpessoa = 2 THEN -- pessoa juridica
        -- clausula 2 do relatorio
        vr_coment01 := '2. Empréstimo - O crédito ora aberto e aceito pelo Emitente é um empréstimo em dinheiro, tendo como origem recursos ' ||
                       'de fontes de Depósitos Interfinanceiros de Repasses – DIM , com pagamento em parcelas, na quantidade ' ||
                       'e valor contratados pelo Emitente, pelo que o Emitente.';
           vr_nmarqim := '/crrl100_03_'||pr_nrdconta||pr_nrctremp||'.pdf';   -- nome do relatorio + nr contrato
            -- titulo do relatorio
           vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO - EMPRÉSTIMO AO COOPERADO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') ;
           vr_dsjasper := 'crrl100_14.jasper'; -- nome do jasper

     -- relatorio crrl100_04
      ELSIF rw_craplcr.tpctrato IN (1,4) AND -- modelo = 1 NORMAL ou 4 = APLICAÇÃO
        rw_craplcr.cdusolcr = 0 AND -- codigo de uso = 0 Normal
        rw_crawepr.tpemprst = 1 AND -- Tipo PP
        rw_crawepr.inpessoa = 1 THEN -- pessoa fisica
        vr_coment01 := '2. Empréstimo - O crédito ora aberto e aceito pelo Emitente é um empréstimo em dinheiro, tendo como origem recursos ' ||
                      'de fontes de Depósitos Interfinanceiros de Repasses – DIM , com pagamento em parcelas, na quantidade ' ||
                      'e valor contratados pelo Emitente, pelo que o Emitente.';
        vr_nmarqim := '/crrl100_04_'||pr_nrdconta||pr_nrctremp||'.pdf';   -- nome do relatorio + nr contrato
        -- titulo do relatorio
        vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO - EMPRÉSTIMO AO COOPERADO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') ;
		-- Se for um contrato de portabilidade
        IF vr_portabilidade = TRUE THEN
          vr_dsjasper := 'crrl100_18_portab.jasper'; -- nome do jasper
        ELSE
		    vr_dsjasper := 'crrl100_18.jasper'; -- nome do jasper
        END IF;

     -- relatorios crrl100_11 / crrl100_10 ou crrl100_14
     ELSIF rw_craplcr.tpctrato = 1 AND -- MODELO: = 1 NORMAL
        rw_craplcr.cdusolcr = 0 AND -- codigo de uso = 0 Normal
        rw_crawepr.tpemprst = 0 THEN -- Tipo TR
        IF rw_crawepr.flgpagto <> 1 THEN -- consignado
           IF rw_craplcr.tpdescto = 2 THEN -- desconto = em folha
             vr_nmarqim := '/crrl100_11_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
             -- titulo do relatorio
             vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO-EMPRÉSTIMO AO COOPERADO–CONSIGNADO–COM INDEXADOR–No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') ;
             vr_dsjasper := 'crrl100_07.jasper'; -- nome do jasper
           ELSE -- desconto = conta corrente
             vr_nmarqim := '/crrl100_10_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
             -- titulo do relatorio
             vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO - EMPRÉSTIMO AO COOPERADO – COM INDEXADOR – No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') ;
             vr_dsjasper := 'crrl100_06.jasper'; -- nome do jasper
           END IF;
        ELSE -- folha
          vr_nmarqim := '/crrl100_14_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
          -- titulo do relatorio
          vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO-EMPRÉSTIMO AO COOPERADO – SALÁRIO – COM INDEXADOR–No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') ;
          vr_dsjasper := 'crrl100_09.jasper'; -- nome do jasper
        END IF;

     -- relatorios crrl100_12 ou crrl100_13
     ELSIF rw_craplcr.tpctrato = 1 AND -- MODELO: = 1 NORMAL
        rw_craplcr.cdusolcr = 1 AND -- codigo de uso = 1 Microcredito
        rw_crawepr.tpemprst = 0 THEN -- Tipo TR
        IF rw_craplcr.dsorgrec IN ('MICROCREDITO PNMPO BNDES','MICROCREDITO PNMPO BRDE', 'MICROCREDITO PNMPO BNDES AILOS') THEN -- Origem do recurso
            vr_nmarqim := '/crrl100_12_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
            vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO - EMPRÉSTIMO AO COOPERADO – MICROCRÉDITO – COM INDEXADOR No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
            vr_dsjasper := 'crrl100_08.jasper'; -- nome do jasper
        ELSE
           vr_nmarqim := '/crrl100_13_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
           -- titulo do relatorio
           vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO - EMPRÉSTIMO AO COOPERADO – MICROCRÉDITO – COM INDEXADOR No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
           vr_dsjasper := 'crrl100_17.jasper';  -- nome do jasper
        END IF;

     -- relatorios crrl100_02 e crrl100_09 e crrl100_16
      ELSIF rw_craplcr.tpctrato IN (2,4) AND -- MODELO: 2 ALIENAÇÃO ou 4 APLICAÇÃO
           rw_craplcr.cdusolcr = 0 THEN -- Cod Uso = NORMAL
        pc_busca_bens(pr_cdcooper => pr_cdcooper
                    , pr_nrdconta => pr_nrdconta
                    , pr_nrctremp => pr_nrctremp
                    , pr_cdagenci => rw_crapavi_01.cdagenci
                    );
        IF rw_crawepr.tpemprst = 1 THEN -- Tipo PP
          -- Se for bens móveis
          IF vr_tab_bens.exists(vr_tab_bens.first) AND
            vr_tab_bens(vr_tab_bens.first).dscatbem IN ('MAQUINA DE COSTURA','EQUIPAMENTO','MAQUINA E EQUIPAMENTO') THEN
            -- clausula 2 do relatorio
            vr_coment01 := '2. Financiamento - O crédito ora aberto e aceito pelo Emitente é um empréstimo em dinheiro, com pagamento em parcelas,'||
                           ' na quantidade e valor contratados pelo Emitente.';
            vr_nmarqim := '/crrl100_05_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
            -- titulo do relatorio
            vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO-FINANCIAMENTO COM ALIENAÇÃO FIDUCIÁRIA DE BENS MÓVEIS No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') ;
            vr_dsjasper := 'crrl100_02.jasper'; -- nome do jasper
            vr_bens := NULL;
           ELSE -- Se for veiculos
             vr_nmarqim := '/crrl100_09_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
			 -- Se for de portabilidade
             IF vr_portabilidade THEN
             -- Titulo do relatorio
                vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO-EMPRÉSTIMO COM ALIENAÇÃO FIDUCIÁRIA DE VEÍCULO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
                -- nome do jasper
                vr_dsjasper := 'crrl100_05_portab.jasper';
             ELSE
                -- Titulo do relatorio
             vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO-FINANCIAMENTO COM ALIENAÇÃO FIDUCIÁRIA DE VEÍCULO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
             -- nome do jasper
             vr_dsjasper := 'crrl100_05.jasper'; -- nome do jasper             
           END IF;
           END IF;
        ELSE -- TR
           vr_nmarqim := '/crrl100_16_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
           -- Titulo do relatorio
           vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO-FINANCIAMENTO COM ALIENAÇÃO FIDUCIÁRIA DE VEÍCULO–COM INDEXADOR No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
           vr_dsjasper := 'crrl100_11.jasper'; -- nome do jasper
        END IF;

     -- relatorio crrl100_06
      ELSIF rw_craplcr.tpctrato IN (3,4) AND -- MODELO: = 3 Hipoteca ou 4 Aplicação
        rw_craplcr.cdusolcr = 0 AND -- codigo de uso = 0 Normal
        rw_crawepr.tpemprst = 1 THEN -- Tipo PP
        -- clausula 2 do relatorio
        vr_coment01 := '2. Financiamento - O crédito ora aberto e aceito pelo Emitente é um empréstimo em dinheiro, com pagamento em parcelas,'||
                       ' na quantidade e valor contratados pelo Emitente.';
        vr_nmarqim := '/crrl100_06_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
        -- titulo do relatorio
        vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO-FINANCIAMENTO COM ALIENAÇÃO FIDUCIÁRIA DE IMÓVEL No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') ;
        vr_dsjasper := 'crrl100_03.jasper'; -- nome do jasper
        vr_bens := NULL;

        pc_busca_bens(pr_cdcooper => pr_cdcooper
                    , pr_nrdconta => pr_nrdconta
                    , pr_nrctremp => pr_nrctremp
                    , pr_cdagenci => rw_crapavi_01.cdagenci
                    );

     -- relatorio crrl100_07, crrl100_08, crrl100_17 ou crrl100_18
      ELSIF rw_craplcr.tpctrato IN (2,4) AND -- MODELO: 2 ALIENAÇÃO ou 4 Aplicação
           rw_craplcr.cdusolcr = 1 THEN -- Cod Uso = MICROCRÉDITO
       IF rw_crawepr.tpemprst = 1 THEN -- Tipo PP
           IF rw_craplcr.dsorgrec IN ('MICROCREDITO PNMPO BNDES','MICROCREDITO PNMPO BRDE', 'MICROCREDITO PNMPO BNDES AILOS') THEN -- Origem do recurso
             vr_nmarqim := '/crrl100_07_'||pr_nrdconta||pr_nrctremp||'.pdf';  -- nome do relatorio + nr contrato
             -- titulo do relatorio
             vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO-FINANCIAMENTO COM ALIENAÇÃO FIDUCIÁRIA DE VEÍCULO MICROCRÉDITO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
             vr_dsjasper := 'crrl100_04.jasper'; -- nome jasper
           ELSE
             vr_nmarqim := '/crrl100_08_'||pr_nrdconta||pr_nrctremp||'.pdf';  -- nome do relatorio + nr contrato
             -- titulo do relatorio
             vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO-FINANCIAMENTO COM ALIENAÇÃO FIDUCIÁRIA DE VEÍCULO MICROCRÉDITO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
             vr_dsjasper := 'crrl100_16.jasper'; -- nome jasper
           END IF;
       ELSE -- Tipo TR
          IF rw_craplcr.dsorgrec IN ('MICROCREDITO PNMPO BNDES','MICROCREDITO PNMPO BRDE', 'MICROCREDITO PNMPO BNDES AILOS') THEN -- Origem do recurso
              vr_nmarqim := '/crrl100_18_'||pr_nrdconta||pr_nrctremp||'.pdf';  -- nome do relatorio + nr contrato
              -- Titulo do relatorio
              vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO-FINANCIAMENTO COM ALIENAÇÃO FIDUCIÁRIA DE VEÍCULO MICROCRÉDITO–COM INDEXADOR No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
              vr_dsjasper := 'crrl100_13.jasper'; -- nome do jasper
          ELSE
              vr_nmarqim := '/crrl100_17_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
              -- Titulo do relatorio
              vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO-FINANCIAMENTO COM ALIENAÇÃO FIDUCIÁRIA DE VEÍCULO MICROCRÉDITO–COM INDEXADOR No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
              vr_dsjasper := 'crrl100_12.jasper'; -- nome do jasper
          END IF;
       END IF;

       pc_busca_bens(pr_cdcooper => pr_cdcooper
                   , pr_nrdconta => pr_nrdconta
                   , pr_nrctremp => pr_nrctremp
                   , pr_cdagenci => rw_crapavi_01.cdagenci
                   );

     -- relatorio crrl100_15
     ELSIF rw_craplcr.tpctrato = 3 AND -- MODELO: = 3 Hipoteca
        rw_craplcr.cdusolcr = 0 AND -- codigo de uso = 0 Normal
        rw_crawepr.tpemprst = 0 THEN -- Tipo TR
        vr_nmarqim := '/crrl100_15_'||pr_nrdconta||pr_nrctremp||'.pdf';  -- nome do relatorio + nr contrato
        -- Titulo do relatorio
        vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO-FINANCIAMENTO COM ALIENAÇÃO FIDUCIÁRIA DE IMÓVEL – COM INDEXADOR No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
        vr_dsjasper := 'crrl100_10.jasper'; -- nome do jasper
        vr_bens := NULL;
        pc_busca_bens(pr_cdcooper => pr_cdcooper
                    , pr_nrdconta => pr_nrdconta
                    , pr_nrctremp => pr_nrctremp
                    , pr_cdagenci => rw_crapavi_01.cdagenci
                    );

     -- relatorio crrl100_01
      ELSIF  rw_craplcr.tpctrato IN (1,4) AND -- MODELO: = 1 NORMAL ou 4 = APLICAÇÃO
        rw_crawepr.tpemprst = 1 AND -- Tipo PP
        rw_craplcr.cdusolcr = 1 AND -- codigo de uso = 1 Microcreditorw_craplcr.dsoperac IN ('FINANCIAMENTO', 'EMPRESTIMO') AND
        rw_craplcr.dsorgrec IN ('MICROCREDITO PNMPO BNDES','MICROCREDITO PNMPO BRDE', 'MICROCREDITO PNMPO BNDES AILOS') THEN -- Origem do recurso
       vr_nmarqim := '/crrl100_01_'||pr_nrdconta||pr_nrctremp||'.pdf';  -- nome do relatorio + nr contrato
       vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO - EMPRÉSTIMO AO COOPERADO MICROCRÉDITO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
       vr_dsjasper := 'crrl100_01.jasper';--nome do jasper

     -- relatorio crrl100_02
     ELSIF rw_craplcr.tpctrato = 1 AND -- MODELO: = 1 NORMAL
        rw_crawepr.tpemprst = 1 AND -- Tipo PP
        rw_craplcr.cdusolcr = 1 THEN -- codigo de uso = 1 Microcredito
       vr_nmarqim := '/crrl100_02_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
       -- titulo do relatorio
       vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO - EMPRÉSTIMO AO COOPERADO MICROCRÉDITO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
       vr_dsjasper := 'crrl100_15.jasper'; -- nome do jasper
     END IF;

      IF vr_nmarqim IS NULL OR vr_dsjasper IS NULL THEN -- se nome do relatorio for nullo, contrato esta fora do novo padrao
        vr_dscritic := 'Conta/Contrato fora do padrao de layout';--monta critica
        RAISE vr_exc_saida; -- encerra programa e retorna critica
      ELSE
          --> Buscar identificador para digitalização
          vr_dstextab :=  TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper, 
                                                     pr_nmsistem => 'CRED'      , 
                                                     pr_tptabela => 'GENERI'    , 
                                                     pr_cdempres => 00          , 
                                                     pr_cdacesso => 'DIGITALIZA', 
                                                     pr_tpregist => 5);

          IF TRIM(vr_dstextab) IS NULL THEN
            vr_dscritic := 'Falta registro na Tabela "DIGITALIZA".';
            RAISE vr_exc_saida;
          END IF;

          vr_cdtipdoc :=  gene0002.fn_busca_entrada(pr_postext => 3, 
                                                    pr_dstext  => vr_dstextab, 
                                                    pr_delimitador => ';');

          -- Gera o QR Code para uso da digitalizacao
          vr_qrcode   := pr_cdcooper ||'_'||
                         rw_crawepr.cdageepr ||'_'||
                         TRIM(gene0002.fn_mask_conta(pr_nrdconta))    ||'_'||
                         0           ||'_'||
                         TRIM(gene0002.fn_mask_contrato(pr_nrctremp)) ||'_'||
                         0           ||'_'||
                         vr_cdtipdoc;

          -- Busca a descricao do titulo e gera o arquivo XML ----------
          vr_digitalizacao := 'Conta: '   ||gene0002.fn_mask_conta(pr_nrdconta)  ||
                              '     Contrato: '||gene0002.fn_mask(pr_nrctremp,'99.999.999')||
                              '     Cód. Doc: '||lpad(rw_crawepr.cdagenci,3,'0');
          -- dados de atendimento da cooperativa, para uso na clausula de solucao amigavel do relatorio.
          vr_dados_coop := 'responsável pela sua conta. Está ainda à sua disposição o tele atendimento('||rw_crapcop.nrtelura||')'||', e o website ('||rw_crapcop.dsendweb||').'||
                           'Se não for solucionado o conflito, o Emitente poderá recorrer à Ouvidoria '||
                           rw_crapcop.nmrescop||'('||rw_crapcop.nrtelouv||'), em dias úteis(08h00min às 17h00min).';

          -- clausulas 1 para relatorio por cooperativa
          IF rw_crawepr.tpemprst = 1 THEN -- PP
            vr_campo_02 := 'Nas condições de vencimento indicadas nos subitens ' || (2 + vr_ind_add_item) || '.9. e ' || (2 + vr_ind_add_item) || '.10, '||
                           'o Emitente pagará por esta Cédula de Crédito Bancário, à '||rw_crapcop.nmextcop||' - '||rw_crapcop.nmrescop||
                           ', sociedade cooperativa de crédito, inscrita no CNPJ sob n.º '||gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)||
                           ', estabelecida na ' ||rw_crapcop.dsendcop||', n.º '||rw_crapcop.nrendcop||', bairro '||rw_crapcop.nmbairro||
                           ', CEP: '||gene0002.fn_mask_cep(rw_crapcop.nrcepend)||', cidade de '||rw_crapcop.nmcidade||'-'||rw_crapcop.cdufdcop||
                           ', designada Cooperativa, a dívida em dinheiro, certa, líquida e exigível correspondente ao '||
                           'valor total emprestado (subitem ' ||
							(2 + vr_ind_add_item) || '.3.).';
         ELSE
           vr_campo_02 := 'O Emitente pagará por esta Cédula de Crédito Bancário, à '||rw_crapcop.nmextcop||' - '||rw_crapcop.nmrescop||
                           ', sociedade cooperativa de crédito, inscrita no CNPJ sob n.º '||gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)||
                           ', estabelecida na ' ||rw_crapcop.dsendcop||', n.º '||rw_crapcop.nrendcop||', bairro '||rw_crapcop.nmbairro||
                           ', CEP: '||gene0002.fn_mask_cep(rw_crapcop.nrcepend)||', cidade de '||rw_crapcop.nmcidade||'-'||rw_crapcop.cdufdcop||
                           ', designada Cooperativa, a dívida em dinheiro, certa, líquida e exigível correspondente ao '||
                           'valor total emprestado (subitem 1.3.).';
          END IF;

          -- Incluir nome do modulo logado
          GENE0001.pc_informa_acesso(pr_module => 'ATENDA'
						                        ,pr_action => 'EMPR0003.pc_gera_xml_contrato_pp_tr'
                                    );

          -- busca primeiro registro quando houver bem
          vr_des_chave := vr_tab_bens.first;
          -- Verifica se relatorio possui bens
          IF vr_des_chave IS NOT NULL THEN
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, '<bens>');
            WHILE vr_des_chave IS NOT NULL LOOP  -- varre temp table de bens
              -- gera xml para cada bem encontrado
              if vr_tab_bens(vr_des_chave).dscatbem != 'MAQUINA E EQUIPAMENTO' then -- Paulo Martins - Alteração devido Maquinas e Equipamentos - 25/06/19
              gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                      '<bem>'||
                                      '  <veiculos>'      ||vr_bens                                 ||'</veiculos>'||
                                      '  <chassi>'        ||vr_tab_bens(vr_des_chave).dschassi      ||'</chassi>'||
                                      '  <placa>'         ||vr_tab_bens(vr_des_chave).nrdplaca      ||'</placa>'||
                                      '  <renavan>'       ||vr_tab_bens(vr_des_chave).nrrenava      ||'</renavan>'||
                                      '  <anomod>'        ||vr_tab_bens(vr_des_chave).dsanomod      ||'</anomod>'||
                                      '  <cor>'           ||vr_tab_bens(vr_des_chave).dscorbem      ||'</cor>'||
                                      '  <dsbem>'         ||'Descrição do bem: '||vr_tab_bens(vr_des_chave).dscatbem || ' ' ||
                                                             vr_tab_bens(vr_des_chave).dsbem        ||'</dsbem>'||
                                      '  <proprietario>'  ||vr_tab_bens(vr_des_chave).proprietario                 ||'</proprietario>'||
                                      '  <dados_pessoais>'||vr_tab_bens(vr_des_chave).dados_pessoais               ||'</dados_pessoais>'||
                                      '  <endereco>'      ||vr_tab_bens(vr_des_chave).endereco                     ||'</endereco>'||
                                      '  <conjuge>'       ||vr_tab_bens(vr_des_chave).conjuge                      ||'</conjuge>'||
                                      '  <avaliacao>'     ||'Avaliação: R$ '||to_char(vr_tab_bens(vr_des_chave).avaliacao,'FM999G999G999G990D00')||'</avaliacao>'||
                                      '</bem>');
              else
                gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                        '<bem>'||
                                        '  <veiculos>'      ||vr_bens                                 ||'</veiculos>'||
                                        '  <chassi>'        ||vr_tab_bens(vr_des_chave).dschassi      ||' '||            
                                                              vr_tab_bens(vr_des_chave).dsanomod      ||'</chassi>'||                                              
                                        '  <dsbem>'         ||'Descrição do bem: '||vr_tab_bens(vr_des_chave).dscatbem || ' ' ||
                                                               vr_tab_bens(vr_des_chave).dsbem||'</dsbem>'||
                                        '  <proprietario>'  ||vr_tab_bens(vr_des_chave).proprietario                 ||'</proprietario>'||
                                        '  <dados_pessoais>'||vr_tab_bens(vr_des_chave).dados_pessoais               ||'</dados_pessoais>'||
                                        '  <endereco>'      ||vr_tab_bens(vr_des_chave).endereco                     ||'</endereco>'||
                                        '  <conjuge>'       ||vr_tab_bens(vr_des_chave).conjuge                      ||'</conjuge>'||
                                        '  <avaliacao>'     ||'Avaliação: R$ '||to_char(vr_tab_bens(vr_des_chave).avaliacao,'FM999G999G999G990D00')||'</avaliacao>'||
                                        '</bem>');                
              end if;
              -- Buscar o proximo
              vr_des_chave := vr_tab_bens.NEXT(vr_des_chave);
              IF vr_des_chave IS NULL THEN
                gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, '</bens>');
              END IF;
            END LOOP;
          END IF;

          -- Verifica se relatorio possui mais de um interveniente
          vr_des_chave_interv := vr_tab_interv.first;
          IF vr_des_chave_interv IS NOT NULL THEN
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, '<intervenientes>');
            WHILE vr_des_chave_interv IS NOT NULL LOOP  -- varre temp table de bens
              -- gera xml para cada bem encontrado
              gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                      '<interveniente>'||
                                      '  <inprimei>'||vr_tab_interv(vr_des_chave_interv).inprimei||'</inprimei>'||
                                      '  <insegund>'||vr_tab_interv(vr_des_chave_interv).insegund||'</insegund>'||
                                      '</interveniente>');
              -- Buscar o proximo
              vr_des_chave_interv := vr_tab_interv.NEXT(vr_des_chave_interv);
              IF vr_des_chave_interv IS NULL THEN
                gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, '</intervenientes>');
              END IF;
            END LOOP;
          END IF;
          -- verificacao para impressao dos textos "nao negociavel" e "para uso da digitalizacao"
          IF nvl(pr_inimpctr,0) = 0 THEN
            vr_negociavel := 'N'; -- imprime "para uso da digitalizacao" e nao imprime "nao negociavel"
          ELSE
            vr_negociavel := 'S'; -- nao imprime "para uso da digitalizacao" e imprime "nao negociavel"
          END IF;
          
          -- Projeto 410 - SM - recalculo de IOF e tarifa para incluir no valor do emprestimo          
          OPEN  cr_crapepr;
          FETCH cr_crapepr INTO rw_crapepr;
          IF cr_crapepr%FOUND THEN
            CLOSE cr_crapepr;
            --vr_vlemprst := nvl(rw_crapepr.vlemprst,0) + nvl(rw_crapepr.vltarifa,0) + nvl(rw_crapepr.vliofepr,0);      
            vr_vlemprst := nvl(rw_crapepr.vlemprst,0);
          ELSE
            CLOSE cr_crapepr;
            
          vr_vlemprst := rw_crawepr.vlemprst;
          if rw_crawepr.idfiniof = 1 then
             vr_dscatbem := '';
             FOR rw_crapbpr IN cr_crapbpr LOOP
                 vr_dscatbem := vr_dscatbem || '|' || rw_crapbpr.dscatbem;
             END LOOP;
              
             -- Buscar iof
             TIOF0001.pc_calcula_iof_epr( pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_dtmvtolt => rw_crawepr.dtmvtolt
                                         ,pr_inpessoa => rw_crawepr.inpessoa
                                         ,pr_cdfinemp => rw_crawepr.cdfinemp
                                         ,pr_cdlcremp => rw_crawepr.cdlcremp
                                         ,pr_qtpreemp => rw_crawepr.qtpreemp
                                         ,pr_vlpreemp => rw_crawepr.vlpreemp
                                         ,pr_vlemprst => rw_crawepr.vlemprst
                                         ,pr_dtdpagto => rw_crawepr.dtdpagto
                                         ,pr_dtlibera => rw_crawepr.dtlibera
                                         ,pr_tpemprst => rw_crawepr.tpemprst
                                         ,pr_dtcarenc        => null
                                         ,pr_qtdias_carencia => null
                                         ,pr_valoriof => vr_vlrdoiof
                                         ,pr_dscatbem => vr_dscatbem
                                         ,pr_idfiniof => rw_crawepr.idfiniof
                                         ,pr_dsctrliq => rw_crawepr.dsctrliq
                                         ,pr_idgravar => 'N'
                                         ,pr_vlpreclc => vr_vlpreclc
                                         ,pr_vliofpri => vr_vliofpri
                                         ,pr_vliofadi => vr_vliofadi
                                         ,pr_flgimune => vr_flgimune
                                         ,pr_dscritic => vr_dscritic);
                                         
              -- VERIFICA SE OCORREU UMA CRITICA
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;
            
            -- Calcula tarifa
            TARI0001.pc_calcula_tarifa(pr_cdcooper => pr_cdcooper
                                     , pr_nrdconta => pr_nrdconta
                                     , pr_cdlcremp => rw_crawepr.cdlcremp
                                     , pr_vlemprst => rw_crawepr.vlemprst
                                     , pr_cdusolcr => rw_craplcr.cdusolcr 
                                     , pr_tpctrato => rw_craplcr.tpctrato
                                     , pr_dsbemgar => vr_dscatbem
                                     , pr_cdprogra => 'RelCET'
                                     , pr_flgemail => 'N'
                                     , pr_vlrtarif => vr_vlrtarif
                                     , pr_vltrfesp => vr_vlrtares
                                     , pr_vltrfgar => vr_vltarbem
                                     , pr_cdhistor => vr_cdhistor
                                     , pr_cdfvlcop => vr_cdfvlcop
                                     , pr_cdhisgar => vr_cdhistor
                                     , pr_cdfvlgar => vr_cdfvlcop
                                     , pr_cdcritic => vr_cdcritic
                                     , pr_dscritic => vr_dscritic);
            
            if vr_dscritic is not null then
               raise vr_exc_saida;
            end if;
            
            vr_vlrtarif := ROUND(nvl(vr_vlrtarif,0),2) + nvl(vr_vlrtares,0) + nvl(vr_vltarbem,0);
                                               
            -- valor total emprestado
            vr_vlemprst := nvl(rw_crawepr.vlemprst,0) + nvl(vr_vlrdoiof,0) + nvl(vr_vlrtarif,0);      
            end if;
          END IF;
       
          -- gera corpo do xml
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                 '<ind_add_item>'  || vr_ind_add_item                        || '</ind_add_item>' || -- Indicador se possui terceiro garantidor (0-Nao / 1-Sim)					
                                 '<versao>'        ||vr_nrversao                             ||'</versao>' ||
                                 '<digitalizacao>' ||vr_digitalizacao                        ||'</digitalizacao>'||
                                 '<dsqrcode>'      || vr_qrcode                              ||'</dsqrcode>'||
                                 '<titulo>'        ||vr_dstitulo                             || '</titulo>'||
                                 '<nmemitente>'    ||rw_crawepr.nmprimtl                     ||'</nmemitente>'||
                                 '<campo_01>'      ||vr_campo_01                             ||'</campo_01>'||
                                 '<campo_02>'||vr_campo_02                                   ||'</campo_02>'||
                                 '<pa>'      ||rw_crawepr.cdagenci                           ||'</pa>'||
                                 '<conta>'   ||gene0002.fn_mask_conta(pr_nrdconta)           ||'</conta>'||
                                 '<nrcnpjbase>'    ||nrcnpjbase_if_origem                                           ||'</nrcnpjbase>'||
                                 '<nrctrprt>'      ||nrcontrato_if_origem                                           ||'</nrctrprt>'||
                                 '<nmcredora>'     ||nomcredora_if_origem                    ||'</nmcredora>'||
                                 '<cnpjdacop>'     ||GENE0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj, 2)              ||'</cnpjdacop>'||
                                 --'<dtmvtolt>'||to_char(rw_crawepr.dtmvtolt,'dd/mm/yyyy')     ||'</dtmvtolt>'||
                                 '<dtmvtolt>'||to_char(rw_crawepr.dtaltpro,'dd/mm/yyyy')     ||'</dtmvtolt>'|| -- Rafael Ferreira (Mouts) - Story 19674
                                 '<vlemprst>'||'R$ '||to_char(vr_vlemprst,'FM99G999G990D00')||'</vlemprst>'||
                                 '<txminima>'||to_char(rw_crawepr.txminima,'FM990D00')||' %' ||'</txminima>'||  --% juros remuneratorios ao mes
                                 '<prjurano>'||to_char(rw_crawepr.prjurano ,'FM990D00')||' %'||'</prjurano>'|| --% juros remuneratorios ao ano
                                 '<dsperiod>'||'MENSAL'                                      ||'</dsperiod>'||
                                 '<taxjream>'||to_char(vr_taxjream, 'FM990D00')        ||' %'||'</taxjream>'||-- juros encargos mes
                                 '<taxjrean>'||to_char(vr_taxjrean, 'FM990D00')        ||' %'||'</taxjrean>'|| -- juros encargos ano
                                 '<dsatumon>'||'INPC/IBGE'                                   ||'</dsatumon>'||-- Atualização monetária por estimativa e projetada
                                 '<dslcremp>'||rw_craplcr.dslcremp||' ('||rw_crawepr.cdlcremp ||')'||'</dslcremp>'|| -- Linha de credito
                                 '<qtpreemp>'||rw_crawepr.qtpreemp                           ||'</qtpreemp>'||
                                 '<vlpreemp>'||'R$ '||to_char(rw_crawepr.vlpreemp,'fm99G999G990D00')||'</vlpreemp>'||
                                 '<diavenct>'||to_char(rw_crawepr.dtvencto,'DD')            ||'</diavenct>'||
                                 '<dtvencto>'||to_char(rw_crawepr.dtvencto,'DD/MM/YYYY')     ||'</dtvencto>'||
                                 '<ultvenct>'||to_char(add_months(rw_crawepr.dtvencto,rw_crawepr.qtpreemp -1),'dd/mm/yyyy')||'</ultvenct>'||
                                 '<perjurmo>'||to_char(rw_craplcr.perjurmo,'FM990D00')||' % ao mês' ||'</perjurmo>'||  --% juros moratorios
                                 '<prdmulta>'||to_char(vr_prmulta,'fm990d00')||' % sobre o valor da parcela vencida'||'</prdmulta>'|| -- % Multa sobre o valor da parcela vencida
                                 '<qttolatr>'||rw_crawepr.qttolatr||' dias corridos, contados do vencimento da parcela não paga'||'</qttolatr>'|| -- Dias de tolerancia de atraso
                                 '<origem>'  ||rw_crawepr.nmcidade||'-'||rw_crawepr.cdufdcop ||'</origem>'  || -- Local Origem
                                 '<destino>' ||rw_crawepr.nmcidade||'-'||rw_crawepr.cdufdcop ||'</destino>' || -- Local destino
                                 '<percetop>'||to_char(vr_txanocet,'fm990d00')||' %' ||'</percetop>'|| -- Custo efetivo total ao ano
                                 '<emitente>'||vr_emitente                                   ||'</emitente>'||
                                 '<coment01>'||vr_coment01                                   ||'</coment01>'||
                                 '<nrtelura>'||rw_crapcop.nrtelura                           ||'</nrtelura>'|| -- Telefone Atendimento
                                 '<nmrescop>'||rw_crapcop.nmrescop                           ||'</nmrescop>'|| -- Nome curto da empresa
                                 '<nrtelouv>'||rw_crapcop.nrtelouv                           ||'</nrtelouv>'|| -- Telefone ouvidoria
                                 '<dsendweb>'||rw_crapcop.dsendweb                           ||'</dsendweb>'|| -- Endereco web
                                 '<nmaval01>'||vr_nmdavali1                                  ||'</nmaval01>'|| -- Nome do avalista 1
                                 '<docava01>'||rw_crapavi_01.dspessoa                        ||'</docava01>'|| -- Tipo do documento(CPF ou CNPJ)
                                 '<cpfava01>'||vr_nrcpfcgc1                                  ||'</cpfava01>'|| -- cpf do avalista 1
                                 '<endava01>'||vr_dsendres1                                  ||'</endava01>'|| -- Endereco avalista 1
                                 '<celava01>'||vr_nrfonres1                                  ||'</celava01>'|| -- Telefone avalista 1
                                 '<nmaval02>'||trim(vr_nmdavali2)                            ||'</nmaval02>'|| -- Nome do avalista 2
                                 '<docava02>'||rw_crapavi_02.dspessoa                        ||'</docava02>'|| -- Tipo do documento(CPF ou CNPJ)
                                 '<cpfava02>'||vr_nrcpfcgc2                                  ||'</cpfava02>'||-- cpf do avalista 2
                                 '<endava02>'||vr_dsendres2                                  ||'</endava02>'|| -- Endereco avalista 2
                                 '<celava02>'||vr_nrfonres2                                  ||'</celava02>'||  -- Telefone avalista 2
                                 '<nmcjg01>'||trim(vr_nmconjug1)                             ||'</nmcjg01>'||  -- nome do conjuge 1
                                 '<cpfcjg01>'||vr_nrcpfcjg1                                  ||'</cpfcjg01>'|| -- cpf conjuge 1
                                 '<endcjg01>'||vr_dsendres1                                  ||'</endcjg01>'|| -- endereco conjuge 1
                                 '<celcjg01>'||vr_nrfonres1                                  ||'</celcjg01>'|| -- telefone conjuge 1
                                 '<nmcjg02>'||trim(vr_nmconjug2)                             ||'</nmcjg02>'||  -- nome do conjuge 2
                                 '<cpfcjg02>'||vr_nrcpfcjg2                                  ||'</cpfcjg02>'|| -- cpf conjuge 2
                                 '<endcjg02>'||vr_dsendres2                                  ||'</endcjg02>'|| -- endereco conjuge 2
                                 '<celcjg02>'||vr_nrfonres2                                  ||'</celcjg02>'|| -- telefone conjuge 2
                                 '<nrctremp>'||gene0002.fn_mask(pr_nrctremp,'99.999.999')    ||'</nrctremp>'|| -- contrato
                                 '<amigalvel>'||vr_dados_coop                                ||'</amigalvel>'|| -- dados de atendimento da coop para clausula de solucao amigavel
                                 '<flginterv>'||vr_flginterv                                 ||'</flginterv>'|| -- Indica se deve ou nao imprimir a linha de assinatura do interveniente
                                 '<negociavel>'||vr_negociavel                               ||'</negociavel>'|| -- Indicador de impressao do texto "nao negociavel"
								  vr_tab_avl(1).descricao ||
								  vr_tab_avl(2).descricao															 
                                 , TRUE);
      END IF;

      IF vr_dscritic IS NOT NULL THEN -- verifica erro na finalizacao do xml
        RAISE vr_exc_saida; -- encerra programa
      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);

      -- Saida de Valores
      pr_des_xml  := vr_des_xml;
      pr_dsjasper := vr_dsjasper;
      pr_nmarqimp := vr_nmarqim;

      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := SQLERRM;

    END pc_gera_xml_contrato_pp_tr;

  /* Monta o XML do contrato POS-FIXADO */
  PROCEDURE pc_gera_xml_contrato_pos(pr_cdcooper  IN crapepr.cdcooper%TYPE --> Codigo da Cooperativa
                                    ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Numero da conta do emprestimo
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Numero do contrato de emprestimo
                                    ,pr_inimpctr  IN INTEGER               --> Impressao Nao Negociavel (0 - Nao / 1 - Sim)
                                    ,pr_dsjasper OUT VARCHAR2              --> Nome do Jasper
                                    ,pr_nmarqimp OUT VARCHAR2              --> Nome do arquivo PDF
                                    ,pr_des_xml  OUT CLOB                  --> XML gerado
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    /* ..........................................................................................................

       Programa: pc_gera_xml_contrato_pos
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Junho/2017                         Ultima atualizacao: 12/04/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Gerar XML do contrato de emprestimo POS-FIXADO

       Alteracoes: 01/02/2018 - Ajustes na geração do XML de contratos. (Jaison/James - PRJ298)
                  
                   12/04/2018 - P410 - Melhorias/Ajustes IOF (Marcos-Envolti)

                   27/11/2018 - Correção dos parâmetros de taxa de juros para serem apresentados corretamente 
                                (proposta efetivada) na Opção Imprimir / Contratos da tela Atenda / Prestações.
				                        Chamado INC0027935 - Gabriel (Mouts).
                  
                   20/12/2018 - Correção da taxa CET para buscar da tabela de CET quando existir registro
                	 						  INC0029082 (Douglas Pagel / AMcom).

                   05/04/2019 - Ajuste (INC0029082) busca da taxa CET: 
                                estava considerando apenas inpessoa =1 e recisa buscar para inpessoa = 2 também
                		 					  INC0011321 (Ana Volles).	 

                   10/01/2019 - P298 - Alteração dos parâmetros da taxa de juros,
                               Custo efetivo financeiro, percentual do custo financeiro. (Anderson-Alan Supero)
                  
    .......................................................................................................... */

      -- Cursor sobre as informacoes de emprestimo
      CURSOR cr_crapepr IS
        SELECT crapepr.vltarifa,
               crapepr.vliofepr,
               crapepr.vlemprst
        FROM crapepr
        WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;

      CURSOR cr_crawepr IS
        SELECT crawepr.cdfinemp,
               crawepr.cdlcremp,
               crawepr.dtmvtolt,
               crawepr.dtdpagto,
               crawepr.vlemprst,
               crawepr.qtpreemp,
               crawepr.dtvencto,
               crawepr.percetop,
               crawepr.vlperidx,
			   crawepr.idcobope,
               crapass.inpessoa,
               crapass.nrcpfcgc,
               crapass.nrdocptl,
               crapass.cdagenci,
               crapass.cdnacion,
               crawepr.cdagenci cdageepr,
               crawepr.txmensal,
               crapass.nmprimtl,
               crapage.nmcidade,
               crapage.cdufdcop,
               crapind.nmdindex,
               craplcr.txjurvar,
               CASE 
                 WHEN crawepr.tpatuidx = 1 THEN 'DIARIO'
                 WHEN crawepr.tpatuidx = 2 THEN 'QUINZENAL'
                 WHEN crawepr.tpatuidx = 3 THEN 'MENSAL'
               END dsperiod,
               'MENSAL' dsperpag,
               UPPER(tbepr_posfix_param_carencia.dscarencia) dscarencia,
               crawepr.dtcarenc,
               DECODE(crapepr.dtmvtolt, NULL, crapdat.dtmvtolt, crapepr.dtmvtolt) dtcalcul,
               DECODE(crapepr.dtmvtolt, NULL, crawepr.dtlibera, crapepr.dtmvtolt) dtefetiv,
               tbepr_posfix_param_carencia.qtddias,
               crawepr.idfiniof,
               crawepr.vlpreemp,
               crawepr.dtlibera,
               crawepr.tpemprst,
               crawepr.txminima,
               ROUND((POWER(1 + (crawepr.txminima / 100),12) - 1) * 100,2) prjurano,
                crawepr.nrctrliq##1 || ',' ||
                crawepr.nrctrliq##2 || ',' ||
                crawepr.nrctrliq##3 || ',' ||
                crawepr.nrctrliq##4 || ',' ||
                crawepr.nrctrliq##5 || ',' ||
                crawepr.nrctrliq##6 || ',' ||
                crawepr.nrctrliq##7 || ',' ||
                crawepr.nrctrliq##8 || ',' ||
                crawepr.nrctrliq##9 || ',' ||
                crawepr.nrctrliq##10 dsctrliq,
                crawepr.dtaltpro -- Rafael Ferreira (Mouts) - Story 19674
          FROM crawepr
     LEFT JOIN crapepr
            ON crapepr.cdcooper = crapepr.cdcooper
           AND crapepr.nrdconta = crawepr.nrdconta
           AND crapepr.nrctremp = crawepr.nrctremp
          JOIN crapass
            ON crapass.cdcooper = crawepr.cdcooper
           AND crapass.nrdconta = crawepr.nrdconta
          JOIN crapage
            ON crapage.cdcooper = crapass.cdcooper
           AND crapage.cdagenci = crapass.cdagenci
          JOIN crapind
            ON crapind.cddindex = crawepr.cddindex
          JOIN craplcr
            ON craplcr.cdcooper = crawepr.cdcooper
           AND craplcr.cdlcremp = crawepr.cdlcremp
          JOIN tbepr_posfix_param_carencia
            ON tbepr_posfix_param_carencia.idcarencia = crawepr.idcarenc
          JOIN crapdat
            ON crapdat.cdcooper = crawepr.cdcooper
         WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta
           AND crawepr.nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;--armazena informacoes do cursor cr_crawepr

      -- Busca a Nacionalidade
      CURSOR cr_crapnac(pr_cdnacion IN crapnac.cdnacion%TYPE) IS
        SELECT crapnac.dsnacion
          FROM crapnac
         WHERE crapnac.cdnacion = pr_cdnacion;
      rw_crapnac cr_crapnac%ROWTYPE;--armazena informacoes do cursor cr_crapnac

      -- Cursor para buscar estado civil da pessoa fisica, jurida nao tem
      CURSOR cr_gnetcvl(pr_cdcooper crapttl.cdcooper%TYPE
                       ,pr_nrdconta crapttl.nrdconta%TYPE) IS
        SELECT gnetcvl.rsestcvl,
               crapttl.dsproftl
         FROM  crapttl,
               gnetcvl
         WHERE crapttl.cdcooper = pr_cdcooper
           AND crapttl.nrdconta = pr_nrdconta
           AND crapttl.idseqttl = 1 -- Primeiro Titular
           AND gnetcvl.cdestcvl = crapttl.cdestcvl;
      rw_gnetcvl cr_gnetcvl%ROWTYPE;--armazena informacoes do cursor cr_gnetcvl

      -- Cursor sobre o cadastro de linhas de credito (tela LCREDI)
      CURSOR cr_craplcr(pr_cdlcremp craplcr.cdlcremp%TYPE) IS
        SELECT dslcremp,
               txminima,
               ROUND((POWER(1 + (txminima / 100),12) - 1) * 100,2) prjurano,
               perjurmo,
               tpctrato,
               flgcobmu,
               cdusolcr
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;--armazena informacoes do cursor cr_craplcr

      -- Cursor sobre o endereco do associado
      CURSOR cr_crapenc(pr_inpessoa crapass.inpessoa%TYPE) IS
        SELECT crapenc.dsendere,
               crapenc.nrendere,
               crapenc.nmbairro,
               crapenc.nmcidade,
               crapenc.cdufende,
               crapenc.nrcepend
          FROM crapenc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND idseqttl = 1
           AND tpendass = CASE
                          WHEN pr_inpessoa = 1 THEN
                            10 --Residencial
                          ELSE
                            9 -- Comercial
                          END;
      rw_crapenc cr_crapenc%ROWTYPE;--armazena informacoes do cursor cr_crapenc

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmextcop
              ,cop.nmrescop
              ,cop.nrdocnpj
              ,cop.dsendcop
              ,cop.nrendcop
              ,cop.nmbairro
              ,cop.nrcepend
              ,cop.nmcidade
              ,cop.cdufdcop
              ,cop.nrtelura
              ,cop.nrtelouv
              ,cop.dsendweb
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE; --armazena informacoes do cursor cr_crapcop

      -- Busca dados do interveniente
      CURSOR cr_interv(pr_cdcooper crapavt.cdcooper%TYPE
                      ,pr_nrdconta crapavt.nrdconta%TYPE
                      ,pr_nrctremp crapavt.nrctremp%TYPE) IS
        SELECT nmdavali
          FROM crapavt
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND tpctrato = 9;

      --> Buscar conjuge
      CURSOR cr_crapcje (pr_cdcooper IN crapcje.cdcooper%TYPE,
                         pr_nrdconta IN crapcje.nrdconta%TYPE )IS
        SELECT nvl(trim(cje.nmconjug),ass.nmprimtl) nmconjug
			  ,cje.nrcpfcjg
          FROM crapcje cje,
               crapass ass
         WHERE cje.cdcooper = ass.cdcooper(+)
           AND cje.nrctacje = ass.nrdconta(+)
           AND cje.cdcooper = pr_cdcooper
           AND cje.nrdconta = pr_nrdconta
           AND cje.idseqttl = 1; 
      rw_crapcje cr_crapcje%ROWTYPE;

      -- Verificar se possui interveniente garantidor
	  CURSOR cr_cobertura(pr_idcobert IN tbgar_cobertura_operacao.idcobertura%TYPE) IS
        SELECT 1
          FROM tbgar_cobertura_operacao tco
         WHERE tco.idcobertura = pr_idcobert
		   AND tco.nrconta_terceiro > 0;
	  rw_cobertura cr_cobertura%ROWTYPE;
      
     -- Projeto 410 - 14/03/2018 - SM - buscar bens da proposta (Jean - Mout´S) 
     CURSOR cr_crapbpr IS 
        SELECT t.dscatbem
          FROM crapbpr t
         WHERE t.cdcooper = pr_cdcooper
               AND t.nrdconta = pr_nrdconta
               AND t.nrctrpro = pr_nrctremp;
         rw_crapbpr cr_crapbpr%ROWTYPE;
              
     -- Verificar se dados do CET já foram gravados
      CURSOR cr_tbepr_calculo_cet is
        SELECT *
          FROM tbepr_calculo_cet t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta
           AND t.nrctremp = pr_nrctremp;
      rw_tbepr_calculo_cet cr_tbepr_calculo_cet%ROWTYPE;
              
      -- Tabela temporaria para o descritivo dos avais
      TYPE typ_reg_avl IS RECORD(descricao VARCHAR2(4000));
      TYPE typ_tab_avl IS TABLE OF typ_reg_avl INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os riscos
      vr_tab_avl typ_tab_avl;

      -- Tratamento de erros
      vr_exc_saida      EXCEPTION;
      vr_cdcritic       PLS_INTEGER;
      vr_dscritic       VARCHAR2(4000);

      -- Variaveis que serao convertidas para TAGs no XML
      vr_dstitulo       VARCHAR2(200);  --> Titulo do contrato
      vr_credora        VARCHAR2(500);  --> Campo com os dados da credora
      vr_emitente       VARCHAR2(500);  --> Endereco do emitente da cooperativa
      vr_nmarqimp       VARCHAR2(50);   --> Nome do arquivo PDF
      vr_nminterv       VARCHAR2(50);   --> Nome do interveniente
      vr_bens           INTEGER := 1;   --> Para listar informacoes dos bens

      -- Variaveis gerais
      vr_texto_completo VARCHAR2(32600);              --> Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_des_xml        CLOB;                         --> XML do relatorio
      vr_prmulta        NUMBER(7,2) := 0;             --> Percentual de multa
      vr_dsjasper       VARCHAR2(100);                --> nome do jasper a ser usado
      vr_dados_coop     VARCHAR(290);                 --> dados de contato da coop, para uso na clausula "Solucao Amigavel"
      vr_cdc            crapprm.dsvlrprm%TYPE;        --> String com valores de linha CDC
      vr_negociavel     VARCHAR2(1);                  --> Identificados para impressao dos textos "Para uso da digitalizacao" e "nao negociavel"
      vr_qrcode         VARCHAR2(100);                --> QR Code para uso da digitalizacao
      vr_cdtipdoc       INTEGER;                      --> Codigo do tipo de documento
      vr_dstextab       craptab.dstextab%TYPE;        --> Descritivo da tab
      vr_ind_add_item   INTEGER := 0;                 --> Indicador se possui terceiro garantidor (0-Nao / 1-Sim)
      vr_ind_add_bem    INTEGER := 0;                 --> Indicador se possui bem como garantia (0-Nao / 1-Sim)
      vr_tab_aval       DSCT0002.typ_tab_dados_avais; --> PL Table dos avalistas
      vr_ind_aval       PLS_INTEGER;                  --> Indice da PL Table
      vr_vlpreemp       NUMBER;                       --> Valor da parcela
      vr_vljurcor	      NUMBER;                       --> Valor do juros de correcao
      vr_vlminpre       NUMBER;                       --> Valor minimo da parcela
      vr_perjurmo       NUMBER;                       --> Juro mora
	    vr_nrcpfcgc       VARCHAR2(50);                 --> CPF/CNPJ do emitente
	    vr_nrcpfcjg       VARCHAR2(50);                 --> CPF do conjuge
      vr_txanocet       NUMBER := 0;                  --> taxa anual do cet

      -- Projeto 410 - 14/03/2018 - SM - Verificar informaçoes de IOF e tarifa
      vr_vlpreclc       NUMBER := 0;                -- Parcela calcula
      vr_dscatbem       varchar2(1000);
      vr_vlemprst       number;
      vr_vlrdoiof       number;
      vr_vlrtarif       number;
      vr_vlrtares       number;
      vr_vltarbem       number;
      vr_vliofpri       number;
      vr_vliofadi       number;
      vr_flgimune PLS_INTEGER;
      vr_tpctrato NUMBER := 0;                -- Tipo de contrato
      vr_cdhisbem NUMBER := 0;                -- Hostorico do bem
      vr_cdhistor NUMBER := 0;                -- Historico
      vr_cdusolcr NUMBER := 0;                -- Uso linha de credito
      vr_vlfinanc NUMBER := 0;
      vr_cdfvlcop crapfco.cdfvlcop%TYPE;
	  -- Variáveis de portabilidade
      nrcnpjbase_if_origem VARCHAR2(100);
      nrcontrato_if_origem VARCHAR2(100);
      nomcredora_if_origem VARCHAR2(100);
      vr_retxml            xmltype;
      vr_portabilidade     BOOLEAN := FALSE;
    BEGIN
      -- Abre o cursor com as informacoes da cooperativa
      OPEN  cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;

      -- Abre o cursor com as informacoes do emprestimo
      OPEN  cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      CLOSE cr_crawepr;

      -- Busca os dados do cadastro de linhas de credito
      OPEN  cr_craplcr(rw_crawepr.cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      CLOSE cr_craplcr;

      vr_cdc := fn_verifica_cdc(pr_cdcooper => pr_cdcooper
                               ,pr_dslcremp => rw_craplcr.dslcremp);
      IF vr_cdc = 'S' THEN
        vr_dscritic := 'Impressao de CCB nao permitida para linhas de CDC';
        RAISE vr_exc_saida;
      END IF;

      -- Busca os dados do endereco residencial do associado
      OPEN  cr_crapenc(rw_crawepr.inpessoa);
      FETCH cr_crapenc INTO rw_crapenc;
      -- Se nao encontrar o endereco finaliza o programa
      IF cr_crapenc%NOTFOUND THEN
        vr_dscritic := 'Endereco do associado nao encontrada para impressao'; -- monta critica
        CLOSE cr_crapenc;
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapenc;
      
      -- Verificacao para impressao dos textos "nao negociavel"
      IF nvl(pr_inimpctr,0) = 0 THEN
        vr_negociavel := 'N'; -- Nao imprime
      ELSE
        vr_negociavel := 'S'; -- Imprime
      END IF;
      
			-- Se possuir cobertura e data for superior ao do novo contrato
			IF rw_crawepr.idcobope > 0 AND
				 rw_crawepr.dtmvtolt >= TO_DATE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
																																 ,pr_cdacesso => 'DT_VIG_IMP_CTR_V2'),'DD/MM/RRRR') THEN
				--> Garantia Operacoes de Credito
				OPEN  cr_cobertura(pr_idcobert => rw_crawepr.idcobope);
				FETCH cr_cobertura INTO rw_cobertura;
				-- Se encontrou
				IF cr_cobertura%FOUND THEN
					-- Atribui flag de interveniente garantidor
					vr_ind_add_item := 1;
				END IF;
				CLOSE cr_cobertura;
      END IF;			
			
      -- Busca os dados da credora
      vr_credora := rw_crapcop.nmextcop||' - '||rw_crapcop.nmrescop||', sociedade Credora/Cooperativa de crédito, inscrita no CNPJ sob n° '||
                    gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)||', estabelecida na '||
                    rw_crapcop.dsendcop||' n° ' ||rw_crapcop.nrendcop|| ', bairro ' ||rw_crapcop.nmbairro||
                    ', CEP: '||gene0002.fn_mask_cep(rw_crapcop.nrcepend)||', cidade de '||rw_crapcop.nmcidade||
                    '-'||rw_crapcop.cdufdcop;

      -- Capturar CPF/CNPJ
      vr_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(rw_crawepr.nrcpfcgc, rw_crawepr.inpessoa);

      --INC0011321 - não considerar inpessoa para buscar vr_txanocet
      --Checar se existe informações de CET gerado na efetivação
      OPEN cr_tbepr_calculo_cet;
      FETCH cr_tbepr_calculo_cet 
       INTO rw_tbepr_calculo_cet;
      IF cr_tbepr_calculo_cet%FOUND THEN
        -- Usaremos as informações da tabela
        vr_txanocet := rw_tbepr_calculo_cet.txanocet;
      ELSE
        vr_txanocet := rw_crawepr.percetop;
      END IF;						
      CLOSE cr_tbepr_calculo_cet;
			
      -- Verifica se o documento eh um CPF ou CNPJ
      IF rw_crawepr.inpessoa = 1 THEN
        -- Busca estado civil e profissao
        OPEN  cr_gnetcvl(pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta); 
        FETCH cr_gnetcvl INTO rw_gnetcvl;
        CLOSE cr_gnetcvl;

        -- Busca a Nacionalidade
        OPEN  cr_crapnac(pr_cdnacion => rw_crawepr.cdnacion);
        FETCH cr_crapnac INTO rw_crapnac;
        CLOSE cr_crapnac;

        -- monta descricao para o relatorio com os dados do emitente
        vr_emitente := rw_crawepr.nmprimtl || ', ' 
                    || (CASE WHEN TRIM(rw_crapnac.dsnacion) IS NOT NULL THEN 'nacionalidade '||LOWER(rw_crapnac.dsnacion) || ', ' ELSE '' END)
                    || (CASE WHEN TRIM(rw_gnetcvl.dsproftl) IS NOT NULL THEN LOWER(rw_gnetcvl.dsproftl) || ', ' ELSE '' END)
                    || (CASE WHEN TRIM(rw_gnetcvl.rsestcvl) IS NOT NULL THEN LOWER(rw_gnetcvl.rsestcvl) || ', ' ELSE '' END)
                    || 'inscrito(a) no CPF sob n° ' || gene0002.fn_mask_cpf_cnpj(rw_crawepr.nrcpfcgc, rw_crawepr.inpessoa) || ', '
                    || 'portador(a) do RG n° ' || rw_crawepr.nrdocptl || ', residente e domiciliado(a) na ' || rw_crapenc.dsendere || ', '
                    || 'n° '|| rw_crapenc.nrendere || ', bairro ' || rw_crapenc.nmbairro || ', '
                    || 'da cidade de ' || rw_crapenc.nmcidade || '/' || rw_crapenc.cdufende || ', '
                    || 'CEP ' || gene0002.fn_mask_cep(rw_crapenc.nrcepend) || ', '
                    || 'titular da conta corrente n° ' || TRIM(gene0002.fn_mask_conta(pr_nrdconta)) || '.';
      ELSE
        -- monta descricao para o relatorio com os dados do emitente
        vr_emitente := rw_crawepr.nmprimtl || ', inscrita no CNPJ sob n° '|| gene0002.fn_mask_cpf_cnpj(rw_crawepr.nrcpfcgc, rw_crawepr.inpessoa)
                    || ' com sede na ' || rw_crapenc.dsendere || ', n° ' || rw_crapenc.nrendere || ', '
                    || 'bairro ' || rw_crapenc.nmbairro || ', da cidade de ' || rw_crapenc.nmcidade || '/' || rw_crapenc.cdufende || ', '
                    || 'CEP ' || gene0002.fn_mask_cep(rw_crapenc.nrcepend) || ', conta corrente n° ' || TRIM(gene0002.fn_mask_conta(pr_nrdconta)) || '.';
      END IF;

      -- Reseta as variaveis
      vr_tab_avl(1).descricao := '';
      vr_tab_avl(2).descricao := '';

      -- Listar avalistas de contratos
      DSCT0002.pc_lista_avalistas(pr_cdcooper => pr_cdcooper  --> Codigo da Cooperativa
                                 ,pr_cdagenci => 0            --> Codigo da agencia
                                 ,pr_nrdcaixa => 0            --> Numero do caixa do operador
                                 ,pr_cdoperad => '1'          --> Codigo do Operador
                                 ,pr_nmdatela => 'EMPR0003'   --> Nome da tela
                                 ,pr_idorigem => 0            --> Identificador de Origem
                                 ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
                                 ,pr_idseqttl => 1            --> Sequencial do titular
                                 ,pr_tpctrato => 1            --> Emprestimo  
                                 ,pr_nrctrato => pr_nrctremp  --> Numero do contrato
                                 ,pr_nrctaav1 => 0            --> Numero da conta do primeiro avalista
                                 ,pr_nrctaav2 => 0            --> Numero da conta do segundo avalista
                                  --------> OUT <--------                                   
                                 ,pr_tab_dados_avais => vr_tab_aval   --> retorna dados do avalista
                                 ,pr_cdcritic        => vr_cdcritic   --> Código da crítica
                                 ,pr_dscritic        => vr_dscritic); --> Descrição da crítica
      -- Se retornou erro
      IF NVL(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      -- Se possuir terceiro garantidor
      ELSIF vr_tab_aval.COUNT > 0 THEN
        vr_ind_add_item := 1;
        
        -- Buscar Primeiro registro
        vr_ind_aval := vr_tab_aval.FIRST;
        -- Percorrer todos os registros
        WHILE vr_ind_aval IS NOT NULL LOOP
          -- monta descricao para o relatorio com os dados do emitente
          IF vr_tab_aval(vr_ind_aval).inpessoa = 1 THEN
          -- Se possuir conta
          IF nvl(vr_tab_aval(vr_ind_aval).nrctaava,0) > 0 THEN
            -- Busca estado civil e profissao
            OPEN  cr_gnetcvl(pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => vr_tab_aval(vr_ind_aval).nrctaava); 
            FETCH cr_gnetcvl INTO rw_gnetcvl;
            CLOSE cr_gnetcvl;
          END IF;

          vr_tab_avl(vr_ind_aval).descricao := '<terceiro_0' || vr_ind_aval || '>'
                                            || vr_tab_aval(vr_ind_aval).nmdavali || ', ' 
                                            || (CASE WHEN TRIM(vr_tab_aval(vr_ind_aval).dsnacion) IS NOT NULL THEN 'nacionalidade '||LOWER(vr_tab_aval(vr_ind_aval).dsnacion) || ', ' ELSE '' END)
                                            || (CASE WHEN nvl(vr_tab_aval(vr_ind_aval).nrctaava,0) > 0 AND TRIM(rw_gnetcvl.dsproftl) IS NOT NULL THEN LOWER(rw_gnetcvl.dsproftl) || ', ' ELSE '' END)
                                            || (CASE WHEN nvl(vr_tab_aval(vr_ind_aval).nrctaava,0) > 0 AND TRIM(rw_gnetcvl.rsestcvl) IS NOT NULL THEN LOWER(rw_gnetcvl.rsestcvl) || ', ' ELSE '' END)
                                            || 'inscrito no CPF/CNPJ n° ' || gene0002.fn_mask_cpf_cnpj(vr_tab_aval(vr_ind_aval).nrcpfcgc, vr_tab_aval(vr_ind_aval).inpessoa) || ', '
                                            || 'residente e domiciliado(a) na ' || vr_tab_aval(vr_ind_aval).dsendere || ', '
                                            || 'n° '|| vr_tab_aval(vr_ind_aval).nrendere || ', bairro ' || vr_tab_aval(vr_ind_aval).dsendcmp || ', '
                                            || 'da cidade de ' || vr_tab_aval(vr_ind_aval).nmcidade || '/' || vr_tab_aval(vr_ind_aval).cdufresd || ', '
                                            || 'CEP ' || gene0002.fn_mask_cep(vr_tab_aval(vr_ind_aval).nrcepend)
                                            || (CASE WHEN vr_tab_aval(vr_ind_aval).nrctaava > 0 THEN ', titular da conta corrente n° ' || TRIM(gene0002.fn_mask_conta(vr_tab_aval(vr_ind_aval).nrctaava)) ELSE '' END)
																						|| (CASE WHEN rw_crawepr.dtmvtolt >= TO_DATE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdacesso => 'DT_VIG_IMP_CTR_V2'),'DD/MM/RRRR') THEN ', na condição de DEVEDOR SOLIDÁRIO' ELSE '' END)
                                              || '.</terceiro_0' || vr_ind_aval || '>';
          ELSE
            vr_tab_avl(vr_ind_aval).descricao := '<terceiro_0' || vr_ind_aval || '>'
                                              || vr_tab_aval(vr_ind_aval).nmdavali || ', '
                                              || 'inscrita no CNPJ sob n° '|| gene0002.fn_mask_cpf_cnpj(vr_tab_aval(vr_ind_aval).nrcpfcgc, vr_tab_aval(vr_ind_aval).inpessoa)
                                              || ' com sede na ' || vr_tab_aval(vr_ind_aval).dsendere || ', n° ' || vr_tab_aval(vr_ind_aval).nrendere || ', '
                                              || 'bairro ' || vr_tab_aval(vr_ind_aval).dsendcmp || ', da cidade de ' || vr_tab_aval(vr_ind_aval).nmcidade || '/' || vr_tab_aval(vr_ind_aval).cdufresd || ', '
                                              || 'CEP ' || gene0002.fn_mask_cep(vr_tab_aval(vr_ind_aval).nrcepend) 
                                              || (CASE WHEN vr_tab_aval(vr_ind_aval).nrctaava > 0 THEN ', conta corrente n° ' || TRIM(gene0002.fn_mask_conta(vr_tab_aval(vr_ind_aval).nrctaava)) ELSE '' END)
																							|| (CASE WHEN rw_crawepr.dtmvtolt >= TO_DATE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdacesso => 'DT_VIG_IMP_CTR_V2'),'DD/MM/RRRR') THEN ', na condição de DEVEDOR SOLIDÁRIO' ELSE '' END)
                                              || '.</terceiro_0' || vr_ind_aval || '>';
          END IF;

          vr_tab_avl(vr_ind_aval).descricao := vr_tab_avl(vr_ind_aval).descricao
                                            || '<nmaval0' || vr_ind_aval || '>' || vr_tab_aval(vr_ind_aval).nmdavali || '</nmaval0' || vr_ind_aval || '>'
                                            || '<cpfava0' || vr_ind_aval || '>' || gene0002.fn_mask_cpf_cnpj(vr_tab_aval(vr_ind_aval).nrcpfcgc, vr_tab_aval(vr_ind_aval).inpessoa) || '</cpfava0' || vr_ind_aval || '>';
                                            
          -- Se pessoa fisica, imprimir dados do conjuge --BUG 14436 - Rubens
          IF vr_tab_aval(vr_ind_aval).inpessoa = 1 THEN
                   vr_tab_avl(vr_ind_aval).descricao := vr_tab_avl(vr_ind_aval).descricao                                            
                                            || '<nmcjg0'  || vr_ind_aval || '>' || vr_tab_aval(vr_ind_aval).nmconjug || '</nmcjg0' || vr_ind_aval || '>'
                                            || '<cpfcjg0' || vr_ind_aval || '>' || gene0002.fn_mask_cpf_cnpj(vr_tab_aval(vr_ind_aval).nrcpfcjg, 1) || '</cpfcjg0' || vr_ind_aval || '>';
          END IF;                                                                                                

          -- Proximo Registro
          vr_ind_aval := vr_tab_aval.NEXT(vr_ind_aval);
        END LOOP;
      END IF;

      -- Buscar identificador para digitalizacao
      vr_dstextab :=  TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED'      , 
                                                 pr_tptabela => 'GENERI'    , 
                                                 pr_cdempres => 00          , 
                                                 pr_cdacesso => 'DIGITALIZA', 
                                                 pr_tpregist => 5);
      IF TRIM(vr_dstextab) IS NULL THEN
        vr_dscritic := 'Falta registro na Tabela "DIGITALIZA".';
        RAISE vr_exc_saida;
      END IF;

      vr_cdtipdoc :=  gene0002.fn_busca_entrada(pr_postext => 3, 
                                                pr_dstext  => vr_dstextab, 
                                                pr_delimitador => ';');

      -- Gera o QR Code para uso da digitalizacao
      vr_qrcode   := pr_cdcooper ||'_'||
                     rw_crawepr.cdageepr ||'_'||
                     TRIM(gene0002.fn_mask_conta(pr_nrdconta))    ||'_'||
                     0           ||'_'||
                     TRIM(gene0002.fn_mask_contrato(pr_nrctremp)) ||'_'||
                     0           ||'_'||
                     vr_cdtipdoc;

      IF rw_craplcr.flgcobmu = 1 THEN
        -- Busca o percentual de multa
        vr_prmulta := gene0002.fn_char_para_number(substr(tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                                                                    ,pr_nmsistem => 'CRED'
                                                                                    ,pr_tptabela => 'USUARI'
                                                                                    ,pr_cdempres => 11
                                                                                    ,pr_cdacesso => 'PAREMPCTL'
                                                                                    ,pr_tpregist => 1),1,5));
      END IF;

      -- Buscaremos as informacoes do interveniente
      OPEN cr_interv(pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrctremp => pr_nrctremp);
      FETCH cr_interv INTO vr_nminterv;
      CLOSE cr_interv;

      -- Buscar dados de portabilidade
      CECRED.empr0006.pc_consulta_portabil_crt(pr_cdcooper   => pr_cdcooper
                                              ,pr_nrdconta   => pr_nrdconta
                                              ,pr_nrctremp   => pr_nrctremp
                                              ,pr_tpoperacao => 1
                                              ,pr_cdcritic   => vr_cdcritic
                                              ,pr_dscritic   => vr_dscritic
                                              ,pr_retxml     => vr_retxml);
                                               
      IF vr_retxml.existsNode('/Dados/inf/nrcnpjbase_if_origem') > 0 AND
         vr_retxml.existsNode('/Dados/inf/nrcontrato_if_origem') > 0 THEN
        vr_portabilidade := TRUE;
        nrcnpjbase_if_origem := TRIM(vr_retxml.extract('/Dados/inf/nrcnpjbase_if_origem/text()').getstringval());
        nrcontrato_if_origem := TRIM(vr_retxml.extract('/Dados/inf/nrcontrato_if_origem/text()').getstringval());
        nomcredora_if_origem := TRIM(vr_retxml.extract('/Dados/inf/nmif_origem/text()').getstringval());
      ELSE
        nrcnpjbase_if_origem := '';
        nrcontrato_if_origem := '';
        nomcredora_if_origem := '';
      END IF;

      -- MODELO VEICULOS
      IF rw_craplcr.tpctrato = 2 THEN
        IF vr_portabilidade THEN
          vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO - EMPRÉSTIMO AO COOPERADO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') || ' PÓS – FIXADO<br>PORTABILIDADE DE CRÉDITO';
          vr_dsjasper := 'crrl100_2'  || (CASE WHEN TRIM(vr_nminterv) IS NULL THEN '4' ELSE '5' END) || '_portab.jasper';
          vr_nmarqimp := '/crrl100_2' || (CASE WHEN TRIM(vr_nminterv) IS NULL THEN '4' ELSE '5' END) || '_' || pr_nrdconta || pr_nrctremp || '_portab.pdf';
        ELSE
          vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO - EMPRÉSTIMO AO COOPERADO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') || ' PÓS – FIXADO';
          vr_dsjasper := 'crrl100_2'  || (CASE WHEN TRIM(vr_nminterv) IS NULL THEN '4' ELSE '5' END) || '.jasper';
          vr_nmarqimp := '/crrl100_2' || (CASE WHEN TRIM(vr_nminterv) IS NULL THEN '4' ELSE '5' END) || '_' || pr_nrdconta || pr_nrctremp || '.pdf';
        END IF;
      -- MODELO IMOVEIS
      ELSIF rw_craplcr.tpctrato = 3 THEN
        IF vr_portabilidade THEN
          vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO - FINANCIAMENTO COM ALIENAÇÃO FIDUCIÁRIA DE IMÓVEL No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') || ' PÓS – FIXADO<br>PORTABILIDADE DE CRÉDITO';
          vr_dsjasper := 'crrl100_2'  || (CASE WHEN TRIM(vr_nminterv) IS NULL THEN '2' ELSE '3' END) || '_portab.jasper';
          vr_nmarqimp := '/crrl100_2' || (CASE WHEN TRIM(vr_nminterv) IS NULL THEN '2' ELSE '3' END) || '_' || pr_nrdconta || pr_nrctremp || '_portab.pdf';
        ELSE
          vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO - FINANCIAMENTO COM ALIENAÇÃO FIDUCIÁRIA DE IMÓVEL No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') || ' PÓS – FIXADO';
          vr_dsjasper := 'crrl100_2'  || (CASE WHEN TRIM(vr_nminterv) IS NULL THEN '2' ELSE '3' END) || '.jasper';
          vr_nmarqimp := '/crrl100_2' || (CASE WHEN TRIM(vr_nminterv) IS NULL THEN '2' ELSE '3' END) || '_' || pr_nrdconta || pr_nrctremp || '.pdf';
        END IF;
      -- MODELO NORMAL
      ELSE
        IF vr_portabilidade THEN
          vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO - EMPRÉSTIMO AO COOPERADO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') || ' PÓS – FIXADO<br>PORTABILIDADE DE CRÉDITO';
          vr_dsjasper := 'crrl100_26_portab.jasper';
          vr_nmarqimp := '/crrl100_26_' || pr_nrdconta || pr_nrctremp || '_portab.pdf';
        ELSE
          vr_dstitulo := 'CÉDULA DE CRÉDITO BANCÁRIO - EMPRÉSTIMO AO COOPERADO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') || ' PÓS – FIXADO';
          vr_dsjasper := 'crrl100_26.jasper';
          vr_nmarqimp := '/crrl100_26_' || pr_nrdconta || pr_nrctremp || '.pdf';
        END IF;
      END IF;

      -- Caso seja VEICULOS ou IMOVEIS
      IF rw_craplcr.tpctrato IN (2,3) THEN
        vr_bens := NULL;
        pc_busca_bens(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp
                     ,pr_cdagenci => 1);
      END IF;

      -- Dados de atendimento da cooperativa, para uso na clausula de solucao amigavel do relatorio
      vr_dados_coop := 'Está ainda à sua disposição o tele atendimento(' || rw_crapcop.nrtelura || ')' 
                    || ', e o website (' || rw_crapcop.dsendweb || '). '
                    || 'Se não for solucionado o conflito, o Emitente/Cooperado(a) poderá recorrer à Ouvidoria '
                    || rw_crapcop.nmrescop || '(' || rw_crapcop.nrtelouv || '), em dias úteis(08h00min às 17h00min).';

      
      IF rw_crawepr.inpessoa = 1 THEN
        --> Buscar conjuge
        rw_crapcje := NULL;
        OPEN cr_crapcje (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta);
      
        FETCH cr_crapcje INTO rw_crapcje;
        CLOSE cr_crapcje;
        -- Capturar CPF do conjuge				
	     	vr_nrcpfcjg := gene0002.fn_mask_cpf_cnpj(rw_crapcje.nrcpfcjg, 1);
      END IF;
      
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'ATENDA'
                                ,pr_action => 'EMPR0003.pc_gera_xml_contrato_pos');

      -- Inicializar o CLOB
      vr_des_xml := NULL;
      vr_texto_completo := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Busca primeiro registro quando houver bem
      vr_des_chave := vr_tab_bens.first;
      -- Verifica se relatorio possui bens
      IF vr_des_chave IS NOT NULL THEN
        vr_ind_add_bem := 1;
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, '<bens>');
        WHILE vr_des_chave IS NOT NULL LOOP  -- varre temp table de bens
          -- Gera xml para cada bem encontrado
          
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                  '<bem>'              ||
                                  '  <veiculos>'       || vr_bens                                                    || '</veiculos>'       ||
                                  '  <chassi>'         || vr_tab_bens(vr_des_chave).dschassi                         || '</chassi>'         ||
                                  '  <placa>'          || vr_tab_bens(vr_des_chave).nrdplaca                         || '</placa>'          ||
                                  '  <renavan>'        || vr_tab_bens(vr_des_chave).nrrenava                         || '</renavan>'        ||
                                  '  <anomod>'         || vr_tab_bens(vr_des_chave).dsanomod                         || '</anomod>'         ||
                                  '  <cor>'            || vr_tab_bens(vr_des_chave).dscorbem                     	   || '</cor>'            ||
                                  '  <dsbem>'          || 'Descrição do bem: ' || vr_tab_bens(vr_des_chave).dscatbem || ' '                 ||
                                                           vr_tab_bens(vr_des_chave).dsbem                           || '</dsbem>'          ||
                                  '  <proprietario>'   || vr_tab_bens(vr_des_chave).proprietario                     || '</proprietario>'   ||
                                  '  <dados_pessoais>' || vr_tab_bens(vr_des_chave).dados_pessoais                    || '</dados_pessoais>' ||
                                  '  <endereco>'       || vr_tab_bens(vr_des_chave).endereco                         || '</endereco>'       ||
                                  '  <conjuge>'        || vr_tab_bens(vr_des_chave).conjuge                          || '</conjuge>'        ||
                                  '  <avaliacao>'      || 'Avaliação: R$ '||to_char(vr_tab_bens(vr_des_chave).avaliacao,'FM999G999G999G990D00') || '</avaliacao>' ||
                                  '</bem>');
          -- Buscar o proximo
          vr_des_chave := vr_tab_bens.NEXT(vr_des_chave);
          IF vr_des_chave IS NULL THEN
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, '</bens>');
          END IF;
        END LOOP;
      END IF;

      OPEN  cr_crapepr;
      FETCH cr_crapepr INTO rw_crapepr;
      IF cr_crapepr%FOUND THEN
         CLOSE cr_crapepr;
         --vr_vlemprst := nvl(rw_crapepr.vlemprst,0) + nvl(rw_crapepr.vltarifa,0) + nvl(rw_crapepr.vliofepr,0);      
         vr_vlemprst := nvl(rw_crapepr.vlemprst,0);
      ELSE
         CLOSE cr_crapepr;
         vr_vlemprst := rw_crawepr.vlemprst;

       -- Projeto 410 - SM - recalculo de IOF e tarifa para incluir no valor do emprestimo          
          if rw_crawepr.idfiniof = 1 then
             vr_dscatbem := '';
             FOR rw_crapbpr IN cr_crapbpr LOOP
                 vr_dscatbem := vr_dscatbem || '|' || rw_crapbpr.dscatbem;
             END LOOP;
              
             -- Buscar iof
             TIOF0001.pc_calcula_iof_epr( pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_dtmvtolt => rw_crawepr.dtmvtolt
                                         ,pr_inpessoa => rw_crawepr.inpessoa
                                         ,pr_cdfinemp => rw_crawepr.cdfinemp
                                         ,pr_cdlcremp => rw_crawepr.cdlcremp
                                         ,pr_qtpreemp => rw_crawepr.qtpreemp
                                         ,pr_vlpreemp => rw_crawepr.vlpreemp
                                         ,pr_vlemprst => rw_crawepr.vlemprst
                                         ,pr_dtdpagto => rw_crawepr.dtdpagto
                                         ,pr_dtlibera => rw_crawepr.dtlibera
                                         ,pr_tpemprst => rw_crawepr.tpemprst
                                         ,pr_dtcarenc        => rw_crawepr.dtcarenc
                                         ,pr_qtdias_carencia => rw_crawepr.qtddias
                                         ,pr_valoriof => vr_vlrdoiof
                                         ,pr_dscatbem => vr_dscatbem
                                         ,pr_idfiniof => rw_crawepr.idfiniof
                                         ,pr_dsctrliq => rw_crawepr.dsctrliq
                                         ,pr_idgravar => 'N'
                                         ,pr_vlpreclc => vr_vlpreclc
                                         ,pr_vliofpri => vr_vliofpri
                                         ,pr_vliofadi => vr_vliofadi
                                         ,pr_flgimune => vr_flgimune
                                         ,pr_dscritic => vr_dscritic);
                                         
              -- VERIFICA SE OCORREU UMA CRITICA
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;
            
            -- Calcula tarifa
            TARI0001.pc_calcula_tarifa(pr_cdcooper => pr_cdcooper
                                     , pr_nrdconta => pr_nrdconta
                                     , pr_cdlcremp => rw_crawepr.cdlcremp
                                     , pr_vlemprst => rw_crawepr.vlemprst
                                     , pr_cdusolcr => rw_craplcr.cdusolcr 
                                     , pr_tpctrato => rw_craplcr.tpctrato
                                     , pr_dsbemgar => vr_dscatbem
                                     , pr_cdprogra => 'RelCET'
                                     , pr_flgemail => 'N'
                                     , pr_vlrtarif => vr_vlrtarif
                                     , pr_vltrfesp => vr_vlrtares
                                     , pr_vltrfgar => vr_vltarbem
                                     , pr_cdhistor => vr_cdhistor
                                     , pr_cdfvlcop => vr_cdfvlcop
                                     , pr_cdhisgar => vr_cdhistor
                                     , pr_cdfvlgar => vr_cdfvlcop
                                     , pr_cdcritic => vr_cdcritic
                                     , pr_dscritic => vr_dscritic);
            
            if vr_dscritic is not null then
               raise vr_exc_saida;
            end if;
            
            vr_vlrtarif := ROUND(nvl(vr_vlrtarif,0),2) + nvl(vr_vlrtares,0) + nvl(vr_vltarbem,0);
                                               
            -- valor total emprestado
            vr_vlemprst := nvl(rw_crawepr.vlemprst,0) + nvl(vr_vlrdoiof,0) + nvl(vr_vlrtarif,0);      
       end if;
     END IF;
     
     -- Chama o calculo da parcela
      EMPR0011.pc_busca_prest_principal_pos(pr_cdcooper        => pr_cdcooper
                                           ,pr_dtefetiv        => rw_crawepr.dtefetiv
                                           ,pr_dtcalcul        => rw_crawepr.dtcalcul
                                           ,pr_cdlcremp        => rw_crawepr.cdlcremp
                                           ,pr_dtcarenc        => rw_crawepr.dtcarenc
                                           ,pr_dtdpagto        => rw_crawepr.dtdpagto
                                           ,pr_qtpreemp        => rw_crawepr.qtpreemp
                                           ,pr_vlemprst        => vr_vlemprst
                                           ,pr_qtdias_carencia => rw_crawepr.qtddias
                                           ,pr_vlpreemp        => vr_vlpreemp
                                           ,pr_vljurcor        => vr_vljurcor
                                           ,pr_cdcritic        => vr_cdcritic
                                           ,pr_dscritic        => vr_dscritic);
      -- Se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
       
      -- Seta valor minimo
      vr_vlminpre := NVL(vr_vlpreemp,0) - NVL(vr_vljurcor,0);
  
      vr_perjurmo := nvl(rw_crawepr.txmensal,0) + nvl(rw_craplcr.perjurmo,0);

      -- Gera corpo do xml
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                             '<ind_add_item>' || vr_ind_add_item                             || '</ind_add_item>' || -- Indicador se possui terceiro garantidor (0-Nao / 1-Sim)
                             '<ind_add_bem>'  || vr_ind_add_bem                              || '</ind_add_bem>'  || -- Indicador se possui bem como garantia (0-Nao / 1-Sim)
                             '<negociavel>'   || vr_negociavel                               || '</negociavel>'   || -- Indicador de impressao do texto "nao negociavel"
                             '<titulo><![CDATA['       || vr_dstitulo                        || ']]></titulo>'    ||
                             '<dsqrcode>'     || vr_qrcode                                   || '</dsqrcode>'     ||
                             '<credora>'      || vr_credora                                  || '</credora>'      ||
                             '<emitente>'     || vr_emitente                                 || '</emitente>'     ||
							 '<nrcpfcgc>'     || vr_nrcpfcgc                                 || '</nrcpfcgc>'     ||
                             '<nmemitente>'   || rw_crawepr.nmprimtl                         || '</nmemitente>'   ||
                             '<nminterven>'   || vr_nminterv                                 || '</nminterven>'   ||
                             '<nmconjug>'     || TRIM(rw_crapcje.nmconjug)                   || '</nmconjug>'     ||                             
							 '<nrcpfcjg>'     || vr_nrcpfcjg                                 || '</nrcpfcjg>'     ||
                             '<conta>'        || TRIM(gene0002.fn_mask_conta(pr_nrdconta))   || '</conta>'        ||
                             '<pa>'           || rw_crawepr.cdagenci                         || '</pa>'           ||
                             '<vlemprst>'     || 'R$ '|| to_char(vr_vlemprst,'FM99G999G990D00')  || '</vlemprst>' ||
                             '<dslcremp>'     || rw_craplcr.dslcremp || ' ('|| rw_crawepr.cdlcremp ||')' || '</dslcremp>' || -- Linha de credito
                             '<origem>'       || rw_crawepr.nmcidade || '- '|| rw_crawepr.cdufdcop       || '</origem>'   || -- Local Origem
                             '<destino>'      || rw_crawepr.nmcidade || '-' || rw_crawepr.cdufdcop       || '</destino>'  || -- Local destino
                             --'<dtmvtolt>'     || to_char(rw_crawepr.dtmvtolt,'dd/mm/yyyy')               || '</dtmvtolt>' ||
                             '<dtmvtolt>'||to_char(rw_crawepr.dtaltpro,'dd/mm/yyyy')     ||'</dtmvtolt>'|| -- Rafael Ferreira (Mouts) - Story 19674
                             '<txminima>'     || to_char(rw_crawepr.txminima,'FM990D00') || ' %'         || '</txminima>' || -- % juros remuneratorios ao mes
                             '<prjurano>'     || to_char(rw_crawepr.prjurano,'FM990D00') || ' %'         || '</prjurano>' || -- % juros remuneratorios ao ano
                             '<percetop>'     || to_char(vr_txanocet,'fm990d00') || ' %'         || '</percetop>' || -- Custo efetivo total ao ano
                             '<ultvenct>'     || to_char(add_months(rw_crawepr.dtvencto,rw_crawepr.qtpreemp -1),'dd/mm/yyyy')     || '</ultvenct>' ||
                             '<perjurmo>'     || to_char(vr_perjurmo,'FM990D00') || ' % ao mês sobre o valor em atraso'   || '</perjurmo>' || -- % juros moratorios
                             '<prdmulta>'     || to_char(vr_prmulta,'fm990d00')          || ' % sobre o valor da parcela vencida' || '</prdmulta>' || -- % Multa sobre o valor da parcela vencida
                             '<dsperiod>'     || rw_crawepr.dsperiod                         || '</dsperiod>'     ||
                             '<dsperpag>'     || rw_crawepr.dsperpag                         || '</dsperpag>'     ||
                             '<qtpreemp>'     || rw_crawepr.qtpreemp                         || '</qtpreemp>'     ||
                             '<dtvencto>'     || to_char(rw_crawepr.dtvencto,'DD/MM/YYYY')   || '</dtvencto>'     ||
                             '<diavenct>'     || to_char(rw_crawepr.dtvencto,'DD')           || '</diavenct>'     ||
                             '<amigavel>'     || vr_dados_coop                               || '</amigavel>'     || -- dados de atendimento da coop para clausula de solucao amigavel
                             '<dscusfin>'     || rw_crawepr.nmdindex                         || '</dscusfin>'     ||
                             '<pccusfin>'     || to_char(rw_crawepr.vlperidx,'FM990D00') || ' %' || '</pccusfin>' ||
                             '<vlminpre>'     || 'R$ ' || to_char(vr_vlminpre,'FM99G999G990D00') || ' + ' || to_char(rw_crawepr.vlperidx,'FM990D00') || '% do ' || rw_crawepr.nmdindex || '</vlminpre>' ||
                             '<dtpagcar>'     || rw_crawepr.dscarencia                       || '</dtpagcar>'     ||
                             '<dtpricar>'     || nvl(to_char(rw_crawepr.dtcarenc,'DD/MM/YYYY'),UPPER('Sem carência'))   || '</dtpricar>'     ||
							 '<dsdcredo>'     || nomcredora_if_origem || ' ' || nrcnpjbase_if_origem || '</dsdcredo>' ||
                             '<nrctrpor>'     || nrcontrato_if_origem || '</nrctrpor>' ||

                             vr_tab_avl(1).descricao ||
                             vr_tab_avl(2).descricao
                             , TRUE);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);

      -- Saida de Valores
      pr_des_xml  := vr_des_xml;
      pr_dsjasper := vr_dsjasper;
      pr_nmarqimp := vr_nmarqimp;

      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := SQLERRM;

  END pc_gera_xml_contrato_pos;

  /* Busca dos pagamentos das parcelas de empréstimo */
  PROCEDURE pc_imprime_contrato_xml(pr_cdcooper IN crapcop.cdcooper%TYPE              --> Codigo da Cooperativa
                                   ,pr_nrdconta IN crapepr.nrdconta%TYPE              --> Numero da conta do emprestimo
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE              --> Numero do contrato de emprestimo
                                   ,pr_inimpctr IN INTEGER DEFAULT 0                  --> Impressao de contratos nao negociaveis
                                   ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2                          --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS                      --> Erros do processo
    /* .............................................................................

       Programa: pc_imprime_contrato_xml
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago Castro (RKAM)
       Data    : Agosto/2014.                         Ultima atualizacao: 12/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Efetuar a impressao do contrato de emprestimo

       Alteracoes: 05/01/2015 - (Chamado 229247) - Novo relatorio incluido nos
                                contratos de emprestimos (Tiago Castro - RKAM).
                                
                   09/06/2015 - (Projeto 209)
                                - Bloquear impressao de contratos
                                  com linha de credito CDC.
                                - Inluido contador de impressoes de contratos.
                                - Incluido novo parametro para impressao de contratos
                                  nao negociaveis.
                                - Inclusao de novo campo no XML dos contratos para
                                  ser enviado o valor do novo parametro.
                                  (Tiago Castro - RKAM)
                                  
                   26/11/2015 - Adicionado nova validacao de origem 
                                "MICROCREDITO PNMPO BNDES CECRED" conforme solicitado
                                no chamado 360165 (Kelvin)             
                                no chamado 360165 (Kelvin)
                                
                    24/08/2016 - (Projeto 343)
                               - Adicionada varíavel para verificação de  versão para 
                                 impressão de novos parágros nos contratos de forma condicional; 
                                 (Ricardo Linhares)             

                   26/06/2017 - Removido chamada pc_XML_para_arquivo pois era desnecessario
                                (Tiago/Rodrigo).

                   25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                     crapass, crapttl, crapjur 
							    (Adriano - P339).

                   09/05/2017 - Passagem do codigo da Finalidade.
                                Separacao da impressao dos contratos. (Jaison/James - PRJ298)

					12/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                     crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
							    (Adriano - P339).
    ............................................................................. */

      -- Cursor sobre as informacoes de emprestimo
      CURSOR cr_crawepr IS
        SELECT crawepr.cdfinemp,
               crawepr.cdlcremp,
               crawepr.vlemprst,
               crawepr.qtpreemp,
               crawepr.vlpreemp,
               crapass.inpessoa,
               crawepr.tpemprst,
               crawepr.dtlibera,
               crawepr.dtdpagto,
               crawepr.txmensal,
               crawepr.nrseqrrq,
               crawepr.idfiniof,
               crawepr.dtmvtolt,               
               crawepr.idcobope
          FROM crapass,
               crawepr
         WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta
           AND crawepr.nrctremp = pr_nrctremp
           AND crapass.cdcooper = crawepr.cdcooper
           AND crapass.nrdconta = crawepr.nrdconta;
      rw_crawepr cr_crawepr%ROWTYPE;--armazena informacoes do cursor cr_crawepr

      -- Cursor sobre as informacoes de emprestimo
      CURSOR cr_crapepr IS
        SELECT dtmvtolt, vltarifa, vliofepr
          FROM crapepr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;--armazena informacoes do cursor cr_crapepr

      -- Garantia Operacoes de Credito
      CURSOR cr_cobertura (pr_idcobert IN tbgar_cobertura_operacao.idcobertura%TYPE) IS
        SELECT tco.perminimo,
               tco.nrconta_terceiro,
               tco.inresgate_automatico,
               tco.qtdias_atraso_permitido
          FROM tbgar_cobertura_operacao tco
         WHERE tco.idcobertura = pr_idcobert;
      rw_cobertura cr_cobertura%ROWTYPE;

      -- Cursor para buscar nome do titular da conta
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
			                 ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
				SELECT ass.nmprimtl,
				       ass.nrcpfcgc,
					   ass.inpessoa,
					   ass.cdnacion,
					   ass.nrdocptl
				  FROM crapass ass
				 WHERE ass.cdcooper = pr_cdcooper
				   AND ass.nrdconta = pr_nrdconta;
			rw_crapass cr_crapass%ROWTYPE;
			
      -- Cursor para buscar estado civil da pessoa fisica, jurida nao tem
      CURSOR cr_gnetcvl(pr_cdcooper crapttl.cdcooper%TYPE
                       ,pr_nrdconta crapttl.nrdconta%TYPE) IS
        SELECT gnetcvl.rsestcvl,
               crapttl.dsproftl
         FROM  crapttl,
               gnetcvl
         WHERE crapttl.cdcooper = pr_cdcooper
           AND crapttl.nrdconta = pr_nrdconta
           AND crapttl.idseqttl = 1 -- Primeiro Titular
           AND gnetcvl.cdestcvl = crapttl.cdestcvl;
      rw_gnetcvl cr_gnetcvl%ROWTYPE;--armazena informacoes do cursor cr_gnetcvl			
			
      -- Busca a Nacionalidade
      CURSOR cr_crapnac(pr_cdnacion IN crapnac.cdnacion%TYPE) IS
        SELECT crapnac.dsnacion
          FROM crapnac
         WHERE crapnac.cdnacion = pr_cdnacion;
      rw_crapnac cr_crapnac%ROWTYPE;--armazena informacoes do cursor cr_crapnac			
			
      -- Cursor sobre o endereco do associado
      CURSOR cr_crapenc(pr_cdcooper crapenc.cdcooper%TYPE
			                 ,pr_nrdconta crapenc.nrdconta%TYPE
			                 ,pr_inpessoa crapass.inpessoa%TYPE) IS
        SELECT crapenc.dsendere,
               crapenc.nrendere,
               crapenc.nmbairro,
               crapenc.nmcidade,
               crapenc.cdufende,
               crapenc.nrcepend
          FROM crapenc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND idseqttl = 1
           AND tpendass = CASE
                          WHEN pr_inpessoa = 1 THEN
                            10 --Residencial
                          ELSE
                            9 -- Comercial
                          END;
      rw_crapenc cr_crapenc%ROWTYPE;--armazena informacoes do cursor cr_crapenc			
			
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Variaveis gerais
      vr_texto_completo VARCHAR2(32600);             --> Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_des_xml        CLOB;                        --> XML do relatorio
      vr_des_xml2       CLOB;                        --> XML do relatorio
      vr_nmarqcet       VARCHAR2(15);                --> retorno da CCET
      vr_cdprogra       VARCHAR2(10) := 'EMPR0003';  --> Nome do programa
      rw_crapdat        btch0001.cr_crapdat%ROWTYPE; --> Cursor genérico de calendário
      vr_nom_direto     VARCHAR2(200);               --> Diretório para gravação do arquivo
      vr_dsjasper       VARCHAR2(100);               --> nome do jasper a ser usado
      vr_dtlibera       DATE;                        --> Data de liberacao do contrato
      vr_nmarqimp       VARCHAR2(50);                --> nome do arquivo PDF
      vr_vlemprst       NUMBER;
      vr_flgachou       BOOLEAN;
      vr_inaddcob       INTEGER := 0;
      vr_inresaut       INTEGER := 0;
      vr_nrctater       INTEGER := 0;
	  vr_nminterv       crapass.nmprimtl%TYPE;
	  vr_nrcpfcgc       VARCHAR2(50);
      vr_interven       VARCHAR2(500);  --> Descrição do interveniente

      -- variaveis de críticas
      vr_tab_erro       GENE0001.typ_tab_erro;
      vr_des_reto       VARCHAR2(10);
      vr_typ_saida      VARCHAR2(3);

    BEGIN
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      -- Abre o cursor com as informacoes do emprestimo
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      -- Se nao encontrar o emprestimo finaliza o programa
      IF cr_crawepr%NOTFOUND THEN
        vr_dscritic := 'Emprestimo '||nvl(pr_nrctremp,0) ||' nao encontrado para impressao'; --monta critica
        CLOSE cr_crawepr;
        RAISE vr_exc_saida; -- encerra programa e retorna critica
      END IF;
      CLOSE cr_crawepr;

      -- Abre o cursor com as informacoes do emprestimo
      OPEN cr_crapepr;
      FETCH cr_crapepr INTO rw_crapepr;
      -- Se nao encontrar o emprestimo finaliza o programa
      CLOSE cr_crapepr;
      
      -- Se for POS-FIXADO
      IF rw_crawepr.tpemprst = 2 THEN
        -- Efetua geracao do XML do contrato
        pc_gera_xml_contrato_pos(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctremp => pr_nrctremp
                                ,pr_inimpctr => pr_inimpctr
                                ,pr_dsjasper => vr_dsjasper
                                ,pr_nmarqimp => vr_nmarqimp
                                ,pr_des_xml  => vr_des_xml2
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
      -- Se for PP ou TR
      ELSIF rw_crawepr.tpemprst IN (0,1) THEN
        -- Efetua geracao do XML do contrato
        pc_gera_xml_contrato_pp_tr(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp
                                  ,pr_inimpctr => pr_inimpctr
                                  ,pr_dsjasper => vr_dsjasper
                                  ,pr_nmarqimp => vr_nmarqimp
                                  ,pr_des_xml  => vr_des_xml2
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
      END IF;

      -- Se retornou erro
      IF NVL(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Inicializar o CLOB
      vr_des_xml := NULL;
      vr_texto_completo := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Inicializa o XML
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'<?xml version="1.0" encoding="utf-8"?><contrato>', TRUE);

      -- Se for PP ou POS-FIXADO
      IF rw_crawepr.tpemprst IN (1,2) THEN
        -- Se possuir cobertura e data for superior ao do novo contrato
        IF rw_crawepr.idcobope > 0 AND
           rw_crawepr.dtmvtolt >= TO_DATE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                   ,pr_cdacesso => 'DT_VIG_IMP_CTR_V2'),'DD/MM/RRRR') THEN
          --> Garantia Operacoes de Credito
          OPEN  cr_cobertura(pr_idcobert => rw_crawepr.idcobope);
          FETCH cr_cobertura INTO rw_cobertura;
          vr_flgachou := cr_cobertura%FOUND;
          CLOSE cr_cobertura;
          -- Se achou
          IF vr_flgachou THEN
						 
					   -- Se possui conta de interveniente
					   IF rw_cobertura.nrconta_terceiro > 0 THEN
							 -- Buscar conta do cooperado
							 OPEN cr_crapass(pr_cdcooper => pr_cdcooper
							                ,pr_nrdconta => rw_cobertura.nrconta_terceiro);
							 FETCH cr_crapass INTO rw_crapass;
							 
							 -- Se não encontrou
							 IF cr_crapass%NOTFOUND THEN
								 -- Fechar cursor
								 CLOSE cr_crapass;
								 -- Gerar crítica
								 vr_cdcritic := 9;
								 -- Levantar exceção
								 RAISE vr_exc_saida;
							 END IF;
							 -- Fechar cursor
							 CLOSE cr_crapass;							 
							 
							 -- Busca os dados do endereco residencial do associado
							 OPEN  cr_crapenc(pr_cdcooper => pr_cdcooper
							                 ,pr_nrdconta => rw_cobertura.nrconta_terceiro
															 ,pr_inpessoa => rw_crapass.inpessoa);
							 FETCH cr_crapenc INTO rw_crapenc;
							 -- Se nao encontrar o endereco finaliza o programa
							 IF cr_crapenc%NOTFOUND THEN
							 	 vr_dscritic := 'Endereco do interveniente nao encontrada para impressao'; -- monta critica
								 CLOSE cr_crapenc;
								 RAISE vr_exc_saida;
							 END IF;
							 CLOSE cr_crapenc;
							 
							 -- Capturar nome, conta e cpf/cnpj do interveniente
							 vr_nminterv := rw_crapass.nmprimtl;
                             vr_nrctater := rw_cobertura.nrconta_terceiro;
							 vr_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc
							                                         ,pr_inpessoa => rw_crapass.inpessoa);																											 
							 
							 -- Verifica se o documento eh um CPF ou CNPJ
							 IF rw_crapass.inpessoa = 1 THEN
								 -- Busca estado civil e profissao
								 OPEN  cr_gnetcvl(pr_cdcooper => pr_cdcooper,
																	pr_nrdconta => rw_cobertura.nrconta_terceiro); 
								 FETCH cr_gnetcvl INTO rw_gnetcvl;
								 CLOSE cr_gnetcvl;

								 -- Busca a Nacionalidade
								 OPEN  cr_crapnac(pr_cdnacion => rw_crapass.cdnacion);
								 FETCH cr_crapnac INTO rw_crapnac;
								 CLOSE cr_crapnac;

								 -- monta descricao para o relatorio com os dados do emitente
								 vr_interven := vr_nminterv || ', ' 
														 || (CASE WHEN TRIM(rw_crapnac.dsnacion) IS NOT NULL THEN 'nacionalidade '||LOWER(rw_crapnac.dsnacion) || ', ' ELSE '' END)
														 || (CASE WHEN TRIM(rw_gnetcvl.dsproftl) IS NOT NULL THEN LOWER(rw_gnetcvl.dsproftl) || ', ' ELSE '' END)
														 || (CASE WHEN TRIM(rw_gnetcvl.rsestcvl) IS NOT NULL THEN LOWER(rw_gnetcvl.rsestcvl) || ', ' ELSE '' END)
														 || 'inscrito(a) no CPF sob n° ' || vr_nrcpfcgc || ', '
														 || 'portador(a) do RG n° ' || rw_crapass.nrdocptl || ', residente e domiciliado(a) na ' || rw_crapenc.dsendere || ', '
														 || 'n° '|| rw_crapenc.nrendere || ', bairro ' || rw_crapenc.nmbairro || ', '
														 || 'da cidade de ' || rw_crapenc.nmcidade || '/' || rw_crapenc.cdufende || ', '
														 || 'CEP ' || gene0002.fn_mask_cep(rw_crapenc.nrcepend) || ', '
														 || 'titular da conta corrente n° ' || TRIM(gene0002.fn_mask_conta(vr_nrctater)) 
														 || ', na condição de INTERVENIENTE GARANTIDOR.';
							 ELSE
								 -- monta descricao para o relatorio com os dados do emitente
								 vr_interven := vr_nminterv || ', inscrita no CNPJ sob n° '|| vr_nrcpfcgc
														 || ' com sede na ' || rw_crapenc.dsendere || ', n° ' || rw_crapenc.nrendere || ', '
														 || 'bairro ' || rw_crapenc.nmbairro || ', da cidade de ' || rw_crapenc.nmcidade || '/' || rw_crapenc.cdufende || ', '
														 || 'CEP ' || gene0002.fn_mask_cep(rw_crapenc.nrcepend) || ', conta corrente n° ' || TRIM(gene0002.fn_mask_conta(vr_nrctater)) 
														 || ', na condição de INTERVENIENTE GARANTIDOR.';
						 END IF;
							  
						 END IF;
						 
             vr_inaddcob := 1;
             vr_inresaut := rw_cobertura.inresgate_automatico;
             GENE0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                    '<cob_qtdiatraso>' || rw_cobertura.qtdias_atraso_permitido || '</cob_qtdiatraso>' ||
                                    '<cob_perminimo>'  || TO_CHAR(rw_cobertura.perminimo,'FM999G999G999G990D00') || '</cob_perminimo>' ||
																		'<cob_interven>'   || vr_interven || '</cob_interven>');
          END IF;
        END IF;
      END IF;

      -- Cria nos de cobertura de operacao e resgate automatico
      GENE0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                             '<cob_nrctater>' || trim(gene0002.fn_mask_conta(nvl(vr_nrctater,0))) || '</cob_nrctater>' ||
                             '<cob_nminterv>' || trim(vr_nminterv) || '</cob_nminterv>' ||														 
                             '<cob_nrcpfint>' || trim(vr_nrcpfcgc) || '</cob_nrcpfint>' ||														 
                             '<cob_inaddcob>' || vr_inaddcob || '</cob_inaddcob>' ||
                             '<cob_inresaut>' || vr_inresaut || '</cob_inresaut>');

      -- Concatena com xml contratos
      dbms_lob.append(vr_des_xml, vr_des_xml2);
      dbms_lob.freetemporary(vr_des_xml2);
      vr_des_xml2 := NULL;
      dbms_lob.createtemporary(vr_des_xml2, TRUE);
      dbms_lob.open(vr_des_xml2, dbms_lob.lob_readwrite);
      
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, ' ', TRUE);

          vr_dtlibera := nvl(nvl(rw_crapepr.dtmvtolt, rw_crawepr.dtlibera),rw_crapdat.dtmvtolt);
      
      --Passar só o valor do empréstimo para a CCET001, pois lá recalcula tudo que precisa
      vr_vlemprst := rw_crawepr.vlemprst;

      -- Chama rotina de CET
      ccet0001.pc_imprime_emprestimos_cet(pr_cdcooper => pr_cdcooper
                                        , pr_dtmvtolt => nvl(rw_crapepr.dtmvtolt,rw_crapdat.dtmvtolt)
                                        , pr_cdprogra => vr_cdprogra
                                        , pr_nrdconta => pr_nrdconta
                                        , pr_inpessoa => rw_crawepr.inpessoa
                                        , pr_cdusolcr => 0 -- Segundo o Lucas, deve ser passado zero
                                        , pr_cdlcremp => rw_crawepr.cdlcremp
                                        , pr_tpemprst => rw_crawepr.tpemprst
                                        , pr_nrctremp => pr_nrctremp
                                        , pr_dtlibera => vr_dtlibera
                                        , pr_dtultpag => trunc(SYSDATE)
                                            , pr_vlemprst => vr_vlemprst
                                        , pr_txmensal => rw_crawepr.txmensal
                                        , pr_vlpreemp => rw_crawepr.vlpreemp
                                        , pr_qtpreemp => rw_crawepr.qtpreemp
                                        , pr_dtdpagto => rw_crawepr.dtdpagto
                                        , pr_nmarqimp => vr_nmarqcet
                                        , pr_des_xml  => vr_des_xml2
                                        , pr_cdcritic => vr_cdcritic
                                        , pr_dscritic => vr_dscritic
                                        );
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, ' ', TRUE);

      -- Concatena xml retornado CET com xml contratos
          dbms_lob.append(vr_des_xml, vr_des_xml2);
          dbms_lob.freetemporary(vr_des_xml2);
          vr_des_xml2 := NULL;
          dbms_lob.createtemporary(vr_des_xml2, TRUE);
          dbms_lob.open(vr_des_xml2, dbms_lob.lob_readwrite);

      IF rw_crawepr.nrseqrrq <> 0 THEN -- somenmte se for microcredito
            -- chama rotinar para geracao de questionario
            empr0003.pc_gera_perfil_empr(pr_cdcooper => pr_cdcooper
                                       , pr_nrdconta => pr_nrdconta
                                       , pr_nrctremp => pr_nrctremp
                                       , pr_cdcritic => vr_cdcritic
                                       , pr_dscritic => vr_dscritic
                                       , pr_retxml   => vr_des_xml2
                                       );
            -- concatena xml retornado empr0005 com xml contratos
            dbms_lob.append(vr_des_xml, vr_des_xml2);
            dbms_lob.freetemporary(vr_des_xml2);
          END IF;

      dbms_lob.writeappend(vr_des_xml, length('</contrato>'), '</contrato>');

      -- Busca diretorio padrao da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl');

      -- Solicita geracao do PDF
      gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                                 , pr_cdprogra  => vr_cdprogra
                                 , pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 , pr_dsxml     => vr_des_xml
                                 , pr_dsxmlnode => '/contrato'
                                 , pr_dsjasper  => vr_dsjasper
                                 , pr_dsparams  => null
                                 , pr_dsarqsaid => vr_nom_direto || vr_nmarqimp
                                 , pr_flg_gerar => 'S'
                                 , pr_qtcoluna  => 234
                                 , pr_sqcabrel  => 1
                                 , pr_flg_impri => 'S'
                                 , pr_nmformul  => ' '
                                 , pr_nrcopias  => 1
                                 , pr_nrvergrl  => 1
                                 , pr_parser    => 'R'           --> Seleciona o tipo do parser. "D" para VTD e "R" para Jasper padrão
                                 , pr_des_erro  => vr_dscritic);


      IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
        RAISE vr_exc_saida; -- encerra programa
      END IF;

      -- copia contrato pdf do diretorio da cooperativa para servidor web
      gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                 , pr_cdagenci => NULL
                                 , pr_nrdcaixa => NULL
                                 , pr_nmarqpdf => vr_nom_direto || vr_nmarqimp
                                 , pr_des_reto => vr_des_reto
                                 , pr_tab_erro => vr_tab_erro
                                 );

      -- caso apresente erro na operação
      IF nvl(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_saida; -- encerra programa
        END IF;
      END IF;

      -- Remover relatorio do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm ' || vr_nom_direto || vr_nmarqimp
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT null THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_saida; -- encerra programa
      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      vr_nmarqimp := substr(vr_nmarqimp, 2);-- retornar somente o nome do PDF sem a barra"/"

      -- Criar XML de retorno para uso na Web
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' || vr_nmarqimp || '</nmarqpdf>');

      -- Atualiza quantidade de impressoes realizadas do contrato do tipo negociavel
      IF nvl(pr_inimpctr,0) = 0 THEN
        BEGIN
          UPDATE crapepr
             SET crapepr.qtimpctr = NVL(qtimpctr,0) + 1
           WHERE crapepr.cdcooper = pr_cdcooper
             AND crapepr.nrdconta = pr_nrdconta
             AND crapepr.nrctremp = pr_nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar quantidade de impressao na crapepr'||SQLERRM;
          RAISE vr_exc_saida; -- encerra programa
        END;
      END IF;

    COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || upper(pr_dscritic) || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||upper(pr_dscritic) ||'</Erro></Root>');
        ROLLBACK;

    END pc_imprime_contrato_xml;

  /* Rotina para acionar a geração de PRoposta PDF no Progress */
  PROCEDURE pc_gera_proposta_pdf(pr_cdcooper in crawepr.cdcooper%TYPE --> Código da cooperativa
                                ,pr_cdagenci in crawepr.nrdconta%TYPE --> Código da Agencia
                                ,pr_nrdcaixa in INTEGER               --> Numero do Caixa                                        
                                ,pr_nmdatela in VARCHAR2              --> Tela
                                ,pr_cdoperad in crapope.cdoperad%TYPE --> Código do Operador
                                ,pr_idorigem in PLS_INTEGER           --> Origem 
                                ,pr_nrdconta in crawepr.nrdconta%TYPE --> Numero da conta
                                ,pr_dtmvtolt in date                  --> Data atual
                                ,pr_dtmvtopr in date                  --> Data próxima
                                ,pr_nrctremp in crawepr.nrctremp%TYPE --> nro do contrato
                                ,pr_dsiduser in varchar2              --> ID da sessão ou id randomico
                                ,pr_nmarqpdf IN OUT varchar2 ) IS          --> Caminho/Arquivo gerado
  /* .............................................................................

       Programa: pc_gera_proposta_pdf
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Martini (Supero)
       Data    : Julho/2017.                         Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Prepara a chamada de Script Shell que irá acionar o fonte 
                   gera_pdf_proposta.p que irá chamar a geração do PDF da proposta
                   e irá escrever o mesmo no caminho que solicitarmos na chamada 

       Alteracoes:

    ............................................................................. */
    vr_dscomand     VARCHAR2(4000); --> Comando para baixa do arquivo
    vr_des_reto     VARCHAR2(3);    --> tipo saida
    vr_dsparame     VARCHAR2(4000); 
  BEGIN
    
    -- Remover arquivo temporário para evitar falta de permissão
    GENE0001.pc_OScommand(pr_typ_comando => 'SR'
                         ,pr_des_comando => 'rm /tmp/exec.script.txt');
        
    -- Comando para Execucao
    vr_dscomand := GENE0001.fn_param_sistema('CRED',3,'SCRIPT_GERA_PROP_EMPR');
    
    -- Montar os parâmetros:
    --  aux_cdcooper
    --  aux_cdagenci
    --  aux_nrdcaixa
    --  aux_nmdatela
    --  aux_cdoperad     
    --  aux_idorigem
    --  aux_nrdconta
    --  aux_dtmvtolt
    --  aux_dtmvtopr
    --  aux_nrctremp
    --  aux_dsiduser
    --  aux_nmarqpdf
    vr_dsparame := pr_cdcooper||';'
                || pr_cdagenci||';'
                || pr_nrdcaixa||';'
                || pr_nmdatela||';'
                || pr_cdoperad||';'
                || pr_idorigem||';'
                || pr_nrdconta||';'
                || to_char(pr_dtmvtolt,'mmddrrrr')||';'
                || to_char(pr_dtmvtopr,'mmddrrrr')||';'
                || pr_nrctremp||';'
                || pr_dsiduser||';'
                || replace(replace(pr_nmarqpdf,'/coopl/','/coop/'),'/cooph/','/coop/');
    -- Incluir os parametros    
    vr_dscomand := REPLACE(vr_dscomand,'[params]',vr_dsparame);

    -- Executar comando para Download
    GENE0001.pc_OScommand(pr_typ_comando => 'SR'
                         ,pr_des_comando => vr_dscomand);
  END;

    PROCEDURE pc_gera_perfil_empr(pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                                 ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                 ,pr_nrctremp IN crawepr.nrctremp%TYPE --> nro do contrato
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT CLOB              --> Arquivo de retorno do XML
                                 ) IS
  /* .............................................................................

       Programa: pc_gera_perfil_empr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago Castro (RKAM)
       Data    : Dezembro/2014.                         Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Gera o relatorio crrl_042 ( PERFIL SOCIO-ECONOMICO DO MICROEMPREENDEDOR)

       Alteracoes:

    ............................................................................. */

    -- busca nome do cooperado
    CURSOR cr_crapass IS
      SELECT  crapass.nmprimtl
      FROM    crapass
      WHERE   crapass.cdcooper = pr_cdcooper
      AND     crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- busca nome da cooperativa
    CURSOR cr_crapcop IS
      SELECT  crapcop.nmextcop
      FROM    crapcop
      WHERE   crapcop.cdcooper = pr_cdcooper;
    rw_crapcop  cr_crapcop%ROWTYPE;

    -- dados do contrato de emprestimo
    CURSOR cr_crawepr IS
      SELECT  crawepr.nrseqrrq
      FROM    crawepr
      WHERE   crawepr.cdcooper = pr_cdcooper
      AND     crawepr.nrdconta = pr_nrdconta
      AND     crawepr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;


    vr_cabecalho      VARCHAR2(3000);  --> Cabecalho do relatorio
    vr_des_xml        CLOB;            --> XML do relatorio
    vr_campo          VARCHAR2(20);    --> campo xml com erro
    vr_des_erro       VARCHAR2(4000);  --> erro empr0005

    BEGIN
      -- busca informacao do cooperado
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;
      -- busca informacao da cooperativa
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;
      --busca informacao do contrato de emprestimo
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      CLOSE cr_crawepr;
      -- monta cabecalho do relatorio
      vr_cabecalho := 'Eu '||rw_crapass.nmprimtl ||' conta corrente no. '||trim(gene0002.fn_mask_conta(pr_nrdconta))||' declaro para'||chr(13)||
                      'os devidos fins, que os procedimentos operacionais referentes ao'||chr(13)||
                      'processo de concessao de microcredito produtivo e orientado foram'||chr(13)||
                      'desenvolvidos pela '||rw_crapcop.nmextcop||' atraves'||chr(13)||
                      'de metodologia baseada no relacionamento direto com o empreendedor e'||chr(13)||
                      'prestando orientacao financeira. Me comprometo a utilizar de forma'||chr(13)||
                      'produtiva a totalidade dos recursos captados, conforme finalidade'||chr(13)||
                      'descrita no contrato no. '||trim(gene0002.fn_mask(pr_nrctremp,'99.999.999'))||', firmado com a '||rw_crapcop.nmextcop||'.';

      -- inicia variavel clob
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- insere cabecalho do relatorio no xml retornado da empr0005
      dbms_lob.writeappend(vr_des_xml,length('<empr0005>'),'<empr0005>');
      dbms_lob.writeappend(vr_des_xml,length('  <cabecalho>'||vr_cabecalho||'</cabecalho>'),'  <cabecalho>'||vr_cabecalho||'</cabecalho>');

      -- busca xml do questionario de perfil socio economico
      empr0005.pc_retorna_perguntas(pr_cdcooper => pr_cdcooper         --> Código da cooperativa
                                  , pr_nrdconta => pr_nrdconta         --> Numero da conta
                                  , pr_nrseqrrq => rw_crawepr.nrseqrrq --> Numero sequencial do retorno das respostas do questionario
                                  , pr_inregcal => 1                   --> Indicador se deve ou nao exibir registros que sao calculados
                                  , pr_retxml   => vr_des_xml         --> Arquivo de retorno do XML
                                  , pr_cdcritic => vr_cdcritic         --> Código da crítica
                                  , pr_dscritic => vr_dscritic);

      -- fecha tag empr0005
      dbms_lob.writeappend(vr_des_xml,length('</empr0005>'),'</empr0005>');
      -- retorna xmls concatenados com
      pr_retxml := vr_des_xml;
    END pc_gera_perfil_empr;


    
    /* Imprime o demonstrativo do contrato de emprestimo pre-aprovado */
    PROCEDURE pc_gera_demonst_pre_aprovado(pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da Cooperativa
                                          ,pr_cdagenci IN crawepr.nrdconta%TYPE --> Código da Agencia
                                          ,pr_nrdcaixa IN INTEGER               --> Numero do Caixa
                                          ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do Operador
                                          ,pr_cdprogra IN crapprg.cdprogra%TYPE --> Código do Programa
                                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do Movimento
                                          ,pr_nmarqimp IN VARCHAR2              --> Caminho do arquivo 
                                          ,pr_nmarqpdf OUT VARCHAR2             --> Nome Arquivo PDF
                                          ,pr_des_reto OUT VARCHAR2) IS         --> Descrição do retorno
    BEGIN
      /* .............................................................................

         Programa: pc_gera_demonstrativo_pre_aprovado
         Sistema : Conta-Corrente - Cooperativa de Credito
         Sigla   : CRED
         Autor   : Carlos Rafael Tanholi
         Data    : Janeiro/2016.                         Ultima atualizacao:

         Dados referentes ao programa:

         Frequencia: Sempre que for chamado.
         Objetivo  : Gera o relatorio crrl_711 (Demonstrativo de contrato de emprestimo pre-aprovado)

         Alteracoes:

      ............................................................................. */

      DECLARE

        -- caminho e nome do arquivo a ser gerado
        vr_nmdireto VARCHAR(150);
        vr_nmrquivo VARCHAR2(100);
        -- caminho e nome do arquivo a ser consultado
        vr_endereco VARCHAR(150);
        vr_arqnome  VARCHAR2(100);        

        -- arquivo que sera trabalhado
        vr_arquivo utl_file.file_type;  
        -- linha com o conteudo do arquivo
        vr_setlinha varchar2(2000);
        -- Numero da linha no arquivo
        vr_nrlinha  PLS_INTEGER := 0;
        vr_des_linha VARCHAR2(1000); 
        vr_des_linha_ant VARCHAR2(1000); 
        -- array com parts do enderco do arquivo
        vr_caminho gene0002.typ_split;
        -- Variaveis de Excecoes
        vr_exc_erro EXCEPTION;    
        vr_dscritic VARCHAR2(10000);
        -- Tabela de erros
        vr_tab_erro GENE0001.typ_tab_erro;
        -- CLOB de Dados
        vr_clobxml711  CLOB;
        vr_dstexto711  VARCHAR2(32600); 
        
        vr_contador INTEGER;       
        vr_nmarqsmt VARCHAR2(400);
        vr_nrctremp NUMBER;
        vr_des_reto VARCHAR2(400);
        vr_dscomand VARCHAR2(400);
        vr_typsaida VARCHAR2(400);
        
        -- Buscar conta corrente do contrato
        CURSOR cr_crawepr(pr_nrctremp crawepr.nrctremp%TYPE
                         ,pr_cdcooper crawepr.cdcooper%TYPE) IS
          SELECT epr.nrdconta
          FROM crawepr epr
          WHERE epr.nrctremp = pr_nrctremp
            AND epr.cdcooper = pr_cdcooper;
        rw_crawepr cr_crawepr%ROWTYPE;
		
      BEGIN
        -- Busca do diretório base da cooperativa para a geração de relatórios
        vr_nmdireto:= gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                           ,pr_cdcooper => pr_cdcooper --> Cooperativa
                                           ,pr_nmsubdir => 'rl');      --> Utilizaremos o rl        

        -- quebra caminho do arquivo e separa caminho e nome                
        vr_caminho := gene0002.fn_quebra_string(pr_string => pr_nmarqimp, pr_delimit => '/');
              
        IF NVL(vr_caminho.count(),0) > 0 THEN    
          -- recupera so o nome do arquivo .ex
          vr_arqnome := vr_caminho(vr_caminho.LAST);  
          -- recupera o endereco do arquivo .ex
          vr_endereco := REPLACE(pr_nmarqimp, vr_arqnome, ''); 
          -- armazena o nome do arquivo destino (PDF)
          vr_nmrquivo := REPLACE(vr_arqnome, '.ex', '.pdf');      
        END IF;      
        
        -- criar handle de arquivo de Saldo Disponível dos Associados
        GENE0001.pc_abre_arquivo(pr_nmdireto => vr_endereco   --> Diretorio do arquivo
                                ,pr_nmarquiv => vr_arqnome    --> Nome do arquivo
                                ,pr_tipabert => 'R'           --> modo de abertura (r,w,a)
                                ,pr_utlfileh => vr_arquivo    --> handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic); --> erro
        -- em caso de crítica
        IF vr_dscritic IS NOT NULL THEN
          vr_dscritic:= 'Erro ao abrir arquivo de origem';
          --levantar excecao
          RAISE vr_exc_erro;
        END IF;      
        
        -- Inicializar as informações do XML de dados para o relatório
        dbms_lob.createtemporary(vr_clobxml711, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clobxml711, dbms_lob.lob_readwrite);
        --Escrever no arquivo XML
        gene0002.pc_escreve_xml(vr_clobxml711,vr_dstexto711,'<?xml version="1.0" encoding="UTF-8"?><crrl711>');        
        
        -- Inicializar número do contrato
        vr_nrctremp := NULL;
        -- Se o arquivo estiver aberto
        IF  utl_file.IS_OPEN(vr_arquivo) THEN
           -- Percorrer as linhas do arquivo
          BEGIN
            vr_contador := 0;
            LOOP        
              gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arquivo,pr_des_text => vr_des_linha);        

			  -- Capturar o número do contrato a partir do arquivo texto
              IF vr_nrctremp IS NULL THEN
                vr_nrctremp := REPLACE(TRIM(SUBSTR(vr_des_linha
                                                  ,INSTR(vr_des_linha, 'Nº') + 2
                                                  ,LENGTH(vr_des_linha))), '.', '');
              END IF;
			  
              IF vr_contador = 0 AND vr_des_linha IS NOT NULL THEN
                 gene0002.pc_escreve_xml(vr_clobxml711,vr_dstexto711,'<cabecalho>');
                 --Escreve o cabecalho do arquivo no XML de dados do relatorio
                 gene0002.pc_escreve_xml(vr_clobxml711, vr_dstexto711, vr_des_linha,TRUE);                 
                 gene0002.pc_escreve_xml(vr_clobxml711,vr_dstexto711,'</cabecalho><conteudo>');
              ELSE   
              
                IF ( vr_des_linha IS NULL AND vr_contador > 1 ) THEN
                  vr_des_linha := '#br#';
                END IF;                  
              
                IF ( NOT vr_des_linha IS NULL ) THEN
                  --Escreve o conteudo do arquivo no XML de dados do relatorio
                  gene0002.pc_escreve_xml(vr_clobxml711, vr_dstexto711, vr_des_linha,TRUE);                  
                END IF;
                
              END IF;
              
              vr_contador := vr_contador+1;
              
            END LOOP; -- Fim LOOP linhas do arquivo
          EXCEPTION
            WHEN no_data_found THEN
              NULL;
          END;
        END IF;
        
        --Finaliza TAG Extratos e Conta
        gene0002.pc_escreve_xml(vr_clobxml711, vr_dstexto711, '</conteudo></crrl711>',TRUE);        
        
        -- Fechar o arquivo
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo);        
        
      	  -- Gera relatório 711
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                                   ,pr_cdprogra  => pr_cdprogra                   --> Programa chamador
                                   ,pr_dtmvtolt  => pr_dtmvtolt                   --> Data do movimento atual
                                   ,pr_dsxml     => vr_clobxml711                 --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl711'                   --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl711.jasper'              --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                          --> Sem parâmetros
                                   ,pr_cdrelato  => 711                           --> Código fixo para o relatório (nao busca pelo sqcabrel)                                       
                                   ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmrquivo --> Arquivo final com o path
                                   ,pr_qtcoluna  => 80                            --> Colunas do relatorio
                                   ,pr_flg_gerar => 'S'                           --> Geraçao na hora
                                   ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => NULL                          --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1                             --> Número de cópias
                                   ,pr_sqcabrel  => 1                             --> Qual a seq do cabrel
                                   ,pr_flappend  => 'N'                           --> Fazer append do relatorio se ja existir
                                   ,pr_des_erro  => vr_dscritic);                 --> Saída com erro
                    
        --Se ocorreu erro no relatorio
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;         
                

        GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper, --Codigo Cooperativa
                                     pr_cdagenci => pr_cdagenci, --Codigo Agencia
                                     pr_nrdcaixa => pr_nrdcaixa, --Numero do Caixa
                                     pr_nmarqpdf => vr_nmdireto||'/'||vr_nmrquivo, --Nome Arquivo PDF
                                     pr_des_reto => pr_des_reto, --Retorno OK/NOK
                                     pr_tab_erro => vr_tab_erro);--tabela erro

        --Se ocorreu erro
        IF pr_des_reto <> 'OK' THEN
          --Se tem erro na tabela 
          IF vr_tab_erro.COUNT > 0 THEN
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic:= 'Erro ao copiar arquivo para web.';  
          END IF; 
          --Sair 
          RAISE vr_exc_erro;
        END IF;
        
        /* P442 - Envio ao smartshare */
        -- Buscar conta corrente com base no contrato
        OPEN cr_crawepr(pr_nrctremp => vr_nrctremp, pr_cdcooper => pr_cdcooper);
        FETCH cr_crawepr INTO rw_crawepr;
        CLOSE cr_crawepr;

        -- Gerar o nome padrão para o arquivo
        vr_nmarqsmt := '57'||'_'||trim(gene0002.fn_mask_contrato(vr_nrctremp))
                       ||'_'||trim(replace(gene0002.fn_mask_conta(rw_crawepr.nrdconta),'-','.'))
                       ||'_'||pr_cdcooper||'_'||pr_cdagenci||'_'||'1'||'.pdf';
        
        -- Gerar versão do relatório para envio
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                                   ,pr_cdprogra  => pr_cdprogra                   --> Programa chamador
                                   ,pr_dtmvtolt  => pr_dtmvtolt                   --> Data do movimento atual
                                   ,pr_dsxml     => vr_clobxml711                 --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl711'                    --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl711.jasper'              --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                          --> Sem parâmetros
                                   ,pr_cdrelato  => 711                           --> Código fixo para o relatório (nao busca pelo sqcabrel)                                       
                                   ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqsmt --> Arquivo final com o path
                                   ,pr_qtcoluna  => 80                            --> Colunas do relatorio
                                   ,pr_flg_gerar => 'S'                           --> Geraçao na hora
                                   ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => NULL                          --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1                             --> Número de cópias
                                   ,pr_sqcabrel  => 1                             --> Qual a seq do cabrel
                                   ,pr_flappend  => 'N'                           --> Fazer append do relatorio se ja existir
                                   ,pr_des_erro  => vr_dscritic);                 --> Saída com erro

        --Se ocorreu erro no relatorio
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
                  
        -- Transferir arquivo para o smartshare
        gene0002.pc_transf_arq_smartshare(pr_nmdiretorio => vr_nmdireto
                                         ,pr_nmarquiv    => '/' || vr_nmarqsmt 
                                         ,pr_cdcooper    => pr_cdcooper
                                         ,pr_des_reto    => vr_des_reto
                                         ,pr_dscritic    => vr_dscritic);
        
        -- Validar se ocorreram erros
        IF NVL(vr_des_reto, 'OK') != 'OK' THEN
          vr_dscritic := 'Erro ao enviar contrato pre-aprovado para o smartshare. ' || vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
                  
        -- Arquivo final com o path    
        pr_nmarqpdf := vr_nmrquivo;
        
        EXCEPTION
          WHEN vr_exc_erro THEN
            pr_des_reto := vr_dscritic;
          WHEN OTHERS THEN
            pr_des_reto:= 'NOK';
        END;

    END pc_gera_demonst_pre_aprovado;

  /******************************************************************************/
  /**            Procedure para buscar operações dos avalistas.                **/
  /******************************************************************************/
  PROCEDURE pc_busca_operacoes(pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo da cooperativa
                              ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Numero da conta
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      --> Data de movimento
                              ,pr_vldscchq IN OUT crapcdb.vlcheque%TYPE  --> Valor de cheque
                              ,pr_vlutlchq IN OUT crapcdb.vlcheque%TYPE  --> Valor do ultimo cheque                              
                              ,pr_vldctitu IN OUT craptdb.vltitulo%TYPE  --> Valor de titulo de descont0
                              ,pr_vlutitit IN OUT craptdb.vltitulo%TYPE  --> Valor do ultimo titulo de desconto                                                                 
                              ------ OUT ------                                      
                              ,pr_tab_co_responsavel IN OUT empr0001.typ_tab_dados_epr --> Retorna dados
                              ,pr_dscritic     OUT VARCHAR2          --> Descrição da critica
                              ,pr_cdcritic     OUT INTEGER) IS       --> Codigo da critica
     
  /* ..........................................................................
    --
    --  Programa : pc_busca_operacoes        Antiga: b1wgen0002i.p/busca_operacoes
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Abril/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para buscar operações dos avalistas.    
    --
    --  Alteração : 
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------    
    
    --> Buscar dados do contrato de limites dos avalistas
    CURSOR cr_craplim ( pr_cdcooper  craplim.cdcooper%TYPE,
                        pr_nrdconta  craplim.nrdconta%TYPE) IS
      SELECT lim.tpctrlim,
             lim.insitlim,
             lim.cdcooper,
             lim.nrdconta,
             lim.nrctrlim,
             lim.vllimite,
             lim.cddlinha
        FROM crapavl avl
            ,craplim lim
       WHERE avl.cdcooper = pr_cdcooper
         AND avl.nrdconta = pr_nrdconta
         AND lim.cdcooper = avl.cdcooper
         AND lim.nrdconta = avl.nrctaavd
         AND lim.nrctrlim = avl.nrctravd;
    
    -->  Buscar valor de cheques
    CURSOR cr_crapcdb ( pr_cdcooper  craplim.cdcooper%TYPE,
                        pr_nrdconta  craplim.nrdconta%TYPE,
                        pr_nrctrlim  craplim.nrctrlim%TYPE,
                        pr_dtmvtolt  DATE) IS
      SELECT SUM(cdb.vlcheque) vlcheque
        FROM crapbdc bdc,
             crapcdb cdb
       WHERE bdc.cdcooper = pr_cdcooper
         AND bdc.nrdconta = pr_nrdconta
         AND bdc.nrctrlim = pr_nrctrlim       
         AND cdb.cdcooper = bdc.cdcooper
         AND cdb.nrdconta = bdc.nrdconta
         AND cdb.nrborder = bdc.nrborder
         AND cdb.nrctrlim = bdc.nrctrlim
         AND cdb.insitchq = 2
         AND cdb.dtlibera > pr_dtmvtolt;
    rw_crapcdb cr_crapcdb%ROWTYPE;
    
    --> Buscar valor total de titulos
    CURSOR cr_craptdb ( pr_cdcooper  craplim.cdcooper%TYPE,
                        pr_nrdconta  craplim.nrdconta%TYPE,
                        pr_nrctrlim  craplim.nrctrlim%TYPE,
                        pr_dtmvtolt  DATE) IS
      SELECT SUM(tdb.vltitulo) vltitulo
        FROM craptdb tdb
       WHERE (tdb.cdcooper = pr_cdcooper AND
              tdb.nrdconta = pr_nrdconta AND
              tdb.nrctrlim = pr_nrctrlim AND 
              tdb.insittit = 4)
          OR (tdb.cdcooper = pr_cdcooper AND
              tdb.nrdconta = pr_nrdconta AND
              tdb.nrctrlim = pr_nrctrlim AND 
              tdb.insittit = 2 AND
              tdb.dtdpagto = pr_dtmvtolt);
    rw_craptdb cr_craptdb%ROWTYPE;
    
    -->  Buscar dados da linha de credito
    CURSOR cr_crapldc ( pr_cdcooper  craplim.cdcooper%TYPE,
                        pr_cddlinha  craplim.cddlinha%TYPE,
                        pr_tpdescto  crapldc.tpdescto%TYPE) IS
      SELECT ldc.cddlinha,
             ldc.dsdlinha
        FROM crapldc ldc
       WHERE ldc.cdcooper = pr_cdcooper
         AND ldc.cddlinha = pr_cddlinha
         AND ldc.tpdescto = pr_tpdescto;
    rw_crapldc cr_crapldc%ROWTYPE;
    --------------> TEMPTABLE <-----------------
    
            
    --------------> VARIAVEIS <-----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);
    
    vr_exc_erro EXCEPTION;
    
    vr_idx      PLS_INTEGER;
    
    
  BEGIN
    
    --> Buscar dados do contrato de limites dos avalistas
    FOR rw_craplim IN cr_craplim ( pr_cdcooper  => pr_cdcooper,
                                   pr_nrdconta  => pr_nrdconta) LOOP
      --> Desconto de Cheque 
      IF rw_craplim.tpctrlim = 2 THEN   
        IF rw_craplim.insitlim  = 2 THEN
          pr_vldscchq := nvl(rw_craplim.vllimite,0);
        END IF;    
        pr_vlutlchq := 0;
        rw_crapcdb  := NULL; 
         
        -->  Buscar valor de cheques
        OPEN cr_crapcdb ( pr_cdcooper  => pr_cdcooper,
                          pr_nrdconta  => rw_craplim.nrdconta,
                          pr_nrctrlim  => rw_craplim.nrctrlim,
                          pr_dtmvtolt  => pr_dtmvtolt);
        FETCH cr_crapcdb INTO rw_crapcdb;
        CLOSE cr_crapcdb;
        
        pr_vlutlchq := nvl(pr_vlutlchq,0) + nvl(rw_crapcdb.vlcheque,0);
        
        IF pr_vlutlchq > 0 THEN
          -->  Buscar dados da linha de credito
          OPEN cr_crapldc ( pr_cdcooper  => rw_craplim.cdcooper,
                            pr_cddlinha  => rw_craplim.cddlinha,
                            pr_tpdescto  => 2);
          FETCH cr_crapldc INTO rw_crapldc;
          CLOSE cr_crapldc;
          
          vr_idx := pr_tab_co_responsavel.count;
          pr_tab_co_responsavel(vr_idx).nrdconta := rw_craplim.nrdconta;
          pr_tab_co_responsavel(vr_idx).nrctremp := rw_craplim.nrctrlim;
          pr_tab_co_responsavel(vr_idx).vlsdeved := pr_vlutlchq;   
          pr_tab_co_responsavel(vr_idx).dsfinemp := '   DESCONTO CHEQUES';
          IF rw_crapldc.dsdlinha IS NOT NULL THEN
            pr_tab_co_responsavel(vr_idx).dslcremp := rw_crapldc.cddlinha ||'-'|| rw_crapldc.dsdlinha;
          END IF;               
        
        END IF;
      --> Desconto de Titulo - tpctrlim = 3   
      ELSE
        IF rw_craplim.insitlim  = 2 THEN
          pr_vldctitu := nvl(rw_craplim.vllimite,0);
        END IF;    
        pr_vlutitit := 0;
        rw_craptdb  := NULL; 
        
        --> Buscar valor total de titulos
        OPEN cr_craptdb(pr_cdcooper  => pr_cdcooper,
                        pr_nrdconta  => rw_craplim.nrdconta,
                        pr_nrctrlim  => rw_craplim.nrctrlim,
                        pr_dtmvtolt  => pr_dtmvtolt);
        FETCH cr_craptdb INTO rw_craptdb;
        CLOSE cr_craptdb;
        
        pr_vlutitit := nvl(pr_vlutitit,0) + nvl(rw_craptdb.vltitulo,0);
        
        IF pr_vlutitit > 0 THEN
          -->  Buscar dados da linha de credito
          OPEN cr_crapldc ( pr_cdcooper  => rw_craplim.cdcooper,
                            pr_cddlinha  => rw_craplim.cddlinha,
                            pr_tpdescto  => 3);
          FETCH cr_crapldc INTO rw_crapldc;
          CLOSE cr_crapldc;
          
          vr_idx := pr_tab_co_responsavel.count;
          pr_tab_co_responsavel(vr_idx).nrdconta := rw_craplim.nrdconta;
          pr_tab_co_responsavel(vr_idx).nrctremp := rw_craplim.nrctrlim;
          pr_tab_co_responsavel(vr_idx).vlsdeved := pr_vlutitit;   
          pr_tab_co_responsavel(vr_idx).dsfinemp := '   DESCONTO TITULOS';
          IF rw_crapldc.dsdlinha IS NOT NULL THEN
            pr_tab_co_responsavel(vr_idx).dslcremp := rw_crapldc.cddlinha ||'-'|| rw_crapldc.dsdlinha;
          END IF;
        END IF;
        
      END IF;  --> Fim  else - Desconto de titulo / tpctrlim = 3  
    END LOOP;                               
    
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN

      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_busca_operacoes ' ||
                     SQLERRM;      
  END pc_busca_operacoes;
  
  /******************************************************************************/
  /**     Procedure para buscar operações dos avalistas - Chamada Progress     **/
  /******************************************************************************/
  PROCEDURE pc_busca_operacoes_prog (pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo da cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Numero da conta
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      --> Data de movimento
                                    ,pr_vldscchq IN OUT crapcdb.vlcheque%TYPE  --> Valor de cheque
                                    ,pr_vlutlchq IN OUT crapcdb.vlcheque%TYPE  --> Valor do ultimo cheque                              
                                    ,pr_vldctitu IN OUT craptdb.vltitulo%TYPE  --> Valor de titulo de descont0
                                    ,pr_vlutitit IN OUT craptdb.vltitulo%TYPE  --> Valor do ultimo titulo de desconto                                                                 
                                    ------ OUT ------                                      
                                    ,pr_xml_co_responsavel IN OUT CLOB --> Retorna dados
                                    ,pr_dscritic     OUT VARCHAR2          --> Descrição da critica
                                    ,pr_cdcritic     OUT INTEGER) IS       --> Codigo da critica
     
  /* ..........................................................................
    --
    --  Programa : pc_busca_operacoes_prog        Antiga: b1wgen0002i.p/busca_operacoes
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Abril/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para buscar operações dos avalistas  - Chamada Progress    
    --
    --  Alteração : 
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------    
    
    --------------> TEMPTABLE <-----------------
    vr_tab_co_responsavel empr0001.typ_tab_dados_epr;
            
    --------------> VARIAVEIS <-----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);    
    vr_exc_erro EXCEPTION;
    
    vr_dstexto      VARCHAR2(32767);
    vr_string       VARCHAR2(32767);    
    vr_index        PLS_INTEGER;
    
    
  BEGIN
    
    pc_busca_operacoes(pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                      ,pr_nrdconta => pr_nrdconta  --> Numero da conta
                      ,pr_dtmvtolt => pr_dtmvtolt  --> Data de movimento
                      ,pr_vldscchq => pr_vldscchq  --> Valor de cheque
                      ,pr_vlutlchq => pr_vlutlchq  --> Valor do ultimo cheque                              
                      ,pr_vldctitu => pr_vldctitu  --> Valor de titulo de descont0
                      ,pr_vlutitit => pr_vlutitit  --> Valor do ultimo titulo de desconto                                                                 
                      ------ OUT ------                                      
                      ,pr_tab_co_responsavel => vr_tab_co_responsavel --> Retorna dados
                      ,pr_dscritic     => vr_dscritic      --> Descrição da critica
                      ,pr_cdcritic     => vr_cdcritic);    --> Codigo da critica                               
    
    IF TRIM(vr_dscritic) IS NOT NULL OR 
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;   
    
    -- Criar documento XML
    dbms_lob.createtemporary(pr_xml_co_responsavel, TRUE); 
    dbms_lob.open(pr_xml_co_responsavel, dbms_lob.lob_readwrite);
        
	gene0002.pc_escreve_xml(pr_xml            => pr_xml_co_responsavel 
                           ,pr_texto_completo => vr_dstexto 
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?> ');
        
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_co_responsavel 
                           ,pr_texto_completo => vr_dstexto 
                           ,pr_texto_novo     => '<root>');
    --Montar CLOB
    IF vr_tab_co_responsavel.COUNT > 0 THEN
         
      --Buscar Primeiro beneficiario
      vr_index := vr_tab_co_responsavel.FIRST;

      --Percorrer todos os beneficiarios
      WHILE vr_index IS NOT NULL LOOP
        vr_string := '<responsavel>'||
                         '<nrdconta>'|| vr_tab_co_responsavel(vr_index).nrdconta  ||'</nrdconta>'||
                         '<nrctremp>'|| vr_tab_co_responsavel(vr_index).nrctremp  ||'</nrctremp>'||
                         '<vlsdeved>'|| vr_tab_co_responsavel(vr_index).vlsdeved  ||'</vlsdeved>'||
                         '<dsfinemp>'|| vr_tab_co_responsavel(vr_index).dsfinemp  ||'</dsfinemp>'||
                         '<dslcremp>'|| vr_tab_co_responsavel(vr_index).dslcremp  ||'</dslcremp>'||
                     '</responsavel>';
        
        -- Escrever no XML
        gene0002.pc_escreve_xml(pr_xml            => pr_xml_co_responsavel 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => vr_string
                               ,pr_fecha_xml      => FALSE);   
                                      
        vr_index := vr_tab_co_responsavel.next(vr_index);
      END LOOP;
      
    END IF;  
    -- Encerrar a tag raiz 
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_co_responsavel 
                           ,pr_texto_completo => vr_dstexto 
                           ,pr_texto_novo     => '</root>' 
                           ,pr_fecha_xml      => TRUE);
      
  EXCEPTION 
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN

      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_busca_operacoes ' ||
                     SQLERRM;      
  END pc_busca_operacoes_prog;
  
  /******************************************************************************/
  /**            Procedure para retornar dados dos co-reponsaveis              **/
  /******************************************************************************/
  PROCEDURE pc_gera_co_responsavel
                              (pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo da cooperativa
                              ,pr_cdagenci IN crapage.cdagenci%TYPE      --> Codigo de agencia 
                              ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE      --> Numero do caixa
                              ,pr_cdoperad IN crapope.cdoperad%TYPE      --> Codigo do operador
                              ,pr_nmdatela IN craptel.nmdatela%TYPE      --> Nome da tela
                              ,pr_idorigem IN INTEGER                    --> Identificado de oriem
                              ,pr_cdprogra IN crapprg.cdprogra%TYPE      --> Codigo do programa 
                              ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Numero da conta
                              ,pr_idseqttl IN crapttl.idseqttl%TYPE      --> Sequencial do titular
                              ,pr_dtcalcul IN DATE                       --> Data do calculo                                                           
                              ,pr_flgerlog IN VARCHAR2                   --> identificador se deve gerar log S-Sim e N-Nao
                              ,pr_vldscchq IN OUT crapcdb.vlcheque%TYPE  --> Valor de cheque
                              ,pr_vlutlchq IN OUT crapcdb.vlcheque%TYPE  --> Valor do ultimo cheque                              
                              ,pr_vldctitu IN OUT craptdb.vltitulo%TYPE  --> Valor de titulo de descont0
                              ,pr_vlutitit IN OUT craptdb.vltitulo%TYPE  --> Valor do ultimo titulo de desconto                                                                 
                              ------ OUT ------                                      
                              ,pr_tab_co_responsavel IN OUT empr0001.typ_tab_dados_epr --> Retorna dados
                              ,pr_dscritic     OUT VARCHAR2          --> Descrição da critica
                              ,pr_cdcritic     OUT INTEGER) IS       --> Codigo da critica
     
  /* ..........................................................................
    --
    --  Programa : pc_gera_co_responsavel        Antiga: b1wgen0002i.p/gera_co_responsavel
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Abril/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para retornar dados dos co-reponsaveis.
    --
    --  Alteração : 
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------    
    
    --> Buscar emprestimos dos avalistas da conta
    CURSOR cr_crapepr ( pr_cdcooper  craplim.cdcooper%TYPE,
                        pr_nrdconta  craplim.nrdconta%TYPE) IS
      SELECT  epr.nrdconta
             ,epr.nrctremp
             ,ass.nmprimtl
        FROM crapavl avl
            ,crapepr epr
            ,crapass ass
       WHERE epr.cdcooper = ass.cdcooper
         AND epr.nrdconta = ass.nrdconta         
         AND epr.cdcooper = avl.cdcooper
         AND epr.nrdconta = avl.nrctaavd
         AND epr.nrctremp = avl.nrctravd
         AND avl.cdcooper = pr_cdcooper
         AND avl.nrdconta = pr_nrdconta;
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    
    --------------> TEMPTABLE <-----------------
    -- variaveis de retorno
    vr_tab_dados_epr empr0001.typ_tab_dados_epr;
    vr_tab_erro      gene0001.typ_tab_erro;
            
    --------------> VARIAVEIS <-----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);    
    vr_exc_erro EXCEPTION;
    vr_des_reto VARCHAR2(3);
    
    --Variaveis para busca de parametros
    vr_dstextab            craptab.dstextab%TYPE;
    vr_dstextab_parempctl  craptab.dstextab%TYPE;
    vr_dstextab_digitaliza craptab.dstextab%TYPE;
    
    --Indicador de utilização da tabela
    vr_inusatab            BOOLEAN;

    vr_qtregist            NUMBER;  
    vr_idx                 PLS_INTEGER;
    vr_idx_res             PLS_INTEGER;
    vr_flachou             BOOLEAN;
    
  BEGIN
  
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
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- busca o tipo de documento GED
    vr_dstextab_digitaliza := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                        ,pr_nmsistem => 'CRED'
                                                        ,pr_tptabela => 'GENERI'
                                                        ,pr_cdempres => 00
                                                        ,pr_cdacesso => 'DIGITALIZA'
                                                        ,pr_tpregist => 5);

    -- Leitura do indicador de uso da tabela de taxa de juros
    vr_dstextab_parempctl := tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                                       ,pr_nmsistem => 'CRED'
                                                       ,pr_tptabela => 'USUARI'
                                                       ,pr_cdempres => 11
                                                       ,pr_cdacesso => 'PAREMPCTL'
                                                       ,pr_tpregist => 01);


    --Buscar Indicador Uso tabela
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'USUARI'
                                            ,pr_cdempres => 11
                                            ,pr_cdacesso => 'TAXATABELA'
                                            ,pr_tpregist => 0);
    --Se nao encontrou
    IF vr_dstextab IS NULL THEN
      --Nao usa tabela
      vr_inusatab:= FALSE;
    ELSE
      IF  SUBSTR(vr_dstextab,1,1) = '0' THEN
        --Nao usa tabela
        vr_inusatab:= FALSE;
      ELSE
        --Nao usa tabela
        vr_inusatab:= TRUE;
      END IF;
    END IF;
  
    
    --> Buscar emprestimos dos avalistas da conta
    FOR rw_crapepr IN  cr_crapepr( pr_cdcooper  => pr_cdcooper,
                                   pr_nrdconta  => pr_nrdconta) LOOP
      
      /* Procedure para obter dados de emprestimos do associado */
      empr0001.pc_obtem_dados_empresti
                             (pr_cdcooper       => pr_cdcooper           --> Cooperativa conectada
                             ,pr_cdagenci       => pr_cdagenci           --> Código da agência
                             ,pr_nrdcaixa       => pr_nrdcaixa           --> Número do caixa
                             ,pr_cdoperad       => pr_cdoperad           --> Código do operador
                             ,pr_nmdatela       => pr_nmdatela           --> Nome datela conectada
                             ,pr_idorigem       => pr_idorigem           --> Indicador da origem da chamada
                             ,pr_nrdconta       => rw_crapepr.nrdconta   --> Conta do associado
                             ,pr_idseqttl       => pr_idseqttl           --> Sequencia de titularidade da conta
                             ,pr_rw_crapdat     => rw_crapdat            --> Vetor com dados de parâmetro (CRAPDAT)
                             ,pr_dtcalcul       => pr_dtcalcul           --> Data solicitada do calculo
                             ,pr_nrctremp       => rw_crapepr.nrctremp   --> Número contrato empréstimo
                             ,pr_cdprogra       => pr_cdprogra           --> Programa conectado
                             ,pr_inusatab       => vr_inusatab           --> Indicador de utilização da tabela
                             ,pr_flgerlog       => pr_flgerlog           --> Gerar log S/N
                             ,pr_flgcondc       => TRUE                  --> Mostrar emprestimos liquidados sem prejuizo
                             ,pr_nmprimtl       => rw_crapepr.nmprimtl   --> Nome Primeiro Titular
                             ,pr_tab_parempctl  => vr_dstextab_parempctl --> Dados tabela parametro
                             ,pr_tab_digitaliza => vr_dstextab_digitaliza--> Dados tabela parametro
                             ,pr_nriniseq       => 0                     --> Numero inicial da paginacao
                             ,pr_nrregist       => 0                     --> Numero de registros por pagina
                             ,pr_qtregist       => vr_qtregist           --> Qtde total de registros
                             ,pr_tab_dados_epr  => vr_tab_dados_epr      --> Saida com os dados do empréstimo
                             ,pr_des_reto       => vr_des_reto           --> Retorno OK / NOK
                             ,pr_tab_erro       => vr_tab_erro);         --> Tabela com possíves erros

      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN

          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        ELSE
          vr_dscritic := 'Não foi possivel obter dados de emprestimos.';
        END IF;
        RAISE vr_exc_erro;
        
      END IF;
    
    vr_idx := vr_tab_dados_epr.first;
    
    WHILE vr_idx IS NOT NULL LOOP
    
      --> Verificar se emprestimo ja esta na lista
      vr_idx_res := pr_tab_co_responsavel.first;
      vr_flachou := FALSE;
      WHILE vr_idx_res IS NOT NULL LOOP
        IF pr_tab_co_responsavel(vr_idx_res).nrdconta = vr_tab_dados_epr(vr_idx).nrdconta AND 
           pr_tab_co_responsavel(vr_idx_res).nrctremp = vr_tab_dados_epr(vr_idx).nrctremp THEN
          vr_flachou := TRUE;
          EXIT;  
        END IF;
        vr_idx_res := pr_tab_co_responsavel.next(vr_idx_res);
      END LOOP;
      
      --> Se nao encontrou, popular
      IF vr_flachou = FALSE THEN
        vr_idx_res := pr_tab_co_responsavel.count;
        pr_tab_co_responsavel(vr_idx_res) := vr_tab_dados_epr(vr_idx);
      END IF;
    
      vr_idx := vr_tab_dados_epr.next(vr_idx);  
    END LOOP;
    
    
    END LOOP;   
    
    
    --> Verifica se tem desconto de cheque ou titulo                            
    pc_busca_operacoes ( pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                        ,pr_nrdconta => pr_nrdconta  --> Numero da conta
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data de movimento
                        ,pr_vldscchq => pr_vldscchq  --> Valor de cheque
                        ,pr_vlutlchq => pr_vlutlchq  --> Valor do ultimo cheque                              
                        ,pr_vldctitu => pr_vldctitu  --> Valor de titulo de descont0
                        ,pr_vlutitit => pr_vlutitit  --> Valor do ultimo titulo de desconto                                                                 
                        ------ OUT ------                                      
                        ,pr_tab_co_responsavel => pr_tab_co_responsavel --> Retorna dados
                        ,pr_dscritic     => vr_dscritic    --> Descrição da critica
                        ,pr_cdcritic     => vr_cdcritic);  --> Codigo da critica
    --> Versao progress nao trata retorno de critica                        
    
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN

      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_gera_co_responsavel ' ||
                     SQLERRM;      
  END pc_gera_co_responsavel;
  
  /******************************************************************************/
  /**   Procedure para retornar dados dos co-reponsaveis - Chamada progress    **/
  /******************************************************************************/
  PROCEDURE pc_gera_co_responsavel_prog
                              (pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo da cooperativa
                              ,pr_cdagenci IN crapage.cdagenci%TYPE      --> Codigo de agencia 
                              ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE      --> Numero do caixa
                              ,pr_cdoperad IN crapope.cdoperad%TYPE      --> Codigo do operador
                              ,pr_nmdatela IN craptel.nmdatela%TYPE      --> Nome da tela
                              ,pr_idorigem IN INTEGER                    --> Identificado de oriem
                              ,pr_cdprogra IN crapprg.cdprogra%TYPE      --> Codigo do programa 
                              ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Numero da conta
                              ,pr_idseqttl IN crapttl.idseqttl%TYPE      --> Sequencial do titular
                              ,pr_dtcalcul IN DATE                       --> Data do calculo                                                           
                              ,pr_flgerlog IN VARCHAR2                   --> identificador se deve gerar log S-Sim e N-Nao
                              ,pr_vldscchq IN OUT crapcdb.vlcheque%TYPE  --> Valor de cheque
                              ,pr_vlutlchq IN OUT crapcdb.vlcheque%TYPE  --> Valor do ultimo cheque                              
                              ,pr_vldctitu IN OUT craptdb.vltitulo%TYPE  --> Valor de titulo de descont0
                              ,pr_vlutitit IN OUT craptdb.vltitulo%TYPE  --> Valor do ultimo titulo de desconto                                                                 
                              ------ OUT ------                                      
                              ,pr_xml_co_responsavel OUT CLOB --> Retorna dados
                              ,pr_dscritic     OUT VARCHAR2          --> Descrição da critica
                              ,pr_cdcritic     OUT INTEGER) IS       --> Codigo da critica
     
  /* ..........................................................................
    --
    --  Programa : pc_gera_co_responsavel        Antiga: b1wgen0002i.p/gera_co_responsavel
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Abril/2017.                   Ultima atualizacao: 06/10/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para retornar dados dos co-reponsaveis.
    --
    --  Alteração : 
	--              06/10/2017 - SD770151 - Correção de informações na proposta de 
	--              empréstimo convertida (Marcos-Supero)
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------    
    
    --------------> TEMPTABLE <-----------------
    vr_tab_co_responsavel empr0001.typ_tab_dados_epr;
            
    --------------> VARIAVEIS <-----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);    
    vr_exc_erro EXCEPTION;
    
    vr_dstexto      VARCHAR2(32767);
    vr_string       VARCHAR2(32767);    
    vr_index        PLS_INTEGER;
    
  BEGIN
  
    pc_gera_co_responsavel ( pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                            ,pr_cdagenci => pr_cdagenci  --> Codigo de agencia 
                            ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa
                            ,pr_cdoperad => pr_cdoperad  --> Codigo do operador
                            ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                            ,pr_idorigem => pr_idorigem  --> Identificado de oriem
                            ,pr_cdprogra => pr_cdprogra  --> Codigo do programa 
                            ,pr_nrdconta => pr_nrdconta  --> Numero da conta
                            ,pr_idseqttl => pr_idseqttl  --> Sequencial do titular
                            ,pr_dtcalcul => pr_dtcalcul  --> Data do calculo                                                           
                            ,pr_flgerlog => pr_flgerlog  --> identificador se deve gerar log S-Sim e N-Nao
                            ,pr_vldscchq => pr_vldscchq  --> Valor de cheque
                            ,pr_vlutlchq => pr_vlutlchq  --> Valor do ultimo cheque                              
                            ,pr_vldctitu => pr_vldctitu  --> Valor de titulo de descont0
                            ,pr_vlutitit => pr_vlutitit  --> Valor do ultimo titulo de desconto                                                                 
                            ------ OUT ------                                      
                            ,pr_tab_co_responsavel => vr_tab_co_responsavel  --> Retorna dados
                            ,pr_dscritic           => vr_dscritic            --> Descrição da critica
                            ,pr_cdcritic           => vr_cdcritic );         --> Codigo da critica                 
    
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro ;
    END IF;   
    
    -- Criar documento XML
    dbms_lob.createtemporary(pr_xml_co_responsavel, TRUE); 
    dbms_lob.open(pr_xml_co_responsavel, dbms_lob.lob_readwrite);
        
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_co_responsavel 
                           ,pr_texto_completo => vr_dstexto 
                           ,pr_texto_novo     => '<root>');
    
    --Montar CLOB
    IF vr_tab_co_responsavel.COUNT > 0 THEN
        
      
         
      --Buscar Primeiro beneficiario
      vr_index := vr_tab_co_responsavel.FIRST;
        
      --Percorrer todos os beneficiarios
      WHILE vr_index IS NOT NULL LOOP
        vr_string := '<responsavel>'||
                         '<nrdconta>' || vr_tab_co_responsavel(vr_index).nrdconta ||'</nrdconta>'||
                         '<cdagenci>' || vr_tab_co_responsavel(vr_index).cdagenci ||'</cdagenci>'||
                         '<nmprimtl>' || vr_tab_co_responsavel(vr_index).nmprimtl ||'</nmprimtl>'||
                         '<nrctremp>' || vr_tab_co_responsavel(vr_index).nrctremp ||'</nrctremp>'||
                         '<vlemprst>' || vr_tab_co_responsavel(vr_index).vlemprst ||'</vlemprst>'||
                         '<vlsdeved>' || vr_tab_co_responsavel(vr_index).vlsdeved ||'</vlsdeved>'||
                         '<vlpreemp>' || vr_tab_co_responsavel(vr_index).vlpreemp ||'</vlpreemp>'||
                         '<vlprepag>' || vr_tab_co_responsavel(vr_index).vlprepag ||'</vlprepag>'||
                         '<txjuremp>' || to_char(vr_tab_co_responsavel(vr_index).txjuremp,'990D00000000') || '</txjuremp>' ||
                         '<vljurmes>' || vr_tab_co_responsavel(vr_index).vljurmes ||'</vljurmes>'||
                         '<vljuracu>' || vr_tab_co_responsavel(vr_index).vljuracu ||'</vljuracu>'||
                         '<vlprejuz>' || vr_tab_co_responsavel(vr_index).vlprejuz ||'</vlprejuz>'||
                         '<vlsdprej>' || vr_tab_co_responsavel(vr_index).vlsdprej ||'</vlsdprej>'||
                         '<dtprejuz>' || to_char(vr_tab_co_responsavel(vr_index).dtprejuz,'DD/MM/RRRR') ||'</dtprejuz>'||
                         '<vljrmprj>' || vr_tab_co_responsavel(vr_index).vljrmprj ||'</vljrmprj>'||
                         '<vljraprj>' || vr_tab_co_responsavel(vr_index).vljraprj ||'</vljraprj>'||
                         '<inprejuz>' || vr_tab_co_responsavel(vr_index).inprejuz ||'</inprejuz>'||
                         '<vlprovis>' || vr_tab_co_responsavel(vr_index).vlprovis ||'</vlprovis>'||
                         '<flgpagto>' || (CASE vr_tab_co_responsavel(vr_index).flgpagto 
                                            WHEN 1 THEN 'yes'
                                            ELSE 'no' 
                                          END)                                    || '</flgpagto>' ||
                         '<dtdpagto>' || to_char(vr_tab_co_responsavel(vr_index).dtdpagto,'DD/MM/RRRR') || '</dtdpagto>' ||
                         '<cdpesqui>' || vr_tab_co_responsavel(vr_index).cdpesqui ||'</cdpesqui>'||
                         '<dspreapg>' || gene0007.fn_caract_acento(vr_tab_co_responsavel(vr_index).dspreapg,1) ||'</dspreapg>'||
                         '<cdlcremp>' || vr_tab_co_responsavel(vr_index).cdlcremp ||'</cdlcremp>'||
                         '<dslcremp>' || vr_tab_co_responsavel(vr_index).dslcremp ||'</dslcremp>'||
                         '<cdfinemp>' || vr_tab_co_responsavel(vr_index).cdfinemp ||'</cdfinemp>'||
                         '<dsfinemp>' || vr_tab_co_responsavel(vr_index).dsfinemp ||'</dsfinemp>'||
                         '<dsdaval1>' || vr_tab_co_responsavel(vr_index).dsdaval1 ||'</dsdaval1>'||
                         '<dsdaval2>' || vr_tab_co_responsavel(vr_index).dsdaval2 ||'</dsdaval2>'||
                         '<vlpreapg>' || nvl(vr_tab_co_responsavel(vr_index).vlpreapg,0) || '</vlpreapg>' ||
                         '<qtmesdec>' || vr_tab_co_responsavel(vr_index).qtmesdec ||'</qtmesdec>'||
                         '<qtprecal>' || vr_tab_co_responsavel(vr_index).qtprecal ||'</qtprecal>'||
                         '<vlacresc>' || vr_tab_co_responsavel(vr_index).vlacresc ||'</vlacresc>'||
                         '<vlrpagos>' || vr_tab_co_responsavel(vr_index).vlrpagos ||'</vlrpagos>'||
                         '<slprjori>' || vr_tab_co_responsavel(vr_index).slprjori ||'</slprjori>'||
                         '<dtmvtolt>' || to_char(vr_tab_co_responsavel(vr_index).dtmvtolt,'DD/MM/RRRR') || '</dtmvtolt>' ||
                         '<qtpreemp>' || vr_tab_co_responsavel(vr_index).qtpreemp ||'</qtpreemp>'||
                         '<dtultpag>' || to_char(vr_tab_co_responsavel(vr_index).dtultpag,'DD/MM/RRRR') || '</dtultpag>' ||
                         '<vlrabono>' || vr_tab_co_responsavel(vr_index).vlrabono ||'</vlrabono>'||
                         '<qtaditiv>' || vr_tab_co_responsavel(vr_index).qtaditiv ||'</qtaditiv>'||
                         '<dsdpagto>' || vr_tab_co_responsavel(vr_index).dsdpagto ||'</dsdpagto>'||
                         '<dsdavali>' || vr_tab_co_responsavel(vr_index).dsdavali ||'</dsdavali>'||
                         '<qtmesatr>' || vr_tab_co_responsavel(vr_index).qtmesatr ||'</qtmesatr>'||
                         '<qtpromis>' || vr_tab_co_responsavel(vr_index).qtpromis ||'</qtpromis>'||
                         '<flgimppr>' || (CASE vr_tab_co_responsavel(vr_index).flgimppr 
                                            WHEN 1 THEN 'yes'
                                            ELSE 'no' 
                                          END)                              || '</flgimppr>' ||
                        '<flgimpnp>' || (CASE vr_tab_co_responsavel(vr_index).flgimpnp 
                                            WHEN 1 THEN 'yes'
                                            ELSE 'no' 
                                          END) ||'</flgimpnp>' ||
                         '<idseleca>' || vr_tab_co_responsavel(vr_index).idseleca ||'</idseleca>'||
                         '<nrdrecid>' || vr_tab_co_responsavel(vr_index).nrdrecid ||'</nrdrecid>'||
                         '<tplcremp>' || vr_tab_co_responsavel(vr_index).tplcremp ||'</tplcremp>'||
                         '<tpemprst>' || vr_tab_co_responsavel(vr_index).tpemprst ||'</tpemprst>'||
                         '<cdtpempr>' || vr_tab_co_responsavel(vr_index).cdtpempr ||'</cdtpempr>'||
                         '<dstpempr>' || gene0007.fn_caract_acento(vr_tab_co_responsavel(vr_index).dstpempr,1) ||'</dstpempr>'||
                         '<permulta>' || vr_tab_co_responsavel(vr_index).permulta ||'</permulta>'||
                         '<perjurmo>' || vr_tab_co_responsavel(vr_index).perjurmo ||'</perjurmo>'||
                         '<dtpripgt>' || to_char(vr_tab_co_responsavel(vr_index).dtpripgt,'DD/MM/RRRR') || '</dtpripgt>' ||
                         '<inliquid>' || vr_tab_co_responsavel(vr_index).inliquid ||'</inliquid>'||
                         '<txmensal>' || vr_tab_co_responsavel(vr_index).txmensal ||'</txmensal>'||
                         '<flgatras>' || (CASE vr_tab_co_responsavel(vr_index).flgatras
                                            WHEN 1 THEN 'yes'
                                            ELSE 'no' 
                                          END)                              || '</flgatras>' ||
                         '<dsidenti>' || vr_tab_co_responsavel(vr_index).dsidenti ||'</dsidenti>'||
                         '<flgdigit>' || (CASE vr_tab_co_responsavel(vr_index).flgdigit
                                            WHEN 1 THEN 'yes'
                                            ELSE 'no' 
                                          END)                              || '</flgdigit>' ||
                         '<tpdocged>' || vr_tab_co_responsavel(vr_index).tpdocged ||'</tpdocged>'||
                         '<vlpapgat>' || vr_tab_co_responsavel(vr_index).vlpapgat ||'</vlpapgat>'||
                         '<vlsdevat>' || vr_tab_co_responsavel(vr_index).vlsdevat ||'</vlsdevat>'||
                         '<qtpcalat>' || vr_tab_co_responsavel(vr_index).qtpcalat ||'</qtpcalat>'||
                         '<qtmdecat>' || vr_tab_co_responsavel(vr_index).qtmdecat ||'</qtmdecat>'||
                         '<tpdescto>' || vr_tab_co_responsavel(vr_index).tpdescto ||'</tpdescto>'||
                         '<qtlemcal>' || vr_tab_co_responsavel(vr_index).qtlemcal ||'</qtlemcal>'||
                         '<vlppagat>' || vr_tab_co_responsavel(vr_index).vlppagat ||'</vlppagat>'||
                         '<vlmrapar>' || vr_tab_co_responsavel(vr_index).vlmrapar ||'</vlmrapar>'||
                         '<vliofcpl>' || vr_tab_co_responsavel(vr_index).vliofcpl ||'</vliofcpl>'||
                         '<vlmtapar>' || vr_tab_co_responsavel(vr_index).vlmtapar ||'</vlmtapar>'||
                         '<vltotpag>' || vr_tab_co_responsavel(vr_index).vltotpag ||'</vltotpag>'||
                         '<vlprvenc>' || vr_tab_co_responsavel(vr_index).vlprvenc ||'</vlprvenc>'||
                         '<vlpraven>' || vr_tab_co_responsavel(vr_index).vlpraven ||'</vlpraven>'||
                         '<flgpreap>' || (CASE WHEN vr_tab_co_responsavel(vr_index).flgpreap THEN 'yes'
                                              ELSE 'no' END) || '</flgpreap>' ||
                         '<cdorigem>' || vr_tab_co_responsavel(vr_index).cdorigem ||'</cdorigem>'||
                         '<vlttmupr>' || vr_tab_co_responsavel(vr_index).vlttmupr ||'</vlttmupr>'||
                         '<vlttjmpr>' || vr_tab_co_responsavel(vr_index).vlttjmpr ||'</vlttjmpr>'||
                         '<vlpgmupr>' || vr_tab_co_responsavel(vr_index).vlpgmupr ||'</vlpgmupr>'||
                         '<vlpgjmpr>' || vr_tab_co_responsavel(vr_index).vlpgjmpr ||'</vlpgjmpr>'||
                         '<percetop>' || vr_tab_co_responsavel(vr_index).percetop ||'</percetop>'||
                         '<cdmodali>' || vr_tab_co_responsavel(vr_index).cdmodali ||'</cdmodali>'||
                         '<dsmodali>' || vr_tab_co_responsavel(vr_index).dsmodali ||'</dsmodali>'||
                         '<cdsubmod>' || vr_tab_co_responsavel(vr_index).cdsubmod ||'</cdsubmod>'||
                         '<dssubmod>' || vr_tab_co_responsavel(vr_index).dssubmod ||'</dssubmod>'||
                         '<txanual> ' || vr_tab_co_responsavel(vr_index).txanual  ||'</txanual> '||
                         '<qtpreapg>' || vr_tab_co_responsavel(vr_index).qtpreapg ||'</qtpreapg>'||
                         '<liquidia>' || vr_tab_co_responsavel(vr_index).liquidia ||'</liquidia>'||
                         '<qtimpctr>' || vr_tab_co_responsavel(vr_index).qtimpctr ||'</qtimpctr>'||
                         '<portabil>' || vr_tab_co_responsavel(vr_index).portabil ||'</portabil>'||
                         '<dsorgrec>' || vr_tab_co_responsavel(vr_index).dsorgrec ||'</dsorgrec>'||
                         '<dtinictr>' || vr_tab_co_responsavel(vr_index).dtinictr ||'</dtinictr>'||
                      '</responsavel>';
        
        -- Escrever no XML
        gene0002.pc_escreve_xml(pr_xml            => pr_xml_co_responsavel 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => vr_string
                               ,pr_fecha_xml      => FALSE);   
                                      
        vr_index := vr_tab_co_responsavel.next(vr_index);
      END LOOP;
      
    END IF;
    
    -- Encerrar a tag raiz 
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_co_responsavel 
                           ,pr_texto_completo => vr_dstexto 
                           ,pr_texto_novo     => '</root>' 
                           ,pr_fecha_xml      => TRUE);
      
  EXCEPTION 
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN

      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_gera_co_responsavel ' ||
                     SQLERRM;      
  END pc_gera_co_responsavel_prog;
  
  PROCEDURE pc_impr_dec_rec_ise_iof_xml(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da Cooperativa
									   ,pr_nrdconta IN crapepr.nrdconta%TYPE  --> Numero da conta
									   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE  --> Numero do CPF
                                       ,pr_nrctrato IN crapepr.nrctremp%TYPE  --> Numero do contrato
									   ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
									   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da critica
									   ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
									   ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
									   ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
									   ,pr_des_erro OUT VARCHAR2) IS          --> Descrição do erro
	/* .............................................................................
	   Programa: pc_imprime_declaracao_recursos_isencao_iof_xml
	   Sistema : Conta-Corrente - Cooperativa de Credito
	   Sigla   : CRED
	   Autor   : Diogo (Mouts)
	   Data    : Outubro/2017.                         Ultima atualizacao: 04/10/2017
	   Dados referentes ao programa:
	   Frequencia: Sempre que for chamado.
	   Objetivo  : Efetuar a impressao da Declaração de Utilização de Recursos para Isenção de IOF
	   Alteracoes: 
	............................................................................. */
	-- Cursor com os dados do cooperado
      CURSOR cr_crapass (pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                        ,pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrctrato IN crapepr.nrctremp%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
		SELECT crapass.nrdconta,
			   gene0002.fn_mask_cpf_cnpj(crapass.nrcpfcgc, crapass.inpessoa) AS nrcpfcgc,
			   crapass.nmprimtl,
			   crapenc.nrcepend,
			   crapenc.dsendere,
			   crapenc.nrendere,
			   nvl(crapenc.complend,'') as complend,
			   nvl(crapenc.nmbairro,'') as nmbairro,
			   nvl(crapenc.nmcidade,'') as nmcidade,
			   nvl(crapenc.cdufende,'') as cdufende,
			   nvl(crapenc.nrcxapst,'') as nrcxapst,
			   nvl(crapnac.dsnacion,'') as dsnacion,
			   nvl(gnetcvl.rsestcvl,'') as rsestcvl, 
		       nvl(crapttl.dsproftl,'') as dsproftl,
               crawepr.nrctremp,
			   crapcop.nmextcop,
			   crapass.inpessoa
		FROM crapass
		INNER JOIN crapcop ON crapcop.cdcooper = crapass.cdcooper
		LEFT JOIN crapenc ON crapenc.nrdconta = crapass.nrdconta AND crapenc.idseqttl = 1 AND crapenc.cdseqinc = 1 AND crapenc.cdcooper = crapass.cdcooper
		LEFT JOIN crapttl ON crapttl.nrdconta = crapass.nrdconta AND crapttl.nrcpfcgc = crapass.nrcpfcgc AND crapttl.cdcooper = crapass.cdcooper
        LEFT JOIN crawepr ON crawepr.cdcooper = crapass.cdcooper AND crawepr.nrdconta = crapass.nrdconta
		LEFT JOIN crapnac ON crapnac.cdnacion = crapass.cdnacion
		LEFT JOIN gnetcvl ON gnetcvl.cdestcvl = crapttl.cdestcvl
		WHERE crapass.nrdconta = pr_nrdconta
			  AND crapass.nrcpfcgc = pr_nrcpfcgc
			  AND crapass.cdcooper = pr_cdcooper
              AND crawepr.nrctremp = pr_nrctrato;
		rw_crapass cr_crapass%ROWTYPE;
		-- Tratamento de erros
		vr_exc_saida EXCEPTION;
		vr_cdcritic PLS_INTEGER;
		vr_dscritic VARCHAR2(4000);
		-- Variaveis gerais
		vr_texto_completo VARCHAR2(32600); --> Variável para armazenar os dados do XML antes de incluir no CLOB
		vr_des_xml        CLOB; --> XML do relatorio
		vr_cdprogra       VARCHAR2(10) := 'EMPR0003'; --> Nome do programa
		rw_crapdat        btch0001.cr_crapdat%ROWTYPE; --> Cursor genérico de calendário
		vr_nom_direto     VARCHAR2(200); --> Diretório para gravação do arquivo
		vr_nmarqimp       VARCHAR2(50); --> nome do arquivo PDF
		vr_temp           VARCHAR2(1000); --> Temporária para gravação do texto XML
		-- variaveis de críticas
		vr_tab_erro  GENE0001.typ_tab_erro;
		vr_des_reto  VARCHAR2(10);
		vr_typ_saida VARCHAR2(3);
		BEGIN
			-- Leitura do calendário da cooperativa
			OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
			FETCH btch0001.cr_crapdat
					INTO rw_crapdat;
			CLOSE btch0001.cr_crapdat;
      
			--Informações do associado
			OPEN cr_crapass(pr_nrcpfcgc => pr_nrcpfcgc
						   ,pr_cdcooper => pr_cdcooper
						   ,pr_nrctrato => pr_nrctrato
						   ,pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO rw_crapass;
			
			--Validações
			IF cr_crapass%NOTFOUND THEN
				CLOSE cr_crapass;
			    vr_cdcritic := 0;
				vr_dscritic := 'Registro nao localizado!';
			    RAISE vr_exc_saida;
			END IF;
			IF rw_crapass.inpessoa <> 1 THEN
			    CLOSE cr_crapass;
			    vr_cdcritic := 0;
				vr_dscritic := 'Declaracao deve ser emitida apenas para pessoa fisica!';
			    RAISE vr_exc_saida;
			END IF;
			CLOSE cr_crapass;
  
			--XML de envio
			vr_temp := '<?xml version="1.0" encoding="utf-8"?>' ||
						 '<associado>' || 
							 '<nrdconta>' || rw_crapass.nrdconta || '</nrdconta>' || 
							 '<nrcpfcgc>' || rw_crapass.nrcpfcgc || '</nrcpfcgc>' || 
							 '<nmprimtl>' || rw_crapass.nmprimtl || '</nmprimtl>' ||
							 '<nrcepend>' || rw_crapass.nrcepend || '</nrcepend>' || 
							 '<dsendere>' || rw_crapass.dsendere || '</dsendere>' || 
							 '<nrendere>' || rw_crapass.nrendere || '</nrendere>' || 
							 '<complend>' || rw_crapass.complend || '</complend>' ||
							 '<nmbairro>' || rw_crapass.nmbairro || '</nmbairro>' || 
							 '<nmcidade>' || rw_crapass.nmcidade || '</nmcidade>' || 
							 '<cdufende>' || rw_crapass.cdufende || '</cdufende>' || 
							 '<nrcxapst>' || rw_crapass.nrcxapst || '</nrcxapst>' ||
							 '<dsnacion>' || rw_crapass.dsnacion || '</dsnacion>' || 
							 '<rsestcvl>' || rw_crapass.rsestcvl || '</rsestcvl>' ||
							 '<dsproftl>' || rw_crapass.dsproftl || '</dsproftl>' ||
							 '<nrctremp>' || rw_crapass.nrctremp || '</nrctremp>' ||
							 '<nmextcop>' || rw_crapass.nmextcop || '</nmextcop>' ||
						'</associado>';
			-- Inicializar o CLOB
			vr_des_xml := NULL;
			dbms_lob.createtemporary(vr_des_xml, TRUE);
			dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
			-- Escreve o XML no CLOB
			vr_texto_completo := NULL;
			gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, vr_temp, TRUE);
			-- Busca diretorio padrao da cooperativa
			vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
												  ,pr_cdcooper => pr_cdcooper
												  ,pr_nmsubdir => 'arquivos');
			-- Solicita geracao do PDF
			vr_nmarqimp := '/dec_isencao_iof_' || pr_nrdconta || pr_nrcpfcgc || '.pdf';
			gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,
										pr_cdprogra  => vr_cdprogra,
										pr_dtmvtolt  => rw_crapdat.dtmvtolt,
										pr_dsxml     => vr_des_xml,
										pr_dsxmlnode => '/',
										pr_dsjasper  => 'dec_isencao_iof.jasper',
										pr_dsparams  => NULL,
										pr_dsarqsaid => vr_nom_direto || vr_nmarqimp,
										pr_flg_gerar => 'S',
										pr_qtcoluna  => 234,
										pr_sqcabrel  => 1,
										pr_flg_impri => 'S',
										pr_nmformul  => ' ',
										pr_nrcopias  => 1,
										pr_nrvergrl  => 1,
										pr_parser    => 'R', --> Seleciona o tipo do parser. "D" para VTD e "R" para Jasper padrão
										pr_des_erro  => vr_dscritic);
			IF vr_dscritic IS NOT NULL THEN
				-- verifica retorno se houve erro
				RAISE vr_exc_saida; -- encerra programa
			END IF;
			-- copia o pdf do diretorio da cooperativa para servidor web
			gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper,
										 pr_cdagenci => NULL,
										 pr_nrdcaixa => NULL,
										 pr_nmarqpdf => vr_nom_direto || vr_nmarqimp,
										 pr_des_reto => vr_des_reto,
										 pr_tab_erro => vr_tab_erro);
			-- caso apresente erro na operação
			IF nvl(vr_des_reto, 'OK') <> 'OK' THEN
				IF vr_tab_erro.COUNT > 0 THEN
					-- verifica pl-table se existe erros
					vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
					vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
					RAISE vr_exc_saida; -- encerra programa
				END IF;
			END IF;
			-- Remover relatorio do diretorio padrao da cooperativa
			gene0001.pc_OScommand(pr_typ_comando => 'S',
								  pr_des_comando => 'rm ' || vr_nom_direto || vr_nmarqimp,
								  pr_typ_saida   => vr_typ_saida,
								  pr_des_saida   => vr_dscritic);
			-- Se retornou erro
			IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT NULL THEN
				-- Concatena o erro que veio
				vr_dscritic := 'Erro ao remover arquivo: ' || vr_dscritic;
				RAISE vr_exc_saida; -- encerra programa
			END IF;
			-- Liberando a memória alocada pro CLOB
			dbms_lob.close(vr_des_xml);
			dbms_lob.freetemporary(vr_des_xml);
			vr_nmarqimp := substr(vr_nmarqimp, 2); -- retornar somente o nome do PDF sem a barra"/"
			-- Criar XML de retorno para uso na Web
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||
											vr_nmarqimp || '</nmarqpdf>');
			COMMIT;
		EXCEPTION
			WHEN vr_exc_saida THEN
				-- Se foi retornado apenas código
				IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
						-- Buscar a descrição
						vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;
				-- Devolvemos código e critica encontradas das variaveis locais
				pr_cdcritic := NVL(vr_cdcritic, 0);
				pr_dscritic := vr_dscritic;
				-- Carregar XML padrão para variável de retorno não utilizada.
				-- Existe para satisfazer exigência da interface.
				pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
												 upper(pr_dscritic) || '</Erro></Root>');
				ROLLBACK;
			WHEN OTHERS THEN
				-- Efetuar retorno do erro não tratado
				pr_cdcritic := 0;
				pr_dscritic := SQLERRM;
				-- Carregar XML padrão para variável de retorno não utilizada.
				-- Existe para satisfazer exigência da interface.
				pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
											 upper(pr_dscritic) || '</Erro></Root>');
				ROLLBACK;
		END pc_impr_dec_rec_ise_iof_xml;
--
PROCEDURE pc_imprime_contrato_prest(pr_cdcooper IN crapcop.cdcooper%TYPE              --> Codigo da Cooperativa
                                     ,pr_nrdconta IN crapepr.nrdconta%TYPE              --> Numero da conta do emprestimo
                                     ,pr_nrctremp IN crapepr.nrctremp%TYPE              --> Numero do contrato de emprestimo
                                     ,pr_inimpctr IN INTEGER DEFAULT 0                  --> Impressao de contratos nao negociaveis
                                     ,pr_nrctrseg IN crawseg.nrctrseg%TYPE  --> Proposta
                                     ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                          --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS 
  /* .............................................................................
     Programa: pc_imprime_contrato_prest
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Rafael Muniz Monteiro (Mouts)
     Data    : Setembro/2018.                         Ultima atualizacao: 

     Frequencia: Sempre que for chamado.
     Objetivo  : Efetuar a impressao da do contrato de empréstimo junto ao seguro prestamista
     
     Alteracoes: 
     
  ............................................................................. */
   --
    -- Cursor da data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic VARCHAR2(10000) := NULL;
    vr_des_reto VARCHAR2(20) := 'OK';
    -- Tabela de erros
    vr_tab_erro GENE0001.typ_tab_erro; 
    vr_typ_saida      VARCHAR2(3);   

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_dsdireto_emp VARCHAR2(4000);
    vr_dsdireto_pre VARCHAR2(4000);
    vr_nmarqimp_emp VARCHAR2(200);
    vr_nmarqimp_pre VARCHAR2(200) := 'TRUE';
    
    -- Variaveis gerais

    vr_nmarqpdf   VARCHAR2(1000);   
    vr_nrctrseg   crawseg.nrctrseg%type;
    
    /*Validar se existe proposta prestamista para contrato*/  
    cursor c_crawseg(p_cdcooper in number,
                     p_nrdconta in number,
                     p_nrctrato in number) is
    select s.nrctrseg
      from crawseg s
     where s.cdcooper = p_cdcooper
       and s.nrdconta = p_nrdconta
       and s.nrctrato = p_nrctrato;
       --
       r_crawseg c_crawseg%rowtype;    

    PROCEDURE pc_imprime_contrato_emprestimo(pr_cdcooper   IN crapcop.cdcooper%TYPE              --> Codigo da Cooperativa
                                            ,pr_nrdconta   IN crapepr.nrdconta%TYPE              --> Numero da conta do emprestimo
                                            ,pr_nrctremp   IN crapepr.nrctremp%TYPE              --> Numero do contrato de emprestimo
                                            ,pr_inimpctr   IN INTEGER DEFAULT 0                  --> Impressao de contratos nao negociaveis
                                            ,pr_nom_direto OUT VARCHAR2
                                            ,pr_nmarqimp   OUT VARCHAR2
                                            ,pr_cdcritic   OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                            ,pr_dscritic   OUT VARCHAR2                          --> Descricao da critica
                                            ) IS                      --> Erros do processo
      /* .............................................................................

         Programa: pc_imprime_contrato_xml
         Sistema : Conta-Corrente - Cooperativa de Credito
         Sigla   : CRED
         Autor   : Tiago Castro (RKAM)
         Data    : Agosto/2014.                         Ultima atualizacao: 12/06/2017

         Dados referentes ao programa:

         Frequencia: Sempre que for chamado.
         Objetivo  : Efetuar a impressao do contrato de emprestimo

         Alteracoes: 
      ............................................................................. */

        -- Cursor sobre as informacoes de emprestimo
        CURSOR cr_crawepr IS
          SELECT crawepr.cdfinemp,
                 crawepr.cdlcremp,
                 crawepr.vlemprst,
                 crawepr.qtpreemp,
                 crawepr.vlpreemp,
                 crapass.inpessoa,
                 crawepr.tpemprst,
                 crawepr.dtlibera,
                 crawepr.dtdpagto,
                 crawepr.txmensal,
                 crawepr.nrseqrrq,
                 crawepr.idfiniof,
                 crawepr.dtmvtolt,               
                 crawepr.idcobope
            FROM crapass,
                 crawepr
           WHERE crawepr.cdcooper = pr_cdcooper
             AND crawepr.nrdconta = pr_nrdconta
             AND crawepr.nrctremp = pr_nrctremp
             AND crapass.cdcooper = crawepr.cdcooper
             AND crapass.nrdconta = crawepr.nrdconta;
        rw_crawepr cr_crawepr%ROWTYPE;--armazena informacoes do cursor cr_crawepr

        -- Cursor sobre as informacoes de emprestimo
        CURSOR cr_crapepr IS
          SELECT dtmvtolt, vltarifa, vliofepr
            FROM crapepr
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctremp = pr_nrctremp;
        rw_crapepr cr_crapepr%ROWTYPE;--armazena informacoes do cursor cr_crapepr

        -- Garantia Operacoes de Credito
        CURSOR cr_cobertura (pr_idcobert IN tbgar_cobertura_operacao.idcobertura%TYPE) IS
          SELECT tco.perminimo,
                 tco.nrconta_terceiro,
                 tco.inresgate_automatico,
                 tco.qtdias_atraso_permitido
            FROM tbgar_cobertura_operacao tco
           WHERE tco.idcobertura = pr_idcobert;
        rw_cobertura cr_cobertura%ROWTYPE;

        -- Cursor para buscar nome do titular da conta
        CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
          SELECT ass.nmprimtl,
                 ass.nrcpfcgc,
               ass.inpessoa,
               ass.cdnacion,
               ass.nrdocptl
            FROM crapass ass
           WHERE ass.cdcooper = pr_cdcooper
             AND ass.nrdconta = pr_nrdconta;
        rw_crapass cr_crapass%ROWTYPE;
        
        -- Cursor para buscar estado civil da pessoa fisica, jurida nao tem
        CURSOR cr_gnetcvl(pr_cdcooper crapttl.cdcooper%TYPE
                         ,pr_nrdconta crapttl.nrdconta%TYPE) IS
          SELECT gnetcvl.rsestcvl,
                 crapttl.dsproftl
           FROM  crapttl,
                 gnetcvl
           WHERE crapttl.cdcooper = pr_cdcooper
             AND crapttl.nrdconta = pr_nrdconta
             AND crapttl.idseqttl = 1 -- Primeiro Titular
             AND gnetcvl.cdestcvl = crapttl.cdestcvl;
        rw_gnetcvl cr_gnetcvl%ROWTYPE;--armazena informacoes do cursor cr_gnetcvl     
        
        -- Busca a Nacionalidade
        CURSOR cr_crapnac(pr_cdnacion IN crapnac.cdnacion%TYPE) IS
          SELECT crapnac.dsnacion
            FROM crapnac
           WHERE crapnac.cdnacion = pr_cdnacion;
        rw_crapnac cr_crapnac%ROWTYPE;--armazena informacoes do cursor cr_crapnac     
        
        -- Cursor sobre o endereco do associado
        CURSOR cr_crapenc(pr_cdcooper crapenc.cdcooper%TYPE
                         ,pr_nrdconta crapenc.nrdconta%TYPE
                         ,pr_inpessoa crapass.inpessoa%TYPE) IS
          SELECT crapenc.dsendere,
                 crapenc.nrendere,
                 crapenc.nmbairro,
                 crapenc.nmcidade,
                 crapenc.cdufende,
                 crapenc.nrcepend
            FROM crapenc
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND idseqttl = 1
             AND tpendass = CASE
                            WHEN pr_inpessoa = 1 THEN
                              10 --Residencial
                            ELSE
                              9 -- Comercial
                            END;
        rw_crapenc cr_crapenc%ROWTYPE;--armazena informacoes do cursor cr_crapenc     
        
        -- Tratamento de erros
        vr_exc_saida  EXCEPTION;
        vr_cdcritic   PLS_INTEGER;
        vr_dscritic   VARCHAR2(4000);

        -- Variaveis gerais
        vr_texto_completo VARCHAR2(32600);             --> Variável para armazenar os dados do XML antes de incluir no CLOB
        vr_des_xml        CLOB;                        --> XML do relatorio
        vr_des_xml2       CLOB;                        --> XML do relatorio
        vr_nmarqcet       VARCHAR2(15);                --> retorno da CCET
        vr_cdprogra       VARCHAR2(10) := 'EMPR0003';  --> Nome do programa
        rw_crapdat        btch0001.cr_crapdat%ROWTYPE; --> Cursor genérico de calendário
        vr_nom_direto     VARCHAR2(4000);               --> Diretório para gravação do arquivo
        vr_dsjasper       VARCHAR2(100);               --> nome do jasper a ser usado
        vr_dtlibera       DATE;                        --> Data de liberacao do contrato
        vr_nmarqimp       VARCHAR2(200);               --> nome do arquivo PDF
        vr_vlemprst       NUMBER;
        vr_flgachou       BOOLEAN;
        vr_inaddcob       INTEGER := 0;
        vr_inresaut       INTEGER := 0;
        vr_nrctater       INTEGER := 0;
        vr_nminterv       crapass.nmprimtl%TYPE;
        vr_nrcpfcgc       VARCHAR2(50);
        vr_interven       VARCHAR2(500);  --> Descrição do interveniente

        -- variaveis de críticas
        vr_tab_erro       GENE0001.typ_tab_erro;
        vr_des_reto       VARCHAR2(10);
        vr_typ_saida      VARCHAR2(3);

    BEGIN
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      -- Abre o cursor com as informacoes do emprestimo
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      -- Se nao encontrar o emprestimo finaliza o programa
      IF cr_crawepr%NOTFOUND THEN
        vr_dscritic := 'Emprestimo '||nvl(pr_nrctremp,0) ||' nao encontrado para impressao'; --monta critica
        CLOSE cr_crawepr;
        RAISE vr_exc_saida; -- encerra programa e retorna critica
      END IF;
      CLOSE cr_crawepr;

      -- Abre o cursor com as informacoes do emprestimo
      OPEN cr_crapepr;
      FETCH cr_crapepr INTO rw_crapepr;
      -- Se nao encontrar o emprestimo finaliza o programa
      CLOSE cr_crapepr;
        
      -- Se for POS-FIXADO
      IF rw_crawepr.tpemprst = 2 THEN
        -- Efetua geracao do XML do contrato
        pc_gera_xml_contrato_pos(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctremp => pr_nrctremp
                                ,pr_inimpctr => pr_inimpctr
                                ,pr_dsjasper => vr_dsjasper
                                ,pr_nmarqimp => vr_nmarqimp
                                ,pr_des_xml  => vr_des_xml2
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
      -- Se for PP ou TR
      ELSIF rw_crawepr.tpemprst IN (0,1) THEN
        -- Efetua geracao do XML do contrato
        pc_gera_xml_contrato_pp_tr(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp
                                  ,pr_inimpctr => pr_inimpctr
                                  ,pr_dsjasper => vr_dsjasper
                                  ,pr_nmarqimp => vr_nmarqimp
                                  ,pr_des_xml  => vr_des_xml2
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
      END IF;

      -- Se retornou erro
      IF NVL(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Inicializar o CLOB
      vr_des_xml := NULL;
      vr_texto_completo := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Inicializa o XML
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'<?xml version="1.0" encoding="utf-8"?><contrato>', TRUE);

      -- Se for PP ou POS-FIXADO
      IF rw_crawepr.tpemprst IN (1,2) THEN
        -- Se possuir cobertura e data for superior ao do novo contrato
        IF rw_crawepr.idcobope > 0 AND
           rw_crawepr.dtmvtolt >= TO_DATE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                   ,pr_cdacesso => 'DT_VIG_IMP_CTR_V2'),'DD/MM/RRRR') THEN
          --> Garantia Operacoes de Credito
          OPEN  cr_cobertura(pr_idcobert => rw_crawepr.idcobope);
          FETCH cr_cobertura INTO rw_cobertura;
          vr_flgachou := cr_cobertura%FOUND;
          CLOSE cr_cobertura;
          -- Se achou
          IF vr_flgachou THEN
               
             -- Se possui conta de interveniente
             IF rw_cobertura.nrconta_terceiro > 0 THEN
               -- Buscar conta do cooperado
               OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => rw_cobertura.nrconta_terceiro);
               FETCH cr_crapass INTO rw_crapass;
                 
               -- Se não encontrou
               IF cr_crapass%NOTFOUND THEN
                 -- Fechar cursor
                 CLOSE cr_crapass;
                 -- Gerar crítica
                 vr_cdcritic := 9;
                 -- Levantar exceção
                 RAISE vr_exc_saida;
               END IF;
               -- Fechar cursor
               CLOSE cr_crapass;               
                 
               -- Busca os dados do endereco residencial do associado
               OPEN  cr_crapenc(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => rw_cobertura.nrconta_terceiro
                               ,pr_inpessoa => rw_crapass.inpessoa);
               FETCH cr_crapenc INTO rw_crapenc;
               -- Se nao encontrar o endereco finaliza o programa
               IF cr_crapenc%NOTFOUND THEN
                 vr_dscritic := 'Endereco do interveniente nao encontrada para impressao'; -- monta critica
                 CLOSE cr_crapenc;
                 RAISE vr_exc_saida;
               END IF;
               CLOSE cr_crapenc;
                 
               -- Capturar nome, conta e cpf/cnpj do interveniente
               vr_nminterv := rw_crapass.nmprimtl;
                             vr_nrctater := rw_cobertura.nrconta_terceiro;
               vr_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc
                                                       ,pr_inpessoa => rw_crapass.inpessoa);                                                       
                 
               -- Verifica se o documento eh um CPF ou CNPJ
               IF rw_crapass.inpessoa = 1 THEN
                 -- Busca estado civil e profissao
                 OPEN  cr_gnetcvl(pr_cdcooper => pr_cdcooper,
                                  pr_nrdconta => rw_cobertura.nrconta_terceiro); 
                 FETCH cr_gnetcvl INTO rw_gnetcvl;
                 CLOSE cr_gnetcvl;

                 -- Busca a Nacionalidade
                 OPEN  cr_crapnac(pr_cdnacion => rw_crapass.cdnacion);
                 FETCH cr_crapnac INTO rw_crapnac;
                 CLOSE cr_crapnac;

                 -- monta descricao para o relatorio com os dados do emitente
                 vr_interven := vr_nminterv || ', ' 
                             || (CASE WHEN TRIM(rw_crapnac.dsnacion) IS NOT NULL THEN 'nacionalidade '||LOWER(rw_crapnac.dsnacion) || ', ' ELSE '' END)
                             || (CASE WHEN TRIM(rw_gnetcvl.dsproftl) IS NOT NULL THEN LOWER(rw_gnetcvl.dsproftl) || ', ' ELSE '' END)
                             || (CASE WHEN TRIM(rw_gnetcvl.rsestcvl) IS NOT NULL THEN LOWER(rw_gnetcvl.rsestcvl) || ', ' ELSE '' END)
                             || 'inscrito(a) no CPF sob n° ' || vr_nrcpfcgc || ', '
                             || 'portador(a) do RG n° ' || rw_crapass.nrdocptl || ', residente e domiciliado(a) na ' || rw_crapenc.dsendere || ', '
                             || 'n° '|| rw_crapenc.nrendere || ', bairro ' || rw_crapenc.nmbairro || ', '
                             || 'da cidade de ' || rw_crapenc.nmcidade || '/' || rw_crapenc.cdufende || ', '
                             || 'CEP ' || gene0002.fn_mask_cep(rw_crapenc.nrcepend) || ', '
                             || 'titular da conta corrente n° ' || TRIM(gene0002.fn_mask_conta(vr_nrctater)) 
                             || ', na condição de INTERVENIENTE GARANTIDOR.';
               ELSE
                 -- monta descricao para o relatorio com os dados do emitente
                 vr_interven := vr_nminterv || ', inscrita no CNPJ sob n° '|| vr_nrcpfcgc
                             || ' com sede na ' || rw_crapenc.dsendere || ', n° ' || rw_crapenc.nrendere || ', '
                             || 'bairro ' || rw_crapenc.nmbairro || ', da cidade de ' || rw_crapenc.nmcidade || '/' || rw_crapenc.cdufende || ', '
                             || 'CEP ' || gene0002.fn_mask_cep(rw_crapenc.nrcepend) || ', conta corrente n° ' || TRIM(gene0002.fn_mask_conta(vr_nrctater)) 
                             || ', na condição de INTERVENIENTE GARANTIDOR.';
             END IF;
                  
             END IF;
               
             vr_inaddcob := 1;
             vr_inresaut := rw_cobertura.inresgate_automatico;
             GENE0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                    '<cob_qtdiatraso>' || rw_cobertura.qtdias_atraso_permitido || '</cob_qtdiatraso>' ||
                                    '<cob_perminimo>'  || TO_CHAR(rw_cobertura.perminimo,'FM999G999G999G990D00') || '</cob_perminimo>' ||
                                    '<cob_interven>'   || vr_interven || '</cob_interven>');
          END IF;
        END IF;
      END IF;

      -- Cria nos de cobertura de operacao e resgate automatico
      GENE0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                             '<cob_nrctater>' || trim(gene0002.fn_mask_conta(nvl(vr_nrctater,0))) || '</cob_nrctater>' ||
                             '<cob_nminterv>' || trim(vr_nminterv) || '</cob_nminterv>' ||                             
                             '<cob_nrcpfint>' || trim(vr_nrcpfcgc) || '</cob_nrcpfint>' ||                             
                             '<cob_inaddcob>' || vr_inaddcob || '</cob_inaddcob>' ||
                             '<cob_inresaut>' || vr_inresaut || '</cob_inresaut>');

      -- Concatena com xml contratos
      dbms_lob.append(vr_des_xml, vr_des_xml2);
      dbms_lob.freetemporary(vr_des_xml2);
      vr_des_xml2 := NULL;
      dbms_lob.createtemporary(vr_des_xml2, TRUE);
      dbms_lob.open(vr_des_xml2, dbms_lob.lob_readwrite);
        
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, ' ', TRUE);

          vr_dtlibera := nvl(nvl(rw_crapepr.dtmvtolt, rw_crawepr.dtlibera),rw_crapdat.dtmvtolt);
        
      --Passar só o valor do empréstimo para a CCET001, pois lá recalcula tudo que precisa
      vr_vlemprst := rw_crawepr.vlemprst;

      -- Chama rotina de CET
      ccet0001.pc_imprime_emprestimos_cet(pr_cdcooper => pr_cdcooper
                                        , pr_dtmvtolt => nvl(rw_crapepr.dtmvtolt,rw_crapdat.dtmvtolt)
                                        , pr_cdprogra => vr_cdprogra
                                        , pr_nrdconta => pr_nrdconta
                                        , pr_inpessoa => rw_crawepr.inpessoa
                                        , pr_cdusolcr => 0 -- Segundo o Lucas, deve ser passado zero
                                        , pr_cdlcremp => rw_crawepr.cdlcremp
                                        , pr_tpemprst => rw_crawepr.tpemprst
                                        , pr_nrctremp => pr_nrctremp
                                        , pr_dtlibera => vr_dtlibera
                                        , pr_dtultpag => trunc(SYSDATE)
                                            , pr_vlemprst => vr_vlemprst
                                        , pr_txmensal => rw_crawepr.txmensal
                                        , pr_vlpreemp => rw_crawepr.vlpreemp
                                        , pr_qtpreemp => rw_crawepr.qtpreemp
                                        , pr_dtdpagto => rw_crawepr.dtdpagto
                                        , pr_nmarqimp => vr_nmarqcet
                                        , pr_des_xml  => vr_des_xml2
                                        , pr_cdcritic => vr_cdcritic
                                        , pr_dscritic => vr_dscritic
                                        );
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, ' ', TRUE);

      -- Concatena xml retornado CET com xml contratos
          dbms_lob.append(vr_des_xml, vr_des_xml2);
          dbms_lob.freetemporary(vr_des_xml2);
          vr_des_xml2 := NULL;
          dbms_lob.createtemporary(vr_des_xml2, TRUE);
          dbms_lob.open(vr_des_xml2, dbms_lob.lob_readwrite);

      IF rw_crawepr.nrseqrrq <> 0 THEN -- somenmte se for microcredito
            -- chama rotinar para geracao de questionario
            empr0003.pc_gera_perfil_empr(pr_cdcooper => pr_cdcooper
                                       , pr_nrdconta => pr_nrdconta
                                       , pr_nrctremp => pr_nrctremp
                                       , pr_cdcritic => vr_cdcritic
                                       , pr_dscritic => vr_dscritic
                                       , pr_retxml   => vr_des_xml2
                                       );
            -- concatena xml retornado empr0005 com xml contratos
            dbms_lob.append(vr_des_xml, vr_des_xml2);
            dbms_lob.freetemporary(vr_des_xml2);
          END IF;

      dbms_lob.writeappend(vr_des_xml, length('</contrato>'), '</contrato>');

      -- Busca diretorio padrao da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl');

      -- Solicita geracao do PDF
      gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                                 , pr_cdprogra  => vr_cdprogra
                                 , pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 , pr_dsxml     => vr_des_xml
                                 , pr_dsxmlnode => '/contrato'
                                 , pr_dsjasper  => vr_dsjasper
                                 , pr_dsparams  => null
                                 , pr_dsarqsaid => vr_nom_direto || vr_nmarqimp
                                 , pr_flg_gerar => 'S'
                                 , pr_qtcoluna  => 234
                                 , pr_sqcabrel  => 1
                                 , pr_flg_impri => 'S'
                                 , pr_nmformul  => ' '
                                 , pr_nrcopias  => 1
                                 , pr_nrvergrl  => 1
                                 , pr_parser    => 'R'           --> Seleciona o tipo do parser. "D" para VTD e "R" para Jasper padrão
                                 , pr_des_erro  => vr_dscritic);


      IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
        RAISE vr_exc_saida; -- encerra programa
      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      pr_nmarqimp   := vr_nmarqimp;
      pr_nom_direto := vr_nom_direto;

      -- Atualiza quantidade de impressoes realizadas do contrato do tipo negociavel
      IF nvl(pr_inimpctr,0) = 0 THEN
        BEGIN
          UPDATE crapepr
             SET crapepr.qtimpctr = NVL(qtimpctr,0) + 1
           WHERE crapepr.cdcooper = pr_cdcooper
             AND crapepr.nrdconta = pr_nrdconta
             AND crapepr.nrctremp = pr_nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar quantidade de impressao na crapepr'||SQLERRM;
          RAISE vr_exc_saida; -- encerra programa
        END;
      END IF;

    COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        /*pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || upper(pr_dscritic) || '</Erro></Root>');
        ROLLBACK;*/
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        /*pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||upper(pr_dscritic) ||'</Erro></Root>');
        ROLLBACK;*/

    END pc_imprime_contrato_emprestimo;  
    --
    PROCEDURE pc_imp_proposta_prestamista(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                         ,pr_nrctrseg IN crawseg.nrctrseg%TYPE  --> Proposta
                                         ,pr_nrctremp IN crawepr.nrctremp%TYPE  --> Contrato                                    
                                         ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                         ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                         ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                         ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                         ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                         ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE  -- Código do operador
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento                                       
                                         ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)                                       
                                         --------> OUT <--------
                                         ,pr_dsdireto OUT VARCHAR2
                                         ,pr_nmarqpdf OUT VARCHAR2             --> Retorna Nome do arquivo                           
                                         ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .............................................................................

     Programa: pc_impres_proposta_seg_pres
     Sistema : Seguros - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Márcio(Mouts)
     Data    : Agosto/2018.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para geração do relatório da proposta de seguro de vida prestamista
     Alteracoes: 
  
    ..............................................................................*/
    ----------->>> Cursores <<<--------   
    --> Buscar informações da proposta    
    CURSOR cr_crawseg IS
      select 
             cc.nmextcop, -- Nome da cooperativa
             trim(gene0002.fn_mask_conta(ca.nrdconta)) nrdconta, -- Número da conta
             cs.nrctrseg, -- Número da Proposta de Seguro de Vida Prestamista             
             cg.cdagenci, -- Número do PA
             cs.nmdsegur, -- Nome do segurado
             cs.nrcpfcgc, -- Cpf do segurado
             g.rsestcvl , -- Estado Civil
             cs.dtnascsg, -- Data de nascimento
             decode(cs.cdsexosg,1,'MASCULINO','FEMININO') cdsexosg, -- Sexo
             cs.dsendres||' '||cs.nrendres Endereco,
             cs.nmbairro, -- Nome do Bairro
             cs.nmcidade, -- Nome da Cidade
             cs.cdufresd, -- UF
             cs.nrcepend, -- CEP
             cs.nrctrato, -- Número do Contrato             
             lpad(cs.tpplaseg,3,'0') tpplaseg, -- Plano
             0 vl_saldo_devedor, --cs.vl_saldo_devedor
             1 id_imprime_DPS, -- Indicador se imprime DPS ou não
             cs.dtinivig,
             cs.dtmvtolt,
             cs.nmdsegur Cooperado, -- Cooperado
             trim(gene0002.fn_mask_conta(ca.nrdconta)) nrdconta2, -- Número da conta
             co.nmoperad -- Nome do operador
      from 
             crawseg cs,
             crapcop cc,
             crapass ca,
             crapage cg,
             crapttl ct,
             gnetcvl g,
             crapope co
      where 
             cs.cdcooper = pr_cdcooper 
         and cs.nrdconta = pr_nrdconta 
         and (cs.nrctrseg = pr_nrctrseg or cs.nrctrato = pr_nrctremp)
         and cs.cdcooper = cc.cdcooper
         and cs.cdcooper = ca.cdcooper
         and cs.nrdconta = ca.nrdconta
         and ca.cdcooper = cg.cdcooper
         and ca.cdagenci = cg.cdagenci
         and ct.cdcooper = cs.cdcooper
         and ct.nrdconta = cs.nrdconta
         and ct.nrcpfcgc = cs.nrcpfcgc
         and g.cdestcvl  = ct.cdestcvl
         and co.cdcooper = cs.cdcooper
         and co.cdoperad = pr_cdoperad
         AND NOT EXISTS (SELECT 1
                           FROM crapseg se
                          WHERE cs.cdcooper = se.cdcooper
                            AND cs.nrdconta = se.nrdconta
                            AND cs.nrctrseg = se.nrctrseg)
         UNION 
      SELECT 
             cc.nmextcop, -- Nome da cooperativa
             trim(gene0002.fn_mask_conta(ca.nrdconta)) nrdconta, -- Número da conta
             cs.nrctrseg, -- Número da Proposta de Seguro de Vida Prestamista             
             cg.cdagenci, -- Número do PA
             cs.nmdsegur, -- Nome do segurado
             cs.nrcpfcgc, -- Cpf do segurado
             g.rsestcvl , -- Estado Civil
             cs.dtnascsg, -- Data de nascimento
             decode(cs.cdsexosg,1,'MASCULINO','FEMININO') cdsexosg, -- Sexo
             cs.dsendres||' '||cs.nrendres Endereco,
             cs.nmbairro, -- Nome do Bairro
             cs.nmcidade, -- Nome da Cidade
             cs.cdufresd, -- UF
             cs.nrcepend, -- CEP
             cs.nrctrato, -- Número do Contrato             
             lpad(cs.tpplaseg,3,'0') tpplaseg, -- Plano
             0 vl_saldo_devedor, --cs.vl_saldo_devedor
             1 id_imprime_DPS, -- Indicador se imprime DPS ou não
             cs.dtinivig,
             cs.dtmvtolt,
             cs.nmdsegur Cooperado, -- Cooperado
             trim(gene0002.fn_mask_conta(ca.nrdconta)) nrdconta2, -- Número da conta
             co.nmoperad -- Nome do operador
      FROM 
             crawseg cs,
             crapcop cc,
             crapass ca,
             crapage cg,
             crapttl ct,
             gnetcvl g,
             crapope co,
             crapseg se
      WHERE 
             cs.cdcooper = pr_cdcooper 
         AND cs.nrdconta = pr_nrdconta 
         AND (cs.nrctrseg = pr_nrctrseg or cs.nrctrato = pr_nrctremp)
         AND cs.cdcooper = cc.cdcooper
         AND cs.cdcooper = ca.cdcooper
         AND cs.nrdconta = ca.nrdconta
         AND ca.cdcooper = cg.cdcooper
         AND ca.cdagenci = cg.cdagenci
         AND ct.cdcooper = cs.cdcooper
         AND ct.nrdconta = cs.nrdconta
         AND ct.nrcpfcgc = cs.nrcpfcgc
         AND g.cdestcvl  = ct.cdestcvl
         AND co.cdcooper = cs.cdcooper
         AND co.cdoperad = pr_cdoperad
         AND EXISTS (SELECT 1
                       FROM crapseg se1
                      WHERE cs.cdcooper = se1.cdcooper
                        AND cs.nrdconta = se1.nrdconta
                        AND cs.nrctrseg = se1.nrctrseg)
         AND cs.cdcooper = se.cdcooper
         AND cs.nrdconta = se.nrdconta
         AND cs.nrctrseg = se.nrctrseg         
         AND se.cdsitseg  NOT IN (2,4)
         ;    

    rw_crawseg cr_crawseg%ROWTYPE;   
      
    --> Buscar informações da proposta efetivada
    CURSOR cr_crapseg(prr_nrctrseg IN crawseg.nrctrseg%TYPE) IS
      select 
             cs.vlslddev, 
             decode(cs.idimpdps,1,'S','N') idimpdps
      from 
             crapseg cs
      where 
             cs.cdcooper = pr_cdcooper 
         and cs.nrdconta = pr_nrdconta 
         and cs.nrctrseg = prr_nrctrseg;
  
    rw_crapseg cr_crapseg%ROWTYPE;   

    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    vr_des_reto        VARCHAR2(100);
    vr_tab_erro        GENE0001.typ_tab_erro;
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_dstransa        craplgm.dstransa%TYPE := 'Impressao contrato prestamista';
    vr_nrdrowid        ROWID;

    vr_idseqttl        crapttl.idseqttl%TYPE := 1; 
    
    vr_dsdireto        VARCHAR2(4000);
    vr_nmendter        VARCHAR2(4000);     
    vr_dscomand        VARCHAR2(4000);
    vr_typsaida        VARCHAR2(100);    
    
    vr_dsmailcop       VARCHAR2(4000);
    vr_dsassmail       VARCHAR2(200);
    vr_dscormail       VARCHAR2(50);
    
    vr_saldodevedor    NUMBER:=0;
    vr_saldodevempr    NUMBER:=0;
    vr_id_imprime_dsp  VARCHAR2(1);    
    vr_flgprestamista  VARCHAR2(1);
    vr_localedata      VARCHAR2(200);    
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    
    l_offset     NUMBER:=0;
    
    vr_dsjasper  VARCHAR2(100);
    vr_dsmotcan  VARCHAR2(60);    
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN   
    --> Definir transação
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper);
                                         
    vr_nmendter := vr_dsdireto ||'/rl/psdp001';
    
    vr_dscomand := 'rm '||vr_nmendter||'* 2>/dev/null';
    
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF; 
    
    --> Montar nome do arquivo
    pr_nmarqpdf := 'psvp001'|| gene0002.fn_busca_time || '.pdf';
   
    --Aqui deve chamar a rotina para verificar se imprime o relatório e se é DPS ou não
    SEGU0003.pc_validar_prestamista(pr_cdcooper       => pr_cdcooper,
                                    pr_nrdconta       => pr_nrdconta,
                                    pr_nrctremp       => pr_nrctremp,
                                    pr_cdagenci       => pr_cdagecxa,
                                    pr_nrdcaixa       => pr_nrdcaixa,
                                    pr_cdoperad       => pr_cdoperad,
                                    pr_nmdatela       => pr_nmdatela,
                                    pr_idorigem       => pr_idorigem,   
                                    pr_valida_proposta => 'S',
                                    pr_sld_devedor    => vr_saldodevedor,  
                                    pr_flgprestamista => vr_flgprestamista,
                                    pr_flgdps         => vr_id_imprime_dsp,
                                    pr_dsmotcan       => vr_dsmotcan,
                                    pr_cdcritic       => pr_cdcritic,
                                    pr_dscritic       => pr_dscritic);
                              
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro; -- encerra programa           
    END IF;
    --

    IF vr_flgprestamista = 'S' THEN
    
      --> Buscar dados para impressao da Proposta de Seguro de Vida Prestamista
      OPEN cr_crawseg;
      FETCH cr_crawseg INTO rw_crawseg;
      IF cr_crawseg%NOTFOUND THEN
        CLOSE cr_crawseg;
        vr_dscritic := 'Proposta nao encontrada.';
        RAISE vr_exc_erro;
      ELSE
       CLOSE cr_crawseg;
      END IF;
    
      OPEN cr_crapseg(rw_crawseg.nrctrseg);
      FETCH cr_crapseg INTO rw_crapseg;
      IF cr_crapseg%NOTFOUND THEN
        CLOSE cr_crapseg;      
        -- Se a proposta nao estiver efetivada, rodar a rotina para calculo do saldo devedor
        SEGU0003.pc_saldo_devedor(pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrctremp => rw_crawseg.nrctrato,
                         pr_cdagenci => pr_cdagecxa,
                         pr_nrdcaixa => pr_nrdcaixa,
                         pr_cdoperad => pr_cdoperad,
                         pr_nmdatela => pr_nmdatela,
                         pr_idorigem => pr_idorigem,
                         pr_saldodevedor => vr_saldodevedor,
                         pr_saldodevempr => vr_saldodevempr,
                         pr_cdcritic => pr_cdcritic,
                         pr_dscritic => pr_dscritic);
         IF pr_dscritic IS NOT NULL THEN
           RAISE vr_exc_erro; -- encerra programa           
         END IF;
           
      ELSE
        -- Se proposta de seguro estiver efetivada, buscar da tabela o valor do saldo e o indicador de DPS   
        --> Buscar dados para impressao da Proposta de Seguro de Vida Prestamista
        CLOSE cr_crapseg;
        vr_saldodevedor   := rw_crapseg.vlslddev;
        vr_id_imprime_dsp := rw_crapseg.idimpdps;
      END IF;

      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Monta o Local e Data
      vr_localedata := upper(SUBSTR(rw_crawseg.nmcidade,1,15) ||', ' || gene0005.fn_data_extenso(pr_dtmvtolt => rw_crawseg.dtmvtolt, pr_flanoatu => FALSE));
    
      vr_txtcompl := NULL;
      
      --> INICIO
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><dadosRelatorio>
                      <dps>'|| vr_id_imprime_dsp ||'</dps>');  -- Nome da cooperativa
      pc_escreve_xml(
        '<nmextcop>'        ||rw_crawseg.nmextcop                       ||'</nmextcop>'        ||-- Nome da cooperativa
        '<conta>'           ||rw_crawseg.nrdconta                       ||'</conta>'           ||-- Número da conta - Formatado
        '<proposta>'        ||rw_crawseg.nrctrseg                       ||'</proposta>'        ||-- Número da Proposta de Seguro de Vida Prestamista    
        '<contaProponete>'  ||rw_crawseg.nrdconta                       ||'</contaProponete>'  ||-- Número da conta - Formatado
        '<postoAtendimento>'||rw_crawseg.cdagenci                       ||'</postoAtendimento>'||-- Número do PA
        '<segurado>'        ||rw_crawseg.nmdsegur                       ||'</segurado>'        ||-- Nome do segurado     
        '<cpf>'             ||rw_crawseg.nrcpfcgc                       ||'</cpf>'             ||-- Cpf do segurado                                     
        '<estadoCivil>'     ||rw_crawseg.rsestcvl                       ||'</estadoCivil>'     ||-- Estado Civil
        '<dataNascimento>'  ||to_char(rw_crawseg.dtnascsg,'DD/MM/RRRR') ||'</dataNascimento>'  ||-- Data de nascimento
        '<sexo>'            ||rw_crawseg.cdsexosg                       ||'</sexo>'            ||-- Sexo 
        '<endereco>'        ||rw_crawseg.Endereco                       ||'</endereco>'        ||-- Endereco
        '<bairro>'          ||rw_crawseg.nmbairro                       ||'</bairro>'          ||-- Nome do Bairro
        '<cidade>'          ||rw_crawseg.nmcidade                       ||'</cidade>'          ||-- Nome da Cidade
        '<uf>'              ||rw_crawseg.cdufresd                       ||'</uf>'              ||-- Unidade da Federacao
        '<cep>'             ||rw_crawseg.nrcepend                       ||'</cep>'             ||-- Cep
        '<contrato>'        ||rw_crawseg.nrctrato                       ||'</contrato>'        ||-- Número do Contrato de empr'estimo vinculado ao seguro 
        '<plano>'           ||rw_crawseg.tpplaseg                       ||'</plano>'           ||-- Plano
        '<saldoDevedor>'    ||vr_saldodevedor                           ||'</saldoDevedor>'    ||-- Saldo Devedor do Cooperado/Conta        
        '<dataIniVigencia>' ||to_char(rw_crawseg.dtinivig,'DD/MM/RRRR') ||'</dataIniVigencia>' ||-- Data de inicio da vigencia do seguro prestamista
        '<localData>'       ||vr_localedata                             ||'</localData>'       ||-- Local e data do seguro prestamista
        '<nomeCooperado>'   ||rw_crawseg.nmdsegur                       ||'</nomeCooperado>'   ||-- Nome do Coooperado
        '<contaCooperado>'  ||rw_crawseg.nrdconta                       ||'</contaCooperado>'  ||-- Conta do Cooperado
        '<operador>'|| rw_crawseg.nmoperad ||'</operador>'); -- Nome do operador           

      --> Descarregar buffer    
      pc_escreve_xml(' ',TRUE); 
    
      --> Descarregar buffer    
      pc_escreve_xml('</dadosRelatorio>',TRUE); 
    
      loop exit when l_offset > dbms_lob.getlength(vr_des_xml);
      DBMS_OUTPUT.PUT_LINE (dbms_lob.substr( vr_des_xml, 254, l_offset) || '~');
      l_offset := l_offset + 255;
      end loop;
    
      IF vr_id_imprime_dsp = 'S'THEN
        vr_dsjasper :='proposta_prestamista_dps.jasper';
      ELSE
        vr_dsjasper := 'proposta_prestamista.jasper';
      END IF;
      --> Solicita geracao do PDF
      gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                                 , pr_cdprogra  => pr_cdprogra
                                 , pr_dtmvtolt  => pr_dtmvtolt
                                 , pr_dsxml     => vr_des_xml
                                 , pr_dsxmlnode => '/dadosRelatorio'
                                 , pr_dsjasper  => vr_dsjasper
                                 , pr_dsparams  => null
                                 , pr_dsarqsaid => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                                 , pr_flg_gerar => 'S'
                                 , pr_qtcoluna  => 234
                                 , pr_cdrelato  => 280
                                 , pr_sqcabrel  => 1
                                 , pr_flg_impri => 'N'
                                 , pr_nmformul  => ' '
                                 , pr_nrcopias  => 1
                                 , pr_nrvergrl  => 1
                                 , pr_dsextmail => NULL
                                 , pr_dsmailcop => vr_dsmailcop
                                 , pr_dsassmail => vr_dsassmail
                                 , pr_dscormail => vr_dscormail
                                 , pr_des_erro  => vr_dscritic);
    
      IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
        RAISE vr_exc_erro; -- encerra programa
      END IF;        
      pr_dsdireto := vr_dsdireto||'/rl/';
     
      --> Gerar log de sucesso
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => ' ', 
                             pr_dsorigem => 'Ayllos WEB',
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  1, -- True
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => vr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrseg', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrseg);
      END IF;
    
      --COMMIT;
    ELSE
      -- Caso retorne que não deve ser gerado o relatório, será retornado 'FALSE' no nome do arquivo
      pr_nmarqpdf:='FALSE';
    END IF;
  EXCEPTION    
    WHEN vr_exc_erro THEN
        
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
        
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => 'Ayllos WEB', 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => vr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                               
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrseg', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrseg);
      END IF;
        
    WHEN OTHERS THEN
        
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao gerar impressao da proposta de seguro de vida prestamista: ' || SQLERRM, chr(13)),chr(10));   
    
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => 'Ayllos WEB', 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => vr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                               
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrseg', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrseg);
      END IF; 
        
    END pc_imp_proposta_prestamista;      
      
      
  
  
  BEGIN
    --
    vr_tab_erro.delete;
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
                                  
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'pc_gera_impressao'
                            	,pr_action => vr_nmeacao);

    -- Busca a data do sistema
    OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
    
    
    -- Validar criação prestamista
    open c_crawseg(pr_cdcooper,pr_nrdconta,pr_nrctremp);
    fetch c_crawseg into r_crawseg;
     if c_crawseg%notfound then
       --Efetivação já cria a p
       segu0003.pc_efetiva_proposta_sp(pr_cdcooper => pr_cdcooper
                                     , pr_nrdconta => pr_nrdconta
                                     , pr_nrctrato => pr_nrctremp
                                     , pr_cdagenci => vr_cdagenci
                                     , pr_nrdcaixa => vr_nrdcaixa
                                     , pr_cdoperad => vr_cdoperad
                                     , pr_nmdatela => vr_nmdatela
                                     , pr_idorigem => vr_idorigem
                                     , pr_cdcritic => vr_cdcritic
                                     , pr_dscritic => vr_dscritic);
      -- Se retornou erro
      if nvl(vr_cdcritic,0) > 0 or 
        trim(vr_dscritic) is not null then
        close c_crawseg;
        raise vr_exc_erro;
      end if;        
      
      --Busca o número da proposta prestamista gerado
      begin
       select s.nrctrseg
         into vr_nrctrseg
         from crawseg s
        where s.cdcooper = pr_cdcooper
          and s.nrdconta = pr_nrdconta
          and s.nrctrato = pr_nrctremp;
      exception
        when no_data_found then
          vr_nmarqimp_pre := 'FALSE';
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao buscar proposta prestamista: '||sqlerrm;
      end;
      if vr_nrctrseg > 0 then
        --Criou 
        commit;
      end if;
      
     else 
      if pr_nrctrseg is null or pr_nrctrseg = 0 then
        vr_nrctrseg := r_crawseg.nrctrseg;
      else
        vr_nrctrseg := pr_nrctrseg;
      end if;  
     end if;
    close c_crawseg;
    
    -- Gerar o contrato de emprestimo
    pc_imprime_contrato_emprestimo(pr_cdcooper   => pr_cdcooper
                                  ,pr_nrdconta   => pr_nrdconta
                                  ,pr_nrctremp   => pr_nrctremp
                                  ,pr_inimpctr   => pr_inimpctr
                                  ,pr_nom_direto => vr_dsdireto_emp
                                  ,pr_nmarqimp   => vr_nmarqimp_emp
                                  ,pr_cdcritic   => vr_cdcritic
                                  ,pr_dscritic   => vr_dscritic); 
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
      TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;                                   
    --               
    IF vr_nmarqimp_pre <> 'FALSE' THEN
    --  Gerar o relatorio proposta prestamista
    pc_imp_proposta_prestamista(pr_cdcooper => vr_cdcooper   --> Código da Cooperativa
                               ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                               ,pr_nrctrseg => vr_nrctrseg  --> Proposta
                               ,pr_nrctremp => pr_nrctremp  --> Contrato                                                                   
                               ,pr_cdagecxa => vr_cdagenci  --> Código da agencia
                               ,pr_nrdcaixa => vr_nrdcaixa  --> Numero do caixa do operador
                               ,pr_cdopecxa => vr_cdoperad  --> Código do Operador
                               ,pr_nmdatela => vr_nmdatela  --> Nome da Tela
                               ,pr_idorigem => vr_idorigem  --> Identificador de Origem
                               ,pr_cdprogra => 'ATENDA'     --> Codigo do programa
                               ,pr_cdoperad => vr_cdoperad  --> Código do Operador
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data de Movimento
                               ,pr_flgerlog => 1            --> True 
                               --------> OUT <--------
                               ,pr_dsdireto => vr_dsdireto_pre
                               ,pr_nmarqpdf => vr_nmarqimp_pre
                               ,pr_cdcritic => vr_cdcritic       --> Código da crítica
                               ,pr_dscritic => vr_dscritic);     --> Descrição da crítica

    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
      TRIM(vr_dscritic) IS NOT NULL THEN
      --RAISE vr_exc_erro;
      vr_nmarqimp_pre := 'FALSE';
    END IF;
    END IF;
    
    -- Se tiver prestamista
    IF vr_nmarqimp_pre <> 'FALSE' THEN
      vr_nmarqpdf:= 'prest001'|| gene0002.fn_busca_time || '.pdf';
      -- Juntar os Pdfs
      gene0002.pc_Juntar_Pdf(pr_dsdirarq => vr_dsdireto_pre, -- Diretorio de onde se encontram os arquivos PDFs
                             pr_lsarqpdf => vr_nmarqimp_emp||';'||vr_nmarqimp_pre, -- Lista dos nomes dos arquivos PDFs separados por ;
                             pr_nmpdfsai => vr_dsdireto_pre||'/'||vr_nmarqpdf, -- Diretorio + nome do arquivo PDF de saida
                             pr_dscritic => vr_dscritic); --Critica caso ocorra
      -- Se retornou erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
      END IF;                           

      -- Remover relatorio Contrato Emprestimo do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm ' || vr_dsdireto_emp || vr_nmarqimp_emp
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT null THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;    
      -- Remover relatorio Proposta Seguro Prestamista do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm ' || vr_dsdireto_pre || vr_nmarqimp_pre
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT null THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;                         
      -- copia contrato pdf do diretorio da cooperativa para servidor web
      gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                 , pr_cdagenci => NULL
                                 , pr_nrdcaixa => NULL
                                 , pr_nmarqpdf => vr_dsdireto_pre || vr_nmarqpdf
                                 , pr_des_reto => vr_des_reto
                                 , pr_tab_erro => vr_tab_erro
                                 );

      -- caso apresente erro na operação
      IF nvl(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_erro; -- encerra programa
        END IF;
      END IF;
      -- Remover relatorio Concatenado contrato + presamista do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm ' || vr_dsdireto_pre || vr_nmarqpdf
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT null THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;
      
      --vr_nmarqpdf := substr(vr_nmarqpdf, 2);-- retornar somente o nome do PDF sem a barra"/"
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' || vr_nmarqpdf || '</nmarqpdf>');
      
    ELSE -- Somente contrato de emprestimo
       
      -- copia contrato pdf do diretorio da cooperativa para servidor web
      gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                 , pr_cdagenci => NULL
                                 , pr_nrdcaixa => NULL
                                 , pr_nmarqpdf => vr_dsdireto_emp || vr_nmarqimp_emp
                                 , pr_des_reto => vr_des_reto
                                 , pr_tab_erro => vr_tab_erro
                                 );

      -- caso apresente erro na operação
      IF nvl(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_saida; -- encerra programa
        END IF;
      END IF;

      -- Remover relatorio do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm ' || vr_dsdireto_emp || vr_nmarqimp_emp
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT null THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_saida; -- encerra programa
      END IF;

      -- Liberando a memória alocada pro CLOB
      vr_nmarqpdf := substr(vr_nmarqimp_emp, 2);-- retornar somente o nome do PDF sem a barra"/"

      -- Criar XML de retorno para uso na Web
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' || vr_nmarqpdf || '</nmarqpdf>');      
    
    
    END IF;
    --
    COMMIT;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Falha geral na rotina da tela pc_imprime_contrato_prest: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
 
   

  END pc_imprime_contrato_prest;    
  --    
 --                           

END EMPR0003;
/
