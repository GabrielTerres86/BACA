/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0013tt.i
    Autor   : Guilherme / SUPERO
    Data    : Marco/2013              Ultima Atualizacao:   /  /    
     
    Dados referentes ao programa:
   
    Objetivo  : Includes referente a BO b1wgen0013.
                 
    Alteracoes: 

.............................................................................*/

DEF TEMP-TABLE tt-cooper
    FIELD cdcooper AS INT
    FIELD nmrescop AS CHAR
    .

DEF TEMP-TABLE tt-resultados NO-UNDO
    FIELD idresult AS INT /* Tipo Pesquisa (1-Acessada 2-Nao Aces. 3-Nunca */
    FIELD rowid    AS CHAR
    FIELD dsdatela AS CHAR
    FIELD cdcooper AS INT
    FIELD dscooper AS CHAR
    FIELD idorigem AS INT
    FIELD dsorigem AS CHAR
    FIELD qtdusuar AS INT
    FIELD qtdacess AS INT
   INDEX ix-res-1 dsdatela cdcooper idorigem.

DEF TEMP-TABLE tt-resulta LIKE tt-resultados.

DEF TEMP-TABLE tt-detalhes
    FIELD rowid    AS CHAR
    FIELD dsdatela AS CHAR
    FIELD cdcooper AS INT
    FIELD dscooper AS CHAR
    FIELD idorigem AS INT
    FIELD dsorigem AS CHAR
    FIELD cdoperad AS CHAR
    FIELD nmoperad AS CHAR
    FIELD cdagenci AS INT
    FIELD qtdacess AS INT
    INDEX ix-usr-1 cdoperad.

DEF TEMP-TABLE tt-detalhe-pesquisa LIKE tt-detalhes.


