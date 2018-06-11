/* .............................................................................

   Programa: Includes/var_lanemp.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 14/02/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criar variaveis e forms para a tela LANEMP.

   Alteracoes: 29/01/97 - Alterar a ordem dos campos Documento Contrato (Odair)

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               13/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

             08/05/2002 - Qdo prejuizo critica de valores lancados (Margarete)

             06/10/2003 - Corrigir critica do histor 391 (Margarete).

             27/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                          (Evandro).
                          
             27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
             
             09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                          glb_cdcooper) no "CAN-FIND" da tabela CRAPHIS. 
                        - Kbase IT Solutions - Paulo Ricardo Maciel.
                        
             15/01/2009 - Alteracao cdempres (Diego).
             
             06/07/2009 - Incluir variavel tab_cdlcrbol - Linha de credito para
                          emprestimos com emissao de boletos (Fernando).
                        - Incluir frame f_nrboleto (Guilherme).
                        
             23/11/2009 - Alteracao Codigo Historico (Kbase).       
             
             26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                          para crapbcl (Adriano). 
             
             06/12/2011 - Incluido as variaveis aux_dtrefere  e aux_vlr_arrasto
                          (Elton). 
                          
             09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).                
             
             16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                          nao cadastrado.". (Reinert)
              
             21/01/2015 - Alterado o formato do campo nrctremp para 8 
                          caracters (Kelvin - 233714)

             10/03/2015 - Alterado o formato do campo nrdocmto para 10
                          posicoes. (Jaison/Gielow - SD: 263692)
                          
             15/08/2016 - Inclusa a declaracao da variavel ant_vlsdprej (Renato Darosci - M176).

			 23/09/2016 - Inclusao da variavel aux_flgativo, Prj. 302 (Jean Michel).

             14/02/2017 - Inclusao da variavel aux_flgretativo e aux_flgretquitado. 
                          (Jaison/James - PRJ302)

		     11/06/2018 - ajuste para o nrlote permitir 7 digitos (Alcemir - Mout's)- (INC0017046) .

............................................................................. */

DEF {1} SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR tel_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_nrdolote AS INT     FORMAT "zzzz,zz9"            NO-UNDO.
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
DEF {1} SHARED VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR tel_nrctremp AS INT     FORMAT "zz,zzz,zz9"          NO-UNDO.
DEF {1} SHARED VAR tel_nrdocmto AS DECIMAL FORMAT "z,zzz,zzz,zz9"       NO-UNDO.
DEF {1} SHARED VAR tel_vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_reganter AS CHAR    FORMAT "x(70)" EXTENT 6      NO-UNDO.

DEF {1} SHARED VAR tab_diapagto AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tab_dtcalcul AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR tab_inusatab AS LOGICAL                              NO-UNDO.

DEF {1} SHARED VAR tab_cdlcrbol AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tel_nrboleto AS INT     FORMAT "zzz,zzz,9"           NO-UNDO.

DEF {1} SHARED VAR aux_dtmvtolt AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR aux_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR aux_nrdolote AS INT     FORMAT "zzzz,zz9"            NO-UNDO.
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

DEF {1} SHARED VAR aux_flgerros AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgretor AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgdodia AS LOGICAL INIT TRUE  /* MFX do dia */  NO-UNDO.
DEF {1} SHARED VAR aux_regexist AS LOGICAL                              NO-UNDO.

DEF {1} SHARED VAR aux_contador AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_cddopcao AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_cdhistor AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdocmto AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_vllanmto AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR aux_indebcre AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_inhistor AS INT                                  NO-UNDO.
DEF {1} SHARED VAR ant_vlsdprej AS DECIMAL                              NO-UNDO.

DEF {1} SHARED VAR aux_dtcalcul AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_dtultdia AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_dtmesant AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_dtultpag AS DATE                                 NO-UNDO.

DEF {1} SHARED VAR aux_inliquid AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdconta AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrctatos AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrctremp AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrultdia AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdiacal AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdiames AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdiamss AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_ddlanmto AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_qtprepag AS INT     FORMAT "zz9"                 NO-UNDO.

DEF {1} SHARED VAR aux_vljurmes AS DECIMAL FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF {1} SHARED VAR aux_vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF {1} SHARED VAR aux_vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_vlprepag AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_txdjuros AS DECIMAL DECIMALS 7                   NO-UNDO.
DEF {1} SHARED VAR aux_vlrpagos AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR aux_vlacresc AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.

