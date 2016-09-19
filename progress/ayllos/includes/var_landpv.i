/* ...........................................................................

   Programa: Includes/var_landpv.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/94.                    Ultima atualizacao: 22/01/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Definicao das variaveis e forms da tela LANDPV.

   Alteracoes: 06/10/94 - Incluida a variavel auxiliar para codigo da alinea
                          (Deborah).

               27/10/94 - Incluida a variavel auxiliar para controle da devolu-
                          cao dos cheques com contra-ordem.

               29/07/97 - Colocado auto-return no valor do lancamento (Deborah).

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               13/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

             05/05/2001 - Tratamento da compensacao eletronica (Margarete).
               
             14/05/2001 - Incluir opcao D e M (Margarete).

             20/08/2001 - Tratar onze posicoes no numero do documento (Edson).

             17/09/2001 - Criar histor 21 quando 386 (Margarete).

             21/01/2002 - Vincular historicos aos lancamentos (Margarete).
             
             02/10/2002 - Tratar liberacao de cheques (Margarete).

             11/03/2003 - Erro no numero do documento quando desmembra o
                          historico 3 e 4 (Margarete).

             13/03/2003 - Incluir tratamento da Concredi (Margarete).

             22/08/2003 - Quando histor 386 criticar saldo (Margarete).

             15/06/2004 - Incluir novas variaveis (Edson).
             
             09/08/2004 - Se histor 88, atualizar crapepr.dtdpagto,
                            crapepr.indpagto (Margarete).

             25/08/2004 - Incluir variaveis para conta integracao (Margarete).

             23/09/2004 - Incluir variaveis para Conta Investimento (Evandro).
             
             06/01/2005 - Quando histor 317, estorno pagto emprestimo,
                            nao deixar estornar mais do que pagou (Margarete).

             27/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                          (Evandro).
                          
             29/09/2005 - Troca da tabela CRAPCHQ p/ CRAPFDC - Andre (SQLWORKS)
             
             27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

             27/02/2007 - Ajustes para o Bancoob (Magui)

             13/04/2007 - Aumentar campo nrdocmto (Magui).
             
             09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                          glb_cdcooper) no "CAN-FIND" da tabela CRAPHIS. 
                        - Kbase IT Solutions - Paulo Ricardo Maciel.
                        
             21/07/2009 - Novo frame f_nrboleto (Guilherme).

             23/11/2009 - Alteracao Codigo Historico (Kbase).
             
             02/03/2011 - Inclusao das variaveis aux_dtmvtlct e aux_vllanlct
                          p/ landpvi.p (Vitor).
                          
             26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                          para crapbcl (Adriano). 
                          
             19/03/2013 - Alterado format da variavel "tel_vlcompdb" (Kruger).
             
             12/06/2013 - Criado frame 'f_landpv_e' para maior format do
                          Nr. do Docmto (Lucas).
                          
             09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).
             
             16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                          nao cadastrado.". (Reinert)

             27/05/2014 - Ajustado o campo tel_nrdocmto, pois o mesmo estava 
                          vindo com 22 posicoes (Andrino - RKAM)
                          
             03/12/2014 - Removido display do campo tel_nrseqdig no frame
                          f_landpv.
                          Motivo: Foi necessario voltar o tamanho do campo
                          de valor (tel_vllanmto) para o seu tamanho original.
                          (Chamado 175752) - (Fabricio)
                          
             22/01/2015 - Remocao de linha em branco entre as linhas, a 
                          formatacao do campo numero do documento estava
                          quebrando as linhas. (Jaison - SD: 246336)
             
             26/01/2015 - Alterado o formato do campo nrctremp para 8 
                          caracters (Kelvin - 233714)
............................................................................ */

DEF BUFFER crablcm  FOR craplcm.
DEF BUFFER crabhis  FOR craphis.
DEF BUFFER crabhis2 FOR craphis.

DEF BUFFER crabfdc  FOR crapfdc.

DEF BUFFER crablot  FOR craplot.
DEF BUFFER crablem  FOR craplem.
DEF BUFFER crabass5 FOR crapass.

DEF {1} SHARED VAR glb_vldebcon AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR glb_vllimneg AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.

