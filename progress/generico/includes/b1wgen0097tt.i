/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0097tt.i                  
    Autor   : Gabriel
    Data    : Maio/2010                     Ultima atualizacao: 25/06/2015

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0097.p

   Alteracoes: 28/07/2011 - Inclusao do campo cdagenci (Diego).
                            
               05/04/2012 - Declaracao da temp-table crapfer (Tiago).  
               
               25/06/2015 - Projeto 215 - DV 3 (Daniel)           
               
               08/07/2015 - Criacao do novo campo cdmodali, dsmodali, tpfinali
                            (Carlos Rafael Tanholi) Projeto Portabilidade.
.............................................................................*/

DEF TEMP-TABLE tt-crapsim LIKE crapsim
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdialib AS INTE
    FIELD dslcremp AS CHAR
    FIELD dsfinemp AS CHAR
    FIELD cdmodali AS CHAR
    FIELD dsmodali AS CHAR
    FIELD tpfinali AS INTE
    FIELD idfiniof AS INTE.

DEF TEMP-TABLE tt-crapfer LIKE crapfer.