DEF {1} SHARED VAR aux_inhst093 AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_cdempres AS INTEGER                              NO-UNDO.
DEF {1} SHARED VAR flg_next     AS LOGICAL                              NO-UNDO.

DEF {1} SHARED VAR aux_dtrefere    AS DATE                              NO-UNDO.
DEF {1} SHARED VAR aux_vlr_arrasto AS DECI                              NO-UNDO.

DEF {1} SHARED VAR aux_flgretativo   AS INTEGER                         NO-UNDO.
DEF {1} SHARED VAR aux_flgretquitado AS INTEGER                         NO-UNDO.

DEF {1} SHARED FRAME f_lanemp.
DEF {1} SHARED FRAME f_regant.
DEF {1} SHARED FRAME f_lanctos.

FORM SPACE(1) WITH ROW 4 OVERLAY 16 DOWN WIDTH 80
                   TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E ou I)"
                        VALIDATE(CAN-DO("A,C,E,I",glb_cddopcao),
                                 "014 - Opcao errada.")

     tel_dtmvtolt AT 12 LABEL "Data"
     tel_cdagenci AT 31 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o codigo do PA."
                        VALIDATE(CAN-FIND (crapage WHERE 
                                           crapage.cdcooper = glb_cdcooper AND
                                           crapage.cdagenci =
                                 tel_cdagenci),"962 - PA nao cadastrado.")

     tel_cdbccxlt AT 47 LABEL "Banco/Caixa" AUTO-RETURN
                        HELP "Entre com o codigo do Banco/Caixa."
                        VALIDATE(CAN-FIND (crapbcl WHERE crapbcl.cdbccxlt =
                                 tel_cdbccxlt),"057 - Banco nao cadastrado.")

     tel_nrdolote AT 65 LABEL "Lote" AUTO-RETURN
                        HELP "Entre com o numero do lote."
                        VALIDATE(tel_nrdolote > 0,
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
     "Hist    Conta/dv       Documento   Contrato" AT  5
     "Valor     Seq."                           AT 61
     SKIP(1)
     tel_cdhistor AT  5 NO-LABEL AUTO-RETURN
                        HELP "Entre com o codigo do historico."
                        VALIDATE(tel_cdhistor > 0 AND
                                 CAN-FIND(craphis WHERE 
                                          craphis.cdcooper = glb_cdcooper AND
                                          craphis.cdhistor = tel_cdhistor),
                                          "093 - Historico errado.")

     tel_nrdconta AT 11 NO-LABEL AUTO-RETURN
                        HELP "Informe o numero da conta do associado."

     tel_nrdocmto AT 24 NO-LABEL AUTO-RETURN
                        HELP "Entre com o numero do documento."

     tel_nrctremp AT 38 NO-LABEL
                        HELP "Informe o numero do contrato de emprestimo."

     tel_vllanmto AT 48 NO-LABEL AUTO-RETURN
                        HELP "Entre com o valor do lancamento."
                        VALIDATE(tel_vllanmto > 0,
                                 "091 - Valor do lancamento errado.")

     tel_nrseqdig AT 69 NO-LABEL
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_lanemp.

FORM tel_reganter[1] AT  6 NO-LABEL  tel_reganter[2] AT  6 NO-LABEL
     tel_reganter[3] AT  6 NO-LABEL  tel_reganter[4] AT  6 NO-LABEL
     tel_reganter[5] AT  6 NO-LABEL  tel_reganter[6] AT  6 NO-LABEL
     WITH ROW 15 COLUMN 2 OVERLAY NO-BOX FRAME f_regant.

FORM craplem.cdhistor AT  6  craplem.nrdconta AT 11
     craplem.nrdocmto AT 24  FORMAT "z,zzz,zzz,zz9"
     craplem.nrctremp AT 38  FORMAT "z,zzz,zz9"
     craplem.vllanmto AT 48  craplem.nrseqdig AT 68
     WITH ROW 15 COLUMN 2 OVERLAY NO-LABEL NO-BOX 6 DOWN FRAME f_lanctos.
     
FORM tel_nrboleto    LABEL "  Referente ao boleto NRO."
                     HELP "Informe o numero do boleto de emprestimo."
     WITH ROW 16 CENTERED OVERLAY SIDE-LABELS FRAME f_nrboleto.

/* .......................................................................... */