DEF {1} SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR tel_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF {1} SHARED VAR tel_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_cdhistor AS INT     FORMAT "zzz9"                NO-UNDO.
DEF {1} SHARED VAR tel_nrdctabb AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR tel_nrdocmto AS DECIMAL FORMAT "zzzzzzzzzzzzzzzzzzzzz9"  NO-UNDO.
DEF {1} SHARED VAR tel_vllanmto AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR tel_dtliblan AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR tel_nrseqdig AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_reganter AS CHAR    FORMAT "x(74)" EXTENT 6      NO-UNDO.
DEF {1} SHARED VAR tel_cdalinea AS INT     FORMAT "zz"                  NO-UNDO.
DEF {1} SHARED VAR tel_nrautdoc LIKE craplcm.nrautdoc                   NO-UNDO.
DEF {1} SHARED VAR tel_cdbaninf LIKE crapfdc.cdbanchq                   NO-UNDO.
DEF {1} SHARED VAR tel_cdageinf LIKE crapfdc.cdagechq                   NO-UNDO.

DEF {1} SHARED VAR his_txdoipmf AS DECIMAL FORMAT "zzz,zz9.9999"        NO-UNDO.
DEF {1} SHARED VAR his_cdhistor AS INT                                  NO-UNDO.
DEF {1} SHARED VAR his_nrdolote AS INT                                  NO-UNDO.
DEF {1} SHARED VAR his_tplotmov AS INT                                  NO-UNDO.
DEF {1} SHARED VAR his_inliquid AS INT                                  NO-UNDO.
DEF {1} SHARED VAR his_nrctremp LIKE crapepr.nrctremp                   NO-UNDO.
DEF {1} SHARED VAR his_vlsdeved AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR his_dtultpag AS DATE                                 NO-UNDO.

DEF {1} SHARED VAR ant_nrdconta AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.

DEF {1} SHARED VAR dpv_nrdctitg AS CHAR                                 NO-UNDO.

DEF {1} SHARED VAR aux_ctpsqitg LIKE craplcm.nrdctabb                   NO-UNDO.
DEF {1} SHARED VAR aux_nrdctitg LIKE crapass.nrdctitg                   NO-UNDO.
DEF {1} SHARED VAR aux_nrdigitg as CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_nrdconta AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR aux_nrdctabb AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR aux_nrctalcm AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR aux_nrctaass AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR aux_nrtrfcta AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR aux_dtmvtolt AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR aux_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR aux_nrdolote AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR aux_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR aux_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR aux_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF {1} SHARED VAR aux_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"                NO-UNDO.
DEF {1} SHARED VAR aux_canclchq AS CHAR    FORMAT "!(1)"                NO-UNDO.
DEF {1} SHARED VAR aux_flgerros AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgretor AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_indevchq AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_cdalinea AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_regexist AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_contador AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_cddopcao AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_cdhistor AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdocmto AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR aux_vllanmto AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR aux_dtliblan AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_indebcre AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_inhistor AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_indoipmf AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_txdoipmf AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR aux_vlsdchsl AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_vlsdbloq AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_vlsdblpr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_vlsdblfp AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_vlstotal AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_vlrdifer AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR aux_lscontas AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_lsconta1 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_lsconta2 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_lsconta3 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_cdbandep LIKE crapfdc.cdbandep                   NO-UNDO.
DEF {1} SHARED VAR aux_cdagedep LIKE crapfdc.cdagedep                   NO-UNDO.

DEF {1} SHARED VAR aux_mensagem AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_nrseqlcm AS INTE                                 NO-UNDO.
DEF {1} SHARED VAR aux_vlcapmin AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgpreju AS LOG                                  NO-UNDO.
DEF {1} SHARED VAR aux_vlctrmve AS DEC                                  NO-UNDO.
DEF {1} SHARED VAR ant_cdhistor AS INT     FORMAT "zzz9"                NO-UNDO.
DEF {1} SHARED VAR ant_nrdctabb AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR ant_nrdocmto AS DECIMAL FORMAT "zz,zzz,zzz,zzz,zz9"  NO-UNDO.

