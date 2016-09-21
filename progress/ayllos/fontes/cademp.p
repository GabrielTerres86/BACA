/* .............................................................................

   Programa: fontes/cademp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo/Julio
   Data    : Novembro/2004.                     Ultima atualizacao: 15/02/2016
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CADEMP - Cadastro de Empresas.

   Alteracoes: 10/11/2004 - Modificado para poder "voltar" os frames (usando
                            "END" ou "F4") na opcao "C" - Consulta (Evandro).
                            
               12/11/2004 - Retirado o campo "Dias de Carencias para 
                            emprestimo" (Evandro).

               10/12/2004 - Nao deixar passar se datas de pagamento horista,
                            mensalista e mes novo igual a zero. (Julio)
                            
               20/12/2004 - Incluisao de empresa, campo credito em folha
                            padrao FALSE (Julio)
              
               13/05/2005 - Alterado para posicionar a empresa no browse       
                            conforme a digitacao do codigo da empresa 
                            nas opcoes "A" e "C" (Diego).

               27/06/2005 - Alimentado campo cdcooper das tabelas craptab e    
                            crapemp (Diego).

               04/07/2005 - Permitir a impressao do relatorio por ordem 
                            alfabetica ou numerica (Edson).

               26/01/2006 - Unficacao dos Bancos - SQLWorks - Fernando

               06/04/2006 - Correcao nos FIND's que estavam utilizando
                            glb_cdcooper, utilizar {1}.crapcop.cdcooper (Julio)
                            
               06/09/2006 - Exluidas opcoes "TAB" (Diego).
                            
               12/12/2006 - Gerado automaticamente data do aviso de debito da
                            para empresa (Elton).
                      
               02/04/2007 - Efetuado acerto funcao obtencao nro empresa(Mirtes)
               
               26/07/2007 - Corrigido erro de "registro nao encontrado" na
                            inclusao (Evandro).
               
               17/12/2007 - Alterado para gerar "log/cademp_t.log" (Gabriel)
                          - Critica quando alterar geracao de avisos e ja 
                            houve um debito no mes(Guilherme).  
                            
               17/03/2009 - Ajustes para unificacao dos bancos de dados, foi
                            unido a este programa o fontes/cademp_t.p e foi
                            removida a opcao de escolha de cooperativa por
                            causa da unificacao gradativa (Evandro);
                          - Alteracao cdempres (Diego).
                          
               14/04/2009 - Incluir campo flgarqrt - Gera arq. retorno
                            (Fernando).            
                            
               04/06/2009 - Acerto na atualizacao das TAB'S NUMLOTEFOL,
                            NUMLOTECOT e NUMLOTEEMP (Diego).
                            
               14/07/2009 - Alteracao CDOPERAD (Diego).
               
               17/02/2010 - Incluindo novos campos no log (GATI - Daniel)
               
               02/02/2011 - InclusÒo do campo "Valida DV Cad.Emp." (FabrÝcio).
               
               16/04/2012 - Fonte substituido por cademp_p.p (Tiago). 
               
               26/08/2013 - Programa convertido para poder ser chamado pela WEB.
                            As regras de negócio foram retiradas e colocadas
                            todas na procedure b1wgen0166.p (Oliver - GATI).                                                         
               
               22/11/2013 - Programa alterado para atender padrão CECRED
                            (Andre - GATI).
                            
               25/03/2014 - SD 122814 Ajustes de padronizacao de cod. Correcao 
                            de parametros na procedure gera_arquivo_log. (Carlos)
                            
               28/03/2014 - Label tel_cdufdemp alterado para "UF" (Carlos)
               
               04/04/2014 - Validacao de cnpj e email (Carlos)
               
               14/07/2014 - Retirado o assign cdempres pois o mesmo eh criado ja
                            no momento da inclusao (Carlos)
                            
               11/08/2014 - Inclusão da opção de Pesquisa de Empresas (Vanessa)
               
               13/01/2015 - Passagem do parametro nrdocnpj na valida_empresa
                            Ref Doc3040 - Ente Consignante - Marcos(Supero)
                            
               21/01/2015 - Ajuste referente aos debitos de emprestimos que ocorriam 
                            mais de uma vez ao mes. 
                            Com a alteraçao atual, os indicadores inavsemp e inavscot
                            somente receberao zero se o crps080 ainda nao rodou no mes.
                            Foi verificado que essa tela, após qualquer alteraçao, colocava
                            o inavsemp e o inavscot para zero. Essa mudança fazia com que o 
                            crps080 fosse executado novamente pois a fontes/proces1.p criava 
                            nova crapsol. Alisson (AMcom)
                            
               17/06/2015 - Prj-158 - Alteracoes no Layout, inclusao de novos campos
                            na tela. (Andre Santos - SUPERO)
               
               03/08/2015 - Ajuste para retirar o caminho absoluto na chamada
                            dos fontes 
                            (Adriano - SD 314469).
                            
               28/09/2015 - Inclusão da mensagem "Favor selecionar uma conta de pessoa Jurídica!!"
                            quando crapass.inpessoa = 1 e mostrar o nome fantasia quando solicitado
                            a opção substituir e demais ajustes solicitados. PRJ158 (Vanessa) 
                            
               25/11/2015 - Ajustando a busca dos valores de tarifas dos
                            convenios. (Andre Santos - SUPERO)  

               15/02/2016 - Inclusao do parametro conta na chamada da
                            fn_valor_tarifa_folha. (Jaison/Marcos)

..............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0166tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_nmarqpdf  AS CHAR                                          NO-UNDO.
DEF VAR aux_lisconta  AS CHAR                                          NO-UNDO.
DEF VAR h-b1wgen0166  AS HANDLE                                        NO-UNDO.
DEF VAR h-b1wgen0153  AS HANDLE                                        NO-UNDO.

DEF VAR  tel_cddopcao AS CHAR    FORMAT "!"                            NO-UNDO.
DEF VAR  aux_nmdbanco AS CHAR                                          NO-UNDO.
DEF VAR  aux_tptran   AS CHAR                                          NO-UNDO.
DEF VAR  aux_confirma AS CHAR    FORMAT "!"                            NO-UNDO.
DEF VAR  aux_confirm2 AS LOGICAL FORMAT "COMPLEMENTAR/SUBSTITUIR"      NO-UNDO.
DEF VAR  aux_confirm3 AS LOGICAL FORMAT "ADESAO/CANCELAMENTO"          NO-UNDO.
DEF VAR  aux_feriad   AS LOGICAL                                       NO-UNDO.

DEF VAR  tel_cdempfol LIKE crapemp.cdempfol INIT 0                     NO-UNDO.
DEF VAR  tel_cdempres LIKE crapemp.cdempres                            NO-UNDO.
DEF VAR  tel_idtpempr AS LOGICAL FORMAT "Cooperativa/Outras"           NO-UNDO.

DEF VAR  tel_nrdconta AS INTE                                          NO-UNDO.
DEF VAR  tel_nmextttl AS CHAR                                          NO-UNDO.
DEF VAR  tel_nmcontat AS CHAR                                          NO-UNDO.

DEF VAR  tel_dtavscot LIKE crapemp.dtavscot                            NO-UNDO.
DEF VAR  tel_dtavsemp LIKE crapemp.dtavsemp                            NO-UNDO.
DEF VAR  tel_dtavsppr LIKE crapemp.dtavsppr                            NO-UNDO.

DEF VAR  tel_dtultufp LIKE crapemp.dtultufp                            NO-UNDO.

DEF VAR  aux_dtavscot LIKE crapemp.dtavscot                            NO-UNDO.
DEF VAR  aux_dtavsemp LIKE crapemp.dtavsemp                            NO-UNDO.
DEF VAR  aux_dtavsppr LIKE crapemp.dtavsppr                            NO-UNDO.

DEF VAR aux_contado2 AS INTE                                           NO-UNDO.
DEF VAR aux_vltarifa AS DECI                                           NO-UNDO.
DEF VAR aux_vltarif0 AS DECI                                           NO-UNDO.
DEF VAR aux_vltarif1 AS DECI                                           NO-UNDO.
DEF VAR aux_vltarif2 AS DECI                                           NO-UNDO.
DEF VAR aux_flagerro AS LOGICAL                                        NO-UNDO.

DEF VAR aux_cdhistor AS INTE                                     NO-UNDO.
DEF VAR aux_cdhisest AS INTE                                     NO-UNDO.
DEF VAR aux_dtdivulg AS DATE                                     NO-UNDO.
DEF VAR aux_dtvigenc AS DATE                                     NO-UNDO.
DEF VAR aux_cdfvlcop AS INTE                                     NO-UNDO.

DEF VAR  tel_flgpagto LIKE crapemp.flgpagto FORMAT "SIM/NAO" INIT NO   NO-UNDO.
DEF VAR  tel_flgarqrt LIKE crapemp.flgarqrt FORMAT "SIM/NAO"           NO-UNDO.

DEF VAR  tel_nmextemp LIKE crapemp.nmextemp                            NO-UNDO.
DEF VAR  tel_nmresemp LIKE crapemp.nmresemp                            NO-UNDO.
DEF VAR  tel_tpconven AS CHAR    FORMAT "x(20)"                        NO-UNDO.
DEF VAR  tel_tpdebcot AS CHAR    FORMAT "x(13)"                        NO-UNDO.
DEF VAR  tel_tpdebemp AS CHAR    FORMAT "x(13)"                        NO-UNDO.
DEF VAR  tel_tpdebppr AS CHAR    FORMAT "x(13)"                        NO-UNDO.
DEF VAR  tel_dsendemp LIKE crapemp.dsendemp                            NO-UNDO.
DEF VAR  tel_nrendemp LIKE crapemp.nrendemp                            NO-UNDO.
DEF VAR  tel_dscomple LIKE crapemp.dscomple                            NO-UNDO.
DEF VAR  tel_nmbairro LIKE crapemp.nmbairro FORMAT "x(15)"             NO-UNDO.
DEF VAR  tel_nmcidade LIKE crapemp.nmcidade                            NO-UNDO.
DEF VAR  tel_cdufdemp LIKE crapemp.cdufdemp                            NO-UNDO.
DEF VAR  tel_nrcepend LIKE crapemp.nrcepend                            NO-UNDO.
DEF VAR  tel_nrdocnpj LIKE crapemp.nrdocnpj                            NO-UNDO.
DEF VAR  tel_nrfonemp LIKE crapemp.nrfonemp                            NO-UNDO.
DEF VAR  tel_nrfaxemp LIKE crapemp.nrfaxemp                            NO-UNDO.
DEF VAR  tel_dsdemail LIKE crapemp.dsdemail                            NO-UNDO.
DEF VAR  tel_indescsg AS LOGICAL FORMAT  "SIM/NAO"                     NO-UNDO.
DEF VAR  tel_dtfchfol LIKE crapemp.dtfchfol                            NO-UNDO.

DEF VAR  tel_flgpgtib LIKE crapemp.flgpgtib FORMAT "SIM/NAO"           NO-UNDO.
DEF VAR  ant_flgpgtib LIKE crapemp.flgpgtib FORMAT "SIM/NAO"           NO-UNDO.
DEF VAR  tel_cdcontar LIKE crapemp.cdcontar FORMAT "zzzzzzzzz9"        NO-UNDO.
DEF VAR  tel_dscontar LIKE crapcfp.dscontar                            NO-UNDO.
DEF VAR  tel_vllimfol LIKE crapemp.vllimfol FORMAT "zzz,zzz,zz9.99"    NO-UNDO.

DEF VAR  aux_dstipdeb AS CHAR 
    INITIAL ",NAO DEBITA,5 DIAS ANTES,3 DIAS ANTES"                    NO-UNDO.
DEF VAR  aux_dstipcon AS CHAR 
    INITIAL ",3/5 DIAS UTEIS ANTES DO FIM DO MES,1.o. DIA UTIL DO MES" NO-UNDO.
DEF VAR  tel_vltrfsal  AS DECI   FORMAT "zzzzzzzz9.99"                 NO-UNDO.

DEF VAR  tel_ddmesnov AS INTE    FORMAT "99"    INIT 15                NO-UNDO. 
DEF VAR  tel_ddpgtmes AS INTE    FORMAT "99"    INIT 1                 NO-UNDO.
DEF VAR  tel_ddpgthor AS INTE    FORMAT "99"    INIT 1                 NO-UNDO.
DEF VAR  tel_nrlotemp AS INTE    FORMAT "999999"                       NO-UNDO.
DEF VAR  tel_nrlotcot AS INTE    FORMAT "999999"                       NO-UNDO.
DEF VAR  tel_nrlotfol AS INTE    FORMAT "999999"                       NO-UNDO. 
DEF VAR  aux_buscanum AS INTE    FORMAT "99999999"                     NO-UNDO.
DEF VAR  aux_temposeg AS INTE                                          NO-UNDO.

DEF VAR  tel_nmcooper LIKE crapcop.nmrescop                            NO-UNDO.
DEF VAR  tel_nmempres LIKE crapemp.nmresemp                            NO-UNDO.

DEF VAR tel_opnmprim AS CHAR  INIT  "Nome da Empresa"                  NO-UNDO.
DEF VAR tel_opnmraza AS CHAR  INIT  "Razão Social"                     NO-UNDO.
DEF VAR tel_nmprimtl AS CHAR  FORMAT "x(40)"                           NO-UNDO.
DEF VAR aux_cdpesqui AS INT   INIT 0                                   NO-UNDO.

DEF VAR aux_flgordem AS LOGICAL FORMAT "Codigo da Empresa/Nome da Empresa"
                                                                       NO-UNDO.

DEF VAR aux_nmendter    AS CHAR  FORMAT "x(20)"                        NO-UNDO.  
DEF VAR aux_flgescra    AS LOG                                         NO-UNDO.
DEF VAR aux_dscomand    AS CHAR                                        NO-UNDO.
DEF VAR aux_contador    AS INTE                                        NO-UNDO.
DEF VAR aux_tpimprim    AS LOGI  FORMAT "T/I"  INIT "T"                NO-UNDO.
DEF VAR par_flgfirst    AS LOG                                         NO-UNDO.
DEF VAR par_flgcance    AS LOG                                         NO-UNDO.
DEF VAR aux_nmarqimp    AS CHAR                                        NO-UNDO.
DEF VAR par_flgrodar    AS LOGICAL INIT TRUE                           NO-UNDO.
DEF VAR tel_dsimprim    AS CHAR  FORMAT "x(8)" INIT "Imprimir"         NO-UNDO.
DEF VAR tel_dscancel    AS CHAR  FORMAT "x(8)" INIT "Cancelar"         NO-UNDO.

DEF VAR  aux_qtdiasut AS INTE                                          NO-UNDO.
DEF VAR  aux_dtavisos AS DATE                                          NO-UNDO.
DEF VAR  aux_dtavs001 AS DATE                                          NO-UNDO.
DEF VAR tel_flgvlddv  AS LOGICAL FORMAT "SIM/NAO"                      NO-UNDO.

DEF VAR aux_cdcritic  AS INT                                           NO-UNDO.
DEF VAR aux_dscritic  AS CHAR                                          NO-UNDO.

/* variaveis para verificar se os campos foram alterados */
DEF VAR  log_indescsg AS LOGIC                                         NO-UNDO.
DEF VAR  log_dtfchfol AS INTE                                          NO-UNDO.
DEF VAR  log_flgpagto AS LOGIC                                         NO-UNDO.
DEF VAR  log_flgarqrt AS LOGIC                                         NO-UNDO.
DEF VAR  log_cdempfol AS INTE                                          NO-UNDO.
DEF VAR  log_tpconven AS CHAR                                          NO-UNDO.
DEF VAR  log_tpdebemp AS CHAR                                          NO-UNDO.
DEF VAR  log_tpdebcot AS CHAR                                          NO-UNDO.
DEF VAR  log_tpdebppr AS CHAR                                          NO-UNDO.
DEF VAR  log_cdempres LIKE tel_cdempres                                NO-UNDO.
DEF VAR  log_idtpempr LIKE tel_idtpempr                                NO-UNDO.
DEF VAR  log_nrdconta LIKE tel_nrdconta                                NO-UNDO.
DEF VAR  log_dtultufp LIKE tel_dtultufp                                NO-UNDO.
DEF VAR  log_flgpgtib LIKE tel_flgpgtib                                NO-UNDO.
DEF VAR  log_cdcontar LIKE tel_cdcontar                                NO-UNDO.
DEF VAR  log_vllimfol LIKE tel_vllimfol                                NO-UNDO.
DEF VAR  log_nmcontat LIKE tel_nmcontat                                NO-UNDO.
DEF VAR  log_dtavscot LIKE tel_dtavscot                                NO-UNDO.
DEF VAR  log_dtavsemp LIKE tel_dtavsemp                                NO-UNDO.
DEF VAR  log_dtavsppr LIKE tel_dtavsppr                                NO-UNDO.
DEF VAR  log_nmextemp LIKE tel_nmextemp                                NO-UNDO.
DEF VAR  log_nmresemp LIKE tel_nmresemp                                NO-UNDO.
DEF VAR  log_cdufdemp LIKE tel_cdufdemp                                NO-UNDO.
DEF VAR  log_dscomple LIKE tel_dscomple                                NO-UNDO.
DEF VAR  log_dsdemail LIKE tel_dsdemail                                NO-UNDO.
DEF VAR  log_dsendemp LIKE tel_dsendemp                                NO-UNDO.
DEF VAR  log_nmbairro LIKE tel_nmbairro                                NO-UNDO.
DEF VAR  log_nmcidade LIKE tel_nmcidade                                NO-UNDO.
DEF VAR  log_nrcepend LIKE tel_nrcepend                                NO-UNDO.
DEF VAR  log_nrdocnpj LIKE tel_nrdocnpj                                NO-UNDO.
DEF VAR  log_nrendemp LIKE tel_nrendemp                                NO-UNDO.
DEF VAR  log_nrfaxemp LIKE tel_nrfaxemp                                NO-UNDO.
DEF VAR  log_nrfonemp LIKE tel_nrfonemp                                NO-UNDO.
DEF VAR  log_flgvlddv LIKE tel_flgvlddv                                NO-UNDO.

