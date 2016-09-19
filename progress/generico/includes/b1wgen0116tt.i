
/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0116tt.i
    Autor(a): Jorge Issamu Hamaguchi
    Data    : Outubro/2011                      Ultima atualizacao: 15/08/2012
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0116.
  
    Alteracoes: 15/08/2012 - Criado tt-dsidpara e tt-cadmsg. (Jorge)
    
.............................................................................*/

DEF TEMP-TABLE tt-mensagens NO-UNDO
    FIELD cdcooper  LIKE crapmsg.cdcooper
    FIELD nrdconta  LIKE crapmsg.nrdconta
    FIELD idseqttl  LIKE crapmsg.idseqttl
    FIELD nrdmensg  LIKE crapmsg.nrdmensg
    FIELD cdprogra  LIKE crapmsg.cdprogra
    FIELD dtdmensg  LIKE crapmsg.dtdmensg
    FIELD hrdmensg  LIKE crapmsg.hrdmensg
    FIELD dsdremet  LIKE crapmsg.dsdremet
    FIELD dsdassun  LIKE crapmsg.dsdassun
    FIELD dsdmensg  LIKE crapmsg.dsdmensg
    FIELD flgleitu  LIKE crapmsg.flgleitu
    FIELD dtdleitu  LIKE crapmsg.dtdleitu
    FIELD hrdleitu  LIKE crapmsg.hrdleitu
    FIELD inpriori  LIKE crapmsg.inpriori
    FIELD flgexclu  LIKE crapmsg.flgexclu
    FIELD qtdresul  AS INTE.

DEF TEMP-TABLE tt-cadmsg NO-UNDO
    LIKE crapcdm.

DEF TEMP-TABLE tt-dsidpara NO-UNDO
    FIELD cdcooper  LIKE crapmsg.cdcooper
    FIELD nrdconta  LIKE crapmsg.nrdconta.





