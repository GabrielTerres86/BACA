/*............................................................................

   Programa: Includes/pgdter.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Maio/2009                          Ultima atualizacao: 25/08/2009

   Dados referentes ao programa:
   
   Frequencia: Diario (Online).
   Objetivo  : Possibilitar a impressao do termo de compromisso do evento.
               Chamada por includes/pgdsit.i e includes/pgdins.i.
               
   NOTA      : USADA POR includes/pgdsit.i e includes/pgdins.i VERIFICAR 
               ANTES DE ALTERAR. 

   Alteracoes: 25/08/2009 - Utilizar o fontes/substitui_caracter.p para 
                            retirar os caracteres acentuados do PROGRID
                            (Gabriel)

..............................................................................*/

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
   RUN termo-de-compromisso IN h-b1wgen0039 
                                       (INPUT glb_cdcooper,
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT glb_cdoperad,
                                        INPUT glb_dtmvtolt,
                                        INPUT tel_nrdconta,
                                        INPUT par_nrdrowid,
                                        INPUT tt-eventos-andamento.rowidedp,
                                        INPUT 1,
                                        INPUT 1,
                                        INPUT glb_nmdatela,
                                        INPUT FALSE,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-termo).
   IF   RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF   AVAILABLE tt-erro   THEN
                 DO:
                     MESSAGE tt-erro.dscritic.
                     PAUSE 2 NO-MESSAGE.
                     HIDE MESSAGE NO-PAUSE.
                 END.
                              
            LEAVE.
        
        END.       

   ASSIGN aux_nmarqimp    = "rl/termo_compromisso.lst".
                                               
   OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

   FIND FIRST tt-termo NO-LOCK NO-ERROR.
   
   /* Tirar caracteres acentuados do PROGRID */
   RUN fontes/substitui_caracter.p (INPUT-OUTPUT tt-termo.nmevento).

   DISPLAY STREAM str_1 tt-termo.nmrescop
   
                        tt-termo.nmextcop WITH FRAME f_termo_coop.
   
   
   IF   tt-termo.tpinseve = 1   THEN /* Inscricao Propria */
        DO: 
            DISPLAY STREAM str_1 tt-termo.nmextttl
                                 tt-termo.nmevento  
                                 tt-termo.nmrescop
                                 tt-termo.prfreque
                                 tt-termo.vldebito
                                 tt-termo.dsdebito
                                 tt-termo.prdescon
                                 tt-termo.nrdconta 
                                 WITH FRAME f_termo_propria.
                                 
            DISPLAY STREAM str_1 tt-termo.nmextttl 
                                 tt-termo.dspacdat
                                 WITH FRAME f_termo_assinatura. 
        
        END.
   ELSE                              /* Inscricao pra outra pessoa */
        DO:
            DISPLAY STREAM str_1 tt-termo.nmextttl
                                 tt-termo.nminseve  
                                 tt-termo.nmevento
                                 tt-termo.nmrescop
                                 tt-termo.prfreque
                                 tt-termo.vldebito
                                 tt-termo.dsdebito
                                 tt-termo.prdescon
                                 tt-termo.nrdconta 
                                 WITH FRAME f_termo_outra.

            DISPLAY STREAM str_1 tt-termo.nmextttl 
                                 tt-termo.dspacdat
                                 WITH FRAME f_termo_assinatura.         

        END.
   
   OUTPUT STREAM str_1 CLOSE.
   
   ASSIGN glb_nrcopias = 1
          glb_nmarqimp = aux_nmarqimp
          par_flgrodar = TRUE.

   RUN fontes/termo_compromisso.p. /* Imprimir o termo */

   LEAVE.
    
END. /* Fim do DO WHILE TRUE */


/*............................................................................*/
