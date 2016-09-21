/* .............................................................................

   Programa: Fontes/lotreq.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/92                      Ultima Atualizacao: 05/09/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela lotreq.

   Alteracoes: 02/04/98 - Tratamento para milenio e troca para V8 (Magui).
   
               13/11/00 - Alterar nrdolote p/6 posicoes (Magui/Planner).
               
             11/12/2002 - Permitir lotes do novo caixa (Magui).

             07/02/2003 - Usar agencia e numero de lote para separar os
                          lotes (Magui).

             19/04/2004 - Nao permitir lotes do caixa on_line (Magui).

             12/11/2004 - Exibir o nome do operador (Evandro).

             07/12/2005 - Incluir tipo de requisicao na tela (Magui).

             30/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
             
             05/09/2013 - Nova forma de chamar as agências, de PAC agora 
                          a escrita será PA (André Euzébio - Supero).
                          
             11/07/2016 - Apresentar apenas opcao C, e incluir quantidades
                          de entrega de taloes.
                          PRJ290 – Caixa OnLine (Odirlei-AMcom)
                         
............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_qtdiferq AS INT     FORMAT "zz,zz9-"              NO-UNDO.
DEF        VAR tel_qtdifetl AS INT     FORMAT "zz,zz9-"              NO-UNDO.
DEF        VAR tel_qtdifeen AS INT     FORMAT "zz,zz9-"              NO-UNDO.
DEF        VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_cdagelot AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_dsagenci AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR tel_nmoperad AS CHAR    FORMAT "x(20)"                NO-UNDO.

DEF        VAR aux_nrdolote AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR aux_cdagelot AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_nrinital AS INT                                   NO-UNDO.
DEF        VAR aux_nrfintal AS INT                                   NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR    FORMAT "x(7)"                 NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgerros AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nrseqems AS INTE                                  NO-UNDO.
DEF        VAR aux_qttalent AS INTE                                  NO-UNDO.
DEF        VAR aux_num_cheque_inicial AS INTE                        NO-UNDO.
DEF        VAR aux_num_cheque_final   AS INTE                        NO-UNDO.
DEF        VAR aux_nrcheque           AS INTE                        NO-UNDO.
DEF        VAR aux_qtentreq_in        AS INTE     FORMAT "z,zz9-"   NO-UNDO.
DEF        VAR aux_qtentcar_in        AS INTE     FORMAT "z,zz9-"   NO-UNDO.
DEF        VAR aux_qtentreq           AS INTE     FORMAT "zz,zz9-"   NO-UNDO.
DEF        VAR aux_qtentcar           AS INTE     FORMAT "zz,zz9-"   NO-UNDO.
DEF        VAR aux_qtentdif_r         AS INTE     FORMAT "zz,zz9-"   NO-UNDO.
DEF        VAR aux_qtentdif_c         AS INTE     FORMAT "zz,zz9-"   NO-UNDO.


FORM SKIP (1)
     "Opcao:"     AT 3
     glb_cddopcao AT 10 NO-LABEL AUTO-RETURN
                  HELP "Informe a opcao desejada (C)."
                  VALIDATE (glb_cddopcao = "C","014 - Opcao errada.")                  
                  /* Apenas permite informar opcao C
                  HELP "Informe a opcao desejada (A, C, E ou I)."
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                            glb_cddopcao = "E" OR glb_cddopcao = "I",
                            "014 - Opcao errada.")*/
     SKIP (1)
     tel_cdagelot AT 4 LABEL "PA" AUTO-RETURN
                  HELP "Informe o numero do PA."
                  VALIDATE (CAN-FIND (crapage WHERE crapage.cdcooper =       
                                                    glb_cdcooper AND 
                                                    crapage.cdagenci = 
                                      tel_cdagelot),"015 - PA nao cadastrado.")
     "-"
     tel_dsagenci NO-LABEL
     tel_nrdolote LABEL "Caixa"
                        HELP "Entre com o numero do caixa."
                        VALIDATE (tel_nrdolote > 0,
                                  "058 - Numero do caixa deve ser informado.")
     
     tel_nmoperad AT 48 LABEL "Operador"
     SKIP (2)
     "Informado"                        AT 35
     "Computado        Diferenca"       AT 52
     SKIP (1)
     "Total de Talonarios Solicitados:" AT 2
     craptrq.qtinfotl AT 39 NO-LABEL AUTO-RETURN
     craptrq.qtcomptl AT 56 NO-LABEL
     tel_qtdifetl     AT 71 NO-LABEL
     SKIP(1)
     "Total de Talonarios Entregues  :" AT 2
     craptrq.qtinfoen AT 39 NO-LABEL AUTO-RETURN
     craptrq.qtcompen AT 56 NO-LABEL
     tel_qtdifeen     AT 71 NO-LABEL
     SKIP(1)
     "              Com Requisições  :" AT 2
     aux_qtentreq_in AT 39 NO-LABEL AUTO-RETURN
     aux_qtentreq    AT 55 NO-LABEL
     aux_qtentdif_r  AT 71 NO-LABEL
     SKIP(1)
     "                  Com Cartões  :" AT 2
     aux_qtentcar_in AT 39 NO-LABEL AUTO-RETURN
     aux_qtentcar    AT 55 NO-LABEL
     aux_qtentdif_c  AT 71 NO-LABEL
     SKIP (2)
     WITH SIDE-LABELS TITLE COLOR MESSAGE " Capa de Lote para Requisicoes "
          ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_lotreq.