/* variaveis para gerar log */
DEF VAR  aux_verifi01 AS CHAR                                          NO-UNDO.
DEF VAR  aux_verifi02 AS CHAR                                          NO-UNDO.
DEF VAR  aux_verifi03 AS CHAR                                          NO-UNDO.

DEF VAR  aux_cdmsgerr AS CHAR                                          NO-UNDO.

DEF VAR  aux_inavscot LIKE crapemp.inavscot                            NO-UNDO.
DEF VAR  aux_inavsemp LIKE crapemp.inavsemp                            NO-UNDO.
DEF VAR  aux_inavsppr LIKE crapemp.inavsppr                            NO-UNDO.
DEF VAR  aux_inavsden LIKE crapemp.inavsden                            NO-UNDO.
DEF VAR  aux_inavsseg LIKE crapemp.inavsseg                            NO-UNDO.
DEF VAR  aux_inavssau LIKE crapemp.inavssau                            NO-UNDO.
DEF VAR  aux_cdempres LIKE crapemp.cdempres                            NO-UNDO.
DEF VAR  aux_idtpempr LIKE crapemp.idtpempr                            NO-UNDO.
DEF VAR  aux_nrdconta LIKE crapemp.nrdconta                            NO-UNDO.
DEF VAR  aux_dtultufp LIKE crapemp.dtultufp                            NO-UNDO.
DEF VAR  aux_flgpgtib LIKE crapemp.flgpgtib                            NO-UNDO.
DEF VAR  aux_cdcontar LIKE crapemp.cdcontar                            NO-UNDO.
DEF VAR  aux_vllimfol LIKE crapemp.vllimfol                            NO-UNDO.
def VAR  aux_flgdgfib LIKE crapemp.flgdgfib                            NO-UNDO.
DEF VAR  aux_nmcontat LIKE crapemp.nmcontat                            NO-UNDO.
DEF VAR  aux_nmresemp LIKE crapemp.nmresemp                            NO-UNDO.
DEF VAR  aux_nmextemp LIKE crapemp.nmextemp                            NO-UNDO.
DEF VAR  aux_tpdebemp LIKE crapemp.tpdebemp                            NO-UNDO.
DEF VAR  aux_tpdebcot LIKE crapemp.tpdebcot                            NO-UNDO.
DEF VAR  aux_tpdebppr LIKE crapemp.tpdebppr                            NO-UNDO.
DEF VAR  aux_cdempfol LIKE crapemp.cdempfol                            NO-UNDO.
DEF VAR  aux_flgpagto LIKE crapemp.flgpagto                            NO-UNDO.
DEF VAR  aux_tpconven LIKE crapemp.tpconven                            NO-UNDO.
DEF VAR  aux_cdufdemp LIKE crapemp.cdufdemp                            NO-UNDO.
DEF VAR  aux_dscomple LIKE crapemp.dscomple                            NO-UNDO.
DEF VAR  aux_dsdemail LIKE crapemp.dsdemail                            NO-UNDO.
DEF VAR  aux_dsendemp LIKE crapemp.dsendemp                            NO-UNDO.
DEF VAR  aux_dtfchfol LIKE crapemp.dtfchfol                            NO-UNDO.
DEF VAR  aux_indescsg LIKE crapemp.indescsg                            NO-UNDO.
DEF VAR  aux_nmbairro LIKE crapemp.nmbairro                            NO-UNDO.
DEF VAR  aux_nmcidade LIKE crapemp.nmcidade                            NO-UNDO.
DEF VAR  aux_nrcepend LIKE crapemp.nrcepend                            NO-UNDO.
DEF VAR  aux_nrdocnpj LIKE crapemp.nrdocnpj                            NO-UNDO.
DEF VAR  aux_nrendemp LIKE crapemp.nrendemp                            NO-UNDO.
DEF VAR  aux_nrfaxemp LIKE crapemp.nrfaxemp                            NO-UNDO.
DEF VAR  aux_nrfonemp LIKE crapemp.nrfonemp                            NO-UNDO.
DEF VAR  aux_flgarqrt LIKE crapemp.flgarqrt                            NO-UNDO.
DEF VAR  aux_flgvlddv LIKE crapemp.flgvlddv                            NO-UNDO.

DEF VAR aux_nmarquiv  AS CHAR                                          NO-UNDO.
DEF VAR aux_liscontas AS CHAR                                          NO-UNDO.

DEF VAR aux_ponteiro  AS INTE                                          NO-UNDO.
DEF VAR aux_stsnrcal  AS LOGICAL                                       NO-UNDO.
DEF VAR h-b1wgen9999  AS HANDLE                                        NO-UNDO.

DEF QUERY q_empres FOR tt-crapemp.

DEF BROWSE br_empres QUERY q_empres 
                     DISPLAY tt-crapemp.cdempres LABEL "Codigo"  FORMAT "zzz9" 
                             tt-crapemp.nmresemp LABEL "Empresa"
                             tt-crapemp.nmextemp LABEL "Razao Social"
                     WITH 7 DOWN NO-LABEL TITLE "Escolha a Empresa:".
 
DEF QUERY q_procuradores FOR tt-procuradores-emp.

DEF BROWSE b_procuradores QUERY q_procuradores
    DISPLAY tt-procuradores-emp.idctasel COLUMN-LABEL ""         FORMAT "S/N"
            tt-procuradores-emp.nrdctato COLUMN-LABEL "Conta/dv"                        
            tt-procuradores-emp.nmprimtl COLUMN-LABEL "Nome"     FORMAT "x(24)"         
            tt-procuradores-emp.nrcpfcgc COLUMN-LABEL "C.P.F."   FORMAT "999,999,999,99"
            tt-procuradores-emp.dtvalida COLUMN-LABEL "Vigencia" FORMAT "99/99/9999"    
            tt-procuradores-emp.dsproftl COLUMN-LABEL "Cargo"    FORMAT "x(10)"
            ENABLE tt-procuradores-emp.idctasel AUTO-RETURN                             
                   HELP "Selecione as contas. Use <F4> para continuar."
            WITH 7 DOWN NO-BOX.

FORM SKIP(12)
     WITH ROW 8 WIDTH 80 OVERLAY SIDE-LABELS 
          TITLE " REPRESENTANTE/PROCURADOR " FRAME f_regua.

FORM b_procuradores
     WITH ROW 10 COLUMN 2 OVERLAY NO-BOX FRAME f_browse.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_cddopcao  LABEL "Opcao" AUTO-RETURN 
                   HELP "Entre com a opcao desejada (A, C, I, R ou T)" 
                   VALIDATE (tel_cddopcao = "A" OR tel_cddopcao = "C" OR   
                             tel_cddopcao = "I" OR tel_cddopcao = "R" OR
                             tel_cddopcao = "T","014 - Opcao errada.") 
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

DEF FRAME f_busca 
    tel_nmcooper AT 10     LABEL "Cooperativa"
    tel_nmempres           LABEL "Empresa"
    WITH NO-LABEL NO-BOX CENTERED ROW 6 COLUMN 20 SIDE-LABELS OVERLAY.

FORM br_empres 
     AT  5 HELP "Utilize as setas p/ navegar ou <F7> para pesquisar"
     WITH OVERLAY COLUMN 5 ROW 9 NO-BOX FRAME f_consemp.

/* Primeiro Frame */

FORM SKIP
     tel_cdempres  AT 02 FORMAT "zzz9"   LABEL "Codigo"
     tel_idtpempr  AT 30 LABEL "Tipo Empresa"
     HELP 'Informe (O)utras ou (C)ooperativa (Exclusivo Filiadas CECRED)'
     SKIP
     tel_nmextemp  AT 02 FORMAT "x(35)"  LABEL "Razao Social"
     HELP 'Informe a Razao Social da Empresa.'    
     SKIP     
     tel_nmresemp  AT 02 FORMAT "x(15)"  LABEL "Nome Fantasia"
     SKIP(1)
     tel_nrdconta  AT 02 FORMAT "zzzz,zzz,9" LABEL "Conta Debito"
     HELP 'Informe Nr Conta Debito ou <F7> para buscar os associados'    
     "-" 
     tel_nmextttl  AT 30 FORMAT "x(40)" NO-LABEL
     SKIP(1)
     tel_nmcontat  AT 02 FORMAT "x(50)" LABEL "Contato"
     HELP "Informe o nome do contato!"
     VALIDATE (tel_nmcontat <> "","Campo  nome do contato Obrigatorio!")
     SKIP
     tel_nrdocnpj  AT 02 FORMAT "99,999,999,9999,99" LABEL "CNPJ"
     HELP "Informe o CNPJ!"
     VALIDATE (tel_nrdocnpj <> 0,"Campo CNPJ Obrigatorio!")
     tel_dsendemp  AT 02 FORMAT "x(40)"  LABEL "Endereco"
     tel_nrendemp  AT 62 FORMAT "zz,zzz" LABEL "Numero"
     SKIP
     tel_dscomple  AT 02 FORMAT "x(50)"  LABEL "Complemento"
     SKIP
     tel_nmbairro  AT 02 FORMAT "x(15)"  LABEL "Bairro"
     tel_nmcidade  AT 40 FORMAT "x(25)"  LABEL "Cidade" 
     SKIP
     tel_cdufdemp  AT 02                     LABEL "UF"
     tel_nrcepend  AT 17 FORMAT "99,999,999" LABEL "CEP"
     SKIP
     tel_nrfonemp  AT 02 FORMAT "x(15)"  LABEL "Fone"
     HELP "Informe o telefone para contato!"
     VALIDATE (tel_nrfonemp <> "","Campo telefone Obrigatorio!") 
     /*VALIDATE (TRIM(tel_nmextemp) <> "","Campo Razao Social da Empresa Obrigatorio!")*/
     tel_nrfaxemp  AT 40 FORMAT "x(15)"  LABEL "Fax"
     SKIP
     tel_dsdemail  AT 02 FORMAT "x(60)"  LABEL "e-mail"
     HELP "Informe e-mail para contato!"
     VALIDATE (tel_dsdemail <> "","Campo e-mail Obrigatorio!")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY 8 DOWN TITLE "Dados da Empresa"
     WIDTH 78 FRAME f_cademp_1.

/* Segundo Frame */

