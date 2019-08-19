/* Baca para gerar os arquivos de quebra de sigilo bancário
 * Arquivos que serão gerados: AGENCIAS, CONTAS, TITULARES, ESXTRATO, ORIGEM_DESTINO
 *
 * Obs: Quem alterar o fonte para adicionar mais historicos ou dados do PA, favor adicionar na ordem
        Históricos podem ser mapeados com ajuda da Sarah Weber, Marina Franco ou Andreia Johse
 
 Variáveis e modo de usar: 
      1. vr_dircop - verificar o diretório onde o resultado é fornecido;
      2. pr_tbpa - verificar se PA está "cadastrado no código";
      3. vr_tbdoc - Executar baca\Reutilizaveis\quebra_sigilo_docs.sql para montar os dados da variável;
         3.1 Solicitar o campo nrcpfdeb para a Natalia Busnardo informando o lançamento;
      4. vr_referencia, vr_dtinicio, vr_dtfim e vr_tbconta_investigar - seguir as instruções localizadas no código no início do programa;
      5. vr_dacaojud - protocolo do SIMBA, quando houver.

 *
 * Autor: Douglas Quisinski
 * 
 * Alterações: 21/02/2017 - Adicionado ao TFS
 *             03/03/2017 - Adicionado o PA 25 da cooperativa 1 - Viacredi (Douglas - Chamado 622893)
 *             13/03/2017 - Adicionado o PA 4 da cooperativa 11 - Credifoz (Douglas - Chamado 628356)
 *             21/03/2017 - Adicionado Históricos 834, 1827, 1829, 1832    (Douglas - Chamado 633139)
 *             28/03/2017 - Ajustado para o inpessoa 3 ser enviado como 2 "Juridico"
 *                        - Adicionado o tipo de conta igual a 4 "Outros" para os históricos 
 *                          de Credito de Transferencia Via Internet (Douglas - Chamado 633139)
 *             11/04/2017 - Ajustes no campos de numero de documento e mapeamento dos históricos:
 *                          8, 579, 584, 667, 887, 1101, 1239, 1265, 1269, 1279, 1280, 1288, 1348, 1419, 1469,
 *                          1487, 1762, 1795, 1813, 1814, 1816, 1823, 1941, 1942, 1943 (Douglas - Chamado 647591)
 *             18/04/2017 - Adicionado o PA 2 da cooperativa 7 - Credcrea (Douglas - Chamado 652300)
 *             20/04/2017 - Adicionado Histórico 668 (Douglas - Chamado 654732)
 *             20/04/2017 - Adicionado o PA 6 da cooperativa 7 - Credcrea e mapeamentos dos 
 *                          historicos 50, 499 e 646 (Douglas - Chamado 654736)
 *             24/04/2017 - Ajuste na listagem de ORIGEM/DESTINO dos lançamentos de Folha de Pagamento
 *                          para o histórico 889 (Douglas - Chamado 653489)
 *             25/04/2017 - Ajuste na listagem dos dados dos titulares que estão sendo investigados
 *                          para buscar os dados da crapttl (Douglas - Chamado 654732)
 *             22/05/2017 - Adicionado o PA 63 da cooperativa 1 - Viacredi (Douglas - Chamado 676395)
 *             16/06/2017 - Adicionado os PAs 19 e 41 da cooperativa 1 - Viacredi e
 *                          mapeado o historico 1787 (Douglas - Chamado 692303)
 *             26/06/2017 - Adicionado o PA 64 da cooperativa 1 - Viacredi e
 *                          mapeado os historicos 31, 961, 1523, 1526 e 2006 (Douglas - Chamado 676395)
 *             13/07/2017 - Adicionado o PA 4 da cooperativa 9 - Transpocred (Douglas - Chamado 711053)
 *             21/09/2017 - Adicionado o PA 7 da cooperativa 13 - ScrCred e o 
 *                          PA 1 da cooperativa 15 - Credimilsul (Douglas - Chamado 760987)
 *             21/09/2017 - Adicionado o PA 34 da cooperativa 1 - Viacredi e 
 *                          mapeado os historicos 24 e 502 (Douglas - Chamado 762574)
 *             26/09/2017 - mapeado os historicos 1232 e 1485 (Douglas - Chamado 763307)
 *             05/10/2017 - Adicionado o PA 58 da cooperativa 1 - Viacredi e 
 *                          mapeado o historico 616  (Douglas - Chamado 770870)
 *             06/11/2017 - Adicionado o PA 4 da cooperativa 13 - ScrCred (Douglas - Chamado 783862)
 *             10/11/2017 - Adicionado o PA 6 da cooperativa 2 - Acredicoop (Douglas - Chamado 791874)
 *             10/11/2017 - Adicionado os PAs 2,9,22,37,42,44,45,52,61,71,72,73,86 da 
 *                          cooperativa 1 - Viacredi e mapeamento dos historicos 20,149,444,453,626,767,
 *                          799,1180,1196,1216,1217,1230,1234,1281,1313,1428,1442,1466,1482,1491,1498,1514,
 *                          1515,1539,1541,1542,1543,1544,1546,1567,1632,1729,1882,1897,2010,2084,2087,2090,
 *                          2093,2175,2176,2177,2178,2179 (Douglas - Chamado 791871)
 *             17/11/2017 - Adicionado o PA 4 e 9 da cooperativa 16 - Viacredi Alto Vale (Douglas - Chamado 796747)
 *             20/11/2017 - Adicionado o PA 48 da cooperativa 1 - Viacredi e 
 *                          mapeado o historico 1186  (Douglas - Chamado 797361)
 *             11/01/2018 - Adicionado o PA 1 da cooperativa 14 - Rodocredito e 
 *                          mapeado os historicos 972 e 1351  (Douglas - Chamado 828278)
 *             24/01/2018 - Adicionado o PA 9 da cooperativa 7 - Credcrea (Douglas - Chamado 837407)
 *             29/01/2018 - Mapeado os históricos  48, 971, 1221, 1349, 1353, 1493, 1559, 1562, 1893 e 1974  (Douglas - Chamado 839574)
 *             02/05/2018 - Adicionado o PA 79 da cooperativa 1 - Viacredi, tambem mapear historicos 2323,2425 (Lucas Ranghetti TASK0013197)
 *             06/08/2018 - Ajuste nos lançamentos de cobrança com histórico 971, 977, 987 e 1089 (Douglas Quisinski)
 */

-- BLOCO PRINCIPAL DO PROGRAMA  
CREATE OR REPLACE PROCEDURE CECRED.pc_quebra_sigilo_bancario IS 

  -- Local para geracao do arquivo
  vr_dircop     CONSTANT VARCHAR2(200) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                    pr_cdcooper => 0,
                                                                    pr_cdacesso => 'ROOT_MICROS') ||
                                          'cecred/quisinski/carta';
  vr_dir_arq    VARCHAR2(300);

  -- Variaveis
  vr_referencia VARCHAR2(40);
  vr_dtinicio   DATE;
  vr_dtfim      DATE;
  vr_contador   NUMBER;
  vr_dacaojud  crapicf.dacaojud%TYPE := '005-MPSC-000366-67'; -- INFORMAR_DESC_ACAO_JUD Informar descrição da ação judicial (este campo é utilizado na tabela CRAPICF)
  
  -- Indices das PL TABLES
  vr_idx_err    INTEGER;
  vr_idx_pa     VARCHAR2(10);
  
  -- Criacao do diretorio de arquivos
  vr_typ_saida VARCHAR2(100);
  vr_des_saida VARCHAR2(1000);
  
  -- Exception
  vr_erros EXCEPTION;
  
  -- Tabelas do programa
  -- Historicos DE -> PARA
  TYPE typ_tbhistorico IS TABLE OF INTEGER INDEX BY PLS_INTEGER;
  vr_tbhistorico typ_tbhistorico;
  
  -- Dados da Agencia
  TYPE typ_rec_pa IS RECORD (cdcooper INTEGER
                            ,cdagenci INTEGER
                            ,dtabertu DATE
                            ,dstelefo VARCHAR2(20));
  -- Agencia
  TYPE typ_tbpa IS TABLE OF typ_rec_pa INDEX BY VARCHAR2(10);
  vr_tbpa typ_tbpa;
  
  -- Contas que serao investigadas
  TYPE typ_rec_conta_investigar IS RECORD (cdcooper INTEGER
                                          ,nrdconta INTEGER
                                          ,nrcpfcgc NUMBER(25));
  -- Conta Investigar
  TYPE typ_tbconta_investigar IS TABLE OF typ_rec_conta_investigar INDEX BY VARCHAR2(30);
  vr_tbconta_investigar typ_tbconta_investigar;  

  -- Dados da TED
  TYPE typ_rec_ted IS RECORD (datadted DATE
                             ,cdbancod INTEGER
                             ,nmclideb VARCHAR2(100)
                             ,nrcpfdeb NUMBER(25)
                             ,contadeb INTEGER
                             ,agenciad INTEGER
                             ,valorted NUMBER(25,2)
                             ,regativo INTEGER);
  -- dados da TED
  TYPE typ_tbted IS TABLE OF typ_rec_ted INDEX BY PLS_INTEGER;
  vr_tbted typ_tbted;
  
  -- Dados da DOC
  TYPE typ_rec_doc IS RECORD (cdagenci INTEGER
                             ,nrcpfdeb NUMBER(25)
                             ,nrdconta INTEGER
                             ,nrctadeb VARCHAR2(100)
                             ,dtmvtolt DATE
                             ,cdbancod INTEGER
                             ,nmclideb VARCHAR2(100)
                             ,valordoc NUMBER(25,2)
                             ,flgativo INTEGER);
                             
  -- dados da DOC
  TYPE typ_tbdoc IS TABLE OF typ_rec_doc INDEX BY PLS_INTEGER;
  vr_tbdoc typ_tbdoc;

  -- Dados do Erro
  TYPE typ_rec_erro IS RECORD (dsorigem VARCHAR(100)
                              ,dserro   VARCHAR2(32000));
  -- Erros da Geração dos arquivos 
  TYPE typ_tberro IS TABLE OF typ_rec_erro INDEX BY PLS_INTEGER;
  vr_tberro typ_tberro;
  
  -- INICIO - Tabelas para guardar dos dados que serão escritos nos arquivos de quebra de sigilo bancário
  -- Dados da Agencia para escrever no arquivo
  TYPE typ_rec_arq_agencia IS RECORD (cddbanco VARCHAR2(3)    /*  1 - Numero do Banco      */
                                     ,cdagenci INTEGER        /*  2 - Numero da Agencia    */
                                     ,nmextage VARCHAR2(35)   /*  3 - Nome da Agencia      */
                                     ,dsendcop VARCHAR2(500)  /*  4 - Endereco da Agencia  */
                                     ,nmcidade VARCHAR2(15)   /*  5 - Cidade               */  
                                     ,cdufdcop VARCHAR2(2)    /*  6 - UF                   */
                                     ,nmdopais VARCHAR2(6)    /*  7 - Pais                 */
                                     ,nrcepend NUMBER(15)     /*  8 - Cep                  */
                                     ,nrtelefo VARCHAR2(30)   /*  9 - Telefone PA          */
                                     ,dtabertu VARCHAR2(10)   /* 10 - Data Abertura PA     */ 
                                     ,dtfecham VARCHAR2(10)); /* 11 - Data Fechamento PA   */
                                     
  -- Dados da Agencia para escrever no arquivo
  TYPE typ_tbarq_agencias IS TABLE OF typ_rec_arq_agencia INDEX BY VARCHAR2(10);
  vr_tbarq_agencias typ_tbarq_agencias;  
  
  -- Dados da Conta para escrever no arquivo
  TYPE typ_rec_arq_conta IS RECORD (cddbanco VARCHAR2(3)    /* 1 - Numero do Banco */
                                   ,cdagenci INTEGER        /* 2 - Numero da Agencia */
                                   ,nrdconta INTEGER        /* 3 - Numero da Conta */
                                   ,tpdconta VARCHAR2(1)    /* 4 - Tipo da Conta: 1=conta corrente, 2=poupança, 3=investimento, 4=outros */
                                   ,dtabertu VARCHAR2(10)   /* 5 - Data de Abertura da Conta */  
                                   ,dtfecham VARCHAR2(10)   /* 6 - Data de Encerramento da Conta */
                                   ,tpmovcta VARCHAR2(1));  /* 7 - Tipo de Movimentação da Conta   
                                                                   1 = É uma conta investigada e houve movimentaçao bancária no período de afastamento.
                                                                   2 = É uma conta investigada, porém nao houve movimentaçao no período.
                                                                   3 = Quando nao for uma conta investigada, 
                                                                      porém trata-se de conta do mesmo banco que efetuou transaçao bancária com uma conta investigada. */
  -- Dados da Conta para escrever no arquivo
  TYPE typ_tbarq_contas IS TABLE OF typ_rec_arq_conta INDEX BY VARCHAR2(15);
  vr_tbarq_contas typ_tbarq_contas;

  -- Dados dos Titulares para escrever no arquivo
  TYPE typ_rec_arq_titular IS RECORD (cddbanco VARCHAR2(3)    /* 1 - Codigo do Banco */
                                     ,cdagenci INTEGER        /* 2 - Numero da Agencia */
                                     ,nrdconta INTEGER        /* 3 - Numero da Conta */
                                     ,tpdconta VARCHAR2(1)    /* 4 - Tipo de conta: 1=conta corrente, 2=poupança, 3=investimento, 4=outros */
                                     ,dsvincul VARCHAR2(1)    /* 5 - Vinculo: T = Titular, 
                                                                              1 = 1o. Co-titular, 
                                                                              2 = 2o. Co-titular e assim consecutivamente; ou 
                                                                              R = Representante, 
                                                                              L = Representante Legal, 
                                                                              P = Procurador, 
                                                                              O = Outros */
                                     ,flafasta INTEGER        /* 6 - Indica se a pessoa, física ou jurídica, teve ou não o sigilo bancário afastado (conforme determinação judicial). 
                                                                     0 = Não teve o sigilo afastado. 1 = Teve o sigilo afastado. */
                                     ,inpessoa INTEGER        /* 7 - Tipo de pessoa: 1=Pessoa Fisica; 2=Pessoa Juridica */
                                     ,nrcpfcgc NUMBER(25)     /* 8 - CPF */
                                     ,nmprimtl VARCHAR2(80)   /* 9 - Nome Completo */
                                     ,tpdocttl VARCHAR2(50)   /* 10 - Tipo de Documento */
                                     ,nrdocttl VARCHAR2(20)   /* 11 - Numero do Documento */
                                     ,dsendere VARCHAR2(80)   /* 12 - Endereço */
                                     ,nmcidade VARCHAR2(40)   /* 13 - Cidade */
                                     ,ufendere VARCHAR2(2)    /* 14 - UF */
                                     ,nmdopais VARCHAR2(40)   /* 15 - País */
                                     ,nrcepend NUMBER(15)     /* 16 - CEP */
                                     ,nrtelefo VARCHAR2(20)   /* 17 - Telefone */
                                     ,vlrrendi VARCHAR2(14)   /* 18 - Renda Informada */
                                     ,dtultalt VARCHAR2(10)   /* 19 - Data Atualizacao Renda */
                                     ,dtadmiss VARCHAR2(10)   /* 20 - Data Abertura da conta */ 
                                     ,dtdemiss VARCHAR2(10)); /* 21 - Data Encerramento da Conta */
  -- Dados da Titulares  para escrever no arquivo
  TYPE typ_tbarq_titulares IS TABLE OF typ_rec_arq_titular INDEX BY VARCHAR2(30);
  vr_tbarq_titulares typ_tbarq_titulares;
  
  -- Dados do Extrato para escrever no arquivo
  TYPE typ_rec_arq_extrato IS RECORD (idseqlcm NUMBER         /*  1 - Sequencial */
                                     ,cddbanco VARCHAR2(3)    /*  2 - Codigo do Banco */
                                     ,cdagenci INTEGER        /*  3 - Agencia */ 
                                     ,nrdconta INTEGER        /*  4 - Conta */
                                     ,tpdconta VARCHAR2(1)    /*  5 - Tipo de conta: 1=conta corrente, 2=poupança, 3=investimento, 4=outros. */
                                     ,dtmvtolt VARCHAR2(10)   /*  6 - Data Lancamento */
                                     ,nrdocmto VARCHAR2(20)   /*  7 - Documento */
                                     ,dshistor VARCHAR2(50)   /*  8 - Descricao Historico */ 
                                     ,tplancto VARCHAR2(3)    /*  9 - Tipo de Lancamento  */
                                     ,vllanmto VARCHAR2(16)   /* 10 - Valor Lancamento */
                                     ,indebcre VARCHAR2(1)    /* 11 - Natureza do Lancamento */
                                     ,vlrsaldo VARCHAR2(16)   /* 12 - Valor Saldo CC */
                                     ,sddebcre VARCHAR2(1)    /* 13 - Natureza do Saldo */
                                     ,localtra VARCHAR2(80)); /* 14 - Local da Transacao */ 
  -- Dados da Extrato para escrever no arquivo
  TYPE typ_tbarq_extrato IS TABLE OF typ_rec_arq_extrato INDEX BY PLS_INTEGER;
  vr_tbarq_extrato typ_tbarq_extrato;
  
  -- Dados de Origem e Destino para escrever no arquivo
  TYPE typ_rec_arq_origem_destino IS RECORD (idseqarq NUMBER          /*  1 - Sequencial  Arquivo */
                                            ,idseqlcm NUMBER          /*  2 - Sequencial */ 
                                            ,vllanmto VARCHAR2(16)    /*  3 - Valor Lancamento */
                                            ,nrdocmto VARCHAR2(20)    /*  4 - Nro. Documento */
                                            ,cdbandep VARCHAR2(3)     /*  5 - Banco OD */  
                                            ,cdagedep INTEGER         /*  6 - Agencia OD */ 
                                            ,nrctadep VARCHAR2(20)    /*  7 - Conta   OD */
                                            ,tpdconta VARCHAR2(1)     /*  8 - Tipo de conta: 1=conta corrente, 2=poupança, 3=investimento, 4=outros.*/
                                            ,inpessoa VARCHAR2(1)     /*  9 - Tipo de Pessoa OD */
                                            ,nrcpfcgc NUMBER(25)      /* 10 - CPF/CNPJ OD */
                                            ,nmprimtl VARCHAR2(80)    /* 11 - Nome OD */  
                                            ,tpdocttl VARCHAR2(50)    /* 12 - Nome Doc Identificacao OD */
                                            ,nrdocttl VARCHAR2(20)    /* 13 - Nro. Doc Identificacao OD */
                                            ,dscodbar VARCHAR2(100)   /* 14 - Codigo Barra  */
                                            ,nmendoss VARCHAR2(80)    /* 15 - Nome Endossante Cheque */ 
                                            ,docendos VARCHAR2(50)    /* 16 - Doc Endossante Cheque   */
                                            ,idsitide VARCHAR2(1)     /* 17 - Situacao Identificacao  */
                                            ,dsobserv VARCHAR2(250)); /* 18 - Observacao  */ 
  -- Dados de Origem e Destino para escrever no arquivo
  TYPE typ_tbarq_origem_destino IS TABLE OF typ_rec_arq_origem_destino INDEX BY PLS_INTEGER;
  vr_tbarq_origem_destino typ_tbarq_origem_destino;
  -- FIM - Tabelas para guardar dos dados que serão escritos nos arquivos de quebra de sigilo bancário
  --
  -- Dados de Cheques ICFJUD para escrever no arquivo
  TYPE typ_rec_arq_cheques_icfjud IS RECORD (dtinireq DATE            /*  1 - Data da Solicitação */
                                            ,cdbanreq NUMBER          /*  2 - Banco Requisitado */ 
                                            ,cdagereq NUMBER          /*  3 - Agencia Requisitada */
                                            ,nrctareq NUMBER          /*  4 - Nr. da conta requisitada */
											,intipreq NUMBER		  /*  5 - Tipo de Requisição */
                                            ,dsdocmc7 VARCHAR2(50) );       /*  6 - dsdocmc7 do cheque requisitado */  

  -- Dados de Cheques ICFJUD
  TYPE typ_tbarq_cheques_icfjud IS TABLE OF typ_rec_arq_cheques_icfjud INDEX BY PLS_INTEGER;
  vr_tbarq_cheques_icfjud typ_tbarq_cheques_icfjud;
  --
  
  -- INICIO -> Carregar Dados que não estão no Ayllos
  PROCEDURE pc_carregar_historico_de_para(pr_tbhistorico OUT typ_tbhistorico) IS
    -- Mapeamento dos históricos DE->PARA
    -- Caso tenha que mapear um histórico, favor entrar em contato com a Sarah Weber
    -- E adicionar o histórico na ordem
  BEGIN
    pr_tbhistorico(   1) := 201;
    pr_tbhistorico(   3) := 201;
    pr_tbhistorico(   4) := 201;
    pr_tbhistorico(   5) := 213;
    pr_tbhistorico(   8) := 219;
    pr_tbhistorico(   9) := 204;
    pr_tbhistorico(  15) := 207;
    pr_tbhistorico(  18) := 107;
    pr_tbhistorico(  20) := 211;
    pr_tbhistorico(  21) := 101;
    pr_tbhistorico(  22) := 114;
    pr_tbhistorico(  23) := 101;
    pr_tbhistorico(  24) := 119;
    pr_tbhistorico(  25) := 104;
    pr_tbhistorico(  27) := 101;
    pr_tbhistorico(  37) := 105;
    pr_tbhistorico(  31) := 104;
    pr_tbhistorico(  38) := 102;
    pr_tbhistorico(  39) := 101;
    pr_tbhistorico(  41) := 101;    
    pr_tbhistorico(  46) := 105;
    pr_tbhistorico(  47) := 203;
    pr_tbhistorico(  48) := 104;
    pr_tbhistorico(  49) := 204; --49(C) - ESTORN.CHEQUE
    pr_tbhistorico(  50) := 101;
    pr_tbhistorico(  57) := 102;
    pr_tbhistorico(  79) := 204;
    pr_tbhistorico(  90) := 105;
    pr_tbhistorico( 108) := 107;
    pr_tbhistorico( 110) := 103;
    pr_tbhistorico( 127) := 104;
    pr_tbhistorico( 132) := 104;
    pr_tbhistorico( 135) := 104;
    pr_tbhistorico( 146) := 105;
    pr_tbhistorico( 148) := 105;
    pr_tbhistorico( 149) := 104;
    pr_tbhistorico( 153) := 101;
    pr_tbhistorico( 160) := 106;
    pr_tbhistorico( 162) := 105;
    pr_tbhistorico( 163) := 105;
    pr_tbhistorico( 164) := 105;
    pr_tbhistorico( 169) := 201;
    pr_tbhistorico( 170) := 201;
    pr_tbhistorico( 266) := 202;
    pr_tbhistorico( 267) := 105;
    pr_tbhistorico( 270) := 207;
    pr_tbhistorico( 271) := 101;
    pr_tbhistorico( 275) := 107;
    pr_tbhistorico( 282) := 107;
    pr_tbhistorico( 290) := 103;
    pr_tbhistorico( 293) := 104;
    pr_tbhistorico( 298) := 105;
    pr_tbhistorico( 300) := 114;
    pr_tbhistorico( 302) := 117;
    pr_tbhistorico( 303) := 213;
    pr_tbhistorico( 313) := 101;
    pr_tbhistorico( 314) := 209;
    pr_tbhistorico( 316) := 114;
    pr_tbhistorico( 317) := 204;
    pr_tbhistorico( 319) := 209;
    pr_tbhistorico( 320) := 204;
    pr_tbhistorico( 322) := 110;
    pr_tbhistorico( 323) := 110;
    pr_tbhistorico( 324) := 110;
    pr_tbhistorico( 325) := 204;
    pr_tbhistorico( 327) := 105;
    pr_tbhistorico( 341) := 104;
    pr_tbhistorico( 346) := 105;
    pr_tbhistorico( 350) := 205;
    pr_tbhistorico( 351) := 119;
    pr_tbhistorico( 354) := 201;
    pr_tbhistorico( 355) := 120;
    pr_tbhistorico( 356) := 201;
    pr_tbhistorico( 357) := 201;
    pr_tbhistorico( 359) := 204;
    pr_tbhistorico( 360) := 103;
    pr_tbhistorico( 362) := 213;
    pr_tbhistorico( 372) := 201;
    pr_tbhistorico( 375) := 104;
    pr_tbhistorico( 377) := 204;
    pr_tbhistorico( 384) := 107;
    pr_tbhistorico( 386) := 201;
    pr_tbhistorico( 394) := 107;
    pr_tbhistorico( 399) := 119;
    pr_tbhistorico( 403) := 201;
    pr_tbhistorico( 404) := 201;    
    pr_tbhistorico( 415) := 112;
    pr_tbhistorico( 428) := 107;
    pr_tbhistorico( 435) := 105;
    pr_tbhistorico( 436) := 105;
    pr_tbhistorico( 442) := 209;
    pr_tbhistorico( 444) := 205;
    pr_tbhistorico( 453) := 104;
    pr_tbhistorico( 460) := 112;
    pr_tbhistorico( 465) := 202;
    pr_tbhistorico( 472) := 106;
    pr_tbhistorico( 478) := 206;
    pr_tbhistorico( 483) := 213;
    pr_tbhistorico( 499) := 206;
    pr_tbhistorico( 501) := 206;
    pr_tbhistorico( 502) := 104;
    pr_tbhistorico( 503) := 120;
    pr_tbhistorico( 504) := 204;
    pr_tbhistorico( 508) := 112;
    pr_tbhistorico( 513) := 105;
    pr_tbhistorico( 518) := 105;
    pr_tbhistorico( 521) := 101;
    pr_tbhistorico( 524) := 101;
    pr_tbhistorico( 527) := 106;
    pr_tbhistorico( 530) := 206;
    pr_tbhistorico( 535) := 112;
    pr_tbhistorico( 537) := 117;
    pr_tbhistorico( 538) := 117;
    pr_tbhistorico( 539) := 213;
    pr_tbhistorico( 548) := 209;
    pr_tbhistorico( 554) := 104;
    pr_tbhistorico( 555) := 120;
    pr_tbhistorico( 566) := 205;
    pr_tbhistorico( 570) := 204;
    pr_tbhistorico( 573) := 215;
    pr_tbhistorico( 575) := 209;
    pr_tbhistorico( 578) := 209;
    pr_tbhistorico( 579) := 204;
    pr_tbhistorico( 581) := 205;
    pr_tbhistorico( 584) := 218;
    pr_tbhistorico( 591) := 104;
    pr_tbhistorico( 593) := 105;
    pr_tbhistorico( 594) := 105;
    pr_tbhistorico( 596) := 105;
    pr_tbhistorico( 597) := 205;
    pr_tbhistorico( 600) := 204;
    pr_tbhistorico( 613) := 112;
    pr_tbhistorico( 614) := 114;
    pr_tbhistorico( 616) := 104;
    pr_tbhistorico( 621) := 119;
    pr_tbhistorico( 626) := 219;
    pr_tbhistorico( 630) := 105;
    pr_tbhistorico( 646) := 205;
    pr_tbhistorico( 651) := 209;
    pr_tbhistorico( 652) := 107;
    pr_tbhistorico( 653) := 112;    
    pr_tbhistorico( 654) := 202;
    pr_tbhistorico( 658) := 112;
    pr_tbhistorico( 661) := 104;
    pr_tbhistorico( 662) := 204;
    pr_tbhistorico( 667) := 104;
    pr_tbhistorico( 668) := 105; 
    pr_tbhistorico( 669) := 105;
    pr_tbhistorico( 670) := 117;    
    pr_tbhistorico( 674) := 104; --DB. SEMASA 104 – para lançamento avisado.
    pr_tbhistorico( 686) := 207;
    pr_tbhistorico( 688) := 105;
    pr_tbhistorico( 695) := 104;
    pr_tbhistorico( 766) := 204;
    pr_tbhistorico( 767) := 204;
    pr_tbhistorico( 770) := 203;
    pr_tbhistorico( 771) := 113;
    pr_tbhistorico( 772) := 219;
    pr_tbhistorico( 778) := 202;
    pr_tbhistorico( 779) := 105;
    pr_tbhistorico( 799) := 209;
    pr_tbhistorico( 826) := 101;
    pr_tbhistorico( 834) := 104;
    pr_tbhistorico( 856) := 112;
    pr_tbhistorico( 874) := 104;
    pr_tbhistorico( 881) := 201;
    pr_tbhistorico( 882) := 104;
    pr_tbhistorico( 887) := 204;
    pr_tbhistorico( 889) := 113;
    pr_tbhistorico( 890) := 105;
    pr_tbhistorico( 891) := 105;
    pr_tbhistorico( 892) := 105;
    pr_tbhistorico( 893) := 105;
    pr_tbhistorico( 901) := 104;
    pr_tbhistorico( 918) := 114;
    pr_tbhistorico( 920) := 204;
    pr_tbhistorico( 933) := 204;
    pr_tbhistorico( 934) := 107;
    pr_tbhistorico( 956) := 218;
    pr_tbhistorico( 961) := 104;
    pr_tbhistorico( 971) := 202;
    pr_tbhistorico( 972) := 104;
    pr_tbhistorico( 976) := 105;
    pr_tbhistorico( 977) := 202;
    pr_tbhistorico( 987) := 202;
    pr_tbhistorico( 993) := 104;
    pr_tbhistorico(1004) := 201;
    pr_tbhistorico(1009) := 117;
    pr_tbhistorico(1011) := 213;
    pr_tbhistorico(1014) := 117;
    pr_tbhistorico(1015) := 213;
    pr_tbhistorico(1019) := 104;
    pr_tbhistorico(1030) := 114;
    pr_tbhistorico(1060) := 102;
    pr_tbhistorico(1061) := 104;
    pr_tbhistorico(1067) := 107;
    pr_tbhistorico(1070) := 102;
    pr_tbhistorico(1071) := 102;
    pr_tbhistorico(1072) := 102;
    pr_tbhistorico(1086) := 105;
    pr_tbhistorico(1087) := 107;
    pr_tbhistorico(1089) := 202;
    pr_tbhistorico(1091) := 204;
    pr_tbhistorico(1100) := 205;
    pr_tbhistorico(1101) := 104;
    pr_tbhistorico(1109) := 205;
    pr_tbhistorico(1110) := 104;
    pr_tbhistorico(1117) := 104;
    pr_tbhistorico(1118) := 205;
    pr_tbhistorico(1133) := 202;    
    pr_tbhistorico(1168) := 112;
    pr_tbhistorico(1176) := 105;
    pr_tbhistorico(1180) := 105;
    pr_tbhistorico(1182) := 105;
    pr_tbhistorico(1186) := 105;
    pr_tbhistorico(1196) := 105;    
    pr_tbhistorico(1200) := 105;
    pr_tbhistorico(1202) := 105;
    pr_tbhistorico(1213) := 105;
    pr_tbhistorico(1215) := 105;
    pr_tbhistorico(1216) := 204;
    pr_tbhistorico(1217) := 105;
    pr_tbhistorico(1219) := 105;
    pr_tbhistorico(1221) := 202;
    pr_tbhistorico(1222) := 104; -- 1222(D) - ACERTO.COB.DB
    pr_tbhistorico(1230) := 104;
    pr_tbhistorico(1231) := 104; -- 
    pr_tbhistorico(1232) := 104;
    pr_tbhistorico(1234) := 104;
    pr_tbhistorico(1235) := 105;
    pr_tbhistorico(1237) := 105;
    pr_tbhistorico(1238) := 205;
    pr_tbhistorico(1239) := 105;
    pr_tbhistorico(1240) := 205;
    pr_tbhistorico(1247) := 105;
    pr_tbhistorico(1249) := 105;
    pr_tbhistorico(1251) := 105;
    pr_tbhistorico(1257) := 105;
    pr_tbhistorico(1259) := 105;
    pr_tbhistorico(1260) := 204;
    pr_tbhistorico(1265) := 105;
    pr_tbhistorico(1267) := 105; -- 1267(D) - TR.SAQ PRE PJ
    pr_tbhistorico(1269) := 105;
    pr_tbhistorico(1279) := 105;
    pr_tbhistorico(1280) := 204;
    pr_tbhistorico(1281) := 105;
    pr_tbhistorico(1287) := 105;
    pr_tbhistorico(1288) := 204;
    pr_tbhistorico(1289) := 105;
    pr_tbhistorico(1290) := 204;
    pr_tbhistorico(1295) := 105;
    pr_tbhistorico(1303) := 105;
    pr_tbhistorico(1311) := 105;
    pr_tbhistorico(1313) := 105;
    pr_tbhistorico(1345) := 105;
    pr_tbhistorico(1347) := 105;
    pr_tbhistorico(1348) := 204;
    pr_tbhistorico(1349) := 105;
    pr_tbhistorico(1351) := 105;
    pr_tbhistorico(1353) := 105;
    pr_tbhistorico(1355) := 105;
    pr_tbhistorico(1357) := 105;
    pr_tbhistorico(1359) := 105;
    pr_tbhistorico(1360) := 204;
    pr_tbhistorico(1361) := 105;
    pr_tbhistorico(1363) := 105;
    pr_tbhistorico(1399) := 205;
    pr_tbhistorico(1402) := 104;
    pr_tbhistorico(1403) := 104;
    pr_tbhistorico(1404) := 205;
    pr_tbhistorico(1405) := 205;
    pr_tbhistorico(1406) := 104;
    pr_tbhistorico(1419) := 204;
    pr_tbhistorico(1423) := 105;
    pr_tbhistorico(1425) := 105;
    pr_tbhistorico(1427) := 105;
    pr_tbhistorico(1428) := 204;
    pr_tbhistorico(1441) := 105;
    pr_tbhistorico(1442) := 204;
    pr_tbhistorico(1443) := 105;
    pr_tbhistorico(1447) := 105;
    pr_tbhistorico(1449) := 105;
    pr_tbhistorico(1451) := 105;
    pr_tbhistorico(1452) := 204;
    pr_tbhistorico(1453) := 105;
    pr_tbhistorico(1455) := 105;
    pr_tbhistorico(1457) := 105;
    pr_tbhistorico(1465) := 105;
    pr_tbhistorico(1466) := 204;
    pr_tbhistorico(1467) := 105;
    pr_tbhistorico(1469) := 105;
    pr_tbhistorico(1479) := 105;
    pr_tbhistorico(1481) := 105;
    pr_tbhistorico(1482) := 204;
    pr_tbhistorico(1483) := 105;
    pr_tbhistorico(1485) := 105;
    pr_tbhistorico(1486) := 204; 
    pr_tbhistorico(1487) := 105;
    pr_tbhistorico(1488) := 204;
    pr_tbhistorico(1491) := 105;
    pr_tbhistorico(1493) := 105;
    pr_tbhistorico(1497) := 105;
    pr_tbhistorico(1498) := 204;
    pr_tbhistorico(1501) := 105;
    pr_tbhistorico(1513) := 105;
    pr_tbhistorico(1514) := 204;
    pr_tbhistorico(1515) := 105;
    pr_tbhistorico(1517) := 104;
    pr_tbhistorico(1523) := 201;
    pr_tbhistorico(1526) := 201;
    pr_tbhistorico(1536) := 207;
    pr_tbhistorico(1539) := 107;
    pr_tbhistorico(1541) := 102;
    pr_tbhistorico(1542) := 102;
    pr_tbhistorico(1543) := 102;
    pr_tbhistorico(1544) := 102;    
    pr_tbhistorico(1545) := 104;
    pr_tbhistorico(1546) := 104;
    pr_tbhistorico(1547) := 104;
    pr_tbhistorico(1548) := 104;
    pr_tbhistorico(1558) := 114;
    pr_tbhistorico(1559) := 114;
    pr_tbhistorico(1560) := 114;    
    pr_tbhistorico(1561) := 104;
    pr_tbhistorico(1562) := 110;
    pr_tbhistorico(1566) := 205;
    pr_tbhistorico(1567) := 204;
    pr_tbhistorico(1577) := 204;
    pr_tbhistorico(1578) := 204;
    pr_tbhistorico(1580) := 204; -- 1580(C) - EST.SQ.CIRRUS
    pr_tbhistorico(1631) := 205;
    pr_tbhistorico(1632) := 207;
    pr_tbhistorico(1662) := 105;
    pr_tbhistorico(1667) := 204;
    pr_tbhistorico(1680) := 206;
    pr_tbhistorico(1686) := 202;
    pr_tbhistorico(1723) := 104;
    pr_tbhistorico(1727) := 105;
    pr_tbhistorico(1728) := 105;
    pr_tbhistorico(1729) := 204;
    pr_tbhistorico(1742) := 105;
    pr_tbhistorico(1760) := 204;
    pr_tbhistorico(1762) := 202;
    pr_tbhistorico(1766) := 204;    
    pr_tbhistorico(1787) := 209;
    pr_tbhistorico(1790) := 105;
    pr_tbhistorico(1791) := 204;
    pr_tbhistorico(1792) := 105; 
    pr_tbhistorico(1793) := 204;   
    pr_tbhistorico(1795) := 105;
    pr_tbhistorico(1796) := 105;
    pr_tbhistorico(1797) := 105;
    pr_tbhistorico(1799) := 204;
    pr_tbhistorico(1812) := 113;
    pr_tbhistorico(1813) := 113;
    pr_tbhistorico(1814) := 113;
    pr_tbhistorico(1816) := 113;
    pr_tbhistorico(1818) := 113;
    pr_tbhistorico(1823) := 219;
    pr_tbhistorico(1827) := 219;
    pr_tbhistorico(1829) := 219;
    pr_tbhistorico(1832) := 219;
    pr_tbhistorico(1841) := 105;
    pr_tbhistorico(1842) := 105;    
    pr_tbhistorico(1843) := 105;
    pr_tbhistorico(1873) := 101;
    pr_tbhistorico(1875) := 201;        
    pr_tbhistorico(1876) := 104;     
    pr_tbhistorico(1882) := 104;
    pr_tbhistorico(1892) := 114;
    pr_tbhistorico(1893) := 114;    
    pr_tbhistorico(1895) := 114;
    pr_tbhistorico(1897) := 204;
    pr_tbhistorico(1908) := 204;
    pr_tbhistorico(1909) := 204;
    pr_tbhistorico(1941) := 105;
    pr_tbhistorico(1942) := 105;
    pr_tbhistorico(1943) := 105;
    pr_tbhistorico(1950) := 105;
    pr_tbhistorico(1962) := 105;
    pr_tbhistorico(1966) := 105;
    pr_tbhistorico(1972) := 105;
    pr_tbhistorico(1974) := 105;    
    pr_tbhistorico(1976) := 105;
    pr_tbhistorico(1978) := 105;
    pr_tbhistorico(1992) := 104;
    pr_tbhistorico(1994) := 104;
    pr_tbhistorico(1998) := 218; 
    pr_tbhistorico(2006) := 104;
    pr_tbhistorico(2010) := 104;
    pr_tbhistorico(2061) := 104;
    pr_tbhistorico(2084) := 102;
    pr_tbhistorico(2087) := 102;
    pr_tbhistorico(2090) := 102;
    pr_tbhistorico(2093) := 102;
    pr_tbhistorico(2123) := 204;
    pr_tbhistorico(2160) := 204;
    pr_tbhistorico(2175) := 211;
    pr_tbhistorico(2176) := 211;
    pr_tbhistorico(2177) := 211;
    pr_tbhistorico(2178) := 211;
    pr_tbhistorico(2179) := 211;
    pr_tbhistorico(2226) := 104;
    pr_tbhistorico(2228) := 104;
    pr_tbhistorico(2230) := 104; -- 2230(D) - RECARGA OI
    pr_tbhistorico(2308) := 110; -- 2308(D) - IOF S/EMPREST
    pr_tbhistorico(2313) := 110;
    pr_tbhistorico(2318) := 110; -- 2318(D) - IOF.S/DESC.CH
    pr_tbhistorico(2320) := 110;    
    pr_tbhistorico(2321) := 110;
    pr_tbhistorico(2323) := 110;
    pr_tbhistorico(2380) := 204;
    pr_tbhistorico(2418) := 205; --2418(C) - CR COTAS PARC
    pr_tbhistorico(2425) := 104;
    pr_tbhistorico(2433) := 201;    
    pr_tbhistorico(2443) := 218; --SIPAG (CR)
    pr_tbhistorico(2447) := 218; --SIPAG (DB)
    pr_tbhistorico(2553) := 104;
    pr_tbhistorico(2658) := 201;
    pr_tbhistorico(2740) := 106;
    pr_tbhistorico(2741) := 206; --2741(C) - CR.APL.PROGR.

