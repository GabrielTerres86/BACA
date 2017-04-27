/*..............................................................................

    Programa: b1wgen0050tt.i                  
    Autor   : David
    Data    : Novembro/2009                   Ultima atualizacao: 07/03/2017

    Dados referentes ao programa:

    Objetivo  : Temp-tables utlizadas na BO b1wgen0050.p - Log SPB.

    Alteracoes: 26/06/2010 - Trocados tipo das variaveis nrctarem e nrctadst de
                             decimal para char - conta com digito X (Fernando).
                             
                16/07/2010 - Incluido os campos qtdrejok e vlrrejok na 
                             TEMP-TABLE tt-logspb-totais (Elton).
                             
                16/04/2012 - Inclusao do campo dsorigem na temp-table
                             tt-logspb-detalhe. (Fabricio)
                             
                30/07/2012 - Inclusão de novos campos na temp-table tt-logspb-detalhe
                             cdagenci, nrdcaixa, cdoperad. ( Lucas R. ).
                             
                04/09/2014 - Inclusao do campo dttransa na temp-table tt-logspb-detalhe 
                             CHAMADO: 161899 - (Jonathan - RKAM)
                
                14/04/2015 - Inclusão dos campos cdisprem e cdispdst na temp-table
                             tt-logspb-detalhe SD271603 FDR041 (Vanessa)
                             
                04/05/2015 - Inclusao do campo dstiptra na temp-table
                             tt-logspb-detalhe. (Dionathan)
                             
                10/08/2015 - Incluir campos nmevento, nrctrlif na temp-table
                             tt-logspb-detalhe (Lucas Ranghetti - Gestao de Teds/Tecs)

                07/03/2017 - Incluir campo dsprotoc na temp-table
				             tt-logspb-detalhe, PRJ335 - OFSSA (Odirlei-AMcom)				  

..............................................................................*/

DEF TEMP-TABLE tt-logspb           NO-UNDO
    FIELD nrseqlog AS INTE
    FIELD dslinlog AS CHAR
    INDEX tt-logspb1 AS PRIMARY nrseqlog.

DEF TEMP-TABLE tt-logspb-detalhe   NO-UNDO
    FIELD nrseqlog AS INTE
    FIELD cdbandst AS INTE
    FIELD cdagedst AS INTE
    FIELD nrctadst AS CHAR
    FIELD dsnomdst AS CHAR
    FIELD dscpfdst AS DECI
    FIELD cdbanrem AS INTE
    FIELD cdagerem AS INTE
    FIELD nrctarem AS CHAR
    FIELD dsnomrem AS CHAR
    FIELD dscpfrem AS DECI
    FIELD hrtransa AS CHAR
    FIELD vltransa AS DECI
    FIELD dsmotivo AS CHAR
    FIELD dstransa AS CHAR
    FIELD dsorigem AS CHAR
    FIELD cdagenci AS INTE
    FIELD nrdcaixa AS INTE
    FIELD cdoperad AS CHAR
    FIELD dttransa AS DATE
    FIELD nrsequen AS INTE
    FIELD cdisprem AS INTE
    FIELD cdispdst AS INTE
    FIELD cdtiptra AS INTE
    FIELD dstiptra AS CHAR
    FIELD nmevento LIKE craplmt.nmevento
    FIELD nrctrlif LIKE craplmt.nrctrlif
	  FIELD dsprotoc AS CHAR
    INDEX tt-logspb1 AS PRIMARY hrtransa nrseqlog.

DEF TEMP-TABLE tt-logspb-totais    NO-UNDO
    FIELD qtdenvok AS INTE
    FIELD vlrenvok AS DECI
    FIELD qtdrecok AS INTE
    FIELD vlrrecok AS DECI
    FIELD qtenvnok AS INTE
    FIELD vlenvnok AS DECI
    FIELD qtrecnok AS INTE
    FIELD vlrecnok AS DECI
    FIELD qtrejeit AS INTE
    FIELD qtdrejok AS INTE  
    FIELD vlrrejok AS DECI.

/*............................................................................*/