DEF {1} SHARED VAR aux_diapagto AS INTE                                 NO-UNDO.
DEF {1} SHARED VAR aux_mespagto AS INTE                                 NO-UNDO.
DEF {1} SHARED VAR aux_anopagto AS INTE                                 NO-UNDO.
DEF {1} SHARED VAR aux_ttjpgepr AS DEC                                  NO-UNDO.

DEF {1} SHARED VAR de-valor-bloqueado AS DEC                            NO-UNDO.
DEF {1} SHARED VAR de-valor-liberado  AS DEC                            NO-UNDO.

DEF {1} SHARED VAR aut_flgsenha AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aut_cdoperad AS CHAR                                 NO-UNDO.

DEF            VAR aux_dtmvtlct AS DATE                                 NO-UNDO.
DEF            VAR aux_vllanlct LIKE craplct.vllanmto                   NO-UNDO.
                                                                        
DEF {1} SHARED FRAME f_landpv.
DEF {1} SHARED FRAME f_regant.
DEF {1} SHARED FRAME f_lanctos.

FORM    SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE COLOR MESSAGE " Lancamentos de Depositos a Vista "
                      FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C, D, E, I, K ou M)"
                        VALIDATE (glb_cddopcao = "C" OR
                                  glb_cddopcao = "D" OR glb_cddopcao = "E" OR
                                  glb_cddopcao = "I" OR glb_cddopcao = "K" OR
                                  glb_cddopcao = "M","014 - Opcao errada.")

     tel_dtmvtolt AT 12 LABEL "Data"
     tel_cdagenci AT 31 LABEL "PA"
                        HELP "Entre com o codigo do PA."
                        VALIDATE (CAN-FIND (crapage WHERE crapage.cdcooper = 
                                                          glb_cdcooper  AND
                                                          crapage.cdagenci =
                                  tel_cdagenci),"962 - PA nao cadastrado.")

     tel_cdbccxlt AT 47 LABEL "Banco/Caixa"
                        HELP "Entre com o codigo do Banco/Caixa."
                        VALIDATE (CAN-FIND (crapbcl WHERE crapbcl.cdbccxlt =
                                  tel_cdbccxlt),"057 - Banco nao cadastrado.")

     tel_nrdolote AT 65 LABEL "Lote"
                        HELP "Entre com o numero do lote."
                        VALIDATE (tel_nrdolote > 0,
                                  "058 - Numero do lote errado.")

     SKIP(1)
     tel_qtinfoln AT  2 LABEL "Informado:Qtd"
     tel_vlinfodb AT 24 LABEL "Debito"
     tel_vlinfocr AT 51 LABEL "Credito"
     SKIP
     tel_qtcompln AT  2 LABEL "Computado:Qtd"
     tel_vlcompdb AT 24 LABEL "Debito"
     tel_vlcompcr AT 51 LABEL "Credito"
     SKIP
     tel_qtdifeln AT  2 LABEL "Diferenca:Qtd"
     tel_vldifedb AT 24 LABEL "Debito"
     tel_vldifecr AT 51 LABEL "Credito"
     SKIP(1)
     "Hst Ct.Base/Chq Bco  Age          Documento" AT 1
     "Valor Liber            Ali" AT 48   
      SKIP(1)
     tel_cdhistor AT  1 NO-LABEL
                        HELP "Entre com o codigo do historico."
                        VALIDATE (tel_cdhistor > 0 AND
                                  CAN-FIND(craphis WHERE
                                           craphis.cdcooper = glb_cdcooper AND
                                           craphis.cdhistor = tel_cdhistor),
                                           "093 - Historico errado.")

     tel_nrdctabb AT  6 NO-LABEL
                        HELP "Informe o numero da conta do associado."

     tel_cdbaninf NO-LABEL FORMAT "zz9"
     tel_cdageinf NO-LABEL FORMAT "zzz9"
     tel_nrdocmto NO-LABEL FORMAT "zzzzzzzzzzzzzzzzzzzzzz"
                        HELP "Entre com o numero do documento."

     tel_vllanmto NO-LABEL   AUTO-RETURN  FORMAT "zzz,zzz,zz9.99"
                        HELP "Entre com o valor do lancamento."
                        VALIDATE (tel_vllanmto > 0,
                                  "091 - Valor do lancamento errado.")

     tel_dtliblan NO-LABEL
                        HELP "Entre com a data de liberacao."

     tel_cdalinea NO-LABEL 
                        HELP "Entre com o codigo da alinea de devolucao"

     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_landpv.

