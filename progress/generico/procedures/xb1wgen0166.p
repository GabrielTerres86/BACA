/*.............................................................................

    Programa: sistema/generico/procedures/Xb1wgen0166.p
    Autor   : Oliver Fagionato (GATI)
    Data    : Agosto/2013

    Objetivo  : BO de Comunicacao XML x BO 
                Tela CADEMP
                Alterar, consultar, incluir e gerar relatorio de empresas.

    Alteracoes: 21/11/2013 - Alteração para adequar o fonte no padrão CECRED
    
                25/03/2014 - Correcao dos parametros para gravar log (Carlos)
                
                12/06/2014 - Adicionado geração do XML na "Gera_arquivo_log"
                             (Douglas - Chamado 122814)
                             
               11/08/2014 - Inclusão da opção de Pesquisa de Empresas (Vanessa)
               
               13/01/2015 - Passagem do parametro nrdocnpj na valida_empresa
                            Ref Doc3040 - Ente Consignante - Marcos(Supero)
               
               25/11/2015 - Ajustando a busca dos valores de tarifas dos
                            convenios. (Andre Santos - SUPERO)

                18/05/2016 - Inclusao do campo dtlimdeb. (Jaison/Marcos)

				12/04/2018 - P437 - Consignado - inclusão do campo nrdddemp - Josiane Stiehler AMcom
				
.............................................................................*/

/*............................. DEFINICOES ..................................*/
DEFINE VARIABLE aux_cdagenci AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_nrdcaixa AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_idorigem AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_nmdatela AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_cdprogra AS CHARACTER   NO-UNDO.

DEF VAR aux2_dtmvtolt AS DATE               NO-UNDO.
DEF VAR old_dtavsemp  LIKE crapemp.dtavsemp NO-UNDO.
DEF VAR new_dtavsemp  LIKE crapemp.dtavsemp NO-UNDO.
DEF VAR old_dtavscot  LIKE crapemp.dtavscot NO-UNDO.
DEF VAR new_dtavscot  LIKE crapemp.dtavscot NO-UNDO.
DEF VAR old_dtavsppr  LIKE crapemp.dtavsppr NO-UNDO.
DEF VAR new_dtavsppr  LIKE crapemp.dtavsppr NO-UNDO.
DEF VAR old_indescsg  AS LOG                NO-UNDO.
DEF VAR new_indescsg  AS LOG                NO-UNDO.
DEF VAR old_dtfchfol  AS INT                NO-UNDO.
DEF VAR new_dtfchfol  AS INT                NO-UNDO.
DEF VAR old_flgpagto  AS LOG                NO-UNDO.
DEF VAR new_flgpagto  AS LOG                NO-UNDO.
DEF VAR old_flgarqrt  AS LOG                NO-UNDO.
DEF VAR new_flgarqrt  AS LOG                NO-UNDO.
DEF VAR old_flgvlddv  AS LOG                NO-UNDO.
DEF VAR new_flgvlddv  AS LOG                NO-UNDO.
DEF VAR old_cdempfol  AS INT                NO-UNDO.
DEF VAR new_cdempfol  AS INT                NO-UNDO.
DEF VAR old_tpconven  AS CHAR               NO-UNDO.
DEF VAR new_tpconven  AS CHAR               NO-UNDO.
DEF VAR old_tpdebemp  AS CHAR               NO-UNDO.
DEF VAR new_tpdebemp  AS CHAR               NO-UNDO.
DEF VAR old_tpdebcot  AS CHAR               NO-UNDO.
DEF VAR new_tpdebcot  AS CHAR               NO-UNDO.
DEF VAR old_tpdebppr  AS CHAR               NO-UNDO.
DEF VAR new_tpdebppr  AS CHAR               NO-UNDO.
DEF VAR aux_nmdbusca  AS CHAR               NO-UNDO.
DEF VAR aux_cdpesqui  AS CHAR               NO-UNDO.
DEF VAR aux_nmprimtl  AS CHAR               NO-UNDO.

