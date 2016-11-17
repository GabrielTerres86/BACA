/* .............................................................................

   Programa: Includes/var_lanbdc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                     Ultima atualizacao: 16/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criar variaveis e forms para a tela lanbdc.

   Alteracoes: 23/10/2000 - Incluir tratamento da opcao T - Troca data da
                            custodia (lote inteiro) - Edson

               13/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               25/09/2001 - Inclusao de novas variaveis e alteracao de layout
                            da tela lanbdc (Junior).

               20/03/2003 - Incluir tratamento da Concredi (Margarete).

               27/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               16/05/2005 - Tratamento Conta Integracao(Mirtes)

               30/11/2005 - Criacao da variavel aux_nrdigitg (Edson).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               15/07/2008 - Variaveis para preju (Magui).
               
               08/07/2010 - Tratamento para Compe 085 (Ze). 
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 
                            
               29/11/2011 - Adicionado tratamento para não permitir data de 
                            liberação para último dia útil do Ano (Ze).
                           
               20/09/2013 - Alteracao de PAC/P.A.C para PA. (James)             
               
               16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)
............................................................................. */

DEF {1} SHARED VAR shr_dsnacion AS CHAR FORMAT "x(15)"                  NO-UNDO.
DEF {1} SHARED VAR shr_inpessoa AS INT                                  NO-UNDO.

DEF {1} SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR tel_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF {1} SHARED VAR tel_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.

DEF {1} SHARED VAR tel_cdcmpchq AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_cdbanchq AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_cdagechq AS INT     FORMAT "zzz9"                NO-UNDO.
DEF {1} SHARED VAR tel_nrddigc1 AS INT     FORMAT "9"                   NO-UNDO.
DEF {1} SHARED VAR tel_nrctachq AS DECIMAL FORMAT "zzz,zzz,zzz,9"       NO-UNDO.
DEF {1} SHARED VAR tel_nrddigc2 AS INT     FORMAT "9"                   NO-UNDO.
DEF {1} SHARED VAR tel_nrcheque AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_nrddigc3 AS INT     FORMAT "9"                   NO-UNDO.
DEF {1} SHARED VAR tel_vlcheque AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_nrborder AS INT     FORMAT "zzz,zz9"             NO-UNDO.

DEF {1} SHARED VAR tel_nrcustod AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR tel_nmcustod AS CHAR    FORMAT "x(40)"               NO-UNDO.
DEF {1} SHARED VAR tel_dtlibera AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR tel_dsdocmc7 AS CHAR    FORMAT "x(34)"               NO-UNDO.

DEF {1} SHARED VAR aux_nrdigitg AS CHAR                                 NO-UNDO.

DEF {1} SHARED VAR tel_reganter AS CHAR    FORMAT "x(76)" EXTENT 2      NO-UNDO.

DEF {1} SHARED VAR tab_intracst AS INTEGER                              NO-UNDO.
DEF {1} SHARED VAR tab_inchqcop AS INTEGER                              NO-UNDO.

DEF {1} SHARED VAR fav_nrcpfcgc AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR fav_inpessoa AS INT                                  NO-UNDO.
DEF {1} SHARED VAR fav_nrdconta LIKE crapass.nrdconta                   NO-UNDO.
DEF {1} SHARED VAR aux_dtmvtolt AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_dtlibera AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR aux_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR aux_nrdolote AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR aux_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR aux_nmprimtl AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_nrcpfcgc AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR aux_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR aux_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF {1} SHARED VAR aux_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"                NO-UNDO.

DEF {1} SHARED VAR aux_flgerros AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgretor AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_regexist AS LOGICAL                              NO-UNDO.

DEF {1} SHARED VAR aux_contador AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdconta AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdctabb AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrtalchq AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdocmto AS INT                                  NO-UNDO.

DEF {1} SHARED VAR aux_cddopcao AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_cdagebcb AS INT                                  NO-UNDO.

DEF {1} SHARED VAR aux_cdbcoctl AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_cdagectl AS INT                                  NO-UNDO.

DEF {1} SHARED VAR aux_lscontas AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_lsconta1 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_lsconta2 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_lsconta3 AS CHAR                                 NO-UNDO.

DEF {1} SHARED VAR aux_lsvalido AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_lsdigctr AS CHAR                                 NO-UNDO.

