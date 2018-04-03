/*.............................................................................

    Programa: xb1wgen0059.p
    Autor   : Jose Luis
    Data    : Marco/2010                   Ultima atualizacao: 31/10/2017

    Objetivo  : BO de Comunicacao XML x BO Generica de Buscas (b1wgen0059.p)

    Alteracoes: 10/08/2010 - Atribuir parametro rsnatjur ao campo aux_dsnatjur
                             (Jose Luis, DB1)
               
                28/10/2010 - Criação da Procedures Busca_Linha_Credito 
                             (Éder -GATI)
                             
                03/01/2011 - Incluir zoom de convenios (Gabriel).   
                
                12/05/2011 - Inclusao da procedure busca_modalidades  
                             (Isara - RKAM).
                             
                16/05/2011 - Procedimento busca_historico. (André - DB1)

                18/05/2011 - Procedimento busca_opcoes_alt. (André - DB1)

                22/06/2011 - Inlcuir zoom para convenios (Gabriel) 

                28/07/2011 - Procedimento para busca de motivos de nao 
                             aprovacao - busca_gncmapr (Diego B. - Gati).  

                06/10/2011 - Criado a procedure Buca_Cooperativa (Adriano).

                24/10/2011 - Adicionado a opção de pesquisa por CPF/CNPJ 
                           na procedure zoom-associados (Rogerius Militão/DB1).

                07/11/2011 - Criado procedure busca_chashes (Gabriel - DB1).

                12/01/2012 - Criado procedure busca_arquivos_pamcard. 
                             (Fabricio).

                26/02/2013 - Criado as procedures busca-crapope, busca-agencia,
                             busca-rotina (Adriano).

                31/03/2014 - Correcoes sd 122817 (Carlos)

                04/04/2014 - Inclusao da procedure busca-crapttl (Jean Michel)

                16/04/2014 - Adicionado parametro par_cdfinemp na procedure 
                             busca-craplcr
                           - Removido parametro par_cdlcremp da procedure 
                             busca-crapfin. (Reinert)

                28/08/2014 - Nova procedure de Zoom para Perfil de Operadores
                            (Guilherme/SUPERO)
                            
                26/03/2015 - Criado proc. busca-produtos para listar produtos. 
                             (Jorge/Rodrigo).
                 
                03/07/2015 - Criacao do novo parametro aux_cdmodali na busca_linhas_credito
                             (Carlos Rafael Tanholi - Projeto Portabilidade).   
                  
				15/07/2016 - Eliminado a rotina Busca_Linha_Credito devido a conversao para PLSQL
						    (Andrei - RKAM).                 
							
				22/02/2017 - Removido as rotinas busca_nat_ocupacao, busca_ocupacao devido a conversao 
				             da busca_gncdnto e da busca-gncdocp
							 (Adriano - SD 614408).	

				23/03/2017 - Adicionado tratamento na procedure Busca-Agencia. (PRJ321 - Reinert)

                29/03/2017 - Criacao do novo parametro aux_tpprodut na busca_linhas_credito.
                             (Jaison/James - PRJ298)

				15/07/2017 - Nova procedure. busca-crapass para listar os associados. (Mauro).

                31/10/2017 - Passagem do tpctrato. (Jaison/Marcos Martini - PRJ404)

.............................................................................*/

                                                                             

