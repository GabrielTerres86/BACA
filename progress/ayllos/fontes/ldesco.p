/* .............................................................................

   Programa: Fontes/ldesco.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                         Ultima atualizacao: 20/05/2009

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LDESCO -- Manutencao das linhas de desconto.

   Alteracoes: 03/10/2006 - Alterado para cooperativas singulares somente
                            consultar(Elton).

               17/09/2008 - Alterado os forms da tela (Gabriel). 
                          - Permissoes para operadores 996, 997, 1(Guilherme).

               11/02/2009 - Retirada permissao do op. 996 e incluido o 979
                            e o 799 (Gabriel).

               20/05/2009 - Alteracao CDOPERAD (Kbase).
............................................................................. */

{ includes/var_online.i }                                                     
{ includes/var_ldesco.i "NEW" }   /*  Contem as def. das variaveis e forms  */
    
VIEW FRAME f_moldura.

PAUSE 0.

VIEW FRAME f_ldesco.
       
ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               IF   aux_flgclear   THEN
                    DO:
                        CLEAR FRAME f_ldesco NO-PAUSE.
                    END.
               MESSAGE glb_dscritic.
               ASSIGN glb_cdcritic = 0
                      aux_flgclear = TRUE.
           END.

      NEXT-PROMPT tel_cddlinha WITH FRAME f_ldesco.

      UPDATE glb_cddopcao tel_cddlinha tel_tpdescto WITH FRAME f_ldesco

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
            IF   glb_nmdatela <> "ldesco"   THEN
                 DO:
                     HIDE FRAME f_ldesco.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   glb_dsdepart <> "TI"                    AND
        glb_dsdepart <> "COORD.PRODUTOS"        AND
        glb_dsdepart <> "COORD.ADM/FINANCEIRO"  AND
        glb_dsdepart <> "PRODUTOS"              AND
        glb_cddopcao <> "C"                     THEN
        DO:
            glb_cdcritic = 36.
            RUN fontes/critic.p.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.
   
   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao
                   glb_cdcritic = 0.
        END.

   IF   glb_cddopcao = "A"   THEN
        RUN fontes/ldescoa.p.
   ELSE
   IF   CAN-DO("B,L",glb_cddopcao)   THEN
        RUN fontes/ldescobl.p.
   ELSE
   IF   glb_cddopcao = "C"   THEN
        RUN fontes/ldescoc.p.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        RUN fontes/ldescoe.p.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        RUN fontes/ldescoi.p.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