glb_cddopcao = "C".

DO WHILE TRUE:

        RUN fontes/inicia.p.

        DISPLAY glb_cddopcao WITH FRAME f_lotreq.
        
        NEXT-PROMPT tel_cdagelot WITH FRAME f_lotreq.
        
        REPEAT ON ENDKEY UNDO, LEAVE:

               /* para limpar o nome do operador */
               tel_nmoperad = "".

               PROMPT-FOR tel_cdagelot tel_nrdolote 
                          WITH FRAME f_lotreq.

               IF   INPUT FRAME f_lotreq tel_cdagelot = 0  THEN                                    DO:
                        glb_cdcritic = 15.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT-PROMPT tel_cdagelot WITH FRAME f_lotreq.
                        NEXT.
                    END.
              
               FIND crapage WHERE crapage.cdcooper = glb_cdcooper      AND
                                  crapage.cdagenci = INPUT tel_cdagelot 
                                  NO-LOCK NO-ERROR.
 
               FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                  crapage.cdagenci = INPUT tel_cdagelot 
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapage   THEN
                    DO:
                        glb_cdcritic = 15.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT-PROMPT tel_cdagelot WITH FRAME f_lotreq.
                        NEXT.
                    END.
                        
               tel_dsagenci = crapage.nmresage.
            
               DISPLAY tel_dsagenci WITH FRAME f_lotreq.

               IF   INPUT FRAME f_lotreq glb_cddopcao <> "C"    AND
                   (INPUT FRAME f_lotreq tel_nrdolote >= 19000  AND
                    INPUT FRAME f_lotreq tel_nrdolote <= 19999) THEN
                    DO:
                        glb_cdcritic = 261.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT-PROMPT tel_nrdolote WITH FRAME f_lotreq.
                        NEXT.
                    END.
                                         
               LEAVE.
        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   glb_nmdatela <> "lotreq"   THEN
                      DO:
                          HIDE FRAME f_lotreq.
                          RETURN.
                      END.
                 ELSE
                      NEXT.
             END.

        IF   aux_cddopcao <> INPUT glb_cddopcao   THEN
             DO:
                 { includes/acesso.i }
                 aux_cddopcao = INPUT glb_cddopcao.
             END.

        ASSIGN aux_cdagelot = INPUT tel_cdagelot
               aux_nrdolote = INPUT tel_nrdolote
               glb_cdagenci = INPUT tel_cdagelot
               glb_nrdolote = INPUT tel_nrdolote
               glb_cddopcao = INPUT glb_cddopcao.

        IF   INPUT glb_cddopcao = "A" THEN
             DO:
                 { includes/lotreqa.i }
             END.
        ELSE
             IF   INPUT glb_cddopcao = "C" THEN
                  DO:
                      { includes/lotreqc.i }
                  END.
             ELSE
                  IF   INPUT glb_cddopcao = "E" THEN
                       DO:
                           { includes/lotreqe.i }
                       END.
                  ELSE
                       IF   INPUT glb_cddopcao = "I" THEN
                            DO:
                                { includes/lotreqi.i }
                            END.
END.

/* .......................................................................... */
