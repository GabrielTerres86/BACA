/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0160tt.i
    Autor   : Gabriel Capoia (DB1)
    Data    : 16/07/2013                     Ultima atualizacao: 01/07/2014
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0160.
  
    Alteracoes: 07/08/2013 - Alterado tipo da variavel nrctachq de INTE para 
                             DECI e adicionado tt-dados-cheque para controle 
                             de grid na pesqsr (Anderson/AMCOM)
               
                01/07/2014 - Adicionado campo cdagetfn na temp-table tt-pesqsr
                             (Reinert)
.............................................................................*/

DEF TEMP-TABLE tt-pesqsr NO-UNDO
    FIELD dtmvtolt AS DATE
    FIELD cdagenci AS INTE
    FIELD cdbccxlt AS INTE
    FIELD nrdolote AS INTE
    FIELD vllanmto AS DECI
    FIELD cdpesqbb AS CHAR
    FIELD nrseqimp AS INTE
    FIELD vldoipmf AS DECI
    FIELD cdbanchq AS CHAR

    FIELD sqlotchq AS INTE
    FIELD cdcmpchq AS INTE
    FIELD nrlotchq AS INTE
    FIELD nrctachq AS DECI
    FIELD nrdocmto AS INTE
    FIELD nrdctabb AS INTE
    FIELD nrdctabx AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD dsagenci AS CHAR
    FIELD nmdsecao AS CHAR
    FIELD cdturnos AS INTE
    FIELD nrfonemp AS CHAR
    FIELD nrramemp AS INTE
    FIELD nrdconta AS INTE
    FIELD cdbaninf AS INTE
    FIELD dsdocmc7 AS CHAR
    FIELD cdagetfn LIKE craplcm.cdagetfn.

DEF TEMP-TABLE tt-dados-cheque NO-UNDO
    FIELD nrseqchq AS INT
    FIELD dtmvtolt AS DATE
    FIELD cdalinea AS CHAR
    FIELD dtmvtori AS DATE
    FIELD cdbanchq AS CHAR FORMAT "x(09)"  
    FIELD cdagechq AS INT
    FIELD cdcmpchq AS INT 
    FIELD nrlotchq AS INT 
    FIELD sqlotchq AS INT 
    FIELD nrctachq AS DEC. 
