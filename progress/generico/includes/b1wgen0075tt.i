/*.............................................................................

    Programa: b1wgen0075tt.i
    Autor   : Jose Luis Marchezoni
    Data    : Maio/2010                   Ultima atualizacao: 18/04/2017

    Objetivo  : Definicao das Temp-Tables, CONTAS - COMERCIAL

    Alteracoes: 16/06/2011 - Incluir campo 'Politicamente exposta' (Gabriel).
        
                23/11/2011 - Incluido o campo dsjusren na tabela tt-comercial e
                             criado a tem-table tt-rendimentos (Adriano). 
                             
                12/08/2015 - Projeto Reformulacao cadastral
                             Eliminado o campo nmdsecao (Tiago Castro - RKAM).

				18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							(Adriano - P339).
              
        29/08/2019 PJ485.6 - Inclusao do tipo de pessoa do empregador na tt comercial - Augusto (Supero)              

.............................................................................*/



/*...........................................................................*/

DEFINE TEMP-TABLE tt-comercial NO-UNDO
    FIELD cdnatopc AS INTE
    FIELD cdocpttl AS INTE
    FIELD tpcttrab AS INTE
    FIELD cdempres AS INTE
    FIELD nmresemp AS CHAR
    FIELD nmextemp AS CHAR
    FIELD nrcpfemp AS CHAR FORMAT "x(14)"
    FIELD dsproftl AS CHAR
    FIELD cdnvlcgo AS INTE
    FIELD nrcadast AS INTE
    FIELD dtadmemp AS DATE
    FIELD vlsalari AS DECI
    FIELD tpdrendi AS INTE EXTENT 4
    FIELD dsdrendi AS CHAR EXTENT 4
    FIELD vldrendi AS DECI EXTENT 4
    FIELD cdturnos AS INTE
    FIELD rsnatocp AS CHAR
    FIELD rsocupa  AS CHAR
    FIELD dsctrtab AS CHAR
    FIELD rsnvlcgo AS CHAR
    FIELD dsturnos AS CHAR
    FIELD cepedct1 AS INTE
    FIELD endrect1 AS CHAR
    FIELD nrendcom AS INTE
    FIELD complcom AS CHAR
    FIELD bairoct1 AS CHAR
    FIELD cidadct1 AS CHAR
    FIELD ufresct1 AS CHAR
    FIELD cxpotct1 AS INTE
    FIELD inpolexp AS INTE
    FIELD nrdrowid AS ROWID
    FIELD dsjusren AS CHAR
    FIELD dssituae AS CHAR
    FIELD dscanale AS CHAR
    FIELD dtrevise AS DATE
    FIELD dssituar AS CHAR
    FIELD dscanalr AS CHAR
    FIELD dtrevisr AS DATE
    FIELD tppesemp AS INTE.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-comercial-ant NO-UNDO 
        FIELD cdnatopc AS INTE
        FIELD cdocpttl AS INTE
        FIELD tpcttrab AS INTE
        FIELD cdempres AS INTE
        FIELD nrcpfemp AS CHAR
        FIELD dsproftl AS CHAR
        FIELD cdnvlcgo AS INTE
        FIELD nrcadast AS INTE
        FIELD dtadmemp AS DATE
        FIELD vlsalari AS DECI
        FIELD tpdrendi AS INTE EXTENT 4
        FIELD dstprend AS CHAR EXTENT 4
        FIELD vldrendi AS DECI EXTENT 4
        FIELD cdturnos AS INTE
        FIELD rsnatocp AS CHAR
        FIELD cepedct1 AS INTE
        FIELD endrect1 AS CHAR
        FIELD nrendcom AS INTE
        FIELD complcom AS CHAR
        FIELD bairoct1 AS CHAR
        FIELD cidadct1 AS CHAR
        FIELD ufresct1 AS CHAR
        FIELD cxpotct1 AS INTE
        FIELD inpolexp AS INTE.

    DEFINE TEMP-TABLE tt-comercial-atl NO-UNDO LIKE tt-comercial-ant.

&ENDIF

DEF TEMP-TABLE tt-rendimentos NO-UNDO
    FIELD tpdrendi AS INT
    FIELD dsdrendi AS CHAR
    FIELD dsorigem AS CHAR
    FIELD vldrendi AS DECI.

DEF TEMP-TABLE tt-ppe NO-UNDO LIKE tbcadast_politico_exposto
    FIELD inpolexp AS INTE
    FIELD nmextttl LIKE crapttl.nmextttl
    FIELD nrcpfcgc LIKE crapttl.nrcpfcgc
    FIELD rsdocupa LIKE gncdocp.rsdocupa
    FIELD dsrelacionamento AS CHAR
    FIELD cidade   AS CHAR.
