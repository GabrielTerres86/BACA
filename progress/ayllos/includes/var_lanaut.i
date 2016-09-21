/* .............................................................................

   Programa: Includes/var_lanaut.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson                       Ultima atualizacao: 16/01/2014
   Data    : Junho/95.

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criar as variaveis e frame da tela LANAUT.

   Alteracoes: 22/03/96 - Alterado para permitir lancar em feriados (Deborah).

               21/10/96 - Alterado para nao deixar com data <= movimento (Odair)

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               13/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               20/08/2001 - Tratar onze posicoes no numero do documento (Edson).

               21/09/2001 - Incluir opcao R (Margarete).

               27/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               25/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "CAN-FIND" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               16/01/2009 - Alteracao cdempres (Diego).
               
               23/11/2009 - Alteracao Codigo Historico (Kbase).
               
               16/03/2010 - Ajuste no help do historico para utilizar
                            o <F7> deste campo (Gabriel).
                            
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano).
                       
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).
               
               16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)
............................................................................. */

DEF        VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_cdbccxlt AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_qtinfoln AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF        VAR tel_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tel_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tel_qtcompln AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF        VAR tel_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tel_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tel_qtdifeln AS INT     FORMAT "zz,zz9-"              NO-UNDO.
DEF        VAR tel_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR tel_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR tel_cdhistor AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nrdocmto AS DECIMAL FORMAT "zz,zzz,zzz,zzz,zz9"   NO-UNDO.
DEF        VAR tel_tpdvalor AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_vllanaut AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tel_cdbccxpg AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF        VAR tel_dtmvtopg AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_reganter AS CHAR    FORMAT "x(76)" EXTENT 6       NO-UNDO.

DEF        VAR lot_cdhistor AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF        VAR lot_cdbccxpg AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR lot_dtmvtopg AS DATE                                  NO-UNDO.

DEF        VAR aux_nrseqdig AS INT     FORMAT "zzzz9"                NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR aux_nrdolote AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR aux_qtinfoln AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF        VAR aux_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR aux_qtcompln AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF        VAR aux_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR aux_qtdifeln AS INT     FORMAT "zz,zz9-"              NO-UNDO.
DEF        VAR aux_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR aux_cdhistor AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF        VAR aux_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR aux_nrtrfcta AS INT                                   NO-UNDO.
DEF        VAR aux_nrdocmto AS DECIMAL FORMAT "zz,zzz,zzz,zzz,zz9"   NO-UNDO.
DEF        VAR aux_tpdvalor AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_vllanaut AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR aux_cdbccxpg AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR aux_dtmvtopg AS DATE                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_flgerros AS LOGICAL                               NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.
DEF        VAR aux_cdempres AS INT                                   NO-UNDO.

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                   TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 02 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E , I ou R)"
                        VALIDATE(CAN-DO("A,C,E,I,R",glb_cddopcao),
                                 "014 - Opcao errada.")

     tel_dtmvtolt AT 12 LABEL "Data"
     tel_cdagenci AT 31 LABEL "PA" AUTO-RETURN
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
     SKIP(1)
     tel_qtinfoln AT 02 LABEL "Informado:Qtd"
     tel_vlinfodb AT 24 LABEL "Debito"
     tel_vlinfocr AT 51 LABEL "Credito"
     SKIP
     tel_qtcompln AT 02 LABEL "Computado:Qtd"
     tel_vlcompdb AT 24 LABEL "Debito"
     tel_vlcompcr AT 51 LABEL "Credito"
     SKIP
     tel_qtdifeln AT 02 LABEL "Diferenca:Qtd"
     tel_vldifedb AT 24 LABEL "Debito"
     tel_vldifecr AT 51 LABEL "Credito"
     SKIP(1)
     "Hist   Conta/dv          Documento" AT 02
     "Valor  Debito  Bco Pg.   Seq."  AT 50
     SKIP(1)
     tel_cdhistor AT 02 NO-LABEL AUTO-RETURN
                        HELP "Informe o codigo do historico ou <F7> p/ listar."
                        VALIDATE(CAN-FIND(craphis WHERE
                                          craphis.cdcooper = glb_cdcooper AND
                                          craphis.cdhistor = tel_cdhistor),
                                          "093 - Historico errado.")

     tel_nrdconta AT 07 NO-LABEL AUTO-RETURN
                        HELP "Informe o numero da conta do associado."

     tel_nrdocmto AT 18 NO-LABEL
                        HELP "Informe o numero do documento."

     tel_vllanaut AT 37 NO-LABEL AUTO-RETURN
                        HELP "Entre com o valor do lancamento."
                        VALIDATE(tel_vllanaut > 0,
                                 "091 - Valor do lancamento errado.")

     tel_dtmvtopg AT 57 NO-LABEL AUTO-RETURN
                        HELP "Entre com a data do pagamento."
                        VALIDATE(tel_dtmvtopg <> ? AND
                                 tel_dtmvtopg > glb_dtmvtolt,
                                 "013 - Data errada.")

     tel_cdbccxpg AT 69 NO-LABEL AUTO-RETURN
                        HELP "Entre com o banco de pagamento."
                        VALIDATE(CAN-FIND(crapban WHERE 
                                          crapban.cdbccxlt = tel_cdbccxpg),
                                          "057 - Banco nao cadastrado.")

     tel_nrseqdig AT 73 NO-LABEL AUTO-RETURN
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_lanaut.

FORM tel_reganter[1] AT 2 NO-LABEL  tel_reganter[2] AT 2 NO-LABEL
     tel_reganter[3] AT 2 NO-LABEL  tel_reganter[4] AT 2 NO-LABEL
     tel_reganter[5] AT 2 NO-LABEL  tel_reganter[6] AT 2 NO-LABEL
     WITH ROW 15 COLUMN 2 OVERLAY NO-BOX FRAME f_regant.

FORM craplau.cdhistor AT 02
     craplau.nrdconta AT 07
     craplau.nrdocmto AT 18 FORMAT "zz,zzz,zzz,zzz,zz9"
     craplau.vllanaut AT 37 FORMAT "zzz,zzz,zzz,zz9.99"
     craplau.dtmvtopg AT 57 FORMAT "99/99/9999"
     craplau.cdbccxpg AT 69
     craplau.nrseqdig AT 73
     WITH ROW 15 COLUMN 2 OVERLAY NO-LABEL NO-BOX 6 DOWN FRAME f_lanctos.

/* .......................................................................... */

