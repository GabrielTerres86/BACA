CREATE OR REPLACE PACKAGE CECRED.CONV0001 AS

/*..............................................................................

    Programa: CONV0001 (Antigo b1wgen0045.p)
    Autor   : Guilherme - Precise
    Data    : Outubro/2009                       Ultima Atualizacao: 29/05/2017

    Dados referentes ao programa:

    Objetivo  : BO para unificacao de funcoes com o CRPS524.
                Programas com funcoes em comum com CRPS524:
                    - CCARBB
                    - CRPS138 relat 115 - Qntde Cooperados
                    - RELINS relat 470 - Beneficios INSS
                    - CRPS483 relat 450 - Inf. de Convenios
                    - RELSEG Op "R" 4 - Inf. de Seguros

    Alteracoes: 18/03/2010 - Incluido novo campo para guardar o numero de
                             cooperados com debito automatico, que tiveram
                             debitos no mes (Elton).

                14/05/2010 - Incluido novo parametro na procedure
                             valor-convenios com a quantidade de cooperados que
                             tiveram pelo menos um debito automatico no mes,
                             independente do convenio. (Elton).

                04/06/2010 - Incluido tratamento para tarifa TAA (Elton).

                15/03/2011 - Inclusao dos parametros ret_vlcancel e ret_qtcancel
                             na procedure limite-cartao-credito (Vitor)

                20/03/2012 - Alterado o parametro aux_qtassdeb para a table
                             crawass na procedure valor-convenios (Adriano).

                25/04/2012 - Incluido novo parametro na procedure
                             limite-cartao-credito. (David Kruger).

                22/06/2012 - Substituido gncoper por crapcop (Tiago).

                05/09/2012 - Alteracao na leitura da situacao de cartoes de
                             Creditos (David Kruger).

                22/02/2013 - Incluido novas procedures para utilizacao da tela
                             RELSEG no AYLLOS e WEB (David Kruger).

                21/06/2013 - Contabilizando crawcrd.insitcrd = 7 como "em uso"
                             (Tiago).

                28/02/2014 - Alterado o calculo do vr_tot_dbautass no
                             pc_grava_tt_convenio_debitos.

                02/05/2014 - Incluir pr_cdempres na pc_gerandb (Lucas R.)

                13/08/2014 - Tratamento para SULAMERICA (cdhistor = 1517) para,
                            no retorno da critica, enviarmos o campo de
                            contrato com 22 posicoes preenchidas, seguido de
                            tres espacos em branco (pc_gerandb).
                            (Chamado 182918 - Fabricio)
                              
               04/09/2015 - Adicioanadas procedures pc_download_ftp e pc_busca_concilia_transabbc
                            para para conectar-se ao FTP da Transabbc e efetuar download de três
                            arquivos diariamente (Lombardi - Projeto 214)
  
               21/09/2015 - Adicioanadas procedures pc_busca_tarifas_por_canal, pc_busca_tarifas_por_canal,
                            pc_busca_custo_bilhete_exe,pc_busca_custo_bilhete_exe e pc_busca_custo_bilhete_exe 
                            para manter a tela PRMDPV  (Lombardi - Projeto 214)

               24/09/2015 - Criacao da pc_relat_repasse_dpvat que gera o 
                            relatorio crrl709 - Repasses Convenio DPVAT 
                            Sicredi. (Jaison/Marcos-Supero)

               30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])		
               
               14/09/2016 - Incluir nova procedure pc_pula_seq_gt0001, irá criar registro de
                            controle na gncontr caso seja alterado o sequencial (Lucas Ranghetti #484556)

               29/05/2017 - Incluir nova procedure pc_gerandb_car para chamar a pc_gerandb
                            (Lucas Ranghetti #681579)
..............................................................................*/

  --Tipo de Registro para convenios
  TYPE typ_reg_convenio IS
    RECORD (inpessoa INTEGER
           ,cdconven INTEGER
           ,cdagenci INTEGER
           ,qtfatura INTEGER
           ,vlfatura NUMBER(25,2)
           ,vltarifa NUMBER(25,2)
           ,vlapagar NUMBER(25,2)
           ,qtdebito INTEGER
           ,vldebito NUMBER(25,2)
           ,vltardeb NUMBER(25,2)
           ,vlapadeb NUMBER(25,2)
           ,qtdebaut INTEGER);

  --Tipo de tabela de memoria para convenios
  TYPE typ_tab_convenio IS TABLE OF typ_reg_convenio INDEX BY VARCHAR2(10); --(3) CDAGENCI || (7) CDCONVEN

  -- Variavel para armazenar a tabela de memoria de convenios
  vr_tab_convenio typ_tab_convenio;

  --Tipo de Registro para associados com pelo menos um debito em conta
  TYPE typ_reg_crawass IS
    RECORD (nrdconta crapass.nrdconta%TYPE
           ,cdagenci crapass.cdagenci%TYPE);

  --Tipo de tabela para associados com pelo menos um debito em conta
  TYPE typ_tab_crawass IS TABLE OF typ_reg_crawass INDEX BY VARCHAR2(13); -- (10) NRDCONTA || (3) CDAGENCI

  -- Variavel para PlTable de associados que pagaram qualquer convenio
  vr_tab_crawass typ_tab_crawass;

  -- Tipo de registro para lancamentos de convenios
  TYPE typ_reg_cratlft IS
    RECORD (cdagenci craplft.cdagenci%TYPE
           ,inpessoa INTEGER
           ,nrdconta craplft.nrdconta%TYPE
           ,vllanmto craplft.vllanmto%TYPE);

  -- Tipo de tabela de memoria para registro de lancamentos de faturas
  TYPE typ_tab_cratlft IS TABLE OF typ_reg_cratlft INDEX BY VARCHAR2(10); -- (3) cdagenci (7) sequencial

  -- Tipo de registro para rotina de convenios pagos com dep. a vista
  TYPE typ_reg_cratlcm IS
    RECORD (cdagenci craplcm.cdagenci%TYPE
           ,nrdconta craplcm.nrdconta%TYPE
           ,vllanmto craplcm.vllanmto%TYPE
           ,inpessora pls_integer);

  -- Tipo de tabela para rotina de convenios  pagos com dep. a vista
  TYPE typ_tab_cratlcm IS
    TABLE OF typ_reg_cratlcm INDEX BY VARCHAR2(23); -- (3) CDAGENCI || (10) NRDCONTA || (10) SEQUENCIAL

  -- Variavel para PlTable de convenios pagos com dep a vista
  vr_tab_cratlcm typ_tab_cratlcm;

  -- Tipo de registro para PlTable de associados que pagaram convenio especifico
  TYPE typ_reg_cratass IS
    RECORD(nrdconta crapass.nrdconta%TYPE);

  -- Tipo de tabela para PlTable de associados que pagaram convenio especifico
  TYPE typ_tab_cratass IS
    TABLE OF typ_reg_cratass INDEX BY PLS_INTEGER; -- nrdconta

  -- Variavel para PlTable de associados que pagaram convenio especifico
  vr_tab_cratass typ_tab_cratass;

  -- Type para armazenar os historicos dos cadastros de convenios
  TYPE typ_reg_historicos IS
    RECORD(cdhiscxa INTEGER,
           nmempres gnconve.nmempres%type);

  TYPE typ_tab_historicos IS TABLE OF typ_reg_historicos
        INDEX BY VARCHAR2(5); -- cdhist(5)

  -- Type para armazenar as empresas conveniadas
  TYPE typ_reg_empr_conve IS
    RECORD(nmextcon VARCHAR2(25),
           cdempcon crapcon.cdempcon%type,
           cdsegmto crapcon.cdsegmto%type,
           flgcnvsi VARCHAR2(3));

  TYPE typ_tab_empr_conve IS TABLE OF typ_reg_empr_conve INDEX BY PLS_INTEGER;

  -- Type para armazenar dados da pesquisa
  TYPE typ_reg_dados_pesqti IS
    RECORD(cdbandst INTEGER
          ,dscodbar craplft.cdbarras%type
          ,nrautdoc INTEGER
          ,nrdocmto NUMBER
          ,flgpgdda BOOLEAN
          ,nrdconta INTEGER
          ,nmoperad VARCHAR2(30)
          ,cdagenci INTEGER
          ,nrdolote INTEGER
          ,vldpagto NUMBER
          ,nmextbcc crapban.nmextbcc%type
          ,dspactaa VARCHAR2(30)
          ,vlconfoz NUMBER
          ,insitfat INTEGER);

  TYPE typ_tab_dados_pesqti IS TABLE OF typ_reg_dados_pesqti INDEX BY PLS_INTEGER;

  /* Procedure para verificar valor dos convenios */
  PROCEDURE pc_valor_convenios  (pr_cdcooper      IN crapcop.cdcooper%type      -- Código da cooperativa
                                ,pr_dataini       IN DATE                       -- Dara de Inicio
                                ,pr_datafim       IN DATE                       -- Data de Fim
                                ,pr_tab_convenio   OUT CONV0001.typ_tab_convenio-- Tabela de convenios
                                ,pr_tab_crawass    OUT CONV0001.typ_tab_crawass -- Tabela de contas com debito
                                ,pr_cdcritic       OUT INTEGER                  -- Código do erro
                                ,pr_dscritic       OUT VARCHAR2);               -- Descricao do erro

  /* Procedimentos para alimentar tabela de memoria de convenios */
  PROCEDURE pc_grava_tt_convenio (pr_cdcooper     IN crapcop.cdcooper%type      -- Código da cooperativa
                                 ,pr_dataini      IN DATE                       -- Dara de Inicio
                                 ,pr_datafim      IN DATE                       -- Data de Fim
                                 ,pr_cdhiscxa     IN gnconve.cdhiscxa%type      -- Código do historico do convenio
                                 ,pr_cdconven     IN gnconve.cdconven%type      -- Código do convenio
                                 ,pr_vltarifa     IN gnconve.vltrfcxa%type      -- Valor tarifa caixa
                                 ,pr_vltrfnet     IN gnconve.vltrfnet%type      -- Valor tarifa internet
                                 ,pr_vltrftaa     IN gnconve.vltrftaa%type      -- Valor tarifa TAA
                                 ,pr_cdcritic      OUT INTEGER                  -- Código do erro
                                 ,pr_dscritic      OUT VARCHAR2);               -- Descricao do erro

  /* Procedimentos para alimentar tabela de memoria de convenios */
  PROCEDURE pc_popula_tt (pr_tipo     IN pls_integer            -- Tipo (1) Pago caixa  (2) debito automatico
                         ,pr_cdconven IN gnconve.cdconven%type  -- Código do convenio
                         ,pr_cdagenci IN craplft.cdagenci%type  -- Código da Agencia
                         ,pr_nrseqdig IN pls_integer            -- Contador de pagamentos
                         ,pr_vlfatura IN NUMBER                 -- Valor da fatura
                         ,pr_vltarifa IN NUMBER                 -- Valor da tarifa
                         ,pr_vlapagar IN NUMBER                 -- Valor a pagar
                         ,pr_qtdebaut IN pls_integer
                         ,pr_cdcritic      OUT INTEGER                  -- Código do erro
                         ,pr_dscritic      OUT VARCHAR2);          -- Quantidade de debito automatico

  /* Procedimentos para alimentar tabela de memoria de convenios */
  PROCEDURE pc_grava_tt_convenio_debitos (pr_cdcooper     IN crapcop.cdcooper%type      -- Código da cooperativa
                                         ,pr_dataini      IN DATE                       -- Dara de Inicio
                                         ,pr_datafim      IN DATE                       -- Data de Fim
                                         ,pr_cdhiscxa     IN gnconve.cdhiscxa%type      -- Código do historico do convenio
                                         ,pr_cdconven     IN gnconve.cdconven%type      -- Código do convenio
                                         ,pr_vltarifa     IN gnconve.vltrfcxa%type      -- Valor tarifa caixa
                                         ,pr_vltrfnet     IN gnconve.vltrfnet%type      -- Valor tarifa internet
                                         ,pr_vltrftaa     IN gnconve.vltrftaa%type      -- Valor tarifa TAA
                                         ,pr_cdcritic      OUT INTEGER                  -- Código do erro
                                         ,pr_dscritic      OUT VARCHAR2);               -- Descricao do erro

  /* Gerar tempTable dos Lancamentos de faturas.(craplft)  dos convenios*/
  PROCEDURE pc_consulta_faturas(pr_cdcooper  IN INTEGER      -- Codigo da cooperativa
                               ,pr_dtmvtolt  IN DATE         -- Data de movimento
                               ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                               ,pr_dtdpagto  IN DATE         -- Data de pagamento
                               ,pr_vldpagto  IN NUMBER       -- Valor do pagamento
                               ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                               ,pr_cdhistor  IN INTEGER      -- Codigo do historico
                               ,pr_flgpagin  IN BOOLEAN      -- Indicativo  de paginação
                               ,pr_nrregist  IN INTEGER      -- Número de controle de registros
                               ,pr_nriniseq  IN INTEGER      -- Número de controle de inicio de registro
                               ,pr_cdempcon  IN VARCHAR2     -- Codigo da empresa a ser conveniada.
                               ,pr_cdsegmto  IN INTEGER      -- Identificacao do segmento da empresa/orgao
                               ,pr_flgcnvsi  IN BOOLEAN      -- Indicador SICREDI associa ao historico específico
                               ,pr_qtregist OUT INTEGER      -- Retorna a quantidade de registro
                               ,pr_dscritic OUT VARCHAR2     -- Descricao da critica
                               ,pr_vlrtotal OUT NUMBER       -- Valor total
                               ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                               ,pr_tab_dados_pesqti OUT CONV0001.typ_tab_dados_pesqti); -- tabela de historicos

  /* Consulta de convênios */
  PROCEDURE pc_lotee_1a (pr_cdcooper IN crapcop.cdcooper%TYPE  -- Código da Cooperativa
                        ,pr_cdhistor IN craphis.cdhistor%TYPE  -- Código do Histórico
                        ,pr_cdagenci OUT crapass.cdagenci%TYPE -- Código da Agência
                        ,pr_codcoope OUT crapcop.cdcooper%TYPE -- Código da Cooperativa
                        ,pr_cdcritic OUT INTEGER               -- Código do erro
                        ,pr_dscritic OUT VARCHAR2);     -- Descricao do erro

  /* Gerar registros na crapndb para devolucao de debitos automaticos. */
  PROCEDURE pc_gerandb (pr_cdcooper IN crapcop.cdcooper%TYPE  -- Código da Cooperativa
                       ,pr_cdhistor IN craphis.cdhistor%TYPE  -- Código do Histórico
                       ,pr_nrdconta IN crapass.nrdconta%TYPE  -- Numero da Conta
                       ,pr_cdrefere IN crapatr.cdrefere%TYPE  -- Código de Referência
                       ,pr_vllanaut IN craplau.vllanaut%TYPE  -- Valor Lancamento
                       ,pr_cdseqtel IN craplau.cdseqtel%TYPE  -- Código Sequencial
                       ,pr_nrdocmto IN craplau.nrdocmto%TYPE  -- Número do Documento
                       ,pr_cdagesic IN crapcop.cdagesic%TYPE  -- Agência Sicredi
                       ,pr_nrctacns IN crapass.nrctacns%TYPE  -- Conta do Consórcio
                       ,pr_cdagenci IN crapass.cdagenci%TYPE  -- Codigo do PA
                       ,pr_cdempres IN craplau.cdempres%TYPE  -- Codigo empresa sicredi
                       ,pr_idlancto IN craplau.idlancto%TYPE  -- Código do lançamento        
                       ,pr_codcriti IN INTEGER                -- Código do erro
                       ,pr_cdcritic OUT INTEGER               -- Código do erro
                       ,pr_dscritic OUT VARCHAR2);            -- Descricao do erro

 /* Gerar registros na crapndb para devolucao de debitos automaticos. */
  PROCEDURE pc_gerandb_car (pr_cdcooper IN crapcop.cdcooper%TYPE  -- Código da Cooperativa
                           ,pr_cdhistor IN craphis.cdhistor%TYPE  -- Código do Histórico
                           ,pr_nrdconta IN crapass.nrdconta%TYPE  -- Numero da Conta
                           ,pr_cdrefere IN VARCHAR2               -- Código de Referência
                           ,pr_vllanaut IN craplau.vllanaut%TYPE  -- Valor Lancamento
                           ,pr_cdseqtel IN craplau.cdseqtel%TYPE  -- Código Sequencial
                           ,pr_nrdocmto IN VARCHAR2               -- Número do Documento
                           ,pr_cdagesic IN crapcop.cdagesic%TYPE  -- Agência Sicredi
                           ,pr_nrctacns IN crapass.nrctacns%TYPE  -- Conta do Consórcio
                           ,pr_cdagenci IN crapass.cdagenci%TYPE  -- Codigo do PA
                           ,pr_cdempres IN craplau.cdempres%TYPE  -- Codigo empresa sicredi
                           ,pr_idlancto IN craplau.idlancto%TYPE  -- Código do lançamento        
                           ,pr_codcriti IN INTEGER                -- Código do erro
                           ,pr_cdcritic OUT INTEGER               -- Código do erro
                           ,pr_dscritic OUT VARCHAR2); 

  -- Conectar-se ao FTP da Transabbc e efetuar download de três arquivos diariamente.
  PROCEDURE pc_busca_concilia_transabbc;
  
  -- Grava as tarifas por canal nos parametros do sistema
  PROCEDURE pc_grava_tarifas_por_canal (pr_caixa     IN     VARCHAR2
                                       ,pr_internet  IN     VARCHAR2
                                       ,pr_taa       IN     VARCHAR2
                                       ,pr_xmllog    IN     VARCHAR2       --> XML com informac?es de LOG
                                       ,pr_cdcritic OUT     PLS_INTEGER    --> Codigo da critica
                                       ,pr_dscritic OUT     VARCHAR2       --> Descricao da critica
                                       ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT     VARCHAR2       --> Nome do campo com erro
                                       ,pr_des_erro OUT     VARCHAR2);     --> Erros do processo
  
  -- Busca as tarifas por canal nos parametros do sistema.
  PROCEDURE pc_busca_tarifas_por_canal (pr_xmllog    IN     VARCHAR2       --> XML com informac?es de LOG
                                       ,pr_cdcritic OUT     PLS_INTEGER    --> Codigo da critica
                                       ,pr_dscritic OUT     VARCHAR2       --> Descricao da critica
                                       ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT     VARCHAR2       --> Nome do campo com erro
                                       ,pr_des_erro OUT     VARCHAR2);     --> Erros do processo
  
  -- Busca os custos bilhete por exercício.
  PROCEDURE pc_busca_custo_bilhete_exe (pr_xmllog    IN     VARCHAR2       --> XML com informac?es de LOG
                                       ,pr_cdcritic OUT     PLS_INTEGER    --> Codigo da critica
                                       ,pr_dscritic OUT     VARCHAR2       --> Descricao da critica
                                       ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT     VARCHAR2       --> Nome do campo com erro
                                       ,pr_des_erro OUT     VARCHAR2);     --> Erros do processo
  
  -- Exclui os custos bilhete por exercício.
  PROCEDURE pc_exclui_custo_bilhete_exe (pr_exercicio IN     VARCHAR2
                                        ,pr_xmllog    IN     VARCHAR2       --> XML com informac?es de LOG
                                        ,pr_cdcritic OUT     PLS_INTEGER    --> Codigo da critica
                                        ,pr_dscritic OUT     VARCHAR2       --> Descricao da critica
                                        ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT     VARCHAR2       --> Nome do campo com erro
                                        ,pr_des_erro OUT     VARCHAR2);     --> Erros do processo
  
  -- Insere ou Atualiza custo bilhete por exercício.
  PROCEDURE pc_grava_custo_bilhete_exe (pr_exercicio IN     VARCHAR2
                                       ,pr_integral  IN     VARCHAR2
                                       ,pr_parcelado IN     VARCHAR2
                                       ,pr_ehnovo    IN     VARCHAR2
                                       ,pr_xmllog    IN     VARCHAR2       --> XML com informac?es de LOG
                                       ,pr_cdcritic OUT     PLS_INTEGER    --> Codigo da critica
                                       ,pr_dscritic OUT     VARCHAR2       --> Descricao da critica
                                       ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT     VARCHAR2       --> Nome do campo com erro
                                       ,pr_des_erro OUT     VARCHAR2);     --> Erros do processo

  /* Procedure para gerar relatorio dos repasses DPVAT */
  PROCEDURE pc_relat_repasse_dpvat (pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da cooperativa
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data atual
                                   ,pr_cdprogra  IN crapprg.cdprogra%TYPE     --> Programa chamador
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo do erro
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao do erro
																	 
  PROCEDURE pc_grava_motv_excl_debaut (  pr_cdcooper IN  tbconv_motivo_excl_autori.cdcooper%TYPE  
										,pr_nrdconta IN  tbconv_motivo_excl_autori.nrdconta%TYPE  
										,pr_cdhistor IN  tbconv_motivo_excl_autori.cdhistor%TYPE  
										,pr_cdrefere IN  tbconv_motivo_excl_autori.cdreferencia%TYPE  
										,pr_idmotivo IN  tbconv_motivo_excl_autori.idmotivo%TYPE  
										,pr_cdorigem IN  tbconv_motivo_excl_autori.cdorigem%TYPE  
										,pr_cdempcon IN  tbconv_motivo_excl_autori.cdempcon%TYPE  
										,pr_cdsegmto IN  tbconv_motivo_excl_autori.cdsegmto%TYPE  
										,pr_cdcritic OUT INTEGER               -- Código do erro
										,pr_dscritic OUT VARCHAR2);            -- Descricao do erro                                   																	 

  -- Criar registro de controle na gncotnr e pular o sequencial na gnconve                  
  PROCEDURE pc_pula_seq_gt0001 (pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooeprativa
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                               ,pr_cdconven IN gnconve.cdconven%TYPE --> Codigo do convenio
                               ,pr_tpdcontr IN gncontr.tpdcontr%TYPE --> Tipo de Controle
                               ,pr_nrseqant IN gncontr.nrsequen%TYPE --> Seq. Anterior
                               ,pr_nrsequen IN gncontr.nrsequen%TYPE --> Seq. Alterada
                               ,pr_nmarqint IN gnconve.nmarqint%TYPE --> Nome do arquivo
                               ,pr_cdcritic OUT NUMBER               --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2);           --> Descrição da critica
                 
  -- Retornar referencia do convenio ja formatada              
  PROCEDURE pc_retorna_referencia_conv (pr_cdconven IN gnconve.cdconven%TYPE --> Codigo do convenio
                                       ,pr_cdhistor IN INTEGER               --> Historico do convenio  
                                       ,pr_cdrefere IN VARCHAR2              --> Referencia
                                       ,pr_nrrefere OUT VARCHAR2             --> Referencia formatada
                                       ,pr_qtdigito OUT INTEGER              --> Qtd. maxima de digitos                                       
                                       ,pr_cdcritic OUT NUMBER               --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2);
END CONV0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CONV0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CONV0001
  --  Sistema  : Procedimentos para Convenios
  --  Sigla    : CRED
  --  Autor    : Douglas Pagel
  --  Data     : Outubro/2013.                   Ultima atualizacao: 16/10/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para agendamentos na Internet
  --
  -- Alteracoes: 13/08/2014 - Tratamento para SULAMERICA (cdhistor = 1517) para,
  --                          no retorno da critica, enviarmos o campo de
  --                          contrato com 22 posicoes preenchidas, seguido de
  --                          tres espacos em branco. (Chamado 182918 - Fabricio)
  --
  --             23/10/2014 - Tratamento para o campo Usa Agencia
  --                          (gnconve.flgagenc); convenios a partir de 2014.
  --                          (Fabricio)
  --
  --             30/10/2014 - Tratamento para o preenchimento dos campos do cdrefere
  --                          procedure pc_gerandb (Lucas R./Elton)
	--
  --             24/03/2015 - Criada function fn_verifica_ult_dia e chamado
  --                          sempre que for inserir um registro nas tabelas
  --                          crapndb ou craplau (SD245218 - Tiago).
  --
  --             17/04/2015 - Ajustado gravacao do campo crapscn.cdempres na tabela crapndb
  --                          quando convenio Sicredi. (Chamado 268307) - (Fabricio)
  --                        - Tratado critica 453 para retorno a empresa (crapndb).
  --                          (Chamado 275834) - (Fabricio)
  --
  --             11/05/2015 - Alterado ordem em que era armazenado os valores do campo
  --                          vr_dtmvtolt, pois quando é chamada a procedure via tela
  --                          gravava na posição da data no arquivo com a data do próximo
  --                          dia útil (Lucas Ranghetti #265396)
  --
  --             13/05/2015 - Adicionado historicos 834,901,993,1061 TIM Celular,HDI,LIBERTY SEGUROS,
  --                          PORTO SEGURO, que ja existia  para PREVISUL, no retorno da critica,
  --                          enviarmos o campo de contrato com 20 posicoes preenchidas, seguido de
  --                          cinco espacos em branco (Lucas Ranghetti #285063)
  --
  --             13/08/2015 - Adicioanar tratamento para o convenio MAPFRE VERA CRUZ SEG, referencia
  --                          e conta (Lucas Ranghetti #292988 )
  --
  --             04/09/2015 - Adicioanadas procedures pc_download_ftp e pc_busca_concilia_transabbc
  --                          para para conectar-se ao FTP da Transabbc e efetuar download de três
  --                          arquivos diariamente (Lombardi - Projeto 214)
  --
  --             21/09/2015 - Adicioanadas procedures pc_busca_tarifas_por_canal, pc_busca_tarifas_por_canal,
  --                          pc_busca_custo_bilhete_exe,pc_busca_custo_bilhete_exe e pc_busca_custo_bilhete_exe 
  --                          para manter a tela PRMDPV  (Lombardi - Projeto 214)
  --
  --             24/09/2015 - Criacao da pc_relat_repasse_dpvat que gera o 
  --                          relatorio crrl709 - Repasses Convenio DPVAT 
  --                          Sicredi. (Jaison/Marcos-Supero)
  --
  --             15/02/2016 - Incluir validacao de cooperado demitido critica '15' na procedure
  --                          pc_gerandb (Lucas Ranghetti #386413)
  --
  --             24/03/2016 - Adicionado tratamento para a vivo historico 453, gravar     
  --                          na crapndb com 11 posicoes (Lucas Ranghetti #417302 )
  --
  --             21/06/2016 - Adicionar historico 690 do Samae Sao Bento para 10 posicoes na procedure 
  --                          pc_gerandb (Lucas Ranghetti #467618)
  --
  --             30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])
  --
  --             27/07/2016 - Adicionar historico 900 do Samae Rio Negrinho para 6 posicoes 
  --                          na procedure pc_gerandb (Lucas Ranghetti #486565)
  --
  --             14/09/2016 - Incluir nova procedure pc_pula_seq_gt0001, irá criar registro de
  --                          controle na gncontr caso seja alterado o sequencial (Lucas Ranghetti #484556)
  --
  --             21/11/2016 - Se for o convenio 045, 14 BRT CELULAR - FEBRABAN e referencia conter 11 
  --                          posicoes, devemos incluir um hifen para completar 12 posicoes 
  --                          ex: 40151016407- na procedure pc_gerandb (Lucas Ranghetti #560620/453337)
  --
  --             20/02/2017 - #551216 Ajustes em pc_busca_concilia_transabbc para logar início, erros e
  --                          fim da execução do programa e mudança nos logs dos erros para atenderem ao 
  --                          padrão 'HH24:MI:SS - nome_programa' (Carlos)
  --
  --             31/03/2017 - Incluir PREVISC para fazer como faz a SULAMERICA (Lucas Ranghetti #637882)
  --
  --             04/04/2017 - Ajuste para integracao de arquivos com layout na versao 5
  --			             (Jonata - RKAM M311).
  --             15/05/2017 - Adicionar tratamento para o convenio CERSAD 9 posicoes na procedure pc_gerandb
  --                          (Lucas Ranghetti #622377)
  --
  --             07/06/2017 - Adicionar UNIFIQUE POMERODE para completar com 22 zeros a esquerda
  --                          conforme faz para Sulamerica (Lucas Ranghetti #663781)
  --             27/06/2017 - Adicionar tratamento para o convenio AGUAS DE JOINVILLE 8 posicoes
  --                          na pc_gerandb (Tiago/Fabricio #692918)
  --
  --             10/07/2017 - Adicionar tratamento para o convenio SANEPAR 8 posicoes
  --                          na pc_gerandb (Tiago/Fabricio #673343)  
  --
  --             29/09/2017 - Incluir validacao de 23 posicoes para a CHUBB(Lucas Ranghetti #766211)
  --
  --             16/10/2017 - Adicionar procedure pc_retorna_referencia_conv para formatar a referencia
  --                          do convenio de acordo com o cadastrado na tabela crapprm 
  --                          (Lucas Ranghetti #712492)
  ---------------------------------------------------------------------------------------------------------------


  /* Busca dos convenios da cooperativa */
  CURSOR cr_gncvcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT gncvcop.cdconven
      FROM gncvcop
     WHERE gncvcop.cdcooper = pr_cdcooper
     ORDER BY gncvcop.cdconven;
  rw_gncvcop cr_gncvcop%ROWTYPE;

  /* Busca convenio especifico */
  CURSOR cr_gnconve(pr_cdconven IN gnconve.cdconven%TYPE) IS
    SELECT gnconve.cdconven,
           gnconve.vltrfcxa,
           gnconve.vltrfnet,
           gnconve.vltrftaa,
           gnconve.nmarqdeb,
           gnconve.vltrfdeb,
           gnconve.cdhiscxa,
           gnconve.cdhisdeb
      FROM gnconve
     WHERE gnconve.cdconven = pr_cdconven
       AND ((gnconve.cdhisdeb > 0 AND gnconve.nmarqdeb <> ' ')
        OR  (gnconve.cdhiscxa > 0))
     ORDER BY gnconve.cdconven;
  rw_gnconve cr_gnconve%ROWTYPE;

  -- Leitura de lancamentos de faturas
  CURSOR cr_craplft ( pr_cdcooper IN crapcop.cdcooper%type
                     ,pr_dtmvtolt IN craplft.dtmvtolt%type
                     ,pr_cdhistor IN craplft.cdhistor%type) IS
    SELECT craplft.cdagenci,
           craplft.vllanmto
      FROM craplft
     WHERE craplft.cdcooper = pr_cdcooper
       AND craplft.dtvencto = pr_dtmvtolt
       AND craplft.insitfat IN (1,2)
       AND craplft.cdhistor = pr_cdhistor
     ORDER BY craplft.cdagenci;
  rw_craplft cr_craplft%ROWTYPE;

  -- Leitura de lacamentos de deposito a vista
  CURSOR cr_craplcm ( pr_cdcooper IN crapcop.cdcooper%type
                     ,pr_dtmvtolt IN craplft.dtmvtolt%type
                     ,pr_cdhistor IN craplft.cdhistor%type) IS
    SELECT craplcm.nrdconta,
           craplcm.vllanmto,
           crapass.cdagenci
      FROM craplcm,crapass
     WHERE craplcm.cdcooper = pr_cdcooper
       AND craplcm.dtmvtolt = pr_dtmvtolt
       AND craplcm.cdhistor = pr_cdhistor
       AND crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = craplcm.nrdconta
     ORDER BY crapass.cdagenci;
  rw_craplcm cr_craplcm%ROWTYPE;

  /* Busca convenio especifico */
  CURSOR cr_gnconve_II(pr_cdconven IN gnconve.cdconven%TYPE,
                       pr_cdhistor IN craphis.cdhistor%TYPE) IS
    SELECT gnconve.cdcooper,
           gnconve.cdconven,
           gnconve.flgagenc
      FROM gnconve
     WHERE gnconve.cdconven = pr_cdconven
       AND gnconve.flgativo = 1
       AND gnconve.cdhisdeb > 0
       AND gnconve.nmarqdeb <> ' '
       AND gnconve.cdhisdeb = pr_cdhistor
     ORDER BY gnconve.cdconven;
  rw_gnconve_II cr_gnconve_II%ROWTYPE;

  /* Busca cooperativas */
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS

    SELECT cop.cdcooper,
           cop.cdagectl
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;

  rw_crapcop cr_crapcop%ROWTYPE;

  /* Procedure para verificar valor dos convenios */
  PROCEDURE pc_valor_convenios  (pr_cdcooper      IN crapcop.cdcooper%type      -- Código da cooperativa
                                ,pr_dataini       IN DATE                       -- Dara de Inicio
                                ,pr_datafim       IN DATE                       -- Data de Fim
                                ,pr_tab_convenio  OUT CONV0001.typ_tab_convenio -- Tabela de convenios
                                ,pr_tab_crawass   OUT CONV0001.typ_tab_crawass  -- Tabela de contas com debito
                                ,pr_cdcritic      OUT INTEGER                   -- Código do erro
                                ,pr_dscritic      OUT VARCHAR2) IS              -- Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_valor_convenio           Antigo: b1wgen0045.p/valor_convenio
  --  Sistema  : Procedimentos para verificar valor dos convenios
  --  Sigla    : CRED
  --  Autor    : Douglas Pagel
  --  Data     : Outubro/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para verificar valor dos convenios

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_vltarifa NUMBER(25,2);
      vr_vltrfnet NUMBER(25,2);
      vr_vltrftaa NUMBER(25,2);

      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%type;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;

    BEGIN
      --Inicializar varaivel retorno erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Limpar tabela memoria
      pr_tab_convenio.DELETE;
      pr_tab_crawass.DELETE;
      conv0001.vr_tab_convenio.DELETE;

      -- Laco para cursor dos convenios por cooperativa
      OPEN cr_gncvcop(pr_cdcooper);
      LOOP
        FETCH cr_gncvcop
          INTO rw_gncvcop;

        EXIT WHEN cr_gncvcop%NOTFOUND;

        -- Laco para convenio da cooperativa
        OPEN cr_gnconve(rw_gncvcop.cdconven);
        LOOP
          FETCH cr_gnconve
            INTO rw_gnconve;
          EXIT WHEN cr_gnconve%NOTFOUND;

          -- Alimenta valores das tarifas
          vr_vltarifa := rw_gnconve.vltrfcxa;
          vr_vltrfnet := rw_gnconve.vltrfnet;
          vr_vltrftaa := rw_gnconve.vltrftaa;

          -- Se não for convenio do IPTU Blumenau
          IF rw_gnconve.cdhiscxa <> 373 THEN
            -- RUN grava_tt_convenio
            pc_grava_tt_convenio (pr_cdcooper     => pr_cdcooper            -- Código da cooperativa
                                 ,pr_dataini      => pr_dataini             -- Dara de Inicio
                                 ,pr_datafim      => pr_datafim             -- Data de Fim
                                 ,pr_cdhiscxa     => rw_gnconve.cdhiscxa    -- Código do historico do convenio
                                 ,pr_cdconven     => rw_gnconve.cdconven    -- Código do convenio
                                 ,pr_vltarifa     => vr_vltarifa            -- Valor tarifa caixa
                                 ,pr_vltrfnet     => vr_vltrfnet            -- Valor tarifa internet
                                 ,pr_vltrftaa     => vr_vltrftaa            -- Valor tarifa TAA
                                 ,pr_cdcritic     => vr_cdcritic            -- Código do erro
                                 ,pr_dscritic     => vr_dscritic);          -- Descrição do erro
            -- Validar retorno de erro
            if vr_dscritic is not null then
              raise vr_exc_erro;
            end if;
          END IF;

          -- Somente convenios com debito automatico
          IF rw_gnconve.nmarqdeb <> ' ' THEN
            -- Atualiza valor da tarifa
            vr_vltarifa := rw_gnconve.vltrfdeb;
            pc_grava_tt_convenio_debitos (pr_cdcooper     => pr_cdcooper            -- Código da cooperativa
                                         ,pr_dataini      => pr_dataini             -- Dara de Inicio
                                         ,pr_datafim      => pr_datafim             -- Data de Fim
                                         ,pr_cdhiscxa     => rw_gnconve.cdhisdeb    -- Código do historico do convenio
                                         ,pr_cdconven     => rw_gnconve.cdconven    -- Código do convenio
                                         ,pr_vltarifa     => vr_vltarifa            -- Valor tarifa caixa
                                         ,pr_vltrfnet     => vr_vltrfnet            -- Valor tarifa internet
                                         ,pr_vltrftaa     => vr_vltrftaa            -- Valor tarifa TAA
                                         ,pr_cdcritic     => vr_cdcritic            -- Código do erro
                                         ,pr_dscritic     => vr_dscritic);          -- Descrição do erro
          END IF;

        END LOOP; -- Laco para convenio da cooperativa
        -- Fecha o cursor
        CLOSE cr_gnconve;

      END LOOP; -- Laco para cursor dos convenios por cooperativa
      CLOSE cr_gncvcop;
      -- Retorna as tabelas de memoria preenchidas
      pr_tab_convenio := conv0001.vr_tab_convenio;
      pr_tab_crawass := conv0001.vr_tab_crawass;


    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CONV0001.pc_valor_convenios. '||SQLERRM;
    END;
  END;

  /* Procedimentos para alimentar tabela de memoria de convenios */
  PROCEDURE pc_grava_tt_convenio (pr_cdcooper     IN crapcop.cdcooper%type      -- Código da cooperativa
                                 ,pr_dataini      IN DATE                       -- Dara de Inicio
                                 ,pr_datafim      IN DATE                       -- Data de Fim
                                 ,pr_cdhiscxa     IN gnconve.cdhiscxa%type      -- Código do historico do convenio
                                 ,pr_cdconven     IN gnconve.cdconven%type      -- Código do convenio
                                 ,pr_vltarifa     IN gnconve.vltrfcxa%type      -- Valor tarifa caixa
                                 ,pr_vltrfnet     IN gnconve.vltrfnet%type      -- Valor tarifa internet
                                 ,pr_vltrftaa     IN gnconve.vltrftaa%type      -- Valor tarifa TAA
                                 ,pr_cdcritic      OUT INTEGER                  -- Código do erro
                                 ,pr_dscritic      OUT VARCHAR2) IS

---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_grava_tt_convenio           Antigo: b1wgen0045.p/grava_tt_convenio
  --  Sistema  : Procedimentos para alimentar tabela de memoria de convenios
  --  Sigla    : CRED
  --  Autor    : Douglas Pagel
  --  Data     : Outubro/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para alimentar tabela de memoria de convenios

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --VARIAVEIS LOCAIS
      vr_dtmvtolt DATE;                         -- Data auxiliar para laco
      vr_tab_cratlft CONV0001.typ_tab_cratlft;  -- Tabela de memoria para valores por agencia.
      vr_chave varchar2(10);                    -- Auxiliar para chave de tabela de memoria.
      vr_seque pls_integer;                     -- Auxiliar para sequencial da chave da PlTable.
      vr_aux_pa pls_integer;                    -- Auxiliar para troca de PA no loop da tabela de memoria
      vr_contador pls_integer := 0;             -- Auxiliar para contador e calculo de total da tarifa
      vr_tot_vlfatura NUMBER(25,2) := 0;        -- Total de fatura do PA.
      vr_tot_vlapagar NUMBER(25,2) := 0;        -- Total a pagar do PA.
      vr_tot_vltarifa NUMBER(25,2) := 0;        -- Total de tarifa do PA.

      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%type;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;

    BEGIN
      -- Laco para periodo informado
      vr_dtmvtolt := pr_dataini;
      vr_seque := 0;
      vr_tab_cratlft.delete;
      WHILE vr_dtmvtolt <= pr_datafim LOOP
        -- Alimenta tabela de memória com dados das contas e valores
        OPEN cr_craplft (pr_cdcooper
                        ,vr_dtmvtolt
                        ,pr_cdhiscxa);
        LOOP
          FETCH cr_craplft
            INTO rw_craplft;
          EXIT WHEN cr_craplft%NOTFOUND;
          --  Monta chave ta tabela de memoria
          vr_seque := vr_seque + 1;
          vr_chave := lpad(rw_craplft.cdagenci, 3, '0') || lpad(vr_seque, 7, '0');

          -- Insere dados na tabela de memoria
          vr_tab_cratlft(vr_chave).cdagenci := rw_craplft.cdagenci;
          vr_tab_cratlft(vr_chave).vllanmto := rw_craplft.vllanmto;

        END LOOP; -- Laco periodo informado
        CLOSE cr_craplft;

        vr_dtmvtolt := vr_dtmvtolt + 1;
      END LOOP; -- Laco para periodo informado

      -- Percorre a tabela de memoria ordenada por agencia
      vr_chave := vr_tab_cratlft.first;
      LOOP
        exit when vr_chave is null;
        -- Pega PA atual
        vr_aux_pa := vr_tab_cratlft(vr_chave).cdagenci;

        -- Acumula valores do PA
        vr_contador := vr_contador + 1;
        vr_tot_vlfatura := vr_tot_vlfatura +  vr_tab_cratlft(vr_chave).vllanmto;

        -- Pega chave do proximo registro se houver
        vr_chave := vr_tab_cratlft.next(vr_chave);

        -- Se trocou o PA ou é o ultimo registro da PLTable
        IF vr_chave IS NULL OR vr_aux_pa <> vr_tab_cratlft(vr_chave).cdagenci then

          -- Valida agencias especificas
          case vr_aux_pa
              when 90 then vr_tot_vltarifa := vr_contador * pr_vltrfnet;  -- Tarifa Internet
              when 91 then vr_tot_vltarifa := vr_contador * pr_vltrftaa;  -- Tarifa TAA
              else vr_tot_vltarifa := vr_contador * pr_vltarifa;          -- Tarifa Caixa
            end case;

          -- Calcula valor total a pagar do PA
          vr_tot_vlapagar := vr_tot_vlfatura - vr_tot_vltarifa;

          conv0001.pc_popula_tt(pr_tipo     => 1                          -- Tipo (1) Pago caixa  (2) debito automatico
                               ,pr_cdconven => pr_cdconven                -- Código do convenio
                               ,pr_cdagenci => vr_aux_pa                  -- Código da Agencia
                               ,pr_nrseqdig => vr_contador                -- Contador de pagamentos
                               ,pr_vlfatura => vr_tot_vlfatura            -- Valor da fatura
                               ,pr_vltarifa => vr_tot_vltarifa            -- Valor da tarifa
                               ,pr_vlapagar => vr_tot_vlapagar            -- Valor a pagar
                               ,pr_qtdebaut => 0    -- Não é deb. autom.  -- Quantidade deb. automatico
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);

          -- Zera variaveis para proximo PA
          vr_contador := 0;
          vr_tot_vlfatura := 0;
          vr_tot_vltarifa := 0;
          vr_tot_vlapagar := 0;

        end if; -- Ultimo PA

      END LOOP; -- PlTable de memoria

    EXCEPTION
      WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CONV0001.pc_grava_tt_convenio. '||SQLERRM;
    END;
  END;

  /* Procedimentos para alimentar tabela de memoria de convenios */
  PROCEDURE pc_popula_tt (pr_tipo     IN pls_integer            -- Tipo (1) Pago caixa  (2) debito automatico
                         ,pr_cdconven IN gnconve.cdconven%type  -- Código do convenio
                         ,pr_cdagenci IN craplft.cdagenci%type  -- Código da Agencia
                         ,pr_nrseqdig IN pls_integer            -- Contador de pagamentos
                         ,pr_vlfatura IN NUMBER                 -- Valor da fatura
                         ,pr_vltarifa IN NUMBER                 -- Valor da tarifa
                         ,pr_vlapagar IN NUMBER                 -- Valor a pagar
                         ,pr_qtdebaut IN pls_integer
                         ,pr_cdcritic      OUT INTEGER                  -- Código do erro
                         ,pr_dscritic      OUT VARCHAR2) IS        -- Quantidade de debito automatico
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_popula_tt           Antigo: b1wgen0045.p/popula_tt
  --  Sistema  : Procedimentos para alimentar tabela de memoria de convenios
  --  Sigla    : CRED
  --  Autor    : Douglas Pagel
  --  Data     : Outubro/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para alimentar tabela de memoria de convenios

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      -- Variavel para auxilio na chave da PlTable de Convenio
      vr_chave_convenio varchar2(10);

      -- VARIAVEIS DE ERRO--
      vr_cdcritic crapcri.cdcritic%type;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;


    BEGIN
      -- Monta chave do PA e Convenio
      vr_chave_convenio := LPAD(pr_cdagenci, 3, '0') || LPAD(pr_cdconven, 7, '0');

      -- Verifica se o convenio para o PA já está na PlTable
      IF conv0001.vr_tab_convenio.EXISTS(vr_chave_convenio) THEN
        -- Se existir, acumula valores e quantidades de acordo com o tipo
        IF pr_tipo = 1 THEN -- Pago no caixa
          conv0001.vr_tab_convenio(vr_chave_convenio).qtfatura := conv0001.vr_tab_convenio(vr_chave_convenio).qtfatura + pr_nrseqdig;
          conv0001.vr_tab_convenio(vr_chave_convenio).vlfatura := conv0001.vr_tab_convenio(vr_chave_convenio).vlfatura + pr_vlfatura;
          conv0001.vr_tab_convenio(vr_chave_convenio).vltarifa := conv0001.vr_tab_convenio(vr_chave_convenio).vltarifa + pr_vltarifa;
          conv0001.vr_tab_convenio(vr_chave_convenio).vlapagar := conv0001.vr_tab_convenio(vr_chave_convenio).vlapagar + pr_vlapagar;
        ELSE -- Tipo 2, debito automatico
          conv0001.vr_tab_convenio(vr_chave_convenio).qtdebito := nvl(conv0001.vr_tab_convenio(vr_chave_convenio).qtdebito,0) + pr_nrseqdig;
          conv0001.vr_tab_convenio(vr_chave_convenio).vldebito := nvl(conv0001.vr_tab_convenio(vr_chave_convenio).vldebito,0) + pr_vlfatura;
          conv0001.vr_tab_convenio(vr_chave_convenio).vltardeb := nvl(conv0001.vr_tab_convenio(vr_chave_convenio).vltardeb,0) + pr_vltarifa;
          conv0001.vr_tab_convenio(vr_chave_convenio).vlapadeb := nvl(conv0001.vr_tab_convenio(vr_chave_convenio).vlapadeb,0) + pr_vlapagar;
          conv0001.vr_tab_convenio(vr_chave_convenio).qtdebaut := nvl(conv0001.vr_tab_convenio(vr_chave_convenio).qtdebaut,0) + pr_qtdebaut;
        END IF;
      ELSE -- Registro nao existe, será iniciado de acordo com o tipo.
        conv0001.vr_tab_convenio(vr_chave_convenio).cdagenci := pr_cdagenci;
        conv0001.vr_tab_convenio(vr_chave_convenio).cdconven := pr_cdconven;

        IF pr_tipo = 1 THEN -- Pago no caixa
          conv0001.vr_tab_convenio(vr_chave_convenio).qtfatura := pr_nrseqdig;
          conv0001.vr_tab_convenio(vr_chave_convenio).vlfatura := pr_vlfatura;
          conv0001.vr_tab_convenio(vr_chave_convenio).vltarifa := pr_vltarifa;
          conv0001.vr_tab_convenio(vr_chave_convenio).vlapagar := pr_vlapagar;
        ELSE -- Tipo 2, debito automatico
          conv0001.vr_tab_convenio(vr_chave_convenio).qtdebito := pr_nrseqdig;
          conv0001.vr_tab_convenio(vr_chave_convenio).vldebito := pr_vlfatura;
          conv0001.vr_tab_convenio(vr_chave_convenio).vltardeb := pr_vltarifa;
          conv0001.vr_tab_convenio(vr_chave_convenio).vlapadeb := pr_vlapagar;
          conv0001.vr_tab_convenio(vr_chave_convenio).qtdebaut := pr_qtdebaut;
        END IF;
      END IF; -- Se registro existe
    EXCEPTION
      WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CONV0001.pc_popula_tt. '||SQLERRM;
    END;
  END;

  /* Procedimentos para alimentar tabela de memoria de convenios */
  PROCEDURE pc_grava_tt_convenio_debitos (pr_cdcooper     IN crapcop.cdcooper%type      -- Código da cooperativa
                                         ,pr_dataini      IN DATE                       -- Dara de Inicio
                                         ,pr_datafim      IN DATE                       -- Data de Fim
                                         ,pr_cdhiscxa     IN gnconve.cdhiscxa%type      -- Código do historico do convenio
                                         ,pr_cdconven     IN gnconve.cdconven%type      -- Código do convenio
                                         ,pr_vltarifa     IN gnconve.vltrfcxa%type      -- Valor tarifa caixa
                                         ,pr_vltrfnet     IN gnconve.vltrfnet%type      -- Valor tarifa internet
                                         ,pr_vltrftaa     IN gnconve.vltrftaa%type      -- Valor tarifa TAA
                                         ,pr_cdcritic      OUT INTEGER                  -- Código do erro
                                         ,pr_dscritic      OUT VARCHAR2) IS

---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_grava_tt_convenio_debitos           Antigo: b1wgen0045.p/grava_tt_convenio_debitos
  --  Sistema  : Procedimentos para alimentar tabela de memoria de convenios
  --  Sigla    : CRED
  --  Autor    : Douglas Pagel
  --  Data     : Outubro/2013.                   Ultima atualizacao: 28/02/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para alimentar tabela de memoria de convenios pagos com debito em conta

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      -- VARIAVEIS LOCAIS --
      vr_dtmvtolt DATE;                         -- Data auxiliar para indice da craplcm
      vr_tot_vlfatura NUMBER(25,2) := 0;        -- Total de fatura do PA.
      vr_tot_vlapagar NUMBER(25,2) := 0;        -- Total a pagar do PA.
      vr_tot_vltarifa NUMBER(25,2) := 0;        -- Total de tarifa do PA.
      vr_tot_dbautass NUMBER(25,2) := 0;        -- Total de associados com debito em conta
      vr_chave_cratlcm VARCHAR2(23);            -- Auxiliar para montagem da chave da vr_cratlcm
      vr_sequencia PLS_INTEGER := 0;            -- Auxiliar para montagem da chave da vr_cratlcm
      vr_nrseqdig PLS_INTEGER;                  -- Contador para numero de lancamentos
      vr_auxpa PLS_INTEGER;                     -- Auxiliar para troca de PA na leitura da PlTable cratlcm
      -- VARIAVEIS DE ERRO--
      vr_cdcritic crapcri.cdcritic%type;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;

    BEGIN
      -- Zera PlTable de lancamentos por dep. a vista.
      conv0001.vr_tab_cratlcm.DELETE;
      -- Zera contador de numero de lancamentos
      vr_nrseqdig := 0;

      -- Laco para alimentar a PlTAble de lancamentos a vista
      vr_dtmvtolt := pr_dataini;
      vr_sequencia := 0;
      WHILE vr_dtmvtolt <= pr_datafim LOOP
        -- Busca dados na tabela de lancamentos dep. a vista
        OPEN cr_craplcm(pr_cdcooper, vr_dtmvtolt, pr_cdhiscxa);
        LOOP
          FETCH cr_craplcm
            INTO rw_craplcm;

          EXIT WHEN cr_craplcm%NOTFOUND;
          vr_sequencia := vr_sequencia + 1;
          -- Monta chave
          vr_chave_cratlcm := lpad(rw_craplcm.cdagenci, 3, '0') || lpad(rw_craplcm.nrdconta, 10, '0') || lpad(vr_sequencia, 10, '0');

          vr_tab_cratlcm(vr_chave_cratlcm).nrdconta := rw_craplcm.nrdconta;
          vr_tab_cratlcm(vr_chave_cratlcm).cdagenci := rw_craplcm.cdagenci;
          vr_tab_cratlcm(vr_chave_cratlcm).vllanmto := rw_craplcm.vllanmto;

        END LOOP; -- Fim da busca dos registros por data
        CLOSE cr_craplcm;
        vr_dtmvtolt := vr_dtmvtolt + 1;
      END LOOP; -- Fim do laco de data.

      -- Com os registros ordenados na PlTable cratlcm, eh feita a leitura da mesma
      vr_chave_cratlcm := vr_tab_cratlcm.FIRST;
      LOOP
        EXIT WHEN vr_chave_cratlcm is null;
        vr_auxpa := vr_tab_cratlcm(vr_chave_cratlcm).cdagenci;

        vr_nrseqdig := nvl(vr_nrseqdig, 0) + 1;
        vr_tot_vlfatura := vr_tot_vlfatura + vr_tab_cratlcm(vr_chave_cratlcm).vllanmto;

        -- Soma quantidade de contas que tenham este convenio com deb. em conta
        IF NOT vr_tab_cratass.EXISTS(vr_tab_cratlcm(vr_chave_cratlcm).nrdconta) THEN
          -- Só soma se não estiver na PLTABLE para não considerar duplicadas
          vr_tot_dbautass := vr_tot_dbautass + 1;
        END IF;

        -- Armazena registro na PlTable de associados que pagaram este convenio
        vr_tab_cratass(vr_tab_cratlcm(vr_chave_cratlcm).nrdconta).nrdconta := vr_tab_cratlcm(vr_chave_cratlcm).nrdconta;

        -- Armazana registro na PlTable de associados que pagaram pelo menos um convenio
        vr_tab_crawass(lpad(vr_tab_cratlcm(vr_chave_cratlcm).cdagenci, 3, '0') || lpad(vr_tab_cratlcm(vr_chave_cratlcm).nrdconta, 10, '0')).cdagenci := vr_tab_cratlcm(vr_chave_cratlcm).cdagenci;
        vr_tab_crawass(lpad(vr_tab_cratlcm(vr_chave_cratlcm).cdagenci, 3, '0') || lpad(vr_tab_cratlcm(vr_chave_cratlcm).nrdconta, 10, '0')).nrdconta := vr_tab_cratlcm(vr_chave_cratlcm).nrdconta;

        -- Pega chave do proximo registro
        vr_chave_cratlcm := vr_tab_cratlcm.NEXT(vr_chave_cratlcm);

        -- Se mudou o PA ou a chave é nula, entra nas regras de quebra de PA
        IF vr_chave_cratlcm is null  OR vr_auxpa <> vr_tab_cratlcm(vr_chave_cratlcm).cdagenci THEN
          -- Calcula valores
          vr_tot_vltarifa := vr_nrseqdig * pr_vltarifa;
          vr_tot_vlapagar := vr_tot_vlfatura - vr_tot_vltarifa;

          conv0001.pc_popula_tt(pr_tipo     => 2                      -- Tipo (1) Pago caixa  (2) debito automatico
                               ,pr_cdconven => pr_cdconven  -- Código do convenio
                               ,pr_cdagenci => vr_auxpa  -- Código da Agencia
                               ,pr_nrseqdig => vr_nrseqdig            -- Contador de pagamentos
                               ,pr_vlfatura => vr_tot_vlfatura                 -- Valor da fatura
                               ,pr_vltarifa => vr_tot_vltarifa                 -- Valor da tarifa
                               ,pr_vlapagar => vr_tot_vlapagar                 -- Valor a pagar
                               ,pr_qtdebaut => vr_tot_dbautass
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);

          -- Trata erro no procedimento
          IF vr_cdcritic is not null OR
             vr_dscritic is not null THEN
            RAISE vr_exc_erro;
          END IF;

          -- Zera variaveis para proximo PA
          vr_nrseqdig := 0;
          vr_tot_vlfatura := 0;
          vr_tot_vltarifa := 0;
          vr_tot_vlapagar := 0;
          vr_tot_dbautass := 0;

          vr_tab_cratass.DELETE;

        END IF; -- Fim da quebra do PA
      END LOOP; -- Fim da leitura da cratlcm

    EXCEPTION
      WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CONV0001.pc_grava_tt_convenio_debitos. '||SQLERRM;

    END;
  END;

  /* Gerar tempTable de historico de Cadastro de convenios(gnconve)  */
  PROCEDURE pc_lista_historicos (pr_cdhiscxa  IN INTEGER       -- Codigo do hist do caixa
                                ,pr_nmempres  IN VARCHAR2      -- Nome da Empresa
                                ,pr_nrregist  IN INTEGER       -- Número de controle de registros
                                ,pr_nriniseq  IN INTEGER       -- Número de controle de inicio de registro
                                ,pr_qtregist OUT INTEGER       -- Retorna a quantidade de registro
                                ,pr_dscritic OUT VARCHAR2      -- Descricao da critica
                                ,pr_tab_historicos OUT CONV0001.typ_tab_historicos) IS -- tabela de historicos
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_lista_historicos           Antigo: Antigo b1wgen0101.p/lista-historico
  --  Sistema  : Procedimentos para Convenios
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana (AMcom)
  --  Data     : Novembro/2013.                Ultima atualizacao: 21/11/2013
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para gerar tempTable de historico de Cadastro de convenios(gnconve)
  ---------------------------------------------------------------------------------------------------------------

    vr_nrregist NUMBER;
    vr_idx      varchar2(5);

    -- Buscar Cadastro de convenios
    CURSOR cr_gnconve IS
      SELECT cdhiscxa,
             nmempres,
             row_number() over (partition by cdhiscxa
                                order by cdhiscxa ) numreg
        FROM gnconve
       WHERE ((pr_cdhiscxa <> 0 AND
               gnconve.cdhiscxa = pr_cdhiscxa) OR
               gnconve.cdhiscxa > 0
              )
         AND ((pr_nmempres IS NOT NULL AND
               gnconve.nmempres like '%'||pr_nmempres||'%') or
               pr_nmempres IS NULL
              )
         AND gnconve.flgativo = 1
       ORDER by gnconve.cdhiscxa;


  BEGIN

    vr_nrregist := pr_nrregist;

    -- Buscar Cadastro de convenios
    FOR rw_gnconve IN cr_gnconve LOOP
      IF rw_gnconve.numreg = 1 THEN --FIRST-OFF
        pr_qtregist := NVL(pr_qtregist,0) + 1;

        /* controles da paginação */
        IF (pr_qtregist < pr_nriniseq) OR
           (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
          CONTINUE;
        END IF;

        IF vr_nrregist >= 1 THEN
          vr_idx := lpad(rw_gnconve.cdhiscxa,5,'0');

          pr_tab_historicos(vr_idx).cdhiscxa := rw_gnconve.cdhiscxa;
          pr_tab_historicos(vr_idx).nmempres := rw_gnconve.nmempres;
        END IF;

        vr_nrregist := vr_nrregist - 1;

      END IF;
    END LOOP;

    pr_dscritic := 'OK';

  END pc_lista_historicos;

  /* Gerar tempTable de Cadastro de empresas conveniadas(crapcon)  */
  PROCEDURE pc_lista_empresas_conv(pr_cdcooper  IN INTEGER       -- Codigo da cooperativa
                                  ,pr_cdempcon  IN VARCHAR2      -- Codigo da empresa a ser conveniada.
                                  ,pr_cdsegmto  IN INTEGER       -- Identificacao do segmento da empresa/orgao
                                  ,pr_nmrescon  IN INTEGER       -- Nome fantasia da empresa a ser conveniada.
                                  ,pr_nrregist  IN INTEGER       -- Número de controle de registros
                                  ,pr_nriniseq  IN INTEGER       -- Número de controle de inicio de registro
                                  ,pr_qtregist OUT INTEGER       -- Retorna a quantidade de registro
                                  ,pr_dscritic OUT VARCHAR2      -- Descricao da critica
                                  ,pr_tab_empr_conve OUT CONV0001.typ_tab_empr_conve) IS -- tabela de historicos
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_lista_empresas_conv           Antigo: Antigo b1wgen0101.p/lista-empresas-conv
  --  Sistema  : Procedimentos para Convenios
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana (AMcom)
  --  Data     : Novembro/2013.                Ultima atualizacao: 21/11/2013
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para gerar tempTable de historico de Cadastro de convenios(gnconve)
  ---------------------------------------------------------------------------------------------------------------

    vr_nrregist NUMBER;
    vr_idx      INTEGER;

    -- Buscar Cadastro das empresas conveniadas
    CURSOR cr_crapcon IS
      SELECT nmextcon,
             cdempcon,
             cdsegmto,
             flgcnvsi
        FROM crapcon
       WHERE crapcon.cdcooper = pr_cdcooper
         AND crapcon.flgcnvsi = 1    /* TRUE =SCIREDI */
         AND ((pr_cdempcon <> 0 AND
               crapcon.cdempcon = pr_cdempcon) OR
               crapcon.cdempcon > 0
              )
         AND ((pr_cdsegmto <> 0 AND
               crapcon.cdsegmto = pr_cdsegmto) OR
               crapcon.cdsegmto > 0
              )
         AND ((pr_nmrescon IS NOT NULL AND
               crapcon.nmrescon like '%'||pr_nmrescon||'%') or
               pr_nmrescon IS NULL
              )
       ORDER by crapcon.cdempcon;


  BEGIN
    vr_nrregist := pr_nrregist;

    -- Buscar Cadastro de convenios
    FOR rw_crapcon IN cr_crapcon LOOP

      pr_qtregist := NVL(pr_qtregist,0) + 1;

      /* controles da paginação */
      IF (pr_qtregist < pr_nriniseq) OR
         (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
        CONTINUE;
      END IF;

      IF vr_nrregist >= 1 THEN
        vr_idx := nvl(pr_tab_empr_conve.count,0) + 1;

        pr_tab_empr_conve(vr_idx).nmextcon := rw_crapcon.nmextcon;
        pr_tab_empr_conve(vr_idx).cdempcon := rw_crapcon.cdempcon;
        pr_tab_empr_conve(vr_idx).cdsegmto := rw_crapcon.cdsegmto;
        pr_tab_empr_conve(vr_idx).flgcnvsi := (CASE rw_crapcon.flgcnvsi
                                                WHEN 1 THEN 'SIM'
                                                WHEN 0 THEN 'NAO'
                                               END);

      END IF;

      vr_nrregist := vr_nrregist - 1;

    END LOOP;

    pr_dscritic := 'OK';

  END pc_lista_empresas_conv;

  /* Gerar tempTable dos Lancamentos de faturas.(craplft)  dos convenios*/
  PROCEDURE pc_consulta_faturas(pr_cdcooper  IN INTEGER      -- Codigo da cooperativa
                               ,pr_dtmvtolt  IN DATE         -- Data de movimento
                               ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                               ,pr_dtdpagto  IN DATE         -- Data de pagamento
                               ,pr_vldpagto  IN NUMBER       -- Valor do pagamento
                               ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                               ,pr_cdhistor  IN INTEGER      -- Codigo do historico
                               ,pr_flgpagin  IN BOOLEAN      -- Indicativo  de paginação
                               ,pr_nrregist  IN INTEGER      -- Número de controle de registros
                               ,pr_nriniseq  IN INTEGER      -- Número de controle de inicio de registro
                               ,pr_cdempcon  IN VARCHAR2     -- Codigo da empresa a ser conveniada.
                               ,pr_cdsegmto  IN INTEGER      -- Identificacao do segmento da empresa/orgao
                               ,pr_flgcnvsi  IN BOOLEAN      -- Indicador SICREDI associa ao historico específico
                               ,pr_qtregist OUT INTEGER      -- Retorna a quantidade de registro
                               ,pr_dscritic OUT VARCHAR2     -- Descricao da critica
                               ,pr_vlrtotal OUT NUMBER       -- Valor total
                               ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                               ,pr_tab_dados_pesqti OUT CONV0001.typ_tab_dados_pesqti) IS -- tabela de historicos
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_consulta_faturas           Antigo: Antigo b1wgen0101.p/consulta_faturas
  --  Sistema  : Procedimentos para Convenios
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana (AMcom)
  --  Data     : Novembro/2013.                Ultima atualizacao: 21/11/2013
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para gerar tempTable de historico de Cadastro de convenios(gnconve)
  ---------------------------------------------------------------------------------------------------------------

    vr_exc_erro EXCEPTION;
    vr_nrregist NUMBER;
    vr_idx      INTEGER;
    vr_dtdpagto DATE;
    vr_tab_historicos CONV0001.typ_tab_historicos;
    vr_tab_empr_conve CONV0001.typ_tab_empr_conve;
    vr_dscritic VARCHAR2(500)      ;
    vr_cdhistor craplft.cdhistor%type;

    vr_qtregist number;

    -- Buscar Lancamentos de faturas.
    CURSOR cr_craplft (pr_dtdpagto IN DATE ,
                       pr_cdhistor IN NUMBER,
                       pr_flgcnvsi IN INTEGER) IS
      SELECT cdagetfn,
             nrterfin,
             cdcoptfn,
             cdbccxlt,
             cdbarras,
             cdagenci,
             insitfat,
             vlrjuros,
             vlrmulta,
             vllanmto,
             nrdolote,
             nrdconta,
             cdseqfat,
             nrautdoc
        FROM craplft
       WHERE craplft.cdcooper = pr_cdcooper
         AND craplft.dtmvtolt = pr_dtdpagto
         AND ((pr_cdagenci <> 0 AND
               craplft.cdagenci = pr_cdagenci) OR
               craplft.cdagenci > 0
              )
         AND (
              (pr_cdhistor <> 0 AND craplft.cdhistor = pr_cdhistor) OR
              (( pr_flgcnvsi = 0 AND craplft.cdhistor <> 1154) OR /* PGTO.CONVENIO */
               (craplft.cdhistor = pr_cdhistor)
               )
              )
         AND ((pr_cdempcon <> 0 AND
               craplft.cdempcon = pr_cdempcon) OR
               1 = 1 -- True, para desconsiderar a clausula acima
              )
         AND ((pr_cdsegmto <> 0 AND
               craplft.cdsegmto = pr_cdsegmto) OR
               1 = 1 -- True, para desconsiderar a clausula acima
              );

    -- busca Cadastro de Bancos
    CURSOR cr_crapban (pr_cdbccxlt crapban.cdbccxlt%type) IS
      SELECT nmextbcc
        FROM crapban
       WHERE crapban.cdbccxlt = pr_cdbccxlt;
    rw_crapban cr_crapban%ROWTYPE;

    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Verificar se o valor do campo esta contido na temptable
    FUNCTION pc_verif_tab_empr( pr_tab_empr_conve IN CONV0001.typ_tab_empr_conve --> TempTable contendo os registros
                               ,pr_campo          IN VARCHAR2                    --> Descrição do campo a ser procurado
                               ,pr_valor          IN VARCHAR2)                   --> Valor do campo a ser procurado
                               RETURN BOOLEAN IS
    BEGIN

      --Varrer o loop procurando se o valor passado consta na temptable
      FOR vridx IN pr_tab_empr_conve.FIRST..pr_tab_empr_conve.LAST LOOP
        IF ( pr_campo = 'CDEMPCON' AND
             pr_tab_empr_conve(vridx).CDEMPCON = pr_valor)
            OR
            (pr_campo = 'CDSEGMTO' AND
             pr_tab_empr_conve(vridx).CDSEGMTO = pr_valor) THEN
          --se localizou 1 retorna verdadeiro
          RETURN TRUE;

        END IF;
      END LOOP;

      --se terminou e não localizou retornar falso
      RETURN FALSE;
    END pc_verif_tab_empr;

  BEGIN
    vr_nrregist := nvl(pr_nrregist,0);
    vr_dtdpagto := nvl(pr_dtdpagto,pr_dtmvtolt);


    /* Verifica o hist. informado */
    IF nvl(pr_cdhistor,0) <> 0 THEN
      CONV0001.pc_lista_historicos ( pr_cdhiscxa => 0     -- Codigo do hist do caixa
                                    ,pr_nmempres => null  -- Nome da Empresa
                                    ,pr_nrregist => 999   -- Número de controle de registros
                                    ,pr_nriniseq => 0     -- Número de controle de inicio de registro
                                    ,pr_qtregist => vr_qtregist  -- Retorna a quantidade de registro
                                    ,pr_dscritic => pr_dscritic  -- Descricao da critica
                                    ,pr_tab_historicos => vr_tab_historicos);
      IF pr_dscritic <> 'OK' then
        RETURN;
      END IF;
      -- SE não encontrou o historico, gerar erro
      IF NOT vr_tab_historicos.EXISTS(pr_cdhistor) THEN

        vr_dscritic := 'Historico nao encontrado.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => 1,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
        pr_dscritic := 'NOK';
        RETURN;

      END IF;
    END IF;

    /* Verifica Empr. e Segmto. */
    IF  pr_cdempcon <> 0 AND
        pr_cdsegmto <> 0 THEN

      CONV0001.pc_lista_empresas_conv( pr_cdcooper  => pr_cdcooper    -- Codigo da cooperativa
                                      ,pr_cdempcon  => pr_cdempcon    -- Codigo da empresa a ser conveniada.
                                      ,pr_cdsegmto  => pr_cdsegmto    -- Identificacao do segmento da empresa/orgao
                                      ,pr_nmrescon  => NULL           -- Nome fantasia da empresa a ser conveniada.
                                      ,pr_nrregist  => 999            -- Número de controle de registros
                                      ,pr_nriniseq  => 0              -- Número de controle de inicio de registro
                                      ,pr_qtregist  => vr_qtregist    -- Retorna a quantidade de registro
                                      ,pr_dscritic  => pr_dscritic    -- Descricao da critica
                                      ,pr_tab_empr_conve => vr_tab_empr_conve); -- tabela de historicos

      IF pr_dscritic <> 'OK' then
        RETURN;
      END IF;

      IF NOT pc_verif_tab_empr( vr_tab_empr_conve,'CDEMPCON',pr_cdempcon) OR
         NOT pc_verif_tab_empr( vr_tab_empr_conve,'CDSEGMTO',pr_cdsegmto) THEN

        vr_dscritic := 'Empresa e Segmento nao conferem ou '||
                       'nao sao SICREDI.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => 1,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
        pr_dscritic := 'NOK';
        RETURN;

      END IF;

    END IF;

    /* Se for Conv. SICREDI associa ao historico específico */
    IF pr_flgcnvsi THEN
      vr_cdhistor := 1154;
    ELSE
      vr_cdhistor := pr_cdhistor;
    END IF;

    -- Loopr para lancamentos de faturas
    FOR rw_craplft IN cr_craplft (pr_dtdpagto => vr_dtdpagto,
                                  pr_cdhistor => vr_cdhistor,
                                  pr_flgcnvsi => (case pr_flgcnvsi
                                                  when true then 1
                                                  else 0 end )) LOOP

      IF pr_vldpagto <> 0 THEN
        IF (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros) < pr_vldpagto THEN
          continue;
        END IF;
      END IF;

      pr_qtregist := NVL(pr_qtregist,0) + 1;

      /* controles da paginação */
      IF pr_flgpagin  AND
         (pr_qtregist < pr_nriniseq  OR
          pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
        CONTINUE;
      END IF;

      IF NOT pr_flgpagin OR vr_nrregist > 0 THEN
        pr_vlrtotal := nvl(pr_vlrtotal,0) +
                      (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);

        vr_idx := nvl(pr_tab_dados_pesqti.count,0) + 1;

        pr_tab_dados_pesqti(vr_idx).cdbandst := rw_craplft.cdbccxlt;
        pr_tab_dados_pesqti(vr_idx).dscodbar := rw_craplft.cdbarras;
        pr_tab_dados_pesqti(vr_idx).nrautdoc := rw_craplft.nrautdoc;
        pr_tab_dados_pesqti(vr_idx).nrdocmto := TO_NUMBER(SUBSTR(rw_craplft.cdseqfat,1,27));
        pr_tab_dados_pesqti(vr_idx).nrdconta := rw_craplft.nrdconta;
        pr_tab_dados_pesqti(vr_idx).nmoperad := '       *********';
        pr_tab_dados_pesqti(vr_idx).nrdolote := rw_craplft.nrdolote;
        pr_tab_dados_pesqti(vr_idx).vldpagto := (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);
        pr_tab_dados_pesqti(vr_idx).cdagenci := rw_craplft.cdagenci;
        pr_tab_dados_pesqti(vr_idx).vlconfoz := TO_NUMBER(SUBSTR(rw_craplft.cdbarras,24,10)) / 100;
        pr_tab_dados_pesqti(vr_idx).insitfat := rw_craplft.insitfat;

        -- Ler cadastro de banco
        OPEN cr_crapban(pr_cdbccxlt => rw_craplft.cdbccxlt);
        FETCH cr_crapban
         INTO rw_crapban;
        --se não localizar
        IF cr_crapban%notfound THEN
          pr_tab_dados_pesqti(vr_idx).nmextbcc := '** BANCO NAO CADASTRADO **';
          CLOSE cr_crapban;
        ELSE
          pr_tab_dados_pesqti(vr_idx).nmextbcc := rw_crapban.nmextbcc;
          CLOSE cr_crapban;
        END IF;

        IF rw_craplft.cdagenci = 91  THEN /** TAA **/
          -- Ler a cooperativa
          OPEN cr_crapcop(pr_cdcooper => rw_craplft.cdcoptfn);
          FETCH cr_crapcop
           INTO rw_crapcop;
          -- Se nao encontrar
          IF cr_crapcop%NOTFOUND THEN
            -- Apenas fechar o cursor
            CLOSE cr_crapcop;
          ELSE
            pr_tab_dados_pesqti(vr_idx).dspactaa := to_char(rw_crapcop.cdagectl,'9999') ||'/'||
                                                    to_char(rw_craplft.cdagetfn,'9999') ||'/'||
                                                    to_char(rw_craplft.nrterfin,'9999');

            CLOSE cr_crapcop;
          END IF;
        END IF;

      END IF;
      IF pr_flgpagin THEN
        vr_nrregist := NVL(vr_nrregist,0) - 1;
      END IF;

    END LOOP;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na CONV0001.pc_consulta_faturas: '||SQLerrm;
  END pc_consulta_faturas;

  /* Gerar registros na crapndb para devolucao de debitos automaticos. */
  PROCEDURE pc_lotee_1a (pr_cdcooper IN crapcop.cdcooper%TYPE  -- Código da Cooperativa
                        ,pr_cdhistor IN craphis.cdhistor%TYPE  -- Código do Histórico
                        ,pr_cdagenci OUT crapass.cdagenci%TYPE -- Código da Agência
                        ,pr_codcoope OUT crapcop.cdcooper%TYPE -- Código da Cooperativa
                        ,pr_cdcritic OUT INTEGER               -- Código do erro
                        ,pr_dscritic OUT VARCHAR2) IS          -- Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_lotee_1a           Antigo: fontes/lotee_1a.p
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    :
  --  Data     : -----                    Ultima atualizacao: 23/10/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : -----
  -- Alteracoes: 29/05/2009 - Inclui "9" mais o codigo da cooperativa na conta do
  --                          cooperado se for diferente de Viacredi ou CECRED ou
  --                          se convenio for Unimed ou Uniodonto (Elton).

  --             20/09/2013 - Adicionado format no par_cdagenci. (Reinert)
  --
  --             03/01/2014 - Conversão Progress >> PLSQL (Jean Michel).
  --
  --             23/10/2014 - Tratamento para o campo Usa Agencia
  --                          (gnconve.flgagenc); convenios a partir de 2014.
  --                          (Fabricio)
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE

      -- VARIAVEIS DE ERRO--
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- VARIAVEIS DE EXCECAO
      vr_exc_erro EXCEPTION;


    BEGIN
      -- CURSOR DE COOPERATIVA
      OPEN cr_crapcop(pr_cdcooper);
        FETCH cr_crapcop
          INTO rw_crapcop;

        IF cr_crapcop%NOTFOUND THEN
          -- FECHAR O CURSOR POIS HAVERÁ RAISE
          CLOSE cr_crapcop;
        ELSE
          -- APENAS FECHAR O CURSOR
          CLOSE cr_crapcop;
        END IF;

      -- CODIGO DE COOPERATI
      pr_codcoope := 8888;

      -- LACO PARA CURSOR DOS CONVENIOS POR COOPERATIVA
      OPEN cr_gncvcop(pr_cdcooper);
      LOOP
        FETCH cr_gncvcop
          INTO rw_gncvcop;

        EXIT WHEN cr_gncvcop%NOTFOUND;

        -- LEITURA DE CONVENIOS
        OPEN cr_gnconve_II(rw_gncvcop.cdconven, pr_cdhistor);
        LOOP
          FETCH cr_gnconve_II
            INTO rw_gnconve_II;

          -- SIA DO LOOP QUANDO NAO HOUVER MAIS REGISTROS A SEREM LIDOS
          EXIT WHEN cr_gnconve_II%NOTFOUND;

          -- CODIGO DA AGENCIA
          pr_cdagenci := gene0002.fn_mask(rw_crapcop.cdagectl, '9999');

          -- VERIFICA SE COOPERATIVA É A VIACREDI OU SE EXISTE CONVENIOS
          IF (rw_crapcop.cdcooper = 1 OR rw_gnconve_II.cdcooper = rw_crapcop.cdcooper OR
              rw_gnconve_II.flgagenc = 1) AND
              rw_gnconve_II.cdconven NOT IN (22,32,38,43,46,47,55,57,58) THEN

            -- CODIGO DA COOPERATIVA
            pr_codcoope := NULL;

          ELSE
            -- CODIGO DA COOPERATIVA
            pr_codcoope := '9' || gene0002.fn_mask(rw_crapcop.cdcooper,'999');

          END IF;

          EXIT;
        -- FIM LOOP CR_GNCONVE_II
        END LOOP;
        -- FECHA CURSOR
        CLOSE cr_gnconve_II;
      -- FIM LOOP CR_GNCVCOP
      END LOOP;
      CLOSE cr_gncvcop;

    -- VERIFICA SE HOUVE EXCEÇÃO
    EXCEPTION
      WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CONV0001.pc_lotee_1a. ' || sqlerrm;
    END;
  END;

  /* Consulta de convênios */
  PROCEDURE pc_gerandb (pr_cdcooper IN crapcop.cdcooper%TYPE  -- Código da Cooperativa
                       ,pr_cdhistor IN craphis.cdhistor%TYPE  -- Código do Histórico
                       ,pr_nrdconta IN crapass.nrdconta%TYPE  -- Numero da Conta
                       ,pr_cdrefere IN crapatr.cdrefere%TYPE  -- Código de Referência
                       ,pr_vllanaut IN craplau.vllanaut%TYPE  -- Valor Lancamento
                       ,pr_cdseqtel IN craplau.cdseqtel%TYPE  -- Código Sequencial
                       ,pr_nrdocmto IN craplau.nrdocmto%TYPE  -- Número do Documento
                       ,pr_cdagesic IN crapcop.cdagesic%TYPE  -- Agência Sicredi
                       ,pr_nrctacns IN crapass.nrctacns%TYPE  -- Conta do Consórcio
                       ,pr_cdagenci IN crapass.cdagenci%TYPE  -- Codigo do PA
                       ,pr_cdempres IN craplau.cdempres%TYPE  -- Empresa sicredi
                       ,pr_idlancto IN craplau.idlancto%TYPE  -- Código lancamento                      
                       ,pr_codcriti IN INTEGER                -- Código do erro
                       ,pr_cdcritic OUT INTEGER               -- Código do erro
                       ,pr_dscritic OUT VARCHAR2) IS          -- Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gerandb           Antigo: Includes/gerandb.i
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : Odair
  --  Data     : Agosto/98.                  Ultima atualizacao: 16/10/2017
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Gerar crapndb para devolucao de debitos automaticos.
  --
  -- ALTERACAO : 24/12/98 - TRATAR BTV. (Odair).
  --
  --             22/03/99 - Tratar dtmvtolt atraves de inproces (Odair)
  --
  --             25/10/99 - Tratar celular separado de fixo (Odair)
  --
  --             01/11/2000 - Ajustar o programa para que trabalhem por
  --                          parametros para o historico 30 (Eduardo).
  --
  --             24/01/2001 - Tratar hist.371 GLOBAL TELECOM (Margarete/Planner).
  --
  --             05/04/2001 - Padronizar os procedimentos para qualquer
  --                          cooperativa. (Ze Eduardo).
  --
  --             02/01/2003 - Ajustes para a Brasil Telecom (Deborah).
  --
  --             09/06/2004 - Acessar tabela de convenio generica(Mirtes)
  --
  --             06/07/2005 - Alimentado campo cdcooper da tabela crapndb (Diego).
  --
  --             29/08/2006 - Melhorias no codigo fonte para nao precisar
  --                          mais tratar cada convenmio novo que entrar (Julio).
  --
  --             04/06/2012 - Tratamento para critica de cancelamento de debito
  --                          automatico (Elton).
  --
  --             10/12/2013 - Alteracao referente a integracao Progress X
  --                          Dataserver Oracle Inclusao do VALIDATE ( André Euzébio / SUPERO)
  --
  --             23/01/2014 - Ajustes para crapndb gerar registro "F" de
  --                          consorcios (Lucas R.)
  --
  --             30/01/2014 - Conversão Progress >> PLSQL (Jean Michel).
  --
  --             29/04/2014 - Correção na gravação do campo crapndb.dstexarq, pois
  --                          havia um trim desnecessário (Marcos-Supero)
  --
  --             02/05/2014 - Incluir ajustes referentes ao debito automatico
  --                          Softdesk 144066 (Lucas R.)
  --
  --             13/08/2014 - Tratamento para SULAMERICA (cdhistor = 1517) para,
  --                          no retorno da critica, enviarmos o campo de
  --                          contrato com 22 posicoes preenchidas, seguido de
  --                          tres espacos em branco. (Chamado 182918 - Fabricio)
  --
  --             25/09/2014 - Tratamento para PREVISUL (cdhistor = 1723) para,
  --                          no retorno da critica, enviarmos o campo de
  --                          contrato com 20 posicoes preenchidas, seguido de
  --                          cinco espacos em branco. (Chamado 101648 - Fabricio)
  --
  --             30/10/2014 - Tratamento para o preenchimento dos campos do cdrefere
  --                          (Lucas R./Elton)
  --
  --             10/02/2015 - Criação de crítica '05' quando crítica de limite excedido (967)
  --                          for recebida (Lunelli - SD. 229251)
  --
  --             17/04/2015 - Ajustado gravacao do campo crapscn.cdempres na tabela crapndb
  --                          quando convenio Sicredi. (Chamado 268307) - (Fabricio)
  --                        - Tratado critica 453 para retorno a empresa (crapndb).
  --                          (Chamado 275834) - (Fabricio)
  --
  --             11/05/2015 - Alterado ordem em que era armazenado os valores do campo
  --                          vr_dtmvtolt, pois quando é chamada a procedure via tela
  --                          gravava na posição da data no arquivo com a data do próximo
  --                          dia útil (Lucas Ranghetti #265396)
  --
  --             13/05/2015 - Adicionado historicos 834,901,993,1061 TIM Celular,HDI,LIBERTY SEGUROS,
  --                          PORTO SEGURO, que ja existia  para PREVISUL, no retorno da critica,
  --                          enviarmos o campo de contrato com 20 posicoes preenchidas, seguido de
  --                          cinco espacos em branco (Lucas Ranghetti #285063)
  --
  --             13/08/2015 - Adicioanar tratamento para o convenio MAPFRE VERA CRUZ SEG, referencia
  --                          e conta (Lucas Ranghetti #292988 )
  --
  --             15/02/2016 - Incluir validacao de cooperado demitido critica '15' (Lucas Ranghetti #386413)
  --
  --             24/03/2016 - Adicionado tratamento para a vivo historico 453, gravar     
  --                          na crapndb com 11 posicoes (Lucas Ranghetti #417302 )
  --
  --             21/06/2016 - Adicionar historico 690 do Samae Sao Bento para 10 posicoes (Lucas Ranghetti #467618)  
  --
  --             27/07/2016 - Adicionar historico 900 do Samae Rio Negrinho para 6 posicoes (Lucas Ranghetti #486565)
  --
  --             21/11/2016 - Se for o convenio 045, 14 BRT CELULAR - FEBRABAN e referencia conter 11 
  --                          posicoes, devemos incluir um hifen para completar 12 posicoes 
  --                          ex: 40151016407- (Lucas Ranghetti #560620/453337)
  --
  --             31/03/2017 - Incluir PREVISC para fazer como faz a SULAMERICA (Lucas Ranghetti #637882)
  --
  --             04/04/2017 - Ajuste para integracao de arquivos com layout na versao 5
  --			                    (Jonata - RKAM M311).
  --
  --             29/05/2017 - Incluir nova procedure pc_gerandb_car para chamar a pc_gerandb
  --                          (Lucas Ranghetti #681579)
  --             15/05/2017 - Adicionar tratamento para o convenio CERSAD 9 posicoes
  --                          (Lucas Ranghetti #622377)
  --
  --             26/05/2017 - Adicionar tratamento para o convenio AGUAS DE GUARAMIRIM 8 posicoes
  --                          (Tiago/Fabricio #640336)  
  --
  --             07/06/2017 - Adicionar UNIFIQUE POMERODE para completar com 22 zeros a esquerda
  --                          conforme faz para Sulamerica (Lucas Ranghetti #663781)
  --  
  --             27/06/2017 - Adicionar tratamento para o convenio AGUAS DE JOINVILLE 8 posicoes
  --                          (Tiago/Fabricio #692918)
  --
  --             10/07/2017 - Adicionar tratamento para o convenio SANEPAR 8 posicoes
  --                          (Tiago/Fabricio #673343)  
  --
  --             29/09/2017 - Incluir validacao de 23 posicoes para a CHUBB(Lucas Ranghetti #766211)
  --
  --             16/10/2017 - Adicionar chamada da procedure pc_retorna_referencia_conv para 
  --                          formatar a referencia do convenio de acordo com o cadastrado
  --                          na tabela crapprm (Lucas Ranghetti #712492)
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE

      -- VARIAVEIS DE ERRO
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic VARCHAR2(4000);

      -- VARIAVEIS DE EXCECAO
      vr_exc_erro EXCEPTION;

      -- DIVERSAS
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdagenci crapass.cdagenci%TYPE;
      vr_cdhistor craplau.cdhistor%TYPE;
      vr_nrdconta VARCHAR2(50);
      vr_dstexarq VARCHAR2(160) := 'F';
      vr_auxcdcri VARCHAR2(50);
      vr_dtmvtolt craplau.dtmvtolt%TYPE;
      vr_flgsicre INTEGER := 0;
      vr_cdseqtel VARCHAR2(60);
      vr_cdrefere VARCHAR2(25);
      vr_qtdigito INTEGER;      

      -- VARIAVEIS PARA CAULCULO DE DIGITOS A COMPLETAR COM ZEROS OU ESPAÇOS
      vr_resultado VARCHAR2(25);

      -- CURSOR GENÉRICO DE CALENDÁRIO
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      /* Tributos do convenio sicredi */
      CURSOR cr_crapscn IS
        SELECT scn.cdempres,
               scn.qtdigito,
               scn.tppreenc
          FROM crapscn scn
         WHERE scn.cdempres = pr_cdempres;
       rw_crapscn cr_crapscn%ROWTYPE;

       CURSOR cr_tbconv_det_agendamento(pr_idlancto IN craplau.idlancto%TYPE) IS
       SELECT t.cdlayout
             ,t.tppessoa_dest
             ,t.nrcpfcgc_dest
        FROM tbconv_det_agendamento t
       WHERE t.idlancto = pr_idlancto;
       rw_tbconv_det_agendamento cr_tbconv_det_agendamento%ROWTYPE;  

      /*PROCEDIMENTOS E FUNCOES INTERNAS*/
      FUNCTION fn_verifica_ult_dia(pr_cdcooper crapcop.cdcooper%TYPE, pr_dtrefere  IN DATE) RETURN DATE IS
      BEGIN
        DECLARE
          CURSOR cr_ultdia(pr_cdcooper crapcop.cdcooper%TYPE) IS
            SELECT TRUNC(add_months(dat.dtmvtolt,12),'RRRR')-1 AS ultimdia
              FROM crapdat dat
             WHERE dat.cdcooper = pr_cdcooper;

          rw_ultdia cr_ultdia%ROWTYPE;

        BEGIN
          IF pr_dtrefere IS NOT NULL THEN

             OPEN cr_ultdia(pr_cdcooper => pr_cdcooper);

             FETCH cr_ultdia INTO rw_ultdia;

             IF cr_ultdia%FOUND THEN
               CLOSE cr_ultdia;

               IF pr_dtrefere = rw_ultdia.ultimdia THEN
                  rw_ultdia.ultimdia := rw_ultdia.ultimdia + 1;
                  RETURN gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => rw_ultdia.ultimdia);
               END IF;
             ELSE
               CLOSE cr_ultdia;
               RETURN pr_dtrefere;
             END IF;
          END IF;

          RETURN pr_dtrefere;
        END;
      END fn_verifica_ult_dia;

    BEGIN
      -- LEITURA DO CALENDÁRIO DA COOPERATIVA
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      -- SE NÃO ENCONTRAR
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- FECHAR O CURSOR POIS EFETUAREMOS RAISE
        CLOSE btch0001.cr_crapdat;
        -- MONTAR MENSAGEM DE CRITICA
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      ELSE
        -- APENAS FECHAR O CURSOR
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- CODIGO DE HISTORICO
      vr_cdhistor := pr_cdhistor;

      -- CODIGO DE ERRO
      vr_cdcritic := pr_codcriti;

      IF pr_cdhistor IN(1230,1231,1232,1233,1234,1019) THEN
        
        vr_flgsicre := 1; -- HISTORICOS DO CONSORCIO SICREDI E DEB. AUTOMATICO
      
      ELSE
        -- LEITURA PARA ENCONTRAR DETALHE DO AGENDAMENTO
        OPEN cr_tbconv_det_agendamento(pr_idlancto => pr_idlancto);
        
        FETCH cr_tbconv_det_agendamento INTO rw_tbconv_det_agendamento;
        
        -- SE NÃO ENCONTRAR
        IF cr_tbconv_det_agendamento%NOTFOUND THEN
          -- FECHAR O CURSOR POIS EFETUAREMOS RAISE
          CLOSE cr_tbconv_det_agendamento;
          -- MONTAR MENSAGEM DE CRITICA
          vr_cdcritic := 597;
          RAISE vr_exc_erro;
        ELSE
          -- APENAS FECHAR O CURSOR
          CLOSE cr_tbconv_det_agendamento;
        END IF;
        
      END IF;

      vr_auxcdcri := vr_cdcritic;
      -- CONSULTA DE CONVENIOS
      conv0001.pc_lotee_1a(pr_cdcooper => pr_cdcooper   -- Código da Cooperativa
                          ,pr_cdhistor => vr_cdhistor   -- Código do Histórico
                          ,pr_cdagenci => vr_cdagenci   -- Código da Agência
                          ,pr_codcoope => vr_cdcooper   -- Código da Cooperativa
                          ,pr_cdcritic => vr_cdcritic   -- Código do erro
                          ,pr_dscritic => vr_dscritic); -- Descricao do erro

      -- VERIFICA SE HOUVE ERRO NA CONSULTA DE CONVENIOS
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      vr_cdcritic := vr_auxcdcri;

      -- VERIFICA CODIGO DA COOPERATIVA
      IF vr_cdcooper = 8888 AND vr_flgsicre = 0 THEN
        vr_cdcritic := 472; -- FALTA TABELA DE CONVENIO
      ELSE
        -- VERIFICA HISTORICO
        IF pr_cdhistor = 48 THEN -- RECEBIMENTO CASAN AUTOMATICO
          -- CODIGO DA AGENCIA
          vr_cdagenci := 1294;
        END IF;

        -- VERIFICA SE COOPERATIVA É NULA
        IF vr_cdcooper IS NULL THEN
          vr_nrdconta := gene0002.fn_mask(pr_nrdconta, '99999999');
        ELSE
          vr_nrdconta := gene0002.fn_mask(vr_cdcooper, '9999') || gene0002.fn_mask(pr_nrdconta, '99999999');
        END IF;

        -- Buscar referencia formatada 
        pc_retorna_referencia_conv(pr_cdconven => 0, 
                                   pr_cdhistor => pr_cdhistor, 
                                   pr_cdrefere => pr_cdrefere, 
                                   pr_nrrefere => vr_cdrefere, 
                                   pr_qtdigito => vr_qtdigito, 
                                   pr_cdcritic => vr_cdcritic, 
                                   pr_dscritic => vr_dscritic);

        -- VERIFICAÇÃO DE HISTÓRICOS
        IF vr_qtdigito <> 0 THEN -- CERSAD E SANEPAR
          vr_dstexarq := vr_dstexarq || vr_cdrefere;
        ELSIF pr_cdhistor IN(31,690)  THEN -- BRASIL TELECOM DB. AUTOMATICO/SAMAE SAO BENTO
          vr_dstexarq := vr_dstexarq || gene0002.fn_mask(pr_cdrefere,'9999999999') || RPAD(' ',15,' ');
        ELSIF pr_cdhistor IN (48,2284,554) THEN -- RECEBIMENTO CASAN AUTOMATICO | AGUAS GUARAMIRIM | AGUAS JOINVILLE
          vr_dstexarq := vr_dstexarq || gene0002.fn_mask(pr_cdrefere,'99999999') || RPAD(' ',17,' ');
        ELSIF pr_cdhistor IN(2039,1517,2025) THEN -- PREVISC, SULAMERICA,UNIFIQUE POMERODE
          vr_dstexarq := vr_dstexarq || gene0002.fn_mask(pr_cdrefere,'9999999999999999999999') ||
                                        RPAD(' ',3,' ');
        ELSIF pr_cdhistor IN(2302) THEN -- CHUBB SEGUROS BRASIL
          vr_dstexarq := vr_dstexarq || gene0002.fn_mask(pr_cdrefere,'99999999999999999999999') ||
                                        RPAD(' ',2,' ');
        ELSIF pr_cdhistor IN(834,901,993,1061,1723) THEN -- TIM Celular,HDI,LIBERTY SEGUROS,PORTO SEGURO,PREVISUL
          vr_dstexarq := vr_dstexarq || gene0002.fn_mask(pr_cdrefere,'99999999999999999999') ||
                                        RPAD(' ',5,' ');
        ELSIF pr_cdhistor IN(1994,1992) THEN --  MAPFRE VERA CRUZ SEG
          vr_dstexarq := vr_dstexarq || pr_cdrefere || RPAD(' ',25 - LENGTH(pr_cdrefere),' ');
          vr_nrdconta := gene0002.fn_mask(pr_nrdconta, '99999999999999');
        ELSIF pr_cdhistor = 453 THEN -- VIVO/TELEFONICA
          vr_dstexarq := vr_dstexarq || gene0002.fn_mask(pr_cdrefere,'99999999999') || RPAD(' ',14,' ');
        ELSIF pr_cdhistor = 900 THEN -- Samae Rio Negrinho
          vr_dstexarq := vr_dstexarq || gene0002.fn_mask(pr_cdrefere,'999999') || RPAD(' ',19,' ');
        ELSIF vr_flgsicre = 0 THEN -- RECEBIMENTO SAMAE BLUMENAU AUTOMATICO
          vr_dstexarq := vr_dstexarq || pr_cdrefere || RPAD(' ',25 - LENGTH(pr_cdrefere),' ');
        END IF;

        -- VERIFICACAO DE CRITICA
        IF vr_cdcritic IN (453,447) THEN -- AUTORIZACAO NAO ENCONTRADA / AUTORIZACAO CANCELADA
          vr_auxcdcri := '30'; -- SEM CONTRATO DE DÉBITO
        ELSIF vr_cdcritic = 967 THEN -- VALOR LIMITE ULTRAPASSADO
          vr_auxcdcri := '05';
        ELSIF vr_cdcritic = '64' THEN -- Cooperado demitido
          vr_auxcdcri := '15'; -- Conta corrente invalida
		ELSIF vr_cdcritic = '964' THEN -- Lançamento bloqueado
          vr_auxcdcri := '04'; -- Outros
        ELSIF rw_tbconv_det_agendamento.cdlayout = 5 AND (vr_cdcritic = '1001' OR vr_cdcritic = '1002' OR vr_cdcritic = '1003') THEN 
          vr_auxcdcri := '19'; -- Outros
        ELSE
          vr_auxcdcri := '01'; -- INSUFICIENCIAS DE FUNDOS
        END IF;

        -- Verificação de data se for chamado via tela ou pelo processo
        IF rw_crapdat.inproces = 1 THEN
          vr_dtmvtolt := rw_crapdat.dtmvtolt;
        ELSE
          vr_dtmvtolt := rw_crapdat.dtmvtopr;
        END IF;

        /* Pega proximo dia util se for ultimo dia do ano ou devolve
           a propria data passada como referencia */
        vr_dtmvtolt := fn_verifica_ult_dia(pr_cdcooper, vr_dtmvtolt);

        IF vr_flgsicre = 1 THEN -- CONSORCIO SICREDI / DEB. AUTOMATICO
          -- tributos do convenio SICREDI
          OPEN cr_crapscn;
          FETCH cr_crapscn INTO rw_crapscn;
          -- SE NAO ENCONTRAR
          IF cr_crapscn%NOTFOUND THEN
            --APENAS FECHAR O CURSOR
            CLOSE cr_crapscn;
          END IF;

          -- fazer o calculo de quantos digitos devera completar com espacos ou zeros
          -- Atribuir resultado com a quantidade de digitos da base
          IF rw_crapscn.tppreenc = 1 THEN
            IF rw_crapscn.qtdigito <> 0 THEN
              vr_resultado := LPAD(pr_nrdocmto,rw_crapscn.qtdigito,'0') ;
            ELSE
              vr_resultado := LPAD(pr_nrdocmto,25,'0') ;
            END IF;
          ELSIF rw_crapscn.tppreenc = 2 THEN
            IF rw_crapscn.qtdigito <> 0 THEN
              vr_resultado := RPAD(pr_nrdocmto,rw_crapscn.qtdigito,'0') ;
            ELSE
              vr_resultado := RPAD(pr_nrdocmto,25,'0') ;
            END IF;
          ELSE
            IF rw_crapscn.qtdigito <> 0 THEN
              vr_resultado :=  RPAD(pr_nrdocmto,rw_crapscn.qtdigito,' ');
            ELSE
              vr_resultado := RPAD(pr_nrdocmto,25,' ') ;
            END IF;
          END IF;

          IF length(vr_resultado) < 25 THEN
            -- completar com 25 espaços se resultado for inferior a 25 poscoes
            vr_resultado := RPAD(vr_resultado,25,' ');
          END IF;

          /* Se for o convenio 045 - 14 BRT CELULAR - FEBRABAN e tiver 11 posicoes, devemos 
             adicionar um hifen para completar 12 posicoes ex:(40151016407-) chamado 453337 */
          IF pr_cdempres = '045' AND LENGTH(pr_nrdocmto) = 11 THEN
            vr_resultado := RPAD(pr_nrdocmto,12,'-') || RPAD(' ',13,' ');
          END IF; 
        
          -- Se existir cdseqtel irá gravar na variavel
          IF trim(pr_cdseqtel) IS NOT NULL THEN
            vr_cdseqtel := RPAD(pr_cdseqtel,60);
          ELSE
            vr_cdseqtel := RPAD(' ',60);
          END IF;

          vr_cdagenci :=  SUBSTR(gene0002.fn_mask(pr_cdagenci,'999'),2,2);

          vr_dstexarq := 'F' || vr_resultado ||
                         gene0002.fn_mask(pr_cdagesic,'9999') ||
                         gene0002.fn_mask(pr_nrctacns,'999999') ||
                         gene0002.fn_mask('','zzzzzzzz') ||
                         TO_CHAR(vr_dtmvtolt,'yyyy') || TO_CHAR(vr_dtmvtolt,'mm') ||
                         TO_CHAR(vr_dtmvtolt,'dd') ||
                         gene0002.fn_mask(to_char(pr_vllanaut*100),'999999999999999') ||
                         vr_auxcdcri || vr_cdseqtel ||
                         RPAD(' ',16) || gene0002.fn_mask(vr_cdagenci,'99') ||
                         TRIM(rw_crapscn.cdempres) ||
                         RPAD(' ',10 - length(TRIM(rw_crapscn.cdempres))) || '0';
                         
        ELSIF rw_tbconv_det_agendamento.cdlayout = 5 THEN
          
          vr_dstexarq := vr_dstexarq ||
                         gene0002.fn_mask(vr_cdagenci,'9999') ||
                         vr_nrdconta ||
                         RPAD(' ', 14 - LENGTH(vr_nrdconta), ' ') ||
                         TO_CHAR(vr_dtmvtolt,'yyyy') ||
                         TO_CHAR(vr_dtmvtolt,'mm') ||
                         TO_CHAR(vr_dtmvtolt,'dd') ||
                         gene0002.fn_mask((pr_vllanaut * 100),'999999999999999') ||
                         vr_auxcdcri ||                          
                         RPAD(pr_cdseqtel,60) ||
                         rw_tbconv_det_agendamento.tppessoa_dest ||
                         LPAD(rw_tbconv_det_agendamento.nrcpfcgc_dest,15,'0') ||
                         RPAD(' ',4)                         
                         || '0';
                                                    
        ELSE

          vr_dstexarq := vr_dstexarq ||
                         gene0002.fn_mask(vr_cdagenci,'9999') ||
                         vr_nrdconta ||
                         RPAD(' ', 14 - LENGTH(vr_nrdconta), ' ') ||
                         TO_CHAR(vr_dtmvtolt,'yyyy') ||
                         TO_CHAR(vr_dtmvtolt,'mm') ||
                         TO_CHAR(vr_dtmvtolt,'dd') ||
                         gene0002.fn_mask((pr_vllanaut * 100),'999999999999999') ||
                         vr_auxcdcri || RPAD(pr_cdseqtel,80) || '0';
        END IF;

        BEGIN
          -- INSERE REGISTRO NA TABELA DE REGISTROS DE DEBITO EM CONTA NAO EFETUADOS
          INSERT INTO
            crapndb(
              dtmvtolt,
              nrdconta,
              cdhistor,
              flgproce,
              cdcooper,
              dstexarq
            )VALUES(
              vr_dtmvtolt,
              pr_nrdconta,
              pr_cdhistor,
              0,
              pr_cdcooper,
              vr_dstexarq
            );

        -- VERIFICA SE HOUVE PROBLEMA NA INCLUSÃO DO REGISTRO
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao inserir na tabela CRAPNDB: ' || sqlerrm;
            RAISE vr_exc_erro;
        END;

      END IF;

    -- VERIFICA SE HOUVE EXCECAO
    EXCEPTION
      WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CONV0001.pc_gerandb. ' || sqlerrm;
    END;
  END pc_gerandb;

  /* Gerar registros na crapndb para devolucao de debitos automaticos. */
  PROCEDURE pc_gerandb_car (pr_cdcooper IN crapcop.cdcooper%TYPE  -- Código da Cooperativa
                           ,pr_cdhistor IN craphis.cdhistor%TYPE  -- Código do Histórico
                           ,pr_nrdconta IN crapass.nrdconta%TYPE  -- Numero da Conta
                           ,pr_cdrefere IN VARCHAR2               -- Código de Referência
                           ,pr_vllanaut IN craplau.vllanaut%TYPE  -- Valor Lancamento
                           ,pr_cdseqtel IN craplau.cdseqtel%TYPE  -- Código Sequencial
                           ,pr_nrdocmto IN VARCHAR2               -- Número do Documento
                           ,pr_cdagesic IN crapcop.cdagesic%TYPE  -- Agência Sicredi
                           ,pr_nrctacns IN crapass.nrctacns%TYPE  -- Conta do Consórcio
                           ,pr_cdagenci IN crapass.cdagenci%TYPE  -- Codigo do PA
                           ,pr_cdempres IN craplau.cdempres%TYPE  -- Codigo empresa sicredi
                           ,pr_idlancto IN craplau.idlancto%TYPE  -- Código do lançamento        
                           ,pr_codcriti IN INTEGER                -- Código do erro
                           ,pr_cdcritic OUT INTEGER               -- Código do erro
                           ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................

    Programa: pc_gerandb_car
    Sistema : Chamar a pc_gerandb.
    Sigla   : CRED
    Autor   : Lucas Ranghetti
    Data    : Maio/2017.                    Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Chamar a pc_gerandb.

    Alteracoes:
    ..............................................................................*/
    DECLARE
      vr_exc_saida  EXCEPTION;
      vr_cdcritic NUMBER;
      vr_dscritic VARCHAR2(500);
    BEGIN
      
      conv0001.pc_gerandb(pr_cdcooper => pr_cdcooper
                         ,pr_cdhistor => pr_cdhistor
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_cdrefere => pr_cdrefere
                         ,pr_vllanaut => pr_vllanaut
                         ,pr_cdseqtel => pr_cdseqtel
                         ,pr_nrdocmto => pr_nrdocmto
                         ,pr_cdagesic => pr_cdagesic
                         ,pr_nrctacns => pr_nrctacns
                         ,pr_cdagenci => pr_cdagenci                         
                         ,pr_cdempres => pr_cdempres
                         ,pr_idlancto => pr_idlancto
                         ,pr_codcriti => pr_codcriti
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
    
      -- Se ocorrer algum erro
      IF vr_dscritic IS NOT NULL OR nvl(vr_cdcritic,0) <> 0 THEN
         RAISE vr_exc_saida;
      END IF;
    
    -- VERIFICA SE HOUVE EXCECAO
    EXCEPTION
      WHEN vr_exc_saida THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CONV0001.pc_gerandb_car. ' || sqlerrm;
    END;
  END pc_gerandb_car;


  -- Faz download de arquivo em um servidor FTP
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

      -- Preparar o comando de conexão e envio ao FTP
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

  -- Conectar-se ao FTP da Transabbc e efetuar download de três arquivos diariamente.
  PROCEDURE pc_busca_concilia_transabbc IS
  BEGIN
    /* .............................................................................

     Programa: pc_busca_concilia_transabbc
     Sistema : Conciliacoes diarias e mensais.
     Sigla   : CRED
     Autor   : Lucas Afonso Lombardi Moreira
     Data    : Setembro/15.                    Ultima atualizacao: 22/06/2015

     Dados referentes ao programa:

     Frequencia: Diariamente.

     Objetivo  : Conectar-se ao FTP da Transabbc e efetuar download de três
                 arquivos diariamente.

     Observacao: -----

     Alteracoes:
     ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(1000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      vr_serv_ftp    VARCHAR2(100);
      vr_user_ftp    VARCHAR2(100);
      vr_pass_ftp    VARCHAR2(100);
      
      vr_nmarquiv      VARCHAR2(100);
      vr_diames        VARCHAR2(100);
      vr_dir_local     VARCHAR2(100);
      vr_dir_remoto    VARCHAR2(100);

      vr_script_ftp    VARCHAR2(600);

      -- Cursor genérico de calendário
      rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;

      vr_jobname  VARCHAR2(40) := 'jbconv_concilia_transabbc';
      vr_idprglog PLS_INTEGER  := 0;

    BEGIN
      
      -- Somente executar a rotina de segunda a sexta... 
      IF to_char(SYSDATE,'d') IN(1,7) THEN
        RETURN;
      END IF;
    
      cecred.pc_log_programa(PR_DSTIPLOG   => 'I', 
                             PR_CDPROGRAMA => vr_jobname, 
                             PR_IDPRGLOG   => vr_idprglog);

      -- Buscar a data do movimento
      OPEN btch0001.cr_crapdat(3);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Verificar se existe informação, e gerar erro caso não exista
      IF btch0001.cr_crapdat%NOTFOUND THEN

        -- Fechar o cursor
        CLOSE btch0001.cr_crapdat;

        -- Gerar exceção
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
                                              ,pr_cdacesso => 'TRAN_BBC_DIR');

      vr_dir_local := GENE0001.fn_diretorio(pr_tpdireto => 'M' --> /micros
                                            ,pr_cdcooper => 3   --> Cooperativa
                                            ,pr_nmsubdir => 'contab');

      vr_script_ftp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_SCRIPT_FTP');

      -- Efetuar laço para buscarmos o arquivo do dia anterior, atual e próximo
      FOR vr_dia IN 1..3 LOOP
      
        -- Montar o dia conforme o laço
        IF vr_dia = 1 THEN
          vr_diames := to_char(rw_crapdat.dtmvtoan, 'DDMM');
        ELSIF vr_dia = 2 THEN
          vr_diames := to_char(rw_crapdat.dtmvtolt, 'DDMM');
        ELSE
          vr_diames := to_char(rw_crapdat.dtmvtopr, 'DDMM');
        END IF;  

        -- Forma o nome do arquivo DTSFDDMM.txt
        vr_nmarquiv := 'DTSF' || vr_diames || '.TXT';

        -- Executa o download do arquivo DTSFDDMM.txt
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

        -- Forma o nome do arquivo DTSFDDMM.txt
        vr_nmarquiv := 'DTSL' || vr_diames || '.TXT';

        -- Executa o download do arquivo DTSFDDMM.txt
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

        -- Forma o nome do arquivo RES_DDMM.txt
        vr_nmarquiv := 'RES_' || vr_diames || '.TXT';

        -- Executa o download do arquivo RES_DDMM.txt
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

      END LOOP;
      -- Gravar os comandos no banco
      COMMIT;
      
      cecred.pc_log_programa(PR_DSTIPLOG   => 'F', 
                             PR_CDPROGRAMA => vr_jobname, 
                             PR_IDPRGLOG   => vr_idprglog);

    EXCEPTION
      WHEN vr_exc_saida THEN

        btch0001.pc_gera_log_batch(pr_cdcooper     => 3 --> Sempre na Cecred
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'HH24:MI:SS') || 
                                                      ' - CONV0001.PC_BUSCA_CONCILIA_TRANSABBC Erro ao efetuar download dos arquivos: ' || vr_dscritic
                                  ,pr_dstiplog   => 'E'
                                  ,pr_cdprograma => vr_jobname);
        ROLLBACK;
      WHEN OTHERS THEN

        cecred.pc_internal_exception;
      
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3 --> Sempre na Cecred
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'HH24:MI:SS') || 
                                                      ' - CONV0001.PC_BUSCA_CONCILIA_TRANSABBC Erro ao efetuar download dos arquivos: ' || SQLERRM
                                  ,pr_dstiplog   => 'E'
                                  ,pr_cdprograma => vr_jobname);
        ROLLBACK;
    END;

  END pc_busca_concilia_transabbc;

  -- Grava as tarifas por canal nos parametros do sistema
  PROCEDURE pc_grava_tarifas_por_canal (pr_caixa     IN     VARCHAR2
                                       ,pr_internet  IN     VARCHAR2
                                       ,pr_taa       IN     VARCHAR2
                                       ,pr_xmllog    IN     VARCHAR2       --> XML com informac?es de LOG
                                       ,pr_cdcritic OUT     PLS_INTEGER    --> Codigo da critica
                                       ,pr_dscritic OUT     VARCHAR2       --> Descricao da critica
                                       ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT     VARCHAR2       --> Nome do campo com erro
                                       ,pr_des_erro OUT     VARCHAR2) IS   --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_grava_tarifas_por_canal
     Sistema : Conciliacoes diarias e mensais.
     Sigla   : CRED
     Autor   : Lucas Afonso Lombardi Moreira
     Data    : Setembro/15.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que chamado.

     Objetivo  : Gravar as tarifas por canal nos parametros do sistema.

     Observacao: -----

     Alteracoes:
     ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_dscritic VARCHAR2(1000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis extraídas do log
      vr_cdcooper INTEGER := 0;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);

    BEGIN
      
      CECRED.GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                                     ,pr_cdcooper => vr_cdcooper
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_nmeacao  => vr_nmeacao
                                     ,pr_cdagenci => vr_cdagenci
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_idorigem => vr_idorigem
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_dscritic => vr_dscritic);
                                     
      -- Tenta inserir tarifa de caixa
      BEGIN
        INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                     VALUES ('CRED', 0, 'DPVAT_SICREDI_TRF_CAIXA', 'Tarifa por canal Caixa', pr_caixa);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          UPDATE crapprm
             SET dsvlrprm = pr_caixa
           WHERE cdacesso = 'DPVAT_SICREDI_TRF_CAIXA';
      END;
      
      -- Tenta inserir tarifa de internet
      BEGIN
        INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                     VALUES ('CRED', 0, 'DPVAT_SICREDI_TRF_INET', 'Tarifa por canal Internet', pr_internet);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          UPDATE crapprm
             SET dsvlrprm = pr_internet
           WHERE cdacesso = 'DPVAT_SICREDI_TRF_INET';
      END;
      
      -- Tenta inserir tarifa de tta
      BEGIN
        INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                     VALUES ('CRED', 0, 'DPVAT_SICREDI_TRF_TAA', 'Tarifa por canal TAA', pr_taa);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          UPDATE crapprm
             SET dsvlrprm = pr_taa
           WHERE cdacesso = 'DPVAT_SICREDI_TRF_TAA';
      END;
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      
      gene0007.pc_insere_tag(pr_retxml, 'Dados', 0, 'Sucesso', 'As tarifas foram gravadas com sucesso!', vr_dscritic);
      
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na busca das tarifas: ' || SQLERRM;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_tarifas_por_canal;
  
  -- Busca as tarifas por canal nos parametros do sistema.
  PROCEDURE pc_busca_tarifas_por_canal (pr_xmllog    IN     VARCHAR2       --> XML com informac?es de LOG
                                       ,pr_cdcritic OUT     PLS_INTEGER    --> Codigo da critica
                                       ,pr_dscritic OUT     VARCHAR2       --> Descricao da critica
                                       ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT     VARCHAR2       --> Nome do campo com erro
                                       ,pr_des_erro OUT     VARCHAR2) IS   --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_carrega_tarifas_por_canal
     Sistema : Conciliacoes diarias e mensais.
     Sigla   : CRED
     Autor   : Lucas Afonso Lombardi Moreira
     Data    : Setembro/15.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que chamado.

     Objetivo  : Buscar as tarifas por canal nos parametros do sistema.

     Observacao: -----

     Alteracoes:
     ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_dscritic VARCHAR2(1000);
      
      vr_caixa    VARCHAR2(6);
      vr_internet VARCHAR2(6);
      vr_taa      VARCHAR2(6);
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis extraídas do log
      vr_cdcooper INTEGER := 0;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);

    BEGIN
      
      CECRED.GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                                     ,pr_cdcooper => vr_cdcooper
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_nmeacao  => vr_nmeacao
                                     ,pr_cdagenci => vr_cdagenci
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_idorigem => vr_idorigem
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_dscritic => vr_dscritic);
                                     
      vr_caixa := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                           ,pr_cdcooper => '0'
                                           ,pr_cdacesso => 'DPVAT_SICREDI_TRF_CAIXA');
      
      vr_internet := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'DPVAT_SICREDI_TRF_INET');
      
      vr_taa := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                         ,pr_cdcooper => '0'
                                         ,pr_cdacesso => 'DPVAT_SICREDI_TRF_TAA');
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      
      gene0007.pc_insere_tag(pr_retxml, 'Dados', 0, 'Caixa', vr_caixa, vr_dscritic);
      gene0007.pc_insere_tag(pr_retxml, 'Dados', 0, 'Internet', vr_internet, vr_dscritic);
      gene0007.pc_insere_tag(pr_retxml, 'Dados', 0, 'Taa', vr_taa, vr_dscritic);
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na busca das tarifas: ' || SQLERRM;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_tarifas_por_canal;

  -- Busca os custos bilhete por exercício.
  PROCEDURE pc_busca_custo_bilhete_exe (pr_xmllog    IN     VARCHAR2       --> XML com informac?es de LOG
                                       ,pr_cdcritic OUT     PLS_INTEGER    --> Codigo da critica
                                       ,pr_dscritic OUT     VARCHAR2       --> Descricao da critica
                                       ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT     VARCHAR2       --> Nome do campo com erro
                                       ,pr_des_erro OUT     VARCHAR2) IS   --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_busca_custo_bilhete_exe
     Sistema : Conciliacoes diarias e mensais.
     Sigla   : CRED
     Autor   : Lucas Afonso Lombardi Moreira
     Data    : Setembro/15.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que chamado.

     Objetivo  : Buscar os custos bilhete por exercicio nos parametros do sistema.

     Observacao: -----

     Alteracoes:
     ..............................................................................*/

    DECLARE
      -- CURSORES --
       
      CURSOR cr_crapprm IS
      SELECT SUBSTR(cdacesso,21,4) exercicio
            ,SUBSTR(dsvlrprm,1,6) integral
            ,SUBSTR(dsvlrprm,7,6) parcelado
        FROM crapprm
        WHERE cdacesso LIKE 'DPVAT_SICREDI_CSTBIL%'
         AND cdcooper = 0
         AND nmsistem = 'CRED'
        ORDER BY cdacesso DESC;
      
      -- Variável de críticas
      vr_dscritic VARCHAR2(1000);
      
      vr_xml      VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis extraídas do log
      vr_cdcooper INTEGER := 0;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);

    BEGIN
      
      CECRED.GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                                     ,pr_cdcooper => vr_cdcooper
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_nmeacao  => vr_nmeacao
                                     ,pr_cdagenci => vr_cdagenci
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_idorigem => vr_idorigem
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_dscritic => vr_dscritic);
                               
      vr_xml := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
      
      vr_xml := vr_xml || '<Dados>';
      
      FOR rw_crapprm IN cr_crapprm LOOP
        
        vr_xml := vr_xml || 
                  '<reg>' ||
                    '<exercicio>' || rw_crapprm.exercicio || '</exercicio>' ||
                    '<integral>'  || rw_crapprm.integral || '</integral>' ||
                    '<parcelado>' || rw_crapprm.parcelado || '</parcelado>' ||
                  '</reg>';
        
      END LOOP;
      
      vr_xml := vr_xml || '</Dados>';
      
      -- Cria XML
      pr_retxml := XMLType.createXML(vr_xml);
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na busca dos custos bilhetes: ' || SQLERRM;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_custo_bilhete_exe;
  
  -- Exclui custo bilhete por exercício.
  PROCEDURE pc_exclui_custo_bilhete_exe (pr_exercicio IN     VARCHAR2
                                        ,pr_xmllog    IN     VARCHAR2       --> XML com informac?es de LOG
                                        ,pr_cdcritic OUT     PLS_INTEGER    --> Codigo da critica
                                        ,pr_dscritic OUT     VARCHAR2       --> Descricao da critica
                                        ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT     VARCHAR2       --> Nome do campo com erro
                                        ,pr_des_erro OUT     VARCHAR2) IS   --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_exclui_custo_bilhete_exe
     Sistema : Conciliacoes diarias e mensais.
     Sigla   : CRED
     Autor   : Lucas Afonso Lombardi Moreira
     Data    : Setembro/15.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que chamado.

     Objetivo  : Exclui o custo bilhete por exercicio nos parametros do sistema.

     Observacao: -----

     Alteracoes:
     ..............................................................................*/

    DECLARE
      -- Variável de críticas
      vr_dscritic VARCHAR2(1000);
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis extraídas do log
      vr_cdcooper INTEGER := 0;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);

    BEGIN
      
      CECRED.GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                                     ,pr_cdcooper => vr_cdcooper
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_nmeacao  => vr_nmeacao
                                     ,pr_cdagenci => vr_cdagenci
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_idorigem => vr_idorigem
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_dscritic => vr_dscritic);
      BEGIN
        DELETE FROM crapprm 
         WHERE cdcooper = 0
           AND nmsistem = 'CRED'
           AND cdacesso = 'DPVAT_SICREDI_CSTBIL' || pr_exercicio;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro geral na busca das tarifas: ' || SQLERRM;
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
      END;
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      
      gene0007.pc_insere_tag(pr_retxml, 'Dados', 0, 'Sucesso', 'O custo bilhete foi excluido com sucesso!', vr_dscritic);
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na busca dos custos bilhetes: ' || SQLERRM;
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_exclui_custo_bilhete_exe;
  
  -- Insere ou Atualiza custo bilhete por exercício.
  PROCEDURE pc_grava_custo_bilhete_exe (pr_exercicio IN     VARCHAR2
                                       ,pr_integral  IN     VARCHAR2
                                       ,pr_parcelado IN     VARCHAR2
                                       ,pr_ehnovo    IN     VARCHAR2
                                       ,pr_xmllog    IN     VARCHAR2       --> XML com informac?es de LOG
                                       ,pr_cdcritic OUT     PLS_INTEGER    --> Codigo da critica
                                       ,pr_dscritic OUT     VARCHAR2       --> Descricao da critica
                                       ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT     VARCHAR2       --> Nome do campo com erro
                                       ,pr_des_erro OUT     VARCHAR2) IS   --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_grava_custo_bilhete_exe
     Sistema : Conciliacoes diarias e mensais.
     Sigla   : CRED
     Autor   : Lucas Afonso Lombardi Moreira
     Data    : Setembro/15.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que chamado.

     Objetivo  : Insere ou Atualiza custo bilhete por exercício.

     Observacao: -----

     Alteracoes:
     ..............................................................................*/

    DECLARE
      -- Variável de críticas
      vr_dscritic VARCHAR2(1000);
      
      vr_msg_sucesso VARCHAR2(100);
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis extraídas do log
      vr_cdcooper INTEGER := 0;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);

    BEGIN
      
      CECRED.GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                                     ,pr_cdcooper => vr_cdcooper
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_nmeacao  => vr_nmeacao
                                     ,pr_cdagenci => vr_cdagenci
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_idorigem => vr_idorigem
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_dscritic => vr_dscritic);
      
      IF upper(pr_ehnovo) = 'S' THEN
        vr_msg_sucesso := 'O custo bilhete foi inserido com sucesso!';
        -- Insere Custo Bilhete por Exercicio
        BEGIN
          INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                       VALUES ('CRED', 0, 'DPVAT_SICREDI_CSTBIL' || pr_exercicio, 'Custo Bilhete Por Exercício De ' || pr_exercicio, lpad(nvl(pr_integral,0),6,'0') || lpad(nvl(pr_parcelado,0),6,'0'));
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            pr_dscritic := 'Exercicio ja cadastrado!';
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><MSGERRO>' || pr_dscritic || '</MSGERRO></Root>');
            ROLLBACK;
          WHEN OTHERS THEN
            pr_dscritic := 'Erro geral na busca dos custos bilhetes: ' || SQLERRM;
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><MSGERRO>' || pr_dscritic || '</MSGERRO></Root>');
            ROLLBACK;
        END;
      ELSE
        vr_msg_sucesso := 'O custo bilhete foi inserido com sucesso!';
        -- Atualiza Custo Bilhete por Exercicio
        BEGIN
          UPDATE crapprm
             SET dsvlrprm = lpad(nvl(pr_integral,0),6,'0') || lpad(nvl(pr_parcelado,0),6,'0')
           WHERE cdacesso = 'DPVAT_SICREDI_CSTBIL' || pr_exercicio;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro geral na busca dos custos bilhetes: ' || SQLERRM;
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><MSGERRO>' || pr_dscritic || '</MSGERRO></Root>');
            ROLLBACK;
        END;
      END IF;
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      gene0007.pc_insere_tag(pr_retxml, 'Dados', 0, 'Sucesso', vr_msg_sucesso, vr_dscritic);
      
      -- Commita as alterações
      COMMIT;
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na busca dos custos bilhetes: ' || SQLERRM;
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><MSGERRO>' || pr_dscritic || '</MSGERRO></Root>');
        ROLLBACK;
    END;

  END pc_grava_custo_bilhete_exe;

  /* Procedure para gerar relatorio dos repasses DPVAT */
  PROCEDURE pc_relat_repasse_dpvat (pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da cooperativa
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data atual
                                   ,pr_cdprogra  IN crapprg.cdprogra%TYPE     --> Programa chamador
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo do erro
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao do erro
  BEGIN
    /* .............................................................................

       Programa: pc_relat_repasse_dpvat
       Sistema : Conciliacoes diarias e mensais
       Sigla   : CRED
       Autor   : Jaison
       Data    : Setembro/2015.                    Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: 
       Objetivo  : Gerar o relatorio para conciliacao dos repasses DPVAT Sicredi

       Alteracoes: 

    ..............................................................................*/

    DECLARE

      -- Busca as arrecadacoes da cooperativa
      CURSOR cr_arrecad(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtiniven IN DATE
                       ,pr_dtfimven IN DATE) IS
        SELECT lft.cdagenci
              ,lft.cdbarras
              ,lft.vllanmto
              ,lft.dtvencto
              ,SUBSTR(TO_CHAR(SYSDATE,'rrrr'),1,2) || SUBSTR(lft.cdbarras,41,2) nranoexe
              ,DECODE(SUBSTR(lft.cdbarras,40,1),1,'I','P') idintegr
          FROM craplft lft
              ,crapscn psc
         WHERE psc.dsoparre <> 'E'
           AND lft.cdcooper  = pr_cdcooper
           AND lft.cdempcon IN(psc.cdempcon,psc.cdempco2)
           AND TO_CHAR(lft.cdsegmto) = psc.cdsegmto   
           AND lft.dtvencto BETWEEN pr_dtiniven AND pr_dtfimven
           AND lft.insitfat  = 2     -- Arrecadada
           AND lft.tpfatura <> 2     -- Todas dif de 2-DARF ARF
           AND lft.cdhistor  = 1154  -- SICREDI
           AND psc.cdempres  = '85'  -- DPVAT
      ORDER BY lft.dtvencto;

      -- Tipo de Registro para resumo
      TYPE typ_reg_resumo IS
        RECORD (dt_total DATE
               ,vl_total NUMBER(25,2));

      -- Tipo de tabela de memoria para resumo
      TYPE typ_tab_resumo IS TABLE OF typ_reg_resumo INDEX BY PLS_INTEGER;

      -- Variavel para armazenar a tabela de memoria do resumo
      vr_tab_resumo typ_tab_resumo;

      -- Variaveis Locais
      vr_dtiniiof DATE;
      vr_dtfimiof DATE;
      vr_dtresumo DATE;
      vr_dt_inici DATE;
      vr_dt_final DATE;
      vr_dt_2_dia DATE;
      vr_dt_4_dia DATE;
      vr_txccdiof NUMBER;
      vr_vltarifa NUMBER;
      vr_vltari90 NUMBER;
      vr_vltari91 NUMBER;
      vr_vltaricx NUMBER;
      vr_vltariof NUMBER;
      vr_vlcusbil NUMBER;
      vr_vl_2_dia NUMBER;
      vr_vl_4_dia NUMBER;
      vr_dscusbil VARCHAR2(25);
      vr_nmdireto VARCHAR2(400);
      vr_index    INTEGER;
      vr_contador INTEGER := 0;

      -- Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- Variaveis de Excecao
      vr_exc_erro EXCEPTION;

      -- Variaveis do Clob
      vr_clobxml CLOB;
      vr_dstexto VARCHAR2(32767);

      -- Calcula os valores da arrecadacao
      PROCEDURE pc_calcula_valores(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                  ,pr_txccdiof  IN NUMBER
                                  ,pr_nranoexe  IN VARCHAR2
                                  ,pr_idintegr  IN VARCHAR2
                                  ,pr_vllanmto  IN craplft.vllanmto%TYPE
                                  ,pr_vltarifa  IN NUMBER
                                  ,pr_vlcusbil OUT NUMBER
                                  ,pr_vltariof OUT NUMBER
                                  ,pr_vl_2_dia OUT NUMBER
                                  ,pr_vl_4_dia OUT NUMBER) IS
      BEGIN

        DECLARE
          vr_dscusbil VARCHAR2(25);

        BEGIN
          -- Parametro de custo de bilhete
          vr_dscusbil := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => pr_cdcooper
                                                  ,pr_cdacesso => 'DPVAT_SICREDI_CSTBIL' || pr_nranoexe);
          -- Custo de bilhete
          IF pr_idintegr = 'I' THEN
            pr_vlcusbil := NVL(TO_NUMBER(SUBSTR(vr_dscusbil,1,6),'FM000D00'),0);
          ELSE
            pr_vlcusbil := NVL(TO_NUMBER(SUBSTR(vr_dscusbil,7,6),'FM000D00'),0);
          END IF;
          
          -- Valor de IOF
          pr_vltariof := ROUND(pr_vllanmto * pr_txccdiof,2);

          -- Repasse 2o dia util
          pr_vl_2_dia := (pr_vllanmto - pr_vlcusbil - pr_vltariof) * 0.5;

          -- Repasse 4o dia util
          pr_vl_4_dia := pr_vllanmto - pr_vltarifa - pr_vltariof - ROUND(pr_vl_2_dia,2);
        END;

      END pc_calcula_valores;

    BEGIN
      
      -- Inicializar variaveis
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      
      -- Limpa a PLTABLE
      vr_tab_resumo.DELETE;

      -- Busca informacoes de IOF
      GENE0005.pc_busca_iof (pr_cdcooper  => pr_cdcooper
                            ,pr_dtmvtolt  => pr_dtmvtolt
                            ,pr_dtiniiof  => vr_dtiniiof
                            ,pr_dtfimiof  => vr_dtfimiof
                            ,pr_txccdiof  => vr_txccdiof
                            ,pr_cdcritic  => vr_cdcritic
                            ,pr_dscritic  => vr_dscritic);

      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_erro;
      END IF;

      -- Tarifa Internet
      vr_vltari90 := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'DPVAT_SICREDI_TRF_INET');
      -- Tarifa TAA
      vr_vltari91 := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'DPVAT_SICREDI_TRF_TAA');
      -- Tarifa Caixa
      vr_vltaricx := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'DPVAT_SICREDI_TRF_CAIXA');

      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

      -- Escrever no arquivo XML
      GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
        '<?xml version="1.0" encoding="UTF-8"?><raiz>');

      -- Listagem de arrecadacoes
      FOR rw_arrecad IN cr_arrecad(pr_cdcooper => pr_cdcooper
                                  ,pr_dtiniven => pr_dtmvtolt
                                  ,pr_dtfimven => pr_dtmvtolt) LOOP

        IF rw_arrecad.cdagenci = 90 THEN -- Tarifa Internet
          vr_vltarifa := vr_vltari90;
        ELSIF rw_arrecad.cdagenci = 91 THEN -- Tarifa TAA
          vr_vltarifa := vr_vltari91;
        ELSE -- Tarifa Caixa
          vr_vltarifa := vr_vltaricx;
        END IF;

        -- Processa os calculos
        pc_calcula_valores(pr_cdcooper => pr_cdcooper
                          ,pr_txccdiof => vr_txccdiof
                          ,pr_nranoexe => rw_arrecad.nranoexe
                          ,pr_idintegr => rw_arrecad.idintegr
                          ,pr_vllanmto => rw_arrecad.vllanmto
                          ,pr_vltarifa => vr_vltarifa
                          ,pr_vlcusbil => vr_vlcusbil
                          ,pr_vltariof => vr_vltariof
                          ,pr_vl_2_dia => vr_vl_2_dia
                          ,pr_vl_4_dia => vr_vl_4_dia);

        -- Dados do Repasse
        GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
          '<dados>'||
          '  <cdagenci>'|| LPAD(rw_arrecad.cdagenci,3,0) ||'</cdagenci>'||
          '  <cdbarras>'|| rw_arrecad.cdbarras ||'</cdbarras>'||
          '  <vllanmto>'|| TO_CHAR(rw_arrecad.vllanmto,'FM999999999990D00MI') ||'</vllanmto>'||
          '  <vltarifa>'|| TO_CHAR(vr_vltarifa,'FM9999999990D00') ||'</vltarifa>'||
          '  <vlcusbil>'|| TO_CHAR(vr_vlcusbil,'FM9999999990D00') ||'</vlcusbil>'||
          '  <vltariof>'|| TO_CHAR(vr_vltariof,'FM9999999990D00') ||'</vltariof>'||
          '  <vl_2_dia>'|| TO_CHAR(vr_vl_2_dia,'FM9999999990D00') ||'</vl_2_dia>'||
          '  <vl_4_dia>'|| TO_CHAR(vr_vl_4_dia,'FM9999999990D00') ||'</vl_4_dia>'||
          '</dados>');

      END LOOP; -- cr_arrecad

      -- Monta datas do resumo
      vr_dtresumo := pr_dtmvtolt - 1;
      FOR vr_ind in 1..5 LOOP
        vr_dtresumo := vr_dtresumo + 1;
        vr_dtresumo := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => vr_dtresumo);
        -- Inicializa a PLTABLE
        vr_tab_resumo(TO_CHAR(vr_dtresumo,'YYYYMMDD')).dt_total := vr_dtresumo;
        vr_tab_resumo(TO_CHAR(vr_dtresumo,'YYYYMMDD')).vl_total := 0;

        -- Se nao foram carregadas datas da pesquisa
        IF vr_dt_inici IS NULL THEN
          vr_dt_inici := vr_dtresumo;
          vr_dt_final := vr_dtresumo;
          FOR vr_ind2 in 1..4 LOOP
            vr_dt_inici := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                      ,pr_dtmvtolt => vr_dt_inici - 1
                                                      ,pr_tipo     => 'A');
          END LOOP;
        END IF;
      END LOOP;
      
      -- Listagem de arrecadacoes do resumo
      FOR rw_arrecad IN cr_arrecad(pr_cdcooper => pr_cdcooper
                                  ,pr_dtiniven => vr_dt_inici
                                  ,pr_dtfimven => vr_dt_final) LOOP

        IF rw_arrecad.cdagenci = 90 THEN -- Tarifa Internet
          vr_vltarifa := vr_vltari90;
        ELSIF rw_arrecad.cdagenci = 91 THEN -- Tarifa TAA
          vr_vltarifa := vr_vltari91;
        ELSE -- Tarifa Caixa
          vr_vltarifa := vr_vltaricx;
        END IF;

        -- Processa os calculos
        pc_calcula_valores(pr_cdcooper => pr_cdcooper
                          ,pr_txccdiof => vr_txccdiof
                          ,pr_nranoexe => rw_arrecad.nranoexe
                          ,pr_idintegr => rw_arrecad.idintegr
                          ,pr_vllanmto => rw_arrecad.vllanmto
                          ,pr_vltarifa => vr_vltarifa
                          ,pr_vlcusbil => vr_vlcusbil
                          ,pr_vltariof => vr_vltariof
                          ,pr_vl_2_dia => vr_vl_2_dia
                          ,pr_vl_4_dia => vr_vl_4_dia);

        -- Calcula 2o dia util referente a data vencimento
        vr_dt_2_dia := rw_arrecad.dtvencto;
        FOR vr_ind2 in 1..2 LOOP
          vr_dt_2_dia := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => vr_dt_2_dia + 1);
        END LOOP;

        -- Calcula 4o dia util referente a data vencimento
        vr_dt_4_dia := vr_dt_2_dia;
        FOR vr_ind2 in 1..2 LOOP
          vr_dt_4_dia := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => vr_dt_4_dia + 1);
        END LOOP;

        -- Se existir na PLTABLE soma
        vr_index:= TO_CHAR(vr_dt_2_dia,'YYYYMMDD');
        IF vr_tab_resumo.EXISTS(vr_index) THEN
          -- Somar o valor do vetor com o valor do 2o dia util
          vr_tab_resumo(vr_index).vl_total := vr_tab_resumo(vr_index).vl_total + NVL(vr_vl_2_dia,0);
        END IF;

        -- Se existir na PLTABLE soma
        vr_index:= TO_CHAR(vr_dt_4_dia,'YYYYMMDD');
        IF vr_tab_resumo.EXISTS(vr_index) THEN
          -- Somar o valor do vetor com o valor do 4o dia util
          vr_tab_resumo(vr_index).vl_total := vr_tab_resumo(vr_index).vl_total + NVL(vr_vl_4_dia,0);
        END IF;

      END LOOP; -- cr_arrecad
      
      -- Abre TAG de resumo
      GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'<resumo>');

      vr_index := vr_tab_resumo.FIRST(); -- Posiciona no primeiro registro
      WHILE vr_index IS NOT NULL LOOP
        -- Dados do resumo
        GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
        '  <dt_tot_'|| vr_contador ||'>'|| TO_CHAR(vr_tab_resumo(vr_index).dt_total,'DD/MM/YYYY') ||'</dt_tot_'|| vr_contador ||'>'||
        '  <vl_tot_'|| vr_contador ||'>'|| TO_CHAR(NVL(vr_tab_resumo(vr_index).vl_total,0),'FM999999999990D00') ||'</vl_tot_'|| vr_contador ||'>');
         vr_contador := vr_contador + 1; -- Contador
         vr_index := vr_tab_resumo.NEXT(vr_index); -- Proximo registro
      END LOOP;

      -- Fecha TAG resumo
      GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</resumo>');

      -- Finaliza TAG Raiz
      GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</raiz>',TRUE);

      -- Busca o diretorio padrao do sistema
      vr_nmdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

      -- Efetuar solicitacao de geracao de relatorio
      GENE0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,
                                  pr_cdprogra  => pr_cdprogra,
                                  pr_dtmvtolt  => pr_dtmvtolt,
                                  pr_dsxml     => vr_clobxml,
                                  pr_dsxmlnode => '/raiz',
                                  pr_dsjasper  => 'crrl709.jasper',
                                  pr_dsparams  => NULL,
                                  pr_dsarqsaid => vr_nmdireto || '/crrl709.lst',
                                  pr_flg_gerar => 'S',
                                  pr_qtcoluna  => 132,
                                  pr_flg_impri => 'S',
                                  pr_nmformul  => '132col',
                                  pr_nrcopias  => 1,
                                  pr_des_erro  => vr_dscritic);

      -- Fechar Clob e Liberar Memoria
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);

      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      COMMIT;

    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CONV0001.pc_relat_repasse_dpvat. ' || SQLERRM;
    END;

  END pc_relat_repasse_dpvat;

  PROCEDURE pc_grava_motv_excl_debaut (pr_cdcooper IN  tbconv_motivo_excl_autori.cdcooper%TYPE  
																			,pr_nrdconta IN  tbconv_motivo_excl_autori.nrdconta%TYPE  
																			,pr_cdhistor IN  tbconv_motivo_excl_autori.cdhistor%TYPE  
																			,pr_cdrefere IN  tbconv_motivo_excl_autori.cdreferencia%TYPE  
																			,pr_idmotivo IN  tbconv_motivo_excl_autori.idmotivo%TYPE  
																			,pr_cdorigem IN  tbconv_motivo_excl_autori.cdorigem%TYPE  
																			,pr_cdempcon IN  tbconv_motivo_excl_autori.cdempcon%TYPE  
																			,pr_cdsegmto IN  tbconv_motivo_excl_autori.cdsegmto%TYPE  
																			,pr_cdcritic OUT INTEGER               -- Código do erro
																			,pr_dscritic OUT VARCHAR2) IS          -- Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_grava_motv_excl_debaut
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : Lucas Lunelli
  --  Data     : 09/05/2016               Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Gravar registro de ligação entre exclusão de debaut e motivo
  -- Alteracoes:
	--
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      vr_exc_erro EXCEPTION;
			
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta
      	 FROM  crapass
         WHERE crapass.cdcooper = pr_cdcooper
         AND   crapass.nrdconta = pr_nrdconta;
			rw_crapass cr_crapass%ROWTYPE;
				 
			CURSOR cr_crapatr (pr_cdcooper IN crapatr.cdcooper%TYPE
												,pr_nrdconta IN crapatr.nrdconta%TYPE
												,pr_cdhistor IN crapatr.cdhistor%TYPE
												,pr_cdrefere IN crapatr.cdrefere%TYPE) IS
			SELECT crapatr.cdcooper
				 FROM crapatr
				 WHERE crapatr.cdcooper = pr_cdcooper
				 AND   crapatr.nrdconta = pr_nrdconta
				 AND   crapatr.cdhistor = pr_cdhistor
				 AND   crapatr.cdrefere = pr_cdrefere;
			rw_crapatr cr_crapatr%ROWTYPE;
			
			CURSOR cr_tbgen_motivo(pr_idmotivo  IN tbgen_motivo.idmotivo%TYPE) IS
			SELECT mot.idmotivo
				 FROM tbgen_motivo mot
				 WHERE mot.cdproduto = 29 /* DEBAUT */
				   AND mot.idmotivo  = pr_idmotivo;
      rw_tbgen_motivo cr_tbgen_motivo%ROWTYPE;

    BEGIN
			
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      
      IF cr_crapcop%NOTFOUND THEN
      
        CLOSE cr_crapcop;
        pr_cdcritic:= 0;
        pr_dscritic:= 'Registro de cooperativa origem nao encontrado.';     
        RAISE vr_exc_erro;
				
      END IF;      
      CLOSE cr_crapcop;
						
			OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      
      IF cr_crapass%NOTFOUND THEN
				
        CLOSE cr_crapass;
        pr_cdcritic:= 0;
        pr_dscritic:= 'Associado nao cadastrado.';				
        RAISE vr_exc_erro;
				
      END IF;
      CLOSE cr_crapass;
						
			OPEN cr_crapatr (pr_cdcooper => pr_cdcooper
											,pr_nrdconta => pr_nrdconta
											,pr_cdhistor => pr_cdhistor
											,pr_cdrefere => pr_cdrefere);
      FETCH cr_crapatr INTO rw_crapatr;
			
			IF cr_crapatr%NOTFOUND THEN
				
        CLOSE cr_crapatr;
        pr_cdcritic:= 0;
        pr_dscritic:= 'Registro de Autorizacao nao encontrado.';				
        RAISE vr_exc_erro;
				
      END IF;
      CLOSE cr_crapatr;
			
			OPEN cr_tbgen_motivo(pr_idmotivo => pr_idmotivo);
      FETCH cr_tbgen_motivo INTO rw_tbgen_motivo;

      IF cr_tbgen_motivo%NOTFOUND THEN
        
				CLOSE cr_tbgen_motivo;								
				vr_dscritic := 'Registros de Motivo nao encontrado (DEBAUT).';
				RAISE vr_exc_erro;
				
      END IF;			
			CLOSE cr_tbgen_motivo;
			
      -- Insere o registro
			BEGIN
				INSERT INTO tbconv_motivo_excl_autori
							 (tbconv_motivo_excl_autori.cdcooper
               ,tbconv_motivo_excl_autori.nrdconta
               ,tbconv_motivo_excl_autori.cdhistor
               ,tbconv_motivo_excl_autori.cdreferencia
               ,tbconv_motivo_excl_autori.dhexclusao 								
               ,tbconv_motivo_excl_autori.idmotivo
               ,tbconv_motivo_excl_autori.cdorigem
               ,tbconv_motivo_excl_autori.cdempcon
               ,tbconv_motivo_excl_autori.cdsegmto)
				VALUES (pr_cdcooper
							 ,pr_nrdconta
							 ,pr_cdhistor
							 ,pr_cdrefere
							 ,SYSDATE -- GENE0002.fn_busca_time
							 ,pr_idmotivo
							 ,pr_cdorigem
							 ,pr_cdempcon
							 ,pr_cdsegmto);
			EXCEPTION
				WHEN OTHERS THEN
					vr_cdcritic:= 0;
					vr_dscritic:= 'Erro ao registro de motivo para exclusao (DEBAUT). '||sqlerrm;
					--Levantar Excecao
					RAISE vr_exc_erro;
			END;						
			
    EXCEPTION
      WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CONV0001.pc_grava_motv_excl_debaut. ' || sqlerrm;
    END;
  END pc_grava_motv_excl_debaut;

  -- Criar registro de controle na gncotnr e pular o sequencial na gnconve                  
  PROCEDURE pc_pula_seq_gt0001 (pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooeprativa
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                               ,pr_cdconven IN gnconve.cdconven%TYPE --> Codigo do convenio
                               ,pr_tpdcontr IN gncontr.tpdcontr%TYPE --> Tipo de Controle
                               ,pr_nrseqant IN gncontr.nrsequen%TYPE --> Seq. Anterior
                               ,pr_nrsequen IN gncontr.nrsequen%TYPE --> Seq. Alterada
                               ,pr_nmarqint IN gnconve.nmarqint%TYPE --> Nome do arquivo
                               ,pr_cdcritic OUT NUMBER               --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da critica

  /*-------------------------------------------------------------------------------------------------
  
    Programa : pc_pula_seq_gt0001
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Lucas Ranghetti
    Data     : 13/09/2016               Ultima atualizacao: 
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Criar registro de controle na gncotnr e pular o sequencial na gnconve
   Alteracoes:
	
  --------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      vr_exc_erro EXCEPTION;      
      
      vr_nrseqint NUMBER;
      
      -- Verificar se registro de controle ja está criado
      CURSOR cr_gncontr(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_cdconven gnconve.cdconven%TYPE
                       ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                       ,pr_nrsequen gncontr.nrsequen%TYPE
                       ,pr_tpdcontr gncontr.tpdcontr%TYPE) IS
          SELECT 1
            FROM gncontr ntr
           WHERE ntr.cdcooper = pr_cdcooper
             AND ntr.cdconven = pr_cdconven
             AND ntr.dtmvtolt = pr_dtmvtolt
             AND ntr.tpdcontr = pr_tpdcontr
             AND ntr.nrsequen = pr_nrsequen;
        rw_gncontr cr_gncontr%ROWTYPE;
        
      -- Busca dos dados dos convenios 
      CURSOR cr_gncvcop IS
        SELECT cop.cdcooper
              ,cop.cdconven
          FROM gncvcop cop
         WHERE cop.cdconven = pr_cdconven;
      
    BEGIN
      -- o ultimo sequencial, não deve criar na tabela de controle(gncontr)
      vr_nrseqint := pr_nrsequen - 1;
      
      -- Loop dos sequenciais que precisaremos criar na gncontr
      FOR sequencial IN pr_nrseqant..vr_nrseqint LOOP        
        
        FOR rw_gncvcop IN cr_gncvcop LOOP
        
          -- Acessa os dados sobre os controles de execucoes
          OPEN cr_gncontr(rw_gncvcop.cdcooper,
                          rw_gncvcop.cdconven, 
                          pr_dtmvtolt, 
                          sequencial,
                          pr_tpdcontr);
          FETCH cr_gncontr INTO rw_gncontr;
          -- Se nao encontrar dados efetua a insercao
          IF cr_gncontr%NOTFOUND THEN
            -- Insere no controle de execucoes
            BEGIN
              INSERT INTO gncontr
                (cdcooper,
                 tpdcontr,
                 cdconven,
                 dtmvtolt,
                 nrsequen,
                 flgmigra,
                 qtdoctos,
                 vldoctos,
                 dtcredit,
                 nmarquiv,
                 vltarifa,
                 vlapagar)
               VALUES
                (rw_gncvcop.cdcooper,
                 pr_tpdcontr,
                 rw_gncvcop.cdconven,
                 pr_dtmvtolt,
                 sequencial,
                 0,
                 0,
                 0,
                 pr_dtmvtolt,
                 pr_nmarqint,
                 0,
                 0);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir gncontr: ' ||SQLERRM;
                RAISE vr_exc_erro;
            END;
          END IF;
          -- Caso o cursor esteja aberto
          IF cr_gncontr%ISOPEN THEN
            CLOSE cr_gncontr;
          END IF;
          
        END LOOP;
      END LOOP;
      
      COMMIT;
    EXCEPTION
      WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CONV0001.pc_pula_seq_gt0001. ' || sqlerrm;
    END;
  END pc_pula_seq_gt0001;

  PROCEDURE pc_retorna_referencia_conv (pr_cdconven IN gnconve.cdconven%TYPE --> Codigo do convenio
                                       ,pr_cdhistor IN INTEGER               --> Historico do convenio
                                       ,pr_cdrefere IN VARCHAR2              --> Referencia
                                       ,pr_nrrefere OUT VARCHAR2             --> Referencia formatada
                                       ,pr_qtdigito OUT INTEGER              --> Qtd. maxima de digitos
                                       ,pr_cdcritic OUT NUMBER               --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2) IS
  /*-------------------------------------------------------------------------------------------------
  
    Programa : pc_retorna_referencia_conv
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Lucas Ranghetti
    Data     : 16/10/2017               Ultima atualizacao: 
  
   Dados referentes ao programa:
  
   Frequencia: Sempre que for chamado
   Objetivo  : Retornar a referencia do convenio ja formatada com 25 posições
   Alteracoes:
	
  --------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      vr_qtdigito INTEGER;
      -- tipo preenchimento = 0 - Nao preenche com zeros / 
      -- 1 - Preenche com zeros a esquerda / 2 - Preenche com zeros a direita
      vr_tppreenc INTEGER; 
      vr_nrrefere VARCHAR2(25);
      vr_cdconven INTEGER;
      
      CURSOR cr_crapprm IS
       SELECT prm.dsvlrprm            
         FROM crapprm prm
        WHERE prm.cdcooper = 0
          AND upper(prm.nmsistem) = 'CRED' 
          AND upper(prm.cdacesso) = 'FORMATA_REF_CONVEN_'||vr_cdconven;
      rw_crapprm cr_crapprm%ROWTYPE;
      
      --  Busca convenio
      CURSOR cr_gnconve IS
        SELECT gnconve.cdconven
          FROM gnconve
         WHERE gnconve.cdhisdeb = pr_cdhistor;   
      rw_gnconve cr_gnconve%ROWTYPE;
      
    BEGIN
    
      IF pr_cdconven = 0 AND pr_cdhistor <> 0 THEN
        OPEN cr_gnconve;
        FETCH cr_gnconve INTO rw_gnconve;
      
        IF cr_gnconve%FOUND THEN
          CLOSE cr_gnconve;
          vr_cdconven:= rw_gnconve.cdconven;
        ELSE
          CLOSE cr_gnconve;
        END IF;
      ELSE
        vr_cdconven:= pr_cdconven;
      END IF;
    
      OPEN cr_crapprm;
      FETCH cr_crapprm INTO rw_crapprm;
      
      IF cr_crapprm%FOUND THEN
        CLOSE cr_crapprm;
        -- Qtd de digitos a completar
        vr_qtdigito:= gene0002.fn_busca_entrada(1, rw_crapprm.dsvlrprm,';');
        -- Tipo de preenchimento
        vr_tppreenc:= gene0002.fn_busca_entrada(2, rw_crapprm.dsvlrprm,';');
      
        -- Nao preenche com zeros
        IF vr_tppreenc = 0 THEN
           vr_nrrefere:= pr_cdrefere;    
        ELSIF vr_tppreenc = 1 THEN -- 1 - Preenche com zeros a esquerda
          vr_nrrefere:= LPAD(pr_cdrefere,vr_qtdigito,'0');
        ELSIF vr_tppreenc = 2 THEN -- 2 - Preenche com zeros a direita
          vr_nrrefere:= RPAD(pr_cdrefere,vr_qtdigito,'0');           
        END IF;      
      ELSE
         CLOSE cr_crapprm;
        vr_nrrefere:= pr_cdrefere;
      END IF;
      
      -- completar com espaços até 25 posições
      pr_nrrefere:= RPAD(vr_nrrefere,25,' ');      
      -- Quantidade maxima de digitos aceitos para deb. aut.
      pr_qtdigito:= nvl(vr_qtdigito,0);

    EXCEPTION      
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina CONV0001.pc_retorna_referencia_conv - ' || sqlerrm;
    END;
  END pc_retorna_referencia_conv;

END CONV0001;
/
