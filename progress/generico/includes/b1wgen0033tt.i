/*..............................................................................

   Programa: b1wgen00333t.i                  
   Autor   : Guilherme
   Data    : Agosto/2008                  Ultima atualizacao:  04/08/2017

   Dados referentes ao programa:

   Objetivo  : Temp-tables utlizadas na BO b1wgen0033.p - Seguros           

   Alteracoes: 07/11/2008 - Definida nova temp-table tt-seguros_autos (Gabriel)
            
               31/08/2011 - Adicionado os campos tpoperac, nmbenvid,
                            dsgraupr e txpartic na tabela temporaria
                            tt-seguros.
                            Criadas temp-tables tt-gar-seg, tt-empresa,
                            tt-cooperativa, tt-associado, tt_end_cor,
                            tt-mot-can (Gati - Oliver)
               
               25/07/2013 - Adicionado a coluna complend na tabela temporaria
                            tt-seg-geral, tt_end_cor, tt-prop-seguros. (James)
                            
               07/11/2013 - Adicionado campo nrfonres na tt-associado. (Reinert)
               
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).

			   04/08/2017 - Inclusao de novos campos na tt-associado 
			                (Adriano)

               27/11/2017 - Chamado 792418 - Incluir opções de cancelamento 10 e 11
                            (Andrei Vieira - MOUTs )

..............................................................................*/

DEF TEMP-TABLE tt-matricula NO-UNDO
    LIKE crapmat.

DEF TEMP-TABLE tt-feriado NO-UNDO
    LIKE crapfer.

DEF TEMP-TABLE tt-end-coop NO-UNDO
    LIKE crapenc.

DEF TEMP-TABLE tt-inf-conj NO-UNDO
    LIKE crapcje.

DEF TEMP-TABLE tt-seg-geral NO-UNDO
    LIKE crapseg
    FIELD nmresseg LIKE crapcsg.nmresseg
    FIELD dstipseg AS CHAR FORMAT "x(004)"
    FIELD ddvencto AS INTEGER
    FIELD vltotpre LIKE crawseg.vlpremio
    FIELD qtmaxpar LIKE crawseg.qtparcel
    FIELD ddpripag AS INTEGER
    FIELD dsendres LIKE crawseg.dsendres
    FIELD nrendres LIKE crawseg.nrendres
    FIELD nmbairro LIKE crawseg.nmbairro
    FIELD nrcepend LIKE crawseg.nrcepend
    FIELD nmcidade LIKE crawseg.nmcidade
    FIELD cdufresd LIKE crawseg.cdufresd
    FIELD complend LIKE crawseg.complend
    FIELD dsendres_2 LIKE crawseg.dsendres
    FIELD nrendres_2 LIKE crawseg.nrendres
    FIELD nmbairro_2 LIKE crawseg.nmbairro
    FIELD nrcepend_2 LIKE crawseg.nrcepend
    FIELD nmcidade_2 LIKE crawseg.nmcidade
    FIELD cdufresd_2 LIKE crawseg.cdufresd
    FIELD complend_2 LIKE crawseg.complend
    FIELD nmdsegur AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD nmbenefi LIKE crapseg.nmbenvid
    FIELD nmcpveic AS CHAR
    FIELD vlbenefi AS DECIMAL
    FIELD nmempres AS CHAR
    FIELD nrcadast AS INT
    FIELD nmdsecao AS CHAR
    FIELD nrfonemp AS CHAR
    FIELD nrfonres AS CHAR
    FIELD dsmarvei AS CHAR
    FIELD dstipvei AS CHAR
    FIELD nranovei AS INT
    FIELD nrmodvei AS INT
    FIELD nrdplaca AS CHAR
    FIELD qtpassag AS INT
    FIELD dschassi LIKE crawseg.dschassi
    FIELD ppdbonus LIKE crawseg.ppdbonus
    FIELD flgdnovo LIKE crawseg.flgdnovo
    FIELD flgrenov LIKE crawseg.flgrenov
    FIELD cdapoant LIKE crawseg.cdapoant
    FIELD nmsegant LIKE crawseg.nmsegant
    FIELD flgdutil LIKE crawseg.flgdutil
    FIELD flgvisto LIKE crawseg.flgvisto
    FIELD flgnotaf LIKE crawseg.flgnotaf
    FIELD flgapant LIKE crawseg.flgapant
    FIELD cdcalcul LIKE crawseg.cdcalcul
    FIELD vlseguro LIKE crawseg.vlseguro
    FIELD vldfranq LIKE crawseg.vldfranq
    FIELD vldcasco LIKE crawseg.vldcasco
    FIELD vlverbae LIKE crawseg.vlverbae
    FIELD flgassis LIKE crawseg.flgassis
    FIELD vldanmat LIKE crawseg.vldanmat
    FIELD vldanpes LIKE crawseg.vldanpes
    FIELD vldanmor LIKE crawseg.vldanmor
    FIELD vlappmor LIKE crawseg.vlappmor
    FIELD vlappinv LIKE crawseg.vlappinv
    FIELD flgcurso LIKE crawseg.flgcurso
    FIELD qtparseg LIKE crapseg.qtparcel
    FIELD dscobext LIKE crawseg.dscobext
    FIELD vlcobext LIKE crawseg.vlcobext
    FIELD flgrepgr LIKE crawseg.flgrepgr
    FIELD vlacipes LIKE crawseg.vlappinv
    FIELD vldanele LIKE crawseg.vlappmor
    FIELD vldiaria LIKE crawseg.vldanmor
    FIELD vldesmor LIKE crawseg.vldanmat
    FIELD vlvidros LIKE crawseg.vldfranq
    FIELD vldrcfam LIKE crawseg.vldanpes
    FIELD vlrouboe LIKE crawseg.vldifseg
    FIELD vlroubop LIKE crawseg.vlfrqobr
    FIELD vlrouboq LIKE crawseg.vlverbae
    FIELD vldvento LIKE crawseg.vldcasco
    FIELD vlmorada AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD dsseguro AS CHAR
    FIELD dspesseg AS CHAR
    FIELD qtpreseg LIKE crapseg.qtprepag
    FIELD dssitseg AS CHAR
    FIELD dsevento AS CHAR
    FIELD vlcapseg AS DECI FORMAT "zzz,zzz,zzz9.99"
    FIELD dscobert AS CHAR FORMAT "x(050)"
    FIELD dsmotcan AS CHAR FORMAT "x(40)"
    .