/*    
EXTRATO => Historico nao mapeado: 674(D) - DB. SEMASA -- 112 para pagamento fornecedores; - Eu usaria o 104 – para lançamento avisado.
EXTRATO => Historico nao mapeado: 2447(C) - SIPAG (DB) -- "202 para líquido de cobrança" ou "218 para pagamentos diversos" – Acho que pode ser o 218
EXTRATO => Historico nao mapeado: 2443(C) - SIPAG (CR) -- "202 para líquido de cobrança" ou "218 para pagamentos diversos" - Acho que pode ser o 218
*/
        
  END pc_carregar_historico_de_para;
  
  PROCEDURE pc_carregar_dados_pa(pr_tbpa OUT typ_tbpa) IS
    -- Mapeamento dos dados do PA
    -- Caso tenha que mapear um PA novo, deve-se verificar se os dados estão no chamado
    -- se não estiver no chamado, entrar em contato com o Juridico
    -- E adicionar o PA na ordem
  BEGIN
    -- Coop: 1 - PA: 1
    pr_tbpa('001_0001').cdcooper := 1;
    pr_tbpa('001_0001').cdagenci := 1;
    pr_tbpa('001_0001').dtabertu := to_date('17/01/1968','DD/MM/YYYY');
    pr_tbpa('001_0001').dstelefo := '4733314665';

    -- Coop: 1 - PA: 2
    pr_tbpa('001_0002').cdcooper := 1;
    pr_tbpa('001_0002').cdagenci := 2;
    pr_tbpa('001_0002').dtabertu := to_date('02/05/1983','DD/MM/YYYY');
    pr_tbpa('001_0002').dstelefo := '4733284803';

    -- Coop: 1 - PA: 3
    pr_tbpa('001_0003').cdcooper := 1;
    pr_tbpa('001_0003').cdagenci := 3;
    pr_tbpa('001_0003').dtabertu := to_date('01/07/1985','DD/MM/YYYY');
    pr_tbpa('001_0003').dstelefo := '4733283900';

    -- Coop: 1 - PA: 7
    pr_tbpa('001_0007').cdcooper := 1;
    pr_tbpa('001_0007').cdagenci := 7;
    pr_tbpa('001_0007').dtabertu := to_date('05/10/1988','DD/MM/YYYY');
    pr_tbpa('001_0007').dstelefo := '4733572520';

    -- Coop: 1 - PA: 8
    pr_tbpa('001_0008').cdcooper := 1;
    pr_tbpa('001_0008').cdagenci := 8;
    pr_tbpa('001_0008').dtabertu := to_date('07/07/1986','DD/MM/YYYY');
    pr_tbpa('001_0008').dstelefo := '4733371157';

    -- Coop: 1 - PA: 9
    pr_tbpa('001_0009').cdcooper := 1;
    pr_tbpa('001_0009').cdagenci := 9;
    pr_tbpa('001_0009').dtabertu := to_date('01/06/1984','DD/MM/YYYY');
    pr_tbpa('001_0009').dstelefo := '4733323958';

    -- Coop: 1 - PA: 15
    pr_tbpa('001_0015').cdcooper := 1;
    pr_tbpa('001_0015').cdagenci := 15;
    pr_tbpa('001_0015').dtabertu := to_date('31/08/2000','DD/MM/YYYY');
    pr_tbpa('001_0015').dstelefo := '4733440836';

    -- Coop: 1 - PA: 18
    pr_tbpa('001_0018').cdcooper := 1;
    pr_tbpa('001_0018').cdagenci := 18;
    pr_tbpa('001_0018').dtabertu := to_date('01/11/2001','DD/MM/YYYY');
    pr_tbpa('001_0018').dstelefo := '4733339564';

    -- Coop: 1 - PA: 19
    pr_tbpa('001_0019').cdcooper := 1;
    pr_tbpa('001_0019').cdagenci := 19;
    pr_tbpa('001_0019').dtabertu := to_date('25/07/2002','DD/MM/YYYY');
    pr_tbpa('001_0019').dstelefo := '4733400885';

    -- Coop: 1 - PA: 21
    pr_tbpa('001_0021').cdcooper := 1;
    pr_tbpa('001_0021').cdagenci := 21;
    pr_tbpa('001_0021').dtabertu := to_date('01/08/2003','DD/MM/YYYY');
    pr_tbpa('001_0021').dstelefo := '4733721302';

    -- Coop: 1 - PA: 22
    pr_tbpa('001_0022').cdcooper := 1;
    pr_tbpa('001_0022').cdagenci := 22;
    pr_tbpa('001_0022').dtabertu := to_date('05/03/2004','DD/MM/YYYY');
    pr_tbpa('001_0022').dstelefo := '4733321243';

    -- Coop: 1 - PA: 23
    pr_tbpa('001_0023').cdcooper := 1;
    pr_tbpa('001_0023').cdagenci := 23;
    pr_tbpa('001_0023').dtabertu := to_date('17/03/2004','DD/MM/YYYY');
    pr_tbpa('001_0023').dstelefo := '4733826433';

    -- Coop: 1 - PA: 25
    pr_tbpa('001_0025').cdcooper := 1;
    pr_tbpa('001_0025').cdagenci := 25;
    pr_tbpa('001_0025').dtabertu := to_date('07/04/2004','DD/MM/YYYY');
    pr_tbpa('001_0025').dstelefo := '4733498304';

    -- Coop: 1 - PA: 26
    pr_tbpa('001_0026').cdcooper := 1;
    pr_tbpa('001_0026').cdagenci := 26;
    pr_tbpa('001_0026').dtabertu := to_date('28/06/2004','DD/MM/YYYY');
    pr_tbpa('001_0026').dstelefo := '4733391790';

    -- Coop: 1 - PA: 28
    pr_tbpa('001_0028').cdcooper := 1;
    pr_tbpa('001_0028').cdagenci := 28;
    pr_tbpa('001_0028').dtabertu := to_date('11/05/2005','DD/MM/YYYY');
    pr_tbpa('001_0028').dstelefo := '4733383326';

    -- Coop: 1 - PA: 30
    pr_tbpa('001_0030').cdcooper := 1;
    pr_tbpa('001_0030').cdagenci := 30;
    pr_tbpa('001_0030').dtabertu := to_date('18/07/2005','DD/MM/YYYY');
    pr_tbpa('001_0030').dstelefo := '4733490939';

    -- Coop: 1 - PA: 31
    pr_tbpa('001_0031').cdcooper := 1;
    pr_tbpa('001_0031').cdagenci := 31;
    pr_tbpa('001_0031').dtabertu := to_date('02/08/2005','DD/MM/YYYY');
    pr_tbpa('001_0031').dstelefo := '4733254366';

    -- Coop: 1 - PA: 34
    pr_tbpa('001_0034').cdcooper := 1;
    pr_tbpa('001_0034').cdagenci := 34;
    pr_tbpa('001_0034').dtabertu := to_date('01/12/2005','DD/MM/YYYY');
    pr_tbpa('001_0034').dstelefo := '4733339523';

    -- Coop: 1 - PA: 37
    pr_tbpa('001_0037').cdcooper := 1;
    pr_tbpa('001_0037').cdagenci := 37;
    pr_tbpa('001_0037').dtabertu := to_date('27/11/2008','DD/MM/YYYY');
    pr_tbpa('001_0037').dstelefo := '4733732726';

    -- Coop: 1 - PA: 41
    pr_tbpa('001_0041').cdcooper := 1;
    pr_tbpa('001_0041').cdagenci := 41;
    pr_tbpa('001_0041').dtabertu := to_date('05/12/2007','DD/MM/YYYY');
    pr_tbpa('001_0041').dstelefo := '4733260132';

    -- Coop: 1 - PA: 42
    pr_tbpa('001_0042').cdcooper := 1;
    pr_tbpa('001_0042').cdagenci := 42;
    pr_tbpa('001_0042').dtabertu := to_date('04/06/2008','DD/MM/YYYY');
    pr_tbpa('001_0042').dstelefo := '4733974854';


    -- Coop: 1 - PA: 43
    pr_tbpa('001_0043').cdcooper := 1;
    pr_tbpa('001_0043').cdagenci := 43;
    pr_tbpa('001_0043').dtabertu := to_date('13/05/2008','DD/MM/YYYY');
    pr_tbpa('001_0043').dstelefo := '4733830887'; 
  
    -- Coop: 1 - PA: 44
    pr_tbpa('001_0044').cdcooper := 1;
    pr_tbpa('001_0044').cdagenci := 44;
    pr_tbpa('001_0044').dtabertu := to_date('01/09/2008','DD/MM/YYYY');
    pr_tbpa('001_0044').dstelefo := '4733430073';

    -- Coop: 1 - PA: 45
    pr_tbpa('001_0045').cdcooper := 1;
    pr_tbpa('001_0045').cdagenci := 45;
    pr_tbpa('001_0045').dtabertu := to_date('23/09/2008','DD/MM/YYYY');
    pr_tbpa('001_0045').dstelefo := '4733860660';
    
    -- Coop: 1 - PA: 46
    pr_tbpa('001_0046').cdcooper := 1;
    pr_tbpa('001_0046').cdagenci := 46;
    pr_tbpa('001_0046').dtabertu := to_date('30/10/2008','DD/MM/YYYY');
    pr_tbpa('001_0046').dstelefo := '4733943644';
    
    -- Coop: 1 - PA: 48
    pr_tbpa('001_0048').cdcooper := 1;
    pr_tbpa('001_0048').cdagenci := 48;
    pr_tbpa('001_0048').dtabertu := to_date('16/02/2009','DD/MM/YYYY');
    pr_tbpa('001_0048').dstelefo := '4733391874';

    -- Coop: 1 - PA: 49
    pr_tbpa('001_0049').cdcooper := 1;
    pr_tbpa('001_0049').cdagenci := 49;
    pr_tbpa('001_0049').dtabertu := to_date('27/03/2009','DD/MM/YYYY');
    pr_tbpa('001_0049').dstelefo := '4733292882';

    -- Coop: 1 - PA: 50
    pr_tbpa('001_0050').cdcooper := 1;
    pr_tbpa('001_0050').cdagenci := 50;
    pr_tbpa('001_0050').dtabertu := to_date('21/05/2009','DD/MM/YYYY');
    pr_tbpa('001_0050').dstelefo := '4733822212';
    
    -- Coop: 1 - PA: 51
    pr_tbpa('001_0051').cdcooper := 1;
    pr_tbpa('001_0051').cdagenci := 51;
    pr_tbpa('001_0051').dtabertu := to_date('04/09/2009','DD/MM/YYYY');
    pr_tbpa('001_0051').dstelefo := '4733277868';

    -- Coop: 1 - PA: 52
    pr_tbpa('001_0052').cdcooper := 1;
    pr_tbpa('001_0052').cdagenci := 52;
    pr_tbpa('001_0052').dtabertu := to_date('14/10/2009','DD/MM/YYYY');
    pr_tbpa('001_0052').dstelefo := '4733326266';

    -- Coop: 1 - PA: 54
    pr_tbpa('001_0054').cdcooper := 1;
    pr_tbpa('001_0054').cdagenci := 54;
    pr_tbpa('001_0054').dtabertu := to_date('30/04/2010','DD/MM/YYYY');
    pr_tbpa('001_0054').dstelefo := '4733239427';

    -- Coop: 1 - PA: 58
    pr_tbpa('001_0058').cdcooper := 1;
    pr_tbpa('001_0058').cdagenci := 58;
    pr_tbpa('001_0058').dtabertu := to_date('01/01/2011','DD/MM/YYYY');
    pr_tbpa('001_0058').dstelefo := '4733556501';

    -- Coop: 1 - PA: 61
    pr_tbpa('001_0061').cdcooper := 1;
    pr_tbpa('001_0061').cdagenci := 61;
    pr_tbpa('001_0061').dtabertu := to_date('20/01/2011','DD/MM/YYYY');
    pr_tbpa('001_0061').dstelefo := '4733543897';

    -- Coop: 1 - PA: 62
    pr_tbpa('001_0062').cdcooper := 1;
    pr_tbpa('001_0062').cdagenci := 62;
    pr_tbpa('001_0062').dtabertu := to_date('12/04/2011','DD/MM/YYYY');
    pr_tbpa('001_0062').dstelefo := '4735218082';

    -- Coop: 1 - PA: 63
    pr_tbpa('001_0063').cdcooper := 1;
    pr_tbpa('001_0063').cdagenci := 63;
    pr_tbpa('001_0063').dtabertu := to_date('07/07/2011','DD/MM/YYYY');
    pr_tbpa('001_0063').dstelefo := '4733947718';

    -- Coop: 1 - PA: 64
    pr_tbpa('001_0064').cdcooper := 1;
    pr_tbpa('001_0064').cdagenci := 64;
    pr_tbpa('001_0064').dtabertu := to_date('15/09/2011','DD/MM/YYYY');
    pr_tbpa('001_0064').dstelefo := '4733232602';

    -- Coop: 1 - PA: 68
    pr_tbpa('001_0068').cdcooper := 1;
    pr_tbpa('001_0068').cdagenci := 68;
    pr_tbpa('001_0068').dtabertu := to_date('17/08/2012','DD/MM/YYYY');
    pr_tbpa('001_0068').dstelefo := '4733461554';

    -- Coop: 1 - PA: 71
    pr_tbpa('001_0071').cdcooper := 1;
    pr_tbpa('001_0071').cdagenci := 71;
    pr_tbpa('001_0071').dtabertu := to_date('25/10/2012','DD/MM/YYYY');
    pr_tbpa('001_0071').dstelefo := '4733399054';

    -- Coop: 1 - PA: 72
    pr_tbpa('001_0072').cdcooper := 1;
    pr_tbpa('001_0072').cdagenci := 72;
    pr_tbpa('001_0072').dtabertu := to_date('19/12/2012','DD/MM/YYYY');
    pr_tbpa('001_0072').dstelefo := '4732738017';

    -- Coop: 1 - PA: 73
    pr_tbpa('001_0073').cdcooper := 1;
    pr_tbpa('001_0073').cdagenci := 73;
    pr_tbpa('001_0073').dtabertu := to_date('01/09/2008','DD/MM/YYYY');
    pr_tbpa('001_0073').dstelefo := '4733430073';

    -- Coop: 1 - PA: 76
    pr_tbpa('001_0076').cdcooper := 1;
    pr_tbpa('001_0076').cdagenci := 76;
    pr_tbpa('001_0076').dtabertu := to_date('21/06/2013','DD/MM/YYYY');
    pr_tbpa('001_0076').dstelefo := '4733557894';

    -- Coop: 1 - PA: 79
    pr_tbpa('001_0078').cdcooper := 1;
    pr_tbpa('001_0078').cdagenci := 78;
    pr_tbpa('001_0078').dtabertu := to_date('15/10/2013','DD/MM/YYYY');
    pr_tbpa('001_0078').dstelefo := '4733469505';    

    -- Coop: 1 - PA: 79
    pr_tbpa('001_0079').cdcooper := 1;
    pr_tbpa('001_0079').cdagenci := 79;
    pr_tbpa('001_0079').dtabertu := to_date('17/12/2013','DD/MM/YYYY');
    pr_tbpa('001_0079').dstelefo := '4733469505';    
    
    -- Coop: 1 - PA: 81
    pr_tbpa('001_0081').cdcooper := 1;
    pr_tbpa('001_0081').cdagenci := 81;
    pr_tbpa('001_0081').dtabertu := to_date('05/05/2014','DD/MM/YYYY');
    pr_tbpa('001_0081').dstelefo := '4733496403';    
    
    -- Coop: 1 - PA: 85
    pr_tbpa('001_0085').cdcooper := 1;
    pr_tbpa('001_0085').cdagenci := 85;
    pr_tbpa('001_0085').dtabertu := to_date('02/01/2014','DD/MM/YYYY');
    pr_tbpa('001_0085').dstelefo := '4733873403';
    
    -- Coop: 1 - PA: 86
    pr_tbpa('001_0086').cdcooper := 1;
    pr_tbpa('001_0086').cdagenci := 86;
    pr_tbpa('001_0086').dtabertu := to_date('02/01/2014','DD/MM/YYYY');
    pr_tbpa('001_0086').dstelefo := '4733380290';

    -- Coop: 1 - PA: 87
    pr_tbpa('001_0087').cdcooper := 1;
    pr_tbpa('001_0087').cdagenci := 87;
    pr_tbpa('001_0087').dtabertu := to_date('02/01/2014','DD/MM/YYYY');
    pr_tbpa('001_0087').dstelefo := '4733873797';

    -- Coop: 1 - PA: 88
    pr_tbpa('001_0088').cdcooper := 1;
    pr_tbpa('001_0088').cdagenci := 88;
    pr_tbpa('001_0088').dtabertu := to_date('02/01/2014','DD/MM/YYYY');
    pr_tbpa('001_0088').dstelefo := '4733875544';    
  
    -- Coop: 2 - PA: 6
    pr_tbpa('002_0006').cdcooper := 2;
    pr_tbpa('002_0006').cdagenci := 6;
    pr_tbpa('002_0006').dtabertu := to_date('08/10/2007','DD/MM/YYYY');
    pr_tbpa('002_0006').dstelefo := '4733380290';

    -- Coop: 2 - PA: 7
    pr_tbpa('002_0007').cdcooper := 2;
    pr_tbpa('002_0007').cdagenci := 7;
    pr_tbpa('002_0007').dtabertu := to_date('08/10/2007','DD/MM/YYYY');
    pr_tbpa('002_0007').dstelefo := '4733873797';

    -- Coop: 2 - PA: 8
    pr_tbpa('002_0008').cdcooper := 2;
    pr_tbpa('002_0008').cdagenci := 8;
    pr_tbpa('002_0008').dtabertu := to_date('01/12/2006','DD/MM/YYYY');
    pr_tbpa('002_0008').dstelefo := '4734679950';

    -- Coop: 2 - PA: 10
    pr_tbpa('002_0010').cdcooper := 2;
    pr_tbpa('002_0010').cdagenci := 10;
    pr_tbpa('002_0010').dtabertu := to_date('23/03/2010','DD/MM/YYYY');
    pr_tbpa('002_0010').dstelefo := '4734667722';

    -- Coop: 2 - PA: 11
    pr_tbpa('002_0011').cdcooper := 2;
    pr_tbpa('002_0011').cdagenci := 11;
    pr_tbpa('002_0011').dtabertu := to_date('01/11/2010','DD/MM/YYYY');
    pr_tbpa('002_0011').dstelefo := '4733875544';

    -- Coop: 2 - PA: 13
    pr_tbpa('002_0013').cdcooper := 2;
    pr_tbpa('002_0013').cdagenci := 13;
    pr_tbpa('002_0013').dtabertu := to_date('04/04/2011','DD/MM/YYYY');
    pr_tbpa('002_0013').dstelefo := '4734670577';

    -- Coop: 2 - PA: 14
    pr_tbpa('002_0014').cdcooper := 2;
    pr_tbpa('002_0014').cdagenci := 14;
    pr_tbpa('002_0014').dtabertu := to_date('18/11/2013','DD/MM/YYYY');
    pr_tbpa('002_0014').dstelefo := '4734339946';

    -- Coop: 2 - PA: 16
    pr_tbpa('002_0016').cdcooper := 2;
    pr_tbpa('002_0016').cdagenci := 16;
    pr_tbpa('002_0016').dtabertu := to_date('01/03/2016','DD/MM/YYYY');
    pr_tbpa('002_0016').dstelefo := '4734381876';

    -- Coop: 5 - PA: 6
    pr_tbpa('005_0006').cdcooper := 5;
    pr_tbpa('005_0006').cdagenci := 6;
    pr_tbpa('005_0006').dtabertu := to_date('01/06/2016','DD/MM/YYYY');
    pr_tbpa('005_0006').dstelefo := '4834371631';
  
    -- Coop: 6 - PA: 5
    pr_tbpa('006_0005').cdcooper := 6;
    pr_tbpa('006_0005').cdagenci := 5;
    pr_tbpa('006_0005').dtabertu := to_date('09/07/2014','DD/MM/YYYY');
    pr_tbpa('006_0005').dstelefo := '4832830064';
    
    -- Coop: 7 - PA: 1
    pr_tbpa('007_0001').cdcooper := 7;
    pr_tbpa('007_0001').cdagenci := 1;
    pr_tbpa('007_0001').dtabertu := to_date('17/05/2004','DD/MM/YYYY');
    pr_tbpa('007_0001').dstelefo := '4833240306';
    
    -- Coop: 7 - PA: 2
    pr_tbpa('007_0002').cdcooper := 7;
    pr_tbpa('007_0002').cdagenci := 2;
    pr_tbpa('007_0002').dtabertu := to_date('17/07/2006','DD/MM/YYYY');
    pr_tbpa('007_0002').dstelefo := '4732732155';
    
    -- Coop: 7 - PA: 3
    pr_tbpa('007_0003').cdcooper := 7;
    pr_tbpa('007_0003').cdagenci := 3;
    pr_tbpa('007_0003').dtabertu := to_date('05/02/2007','DD/MM/YYYY');
    pr_tbpa('007_0003').dstelefo := '4732491501';

    -- Coop: 7 - PA: 6
    pr_tbpa('007_0006').cdcooper := 7;
    pr_tbpa('007_0006').cdagenci := 6;
    pr_tbpa('007_0006').dtabertu := to_date('22/01/2010','DD/MM/YYYY');
    pr_tbpa('007_0006').dstelefo := '4832342831';
    
    -- Coop: 7 - PA: 7
    pr_tbpa('007_0007').cdcooper := 7;
    pr_tbpa('007_0007').cdagenci := 7;
    pr_tbpa('007_0007').dtabertu := to_date('28/03/2011','DD/MM/YYYY');
    pr_tbpa('007_0007').dstelefo := '4832401520';
    
    -- Coop: 7 - PA: 9
    pr_tbpa('007_0009').cdcooper := 7;
    pr_tbpa('007_0009').cdagenci := 9;
    pr_tbpa('007_0009').dtabertu := to_date('11/11/2013','DD/MM/YYYY');
    pr_tbpa('007_0009').dstelefo := '4132236162';
    
    -- Coop: 7 - PA: 10
    pr_tbpa('007_0010').cdcooper := 7;
    pr_tbpa('007_0010').cdagenci := 10;
    pr_tbpa('007_0010').dtabertu := to_date('16/10/2014','DD/MM/YYYY');
    pr_tbpa('007_0010').dstelefo := '4834330286';
    
    -- Coop: 8 - PA: 1
    pr_tbpa('008_0001').cdcooper := 8;
    pr_tbpa('008_0001').cdagenci := 1;
    pr_tbpa('008_0001').dtabertu := to_date('25/07/2007','DD/MM/YYYY');
    pr_tbpa('008_0001').dstelefo := '4833221111';
    
    -- Coop: 9 - PA: 1
    pr_tbpa('009_0001').cdcooper := 9;
    pr_tbpa('009_0001').cdagenci := 1;
    pr_tbpa('009_0001').dtabertu := to_date('29/07/2013','DD/MM/YYYY');
    pr_tbpa('009_0001').dstelefo := '4833481722';
    
    -- Coop: 9 - PA: 2
    pr_tbpa('009_0002').cdcooper := 9;
    pr_tbpa('009_0002').cdagenci := 2;
    pr_tbpa('009_0002').dtabertu := to_date('16/09/2008','DD/MM/YYYY');
    pr_tbpa('009_0002').dstelefo := '4833481722';
    
    -- Coop: 9 - PA: 3
    pr_tbpa('009_0003').cdcooper := 9;
    pr_tbpa('009_0003').cdagenci := 3;
    pr_tbpa('009_0003').dtabertu := to_date('04/04/2007','DD/MM/YYYY');
    pr_tbpa('009_0003').dstelefo := '4734342128';
    
    -- Coop: 9 - PA: 4
    pr_tbpa('009_0004').cdcooper := 9;
    pr_tbpa('009_0004').cdagenci := 4;
    pr_tbpa('009_0004').dtabertu := to_date('25/04/2007','DD/MM/YYYY');
    pr_tbpa('009_0004').dstelefo := '4933294430';

    -- Coop: 9 - PA: 5
    pr_tbpa('009_0005').cdcooper := 9;
    pr_tbpa('009_0005').cdagenci := 5;
    pr_tbpa('009_0005').dtabertu := to_date('27/04/2010','DD/MM/YYYY');
    pr_tbpa('009_0005').dstelefo := '4733478502';

    -- Coop: 9 - PA: 7
    pr_tbpa('009_0007').cdcooper := 9;
    pr_tbpa('009_0007').cdagenci := 7;
    pr_tbpa('009_0007').dtabertu := to_date('13/02/2012','DD/MM/YYYY');
    pr_tbpa('009_0007').dstelefo := '4733397077';

    -- Coop: 11 - PA: 1
    pr_tbpa('011_0001').cdcooper := 11;
    pr_tbpa('011_0001').cdagenci := 1;
    pr_tbpa('011_0001').dtabertu := to_date('15/05/2008','DD/MM/YYYY');
    pr_tbpa('011_0001').dstelefo := '4733499085';

    -- Coop: 11 - PA: 2
    pr_tbpa('011_0002').cdcooper := 11;
    pr_tbpa('011_0002').cdagenci := 2;
    pr_tbpa('011_0002').dtabertu := to_date('30/04/2009','DD/MM/YYYY');
    pr_tbpa('011_0002').dstelefo := '4733481818';

    -- Coop: 11 - PA: 4
    pr_tbpa('011_0004').cdcooper := 11;
    pr_tbpa('011_0004').cdagenci := 4;
    pr_tbpa('011_0004').dtabertu := to_date('19/09/2017','DD/MM/YYYY');
    pr_tbpa('011_0004').dstelefo := '4733666573';

    -- Coop: 11 - PA: 6
    pr_tbpa('011_0006').cdcooper := 11;
    pr_tbpa('011_0006').cdagenci := 6;
    pr_tbpa('011_0006').dtabertu := to_date('18/12/2012','DD/MM/YYYY');
    pr_tbpa('011_0006').dstelefo := '4732687088';

    -- Coop: 12 - PA: 1
    pr_tbpa('012_0001').cdcooper := 12;
    pr_tbpa('012_0001').cdagenci := 1;
    pr_tbpa('012_0001').dtabertu := to_date('06/08/2008','DD/MM/YYYY');
    pr_tbpa('012_0001').dstelefo := '4733734543';

    -- Coop: 13 - PA: 1
    pr_tbpa('013_0001').cdcooper := 13;
    pr_tbpa('013_0001').cdagenci := 1;
    pr_tbpa('013_0001').dtabertu := to_date('12/08/2008','DD/MM/YYYY');
    pr_tbpa('013_0001').dstelefo := '4736342211';

    -- Coop: 13 - PA: 4
    pr_tbpa('013_0004').cdcooper := 13;
    pr_tbpa('013_0004').cdagenci := 4;
    pr_tbpa('013_0004').dtabertu := to_date('29/07/2013','DD/MM/YYYY');
    pr_tbpa('013_0004').dstelefo := '4736331100';

    -- Coop: 13 - PA: 7
    pr_tbpa('013_0007').cdcooper := 13;
    pr_tbpa('013_0007').cdagenci := 7;
    pr_tbpa('013_0007').dtabertu := to_date('01/12/2014','DD/MM/YYYY');
    pr_tbpa('013_0007').dstelefo := '4235236462';

    -- Coop: 14 - PA: 1
    pr_tbpa('014_0001').cdcooper := 14;
    pr_tbpa('014_0001').cdagenci := 1;
    pr_tbpa('014_0001').dtabertu := to_date('01/08/2017','DD/MM/YYYY');
    pr_tbpa('014_0001').dstelefo := '4635237333';

    -- Coop: 14 - PA: 3
    pr_tbpa('014_0003').cdcooper := 14;
    pr_tbpa('014_0003').cdagenci := 3;
    pr_tbpa('014_0003').dtabertu := to_date('06/05/2013','DD/MM/YYYY');
    pr_tbpa('014_0003').dstelefo := '4635361225';

    -- Coop: 15 - PA: 1
    pr_tbpa('015_0001').cdcooper := 15;
    pr_tbpa('015_0001').cdagenci := 1;
    pr_tbpa('015_0001').dtabertu := to_date('14/04/2012','DD/MM/YYYY');
    pr_tbpa('015_0001').dstelefo := '4235236462';

    -- Coop: 16 - PA: 4
    pr_tbpa('016_0004').cdcooper := 16;
    pr_tbpa('016_0004').cdagenci := 4;
    pr_tbpa('016_0004').dtabertu := to_date('02/01/2013','DD/MM/YYYY');
    pr_tbpa('016_0004').dstelefo := '4733520765';

    -- Coop: 16 - PA: 6
    pr_tbpa('016_0006').cdcooper := 16;
    pr_tbpa('016_0006').cdagenci := 6;
    pr_tbpa('016_0006').dtabertu := to_date('02/01/2013','DD/MM/YYYY');
    pr_tbpa('016_0006').dstelefo := '4735218082';

    -- Coop: 16 - PA: 8
    pr_tbpa('016_0008').cdcooper := 16;
    pr_tbpa('016_0008').cdagenci := 8;
    pr_tbpa('016_0008').dtabertu := to_date('28/10/2013','DD/MM/YYYY');
    pr_tbpa('016_0008').dstelefo := '4735231509';

    -- Coop: 16 - PA: 9
    pr_tbpa('016_0009').cdcooper := 16;
    pr_tbpa('016_0009').cdagenci := 9;
    pr_tbpa('016_0009').dtabertu := to_date('03/12/2013','DD/MM/YYYY');
    pr_tbpa('016_0009').dstelefo := '4733523023';

    -- Coop: 16 - PA: 1
    pr_tbpa('016_0011').cdcooper := 16;
    pr_tbpa('016_0011').cdagenci := 11;
    pr_tbpa('016_0011').dtabertu := to_date('04/11/2014','DD/MM/YYYY');
    pr_tbpa('016_0011').dstelefo := '4735334418';

    -- Coop: 16 - PA: 12
    pr_tbpa('016_0012').cdcooper := 16;
    pr_tbpa('016_0012').cdagenci := 12;
    pr_tbpa('016_0012').dtabertu := to_date('10/08/2015','DD/MM/YYYY');
    pr_tbpa('016_0012').dstelefo := '4735452947';
  END pc_carregar_dados_pa;
  -- FIM -> Carregar Dados que não estão no Ayllos

  -- INICIO -> Escrever linha no arquivo
  -- Criar o arquivo
  PROCEDURE pc_abre_arquivo(pr_dirarquivo  IN VARCHAR2
                           ,pr_nmarquivo   IN VARCHAR2
                           ,pr_ind_arqlog  IN OUT UTL_FILE.file_type) IS
    vr_exc_saida EXCEPTION;
    vr_des_erro   VARCHAR2(4000);
  BEGIN
    -- Tenta abrir o arquivo de log em modo append
    gene0001.pc_abre_arquivo(pr_nmdireto => pr_dirarquivo --> Diretório do arquivo
                            ,pr_nmarquiv => pr_nmarquivo  --> Nome do arquivo
                            ,pr_tipabert => 'W'           --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => pr_ind_arqlog --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro); --> Descricao do erro
    IF vr_des_erro IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
      gene0001.pc_print(to_char(sysdate, 'hh24:mi:ss') || ' - ' ||
                        'BTCH0001.pc_gera_log_batch --> ' || vr_des_erro);
  END pc_abre_arquivo;
  
  -- Escrever no arquivo
  PROCEDURE pc_escreve_linha_arq(pr_dirarquivo  IN VARCHAR2
                                ,pr_nmarquivo   IN VARCHAR2
                                ,pr_texto_linha IN VARCHAR2
                                ,pr_ind_arqlog  IN OUT UTL_FILE.file_type) IS
    vr_exc_saida EXCEPTION;
    vr_des_erro   VARCHAR2(4000);
  BEGIN
    -- Adiciona a linha de log
    BEGIN
      gene0001.pc_escr_linha_arquivo(pr_ind_arqlog,pr_texto_linha);
    EXCEPTION
      WHEN OTHERS THEN
        -- Retornar erro
        vr_des_erro := 'Problema ao escrever no arquivo <' || pr_dirarquivo || '/' || pr_nmarquivo || '>: ' || sqlerrm;
        RAISE vr_exc_saida;
    END;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
      gene0001.pc_print(to_char(sysdate, 'hh24:mi:ss') || ' - ' ||
                        'BTCH0001.pc_gera_log_batch --> ' || vr_des_erro);
  END pc_escreve_linha_arq;
  
  -- Fechar arquivo
  PROCEDURE pc_fechar_arquivo(pr_dirarquivo  IN VARCHAR2
                             ,pr_nmarquivo   IN VARCHAR2
                             ,pr_ind_arqlog  IN OUT UTL_FILE.file_type) IS
    vr_exc_saida EXCEPTION;
    vr_des_erro   VARCHAR2(4000);
  BEGIN
    -- Libera o arquivo
    BEGIN
      gene0001.pc_fecha_arquivo(pr_ind_arqlog);
    EXCEPTION
      WHEN OTHERS THEN
        -- Retornar erro
        vr_des_erro := 'Problema ao fechar o arquivo <' || pr_dirarquivo || '/' || pr_nmarquivo || '>: ' || sqlerrm;
        RAISE vr_exc_saida;
    END;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
      gene0001.pc_print(to_char(sysdate, 'hh24:mi:ss') || ' - ' ||
                        'BTCH0001.pc_gera_log_batch --> ' || vr_des_erro);
  END pc_fechar_arquivo;
  -- FIM -> Escrever linha no arquivo


  -- INICIO -> Procedures para carregar os dados
  -- Carregar todos os dados das Agencias 
  PROCEDURE pc_carrega_arq_agencias(pr_tbconta_investigar IN     typ_tbconta_investigar --> Contar Investigadas
                                   ,pr_tbpa               IN     typ_tbpa               --> Dados dos PAs
                                   ,pr_tbarq_agencias        OUT typ_tbarq_agencias     --> Dados das agencias para o arquivo
                                   ,pr_tberro             IN OUT typ_tberro) IS         --> Tabela de erros do processo
    
    -- Variaveis Locais
    vr_idx_err   INTEGER;
    vr_idx_pa    VARCHAR2(10);
    vr_idx_cta_investigar VARCHAR2(30);
    
    -- Buscar os dados das agencias que estão sendo investigadas
    CURSOR cr_agencias (pr_cdcooper IN INTEGER
                       ,pr_nrdconta IN INTEGER) IS
      SELECT age.cdcooper
            ,age.cdagenci
            ,UPPER(age.nmextage) nmextage
            ,UPPER(age.nmcidade) nmcidade
            ,UPPER(age.cdufdcop) cdufdcop
            ,age.nrcepend
            ,UPPER(age.dsendcop) dsendcop
            ,UPPER(age.nmbairro) nmbairro
            ,ass.inpessoa
        FROM crapass ass, crapage age
       WHERE age.cdcooper = ass.cdcooper
         AND age.cdagenci = ass.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    
    -- Buscar os dados das agencias dos avalistas dessa conta
    CURSOR cr_avalistas (pr_cdcooper IN INTEGER 
                        ,pr_nrdconta IN INTEGER) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,age.cdagenci
            ,UPPER(age.nmextage) nmextage
            ,UPPER(age.nmcidade) nmcidade
            ,UPPER(age.cdufdcop) cdufdcop
            ,age.nrcepend
            ,UPPER(age.dsendcop) dsendcop
            ,UPPER(age.nmbairro) nmbairro
            ,ass.inpessoa
        FROM crapass ass, crapavt avt, crapage age
       WHERE age.cdcooper = ass.cdcooper
         AND age.cdagenci = ass.cdagenci
         AND ass.cdcooper = avt.cdcooper
         AND ass.nrcpfcgc = avt.nrcpfcgc
         AND avt.cdcooper = pr_cdcooper
         AND avt.nrdconta = pr_nrdconta
         AND avt.nrcpfcgc > 0
         AND avt.nrdctato > 0;
         
  BEGIN
    -- Percorrer todas as contas que estao sendo investigadas
    vr_idx_cta_investigar := pr_tbconta_investigar.FIRST;
    WHILE TRIM(vr_idx_cta_investigar) IS NOT NULL LOOP
      -- Carregar os dados da agencia de cada conta investigada
      FOR rw_agencia IN cr_agencias (pr_cdcooper => pr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                    ,pr_nrdconta => pr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP
                                    
        -- Chave do PA para buscar os dados
        vr_idx_pa := to_char(rw_agencia.cdcooper,'fm000') || '_' || 
                     to_char(rw_agencia.cdagenci,'fm0000');
        
        -- Se não possuir dados do PA, devemos criticar para que o Juridico providencie
        IF NOT pr_tbpa.EXISTS(vr_idx_pa) THEN
          vr_idx_err := pr_tberro.COUNT + 1;
          pr_tberro(vr_idx_err).dsorigem := 'AGENCIAS';
          pr_tberro(vr_idx_err).dserro   := 'Dados do PA nao carregados. ' ||
                                            'Cooperativa: ' || to_char(rw_agencia.cdcooper,'fm000') ||
                                            ' PA: ' || to_char(rw_agencia.cdagenci,'fm0000') ||
                                            ' Informar o telefone e a data de abertura!';
        ELSE
          -- Verificamos se os dados do PA já foram carregados, para evitar de enviarmos linhas duplicadas do PA
          IF NOT pr_tbarq_agencias.EXISTS(vr_idx_pa) THEN
            pr_tbarq_agencias(vr_idx_pa).cddbanco := '085';
            pr_tbarq_agencias(vr_idx_pa).cdagenci := rw_agencia.cdagenci;
            pr_tbarq_agencias(vr_idx_pa).nmextage := rw_agencia.nmextage;
            pr_tbarq_agencias(vr_idx_pa).dsendcop := TRIM(rw_agencia.dsendcop) || ' ' || TRIM(rw_agencia.nmbairro);
            pr_tbarq_agencias(vr_idx_pa).nmcidade := SUBSTR(rw_agencia.nmcidade, 1, 15);
            pr_tbarq_agencias(vr_idx_pa).cdufdcop := rw_agencia.cdufdcop;
            pr_tbarq_agencias(vr_idx_pa).nmdopais := 'BRASIL';
            pr_tbarq_agencias(vr_idx_pa).nrcepend := rw_agencia.nrcepend;
            pr_tbarq_agencias(vr_idx_pa).nrtelefo := pr_tbpa(vr_idx_pa).dstelefo;
            pr_tbarq_agencias(vr_idx_pa).dtabertu := to_char(pr_tbpa(vr_idx_pa).dtabertu, 'DDMMYYYY');
            pr_tbarq_agencias(vr_idx_pa).dtfecham := '';
          END IF;
        END IF;
        
        -- verificar se a conta eh de pessoa juridica
        IF rw_agencia.inpessoa = 2 THEN
          -- Temos que carregar as informacoes dos avalistas
          FOR rw_agencia_avalista IN cr_avalistas(pr_cdcooper => pr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                                 ,pr_nrdconta => pr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP
            -- Chave do PA para buscar os dados
            vr_idx_pa := to_char(rw_agencia_avalista.cdcooper,'fm000') || '_' || 
                         to_char(rw_agencia_avalista.cdagenci,'fm0000');
            --  Se não possuir dados do PA, devemos criticar para que o Juridico providencie
            IF NOT pr_tbpa.EXISTS(vr_idx_pa) THEN
              vr_idx_err := pr_tberro.COUNT + 1;
              pr_tberro(vr_idx_err).dsorigem := 'AGENCIAS';
              pr_tberro(vr_idx_err).dserro   := 'Dados do PA nao carregados. ' ||
                                                'Cooperativa: ' || to_char(rw_agencia_avalista.cdcooper,'fm000') ||
                                                ' PA: ' || to_char(rw_agencia_avalista.cdagenci,'fm0000');
            ELSE
              -- Verificamos se os dados do PA já foram carregados, para evitar de enviarmos linhas duplicadas do PA
              IF NOT pr_tbarq_agencias.EXISTS(vr_idx_pa) THEN
                pr_tbarq_agencias(vr_idx_pa).cddbanco := '085';
                pr_tbarq_agencias(vr_idx_pa).cdagenci := rw_agencia_avalista.cdagenci;
                pr_tbarq_agencias(vr_idx_pa).nmextage := rw_agencia_avalista.nmextage;
                pr_tbarq_agencias(vr_idx_pa).dsendcop := TRIM(rw_agencia_avalista.dsendcop) || ' ' ||
                                                          TRIM(rw_agencia_avalista.nmbairro);
                pr_tbarq_agencias(vr_idx_pa).nmcidade := rw_agencia_avalista.nmcidade;
                pr_tbarq_agencias(vr_idx_pa).cdufdcop := rw_agencia_avalista.cdufdcop;
                pr_tbarq_agencias(vr_idx_pa).nmdopais := 'BRASIL';
                pr_tbarq_agencias(vr_idx_pa).nrcepend := rw_agencia_avalista.nrcepend;
                pr_tbarq_agencias(vr_idx_pa).nrtelefo := pr_tbpa(vr_idx_pa).dstelefo;
                pr_tbarq_agencias(vr_idx_pa).dtabertu := to_char(pr_tbpa(vr_idx_pa).dtabertu, 'DDMMYYYY');
                pr_tbarq_agencias(vr_idx_pa).dtfecham := '';
              END IF;
            END IF;
          END LOOP; -- Loop Agencia do Avalista
        END IF; -- Pessoa Juridica

      END LOOP; --  Loop Agencia
      
      -- Ir para a proxima CONTA
      vr_idx_cta_investigar := pr_tbconta_investigar.NEXT(vr_idx_cta_investigar);
    END LOOP; --  Loop Contas investigadas
  EXCEPTION
    
    WHEN OTHERS THEN
      -- Caso acontece algum erro nao tratado, nao geramos o arquivo e o programa deve ser corrigido
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'AGENCIAS';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_carrega_arq_agencias;

  -- Carregar os dados para escrever no arquivo de _CONTAS
  PROCEDURE pc_carrega_arq_contas(pr_tbconta_investigar IN     typ_tbconta_investigar --> Contas Investigadas
                                 ,pr_dtini_quebra       IN     DATE                   --> Data de Inicio da Quebra do Sigilo
                                 ,pr_dtfim_quebra       IN     DATE                   --> Data de Fim da Quebra do Sigilo
                                 ,pr_tbarq_conta           OUT typ_tbarq_contas       --> Dados das contas para o arquivo
                                 ,pr_tberro             IN OUT typ_tberro) IS         --> Tabela de erros
    
    -- Variaveis Locais
    vr_idx_err   INTEGER;
    vr_idx_conta VARCHAR2(15);
    vr_tpmovcta  VARCHAR2(1);
    vr_idx_cta_investigar VARCHAR2(30);
    vr_idx_cta_investigar_exists VARCHAR2(30);

    -- Buscar os dados das contas que estão sendo investigadas
    CURSOR cr_contas (pr_cdcooper IN INTEGER
                     ,pr_nrdconta IN INTEGER) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.cdagenci
            ,ass.dtmvtolt -- Inicio do Relacionamento
            ,ass.dtelimin -- Fim do Relacionamento
            ,ass.inpessoa
						,ass.nrcpfcgc
						,ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;

    -- Buscar os dados das contas dos avalistas que estão sendo investigados
    CURSOR cr_avalistas (pr_cdcooper IN INTEGER 
                        ,pr_nrdconta IN INTEGER) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.nrcpfcgc
            ,ass.cdagenci
            ,ass.dtmvtolt -- Inicio do Relacionamento
            ,ass.dtelimin -- Fim do Relacionamento
            ,ass.inpessoa
        FROM crapass ass, crapavt avt
       WHERE ass.cdcooper = avt.cdcooper
         AND ass.nrcpfcgc = avt.nrcpfcgc
         AND avt.cdcooper = pr_cdcooper
         AND avt.nrdconta = pr_nrdconta
         AND avt.nrcpfcgc > 0
         AND avt.nrdctato > 0;
         
    -- verificar se a conta possui movimentacao durante o periodo da quebra
    CURSOR cr_existe_mov (pr_cdcooper IN INTEGER
                         ,pr_nrdconta IN INTEGER
                         ,pr_dtmvtolt_ini IN DATE
                         ,pr_dtmvtolt_fim IN DATE) IS
      SELECT 1 existe
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.nrdconta = pr_nrdconta
         AND lcm.dtmvtolt BETWEEN pr_dtmvtolt_ini AND pr_dtmvtolt_fim;
    rw_existe_mov cr_existe_mov%ROWTYPE;
         
  BEGIN
    -- Percorrer todas as contas que estao sendo investigadas
    vr_idx_cta_investigar := pr_tbconta_investigar.FIRST;
    WHILE TRIM(vr_idx_cta_investigar) IS NOT NULL LOOP
      -- Carregar os dados da conta de cada conta investigada
      FOR rw_conta IN cr_contas (pr_cdcooper => pr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                ,pr_nrdconta => pr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP
                                    
        -- Chave do Conta para buscar os dados
        vr_idx_conta := to_char(rw_conta.cdcooper,'fm000') || '_' || 
                        to_char(rw_conta.nrdconta,'fm0000000000');
                   
        -- Tipo Movimentação = 1 - É uma conta investigada e houve movimentação bancária no período de afastamento
        vr_tpmovcta := '1';
        
        -- Verificar se a conta teve movimentação no periodo da quebra
        OPEN cr_existe_mov (pr_cdcooper     => rw_conta.cdcooper 
                           ,pr_nrdconta     => rw_conta.nrdconta 
                           ,pr_dtmvtolt_ini => pr_dtini_quebra
                           ,pr_dtmvtolt_fim => pr_dtfim_quebra);
        FETCH cr_existe_mov INTO rw_existe_mov;
        -- Verificar se encontrou registro
        IF cr_existe_mov%NOTFOUND THEN
          -- Possui movimentação ?
          -- Tipo Movimentação = 2 - É uma conta investigada, porém não houve movimentação no período
          vr_tpmovcta := '2';
        END IF;
        -- Fecha o Cursor
        CLOSE cr_existe_mov;
        
        -- Indice da Conta que estamos criando                  
        IF NOT pr_tbarq_conta.EXISTS(vr_idx_conta) THEN
          pr_tbarq_conta(vr_idx_conta).cddbanco := '085';
          pr_tbarq_conta(vr_idx_conta).cdagenci := rw_conta.cdagenci;
          pr_tbarq_conta(vr_idx_conta).nrdconta := rw_conta.nrdconta;
          pr_tbarq_conta(vr_idx_conta).tpdconta := 1; -- Conta Corrente
          pr_tbarq_conta(vr_idx_conta).dtabertu := to_char(rw_conta.dtmvtolt, 'DDMMYYYY');
          pr_tbarq_conta(vr_idx_conta).dtfecham := to_char(rw_conta.dtelimin, 'DDMMYYYY');
          pr_tbarq_conta(vr_idx_conta).tpmovcta := vr_tpmovcta;
        END IF;
        
        -- verificar se a conta eh de pessoa juridica
        IF rw_conta.inpessoa = 2 THEN
          -- Temos que carregar as informacoes dos avalistas
          FOR rw_conta_avalista IN cr_avalistas(pr_cdcooper => pr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                               ,pr_nrdconta => pr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP
            
            -- Chave do Conta para buscar os dados
            vr_idx_cta_investigar_exists := to_char(rw_conta_avalista.cdcooper,'fm000') || '_' || 
                                            to_char(rw_conta_avalista.nrdconta,'fm0000000000') || '_' || 
                                            to_char(rw_conta_avalista.nrcpfcgc,'fm000000000000000');
                       
            -- Tipo Movimentação = 1 - É uma conta investigada e houve movimentação bancária no período de afastamento
            vr_tpmovcta := '1';
            
            -- Verificar se a conta esta sendo investigada ?
            IF NOT pr_tbconta_investigar.EXISTS(vr_idx_cta_investigar_exists) THEN
              -- Tipo Movimentação = 3 - Quando não for uma conta investigada, porém trata-se de conta do mesmo banco que efetuou transação bancária com uma conta investigada.
              vr_tpmovcta := '3';
            ELSE 
              -- Verificar se a conta teve movimentação no periodo da quebra
              OPEN cr_existe_mov (pr_cdcooper     => rw_conta_avalista.cdcooper 
                                 ,pr_nrdconta     => rw_conta_avalista.nrdconta 
                                 ,pr_dtmvtolt_ini => pr_dtini_quebra
                                 ,pr_dtmvtolt_fim => pr_dtfim_quebra);
              FETCH cr_existe_mov INTO rw_existe_mov;
              -- Verificar se encontrou registro
              IF cr_existe_mov%NOTFOUND THEN
                -- Possui movimentação ?
                -- Tipo Movimentação = 2 - É uma conta investigada, porém não houve movimentação no período
                vr_tpmovcta := '2';
              END IF;
              -- Fecha o Cursor
              CLOSE cr_existe_mov;
            END IF;
            
            -- Montar a chave para armazenar os avalistas
            vr_idx_conta := to_char(rw_conta_avalista.cdcooper,'fm000') || '_' || 
                            to_char(rw_conta_avalista.nrdconta,'fm0000000000');
            -- Indice da Conta que estamos criando                  
            IF NOT pr_tbarq_conta.EXISTS(vr_idx_conta) THEN
              pr_tbarq_conta(vr_idx_conta).cddbanco := '085';
              pr_tbarq_conta(vr_idx_conta).cdagenci := rw_conta_avalista.cdagenci;
              pr_tbarq_conta(vr_idx_conta).nrdconta := rw_conta_avalista.nrdconta;
              pr_tbarq_conta(vr_idx_conta).tpdconta := 1; -- Conta Corrente
              pr_tbarq_conta(vr_idx_conta).dtabertu := to_char(rw_conta_avalista.dtmvtolt, 'DDMMYYYY');
              pr_tbarq_conta(vr_idx_conta).dtfecham := to_char(rw_conta_avalista.dtelimin, 'DDMMYYYY');
              pr_tbarq_conta(vr_idx_conta).tpmovcta := vr_tpmovcta;
            END IF;
          END LOOP; -- Loop Conta do Avalista
        END IF; -- Pessoa Juridica

      END LOOP; --  Loop Conta Cooperado
      
      -- Ir para a proxima CONTA
      vr_idx_cta_investigar := pr_tbconta_investigar.NEXT(vr_idx_cta_investigar);
    END LOOP; --  Loop Contas investigadas
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'CONTAS';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_carrega_arq_contas;
  
  
  -- Carregar os dados para escrever no arquivo de _TITULARES
  PROCEDURE pc_carrega_arq_titulares(pr_tbconta_investigar IN     typ_tbconta_investigar --> Contas Investigadas
                                    ,pr_tbarq_titulares       OUT typ_tbarq_titulares    --> Dados dos titulares para o arquivo
                                    ,pr_tberro             IN OUT typ_tberro) IS         --> Tabela de erros
    
    -- Variaveis Locais
    vr_idx_err     INTEGER;
    vr_idx_titular VARCHAR2(30);
    vr_idx_cta_investigar VARCHAR2(30);
    vr_pessoa_investigada VARCHAR2(1);
    vr_tpendass NUMBER;
    vr_nmprimtl VARCHAR2(80);
    vr_tpdocttl VARCHAR2(50);
    vr_nrdocttl VARCHAR2(20);
    vr_dsendere VARCHAR2(80);
    vr_nmcidade VARCHAR2(40);
    vr_ufendere VARCHAR2(2);
    vr_nmdopais VARCHAR2(40);
    vr_nrcepend NUMBER(15);
    vr_nrtelefo VARCHAR2(20);
    vr_vlrrendi NUMBER(25,2);
    vr_dtultalt VARCHAR2(10);
    vr_dtabtcct VARCHAR2(10);
    vr_dtdemiss VARCHAR2(10);
    vr_inpessoa VARCHAR2(1);
    vr_nrcpfcgc NUMBER(25);
    vr_dsvincul VARCHAR2(1);
    
    -- Buscar os dados dos titulares que estão sendo investigadas
    CURSOR cr_contas (pr_cdcooper IN INTEGER
                     ,pr_nrdconta IN INTEGER) IS
      SELECT ass.cdcooper,
             ass.nrdconta,
             ass.cdagenci,
             ass.inpessoa,
             ass.dtmvtolt,
             ass.dtelimin,
             ass.nrcpfcgc,
             ass.nmprimtl,
             ass.tpdocptl,
             ass.nrdocptl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    
    -- Buscar os dados do titular "Pessoa Fisica" com base no CPF investigado
    CURSOR cr_titulares(pr_cdcooper IN INTEGER
                       ,pr_nrdconta IN INTEGER) IS
      SELECT ttl.*,
             decode(ttl.idseqttl, 
              1, 'T', -- O primeiro titular eh "T"
              2, '1', -- O segundo titular eh "1"  Primeiro co-titular
              3, '2', -- O terceiro titular eh "2"  Segundo co-titular
              4, '3', -- O quarto titular eh "3"  Terceiro co-titular
              'O') dsvincul -- Os demais titulares serão "O" Outros
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper 
         AND ttl.nrdconta = pr_nrdconta;

    -- Buscar a ultima data de alteracao na conta do cooperado
    CURSOR cr_ultima_alteracao (pr_cdcooper IN INTEGER
                               ,pr_nrdconta IN INTEGER) IS
      SELECT MAX(alt.dtaltera) dtaltera
        FROM crapalt alt
       WHERE alt.cdcooper = pr_cdcooper
         AND alt.nrdconta = pr_nrdconta
         AND alt.tpaltera = 1;
    rw_ultima_alteracao cr_ultima_alteracao%ROWTYPE;

    -- Buscar o contrato social da empresa
    CURSOR cr_contrato_social (pr_cdcooper IN INTEGER
                              ,pr_nrdconta IN INTEGER) IS
      SELECT jur.nrregemp
        ,UPPER(jur.orregemp) orregemp
      FROM crapjur jur
       WHERE jur.cdcooper = pr_cdcooper
         AND jur.nrdconta = pr_nrdconta;
    rw_contrato_social cr_contrato_social%ROWTYPE;
   
    -- Buscar o endereco do cooperado
    CURSOR cr_endereco (pr_cdcooper IN INTEGER
                       ,pr_nrdconta IN INTEGER
                       ,pr_tpendass IN INTEGER) IS
      SELECT enc.dsendere
            ,enc.nrendere
            ,enc.nmcidade
            ,enc.cdufende
            ,enc.nrcepend
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta
         AND enc.tpendass = pr_tpendass;
    rw_endereco cr_endereco%ROWTYPE;

    -- Buscar o telefone de contato do cooperado
    CURSOR cr_contato (pr_cdcooper IN INTEGER
                      ,pr_nrdconta IN INTEGER) IS
      SELECT tfc.nrdddtfc
            ,tfc.nrtelefo
        FROM craptfc tfc
       WHERE tfc.cdcooper = pr_cdcooper
         AND tfc.nrdconta = pr_nrdconta
         AND tfc.tptelefo in (1,2,3) -- 1: Residencial / 2: Celular / 3: Comercial
       ORDER BY tfc.tptelefo;
    rw_contato cr_contato%ROWTYPE;
    
    -- Buscar o rendimento do cooperado
    CURSOR cr_rendimento (pr_cdcooper IN INTEGER
                         ,pr_nrdconta IN INTEGER
                         ,pr_nrcpfcgc IN NUMBER) IS
      SELECT ttl.vlsalari,
             (ttl.vldrendi##1
            + ttl.vldrendi##2
            + ttl.vldrendi##3
            + ttl.vldrendi##4
            + ttl.vldrendi##5
            + ttl.vldrendi##6) vldrendi
      FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.nrcpfcgc = pr_nrcpfcgc;
    rw_rendimento cr_rendimento%ROWTYPE;
    
    -- Buscar o valor do ultimo faturamento informado pela empresa
    CURSOR cr_faturamento (pr_cdcooper IN INTEGER
                          ,pr_nrdconta IN INTEGER) IS
      SELECT resultado.cdcooper
            ,resultado.nrdconta
            ,TO_NUMBER(SUBSTR(resultado.chave,1,4)) max_anoftbru
            ,TO_NUMBER(SUBSTR(resultado.chave,5,2)) max_mesftbru
            ,TO_NUMBER(SUBSTR(resultado.chave,7,27)) / 100 max_vlrftbru
      FROM (
            SELECT jfn.cdcooper
                  ,jfn.nrdconta
                  ,MAX(TO_CHAR(a.anoftbru,'fm0000')
                     ||TO_CHAR(a.mesftbru,'fm00')
                     ||TO_CHAR(a.vlrftbru*100,'fm000000000000000000000000000')) chave
            FROM (
                  -- Tabela de memoria para carregar todos os valores de faturamento
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##1 mesftbru
                        ,jfni.anoftbru##1 anoftbru
                        ,jfni.vlrftbru##1 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##2 mesftbru
                        ,jfni.anoftbru##2 anoftbru
                        ,jfni.vlrftbru##2 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##3 mesftbru
                        ,jfni.anoftbru##3 anoftbru
                        ,jfni.vlrftbru##3 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##4 mesftbru
                        ,jfni.anoftbru##4 anoftbru
                        ,jfni.vlrftbru##4 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##5 mesftbru
                        ,jfni.anoftbru##5 anoftbru
                        ,jfni.vlrftbru##5 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##6 mesftbru
                        ,jfni.anoftbru##6 anoftbru
                        ,jfni.vlrftbru##6 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##7 mesftbru
                        ,jfni.anoftbru##7 anoftbru
                        ,jfni.vlrftbru##7 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##8 mesftbru
                        ,jfni.anoftbru##8 anoftbru
                        ,jfni.vlrftbru##8 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##9 mesftbru
                        ,jfni.anoftbru##9 anoftbru
                        ,jfni.vlrftbru##9 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##10 mesftbru
                        ,jfni.anoftbru##10 anoftbru
                        ,jfni.vlrftbru##10 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##11 mesftbru
                        ,jfni.anoftbru##11 anoftbru
                        ,jfni.vlrftbru##11 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##12 mesftbru
                        ,jfni.anoftbru##12 anoftbru
                        ,jfni.vlrftbru##12 vlrftbru
                  FROM crapjfn jfni
                 ) a
                ,crapjfn jfn
            WHERE a.cdcooper = jfn.cdcooper
              AND a.nrdconta = jfn.nrdconta
              AND jfn.cdcooper = pr_cdcooper
              AND jfn.nrdconta = pr_nrdconta
            GROUP BY
                   jfn.cdcooper
                  ,jfn.nrdconta
           ) resultado;
    rw_faturamento cr_faturamento%ROWTYPE;

    -- Buscar os dados das contas dos avalistas que estão sendo investigados
    CURSOR cr_avalistas (pr_cdcooper IN INTEGER 
                        ,pr_nrdconta IN INTEGER) IS
      SELECT ass.cdcooper,
             ass.nrdconta,
             ass.cdagenci,
             ass.inpessoa,
             ass.dtmvtolt,
             ass.dtelimin,
             ass.nrcpfcgc,
             ass.nmprimtl,
             ass.tpdocptl,
             ass.nrdocptl
        FROM crapass ass, crapavt avt
       WHERE ass.cdcooper = avt.cdcooper
         AND ass.nrcpfcgc = avt.nrcpfcgc
         AND avt.cdcooper = pr_cdcooper
         AND avt.nrdconta = pr_nrdconta
         AND avt.nrcpfcgc > 0
         AND avt.nrdctato > 0;
         
  BEGIN
    -- Percorrer todas as contas que estao sendo investigadas
    vr_idx_cta_investigar := pr_tbconta_investigar.FIRST;
    WHILE TRIM(vr_idx_cta_investigar) IS NOT NULL LOOP
      -- Carregar os dados da conta de cada conta investigada
      FOR rw_conta IN cr_contas (pr_cdcooper => pr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                ,pr_nrdconta => pr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP
                                    
        -- Abertura e encerramento da conta
        vr_dtabtcct := to_char(rw_conta.dtmvtolt,'DDMMYYYY');
        vr_dtdemiss := to_char(rw_conta.dtelimin,'DDMMYYYY');
        -- Tipo de pessoa 
        vr_inpessoa := rw_conta.inpessoa;
        
        -- Limpar os campos
        vr_tpdocttl := '';
        vr_nrdocttl := '';
        vr_nmprimtl := '';
        vr_nrcpfcgc := 0;
        
        -- Carregar a data da ultima atualizacao do cadastro
        vr_dtultalt := '';
        OPEN cr_ultima_alteracao (pr_cdcooper => rw_conta.cdcooper
                                 ,pr_nrdconta => rw_conta.nrdconta);
        FETCH cr_ultima_alteracao INTO rw_ultima_alteracao;
        -- Verificar se encontrou atualizacao
        IF cr_ultima_alteracao%FOUND THEN
          -- Carrega a data
          vr_dtultalt := to_char(rw_ultima_alteracao.dtaltera,'DDMMYYYY');
        END IF;
        -- Fechar o Cursor
        CLOSE cr_ultima_alteracao;
        
        -- Carregar os dados do endereço da conta
        vr_dsendere := '';
        vr_nmcidade := '';
        vr_nrcepend := '';
        -- Verificar o tipo de pessoa para carregar o endereço correto
        IF rw_conta.inpessoa = 1 THEN
          vr_tpendass := 10; -- Residencial
        ELSE
          vr_tpendass := 9;  -- Comercial
        END IF;
        -- Abrir o cursor do endereco da conta do cooperado
        OPEN cr_endereco (pr_cdcooper => rw_conta.cdcooper
                         ,pr_nrdconta => rw_conta.nrdconta
                         ,pr_tpendass => vr_tpendass);
        FETCH cr_endereco INTO rw_endereco;
        -- Verificamos se o endereço existe
        IF cr_endereco%FOUND THEN
          -- Atualizamos o endereço
          vr_dsendere := rw_endereco.dsendere || ' ' || rw_endereco.nrendere;
          vr_nmcidade := rw_endereco.nmcidade;
          vr_ufendere := rw_endereco.cdufende;
          IF rw_endereco.nrcepend > 0 THEN
            vr_nrcepend := rw_endereco.nrcepend;
          END IF;
        END IF;
        -- Fechar o Cursor
        CLOSE cr_endereco;

        -- Carregamos a informação do telefone do cooperado
        vr_nrtelefo := ''; 
        OPEN cr_contato(pr_cdcooper => rw_conta.cdcooper
                       ,pr_nrdconta => rw_conta.nrdconta);
        FETCH cr_contato INTO rw_contato;
        -- Verificar se encontrou o telefone de contato
        IF cr_contato%FOUND THEN
          -- Atulizar o telefone de contato
          vr_nrtelefo := to_char(rw_contato.nrdddtfc) || to_char(rw_contato.nrtelefo);
        END IF;
        -- Fechar o Cursor 
        CLOSE cr_contato;        
        
        -- Pessoa Fisica
        IF rw_conta.inpessoa  = 1 THEN
          
          -- Para pessoa fisica, temos que buscar os dados do Titular crapttl
          FOR rw_titular IN cr_titulares(pr_cdcooper => pr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                        ,pr_nrdconta => pr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP
                                        
            -- Chave do Conta para buscar os dados
            vr_idx_titular := to_char(rw_titular.cdcooper,'fm000') || '_' || 
                              to_char(rw_titular.nrdconta,'fm0000000000') || '_' ||
                              to_char(rw_titular.nrcpfcgc,'fm000000000000000');

            -- Pessoa esta sendo investigada ?
            vr_pessoa_investigada := '0';
            IF pr_tbconta_investigar.EXISTS(vr_idx_titular) THEN
              vr_pessoa_investigada := '1';
            END IF;
              
            -- Nome do titular 
            vr_nmprimtl := rw_titular.nmextttl;
            -- Documentos do cooperado
            vr_tpdocttl := rw_titular.tpdocttl;
            vr_nrdocttl := rw_titular.nrdocttl;
            vr_nrcpfcgc := rw_titular.nrcpfcgc;
            
            -- Carregar o valor de rendimento informado pelo cooperado
            vr_vlrrendi := 0;
            -- Quando for pessoa fisica enviamos o salario mais a renda informada
            OPEN cr_rendimento (pr_cdcooper => rw_titular.cdcooper
                               ,pr_nrdconta => rw_titular.nrdconta
                               ,pr_nrcpfcgc => rw_titular.nrcpfcgc);
            FETCH cr_rendimento INTO rw_rendimento;
            IF cr_rendimento%FOUND THEN
              -- Rendimento do Cooperado (SALARIO + RENDIMENTOS INFORMADOS)
              vr_vlrrendi := (rw_rendimento.vlsalari + rw_rendimento.vldrendi);
            END IF;
            -- Fechar Cursor
            CLOSE cr_rendimento;
            
            -- Indice da Conta que estamos criando                  
            IF NOT pr_tbarq_titulares.EXISTS(vr_idx_titular) THEN
              pr_tbarq_titulares(vr_idx_titular).cddbanco:= '085';
              pr_tbarq_titulares(vr_idx_titular).cdagenci:= rw_conta.cdagenci;
              pr_tbarq_titulares(vr_idx_titular).nrdconta:= rw_titular.nrdconta;
              pr_tbarq_titulares(vr_idx_titular).tpdconta:= 1;   -- Conta Corrente
              pr_tbarq_titulares(vr_idx_titular).dsvincul:= rw_titular.dsvincul; -- Titular da Conta
              pr_tbarq_titulares(vr_idx_titular).flafasta:= vr_pessoa_investigada;
              pr_tbarq_titulares(vr_idx_titular).inpessoa:= vr_inpessoa;
              pr_tbarq_titulares(vr_idx_titular).nrcpfcgc:= vr_nrcpfcgc;
              pr_tbarq_titulares(vr_idx_titular).nmprimtl:= vr_nmprimtl;
              pr_tbarq_titulares(vr_idx_titular).tpdocttl:= vr_tpdocttl;
              pr_tbarq_titulares(vr_idx_titular).nrdocttl:= vr_nrdocttl;
              pr_tbarq_titulares(vr_idx_titular).dsendere:= vr_dsendere;
              pr_tbarq_titulares(vr_idx_titular).nmcidade:= vr_nmcidade;
              pr_tbarq_titulares(vr_idx_titular).ufendere:= vr_ufendere;
              pr_tbarq_titulares(vr_idx_titular).nmdopais:= 'BRASIL';
              pr_tbarq_titulares(vr_idx_titular).nrcepend:= vr_nrcepend;
              pr_tbarq_titulares(vr_idx_titular).nrtelefo:= vr_nrtelefo;
              pr_tbarq_titulares(vr_idx_titular).vlrrendi:= to_char(vr_vlrrendi * 100);
              pr_tbarq_titulares(vr_idx_titular).dtultalt:= vr_dtultalt;
              pr_tbarq_titulares(vr_idx_titular).dtadmiss:= vr_dtabtcct;
              pr_tbarq_titulares(vr_idx_titular).dtdemiss:= vr_dtdemiss;
            END IF;
            
          END LOOP; -- Titulares da conta de pessoa fisica
        
        ELSE
          -- Pessoa Jurídica
          
          -- Chave do Conta para buscar os dados
          vr_idx_titular := to_char(rw_conta.cdcooper,'fm000') || '_' || 
                            to_char(rw_conta.nrdconta,'fm0000000000') || '_' ||
                            to_char(rw_conta.nrcpfcgc,'fm000000000000000');

          -- Pessoa esta sendo investigada ?
          vr_pessoa_investigada := '0';
          IF pr_tbconta_investigar.EXISTS(vr_idx_titular) THEN
            vr_pessoa_investigada := '1';
          END IF;

          -- Pessoa Juridica utiliza o contrato social
          vr_tpdocttl := '';
          vr_nrdocttl := '';
          -- Nome do titular da conta PJ
          vr_nmprimtl := rw_conta.nmprimtl;
          -- CNPJ que está sendo investigado
          vr_nrcpfcgc := rw_conta.nrcpfcgc;
          
          -- Abrir o cursor do contrato social da conta do cooperado
          OPEN cr_contrato_social (pr_cdcooper => rw_conta.cdcooper
                                  ,pr_nrdconta => rw_conta.nrdconta);
          FETCH cr_contrato_social INTO rw_contrato_social;
          -- Verificamos se o endereço existe
          IF cr_contrato_social%FOUND THEN
            vr_tpdocttl := 'CONTRATO SOCIAL';
            vr_nrdocttl := SUBSTR( to_char(rw_contrato_social.nrregemp) || ' ' || rw_contrato_social.orregemp , 1,20);
          END IF;
          -- Fechar Cursor
          CLOSE cr_contrato_social;
          
          -- Carregar o valor de rendimento informado pelo cooperado
          vr_vlrrendi := 0;
          -- Quando for pessoa juridica enviamos o valor do faturamento
          OPEN cr_faturamento (pr_cdcooper => rw_conta.cdcooper
                              ,pr_nrdconta => rw_conta.nrdconta);
          FETCH cr_faturamento INTO rw_faturamento;
          IF cr_faturamento%FOUND THEN
            -- Ultimo faturamento da empresa
            vr_vlrrendi := rw_faturamento.max_vlrftbru;
          END IF;
          -- Fechar Cursor
          CLOSE cr_faturamento;

          -- Indice da Conta que estamos criando                  
          IF NOT pr_tbarq_titulares.EXISTS(vr_idx_titular) THEN
            pr_tbarq_titulares(vr_idx_titular).cddbanco:= '085';
            pr_tbarq_titulares(vr_idx_titular).cdagenci:= rw_conta.cdagenci;
            pr_tbarq_titulares(vr_idx_titular).nrdconta:= rw_conta.nrdconta;
            pr_tbarq_titulares(vr_idx_titular).tpdconta:= 1;   -- Conta Corrente
            pr_tbarq_titulares(vr_idx_titular).dsvincul:= 'T'; -- Titular da Conta
            pr_tbarq_titulares(vr_idx_titular).flafasta:= vr_pessoa_investigada;
            pr_tbarq_titulares(vr_idx_titular).inpessoa:= vr_inpessoa;
            pr_tbarq_titulares(vr_idx_titular).nrcpfcgc:= vr_nrcpfcgc;
            pr_tbarq_titulares(vr_idx_titular).nmprimtl:= vr_nmprimtl;
            pr_tbarq_titulares(vr_idx_titular).tpdocttl:= vr_tpdocttl;
            pr_tbarq_titulares(vr_idx_titular).nrdocttl:= vr_nrdocttl;
            pr_tbarq_titulares(vr_idx_titular).dsendere:= vr_dsendere;
            pr_tbarq_titulares(vr_idx_titular).nmcidade:= vr_nmcidade;
            pr_tbarq_titulares(vr_idx_titular).ufendere:= vr_ufendere;
            pr_tbarq_titulares(vr_idx_titular).nmdopais:= 'BRASIL';
            pr_tbarq_titulares(vr_idx_titular).nrcepend:= vr_nrcepend;
            pr_tbarq_titulares(vr_idx_titular).nrtelefo:= vr_nrtelefo;
            pr_tbarq_titulares(vr_idx_titular).vlrrendi:= to_char(vr_vlrrendi * 100);
            pr_tbarq_titulares(vr_idx_titular).dtultalt:= vr_dtultalt;
            pr_tbarq_titulares(vr_idx_titular).dtadmiss:= vr_dtabtcct;
            pr_tbarq_titulares(vr_idx_titular).dtdemiss:= vr_dtdemiss;
          END IF;
        
          -- Temos que carregar as informacoes dos avalistas
          FOR rw_titular_avt IN cr_avalistas(pr_cdcooper => pr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                            ,pr_nrdconta => pr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP
            
            -- Chave do Conta para buscar os dados
            vr_idx_titular := to_char(rw_titular_avt.cdcooper,'fm000') || '_' || 
                              to_char(rw_titular_avt.nrdconta,'fm0000000000') || '_' ||
                              to_char(rw_titular_avt.nrcpfcgc,'fm000000000000000');

            -- Abertura e encerramento da conta
            vr_dtabtcct := to_char(rw_titular_avt.dtmvtolt,'DDMMYYYY');
            vr_dtdemiss := to_char(rw_titular_avt.dtelimin,'DDMMYYYY');
              
            -- Verificar se a 
            IF rw_titular_avt.inpessoa = 2 THEN
              -- Pessoa Juridica utiliza o contrato social
              vr_tpdocttl := '';
              vr_nrdocttl := '';
              -- Abrir o cursor do contrato social da conta do cooperado
              OPEN cr_contrato_social (pr_cdcooper => rw_titular_avt.cdcooper
                                      ,pr_nrdconta => rw_titular_avt.nrdconta);
              FETCH cr_contrato_social INTO rw_contrato_social;
              -- Verificamos se o endereço existe
              IF cr_contrato_social%FOUND THEN
                vr_tpdocttl := 'CONTRATO SOCIAL';
                vr_nrdocttl := to_char(rw_contrato_social.nrregemp) || ' ' || rw_contrato_social.orregemp;
              END IF;
              -- Fechar Cursor
              CLOSE cr_contrato_social;
            ELSE
              vr_tpdocttl := rw_titular_avt.tpdocptl;
              vr_nrdocttl := rw_titular_avt.nrdocptl;
            END IF;
              
            -- Pessoa esta sendo investigada ?
            vr_pessoa_investigada := '0';
            IF pr_tbconta_investigar.EXISTS(vr_idx_titular) THEN
              vr_pessoa_investigada := '1';
            END IF;
              
            -- Carregar a data da ultima atualizacao do cadastro
            vr_dtultalt := '';
            OPEN cr_ultima_alteracao (pr_cdcooper => rw_titular_avt.cdcooper
                                     ,pr_nrdconta => rw_titular_avt.nrdconta);
            FETCH cr_ultima_alteracao INTO rw_ultima_alteracao;
            -- Verificar se encontrou atualizacao
            IF cr_ultima_alteracao%FOUND THEN
              -- Carrega a data
              vr_dtultalt := to_char(rw_ultima_alteracao.dtaltera,'DDMMYYYY');
            END IF;
            -- Fechar o Cursor
            CLOSE cr_ultima_alteracao;
              
            -- Carregar os dados do endereço da conta
            vr_dsendere := '';
            vr_nmcidade := '';
            vr_nrcepend := '';
            -- Verificar o tipo de pessoa para carregar o endereço correto
            IF rw_titular_avt.inpessoa = 1 THEN
              vr_tpendass := 10; -- Residencial
            ELSE
              vr_tpendass := 9;  -- Comercial
            END IF;
            -- Abrir o cursor do endereco da conta do cooperado
            OPEN cr_endereco (pr_cdcooper => rw_titular_avt.cdcooper
                             ,pr_nrdconta => rw_titular_avt.nrdconta
                             ,pr_tpendass => vr_tpendass);
            FETCH cr_endereco INTO rw_endereco;
            -- Verificamos se o endereço existe
            IF cr_endereco%FOUND THEN
              -- Atualizamos o endereço
              vr_dsendere := rw_endereco.dsendere || ' ' || rw_endereco.nrendere;
              vr_nmcidade := rw_endereco.nmcidade;
              vr_ufendere := rw_endereco.cdufende;
              IF rw_endereco.nrcepend > 0 THEN
                vr_nrcepend := rw_endereco.nrcepend;
              END IF;
            END IF;
            -- Fechar o Cursor
            CLOSE cr_endereco;

            -- Carregamos a informação do telefone do cooperado
            vr_nrtelefo := ''; 
            OPEN cr_contato(pr_cdcooper => rw_titular_avt.cdcooper
                           ,pr_nrdconta => rw_titular_avt.nrdconta);
            FETCH cr_contato INTO rw_contato;
            -- Verificar se encontrou o telefone de contato
            IF cr_contato%FOUND THEN
              -- Atulizar o telefone de contato
              vr_nrtelefo := to_char(rw_contato.nrdddtfc) || to_char(rw_contato.nrtelefo);
            END IF;
            -- Fechar o Cursor 
            CLOSE cr_contato;
            
            -- Carregar o valor de rendimento informado pelo cooperado
            vr_vlrrendi := 0;
            -- Tratamento para pessoa física
            IF rw_titular_avt.inpessoa = 1 THEN
              -- Quando for pessoa fisica enviamos o salario mais a renda informada
              OPEN cr_rendimento (pr_cdcooper => rw_titular_avt.cdcooper
                                 ,pr_nrdconta => rw_titular_avt.nrdconta
                                 ,pr_nrcpfcgc => rw_titular_avt.nrcpfcgc);
              FETCH cr_rendimento INTO rw_rendimento;
              IF cr_rendimento%FOUND THEN
                -- Rendimento do Cooperado (SALARIO + RENDIMENTOS INFORMADOS)
                vr_vlrrendi := (rw_rendimento.vlsalari + rw_rendimento.vldrendi);
              END IF;
              -- Fechar Cursor
              CLOSE cr_rendimento;
            ELSE
              -- Quando for pessoa juridica enviamos o valor do faturamento
              OPEN cr_faturamento (pr_cdcooper => rw_titular_avt.cdcooper
                                  ,pr_nrdconta => rw_titular_avt.nrdconta);
              FETCH cr_faturamento INTO rw_faturamento;
              IF cr_faturamento%FOUND THEN
                -- Ultimo faturamento da empresa
                vr_vlrrendi := rw_faturamento.max_vlrftbru;
              END IF;
              -- Fechar Cursor
              CLOSE cr_faturamento;
            END IF;

            -- Indice da Conta que estamos criando                  
            IF NOT pr_tbarq_titulares.EXISTS(vr_idx_titular) THEN
              -- Se a conta em questão existe para investigar, temos que mandar como TITULAR
              IF pr_tbconta_investigar.EXISTS(vr_idx_titular) THEN
                vr_dsvincul := 'T'; -- TITULAR
              ELSE
                vr_dsvincul := 'R'; -- REPRESENTANTE
              END IF;
            
              pr_tbarq_titulares(vr_idx_titular).cddbanco:= '085';
              pr_tbarq_titulares(vr_idx_titular).cdagenci:= rw_titular_avt.cdagenci;
              pr_tbarq_titulares(vr_idx_titular).nrdconta:= rw_titular_avt.nrdconta;
              pr_tbarq_titulares(vr_idx_titular).tpdconta:= 1;   -- Conta Corrente
              pr_tbarq_titulares(vr_idx_titular).dsvincul:= vr_dsvincul; -- Titular da Conta
              pr_tbarq_titulares(vr_idx_titular).flafasta:= vr_pessoa_investigada;
              pr_tbarq_titulares(vr_idx_titular).inpessoa:= rw_titular_avt.inpessoa;
              pr_tbarq_titulares(vr_idx_titular).nrcpfcgc:= rw_titular_avt.nrcpfcgc;
              pr_tbarq_titulares(vr_idx_titular).nmprimtl:= rw_titular_avt.nmprimtl;
              pr_tbarq_titulares(vr_idx_titular).tpdocttl:= vr_tpdocttl;
              pr_tbarq_titulares(vr_idx_titular).nrdocttl:= vr_nrdocttl;
              pr_tbarq_titulares(vr_idx_titular).dsendere:= vr_dsendere;
              pr_tbarq_titulares(vr_idx_titular).nmcidade:= vr_nmcidade;
              pr_tbarq_titulares(vr_idx_titular).ufendere:= vr_ufendere;
              pr_tbarq_titulares(vr_idx_titular).nmdopais:= 'BRASIL';
              pr_tbarq_titulares(vr_idx_titular).nrcepend:= vr_nrcepend;
              pr_tbarq_titulares(vr_idx_titular).nrtelefo:= vr_nrtelefo;
              pr_tbarq_titulares(vr_idx_titular).vlrrendi:= to_char(vr_vlrrendi * 100);
              pr_tbarq_titulares(vr_idx_titular).dtultalt:= vr_dtultalt;
              pr_tbarq_titulares(vr_idx_titular).dtadmiss:= vr_dtabtcct;
              pr_tbarq_titulares(vr_idx_titular).dtdemiss:= vr_dtdemiss;
            END IF;
          
          END LOOP; -- Loop Conta do Avalista
          
        END IF; -- Pessoa Juridica

      END LOOP; --  Loop Conta Cooperado
      
      -- Ir para a proxima CONTA
      vr_idx_cta_investigar := pr_tbconta_investigar.NEXT(vr_idx_cta_investigar);
    END LOOP; --  Loop Contas investigadas
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'TITULARES';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_carrega_arq_titulares;
  
  -- Carregar os dados para escrever no arquivo de _EXTRATO
  PROCEDURE pc_carrega_arq_extrato(pr_tbconta_investigar IN     typ_tbconta_investigar --> Contas Investigadas
                                  ,pr_dtini_quebra       IN     DATE                   --> Data de Inicio da Quebra do Sigilo
                                  ,pr_dtfim_quebra       IN     DATE                   --> Data de Fim da Quebra do Sigilo
                                  ,pr_tbhistorico        IN     typ_tbhistorico        --> Mapeamento dos Historicos
                                  ,pr_tbarq_extrato         OUT typ_tbarq_extrato      --> Dados das contas para o arquivo
                                  ,pr_tberro             IN OUT typ_tberro) IS         --> Tabela de erros
    
    -- Variaveis Locais
    vr_idx_err     INTEGER;
    vr_idx_extrato INTEGER;
    vr_idx_cta_investigar VARCHAR2(30);
    
    vr_tplancto INTEGER;
    vr_vldsaldo NUMBER(25,2);
    vr_vlrsaldo NUMBER(25,2);
    vr_sddebcre VARCHAR2(1);
    vr_localtra VARCHAR2(50);
    
    -- Buscar os dados das contas que estão sendo investigadas
    CURSOR cr_contas (pr_cdcooper IN INTEGER
                     ,pr_nrdconta IN INTEGER) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.cdagenci
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;

    -- Buscar o saldo inicial da conta
    CURSOR cr_saldo (pr_cdcooper IN INTEGER
                    ,pr_nrdconta IN INTEGER
                    ,pr_dtmvtolt IN DATE) IS
      SELECT sda.vlsddisp
        FROM crapsda sda
       WHERE sda.cdcooper = pr_cdcooper
         AND sda.nrdconta = pr_nrdconta
         AND sda.dtmvtolt = pr_dtmvtolt;
    rw_saldo cr_saldo%ROWTYPE;

    -- Buscar as movimentações que a conte efetuou
    CURSOR cr_lancamentos (pr_cdcooper IN INTEGER
                          ,pr_nrdconta IN INTEGER
                          ,pr_dtmvtolt_ini IN DATE
                          ,pr_dtmvtolt_fim IN DATE) IS
      SELECT lcm.progress_recid
            ,lcm.dtmvtolt
            ,lcm.vllanmto
            ,lcm.nrdocmto
            ,lcm.nrterfin
            ,his.cdhistor
            ,his.dshistor
            ,his.indebcre     
        FROM craplcm lcm, craphis his
       WHERE his.cdcooper = lcm.cdcooper
         AND his.cdhistor = lcm.cdhistor
         AND lcm.cdcooper = pr_cdcooper
         AND lcm.nrdconta = pr_nrdconta
         AND lcm.dtmvtolt BETWEEN pr_dtmvtolt_ini AND pr_dtmvtolt_fim; 
         
       
  BEGIN
    -- Percorrer todas as contas que estao sendo investigadas
    vr_idx_cta_investigar := pr_tbconta_investigar.FIRST;
    WHILE TRIM(vr_idx_cta_investigar) IS NOT NULL LOOP
      -- Carregar os dados da conta de cada conta investigada
      FOR rw_conta IN cr_contas (pr_cdcooper => pr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                ,pr_nrdconta => pr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP
        
        -- Carregar o saldo inicial do cooperado 
        vr_vldsaldo := 0;
        OPEN cr_saldo (pr_cdcooper => rw_conta.cdcooper
                      ,pr_nrdconta => rw_conta.nrdconta
                      ,pr_dtmvtolt => (pr_dtini_quebra - 1));
        FETCH cr_saldo INTO rw_saldo;
        IF cr_saldo%FOUND THEN
          vr_vldsaldo := rw_saldo.vlsddisp;
        END IF;
        -- Fecha Cursor
        CLOSE cr_saldo;
                      
        -- Percorrer todas as movimentaçoes da conta
        FOR rw_lancamento IN cr_lancamentos (pr_cdcooper     => rw_conta.cdcooper
                                            ,pr_nrdconta     => rw_conta.nrdconta
                                            ,pr_dtmvtolt_ini => pr_dtini_quebra
                                            ,pr_dtmvtolt_fim => pr_dtfim_quebra) LOOP
        
          -- Identificamos se o historico do lancamento esta mapeado
          IF NOT pr_tbhistorico.EXISTS(rw_lancamento.cdhistor) THEN
            -- Gerar critica de historico nao mapeado
            vr_idx_err := pr_tberro.COUNT + 1;
            pr_tberro(vr_idx_err).dsorigem := 'EXTRATO';
            pr_tberro(vr_idx_err).dserro   := 'Historico nao mapeado: ' ||
                                              rw_lancamento.cdhistor    || '(' ||
                                              rw_lancamento.indebcre    || ') - ' ||
                                              rw_lancamento.dshistor;
            -- Vamos para o proximo lancamento
            CONTINUE;
          END IF;
          
          -- Calcular o valor do saldo do cooperado
          IF rw_lancamento.indebcre = 'C' THEN
            vr_vldsaldo := vr_vldsaldo + rw_lancamento.vllanmto;
          ELSE
            vr_vldsaldo := vr_vldsaldo - rw_lancamento.vllanmto;
          END IF;
          
          -- Verificar situacao da conta com base no lancamento que foi computado ao saldo
          IF vr_vldsaldo >= 0  THEN
      vr_sddebcre := 'C'; -- Credor
          ELSE
            vr_sddebcre := 'D'; --Devedor
          END IF;
          
          -- Verificar se o saldo esta negativo
          IF vr_vldsaldo < 0 THEN
            -- Deixar valor positivo para escrever no arquivo
            vr_vlrsaldo := vr_vldsaldo * -1;
          ELSE
            vr_vlrsaldo := vr_vldsaldo;
          END IF;
          
          -- Tipo do Lancamento, mapeado para o historico
          vr_tplancto := pr_tbhistorico(rw_lancamento.cdhistor);
          
          -- Definir o local de onde a transacao foi efetuada
          vr_localtra := '';
          IF rw_lancamento.nrterfin > 0 THEN 
            vr_localtra := 'TAA - ' || rw_lancamento.nrterfin;
          ELSIF rw_lancamento.indebcre = 'C' THEN
            vr_localtra := 'AGENCIA';
          ELSIF vr_tplancto IN (105, 102, 110, 104, 203, 207, 213, 107, 204, 106) THEN
            vr_localtra := 'AGENCIA';
          END IF;
          
          IF rw_lancamento.cdhistor = 135 THEN
            vr_localtra := 'AGENCIA';
          END IF;

          IF rw_lancamento.cdhistor IN (508, 537, 538, 539) THEN
            vr_localtra := 'INTERNET';
          END IF;

          -- Chave do Extrato
          vr_idx_extrato := pr_tbarq_extrato.COUNT + 1;
          
          pr_tbarq_extrato(vr_idx_extrato).idseqlcm := rw_lancamento.progress_recid;
          pr_tbarq_extrato(vr_idx_extrato).cddbanco := '085';
          pr_tbarq_extrato(vr_idx_extrato).cdagenci := rw_conta.cdagenci;
          pr_tbarq_extrato(vr_idx_extrato).nrdconta := rw_conta.nrdconta;
          pr_tbarq_extrato(vr_idx_extrato).tpdconta := '1'; -- Conta Corrente
          pr_tbarq_extrato(vr_idx_extrato).dtmvtolt := to_char(rw_lancamento.dtmvtolt, 'DDMMYYYY');
          pr_tbarq_extrato(vr_idx_extrato).dshistor := rw_lancamento.dshistor;
          pr_tbarq_extrato(vr_idx_extrato).tplancto := vr_tplancto;
          pr_tbarq_extrato(vr_idx_extrato).vllanmto := to_char(rw_lancamento.vllanmto * 100);
          pr_tbarq_extrato(vr_idx_extrato).indebcre := rw_lancamento.indebcre;
          pr_tbarq_extrato(vr_idx_extrato).vlrsaldo := to_char(vr_vlrsaldo * 100);
          pr_tbarq_extrato(vr_idx_extrato).sddebcre := vr_sddebcre;
          pr_tbarq_extrato(vr_idx_extrato).localtra := vr_localtra;
          IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
            pr_tbarq_extrato(vr_idx_extrato).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
          ELSE 
            pr_tbarq_extrato(vr_idx_extrato).nrdocmto := to_char(rw_lancamento.nrdocmto);
          END IF;
          
        END LOOP; -- Extrato da conta do cooperado
  
      END LOOP; --  Loop Conta Cooperado
      
      -- Ir para a proxima CONTA
      vr_idx_cta_investigar := pr_tbconta_investigar.NEXT(vr_idx_cta_investigar);
    END LOOP; --  Loop Contas investigadas
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'EXTRATO';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_carrega_arq_extrato;
  
  -- Carregar os dados para escrever no arquivo de _ORIGEM_DESTINO
  PROCEDURE pc_carrega_arq_origem_destino(pr_tbconta_investigar IN     typ_tbconta_investigar   --> Contas Investigadas
                                         ,pr_dtini_quebra       IN     DATE                     --> Data de Inicio da Quebra do Sigilo
                                         ,pr_dtfim_quebra       IN     DATE                     --> Data de Fim da Quebra do Sigilo
                                         ,pr_tbhistorico        IN     typ_tbhistorico          --> Mapeamento dos Historicos
                                         ,pr_tbarq_origem_destino  OUT typ_tbarq_origem_destino --> Dados das contas para o arquivo
                                         ,pr_tbarq_cheques_icfjud  OUT typ_tbarq_cheques_icfjud --> Dados do novo arquivo de cheques icfjud
                                         ,pr_tberro             IN OUT typ_tberro) IS           --> Tabela de erros
    
    -- Variaveis Locais
    vr_idx_err     INTEGER;
    vr_idx_ted     INTEGER;
    vr_idx_doc     INTEGER;
    vr_idx_origem_destino INTEGER;
    vr_idx_cheques_icfjud INTEGER;
    vr_idx_cta_investigar VARCHAR2(30);
    
    vr_nrsequen INTEGER := 0;
    vr_vldsaldo NUMBER(25,2);
    vr_vlrsaldo NUMBER(25,2);
    vr_tplancto INTEGER;
    vr_nrdocmto NUMBER(25);
    vr_inpessoa VARCHAR2(1);
    vr_nrcpfcgc NUMBER(25);
    vr_nmprimtl VARCHAR2(50);
    vr_cdagenci INTEGER;
    vr_nrdconta INTEGER;
    vr_cdbandep INTEGER;
    vr_nrctadep INTEGER;
    
    vr_registro BOOLEAN;
    vr_anteutil DATE;
    vr_vldpagto NUMBER(25,2);
    
    vr_found_boleto BOOLEAN;
    vr_dt_pesquisa_ret DATE;
    
    vr_lote_empres VARCHAR2(5000);
    vr_encontrou_folha_velha BOOLEAN;

    -- Buscar os dados das contas que estão sendo investigadas
    CURSOR cr_contas (pr_cdcooper IN INTEGER
                     ,pr_nrdconta IN INTEGER) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.cdagenci
            ,ass.inpessoa
            ,ass.nrcpfcgc
            ,ass.nmprimtl
            ,cop.nmextcop
            ,cop.nrdocnpj
        FROM crapass ass, crapcop cop
       WHERE cop.cdcooper = ass.cdcooper
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_conta cr_contas%ROWTYPE;

    -- Buscar o saldo inicial da conta
    CURSOR cr_saldo (pr_cdcooper IN INTEGER
                    ,pr_nrdconta IN INTEGER
                    ,pr_dtmvtolt IN DATE) IS
      SELECT sda.vlsddisp
        FROM crapsda sda
       WHERE sda.cdcooper = pr_cdcooper
         AND sda.nrdconta = pr_nrdconta
         AND sda.dtmvtolt = pr_dtmvtolt;
    rw_saldo cr_saldo%ROWTYPE;

    -- Buscar as movimentações que a conte efetuou
    CURSOR cr_lancamentos (pr_cdcooper IN INTEGER
                          ,pr_nrdconta IN INTEGER
                          ,pr_dtmvtolt_ini IN DATE
                          ,pr_dtmvtolt_fim IN DATE) IS
      SELECT lcm.cdcooper
            ,lcm.nrdconta
            ,lcm.progress_recid
            ,lcm.dtmvtolt
            ,lcm.vllanmto
            ,lcm.nrdocmto
            ,lcm.cdcoptfn
            ,lcm.nrterfin
            ,lcm.cdpesqbb
            ,lcm.nrdctabb
            ,lcm.nrdolote
            ,lcm.cdbanchq
            ,lcm.cdagechq
            ,lcm.nrctachq
            ,his.cdhistor
            ,his.dshistor
            ,his.indebcre     
        FROM craplcm lcm, craphis his
       WHERE his.cdcooper = lcm.cdcooper
         AND his.cdhistor = lcm.cdhistor
         AND lcm.cdcooper = pr_cdcooper
         AND lcm.nrdconta = pr_nrdconta
         AND lcm.dtmvtolt BETWEEN pr_dtmvtolt_ini AND pr_dtmvtolt_fim;
       
      
    CURSOR cr_lancamentos_doc (pr_cdcooper IN INTEGER
                              ,pr_nrdconta IN INTEGER
                              ,pr_dtmvtolt_ini IN DATE
                              ,pr_dtmvtolt_fim IN DATE) IS
      SELECT lcm.progress_recid
            ,lcm.dtmvtolt
            ,lcm.vllanmto
            ,lcm.nrdocmto
            ,lcm.nrterfin
            ,lcm.nrdconta
            ,lcm.cdagenci
            ,lcm.nrctachq
            ,lcm.cdbanchq
            ,lcm.cdpesqbb
            ,his.cdhistor
            ,his.dshistor
            ,his.indebcre             
            ,doc.cpfcgemi    
        FROM craplcm lcm
        JOIN craphis his
          ON his.cdcooper = lcm.cdcooper
         AND his.cdhistor = lcm.cdhistor
        JOIN gncpdoc doc
          ON doc.cdcooper = lcm.cdcooper
         AND doc.dtmvtolt = lcm.dtmvtolt
         AND doc.nrdconta = lcm.nrdconta 
         AND doc.nrdocmto = lcm.nrdocmto
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.nrdconta = pr_nrdconta
         AND lcm.dtmvtolt BETWEEN pr_dtmvtolt_ini AND pr_dtmvtolt_fim
         AND his.cdhistor IN (548, 575); 
    -- Buscar o codigo da empresa 
    CURSOR cr_empresa(pr_cdcooper IN INTEGER
                     ,pr_nrdconta IN INTEGER) IS
      SELECT emp.cdempres
        FROM crapemp emp
       WHERE emp.cdcooper = pr_cdcooper
         AND emp.nrdconta = pr_nrdconta;
    rw_empresa cr_empresa%ROWTYPE;
    
    -- Buscar os dados da conta salario
    CURSOR cr_conta_salario(pr_cdcooper IN INTEGER
                           ,pr_nrdconta IN INTEGER) IS
      SELECT ccs.* 
        FROM crapccs ccs
       WHERE ccs.cdcooper = pr_cdcooper
         AND ccs.nrdconta = pr_nrdconta;
    rw_conta_salario cr_conta_salario%ROWTYPE;
    
    -- Buscar o valor total da folha paga em determinada data
    CURSOR cr_total_folha_velha(pr_cdcooper IN INTEGER
                               ,pr_nrdolote IN INTEGER
                               ,pr_cdempres IN INTEGER
                               ,pr_dtmvtolt IN DATE)  IS
      SELECT SUM(valor) total FROM (
        -- Somar o valor de Salario - Creditado na cooperativa
        SELECT SUM(lcm.vllanmto) valor 
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.nrdolote = pr_nrdolote
           AND lcm.dtmvtolt = pr_dtmvtolt
           AND lcm.cdhistor = 8 -- Credito de salario liquido
        UNION ALL
        -- Somar o valor de Salario - Creditado na conta salario
        SELECT SUM(lcs.vllanmto) valor 
          FROM craplcs lcs, crapccs ccs 
         WHERE ccs.cdcooper = lcs.cdcooper 
           AND ccs.nrdconta = lcs.nrdconta 
           AND lcs.dtmvtolt >= ccs.dtadmiss
           AND ccs.cdempres = pr_cdempres 
           AND lcs.cdcooper = pr_cdcooper 
           AND lcs.dtmvtolt = pr_dtmvtolt
      ) tabela;
    rw_total_folha_velha cr_total_folha_velha%ROWTYPE;
    
    -- Buscar o valor total da folha paga em determinada data
    CURSOR cr_lancto_folha_velha(pr_cdcooper IN INTEGER
                                ,pr_nrdolote IN INTEGER
                                ,pr_cdempres IN INTEGER
                                ,pr_dtmvtolt IN DATE)  IS
    
      SELECT * FROM (
        -- Salario - Creditado na cooperativa
        SELECT lcm.cdcooper
              ,lcm.nrdconta
              ,lcm.vllanmto
              ,'C' idtpcont
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.nrdolote = pr_nrdolote
           AND lcm.dtmvtolt = pr_dtmvtolt
           AND lcm.cdhistor = 8 -- Credito de salario liquido
        UNION ALL
        -- Salario - Creditado na conta salario
        SELECT ccs.cdcooper
              ,ccs.nrdconta
              ,lcs.vllanmto
              ,'T' idtpcont 
          FROM craplcs lcs, crapccs ccs 
         WHERE ccs.cdcooper = lcs.cdcooper 
           AND ccs.nrdconta = lcs.nrdconta 
           AND lcs.dtmvtolt >= ccs.dtadmiss
           AND ccs.cdempres = pr_cdempres 
           AND lcs.cdcooper = pr_cdcooper 
           AND lcs.dtmvtolt = pr_dtmvtolt
      ) tabela;    
    
    -- Buscar o valor total da folha paga em determinada data
    CURSOR cr_total_folha_nova(pr_cdcooper IN INTEGER
                              ,pr_nrdconta IN INTEGER
                              ,pr_dtmvtolt IN DATE)  IS
      SELECT SUM(pfp.vllctpag) vllctpag 
        FROM crappfp pfp, crapemp emp
       WHERE pfp.cdcooper = emp.cdcooper 
         AND pfp.cdempres = emp.cdempres 
         AND pfp.dtcredit = pr_dtmvtolt
         AND emp.cdcooper = pr_cdcooper 
         AND emp.nrdconta = pr_nrdconta;
    rw_total_folha_nova cr_total_folha_nova%ROWTYPE;

    -- Buscar os dados dos lancamento auxiliares para uma date e um lote
    CURSOR cr_lancto_folha_nova (pr_cdcooper IN INTEGER
                                ,pr_nrdconta IN INTEGER
                                ,pr_dtmvtolt IN DATE)  IS
      SELECT lfp.*
        FROM craplfp lfp, crappfp pfp, crapemp emp
       WHERE lfp.cdcooper = pfp.cdcooper 
         AND lfp.cdempres = pfp.cdempres 
         AND lfp.nrseqpag = pfp.nrseqpag
         
         AND pfp.cdcooper = emp.cdcooper 
         AND pfp.cdempres = emp.cdempres 
         AND pfp.dtcredit = pr_dtmvtolt
         AND emp.cdcooper = pr_cdcooper 
         AND emp.nrdconta = pr_nrdconta;
       
		-- Buscar banco, agência e conta depositada do cheque
	  CURSOR cr_crapfdc_524(pr_cdcooper IN crapfdc.cdcooper%TYPE
                         ,pr_nrdconta IN crapfdc.nrdconta%TYPE
		                     ,pr_cdbanchq IN crapfdc.cdbanchq%TYPE
												 ,pr_cdagechq IN crapfdc.cdagechq%TYPE
												 ,pr_nrctachq IN crapfdc.nrctachq%TYPE
												 ,pr_nrcheque IN crapfdc.nrcheque%TYPE) IS
			SELECT fdc.cdbandep
			      ,fdc.cdagedep
						,fdc.nrctadep
						,fdc.dsdocmc7
			  FROM crapfdc fdc
			 WHERE fdc.cdcooper = pr_cdcooper
			   AND fdc.nrdconta = pr_nrdconta
			   AND fdc.cdbandep = pr_cdbanchq
				 AND fdc.cdagedep = pr_cdagechq
				 AND fdc.nrctadep = pr_nrctachq
				 AND fdc.nrcheque = pr_nrcheque;
    rw_crapfdc_524 cr_crapfdc_524%ROWTYPE;
		
    -- Buscar os dados do cheque
    CURSOR cr_cheque(pr_cdcooper IN INTEGER
                    ,pr_nrdconta IN INTEGER
                    ,pr_nrcheque IN INTEGER) IS
      SELECT fdc.cdbandep
            ,fdc.cdagedep
            ,fdc.nrctadep
            ,fdc.nrctachq
        FROM crapfdc fdc 
       WHERE fdc.cdcooper = pr_cdcooper
         AND fdc.nrdconta = pr_nrdconta
         AND fdc.nrcheque = pr_nrcheque;
     rw_cheque cr_cheque%ROWTYPE;
      
    -- Buscar os dados da conta do cooperado a partir da agencia da cooperativa
    CURSOR cr_conta_aux(pr_cdagectl IN INTEGER
                       ,pr_nrdconta IN INTEGER) IS
      SELECT ass.nmprimtl
            ,ass.inpessoa
            ,ass.nrcpfcgc
            ,ass.cdagenci
        FROM crapass ass, crapcop cop
       WHERE cop.cdcooper = ass.cdcooper
         AND ass.nrdconta = pr_nrdconta
         AND cop.cdagectl = pr_cdagectl;
    rw_conta_aux cr_conta_aux%ROWTYPE;
     
    -- Buscar os dados da conta do cooperado com o codigo da cooperativa
    CURSOR cr_conta_aux2(pr_cdcooper IN INTEGER
                       ,pr_nrdconta IN INTEGER) IS
      SELECT ass.nmprimtl
            ,DECODE(ass.inpessoa,1,1,2) inpessoa
            ,ass.nrcpfcgc
            ,ass.cdagenci
        FROM crapass ass
       WHERE ass.nrdconta = pr_nrdconta
         AND ass.cdcooper = pr_cdcooper;
    rw_conta_aux2 cr_conta_aux2%ROWTYPE;
      
    -- Buscar os dados do boleto
    CURSOR cr_boleto (pr_cdcooper IN INTEGER
                     ,pr_nrdconta IN INTEGER
                     ,pr_dtdpagto IN DATE
                     ,pr_nrdocmto IN INTEGER) IS
      SELECT cob.vldpagto
            ,cob.nrinssac
            ,cob.nrdocmto
            ,cob.cdbanpag
            ,cob.cdagepag
        FROM crapcob cob
       WHERE cob.cdcooper = pr_cdcooper
         AND cob.nrdconta = pr_nrdconta
         AND cob.dtdpagto = pr_dtdpagto
         AND cob.nrdocmto = pr_nrdocmto;
    rw_boleto cr_boleto%ROWTYPE;
    
    -- Buscar os dados do boleto
    CURSOR cr_boleto_2 (pr_cdcooper IN INTEGER
                       ,pr_nrdconta IN INTEGER
                       ,pr_nrcnvcob IN INTEGER
                       ,pr_nrdocmto IN INTEGER) IS
      SELECT cob.vldpagto
            ,cob.nrinssac
            ,cob.nrdocmto
            ,cob.cdbanpag
            ,cob.cdagepag
        FROM crapcob cob
       WHERE cob.cdcooper = pr_cdcooper
         AND cob.nrdconta = pr_nrdconta
         AND cob.nrcnvcob = pr_nrcnvcob
         AND cob.nrdocmto = pr_nrdocmto;
    rw_boleto_2 cr_boleto_2%ROWTYPE;

    -- Credito de Cobranca - Histórico 971
    CURSOR cr_crapret_971(pr_cdcooper IN INTEGER
                         ,pr_nrdconta IN INTEGER
                         ,pr_dtcredit IN crapret.dtcredit%TYPE) IS
      SELECT ret.*
        FROM crapret ret, crapcco cco
       WHERE cco.cdcooper = ret.cdcooper 
         AND cco.nrconven = ret.nrcnvcob
         AND cco.cddbanco = 1 -- Apenas convenio BB
         AND ret.cdcooper = pr_cdcooper
         AND ret.nrdconta = pr_nrdconta
         AND ( ( --- Liberação do FLOAT
                     pr_dtcredit >= to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit = pr_dtcredit
                 AND ret.flcredit = 1
                 AND ret.cdocorre IN (6,17)
               ) OR (
                     pr_dtcredit < to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit IS NULL
                 AND ret.flcredit = 0
                 AND ret.dtocorre = pr_dtcredit
                 AND ret.cdocorre IN (6,17)
               )
             );

    -- Credito de Cobranca - Histórico 977
    CURSOR cr_crapret_977(pr_cdcooper IN INTEGER
                         ,pr_nrdconta IN INTEGER
                         ,pr_dtcredit IN crapret.dtcredit%TYPE) IS
      SELECT ret.*
        FROM crapret ret, crapcop cop, crapcco cco
       WHERE cop.cdcooper = ret.cdcooper
         AND cco.cdcooper = ret.cdcooper 
         AND cco.nrconven = ret.nrcnvcob
         AND cco.cddbanco = 85 -- Apenas convenio CECRED
         AND ret.cdcooper = pr_cdcooper
         AND ret.nrdconta = pr_nrdconta
         AND ( ( --- Liberação do FLOAT
                     pr_dtcredit >= to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit = pr_dtcredit
                 AND ret.flcredit = 1
                 AND ((ret.cdbcorec = 85 and ret.cdagerec <> cop.cdagectl and ret.cdocorre IN (6,76)) or
                      (ret.cdbcorec <> 85 and ret.cdocorre IN (6,76)))
               ) OR (
                     pr_dtcredit < to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit IS NULL
                 AND ret.flcredit = 0
                 AND ret.dtocorre = pr_dtcredit
                 AND ((ret.cdbcorec = 85 and ret.cdagerec <> cop.cdagectl and ret.cdocorre IN (6,76)) or
                      (ret.cdbcorec <> 85 and ret.cdocorre IN (6,76)))
               )
             );    
    
    -- Credito de Cobranca - Histórico 987
    CURSOR cr_crapret_987(pr_cdcooper IN INTEGER
                         ,pr_nrdconta IN INTEGER
                         ,pr_dtcredit IN crapret.dtcredit%TYPE) IS
      SELECT ret.*
        FROM crapret ret, crapcop cop, crapcco cco
       WHERE cop.cdcooper = ret.cdcooper
         AND cco.cdcooper = ret.cdcooper 
         AND cco.nrconven = ret.nrcnvcob
         AND cco.cddbanco = 85 -- Apenas convenio CECRED
         AND ret.cdcooper = pr_cdcooper
         AND ret.nrdconta = pr_nrdconta
         AND ( ( --- Liberação do FLOAT
                     pr_dtcredit >= to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit = pr_dtcredit
                 AND ret.flcredit = 1
                 AND ret.cdbcorec = 85
                 AND ret.cdagerec = cop.cdagectl
                 AND ret.cdocorre IN (6,76)
               ) OR (
                     pr_dtcredit < to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit IS NULL
                 AND ret.flcredit = 0
                 AND ret.dtocorre = pr_dtcredit
                 AND ret.cdbcorec = 85
                 AND ret.cdagerec = cop.cdagectl
                 AND ret.cdocorre IN (6,76)
               )
             );


    -- Credito de Cobranca - Histórico 1089
    CURSOR cr_crapret_1089(pr_cdcooper IN INTEGER
                          ,pr_nrdconta IN INTEGER
                          ,pr_dtcredit IN crapret.dtcredit%TYPE
                          ,pr_vltitulo IN crapret.vltitulo%TYPE) IS
      
      SELECT *
        FROM (SELECT ret.*
                    ,SUM(ret.vlrpagto) OVER (PARTITION BY ret.cdoperad) totalret
        FROM crapret ret, crapcco cco
       WHERE cco.cdcooper = ret.cdcooper 
         AND cco.nrconven = ret.nrcnvcob
         AND cco.cddbanco = 85 -- Apenas convenio CECRED
         AND ret.cdcooper = pr_cdcooper
         AND ret.nrdconta = pr_nrdconta
         AND ( ( --- Liberação do FLOAT
                     pr_dtcredit >= to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit = pr_dtcredit
                 AND ret.flcredit = 1
                 AND ret.cdocorre IN (17,77)
               ) OR (
                     pr_dtcredit < to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit IS NULL
                 AND ret.flcredit = 0
                 AND ret.dtocorre = pr_dtcredit
                 AND ret.cdocorre IN (17,77)
               )
                     )
                    )
       WHERE totalret = pr_vltitulo;
    
    -- Buscar os dados do pagador
    CURSOR cr_pagador(pr_cdcooper IN INTEGER
                     ,pr_nrdconta IN INTEGER
                     ,pr_nrinssac IN NUMBER) IS
      SELECT sab.cdtpinsc 
            ,sab.nrinssac
            ,sab.nmdsacad
        FROM crapsab sab
       WHERE sab.cdcooper = pr_cdcooper
         AND sab.nrdconta = pr_nrdconta
         AND sab.nrinssac = pr_nrinssac;
    rw_pagador cr_pagador%ROWTYPE;
    
    -- Buscar os dados da Custodia de Cheque
    CURSOR cr_custodia_cheque(pr_cdcooper IN INTEGER
                             ,pr_nrdconta IN INTEGER
                             ,pr_nrdocmto IN INTEGER) IS
      SELECT cst.vlcheque
            ,cst.nrdocmto
            ,cst.cdbanchq
            ,cst.cdagechq
            ,cst.nrctachq       
						,cst.cdcooper
						,cst.dsdocmc7
        FROM crapcst cst       
       WHERE cst.cdcooper = pr_cdcooper
         AND cst.nrdconta = pr_nrdconta
         AND cst.nrdocmto = pr_nrdocmto;
    rw_custodia_cheque cr_custodia_cheque%ROWTYPE;
    
    -- Buscar os dados do cheque 
    CURSOR cr_cheque_085 (pr_cdcooper IN INTEGER
                         ,pr_nrdconta IN INTEGER
                         ,pr_nrdocmto IN INTEGER) IS
      SELECT chd.nrctachq
            ,chd.cdagechq
        FROM crapchd chd
       WHERE chd.cdcooper = pr_cdcooper
         AND chd.nrdconta = pr_nrdconta
         AND chd.nrdocmto = pr_nrdocmto
         AND chd.cdbanchq = 085;
    rw_cheque_085 cr_cheque_085%ROWTYPE;

    -- Buscar os dados do cheque 
    CURSOR cr_all_cheques (pr_cdcooper IN INTEGER
                          ,pr_nrdconta IN INTEGER
                          ,pr_nrdocmto IN INTEGER) IS
      SELECT chd.nrctachq
            ,chd.cdagechq
            ,chd.cdbanchq
            ,chd.vlcheque
            ,chd.dsdocmc7
        FROM crapchd chd
       WHERE chd.cdcooper = pr_cdcooper
         AND chd.nrdconta = pr_nrdconta
         AND chd.nrdocmto = pr_nrdocmto;

    -- Buscar os dados do cheque na DATA
    CURSOR cr_all_cheques_data (pr_cdcooper IN INTEGER
                               ,pr_nrdconta IN INTEGER
                               ,pr_nrdocmto IN INTEGER
                               ,pr_dtmvtolt IN DATE) IS
      SELECT chd.nrctachq
            ,chd.cdagechq
            ,chd.cdbanchq
            ,chd.vlcheque
            ,chd.nrdocmto
        FROM crapchd chd
       WHERE chd.cdcooper = pr_cdcooper
         AND chd.nrdconta = pr_nrdconta
         AND chd.nrdocmto = pr_nrdocmto
         AND chd.dtmvtolt = pr_dtmvtolt;
         
    -- Buscar os dados de Transferencia de Valores
    CURSOR cr_transf_valor (pr_cdcooper IN INTEGER
                           ,pr_nrdconta IN INTEGER
                           ,pr_vldocrcb IN NUMBER
                           ,pr_dtmvtolt IN DATE
                           ,pr_nrdocmto IN INTEGER) IS
      SELECT tvl.cpfcgrcb,
             tvl.cdbccrcb,
             tvl.cdagercb,
             tvl.nrcctrcb,
             tvl.nmpesrcb,
             tvl.flgpescr -- Tipo de Pessoa que receberá a TED
        FROM craptvl tvl
       WHERE tvl.cdcooper = pr_cdcooper
         AND tvl.nrdconta = pr_nrdconta
         AND tvl.vldocrcb = pr_vldocrcb
         AND tvl.dtmvtolt = pr_dtmvtolt
         AND tvl.nrdocmto = pr_nrdocmto;
    rw_transf_valor cr_transf_valor%ROWTYPE;
    
    -- Bordero de Cheque
    CURSOR cr_bordero_cheque (pr_cdcooper IN INTEGER
                             ,pr_nrdconta IN INTEGER
                             ,pr_nrborder IN INTEGER) IS
      SELECT cdb.vlliquid
            ,cdb.nrdocmto
            ,cdb.cdbanchq
            ,cdb.cdagechq
            ,cdb.nrctachq
      FROM crapcdb cdb
      WHERE cdb.cdcooper = pr_cdcooper 
        AND cdb.nrdconta = pr_nrdconta 
        AND cdb.nrborder = pr_nrborder;                             

    -- Bordero de Titulos
    CURSOR cr_bordero_titulo (pr_cdcooper IN INTEGER
                             ,pr_nrdconta IN INTEGER
                             ,pr_nrborder IN INTEGER) IS
      SELECT tdb.vlliquid
            ,tdb.nrdocmto
            ,tdb.nrinssac
      FROM craptdb tdb
      WHERE tdb.cdcooper = pr_cdcooper 
        AND tdb.nrdconta = pr_nrdconta 
        AND tdb.nrborder = pr_nrborder;

    -- Buscar as informações de TED
    CURSOR cr_ted (pr_cdcooper IN INTEGER
                  ,pr_nrdconta IN INTEGER
                  ,pr_dtmvtini IN DATE
                  ,pr_dtmvtfim IN DATE) IS
      SELECT lmt.vldocmto,
             lmt.cdbandif banco,
             lmt.cdagedif,
             lmt.nrctadif,
             TRIM(lmt.nmtitdif) nmtitdif,
             lmt.nrcpfdif,
             lmt.cdbanctl,
             lmt.cdagectl,
             lmt.nrdconta,
             lmt.nmcopcta,
             lmt.nrcpfcop,
             lmt.cdagenci,
             lmt.dttransa
        FROM craplmt lmt
       WHERE lmt.cdcooper = pr_cdcooper
         AND lmt.nrdconta = pr_nrdconta 
         AND lmt.dttransa BETWEEN pr_dtmvtini AND pr_dtmvtfim
         AND lmt.idsitmsg = 3 -- (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
    ORDER BY lmt.dttransa, lmt.hrtransa, lmt.nrsequen;
   
    CURSOR cr_conta_itg(pr_cdcooper crapass.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta
            ,ass.cdcooper
            ,cop.cdageitg
            ,ass.nrdctitg
            ,ass.nmprimtl
            ,ass.nrcpfcgc
        FROM crapass ass
        JOIN crapcop cop
          ON ass.cdcooper = cop.cdcooper 
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_conta_itg cr_conta_itg %ROWTYPE;
    
    Cursor cr_crapicf (pr_cdcooper     IN INTEGER
                      ,pr_dacaojud     IN VARCHAR2
                      ,pr_nrctareq     IN INTEGER 
                      ,pr_cdbanreq     IN INTEGER
                      ,pr_cdagereq     IN INTEGER) IS
	  SELECT dtinireq,
		     cdbanreq,
		     cdagereq,
		     nrctareq,
		     intipreq,
		     dsdocmc7,
		     nrcpfcgc,
		     nmprimtl
    FROM crapicf
       WHERE cdcooper = pr_cdcooper
       AND dacaojud = Upper(pr_dacaojud)
       AND nrctareq = pr_nrctareq
       AND cdbanreq = pr_cdbanreq
       AND cdagereq = pr_cdagereq;
	--
	rw_crapicf cr_crapicf%ROWTYPE;
  
    -- Buscar os dados do cheque
    CURSOR cr_cheque_2433(pr_cdcooper IN INTEGER
						 ,pr_nrdconta IN INTEGER
						 ,pr_dtmvtolt IN DATE
						 ,pr_nrdocmto IN INTEGER) IS
      SELECT cdbanchq
			,cdagechq
			,cdoperad
			,nrctachq
			,nrcheque
			,vlcheque
			,progress_recid
			,nrdocmto
					,dsdocmc7
        FROM crapchd
 	   WHERE cdcooper = pr_cdcooper 
	     AND nrdconta = pr_nrdconta
	     AND dtmvtolt = pr_dtmvtolt
	     AND nrdocmto = pr_nrdocmto;
    rw_cheque_2433 cr_cheque%ROWTYPE;
	
  CURSOR cr_cooperativa(pr_cdagectl IN crapcop.cdagectl%TYPE) IS
		SELECT crapcop.cdcooper
		  FROM crapcop
     WHERE crapcop.cdagectl = pr_cdagectl;
  rw_cooperativa cr_cooperativa%ROWTYPE;
	--
	CURSOR cr_cooperado(pr_cdcooper IN INTEGER
					   ,pr_nrdconta IN INTEGER) IS
		SELECT crapass.nmprimtl, crapass.nrcpfcgc 
		  FROM crapass 
		 WHERE crapass.cdcooper = pr_cdcooper
		   AND crapass.nrdconta = pr_nrdconta;
	--
	rw_cooperado cr_cooperado%ROWTYPE;
  
  -- Buscar os dados do boleto BB (hist 266)
  CURSOR cr_cobranca (pr_cdcooper IN INTEGER
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS            
    SELECT cob.nrinssac FROM crapcob cob
     WHERE cob.cdcooper = pr_cdcooper
       AND cob.nrdconta = pr_nrdconta
       AND cob.nrdocmto = pr_nrdocmto
       AND cob.cdbandoc = 1;                      
  rw_cobranca cr_cobranca%ROWTYPE;

  CURSOR cr_sacado(pr_cdcooper IN INTEGER
                  ,pr_nrdconta IN crapass.nrdconta%TYPE
                  ,pr_nrinssac IN crapcob.nrinssac%TYPE) IS
    SELECT sab.cdtpinsc
          ,sab.nrinssac
          ,sab.nmdsacad
      FROM crapsab sab
     WHERE sab.cdcooper = pr_cdcooper
       AND sab.nrdconta = pr_nrdconta
       AND sab.nrinssac = pr_nrinssac;
  rw_sacado cr_sacado%ROWTYPE;
   
  
	--
  BEGIN
    -- Percorrer todas as contas que estao sendo investigadas
    vr_idx_cta_investigar := pr_tbconta_investigar.FIRST;
    WHILE TRIM(vr_idx_cta_investigar) IS NOT NULL LOOP
      -- Carregar os dados da conta de cada conta investigada
      FOR rw_conta IN cr_contas (pr_cdcooper => pr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                ,pr_nrdconta => pr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP
        
        -- Carregar o saldo inicial do cooperado 
        vr_vldsaldo := 0;
        OPEN cr_saldo (pr_cdcooper => rw_conta.cdcooper
                      ,pr_nrdconta => rw_conta.nrdconta
                      ,pr_dtmvtolt => (pr_dtini_quebra - 1));
        FETCH cr_saldo INTO rw_saldo;
        IF cr_saldo%FOUND THEN
          vr_vldsaldo := rw_saldo.vlsddisp;
        END IF;
        -- Fecha Cursor
        CLOSE cr_saldo;
        
        -- Para cada conta investigada, devemos carregar os dados de TED
        vr_tbted.DELETE;
        FOR rw_ted IN cr_ted(pr_cdcooper => rw_conta.cdcooper
                            ,pr_nrdconta => rw_conta.nrdconta
                            ,pr_dtmvtini => pr_dtini_quebra
                            ,pr_dtmvtfim => pr_dtfim_quebra) LOOP
          -- Contador
          vr_idx_ted := vr_tbted.COUNT + 1;
          -- Carregar os dados da ted
          vr_tbted(vr_idx_ted).datadted := rw_ted.dttransa;
          vr_tbted(vr_idx_ted).cdbancod := rw_ted.banco;
          vr_tbted(vr_idx_ted).nmclideb := rw_ted.nmtitdif;
          vr_tbted(vr_idx_ted).nrcpfdeb := rw_ted.nrcpfdif;
          vr_tbted(vr_idx_ted).contadeb := rw_ted.nrctadif;
          vr_tbted(vr_idx_ted).agenciad := rw_ted.cdagedif;
          vr_tbted(vr_idx_ted).valorted := rw_ted.vldocmto;
          vr_tbted(vr_idx_ted).regativo := 0;
          
          -- Se a TED nao possui CPF de origem e o banco eh o 756 (Bancoob)
          -- Iremos adicionar o CNPJ do banco como origem
          IF rw_ted.nrcpfdif = 0   AND 
             rw_ted.banco    = 756 THEN
             vr_tbted(vr_idx_ted).nrcpfdeb := 02038232000164;
          END IF;
        END LOOP;

        vr_tbdoc.DELETE;
        -- DOC sempre será montado manualmente
        -- MANUAL (baca\Reutilizaveis\quebra_sigilo_docs.sql)

vr_tbdoc(1).cdagenci := 1;
        vr_tbdoc(1).nrcpfdeb := 0000000000;
        vr_tbdoc(1).nrdconta := 3834956;
        vr_tbdoc(1).nrctadeb := 6423361;
        vr_tbdoc(1).dtmvtolt := TO_DATE('06/07/12','DD/MM/RRRR');
        vr_tbdoc(1).cdbancod := 1;
        vr_tbdoc(1).nmclideb := 'CONSTRUTORA POLICONS LT';
        vr_tbdoc(1).valordoc := 1120;
        vr_tbdoc(1).flgativo := 0;
vr_tbdoc(2).cdagenci := 1;
        vr_tbdoc(2).nrcpfdeb := 0000000000;
        vr_tbdoc(2).nrdconta := 6121039;
        vr_tbdoc(2).nrctadeb := 6423361;
        vr_tbdoc(2).dtmvtolt := TO_DATE('04/08/11','DD/MM/RRRR');
        vr_tbdoc(2).cdbancod := 1;
        vr_tbdoc(2).nmclideb := 'CONSTRUTORA POLICONS LT';
        vr_tbdoc(2).valordoc := 1000;
        vr_tbdoc(2).flgativo := 0;
vr_tbdoc(3).cdagenci := 1;
        vr_tbdoc(3).nrcpfdeb := 0000000000;
        vr_tbdoc(3).nrdconta := 6121039;
        vr_tbdoc(3).nrctadeb := 6423361;
        vr_tbdoc(3).dtmvtolt := TO_DATE('09/08/11','DD/MM/RRRR');
        vr_tbdoc(3).cdbancod := 1;
        vr_tbdoc(3).nmclideb := 'CONSTRUTORA POLICONS LT';
        vr_tbdoc(3).valordoc := 1000;
        vr_tbdoc(3).flgativo := 0;
vr_tbdoc(4).cdagenci := 1;
        vr_tbdoc(4).nrcpfdeb := 0000000000;
        vr_tbdoc(4).nrdconta := 6121039;
        vr_tbdoc(4).nrctadeb := 6423361;
        vr_tbdoc(4).dtmvtolt := TO_DATE('19/08/11','DD/MM/RRRR');
        vr_tbdoc(4).cdbancod := 1;
        vr_tbdoc(4).nmclideb := 'CONSTRUTORA POLICONS LT';
        vr_tbdoc(4).valordoc := 1500;
        vr_tbdoc(4).flgativo := 0;
vr_tbdoc(5).cdagenci := 1;
        vr_tbdoc(5).nrcpfdeb := 0000000000;
        vr_tbdoc(5).nrdconta := 6121039;
        vr_tbdoc(5).nrctadeb := 6423361;
        vr_tbdoc(5).dtmvtolt := TO_DATE('15/09/11','DD/MM/RRRR');
        vr_tbdoc(5).cdbancod := 1;
        vr_tbdoc(5).nmclideb := 'CONSTRUTORA POLICONS LT';
        vr_tbdoc(5).valordoc := 3000;
        vr_tbdoc(5).flgativo := 0;
vr_tbdoc(6).cdagenci := 1;
        vr_tbdoc(6).nrcpfdeb := 0000000000;
        vr_tbdoc(6).nrdconta := 6121039;
        vr_tbdoc(6).nrctadeb := 6423361;
        vr_tbdoc(6).dtmvtolt := TO_DATE('03/10/11','DD/MM/RRRR');
        vr_tbdoc(6).cdbancod := 1;
        vr_tbdoc(6).nmclideb := 'CONSTRUTORA POLICONS LT';
        vr_tbdoc(6).valordoc := 1200;
        vr_tbdoc(6).flgativo := 0;
vr_tbdoc(7).cdagenci := 1;
        vr_tbdoc(7).nrcpfdeb := 0000000000;
        vr_tbdoc(7).nrdconta := 6121039;
        vr_tbdoc(7).nrctadeb := 6423361;
        vr_tbdoc(7).dtmvtolt := TO_DATE('21/10/11','DD/MM/RRRR');
        vr_tbdoc(7).cdbancod := 1;
        vr_tbdoc(7).nmclideb := 'CONSTRUTORA POLICONS LT';
        vr_tbdoc(7).valordoc := 4500;
        vr_tbdoc(7).flgativo := 0;
vr_tbdoc(8).cdagenci := 1;
        vr_tbdoc(8).nrcpfdeb := 0000000000;
        vr_tbdoc(8).nrdconta := 6121039;
        vr_tbdoc(8).nrctadeb := 6423361;
        vr_tbdoc(8).dtmvtolt := TO_DATE('25/05/12','DD/MM/RRRR');
        vr_tbdoc(8).cdbancod := 1;
        vr_tbdoc(8).nmclideb := 'CONSTRUTORA POLICONS LT';
        vr_tbdoc(8).valordoc := 1000;
        vr_tbdoc(8).flgativo := 0;
vr_tbdoc(9).cdagenci := 1;
        vr_tbdoc(9).nrcpfdeb := 0000000000;
        vr_tbdoc(9).nrdconta := 6121039;
        vr_tbdoc(9).nrctadeb := 6423361;
        vr_tbdoc(9).dtmvtolt := TO_DATE('29/06/12','DD/MM/RRRR');
        vr_tbdoc(9).cdbancod := 1;
        vr_tbdoc(9).nmclideb := 'CONSTRUTORA POLICONS LT';
        vr_tbdoc(9).valordoc := 1000;
        vr_tbdoc(9).flgativo := 0;
vr_tbdoc(10).cdagenci := 1;
        vr_tbdoc(10).nrcpfdeb := 0000000000;
        vr_tbdoc(10).nrdconta := 6121039;
        vr_tbdoc(10).nrctadeb := 6423361;
        vr_tbdoc(10).dtmvtolt := TO_DATE('13/12/12','DD/MM/RRRR');
        vr_tbdoc(10).cdbancod := 1;
        vr_tbdoc(10).nmclideb := 'CONSTRUTORA POLICONS LT';
        vr_tbdoc(10).valordoc := 1000;
        vr_tbdoc(10).flgativo := 0;
vr_tbdoc(11).cdagenci := 1;
        vr_tbdoc(11).nrcpfdeb := 0000000000;
        vr_tbdoc(11).nrdconta := 6121039;
        vr_tbdoc(11).nrctadeb := 6423361;
        vr_tbdoc(11).dtmvtolt := TO_DATE('20/12/13','DD/MM/RRRR');
        vr_tbdoc(11).cdbancod := 1;
        vr_tbdoc(11).nmclideb := 'CONSTRUTORA POLICONS LT';
        vr_tbdoc(11).valordoc := 1900;
        vr_tbdoc(11).flgativo := 0;
vr_tbdoc(12).cdagenci := 1;
        vr_tbdoc(12).nrcpfdeb := 0000000000;
        vr_tbdoc(12).nrdconta := 4043650;
        vr_tbdoc(12).nrctadeb := 130006950;
        vr_tbdoc(12).dtmvtolt := TO_DATE('10/03/16','DD/MM/RRRR');
        vr_tbdoc(12).cdbancod := 33;
        vr_tbdoc(12).nmclideb := 'ASSOCIACAO DOS FUNCIONARIOS DA UNIMED LI';
        vr_tbdoc(12).valordoc := 358.25;
        vr_tbdoc(12).flgativo := 0;
vr_tbdoc(13).cdagenci := 1;
        vr_tbdoc(13).nrcpfdeb := 0000000000;
        vr_tbdoc(13).nrdconta := 4043650;
        vr_tbdoc(13).nrctadeb := 75790;
        vr_tbdoc(13).dtmvtolt := TO_DATE('28/04/16','DD/MM/RRRR');
        vr_tbdoc(13).cdbancod := 341;
        vr_tbdoc(13).nmclideb := 'PATRICK WEEGE';
        vr_tbdoc(13).valordoc := 100;
        vr_tbdoc(13).flgativo := 0;
vr_tbdoc(14).cdagenci := 1;
        vr_tbdoc(14).nrcpfdeb := 0000000000;
        vr_tbdoc(14).nrdconta := 6121039;
        vr_tbdoc(14).nrctadeb := 99724;
        vr_tbdoc(14).dtmvtolt := TO_DATE('16/06/16','DD/MM/RRRR');
        vr_tbdoc(14).cdbancod := 1;
        vr_tbdoc(14).nmclideb := 'HR PRESTADORA DE SERVICO';
        vr_tbdoc(14).valordoc := 120;
        vr_tbdoc(14).flgativo := 0;
vr_tbdoc(15).cdagenci := 1;
        vr_tbdoc(15).nrcpfdeb := 0000000000;
        vr_tbdoc(15).nrdconta := 4043650;
        vr_tbdoc(15).nrctadeb := 212768;
        vr_tbdoc(15).dtmvtolt := TO_DATE('30/08/16','DD/MM/RRRR');
        vr_tbdoc(15).cdbancod := 1;
        vr_tbdoc(15).nmclideb := 'CASA NOSTRA HOTEL E RESTA';
        vr_tbdoc(15).valordoc := 880;
        vr_tbdoc(15).flgativo := 0;
vr_tbdoc(16).cdagenci := 1;
        vr_tbdoc(16).nrcpfdeb := 0000000000;
        vr_tbdoc(16).nrdconta := 8474540;
        vr_tbdoc(16).nrctadeb := 4502;
        vr_tbdoc(16).dtmvtolt := TO_DATE('09/08/16','DD/MM/RRRR');
        vr_tbdoc(16).cdbancod := 237;
        vr_tbdoc(16).nmclideb := 'ICATU SEGUROS S A';
        vr_tbdoc(16).valordoc := 55.58;
        vr_tbdoc(16).flgativo := 0;
vr_tbdoc(17).cdagenci := 1;
        vr_tbdoc(17).nrcpfdeb := 0000000000;
        vr_tbdoc(17).nrdconta := 8474540;
        vr_tbdoc(17).nrctadeb := 4502;
        vr_tbdoc(17).dtmvtolt := TO_DATE('06/09/16','DD/MM/RRRR');
        vr_tbdoc(17).cdbancod := 237;
        vr_tbdoc(17).nmclideb := 'ICATU SEGUROS S A';
        vr_tbdoc(17).valordoc := 108.91;
        vr_tbdoc(17).flgativo := 0;
vr_tbdoc(18).cdagenci := 1;
        vr_tbdoc(18).nrcpfdeb := 0000000000;
        vr_tbdoc(18).nrdconta := 8474540;
        vr_tbdoc(18).nrctadeb := 4502;
        vr_tbdoc(18).dtmvtolt := TO_DATE('09/11/16','DD/MM/RRRR');
        vr_tbdoc(18).cdbancod := 237;
        vr_tbdoc(18).nmclideb := 'ICATU SEGUROS S A';
        vr_tbdoc(18).valordoc := 52.58;
        vr_tbdoc(18).flgativo := 0;
vr_tbdoc(19).cdagenci := 1;
        vr_tbdoc(19).nrcpfdeb := 0000000000;
        vr_tbdoc(19).nrdconta := 8474540;
        vr_tbdoc(19).nrctadeb := 4502;
        vr_tbdoc(19).dtmvtolt := TO_DATE('07/12/16','DD/MM/RRRR');
        vr_tbdoc(19).cdbancod := 237;
        vr_tbdoc(19).nmclideb := 'ICATU SEGUROS S A';
        vr_tbdoc(19).valordoc := 51.83;
        vr_tbdoc(19).flgativo := 0;
vr_tbdoc(20).cdagenci := 1;
        vr_tbdoc(20).nrcpfdeb := 0000000000;
        vr_tbdoc(20).nrdconta := 4043650;
        vr_tbdoc(20).nrctadeb := 307777;
        vr_tbdoc(20).dtmvtolt := TO_DATE('12/01/17','DD/MM/RRRR');
        vr_tbdoc(20).cdbancod := 1;
        vr_tbdoc(20).nmclideb := 'M7 EXPOSITORES LTDA - ME';
        vr_tbdoc(20).valordoc := 1441;
        vr_tbdoc(20).flgativo := 0;
vr_tbdoc(21).cdagenci := 1;
        vr_tbdoc(21).nrcpfdeb := 0000000000;
        vr_tbdoc(21).nrdconta := 8474540;
        vr_tbdoc(21).nrctadeb := 4502;
        vr_tbdoc(21).dtmvtolt := TO_DATE('05/01/17','DD/MM/RRRR');
        vr_tbdoc(21).cdbancod := 237;
        vr_tbdoc(21).nmclideb := 'ICATU SEGUROS S A';
        vr_tbdoc(21).valordoc := 51.08;
        vr_tbdoc(21).flgativo := 0;
vr_tbdoc(22).cdagenci := 1;
        vr_tbdoc(22).nrcpfdeb := 0000000000;
        vr_tbdoc(22).nrdconta := 8474540;
        vr_tbdoc(22).nrctadeb := 4502;
        vr_tbdoc(22).dtmvtolt := TO_DATE('01/02/17','DD/MM/RRRR');
        vr_tbdoc(22).cdbancod := 237;
        vr_tbdoc(22).nmclideb := 'ICATU SEGUROS S A';
        vr_tbdoc(22).valordoc := 50.33;
        vr_tbdoc(22).flgativo := 0;
vr_tbdoc(23).cdagenci := 1;
        vr_tbdoc(23).nrcpfdeb := 0000000000;
        vr_tbdoc(23).nrdconta := 8474540;
        vr_tbdoc(23).nrctadeb := 4502;
        vr_tbdoc(23).dtmvtolt := TO_DATE('08/03/17','DD/MM/RRRR');
        vr_tbdoc(23).cdbancod := 237;
        vr_tbdoc(23).nmclideb := 'ICATU SEGUROS S A';
        vr_tbdoc(23).valordoc := 52.05;
        vr_tbdoc(23).flgativo := 0;
vr_tbdoc(24).cdagenci := 1;
        vr_tbdoc(24).nrcpfdeb := 0000000000;
        vr_tbdoc(24).nrdconta := 4043650;
        vr_tbdoc(24).nrctadeb := 287946;
        vr_tbdoc(24).dtmvtolt := TO_DATE('19/04/17','DD/MM/RRRR');
        vr_tbdoc(24).cdbancod := 341;
        vr_tbdoc(24).nmclideb := 'CLEIDI RODRIGUES FRANCA';
        vr_tbdoc(24).valordoc := 300;
        vr_tbdoc(24).flgativo := 0;
vr_tbdoc(25).cdagenci := 1;
        vr_tbdoc(25).nrcpfdeb := 0000000000;
        vr_tbdoc(25).nrdconta := 8474540;
        vr_tbdoc(25).nrctadeb := 4502;
        vr_tbdoc(25).dtmvtolt := TO_DATE('05/04/17','DD/MM/RRRR');
        vr_tbdoc(25).cdbancod := 237;
        vr_tbdoc(25).nmclideb := 'ICATU SEGUROS S A';
        vr_tbdoc(25).valordoc := 51.26;
        vr_tbdoc(25).flgativo := 0;
vr_tbdoc(26).cdagenci := 1;
        vr_tbdoc(26).nrcpfdeb := 0000000000;
        vr_tbdoc(26).nrdconta := 4043650;
        vr_tbdoc(26).nrctadeb := 75790;
        vr_tbdoc(26).dtmvtolt := TO_DATE('08/05/17','DD/MM/RRRR');
        vr_tbdoc(26).cdbancod := 341;
        vr_tbdoc(26).nmclideb := 'PATRICK WEEGE';
        vr_tbdoc(26).valordoc := 100;
        vr_tbdoc(26).flgativo := 0;
vr_tbdoc(27).cdagenci := 1;
        vr_tbdoc(27).nrcpfdeb := 0000000000;
        vr_tbdoc(27).nrdconta := 8474540;
        vr_tbdoc(27).nrctadeb := 4502;
        vr_tbdoc(27).dtmvtolt := TO_DATE('09/05/17','DD/MM/RRRR');
        vr_tbdoc(27).cdbancod := 237;
        vr_tbdoc(27).nmclideb := 'ICATU SEGUROS S A';
        vr_tbdoc(27).valordoc := 50.48;
        vr_tbdoc(27).flgativo := 0;
vr_tbdoc(28).cdagenci := 1;
        vr_tbdoc(28).nrcpfdeb := 0000000000;
        vr_tbdoc(28).nrdconta := 8474540;
        vr_tbdoc(28).nrctadeb := 4502;
        vr_tbdoc(28).dtmvtolt := TO_DATE('05/06/17','DD/MM/RRRR');
        vr_tbdoc(28).cdbancod := 237;
        vr_tbdoc(28).nmclideb := 'ICATU SEGUROS S A';
        vr_tbdoc(28).valordoc := 49.69;
        vr_tbdoc(28).flgativo := 0;
vr_tbdoc(29).cdagenci := 1;
        vr_tbdoc(29).nrcpfdeb := 0000000000;
        vr_tbdoc(29).nrdconta := 8474540;
        vr_tbdoc(29).nrctadeb := 9474;
        vr_tbdoc(29).dtmvtolt := TO_DATE('14/06/17','DD/MM/RRRR');
        vr_tbdoc(29).cdbancod := 237;
        vr_tbdoc(29).nmclideb := 'CAMVEL ADMINISTRADORA DE CONSORCIOS LTDA';
        vr_tbdoc(29).valordoc := 152.68;
        vr_tbdoc(29).flgativo := 0;
vr_tbdoc(30).cdagenci := 1;
        vr_tbdoc(30).nrcpfdeb := 0000000000;
        vr_tbdoc(30).nrdconta := 4043650;
        vr_tbdoc(30).nrctadeb := 122351;
        vr_tbdoc(30).dtmvtolt := TO_DATE('01/08/17','DD/MM/RRRR');
        vr_tbdoc(30).cdbancod := 237;
        vr_tbdoc(30).nmclideb := 'MECANICA RUCHINSKI LTDA - ME';
        vr_tbdoc(30).valordoc := 470;
        vr_tbdoc(30).flgativo := 0;
vr_tbdoc(31).cdagenci := 1;
        vr_tbdoc(31).nrcpfdeb := 0000000000;
        vr_tbdoc(31).nrdconta := 4043650;
        vr_tbdoc(31).nrctadeb := 1243438;
        vr_tbdoc(31).dtmvtolt := TO_DATE('27/11/17','DD/MM/RRRR');
        vr_tbdoc(31).cdbancod := 237;
        vr_tbdoc(31).nmclideb := 'FABIELLE CHRISTINE BARBOSA';
        vr_tbdoc(31).valordoc := 900;
        vr_tbdoc(31).flgativo := 0;
vr_tbdoc(32).cdagenci := 1;
        vr_tbdoc(32).nrcpfdeb := 0000000000;
        vr_tbdoc(32).nrdconta := 4043650;
        vr_tbdoc(32).nrctadeb := 769932;
        vr_tbdoc(32).dtmvtolt := TO_DATE('20/12/17','DD/MM/RRRR');
        vr_tbdoc(32).cdbancod := 1;
        vr_tbdoc(32).nmclideb := 'CASA NOSTRA CANTINA ITALI';
        vr_tbdoc(32).valordoc := 940;
        vr_tbdoc(32).flgativo := 0;
vr_tbdoc(33).cdagenci := 1;
        vr_tbdoc(33).nrcpfdeb := 0000000000;
        vr_tbdoc(33).nrdconta := 4043650;
        vr_tbdoc(33).nrctadeb := 74781;
        vr_tbdoc(33).dtmvtolt := TO_DATE('21/12/17','DD/MM/RRRR');
        vr_tbdoc(33).cdbancod := 341;
        vr_tbdoc(33).nmclideb := 'DANIEL DOS SANTOS';
        vr_tbdoc(33).valordoc := 1880;
        vr_tbdoc(33).flgativo := 0;
vr_tbdoc(34).cdagenci := 1;
        vr_tbdoc(34).nrcpfdeb := 0000000000;
        vr_tbdoc(34).nrdconta := 8474540;
        vr_tbdoc(34).nrctadeb := 13000328736;
        vr_tbdoc(34).dtmvtolt := TO_DATE('01/12/17','DD/MM/RRRR');
        vr_tbdoc(34).cdbancod := 104;
        vr_tbdoc(34).nmclideb := 'JEFFERSON GOLLE';
        vr_tbdoc(34).valordoc := 500;
        vr_tbdoc(34).flgativo := 0;
vr_tbdoc(35).cdagenci := 1;
        vr_tbdoc(35).nrcpfdeb := 0000000000;
        vr_tbdoc(35).nrdconta := 8474540;
        vr_tbdoc(35).nrctadeb := 1697536;
        vr_tbdoc(35).dtmvtolt := TO_DATE('15/12/17','DD/MM/RRRR');
        vr_tbdoc(35).cdbancod := 1;
        vr_tbdoc(35).nmclideb := 'ADRIANA SCHAUFFERT AMORIM';
        vr_tbdoc(35).valordoc := 500;
        vr_tbdoc(35).flgativo := 0;
vr_tbdoc(36).cdagenci := 1;
        vr_tbdoc(36).nrcpfdeb := 0000000000;
        vr_tbdoc(36).nrdconta := 4043650;
        vr_tbdoc(36).nrctadeb := 940046;
        vr_tbdoc(36).dtmvtolt := TO_DATE('08/02/18','DD/MM/RRRR');
        vr_tbdoc(36).cdbancod := 237;
        vr_tbdoc(36).nmclideb := 'TERENCE SCHAUFERT REISER';
        vr_tbdoc(36).valordoc := 1060;
        vr_tbdoc(36).flgativo := 0;
vr_tbdoc(37).cdagenci := 1;
        vr_tbdoc(37).nrcpfdeb := 0000000000;
        vr_tbdoc(37).nrdconta := 4043650;
        vr_tbdoc(37).nrctadeb := 940046;
        vr_tbdoc(37).dtmvtolt := TO_DATE('09/04/18','DD/MM/RRRR');
        vr_tbdoc(37).cdbancod := 237;
        vr_tbdoc(37).nmclideb := 'TERENCE SCHAUFERT REISER';
        vr_tbdoc(37).valordoc := 1080;
        vr_tbdoc(37).flgativo := 0;
vr_tbdoc(38).cdagenci := 1;
        vr_tbdoc(38).nrcpfdeb := 0000000000;
        vr_tbdoc(38).nrdconta := 4043650;
        vr_tbdoc(38).nrctadeb := 58176;
        vr_tbdoc(38).dtmvtolt := TO_DATE('13/04/18','DD/MM/RRRR');
        vr_tbdoc(38).cdbancod := 341;
        vr_tbdoc(38).nmclideb := 'MUNDO MANIA COM UTIL LTDA ME';
        vr_tbdoc(38).valordoc := 400;
        vr_tbdoc(38).flgativo := 0;
vr_tbdoc(39).cdagenci := 1;
        vr_tbdoc(39).nrcpfdeb := 0000000000;
        vr_tbdoc(39).nrdconta := 4043650;
        vr_tbdoc(39).nrctadeb := 940046;
        vr_tbdoc(39).dtmvtolt := TO_DATE('08/05/18','DD/MM/RRRR');
        vr_tbdoc(39).cdbancod := 237;
        vr_tbdoc(39).nmclideb := 'TERENCE SCHAUFERT REISER';
        vr_tbdoc(39).valordoc := 1080;
        vr_tbdoc(39).flgativo := 0;
vr_tbdoc(40).cdagenci := 1;
        vr_tbdoc(40).nrcpfdeb := 0000000000;
        vr_tbdoc(40).nrdconta := 8474540;
        vr_tbdoc(40).nrctadeb := 2922711;
        vr_tbdoc(40).dtmvtolt := TO_DATE('07/05/18','DD/MM/RRRR');
        vr_tbdoc(40).cdbancod := 1;
        vr_tbdoc(40).nmclideb := 'PATRICIA GARCIA';
        vr_tbdoc(40).valordoc := 200;
        vr_tbdoc(40).flgativo := 0;
vr_tbdoc(41).cdagenci := 1;
        vr_tbdoc(41).nrcpfdeb := 0000000000;
        vr_tbdoc(41).nrdconta := 8474540;
        vr_tbdoc(41).nrctadeb := 143960;
        vr_tbdoc(41).dtmvtolt := TO_DATE('24/05/18','DD/MM/RRRR');
        vr_tbdoc(41).cdbancod := 237;
        vr_tbdoc(41).nmclideb := 'PORTAL BRASIL REPRESENTACOES LTDA';
        vr_tbdoc(41).valordoc := 400;
        vr_tbdoc(41).flgativo := 0;
vr_tbdoc(42).cdagenci := 1;
        vr_tbdoc(42).nrcpfdeb := 0000000000;
        vr_tbdoc(42).nrdconta := 4043650;
        vr_tbdoc(42).nrctadeb := 940046;
        vr_tbdoc(42).dtmvtolt := TO_DATE('08/06/18','DD/MM/RRRR');
        vr_tbdoc(42).cdbancod := 237;
        vr_tbdoc(42).nmclideb := 'TERENCE SCHAUFERT REISER';
        vr_tbdoc(42).valordoc := 1080;
        vr_tbdoc(42).flgativo := 0;
vr_tbdoc(43).cdagenci := 1;
        vr_tbdoc(43).nrcpfdeb := 0000000000;
        vr_tbdoc(43).nrdconta := 4043650;
        vr_tbdoc(43).nrctadeb := 75793;
        vr_tbdoc(43).dtmvtolt := TO_DATE('11/06/18','DD/MM/RRRR');
        vr_tbdoc(43).cdbancod := 341;
        vr_tbdoc(43).nmclideb := 'PATRICK WEEGE';
        vr_tbdoc(43).valordoc := 100;
        vr_tbdoc(43).flgativo := 0;
vr_tbdoc(44).cdagenci := 1;
        vr_tbdoc(44).nrcpfdeb := 0000000000;
        vr_tbdoc(44).nrdconta := 4043650;
        vr_tbdoc(44).nrctadeb := 58176;
        vr_tbdoc(44).dtmvtolt := TO_DATE('13/06/18','DD/MM/RRRR');
        vr_tbdoc(44).cdbancod := 341;
        vr_tbdoc(44).nmclideb := 'MUNDO MANIA COM UTIL LTDA ME';
        vr_tbdoc(44).valordoc := 1200;
        vr_tbdoc(44).flgativo := 0;
vr_tbdoc(45).cdagenci := 1;
        vr_tbdoc(45).nrcpfdeb := 0000000000;
        vr_tbdoc(45).nrdconta := 8474540;
        vr_tbdoc(45).nrctadeb := 1718800;
        vr_tbdoc(45).dtmvtolt := TO_DATE('15/06/18','DD/MM/RRRR');
        vr_tbdoc(45).cdbancod := 1;
        vr_tbdoc(45).nmclideb := 'AMANDIA MARIA DE BORBA';
        vr_tbdoc(45).valordoc := 954;
        vr_tbdoc(45).flgativo := 0;
vr_tbdoc(46).cdagenci := 1;
        vr_tbdoc(46).nrcpfdeb := 0000000000;
        vr_tbdoc(46).nrdconta := 4043650;
        vr_tbdoc(46).nrctadeb := 940046;
        vr_tbdoc(46).dtmvtolt := TO_DATE('09/07/18','DD/MM/RRRR');
        vr_tbdoc(46).cdbancod := 237;
        vr_tbdoc(46).nmclideb := 'TERENCE SCHAUFERT REISER';
        vr_tbdoc(46).valordoc := 1080;
        vr_tbdoc(46).flgativo := 0;
vr_tbdoc(47).cdagenci := 1;
        vr_tbdoc(47).nrcpfdeb := 0000000000;
        vr_tbdoc(47).nrdconta := 4043650;
        vr_tbdoc(47).nrctadeb := 940046;
        vr_tbdoc(47).dtmvtolt := TO_DATE('19/07/18','DD/MM/RRRR');
        vr_tbdoc(47).cdbancod := 237;
        vr_tbdoc(47).nmclideb := 'TERENCE SCHAUFERT REISER';
        vr_tbdoc(47).valordoc := 1000;
        vr_tbdoc(47).flgativo := 0;
vr_tbdoc(48).cdagenci := 1;
        vr_tbdoc(48).nrcpfdeb := 0000000000;
        vr_tbdoc(48).nrdconta := 4043650;
        vr_tbdoc(48).nrctadeb := 940046;
        vr_tbdoc(48).dtmvtolt := TO_DATE('08/08/18','DD/MM/RRRR');
        vr_tbdoc(48).cdbancod := 237;
        vr_tbdoc(48).nmclideb := 'TERENCE SCHAUFERT REISER';
        vr_tbdoc(48).valordoc := 1080;
        vr_tbdoc(48).flgativo := 0;
vr_tbdoc(49).cdagenci := 1;
        vr_tbdoc(49).nrcpfdeb := 0000000000;
        vr_tbdoc(49).nrdconta := 4043650;
        vr_tbdoc(49).nrctadeb := 2747006;
        vr_tbdoc(49).dtmvtolt := TO_DATE('07/12/18','DD/MM/RRRR');
        vr_tbdoc(49).cdbancod := 237;
        vr_tbdoc(49).nmclideb := 'GEAN CARLOS BARBOSA - ME';
        vr_tbdoc(49).valordoc := 477.77;
        vr_tbdoc(49).flgativo := 0;
vr_tbdoc(50).cdagenci := 1;
        vr_tbdoc(50).nrcpfdeb := 0000000000;
        vr_tbdoc(50).nrdconta := 4043650;
        vr_tbdoc(50).nrctadeb := 940046;
        vr_tbdoc(50).dtmvtolt := TO_DATE('08/01/19','DD/MM/RRRR');
        vr_tbdoc(50).cdbancod := 237;
        vr_tbdoc(50).nmclideb := 'TERENCE SCHAUFERT REISER';
        vr_tbdoc(50).valordoc := 1080;
        vr_tbdoc(50).flgativo := 0;
vr_tbdoc(51).cdagenci := 1;
        vr_tbdoc(51).nrcpfdeb := 0000000000;
        vr_tbdoc(51).nrdconta := 4043650;
        vr_tbdoc(51).nrctadeb := 940046;
        vr_tbdoc(51).dtmvtolt := TO_DATE('08/02/19','DD/MM/RRRR');
        vr_tbdoc(51).cdbancod := 237;
        vr_tbdoc(51).nmclideb := 'TERENCE SCHAUFERT REISER';
        vr_tbdoc(51).valordoc := 1100;
        vr_tbdoc(51).flgativo := 0;
vr_tbdoc(52).cdagenci := 1;
        vr_tbdoc(52).nrcpfdeb := 0000000000;
        vr_tbdoc(52).nrdconta := 4043650;
        vr_tbdoc(52).nrctadeb := 58176;
        vr_tbdoc(52).dtmvtolt := TO_DATE('27/02/19','DD/MM/RRRR');
        vr_tbdoc(52).cdbancod := 341;
        vr_tbdoc(52).nmclideb := 'MUNDO MANIA COM UTIL LTDA ME';
        vr_tbdoc(52).valordoc := 998;
        vr_tbdoc(52).flgativo := 0;
vr_tbdoc(53).cdagenci := 1;
        vr_tbdoc(53).nrcpfdeb := 0000000000;
        vr_tbdoc(53).nrdconta := 4043650;
        vr_tbdoc(53).nrctadeb := 2747006;
        vr_tbdoc(53).dtmvtolt := TO_DATE('08/03/19','DD/MM/RRRR');
        vr_tbdoc(53).cdbancod := 237;
        vr_tbdoc(53).nmclideb := 'GEAN CARLOS BARBOSA - ME';
        vr_tbdoc(53).valordoc := 500;
        vr_tbdoc(53).flgativo := 0;
vr_tbdoc(54).cdagenci := 1;
        vr_tbdoc(54).nrcpfdeb := 0000000000;
        vr_tbdoc(54).nrdconta := 4043650;
        vr_tbdoc(54).nrctadeb := 940046;
        vr_tbdoc(54).dtmvtolt := TO_DATE('08/03/19','DD/MM/RRRR');
        vr_tbdoc(54).cdbancod := 237;
        vr_tbdoc(54).nmclideb := 'TERENCE SCHAUFERT REISER';
        vr_tbdoc(54).valordoc := 1100;
        vr_tbdoc(54).flgativo := 0;
vr_tbdoc(55).cdagenci := 1;
        vr_tbdoc(55).nrcpfdeb := 0000000000;
        vr_tbdoc(55).nrdconta := 4043650;
        vr_tbdoc(55).nrctadeb := 13000086463;
        vr_tbdoc(55).dtmvtolt := TO_DATE('22/03/19','DD/MM/RRRR');
        vr_tbdoc(55).cdbancod := 104;
        vr_tbdoc(55).nmclideb := 'JULIANO PEREIRA ROSA';
        vr_tbdoc(55).valordoc := 150;
        vr_tbdoc(55).flgativo := 0;
vr_tbdoc(56).cdagenci := 1;
        vr_tbdoc(56).nrcpfdeb := 0000000000;
        vr_tbdoc(56).nrdconta := 8474540;
        vr_tbdoc(56).nrctadeb := 143960;
        vr_tbdoc(56).dtmvtolt := TO_DATE('15/03/19','DD/MM/RRRR');
        vr_tbdoc(56).cdbancod := 237;
        vr_tbdoc(56).nmclideb := 'PORTAL BRASIL REPRESENTACOES LTDA';
        vr_tbdoc(56).valordoc := 500;
        vr_tbdoc(56).flgativo := 0;
vr_tbdoc(57).cdagenci := 1;
        vr_tbdoc(57).nrcpfdeb := 0000000000;
        vr_tbdoc(57).nrdconta := 4043650;
        vr_tbdoc(57).nrctadeb := 75793;
        vr_tbdoc(57).dtmvtolt := TO_DATE('05/04/19','DD/MM/RRRR');
        vr_tbdoc(57).cdbancod := 341;
        vr_tbdoc(57).nmclideb := 'PATRICK WEEGE';
        vr_tbdoc(57).valordoc := 100;
        vr_tbdoc(57).flgativo := 0;
vr_tbdoc(58).cdagenci := 1;
        vr_tbdoc(58).nrcpfdeb := 0000000000;
        vr_tbdoc(58).nrdconta := 4043650;
        vr_tbdoc(58).nrctadeb := 940046;
        vr_tbdoc(58).dtmvtolt := TO_DATE('08/04/19','DD/MM/RRRR');
        vr_tbdoc(58).cdbancod := 237;
        vr_tbdoc(58).nmclideb := 'TERENCE SCHAUFERT REISER';
        vr_tbdoc(58).valordoc := 1100;
        vr_tbdoc(58).flgativo := 0;
vr_tbdoc(59).cdagenci := 1;
        vr_tbdoc(59).nrcpfdeb := 0000000000;
        vr_tbdoc(59).nrdconta := 4043650;
        vr_tbdoc(59).nrctadeb := 2747006;
        vr_tbdoc(59).dtmvtolt := TO_DATE('08/04/19','DD/MM/RRRR');
        vr_tbdoc(59).cdbancod := 237;
        vr_tbdoc(59).nmclideb := 'GEAN CARLOS BARBOSA - ME';
        vr_tbdoc(59).valordoc := 500;
        vr_tbdoc(59).flgativo := 0;

/*
        vr_tbdoc(1).cdagenci := 1;                                           
        vr_tbdoc(1).nrcpfdeb := 01894432000156;
        vr_tbdoc(1).nrdconta := 6474586;
        vr_tbdoc(1).nrctadeb := 130011858;
        vr_tbdoc(1).dtmvtolt := TO_DATE('07/05/2013','DD/MM/RRRR');
        vr_tbdoc(1).cdbancod := 33;
        vr_tbdoc(1).nmclideb := 'ASSOCIACAO EDUCACIONAL LEONARDO DA VINCI';
        vr_tbdoc(1).valordoc := 80.27;
        vr_tbdoc(1).flgativo := 0;

        vr_tbdoc(1).cdagenci := 1;
        vr_tbdoc(1).nrcpfdeb := 19277670000188;
        vr_tbdoc(1).nrdconta := 120693;
        vr_tbdoc(1).nrctadeb := 3000023570;
        vr_tbdoc(1).dtmvtolt := TO_DATE('29/09/16','DD/MM/RRRR');
        vr_tbdoc(1).cdbancod := 104;
        vr_tbdoc(1).nmclideb := 'MAO SANTA';
        vr_tbdoc(1).valordoc := 4999.99;
        vr_tbdoc(1).flgativo := 0;
        
        vr_tbdoc(2).cdagenci := 1;
        vr_tbdoc(2).nrcpfdeb := 19277670000188;
        vr_tbdoc(2).nrdconta := 120693;
        vr_tbdoc(2).nrctadeb := 3000023570;
        vr_tbdoc(2).dtmvtolt := TO_DATE('29/09/16','DD/MM/RRRR');
        vr_tbdoc(2).cdbancod := 104;
        vr_tbdoc(2).nmclideb := 'MAO SANTA';
        vr_tbdoc(2).valordoc := 2020;
        vr_tbdoc(2).flgativo := 0;
        
        vr_tbdoc(3).cdagenci := 1;
        vr_tbdoc(3).nrcpfdeb := 15686065000100;
        vr_tbdoc(3).nrdconta := 120693;
        vr_tbdoc(3).nrctadeb := 3000024058;
        vr_tbdoc(3).dtmvtolt := TO_DATE('03/10/16','DD/MM/RRRR');
        vr_tbdoc(3).cdbancod := 104;
        vr_tbdoc(3).nmclideb := 'EMENGE CONTR E EMPR IMOB LTDA';
        vr_tbdoc(3).valordoc := 4654;
        vr_tbdoc(3).flgativo := 0;
*/
        -- Percorrer todas as movimentaçoes da conta
        FOR rw_lancamento IN cr_lancamentos (pr_cdcooper     => rw_conta.cdcooper
                                            ,pr_nrdconta     => rw_conta.nrdconta
                                            ,pr_dtmvtolt_ini => pr_dtini_quebra
                                            ,pr_dtmvtolt_fim => pr_dtfim_quebra) LOOP
          -- Identificamos se o historico do lancamento esta mapeado
          IF NOT pr_tbhistorico.EXISTS(rw_lancamento.cdhistor) THEN
            -- Gerar critica de historico nao mapeado
            vr_idx_err := pr_tberro.COUNT + 1;
            pr_tberro(vr_idx_err).dsorigem := 'EXTRATO';
            pr_tberro(vr_idx_err).dserro   := 'Historico nao mapeado: ' ||
                                              rw_lancamento.cdhistor    || '(' ||
                                              rw_lancamento.indebcre    || ') - ' ||
                                              rw_lancamento.dshistor;
            -- Vamos para o proximo lancamento
            CONTINUE;
          END IF;
          
          vr_nrsequen := 0;
          -- Calcular o valor do saldo do cooperado
          IF rw_lancamento.indebcre = 'C' THEN
            vr_vldsaldo := vr_vldsaldo + rw_lancamento.vllanmto;
          ELSE
            vr_vldsaldo := vr_vldsaldo - rw_lancamento.vllanmto;
          END IF;
          
          -- Verificar se o saldo esta negativo
          IF vr_vldsaldo < 0 THEN
            -- Deixar valor positivo para escrever no arquivo
            vr_vlrsaldo := vr_vldsaldo * -1;
          ELSE
            vr_vlrsaldo := vr_vldsaldo;
          END IF;
          
          -- Tipo do Lancamento, mapeado para o historico
          vr_tplancto := pr_tbhistorico(rw_lancamento.cdhistor);

          -- Debito de CHEQUE 
          IF rw_lancamento.cdhistor = 21 THEN -- Deb. CHEQUE
            vr_registro := FALSE;
            -- Montar o numero do documento
            vr_nrdocmto := SUBSTR(to_char(rw_lancamento.nrdocmto),1,( LENGTH(to_char(rw_lancamento.nrdocmto)) - 1 ));
            vr_inpessoa := '';
            vr_nrcpfcgc := '';
            vr_nmprimtl := '';

            -- Buscar os dados do cheque
            OPEN cr_cheque (pr_cdcooper => rw_lancamento.cdcooper 
                           ,pr_nrdconta => rw_lancamento.nrdconta
                           ,pr_nrcheque => vr_nrdocmto);
            FETCH cr_cheque INTO rw_cheque;
            IF cr_cheque%FOUND THEN
              -- Se for cheque da Cooperativa
              IF rw_cheque.cdbandep = 85 THEN 
                -- Buscar a conta de quem depositou o cheque
                OPEN cr_conta_aux (pr_cdagectl => rw_cheque.cdagedep
                                  ,pr_nrdconta => rw_cheque.nrctadep);
                FETCH cr_conta_aux INTO rw_conta_aux;
                IF cr_conta_aux%FOUND THEN
                  vr_inpessoa := rw_conta_aux.inpessoa;
                  vr_nrcpfcgc := rw_conta_aux.nrcpfcgc;
                  vr_nmprimtl := rw_conta_aux.nmprimtl;
                END IF;
                -- Fechar Cursor
                CLOSE cr_conta_aux;
              END IF;
              
              -- Atualizar os sequenciais 
              vr_nrsequen := vr_nrsequen + 1;
              vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
              pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_cheque.cdbandep;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_cheque.cdagedep;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_cheque.nrctadep;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
              pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
              IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
              ELSE 
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
              END IF;

              vr_registro := TRUE;
               
            END IF; -- Encontrou cheque
            -- Fechar Cursor
            CLOSE cr_cheque;
            
            IF vr_registro THEN
              CONTINUE;
            END IF;
          END IF;-- Historico 21

/*          IF rw_lancamento.cdhistor = 266 THEN -- Credito Cobranca 
            vr_registro := FALSE;*/
/*            vr_anteutil := rw_lancamento.dtmvtolt - 1;
            vr_anteutil := gene0005.fn_valida_dia_util(pr_cdcooper => rw_lancamento.cdcooper
                                                      ,pr_dtmvtolt => vr_anteutil
                                                      ,pr_tipo     => 'A');
*/
/*            vr_vldpagto := 0;

            -- Buscar os dados do boleto que esta sendo pago
            OPEN cr_cobranca (pr_cdcooper => rw_lancamento.cdcooper 
                             ,pr_nrdconta => rw_lancamento.nrdconta
                             ,pr_nrdocmto => rw_lancamento.nrdocmto);
            FETCH cr_cobranca INTO rw_cobranca;

            -- Encontrou boleto ?
            IF cr_cobranca%FOUND THEN
              vr_vldpagto := vr_vldpagto + rw_cobranca.vldpagto;
              vr_inpessoa := '';
              vr_nrcpfcgc := '';
              vr_nmprimtl := '';
              -- Busca dados do pagador
              IF rw_cobranca.nrinssac > 0 THEN
                -- Buscar Pagador
            
                OPEN cr_sacado (pr_cdcooper => rw_lancamento.cdcooper 
                                 ,pr_nrdconta => rw_lancamento.nrdconta
                                 ,pr_nrdocmto => rw_cobranca.nrinssac);
                FETCH cr_sacado INTO rw_sacado;
                                
                IF cr_sacado%FOUND THEN
                  vr_inpessoa := rw_sacado.cdtpinsc;
                  vr_nrcpfcgc := rw_sacado.nrinssac;
                  vr_nmprimtl := rw_sacado.nmdsacad;
                END IF;
                -- Fechar cursor
                CLOSE cr_sacado;
              END IF;-- Dados do pagador
                
              -- Atualizar os sequenciais
              vr_nrsequen := vr_nrsequen + 1;
              vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
              pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_cobranca.vldpagto * 100);
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := rw_cobranca.nrdocmto;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_cobranca.cdbanpag;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_cobranca.cdagepag;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
              pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
                
              vr_registro := TRUE;
            END IF;
            -- Fechar Cursor
            CLOSE cr_cobranca;                    

            -- Se encontrou o boleto vai para o proximo lancamento
            IF vr_registro THEN
              CONTINUE;
            END IF;
*/


/* chw            
            
            -- Buscar os dados do boleto que esta sendo pago
            OPEN cr_boleto (pr_cdcooper => rw_lancamento.cdcooper 
                           ,pr_nrdconta => rw_lancamento.nrdconta
                           ,pr_dtdpagto => vr_anteutil
                           ,pr_nrdocmto => rw_lancamento.nrdocmto);
            FETCH cr_boleto INTO rw_boleto;
            -- Encontrou boleto ?
            IF cr_boleto%FOUND THEN
              vr_vldpagto := vr_vldpagto + rw_boleto.vldpagto;
              vr_inpessoa := '';
              vr_nrcpfcgc := '';
              vr_nmprimtl := '';
              -- Busca dados do pagador
              IF rw_boleto.nrinssac > 0 THEN
                -- Buscar Pagador
                OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                ,pr_nrdconta => rw_lancamento.nrdconta
                                ,pr_nrinssac => rw_boleto.nrinssac);
                FETCH cr_pagador INTO rw_pagador;
                IF cr_pagador%FOUND THEN
                  vr_inpessoa := rw_pagador.cdtpinsc;
                  vr_nrcpfcgc := rw_pagador.nrinssac;
                  vr_nmprimtl := rw_pagador.nmdsacad;
                END IF;
                -- Fechar cursor
                CLOSE cr_pagador;
              END IF;-- Dados do pagador
                
              -- Atualizar os sequenciais
              vr_nrsequen := vr_nrsequen + 1;
              vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
              pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_boleto.vldpagto * 100);
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := rw_boleto.nrdocmto;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_boleto.cdbanpag;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_boleto.cdagepag;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
              pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
                
              vr_registro := TRUE;
            END IF;
            -- Fechar Cursor
            CLOSE cr_boleto;
            
            -- Se encontrou o boleto vai para o proximo lancamento
            IF vr_registro THEN
              CONTINUE;
            END IF;
            
            vr_vldpagto := 0;
            -- Buscar os dados do boleto que esta sendo pago
            OPEN cr_boleto (pr_cdcooper => rw_lancamento.cdcooper 
                           ,pr_nrdconta => rw_lancamento.nrdconta
                           ,pr_dtdpagto => rw_lancamento.dtmvtolt
                           ,pr_nrdocmto => rw_lancamento.nrdocmto);
            FETCH cr_boleto INTO rw_boleto;
            -- Encontrou boleto ?
            IF cr_boleto%FOUND THEN
              vr_vldpagto := vr_vldpagto + rw_boleto.vldpagto;
              vr_inpessoa := '';
              vr_nrcpfcgc := '';
              vr_nmprimtl := '';
              
              -- Busca dados do pagador
              IF rw_boleto.nrinssac > 0 THEN
                -- Buscar Pagador
                OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                ,pr_nrdconta => rw_lancamento.nrdconta
                                ,pr_nrinssac => rw_boleto.nrinssac);
                FETCH cr_pagador INTO rw_pagador;
                IF cr_pagador%FOUND THEN
                  vr_inpessoa := rw_pagador.cdtpinsc;
                  vr_nrcpfcgc := rw_pagador.nrinssac;
                  vr_nmprimtl := rw_pagador.nmdsacad;
                END IF;
                -- Fechar cursor
                CLOSE cr_pagador;
              END IF;-- Dados do pagador
        
              -- Atualizar os sequenciais
              vr_nrsequen := vr_nrsequen + 1;
              vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
              pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_boleto.vldpagto * 100);
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := rw_boleto.nrdocmto;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_boleto.cdbanpag;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_boleto.cdagepag;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
              pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';        
              
              vr_registro := TRUE;
            END IF;
            
            -- Fechar cursor
            CLOSE cr_boleto;
chw */

/*
            IF vr_vldpagto <> rw_lancamento.vllanmto  THEN
              vr_idx_err := pr_tberro.COUNT + 1;
              pr_tberro(vr_idx_err).dsorigem := 'ORIGEM DESTINO - LOOP';
              pr_tberro(vr_idx_err).dserro   := '1 - ' ||
                                                'Data: ' || rw_lancamento.dtmvtolt || '  ' || 
                                                'Valor Calculado: ' || vr_vldpagto || '  ' || 
                                                'Valor Lancamento: ' || rw_lancamento.vllanmto || '  ' || 
                                                'Documento: ' || rw_lancamento.nrdocmto || '  ' || 
                                                'ID: ' || rw_lancamento.progress_recid;
            END IF;
            
            IF vr_registro THEN
              CONTINUE;
            END IF;
          END IF; -- Historico 266 
*/
          IF rw_lancamento.cdhistor = 971 THEN -- Credito Cobranca 
            -- Abrir cursor da crapret 
            FOR rw_crapret IN cr_crapret_971(pr_cdcooper => rw_lancamento.cdcooper 
                                            ,pr_nrdconta => rw_lancamento.nrdconta
                                            ,pr_dtcredit => rw_lancamento.dtmvtolt) LOOP
              
              vr_vldpagto := 0;
              -- Buscar os dados do boleto que esta sendo pago
              OPEN cr_boleto (pr_cdcooper => rw_crapret.cdcooper 
                             ,pr_nrdconta => rw_crapret.nrdconta
                             ,pr_dtdpagto => rw_crapret.dtocorre
                             ,pr_nrdocmto => rw_crapret.nrdocmto);
              FETCH cr_boleto INTO rw_boleto;
              vr_found_boleto := cr_boleto%FOUND;
              CLOSE cr_boleto;

              -- Se não encontrou o boleto com a data de pagamento, vamos buscar pelo número
              IF NOT vr_found_boleto THEN
                -- Buscar os dados do boleto que esta sendo pago
                OPEN cr_boleto_2 (pr_cdcooper => rw_crapret.cdcooper 
                                 ,pr_nrdconta => rw_crapret.nrdconta
                                 ,pr_nrcnvcob => rw_crapret.nrcnvcob
                                 ,pr_nrdocmto => rw_crapret.nrdocmto);
                FETCH cr_boleto_2 INTO rw_boleto;
                vr_found_boleto := cr_boleto_2%FOUND;
                CLOSE cr_boleto_2;
              END IF;
                
              -- Encontrou boleto ?
              IF vr_found_boleto THEN
                vr_vldpagto := vr_vldpagto + rw_boleto.vldpagto;
                vr_inpessoa := '';
                vr_nrcpfcgc := '';
                vr_nmprimtl := '';
                
                -- Busca dados do pagador
                IF rw_boleto.nrinssac > 0 THEN
                  -- Buscar Pagador
                  OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                  ,pr_nrdconta => rw_lancamento.nrdconta
                                  ,pr_nrinssac => rw_boleto.nrinssac);
                  FETCH cr_pagador INTO rw_pagador;
                  IF cr_pagador%FOUND THEN
                    vr_inpessoa := rw_pagador.cdtpinsc;
                    vr_nrcpfcgc := rw_pagador.nrinssac;
                    vr_nmprimtl := rw_pagador.nmdsacad;
                  END IF;
                  -- Fechar cursor
                  CLOSE cr_pagador;
                END IF;-- Dados do pagador
          
                -- Atualizar os sequenciais
                vr_nrsequen := vr_nrsequen + 1;
                vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;
 
                pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
                pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
                pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_boleto.vldpagto * 100);
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := rw_boleto.nrdocmto;
                pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_boleto.cdbanpag;
                pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_boleto.cdagepag;
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
                pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
                pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
                pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';        
              END IF;
              
            END LOOP;
            CONTINUE;
          END IF; -- Historico 971


          IF rw_lancamento.cdhistor = 977 THEN -- Credito Cobranca 
            
            -- data padrão para pesquisa
            vr_dt_pesquisa_ret := rw_lancamento.dtmvtolt;
          
            -- DATAS QUE DEREM PROBLEMA NO CREDITO DE COBRANCA
            IF rw_lancamento.cdcooper = 1                                  AND 
               rw_lancamento.nrdconta = 2028085                            AND
               rw_lancamento.dtmvtolt = to_date('20/01/2016','dd/mm/rrrr') AND 
               rw_lancamento.vllanmto = 773.06                             THEN
              -- Foi lançado no dia anterior
              vr_dt_pesquisa_ret := to_date('19/01/2016','dd/mm/rrrr');
            END IF;

            -- DATAS QUE DEREM PROBLEMA NO CREDITO DE COBRANCA
            IF rw_lancamento.cdcooper = 1                                  AND 
               rw_lancamento.nrdconta = 2028085                            AND
               rw_lancamento.dtmvtolt = to_date('19/02/2015','dd/mm/rrrr') AND 
               rw_lancamento.vllanmto = 737.35                             THEN
              -- Foi lançado no dia anterior
              vr_dt_pesquisa_ret := to_date('18/02/2015','dd/mm/rrrr');
            END IF;
            
            -- DATAS QUE DEREM PROBLEMA NO CREDITO DE COBRANCA
            IF rw_lancamento.cdcooper = 1                                  AND 
               rw_lancamento.nrdconta = 2028085                            AND
               rw_lancamento.dtmvtolt = to_date('24/02/2016','dd/mm/rrrr') AND 
               rw_lancamento.vllanmto = 169.91                             THEN
              -- Foi lançado no dia anterior
              vr_dt_pesquisa_ret := to_date('23/02/2016','dd/mm/rrrr');
            END IF;

            -- Abrir cursor da crapret 
            FOR rw_crapret IN cr_crapret_977(pr_cdcooper => rw_lancamento.cdcooper 
                                            ,pr_nrdconta => rw_lancamento.nrdconta
                                            ,pr_dtcredit => vr_dt_pesquisa_ret) LOOP
              
              vr_vldpagto := 0;
              -- Buscar os dados do boleto que esta sendo pago
              OPEN cr_boleto (pr_cdcooper => rw_crapret.cdcooper 
                             ,pr_nrdconta => rw_crapret.nrdconta
                             ,pr_dtdpagto => rw_crapret.dtocorre
                             ,pr_nrdocmto => rw_crapret.nrdocmto);
              FETCH cr_boleto INTO rw_boleto;
              vr_found_boleto := cr_boleto%FOUND;
              CLOSE cr_boleto;

              -- Se não encontrou o boleto com a data de pagamento, vamos buscar pelo número
              IF NOT vr_found_boleto THEN
                -- Buscar os dados do boleto que esta sendo pago
                OPEN cr_boleto_2 (pr_cdcooper => rw_crapret.cdcooper 
                                 ,pr_nrdconta => rw_crapret.nrdconta
                                 ,pr_nrcnvcob => rw_crapret.nrcnvcob
                                 ,pr_nrdocmto => rw_crapret.nrdocmto);
                FETCH cr_boleto_2 INTO rw_boleto;
                vr_found_boleto := cr_boleto_2%FOUND;
                CLOSE cr_boleto_2;
              END IF;
                
              -- Encontrou boleto ?
              IF vr_found_boleto THEN
                vr_vldpagto := vr_vldpagto + rw_boleto.vldpagto;
                vr_inpessoa := '';
                vr_nrcpfcgc := '';
                vr_nmprimtl := '';
                
                -- Busca dados do pagador
                IF rw_boleto.nrinssac > 0 THEN
                  -- Buscar Pagador
                  OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                  ,pr_nrdconta => rw_lancamento.nrdconta
                                  ,pr_nrinssac => rw_boleto.nrinssac);
                  FETCH cr_pagador INTO rw_pagador;
                  IF cr_pagador%FOUND THEN
                    vr_inpessoa := rw_pagador.cdtpinsc;
                    vr_nrcpfcgc := rw_pagador.nrinssac;
                    vr_nmprimtl := rw_pagador.nmdsacad;
                  END IF;
                  -- Fechar cursor
                  CLOSE cr_pagador;
                END IF;-- Dados do pagador
          
                -- Atualizar os sequenciais
                vr_nrsequen := vr_nrsequen + 1;
                vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

                pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
                pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
                pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_boleto.vldpagto * 100);
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := rw_boleto.nrdocmto;
                pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_boleto.cdbanpag;
                pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_boleto.cdagepag;
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
                pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
                pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
                pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';        
              END IF;
              
            END LOOP;
            CONTINUE;
          END IF; -- Historico 977

          IF rw_lancamento.cdhistor = 987 THEN -- Credito Cobranca 
            -- Abrir cursor da crapret 
            FOR rw_crapret IN cr_crapret_987(pr_cdcooper => rw_lancamento.cdcooper 
                                            ,pr_nrdconta => rw_lancamento.nrdconta
                                            ,pr_dtcredit => rw_lancamento.dtmvtolt) LOOP
              
              vr_vldpagto := 0;
              -- Buscar os dados do boleto que esta sendo pago
              OPEN cr_boleto (pr_cdcooper => rw_crapret.cdcooper 
                             ,pr_nrdconta => rw_crapret.nrdconta
                             ,pr_dtdpagto => rw_crapret.dtocorre
                             ,pr_nrdocmto => rw_crapret.nrdocmto);
              FETCH cr_boleto INTO rw_boleto;
              vr_found_boleto := cr_boleto%FOUND;
              CLOSE cr_boleto;

              -- Se não encontrou o boleto com a data de pagamento, vamos buscar pelo número
              IF NOT vr_found_boleto THEN
                -- Buscar os dados do boleto que esta sendo pago
                OPEN cr_boleto_2 (pr_cdcooper => rw_crapret.cdcooper 
                                 ,pr_nrdconta => rw_crapret.nrdconta
                                 ,pr_nrcnvcob => rw_crapret.nrcnvcob
                                 ,pr_nrdocmto => rw_crapret.nrdocmto);
                FETCH cr_boleto_2 INTO rw_boleto;
                vr_found_boleto := cr_boleto_2%FOUND;
                CLOSE cr_boleto_2;
              END IF;

              -- Encontrou boleto ?
              IF vr_found_boleto THEN
                vr_vldpagto := vr_vldpagto + rw_boleto.vldpagto;
                vr_inpessoa := '';
                vr_nrcpfcgc := '';
                vr_nmprimtl := '';
                
                -- Busca dados do pagador
                IF rw_boleto.nrinssac > 0 THEN
                  -- Buscar Pagador
                  OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                  ,pr_nrdconta => rw_lancamento.nrdconta
                                  ,pr_nrinssac => rw_boleto.nrinssac);
                  FETCH cr_pagador INTO rw_pagador;
                  IF cr_pagador%FOUND THEN
                    vr_inpessoa := rw_pagador.cdtpinsc;
                    vr_nrcpfcgc := rw_pagador.nrinssac;
                    vr_nmprimtl := rw_pagador.nmdsacad;
                  END IF;
                  -- Fechar cursor
                  CLOSE cr_pagador;
                END IF;-- Dados do pagador
          
                -- Atualizar os sequenciais
                vr_nrsequen := vr_nrsequen + 1;
                vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

                pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
                pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
                pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_boleto.vldpagto * 100);
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := rw_boleto.nrdocmto;
                pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_boleto.cdbanpag;
                pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_boleto.cdagepag;
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
                pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
                pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
                pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';        
              END IF;
              
            END LOOP;
            CONTINUE;
          END IF; -- Historico 987

          IF rw_lancamento.cdhistor = 1089 THEN -- Credito Cobranca 
            
            -- Abrir cursor da crapret 
            FOR rw_crapret IN cr_crapret_1089(pr_cdcooper => rw_lancamento.cdcooper 
                                             ,pr_nrdconta => rw_lancamento.nrdconta
                                             ,pr_dtcredit => rw_lancamento.dtmvtolt
                                             ,pr_vltitulo => rw_lancamento.vllanmto) LOOP
                                             
              vr_vldpagto := 0;
              -- Buscar os dados do boleto que esta sendo pago
              OPEN cr_boleto (pr_cdcooper => rw_crapret.cdcooper 
                             ,pr_nrdconta => rw_crapret.nrdconta
                             ,pr_dtdpagto => rw_crapret.dtocorre
                             ,pr_nrdocmto => rw_crapret.nrdocmto);
              FETCH cr_boleto INTO rw_boleto;
              vr_found_boleto := cr_boleto%FOUND;
              CLOSE cr_boleto;

              -- Se não encontrou o boleto com a data de pagamento, vamos buscar pelo número
              IF NOT vr_found_boleto THEN
                -- Buscar os dados do boleto que esta sendo pago
                OPEN cr_boleto_2 (pr_cdcooper => rw_crapret.cdcooper 
                                 ,pr_nrdconta => rw_crapret.nrdconta
                                 ,pr_nrcnvcob => rw_crapret.nrcnvcob
                                 ,pr_nrdocmto => rw_crapret.nrdocmto);
                FETCH cr_boleto_2 INTO rw_boleto;
                vr_found_boleto := cr_boleto_2%FOUND;
                CLOSE cr_boleto_2;
              END IF;

              -- Encontrou boleto ?
              IF vr_found_boleto THEN

                vr_vldpagto := vr_vldpagto + rw_boleto.vldpagto;
                vr_inpessoa := '';
                vr_nrcpfcgc := '';
                vr_nmprimtl := '';
                
                -- Busca dados do pagador
                IF rw_boleto.nrinssac > 0 THEN
                  -- Buscar Pagador
                  OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                  ,pr_nrdconta => rw_lancamento.nrdconta
                                  ,pr_nrinssac => rw_boleto.nrinssac);
                  FETCH cr_pagador INTO rw_pagador;
                  IF cr_pagador%FOUND THEN
                    vr_inpessoa := rw_pagador.cdtpinsc;
                    vr_nrcpfcgc := rw_pagador.nrinssac;
                    vr_nmprimtl := rw_pagador.nmdsacad;
                  END IF;
                  -- Fechar cursor
                  CLOSE cr_pagador;
                END IF;-- Dados do pagador
          
                -- Atualizar os sequenciais
                vr_nrsequen := vr_nrsequen + 1;
                vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

                pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
                pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
                pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_boleto.vldpagto * 100);
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := rw_boleto.nrdocmto;
                pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_boleto.cdbanpag;
                pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_boleto.cdagepag;
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
                pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
                pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
                pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
                pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';        
              END IF;
              
            END LOOP;

            CONTINUE;
          END IF; -- Historico 1089




          IF rw_lancamento.cdhistor = 654 THEN -- Credito de Cobrança
            vr_registro := FALSE;
            vr_vldpagto := 0;
            
            -- Buscar os dados do boleto que esta sendo pago
            OPEN cr_boleto (pr_cdcooper => rw_lancamento.cdcooper 
                           ,pr_nrdconta => rw_lancamento.nrdconta
                           ,pr_dtdpagto => rw_lancamento.dtmvtolt
                           ,pr_nrdocmto => to_number(SUBSTR(to_char(rw_lancamento.nrdocmto),5,6)));
            FETCH cr_boleto INTO rw_boleto;
            -- Encontrou boleto ?
            IF cr_boleto%FOUND THEN
              vr_vldpagto := vr_vldpagto + rw_boleto.vldpagto;
              vr_inpessoa := '';
              vr_nrcpfcgc := '';
              vr_nmprimtl := '';
              -- Busca dados do pagador
              IF rw_boleto.nrinssac > 0 THEN
                -- Buscar Pagador
                OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                ,pr_nrdconta => rw_lancamento.nrdconta
                                ,pr_nrinssac => rw_boleto.nrinssac);
                FETCH cr_pagador INTO rw_pagador;
                IF cr_pagador%FOUND THEN
                  vr_inpessoa := rw_pagador.cdtpinsc;
                  vr_nrcpfcgc := rw_pagador.nrinssac;
                  vr_nmprimtl := rw_pagador.nmdsacad;
                END IF;
                -- Fechar cursor
                CLOSE cr_pagador;
              END IF;-- Dados do pagador
            
              -- Atualizar os sequenciais
              vr_nrsequen := vr_nrsequen + 1;
              vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
              pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_boleto.vldpagto * 100);
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := rw_boleto.nrdocmto;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_boleto.cdbanpag;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_boleto.cdagepag;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
              pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';        
              
              vr_registro := TRUE;
            END IF;
            -- Fechar cursor
            CLOSE cr_boleto;
            
            IF vr_vldpagto <> rw_lancamento.vllanmto  THEN
              vr_idx_err := pr_tberro.COUNT + 1;
              pr_tberro(vr_idx_err).dsorigem := 'ORIGEM DESTINO - LOOP';
              pr_tberro(vr_idx_err).dserro   := '2 - ' ||
                                                'Data: ' || rw_lancamento.dtmvtolt || '  ' || 
                                                'Valor Calculado: ' || vr_vldpagto || '  ' || 
                                                'Valor Lancamento: ' || rw_lancamento.vllanmto || '  ' || 
                                                'Documento: ' || rw_lancamento.nrdocmto || '  ' || 
                                                'ID: ' || rw_lancamento.progress_recid;
            END IF;
            
            IF vr_registro THEN
              CONTINUE;
            END IF;
            
          END IF; -- Historico 654
           
          IF rw_lancamento.cdhistor = 881 THEN -- Deb. Bloq. de Cheque em Custodia
            vr_registro := FALSE;
            --
            FOR rw_custodia_cheque IN cr_custodia_cheque (pr_cdcooper => rw_lancamento.cdcooper 
                                                         ,pr_nrdconta => rw_lancamento.nrdconta
                                                         ,pr_nrdocmto => rw_lancamento.nrdocmto) LOOP
              
            vr_inpessoa := '';
            vr_nrcpfcgc := '';
            vr_nmprimtl := '';
            
							IF rw_custodia_cheque.cdbanchq = 85 THEN
								OPEN  cr_cooperativa(pr_cdagectl => rw_custodia_cheque.cdagechq);
								FETCH cr_cooperativa INTO rw_cooperativa;
								--
								IF cr_cooperativa%FOUND THEN
									OPEN  cr_cooperado(pr_cdcooper => rw_cooperativa.cdcooper
																		,pr_nrdconta => rw_custodia_cheque.nrctachq);
									FETCH cr_cooperado INTO rw_cooperado;
									IF cr_cooperado%FOUND THEN
										vr_nrcpfcgc := rw_cooperado.nrcpfcgc;
										vr_nmprimtl := rw_cooperado.nmprimtl;
									END IF;
									CLOSE cr_cooperado;
								END IF;
								--
								CLOSE cr_cooperativa;								
							ELSE							
								
			  OPEN  cr_crapicf (pr_cdcooper => rw_conta.cdcooper
                         ,pr_dacaojud => Upper(vr_dacaojud)
                         ,pr_nrctareq => rw_custodia_cheque.nrctachq
                         ,pr_cdbanreq => rw_custodia_cheque.cdbanchq
                         ,pr_cdagereq => rw_custodia_cheque.cdagechq );
			  FETCH cr_crapicf INTO rw_crapicf;
			  -- Verificar se não encontra a informação na tabela CRAPICF.
			  IF cr_crapicf%NOTFOUND THEN
				BEGIN
  				  INSERT INTO crapicf
					  (cdcooper
					  ,nrctaori
					  ,cdbanori
					  ,cdbanreq
					  ,cdagereq
					  ,nrctareq
					  ,intipreq
					  ,dacaojud
					  ,dtmvtolt
					  ,dtinireq
					  ,cdoperad
					  ,dsdocmc7
					  ,dtdopera
					  ,vldopera
					  ,tpctapes)
				  VALUES
					  (rw_conta.cdcooper
					  ,rw_conta.nrdconta
					  ,85
					  ,rw_custodia_cheque.cdbanchq
					  ,rw_custodia_cheque.cdagechq
					  ,rw_custodia_cheque.nrctachq
					  ,1
					  ,UPPER(vr_dacaojud)
					  ,TRUNC(SYSDATE)
					  ,TRUNC(SYSDATE)
					  ,'1'
					  ,rw_custodia_cheque.dsdocmc7
					  ,rw_lancamento.dtmvtolt
											,rw_custodia_cheque.vlcheque
					  ,'01');
				  --
										vr_idx_cheques_icfjud := pr_tbarq_cheques_icfjud.COUNT + 1;
										--
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).dtinireq := TRUNC(SYSDATE);              
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).cdbanreq := rw_custodia_cheque.cdbanchq; 
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).cdagereq := rw_custodia_cheque.cdagechq; 
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).nrctareq := rw_custodia_cheque.nrctachq; 
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).intipreq := 1;                           
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).dsdocmc7 := rw_custodia_cheque.dsdocmc7;							
										
				EXCEPTION
				  WHEN OTHERS THEN
					  vr_idx_err := pr_tberro.COUNT + 1;
					  pr_tberro(vr_idx_err).dsorigem := 'ORIGEM DESTINO Historico - 881 - LOOP';
					  pr_tberro(vr_idx_err).dserro   := '3 - Erro ao tentar inserir na tabela CRAPICF. ' ||
														'Data: ' || rw_lancamento.dtmvtolt || '  ' || 
																												'Valor Cheque: ' || rw_custodia_cheque.vlcheque || '  ' || 
														'Documento: ' || rw_lancamento.nrdocmto || '  ' || 
																												'ID: ' || rw_lancamento.progress_recid ||  '  ' || 
																					              'Erro: '|| SQLERRM;
																												
				END;
			  ELSE
				vr_nrcpfcgc := rw_crapicf.nrcpfcgc;
				vr_nmprimtl := rw_crapicf.nmprimtl;
			  END IF;
			  --
			  CLOSE cr_crapicf;
							END IF;
              
              -- Atualizar os sequenciais
              vr_nrsequen := vr_nrsequen + 1;
              vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
              pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_custodia_cheque.vlcheque * 100);
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := rw_custodia_cheque.nrdocmto;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_custodia_cheque.cdbanchq;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_custodia_cheque.cdagechq;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_custodia_cheque.nrctachq;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
              pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';        
            
              vr_registro := TRUE;
            END LOOP;
            
            IF vr_registro THEN
              CONTINUE;
            END IF;
          END IF; -- Historico 881

          IF rw_lancamento.cdhistor = 386 THEN -- Deb. CHEQUE Propria Cooperativa
            vr_registro := FALSE;
            -- Gerar o numero do documento
            vr_nrdocmto := to_number( SUBSTR(to_char(rw_lancamento.nrdocmto),1,( LENGTH(to_char(rw_lancamento.nrdocmto)) - 3 )) || '022' );
            -- Buscar os dados do cheque
            OPEN cr_cheque_085 (pr_cdcooper => rw_lancamento.cdcooper 
                               ,pr_nrdconta => rw_lancamento.nrdconta
                               ,pr_nrdocmto => vr_nrdocmto);
            FETCH cr_cheque_085 INTO rw_cheque_085;
            -- Encontrou o cheque ?
            IF cr_cheque_085%FOUND THEN
              vr_inpessoa := '';
              vr_nrcpfcgc := '';
              vr_nmprimtl := '';
              vr_cdagenci := '';

              -- Buscar a conta de quem depositou o cheque
              OPEN cr_conta_aux (pr_cdagectl => rw_cheque_085.cdagechq
                                ,pr_nrdconta => rw_cheque_085.nrctachq);
              FETCH cr_conta_aux INTO rw_conta_aux;
              IF cr_conta_aux%FOUND THEN
                vr_inpessoa := rw_conta_aux.inpessoa;
                vr_nrcpfcgc := rw_conta_aux.nrcpfcgc;
                vr_nmprimtl := rw_conta_aux.nmprimtl;
                vr_cdagenci := rw_conta_aux.cdagenci;
              END IF;
              -- Fechar Cursor
              CLOSE cr_conta_aux;

              -- Atualizar os sequenciais
              vr_nrsequen := vr_nrsequen + 1;
              vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
              pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := '085';
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := vr_cdagenci;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_cheque_085.nrctachq;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
              pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
              IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
              ELSE 
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
              END IF;
              
              vr_registro := TRUE;
            END IF;
            -- Fechar cursor
            CLOSE cr_cheque_085;
            
            IF vr_registro THEN
              CONTINUE;
            END IF;
          END IF; -- Historico 386

          IF rw_lancamento.cdhistor IN (537, 538, 539) THEN -- Credito de Transferencia Via Internet
            vr_nrdconta := to_number( SUBSTR(rw_lancamento.cdpesqbb,45,8));
            vr_inpessoa := '';
            vr_nrcpfcgc := '';
            vr_nmprimtl := '';
            vr_cdagenci := '';
            
            -- Buscar os dados da conta que fez a transferencia
            OPEN cr_conta_aux2 (pr_cdcooper => rw_lancamento.cdcooper
                               ,pr_nrdconta => vr_nrdconta);
            FETCH cr_conta_aux2 INTO rw_conta_aux2;
            -- Encontrou a conta?
            IF cr_conta_aux2%FOUND THEN
              vr_inpessoa := rw_conta_aux2.inpessoa;
              vr_nrcpfcgc := rw_conta_aux2.nrcpfcgc;
              vr_nmprimtl := rw_conta_aux2.nmprimtl;
              vr_cdagenci := rw_conta_aux2.cdagenci;
            END IF;
            -- Fechar Cursor
            CLOSE cr_conta_aux2;
            
            -- Atualizar os sequenciais
            vr_nrsequen := vr_nrsequen + 1;
            vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
            pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := '085';
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := vr_cdagenci;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_lancamento.nrdconta;
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '4'; -- Outros
            pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
            pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
            IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
            ELSE 
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
            END IF;
            
            CONTINUE;
          END IF; -- Historicos 537, 538, 539
          
          IF rw_lancamento.cdhistor IN (1009, 1014, 1011, 1015) THEN -- Transferencia Intercooperativa
            vr_nrdconta := rw_lancamento.nrdctabb;
            vr_inpessoa := '';
            vr_nrcpfcgc := '';
            vr_nmprimtl := '';
            vr_cdagenci := '';
            
            -- Buscar os dados da conta que fez a transferencia
            OPEN cr_conta_aux2 (pr_cdcooper => rw_lancamento.cdcoptfn
                               ,pr_nrdconta => vr_nrdconta);
            FETCH cr_conta_aux2 INTO rw_conta_aux2;
            -- Encontrou a conta?
            IF cr_conta_aux2%FOUND THEN
              vr_inpessoa := rw_conta_aux2.inpessoa;
              vr_nrcpfcgc := rw_conta_aux2.nrcpfcgc;
              vr_nmprimtl := rw_conta_aux2.nmprimtl;
              vr_cdagenci := rw_conta_aux2.cdagenci;
            END IF;
            -- Fechar Cursor
            CLOSE cr_conta_aux2;
            
            -- Atualizar os sequenciais
            vr_nrsequen := vr_nrsequen + 1;
            vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
            pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := '085';
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := vr_cdagenci;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_lancamento.nrdconta;
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
            pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
            IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
            ELSE 
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
            END IF;
            
            CONTINUE;
          END IF; -- Historicos 1009, 1014, 1011, 1015

          IF rw_lancamento.cdhistor IN (302, 771, 303) THEN -- Transferencia Cooperativa
            
            IF rw_lancamento.cdhistor = 771 THEN
              vr_nrdconta := to_number(SUBSTR(rw_lancamento.cdpesqbb,45,8));
            ELSE
              vr_nrdconta := rw_lancamento.cdpesqbb;
            END IF;

            vr_inpessoa := '';
            vr_nrcpfcgc := '';
            vr_nmprimtl := '';
            vr_cdagenci := '';
            
            -- Buscar os dados da conta que fez a transferencia
            OPEN cr_conta_aux2 (pr_cdcooper => rw_lancamento.cdcooper
                               ,pr_nrdconta => vr_nrdconta);
            FETCH cr_conta_aux2 INTO rw_conta_aux2;
            -- Encontrou a conta?
            IF cr_conta_aux2%FOUND THEN
              vr_inpessoa := rw_conta_aux2.inpessoa;
              vr_nrcpfcgc := rw_conta_aux2.nrcpfcgc;
              vr_nmprimtl := rw_conta_aux2.nmprimtl;
              vr_cdagenci := rw_conta_aux2.cdagenci;
            END IF;
            -- Fechar Cursor
            CLOSE cr_conta_aux2;
            
            -- Atualizar os sequenciais
            vr_nrsequen := vr_nrsequen + 1;
            vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
            pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := '085';
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := vr_cdagenci;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_lancamento.nrdconta;
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
            pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
            IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
            ELSE 
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
            END IF;
            
            CONTINUE;
          END IF; -- Historicos 302, 771, 303
          
          IF rw_lancamento.cdhistor IN (3, 4, 372) THEN -- Deb. CHEQUE Praca e Fora Praca 
            vr_registro := FALSE;
            FOR rw_all_cheques IN cr_all_cheques(pr_cdcooper => rw_lancamento.cdcooper
                                                ,pr_nrdconta => rw_lancamento.nrdconta
                                                ,pr_nrdocmto => rw_lancamento.nrdocmto) LOOP
              vr_inpessoa := '';
              vr_nrcpfcgc := '';
              vr_nmprimtl := '';
			  
							-- cdbanchq=85 o Banco do Cheque é da AILOS
							IF rw_all_cheques.cdbanchq = 85 THEN
								OPEN  cr_cooperativa(pr_cdagectl => rw_all_cheques.cdagechq);
								FETCH cr_cooperativa INTO rw_cooperativa;
				--
								IF cr_cooperativa%FOUND THEN
									OPEN  cr_cooperado(pr_cdcooper => rw_cooperativa.cdcooper
									  ,pr_nrdconta => rw_all_cheques.nrctachq);
					FETCH cr_cooperado INTO rw_cooperado;
					IF cr_cooperado%FOUND THEN
										vr_nrcpfcgc := rw_cooperado.nrcpfcgc;
										vr_nmprimtl := rw_cooperado.nmprimtl;
					END IF;
					CLOSE cr_cooperado;
				END IF;
				--
								CLOSE cr_cooperativa;
              ELSE

								OPEN  cr_crapicf (pr_cdcooper => rw_conta.cdcooper
																 ,pr_dacaojud => Upper(vr_dacaojud)
																 ,pr_nrctareq => rw_all_cheques.nrctachq
																 ,pr_cdbanreq => rw_all_cheques.cdbanchq
																 ,pr_cdagereq => rw_all_cheques.cdagechq );
								FETCH cr_crapicf INTO rw_crapicf;
								-- Verificar se não encontra a informação na tabela CRAPICF.
								IF cr_crapicf%NOTFOUND THEN																
				BEGIN
					INSERT INTO crapicf
						(cdcooper
						,nrctaori
						,cdbanori
						,cdbanreq
						,cdagereq
						,nrctareq
						,intipreq
						,dacaojud
						,dtmvtolt
						,dtinireq
						,cdoperad
						,dsdocmc7
											,dtdopera
											,vldopera
						,tpctapes)
					VALUES
						(rw_conta.cdcooper
						,rw_conta.nrdconta
						,85
						,rw_all_cheques.cdbanchq
						,rw_all_cheques.cdagechq
						,rw_all_cheques.nrctachq
						,1
						,UPPER(vr_dacaojud)
						,TRUNC(SYSDATE)
						,TRUNC(SYSDATE)
						,'1'
						,rw_all_cheques.dsdocmc7
											,rw_lancamento.dtmvtolt
											,rw_all_cheques.vlcheque
						,'01');
				--
										vr_idx_cheques_icfjud := pr_tbarq_cheques_icfjud.COUNT + 1;
										--								
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).dtinireq := TRUNC(SYSDATE);          
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).cdbanreq := rw_all_cheques.cdbanchq;
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).cdagereq := rw_all_cheques.cdagechq;
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).nrctareq := rw_all_cheques.nrctachq;
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).intipreq := 1;                      
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).dsdocmc7 := rw_all_cheques.dsdocmc7;									
				EXCEPTION
					WHEN OTHERS THEN
						vr_idx_err := pr_tberro.COUNT + 1;
						pr_tberro(vr_idx_err).dsorigem := 'ORIGEM DESTINO Historico 372 - LOOP';
						pr_tberro(vr_idx_err).dserro   := '3 - Erro ao tentar inserir na tabela CRAPICF. ' ||
													      'Data: ' || rw_lancamento.dtmvtolt || '  ' || 
																					'Valor Cheque: ' || rw_all_cheques.vlcheque || '  ' || 
														  'Documento: ' || rw_lancamento.nrdocmto || '  ' || 
																					'ID: ' || rw_lancamento.progress_recid || '  ' || 
																					'Erro: '|| SQLERRM;
				END;
								ELSE
									vr_nrcpfcgc := rw_crapicf.nrcpfcgc;
									vr_nmprimtl := rw_crapicf.nmprimtl;									
			  END IF;
								-- Fechar cursor
								CLOSE cr_crapicf;
							END IF;
			  --
              -- Atualizar os sequenciais
              vr_nrsequen := vr_nrsequen + 1;
              vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;
              --

              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
              pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_all_cheques.vlcheque * 100);
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_all_cheques.cdbanchq;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_all_cheques.cdagechq;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_all_cheques.nrctachq;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
              pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
              IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
              ELSE 
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
              END IF;
              
              vr_registro := TRUE;
            END LOOP;

            IF vr_registro THEN
              CONTINUE;
            END IF;
          END IF; -- Historicos 3, 4, 372                                

          IF rw_lancamento.cdhistor = 889 THEN -- Folha de Pagemnto
            vr_registro := FALSE;
            -- Valor inicial = FOLHA VELHA não encontrada
            vr_encontrou_folha_velha := FALSE;
            
            -- Buscar o código da empresa, para identificar os dados da folha de pagamentos
            OPEN cr_empresa(pr_cdcooper => rw_lancamento.cdcooper 
                           ,pr_nrdconta => rw_lancamento.nrdconta);
            FETCH cr_empresa INTO rw_empresa;
            -- Verifica se encontrou a empresa
            IF cr_empresa%FOUND THEN
              -- Fecha cursor
              CLOSE cr_empresa;
              
              -- Buscar o lote da empresa
              vr_lote_empres := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_lancamento.cdcooper 
                                                          ,pr_nmsistem => 'CRED'
                                                          ,pr_tptabela => 'GENERI'
                                                          ,pr_cdempres => 0
                                                          ,pr_cdacesso => 'NUMLOTEFOL'
                                                          ,pr_tpregist => rw_empresa.cdempres) ;

              -- Antes dessa data o lote era incrementado em 1                                            
              IF rw_lancamento.dtmvtolt < to_date('10/12/2015','dd/mm/yyyy') THEN
                vr_lote_empres := vr_lote_empres + 1;
              END IF;
              
              -- Verificar o valor total da folha velha
              OPEN cr_total_folha_velha(pr_cdcooper => rw_lancamento.cdcooper 
                                       ,pr_nrdolote => vr_lote_empres
                                       ,pr_cdempres => rw_empresa.cdempres
                                       ,pr_dtmvtolt => rw_lancamento.dtmvtolt);
              FETCH cr_total_folha_velha INTO rw_total_folha_velha;
              -- Encontrou a folha ?
              IF cr_total_folha_velha%FOUND THEN
                -- Fecha cursor
                CLOSE cr_total_folha_velha;
                  
                -- Verificar se o valor da Folha que foi paga é igual ao lançamento
                IF rw_total_folha_velha.total = rw_lancamento.vllanmto THEN
                  -- Encontrou o valor correspondente na FOLHA VELHA
                  vr_encontrou_folha_velha := TRUE;

                  -- Se for igual, vamos enviar os lançamentos individuais
                  -- Caso conta não seja o mesmo valor, será enviado de forma consolidada
                    
                  -- Percorrer todos os lançamentos da folha de pagamento CRAPLCM e CRAPLCS
                  FOR rw_lancto_folha_velha IN cr_lancto_folha_velha(pr_cdcooper => rw_lancamento.cdcooper 
                                                                    ,pr_nrdolote => vr_lote_empres
                                                                    ,pr_cdempres => rw_empresa.cdempres
                                                                    ,pr_dtmvtolt => rw_lancamento.dtmvtolt) LOOP
                    -- Inicializar variaveis
                    vr_inpessoa := '';
                    vr_nrcpfcgc := '';
                    vr_nmprimtl := '';
                    vr_cdagenci := '';
                    vr_cdbandep := '';
                    vr_nrctadep := 0;
                          
                    -- Verificar se o tipo de lançamento eh "C" - Conta Corrente
                    IF rw_lancto_folha_velha.idtpcont = 'C' THEN
                      -- Buscar os dados da conta que fez a transferencia
                      OPEN cr_conta_aux2 (pr_cdcooper => rw_lancto_folha_velha.cdcooper
                                         ,pr_nrdconta => rw_lancto_folha_velha.nrdconta);
                      FETCH cr_conta_aux2 INTO rw_conta_aux2;
                      -- Encontrou a conta?
                      IF cr_conta_aux2%FOUND THEN
                        vr_inpessoa := rw_conta_aux2.inpessoa;
                        vr_nrcpfcgc := rw_conta_aux2.nrcpfcgc;
                        vr_nmprimtl := rw_conta_aux2.nmprimtl;
                        vr_cdagenci := rw_conta_aux2.cdagenci;
                        vr_cdbandep := '085';
                        vr_nrctadep := rw_lancto_folha_velha.nrdconta;
                      END IF;
                      -- Fechar Cursor
                      CLOSE cr_conta_aux2;

                    -- Verificar se o tipo de lançamento eh "T" - Transferencia Conta Salário
                    ELSIF rw_lancto_folha_velha.idtpcont = 'T' THEN
                      -- Buscar os dados da conta salario
                      OPEN cr_conta_salario (pr_cdcooper => rw_lancto_folha_velha.cdcooper
                                            ,pr_nrdconta => rw_lancto_folha_velha.nrdconta);
                      FETCH cr_conta_salario INTO rw_conta_salario;
                      -- Encontrou a conta?
                      IF cr_conta_salario%FOUND THEN
                        vr_inpessoa := '1'; -- Pessoa Fisica
                        vr_nrcpfcgc := rw_conta_salario.nrcpfcgc;
                        vr_nmprimtl := rw_conta_salario.nmfuncio;
                        vr_cdagenci := rw_conta_salario.cdagetrf;
                        vr_cdbandep := rw_conta_salario.cdbantrf;
                        vr_nrctadep := rw_conta_salario.nrctatrf;
                      END IF;
                      -- Fechar Cursor
                      CLOSE cr_conta_salario;
                        
                    END IF;
                      
                    -- Atualizar os sequenciais
                    vr_nrsequen := vr_nrsequen + 1;
                    vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;
         
                    pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
                    pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
                    pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancto_folha_velha.vllanmto * 100);
                    pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := vr_cdbandep;
                    pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := vr_cdagenci;
                    pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := vr_nrctadep;
                    pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
                    pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
                    pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
                    pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
                    pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
                    pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
                    pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
                    pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
                    pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
                    pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
                    pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
                    IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                      pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                    ELSE 
                      pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
                    END IF;

                    vr_registro := TRUE;
                  END LOOP; -- LOOP Folha nova
                END IF; -- Total da folha velha
                
              ELSE
                -- Fecha cursor
                CLOSE cr_total_folha_velha;
              END IF; -- Encontrou total folha velha ?
            
              -- Se encontrou a folha de pagamento velha, não pesquisa a folha de pagamento nova
              IF NOT vr_encontrou_folha_velha THEN
                -- Verificar o valor total da folha nova
                OPEN cr_total_folha_nova(pr_cdcooper => rw_lancamento.cdcooper
                                        ,pr_nrdconta => rw_lancamento.nrdconta
                                        ,pr_dtmvtolt => rw_lancamento.dtmvtolt);
                FETCH cr_total_folha_nova INTO rw_total_folha_nova;
                IF cr_total_folha_nova%FOUND THEN
                  -- Fecha cursor
                  CLOSE cr_total_folha_nova;
                  
                  -- Verificar se o valor da Folha que foi paga é igual ao lançamento
                  IF rw_total_folha_nova.vllctpag = rw_lancamento.vllanmto THEN
                    -- Se for igual, vamos enviar os lançamentos individuais
                    -- Caso conta não seja o mesmo valor, será enviado de forma consolidada
                    
                    -- Percorrer todos os lançamentos da folha de pagamento CRAPLPF - Lançamento de FOLHA
                    FOR rw_lancto_folha_nova IN cr_lancto_folha_nova(pr_cdcooper => rw_lancamento.cdcooper
                                                                    ,pr_nrdconta => rw_lancamento.nrdconta
                                                                    ,pr_dtmvtolt => rw_lancamento.dtmvtolt) LOOP
                      -- Inicializar variaveis
                      vr_inpessoa := '';
                      vr_nrcpfcgc := '';
                      vr_nmprimtl := '';
                      vr_cdagenci := '';
                      vr_cdbandep := '';
                      vr_nrctadep := 0;
                          
                      -- Verificar se o tipo de lançamento eh "C" - Conta Corrente
                      IF rw_lancto_folha_nova.idtpcont = 'C' THEN
                        -- Buscar os dados da conta que fez a transferencia
                        OPEN cr_conta_aux2 (pr_cdcooper => rw_lancto_folha_nova.cdcooper
                                           ,pr_nrdconta => rw_lancto_folha_nova.nrdconta);
                        FETCH cr_conta_aux2 INTO rw_conta_aux2;
                        -- Encontrou a conta?
                        IF cr_conta_aux2%FOUND THEN
                          vr_inpessoa := rw_conta_aux2.inpessoa;
                          vr_nrcpfcgc := rw_conta_aux2.nrcpfcgc;
                          vr_nmprimtl := rw_conta_aux2.nmprimtl;
                          vr_cdagenci := rw_conta_aux2.cdagenci;
                          vr_cdbandep := '085';
                          vr_nrctadep := rw_lancto_folha_nova.nrdconta;
                        END IF;
                        -- Fechar Cursor
                        CLOSE cr_conta_aux2;

                      -- Verificar se o tipo de lançamento eh "T" - Transferencia Conta Salário
                      ELSIF rw_lancto_folha_nova.idtpcont = 'T' THEN
                        -- Buscar os dados da conta salario
                        OPEN cr_conta_salario (pr_cdcooper => rw_lancto_folha_nova.cdcooper
                                              ,pr_nrdconta => rw_lancto_folha_nova.nrdconta);
                        FETCH cr_conta_salario INTO rw_conta_salario;
                        -- Encontrou a conta?
                        IF cr_conta_salario%FOUND THEN
                          vr_inpessoa := '1'; -- Pessoa Fisica
                          vr_nrcpfcgc := rw_conta_salario.nrcpfcgc;
                          vr_nmprimtl := rw_conta_salario.nmfuncio;
                          vr_cdagenci := rw_conta_salario.cdagetrf;
                          vr_cdbandep := rw_conta_salario.cdbantrf;
                          vr_nrctadep := rw_conta_salario.nrctatrf;
                        END IF;
                        -- Fechar Cursor
                        CLOSE cr_conta_salario;
                        
                      END IF;
                      
                      -- Atualizar os sequenciais
                      vr_nrsequen := vr_nrsequen + 1;
                      vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

                      pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
                      pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
                      pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancto_folha_nova.vllancto * 100);
                      pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := vr_cdbandep;
                      pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := vr_cdagenci;
                      pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := vr_nrctadep;
                      pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
                      pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
                      pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
                      pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
                      pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
                      pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
                      pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
                      pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
                      pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
                      pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
                      pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
                      IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                        pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                      ELSE 
                        pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
                      END IF;

                      vr_registro := TRUE;
                    END LOOP; -- LOOP Folha nova
                    
                  END IF; -- Valor total da folha de pagamento nova
                
                ELSE 
                  -- Fecha cursor
                  CLOSE cr_total_folha_nova;
                  
                END IF; -- Encontrou total folha nova ? 
                
              END IF; -- Encontrou folha velha ? 
            
            END IF; -- Encontrou cadastro da EMPRESA
                
            IF vr_registro THEN
              CONTINUE;
            END IF;
          END IF; -- Historico 889

          IF rw_lancamento.cdhistor = 578 THEN -- Credito TED
            vr_registro := FALSE;
            -- Verificar se existem TEDs Carregadas
            IF  vr_tbted.COUNT > 0 THEN
              -- Percorrer todas as TEDs
              FOR x IN vr_tbted.FIRST..vr_tbted.LAST LOOP
                -- Identificar a TED por DATA e VALOR - ainda não utilizada ?
                IF vr_tbted(x).datadted = rw_lancamento.dtmvtolt AND 
                   vr_tbted(x).valorted = rw_lancamento.vllanmto AND 
                   vr_tbted(x).regativo = 0 THEN
                  -- Alterar o Status para Utilizado
                  vr_tbted(x).regativo := 1;

                  -- Atualizar os sequenciais
                  vr_nrsequen := vr_nrsequen + 1;
                  vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

                  pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
                  pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
                  pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
                  pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := vr_tbted(x).cdbancod;
                  pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
                  pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := '';
                  pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_tbted(x).nrcpfdeb;
                  pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_tbted(x).nmclideb;
                  pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
                  pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
                  pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
                  pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
                  pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
                  pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
                  pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
                  IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                    pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                  ELSE 
                    pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
                  END IF;
                  
                  -- Verificar se a Conta do Depositante existe
                  IF vr_tbted(x).contadeb > 0 THEN
                    -- Se a conta existir mandamos os dados do Depositante
                    pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := vr_tbted(x).agenciad;
                    pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := vr_tbted(x).contadeb;
                  ELSE
                    -- Caso o depositante/favorecido não possua conta no banco, 
                    -- os campos AGENCIA, CONTA e OBSERVACAO devem possuir, respectivamente, os seguintes valores: 
                    --              9999, 99999999999999999999 e NAO­CORRENTISTA 
                    pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := 9999;
                    pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := 99999999999999999999;
                    pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := 'NAO­CORRENTISTA';
                  END IF;
                  
                  vr_registro := TRUE;
                  -- Se encontrou a TED, para o LOOP
                  EXIT; 
                END IF; -- Encontrou uma TED para listar
              END LOOP; -- LOOP das TEDs
            END IF; -- Existem TEDs carregadas ?
            
            IF vr_registro THEN
              CONTINUE;
            END IF;  
          END IF;-- Historico 578
          
          IF rw_lancamento.cdhistor IN (548,575) THEN -- Credito DOC
            vr_registro := TRUE;
            -- Existem DOCs carregadas ?
            IF vr_tbdoc.COUNT > 0 THEN
              -- Percorrer todas as DOCs 
              FOR x IN vr_tbdoc.FIRST..vr_tbdoc.LAST LOOP
                -- Identificar a TED por DATA e VALOR - ainda não utilizada ?
                IF vr_tbdoc(x).dtmvtolt = rw_lancamento.dtmvtolt AND 
                   vr_tbdoc(x).valordoc = rw_lancamento.vllanmto AND 
                   vr_tbdoc(x).nrdconta = rw_lancamento.nrdconta AND 
                   vr_tbdoc(x).flgativo = 0 THEN
                  -- Alterar o Status para Utilizado
                  vr_tbdoc(x).flgativo := 1;
              
                  -- Atualizar os sequenciais
                  vr_nrsequen := vr_nrsequen + 1;
                  vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

                  pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
                  pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
                  pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
                  pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := vr_tbdoc(x).cdbancod;
                  pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := vr_tbdoc(x).cdagenci;
                  pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := vr_tbdoc(x).nrctadeb;
                  pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
                  pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := '';
                  pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_tbdoc(x).nrcpfdeb;
                  pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_tbdoc(x).nmclideb;
                  pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
                  pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
                  pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
                  pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
                  pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
                  pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
                  pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
                  IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                    pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                  ELSE 
                    pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
                  END IF;

                  vr_registro := TRUE;
                  
                  -- Se encontrou a DOC, para o LOOP
                  EXIT; 
                END IF; -- Encontrou uma DOC para listar
              END LOOP; -- LOOP das DOCs
            END IF; -- Existem DOCs carregadas ?
            
            IF vr_registro THEN
              CONTINUE;
            END IF;
          END IF; -- Historico 548,575

          IF rw_lancamento.cdhistor = 521 THEN -- Acerto Cheque Extra Caixa
            vr_registro := FALSE;
            -- Montar o numero do documento
            vr_nrdocmto := SUBSTR(to_char(rw_lancamento.nrdocmto), 1, (LENGTH(to_char(rw_lancamento.nrdocmto)) - 1 ));
            -- Buscar os dados do cheque
            OPEN cr_cheque (pr_cdcooper => rw_lancamento.cdcooper 
                           ,pr_nrdconta => rw_lancamento.nrdconta
                           ,pr_nrcheque => vr_nrdocmto);
            FETCH cr_cheque INTO rw_cheque;
            IF cr_cheque%FOUND THEN
              vr_inpessoa := '';
              vr_nrcpfcgc := '';
              vr_nmprimtl := '';
              vr_cdagenci := '';
              -- Buscar a conta de quem depositou o cheque
              OPEN cr_conta_aux (pr_cdagectl => rw_cheque.cdagedep
                                ,pr_nrdconta => rw_cheque.nrctachq);
              FETCH cr_conta_aux INTO rw_conta_aux;
              IF cr_conta_aux%FOUND THEN
                vr_inpessoa := rw_conta_aux.inpessoa;
                vr_nrcpfcgc := rw_conta_aux.nrcpfcgc;
                vr_nmprimtl := rw_conta_aux.nmprimtl;
                vr_cdagenci := rw_conta_aux.cdagenci;
              END IF;
              -- Fechar Cursor
              CLOSE cr_conta_aux;
              
              -- Atualizar os sequenciais 
              vr_nrsequen := vr_nrsequen + 1;
              vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
              pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := '085';
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := vr_cdagenci;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_cheque.nrctachq;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
              pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
              IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
              ELSE 
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
              END IF;

              vr_registro := TRUE;
            END IF; -- Encontrou cheque
            -- Fechar Cursor
            CLOSE cr_cheque;
            
            IF vr_registro THEN
              CONTINUE;
            END IF;
          END IF; -- Historico 521

          IF rw_lancamento.cdhistor IN (503, 555) THEN --  Deb. TED 
            vr_registro := FALSE;

            -- Buscar o registro de transferencia de Valor
            OPEN cr_transf_valor (pr_cdcooper => rw_lancamento.cdcooper 
                                 ,pr_nrdconta => rw_lancamento.nrdconta
                                 ,pr_vldocrcb => rw_lancamento.vllanmto
                                 ,pr_dtmvtolt => rw_lancamento.dtmvtolt
                                 ,pr_nrdocmto => rw_lancamento.nrdocmto);
            FETCH cr_transf_valor INTO rw_transf_valor;
            -- Verificar se encontrou o registro
            IF cr_transf_valor%FOUND THEN
              
              -- Se o tamanho do documento for maior que 11 é pessoa jurídica
              IF length(rw_transf_valor.cpfcgrcb) > 11 THEN
                vr_inpessoa := '2';
              ELSE
                vr_inpessoa := '1';
              END IF;
                
              -- Atualizar os sequenciais 
              vr_nrsequen := vr_nrsequen + 1;
              vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
              pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_transf_valor.cdbccrcb;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_transf_valor.cdagercb;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_transf_valor.nrcctrcb;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '1';
              pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := rw_transf_valor.cpfcgrcb;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := rw_transf_valor.nmpesrcb;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
              pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
              IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
              ELSE 
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
              END IF;

              vr_registro := TRUE;
            ELSE
              -- Se não encontrou manda como não correntista
              vr_nrsequen := vr_nrsequen + 1;
              vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;
                      
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
              pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
              -- Caso o depositante/favorecido não possua conta no banco, 
              -- os campos AGENCIA, CONTA e OBSERVACAO devem possuir, respectivamente, os seguintes valores: 
              --              9999, 99999999999999999999 e NAO­CORRENTISTA 
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := 9999;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := 99999999999999999999;
              pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := 'NAO­CORRENTISTA';
                
              IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
              ELSE 
                pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
              END IF;

              vr_registro := TRUE;
            END IF;
              
            -- Fechar Cursor
            CLOSE cr_transf_valor;
            
            IF vr_registro THEN
              CONTINUE;
            END IF;
          END IF; -- Historicos 503, 555
          
          IF vr_tplancto IN (102, 104, 105, 106, 107, 110 ) OR
             rw_lancamento.cdhistor IN (351, 399, 47, 15, 79, 501, 530, 597, 377,
                                        613, 630, 320, 354, 658, 535, 504) THEN
            -- Atualizar os sequenciais 
            vr_nrsequen := vr_nrsequen + 1;
            vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;
              
            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
            pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := '085';
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '1';
            pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := '2'; -- Juridica
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := '82639451000138';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := rw_conta.nmextcop;
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
            pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
            IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
            ELSE 
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
            END IF;
            
            CONTINUE;
          END IF; -- Tipo Lancamento 102, 104, 105, 106, 107, 110  e Historicos 351, 399, 47, 15, 79, 501, 503, 597, 377, 613, 630, 320, 354, 658, 535, 504

          IF rw_lancamento.cdhistor IN (524, 27 ) THEN -- Cheque Compensado

            vr_nrcpfcgc := '';
            vr_nmprimtl := '';
						-- Buscar banco, agência e conta de depósito
						OPEN cr_crapfdc_524(pr_cdcooper => rw_conta.cdcooper
															 ,pr_nrdconta => rw_conta.nrdconta
															 ,pr_cdbanchq => rw_lancamento.cdbanchq
															 ,pr_cdagechq => rw_lancamento.cdagechq
															 ,pr_nrctachq => rw_lancamento.nrctachq
															 ,pr_nrcheque => to_number(substr(to_char(rw_lancamento.nrdocmto), 0, length(to_char(rw_lancamento.nrdocmto)) -1))
															 );
						FETCH cr_crapfdc_524 INTO rw_crapfdc_524;

						IF cr_crapfdc_524%FOUND THEN						
							-- cdbanchq=85 o Banco do Cheque é da AILOS
							IF rw_crapfdc_524.cdbandep = 85 THEN
								OPEN  cr_cooperativa(pr_cdagectl => rw_crapfdc_524.cdagedep);
								FETCH cr_cooperativa INTO rw_cooperativa;
				--
								IF cr_cooperativa%FOUND THEN
									OPEN  cr_cooperado(pr_cdcooper => rw_cooperativa.cdcooper
																		,pr_nrdconta => rw_crapfdc_524.nrctadep);
					FETCH cr_cooperado INTO rw_cooperado;
					IF cr_cooperado%FOUND THEN
										vr_nrcpfcgc := rw_cooperado.nrcpfcgc;
										vr_nmprimtl := rw_cooperado.nmprimtl;
					END IF;
					CLOSE cr_cooperado;
				END IF;
				--
								CLOSE cr_cooperativa;
							ELSE
								
								OPEN cr_crapicf (pr_cdcooper => rw_conta.cdcooper
																,pr_dacaojud => Upper(vr_dacaojud)
																,pr_nrctareq => rw_crapfdc_524.nrctadep
																,pr_cdbanreq => rw_crapfdc_524.cdbandep
																,pr_cdagereq => rw_crapfdc_524.cdagedep );
								FETCH cr_crapicf INTO rw_crapicf;
								-- Verificar se não encontra a informação na tabela CRAPICF.
								IF cr_crapicf%NOTFOUND THEN	
				--
				BEGIN
					INSERT INTO crapicf
						(cdcooper
						,nrctaori
						,cdbanori
						,cdbanreq
						,cdagereq
						,nrctareq
						,intipreq
						,dacaojud
						,dtmvtolt
						,dtinireq
						,cdoperad
						,dsdocmc7
											,dtdopera
											,vldopera											
						,tpctapes)
					VALUES
						(rw_conta.cdcooper
						,rw_conta.nrdconta
						,85
											,rw_crapfdc_524.cdbandep
											,rw_crapfdc_524.cdagedep
											,rw_crapfdc_524.nrctadep
						,1
						,UPPER(vr_dacaojud)
						,TRUNC(SYSDATE)
						,TRUNC(SYSDATE)
						,'1'
											,rw_crapfdc_524.dsdocmc7
											,rw_lancamento.dtmvtolt
											,rw_lancamento.vllanmto											
						,'02');
				--
										vr_idx_cheques_icfjud := pr_tbarq_cheques_icfjud.COUNT + 1;
										--								
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).dtinireq := TRUNC(SYSDATE);          
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).cdbanreq := rw_crapfdc_524.cdbandep;
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).cdagereq := rw_crapfdc_524.cdagedep;
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).nrctareq := rw_crapfdc_524.nrctadep;
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).intipreq := 1;                      
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).dsdocmc7 := rw_crapfdc_524.dsdocmc7;									
				EXCEPTION
					WHEN OTHERS THEN
						vr_idx_err := pr_tberro.COUNT + 1;
						pr_tberro(vr_idx_err).dsorigem := 'ORIGEM DESTINO Historico 524 - LOOP';
						pr_tberro(vr_idx_err).dserro   := '3 - Erro ao tentar inserir na tabela CRAPICF. ' ||
													      'Data: ' || rw_lancamento.dtmvtolt || '  ' || 
														  'Valor Lancamento: ' || rw_lancamento.vllanmto || '  ' || 
														  'Documento: ' || rw_lancamento.nrdocmto || '  ' || 
																												'ID: ' || rw_lancamento.progress_recid || '  ' || 
																					              'Erro: '|| SQLERRM;
				END;
								ELSE
									vr_nrcpfcgc := rw_crapicf.nrcpfcgc;
									vr_nmprimtl := rw_crapicf.nmprimtl;									
								END IF; -- cr_crapicf
								CLOSE cr_crapicf;
			END IF;
			--
						END IF; -- cr_crapfdc_524
						-- Fechar cursor
						CLOSE cr_crapfdc_524;
            -- Atualizar os sequenciais 
            vr_nrsequen := vr_nrsequen + 1;
            vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;
              
            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
            pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_lancamento.cdbanchq;
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_lancamento.cdagechq;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_lancamento.nrctachq;
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := '';
						pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
						pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
            pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
            IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
            ELSE 
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
            END IF;
            
            CONTINUE;
          END IF; -- Historicos 524, 27

          IF rw_lancamento.cdhistor IN (570, 22, 614, 1030, 271, 1) THEN 
            -- Atualizar os sequenciais 
            vr_nrsequen := vr_nrsequen + 1;
            vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
            pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := '085';
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_conta.cdagenci;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_conta.nrdconta;
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '1';
            pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := rw_conta.inpessoa;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := rw_conta.nrcpfcgc;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := rw_conta.nmprimtl;
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
            pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
            IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
            ELSE 
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
            END IF;

            CONTINUE;
          END IF; -- Historicos 570, 22, 614, 1030, 271, 1

          IF rw_lancamento.cdhistor IN ( 3, 4) THEN
            -- Percorrer todos os cheques na data
            FOR rw_cheque IN cr_all_cheques_data(pr_cdcooper => rw_lancamento.cdcooper
                                                ,pr_nrdconta => rw_lancamento.nrdconta
                                                ,pr_nrdocmto => rw_lancamento.nrdocmto
                                                ,pr_dtmvtolt => rw_lancamento.dtmvtolt) LOOP
              -- Atualizar os sequenciais 
              vr_nrsequen := vr_nrsequen + 1;
              vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;
                       
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
              pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_cheque.vlcheque * 100);
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := rw_cheque.nrdocmto;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_cheque.cdbanchq;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_cheque.cdagechq;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_cheque.nrctachq;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
              pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
            END LOOP; -- Loop dos cheque na data
          END IF;-- Historico 3, 4

          IF rw_lancamento.cdhistor = 270 THEN -- Cr. Descto. Chq.
            vr_registro := FALSE;
            
            -- Percorrer borderô de cheque
            FOR rw_bordero_cheque IN cr_bordero_cheque (pr_cdcooper => rw_lancamento.cdcooper
                                                       ,pr_nrdconta => rw_lancamento.nrdconta
                                                       ,pr_nrborder => rw_lancamento.nrdocmto) LOOP
              -- Atualizar os sequenciais 
              vr_nrsequen := vr_nrsequen + 1;
              vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;
                
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
              pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_bordero_cheque.vlliquid * 100);
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := rw_bordero_cheque.nrdocmto;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_bordero_cheque.cdbanchq;
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_bordero_cheque.cdagechq;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_bordero_cheque.nrctachq;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
              pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
              
              vr_registro := TRUE;
            END LOOP; -- Loop dos borderos de cheque

            IF vr_registro THEN
              CONTINUE;
            END IF;
          END IF; -- Historico 270

          IF rw_lancamento.cdhistor = 686 THEN -- Bordero de Titulo
            vr_registro := FALSE;
            vr_nrdocmto := to_number(TRIM(REPLACE(REPLACE(UPPER(rw_lancamento.cdpesqbb),'DESCONTO DO BORDERO',' '),'.', '')));
            
            -- Percorrer borderô de titulo
            FOR rw_bordero_titulo IN cr_bordero_titulo (pr_cdcooper => rw_lancamento.cdcooper
                                                       ,pr_nrdconta => rw_lancamento.nrdconta
                                                       ,pr_nrborder => vr_nrdocmto) LOOP
              -- Limpar as informações do pagador                                         
              vr_inpessoa := '';
              vr_nrcpfcgc := '';
              vr_nmprimtl := '';
              -- Buscar Pagador
              OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                              ,pr_nrdconta => rw_lancamento.nrdconta
                              ,pr_nrinssac => rw_bordero_titulo.nrinssac);
              FETCH cr_pagador INTO rw_pagador;
              IF cr_pagador%FOUND THEN
                vr_inpessoa := rw_pagador.cdtpinsc;
                vr_nrcpfcgc := rw_pagador.nrinssac;
                vr_nmprimtl := rw_pagador.nmdsacad;
              END IF;
              -- Fechar cursor
              CLOSE cr_pagador;
                                                       
              -- Atualizar os sequenciais 
              vr_nrsequen := vr_nrsequen + 1;
              vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
              pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_bordero_titulo.vlliquid * 100);
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
              pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
              
              vr_registro := TRUE;
            END LOOP; -- Loop dos borderos de cheque

            IF vr_registro THEN
              CONTINUE;
            END IF;
          END IF; -- Historico 686
          
          IF rw_lancamento.cdhistor IN (651,1875) THEN -- CRED TED BB / CR. VIA BB
            vr_registro := FALSE;
            
            OPEN cr_conta_itg(rw_lancamento.cdcooper
                             ,rw_lancamento.nrdconta);
              FETCH cr_conta_itg
                INTO rw_conta_itg;
            CLOSE cr_conta_itg;
            
            vr_nrsequen := vr_nrsequen;
            vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
            pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := '001';
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := rw_conta_itg.nrcpfcgc;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := rw_conta_itg.nmprimtl;
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
            -- Caso o depositante/favorecido não possua conta no banco, 
            -- os campos AGENCIA, CONTA e OBSERVACAO devem possuir, respectivamente, os seguintes valores: 
            --              9999, 99999999999999999999 e NAO­CORRENTISTA 
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_conta_itg.cdageitg;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_conta_itg.nrdctitg;
            pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := 'TED-INTEGRACAO';
                
            IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
            ELSE 
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
            END IF;

            vr_registro := TRUE;
            
            IF vr_registro THEN
              CONTINUE;
            END IF;
          END IF; -- Historico 651
          
          
          IF rw_lancamento.cdhistor IN (316) THEN -- SAQUE CARTAO
            vr_registro := FALSE;
            
            vr_nrsequen := vr_nrsequen;
            vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;
                      
            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
            pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
            
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := 9999;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := 99999999999999999999;
            pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := 'SAQUE-CARTAO';
                
            IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
            ELSE 
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
            END IF;

            vr_registro := TRUE;
            
            IF vr_registro THEN
              CONTINUE;
            END IF;
          END IF; -- Historico 316
                           
          IF rw_lancamento.cdhistor = 2433 THEN
            vr_registro := FALSE;
			--

            -- Buscar os dados do cheque
            FOR rw_cheque_2433 IN cr_cheque_2433 (pr_cdcooper => rw_lancamento.cdcooper 
																								 ,pr_nrdconta => rw_lancamento.nrdconta
																								 ,pr_dtmvtolt => rw_lancamento.dtmvtolt
																								 ,pr_nrdocmto => rw_lancamento.nrdocmto) LOOP
																								 
							vr_nrcpfcgc := '';
							vr_nmprimtl := '';
																								 
              -- Se o cheque for da cooperativa												
						  IF rw_cheque_2433.cdbanchq = 85 THEN
								OPEN cr_cooperativa(pr_cdagectl => rw_cheque_2433.cdagechq);
								FETCH cr_cooperativa INTO rw_cooperativa;
								-- Buscar informações do cooperado
								IF cr_cooperativa%FOUND THEN
									OPEN  cr_cooperado(pr_cdcooper => rw_cooperativa.cdcooper
																		,pr_nrdconta => rw_cheque_2433.nrctachq);
									FETCH cr_cooperado INTO rw_cooperado;
									IF cr_cooperado%FOUND THEN
										vr_nrcpfcgc := rw_cooperado.nrcpfcgc;
										vr_nmprimtl := rw_cooperado.nmprimtl;
									END IF;
									CLOSE cr_cooperado;
								END IF;
								CLOSE cr_cooperativa;
							ELSE						
			 OPEN cr_crapicf (pr_cdcooper => rw_conta.cdcooper
							 ,pr_dacaojud => Upper(vr_dacaojud)
																,pr_nrctareq => rw_cheque_2433.nrctachq
																,pr_cdbanreq => rw_cheque_2433.cdbanchq
																,pr_cdagereq => rw_cheque_2433.cdagechq );
			FETCH cr_crapicf INTO rw_crapicf;
			-- Verificar se não encontra a informação na tabela CRAPICF.
			IF cr_crapicf%NOTFOUND THEN
			  BEGIN
  				INSERT INTO crapicf
					(cdcooper
					,nrctaori
					,cdbanori
					,cdbanreq
					,cdagereq
					,nrctareq
					,intipreq
					,dacaojud
					,dtmvtolt
					,dtinireq
					,cdoperad
					,dsdocmc7
					,dtdopera
					,vldopera
					,tpctapes)
				VALUES
					(rw_conta.cdcooper
					,rw_conta.nrdconta
					,85
										,rw_cheque_2433.cdbanchq
										,rw_cheque_2433.cdagechq
										,rw_cheque_2433.nrctachq
					,1
					,UPPER(vr_dacaojud)
					,TRUNC(SYSDATE)
					,TRUNC(SYSDATE)
					,'1'
										,rw_cheque_2433.dsdocmc7
					,rw_lancamento.dtmvtolt
										,rw_cheque_2433.vlcheque
					,'01');
				--
										vr_idx_cheques_icfjud := pr_tbarq_cheques_icfjud.COUNT + 1;
										--								
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).dtinireq := TRUNC(SYSDATE);          
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).cdbanreq := rw_cheque_2433.cdbanchq;
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).cdagereq := rw_cheque_2433.cdagechq;
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).nrctareq := rw_cheque_2433.nrctachq;
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).intipreq := 1;                      
										pr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).dsdocmc7 := rw_cheque_2433.dsdocmc7;
										
			  EXCEPTION
			    WHEN OTHERS THEN
				  vr_idx_err := pr_tberro.COUNT + 1;
				  pr_tberro(vr_idx_err).dsorigem := 'ORIGEM DESTINO Historico 2433 - LOOP';
				  pr_tberro(vr_idx_err).dserro   := '3 - Erro ao tentar inserir na tabela CRAPICF. ' ||
													'Data: ' || rw_lancamento.dtmvtolt || '  ' || 
																												'Valor Cheque: ' || rw_cheque_2433.vlcheque || '  ' || 
													'Documento: ' || rw_lancamento.nrdocmto || '  ' || 
																												'ID: ' || rw_lancamento.progress_recid || '  ' || 
																					              'Erro: '|| SQLERRM;
			  END;
			ELSE
			  vr_nrcpfcgc := rw_crapicf.nrcpfcgc;
			  vr_nmprimtl := rw_crapicf.nmprimtl;
			END IF;
			--
			CLOSE cr_crapicf;
																
							END IF;
			--
            vr_nrsequen := vr_nrsequen;
            vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;
			  --
			  pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_cheque_2433.progress_recid) || to_char(vr_nrsequen);
							pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
			  pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_cheque_2433.vlcheque * 100);
			  pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := rw_cheque_2433.cdbanchq;
			  pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_cheque_2433.cdagechq;
							pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_cheque_2433.nrctachq;							
							pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
							pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := '';
							pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
							pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
							pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
							pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
							pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
							pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
							pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
							pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO            
			  --
							IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
								pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
			  ELSE 
								pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
			  END IF;
			  --
			  vr_registro := TRUE;
			  --
            END LOOP;
						
			  IF vr_registro THEN
			    CONTINUE;
			  END IF;
						
          END IF; -- Historico 2433

          IF rw_lancamento.cdhistor = 521 THEN -- Acerto Cheque Extra Caixa
            vr_registro := FALSE;
            -- Montar o numero do documento
            vr_nrdocmto := SUBSTR(to_char(rw_lancamento.nrdocmto), 1, (LENGTH(to_char(rw_lancamento.nrdocmto)) - 1 ));
            -- Buscar os dados do cheque
            OPEN cr_cheque (pr_cdcooper => rw_lancamento.cdcooper 
                           ,pr_nrdconta => rw_lancamento.nrdconta
                           ,pr_nrcheque => vr_nrdocmto);
            FETCH cr_cheque INTO rw_cheque;
            IF cr_cheque%FOUND THEN
              vr_inpessoa := '';
              vr_nrcpfcgc := '';
              vr_nmprimtl := '';
              vr_cdagenci := '';
              -- Buscar a conta de quem depositou o cheque
              OPEN cr_conta_aux (pr_cdagectl => rw_cheque.cdagedep
                                ,pr_nrdconta => rw_cheque.nrctachq);
              FETCH cr_conta_aux INTO rw_conta_aux;
              IF cr_conta_aux%FOUND THEN
                vr_inpessoa := rw_conta_aux.inpessoa;
                vr_nrcpfcgc := rw_conta_aux.nrcpfcgc;
                vr_nmprimtl := rw_conta_aux.nmprimtl;
                vr_cdagenci := rw_conta_aux.cdagenci;
              END IF;
              -- Fechar Cursor
              CLOSE cr_conta_aux;
              
              -- Atualizar os sequenciais 
              vr_nrsequen := vr_nrsequen + 1;
              vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;

              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
              pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
              pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := '085';
              pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := vr_cdagenci;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_cheque.nrctachq;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := vr_inpessoa;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := vr_nrcpfcgc;
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := vr_nmprimtl;
              pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
              pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
              pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := '';
            IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
            ELSE 
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
            END IF;

            vr_registro := TRUE;
            END IF; -- Encontrou cheque
            -- Fechar Cursor
            CLOSE cr_cheque;
            
            IF vr_registro THEN
              CONTINUE;
            END IF;
          END IF; -- Historico 521

          IF rw_lancamento.cdhistor = 362 THEN -- Informacoes da propria cooperativa, lancamentos de ajuste

            -- Atualizar os sequenciais 
            vr_nrsequen := vr_nrsequen + 1;
            vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;
                  
            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
            pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
            pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := '085';
            pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := rw_conta.cdagenci;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := rw_lancamento.nrdconta;
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '1';
            pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := '2';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := rw_conta.nrdocnpj;
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := rw_conta.nmextcop;
            pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
            pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
            pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := 'HISTORICO: ' || rw_lancamento.cdhistor;
            
            IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
            ELSE 
              pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
            END IF;
            CONTINUE;
          END IF;
            
          -- Por fim, adicionar a linha que está com a informação do lançamento no arquivo de Origem Destino
          -- Atualizar os sequenciais 
          vr_nrsequen := vr_nrsequen + 1;
          vr_idx_origem_destino := pr_tbarq_origem_destino.COUNT + 1;
                
          pr_tbarq_origem_destino(vr_idx_origem_destino).idseqarq := to_char(rw_lancamento.progress_recid) || to_char(vr_nrsequen);
          pr_tbarq_origem_destino(vr_idx_origem_destino).idseqlcm := rw_lancamento.progress_recid;
          pr_tbarq_origem_destino(vr_idx_origem_destino).vllanmto := to_char(rw_lancamento.vllanmto * 100);
          pr_tbarq_origem_destino(vr_idx_origem_destino).cdbandep := '';
          pr_tbarq_origem_destino(vr_idx_origem_destino).cdagedep := '';
          pr_tbarq_origem_destino(vr_idx_origem_destino).nrctadep := '';
          pr_tbarq_origem_destino(vr_idx_origem_destino).tpdconta := '';
          pr_tbarq_origem_destino(vr_idx_origem_destino).inpessoa := '';
          pr_tbarq_origem_destino(vr_idx_origem_destino).nrcpfcgc := '';
          pr_tbarq_origem_destino(vr_idx_origem_destino).nmprimtl := '';
          pr_tbarq_origem_destino(vr_idx_origem_destino).tpdocttl := '';
          pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocttl := '';
          pr_tbarq_origem_destino(vr_idx_origem_destino).dscodbar := '';
          pr_tbarq_origem_destino(vr_idx_origem_destino).nmendoss := '';
          pr_tbarq_origem_destino(vr_idx_origem_destino).docendos := '';
          pr_tbarq_origem_destino(vr_idx_origem_destino).idsitide := '0'; -- Fixo ZERO
          pr_tbarq_origem_destino(vr_idx_origem_destino).dsobserv := 'HISTORICO: ' || rw_lancamento.cdhistor;
          
          IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
          ELSE 
            pr_tbarq_origem_destino(vr_idx_origem_destino).nrdocmto := to_char(rw_lancamento.nrdocmto);
          END IF;

        END LOOP; -- Extrato da conta do cooperado
  
      END LOOP; --  Loop Conta Cooperado
      -- Ir para a proxima CONTA
      vr_idx_cta_investigar := pr_tbconta_investigar.NEXT(vr_idx_cta_investigar);
    END LOOP; --  Loop Contas investigadas
  
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'ORIGEM DESTINO';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_carrega_arq_origem_destino;
  -- FIM -> Carregar dados para geração
  
  -- INICIO -> Gerar os arquivos
  -- Escrever todas as informações carregadas no arquivo _AGENCIAS
  PROCEDURE pc_gera_arq_agencias(pr_nmdir_arquivo   IN VARCHAR2
                                ,pr_referencia      IN VARCHAR2
                                ,pr_tbarq_agencias  IN typ_tbarq_agencias
                                ,pr_tberro      IN OUT typ_tberro) IS
    -- Variaveis Locais
    vr_idx_err   INTEGER;
    vr_idx_pa    VARCHAR2(10);
    vr_nmarquiv  VARCHAR2(100) := pr_referencia || '_AGENCIAS.txt';
    vr_dstext_linha VARCHAR2(32000);
    vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
  BEGIN
    -- Abrir o arquivo
    pc_abre_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                   ,pr_nmarquivo  => vr_nmarquiv
                   ,pr_ind_arqlog => vr_ind_arqlog);
  
    -- Chave para percorrer todas as agencias
    vr_idx_pa:= pr_tbarq_agencias.FIRST;
    WHILE vr_idx_pa IS NOT NULL LOOP
      vr_dstext_linha := pr_tbarq_agencias(vr_idx_pa).cddbanco || chr(09) || 
                         pr_tbarq_agencias(vr_idx_pa).cdagenci || chr(09) || 
                         pr_tbarq_agencias(vr_idx_pa).nmextage || chr(09) || 
                         pr_tbarq_agencias(vr_idx_pa).dsendcop || chr(09) || 
                         pr_tbarq_agencias(vr_idx_pa).nmcidade || chr(09) || 
                         pr_tbarq_agencias(vr_idx_pa).cdufdcop || chr(09) || 
                         pr_tbarq_agencias(vr_idx_pa).nmdopais || chr(09) || 
                         pr_tbarq_agencias(vr_idx_pa).nrcepend || chr(09) || 
                         pr_tbarq_agencias(vr_idx_pa).nrtelefo || chr(09) || 
                         pr_tbarq_agencias(vr_idx_pa).dtabertu || chr(09) || 
                         pr_tbarq_agencias(vr_idx_pa).dtfecham || chr(13);
                         
      pc_escreve_linha_arq(pr_dirarquivo  => pr_nmdir_arquivo
                          ,pr_nmarquivo   => vr_nmarquiv
                          ,pr_texto_linha => vr_dstext_linha
                          ,pr_ind_arqlog  => vr_ind_arqlog);
      
      vr_idx_pa := pr_tbarq_agencias.NEXT(vr_idx_pa);
    END LOOP;
    
    -- Fechar o arquivo
    pc_fechar_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                     ,pr_nmarquivo  => vr_nmarquiv
                     ,pr_ind_arqlog => vr_ind_arqlog);
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'ARQUIVO AGENCIAS';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
    
  END pc_gera_arq_agencias;
  
  -- Escrever todas as informações carregadas no arquivo _CONTAS
  PROCEDURE pc_gera_arq_contas(pr_nmdir_arquivo IN VARCHAR2
                              ,pr_referencia    IN VARCHAR2
                              ,pr_tbarq_contas  IN typ_tbarq_contas
                              ,pr_tberro        IN OUT typ_tberro) IS
    -- Variaveis Locais
    vr_idx_err   INTEGER;
    vr_idx_conta VARCHAR2(15);
    vr_nmarquiv  VARCHAR2(100) := pr_referencia || '_CONTAS.txt';
    vr_dstext_linha VARCHAR2(32000);
    vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
  BEGIN
    -- Abrir o arquivo
    pc_abre_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                   ,pr_nmarquivo  => vr_nmarquiv
                   ,pr_ind_arqlog => vr_ind_arqlog);
  
    -- Chave para percorrer todas as agencias
    vr_idx_conta:= pr_tbarq_contas.FIRST;
    WHILE vr_idx_conta IS NOT NULL LOOP
      vr_dstext_linha := pr_tbarq_contas(vr_idx_conta).cddbanco || chr(09) || 
                         pr_tbarq_contas(vr_idx_conta).cdagenci || chr(09) || 
                         pr_tbarq_contas(vr_idx_conta).nrdconta || chr(09) || 
                         pr_tbarq_contas(vr_idx_conta).tpdconta || chr(09) || 
                         pr_tbarq_contas(vr_idx_conta).dtabertu || chr(09) || 
                         pr_tbarq_contas(vr_idx_conta).dtfecham || chr(09) || 
                         pr_tbarq_contas(vr_idx_conta).tpmovcta || chr(13);
                          
      pc_escreve_linha_arq(pr_dirarquivo  => pr_nmdir_arquivo
                          ,pr_nmarquivo   => vr_nmarquiv
                          ,pr_texto_linha => vr_dstext_linha
                          ,pr_ind_arqlog  => vr_ind_arqlog);
      
      vr_idx_conta := pr_tbarq_contas.NEXT(vr_idx_conta);
    END LOOP;
    
    -- Fechar o arquivo
    pc_fechar_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                     ,pr_nmarquivo  => vr_nmarquiv
                     ,pr_ind_arqlog => vr_ind_arqlog);
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'ARQUIVO CONTAS';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
    
  END pc_gera_arq_contas;
  
  -- Escrever todas as informações carregadas no arquivo _TITULARES
  PROCEDURE pc_gera_arq_titulares(pr_nmdir_arquivo   IN VARCHAR2
                                 ,pr_referencia      IN VARCHAR2
                                 ,pr_tbarq_titulares IN typ_tbarq_titulares
                                 ,pr_tberro          IN OUT typ_tberro) IS
    -- Variaveis Locais
    vr_idx_err      INTEGER;
    vr_idx_titular  VARCHAR2(30);
    vr_nmarquiv     VARCHAR2(100) := pr_referencia || '_TITULARES.txt';
    vr_dstext_linha VARCHAR2(32000);
    vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
  BEGIN
    -- Abrir o arquivo
    pc_abre_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                   ,pr_nmarquivo  => vr_nmarquiv
                   ,pr_ind_arqlog => vr_ind_arqlog);
                   
    -- Chave para percorrer todas as agencias
    vr_idx_titular:= pr_tbarq_titulares.FIRST;
    WHILE vr_idx_titular IS NOT NULL LOOP
      vr_dstext_linha := pr_tbarq_titulares(vr_idx_titular).cddbanco || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).cdagenci || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).nrdconta || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).tpdconta || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).dsvincul || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).flafasta || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).inpessoa || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).nrcpfcgc || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).nmprimtl || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).tpdocttl || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).nrdocttl || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).dsendere || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).nmcidade || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).ufendere || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).nmdopais || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).nrcepend || chr(09) || 
                         NVL(TRIM(pr_tbarq_titulares(vr_idx_titular).nrtelefo), 0) || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).vlrrendi || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).dtultalt || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).dtadmiss || chr(09) || 
                         pr_tbarq_titulares(vr_idx_titular).dtdemiss || chr(13);
                         
      pc_escreve_linha_arq(pr_dirarquivo  => pr_nmdir_arquivo
                          ,pr_nmarquivo   => vr_nmarquiv
                          ,pr_texto_linha => vr_dstext_linha
                          ,pr_ind_arqlog  => vr_ind_arqlog);
      
      vr_idx_titular := pr_tbarq_titulares.NEXT(vr_idx_titular);
    END LOOP;
    
    -- Fechar o arquivo
    pc_fechar_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                     ,pr_nmarquivo  => vr_nmarquiv
                     ,pr_ind_arqlog => vr_ind_arqlog);
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'ARQUIVO TITULARES';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
    
  END pc_gera_arq_titulares;

  -- Escrever todas as informações carregadas no arquivo _EXTRATO
  PROCEDURE pc_gera_arq_extrato(pr_nmdir_arquivo IN VARCHAR2
                               ,pr_referencia    IN VARCHAR2
                               ,pr_tbarq_extrato IN typ_tbarq_extrato
                               ,pr_tberro        IN OUT typ_tberro) IS
    -- Variaveis Locais
    vr_idx_err      INTEGER;
    vr_nmarquiv     VARCHAR2(100) := pr_referencia || '_EXTRATO.txt';
    vr_dstext_linha VARCHAR2(32000);
    vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
  BEGIN
    -- Abrir o arquivo
    pc_abre_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                   ,pr_nmarquivo  => vr_nmarquiv
                   ,pr_ind_arqlog => vr_ind_arqlog);
                   
    -- Percorrer todas as linhas de extrato que identificamos 
    IF pr_tbarq_extrato.COUNT > 0 THEN
      FOR vr_idx_extrato IN pr_tbarq_extrato.FIRST..pr_tbarq_extrato.LAST LOOP
        vr_dstext_linha := pr_tbarq_extrato(vr_idx_extrato).idseqlcm || chr(09) || 
                           pr_tbarq_extrato(vr_idx_extrato).cddbanco || chr(09) || 
                           pr_tbarq_extrato(vr_idx_extrato).cdagenci || chr(09) || 
                           pr_tbarq_extrato(vr_idx_extrato).nrdconta || chr(09) || 
                           pr_tbarq_extrato(vr_idx_extrato).tpdconta || chr(09) || 
                           pr_tbarq_extrato(vr_idx_extrato).dtmvtolt || chr(09) || 
                           pr_tbarq_extrato(vr_idx_extrato).nrdocmto || chr(09) || 
                           pr_tbarq_extrato(vr_idx_extrato).dshistor || chr(09) || 
                           pr_tbarq_extrato(vr_idx_extrato).tplancto || chr(09) || 
                           pr_tbarq_extrato(vr_idx_extrato).vllanmto || chr(09) || 
                           pr_tbarq_extrato(vr_idx_extrato).indebcre || chr(09) || 
                           pr_tbarq_extrato(vr_idx_extrato).vlrsaldo || chr(09) || 
                           pr_tbarq_extrato(vr_idx_extrato).sddebcre || chr(09) || 
                           pr_tbarq_extrato(vr_idx_extrato).localtra || chr(13);

        pc_escreve_linha_arq(pr_dirarquivo  => pr_nmdir_arquivo
                            ,pr_nmarquivo   => vr_nmarquiv
                            ,pr_texto_linha => vr_dstext_linha
                            ,pr_ind_arqlog  => vr_ind_arqlog);
      END LOOP;
    END IF;

    
    -- Fechar o arquivo
    pc_fechar_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                     ,pr_nmarquivo  => vr_nmarquiv
                     ,pr_ind_arqlog => vr_ind_arqlog);
                     
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'ARQUIVO EXTRATO';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
    
  END pc_gera_arq_extrato;
  
  -- Escrever todas as informações carregadas no arquivo _ORIGEM_DESTINO
  PROCEDURE pc_gera_arq_origem_destino(pr_nmdir_arquivo        IN VARCHAR2
                                      ,pr_referencia           IN VARCHAR2
                                      ,pr_tbarq_origem_destino IN typ_tbarq_origem_destino
                                      ,pr_tberro        IN OUT typ_tberro) IS
    -- Variaveis Locais
    vr_idx_err      INTEGER;
    vr_nmarquiv     VARCHAR2(100) := pr_referencia || '_ORIGEM_DESTINO.txt';
    vr_dstext_linha VARCHAR2(32000);
    vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
  BEGIN
    -- Abrir o arquivo
    pc_abre_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                   ,pr_nmarquivo  => vr_nmarquiv
                   ,pr_ind_arqlog => vr_ind_arqlog);

    -- Percorrer todas as linhas de extrato que identificamos 
    IF pr_tbarq_origem_destino.COUNT > 0 THEN
      FOR vr_idx IN pr_tbarq_origem_destino.FIRST..pr_tbarq_origem_destino.LAST LOOP
        
        --CPF_CNPJ_OD,NOME_PESSOA_OD, NUMERO_BANCO_OD, NUMERO_AGENCIA_OD e NUMERO_CONTA_OD
        vr_dstext_linha := pr_tbarq_origem_destino(vr_idx).idseqarq || chr(09) || 
                           pr_tbarq_origem_destino(vr_idx).idseqlcm || chr(09) || 
                           pr_tbarq_origem_destino(vr_idx).vllanmto || chr(09) || 
                           pr_tbarq_origem_destino(vr_idx).nrdocmto || chr(09) || 
                           pr_tbarq_origem_destino(vr_idx).cdbandep || chr(09) || --NUMERO_BANCO_OD
                           pr_tbarq_origem_destino(vr_idx).cdagedep || chr(09) || --NUMERO_AGENCIA_OD
                           pr_tbarq_origem_destino(vr_idx).nrctadep || chr(09) || --NUMERO_CONTA_OD
                           pr_tbarq_origem_destino(vr_idx).tpdconta || chr(09) || 
                           pr_tbarq_origem_destino(vr_idx).inpessoa || chr(09) || 
                           pr_tbarq_origem_destino(vr_idx).nrcpfcgc || chr(09) || --CPF_CNPJ_OD
                           pr_tbarq_origem_destino(vr_idx).nmprimtl || chr(09) || --NOME_PESSOA_OD
                           pr_tbarq_origem_destino(vr_idx).tpdocttl || chr(09) || 
                           pr_tbarq_origem_destino(vr_idx).nrdocttl || chr(09) || 
                           pr_tbarq_origem_destino(vr_idx).dscodbar || chr(09) || 
                           pr_tbarq_origem_destino(vr_idx).nmendoss || chr(09) || 
                           pr_tbarq_origem_destino(vr_idx).docendos || chr(09) || 
                           pr_tbarq_origem_destino(vr_idx).idsitide || chr(09) || 
                           pr_tbarq_origem_destino(vr_idx).dsobserv || chr(13);
      
        pc_escreve_linha_arq(pr_dirarquivo  => pr_nmdir_arquivo
                            ,pr_nmarquivo   => vr_nmarquiv
                            ,pr_texto_linha => vr_dstext_linha
                            ,pr_ind_arqlog  => vr_ind_arqlog);
	  END LOOP;
    END IF;
    
    -- Fechar o arquivo
    pc_fechar_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                     ,pr_nmarquivo  => vr_nmarquiv
                     ,pr_ind_arqlog => vr_ind_arqlog);
                     
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'ARQUIVO ORIGEM DESTINO';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
    
  END pc_gera_arq_origem_destino;

	
  -- Escrever todas as informações carregadas no arquivo _CHEQUES_ICFJUD_CPF
  PROCEDURE pc_gera_arq_cheques_icfjud(pr_nmdir_arquivo        	IN VARCHAR2
                                      ,pr_referencia           	IN VARCHAR2
                                      ,pr_tbarq_cheques_icfjud 	IN typ_tbarq_cheques_icfjud
                                      ,pr_tberro        		IN OUT typ_tberro) IS
    -- Variaveis Locais
    vr_idx_err      INTEGER;
    vr_nmarquiv     VARCHAR2(100) := pr_referencia || '_CHEQUES_ICFJUD_CPF.csv';
    vr_dstext_linha VARCHAR2(32000);
    vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
  BEGIN
    -- Abrir o arquivo
    pc_abre_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                   ,pr_nmarquivo  => vr_nmarquiv
                   ,pr_ind_arqlog => vr_ind_arqlog);
           
		vr_dstext_linha := 'Data Solicitação;Banco Requisitado;Agência Requisitada;Conta Requisitada;Tipo Requisição;CMC7';
		
		pc_escreve_linha_arq(pr_dirarquivo  => pr_nmdir_arquivo
												,pr_nmarquivo   => vr_nmarquiv
												,pr_texto_linha => vr_dstext_linha
                   ,pr_ind_arqlog => vr_ind_arqlog);
				   
    -- Percorrer todas as linhas de extrato que identificamos
    IF pr_tbarq_cheques_icfjud.COUNT > 0 THEN
      FOR vr_idx IN pr_tbarq_cheques_icfjud.FIRST..pr_tbarq_cheques_icfjud.LAST LOOP
        vr_dstext_linha := pr_tbarq_cheques_icfjud(vr_idx).dtinireq || ';' || 
                           pr_tbarq_cheques_icfjud(vr_idx).cdbanreq || ';' || 
                           pr_tbarq_cheques_icfjud(vr_idx).cdagereq || ';' || 
                           pr_tbarq_cheques_icfjud(vr_idx).nrctareq || ';' || 
                           pr_tbarq_cheques_icfjud(vr_idx).intipreq || ';' || 
                           pr_tbarq_cheques_icfjud(vr_idx).dsdocmc7;
      
        pc_escreve_linha_arq(pr_dirarquivo  => pr_nmdir_arquivo
                            ,pr_nmarquivo   => vr_nmarquiv
                            ,pr_texto_linha => vr_dstext_linha
                            ,pr_ind_arqlog  => vr_ind_arqlog);
	  END LOOP;
    END IF;
    --	
    -- Fechar o arquivo
    pc_fechar_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                     ,pr_nmarquivo  => vr_nmarquiv
                     ,pr_ind_arqlog => vr_ind_arqlog);
                     
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'ARQUIVO CHEQUES ICF JUD';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_gera_arq_cheques_icfjud;
  -- FIM -> Gerar os arquivos

