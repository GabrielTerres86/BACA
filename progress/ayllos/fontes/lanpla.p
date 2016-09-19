/* .............................................................................

   Programa: Fontes/lanpla.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Julho/92                           Ultima atualizacao: 16/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANPLA.

   Alteracoes: 02/04/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               13/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               27/01/2005 - Mudado o LABEL do campo "tel_cdagenci" de "Agencia"
                            para "PAC";
                            HELP de "codigo da agencia." para "codigo do PAC.";
                            VALIDATE de "015 - Agencia nao cadastrada." para
                            "015 - PAC nao cadastrado." (Evandro).
                            
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 
                            
               05/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)                                                        

............................................................................. */

{ includes/var_online.i }

DEF NEW SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF NEW SHARED VAR tel_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF NEW SHARED VAR tel_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF NEW SHARED VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF NEW SHARED VAR tel_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF NEW SHARED VAR tel_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR tel_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR tel_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF NEW SHARED VAR tel_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR tel_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR tel_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF NEW SHARED VAR tel_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF NEW SHARED VAR tel_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF NEW SHARED VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF NEW SHARED VAR tel_vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF NEW SHARED VAR tel_reganter AS CHAR    FORMAT "x(50)" EXTENT 6      NO-UNDO.

DEF NEW SHARED VAR aux_nrmesant AS INT                                  NO-UNDO.
DEF NEW SHARED VAR aux_nrdconta AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF NEW SHARED VAR aux_dtmvtolt AS DATE                                 NO-UNDO.
DEF NEW SHARED VAR aux_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF NEW SHARED VAR aux_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF NEW SHARED VAR aux_nrdolote AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF NEW SHARED VAR aux_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF NEW SHARED VAR aux_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR aux_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR aux_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF NEW SHARED VAR aux_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR aux_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR aux_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF NEW SHARED VAR aux_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF NEW SHARED VAR aux_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF NEW SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"                NO-UNDO.
DEF NEW SHARED VAR aux_flgerros AS LOGICAL                              NO-UNDO.
DEF NEW SHARED VAR aux_flgretor AS LOGICAL                              NO-UNDO.
DEF NEW SHARED VAR aux_regexist AS LOGICAL                              NO-UNDO.
DEF NEW SHARED VAR aux_contador AS INT                                  NO-UNDO.
DEF NEW SHARED VAR aux_cddopcao AS CHAR                                 NO-UNDO.
DEF NEW SHARED VAR aux_vllanmto AS DECIMAL                              NO-UNDO.

DEF NEW SHARED FRAME f_lanpla.
DEF NEW SHARED FRAME f_regant.
DEF NEW SHARED FRAME f_lanctos.

FORM    SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE COLOR MESSAGE " Lancamentos de Planos "
                      FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E ou I)"
                        VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR glb_cddopcao = "I",
                                  "014 - Opcao errada.")

     tel_dtmvtolt AT 12 LABEL "Data"
     tel_cdagenci AT 32 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o codigo do PA."
                        VALIDATE (CAN-FIND (crapage WHERE crapage.cdcooper =
                                                             glb_cdcooper AND
                                                          crapage.cdagenci =
                                  tel_cdagenci),"962 - PA nao cadastrado.")

     tel_cdbccxlt AT 47 LABEL "Banco/Caixa" AUTO-RETURN
                        HELP "Entre com o codigo do Banco/Caixa."
                        VALIDATE (CAN-FIND (crapbcl WHERE crapbcl.cdbccxlt =
                                  tel_cdbccxlt),"057 - Banco nao cadastrado.")

     tel_nrdolote AT 65 LABEL "Lote" AUTO-RETURN
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
     "Conta/dv                  Valor        Seq." AT 19
     SKIP(1)
     tel_nrdconta AT 17 NO-LABEL AUTO-RETURN
                        HELP "Informe o numero da conta do associado."

     tel_vllanmto AT 32 NO-LABEL AUTO-RETURN
                        HELP "Entre com o valor do lancamento."

     tel_nrseqdig AT 56 NO-LABEL

     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_lanpla.

FORM tel_reganter[1] AT 17 NO-LABEL  tel_reganter[2] AT 17 NO-LABEL
     tel_reganter[3] AT 17 NO-LABEL  tel_reganter[4] AT 17 NO-LABEL
     tel_reganter[5] AT 17 NO-LABEL  tel_reganter[6] AT 17 NO-LABEL
     WITH ROW 15 COLUMN 2 OVERLAY NO-BOX FRAME f_regant.

FORM tel_nrdconta AT 17  tel_vllanmto AT 32
     tel_nrseqdig AT 56
     WITH ROW 15 COLUMN 2 OVERLAY NO-LABEL NO-BOX 6 DOWN FRAME f_lanctos.

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "I"
       tel_nrdconta = 0
       tel_vllanmto = 0
       tel_nrseqdig = 1
       tel_dtmvtolt = glb_dtmvtolt

       aux_flgretor = FALSE

       aux_nrmesant = IF MONTH(glb_dtmvtolt) = 1
                         THEN 12
                         ELSE MONTH(glb_dtmvtolt) - 1.

IF   glb_nmtelant = "LOTE"   THEN
     ASSIGN tel_cdagenci = glb_cdagenci
            tel_cdbccxlt = glb_cdbccxlt
            tel_nrdolote = glb_nrdolote.

PAUSE(0).

DISPLAY glb_cddopcao  tel_dtmvtolt  tel_cdagenci  tel_cdbccxlt
        tel_nrdolote  tel_nrdconta  tel_vllanmto  tel_nrseqdig
        WITH FRAME f_lanpla.

CLEAR FRAME f_regant NO-PAUSE.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   NOT aux_flgretor   THEN
           IF   tel_cdagenci <> 0   AND
                tel_cdbccxlt <> 0   AND
                tel_nrdolote <> 0   THEN
                LEAVE.

      SET glb_cddopcao tel_cdagenci tel_cdbccxlt tel_nrdolote
          WITH FRAME f_lanpla.

      LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "LANPLA"   THEN
                 DO:
                     HIDE FRAME f_lanpla.
                     HIDE FRAME f_regant.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   ASSIGN aux_dtmvtolt = tel_dtmvtolt
          aux_cdagenci = tel_cdagenci
          aux_cdbccxlt = tel_cdbccxlt
          aux_nrdolote = tel_nrdolote
          aux_flgretor = TRUE.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   INPUT glb_cddopcao = "A" THEN
        DO:
            RUN fontes/lanplaa.p.
        END.
   ELSE
        IF   INPUT glb_cddopcao = "C" THEN
             DO:
                 RUN fontes/lanplac.p.
             END.
        ELSE
             IF   INPUT glb_cddopcao = "E"   THEN
                  DO:
                      RUN fontes/lanplae.p.
                  END.
             ELSE
                  IF   INPUT glb_cddopcao = "I"   THEN
                       DO:
                           RUN fontes/lanplai.p.
                       END.

   IF   glb_nmdatela = "LOTE"   THEN
        DO:
            HIDE FRAME f_lanpla.
            HIDE FRAME f_regant.
            HIDE FRAME f_lanctos.
            HIDE FRAME f_moldura.
            RETURN.                        /* Retorna a tela LOTE */
        END.
   ELSE
        aux_flgretor = TRUE.

END.

/* .......................................................................... */