FORM "Ct.Base/Chq                           Documento"
     SKIP(1)
     tel_nrdctabb AT 02 NO-LABEL HELP "Informe o numero da conta do associado."
     tel_nrdocmto AT 15 NO-LABEL FORMAT "z,zzz,zzz,zzz,zzz,zzz,zzz,zzz,zzz"
     WITH ROW 12 COLUMN 6 OVERLAY NO-BOX WIDTH 48 FRAME f_landpv_e.

FORM tel_reganter[1] AT 1 NO-LABEL  tel_reganter[2] AT 1 NO-LABEL
     tel_reganter[3] AT 1 NO-LABEL  tel_reganter[4] AT 1 NO-LABEL
     tel_reganter[5] AT 1 NO-LABEL  tel_reganter[6] AT 1 NO-LABEL
     WITH ROW 15 COLUMN 2 OVERLAY NO-BOX FRAME f_regant.

FORM craplcm.cdhistor AT  1  
     craplcm.nrdctabb AT  6
     craplcm.cdbanchq       FORMAT "zz9"
     craplcm.cdagechq       FORMAT "zzz9"
     craplcm.nrdocmto       FORMAT "zzzzzzzzzzzzzzzzzz"
     craplcm.vllanmto       FORMAT "zzz,zzz,zz9.99"
     tel_dtliblan       
     tel_cdalinea     AT 72
     WITH ROW 15 COLUMN 2 OVERLAY NO-LABEL NO-BOX 6 DOWN FRAME f_lanctos.

/****** Variaveis para tratamento da Compensacao Eletronica ****/
/**** Colocado NO-UNDO na Temp-Table w-compel ****/
DEF TEMP-TABLE w-compel                                            NO-UNDO
    FIELD dsdocmc7 AS CHAR    FORMAT "X(34)"
    FIELD cdcmpchq AS INT     FORMAT "zz9"
    FIELD cdbanchq AS INT     FORMAT "zz9"
    FIELD cdagechq AS INT     FORMAT "zzz9"
    FIELD nrddigc1 AS INT     FORMAT "9"   
    FIELD nrctaaux AS INT     
    FIELD nrctachq AS DECIMAL FORMAT "zzz,zzz,zzz,9"
    FIELD nrctabdb AS DECIMAL FORMAT "zzz,zzz,zzz,9"
    FIELD nrddigc2 AS INT     FORMAT "9"            
    FIELD nrcheque AS INT     FORMAT "zzz,zz9"      
    FIELD nrddigc3 AS INT     FORMAT "9"            
    FIELD vlcompel AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD dtlibcom AS DATE    FORMAT "99/99/9999"
    FIELD lsdigctr AS CHAR
    FIELD tpdmovto AS INTE
    FIELD nrseqdig AS INTE
    FIELD nrseqlcm AS INTE
    FIELD cdtipchq AS INTE
    FIELD nrdoclcm LIKE craplcm.nrdocmto
    FIELD nrposchq AS INTE
    INDEX compel1 AS UNIQUE PRIMARY
          dsdocmc7
    INDEX compel2 AS UNIQUE
          nrseqdig DESCENDING.

DEF {1} SHARED VAR tel_vlcompel AS DEC     FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR tel_cdcmpchq AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_cdbanchq AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_cdagechq AS INT     FORMAT "zzz9"                NO-UNDO.
DEF {1} SHARED VAR tel_nrddigc1 AS INT     FORMAT "9"                   NO-UNDO.
DEF {1} SHARED VAR tel_nrctachq AS DECIMAL FORMAT "zzz,zzz,zzz,9"       NO-UNDO.
DEF {1} SHARED VAR tel_nrctabdb AS DECIMAL FORMAT "zzz,zzz,zzz,9"       NO-UNDO.
DEF {1} SHARED VAR tel_nrddigc2 AS INT     FORMAT "9"                   NO-UNDO.
DEF {1} SHARED VAR tel_nrcheque AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_nrddigc3 AS INT     FORMAT "9"                   NO-UNDO.
DEF {1} SHARED VAR tel_vlcheque AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR tel_dtlibcom AS DATE    FORMAT "99/99/9999"          NO-UNDO.