DEF VAR old_cdempres  LIKE crapemp.cdempres NO-UNDO.
DEF VAR new_cdempres  LIKE crapemp.cdempres NO-UNDO.
DEF VAR old_nmextemp  LIKE crapemp.nmextemp NO-UNDO.
DEF VAR new_nmextemp  LIKE crapemp.nmextemp NO-UNDO.
DEF VAR old_nmresemp  LIKE crapemp.nmresemp NO-UNDO.
DEF VAR new_nmresemp  LIKE crapemp.nmresemp NO-UNDO.
DEF VAR old_cdufdemp  LIKE crapemp.cdufdemp NO-UNDO.
DEF VAR new_cdufdemp  LIKE crapemp.cdufdemp NO-UNDO.
DEF VAR old_dscomple  LIKE crapemp.dscomple NO-UNDO.
DEF VAR new_dscomple  LIKE crapemp.dscomple NO-UNDO.
DEF VAR old_dsdemail  LIKE crapemp.dsdemail NO-UNDO.
DEF VAR new_dsdemail  LIKE crapemp.dsdemail NO-UNDO.
DEF VAR old_dsendemp  LIKE crapemp.dsendemp NO-UNDO.
DEF VAR new_dsendemp  LIKE crapemp.dsendemp NO-UNDO.
DEF VAR old_nmbairro  LIKE crapemp.nmbairro NO-UNDO.
DEF VAR new_nmbairro  LIKE crapemp.nmbairro NO-UNDO.
DEF VAR old_nmcidade  LIKE crapemp.nmcidade NO-UNDO.
DEF VAR new_nmcidade  LIKE crapemp.nmcidade NO-UNDO.
DEF VAR old_nrcepend  LIKE crapemp.nrcepend NO-UNDO.
DEF VAR new_nrcepend  LIKE crapemp.nrcepend NO-UNDO.
DEF VAR old_nrdocnpj  LIKE crapemp.nrdocnpj NO-UNDO.
DEF VAR new_nrdocnpj  LIKE crapemp.nrdocnpj NO-UNDO.
DEF VAR old_nrendemp  LIKE crapemp.nrendemp NO-UNDO.
DEF VAR new_nrendemp  LIKE crapemp.nrendemp NO-UNDO.
DEF VAR old_nrfaxemp  LIKE crapemp.nrfaxemp NO-UNDO.
DEF VAR new_nrfaxemp  LIKE crapemp.nrfaxemp NO-UNDO.
DEF VAR old_nrfonemp  LIKE crapemp.nrfonemp NO-UNDO.
DEF VAR new_nrfonemp  LIKE crapemp.nrfonemp NO-UNDO.
DEF VAR aux_cdempfol  LIKE crapemp.cdempfol NO-UNDO.
DEF VAR aux_cdempres  LIKE crapemp.cdempres NO-UNDO.
DEF VAR aux_dtavscot  LIKE crapemp.dtavscot NO-UNDO.
DEF VAR aux_dtavsemp  LIKE crapemp.dtavsemp NO-UNDO.
DEF VAR aux_dtavsppr  LIKE crapemp.dtavsppr NO-UNDO.
DEF VAR aux_flgpagto  LIKE crapemp.flgpagto NO-UNDO.
DEF VAR aux_flgarqrt  LIKE crapemp.flgarqrt NO-UNDO.
DEF VAR aux_nmextemp  LIKE crapemp.nmextemp NO-UNDO.
DEF VAR aux_nmresemp  LIKE crapemp.nmresemp NO-UNDO.
DEF VAR aux_dtfchfol  LIKE crapemp.dtfchfol NO-UNDO.
DEF VAR aux_cdufdemp  LIKE crapemp.cdufdemp NO-UNDO.
DEF VAR aux_nmbairro  LIKE crapemp.nmbairro NO-UNDO.
DEF VAR aux_nmcidade  LIKE crapemp.nmcidade NO-UNDO.
DEF VAR aux_dscomple  LIKE crapemp.dscomple NO-UNDO.
DEF VAR aux_nrendemp  LIKE crapemp.nrendemp NO-UNDO.
DEF VAR aux_dsendemp  LIKE crapemp.dsendemp NO-UNDO.
DEF VAR aux_nrcepend  LIKE crapemp.nrcepend NO-UNDO.
DEF VAR aux_nrfonemp  LIKE crapemp.nrfonemp NO-UNDO.
DEF VAR aux_nrfaxemp  LIKE crapemp.nrfaxemp NO-UNDO.
DEF VAR aux_nrdocnpj  LIKE crapemp.nrdocnpj NO-UNDO.
DEF VAR aux_dsdemail  LIKE crapemp.dsdemail NO-UNDO.
DEF VAR aux_flgvlddv  LIKE crapemp.flgvlddv NO-UNDO.
DEF VAR aux_inavscot  LIKE crapemp.inavscot NO-UNDO.
DEF VAR aux_inavsemp  LIKE crapemp.inavsemp NO-UNDO.
DEF VAR aux_inavsppr  LIKE crapemp.inavsppr NO-UNDO.
DEF VAR aux_inavsden  LIKE crapemp.inavsden NO-UNDO.
DEF VAR aux_inavsseg  LIKE crapemp.inavsseg NO-UNDO.
DEF VAR aux_inavssau  LIKE crapemp.inavssau NO-UNDO.
DEF VAR aux_tpconven  LIKE crapemp.tpconven NO-UNDO.
DEF VAR aux_tpdebcot  LIKE crapemp.tpdebcot NO-UNDO.
DEF VAR aux_tpdebemp  LIKE crapemp.tpdebemp NO-UNDO.
DEF VAR aux_tpdebppr  LIKE crapemp.tpdebppr NO-UNDO.
DEF VAR aux_indescsg  LIKE crapemp.indescsg NO-UNDO.
DEF VAR aux_cdcooper  LIKE crapemp.cdcooper NO-UNDO.
DEF VAR aux_cdacesso  LIKE craptab.cdacesso NO-UNDO.
DEF VAR aux_nmsistem  AS CHAR               NO-UNDO.
DEF VAR aux_tpregist  LIKE craptab.tpregist NO-UNDO.
DEF VAR aux_tptabela  LIKE craptab.tptabela NO-UNDO.
DEF VAR aux_tiptrans  AS CHAR               NO-UNDO.
DEF VAR aux_dstextab  LIKE craptab.dstextab NO-UNDO.
DEF VAR aux_dtferiad  AS DATE               NO-UNDO.
DEF VAR aux_cdopcao   AS CHAR               NO-UNDO.
DEF VAR aux_cdoperad  AS CHAR               NO-UNDO.
DEF VAR par_feriad    AS LOGICAL            NO-UNDO.
DEF VAR par_dscritic  AS CHAR               NO-UNDO.
DEF VAR par_cdempres  LIKE crapemp.cdempres NO-UNDO.
DEF VAR aux_flgordem  AS LOGICAL            NO-UNDO.
DEF VAR par_cdcooper  LIKE crapcop.cdcooper NO-UNDO.
DEF VAR par_cdagenci  LIKE crapage.cdagenci NO-UNDO.
DEF VAR par_nrdcaixa  AS INTE               NO-UNDO.
DEF VAR par_cdoperad  AS CHAR               NO-UNDO.
DEF VAR par_dtmvtolt  AS DATE               NO-UNDO.
DEF VAR par_idorigem  AS INTE               NO-UNDO.
DEF VAR par_nmdatela  AS CHAR               NO-UNDO.
DEF VAR par_cdprogra  AS CHAR               NO-UNDO.
DEF VAR par_dtferiad  AS DATE               NO-UNDO.
DEF VAR aux_dtavisos  AS DATE               NO-UNDO.
DEF VAR aux_dtavs001  AS DATE               NO-UNDO.
DEF VAR aux_dtlimdeb  LIKE crapemp.dtlimdeb NO-UNDO.
DEF VAR new_dtlimdeb  LIKE crapemp.dtlimdeb NO-UNDO.
DEF VAR old_dtlimdeb  LIKE crapemp.dtlimdeb NO-UNDO.

