/* .............................................................................

   Programa: Fontes/rellot.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Setembro/94.                        Ultima atualizacao: 17/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela RELLOT -- Listar os lotes digitados no dia.

   Alteracao : 30/11/94 - Alterado para permitir a consulta dos lotes tipo
                          10 e 11 (Odair).

               29/05/95 - Alterado para nao mostrar a data do debito (Deborah)

               21/06/95 - Alterado para mostrar lote tipo 12 (Odair).

               21/02/96 - Alterado para incluir PAC na tela e mostrar tipo de
                          lote 13 (Odair).

               11/04/96 - Permitir a consulta de lotes 14 (Odair)

               19/12/96 - Permitir a consulta de lotes 15 (Deborah).

               15/04/97 - Permitir a consulta de lotes 16 e 17 (Deborah).

               26/11/97 - Permitir a consulta de lotes 18 (Odair)

               08/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               16/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               05/01/2001 - Tratar tipo de lote 21 (Deborah).

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               17/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)                            
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_difecrdb AS CHAR    FORMAT "x(1)"                 NO-UNDO.
DEF        VAR tel_tplotmov AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_tplotmov AT  2 LABEL "Tipo de lote" AUTO-RETURN
                        HELP  "Entre com o tipo de lote: DE 0 ATE 27."
                        VALIDATE (tel_tplotmov < 28,
                                  "062 - Tipo de lote errado.")
     tel_cdagenci AT 24 LABEL "PA"
                        HELP "Entre com o codigo do PA."
                        VALIDATE(CAN-FIND(crapage WHERE
                                          crapage.cdcooper = glb_cdcooper AND
                                          crapage.cdagenci = tel_cdagenci) OR
                                          tel_cdagenci = 0 ,
                                          "962 - PA nao cadastrado.")

     SKIP(1)
     "Tp  PA  Bco     Lote  Lanct.    Total a Credito     Total a Debito" AT 02
     "Df "                                                               AT 70
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_rellot.

FORM craplot.tplotmov AT  2   FORMAT        "z9"
     craplot.cdagenci AT  6
     craplot.cdbccxlt AT 11
     craplot.nrdolote AT 16   FORMAT        "zzz,zz9"
     craplot.qtinfoln AT 25
     craplot.vlinfocr AT 32
     craplot.vlinfodb AT 51
     tel_difecrdb     AT 70     /* sinal diferenca credito debito */
  /* craplot.dtmvtopg AT 70 */
     WITH ROW 10 COLUMN 2 OVERLAY 10 DOWN NO-LABEL NO-BOX FRAME f_lotes.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_rellot NO-PAUSE.
               CLEAR FRAME f_lotes ALL NO-PAUSE.
               glb_cdcritic = 0.
           END.

      UPDATE tel_tplotmov  tel_cdagenci WITH FRAME f_rellot

      EDITING:

         aux_stimeout = 0.

         DO WHILE TRUE:

            READKEY PAUSE 1.

            IF   LASTKEY = -1   THEN
                 DO:
                     aux_stimeout = aux_stimeout + 1.

                     IF   aux_stimeout > glb_stimeout   THEN
                          QUIT.

                     NEXT.
                 END.

            APPLY LASTKEY.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

      END.  /*  Fim do EDITING  */

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "RELLOT"   THEN
                 DO:
                     HIDE FRAME f_rellot.
                     HIDE FRAME f_lotes.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

   CLEAR FRAME f_lotes ALL NO-PAUSE.

   ASSIGN aux_regexist = FALSE
          aux_flgretor = FALSE
          aux_contador = 0.

   FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper AND 
                          craplot.dtmvtolt = glb_dtmvtolt
                          NO-LOCK:

       IF   tel_tplotmov <> 0 THEN    /* Compara se e um lote especifico */
            IF   craplot.tplotmov  <>  tel_tplotmov  THEN
                 NEXT.

       IF   tel_cdagenci <> 0 THEN    /* Compara se e um PAC especifico */
            IF   craplot.cdagenci  <>  tel_cdagenci THEN
                 NEXT.

       ASSIGN aux_regexist = TRUE
              aux_contador = aux_contador + 1.

       IF   aux_contador = 1   THEN
            IF   aux_flgretor   THEN
                 DO:
                     PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                     CLEAR FRAME f_lotes ALL NO-PAUSE.
                 END.
            ELSE
                 aux_flgretor = TRUE.

       IF   craplot.vlinfocr < craplot.vlcompcr   OR
            craplot.vlinfodb < craplot.vlcompdb   OR
            craplot.qtinfoln < craplot.qtcompln   THEN
            tel_difecrdb = "+".
       ELSE
       IF   craplot.vlinfocr > craplot.vlcompcr   OR
            craplot.vlinfodb > craplot.vlcompdb   OR
            craplot.qtinfoln > craplot.qtcompln   THEN
            tel_difecrdb = "-".
       ELSE
            tel_difecrdb = "".

       DISPLAY   craplot.tplotmov   craplot.cdagenci   craplot.cdbccxlt
                 craplot.nrdolote   craplot.qtinfoln   craplot.vlinfocr
                 craplot.vlinfodb   tel_difecrdb   /*  craplot.dtmvtopg  */
                 WITH FRAME f_lotes.

       IF   aux_contador = 10   THEN
            aux_contador = 0.
       ELSE
            DOWN WITH FRAME f_lotes.

   END.  /*  Fim do FOR EACH  --  Leitura dos lotes automaticos  */

   IF   NOT aux_regexist   THEN
        DO:
            glb_cdcritic = 60.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
