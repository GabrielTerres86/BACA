/* .............................................................................

   Programa: includes/var_lanlci.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Setembro/2004.                    Ultima atualizacao: 12/05/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Definicao das variaveis e forms da tela LANLCI.

   Alteracoes: 27/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               03/02/2005 - Permitir transferencia entre Contas de Invest.
                            (Mirtes/Evandro).
                            
               10/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               23/11/2009 - Alteracao Codigo Historico (Kbase).
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano).
                            
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas). 
               
               16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)
               
			   12/05/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).
               
............................................................................ */
DEF BUFFER crabass5 FOR crapass.
DEF BUFFER crabhis  FOR craphis.

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
DEF {1} SHARED VAR tel_cdhistor AS INT     FORMAT "zzz9"                NO-UNDO.
DEF {1} SHARED VAR tel_nrctainv AS INT     FORMAT "zz,zzz,zzz,9"        NO-UNDO.
DEF {1} SHARED VAR tel_nrdocmto AS DECIMAL FORMAT "zz,zzz,zzz,zzz,zz9"  NO-UNDO.
DEF {1} SHARED VAR tel_vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_dtliblan AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_reganter AS CHAR    FORMAT "x(74)" EXTENT 6      NO-UNDO.
DEF {1} SHARED VAR tel_cdalinea AS INT     FORMAT "zz"                  NO-UNDO.
DEF {1} SHARED VAR tel_nrautdoc LIKE craplcm.nrautdoc                   NO-UNDO.
DEF {1} SHARED VAR aux_cddopcao AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR tel_nrctainv_dest AS INT FORMAT "zz,zzz,zzz,9"       NO-UNDO.
 

DEF {1} SHARED VAR aut_flgsenha AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aut_cdoperad AS CHAR                                 NO-UNDO.


DEF {1} SHARED FRAME f_lanlci.
DEF {1} SHARED FRAME f_regant.
DEF {1} SHARED FRAME f_lanctos.

FORM    SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80 
                      TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C, E ou I)"
                        VALIDATE (glb_cddopcao = "C" OR glb_cddopcao = "E" OR
                                  glb_cddopcao = "I","014 - Opcao errada.")

     tel_dtmvtolt AT 12 LABEL "Data"
     tel_cdagenci AT 31 LABEL "PA"
                        HELP "Entre com o codigo do PA."
                        VALIDATE (CAN-FIND (crapage WHERE 
                                            crapage.cdcooper = glb_cdcooper AND
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
                   
     " Hst   Conta Inv.          Documento              Valor          Seq." AT 2
     SKIP(1)
     tel_cdhistor AT  2 NO-LABEL
                        HELP "Entre com o codigo do historico."
                        VALIDATE (tel_cdhistor = 485 OR tel_cdhistor = 486 OR
                                  tel_cdhistor = 487 OR
                                  tel_cdhistor = 647,"093 - Historico errado.")

     tel_nrctainv AT  7 NO-LABEL
                        HELP "Informe o numero da Conta de Inv. do associado."

     tel_nrdocmto AT 20 NO-LABEL
                        HELP "Entre com o numero do documento."
                         
     tel_vllanmto AT 39 NO-LABEL   AUTO-RETURN
                        HELP "Entre com o valor do lancamento."
                        VALIDATE (tel_vllanmto > 0,
                                  "091 - Valor do lancamento errado.")
/*
     tel_dtliblan AT 57 NO-LABEL
                        HELP "Entre com a data de liberacao."

     tel_cdalinea AT 71 NO-LABEL
                        HELP "Entre com o codigo da alinea de devolucao"
*/

     tel_nrseqdig AT 64 NO-LABEL
  
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_lanlci.

FORM SKIP(1)
     tel_nrctainv_dest AT 8 LABEL "Conta Inv. Destino"
         HELP "Informe o nro. da Conta de Investimentos que recebera o valor."
     SKIP(1)
     WITH SIDE-LABELS ROW 15 COLUMN 2 SIZE 78 BY 6 OVERLAY NO-BOX
          FRAME f_destino.
     
FORM tel_reganter[1] AT 2 NO-LABEL  tel_reganter[2] AT 2 NO-LABEL
     tel_reganter[3] AT 2 NO-LABEL  tel_reganter[4] AT 2 NO-LABEL
     tel_reganter[5] AT 2 NO-LABEL  tel_reganter[6] AT 2 NO-LABEL
     WITH ROW 15 COLUMN 2 OVERLAY NO-BOX FRAME f_regant.

/****** Variaveis para tratamento da Compensacao Eletronica ****/
DEF TEMP-TABLE w-compel NO-UNDO
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
    FIELD nrtalchq AS INTE    FORMAT "zz,zz9"
    FIELD nrdocmto AS DECIMAL FORMAT "zzz,zzz,9"
    FIELD nrdoclcm LIKE craplcm.nrdocmto
    FIELD nrposchq AS INTE
    INDEX compel1 AS UNIQUE PRIMARY
          dsdocmc7
    INDEX compel2 AS UNIQUE
          nrseqdig DESCENDING.

DEF {1} SHARED VAR aux_ctpsqitg LIKE craplcm.nrdctabb                   NO-UNDO.
DEF {1} SHARED VAR aux_nrdctitg LIKE crapass.nrdctitg                   NO-UNDO.
DEF {1} SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"                NO-UNDO.
DEF {1} SHARED VAR aux_nrctaass AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR aux_lsconta1 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_lsconta2 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_lsconta3 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_nrdocmto AS DECIMAL                              NO-UNDO.
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
DEF {1} SHARED VAR aux_nrcpfcgc1 LIKE crapttl.nrcpfcgc				    NO-UNDO.
DEF {1} SHARED VAR aux_nrcpfcgc2 LIKE crapttl.nrcpfcgc				    NO-UNDO.

DEF {1} SHARED FRAME f_compel.
DEF {1} SHARED FRAME f_lanctos_compel.

FORM tel_vlcompel AT  6 LABEL "Valor"
                        VALIDATE(tel_vlcompel <> 0,
                                 "269 - Valor errado.")
     tel_dsdocmc7 AT 32 LABEL "CMC-7"
     SPACE(6) SKIP(1)
     "Comp  Bco   Ag. C1          Conta C2   Cheque C3" AT 3 
     SPACE(11) 
/*     "Valor   Liberacao"*/
     "Valor"
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
/*...........................................................................*/
