
/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0153tt.i
    Autor   : Tiago / Daniel
    Data    : Fevereiro/2013              Ultima Atualizacao: 08/03/2016
     
    Dados referentes ao programa:
   
    Objetivo  : Includes referente a BO b1wgen0153.
                 
    Alteracoes: 
                31/07/2013 - Incluido mais 2 campos na tt-atribdet, 
                             nrconven e dsconven (Tiago).
                             
                14/08/2015 - Inclusão do campo nmoperad na tt-atribdet
                             Projeto Melhorias Tarifas (Carlos Rafael Tanholi)
                             
                01/09/2015 - Criacao de campos na tt-faixavalores para o
                             Projeto Melhorias Tarifas (Jaison/Diego)
                             
                08/03/2016 - Inclusao da TT tt-tbtarif-pacotes, Prj. 218,
                             Pacotes de Tarifas (Jean Michel).
							 
				11/07/2017 - Melhoria 150 - adicionado campos na estrutura
                             tt-atribdet
.............................................................................*/

DEF TEMP-TABLE tt-grupos NO-UNDO
    FIELD cddgrupo AS INTE
    FIELD dsdgrupo AS CHAR.
                                   
DEF TEMP-TABLE tt-subgrupos NO-UNDO
    FIELD cdsubgru AS INTE
    FIELD dssubgru AS CHAR
    FIELD cddgrupo AS INTE.

DEF TEMP-TABLE tt-cadint NO-UNDO
    FIELD cdinctar AS INTE
    FIELD dsinctar AS CHAR
    FIELD flgocorr AS LOG
    FIELD flgmotiv AS LOG.

DEF TEMP-TABLE tt-tipcat NO-UNDO
    FIELD cdtipcat AS INTE
    FIELD dstipcat AS CHAR.

DEF TEMP-TABLE tt-categorias NO-UNDO
    FIELD cdcatego AS INTE
    FIELD dscatego AS CHAR
    FIELD cdsubgru AS INTE
    FIELD cddgrupo AS INTE
    FIELD cdtipcat AS INTE.

DEF TEMP-TABLE tt-faixavalores NO-UNDO
    FIELD cdfaixav AS INTE
    FIELD vlinifvl AS DECI
    FIELD vlfinfvl AS DECI
    FIELD cdhistor AS INTE
    FIELD dshistor AS CHAR
    FIELD cdhisest AS INTE
    FIELD dshisest AS CHAR
    FIELD cdtarifa AS INTE
    FIELD dstarifa AS CHAR
    FIELD vltarifa AS DECI
    FIELD cdocorre AS INTE
    FIELD nrconven AS INTE
    FIELD cdlcremp AS INTE.

DEF TEMP-TABLE tt-historicos NO-UNDO
    FIELD cdhistor AS INTE
    FIELD dshistor AS CHAR.

DEF TEMP-TABLE tt-tarifas NO-UNDO
    FIELD cdtarifa AS INTE
    FIELD dstarifa AS CHAR
    FIELD cdmotivo AS CHAR
    FIELD cdocorre AS INTE
    FIELD inpessoa AS INTE
    FIELD flglaman AS LOG
    FIELD idinctar AS INTE
    FIELD dsinctar AS CHAR
    FIELD cddgrupo AS INTE
    FIELD dsdgrupo AS CHAR
    FIELD cdsubgru AS INTE
    FIELD dssubgru AS CHAR
    FIELD cdcatego AS INTE
    FIELD dscatego AS CHAR
    FIELD cdhistor AS INTE
    FIELD dshistor AS CHAR
    FIELD vltarifa AS DECI
    FIELD cdfaixav AS INTE
    FIELD cdfvlcop AS INTE
    FIELD bloqueia AS INTE
    FIELD dspessoa AS CHAR.

DEF TEMP-TABLE tt-met NO-UNDO
    FIELD cdmotest AS INTE
    FIELD dsmotest AS CHAR
    FIELD tpaplica AS INTE.

DEF TEMP-TABLE tt-agenci NO-UNDO
    FIELD cdcooper AS INTE
    FIELD nmrescop AS CHAR
    FIELD cdagenci AS INTE
    FIELD nmresage AS CHAR.

DEF TEMP-TABLE tt-partar NO-UNDO
    FIELD cdpartar AS INTE
    FIELD nmpartar AS CHAR
    FIELD tpdedado AS INTE.

DEF TEMP-TABLE tt-cooper NO-UNDO
    FIELD cdcooper AS INTE 
    FIELD nmrescop AS CHAR
    FIELD nrconven AS INTE
    FIELD cdlcremp AS INTE.