-- BLOCO PRINCIPAL DO PROGRAMA  
BEGIN 
  
  -- Limpar todas as tabelas que serão utilizadas no processo
  vr_tbconta_investigar.DELETE;
  vr_tberro.DELETE;
  vr_tbhistorico.DELETE;
  vr_tbpa.DELETE;
  vr_tbarq_agencias.DELETE;
  vr_tbarq_contas.DELETE;
  vr_tbarq_titulares.DELETE;
  vr_tbarq_extrato.DELETE;
  vr_tbarq_origem_destino.DELETE;
  vr_tbarq_cheques_icfjud.DELETE; 
  
  -- ##############################################################################################################
  -- #####################################        ALTERAR APENAS AQUI         #####################################
  -- ##############################################################################################################

  -- Contas para investigar (Possuem o CPF que está sendo investigado)
  -- MASCARA DA CONTA PARA ADICIONAR NA CONTA INVESTIGADA
  --   000_0000000000 -> Cooperativa com 3 digitos, Conta com 10 digitos e o CPF/CNPJ com 15 digitos, separados por "_"
  /*  Exemplo:
        vr_tbconta_investigar('000_0000000000_000000000000000').cdcooper := 0;
        vr_tbconta_investigar('000_0000000000_000000000000000').nrdconta := 0;
        vr_tbconta_investigar('000_0000000000_000000000000000').nrcpfcgc := 0;
  */
  -- ##############################################################################################################
  -- ##############################################################################################################

  -- Adicionar a referencia (será utilizada para criação da pasta que conterá os arquivos gerados)
  vr_referencia := 'RITM0032523';

  -- Data que deve ocorrer a quebra de sigilo bancário
  vr_dtinicio   := TO_DATE('01/01/2008','DD/MM/YYYY'); --01/01/2008 até 31/12/2013
  vr_dtfim      := TO_DATE('05/05/2019','DD/MM/YYYY'); 

  --viacredi 1 | cpfs 054.827.669-26 / 091.066.489-75 / 547.238.929-15 / 705.580.789-15
