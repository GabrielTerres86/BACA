/* ............................................................................

   Programa: Fontes/pesqlt.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Diego
   Data    : Setembro/2005                      Ultima alteracao: 29/05/2014  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar dados referente Lote.
   
   Alteracoes: Unificacao dos Bancos - SQLWorks - Fernando 
   
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

............................................................................ */

{ includes/var_online.i }

DEF STREAM str_1. 

DEF   VAR aux_nmendter    AS CHAR     FORMAT "x(20)"                  NO-UNDO.
DEF   VAR aux_nmarqimp    AS CHAR                                     NO-UNDO.
DEF   VAR aux_confirma    AS CHAR     FORMAT "!(1)"                   NO-UNDO.
DEF   VAR aux_flgescra    AS LOGICAL                                  NO-UNDO.
DEF   VAR aux_dscomand    AS CHAR                                     NO-UNDO.
DEF   VAR aux_contador    AS INT      FORMAT "99"                     NO-UNDO.
DEF   VAR aux_titrelat    AS CHAR     FORMAT "x(30)"                  NO-UNDO.
DEF   VAR aux_cddopcao    AS CHAR                                     NO-UNDO.

DEF   VAR tel_dsimprim    AS CHAR     FORMAT "x(8)" INIT "Imprimir"   NO-UNDO.
DEF   VAR tel_dscancel    AS CHAR     FORMAT "x(8)" INIT "Cancelar"   NO-UNDO.
DEF   VAR tel_cdalinea    AS CHAR     FORMAT "x(27)"                  NO-UNDO.
DEF   VAR tel_dtrefere    AS DATE     FORMAT "99/99/9999"             NO-UNDO.
DEF   VAR tel_cdhistor    AS CHAR     FORMAT "x(27)"                  NO-UNDO.
DEF   VAR tel_valortot    LIKE craplcm.vllanmto                       NO-UNDO.

DEF   VAR par_flgcance    AS LOGICAL                                  NO-UNDO.
DEF   VAR par_flgrodar    AS LOGICAL                                  NO-UNDO.
DEF   VAR par_flgfirst    AS LOGICAL      INIT TRUE                   NO-UNDO.

DEF QUERY q_lotes FOR craplcm.
                                     
DEF BROWSE b_lotes QUERY q_lotes 
    DISP craplcm.nrdolote COLUMN-LABEL "Lote"
         craplcm.nrdconta COLUMN-LABEL "Conta"
         craplcm.nrdocmto COLUMN-LABEL "Nr.Cheque"   FORMAT "999,999,9"
         craplcm.cdpesqbb COLUMN-LABEL "Alinea"      FORMAT "x(2)"
         craplcm.nrdctabb COLUMN-LABEL "Cta.Base"
         craplcm.vllanmto COLUMN-LABEL "Valor"
         WITH 6 DOWN.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C ou R)."
                        VALIDATE(CAN-DO("C,R",glb_cddopcao),
                                 "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_lote.

DEF FRAME f_lotes_doc  
          SKIP(1)
          b_lotes   HELP  "Pressione <F4> ou <END> p/finalizar" 
          WITH NO-BOX CENTERED OVERLAY ROW 8.

FORM tel_dtrefere AT 1  LABEL "Data"
                        HELP "Entre com a data de referencia."
                        VALIDATE(INPUT tel_dtrefere <> ?,
                                 "375 - O campo deve ser preenchido")
     tel_cdalinea AT 25 LABEL "   Alinea"
                        HELP "Para modificar Alinea, separe por virgulas."
                        VALIDATE(INPUT tel_cdalinea <> "",
                                 "375 - O campo deve ser preenchido")
     SKIP
     tel_cdhistor AT 25 LABEL "Historico"
                        HELP "Para modificar Historico, separe por virgulas."
                        VALIDATE(INPUT tel_cdhistor <> "",
                                 "375 - O campo deve ser preenchido")
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere.

FORM tel_valortot       LABEL "Valor Total "   AT 36
     WITH NO-BOX NO-LABEL SIDE-LABELS ROW 19 COLUMN 6 OVERLAY FRAME f_total.
     
ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_cdalinea = "11,12,13"
       tel_cdhistor = "47".

VIEW FRAME f_moldura.
PAUSE(0).
   
DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.
    
      UPDATE glb_cddopcao  WITH FRAME f_lote.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "PESQLT"  THEN
                 DO:
                     HIDE FRAME f_refere.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> INPUT glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "C"    THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               ASSIGN tel_valortot = 0.

               UPDATE tel_dtrefere tel_cdalinea tel_cdhistor
                      WITH FRAME f_refere.

               OPEN QUERY q_lotes
                  FOR EACH craplcm WHERE 
                           craplcm.cdcooper = glb_cdcooper                 AND
                           craplcm.dtmvtolt = tel_dtrefere                 AND
                           CAN-DO(tel_cdalinea,craplcm.cdpesqbb)           AND 
                           CAN-DO(tel_cdhistor,STRING(craplcm.cdhistor))  
                           USE-INDEX craplcm4 NO-LOCK   BY craplcm.nrdolote.

               ENABLE b_lotes WITH FRAME f_lotes_doc.
               
               FOR EACH craplcm WHERE 
                        craplcm.cdcooper = glb_cdcooper                AND
                        craplcm.dtmvtolt = tel_dtrefere                AND
                        CAN-DO(tel_cdalinea,craplcm.cdpesqbb)          AND 
                        CAN-DO(tel_cdhistor,STRING(craplcm.cdhistor))  
                        USE-INDEX craplcm4 NO-LOCK:
      
                   ASSIGN tel_valortot = tel_valortot + craplcm.vllanmto.
      
                   DISPLAY tel_valortot WITH FRAME f_total.
               
               END.                
               
               WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
               
               CLOSE QUERY q_lotes.  
                
               HIDE FRAME f_lotes_doc.
               HIDE FRAME f_total.
               
               HIDE MESSAGE NO-PAUSE.
           
            END. /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   glb_cddopcao = "R"   THEN
        DO:
            UPDATE tel_dtrefere tel_cdalinea tel_cdhistor
                   WITH FRAME f_refere.

            RUN proc_imprime.           
        END.    
                          
END.  /*  Fim do DO WHILE TRUE  */

/*  ........................................................................  */

PROCEDURE confirma:

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.

      RUN fontes/critic.p.
      glb_cdcritic = 0.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 1 NO-MESSAGE.
        END. /* Mensagem de confirmacao */

END PROCEDURE.

PROCEDURE proc_imprime:
  
  FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

  INPUT THROUGH basename `tty` NO-ECHO.

  SET aux_nmendter WITH FRAME f_terminal.

  INPUT CLOSE.
  
  aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                        aux_nmendter.

  UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

  ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".
  
  OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.               
  
  aux_titrelat = "CONSULTA LOTES" + " - " + STRING(tel_dtrefere) + "~n" .
  
  ASSIGN tel_valortot = 0.
  
  FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper                  AND
                         craplcm.dtmvtolt = tel_dtrefere                  AND
                         CAN-DO(tel_cdalinea,craplcm.cdpesqbb)            AND 
                         CAN-DO(tel_cdhistor,STRING(craplcm.cdhistor))    
                         USE-INDEX craplcm4  NO-LOCK BY craplcm.nrdolote:

      ASSIGN tel_valortot = tel_valortot + craplcm.vllanmto.
                         
      DISPLAY STREAM str_1
                     craplcm.nrdolote LABEL "Lote"
                     craplcm.nrdconta LABEL "Conta"
                     craplcm.nrdocmto LABEL "Nr.Cheque" FORMAT "999,999,9"
                     craplcm.cdpesqbb LABEL "Alinea"    FORMAT "x(2)"
                     craplcm.nrdctabb LABEL "Cta.Base"
                     craplcm.vllanmto LABEL "Valor"
                     WITH NO-LABEL CENTERED TITLE aux_titrelat.
  END.                          

  IF   tel_valortot > 0   THEN
       DO:
           DOWN STREAM str_1.
           DISPLAY STREAM str_1
                   tel_valortot  @ craplcm.vllanmto LABEL "Valor Total" AT 41
                   WITH  NO-LABEL SIDE-LABELS. 

           OUTPUT STREAM str_1 CLOSE.

           RUN confirma.
           IF   aux_confirma = "S"   THEN
                DO:
                    ASSIGN glb_nrdevias = 1
                           par_flgrodar = TRUE
                           glb_nmformul = "80col".
           
                           { includes/impressao.i }
                END.
       END.
  ELSE
       DO:
           OUTPUT STREAM str_1 CLOSE.
           ASSIGN glb_cdcritic = 263.
           RUN fontes/critic.p.
           BELL.
           MESSAGE glb_dscritic.
           PAUSE 2 NO-MESSAGE.
           HIDE MESSAGE.
           DISPLAY glb_cddopcao WITH FRAME f_lote.
           NEXT.
       END.
       
END PROCEDURE.