DEF {1} SHARED VAR tel_qtinfocc AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_qtinfoci AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_qtinfocs AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_vlinfocc AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR tel_vlinfoci AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR tel_vlinfocs AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.

DEF {1} SHARED VAR tel_qtdifecc AS INT     FORMAT "zzz,zz9-"            NO-UNDO.
DEF {1} SHARED VAR tel_qtdifeci AS INT     FORMAT "zzz,zz9-"            NO-UNDO.
DEF {1} SHARED VAR tel_qtdifecs AS INT     FORMAT "zzz,zz9-"            NO-UNDO.
DEF {1} SHARED VAR tel_vldifecc AS DECIMAL FORMAT "zz,zzz,zz9.99-"      NO-UNDO.
DEF {1} SHARED VAR tel_vldifeci AS DECIMAL FORMAT "zz,zzz,zz9.99-"      NO-UNDO.
DEF {1} SHARED VAR tel_vldifecs AS DECIMAL FORMAT "zz,zzz,zz9.99-"      NO-UNDO.

DEF {1} SHARED VAR tel_qtcompcc AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_qtcompci AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_qtcompcs AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_vlcompcc AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR tel_vlcompci AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR tel_vlcompcs AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.

DEF {1} SHARED VAR tel_nmemichq AS CHAR    FORMAT "x(40)"               NO-UNDO.
DEF {1} SHARED VAR tel_nrcpfchq AS DECIMAL FORMAT "zzzzzzzzzzzzz9"      NO-UNDO.

DEF {1} SHARED VAR ant_vlcheque AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.

DEF {1} SHARED VAR tab_vlchqmai AS DECIMAL                              NO-UNDO.

DEF {1} SHARED VAR tab_qtdiamin AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tab_qtdiamax AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tab_qtrenova AS INT                                  NO-UNDO.

DEF {1} SHARED VAR aux_nrctaass AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR aux_ctpsqitg AS DEC                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdctitg LIKE crapass.nrdctitg                   NO-UNDO.
DEF {1} SHARED VAR aux_flgpreju AS LOGICAL                              NO-UNDO.

DEF {1} SHARED VAR h-b1wgen0015 AS HANDLE                               NO-UNDO.
DEF {1} SHARED VAR aux_dtdialim AS DATE                                 NO-UNDO.

DEF {1} SHARED FRAME f_lanbdc.
DEF {1} SHARED FRAME f_regant.
DEF {1} SHARED FRAME f_lanctos.

DEF BUFFER crabass5 FOR crapass.

aux_lsvalido = "1,2,3,4,5,6,7,8,9,0,G,<,>,:," +
               "RETURN,F4,CURSOR-LEFT,CURSOR-RIGHT".

