/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0150tt.i
    Autor   : Lucas Lunelli
    Data    : Fevereiro/2013            Ultima Atualizacao:   /  /    
     
    Dados referentes ao programa:
   
    Objetivo  : Include referente a BO b1wgen0150.
                 
    Alteracoes: 

.............................................................................*/

DEFINE  TEMP-TABLE tt-admiss NO-UNDO
        FIELD cdagenci LIKE crapass.cdagenci
        FIELD nrdconta LIKE crapass.nrdconta
        FIELD nrmatric LIKE crapadm.nrmatric
        FIELD nmprimtl LIKE crapttl.nmextttl.

DEFINE  TEMP-TABLE tt-demiss NO-UNDO
        FIELD dtdemiss LIKE crapass.dtdemiss
        FIELD cdagenci LIKE crapass.cdagenci
        FIELD nrdconta LIKE crapass.nrdconta
        FIELD nmprimtl LIKE crapass.nmprimtl
        FIELD cdmotdem LIKE crapass.cdmotdem
        FIELD dsmotdem AS CHAR FORMAT "x(15)".
