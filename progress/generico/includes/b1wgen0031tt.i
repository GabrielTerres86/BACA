/*.............................................................................

   Programa: b1wgen0031tt.i                  
   Autor   : Guilherme
   Data    : Julho/2008                  Ultima atualizacao: 04/07/2011

   Dados referentes ao programa:

   Objetivo  : Temp-tables utlizadas na BO b1wgen0031.p

   Alteracoes: 07/12/2010 - Definida temp-table de mensagens da tela 
                            de contas (Gabriel - DB1)  .
                            
               18/03/2011 - Eliminar temp-tables tt-anota/tt-cab_anota (David).
               
               04/07/2011 - Criada temp-table tt-crapalt (Henrique).
                            
.............................................................................*/

DEF TEMP-TABLE tt-mensagens-atenda                                      NO-UNDO
    FIELD nrsequen AS INTE
    FIELD dsmensag AS CHAR
    INDEX tt-mensagens-atenda1 AS PRIMARY nrsequen.

DEF TEMP-TABLE tt-mensagens-contas                                      NO-UNDO
    FIELD nrsequen AS INTE
    FIELD dsmensag AS CHAR
    INDEX tt-mensagens-contas1 AS PRIMARY nrsequen.
        
DEF TEMP-TABLE tt-crapalt                                               NO-UNDO
    FIELD dtaltera AS DATE
    FIELD tpaltera AS CHAR
    FIELD dsaltera AS CHAR
    FIELD nmoperad AS CHAR.
/*...........................................................................*/
