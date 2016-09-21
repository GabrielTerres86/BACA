
/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0156tt.i
    Autor   : Jorge I. Hamaguchi
    Data    : Maio/2013                         Ultima Atualizacao: 01/11/2013
     
    Dados referentes ao programa:
   
    Objetivo  : Include referente a BO b1wgen0156.
                 
    Alteracoes: 01/11/2013 - Criado temp-table tt-lote.(Jorge)

.............................................................................*/

DEF TEMP-TABLE tt-contas-lote LIKE crapipc.

DEF TEMP-TABLE tt-lote LIKE craplpc.

DEF TEMP-TABLE tt-avalistas
    FIELDS nrcpfcgc AS DECI
    FIELDS nrdctato AS INTE
    FIELDS nmdavali AS CHAR
    FIELDS cddosexo AS CHAR
    FIELDS dsendere AS CHAR
    FIELDS nrcepend AS INTE
    FIELDS flgcheck AS LOGI
    INDEX tt-avalistas AS PRIMARY nrcpfcgc.

DEF TEMP-TABLE tt-arq-brde  
    FIELD cdseqlin AS INTEGER
    FIELD dsdlinha AS CHAR
    INDEX tt-arq-brde AS PRIMARY cdseqlin.

DEF TEMP-TABLE tt-brde
    FIELDS nrdconta AS INTE
    FIELDS nmextttl AS CHAR
    FIELDS dtnasttl AS DATE
    FIELDS vlsalari AS DECI
    FIELDS dtrefere AS DATE
    FIELDS nrcpfcgc AS DECI
    FIELDS dsendere AS CHAR
    FIELDS nrendere AS INTE
    FIELDS compleme AS CHAR
    FIELDS nmbairro AS CHAR
    FIELDS nrcepend AS INTE
    FIELDS cdufende AS CHAR
    FIELDS nmcidade AS CHAR
    FIELDS nrdddtfc AS INTE
    FIELDS nrtelefo AS DECI
    INDEX  tt-brde  AS PRIMARY nrdconta.


    