DEF {1} SHARED VAR tel_nrddigv1 AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tel_nrddigv2 AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tel_nrddigv3 AS INT                                  NO-UNDO.

DEF {1} SHARED VAR tel_nrfavore AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR tel_nmfavore AS CHAR    FORMAT "x(40)"               NO-UNDO.
DEF {1} SHARED VAR tel_dsdocmc7 AS CHAR    FORMAT "x(34)"               NO-UNDO.

DEF {1} SHARED VAR aux_lsvalido AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_lsdigctr AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_tpdmovto AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrtalchq AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_cdagebcb AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_vlttcomp AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR aux_nrctcomp AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrctachq AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdocchq AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_flgchqex AS LOG                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrsqcomp AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_qtlincom AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_maischeq AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_vllanlcm LIKE craplcm.vllanmto                   NO-UNDO.
DEF {1} SHARED VAR aux_nrdoclcm LIKE craplcm.nrdocmto                   NO-UNDO.
DEF {1} SHARED VAR aux_nrdocchr AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR tab_vlchqmai AS DECIMAL                              NO-UNDO.

DEF {1} SHARED FRAME f_compel.
DEF {1} SHARED FRAME f_lanctos_compel.

FORM tel_vlcompel AT  6 LABEL "Valor"
                        VALIDATE(tel_vlcompel <> 0,
                                 "269 - Valor errado.")
     tel_dsdocmc7 AT 32 LABEL "CMC-7"
     SPACE(6) SKIP(1)
     "Comp  Bco   Ag. C1          Conta C2   Cheque C3" AT 3 
     SPACE(11) 
     "Valor   Liberacao"
     WITH ROW 12 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX NO-LABELS FRAME f_compel.

FORM tel_cdcmpchq SPACE(2)
     tel_cdbanchq SPACE(2)
     tel_cdagechq SPACE(2)
     tel_nrddigc1 SPACE(2)
     tel_nrctabdb SPACE(2)
     tel_nrddigc2 SPACE(2) 
     tel_nrcheque SPACE(2)
     tel_nrddigc3 SPACE(2)
     tel_vlcheque SPACE(2) 
     tel_dtlibcom 
     WITH ROW 16 COLUMN 5 OVERLAY NO-LABEL NO-BOX 5 DOWN FRAME f_lanctos_compel.

/* variaveis para mostrar a consulta da compensacao eletronica */          
DEF QUERY  bcrapchd-q FOR crapchd. 
DEF BROWSE bcrapchd-b QUERY bcrapchd-q
      DISP cdcmpchq  COLUMN-LABEL "Comp"
           cdbanchq  COLUMN-LABEL "Bco"
           cdagechq  COLUMN-LABEL "Ag."
           nrddigc1  COLUMN-LABEL "C1"
           nrctachq  COLUMN-LABEL "Conta"
           nrddigc2  COLUMN-LABEL "C2"
           nrcheque  COLUMN-LABEL "Cheque"
           nrddigc3  COLUMN-LABEL "C3"
           vlcheque  COLUMN-LABEL "Valor"
           WITH 3 DOWN OVERLAY.    

DEF FRAME f_consulta_compel
          bcrapchd-b HELP "Pressione <F4> ou <END> para finalizar" 
          SKIP(1)
          WITH NO-BOX CENTERED OVERLAY ROW 15.
 
ASSIGN aux_lsvalido = "1,2,3,4,5,6,7,8,9,0,G,<,>,:," +
                      "RETURN,F4,CURSOR-LEFT,CURSOR-RIGHT".