/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdcoopea AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_nrispbif AS INTE                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_cdestcvl AS INTE                                           NO-UNDO.
DEF VAR aux_dsestcvl AS CHAR                                           NO-UNDO.
DEF VAR aux_dsnacion AS CHAR                                           NO-UNDO.
DEF VAR aux_dsnatura AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_dsproftl AS CHAR                                           NO-UNDO.
DEF VAR aux_tpnacion AS INTE                                           NO-UNDO.
DEF VAR aux_destpnac AS CHAR                                           NO-UNDO.
DEF VAR aux_grescola AS INTE                                           NO-UNDO.
DEF VAR aux_dsescola AS CHAR                                           NO-UNDO.
DEF VAR aux_cdfrmttl AS INTE                                           NO-UNDO.
DEF VAR aux_rsfrmttl AS CHAR                                           NO-UNDO.
DEF VAR aux_cdnatjur AS INTE                                           NO-UNDO.
DEF VAR aux_dsnatjur AS CHAR                                           NO-UNDO.
DEF VAR aux_cdseteco AS INTE                                           NO-UNDO.
DEF VAR aux_nmseteco AS CHAR                                           NO-UNDO.
DEF VAR aux_cdrmativ AS INTE                                           NO-UNDO.
DEF VAR aux_nmrmativ AS CHAR                                           NO-UNDO.
DEF VAR aux_cddbanco AS INTE                                           NO-UNDO.
DEF VAR aux_nmdbanco AS CHAR                                           NO-UNDO.
DEF VAR aux_cdageban AS INTE                                           NO-UNDO.
DEF VAR aux_nmageban AS CHAR                                           NO-UNDO.
DEF VAR aux_cdrelato AS INTE                                           NO-UNDO.
DEF VAR aux_cddfrenv AS INTE                                           NO-UNDO.
DEF VAR aux_cdperiod AS DECI                                           NO-UNDO.
DEF VAR aux_cdprogra AS INTE                                           NO-UNDO.
DEF VAR aux_nrinfcad AS INTE                                           NO-UNDO.
DEF VAR aux_nrpatlvr AS INTE                                           NO-UNDO.
DEF VAR aux_dsdemail AS CHAR                                           NO-UNDO.
DEF VAR aux_tpendass AS INTE                                           NO-UNDO.
DEF VAR aux_tptelefo AS INTE                                           NO-UNDO.
DEF VAR aux_nrtopico AS INTE                                           NO-UNDO.
DEF VAR aux_nritetop AS INTE                                           NO-UNDO.
DEF VAR aux_cdnatocp AS INTE                                           NO-UNDO.
DEF VAR aux_rsnatocp AS CHAR                                           NO-UNDO.
DEF VAR aux_cddocupa AS INTE                                           NO-UNDO.
DEF VAR aux_rsdocupa AS CHAR                                           NO-UNDO.
DEF VAR aux_cdturnos AS INTE                                           NO-UNDO.
DEF VAR aux_dsturnos AS CHAR                                           NO-UNDO.
DEF VAR aux_cdnvlcgo AS INTE                                           NO-UNDO.
DEF VAR aux_rsnvlcgo AS CHAR                                           NO-UNDO.
DEF VAR aux_nrseqite AS INTE                                           NO-UNDO.
DEF VAR aux_dsseqite AS CHAR                                           NO-UNDO.
DEF VAR aux_cdseqinc AS INTE                                           NO-UNDO.
DEF VAR aux_incasprp AS INTE                                           NO-UNDO.
DEF VAR aux_dscasprp AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagepac AS INTE                                           NO-UNDO.
DEF VAR aux_dsagepac AS CHAR                                           NO-UNDO.
DEF VAR aux_nmresage AS CHAR                                           NO-UNDO.
DEF VAR aux_cdsecext AS INTE                                           NO-UNDO.
DEF VAR aux_dssecext AS CHAR                                           NO-UNDO.
DEF VAR aux_cdtipcta AS INTE                                           NO-UNDO.
DEF VAR aux_dstipcta AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagpesq AS INTE                                           NO-UNDO.
DEF VAR aux_cdpesqui AS INTE                                           NO-UNDO.
DEF VAR aux_nmdbusca AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdapesq AS INTE                                           NO-UNDO.
DEF VAR aux_nrdctitg AS CHAR                                           NO-UNDO.
DEF VAR aux_cdopetfn AS INTE                                           NO-UNDO.
DEF VAR aux_nmopetfn AS CHAR                                           NO-UNDO.
DEF VAR aux_cdtipdep AS INTE                                           NO-UNDO.
DEF VAR aux_dstipdep AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdrendi AS INTE                                           NO-UNDO.
DEF VAR aux_dsdrendi AS CHAR                                           NO-UNDO.
DEF VAR aux_cdempres AS INTE                                           NO-UNDO.
DEF VAR aux_nmresemp AS CHAR                                           NO-UNDO.
DEF VAR aux_cdmotdem AS INTE                                           NO-UNDO.
DEF VAR aux_dsmotdem AS CHAR                                           NO-UNDO.
DEF VAR aux_cddlinha AS INTE                                           NO-UNDO.
DEF VAR aux_dsdlinha AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdlinha AS INTE                                           NO-UNDO.
DEF VAR aux_flgstlcr AS LOG                                            NO-UNDO.
DEF VAR aux_tpdorgan AS INTE                                           NO-UNDO.
DEF VAR aux_nrconven AS INTE                                           NO-UNDO.
DEF VAR aux_dsorgarq AS CHAR                                           NO-UNDO.
DEF VAR aux_cdlcremp AS INTE                                           NO-UNDO.
DEF VAR aux_dslcremp AS CHAR                                           NO-UNDO.
DEF VAR aux_dsfinemp AS CHAR                                           NO-UNDO.
DEF VAR aux_cdfinemp AS INTE                                           NO-UNDO.
DEF VAR aux_flgstfin AS LOG                                            NO-UNDO.
DEF VAR aux_flgcompl AS LOG                                            NO-UNDO.
DEF VAR aux_flglanca AS LOGI                                           NO-UNDO.
DEF VAR aux_inautori AS INTE                                           NO-UNDO.
DEF VAR aux_cdhistor AS INTE                                           NO-UNDO.
DEF VAR aux_dshistor AS CHAR                                           NO-UNDO.
DEF VAR aux_nmsistem AS CHAR                                           NO-UNDO.
DEF VAR aux_tptabela AS CHAR                                           NO-UNDO.
DEF VAR aux_cdacesso AS CHAR                                           NO-UNDO.
DEF VAR aux_cdidenti AS DECI                                           NO-UNDO.
DEF VAR aux_cdconven AS INTE                                           NO-UNDO.
DEF VAR aux_nmempres AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcmaprv AS INTE                                           NO-UNDO.
DEF VAR aux_dscmaprv AS CHAR                                           NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                           NO-UNDO.
DEF VAR aux_nmextcop AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DEC                                            NO-UNDO.
DEF VAR aux_nrterfin AS INTE                                           NO-UNDO.
DEF VAR aux_nmterfin AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcopsol AS INT                                            NO-UNDO.
DEF VAR aux_cdopelib AS CHAR                                           NO-UNDO.
DEF VAR aux_cdbccxlt AS INT                                            NO-UNDO.
DEF VAR aux_cdoperac AS CHAR                                           NO-UNDO.
DEF VAR aux_dsoperac AS CHAR                                           NO-UNDO.
DEF VAR aux_cdperfil AS CHAR                                           NO-UNDO.
DEF VAR aux_dsperfil AS CHAR                                           NO-UNDO.
DEF VAR aux_dsarnego AS CHAR                                           NO-UNDO.
DEF VAR aux_dsprodut AS CHAR                                           NO-UNDO.
DEF VAR aux_cdmodali AS CHAR                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_cdrelacionamento AS INTE                                   NO-UNDO.
DEF VAR aux_dsrelacionamento AS CHAR                                   NO-UNDO.
DEF VAR aux_tpctrato AS INTE                                           NO-UNDO.
DEF VAR aux_tpprodut AS INTE INIT ?                                    NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0059tt.i 
    &VAR-AMB=SIM &PROC-BUSCA=SIM &BD-GEN=SIM}