DEF VAR aux_nrdddemp  LIKE crapemp.nrdddemp NO-UNDO.
DEF VAR old_nrdddemp  LIKE crapemp.nrdddemp NO-UNDO.
DEF VAR new_nrdddemp  LIKE crapemp.nrdddemp NO-UNDO.


DEF VAR aux_indtermo AS INTE                NO-UNDO.
DEF VAR aux_lisconta AS CHAR                NO-UNDO.
DEF VAR aux_cdcritic AS INTE                NO-UNDO.
DEF VAR aux_dscritic AS CHAR                NO-UNDO.

DEF VAR aux_idtpempr AS CHAR               NO-UNDO.
DEF VAR aux_nrdconta LIKE crapemp.nrdconta NO-UNDO.
DEF VAR aux_dtultufp LIKE crapemp.dtultufp NO-UNDO.
DEF VAR aux_nmcontat LIKE crapemp.nmcontat NO-UNDO.
DEF VAR aux_flgpgtib LIKE crapemp.flgpgtib NO-UNDO.
DEF VAR aux_cdcontar LIKE crapemp.cdcontar NO-UNDO.
DEF VAR aux_vllimfol LIKE crapemp.vllimfol NO-UNDO.
DEF VAR aux_flgdgfib LIKE crapemp.flgdgfib NO-UNDO.

DEF VAR old_idtpempr LIKE crapemp.idtpempr NO-UNDO.
DEF VAR old_nrdconta LIKE crapemp.nrdconta NO-UNDO.
DEF VAR old_dtultufp LIKE crapemp.dtultufp NO-UNDO.
DEF VAR old_nmcontat LIKE crapemp.nmcontat NO-UNDO.
DEF VAR old_flgpgtib LIKE crapemp.flgpgtib NO-UNDO.
DEF VAR old_cdcontar LIKE crapemp.cdcontar NO-UNDO.
DEF VAR old_vllimfol LIKE crapemp.vllimfol NO-UNDO.

DEF VAR new_idtpempr LIKE crapemp.idtpempr NO-UNDO.
DEF VAR new_nrdconta LIKE crapemp.nrdconta NO-UNDO.
DEF VAR new_dtultufp LIKE crapemp.dtultufp NO-UNDO.
DEF VAR new_nmcontat LIKE crapemp.nmcontat NO-UNDO.
DEF VAR new_flgpgtib LIKE crapemp.flgpgtib NO-UNDO.
DEF VAR new_cdcontar LIKE crapemp.cdcontar NO-UNDO.
DEF VAR new_vllimfol LIKE crapemp.vllimfol NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0166tt.i }

