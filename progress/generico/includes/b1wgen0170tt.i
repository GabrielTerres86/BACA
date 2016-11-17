/*.............................................................................

   Programa: b1wgen0170tt.i                  
   Autor   : Lucas R.
   Data    : Agosto/2013                      Ultima atualizacao: 01/09/2015

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0170.p

   Alteracoes: 01/10/2013 - Incluido temp-table tt-msg (Lucas R.)

               01/09/2015 - Adicionado os campos de assessoria e motivo CIN
                            (Douglas - Melhoria 12)
.............................................................................*/

DEF TEMP-TABLE tt-crapcyc NO-UNDO
    FIELD cdcooper AS INTE
    FIELD cdorigem AS INTE
    FIELD nrdconta AS INTE
    FIELD nrctremp AS INTE
    FIELD flgjudic AS CHAR
    FIELD flextjud AS CHAR
    FIELD flgehvip AS CHAR
    FIELD dsorigem AS CHAR
    FIELD dtenvcbr AS DATE
    FIELD dtinclus AS DATE
    FIELD cdoperad AS CHAR
    FIELD cdopeinc AS CHAR
    FIELD dtaltera AS DATE
    FIELD cdassess AS INTE
    FIELD nmassess AS CHAR
    FIELD cdmotcin AS INTE
    FIELD dsmotcin AS CHAR.

DEF TEMP-TABLE tt-msg NO-UNDO
    FIELD nrdconta AS INT
    FIELD nrctremp AS INT
    FIELD cdcritic AS INT
    FIELD dscritic AS CHAR.