/*...........................................................................*/

PROCEDURE valores_entrada:

    FOR EACH tt-param:
    
        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdcoopea" THEN aux_cdcoopea = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN 
                ASSIGN 
                   aux_cdagenci = INTE(tt-param.valorCampo)
                   aux_cdagepac = aux_cdagenci.
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "nrispbif" THEN aux_nrispbif = INTE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "cdestcvl" THEN aux_cdestcvl = INTE(tt-param.valorCampo).
            WHEN "dsestcvl" THEN aux_dsestcvl = tt-param.valorCampo.
            WHEN "dsnacion" THEN aux_dsnacion = tt-param.valorCampo.
            WHEN "dsnatura" THEN aux_dsnatura = tt-param.valorCampo.
            WHEN "dsproftl" THEN aux_dsproftl = tt-param.valorCampo.
            WHEN "tpnacion" THEN aux_tpnacion = INTE(tt-param.valorCampo).
            WHEN "destpnac" THEN aux_destpnac = tt-param.valorCampo.
            WHEN "grescola" THEN aux_grescola = INTE(tt-param.valorCampo).
            WHEN "dsescola" THEN aux_dsescola = tt-param.valorCampo.
            WHEN "cdfrmttl" THEN aux_cdfrmttl = INTE(tt-param.valorCampo).
            WHEN "rsfrmttl" THEN aux_rsfrmttl = tt-param.valorCampo.
            WHEN "cdnatjur" OR WHEN "natjurid" THEN 
                aux_cdnatjur = INTE(tt-param.valorCampo).
            WHEN "dsnatjur" OR WHEN "rsnatjur" THEN 
                aux_dsnatjur = tt-param.valorCampo.
            WHEN "cdseteco" THEN aux_cdseteco = INTE(tt-param.valorCampo).
            WHEN "nmseteco" THEN aux_nmseteco = tt-param.valorCampo.
            WHEN "cdrmativ" THEN aux_cdrmativ = INTE(tt-param.valorCampo).
            WHEN "nmrmativ" OR WHEN "dsrmativ" THEN 
                aux_nmrmativ = tt-param.valorCampo.
            WHEN "cddbanco" THEN aux_cddbanco = INTE(tt-param.valorCampo).
            WHEN "nmdbanco" OR WHEN "dsdbanco" OR WHEN "nmextbcc" OR WHEN "nmresbcc" THEN 
                aux_nmdbanco = tt-param.valorCampo.
            WHEN "cdageban" THEN aux_cdageban = INTE(tt-param.valorCampo).
            WHEN "nmageban" THEN aux_nmageban = tt-param.valorCampo.
            WHEN "cddfrenv" THEN aux_cddfrenv = INTE(tt-param.valorCampo).
            WHEN "cdperiod" THEN aux_cdperiod = DECI(tt-param.valorCampo).
            WHEN "cdprogra" THEN aux_cdprogra = INTE(tt-param.valorCampo).
            WHEN "cdrelato" THEN aux_cdrelato = INTE(tt-param.valorCampo).
            WHEN "nrinfcad" OR WHEN "nrpatlvr" OR 
            WHEN "nrperger" OR WHEN "nrseqite" THEN 
                aux_nrseqite = INTE(tt-param.valorCampo).
            WHEN "nrpatlvr" THEN aux_nrpatlvr = INTE(tt-param.valorCampo).
            WHEN "dsdemail" THEN aux_dsdemail = tt-param.valorCampo.
            WHEN "tpendass" THEN aux_tpendass = INTE(tt-param.valorCampo).
            WHEN "tptelefo" THEN aux_tptelefo = INTE(tt-param.valorCampo).
            WHEN "nrtopico" THEN aux_nrtopico = INTE(tt-param.valorCampo).
            WHEN "nritetop" THEN aux_nritetop = INTE(tt-param.valorCampo).
            WHEN "cdnatopc" THEN aux_cdnatocp = INTE(tt-param.valorCampo).
            WHEN "rsnatocp" THEN aux_rsnatocp = tt-param.valorCampo.
            WHEN "cdocpcje" OR WHEN "cddocupa" OR WHEN "cdocpttl" THEN 
                aux_cddocupa = INTE(tt-param.valorCampo).
            WHEN "rsdocupa" OR WHEN "rsocupa" OR WHEN "dsocpttl" THEN 
                aux_rsdocupa = tt-param.valorCampo.
            WHEN "cdturnos" THEN aux_cdturnos = INTE(tt-param.valorCampo).
            WHEN "dsturnos" THEN aux_dsturnos = tt-param.valorCampo.
            WHEN "cdnvlcgo" THEN aux_cdnvlcgo = INTE(tt-param.valorCampo).
            WHEN "rsnvlcgo" THEN aux_rsnvlcgo = tt-param.valorCampo.
            WHEN "dsinfcad" OR WHEN "dspatlvr" OR 
            WHEN "dsperger" OR WHEN "dsseqite" THEN 
                aux_dsseqite = tt-param.valorCampo.
            WHEN "cdseqinc" THEN aux_cdseqinc = INTE(tt-param.valorCampo).
            WHEN "cdagepac" THEN aux_cdagepac = INTE(tt-param.valorCampo).
            WHEN "dsagepac" OR WHEN "nmresage" THEN 
                aux_dsagepac = tt-param.valorCampo.
            WHEN "cdsecext" THEN aux_cdsecext = INTE(tt-param.valorCampo).
            WHEN "dssecext" THEN aux_dssecext = tt-param.valorCampo.
            WHEN "cdtipcta" THEN aux_cdtipcta = INTE(tt-param.valorCampo).
            WHEN "dstipcta" THEN aux_dstipcta = tt-param.valorCampo.
            WHEN "cdagpesq" THEN aux_cdagpesq = INTE(tt-param.valorCampo).
            WHEN "cdpesqui" THEN aux_cdpesqui = INTE(tt-param.valorCampo).
            WHEN "nmdbusca" THEN aux_nmdbusca = tt-param.valorCampo.
            WHEN "tpdapesq" THEN aux_tpdapesq = INTE(tt-param.valorCampo).
            WHEN "nrdctitg" THEN aux_nrdctitg = tt-param.valorCampo.
            WHEN "cdopetfn" THEN aux_cdopetfn = INTE(tt-param.valorCampo).
            WHEN "nmopetfn" THEN aux_nmopetfn = tt-param.valorCampo.
            WHEN "cdtipdep" THEN aux_cdtipdep = INTE(tt-param.valorCampo).
            WHEN "dstipdep" THEN aux_dstipdep = tt-param.valorCampo.
            WHEN "tpdrendi" OR WHEN "tpdrend2" OR 
                WHEN "tpdrend3" OR WHEN "tpdrend4" OR
                WHEN "tpdrend5" OR WHEN "tpdrend6" OR WHEN "tpdrend1" THEN 
                aux_tpdrendi = INTE(tt-param.valorCampo).
            WHEN "dsdrendi" OR WHEN "dsdrend2" OR 
                WHEN "dsdrend3" OR WHEN "dsdrend4" OR 
                WHEN "dsdrend5" OR WHEN "dsdrend6" OR WHEN "dsdrend1" THEN 
                aux_dsdrendi = tt-param.valorCampo.
            WHEN "cdempres" THEN aux_cdempres = INTE(tt-param.valorCampo).
            WHEN "nmresemp" THEN aux_nmresemp = tt-param.valorCampo.
            WHEN "cdmotdem" THEN aux_cdmotdem = INTE(tt-param.valorCampo).
            WHEN "dsmotdem" THEN aux_dsmotdem = tt-param.valorCampo.
            WHEN "cddlinha" THEN aux_cddlinha = INTE(tt-param.valorCampo).
            WHEN "dsdlinha" THEN aux_dsdlinha = tt-param.valorCampo.
            WHEN "tpdlinha" THEN aux_tpdlinha = INTE(tt-param.valorCampo).
            WHEN "flgstlcr" THEN aux_flgstlcr = LOGICAL(tt-param.valorCampo).
            WHEN "tpdorgan" THEN aux_tpdorgan = INTE(tt-param.valorCampo).
            WHEN "nrconven" THEN aux_nrconven = INTE(tt-param.valorCampo).
            WHEN "dsorgarq" THEN aux_dsorgarq = tt-param.valorCampo.
            WHEN "cdlcremp" THEN aux_cdlcremp = INTE(tt-param.valorCampo).
            WHEN "dslcremp" THEN aux_dslcremp = tt-param.valorCampo.
            WHEN "dsfinemp" THEN aux_dsfinemp = tt-param.valorCampo.
            WHEN "cdfinemp" THEN aux_cdfinemp = INTE(tt-param.valorCampo).
            WHEN "flgstfin" THEN aux_flgstfin = LOGICAL(tt-param.valorCampo).
            WHEN "flgcompl" THEN aux_flgcompl = LOGICAL(tt-param.valorCampo).
            WHEN "inautori" THEN aux_inautori = INTE(tt-param.valorCampo).
            WHEN "flglanca" THEN aux_flglanca = LOGICAL(tt-param.valorCampo).
            WHEN "dshistor" THEN aux_dshistor = tt-param.valorCampo.
            WHEN "cdhistor" THEN aux_cdhistor = INTE(tt-param.valorCampo).
            WHEN "nmsistem" THEN aux_nmsistem = tt-param.valorCampo.
            WHEN "tptabela" THEN aux_tptabela = tt-param.valorCampo.
            WHEN "cdacesso" THEN aux_cdacesso = tt-param.valorCampo.
            WHEN "cdidenti" THEN aux_cdidenti = DECI(tt-param.valorCampo).
            WHEN "cdconven" THEN aux_cdconven = INTE(tt-param.valorCampo).
            WHEN "nmempres" THEN aux_nmempres = tt-param.valorCampo.
            WHEN "cdcmaprv" THEN aux_cdcmaprv = INTE(tt-param.valorCampo).
            WHEN "dscmaprv" THEN aux_dscmaprv = tt-param.valorCampo.
            WHEN "nrctremp" THEN aux_nrctremp = INTE(tt-param.valorCampo).
            WHEN "nmextcop" THEN aux_nmextcop = tt-param.valorCampo.
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
            WHEN "nrterfin" THEN aux_nrterfin = INTE(tt-param.valorCampo).
            WHEN "nmterfin" THEN aux_nmterfin = tt-param.valorCampo.
            WHEN "nmarquiv" THEN aux_nmarquiv = tt-param.valorCampo.
            WHEN "nmoperad" THEN aux_nmoperad = tt-param.valorCampo.
            WHEN "cdcopsol" THEN aux_cdcopsol = INT(tt-param.valorCampo).
            WHEN "cdopelib" THEN aux_cdopelib = (tt-param.valorCampo).
            WHEN "cdbccxlt" THEN aux_cdbccxlt = INT(tt-param.valorCampo).
            WHEN "cdoperac" THEN aux_cdoperac = tt-param.valorCampo.
            WHEN "dsoperac" THEN aux_dsoperac = tt-param.valorCampo.
            WHEN "cdperfil" THEN aux_cdperfil = tt-param.valorCampo.
            WHEN "dsperfil" THEN aux_cdperfil = tt-param.valorCampo.
            WHEN "dsarnego" THEN aux_dsarnego = tt-param.valorCampo.
            WHEN "dsprodut" THEN aux_dsprodut = tt-param.valorCampo.
            WHEN "cdmodali" THEN aux_cdmodali = tt-param.valorCampo.
            WHEN "inpessoa" THEN aux_inpessoa = INT(tt-param.valorCampo).
            WHEN "nmprimtl" THEN aux_nmprimtl = tt-param.valorCampo.            
            WHEN "cdrelacionamento" THEN aux_cdrelacionamento = INTE(tt-param.valorCampo).
            WHEN "dsrelacionamento" THEN aux_dsrelacionamento = tt-param.valorCampo.
            WHEN "tpctrato" THEN aux_tpctrato = INT(tt-param.valorCampo).
            WHEN "tpprodut" THEN aux_tpprodut = INT(tt-param.valorCampo).
                
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.    

PROCEDURE Busca_Naturalidade:

    RUN carrega-objeto.

    RUN busca-crapnat IN h-b1wgen0059
        ( INPUT aux_dsnatura,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapnat ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapnat:HANDLE,
                             INPUT "Naturalidade").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Nacionalidade:

    RUN carrega-objeto.

    RUN busca-crapnac IN h-b1wgen0059
        ( INPUT 0,
          INPUT aux_dsnacion,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapnac ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapnac:HANDLE,
                             INPUT "Nacionalidade").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Estado_Civil:

    RUN carrega-objeto.

    RUN busca-gnetcvl IN h-b1wgen0059
        ( INPUT aux_cdestcvl,
          INPUT aux_dsestcvl,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-gnetcvl ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-gnetcvl:HANDLE,
                             INPUT "EstadoCivil").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Cargos:

    RUN carrega-objeto.

    RUN busca-cargos IN h-b1wgen0059
        ( INPUT 0,
          INPUT aux_dsproftl,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-cargos ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-cargos:HANDLE,
                             INPUT "Cargos").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Tipo_Nacionalidade:

    RUN carrega-objeto.

    RUN busca-gntpnac IN h-b1wgen0059
        ( INPUT aux_tpnacion,
          INPUT aux_destpnac,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-gntpnac ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-gntpnac:HANDLE,
                             INPUT "TipoNacionalidade").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Grau_Escolar:

    RUN carrega-objeto.

    RUN busca-gngresc IN h-b1wgen0059
        ( INPUT aux_grescola,
          INPUT aux_dsescola,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-gngresc ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-gngresc:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Formacao:

    RUN carrega-objeto.

    RUN busca-gncdfrm IN h-b1wgen0059
        ( INPUT aux_cdfrmttl,
          INPUT aux_rsfrmttl,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-gncdfrm ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-gncdfrm:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Natureza_Juridica:

    RUN carrega-objeto.

    RUN busca-gncdntj IN h-b1wgen0059
        ( INPUT aux_cdnatjur,
          INPUT aux_dsnatjur,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-gncdntj ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-gncdntj:HANDLE,
                             INPUT "NaturezaJuridica").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Setor_Economico:

    RUN carrega-objeto.

    RUN busca-setorec IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_cdseteco,
          INPUT aux_nmseteco,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-setorec ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-setorec:HANDLE,
                             INPUT "SetorEconomico").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Ramo_Atividade:

    RUN carrega-objeto.

    RUN busca-gnrativ IN h-b1wgen0059
        ( INPUT aux_cdseteco,
          INPUT aux_cdrmativ,
          INPUT aux_nmrmativ,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-gnrativ ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-gnrativ:HANDLE,
                             INPUT "RamoAtividade").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Convenio:

    RUN carrega-objeto.

    RUN busca-gnconve IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_cdconven,
          INPUT aux_nmempres,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-gnconve).    

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-gnconve:HANDLE,
                             INPUT "Banco").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.



PROCEDURE Busca_Banco:

    RUN carrega-objeto.

    RUN busca-crapban IN h-b1wgen0059
        ( INPUT aux_cdbccxlt,
          INPUT aux_nmdbanco,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapban ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapban:HANDLE,
                             INPUT "Banco").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Agencia:

    RUN carrega-objeto.

	IF aux_cddbanco = 0 AND
	   aux_cdbccxlt > 0 then
	   ASSIGN aux_cddbanco = aux_cdbccxlt.

    RUN busca-crapagb IN h-b1wgen0059
        ( INPUT aux_cddbanco,
          INPUT aux_cdageban,
          INPUT aux_nmageban,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapagb ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapagb:HANDLE,
                             INPUT "Agencia").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Relatorios:

    RUN carrega-objeto.

    RUN busca-crapifc IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_cdrelato,
          INPUT aux_cdprogra,
          INPUT aux_cddfrenv,
          INPUT aux_cdperiod,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapifc ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapifc:HANDLE,
                             INPUT "Relatorios").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Email:

    RUN carrega-objeto.

    RUN busca-crapcem IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_nrdconta,
          INPUT aux_idseqttl,
          INPUT aux_dsdemail,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapcem ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcem:HANDLE,
                             INPUT "Emails").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Telefone:

    RUN carrega-objeto.

    RUN busca-craptfc IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_nrdconta,
          INPUT aux_idseqttl,
          INPUT aux_tptelefo,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-craptfc ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-craptfc:HANDLE,
                             INPUT "Telefone").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Endereco:

    RUN carrega-objeto.

    RUN busca-crapenc IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_nrdconta,
          INPUT aux_idseqttl,
          INPUT aux_tpendass,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapenc ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapenc:HANDLE,
                             INPUT "Endereco").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Recebimento:

    RUN carrega-objeto.

    RUN busca-recebto IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_nrdconta,
          INPUT aux_idseqttl,
          INPUT aux_cddfrenv,
          INPUT aux_cdseqinc,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-recebto ). 

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-recebto:HANDLE,
                             INPUT "Endereco").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlAtributo (INPUT "cddfrenv",INPUT STRING(aux_cddfrenv)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_SeqRating:

    RUN carrega-objeto.

    RUN busca-craprad IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_nrtopico,
          INPUT aux_nritetop,
          INPUT aux_nrseqite,
          INPUT aux_dsseqite,
          INPUT aux_flgcompl,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-craprad ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-craprad:HANDLE,
                             INPUT "SeqRating").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.


/*
craptab dstextab = 'CONJUGE,1,PAI/MAE,2,FILHO(A),3,COMPANHEIRO(A),4,OUTROS,5,COLABORADOR(A),6,ENTEADO(A),7,NENHUM,9'
			where craptab.cdcooper > 0 AND
				  craptab.nmsistem = 'CRED'                     AND
				  craptab.tptabela = 'GENERI'                   AND
				  craptab.cdempres = 0                          AND
				  craptab.cdacesso = 'VINCULOTTL'               AND
				  craptab.tpregist = 0;
*/
PROCEDURE busca_relacionamento:

    RUN carrega-objeto.

    RUN busca-relacionamento IN h-b1wgen0059
        ( INPUT aux_cdrelacionamento,
          INPUT aux_dsrelacionamento,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-relacionamento ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-relacionamento:HANDLE,
                             INPUT "Relacionamento").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.



PROCEDURE busca_turnos:

    RUN carrega-objeto.

    RUN busca-turnos IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_cdturnos,
          INPUT aux_dsturnos,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-turnos ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-turnos:HANDLE,
                             INPUT "Turnos").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE busca_nivel_cargo:

    RUN carrega-objeto.

    RUN busca-gncdncg IN h-b1wgen0059
        ( INPUT aux_cdnvlcgo,
          INPUT aux_rsnvlcgo,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-gncdncg ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-gncdncg:HANDLE,
                             INPUT "NivelCargo").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.


PROCEDURE busca_tpimovel:

    RUN carrega-objeto.

    RUN busca-tpimovel IN h-b1wgen0059
        ( INPUT aux_incasprp,
          INPUT aux_dscasprp,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-tpimovel ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-tpimovel:HANDLE,
                             INPUT "TipoImovel").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Pac:

    RUN carrega-objeto.

    RUN busca-crapage IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_cdagepac,
          INPUT aux_dsagepac,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapage ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapage:HANDLE,
                             INPUT "PA").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Destino_Extrato:

    RUN carrega-objeto.

    RUN busca-crapdes IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_cdagepac,
          INPUT aux_cdsecext,
          INPUT aux_dssecext,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapdes ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapdes:HANDLE,
                             INPUT "DestExtrato").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Tipo_Conta:

    RUN carrega-objeto.

    RUN busca-craptip IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_cdtipcta,
          INPUT aux_dstipcta,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-craptip ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-craptip:HANDLE,
                             INPUT "TipoConta").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE zoom-associados:

    RUN carrega-objeto.

    RUN zoom-associados IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_cdagpesq,
          INPUT aux_cdpesqui,
          INPUT aux_nmdbusca,
          INPUT aux_tpdapesq,
          INPUT aux_nrdctitg,
          INPUT aux_tpdorgan,
          INPUT aux_nrcpfcgc,
          INPUT YES,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-titular ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-titular:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "qtcopera",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.


PROCEDURE busca_operadoras:

    RUN carrega-objeto.

    RUN busca-operadoras IN h-b1wgen0059
        ( INPUT 0,
          INPUT aux_cdopetfn,
          INPUT aux_nmopetfn,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-oper-tel ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-oper-tel:HANDLE,
                             INPUT "Operadoras").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Tipo_Dependentes:

    RUN carrega-objeto.

    RUN busca-tipo-depend IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_cdtipdep,
          INPUT aux_dstipdep,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-tipo-depend ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-tipo-depend:HANDLE,
                             INPUT "TipoDepend").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE busca_tipo_rendimento:

    RUN carrega-objeto.

    RUN busca-tipo-rendi IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_tpdrendi,
          INPUT aux_dsdrendi,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-tipo-rendi ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-tipo-rendi:HANDLE,
                             INPUT "TipoRendi").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE Busca_Empresa:

    RUN carrega-objeto.

    RUN busca-crapemp IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_cdempres,
          INPUT aux_nmresemp,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapemp ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapemp:HANDLE,
                             INPUT "Empresa").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE busca_motivo_demissao:

    RUN carrega-objeto.

    RUN busca-mot-demissao IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_cdmotdem,
          INPUT aux_dsmotdem,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-mot-demissao ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO: 
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO: 
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-mot-demissao:HANDLE,
                             INPUT "MotDemissao").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE busca_convenios:

    RUN carrega-objeto.

    RUN busca-crapcco IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_nrconven,
          INPUT aux_dsorgarq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapcco ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcco:HANDLE,
                             INPUT "Convenios").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.
    
END PROCEDURE.

PROCEDURE busca_linhas_credito:

    RUN busca-craplcr IN hBO
                    ( INPUT aux_cdcooper, 
                      INPUT aux_cdlcremp, 
                      INPUT aux_dslcremp,
                      INPUT aux_cdfinemp,
                      INPUT aux_flgstlcr,
                      INPUT aux_nrregist, 
                      INPUT aux_nriniseq, 
                      INPUT aux_cdmodali,
                      INPUT aux_tpprodut,
                     OUTPUT aux_qtregist, 
                     OUTPUT TABLE tt-craplcr ).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-craplcr:HANDLE,
                               INPUT "Linhas").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
           
        END.

END.

PROCEDURE busca_finalidade_empr:

    RUN busca-crapfin IN hBO
                    ( INPUT aux_cdcooper, 
                      INPUT aux_cdfinemp, 
                      INPUT aux_dsfinemp,                     
                      INPUT aux_flgstfin,
                      INPUT aux_nrregist, 
                      INPUT aux_nriniseq, 
                     OUTPUT aux_qtregist, 
                     OUTPUT TABLE tt-crapfin ).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-crapfin:HANDLE,
                               INPUT "Finalidades").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
           
        END.

END.

PROCEDURE busca_modalidades:

    RUN busca-modalidade IN hBO
                    (OUTPUT aux_qtregist, 
                     OUTPUT TABLE tt-gnmodal).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-gnmodal:HANDLE,
                               INPUT "Modalidades").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
           
        END.
END.


PROCEDURE busca_historico:

    RUN busca-historico IN hBO
        ( INPUT aux_cdcooper,
          INPUT aux_cdhistor,
          INPUT aux_dshistor,
          INPUT aux_flglanca,
          INPUT aux_inautori,
          INPUT aux_nrregist, 
          INPUT aux_nriniseq, 
         OUTPUT aux_qtregist, 
         OUTPUT TABLE tt-craphis).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-craphis:HANDLE,
                               INPUT "Historicos").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
           
        END.
END.

PROCEDURE busca-opcoes-manut-inss:

    RUN busca-opcoes-manut-inss IN hBO
        ( INPUT aux_cdcoopea,
          INPUT aux_nmsistem,
          INPUT aux_tptabela,
          INPUT aux_cdempres,
          INPUT aux_cdacesso,
          INPUT aux_nrregist, 
          INPUT aux_nriniseq, 
         OUTPUT aux_qtregist, 
         OUTPUT TABLE tt-manut-inss).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-manut-inss:HANDLE,
                               INPUT "Opcoes").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
           
        END.
END.


PROCEDURE busca_crapttl:
    

    RUN busca-crapttl IN hBO
        ( INPUT aux_cdcooper,
          INPUT aux_nrdconta,
          INPUT aux_nrregist, 
          INPUT aux_nriniseq, 
         OUTPUT aux_qtregist, 
         OUTPUT TABLE tt-crapttl).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO: 
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-crapttl:HANDLE,
                               INPUT "Titulares").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
           
        END.
END.



PROCEDURE busca_crapcgp:

    RUN busca-crapcgp IN hBO
        ( INPUT aux_cdcooper,
          INPUT aux_cdidenti,
          INPUT aux_nrregist, 
          INPUT aux_nriniseq, 
         OUTPUT aux_qtregist, 
         OUTPUT TABLE tt-crapcgp).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-crapcgp:HANDLE,
                               INPUT "Guias").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
           
        END.
END.



PROCEDURE busca_motivos_nao_aprovacao:

    RUN busca-gncmapr IN hBO
        ( INPUT aux_cdcmaprv,
          INPUT aux_dscmaprv,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist, 
         OUTPUT TABLE tt-gncmapr).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-gncmapr:HANDLE,
                               INPUT "MotNaoAprovacao").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
           
        END.

END PROCEDURE.

PROCEDURE busca_aditivos:

    RUN busca-crapadt IN hBO
        ( INPUT aux_cdcooper,
          INPUT aux_nrdconta,
          INPUT aux_nrctremp,
          INPUT aux_tpctrato,
          INPUT aux_nrregist, 
          INPUT aux_nriniseq, 
         OUTPUT aux_qtregist, 
         OUTPUT TABLE tt-crapadt).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-crapadt:HANDLE,
                               INPUT "Aditivos").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
           
        END.
END.

PROCEDURE Busca_Cooperativa:

    RUN carrega-objeto.

    RUN busca-crapcop IN hBO
        ( INPUT aux_cdcopsol,
          INPUT aux_nmextcop,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapcop ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO: 
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcop:HANDLE,
                             INPUT "Cooperativa").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.

        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE busca_chashes:

    RUN busca-craptfn IN hBO
        ( INPUT aux_cdcooper,
          INPUT aux_nrterfin,
          INPUT aux_nmterfin,
          INPUT aux_nrregist, 
          INPUT aux_nriniseq, 
         OUTPUT aux_qtregist, 
         OUTPUT TABLE tt-craptfn).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-craptfn:HANDLE,
                               INPUT "Cashes").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
           
        END.
END.

PROCEDURE busca_arquivos_pamcard:

    RUN busca_arquivos_pamcard IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_nmarquiv,
                                      OUTPUT aux_qtregist,
                                      OUTPUT TABLE tt-arquivos-pamcard).

    IF RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
        END.
                
        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
    END.
    ELSE 
    DO:
        RUN piXmlNew.
        RUN piXmlExport   (INPUT TEMP-TABLE tt-arquivos-pamcard:HANDLE,
                               INPUT "Arquivos").
        RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
        RUN piXmlSave.
           
    END.

END PROCEDURE.

/*PROCEDURE RESPONSAVEL POR ENCONTRAR O OPERADOR DE UMA COOPERATIVA ESPECIFICA*/
PROCEDURE busca-operador:

    RUN carrega-objeto.
                            
    RUN busca-crapope IN h-b1wgen0059
        ( INPUT aux_cdcopsol,
          INPUT aux_cdopelib,
          INPUT aux_cdagepac,
          INPUT aux_nmoperad,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapope ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO: 
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapope:HANDLE,
                             INPUT "Operador").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.

        END.

    RUN remove-objeto.

END PROCEDURE.


/*PROCEDURE RESPONSAVEL POR BUSCAR UMA AGENCIA DE UM COOPERATIVA SOLICITADA*/
PROCEDURE busca-agencia:

    RUN carrega-objeto.

    RUN busca-agencia IN h-b1wgen0059
        ( INPUT aux_cdcopsol,
          INPUT aux_cdagepac,
          INPUT aux_dsagepac,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapage ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapage:HANDLE,
                             INPUT "PA").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

/*PROCEDURE RESPONSAVEL POR BUSCAR A(s) ROTINA(s) NA TABELA CRAPROT*/
PROCEDURE busca-rotina:

    RUN carrega-objeto.

    RUN busca-rotina IN h-b1wgen0059
        ( INPUT aux_cdoperac,
          INPUT aux_dsoperac,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-craprot ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-craprot:HANDLE,
                             INPUT "Rotina").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE busca-operador-geral:

    RUN carrega-objeto.

    RUN busca-crapope IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_cdoperad,
          INPUT aux_cdagenci,
          INPUT aux_nmoperad,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-operador ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO: 
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-operador:HANDLE,
                             INPUT "Operador").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.

        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE busca-crapttl:
    

    RUN busca-crapttl IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_nrdconta,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
          
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapttl ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO: 
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapttl:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.

        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE busca-perfil:

    /*
    
     GABRIEL - RKAM - ESTAVA DANDO ERRO DE TABELA CRAPPFO NAO ENCONTRADA
    
    
    RUN carrega-objeto.
            
    RUN busca-crappfo IN h-b1wgen0059
        ( INPUT aux_cdcooper,
          INPUT aux_cdperfil,
          INPUT aux_dsperfil,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-perfil ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO: 
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-perfil:HANDLE,
                             INPUT "Perfil").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.

        END.

    RUN remove-objeto.
            */
END PROCEDURE.


PROCEDURE busca-produtos:
    
    RUN carrega-objeto.
    
    RUN busca-produtos IN h-b1wgen0059
        ( 
          INPUT aux_dsarnego,
          INPUT aux_dsprodut,
          INPUT aux_nrregist,
          INPUT aux_nriniseq,

         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-produtos ).
    
    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO: 
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-produtos:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.

        END.

    RUN remove-objeto.

END PROCEDURE.

PROCEDURE busca_associado:

    RUN busca-crapass IN hBO
                    ( INPUT aux_cdcooper, 
                      INPUT aux_inpessoa, 
                      INPUT aux_nrcpfcgc,
                      INPUT aux_nrdconta,                      
                      INPUT aux_nmprimtl,
                      INPUT aux_nrregist, 
                      INPUT aux_nriniseq,                       
                     OUTPUT aux_qtregist, 
                     OUTPUT TABLE tt-crapass ).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-crapass:HANDLE,
                               INPUT "Linhas").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
           
        END.

END.
/* .......................................................................... */
