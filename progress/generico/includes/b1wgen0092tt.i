/*.............................................................................

    Programa: b1wgen0092tt.i                  
    Autor   : André (DB1)
    Data    : Maio/2011                       Ultima atualizacao: 07/11/2017

    Dados referentes ao programa:

    Objetivo  : Temp-tables utlizadas na BO b1wgen0092.p
                Autorizacoes de Debito em Conta

    Alteracoes: 20/08/2014 - Adicionada temp-table tt-convenios-codbarras.
                             (Projeto Debito Facil - Chamado 184458) - 
                             (Fabricio).
                             
                28/08/2014 - Adicionada temp-table tt-autorizacoes-cadastradas.
                             (Projeto Debito Facil - Chamado 184458) - 
                             (Fabricio).
                             
                08/09/2014 - Adicionada temp-table tt-autorizacoes-suspensas.
                             (Projeto Debito Facil - Chamado 184458) - 
                             (Fabricio).
                             
                09/09/2014 - Adicionada temp-table tt-lancamentos.
                             (Projeto Debito Facil - Chamado 184458) - 
                             (Fabricio).
                             
                15/09/2014 - Novos campos na tt-autori para Projeto 
                             de Débito Fácil (Lucas Lunelli - Out/2014).
                            
                30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])
                            
                07/11/2017 - Incluir campos nas temp-tables tt-lancamentos e
                             tt-autorizacoes-cadastradas (David).
                            
.............................................................................*/

DEFINE TEMP-TABLE tt-autori                                             NO-UNDO
    FIELD cdhistor LIKE crapatr.cdhistor
    FIELD dshistor LIKE craphis.dshistor
    FIELD cddddtel LIKE crapatr.cddddtel
    FIELD cdrefere AS DECI FORMAT "zzzzzzzzzzzzzzzzzzzzzzzz9"
    FIELD dtautori LIKE crapatr.dtiniatr
    FIELD dtcancel LIKE crapatr.dtfimatr
    FIELD dtultdeb LIKE crapatr.dtultdeb
    FIELD dtvencto LIKE crapatr.ddvencto
    FIELD nmfatura LIKE crapatr.nmfatura
    FIELD nmempres LIKE crapatr.nmempres
    FIELD nmempcon LIKE gnconve.nmempres
    FIELD vlrmaxdb LIKE crapatr.vlrmaxdb
    FIELD desmaxdb AS CHAR
    FIELD cdempcon LIKE crapatr.cdempcon
    FIELD cdsegmto LIKE crapatr.cdsegmto
    FIELD dbcancel AS LOGI.

DEFINE TEMP-TABLE tt-autori-ant                                        NO-UNDO
    FIELD dtiniatr LIKE crapatr.dtiniatr
    FIELD dtfimatr LIKE crapatr.dtfimatr
    FIELD ddvencto LIKE crapatr.ddvencto
    FIELD nmfatura LIKE crapatr.nmfatura
    FIELD nrdconta LIKE crapatr.nrdconta
    FIELD cdhistor LIKE crapatr.cdhistor
    FIELD cddddtel LIKE crapatr.cddddtel
    FIELD cdrefere LIKE crapatr.cdrefere
    FIELD dtultdeb LIKE crapatr.dtultdeb
    FIELD cdcooper LIKE crapatr.cdcooper
    FIELD cdsegmto LIKE crapatr.cdsegmto
    FIELD cdempcon LIKE crapatr.cdempcon
    FIELD vlrmaxdb LIKE crapatr.vlrmaxdb
    FIELD dtinisus LIKE crapatr.dtinisus
    FIELD dtfimsus LIKE crapatr.dtfimsus
    FIELD dsmotivo AS CHAR FORMAT "x(60)".
            
DEFINE TEMP-TABLE tt-autori-atl NO-UNDO LIKE tt-autori-ant.

DEFINE TEMP-TABLE tt-sms-telefones                                     NO-UNDO
    FIELD idseqttl LIKE craptfc.idseqttl
    FIELD cdseqtfc LIKE craptfc.cdseqtfc
    FIELD flgacsms LIKE craptfc.flgacsms
    FIELD nrdddtfc LIKE craptfc.nrdddtfc
    FIELD nrtelefo LIKE craptfc.nrtelefo
    FIELD prgqfalt LIKE craptfc.prgqfalt.
    
DEFINE TEMP-TABLE tt-sms-telefones-ant 
   FIELD nrdddtfc LIKE craptfc.nrdddtfc
   FIELD nrtelefo LIKE craptfc.nrtelefo.
   
DEFINE TEMP-TABLE tt-sms-telefones-atl NO-UNDO LIKE tt-sms-telefones-ant.

DEF TEMP-TABLE tt-crapscn NO-UNDO 
    FIELD cdhistor AS CHAR
    FIELD dshistor AS CHAR.

DEF TEMP-TABLE tt-convenios-codbarras NO-UNDO
    FIELD nmextcon LIKE crapcon.nmextcon
    FIELD nmrescon LIKE crapcon.nmrescon
    FIELD flgcnvsi LIKE crapcon.flgcnvsi
    FIELD cdempcon LIKE crapcon.cdempcon
    FIELD cdsegmto LIKE crapcon.cdsegmto
    FIELD cdhistor LIKE crapcon.cdhistor.

DEF TEMP-TABLE tt-autorizacoes-cadastradas NO-UNDO
    FIELD nmextcon LIKE crapcon.nmextcon
    FIELD nmrescon LIKE crapcon.nmrescon
    FIELD cdempcon LIKE crapatr.cdempcon
    FIELD cdsegmto LIKE crapatr.cdsegmto
    FIELD cdrefere LIKE crapatr.cdrefere
    FIELD vlmaxdeb LIKE crapatr.vlrmaxdb
    FIELD dshisext LIKE crapatr.dshisext
    FIELD inaltera AS LOGICAL
    FIELD cdhistor AS INTEGER
    FIELD insituac AS INTEGER
    FIELD dssituac AS CHAR
    FIELD dssegmto AS CHAR.

DEF TEMP-TABLE tt-autorizacoes-suspensas NO-UNDO
    FIELD nmextcon LIKE crapcon.nmextcon
    FIELD nmrescon LIKE crapcon.nmrescon
    FIELD cdempcon LIKE crapatr.cdempcon
    FIELD cdsegmto LIKE crapatr.cdsegmto
    FIELD cdrefere LIKE crapatr.cdrefere
    FIELD dtinisus LIKE crapatr.dtinisus
    FIELD dtfimsus LIKE crapatr.dtfimsus.

DEF TEMP-TABLE tt-lancamentos NO-UNDO
    FIELD dtmvtolt LIKE craplcm.dtmvtolt
    FIELD nmextcon LIKE crapcon.nmextcon
    FIELD dshisext LIKE crapatr.dshisext
    FIELD nrdocmto LIKE craplcm.nrdocmto
    FIELD vllanmto LIKE craplcm.vllanmto
    FIELD situacao LIKE crapatr.dshisext
    FIELD cdhistor LIKE craplcm.cdhistor
    FIELD insituac AS INTEGER
    FIELD dsprotoc LIKE crappro.dsprotoc.
    
DEF TEMP-TABLE tt-motivos-cancel-debaut NO-UNDO
    FIELD idmotivo AS INTEGER
    FIELD dsmotivo AS CHARACTER.

/*...........................................................................*/