DEF TEMP-TABLE tt-parametros NO-UNDO
    FIELD cdpartar AS INTE
    FIELD cdcooper AS INTE
    FIELD dsconteu AS CHAR
    FIELD nmrescop AS CHAR.

DEF TEMP-TABLE tt-atribdet NO-UNDO
    FIELD cdfvlcop AS INTE
    FIELD cdfaixav AS INTE
    FIELD cdcooper AS INTE
    FIELD nmrescop AS CHAR
    FIELD dtdivulg AS DATE
    FIELD dtvigenc AS DATE
    FIELD vltarifa AS DECI
    FIELD vlrepass AS DECI
    FIELD nrconven AS INTE
    FIELD dsconven AS CHAR
    FIELD cdlcremp AS INTE
    FIELD dslcremp AS CHAR
    FIELD nmoperad AS CHAR
	FIELD tpcobtar AS INTE
	FIELD vlpertar AS DECI
	FIELD vlmintar AS DECI
	FIELD vlmaxtar AS DECI.

DEF TEMP-TABLE tt-associados NO-UNDO
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR
    FIELD cdagenci AS INTE
    FIELD inpessoa AS INTE
    FIELD cdtipcta AS INTE
    FIELD dstipcta AS CHAR
    FIELD nrmatric AS INTE
    FIELD qtdchcus AS INTE
    FIELD nrctafmt AS CHAR
    INDEX tt-associados1 nrdconta.

DEF TEMP-TABLE tt-tpconta NO-UNDO
    FIELD cdtipcta AS INTE
    FIELD dstipcta AS CHAR.

DEF TEMP-TABLE tt-battar NO-UNDO LIKE crapbat
    FIELD dscadast AS CHAR.
    

DEF TEMP-TABLE tt-estorno NO-UNDO
    FIELD cdlantar AS INTE
    FIELD dtmvtolt AS DATE
    FIELD cdhistor AS INTE
    FIELD dshistor AS CHAR
    FIELD nrdocmto AS INTE
    FIELD vltarifa AS DECI
    FIELD cdcooper AS INTE
    FIELD cdagenci AS INTE.    

DEF   TEMP-TABLE tt-receita  NO-UNDO
      FIELD dtmvtolt AS  DATE
      FIELD cdhistor AS  INTE
      FIELD dshistor AS  CHAR
      FIELD nrdconta LIKE crapass.nrdconta
      FIELD vltarifa AS  DECI
      FIELD vlrepass AS  DECI
      FIELD cdcooper AS INTE
      FIELD cdagenci AS INTE
      FIELD inpessoa AS CHAR.

DEF   TEMP-TABLE tt-relestorno  NO-UNDO
      FIELD dtmvtolt AS  DATE
      FIELD cdhistor AS  INTE
      FIELD dshistor AS  CHAR
      FIELD nrdconta LIKE crapass.nrdconta
      FIELD vltarifa AS  DECI
      FIELD dsmotest AS  CHAR
      FIELD cdcooper AS INTE
      FIELD cdagenci AS INTE
      FIELD inpessoa AS CHAR.

DEF TEMP-TABLE tt-convenios NO-UNDO
      FIELD cdcooper AS INTE
      FIELD nrconven AS INTE
      FIELD dsconven AS CHAR.


DEF TEMP-TABLE tt-linhas-cred NO-UNDO
      FIELD cdcooper AS INTE
      FIELD cdlcremp AS INTE
      FIELD dslcremp AS CHAR.

DEF TEMP-TABLE tt-vigenc NO-UNDO
      FIELD cdfvlcop LIKE crapfco.cdfvlcop
      FIELD dtvigenc LIKE crapfco.dtvigenc
      FIELD cdfaixav LIKE crapfvl.cdfaixav
      FIELD nrconven LIKE crapfco.nrconven
      FIELD cdocorre LIKE craptar.cdocorre
      FIELD cdmotivo LIKE craptar.cdmotivo
      FIELD cdlcremp LIKE crapfco.cdlcremp
      FIELD qtdiavig AS   INTE.

DEF TEMP-TABLE tt-tbtarif-pacotes NO-UNDO
    FIELD cddopcao AS CHAR
    FIELD dstarifa AS CHAR
    FIELD dtmvtolt AS DATE
    FIELD dtcancelamento AS DATE
    FIELD tppessoa AS INTE 
    FIELD dspessoa AS CHAR
    FIELD cdpacote AS INTE
    FIELD dspacote AS CHAR
    FIELD flgsituacao AS INTE
    FIELD cdtarifa_lancamento AS INTE
	FIELD vlpacote AS CHAR.
