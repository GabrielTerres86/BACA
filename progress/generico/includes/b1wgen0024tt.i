/*............................................................................

  Programa: b1wgen0024tt.i 
  Autor   : Gabriel
  Data    : Junho/2010                      Ultima atualizacao:  09/06/2015
  
  Dados referentes ao programa:
  
  Objetivo  : Arquivo com variaveis utilizadas na BO b1wgen0024.p
  
  Alteracoes: 23/07/2010 - Incluir novas temp-table para a fase II
                           do projeto de melhorias de propostas (Gabriel).
                           
              24/11/2011 - Criado o campo dsjusren na tabela tt-rendimento
                           (Adriano).
                           
              12/07/2013 - Adicionado NO-UNDO em todas as temp-tables.
                           (Fabricio)

              22/08/2014 - Projeto Automatização de Consultas em Propostas
                           de Crédito (Jonata-RKAM).
              
              09/06/2015 - Alterada a ordenacao da tt-contratos para dtmvtolt 
                           SD 279116 (Kelvin).
.............................................................................*/

DEF TEMP-TABLE tt-contratos NO-UNDO
    FIELD cdagenci AS INTE
    FIELD nrdconta AS INTE
    FIELD nrctrato AS INTE
    FIELD dsoperac AS CHAR
    FIELD dtmvtolt AS DATETIME
    FIELD dsdimpri AS CHAR
    FIELD nomedarq AS CHAR
    FIELD vloperac AS DECI
    FIELD nmprimtl AS CHAR
    INDEX tt-contratos1
          dtmvtolt ASC.
    
DEF TEMP-TABLE tt-rendimento NO-UNDO
    FIELD tpdrendi AS INTE EXTENT 6
    FIELD dsdrendi AS CHAR EXTENT 6
    FIELD vldrendi AS DECI EXTENT 6
    FIELD vlsalari AS DECI
    FIELD vlsalcon AS DECI /* Para o ayllos caracter */
    FIELD nmextemp AS CHAR
    FIELD perfatcl AS DECI
    FIELD vlmedfat AS DECI
    FIELD inpessoa AS INTE
    FIELD flgconju AS LOGI
    FIELD nrctacje AS INTE
    FIELD nrcpfcjg AS DECI
    FIELD flgdocje AS LOGI FORMAT "Sim/Nao"
    FIELD vloutras AS DECI
    FIELD vlalugue AS DECI
    FIELD dsjusren AS CHAR
    FIELD inconcje AS LOGI.

DEF TEMP-TABLE tt-dados-analise NO-UNDO
    FIELD nrperger AS INTE
    FIELD dsperger AS CHAR
    FIELD dtcnsspc AS DATE
    FIELD nrinfcad AS INTE INIT 1
    FIELD dsinfcad AS CHAR
    FIELD dtdrisco AS DATE
    FIELD vltotsfn AS DECI
    FIELD qtopescr AS INTE
    FIELD qtifoper AS INTE
    FIELD nrliquid AS INTE
    FIELD dsliquid AS CHAR
    FIELD vlopescr AS DECI
    FIELD vlrpreju AS DECI
    FIELD nrpatlvr AS INTE
    FIELD dspatlvr AS CHAR
    FIELD nrgarope AS INTE
    FIELD dsgarope AS CHAR
    FIELD dtoutspc AS DATE
    FIELD dtoutris AS DATE
    FIELD vlsfnout AS DECI
    FIELD flgcentr AS LOGI
    FIELD flgcoout AS LOGI.

DEF TEMP-TABLE tt-central-risco NO-UNDO
    FIELD dtdrisco AS DATE
    FIELD qtopescr AS INTE
    FIELD qtifoper AS INTE
    FIELD vltotsfn AS DECI
    FIELD vlopescr AS DECI
    FIELD vlrpreju AS DECI.

DEF TEMP-TABLE tt-valores-gerais NO-UNDO
    FIELD nmprimtl AS CHAR
    FIELD nrdconta AS INTE
    FIELD vlsmdtri AS DECI
    FIELD vldcotas AS DECI
    FIELD vlprepla AS DECI
    FIELD vlsldapl AS DECI.

DEF TEMP-TABLE tt-rotativos NO-UNDO
    FIELD dsoperac AS CHAR
    FIELD vllimite AS DECI
    FIELD vlutiliz AS DECI
    FIELD dsgarant AS CHAR
    FIELD dtmvtolt AS DATE.

/* ..........................................................................*/