/*............................... PROCEDURES ................................*/
PROCEDURE valores_entrada:

    FOR EACH tt-param:
        CASE tt-param.nomeCampo:
            WHEN "cdagenci"     THEN aux_cdagenci = int(tt-param.valorCampo).
            WHEN "nrdcaixa"     THEN aux_nrdcaixa = int(tt-param.valorCampo).
            WHEN "idorigem"     THEN aux_idorigem = int(tt-param.valorCampo).
            WHEN "nmdatela"     THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "cdprogra"     THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "dstextab"     THEN aux_dstextab = tt-param.valorCampo.
            WHEN "old_dsendemp" THEN old_dsendemp = tt-param.valorCampo.
            WHEN "new_dsendemp" THEN new_dsendemp = tt-param.valorCampo.
            WHEN "old_nmbairro" THEN old_nmbairro = tt-param.valorCampo.
            WHEN "new_nmbairro" THEN new_nmbairro = tt-param.valorCampo.
            WHEN "old_nmcidade" THEN old_nmcidade = tt-param.valorCampo.
            WHEN "new_nmcidade" THEN new_nmcidade = tt-param.valorCampo.
            WHEN "old_nrfaxemp" THEN old_nrfaxemp = tt-param.valorCampo.
            WHEN "new_nrfaxemp" THEN new_nrfaxemp = tt-param.valorCampo.
            WHEN "old_nrfonemp" THEN old_nrfonemp = tt-param.valorCampo.
            WHEN "new_nrfonemp" THEN new_nrfonemp = tt-param.valorCampo.
            WHEN "old_nmextemp" THEN old_nmextemp = tt-param.valorCampo.
            WHEN "new_nmextemp" THEN new_nmextemp = tt-param.valorCampo.
            WHEN "old_nmresemp" THEN old_nmresemp = tt-param.valorCampo.
            WHEN "new_nmresemp" THEN new_nmresemp = tt-param.valorCampo.
            WHEN "old_cdufdemp" THEN old_cdufdemp = tt-param.valorCampo.
            WHEN "new_cdufdemp" THEN new_cdufdemp = tt-param.valorCampo.
            WHEN "old_dscomple" THEN old_dscomple = tt-param.valorCampo.
            WHEN "new_dscomple" THEN new_dscomple = tt-param.valorCampo.
            WHEN "old_dsdemail" THEN old_dsdemail = tt-param.valorCampo.
            WHEN "new_dsdemail" THEN new_dsdemail = tt-param.valorCampo.
            WHEN "old_tpconven" THEN old_tpconven = tt-param.valorCampo.
            WHEN "new_tpconven" THEN new_tpconven = tt-param.valorCampo.
            WHEN "old_tpdebemp" THEN old_tpdebemp = tt-param.valorCampo.
            WHEN "new_tpdebemp" THEN new_tpdebemp = tt-param.valorCampo.
            WHEN "old_tpdebcot" THEN old_tpdebcot = tt-param.valorCampo.
            WHEN "new_tpdebcot" THEN new_tpdebcot = tt-param.valorCampo.
            WHEN "old_tpdebppr" THEN old_tpdebppr = tt-param.valorCampo.
            WHEN "new_tpdebppr" THEN new_tpdebppr = tt-param.valorCampo.
            WHEN "dstextab"     THEN aux_dstextab = tt-param.valorCampo.
            WHEN "cdoperad"     THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "cdopcao"      THEN aux_cdopcao  = tt-param.valorCampo.
            WHEN "cdacesso"     THEN aux_cdacesso = tt-param.valorCampo.
            WHEN "nmsistem"     THEN aux_nmsistem = tt-param.valorCampo.
            WHEN "tptabela"     THEN aux_tptabela = tt-param.valorCampo.
            WHEN "tiptrans"     THEN aux_tiptrans = tt-param.valorCampo.
            WHEN "nmextemp"     THEN aux_nmextemp = tt-param.valorCampo.
            WHEN "nmresemp"     THEN aux_nmresemp = tt-param.valorCampo.
            WHEN "cdufdemp"     THEN aux_cdufdemp = tt-param.valorCampo.
            WHEN "nmbairro"     THEN aux_nmbairro = tt-param.valorCampo.
            WHEN "nmcidade"     THEN aux_nmcidade = tt-param.valorCampo.
            WHEN "dscomple"     THEN aux_dscomple = tt-param.valorCampo.
            WHEN "dsendemp"     THEN aux_dsendemp = tt-param.valorCampo.
            WHEN "nrfonemp"     THEN aux_nrfonemp = tt-param.valorCampo.
            WHEN "nrfaxemp"     THEN aux_nrfaxemp = tt-param.valorCampo.
            WHEN "dsdemail"     THEN aux_dsdemail = tt-param.valorCampo.
            WHEN "old_nrcepend" THEN old_nrcepend = INTEGER(tt-param.valorCampo).
            WHEN "new_nrcepend" THEN new_nrcepend = INTEGER(tt-param.valorCampo).
            WHEN "old_nrendemp" THEN old_nrendemp = INTEGER(tt-param.valorCampo).
            WHEN "new_nrendemp" THEN new_nrendemp = INTEGER(tt-param.valorCampo).
            WHEN "old_cdempres" THEN old_cdempres = INTEGER(tt-param.valorCampo).
            WHEN "new_cdempres" THEN new_cdempres = INTEGER(tt-param.valorCampo).
            WHEN "old_cdempfol" THEN old_cdempfol = INTEGER(tt-param.valorCampo).
            WHEN "new_cdempfol" THEN new_cdempfol = INTEGER(tt-param.valorCampo).
            WHEN "old_dtfchfol" THEN old_dtfchfol = INTEGER(tt-param.valorCampo).
            WHEN "new_dtfchfol" THEN new_dtfchfol = INTEGER(tt-param.valorCampo).
            WHEN "nrendemp"     THEN aux_nrendemp = INTEGER(tt-param.valorCampo).
            WHEN "nrcepend"     THEN aux_nrcepend = INTEGER(tt-param.valorCampo).
            WHEN "inavscot"     THEN aux_inavscot = INTEGER(tt-param.valorCampo).
            WHEN "inavsemp"     THEN aux_inavsemp = INTEGER(tt-param.valorCampo).
            WHEN "inavsppr"     THEN aux_inavsppr = INTEGER(tt-param.valorCampo).
            WHEN "inavsden"     THEN aux_inavsden = INTEGER(tt-param.valorCampo).
            WHEN "inavsseg"     THEN aux_inavsseg = INTEGER(tt-param.valorCampo).
            WHEN "inavssau"     THEN aux_inavssau = INTEGER(tt-param.valorCampo).
            WHEN "tpconven"     THEN aux_tpconven = INTEGER(tt-param.valorCampo).
            WHEN "tpdebcot"     THEN aux_tpdebcot = INTEGER(tt-param.valorCampo).
            WHEN "tpdebemp"     THEN aux_tpdebemp = INTEGER(tt-param.valorCampo).
            WHEN "tpdebppr"     THEN aux_tpdebppr = INTEGER(tt-param.valorCampo).
            WHEN "indescsg"     THEN aux_indescsg = INTEGER(tt-param.valorCampo).
            WHEN "cdcooper"     THEN aux_cdcooper = INTEGER(tt-param.valorCampo).
            WHEN "cdempres"     THEN aux_cdempres = INTEGER(tt-param.valorCampo).
            WHEN "tpregist"     THEN aux_tpregist = INTEGER(tt-param.valorCampo).
            WHEN "cdempfol"     THEN aux_cdempfol = INTEGER(tt-param.valorCampo).
            WHEN "dtfchfol"     THEN aux_dtfchfol = INTEGER(tt-param.valorCampo).
            WHEN "dtavscot"     THEN aux_dtavscot = DATE(tt-param.valorCampo).
            WHEN "dtavsemp"     THEN aux_dtavsemp = DATE(tt-param.valorCampo).
            WHEN "dtavsppr"     THEN aux_dtavsppr = DATE(tt-param.valorCampo).
            WHEN "old_dtavsemp" THEN old_dtavsemp = DATE(tt-param.valorCampo).
            WHEN "new_dtavsemp" THEN new_dtavsemp = DATE(tt-param.valorCampo).
            WHEN "old_dtavscot" THEN old_dtavscot = DATE(tt-param.valorCampo).
            WHEN "new_dtavscot" THEN new_dtavscot = DATE(tt-param.valorCampo).
            WHEN "old_dtavsppr" THEN old_dtavsppr = DATE(tt-param.valorCampo).
            WHEN "new_dtavsppr" THEN new_dtavsppr = DATE(tt-param.valorCampo).
            WHEN "dtmvtolt"     THEN aux2_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "old_flgpagto" THEN old_flgpagto = LOGICAL(tt-param.valorCampo).
            WHEN "flgordem"     THEN aux_flgordem = LOGICAL(tt-param.valorCampo).
            WHEN "new_flgpagto" THEN new_flgpagto = LOGICAL(tt-param.valorCampo).
            WHEN "old_flgarqrt" THEN old_flgarqrt = LOGICAL(tt-param.valorCampo).
            WHEN "new_flgarqrt" THEN new_flgarqrt = LOGICAL(tt-param.valorCampo).
            WHEN "old_flgvlddv" THEN old_flgvlddv = LOGICAL(tt-param.valorCampo).
            WHEN "new_flgvlddv" THEN new_flgvlddv = LOGICAL(tt-param.valorCampo).
            WHEN "old_indescsg" THEN old_indescsg = LOGICAL(tt-param.valorCampo).
            WHEN "new_indescsg" THEN new_indescsg = LOGICAL(tt-param.valorCampo).
            WHEN "flgpagto"     THEN aux_flgpagto = LOGICAL(tt-param.valorCampo).
            WHEN "flgarqrt"     THEN aux_flgarqrt = LOGICAL(tt-param.valorCampo).
            WHEN "flgvlddv"     THEN aux_flgvlddv = LOGICAL(tt-param.valorCampo).
            WHEN "old_nrdocnpj" THEN old_nrdocnpj = DEC(tt-param.valorCampo).
            WHEN "new_nrdocnpj" THEN new_nrdocnpj = DEC(tt-param.valorCampo).
            WHEN "nrdocnpj"     THEN aux_nrdocnpj = DEC(tt-param.valorCampo).
            WHEN "nmdbusca"     THEN aux_nmdbusca = STRING(tt-param.valorCampo).
            WHEN "cdpesqui"     THEN aux_cdpesqui = STRING(tt-param.valorCampo).
            WHEN "dtlimdeb"     THEN aux_dtlimdeb = INTEGER(tt-param.valorCampo).
            WHEN "new_dtlimdeb" THEN new_dtlimdeb = INTEGER(tt-param.valorCampo).
            WHEN "old_dtlimdeb" THEN old_dtlimdeb = INTEGER(tt-param.valorCampo).
            WHEN "dtferiad"     THEN aux_dtferiad = DATE(tt-param.valorCampo).
			WHEN "nrdddemp"     THEN aux_nrdddemp = INTEGER(tt-param.valorCampo).
            WHEN "old_nrdddemp" THEN old_nrdddemp = INTEGER(tt-param.valorCampo).
            WHEN "new_nrdddemp" THEN new_nrdddemp = INTEGER(tt-param.valorCampo).
           
            WHEN "idtpempr"     THEN aux_idtpempr = STRING(tt-param.valorCampo).
            WHEN "nrdconta"     THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "dtultufp"     THEN aux_dtultufp = DATE(tt-param.valorCampo).
            WHEN "nmcontat"     THEN aux_nmcontat = STRING(tt-param.valorCampo).
            WHEN "flgpgtib"     THEN aux_flgpgtib = LOGICAL(tt-param.valorCampo).
            WHEN "cdcontar"     THEN aux_cdcontar = INTE(tt-param.valorCampo).
            WHEN "vllimfol"     THEN aux_vllimfol = DECI(tt-param.valorCampo).
            WHEN "flgdgfib"     THEN aux_flgdgfib = LOGICAL(tt-param.valorCampo).
            
            WHEN "old_idtpempr" THEN old_idtpempr = STRING(tt-param.valorCampo). 
            WHEN "old_nrdconta" THEN old_nrdconta = INTE(tt-param.valorCampo).   
            WHEN "old_dtultufp" THEN old_dtultufp = DATE(tt-param.valorCampo).   
            WHEN "old_nmcontat" THEN old_nmcontat = STRING(tt-param.valorCampo). 
            WHEN "old_flgpgtib" THEN old_flgpgtib = LOGICAL(tt-param.valorCampo).
            WHEN "old_cdcontar" THEN old_cdcontar = INTE(tt-param.valorCampo).   
            WHEN "old_vllimfol" THEN old_vllimfol = DECI(tt-param.valorCampo). 
            
            WHEN "new_idtpempr" THEN new_idtpempr = STRING(tt-param.valorCampo). 
            WHEN "new_nrdconta" THEN new_nrdconta = INTE(tt-param.valorCampo).   
            WHEN "new_dtultufp" THEN new_dtultufp = DATE(tt-param.valorCampo).   
            WHEN "new_nmcontat" THEN new_nmcontat = STRING(tt-param.valorCampo). 
            WHEN "new_flgpgtib" THEN new_flgpgtib = LOGICAL(tt-param.valorCampo).
            WHEN "new_cdcontar" THEN new_cdcontar = INTE(tt-param.valorCampo).   
            WHEN "new_vllimfol" THEN new_vllimfol = DECI(tt-param.valorCampo).

            WHEN "nmprimtl"     THEN aux_nmprimtl = STRING(tt-param.valorCampo).
            WHEN "indtermo"     THEN aux_indtermo = INTE(tt-param.valorCampo).
            WHEN "lisconta"     THEN aux_lisconta = STRING(tt-param.valorCampo).

        END CASE.
    END. /* FOR EACH tt-param */