FORM SKIP(1)
     tel_flgpagto  AT 02                 LABEL "Integra Folha"
     SKIP(1)
     tel_cdempfol  AT 02 FORMAT "zzz9"   LABEL "Codigo da Empresa Sistema Folha"
     SKIP
     tel_vltrfsal  AT 02 LABEL "Tarifa para Credito de Salarios"
     SKIP
     tel_dtfchfol  AT 02 FORMAT "99"     LABEL "Dia Fechamento Folha"
     SKIP(1)
     tel_ddpgtmes  AT 02 LABEL "Dia do Pagamento de Mensalista "
                   VALIDATE(tel_ddpgtmes > 0 AND tel_ddpgtmes <= 28,
                            "520 - Dia Incorreto")
     SKIP
     tel_ddpgthor  AT 02 LABEL "Dia do Pagamento de Horista    "
                   VALIDATE(tel_ddpgthor > 0 AND tel_ddpgthor <= 28,
                            "520 - Dia Incorreto")
     WITH ROW 6 COLUMN 2 WIDTH 78 SIDE-LABELS OVERLAY 8 DOWN TITLE "Folha E-mail"
     FRAME f_cademp_3.

/* Terceiro Frame */

FORM SKIP(1)
     tel_flgpgtib  AT 02                           LABEL "Liberacao Folha IB?"
     SKIP(1)
     tel_cdcontar  AT 02                           LABEL "Convenio Tarifario"
     VALIDATE (INPUT tel_cdcontar <> 0,aux_cdmsgerr)
     "-"
     tel_dscontar  AT 35 FORMAT "x(40)" NO-LABEL
     tel_vllimfol  AT 02 FORMAT "zzz,zzz,zz9.99"   LABEL "Valor Limite Diario"
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY 8 DOWN TITLE "Folha Internet Banking"
     WIDTH 78 FRAME f_cademp_2.

/* Quarto Frame */

FORM SKIP(1)
     tel_indescsg  AT 02                 LABEL "Emprestimo Consignado"
     HELP "Habilitar a empresa para consignacao de emprestimo (S ou N)" 
     tel_flgarqrt  AT 02                 LABEL "Gera arq. retorno"
     SKIP
     tel_flgvlddv  AT 02                 LABEL "Valida DV Cad.Emp."
     SKIP(1)
     tel_ddmesnov  AT 02 LABEL "Dia Mes Novo para Emprestimo   "
     VALIDATE(tel_ddmesnov > 0 AND tel_ddmesnov <= 28,"520 - Dia Incorreto") 
     SKIP
     tel_tpconven  AT 02 FORMAT "x(34)"  LABEL "Impressao do Aviso"
     SKIP(1)
     tel_nrlotcot  AT 02 LABEL "Lote Cotas"       FORMAT "zz9999"
     tel_nrlotemp  AT 25 LABEL "Lote Emprestimo"  FORMAT "zz9999"
     tel_nrlotfol  AT 55 LABEL "Lote Folha"       FORMAT "zz9999"
     SKIP(1)
     tel_tpdebemp  AT 02                 LABEL "Gera Aviso Emprestimo"
     HELP "Gerar aviso de debito de emprestimos"
     tel_dtavsemp  AT 43 FORMAT "99/99/9999" LABEL "Data Aviso "
     SKIP
     tel_tpdebcot  AT 02                 LABEL "Gera Aviso Cotas     "
     HELP "Gerar aviso de debito de cotas"
     tel_dtavscot  AT 43 FORMAT "99/99/9999" LABEL "Data Aviso "
     SKIP
     tel_tpdebppr  AT 02                 LABEL "Gera Aviso Poup.Prog."
     HELP "Gerar aviso de debito de poupanca programada"
     tel_dtavsppr  AT 43 FORMAT "99/99/9999" LABEL "Data Aviso "
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY 8 DOWN TITLE "Informacoes Complementares"
     WIDTH 78 FRAME f_cademp_4.

FORM SKIP(1)
        
     tel_opnmprim  NO-LABEL AT 7 FORMAT "x(15)"
                  HELP "Pesquisar por nome da Empresa."
     
     SPACE(4)
     tel_opnmraza NO-LABEL       FORMAT "x(16)"
                  HELP "Pesquisar por Razão Social da Empresa."
      
   SKIP(1)
     tel_nmprimtl LABEL "Nome a pesquisar"
                  HELP "Informe o nome ou parte dele para efetuar a pesquisa."
      
     SKIP(1)
     WITH ROW 8 CENTERED SIDE-LABELS 
          TITLE COLOR NORMAL " Pesquisa de Empresas " OVERLAY
          FRAME f_pesquisa.


/******* FUNCOES ************/
FUNCTION LogicToInt RETURNS INTEGER(INPUT par_converte AS LOGICAL):

    IF  par_converte   THEN
        RETURN 1.
    ELSE
        RETURN 0.

END.
/********/

/******* TRIGGER *********/

ON ANY-KEY OF br_empres IN FRAME f_consemp DO:

    IF  CAN-DO("0,1,2,3,4,5,6,7,8,9",KEYFUNCTION(LASTKEY))   THEN DO: 
        
        IF  aux_temposeg  >=  TIME   THEN 
            aux_buscanum  = INTEGER(STRING(aux_buscanum) + 
                            KEYFUNCTION(LASTKEY)).
        ELSE
            aux_buscanum = INTEGER(KEYFUNCTION(LASTKEY)).
             
        aux_temposeg = TIME.
              
        /**Utilizado para nao estourar valor**/
        IF  aux_buscanum > 99999999   THEN
            aux_buscanum = 0.
    
            IF  CAN-FIND (tt-crapemp
                   WHERE  tt-crapemp.cdcooper = glb_cdcooper  AND
                          tt-crapemp.cdempres = aux_buscanum) THEN 
            
                 FIND tt-crapemp
                WHERE tt-crapemp.cdcooper = glb_cdcooper
                  AND tt-crapemp.cdempres = aux_buscanum
                  NO-LOCK.

            ELSE
                NEXT.
    
        REPOSITION q_empres TO ROWID ROWID(tt-crapemp). 
            
    END.

END.

