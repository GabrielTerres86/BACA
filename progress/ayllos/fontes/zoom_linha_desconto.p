/*.............................................................................

   Programa: fontes/zoom_linha_desconto.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Outubro/2009                       Ultima alteracao:
   
   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Zoom das linhas de desconto.
   
   ENTRADA   : par_cdcooper - Codigo da cooperativa.
                
               par_tpdescto - 0 Todas
                              2 Desconto de cheque.
                              3 Desconto de titulo.
                              
               par_flgstlcr - TRUE  - Liberadas
                              FALSE - Liberadas e bloqueadas.               
   Alteracoes:
   
............................................................................. */

DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
DEF  INPUT PARAM par_tpdescto AS INTE                             NO-UNDO.
DEF  INPUT PARAM par_flgstlcr AS LOGI                             NO-UNDO.
                                                      
DEF INPUT-OUTPUT PARAM par_cddlinha AS INTE                       NO-UNDO.
DEF INPUT-OUTPUT PARAM par_dsdlinha AS CHAR                       NO-UNDO.
                                                          

DEF QUERY q-crapldc-1 FOR crapldc.

DEF QUERY q-crapldc-2 FOR crapldc.

DEF BROWSE b-crapldc-1 QUERY q-crapldc-1
    DISPLAY crapldc.cddlinha COLUMN-LABEL "Linha de Desconto"
            crapldc.dsdlinha COLUMN-LABEL "Descricao"
            WITH 5 DOWN OVERLAY TITLE " Linhas de Desconto ".

DEF BROWSE b-crapldc-2 QUERY q-crapldc-2
    DISPLAY crapldc.cddlinha COLUMN-LABEL "Linha de Desconto"
            crapldc.dsdlinha COLUMN-LABEL "Descricao"
            crapldc.flgstlcr COLUMN-LABEL "Situacao"
            WITH 5 DOWN OVERLAY TITLE " Linhas de Desconto ".


FORM b-crapldc-1
        HELP "Use as <SETAS> para navegar <ENTER> para selecionar."
     SKIP

     WITH NO-BOX CENTERED OVERLAY ROW 10 FRAME f_linha-1.

FORM b-crapldc-2
        HELP "Use as <SETAS> para navegar <ENTER> para selecionar."
    SKIP

    WITH NO-BOX CENTERED OVERLAY ROW 10 FRAME f_linha-2.


ON 'RETURN' OF b-crapldc-1, b-crapldc-2 DO: 

    IF   AVAILABLE crapldc THEN
         ASSIGN par_cddlinha = crapldc.cddlinha
                par_dsdlinha = crapldc.dsdlinha.

    IF   par_flgstlcr   THEN
         DO:
             CLOSE QUERY q-crapldc-1.
             APPLY "END-ERROR" TO b-crapldc-1.
         END.
    ELSE
         DO:
             CLOSE QUERY q-crapldc-2.
             APPLY "END-ERROR" TO b-crapldc-2.
         END.
END.


/* Linhas de desconto liberadas */

IF   par_flgstlcr   THEN
     DO:
         OPEN QUERY q-crapldc-1 FOR EACH crapldc WHERE 
                                         crapldc.cdcooper = par_cdcooper AND
                                        (crapldc.tpdescto = par_tpdescto OR
                                         par_tpdescto = 0)               AND
                                         crapldc.flgstlcr = TRUE         NO-LOCK.

                                         
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

             UPDATE b-crapldc-1 WITH FRAME f_linha-1.
             LEAVE.

         END.

     END.
ELSE    /* Linhas bloqueadas e liberadas*/
     DO:
         OPEN QUERY q-crapldc-2 FOR EACH crapldc WHERE
                                         crapldc.cdcooper = par_cdcooper AND
                                        (crapldc.tpdescto = par_tpdescto OR
                                         par_tpdescto = 0)               NO-LOCK.


         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

             UPDATE b-crapldc-2 WITH FRAME f_linha-2.
             LEAVE.

         END.

     END.

HIDE FRAME f_linha-1 NO-PAUSE.
HIDE FRAME f_linha-2 NO-PAUSE.


/*...........................................................................*/