END PROCEDURE. /* valores_entrada */

PROCEDURE Valida_empresa:

    RUN Valida_empresa IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux2_dtmvtolt,
                              INPUT aux_idorigem,
                              INPUT aux_nmdatela,
                              INPUT aux_cdprogra,
                              INPUT IF aux_indescsg = 1 THEN NO ELSE YES,
                              INPUT aux_nrdocnpj,
                              INPUT aux_dtfchfol,
                              INPUT aux_cdempfol,
                              INPUT aux_flgpagto,
                              INPUT old_dtavsemp,
                              INPUT new_dtavsemp,
                              INPUT old_dtavscot,
                              INPUT new_dtavscot,
                              INPUT old_dtavsppr,
                              INPUT new_dtavsppr,
                              OUTPUT par_dscritic,
                              OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dscritic",INPUT par_dscritic).
            RUN piXmlSave.
        END.

    

END PROCEDURE.

PROCEDURE Imprime_relacao:
    DEFINE VARIABLE aux_nmarqpdf AS CHARACTER   NO-UNDO.
    RUN Imprime_relacao IN hBO(INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux2_dtmvtolt,
                               INPUT aux_idorigem,
                               INPUT aux_nmdatela,
                               INPUT aux_cdprogra,
                               INPUT aux_flgordem,
                               OUTPUT aux_nmarqpdf,
                               OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE Busca_empresas:

    RUN Busca_empresas IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux2_dtmvtolt,
                              INPUT aux_idorigem,
                              INPUT aux_nmdatela,
                              INPUT aux_cdprogra,
                              INPUT aux_nmdbusca,
                              INPUT aux_cdpesqui,
                              INPUT aux_cdempres,
                              OUTPUT TABLE tt-crapemp,
                              OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapemp:HANDLE,
                             INPUT "empresas").
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE Busca_tabela:

    RUN Busca_tabela IN hBO(INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux2_dtmvtolt,
                            INPUT aux_idorigem,
                            INPUT aux_nmdatela,
                            INPUT aux_cdprogra,
                            INPUT aux_nmsistem,
                            INPUT aux_tptabela,
                            INPUT aux_cdempres,
                            INPUT aux_cdacesso,
                            INPUT aux_tpregist,
                            OUTPUT TABLE tt-craptab,
                            OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-craptab:HANDLE,
                             INPUT "tabela").
            RUN piXmlSave.
        END.
    
