/* .............................................................................

   Programa: fontes/quebra_str.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fernando/Julio
   Data    : Julho/2003                         Ultima Atualizacao: 20/10/2003          

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Quebrar um string em quatro linhas, e justifica-las.

   Alteracoes: 20/10/2003 - Procedure conta_fim, estava somando incorretamente
                            dentro da condicao do while a variavel 
                            aux_contafim (Julio).
............................................................................. */

DEF INPUT  PARAMETER aux_dsstring  AS CHAR                 NO-UNDO.

DEF INPUT  PARAMETER par_qtcolun1  AS INT                  NO-UNDO.
DEF INPUT  PARAMETER par_qtcolun2  AS INT                  NO-UNDO.
DEF INPUT  PARAMETER par_qtcolun3  AS INT                  NO-UNDO.
DEF INPUT  PARAMETER par_qtcolun4  AS INT                  NO-UNDO.

DEF OUTPUT PARAMETER aux_dslinha1  AS CHAR                 NO-UNDO.
DEF OUTPUT PARAMETER aux_dslinha2  AS CHAR                 NO-UNDO.
DEF OUTPUT PARAMETER aux_dslinha3  AS CHAR                 NO-UNDO.
DEF OUTPUT PARAMETER aux_dslinha4  AS CHAR                 NO-UNDO.
                                                  
DEF        VAR       aux_containi  AS INT                  NO-UNDO.
DEF        VAR       aux_contafim  AS INT                  NO-UNDO.
DEF        VAR       aux_nrocolun  AS INT                  NO-UNDO.
DEF        VAR       aux_contalet  AS INT                  NO-UNDO.


RUN Conta_Fim (INPUT par_qtcolun1).
aux_dslinha1 = TRIM(SUBSTR(aux_dsstring, aux_containi, aux_nrocolun + 1)).
RUN Justifica (INPUT aux_dslinha1, INPUT par_qtcolun1, OUTPUT aux_dslinha1).

RUN Conta_Fim (INPUT par_qtcolun2).
aux_dslinha2 = TRIM(SUBSTR(aux_dsstring, aux_containi, aux_nrocolun + 1)).
RUN Justifica (INPUT aux_dslinha2, INPUT par_qtcolun2, OUTPUT aux_dslinha2).

RUN Conta_Fim (INPUT par_qtcolun3).
aux_dslinha3 = TRIM(SUBSTR(aux_dsstring, aux_containi, aux_nrocolun + 1)).
RUN Justifica (INPUT aux_dslinha3, INPUT par_qtcolun3, OUTPUT aux_dslinha3).

RUN Conta_Fim (INPUT par_qtcolun4).
aux_dslinha4 = TRIM(SUBSTR(aux_dsstring, aux_containi, aux_nrocolun + 1)).
RUN Justifica (INPUT aux_dslinha4, INPUT par_qtcolun4, OUTPUT aux_dslinha4).

/* .......................................................................... */

PROCEDURE Conta_Fim:

   DEF INPUT PARAMETER par_qtcoluna AS INT NO-UNDO.                 

   ASSIGN aux_containi = aux_contafim + 1
          aux_contafim = aux_containi + par_qtcoluna.
          
   DO WHILE (SUBSTR(aux_dsstring, aux_contafim, 1) <> " ") AND 
            (aux_contafim > 0):
            aux_contafim = aux_contafim - 1.
   END.

   aux_nrocolun = aux_contafim - aux_containi.

END.

PROCEDURE Justifica:
    
   DEF INPUT  PARAMETER aux_linhaatu   AS CHAR                    NO-UNDO.
   DEF INPUT  PARAMETER aux_qtdcolun   AS INT                     NO-UNDO.
   DEF OUTPUT PARAMETER aux_linharet   AS CHAR                    NO-UNDO.
   DEF        VAR       aux_espacobr   AS CHAR INITIAL " "        NO-UNDO.

   aux_contalet = aux_nrocolun - 1.

   IF   LENGTH(TRIM(aux_linhaatu)) > 0 THEN
        DO:
            DO WHILE (LENGTH(TRIM(aux_linhaatu)) < aux_qtdcolun) AND 
                 (aux_contalet > 0) AND 
                 (LENGTH(TRIM(aux_linhaatu)) > aux_qtdcolun / 2):
               
               IF   SUBSTR(TRIM(aux_linhaatu), aux_contalet, 1) = 
                                                           aux_espacobr THEN
                    DO:
                        aux_linhaatu = TRIM(SUBSTR(aux_linhaatu, 1, 
                                                       aux_contalet) +
                                   " " + SUBSTR(aux_linhaatu, aux_contalet + 1, 
                                   aux_qtdcolun - aux_contalet)). 
                    END.                 
         
               IF   aux_contalet > 1 THEN
                    aux_contalet = aux_contalet - 1.         
               ELSE
                    DO:
                        ASSIGN aux_contalet = aux_qtdcolun
                               aux_espacobr = aux_espacobr + " ".
                    END.
      
            END.  /*  Fim do DO WHILE  */
        END.

   aux_linharet = aux_linhaatu.

END.

/* .......................................................................... */