DEF TEMP-TABLE tt-cobert-casa NO-UNDO
    LIKE crapcsc.

DEF TEMP-TABLE tt-seg-vida NO-UNDO
    LIKE crawseg.

DEF TEMP-TABLE tt-titular NO-UNDO
    LIKE crapttl.

DEF TEMP-TABLE tt-pess-jur NO-UNDO
    LIKE crapjur.

DEF TEMP-TABLE tt-gar-seg NO-UNDO
    LIKE crapgsg.

DEF TEMP-TABLE tt-empresa NO-UNDO
    LIKE crapemp.

DEF TEMP-TABLE tt-cooperativa NO-UNDO
    LIKE crapcop.

DEF TEMP-TABLE tt-associado NO-UNDO
    LIKE crapass
    FIELD nrfonres AS CHAR
	FIELD nrcpfstl LIKE crapttl.nrcpfcgc
	FIELD nrfonemp AS CHAR.

DEF TEMP-TABLE tt2-associado NO-UNDO
    LIKE crapass.

DEF TEMP-TABLE tt_end_cor NO-UNDO
    FIELD dsendres LIKE crawseg.dsendres
    FIELD nrendres LIKE crawseg.nrendres
    FIELD nmbairro LIKE crawseg.nmbairro
    FIELD nrcepend LIKE crawseg.nrcepend
    FIELD nmcidade LIKE crawseg.nmcidade
    FIELD cdufresd LIKE crawseg.cdufresd
    FIELD complend LIKE crawseg.complend.

DEF TEMP-TABLE tt-plano-seg NO-UNDO
    LIKE craptsg.

DEF TEMP-TABLE tt-cobert-seg NO-UNDO
    LIKE craptsg.

DEF TEMP-TABLE tt-mot-can NO-UNDO
    FIELD cdmotcan AS INTEGER FORMAT "99"
    FIELD dsmotcan AS CHAR FORMAT "x(40)".

DEF TEMP-TABLE tt-seguradora NO-UNDO
    LIKE crapcsg
    FIELD nmrescec AS   CHAR    
    FIELD nmrescop LIKE crapcop.nmrescop.

DEF TEMP-TABLE tt-seguros NO-UNDO LIKE crapseg
    FIELD dsseguro AS CHAR
    FIELD dsstatus AS CHAR
    FIELD vlseguro LIKE crawseg.vlseguro
    FIELD nmdsegur LIKE crawseg.nmdsegur
    FIELD vlant    LIKE crapseg.vlpreseg
    FIELD registro AS RECID
    FIELD dsmotcan AS CHAR FORMAT "x(40)"
    INDEX id1 cdcooper nrdconta tpseguro nrctrseg.
    
