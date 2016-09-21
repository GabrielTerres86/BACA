/*..............................................................................

  Programa: b1wgen0043tt.i
  Autor   : Gabriel
  Data    : Setembro/2009                       Ultima atualizacao: 12/09/2011

  Dados referentes ao programa:

  Objetivo  : Arquivo com temp-tables utilizada na b1wgen0043.p

  Alteracoes: 00/00/0000 - Criado temp-table tt-itens_topico_rating
  
              01/06/2010 - Incluir campo nrctrrat na tt-impressao-coop (David).
              
              01/03/2011 - Incluir campo vlrcoope na tt-impressao-risco 
                         - Incluir tt-impressao-risco-tl copia
                         - Inluir campo nrnotatl na tt-ratings
                           (Guilherme).
                           
              14/04/2011 - Incluido campo intopico na temp-table 
                           tt-impressao-rating. (Fabricio)
                           
              11/08/2011 - Incluir campo dtrefere na tt-ratings (Guilherme).
              
              12/09/2011 - Incluir tt-rating-singulares - Rating na Central 
                           (Guilherme).
..............................................................................*/

/* Informacoes do cooperado na impressao do Rating */
DEF TEMP-TABLE tt-impressao-coop      NO-UNDO
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR
    FIELD dspessoa AS CHAR
    FIELD dsdopera AS CHAR
    FIELD nrctrrat AS INTE
    FIELD tpctrrat AS INTE.
               
/* Itens do Rating */
DEF TEMP-TABLE tt-impressao-rating    NO-UNDO
    FIELD intopico AS INTE
    FIELD nrtopico AS INTE
    FIELD nritetop AS INTE
    FIELD nrseqite AS INTE
    FIELD dsitetop AS CHAR
    FIELD dspesoit AS CHAR.

/* Nota e risco do cooperado naquele Rating - PROVISAOCL */
DEF TEMP-TABLE tt-impressao-risco     NO-UNDO
    FIELD vlrtotal AS DECI
    FIELD dsdrisco AS CHAR
    FIELD vlprovis AS DECI
    FIELD dsparece AS CHAR
    FIELD vlrcoope AS DECI.

/* Nota e risco do cooperado naquele Rating - PROVISAOTL */
DEF TEMP-TABLE tt-impressao-risco-tl     NO-UNDO
    FIELD vlrtotal AS DECI
    FIELD vlrcoope AS DECI
    FIELD dsdrisco AS CHAR
    FIELD vlprovis AS DECI
    FIELD dsparece AS CHAR.


/* Assinatura na impressao do Rating */
DEF TEMP-TABLE tt-impressao-assina    NO-UNDO
    FIELD dsdedata AS CHAR
    FIELD nmoperad AS CHAR
    FIELD dsrespon AS CHAR.

/* Descricao do item do RATING */
DEF TEMP-TABLE tt-itens-rating        NO-UNDO
    FIELD nrseqite AS INTE
    FIELD dsseqite AS CHAR
    FIELD nrtopico LIKE craprat.nrtopico.

/* Sequencias de itens RATING */
DEF TEMP-TABLE tt-itens-topico-rating NO-UNDO
    FIELD nrtopico LIKE craprad.nrtopico
    FIELD nritetop LIKE craprad.nritetop
    FIELD nrseqite LIKE craprad.nrseqite
    FIELD dsseqite LIKE craprad.dsseqite
    FIELD selecion AS CHAR.

/* Topicos RATING */
DEF TEMP-TABLE tt-topicos-rating      NO-UNDO
    FIELD nrtopico LIKE craprat.nrtopico
    FIELD dstopico LIKE craprat.dstopico.


/* Temp-table interna da BO, para o calculo do Rating */
DEF TEMP-TABLE tt-crapras             NO-UNDO      
    FIELD nrtopico AS INTE
    FIELD nritetop AS INTE
    FIELD nrseqite AS INTE.

/* Usada na hora de efetivacao do Rating */
DEF TEMP-TABLE tt-efetivacao          NO-UNDO
    FIELD dsdefeti AS CHAR
    FIELD idseqmen AS INTE.
    

/* Informacoes com os Ratings do Cooperado */
DEF TEMP-TABLE tt-ratings             NO-UNDO
    FIELD cdagenci AS INTE
    FIELD nrdconta AS INTE
    FIELD nrctrrat AS INTE
    FIELD tpctrrat AS INTE
    FIELD indrisco AS CHAR
    FIELD dtmvtolt AS DATE
    FIELD dteftrat AS DATE
    FIELD cdoperad AS CHAR
    FIELD insitrat AS INTE
    FIELD dsditrat AS CHAR
    FIELD nrnotrat AS DECI
    FIELD vlutlrat AS DECI
    FIELD vloperac AS DECI
    FIELD dsdopera AS CHAR
    FIELD dsdrisco AS CHAR
    FIELD flgorige AS LOGI
    FIELD inrisctl AS CHAR
    FIELD nrnotatl AS DECI
    FIELD dtrefere AS DATE.

/* Informacoes dos campos de rating do cooperado */
DEF TEMP-TABLE tt-valores-rating        NO-UNDO
    FIELD nrinfcad AS INTE 
    FIELD nrpatlvr AS INTE 
    FIELD nrperger AS INTE
    FIELD vltotsfn AS DECI
    FIELD perfatcl LIKE crapjfn.perfatcl
    FIELD nrgarope AS INTE
    FIELD nrliquid AS INTE
    FIELD inpessoa AS INTE.

/* Tabela temporaria de ratings da cooperativa singular na cecred */
DEF TEMP-TABLE tt-rating-singulares     NO-UNDO
    FIELD nrtopico AS INTE
    FIELD nritetop AS INTE
    FIELD nrseqite AS INTE.

DEF TEMP-TABLE tt-singulares            NO-UNDO
    FIELD nrtopico AS INTE
    FIELD nritetop AS INTE
    FIELD nrseqite AS INTE.
/*............................................................................*/