/*
3834956   9106648975  
4043650   5482766926
6121039   54723892915
8474540   70558078915
  */
  vr_tbconta_investigar('001_0003834956_000009106648975').cdcooper := 1;
  vr_tbconta_investigar('001_0003834956_000009106648975').nrdconta := 3834956;
  vr_tbconta_investigar('001_0003834956_000009106648975').nrcpfcgc := 9106648975;

  vr_tbconta_investigar('001_0004043650_000005482766926').cdcooper := 1;
  vr_tbconta_investigar('001_0004043650_000005482766926').nrdconta := 4043650;
  vr_tbconta_investigar('001_0004043650_000005482766926').nrcpfcgc := 5482766926;
  
  vr_tbconta_investigar('001_0006121039_000054723892915').cdcooper := 1;
  vr_tbconta_investigar('001_0006121039_000054723892915').nrdconta := 6121039;
  vr_tbconta_investigar('001_0006121039_000054723892915').nrcpfcgc := 54723892915;
  
  vr_tbconta_investigar('001_0008474540_000070558078915').cdcooper := 1;
  vr_tbconta_investigar('001_0008474540_000070558078915').nrdconta := 8474540;
  vr_tbconta_investigar('001_0008474540_000070558078915').nrcpfcgc := 70558078915;
  
  -- Carregar as informações iniciais para a quebra de sigilo bancário
  -- Mapeamento de Histórico DE->PARA
  pc_carregar_historico_de_para(pr_tbhistorico => vr_tbhistorico);
  
  -- Dados da Agencia
  pc_carregar_dados_pa(pr_tbpa => vr_tbpa);

  -- Inicio do carregamento dos dados para geração dos arquivos
  -- Dados para o arquivo _AGENCIAS
  pc_carrega_arq_agencias(pr_tbconta_investigar => vr_tbconta_investigar
                         ,pr_tbpa               => vr_tbpa
                         ,pr_tbarq_agencias     => vr_tbarq_agencias
                         ,pr_tberro             => vr_tberro);

  -- Dados para o arquivo _CONTAS
  pc_carrega_arq_contas(pr_tbconta_investigar => vr_tbconta_investigar
                       ,pr_dtini_quebra       => vr_dtinicio
                       ,pr_dtfim_quebra       => vr_dtfim
                       ,pr_tbarq_conta        => vr_tbarq_contas
                       ,pr_tberro             => vr_tberro);
                       
  -- Dados para o arquivo _TITULARES
  pc_carrega_arq_titulares(pr_tbconta_investigar => vr_tbconta_investigar
                          ,pr_tbarq_titulares    => vr_tbarq_titulares
                          ,pr_tberro             => vr_tberro);

  -- Dados para o arquivo _EXTRATO
  pc_carrega_arq_extrato(pr_tbconta_investigar => vr_tbconta_investigar
                        ,pr_dtini_quebra       => vr_dtinicio
                        ,pr_dtfim_quebra       => vr_dtfim
                        ,pr_tbhistorico        => vr_tbhistorico
                        ,pr_tbarq_extrato      => vr_tbarq_extrato
                        ,pr_tberro             => vr_tberro);

  -- Dados para o arquivo _ORIGEM_DESTINO
  pc_carrega_arq_origem_destino(pr_tbconta_investigar   => vr_tbconta_investigar
                               ,pr_dtini_quebra         => vr_dtinicio
                               ,pr_dtfim_quebra         => vr_dtfim
                               ,pr_tbhistorico          => vr_tbhistorico
                               ,pr_tbarq_origem_destino => vr_tbarq_origem_destino
                               ,pr_tbarq_cheques_icfjud => vr_tbarq_cheques_icfjud --> Dados do novo arquivo de cheques icfjud
                               ,pr_tberro               => vr_tberro);

  -- Verificar se ocorreu algum erro que deve ser tratado antes de gerar o arquivo
  IF vr_tberro.COUNT > 0 THEN
    RAISE vr_erros;
  END IF;
  
  -- Se não possuir erros gera os arquivos 
  -- Criar diretorio com base na REFERENCIA do processo de quebra de sigilo bancário
  vr_dir_arq := vr_dircop || '/' || vr_referencia;
  -- Primeiro garantimos que o diretorio exista
  IF NOT gene0001.fn_exis_diretorio(vr_dir_arq) THEN
    -- Efetuar a criação do mesmo
    gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir '||vr_dir_arq||' 1> /dev/null'
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_des_saida);

    --Se ocorreu erro dar RAISE
    IF vr_typ_saida = 'ERR' THEN
      vr_idx_err := vr_tberro.COUNT + 1;
      vr_tberro(vr_idx_err).dsorigem := 'CRIAR DIRETORIO ARQUIVO';
      vr_tberro(vr_idx_err).dserro   := 'Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;  
      RAISE vr_erros;
    END IF;           
    
    -- Adicionar permissão total na pasta
    gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 '||vr_dir_arq||' 1> /dev/null'
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_des_saida);

    --Se ocorreu erro dar RAISE
    IF vr_typ_saida = 'ERR' THEN
      vr_idx_err := vr_tberro.COUNT + 1;
      vr_tberro(vr_idx_err).dsorigem := 'PERMISSAO NO DIRETORIO';
      vr_tberro(vr_idx_err).dserro   := 'Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
      RAISE vr_erros;
    END IF;           
  END IF;
  
  -- Gerar o arquivo com os dados das agencias para quebra do sigilo bancário
  pc_gera_arq_agencias(pr_nmdir_arquivo   => vr_dir_arq
                      ,pr_referencia      => vr_referencia
                      ,pr_tbarq_agencias  => vr_tbarq_agencias
                      ,pr_tberro          => vr_tberro);
  
  -- Gerar o arquivo com os dados das contas para quebra do sigilo bancário
  pc_gera_arq_contas(pr_nmdir_arquivo => vr_dir_arq
                    ,pr_referencia    => vr_referencia
                    ,pr_tbarq_contas  => vr_tbarq_contas
                    ,pr_tberro        => vr_tberro);

  -- Gerar o arquivo com os dados dos titulares para quebra do sigilo bancário
  pc_gera_arq_titulares(pr_nmdir_arquivo   => vr_dir_arq
                       ,pr_referencia      => vr_referencia
                       ,pr_tbarq_titulares => vr_tbarq_titulares
                       ,pr_tberro          => vr_tberro);
                       
  -- Gerar o arquivo com os dados do extrato para quebra do sigilo bancário
  pc_gera_arq_extrato(pr_nmdir_arquivo => vr_dir_arq
                     ,pr_referencia    => vr_referencia
                     ,pr_tbarq_extrato => vr_tbarq_extrato
                     ,pr_tberro        => vr_tberro);

  -- Gerar o arquivo com os dados de origem e destino para quebra do sigilo bancário
  pc_gera_arq_origem_destino(pr_nmdir_arquivo        => vr_dir_arq
                            ,pr_referencia           => vr_referencia
                            ,pr_tbarq_origem_destino => vr_tbarq_origem_destino
                            ,pr_tberro               => vr_tberro);
  
  -- Gerar o arquivo com os dados de origem e destino para quebra do sigilo bancário
  pc_gera_arq_cheques_icfjud(pr_nmdir_arquivo        => vr_dir_arq
                            ,pr_referencia           => vr_referencia
                            ,pr_tbarq_cheques_icfjud => vr_tbarq_cheques_icfjud
                            ,pr_tberro               => vr_tberro);

  -- Caso tenha acontecido algum erro durante a geracao dos arquivos precisamos corrigir
  IF vr_tberro.COUNT > 0 THEN
    RAISE vr_erros;
  END IF;
  
	-- Efetuar commit
	COMMIT;
EXCEPTION
  WHEN vr_erros THEN
    dbms_output.put_line('Foram identificados erros durante a geração dos arquivos de quebra de sigilo bancário.');
    dbms_output.put_line('Favor verificar!');
    
    FOR x IN vr_tberro.FIRST..vr_tberro.LAST LOOP
      dbms_output.put_line(vr_tberro(x).dsorigem || ' => ' || vr_tberro(x).dserro);
    END LOOP;
    -- Não altera nenhum dado    
    ROLLBACK;
  
  WHEN OTHERS THEN
    dbms_output.put_line('Erro não tratado. Verifique: ' ||
                         REPLACE (dbms_utility.format_error_backtrace || ' - ' ||
                                  dbms_utility.format_error_stack,'"', NULL));
    -- Não altera nenhum dado    
    ROLLBACK;
END pc_quebra_sigilo_bancario;
/