DEF TEMP-TABLE tt-prop-seguros NO-UNDO
    FIELD dtiniseg LIKE crapseg.dtiniseg
    FIELD nrctrseg LIKE crapseg.nrctrseg
    FIELD dtdebito LIKE crapseg.dtdebito
    FIELD tpseguro LIKE crapseg.tpseguro
    FIELD dsseguro AS CHAR 
    FIELD vlpreseg LIKE crapseg.vlpreseg
    FIELD dtinivig LIKE crapseg.dtinivig
    FIELD cdmotcan LIKE crapseg.cdmotcan
    FIELD dtmvtolt LIKE crawseg.dtmvtolt
    FIELD tpsegvid LIKE crawseg.tpsegvid
    FIELD nrcpfcgc LIKE crawseg.nrcpfcgc
    FIELD nmdsegur LIKE crawseg.nmdsegur
    FIELD nrdconta LIKE crawseg.nrdconta
    FIELD cdsexosg LIKE crawseg.cdsexosg
    FIELD dtnascsg LIKE crawseg.dtnascsg
    FIELD dsendres LIKE crawseg.dsendres
    FIELD nmbairro LIKE crawseg.nmbairro
    FIELD nmcidade LIKE crawseg.nmcidade
    FIELD cdufresd LIKE crawseg.cdufresd
    FIELD nrcepend LIKE crawseg.nrcepend
    FIELD complend LIKE crawseg.complend
    FIELD tpplaseg LIKE crawseg.tpplaseg
    FIELD vlseguro LIKE crawseg.vlseguro
    FIELD cdcooper LIKE crawseg.cdcooper
    FIELD vlpremio LIKE crawseg.vlpremio
    FIELD qtparcel LIKE crawseg.qtparcel
    FIELD dtprideb LIKE crawseg.dtprideb
    FIELD nmcpveic LIKE crawseg.nmcpveic
    FIELD nmbenefi LIKE crawseg.nmbenefi
    FIELD vlbenefi LIKE crawseg.vlbenefi
    FIELD nmempres LIKE crawseg.nmempres
    FIELD nrcadast LIKE crawseg.nrcadast    
    FIELD nrfonemp LIKE crawseg.nrfonemp
    FIELD nrfonres LIKE crawseg.nrfonres
    FIELD dsmarvei LIKE crawseg.dsmarvei
    FIELD dstipvei LIKE crawseg.dstipvei
    FIELD nranovei LIKE crawseg.nranovei
    FIELD nrmodvei LIKE crawseg.nrmodvei
    FIELD nrdplaca LIKE crawseg.nrdplaca
    FIELD qtpasvei LIKE crawseg.qtpasvei
    FIELD dschassi LIKE crawseg.dschassi
    FIELD ppdbonus LIKE crawseg.ppdbonus
    FIELD flgdnovo LIKE crawseg.flgdnovo
    FIELD flgrenov LIKE crawseg.flgrenov
    FIELD cdapoant LIKE crawseg.cdapoant
    FIELD nmsegant LIKE crawseg.nmsegant
    FIELD flgdutil LIKE crawseg.flgdutil
    FIELD flgvisto LIKE crawseg.flgvisto
    FIELD flgnotaf LIKE crawseg.flgnotaf
    FIELD flgapant LIKE crawseg.flgapant
    FIELD flgrepgr LIKE crawseg.flgrepgr
    FIELD dtfimvig LIKE crawseg.dtfimvig
    FIELD cdcalcul LIKE crawseg.cdcalcul
    FIELD vldfranq LIKE crawseg.vldfranq
    FIELD vldcasco LIKE crawseg.vldcasco
    FIELD vlverbae LIKE crawseg.vlverbae
    FIELD flgassis LIKE crawseg.flgassis
    FIELD vldanmat LIKE crawseg.vldanmat
    FIELD vldanpes LIKE crawseg.vldanpes
    FIELD vldanmor LIKE crawseg.vldanmor
    FIELD vlappmor LIKE crawseg.vlappmor
    FIELD vlappinv LIKE crawseg.vlappinv
    FIELD flgcurso LIKE crawseg.flgcurso
    FIELD vldifseg LIKE crawseg.vldifseg
    FIELD vlfrqobr LIKE crawseg.vlfrqobr
    FIELD nrendres LIKE crawseg.nrendres
    FIELD cdsegura LIKE crawseg.cdsegura
    FIELD flgunica LIKE crawseg.flgunica
    FIELD lsctrant AS CHAR
    FIELD registro AS RECID
    INDEX id1 cdcooper cdsegura nrdconta nrctrseg
    INDEX id2 registro.
    
DEF TEMP-TABLE tt-seguros_autos NO-UNDO
    FIELD nmdsegur LIKE crawseg.nmdsegur
    FIELD dsmarvei LIKE crawseg.dsmarvei
    FIELD dstipvei LIKE crawseg.dstipvei
    FIELD nranovei LIKE crawseg.nranovei
    FIELD nrmodvei LIKE crawseg.nrmodvei
    FIELD nrdplaca LIKE crawseg.nrdplaca
    FIELD dtinivig LIKE crawseg.dtinivig
    FIELD dtfimvig LIKE crawseg.dtfimvig
    FIELD qtparcel LIKE crawseg.qtparcel
    FIELD vlpreseg LIKE crawseg.vlpreseg
    FIELD vlpremio LIKE crawseg.vlpremio
    FIELD dtdebito AS INT.

DEFINE TEMP-TABLE cratseg                                          NO-UNDO
       FIELD  tpseguro  LIKE crapseg.tpseguro
       FIELD  tpplaseg  LIKE crapseg.tpplaseg
       FIELD  dtdebito  LIKE crapseg.dtdebito
       FIELD  nrdconta  LIKE crapseg.nrdconta
       FIELD  nrctrseg  LIKE crapseg.nrctrseg
       FIELD  vlpreseg  LIKE crapseg.vlpreseg
       FIELD  vlatual   AS DEC FORMAT "zz9.99-"         
       FIELD  dtmvtolt  LIKE crapseg.dtmvtolt
       FIELD  registro    AS RECID.

/*............................................................................*/


