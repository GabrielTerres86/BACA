/* .............................................................................
   Programa: Includes/var_lanrda.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/94                     Ultima atualizacao: 16/01/2014

   Objetivo  : Definicao das variaveis e forms da tela LANRDA.

   Alteracoes: 19/11/97 - Alterado para tratar RDCA 30 ESPECIAL (Edson).

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               13/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
             20/04/2004 - Tratar modo de impressao do extrato (Margarete).   
              
             02/09/2004 - Incluido Flag Conta Investimento(Mirtes).
             
             09/09/2004 - Incluido Flag Debitar Conta Investimento (Evandro).

             27/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                          (Evandro).
                          
             01/02/2006 - Unificacao dos Bancos - SQLWorks - Andre
             
             26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                          para crapbcl (Adriano).
                          
             09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).
             
             16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                          nao cadastrado.". (Reinert)
............................................................................. */

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

DEF {1} SHARED VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR tel_tpaplica AS INT     FORMAT "9"                   NO-UNDO.
DEF {1} SHARED VAR tel_nrdocmto AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_vllanmto AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_reganter AS CHAR    FORMAT "x(75)" EXTENT 6      NO-UNDO.
DEF {1} SHARED VAR tel_tpemiext AS INTE    FORMAT "9"                   NO-UNDO.

DEF {1} SHARED VAR tel_flgctain AS LOG     FORMAT "S/N"                 NO-UNDO.
DEF {1} SHARED VAR tel_flgdebci AS LOGICAL FORMAT "S/N"                 NO-UNDO.
DEF {1} SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"                NO-UNDO.
DEF {1} SHARED VAR aux_cddopcao AS CHAR                                 NO-UNDO.

DEF {1} SHARED VAR aux_contador AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_cdhistor AS INT                                  NO-UNDO.

DEF {1} SHARED VAR aux_flgerros AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgretor AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgdodia AS LOGICAL INIT TRUE  /* MFX do dia */  NO-UNDO.
DEF {1} SHARED VAR aux_regexist AS LOGICAL                              NO-UNDO.

DEF {1} SHARED VAR aux_dtfimper AS DATE                                 NO-UNDO.

DEF {1} SHARED VAR aux_flgctain AS CHAR    FORMAT "x(01)"               NO-UNDO.
DEF {1} SHARED VAR aux_flgdebci AS CHAR    FORMAT "x(01)"               NO-UNDO.

DEF {1} SHARED FRAME f_lanrda.
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
                        VALIDATE(CAN-FIND (crapage WHERE crapage.cdcooper =
                                                             glb_cdcooper AND
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
  "Tp.A.     Conta/dv   Aplicacao  CI   Saldo CI           Valor  Extrato  Seq."
     AT 02
     SKIP(1)
     tel_tpaplica AT 04 NO-LABEL
         HELP "Tipo de Aplicacao: 3-RDCA , 5-RDCA60, 6-RDCA 30 ESPECIAL"
                        VALIDATE(CAN-DO("3,5,6",STRING(tel_tpaplica)),
                                 "346 - Tipo de aplicacao errado.")

     tel_nrdconta AT 10 NO-LABEL AUTO-RETURN
                        HELP "Entre com o numero da conta do associado."

     tel_nrdocmto AT 25 NO-LABEL AUTO-RETURN
                        HELP "Entre com o numero do contrato da aplicacao."

     tel_flgctain AT 35 NO-LABEL AUTO-RETURN
                        HELP "Entre com S/N - Conta Investimento"

     tel_flgdebci AT 42 NO-LABEL AUTO-RETURN
                        HELP "Debitar Conta Investimento (S/N)"
                        
     tel_vllanmto AT 49 NO-LABEL AUTO-RETURN
                        HELP "Entre com o valor da aplicacao."
                        VALIDATE(tel_vllanmto > 0,
                                 "269 - Valor errado.")

     tel_tpemiext AT 69 NO-LABEL AUTO-RETURN
             HELP "Como receber o extrato. (1-individual,2-todas,3-nao emit)"
                  VALIDATE((tel_tpemiext > 0  AND
                           tel_tpemiext < 4),
                           "269 - Valor errado.")
                           
     tel_nrseqdig AT 71 NO-LABEL
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_lanrda.

FORM tel_reganter[1] AT 03 NO-LABEL
     tel_reganter[2] AT 03 NO-LABEL
     tel_reganter[3] AT 03 NO-LABEL
     tel_reganter[4] AT 03 NO-LABEL
     tel_reganter[5] AT 03 NO-LABEL
     tel_reganter[6] AT 03 NO-LABEL
     WITH ROW 15 COLUMN 3 OVERLAY NO-BOX FRAME f_regant.

FORM craprda.tpaplica AT 04
     craplap.nrdconta AT 10
     craplap.nrdocmto AT 25
     aux_flgctain     AT 35 
     craprda.flgdebci AT 42
     craplap.vllanmto AT 49 FORMAT "zzz,zzz,zz9.99"
     craprda.tpemiext AT 69
     craplap.nrseqdig AT 71
     WITH ROW 15 COLUMN  2 OVERLAY NO-LABEL NO-BOX  6 DOWN  FRAME f_lanctos.

/* .......................................................................... */
