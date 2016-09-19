/*..............................................................................

    Programa: sistema/generico/includes/b1wgen0079tt.i                  
    Autor   : David
    Data    : Dezembro/2010                      Ultima atualizacao: 12/03/2012

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0079.p

   Alteracoes: 
   
   26/12/2011 - Adicionado campo vlliquid em tt-titulos-sacado-dda (Jorge).
   
   30/01/2012 - Adicionado campo vldsccal, vljurcal, vlmulcal e vltotcob em 
                tt-titulos-sacado-dda (Jorge).
                
   12/03/2012 - Adicionado campo dtlimpgt em tt-titulos-sacado-dda.(Jorge) 
                            
..............................................................................*/


DEF TEMP-TABLE tt-titulos-sacado-dda                                    NO-UNDO
    FIELD nrorditm AS INTE 
    FIELD idtitdda AS DECI 
    FIELD nmdsacad AS CHAR
    FIELD nmressac AS CHAR
    FIELD tppessac AS CHAR 
    FIELD nrdocsac AS DECI 
    FIELD dsdocsac AS CHAR
    FIELD cdbccced AS CHAR
    FIELD nmbccced AS CHAR
    FIELD nmcedent AS CHAR 
    FIELD nmresced AS CHAR
    FIELD nmcedhis AS CHAR
    FIELD tppesced AS CHAR 
    FIELD nrdocced AS DECI 
    FIELD dsdocced AS CHAR
    FIELD nrdocmto AS CHAR 
    FIELD dtvencto AS DATE 
    FIELD cddmoeda AS CHAR 
    FIELD dsdmoeda AS CHAR
    FIELD vltitulo AS DECI 
    FIELD nossonum AS CHAR 
    FIELD dtemissa AS DATE 
    FIELD qtdiapro AS INTE 
    FIELD vlrabati AS DECI 
    FIELD vlrdmora AS DECI 
    FIELD cdtpmora AS CHAR
    FIELD dtdamora AS DATE
    FIELD dsdamora AS CHAR
    FIELD vlrmulta AS DECI 
    FIELD cdtpmult AS CHAR
    FIELD dtdmulta AS DATE
    FIELD dsdmulta AS CHAR
    FIELD nmsacava AS CHAR
    FIELD nrdocsav AS DECI
    FIELD dsdocsav AS CHAR
    FIELD cdsittit AS INTE 
    FIELD dssittit AS CHAR 
    FIELD dscodbar AS CHAR 
    FIELD dslindig AS CHAR 
    FIELD idtpdpag AS INTE 
    FIELD flgvenci AS LOGI 
    FIELD flgpghab AS LOGI
    FIELD cdcartei AS CHAR
    FIELD dscartei AS CHAR
    FIELD idtitneg AS CHAR
    FIELD vlliquid AS DECI
    FIELD vldsccal AS DECI
    FIELD vljurcal AS DECI
    FIELD vlmulcal AS DECI
    FIELD vltotcob AS DECI
    FIELD dtlimpgt AS DATE
    INDEX tt-titulos-sacado-dda1 AS PRIMARY nrorditm.

DEF TEMP-TABLE tt-instr-tit-sacado-dda NO-UNDO
    FIELD nrorditm AS INTE
    FIELD dsdinstr AS CHAR
    INDEX tt-instr-tit-sacado-dda1 AS PRIMARY nrorditm.

DEF TEMP-TABLE tt-descto-tit-sacado-dda NO-UNDO
    FIELD nrorditm AS INTE
    FIELD dtlimdsc AS DATE
    FIELD cdtpdesc AS CHAR
    FIELD dstpdesc AS CHAR
    FIELD vldescto AS DECI
    FIELD dsdescto AS CHAR
    INDEX tt-descto-tit-sacado-dda1 AS PRIMARY nrorditm.

DEF TEMP-TABLE tt-consulta-situacao NO-UNDO
    FIELD flgativo AS LOGI 
    FIELD cdsituac AS INTE
    FIELD dtsituac AS DATE
    FIELD qtadesao AS INTE
    FIELD dtadesao AS DATE
    FIELD dtexclus AS DATE
    FIELD flsacpro AS LOGI FORMAT "SIM/NAO".

DEF TEMP-TABLE tt-verificar-lote
    FIELD tppessoa AS CHAR
    FIELD nrcpfsac AS DECI
    FIELD flgativo AS LOGI.

DEF TEMP-TABLE tt-grupo-titulos-sacado-dda LIKE tt-titulos-sacado-dda.

DEF TEMP-TABLE tt-grupo-instr-tit-sacado-dda LIKE tt-instr-tit-sacado-dda.

DEF TEMP-TABLE tt-grupo-descto-tit-sacado-dda LIKE tt-descto-tit-sacado-dda.



/*............................................................................*/