FORM SPACE(1) WITH ROW 4 OVERLAY 16 DOWN WIDTH 80
                   TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                  HELP "Informe a opcao desejada (A, C, E, I ou R)"
                        VALIDATE(CAN-DO("A,C,E,I,R",glb_cddopcao),
                                 "014 - Opcao errada.")

     tel_dtmvtolt AT 12 LABEL "Data"
     tel_cdagenci AT 31 LABEL "PA"  AUTO-RETURN
                        HELP "Entre com o codigo do PA."
                        VALIDATE(CAN-FIND(crapage WHERE 
                                          crapage.cdcooper = glb_cdcooper AND
                                          crapage.cdagenci = tel_cdagenci),
                                          "962 - PA nao cadastrado.")

     tel_cdbccxlt AT 47 LABEL "Banco/Caixa" AUTO-RETURN
                        HELP "Entre com o codigo do Banco/Caixa."
                        VALIDATE(CAN-FIND(crapbcl WHERE 
                                          crapbcl.cdbccxlt = tel_cdbccxlt),
                                          "057 - Banco nao cadastrado.")

     tel_nrdolote AT 65 LABEL "Lote" AUTO-RETURN
                        HELP "Entre com o numero do lote."
                        VALIDATE(tel_nrdolote > 0,
                                "058 - Numero do lote errado.")
     SKIP
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
     tel_nrcustod AT  5 LABEL "Desconto para"   
                        HELP "Entre com a conta do associado."
                        VALIDATE(tel_nrcustod > 0,
                                 "127 - Conta errada.")
                                 
     tel_nmcustod AT 33 NO-LABEL
     SKIP
     tel_nrborder AT 11 LABEL "Bordero" FORMAT "zzzz,zzz,9"
     SKIP
     tel_dtlibera AT 10 LABEL "Bom para"
                        HELP "Entre com a data boa do cheque."
                        
     tel_dsdocmc7 AT 34 LABEL "CMC-7"
                        HELP "Passe o cheque pela leitora."
     SKIP(1)
     "Comp Bco  Ag. C1"    AT  2
     "Conta C2  Cheque C3" AT 27
     "Valor     Seq."      AT 63
     SKIP(1)
     tel_cdcmpchq AT 03 NO-LABEL
                        HELP "Entre com o numero de compensacao do cheque."
                        VALIDATE(tel_cdcmpchq > 0,
                                 "380 - Numero errado.")

     tel_cdbanchq AT 07 NO-LABEL
                        HELP "Entre com o numero do banco impresso no cheque."
                        VALIDATE(CAN-FIND(crapban WHERE
                                          crapban.cdbccxlt = tel_cdbanchq),
                                          "057 - Banco nao cadastrado.")
                                 
     tel_cdagechq AT 11 NO-LABEL
                        HELP "Entre com o codigo da agencia impresso no cheque."
                        VALIDATE(tel_cdagechq > 0,
                                 "089 - Agencia devera ser informada.")
     
     tel_nrddigc1 AT 17 NO-LABEL
                        HELP "Entre com o primeiro digito de controle (C1)."
                         
     tel_nrctachq AT 19 NO-LABEL
                        HELP "Entre com o numero da conta impresso no cheque."
                        VALIDATE(tel_nrctachq > 0,
                                 "127 - Conta errada.")
 
     tel_nrddigc2 AT 34 NO-LABEL
                        HELP "Entre com o segundo digito de controle (C2)."
                        
     tel_nrcheque AT 36 NO-LABEL
                        HELP "Entre com o numero do cheque."
                        VALIDATE(tel_nrcheque > 0,
                                 "380 - Numero errado.")
                         
     tel_nrddigc3 AT 45 NO-LABEL
                        HELP "Entre com o terceiro digito de controle (C3)."
                        
     tel_vlcheque AT 50 NO-LABEL
                        HELP "Entre com o valor do cheque."
                        VALIDATE(tel_vlcheque > 0,
                                 "269 - Valor errado.")
                         
     tel_nrseqdig AT 71 NO-LABEL
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_lanbdc.

FORM tel_reganter[1] AT  3 NO-LABEL  tel_reganter[2] AT  3 NO-LABEL
     WITH ROW 19 COLUMN 2 OVERLAY NO-BOX FRAME f_regant.

FORM crapcdb.cdcmpchq AT 03 FORMAT "zz9"                LABEL "Cmp"
     crapcdb.cdbanchq AT 07 FORMAT "zz9"                LABEL "Bco"
     crapcdb.cdagechq AT 11 FORMAT "zzz9"               LABEL "Ag."
     crapcdb.nrddigc1 AT 16 FORMAT "9"                  LABEL "C1"
     crapcdb.nrctachq AT 19 FORMAT "zzz,zzz,zzz,9"      LABEL "Conta"
     crapcdb.nrddigc2 AT 33 FORMAT "9"                  LABEL "C2"
     crapcdb.nrcheque AT 37 FORMAT "zzz,zz9"            LABEL "Cheque"
     crapcdb.nrddigc3 AT 45 FORMAT "9"                  LABEL "C3"
     crapcdb.vlcheque AT 50 FORMAT "zzz,zzz,zzz,zz9.99" LABEL "Valor"
     crapcdb.nrseqdig AT 71 FORMAT "zz,zz9"             LABEL "Seq." " "
     WITH ROW 8 COLUMN 2 OVERLAY NO-LABEL NO-BOX 11 DOWN FRAME f_lanctos.

FORM SKIP(1)
     tel_nmemichq LABEL "    Nome do emitente"   AT 3 "  "
     SKIP(1)
     tel_nrcpfchq LABEL "CPF/CNPJ do emitente"   AT 3
     SKIP(1)
     WITH ROW 15 CENTERED OVERLAY SIDE-LABEL TITLE " Dados do Emitente "
          FRAME f_emitente.

/* ......................................................................... */