/* variaveis para mostrar a consulta do w-compel */          
DEF QUERY  bwcompel-q FOR w-compel. 
DEF BROWSE bwcompel-b QUERY bwcompel-q
      DISP w-compel.cdcmpchq  COLUMN-LABEL "Comp"
           w-compel.cdbanchq  COLUMN-LABEL "Bco"
           w-compel.cdagechq  COLUMN-LABEL "Ag."
           w-compel.nrddigc1  COLUMN-LABEL "C1"
           w-compel.nrctachq  COLUMN-LABEL "Conta"
           w-compel.nrddigc2  COLUMN-LABEL "C2"
           w-compel.nrcheque  COLUMN-LABEL "Cheque"
           w-compel.nrddigc3  COLUMN-LABEL "C3"
           w-compel.vlcompel  COLUMN-LABEL "Valor"
           WITH 3 DOWN OVERLAY.    

DEF FRAME f_consulta_wcompel
          bwcompel-b HELP "Pressione <F4> ou <END> para finalizar" 
          SKIP(1)
          WITH NO-BOX CENTERED OVERLAY ROW 15.
 
/****** Magui alterado em 05/02/2002 ***********************************/
DEF {1} SHARED VAR tab_inusatab AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR tel_nrctremp AS INT     FORMAT "zz,zzz,zz9"           NO-UNDO.
DEF {1} SHARED VAR tel_nrboleto AS INT     FORMAT "zzz,zzz,9"           NO-UNDO.
DEF {1} SHARED VAR aux_nrctremp LIKE crapepr.nrctremp                   NO-UNDO.
DEF {1} SHARED VAR aux_vljurmes AS DECIMAL FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF {1} SHARED VAR aux_vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF {1} SHARED VAR aux_vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_vlprepag AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_txdjuros AS DECIMAL DECIMALS 7                   NO-UNDO.
DEF {1} SHARED VAR aux_dtcalcul AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_dtultdia AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_dtultpag AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_inliquid AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tab_diapagto AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tab_dtcalcul AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_dtmesant AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_nrdiacal AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdiames AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdiamss AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_ddlanmto AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_qtprepag AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR aux_inhst093 AS LOGICAL                              NO-UNDO.
   
FORM tel_nrctremp    LABEL "Referente ao Contrato NRO."
                        HELP "Informe o numero do contrato de emprestimo."
     WITH ROW 16 CENTERED OVERLAY SIDE-LABELS FRAME f_nrctremp.
     
FORM tel_nrboleto    LABEL "  Referente ao boleto NRO."
                     HELP "Informe o numero do boleto de emprestimo."
     WITH ROW 16 CENTERED OVERLAY SIDE-LABELS FRAME f_nrboleto.

FORM tel_nrautdoc  LABEL "Autenticacao NRO."
                   HELP "Informe o numero da autenticacao."
                   VALIDATE(tel_nrautdoc > 0,
                            "375 - O campo deve ser preenchido")
     WITH ROW 16 CENTERED OVERLAY SIDE-LABELS FRAME f_autentica.

/*** Para criticar o saldo quando for cheque nosso ***/

/**** Colocado opcao NO-UNDO nas variaveis e na Temp-Table tt-conta ****/
DEF            VAR h-b1crap02   AS HANDLE                               NO-UNDO.
DEF            VAR aux_vllibera LIKE crapsld.vlsddisp                   NO-UNDO.
DEF            VAR aux_vlsddisp LIKE crapsld.vlsddisp                   NO-UNDO.
DEF            VAR aux_flgctrsl AS LOGICAL                              NO-UNDO.

DEF TEMP-TABLE tt-conta                                                 NO-UNDO
        FIELD situacao           as char format "x(21)"
        field tipo-conta         as char format "x(21)"
        field empresa            AS  char format "x(15)"
        field devolucoes         AS inte format "99"
        field agencia            AS char format "x(15)"
        field magnetico          as inte format "z9"
        field estouros           as inte format "zzz9"
        field folhas             as inte format "zzz,zz9"
        field identidade         AS CHAR
        field orgao              AS CHAR
        field cpfcgc             AS CHAR
        field disponivel         AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"
        FIELD bloqueado          AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"
        field bloq-praca         AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"
        field bloq-fora-praca    AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"
        field cheque-salario     AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"
        field saque-maximo       AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"
        field acerto-conta       AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"
        field db-cpmf            AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"
        field limite-credito     AS DEC
        field ult-atualizacao    AS DATE
        field saldo-total        AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"
        FIELD nome-tit           AS CHAR
        FIELD nome-seg-tit       AS CHAR.
/* .......................................................................... */
