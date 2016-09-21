/* .............................................................................

   Programa: Fontes/moedasr.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Dezembro/2011                       Ultima atualizacao:03/06/2014    

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gerar relatorio de Taxas atraves da tela MOEDAS.

   Alteracao : 03/02/2014 - Alteração do Layout de impressão e inclusão
                            de campos no relatório (Jean Michel)
                            
               03/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................. */

DEF VAR aux_server   AS CHAR NO-UNDO.

IF   tel_dtinicio = ? OR
     tel_dttermin = ? THEN
     DO:
         BELL.
         MESSAGE "Favor inserir a Data inicio ou termino.".
         CLEAR FRAME f_relatorio.
         HIDE FRAME f_relatorio.
         NEXT.
     END.

IF   tel_dtinicio > tel_dttermin THEN
     DO:
         BELL.
         MESSAGE "Data inicio superior a data termino.".
         CLEAR FRAME f_relatorio.
         HIDE FRAME f_relatorio.
         NEXT.
     END.

IF   tel_dtinicio < (glb_dtmvtolt - 90) THEN
     DO:
         BELL.
         MESSAGE "Data inicio inferior a 90 dias.".
         CLEAR FRAME f_relatorio.
         HIDE FRAME f_relatorio.
         NEXT.
     END.
  
EMPTY TEMP-TABLE tt-taxas.

MESSAGE "Aguarde...Gerando Relatorio...".


/**** Leitura das cotacoes das moedas ****/
FOR EACH crapmfx WHERE crapmfx.cdcooper  = glb_cdcooper AND
                       crapmfx.dtmvtolt >= tel_dtinicio AND
                       crapmfx.dtmvtolt <= tel_dttermin 
                       NO-LOCK:

    FIND FIRST tt-taxas WHERE tt-taxas.dtmvtolt = crapmfx.dtmvtolt NO-ERROR.

    IF   NOT AVAIL tt-taxas THEN 
         DO:
             /*********** Cálculo dos dias úteis ***********/
             RUN fontes/calcdata.p (INPUT crapmfx.dtmvtolt,  /* Periodo */
                                    INPUT 1,
                                    INPUT "M",               /* CDI Mensal */
                                    INPUT 0,
                                    OUTPUT aux_dtfimper).    /* Fim Periodo */

             ASSIGN aux_dtmvtolt = crapmfx.dtmvtolt 
                    aux_qtdiaute = 0.
        
             DO WHILE aux_dtmvtolt < aux_dtfimper:

                IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt))) OR
                     CAN-FIND(FIRST crapfer WHERE
                                    crapfer.cdcooper = crapmfx.cdcooper AND
                                    crapfer.dtferiad = aux_dtmvtolt) THEN.    
                ELSE 
                     aux_qtdiaute = aux_qtdiaute + 1.
            
                aux_dtmvtolt = aux_dtmvtolt + 1.

             END.  /*  Fim do DO WHILE TRUE  */

                  
             CREATE tt-taxas.
             ASSIGN tt-taxas.dtmvtolt = crapmfx.dtmvtolt
                    tt-taxas.qtdiaute = aux_qtdiaute.

    END.

    CASE crapmfx.tpmoefix:
        /* CDI Anual */
        WHEN 6 THEN 
            ASSIGN tt-taxas.vlcdiano = crapmfx.vlmoefix.

        /* Poupança */
        WHEN 8 THEN
            ASSIGN tt-taxas.vldapoup = crapmfx.vlmoefix
                   tt-taxas.vlpoupIR = crapmfx.vlmoefix / 0.775.

        /* TR */
        WHEN 11 THEN
            ASSIGN tt-taxas.vltaxaTR = crapmfx.vlmoefix.

        /* CDI Mensal */
        WHEN 16 THEN
            ASSIGN tt-taxas.vlcdimes = crapmfx.vlmoefix.

        /* CDI Acumulado */
        WHEN 17 THEN
            ASSIGN tt-taxas.vlcdiacu = crapmfx.vlmoefix.

        /* CDI Diario */
        WHEN 18 THEN
            ASSIGN tt-taxas.vlcdidia = crapmfx.vlmoefix.
        
        /* SELIC Meta */
        WHEN 19 THEN
            ASSIGN tt-taxas.vlpoupsl = crapmfx.vlmoefix.
        WHEN 20 THEN
            ASSIGN tt-taxas.vlpoupnr = crapmfx.vlmoefix
                   tt-taxas.vlponrir = crapmfx.vlmoefix / 0.775.    
    END CASE.

END.  /*  Fim do FOR EACH -- Leitura das moedas fixas do mes corrente  */


INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

INPUT THROUGH basename `hostname -s` NO-ECHO.
IMPORT UNFORMATTED aux_server.
INPUT CLOSE.

aux_nmendter = substr(aux_server,length(aux_server) - 1) +
                      aux_nmendter.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

ASSIGN aux_nmarqimp    = "rl/" + aux_nmendter + STRING(TIME) + ".ex"
       glb_cdrelato[1] = 617.

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 60 PAGED. 

{ includes/cabrel234_1.i }

VIEW STREAM str_1 FRAME f_cabrel234_2.

DISPLAY STREAM str_1 tel_dtinicio tel_dttermin WITH FRAME f_refere.
DOWN STREAM str_1 WITH FRAME f_refere.

/*  Lista as taxas  */
FOR EACH tt-taxas:

    DISPLAY STREAM str_1 tt-taxas.dtmvtolt      tt-taxas.qtdiaute 
                         tt-taxas.vlcdiano      tt-taxas.vlcdidia     
                         tt-taxas.vlcdiacu      tt-taxas.vlcdimes    
                         tt-taxas.vltaxaTR      tt-taxas.vldapoup    
                         tt-taxas.vlpoupIR      tt-taxas.vlpoupnr
                         tt-taxas.vlponrir      tt-taxas.vlpoupsl
                         WITH FRAME f_taxas.
    
    DOWN STREAM str_1 WITH FRAME f_taxas.
    
END.  

ASSIGN tel_cddopcao = "T".

DISPLAY STREAM str_1 WITH FRAME f_assina.
DOWN STREAM str_1 WITH FRAME f_assina.

OUTPUT STREAM str_1 CLOSE.

HIDE MESSAGE NO-PAUSE.


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
   MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao FORMAT "!(1)".
    
   IF   tel_cddopcao = "I"   THEN
        DO:
            /* somente para o includes/impressao.i */
            FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper       
                                     NO-LOCK NO-ERROR.

            glb_nmformul = "234dh".
                        
            { includes/impressao.i }

            LEAVE.
        END.
   ELSE
        IF   tel_cddopcao = "T"   THEN
             DO:
                 RUN fontes/visrel.p (INPUT aux_nmarqimp).
                 LEAVE.
             END.
        ELSE
             DO: 
                 glb_cdcritic = 14.
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE glb_dscritic.
                 glb_cdcritic = 0.
                 NEXT.
             END.            
END.
CLEAR FRAME f_relatorio.


/* .......................................................................... */
