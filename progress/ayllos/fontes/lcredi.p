/* .............................................................................

   Programa: Fontes/lcredi.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/94.                           Ultima atualizacao: 24/04/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LCREDI -- Manutencao das linhas de credito.

   Alteracoes: 14/10/94 - Alterado para inclusao de novos parametros para as
                          linhas de credito: taxa minima e maxima e o sinali-
                          zador de linha com saldo devedor.

               21/02/97 - Alterado para permitir o tratamento de ate 100 par-
                          celas (Edson).

               25/10/2004 - Implementado zoom para linhas de credito (Edson).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               13/02/2006 - Inclusao do parametro glb_cdcooper para a chamada do
                            do programa fontes/zoom_linhas_de_credito.p 
                            SQLWorks - Fernando

               03/10/2006 - Alterado para cooperativas singulares somente
                            consultar (Elton).
                            
               10/02/2009 - Liberar opcoes soh pro op. 799 (Gabriel).
                    
               20/05/2009 - Alteracao CDOPERAD (Kbase).

               07/08/2009 - Alterada chamada do fontes do f7 da linha(Gabriel).
               
               22/07/2010 - Tratar a tela principal em duas frames (Gabriel).
               
               18/12/2012 - Incluir departameto Coord. Fin. - Trf. 31474 (Ze).
               
               23/04/2014 - Adicionado parametro de finalidade de emprestimo
                            no zoom_linhas_de_credito. (Reinert)

               24/04/2015 - Adicionado o departamento FINANCEIRO para poder
                            fazer alteracoes. (Jaison/Irlan - SD: 279663)

............................................................................. */

{ includes/var_online.i }
{ includes/var_lcredi.i "NEW" }   /*  Contem as def. das variaveis e forms  */

VIEW FRAME f_moldura.

PAUSE 0.

VIEW FRAME f_lcredi.


/* Somente para o fontes do F7 da linha - nao eh utilizada */
DEF VAR par_dslcremp                         AS CHAR              NO-UNDO.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0

       aux_dstipolc = "NORMAL,EQUIVALENCIA SALARIAL".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                               
      ASSIGN tel_dslcremp = "".

      DISPLAY tel_dslcremp WITH FRAME f_lcredi.
                                 
      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.                           
               IF   aux_flgclear   THEN
                    DO:
                        CLEAR FRAME f_lcredi NO-PAUSE.
                    END.
               
                    MESSAGE glb_dscritic.
               
               ASSIGN glb_cdcritic = 0
                      aux_flgclear = TRUE.
           END.

      NEXT-PROMPT tel_cdlcremp WITH FRAME f_lcredi.

      UPDATE glb_cddopcao tel_cdlcremp WITH FRAME f_lcredi

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
            ELSE
            IF   LASTKEY = KEYCODE("F7") THEN
                 DO:
                     IF   FRAME-FIELD = "tel_cdlcremp" THEN
                          DO:
                              /* Liberadas e bloqueadas */
                              RUN fontes/zoom_linhas_de_credito.p 
                                              ( INPUT  glb_cdcooper,
                                                INPUT  0,
                                                INPUT  FALSE,
                                                OUTPUT tel_cdlcremp,
                                                OUTPUT par_dslcremp).

                              DISPLAY tel_cdlcremp WITH FRAME f_lcredi.

                              IF   tel_cdlcremp > 0    THEN
                                   APPLY "RETURN".                             
                          END.
                 END.
            ELSE
                 APPLY LASTKEY.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */
                                                            
      END.  /*  Fim do EDITING  */

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "LCREDI"   THEN
                 DO:
                     HIDE FRAME f_presta.
                     HIDE FRAME f_finali.
                     HIDE FRAME f_lcredi.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao
                   glb_cdcritic = 0.
        END.
        
        /* Cooperativas singulares podem somente consultar */
   IF   NOT CAN-DO("C,F",glb_cddopcao)              THEN
        IF  glb_dsdepart <> "TI"                    AND
            glb_dsdepart <> "PRODUTOS"              AND
            glb_dsdepart <> "COORD.ADM/FINANCEIRO"  AND
           (glb_dsdepart =  "FINANCEIRO"            AND 
            glb_cdcooper <> 3)                      THEN
            DO:
                BELL.
                MESSAGE "Sistema liberado somente para Consulta !!!".
                NEXT.
            END.

   /*  Modelo do contrato  */
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                      craptab.nmsistem = "CRED"          AND
                      craptab.tptabela = "GENERI"        AND
                      craptab.cdempres = 0               AND
                      craptab.cdacesso = "CTRATOEMPR"    AND
                      craptab.tpregist = 0               NO-LOCK
                      USE-INDEX craptab1 NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN
        DO:
            glb_cdcritic = 529.
            NEXT.
        END.

   ASSIGN aux_lsctrato = TRIM(craptab.dstextab)
          aux_nvfinhab = ""
          aux_exfinhab = "".

   IF   glb_cddopcao = "A"   THEN
        RUN fontes/lcredia.p.
   ELSE
   IF   CAN-DO("B,L",glb_cddopcao)   THEN
        RUN fontes/lcredibl.p.
   ELSE
   IF   glb_cddopcao = "C"   THEN
        RUN fontes/lcredic.p.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        RUN fontes/lcredie.p.
   ELSE
   IF   glb_cddopcao = "F"   THEN
        RUN fontes/lcredif.p.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        RUN fontes/lcredii.p.      
   ELSE
   IF   glb_cddopcao = "P"   THEN
        RUN fontes/lcredip.p.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */


