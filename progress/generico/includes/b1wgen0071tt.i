/*..............................................................................

    Programa: sistema/generico/includes/b1wgen0071tt.i                  
    Autor   : David
    Data    : Abril/2010                      Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0071.p

   Alteracoes: 
    - 23/03/2019 - Vitor S. Assanuma - Inclusao dos campos: dssituac; dsdcanal; dtrevisa
                            
..............................................................................*/


DEF TEMP-TABLE tt-email-cooperado NO-UNDO
    FIELD cddemail AS INTE
    FIELD dsdemail AS CHAR
    FIELD secpscto AS CHAR
    FIELD nmpescto AS CHAR
    FIELD dssituac AS CHAR
    FIELD dsdcanal AS CHAR
    FIELD dtrevisa AS DATE FORMAT "99/99/9999"
    FIELD nrdrowid AS ROWID.


/*............................................................................*/
