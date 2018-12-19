/*..............................................................................

  Programa: b1wgen0039tt.i
  Autor   : Gabriel
  Data    : Maio/2009                    Ultima atualizacao: 01/11/2010

  Dados referentes ao programa:

  Objetivo  : Arquivo com temp-table`s utlizadas na BO b1wgen0039.p

  Alteracoes: 24/08/2009 - Incluir temp-table tt-inscricoes-conta para 
                           a procedure inscricoes-da-conta 
                         
                         - Retirada da temp-table tt-inscricoes para
                           padronizar passagem de parametros na BO(Gabriel).
                           
              23/10/2009 - Incluir temp-table tt-grau-parentesco (Gabriel).
              
              17/06/2010 - Incluir o cdagenci em tt-inscricoes-conta (Gabriel).
              
              01/11/2010- Inclusao do dtcadqst em tt-qtdade-eventos (Vitor)             

.............................................................................*/

DEF TEMP-TABLE tt-qtdade-eventos     NO-UNDO
    FIELD qtpenden AS INTE
    FIELD qtconfir AS INTE
    FIELD qtandame AS INTE
    FIELD qthispar AS INTE
    FIELD dtinique AS DATE
    FIELD dtfimque AS DATE
    FIELD dtcadqst AS DATE.

DEF TEMP-TABLE tt-eventos-andamento  NO-UNDO
    FIELD cdevento AS INTE
    FIELD idevento AS INTE
    FIELD nmevento AS CHAR
    FIELD qtmaxtur AS INTE
    FIELD qtpenden AS INTE
    FIELD qtconfir AS INTE
    FIELD dtinieve AS CHAR
    FIELD dtfineve AS CHAR
    FIELD nrmeseve AS INTE
    FIELD dsobserv AS CHAR
    FIELD dsrestri AS CHAR
    FIELD nridamin AS INTE
    FIELD flgcompr AS LOGI
    FIELD rowidedp AS ROWID
    FIELD rowidadp AS ROWID
	FIELD nmdgrupo AS CHAR.

DEF TEMP-TABLE tt-detalhe-evento     NO-UNDO
    FIELD nmevento AS CHAR
    FIELD dtinieve AS CHAR
    FIELD dtfineve AS CHAR
    FIELD dshroeve AS CHAR INIT "NAO DETERMINADO"
    FIELD dslocali AS CHAR INIT "NAO DETERMINADO"
    FIELD nmfornec AS CHAR INIT "NAO DETERMINADO"
    FIELD nmfacili AS CHAR INIT "NAO DETERMINADO"
    FIELD dsconteu AS CHAR EXTENT 99.

DEF TEMP-TABLE tt-info-cooperado     NO-UNDO
    FIELD idseqttl AS INTE
    FIELD cdgraupr AS INTE 
    FIELD dsgraupr AS CHAR
    FIELD nminseve AS CHAR 
    FIELD dsdemail AS CHAR
    FIELD nrdddins AS INTE
    FIELD nrtelefo AS INTE
    FIELD dsobserv AS CHAR
    FIELD flgdispe AS LOGI 
    INDEX tt-info-cooperado1 idseqttl.

DEF TEMP-TABLE tt-grau-parentesco    NO-UNDO
    FIELD cdgraupr AS INTE
    FIELD dsgraupr AS CHAR.

DEF TEMP-TABLE tt-inscricoes-conta   NO-UNDO
    FIELD nminseve AS CHAR
    FIELD dtmvtolt AS CHAR
    FIELD nmresage AS CHAR
    FIELD cdagenci AS INTE.
    
DEF TEMP-TABLE tt-situacao-inscricao NO-UNDO     
    FIELD rowididp AS ROWID      
    FIELD nmevento AS CHAR
    FIELD dtinieve AS DATE
    FIELD nminseve AS CHAR
    FIELD dsstaeve AS CHAR
    FIELD dtconins AS DATE
    FIELD flginsin AS LOGI.

DEF TEMP-TABLE tt-crapidp            NO-UNDO LIKE crapidp.

DEF TEMP-TABLE tt-lista-eventos      NO-UNDO
    FIELD nmevento AS CHAR
    FIELD idevento AS INTE
    FIELD cdevento AS INTE
    INDEX tt-lista-eventos1 idevento cdevento.

DEF TEMP-TABLE tt-historico-evento   NO-UNDO
    FIELD nminseve AS CHAR
    FIELD nmevento AS CHAR
    FIELD dtinieve AS DATE
    FIELD dtfineve AS DATE
    FIELD dsstains AS CHAR.

DEF TEMP-TABLE tt-termo              NO-UNDO
    FIELD nmextttl AS CHAR FORMAT      "x(30)"
    FIELD tpinseve AS INTE 
    FIELD nminseve AS CHAR FORMAT      "x(30)"
    FIELD nmevento AS CHAR FORMAT      "x(30)"
    FIELD nmrescop AS CHAR FORMAT      "x(30)"
    FIELD nmextcop AS CHAR 
    FIELD prfreque AS INTE FORMAT        "zz9"
    FIELD vldebito AS DECI FORMAT "zzz,zz9.99"
    FIELD dsdebito AS CHAR FORMAT      "x(15)"
    FIELD prdescon AS DECI FORMAT        "zz9"
    FIELD nrdconta AS DECI FORMAT "zzzz,zzz,9"
    FIELD dspacdat AS CHAR.


/*............................................................................*/
