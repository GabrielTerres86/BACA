/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0119tt.i                  
    Autor(a): Fabricio
    Data    : Dezembro/2011                      Ultima atualizacao: 26/02/2014
  
    Dados referentes ao programa:
  
    Objetivo  : Definicao das temp-tables para a tela PAMCAR.
                
  
    Alteracoes: 10/02/2012 - Criado o campo pertxpam na tabela 
                             tt-criticas-rel615 (Adriano).
                             
                26/02/2014 - Adicionado campo flgdemis 'a temp-table
                             tt-dados-conta. (Fabricio)
                             
.............................................................................*/



DEF TEMP-TABLE tt-crapcop NO-UNDO
    FIELD codcoope AS INTE
    FIELD nmrescop AS CHAR.


DEF TEMP-TABLE tt-dados-conta NO-UNDO
    FIELD nrdconta AS INTE
    FIELD nrdctitg AS CHAR
    FIELD dssititg AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD nrcpfcgc AS DECI
    FIELD flgpamca AS LOGI
    FIELD vllimpam AS DECI
    FIELD dddebpam AS INTE
    FIELD nrctapam AS INTE
    FIELD flgdemis AS LOGI.

DEF TEMP-TABLE tt-criticas-rel615 NO-UNDO
    FIELD cdagenci AS INTE
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR
    FIELD nrcpfcgc AS DECI
    FIELD vllanmto AS DECI
    FIELD pertxpam AS DECI
    FIELD dscritic AS CHAR.

DEF TEMP-TABLE tt-debitos-rel615 NO-UNDO
    FIELD cdagenci AS INTE
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR
    FIELD nrcpfcgc AS DECI
    FIELD vllanmto AS DECI
    FIELD pertxpam AS DECI.

DEF TEMP-TABLE tt-log-processamento NO-UNDO
    FIELD nmarquiv AS CHAR
    FIELD dsstatus AS CHAR
    FIELD dtproces AS DATE.