ON f7 OF br_empres IN FRAME f_consemp DO:  

    ASSIGN tel_nmprimtl = "".

    DISPLAY tel_opnmprim tel_opnmraza tel_nmprimtl
            WITH FRAME f_pesquisa.

    CHOOSE FIELD tel_opnmprim tel_opnmraza tel_nmprimtl
                  WITH FRAME f_pesquisa.

    IF  FRAME-VALUE = tel_opnmprim   THEN
        ASSIGN aux_cdpesqui = 1.
    ELSE
    IF  FRAME-VALUE = tel_opnmraza   THEN
        ASSIGN aux_cdpesqui = 0.

    UPDATE tel_nmprimtl
           WITH FRAME f_pesquisa.        

    RUN Busca_empresas IN h-b1wgen0166
                      (INPUT glb_cdcooper,
                       INPUT glb_cdagenci,
                       INPUT 0 /*nrdcaixa*/,
                       INPUT glb_cdoperad,
                       INPUT glb_dtmvtolt,
                       INPUT 1 /*idorigem*/,
                       INPUT glb_nmdatela,
                       INPUT glb_cdprogra,
                       INPUT tel_nmprimtl,
                       INPUT aux_cdpesqui,
                       INPUT -1,
                       OUTPUT TABLE tt-crapemp,
                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"   THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  AVAIL tt-erro   THEN
            MESSAGE tt-erro.dscritic.
        ELSE
            MESSAGE "Erro na busca de empresa.AAAAAA".

        PAUSE.

        RETURN "NOK".
    END.

    OPEN QUERY q_empres FOR EACH tt-crapemp.

    VIEW FRAME f_consemp.
    ENABLE br_empres
           WITH FRAME f_consemp.
    WAIT-FOR ENDKEY OF br_empres.

    CLOSE QUERY q_empres.

    HIDE FRAME f_consemp.

    VIEW FRAME f_moldura.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        PAUSE 
        MESSAGE "Tecle algo para continuar... / F4 para voltar".
        LEAVE.
    END.

END.


ON RETURN OF br_empres DO:

    DEF VAR aux_flgfinal AS LOGICAL INIT NO                  NO-UNDO.
   
    ASSIGN  tel_nmempres = tt-crapemp.nmresemp.
    
    DISPLAY tel_nmempres
            WITH FRAME f_busca.

    PAUSE(0).
   
    IF  glb_cddopcao = "C"   THEN DO:

        RUN p_consulta.
                 
        /* Exibe o Primeiro Frame */
        DO  WHILE TRUE:

            DISPLAY tel_idtpempr tel_nmextemp tel_nmresemp
                    tel_cdempres tel_dsendemp tel_nrendemp
                    tel_nrdconta tel_nmextttl tel_nmcontat
                    tel_dscomple tel_nmbairro tel_nmcidade
                    tel_cdufdemp tel_nrcepend tel_nrdocnpj
                    tel_nrfonemp tel_nrfaxemp tel_dsdemail
                    WITH FRAME f_cademp_1.
                 
            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                PAUSE MESSAGE "Tecle algo para continuar... / F4 para voltar".
                LEAVE.
            END.
            
            /* Fecha todos os frames que estao abertos */
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN DO:
                 HIDE FRAME f_cademp_1
                      FRAME f_cademp_3
                      FRAME f_cademp_2
                      FRAME f_cademp_4.

                /* Finaliza a consulta */
                LEAVE.
            END.

            /* Exibe o Segundo Frame */
            DO  WHILE TRUE:

                DISPLAY tel_flgpagto tel_cdempfol tel_vltrfsal
                        tel_dtfchfol tel_ddpgtmes tel_ddpgthor
                        WITH FRAME f_cademp_3.
           
                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    PAUSE 
                    MESSAGE "Tecle algo para continuar... / F4 para voltar".
                    LEAVE.
                END.
                
                /* Fecha o frame */
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN DO:
                    HIDE FRAME f_cademp_3.
                    aux_flgfinal = NO.
                    LEAVE.
                END.

                /* Exibe o Terceiro Frame */
                DO  WHILE TRUE:

                    /* Exibe o Terceiro Frame */
                    IF  tt-crapemp.tpdebemp = 0 THEN 
                        ASSIGN tel_tpdebemp = "NAO DEBITA"
                               tel_dtavsemp = ?.
                    
                    IF  tt-crapemp.tpdebcot = 0 THEN 
                        ASSIGN  tel_tpdebcot = "NAO DEBITA"
                                tel_dtavscot = ?.
                    
                    IF  tt-crapemp.tpdebppr = 0 THEN 
                        ASSIGN  tel_tpdebppr = "NAO DEBITA"
                                tel_dtavsppr = ?.
                    
                    DISPLAY tel_flgpgtib
                            tel_cdcontar
                            tel_dscontar
                            tel_vllimfol
                            WITH FRAME f_cademp_2.
                   
                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        PAUSE
                        MESSAGE "Tecle algo para continuar... / F4 para voltar".
                        LEAVE.
                    END.
                   
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN DO:
                        HIDE FRAME f_cademp_2.
                        aux_flgfinal = NO.
                        LEAVE.
                    END.

                    /* Exibe o Quarto Frame */
                    DISPLAY tel_indescsg tel_flgarqrt tel_flgvlddv
                            tel_ddmesnov tel_tpconven tel_nrlotcot
                            tel_nrlotemp tel_nrlotfol tel_tpdebemp
                            tel_dtavsemp tel_tpdebcot tel_dtavscot
                            tel_tpdebppr tel_dtavsppr
                            WITH FRAME f_cademp_4.
                   
                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        PAUSE
                        MESSAGE "Tecle algo para continuar... / F4 para voltar".
                        LEAVE.
                    END.
                   
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN DO:
                        HIDE FRAME f_cademp_4.
                        NEXT.
                    END.

                    aux_flgfinal = YES.
                    LEAVE.

                END. /* Fim DO WHILE TRUE */

                IF  aux_flgfinal   THEN
                    LEAVE.
                ELSE
                    NEXT.

            END.

            HIDE FRAME f_cademp_1
                 FRAME f_cademp_3
                 FRAME f_cademp_2
                 FRAME f_cademp_4.
            
            IF  aux_flgfinal   THEN
                LEAVE.
            ELSE
                NEXT.          

        END. /* Fim DO WHILE TRUE */
    END.
    ELSE
    IF  glb_cddopcao = "A"   THEN DO:
        RUN p_altera_inclui.

        RUN Busca_empresas IN h-b1wgen0166
                          (INPUT glb_cdcooper,
                           INPUT glb_cdagenci,
                           INPUT 0 /*nrdcaixa*/,
                           INPUT glb_cdoperad,
                           INPUT glb_dtmvtolt,
                           INPUT 1 /*idorigem*/,
                           INPUT glb_nmdatela,
                           INPUT glb_cdprogra,
                           INPUT tel_nmprimtl,
                           INPUT aux_cdpesqui,
                           INPUT -1,
                           OUTPUT TABLE tt-crapemp,
                           OUTPUT TABLE tt-erro).
        
        IF  RETURN-VALUE <> "OK"   THEN DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAIL tt-erro   THEN
                MESSAGE tt-erro.dscritic.
            ELSE
                MESSAGE "Erro na busca de empresa.BBBBB".
               
            PAUSE.
                  
            RETURN "NOK".
        END.

        OPEN QUERY q_empres FOR EACH tt-crapemp.

    END.
    ELSE
    IF  glb_cddopcao = "T" THEN DO:

        RUN p_consulta.

        OPEN QUERY q_empres FOR EACH tt-crapemp.

        RUN p_impressao_termo.

        HIDE  FRAME f_browse
              FRAME f_regua.

    END.
END.

ON  RETURN OF tel_nrdconta IN FRAME f_cademp_1 DO:

    ASSIGN aux_cdmsgerr = "".

    IF  INPUT tel_nrdconta = 0 AND ant_flgpgtib THEN DO:     
        aux_cdmsgerr = "Campo Conta Debito da Empresa deve ser Informado!".
        NEXT.
    END.
    
    IF  INPUT tel_nrdconta > 0 THEN DO:
    
        FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                             AND crapass.nrdconta = INPUT tel_nrdconta
                             AND crapass.dtdemiss = ?
                             NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL crapass THEN DO:
            ASSIGN tel_nrdconta = 0
                   tel_nmextttl = ""
                   aux_cdmsgerr = "Conta inexistente ou Demitida da cooperativa!".
    
            DISPLAY tel_nrdconta  
                    tel_nmextttl   
                    WITH FRAME f_cademp_1.
        
            NEXT.
        END.
        ELSE
        DO:
            IF  crapass.inpessoa = 1  THEN 
            DO:
                ASSIGN tel_nrdconta = 0
                   tel_nmextttl = ""
                   aux_cdmsgerr = "Favor selecionar uma conta de pessoa Jurídica!".
    
                DISPLAY tel_nrdconta  
                        tel_nmextttl   
                        WITH FRAME f_cademp_1.
                NEXT.
           END.
        END.
       
        
        IF  glb_cddopcao = "A" THEN DO:
        
            IF  tt-crapemp.nrdconta <> INPUT tel_nrdconta THEN DO:
        
                FIND FIRST crapemp WHERE crapemp.cdcooper = crapass.cdcooper
                                     AND crapemp.nrdconta = crapass.nrdconta
                                     NO-LOCK NO-ERROR.
        
                IF  AVAIL crapemp THEN DO:
                    ASSIGN tel_nrdconta = 0
                           tel_nmextttl = ""
                           aux_cdmsgerr = "Conta informada ja utilizada por outra empresa: " +
                                          STRING(crapemp.cdempres,"999") + " - " + crapemp.nmresemp.
        
                    DISPLAY tel_nrdconta  
                            tel_nmextttl
                            WITH FRAME f_cademp_1.
        
                    NEXT.
                END.
            END.
        END.
        ELSE DO:
            FIND FIRST crapemp WHERE crapemp.cdcooper = crapass.cdcooper
                                 AND crapemp.nrdconta = crapass.nrdconta
                                 NO-LOCK NO-ERROR.
        
            IF  AVAIL crapemp THEN DO:
                ASSIGN tel_nrdconta = 0
                       tel_nmextttl = ""
                       aux_cdmsgerr = "Conta informada ja utilizada por outra empresa: " +
                                      STRING(crapemp.cdempres,"999") + " - " + crapemp.nmresemp.
        
                DISPLAY tel_nrdconta  
                        tel_nmextttl
                        WITH FRAME f_cademp_1.
        
                NEXT.
            END.
        END.
        
        ASSIGN tel_nrdconta = crapass.nrdconta
               tel_nmextttl = crapass.nmprimtl.
        
        DISPLAY crapass.nrdconta @ tel_nrdconta  
                crapass.nmprimtl @ tel_nmextttl   
                WITH FRAME f_cademp_1.

    END.

    APPLY "GO".

END.

ON  RETURN OF tel_cdcontar IN FRAME f_cademp_2 DO:

    FIND FIRST crapcfp WHERE crapcfp.cdcooper = glb_cdcooper
                         AND crapcfp.cdcontar = INPUT tel_cdcontar
                         NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcfp THEN DO:
        ASSIGN tel_cdcontar = 0
               tel_dscontar = ""
               aux_cdmsgerr = "Codigo convenio tarifario nao encontrado!".

        DISPLAY tel_cdcontar  
                tel_dscontar   
                WITH FRAME f_cademp_2.

        NEXT.
    END.

    aux_flagerro = FALSE.

    DO  aux_contador = 0 TO 2:
            
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /*** Faz a busca do historico da transação ***/
        RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
                         aux_ponteiro = PROC-HANDLE
           
        ("SELECT folh0001.fn_valor_tarifa_folha(" + STRING(crapcfp.cdcooper) + ","
                                                  + "0," /* Conta */
                                                  + STRING(crapcfp.cdcontar) + ","
                                                  + STRING(aux_contador) + ","
                                                  + STRING(0) + ") FROM dual").
        
        FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
            ASSIGN aux_vltarifa = DECI(proc-text).
        END.
        
        CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
              WHERE PROC-HANDLE = aux_ponteiro.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        IF  aux_vltarifa = -1 THEN /* Nao pode haver tarifa menor que ZERO */
            ASSIGN aux_flagerro = TRUE.

        CASE aux_contador:
            WHEN 0 THEN
                ASSIGN aux_vltarif0 = aux_vltarifa.
            WHEN 1 THEN
                ASSIGN aux_vltarif1 = aux_vltarifa.
            WHEN 2 THEN
                ASSIGN aux_vltarif2 = aux_vltarifa.
        END CASE.
    END.

    IF  aux_flagerro THEN DO:
        ASSIGN tel_cdcontar = 0
               tel_dscontar = ""
               aux_cdmsgerr = "Convenio tarifario incompleto! " +
                              "Favor efetuar cadastramento das tarifas na CADTAR.".

        DISPLAY tel_cdcontar  
                tel_dscontar   
                WITH FRAME f_cademp_2.

        NEXT.
    END.

    ASSIGN tel_cdcontar = crapcfp.cdcontar
           tel_dscontar = crapcfp.dscontar.

    DISPLAY crapcfp.cdcontar @ tel_cdcontar  
            crapcfp.dscontar @ tel_dscontar   
            WITH FRAME f_cademp_2.

    APPLY "GO".

END.

ON  LEAVE OF tel_tpdebemp IN FRAME f_cademp_4 DO:

    IF  aux_contador = 3 OR aux_contador = 4 THEN DO:
        IF  aux_contador = 3 THEN
            tel_dtavsemp = aux_dtavisos.
        ELSE
            tel_dtavsemp = aux_dtavs001.
        END.
    ELSE 
        tel_dtavsemp = ?.
    
    DISPLAY tel_dtavsemp
            WITH FRAME f_cademp_4.

END.

ON  LEAVE OF tel_tpdebcot IN FRAME f_cademp_4 DO:

    IF  aux_contador = 3 OR aux_contador = 4 THEN DO:
        IF  aux_contador = 3 THEN
            tel_dtavscot = aux_dtavisos.
        ELSE
            tel_dtavscot = aux_dtavs001.
        END.
    ELSE 
        tel_dtavscot = ?.
    
    DISPLAY tel_dtavscot
            WITH FRAME f_cademp_4.

END.

ON  LEAVE OF tel_tpdebppr IN FRAME f_cademp_4 DO:

    IF  aux_contador = 3 OR aux_contador = 4 THEN DO:
        IF  aux_contador = 3 THEN
            tel_dtavsppr = aux_dtavisos.
        ELSE
            tel_dtavsppr = aux_dtavs001.
        END.
    ELSE 
        tel_dtavsppr = ?.

    DISPLAY tel_dtavsppr
            WITH FRAME f_cademp_4.

END.

VIEW FRAME f_moldura.
PAUSE(0).

ASSIGN glb_cdcritic = 0
       glb_cdprogra = "CADEMP" 
       glb_nmrotina = "".

DO  WHILE TRUE:

    ASSIGN tel_cddopcao = "C"
           aux_dtavisos = ?
           tel_nmprimtl = "".
          
    CLEAR FRAME f_opcao.
   
    RUN fontes/inicia.p.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE: 

        IF  NOT VALID-HANDLE(h-b1wgen0166) THEN
            RUN sistema/generico/procedures/b1wgen0166.p 
            PERSISTENT SET h-b1wgen0166.

        VIEW FRAME f_moldura.
        PAUSE(0).
        UPDATE tel_cddopcao WITH FRAME f_opcao.
        LEAVE.
    END.
      
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN DO: /*   F4 OU FIM   */
        
        RUN fontes/novatela.p.
        IF  CAPS(glb_nmdatela) <> "CADEMP" THEN DO:
            IF  VALID-HANDLE(h-b1wgen0166) THEN
                DELETE OBJECT h-b1wgen0166.

            HIDE FRAME f_opcao.
            HIDE FRAME f_moldura.
            RETURN.
        END.
        ELSE
            NEXT.
    END.

    glb_cddopcao = tel_cddopcao.
  
    { includes/acesso.i }
   
    IF  glb_cddopcao = "R"   THEN DO:
        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

            aux_confirma = "N".
            MESSAGE COLOR NORMAL "DESEJA IMPRIMIR A RELACAO DE EMPRESAS ?" 
            UPDATE aux_confirma.
            LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */
            
        IF  aux_confirma = "N"   THEN
            NEXT.
    END.

    RUN Terceiro_quinto_dia_util IN h-b1wgen0166
                                (INPUT glb_cdcooper,
                                 INPUT glb_cdagenci,
                                 INPUT 0,
                                 INPUT glb_cdoperad,
                                 INPUT glb_dtmvtolt,
                                 INPUT 1 /* idorigem */,
                                 INPUT glb_nmdatela,
                                 INPUT glb_cdprogra,
                                 INPUT aux_dtavisos,
                                 OUTPUT aux_dtavisos,
                                 OUTPUT aux_dtavs001,
                                 OUTPUT TABLE tt-erro).



/*
   ASSIGN aux_dtavisos = IF  MONTH(glb_dtmvtolt) = 12  THEN
                             DATE(1,1,YEAR(glb_dtmvtolt) + 1)
                         ELSE
                             DATE(MONTH(glb_dtmvtolt) + 1,1,
                             YEAR(glb_dtmvtolt))
          aux_dtavisos = aux_dtavisos - DAY(aux_dtavisos)
          aux_dtavs001 = aux_dtavisos
          aux_qtdiasut = 0.

   /*** retorna terceiro ou quinto dia util do mes. **/
   DO  WHILE aux_qtdiasut < 5:

       RUN Valida_feriado IN h-b1wgen0166 (INPUT glb_cdcooper,
                                           INPUT glb_cdagenci,
                                           INPUT 0 /*nrdcaixa*/,
                                           INPUT glb_cdoperad,
                                           INPUT glb_dtmvtolt,
                                           INPUT 1 /*idorigem*/,
                                           INPUT glb_nmdatela,
                                           INPUT glb_cdprogra,
                                           INPUT aux_dtavisos,
                                          OUTPUT aux_feriad,
                                          OUTPUT TABLE tt-erro).
   
       IF  RETURN-VALUE <> "OK"   THEN
           DO:
               FIND FIRST tt-erro NO-LOCK NO-ERROR.
               IF  AVAIL tt-erro   THEN
                   MESSAGE tt-erro.dscritic.
               ELSE
                   MESSAGE "Erro na validação de feriado.".
               
               PAUSE.
                  
               RETURN "NOK".
           END.

       IF  WEEKDAY(aux_dtavisos) = 1 OR 
           WEEKDAY(aux_dtavisos) = 7 OR
           aux_feriad THEN.
       ELSE
           aux_qtdiasut = aux_qtdiasut + 1.
    
       IF  aux_qtdiasut < 5  THEN
           aux_dtavisos = aux_dtavisos - 1.

       IF  aux_qtdiasut < 3  THEN
           aux_dtavs001 = aux_dtavs001 - 1.
                                                   

   END.     /* Fim do DO WHILE  */
*/

    tel_nmcooper = glb_nmrescop.
    DISPLAY tel_nmcooper WITH FRAME f_busca.

    IF  glb_cddopcao = "I"   THEN DO:
        
        RUN Busca_empresas IN h-b1wgen0166
                          (INPUT glb_cdcooper,
                           INPUT glb_cdagenci,
                           INPUT 0 /*nrdcaixa*/,
                           INPUT glb_cdoperad,
                           INPUT glb_dtmvtolt,
                           INPUT 1 /*idorigem*/,
                           INPUT glb_nmdatela,
                           INPUT glb_cdprogra,
                           INPUT tel_nmprimtl,
                           INPUT aux_cdpesqui,
                           INPUT -1,
                           OUTPUT TABLE tt-crapemp,
                           OUTPUT TABLE tt-erro).
        
        IF  RETURN-VALUE <> "OK"   THEN DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAIL tt-erro   THEN
                MESSAGE tt-erro.dscritic.
            ELSE
                MESSAGE "Erro na busca de empresa.CCCCC".
               
            PAUSE.
                  
            RETURN "NOK".
        END.

        OPEN QUERY q_empres FOR EACH tt-crapemp.

        RUN p_altera_inclui.
   
    END. /* Fim da Opcao "I"*/
    ELSE
    IF  glb_cddopcao = "A"   OR
        glb_cddopcao = "C"   THEN DO:

        RUN Busca_empresas IN h-b1wgen0166
                          (INPUT glb_cdcooper,
                           INPUT glb_cdagenci,
                           INPUT 0 /*nrdcaixa*/,
                           INPUT glb_cdoperad,
                           INPUT glb_dtmvtolt,
                           INPUT 1 /*idorigem*/,
                           INPUT glb_nmdatela,
                           INPUT glb_cdprogra,
                           INPUT tel_nmprimtl,
                           INPUT aux_cdpesqui,
                           INPUT -1,
                           OUTPUT TABLE tt-crapemp,
                           OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK"   THEN DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAIL tt-erro   THEN
                MESSAGE tt-erro.dscritic.
            ELSE
                MESSAGE "Erro na busca de empresa.DDDD".
                   
            PAUSE.
                      
            RETURN "NOK".
        END.

        OPEN QUERY q_empres FOR EACH tt-crapemp.

        VIEW FRAME f_consemp.
        ENABLE br_empres WITH FRAME f_consemp.
        WAIT-FOR ENDKEY OF br_empres.
            
        CLOSE QUERY q_empres.
        HIDE FRAME f_consemp.


    END. /* Fim da opcao "A" ou "C" */
    ELSE
    IF  glb_cddopcao = "R"   THEN
        RUN p_imprimerelacao.
    ELSE
    IF  glb_cddopcao = "T" THEN DO:

        MESSAGE "Para impressao dos termos utilizar "+
                "CADEMP no Ayllos Web!".

/*
        RUN Busca_empresas IN h-b1wgen0166
                          (INPUT glb_cdcooper,
                           INPUT glb_cdagenci,
                           INPUT 0 /*nrdcaixa*/,
                           INPUT glb_cdoperad,
                           INPUT glb_dtmvtolt,
                           INPUT 1 /*idorigem*/,
                           INPUT glb_nmdatela,
                           INPUT glb_cdprogra,
                           INPUT tel_nmprimtl,
                           INPUT aux_cdpesqui,
                           INPUT -1,
                           OUTPUT TABLE tt-crapemp,
                           OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK"   THEN DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro   THEN
                MESSAGE tt-erro.dscritic.
            ELSE
                MESSAGE "Erro na busca de empresa. XXXXX".

            PAUSE.

            RETURN "NOK".
        END.

        OPEN QUERY q_empres FOR EACH tt-crapemp.
    
        VIEW FRAME f_consemp.
        ENABLE br_empres WITH FRAME f_consemp.
        WAIT-FOR ENDKEY OF br_empres.
                
        CLOSE QUERY q_empres.
        HIDE FRAME f_consemp.
    */
    END.


END.  /*  Fim do DO WHILE TRUE  */


/************ PROCEDURES ****/

PROCEDURE p_imprimerelacao:
    
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        MESSAGE "Qual a classifcacao do relatorio (C/N)?" UPDATE aux_flgordem.
        LEAVE.
    END.

    RUN Imprime_relacao IN h-b1wgen0166
                       (INPUT glb_cdcooper,
                        INPUT glb_cdagenci,
                        INPUT 0 /*nrdcaixa*/,
                        INPUT glb_cdoperad,
                        INPUT glb_dtmvtolt,
                        INPUT 1 /*idorigem*/,
                        INPUT glb_nmdatela,
                        INPUT glb_cdprogra,
                        INPUT aux_flgordem,
                        OUTPUT aux_nmarqpdf,
                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        IF  AVAIL tt-erro   THEN
            MESSAGE tt-erro.dscritic.
        ELSE
            MESSAGE "Erro na impressao.".
          
        PAUSE.
             
        RETURN "NOK".
    END.
    ELSE DO:
        FIND FIRST crapass NO-LOCK NO-ERROR.

        ASSIGN glb_nmformul    = "80col"
               glb_nrdevias    = 1
               glb_nrcopias    = 1
               glb_cdempres    = 11
               glb_cdrelato[1] = 0
               aux_nmarqimp    = aux_nmarqimp
               aux_tpimprim    = TRUE.

        { includes/impressao.i }    
    END.

END.

PROCEDURE p_consulta:

    CLEAR FRAME f_cademp_1.

    ASSIGN tel_cdempfol = tt-crapemp.cdempfol
           tel_cdempres = tt-crapemp.cdempres
           tel_dtavscot = tt-crapemp.dtavscot
           tel_dtavsemp = tt-crapemp.dtavsemp
           tel_dtavsppr = tt-crapemp.dtavsppr
           tel_flgpagto = tt-crapemp.flgpagto
           tel_nmextemp = tt-crapemp.nmextemp
           tel_nmresemp = tt-crapemp.nmresemp
           tel_tpconven = ENTRY(tt-crapemp.tpconven + 1, aux_dstipcon)
           tel_tpdebcot = ENTRY(tt-crapemp.tpdebcot + 1, aux_dstipdeb)
           tel_tpdebemp = ENTRY(tt-crapemp.tpdebemp + 1, aux_dstipdeb)
           tel_tpdebppr = ENTRY(tt-crapemp.tpdebppr + 1, aux_dstipdeb)
           tel_cdufdemp = tt-crapemp.cdufdemp
           tel_dscomple = tt-crapemp.dscomple
           tel_dsdemail = tt-crapemp.dsdemail
           tel_dsendemp = tt-crapemp.dsendemp
           tel_dtfchfol = tt-crapemp.dtfchfol
           tel_indescsg = tt-crapemp.indescsg = 2
           tel_nmbairro = tt-crapemp.nmbairro
           tel_nmcidade = tt-crapemp.nmcidade
           tel_nrcepend = tt-crapemp.nrcepend
           tel_nrdocnpj = tt-crapemp.nrdocnpj
           tel_nrendemp = tt-crapemp.nrendemp
           tel_nrfaxemp = tt-crapemp.nrfaxemp
           tel_nrfonemp = tt-crapemp.nrfonemp
           tel_flgarqrt = tt-crapemp.flgarqrt
           tel_flgvlddv = tt-crapemp.flgvlddv
           tel_idtpempr = IF tt-crapemp.idtpempr = "C" THEN TRUE ELSE FALSE
           tel_nrdconta = tt-crapemp.nrdconta
           tel_nmextttl = tt-crapemp.nmextttl
           tel_cdcontar = tt-crapemp.cdcontar
           tel_dscontar = tt-crapemp.dscontar
           tel_flgpgtib = tt-crapemp.flgpgtib
           ant_flgpgtib = tt-crapemp.flgpgtib
           tel_vllimfol = tt-crapemp.vllimfol
           tel_nmcontat = tt-crapemp.nmcontat
           tel_dtultufp = tt-crapemp.dtultufp.

    RUN Busca_tabela IN h-b1wgen0166
                    (INPUT glb_cdcooper,
                     INPUT glb_cdagenci,
                     INPUT 0 /*nrdcaixa*/,
                     INPUT glb_cdoperad,
                     INPUT glb_dtmvtolt,
                     INPUT 1 /*idorigem*/,
                     INPUT glb_nmdatela,
                     INPUT glb_cdprogra,
                     INPUT "CRED",
                     INPUT "USUARI",
                     INPUT tel_cdempres,
                     INPUT "VLTARIF008",
                     INPUT 001,
                     OUTPUT TABLE tt-craptab,
                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"   THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        IF  AVAIL tt-erro   THEN
            MESSAGE tt-erro.dscritic.
        ELSE
            MESSAGE "Erro na busca de tabela. ".
         
        PAUSE.
            
        RETURN "NOK".
    END.
  
    FIND FIRST tt-craptab NO-ERROR.

    IF  AVAILABLE tt-craptab   THEN
        tel_vltrfsal = DECIMAL(tt-craptab.dstextab).
    ELSE DO:
        tel_vltrfsal = 0.0.
        MESSAGE "Falta tabela com a tarifa para credito de salarios.".
        PAUSE.
        HIDE MESSAGE.
    END.

    RUN Busca_tabela IN h-b1wgen0166
                    (INPUT glb_cdcooper,
                     INPUT glb_cdagenci,
                     INPUT 0 /*nrdcaixa*/,
                     INPUT glb_cdoperad,
                     INPUT glb_dtmvtolt,
                     INPUT 1 /*idorigem*/,
                     INPUT glb_nmdatela,
                     INPUT glb_cdprogra,
                     INPUT "CRED",
                     INPUT "GENERI",
                     INPUT 00,
                     INPUT "DIADOPAGTO",
                     INPUT tel_cdempres,
                     OUTPUT TABLE tt-craptab,
                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"   THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
        IF  AVAIL tt-erro   THEN
            MESSAGE tt-erro.dscritic.
        ELSE
            MESSAGE "Erro na busca de tabela.".
         
        PAUSE.
            
        RETURN "NOK".
    END.

    FIND FIRST tt-craptab NO-ERROR.

    IF  AVAILABLE tt-craptab  THEN DO:
        ASSIGN tel_ddmesnov = INT(SUBSTRING(tt-craptab.dstextab, 1, 2))
               tel_ddpgtmes = INT(SUBSTRING(tt-craptab.dstextab, 4, 2))
               tel_ddpgthor = INT(SUBSTRING(tt-craptab.dstextab, 7, 2)).
    END.
    ELSE DO:
    
        ASSIGN tel_ddmesnov = 15
               tel_ddpgtmes = 1
               tel_ddpgthor = 1.

        MESSAGE "Falta tabela referente aos dias de pagamento.".
        PAUSE.
        HIDE MESSAGE.
    END.

    RUN Busca_tabela IN h-b1wgen0166
                    (INPUT glb_cdcooper,
                     INPUT glb_cdagenci,
                     INPUT 0 /*nrdcaixa*/,
                     INPUT glb_cdoperad,
                     INPUT glb_dtmvtolt,
                     INPUT 1 /*idorigem*/,
                     INPUT glb_nmdatela,
                     INPUT glb_cdprogra,
                     INPUT "CRED",
                     INPUT "GENERI",
                     INPUT 00,
                     INPUT "NUMLOTEFOL",
                     INPUT tel_cdempres,
                     OUTPUT TABLE tt-craptab,
                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"   THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
        IF  AVAIL tt-erro   THEN
            MESSAGE tt-erro.dscritic.
        ELSE
            MESSAGE "Erro na busca de tabela.".
         
        PAUSE.
            
        RETURN "NOK".
    END.

    FIND FIRST tt-craptab NO-ERROR.

    IF  AVAILABLE tt-craptab   THEN
        tel_nrlotfol = INT(tt-craptab.dstextab).
    ELSE DO:
        tel_nrlotfol = 0.
        MESSAGE "Falta tabela com numero de lote para folha.".
        PAUSE.
        HIDE MESSAGE.
    END.

    RUN Busca_tabela IN h-b1wgen0166
                    (INPUT glb_cdcooper,
                     INPUT glb_cdagenci,
                     INPUT 0 /*nrdcaixa*/,
                     INPUT glb_cdoperad,
                     INPUT glb_dtmvtolt,
                     INPUT 1 /*idorigem*/,
                     INPUT glb_nmdatela,
                     INPUT glb_cdprogra,
                     INPUT "CRED",
                     INPUT "GENERI",
                     INPUT 00,
                     INPUT "NUMLOTEEMP",
                     INPUT tel_cdempres,
                     OUTPUT TABLE tt-craptab,
                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"   THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  AVAIL tt-erro   THEN
            MESSAGE tt-erro.dscritic.
        ELSE
            MESSAGE "Erro na busca de tabela.".
         
        PAUSE.
            
        RETURN "NOK".
    END.

    FIND FIRST tt-craptab NO-ERROR.

    IF  AVAILABLE tt-craptab   THEN
        tel_nrlotemp = INT(tt-craptab.dstextab).
    ELSE DO:
        tel_nrlotemp = 0.
        MESSAGE "Falta tabela com numero de lote para emprestimo.".
        PAUSE.
        HIDE MESSAGE.
    END.

    RUN Busca_tabela IN h-b1wgen0166
                    (INPUT glb_cdcooper,
                     INPUT glb_cdagenci,
                     INPUT 0 /*nrdcaixa*/,
                     INPUT glb_cdoperad,
                     INPUT glb_dtmvtolt,
                     INPUT 1 /*idorigem*/,
                     INPUT glb_nmdatela,
                     INPUT glb_cdprogra,
                     INPUT "CRED",
                     INPUT "GENERI",
                     INPUT 00,
                     INPUT "NUMLOTECOT",
                     INPUT tel_cdempres,
                     OUTPUT TABLE tt-craptab,
                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"   THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
        IF  AVAIL tt-erro   THEN
            MESSAGE tt-erro.dscritic.
        ELSE
            MESSAGE "Erro na busca de tabela.".
         
        PAUSE.
            
        RETURN "NOK".
    END.

    FIND FIRST tt-craptab NO-ERROR.

    IF  AVAILABLE tt-craptab   THEN
        tel_nrlotcot = INT(tt-craptab.dstextab).
    ELSE DO:
        tel_nrlotcot = 0.
        MESSAGE "Falta tabela com numero de lote para cotas.".
        PAUSE.
        HIDE MESSAGE.
    END.

END.

PROCEDURE p_altera_inclui:

    DEF VAR aux_cdcritic AS INTE                                   NO-UNDO.

    DO  WHILE TRUE:

        IF  glb_cddopcao = "A"  THEN           /* Alteracao */
            RUN p_consulta.
        ELSE DO:                               /* Inclusao */

            RUN Define_cdempres IN h-b1wgen0166 (INPUT glb_cdcooper,
                                                 INPUT glb_cdagenci,
                                                 INPUT 0 /*nrdcaixa*/,
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT 1 /*idorigem*/,
                                                 INPUT glb_nmdatela,
                                                 INPUT glb_cdprogra,
                                                 OUTPUT tel_cdempres,
                                                 OUTPUT TABLE tt-erro).
            
            IF  RETURN-VALUE <> "OK"   THEN DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF  AVAIL tt-erro   THEN
                    MESSAGE tt-erro.dscritic.
                ELSE
                    MESSAGE "Erro na busca codigo empresa.".
                
                PAUSE.
                   
                RETURN "NOK".
            END.

            ASSIGN tel_nrdconta = 0
                   tel_nmextttl = ""
                   tel_nmcontat = ""
                   tel_idtpempr = FALSE
                   tel_flgpgtib = FALSE
                   aux_flgpgtib = FALSE
                   tel_cdcontar = 0
                   tel_dscontar = ""
                   tel_vllimfol = 0
                   tel_cdempfol = 0
                   tel_dtavscot = ?
                   tel_dtavsemp = ?
                   tel_dtavsppr = ?
                   tel_flgpagto = FALSE
                   tel_flgarqrt = FALSE
                   tel_nmextemp = ""
                   tel_nmresemp = ""
                   tel_tpconven = "1.o. DIA UTIL DO MES"
                   tel_tpdebcot = "NAO DEBITA" /*"DIA DEBITO" */
                   tel_tpdebemp = "NAO DEBITA" /*"DIA DEBITO" */
                   tel_tpdebppr = "NAO DEBITA" /*"DIA DEBITO" */
                   tel_nrlotcot = INT("8" + STRING(tel_cdempres, "9999") + "0")
                   tel_nrlotemp = INT("5" + STRING(tel_cdempres, "9999") + "0")
                   tel_nrlotfol = INT("9" + STRING(tel_cdempres, "9999") + "0")
                   tel_flgvlddv = TRUE.
            
            ASSIGN tel_cdufdemp = ""
                   tel_dscomple = ""
                   tel_dsdemail = ""
                   tel_dsendemp = ""
                   tel_dtfchfol = ?
                   tel_nmbairro = ""
                   tel_nmcidade = ""
                   tel_nrfaxemp = ""
                   tel_nrfonemp = ""
                   tel_flgarqrt = NO
                   tel_flgvlddv = NO
                   tel_nrlotcot = 0
                   tel_nrlotemp = 0
                   tel_nrlotfol = 0 
                   tel_nrendemp = 0
                   tel_nrcepend = 0
                   tel_nrdocnpj = 0.

        END.  /* Fim do Else opcao "I" */

        ASSIGN log_indescsg = tel_indescsg
               log_dtfchfol = tel_dtfchfol
               log_flgpagto = tel_flgpagto
               log_flgarqrt = tel_flgarqrt
               log_cdempfol = tel_cdempfol
               log_tpconven = tel_tpconven
               log_tpdebemp = tel_tpdebemp
               log_tpdebcot = tel_tpdebcot
               log_tpdebppr = tel_tpdebppr
               log_cdempres = tel_cdempres
               log_idtpempr = tel_idtpempr
               log_nrdconta = tel_nrdconta
               log_nmcontat = tel_nmcontat
               log_dtavscot = tel_dtavscot
               log_dtavsemp = tel_dtavsemp
               log_dtavsppr = tel_dtavsppr
               log_nmextemp = tel_nmextemp
               log_nmresemp = tel_nmresemp
               log_cdufdemp = tel_cdufdemp
               log_dscomple = tel_dscomple
               log_dsdemail = tel_dsdemail
               log_dsendemp = tel_dsendemp
               log_nmbairro = tel_nmbairro
               log_nmcidade = tel_nmcidade
               log_nrcepend = tel_nrcepend
               log_nrdocnpj = tel_nrdocnpj
               log_nrendemp = tel_nrendemp
               log_nrfaxemp = tel_nrfaxemp
               log_nrfonemp = tel_nrfonemp
               log_flgvlddv = tel_flgvlddv
               log_flgpgtib = tel_flgpgtib
               log_cdcontar = tel_cdcontar
               log_vllimfol = tel_vllimfol
               aux_cdmsgerr = "".

        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
          
            DISPLAY tel_cdempres tel_nmextemp tel_nmresemp
                    tel_nmcontat tel_nrdconta tel_nmextttl
                    tel_dsendemp tel_nrendemp tel_nrdocnpj
                    tel_nmbairro tel_nmcidade tel_dscomple
                    tel_nrcepend tel_nrfonemp tel_cdufdemp
                    tel_dsdemail tel_idtpempr tel_nrfaxemp
                    WITH FRAME f_cademp_1.

            UPDATE tel_nmextemp tel_nmresemp tel_idtpempr
                   WITH FRAME f_cademp_1.

            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                DISPLAY tel_nrdconta
                        tel_nmextttl
                        WITH FRAME f_cademp_1.

                UPDATE tel_nrdconta
                   WITH FRAME f_cademp_1
                EDITING:
      
                    READKEY.
                    HIDE MESSAGE NO-PAUSE.                   
                    
                    IF  LASTKEY = KEYCODE("F7") THEN DO:
                        IF  FRAME-FIELD = "tel_nrdconta" THEN DO:

                            RUN fontes/zoom_ass_cademp.p (INPUT  glb_cdcooper,
                                                          OUTPUT tel_nrdconta,
                                                          OUTPUT tel_nmextttl).

                            IF  tel_nrdconta > 0   THEN DO:
                                DISPLAY tel_nrdconta
                                        tel_nmextttl
                                        WITH FRAME f_cademp_1.
                                PAUSE 0.
                            END.

                        END.

                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                            NEXT.

                    END.

                    APPLY LASTKEY.
                  
                END. /* Fim do EDITING*/

                IF  aux_cdmsgerr <> ""  THEN DO:
                    MESSAGE aux_cdmsgerr.
                    NEXT.
                END.
                
                IF tel_nrdconta > 0 THEN DO:

                
                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        aux_confirma = "N".
                        MESSAGE COLOR NORMAL
                           "Deseja buscar informacoes do Associado? (S/N)" 
                            UPDATE aux_confirma.
                        LEAVE.
                    END.  /*  Fim do DO WHILE TRUE  */
                
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                        aux_confirma = "S" THEN DO:
        
                        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            aux_confirm2 = TRUE.
                            MESSAGE COLOR NORMAL
                               "Deseja Complementar ou Substituir as "+ 
                               "informacoes? (C/S)"
                               UPDATE aux_confirm2.
                            LEAVE.
                        END.  /*  Fim do DO WHILE TRUE  */
        
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /* F4 OU FIM */
                            NEXT.
                    
                        RUN busca_dados_associado IN h-b1wgen0166
                                                 (INPUT glb_cdcooper,
                                                  INPUT 0, /*par_cdagenci*/
                                                  INPUT 0, /*par_nrdcaixa*/
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT 1, /* AYLLOS */
                                                  INPUT glb_nmdatela,
                                                  INPUT "CADEMP",
                                                  INPUT tel_nrdconta,
                                                  OUTPUT TABLE tt-dados-ass,
                                                  OUTPUT TABLE tt-erro).
        
                        IF  RETURN-VALUE <> "OK"   THEN DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                            IF  AVAIL tt-erro   THEN
                                MESSAGE tt-erro.dscritic.
                            ELSE
                                MESSAGE "Nao foi localizados os dados do associado!".
        
                            PAUSE.
        
                            ASSIGN tel_nrdconta = 0
                                   tel_nmextttl = "".
        
                            NEXT.
                        END.
        
                        FIND FIRST tt-dados-ass NO-LOCK NO-ERROR.
        
                        /* Se for Complementar(TRUE) preencher somente campos
                         em branco. Se for Substituir(False), substitui todos
                         os campos */
                        ASSIGN tel_nmcontat = tt-dados-ass.nmcontat
                                  WHEN ((tel_nmcontat = "" AND aux_confirm2)
                                    OR NOT aux_confirm2)
                               tel_nrdocnpj = tt-dados-ass.nrcpfcgc WHEN ((tel_nrdocnpj = 0        AND aux_confirm2) OR NOT aux_confirm2)
                               tel_dsendemp = tt-dados-ass.dsendere WHEN ((TRIM(tel_dsendemp) = "" AND aux_confirm2) OR NOT aux_confirm2)
                               tel_nrendemp = tt-dados-ass.nrendere WHEN ((tel_nrendemp = 0        AND aux_confirm2) OR NOT aux_confirm2)
                               tel_dscomple = tt-dados-ass.complend WHEN ((TRIM(tel_dscomple) = "" AND aux_confirm2) OR NOT aux_confirm2)
                               tel_nmbairro = tt-dados-ass.nmbairro WHEN ((TRIM(tel_nmbairro) = "" AND aux_confirm2) OR NOT aux_confirm2)
                               tel_nmcidade = tt-dados-ass.nmcidade WHEN ((TRIM(tel_nmcidade) = "" AND aux_confirm2) OR NOT aux_confirm2)
                               tel_cdufdemp = tt-dados-ass.cdufende WHEN ((TRIM(tel_cdufdemp) = "" AND aux_confirm2) OR NOT aux_confirm2)
                               tel_nrcepend = tt-dados-ass.nrcepend WHEN ((tel_nrcepend = 0        AND aux_confirm2) OR NOT aux_confirm2)
                               tel_dsdemail = tt-dados-ass.dsdemail WHEN ((TRIM(tel_dsdemail) = "" AND aux_confirm2) OR NOT aux_confirm2)
                               tel_nmresemp = tt-dados-ass.nmfansia WHEN ((TRIM(tel_nmresemp) = "" AND aux_confirm2) OR NOT aux_confirm2).
                        
                        DISPLAY tel_cdempres tel_nmextemp tel_nmresemp
                                tel_nmcontat tel_nrdconta tel_nmextttl
                                tel_dsendemp tel_nrendemp tel_nrdocnpj
                                tel_nmbairro tel_nmcidade tel_dscomple
                                tel_nrcepend tel_nrfonemp tel_cdufdemp
                                tel_dsdemail tel_idtpempr tel_nrfaxemp
                                WITH FRAME f_cademp_1.
                    END.
                
                END.

                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_nmcontat tel_nrdocnpj
                           tel_dsendemp tel_nrendemp tel_dscomple
                           tel_nmbairro tel_nmcidade tel_cdufdemp
                           tel_nrcepend tel_nrfonemp tel_nrfaxemp
                           tel_dsdemail
                           WITH FRAME f_cademp_1.
                    
                    IF tel_nmextemp = "" THEN
                      DO:
                         MESSAGE "Campo Razao Social da Empresa Obrigatorio!".
                         UPDATE tel_nmextemp
                              WITH FRAME f_cademp_1.
                         
                      END.
                   
                    IF tel_nrdocnpj <> 0 THEN DO:

                        IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                            RUN sistema/generico/procedures/b1wgen9999.p
                            PERSISTENT SET h-b1wgen9999.
        
                        RUN valida-cnpj IN h-b1wgen9999
                                      ( INPUT  tel_nrdocnpj,
                                        OUTPUT aux_stsnrcal).
               
                        IF  VALID-HANDLE(h-b1wgen9999) THEN
                            DELETE PROCEDURE h-b1wgen9999.

                        IF  NOT aux_stsnrcal THEN DO:
                            MESSAGE "CNPJ invalido.".
                            PAUSE(3) NO-MESSAGE.
                            NEXT.
                        END.

                    END. /* Fim do if tel_nrdocnpj <> 0 */
         
                    IF  tel_dsdemail <> "" THEN DO:
                        RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement aux_ponteiro = PROC-HANDLE
                        ("SELECT GENE0003.fn_valida_email('" + tel_dsdemail + "')  FROM dual").

                        FOR EACH {&sc2_dboraayl}.proc-text WHERE PROC-HANDLE = aux_ponteiro:
                            ASSIGN aux_cdcritic = INTE(proc-text).
                        END.
                        CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
                                    WHERE PROC-HANDLE = aux_ponteiro.       
        
                        IF  aux_cdcritic <> 1 THEN DO:
                            MESSAGE "E-mail invalido.".
                            PAUSE(3) NO-MESSAGE.
                            NEXT.
                        END.
                    END.

                    IF  NOT KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /* F4 OU FIM */
                        LEAVE.

                    NEXT.

                END.

                IF  NOT KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /* F4 OU FIM */
                    LEAVE.

                NEXT.

            END.

            IF  NOT KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /* F4 OU FIM */
                LEAVE.

            NEXT.

        END. /* Fim DO WHILE TRUE */

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN DO: /* F4 OU FIM */

            HIDE FRAME f_cademp_1
                 FRAME f_cademp_3
                 FRAME f_cademp_2.
            RETURN.
        END.

        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
            DISPLAY tel_flgpagto tel_cdempfol tel_vltrfsal
                    tel_dtfchfol tel_ddpgtmes tel_ddpgthor
                    WITH FRAME f_cademp_3.

            UPDATE tel_flgpagto tel_cdempfol tel_vltrfsal
                   tel_dtfchfol tel_ddpgtmes tel_ddpgthor
                   WITH FRAME f_cademp_3.

            RUN Valida_empresa IN h-b1wgen0166
                              (INPUT glb_cdcooper,
                               INPUT glb_cdagenci,
                               INPUT 0 /*nrdcaixa*/,
                               INPUT glb_cdoperad,
                               INPUT glb_dtmvtolt,
                               INPUT 1 /*idorigem*/,
                               INPUT glb_nmdatela,
                               INPUT glb_cdprogra,
                               INPUT tel_indescsg,
                               INPUT tel_nrdocnpj,
                               INPUT tel_dtfchfol,
                               INPUT tel_cdempfol,
                               INPUT tel_flgpagto,
                               INPUT aux_dtavsemp,
                               INPUT tel_dtavsemp,
                               INPUT aux_dtavscot,
                               INPUT tel_dtavscot,
                               INPUT aux_dtavsppr,
                               INPUT tel_dtavsppr,
                               OUTPUT aux_dscritic,
                               OUTPUT TABLE tt-erro).
        
            IF  RETURN-VALUE <> "OK"   THEN DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF  AVAIL tt-erro   THEN
                    MESSAGE tt-erro.dscritic.
                ELSE
                    MESSAGE "Erro na validação empresa.".
    
                PAUSE.

                NEXT.
            END.

            LEAVE.

        END. /* Fim DO WHILE TRUE */

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN DO: /* F4 OU FIM */
            HIDE FRAME f_cademp_3
                 FRAME f_cademp_1.
            NEXT.
        END.

        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

            DISPLAY tel_flgpgtib
                    tel_cdcontar
                    tel_dscontar
                    tel_vllimfol
                    WITH FRAME f_cademp_2.

            UPDATE tel_flgpgtib
                   WITH FRAME f_cademp_2.

            /* Atualiza os demais campos
            se servico for adquirido */
            IF  tel_flgpgtib THEN DO:

                UPDATE tel_cdcontar
                    WITH FRAME f_cademp_2
                EDITING:
      
                    READKEY.
                    HIDE MESSAGE NO-PAUSE.

                    IF  LASTKEY = KEYCODE("F7") THEN DO:
                        IF  FRAME-FIELD = "tel_cdcontar" THEN DO:

                            RUN fontes/zoom_convenio.p (INPUT  glb_cdcooper,
                                                        OUTPUT tel_cdcontar,
                                                        OUTPUT tel_dscontar).

                            IF  tel_cdcontar > 0   THEN DO:
                                DISPLAY tel_cdcontar
                                        tel_dscontar
                                        WITH FRAME f_cademp_2.
                                PAUSE 0.
                            END.

                        END.

                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                            NEXT.

                    END.

                    APPLY LASTKEY.
                  
                END. /* Fim do EDITING */

                UPDATE tel_vllimfol
                       WITH FRAME f_cademp_2.

                /* Validacao dos campos */
                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    IF  tel_cdcontar = 0 THEN DO:
                        MESSAGE "O Convenio Tarifario deve ser preenchido.".
                        PAUSE.

                        UPDATE tel_cdcontar
                               WITH FRAME f_cademp_2.
                        NEXT.
                    END.

                    IF  tel_vllimfol = 0 THEN DO:
                        MESSAGE "Valor Limite Diario deve ser preenchido.".
                        PAUSE.

                        UPDATE tel_vllimfol
                               WITH FRAME f_cademp_2.
                        NEXT.
                    END.

                    LEAVE.

                END. /* Fim DO WHILE TRUE */
            
            END.

            LEAVE.

        END. /* Fim DO WHILE TRUE */

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN DO: /* F4 OU FIM */
            HIDE FRAME f_cademp_2
                 FRAME f_cademp_3.
            NEXT.
        END.

        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

            /* Somente pega as descricoes se estiver na alteracao */
            IF  glb_cddopcao = "A"   THEN DO:
                IF  tt-crapemp.tpdebemp = 0   THEN
                    ASSIGN tel_tpdebemp = "NAO DEBITA"
                           tel_dtavsemp = ?.

                IF  tt-crapemp.tpdebcot = 0   THEN
                    ASSIGN tel_tpdebcot = "NAO DEBITA"
                           tel_dtavscot = ?.

                IF  tt-crapemp.tpdebppr = 0 THEN
                    ASSIGN tel_tpdebppr = "NAO DEBITA"
                           tel_dtavsppr = ?.
            END. /* Fim do IF opcao "A" */

            IF  glb_dsdepart <> "TI"       AND
                glb_dsdepart <> "SUPORTE"  THEN
                LEAVE.

            ASSIGN aux_dtavsemp = tel_dtavsemp
                   aux_dtavscot = tel_dtavscot
                   aux_dtavsppr = tel_dtavsppr.

            DO  WHILE TRUE :

                DISPLAY tel_dtavsemp tel_dtavscot tel_dtavsppr
                        WITH FRAME f_cademp_4.

                UPDATE tel_indescsg tel_flgarqrt tel_flgvlddv
                       tel_ddmesnov tel_tpconven tel_tpdebemp
                       tel_tpdebcot tel_tpdebppr
                       WITH FRAME f_cademp_4
                EDITING:

                    READKEY.
                    IF  FRAME-FIELD = "tel_tpconven"   THEN DO:
                        aux_contador = LOOKUP(tel_tpconven,aux_dstipcon).

                        IF  KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"    OR
                            KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN DO:
                            
                            aux_contador = aux_contador + 1.
                             
                            IF  aux_contador > NUM-ENTRIES(aux_dstipcon) THEN
                                aux_contador = 2.

                            tel_tpconven = ENTRY(aux_contador,aux_dstipcon).

                            DISPLAY tel_tpconven
                                    WITH FRAME f_cademp_4.
                        END.
                        ELSE
                        IF  KEYFUNCTION(LASTKEY) = "CURSOR-UP"    OR
                            KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN DO:
                            
                            aux_contador = aux_contador - 1.
                            
                            IF  aux_contador <= 1   THEN
                                aux_contador = NUM-ENTRIES(aux_dstipcon).

                            tel_tpconven = ENTRY(aux_contador,aux_dstipcon).

                            DISPLAY tel_tpconven
                                    WITH FRAME f_cademp_4.
                        END.
                        ELSE
                        IF  KEYFUNCTION(LASTKEY) = "RETURN"    OR
                            KEYFUNCTION(LASTKEY) = "BACK-TAB"  OR
                            KEYFUNCTION(LASTKEY) = "GO"        OR
                            KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                            APPLY LASTKEY.
                    END.
                    ELSE
                    IF  FRAME-FIELD = "tel_tpdebcot"   THEN DO:
                        aux_contador = LOOKUP(tel_tpdebcot,aux_dstipdeb).

                        IF  KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"    OR
                            KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN DO:
                            
                            aux_contador = aux_contador + 1.
                            
                            IF  aux_contador > NUM-ENTRIES(aux_dstipdeb) THEN
                                aux_contador = 2.

                            tel_tpdebcot = ENTRY(aux_contador,aux_dstipdeb).

                            DISPLAY tel_tpdebcot
                                    WITH FRAME f_cademp_4.
                        END.
                        ELSE
                        IF  KEYFUNCTION(LASTKEY) = "CURSOR-UP"    OR
                            KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN DO:
                            
                            aux_contador = aux_contador - 1.
                             
                            IF  aux_contador <= 1   THEN
                                aux_contador = NUM-ENTRIES(aux_dstipdeb).

                            tel_tpdebcot = ENTRY(aux_contador,aux_dstipdeb).

                            DISPLAY tel_tpdebcot
                                    WITH FRAME f_cademp_4.
                        END.
                        ELSE
                        IF  KEYFUNCTION(LASTKEY) = "RETURN"    OR
                            KEYFUNCTION(LASTKEY) = "BACK-TAB"  OR
                            KEYFUNCTION(LASTKEY) = "GO"        OR
                            KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                            APPLY LASTKEY.

                        APPLY "LEAVE" TO tel_tpdebcot.
                    END.
                    ELSE
                    IF  FRAME-FIELD = "tel_tpdebemp"   THEN DO:

                        aux_contador = LOOKUP(tel_tpdebemp,aux_dstipdeb).

                        IF  KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"    OR
                            KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN DO:
                             
                            aux_contador = aux_contador + 1.
                             
                            IF  aux_contador > NUM-ENTRIES(aux_dstipdeb) THEN
                                aux_contador = 2.

                                tel_tpdebemp = ENTRY(aux_contador,aux_dstipdeb).

                            DISPLAY tel_tpdebemp
                                    WITH FRAME f_cademp_4.
                        END.
                        ELSE
                        IF  KEYFUNCTION(LASTKEY) = "CURSOR-UP"    OR
                            KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN DO:

                            aux_contador = aux_contador - 1.

                            IF  aux_contador <= 1   THEN
                                aux_contador = NUM-ENTRIES(aux_dstipdeb).

                                tel_tpdebemp = ENTRY(aux_contador,aux_dstipdeb).

                                DISPLAY tel_tpdebemp
                                        WITH FRAME f_cademp_4.
                        END.
                        ELSE
                        IF  KEYFUNCTION(LASTKEY) = "RETURN"    OR
                            KEYFUNCTION(LASTKEY) = "BACK-TAB"  OR
                            KEYFUNCTION(LASTKEY) = "GO"        OR
                            KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                            APPLY LASTKEY.

                        APPLY "LEAVE" TO tel_tpdebemp.
                    END.
                    ELSE
                    IF  FRAME-FIELD = "tel_tpdebppr"   THEN DO:
                        aux_contador = LOOKUP(tel_tpdebppr,aux_dstipdeb).

                        IF  KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"    OR
                            KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN DO:
                            
                            aux_contador = aux_contador + 1.
                            
                            IF  aux_contador > NUM-ENTRIES(aux_dstipdeb) THEN
                                aux_contador = 2.

                            tel_tpdebppr = ENTRY(aux_contador,aux_dstipdeb).

                            DISPLAY tel_tpdebppr
                                    WITH FRAME f_cademp_4.
                        END.
                        ELSE
                        IF  KEYFUNCTION(LASTKEY) = "CURSOR-UP"    OR
                            KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN DO:
                            
                            aux_contador = aux_contador - 1.
                            
                            IF   aux_contador <= 1   THEN
                                 aux_contador = NUM-ENTRIES(aux_dstipdeb).

                            tel_tpdebppr = ENTRY(aux_contador,aux_dstipdeb).

                            DISPLAY tel_tpdebppr
                                    WITH FRAME f_cademp_4.
                         END.
                        ELSE
                        IF  KEYFUNCTION(LASTKEY) = "RETURN"    OR
                            KEYFUNCTION(LASTKEY) = "BACK-TAB"  OR
                            KEYFUNCTION(LASTKEY) = "GO"        OR
                            KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                            APPLY LASTKEY.

                        APPLY "LEAVE" TO tel_tpdebppr.
                    END.
                    ELSE
                    IF  KEYFUNCTION(LASTKEY) = "ENDKEY"       OR
                        KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  OR
                        KEYFUNCTION(LASTKEY) = "CURSOR-UP"    THEN
                        APPLY LASTKEY.
                    ELSE
                        APPLY LASTKEY.
                END. /* Fim do EDITING */

                IF  aux_dscritic <> "" THEN DO:
                    MESSAGE aux_dscritic.
                    NEXT.
                END.

                LEAVE.

            END. /* Fim DO WHILE TRUE */
        
            LEAVE.

        END.  /* Fim DO WHILE TRUE */

        /*   F4 ou Fim     */
        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN DO:
            HIDE FRAME f_cademp_4.
            NEXT.
        END.

        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

            aux_confirma = "N".
            glb_cdcritic = 78.
            RUN fontes/critic.p.
            BELL.
            glb_cdcritic = 0.
            MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
            LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
            aux_confirma <> "S" THEN DO:
            
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 5 NO-MESSAGE.
            HIDE FRAME f_cademp_1
                 FRAME f_cademp_3
                 FRAME f_cademp_2
                 FRAME f_cademp_4.
            RETURN.
        END.

        /* Verifica se a conta debito esta informada quando 
        o servico de folha de pagamento esta sendo aderido */
        IF  (ant_flgpgtib <> tel_flgpgtib) THEN DO:
            /* Adquirindo o servico de folha */ 
            IF  tel_flgpgtib THEN DO:
                IF tel_nrdconta = 0 THEN DO:
                    MESSAGE "Conta Debito deve ser informada!".
                    PAUSE(5) NO-MESSAGE.
                    HIDE MESSAGE.
                    NEXT.

                END.
            END.

            aux_flgdgfib = TRUE.
        END.
        ELSE aux_flgdgfib = FALSE.


        RUN Grava_tabela IN h-b1wgen0166
                        (INPUT glb_cdcooper,
                         INPUT glb_cdagenci,
                         INPUT 0 /*nrdcaixa*/,
                         INPUT glb_cdoperad,
                         INPUT glb_dtmvtolt,
                         INPUT 1 /*idorigem*/,
                         INPUT glb_nmdatela,
                         INPUT glb_cdprogra,
                         INPUT "CRED",
                         INPUT "GENERI",
                         INPUT 00,
                         INPUT "DIADOPAGTO",
                         INPUT tel_cdempres,
                         INPUT       STRING(tel_ddmesnov,"99") +
                               " " + STRING(tel_ddpgtmes,"99") +
                               " " + STRING(tel_ddpgthor,"99") +
                               " 270 0",
                          OUTPUT TABLE tt-erro).
        
        IF  RETURN-VALUE <> "OK"   THEN DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro   THEN
                MESSAGE tt-erro.dscritic.
            ELSE
                MESSAGE "Erro na gravacao tabela.".

            PAUSE.

            RETURN "NOK".
        END.

        RUN Grava_tabela IN h-b1wgen0166
                        (INPUT glb_cdcooper,
                         INPUT glb_cdagenci,
                         INPUT 0 /*nrdcaixa*/,
                         INPUT glb_cdoperad,
                         INPUT glb_dtmvtolt,
                         INPUT 1 /*idorigem*/,
                         INPUT glb_nmdatela,
                         INPUT glb_cdprogra,
                         INPUT "CRED",
                         INPUT "USUARI",
                         INPUT tel_cdempres,
                         INPUT "VLTARIF008",
                         INPUT 001,
                         INPUT STRING(tel_vltrfsal,"999999999.99"),
                         OUTPUT TABLE tt-erro).
     
        IF  RETURN-VALUE <> "OK"   THEN DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAIL tt-erro   THEN
                MESSAGE tt-erro.dscritic.
            ELSE
                MESSAGE "Erro na gravacao tabela.".
            
            PAUSE.
               
            RETURN "NOK".
        END.

        RUN Grava_tabela IN h-b1wgen0166
                        (INPUT glb_cdcooper,
                         INPUT glb_cdagenci,
                         INPUT 0 /*nrdcaixa*/,
                         INPUT glb_cdoperad,
                         INPUT glb_dtmvtolt,
                         INPUT 1 /*idorigem*/,
                         INPUT glb_nmdatela,
                         INPUT glb_cdprogra,
                         INPUT "CRED",
                         INPUT "GENERI",
                         INPUT 00,
                         INPUT "NUMLOTEFOL",
                         INPUT tel_cdempres,
                         INPUT "9"+ STRING(tel_cdempres,"9999") + 
                               "0",
                         OUTPUT TABLE tt-erro).
     
        IF  RETURN-VALUE <> "OK"   THEN DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF AVAIL tt-erro   THEN
                MESSAGE tt-erro.dscritic.
            ELSE
                MESSAGE "Erro na gravacao tabela.".
            
            PAUSE.
               
            RETURN "NOK".
        END.

        RUN Grava_tabela IN h-b1wgen0166
                        (INPUT glb_cdcooper,
                         INPUT glb_cdagenci,
                         INPUT 0 /*nrdcaixa*/,
                         INPUT glb_cdoperad,
                         INPUT glb_dtmvtolt,
                         INPUT 1 /*idorigem*/,
                         INPUT glb_nmdatela,
                         INPUT glb_cdprogra,
                         INPUT "CRED",
                         INPUT "GENERI",
                         INPUT 00,
                         INPUT "NUMLOTEEMP",
                         INPUT tel_cdempres,
                         INPUT "5"+ STRING(tel_cdempres,"9999") + 
                               "0",
                         OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK"   THEN DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF AVAIL tt-erro   THEN
                MESSAGE tt-erro.dscritic.
            ELSE
                MESSAGE "Erro na gravacao tabela.".
            
            PAUSE.
               
            RETURN "NOK".
        END.

        RUN Grava_tabela IN h-b1wgen0166
                        (INPUT glb_cdcooper,
                         INPUT glb_cdagenci,
                         INPUT 0 /*nrdcaixa*/,
                         INPUT glb_cdoperad,
                         INPUT glb_dtmvtolt,
                         INPUT 1 /*idorigem*/,
                         INPUT glb_nmdatela,
                         INPUT glb_cdprogra,
                         INPUT "CRED",
                         INPUT "GENERI",
                         INPUT 00,
                         INPUT "NUMLOTECOT",
                         INPUT tel_cdempres,
                         INPUT "8" + STRING(tel_cdempres,"9999")+ 
                               "0",
                         OUTPUT TABLE tt-erro).
        
        IF  RETURN-VALUE <> "OK"   THEN DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAIL tt-erro   THEN
                MESSAGE tt-erro.dscritic.
            ELSE
                MESSAGE "Erro na gravacao tabela.".
            
            PAUSE.
               
            RETURN "NOK".
        END.

        IF  glb_cddopcao = "I"  THEN DO:
            IF  glb_cdcritic <> 0   THEN DO:
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                PAUSE 5 NO-MESSAGE.
                HIDE FRAME f_cademp_3
                     FRAME f_cademp_2
                     FRAME f_cademp_1.
                RETURN.
            END.
            ELSE
                ASSIGN aux_tptran = "I".
        END.
        ELSE DO:
            ASSIGN aux_tptran = "A".
        END.

        ASSIGN aux_cdempfol = tel_cdempfol
               aux_cdempres = tel_cdempres
               aux_idtpempr = STRING(tel_idtpempr,"C/O")
               aux_nrdconta = tel_nrdconta
               aux_dtultufp = tel_dtultufp
               aux_nmcontat = tel_nmcontat
               aux_dtavscot = tel_dtavscot
               aux_dtavsemp = tel_dtavsemp
               aux_dtavsppr = tel_dtavsppr
               aux_flgpagto = tel_flgpagto
               aux_flgarqrt = tel_flgarqrt
               aux_nmextemp = CAPS(tel_nmextemp)
               aux_nmresemp = CAPS(tel_nmresemp)
               aux_dtfchfol = tel_dtfchfol
               aux_cdufdemp = tel_cdufdemp
               aux_nmbairro = tel_nmbairro
               aux_nmcidade = tel_nmcidade
               aux_dscomple = tel_dscomple
               aux_nrendemp = tel_nrendemp
               aux_dsendemp = tel_dsendemp
               aux_nrcepend = tel_nrcepend
               aux_nrfonemp = tel_nrfonemp
               aux_nrfaxemp = tel_nrfaxemp
               aux_nrdocnpj = tel_nrdocnpj
               aux_dsdemail = tel_dsdemail
               aux_flgvlddv = tel_flgvlddv
               aux_flgpgtib = tel_flgpgtib
               aux_cdcontar = tel_cdcontar
               aux_vllimfol = tel_vllimfol.

        /* Alisson (AMcom) - 21/01/2015
           Somente vai zerar o crapemp.inavsemp e crapemp.inavscot
           ao alterar as informacoes se ainda nao tiver rodado o crps080 
        */

        IF aux_tptran = "I" THEN 
           ASSIGN aux_inavsemp = 0
                  aux_inavscot = 0.
        ELSE
          /* se ja executou o crps080 mantem o mesmo indicador */
          IF tt-crapemp.inavsemp <> 0 OR tt-crapemp.inavscot <> 0 THEN
            ASSIGN aux_inavsemp = tt-crapemp.inavsemp
                   aux_inavscot = tt-crapemp.inavscot.
          ELSE
            ASSIGN aux_inavsemp = 0
                   aux_inavscot = 0.

        ASSIGN /* Comentado por Alisson (AMcom) - 21/01/2015 
               aux_inavscot = 0
               aux_inavsemp = 0 
               */
               aux_inavsppr = 0
               aux_inavsden = 0
               aux_inavsseg = 0
               aux_inavssau = 0
               aux_tpconven = LOOKUP(tel_tpconven,aux_dstipcon) - 1
               aux_tpdebcot = LOOKUP(tel_tpdebcot,aux_dstipdeb) - 1
               aux_tpdebemp = LOOKUP(tel_tpdebemp,aux_dstipdeb) - 1
               aux_tpdebppr = LOOKUP(tel_tpdebppr,aux_dstipdeb) - 1
               aux_indescsg = LogicToInt(tel_indescsg) + 1.

        RUN Altera_inclui IN h-b1wgen0166
                         (INPUT glb_cdcooper,
                          INPUT glb_cdagenci,
                          INPUT 0 /*nrdcaixa*/,
                          INPUT glb_cdoperad,
                          INPUT glb_dtmvtolt,
                          INPUT 1 /*idorigem*/,
                          INPUT glb_nmdatela,
                          INPUT glb_cdprogra,
                          INPUT aux_tptran,
                          INPUT aux_inavscot,
                          INPUT aux_inavsemp,
                          INPUT aux_inavsppr,
                          INPUT aux_inavsden,
                          INPUT aux_inavsseg,
                          INPUT aux_inavssau,
                          INPUT aux_cdempres,
                          INPUT aux_idtpempr,
                          INPUT aux_nrdconta,
                          INPUT aux_dtultufp,
                          INPUT aux_nmcontat,
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
                          INPUT aux_flgpgtib,
                          INPUT aux_cdcontar,
                          INPUT aux_vllimfol,
                          INPUT aux_flgdgfib,
                          OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK"   THEN DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAIL tt-erro   THEN
                MESSAGE tt-erro.dscritic.
            ELSE
                MESSAGE "Erro na inlusao/alteracao empresa.".
            
            PAUSE.
               
            RETURN "NOK".
        END.

        RUN Gera_arquivo_log IN h-b1wgen0166
                            (INPUT glb_cdcooper,
                             INPUT glb_cddopcao,
                             INPUT glb_dtmvtolt,
                             INPUT glb_cdoperad,
                             INPUT tel_cdempres,
                             INPUT tel_idtpempr,
                             INPUT tel_nrdconta,
                             INPUT tel_dtultufp,
                             INPUT tel_flgpgtib,
                             INPUT tel_cdcontar,
                             INPUT tel_vllimfol,
                             INPUT tel_nmcontat,
                             INPUT log_indescsg, 
                             INPUT tel_indescsg,
                             INPUT log_dtfchfol, 
                             INPUT tel_dtfchfol,
                             INPUT log_flgpagto, 
                             INPUT tel_flgpagto,
                             INPUT log_flgarqrt, 
                             INPUT tel_flgarqrt,
                             INPUT log_flgvlddv, 
                             INPUT tel_flgvlddv,
                             INPUT log_cdempfol, 
                             INPUT tel_cdempfol,
                             INPUT log_tpconven, 
                             INPUT INPUT tel_tpconven,
                             INPUT log_tpdebemp, 
                             INPUT INPUT tel_tpdebemp,
                             INPUT log_tpdebcot, 
                             INPUT INPUT tel_tpdebcot,
                             INPUT log_tpdebppr, 
                             INPUT INPUT tel_tpdebppr,
                             INPUT log_cdempres,
                             INPUT log_idtpempr,
                             INPUT log_nrdconta,
                             INPUT log_dtultufp,
                             INPUT log_flgpgtib,
                             INPUT log_cdcontar,
                             INPUT log_vllimfol,
                             INPUT log_nmcontat,
                             INPUT tel_cdempres,
                             INPUT tel_idtpempr,
                             INPUT tel_nrdconta,
                             INPUT tel_dtultufp,
                             INPUT tel_flgpgtib,
                             INPUT tel_cdcontar,
                             INPUT tel_vllimfol,
                             INPUT tel_nmcontat,
                             INPUT log_dtavscot, 
                             INPUT tel_dtavscot,
                             INPUT log_dtavsemp, 
                             INPUT tel_dtavsemp,
                             INPUT log_dtavsppr, 
                             INPUT tel_dtavsppr,
                             INPUT log_nmextemp, 
                             INPUT tel_nmextemp,
                             INPUT log_nmresemp, 
                             INPUT tel_nmresemp,
                             INPUT log_cdufdemp, 
                             INPUT tel_cdufdemp,
                             INPUT log_dscomple, 
                             INPUT tel_dscomple,
                             INPUT log_dsdemail, 
                             INPUT tel_dsdemail,
                             INPUT log_dsendemp, 
                             INPUT tel_dsendemp,
                             INPUT log_nmbairro, 
                             INPUT tel_nmbairro,
                             INPUT log_nmcidade, 
                             INPUT tel_nmcidade,
                             INPUT log_nrcepend, 
                             INPUT tel_nrcepend,
                             INPUT log_nrdocnpj, 
                             INPUT tel_nrdocnpj,
                             INPUT log_nrendemp, 
                             INPUT tel_nrendemp,
                             INPUT log_nrfaxemp, 
                             INPUT tel_nrfaxemp,
                             INPUT log_nrfonemp, 
                             INPUT tel_nrfonemp).

        /* Se a empresa esta adquirindo o servico, verificar se ja exite
        a digitalizacao do DOC. Caso ja tenho o servico de folha, ignora
        essa validacao */
        IF  (ant_flgpgtib <> tel_flgpgtib) THEN DO:
            /* Adquirindo o servico de folha */ 
            IF  tel_flgpgtib THEN DO:

                MESSAGE "Favor efetuar a digitalizacao do termo de adesao " +
                        "dessa conta.".
                PAUSE(5) NO-MESSAGE.
                HIDE MESSAGE.

                ASSIGN tel_dtultufp = ?
                       log_dtultufp = ?.

            END.
            ELSE DO: /* Cancelamento */

                IF  glb_cddopcao = "A"  THEN DO:

                    MESSAGE "Favor efetuar a digitalizacao do termo de " + 
                            "cancelamento dessa conta.".
                    PAUSE(5) NO-MESSAGE.
                    HIDE MESSAGE.

                    ASSIGN tel_dtultufp = ?
                           log_dtultufp = ?.
                END.
            
            END.
        END.

        MESSAGE "Operacao efetuada com sucesso!".
        PAUSE(3) NO-MESSAGE.


        HIDE FRAME f_cademp_1
             FRAME f_cademp_3
             FRAME f_cademp_2
             FRAME f_cademp_4.

        LEAVE.

    END.  /*  Fim do DO WHILE TRUE PRINCIPAL  */

END PROCEDURE.

PROCEDURE p_impressao_termo:

    /* Se a empresa possui ou ja possuiu o servico de folha de pagto */
    IF  NOT (tel_flgpgtib OR (NOT tel_flgpgtib AND tel_dtultufp <> ?)) THEN DO:
        MESSAGE  "A empresa selecionada nao possui servico Folha de Pagamento.".
        PAUSE NO-MESSAGE.
        NEXT.
    END.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        aux_confirm3 = FALSE.
        MESSAGE COLOR NORMAL
           "Impressao do termo de Adesao ou Cancelamento? (A/C)" UPDATE aux_confirm3.
        LEAVE.
    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /* F4 OU FIM */
        NEXT.

    IF  aux_confirm3 THEN DO: /* ADESAO DO SERVICO */

        DO  WHILE TRUE:
        
            RUN Busca_Procuradores_Emp IN h-b1wgen0166
                                      (INPUT glb_cdcooper
                                      ,INPUT tel_cdempres
                                      ,OUTPUT TABLE tt-procuradores-emp
                                      ,OUTPUT TABLE tt-erro).

            VIEW FRAME f_regua.
            PAUSE 0.
            
            OPEN QUERY q_procuradores FOR EACH tt-procuradores-emp.
            
            DISPLAY b_procuradores WITH FRAME f_browse.
            
            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                UPDATE b_procuradores WITH FRAME f_browse.
                LEAVE.
            
            END.
            
            IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN DO:
            
                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    aux_confirma = "N".
                    MESSAGE COLOR NORMAL "Confirma selecao de procuradores ou voltar a selecao de empresas?(S/N)"
                    UPDATE aux_confirma.
                    LEAVE.
                END.

                IF  aux_confirma <> "S"   THEN
                    LEAVE.
            END.

            /* Verifica se alguma conta foi selecionada */
            FIND FIRST tt-procuradores-emp WHERE tt-procuradores-emp.idctasel
                                              NO-LOCK NO-ERROR.

            IF  NOT AVAIL tt-procuradores-emp THEN DO:
                MESSAGE "Para prosseguir com a geracao do termo, favor escolher um procurador".
                PAUSE.
                NEXT.
            END.

            /* Monta a lista de contas */
            ASSIGN aux_contador = 0.
            FOR EACH tt-procuradores-emp WHERE tt-procuradores-emp.idctasel NO-LOCK:
                
                IF  aux_contador = 0 THEN
                    ASSIGN aux_lisconta = STRING(tt-procuradores-emp.nrdctato) + ","
                           aux_contador = 1.
                ELSE
                    ASSIGN aux_lisconta = aux_lisconta + STRING(tt-procuradores-emp.nrdctato) + ","
                           aux_contador = aux_contador + 1.

            END.
            ASSIGN aux_lisconta = "," + aux_lisconta.

            MESSAGE "Gerando termo de adesao...".
            
            /* Gerando Termo de Adesao */
            RUN Impresao_Termo_Servico IN h-b1wgen0166
                                      (INPUT glb_cdcooper,
                                       INPUT glb_dtmvtolt,
                                       INPUT glb_cdagenci,
                                       INPUT 1,
                                       INPUT tel_cdempres,
                                       INPUT 0, /* Adesao */
                                       INPUT aux_lisconta,
                                       OUTPUT aux_nmarquiv,
                                       OUTPUT glb_cdcritic,
                                       OUTPUT glb_dscritic).
    
            IF  RETURN-VALUE <> "OK"   THEN DO:
        
                IF glb_cdcritic <> 0
                OR glb_dscritic <> "" THEN
                    MESSAGE glb_dscritic.
        
                PAUSE.
                RETURN "NOK".
            END.

            PAUSE(0) NO-MESSAGE.
            HIDE MESSAGE.

            MESSAGE "Termo de Adesao gerado em: " + aux_nmarquiv.
            PAUSE(5) NO-MESSAGE.
            HIDE MESSAGE.
            LEAVE.

        END. /* Fim DO WHILE TRUE */

    END. 
    ELSE DO: /* CANCELAMENTO DO SERVICO */

        MESSAGE "Gerando termo de cancelamento...".
        /* Gerando Termo de Cancelamento */
        RUN Impresao_Termo_Servico IN h-b1wgen0166
                                  (INPUT glb_cdcooper,
                                   INPUT glb_dtmvtolt,
                                   INPUT 1,
                                   INPUT 1,
                                   INPUT tel_cdempres,
                                   INPUT 1, /* Cancelamento */
                                   INPUT "",
                                   OUTPUT aux_nmarquiv,
                                   OUTPUT glb_cdcritic,
                                   OUTPUT glb_dscritic).

        IF  RETURN-VALUE <> "OK"   THEN DO:
        
            IF glb_cdcritic <> 0
            OR glb_dscritic <> "" THEN
                MESSAGE glb_dscritic.
    
            PAUSE.
            RETURN "NOK".
        END.
        
        PAUSE(0) NO-MESSAGE.
        HIDE MESSAGE.

        MESSAGE "Termo de Cancelamento gerado em: " + aux_nmarquiv.
        PAUSE(5) NO-MESSAGE.
        HIDE MESSAGE.
    END.

    RETURN "OK".

END PROCEDURE.
  
/* .......................................................................... */