END PROCEDURE.

PROCEDURE Altera_inclui:

  RUN Altera_inclui IN hBO(INPUT aux_cdcooper,
                           INPUT aux_cdagenci,
                           INPUT aux_nrdcaixa,
                           INPUT aux_cdoperad,
                           INPUT aux2_dtmvtolt,
                           INPUT aux_idorigem,
                           INPUT aux_nmdatela,
                           INPUT aux_cdprogra,
                           INPUT aux_tiptrans,
                           INPUT aux_inavscot,
                           INPUT aux_inavsemp,
                           INPUT aux_inavsppr,
                           INPUT aux_inavsden,
                           INPUT aux_inavsseg,
                           INPUT aux_inavssau,
                           INPUT aux_cdempres,
                           INPUT aux_idtpempr, /* aqui */
                           INPUT aux_nrdconta, /* aqui */
                           INPUT aux_dtultufp, /* aqui */
                           INPUT aux_nmcontat, /* aqui */
                           INPUT aux_nmresemp,
                           INPUT aux_nmextemp,
                           INPUT aux_tpdebemp,
                           INPUT aux_tpdebcot,
                           INPUT aux_tpdebppr,
                           INPUT aux_cdempfol,
                           INPUT aux_dtavscot,
                           INPUT aux_dtavsemp,
                           INPUT aux_dtavsppr,
                           INPUT aux_flgpagto,
                           INPUT aux_tpconven,
                           INPUT aux_cdufdemp,
                           INPUT aux_dscomple,
                           INPUT aux_dsdemail,
                           INPUT aux_dsendemp,
                           INPUT aux_dtfchfol,
                           INPUT aux_indescsg,
                           INPUT aux_nmbairro,
                           INPUT aux_nmcidade,
                           INPUT aux_nrcepend,
                           INPUT aux_nrdocnpj,
                           INPUT aux_nrendemp,
                           INPUT aux_nrfaxemp,
                           INPUT aux_nrfonemp,
                           INPUT aux_flgarqrt,
                           INPUT aux_flgvlddv,
                           INPUT aux_flgpgtib, /* aqui */
                           INPUT aux_cdcontar, /* aqui */
                           INPUT aux_vllimfol, /* aqui */
                           INPUT aux_flgdgfib,
                           INPUT aux_dtlimdeb,
						   INPUT aux_nrdddemp,
                           OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Grava_tabela:

    RUN Grava_tabela IN hBO(INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux2_dtmvtolt,
                            INPUT aux_idorigem,
                            INPUT aux_nmdatela,
                            INPUT aux_cdprogra,
                            INPUT aux_nmsistem,
                            INPUT aux_tptabela,
                            INPUT aux_cdempres,
                            INPUT aux_cdacesso,
                            INPUT aux_tpregist,
                            INPUT aux_dstextab,
                            OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE Valida_feriado:

    RUN Valida_feriado IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux2_dtmvtolt,
                              INPUT aux_idorigem,
                              INPUT aux_nmdatela,
                              INPUT aux_cdprogra,
                              INPUT aux_dtferiad,
                              OUTPUT par_feriad,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "feriad",INPUT STRING(par_feriad)).
            RUN piXmlSave.
        END.
            
END PROCEDURE.

PROCEDURE Terceiro_quinto_dia_util:
    RUN Terceiro_quinto_dia_util IN hBO(INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_dtmvtolt,
                                        INPUT par_idorigem,
                                        INPUT par_nmdatela,
                                        INPUT par_cdprogra,
                                        INPUT par_dtferiad, /* dtavisos */
                                        OUTPUT aux_dtavisos,
                                        OUTPUT aux_dtavs001,
                                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "feriad",INPUT STRING(par_feriad)).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Define_cdempres:

    RUN Define_cdempres IN hBO(INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux2_dtmvtolt,
                               INPUT aux_idorigem,
                               INPUT aux_nmdatela,
                               INPUT aux_cdprogra,
                               OUTPUT par_cdempres,
                               OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdempres",INPUT STRING(par_cdempres)).
            RUN piXmlSave.
        END.
    
END PROCEDURE.

PROCEDURE Gera_arquivo_log:

    RUN Gera_arquivo_log IN hBO(INPUT aux_cdcooper,
                                INPUT aux_cdopcao,
                                INPUT aux2_dtmvtolt,
                                INPUT aux_cdoperad,
                                INPUT aux_cdempres,
                                INPUT aux_idtpempr,
                                INPUT aux_nrdconta,
                                INPUT aux_dtultufp,
                                INPUT aux_flgpgtib,
                                INPUT aux_cdcontar,
                                INPUT aux_vllimfol,
                                INPUT aux_nmcontat,
                                INPUT old_indescsg,
                                INPUT new_indescsg,
                                INPUT old_dtfchfol,
                                INPUT new_dtfchfol,
                                INPUT old_flgpagto,
                                INPUT new_flgpagto,
                                INPUT old_flgarqrt,
                                INPUT new_flgarqrt,
                                INPUT old_flgvlddv,
                                INPUT new_flgvlddv,
                                INPUT old_cdempfol,
                                INPUT new_cdempfol,
                                INPUT old_tpconven,
                                INPUT new_tpconven,
                                INPUT old_tpdebemp,
                                INPUT new_tpdebemp,
                                INPUT old_tpdebcot,
                                INPUT new_tpdebcot,
                                INPUT old_tpdebppr,
                                INPUT new_tpdebppr,
                                INPUT old_cdempres,
                                INPUT old_idtpempr,
                                INPUT old_nrdconta,
                                INPUT old_dtultufp,
                                INPUT old_flgpgtib,
                                INPUT old_cdcontar,
                                INPUT old_vllimfol,
                                INPUT old_nmcontat,
                                INPUT new_cdempres,
                                INPUT aux_idtpempr,
                                INPUT aux_nrdconta,
                                INPUT aux_dtultufp,
                                INPUT aux_flgpgtib,
                                INPUT aux_cdcontar,
                                INPUT aux_vllimfol,
                                INPUT aux_nmcontat,
                                INPUT old_dtavscot,
                                INPUT new_dtavscot,
                                INPUT old_dtavsemp,
                                INPUT new_dtavsemp,
                                INPUT old_dtavsppr,
                                INPUT new_dtavsppr,
                                INPUT old_nmextemp,
                                INPUT new_nmextemp,
                                INPUT old_nmresemp,
                                INPUT new_nmresemp,
                                INPUT old_cdufdemp,
                                INPUT new_cdufdemp,
                                INPUT old_dscomple,
                                INPUT new_dscomple,
                                INPUT old_dsdemail,
                                INPUT new_dsdemail,
                                INPUT old_dsendemp,
                                INPUT new_dsendemp,
                                INPUT old_nmbairro,
                                INPUT new_nmbairro,
                                INPUT old_nmcidade,
                                INPUT new_nmcidade,
                                INPUT old_nrcepend,
                                INPUT new_nrcepend,
                                INPUT old_nrdocnpj,
                                INPUT new_nrdocnpj,
                                INPUT old_nrendemp,
                                INPUT new_nrendemp,
                                INPUT old_nrfaxemp,
                                INPUT new_nrfaxemp,
                                INPUT old_nrfonemp,
                                INPUT new_nrfonemp,
                                INPUT old_dtlimdeb,
                                INPUT new_dtlimdeb,
								INPUT old_nrdddemp,
								INPUT new_nrdddemp).    


    RUN piXmlNew.
    RUN piXmlSave. 

END PROCEDURE.

PROCEDURE Busca_Convenios_Tarifarios:

    RUN Busca_Convenios_Tarifarios IN hBO
                                  (INPUT aux_cdcooper
                                  ,OUTPUT TABLE tt-convenio).

    IF  RETURN-VALUE <> "OK"  THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
        IF  NOT AVAILABLE tt-erro  THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                      "operacao.".
        END.
                
        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                        INPUT "Erro").
    END.
    ELSE DO:
        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-convenio:HANDLE,
                         INPUT "Convenio").
        RUN piXmlSave.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Busca_Conta_Emp:

    RUN Busca_Conta_Emp IN hBO
                       (INPUT aux_cdcooper,
                        INPUT aux_nrdconta,
                        INPUT aux_cdempres,
                        INPUT aux_cdopcao,
                        INPUT aux_nmprimtl,
                        OUTPUT TABLE tt-titular,
                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-titular:HANDLE,
                            INPUT "Contas").
           RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE busca_dados_associado:

    RUN busca_dados_associado IN hBO
                             (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_dtmvtolt,
                              INPUT aux_idorigem,
                              INPUT aux_nmdatela,
                              INPUT aux_cdprogra,
                              INPUT aux_nrdconta,
                              OUTPUT TABLE tt-dados-ass,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-dados-ass:HANDLE,
                            INPUT "Associado").
           RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Impresao_Termo_Servico:

    DEFINE VARIABLE aux_nmarqpdf AS CHARACTER   NO-UNDO.

    RUN Impresao_Termo_Servico IN hBO(INPUT aux_cdcooper,
                                      INPUT aux2_dtmvtolt,
                                      INPUT aux_cdagenci,
                                      INPUT 1,
                                      INPUT aux_cdempres,
                                      INPUT aux_indtermo,
                                      INPUT aux_lisconta,
                                      OUTPUT aux_nmarqpdf,
                                      OUTPUT aux_cdcritic,
                                      OUTPUT aux_dscritic).

    IF  RETURN-VALUE <> "OK"  THEN DO:

        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro  THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = aux_dscritic.
        END.
                
        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                        INPUT "Erro").
    END.
    ELSE DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
        RUN piXmlSave.
    END.

END PROCEDURE.

PROCEDURE Busca_Procuradores_Emp:

    RUN Busca_Procuradores_Emp IN hBO
                             (INPUT aux_cdcooper,
                              INPUT aux_cdempres,
                              OUTPUT TABLE tt-procuradores-emp,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-procuradores-emp:HANDLE,
                            INPUT "Procurador").
           RUN piXmlSave.
        END.

END PROCEDURE.
