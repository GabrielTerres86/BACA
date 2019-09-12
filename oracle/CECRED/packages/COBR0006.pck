CREATE OR REPLACE PACKAGE CECRED.COBR0006 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COBR0006
  --  Sistema  : Procedimentos para  gerais da cobranca
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Novembro/2015.                   Ultima atualizacao: 29/05/2016 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas referente a importacao de arquivos de cobrança
  --
  --  Alteracoes: 06/07/2016 - Ajuste para definir rotinas como publicas (Andrei - RKAM).
  --
  --              17/08/2016 - Ajuste para inclusao de campo na pltable typ_rec_crawaux (Andrei - RKAM).
  --
  --              28/12/2016 - Ajuste da validacao dos caracteres especiais e da definicao do registro de 
  --                           rejeitados (Rodrigo - 550849 / 583172)
  --
  --              29/12/2016 - P340 - Ajustes para leitura do Segmento y053 e envia a CIP (Ricardo Linhares).
  --
  --              02/02/2018 - Alterações referente ao PRJ352 - Nova solução de protesto
  -- 
  --	          16/05/2018 - Ajuste para que o insert do campo cdmensag nunca seja com o valor nulo.
  --                           Chamado INC0011898 - Gabriel (Mouts).
  --
  --	          29/05/2018 - Ajuste no comando que envia arquivos .LOG e .ERR para servidor ftp.
  --                           Chamado INC0015743 - Gabriel (Mouts).
  --
  --			  20/08/2018 - Foi incluido a validação do segmento Q
  --						   (Felipe - Mouts).
  --
  --              08/10/2018 - Incluido validação de UF para pretesto codigos 9 e 80 (SM_P352, Anderson-Alan, Supero)
  --    
  --              18/06/2018 - Alteração de código de motivo. Alcemir Jr./Roberto Holz  -  Mout´s(PRB0041653).

  ---------------------------------------------------------------------------------------------------------------
    
  --> type para armazenar arquivos a serem processados b1wgen0010tt.i/crawaux
  TYPE typ_rec_crawaux 
    IS RECORD (cdcooper  crapcop.cdcooper%TYPE,
               nmarquiv  VARCHAR2(500),
               nmarqori  VARCHAR2(500),
               nrsequen  INTEGER);
  TYPE typ_tab_crawaux IS TABLE OF typ_rec_crawaux
    INDEX BY PLS_INTEGER;

  --> type para armazenar as informacoes do header do arquivo
  TYPE typ_rec_header
    IS RECORD (nrremass  INTEGER,
               cdbancbb  crapcco.cddbanco%TYPE,
               cdagenci  crapcco.cdagenci%TYPE,
               cdbccxlt  crapcco.cdbccxlt%TYPE,
               nrdolote  crapcco.nrdolote%TYPE,
               cdhistor  crapcco.cdhistor%TYPE,
               nrdctabb  crapcco.nrdctabb%TYPE,
               cdbandoc  crapcco.cddbanco%TYPE,
               nrcnvcob  crapcco.nrconven%TYPE,
               flgutceb  crapcco.flgutceb%TYPE,
               flgregis  crapcco.flgregis%TYPE,
               flgpgdiv  crapceb.flgpgdiv%TYPE,
               flgregon  crapceb.flgregon%TYPE,               
               -- Dados que devem ser carregados da cooperativa
               cdbcoctl  crapcop.cdbcoctl%TYPE,
               cdagectl  crapcop.cdagectl%TYPE,
               -- Dados do cadastro de emissao de boletos
               flceeexp  crapceb.flceeexp%TYPE,
               -- Dados da conta que esta processando o arquivo
               inpessoa  crapass.inpessoa%TYPE,
               nrcpfcgc  crapass.nrcpfcgc%TYPE,
               flserasa  crapceb.flserasa%TYPE
               );

  --> type para armazenar as informacoes dos segmentos do arquivo
  TYPE typ_rec_cobranca
    IS RECORD (cdcooper  crapcob.cdcooper%TYPE,
               nrdconta  crapcob.nrdconta%TYPE,
               dtmvtolt  crapcob.dtmvtolt%TYPE,
               -- Dados da Cobranca
               nrdctabb  crapcob.nrdctabb%TYPE,
               cdbandoc  crapcob.cdbandoc%TYPE,
               nrcnvcob  crapcob.nrcnvcob%TYPE,
               flgregis  crapcob.flgregis%TYPE,
               nrremass  crapcob.nrremass%TYPE,
               inpagdiv  crapcob.inpagdiv%TYPE,
               -- Valores
               dtvencto  crapcob.dtvencto%TYPE,
               vltitulo  crapcob.vltitulo%TYPE,
               vldescto  crapcob.vldescto%TYPE,
               tpdescto  INTEGER,
               dtdescto  INTEGER,
               vlabatim  crapcob.vlabatim%TYPE,
               tpdmulta  crapcob.tpdmulta%TYPE,
               vldmulta  crapcob.vlrmulta%TYPE,
               tpdjuros  crapcob.tpjurmor%TYPE,
               vldjuros  crapcob.vljurdia%TYPE,
               vlminimo  crapcob.vlminimo%TYPE,
               -- Dados do Sacado
               nmdsacad  crapcob.nmdsacad%TYPE,
               dsendsac  crapcob.dsendsac%TYPE,
               nmbaisac  crapcob.nmbaisac%TYPE,
               nmcidsac  crapcob.nmcidsac%TYPE,
               cdufsaca  crapcob.cdufsaca%TYPE,
               nrcepsac  crapcob.nrcepsac%TYPE,
               cdtpinsc  crapcob.cdtpinsc%TYPE,
               nrinssac  crapcob.nrinssac%TYPE,
               -- Email e telefone do Sacado
               dsdemail  VARCHAR2(5000),
               nrcelsac  crapsab.nrcelsac%TYPE,
               -- Dados do Avalista
               nmdavali  crapcob.nmdavali%TYPE,
               cdtpinav  crapcob.cdtpinav%TYPE,
               nrinsava  crapcob.nrinsava%TYPE,
               -- Dados do Boleto
               dsnosnum  crapcob.nrnosnum%TYPE,
               nrbloque  crapcob.nrdocmto%TYPE,
               cdcartei  crapcob.cdcartei%TYPE,
               inemiten  crapcob.inemiten%TYPE,
               dsdoccop  crapcob.dsdoccop%TYPE,
               dsusoemp  crapcob.dsusoemp%TYPE,
               dsdinstr  crapcob.dsdinstr%TYPE,
               qtdiaprt  crapcob.qtdiaprt%TYPE,
               cdprotes  INTEGER,
               flgdprot  crapcob.flgdprot%TYPE,
               flgaceit  crapcob.flgaceit%TYPE,
               inemiexp  crapcob.inemiexp%TYPE,
               cddespec  crapcob.cddespec%TYPE,
               dtemscob  crapcob.dtretcob%TYPE,
               inenvcip  crapcob.inenvcip%TYPE,
			   insrvprt  crapcob.insrvprt%TYPE,
               -- Ocorrencia --> Utilizado em diversas linhas
               cdocorre  INTEGER,
               -- Identifica se foi rejeitado
               flgrejei BOOLEAN,
               instcodi INTEGER,
               instcodi2 INTEGER,
               serasa    INTEGER,
               flserasa crapcob.flserasa%TYPE,
               qtdianeg crapcob.qtdianeg%TYPE,
               inserasa crapcob.inserasa%TYPE,
               -- Indicadores de SMS
               inavisms crapcob.inavisms%TYPE,
               insmsant crapcob.insmsant%TYPE,
               insmsvct crapcob.insmsvct%TYPE,
               insmspos crapcob.insmspos%TYPE);

  --> type para armazenar as informacoes dos segmentos do arquivo
  TYPE typ_rec_instrucao
    IS RECORD (cdcooper  crapcob.cdcooper%TYPE,
               nrdconta  crapcob.nrdconta%TYPE,
               nrcnvcob  crapcob.nrcnvcob%TYPE,
               nrdocmto  crapcob.nrdocmto%TYPE,
               nrremass  crapcob.nrremass%TYPE,
               cdocorre  INTEGER,
               vltitulo  crapcob.vltitulo%TYPE,
               vldescto  crapcob.vldescto%TYPE,
               vlabatim  crapcob.vlabatim%TYPE,
               dtvencto  crapcob.dtvencto%TYPE,
               nrnosnum  crapcob.nrnosnum%TYPE,
               nrinssac  crapcob.nrinssac%TYPE,
               dsendsac  crapcob.dsendsac%TYPE,
               nmbaisac  crapcob.nmbaisac%TYPE,
               nrcepsac  crapcob.nrcepsac%TYPE,
               nmcidsac  crapcob.nmcidsac%TYPE,
               cdufsaca  crapcob.cdufsaca%TYPE,
               qtdiaprt  crapcob.qtdiaprt%TYPE,
               dsdoccop  crapcob.dsdoccop%TYPE,
               cdbandoc  crapcob.cdbandoc%TYPE,
               nrdctabb  crapcob.nrdctabb%TYPE,
               inemiten  crapcob.inemiten%TYPE,
               dtemscob  crapcob.dtretcob%TYPE,
               inavisms  crapcob.inavisms%TYPE,
               insmsant  crapcob.insmsant%TYPE,
               insmsvct  crapcob.insmsvct%TYPE,
               insmspos  crapcob.insmspos%TYPE,
               nrcelsac  crapsab.nrcelsac%TYPE);

  TYPE typ_tab_instrucao IS TABLE OF typ_rec_instrucao
    INDEX BY PLS_INTEGER;

  TYPE typ_rec_rejeitado 
    IS RECORD (cdcooper crapret.cdcooper%TYPE,
               nrdconta crapret.nrdconta%TYPE,
               nrcnvcob crapret.nrcnvcob%TYPE,
               dtmvtolt craprtc.dtmvtolt%TYPE,
               nrremrtc craprtc.nrremret%TYPE,
               nmarqrtc craprtc.nmarquiv%TYPE,
               dtaltera craprtc.dtaltera%TYPE,
               nrremcre crapcre.nrremret%TYPE,
               nmarqcre crapcre.nmarquiv%TYPE,
               cdoperad crapret.cdoperad%TYPE,
               nrseqreg crapret.nrseqreg%TYPE,
               cdocorre crapret.cdocorre%TYPE,
               cdmotivo crapret.cdmotivo%TYPE,
               vltitulo crapret.vltitulo%TYPE,
               cdbcorec crapret.cdbcorec%TYPE,
               cdagerec crapret.cdagerec%TYPE,
               dtocorre crapret.dtocorre%TYPE,
               nrnosnum crapret.nrnosnum%TYPE,
               dsdoccop crapret.dsdoccop%TYPE,
               nrremass crapret.nrremret%TYPE,
               dtvencto crapret.dtvencto%TYPE);
  TYPE typ_tab_rejeitado IS TABLE OF typ_rec_rejeitado
    INDEX BY PLS_INTEGER;
    
  TYPE typ_rejeita
    IS RECORD (tpcritic INTEGER
              ,nrlinseq VARCHAR2(10)
              ,cdseqcri INTEGER
              ,dscritic VARCHAR2(400) --(72)
              ,seqdetal VARCHAR2(400));
  TYPE typ_tab_rejeita IS TABLE OF typ_rejeita
    INDEX BY PLS_INTEGER;
    
  TYPE typ_crawrej
    IS RECORD (cdcooper crapcop.cdcooper%TYPE
              ,nrdconta crapass.nrdconta%TYPE
              ,nrdocmto crapcob.nrdocmto%TYPE
              ,dscritic VARCHAR2(400));
  TYPE typ_tab_crawrej IS TABLE OF typ_crawrej
    INDEX BY PLS_INTEGER;

  --> type para armazenar as informacoes dos segmentos do arquivo
  TYPE typ_rec_crapcob
    IS RECORD (cdcooper  crapcob.cdcooper%TYPE,
               dtmvtolt  crapcob.dtmvtolt%TYPE,
               incobran  crapcob.incobran%TYPE,
               nrdconta  crapcob.nrdconta%TYPE,
               nrdctabb  crapcob.nrdctabb%TYPE,
               cdbandoc  crapcob.cdbandoc%TYPE,
               nrdocmto  crapcob.nrdocmto%TYPE,
               nrcnvcob  crapcob.nrcnvcob%TYPE,
               dtretcob  crapcob.dtretcob%TYPE,
               dsdoccop  crapcob.dsdoccop%TYPE,
               vltitulo  crapcob.vltitulo%TYPE,
               vldescto  crapcob.vldescto%TYPE,
               cdmensag  crapcob.cdmensag%TYPE,
               dtvencto  crapcob.dtvencto%TYPE,
               cdcartei  crapcob.cdcartei%TYPE,
               cddespec  crapcob.cddespec%TYPE,
               cdtpinsc  crapcob.cdtpinsc%TYPE,
               nrinssac  crapcob.nrinssac%TYPE,
               nmdsacad  crapcob.nmdsacad%TYPE,
               dsendsac  crapcob.dsendsac%TYPE,
               nmbaisac  crapcob.nmbaisac%TYPE,
               nmcidsac  crapcob.nmcidsac%TYPE,
               cdufsaca  crapcob.cdufsaca%TYPE,
               nrcepsac  crapcob.nrcepsac%TYPE,
               nmdavali  crapcob.nmdavali%TYPE,
               nrinsava  crapcob.nrinsava%TYPE,
               cdtpinav  crapcob.cdtpinav%TYPE,
               dsdinstr  crapcob.dsdinstr%TYPE,
               dsusoemp  crapcob.dsusoemp%TYPE,
               nrremass  crapcob.nrremass%TYPE,
               flgregis  crapcob.flgregis%TYPE,
               cdimpcob  crapcob.cdimpcob%TYPE,
               flgimpre  crapcob.flgimpre%TYPE,
               nrnosnum  crapcob.nrnosnum%TYPE,
               dtdocmto  crapcob.dtdocmto%TYPE,
               tpjurmor  crapcob.tpjurmor%TYPE,
               vljurdia  crapcob.vljurdia%TYPE,
               tpdmulta  crapcob.tpdmulta%TYPE,
               vlrmulta  crapcob.vlrmulta%TYPE,
               vlminimo  crapcob.vlminimo%TYPE,
               inpagdiv  crapcob.inpagdiv%TYPE,
               inenvcip  crapcob.inenvcip%TYPE,
               inemiten  crapcob.inemiten%TYPE,
               flgdprot  crapcob.flgdprot%TYPE,
			   insrvprt  crapcob.insrvprt%TYPE,
               flgaceit  crapcob.flgaceit%TYPE,
               idseqttl  crapcob.idseqttl%TYPE,
               cdoperad  crapcob.cdoperad%TYPE,
               qtdiaprt  crapcob.qtdiaprt%TYPE,
               inemiexp  crapcob.inemiexp%TYPE,
               flserasa  crapcob.flserasa%TYPE,
               qtdianeg  crapcob.qtdianeg%TYPE,
               inserasa  crapcob.inserasa%TYPE,
               inavisms  crapcob.inavisms%TYPE,
               insmsant  crapcob.insmsant%TYPE,
               insmsvct  crapcob.insmsvct%TYPE,
    insmspos crapcob.insmspos%TYPE,
    vlabatim crapcob.vlabatim%TYPE);
  TYPE typ_tab_crapcob IS TABLE OF typ_rec_crapcob INDEX BY VARCHAR2(50);

  --> type para armazenar os dados do sacado do segmento Q
  TYPE typ_rec_sacado
    IS RECORD (cdcooper  crapsab.cdcooper%TYPE,
               nrdconta  crapsab.nrdconta%TYPE,
               nmdsacad  crapsab.nmdsacad%TYPE,
               cdtpinsc  crapsab.cdtpinsc%TYPE,
               nrinssac  crapsab.nrinssac%TYPE,
               dsendsac  crapsab.dsendsac%TYPE,
               nrendsac  crapsab.nrendsac%TYPE,
               nmbaisac  crapsab.nmbaisac%TYPE,
               nmcidsac  crapsab.nmcidsac%TYPE,
               cdufsaca  crapsab.cdufsaca%TYPE,
               nrcepsac  crapsab.nrcepsac%TYPE,
               cdoperad  crapsab.cdoperad%TYPE,
               dtmvtolt  crapsab.dtmvtolt%TYPE,
               nrcelsac  crapsab.nrcelsac%TYPE
               );
  TYPE typ_tab_sacado IS TABLE OF typ_rec_sacado
    INDEX BY PLS_INTEGER;  


  --> Integrar/processar arquivo de remessa cnab240_001
  PROCEDURE pc_intarq_remes_cnab240_001(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                       ,pr_nmarquiv  IN VARCHAR2              --> Nome do arquivo a ser importado               
                                       ,pr_idorigem  IN INTEGER               --> Identificador de origem
                                       ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                       ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do operador
                                       ,pr_nmdatela  IN VARCHAR2              --> Nome da Tela                                 
                                       ,pr_tab_crawrej IN OUT typ_tab_crawrej --> Tabela de Rejeitados
                                       ,pr_hrtransa OUT INTEGER               --> Hora da transacao
                                       ,pr_nrprotoc OUT VARCHAR2              --> Numero do Protocolo
                                       ,pr_des_reto OUT VARCHAR2              --> OK ou NOK
                                       ,pr_cdcritic OUT INTEGER               --> Codigo de critica
                                       ,pr_dscritic OUT VARCHAR2);           --> Descricao da critica

  -- Integrar/processar arquivo de remessa cnab240
  PROCEDURE pc_intarq_remes_cnab240_085(pr_cdcooper  IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                                        pr_nrdconta  IN crapass.nrdconta%TYPE, --> Numero da conta do cooperado
                                        pr_nmarquiv  IN VARCHAR2,              --> Nome do arquivo a ser importado               
                                        pr_idorigem  IN INTEGER,               --> Identificador de origem
                                        pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE, --> Data do movimento
                                        pr_cdoperad  IN crapope.cdoperad%TYPE, --> Codigo do operador
                                        pr_nmdatela  IN VARCHAR2,              --> Nome da Tela
                                        ------> OUT <------
                                        pr_tab_crawrej IN OUT typ_tab_crawrej, --> Tabela de reijatados
                                        pr_hrtransa OUT INTEGER,               --> Hora da transacao
                                        pr_nrprotoc OUT VARCHAR2,              --> Numero do Protocolo
                                        pr_des_reto OUT VARCHAR2,              --> OK ou NOK
                                        pr_cdcritic OUT INTEGER,               --> Codigo de critica
                                        pr_dscritic OUT VARCHAR2);             --> Descricao da critica

  --> Integrar/processar arquivo de remessa CNAB400
  PROCEDURE pc_intarq_remes_cnab400_085(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                       ,pr_nmarquiv  IN VARCHAR2              --> Nome do arquivo a ser importado               
                                       ,pr_idorigem  IN INTEGER               --> Identificador de origem
                                       ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                       ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do operador
                                       ,pr_nmdatela  IN VARCHAR2              --> Nome da Tela
                                       ,pr_tab_crawrej IN OUT typ_tab_crawrej --> Tabela de Rejeitados
                                       ,pr_hrtransa OUT INTEGER               --> Hora da transacao
                                       ,pr_nrprotoc OUT VARCHAR2              --> Numero do Protocolo
                                       ,pr_des_reto OUT VARCHAR2              --> OK ou NOK
                                       ,pr_cdcritic OUT INTEGER               --> Codigo de critica
                                       ,pr_dscritic OUT VARCHAR2               --> Descricao da critica
                                       ) ;                                        

  /* Procedure que prepara retorno para cooperado  */
  PROCEDURE pc_prep_retorno_cooper_90 (pr_idregcob IN ROWID --ROWID da cobranca
                                      ,pr_cdocorre IN INTEGER --Codigo Ocorrencia
                                      ,pr_cdmotivo IN VARCHAR --Descricao Motivo
                                      ,pr_vltarifa IN NUMBER  --Valor Tarifa
                                      ,pr_cdbcoctl IN crapcop.cdbcoctl%TYPE --Banco Centralizador
                                      ,pr_cdagectl IN crapcop.cdagectl%TYPE --Agencia Centralizadora
                                      ,pr_dtmvtolt IN DATE    --Data Movimento
                                      ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                      ,pr_nrremass IN INTEGER --Numero Remessa
                                      ,pr_dtcatanu IN crapret.dtcatanu%TYPE DEFAULT null --Data de referencia a quitacao da divida.
                                      ,pr_cdcritic OUT INTEGER --Codigo Critica
                                      ,pr_dscritic OUT VARCHAR2);  --Descricao Critica
                                      
  /* Procedimento do internetbank operação 69 - Arquivo de cobranca */
  PROCEDURE pc_InternetBank69 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                              ,pr_nrdconta IN crapttl.nrdconta%TYPE   --> Numero da conta
                              ,pr_nmarquiv IN VARCHAR2                --> Nome do arquivo
                              ,pr_idorigem IN INTEGER                 --> Ambiente de Origem
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --> Data de movimento
                              ,pr_cdoperad IN VARCHAR2                --> Codigo do operador
                              ,pr_nmdatela IN VARCHAR2                --> Nome da tela
                              ,pr_flvalarq IN INTEGER                 --> 1-TRUE 0-FALSE
                              ,pr_iddirarq IN INTEGER                 --> Indica o diretório de importação (0 - "/usr/coop/COOPERATIVA/upload/" ou 1 - "/usr/coop/SOA/COOPERATIVA/upload/")
                              ,pr_flmobile IN INTEGER                 --> Indicador se origem é do Mobile
                              ,pr_iptransa IN VARCHAR2                --> IP da transacao no IBank/mobile
                              ,pr_xml_dsmsgerr   OUT VARCHAR2         --> Retorno XML de critica
                              ,pr_xml_operacao69 OUT CLOB             --> Retorno XML da operação 26
                              ,pr_dsretorn       OUT VARCHAR2);       --> Retorno de critica (OK ou NOK)
                           
   /* Procedure validar arquivos de cobranca Modo Caracter */
  PROCEDURE pc_valida_arquivo_cobranca_car(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                          ,pr_nmarqint IN VARCHAR2                --> Nome do arquivo a ser validado                                          
                                          ,pr_des_erro OUT VARCHAR2               --> Saida OK/NOK
                                          ,pr_clob_ret OUT CLOB                   --> Tabela Beneficiarios
                                          ,pr_cdcritic OUT PLS_INTEGER            --> Codigo Erro
                                          ,pr_dscritic OUT VARCHAR2);         
            
  /*Todas as rotinas abaixo nao precisa ser declaradas publicas pois, foram
    declaradas apenas para facilitar os testes
    */                          
  --> Realiza a validação do arquivo cnab240 01
  PROCEDURE pc_importa (pr_cdcooper    IN crapcop.cdcooper%TYPE,   --> Codigo da cooperativa
                        pr_nmarqint    IN VARCHAR2,                --> Nome do arquivo a ser validado
                        pr_tpenvcob    IN crapceb.inenvcob%TYPE DEFAULT 1, --> Tipo de envio do arquivo (1-Envio via Internet Bank, 2-Envio via FTP)
                        pr_rec_rejeita OUT COBR0006.typ_tab_rejeita,       --> Dados invalidados
                        pr_des_reto    OUT VARCHAR2               --> Retorno OK/NOK
                        ) ;
                                           
  --> Realiza a validação do arquivo cnab240 085
  PROCEDURE pc_importa_cnab240_085 (pr_cdcooper    IN crapcop.cdcooper%TYPE     --> Codigo da cooperativa
                                   ,pr_nmarqint    IN VARCHAR2                  --> Nome do arquivo a ser validado
                                   ,pr_tpenvcob    IN crapceb.inenvcob%TYPE DEFAULT 1 --> Tipo de envio do arquivo (1-Envio via Internet Bank, 2-Envio via FTP)
                                   ,pr_rec_rejeita OUT COBR0006.typ_tab_rejeita --> Dados invalidados
                                   ,pr_des_reto    OUT VARCHAR2) ; 
                                   
                                   
                                   
PROCEDURE pc_importa_cnab400_085 (pr_cdcooper    IN crapcop.cdcooper%TYPE      --> Codigo da cooperativa
                                   ,pr_nmarqint    IN VARCHAR2                   --> Nome do arquivo a ser validado
                                   ,pr_tpenvcob    IN crapceb.inenvcob%TYPE DEFAULT 1 --> Tipo de envio do arquivo (1-Envio via Internet Bank, 2-Envio via FTP)
                                   ,pr_rec_rejeita OUT COBR0006.typ_tab_rejeita  --> Dados invalidados
                                   ,pr_des_reto    OUT VARCHAR2) ;              --> Retorno OK/NOK
                                                                 
  --> Realiza a validação dos arquivos de cobranca
  PROCEDURE pc_valida_arquivo_cobranca (pr_cdcooper    IN crapcop.cdcooper%TYPE,     --> Codigo da cooperativa
                                        pr_nmarqint    IN VARCHAR2,                  --> Nome do arquivo a ser validado
                                        pr_tpenvcob    IN crapceb.inenvcob%TYPE DEFAULT 1, --> Tipo de envio do arquivo (1-Envio via Internet Bank, 2-Envio via FTP)
                                        pr_rec_rejeita OUT COBR0006.typ_tab_rejeita, --> Dados invalidados
                                        pr_des_reto    OUT VARCHAR2);               --> Retorno OK/NOK
                                        
  --> Verifica o tipo de arquivo
  PROCEDURE pc_identifica_arq_cnab (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                   ,pr_nmarqint IN VARCHAR2               --> Nome do arquivo
                                   ,pr_tparquiv OUT VARCHAR2              --> Tipo do arquivo
                                   ,pr_cddbanco OUT INTEGER               --> Codigo do banco
								   ,pr_nrdconta OUT crapass.nrdconta%TYPE --> Numero da conta do cooperado    
                                   ,pr_rec_rejeita OUT COBR0006.typ_tab_rejeita --> Tabela com rejeitados
                                   ,pr_cdcritic OUT INTEGER               --> Código da critica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da critica
                                   ,pr_des_reto OUT VARCHAR2) ;          --> Retorno OK/NOK                                             
  
  -- Procedure para rejeitar arquivo de remessa
  PROCEDURE pc_rejeitar_arquivo (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                ,pr_dtmvtolt      IN DATE                   -- Data do Movimento  
                                ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro                                                                                                     
                                                                                                     
  -- Procedure para processar os titulos que foram identificados no arquivo
  PROCEDURE pc_processa_instrucoes(pr_cdcooper      IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                  ,pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                  ,pr_cdoperad      IN crapope.cdoperad%TYPE --> Operador
                                  ,pr_flremarq      IN INTEGER DEFAULT 1     --> Identifica se é uma remessa via arquivo(1-Sim, 0-Não)
                                  ,pr_tab_instrucao IN typ_tab_instrucao     --> Tabela de Cobranca
                                  ,pr_rec_header    IN typ_rec_header        --> Dados do Header do Arquivo
                                  ,pr_tab_rejeitado IN OUT NOCOPY typ_tab_rejeitado --> Tabela de rejeitados
                                  ,pr_tab_lat_consolidada IN OUT NOCOPY PAGA0001.typ_tab_lat_consolidada --> Tabela tarifas
                                  ,pr_cdcritic     OUT INTEGER               --> Codigo da Critica
                                  ,pr_dscritic     OUT VARCHAR2);            --> Descricao da Critica

  -- Procedure para processar os titulos que foram identificados no arquivo
  PROCEDURE pc_processa_rejeitados(pr_tab_rejeitado IN typ_tab_rejeitado     --> Tabela de rejeitados
                                  ,pr_cdcritic     OUT INTEGER               --> Codigo da Critica
                                  ,pr_dscritic     OUT VARCHAR2);            --> Descricao da Critica



END COBR0006;
/
CREATE OR REPLACE PACKAGE BODY CECRED.COBR0006 IS

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : COBR0006
    Sistema  : Procedimentos para  gerais da cobranca
    Sigla    : CRED
    Autor    : Odirlei Busana - AMcom
    Data     : Novembro/2015.                   Ultima atualizacao: 18/07/2019
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Rotinas referente a importacao de arquivos de cobrança
  
    Alteracoes: 08/03/2016 - Ajuste referente as conversoes das rotinas referentes a importacao dos 
                             arquivos de cobranca CNAB
                             (Andrei - RKAM)
                   
                27/05/2016 - Ajuste para considerar o caracter ":" ao chamar
                             a rotina de validação de caracteres para endereços
                            (Andrei).  
                    
                31/05/2016 - Ajuste para inclusao do controle monitoramento para
                             integracao com Aymaru
                            (Andrei - RKAM).   
                            
                07/06/2016 - Ajuste para remover o arquivo original da pasta upload
                             (Andrei - RKAM). 
                                           
                06/07/2016 - Ajuste para definir rotinas como publicas (Andrei - RKAM).
                
                17/08/2016 - Ajustes realizados:
                              > Ajuste para retirar tratementos do Trailer de Lote e
                                efetuar tratamento para os segmentos R,S;
                              > Ajuste para enviar o nome original do arquivo para emissao do protocolo;
                             (Andrei - RKAM).
                                           
                26/10/2016 - Ajuste na validacao do nome do sacado (pc_trata_segmento_q_240_85)
                             para considerar o caracter ':' como valido.
                             (Chamado 535830) - (Fabricio)

				01/11/2016 - Incluido tratamento NVL no campo QTDIAPRT ao inserir na CRAPCOB.
				             Alterado local de atribuicao de valores nos campos da pc_rec_cobranca
							 na rotina pc_trata_detalhe_cnab400. Estava gerando erro nas instrucoes
							 enviadas pelos cooperados.
							 Heitor (Mouts) - Chamado 545476
                                           
				04/11/2016 - Removidas validacoes de CEP quanto a UF, se a UF que vier no arquivo for
				             diferente da UF da base de enderecos, nao vai rejeitar.
							 Heitor (Mouts) - Chamado 523346
                                           
                07/11/2016 - Ajustado a validacao de Data de Emissao, para que a quantidade 
                             de dias seja parametrizada. Foi definido o parametro na crapprm
                             cdacesso = "QTD_DIAS_EMISSAO_RETR" para armazenar o valor.
                             Sera alterado de 90 para 365 dias. (Douglas - Chamado 523329)

				01/12/2016 - Inserir texto informativo no campo dsinform e nao mais no campo dsdinstr
				             Por estar utilizando o campo indevido, nao estava enviando a info para a PG
							 Heitor (Mouts) - Chamado 564818

                02/12/2016 - Ajustes efetuados:
                              > Levantar exception (NOK) quando for encontrado registro de rejeição;
                              > Tratar nome da cidade, nome do bairro e uf nulos ; 
                             (Andrei - RKAM).
                            
                22/12/2016 - Ajuste para utilizar a sequence na geração do registro na craprtc 
                            (Douglas - Chamado 547357)

                06/01/2017 - Ajuste na forma como sao feitas as atribuicoes dos campos de protesto e serasa, estava
                             gerando problemas com protesto e negativacao automaticos e exibicao na COBRAN.
                             Heitor (Mouts) - Chamado 574161

               29/12/2016 - P340 - Ajustes para leitura do segmento Y053;
                                 - Envio dos boletos para a CRPS618;                            
                            (Ricardo Linhares)
                            
                07/02/2017 - Projeto 319 - Envio de SMS para boletos de cobranca (Andrino - Mout's)

                13/02/2017 - Ajustes realizados: 
                              > Utilizar NOCOPY na passagem de PLTABLEs como parâmetro;
                              > Alterado diretório para mover os arquivos rejeitados;
                            (Andrei - Mouts).

                17/03/2017 - Removido a validação que verificava se o CEP do pagador do boleto existe no Ayllos
                             Solicitado pelo Leomir e aprovado pelo Victor (cobrança)
                             (Douglas - Chamado 601436)
                             
                16/05/2017 - Implementado melhorias para nao ocorrer estouro de chave
                             qdo inserir a crapsab na pc_processa_sacados (Tiago/Rodrigo #663284)
                             
                30/05/2017 - Feito tratamento para o campo NOSSO NUMERO qdo for nulo devolver a 
                             critica correta na procedure pc_trata_segmento_p_240_85
                             (Tiago/Rodrigo #664748)
                             
                30/05/2017 - Implementado ajustes para nao estourar a chave da crapcob na 
                             pc_processa_titulos(Tiago/Rodrigo #663295)
                
                01/02/2018 - Alterações referente ao PRJ352 - Nova solução de protesto.
                
                             
                12/06/2018 - Ajuste para remover caratere especiais do campo dsdinstr que é usado para gravar 
                             na crapcob campo dsinform : Alcemir - Mout's (PRB0040060) .      
							 
		        06/07/2018 - Incluido validação da UF do arquivo de cobrança : Alcemir - Mout's (SCTASK0014853).
				     
            08/10/2018 - Incluido validação de UF para pretesto codigos 9 e 80 (SM_P352, Anderson-Alan, Supero)
				     
            19/11/2018 - inc0027103 Na rotina pc_InternetBank69, separadas as execuções em module e action para
                         cada tipo de layout cnab, a fim de identificar melhor os pontos que demandam mais 
                         processamento (Carlos)
                         
                 12/03/2019 - Validar numero do boleto zero no arquivo de remessa
                              (Lucas Ranghetti INC0031367)
                              
            18/07/2019 - inc0020612 Na rotina pc_trata_segmento_p_240_85, verificado a nulidade do valor de
                         desconto quando o mesmo for obrigatório (Carlos)
  ---------------------------------------------------------------------------------------------------------------*/
  
  ------------------------------- CURSORES ---------------------------------    
  --> Buscar dados do associado
  CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                     pr_nrdconta crapass.nrdconta%TYPE) IS
  SELECT ass.nrdconta,
         ass.nrcpfcgc,
         ass.inpessoa,
         decode(ass.inpessoa,1,1,2) inpessoa_vld,
         ass.cdcooper
    FROM crapass ass
   WHERE ass.cdcooper = pr_cdcooper
     AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
  --> Busca as informacoes da cobranca
  CURSOR cr_crapcob (pr_cdcooper crapcob.cdcooper%TYPE,
                     pr_nrdconta crapcob.nrdconta%TYPE,
                     pr_cdbandoc crapcob.cdbandoc%TYPE,
                     pr_nrdctabb crapcob.nrdctabb%TYPE,
                     pr_nrcnvcob crapcob.nrcnvcob%TYPE,
                     pr_nrdocmto crapcob.nrdocmto%TYPE) IS
  SELECT cob.cdcooper,
         cob.nrdconta,
         cob.nrcnvcob,
         cob.nrdocmto,
         cob.vltitulo,
         cob.dtvencto,
         cob.dsinform,
         cob.incobran,
         cob.cdtitprt,
         cob.flgcbdda,
         cob.ininscip,
         cob.nrdident,
         cob.rowid
    FROM crapcob cob
   WHERE cob.cdcooper = pr_cdcooper 
     AND cob.cdbandoc = pr_cdbandoc 
     AND cob.nrdctabb = pr_nrdctabb 
     AND cob.nrcnvcob = pr_nrcnvcob 
     AND cob.nrdconta = pr_nrdconta 
     AND cob.nrdocmto = pr_nrdocmto;
  rw_crapcob cr_crapcob%ROWTYPE;

/* Remover o cursor, nao sera mais validado se o CEP existe no sistema
   Chamado 601436 -> Solicitado por Leomir e autorizado pelo Victor Hugo Zimmerman
  --> Buscar as informacoes do cadastro de endereco
  CURSOR cr_crapdne (pr_nrceplog crapdne.nrceplog%TYPE,
                     pr_idoricad crapdne.idoricad%TYPE) IS
  SELECT dne.cduflogr
    FROM crapdne dne
   WHERE dne.nrceplog = pr_nrceplog
     AND dne.idoricad = pr_idoricad;
  rw_crapdne cr_crapdne%ROWTYPE;
*/  

  -- cursor para buscar as UFs 
  CURSOR cr_caduf (pr_cduf tbcadast_uf.cduf%TYPE) IS
   SELECT u.cduf FROM tbcadast_uf u
    WHERE u.cduf <> 'EX'
     AND  UPPER(u.cduf) = UPPER(pr_cduf);
  rw_caduf cr_caduf%ROWTYPE; 

  --> Busca informacoes do Controle de Remessa/Retorno de Titulos do Cooperado
  CURSOR cr_craprtc (pr_cdcooper craprtc.cdcooper%TYPE,
                     pr_nrdconta craprtc.nrdconta%TYPE,
                     pr_nrcnvcob craprtc.nrcnvcob%TYPE,
                     pr_nrremret craprtc.nrremret%TYPE,
                     pr_intipmvt craprtc.intipmvt%TYPE) IS
  SELECT rtc.nrremret
        ,rtc.rowid
    FROM craprtc rtc
   WHERE rtc.cdcooper = pr_cdcooper
     AND rtc.nrdconta = pr_nrdconta
     AND rtc.nrcnvcob = pr_nrcnvcob
     AND rtc.nrremret = pr_nrremret
     AND rtc.intipmvt = pr_intipmvt
   ORDER BY rtc.progress_recid DESC;
  
  ---------------------------------
  -- Quantidade de dias para emissão retroativa
  vr_qtd_emi_ret CONSTANT INTEGER := NVL(gene0001.fn_param_sistema('CRED',0,'QTD_DIAS_EMISSAO_RETR'), 90);
  ---------------------------------
  
  /* Funcao para validacao dos caracteres */
  FUNCTION fn_valida_caracteres (pr_flgnumer IN BOOLEAN,  -- Validar Numeros?
                                 pr_flgletra IN BOOLEAN,  -- Validar Letras?
                                 pr_listaesp IN VARCHAR2, -- Lista de Caracteres Validos
                                 pr_dsvalida IN VARCHAR2  -- Texto para ser validado
                                ) RETURN BOOLEAN IS       -- ERRO -> TRUE
  /* ............................................................................

    Programa: fn_valida_caracteres                           antiga:b1wgen0090/valida_caracteres
    Autor   : Douglas Quisinski
    Data    : Dezembro/2015                  Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Rotina de validacao de caracteres com base parametros informados
                Se o texto que esta sendo validado tiver algum caracter que nao esta na lista
                vai retornar ERRO -> TRUE

    Parametros : pr_flgnumer : Validar lista de numeros ?
                 pr_flgletra : Validar lista de letras  ?
                 pr_listaesp : Lista de caracteres validados.
                 pr_validar  : Campo a ser validado.

    Alteracoes: 
  ............................................................................ */   
    vr_dsvalida VARCHAR2(30000);
      
    vr_numeros  VARCHAR2(10) := '0123456789';
	--Necessario acrescentar esta variavel por causa da 
    --funcao CAN-DO do Progress, que permite simbolos como "(" e ")";
    vr_simbolos VARCHAR2(10) := '().,/-_:';
    vr_letras   VARCHAR2(49) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÀÄÂÃÉÈËÊÍÌÏÎÓÒÖÔÕÚÙÜÛÇ';
    vr_validar  VARCHAR2(30000);
    vr_caracter VARCHAR2(1);
      
    TYPE typ_tab_char IS TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(1);
    vr_tab_char typ_tab_char;
            
  BEGIN
      
    vr_dsvalida := REPLACE(UPPER(pr_dsvalida),' ','');
    -- Caso nao tenha campos a validar retorna OK
    IF TRIM(vr_dsvalida) IS NULL THEN
      RETURN FALSE;
    END IF;

    -- Numeros
    IF pr_flgnumer THEN
      -- Todos os caracteres devem ser numeros
      vr_validar:= vr_validar || vr_numeros;
    END IF;

    -- Letras 
    IF pr_flgletra THEN
      -- Todos os caracteres devem ser numeros
      vr_validar:= vr_validar || vr_letras;
    END IF;
      
    -- Lista Caracteres Aceitos
    IF TRIM(pr_listaesp) IS NOT NULL THEN
      vr_validar:= vr_validar || pr_listaesp;
    END IF;

	--Necessario permitir simbolos "(" e ")";
    vr_validar := vr_validar || vr_simbolos;
    FOR vr_pos IN 1..length(vr_validar) LOOP
      vr_caracter:= SUBSTR(vr_validar,vr_pos,1);
      vr_tab_char(vr_caracter) := vr_caracter;
    END LOOP;
    
    FOR vr_pos IN 1..length(vr_dsvalida) LOOP
      vr_caracter:= SUBSTR(vr_dsvalida,vr_pos,1);
      IF NOT vr_tab_char.exists(vr_caracter) THEN
        RETURN TRUE;
      END IF;
    END LOOP;

    RETURN FALSE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END fn_valida_caracteres;
  
  /* Verifica campos numéricos */
  FUNCTION fn_numericos (pr_conteudo VARCHAR2 --Conteudo a ser validado
                         ) RETURN BOOLEAN IS       -- ERRO -> TRUE
  /* ............................................................................

    Programa: fn_numericos
    Autor   : Andrei - RKAM
    Data    : Marco/2016                  Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Valida campos numéricos

    Parametros : 
    
    Alteracoes: 
  ............................................................................ */   
    vr_dsvalida VARCHAR2(30000);
      
    vr_numeros  VARCHAR2(10) := '0123456789';
    vr_validar  VARCHAR2(30000);
    vr_caracter VARCHAR2(1);
      
    TYPE typ_tab_char IS TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(1);
    vr_tab_char typ_tab_char;
            
  BEGIN
      
    IF trim(pr_conteudo) IS NULL THEN
      
      RETURN FALSE;
    
    ELSE
       
      vr_validar:= vr_validar || vr_numeros;
       
      FOR vr_pos IN 1..length(vr_validar) LOOP
        
        vr_caracter:= SUBSTR(vr_validar,vr_pos,1);
        vr_tab_char(vr_caracter) := vr_caracter;
        
      END LOOP;
      
      FOR vr_pos IN 1..length(pr_conteudo) LOOP
        
        vr_caracter:= SUBSTR(pr_conteudo,vr_pos,1);
        
        IF NOT vr_tab_char.exists(vr_caracter) THEN
          RETURN FALSE;
        END IF;
        
      END LOOP;
      
    END IF;
    
    RETURN TRUE;
    
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END fn_numericos;


  /* Função para remover caracteres especiais */
  FUNCTION fn_remove_chr_especial(pr_texto VARCHAR2    -- Texto Original
                                  ) RETURN VARCHAR2 IS -- Texto sem caracteres especiais
  /* ............................................................................

    Programa: fn_remove_chr_especial
    Autor   : Douglas Quisinski
    Data    : Novembro/2017               Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Remover os caracteres especiais na importação do arquivo de cobrança

    Parametros : 
    
    Alteracoes: 
  ............................................................................ */   
    vr_texto VARCHAR2(30000);
  BEGIN
    -- Tetxo Original
    vr_texto:= pr_texto;
    
    -- Remover o "&" pois gera erro no XML caso seja inserido no Banco de Dados
    vr_texto:= REPLACE(vr_texto,'&','E');

    -- Remover o chr(160) "Espaço em branco que não quebra (Non-breaking space)"
    -- ele não é visivel no arquivo pois é identico a um espaço em branco,
    -- porém é outro caracter
    -- O espaço em branco é o chr(32)
    vr_texto:= REPLACE(vr_texto,chr(160),'');
    
    -- Remover os espaços em branco
    vr_texto:= TRIM(vr_texto);
    
    RETURN vr_texto;
    
  EXCEPTION
    WHEN OTHERS THEN
      RETURN vr_texto;
  END fn_remove_chr_especial;


  /* Rotina para monitoração do processo de importação dos arquivos de cobrança para integraão ao Aymaru */
  PROCEDURE pc_monitora_processo(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da conta
                                ,pr_cdprogra  IN VARCHAR2              --> Nome do programa
                                ,pr_cdservico IN INTEGER               --> Código do serviço
                                ,pr_tpoperac  IN INTEGER               --> Tipo de operação
                                ,pr_flgerro   IN INTEGER               --> Com erros
                                ,pr_nmarquiv  VARCHAR2                 --> Nome do arquivo
                                ,pr_dslogerro VARCHAR2                 --> Descrição do erro
                                ,pr_qtprocessado INTEGER               --> Quantidade de registros processados
                                ,pr_qterro       INTEGER               --> Quantidade de registros com erro
                                ,pr_rowid_resumo IN OUT ROWID          --> ROWID do resumo do processo 
                                ,pr_rowid_item_resumo IN OUT ROWID) IS --> Rowid do item de resumo do processo
    -- Cria uma nova seção para commitar
    -- somente este escopo de alterações
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    -- ..........................................................................

    -- Programa: pc_monitora_processo
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Andrei - RKAM
    -- Data    : Maio/2016.                     Ultima atualizacao:

    -- Dados referentes ao programa:

    -- Frequencia: Sempre que for chamado
    -- Objetivo  : Realizar a inclusão/atualização dos registros para monitoração do processo de importação dos arquivos CNAB. 
    --             Esse monitoramento será integrado com o Aymaru.

    -- Alteracoes:
    --
    -- .............................................................................
    DECLARE

      --Cursor para buscar o tipo de serviço
      CURSOR cr_tbgen_aplicacao_barramento(pr_cdservico IN tbgen_aplicacao_barramento.cdservico_barramento%TYPE)IS
      SELECT tbgen_aplicacao_barramento.cdservico_barramento
        FROM tbgen_aplicacao_barramento
       WHERE tbgen_aplicacao_barramento.cdservico_barramento = pr_cdservico;
      rw_tbgen_aplicacao_barramento cr_tbgen_aplicacao_barramento%ROWTYPE;
      
      --Crusro para buscar o resumo do processo
      CURSOR cr_tbgen_resumo_processo(pr_rowid IN ROWID)IS
      SELECT tbgen_resumo_processo.cdresumo_processo
        FROM tbgen_resumo_processo
       WHERE ROWID = pr_rowid;
      rw_tbgen_resumo_processo cr_tbgen_resumo_processo%ROWTYPE;
      
      --Cursor para buscar os itens do resumo
      CURSOR cr_tbgen_item_resumo_processo(pr_rowid IN ROWID)IS
      SELECT ROWID
        FROM tbgen_item_resumo_processo
       WHERE ROWID = pr_rowid;
      rw_tbgen_item_resumo_processo cr_tbgen_item_resumo_processo%ROWTYPE;
      
      --Variaveis locais
      vr_dscritic VARCHAR2(400);
      vr_cdresumo_processo tbgen_resumo_processo.cdresumo_processo%TYPE;
      
      --Variaveis de exceção
      vr_exc_erro EXCEPTION;
      vr_nrsequence crapsqu.nrseqatu%TYPE;

    BEGIN

      --Busca o tipo de serviço
      OPEN cr_tbgen_aplicacao_barramento(pr_cdservico => pr_cdservico);
        
      FETCH cr_tbgen_aplicacao_barramento INTO rw_tbgen_aplicacao_barramento;
        
      IF cr_tbgen_aplicacao_barramento%NOTFOUND THEN
        
        --Fecha o cursor
        CLOSE cr_tbgen_aplicacao_barramento;
          
        vr_dscritic := 'Tipo de servico nao encontrado.';
           
        RAISE vr_exc_erro;
          
      ELSE
          
        --Fecha o cursor
        CLOSE cr_tbgen_aplicacao_barramento;  
                    
      END IF;
        
      --Inicaliza o monitoramento
      IF pr_tpoperac = 1 THEN
        vr_nrsequence := fn_sequence(pr_nmtabela => 'TBGEN_RESUMO_PROCESSO'
                                ,pr_nmdcampo => 'CDRESUMO_PROCESSO'
                                ,pr_dsdchave => '0');
        BEGIN
          INSERT INTO tbgen_resumo_processo (cdresumo_processo
                                            ,cdservico_barramento
                                            ,dhinicio
                                            ,indstatus_processo)
                                     VALUES( vr_nrsequence
                                            ,rw_tbgen_aplicacao_barramento.cdservico_barramento
                                            ,SYSDATE
                                            ,1)
                                 RETURNING ROWID
                                          ,tbgen_resumo_processo.cdresumo_processo
                                      INTO pr_rowid_resumo
                                          ,vr_cdresumo_processo;
        EXCEPTION
          WHEN OTHERS THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_cdprograma   => NVL(pr_cdprogra, 'COBR0006'),
                                       pr_ind_tipo_log => 2, --> erro tratado
                                       pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                          ' - '|| NVL(pr_cdprogra, 'COBR0006') ||
                                                          ' --> Erro tratado na COBR0006.pc_monitora_processo -'
                                                          || ' ao inserir tbgen_resumo_processo: '|| SQLERRM ,
                                       pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
                                

        END;

        vr_nrsequence := fn_sequence(pr_nmtabela => 'TBGEN_ITEM_RESUMO_PROCESSO'
                                ,pr_nmdcampo => 'CDITEM_RESUMO_PROCESSO'
                                ,pr_dsdchave => '0');
        
        BEGIN
            INSERT INTO tbgen_item_resumo_processo (cditem_resumo_processo
                                                    ,cdresumo_processo
                                                    ,dhinicio                                                                                                       
                                                    ,indstatus_processo
                                                    ,cdcooper
                                                    ,nrdconta
                                                    ,dsitem_resumo_processo)
                                             VALUES(vr_nrsequence
                                                   ,vr_cdresumo_processo
                                                   ,SYSDATE                                                  
                                                   ,1 --Iniciado
                                                   ,pr_cdcooper
                                                   ,pr_nrdconta
                                                   ,pr_nmarquiv)
                                         RETURNING(ROWID)
                                              INTO(pr_rowid_item_resumo) ;
          EXCEPTION
            WHEN OTHERS THEN
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_cdprograma   => NVL(pr_cdprogra, 'COBR0006'),
                                         pr_ind_tipo_log => 2, --> erro tratado
                                         pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                            ' - '|| NVL(pr_cdprogra, 'COBR0006') ||
                                                            ' --> Erro tratado na COBR0006.pc_monitora_processo -'
                                                            || ' ao inserir tbgen_resumo_processo: '|| SQLERRM ,
                                         pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
                                  

          END;
      
      --Finaliza o monitoramento
      ELSIF pr_tpoperac = 2 THEN
        
        OPEN cr_tbgen_resumo_processo(pr_rowid => pr_rowid_resumo);
        
        FETCH cr_tbgen_resumo_processo INTO rw_tbgen_resumo_processo;
        
        IF cr_tbgen_resumo_processo%NOTFOUND THEN
          
          --Fecha o cursor
          CLOSE cr_tbgen_resumo_processo;
          
          vr_dscritic := 'Nao foi possivel encontrar o registro do resumo.';
          
          RAISE vr_exc_erro;
          
        ELSE
          
          --Fecha o cursor
          CLOSE cr_tbgen_resumo_processo;
        
        END IF;
        
        BEGIN
          UPDATE tbgen_resumo_processo 
             SET tbgen_resumo_processo.dhtermino = SYSDATE
                ,tbgen_resumo_processo.dslog_erro = pr_dslogerro
                ,tbgen_resumo_processo.indstatus_processo = (CASE 
                                                               WHEN pr_flgerro = 1  THEN 
                                                                 4 --Com erro
                                                               ELSE 
                                                                 3 --Com sucesso
                                                             END)                              
           WHERE ROWID = pr_rowid_resumo;                                  
        EXCEPTION
          WHEN OTHERS THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_cdprograma   => NVL(pr_cdprogra, 'COBR0006'),
                                       pr_ind_tipo_log => 2, --> erro tratado
                                       pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                          ' - '|| NVL(pr_cdprogra, 'COBR0006') ||
                                                          ' --> Erro tratado na COBR0006.pc_monitora_processo -'
                                                          || ' ao atualizar tbgen_resumo_processo: '|| SQLERRM ,
                                       pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
                                

        END;
        
        OPEN cr_tbgen_item_resumo_processo(pr_rowid => pr_rowid_item_resumo);
        
        FETCH cr_tbgen_item_resumo_processo INTO rw_tbgen_item_resumo_processo;
        
        IF cr_tbgen_item_resumo_processo%NOTFOUND THEN
          
          --Fecha o cursor
          CLOSE cr_tbgen_item_resumo_processo;
          
          vr_dscritic := 'Nao foi possivel encontrar o registro de item do resumo.';
          
          RAISE vr_exc_erro;
          
        ELSE
          
          --Fecha o cursor
          CLOSE cr_tbgen_item_resumo_processo;
        
        END IF;
        
        BEGIN
          
          UPDATE tbgen_item_resumo_processo
             SET tbgen_item_resumo_processo.indstatus_processo = (CASE 
                                                                   WHEN pr_flgerro = 1 THEN 
                                                                     4 --Com erro
                                                                   ELSE 
                                                                     3 --Com sucesso
                                                                 END) 
                ,tbgen_item_resumo_processo.dhtermino = SYSDATE
                ,tbgen_item_resumo_processo.qtprocessado = nvl(pr_qtprocessado,0)
                ,tbgen_item_resumo_processo.qterro = nvl(pr_qterro,0)
           WHERE ROWID = pr_rowid_item_resumo;
        
        EXCEPTION
          WHEN OTHERS THEN
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_cdprograma   => NVL(pr_cdprogra, 'COBR0006'),
                                         pr_ind_tipo_log => 2, --> erro tratado
                                         pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                            ' - '|| NVL(pr_cdprogra, 'COBR0006') ||
                                                            ' --> Erro tratado na COBR0006.pc_monitora_processo -'
                                                            || ' ao atualizar tbgen_item_resumo_processo: '|| sqlerrm ,
                                         pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
                                  
        END;
      
      END IF;
      
      -- Gravar
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        /* Se aconteceu erro, gera o log e envia o erro por e-mail */
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_cdprograma   => NVL(pr_cdprogra, 'COBR0006'),
                                   pr_ind_tipo_log => 2, --> erro tratado
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '|| NVL(pr_cdprogra, 'COBR0006') ||
                                                      '-->  Erro nao tratado na COBR0006.pc_monitora_processo: '|| sqlerrm,
                                   pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
                                   
        -- Efetuar commit para liberar a seção
        COMMIT;
        
      WHEN OTHERS THEN
        /* Se aconteceu erro, gera o log e envia o erro por e-mail */
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_cdprograma   => NVL(pr_cdprogra, 'COBR0006'),
                                   pr_ind_tipo_log => 2, --> erro tratado
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_cdprogra, 'COBR0006') ||
                                                        ' --> Erro nao tratado na COBR0006.pc_monitora_processo: '|| sqlerrm,
                                   pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
                                   
        -- Efetuar commit para liberar a seção
        COMMIT;
        
    END;
  END pc_monitora_processo;
  
  --> Inicializa as variaveis do registro de cobranca
  PROCEDURE pc_inicializa_cobranca( pr_cdcooper     IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                                    pr_nrdconta     IN crapass.nrdconta%TYPE, --> Numero da conta do cooperado
                                    pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE, --> Data 
                                    pr_rec_header   IN typ_rec_header,        --> Dados do Header do Arquivo
                                    pr_rec_cobranca IN OUT typ_rec_cobranca   --> Dados da Cobranca
                                  ) IS
                                   
  /* ............................................................................

       Programa: pc_inicializa_cobranca
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Dezembro/2015.                   Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Inicializa todos os campos da cobranca

       Alteracoes: 
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
  BEGIN
    pr_rec_cobranca.cdcooper := pr_cdcooper;
    pr_rec_cobranca.nrdconta := pr_nrdconta;
    pr_rec_cobranca.dtmvtolt := pr_dtmvtolt;
    
    -- Dados da Cobranca
    pr_rec_cobranca.nrdctabb := pr_rec_header.nrdctabb;
    pr_rec_cobranca.cdbandoc := pr_rec_header.cdbandoc;
    pr_rec_cobranca.nrcnvcob := pr_rec_header.nrcnvcob;
    pr_rec_cobranca.flgregis := pr_rec_header.flgregis;
    pr_rec_cobranca.nrremass := pr_rec_header.nrremass;
    -- Vencimento
    pr_rec_cobranca.dtvencto := NULL;
    -- Valores
    pr_rec_cobranca.vltitulo := 0;
    pr_rec_cobranca.vldescto := 0;
    pr_rec_cobranca.tpdescto := 0;
    pr_rec_cobranca.vlabatim := 0;
    pr_rec_cobranca.tpdmulta := 3; /* Isento */
    pr_rec_cobranca.vldmulta := 0;
    pr_rec_cobranca.tpdjuros := NULL;
    pr_rec_cobranca.vldjuros := 0;
    pr_rec_cobranca.vlminimo := 0;
    -- Dados do Sacado
    pr_rec_cobranca.nmdsacad := NULL;
    pr_rec_cobranca.dsendsac := NULL;
    pr_rec_cobranca.nmbaisac := NULL;
    pr_rec_cobranca.nmcidsac := NULL;
    pr_rec_cobranca.cdufsaca := NULL;
    pr_rec_cobranca.nrcepsac := NULL;
    pr_rec_cobranca.cdtpinsc := NULL;
    pr_rec_cobranca.nrinssac := NULL;
    -- Email e telefone do Sacado
    pr_rec_cobranca.dsdemail := NULL;
    pr_rec_cobranca.nrcelsac := NULL;
    -- Dados do Avalista
    pr_rec_cobranca.nmdavali := NULL;
    pr_rec_cobranca.cdtpinav := NULL;
    pr_rec_cobranca.nrinsava := NULL;
    -- Dados do Boleto
    pr_rec_cobranca.dsnosnum := NULL;
    pr_rec_cobranca.nrbloque := NULL;
    pr_rec_cobranca.cdcartei := 01;
    pr_rec_cobranca.inemiten := 2; /* Cooperado Emite e Expede */
    pr_rec_cobranca.dsdoccop := NULL;
    pr_rec_cobranca.dsusoemp := NULL;
    pr_rec_cobranca.dsdinstr := NULL;
    pr_rec_cobranca.qtdiaprt := 0;
    pr_rec_cobranca.flgdprot := 0;
	pr_rec_cobranca.insrvprt := 0;
    pr_rec_cobranca.flgaceit := NULL;
    pr_rec_cobranca.inemiexp := NULL;
    pr_rec_cobranca.cddespec := NULL;
    pr_rec_cobranca.dtemscob := NULL;
    -- Ocorrencia --> Utilizado em diversas linhas
    pr_rec_cobranca.cdocorre := NULL;
    -- Inicializa como NAO rejeitada
    pr_rec_cobranca.flgrejei := FALSE;
	pr_rec_cobranca.inserasa := 0;
    pr_rec_cobranca.flserasa := 0;
    -- Indicadores de SMS
    pr_rec_cobranca.inavisms := 0;
    pr_rec_cobranca.insmsant := 0;
    pr_rec_cobranca.insmsvct := 0;
    pr_rec_cobranca.insmspos := 0;
    -- NPC
    pr_rec_cobranca.inpagdiv := 0;
    
  END pc_inicializa_cobranca;
  
  --> Gravar criticas do processo
  PROCEDURE pc_grava_critica( pr_cdcooper  IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                              pr_nrdconta  IN crapass.nrdconta%TYPE, --> Numero da conta do cooperado
                              pr_nrdocmto  IN crapcob.nrdocmto%TYPE, --> Numero do documento
                              pr_dscritic  IN VARCHAR2,              --> Descricao da critica
                              pr_tab_crawrej IN OUT NOCOPY COBR0006.typ_tab_crawrej --> Tabela de rejeitos
                              ) IS
                                   
  /* ............................................................................

       Programa: pc_grava_critica    
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana - AMcom
       Data    : Novembro/2015.                   Ultima atualizacao: 13/02/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Gravar criticas do processo

       Alteracoes: 25/11/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)

				   13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 
    ............................................................................ */   
    
    ------------------------ VARIAVEIS  ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    
    vr_index      INTEGER;
    
  BEGIN
    
    vr_index := pr_tab_crawrej.COUNT() + 1;
    
    pr_tab_crawrej(vr_index).cdcooper := pr_cdcooper;
    pr_tab_crawrej(vr_index).nrdconta := pr_nrdconta;
    pr_tab_crawrej(vr_index).nrdocmto := pr_nrdocmto;
    pr_tab_crawrej(vr_index).nrdconta := pr_nrdconta;
    pr_tab_crawrej(vr_index).dscritic := pr_dscritic;
    
  END pc_grava_critica;
  
  --> Gravar Boleto -> Gerar registro na PL TABLE de Cobranca
  PROCEDURE pc_grava_boleto( pr_rec_cobranca IN typ_rec_cobranca,    --> Dados da linha
                             pr_qtbloque     IN OUT INTEGER,         --> Quantidade de boletos 
                             pr_vlrtotal     IN OUT NUMBER,          --> Valor total dos boletos
                             pr_tab_crapcob  IN OUT NOCOPY typ_tab_crapcob, --> Tabela de Cobranca
                             pr_dscritic    OUT VARCHAR2             --> Descricao da critica
                            ) IS
                                   
  /* ............................................................................

       Programa: pc_grava_boleto    
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Dezembro/2015.                   Ultima atualizacao: 15/01/2018

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Gerar o registro do cabranca na PL TABLE

       Alteracoes: 13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 
                                
                   15/01/2018 - Ajustar para gravar o tipo de desconto no campo cdmensag (tipo de desconto)
                                (Douglas - Chamado 831413)                                
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    -- Identificacao da Cobranca
    vr_cdcooper   crapcob.cdcooper%TYPE;
    vr_nrdconta   crapcob.nrdconta%TYPE;
    vr_cdbandoc   crapcob.cdbandoc%TYPE;
    vr_nrdctabb   crapcob.nrdctabb%TYPE;
    vr_nrcnvcob   crapcob.nrcnvcob%TYPE;
    vr_nrbloque   crapcob.nrdocmto%TYPE;
    -- Indice da PL TABLE
    -- cdcooper (5) || nrdconta (10) || cdbandoc (5) || nrdctabb (10) || nrcnvcob (10) || nrdocmto (10)
    vr_index      VARCHAR2(50);

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
  BEGIN
    vr_cdcooper := pr_rec_cobranca.cdcooper;
    vr_nrdconta := pr_rec_cobranca.nrdconta;
    vr_cdbandoc := pr_rec_cobranca.cdbandoc;
    vr_nrdctabb := pr_rec_cobranca.nrdctabb;
    vr_nrcnvcob := pr_rec_cobranca.nrcnvcob;
    vr_nrbloque := pr_rec_cobranca.nrbloque;
    -- cdcooper (5) || nrdconta (10) || cdbandoc (5) || nrdctabb (10) || nrcnvcob (10) || nrdocmto (10)
    vr_index := lpad(vr_cdcooper, 5,'0') ||
                lpad(vr_nrdconta,10,'0') ||
                lpad(vr_cdbandoc, 5,'0') ||
                lpad(vr_nrdctabb,10,'0') ||
                lpad(vr_nrcnvcob,10,'0') ||
                lpad(vr_nrbloque,10,'0');
    
    IF pr_tab_crapcob.exists(vr_index) THEN
      RAISE vr_exc_saida;
    END IF;
    
    OPEN cr_crapcob(pr_cdcooper => vr_cdcooper,
                    pr_nrdconta => vr_nrdconta,
                    pr_cdbandoc => vr_cdbandoc,
                    pr_nrdctabb => vr_nrdctabb,
                    pr_nrcnvcob => vr_nrcnvcob,
                    pr_nrdocmto => vr_nrbloque);
    FETCH cr_crapcob INTO rw_crapcob;
    
    IF cr_crapcob%FOUND THEN
      CLOSE cr_crapcob;
      /* Se o boleto possuir informacao de "LIQAPOSBX" e o cobranca
         nao entrou o boleto deve adicionado para ser processado */
      IF NOT (rw_crapcob.dsinform LIKE 'LIQAPOSBX%' AND 
              rw_crapcob.incobran = 0) THEN 
        RAISE vr_exc_saida;        
      END IF;
    ELSE
      CLOSE cr_crapcob;
    END IF;
    
    -- Adicionar o titulo na tabela de cobraca
    pr_tab_crapcob(vr_index).cdcooper := pr_rec_cobranca.cdcooper;
    pr_tab_crapcob(vr_index).dtmvtolt := pr_rec_cobranca.dtmvtolt;
    pr_tab_crapcob(vr_index).incobran := 0;
    pr_tab_crapcob(vr_index).nrdconta := pr_rec_cobranca.nrdconta;
    pr_tab_crapcob(vr_index).nrdctabb := pr_rec_cobranca.nrdctabb;
    pr_tab_crapcob(vr_index).cdbandoc := pr_rec_cobranca.cdbandoc;
    pr_tab_crapcob(vr_index).nrdocmto := pr_rec_cobranca.nrbloque;
    pr_tab_crapcob(vr_index).nrcnvcob := pr_rec_cobranca.nrcnvcob;
    pr_tab_crapcob(vr_index).dtretcob := pr_rec_cobranca.dtemscob;
    pr_tab_crapcob(vr_index).dsdoccop := pr_rec_cobranca.dsdoccop;
    pr_tab_crapcob(vr_index).vltitulo := pr_rec_cobranca.vltitulo;
    pr_tab_crapcob(vr_index).vldescto := pr_rec_cobranca.vldescto;
    pr_tab_crapcob(vr_index).cdmensag := pr_rec_cobranca.tpdescto;
    pr_tab_crapcob(vr_index).dtvencto := pr_rec_cobranca.dtvencto;
    pr_tab_crapcob(vr_index).cdcartei := pr_rec_cobranca.cdcartei;
    pr_tab_crapcob(vr_index).cddespec := pr_rec_cobranca.cddespec;
    pr_tab_crapcob(vr_index).cdtpinsc := pr_rec_cobranca.cdtpinsc;
    pr_tab_crapcob(vr_index).nrinssac := pr_rec_cobranca.nrinssac;
    pr_tab_crapcob(vr_index).nmdsacad := pr_rec_cobranca.nmdsacad;
    pr_tab_crapcob(vr_index).dsendsac := pr_rec_cobranca.dsendsac;
    pr_tab_crapcob(vr_index).nmbaisac := pr_rec_cobranca.nmbaisac;
    pr_tab_crapcob(vr_index).nmcidsac := pr_rec_cobranca.nmcidsac;
    pr_tab_crapcob(vr_index).cdufsaca := pr_rec_cobranca.cdufsaca;
    pr_tab_crapcob(vr_index).nrcepsac := pr_rec_cobranca.nrcepsac;
    pr_tab_crapcob(vr_index).nmdavali := pr_rec_cobranca.nmdavali;
    pr_tab_crapcob(vr_index).nrinsava := pr_rec_cobranca.nrinsava;
    pr_tab_crapcob(vr_index).cdtpinav := pr_rec_cobranca.cdtpinav;
    pr_tab_crapcob(vr_index).dsdinstr := fn_remove_chr_especial(pr_rec_cobranca.dsdinstr);
    pr_tab_crapcob(vr_index).dsusoemp := pr_rec_cobranca.dsusoemp;
    pr_tab_crapcob(vr_index).nrremass := pr_rec_cobranca.nrremass;
    pr_tab_crapcob(vr_index).flgregis := pr_rec_cobranca.flgregis;
    pr_tab_crapcob(vr_index).cdimpcob := 2;
    pr_tab_crapcob(vr_index).flgimpre := 1; -- TRUE
    pr_tab_crapcob(vr_index).nrnosnum := pr_rec_cobranca.dsnosnum;
    pr_tab_crapcob(vr_index).dtdocmto := pr_rec_cobranca.dtemscob;
    pr_tab_crapcob(vr_index).tpjurmor := pr_rec_cobranca.tpdjuros;
    pr_tab_crapcob(vr_index).vljurdia := pr_rec_cobranca.vldjuros;
    pr_tab_crapcob(vr_index).tpdmulta := pr_rec_cobranca.tpdmulta;
    pr_tab_crapcob(vr_index).vlrmulta := pr_rec_cobranca.vldmulta;
    pr_tab_crapcob(vr_index).inemiten := pr_rec_cobranca.inemiten;
    pr_tab_crapcob(vr_index).flgdprot := pr_rec_cobranca.flgdprot;
	pr_tab_crapcob(vr_index).insrvprt := pr_rec_cobranca.insrvprt;
    pr_tab_crapcob(vr_index).flgaceit := pr_rec_cobranca.flgaceit;
    pr_tab_crapcob(vr_index).idseqttl := 1;
    pr_tab_crapcob(vr_index).cdoperad := '996';
    pr_tab_crapcob(vr_index).qtdiaprt := pr_rec_cobranca.qtdiaprt;
    pr_tab_crapcob(vr_index).inemiexp := pr_rec_cobranca.inemiexp;
    pr_tab_crapcob(vr_index).vlminimo := pr_rec_cobranca.vlminimo;
    pr_tab_crapcob(vr_index).inpagdiv := pr_rec_cobranca.inpagdiv;
    pr_tab_crapcob(vr_index).inenvcip := pr_rec_cobranca.inenvcip;
	pr_tab_crapcob(vr_index).inserasa := pr_rec_cobranca.inserasa;
    pr_tab_crapcob(vr_index).flserasa := pr_rec_cobranca.flserasa;
    pr_tab_crapcob(vr_index).qtdianeg := pr_rec_cobranca.qtdianeg;

    pr_tab_crapcob(vr_index).inavisms := pr_rec_cobranca.inavisms;
    pr_tab_crapcob(vr_index).insmsant := pr_rec_cobranca.insmsant;
    pr_tab_crapcob(vr_index).insmsvct := pr_rec_cobranca.insmsvct;
    pr_tab_crapcob(vr_index).insmspos := pr_rec_cobranca.insmspos;
    pr_tab_crapcob(vr_index).vlabatim := pr_rec_cobranca.vlabatim;
    -- Atualizar os totalizadores
    pr_qtbloque := pr_qtbloque + 1;
    pr_vlrtotal := pr_vlrtotal + NVL(pr_rec_cobranca.vltitulo, 0);
    
  EXCEPTION 
    WHEN vr_exc_saida THEN
      -- Nao eh erro, apenas para a execucao
      NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral na COBR0006.pc_grava_boleto -> ' || SQLERRM;
  END pc_grava_boleto;

  --> Gravar Instrucoes -> Gerar registro na PL TABLE de Intrucoes
  PROCEDURE pc_grava_instrucao( pr_rec_cobranca  IN typ_rec_cobranca,      --> Dados da linha
                                pr_tab_instrucao IN OUT NOCOPY typ_tab_instrucao, --> Tabela de Instrucoes
                                pr_dscritic      OUT VARCHAR2              --> Descricao da critica
                              ) IS
                                   
  /* ............................................................................

       Programa: pc_grava_instrucao                                            antiga:b1wgen0090/p_grava_instrucao
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Dezembro/2015.                   Ultima atualizacao: 13/02/2017 

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Gravar as instrucoes do processo

       Alteracoes: 13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    vr_index INTEGER;

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
  BEGIN
    vr_index := pr_tab_instrucao.COUNT() + 1;
    
    pr_tab_instrucao(vr_index).cdcooper := pr_rec_cobranca.cdcooper;
    pr_tab_instrucao(vr_index).nrdconta := pr_rec_cobranca.nrdconta;
    pr_tab_instrucao(vr_index).nrcnvcob := pr_rec_cobranca.nrcnvcob;
    pr_tab_instrucao(vr_index).nrdocmto := pr_rec_cobranca.nrbloque;
    pr_tab_instrucao(vr_index).nrremass := pr_rec_cobranca.nrremass;
    pr_tab_instrucao(vr_index).cdocorre := pr_rec_cobranca.cdocorre;
    pr_tab_instrucao(vr_index).vltitulo := pr_rec_cobranca.vltitulo;
    pr_tab_instrucao(vr_index).vldescto := pr_rec_cobranca.vldescto;
    pr_tab_instrucao(vr_index).vlabatim := pr_rec_cobranca.vlabatim;
    pr_tab_instrucao(vr_index).dtvencto := pr_rec_cobranca.dtvencto;
    pr_tab_instrucao(vr_index).nrnosnum := pr_rec_cobranca.dsnosnum;
    pr_tab_instrucao(vr_index).nrinssac := pr_rec_cobranca.nrinssac;
    pr_tab_instrucao(vr_index).dsendsac := pr_rec_cobranca.dsendsac;
    pr_tab_instrucao(vr_index).nmbaisac := pr_rec_cobranca.nmbaisac;
    pr_tab_instrucao(vr_index).nrcepsac := pr_rec_cobranca.nrcepsac;
    pr_tab_instrucao(vr_index).nmcidsac := pr_rec_cobranca.nmcidsac;
    pr_tab_instrucao(vr_index).cdufsaca := pr_rec_cobranca.cdufsaca;
    pr_tab_instrucao(vr_index).cdbandoc := pr_rec_cobranca.cdbandoc; 
    pr_tab_instrucao(vr_index).nrdctabb := pr_rec_cobranca.nrdctabb;
    pr_tab_instrucao(vr_index).qtdiaprt := pr_rec_cobranca.qtdiaprt;
    pr_tab_instrucao(vr_index).dsdoccop := pr_rec_cobranca.dsdoccop;
    pr_tab_instrucao(vr_index).inemiten := pr_rec_cobranca.inemiten;
    pr_tab_instrucao(vr_index).dtemscob := pr_rec_cobranca.dtemscob; 
    pr_tab_instrucao(vr_index).nrcelsac := pr_rec_cobranca.nrcelsac;
    pr_tab_instrucao(vr_index).inavisms := pr_rec_cobranca.inavisms;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral na COBR0006.pc_grava_instrucao -> ' || SQLERRM;
  END pc_grava_instrucao;

  --> Gravar Rejeitados -> Gerar registro na PL TABLE de Rejeitados
  PROCEDURE pc_grava_rejeitado(pr_cdcooper      IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                              ,pr_nrdconta      IN crapass.nrdconta%TYPE --> Numero da Conta
                              ,pr_nrcnvcob      IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                              ,pr_vltitulo      IN crapcob.vltitulo%TYPE --> Valor do Titulo
                              ,pr_cdbcoctl      IN crapcop.cdbcoctl%TYPE --> Codigo do banco na central
                              ,pr_cdagectl      IN crapcop.cdagectl%TYPE --> Codigo da Agencial na central
                              ,pr_nrnosnum      IN crapcob.nrnosnum%TYPE --> Nosso Numero
                              ,pr_dsdoccop      IN crapcob.dsdoccop%TYPE --> Descricao do Documento
                              ,pr_nrremass      IN crapcob.nrremass%TYPE --> Numero da Remessa
                              ,pr_dtvencto      IN crapcob.dtvencto%TYPE --> Data de Vencimento
                              ,pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                              ,pr_cdoperad      IN crapope.cdoperad%TYPE --> Operador
                              ,pr_cdocorre      IN INTEGER               --> Codigo da Ocorrencia
                              ,pr_cdmotivo      IN VARCHAR2              --> Motivo da Rejeicao
                              ,pr_tab_rejeitado IN OUT NOCOPY typ_tab_rejeitado  --> Tabela de Rejeitados
                              ) IS
                                   
  /* ............................................................................

       Programa: pc_grava_rejeitado    
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Dezembro/2015.                   Ultima atualizacao: 13/02/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Gravar os rejeitados do processo

       Alteracoes: 13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    vr_index INTEGER;

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
  BEGIN
    vr_index := pr_tab_rejeitado.COUNT() + 1;
    
    pr_tab_rejeitado(vr_index).cdcooper := pr_cdcooper;
    pr_tab_rejeitado(vr_index).nrdconta := pr_nrdconta;
    pr_tab_rejeitado(vr_index).nrcnvcob := pr_nrcnvcob;
    pr_tab_rejeitado(vr_index).dtmvtolt := pr_dtmvtolt;
    pr_tab_rejeitado(vr_index).nmarqrtc := 'cobret' || to_char(pr_dtmvtolt,'mmdd');
    pr_tab_rejeitado(vr_index).dtaltera := pr_dtmvtolt;
    pr_tab_rejeitado(vr_index).nmarqcre := 'ret085' || to_char(pr_dtmvtolt,'mmdd');
    pr_tab_rejeitado(vr_index).cdoperad := pr_cdoperad;
    pr_tab_rejeitado(vr_index).cdocorre := pr_cdocorre;
    pr_tab_rejeitado(vr_index).cdmotivo := pr_cdmotivo;
    pr_tab_rejeitado(vr_index).vltitulo := pr_vltitulo;
    pr_tab_rejeitado(vr_index).cdbcorec := pr_cdbcoctl;
    pr_tab_rejeitado(vr_index).cdagerec := pr_cdagectl;
    pr_tab_rejeitado(vr_index).dtocorre := pr_dtmvtolt;
    pr_tab_rejeitado(vr_index).nrnosnum := pr_nrnosnum;
    pr_tab_rejeitado(vr_index).dsdoccop := pr_dsdoccop;
    pr_tab_rejeitado(vr_index).nrremass := pr_nrremass;
    pr_tab_rejeitado(vr_index).dtvencto := pr_dtvencto;
  END pc_grava_rejeitado;

  --> Valida a ocorrencia para Gravar Rejeitados -> Gerar registro na PL TABLE de Rejeitados
  PROCEDURE pc_valida_grava_rejeitado(pr_cdcooper      IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                     ,pr_nrdconta      IN crapass.nrdconta%TYPE --> Numero da Conta
                                     ,pr_nrcnvcob      IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                     ,pr_vltitulo      IN crapcob.vltitulo%TYPE --> Valor do Titulo
                                     ,pr_cdbcoctl      IN crapcop.cdbcoctl%TYPE --> Codigo do banco na central
                                     ,pr_cdagectl      IN crapcop.cdagectl%TYPE --> Codigo da Agencial na central
                                     ,pr_nrnosnum      IN crapcob.nrnosnum%TYPE --> Nosso Numero
                                     ,pr_dsdoccop      IN crapcob.dsdoccop%TYPE --> Descricao do Documento
                                     ,pr_nrremass      IN crapcob.nrremass%TYPE --> Numero da Remessa
                                     ,pr_dtvencto      IN crapcob.dtvencto%TYPE --> Data de Vencimento
                                     ,pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                     ,pr_cdoperad      IN crapope.cdoperad%TYPE --> Operador
                                     ,pr_cdocorre      IN INTEGER               --> Codigo da Ocorrencia
                                     ,pr_cdmotivo      IN VARCHAR2              --> Motivo da Rejeicao
                                     ,pr_tab_rejeitado IN OUT NOCOPY typ_tab_rejeitado --> Tabela de Rejeitados
                                     ) IS
                                   
  /* ............................................................................

       Programa: pc_valida_grava_rejeitado    
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Dezembro/2015.                   Ultima atualizacao: 13/02/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : verificar qual ocorrencia gerar a rejeicao

       Alteracoes: 13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    vr_cdocorre INTEGER;

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
  BEGIN
    IF pr_cdmotivo = 'S3' OR pr_cdmotivo = 'S4' THEN
      
      -- Inconsistencia Negativacao Serasa
      vr_cdocorre := 92;      
    
    ELSIF pr_cdocorre = 1 THEN
      -- Gerar Rejeicao com Ocorrencia 03 - Entrada Rejeitada
      vr_cdocorre := 03;
    ELSE
      -- Gerar Rejeicao com Ocorrencia 26 - Instrucao Rejeitada 
      vr_cdocorre := 26;
    END IF;
    
    -- Rejeitou a cobranca e nao deve continuar o processamento
    pc_grava_rejeitado(pr_cdcooper      => pr_cdcooper        --> Codigo da Cooperativa
                      ,pr_nrdconta      => pr_nrdconta        --> Numero da Conta
                      ,pr_nrcnvcob      => pr_nrcnvcob        --> Numero do Convenio
                      ,pr_vltitulo      => pr_vltitulo        --> Valor do Titulo
                      ,pr_cdbcoctl      => pr_cdbcoctl        --> Codigo do banco na central
                      ,pr_cdagectl      => pr_cdagectl        --> Codigo da Agencial na central
                      ,pr_nrnosnum      => pr_nrnosnum        --> Nosso Numero
                      ,pr_dsdoccop      => pr_dsdoccop        --> Descricao do Documento
                      ,pr_nrremass      => pr_nrremass        --> Numero da Remessa
                      ,pr_dtvencto      => pr_dtvencto        --> Data de Vencimento
                      ,pr_dtmvtolt      => pr_dtmvtolt        --> Data de Movimento
                      ,pr_cdoperad      => pr_cdoperad        --> Operador
                      ,pr_cdocorre      => vr_cdocorre        --> Codigo da Ocorrencia
                      ,pr_cdmotivo      => pr_cdmotivo        --> Motivo da Rejeicao
                      ,pr_tab_rejeitado => pr_tab_rejeitado); --> Tabela de Rejeitados
    
  END pc_valida_grava_rejeitado;


  --> Gravar Sacado -> Gerar registro na PL TABLE de Sacados
  PROCEDURE pc_grava_sacado( pr_cdoperad     IN crapope.cdoperad%TYPE, --> Operador
                             pr_rec_cobranca IN typ_rec_cobranca,      --> Dados da linha
                             pr_tab_sacado   IN OUT NOCOPY typ_tab_sacado,    --> Tabela de Instrucoes
                             pr_dscritic        OUT VARCHAR2           --> Descricao da critica
                            ) IS                                  
  /* ............................................................................

       Programa: pc_grava_sacado                   antiga:b1wgen0090/p_grava_sacado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Janeiro/2016                     Ultima atualizacao: 13/02/2017 

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Gravar as informacoes do sacado

       Alteracoes: 25/11/2016 - Remover caracteres especial no nome do sacado (Gil Furtado - MOUTS)

	               13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 

    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    vr_index INTEGER;

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
  BEGIN
    vr_index := pr_tab_sacado.COUNT() + 1;
    
    pr_tab_sacado(vr_index).cdcooper := pr_rec_cobranca.cdcooper;
    pr_tab_sacado(vr_index).nrdconta := pr_rec_cobranca.nrdconta;
    pr_tab_sacado(vr_index).nmdsacad := gene0007.fn_caract_acento(pr_rec_cobranca.nmdsacad, 1, '@#$&%¹²³ªº°*!?<>/\|€', '                    ');
    pr_tab_sacado(vr_index).cdtpinsc := pr_rec_cobranca.cdtpinsc;
    pr_tab_sacado(vr_index).nrinssac := pr_rec_cobranca.nrinssac;
    pr_tab_sacado(vr_index).dsendsac := pr_rec_cobranca.dsendsac;
    pr_tab_sacado(vr_index).nrendsac := 0;
    pr_tab_sacado(vr_index).nmbaisac := pr_rec_cobranca.nmbaisac;
    pr_tab_sacado(vr_index).nmcidsac := pr_rec_cobranca.nmcidsac;
    pr_tab_sacado(vr_index).cdufsaca := pr_rec_cobranca.cdufsaca;
    pr_tab_sacado(vr_index).nrcepsac := pr_rec_cobranca.nrcepsac;
    pr_tab_sacado(vr_index).cdoperad := pr_cdoperad;
    pr_tab_sacado(vr_index).dtmvtolt := pr_rec_cobranca.dtmvtolt;
    pr_tab_sacado(vr_index).nrcelsac := pr_rec_cobranca.nrcelsac;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral na COBR0006.pc_grava_sacado -> ' || SQLERRM;
  END pc_grava_sacado;


  --> Rotina tem como objetivo efetuar a validacao de campos quando for comando de instrucao.
  PROCEDURE pc_valida_exec_instrucao ( pr_cdcooper     IN crapcop.cdcooper%TYPE,   --> Codigo da cooperativa
                                       pr_nrdconta     IN crapass.nrdconta%TYPE,   --> Numero da conta do cooperado
                                       pr_rec_header   IN typ_rec_header,          --> Header do Arquivo
                                       pr_tab_linhas   IN gene0009.typ_tab_campos, --> Dados da linha
                                       pr_cdocorre     IN NUMBER,                  --> Tipo de cocorrencia
                                       pr_tipocnab     IN VARCHAR2,                --> Tipo CNAB (240/400)
                                       pr_cdmotivo    OUT VARCHAR2                 --> Motivo
                                     ) IS
                                   
  /* ............................................................................

       Programa: pc_valida_exec_instrucao         antigo: b1wgen0090.p/valida-execucao-instrucao
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana - AMcom
       Data    : Novembro/2015.                   Ultima atualizacao: 17/03/2016

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina tem como objetvo efetuar a validacao de campos quando for comando de instrucao.

       Alteracoes: 25/11/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)
       
                   13/03/2016 - Decorrente a conversão da rotina de importação do arquivo CNAB400,
                                foi descomentado o código para trata-lo
                                (Andrei - RKAM).

				   27/05/2016 - Ajuste para considerar o caracter ":" ao chamar
								a rotina de validação de caracteres para endereços
								(Andrei). 

                   17/03/2017 - Removido a validação que verificava se o CEP do pagador do boleto existe no Ayllos. 
                                Solicitado pelo Leomir e aprovado pelo Victor (cobrança)
                               (Douglas - Chamado 601436)
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_motivo   EXCEPTION;
    vr_exc_saida    EXCEPTION;

    ------------------------------- CURSORES ---------------------------------    
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_dsnosnum  VARCHAR2(17);
    vr_nrdconta  INTEGER;
    vr_nrbloque  INTEGER;
    vr_stsnrcal  BOOLEAN;
    vr_inpessoa  INTEGER;
    vr_cdinstr1  INTEGER;
    vr_cdinstr2  INTEGER;
	vr_limitemin INTEGER;
    vr_limitemax INTEGER;
    vr_dsnegufds tbcobran_param_protesto.dsnegufds%TYPE;
    vr_cdufsaca crapcob.nmdsacad%TYPE;
    
    vr_des_erro  VARCHAR2(255);
    vr_dscritic  VARCHAR2(255);
    
  BEGIN
    --> Inicializa variaveis
    pr_cdmotivo:= '';
    
    -- Se for algum dos motivos abaixo, nao existe nenhuma validacao para ser feita
    IF pr_cdocorre IN (05, -- Cancelamento Concessao de Abatimento
                       08, -- Cancelamento Concessao de Desconto
                       10, -- Sustar Protesto e Baixar
                       11, -- Sustar Protesto e Mater em Carteira
                       41, -- Cancelar Protesto
                       93, -- Negativar Serasa
                       94  -- Cancelar negativacao Serasa
                       ) THEN
      RAISE vr_exc_saida;
    END IF;
    
    --Caso NOSSO NUMERO nao exista na linha qdo passar aqui devolve uma critica
    IF NOT pr_tab_linhas.exists('DSNOSNUM') THEN 
       -- Nosso Numero Invalido
       pr_cdmotivo := '08';
       RAISE vr_exc_motivo;       
    END IF;
    
    -- Formatar nosso numero com 17 posicoes para separa o numero da conta e o numero do boleto
    vr_dsnosnum := to_char(TRIM(pr_tab_linhas('DSNOSNUM').texto),'fm00000000000000000');
    vr_nrdconta := to_number(SUBSTR(vr_dsnosnum,1,8));
    vr_nrbloque := to_number(SUBSTR(vr_dsnosnum,9,9));

    -- Verifica se conta do cooperado confere com conta do nosso numero
    IF pr_nrdconta <> vr_nrdconta THEN
      -- Nosso Numero Invalido
      pr_cdmotivo := '08';
      RAISE vr_exc_motivo;
    END IF;
    
    -- Verifica Existencia Titulo
    OPEN cr_crapcob(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => vr_nrdconta,
                    pr_cdbandoc => pr_rec_header.cdbandoc,
                    pr_nrdctabb => pr_rec_header.nrdctabb,
                    pr_nrcnvcob => pr_rec_header.nrcnvcob,
                    pr_nrdocmto => vr_nrbloque);
                    
    FETCH cr_crapcob INTO rw_crapcob;
    -- Se nao encountrou a cobranca, gera erro
    IF cr_crapcob%NOTFOUND THEN
      
      CLOSE cr_crapcob;
      RAISE vr_exc_motivo;
    ELSE
      CLOSE cr_crapcob;
    END IF;

    -- Concessao de Abatimento
    IF pr_cdocorre = 04 THEN 
      IF ( pr_tab_linhas('VLABATIM').numero = 0 ) THEN
        -- Valor do Abatimento Invalido
        pr_cdmotivo := '33';
        RAISE vr_exc_motivo;
      END IF;
    END IF;
    
    -- Alteracao de Vencimento
    IF pr_cdocorre = 06 THEN
      IF TRIM(pr_tab_linhas('DTVENCTO').data) IS NULL THEN
        -- Data de Vencimento Invalida
        pr_cdmotivo := '16';
        RAISE vr_exc_motivo;
      END IF;
      
      IF ( pr_tab_linhas('DTVENCTO').data < TRUNC(SYSDATE) ) OR 
         ( pr_tab_linhas('DTVENCTO').data > TO_DATE('13/10/2049','DD/MM/RRRR') ) THEN 
        -- Vencimento Fora do Prazo de Operacao
        pr_cdmotivo := '18';
        RAISE vr_exc_motivo;
      END IF;
    END IF;
    
    -- Concessao de Desconto
    IF pr_cdocorre = 07 THEN
      IF pr_tab_linhas('VLDESCTO').numero = 0 THEN
        -- Desconto a Conceder Nao Confere
        pr_cdmotivo := '30';
        RAISE vr_exc_motivo;
      END IF;
      
      IF pr_tab_linhas('VLDESCTO').numero >= rw_crapcob.vltitulo THEN
        -- Valor do Desconto Maior ou Igual ao Valor do Titulo
        pr_cdmotivo := '29';
        RAISE vr_exc_motivo;
      END IF;
    END IF;
    
    -- Protestar
    IF pr_cdocorre = 09 THEN
	
	  tela_parprt.pc_consulta_periodo_parprt(pr_cdcooper => pr_cdcooper,
										     pr_qtlimitemin_tolerancia => vr_limitemin,
										     pr_qtlimitemax_tolerancia => vr_limitemax,
										     pr_des_erro => vr_des_erro,
										     pr_dscritic => vr_dscritic);
	
      IF (vr_des_erro <> 'OK') THEN
        pr_cdmotivo := '38';
        RAISE vr_exc_motivo;
      END IF;
    
      IF rw_crapcob.dtvencto >= TRUNC(SYSDATE) THEN
        -- Pedido de Protesto Nao Permitido para o Titulo
        pr_cdmotivo := '39';
        RAISE vr_exc_motivo;
      END IF;
      
      IF pr_tipocnab = '240' THEN -- CNAB 240
        -- Validar o Codigo de Protesto
        IF pr_tab_linhas('CDDPROTE').numero <> 1 THEN
          -- Codigo para Protesto Invalido
          pr_cdmotivo := '37';
          RAISE vr_exc_motivo;
        END IF;
        
        -- Valida Prazo para Protesto
        IF pr_rec_header.cdbandoc = 085 THEN
          -- Prazo para protesto valido de X a Y dias
          IF pr_tab_linhas('QTDIAPRT').numero < vr_limitemin OR
             pr_tab_linhas('QTDIAPRT').numero > vr_limitemax THEN
            -- Prazo para Protesto Invalido
            pr_cdmotivo := '38';
            RAISE vr_exc_motivo;
          END IF;
        ELSE
        -- Prazo para protesto valido de 5 a 15 dias
        IF pr_tab_linhas('QTDIAPRT').numero < 5  OR
           pr_tab_linhas('QTDIAPRT').numero > 15 THEN
          -- Prazo para Protesto Invalido
          pr_cdmotivo := '38';
          RAISE vr_exc_motivo;
        END IF;
        END IF;

        IF pr_rec_header.cdbandoc = 085 AND
           pr_tab_linhas('QTDIAPRT').numero <> 0 AND
           pr_tab_linhas('CDDESPEC').numero = 2 /*DS*/ THEN
             vr_cdufsaca := pr_tab_linhas('CDUFSACA').texto;
      
             tela_parprt.pc_validar_dsnegufds_parprt(pr_cdcooper => pr_cdcooper,
                                                      pr_cdufsaca => vr_cdufsaca,
                                                      pr_des_erro => vr_des_erro,	
                                                      pr_dscritic => vr_dscritic);
              
             IF (vr_des_erro <> 'OK') THEN
               --Pedido de Protesto Não Permitido para o Título
               pr_cdmotivo := '39';
               RAISE vr_exc_motivo;
             END IF; 
        END IF;
        
      ELSE -- CNAB 400
        -- Definido pelo Rafael que instrucao de protesto deve ser apenas em dias corridos
        vr_cdinstr1 := pr_tab_linhas('INSTCODI').numero;
        vr_cdinstr2 := pr_tab_linhas('INSTCODI2').numero;       
        
        --Indica Protesto em dias corridos
        IF vr_cdinstr1 <> 6 AND
           vr_cdinstr2 <> 6 THEN
           
          --Codigo de Protesto Invalido 
          pr_cdmotivo := '37';
          RAISE vr_exc_motivo;  
        
        ELSE
         
          -- Valida Prazo para Protesto
          IF pr_rec_header.cdbandoc = 085 THEN
            -- Prazo para protesto valido de X a Y dias
            IF pr_tab_linhas('NRDIAPRT').numero < vr_limitemin OR
               pr_tab_linhas('NRDIAPRT').numero > vr_limitemax THEN
              -- Prazo para Protesto Invalido
              pr_cdmotivo := '38';
              RAISE vr_exc_motivo;
            END IF; 
          ELSE
          -- Prazo para protesto valido de 5 a 15 dias
          IF pr_tab_linhas('NRDIAPRT').numero < 5  OR
             pr_tab_linhas('NRDIAPRT').numero > 15 THEN
            -- Prazo para Protesto Invalido
            pr_cdmotivo := '38';
            RAISE vr_exc_motivo;
          END IF; 
          END IF;
        
          IF pr_rec_header.cdbandoc = 085 AND
             pr_tab_linhas('NRDIAPRT').numero <> 0 AND
             pr_tab_linhas('ESPTITUL').numero = 12 /*DS*/ THEN
             
             vr_cdufsaca := pr_tab_linhas('UFSACADO').texto;
             
             tela_parprt.pc_validar_dsnegufds_parprt(pr_cdcooper => pr_cdcooper,
                                                     pr_cdufsaca => vr_cdufsaca,
                                                     pr_des_erro => vr_des_erro,	
                                                     pr_dscritic => vr_dscritic);
        
              IF (vr_des_erro <> 'OK') THEN
                --Espécie de título inválida para carteira
                pr_cdmotivo := '05';
                RAISE vr_exc_motivo;
        END IF;
          END IF;
        
        END IF;
               
      END IF;
      
    END IF;
    
    -- Alteracao de Outros Dados
    IF pr_cdocorre = 31 THEN
      
      --  Valida Tipo de Inscricao
      IF pr_tab_linhas('INPESSOA').numero <> 1 AND 
         pr_tab_linhas('INPESSOA').numero <> 2 THEN
        -- Tipo/Numero de Inscricao do Sacado Invalidos
        pr_cdmotivo := '46';
        RAISE vr_exc_motivo;
      END IF;
        
      -- 09.3Q Valida Numero de Inscricao
      gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_tab_linhas('NRCPFCGC').numero, 
                                  pr_stsnrcal => vr_stsnrcal, 
                                  pr_inpessoa => vr_inpessoa);
      -- Verifica se o CPF/CNPJ esta correto
      IF NOT vr_stsnrcal THEN
        -- Tipo/Numero de Inscricao do Sacado Invalidos
        pr_cdmotivo := '46';
        RAISE vr_exc_motivo;
      END IF;
  
      -- Valida Endereco do Sacado
      IF TRIM(REPLACE(pr_tab_linhas('DSENDSAC').texto,',','')) IS NULL THEN
        -- Endereco do Sacado Nao Informado
        pr_cdmotivo := '47';
        RAISE vr_exc_motivo;
      END IF;
      
      -- Validar os caracteres do endereco do sacado
      IF fn_valida_caracteres(pr_flgnumer => TRUE,   -- Validar Numeros
                              pr_flgletra => TRUE,   -- Validar Letras
                              pr_listaesp => '',     -- Lista Caracteres Validos (incluir caracteres que sao validos apenas para este campo)
                              pr_dsvalida => REPLACE(pr_tab_linhas('DSENDSAC').texto,',','') ) THEN -- Endereco
        -- Endereco do Sacado Nao Informado
        pr_cdmotivo := '47';
        RAISE vr_exc_motivo;
      END IF;
      
      -- Validar se o CEP do Sacado foi informado, ou está zerado
      IF TRIM(pr_tab_linhas('NRCEPSAC').numero) IS NULL OR 
         NVL(pr_tab_linhas('NRCEPSAC').numero, 0) = 0 THEN
        
        --  CEP Invalido
        pr_cdmotivo := '48';
        RAISE vr_exc_motivo;
        
      END IF;
      
      -- Validar os caracteres do cep do sacado
      IF fn_valida_caracteres(pr_flgnumer => TRUE   -- Validar Numeros
                             ,pr_flgletra => FALSE  -- Validar Letras
                             ,pr_listaesp => ''     -- Lista Caracteres Validos
                             ,pr_dsvalida => pr_tab_linhas('NRCEPSAC').numero ) THEN -- CEP do Sacado
                              
        -- CEP invalido
        pr_cdmotivo := '48';
        RAISE vr_exc_motivo;
        
      END IF;
      
      
      
/* Nao sera mais validado se o CEP existe no sistema
   Chamado 601436 -> Solicitado por Leomir e autorizado pelo Victor Hugo Zimmerman
   
      -- Valida CEP do Sacado
      -- Pesquisar a Origem = CORREIOS
      OPEN cr_crapdne (pr_nrceplog => pr_tab_linhas('NRCEPSAC').numero,
                       pr_idoricad => 1); -- Correios
      FETCH cr_crapdne INTO rw_crapdne;
      IF cr_crapdne%NOTFOUND THEN
        CLOSE cr_crapdne;
        -- Se nao encontrou 
        -- Pesquisar a Origem = AYLLOS
        OPEN cr_crapdne(pr_nrceplog => pr_tab_linhas('NRCEPSAC').numero,
                        pr_idoricad => 2); -- Ayllos
        FETCH cr_crapdne INTO rw_crapdne;
      END IF;
      
      IF cr_crapdne%NOTFOUND THEN
        IF cr_crapdne%ISOPEN THEN
          CLOSE cr_crapdne;
        END IF;
      
        -- CEP Invalido
        pr_cdmotivo := '48';
        RAISE vr_exc_motivo;
      END IF;
      
      IF cr_crapdne%ISOPEN THEN
        CLOSE cr_crapdne;
      END IF;
*/

      /*
      IF pr_tab_linhas('CDUFSACA').texto <> rw_crapdne.cduflogr THEN
        --  CEP incompativel com a Unidade da Federacao
        pr_cdmotivo := '51';
        RAISE vr_exc_motivo;
      END IF;
	  */
    END IF;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Quando executar a saida, nao possui erro
      -- apenas aborta a execucao pois a ocorrencia nao possui validacao nenhuma
      NULL;
    WHEN vr_exc_motivo THEN
      -- Quando encontrar motivo, para a execucao para a inconsistencia encontrada
      NULL;
  
  END pc_valida_exec_instrucao;
  
  --> Procedure para processar os titulos que foram identificados no arquivo
  PROCEDURE pc_processa_titulos(pr_cdcooper    IN crapcop.cdcooper%TYPE, --> Codigo da Cooperativa
                                pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE, --> Data de Movimento
                                pr_cdoperad    IN crapope.cdoperad%TYPE, --> Operador
                                pr_tab_crapcob IN typ_tab_crapcob,       --> Tabela de Cobranca
                                pr_rec_header  IN typ_rec_header,        --> Dados do Header do Arquivo
                                pr_tab_lat_consolidada IN OUT NOCOPY PAGA0001.typ_tab_lat_consolidada, --> Tabela tarifas
                                pr_cdcritic   OUT INTEGER,               --> Codigo da Critica
                                pr_dscritic   OUT VARCHAR2               --> Descricao da Critica
                               ) IS
                                   
  /* ............................................................................

       Programa: pc_processa_titulos                                           antiga: b1wgen0090/p_processa_titulos
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Janeiro/2016                     Ultima atualizacao: 15/01/2018

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Processar os titulos que foram identificados no arquivo de 
                   remessa

       Alteracoes: 07/01/2016 - Conversão Progress -> Oracle (Douglas Quisinski)
       
                   02/12/2016 - Ajuste para tratar nome da cidade, nome do bairro e uf nulos 
  						               		(Andrei - RKAM).

                   29/12/2016 - P340 - Adição da chamada ao CRPS618 para envio de boletos a CIP 
  						               	  (Ricardo Linhares).                                
                                
				   13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 

                  14/07/2017 - Retirado verificação de pagador DDA e ROLLOUT. Essa verificação é
                               feita no pc_crps618. (Rafael)

                  21/08/2017 - Incluir vencto original (dtvctori) ao registrar o boleto. (Rafael)

                  15/01/2018 - Gravar o cdmensag (tipo de desconto) que foi carregado
                               (Douglas - Chamado 831413)                                
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_des_erro   VARCHAR2(5);

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_idx_cob    VARCHAR2(50);
    vr_idx_lat    VARCHAR2(60);
    vr_insitpro   INTEGER;
    vr_qtd_proc   INTEGER;
    vr_new_rowid  ROWID;
    vr_nrdconta crapcop.nrdconta%TYPE;
    vr_stprogra PLS_INTEGER; -- variável para chamada do crps618
    vr_infimsol PLS_INTEGER; -- variável para chamada do crps618     
    vr_inregcip   crapcob.inregcip%TYPE;
    
    -- Indicador do tipo de pessoa fisica/juridica
    vr_tppessoa VARCHAR2(1);
    -- Identificador de pagador DDA
    vr_flgsacad INTEGER;
    -- Motivo 
    vr_cdmotivo VARCHAR2(10);

  BEGIN
    vr_qtd_proc:= 0;
    -- Percorrer todos os titulos que foram identificados e realizar as validacoes necessarias
    vr_idx_cob := pr_tab_crapcob.FIRST;
    WHILE vr_idx_cob IS NOT NULL LOOP
      -- Contador para que seja comitado a cada 1000 registros
      vr_qtd_proc:= vr_qtd_proc + 1;
      
          OPEN cr_crapcob(pr_cdcooper => pr_tab_crapcob(vr_idx_cob).cdcooper,
                          pr_nrdconta => pr_tab_crapcob(vr_idx_cob).nrdconta,
                          pr_cdbandoc => pr_tab_crapcob(vr_idx_cob).cdbandoc,
                          pr_nrdctabb => pr_tab_crapcob(vr_idx_cob).nrdctabb,
                          pr_nrcnvcob => pr_tab_crapcob(vr_idx_cob).nrcnvcob,
                          pr_nrdocmto => pr_tab_crapcob(vr_idx_cob).nrdocmto);
          FETCH cr_crapcob INTO rw_crapcob;
          
          IF cr_crapcob%FOUND THEN
            CLOSE cr_crapcob;
            -- validar se o boleto possui "LIQAPOSBX" e se incobran ainda nao foi processado 
            IF rw_crapcob.dsinform LIKE 'LIQAPOSBX%' AND 
               rw_crapcob.incobran = 0 THEN
              -- Pega o boleto atual e exclui para que seja criado novamente com as informacoes atualizadas
              DELETE FROM crapcob WHERE crapcob.rowid = rw_crapcob.rowid;
            ELSE
              COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid,
                                                 pr_cdocorre => 3,    -- Entrada Rejeitada
                                                 pr_cdmotivo => '63', -- Entrada para Titulo ja Cadastrado
                                                 pr_vltarifa => 0,
                                                 pr_cdbcoctl => pr_rec_header.cdbcoctl,
                                                 pr_cdagectl => pr_rec_header.cdagectl,
                                                 pr_dtmvtolt => pr_dtmvtolt,
                                                 pr_cdoperad => pr_cdoperad,
                                                 pr_nrremass => pr_rec_header.nrremass,
                                                 pr_cdcritic => vr_cdcritic,
                                                 pr_dscritic => vr_dscritic);

              -- Se ocorreu critica escreve no proc_message.log
              -- Não para o processo
              IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper                     
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                          ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                              ' - COBR0006 --> pc_processa_titulos' ||
                                                              ' Coop: '      || pr_tab_crapcob(vr_idx_cob).cdcooper ||
                                                              ' Conta: '     || pr_tab_crapcob(vr_idx_cob).nrdconta ||
                                                              ' Remessa: '   || pr_rec_header.nrremass ||
                                                              ' Convenio: '  || pr_rec_header.nrcnvcob ||
                                                              ' Nosso Num.:' || pr_tab_crapcob(vr_idx_cob).nrnosnum ||
                                                              ' ROWID: '     || rw_crapcob.rowid ||
                                                              ' - ERRO: '    || NVL(vr_cdcritic,0) || 
                                                              ' - ' || NVL(vr_dscritic,''));
                vr_cdcritic:= NULL;
                vr_dscritic:= NULL;
              END IF;
                                                 
              CONTINUE;
            END IF;
          ELSE 
            CLOSE cr_crapcob;
          END IF;
      
      IF pr_tab_crapcob(vr_idx_cob).flgregis = 1 THEN
        vr_insitpro := 1;
      ELSE 
        vr_insitpro := 0;
      END IF;
          
      -- se o convenio do cooperado possuir registro online
      -- devera gravar o boleto com registro online;
      IF pr_rec_header.flgregon = 1 THEN
        -- Verificar se eh Cooperativa Emite e Expede
        IF pr_tab_crapcob(vr_idx_cob).inemiten = 3 THEN
          vr_inregcip := 2; -- Registro via batch
        ELSE
          vr_inregcip := 1; -- Registro ONLINE
        END IF;
      ELSE
        vr_inregcip := 2; -- Registro via batch
      END IF;
          
      -- Insere o registro de cobranca
      INSERT INTO crapcob
               (cdcooper,
                dtmvtolt,
                incobran,
                nrdconta,
                nrdctabb,
                cdbandoc,
                nrdocmto,
                nrcnvcob,
                dtretcob,
                dsdoccop,
                vltitulo,
                vldescto,
                cdmensag,
                dtvencto,
                cdcartei,
                cddespec,
                cdtpinsc,
                nrinssac,
                nmdsacad,
                dsendsac,
                nmbaisac,
                nmcidsac,
                cdufsaca,
                nrcepsac,
                nmdavali,
                nrinsava,
                cdtpinav,
                dsinform, --dsdinstr --> Conforme chamado 564818, deve gravar a informacao no campo dsinform para correto envio a PG
                dsusoemp,
                nrremass,
                flgregis,
                cdimpcob,
                flgimpre,
                nrnosnum,
                dtdocmto,
                tpjurmor,
                vljurdia,
                tpdmulta,
                vlrmulta,
                inemiten,
                flgdprot,
				        insrvprt,
                flgaceit,
                idseqttl,
                cdoperad,
                qtdiaprt,
                inemiexp,
                -- Campos com valor FIXO
                idopeleg,
                idtitleg,
                flgcbdda,
                insitpro,
                flserasa,
                qtdianeg,
                inserasa,
                inavisms,
                insmsant,
                insmsvct,
                insmspos,
                vlminimo,
                inpagdiv,                
                inenvcip,
                inregcip,
                dtvctori,
                vlabatim
                )
        VALUES (pr_tab_crapcob(vr_idx_cob).cdcooper,
                pr_tab_crapcob(vr_idx_cob).dtmvtolt,
                pr_tab_crapcob(vr_idx_cob).incobran,
                pr_tab_crapcob(vr_idx_cob).nrdconta,
                pr_tab_crapcob(vr_idx_cob).nrdctabb,
                pr_tab_crapcob(vr_idx_cob).cdbandoc,
                pr_tab_crapcob(vr_idx_cob).nrdocmto,
                pr_tab_crapcob(vr_idx_cob).nrcnvcob,
                pr_tab_crapcob(vr_idx_cob).dtretcob,
                pr_tab_crapcob(vr_idx_cob).dsdoccop,
                pr_tab_crapcob(vr_idx_cob).vltitulo,
                pr_tab_crapcob(vr_idx_cob).vldescto,
                nvl(pr_tab_crapcob(vr_idx_cob).cdmensag,0),
                pr_tab_crapcob(vr_idx_cob).dtvencto,
                pr_tab_crapcob(vr_idx_cob).cdcartei,
                pr_tab_crapcob(vr_idx_cob).cddespec,
                pr_tab_crapcob(vr_idx_cob).cdtpinsc,
                pr_tab_crapcob(vr_idx_cob).nrinssac,
                pr_tab_crapcob(vr_idx_cob).nmdsacad,
                pr_tab_crapcob(vr_idx_cob).dsendsac,
                nvl(trim(pr_tab_crapcob(vr_idx_cob).nmbaisac),' '),
                nvl(trim(pr_tab_crapcob(vr_idx_cob).nmcidsac),' '),
                nvl(trim(pr_tab_crapcob(vr_idx_cob).cdufsaca),' '),
                pr_tab_crapcob(vr_idx_cob).nrcepsac,
                nvl(trim(pr_tab_crapcob(vr_idx_cob).nmdavali),' '),
                nvl(pr_tab_crapcob(vr_idx_cob).nrinsava,0),
                nvl(pr_tab_crapcob(vr_idx_cob).cdtpinav,0),
                nvl(trim(pr_tab_crapcob(vr_idx_cob).dsdinstr),' '),
                pr_tab_crapcob(vr_idx_cob).dsusoemp,
                pr_tab_crapcob(vr_idx_cob).nrremass,
                pr_tab_crapcob(vr_idx_cob).flgregis,
                pr_tab_crapcob(vr_idx_cob).cdimpcob,
                pr_tab_crapcob(vr_idx_cob).flgimpre,
                pr_tab_crapcob(vr_idx_cob).nrnosnum,
                pr_tab_crapcob(vr_idx_cob).dtdocmto,
                nvl(pr_tab_crapcob(vr_idx_cob).tpjurmor,3),
                pr_tab_crapcob(vr_idx_cob).vljurdia,
                pr_tab_crapcob(vr_idx_cob).tpdmulta,
                pr_tab_crapcob(vr_idx_cob).vlrmulta,
                pr_tab_crapcob(vr_idx_cob).inemiten,
                pr_tab_crapcob(vr_idx_cob).flgdprot,
				        pr_tab_crapcob(vr_idx_cob).insrvprt,
                pr_tab_crapcob(vr_idx_cob).flgaceit,
                pr_tab_crapcob(vr_idx_cob).idseqttl,
                pr_tab_crapcob(vr_idx_cob).cdoperad,
                nvl(pr_tab_crapcob(vr_idx_cob).qtdiaprt,0),
                nvl(pr_tab_crapcob(vr_idx_cob).inemiexp,0),
                0, -- idopeleg
                0, -- idtitleg
                0, -- flgcbdda (FALSE)
                vr_insitpro,
                pr_tab_crapcob(vr_idx_cob).flserasa,
                pr_tab_crapcob(vr_idx_cob).qtdianeg,
                pr_tab_crapcob(vr_idx_cob).inserasa,
                pr_tab_crapcob(vr_idx_cob).inavisms,
                pr_tab_crapcob(vr_idx_cob).insmsant,
                pr_tab_crapcob(vr_idx_cob).insmsvct,
                pr_tab_crapcob(vr_idx_cob).insmspos,
                pr_tab_crapcob(vr_idx_cob).vlminimo,
                pr_tab_crapcob(vr_idx_cob).inpagdiv,
                pr_tab_crapcob(vr_idx_cob).inenvcip,
                vr_inregcip,
                pr_tab_crapcob(vr_idx_cob).dtvencto,
                nvl(pr_tab_crapcob(vr_idx_cob).vlabatim,0)
                )
        RETURNING ROWID INTO vr_new_rowid;
      
      IF pr_tab_crapcob(vr_idx_cob).flgregis = 1 THEN      
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => vr_new_rowid,
                                      pr_cdoperad => pr_cdoperad,
                                      pr_dtmvtolt => pr_dtmvtolt,
                                      pr_dsmensag => 'Boleto integrado por arquivo com sequencial ' ||
                                                     to_char(pr_rec_header.nrremass) ||
                                                     ' - Emissao ' ||
                                                     to_char(pr_tab_crapcob(vr_idx_cob).dtdocmto,'dd/mm/RRRR'),
                                      pr_des_erro => vr_des_erro,
                                      pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - COBR0006 --> pc_processa_titulos' ||
                                                        ' Coop: '      || pr_tab_crapcob(vr_idx_cob).cdcooper ||
                                                        ' Conta: '     || pr_tab_crapcob(vr_idx_cob).nrdconta ||
                                                        ' Remessa: '   || pr_rec_header.nrremass ||
                                                        ' Convenio: '  || pr_rec_header.nrcnvcob ||
                                                        ' Nosso Num.:' || pr_tab_crapcob(vr_idx_cob).nrnosnum ||
                                                        ' ROWID: '     || vr_new_rowid ||
                                                        ' - ERRO: '    || NVL(vr_dscritic,''));
          vr_des_erro:= NULL;
          vr_dscritic:= NULL;
        END IF;
        
        -- Caso o tip de emissao seja cooperativa emite e expede deve gerar log para a tela cobran
        IF pr_tab_crapcob(vr_idx_cob).cdbandoc = 085 AND
           pr_tab_crapcob(vr_idx_cob).inemiten = 3   THEN
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => vr_new_rowid,
                                        pr_cdoperad => pr_cdoperad,
                                        pr_dtmvtolt => pr_dtmvtolt,
                                        pr_dsmensag => 'Titulo a enviar para PG',
                                        pr_des_erro => vr_des_erro,
                                        pr_dscritic => vr_dscritic);
          -- Verifica se ocorreu erro
          IF vr_des_erro <> 'OK' THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                      ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                          ' - COBR0006 --> pc_processa_titulos' ||
                                                          ' Coop: '      || pr_tab_crapcob(vr_idx_cob).cdcooper ||
                                                          ' Conta: '     || pr_tab_crapcob(vr_idx_cob).nrdconta ||
                                                          ' Remessa: '   || pr_rec_header.nrremass ||
                                                          ' Convenio: '  || pr_rec_header.nrcnvcob ||
                                                          ' Nosso Num.:' || pr_tab_crapcob(vr_idx_cob).nrnosnum ||
                                                          ' ROWID: '     || vr_new_rowid ||
                                                          ' - ERRO: '    || NVL(vr_dscritic,''));
            vr_des_erro:= NULL;
            vr_dscritic:= NULL;
          END IF;
        END IF;
        
        -- se o sacado nao for DDA, confirmar registro do titulo, 
        -- pois quando o sacado eh DDA, a confirmacao eh realizada
        -- pelo programa crps618.p
        IF pr_tab_crapcob(vr_idx_cob).cdbandoc = 085 THEN

          -- Identificar se eh pessoa fisica ou juridica
          --    cdtpinsc = 1 -- Fisica
          --    cdtpinsc = 2 -- Juridica
          IF pr_tab_crapcob(vr_idx_cob).cdtpinsc = 1 THEN
            vr_tppessoa := 'F';
          ELSE
            vr_tppessoa := 'J';
          END IF;

          vr_cdmotivo := NULL;
          -- 1) se inregcip = 1 -> vr_cdmotivo = 'R1' (concatenar);
          IF vr_inregcip = 1 THEN
            vr_cdmotivo := NVL(vr_cdmotivo,'') || 'R1';
          END IF;
          
          -- 2) se inemiten = 3 -> vr_cdmotivo = 'P1' (concatenar);
          IF pr_tab_crapcob(vr_idx_cob).inemiten = 3 THEN
            vr_cdmotivo := NVL(vr_cdmotivo,'') || 'P1';
          END IF;
        
          -- se sacado nao-DDA, registrar ent confirmada
          COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => vr_new_rowid,
                                             pr_cdocorre => 2,    -- Entrada Confirmada
                                             pr_cdmotivo => NVL(vr_cdmotivo,'  '),
                                             pr_vltarifa => 0,
                                             pr_cdbcoctl => pr_rec_header.cdbcoctl,
                                             pr_cdagectl => pr_rec_header.cdagectl,
                                             pr_dtmvtolt => pr_dtmvtolt,
                                             pr_cdoperad => pr_cdoperad,
                                             pr_nrremass => pr_rec_header.nrremass,
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic);

          -- Se ocorreu critica escreve no proc_message.log
          -- Não para o processo
          IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                      ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                          ' - COBR0006 --> pc_processa_titulos' ||
                                                          ' Coop: '      || pr_tab_crapcob(vr_idx_cob).cdcooper ||
                                                          ' Conta: '     || pr_tab_crapcob(vr_idx_cob).nrdconta ||
                                                          ' Remessa: '   || pr_rec_header.nrremass ||
                                                          ' Convenio: '  || pr_rec_header.nrcnvcob ||
                                                          ' Nosso Num.:' || pr_tab_crapcob(vr_idx_cob).nrnosnum ||
                                                          ' ROWID: '     || rw_crapcob.rowid ||
                                                          ' - ERRO: '    || NVL(vr_cdcritic,0) || 
                                                          ' - ' || NVL(vr_dscritic,''));
            vr_cdcritic:= NULL;
            vr_dscritic:= NULL;
          END IF;
          
          -- Cria registro para cobranca tarifa.
          vr_idx_lat:= lpad(pr_tab_crapcob(vr_idx_cob).cdcooper,10,'0')||
                       lpad(pr_tab_crapcob(vr_idx_cob).nrdconta,10,'0')||
                       lpad(pr_tab_crapcob(vr_idx_cob).nrcnvcob,10,'0')||
                       lpad(2,10,'0')||
                       lpad('',10,'0')||
                       lpad(pr_tab_lat_consolidada.Count+1,10,'0');
                       
          pr_tab_lat_consolidada(vr_idx_lat).cdcooper := pr_tab_crapcob(vr_idx_cob).cdcooper;
          pr_tab_lat_consolidada(vr_idx_lat).nrdconta := pr_tab_crapcob(vr_idx_cob).nrdconta;
          pr_tab_lat_consolidada(vr_idx_lat).nrdocmto := pr_tab_crapcob(vr_idx_cob).nrdocmto;
          pr_tab_lat_consolidada(vr_idx_lat).nrcnvcob := pr_tab_crapcob(vr_idx_cob).nrcnvcob;
          pr_tab_lat_consolidada(vr_idx_lat).dsincide := 'RET';
          pr_tab_lat_consolidada(vr_idx_lat).cdocorre := 02; -- 02 - Entrada Confirmada
          pr_tab_lat_consolidada(vr_idx_lat).cdmotivo := NVL(vr_cdmotivo,'  ');
          pr_tab_lat_consolidada(vr_idx_lat).vllanmto := pr_tab_crapcob(vr_idx_cob).vltitulo;
        END IF;
      END IF;
    
      IF vr_nrdconta IS NULL THEN
        vr_nrdconta := pr_tab_crapcob(vr_idx_cob).nrdconta;
      END IF;
    
      vr_idx_cob := pr_tab_crapcob.NEXT(vr_idx_cob);
      
    END LOOP;
    
    -- verifica se é para enviar para a CIP
    IF pr_rec_header.flgregon = 1 AND vr_nrdconta IS NOT NULL THEN
         pc_crps618(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => vr_nrdconta,
                    --pr_flgresta => 0,
                    --pr_stprogra => vr_stprogra,
                    --pr_infimsol => vr_infimsol,
                    pr_cdcritic => vr_cdcritic,
                    pr_dscritic => pr_dscritic);
                     
         IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                         ' - COBR0006.pc_processa_titulos -->' ||
                                                         ' Coop: '      || pr_cdcooper ||
                                                         ' Remessa: '   || pr_rec_header.nrremass ||
                                                         ' Convenio: '  || pr_rec_header.nrcnvcob ||
                                                         ' ROWID: '     || rw_crapcob.rowid ||
                                                         ' - ERRO: '    || NVL(vr_cdcritic,0) || 
                                                         ' - '          || NVL(vr_dscritic,''));
           vr_cdcritic:= NULL;
           vr_dscritic:= NULL;
         END IF;                   
                   
     END IF;
    
  EXCEPTION 
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na COBR0006.pc_processa_titulos --> ' || SQLERRM;

  END pc_processa_titulos;

  --> Procedure para processar os titulos que foram identificados no arquivo
  PROCEDURE pc_processa_instrucoes(pr_cdcooper      IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                  ,pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                  ,pr_cdoperad      IN crapope.cdoperad%TYPE --> Operador
                                  ,pr_flremarq      IN INTEGER DEFAULT 1     --> Identifica se é uma remessa via arquivo(1-Sim, 0-Não)
                                  ,pr_tab_instrucao IN typ_tab_instrucao     --> Tabela de Cobranca
                                  ,pr_rec_header    IN typ_rec_header        --> Dados do Header do Arquivo
                                  ,pr_tab_rejeitado IN OUT NOCOPY typ_tab_rejeitado --> Tabela de rejeitados
                                  ,pr_tab_lat_consolidada IN OUT NOCOPY PAGA0001.typ_tab_lat_consolidada --> Tabela tarifas
                                  ,pr_cdcritic     OUT INTEGER               --> Codigo da Critica
                                  ,pr_dscritic     OUT VARCHAR2              --> Descricao da Critica
                                  ) IS
                                   
  /* ............................................................................

       Programa: pc_processa_instrucoes           Antiga: b1wgen0090.p/p_processa_instrucoes
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Janeiro/2016                     Ultima atualizacao: 12/08/2019

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Processar as instrucoes que foram identificados no arquivo de 
                   remessa

       Alteracoes: 25/01/2016 - Conversão Progress -> Oracle (Douglas Quisinski)

	               13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 
                
                   01/02/2018 - Alterações referente ao PRJ352 - Nova solução de protesto
                   
                   12/08/2019 - Incluída Validação de Desconto Superior a Valor do Documento
                                Rafael Ferreira (Mouts) - INC0021299
                   
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_processa_erro EXCEPTION;
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_des_erro   VARCHAR2(5);

    ------------------------------- CURSORES ---------------------------------    
    -- Parâmetros do cadastro de cobrança
    CURSOR cr_crapcco(pr_cdcooper IN crapcob.cdcooper%type
                     ,pr_nrconven IN crapcco.nrconven%TYPE) IS
      SELECT cco.cddbanco
            ,cco.nrdctabb
        FROM crapcco cco
       WHERE cco.cdcooper = pr_cdcooper
         AND cco.nrconven = pr_nrconven;
    rw_crapcco cr_crapcco%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    vr_instrucao  typ_rec_instrucao;
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_cdcooper   crapcob.cdcooper%TYPE;
    vr_nrdconta   crapcob.nrdconta%TYPE;
    vr_nrcnvcob   crapcob.nrcnvcob%TYPE;
    vr_nrdocmto   crapcob.nrdocmto%TYPE;
    -- Quantidades   
    vr_qtd_proc   INTEGER;
		
		vr_dsocorre crapoco.dsocorre%TYPE;

  BEGIN
  
    vr_qtd_proc:= 0;
    
    -- Percorrer todos as instrucoes para que sejam processadas
    FOR vr_idx IN 1..pr_tab_instrucao.COUNT() LOOP
      BEGIN
        -- Contador para que seja comitado a cada 1000 registros
        vr_qtd_proc:= vr_qtd_proc + 1;
        vr_cdcritic:= NULL;
        vr_dscritic:= NULL;
        
        vr_instrucao:= pr_tab_instrucao(vr_idx);
        
        OPEN cr_crapcob(pr_cdcooper => vr_instrucao.cdcooper,
                        pr_nrdconta => vr_instrucao.nrdconta,
                        pr_cdbandoc => vr_instrucao.cdbandoc,
                        pr_nrdctabb => vr_instrucao.nrdctabb,
                        pr_nrcnvcob => vr_instrucao.nrcnvcob,
                        pr_nrdocmto => vr_instrucao.nrdocmto);
        FETCH cr_crapcob INTO rw_crapcob;
        -- Verifica se encontrou o registro da cobranca
        IF cr_crapcob%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_crapcob;
          
          -- Rejeitou a cobranca e nao deve continuar o processamento
          -- Armazenar a rejeicao, todos serao processados no proximo passo
          -- 60 - Movimento para Titulo Nao Cadastrado
          pc_grava_rejeitado(pr_cdcooper      => vr_instrucao.cdcooper  --> Codigo da Cooperativa
                            ,pr_nrdconta      => vr_instrucao.nrdconta  --> Numero da Conta
                            ,pr_nrcnvcob      => vr_instrucao.nrcnvcob  --> Numero do Convenio
                            ,pr_vltitulo      => vr_instrucao.vltitulo  --> Valor do Titulo
                            ,pr_cdbcoctl      => pr_rec_header.cdbcoctl --> Codigo do banco na central
                            ,pr_cdagectl      => pr_rec_header.cdagectl --> Codigo da Agencial na central
                            ,pr_nrnosnum      => vr_instrucao.nrnosnum  --> Nosso Numero
                            ,pr_dsdoccop      => vr_instrucao.dsdoccop  --> Descricao do Documento
                            ,pr_nrremass      => pr_rec_header.nrremass --> Numero da Remessa
                            ,pr_dtvencto      => vr_instrucao.dtvencto  --> Data de Vencimento
                            ,pr_dtmvtolt      => pr_dtmvtolt            --> Data de Movimento
                            ,pr_cdoperad      => pr_cdoperad            --> Operador
                            ,pr_cdocorre      => 26                     --> Codigo da Ocorrencia
                            ,pr_cdmotivo      => '60'                   --> Motivo da Rejeicao
                            ,pr_tab_rejeitado => pr_tab_rejeitado);     --> Tabela de Rejeitados
          CONTINUE;
        ELSE 
          -- Fecha cursor
          CLOSE cr_crapcob;
        END IF;
        
        -- verificar se a instrucao está pendente de processamento na CIP
        IF rw_crapcob.ininscip = 1 THEN
          -- Armazenar a rejeicao, todos serao processados no proximo passo
          -- 99 - Motivo nao cadastrado
          pc_grava_rejeitado(pr_cdcooper      => vr_instrucao.cdcooper  --> Codigo da Cooperativa
                            ,pr_nrdconta      => vr_instrucao.nrdconta  --> Numero da Conta
                            ,pr_nrcnvcob      => vr_instrucao.nrcnvcob  --> Numero do Convenio
                            ,pr_vltitulo      => vr_instrucao.vltitulo  --> Valor do Titulo
                            ,pr_cdbcoctl      => pr_rec_header.cdbcoctl --> Codigo do banco na central
                            ,pr_cdagectl      => pr_rec_header.cdagectl --> Codigo da Agencial na central
                            ,pr_nrnosnum      => vr_instrucao.nrnosnum  --> Nosso Numero
                            ,pr_dsdoccop      => vr_instrucao.dsdoccop  --> Descricao do Documento
                            ,pr_nrremass      => pr_rec_header.nrremass --> Numero da Remessa
                            ,pr_dtvencto      => vr_instrucao.dtvencto  --> Data de Vencimento
                            ,pr_dtmvtolt      => pr_dtmvtolt            --> Data de Movimento
                            ,pr_cdoperad      => pr_cdoperad            --> Operador
                            ,pr_cdocorre      => 26                     --> Codigo da Ocorrencia
                            ,pr_cdmotivo      => 'A8'                   --> Motivo da Rejeicao
                            ,pr_tab_rejeitado => pr_tab_rejeitado);     --> Tabela de Rejeitados
                                      
          IF pr_rec_header.nrremass = 0 THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Instrucao pendente de processamento na CIP. Tente novamente.';            
            RAISE vr_processa_erro;  
          END IF;
          
          CONTINUE;          
        END IF;
        
        -- Rafael Ferreira (Mouts) - INC0021299
        -- Valida se o Desconto é igual ou superior ao valor Total do Documento
        IF nvl(vr_instrucao.vldescto,0) >= nvl(vr_instrucao.vltitulo,0) THEN
          -- Armazenar a rejeicao, todos serao processados no proximo passo
          -- 29 - Motivo Valor do Desconto Maior ou Igual ao Valor do Título
          pc_grava_rejeitado(pr_cdcooper      => vr_instrucao.cdcooper  --> Codigo da Cooperativa
                            ,pr_nrdconta      => vr_instrucao.nrdconta  --> Numero da Conta
                            ,pr_nrcnvcob      => vr_instrucao.nrcnvcob  --> Numero do Convenio
                            ,pr_vltitulo      => vr_instrucao.vltitulo  --> Valor do Titulo
                            ,pr_cdbcoctl      => pr_rec_header.cdbcoctl --> Codigo do banco na central
                            ,pr_cdagectl      => pr_rec_header.cdagectl --> Codigo da Agencial na central
                            ,pr_nrnosnum      => vr_instrucao.nrnosnum  --> Nosso Numero
                            ,pr_dsdoccop      => vr_instrucao.dsdoccop  --> Descricao do Documento
                            ,pr_nrremass      => pr_rec_header.nrremass --> Numero da Remessa
                            ,pr_dtvencto      => vr_instrucao.dtvencto  --> Data de Vencimento
                            ,pr_dtmvtolt      => pr_dtmvtolt            --> Data de Movimento
                            ,pr_cdoperad      => pr_cdoperad            --> Operador
                            ,pr_cdocorre      => 03                     --> Codigo da Ocorrencia
                            ,pr_cdmotivo      => '29'                   --> Motivo da Rejeicao
                            ,pr_tab_rejeitado => pr_tab_rejeitado);     --> Tabela de Rejeitados
                                      
          IF pr_rec_header.nrremass = 0 THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Valor do Desconto Maior ou Igual ao Valor do Título.';
            RAISE vr_processa_erro;  
          END IF;
          
          CONTINUE;          
        END IF;
        
        -- verificar se titulo é DDA e não possui nr de identificacao na CIP
        IF rw_crapcob.flgcbdda = 1 AND nvl(rw_crapcob.nrdident,0) = 0 THEN
          -- Armazenar a rejeicao, todos serao processados no proximo passo
          -- 99 - Motivo nao cadastrado
          pc_grava_rejeitado(pr_cdcooper      => vr_instrucao.cdcooper  --> Codigo da Cooperativa
                            ,pr_nrdconta      => vr_instrucao.nrdconta  --> Numero da Conta
                            ,pr_nrcnvcob      => vr_instrucao.nrcnvcob  --> Numero do Convenio
                            ,pr_vltitulo      => vr_instrucao.vltitulo  --> Valor do Titulo
                            ,pr_cdbcoctl      => pr_rec_header.cdbcoctl --> Codigo do banco na central
                            ,pr_cdagectl      => pr_rec_header.cdagectl --> Codigo da Agencial na central
                            ,pr_nrnosnum      => vr_instrucao.nrnosnum  --> Nosso Numero
                            ,pr_dsdoccop      => vr_instrucao.dsdoccop  --> Descricao do Documento
                            ,pr_nrremass      => pr_rec_header.nrremass --> Numero da Remessa
                            ,pr_dtvencto      => vr_instrucao.dtvencto  --> Data de Vencimento
                            ,pr_dtmvtolt      => pr_dtmvtolt            --> Data de Movimento
                            ,pr_cdoperad      => pr_cdoperad            --> Operador
                            ,pr_cdocorre      => 26                     --> Codigo da Ocorrencia
                            ,pr_cdmotivo      => 'A9'                   --> Motivo da Rejeicao
                            ,pr_tab_rejeitado => pr_tab_rejeitado);     --> Tabela de Rejeitados
                                      
          IF pr_rec_header.nrremass = 0 THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Titulo pendente de registro na CIP. Tente mais tarde.';
            RAISE vr_processa_erro;  
          END IF;
          
          CONTINUE;          
        END IF;        
        
        -- Verificar se ja esta Liquidado
        IF rw_crapcob.incobran = 5 THEN
          -- Preparar Lote de Retorno Cooperado
          pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                    ,pr_cdocorre => 26    -- Instrucao Rejeitada  
                                    ,pr_cdmotivo => NULL  -- Motivo
                                    ,pr_vltarifa => 0     -- Valor da tarifa
                                    ,pr_cdbcoctl => pr_rec_header.cdbcoctl
                                    ,pr_cdagectl => pr_rec_header.cdagectl
                                    ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                    ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                    ,pr_nrremass => vr_instrucao.nrremass --Numero Remessa
                                    ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                    ,pr_dscritic => vr_dscritic); --Descricao Critica

          IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_processa_erro;
          END IF;
          CONTINUE;
        END IF;
        
        -- Ocorrencias:
        --   02 - Baixar
        --   10 - Sustar Protesto e Baixar
        --   11 - Sustar Protesto e Carteira
        --   81 - Excluir Protesto com Carta de Anuência
        IF vr_instrucao.cdocorre NOT IN (02,10,11,81) AND
           rw_crapcob.incobran = 3                 AND -- Baixado
           TRIM(rw_crapcob.cdtitprt) IS NULL       THEN
          -- Preparar Lote de Retorno Cooperado
          pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid       --> ROWID da cobranca
                                    ,pr_cdocorre => 26                     --> Instrucao Rejeitada  
                                    ,pr_cdmotivo => NULL                   --> Motivo
                                    ,pr_vltarifa => 0                      --> Valor da tarifa
                                    ,pr_cdbcoctl => pr_rec_header.cdbcoctl --> Codigo do banco na central
                                    ,pr_cdagectl => pr_rec_header.cdagectl --> Codigo da agencia na cental
                                    ,pr_dtmvtolt => pr_dtmvtolt            --> Data Movimento
                                    ,pr_cdoperad => pr_cdoperad            --> Codigo Operador
                                    ,pr_nrremass => vr_instrucao.nrremass  --> Numero Remessa
                                    ,pr_cdcritic => vr_cdcritic            --> Codigo Critica
                                    ,pr_dscritic => vr_dscritic);          --> Descricao Critica
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_processa_erro;
          END IF;
          CONTINUE;
        END IF;
        
        --Cria log cobranca
        IF nvl(vr_instrucao.nrremass,0) > 0 THEN
					-- Busca descrição da instrução
					BEGIN
						--
						SELECT crapoco.dsocorre
						  INTO vr_dsocorre
							FROM crapoco
						 WHERE crapoco.cdcooper = pr_cdcooper
							 AND crapoco.cddbanco = vr_instrucao.cdbandoc
							 AND crapoco.cdocorre = vr_instrucao.cdocorre
							 AND crapoco.tpocorre = 1; -- 1 - Remessa
						--
					EXCEPTION
						WHEN no_data_found THEN
							vr_dscritic := 'Codigo de ocorrencia ' || vr_instrucao.cdocorre || ' nao encontrado!';
							RAISE vr_processa_erro;
						WHEN OTHERS THEN
							vr_dscritic := 'Erro ao buscar a descricao da ocorrencia: ' || SQLERRM;
							RAISE vr_processa_erro;
					END;
					--
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --> ROWID da Cobranca
                                       ,pr_cdoperad => pr_cdoperad      --> Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt      --> Data movimento
                                       ,pr_dsmensag => 'Instrucao ' || 
                                                       vr_instrucao.cdocorre ||
                                                       ' integrada por arquivo - ' ||
                                                       vr_instrucao.nrremass --> Descricao Mensagem
                                       ,pr_des_erro => vr_des_erro   --> Indicador erro
                                       ,pr_dscritic => vr_dscritic); --> Descricao erro

          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_processa_erro;
          END IF;
        END IF;
        
        -- Verificar que eh a instrucao que foi identificada
        CASE vr_instrucao.cdocorre
          -- 02 = Instrucoes de Baixa
          WHEN 02 THEN
            -- Tratamento para solicitar baixa boleto BB vinculado ao boleto 085
            IF rw_crapcob.incobran = 3 AND 
               TRIM(rw_crapcob.cdtitprt) IS NOT NULL THEN
               
              -- Ler as informacoes do titulo protestado
              vr_cdcooper := GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(pr_postext => 1, pr_dstext => rw_crapcob.cdtitprt, pr_delimitador => ';'));
              vr_nrdconta := GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(pr_postext => 2, pr_dstext => rw_crapcob.cdtitprt, pr_delimitador => ';'));
              vr_nrcnvcob := GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(pr_postext => 3, pr_dstext => rw_crapcob.cdtitprt, pr_delimitador => ';'));
              vr_nrdocmto := GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(pr_postext => 4, pr_dstext => rw_crapcob.cdtitprt, pr_delimitador => ';'));

              -- Busca as informacoes do cadastro de cobranca
              OPEN cr_crapcco (pr_cdcooper => vr_cdcooper
                              ,pr_nrconven => vr_nrcnvcob); 
              FETCH cr_crapcco INTO rw_crapcco;
              -- Verifica se existe o cadastro de cobranca
              IF cr_crapcco%FOUND THEN
                -- Fecha o cursor
                CLOSE cr_crapcco;
                -- Buscar as informacoes da cobranca
                OPEN cr_crapcob(pr_cdcooper => vr_cdcooper,
                                pr_nrdconta => vr_nrdconta,
                                pr_cdbandoc => rw_crapcco.cddbanco,
                                pr_nrdctabb => rw_crapcco.nrdctabb,
                                pr_nrcnvcob => vr_nrcnvcob,
                                pr_nrdocmto => vr_nrdocmto);
                FETCH cr_crapcob INTO rw_crapcob;
                -- Verifica se encontrou o registro da cobranca
                IF cr_crapcob%FOUND THEN
                  -- Fecha cursor
                  CLOSE cr_crapcob;
                  -- Executa a instrucao com a cobranca encontrada
                  COBR0007.pc_inst_pedido_baixa(pr_idregcob => rw_crapcob.rowid
                                               ,pr_cdocorre => vr_instrucao.cdocorre
                                               ,pr_dtmvtolt => pr_dtmvtolt
                                               ,pr_cdoperad => pr_cdoperad
                                               ,pr_nrremass => vr_instrucao.nrremass
                                               ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
                ELSE
                  -- Fecha cursor
                  CLOSE cr_crapcob;
                END IF;
              ELSE 
                -- Fecha o cursor
                CLOSE cr_crapcco;
              END IF;
              -- FIM do tratamento de incobran = 3
            ELSE
              -- Executa a instrucao com os dados do arquivo
              COBR0007.pc_inst_pedido_baixa(pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => vr_instrucao.cdocorre
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => vr_instrucao.nrremass
                                           ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
            END IF;
          
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;

          -- 04 = Concessao de Abatimento
          WHEN 04 THEN
            COBR0007.pc_inst_conc_abatimento(pr_cdcooper => vr_instrucao.cdcooper
                                            ,pr_nrdconta => vr_instrucao.nrdconta
                                            ,pr_nrcnvcob => vr_instrucao.nrcnvcob
                                            ,pr_nrdocmto => vr_instrucao.nrdocmto
                                            ,pr_cdocorre => vr_instrucao.cdocorre
                                            ,pr_dtmvtolt => pr_dtmvtolt
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_vlabatim => vr_instrucao.vlabatim
                                            ,pr_nrremass => vr_instrucao.nrremass
                                            ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;

          -- 05 = Cancelamento de Abatimento
          WHEN 05 THEN
            COBR0007.pc_inst_canc_abatimento(pr_cdcooper => vr_instrucao.cdcooper
                                            ,pr_nrdconta => vr_instrucao.nrdconta
                                            ,pr_nrcnvcob => vr_instrucao.nrcnvcob
                                            ,pr_nrdocmto => vr_instrucao.nrdocmto
                                            ,pr_cdocorre => vr_instrucao.cdocorre
                                            ,pr_dtmvtolt => pr_dtmvtolt
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_nrremass => vr_instrucao.nrremass
                                            ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;

          -- 06 = Alteracao de Vencimento
          WHEN 06 THEN
            COBR0007.pc_inst_alt_vencto(pr_cdcooper => vr_instrucao.cdcooper
                                       ,pr_nrdconta => vr_instrucao.nrdconta
                                       ,pr_nrcnvcob => vr_instrucao.nrcnvcob
                                       ,pr_nrdocmto => vr_instrucao.nrdocmto
                                       ,pr_cdocorre => vr_instrucao.cdocorre
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_dtvencto => vr_instrucao.dtvencto
                                       ,pr_nrremass => vr_instrucao.nrremass
                                       ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;

          -- 07 = Concessao de Desconto
          WHEN 07 THEN
            COBR0007.pc_inst_conc_desconto(pr_cdcooper => vr_instrucao.cdcooper
                                          ,pr_nrdconta => vr_instrucao.nrdconta
                                          ,pr_nrcnvcob => vr_instrucao.nrcnvcob
                                          ,pr_nrdocmto => vr_instrucao.nrdocmto
                                          ,pr_cdocorre => vr_instrucao.cdocorre
                                          ,pr_dtmvtolt => pr_dtmvtolt
                                          ,pr_cdoperad => pr_cdoperad
                                          ,pr_vldescto => vr_instrucao.vldescto
                                          ,pr_nrremass => vr_instrucao.nrremass
                                          ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
            
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;

          -- 08 = Cancelamento de Desconto
          WHEN 08 THEN
            COBR0007.pc_inst_canc_desconto(pr_cdcooper => vr_instrucao.cdcooper
                                          ,pr_nrdconta => vr_instrucao.nrdconta
                                          ,pr_nrcnvcob => vr_instrucao.nrcnvcob
                                          ,pr_nrdocmto => vr_instrucao.nrdocmto
                                          ,pr_cdocorre => vr_instrucao.cdocorre
                                          ,pr_dtmvtolt => pr_dtmvtolt
                                          ,pr_cdoperad => pr_cdoperad
                                          ,pr_nrremass => vr_instrucao.nrremass
                                          ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;

          -- 09 = Protestar
          WHEN 09 THEN
            cobr0007.pc_inst_protestar(pr_cdcooper => vr_instrucao.cdcooper
                                     , pr_nrdconta => vr_instrucao.nrdconta
                                     , pr_nrcnvcob => vr_instrucao.nrcnvcob
                                     , pr_nrdocmto => vr_instrucao.nrdocmto
                                     , pr_cdocorre => vr_instrucao.cdocorre
                                     , pr_cdtpinsc => 0 -- variavel nao esta sendo utilizada
                                     , pr_dtmvtolt => pr_dtmvtolt
                                     , pr_cdoperad => pr_cdoperad
                                     , pr_nrremass => vr_instrucao.nrremass
                                     , pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                     , pr_cdcritic => vr_cdcritic
                                     , pr_dscritic => vr_dscritic);
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;

          -- 10 = Sustar Protesto e Baixar
          WHEN 10 THEN
            -- Tratamento para Sustar Protesto e Baixar boleto BB vinculado ao boleto 085
            IF rw_crapcob.incobran = 3 AND 
               TRIM(rw_crapcob.cdtitprt) IS NOT NULL THEN
               
              -- Ler as informacoes do titulo protestado
              vr_cdcooper := GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(pr_postext => 1, pr_dstext => rw_crapcob.cdtitprt, pr_delimitador => ';'));
              vr_nrdconta := GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(pr_postext => 2, pr_dstext => rw_crapcob.cdtitprt, pr_delimitador => ';'));
              vr_nrcnvcob := GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(pr_postext => 3, pr_dstext => rw_crapcob.cdtitprt, pr_delimitador => ';'));
              vr_nrdocmto := GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(pr_postext => 4, pr_dstext => rw_crapcob.cdtitprt, pr_delimitador => ';'));

              -- Busca as informacoes do cadastro de cobranca
              OPEN cr_crapcco (pr_cdcooper => vr_cdcooper
                              ,pr_nrconven => vr_nrcnvcob); 
              FETCH cr_crapcco INTO rw_crapcco;
              -- Verifica se existe o cadastro de cobranca
              IF cr_crapcco%FOUND THEN
                -- Fecha o cursor
                CLOSE cr_crapcco;
                -- Buscar as informacoes da cobranca
                OPEN cr_crapcob(pr_cdcooper => vr_cdcooper,
                                pr_nrdconta => vr_nrdconta,
                                pr_cdbandoc => rw_crapcco.cddbanco,
                                pr_nrdctabb => rw_crapcco.nrdctabb,
                                pr_nrcnvcob => vr_nrcnvcob,
                                pr_nrdocmto => vr_nrdocmto);
                FETCH cr_crapcob INTO rw_crapcob;
                -- Verifica se encontrou o registro da cobranca
                IF cr_crapcob%FOUND THEN
                  -- Fecha cursor
                  CLOSE cr_crapcob;
                  -- Executa a instrucao com a cobranca encontrada
                  COBR0007.pc_inst_sustar_baixar(pr_cdcooper => rw_crapcob.cdcooper
                                                ,pr_nrdconta => rw_crapcob.nrdconta
                                                ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                                                ,pr_nrdocmto => rw_crapcob.nrdocmto
                                                ,pr_dtmvtolt => pr_dtmvtolt
                                                ,pr_cdoperad => pr_cdoperad
                                                ,pr_nrremass => vr_instrucao.nrremass
                                                ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic);
                ELSE
                  -- Fecha cursor
                  CLOSE cr_crapcob;
                END IF;
              ELSE 
                -- Fecha o cursor
                CLOSE cr_crapcco;
              END IF;
              -- FIM do tratamento de incobran = 3
            ELSE
              -- Executa a instrucao com os dados do arquivo
              COBR0007.pc_inst_sustar_baixar(pr_cdcooper => vr_instrucao.cdcooper
                                            ,pr_nrdconta => vr_instrucao.nrdconta
                                            ,pr_nrcnvcob => vr_instrucao.nrcnvcob
                                            ,pr_nrdocmto => vr_instrucao.nrdocmto
                                            ,pr_dtmvtolt => pr_dtmvtolt
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_nrremass => vr_instrucao.nrremass
                                            ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
            END IF;
            
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;

          -- 11 = Sustar Protesto e Manter em Carteira
          WHEN 11 THEN
            -- Tratamento para Sustar Protesto e Manter em Carteira boleto BB vinculado ao boleto 085
            IF rw_crapcob.incobran = 3 AND 
               TRIM(rw_crapcob.cdtitprt) IS NOT NULL THEN
               
              -- Ler as informacoes do titulo protestado
              vr_cdcooper := GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(pr_postext => 1, pr_dstext => rw_crapcob.cdtitprt, pr_delimitador => ';'));
              vr_nrdconta := GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(pr_postext => 2, pr_dstext => rw_crapcob.cdtitprt, pr_delimitador => ';'));
              vr_nrcnvcob := GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(pr_postext => 3, pr_dstext => rw_crapcob.cdtitprt, pr_delimitador => ';'));
              vr_nrdocmto := GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(pr_postext => 4, pr_dstext => rw_crapcob.cdtitprt, pr_delimitador => ';'));

              -- Busca as informacoes do cadastro de cobranca
              OPEN cr_crapcco (pr_cdcooper => vr_cdcooper
                              ,pr_nrconven => vr_nrcnvcob); 
              FETCH cr_crapcco INTO rw_crapcco;
              -- Verifica se existe o cadastro de cobranca
              IF cr_crapcco%FOUND THEN
                -- Fecha o cursor
                CLOSE cr_crapcco;
                -- Buscar as informacoes da cobranca
                OPEN cr_crapcob(pr_cdcooper => vr_cdcooper,
                                pr_nrdconta => vr_nrdconta,
                                pr_cdbandoc => rw_crapcco.cddbanco,
                                pr_nrdctabb => rw_crapcco.nrdctabb,
                                pr_nrcnvcob => vr_nrcnvcob,
                                pr_nrdocmto => vr_nrdocmto);
                FETCH cr_crapcob INTO rw_crapcob;
                -- Verifica se encontrou o registro da cobranca
                IF cr_crapcob%FOUND THEN
                  -- Fecha cursor
                  CLOSE cr_crapcob;
                  -- Executa a instrucao com a cobranca encontrada
                  COBR0007.pc_inst_sustar_manter(pr_cdcooper => rw_crapcob.cdcooper
                                                ,pr_nrdconta => rw_crapcob.nrdconta
                                                ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                                                ,pr_nrdocmto => rw_crapcob.nrdocmto
                                                ,pr_cdocorre => vr_instrucao.cdocorre
                                                ,pr_dtmvtolt => pr_dtmvtolt
                                                ,pr_cdoperad => pr_cdoperad
                                                ,pr_nrremass => vr_instrucao.nrremass
                                                ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic);
                ELSE
                  -- Fecha cursor
                  CLOSE cr_crapcob;
                END IF;
              ELSE 
                -- Fecha o cursor
                CLOSE cr_crapcco;
              END IF;
              -- FIM do tratamento de incobran = 3
            ELSE
              -- Executa a instrucao com os dados do arquivo
              COBR0007.pc_inst_sustar_manter(pr_cdcooper => vr_instrucao.cdcooper
                                            ,pr_nrdconta => vr_instrucao.nrdconta
                                            ,pr_nrcnvcob => vr_instrucao.nrcnvcob
                                            ,pr_nrdocmto => vr_instrucao.nrdocmto
                                            ,pr_cdocorre => vr_instrucao.cdocorre
                                            ,pr_dtmvtolt => pr_dtmvtolt
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_nrremass => vr_instrucao.nrremass
                                            ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
              
            END IF;
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;

          -- 31 = Alteracao de Outros Dados
          WHEN 31 THEN
            COBR0007.pc_inst_alt_dados_arq_rem_085(pr_cdcooper => vr_instrucao.cdcooper
                                                  ,pr_nrdconta => vr_instrucao.nrdconta
                                                  ,pr_nrcnvcob => vr_instrucao.nrcnvcob
                                                  ,pr_nrdocmto => vr_instrucao.nrdocmto
                                                  ,pr_cdocorre => vr_instrucao.cdocorre
                                                  ,pr_nrinssac => vr_instrucao.nrinssac
                                                  ,pr_dsendsac => vr_instrucao.dsendsac
                                                  ,pr_nmbaisac => vr_instrucao.nmbaisac
                                                  ,pr_nrcepsac => vr_instrucao.nrcepsac
                                                  ,pr_nmcidsac => vr_instrucao.nmcidsac
                                                  ,pr_cdufsaca => vr_instrucao.cdufsaca
                                                  ,pr_dtmvtolt => pr_dtmvtolt
                                                  ,pr_cdoperad => pr_cdoperad
                                                  ,pr_nrremass => vr_instrucao.nrremass
                                                  ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                                  ,pr_cdcritic => vr_cdcritic
                                                  ,pr_dscritic => vr_dscritic);
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;
          
          -- 41 = Cancelar Protesto
          WHEN 41 THEN
            COBR0007.pc_inst_cancel_protesto(pr_cdcooper => vr_instrucao.cdcooper
                                            ,pr_nrdconta => vr_instrucao.nrdconta
                                            ,pr_nrcnvcob => vr_instrucao.nrcnvcob
                                            ,pr_nrdocmto => vr_instrucao.nrdocmto
                                            ,pr_cdocorre => vr_instrucao.cdocorre
                                            ,pr_dtmvtolt => pr_dtmvtolt
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_nrremass => vr_instrucao.nrremass
                                            ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;

          -- 80 = Instrução automática de protesto
          WHEN 80 THEN
            COBR0007.pc_inst_aut_protesto(pr_cdcooper => vr_instrucao.cdcooper
                                         ,pr_nrdconta => vr_instrucao.nrdconta
                                         ,pr_nrcnvcob => vr_instrucao.nrcnvcob
                                         ,pr_nrdocmto => vr_instrucao.nrdocmto
                                         ,pr_cdocorre => vr_instrucao.cdocorre
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_qtdiaprt => vr_instrucao.qtdiaprt
                                         ,pr_dtvencto => vr_instrucao.dtvencto
                                         ,pr_nrremass => vr_instrucao.nrremass
                                         ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic
                                         );
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;
          
          -- 81 = Excluir Protesto com Carta de Anuência Eletrônica -- REVISAR
          WHEN 81 THEN
            COBR0007.pc_exc_prtst_anuencia_eletr(pr_cdcooper => vr_instrucao.cdcooper
                                                ,pr_nrdconta => vr_instrucao.nrdconta
                                                ,pr_nrcnvcob => vr_instrucao.nrcnvcob
                                                ,pr_nrdocmto => vr_instrucao.nrdocmto
                                                ,pr_cdocorre => vr_instrucao.cdocorre
                                                ,pr_dtmvtolt => pr_dtmvtolt
                                                ,pr_cdoperad => pr_cdoperad
                                                ,pr_nrremass => vr_instrucao.nrremass
                                                ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic
                                                );
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;
          
          -- 90 = Alterar tipo de emissao CEE
          WHEN 90 THEN
            COBR0007.pc_inst_alt_tipo_emissao_cee(pr_cdcooper => vr_instrucao.cdcooper
                                                 ,pr_nrdconta => vr_instrucao.nrdconta
                                                 ,pr_nrcnvcob => vr_instrucao.nrcnvcob
                                                 ,pr_nrdocmto => vr_instrucao.nrdocmto
                                                 ,pr_cdocorre => vr_instrucao.cdocorre
                                                 ,pr_dtmvtolt => pr_dtmvtolt
                                                 ,pr_cdoperad => pr_cdoperad
                                                 ,pr_nrremass => vr_instrucao.nrremass
                                                 ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                                 ,pr_cdcritic => vr_cdcritic
                                                 ,pr_dscritic => vr_dscritic);
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;
            
          -- 93 = Negativar Serasa
          WHEN 93 THEN
             SSPC0002.pc_negativa_serasa(pr_cdcooper => vr_instrucao.cdcooper --> Codigo da cooperativa
                                        ,pr_nrcnvcob => vr_instrucao.nrcnvcob --> Numero do convenio de cobranca. 
                                        ,pr_nrdconta => vr_instrucao.nrdconta --> Numero da conta/dv do associado. 
                                        ,pr_nrdocmto => vr_instrucao.nrdocmto --> Numero do documento(boleto) 
                                        ,pr_nrremass => vr_instrucao.nrremass --> Numero da Remessa
                                        ,pr_cdoperad => pr_cdoperad           --> Codigo do operador
                                        ,pr_cdcritic => vr_cdcritic           --> Código da crítica
                                        ,pr_dscritic => vr_dscritic);         --> Descrição da crítica
                                        
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;
           
          -- 94 = Cancelar Negativacao Serasa
          WHEN 94 THEN
            SSPC0002.pc_cancelar_neg_serasa(pr_cdcooper => vr_instrucao.cdcooper --> Codigo da cooperativa
                                           ,pr_nrcnvcob => vr_instrucao.nrcnvcob --> Numero do convenio de cobranca. 
                                           ,pr_nrdconta => vr_instrucao.nrdconta --> Numero da conta/dv do associado.
                                           ,pr_nrdocmto => vr_instrucao.nrdocmto --> Numero do documento(boleto) 
                                           ,pr_nrremass => vr_instrucao.nrremass --> Numero da Remessa
                                           ,pr_cdoperad => pr_cdoperad           --> Codigo do operador
                                           ,pr_cdcritic => vr_cdcritic           --> Código da crítica
                                           ,pr_dscritic => vr_dscritic);         --> Descrição da crítica
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;
            
          -- 95 = Instrucao manual de envio de SMS
          WHEN 95 THEN
            COBR0007.pc_inst_envio_sms(pr_cdcooper => vr_instrucao.cdcooper,
                                       pr_nrdconta => vr_instrucao.nrdconta,
                                       pr_nrcnvcob => vr_instrucao.nrcnvcob,
                                       pr_nrdocmto => vr_instrucao.nrdocmto,
                                       pr_dtmvtolt => pr_dtmvtolt,
                                       pr_cdoperad => pr_cdoperad,
                                       pr_inavisms => vr_instrucao.inavisms,
                                       pr_nrcelsac => vr_instrucao.nrcelsac,
                                       pr_nrremass => vr_instrucao.nrremass,
                                       pr_cdcritic => vr_cdcritic,
                                       pr_dscritic => vr_dscritic);
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;

          -- 96 = Cancelamento de envio de SMS
          WHEN 96 THEN
            COBR0007.pc_inst_canc_sms(pr_cdcooper => vr_instrucao.cdcooper,
                                      pr_nrdconta => vr_instrucao.nrdconta,
                                      pr_nrcnvcob => vr_instrucao.nrcnvcob,
                                      pr_nrdocmto => vr_instrucao.nrdocmto,
                                      pr_dtmvtolt => pr_dtmvtolt,
                                      pr_cdoperad => pr_cdoperad,
                                      pr_nrremass => vr_instrucao.nrremass,
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);
            -- Verificar se ocorreu erro durante a execucao da instrucao
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;

          -- Instrucoes que nao estavam previstas
          ELSE
            -- Preparar Lote de Retorno Cooperado
            pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid       --> ROWID da cobranca
                                      ,pr_cdocorre => 26                     --> Instrucao Rejeitada  
                                      ,pr_cdmotivo => NULL                   --> Motivo
                                      ,pr_vltarifa => 0                      --> Valor da tarifa
                                      ,pr_cdbcoctl => pr_rec_header.cdbcoctl --> Codigo do banco na central
                                      ,pr_cdagectl => pr_rec_header.cdagectl --> Codigo da agencia na cental
                                      ,pr_dtmvtolt => pr_dtmvtolt            --> Data Movimento
                                      ,pr_cdoperad => pr_cdoperad            --> Codigo Operador
                                      ,pr_nrremass => vr_instrucao.nrremass  --> Numero Remessa
                                      ,pr_cdcritic => vr_cdcritic            --> Codigo Critica
                                      ,pr_dscritic => vr_dscritic);          --> Descricao Critica
            -- Verificar se ocorreu erro 
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_processa_erro;
            END IF;
            
            --Cria log cobranca
            PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --> ROWID da Cobranca
                                         ,pr_cdoperad => pr_cdoperad      --> Operador
                                         ,pr_dtmvtolt => pr_dtmvtolt      --> Data movimento
                                         ,pr_dsmensag => 'Instrucao ' || 
                                                         vr_instrucao.cdocorre ||
                                                         ' nao programada ' --> Descricao Mensagem
                                         ,pr_des_erro => vr_des_erro   --> Indicador erro
                                         ,pr_dscritic => vr_dscritic); --> Descricao erro

            --Se ocorreu erro
            IF vr_des_erro = 'NOK' THEN
              --Levantar Excecao
              RAISE vr_processa_erro;
            END IF;
        END CASE;
        
      EXCEPTION
        WHEN vr_processa_erro THEN
          -- Quando processar as linhas de instrucao, alem da procedure em gerar o retorno
          -- para o cooperado, devemos armazenar o motivo da rejeicao da instrucao
          -- deve gerar as informacoes da cobranca em questao no arquivo proc_message.log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - COBR0006 --> pc_processa_instrucoes' ||
                                                        ' Coop: '      || vr_instrucao.cdcooper ||
                                                        ' Conta: '     || vr_instrucao.nrdconta ||
                                                        ' Remessa: '   || vr_instrucao.nrremass ||
                                                        ' Convenio: '  || vr_instrucao.nrcnvcob ||
                                                        ' Nosso Num.:' || vr_instrucao.nrnosnum ||
                                                        ' - MOTIVO: '  || vr_cdcritic || 
                                                        ' - '          || vr_dscritic);
        
          --> Caso não seja remessa arquivo
          IF pr_flremarq = 0 THEN
            RAISE vr_exc_erro;
          END IF;
        
        WHEN OTHERS THEN
          -- Quando ocorrer erro geral em procedures que processam os segmentos
          -- deve gerar as informacoes da cobranca em questao no arquivo proc_message.log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - COBR0006 --> pc_processa_instrucoes' ||
                                                        ' Coop: '      || vr_instrucao.cdcooper ||
                                                        ' Conta: '     || vr_instrucao.nrdconta ||
                                                        ' Remessa: '   || vr_instrucao.nrremass ||
                                                        ' Convenio: '  || vr_instrucao.nrcnvcob ||
                                                        ' Nosso Num.:' || vr_instrucao.nrnosnum ||
                                                        ' - TRACE: '   || dbms_utility.format_error_backtrace || 
                                                        ' - '          || dbms_utility.format_error_stack);
        --> Caso não seja remessa arquivo
        IF pr_flremarq = 0 THEN
          RAISE vr_exc_erro;
        END IF;
      END;
    END LOOP;
          
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na COBR0006.pc_processa_instrucoes --> ' || SQLERRM;
  END pc_processa_instrucoes;

  --> Procedure para processar os titulos que foram identificados no arquivo
  PROCEDURE pc_processa_rejeitados(pr_tab_rejeitado IN typ_tab_rejeitado     --> Tabela de rejeitados
                                  ,pr_cdcritic     OUT INTEGER               --> Codigo da Critica
                                  ,pr_dscritic     OUT VARCHAR2 ) IS         --> Descricao da Critica
  /* ............................................................................

       Programa: pc_processa_rejeitados           
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Janeiro/2016                     Ultima atualizacao: 26/01/2016

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Processar as instrucoes que foram identificados no arquivo de 
                   remessa

       Alteracoes: 26/01/2016 - Conversão Progress -> Oracle (Douglas Quisinski)
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    ------------------------------- CURSORES ---------------------------------    
    -- Buscar Controle de Remessa/Retorno de Titulos do Cooperado
    CURSOR cr_craprtc (pr_cdcooper  craprtc.cdcooper%TYPE,
                       pr_nrdconta  craprtc.nrdconta%TYPE,
                       pr_nrcnvcob  craprtc.nrcnvcob%TYPE,
                       pr_dtmvtolt  craprtc.dtmvtolt%TYPE,
                       pr_intipmvt  craprtc.intipmvt%TYPE) IS
      SELECT rtc.nrremret
        FROM craprtc rtc
       WHERE rtc.cdcooper = pr_cdcooper 
         AND rtc.nrdconta = pr_nrdconta 
         AND rtc.dtmvtolt = pr_dtmvtolt
         AND rtc.nrcnvcob = pr_nrcnvcob 
         AND rtc.intipmvt = pr_intipmvt
       ORDER BY rtc.progress_recid DESC;
    rw_craprtc cr_craprtc%ROWTYPE;
    
    -- Buscar Controle de Remessa/Retorno de Titulos Bancarios
    CURSOR cr_crapcre (pr_cdcooper  crapcre.cdcooper%TYPE,
                       pr_nrcnvcob  crapcre.nrcnvcob%TYPE,
                       pr_dtmvtolt  crapcre.dtmvtolt%TYPE,
                       pr_intipmvt  crapcre.intipmvt%TYPE) IS
      SELECT cre.nrremret
        FROM crapcre cre
       WHERE cre.cdcooper = pr_cdcooper 
         AND cre.nrcnvcob = pr_nrcnvcob 
         AND cre.dtmvtolt = pr_dtmvtolt
         AND cre.intipmvt = pr_intipmvt
       ORDER BY cre.progress_recid DESC;
    rw_crapcre cr_crapcre%ROWTYPE;
       
    -- Buscar Controle de Remessa/Retorno de Titulos Bancarios
    CURSOR cr_crapcre2(pr_cdcooper  crapcre.cdcooper%TYPE,
                       pr_nrcnvcob  crapcre.nrcnvcob%TYPE,
                       pr_intipmvt  crapcre.intipmvt%TYPE) IS
      SELECT cre.nrremret
        FROM crapcre cre
       WHERE cre.cdcooper = pr_cdcooper 
         AND cre.nrcnvcob = pr_nrcnvcob 
         AND cre.intipmvt = pr_intipmvt
       ORDER BY cre.progress_recid DESC;
    rw_crapcre2 cr_crapcre2%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ----------------------
    vr_rejeitado  typ_rec_rejeitado;
    
    ------------------------------- VARIAVEIS --------------------------------
    vr_nrremrtc INTEGER;
    vr_nrremcre INTEGER;
    vr_nrseqreg INTEGER;

  BEGIN
  
    -- Percorrer todos os registros rejeitados
    FOR vr_idx IN 1..pr_tab_rejeitado.COUNT() LOOP
      
      vr_rejeitado := pr_tab_rejeitado(vr_idx);
      
      --- Localiza o ultimo RTC desta data ---
      OPEN cr_craprtc(pr_cdcooper => vr_rejeitado.cdcooper
                     ,pr_nrdconta => vr_rejeitado.nrdconta
                     ,pr_nrcnvcob => vr_rejeitado.nrcnvcob
                     ,pr_dtmvtolt => vr_rejeitado.dtmvtolt
                     ,pr_intipmvt => 2);
                     
      FETCH cr_craprtc INTO rw_craprtc;
      
      IF cr_craprtc%NOTFOUND THEN 
        -- Fecha o cursor
        CLOSE cr_craprtc;
        
        -- Utilizar a SEQUENCE para gerar o numero de remessa do cooperado
        vr_nrremrtc := fn_sequence(pr_nmtabela => 'CRAPRTC'
                                  ,pr_nmdcampo => 'NRREMRET'
                                  ,pr_dsdchave => vr_rejeitado.cdcooper || ';' || 
                                                  vr_rejeitado.nrdconta || ';' || 
                                                  vr_rejeitado.nrcnvcob || ';2');
        
        -- Insere registro
        INSERT INTO craprtc(cdcooper
                           ,nrdconta
                           ,nrcnvcob
                           ,dtmvtolt
                           ,nrremret
                           ,nmarquiv
                           ,flgproce
                           ,cdoperad
                           ,dtaltera
                           ,hrtransa
                           ,dtdenvio
                           ,qtreglot
                           ,intipmvt)
                     VALUES(vr_rejeitado.cdcooper
                           ,vr_rejeitado.nrdconta
                           ,vr_rejeitado.nrcnvcob
                           ,vr_rejeitado.dtmvtolt
                           ,vr_nrremrtc
                           ,vr_rejeitado.nmarqrtc
                           ,0 -- NO
                           ,vr_rejeitado.cdoperad
                           ,vr_rejeitado.dtmvtolt
                           ,GENE0002.fn_busca_time
                           ,NULL
                           ,1
                           ,2);
      ELSE
        -- Fecha cursor
        CLOSE cr_craprtc;
        vr_nrremrtc := rw_craprtc.nrremret;
      END IF;
      
      --- Localiza o ultimo CRE desta data ---
      OPEN cr_crapcre(pr_cdcooper => vr_rejeitado.cdcooper
                     ,pr_nrcnvcob => vr_rejeitado.nrcnvcob
                     ,pr_dtmvtolt => vr_rejeitado.dtmvtolt
                     ,pr_intipmvt => 2);
                     
      FETCH cr_crapcre INTO rw_crapcre;
      
      IF cr_crapcre%NOTFOUND THEN 
        -- Fecha o cursor
        CLOSE cr_crapcre;
        
        -- Localiza ultima sequencia
        OPEN cr_crapcre2(pr_cdcooper => vr_rejeitado.cdcooper
                        ,pr_nrcnvcob => vr_rejeitado.nrcnvcob
                        ,pr_intipmvt => 2);
        FETCH cr_crapcre2 INTO rw_crapcre2;
        
        -- Verifica se encontrou 
        IF cr_crapcre2%NOTFOUND THEN 
          vr_nrremcre := 999999;
        ELSE
          vr_nrremcre := rw_crapcre2.nrremret + 1;
        END IF;
        
        -- Fecha o cursor
        CLOSE cr_crapcre2;
        
        -- Insere registro
        INSERT INTO crapcre(cdcooper
                           ,nrcnvcob
                           ,dtmvtolt
                           ,nrremret
                           ,intipmvt
                           ,nmarquiv
                           ,flgproce
                           ,cdoperad
                           ,dtaltera
                           ,hrtranfi)
                     VALUES(vr_rejeitado.cdcooper
                           ,vr_rejeitado.nrcnvcob
                           ,vr_rejeitado.dtmvtolt
                           ,vr_nrremcre
                           ,2
                           ,vr_rejeitado.nmarqcre
                           ,1 -- YES
                           ,vr_rejeitado.cdoperad
                           ,vr_rejeitado.dtaltera
                           ,GENE0002.fn_busca_time);
      ELSE
        -- Fecha cursor
        CLOSE cr_crapcre;
        vr_nrremcre := rw_crapcre.nrremret;
      END IF;

      -- A busca do sequencial do nrseqreg sera atraves de sequence no Oracle
      -- CDCOOPER;NRCNVCOB;NRREMRET
      vr_nrseqreg := fn_sequence(pr_nmtabela => 'CRAPRET'
                                ,pr_nmdcampo => 'NRSEQREG'
                                ,pr_dsdchave => vr_rejeitado.cdcooper||';'||
                                                vr_rejeitado.nrcnvcob||';'||
                                                vr_nrremcre
                                ,pr_flgdecre => 'N');
                                
      -- Insere registro
      INSERT INTO crapret(cdcooper
                         ,nrcnvcob
                         ,nrdconta
                         ,nrdocmto
                         ,nrretcoo
                         ,nrremret
                         ,nrseqreg
                         ,cdocorre
                         ,cdmotivo
                         ,vltitulo
                         ,vlabatim
                         ,vldescto
                         ,vltarass
                         ,vltarcus
                         ,cdbcorec
                         ,cdagerec
                         ,dtocorre
                         ,cdoperad
                         ,dtaltera
                         ,hrtransa
                         ,nrnosnum
                         ,dsdoccop
                         ,nrremass
                         ,dtvencto)
                   VALUES(vr_rejeitado.cdcooper
                         ,vr_rejeitado.nrcnvcob
                         ,vr_rejeitado.nrdconta
                         ,0
                         ,vr_nrremrtc -- Ultimo da RTC
                         ,vr_nrremcre -- Ultimo da CRE
                         ,vr_nrseqreg -- Ultimo da RET
                         ,vr_rejeitado.cdocorre
                         ,nvl(trim(vr_rejeitado.cdmotivo),' ')
                         ,vr_rejeitado.vltitulo
                         ,0
                         ,0
                         ,0
                         ,0
                         ,vr_rejeitado.cdbcorec
                         ,vr_rejeitado.cdagerec
                         ,vr_rejeitado.dtocorre
                         ,vr_rejeitado.cdoperad
                         ,vr_rejeitado.dtaltera
                         ,GENE0002.fn_busca_time
                         ,vr_rejeitado.nrnosnum
                         ,vr_rejeitado.dsdoccop
                         ,vr_rejeitado.nrremass
                         ,vr_rejeitado.dtvencto);
    END LOOP;
    
  EXCEPTION 
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na COBR0006.pc_processa_rejeitados --> ' || SQLERRM;
  END pc_processa_rejeitados;

  --> Procedure para processar os titulos que foram identificados no arquivo
  PROCEDURE pc_processa_sacados(pr_tab_sacado  IN typ_tab_sacado --> Tabela de sacados
                               ,pr_cdcritic   OUT INTEGER        --> Codigo da Critica
                               ,pr_dscritic   OUT VARCHAR2 ) IS  --> Descricao da Critica
  /* ............................................................................

       Programa: pc_processa_sacados
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Janeiro/2016                     Ultima atualizacao: 16/05/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Atualizar as informacoes dos sacados

       Alteracoes: 27/01/2016 - Conversão Progress -> Oracle (Douglas Quisinski)
				   
                   25/11/2016 - Correção dos caracteres invelidos no nome do sacado (Gil Furtado - MOUTS)     
           
                   02/12/2016 - Ajuste para tratar nome da cidade, nome do bairro e uf nulos 
  						               		(Andrei - RKAM).     
                   
                   16/05/2017 - Implementado melhorias para nao ocorrer estouro de chave
                                qdo inserir a crapsab (Tiago/Rodrigo #663284)
                                
                   26/07/2017 - Ajuste no insert da tabela crapsab, onde estava sendo inserido
                                na coluna nrcelsac o valor do cep e tambem corrigido para inserir a 
                                situacao como ativo, antes estava assumindo o valor 0 por default 
                                (Rafael Monteiro - 720045)    
						 
			       26/06/2019 - Ajuste para retirar acentos e caracteres especiais do sacado
				                Alcemir Jr. (PRB0041807).                            
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    ------------------------------- CURSORES ---------------------------------    
    CURSOR cr_crapsab(pr_cdcooper crapsab.cdcooper%TYPE,
                      pr_nrdconta crapsab.nrdconta%TYPE,
                      pr_nrinssac crapsab.nrinssac%TYPE) IS
      SELECT sab.rowid
            ,sab.nrendsac
            ,sab.dsendsac
            ,sab.nrcelsac
        FROM crapsab sab
       WHERE sab.cdcooper = pr_cdcooper
         AND sab.nrdconta = pr_nrdconta
         AND sab.nrinssac = pr_nrinssac;
    rw_crapsab cr_crapsab%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ----------------------
    vr_sacado  typ_rec_sacado;
    ------------------------------- VARIAVEIS --------------------------------
    vr_nrendsac INTEGER;
	vr_nmdsacad crapsab.nmdsacad%type;
	vr_nmbaisac crapsab.nmbaisac%TYPE; 
    vr_nmcidsac crapsab.nmcidsac%TYPE; 
    vr_dsendsac crapsab.dsendsac%TYPE; 

  BEGIN
  
    -- Percorrer todos os registros rejeitados
    FOR vr_idx IN 1..pr_tab_sacado.COUNT() LOOP
      vr_sacado := pr_tab_sacado(vr_idx);
  	  -- Limpar Variavel vr_nmdsacad
      vr_nmdsacad := '';
      -- remover caracter especial vr_nmdsacad
      vr_nmdsacad := gene0007.fn_caract_acento(vr_sacado.nmdsacad, 1, '@#$&%¹²³ªº°*!?<>/\|€', '                    ');
	  vr_nmbaisac := gene0007.fn_caract_acento(vr_sacado.nmbaisac, 1, '@#$&%¹²³ªº°*!?<>/\|€', '                    ');
      vr_nmcidsac := gene0007.fn_caract_acento(vr_sacado.nmcidsac, 1, '@#$&%¹²³ªº°*!?<>/\|€', '                    ');
      vr_dsendsac := gene0007.fn_caract_acento(vr_sacado.dsendsac, 1, '@#$&%¹²³ªº°*!?<>/\|€', '                    ');
      
      BEGIN
        -- Se nao existe o sacado, vamos cadastrar
        INSERT INTO crapsab(cdcooper
                           ,nrdconta
                           ,nmdsacad
                           ,cdtpinsc
                           ,nrinssac
                           ,dsendsac
                           ,nrendsac
                           ,nmbaisac
                           ,nmcidsac
                           ,cdufsaca
                           ,nrcepsac
                           ,cdoperad
                           ,dtmvtolt
                           ,nrcelsac
                           ,cdsitsac)
                    VALUES(vr_sacado.cdcooper
                          ,vr_sacado.nrdconta
                          ,vr_nmdsacad
                          ,vr_sacado.cdtpinsc
                          ,vr_sacado.nrinssac
                          ,vr_dsendsac
                          ,0
                          ,nvl(trim(vr_nmbaisac),' ')
                          ,nvl(trim(vr_nmcidsac),' ')
                          ,nvl(trim(vr_sacado.cdufsaca),' ')
                          ,vr_sacado.nrcepsac
                          ,vr_sacado.cdoperad
                          ,vr_sacado.dtmvtolt
                          ,nvl(vr_sacado.nrcelsac,0)
                          ,1); -- Ativo
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          -- Sacado possui registro
          OPEN cr_crapsab (pr_cdcooper => vr_sacado.cdcooper
                          ,pr_nrdconta =>  vr_sacado.nrdconta
                          ,pr_nrinssac => vr_sacado.nrinssac);
          FETCH cr_crapsab INTO rw_crapsab;

          -- Fecha cursor
          CLOSE cr_crapsab;
          
          IF rw_crapsab.dsendsac <> vr_sacado.dsendsac THEN
            vr_nrendsac:= 0;
          ELSE
            vr_nrendsac:= rw_crapsab.nrendsac;
          END IF;
          
          -- Se o sacado existir, Efetua atualizacao dados do sacado
          UPDATE crapsab
             SET crapsab.nmdsacad = vr_nmdsacad
                ,crapsab.dsendsac = vr_sacado.dsendsac
                ,crapsab.nrendsac = vr_nrendsac
                ,crapsab.nmbaisac = nvl(trim(vr_sacado.nmbaisac),' ')
                ,crapsab.nrcepsac = vr_sacado.nrcepsac
                ,crapsab.nmcidsac = nvl(trim(vr_sacado.nmcidsac),' ')
                ,crapsab.cdufsaca = nvl(trim(vr_sacado.cdufsaca),' ')
                ,crapsab.cdoperad = vr_sacado.cdoperad
                ,crapsab.dtmvtolt = vr_sacado.dtmvtolt
                ,crapsab.nrcelsac = nvl(TRIM(vr_sacado.nrcelsac),rw_crapsab.nrcelsac)
           WHERE crapsab.rowid = rw_crapsab.rowid;
      END;
    END LOOP;
      
  EXCEPTION 
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na COBR0006.pc_processa_sacados --> ' || SQLERRM;
  END pc_processa_sacados;
  
  --> Gerar o protocolo da transacao
  PROCEDURE pc_protocolo_transacao(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                  ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                  ,pr_cddbanco  IN crapcco.cddbanco%TYPE --> Codigo do Banco
                                  ,pr_nrconven  IN crapcco.nrconven%TYPE --> Numero do Convenio
                                  ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                  ,pr_qtbloque  IN INTEGER               --> Quantidade de Boletos Processados
                                  ,pr_vlrtotal  IN crapcob.vltitulo%TYPE --> Valor Totall dos Boletos
                                  ,pr_nmarquiv  IN OUT VARCHAR2          --> Nome do Arquivo
                                  ,pr_nrprotoc OUT VARCHAR2              --> Numero do Protocolo
                                  ,pr_hrtransa OUT INTEGER               --> Hora da Transacao
                                  ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                  ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
  /* ............................................................................

       Programa: pc_protocolo_transacao           Antiga: b1wgen0090.p/pi_protocolo_transacao    
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Janeiro/2016                     Ultima atualizacao: 28/01/2016

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Gerar o protocolo da transacao

       Alteracoes: 28/01/2016 - Conversão Progress -> Oracle (Douglas Quisinski)
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_des_erro   VARCHAR2(1000);

    ------------------------------- CURSORES ---------------------------------    
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.dsdircop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.nmprimtl 
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ----------------------
    
    ------------------------------- VARIAVEIS --------------------------------
    vr_dsinfor1 crappro.dsinform##1%TYPE;
    vr_dsinfor2 crappro.dsinform##2%TYPE;
    vr_dsinfor3 crappro.dsinform##3%TYPE;
    
  BEGIN
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
    
    -- Buscar as informacoes do Cooperado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- Se não encontrar
    IF cr_crapass%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapass;
      -- Montar mensagem de critica
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapass;
    END IF;
    
    -- Campos gravados na crappro para visualizacao na internet
    pr_hrtransa := GENE0002.fn_busca_time;
    pr_nmarquiv := REPLACE(REPLACE(pr_nmarquiv, 
                                   gene0002.fn_mask(pr_cdcooper, '999') || '.' || 
                                   pr_nrdconta || '.', ''),
                          '/usr/coop/' || rw_crapcop.dsdircop || '/upload/', '');
    vr_dsinfor1 := 'Arquivo Remessa Cobranca';
    vr_dsinfor2 := rw_crapass.nmprimtl ||
                   '#Convenio: ' || gene0002.fn_mask(pr_cddbanco, '999') ||
                   '/' || pr_nrconven;
    vr_dsinfor3 := 'Total de Boletos: ' || pr_qtbloque || '#Arquivo: ' || pr_nmarquiv;
    
    -- Gera um protocolo para o pagamento
    GENE0006.pc_gera_protocolo(pr_cdcooper => pr_cdcooper
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_hrtransa => pr_hrtransa
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdocmto => pr_nrremass
                              ,pr_nrseqaut => 0
                              ,pr_vllanmto => pr_vlrtotal
                              ,pr_nrdcaixa => 0
                              ,pr_gravapro => TRUE
                              ,pr_cdtippro => 7
                              ,pr_dsinfor1 => vr_dsinfor1
                              ,pr_dsinfor2 => vr_dsinfor2
                              ,pr_dsinfor3 => vr_dsinfor3
                              ,pr_dscedent => ''
                              ,pr_flgagend => FALSE
                              ,pr_nrcpfope => 0
                              ,pr_nrcpfpre => 0
                              ,pr_nmprepos => ''
                              ,pr_dsprotoc => pr_nrprotoc
                              ,pr_dscritic => vr_dscritic
                              ,pr_des_erro => vr_des_erro);
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL OR vr_des_erro IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
      pr_cdcritic:= NVL(vr_cdcritic,0);
      pr_dscritic:= vr_dscritic;
     
    WHEN OTHERS THEN
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro geral na GENE0006.pc_protocolo_transacao -> ' || SQLERRM;
  
  END pc_protocolo_transacao;
  
  --> Gravar Controle de Remessa/Retorno de Titulos do Cooperado
  PROCEDURE pc_grava_rtc( pr_cdcooper  IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                          pr_nrdconta  IN crapass.nrdconta%TYPE, --> Numero da conta do cooperado
                          pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE, --> Numero do documento
                          pr_nrremass  IN crapcob.nrremass%TYPE, --> Codigo de critica
                          pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE, --> Data de Movimento
                          pr_nmarquiv  IN craprtc.nmarquiv%TYPE, --> Nome do Arquivo
                          pr_cdoperad  IN crapope.cdoperad%TYPE, --> Operador
                          pr_tab_crawrej   IN OUT NOCOPY typ_tab_crawrej, --> Tabela de Rejeitados
                          pr_des_reto OUT VARCHAR2) IS           --> Retorno OK/NOK
  /* ............................................................................
       Programa: pc_grava_rtc                     Antiga: b1wgen0090.p/pi_grava_rtc
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Janeiro/2016                     Ultima atualizacao: 13/02/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Gravar Controle de Remessa/Retorno de Titulos do Cooperado

       Alteracoes: 29/01/2016 - Conversão Progress -> Oracle (Douglas)

	               13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 

    ............................................................................ */   
     
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    rw_craprtc COBR0006.cr_craprtc%ROWTYPE;
    
  BEGIN
    OPEN cr_craprtc (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrcnvcob => pr_nrcnvcob
                    ,pr_nrremret => pr_nrremass
                    ,pr_intipmvt => 1);
                    
    FETCH cr_craprtc INTO rw_craprtc;
    
    IF cr_craprtc%FOUND THEN
      -- Fecha o Cursor
      CLOSE cr_craprtc;
      
      -- Lote de remessa ja processado
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_nrdocmto => 999999,
                       pr_dscritic => GENE0001.fn_busca_critica(pr_cdcritic => 59) ||
                                      ' - Remessa: ' || pr_nrremass,
                       pr_tab_crawrej => pr_tab_crawrej);
                       
      pr_des_reto := 'NOK';
      
    ELSE
      
      -- Fecha o Cursor      
      CLOSE cr_craprtc;
      
      -- Controle de Remessa/Retorno de Titulos do Cooperado
      INSERT INTO craprtc (cdcooper
                          ,nrdconta
                          ,nrcnvcob
                          ,dtmvtolt
                          ,nrremret
                          ,nmarquiv
                          ,flgproce
                          ,cdoperad
                          ,dtaltera
                          ,hrtransa
                          ,dtdenvio
                          ,qtreglot
                          ,intipmvt)
                   VALUES (pr_cdcooper
                          ,pr_nrdconta
                          ,pr_nrcnvcob
                          ,pr_dtmvtolt
                          ,pr_nrremass
                          ,pr_nmarquiv
                          ,0 -- NO
                          ,pr_cdoperad
                          ,pr_dtmvtolt
                          ,GENE0002.fn_busca_time
                          ,NULL
                          ,1
                          ,1);
                          
      pr_des_reto := 'OK';
      
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      -- Lote de remessa ja processado
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_nrdocmto => 999999,
                       pr_dscritic => 'Erro geral na GENE0006.pc_grava_rtc -> ' || SQLERRM,
                       pr_tab_crawrej => pr_tab_crawrej);
      pr_des_reto:= 'NOK';
  END pc_grava_rtc;
  
  --> Cria registro de rejeito para identificar a linha rejeitada
  PROCEDURE pc_cria_rejeitado (pr_tpcritic IN INTEGER                         --> Tipo da critica
                              ,pr_nrlinseq IN VARCHAR2 DEFAULT ' '            --> Número sequencial da linha com problema
                              ,pr_cdseqcri IN INTEGER                         --> Código sequencial da critica
                              ,pr_seqdetal IN VARCHAR2 DEFAULT ' '            --> Detalhes
                              ,pr_dscritic IN VARCHAR2                        --> Dscrição da critica
                              ,pr_tab_rejeita IN OUT NOCOPY COBR0006.typ_tab_rejeita --> Contem as linhas rejeitadas
                              ,pr_critica OUT VARCHAR2                        --> Descricao do erro 
                              ,pr_des_reto OUT VARCHAR2) IS                   --> Retorno OK/NOK     
         
  /* ............................................................................

       Programa: pc_cria_rejeitado          
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrei -RKAM
       Data    : Marco/2016.                   Ultima atualizacao: 13/02/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Cria registros para identificar linhas rejeitadas

       Alteracoes: 13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 
    ............................................................................ */   
    
    vr_index INTEGER;
                          
  BEGIN
    
    vr_index := pr_tab_rejeita.COUNT() + 1;
    
    pr_tab_rejeita(vr_index).tpcritic := pr_tpcritic;
    pr_tab_rejeita(vr_index).nrlinseq := pr_nrlinseq;
    pr_tab_rejeita(vr_index).cdseqcri := pr_cdseqcri;
    pr_tab_rejeita(vr_index).dscritic := pr_dscritic; --substr(pr_dscritic,1,72);
    pr_tab_rejeita(vr_index).seqdetal := pr_seqdetal;
            
    pr_des_reto := 'OK';
    
  EXCEPTION          
    WHEN OTHERS THEN    
       pr_critica := 'Erro geral na COBR0006.pc_cria_rejeitado -> ' || SQLERRM;
       pr_des_reto := 'NOK';
           
  END pc_cria_rejeitado;   
                                                                          
  --> Verifica o tipo de arquivo
  PROCEDURE pc_identifica_arq_cnab (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                   ,pr_nmarqint IN VARCHAR2               --> Nome do arquivo
                                   ,pr_tparquiv OUT VARCHAR2              --> Tipo do arquivo
                                   ,pr_cddbanco OUT INTEGER               --> Codigo do banco
								   ,pr_nrdconta OUT crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                   ,pr_rec_rejeita OUT COBR0006.typ_tab_rejeita --> Tabela com rejeitados
                                   ,pr_cdcritic OUT INTEGER               --> Código da critica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da critica
                                   ,pr_des_reto OUT VARCHAR2) IS          --> Retorno OK/NOK                                    
                                   
  /* ............................................................................

       Programa: pc_identifica_arq_cnab        antigo: b1wgen0010/identifica-arq-cnab
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrei - RKAM
       Data    : Marco/2016.                   Ultima atualizacao:  31/12/2018

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Identifica qual o tipo de arquivo de cobranca.

       Alteracoes:  31/12/2018 - Alterar mensagem de erro de "Arquivo CNAB invalido."
                                 para "Arquivo de remessa fora do layout."
                                 (Douglas - INC0029384)
    ............................................................................ */   
    
    ------------------------ VARIAVEIS  ----------------------------
    -- Tratamento de erros
    vr_exc_reje   EXCEPTION;
    vr_exc_fim    EXCEPTION;
    vr_cdcritic   INTEGER;
    vr_dscritic   VARCHAR2(4000);
    
    vr_dsdireto     VARCHAR2(500);
    vr_nmarquiv     VARCHAR2(500);
    vr_contaerr     INTEGER := 0;
    vr_des_reto     VARCHAR2(10);
    
    vr_dslinha    VARCHAR2(4000);            
     
    vr_ind_arquiv utl_file.file_type;
    
    -- Tratamento de erros
		vr_exc_saida EXCEPTION;
    
  BEGIN

    IF trim(pr_nmarqint) IS NULL THEN
      
      vr_contaerr:= vr_contaerr + 1;
      
      COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                ,pr_nrlinseq => '99999'
                                ,pr_cdseqcri => vr_contaerr
                                ,pr_dscritic => 'Arquivo nao encontrado.'
                                ,pr_tab_rejeita => pr_rec_rejeita 
                                ,pr_critica => vr_dscritic      
                                ,pr_des_reto => vr_des_reto);
      
      pr_des_reto:= 'NOK';                                  
      RETURN;
    
    END IF;
    
    -- separa diretorio e nmarquivo
    gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmarqint, 
                                    pr_direto  => vr_dsdireto, 
                                    pr_arquivo => vr_nmarquiv);

    --Abrir arquivo
    gene0001.pc_abre_arquivo ( pr_nmdireto => vr_dsdireto    --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nmarquiv    --> Nome do arquivo
                              ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arquiv  --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);  --> Erro
                      
    IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
    END IF;
          
    BEGIN
      LOOP
        -- Verifica se o arquivo está aberto
        IF utl_file.IS_OPEN(vr_ind_arquiv) THEN
          
          -- Ler linha
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                                      ,pr_des_text => vr_dslinha);  --> Texto lido
             
          IF NOT (length(vr_dslinha) = 240 OR
                  length(vr_dslinha) = 241 OR
                  length(vr_dslinha) = 400 OR
                  length(vr_dslinha) = 401) THEN
           
            vr_contaerr:= vr_contaerr + 1;
      
            COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                      ,pr_nrlinseq => '99999'
                                      ,pr_cdseqcri => vr_contaerr
                                      ,pr_dscritic => 'Arquivo de remessa fora do layout.'
                                      ,pr_tab_rejeita => pr_rec_rejeita 
                                      ,pr_critica => vr_dscritic      
                                      ,pr_des_reto => vr_des_reto);
            
            pr_des_reto:= 'NOK';                                  
            RETURN;
            
          END IF;
                                  
          IF length(vr_dslinha) = 240 OR 
             length(vr_dslinha) = 241 THEN
             
            pr_tparquiv := 'CNAB240';
            
          ELSIF length(vr_dslinha) = 400 OR 
                length(vr_dslinha) = 401 THEN
             
            pr_tparquiv := 'CNAB400';
            
          ELSE
            
            pr_tparquiv := 'NOK';
          
          END IF;
          
          IF pr_tparquiv = 'CNAB240' THEN
            
            BEGIN 
            pr_cddbanco := to_number(substr(vr_dslinha,1,3));
            EXCEPTION
              WHEN OTHERS THEN
                vr_contaerr:= vr_contaerr + 1;
          
                COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                          ,pr_nrlinseq => '99999'
                                          ,pr_cdseqcri => vr_contaerr
                                          ,pr_dscritic => 'Codigo do banco invalido.'
                                          ,pr_tab_rejeita => pr_rec_rejeita 
                                          ,pr_critica => vr_dscritic      
                                          ,pr_des_reto => vr_des_reto);
                
                pr_des_reto:= 'NOK';                                  
                RETURN;

            END;
            

            BEGIN 
		    pr_nrdconta := to_number(substr(vr_dslinha,59,13));
            EXCEPTION
              WHEN OTHERS THEN 
                vr_contaerr:= vr_contaerr + 1;
          
                COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                          ,pr_nrlinseq => '99999'
                                          ,pr_cdseqcri => vr_contaerr
                                          ,pr_dscritic => 'Codigo da conta invalido.'
                                          ,pr_tab_rejeita => pr_rec_rejeita 
                                          ,pr_critica => vr_dscritic      
                                          ,pr_des_reto => vr_des_reto);
                
                pr_des_reto:= 'NOK';                                  
                RETURN;
                
            END;
            
            
            
          ELSIF pr_tparquiv = 'CNAB400' THEN
            
            BEGIN 
            pr_cddbanco := to_number(substr(vr_dslinha,77,3));
            EXCEPTION
              WHEN OTHERS THEN
                vr_contaerr:= vr_contaerr + 1;
          
                COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                          ,pr_nrlinseq => '99999'
                                          ,pr_cdseqcri => vr_contaerr
                                          ,pr_dscritic => 'Codigo do banco invalido.'
                                          ,pr_tab_rejeita => pr_rec_rejeita 
                                          ,pr_critica => vr_dscritic      
                                          ,pr_des_reto => vr_des_reto);
                
                pr_des_reto:= 'NOK';                                  
                RETURN;
                
            END;

            BEGIN 
			pr_nrdconta := to_number(substr(vr_dslinha,32,9));
            EXCEPTION
              WHEN OTHERS THEN
                vr_contaerr:= vr_contaerr + 1;
          
                COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                          ,pr_nrlinseq => '99999'
                                          ,pr_cdseqcri => vr_contaerr
                                          ,pr_dscritic => 'Codigo da conta invalido.'
                                          ,pr_tab_rejeita => pr_rec_rejeita 
                                          ,pr_critica => vr_dscritic      
                                          ,pr_des_reto => vr_des_reto);
                
                pr_des_reto:= 'NOK';                                  
                RETURN;
                
            END;		      
                                
          END IF;           
        
          IF pr_cddbanco <> 1  AND
             pr_cddbanco <> 85 THEN
            
            vr_contaerr:= vr_contaerr + 1;
      
            COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                      ,pr_nrlinseq => '99999'
                                      ,pr_cdseqcri => vr_contaerr
                                      ,pr_dscritic => 'Codigo do banco invalido.'
                                      ,pr_tab_rejeita => pr_rec_rejeita 
                                      ,pr_critica => vr_dscritic      
                                      ,pr_des_reto => vr_des_reto);
            
            pr_des_reto:= 'NOK';                                  
            RETURN;
                         
          END IF; 
        
        END IF;
        
        EXIT;
        
      END LOOP;
      
    EXCEPTION
      WHEN no_data_found THEN
        -- Fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    END; 
      
    pr_des_reto := 'OK';
  
  EXCEPTION 
    WHEN vr_exc_saida  THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := pr_dscritic;
      
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      
      pr_des_reto:= 'NOK';        
      
    WHEN OTHERS THEN
      -- Alimenta críticas parametrizadas
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na procedure COBR0006.pc_identifica_arq_cnab --> ' || SQLERRM;
      
      pr_des_reto:= 'NOK';    
       
  END pc_identifica_arq_cnab;
  
  PROCEDURE pc_altera_email_cel_sacado (pr_cdcooper IN crapcop.cdcooper%TYPE --Cooperativa 
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE --Conta
                                       ,pr_nrinssac IN crapsab.nrinssac%TYPE --Inscrição do sacado
                                       ,pr_dsdemail IN VARCHAR2              --E-mail
                                       ,pr_nrcelsac IN crapsab.nrcelsac%TYPE --Número do celular
                                       ,pr_des_erro OUT VARCHAR2             --Retorno OK/NOK
                                       ,pr_cdcritic OUT INTEGER              --Codigo Critica
                                       ,pr_dscritic OUT VARCHAR2)IS          --Tabela de erros 
                                
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_altera_email_cel_sacado                            antiga: b1wgen0090/p_altera_email_cel_sacado
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Marco/2016                           Ultima atualizacao: 05/10/2016
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Alterar e-mail dos sacados
    
    Alterações : 05/10/2016 - Ajustes referente a melhoria M271 (Kelvin)
    -------------------------------------------------------------------------------------------------------------*/                                
  
    CURSOR cr_crapsab(pr_cdcooper IN crapsab.cdcooper%TYPE
                     ,pr_nrdconta IN crapsab.nrdconta%TYPE
                     ,pr_nrinssac IN crapsab.nrinssac%TYPE) IS
    SELECT crapsab.nrcelsac
      FROM crapsab 
     WHERE crapsab.cdcooper = pr_cdcooper
       AND crapsab.nrdconta = pr_nrdconta
       AND crapsab.nrinssac = pr_nrinssac;
    rw_crapsab cr_crapsab%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER := 0;
    vr_dscritic VARCHAR2(4000):= NULL;
    vr_des_erro VARCHAR2(1000);
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;
    
    --Variaveis locais 
    vr_dsdemail VARCHAR2(5000);
    
    --> Tabela de retorno do operadores que estao alocando a tabela especifidada
    vr_tab_locktab GENE0001.typ_tab_locktab;
    
    -- Variável exceção para locked
    vr_exc_locked EXCEPTION;
    PRAGMA EXCEPTION_INIT(vr_exc_locked, -54);
    
  BEGIN
  
    vr_dsdemail := TRIM(pr_dsdemail);
    
    IF nvl(pr_nrinssac,0) = 0 THEN
      
      RAISE vr_exc_saida;
    
    END IF;
    
    /* Se o e-mail foi preenchido, temos que verificar se ele eh valido */
    IF vr_dsdemail IS NOT NULL THEN
      
      
      IF GENE0003.fn_valida_email(pr_dsdemail => vr_dsdemail) <> 1 THEN
        
        vr_cdcritic := 0;
        vr_dscritic := 'Email invalido.';
      
        RAISE vr_exc_erro;
        
      END IF;
    
    
    END IF;
    
    BEGIN
      -- Busca sacado
      OPEN cr_crapsab(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrinssac => pr_nrinssac);
                      
      FETCH cr_crapsab INTO rw_crapsab;
           
      -- Se não encontrar apenas aborta rotina
      IF cr_crapsab%NOTFOUND THEN
        
        -- Fechar cursor pois teremos raise
        CLOSE cr_crapsab;
         
        -- Gera exceção
        RAISE vr_exc_saida;
         
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapsab;
        
      END IF; 
        
    EXCEPTION
      WHEN vr_exc_locked THEN
        gene0001.pc_ver_lock(pr_nmtabela    => 'CRAPSAB'
                            ,pr_nrdrecid    => ''
                            ,pr_des_reto    => pr_des_erro
                            ,pt_tab_locktab => vr_tab_locktab);
                            
        IF pr_des_erro = 'OK' THEN
          FOR VR_IND IN 1..vr_tab_locktab.COUNT LOOP
            vr_dscritic := 'Registro sendo alterado em outro terminal (CRAPSAB)' || 
                           ' - ' || vr_tab_locktab(VR_IND).nmusuari;
          END LOOP;
        END IF;
        
        RAISE vr_exc_erro;
         
    END;   
    
    
    --Realiza a alteração do registro de sacado                          
    BEGIN
            
      UPDATE crapsab SET crapsab.nrcelsac = (CASE 
                                               WHEN nvl(pr_nrcelsac,0) <> 0            AND 
                                                    pr_nrcelsac <> rw_crapsab.nrcelsac THEN 
                                                 pr_nrcelsac 
                                               ELSE 
                                                 rw_crapsab.nrcelsac
                                             END)                        
                  WHERE crapsab.cdcooper = pr_cdcooper
                    AND crapsab.nrdconta = pr_nrdconta
                    AND crapsab.nrinssac = pr_nrinssac;
                      
    EXCEPTION
      WHEN OTHERS THEN      
        --Monta mensagem de erro
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel atualizar o email do sacado - ' || sqlerrm;
        
        RAISE vr_exc_erro;             
    
    END;
    
    -- Realizar a gravação do email do pagador    
    COBR0009.pc_grava_email_pagador(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrinssac => pr_nrinssac
                                   ,pr_dsdemail => vr_dsdemail
                                   ,pr_des_erro => vr_des_erro
                                   ,pr_dscritic => vr_dscritic);
    -- Validacao de erro 
    IF vr_des_erro <> 'OK' THEN
      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := 'Nao foi possivel atualizar o email do sacado - COBR0009.pc_grava_email_pagador';
      END IF;
      RAISE vr_exc_erro;
    END IF;
    
    --Retorno OK
    pr_des_erro:= 'OK';  
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      -- Retorno não OK          
      pr_des_erro:= 'NOK';   
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
      
             
    WHEN vr_exc_saida THEN
      
      -- Retorno OK          
      pr_des_erro:= 'OK';   
      
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= '';
          
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
          
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_altera_email_cel_sacado --> '|| SQLERRM;       
       
  END pc_altera_email_cel_sacado;     
  
  --> Realiza a validação dos arquivos de cobranca
  PROCEDURE pc_valida_arquivo_cobranca (pr_cdcooper    IN crapcop.cdcooper%TYPE,     --> Codigo da cooperativa
                                        pr_nmarqint    IN VARCHAR2,                  --> Nome do arquivo a ser validado
                                        pr_tpenvcob    IN crapceb.inenvcob%TYPE DEFAULT 1,--> Tipo de envio do arquivo (1-Envio via Internet Bank, 2-Envio via FTP)
                                        pr_rec_rejeita OUT COBR0006.typ_tab_rejeita, --> Dados invalidados
                                        pr_des_reto    OUT VARCHAR2)IS               --> Retorno OK/NOK
                                         
  /* ............................................................................

       Programa: pc_valida_arquivo_cobranca                                  antigo: b1wgen0010/valida-arquivo-cobranca
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrei - RKAM
       Data    : Marco/2016.                   Ultima atualizacao: 02/12/2016 

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Realiza a validação dos arquivos de cobranca

       Alteracoes: 02/12/2016 - Ajuste para levantar exception (NOK) quando for encontrado registro de rejeição
                                (Andrei - RKAM).
    ............................................................................ */   
    
    ------------------------ VARIAVEIS  ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    vr_des_reto   VARCHAR2(4);

    vr_tparquiv   VARCHAR2(100);
    vr_cddbanco   INTEGER;
	vr_nrdconta   crapass.nrdconta%TYPE;
    
  BEGIN
       
    COBR0006.pc_identifica_arq_cnab (pr_cdcooper => pr_cdcooper,  --> Codigo da cooperativa
                                     pr_nmarqint => pr_nmarqint,  --> Numero da conta do cooperado
                                     pr_tparquiv => vr_tparquiv,  --> Data de movimento
                                     pr_cddbanco => vr_cddbanco,  --> Operador
									 pr_nrdconta => vr_nrdconta,  --> Conta do cooperado (header do arq)
                                     pr_rec_rejeita => pr_rec_rejeita, --> Tabela com rejeitados
                                     pr_cdcritic => vr_cdcritic,  --> Código da critica
                                     pr_dscritic => vr_dscritic,  -->Descrição da critica
                                     pr_des_reto => vr_des_reto); --> Retorno OK/NOK   
                                        
    IF vr_des_reto <> 'OK' THEN
      
      RAISE vr_exc_erro;
    
    END IF;                                         
    
    IF vr_tparquiv = 'CNAB240' AND
       vr_cddbanco = 1         THEN
       
      pc_importa (pr_cdcooper    => pr_cdcooper,   --> Codigo da cooperativa
                  pr_nmarqint    => pr_nmarqint,   --> Nome do arquivo a ser validado
                  pr_tpenvcob    => pr_tpenvcob,   --> Tipo de envio do arquivo (1-Envio via Internet Bank, 2-Envio via FTP)
                  pr_rec_rejeita => pr_rec_rejeita,--> Dados invalidados
                  pr_des_reto    => vr_des_reto);  --> Retorno OK/NOK       
       
    ELSIF vr_tparquiv = 'CNAB240' AND
          vr_cddbanco = 85        THEN
          
      pc_importa_cnab240_085 (pr_cdcooper    => pr_cdcooper,   --> Codigo da cooperativa
                              pr_nmarqint    => pr_nmarqint,   --> Nome do arquivo a ser validado
                              pr_tpenvcob    => pr_tpenvcob,   --> Tipo de envio do arquivo (1-Envio via Internet Bank, 2-Envio via FTP)
                              pr_rec_rejeita => pr_rec_rejeita,--> Dados invalidados
                              pr_des_reto    => vr_des_reto);  --> Retorno OK/NOK
                  
    ELSIF vr_tparquiv = 'CNAB400' AND
          vr_cddbanco = 85        THEN
    
      pc_importa_cnab400_085 (pr_cdcooper    => pr_cdcooper,   --> Codigo da cooperativa
                              pr_nmarqint    => pr_nmarqint,   --> Nome do arquivo a ser validado
                              pr_tpenvcob    => pr_tpenvcob,   --> Tipo de envio do arquivo (1-Envio via Internet Bank, 2-Envio via FTP)
                              pr_rec_rejeita => pr_rec_rejeita,--> Dados invalidados
                              pr_des_reto    => vr_des_reto);  --> Retorno OK/NOK
                                     
    ELSE
            
      RAISE vr_exc_erro;              
       
    END IF;
    
    IF vr_des_reto <> 'OK'        OR 
       pr_rec_rejeita.count() > 1 THEN
      
      RAISE vr_exc_erro; 
        
    END IF;  
    
    pr_des_reto := 'OK';
    
  EXCEPTION  
    WHEN vr_exc_erro THEN         
      
      pr_des_reto := 'NOK';
       
    WHEN OTHERS THEN
      
      pr_des_reto := 'NOK';     
      
  END pc_valida_arquivo_cobranca;  
  
  /* Procedure validar arquivos de cobranca Modo Caracter */
  PROCEDURE pc_valida_arquivo_cobranca_car(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                          ,pr_nmarqint IN VARCHAR2                --> Nome do arquivo a ser validado                                          
                                          ,pr_des_erro OUT VARCHAR2               --> Saida OK/NOK
                                          ,pr_clob_ret OUT CLOB                   --> Tabela Beneficiarios
                                          ,pr_cdcritic OUT PLS_INTEGER            --> Codigo Erro
                                          ,pr_dscritic OUT VARCHAR2) IS           --> Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_valida_arquivo_cobranca_car              Antigo: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Marco/2016                           Ultima atualizacao:  
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para validar arquivos de cobranca via progress
  
    Alterações :  
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabelas de Memoria
    vr_tab_rejeita typ_tab_rejeita;

    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
        
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
        
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      COBR0006.pc_valida_arquivo_cobranca(pr_cdcooper    => pr_cdcooper
                                         ,pr_nmarqint    => pr_nmarqint
                                         ,pr_rec_rejeita => vr_tab_rejeita
                                         ,pr_des_reto    => vr_des_reto);
                                         
      --Montar CLOB
      IF vr_tab_rejeita.COUNT > 0 THEN
        
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clob_ret, TRUE); 
        dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);
        
        -- Insere o cabeçalho do XML 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
         
        --Buscar Primeiro rejeitado
        vr_index:= vr_tab_rejeita.FIRST;
       
        --Percorrer todos os rejeitados
        WHILE vr_index IS NOT NULL LOOP
          
          vr_string:= '<rejeitados>'||
                          '<tpcritic>'||NVL(TO_CHAR(vr_tab_rejeita(vr_index).tpcritic),'0')|| '</tpcritic>'|| 
                          '<nrlinseq>'||NVL(TO_CHAR(vr_tab_rejeita(vr_index).nrlinseq),' ')|| '</nrlinseq>'|| 
                          '<cdseqcri>'||NVL(TO_CHAR(vr_tab_rejeita(vr_index).cdseqcri),'0')|| '</cdseqcri>'|| 
                          '<dscritic>'||NVL(TO_CHAR(vr_tab_rejeita(vr_index).dscritic),' ')|| '</dscritic>'|| 
                          '<seqdetal>'||NVL(TO_CHAR(vr_tab_rejeita(vr_index).seqdetal),' ')|| '</seqdetal>'||                         
                      '</rejeitados>';
                      
          -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                                 ,pr_texto_completo => vr_dstexto 
                                 ,pr_texto_novo     => vr_string
                                 ,pr_fecha_xml      => FALSE);   
                                                    
          --Proximo Registro
          vr_index:= vr_tab_rejeita.NEXT(vr_index);
          
        END LOOP;  
        
        -- Encerrar a tag raiz 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '</root>' 
                               ,pr_fecha_xml      => TRUE);
          
        --Levantar Excecao
        RAISE vr_exc_erro;        
     
      END IF;
                                         
      --Retorno
      pr_des_erro:= 'OK';    

    EXCEPTION
      WHEN vr_exc_erro THEN
        
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;        
          
      WHEN OTHERS THEN
        
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        pr_cdcritic:= 0;
        -- Chamar rotina de gravação de erro
        pr_dscritic:= 'Erro na inss0001.pc_valida_arquivo_cobranca_car --> '|| SQLERRM;

  END pc_valida_arquivo_cobranca_car;  

  --> Tratar linha do arquicvo Header do arquivo
  PROCEDURE pc_trata_header_arq_240_85 (pr_cdcooper    IN crapcop.cdcooper%TYPE,   --> Codigo da cooperativa
                                        pr_nrdconta    IN crapass.nrdconta%TYPE,   --> Numero da conta do cooperado
                                        pr_tab_linhas  IN gene0009.typ_tab_campos, --> Dados da linha
                                        pr_rec_header OUT typ_rec_header,          --> Dados do Header
                                        pr_cdcritic   OUT INTEGER,                 --> Codigo de critica
                                        pr_dscritic   OUT VARCHAR2,                --> Descricao da critica
                                        pr_des_reto   OUT VARCHAR2                 --> Retorno OK/NOK
                                        ) IS
                                   
  /* ............................................................................

       Programa: pc_trata_header_arq_240_85    
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana - AMcom
       Data    : Novembro/2015.                   Ultima atualizacao: 22/12/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Tratar linha do arquicvo Header do arquivo

       Alteracoes: 25/11/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)
       
                   29/12/2016 - P340 - Ajustes para pagamentos divergentes (Ricardo Linhares)

                   16/11/2017 - Quando INPESSOA = 3 considerar com o sendo 2 (SD795292 - AJFink)

                   22/12/2017 - Carregar o CPF/CNPJ do titular da conta (Douglas - Chamado 819777)
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    
    --> Verifica se convenio esta Homologacao 
    CURSOR cr_crapceb (pr_cdcooper  crapceb.cdcooper%TYPE,
                       pr_nrconven  crapceb.nrconven%TYPE,
                       pr_nrdconta  crapceb.nrdconta%TYPE) IS
      SELECT *
        FROM crapceb
       WHERE crapceb.cdcooper = pr_cdcooper
         AND crapceb.nrconven = pr_nrconven
         AND crapceb.nrdconta = pr_nrdconta
         AND crapceb.insitceb = 1;    
    rw_crapceb cr_crapceb%ROWTYPE;  
    
    --> Codigo do Convenio
    CURSOR cr_crapcco (pr_cdcooper crapcco.cdcooper%TYPE,
                       pr_nrconven crapcco.nrconven%TYPE) IS
      SELECT  crapcco.cddbanco
             ,crapcco.cdagenci
             ,crapcco.cdbccxlt
             ,crapcco.nrdolote
             ,crapcco.cdhistor
             ,crapcco.nrdctabb
             ,crapcco.nrconven
             ,crapcco.flgutceb
             ,crapcco.flgregis
             ,crapcco.rowid
        FROM crapcco
       WHERE crapcco.cdcooper = pr_cdcooper
         AND crapcco.cddbanco = 085
         AND crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE'
         AND crapcco.nrconven = pr_nrconven;
    rw_crapcco cr_crapcco%ROWTYPE;
    
    --> Buscar ultimo arquivo processaso
    CURSOR cr_craprtc (pr_cdcooper  craprtc.cdcooper%TYPE,
                       pr_nrconven  craprtc.nrcnvcob%TYPE,
                       pr_nrdconta  craprtc.nrdconta%TYPE,
                       pr_nrremret  craprtc.nrremret%TYPE)IS
      SELECT /*+indesx_desc (craprtc CRAPRTC##CRAPRTC1)*/
             craprtc.nrremret
        FROM craprtc
       WHERE craprtc.cdcooper = pr_cdcooper
         AND craprtc.nrdconta = pr_nrdconta
         AND craprtc.nrcnvcob = pr_nrconven
         AND craprtc.intipmvt = 1 /* Remessa */
         AND craprtc.nrremret = nvl(pr_nrremret,craprtc.nrremret);
    rw_craprtc cr_craprtc%ROWTYPE;
    
         
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_nrremass   NUMBER;
    vr_nrconven   NUMBER;
    
  BEGIN
    
    --> Numero da Remessa do Cooperado 
    vr_nrremass := pr_tab_linhas('NRSEQARQ').numero;    
    vr_nrconven := to_number(pr_tab_linhas('NRCONVEN').texto);
    
    --> Verifica se convenio esta Homologacao 
    OPEN cr_crapceb (pr_cdcooper  => pr_cdcooper,
                     pr_nrconven  => vr_nrconven,
                     pr_nrdconta  => pr_nrdconta);
                     
    FETCH cr_crapceb INTO rw_crapceb;
    
    IF cr_crapceb%FOUND THEN
      CLOSE cr_crapceb;
      IF rw_crapceb.flgcebhm = 0 THEN --> FALSE        
        vr_dscritic := 'Convenio Nao Homologado - Entre em contato com seu Posto de Atendimento.';
        RAISE vr_exc_erro;
      END IF;      
    ELSE
      CLOSE cr_crapceb;
      vr_dscritic := 'Convenio Inativo ou Nao Cadastrado.';
      RAISE vr_exc_erro;
    END IF;
    
    --> 01.0 Codigo do banco na compensacao 
    IF pr_tab_linhas('CDBANCMP').numero <> '85' THEN
      vr_dscritic := 'Codigo do banco na compensacao invalido';
      RAISE vr_exc_erro;
    END IF;

    --> 02.0 Lote de Servico
    IF pr_tab_linhas('NRLOTSER').numero <> '0000' THEN
      vr_dscritic := 'Lote de Servico Invalido.';
      RAISE vr_exc_erro;
    END IF;

    --> 03.0 Tipo de Registro
    IF pr_tab_linhas('TPREGIST').numero <> 0 THEN 
      vr_dscritic := 'Tipo de Registro Invalido.';
      RAISE vr_exc_erro;
    END IF;
   
    --> 05.0 Tipo de Inscricao do Cooperado
    IF pr_tab_linhas('INPESSOA').numero NOT IN (1,2) THEN -- 1-Pessoa Fisica 2-Pessoa Juridica
      vr_dscritic := 'Tipo de Inscricao Invalida.';
      RAISE vr_exc_erro;
    END IF;

    --> 10.0 a 11.0 Conta/DV 
    IF pr_tab_linhas('NRDCONTA').numero <> pr_nrdconta THEN
      vr_dscritic := 'Conta/DV Header Arquivo Invalida.';
      RAISE vr_exc_erro;
    END IF;
   
    --> Buscar dados do associado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Conta/DV Informado Header Arquivo nao pertence a um cooperado cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
      IF rw_crapass.nrcpfcgc <> pr_tab_linhas('NRCPFCGC').numero THEN       
        vr_dscritic := 'CPF/CNPJ Informado Header Arquivo Invalido.';
        RAISE vr_exc_erro;
      ELSIF rw_crapass.inpessoa_vld <> pr_tab_linhas('INPESSOA').numero THEN
        vr_dscritic := 'CPF/CNPJ Informado Header Arquivo incompativel com Tipo de Inscricao.';
        RAISE vr_exc_erro;
      END IF;      
    END IF;
    
    --> Codigo do Convenio
    OPEN cr_crapcco (pr_cdcooper => pr_cdcooper,
                     pr_nrconven => vr_nrconven );
                     
    FETCH cr_crapcco INTO rw_crapcco;
    
    IF cr_crapcco%NOTFOUND THEN
      CLOSE cr_crapcco;
      vr_dscritic := 'Convenio nao Encontrado.';
      RAISE vr_exc_erro;
      
    ELSE
      CLOSE cr_crapcco;
    END IF;
    
    --> 16.0 Codigo Remessa/Retorno 
    IF pr_tab_linhas('CDREMRET').numero <> '1' THEN
      vr_dscritic := 'Codigo de Remessa nao encontrado no segmento header do arquivo.';
      RAISE vr_exc_erro;
    END IF;

    --> 17.0 Data de geracao de arquivo
    IF ( pr_tab_linhas('DTGERARQ').data > SYSDATE ) OR
       ( pr_tab_linhas('DTGERARQ').data < ( SYSDATE - 30 ))   THEN
      vr_dscritic := 'Data de geracao do arquivo fora do periodo permitido.';
      RAISE vr_exc_erro;
    END IF;
   
    IF vr_nrremass = 0 THEN
      vr_dscritic := 'Numero da Remessa Invalida.';
      RAISE vr_exc_erro;
    END IF;  
    
    --> Buscar ultimo arquivo processado
    OPEN cr_craprtc (pr_cdcooper  => rw_crapass.cdcooper,
                     pr_nrconven  => rw_crapcco.nrconven,
                     pr_nrdconta  => rw_crapass.nrdconta,
                     pr_nrremret  => NULL);
                     
    FETCH cr_craprtc INTO rw_craprtc;
    
    IF cr_craprtc%FOUND THEN
      
      CLOSE cr_craprtc;
      --> Verificacao do numero de remessa que esta sendo processado eh igual ao ultimo processado */
      IF rw_craprtc.nrremret = vr_nrremass THEN
        vr_dscritic := 'Arquivo ja processado';
        RAISE vr_exc_erro;
      ELSIF rw_craprtc.nrremret > vr_nrremass THEN
        
        --> Verificar se o ultimo arquivo processado possui ateh 6 caracteres que eh 
        --  o maximo para CNAB240
        IF LENGTH(rw_craprtc.nrremret) <= 6  THEN
          vr_dscritic := 'Numero de remessa (HEADER) inferior ao ultimo arquivo processado.';
          RAISE vr_exc_erro; 
        ELSE
          --> Se o ultimo possuir mais de 6 caracteres, pesquisa pelo numero de remessa
          --  que esta sendo processado
          OPEN cr_craprtc (pr_cdcooper  => rw_crapass.cdcooper,
                           pr_nrconven  => rw_crapcco.nrconven,
                           pr_nrdconta  => rw_crapass.nrdconta,
                           pr_nrremret  => vr_nrremass);
                           
          FETCH cr_craprtc INTO rw_craprtc;
          
          IF cr_craprtc%FOUND THEN
            CLOSE cr_craprtc;
            vr_dscritic := 'Arquivo ja processado';
            RAISE vr_exc_erro;          
          END IF;
          CLOSE cr_craprtc;
        END IF;
      END IF;
      
    END IF;
    IF cr_craprtc%ISOPEN THEN
      CLOSE cr_craprtc;
    END IF;
    
    -- Carregar todas as informacoes do Header
    pr_rec_header.nrremass := vr_nrremass;
    pr_rec_header.cdbancbb := rw_crapcco.cddbanco;
    pr_rec_header.cdagenci := rw_crapcco.cdagenci;
    pr_rec_header.cdbccxlt := rw_crapcco.cdbccxlt;
    pr_rec_header.nrdolote := rw_crapcco.nrdolote;
    pr_rec_header.cdhistor := rw_crapcco.cdhistor;
    pr_rec_header.nrdctabb := rw_crapcco.nrdctabb;
    pr_rec_header.cdbandoc := rw_crapcco.cddbanco;
    pr_rec_header.nrcnvcob := rw_crapcco.nrconven;
    pr_rec_header.flgutceb := rw_crapcco.flgutceb;
    pr_rec_header.flgregis := rw_crapcco.flgregis;
    pr_rec_header.flceeexp := rw_crapceb.flceeexp;
    pr_rec_header.inpessoa := rw_crapass.inpessoa;
    pr_rec_header.nrcpfcgc := rw_crapass.nrcpfcgc;
    pr_rec_header.flserasa := rw_crapceb.flserasa;
    pr_rec_header.flgregon := rw_crapceb.flgregon;
    pr_rec_header.flgpgdiv := rw_crapceb.flgpgdiv;
    
    pr_des_reto := 'OK';
    
  EXCEPTION  
    WHEN vr_exc_erro THEN      
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic; 
      pr_des_reto := 'NOK';
       
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao validar Header do arquivo: '||SQLERRM;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_reto := 'NOK';
      
  END pc_trata_header_arq_240_85;   
  
  --> Tratar linha do arquicvo Header do lote
  PROCEDURE pc_trata_header_lote_240_85(pr_cdcooper   IN crapcop.cdcooper%TYPE,   --> Codigo da cooperativa
                                        pr_nrdconta   IN crapass.nrdconta%TYPE,   --> Numero da conta do cooperado
                                        pr_nrconven   IN crapcco.nrconven%TYPE,   --> Numero do convenio
                                        pr_tab_linhas IN gene0009.typ_tab_campos, --> Dados da linha
                                        pr_cdcritic OUT INTEGER,                  --> Codigo de critica
                                        pr_dscritic OUT VARCHAR2,                 --> Descricao da critica
                                        pr_des_reto  OUT VARCHAR2                 --> Retorno OK/NOK
                                        ) IS
                                   
  /* ............................................................................

       Programa: pc_trata_header_lote_240_85    
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana - AMcom
       Data    : Novembro/2015.                   Ultima atualizacao: 25/11/2015

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Tratar linha do arquicvo Header do lote

       Alteracoes: 25/11/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)

                   16/11/2016 - Quando INPESSOA = 3 considerar com o sendo 2 (SD795292 - AJFink)

    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    
    
    --> Buscar ultimo arquivo processaso
    CURSOR cr_craprtc (pr_cdcooper  craprtc.cdcooper%TYPE,
                       pr_nrconven  craprtc.nrcnvcob%TYPE,
                       pr_nrdconta  craprtc.nrdconta%TYPE,
                       pr_nrremret  craprtc.nrremret%TYPE)IS
      SELECT /*+indesx_desc (craprtc CRAPRTC##CRAPRTC1)*/
             craprtc.nrremret
        FROM craprtc
       WHERE craprtc.cdcooper = pr_cdcooper
         AND craprtc.nrdconta = pr_nrdconta
         AND craprtc.nrcnvcob = pr_nrconven
         AND craprtc.intipmvt = 1 /* Remessa */
         AND craprtc.nrremret = nvl(pr_nrremret,craprtc.nrremret);
    rw_craprtc cr_craprtc%ROWTYPE;
    
         
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_nrremret  NUMBER;
    
  BEGIN
    
    --> Numero da Remessa do Cooperado 
    vr_nrremret := pr_tab_linhas('NRREMRET').numero;   
    
    --> 01.0 Codigo do banco na compensacao 
    IF pr_tab_linhas('CDBANCMP').numero <> '085' THEN
      vr_dscritic := 'Codigo do banco na compensacao invalido';
      RAISE vr_exc_erro;
    END IF;

    --> 02.0 Lote de Servico
    IF pr_tab_linhas('NRLOTSER').numero <> '0001' THEN
      vr_dscritic := 'Lote de Servico Invalido.';
      RAISE vr_exc_erro;
    END IF;

    --> 03.0 Tipo de Registro
    IF pr_tab_linhas('TPREGIST').numero <> 1 THEN 
      vr_dscritic := 'Tipo de Registro Invalido.';
      RAISE vr_exc_erro;
    END IF;
    
    -- 04.1 Operacao 
    IF pr_tab_linhas('TPOPERAC').Texto <> 'R' THEN
      vr_dscritic := 'Tipo de Operacao Invalido.';
      RAISE vr_exc_erro;
    END IF;

    --> 05.1 Tipo de Servico 
    IF pr_tab_linhas('TPSERVIC').numero <> '01' THEN
      vr_dscritic := 'Tipo de Servico Invalida.';
      RAISE vr_exc_erro;
    END IF;
    
    --> 09.1 Tipo de Inscricao do Cooperado
    IF pr_tab_linhas('INPESSOA').numero NOT IN (1,2) THEN -- 1-Pessoa Fisica 2-Pessoa Juridica
      vr_dscritic := 'Tipo de Inscricao Invalida.';
      RAISE vr_exc_erro;
    END IF;

    --> 14.1 a 15.1 Conta/DV
    IF pr_tab_linhas('NRDCONTA').numero <> pr_nrdconta THEN
      vr_dscritic := 'Conta/DV Header Lote Invalida.';
      RAISE vr_exc_erro;
    END IF;
    
    --> Buscar dados do associado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Conta/DV Informado Header Lote nao pertence a um cooperado cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
      IF rw_crapass.nrcpfcgc <> pr_tab_linhas('NRCPFCGC').numero THEN       
        vr_dscritic := 'CPF/CNPJ Informado Header Lote Invalido.';
        RAISE vr_exc_erro;
      ELSIF rw_crapass.inpessoa_vld <> pr_tab_linhas('INPESSOA').numero THEN
        vr_dscritic := 'CPF/CNPJ Informado Header Lote incompativel com Tipo de Inscricao.';
        RAISE vr_exc_erro;
      END IF;      
    END IF;
    
    --> Buscar ultimo arquivo processaso
    OPEN cr_craprtc (pr_cdcooper  => rw_crapass.cdcooper,
                     pr_nrconven  => pr_nrconven,
                     pr_nrdconta  => rw_crapass.nrdconta,
                     pr_nrremret  => NULL);
    FETCH cr_craprtc INTO rw_craprtc;
    IF cr_craprtc%FOUND THEN
      CLOSE cr_craprtc;
      --> Verificacao do numero de remessa que esta sendo processado eh igual ao ultimo processado */
      IF rw_craprtc.nrremret = vr_nrremret THEN
        vr_dscritic := 'Arquivo ja processado';
        RAISE vr_exc_erro;
      ELSIF rw_craprtc.nrremret > vr_nrremret THEN
        
        --> Verificar se o ultimo arquivo processado possui ateh 6 caracteres que eh 
        --  o maximo para CNAB240
        IF LENGTH(rw_craprtc.nrremret) <= 6  THEN
          vr_dscritic := 'Numero de remessa (HEADER) inferior ao ultimo arquivo processado.';
          RAISE vr_exc_erro; 
        ELSE
          --> Se o ultimo possuir mais de 6 caracteres, pesquisa pelo numero de remessa
          --  que esta sendo processado
          OPEN cr_craprtc (pr_cdcooper  => rw_crapass.cdcooper,
                           pr_nrconven  => pr_nrconven,
                           pr_nrdconta  => rw_crapass.nrdconta,
                           pr_nrremret  => vr_nrremret);
          FETCH cr_craprtc INTO rw_craprtc;
          IF cr_craprtc%FOUND THEN
            CLOSE cr_craprtc;
            vr_dscritic := 'Arquivo ja processado';
            RAISE vr_exc_erro;          
          END IF;
          CLOSE cr_craprtc;
        END IF;
      END IF;
    END IF;
    IF cr_craprtc%ISOPEN THEN
      CLOSE cr_craprtc;
    END IF;
    
    --> 17.0 Data de geracao de arquivo
    IF ( pr_tab_linhas('DTREMRET').data > SYSDATE ) OR
       ( pr_tab_linhas('DTREMRET').data < ( SYSDATE - 30 ))   THEN
      vr_dscritic := 'Data de gravacao do arquivo fora do periodo permitido.';
      RAISE vr_exc_erro;
    END IF;
    
    pr_des_reto := 'OK';
    
  EXCEPTION  
    WHEN vr_exc_erro THEN      
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic; 
      pr_des_reto := 'NOK';
       
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao validar Header do lote: '||SQLERRM;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_reto := 'NOK';
      
  END pc_trata_header_lote_240_85;
  
  --> Tratar linha do arquivo tipo de registro P
  PROCEDURE pc_trata_segmento_p_240_85 (pr_cdcooper      IN crapcop.cdcooper%TYPE,   --> Codigo da cooperativa
                                        pr_nrdconta      IN crapass.nrdconta%TYPE,   --> Numero da conta do cooperado
                                        pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE,   --> Data de movimento
                                        pr_cdoperad      IN crapope.cdoperad%TYPE,   --> Operador
                                        pr_diasvcto      IN INTEGER,                 --> Dias de Vencimento
                                        pr_flgfirst      IN OUT BOOLEAN,             --> controle de primeiro registro
                                        pr_tab_linhas    IN gene0009.typ_tab_campos, --> Dados da linha
                                        pr_rec_header    IN typ_rec_header,          --> Dados do Header do Arquivo
                                        pr_qtdregis      IN OUT INTEGER,             --> contador de registro
                                        pr_qtdinstr      IN OUT INTEGER,             --> contador de instucoes
                                        pr_qtbloque      IN OUT INTEGER,             --> contador de boletos processados
                                        pr_vlrtotal      IN OUT NUMBER,              --> Valor total dos boletos
                                        pr_rec_cobranca  IN OUT NOCOPY typ_rec_cobranca,    --> Dados da Cobranca
                                        pr_tab_crapcob   IN OUT NOCOPY typ_tab_crapcob,     --> Tabela de Cobranca
                                        pr_tab_instrucao IN OUT NOCOPY typ_tab_instrucao,   --> Tabela de Instrucoes
                                        pr_tab_rejeitado IN OUT NOCOPY typ_tab_rejeitado,   --> Tabela de Rejeitados
                                        pr_tab_crawrej   IN OUT NOCOPY typ_tab_crawrej,     --> Tabela de Rejeitados
                                        pr_des_reto         OUT VARCHAR2             --> Retorno OK/NOK
                                        ) IS
                                   
  /* ............................................................................

       Programa: pc_trata_segmento_p_240_85
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana - AMcom
       Data    : Novembro/2015.                   Ultima atualizacao: 11/01/2018

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Tratar linha do arquivo tipo de segmento P

       Alteracoes: 25/11/2015 - Conversão Progress -> Oracle (Douglas Quisinski)
       
                   07/11/2016 - Ajustado a validacao de Data de Emissao, para que a 
                                quantidade de dias seja parametrizada. Sera alterado 
                                de 90 para 365 dias. (Douglas - Chamado 523329)

                   23/12/2016 - Validar nulo na data de vencimento, emissão e valor do
                                título. (AJFink - SD#581070)

                   28/12/2016 - Quando nosso número bem com zeros a esquerda completando
                                20 caracteres, deve gravar na cob somente 17.
                                (AJFink - SD#580867)

				   13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts).
						
                   07/06/2017 - Inicializar pr_rec_cobranca.flserasa = 1 na validação
                                da informação de negativação. (SD#686881 - AJFink)

                   11/01/2018 - Ajustar para executar RAISE apenas se ocorreu erro nas validações da
                                pc_valida_exec_instrucao e o boleto tenha sido rejeitado, caso contrário
                                o processo deve continuar. (Douglas 828517)
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_reje   EXCEPTION;
    vr_exc_fim    EXCEPTION;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_rej_cdmotivo VARCHAR2(2);
    
  BEGIN
    IF pr_tab_linhas('CDMOVRE').numero = '01' THEN
      pr_qtdregis := pr_qtdregis + 1;
    ELSE
      pr_qtdinstr := pr_qtdinstr + 1;
    END IF;
    
    --> Cria o ultimo boleto ou gera instrucao apenas se nao tiver erros 
    IF pr_flgfirst AND NOT pr_rec_cobranca.flgrejei THEN
       
       --> 01 - Solicitacao de Remessa 
       IF pr_rec_cobranca.cdocorre = 1 THEN
         vr_dscritic:= '';
         -- Armazenar o boleto para gravacao ao fim do arquivo
         pc_grava_boleto(pr_rec_cobranca => pr_rec_cobranca,
                         pr_qtbloque     => pr_qtbloque, 
                         pr_vlrtotal     => pr_vlrtotal,
                         pr_tab_crapcob  => pr_tab_crapcob,
                         pr_dscritic     => vr_dscritic);
                         
         -- Se ocorreu erro durante o armazenamento do boleto grava o erro
         IF TRIM(vr_dscritic) IS NOT NULL THEN
           pc_grava_critica(pr_cdcooper => pr_rec_cobranca.cdcooper,
                            pr_nrdconta => pr_rec_cobranca.nrdconta,
                            pr_nrdocmto => pr_rec_cobranca.nrbloque,
                            pr_dscritic => vr_dscritic,
                            pr_tab_crawrej => pr_tab_crawrej);
         END IF;
       ELSE
         vr_dscritic:= '';
         -- Armazenar a instrucao para gravacao ao fim do arquivo
         pc_grava_instrucao(pr_rec_cobranca  => pr_rec_cobranca,
                            pr_tab_instrucao => pr_tab_instrucao,
                            pr_dscritic      => vr_dscritic);  
                            
         -- Se ocorreu erro durante o armazenamento da instrucao grava o erro
         IF TRIM(vr_dscritic) IS NOT NULL THEN
           pc_grava_critica(pr_cdcooper => pr_rec_cobranca.cdcooper,
                            pr_nrdconta => pr_rec_cobranca.nrdconta,
                            pr_nrdocmto => pr_rec_cobranca.nrbloque,
                            pr_dscritic => vr_dscritic,
                            pr_tab_crawrej => pr_tab_crawrej);
         END IF;
       END IF;       
    END IF;
    
    -- Inicializar
    pr_flgfirst := TRUE;    
    -- Zerar críticas
    vr_rej_cdmotivo := NULL;
    
    -- Inicializar uma nova cobranca
    pc_inicializa_cobranca(pr_cdcooper     => pr_cdcooper,      --> Cooperativa
                           pr_nrdconta     => pr_nrdconta,      --> Conta
                           pr_dtmvtolt     => pr_dtmvtolt,      --> Data de Movimento
                           pr_rec_header   => pr_rec_header,    --> Dados do Header do Arquivo
                           pr_rec_cobranca => pr_rec_cobranca); --> Cobranca
    
    --Tratamento para verificar se o NOSSO NUMERO é null
    IF TRIM(pr_tab_linhas('DSNOSNUM').texto) IS NULL THEN
       -- Nosso Numero Invalido
       pr_rec_cobranca.dsnosnum := '';
       vr_rej_cdmotivo := '08';
       RAISE vr_exc_reje;
    END IF;      
    
    --SD#580867
    if nvl(length(TRIM(pr_tab_linhas('DSNOSNUM').texto)),0) > 17 then
      if substr(TRIM(pr_tab_linhas('DSNOSNUM').texto),1,3) <> '000' then
        -- Nosso Numero Invalido
        pr_rec_cobranca.dsnosnum := TRIM(pr_tab_linhas('DSNOSNUM').texto);
        vr_rej_cdmotivo := '08';
        RAISE vr_exc_reje;
      end if;
    end if;

    -- Formatar nosso numero com 17 posicoes para separa o numero da conta e o numero do boleto
    pr_rec_cobranca.dsnosnum := to_char(TRIM(pr_tab_linhas('DSNOSNUM').texto),'fm00000000000000000');
    pr_rec_cobranca.nrdconta := to_number(SUBSTR(pr_rec_cobranca.dsnosnum,1,8));
    pr_rec_cobranca.nrbloque := to_number(SUBSTR(pr_rec_cobranca.dsnosnum,9,9));  
    -- Inicializar os valores do registro
    pr_rec_cobranca.dsdoccop := TRIM(pr_tab_linhas('NRDOCMTO').texto);
    pr_rec_cobranca.dsusoemp := pr_tab_linhas('DSUSOEMP').texto;
    pr_rec_cobranca.flserasa := 0;
    pr_rec_cobranca.qtdianeg := 0;
    pr_rec_cobranca.inserasa := 0;
    pr_rec_cobranca.serasa := 0;
    
    --> tratar flag aceite enviada no arquivo motivo 23 - Aceite invalido, nao sera tratado
    --  para nao impactar nos cooperados que ignoravam essa informacao*/                   
    IF upper(pr_tab_linhas('FLGACEIT').texto) = 'A' THEN
      pr_rec_cobranca.flgaceit := 1;
    ELSE
      pr_rec_cobranca.flgaceit := 0;
    END IF;  
                          
    pr_rec_cobranca.inemiexp := 0;
    
    --> 07.3P Valida Codigo do Movimento
    pr_rec_cobranca.cdocorre := pr_tab_linhas('CDMOVRE').numero;
    IF pr_rec_cobranca.cdocorre NOT IN (1,2,4,5,6,7,8,9,10,11,31,41,80,81,90,93,94,95,96) THEN
      vr_rej_cdmotivo := '05'; --> Codigo de Movimento Invalido
      RAISE vr_exc_reje;
    END IF;
  
    -- Carregar os valores necessarios para criar os rejeitados
    pr_rec_cobranca.vltitulo:= pr_tab_linhas('VLTITULO').numero;
    pr_rec_cobranca.dtvencto:= pr_tab_linhas('DTVENCTO').data;
    pr_rec_cobranca.dtemscob:= pr_tab_linhas('DTEMSCOB').data;
	pr_rec_cobranca.vlabatim:= pr_tab_linhas('VLABATIM').numero;	

    --> Validacao de Comandos de Instrucao
    IF pr_rec_cobranca.cdocorre <> 1 THEN -- 01 - Remessa
      IF pr_rec_cobranca.cdocorre NOT IN (31,95,96) THEN 
        -- Realiza as validações da instrucao
        pc_valida_exec_instrucao (pr_cdcooper   => pr_cdcooper,
                                  pr_nrdconta   => pr_nrdconta,
                                  pr_rec_header => pr_rec_header,
                                  pr_tab_linhas => pr_tab_linhas,
                                  pr_cdocorre   => pr_rec_cobranca.cdocorre,
                                  pr_tipocnab   => '240',
                                  pr_cdmotivo   => vr_rej_cdmotivo);
                                  
        IF TRIM(vr_rej_cdmotivo) IS NOT NULL THEN
          pc_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                            ,pr_nrdconta      => pr_nrdconta -- Enviar o pr_nrdconta ao inves do pr_rec_cobranca.nrdconta, pois quando o motivo eh 08 o campo pr_rec_cobranca.nrdconta eh gerado com valor errado
                            ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                            ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                            ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                            ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                            ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                            ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                            ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                            ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                            ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                            ,pr_cdoperad      => pr_cdoperad              --> Operador
                            ,pr_cdocorre      => 26                       --> Codigo da Ocorrencia
                            ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                            ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
          RAISE vr_exc_fim;
        END IF;
      END IF;
    END IF;
  
    -- 17.3P Valida Tipo de Emissao do Boleto
    IF pr_rec_cobranca.cdocorre = 01  OR    -- 01 - Remessa
       pr_rec_cobranca.cdocorre = 90  THEN 

      pr_rec_cobranca.inemiten := pr_tab_linhas('INEMITEN').numero;
      
      IF pr_rec_cobranca.inemiten <> 1 AND  -- Banco Emite
         pr_rec_cobranca.inemiten <> 2 THEN -- Cliente Emite
        -- Identificaçao da Emissao do Bloqueto invalida
        vr_rej_cdmotivo := '13';
        RAISE vr_exc_reje;
      END IF;
      
      IF pr_rec_cobranca.inemiten = 1 THEN
        pr_rec_cobranca.inemiten := 3; -- Cooperativa Emite e Expede 
        pr_rec_cobranca.inemiexp := 1; -- Indicador de emissao, 1 – cooperativa emite e expede – a enviar
      ELSE
        pr_rec_cobranca.inemiten := 2; -- Cooperado Emite e Expede
        pr_rec_cobranca.inemiexp := 0; 
      END IF;

      IF  pr_rec_cobranca.inemiten = 3 AND 
          pr_rec_header.flceeexp = 0   THEN
        -- Identificaçao da Emissao do Bloqueto invalida
        vr_rej_cdmotivo := '13';
        RAISE vr_exc_reje;
      END IF;
    END IF;
  
    -- 20.3P Valida Data de Vencimento 
    IF pr_rec_cobranca.cdocorre = 01  OR    -- 01 - Remessa
       pr_rec_cobranca.cdocorre = 06  THEN  -- 06 - Alteracao Vencimento
        
      IF pr_rec_cobranca.dtvencto IS NULL THEN --SD#581070
        --Data de Vencimento Invalida
        vr_rej_cdmotivo := '16';
        RAISE vr_exc_reje;
      ELSIF pr_rec_cobranca.dtvencto < TRUNC(SYSDATE) OR 
         pr_rec_cobranca.dtvencto > to_date('13/10/2049','dd/mm/RRRR')  THEN 
        -- Vencimento Fora do Prazo de Operacao
        vr_rej_cdmotivo := '18';
        RAISE vr_exc_reje;
      END IF;

      -- coop. emite e expede
      IF  pr_rec_cobranca.inemiten = 3 THEN 
        IF pr_rec_cobranca.dtvencto <= (TRUNC(SYSDATE) + pr_diasvcto) THEN
          -- Data de Vencimento Invalida
          vr_rej_cdmotivo := '16';
          RAISE vr_exc_reje;
        END IF;
      END IF;
      
    END IF;
    
    -- 21.3P Valida Valor do Titulo
    -- O valor do titulo sempre sera validado independente de ter gerado erro anteriormente
    IF nvl(pr_rec_cobranca.vltitulo,0) = 0 THEN --SD#581070
      -- Valor do Titulo Invalido
      vr_rej_cdmotivo := '20';
      RAISE vr_exc_reje;
    END IF;
        
    -- 1.3P Banco
    IF pr_tab_linhas('CDBANCMP').numero <> 085 THEN -- CECRED
      -- Codigo do Banco Invalido
      vr_rej_cdmotivo := '01';
      RAISE vr_exc_reje;
    END IF;

    -- 14.3P Carteira
    -- Cobrança Simples
    IF pr_tab_linhas('CDCARTEI').numero <> 1 THEN
      -- Carteira Invalido
      vr_rej_cdmotivo := '10';
      RAISE vr_exc_reje;
    END IF;
    
    -- 24.3P Especie do Titulo
    pr_rec_cobranca.cddespec := pr_tab_linhas('CDDESPEC').numero;
    /* Tratar Especie do Titulo Febraban -> Cecred */
    IF pr_rec_cobranca.cddespec = 02 THEN /* DM */
      pr_rec_cobranca.cddespec := 01;
    ELSIF pr_rec_cobranca.cddespec = 04 THEN /* DS */
      pr_rec_cobranca.cddespec := 02;
    ELSIF pr_rec_cobranca.cddespec = 12 THEN /* NP */
      pr_rec_cobranca.cddespec := 03;
    ELSIF pr_rec_cobranca.cddespec = 17 THEN /* Recibo */
      pr_rec_cobranca.cddespec := 06;
    ELSIF pr_rec_cobranca.cddespec = 21 THEN /* Mensalidade */
      pr_rec_cobranca.cddespec := 04;
    ELSIF pr_rec_cobranca.cddespec = 23 THEN /* Nota Fiscal */
      pr_rec_cobranca.cddespec := 05;
    ELSE
      -- Especie do Titulo Invalido
      vr_rej_cdmotivo := '21';
      RAISE vr_exc_reje;
    END IF;
    
    -- 26.3P Valida Data de Emissao
    IF pr_rec_cobranca.dtemscob IS NULL THEN --SD#581070
      -- Data de emissao inválida
      vr_rej_cdmotivo := '24';
      RAISE vr_exc_reje;
    ELSIF pr_rec_cobranca.dtemscob > to_date('13/10/2049','dd/mm/RRRR') OR
       TRUNC(SYSDATE) - vr_qtd_emi_ret > pr_rec_cobranca.dtemscob    THEN

      -- Data de documento superior ao limite 13/10/2049 ou
      -- Data retroativa maior que 90 dias.
      vr_rej_cdmotivo := '24';
      RAISE vr_exc_reje;
    END IF;
    
    IF pr_rec_cobranca.dtvencto < pr_rec_cobranca.dtemscob THEN
      -- Data de vencimento anterior a data de emissao
      vr_rej_cdmotivo := '17';
      RAISE vr_exc_reje;
    END IF;

    -- 27.3P Valida Codigo do Juros de Mora
    pr_rec_cobranca.tpdjuros := nvl(pr_tab_linhas('TPDJUROS').numero,0);
    IF pr_rec_cobranca.tpdjuros <> 1 AND  -- Valor por Dia
       pr_rec_cobranca.tpdjuros <> 2 AND  -- Taxa Mensal
       pr_rec_cobranca.tpdjuros <> 3 THEN -- Isento
      -- Codigo de Juros de Mora Invalido
      vr_rej_cdmotivo := '26';
      RAISE vr_exc_reje;
    END IF;
  
    -- 29.3P Valida Valor de Mora
    pr_rec_cobranca.vldjuros := pr_tab_linhas('VLDJUROS').numero;
    IF pr_rec_cobranca.tpdjuros = 1 THEN
      -- validacoes de Valor por Dia
      IF pr_rec_cobranca.vldjuros > pr_rec_cobranca.vltitulo OR
         pr_rec_cobranca.vldjuros = 0  THEN
        -- Valor/Taxa de Juros de Mora Invalido
        vr_rej_cdmotivo := '27';
        RAISE vr_exc_reje;
      END IF;
    ELSIF pr_rec_cobranca.tpdjuros = 2 THEN
      -- Validacoes de Taxa Mensal
      IF pr_rec_cobranca.vldjuros > 100  OR 
         pr_rec_cobranca.vldjuros = 0    THEN
        -- Valor/Taxa de Juros de Mora Invalido
        vr_rej_cdmotivo := '27';
        RAISE vr_exc_reje;
      END IF;
    ELSIF pr_rec_cobranca.tpdjuros = 3 THEN
      -- Validacoes de Isento
      -- Se Isento Desprezar Valor
      pr_rec_cobranca.vldjuros := 0;
    END IF;
  
    -- 30.3P Valida Codigo do Desconto */
    pr_rec_cobranca.tpdescto := pr_tab_linhas('TPDESCTO').numero;
    IF pr_rec_cobranca.tpdescto <> 0 AND   -- Desprezar Desconto
       pr_rec_cobranca.tpdescto <> 1 THEN  -- Valor Fixo ate a Data Informada
      -- Codigo do Desconto Invalido
      vr_rej_cdmotivo := '28';
      RAISE vr_exc_reje;
    END IF;
    
    --  31.3P 32.3P Valida Data de Desconto e Valor de Desconto
    pr_rec_cobranca.dtdescto:= pr_tab_linhas('DTDESCTO').numero;
    IF pr_rec_cobranca.tpdescto = 1 THEN 
      -- Valor Fixo ate a Data Informada
      pr_rec_cobranca.vldescto := pr_tab_linhas('VLDESCTO').numero;
      IF nvl(pr_rec_cobranca.vldescto,0) = 0 THEN
        -- Desconto a Conceder Nao Confere
        vr_rej_cdmotivo := '30';
        RAISE vr_exc_reje;
      END IF;
      
      IF pr_rec_cobranca.vldescto >= pr_rec_cobranca.vltitulo  THEN
        -- Valor do Desconto Maior ou Igual ao Valor do Titulo
        vr_rej_cdmotivo := '29';
        RAISE vr_exc_reje;
      END IF;
    END IF;

    -- 13.3P Validacao Nosso Numero
    -- Verifica se conta do cooperado confere com conta do nosso numero
    IF pr_nrdconta <> pr_rec_cobranca.nrdconta THEN
      -- Nosso Numero Invalido
      vr_rej_cdmotivo := '08';
      RAISE vr_exc_reje;
    END IF;
  
    IF pr_rec_cobranca.cdocorre = 01 THEN -- 01 - Remessa
      -- Verifica Existencia Titulo
      OPEN cr_crapcob(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_rec_cobranca.nrdconta,
                      pr_cdbandoc => pr_rec_header.cdbandoc,
                      pr_nrdctabb => pr_rec_header.nrdctabb,
                      pr_nrcnvcob => pr_rec_header.nrcnvcob,
                      pr_nrdocmto => pr_rec_cobranca.nrbloque);
                      
      FETCH cr_crapcob INTO rw_crapcob;
      -- Se nao encountrou a cobranca, gera erro
      IF cr_crapcob%FOUND THEN
        CLOSE cr_crapcob;
        -- Se o boleto possuir informacao de "LIQAPOSBX" e o cobranca
        -- nao entrou o boleto deve adicionado para ser processado
        IF NOT (rw_crapcob.dsinform LIKE 'LIQAPOSBX%' AND 
                rw_crapcob.incobran = 0) THEN
          -- Nosso Numero Duplicado
          vr_rej_cdmotivo := '09';
          RAISE vr_exc_reje;
        END IF;
      ELSE
        CLOSE cr_crapcob;
      END IF;
    END IF;
    
    -- 19.3P Valida Nro. Documento de Cobranca
    IF TRIM(pr_rec_cobranca.dsdoccop) IS NULL THEN 
      -- Seu Numero Invalido
      vr_rej_cdmotivo := '86';
      RAISE vr_exc_reje;
    END IF;
    
    IF fn_valida_caracteres(pr_flgnumer => TRUE,   -- Validar Numeros
                            pr_flgletra => TRUE,   -- Validar Letras
                            pr_listaesp => '',     -- Lista Caracteres Validos
                            pr_dsvalida => pr_rec_cobranca.dsdoccop ) THEN -- Documento
      -- Seu Numero Invalido
      vr_rej_cdmotivo := '86';
      RAISE vr_exc_reje;
    END IF;
      
    -- 34.3P Valor de Abatimento
    pr_rec_cobranca.vlabatim := pr_tab_linhas('VLABATIM').numero;
    IF pr_rec_cobranca.vlabatim >= pr_rec_cobranca.vltitulo THEN
      -- Valor do Abatimento Maior ou Igual ao Valor do Titulo
      vr_rej_cdmotivo := '34';
      RAISE vr_exc_reje;
    END IF;

    -- 36.3P Valida Codigo de Protesto
    pr_rec_cobranca.cdprotes := pr_tab_linhas('CDDPROTE').numero;
    IF pr_rec_cobranca.cdprotes <> 1 AND  -- Protestar Dias Corridos
       pr_rec_cobranca.cdprotes <> 2 AND  -- Negativar Serasa
       pr_rec_cobranca.cdprotes <> 3 AND  -- Nao Protestar
       pr_rec_cobranca.cdprotes <> 9 THEN -- Cancel. do Protesto automatico
      -- Codigo para Protesto Invalido
      vr_rej_cdmotivo := '37';
      RAISE vr_exc_reje;
    ELSE
      IF pr_tab_linhas('CDDPROTE').numero IN (2,3) THEN     
        pr_rec_cobranca.flgdprot := 0;
      ELSE
        pr_rec_cobranca.flgdprot := 1;
    END IF;
    END IF;
    
    IF pr_rec_cobranca.cdprotes = 9    AND  -- Cancel. do Protesto automatico
       pr_rec_cobranca.cdocorre <> 31  THEN -- Alteracao de Outros Dados
      -- Codigo para Protesto Invalido
      vr_rej_cdmotivo := '37';
      RAISE vr_exc_reje;
    END IF;

    -- Apenas pessoa Juridica pode realizar o protesto
    IF ( pr_rec_header.inpessoa = 1 AND pr_rec_cobranca.cdprotes = 1 ) THEN
      -- Pedido de protesto nao permitido para o titulo
      vr_rej_cdmotivo := '39';
      RAISE vr_exc_reje;
    END IF;

    -- 37.3P Valida Prazo para Protesto
    IF pr_rec_cobranca.cdprotes = 1 THEN -- Protestar Dias Corridos
      pr_rec_cobranca.qtdiaprt := nvl(pr_tab_linhas('QTDIAPRT').numero,0);
      -- Prazo para protesto valido de 5 a 15 dias
      IF pr_rec_cobranca.qtdiaprt < 5  OR 
         pr_rec_cobranca.qtdiaprt > 15 THEN
        -- Prazo para Protesto Invalido
        vr_rej_cdmotivo := '38';
        RAISE vr_exc_reje;
      END IF;
    ELSE
      pr_rec_cobranca.qtdiaprt := 0;
    END IF;
  
    IF pr_rec_cobranca.qtdiaprt <> 0 AND
       pr_rec_cobranca.cddespec NOT IN (01, 02) THEN /* DM e DS */
      -- Pedido de Protesto Não Permitido para o Título
      vr_rej_cdmotivo := '39';
      RAISE vr_exc_reje;
    END IF;
  
    --Modificado para efetuar demais validação junto ao sacado
    pr_rec_cobranca.serasa := pr_rec_header.flserasa;
  
    --Negativar Serasa e possui convenio serasa
    IF pr_rec_cobranca.cdprotes = 2 AND pr_rec_header.flserasa = 1 THEN
      pr_rec_cobranca.flserasa := 1;
      pr_rec_cobranca.qtdianeg := nvl(pr_tab_linhas('QTDIAPRT').numero,0);
    ELSE
      pr_rec_cobranca.flserasa := 0;
      pr_rec_cobranca.qtdianeg := 0;
    END IF;
    
    pr_des_reto := 'OK';
  
  EXCEPTION 
    WHEN vr_exc_fim  THEN
      -- Fim da execucao devido a ocorrencia que nao necessita do 
      -- restante das validacoes do segmento "P"
      pr_des_reto:= 'OK';
      
    WHEN vr_exc_reje THEN
      -- Rejeitou a cobranca e nao deve continuar o processamento
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_nrdconta --SD#580867 Enviar o pr_nrdconta ao inves do pr_rec_cobranca.nrdconta, pois quando o motivo eh 08 o campo pr_rec_cobranca.nrdconta eh gerado com valor errado
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
      
      pr_des_reto:= 'NOK';
      pr_rec_cobranca.flgrejei:= TRUE;
      
    WHEN OTHERS THEN
      -- Erro geral no processamento - codigo 99
      vr_rej_cdmotivo:= '99';
      -- Erro geral do processamento do segmento "P"
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_nrdconta --SD#580867 Enviar o pr_nrdconta ao inves do pr_rec_cobranca.nrdconta, pois quando o motivo eh 08 o campo pr_rec_cobranca.nrdconta eh gerado com valor errado
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
                                
      -- Quando ocorrer erro geral em procedures que processam os segmentos
      -- deve gerar as informacoes da cobranca em questao no arquivo proc_message.log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') || ' - COBR0006' ||
                                                    ' --> pc_trata_segmento_p_240_85' ||
                                                    ' Coop: '      || pr_cdcooper ||
                                                    ' Conta: '     || pr_nrdconta ||
                                                    ' Remessa: '   || pr_rec_header.nrremass ||
                                                    ' Convenio: '  || pr_rec_header.nrcnvcob ||
                                                    ' Nosso Num.:' || pr_rec_cobranca.dsnosnum ||
                                                    ' - TRACE: '   || dbms_utility.format_error_backtrace || 
                                                    ' - '          || dbms_utility.format_error_stack);
                                
      -- Ignora a cobranca
      pr_des_reto:= 'NOK';
      pr_rec_cobranca.flgrejei:= TRUE;
      
  END pc_trata_segmento_p_240_85;
  
  --> Tratar linha do arquivo tipo de registro Q
  PROCEDURE pc_trata_segmento_q_240_85 (pr_cdcooper      IN crapcop.cdcooper%TYPE,   --> Codigo da cooperativa
                                        pr_nrdconta      IN crapass.nrdconta%TYPE,   --> Numero da conta do cooperado
                                        pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE,   --> Data de movimento
                                        pr_cdoperad      IN crapope.cdoperad%TYPE,   --> Operador
                                        pr_tab_linhas    IN gene0009.typ_tab_campos, --> Dados da linha
                                        pr_rec_header    IN typ_rec_header,          --> Dados do Header do Arquivo
                                        pr_rec_cobranca  IN OUT NOCOPY typ_rec_cobranca,    --> Dados da Cobranca
                                        pr_tab_rejeitado IN OUT NOCOPY typ_tab_rejeitado,   --> Tabela de Rejeitados
                                        pr_tab_sacado    IN OUT NOCOPY typ_tab_sacado,      --> Tabela de Sacados
                                        pr_des_reto         OUT VARCHAR2             --> Retorno OK/NOK
                                        ) IS
                                         
  /* ............................................................................

       Programa: pc_trata_segmento_q_240_85
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Novembro/2015.                   Ultima atualizacao: 22/12/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Tratar linha do arquivo tipo de segmento Q

       Alteracoes: 06/01/2016 - Conversão Progress -> Oracle (Douglas Quisinski)

		           27/05/2016 - Ajuste para considerar o caracter ":" ao chamar
								a rotina de validação de caracteres para endereços
								(Andrei). 
                
                   26/10/2016 - Ajuste na validacao do nome do sacado para considerar 
                                o caracter ':' como valido.
                               (Chamado 535830) - (Fabricio)

                   13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
							   (Andrei - Mouts).
                               
                   17/03/2017 - Removido a validação que verificava se o CEP do pagador do boleto existe no Ayllos. 
                                Solicitado pelo Leomir e aprovado pelo Victor (cobrança)
                               (Douglas - Chamado 601436)

                   07/06/2017 - Trocar na validação de Serasa qtdiaprt por qtdianeg. Somente
                                quando pr_rec_cobranca.flserasa = 1. (SD#686881 - AJFink)

                   26/10/2017 - Validar CPF e CNPJ de acordo com o tipo de inscricao (Rafael)

                   08/11/2017 - Adicionar chamada para a função fn_remove_chr_especial que
                                remove o caractere invalido chr(160) (Douglas - Chamado 778480)

                   22/12/2017 - Validar se o CPF/CNPJ do pagador é o mesmo do titular da conta
                                e rejeitar com o motivo '46' (Douglas - Chamado 819777)
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_reje   EXCEPTION;
    vr_exc_fim    EXCEPTION;
    vr_dscritic   VARCHAR2(4000);
    vr_qtminimo   INTEGER := 0;
    vr_qtmaximo   INTEGER := 0;
    vr_vlminimo   NUMBER(25,2) := 0;
    vr_dstexto_dias VARCHAR2(500);

    ------------------------------- CURSORES ---------------------------------    
    
    --> seleciona os uf não permitidor para protestar
    CURSOR cr_dsnegufds(pr_cdcooper crapsab.cdcooper%TYPE) IS
      SELECT p.dsnegufds
        FROM tbcobran_param_protesto p
       WHERE p.cdcooper = pr_cdcooper;
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_stsnrcal  BOOLEAN;
    vr_inpessoa  INTEGER;
    vr_rej_cdmotivo VARCHAR2(2);
    vr_dsnegufds tbcobran_param_protesto.dsnegufds%TYPE;
    
  BEGIN

    --> Validacao de Comandos de Instrucao
    IF pr_rec_cobranca.cdocorre <> 1 THEN -- 01 - Remessa
      IF pr_rec_cobranca.cdocorre = 31 THEN  -- 31 - Outros dados
        -- Realiza as validações da instrucao
        pc_valida_exec_instrucao (pr_cdcooper   => pr_cdcooper,
                                  pr_nrdconta   => pr_nrdconta,
                                  pr_rec_header => pr_rec_header,
                                  pr_tab_linhas => pr_tab_linhas,
                                  pr_cdocorre   => pr_rec_cobranca.cdocorre,
                                  pr_tipocnab   => '240',
                                  pr_cdmotivo   => vr_rej_cdmotivo);
                                  

        IF TRIM(vr_rej_cdmotivo) IS NOT NULL THEN
          pc_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                            ,pr_nrdconta      => pr_nrdconta -- Enviar o pr_nrdconta ao inves do pr_rec_cobranca.nrdconta, pois quando o motivo eh 08 o campo pr_rec_cobranca.nrdconta eh gerado com valor errado
                            ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                            ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                            ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                            ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                            ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                            ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                            ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                            ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                            ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                            ,pr_cdoperad      => pr_cdoperad              --> Operador
                            ,pr_cdocorre      => 26                       --> Codigo da Ocorrencia
                            ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                            ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
        END IF;
      END IF;
      
      RAISE vr_exc_fim;
    END IF;

    -- Dados do sacado
    pr_rec_cobranca.nmdsacad := fn_remove_chr_especial(pr_texto => pr_tab_linhas('NMDSACAD').texto);
    pr_rec_cobranca.dsendsac := fn_remove_chr_especial(pr_texto => pr_tab_linhas('DSENDSAC').texto);
    pr_rec_cobranca.nmbaisac := fn_remove_chr_especial(pr_texto => pr_tab_linhas('NMBAISAC').texto);
    pr_rec_cobranca.nmcidsac := fn_remove_chr_especial(pr_texto => pr_tab_linhas('NMCIDSAC').texto);   
    pr_rec_cobranca.cdufsaca := fn_remove_chr_especial(pr_texto => pr_tab_linhas('CDUFSACA').texto);
    pr_rec_cobranca.nrcepsac := pr_tab_linhas('NRCEPSAC').numero;
    
    IF pr_rec_cobranca.flserasa = 1 THEN
      
      vr_qtminimo := 0;  
      vr_qtmaximo := 0;
      vr_vlminimo := 0;
      
      --Rotina para buscar paraemtros de negativacao com base no estado do sacado
      sspc0002.pc_busca_param_negativ(pr_cdcooper             => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                                     ,pr_cduf_sacado          => pr_rec_cobranca.cdufsaca -- Codigo da UF do Sacado
                                     ,pr_qtminimo_negativacao => vr_qtminimo
                                     ,pr_qtmaximo_negativacao => vr_qtmaximo
                                     ,pr_vlminimo_boleto      => vr_vlminimo
                                     ,pr_dstexto_dias         => vr_dstexto_dias
                                     ,pr_dscritic             => vr_dscritic);
    
      --Prazo valido
      IF (pr_rec_cobranca.qtdianeg < vr_qtminimo  OR
          pr_rec_cobranca.qtdianeg > vr_qtmaximo) THEN
        -- Prazo para Negativacao Serasa Invalido
        vr_rej_cdmotivo := 'S3';
        RAISE vr_exc_reje;     
      END IF;
      
      IF pr_rec_cobranca.vltitulo < vr_vlminimo THEN
        --  Valor Inferior au Minimo Permitido para Negativacao Serasa Invalido
        vr_rej_cdmotivo := 'S4';
        RAISE vr_exc_reje;     
      END IF;
      
    END IF;
    
    -- 01.3Q Banco
    IF pr_tab_linhas('CDBANCMP').numero <> 085 THEN -- CECRED
      -- Codigo do Banco Invalido
      vr_rej_cdmotivo := '01';
      RAISE vr_exc_reje;
    END IF;

    -- 08.3Q Valida Tipo de Inscricao
    pr_rec_cobranca.cdtpinsc := nvl(pr_tab_linhas('INPESSOA').numero,0);
    IF pr_rec_cobranca.cdtpinsc <> 1 AND
       pr_rec_cobranca.cdtpinsc <> 2  THEN
      -- Tipo/Numero de Inscricao do Sacado Invalidos
      vr_rej_cdmotivo := '46';
      RAISE vr_exc_reje;
    END IF;

    -- 09.3Q Valida Numero de Inscricao
    pr_rec_cobranca.nrinssac := pr_tab_linhas('NRCPFCGC').numero;
    gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_rec_cobranca.nrinssac,
                                pr_stsnrcal => vr_stsnrcal, 
                                pr_inpessoa => vr_inpessoa);
    -- Verifica se o CPF/CNPJ esta correto
    IF NOT vr_stsnrcal THEN
      -- Tipo/Numero de Inscricao do Sacado Invalidos
      vr_rej_cdmotivo := '46';
      RAISE vr_exc_reje;
    END IF;

    -- se pagador dor PF, entao validar CPF
    IF pr_rec_cobranca.cdtpinsc = 1 THEN
      gene0005.pc_valida_cpf(pr_nrcalcul => pr_rec_cobranca.nrinssac,
                             pr_stsnrcal => vr_stsnrcal);                             
      -- Verifica se o CPF esta correto
      IF NOT vr_stsnrcal THEN
        -- Tipo/Numero de Inscricao do Sacado Invalidos
        vr_rej_cdmotivo := '46';
        RAISE vr_exc_reje;
      END IF;                             
    END IF;
    
    -- se pagador dor PJ, entao validar CNPJ
    IF pr_rec_cobranca.cdtpinsc = 2 THEN
      gene0005.pc_valida_cnpj(pr_nrcalcul => pr_rec_cobranca.nrinssac,
                              pr_stsnrcal => vr_stsnrcal);                             
      -- Verifica se o CNPJ esta correto
      IF NOT vr_stsnrcal THEN
        -- Tipo/Numero de Inscricao do Sacado Invalidos
        vr_rej_cdmotivo := '46';
        RAISE vr_exc_reje;
      END IF;                             
    END IF;        
    
    -- Validar se o CPF/CNPJ do pagador é o mesmo do Beneficiário
    IF pr_rec_cobranca.nrinssac = pr_rec_header.nrcpfcgc THEN
      -- Tipo/Numero de Inscricao do Sacado Invalidos
      vr_rej_cdmotivo := '46';
      RAISE vr_exc_reje;
    END IF;                             

    -- 10.3Q Valida Nome do Sacado
    IF TRIM(pr_rec_cobranca.nmdsacad) IS NULL THEN
      -- Nome do Sacado Nao Informado
      vr_rej_cdmotivo := '45';
      RAISE vr_exc_reje;
    END IF;
    
    -- Validar os caracteres do nome do sacado
    IF fn_valida_caracteres(pr_flgnumer => TRUE,   -- Validar Numeros
                            pr_flgletra => TRUE,   -- Validar Letras
                            pr_listaesp => '',     -- Lista Caracteres Validos
                            pr_dsvalida => pr_rec_cobranca.nmdsacad ) THEN -- Nome do Sacado
      -- Nome do Sacado Nao Informado
      vr_rej_cdmotivo := '45';
      RAISE vr_exc_reje;
    END IF;

    -- 11.3Q Valida Endereco do Sacado
    IF TRIM(pr_rec_cobranca.dsendsac) IS NULL THEN
      -- Endereco do Sacado Nao Informado
      vr_rej_cdmotivo := '47';
      RAISE vr_exc_reje;
    END IF;
    
    --Buscando os uf não permitidos para protestar
    OPEN cr_dsnegufds(pr_cdcooper);
    FETCH cr_dsnegufds INTO vr_dsnegufds;
    CLOSE cr_dsnegufds;
    
    IF pr_rec_cobranca.qtdiaprt <> 0 AND
       vr_dsnegufds LIKE '%' || pr_rec_cobranca.cdufsaca || '%' AND 
       pr_rec_cobranca.cddespec = 02 /*DS*/ THEN
         --Pedido de Protesto Não Permitido para o Título
         vr_rej_cdmotivo := '39';
         RAISE vr_exc_reje;
    END IF;
    
    -- Validar os caracteres do endereco do sacado
    IF fn_valida_caracteres(pr_flgnumer => TRUE,   -- Validar Numeros
                            pr_flgletra => TRUE,   -- Validar Letras
                            pr_listaesp => '',     -- Lista Caracteres Validos
                            pr_dsvalida => REPLACE(pr_rec_cobranca.dsendsac,',','') ) THEN -- Endereco do Sacado
      -- Endereco do Sacado Nao Informado
      vr_rej_cdmotivo := '47';
      RAISE vr_exc_reje;
    END IF;

    -- 13.3Q e 14.3Q Valida CEP do Sacado, ou está zerado
    IF TRIM(pr_rec_cobranca.nrcepsac) IS NULL OR 
       NVL(pr_rec_cobranca.nrcepsac, 0) = 0 THEN
       
      --  CEP Invalido
      vr_rej_cdmotivo := '48';
      RAISE vr_exc_reje;
      
    END IF;
    
    -- Validar os caracteres do cep do sacado
    IF fn_valida_caracteres(pr_flgnumer => TRUE   -- Validar Numeros
                           ,pr_flgletra => FALSE  -- Validar Letras
                           ,pr_listaesp => ''     -- Lista Caracteres Validos
                           ,pr_dsvalida => pr_rec_cobranca.nrcepsac ) THEN -- Nome do Sacado
                            
      -- CEP invalido
      vr_rej_cdmotivo := '48';
      RAISE vr_exc_reje;
      
    END IF;
    

/* Nao sera mais validado se o CEP existe no sistema
   Chamado 601436 -> Solicitado por Leomir e autorizado pelo Victor Hugo Zimmerman
   
    -- 13.3Q e 14.3Q Valida CEP do Sacado
    -- Pesquisar a Origem = CORREIOS
    OPEN cr_crapdne (pr_nrceplog => pr_rec_cobranca.nrcepsac,
                     pr_idoricad => 1); -- Correios
                     
    FETCH cr_crapdne INTO rw_crapdne;
    
    IF cr_crapdne%NOTFOUND THEN
      
      CLOSE cr_crapdne;
      
      -- Se nao encontrou 
      -- Pesquisar a Origem = AYLLOS
      OPEN cr_crapdne(pr_nrceplog => pr_rec_cobranca.nrcepsac,
                      pr_idoricad => 2); -- Ayllos
                      
      FETCH cr_crapdne INTO rw_crapdne;
      
    END IF;
      
    IF cr_crapdne%NOTFOUND THEN
      
      IF cr_crapdne%ISOPEN THEN
        CLOSE cr_crapdne;
      END IF;
      
      -- CEP Invalido
      vr_rej_cdmotivo := '48';
      RAISE vr_exc_reje;
      
    END IF;
    
    IF cr_crapdne%ISOPEN THEN
      CLOSE cr_crapdne;
    END IF;
*/

    -- 16.3Q Valida UF do Sacado
	/*
    IF pr_rec_cobranca.cdufsaca <> rw_crapdne.cduflogr THEN
      --  CEP incompativel com a Unidade da Federacao
      vr_rej_cdmotivo := '51';
      RAISE vr_exc_reje;
    END IF;
	*/

	--validar UF que esta no arquivo.

	OPEN cr_caduf(pr_rec_cobranca.cdufsaca);
    
    FETCH cr_caduf INTO rw_caduf;
        
    IF cr_caduf%NOTFOUND THEN      
	  
      CLOSE cr_caduf;
      vr_rej_cdmotivo := '51';
      RAISE vr_exc_reje;
      
    END IF;
        
    CLOSE cr_caduf;


    -- 17.3Q Valida Tipo de Inscricao Avalista
    pr_rec_cobranca.cdtpinav := nvl(pr_tab_linhas('CDTPINAV').numero,0);
    IF pr_rec_cobranca.cdtpinav <> 0 AND  -- Vazio
       pr_rec_cobranca.cdtpinav <> 1 AND  -- Fisica
       pr_rec_cobranca.cdtpinav <> 2 THEN -- Juridica
      -- Tipo/Numero de Inscricao do Sacador/Avalista Invalidos
      vr_rej_cdmotivo := '53';
      RAISE vr_exc_reje;
    END IF;

    -- 18.3Q Valida Numero de Inscricao Avalista
    IF pr_rec_cobranca.cdtpinav <> 0 THEN
      pr_rec_cobranca.nrinsava := pr_tab_linhas('NRINSAVA').numero;
    
      -- 09.3Q Valida Numero de Inscricao
      gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_rec_cobranca.nrinsava, 
                                  pr_stsnrcal => vr_stsnrcal, 
                                  pr_inpessoa => vr_inpessoa);
      -- Verifica se o CPF/CNPJ esta correto
      IF NOT vr_stsnrcal THEN
        -- Tipo/Numero de Inscricao do Sacador/Avalista Invalidos
        vr_rej_cdmotivo := '53';
        RAISE vr_exc_reje;
      END IF;
    END IF;

    -- 19.3Q Valida Nome do Sacado Avalista
    IF pr_rec_cobranca.cdtpinav <> 0 THEN
      pr_rec_cobranca.nmdavali := pr_tab_linhas('NMDAVALI').texto;
      IF TRIM(pr_rec_cobranca.nmdavali) IS NULL THEN
        -- Sacador/Avalista Nao Informado
        vr_rej_cdmotivo := '54';
        RAISE vr_exc_reje;
      END IF;

      -- Validar os caracteres do endereco do sacado
      IF fn_valida_caracteres(pr_flgnumer => TRUE,   -- Validar Numeros
                              pr_flgletra => TRUE,   -- Validar Letras
                              pr_listaesp => '',     -- Lista Caracteres Validos
                              pr_dsvalida => pr_rec_cobranca.nmdavali ) THEN -- Nome do Sacado/Avalista
        -- Sacado/Avalista Nao Informado
        vr_rej_cdmotivo := '54';
        RAISE vr_exc_reje;
      END IF;
    END IF;
    
    -- Se for solicitacao de Remessa, entao devera gravar sacado
    IF  pr_rec_cobranca.cdocorre = 01 THEN
       pc_grava_sacado( pr_cdoperad     => pr_cdoperad,     --> Operador
                        pr_rec_cobranca => pr_rec_cobranca, --> Dados da linha
                        pr_tab_sacado   => pr_tab_sacado,   --> Tabela de Instrucoes
                        pr_dscritic     => vr_dscritic);    --> Descricao do Erro
    END IF;
    
    pr_des_reto := 'OK';
  
  EXCEPTION 
    WHEN vr_exc_fim  THEN
      -- Fim da execucao devido a ocorrencia que nao necessita do 
      -- restante das validacoes do segmento "Q"
      pr_des_reto:= 'OK';
      
    WHEN vr_exc_reje THEN
      -- Rejeitou a cobranca e nao deve continuar o processamento
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_rec_cobranca.nrdconta --> Numero da Conta
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
      pr_des_reto:= 'NOK';
      pr_rec_cobranca.flgrejei:= TRUE;
      
    WHEN OTHERS THEN
      -- Erro geral no processamento - codigo 99
      vr_rej_cdmotivo:= '99';
      -- Erro geral do processamento do segmento "Q"
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_rec_cobranca.nrdconta --> Numero da Conta
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
                                
      -- Quando ocorrer erro geral em procedures que processam os segmentos
      -- deve gerar as informacoes da cobranca em questao no arquivo proc_message.log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - COBR0006 --> pc_trata_segmento_q_240_85' ||
                                                    ' Coop: '      || pr_cdcooper ||
                                                    ' Conta: '     || pr_nrdconta ||
                                                    ' Remessa: '   || pr_rec_header.nrremass ||
                                                    ' Convenio: '  || pr_rec_header.nrcnvcob ||
                                                    ' Nosso Num.:' || pr_rec_cobranca.dsnosnum ||
                                                    ' - TRACE: '   || dbms_utility.format_error_backtrace || 
                                                    ' - '          || dbms_utility.format_error_stack);
                                
      -- Ignora a cobranca
      pr_des_reto:= 'NOK';
      pr_rec_cobranca.flgrejei:= TRUE;
      
  END pc_trata_segmento_q_240_85;

  --> Tratar linha do arquivo tipo de registro R
  PROCEDURE pc_trata_segmento_r_240_85 (pr_cdcooper      IN crapcop.cdcooper%TYPE,   --> Codigo da cooperativa
                                        pr_nrdconta      IN crapass.nrdconta%TYPE,   --> Numero da conta do cooperado
                                        pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE,   --> Data de movimento
                                        pr_cdoperad      IN crapope.cdoperad%TYPE,   --> Operador
                                        pr_tab_linhas    IN gene0009.typ_tab_campos, --> Dados da linha
                                        pr_rec_header    IN typ_rec_header,          --> Dados do Header do Arquivo
                                        pr_rec_cobranca  IN OUT NOCOPY typ_rec_cobranca,    --> Dados da Cobranca
                                        pr_tab_rejeitado IN OUT NOCOPY typ_tab_rejeitado,   --> Tabela de Rejeitados
                                        pr_des_reto         OUT VARCHAR2             --> Retorno OK/NOK
                                        ) IS
                                   
  /* ............................................................................

       Programa: pc_trata_segmento_r_240_85
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Novembro/2015.                   Ultima atualizacao: 13/02/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Tratar linha do arquivo tipo de segmento R

       Alteracoes: 06/01/2016 - Conversão Progress -> Oracle (Douglas Quisinski)
	    
		           13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 

    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_reje   EXCEPTION;
    vr_exc_fim    EXCEPTION;
    
    ------------------------------- CURSORES ---------------------------------    
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_rej_cdmotivo VARCHAR2(2);
    
  BEGIN
    -- Somente valor de o codigo de movimento for 1
    IF pr_tab_linhas('CDMOVRE').numero <> 1 THEN
      RAISE vr_exc_fim;
    END IF;

    --> Nao verifica registro R quando Instrucao
    IF pr_rec_cobranca.cdocorre <> 1 THEN -- 01 - Remessa
      RAISE vr_exc_fim;
    END IF;
    
    -- 14.3R Valida Codigo da Multa
    pr_rec_cobranca.tpdmulta := pr_tab_linhas('TPDMULTA').numero;
    IF pr_rec_cobranca.tpdmulta <> 1 AND  -- Valor Fixo
       pr_rec_cobranca.tpdmulta <> 2 THEN -- Percentual
      -- Codigo da Multa Invalido
      vr_rej_cdmotivo := '57';
      RAISE vr_exc_reje;
    END IF;

    -- 16.3R Valida Valor da Multa
    pr_rec_cobranca.vldmulta := pr_tab_linhas('VLDMULTA').numero;
    -- se nao possui valor de multa, colocar o tipo de multa para 3-Isento
    IF pr_rec_cobranca.vldmulta = 0 THEN
      pr_rec_cobranca.tpdmulta := 3;
    ELSE
      IF pr_rec_cobranca.tpdmulta = 1 THEN -- Valor Fixo
        IF pr_rec_cobranca.vldmulta > pr_rec_cobranca.vltitulo THEN
          --Valor/Percentual da Multa Invalido
          vr_rej_cdmotivo := '59';
          RAISE vr_exc_reje;
        END IF;
      ELSE -- Percentual
        IF pr_rec_cobranca.vldmulta > 100  THEN
          -- Valor/Percentual da Multa Invalido
          vr_rej_cdmotivo := '59';
          RAISE vr_exc_reje;
        END IF;
      END IF;
    END IF;

    pr_des_reto := 'OK';
  
  EXCEPTION 
    WHEN vr_exc_fim  THEN
      -- Fim da execucao devido a ocorrencia que nao necessita do 
      -- restante das validacoes do segmento "R"
      pr_des_reto:= 'OK';
      
    WHEN vr_exc_reje THEN
      -- Rejeitou a cobranca e nao deve continuar o processamento
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_rec_cobranca.nrdconta --> Numero da Conta
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
      pr_des_reto:= 'NOK';
      pr_rec_cobranca.flgrejei:= TRUE;
      
    WHEN OTHERS THEN
      -- Erro geral no processamento - codigo 99
      vr_rej_cdmotivo := '99';
      -- Erro geral do processamento do segmento "R"
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_rec_cobranca.nrdconta --> Numero da Conta
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
                                
      -- Quando ocorrer erro geral em procedures que processam os segmentos
      -- deve gerar as informacoes da cobranca em questao no arquivo proc_message.log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - COBR0006 --> pc_trata_segmento_r_240_85' ||
                                                    ' Coop: '      || pr_cdcooper ||
                                                    ' Conta: '     || pr_nrdconta ||
                                                    ' Remessa: '   || pr_rec_header.nrremass ||
                                                    ' Convenio: '  || pr_rec_header.nrcnvcob ||
                                                    ' Nosso Num.:' || pr_rec_cobranca.dsnosnum ||
                                                    ' - TRACE: '   || dbms_utility.format_error_backtrace || 
                                                    ' - '          || dbms_utility.format_error_stack);
                                
      -- Ignora a cobranca
      pr_des_reto:= 'NOK';
      pr_rec_cobranca.flgrejei:= TRUE;
      
  END pc_trata_segmento_r_240_85;

  --> Tratar linha do arquivo tipo de registro S
  PROCEDURE pc_trata_segmento_s_240_85 (pr_cdcooper      IN crapcop.cdcooper%TYPE,   --> Codigo da cooperativa
                                        pr_nrdconta      IN crapass.nrdconta%TYPE,   --> Numero da conta do cooperado
                                        pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE,   --> Data de movimento
                                        pr_cdoperad      IN crapope.cdoperad%TYPE,   --> Operador
                                        pr_rec_header    IN typ_rec_header,          --> Dados do Header do Arquivo
                                        pr_tab_linhas    IN gene0009.typ_tab_campos, --> Dados da linha
                                        pr_rec_cobranca  IN OUT NOCOPY typ_rec_cobranca,    --> Dados da Cobranca
                                        pr_tab_rejeitado IN OUT NOCOPY typ_tab_rejeitado,   --> Tabela de Rejeitados
                                        pr_des_reto         OUT VARCHAR2             --> Retorno OK/NOK
                                        ) IS
                                   
  /* ............................................................................

       Programa: pc_trata_segmento_s_240_85
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Novembro/2015.                   Ultima atualizacao: 13/02/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Tratar linha do arquivo tipo de segmento S

       Alteracoes: 06/01/2016 - Conversão Progress -> Oracle (Douglas Quisinski)

	               13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 

    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_fim    EXCEPTION;
    
    ------------------------------- CURSORES ---------------------------------    
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_rej_cdmotivo VARCHAR2(2);
    
  BEGIN
    
    -- Importar linha de mensagem quando solicitacao de remessa
    IF pr_tab_linhas('CDMOVRE').numero = 1 AND 
       pr_tab_linhas('IDIMPRES').numero = 3 THEN

      /* Nao verifica registro R quando Instrucao */
      IF pr_rec_cobranca.cdocorre <> 1 THEN -- 1 - Remessa
        RAISE vr_exc_fim;
      END IF;

      /* Concatena instrucoes separadas por _   */
      pr_rec_cobranca.dsdinstr := fn_remove_chr_especial(pr_tab_linhas('DSMENSG5').texto || '_' ||
                                  pr_tab_linhas('DSMENSG6').texto || '_' ||
                                  pr_tab_linhas('DSMENSG7').texto || '_' ||
                                  pr_tab_linhas('DSMENSG8').texto || '_' ||
                                                         pr_tab_linhas('DSMENSG9').texto);
    END IF;
    
    pr_des_reto := 'OK';
    
  EXCEPTION 
    WHEN vr_exc_fim  THEN
      -- Fim da execucao devido a ocorrencia que nao necessita do 
      -- restante das validacoes do segmento "S"
      pr_des_reto:= 'OK';
      
    WHEN OTHERS THEN
      -- Erro geral no processamento - codigo 99
      vr_rej_cdmotivo := '99';
      -- Erro geral do processamento do segmento "S"
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_rec_cobranca.nrdconta --> Numero da Conta
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
                                
      -- Quando ocorrer erro geral em procedures que processam os segmentos
      -- deve gerar as informacoes da cobranca em questao no arquivo proc_message.log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - COBR0006 --> pc_trata_segmento_r' ||
                                                    ' Coop: '      || pr_cdcooper ||
                                                    ' Conta: '     || pr_nrdconta ||
                                                    ' Remessa: '   || pr_rec_header.nrremass ||
                                                    ' Convenio: '  || pr_rec_header.nrcnvcob ||
                                                    ' Nosso Num.:' || pr_rec_cobranca.dsnosnum ||
                                                    ' - TRACE: '   || dbms_utility.format_error_backtrace || 
                                                    ' - '          || dbms_utility.format_error_stack);
      -- Ignora a cobranca
      pr_rec_cobranca.flgrejei:= TRUE;
      pr_des_reto:= 'NOK';
      
  END pc_trata_segmento_s_240_85;

  --> Tratar linha do arquivo tipo de registro Y-04
  PROCEDURE pc_trata_segmento_y04_240_85 (pr_cdcooper      IN crapcop.cdcooper%TYPE,   --> Codigo da cooperativa
                                          pr_nrdconta      IN crapass.nrdconta%TYPE,   --> Numero da conta do cooperado
                                          pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE,   --> Data de movimento
                                          pr_cdoperad      IN crapope.cdoperad%TYPE,   --> Operador
                                          pr_rec_header    IN typ_rec_header,          --> Dados do Header do Arquivo
                                          pr_tab_linhas    IN gene0009.typ_tab_campos, --> Dados da linha
                                          pr_rec_cobranca  IN OUT NOCOPY typ_rec_cobranca,    --> Dados da Cobranca
                                          pr_tab_rejeitado IN OUT NOCOPY typ_tab_rejeitado,   --> Tabela de Rejeitados
                                          pr_tab_sacado    IN OUT NOCOPY typ_tab_sacado,      --> Tabela de Sacados
                                          pr_des_reto         OUT VARCHAR2             --> Retorno OK/NOK
                                         ) IS
                                   
  /* ............................................................................

       Programa: pc_trata_segmento_y04_240_85
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Novembro/2015.                   Ultima atualizacao: 13/02/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Tratar linha do arquivo tipo de segmento Y-04

       Alteracoes: 06/01/2016 - Conversão Progress -> Oracle (Douglas Quisinski)

	               13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 

                   18/01/2019 - INC0027091 - Inclusão de motivo XW para SMS não contratado 
                   (Douglas Pagel/ AMcom).

    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    
    ------------------------------- CURSORES ---------------------------------    
    CURSOR cr_config IS
      SELECT 1
        FROM tbcobran_sms_contrato
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND dhcancela IS NULL;
    rw_config cr_config%ROWTYPE;
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_rej_cdmotivo VARCHAR2(2);
    vr_dscritic VARCHAR2(500);
    
  BEGIN
    
    -- Importar linha de mensagem quando solicitacao de remessa
    IF pr_tab_linhas('TPREGOPC').numero = 3 THEN
      -- 09.4Y - E-mail para envio da informacao
      pr_rec_cobranca.dsdemail := pr_tab_linhas('DSDEMAIL').texto;
      -- 10.4Y 11.4Y - Celular do pagador
      pr_rec_cobranca.nrcelsac := pr_tab_linhas('NRCELSAC').texto;
      -- Indicadores de SMS
      IF pr_tab_linhas('INAVISMS').numero = 0 THEN
        pr_rec_cobranca.inavisms := 0;
        pr_rec_cobranca.insmsant := 0;
        pr_rec_cobranca.insmsvct := 0;
        pr_rec_cobranca.insmspos := 0;
      ELSE
        -- verifica se pode existir SMS para a conta
        OPEN cr_config;
        FETCH cr_config INTO rw_config;
        -- Se nao possui acesso gera rejeicao
        IF cr_config%NOTFOUND THEN
          pr_rec_cobranca.inavisms := 0;
          pr_rec_cobranca.insmsant := 0;
          pr_rec_cobranca.insmsvct := 0;
          pr_rec_cobranca.insmspos := 0;
          -- Insere como rejeitado
          vr_rej_cdmotivo := 'XW';
          pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                                   ,pr_nrdconta      => pr_rec_cobranca.nrdconta --> Numero da Conta
                                   ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                                   ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                                   ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                                   ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                                   ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                                   ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                                   ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                                   ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                                   ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                                   ,pr_cdoperad      => pr_cdoperad              --> Operador
                                   ,pr_cdocorre      => 26                       --> Codigo da Ocorrencia
                                   ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                                   ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
        ELSE
          pr_rec_cobranca.inavisms := pr_tab_linhas('INAVISMS').numero;
          pr_rec_cobranca.insmsant := pr_tab_linhas('INSMSANT').numero;
          pr_rec_cobranca.insmsvct := pr_tab_linhas('INSMSVCT').numero;
          pr_rec_cobranca.insmspos := pr_tab_linhas('INSMSPOS').numero;
        END IF;
       CLOSE cr_config;
      END IF;

      -- Se for solicitacao de Remessa, entao devera gravar sacado
      IF  pr_rec_cobranca.cdocorre = 01 THEN
         pc_grava_sacado( pr_cdoperad     => pr_cdoperad,     --> Operador
                          pr_rec_cobranca => pr_rec_cobranca, --> Dados da linha
                          pr_tab_sacado   => pr_tab_sacado,   --> Tabela de Instrucoes
                          pr_dscritic     => vr_dscritic);    --> Descricao do Erro
      END IF;

    END IF;
    
    pr_des_reto := 'OK';
    
  EXCEPTION 
      
    WHEN OTHERS THEN
      -- Erro geral no processamento - codigo 99
      vr_rej_cdmotivo := '99';
      -- Erro geral do processamento do segmento "Y-04"
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_rec_cobranca.nrdconta --> Numero da Conta
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
                                
      -- Quando ocorrer erro geral em procedures que processam os segmentos
      -- deve gerar as informacoes da cobranca em questao no arquivo proc_message.log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - COBR0006 --> pc_trata_segmento_y04_240_85' ||
                                                    ' Coop: '      || pr_cdcooper ||
                                                    ' Conta: '     || pr_nrdconta ||
                                                    ' Remessa: '   || pr_rec_header.nrremass ||
                                                    ' Convenio: '  || pr_rec_header.nrcnvcob ||
                                                    ' Nosso Num.:' || pr_rec_cobranca.dsnosnum ||
                                                    ' - TRACE: '   || dbms_utility.format_error_backtrace || 
                                                    ' - '          || dbms_utility.format_error_stack);
      
      -- Ignora a cobranca
      pr_rec_cobranca.flgrejei:= TRUE;
      pr_des_reto:= 'NOK';
      
  END pc_trata_segmento_y04_240_85;

  --> Tratar linha do arquivo tipo de registro Y-53
  PROCEDURE pc_trata_segmento_y53_240_85 (pr_cdcooper      IN crapcop.cdcooper%TYPE,   --> Codigo da cooperativa
                                          pr_nrdconta      IN crapass.nrdconta%TYPE,   --> Numero da conta do cooperado
                                          pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE,   --> Data de movimento
                                          pr_cdoperad      IN crapope.cdoperad%TYPE,   --> Operador
                                          pr_rec_header    IN typ_rec_header,          --> Dados do Header do Arquivo
                                          pr_tab_linhas    IN gene0009.typ_tab_campos, --> Dados da linha
                                          pr_rec_cobranca  IN OUT NOCOPY typ_rec_cobranca,    --> Dados da Cobranca
                                          pr_tab_rejeitado IN OUT NOCOPY typ_tab_rejeitado,   --> Tabela de Rejeitados
                                          pr_des_reto         OUT VARCHAR2             --> Retorno OK/NOK
                                         ) IS
                                   
  /* ............................................................................

       Programa: pc_trata_segmento_y53_240_85
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Ricardo Linhares
       Data    : Dezembro/2016.                   Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Tratar linha do arquivo tipo de segmento Y-53


    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    
    vr_exc_reje   EXCEPTION;
    
    ------------------------------- CURSORES ---------------------------------   
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_rej_cdmotivo VARCHAR2(2);
    
  BEGIN
  
    -- verifica se possui permissão para pagamento divergente
    IF pr_rec_header.flgpgdiv = 0 THEN
      vr_rej_cdmotivo := 'B3';
      RAISE vr_exc_reje;
    END IF;
    
    -- verifica se contém o número permitido de parcelas
    IF pr_tab_linhas('NRQTPAG').numero <> 1 THEN
      vr_rej_cdmotivo := '99';
      RAISE vr_exc_reje;
    END IF;    
    
    -- verifica se o tipo de valor máixmo é do tipo Valor (percentual não é permitido)
    IF pr_tab_linhas('TPVLMAX').numero <> 2 THEN
      vr_rej_cdmotivo := '99';
      RAISE vr_exc_reje;
    END IF;        
    
    -- verifica se o tipo de valor mínimo é do tipo Valor (percentual não é permitido)
    IF pr_tab_linhas('TPVLMIN').numero <> 2 THEN
      vr_rej_cdmotivo := '99';
      RAISE vr_exc_reje;
    END IF;

    pr_rec_cobranca.inpagdiv := pr_tab_linhas('IDTPPAG').numero;
    pr_rec_cobranca.vlminimo := pr_tab_linhas('NRVLMIN').numero;
    
    -- verificar se os tipos 1, 2 e 3 esperados estão corretos
    IF pr_tab_linhas('IDTPPAG').numero NOT IN (1,2,3) THEN
      vr_rej_cdmotivo := 'B3';
      RAISE vr_exc_reje;
    END IF;
    
    -- ajustar os valores do layout febraban ao nossos valores esperados
    -- no campo crapcob.inpagdiv
    -- C078 => ('01' = Aceita qualquer valor, 
    --          ‘02’ = Entre o mínimo e o máximo,
    --          ‘03’ = Não aceita pagamento com o valor divergente)
    
    CASE pr_tab_linhas('IDTPPAG').numero 
      WHEN 3 THEN pr_rec_cobranca.inpagdiv := 0; -- não autoriza pagto divergente
      WHEN 2 THEN pr_rec_cobranca.inpagdiv := 1; -- aceita com valor minimo
      WHEN 1 THEN pr_rec_cobranca.inpagdiv := 2; -- aceita qualquer valor
    END CASE;
            
    IF pr_rec_header.flgpgdiv = 0 AND pr_rec_cobranca.inpagdiv IN (1,2) THEN
      vr_rej_cdmotivo := 'B3';
      RAISE vr_exc_reje;
    END IF;
    
    -- se o valor minimo for setado e nao aceitar pagto com valor minimo, recusar
    IF nvl(pr_rec_cobranca.vlminimo,0) > 0 AND pr_rec_cobranca.inpagdiv <> 1 THEN
      vr_rej_cdmotivo := 'B4';
      RAISE vr_exc_reje;
    END IF;           
    
    -- se aceitar pagto com valor minimo e valor minimo zero, recusar
    IF nvl(pr_rec_cobranca.vlminimo,0) = 0 AND pr_rec_cobranca.inpagdiv = 1 THEN
      vr_rej_cdmotivo := 'B4';
      RAISE vr_exc_reje;
    END IF;           
      
    pr_des_reto := 'OK';
    
  EXCEPTION 
    WHEN vr_exc_reje THEN
      -- Rejeitou a cobranca e nao deve continuar o processamento
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_rec_cobranca.nrdconta --> Numero da Conta
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
                               
      -- Quando ocorrer erro geral em procedures que processam os segmentos
      -- deve gerar as informacoes da cobranca em questao no arquivo proc_message.log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - COBR0006.pc_trata_segmento_y53_240_85 -->' ||
                                                    ' Coop: '      || pr_cdcooper ||
                                                    ' Conta: '     || pr_nrdconta ||
                                                    ' Remessa: '   || pr_rec_header.nrremass ||
                                                    ' Convenio: '  || pr_rec_header.nrcnvcob ||
                                                    ' Nosso Num.:' || pr_rec_cobranca.dsnosnum ||
                                                    ' - TRACE: '   || dbms_utility.format_error_backtrace || 
                                                    ' - '          || dbms_utility.format_error_stack);                               
                               
      pr_des_reto:= 'NOK';
      pr_rec_cobranca.flgrejei:= TRUE;  
      
    WHEN OTHERS THEN
      -- Erro geral no processamento - codigo 99
      vr_rej_cdmotivo := '99';
      -- Erro geral do processamento do segmento "Y-53"
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_rec_cobranca.nrdconta --> Numero da Conta
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
                                
      -- Quando ocorrer erro geral em procedures que processam os segmentos
      -- deve gerar as informacoes da cobranca em questao no arquivo proc_message.log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - COBR0006.pc_trata_segmento_y53_240_85 -->' ||
                                                    ' Coop: '      || pr_cdcooper ||
                                                    ' Conta: '     || pr_nrdconta ||
                                                    ' Remessa: '   || pr_rec_header.nrremass ||
                                                    ' Convenio: '  || pr_rec_header.nrcnvcob ||
                                                    ' Nosso Num.:' || pr_rec_cobranca.dsnosnum ||
                                                    ' - TRACE: '   || dbms_utility.format_error_backtrace || 
                                                    ' - '          || dbms_utility.format_error_stack);
      
      -- Ignora a cobranca
      pr_rec_cobranca.flgrejei:= TRUE;
      pr_des_reto:= 'NOK';
      
  END pc_trata_segmento_y53_240_85;



  --> Tratar linha do arquicvo Header do arquivo
  PROCEDURE pc_trata_header_arq_240_01 (pr_cdcooper    IN crapcop.cdcooper%TYPE,   --> Codigo da cooperativa
                                        pr_nrdconta    IN crapass.nrdconta%TYPE,   --> Numero da conta do cooperado
                                        pr_tab_linhas  IN gene0009.typ_tab_campos, --> Dados da linha
                                        pr_rec_header OUT typ_rec_header,          --> Dados do Header
                                        pr_cdcritic   OUT INTEGER,                 --> Codigo de critica
                                        pr_dscritic   OUT VARCHAR2,                --> Descricao da critica
                                        pr_des_reto   OUT VARCHAR2                 --> Retorno OK/NOK
                                        ) IS
                                   
  /* ............................................................................

       Programa: pc_trata_header_arq    
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrei - RKAM
       Data    : Marco/2016.                   Ultima atualizacao:  

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Tratar linha do arquicvo Header do arquivo

       Alteracoes:  
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    
    --> Codigo do Convenio
    CURSOR cr_crapcco (pr_cdcooper crapcco.cdcooper%TYPE,
                       pr_nrconven crapcco.nrconven%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT  crapcco.cddbanco
             ,crapcco.cdagenci
             ,crapcco.cdbccxlt
             ,crapcco.nrdolote
             ,crapcco.cdhistor
             ,crapcco.nrdctabb
             ,crapcco.nrconven
             ,crapcco.flgutceb
             ,crapcco.flgregis
             ,crapcco.rowid
        FROM crapcco
       WHERE crapcco.cdcooper = pr_cdcooper
         AND crapcco.cddbanco = 1
         AND crapcco.cdagenci = 1
         AND crapcco.nrdctabb = pr_nrdconta
         AND crapcco.nrconven = pr_nrconven;
    rw_crapcco cr_crapcco%ROWTYPE;
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_nrremass   NUMBER;
    vr_nrconven   NUMBER;
    
  BEGIN
    
    --> Numero da Remessa do Cooperado 
    vr_nrremass := pr_tab_linhas('NRSEQARQ').numero;   
    vr_nrconven := to_number(pr_tab_linhas('NRCONVEN').texto);
    
    --> Tipo de Registro
    IF pr_tab_linhas('TPREGIST').numero <> 0 THEN 
      vr_dscritic := gene0001.fn_busca_critica(468);
      RAISE vr_exc_erro;
    END IF;
    
    --> Codigo do Convenio
    OPEN cr_crapcco (pr_cdcooper => pr_cdcooper,
                     pr_nrconven => vr_nrconven,
                     pr_nrdconta => pr_tab_linhas('NRDCONTA').numero);
                     
    FETCH cr_crapcco INTO rw_crapcco;
    
    IF cr_crapcco%NOTFOUND THEN
      
      CLOSE cr_crapcco;
      
      vr_dscritic := gene0001.fn_busca_critica(563);
      RAISE vr_exc_erro;
      
    ELSE
      
      CLOSE cr_crapcco;
      
    END IF;    
    
    -- Carregar todas as informacoes do Header
    pr_rec_header.nrremass := vr_nrremass;
    pr_rec_header.cdbancbb := rw_crapcco.cddbanco;
    pr_rec_header.cdagenci := rw_crapcco.cdagenci;
    pr_rec_header.cdbccxlt := rw_crapcco.cdbccxlt;
    pr_rec_header.nrdolote := rw_crapcco.nrdolote;
    pr_rec_header.cdhistor := rw_crapcco.cdhistor;
    pr_rec_header.nrdctabb := rw_crapcco.nrdctabb;
    pr_rec_header.cdbandoc := rw_crapcco.cddbanco;
    pr_rec_header.nrcnvcob := rw_crapcco.nrconven;
    pr_rec_header.flgutceb := rw_crapcco.flgutceb;
    pr_rec_header.flgregis := rw_crapcco.flgregis;    
    
    pr_des_reto := 'OK';
    
  EXCEPTION  
    WHEN vr_exc_erro THEN      
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic; 
      pr_des_reto := 'NOK';
       
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao validar Header do arquivo: '||SQLERRM;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_reto := 'NOK';
      
  END pc_trata_header_arq_240_01;   
  
  --> Tratar linha do arquicvo Header do lote
  PROCEDURE pc_trata_header_lote_240_01(pr_cdcooper   IN crapcop.cdcooper%TYPE,   --> Codigo da cooperativa
                                        pr_nrdconta   IN crapass.nrdconta%TYPE,   --> Numero da conta do cooperado
                                        pr_nrconven   IN crapcco.nrconven%TYPE,   --> Numero do convenio
                                        pr_tab_linhas IN gene0009.typ_tab_campos, --> Dados da linha
                                        pr_cdcritic OUT INTEGER,                  --> Codigo de critica
                                        pr_dscritic OUT VARCHAR2,                 --> Descricao da critica
                                        pr_des_reto  OUT VARCHAR2                 --> Retorno OK/NOK
                                        ) IS
                                   
  /* ............................................................................

       Programa: pc_trata_header_lote_240_01    
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrei - RKAM
       Data    : Marco/2016.                   Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Tratar linha do arquicvo Header do lote

       Alteracoes: 
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

  BEGIN
    
    --> Tipo de Registro
    IF pr_tab_linhas('TPREGIST').numero <> 1 THEN 
      vr_dscritic := gene0001.fn_busca_critica(468);
      RAISE vr_exc_erro;
    END IF;
    
    pr_des_reto := 'OK';
    
  EXCEPTION  
    WHEN vr_exc_erro THEN      
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic; 
      pr_des_reto := 'NOK';
       
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao validar Header do lote: '||SQLERRM;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_reto := 'NOK';
      
  END pc_trata_header_lote_240_01;
  
  --> Tratar linha do arquivo tipo de registro P
  PROCEDURE pc_trata_segmento_p_240_01 (pr_cdcooper      IN crapcop.cdcooper%TYPE,   --> Codigo da cooperativa
                                        pr_nrdconta      IN crapass.nrdconta%TYPE,   --> Numero da conta do cooperado
                                        pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE,   --> Data de movimento
                                        pr_cdoperad      IN crapope.cdoperad%TYPE,   --> Operador
                                        pr_diasvcto      IN INTEGER,                 --> Dias de Vencimento
                                        pr_flgfirst      IN OUT BOOLEAN,             --> controle de primeiro registro
                                        pr_tab_linhas    IN gene0009.typ_tab_campos, --> Dados da linha
                                        pr_rec_header    IN typ_rec_header,          --> Dados do Header do Arquivo
                                        pr_qtdregis      IN OUT INTEGER,             --> contador de registro
                                        pr_qtdinstr      IN OUT INTEGER,             --> contador de instucoes
                                        pr_qtbloque      IN OUT INTEGER,             --> contador de boletos processados
                                        pr_vlrtotal      IN OUT NUMBER,              --> Valor total dos boletos
                                        pr_rec_cobranca  IN OUT NOCOPY typ_rec_cobranca,    --> Dados da Cobranca
                                        pr_tab_crapcob   IN OUT NOCOPY typ_tab_crapcob,     --> Tabela de Cobranca
                                        pr_tab_instrucao IN OUT NOCOPY typ_tab_instrucao,   --> Tabela de Instrucoes
                                        pr_tab_rejeitado IN OUT NOCOPY typ_tab_rejeitado,   --> Tabela de Rejeitados
                                        pr_tab_crawrej   IN OUT NOCOPY typ_tab_crawrej,     --> Tabela de Rejeitados
                                        pr_des_reto         OUT VARCHAR2             --> Retorno OK/NOK
                                        ) IS
                                   
  /* ............................................................................

       Programa: pc_trata_segmento_p_240_01
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrei - RKAM
       Data    : Marco/2016.                   Ultima atualizacao: 13/02/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Tratar linha do arquivo tipo de segmento P

       Alteracoes: 07/11/2016 - Ajustado a validacao de Data de Emissao, para que a 
                                quantidade de dias seja parametrizada. Sera alterado 
                                de 90 para 365 dias. (Douglas - Chamado 523329)
       
	               13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts).
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_reje   EXCEPTION;
    vr_exc_fim    EXCEPTION;
    vr_dscritic   VARCHAR2(4000);

    vr_rej_cdmotivo VARCHAR2(2);
    
  BEGIN
    
    IF pr_tab_linhas('CDMOVRE').numero = '01' THEN
      pr_qtdregis := pr_qtdregis + 1;
    ELSE
      pr_qtdinstr := pr_qtdinstr + 1;
    END IF;
    
    --> Cria o ultimo boleto ou gera instrucao apenas se nao tiver erros 
    IF pr_flgfirst AND NOT pr_rec_cobranca.flgrejei THEN
              
      vr_dscritic:= '';
      
      -- Armazenar o boleto para gravacao ao fim do arquivo
      pc_grava_boleto(pr_rec_cobranca => pr_rec_cobranca,
                      pr_qtbloque     => pr_qtbloque, 
                      pr_vlrtotal     => pr_vlrtotal,
                      pr_tab_crapcob  => pr_tab_crapcob,
                      pr_dscritic     => vr_dscritic);
                          
      -- Se ocorreu erro durante o armazenamento do boleto grava o erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        pc_grava_critica(pr_cdcooper => pr_rec_cobranca.cdcooper,
                         pr_nrdconta => pr_rec_cobranca.nrdconta,
                         pr_nrdocmto => pr_rec_cobranca.nrbloque,
                         pr_dscritic => vr_dscritic,
                         pr_tab_crawrej => pr_tab_crawrej);
      END IF;
       
    END IF;
    
    -- Inicializar
    pr_flgfirst := TRUE;    
    -- Zerar críticas
    vr_rej_cdmotivo := NULL;
    
    -- Inicializar uma nova cobranca
    pc_inicializa_cobranca(pr_cdcooper     => pr_cdcooper,      --> Cooperativa
                           pr_nrdconta     => pr_nrdconta,      --> Conta
                           pr_dtmvtolt     => pr_dtmvtolt,      --> Data de Movimento
                           pr_rec_header   => pr_rec_header,    --> Dados do Header do Arquivo
                           pr_rec_cobranca => pr_rec_cobranca); --> Cobranca
    
    -- Inicializar os valores do registro
    pr_rec_cobranca.dsnosnum := TRIM(pr_tab_linhas('DSNOSNUM').texto);
    pr_rec_cobranca.dsdoccop := TRIM(pr_tab_linhas('NRDOCMTO').texto);
    pr_rec_cobranca.dsusoemp := pr_tab_linhas('DSUSOEMP').texto;
    
    -- Carregar os valores necessarios para criar os rejeitados
    pr_rec_cobranca.vltitulo:= pr_tab_linhas('VLTITULO').numero;
    pr_rec_cobranca.dtvencto:= pr_tab_linhas('DTVENCTO').data;
    pr_rec_cobranca.dtemscob:= pr_tab_linhas('DTEMSCOB').data;
        
    -- Se existe a data de emissao
    IF pr_rec_cobranca.dtemscob > to_date('13/10/2049','dd/mm/RRRR') THEN

      COBR0006.pc_grava_critica(pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrdocmto => 999999,
                                pr_dscritic => 'Data de documento superior ao limite 13/10/2049',
                                pr_tab_crawrej => pr_tab_crawrej);
                                
    END IF;
    
    IF TRUNC(SYSDATE) - vr_qtd_emi_ret > pr_rec_cobranca.dtemscob THEN
    
      COBR0006.pc_grava_critica(pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrdocmto => 999999,
                                pr_dscritic => 'Data retroativa maior que ' || 
                                               to_char(vr_qtd_emi_ret) ||
                                               ' dias.',
                                pr_tab_crawrej => pr_tab_crawrej);
                                
    END IF;
    
    IF pr_rec_cobranca.dtvencto < TRUNC(SYSDATE)           OR 
       pr_rec_cobranca.dtvencto < pr_rec_cobranca.dtemscob THEN 
       
      COBR0006.pc_grava_critica(pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrdocmto => 999999,
                                pr_dscritic => 'Data de vencimento anterior a data de emissao',
                                pr_tab_crawrej => pr_tab_crawrej);
                                
    END IF;

    -- Formatar nosso numero com 17 posicoes para separa o numero da conta e o numero do boleto
    pr_rec_cobranca.dsnosnum := to_char(TRIM(pr_tab_linhas('DSNOSNUM').texto),'fm00000000000000000');
    
    -- Carregar os valores necessarios para criar os rejeitados
    pr_rec_cobranca.vltitulo:= pr_tab_linhas('VLTITULO').numero;
    pr_rec_cobranca.dtvencto:= pr_tab_linhas('DTVENCTO').data;
    pr_rec_cobranca.dtemscob:= pr_tab_linhas('DTEMSCOB').data; 
    
    
    IF pr_rec_header.flgutceb = 0 THEN
      
      pr_rec_cobranca.nrdconta := to_number(SUBSTR(pr_rec_cobranca.dsnosnum,1,8));
      pr_rec_cobranca.nrbloque := to_number(SUBSTR(pr_rec_cobranca.dsnosnum,9,9));
    
    ELSE
      
      pr_rec_cobranca.nrdconta := to_number(SUBSTR(pr_rec_cobranca.dsnosnum,8,4));
      pr_rec_cobranca.nrbloque := to_number(SUBSTR(pr_rec_cobranca.dsnosnum,12,6));
    
    
    END IF;
    
    pr_des_reto := 'OK';
  
  EXCEPTION 
    WHEN vr_exc_fim  THEN
      -- Fim da execucao devido a ocorrencia que nao necessita do 
      -- restante das validacoes do segmento "P"
      pr_des_reto:= 'OK';
      
    WHEN vr_exc_reje THEN
      -- Rejeitou a cobranca e nao deve continuar o processamento
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_rec_cobranca.nrdconta --> Numero da Conta
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
      
      pr_des_reto:= 'NOK';
      pr_rec_cobranca.flgrejei:= TRUE;
      
    WHEN OTHERS THEN
      -- Erro geral no processamento - codigo 99
      vr_rej_cdmotivo:= '99';
      -- Erro geral do processamento do segmento "P"
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_rec_cobranca.nrdconta --> Numero da Conta
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
                                
      -- Quando ocorrer erro geral em procedures que processam os segmentos
      -- deve gerar as informacoes da cobranca em questao no arquivo proc_message.log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - COBR0006 --> pc_trata_segmento_p_240_01' ||
                                                    ' Coop: '      || pr_cdcooper ||
                                                    ' Conta: '     || pr_nrdconta ||
                                                    ' Remessa: '   || pr_rec_header.nrremass ||
                                                    ' Convenio: '  || pr_rec_header.nrcnvcob ||
                                                    ' Nosso Num.:' || pr_rec_cobranca.dsnosnum ||
                                                    ' - TRACE: '   || dbms_utility.format_error_backtrace || 
                                                    ' - '          || dbms_utility.format_error_stack);
                                
      -- Ignora a cobranca
      pr_des_reto:= 'NOK';
      pr_rec_cobranca.flgrejei:= TRUE;
      
  END pc_trata_segmento_p_240_01;
  
  --> Tratar linha do arquivo tipo de registro Q
  PROCEDURE pc_trata_segmento_q_240_01 (pr_cdcooper      IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                       ,pr_nrdconta      IN crapass.nrdconta%TYPE   --> Numero da conta do cooperado
                                       ,pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE   --> Data de movimento
                                       ,pr_cdoperad      IN crapope.cdoperad%TYPE   --> Operador
                                       ,pr_tab_linhas    IN gene0009.typ_tab_campos --> Dados da linha
                                       ,pr_rec_header    IN typ_rec_header          --> Dados do Header do Arquivo
                                       ,pr_tab_crawrej   IN OUT NOCOPY typ_tab_crawrej     --> Tabela de rejeitados
                                       ,pr_rec_cobranca  IN OUT NOCOPY typ_rec_cobranca    --> Dados da Cobranca
                                       ,pr_tab_rejeitado IN OUT NOCOPY typ_tab_rejeitado   --> Tabela de Rejeitados
                                       ,pr_tab_sacado    IN OUT NOCOPY typ_tab_sacado      --> Tabela de Sacados
                                       ,pr_des_reto         OUT VARCHAR2            --> Retorno OK/NOK
                                        ) IS
                                   
  /* ............................................................................

       Programa: pc_trata_segmento_q_240_01
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrei - RKAM
       Data    : Marco/2016.                   Ultima atualizacao: 13/02/2017 

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Tratar linha do arquivo tipo de segmento Q

       Alteracoes: 13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 

                   08/11/2017 - Adicionar chamada para a função fn_remove_chr_especial que
                                remove o caractere invalido chr(160) (Douglas - Chamado 778480)
    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_reje   EXCEPTION;
    vr_exc_fim    EXCEPTION;
    vr_dscritic   VARCHAR2(4000);
    vr_nrdconta   crapass.nrdconta%TYPE;
    vr_nmprimtl   crapass.nmprimtl%TYPE;

    ------------------------------- CURSORES ---------------------------------    
    --> Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT ass.nrdconta,
           ass.nrcpfcgc,
           ass.inpessoa,
           ass.cdcooper,
           ass.nmprimtl
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --> Verifica se convenio esta Homologacao 
    CURSOR cr_crapceb (pr_cdcooper  crapceb.cdcooper%TYPE,
                       pr_nrconven  crapceb.nrconven%TYPE,
                       pr_nrcnvceb  crapceb.nrdconta%TYPE,
                       pr_flgutceb  crapcco.flgutceb%TYPE) IS
    SELECT *
      FROM crapceb
     WHERE crapceb.cdcooper = pr_cdcooper
       AND crapceb.nrconven = pr_nrconven
       AND crapceb.nrcnvceb = decode(pr_flgutceb,1,pr_nrcnvceb,crapceb.nrcnvceb)
       AND crapceb.nrdconta = decode(pr_flgutceb,0,pr_nrcnvceb,crapceb.nrdconta);    
    rw_crapceb cr_crapceb%ROWTYPE;  
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_rej_cdmotivo VARCHAR2(2);
    
  BEGIN

    --> Validacao de Comandos de Instrucao
    IF pr_rec_cobranca.cdocorre <> 1 THEN -- 01 - Remessa
      
      IF pr_rec_cobranca.cdocorre = 31 THEN  -- 31 - Outros dados
        
        -- Realiza as validações da instrucao
        pc_valida_exec_instrucao (pr_cdcooper   => pr_cdcooper,
                                  pr_nrdconta   => pr_nrdconta,
                                  pr_rec_header => pr_rec_header,
                                  pr_tab_linhas => pr_tab_linhas,
                                  pr_cdocorre   => pr_rec_cobranca.cdocorre,
                                  pr_tipocnab   => '240',
                                  pr_cdmotivo   => vr_rej_cdmotivo);
                                  

        IF TRIM(vr_rej_cdmotivo) IS NOT NULL THEN
          pc_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                            ,pr_nrdconta      => pr_nrdconta -- Enviar o pr_nrdconta ao inves do pr_rec_cobranca.nrdconta, pois quando o motivo eh 08 o campo pr_rec_cobranca.nrdconta eh gerado com valor errado
                            ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                            ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                            ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                            ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                            ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                            ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                            ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                            ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                            ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                            ,pr_cdoperad      => pr_cdoperad              --> Operador
                            ,pr_cdocorre      => 26                       --> Codigo da Ocorrencia
                            ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                            ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
        END IF;
      END IF;
      
      RAISE vr_exc_fim;
    END IF;

    -- Dados do sacado
    pr_rec_cobranca.nmdsacad := fn_remove_chr_especial(pr_texto => pr_tab_linhas('NMDSACAD').texto);
    pr_rec_cobranca.dsendsac := fn_remove_chr_especial(pr_texto => pr_tab_linhas('DSENDSAC').texto);
    pr_rec_cobranca.nmbaisac := fn_remove_chr_especial(pr_texto => pr_tab_linhas('NMBAISAC').texto);
    pr_rec_cobranca.nmcidsac := fn_remove_chr_especial(pr_texto => pr_tab_linhas('NMCIDSAC').texto);
    pr_rec_cobranca.cdufsaca := fn_remove_chr_especial(pr_texto => pr_tab_linhas('CDUFSACA').texto);
    
    --Busca conveio
    OPEN cr_crapceb(pr_cdcooper => pr_cdcooper
                   ,pr_nrconven => pr_rec_header.nrcnvcob
                   ,pr_nrcnvceb => pr_rec_cobranca.nrdconta
                   ,pr_flgutceb => pr_rec_header.flgutceb);
                             
    FETCH cr_crapceb INTO rw_crapceb;
            
    IF cr_crapceb%NOTFOUND      OR 
       rw_crapceb.insitceb <> 1 THEN
                
      CLOSE cr_crapceb;
              
      COBR0006.pc_grava_critica(pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrdocmto => pr_rec_cobranca.nrbloque,
                                pr_dscritic => gene0001.fn_busca_critica(563) || ' - CNV : ' ||
                                               TO_CHAR(pr_nrdconta),
                                pr_tab_crawrej => pr_tab_crawrej);
             
              
    ELSE
                
      CLOSE cr_crapceb; 
              
      pr_rec_cobranca.nrdconta := rw_crapceb.nrdconta;
              
    END IF;
      
    IF pr_rec_cobranca.nrdconta <> pr_nrdconta THEN
            
      COBR0006.pc_grava_critica(pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrdocmto => pr_rec_cobranca.nrbloque,
                                pr_dscritic => 'Nosso numero invalido : ' || to_char(pr_rec_cobranca.dsnosnum),
                                pr_tab_crawrej => pr_tab_crawrej);
          
    END IF;
            
    --> Buscar dados do associado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
                           
    FETCH cr_crapass INTO rw_crapass;
          
    IF cr_crapass%NOTFOUND THEN
            
      COBR0006.pc_grava_critica(pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrdocmto => pr_rec_cobranca.nrbloque,
                                pr_dscritic => gene0001.fn_busca_critica(9),
                                pr_tab_crawrej => pr_tab_crawrej);
            
    ELSE
            
      CLOSE cr_crapass;      
      
      vr_nmprimtl := rw_crapass.nmprimtl;
             
    END IF;      
    
    pr_rec_cobranca.cdtpinsc := nvl(pr_tab_linhas('INPESSOA').numero,0);
    pr_rec_cobranca.nrinssac := pr_tab_linhas('NRCPFCGC').numero;
    pr_rec_cobranca.nmdsacad := fn_remove_chr_especial(pr_texto => pr_tab_linhas('NMDSACAD').texto);
    pr_rec_cobranca.dsendsac := fn_remove_chr_especial(pr_texto => pr_tab_linhas('DSENDSAC').texto);
    pr_rec_cobranca.nmbaisac := fn_remove_chr_especial(pr_texto => pr_tab_linhas('NMBAISAC').texto);
    pr_rec_cobranca.nrcepsac := pr_tab_linhas('NRCEPSAC').numero;
    pr_rec_cobranca.nmcidsac := fn_remove_chr_especial(pr_texto => pr_tab_linhas('NMCIDSAC').texto);
    pr_rec_cobranca.cdufsaca := fn_remove_chr_especial(pr_texto => pr_tab_linhas('CDUFSACA').texto);
    pr_rec_cobranca.nmdavali := fn_remove_chr_especial(pr_texto => pr_tab_linhas('NMDAVALI').texto);
    pr_rec_cobranca.nrinsava := pr_tab_linhas('NRINSAVA').numero;
    pr_rec_cobranca.cdtpinav := nvl(pr_tab_linhas('CDTPINAV').numero,0);
    
    pc_grava_sacado( pr_cdoperad     => pr_cdoperad,     --> Operador
                     pr_rec_cobranca => pr_rec_cobranca, --> Dados da linha
                     pr_tab_sacado   => pr_tab_sacado,   --> Tabela de Instrucoes
                     pr_dscritic     => vr_dscritic);    --> Descricao do Erro
                        
    pr_des_reto := 'OK';
  
  EXCEPTION 
    WHEN vr_exc_fim  THEN
      
      pr_des_reto:= 'OK';  
      
    WHEN OTHERS THEN
      
      pr_des_reto:= 'NOK';
            
  END pc_trata_segmento_q_240_01;

  -- Procedure que prepara retorno para cooperado 
  PROCEDURE pc_prep_retorno_cooper_90 (pr_idregcob IN ROWID   --ROWID da cobranca
                                      ,pr_cdocorre IN INTEGER --Codigo Ocorrencia
                                      ,pr_cdmotivo IN VARCHAR --Descricao Motivo
                                      ,pr_vltarifa IN NUMBER  --Valor Tarifa
                                      ,pr_cdbcoctl IN crapcop.cdbcoctl%TYPE --Banco Centralizador
                                      ,pr_cdagectl IN crapcop.cdagectl%TYPE --Agencia Centralizadora
                                      ,pr_dtmvtolt IN DATE     --Data Movimento
                                      ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                      ,pr_nrremass IN INTEGER  --Numero Remessa
                                      ,pr_dtcatanu IN crapret.dtcatanu%TYPE DEFAULT null --Data de referencia a quitacao da divida.
                                      ,pr_cdcritic OUT INTEGER --Codigo Critica
                                      ,pr_dscritic OUT VARCHAR2) IS --Descricao Critica
    /* .........................................................................

      Programa : pc_prep_retorno_cooper_90       Antigo: b1wgen0090.p/prep-retorno-cooperado
      Sistema  : Cred
      Sigla    : COBR0006
      Autor    : Alisson C. Berrido - AMcom
      Data     : Julho/2013.                     Ultima atualizacao: 11/01/2016

      Dados referentes ao programa:

       Frequencia: Sempre que for chamado
       Objetivo  : Procedure que prepara retorno para cooperado

       Alterações
       28/04/2014 - Ajustes na busca da próxima sequencia de gravação (Marcos-Supero)

       24/07/2015 - Ajustar a gravação da crapret para utilizar o valor de
                    vr_nrremrtc e vr_nrremcre Douglas - Chamado 310678)

       10/09/2015 - Ajuste para passar o parâmetro correto ao buscar a sequence
                    da crapret
                    (Adriano).

       17/09/2015 - Ajustes melhoria performace no cursor cr_craprtc(Odirlei-AMcom)

       11/01/2016 - Procedure movida da package PAGA0001 para COBR0006
                    (Douglas - Importacao de Arquivos CNAB)

     .........................................................................*/
  BEGIN
    DECLARE
      --Selecionar retorno titulo cooperado
      CURSOR cr_craprtc (pr_cdcooper IN craprtc.cdcooper%type
                        ,pr_nrcnvcob IN craprtc.nrcnvcob%type
                        ,pr_nrdconta IN craprtc.nrdconta%type
                        ,pr_dtmvtolt IN craprtc.dtmvtolt%type
                        ,pr_intipmvt IN craprtc.intipmvt%TYPE
                        ,pr_tipo     IN INTEGER) IS
        SELECT /*+ INDEX_DESC (craprtc CRAPRTC##CRAPRTC1) */
              craprtc.nrremret
        FROM craprtc
        WHERE craprtc.cdcooper = pr_cdcooper
        AND   craprtc.nrcnvcob = pr_nrcnvcob
        AND   craprtc.nrdconta = pr_nrdconta
        AND   ((pr_tipo = 1 AND craprtc.dtmvtolt = pr_dtmvtolt) OR pr_tipo = 2)
        AND   craprtc.intipmvt = pr_intipmvt
        --ORDER BY craprtc.progress_recid DESC substituido para hint semelhante ao progress
        -- para ganho de performace - Odirlei
        ;
      rw_craprtc cr_craprtc%ROWTYPE;
      -- Selecionar controle retorno titulos bancarios
      CURSOR cr_crapcre (pr_cdcooper IN crapcre.cdcooper%type
                        ,pr_nrcnvcob IN crapcre.nrcnvcob%type
                        ,pr_dtmvtolt IN crapcre.dtmvtolt%type
                        ,pr_nrremret IN crapcre.nrremret%type
                        ,pr_intipmvt IN crapcre.intipmvt%type
                        ,pr_tipo     IN INTEGER) IS
        SELECT crapcre.nrremret
        FROM crapcre
        WHERE crapcre.cdcooper = pr_cdcooper
        AND   crapcre.nrcnvcob = pr_nrcnvcob
        AND   ((pr_tipo = 1 AND crapcre.dtmvtolt = pr_dtmvtolt) OR
                pr_tipo = 2 OR
               (pr_tipo = 3 and crapcre.nrremret > pr_nrremret))
        AND   crapcre.intipmvt = pr_intipmvt
        ORDER BY crapcre.progress_recid DESC;
      rw_crapcre cr_crapcre%ROWTYPE;
      
      --Selecionar registro cobranca
      CURSOR cr_crapcob (pr_rowid IN ROWID) IS
        SELECT  crapcob.cdcooper
               ,crapcob.nrdconta
               ,crapcob.cdbandoc
               ,crapcob.nrdctabb
               ,crapcob.nrcnvcob
               ,crapcob.nrdocmto
               ,crapcob.flgregis
               ,crapcob.flgcbdda
               ,crapcob.insitpro
               ,crapcob.nrnosnum
               ,crapcob.vltitulo
               ,crapcob.incobran
               ,crapcob.dtvencto
               ,crapcob.dsdoccop
               ,crapcob.vlabatim
               ,crapcob.vldescto
               ,crapcob.flgdprot
               ,crapcob.idopeleg
               ,crapcob.insitcrt
               ,crapcob.cdagepag
               ,crapcob.cdbanpag
               ,crapcob.cdtitprt
               ,crapcob.dtdbaixa
               ,crapcob.nrctremp
               ,crapcob.rowid
        FROM crapcob
        WHERE crapcob.ROWID = pr_rowid;
      rw_crapcob cr_crapcob%ROWTYPE;


      --Variaveis Locais
      vr_nmarquiv VARCHAR2(100);
      vr_nmarqcre VARCHAR2(100);
      vr_nrremrtc INTEGER;
      vr_nrremcre INTEGER;
      vr_nrseqreg INTEGER;
      vr_vltarifa NUMBER;
      --Variaveis Retorno Tarifa
      vr_tar_cdhistor INTEGER;
      vr_tar_cdhisest INTEGER;
      vr_tar_vltarifa NUMBER;
      vr_tar_dtdivulg DATE;
      vr_tar_dtvigenc DATE;
      vr_tar_cdfvlcop INTEGER;
      --Tabela de Erro
      vr_tab_erro GENE0001.typ_tab_erro;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Selecionar registro cobranca
      OPEN cr_crapcob (pr_rowid => pr_idregcob);
      --Posicionar no proximo registro
      FETCH cr_crapcob INTO rw_crapcob;
      --Se nao encontrar
      IF cr_crapcob%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcob;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcob;
      /* Em caso de Entrada Rejeitada ou Instrucao Rejeitada Zera Valor Tarifa */
      IF pr_cdocorre IN (03,26) THEN
        vr_vltarifa:= 0;
      ELSE
        --Buscar valor tarifa
        TARI0001.pc_busca_dados_tarifa (pr_cdcooper  => rw_crapcob.cdcooper    --Codigo Cooperativa
                                       ,pr_nrdconta  => rw_crapcob.nrdconta    --Codigo da Conta
                                       ,pr_nrconven  => rw_crapcob.nrcnvcob    --Numero Convenio
                                       ,pr_dsincide  => 'RET'                  --Descricao Incidencia
                                       ,pr_cdocorre  => pr_cdocorre            --Codigo Ocorrencia
                                       ,pr_cdmotivo  => pr_cdmotivo                      --Codigo Motivo
                                       ,pr_idtabcob  => pr_idregcob            --Tipo Pessoa
                                       ,pr_cdhistor  => vr_tar_cdhistor        --Codigo Historico
                                       ,pr_cdhisest  => vr_tar_cdhisest        --Historico Estorno
                                       ,pr_vltarifa  => vr_tar_vltarifa        --Valor Tarifa
                                       ,pr_dtdivulg  => vr_tar_dtdivulg        --Data Divulgacao
                                       ,pr_dtvigenc  => vr_tar_dtvigenc        --Data Vigencia
                                       ,pr_cdfvlcop  => vr_tar_cdfvlcop        --Codigo Cooperativa
                                       ,pr_cdcritic  => vr_cdcritic            --Codigo Critica
                                       ,pr_dscritic  => vr_dscritic            --Descricao Critica
                                       ,pr_tab_erro  => vr_tab_erro); --Tabela erros
        --Se nao ocorreu erro
        IF NVL(vr_cdcritic,0) = 0 AND TRIM(vr_dscritic) IS NULL THEN
          /* Cobrar Tarifas Apenas Quando Instrucao */
          IF pr_cdocorre <> 2 THEN
            IF pr_vltarifa = 0 THEN
              vr_vltarifa:= vr_tar_vltarifa;
            ELSE
              vr_vltarifa:= pr_vltarifa;
            END IF;
          ELSE
            vr_vltarifa:= vr_tar_vltarifa;
          END IF;
        END IF;
      END IF;
      /*** Gerar tarifas Cooperado **/
      /*** somente se for comandado pelo cooperado ***/
      /* 9=Baixa '09'=Comandada pelo Banco 085 (temporario) */
      IF (pr_cdoperad = '1' OR pr_cdoperad = '0') AND
         (pr_cdocorre = 9 AND pr_cdmotivo = '09') AND
         (rw_crapcob.cdbandoc = 085) THEN
        vr_vltarifa:= 0;
      END IF;
      --Nome Arquivo
      vr_nmarquiv:= 'cobret'||to_char(pr_dtmvtolt,'MMDD');
      vr_nmarqcre:= 'ret085'||to_char(pr_dtmvtolt,'MMDD');

      /*** Localiza o ultimo RTC desta data ***/

      --Selecionar retorno titulo
      OPEN cr_craprtc (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_dtmvtolt => pr_dtmvtolt
                      ,pr_intipmvt => 2
                      ,pr_tipo     => 1);
      --Posicionar no proximo registro
      FETCH cr_craprtc INTO rw_craprtc;
      --Se nao encontrar
      IF cr_craprtc%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_craprtc;

        -- Utilizar a SEQUENCE para gerar o numero de remessa do cooperado
        vr_nrremrtc := fn_sequence(pr_nmtabela => 'CRAPRTC'
                                  ,pr_nmdcampo => 'NRREMRET'
                                  ,pr_dsdchave => rw_crapcob.cdcooper || ';' || 
                                                  rw_crapcob.nrdconta ||';' || 
                                                  rw_crapcob.nrcnvcob || ';2');

        --Criar retorno titulo cooperado
        BEGIN
          INSERT INTO craprtc
            (craprtc.cdcooper
            ,craprtc.nrdconta
            ,craprtc.nrcnvcob
            ,craprtc.dtmvtolt
            ,craprtc.nrremret
            ,craprtc.nmarquiv
            ,craprtc.flgproce
            ,craprtc.dtdenvio
            ,craprtc.qtreglot
            ,craprtc.cdoperad
            ,craprtc.dtaltera
            ,craprtc.hrtransa
            ,craprtc.intipmvt)
          VALUES
            (rw_crapcob.cdcooper
            ,rw_crapcob.nrdconta
            ,rw_crapcob.nrcnvcob
            ,pr_dtmvtolt
            ,vr_nrremrtc
            ,vr_nmarquiv
            ,0 --false
            ,NULL
            ,1
            ,pr_cdoperad
            ,pr_dtmvtolt
            ,gene0002.fn_busca_time
            ,2);
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao inserir na tabela craprtc. '||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      ELSE
        --Se encontrou, utiliza o que já existe - Numero remessa
        vr_nrremrtc:= rw_craprtc.nrremret;
      END IF;
      --Fechar Cursor
      IF cr_craprtc%ISOPEN THEN
        CLOSE cr_craprtc;
      END IF;

      --Selecionar Controle Remessa
      /* buscar o ultimo movimento de retorno do convenio do dia */
      OPEN cr_crapcre (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_dtmvtolt => pr_dtmvtolt
                      ,pr_nrremret => 0
                      ,pr_intipmvt => 2
                      ,pr_tipo     => 1);
      --Posicionar no proximo registro
      FETCH cr_crapcre INTO rw_crapcre;
      --Se nao encontrar
      IF cr_crapcre%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcre;
        /* tratamento especial para titulos cobranca com registro BB */
        IF rw_crapcob.cdbandoc = 1 THEN
          --Selecionar movimento retorno
          OPEN cr_crapcre (pr_cdcooper => rw_crapcob.cdcooper
                          ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_nrremret => 999999
                          ,pr_intipmvt => 2
                          ,pr_tipo     => 3);
          --Posicionar no proximo registro
          FETCH cr_crapcre INTO rw_crapcre;
          /* numeracao BB quando gerado pelo sistema, comecar
                   a partir de 999999 para nao confundir com o numero
                   de controle do arquivo de retorno BB */
          --Se nao encontrar
          IF cr_crapcre%NOTFOUND THEN
            --Numero remessa
            vr_nrremcre:= 999999;
          ELSE
            --Numero remessa
            vr_nrremcre:= rw_crapcre.nrremret + 1;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapcre;
        ELSE
          --Selecionar movimento retorno
          OPEN cr_crapcre (pr_cdcooper => rw_crapcob.cdcooper
                          ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_nrremret => 0
                          ,pr_intipmvt => 2
                          ,pr_tipo     => 2);
          --Posicionar no proximo registro
          FETCH cr_crapcre INTO rw_crapcre;
          --Se nao encontrar
          IF cr_crapcre%NOTFOUND THEN
            --Numero remessa
            vr_nrremcre:= 1;
          ELSE
            --Numero remessa
            vr_nrremcre:= rw_crapcre.nrremret + 1;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapcre;
        END IF;
        --Criar movimento retorno
        BEGIN
          INSERT INTO crapcre
            (crapcre.cdcooper
            ,crapcre.nrcnvcob
            ,crapcre.dtmvtolt
            ,crapcre.nrremret
            ,crapcre.intipmvt
            ,crapcre.nmarquiv
            ,crapcre.flgproce
            ,crapcre.cdoperad
            ,crapcre.dtaltera
            ,crapcre.hrtranfi)
          VALUES
            (rw_crapcob.cdcooper
            ,rw_crapcob.nrcnvcob
            ,pr_dtmvtolt
            ,vr_nrremcre
            ,2 /* retorno */
            ,vr_nmarqcre
            ,1 --TRUE
            ,pr_cdoperad
            ,pr_dtmvtolt
            ,gene0002.fn_busca_time);
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao inserir na tabela crapcre. '||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      ELSE
        --Se encontrou, utiliza o que já existe - Numero remessa
        vr_nrremcre:= rw_crapcre.nrremret;
      END IF;
      IF cr_crapcre%ISOPEN THEN
        --Fechar Cursor
        CLOSE cr_crapcre;
      END IF;
      /***** Localiza ultima sequencia *****/
      vr_nrseqreg := fn_sequence('CRAPRET','NRSEQREG', rw_crapcob.cdcooper||';'||
                                                       rw_crapcob.nrcnvcob||';'||
                                                       vr_nrremcre);
      --Criar movimento retorno titulos bancarios
      BEGIN
        INSERT INTO crapret
          (crapret.cdcooper
          ,crapret.nrcnvcob
          ,crapret.nrdconta
          ,crapret.nrdocmto
          ,crapret.nrretcoo
          ,crapret.nrremret
          ,crapret.nrseqreg
          ,crapret.cdocorre
          ,crapret.cdmotivo
          ,crapret.vltitulo
          ,crapret.vlabatim
          ,crapret.vldescto
          ,crapret.vltarass
          ,crapret.cdbcorec
          ,crapret.cdagerec
          ,crapret.dtocorre
          ,crapret.cdoperad
          ,crapret.dtaltera
          ,crapret.hrtransa
          ,crapret.nrnosnum
          ,crapret.dsdoccop
          ,crapret.nrremass
          ,crapret.dtvencto
          ,crapret.dtcatanu)
        VALUES
          (rw_crapcob.cdcooper
          ,rw_crapcob.nrcnvcob
          ,rw_crapcob.nrdconta
          ,rw_crapcob.nrdocmto
          ,vr_nrremrtc          /* Ultimo da RTC */
          ,vr_nrremcre          /* Ultimo da CRE */
          ,vr_nrseqreg          /* Ultimo da RET */
          ,pr_cdocorre
          ,nvl(pr_cdmotivo,' ')
          ,rw_crapcob.vltitulo
          ,rw_crapcob.vlabatim
          ,rw_crapcob.vldescto
          ,vr_vltarifa
          ,pr_cdbcoctl
          ,pr_cdagectl
          ,pr_dtmvtolt
          ,pr_cdoperad
          ,pr_dtmvtolt
          ,gene0002.fn_busca_time
          ,rw_crapcob.nrnosnum
          ,rw_crapcob.dsdoccop
          ,pr_nrremass
          ,rw_crapcob.dtvencto
          ,pr_dtcatanu);
      EXCEPTION
        WHEN Others THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao inserir na tabela crapret. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina COBR0006.pc_prep_retorno_cooper_90. '||sqlerrm;
    END;
  END pc_prep_retorno_cooper_90;

  --> Tratar linha do arquicvo Header do arquivo
  PROCEDURE pc_trata_header_arq_cnab400 (pr_cdcooper    IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                        ,pr_nrdconta    IN crapass.nrdconta%TYPE   --> Numero da conta do cooperado
                                        ,pr_cdagectl    in crapcop.cdagectl%TYPE   --> Codigo da agencia da central
                                        ,pr_tab_linhas  IN gene0009.typ_tab_campos --> Dados da linha
                                        ,pr_rec_header OUT typ_rec_header          --> Dados do Header
                                        ,pr_cdcritic   OUT INTEGER                 --> Codigo de critica
                                        ,pr_dscritic   OUT VARCHAR2                --> Descricao da critica
                                        ,pr_des_reto   OUT VARCHAR2) IS            --> Retorno OK/NOK
                                           
  /* ............................................................................

       Programa: pc_trata_header_arq_cnab400    
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrei - RKAM
       Data    : Marco/2016.                   Ultima atualizacao: 22/12/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Tratar linha do arquicvo Header do arquivo

       Alteracoes: 22/12/2017 - Carregar o CPF/CNPJ do titular da conta (Douglas - Chamado 819777)
    ............................................................................ */   
    
    ------------------------------- CURSORES ---------------------------------    
    --> Verifica se convenio esta Homologacao 
    CURSOR cr_crapceb (pr_cdcooper  crapceb.cdcooper%TYPE,
                       pr_nrconven  crapceb.nrconven%TYPE,
                       pr_nrdconta  crapceb.nrdconta%TYPE) IS
      SELECT *
        FROM crapceb
       WHERE crapceb.cdcooper = pr_cdcooper
         AND crapceb.nrconven = pr_nrconven
         AND crapceb.nrdconta = pr_nrdconta
         AND crapceb.insitceb = 1;    
    rw_crapceb cr_crapceb%ROWTYPE;  
    
    --> Codigo do Convenio
    CURSOR cr_crapcco (pr_cdcooper crapcco.cdcooper%TYPE,
                       pr_nrconven crapcco.nrconven%TYPE) IS
      SELECT  crapcco.cddbanco
             ,crapcco.cdagenci
             ,crapcco.cdbccxlt
             ,crapcco.nrdolote
             ,crapcco.cdhistor
             ,crapcco.nrdctabb
             ,crapcco.nrconven
             ,crapcco.flgutceb
             ,crapcco.flgregis
             ,crapcco.rowid
        FROM crapcco
       WHERE crapcco.cdcooper = pr_cdcooper
         AND crapcco.cddbanco = 085
         AND crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE'
         AND crapcco.nrconven = pr_nrconven;
    rw_crapcco cr_crapcco%ROWTYPE;
    
    --> Buscar ultimo arquivo processaso
    CURSOR cr_craprtc (pr_cdcooper  craprtc.cdcooper%TYPE,
                       pr_nrconven  craprtc.nrcnvcob%TYPE,
                       pr_nrdconta  craprtc.nrdconta%TYPE)IS
      SELECT /*+indesx_desc (craprtc CRAPRTC##CRAPRTC1)*/
             craprtc.nrremret
        FROM craprtc
       WHERE craprtc.cdcooper = pr_cdcooper
         AND craprtc.nrdconta = pr_nrdconta
         AND craprtc.nrcnvcob = pr_nrconven
         AND craprtc.intipmvt = 1 /* Remessa */
       ORDER BY craprtc.progress_recid DESC;         
    rw_craprtc cr_craprtc%ROWTYPE;
    
         
    ------------------------ VARIAVEIS  ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    
    vr_nrremass   NUMBER;
    vr_nrconven   NUMBER;
    
  BEGIN
    
    --> Numero da Remessa do Cooperado 
    vr_nrremass := pr_tab_linhas('NRSEQREM').numero;    
    vr_nrconven := to_number(pr_tab_linhas('NRCONVEN').numero);
        
    --> Verifica se convenio esta Homologacao 
    OPEN cr_crapceb (pr_cdcooper  => pr_cdcooper
                    ,pr_nrconven  => vr_nrconven
                    ,pr_nrdconta  => pr_nrdconta);
                     
    FETCH cr_crapceb INTO rw_crapceb;
    
    IF cr_crapceb%FOUND THEN
      
      CLOSE cr_crapceb;
      
      IF rw_crapceb.flgcebhm = 0 THEN        
        
        vr_dscritic := 'Convenio Nao Homologado - Entre em contato com seu Posto de Atendimento.';
        RAISE vr_exc_erro;
      
      END IF;
      
    ELSE
      CLOSE cr_crapceb;
        
    END IF;
    
    --> 01.0 Tipo de Registro
    IF pr_tab_linhas('TPREGIST').numero <> 0 THEN 

      vr_cdcritic := 468;  
      vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);    
      RAISE vr_exc_erro;

    END IF;
    
    --> 02.0 Tipo de Operacao
    IF pr_tab_linhas('TPOPERAC').numero <> 1 THEN 

      vr_cdcritic := 0;
      vr_dscritic := 'Tipo de Operacao Invalida.';
      RAISE vr_exc_erro;

    END IF;
    
    --> 03.0 Identificacao por extenso do Tipo de Operacao
    IF pr_tab_linhas('DSTPOPER').texto <> 'REMESSA' THEN 

      vr_cdcritic := 0;
      vr_dscritic := 'Identificacao do Tipo de Operacao Invalida.';
      RAISE vr_exc_erro;

    END IF;
    
    --> 04.0 Tipo de Servico
    IF pr_tab_linhas('TPSERVIC').numero <> 1 THEN 

      vr_cdcritic := 0;
      vr_dscritic := 'Tipo de Servico Invalida.';
      RAISE vr_exc_erro;

    END IF;
    
    --> 05.0 Identificacao por extenso do Tipo de Servico
    IF pr_tab_linhas('DSTPSERV').texto <> 'COBRANCA' THEN 

      vr_cdcritic := 0;
      vr_dscritic := 'Identificacao do Tipo de Servico Invalida.';
      RAISE vr_exc_erro;

    END IF;
    
    --> 07.0 a 08.0 Agencia/DV
    IF pr_cdagectl <> pr_tab_linhas('PREFAGCE').numero THEN 

      vr_cdcritic := 0;
      vr_dscritic := 'Agencia/DV header Invalida.';
      RAISE vr_exc_erro;

    END IF;
    
    --> Buscar dados do associado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
                     
    FETCH cr_crapass INTO rw_crapass;
    
    IF cr_crapass%NOTFOUND THEN
      
      CLOSE cr_crapass;
      
      vr_dscritic := 'Conta/DV header Invalida.';
      RAISE vr_exc_erro;
      
    ELSE
      
      CLOSE cr_crapass;      
       
    END IF;
    
    --> 13.0 Fixo "085"
    IF substr(pr_tab_linhas('DSCEDENT').texto,1,3) <> '085' THEN
      vr_dscritic := 'Identificacao HEADER Invalida.';
      RAISE vr_exc_erro;
    END IF;
    
    --> 14.0 Data de Gravacao do Arquivo
    IF ( pr_tab_linhas('DTDGRAVA').data > SYSDATE )         OR
       ( pr_tab_linhas('DTDGRAVA').data < ( SYSDATE - 30 )) THEN
      vr_dscritic := 'Data de Gravacao do Arquivo fora do Periodo Permitido.';
      RAISE vr_exc_erro;
    END IF;
    
    IF vr_nrremass = 0 THEN
      vr_dscritic := 'Numero da Remessa Invalida.';
      RAISE vr_exc_erro;
    END IF; 
    
    --> 15.0 Sequencial da Remessa
    --> Buscar ultimo arquivo processado
    OPEN cr_craprtc (pr_cdcooper  => rw_crapass.cdcooper
                    ,pr_nrconven  => vr_nrconven
                    ,pr_nrdconta  => rw_crapass.nrdconta);
                     
    FETCH cr_craprtc INTO rw_craprtc;
    
    IF cr_craprtc%FOUND THEN
      
      CLOSE cr_craprtc;
      
      --> Verificacao do numero de remessa que esta sendo processado eh igual ao ultimo processado */
      IF rw_craprtc.nrremret = vr_nrremass THEN
        
        vr_dscritic := 'Arquivo ja processado';
        RAISE vr_exc_erro;
        
      ELSIF rw_craprtc.nrremret > vr_nrremass THEN
        
        vr_dscritic := 'Numero de remessa inferior ao ultimo arquivo processado.';
        RAISE vr_exc_erro;
                  
      END IF;
      
    END IF;
    
    IF cr_craprtc%ISOPEN THEN
      CLOSE cr_craprtc;
    END IF; 
    
    --> Codigo do Convenio
    OPEN cr_crapcco (pr_cdcooper => pr_cdcooper
                    ,pr_nrconven => vr_nrconven );
                     
    FETCH cr_crapcco INTO rw_crapcco;
    
    IF cr_crapcco%NOTFOUND THEN
      
      CLOSE cr_crapcco;
      vr_dscritic := 'Convenio nao Encontrado.';
      
      RAISE vr_exc_erro;
      
    ELSE
      CLOSE cr_crapcco;
      
      --> Verifica se convenio esta Homologacao 
      OPEN cr_crapceb (pr_cdcooper  => pr_cdcooper
                      ,pr_nrconven  => vr_nrconven
                      ,pr_nrdconta  => pr_nrdconta);
                       
      FETCH cr_crapceb INTO rw_crapceb;
      
      IF cr_crapceb%NOTFOUND THEN
        
        CLOSE cr_crapceb;
              
        vr_dscritic := 'Convenio nao Habilitado.';
        RAISE vr_exc_erro;
                
      ELSE
        CLOSE cr_crapceb;
          
      END IF;
      
    END IF;
    
    -- Carregar todas as informacoes do Header
    pr_rec_header.nrremass := vr_nrremass;
    pr_rec_header.cdbancbb := rw_crapcco.cddbanco;
    pr_rec_header.cdagenci := rw_crapcco.cdagenci;
    pr_rec_header.cdbccxlt := rw_crapcco.cdbccxlt;
    pr_rec_header.nrdolote := rw_crapcco.nrdolote;
    pr_rec_header.cdhistor := rw_crapcco.cdhistor;
    pr_rec_header.nrdctabb := rw_crapcco.nrdctabb;
    pr_rec_header.cdbandoc := rw_crapcco.cddbanco;
    pr_rec_header.nrcnvcob := rw_crapcco.nrconven;
    pr_rec_header.flgutceb := rw_crapcco.flgutceb;
    pr_rec_header.flgregis := rw_crapcco.flgregis;
    pr_rec_header.flceeexp := rw_crapceb.flceeexp;
    pr_rec_header.inpessoa := rw_crapass.inpessoa;
    pr_rec_header.nrcpfcgc := rw_crapass.nrcpfcgc;
    
    --> 19.0 Sequencial Fixo "000001"
    IF pr_tab_linhas('NRSEQREG').numero <> 1 THEN
      vr_dscritic := 'Sequencial do Registro Header 000001 Invalida.';
      RAISE vr_exc_erro;
    END IF;
    
    pr_des_reto := 'OK';
    
  EXCEPTION  
    WHEN vr_exc_erro THEN      
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic; 
      pr_des_reto := 'NOK';
       
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao validar Header do arquivo: '||SQLERRM;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_reto := 'NOK';
      
  END pc_trata_header_arq_cnab400;   
  
  --> Tratar linha do arquivo do tipo detalhe
  PROCEDURE pc_trata_detalhe_cnab400 (pr_cdcooper      IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                     ,pr_nrdconta      IN crapass.nrdconta%TYPE   --> Numero da conta do cooperado
                                     ,pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE   --> Data de movimento
                                     ,pr_cdoperad      IN crapope.cdoperad%TYPE   --> Operador
                                     ,pr_diasvcto      IN INTEGER                 --> Dias de Vencimento
                                     ,pr_flgfirst      IN OUT BOOLEAN             --> controle de primeiro registro
                                     ,pr_tab_linhas    IN gene0009.typ_tab_campos --> Dados da linha
                                     ,pr_rec_header    IN typ_rec_header          --> Dados do Header do Arquivo
                                     ,pr_qtdregis      IN OUT INTEGER             --> contador de registro
                                     ,pr_qtdinstr      IN OUT INTEGER             --> contador de instucoes
                                     ,pr_qtbloque      IN OUT INTEGER             --> contador de boletos processados
                                     ,pr_vlrtotal      IN OUT NUMBER              --> Valor total dos boletos
                                     ,pr_rec_cobranca  IN OUT NOCOPY typ_rec_cobranca    --> Dados da Cobranca
                                     ,pr_tab_crapcob   IN OUT NOCOPY typ_tab_crapcob     --> Tabela de Cobranca
                                     ,pr_tab_instrucao IN OUT NOCOPY typ_tab_instrucao   --> Tabela de Instrucoes
                                     ,pr_tab_rejeitado IN OUT NOCOPY typ_tab_rejeitado   --> Tabela de Rejeitados
                                     ,pr_tab_sacado    IN OUT NOCOPY typ_tab_sacado      --> Tabela de Sacados                                  
                                     ,pr_tab_crawrej   IN OUT NOCOPY typ_tab_crawrej     --> Tabela de Rejeitados
                                     ,pr_des_reto      OUT VARCHAR2)IS            --> Retorno OK/NOK
                                         
  /* ............................................................................

       Programa: pc_trata_detalhe_cnab400
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrei - RKAM
       Data    : Marco/2016.                   Ultima atualizacao: 15/01/2018

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Tratar linha de detalhe do arquivo cnab400

       Alteracoes: 27/05/2016 - Ajuste para considerar o caracter ":" ao chamar
								a rotina de validação de caracteres para endereços
								(Andrei). 
                                
                   07/11/2016 - Ajustado a validacao de Data de Emissao, para que a 
                                quantidade de dias seja parametrizada. Sera alterado 
                                de 90 para 365 dias. (Douglas - Chamado 523329)

                   23/12/2016 - Validar nulo no valor do título. (AJFink - SD#581070)

                   27/01/2017 - Incluir atribuição do flgdprot quando houver
                                instrução de protesto. (AJFink - SD#586758)

				   13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts).
                                
                   17/03/2017 - Removido a validação que verificava se o CEP do pagador do boleto existe no Ayllos. 
                                Solicitado pelo Leomir e aprovado pelo Victor (cobrança)
                               (Douglas - Chamado 601436)
                               
                   26/10/2017 - Validar CPF e CNPJ de acordo com o tipo de inscricao (Rafael)                               

                   08/11/2017 - Adicionar chamada para a função fn_remove_chr_especial que
                                remove o caractere invalido chr(160) (Douglas - Chamado 778480)

                   22/12/2017 - Validar se o CPF/CNPJ do pagador é o mesmo do titular da conta
                                e rejeitar com o motivo '46' (Douglas - Chamado 819777)

                   15/01/2018 - Ajustar para quando o cooperado informar o valor de desconto
                                o cdmensag seja gravado com 1 (Vencimento até o desconto)
                                (Douglas - Chamado 831413)
    ............................................................................ */   
    
    --> Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_nrCPFCGC crapass.NRCPFCGC%TYPE) IS
      SELECT ass.nrdconta,
             ass.nrcpfcgc,
             ass.inpessoa,
             ass.cdcooper
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta
         AND ass.nrcpfcgc = pr_nrcpfcgc;
    rw_crapass cr_crapass%ROWTYPE;
    
    --> seleciona os uf não permitidor para protestar
    CURSOR cr_dsnegufds(pr_cdcooper crapsab.cdcooper%TYPE) IS
      SELECT p.dsnegufds
        FROM tbcobran_param_protesto p
       WHERE p.cdcooper = pr_cdcooper;
    
    ------------------------ VARIAVEIS  ----------------------------
    -- Tratamento de erros
    vr_exc_reje   EXCEPTION;
    vr_exc_fim    EXCEPTION;
    vr_dscritic   VARCHAR2(4000);
    vr_stsnrcal   BOOLEAN;
    vr_inpessoa   INTEGER;
	vr_limitemin  INTEGER;
    vr_limitemax  INTEGER;
    vr_rej_cdmotivo VARCHAR2(2);
    vr_dsnegufds tbcobran_param_protesto.dsnegufds%TYPE;
    
	vr_des_erro  VARCHAR2(255);
    
  BEGIN
    
    IF pr_tab_linhas('TPCOMAND').numero = '01' THEN
      pr_qtdregis := pr_qtdregis + 1;
    ELSE
      pr_qtdinstr := pr_qtdinstr + 1;
    END IF;
    
    --> Cria o ultimo boleto ou gera instrucao apenas se nao tiver erros 
    IF pr_flgfirst AND NOT pr_rec_cobranca.flgrejei THEN
       
       --> 01 - Solicitacao de Remessa 
       IF pr_rec_cobranca.cdocorre = 1 THEN
         
         vr_dscritic:= '';
         
         -- Armazenar o boleto para gravacao ao fim do arquivo
         pc_grava_boleto(pr_rec_cobranca => pr_rec_cobranca
                        ,pr_qtbloque     => pr_qtbloque
                        ,pr_vlrtotal     => pr_vlrtotal
                        ,pr_tab_crapcob  => pr_tab_crapcob
                        ,pr_dscritic     => vr_dscritic);
                         
         -- Se ocorreu erro durante o armazenamento do boleto grava o erro
         IF TRIM(vr_dscritic) IS NOT NULL THEN
           pc_grava_critica(pr_cdcooper => pr_rec_cobranca.cdcooper
                           ,pr_nrdconta => pr_rec_cobranca.nrdconta
                           ,pr_nrdocmto => pr_rec_cobranca.nrbloque
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_crawrej => pr_tab_crawrej);
         END IF;
       ELSE
         
         vr_dscritic:= '';
         
         -- Armazenar a instrucao para gravacao ao fim do arquivo
         pc_grava_instrucao(pr_rec_cobranca  => pr_rec_cobranca
                           ,pr_tab_instrucao => pr_tab_instrucao
                           ,pr_dscritic      => vr_dscritic);  
                            
         -- Se ocorreu erro durante o armazenamento da instrucao grava o erro
         IF TRIM(vr_dscritic) IS NOT NULL THEN
           pc_grava_critica(pr_cdcooper => pr_rec_cobranca.cdcooper
                           ,pr_nrdconta => pr_rec_cobranca.nrdconta
                           ,pr_nrdocmto => pr_rec_cobranca.nrbloque
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_crawrej => pr_tab_crawrej);
                            
         END IF;
         
       END IF;   
           
    END IF;
    
    -- Inicializar
    pr_flgfirst := TRUE;   
     
    -- Zerar críticas
    vr_rej_cdmotivo := NULL;
    
    -- Inicializar uma nova cobranca
    pc_inicializa_cobranca(pr_cdcooper     => pr_cdcooper       --> Cooperativa
                          ,pr_nrdconta     => pr_nrdconta       --> Conta
                          ,pr_dtmvtolt     => pr_dtmvtolt       --> Data de Movimento
                          ,pr_rec_header   => pr_rec_header     --> Dados do Header do Arquivo
                          ,pr_rec_cobranca => pr_rec_cobranca); --> Cobranca
    
    -- Inicializar os valores do registro
    pr_rec_cobranca.dsnosnum := TRIM(pr_tab_linhas('DSNOSNUM').texto);
    pr_rec_cobranca.dsdoccop := TRIM(pr_tab_linhas('NRDOCMTO').texto);
    pr_rec_cobranca.dsusoemp := pr_tab_linhas('DSUSOEMP').texto;
    pr_rec_cobranca.cdocorre := pr_tab_linhas('TPCOMAND').numero;
    
    --Registros de controle serasa
    pr_rec_cobranca.flserasa := 0;
    pr_rec_cobranca.qtdianeg := 0;
    pr_rec_cobranca.inserasa := 0;
    pr_rec_cobranca.serasa := 0;    
    
    -- Carregar os valores necessarios para criar os rejeitados
    pr_rec_cobranca.vltitulo:= pr_tab_linhas('VLTITULO').numero;
    pr_rec_cobranca.dtvencto:= pr_tab_linhas('DTVENCTO').data;
    pr_rec_cobranca.dtemscob:= pr_tab_linhas('DTEMSCOB').data;
    pr_rec_cobranca.instcodi:= pr_tab_linhas('INSTCODI').numero;
    pr_rec_cobranca.instcodi2:= pr_tab_linhas('INSTCODI2').numero;
    
    -- Formatar nosso numero com 17 posicoes para separa o numero da conta e o numero do boleto
    pr_rec_cobranca.dsnosnum := to_char(TRIM(pr_tab_linhas('DSNOSNUM').texto),'fm00000000000000000');
    pr_rec_cobranca.nrdconta := to_number(SUBSTR(pr_rec_cobranca.dsnosnum,1,8));
    pr_rec_cobranca.nrbloque := to_number(SUBSTR(pr_rec_cobranca.dsnosnum,9,9));

    --> tratar flag aceite enviada no arquivo motivo 23 - Aceite invalido, nao sera tratado
    --  para nao impactar nos cooperados que ignoravam essa informacao*/                   
    IF upper(pr_tab_linhas('ACEITITU').texto) = 'A' THEN
      pr_rec_cobranca.flgaceit := 1;
    ELSE
      pr_rec_cobranca.flgaceit := 0;
    END IF;  
    
    --21.7 Comandos
    IF pr_rec_cobranca.cdocorre NOT IN (1,2,4,5,6,9,10,12,31,32) THEN
    
      --> Codigo de Movimento Invalido
      vr_rej_cdmotivo := '05'; 
      RAISE vr_exc_reje;
    
    ELSIF pr_rec_cobranca.cdocorre = 31 THEN 
      
      --Conceder desconto
      pr_rec_cobranca.cdocorre := 7; 
      
    ELSIF pr_rec_cobranca.cdocorre = 32 THEN 
       
      --Nao conceder desconto
      pr_rec_cobranca.cdocorre := 8;
      
    ELSIF pr_rec_cobranca.cdocorre = 12 THEN 
        
      --Alteracao de nome e endereco
      pr_rec_cobranca.cdocorre := 31;
    
    END IF;
          
    --> Validacao de Comandos de Instrucao
    IF pr_rec_cobranca.cdocorre <> 1 THEN -- 01 - Remessa
      
      -- Realiza as validações da instrucao
      pc_valida_exec_instrucao (pr_cdcooper   => pr_cdcooper
                               ,pr_nrdconta   => pr_nrdconta
                               ,pr_rec_header => pr_rec_header
                               ,pr_tab_linhas => pr_tab_linhas
                               ,pr_cdocorre   => pr_rec_cobranca.cdocorre
                               ,pr_tipocnab   => '400'
                               ,pr_cdmotivo   => vr_rej_cdmotivo);
                                
      IF TRIM(vr_rej_cdmotivo) IS NOT NULL THEN
        pc_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                          ,pr_nrdconta      => pr_nrdconta -- Enviar o pr_nrdconta ao inves do pr_rec_cobranca.nrdconta, pois quando o motivo eh 08 o campo pr_rec_cobranca.nrdconta eh gerado com valor errado
                          ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                          ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                          ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                          ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                          ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                          ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                          ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                          ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                          ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                          ,pr_cdoperad      => pr_cdoperad              --> Operador
                          ,pr_cdocorre      => 26                       --> Codigo da Ocorrencia
                          ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                          ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados      
              
      END IF;
      
      RAISE vr_exc_fim;
      
    END IF;      
     
    -- 02.7 Tipo de Inscricao do Cedente
    IF pr_tab_linhas('TPINSCRI').numero <> 1 AND
       pr_tab_linhas('TPINSCRI').numero <> 2 THEN
        
      -- Tipo/Numero de Inscricao do Cedente Invalidos 
      vr_rej_cdmotivo := '06';
      RAISE vr_exc_reje;
      
    END IF;
  
    -- 03.7 Numero do CPF/CNPJ do Cedente 
    --> Buscar dados do associado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrcpfcgc => pr_tab_linhas('NRCPFCGC').numero);
                     
    FETCH cr_crapass INTO rw_crapass;
    
    IF cr_crapass%NOTFOUND THEN
      
      CLOSE cr_crapass;
      
      /* Tipo/Numero de Inscricao do Cedente Invalidos    */
      vr_rej_cdmotivo := '06';
      RAISE vr_exc_reje;
      
    ELSE
      
      CLOSE cr_crapass;    
      
      IF rw_crapass.inpessoa <> pr_tab_linhas('TPINSCRI').numero THEN
        
        /* Tipo/Numero de Inscricao do Cedente Invalidos    */
        vr_rej_cdmotivo := '06';
        RAISE vr_exc_reje;
      
      END IF;   
       
    END IF;
  
    -- 04.7 a 05.7 Agencia/DV
    IF pr_rec_header.cdagectl <> pr_tab_linhas('NRPREFAG').numero THEN
        
      -- Agencia/Conta/DV Invalido 
      vr_rej_cdmotivo := '07';
      RAISE vr_exc_reje;
      
    END IF;
  
    -- 06.7 a 07.7 Numero da Conta/DV
    IF pr_nrdconta <> pr_tab_linhas('NRDCONTA').numero THEN
        
      -- Agencia/Conta/DV Invalido 
      vr_rej_cdmotivo := '07';
      RAISE vr_exc_reje;
      
    END IF;
  
    -- 08.7 Numero do convenio de cobranca
    IF pr_rec_header.nrcnvcob <> pr_tab_linhas('NRCNVCED').numero THEN
        
      -- Numero de Contrato Invalido
      vr_rej_cdmotivo := '96';
      RAISE vr_exc_reje;
      
    END IF;
  
    -- Verificacao para impedir cadastro de titulo sem numero
    IF pr_rec_cobranca.nrbloque = 0 THEN
      
      -- Nosso Numero Invalido
      vr_rej_cdmotivo := '08';
      RAISE vr_exc_reje;
      
    END IF;
    
    -- 10.7 Nosso-Numero
    IF pr_nrdconta <> pr_rec_cobranca.nrdconta THEN
      
      -- Nosso Numero Invalido
      vr_rej_cdmotivo := '08';
      RAISE vr_exc_reje;
      
    END IF;
  
    IF pr_rec_cobranca.cdocorre = 01 THEN -- 01 - Remessa
      
      -- Verifica Existencia Titulo
      OPEN cr_crapcob(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_rec_cobranca.nrdconta
                     ,pr_cdbandoc => pr_rec_header.cdbandoc
                     ,pr_nrdctabb => pr_rec_header.nrdctabb
                     ,pr_nrcnvcob => pr_rec_header.nrcnvcob
                     ,pr_nrdocmto => pr_rec_cobranca.nrbloque);
                      
      FETCH cr_crapcob INTO rw_crapcob;
      
      -- Se nao encountrou a cobranca, gera erro
      IF cr_crapcob%FOUND THEN
        
        CLOSE cr_crapcob;
        
        -- Se o boleto possuir informacao de "LIQAPOSBX" e o cobranca
        -- nao entrou o boleto deve adicionado para ser processado
        IF NOT (rw_crapcob.dsinform LIKE 'LIQAPOSBX%' AND 
                rw_crapcob.incobran = 0)              THEN
                
          -- Nosso Numero Duplicado
          vr_rej_cdmotivo := '09';
          RAISE vr_exc_reje;
          
        END IF;
        
      ELSE
      
        CLOSE cr_crapcob;
        
      END IF;
      
    END IF;
  
    -- 20.7 Carteira
    IF pr_tab_linhas('CARCOBRA').numero <> 1 THEN --Cobranca Simples
        
      -- Carteira Invalida
      vr_rej_cdmotivo := '10';
      RAISE vr_exc_reje;
      
    END IF;
  
    -- 22.7 Seu numero
    IF pr_tab_linhas('CARCOBRA').numero <> 1 THEN --Cobranca Simples
        
      -- Carteira Invalida
      vr_rej_cdmotivo := '10';
      RAISE vr_exc_reje;
      
    END IF;
  
    IF fn_valida_caracteres(pr_flgnumer => TRUE   -- Validar Numeros
                           ,pr_flgletra => TRUE   -- Validar Letras
                           ,pr_listaesp => ''     -- Lista Caracteres Validos
                           ,pr_dsvalida => pr_rec_cobranca.dsdoccop ) THEN -- Documento
      
      -- Seu Numero Invalido
      vr_rej_cdmotivo := '86';
      RAISE vr_exc_reje;
      
    END IF;
  
    -- 23.7 Data de Vencimento
    IF pr_rec_cobranca.cdocorre = 01  OR    -- 01 - Remessa
       pr_rec_cobranca.cdocorre = 06  THEN  -- 06 - Alteracao Vencimento
        
      IF pr_rec_cobranca.dtvencto IS NOT NULL THEN        
          
        IF pr_rec_cobranca.dtvencto < TRUNC(SYSDATE) OR 
           pr_rec_cobranca.dtvencto > to_date('13/10/2049','dd/mm/RRRR')  THEN 
           
          -- Vencimento Fora do Prazo de Operacao
          vr_rej_cdmotivo := '18';
          RAISE vr_exc_reje;
          
        END IF;
      
      ELSE
        
        --Data de Vencimento Invalida
        vr_rej_cdmotivo := '16';
        RAISE vr_exc_reje;
          
      END IF;
      
    END IF;
  
    -- 24.7 Valor do titulo
    -- O valor do titulo sempre sera validado independente de ter gerado erro anteriormente
    IF nvl(pr_rec_cobranca.vltitulo,0) = 0 THEN --SD#581070
      
      -- Valor do Titulo Invalido
      vr_rej_cdmotivo := '20';
      RAISE vr_exc_reje;
      
    END IF;
    
    -- 25.7 Numero do Banco Fixo 085
    IF pr_tab_linhas('NRDBANCO').numero <> 85 THEN -- CECRED
      
      -- Codigo do Banco Invalido
      vr_rej_cdmotivo := '01';
      RAISE vr_exc_reje;
      
    END IF;
    
    -- 28.7 Especie do Titulo 
    pr_rec_cobranca.cddespec := pr_tab_linhas('ESPTITUL').numero;
    
    /* Tratar Especie do Titulo Febraban -> Cecred */
    IF pr_rec_cobranca.cddespec = '01' THEN /* Duplicata mercantil */
      pr_rec_cobranca.cddespec := '01';
    ELSIF pr_rec_cobranca.cddespec = '02' THEN /* Nota promissoria */
      pr_rec_cobranca.cddespec := '03';
    ELSIF pr_rec_cobranca.cddespec = 5 THEN /* Recibo */
      pr_rec_cobranca.cddespec := '06';
    ELSIF pr_rec_cobranca.cddespec = 12 THEN /* Duplicata de Servico */
      pr_rec_cobranca.cddespec := '02';    
    ELSE
      
      -- Especie do Titulo Invalido
      vr_rej_cdmotivo := '21';
      RAISE vr_exc_reje;
      
    END IF;
    
    -- 30.7 Data de Emissao
    IF pr_rec_cobranca.dtemscob IS NOT NULL THEN
      
      IF pr_rec_cobranca.dtemscob > to_date('13/10/2049','dd/mm/RRRR') OR
         TRUNC(SYSDATE) - vr_qtd_emi_ret > pr_rec_cobranca.dtemscob    THEN

        -- Data de documento superior ao limite 13/10/2049 ou
        -- Data retroativa maior que 90 dias.
        vr_rej_cdmotivo := '24';
        RAISE vr_exc_reje;
        
      END IF;
      
      IF pr_rec_cobranca.dtvencto < pr_rec_cobranca.dtemscob THEN
        
        -- Data de vencimento anterior a data de emissao
        vr_rej_cdmotivo := '17';
        RAISE vr_exc_reje;
        
      END IF;
      
    ELSE
      
      --Data da Emissao Invalida
      vr_rej_cdmotivo := '24';
      RAISE vr_exc_reje;
      
    END IF;
  
    -- 31.7 Instrucao Codificada 1 
    -- 32.7 Instrucao Codificada 2 
    --pr_rec_cobranca.cdprotes := pr_tab_linhas('CDDPROTE').numero;
    
    --01-Registro de titulos
    IF pr_rec_cobranca.cdocorre = 1 THEN
      
      --Validar apenas o codigo de instrução 01 - Douglas/Cechet 
      IF pr_tab_linhas('INSTCODI').numero <> 0  AND  
         pr_tab_linhas('INSTCODI').numero <> 6  AND  
         pr_tab_linhas('INSTCODI').numero <> 7  AND
         pr_tab_linhas('INSTCODI').numero <> 10 AND
         pr_tab_linhas('INSTCODI').numero <> 15 THEN 
         
        -- Codigo para Protesto Invalido
        vr_rej_cdmotivo := '37';
        RAISE vr_exc_reje;
        
      END IF;
      
      -- Pessoa Fisica nao permitido protesto
      IF ( pr_rec_header.inpessoa = 1              AND 
           pr_tab_linhas('INSTCODI').numero <> 7   AND
           pr_tab_linhas('INSTCODI').numero <> 0 ) THEN
        
        -- Pedido de protesto nao permitido para o titulo
        vr_rej_cdmotivo := '39';
        RAISE vr_exc_reje;
        
      END IF;
      
      -- Adicionado validação no código de instrução 1 
      -- para gerar a flag de protesto e a quantidade de dias para protestar
      IF ( pr_tab_linhas('INSTCODI').numero = 0   OR
           pr_tab_linhas('INSTCODI').numero = 7 ) THEN
        
        pr_rec_cobranca.cdprotes := 0;
        pr_rec_cobranca.qtdiaprt := 0;
        
      END IF;
      
      --Se o código for "06" gera protesto e a quantidade de dias é calculada no item 48.7
      --Nesse item são feitas validações para buscar a quantidade de dias nas posições 392 e 393
      --sendo que esse valor deve ser entre 05 e 15 dias
      IF pr_tab_linhas('INSTCODI').numero = 6 THEN
        
        pr_rec_cobranca.cdprotes := 1;
        
      END IF;
      
      --Se o código for "10" gera protesto e a quantidade de dias é dez 
      IF pr_tab_linhas('INSTCODI').numero = 10 THEN
        
        pr_rec_cobranca.cdprotes := 1;
        pr_rec_cobranca.qtdiaprt := 10;
        
      END IF;
      
      --Se o código for "15" gera protesto e a quantidade de dias é quinze
      IF pr_tab_linhas('INSTCODI').numero = 15 THEN
        
        pr_rec_cobranca.cdprotes := 1;
        pr_rec_cobranca.qtdiaprt := 15;
        
      END IF;      
    
      IF pr_rec_cobranca.qtdiaprt <> 0 AND
         pr_rec_cobranca.cddespec NOT IN (01, 02) THEN /* DM e DS */
        -- Pedido de Protesto Não Permitido para o Título
        vr_rej_cdmotivo := '39';
        RAISE vr_exc_reje;
      END IF;      
    
    END IF;    
            
    --Solicitacao de Baixa
    IF pr_rec_cobranca.cdocorre = 2 THEN
    
      IF ( pr_tab_linhas('INSTCODI').numero <> 44   AND
           pr_tab_linhas('INSTCODI').numero <> 44 ) THEN
           
        -- Codigo para Baixa/Devolucao Invalido
        vr_rej_cdmotivo := '42';
        RAISE vr_exc_reje;
        
      END IF;
      
    END IF;
    
    --Instrucao para Protestar
    IF pr_rec_cobranca.cdocorre = 9 THEN
    
      IF pr_rec_cobranca.instcodi <> 6  AND --06 a 30 - Protestar no XX dia corridos apos vencido 
         pr_rec_cobranca.instcodi <> 10 AND --10 - Protestar no 10º dia corrido apos vencido  
         pr_rec_cobranca.instcodi <> 15 AND --15 - Protestar no 15º dia corrido apos vencido
         pr_rec_cobranca.instcodi2 <> 6  AND
         pr_rec_cobranca.instcodi2 <> 10 AND
         pr_rec_cobranca.instcodi2 <> 15 THEN 
         
        -- Codigo para Protesto Invalido
        vr_rej_cdmotivo := '37';
        RAISE vr_exc_reje;
        
      END IF;
    
    END IF;
    
    /*
    Observacoes: 
      a)  Os  títulos  com  vencimento  “a  vista”  ou  “na  apresentacao”  e  com  instrucao  para  protesto 
          03, 04, 05, 10, 15, 20, 25 e 30 dias apos o vencimento terao a data de protesto com 18, 19, 
          20, 25, 30, 35, 40 45 dias respectivamente apos a data do seu registro; 
      b)  Nao sao passíveis de Instrucao de Protesto: Notas de Debito, Recibos, Notas Promissorias, 
          prêmios e notas de seguro; 
      c)  Os campo 31.7 ou 32.7  - Primeira Instrucao Codificadas e Segunda Instrucao Codificada – 
          Nao poderao conter “Codigos” conflitantes entre si. Exemplo: 05 – Protestar apos 05 dias e 
          07 – Nao Protestar. Neste caso, sera valida apenas a primeira instrucao informada, ou seja, 
          Protestar apos 5 dias; 
      d)  As  instrucoes  codificadas  remetidas  com  o  mesmo  codigo  serao  canceladas  no 
          processamento.
    */
    
    --Nao protestar
    IF pr_rec_cobranca.instcodi = 7 THEN
        
      -- Ausencia de instrucoes
      pr_rec_cobranca.instcodi2 := 0;
        
    END IF;
    
    -- 33.7 Juros de Mora por Dia de Atraso 
    pr_rec_cobranca.vldjuros := pr_tab_linhas('VLDJUROS').numero;
        
    IF pr_rec_cobranca.vldjuros > pr_rec_cobranca.vltitulo THEN
       
      -- Valor/Taxa de Juros de Mora Invalido
      vr_rej_cdmotivo := '27';
      RAISE vr_exc_reje;
      
    END IF;
        
    IF pr_rec_cobranca.vldjuros > 0 THEN
       
      -- Juros por dia
      pr_rec_cobranca.tpdjuros := 1;
      
    END IF;
    
    --35.7 Valor de Desconto
    pr_rec_cobranca.vldescto := pr_tab_linhas('VLDESCTO').numero;
    
    IF pr_rec_cobranca.vldescto >= pr_rec_cobranca.vltitulo  THEN
      
      -- Valor do Desconto Maior ou Igual ao Valor do Titulo
      vr_rej_cdmotivo := '29';
      RAISE vr_exc_reje;
      
    END IF;
    
    -- Verificar se existe desconto
    IF pr_rec_cobranca.vldescto > 0 THEN
      -- Conceder desconto até o vencimento
      pr_rec_cobranca.tpdescto := 1;
    END IF;
    
    
    -- 37.7 Valor de Abatimento
    pr_rec_cobranca.vlabatim := pr_tab_linhas('VLABATIM').numero;
    
    IF pr_rec_cobranca.vlabatim >= pr_rec_cobranca.vltitulo THEN
       
      -- Valor do Abatimento Maior ou Igual ao Valor do Titulo 
      vr_rej_cdmotivo := '34';
      RAISE vr_exc_reje;
      
    END IF;
    
    -- Dados do sacado
    pr_rec_cobranca.nmdsacad := fn_remove_chr_especial(pr_texto => pr_tab_linhas('NMSACADO').texto);
    pr_rec_cobranca.dsendsac := fn_remove_chr_especial(pr_texto => pr_tab_linhas('ENDSACAD').texto);
    pr_rec_cobranca.nmbaisac := fn_remove_chr_especial(pr_texto => pr_tab_linhas('BAIRRSAC').texto);
    pr_rec_cobranca.nmcidsac := fn_remove_chr_especial(pr_texto => pr_tab_linhas('CIDSACAD').texto);   
    pr_rec_cobranca.cdufsaca := fn_remove_chr_especial(pr_texto => pr_tab_linhas('UFSACADO').texto);
    pr_rec_cobranca.nrcepsac := pr_tab_linhas('CEPSACAD').numero;
    pr_rec_cobranca.cdtpinsc := pr_tab_linhas('TPINSSAC').numero;
      
    -- 38.7 Tipo de inscricao do sacado 
    IF pr_tab_linhas('TPINSSAC').numero <> 0 AND  --Vazio
       pr_tab_linhas('TPINSSAC').numero <> 1 AND  --Fisica
       pr_tab_linhas('TPINSSAC').numero <> 2 THEN --Juridica
             
      -- Tipo/Numero de Inscricao do Sacado Invalidos
      vr_rej_cdmotivo := '46';
      RAISE vr_exc_reje;             
        
    END IF;
  
    -- 39.7 Numero CPF/CNPJ do Sacado
    pr_rec_cobranca.nrinssac := pr_tab_linhas('NRCPFSAC').numero;
    
    gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_rec_cobranca.nrinssac
                               ,pr_stsnrcal => vr_stsnrcal
                               ,pr_inpessoa => vr_inpessoa);
                                
    -- Verifica se o CPF/CNPJ esta correto
    IF NOT vr_stsnrcal THEN
      
      -- Tipo/Numero de Inscricao do Sacado Invalidos
      vr_rej_cdmotivo := '46';
      RAISE vr_exc_reje;
      
    END IF;
    
    -- se pagador dor PF, entao validar CPF
    IF pr_rec_cobranca.cdtpinsc = 1 THEN
      gene0005.pc_valida_cpf(pr_nrcalcul => pr_rec_cobranca.nrinssac,
                             pr_stsnrcal => vr_stsnrcal);                             
      -- Verifica se o CPF esta correto
      IF NOT vr_stsnrcal THEN
      -- Tipo/Numero de Inscricao do Sacado Invalidos
      vr_rej_cdmotivo := '46';
      RAISE vr_exc_reje;
      END IF;                             
    END IF;
      
    -- se pagador dor PJ, entao validar CNPJ
    IF pr_rec_cobranca.cdtpinsc = 2 THEN
      gene0005.pc_valida_cnpj(pr_nrcalcul => pr_rec_cobranca.nrinssac,
                              pr_stsnrcal => vr_stsnrcal);                             
      -- Verifica se o CNPJ esta correto
      IF NOT vr_stsnrcal THEN
      -- Tipo/Numero de Inscricao do Sacado Invalidos
      vr_rej_cdmotivo := '46';
      RAISE vr_exc_reje;
      END IF;                             
    END IF;
      
    -- Validar se o CPF/CNPJ do pagador é o mesmo do Beneficiário
    IF pr_rec_cobranca.nrinssac = pr_rec_header.nrcpfcgc THEN
      -- Tipo/Numero de Inscricao do Sacado Invalidos
      vr_rej_cdmotivo := '46';
      RAISE vr_exc_reje;
    END IF;
  
    -- 40.7 Nome do Sacado
    IF TRIM(pr_rec_cobranca.nmdsacad) IS NULL THEN
      
      -- Nome do Sacado Nao Informado
      vr_rej_cdmotivo := '45';
      RAISE vr_exc_reje;
      
    END IF;
    
    -- Validar os caracteres do nome do sacado
    IF fn_valida_caracteres(pr_flgnumer => TRUE   -- Validar Numeros
                           ,pr_flgletra => TRUE   -- Validar Letras
                           ,pr_listaesp => ''     -- Lista Caracteres Validos
                           ,pr_dsvalida => pr_rec_cobranca.nmdsacad ) THEN -- Nome do Sacado
                            
      -- Nome do Sacado Nao Informado
      vr_rej_cdmotivo := '45';
      RAISE vr_exc_reje;
      
    END IF;
  
    -- 42.7 Endereco do Sacado
    IF TRIM(pr_rec_cobranca.dsendsac) IS NULL THEN
      
      -- Endereco do Sacado Nao Informado
      vr_rej_cdmotivo := '47';
      RAISE vr_exc_reje;
      
    END IF;
    
    -- Validar os caracteres do endereco do sacado
    IF fn_valida_caracteres(pr_flgnumer => TRUE   -- Validar Numeros
                           ,pr_flgletra => TRUE   -- Validar Letras
                           ,pr_listaesp => ''     -- Lista Caracteres Validos
                           ,pr_dsvalida => pr_rec_cobranca.dsendsac ) THEN -- Nome do Sacado
                            
      -- Endereco do Sacado Nao Informado
      vr_rej_cdmotivo := '47';
      RAISE vr_exc_reje;
      
    END IF;
  
    -- 44.7 CEP do Sacado nao informado, ou zerado
    IF TRIM(pr_rec_cobranca.nrcepsac) IS NULL OR 
       NVL(pr_rec_cobranca.nrcepsac, 0) = 0 THEN
      
      --  CEP Invalido
      vr_rej_cdmotivo := '48';
      RAISE vr_exc_reje;
      
    END IF;
    
    -- Validar os caracteres do cep do sacado
    IF fn_valida_caracteres(pr_flgnumer => TRUE   -- Validar Numeros
                           ,pr_flgletra => FALSE  -- Validar Letras
                           ,pr_listaesp => ''     -- Lista Caracteres Validos
                           ,pr_dsvalida => pr_rec_cobranca.nrcepsac ) THEN -- Nome do Sacado
                            
      -- CEP invalido
      vr_rej_cdmotivo := '48';
      RAISE vr_exc_reje;
      
    END IF;

/* Nao sera mais validado se o CEP existe no sistema
   Chamado 601436 -> Solicitado por Leomir e autorizado pelo Victor Hugo Zimmerman
     
    -- 44.7 Valida CEP do Sacado
    -- Pesquisar a Origem = CORREIOS
    OPEN cr_crapdne (pr_nrceplog => pr_rec_cobranca.nrcepsac,
                     pr_idoricad => 1); -- Correios
                     
    FETCH cr_crapdne INTO rw_crapdne;
    
    IF cr_crapdne%NOTFOUND THEN
      
      CLOSE cr_crapdne;
      
      -- Se nao encontrou 
      -- Pesquisar a Origem = AYLLOS
      OPEN cr_crapdne(pr_nrceplog => pr_rec_cobranca.nrcepsac
                     ,pr_idoricad => 2); -- Ayllos
                      
      FETCH cr_crapdne INTO rw_crapdne;
      
    END IF;
      
    IF cr_crapdne%NOTFOUND THEN
      
      IF cr_crapdne%ISOPEN THEN
        CLOSE cr_crapdne;
      END IF;
      
      -- CEP Invalido
      vr_rej_cdmotivo := '48';
      RAISE vr_exc_reje;
      
    END IF;
    
    IF cr_crapdne%ISOPEN THEN
      CLOSE cr_crapdne;
    END IF;
*/

    -- 46.7 UF do Sacado
    /*
    IF pr_rec_cobranca.cdufsaca <> rw_crapdne.cduflogr THEN
      
      --  CEP Incompativel com a Unidade da Federacao
      vr_rej_cdmotivo := '51';
      RAISE vr_exc_reje;
      
    END IF;
	*/
  
	-- Validar UF que esta no arquivo.
	OPEN cr_caduf(pr_rec_cobranca.cdufsaca);
    
    FETCH cr_caduf INTO rw_caduf;
        
    IF cr_caduf%NOTFOUND THEN      
      
      CLOSE cr_caduf;
      vr_rej_cdmotivo := '51';
      RAISE vr_exc_reje;
      
    END IF;
        
    CLOSE cr_caduf;
  
    -- 47.7 Mensagem ou Sacador/Avalista 
    IF pr_tab_linhas('INDMENSA').texto = 'A' THEN
            
      IF substr(pr_tab_linhas('OBSMENSA').texto,23,4) = 'CNPJ' THEN
        pr_rec_cobranca.nmdavali := substr(pr_tab_linhas('OBSMENSA').texto,1,20);
        pr_rec_cobranca.nrinsava := substr(pr_tab_linhas('OBSMENSA').texto,27,14);
        pr_rec_cobranca.cdtpinav := 2;
      
        IF to_number(substr(pr_tab_linhas('OBSMENSA').texto,27,14)) > 0 AND 
           trim(substr(pr_tab_linhas('OBSMENSA').texto,1,20)) IS NULL   THEN
          
          -- Nome do Sacado Nao Informado
          vr_rej_cdmotivo := '54';
          RAISE vr_exc_reje;
        
        ELSE
          
          gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => to_number(substr(pr_tab_linhas('OBSMENSA').texto,27,14))
                                     ,pr_stsnrcal => vr_stsnrcal
                                     ,pr_inpessoa => vr_inpessoa);
                                      
          -- Verifica se o CPF/CNPJ esta correto
          IF NOT vr_stsnrcal THEN
            
            -- Tipo/Numero de Inscricao do Sacado Invalidos
            vr_rej_cdmotivo := '53';
            RAISE vr_exc_reje;
            
          END IF;
        
        END IF;         
         
      ELSIF substr(pr_tab_linhas('OBSMENSA').texto,27,3) = 'CPF' THEN
        pr_rec_cobranca.nmdavali := substr(pr_tab_linhas('OBSMENSA').texto,1,24);
        pr_rec_cobranca.nrinsava := substr(pr_tab_linhas('OBSMENSA').texto,30,11);
        pr_rec_cobranca.cdtpinav := 1;
        
        IF to_number(substr(pr_tab_linhas('OBSMENSA').texto,30,11)) > 0 AND 
           trim(substr(pr_tab_linhas('OBSMENSA').texto,1,24)) IS NULL   THEN
          
          -- Nome do Sacado Nao Informado
          vr_rej_cdmotivo := '54';
          RAISE vr_exc_reje;
        
        ELSE
          
          gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => to_number(substr(pr_tab_linhas('OBSMENSA').texto,28,14))
                                     ,pr_stsnrcal => vr_stsnrcal
                                     ,pr_inpessoa => vr_inpessoa);
                                      
          -- Verifica se o CPF/CNPJ esta correto
          IF NOT vr_stsnrcal THEN
            
            -- Tipo/Numero de Inscricao do Sacado Invalidos
            vr_rej_cdmotivo := '53';
            RAISE vr_exc_reje;
            
          END IF;
        
        END IF;
      
      END IF;
      
    ELSIF trim(pr_tab_linhas('INDMENSA').texto) IS NULL  THEN
          
      pr_rec_cobranca.dsdinstr := fn_remove_chr_especial(substr(pr_tab_linhas('OBSMENSA').texto,1,40));
    
    END IF;
  
    /* 48.7 Numero de dias para protesto */
    /* Caso o campo “Comando” tenha sido preenchido com “01-Registro de titulos” e o campo 
       “instrucao codificada” tenha sido preenchido com “06”, informar o numero de dias 
       corridos para protesto: de 06 a 29, 35 ou 40 dias 
       Nosso sistema trabalha apenas com prazo de 5 a 15 dias. */
    IF pr_rec_cobranca.cdprotes = 1 THEN -- 01-Registro de titulos
      
      BEGIN
        SELECT insrvprt
          INTO pr_rec_cobranca.insrvprt
          FROM crapcco
         WHERE cdcooper = pr_rec_cobranca.cdcooper
           AND nrconven = pr_rec_cobranca.nrcnvcob;
      EXCEPTION
          WHEN OTHERS THEN
            pr_rec_cobranca.insrvprt := 2;
      END;
      
      -- 06-Indica Protesto em dias corridos
      IF pr_rec_cobranca.instcodi  = 6 OR
         pr_rec_cobranca.instcodi2 = 6 THEN
         
        pr_rec_cobranca.qtdiaprt := pr_tab_linhas('NRDIAPRT').numero;
        
        -- Valida dias para protesto
        IF pr_rec_cobranca.qtdiaprt <> 0 THEN
        
          --Buscando os uf não permitidos para protestar
          OPEN cr_dsnegufds(pr_cdcooper);
          FETCH cr_dsnegufds INTO vr_dsnegufds;
          CLOSE cr_dsnegufds;
          
          IF vr_dsnegufds LIKE '%' || pr_rec_cobranca.cdufsaca || '%' AND 
           pr_rec_cobranca.cddespec = 02 /*DS*/ THEN
             --Espécie de título inválida para carteira
             vr_rej_cdmotivo := '05'; 
             RAISE vr_exc_reje;
          END IF;

        END IF;
        
        tela_parprt.pc_consulta_periodo_parprt(pr_cdcooper => pr_rec_cobranca.cdcooper,
                                               pr_qtlimitemin_tolerancia => vr_limitemin,
                                               pr_qtlimitemax_tolerancia => vr_limitemax,
                                               pr_des_erro => vr_des_erro,
                                               pr_dscritic => vr_dscritic);
                                               
        IF (vr_des_erro <> 'OK') THEN
          vr_rej_cdmotivo := '38';
          RAISE vr_exc_reje;
        ELSE
          -- Prazo para protesto valido de X a Y dias
          IF pr_rec_cobranca.qtdiaprt < vr_limitemin  OR 
             pr_rec_cobranca.qtdiaprt > vr_limitemax THEN
           
          -- Prazo para Protesto Invalido
          vr_rej_cdmotivo := '38';
          RAISE vr_exc_reje;
          
        END IF;
        END IF;
        
      END IF;
            
      --SD#586758
      if nvl(pr_rec_cobranca.qtdiaprt,0) > 0 then
        pr_rec_cobranca.flgdprot := 1;
      end if;
            
    END IF;
    
    -- Se for solicitacao de Remessa, entao devera gravar sacado
    IF pr_rec_cobranca.cdocorre = 01 THEN --01 - Registro de Titulo
       pc_grava_sacado(pr_cdoperad     => pr_cdoperad     --> Operador
                      ,pr_rec_cobranca => pr_rec_cobranca --> Dados da linha
                      ,pr_tab_sacado   => pr_tab_sacado   --> Tabela de Instrucoes
                      ,pr_dscritic     => vr_dscritic);   --> Descricao do Erro
    END IF;
    
    pr_des_reto := 'OK';
  
  EXCEPTION 
    WHEN vr_exc_fim  THEN
      -- Fim da execucao devido a ocorrencia que nao necessita do 
      -- restante das validacoes 
      pr_des_reto:= 'OK';
      
    WHEN vr_exc_reje THEN
      -- Rejeitou a cobranca e nao deve continuar o processamento
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_nrdconta -- Enviar o pr_nrdconta ao inves do pr_rec_cobranca.nrdconta, pois quando o motivo eh 08 o campo pr_rec_cobranca.nrdconta eh gerado com valor errado
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
      
      pr_des_reto:= 'NOK';
      pr_rec_cobranca.flgrejei:= TRUE;
      
    WHEN OTHERS THEN
      -- Erro geral no processamento - codigo 99
      vr_rej_cdmotivo:= '99';

      -- Erro geral do processamento 
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_nrdconta -- Enviar o pr_nrdconta ao inves do pr_rec_cobranca.nrdconta, pois quando o motivo eh 08 o campo pr_rec_cobranca.nrdconta eh gerado com valor errado
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
                                
      -- Quando ocorrer erro geral em procedures que processam os segmentos
      -- deve gerar as informacoes da cobranca em questao no arquivo proc_message.log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - COBR0006 --> pc_trata_detalhe_cnab400 ' ||
                                                    ' Coop: '      || pr_cdcooper ||
                                                    ' Conta: '     || pr_nrdconta ||
                                                    ' Remessa: '   || pr_rec_header.nrremass ||
                                                    ' Convenio: '  || pr_rec_header.nrcnvcob ||
                                                    ' Nosso Num.:' || pr_rec_cobranca.dsnosnum ||
                                                    ' - TRACE: '   || dbms_utility.format_error_backtrace || 
                                                    ' - '          || dbms_utility.format_error_stack);
                                
      -- Ignora a cobranca
      pr_des_reto:= 'NOK';
      pr_rec_cobranca.flgrejei:= TRUE;
      
  END pc_trata_detalhe_cnab400;  
  
  --> Tratar linha de multa
  PROCEDURE pc_trata_multa_cnab400 (pr_cdcooper      IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE   --> Numero da conta do cooperado
                                   ,pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE   --> Data de movimento
                                   ,pr_cdoperad      IN crapope.cdoperad%TYPE   --> Operador
                                   ,pr_tab_linhas    IN gene0009.typ_tab_campos --> Dados da linha
                                   ,pr_rec_header    IN typ_rec_header          --> Dados do Header do Arquivo
                                   ,pr_rec_cobranca  IN OUT NOCOPY typ_rec_cobranca    --> Dados da Cobranca
                                   ,pr_tab_rejeitado IN OUT NOCOPY typ_tab_rejeitado   --> Tabela de Rejeitados
                                   ,pr_tab_sacado    IN OUT NOCOPY typ_tab_sacado      --> Tabela de Sacados
                                   ,pr_des_reto      OUT VARCHAR2)IS            --> Retorno OK/NOK
                                   
  /* ............................................................................

       Programa: pc_trata_multa
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrei - RKAM
       Data    : Marco/2016.                   Ultima atualizacao: 13/02/2017 

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Tratar linha do arquivo que contem as informações de multa

       Alteracoes: 13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 
    ............................................................................ */   
    
    ------------------------ VARIAVEIS  ----------------------------
    -- Tratamento de erros
    vr_exc_reje   EXCEPTION;
    vr_exc_fim    EXCEPTION;
    vr_dscritic   VARCHAR2(4000);
    vr_des_erro   VARCHAR2(1000);
    vr_rej_cdmotivo VARCHAR2(2);
    vr_cdcritic     INTEGER;
    
  BEGIN

    --> Nao executar em caso de Instrucao
    IF pr_rec_cobranca.cdocorre <> 1 THEN 
      
      RAISE vr_exc_fim;
      
    END IF;
    
    -- Tipo de Serviço "99" (Multa) e "01" (Envio de Boleto por e-mail)
    IF pr_tab_linhas('TPSERVIC').texto <> '99' AND
       pr_tab_linhas('TPSERVIC').texto <> '01' THEN
      vr_rej_cdmotivo := '2'; /* Tipo de servico invalido */
      RAISE vr_exc_reje;
    END IF;

    -- 02.5 Tipo de serviço "01"
    IF pr_tab_linhas('TPSERVIC').texto = '01' THEN
      
      COBR0006.pc_altera_email_cel_sacado(pr_cdcooper => pr_cdcooper    --Cooperativa 
                                         ,pr_nrdconta => pr_nrdconta    --Conta
                                         ,pr_nrinssac => pr_rec_cobranca.nrinssac    --Inscrição do sacado
                                         ,pr_dsdemail => substr(pr_tab_linhas('DSCEMAIL').texto,1,136) --E-mail
                                         ,pr_nrcelsac => 0              --Número do celular
                                         ,pr_des_erro => vr_des_erro    --Retorno OK/NOK
                                         ,pr_cdcritic => vr_cdcritic    --Codigo Critica
                                         ,pr_dscritic => vr_dscritic);  --Tabela de erros 
     
    /* 02.5 Tipo de servico "99" */

    ELSIF pr_tab_linhas('TPSERVIC').texto = 99 THEN   
    
      /* 03.5 Codigo de Multa */

      pr_rec_cobranca.tpdmulta := pr_tab_linhas('CODMULTA').numero;
      
      IF pr_rec_cobranca.tpdmulta <> 1 AND  -- Valor Fixo
         pr_rec_cobranca.tpdmulta <> 2 AND  -- Valor Fixo
         pr_rec_cobranca.tpdmulta <> 9 THEN -- Isento
         
        -- Codigo da Multa Invalido
        vr_rej_cdmotivo := '57';
        RAISE vr_exc_reje;
        
      END IF;
       
      -- 05.5 Valor/Percentual da Multa 
      pr_rec_cobranca.vldmulta := pr_tab_linhas('VLDMULTA').numero;
     
      -- Valor
      IF pr_rec_cobranca.tpdmulta = 1 THEN
        
        IF pr_rec_cobranca.vldmulta > pr_rec_cobranca.vltitulo THEN
          --  Valor/Percentual da Multa Invalido 
          vr_rej_cdmotivo := '59';
          RAISE vr_exc_reje;
        END IF;
      --Percentual
      ELSIF pr_rec_cobranca.tpdmulta = 2 THEN
        
        IF pr_rec_cobranca.vldmulta > 100 THEN
          --  Valor/Percentual da Multa Invalido 
          vr_rej_cdmotivo := '59';
          RAISE vr_exc_reje;
        END IF;
      --Isento
      ELSIF pr_rec_cobranca.tpdmulta = 9 THEN
        -- Se Isento Desprezar Valor
        --IF pr_rec_cobranca.tpdjuros = 3 THEN
          pr_rec_cobranca.vldmulta := 0;
        --END IF;
        
      END IF;
      
      /* se nao possui valor de multa, definir como isento */                             
      IF pr_rec_cobranca.vldmulta = 0 THEN
        
        pr_rec_cobranca.tpdmulta := 9;
      
      END IF;

    END IF;
    
    pr_des_reto := 'OK';
  
  EXCEPTION 
    WHEN vr_exc_fim  THEN
      -- Fim da execucao devido a ocorrencia que nao necessita do 
      -- restante das validacoes 
      pr_des_reto:= 'OK';
      
    WHEN vr_exc_reje THEN
      -- Rejeitou a cobranca e nao deve continuar o processamento
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_rec_cobranca.nrdconta --> Numero da Conta
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
      pr_des_reto:= 'NOK';
      pr_rec_cobranca.flgrejei:= TRUE;
      
    WHEN OTHERS THEN
      -- Erro geral no processamento - codigo 99
      vr_rej_cdmotivo:= '99';
      -- Erro geral do processamento do segmento "Q"
      pc_valida_grava_rejeitado(pr_cdcooper      => pr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => pr_rec_cobranca.nrdconta --> Numero da Conta
                               ,pr_nrcnvcob      => pr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => pr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => pr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => pr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => pr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => pr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => pr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => pr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => pr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => pr_tab_rejeitado);       --> Tabela de Rejeitados
                                
      -- Quando ocorrer erro geral em procedures que processam os segmentos
      -- deve gerar as informacoes da cobranca em questao no arquivo proc_message.log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - COBR0006 --> pc_trata_multa_cnab400 ' ||
                                                    ' Coop: '      || pr_cdcooper ||
                                                    ' Conta: '     || pr_nrdconta ||
                                                    ' Remessa: '   || pr_rec_header.nrremass ||
                                                    ' Convenio: '  || pr_rec_header.nrcnvcob ||
                                                    ' Nosso Num.:' || pr_rec_cobranca.dsnosnum ||
                                                    ' - TRACE: '   || dbms_utility.format_error_backtrace || 
                                                    ' - '          || dbms_utility.format_error_stack);
                                
      -- Ignora a cobranca
      pr_des_reto:= 'NOK';
      pr_rec_cobranca.flgrejei:= TRUE;
      
  END pc_trata_multa_cnab400;
  
  --> Integrar/processar arquivo de remessa cnab240_001
  PROCEDURE pc_intarq_remes_cnab240_001(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                       ,pr_nmarquiv  IN VARCHAR2              --> Nome do arquivo a ser importado               
                                       ,pr_idorigem  IN INTEGER               --> Identificador de origem
                                       ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                       ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do operador
                                       ,pr_nmdatela  IN VARCHAR2              --> Nome da Tela                                 
                                       ,pr_tab_crawrej IN OUT NOCOPY typ_tab_crawrej --> Tabela de Rejeitados
                                       ,pr_hrtransa OUT INTEGER               --> Hora da transacao
                                       ,pr_nrprotoc OUT VARCHAR2              --> Numero do Protocolo
                                       ,pr_des_reto OUT VARCHAR2              --> OK ou NOK
                                       ,pr_cdcritic OUT INTEGER               --> Codigo de critica
                                       ,pr_dscritic OUT VARCHAR2)IS           --> Descricao da critica
                                   
  /* ............................................................................

       Programa: pc_integra_arq_remessa    antiga: b1wgen0090.p/p_integra_arq_remessa
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrei - RKAM
       Data    : Marco/2016.                   Ultima atualizacao: 13/02/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel pode integrar o arquivo de remessa de cobrança
                   no padrão CNAB240 para boletos 001

       Alteracoes: 08/03/2016 - Conversão Progress -> Oracle (Andrei - RKAM)       
       
                   17/08/2016 - Ajuste para enviar o nome original do arquivo para emissao do protocolo
                                (Andrei - RKAM).


			       13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 

                   09/11/2017 - Inclusão de chamada da procedure npcb0002.pc_libera_sessao_sqlserver_npc.
                                (SD#791193 - AJFink)

    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_exc_saida  EXCEPTION;
    vr_cdcritic   INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_dscritic2  VARCHAR2(4000);
    vr_des_reto   VARCHAR2(400);
    vr_nrdoccri   crapcob.nrdocmto%TYPE;

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdbcoctl
          ,cop.cdagectl
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    rw_craprtc COBR0006.cr_craprtc%ROWTYPE;
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    vr_tab_listarqu  gene0002.typ_split;
    vr_tab_crapaux   typ_tab_crawaux;
    vr_tab_linhas    gene0009.typ_tab_linhas;
    vr_rec_header    typ_rec_header;
    vr_rec_cobranca  typ_rec_cobranca;
    vr_tab_crapcob   typ_tab_crapcob;
    vr_tab_instrucao typ_tab_instrucao;
    vr_tab_rejeitado typ_tab_rejeitado;
    vr_tab_sacado    typ_tab_sacado;
    vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
    vr_tab_crawrej   COBR0006.typ_tab_crawrej;
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_dstextab     craptab.dstextab%TYPE;
    vr_diasvcto     INTEGER;
    
    vr_dscomand     VARCHAR2(4000);
    vr_typ_said     VARCHAR2(500);
    vr_setlinha     VARCHAR2(500);
    
    vr_dsdireto     VARCHAR2(500);
    vr_dsdircop     VARCHAR2(500);
    vr_nmarquiv     VARCHAR2(500);
    vr_nmfisico     VARCHAR2(500);
    vr_listarqu     VARCHAR2(4000);
    vr_contador     INTEGER := 0;
    vr_idxarq       PLS_INTEGER;
    vr_flgfirst     BOOLEAN := FALSE;
    
    vr_qtbloque     INTEGER := 0;
    vr_qtdregis     INTEGER := 0;
    vr_qtdinstr     INTEGER := 0;    
    vr_vlrtotal     NUMBER  := 0;
    vr_qterro       INTEGER := 0;
    vr_rowid_resumo      ROWID;
    vr_rowid_item_resumo ROWID;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
  BEGIN

    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_intarq_remes_cnab240_001');

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    
    FETCH cr_crapcop INTO rw_crapcop;
    
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
      
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
    
    --> Buscar parametro de vencimento
    vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => 3, 
                                               pr_nmsistem => 'CRED', 
                                               pr_tptabela => 'GENERI', 
                                               pr_cdempres => 0, 
                                               pr_cdacesso => 'DIASVCTOCEE', 
                                               pr_tpregist => 0);
    IF TRIM(vr_dstextab) IS NULL THEN
      vr_dscritic := 'Tabela com parametro vencimento nao encontrado.';
      RAISE vr_exc_erro;
    END IF;
    
    --> buscar diretorio da cooperativa
    vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C', 
                                         pr_cdcooper => pr_cdcooper, 
                                         pr_nmsubdir => NULL);
    
    
    vr_diasvcto := SUBSTR(vr_dstextab,1,2);
    
    -- separa diretorio e nmarquivo
    gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmarquiv, 
                                    pr_direto  => vr_dsdireto, 
                                    pr_arquivo => vr_nmarquiv);
    
    -- Buscar arquivo a ser importado
    gene0001.pc_lista_arquivos(pr_path     => vr_dsdireto
                              ,pr_pesq     => vr_nmarquiv
                              ,pr_listarq  => vr_listarqu
                              ,pr_des_erro => vr_dscritic);

    -- Se ocorrer erro ao recuperar lista de arquivos, registra no log
    IF TRIM(vr_dscritic) IS NOT NULL THEN 
      vr_dscritic := 'Nao foi possivel localizar arquivo '||pr_nmarquiv||': '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    
    --Inicia o processo de monitoramento para o Aymaru
    pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                        ,pr_nrdconta  => pr_nrdconta --> Número da conta
                        ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                        ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                        ,pr_tpoperac  => 1           --> Tipo de operação
                        ,pr_flgerro   => 0           --> Sem erros
                        ,pr_nmarquiv  => vr_nmarquiv --> Nome do arquivo
                        ,pr_dslogerro => ''          --> Descrição do erro
                        ,pr_qtprocessado => 0        --> Quantidade de registros processados
                        ,pr_qterro       => 0        --> Quantidade de registros com erro
                        ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                        ,pr_rowid_item_resumo => vr_rowid_item_resumo);
                        
    vr_tab_listarqu := gene0002.fn_quebra_string(pr_string => vr_listarqu,
                                                 pr_delimit => ',');
    
    vr_contador := 0;
                                            
    IF vr_tab_listarqu.count > 0 THEN
      
      --> Varrer arquivos
      FOR i IN vr_tab_listarqu.first..vr_tab_listarqu.last LOOP
        
        vr_contador := vr_contador + 1;
        vr_nmfisico := vr_dsdircop||'/integra/cobran'|| to_char(pr_dtmvtolt,'DDMMRR')||
                       '_'|| to_char(vr_contador,'fm0000') ||'_'||to_char(pr_nrdconta,'fm00000000');
        
        --> Controlar tamanho do arquivo
        IF length(vr_tab_listarqu(i)) > 90  THEN
          
          vr_cdcritic := 999;
          vr_dscritic := 'Nome do Arquivo muito grande';
          vr_nrdoccri := 0;      
          RAISE vr_exc_saida;
          
        END IF;
        
        vr_dscomand := 'dos2ux ' || vr_dsdireto || '/' || vr_tab_listarqu(i) ||' > ' || vr_nmfisico;

        -- Converte o arquivo de DOS para Unix
        gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic);
        
        -- Verificar retorno de erro
        IF NVL(vr_typ_said, ' ') = 'ERR' THEN
          -- O comando shell executou com erro
          vr_cdcritic := 0;
          vr_dscritic := 'Erro dos2ux arquivos: '||vr_dscritic;
          RAISE vr_exc_erro;
        END IF;
        
        -- Comando para listar a primeira linha do arquivo
        vr_dscomand:= 'head -1 ' ||vr_nmfisico;

        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_dscomand
                             ,pr_typ_saida   => vr_typ_said
                             ,pr_des_saida   => vr_setlinha);
                             
        --Se ocorreu erro dar RAISE
        IF vr_typ_said = 'ERR' THEN
          vr_dscritic:= 'Não foi possivel executar comando unix. '||vr_dscomand;
          RAISE vr_exc_erro;
        END IF;
        
        --> Verificar tamanho da linha do arquivo (padrao cnab240)
        IF length(vr_setlinha) > 243 THEN
        
          vr_cdcritic := 999;
          vr_dscritic := 'Arquivo fora do formato';
          vr_nrdoccri := 0;      
          RAISE vr_exc_saida;
        
        END IF;
        
        vr_idxarq := vr_tab_crapaux.count;
        vr_tab_crapaux(vr_idxarq).nrsequen := SUBSTR(vr_setlinha,158,06);
        vr_tab_crapaux(vr_idxarq).nmarquiv := vr_nmfisico;
        vr_tab_crapaux(vr_idxarq).nmarqori := SUBSTR(pr_nmarquiv,INSTR(pr_nmarquiv,'/',-1)+1);
        
        vr_flgfirst := TRUE;
        
      END LOOP;
      
    END IF;
    
    IF NOT vr_flgfirst  THEN    
      vr_cdcritic := 887; --> Identificacao do arquivo Invalida 
      vr_nrdoccri := 0;
      RAISE vr_exc_saida;   
    END IF;
   
    vr_qtbloque := 0;
    vr_qtdregis := 0;
    vr_qtdinstr := 0;
    
    -- Processar arquivos
    FOR i IN vr_tab_crapaux.first..vr_tab_crapaux.last LOOP
      
      vr_flgfirst := FALSE;
      vr_vlrtotal := 0;
      vr_tab_linhas.delete;
      
      -- separa diretorio e nmarquivo
      gene0001.pc_separa_arquivo_path(pr_caminho => vr_tab_crapaux(i).nmarquiv, 
                                      pr_direto  => vr_dsdireto, 
                                      pr_arquivo => vr_nmarquiv);
      
      --> Ler arquivo conforme configurado no cadastro de layout 
      gene0009.pc_importa_arq_layout( pr_nmlayout   => 'CNAB240',      --> Nome do Layout do arquivo a ser importado
                                      pr_dsdireto   => vr_dsdireto,    --> Descrição do diretorio onde o arquivo se enconta
                                      pr_nmarquiv   => vr_nmarquiv,    --> Nome do arquivo a ser importado
                                      -----> OUT <------ 
                                      pr_dscritic   => vr_dscritic,    --> Retorna critica Caso ocorra
                                      pr_tab_linhas => vr_tab_linhas); --> Retorna as linhas/campos do arquivo na temptable
                                      
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      IF vr_tab_linhas.count = 0 THEN
        
        vr_cdcritic := 999;
        vr_dscritic := 'Arquivo vazio.';
        vr_nrdoccri := 0;     
         
        RAISE vr_exc_saida;  
        
      ELSE
        
        -- Antes de iniciar o processamento do layout CNAB240, vamos limpar a PL TABLE
        vr_tab_crapcob.delete;  
        vr_tab_instrucao.delete;
        vr_tab_rejeitado.delete;
        vr_tab_sacado.delete;
      
        --> Varrer linhas do arquivo
        FOR vr_idlinha IN vr_tab_linhas.first..vr_tab_linhas.last LOOP
          
          IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
            
             vr_dscritic := 'Linha '||vr_idlinha||' '|| vr_tab_linhas(vr_idlinha)('$ERRO$').texto;
             vr_nrdoccri := 0;  
                 
             RAISE vr_exc_saida;
             
          END IF;
          
          -------------------  Header do Arquivo --------------------
          IF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'HA' THEN 
            
            pc_trata_header_arq_240_01 (pr_cdcooper   => pr_cdcooper,               --> Codigo da cooperativa
                                        pr_nrdconta   => pr_nrdconta,               --> Numero da conta do cooperado
                                        pr_tab_linhas => vr_tab_linhas(vr_idlinha), --> Dados da linha
                                        pr_rec_header => vr_rec_header,             --> Dados do Header
                                        pr_cdcritic   => vr_cdcritic,               --> Codigo de critica
                                        pr_dscritic   => vr_dscritic,               --> Descricao da critica
                                        pr_des_reto   => vr_des_reto );             --> Retorno OK/NOK
                                   
            IF vr_des_reto <> 'OK' THEN
              
              --> Remover arquivo 
              vr_dscomand := 'rm -f '|| vr_tab_crapaux(i).nmarquiv;
              
              gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                          pr_typ_saida   => vr_typ_said,
                                          pr_des_saida   => vr_dscritic2);
              
              -- Verificar retorno de erro
              IF NVL(vr_typ_said, ' ') = 'ERR' THEN
                
                IF NVL(vr_cdcritic,0) = 0    AND
                   TRIM(vr_dscritic) IS NULL THEN
                  -- O comando shell executou com erro
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                
                END IF;
                 
                RAISE vr_exc_erro;
                
              END IF;
        
              RAISE vr_exc_saida;
              
            END IF;
            
            -- Se nao ocorreu erro no header, carrega as informacoes de banco
            vr_rec_header.cdbcoctl := rw_crapcop.cdbcoctl;
            vr_rec_header.cdagectl := rw_crapcop.cdagectl;
            
          --------------------  Header do Arquivo ---------------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'HL' THEN   
          
            pc_trata_header_lote_240_01(pr_cdcooper   => pr_cdcooper,               --> Codigo da cooperativa
                                        pr_nrdconta   => pr_nrdconta,               --> Numero da conta do cooperado
                                        pr_nrconven   => vr_rec_header.nrcnvcob,    --> numero do convenio
                                        pr_tab_linhas => vr_tab_linhas(vr_idlinha), --> Dados da linha
                                        pr_cdcritic   => vr_cdcritic,               --> Codigo de critica
                                        pr_dscritic   => vr_dscritic,               --> Descricao da critica
                                        pr_des_reto   => vr_des_reto );             --> Retorno OK/NOK
                                  
            IF vr_des_reto <> 'OK' THEN
              
              --> Remover arquivo 
              vr_dscomand := 'rm -f '|| vr_tab_crapaux(i).nmarquiv;
              
              gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                          pr_typ_saida   => vr_typ_said,
                                          pr_des_saida   => vr_dscritic2);
              
              -- Verificar retorno de erro
              IF NVL(vr_typ_said, ' ') = 'ERR' THEN
                
                IF NVL(vr_cdcritic,0) = 0    AND
                   TRIM(vr_dscritic) IS NULL THEN
                  -- O comando shell executou com erro
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                  
                END IF;
                  
                RAISE vr_exc_erro;
                
              END IF;
        
              RAISE vr_exc_saida;
              
            END IF; 
            
          ---------------  Detalhe ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'P' THEN    
          
            -- Processar o Segmento "P"            
            pc_trata_segmento_p_240_01(pr_cdcooper      => pr_cdcooper,               --> Codigo da cooperativa
                                       pr_nrdconta      => pr_nrdconta,               --> Numero da conta do cooperado
                                       pr_dtmvtolt      => pr_dtmvtolt,               --> Data de Movimento
                                       pr_cdoperad      => pr_cdoperad,               --> Operador
                                       pr_diasvcto      => vr_diasvcto,               --> Dias de vr_diasvctoencimento
                                       pr_flgfirst      => vr_flgfirst,               --> controle de primeiro registro
                                       pr_tab_linhas    => vr_tab_linhas(vr_idlinha), --> Dados da linha
                                       pr_rec_header    => vr_rec_header,             --> Dados do Header do Arquivo
                                       pr_qtdregis      => vr_qtdregis,               --> contador de registro
                                       pr_qtdinstr      => vr_qtdinstr,               --> contador de instucoes
                                       pr_qtbloque      => vr_qtbloque,               --> contador de boletos processados
                                       pr_vlrtotal      => vr_vlrtotal,               --> Valor total dos boletos
                                       pr_rec_cobranca  => vr_rec_cobranca,           --> Dados da Cobranca
                                       pr_tab_crapcob   => vr_tab_crapcob,            --> Tabela de Cobranca
                                       pr_tab_instrucao => vr_tab_instrucao,          --> Tabela de Instrucoes
                                       pr_tab_rejeitado => vr_tab_rejeitado,          --> Tabela de Rejeitados
                                       pr_tab_crawrej   => pr_tab_crawrej,            --> Tabela de Rejeitados
                                       pr_des_reto      => vr_des_reto);              --> Retorno OK/NOK
                                
          ---------------  Detalhe ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'Q' THEN
            
            -- Verificar se a cobranca foi rejeitada
            IF NOT vr_rec_cobranca.flgrejei THEN
              -- Processar apenas se não foi rejeitado a cobranca
              -- Se foi rejeitada ignora o processamento dessa cobranca para todas as linhas
              -- Ate encontrar a proxima cobranca com o segmento "P"
              
              -- Validar a linha para o Segmento "Q"
              pc_trata_segmento_q_240_01(pr_cdcooper      => pr_cdcooper,               --> Codigo da cooperativa
                                         pr_nrdconta      => pr_nrdconta,               --> Numero da conta do cooperado
                                         pr_dtmvtolt      => pr_dtmvtolt,               --> Data de movimento
                                         pr_cdoperad      => pr_cdoperad,               --> Operador
                                         pr_tab_linhas    => vr_tab_linhas(vr_idlinha), --> Dados da linha
                                         pr_rec_header    => vr_rec_header,             --> Dados do Header do Arquivo
                                         pr_tab_crawrej   => vr_tab_crawrej,            --> Tabela de rejeitados
                                         pr_rec_cobranca  => vr_rec_cobranca,           --> Dados da Cobranca
                                         pr_tab_rejeitado => vr_tab_rejeitado,          --> Tabela de Rejeitados
                                         pr_tab_sacado    => vr_tab_sacado,             --> Tabela de Sacados
                                         pr_des_reto      => pr_des_reto);
                   
             END IF;            
          
          END IF;
          
        END LOOP; --> Fim linhas arquivo
                
        -- Após finalizar as linhas do arquivo, temos que validar o ultimo titulo processado
        --> Cria o ultimo boleto ou gera instrucao apenas se nao tiver erros 
        IF vr_flgfirst AND NOT vr_rec_cobranca.flgrejei THEN
                      
           vr_dscritic:= '';
             
           -- Armazenar o boleto para gravacao ao fim do arquivo
           pc_grava_boleto(pr_rec_cobranca => vr_rec_cobranca,
                           pr_qtbloque     => vr_qtbloque, 
                           pr_vlrtotal     => vr_vlrtotal,
                           pr_tab_crapcob  => vr_tab_crapcob,
                           pr_dscritic     => vr_dscritic);
                             
           -- Se ocorreu erro durante o armazenamento do boleto grava o erro
           IF TRIM(vr_dscritic) IS NOT NULL THEN
             pc_grava_critica(pr_cdcooper => vr_rec_cobranca.cdcooper,
                              pr_nrdconta => vr_rec_cobranca.nrdconta,
                              pr_nrdocmto => vr_rec_cobranca.nrbloque,
                              pr_dscritic => vr_dscritic,
                              pr_tab_crawrej => pr_tab_crawrej);
                              
           END IF;                          
           
        END IF;
        
        --Armarzena quantidade de registros processados 
        vr_qtbloque := vr_qtdregis + vr_qtdinstr;
        
        --Armazena quantidade de registros com erro
        vr_qterro      := pr_tab_crawrej.count();      
        
        --> Apaga o Arquivo QUOTER
        vr_dscomand := 'rm -f '|| vr_tab_crapaux(i).nmarquiv || ' 2> /dev/null';
        
        gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic2);
              
        -- Verificar retorno de erro
        IF NVL(vr_typ_said, ' ') = 'ERR' THEN
          
          IF NVL(vr_cdcritic,0) = 0    AND
             TRIM(vr_dscritic) IS NULL THEN
            -- O comando shell executou com erro
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                  
          END IF;
          
          RAISE vr_exc_erro;
          
        END IF;
               
        IF vr_qtbloque > 0 THEN
          pc_protocolo_transacao(pr_cdcooper  => pr_cdcooper --> Codigo da cooperativa
                                ,pr_nrdconta  => pr_nrdconta --> Numero da conta do cooperado
                                ,pr_dtmvtolt  => pr_dtmvtolt --> Data de Movimento
                                ,pr_cddbanco  => vr_rec_header.cdbandoc --> Codigo do Banco
                                ,pr_nrconven  => vr_rec_header.nrcnvcob --> Numero do Convenio
                                ,pr_nrremass  => vr_rec_header.nrremass --> Numero da Remessa
                                ,pr_qtbloque  => vr_qtbloque --> Quantidade de Boletos Processados
                                ,pr_vlrtotal  => vr_vlrtotal --> Valor Totall dos Boletos
                                ,pr_nmarquiv  => vr_tab_crapaux(i).nmarqori --> Nome do Arquivo
                                ,pr_nrprotoc  => pr_nrprotoc --> Numero do Protocolo
                                ,pr_hrtransa  => pr_hrtransa --> Hora da transacao
                                ,pr_cdcritic  => vr_cdcritic --> Codigo da Critica
                                ,pr_dscritic  => vr_dscritic); --> Descricao da Critica
          
          -- Se ocorreu erro durante o armazenamento da instrucao grava o erro
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            pc_grava_critica(pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => pr_nrdconta,
                             pr_nrdocmto => 999999,
                             pr_dscritic => vr_dscritic || ' - Remessa: ' || vr_rec_header.nrremass,
                             pr_tab_crawrej => pr_tab_crawrej);

            --> Apaga o Arquivo
            vr_dscomand := 'rm '|| SUBSTR(STR1 => vr_tab_crapaux(i).nmarquiv, 
                                          POS => 1, 
                                          LEN => LENGTH(vr_tab_crapaux(i).nmarquiv)) || ' 2> /dev/null';
                                          
            gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                        pr_typ_saida   => vr_typ_said,
                                        pr_des_saida   => vr_dscritic2);
                  
            -- Verificar retorno de erro
            IF NVL(vr_typ_said, ' ') = 'ERR' THEN
              
              IF NVL(vr_cdcritic,0) = 0    AND
                 TRIM(vr_dscritic) IS NULL THEN
                -- O comando shell executou com erro
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                    
              END IF;
              
              RAISE vr_exc_erro;

            END IF;

            --> Apaga o Arquivo QUOTER
            vr_dscomand := 'rm -f '|| vr_tab_crapaux(i).nmarquiv || ' 2> /dev/null';
            gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                        pr_typ_saida   => vr_typ_said,
                                        pr_des_saida   => vr_dscritic2);
                  
            -- Verificar retorno de erro
            IF NVL(vr_typ_said, ' ') = 'ERR' THEN
              
              IF NVL(vr_cdcritic,0) = 0    AND
                 TRIM(vr_dscritic) IS NULL THEN
                -- O comando shell executou com erro
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                  
              END IF;
              
              RAISE vr_exc_erro;
              
            END IF;
            
            CONTINUE;
            
          END IF;
          
          -- Cria Lote de Remessa do Cooperado 
          pc_grava_rtc(pr_cdcooper  => pr_cdcooper, --> Codigo da cooperativa
                       pr_nrdconta  => pr_nrdconta, --> Numero da conta do cooperado
                       pr_nrcnvcob  => vr_rec_header.nrcnvcob, --> Numero do documento
                       pr_nrremass  => vr_rec_header.nrremass, --> Codigo de critica
                       pr_dtmvtolt  => pr_dtmvtolt, --> Data de Movimento
                       pr_nmarquiv  => vr_tab_crapaux(i).nmarqori, --> Nome do Arquivo
                       pr_cdoperad  => pr_cdoperad, --> Operador
                       pr_tab_crawrej => pr_tab_crawrej,     --> Tabela de Rejeitados
                       pr_des_reto  => vr_des_reto);--> Retorno OK/NOK
          
          -- Se ocorreu erro durante o armazenamento da instrucao grava o erro
          IF vr_des_reto <> 'OK' THEN
            
            --> Apaga o Arquivo
            vr_dscomand := 'rm '|| SUBSTR(STR1 => vr_tab_crapaux(i).nmarquiv, 
                                          POS => 1, 
                                          LEN => LENGTH(vr_tab_crapaux(i).nmarquiv)) || ' 2> /dev/null';
                                          
            gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                        pr_typ_saida   => vr_typ_said,
                                        pr_des_saida   => vr_dscritic2);
                  
            -- Verificar retorno de erro
            IF NVL(vr_typ_said, ' ') = 'ERR' THEN
              
              IF NVL(vr_cdcritic,0) = 0    AND
                 TRIM(vr_dscritic) IS NULL THEN
                -- O comando shell executou com erro
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                  
              END IF;
              
              RAISE vr_exc_erro;
              
            END IF;

            --> Apaga o Arquivo QUOTER
            vr_dscomand := 'rm -f '|| vr_tab_crapaux(i).nmarquiv || ' 2> /dev/null';
            gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                        pr_typ_saida   => vr_typ_said,
                                        pr_des_saida   => vr_dscritic2);
                  
            -- Verificar retorno de erro
            IF NVL(vr_typ_said, ' ') = 'ERR' THEN
              
              IF NVL(vr_cdcritic,0) = 0    AND
                 TRIM(vr_dscritic) IS NULL THEN
                -- O comando shell executou com erro
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                  
              END IF;
              
              RAISE vr_exc_erro;
              
            END IF;
            
            CONTINUE;
            
          END IF;
          
        END IF;
        
        -- Busca as informacoes
        OPEN cr_craprtc (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrcnvcob => vr_rec_header.nrcnvcob
                        ,pr_nrremret => vr_rec_header.nrremass
                        ,pr_intipmvt => 1);
                        
        FETCH cr_craprtc INTO rw_craprtc;
        
        IF cr_craprtc%FOUND THEN
          
          -- Fecha Cursor
          CLOSE cr_craprtc;
          
          -- Atualiza o registro
          UPDATE craprtc 
             SET craprtc.flgproce = 1 -- YES
                ,craprtc.qtreglot = vr_qtbloque
                ,craprtc.qttitcsi = vr_qtbloque
                ,craprtc.vltitcsi = vr_vlrtotal
                ,craprtc.dsprotoc = pr_nrprotoc
           WHERE craprtc.rowid = rw_craprtc.rowid;
           
        ELSE 
          -- Fecha Cursor
          CLOSE cr_craprtc;
          
          -- Cria Rejeitado
          pc_grava_critica(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdocmto => 999999,
                           pr_dscritic => 'Nenhum boleto foi processado!',
                           pr_tab_crawrej => pr_tab_crawrej);
                           
          CONTINUE;
          
        END IF;
        
        -- Limpar a tabela de tarifas
        vr_tab_lat_consolidada.DELETE;
        
        -- Apos a importacao, processar PL TABLE dos titulos
        pc_processa_titulos(pr_cdcooper    => pr_cdcooper,    --> Codigo da Cooperativa
                            pr_dtmvtolt    => pr_dtmvtolt,    --> Data de Movimento
                            pr_cdoperad    => pr_cdoperad,    --> Operador
                            pr_tab_crapcob => vr_tab_crapcob, --> Tabela de Cobranca
                            pr_rec_header  => vr_rec_header,  --> Dados do Header do Arquivo
                            pr_tab_lat_consolidada => vr_tab_lat_consolidada, --> Tabela tarifas
                            pr_cdcritic => vr_cdcritic,       --> Codigo da Critica
                            pr_dscritic => vr_dscritic);      --> Descricao da Critica
                            
        -- Se ocorreu critica escreve no proc_message.log
        -- Não para o processo
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_nmdatela, 'COBR0006') ||
                                                        ' --> COBR0006.pc_intarq_remes_cnab240_001 ' ||
                                                        ' ERRO no processamento dos titulos: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
          vr_cdcritic:= NULL;
          vr_dscritic:= NULL;
        END IF;
                            
        -- Apos a importacao, processar PL TABLE das instrucoes
        pc_processa_instrucoes(pr_cdcooper      => pr_cdcooper --> Codigo da Cooperativa
                              ,pr_dtmvtolt      => pr_dtmvtolt --> Data de Movimento
                              ,pr_cdoperad      => pr_cdoperad --> Operador
                              ,pr_tab_instrucao => vr_tab_instrucao --> Tabela de Cobranca
                              ,pr_rec_header    => vr_rec_header    --> Dados do Header do Arquivo
                              ,pr_tab_rejeitado => vr_tab_rejeitado --> Tabela de rejeitados
                              ,pr_tab_lat_consolidada => vr_tab_lat_consolidada --> Tabela tarifas
                              ,pr_cdcritic      => vr_cdcritic   --> Codigo da Critica
                              ,pr_dscritic      => vr_dscritic); --> Descricao da Critica
                              
        -- Se ocorreu critica escreve no proc_message.log
        -- Não para o processo
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_nmdatela, 'COBR0006') || ' --> COBR0006.pc_intarq_remes_cnab240_001' ||
                                                        ' ERRO no processamento das instrucoes: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
          vr_cdcritic:= NULL;
          vr_dscritic:= NULL;
        END IF;
                 
        -- Apos a importacao, processar PL TABLE de rejeitados
        pc_processa_rejeitados (pr_tab_rejeitado => vr_tab_rejeitado --> Tabela de rejeitados
                               ,pr_cdcritic      => vr_cdcritic   --> Codigo da Critica
                               ,pr_dscritic      => vr_dscritic); --> Descricao da Critica
                               
        -- Se ocorreu critica escreve no proc_message.log
        -- Não para o processo
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_nmdatela, 'COBR0006') || ' --> COBR0006.pc_intarq_remes_cnab240_001' ||
                                                        ' ERRO no processamento dos rejeitados: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
          vr_cdcritic:= NULL;
          vr_dscritic:= NULL;
        END IF;
                            
        -- Apos a importacao, processar PL TABLE de sacados
        pc_processa_sacados(pr_tab_sacado => vr_tab_sacado --> Tabela de sacados
                           ,pr_cdcritic   => vr_cdcritic   --> Codigo da Critica
                           ,pr_dscritic   => vr_dscritic); --> Descricao da Critica
                           
        -- Se ocorreu critica escreve no proc_message.log
        -- Não para o processo
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_nmdatela, 'COBR0006') || ' --> COBR0006.pc_intarq_remes_cnab240_001' ||
                                                        ' ERRO no processamento dos sacados: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
          vr_cdcritic:= NULL;
          vr_dscritic:= NULL;
        END IF;
        
        PAGA0001.pc_efetua_lancto_tarifas_lat(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_intarq_remes_cnab240_001');

        -- Se ocorreu critica escreve no proc_message.log
        -- Não para o processo
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_nmdatela, 'COBR0006') || ' --> COBR0006.pc_intarq_remes_cnab240_001' ||
                                                        ' ERRO no lancamento de tarifas: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
          vr_cdcritic:= NULL;
          vr_dscritic:= NULL;
          
        END IF;
        
      END IF;
      
    END LOOP;--> Fim arquivos
    
    IF pr_tab_crawrej.count = 0 THEN
      --Finaliza o processo de monitoramento para o Aymaru
      pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                          ,pr_nrdconta  => pr_nrdconta --> Número da conta
                          ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                          ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                          ,pr_tpoperac  => 2           --> Tipo de operação
                          ,pr_flgerro   => 0           --> Sem erros
                          ,pr_nmarquiv  => pr_nmarquiv --> Nome do arquivo
                          ,pr_dslogerro => 'Arquivo importado com sucesso' --> Descrição do erro
                          ,pr_qtprocessado => vr_qtbloque     --> Quantidade de registros processados
                          ,pr_qterro       => vr_qterro       --> Quantidade de registros com erro
                          ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                          ,pr_rowid_item_resumo => vr_rowid_item_resumo); 
    ELSE
      --Finaliza o processo de monitoramento para o Aymaru
      pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                          ,pr_nrdconta  => pr_nrdconta --> Número da conta
                          ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                          ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                          ,pr_tpoperac  => 2           --> Tipo de operação
                          ,pr_flgerro   => 1           --> Com erros
                          ,pr_nmarquiv  => pr_nmarquiv --> Nome do arquivo
                          ,pr_dslogerro => pr_tab_crawrej(pr_tab_crawrej.last).dscritic --> Descrição do erro
                          ,pr_qtprocessado => vr_qtbloque     --> Quantidade de registros processados
                          ,pr_qterro       => vr_qterro       --> Quantidade de registros com erro
                          ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                          ,pr_rowid_item_resumo => vr_rowid_item_resumo); 
    END IF;
                            
    COMMIT;
    npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'COBR006_1');
    
    pr_des_reto := 'OK';
    
    gene0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION  
    WHEN vr_exc_saida THEN
      gene0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

      --> Gravar critica
      pc_grava_critica( pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_nrdocmto => vr_nrdoccri,
                        pr_dscritic => vr_dscritic,
                        pr_tab_crawrej => pr_tab_crawrej); 
                        
      pr_des_reto := 'NOK';
      
      --Finaliza o processo de monitoramento para o Aymaru
      pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                          ,pr_nrdconta  => pr_nrdconta --> Número da conta
                          ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                          ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                          ,pr_tpoperac  => 2           --> Tipo de operação
                          ,pr_flgerro   => 1           --> Com erros
                          ,pr_nmarquiv  => pr_nmarquiv --> Nome do arquivo
                          ,pr_dslogerro => vr_dscritic --> Descrição do erro
                          ,pr_qtprocessado => vr_qtbloque     --> Quantidade de registros processados
                          ,pr_qterro       => vr_qterro       --> Quantidade de registros com erro
                          ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                          ,pr_rowid_item_resumo => vr_rowid_item_resumo); 
      
      -- Efetuar rollback
      ROLLBACK;
      npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'COBR006_2');
      
    WHEN vr_exc_erro THEN
      gene0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      
      pr_des_reto := 'NOK';
      
      --Finaliza o processo de monitoramento para o Aymaru
      pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                          ,pr_nrdconta  => pr_nrdconta --> Número da conta
                          ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                          ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                          ,pr_tpoperac  => 2           --> Tipo de operação
                          ,pr_flgerro   => 1           --> Com erros
                          ,pr_nmarquiv  => pr_nmarquiv --> Nome do arquivo
                          ,pr_dslogerro => vr_dscritic --> Descrição do erro
                          ,pr_qtprocessado => vr_qtbloque     --> Quantidade de registros processados
                          ,pr_qterro       => vr_qterro       --> Quantidade de registros com erro
                          ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                          ,pr_rowid_item_resumo => vr_rowid_item_resumo); 
      
      -- Efetuar rollback
      ROLLBACK;
      npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'COBR006_3');
    WHEN OTHERS THEN
      cecred.pc_internal_exception;

      gene0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      
      pr_des_reto := 'NOK';
      
      --Finaliza o processo de monitoramento para o Aymaru
      pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                          ,pr_nrdconta  => pr_nrdconta --> Número da conta
                          ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                          ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                          ,pr_tpoperac  => 2           --> Tipo de operação
                          ,pr_flgerro   => 1           --> Com erros
                          ,pr_nmarquiv  => pr_nmarquiv --> Nome do arquivo
                          ,pr_dslogerro => vr_dscritic --> Descrição do erro
                          ,pr_qtprocessado => vr_qtbloque     --> Quantidade de registros processados
                          ,pr_qterro       => vr_qterro       --> Quantidade de registros com erro
                          ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                          ,pr_rowid_item_resumo => vr_rowid_item_resumo); 
      
      -- Efetuar rollback
      ROLLBACK;  
      npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'COBR006_4');
      
  END pc_intarq_remes_cnab240_001;
  
  --> Integrar/processar arquivo de remessa cnab240_085
  PROCEDURE pc_intarq_remes_cnab240_085(  pr_cdcooper  IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                                          pr_nrdconta  IN crapass.nrdconta%TYPE, --> Numero da conta do cooperado
                                          pr_nmarquiv  IN VARCHAR2,              --> Nome do arquivo a ser importado               
                                          pr_idorigem  IN INTEGER,               --> Identificador de origem
                                          pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE, --> Data do movimento
                                          pr_cdoperad  IN crapope.cdoperad%TYPE, --> Codigo do operador
                                          pr_nmdatela  IN VARCHAR2,              --> Nome da Tela
                                          ------> OUT <------
                                          pr_tab_crawrej IN OUT NOCOPY typ_tab_crawrej, --> Tabela de Rejeitados
                                          pr_hrtransa OUT INTEGER,               --> Hora da transacao
                                          pr_nrprotoc OUT VARCHAR2,              --> Numero do Protocolo
                                          pr_des_reto OUT VARCHAR2,              --> OK ou NOK
                                          pr_cdcritic OUT INTEGER,               --> Codigo de critica
                                          pr_dscritic OUT VARCHAR2               --> Descricao da critica
                                          ) IS
                                   
  /* ............................................................................

       Programa: pc_intarq_remes_cnab240_085         antiga: b1wgen0090.p/p_integra_arq_remessa_cnab240_085
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana - AMcom
       Data    : Novembro/2015.                   Ultima atualizacao: 13/02/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel pode integrar o arquivo de remessa de cobrança
                   no padrão CNAB240 para boletos 085

       Alteracoes: 25/11/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)
       
                   17/08/2016 - Ajuste para enviar o nome original do arquivo para emissao do protocolo
                                (Andrei - RKAM).
                                
                   29/12/2016 - P340 - Ajustes para validação e envio a CIP;
                                (Ricardo Linhares)
                                
                   13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 

                   09/11/2017 - Inclusão de chamada da procedure npcb0002.pc_libera_sessao_sqlserver_npc.
                                (SD#791193 - AJFink)

				   20/08/2018 - Foi incluido a validação do segmento Q
							    (Felipe - Mouts).

    ............................................................................ */   
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro     EXCEPTION;
    vr_exc_saida    EXCEPTION;
    vr_cdcritic     PLS_INTEGER;
    vr_dscritic     VARCHAR2(4000);
    vr_dscritic2    VARCHAR2(4000);
    vr_des_reto     VARCHAR2(400);
	vr_rej_cdmotivo VARCHAR2(2);
    vr_nrdoccri     crapcob.nrdocmto%TYPE;

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    rw_craprtc COBR0006.cr_craprtc%ROWTYPE;
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    vr_tab_listarqu  gene0002.typ_split;
    vr_tab_crapaux   typ_tab_crawaux;
    vr_tab_linhas    gene0009.typ_tab_linhas;
    vr_rec_header    typ_rec_header;
    vr_rec_cobranca  typ_rec_cobranca;
    vr_tab_crapcob   typ_tab_crapcob;
    vr_tab_instrucao typ_tab_instrucao;
    vr_tab_rejeitado typ_tab_rejeitado;
    vr_tab_sacado    typ_tab_sacado;
    vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_dstextab     craptab.dstextab%TYPE;
    vr_diasvcto     INTEGER;
    
    vr_dscomand     VARCHAR2(4000);
    vr_typ_said     VARCHAR2(500);
    vr_setlinha     VARCHAR2(500);
    
    vr_dsdireto     VARCHAR2(500);
    vr_dsdircop     VARCHAR2(500);
    vr_nmarquiv     VARCHAR2(500);
    vr_nmfisico     VARCHAR2(500);
    vr_listarqu     VARCHAR2(4000);
    vr_contador     INTEGER := 0;
    vr_idxarq       PLS_INTEGER;
    vr_flgfirst     BOOLEAN := FALSE;
	vr_flgseqq      BOOLEAN := FALSE;

    vr_qtbloque     INTEGER := 0;
    vr_qtdregis     INTEGER := 0;
    vr_qtdinstr     INTEGER := 0;
    vr_vlrtotal     NUMBER  := 0;
    vr_qterro       INTEGER := 0;
    vr_rowid_resumo      ROWID;
    vr_rowid_item_resumo ROWID;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
  BEGIN

    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_intarq_remes_cnab240_085');

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
                            
    --> Buscar parametro de vencimento
    vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => 3, 
                                               pr_nmsistem => 'CRED', 
                                               pr_tptabela => 'GENERI', 
                                               pr_cdempres => 0, 
                                               pr_cdacesso => 'DIASVCTOCEE', 
                                               pr_tpregist => 0);
    IF TRIM(vr_dstextab) IS NULL THEN
      vr_dscritic := 'Tabela com parametro vencimento nao encontrado.';
      RAISE vr_exc_erro;
    END IF;
    
    --> buscar diretorio da cooperativa
    vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C', 
                                         pr_cdcooper => pr_cdcooper, 
                                         pr_nmsubdir => NULL);
    
    
    vr_diasvcto := SUBSTR(vr_dstextab,1,2);
    
    -- separa diretorio e nmarquivo
    gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmarquiv, 
                                    pr_direto  => vr_dsdireto, 
                                    pr_arquivo => vr_nmarquiv);
    
    -- Buscar arquivo a ser importado
    gene0001.pc_lista_arquivos(pr_path     => vr_dsdireto
                              ,pr_pesq     => vr_nmarquiv
                              ,pr_listarq  => vr_listarqu
                              ,pr_des_erro => vr_dscritic);

    -- Se ocorrer erro ao recuperar lista de arquivos, registra no log
    IF TRIM(vr_dscritic) IS NOT NULL THEN 
      vr_dscritic := 'Nao foi possivel localizar arquivo '||pr_nmarquiv||': '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    
    --Inicia o processo de monitoramento para o Aymaru
    pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                        ,pr_nrdconta  => pr_nrdconta --> Número da conta
                        ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                        ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                        ,pr_tpoperac  => 1           --> Tipo de operação
                        ,pr_flgerro   => 0           --> Sem erros
                        ,pr_nmarquiv  => vr_nmarquiv --> Nome do arquivo
                        ,pr_dslogerro => ''          --> Descrição do erro
                        ,pr_qtprocessado => 0        --> Quantidade de registros processados
                        ,pr_qterro       => 0        --> Quantidade de registros com erro
                        ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                        ,pr_rowid_item_resumo => vr_rowid_item_resumo);
                        
    vr_tab_listarqu := gene0002.fn_quebra_string(pr_string => vr_listarqu,
                                                 pr_delimit => ',');
    
    vr_contador := 0;
                                            
    IF vr_tab_listarqu.count > 0 THEN
      --> Varrer arquivos
      FOR i IN vr_tab_listarqu.first..vr_tab_listarqu.last LOOP
        
        vr_contador := vr_contador + 1;
        vr_nmfisico := vr_dsdircop||'/integra/cobran'|| to_char(pr_dtmvtolt,'DDMMRR')||
                       '_'|| to_char(vr_contador,'fm0000') ||'_'||to_char(pr_nrdconta,'fm00000000');
        
        --> Controlar tamanho do arquivo
        IF length(vr_tab_listarqu(i)) > 90  THEN
          
          vr_cdcritic := 999;
          vr_dscritic := 'Nome do Arquivo muito grande';
          vr_nrdoccri := 0;      
          RAISE vr_exc_saida;
          
        END IF;
        
        vr_dscomand := 'dos2ux ' || vr_dsdireto || '/' || vr_tab_listarqu(i) ||' > ' || vr_nmfisico;

        -- Converte o arquivo de DOS para Unix
        gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic);
        
        -- Verificar retorno de erro
        IF NVL(vr_typ_said, ' ') = 'ERR' THEN
          -- O comando shell executou com erro
          vr_cdcritic := 0;
          vr_dscritic := 'Erro dos2ux arquivos: '||vr_dscritic;
          RAISE vr_exc_erro;
        END IF;
        
        -- Comando para listar a primeira linha do arquivo
        vr_dscomand:= 'head -1 ' ||vr_nmfisico;

        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_dscomand
                             ,pr_typ_saida   => vr_typ_said
                             ,pr_des_saida   => vr_setlinha);
        --Se ocorreu erro dar RAISE
        IF vr_typ_said = 'ERR' THEN
          vr_dscritic:= 'Não foi possivel executar comando unix. '||vr_dscomand;
          RAISE vr_exc_erro;
        END IF;
        
        --> Verificar tamanho da linha do arquivo (padrao cnab240)
        IF length(vr_setlinha) > 243 THEN
        
          vr_cdcritic := 999;
          vr_dscritic := 'Arquivo fora do formato';
          vr_nrdoccri := 0;      
          RAISE vr_exc_saida;
        
        END IF;
        
        vr_idxarq := vr_tab_crapaux.count;
        vr_tab_crapaux(vr_idxarq).nrsequen := SUBSTR(vr_setlinha,158,06);
        vr_tab_crapaux(vr_idxarq).nmarquiv := vr_nmfisico;
        vr_tab_crapaux(vr_idxarq).nmarqori := SUBSTR(pr_nmarquiv,INSTR(pr_nmarquiv,'/',-1)+1);
        
        vr_flgfirst := TRUE;
      END LOOP;
    END IF;
    
    IF NOT vr_flgfirst  THEN    
      vr_cdcritic := 887; --> Identificacao do arquivo Invalida 
      vr_nrdoccri := 0;
      RAISE vr_exc_saida;   
    END IF;
   
    vr_qtbloque := 0;
    vr_qtdregis := 0;
    vr_qtdinstr := 0;
    
    -- Processar arquivos
    FOR i IN vr_tab_crapaux.first..vr_tab_crapaux.last LOOP
      
      vr_flgfirst := FALSE;
      vr_vlrtotal := 0;
      vr_tab_linhas.delete;
      
      -- separa diretorio e nmarquivo
      gene0001.pc_separa_arquivo_path(pr_caminho => vr_tab_crapaux(i).nmarquiv, 
                                      pr_direto  => vr_dsdireto, 
                                      pr_arquivo => vr_nmarquiv);
      
      --> Ler arquivo conforme configurado no cadastro de layout 
      gene0009.pc_importa_arq_layout( pr_nmlayout   => 'CNAB240',      --> Nome do Layout do arquivo a ser importado
                                      pr_dsdireto   => vr_dsdireto,    --> Descrição do diretorio onde o arquivo se enconta
                                      pr_nmarquiv   => vr_nmarquiv,    --> Nome do arquivo a ser importado
                                      -----> OUT <------ 
                                      pr_dscritic   => vr_dscritic,    --> Retorna critica Caso ocorra
                                      pr_tab_linhas => vr_tab_linhas); --> Retorna as linhas/campos do arquivo na temptable
                                      
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      IF vr_tab_linhas.count = 0 THEN
        vr_cdcritic := 999;
        vr_dscritic := 'Arquivo vazio.';
        vr_nrdoccri := 0;      
        RAISE vr_exc_saida;  
      ELSE
        -- Antes de iniciar o processamento do layout CNAB240, vamos limpar a PL TABLE
        vr_tab_crapcob.delete;  
        vr_tab_instrucao.delete;
        vr_tab_rejeitado.delete;
        vr_tab_sacado.delete;
      
        --> Varrer linhas do arquivo
        FOR vr_idlinha IN vr_tab_linhas.first..vr_tab_linhas.last LOOP
          
		      --Gerar critica do arquivo quando os erros forem nos HA, HL, TL, TA;
          IF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto IN ('HA','HL','TL','TA') THEN
             IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
               vr_dscritic := 'Linha '||vr_idlinha||' '|| vr_tab_linhas(vr_idlinha)('$ERRO$').texto;
               vr_nrdoccri := 0;      
               RAISE vr_exc_saida;
   			     END IF;
          END IF;
          
		  -- Validação do segmento Q, Após o segundo segmento P ele verifica se 
          -- o segmento P anterior teve segmento Q
          IF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'P' AND vr_idlinha > 3 AND NOT vr_flgseqq THEN
            vr_rej_cdmotivo := '03'; 
            pc_valida_grava_rejeitado(pr_cdcooper      => vr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => vr_rec_cobranca.nrdconta --> Numero da Conta
                               ,pr_nrcnvcob      => vr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => vr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => vr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => vr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => vr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => vr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => vr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => vr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => vr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => vr_tab_rejeitado);       --> Tabela de Rejeitados
          END IF;



          -------------------  Header do Arquivo --------------------
          IF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'HA' THEN 
            
            pc_trata_header_arq_240_85 (pr_cdcooper   => pr_cdcooper,               --> Codigo da cooperativa
                                        pr_nrdconta   => pr_nrdconta,               --> Numero da conta do cooperado
                                        pr_tab_linhas => vr_tab_linhas(vr_idlinha), --> Dados da linha
                                        pr_rec_header => vr_rec_header,             --> Dados do Header
                                        pr_cdcritic   => vr_cdcritic,               --> Codigo de critica
                                        pr_dscritic   => vr_dscritic,               --> Descricao da critica
                                        pr_des_reto   => vr_des_reto );             --> Retorno OK/NOK
                                  
            IF vr_des_reto <> 'OK' THEN
              
              --> Remover arquivo 
              vr_dscomand := 'rm -f '|| vr_tab_crapaux(i).nmarquiv;
              gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                          pr_typ_saida   => vr_typ_said,
                                          pr_des_saida   => vr_dscritic2);
              
              -- Verificar retorno de erro
              IF NVL(vr_typ_said, ' ') = 'ERR' THEN
                
                IF NVL(vr_cdcritic,0) = 0    AND
                   TRIM(vr_dscritic) IS NULL THEN
                   
                  -- O comando shell executou com erro
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;

                END IF;
                 
                RAISE vr_exc_erro;
                
              END IF;
        
              RAISE vr_exc_saida;
              
            END IF;
            
            -- Se nao ocorreu erro no header, carrega as informacoes de banco
            vr_rec_header.cdbcoctl := rw_crapcop.cdbcoctl;
            vr_rec_header.cdagectl := rw_crapcop.cdagectl;
            
            -- atribui regra para envio a CIP
            vr_rec_cobranca.inenvcip := 1; -- a enviar
            
          --------------------  Header do Arquivo ---------------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'HL' THEN   
          
            pc_trata_header_lote_240_85(pr_cdcooper   => pr_cdcooper,               --> Codigo da cooperativa
                                        pr_nrdconta   => pr_nrdconta,               --> Numero da conta do cooperado
                                        pr_nrconven   => vr_rec_header.nrcnvcob,    --> numero do convenio
                                        pr_tab_linhas => vr_tab_linhas(vr_idlinha), --> Dados da linha
                                        pr_cdcritic   => vr_cdcritic,               --> Codigo de critica
                                        pr_dscritic   => vr_dscritic,               --> Descricao da critica
                                        pr_des_reto   => vr_des_reto );             --> Retorno OK/NOK
                                  
            IF vr_des_reto <> 'OK' THEN
              
              --> Remover arquivo 
              vr_dscomand := 'rm -f '|| vr_tab_crapaux(i).nmarquiv;
              gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                          pr_typ_saida   => vr_typ_said,
                                          pr_des_saida   => vr_dscritic2);
              
              -- Verificar retorno de erro
              IF NVL(vr_typ_said, ' ') = 'ERR' THEN
                
                IF NVL(vr_cdcritic,0) = 0    AND
                   TRIM(vr_dscritic) IS NULL THEN
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                  
                END IF;
                
                RAISE vr_exc_erro;
                
              END IF;
        
              RAISE vr_exc_saida;
              
            END IF; 
            
          ---------------  Detalhe ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'P' THEN    
          
		    vr_flgseqq := FALSE;
            -- Processar o Segmento "P"            
            pc_trata_segmento_p_240_85(pr_cdcooper      => pr_cdcooper,               --> Codigo da cooperativa
                                       pr_nrdconta      => pr_nrdconta,               --> Numero da conta do cooperado
                                       pr_dtmvtolt      => pr_dtmvtolt,               --> Data de Movimento
                                       pr_cdoperad      => pr_cdoperad,               --> Operador
                                       pr_diasvcto      => vr_diasvcto,               --> Dias de vr_diasvctoencimento
                                       pr_flgfirst      => vr_flgfirst,               --> controle de primeiro registro
                                       pr_tab_linhas    => vr_tab_linhas(vr_idlinha), --> Dados da linha
                                       pr_rec_header    => vr_rec_header,             --> Dados do Header do Arquivo
                                       pr_qtdregis      => vr_qtdregis,               --> contador de registro
                                       pr_qtdinstr      => vr_qtdinstr,               --> contador de instucoes
                                       pr_qtbloque      => vr_qtbloque,               --> contador de boletos processados
                                       pr_vlrtotal      => vr_vlrtotal,               --> Valor total dos boletos
                                       pr_rec_cobranca  => vr_rec_cobranca,           --> Dados da Cobranca
                                       pr_tab_crapcob   => vr_tab_crapcob,            --> Tabela de Cobranca
                                       pr_tab_instrucao => vr_tab_instrucao,          --> Tabela de Instrucoes
                                       pr_tab_rejeitado => vr_tab_rejeitado,          --> Tabela de Rejeitados
                                       pr_tab_crawrej   => pr_tab_crawrej,            --> Tabela de Rejeitados
                                       pr_des_reto      => vr_des_reto);              --> Retorno OK/NOK
                                
          ---------------  Detalhe ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'Q' THEN
             
			 vr_flgseqq := TRUE;
            -- Verificar se a cobranca foi rejeitada
            IF NOT vr_rec_cobranca.flgrejei THEN
              -- Processar apenas se não foi rejeitado a cobranca
              -- Se foi rejeitada ignora o processamento dessa cobranca para todas as linhas
              -- Ate encontrar a proxima cobranca com o segmento "P"
              
              -- Validar a linha para o Segmento "Q"
              pc_trata_segmento_q_240_85(pr_cdcooper      => pr_cdcooper,               --> Codigo da cooperativa
                                         pr_nrdconta      => pr_nrdconta,               --> Numero da conta do cooperado
                                         pr_dtmvtolt      => pr_dtmvtolt,               --> Data de movimento
                                         pr_cdoperad      => pr_cdoperad,               --> Operador
                                         pr_tab_linhas    => vr_tab_linhas(vr_idlinha), --> Dados da linha
                                         pr_rec_header    => vr_rec_header,             --> Dados do Header do Arquivo
                                         pr_rec_cobranca  => vr_rec_cobranca,           --> Dados da Cobranca
                                         pr_tab_rejeitado => vr_tab_rejeitado,          --> Tabela de Rejeitados
                                         pr_tab_sacado    => vr_tab_sacado,             --> Tabela de Sacados
                                         pr_des_reto      => pr_des_reto);
             
             END IF;
            
          ---------------  Detalhe ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'R' THEN
            
            -- Verificar se a cobranca foi rejeitada
            IF NOT vr_rec_cobranca.flgrejei THEN
              -- Processar apenas se não foi rejeitado a cobranca
              -- Se foi rejeitada ignora o processamento dessa cobranca para todas as linhas
              -- Ate encontrar a proxima cobranca com o segmento "P"
            
              -- Validar a linha para o Segmento "R"
              pc_trata_segmento_r_240_85 (pr_cdcooper      => pr_cdcooper,               --> Codigo da cooperativa
                                          pr_nrdconta      => pr_nrdconta,               --> Numero da conta do cooperado
                                          pr_dtmvtolt      => pr_dtmvtolt,               --> Data de movimento
                                          pr_cdoperad      => pr_cdoperad,               --> Operador
                                          pr_tab_linhas    => vr_tab_linhas(vr_idlinha), --> Dados da linha
                                          pr_rec_header    => vr_rec_header,             --> Dados do Header do Arquivo
                                          pr_rec_cobranca  => vr_rec_cobranca,           --> Dados da Cobranca
                                          pr_tab_rejeitado => vr_tab_rejeitado,          --> Tabela de Rejeitados
                                          pr_des_reto      => vr_des_reto);                --> Retorno OK/NOK
            END IF;
          ---------------  Detalhe ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'S' THEN
            
            -- Verificar se a cobranca foi rejeitada
            IF NOT vr_rec_cobranca.flgrejei THEN
              -- Processar apenas se não foi rejeitado a cobranca
              -- Se foi rejeitada ignora o processamento dessa cobranca para todas as linhas
              -- Ate encontrar a proxima cobranca com o segmento "P"
              
              -- Validar a linha para o Segmento "S"
              pc_trata_segmento_s_240_85 (pr_cdcooper      => pr_cdcooper,               --> Codigo da cooperativa
                                          pr_nrdconta      => pr_nrdconta,               --> Numero da conta do cooperado
                                          pr_dtmvtolt      => pr_dtmvtolt,               --> Data de movimento
                                          pr_cdoperad      => pr_cdoperad,               --> Operador
                                          pr_rec_header    => vr_rec_header,             --> Dados do Header do Arquivo
                                          pr_tab_linhas    => vr_tab_linhas(vr_idlinha), --> Dados da linha
                                          pr_rec_cobranca  => vr_rec_cobranca,           --> Dados da Cobranca
                                          pr_tab_rejeitado => vr_tab_rejeitado,          --> Tabela de Rejeitados
                                          pr_des_reto      => vr_des_reto);              --> Retorno OK/NOK
            END IF;

          ---------------  Detalhe ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'Y04' THEN
            
            -- Verificar se a cobranca foi rejeitada
            IF NOT vr_rec_cobranca.flgrejei THEN
              -- Processar apenas se não foi rejeitado a cobranca
              -- Se foi rejeitada ignora o processamento dessa cobranca para todas as linhas
              -- Ate encontrar a proxima cobranca com o segmento "P"
              
              -- Validar a linha para o Segmento "Y-04"
              pc_trata_segmento_y04_240_85 (pr_cdcooper      => pr_cdcooper,               --> Codigo da cooperativa
                                            pr_nrdconta      => pr_nrdconta,               --> Numero da conta do cooperado
                                            pr_dtmvtolt      => pr_dtmvtolt,               --> Data de movimento
                                            pr_cdoperad      => pr_cdoperad,               --> Operador
                                            pr_rec_header    => vr_rec_header,             --> Dados do Header do Arquivo
                                            pr_tab_linhas    => vr_tab_linhas(vr_idlinha), --> Dados da linha
                                            pr_rec_cobranca  => vr_rec_cobranca,           --> Dados da Cobranca
                                            pr_tab_sacado    => vr_tab_sacado,             --> Tabela de Sacados
                                            pr_tab_rejeitado => vr_tab_rejeitado,          --> Tabela de Rejeitados
                                            pr_des_reto      => vr_des_reto);              --> Retorno OK/NOK
            END IF;
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'Y53' THEN
            
            -- Verificar se a cobranca foi rejeitada
            IF NOT vr_rec_cobranca.flgrejei THEN
              -- Processar apenas se não foi rejeitado a cobranca
              -- Se foi rejeitada ignora o processamento dessa cobranca para todas as linhas
              -- Ate encontrar a proxima cobranca com o segmento "P"
              
              -- Validar a linha para o Segmento "Y-53"
              pc_trata_segmento_y53_240_85 (pr_cdcooper      => pr_cdcooper,               --> Codigo da cooperativa
                                            pr_nrdconta      => pr_nrdconta,               --> Numero da conta do cooperado
                                            pr_dtmvtolt      => pr_dtmvtolt,               --> Data de movimento
                                            pr_cdoperad      => pr_cdoperad,               --> Operador
                                            pr_rec_header    => vr_rec_header,             --> Dados do Header do Arquivo
                                            pr_tab_linhas    => vr_tab_linhas(vr_idlinha), --> Dados da linha
                                            pr_rec_cobranca  => vr_rec_cobranca,           --> Dados da Cobranca
                                            pr_tab_rejeitado => vr_tab_rejeitado,          --> Tabela de Rejeitados
                                            pr_des_reto      => vr_des_reto);              --> Retorno OK/NOK
            END IF;
            
            
          END IF;
          
        END LOOP; --> Fim linhas arquivo

		-- verifica o segmento Q, como ele verifica o segmento P anterior, ao final
		-- do loop e necessario validar o ultimo segmento processado
        IF NOT vr_flgseqq THEN 
          
          vr_rej_cdmotivo := '03'; 
          pc_valida_grava_rejeitado(pr_cdcooper      => vr_rec_cobranca.cdcooper --> Codigo da Cooperativa
                               ,pr_nrdconta      => vr_rec_cobranca.nrdconta --> Numero da Conta
                               ,pr_nrcnvcob      => vr_rec_cobranca.nrcnvcob --> Numero do Convenio
                               ,pr_vltitulo      => vr_rec_cobranca.vltitulo --> Valor do Titulo
                               ,pr_cdbcoctl      => vr_rec_header.cdbcoctl   --> Codigo do banco na central
                               ,pr_cdagectl      => vr_rec_header.cdagectl   --> Codigo da Agencial na central
                               ,pr_nrnosnum      => vr_rec_cobranca.dsnosnum --> Nosso Numero
                               ,pr_dsdoccop      => vr_rec_cobranca.dsdoccop --> Descricao do Documento
                               ,pr_nrremass      => vr_rec_header.nrremass   --> Numero da Remessa
                               ,pr_dtvencto      => vr_rec_cobranca.dtvencto --> Data de Vencimento
                               ,pr_dtmvtolt      => pr_dtmvtolt              --> Data de Movimento
                               ,pr_cdoperad      => pr_cdoperad              --> Operador
                               ,pr_cdocorre      => vr_rec_cobranca.cdocorre --> Codigo da Ocorrencia
                               ,pr_cdmotivo      => vr_rej_cdmotivo          --> Motivo da Rejeicao
                               ,pr_tab_rejeitado => vr_tab_rejeitado);       --> Tabela de Rejeitados
          vr_rec_cobranca.flgrejei:= TRUE;
      
        END IF; 

        
        -- Após finalizar as linhas do arquivo, temos que validar o ultimo titulo processado
        --> Cria o ultimo boleto ou gera instrucao apenas se nao tiver erros 
        IF vr_flgfirst AND NOT vr_rec_cobranca.flgrejei THEN
           
           --> 01 - Solicitacao de Remessa 
           IF vr_rec_cobranca.cdocorre = 1 THEN
             
             vr_dscritic:= '';
             -- Armazenar o boleto para gravacao ao fim do arquivo
             pc_grava_boleto(pr_rec_cobranca => vr_rec_cobranca,
                             pr_qtbloque     => vr_qtbloque, 
                             pr_vlrtotal     => vr_vlrtotal,
                             pr_tab_crapcob  => vr_tab_crapcob,
                             pr_dscritic     => vr_dscritic);
                             
             -- Se ocorreu erro durante o armazenamento do boleto grava o erro
             IF TRIM(vr_dscritic) IS NOT NULL THEN
               pc_grava_critica(pr_cdcooper => vr_rec_cobranca.cdcooper,
                                pr_nrdconta => vr_rec_cobranca.nrdconta,
                                pr_nrdocmto => vr_rec_cobranca.nrbloque,
                                pr_dscritic => vr_dscritic,
                                pr_tab_crawrej => pr_tab_crawrej);
             END IF;
           ELSE
             vr_dscritic:= '';
             -- Armazenar a instrucao para gravacao ao fim do arquivo
             pc_grava_instrucao(pr_rec_cobranca  => vr_rec_cobranca,
                                pr_tab_instrucao => vr_tab_instrucao,
                                pr_dscritic      => vr_dscritic);  
                                
             -- Se ocorreu erro durante o armazenamento da instrucao grava o erro
             IF TRIM(vr_dscritic) IS NOT NULL THEN
               pc_grava_critica(pr_cdcooper => vr_rec_cobranca.cdcooper,
                                pr_nrdconta => vr_rec_cobranca.nrdconta,
                                pr_nrdocmto => vr_rec_cobranca.nrbloque,
                                pr_dscritic => vr_dscritic,
                                pr_tab_crawrej => pr_tab_crawrej);
             END IF;
           END IF;       
        END IF;
        
        --Armarzena quantidade de registros processados
        vr_qtbloque := vr_qtdregis + vr_qtdinstr; 
        
        --Armazena quantidade de registros com erro
        vr_qterro      := vr_tab_rejeitado.count();        
        
        --> Apaga o Arquivo QUOTER
        vr_dscomand := 'rm -f '|| vr_tab_crapaux(i).nmarquiv || ' 2> /dev/null';
        
        gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic2);
              
        -- Verificar retorno de erro
        IF NVL(vr_typ_said, ' ') = 'ERR' THEN
          
          IF NVL(vr_cdcritic,0) = 0    AND
             TRIM(vr_dscritic) IS NULL THEN
            -- O comando shell executou com erro
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                  
          END IF;
          
          RAISE vr_exc_erro;
          
        END IF;
        
        IF vr_qtbloque > 0 THEN
          pc_protocolo_transacao(pr_cdcooper  => pr_cdcooper --> Codigo da cooperativa
                                ,pr_nrdconta  => pr_nrdconta --> Numero da conta do cooperado
                                ,pr_dtmvtolt  => pr_dtmvtolt --> Data de Movimento
                                ,pr_cddbanco  => vr_rec_header.cdbandoc --> Codigo do Banco
                                ,pr_nrconven  => vr_rec_header.nrcnvcob --> Numero do Convenio
                                ,pr_nrremass  => vr_rec_header.nrremass --> Numero da Remessa
                                ,pr_qtbloque  => vr_qtbloque --> Quantidade de Boletos Processados
                                ,pr_vlrtotal  => vr_vlrtotal  --> Valor Totall dos Boletos
                                ,pr_nmarquiv  => vr_tab_crapaux(i).nmarqori --> Nome do Arquivo
                                ,pr_nrprotoc  => pr_nrprotoc --> Numero do Protocolo
                                ,pr_hrtransa  => pr_hrtransa --> Hora da transacao
                                ,pr_cdcritic  => vr_cdcritic --> Codigo da Critica
                                ,pr_dscritic  => vr_dscritic); --> Descricao da Critica
          
          -- Se ocorreu erro durante o armazenamento da instrucao grava o erro
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            pc_grava_critica(pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => pr_nrdconta,
                             pr_nrdocmto => 999999,
                             pr_dscritic => vr_dscritic || ' - Remessa: ' || vr_rec_header.nrremass,
                             pr_tab_crawrej => pr_tab_crawrej);

            --> Apaga o Arquivo
            vr_dscomand := 'rm '|| SUBSTR(STR1 => vr_tab_crapaux(i).nmarquiv, 
                                          POS => 1, 
                                          LEN => LENGTH(vr_tab_crapaux(i).nmarquiv)) || ' 2> /dev/null';
            gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                        pr_typ_saida   => vr_typ_said,
                                        pr_des_saida   => vr_dscritic2);
                  
            -- Verificar retorno de erro
            IF NVL(vr_typ_said, ' ') = 'ERR' THEN
              
              IF NVL(vr_cdcritic,0) = 0    AND
                 TRIM(vr_dscritic) IS NULL THEN
                -- O comando shell executou com erro
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                    
              END IF;
                  
              RAISE vr_exc_erro;
              
            END IF;

            --> Apaga o Arquivo QUOTER
            vr_dscomand := 'rm -f '|| vr_tab_crapaux(i).nmarquiv || ' 2> /dev/null';
            gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                        pr_typ_saida   => vr_typ_said,
                                        pr_des_saida   => vr_dscritic2);
                  
            -- Verificar retorno de erro
            IF NVL(vr_typ_said, ' ') = 'ERR' THEN
              
              IF NVL(vr_cdcritic,0) = 0    AND
                 TRIM(vr_dscritic) IS NULL THEN
                -- O comando shell executou com erro
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                    
              END IF;
                  
              RAISE vr_exc_erro;
              
            END IF;
            
            CONTINUE;
            
          END IF;
          
          -- Cria Lote de Remessa do Cooperado 
          pc_grava_rtc(pr_cdcooper  => pr_cdcooper, --> Codigo da cooperativa
                       pr_nrdconta  => pr_nrdconta, --> Numero da conta do cooperado
                       pr_nrcnvcob  => vr_rec_header.nrcnvcob, --> Numero do documento
                       pr_nrremass  => vr_rec_header.nrremass, --> Codigo de critica
                       pr_dtmvtolt  => pr_dtmvtolt, --> Data de Movimento
                       pr_nmarquiv  => vr_tab_crapaux(i).nmarqori, --> Nome do Arquivo
                       pr_cdoperad  => pr_cdoperad, --> Operador
                       pr_tab_crawrej => pr_tab_crawrej,     --> Tabela de Rejeitados
                       pr_des_reto  => vr_des_reto);--> Retorno OK/NOK
          
          -- Se ocorreu erro durante o armazenamento da instrucao grava o erro
          IF vr_des_reto <> 'OK' THEN
            --> Apaga o Arquivo
            vr_dscomand := 'rm '|| SUBSTR(STR1 => vr_tab_crapaux(i).nmarquiv, 
                                          POS => 1, 
                                          LEN => LENGTH(vr_tab_crapaux(i).nmarquiv)) || ' 2> /dev/null';
                                          
            gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                        pr_typ_saida   => vr_typ_said,
                                        pr_des_saida   => vr_dscritic2);
                  
            -- Verificar retorno de erro
            IF NVL(vr_typ_said, ' ') = 'ERR' THEN
              
              IF NVL(vr_cdcritic,0) = 0    AND
                 TRIM(vr_dscritic) IS NULL THEN
                -- O comando shell executou com erro
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                  
              END IF;
                
              RAISE vr_exc_erro;
              
            END IF;

            --> Apaga o Arquivo QUOTER
            vr_dscomand := 'rm -f '|| vr_tab_crapaux(i).nmarquiv || ' 2> /dev/null';
            gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                        pr_typ_saida   => vr_typ_said,
                                        pr_des_saida   => vr_dscritic2);
                  
            -- Verificar retorno de erro
            IF NVL(vr_typ_said, ' ') = 'ERR' THEN
              
              IF NVL(vr_cdcritic,0) = 0    AND
                 TRIM(vr_dscritic) IS NULL THEN
                -- O comando shell executou com erro
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                  
              END IF;
                
              RAISE vr_exc_erro;
              
            END IF;
            
            CONTINUE;
          END IF;
        END IF;
        
        -- Busca as informacoes
        OPEN cr_craprtc (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrcnvcob => vr_rec_header.nrcnvcob
                        ,pr_nrremret => vr_rec_header.nrremass
                        ,pr_intipmvt => 1);
                        
        FETCH cr_craprtc INTO rw_craprtc;
        
        IF cr_craprtc%FOUND THEN
          
          -- Fecha Cursor
          CLOSE cr_craprtc;
          
          -- Atualiza o registro
          UPDATE craprtc 
             SET craprtc.flgproce = 1 -- YES
                ,craprtc.qtreglot = vr_qtbloque
                ,craprtc.qttitcsi = vr_qtbloque
                ,craprtc.vltitcsi = vr_vlrtotal
                ,craprtc.dsprotoc = pr_nrprotoc
           WHERE craprtc.rowid = rw_craprtc.rowid;
           
        ELSE 
          -- Fecha Cursor
          CLOSE cr_craprtc;
          
          -- Cria Rejeitado
          pc_grava_critica(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdocmto => 999999,
                           pr_dscritic => 'Nenhum boleto foi processado!',
                           pr_tab_crawrej => pr_tab_crawrej);
                           
          CONTINUE;
          
        END IF;
        
        -- Limpar a tabela de tarifas
        vr_tab_lat_consolidada.DELETE;
        
        -- Apos a importacao, processar PL TABLE dos titulos
        pc_processa_titulos(pr_cdcooper    => pr_cdcooper,    --> Codigo da Cooperativa
                            pr_dtmvtolt    => pr_dtmvtolt,    --> Data de Movimento
                            pr_cdoperad    => pr_cdoperad,    --> Operador
                            pr_tab_crapcob => vr_tab_crapcob, --> Tabela de Cobranca
                            pr_rec_header  => vr_rec_header,  --> Dados do Header do Arquivo
                            pr_tab_lat_consolidada => vr_tab_lat_consolidada, --> Tabela tarifas
                            pr_cdcritic => vr_cdcritic,       --> Codigo da Critica
                            pr_dscritic => vr_dscritic);      --> Descricao da Critica
                            
        -- Se ocorreu critica escreve no proc_message.log
        -- Não para o processo
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_nmdatela, 'COBR0006') || ' --> COBR0006.pc_intarq_remes_cnab240_085' ||
                                                        ' ERRO no processamento dos titulos: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
          vr_cdcritic:= NULL;
          vr_dscritic:= NULL;
        END IF;
                            
        -- Apos a importacao, processar PL TABLE das instrucoes
        pc_processa_instrucoes(pr_cdcooper      => pr_cdcooper --> Codigo da Cooperativa
                              ,pr_dtmvtolt      => pr_dtmvtolt --> Data de Movimento
                              ,pr_cdoperad      => pr_cdoperad --> Operador
                              ,pr_tab_instrucao => vr_tab_instrucao --> Tabela de Cobranca
                              ,pr_rec_header    => vr_rec_header    --> Dados do Header do Arquivo
                              ,pr_tab_rejeitado => vr_tab_rejeitado --> Tabela de rejeitados
                              ,pr_tab_lat_consolidada => vr_tab_lat_consolidada --> Tabela tarifas
                              ,pr_cdcritic      => vr_cdcritic   --> Codigo da Critica
                              ,pr_dscritic      => vr_dscritic); --> Descricao da Critica
                              
        -- Se ocorreu critica escreve no proc_message.log
        -- Não para o processo
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_nmdatela, 'COBR0006') || ' --> COBR0006.pc_intarq_remes_cnab240_085' ||
                                                        ' --> ERRO no processamento das instrucoes: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
          vr_cdcritic:= NULL;
          vr_dscritic:= NULL;
          
        END IF;
                
        -- Apos a importacao, processar PL TABLE de rejeitados
        pc_processa_rejeitados (pr_tab_rejeitado => vr_tab_rejeitado --> Tabela de rejeitados
                               ,pr_cdcritic      => vr_cdcritic   --> Codigo da Critica
                               ,pr_dscritic      => vr_dscritic); --> Descricao da Critica
                               
        -- Se ocorreu critica escreve no proc_message.log
        -- Não para o processo
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_nmdatela, 'COBR0006') || ' --> COBR0006.pc_intarq_remes_cnab240_085' ||
                                                        ' ERRO no processamento dos rejeitados: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
          vr_cdcritic:= NULL;
          vr_dscritic:= NULL;
        END IF;
                            
        -- Apos a importacao, processar PL TABLE de sacados
        pc_processa_sacados(pr_tab_sacado => vr_tab_sacado --> Tabela de sacados
                           ,pr_cdcritic   => vr_cdcritic   --> Codigo da Critica
                           ,pr_dscritic   => vr_dscritic); --> Descricao da Critica
                           
        -- Se ocorreu critica escreve no proc_message.log
        -- Não para o processo
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_nmdatela, 'COBR0006') || ' --> COBR0006.pc_intarq_remes_cnab240_085' ||
                                                        ' ERRO no processamento dos sacados: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
          vr_cdcritic:= NULL;
          vr_dscritic:= NULL;
        END IF;
        
        PAGA0001.pc_efetua_lancto_tarifas_lat(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_intarq_remes_cnab240_085');

        -- Se ocorreu critica escreve no proc_message.log
        -- Não para o processo
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_nmdatela, 'COBR0006') || ' --> COBR0006.pc_intarq_remes_cnab240_085' ||
                                                        ' ERRO no lancamento de tarifas: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
          vr_cdcritic:= NULL;
          vr_dscritic:= NULL;
          
        END IF;
        
      END IF;
      
    END LOOP;--> Fim arquivos
    
    IF pr_tab_crawrej.count = 0 THEN
      --Finaliza o processo de monitoramento para o Aymaru
      pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                          ,pr_nrdconta  => pr_nrdconta --> Número da conta
                          ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                          ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                          ,pr_tpoperac  => 2           --> Tipo de operação
                          ,pr_flgerro   => 0           --> Sem erros
                          ,pr_nmarquiv  => pr_nmarquiv --> Nome do arquivo
                          ,pr_dslogerro => 'Arquivo importado com sucesso' --> Descrição do erro
                          ,pr_qtprocessado => vr_qtbloque     --> Quantidade de registros processados
                          ,pr_qterro       => vr_qterro       --> Quantidade de registros com erro
                          ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                          ,pr_rowid_item_resumo => vr_rowid_item_resumo); 
    ELSE
      --Finaliza o processo de monitoramento para o Aymaru
      pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                          ,pr_nrdconta  => pr_nrdconta --> Número da conta
                          ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                          ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                          ,pr_tpoperac  => 2           --> Tipo de operação
                          ,pr_flgerro   => 1           --> Com erros
                          ,pr_nmarquiv  => pr_nmarquiv --> Nome do arquivo
                          ,pr_dslogerro => pr_tab_crawrej(pr_tab_crawrej.last).dscritic --> Descrição do erro
                          ,pr_qtprocessado => vr_qtbloque     --> Quantidade de registros processados
                          ,pr_qterro       => vr_qterro       --> Quantidade de registros com erro
                          ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                          ,pr_rowid_item_resumo => vr_rowid_item_resumo); 
    END IF;
                        
    COMMIT;
    npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'COBR006_5');
    
    pr_des_reto := 'OK';

    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION  
    WHEN vr_exc_saida THEN
      gene0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

      --> Gravar critica
      pc_grava_critica( pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_nrdocmto => vr_nrdoccri,
                        pr_dscritic => vr_dscritic,
                        pr_tab_crawrej => pr_tab_crawrej); 
                        
      pr_des_reto := 'NOK';
      
      --Finaliza o processo de monitoramento para o Aymaru
      pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                          ,pr_nrdconta  => pr_nrdconta --> Número da conta
                          ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                          ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                          ,pr_tpoperac  => 2           --> Tipo de operação
                          ,pr_flgerro   => 1           --> Com erros
                          ,pr_nmarquiv  => pr_nmarquiv --> Nome do arquivo
                          ,pr_dslogerro => vr_dscritic --> Descrição do erro
                          ,pr_qtprocessado => vr_qtbloque     --> Quantidade de registros processados
                          ,pr_qterro       => vr_qterro       --> Quantidade de registros com erro
                          ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                          ,pr_rowid_item_resumo => vr_rowid_item_resumo); 
      
      -- Efetuar rollback
      ROLLBACK;
      npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'COBR006_6');
      
    WHEN vr_exc_erro THEN
      gene0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      
      pr_des_reto := 'NOK';
      
      --Finaliza o processo de monitoramento para o Aymaru
      pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                          ,pr_nrdconta  => pr_nrdconta --> Número da conta
                          ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                          ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                          ,pr_tpoperac  => 2           --> Tipo de operação
                          ,pr_flgerro   => 1           --> Com erros
                          ,pr_nmarquiv  => pr_nmarquiv --> Nome do arquivo
                          ,pr_dslogerro => vr_dscritic --> Descrição do erro
                          ,pr_qtprocessado => vr_qtbloque     --> Quantidade de registros processados
                          ,pr_qterro       => vr_qterro       --> Quantidade de registros com erro
                          ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                          ,pr_rowid_item_resumo => vr_rowid_item_resumo); 
      
      -- Efetuar rollback
      ROLLBACK;
      npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'COBR006_7');
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      
      gene0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      
      pr_des_reto := 'NOK';
      
      --Finaliza o processo de monitoramento para o Aymaru
      pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                          ,pr_nrdconta  => pr_nrdconta --> Número da conta
                          ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                          ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                          ,pr_tpoperac  => 2           --> Tipo de operação
                          ,pr_flgerro   => 1           --> Com erros
                          ,pr_nmarquiv  => pr_nmarquiv --> Nome do arquivo
                          ,pr_dslogerro => vr_dscritic --> Descrição do erro
                          ,pr_qtprocessado => vr_qtbloque     --> Quantidade de registros processados
                          ,pr_qterro       => vr_qterro       --> Quantidade de registros com erro
                          ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                          ,pr_rowid_item_resumo => vr_rowid_item_resumo); 
      
      -- Efetuar rollback
      ROLLBACK;  
      npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'COBR006_8');
  END pc_intarq_remes_cnab240_085;
  
  --> Integrar/processar arquivo de remessa CNAB400
  PROCEDURE pc_intarq_remes_cnab400_085(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                       ,pr_nmarquiv  IN VARCHAR2              --> Nome do arquivo a ser importado               
                                       ,pr_idorigem  IN INTEGER               --> Identificador de origem
                                       ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                       ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do operador
                                       ,pr_nmdatela  IN VARCHAR2              --> Nome da Tela
                                       ,pr_tab_crawrej IN OUT NOCOPY typ_tab_crawrej --> Tabela de Rejeitados
                                       ,pr_hrtransa OUT INTEGER               --> Hora da transacao
                                       ,pr_nrprotoc OUT VARCHAR2              --> Numero do Protocolo
                                       ,pr_des_reto OUT VARCHAR2              --> OK ou NOK
                                       ,pr_cdcritic OUT INTEGER               --> Codigo de critica
                                       ,pr_dscritic OUT VARCHAR2               --> Descricao da critica
                                       ) IS
                                   
  /* ............................................................................

       Programa: pc_intarq_remes_cnab400_85        antiga: b1wgen0090.p/p_integra_arq_remessa_cnab400_085
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrei - RKAM
       Data    : Marco/2016.                   Ultima atualizacao:13/02/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel pode integrar o arquivo de remessa de cobrança
                   no padrão CNAB400 para boletos 085

       Alteracoes: 17/08/2016 - Ajuste para enviar o nome original do arquivo para emissao do protocolo
                                (Andrei - RKAM).

                   13/02/2017 - Ajuste para utilizar NOCOPY na passagem de PLTABLE como parâmetro
								(Andrei - Mouts). 

                   04/04/2017 - Inclusão da busca do parâmetro DIASVCTOCEE, pois fazia atribuição
                                da variável vr_diasvcto sem buscar o parâmetro (AJFink-SD#643179). 

                   09/11/2017 - Inclusão de chamada da procedure npcb0002.pc_libera_sessao_sqlserver_npc.
                                (SD#791193 - AJFink)

    ............................................................................ */   
    
    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    rw_craprtc COBR0006.cr_craprtc%ROWTYPE;
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    vr_tab_listarqu  gene0002.typ_split;
    vr_tab_crapaux   COBR0006.typ_tab_crawaux;
    vr_tab_linhas    gene0009.typ_tab_linhas;
    vr_tab_crawrej   COBR0006.typ_tab_crawrej;
    vr_rec_header    COBR0006.typ_rec_header;
    vr_rec_cobranca  COBR0006.typ_rec_cobranca;
    vr_tab_crapcob   COBR0006.typ_tab_crapcob;
    vr_tab_instrucao COBR0006.typ_tab_instrucao;
    vr_tab_rejeitado COBR0006.typ_tab_rejeitado;
    vr_tab_sacado    COBR0006.typ_tab_sacado;
    vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
    
    ------------------------------- VARIAVEIS -------------------------------
    
    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;
    vr_exc_saida EXCEPTION;
    vr_cdcritic  PLS_INTEGER;
    vr_dscritic  VARCHAR2(4000);
    vr_dscritic2 VARCHAR2(4000);    
    vr_des_reto  VARCHAR2(400);
    vr_nrdoccri  crapcob.nrdocmto%TYPE;
    
    vr_dstextab  craptab.dstextab%TYPE;
    vr_diasvcto  INTEGER;
    
    vr_dscomand  VARCHAR2(4000);
    vr_typ_said  VARCHAR2(500);
    vr_setlinha  VARCHAR2(500);
    
    vr_dsdireto  VARCHAR2(500);
    vr_dsdircop  VARCHAR2(500);
    vr_nmarquiv  VARCHAR2(500);
    vr_nmfisico  VARCHAR2(500);
    vr_listarqu  VARCHAR2(4000);
    vr_contador  INTEGER := 0;
    vr_idxarq    PLS_INTEGER;
    vr_flgfirst  BOOLEAN := FALSE;
    
    vr_qtbloque  INTEGER := 0;
    vr_qtdregis  INTEGER := 0;
    vr_qtdinstr  INTEGER := 0;
    vr_vlrtotal  NUMBER  := 0;
    vr_qterro       INTEGER := 0;
    vr_rowid_resumo      ROWID;
    vr_rowid_item_resumo ROWID;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
  BEGIN

    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_intarq_remes_cnab400_085');

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    
    FETCH cr_crapcop INTO rw_crapcop;
    
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
      
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
    
    --> buscar diretorio da cooperativa
    vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C', 
                                         pr_cdcooper => pr_cdcooper, 
                                         pr_nmsubdir => NULL);    
    
    --> Buscar parametro de vencimento
    vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => 3, 
                                               pr_nmsistem => 'CRED', 
                                               pr_tptabela => 'GENERI', 
                                               pr_cdempres => 0, 
                                               pr_cdacesso => 'DIASVCTOCEE', 
                                               pr_tpregist => 0);
    IF TRIM(vr_dstextab) IS NULL THEN
      vr_dscritic := 'Tabela com parametro vencimento nao encontrado.';
      RAISE vr_exc_erro;
    END IF;

    vr_diasvcto := SUBSTR(vr_dstextab,1,2);
    
    -- separa diretorio e nmarquivo
    gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmarquiv, 
                                    pr_direto  => vr_dsdireto, 
                                    pr_arquivo => vr_nmarquiv);
    
    -- Buscar arquivo a ser importado
    gene0001.pc_lista_arquivos(pr_path     => vr_dsdireto
                              ,pr_pesq     => vr_nmarquiv
                              ,pr_listarq  => vr_listarqu
                              ,pr_des_erro => vr_dscritic);

    -- Se ocorrer erro ao recuperar lista de arquivos, registra no log
    IF TRIM(vr_dscritic) IS NOT NULL THEN 
      
      vr_dscritic := 'Nao foi possivel localizar arquivo '||pr_nmarquiv||': '||vr_dscritic;
      RAISE vr_exc_erro;
      
    END IF;
    
    --Inicia o processo de monitoramento para o Aymaru
    pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                        ,pr_nrdconta  => pr_nrdconta --> Número da conta
                        ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                        ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                        ,pr_tpoperac  => 1           --> Tipo de operação
                        ,pr_flgerro   => 0           --> Sem erros
                        ,pr_nmarquiv  => vr_nmarquiv --> Nome do arquivo
                        ,pr_dslogerro => ''          --> Descrição do erro
                        ,pr_qtprocessado => 0        --> Quantidade de registros processados
                        ,pr_qterro       => 0        --> Quantidade de registros com erro
                        ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                        ,pr_rowid_item_resumo => vr_rowid_item_resumo);
    
    vr_tab_listarqu := gene0002.fn_quebra_string(pr_string => vr_listarqu,
                                                 pr_delimit => ',');
    
    vr_contador := 0;
                                            
    IF vr_tab_listarqu.count > 0 THEN
      
      --> Varrer arquivos
      FOR i IN vr_tab_listarqu.first..vr_tab_listarqu.last LOOP
        
        vr_contador := vr_contador + 1;
        vr_nmfisico := vr_dsdircop||'/integra/cobran'|| to_char(pr_dtmvtolt,'DDMMRR')||
                       '_'|| to_char(vr_contador,'fm0000') ||'_'||to_char(pr_nrdconta,'fm00000000');        
                
        vr_dscomand := 'dos2ux ' || vr_dsdireto || '/' || vr_tab_listarqu(i) ||' > ' || vr_nmfisico;

        -- Converte o arquivo de DOS para Unix
        gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic);
        
        -- Verificar retorno de erro
        IF NVL(vr_typ_said, ' ') = 'ERR' THEN
          
          -- O comando shell executou com erro
          vr_cdcritic := 0;
          vr_dscritic := 'Erro dos2ux arquivos: '||vr_dscritic;
          
          RAISE vr_exc_erro;
          
        END IF;
        
        -- Comando para listar a primeira linha do arquivo
        vr_dscomand:= 'head -1 ' ||vr_nmfisico;

        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_dscomand
                             ,pr_typ_saida   => vr_typ_said
                             ,pr_des_saida   => vr_setlinha);
                             
        --Se ocorreu erro dar RAISE
        IF vr_typ_said = 'ERR' THEN
          
          vr_dscritic:= 'Não foi possivel executar comando unix. '||vr_dscomand;
          RAISE vr_exc_erro;
          
        END IF;
        
        --> Verificar tamanho da linha do arquivo (padrao cnab400)
        IF length(vr_setlinha) > 403 THEN
        
          vr_cdcritic := 999;
          vr_dscritic := 'Arquivo invalido.';
          vr_nrdoccri := 0;      
          
          RAISE vr_exc_saida;
        
        END IF;
        
        vr_idxarq := vr_tab_crapaux.count;
        vr_tab_crapaux(vr_idxarq).nrsequen := SUBSTR(vr_setlinha,101,07);
        vr_tab_crapaux(vr_idxarq).nmarquiv := vr_nmfisico;
        vr_tab_crapaux(vr_idxarq).nmarqori := SUBSTR(pr_nmarquiv,INSTR(pr_nmarquiv,'/',-1)+1);
        
        vr_flgfirst := TRUE;
        
      END LOOP;
      
    END IF;
    
    IF NOT vr_flgfirst  THEN    
      
      vr_cdcritic := 887; --> Identificacao do arquivo Invalida 
      vr_nrdoccri := 0;
      
      RAISE vr_exc_saida;   
      
    END IF;
   
    vr_qtbloque := 0;
    vr_qtdregis := 0;
    vr_qtdinstr := 0;
    
    -- Processar arquivos
    FOR i IN vr_tab_crapaux.first..vr_tab_crapaux.last LOOP
      
      vr_flgfirst := FALSE;
      vr_vlrtotal := 0;
      vr_tab_linhas.delete;
      
      -- separa diretorio e nmarquivo
      gene0001.pc_separa_arquivo_path(pr_caminho => vr_tab_crapaux(i).nmarquiv, 
                                      pr_direto  => vr_dsdireto, 
                                      pr_arquivo => vr_nmarquiv);
      
      --> Ler arquivo conforme configurado no cadastro de layout 
      gene0009.pc_importa_arq_layout(pr_nmlayout   => 'CNAB400'       --> Nome do Layout do arquivo a ser importado
                                    ,pr_dsdireto   => vr_dsdireto     --> Descrição do diretorio onde o arquivo se enconta
                                    ,pr_nmarquiv   => vr_nmarquiv     --> Nome do arquivo a ser importado
                                    ,pr_dscritic   => vr_dscritic     --> Retorna critica Caso ocorra
                                    ,pr_tab_linhas => vr_tab_linhas); --> Retorna as linhas/campos do arquivo na temptable
                                      
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      IF vr_tab_linhas.count = 0 THEN
        
        vr_cdcritic := 999;
        vr_dscritic := 'Arquivo vazio.';
        vr_nrdoccri := 0;     
         
        RAISE vr_exc_saida; 
         
      ELSE
        
        -- Antes de iniciar o processamento do layout CNAB240, vamos limpar a PL TABLE
        vr_tab_crapcob.delete;  
        vr_tab_instrucao.delete;
        vr_tab_rejeitado.delete;
        vr_tab_sacado.delete;
      
        --> Varrer linhas do arquivo
        FOR vr_idlinha IN vr_tab_linhas.first..vr_tab_linhas.last LOOP
          
          --Gerar exceção apenas quando o HA ou TA possuirem erros         
          IF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto IN ('HA','TA') THEN
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout              
               vr_dscritic := 'Linha '||vr_idlinha||' '|| vr_tab_linhas(vr_idlinha)('$ERRO$').texto;
               vr_nrdoccri := 0;                     
               RAISE vr_exc_saida;               
            END IF;
          END IF;
          
          -------------------  Header do Arquivo --------------------
          IF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'HA' THEN 
            
            pc_trata_header_arq_cnab400 (pr_cdcooper   => pr_cdcooper               --> Codigo da cooperativa
                                        ,pr_nrdconta   => pr_nrdconta               --> Numero da conta do cooperado
                                        ,pr_cdagectl   => rw_crapcop.cdagectl        --> Codigo da agencia da central
                                        ,pr_tab_linhas => vr_tab_linhas(vr_idlinha) --> Dados da linha
                                        ,pr_rec_header => vr_rec_header             --> Dados do Header
                                        ,pr_cdcritic   => vr_cdcritic               --> Codigo de critica
                                        ,pr_dscritic   => vr_dscritic               --> Descricao da critica
                                        ,pr_des_reto   => vr_des_reto );            --> Retorno OK/NOK
                                          
            IF vr_des_reto <> 'OK' THEN
              
              --> Remover arquivo 
              vr_dscomand := 'rm -f '|| vr_tab_crapaux(i).nmarquiv;
              
              gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                          pr_typ_saida   => vr_typ_said,
                                          pr_des_saida   => vr_dscritic2);
              
              -- Verificar retorno de erro
              IF NVL(vr_typ_said, ' ') = 'ERR' THEN
                
                IF NVL(vr_cdcritic,0) = 0    AND
                   TRIM(vr_dscritic) IS NULL THEN
                   
                  -- O comando shell executou com erro
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                
                END IF;
                
                RAISE vr_exc_erro;
                
              END IF;
        
              RAISE vr_exc_saida;
              
            END IF;
            
            -- Se nao ocorreu erro no header, carrega as informacoes de banco
            vr_rec_header.cdbcoctl := rw_crapcop.cdbcoctl;
            vr_rec_header.cdagectl := rw_crapcop.cdagectl;
            
            -- atribui regra para envio a CIP
            vr_rec_cobranca.inenvcip := 1; -- a enviar            
            
          ---------------  Detalhe ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'R' THEN    
                      
            -- Processar detalhe       
            pc_trata_detalhe_cnab400(pr_cdcooper      => pr_cdcooper,               --> Codigo da cooperativa
                                     pr_nrdconta      => pr_nrdconta,               --> Numero da conta do cooperado
                                     pr_dtmvtolt      => pr_dtmvtolt,               --> Data de Movimento
                                     pr_cdoperad      => pr_cdoperad,               --> Operador
                                     pr_diasvcto      => vr_diasvcto,               --> Dias de vr_diasvctoencimento
                                     pr_flgfirst      => vr_flgfirst,               --> controle de primeiro registro
                                     pr_tab_linhas    => vr_tab_linhas(vr_idlinha), --> Dados da linha
                                     pr_rec_header    => vr_rec_header,             --> Dados do Header do Arquivo
                                     pr_qtdregis      => vr_qtdregis,               --> contador de registro
                                     pr_qtdinstr      => vr_qtdinstr,               --> contador de instucoes
                                     pr_qtbloque      => vr_qtbloque,               --> contador de boletos processados
                                     pr_vlrtotal      => vr_vlrtotal,               --> Valor total dos boletos
                                     pr_rec_cobranca  => vr_rec_cobranca,           --> Dados da Cobranca
                                     pr_tab_crapcob   => vr_tab_crapcob,            --> Tabela de Cobranca
                                     pr_tab_instrucao => vr_tab_instrucao,          --> Tabela de Instrucoes
                                     pr_tab_rejeitado => vr_tab_rejeitado,          --> Tabela de Rejeitados
                                     pr_tab_sacado    => vr_tab_sacado,             --> Tabela de Sacados 
                                     pr_tab_crawrej   => pr_tab_crawrej,            --> Tabela dae rejeitados
                                     pr_des_reto      => vr_des_reto);              --> Retorno OK/NOK
                                
          ---------------  Multa ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'MU' THEN
            
            -- Verificar se a cobranca foi rejeitada
            IF NOT vr_rec_cobranca.flgrejei THEN
                            
              -- Validar a linha que contem a multa
              pc_trata_multa_cnab400(pr_cdcooper      => pr_cdcooper               --> Codigo da cooperativa
                                    ,pr_nrdconta      => pr_nrdconta               --> Numero da conta do cooperado
                                    ,pr_dtmvtolt      => pr_dtmvtolt               --> Data de movimento
                                    ,pr_cdoperad      => pr_cdoperad               --> Operador
                                    ,pr_tab_linhas    => vr_tab_linhas(vr_idlinha) --> Dados da linha
                                    ,pr_rec_header    => vr_rec_header             --> Dados do Header do Arquivo
                                    ,pr_rec_cobranca  => vr_rec_cobranca           --> Dados da Cobranca
                                    ,pr_tab_rejeitado => vr_tab_rejeitado          --> Tabela de Rejeitados
                                    ,pr_tab_sacado    => vr_tab_sacado             --> Tabela de Sacados
                                    ,pr_des_reto      => pr_des_reto);	
             
             END IF;
                      
          END IF;
          
        END LOOP; --> Fim linhas arquivo
        
        -- Após finalizar as linhas do arquivo, temos que validar o ultimo titulo processado
        --> Cria o ultimo boleto ou gera instrucao apenas se nao tiver erros 
        IF vr_flgfirst AND NOT vr_rec_cobranca.flgrejei THEN
           
           --> 01 - Solicitacao de Remessa 
           IF vr_rec_cobranca.cdocorre = 1 THEN
             
             vr_dscritic:= '';
             
             -- Armazenar o boleto para gravacao ao fim do arquivo
             pc_grava_boleto(pr_rec_cobranca => vr_rec_cobranca
                            ,pr_qtbloque     => vr_qtbloque
                            ,pr_vlrtotal     => vr_vlrtotal
                            ,pr_tab_crapcob  => vr_tab_crapcob
                            ,pr_dscritic     => vr_dscritic);
                             
             -- Se ocorreu erro durante o armazenamento do boleto grava o erro
             IF TRIM(vr_dscritic) IS NOT NULL THEN
               pc_grava_critica(pr_cdcooper => vr_rec_cobranca.cdcooper
                               ,pr_nrdconta => vr_rec_cobranca.nrdconta
                               ,pr_nrdocmto => vr_rec_cobranca.nrbloque
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_crawrej => pr_tab_crawrej);
             END IF;
             
           ELSE
             
             vr_dscritic:= '';
             
             -- Armazenar a instrucao para gravacao ao fim do arquivo
             pc_grava_instrucao(pr_rec_cobranca  => vr_rec_cobranca
                               ,pr_tab_instrucao => vr_tab_instrucao
                               ,pr_dscritic      => vr_dscritic);  
                                
             -- Se ocorreu erro durante o armazenamento da instrucao grava o erro
             IF TRIM(vr_dscritic) IS NOT NULL THEN
               pc_grava_critica(pr_cdcooper => vr_rec_cobranca.cdcooper
                               ,pr_nrdconta => vr_rec_cobranca.nrdconta
                               ,pr_nrdocmto => vr_rec_cobranca.nrbloque
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_crawrej => pr_tab_crawrej);
                                
             END IF;
             
           END IF;       
           
        END IF;
        
        --Armarzena quantidade de registros processados
        vr_qtbloque := vr_qtdregis + vr_qtdinstr; 
        
        --Armazena quantidade de registros com erro
        vr_qterro := vr_tab_rejeitado.count();      
        
        --> Apaga o Arquivo QUOTER
        vr_dscomand := 'rm -f '|| vr_tab_crapaux(i).nmarquiv || ' 2> /dev/null';
        
        gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic2);
              
        -- Verificar retorno de erro
        IF NVL(vr_typ_said, ' ') = 'ERR' THEN
          
          IF NVL(vr_cdcritic,0) = 0    AND
             TRIM(vr_dscritic) IS NULL THEN
            -- O comando shell executou com erro
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                  
          END IF;
                
          RAISE vr_exc_erro;
          
        END IF;
        
        IF vr_qtbloque > 0 THEN
          pc_protocolo_transacao(pr_cdcooper  => pr_cdcooper --> Codigo da cooperativa
                                ,pr_nrdconta  => pr_nrdconta --> Numero da conta do cooperado
                                ,pr_dtmvtolt  => pr_dtmvtolt --> Data de Movimento
                                ,pr_cddbanco  => vr_rec_header.cdbandoc --> Codigo do Banco
                                ,pr_nrconven  => vr_rec_header.nrcnvcob --> Numero do Convenio
                                ,pr_nrremass  => vr_rec_header.nrremass --> Numero da Remessa
                                ,pr_qtbloque  => vr_qtbloque --> Quantidade de Boletos Processados
                                ,pr_vlrtotal  => vr_vlrtotal  --> Valor Totall dos Boletos
                                ,pr_nmarquiv  => vr_tab_crapaux(i).nmarqori --> Nome do Arquivo
                                ,pr_nrprotoc  => pr_nrprotoc --> Numero do Protocolo
                                ,pr_hrtransa  => pr_hrtransa --> Hora da transacao
                                ,pr_cdcritic  => vr_cdcritic --> Codigo da Critica
                                ,pr_dscritic  => vr_dscritic); --> Descricao da Critica
          
          -- Se ocorreu erro durante o armazenamento da instrucao grava o erro
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            pc_grava_critica(pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => pr_nrdconta,
                             pr_nrdocmto => 999999,
                             pr_dscritic => vr_dscritic || ' - Remessa: ' || vr_rec_header.nrremass,
                             pr_tab_crawrej => pr_tab_crawrej);

            --> Apaga o Arquivo
            vr_dscomand := 'rm '|| SUBSTR(STR1 => vr_tab_crapaux(i).nmarquiv, 
                                          POS => 1, 
                                          LEN => LENGTH(vr_tab_crapaux(i).nmarquiv)) || ' 2> /dev/null';
                                          
            gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                        pr_typ_saida   => vr_typ_said,
                                        pr_des_saida   => vr_dscritic2);
                  
            -- Verificar retorno de erro
            IF NVL(vr_typ_said, ' ') = 'ERR' THEN
              
              IF NVL(vr_cdcritic,0) = 0    AND
                 TRIM(vr_dscritic) IS NULL THEN
                -- O comando shell executou com erro
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                  
              END IF;
              
              RAISE vr_exc_erro;
              
            END IF;

            --> Apaga o Arquivo QUOTER
            vr_dscomand := 'rm -f '|| vr_tab_crapaux(i).nmarquiv || ' 2> /dev/null';
            
            gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                        pr_typ_saida   => vr_typ_said,
                                        pr_des_saida   => vr_dscritic2);
                  
            -- Verificar retorno de erro
            IF NVL(vr_typ_said, ' ') = 'ERR' THEN
              
              IF NVL(vr_cdcritic,0) = 0    AND
                 TRIM(vr_dscritic) IS NULL THEN
                -- O comando shell executou com erro
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                  
              END IF;
                
              RAISE vr_exc_erro;
              
            END IF;
            
            CONTINUE;
            
          END IF;
          
          -- Cria Lote de Remessa do Cooperado 
          pc_grava_rtc(pr_cdcooper  => pr_cdcooper, --> Codigo da cooperativa
                       pr_nrdconta  => pr_nrdconta, --> Numero da conta do cooperado
                       pr_nrcnvcob  => vr_rec_header.nrcnvcob, --> Numero do documento
                       pr_nrremass  => vr_rec_header.nrremass, --> Codigo de critica
                       pr_dtmvtolt  => pr_dtmvtolt, --> Data de Movimento
                       pr_nmarquiv  => vr_tab_crapaux(i).nmarqori, --> Nome do Arquivo
                       pr_cdoperad  => pr_cdoperad, --> Operador
                       pr_tab_crawrej => pr_tab_crawrej, --> Tabela de rejeitados
                       pr_des_reto  => vr_des_reto);--> Retorno OK/NOK
          
          -- Se ocorreu erro durante o armazenamento da instrucao grava o erro
          IF vr_des_reto <> 'OK' THEN
            
            --> Apaga o Arquivo
            vr_dscomand := 'rm '|| SUBSTR(STR1 => vr_tab_crapaux(i).nmarquiv, 
                                          POS => 1, 
                                          LEN => LENGTH(vr_tab_crapaux(i).nmarquiv)) || ' 2> /dev/null';
                                          
            gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                        pr_typ_saida   => vr_typ_said,
                                        pr_des_saida   => vr_dscritic2);
                  
            -- Verificar retorno de erro
            IF NVL(vr_typ_said, ' ') = 'ERR' THEN
              
              IF NVL(vr_cdcritic,0) = 0    AND
                 TRIM(vr_dscritic) IS NULL THEN
                -- O comando shell executou com erro
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                  
              END IF;
                
              RAISE vr_exc_erro;
              
            END IF;

            --> Apaga o Arquivo QUOTER
            vr_dscomand := 'rm -f '|| vr_tab_crapaux(i).nmarquiv || ' 2> /dev/null';
            gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                        pr_typ_saida   => vr_typ_said,
                                        pr_des_saida   => vr_dscritic2);
                  
            -- Verificar retorno de erro
            IF NVL(vr_typ_said, ' ') = 'ERR' THEN
              
              IF NVL(vr_cdcritic,0) = 0    AND
                 TRIM(vr_dscritic) IS NULL THEN
                -- O comando shell executou com erro
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao remover arquivo '||vr_tab_crapaux(i).nmarquiv ||': '||vr_dscritic2;
                  
              END IF;
                
              RAISE vr_exc_erro;
              
            END IF;
            
            CONTINUE;
            
          END IF;
          
        END IF;
        
        -- Busca as informacoes
        OPEN cr_craprtc (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrcnvcob => vr_rec_header.nrcnvcob
                        ,pr_nrremret => vr_rec_header.nrremass
                        ,pr_intipmvt => 1);
                        
        FETCH cr_craprtc INTO rw_craprtc;
        
        IF cr_craprtc%FOUND THEN
          
          -- Fecha Cursor
          CLOSE cr_craprtc;
          
          -- Atualiza o registro
          UPDATE craprtc 
             SET craprtc.flgproce = 1 -- YES
                ,craprtc.qtreglot = vr_qtbloque
                ,craprtc.qttitcsi = vr_qtbloque
                ,craprtc.vltitcsi = vr_vlrtotal
                ,craprtc.dsprotoc = pr_nrprotoc
           WHERE craprtc.rowid = rw_craprtc.rowid;
           
        ELSE 
          -- Fecha Cursor
          CLOSE cr_craprtc;
          
          -- Cria Rejeitado
          pc_grava_critica(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdocmto => 999999,
                           pr_dscritic => 'Nenhum boleto foi processado!',
                           pr_tab_crawrej => pr_tab_crawrej);
                           
          CONTINUE;
          
        END IF;
        
        -- Limpar a tabela de tarifas
        vr_tab_lat_consolidada.DELETE;
        
        -- Apos a importacao, processar PL TABLE dos titulos
        pc_processa_titulos(pr_cdcooper    => pr_cdcooper,    --> Codigo da Cooperativa
                            pr_dtmvtolt    => pr_dtmvtolt,    --> Data de Movimento
                            pr_cdoperad    => pr_cdoperad,    --> Operador
                            pr_tab_crapcob => vr_tab_crapcob, --> Tabela de Cobranca
                            pr_rec_header  => vr_rec_header,  --> Dados do Header do Arquivo
                            pr_tab_lat_consolidada => vr_tab_lat_consolidada, --> Tabela tarifas
                            pr_cdcritic => vr_cdcritic,       --> Codigo da Critica
                            pr_dscritic => vr_dscritic);      --> Descricao da Critica
                            
        -- Se ocorreu critica escreve no proc_message.log
        -- Não para o processo
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_nmdatela, 'COBR0006') || ' --> COBR0006.pc_intarq_remes_cnab400_085' ||
                                                        ' ERRO no processamento dos titulos: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
                                                        
          vr_cdcritic:= NULL;
          vr_dscritic:= NULL;
          
        END IF;
                            
        -- Apos a importacao, processar PL TABLE das instrucoes
        pc_processa_instrucoes(pr_cdcooper      => pr_cdcooper --> Codigo da Cooperativa
                              ,pr_dtmvtolt      => pr_dtmvtolt --> Data de Movimento
                              ,pr_cdoperad      => pr_cdoperad --> Operador
                              ,pr_tab_instrucao => vr_tab_instrucao --> Tabela de Cobranca
                              ,pr_rec_header    => vr_rec_header    --> Dados do Header do Arquivo
                              ,pr_tab_rejeitado => vr_tab_rejeitado --> Tabela de rejeitados
                              ,pr_tab_lat_consolidada => vr_tab_lat_consolidada --> Tabela tarifas
                              ,pr_cdcritic      => vr_cdcritic   --> Codigo da Critica
                              ,pr_dscritic      => vr_dscritic); --> Descricao da Critica
                              
        -- Se ocorreu critica escreve no proc_message.log
        -- Não para o processo
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_nmdatela, 'COBR0006') || ' --> COBR0006.pc_intarq_remes_cnab400_085' ||
                                                        ' ERRO no processamento das instrucoes: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
                                                        
          vr_cdcritic:= NULL;
          vr_dscritic:= NULL;
          
        END IF;
           
        -- Apos a importacao, processar PL TABLE de rejeitados
        pc_processa_rejeitados (pr_tab_rejeitado => vr_tab_rejeitado --> Tabela de rejeitados
                               ,pr_cdcritic      => vr_cdcritic   --> Codigo da Critica
                               ,pr_dscritic      => vr_dscritic); --> Descricao da Critica
                               
        -- Se ocorreu critica escreve no proc_message.log
        -- Não para o processo
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_nmdatela, 'COBR0006') || ' --> COBR0006.pc_intarq_remes_cnab400_085' ||
                                                        ' ERRO no processamento dos rejeitados: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
                                                        
          vr_cdcritic:= NULL;
          vr_dscritic:= NULL;
          
        END IF;
                            
        -- Apos a importacao, processar PL TABLE de sacados
        pc_processa_sacados(pr_tab_sacado => vr_tab_sacado --> Tabela de sacados
                           ,pr_cdcritic   => vr_cdcritic   --> Codigo da Critica
                           ,pr_dscritic   => vr_dscritic); --> Descricao da Critica
                           
        -- Se ocorreu critica escreve no proc_message.log
        -- Não para o processo
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_nmdatela, 'COBR0006') || ' --> COBR0006.pc_intarq_remes_cnab400_085' ||
                                                        ' ERRO no processamento dos sacados: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
                                                        
          vr_cdcritic:= NULL;
          vr_dscritic:= NULL;
          
        END IF;
                
        PAGA0001.pc_efetua_lancto_tarifas_lat(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_intarq_remes_cnab400_085');
        
        -- Se ocorreu critica escreve no proc_message.log
        -- Não para o processo
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || NVL(pr_nmdatela, 'COBR0006') || ' --> COBR0006.pc_intarq_remes_cnab400_085' ||
                                                        ' ERRO no lancamento de tarifas: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
                                                        
          vr_cdcritic:= NULL;
          vr_dscritic:= NULL;
          
        END IF;
        
      END IF;
      
    END LOOP;--> Fim arquivos
    
    IF pr_tab_crawrej.count = 0 THEN
      --Finaliza o processo de monitoramento para o Aymaru
      pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                          ,pr_nrdconta  => pr_nrdconta --> Número da conta
                          ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                          ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                          ,pr_tpoperac  => 2           --> Tipo de operação
                          ,pr_flgerro   => 0           --> Sem erros
                          ,pr_nmarquiv  => pr_nmarquiv --> Nome do arquivo
                          ,pr_dslogerro => 'Arquivo importado com sucesso' --> Descrição do erro
                          ,pr_qtprocessado => vr_qtbloque     --> Quantidade de registros processados
                          ,pr_qterro       => vr_qterro       --> Quantidade de registros com erro
                          ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                          ,pr_rowid_item_resumo => vr_rowid_item_resumo); 
    ELSE
      --Finaliza o processo de monitoramento para o Aymaru
      pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                          ,pr_nrdconta  => pr_nrdconta --> Número da conta
                          ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                          ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                          ,pr_tpoperac  => 2           --> Tipo de operação
                          ,pr_flgerro   => 1           --> Com erros
                          ,pr_nmarquiv  => pr_nmarquiv --> Nome do arquivo
                          ,pr_dslogerro => pr_tab_crawrej(pr_tab_crawrej.last).dscritic --> Descrição do erro
                          ,pr_qtprocessado => vr_qtbloque     --> Quantidade de registros processados
                          ,pr_qterro       => vr_qterro       --> Quantidade de registros com erro
                          ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                          ,pr_rowid_item_resumo => vr_rowid_item_resumo); 
    END IF; 
                        
    COMMIT;
    npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'COBR006_9');
    
    pr_des_reto := 'OK';

    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION  
    WHEN vr_exc_saida THEN
      gene0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

      --> Gravar critica
      pc_grava_critica( pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_nrdocmto => vr_nrdoccri,
                        pr_dscritic => vr_dscritic,
                        pr_tab_crawrej => pr_tab_crawrej); 
                        
      pr_des_reto := 'NOK';
      
      --Finaliza o processo de monitoramento para o Aymaru
      pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                          ,pr_nrdconta  => pr_nrdconta --> Número da conta
                          ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                          ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                          ,pr_tpoperac  => 2           --> Tipo de operação
                          ,pr_flgerro   => 1           --> Com erros
                          ,pr_nmarquiv  => pr_nmarquiv --> Nome do arquivo
                          ,pr_dslogerro => vr_dscritic --> Descrição do erro
                          ,pr_qtprocessado => vr_qtbloque     --> Quantidade de registros processados
                          ,pr_qterro       => vr_qterro       --> Quantidade de registros com erro
                          ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                          ,pr_rowid_item_resumo => vr_rowid_item_resumo); 
      
      -- Efetuar rollback
      ROLLBACK;
      npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'COBR006_10');
      
    WHEN vr_exc_erro THEN
      gene0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      
      pr_des_reto := 'NOK';
      
      --Finaliza o processo de monitoramento para o Aymaru
      pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                          ,pr_nrdconta  => pr_nrdconta --> Número da conta
                          ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                          ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                          ,pr_tpoperac  => 2           --> Tipo de operação
                          ,pr_flgerro   => 1           --> Com erros
                          ,pr_nmarquiv  => pr_nmarquiv --> Nome do arquivo
                          ,pr_dslogerro => vr_dscritic --> Descrição do erro
                          ,pr_qtprocessado => vr_qtbloque     --> Quantidade de registros processados
                          ,pr_qterro       => vr_qterro       --> Quantidade de registros com erro
                          ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                          ,pr_rowid_item_resumo => vr_rowid_item_resumo); 
      
      -- Efetuar rollback
      ROLLBACK;
      npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'COBR006_11');
      
    WHEN OTHERS THEN
      cecred.pc_internal_exception;

      gene0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      
      pr_des_reto := 'NOK';
      
      --Finaliza o processo de monitoramento para o Aymaru
      pc_monitora_processo(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                          ,pr_nrdconta  => pr_nrdconta --> Número da conta
                          ,pr_cdprogra  => pr_nmdatela --> Nome do programa
                          ,pr_cdservico => 1           --> Código do serviço (Arquivos de cobrança)
                          ,pr_tpoperac  => 2           --> Tipo de operação
                          ,pr_flgerro   => 1           --> Com erros
                          ,pr_nmarquiv  => pr_nmarquiv --> Nome do arquivo
                          ,pr_dslogerro => vr_dscritic --> Descrição do erro
                          ,pr_qtprocessado => vr_qtbloque     --> Quantidade de registros processados
                          ,pr_qterro       => vr_qterro       --> Quantidade de registros com erro
                          ,pr_rowid_resumo => vr_rowid_resumo --> ROWID do resumo do processo 
                          ,pr_rowid_item_resumo => vr_rowid_item_resumo); 
      
      -- Efetuar rollback
      ROLLBACK;  
      npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'COBR006_12');
      
  END pc_intarq_remes_cnab400_085;
  
  --> Realiza a validação do arquivo cnab240_01
  PROCEDURE pc_importa (pr_cdcooper    IN crapcop.cdcooper%TYPE      --> Codigo da cooperativa
                       ,pr_nmarqint    IN VARCHAR2                   --> Nome do arquivo a ser validado
                       ,pr_tpenvcob    IN crapceb.inenvcob%TYPE DEFAULT 1 --> Tipo de envio do arquivo (1-Envio via Internet Bank, 2-Envio via FTP)
                       ,pr_rec_rejeita OUT COBR0006.typ_tab_rejeita  --> Dados invalidados
                       ,pr_des_reto    OUT VARCHAR2)IS               --> Retorno OK/NOK
                                                                   
  /* ............................................................................

       Programa: pc_importa                                            antigo: b1wgen0010/p_importa    
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrei -RKAM
       Data    : Marco/2016.                   Ultima atualizacao: 12/03/2019 

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Realiza a validação do arquivo cnab240_01

       Alteracoes: 
                   24/07/2017 - Arquivo recebido com problema de layout é rejeitado por
                                erro na gene0009.pc_importa_arq_layout. Guardar mensagem
                                de retorno com a cobr0006.pc_cria_rejeitado e no tratamento
                                de exceção carregar o parâmetro pr_rec_rejeita, que é
                                tratado no pc_crps778. A falta do retorno estava interrompendo
                                a execução da carga de arquivos por FTP. (SD#718122-AJFink)
                                
                   12/03/2019 - Validar numero do boleto zero no arquivo de remessa
                                (Lucas Ranghetti INC0031367)
    ............................................................................ */   
    
    ------------------------------- CURSORES ---------------------------------    
    --> Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT ass.nrdconta,
           ass.nrcpfcgc,
           ass.inpessoa,
           ass.cdcooper,
           ass.nmprimtl
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --> Verifica se convenio esta Homologacao 
    CURSOR cr_crapceb (pr_cdcooper  crapceb.cdcooper%TYPE,
                       pr_nrconven  crapceb.nrconven%TYPE,
                       pr_nrcnvceb  crapceb.nrdconta%TYPE,
                       pr_flgutceb  crapcco.flgutceb%TYPE) IS
    SELECT *
      FROM crapceb
     WHERE crapceb.cdcooper = pr_cdcooper
       AND crapceb.nrconven = pr_nrconven
       AND crapceb.nrcnvceb = decode(pr_flgutceb,1,pr_nrcnvceb,crapceb.nrcnvceb)
       AND crapceb.nrdconta = decode(pr_flgutceb,0,pr_nrcnvceb,crapceb.nrdconta);    
    rw_crapceb cr_crapceb%ROWTYPE;  
    
    --> Codigo do Convenio
    CURSOR cr_crapcco (pr_cdcooper crapcco.cdcooper%TYPE,
                       pr_nrconven crapcco.nrconven%TYPE,
                       pr_nrdctabb crapcco.nrdctabb%TYPE) IS
    SELECT  crapcco.cddbanco
           ,crapcco.cdagenci
           ,crapcco.cdbccxlt
           ,crapcco.nrdolote
           ,crapcco.cdhistor
           ,crapcco.nrdctabb
           ,crapcco.nrconven
           ,crapcco.flgutceb
           ,crapcco.flgregis
           ,crapcco.rowid
      FROM crapcco
     WHERE crapcco.cdcooper = pr_cdcooper
       AND crapcco.cddbanco = 1
       AND crapcco.cdagenci = 1         
       AND crapcco.nrconven = pr_nrconven
       AND crapcco.nrdctabb = pr_nrdctabb;
    rw_crapcco cr_crapcco%ROWTYPE;
    
    --> Codigo do Convenio
    CURSOR cr_crapcco2(pr_cdcooper crapcco.cdcooper%TYPE,
                       pr_nrconven crapcco.nrconven%TYPE) IS
    SELECT  crapcco.cddbanco
           ,crapcco.cdagenci
           ,crapcco.cdbccxlt
           ,crapcco.nrdolote
           ,crapcco.cdhistor
           ,crapcco.nrdctabb
           ,crapcco.nrconven
           ,crapcco.flgutceb
           ,crapcco.flgregis
           ,crapcco.rowid
      FROM crapcco
     WHERE crapcco.cdcooper = pr_cdcooper          
       AND crapcco.nrconven = pr_nrconven;
    rw_crapcco2 cr_crapcco2%ROWTYPE;
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    --Tabelas contendo as linhas rejeitadas
    vr_tab_rejeita   COBR0006.typ_tab_rejeita; 
    vr_tab_listarqu  gene0002.typ_split;
    vr_tab_linhas    gene0009.typ_tab_linhas; 
    vr_tab_campos    gene0009.typ_tab_campos;
    vr_split         gene0002.typ_split := gene0002.typ_split();
    
    --Variaveis locais
    vr_flgutceb crapcco.flgutceb%TYPE;   
    vr_flgfirst BOOLEAN := FALSE; 
    vr_dsnosnum VARCHAR2(17);
    vr_nrdconta crapass.nrdconta%TYPE;
    vr_nmprimtl crapass.nmprimtl%TYPE;
    vr_tpcritic INTEGER;
    vr_dslocali VARCHAR2(100);
    vr_nrcepsac NUMBER(15); 
    vr_vlrtotal NUMBER  := 0;
    vr_contalin INTEGER := 0;
    vr_contaerr INTEGER := 0;
    vr_critica  VARCHAR2(400);
    vr_des_reto VARCHAR2(4);
    vr_dscriti1 VARCHAR2(40);
    vr_dscriti2 VARCHAR2(40);
    vr_nrcnvcob crapcco.nrconven%TYPE;
    vr_dsdireto  VARCHAR2(500);
    vr_nmarquiv  VARCHAR2(500);
    vr_listarqu  VARCHAR2(4000);
    vr_idx       PLS_INTEGER;
    
  BEGIN
    
    vr_tab_rejeita.delete;
    
    IF trim(pr_nmarqint) IS NULL THEN      
    
      COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                ,pr_nrlinseq => '99999'
                                ,pr_cdseqcri => (nvl(vr_tab_rejeita.count(),0)+1)
                                ,pr_dscritic => 'Arquivo nao encontrado.'
                                ,pr_tab_rejeita => vr_tab_rejeita 
                                ,pr_critica => vr_critica      
                                ,pr_des_reto => vr_des_reto);
    
      RAISE vr_exc_erro;
      
    END IF; 
    
    -- separa diretorio e nmarquivo
    gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmarqint, 
                                    pr_direto  => vr_dsdireto, 
                                    pr_arquivo => vr_nmarquiv);
    
    -- Buscar arquivo a ser importado
    gene0001.pc_lista_arquivos(pr_path     => vr_dsdireto
                              ,pr_pesq     => vr_nmarquiv
                              ,pr_listarq  => vr_listarqu
                              ,pr_des_erro => vr_dscritic);

    -- Se ocorrer erro ao recuperar lista de arquivos, registra no log
    IF TRIM(vr_dscritic) IS NOT NULL THEN 
      vr_dscritic := 'Nao foi possivel localizar arquivo '||pr_nmarqint||': '||vr_dscritic;

      COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                ,pr_nrlinseq => '99999'
                                ,pr_cdseqcri => (nvl(vr_tab_rejeita.count(),0)+1)
                                ,pr_dscritic => vr_dscritic
                                ,pr_tab_rejeita => vr_tab_rejeita 
                                ,pr_critica => vr_critica      
                                ,pr_des_reto => vr_des_reto);

      RAISE vr_exc_erro;
    END IF;
    
    vr_tab_listarqu := gene0002.fn_quebra_string(pr_string => vr_listarqu,
                                                 pr_delimit => ',');   
          
    -- Processar arquivos
    FOR i IN vr_tab_listarqu.first..vr_tab_listarqu.last LOOP
      
      vr_flgfirst := FALSE;
      vr_vlrtotal := 0;
      vr_tab_linhas.delete;
            
      --> Ler arquivo conforme configurado no cadastro de layout 
      gene0009.pc_importa_arq_layout(pr_nmlayout   => 'CNAB240'          --> Nome do Layout do arquivo a ser importado
                                    ,pr_dsdireto   => vr_dsdireto        --> Descrição do diretorio onde o arquivo se enconta
                                    ,pr_nmarquiv   => vr_tab_listarqu(i) --> Nome do arquivo a ser importado
                                    ,pr_dscritic   => vr_dscritic        --> Retorna critica Caso ocorra
                                    ,pr_tab_linhas => vr_tab_linhas);    --> Retorna as linhas/campos do arquivo na temptable
                                      
      IF TRIM(vr_dscritic) IS NOT NULL THEN

        COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                  ,pr_nrlinseq => '99999'
                                  ,pr_cdseqcri => (nvl(vr_tab_rejeita.count(),0)+1)
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_tab_rejeita => vr_tab_rejeita 
                                  ,pr_critica => vr_critica      
                                  ,pr_des_reto => vr_des_reto);

        RAISE vr_exc_erro;
      END IF;
      
      IF vr_tab_linhas.count = 0 THEN
        
        vr_cdcritic := 999;
        vr_dscritic := 'Arquivo vazio.';

        COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                  ,pr_nrlinseq => '99999'
                                  ,pr_cdseqcri => (nvl(vr_tab_rejeita.count(),0)+1)
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_tab_rejeita => vr_tab_rejeita 
                                  ,pr_critica => vr_critica      
                                  ,pr_des_reto => vr_des_reto);

        RAISE vr_exc_erro; 
         
      ELSE
        
        vr_contalin := 0;  
        vr_contaerr := 0; 
        vr_dscriti1 := 'Informar valores numericos';
        vr_dscriti2 := 'Deve ser campo CARACTER';
              
        --> Varrer linhas do arquivo
        FOR vr_idlinha IN vr_tab_linhas.first..vr_tab_linhas.last LOOP
          
          vr_tab_campos := vr_tab_linhas(vr_idlinha);
          
          vr_contalin := vr_contalin + 1;
          
          -------------------  Header do Arquivo --------------------
          IF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'HA' THEN 
           
            --Problemas com importacao do layout
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN 
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
                                        
            --> Cod. Banco na compen.
            IF vr_tab_campos('CDBANCMP').numero <> 1 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 1 ate 3 (Codigo do banco deve ser 001)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Lote do servico
            IF vr_tab_campos('NRLOTSER').numero <> 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 4 ate 7 (Lote do servico deve ser 0000)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Tipo de registro
            IF vr_tab_campos('TPREGIST').numero <> 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 8 ate 8 (Tipo de registro deve ser 0)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Uso exclusivo FEBRABAN
            IF vr_tab_campos('DSUSOFEB').texto IS NOT NULL    AND
               vr_tab_campos('DSUSOFEB').texto <> '000000000' THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 9 ate 17 (Preencher com brancos)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            END IF;
          
            --> Numero de inscricao
            IF vr_tab_campos('NRCPFCGC').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 19 ate 32 (Informar numero de inscricao da empresa)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
          
            --> Agencia
            IF vr_tab_campos('CDAGENCI').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 53 ate 57 (Informar agencia mantenedora da conta)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --Busca convenio
            OPEN cr_crapcco(pr_cdcooper => pr_cdcooper
                           ,pr_nrdctabb => vr_tab_campos('NRDCONTA').numero
                           ,pr_nrconven => to_number(vr_tab_campos('NRCONVEN').texto));
                           
            FETCH cr_crapcco INTO rw_crapcco;
            
            IF cr_crapcco%NOTFOUND THEN
              
              CLOSE cr_crapcco;
              
              --Parametros do cadastro de cobranca(CADCCO)
              OPEN cr_crapcco2(pr_cdcooper => pr_cdcooper
                              ,pr_nrconven => to_number(vr_tab_campos('NRCONVEN').texto));
              
              FETCH cr_crapcco2 INTO rw_crapcco2;
              
              IF cr_crapcco2%NOTFOUND THEN
                
                CLOSE cr_crapcco2;
                            
                vr_contaerr := vr_contaerr + 1;
                  
                vr_split := gene0002.fn_quebra_string(pr_string  => gene0001.fn_busca_critica(563)
                                                     ,pr_delimit => '-');         
                                                     
                COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                          ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                          ,pr_cdseqcri => vr_contaerr
                                          ,pr_dscritic => 'Posicao: 33 ate 52 ('|| vr_split(2) ||')' 
                                          ,pr_tab_rejeita => vr_tab_rejeita 
                                          ,pr_critica => vr_critica      
                                          ,pr_des_reto => vr_des_reto);               
                
              ELSE
                
                CLOSE cr_crapcco2;
              
                IF vr_tab_campos('NRDCONTA').numero = 0 THEN
                  
                  vr_contaerr := vr_contaerr + 1;
                  
                  COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                            ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                            ,pr_cdseqcri => vr_contaerr
                                            ,pr_dscritic => 'Posicao: 59 ate 71 (Conta Base nao cadastrada)'
                                            ,pr_tab_rejeita => vr_tab_rejeita 
                                            ,pr_critica => vr_critica      
                                            ,pr_des_reto => vr_des_reto);

                
                END IF;
              
              
              END IF;  
                
            ELSE
              
              CLOSE cr_crapcco;
            
              -- Utiliza sequencial CADCEB
              vr_flgutceb := rw_crapcco.flgutceb;
              vr_nrcnvcob := rw_crapcco.nrconven;
            
            END IF;
              
            --> Nome da empresa
            IF vr_tab_campos('NMEMPRES').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 73 ate 102 (Informar nome da empresa)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Nome do banco
            IF vr_tab_campos('NMDBANCO').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 103 ate 132 (Informar nome do banco)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
          --------------------  Header do Lote ---------------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'HL' THEN   
          
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            --> Cod. Banco na compensa.
            IF vr_tab_campos('CDBANCMP').numero <> 1 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 1 ate 3 (Codigo do banco deve ser 001)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
                        
            --> Lote do servico
            IF vr_tab_campos('NRLOTSER').numero <> 1 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 4 ate 7 (Lote do servico deve ser 0001)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Tipo de registro
            IF vr_tab_campos('TPREGIST').numero <> 1 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 8 ate 8 (Tipo de registro deve ser 1)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Tipo de servico 
            IF vr_tab_campos('TPSERVIC').numero <> 1 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 10 ate 11 (Tipo de servico deve ser 01)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Exclusivo FEBRABAN
            IF vr_tab_campos('DSUSOFEB').texto IS NOT NULL AND
               vr_tab_campos('DSUSOFEB').texto <> '00'     THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 12 ate 13 (Preencher com brancos)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Uso exclusivo Febraban
            IF vr_tab_campos('DSUSOFEB2').texto IS NOT NULL AND
               vr_tab_campos('DSUSOFEB2').texto <> '0'      THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 17 ate 17 (Preencher com brancos)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Numero de Inscricao da empresa
            IF vr_tab_campos('NRCPFCGC').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 19 ate 33 (Informar numero de inscricao da empresa)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
                        
            --> Agencia
            IF vr_tab_campos('CDAGENCI').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 54 ate 58 (Informar agencia mantenedora da conta)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --Busca convenio
            OPEN cr_crapcco(pr_cdcooper => pr_cdcooper
                           ,pr_nrdctabb => vr_tab_campos('NRDCONTA').numero
                           ,pr_nrconven => to_number(vr_tab_campos('NRCONVEN').texto));
                           
            FETCH cr_crapcco INTO rw_crapcco;
            
            IF cr_crapcco%NOTFOUND THEN
              
              CLOSE cr_crapcco;
              
              OPEN cr_crapcco2(pr_cdcooper => pr_cdcooper
                              ,pr_nrconven => to_number(vr_tab_campos('NRCONVEN').texto));
              
              FETCH cr_crapcco2 INTO rw_crapcco2;
              
              IF cr_crapcco2%NOTFOUND THEN
                
                CLOSE cr_crapcco2;                
                
                vr_contaerr := vr_contaerr + 1;
                                
                vr_split := gene0002.fn_quebra_string(pr_string  => gene0001.fn_busca_critica(563)
                                                     ,pr_delimit => '-');                                                        
                 
                COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                          ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                          ,pr_cdseqcri => vr_contaerr
                                          ,pr_dscritic => 'Posicao: 34 ate 53 ('|| vr_split(2) ||')' 
                                          ,pr_tab_rejeita => vr_tab_rejeita 
                                          ,pr_critica => vr_critica      
                                          ,pr_des_reto => vr_des_reto);
                
                
              ELSE
                
                CLOSE cr_crapcco2;
              
                IF vr_tab_campos('NRDCONTA').numero = 0 THEN
                  
                  vr_contaerr := vr_contaerr + 1;
                  
                  COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                            ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                            ,pr_cdseqcri => vr_contaerr
                                            ,pr_dscritic => 'Posicao: 60 ate 72 (Conta Base nao cadastrada)'
                                            ,pr_tab_rejeita => vr_tab_rejeita 
                                            ,pr_critica => vr_critica      
                                            ,pr_des_reto => vr_des_reto);

                
                END IF;
              
              
              END IF;  
                
            ELSE
              
              CLOSE cr_crapcco;
                        
            END IF;
                        
            --> Nome da empresa
            IF vr_tab_campos('NMEMPRES').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 74 a 103 (Informar nome da empresa)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
                        
          ---------------  Detalhe ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'P' THEN    
           
            --Problemas com importacao do layout
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN 
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            -- Formatar nosso numero com 17 posicoes para separa o numero da conta e o numero do boleto
            vr_dsnosnum := to_char(TRIM(vr_tab_campos('DSNOSNUM').texto),'fm00000000000000000'); 
                        
            IF vr_flgutceb = 0 THEN
              
              vr_nrdconta := to_number(SUBSTR(vr_dsnosnum,1,8));
    
            ELSE 
              
              vr_nrdconta := to_number(SUBSTR(vr_dsnosnum,8,4));
      
            
            END IF;
            
            --> Cod. movimento de remessa
            IF vr_tab_campos('CDMOVRE').numero <> 1 THEN
              
              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 16 ate 17 (Informar 01 Solicitacao de remessa)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
               
            
            END IF;
            
            --> Agencia Mantenedora da Conta
            IF vr_tab_campos('CDAGENCI').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 18 ate 22 (Informar agencia mantenedora da conta)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            
            
            END IF;
            
            --> Conta corrente
            IF vr_tab_campos('NRDCONTA').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 24 ate 35 (Informar numero da conta)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            
            END IF;
            
            --> Numero do documento
            IF vr_tab_campos('NRDOCMTO').texto IS NULL OR
               vr_tab_campos('NRDOCMTO').texto = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 63 ate 77 (Informar numero do documento de cobranca)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            
            
            END IF;
            
            --> Valor do Titulo
            IF vr_tab_campos('VLTITULO').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 86 ate 100 (Informar valor do titulo)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            
            
            END IF;
                        
          ---------------  Detalhe - Segmento Q ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'Q' THEN
            
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            --Busca conveio
            OPEN cr_crapceb(pr_cdcooper => pr_cdcooper
                           ,pr_nrconven => vr_nrcnvcob
                           ,pr_nrcnvceb => vr_nrdconta
                           ,pr_flgutceb => vr_flgutceb);
                             
            FETCH cr_crapceb INTO rw_crapceb;
            
            IF cr_crapceb%NOTFOUND      OR 
               rw_crapceb.insitceb <> 1 THEN
                
              CLOSE cr_crapceb;
              
              vr_contaerr := vr_contaerr + 1;
                   
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr                                         
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero - 1,'00000')
                                        ,pr_dscritic => '(P)Posicao: 38 ate 57 (Nosso numero esta incorreto)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
             
              
            ELSE
                
              CLOSE cr_crapceb; 
              
              vr_nrdconta := rw_crapceb.nrdconta;
              
            END IF;
              
            --> Se convenio esta cadastrado como envio FTP
            --> Só podera ser importado via FTP
            IF rw_crapceb.inenvcob = 2 AND 
               pr_tpenvcob <> 2 THEN
               
              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero - 1,'00000')
                                        ,pr_dscritic =>  'Convenio cadastrado para apenas ser enviado via FTP.'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                         
            END IF;    
              
            --Busca conta
            OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => vr_nrdconta);
                           
            FETCH cr_crapass INTO rw_crapass;
            
            IF cr_crapass%NOTFOUND THEN
              
              CLOSE cr_crapass;
                            
              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero - 1,'00000')
                                        ,pr_dscritic =>  '(P)Posicao: 38 ate 57 (Nosso numero esta incorreto)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            
            ELSE
              
              CLOSE cr_crapass;
              
              vr_nmprimtl := rw_crapass.nmprimtl;
            
            END IF;            
          
            IF vr_tab_campos('CDMOVRE').numero <> 1 THEN
            
              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 16 ate 17 (Informar 01 Solicitadao de remessa)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            
                                           
            END IF;               
            
            --> Nome do sacado
            IF vr_tab_campos('NMDSACAD').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 34 ate 73 (Informar o nome do Pagador)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          

            END IF;
            
            --> Endereco
            IF vr_tab_campos('DSENDSAC').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 74 ate 113 (Informar Endereco)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          

            END IF;
            
            --> Bairro
            IF vr_tab_campos('NMBAISAC').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 114 ate 128 (Informar Bairro)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          

            END IF;
            
            --CEP
            IF vr_tab_campos('NRCEPSAC').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 129 ate 136 (Informar CEP)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          

            END IF;
            
            -- Cidade
            IF vr_tab_campos('NMCIDSAC').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 137 ate 151 (Informar Cidade)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          

            END IF;
            
            -- Unidade da Federacao
            IF vr_tab_campos('CDUFSACA').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 152 ate 153 (Informar U.F.)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          

            END IF;
                        
          ---------------  Trailer do Lote ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'TL' THEN
          
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 4
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            IF vr_tab_campos('TPREGIST').numero <> 5 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              vr_split := gene0002.fn_quebra_string(pr_string  => gene0001.fn_busca_critica(468)
                                                   ,pr_delimit => '-');                                                        
                 
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 4
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 8 ate 8 ('|| vr_split(2) ||')' 
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            -- Qtd. registros do lote
            IF vr_tab_campos('QTRERLOT').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 4
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 18 ate 23 (Informar Qtd. de registros no lote)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            -- Qtd. titulos em cobranca
            IF vr_tab_campos('QTTITCOB').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 4
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 24 ate 29 (Informar Qtd. de titulos em cobranca)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            -- Vlr. total dos titulos em carteira
            IF vr_tab_campos('VLTITCAR').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 4
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 30 ate 46 (Informar Vlr. total dos titulos)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
          ---------------  Trailer do arquivo ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'TA' THEN
                      
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 5
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            IF vr_tab_campos('NRLOTSER').numero <> 9999 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 5
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 4 ate 7 (Lote do servico deve ser 9999)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            IF vr_tab_campos('TPREGIST').numero <> 9 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 5
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 8 ate 8 (Tipo de registro deve ser 9)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
          
            IF vr_tab_campos('DSUSOFEB').texto IS NOT NULL THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 5
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 9 ate 17 (Preencher com brancos)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
          
            -- Qtd. Lotes do arquivo
            IF vr_tab_campos('QTLOTARQ').numero <> 1 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 5
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 18 ate 23 (Qtd. de Lotes do arquivo eh 0001)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
          
            IF vr_tab_campos('QTREGARQ').numero <> vr_contalin THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 5
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 24 ate 29 (Quantidade de registros do arquivo esta errada => ' 
                                                        || to_char(vr_contalin,'000000') || ' )'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
          
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto <> 'S' THEN
          
            vr_contaerr := vr_contaerr + 1;
              
            COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                      ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                      ,pr_cdseqcri => vr_contaerr
                                      ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                      ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Este tipo de Registro nao eh tratado.'
                                      ,pr_tab_rejeita => vr_tab_rejeita 
                                      ,pr_critica => vr_critica      
                                      ,pr_des_reto => vr_des_reto);
                                        
          
          END IF;
          
         END LOOP;    
         
       END IF;
       
    END LOOP;
    
    vr_contaerr := 0;
    vr_tpcritic := 0;
    
    -- Percorrer todos os registros rejeitados
    FOR vr_idx IN 1..vr_tab_rejeita.COUNT() LOOP
            
      vr_contaerr := vr_contaerr + 1;
            
      IF vr_tpcritic <>  vr_tab_rejeita(vr_idx).tpcritic THEN -- vr_tab_rejeita(vr_idx).tpcritic THEN
        
        CASE vr_tab_rejeita(vr_idx).tpcritic
          WHEN 1 THEN
            vr_dslocali := 'Header do Arquivo';
          WHEN 2 THEN
            vr_dslocali := 'Header do Lote';  
          WHEN 3 THEN
            vr_dslocali := 'Detalhe do Arquivo';
          WHEN 4 THEN
            vr_dslocali := 'Trailer do Lote';
          ELSE
            vr_dslocali := 'Trailer do Arquivo';  
          
        END CASE;   
        
        COBR0006.pc_cria_rejeitado(pr_tpcritic => vr_tab_rejeita(vr_idx).tpcritic
                                  ,pr_cdseqcri => vr_contaerr
                                  ,pr_dscritic => '==>  ' ||  vr_dslocali
                                  ,pr_tab_rejeita => pr_rec_rejeita 
                                  ,pr_critica => vr_critica      
                                  ,pr_des_reto => vr_des_reto);

        vr_contaerr := vr_contaerr + 1;
        vr_tab_rejeita(vr_idx).cdseqcri := vr_contaerr; 
        vr_tpcritic := vr_tab_rejeita(vr_idx).tpcritic;
        
        COBR0006.pc_cria_rejeitado(pr_tpcritic => vr_tab_rejeita(vr_idx).tpcritic
                                  ,pr_nrlinseq => vr_tab_rejeita(vr_idx).nrlinseq        
                                  ,pr_cdseqcri => vr_contaerr
                                  ,pr_seqdetal => vr_tab_rejeita(vr_idx).seqdetal                                  
                                  ,pr_dscritic => vr_tab_rejeita(vr_idx).dscritic
                                  ,pr_tab_rejeita => pr_rec_rejeita 
                                  ,pr_critica => vr_critica      
                                  ,pr_des_reto => vr_des_reto);
        
      ELSE
        
        vr_tab_rejeita(vr_idx).cdseqcri := vr_contaerr;  
        
        COBR0006.pc_cria_rejeitado(pr_tpcritic => vr_tab_rejeita(vr_idx).tpcritic
                                  ,pr_nrlinseq => vr_tab_rejeita(vr_idx).nrlinseq        
                                  ,pr_cdseqcri => vr_contaerr
                                  ,pr_seqdetal => vr_tab_rejeita(vr_idx).seqdetal                                  
                                  ,pr_dscritic => vr_tab_rejeita(vr_idx).dscritic
                                  ,pr_tab_rejeita => pr_rec_rejeita 
                                  ,pr_critica => vr_critica      
                                  ,pr_des_reto => vr_des_reto);
                                  
      END IF;
        
    END LOOP;    
        
    pr_des_reto := 'OK';
    
  EXCEPTION  
    WHEN vr_exc_erro THEN         
    begin
      if nvl(pr_rec_rejeita.count(),0) = 0 and nvl(vr_tab_rejeita.count(),0) > 0 then

        vr_contaerr := 0;
        vr_tpcritic := 0;
        
        -- Percorrer todos os registros rejeitados
        FOR vr_idx IN 1..vr_tab_rejeita.COUNT() LOOP
                
          vr_contaerr := vr_contaerr + 1;
                
          IF vr_tpcritic <>  vr_tab_rejeita(vr_idx).tpcritic THEN -- vr_tab_rejeita(vr_idx).tpcritic THEN
            
            CASE vr_tab_rejeita(vr_idx).tpcritic
              WHEN 1 THEN
                vr_dslocali := 'Header do Arquivo';
              WHEN 2 THEN
                vr_dslocali := 'Header do Lote';  
              WHEN 3 THEN
                vr_dslocali := 'Detalhe do Arquivo';
              WHEN 4 THEN
                vr_dslocali := 'Trailer do Lote';
              ELSE
                vr_dslocali := 'Trailer do Arquivo';  
              
            END CASE;   
            
            COBR0006.pc_cria_rejeitado(pr_tpcritic => vr_tab_rejeita(vr_idx).tpcritic
                                      ,pr_cdseqcri => vr_contaerr
                                      ,pr_dscritic => '==>  ' ||  vr_dslocali
                                      ,pr_tab_rejeita => pr_rec_rejeita 
                                      ,pr_critica => vr_critica      
                                      ,pr_des_reto => vr_des_reto);

            vr_contaerr := vr_contaerr + 1;
            vr_tab_rejeita(vr_idx).cdseqcri := vr_contaerr; 
            vr_tpcritic := vr_tab_rejeita(vr_idx).tpcritic;
            
            COBR0006.pc_cria_rejeitado(pr_tpcritic => vr_tab_rejeita(vr_idx).tpcritic
                                      ,pr_nrlinseq => vr_tab_rejeita(vr_idx).nrlinseq        
                                      ,pr_cdseqcri => vr_contaerr
                                      ,pr_seqdetal => vr_tab_rejeita(vr_idx).seqdetal                                  
                                      ,pr_dscritic => vr_tab_rejeita(vr_idx).dscritic
                                      ,pr_tab_rejeita => pr_rec_rejeita 
                                      ,pr_critica => vr_critica      
                                      ,pr_des_reto => vr_des_reto);
            
          ELSE
            
            vr_tab_rejeita(vr_idx).cdseqcri := vr_contaerr;  
            
            COBR0006.pc_cria_rejeitado(pr_tpcritic => vr_tab_rejeita(vr_idx).tpcritic
                                      ,pr_nrlinseq => vr_tab_rejeita(vr_idx).nrlinseq        
                                      ,pr_cdseqcri => vr_contaerr
                                      ,pr_seqdetal => vr_tab_rejeita(vr_idx).seqdetal                                  
                                      ,pr_dscritic => vr_tab_rejeita(vr_idx).dscritic
                                      ,pr_tab_rejeita => pr_rec_rejeita 
                                      ,pr_critica => vr_critica      
                                      ,pr_des_reto => vr_des_reto);
                                      
          END IF;
            
        END LOOP;

      end if;

      pr_des_reto := 'NOK';

    end;
       
    WHEN OTHERS THEN
      
      pr_des_reto := 'NOK';
      
  END pc_importa;   
  
  --> Realiza a validação do arquivo cnab240 085
  PROCEDURE pc_importa_cnab240_085 (pr_cdcooper    IN crapcop.cdcooper%TYPE     --> Codigo da cooperativa
                                   ,pr_nmarqint    IN VARCHAR2                  --> Nome do arquivo a ser validado
                                   ,pr_tpenvcob    IN crapceb.inenvcob%TYPE DEFAULT 1--> Tipo de envio do arquivo (1-Envio via Internet Bank, 2-Envio via FTP)
                                   ,pr_rec_rejeita OUT COBR0006.typ_tab_rejeita --> Dados invalidados
                                   ,pr_des_reto    OUT VARCHAR2) IS             --> Retorno OK/NOK
                                           
  /* ............................................................................

       Programa: pc_importa_cnab240_085                                            antigo: b1wgen0010/p_importa_cnab240_085    
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrei
       Data    : Marco/2016.                   Ultima atualizacao: 12/03/2019

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Realiza a validação do arquivo cnab240_085

       Alteracoes: 17/08/2016 - Ajuste para retirar tratementos do Trailer de Lote e
                                efetuar tratamento para os segmentos R,S
                                (Andrei - RKAM).
                   24/07/2017 - Arquivo recebido com problema de layout é rejeitado por
                                erro na gene0009.pc_importa_arq_layout. Guardar mensagem
                                de retorno com a cobr0006.pc_cria_rejeitado e no tratamento
                                de exceção carregar o parâmetro pr_rec_rejeita, que é
                                tratado no pc_crps778. A falta do retorno estava interrompendo
                                a execução da carga de arquivos por FTP. (SD#718122-AJFink)
                                
                   12/03/2019 - Validar numero do boleto zero no arquivo de remessa
                                (Lucas Ranghetti INC0031367)
    ............................................................................ */   
    
    ------------------------------- CURSORES ---------------------------------    
    --> Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                     pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT ass.nrdconta,
           ass.nrcpfcgc,
           ass.inpessoa,
           ass.cdcooper,
           ass.nmprimtl
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
  
    --> Verifica se convenio esta Homologacao 
    CURSOR cr_crapceb (pr_cdcooper  crapceb.cdcooper%TYPE,
                       pr_nrconven  crapceb.nrconven%TYPE,
                       pr_nrdconta  crapceb.nrdconta%TYPE) IS
    SELECT crapceb.insitceb
          ,crapceb.inenvcob
          ,crapceb.flgpgdiv
      FROM crapceb
     WHERE crapceb.cdcooper = pr_cdcooper
       AND crapceb.nrconven = pr_nrconven        
       AND crapceb.nrdconta = pr_nrdconta;    
    rw_crapceb cr_crapceb%ROWTYPE;  
    
    --> Codigo do Convenio
    CURSOR cr_crapcco (pr_cdcooper crapcco.cdcooper%TYPE,
                       pr_nrconven crapcco.nrconven%TYPE) IS
    SELECT  crapcco.cddbanco
           ,crapcco.cdagenci
           ,crapcco.cdbccxlt
           ,crapcco.nrdolote
           ,crapcco.cdhistor
           ,crapcco.nrdctabb
           ,crapcco.nrconven
           ,crapcco.flgutceb
           ,crapcco.flgregis
           ,crapcco.rowid
      FROM crapcco
     WHERE crapcco.cdcooper = pr_cdcooper
       AND crapcco.cddbanco = 85
       AND crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE'
       AND crapcco.nrconven = pr_nrconven;
    rw_crapcco cr_crapcco%ROWTYPE;    
    
    --> Codigo do Convenio
    CURSOR cr_crapcco2 (pr_cdcooper crapcco.cdcooper%TYPE,
                       pr_nrconven crapcco.nrconven%TYPE) IS
    SELECT  crapcco.cddbanco
           ,crapcco.cdagenci
           ,crapcco.cdbccxlt
           ,crapcco.nrdolote
           ,crapcco.cdhistor
           ,crapcco.nrdctabb
           ,crapcco.nrconven
           ,crapcco.flgutceb
           ,crapcco.flgregis
           ,crapcco.rowid
      FROM crapcco
     WHERE crapcco.cdcooper = pr_cdcooper
       AND crapcco.cddbanco = 85        
       AND crapcco.nrconven = pr_nrconven;
    rw_crapcco2 cr_crapcco2%ROWTYPE;    
       
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    --Tabelas 
    vr_tab_rejeita  COBR0006.typ_tab_rejeita; 
    vr_tab_linhas   gene0009.typ_tab_linhas; 
    vr_tab_campos   gene0009.typ_tab_campos;
    vr_split        gene0002.typ_split := gene0002.typ_split();
    vr_tab_listarqu gene0002.typ_split;
    
    --Variaveis locais
    vr_flgfirst BOOLEAN := FALSE;    
    vr_flgutceb crapcco.flgutceb%TYPE;                                 
    vr_dsnosnum VARCHAR2(17);
    vr_nrdconta crapass.nrdconta%TYPE;
    vr_nmprimtl crapass.nmprimtl%TYPE;
    vr_tpcritic INTEGER;
    vr_dslocali VARCHAR2(100);
    vr_nrcepsac NUMBER(15); 
    vr_vlrtotal NUMBER  := 0;
    vr_contalin INTEGER := 0;
    vr_contaerr INTEGER := 0;
    vr_critica  VARCHAR2(400);
    vr_des_reto VARCHAR2(4);
    vr_nrcnvcob crapcco.nrconven%TYPE;
    vr_dscriti1 VARCHAR2(40);
    vr_dscriti2 VARCHAR2(40);
    vr_dsdireto VARCHAR2(500);
    vr_nmarquiv VARCHAR2(500);
    vr_listarqu VARCHAR2(4000);
    vr_dsdinstr VARCHAR2(230); 
    vr_tpdmulta NUMBER(5);
    vr_vltitulo NUMBER(15,2);
    vr_vldmulta NUMBER(15,2);
    vr_nrinssac crapcob.nrinssac%TYPE;
    vr_dsdemail VARCHAR2(5000);
    vr_nrcelsac crapsab.nrcelsac%TYPE;
    vr_idx      PLS_INTEGER;
    
  BEGIN
    
    vr_tab_rejeita.delete;
    
    IF trim(pr_nmarqint) IS NULL THEN
      
      COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                ,pr_nrlinseq => '99999'
                                ,pr_cdseqcri => (nvl(vr_tab_rejeita.count(),0)+1)
                                ,pr_dscritic => 'Arquivo nao encontrado.'
                                ,pr_tab_rejeita => vr_tab_rejeita 
                                ,pr_critica => vr_critica      
                                ,pr_des_reto => vr_des_reto);
         
      RAISE vr_exc_erro;
      
    END IF; 
    
    -- separa diretorio e nmarquivo
    gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmarqint, 
                                    pr_direto  => vr_dsdireto, 
                                    pr_arquivo => vr_nmarquiv);
    
    -- Buscar arquivo a ser importado
    gene0001.pc_lista_arquivos(pr_path     => vr_dsdireto
                              ,pr_pesq     => vr_nmarquiv
                              ,pr_listarq  => vr_listarqu
                              ,pr_des_erro => vr_dscritic);

    -- Se ocorrer erro ao recuperar lista de arquivos, registra no log
    IF TRIM(vr_dscritic) IS NOT NULL THEN 
      vr_dscritic := 'Nao foi possivel localizar arquivo '||pr_nmarqint||': '||vr_dscritic;

      COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                ,pr_nrlinseq => '99999'
                                ,pr_cdseqcri => (nvl(vr_tab_rejeita.count(),0)+1)
                                ,pr_dscritic => vr_dscritic
                                ,pr_tab_rejeita => vr_tab_rejeita 
                                ,pr_critica => vr_critica      
                                ,pr_des_reto => vr_des_reto);

      RAISE vr_exc_erro;
    END IF;
    
    vr_tab_listarqu := gene0002.fn_quebra_string(pr_string => vr_listarqu,
                                                 pr_delimit => ',');   
          
    -- Processar arquivos
    FOR i IN vr_tab_listarqu.first..vr_tab_listarqu.last LOOP
      
      vr_flgfirst := FALSE;
      vr_vlrtotal := 0;
      vr_tab_linhas.delete;
            
      --> Ler arquivo conforme configurado no cadastro de layout 
      gene0009.pc_importa_arq_layout(pr_nmlayout   => 'CNAB240'          --> Nome do Layout do arquivo a ser importado
                                    ,pr_dsdireto   => vr_dsdireto        --> Descrição do diretorio onde o arquivo se enconta
                                    ,pr_nmarquiv   => vr_tab_listarqu(i) --> Nome do arquivo a ser importado
                                    ,pr_dscritic   => vr_dscritic        --> Retorna critica Caso ocorra
                                    ,pr_tab_linhas => vr_tab_linhas);    --> Retorna as linhas/campos do arquivo na temptable
                                      
      IF TRIM(vr_dscritic) IS NOT NULL THEN

        COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                  ,pr_nrlinseq => '99999'
                                  ,pr_cdseqcri => (nvl(vr_tab_rejeita.count(),0)+1)
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_tab_rejeita => vr_tab_rejeita 
                                  ,pr_critica => vr_critica      
                                  ,pr_des_reto => vr_des_reto);

        RAISE vr_exc_erro;
      END IF;
      
      IF vr_tab_linhas.count = 0 THEN
        
        vr_cdcritic := 999;
        vr_dscritic := 'Arquivo vazio.';

        COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                  ,pr_nrlinseq => '99999'
                                  ,pr_cdseqcri => (nvl(vr_tab_rejeita.count(),0)+1)
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_tab_rejeita => vr_tab_rejeita 
                                  ,pr_critica => vr_critica      
                                  ,pr_des_reto => vr_des_reto);

        RAISE vr_exc_erro; 
         
      ELSE
        
        vr_contalin := 0;  
        vr_contaerr := 0; 
        vr_dscriti1 := 'Informar valores numericos.';
        vr_dscriti2 := 'Deve ser campo CARACTER';
              
        --> Varrer linhas do arquivo
        FOR vr_idlinha IN vr_tab_linhas.first..vr_tab_linhas.last LOOP
          
          vr_tab_campos := vr_tab_linhas(vr_idlinha);
          
          vr_contalin := vr_contalin + 1;
                    
          -------------------  Header do Arquivo --------------------
          IF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'HA' THEN 
           
            --Problemas com importacao do layout
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN 
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            --> Cod. Banco na compen.
            IF vr_tab_campos('CDBANCMP').numero <> 85 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 1 ate 3 (Codigo do banco deve ser 085)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Lote do servico
            IF vr_tab_campos('NRLOTSER').numero <> 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 4 ate 7 (Lote do servico deve ser 0000)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Tipo de registro
            IF vr_tab_campos('TPREGIST').numero <> 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 8 ate 8 (Tipo de registro deve ser 0)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Uso exclusivo FEBRABAN
            IF vr_tab_campos('DSUSOFEB').texto IS NOT NULL    AND
               vr_tab_campos('DSUSOFEB').texto <> '000000000' THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 9 ate 17 (Preencher com brancos)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            END IF;
          
            --> Numero de inscricao
            IF vr_tab_campos('NRCPFCGC').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 19 ate 32 (Informar numero de inscricao da empresa)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
          
            --> Agencia
            IF vr_tab_campos('CDAGENCI').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 53 ate 57 (Informar agencia mantenedora da conta)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --Busca convenio
            OPEN cr_crapcco(pr_cdcooper => pr_cdcooper
                           ,pr_nrconven => to_number(vr_tab_campos('NRCONVEN').texto));
                           
            FETCH cr_crapcco INTO rw_crapcco;
            
            IF cr_crapcco%NOTFOUND THEN
              
              CLOSE cr_crapcco;
              
              vr_contaerr := vr_contaerr + 1;
              
              vr_split := gene0002.fn_quebra_string(pr_string  => gene0001.fn_busca_critica(563)
                                                   ,pr_delimit => '-');  
                                                   
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 33 ate 52 ('|| vr_split(2) ||')' 
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                
            ELSE
              
              CLOSE cr_crapcco;
            
              --Utiliza convenio CADCEB
              vr_flgutceb := rw_crapcco.flgutceb;
              vr_nrcnvcob := rw_crapcco.nrconven;
            
            END IF;
              
            --Busca conta
            OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => vr_tab_campos('NRDCONTA').numero);
                           
            FETCH cr_crapass INTO rw_crapass;
            
            IF cr_crapass%NOTFOUND THEN
              
              CLOSE cr_crapass;
                            
              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic =>  'Posicao: 59 ate 71 (Conta do cooperado nao cadastrada)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            
            ELSE
              
              CLOSE cr_crapass;
              
              vr_nmprimtl := rw_crapass.nmprimtl;
              vr_nrdconta := rw_crapass.nrdconta;
            
            END IF;
            
            --Possui convenio CECRED
            OPEN cr_crapceb(pr_cdcooper => pr_cdcooper
                           ,pr_nrconven => vr_nrcnvcob
                           ,pr_nrdconta => vr_nrdconta);
                             
            FETCH cr_crapceb INTO rw_crapceb;
            
            IF cr_crapceb%NOTFOUND THEN
                
              CLOSE cr_crapceb;
              
              vr_contaerr := vr_contaerr + 1;
                   
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr    
                                        ,pr_dscritic => 'Posicao: 33 ate 52 (Convenio de cobranca nao habilitado)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
             
              
            ELSE
                
              CLOSE cr_crapceb; 
              
              IF rw_crapceb.insitceb <> 1 THEN
              
                vr_contaerr := vr_contaerr + 1;
                   
                COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                          ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                          ,pr_cdseqcri => vr_contaerr    
                                          ,pr_dscritic => 'Posicao: 33 ate 52 (Convenio de cobranca inativo)'
                                          ,pr_tab_rejeita => vr_tab_rejeita 
                                          ,pr_critica => vr_critica      
                                          ,pr_des_reto => vr_des_reto);              
              
              END IF;
              
            END IF;            
            
            --> Se convenio esta cadastrado como envio FTP
            --> Só podera ser importado via FTP
            IF rw_crapceb.inenvcob = 2 AND 
               pr_tpenvcob <> 2 THEN
               
              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic =>  'Convenio cadastrado para apenas ser enviado via FTP.'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                         
            END IF;      
            
            --> Nome do cooperado
            IF vr_tab_campos('NMEMPRES').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 73 ate 102 (Informar nome do cooperado)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Nome da cooperativa
            IF vr_tab_campos('NMDBANCO').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 103 ate 132 (Informar nome da cooperativa)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
          --------------------  Header do Lote ---------------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'HL' THEN   
          
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            --> Cod. Banco na compensa.
            IF vr_tab_campos('CDBANCMP').numero <> 85 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 1 ate 3 (Codigo do banco deve ser 085)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
                        
            --> Lote do servico
            IF vr_tab_campos('NRLOTSER').numero <> 1 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 4 ate 7 (Lote do servico deve ser 0001)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Tipo de registro
            IF vr_tab_campos('TPREGIST').numero <> 1 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 8 ate 8 (Tipo de registro deve ser 1)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Tipo de servico 
            IF vr_tab_campos('TPSERVIC').numero <> 1 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 10 ate 11 (Tipo de servico deve ser 01)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Exclusivo FEBRABAN
            IF vr_tab_campos('DSUSOFEB').texto IS NOT NULL AND
               vr_tab_campos('DSUSOFEB').texto <> '00'     THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 12 ate 13 (Preencher com brancos)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Uso exclusivo Febraban
            IF vr_tab_campos('DSUSOFEB2').texto IS NOT NULL AND
               vr_tab_campos('DSUSOFEB2').texto <> '0'      THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 17 ate 17 (Preencher com brancos)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Numero de Inscricao da empresa
            IF vr_tab_campos('NRCPFCGC').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 19 ate 33 (Informar numero de inscricao da empresa)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
                        
            --> Agencia
            IF vr_tab_campos('CDAGENCI').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 54 ate 58 (Informar agencia mantenedora da conta)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --Busca convenio
            OPEN cr_crapcco2(pr_cdcooper => pr_cdcooper                           
                            ,pr_nrconven => to_number(vr_tab_campos('NRCONVEN').texto));
                           
            FETCH cr_crapcco2 INTO rw_crapcco2;
            
            IF cr_crapcco2%NOTFOUND THEN
              
              CLOSE cr_crapcco2;
              
              vr_contaerr := vr_contaerr + 1;
                                
              vr_split := gene0002.fn_quebra_string(pr_string  => gene0001.fn_busca_critica(563)
                                                   ,pr_delimit => '-');                                                        
                 
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 34 ate 53 ('|| vr_split(2) ||')' 
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                
            ELSE
              
              CLOSE cr_crapcco2;
                        
            END IF;
                       
            --Busca conta
            OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => vr_nrdconta);
                           
            FETCH cr_crapass INTO rw_crapass;
            
            IF cr_crapass%NOTFOUND THEN
              
              CLOSE cr_crapass;
                            
              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic =>  'Posicao: 60 ate 72 (Conta do cooperado nao cadastrada)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            
            ELSE
              
              CLOSE cr_crapass;
              
            END IF;
            
            --> Nome da empresa
            IF vr_tab_campos('NMEMPRES').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 2
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 74 a 103 (Informar nome da empresa)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
                       
          ---------------  Detalhe ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'P' THEN    
           
            vr_vltitulo := 0;
            
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            -- Formatar nosso numero com 17 posicoes para separa o numero da conta e o numero do boleto
            vr_dsnosnum := to_char(TRIM(vr_tab_campos('DSNOSNUM').texto),'fm00000000000000000'); 
                        
            --> Conta corrente
            IF vr_nrdconta <> vr_tab_campos('NRDCONTA').numero THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => vr_tab_campos('NRDCONTA').numero
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 24 ate 36 (Conta informada diferente do header)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            
            END IF;
            
            --> Agencia Mantenedora da Conta
            IF vr_tab_campos('CDAGENCI').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 18 ate 22 (Informar agencia mantenedora da conta)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            
            
            END IF;
            
            --> Conta corrente
            IF vr_tab_campos('NRDCONTA').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 24 ate 35 (Informar numero da conta)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            
            END IF;
            
            --> Numero do documento
            IF vr_tab_campos('NRDOCMTO').texto IS NULL OR
               vr_tab_campos('NRDOCMTO').texto = 0 THEN

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 63 ate 77 (Informar numero do documento de cobranca)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            
            
            END IF;
            
            vr_vltitulo := vr_tab_campos('VLTITULO').numero;
            
            --> Valor do Titulo
            IF vr_tab_campos('VLTITULO').numero = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 86 ate 100 (Informar valor do titulo)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            
            
            END IF;            
            
          ---------------  Detalhe - Segmento Q ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'Q' THEN
            
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            --> Nome do sacado
            IF vr_tab_campos('NMDSACAD').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 34 ate 73 (Informar o nome do sacado)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          

            END IF;
            
            --> Endereco
            IF vr_tab_campos('DSENDSAC').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 74 ate 113 (Informar Endereco)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          

            END IF;
            
            --> Bairro
            IF vr_tab_campos('NMBAISAC').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 114 ate 128 (Informar Bairro)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          

            END IF;
            
            IF nvl(vr_tab_campos('NRCEPSAC').numero,0) = 0 THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 129 ate 136 (Informar CEP)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          

            END IF;
            
            -- Cidade
            IF vr_tab_campos('NMCIDSAC').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 137 ate 151 (Informar Cidade)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          

            END IF;
            
            -- Unidade da Federacao
            IF vr_tab_campos('CDUFSACA').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 152 ate 153 (Informar U.F.)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          

            END IF;
            
            vr_nrinssac := vr_tab_campos('NRINSAVA').numero;
             
          ----- Segmento S
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'S' THEN
          
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            IF vr_tab_campos('CDMOVRE').numero  = 1 AND 
               vr_tab_campos('IDIMPRES').numero = 3 THEN

              /* Concatena instrucoes separadas por _   */
              vr_dsdinstr := fn_remove_chr_especial(vr_tab_campos('DSMENSG5').texto || '_' ||
                             vr_tab_campos('DSMENSG5').texto || '_' ||
                             vr_tab_campos('DSMENSG6').texto || '_' ||
                             vr_tab_campos('DSMENSG7').texto || '_' ||
                             vr_tab_campos('DSMENSG8').texto || '_' ||
                                                    vr_tab_campos('DSMENSG9').texto);
                                          
              IF trim(vr_dsdinstr) IS NULL THEN
                
                vr_contaerr := vr_contaerr + 1;               
              
                COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                        ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 19 ate 218 (Informar Mensagem)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                
              END IF; 
                                          
                                                        
            END IF;
            
          ----- Segmento R
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'R' THEN
          
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            IF vr_tab_campos('CDMOVRE').numero = 1 THEN

              -- Valida Codigo da Multa
              vr_tpdmulta := vr_tab_campos('TPDMULTA').numero;
              
              IF vr_tpdmulta <> 1 AND  -- Valor Fixo
                 vr_tpdmulta <> 2 THEN -- Percentual
                -- Codigo da Multa Invalido
                vr_contaerr := vr_contaerr + 1;               
              
                COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                          ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                          ,pr_cdseqcri => vr_contaerr
                                          ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                          ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 66 ate 66 (Codigo da multa invalido)'
                                          ,pr_tab_rejeita => vr_tab_rejeita 
                                          ,pr_critica => vr_critica      
                                          ,pr_des_reto => vr_des_reto);
                                          
              END IF;

              -- Valida Valor da Multa
              vr_vldmulta := vr_tab_campos('VLDMULTA').numero;
              
              -- se nao possui valor de multa, colocar o tipo de multa para 3-Isento
              IF vr_vldmulta = 0 THEN
                 vr_tpdmulta := 3;
              ELSE
                IF vr_tpdmulta = 1 THEN -- Valor Fixo
                  IF vr_vldmulta > vr_vltitulo THEN
                    --Valor/Percentual da Multa Invalido
                    vr_contaerr := vr_contaerr + 1;               
                  
                    COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                              ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                              ,pr_cdseqcri => vr_contaerr
                                              ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                              ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 75 ate 89 (Valor/Percentual da Multa Invalido)'
                                              ,pr_tab_rejeita => vr_tab_rejeita 
                                              ,pr_critica => vr_critica      
                                              ,pr_des_reto => vr_des_reto);
                          
                  END IF;
                ELSE -- Percentual
                  IF vr_vldmulta > 100  THEN
                    -- Valor/Percentual da Multa Invalido
                    vr_contaerr := vr_contaerr + 1;               
                  
                    COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                              ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                              ,pr_cdseqcri => vr_contaerr
                                              ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                              ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 75 ate 89 (Valor/Percentual da Multa Invalido)'
                                              ,pr_tab_rejeita => vr_tab_rejeita 
                                              ,pr_critica => vr_critica      
                                              ,pr_des_reto => vr_des_reto);
                          
                  END IF;
                END IF;
              END IF;                                          
                                                        
            END IF;
            
          ----- Segmento Y04
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'Y04' THEN
          
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            IF vr_tab_campos('TPREGOPC').numero = 3 THEN

              -- 09.4Y - E-mail para envio da informacao
              vr_dsdemail := vr_tab_campos('DSDEMAIL').texto;
              -- 10.4Y 11.4Y - Celular do pagador
              vr_nrcelsac := vr_tab_campos('NRCELSAC').texto;

              COBR0006.pc_altera_email_cel_sacado(pr_cdcooper => pr_cdcooper    --Cooperativa 
                                                 ,pr_nrdconta => vr_nrdconta    --Conta
                                                 ,pr_nrinssac => vr_nrinssac    --Inscrição do sacado
                                                 ,pr_dsdemail => vr_dsdemail     --E-mail
                                                 ,pr_nrcelsac => vr_nrcelsac    --Número do celular
                                                 ,pr_des_erro => vr_des_reto    --Retorno OK/NOK
                                                 ,pr_cdcritic => vr_cdcritic    --Codigo Critica
                                                 ,pr_dscritic => vr_dscritic);  --Tabela de erros 
             
              -- 09.4Y - E-mail para envio da informacao
              vr_dsdemail := ' ';
              -- 10.4Y 11.4Y - Celular do pagador
              vr_nrcelsac := 0;
              
              vr_nrinssac := 0;
                                                        
            END IF;
            
          ---------------  Trailer do Lote ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'TL' THEN
          
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 4
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            IF vr_tab_campos('TPREGIST').numero <> 5 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              vr_split := gene0002.fn_quebra_string(pr_string  => gene0001.fn_busca_critica(468)
                                                   ,pr_delimit => '-');                                                        
                 
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 4
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 8 ate 8 ('|| vr_split(2) ||')' 
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
                        

          ---------------  Trailer do arquivo ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'TA' THEN
                 
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 5
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            IF vr_tab_campos('NRLOTSER').numero <> 9999 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 5
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 4 ate 7 (Lote do servico deve ser 9999)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            IF vr_tab_campos('TPREGIST').numero <> 9 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 5
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 8 ate 8 (Tipo de registro deve ser 9)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
          
            IF vr_tab_campos('DSUSOFEB').texto IS NOT NULL THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 5
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 9 ate 17 (Preencher com brancos)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
          
            -- Qtd. Lotes do arquivo
            IF vr_tab_campos('QTLOTARQ').numero <> 1 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 5
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 18 ate 23 (Qtd. de Lotes do arquivo eh 0001)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
          
            IF vr_tab_campos('QTREGARQ').numero <> vr_contalin THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 5
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 24 ate 29 (Quantidade de registros do arquivo esta errada => ' 
                                                        || to_char(vr_contalin,'000000') || ' )'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
          
          ----- Segmento Y53
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'Y53' THEN
          
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;     
            
           
            --Busca conveio
            OPEN cr_crapceb(pr_cdcooper => pr_cdcooper
                           ,pr_nrconven => vr_nrcnvcob
                           ,pr_nrdconta => vr_nrdconta);
                             
            FETCH cr_crapceb INTO rw_crapceb;
            
            -- Verifica se há permissão para pagamento divergente
            IF cr_crapceb%NOTFOUND OR rw_crapceb.flgpgdiv <> 1 THEN
              CLOSE cr_crapceb;
              
              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                            ,pr_nrlinseq => to_char(vr_contalin,'00000')
                            ,pr_cdseqcri => vr_contaerr
                            ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                            ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')(tipo de pagamento invalido.)'
                            ,pr_tab_rejeita => vr_tab_rejeita 
                            ,pr_critica => vr_critica      
                            ,pr_des_reto => vr_des_reto); 
             ELSE
              CLOSE cr_crapceb; 
             END IF;

            -- Quantidade de pagamentos possíveis
            IF vr_tab_campos('NRQTPAG').numero <> 1 THEN
              
                vr_contaerr := vr_contaerr + 1;               
              
                COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                          ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                          ,pr_cdseqcri => vr_contaerr
                                          ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                          ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 22 ate 23 (Quantidade de parcelas invalida.)'
                                          ,pr_tab_rejeita => vr_tab_rejeita 
                                          ,pr_critica => vr_critica      
                                          ,pr_des_reto => vr_des_reto);            
              
            END IF;

            -- Tipo de Valor Informado (Valor Máximo)
            IF vr_tab_campos('TPVLMAX').numero <> 2 THEN
              
                vr_contaerr := vr_contaerr + 1;               
                                        
                COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                          ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                          ,pr_cdseqcri => vr_contaerr
                                          ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                          ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 24 ate 24 (Tipo de valor invalido.)'
                                          ,pr_tab_rejeita => vr_tab_rejeita 
                                          ,pr_critica => vr_critica      
                                          ,pr_des_reto => vr_des_reto); 
              
            END IF;
            
            -- Tipo de Valor Informado (Valor Mínimo)
            IF vr_tab_campos('TPVLMIN').numero <> 2 THEN
              
                vr_contaerr := vr_contaerr + 1;               
              
                COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                          ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                          ,pr_cdseqcri => vr_contaerr
                                          ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                          ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Posicao: 40 ate 40 (Tipo de valor invalido.)'
                                          ,pr_tab_rejeita => vr_tab_rejeita 
                                          ,pr_critica => vr_critica      
                                          ,pr_des_reto => vr_des_reto); 
              
            END IF;            
                                        
          ELSE
          
            vr_contaerr := vr_contaerr + 1;
              
            COBR0006.pc_cria_rejeitado(pr_tpcritic => 3
                                      ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                      ,pr_cdseqcri => vr_contaerr
                                      ,pr_seqdetal => to_char(vr_tab_campos('NRSEQLOT').numero,'00000')
                                      ,pr_dscritic =>  '(' || vr_tab_campos('CDSEQDET').texto || ')Este tipo de Registro nao eh tratado.'
                                      ,pr_tab_rejeita => vr_tab_rejeita 
                                      ,pr_critica => vr_critica      
                                      ,pr_des_reto => vr_des_reto);
        
          END IF;
          
         END LOOP;    
         
       END IF;
       
    END LOOP;
    
    vr_contaerr := 0;
    vr_tpcritic := 0;
    
    -- Percorrer todos os registros rejeitados
    FOR vr_idx IN 1..vr_tab_rejeita.COUNT() LOOP
            
      vr_contaerr := vr_contaerr + 1;
            
      IF vr_tpcritic <>  vr_tab_rejeita(vr_idx).tpcritic THEN -- vr_tab_rejeita(vr_idx).tpcritic THEN
        
        CASE vr_tab_rejeita(vr_idx).tpcritic
          WHEN 1 THEN
            vr_dslocali := 'Header do Arquivo';
          WHEN 2 THEN
            vr_dslocali := 'Header do Lote';  
          WHEN 3 THEN
            vr_dslocali := 'Detalhe do Arquivo';
          WHEN 4 THEN
            vr_dslocali := 'Trailer do Lote';
          ELSE
            vr_dslocali := 'Trailer do Arquivo';  
          
        END CASE;   
        
        COBR0006.pc_cria_rejeitado(pr_tpcritic => vr_tab_rejeita(vr_idx).tpcritic
                                  ,pr_cdseqcri => vr_contaerr
                                  ,pr_dscritic => '==>  ' ||  vr_dslocali
                                  ,pr_tab_rejeita => pr_rec_rejeita 
                                  ,pr_critica => vr_critica      
                                  ,pr_des_reto => vr_des_reto);

        vr_contaerr := vr_contaerr + 1;
        vr_tab_rejeita(vr_idx).cdseqcri := vr_contaerr; 
        vr_tpcritic := vr_tab_rejeita(vr_idx).tpcritic;
        
        COBR0006.pc_cria_rejeitado(pr_tpcritic => vr_tab_rejeita(vr_idx).tpcritic
                                  ,pr_nrlinseq => vr_tab_rejeita(vr_idx).nrlinseq
                                  ,pr_cdseqcri => vr_contaerr
                                  ,pr_seqdetal => vr_tab_rejeita(vr_idx).seqdetal                                  
                                  ,pr_dscritic => vr_tab_rejeita(vr_idx).dscritic
                                  ,pr_tab_rejeita => pr_rec_rejeita 
                                  ,pr_critica => vr_critica      
                                  ,pr_des_reto => vr_des_reto);
        
      ELSE
        
        vr_tab_rejeita(vr_idx).cdseqcri := vr_contaerr;  
        
        COBR0006.pc_cria_rejeitado(pr_tpcritic => vr_tab_rejeita(vr_idx).tpcritic
                                  ,pr_nrlinseq => vr_tab_rejeita(vr_idx).nrlinseq        
                                  ,pr_cdseqcri => vr_contaerr
                                  ,pr_seqdetal => vr_tab_rejeita(vr_idx).seqdetal                                  
                                  ,pr_dscritic => vr_tab_rejeita(vr_idx).dscritic
                                  ,pr_tab_rejeita => pr_rec_rejeita 
                                  ,pr_critica => vr_critica      
                                  ,pr_des_reto => vr_des_reto);
                                  
      END IF;
        
    END LOOP;
    
    pr_des_reto := 'OK';
    
  EXCEPTION  
    WHEN vr_exc_erro THEN         
    begin
      if nvl(pr_rec_rejeita.count(),0) = 0 and nvl(vr_tab_rejeita.count(),0) > 0 then

        vr_contaerr := 0;
        vr_tpcritic := 0;
        
        -- Percorrer todos os registros rejeitados
        FOR vr_idx IN 1..vr_tab_rejeita.COUNT() LOOP
                
          vr_contaerr := vr_contaerr + 1;
                
          IF vr_tpcritic <>  vr_tab_rejeita(vr_idx).tpcritic THEN -- vr_tab_rejeita(vr_idx).tpcritic THEN
            
            CASE vr_tab_rejeita(vr_idx).tpcritic
              WHEN 1 THEN
                vr_dslocali := 'Header do Arquivo';
              WHEN 2 THEN
                vr_dslocali := 'Header do Lote';  
              WHEN 3 THEN
                vr_dslocali := 'Detalhe do Arquivo';
              WHEN 4 THEN
                vr_dslocali := 'Trailer do Lote';
              ELSE
                vr_dslocali := 'Trailer do Arquivo';  
              
            END CASE;   
            
            COBR0006.pc_cria_rejeitado(pr_tpcritic => vr_tab_rejeita(vr_idx).tpcritic
                                      ,pr_cdseqcri => vr_contaerr
                                      ,pr_dscritic => '==>  ' ||  vr_dslocali
                                      ,pr_tab_rejeita => pr_rec_rejeita 
                                      ,pr_critica => vr_critica      
                                      ,pr_des_reto => vr_des_reto);

            vr_contaerr := vr_contaerr + 1;
            vr_tab_rejeita(vr_idx).cdseqcri := vr_contaerr; 
            vr_tpcritic := vr_tab_rejeita(vr_idx).tpcritic;
            
            COBR0006.pc_cria_rejeitado(pr_tpcritic => vr_tab_rejeita(vr_idx).tpcritic
                                      ,pr_nrlinseq => vr_tab_rejeita(vr_idx).nrlinseq
                                      ,pr_cdseqcri => vr_contaerr
                                      ,pr_seqdetal => vr_tab_rejeita(vr_idx).seqdetal                                  
                                      ,pr_dscritic => vr_tab_rejeita(vr_idx).dscritic
                                      ,pr_tab_rejeita => pr_rec_rejeita 
                                      ,pr_critica => vr_critica      
                                      ,pr_des_reto => vr_des_reto);
            
          ELSE
            
            vr_tab_rejeita(vr_idx).cdseqcri := vr_contaerr;  
            
            COBR0006.pc_cria_rejeitado(pr_tpcritic => vr_tab_rejeita(vr_idx).tpcritic
                                      ,pr_nrlinseq => vr_tab_rejeita(vr_idx).nrlinseq        
                                      ,pr_cdseqcri => vr_contaerr
                                      ,pr_seqdetal => vr_tab_rejeita(vr_idx).seqdetal                                  
                                      ,pr_dscritic => vr_tab_rejeita(vr_idx).dscritic
                                      ,pr_tab_rejeita => pr_rec_rejeita 
                                      ,pr_critica => vr_critica      
                                      ,pr_des_reto => vr_des_reto);
                                      
          END IF;
            
        END LOOP;
      end if;

      pr_des_reto := 'NOK';

    end;
       
    WHEN OTHERS THEN
      
      pr_des_reto := 'NOK';
            
  END pc_importa_cnab240_085;   
  
  --> Realiza a validação do arquivo cnab400_085
  PROCEDURE pc_importa_cnab400_085 (pr_cdcooper    IN crapcop.cdcooper%TYPE      --> Codigo da cooperativa
                                   ,pr_nmarqint    IN VARCHAR2                   --> Nome do arquivo a ser validado
                                   ,pr_tpenvcob    IN crapceb.inenvcob%TYPE DEFAULT 1 --> Tipo de envio do arquivo (1-Envio via Internet Bank, 2-Envio via FTP)
                                   ,pr_rec_rejeita OUT COBR0006.typ_tab_rejeita  --> Dados invalidados
                                   ,pr_des_reto    OUT VARCHAR2) IS              --> Retorno OK/NOK
                                                                               
  /* ............................................................................

       Programa: pc_importa_cnab400_085                                            antigo: b1wgen0010/p_importa_cnab400_085    
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrei - RKAM 
       Data    : Marco/2016.                   Ultima atualizacao: 12/03/2019

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Realiza a validação do arquivo cnab400_085

       Alteracoes: 12/03/2019 - Validar numero do boleto zero no arquivo de remessa
                                (Lucas Ranghetti INC0031367)
    ............................................................................ */   
    
    ------------------------------- CURSORES ---------------------------------    
    --> Buscar dados do associado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT ass.nrdconta,
           ass.nrcpfcgc,
           ass.inpessoa,
           ass.cdcooper,
           ass.nmprimtl
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
  
    --> Verifica se convenio esta Homologacao 
    CURSOR cr_crapceb (pr_cdcooper  crapceb.cdcooper%TYPE
                      ,pr_nrconven  crapceb.nrconven%TYPE
                      ,pr_nrdconta  crapceb.nrdconta%TYPE) IS
    SELECT crapceb.insitceb
          ,crapceb.inenvcob
      FROM crapceb
     WHERE crapceb.cdcooper = pr_cdcooper
       AND crapceb.nrconven = pr_nrconven        
       AND crapceb.nrdconta = pr_nrdconta;    
    rw_crapceb cr_crapceb%ROWTYPE;  
    
    --> Codigo do Convenio
    CURSOR cr_crapcco (pr_cdcooper crapcco.cdcooper%TYPE,
                       pr_nrconven crapcco.nrconven%TYPE) IS
      SELECT  crapcco.cddbanco
             ,crapcco.cdagenci
             ,crapcco.cdbccxlt
             ,crapcco.nrdolote
             ,crapcco.cdhistor
             ,crapcco.nrdctabb
             ,crapcco.nrconven
             ,crapcco.flgutceb
             ,crapcco.flgregis
             ,crapcco.rowid
        FROM crapcco
       WHERE crapcco.cdcooper = pr_cdcooper
         AND crapcco.cddbanco = 85
         AND crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE'
         AND crapcco.nrconven = pr_nrconven;
    rw_crapcco cr_crapcco%ROWTYPE;    
       
    ------------------------------- VARIAVEIS -------------------------------
    
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    --Tabelas
    vr_tab_rejeita   COBR0006.typ_tab_rejeita; 
    vr_tab_listarqu  gene0002.typ_split;
    vr_tab_linhas    gene0009.typ_tab_linhas; 
    vr_tab_campos    gene0009.typ_tab_campos;
    vr_split         gene0002.typ_split := gene0002.typ_split();
    
    --Variaveis locais
    vr_flgutceb crapcco.flgutceb%TYPE;
    vr_flgfirst BOOLEAN := FALSE;                                       
    vr_nrdconta crapass.nrdconta%TYPE;
    vr_nmprimtl crapass.nmprimtl%TYPE;
    vr_tpcritic INTEGER;
    vr_dslocali VARCHAR2(100);
    vr_vlrtotal NUMBER  := 0;
    vr_contalin INTEGER := 0;
    vr_contaerr INTEGER := 0;
    vr_critica  VARCHAR2(400);
    vr_des_reto VARCHAR2(4);
    vr_nrcnvcob crapcco.nrconven%TYPE;
    vr_dscriti1 VARCHAR2(100);
    vr_dscriti2 VARCHAR2(100);
    vr_dsdireto VARCHAR2(500);
    vr_nmarquiv VARCHAR2(500);
    vr_listarqu VARCHAR2(4000);
    vr_idx      PLS_INTEGER;
    
  BEGIN
    
    vr_tab_rejeita.delete;
    
    IF trim(pr_nmarqint) IS NULL THEN
      
      COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                ,pr_nrlinseq => '99999'
                                ,pr_cdseqcri => 1
                                ,pr_dscritic => 'Arquivo nao encontrado)'
                                ,pr_tab_rejeita => vr_tab_rejeita 
                                ,pr_critica => vr_critica      
                                ,pr_des_reto => vr_des_reto);
         
      RAISE vr_exc_erro;
      
    END IF; 
    
    -- separa diretorio e nmarquivo
    gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmarqint, 
                                    pr_direto  => vr_dsdireto, 
                                    pr_arquivo => vr_nmarquiv);
    
    -- Buscar arquivo a ser importado
    gene0001.pc_lista_arquivos(pr_path     => vr_dsdireto
                              ,pr_pesq     => vr_nmarquiv
                              ,pr_listarq  => vr_listarqu
                              ,pr_des_erro => vr_dscritic);

    -- Se ocorrer erro ao recuperar lista de arquivos, registra no log
    IF TRIM(vr_dscritic) IS NOT NULL THEN
       
      vr_dscritic := 'Nao foi possivel localizar arquivo '||pr_nmarqint||': '||vr_dscritic;
      RAISE vr_exc_erro;
      
    END IF;
    
    vr_tab_listarqu := gene0002.fn_quebra_string(pr_string => vr_listarqu,
                                                 pr_delimit => ',');   
          
    -- Processar arquivos
    FOR i IN vr_tab_listarqu.first..vr_tab_listarqu.last LOOP
      
      vr_flgfirst := FALSE;
      vr_vlrtotal := 0;
      vr_tab_linhas.delete;
            
      --> Ler arquivo conforme configurado no cadastro de layout 
      gene0009.pc_importa_arq_layout( pr_nmlayout   => 'CNAB400'          --> Nome do Layout do arquivo a ser importado
                                     ,pr_dsdireto   => vr_dsdireto        --> Descrição do diretorio onde o arquivo se enconta
                                     ,pr_nmarquiv   => vr_tab_listarqu(i) --> Nome do arquivo a ser importado
                                     ,pr_dscritic   => vr_dscritic        --> Retorna critica Caso ocorra
                                     ,pr_tab_linhas => vr_tab_linhas);    --> Retorna as linhas/campos do arquivo na temptable
                                      
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      IF vr_tab_linhas.count = 0 THEN
        
        vr_cdcritic := 999;
        vr_dscritic := 'Arquivo vazio.';
         
        RAISE vr_exc_erro; 
         
      ELSE
        
        vr_contalin := 0;  
        vr_contaerr := 0; 
        vr_dscriti1 := 'Informar valores numericos.';
        vr_dscriti2 := 'Deve ser campo CARACTER';
              
        --> Varrer linhas do arquivo
        FOR vr_idlinha IN vr_tab_linhas.first..vr_tab_linhas.last LOOP
          
          vr_tab_campos := vr_tab_linhas(vr_idlinha);
          
          vr_contalin := vr_contalin + 1;
          
          -------------------  Header do Arquivo --------------------
          IF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'HA' THEN 
           
            --Problemas com importacao do layout
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN 
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            --> Cod. Banco na compen.
            IF vr_tab_campos('DSCEDENT').numero <> 85 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 77 ate 94 (Codigo do banco deve ser 085)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Tipo de registro
            IF vr_tab_campos('TPREGIST').numero <> 0 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 1 ate 1 (Tipo de registro deve ser 0)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Tipo de operacao - Fixo
            IF vr_tab_campos('TPOPERAC').numero <> 1 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 2 ate 2 (Tipo de operacao deve ser 1)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
            --> Tipo de operação - REMESSA
            -- Pode conter a Palavra Teste no tipo de operação, mas até o momento não estou considerando a mesma.
            IF vr_tab_campos('DSTPOPER').texto <> 'REMESSA' THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 3 ate 9 (Tipo de operacao deve ser REMESSA)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            END IF;
            
            --> Identificacao do tipo de servico - Fixo "01"
            IF vr_tab_campos('TPSERVIC').numero <> 1 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 10 ate 11 (Tipo de servico deve ser 01)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            END IF;
            
            --> Tipo de Servico
            IF vr_tab_campos('DSTPSERV').texto <> 'COBRANCA' THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 12 ate 19 (Tipo de servico deve ser COBRANCA)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            END IF;
            
            -->  Complemento do registro 
            IF vr_tab_campos('COMPREGI2').texto <> '000000' THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 41 ate 46 (Complemento registro deve ser 000000)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            END IF;
            
            --> Nome cedente
            IF vr_tab_campos('NMCEDENT').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 47 ate 76 (Nome Beneficiario nao informado)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            END IF;
            
            --> Nome cedente
            IF vr_tab_campos('COMPREGI3').texto IS NOT NULL THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 108 ate 129 (Complemento registro deve ser BRANCOS)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            END IF;
            
            --> Complemento Registro - BRANCOS
            IF vr_tab_campos('COMPREGI4').texto IS NOT NULL THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 137 ate 394 (Complemento registro deve ser BRANCOS)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            END IF;
            
            --Busca convenio
            OPEN cr_crapcco(pr_cdcooper => pr_cdcooper
                           ,pr_nrconven => to_number(vr_tab_campos('NRCONVEN').numero));
                           
            FETCH cr_crapcco INTO rw_crapcco;
            
            IF cr_crapcco%NOTFOUND THEN
              
              CLOSE cr_crapcco;
              
              vr_contaerr := vr_contaerr + 1;
              
              vr_split := gene0002.fn_quebra_string(pr_string  => gene0001.fn_busca_critica(563)
                                                   ,pr_delimit => '-');  
                                                   
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 130 ate 136 ('|| vr_split(2) ||')' 
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                
            ELSE
              
              CLOSE cr_crapcco;
              
              --Utiliza sequencia CADCEB
              vr_flgutceb := rw_crapcco.flgutceb;
              vr_nrcnvcob := rw_crapcco.nrconven;
            
            END IF;
            
            OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => vr_tab_campos('NRDCONTA').numero);
                           
            FETCH cr_crapass INTO rw_crapass;
            
            IF cr_crapass%NOTFOUND THEN
              
              CLOSE cr_crapass;
                            
              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic =>  'Posicao: 32 ate 40 (Conta do cooperado nao cadastrada)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
            
            ELSE
              
              CLOSE cr_crapass;
              
              vr_nmprimtl := rw_crapass.nmprimtl;
              vr_nrdconta := rw_crapass.nrdconta;
              
              OPEN cr_crapceb(pr_cdcooper => pr_cdcooper
                             ,pr_nrconven => vr_nrcnvcob
                             ,pr_nrdconta => vr_nrdconta);
                               
              FETCH cr_crapceb INTO rw_crapceb;
              
              IF cr_crapceb%NOTFOUND THEN
                  
                CLOSE cr_crapceb;
                
                vr_contaerr := vr_contaerr + 1;
                     
                COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                          ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                          ,pr_cdseqcri => vr_contaerr    
                                          ,pr_dscritic => 'Posicao: 33 ate 52 (Convenio de cobranca nao habilitado)'
                                          ,pr_tab_rejeita => vr_tab_rejeita 
                                          ,pr_critica => vr_critica      
                                          ,pr_des_reto => vr_des_reto);
               
                
              ELSE
                  
                CLOSE cr_crapceb; 
                
                IF rw_crapceb.insitceb <> 1 THEN
                
                  vr_contaerr := vr_contaerr + 1;
                     
                  COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                            ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                            ,pr_cdseqcri => vr_contaerr    
                                            ,pr_dscritic => 'Posicao: 33 ate 52 (Convenio de cobranca inativo)'
                                            ,pr_tab_rejeita => vr_tab_rejeita 
                                            ,pr_critica => vr_critica      
                                            ,pr_des_reto => vr_des_reto);              
                
                END IF;
            
              END IF;
              
            END IF;
            
            --> Se convenio esta cadastrado como envio FTP
            --> Só podera ser importado via FTP
            IF rw_crapceb.inenvcob = 2 AND 
               pr_tpenvcob <> 2 THEN
               
              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr                                        
                                        ,pr_dscritic =>  'Convenio cadastrado para apenas ser enviado via FTP.'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                         
            END IF; 
            
          ---------------  Detalhe ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'R' THEN    
           
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
            
            --> Se acabou detalhe
            IF vr_tab_campos('TPREGIST').numero <> 7 AND
               vr_tab_campos('TPREGIST').numero <> 1 AND 
               vr_tab_campos('TPREGIST').numero <> 5 THEN 

              EXIT;
              
            END IF;
              
            --> se registro detalhe tipo 5, eh opcional - sera tratado no futuro
            IF vr_tab_campos('TPREGIST').numero = 5 THEN 

              continue;
              
            END IF;                            
                 
            --> Numero da prestacao é fixo no CNAB400 = "00"
            IF vr_tab_campos('NRPRESTA').numero <> 0 THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic =>  'Posicao: 81 ate 82 (Numero da prestacao deve ser 00)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          
            END IF;
            
            --> Numero do titulo
            IF vr_tab_campos('NRDOCMTO').texto IS NULL OR
               vr_tab_campos('NRDOCMTO').texto = 0 THEN

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic =>  'Posicao: 111 ate 120 (Seu numero do titulo deve ser informado)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          
            END IF;
            
            --> Tipo de inscricao do sacado
            IF vr_tab_campos('TPINSCRI').numero <> 1 AND
               vr_tab_campos('TPINSCRI').numero <> 2 THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic =>  'Posicao: 219 ate 220 (Tipo inscricao do Pagador invalido)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          
            END IF;
            
            --> Nome do sacado 
            IF vr_tab_campos('NMSACADO').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic =>  'Posicao: 235 ate 271 (Nome Pagador deve ser informado)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          
            END IF;
            
            --> Endereco do sacado 
            IF vr_tab_campos('ENDSACAD').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic =>  'Posicao: 275 ate 314 (Endereco Pagador deve ser informado)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          
            END IF;
            
            --> Bairro do sacado 
            IF vr_tab_campos('BAIRRSAC').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic =>  'Posicao: 315 ate 326 (Bairro Pagador deve ser informado)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          
            END IF;
            
            --> Cidade do sacado
            IF vr_tab_campos('CIDSACAD').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic =>  'Posicao: 335 ate 349 (Cidade Pagador deve ser informado)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          
            END IF;
            
            --> UF do sacado
            IF vr_tab_campos('UFSACADO').texto IS NULL THEN 

              vr_contaerr := vr_contaerr + 1;
                
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 1
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic =>  'Posicao: 350 ate 351 (UF da cidade Pagador deve ser informado)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                          
            END IF;
            
            
          ---------------  Trailer do Arquivo ---------------
          ELSIF vr_tab_linhas(vr_idlinha)('$LAYOUT$').texto = 'TA' THEN
          
            IF vr_tab_linhas(vr_idlinha).exists('$ERRO$') THEN --Problemas com importacao do layout
              
              vr_contaerr := vr_contaerr + 1;               
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 4
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => vr_tab_linhas(vr_idlinha)('$ERRO$').texto
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);
                                        
            END IF;
              
            --> Identificacao do registro de trailler
            IF vr_tab_campos('TPREGIST').numero <> 9 THEN 

              vr_contaerr := vr_contaerr + 1;
              
              vr_split := gene0002.fn_quebra_string(pr_string  => gene0001.fn_busca_critica(468)
                                                   ,pr_delimit => '-');                                                        
                 
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 4
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 1 ('|| vr_split(2) ||')' 
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
           
            IF vr_tab_campos('COMPREGI4').texto IS NOT NULL THEN 

              vr_contaerr := vr_contaerr + 1;
              
              COBR0006.pc_cria_rejeitado(pr_tpcritic => 5
                                        ,pr_nrlinseq => to_char(vr_contalin,'00000')
                                        ,pr_cdseqcri => vr_contaerr
                                        ,pr_dscritic => 'Posicao: 2 ate 394 (Preencher com brancos)'
                                        ,pr_tab_rejeita => vr_tab_rejeita 
                                        ,pr_critica => vr_critica      
                                        ,pr_des_reto => vr_des_reto);

            END IF;
            
          END IF;
          
         END LOOP;    
         
       END IF;
       
    END LOOP;
    
    vr_contaerr := 0;
    vr_tpcritic := 0;
    vr_tpcritic := 0;
    
    -- Percorrer todos os registros rejeitados
    FOR vr_idx IN 1..vr_tab_rejeita.COUNT() LOOP
            
      vr_contaerr := vr_contaerr + 1;
            
      IF vr_tpcritic <>  vr_tab_rejeita(vr_idx).tpcritic THEN -- vr_tab_rejeita(vr_idx).tpcritic THEN
        
        CASE vr_tab_rejeita(vr_idx).tpcritic
          WHEN 1 THEN
            vr_dslocali := 'Header do Arquivo';          
          ELSE
            vr_dslocali := 'Trailer do Arquivo';  
          
        END CASE;   
        
        COBR0006.pc_cria_rejeitado(pr_tpcritic => vr_tab_rejeita(vr_idx).tpcritic
                                  ,pr_cdseqcri => vr_contaerr
                                  ,pr_dscritic => '==>  ' ||  vr_dslocali
                                  ,pr_tab_rejeita => pr_rec_rejeita 
                                  ,pr_critica => vr_critica      
                                  ,pr_des_reto => vr_des_reto);

        vr_contaerr := vr_contaerr + 1;
        vr_tab_rejeita(vr_idx).cdseqcri := vr_contaerr; 
        vr_tpcritic := vr_tab_rejeita(vr_idx).tpcritic;
        
        COBR0006.pc_cria_rejeitado(pr_tpcritic => vr_tab_rejeita(vr_idx).tpcritic
                                  ,pr_nrlinseq => vr_tab_rejeita(vr_idx).nrlinseq
                                  ,pr_cdseqcri => vr_contaerr
                                  ,pr_seqdetal => vr_tab_rejeita(vr_idx).seqdetal                                  
                                  ,pr_dscritic => vr_tab_rejeita(vr_idx).dscritic
                                  ,pr_tab_rejeita => pr_rec_rejeita 
                                  ,pr_critica => vr_critica      
                                  ,pr_des_reto => vr_des_reto);
        
      ELSE
        
        vr_tab_rejeita(vr_idx).cdseqcri := vr_contaerr;  
        
        COBR0006.pc_cria_rejeitado(pr_tpcritic => vr_tab_rejeita(vr_idx).tpcritic
                                  ,pr_nrlinseq => vr_tab_rejeita(vr_idx).nrlinseq  
                                  ,pr_cdseqcri => vr_contaerr
                                  ,pr_seqdetal => vr_tab_rejeita(vr_idx).seqdetal
                                  ,pr_dscritic => vr_tab_rejeita(vr_idx).dscritic
                                  ,pr_tab_rejeita => pr_rec_rejeita 
                                  ,pr_critica => vr_critica      
                                  ,pr_des_reto => vr_des_reto);
                                  
      END IF;
        
    END LOOP;
    
    pr_des_reto := 'OK';
    
  EXCEPTION  
    WHEN vr_exc_erro THEN         
      
      pr_des_reto := 'NOK';
       
    WHEN OTHERS THEN
      
      pr_des_reto := 'NOK';
            
  END pc_importa_cnab400_085;   
  
  /* Procedimento do internetbank operação 69 - Arquivo de cobranca */
  PROCEDURE pc_InternetBank69 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                              ,pr_nrdconta IN crapttl.nrdconta%TYPE   --> Numero da conta
                              ,pr_nmarquiv IN VARCHAR2                --> Nome do arquivo
                              ,pr_idorigem IN INTEGER                 --> Ambiente de Origem
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --> Data de movimento
                              ,pr_cdoperad IN VARCHAR2                --> Codigo do operador
                              ,pr_nmdatela IN VARCHAR2                --> Nome da tela
                              ,pr_flvalarq IN INTEGER                 --> 1-TRUE 0-FALSE
                              ,pr_iddirarq IN INTEGER                 --> Indica o diretório de importação (0 - "/usr/coop/COOPERATIVA/upload/" ou 1 - "/usr/coop/SOA/COOPERATIVA/upload/")
                              ,pr_flmobile IN INTEGER                 --> Indicador se origem é do Mobile
                              ,pr_iptransa IN VARCHAR2                --> IP da transacao no IBank/mobile
                              ,pr_xml_dsmsgerr   OUT VARCHAR2         --> Retorno XML de critica
                              ,pr_xml_operacao69 OUT CLOB             --> Retorno XML da operação 26
                              ,pr_dsretorn       OUT VARCHAR2) IS     --> Retorno de critica (OK ou NOK)

    /* ..........................................................................
    
      Programa : pc_InternetBank69        Antiga: sistema/internet/fontes/InternetBank69.p
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Andrei - RKAM
      Data    : Marco/2016.                       Ultima atualizacao: 07/06/2016
   
      Dados referentes ao programa:
       
      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Importar dados de remessa de cobrança enviado pelo cooperado.
          
      Alteracoes: 03/07/2012 - tratamento do cdoperad "operador" de INTE para CHAR.
                               (Lucas R.)   
                           
                  25/04/2013 - Projeto Melhorias da Cobranca - implementar rotina
                               de importacao de titulos CNAB240 - 085. (Rafael)
                            
                  28/09/2013 - Projeto Melhorias da Cobranca - Retornar cddbanco 
                               no XML. (Rafael)
                            
                  11/03/2014 - Correcao fechamento instancia b1wgen0090 (Daniel) 
                  
                  11/03/2016 - Conversao para PL SQL (Andrei - RKAM).
                                                      
                  31/05/2016 - Ajuste para inclusao do controle monitoramento para
                               integracao com Aymaru
                               (Andrei - RKAM).    
                               
                  07/06/2016 - Ajuste para remover o arquivo original da pasta upload
                               (Andrei - RKAM).             
                                    
    .................................................................................*/
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT cop.dsdircop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    ----------------> TEMPTABLE  <---------------
    vr_tab_crawrej              COBR0006.typ_tab_crawrej;
    
    ----------------> VARIAVEIS <---------------
    --Variaveis de Erro
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_tab_rejeita COBR0006.typ_tab_rejeita; 
    vr_dscritic  VARCHAR2(4000);
    
    --Variaveis de Excecao
    vr_exc_erro  EXCEPTION;
        
    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    
    --Variaveis locais
    vr_dstransa VARCHAR2(500) := NULL;
    vr_dslinxml VARCHAR2(4000) := ' ';
    vr_cddbanco INTEGER;
    vr_dsdircop VARCHAR2(500);
    vr_dsarquiv VARCHAR2(500);
    vr_hrtransa INTEGER;
    vr_nrprotoc VARCHAR2(200);
    vr_des_reto VARCHAR2(10);
    vr_tparquiv  VARCHAR2(100);
    vr_dscomand  VARCHAR2(4000);
    vr_typ_said  VARCHAR2(500);
    vr_nrdconta crapass.nrdconta%TYPE;
    
  BEGIN

    GENE0001.pc_set_modulo(pr_module => 'pc_InternetBank69', pr_action => 'pc_InternetBank69');

    --Inicializa variaveis
    vr_cdcritic := 0;
    vr_dscritic := NULL;    
    
    -- Definir descrição da transação    
    vr_dstransa := 'Importar dados de cobranca contidos em arquivo';
        
    --> Verificar cooperativa
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    
    FETCH cr_crapcop INTO rw_crapcop;
      
    --> verificar se encontra registro
    IF cr_crapcop%NOTFOUND THEN
      
      CLOSE cr_crapcop;
      
      vr_dscritic := 'Cooperativa de destino nao cadastrada.';
      
      RAISE vr_exc_erro;
      
    ELSE
      CLOSE cr_crapcop;
    END IF;
      
    vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C', 
                                         pr_cdcooper => pr_cdcooper, 
                                         pr_nmsubdir => NULL);
                                         
    IF pr_iddirarq = 0 THEN -- Diretorio de upload do gnusites                                           
      vr_dsarquiv := vr_dsdircop || '/upload/' || pr_nmarquiv;
    ELSE -- Diretorio de upload do SOA
      vr_dsarquiv := gene0001.fn_diretorio('C',0)                                ||
                     gene0001.fn_param_sistema('CRED',0,'PATH_DOWNLOAD_ARQUIVO') ||
                     '/'                                                         ||
                     rw_crapcop.dsdircop                                         ||
                     '/upload/'                                                  ||
                     pr_nmarquiv;
    END IF;
                                         
    --> Montar xml de retorno dos dados <---
    -- Criar documento XML
    dbms_lob.createtemporary(pr_xml_operacao69, TRUE); 
    dbms_lob.open(pr_xml_operacao69, dbms_lob.lob_readwrite); 
   
    --Se for para validar o arquivo      
    IF pr_flvalarq = 1 THEN
      
      COBR0006.pc_valida_arquivo_cobranca(pr_cdcooper    => pr_cdcooper    --> Codigo da cooperativa
                                         ,pr_nmarqint    => vr_dsarquiv    --> Nome do arquivo a ser validado
                                         ,pr_rec_rejeita => vr_tab_rejeita --> Dados invalidados
                                         ,pr_des_reto    => vr_des_reto);  --> Retorno OK/NOK
                                         
      IF vr_des_reto <> 'OK' THEN
        
        IF vr_tab_rejeita.count() > 0 THEN
          
          --> Montar xml de retorno dos dados <---
          gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao69 
                                 ,pr_texto_completo => vr_xml_temp 
                                 ,pr_texto_novo     => '<rejeitados>');     
          
          FOR i IN vr_tab_rejeita.first..vr_tab_rejeita.last LOOP
            
            --> Montar xml de retorno dos dados <---
            gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao69 
                                   ,pr_texto_completo => vr_xml_temp 
                                   ,pr_texto_novo     => '<cobranca>' || 
                                                            '<tpcritic>' || to_char(vr_tab_rejeita(i).tpcritic) || '</tpcritic>' ||
                                                            '<cdseqcri>' || to_char(vr_tab_rejeita(i).cdseqcri) || '</cdseqcri>' ||
                                                            '<nrdocmto>0</nrdocmto>' ||
                                                            '<dscritic>' || vr_tab_rejeita(i).dscritic || '</dscritic>' || 
                                                            '<nrlinseq>' || vr_tab_rejeita(i).nrlinseq || '</nrlinseq>' || 
                                                        '</cobranca>');                       
          
          END LOOP;
        
          --> Montar xml de retorno dos dados <---
          gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao69 
                                 ,pr_texto_completo => vr_xml_temp 
                                 ,pr_fecha_xml      => TRUE 
                                 ,pr_texto_novo     => '</rejeitados>');
                                   
        ELSE
        
          IF nvl(vr_cdcritic,0) = 0    AND
             TRIM(vr_dscritic) IS NULL THEN 
             
            vr_dscritic := 'Nao foi possivel validar o arquivo de cobranca.';
   
          END IF;
               
          RAISE vr_exc_erro;  
        
        END IF;
      
      ELSE
        --> Montar xml de retorno dos dados <---
        gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao69 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_fecha_xml      => TRUE 
                               ,pr_texto_novo     => '<flgvalok>OK</flgvalok>');
                                                          
      END IF;
            
      pr_dsretorn := 'OK';
      
       --> Remover arquivo 
      vr_dscomand := 'rm '|| vr_dsarquiv;
              
      gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                  pr_typ_saida   => vr_typ_said,
                                  pr_des_saida   => vr_dscritic); 
                                  
      RETURN;  
        
    ELSE  
      
      COBR0006.pc_identifica_arq_cnab(pr_cdcooper => pr_cdcooper               --> Codigo da cooperativa
                                     ,pr_nmarqint => vr_dsarquiv               --> Nome do arquivo
                                     ,pr_tparquiv => vr_tparquiv               --> Tipo do arquivo
                                     ,pr_cddbanco => vr_cddbanco               --> Codigo do banco
									 ,pr_nrdconta => vr_nrdconta               --> Recebe nrdconta
                                     ,pr_rec_rejeita => vr_tab_rejeita         --> Dados invalidados
                                     ,pr_cdcritic => vr_cdcritic               --> Código da critica
                                     ,pr_dscritic => vr_dscritic               -->Descrição da critica
                                     ,pr_des_reto => vr_des_reto) ;            --> Retorno OK/NOK  
          
      IF vr_tab_rejeita.count() > 0 THEN
            
        --> Montar xml de retorno dos dados <---
        gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao69 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<rejeitados>');    
            
        FOR i IN vr_tab_rejeita.first..vr_tab_rejeita.last LOOP
            
          --> Montar xml de retorno dos dados <---
          gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao69 
                                 ,pr_texto_completo => vr_xml_temp 
                                 ,pr_texto_novo     => '<cobranca>' || 
                                                          '<tpcritic>' || to_char(vr_tab_rejeita(i).tpcritic) || '</tpcritic>' ||
                                                          '<cdseqcri>' || to_char(vr_tab_rejeita(i).cdseqcri) || '</cdseqcri>' ||
                                                          '<nrdocmto>0</nrdocmto>' ||
                                                          '<dscritic>' || vr_tab_rejeita(i).dscritic || '</dscritic>' || 
                                                          '<nrlinseq>' || vr_tab_rejeita(i).nrlinseq || '</nrlinseq>' || 
                                                      '</cobranca>');       
            
        END LOOP;
          
        --> Montar xml de retorno dos dados <---
        gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao69 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_fecha_xml      => TRUE 
                               ,pr_texto_novo     => '</rejeitados>');
                                     
        pr_dsretorn := 'NOK';
        
        --> Remover arquivo 
        vr_dscomand := 'rm '|| vr_dsarquiv;
                
        gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic); 
                                    
        
        RETURN; 
                                 
      ELSIF vr_des_reto <> 'OK' THEN
          
        IF nvl(vr_cdcritic,0) = 0     AND
           trim(vr_dscritic)  IS NULL THEN 
               
           vr_dscritic := 'Nao foi possivel identificar o arquivo de cobranca.';
               
        END IF;
            
        RAISE vr_exc_erro; 
          
      END IF;                                                       
      
      IF NOT (vr_tparquiv = 'CNAB240' AND
              vr_cddbanco = 1 )       AND
         NOT (vr_tparquiv = 'CNAB240' AND
              vr_cddbanco = 85)       AND
         NOT (vr_tparquiv = 'CNAB400' AND
              vr_cddbanco = 85)       THEN
      
        --Monta mensagem de critica
        vr_dscritic := 'Formato de arquivo invalido.';
          
        RAISE vr_exc_erro;
      
      END IF;    
                  
      IF vr_tparquiv = 'CNAB240' AND
         vr_cddbanco = 1         THEN
           
        COBR0006.pc_intarq_remes_cnab240_001(pr_cdcooper  => pr_cdcooper   --> Codigo da cooperativa
                                            ,pr_nrdconta  => pr_nrdconta   --> Numero da conta do cooperado
                                            ,pr_nmarquiv  => vr_dsarquiv   --> Nome do arquivo a ser importado               
                                            ,pr_idorigem  => pr_idorigem   --> Identificador de origem
                                            ,pr_dtmvtolt  => pr_dtmvtolt   --> Data do movimento
                                            ,pr_cdoperad  => pr_cdoperad   --> Codigo do operador
                                            ,pr_nmdatela  => pr_nmdatela   --> Nome da Tela
                                            ,pr_tab_crawrej => vr_tab_crawrej --> Registros rejeitados
                                            ,pr_hrtransa  => vr_hrtransa   --> Hora da transacao
                                            ,pr_nrprotoc  => vr_nrprotoc   --> Numero do Protocolo
                                            ,pr_des_reto  => vr_des_reto   --> OK ou NOK
                                            ,pr_cdcritic  => vr_cdcritic   --> Codigo de critica
                                            ,pr_dscritic  => vr_dscritic); --> Descricao da critica

        GENE0001.pc_set_modulo(pr_module => 'pc_InternetBank69', pr_action => 'pc_InternetBank69');
           
      ELSIF vr_tparquiv = 'CNAB240' AND
            vr_cddbanco = 85        THEN
              
        COBR0006.pc_intarq_remes_cnab240_085(pr_cdcooper  => pr_cdcooper   --> Codigo da cooperativa
                                            ,pr_nrdconta  => pr_nrdconta   --> Numero da conta do cooperado
                                            ,pr_nmarquiv  => vr_dsarquiv   --> Nome do arquivo a ser importado               
                                            ,pr_idorigem  => pr_idorigem   --> Identificador de origem
                                            ,pr_dtmvtolt  => pr_dtmvtolt   --> Data do movimento
                                            ,pr_cdoperad  => pr_cdoperad   --> Codigo do operador
                                            ,pr_nmdatela  => pr_nmdatela   --> Nome da Tela
                                            ,pr_tab_crawrej => vr_tab_crawrej --> Registros rejeitados
                                            ,pr_hrtransa  => vr_hrtransa   --> Hora da transacao
                                            ,pr_nrprotoc  => vr_nrprotoc   --> Numero do Protocolo
                                            ,pr_des_reto  => vr_des_reto   --> OK ou NOK
                                            ,pr_cdcritic  => vr_cdcritic   --> Codigo de critica
                                            ,pr_dscritic  => vr_dscritic); --> Descricao da critica

        GENE0001.pc_set_modulo(pr_module => 'pc_InternetBank69', pr_action => 'pc_InternetBank69');

      ELSIF vr_tparquiv = 'CNAB400' AND
            vr_cddbanco = 85        THEN
              
        COBR0006.pc_intarq_remes_cnab400_085(pr_cdcooper  => pr_cdcooper --> Codigo da cooperativa
                                            ,pr_nrdconta  => pr_nrdconta --> Numero da conta do cooperado
                                            ,pr_nmarquiv  => vr_dsarquiv --> Nome do arquivo a ser importado               
                                            ,pr_idorigem  => pr_idorigem --> Identificador de origem
                                            ,pr_dtmvtolt  => pr_dtmvtolt --> Data do movimento
                                            ,pr_cdoperad  => pr_cdoperad --> Codigo do operador
                                            ,pr_nmdatela  => pr_nmdatela --> Nome da Tela
                                            ,pr_tab_crawrej => vr_tab_crawrej --> Registros rejeitados
                                            ,pr_hrtransa  => vr_hrtransa --> Hora da transacao
                                            ,pr_nrprotoc  => vr_nrprotoc --> Numero do Protocolo
                                            ,pr_des_reto  => vr_des_reto --> OK ou NOK
                                            ,pr_cdcritic  => vr_cdcritic --> Codigo de critica
                                            ,pr_dscritic  => vr_dscritic);    

        GENE0001.pc_set_modulo(pr_module => 'pc_InternetBank69', pr_action => 'pc_InternetBank69');  

      END IF;
              
      IF vr_tab_crawrej.count() > 0 THEN
            
        --> Montar xml de retorno dos dados <---
        gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao69 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<rejeitados>'); 
            
        FOR i IN vr_tab_crawrej.first..vr_tab_crawrej.last LOOP
             
          --> Montar xml de retorno dos dados <---
          gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao69 
                                 ,pr_texto_completo => vr_xml_temp 
                                 ,pr_texto_novo     => '<cobranca>' || 
                                                          '<tpcritic>9</tpcritic>' ||
                                                          '<cdseqcri>0</cdseqcri>' ||
                                                          '<nrdocmto>' || vr_tab_crawrej(i).nrdocmto ||'</nrdocmto>' ||
                                                          '<dscritic>' || vr_tab_crawrej(i).dscritic || '</dscritic>' || 
                                                          '<nrlinseq>99999</nrlinseq>' || 
                                                      '</cobranca>');                          
            
        END LOOP;
          
        --> Montar xml de retorno dos dados <---
        gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao69 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</rejeitados>');
                                 
      ELSIF vr_des_reto <> 'OK' THEN
          
        IF nvl(vr_cdcritic,0) = 0     AND
           trim(vr_dscritic)  IS NULL THEN 
               
           vr_dscritic := 'Nao foi possivel identificar o arquivo de cobranca.';
               
        END IF;
        
        RAISE vr_exc_erro;  
                                                               
      END IF;
        
      --> Montar xml de retorno dos dados <---
      gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao69 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_fecha_xml      => TRUE 
                             ,pr_texto_novo     => '<dados>' || 
                                                      '<nrprotoc>' || to_char(nvl(trim(vr_nrprotoc), ' ')) || '</nrprotoc>' ||
                                                      '<cdcritic>' || to_char(nvl(vr_cdcritic,0)) || '</cdcritic>' || 
                                                      '<hrtransa>' || to_char(GENE0002.fn_converte_time_data(vr_hrtransa)) || '</hrtransa>' ||
                                                      '<cddbanco>' || to_char(nvl(vr_cddbanco,0),'000') || '</cddbanco>' ||
                                                  '</dados>'); 
      
    END IF;
      
    --> Mover arquivo 
    vr_dscomand := 'mv '|| vr_dsarquiv || ' ' ||
                           vr_dsdircop || '/salvar';
                
    gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                pr_typ_saida   => vr_typ_said,
                                pr_des_saida   => vr_dscritic); 
                                                   
    pr_dsretorn := 'OK';
    
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION
    WHEN vr_exc_erro THEN
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
      -- se possui codigo, porém não possui descrição     
      IF nvl(vr_cdcritic,0) > 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        -- buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
         
      END IF; 
      
      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
      pr_dsretorn := 'NOK';    
      
      --> Mover arquivo 
      vr_dscomand := 'mv '|| vr_dsdircop || '/upload/' || pr_nmarquiv|| ' ' ||
                             vr_dsdircop || '/salvar';
              
      gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                  pr_typ_saida   => vr_typ_said,
                                  pr_des_saida   => vr_dscritic);              
                                
    WHEN OTHERS THEN
      CECRED.pc_internal_exception;

      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>Erro inesperado. Nao foi possivel importar o arquivo de cobranca. Tente novamente ou contacte seu PA</dsmsgerr>' || sqlerrm;
      pr_dsretorn := 'NOK';           
      
       --> Mover arquivo 
      vr_dscomand := 'mv '|| vr_dsdircop || '/upload/' || pr_nmarquiv|| ' ' ||
                             vr_dsdircop || '/salvar';
              
      gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand,
                                  pr_typ_saida   => vr_typ_said,
                                  pr_des_saida   => vr_dscritic); 
                                  
  END pc_InternetBank69;
  
  -- Procedure para rejeitar arquivo de remessa
  PROCEDURE pc_rejeitar_arquivo (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado                               
                                ,pr_dtmvtolt      IN DATE                   -- Data do Movimento  
                                ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro
                                  
   
     /* ..........................................................................
    
      Programa : pc_rejeitar_arquivo        
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Odirlei Busana - AMcom
      Data    : Julho/2017.                       Ultima atualizacao: 13/02/2017
   
      Dados referentes ao programa:
       
      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Procedure para rejeitar arquivo de remessa
          
      Alteracoes: 13/02/2017 - Ajuste para alterar o diretório destino para os arquivos rejeitados
                               e efetuar corretamente o comando para envio do arquivo ao ftp
				                      (Andrei - Mouts).        
                  29/05/2018 - Ajuste para mover arquivos para pasta FTP e melhoria no script.
				               Gabriel (Mouts) - Chamado INC0015743.                   

    .................................................................................*/
    
    -- Busca dados da Cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapccc.cdcooper%TYPE) IS
      SELECT crapcop.dsdircop
      FROM crapcop crapcop
      WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Nome do Arquivo .ERR
    vr_nmarquivo_err VARCHAR2(4000);

    vr_exc_erro EXCEPTION; 
    vr_nrdrowid ROWID;
    
    -- Descrição da Origem
    vr_dsorigem VARCHAR2(100);
    
    vr_diretorio_log VARCHAR2(4000);
    vr_diretorio_err VARCHAR2(4000);
    vr_dir_coop VARCHAR2(4000);
    
    vr_serv_ftp VARCHAR2(100);
    vr_user_ftp VARCHAR2(100);
    vr_pass_ftp VARCHAR2(100);
    
    vr_comando VARCHAR2(4000);
    
    vr_typ_saida VARCHAR2(3);
    
    vr_dir_retorno varchar2(4000);
    
    vr_script_cust varchar2(4000);
    
    vr_cdcritic INTEGER := 0;
    vr_dscritic VARCHAR2(5000) := NULL;
  
  BEGIN
    -- Inicializa Variaveis
    vr_cdcritic:= 0;
    vr_dscritic:= NULL;
    
    -- Monta nome do Arquivo de Erro (.ERR)
    vr_nmarquivo_err := REPLACE(UPPER(pr_nmarquiv),'.REM','.ERR');

    -- Busca nome resumido da cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 0;
      vr_dscritic := 'Cooperativa nao Cadastrada.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      --Fechar Cursor
      CLOSE cr_crapcop;  
    END IF;
    
    -- Diretório da Cooperativa
    vr_dir_coop := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper);
     
    -- Diretório do arquivo de Erro (.ERR)
    vr_diretorio_err := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/upload/ftp') ;  
      
    -- Renomeia o Arquivo .REM para .ERR
    gene0001.pc_OScommand_Shell('mv ' || vr_diretorio_err || '/' || pr_nmarquiv || ' ' || 
                                vr_diretorio_err || '/' || vr_nmarquivo_err); 
        
    -- Caminho script que envia/recebe via FTP os arquivos de custodia cheque
    vr_script_cust := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdcooper => '0'
                                               ,pr_cdacesso => 'SCRIPT_ENV_REC_ARQ_CUST');
      
    vr_serv_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => '0'
                                            ,pr_cdacesso => 'CUST_CHQ_ARQ_SERV_FTP'); 
                                                
    vr_user_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => '0'
                                            ,pr_cdacesso => 'CUST_CHQ_ARQ_USER_FTP');
                                              
    vr_pass_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => '0'
                                            ,pr_cdacesso => 'CUST_CHQ_ARQ_PASS_FTP');   
                                              
    vr_dir_retorno := '/' ||TRIM(rw_crapcop.dsdircop)   ||
                      '/' || TRIM(to_char(pr_nrdconta)) || '/RETORNO';                                                                              
            
    -- Copia Arquivo .ERR para Servidor FTP
    vr_comando := vr_script_cust                                 || ' ' ||
    '-envia'                                                     || ' ' || 
    '-srv '         || vr_serv_ftp                               || ' ' || -- Servidor
    '-usr '         || vr_user_ftp                               || ' ' || -- Usuario
    '-pass '        || vr_pass_ftp                               || ' ' || -- Senha
    '-arq '         || CHR(39) || vr_nmarquivo_err || CHR(39)    || ' ' || -- .ERR
    '-dir_local '   || vr_diretorio_err                          || ' ' || -- /usr/coop/<cooperativa>/upload
    '-dir_remoto '  || vr_dir_retorno                            || ' ' || -- /<conta do cooperado>/RETORNO 
    '-salvar '      || vr_dir_coop || '/salvar'                  || ' ' || -- /usr/coop/<cooperativa>/salvar  
    '-log '         || vr_dir_coop || '/log/cbr_por_arquivo.log';          -- /usr/coop/<cooperativa>/log/cst_por_arquivo.log
      
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => pr_dscritic
                         ,pr_flg_aguard  => 'S');
                           
    -- Se ocorreu erro dar RAISE
    IF vr_typ_saida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
      RAISE vr_exc_erro;
    END IF;                    

    -- Verifica Qual a Origem
    CASE pr_idorigem 
      WHEN 1 THEN vr_dsorigem := 'AIMARO';
      WHEN 3 THEN vr_dsorigem := 'INTERNET';
      WHEN 7 THEN vr_dsorigem := 'FTP';
      ELSE vr_dsorigem := ' ';
    END CASE; 
      
    -- Gerar log ao cooperado (b1wgen0014 - gera_log);
    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => 'Arquivo ' || pr_nmarquiv || ' de cobrança foi rejeitado'
                        ,pr_dttransa => pr_dtmvtolt
                        ,pr_flgtrans => 0 -- TRUE
                        ,pr_hrtransa => to_number(to_char(pr_dtmvtolt,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => ' '
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
                        
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorna variaveis de saida
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Atualiza campo de erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro COBR0006.pc_rejeitar_arquivo: ' || SQLERRM;  
  END pc_rejeitar_arquivo;    
  
  
END COBR0006;
/
