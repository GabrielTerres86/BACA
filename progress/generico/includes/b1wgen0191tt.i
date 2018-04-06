/*............................................................................

  Programa: b1wgen0191tt.i 
  Autor   : Jonata-RKAM
  Data    : Outubro/2014                      Ultima atualizacao: 19/12/2017
  
  Dados referentes ao programa:
  
  Objetivo  : Arquivo com variaveis utilizadas na BO b1wgen0191.p.
              Projeto Automatização de Consultas em Propostas
              de Crédito (Jonata-RKAM).
  
  Alteracoes: 11/12/2015 - Inclusao do campo dsmotivo na tt-crapcsf
                           Chamado 363148 (Heitor - RKAM)
                           
              23/09/2016 - Correçao nas TEMP-TABLES colocar NO-UNDO, tt-msg-orgaos (Oscar).

              19/12/2017 - Cricao da tt-erros-bir. (Jaison/James - M464)

.............................................................................*/

DEF TEMP-TABLE tt-xml-geral                                            NO-UNDO
    FIELD dstagavo AS CHAR
    FIELD dstagpai AS CHAR
    FIELD dstagfil AS CHAR
    FIELD dstagnet AS CHAR  
    FIELD dsdvalor AS CHAR.  

DEF TEMP-TABLE tt-craprsc                                               NO-UNDO
    FIELD nrseqreg AS INTE
    FIELD dslocnac AS CHAR
    FIELD dsinstit AS CHAR
    FIELD dsentorg AS CHAR
    FIELD nmcidade AS CHAR
    FIELD cdufende AS CHAR
    FIELD dtregist AS DATE
    FIELD dtvencto AS DATE
    FIELD dsmtvreg AS CHAR
    FIELD vlregist AS DECI
    INDEX tt-craprsc-1 IS PRIMARY UNIQUE nrseqreg.

DEF TEMP-TABLE tt-crapcbd                                               NO-UNDO
    FIELD nrseqreg AS INTE
    FIELD dstagpai AS CHAR
    FIELD dscpfcgc AS CHAR
    FIELD nmtitcon AS CHAR
    FIELD dtentsoc AS DATE
    FIELD percapvt AS DECI
    FIELD pertotal AS DECI
    FIELD dsprofis AS CHAR
    FIELD dtmanadm AS CHAR
    FIELD dtatusoc AS DATE
    FIELD dtentadm AS DATE
    FIELD dtatuadm AS DATE
    FIELD nmvincul AS CHAR
    INDEX tt-crapcbd-1 IS PRIMARY UNIQUE nrseqreg dstagpai.

DEF TEMP-TABLE tt-craprpf                                               NO-UNDO
    FIELD dscpfcgc AS CHAR
    FIELD innegati AS INTE
    FIELD vlnegati AS DECI
    FIELD dtultneg AS DATE
    FIELD dsnegati AS CHAR
    INDEX tt-craprpf-1 IS PRIMARY UNIQUE dscpfcgc innegati.

DEF TEMP-TABLE tt-crapcsf                                               NO-UNDO
    FIELD nrseqreg AS INTE
    FIELD nmbanchq AS CHAR
    FIELD cdagechq AS INTE
    FIELD cdalinea AS INTE
    FIELD dsmotivo AS CHAR
    FIELD qtcheque AS INTE
    FIELD dtultocr AS DATE
    FIELD dtinclus AS DATE
    FIELD nrcheque AS CHAR
    FIELD vlcheque AS DECI
    FIELD nmcidade AS CHAR
    FIELD cdufende AS CHAR
    FIELD intipchq AS INTE
    INDEX tt-crapcsf-1 IS PRIMARY UNIQUE nrseqreg.

DEF TEMP-TABLE tt-crapprf                                               NO-UNDO
    FIELD nrseqreg AS INTE
    FIELD dstagpai AS CHAR
    FIELD inpefref AS INTE
    FIELD dtvencto AS DATE
    FIELD vlregist AS DECI
    FIELD dsinstit AS CHAR
    FIELD dsmtvreg AS CHAR
    FIELD dsnature AS CHAR
    INDEX tt-crapprf-1 IS PRIMARY UNIQUE nrseqreg dstagpai.

DEF TEMP-TABLE tt-crapprt                                               NO-UNDO
    FIELD nrseqreg AS INTE
    FIELD nmlocprt AS CHAR
    FIELD qtprotes AS INTE
    FIELD dtprotes AS DATE
    FIELD vlprotes AS DECI
    FIELD nmcidade AS CHAR
    FIELD cdufende AS CHAR
    INDEX tt-crapprt-1 IS PRIMARY UNIQUE nrseqreg.

DEF TEMP-TABLE tt-crapabr                                               NO-UNDO
    FIELD nrseqreg AS INTE                                             
    FIELD dtacajud AS DATE
    FIELD dsnataca AS CHAR
    FIELD vltotaca AS DECI
    FIELD nrdistri AS INTE
    FIELD nrvaraca AS INTE
    FIELD nmcidade AS CHAR
    FIELD cdufende AS CHAR
    INDEX tt-crapabr-1 IS PRIMARY UNIQUE nrseqreg.

DEF TEMP-TABLE tt-craprfc                                               NO-UNDO
    FIELD nrseqreg AS INTE
    FIELD dtregist AS DATE
    FIELD dstipreg AS CHAR
    FIELD dsorgreg AS CHAR
    FIELD nmcidade AS CHAR
    FIELD cdufende AS CHAR
    INDEX tt-craprfc-1 IS PRIMARY UNIQUE nrseqreg.
                                        
DEF TEMP-TABLE tt-crappsa                                               NO-UNDO
    FIELD nrdecnpj AS CHAR
    FIELD dscpfcgc AS CHAR
    FIELD nmempres AS CHAR
    FIELD nmcidade AS CHAR
    FIELD cdufende AS CHAR
    FIELD pertotal AS INTE
    FIELD nmvincul AS CHAR.

DEF TEMP-TABLE tt-msg-orgaos NO-UNDO
    FIELD dsmensag AS CHAR.

DEF TEMP-TABLE tt-erros-bir NO-UNDO
    FIELD dscritic AS CHAR.


/* ......................................................................... */

