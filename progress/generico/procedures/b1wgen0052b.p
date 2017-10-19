/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0052b.p                  
    Autor(a): Jose Luis Marchezoni (DB1)
    Data    : Junho/2010                      Ultima atualizacao: 09/09/2016
  
    Dados referentes ao programa:
  
    Objetivo  : BO com regras de negocio refente a tela MATRIC.
                Baseado em fontes/matric.p.
                Rotinas de Busca de Dados
  
    Alteracoes: 18/10/2010 - Atribuir informaçao ao campo tt-relat-rep.nrdconta 
                            (Joao-RKAM)
                            
                25/02/2011 - Retornar critica 832 como alerta na procedure
                             Verifica_Principal (David).
                             
                14/06/2012 - Ajsutes referente ao projeto GP - Socios Menores
                            (Adriano).
                            
                25/04/2013 - Incluir campos dsnatura, cdufnatu para armazenar
                             na temp-table tt-relat-fis e na tt-crapass 
                             (Lucas R.)

                15/05/2014 - Alterar a busca de dsestcvl da tabela crapass 
                             para crapttl. (Douglas - Chamado 131253)
                             
                10/06/2014 - Troca do campo crapass.nmconjug 
                             por crapcje.nmconjug. 
                             (Chamado 117414) - (Tiago Castro - RKAM)

                27/06/2014 - Alterado o cdestcvl que estava na crapass.
                             (Douglas - Chamado 172401)

                07/08/2014 - Removido campo cdestcvl da busca do crapass.
                             (Douglas)
                
                10/06/2014 - Remover o campo nmconjug  da busca do crapttl
                             (Douglas)
                             
                28/01/2015 - #239097 Ajustes para cadastro de Resp. legal 
                             0 - menor/maior. (Carlos)
                             
                13/07/2015 - Reformulacao Cadastral (Gabriel-RKAM).     
                
                12/08/2015 - Projeto Reformulacao cadastral
                             Eliminado o campo nmdsecao (Tiago Castro - RKAM). 
                             
                05/10/2015 - Adicionado nova opção "J" para alteração apenas do cpf/cnpj e 
                             removido a possibilidade de alteração pela opção "X", conforme 
                             solicitado no chamado 321572 (Kelvin). 

                01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
				             Transferencia entre PAs (Heitor - RKAM)							 

				09/09/2016 - Alterado procedure Busca_Dados, retorno do parametro
						     aux_qtminast referente a quantidade minima de assinatura
						     conjunta, SD 514239 (Jean Michel).
			 
.............................................................................*/


/*............................... DEFINICOES ................................*/

{ sistema/generico/includes/b1wgen0052tt.i }
{ sistema/generico/includes/b1wgen0070tt.i }
{ sistema/generico/includes/b1wgen0072tt.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0060 AS HANDLE                                      NO-UNDO.
DEF VAR aux_nmconjug LIKE crapcje.nmconjug                          NO-UNDO.

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ) FORWARD.

FUNCTION BuscaIdade RETURNS INTEGER 
    ( INPUT par_dtnascto AS DATE,
      INPUT par_dtmvtolt AS DATE ) FORWARD.

/* Pre-Processador para controle de erros 'Progress' */
&SCOPED-DEFINE GET-MSG ERROR-STATUS:GET-MESSAGE(1)

/*........................... PROCEDURES EXTERNAS ...........................*/


/* ------------------------------------------------------------------------ */
/*                EFETUA A BUSCA DE DADOS DO ASSOCIADO                      */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapass.
    DEF OUTPUT PARAM TABLE FOR tt-operadoras-celular.
    DEF OUTPUT PARAM TABLE FOR tt-crapavt.
    DEF OUTPUT PARAM TABLE FOR tt-alertas.
    DEF OUTPUT PARAM TABLE FOR tt-bens.
    DEF OUTPUT PARAM TABLE FOR tt-crapcrl.

    DEF VAR h-b1wgen0058 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtmvtolt AS DATE                                    NO-UNDO.
	DEF VAR aux_qtminast AS INTE									NO-UNDO.

    ASSIGN par_dscritic = ""
           par_cdcritic = 0
           aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapass.
        EMPTY TEMP-TABLE tt-operadoras-celular.
        EMPTY TEMP-TABLE tt-crapavt.
        EMPTY TEMP-TABLE tt-alertas.
        EMPTY TEMP-TABLE tt-crapcrl.

        /* realiza a verificacao conforme a opcao selecionada */
        RUN Verifica_Dados
            (  INPUT par_cdcooper,
               INPUT par_nrdconta,
               INPUT par_cddopcao,
               INPUT par_idorigem,
              OUTPUT par_cdcritic,
              OUTPUT par_dscritic ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               LEAVE Busca.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Busca.

        CASE par_cddopcao:
            WHEN "C" OR WHEN "A" OR WHEN "X" OR WHEN "J" THEN DO:
                RUN Procura_Alertas 
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_cddopcao,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic,
                     OUTPUT TABLE tt-alertas ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       LEAVE Busca.
                    END.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Busca.
            END.
            WHEN "R" THEN DO:
                /* nao precisa dos dados do associado */
                ASSIGN aux_returnvl = "OK".
                LEAVE Busca.
            END.
        END CASE.

        /* Buscar operadores de celular */
        FOR EACH craptab WHERE craptab.cdcooper = 0            AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "USUARI"     AND
                               craptab.cdempres = 11           AND
                               craptab.cdacesso = "OPETELEFON" NO-LOCK:
                             
            CREATE tt-operadoras-celular.
            ASSIGN tt-operadoras-celular.cdopetfn = craptab.tpregist 
                   tt-operadoras-celular.nmopetfn = craptab.dstextab.
    
        END. 

        IF   par_cddopcao = "I"   THEN
             DO:
                 ASSIGN aux_returnvl = "OK".
                 LEAVE Busca.
             END.           

        /* carrega a temp-table com os dados do associado */
        RUN Pesquisa_Associado
            ( INPUT par_cdcooper,
              INPUT par_nrdconta,
              INPUT par_cddopcao,
             OUTPUT par_cdcritic,
             OUTPUT par_dscritic,
             OUTPUT TABLE tt-crapass ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               LEAVE Busca.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Busca.

        IF NOT VALID-HANDLE(h-b1wgen0058) THEN
           RUN sistema/generico/procedures/b1wgen0058.p 
               PERSISTENT SET h-b1wgen0058.

        RUN Busca_Dados IN h-b1wgen0058
            (INPUT par_cdcooper,
             INPUT 0,
             INPUT 0,
             INPUT par_cdoperad,
             INPUT par_nmdatela,
             INPUT 1,
             INPUT par_nrdconta,
             INPUT 0,
             INPUT YES,
             INPUT "C",
             INPUT 0,
             INPUT 0,
             INPUT ?,
            OUTPUT TABLE tt-crapavt,
            OUTPUT TABLE tt-bens,
			OUTPUT aux_qtminast,
            OUTPUT TABLE tt-erro) NO-ERROR.
        
        IF VALID-HANDLE(h-b1wgen0058) THEN
           DELETE OBJECT h-b1wgen0058.

        IF ERROR-STATUS:ERROR THEN
           DO:
              ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
              LEAVE Busca.

           END.
                
        IF RETURN-VALUE <> "OK" THEN
           LEAVE Busca.

        FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
        
        ASSIGN aux_dtmvtolt = crapdat.dtmvtolt.

        /* Busca responsaveis legais */
        FOR EACH crapcrl WHERE crapcrl.cdcooper = par_cdcooper         AND
                               crapcrl.nrctamen = par_nrdconta         AND
                               crapcrl.idseqmen = par_idseqttl 
                               NO-LOCK: 

            IF crapcrl.nrdconta <> 0 THEN
               DO: 
                   RUN Busca_Dados_Cto ( INPUT crapcrl.cdcooper,
                                         INPUT crapcrl.nrctamen,
                                         INPUT crapcrl.idseqmen,
                                         INPUT crapcrl.nrdconta,
                                         INPUT crapcrl.nrcpfcgc,
                                         INPUT aux_dtmvtolt,
                                         INPUT par_cddopcao,
                                         INPUT crapcrl.nrcpfmen,
                                         INPUT FALSE,
                                         INPUT par_nmdatela,
                                         OUTPUT aux_cdcritic,
                                         OUTPUT aux_dscritic ).
               END.
            ELSE
               DO: 
                   CREATE tt-crapcrl.
                   ASSIGN tt-crapcrl.cdcooper = crapcrl.cdcooper
                          tt-crapcrl.nrctamen = crapcrl.nrctamen
                          tt-crapcrl.nrcpfmen = crapcrl.nrcpfmen
                          tt-crapcrl.idseqmen = crapcrl.idseqmen
                          tt-crapcrl.nrdconta = crapcrl.nrdconta
                          tt-crapcrl.nrcpfcgc = crapcrl.nrcpfcgc
                          
                          tt-crapcrl.nmrespon = crapcrl.nmrespon
                          tt-crapcrl.nridenti = crapcrl.nridenti
                          tt-crapcrl.tpdeiden = crapcrl.tpdeiden
                          tt-crapcrl.dsorgemi = crapcrl.dsorgemi
                                                                
                          tt-crapcrl.cdufiden = crapcrl.cdufiden
                          tt-crapcrl.dtemiden = crapcrl.dtemiden
                          tt-crapcrl.dtnascin = crapcrl.dtnascin
                          tt-crapcrl.cddosexo = crapcrl.cddosexo
                          tt-crapcrl.cdestciv = crapcrl.cdestciv
                          tt-crapcrl.dsnacion = crapcrl.dsnacion
                          tt-crapcrl.dsnatura = crapcrl.dsnatura
                          tt-crapcrl.cdcepres = crapcrl.cdcepres
                          tt-crapcrl.dsendres = crapcrl.dsendres
                          tt-crapcrl.nrendres = crapcrl.nrendres
                          tt-crapcrl.dscomres = crapcrl.dscomres
                          tt-crapcrl.dsbaires = crapcrl.dsbaires
                          tt-crapcrl.nrcxpost = crapcrl.nrcxpost
                          tt-crapcrl.dscidres = crapcrl.dscidres
                          tt-crapcrl.dsdufres = crapcrl.dsdufres
                          tt-crapcrl.nmpairsp = crapcrl.nmpairsp
                          tt-crapcrl.nmmaersp = crapcrl.nmmaersp.
                  
                   /* Estado civil */
                   FOR FIRST gnetcvl FIELDS(rsestcvl)
                             WHERE gnetcvl.cdestcvl = tt-crapcrl.cdestciv 
                             NO-LOCK:
                       ASSIGN tt-crapcrl.dsestcvl = gnetcvl.rsestcvl.
                   END.

                   ASSIGN tt-crapcrl.nrdrowid = ROWID(crapcrl) 
                          tt-crapcrl.deletado = FALSE
                          tt-crapcrl.cddopcao = "C".

               END.


        END.
                   
        ASSIGN aux_returnvl = "OK".

        LEAVE Busca.
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */



/* ------------------------------------------------------------------------ */
/*           EFETUA A BUSCA DE DADOS DO ASSOCIADO PARA IMPRESSAO            */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Impressao :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-relat-cab.
    DEF OUTPUT PARAM TABLE FOR tt-relat-par.
    DEF OUTPUT PARAM TABLE FOR tt-relat-fis.
    DEF OUTPUT PARAM TABLE FOR tt-relat-jur.
    DEF OUTPUT PARAM TABLE FOR tt-relat-rep.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_contapal AS INTE                                    NO-UNDO.
    DEF VAR aux_qtpalavr AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdconta AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF BUFFER crabass FOR crapass.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    Impressao: DO ON ERROR UNDO Impressao, LEAVE Impressao:
        EMPTY TEMP-TABLE tt-relat-cab.
        EMPTY TEMP-TABLE tt-relat-par.
        EMPTY TEMP-TABLE tt-relat-fis.
        EMPTY TEMP-TABLE tt-relat-jur.
        EMPTY TEMP-TABLE tt-relat-rep.

        /* verifica se e possivel emitir o relatorio */
        RUN Verifica_Dados
            (  INPUT par_cdcooper,
               INPUT par_nrdconta,
               INPUT "R",
               INPUT par_idorigem,
              OUTPUT par_cdcritic,
              OUTPUT par_dscritic ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               LEAVE Impressao.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Impressao.

        FOR FIRST crapcop FIELDS(nmextcop dsendcop nrendcop 
                                 nmcidade nrdocnpj cdufdcop)
                          WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crapcop THEN
            DO:
               ASSIGN par_cdcritic = 651.
               LEAVE Impressao.
            END.

        FOR FIRST crapass FIELDS(inmatric nrmatric cdagenci inpessoa nrcpfcgc 
                                 nrdconta nmprimtl nrdocptl cdoedptl cdufdptl 
                                 dtemdptl dtnasctl dsnacion nrcadast 
                                 cdsexotl dtadmiss)
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN par_cdcritic = 9.
               LEAVE Impressao.
            END.
        
        FOR FIRST crapage FIELDS(nmresage)
                          WHERE crapage.cdcooper = par_cdcooper AND
                                crapage.cdagenci = crapass.cdagenci NO-LOCK:
        END.

        IF  NOT AVAILABLE crapage THEN
            DO:
               ASSIGN par_cdcritic = 15.
               LEAVE Impressao.
            END.

        ASSIGN aux_nrdconta = (IF  crapass.nrdconta = 0 THEN "0"
                               ELSE TRIM(STRING(STRING(crapass.nrdconta,
                                                       ">>>>>999"),
                                                "xxxx.xxx.x"))).

        DO WHILE TRUE:
            IF  TRIM(aux_nrdconta) BEGINS "." THEN
                ASSIGN SUBSTR(aux_nrdconta,1,1) = "".
            ELSE
                LEAVE.
        END.

        CREATE tt-relat-cab.
        ASSIGN
            /* f_cabecalho, f_cooperativa, f_assina */
            tt-relat-cab.nmextcop = crapcop.nmextcop
            tt-relat-cab.nmprimtl = crapass.nmprimtl
            tt-relat-cab.inpessoa = crapass.inpessoa
            tt-relat-cab.nrmatric = TRIM(STRING(STRING(crapass.nrmatric,
                                                       ">>>>>9"),"xxx.xxx"))
            tt-relat-cab.nrdconta = aux_nrdconta
            tt-relat-cab.nmcidade = TRIM(crapcop.nmcidade) + " " + 
                                    TRIM(crapcop.cdufdcop) + ","
            tt-relat-cab.dsendcop = crapcop.dsendcop + ", " +
                                    STRING(crapcop.nrendcop,"zz,zz9") + 
                                    " - " + crapcop.nmcidade
            tt-relat-cab.nrdocnpj = "CNPJ " + STRING(STRING
                                    (crapcop.nrdocnpj,"99999999999999"),
                                                     "xx.xxx.xxx/xxxx-xx").

        IF  crapass.nrmatric < 1000 THEN
            ASSIGN SUBSTR(tt-relat-cab.nrmatric,1,1) = "".

        /* f_termo */
        ASSIGN tt-relat-cab.dtadmiss = crapass.dtadmiss.

        /* dados para termo de parcelamento de capital */
        FOR FIRST crapsdc FIELDS(vllanmto dtrefere)
                            WHERE crapsdc.cdcooper = par_cdcooper AND
                                  crapsdc.nrdconta = par_nrdconta AND
                                  crapsdc.tplanmto = 2        NO-LOCK
                                  BY crapsdc.nrseqdig:

            /* f_autoriza */ 
            CREATE tt-relat-par.
            ASSIGN 
                tt-relat-par.nrmatric = tt-relat-cab.nrmatric
                tt-relat-par.nrdconta = aux_nrdconta 
                tt-relat-par.nmprimtl = crapass.nmprimtl
                tt-relat-par.vlparcel = STRING(crapsdc.vllanmto,"zzz,zz9.99")
                tt-relat-par.dtdebito = crapsdc.dtrefere.
        END.
                                
        FOR LAST crapsdc FIELDS(nrseqdig)
                            WHERE crapsdc.cdcooper = par_cdcooper AND
                                  crapsdc.nrdconta = par_nrdconta AND
                                  crapsdc.tplanmto = 2        NO-LOCK
                                  BY crapsdc.nrseqdig:

            ASSIGN tt-relat-par.dsdprazo = STRING(crapsdc.nrseqdig - 1,"99").
        END.

        IF  AVAILABLE tt-relat-par AND DECIMAL(tt-relat-par.vlparcel) <> 0 THEN
            DO:
               IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                   RUN sistema/generico/procedures/b1wgen9999.p
                       PERSISTENT SET h-b1wgen9999.

               RUN valor-extenso IN h-b1wgen9999
                   ( INPUT DEC(tt-relat-par.vlparcel),
                     INPUT 52,
                     INPUT 65,
                     INPUT "M",
                    OUTPUT tt-relat-par.dsparcel[1],
                    OUTPUT tt-relat-par.dsparcel[2] ).

               DELETE OBJECT h-b1wgen9999.

               ASSIGN 
                   tt-relat-par.dsparcel[1] = "(" + tt-relat-par.dsparcel[1]
                   tt-relat-par.dsparcel[2] = tt-relat-par.dsparcel[2] + ")".
            END.

        /* f_assina */
        ASSIGN tt-relat-cab.dtmvtolt = par_dtmvtolt.

        ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ") / 2.

        DO aux_contapal = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):

           IF  aux_contapal <= aux_qtpalavr THEN
               ASSIGN tt-relat-cab.nmrescop[1] = tt-relat-cab.nmrescop[1] +   
                                   (IF TRIM(tt-relat-cab.nmrescop[1]) = "" 
                                    THEN "" ELSE " ") + 
                                   ENTRY(aux_contapal,crapcop.nmextcop," ").
           ELSE
               ASSIGN tt-relat-cab.nmrescop[2] = tt-relat-cab.nmrescop[2] +
                                   (IF TRIM(tt-relat-cab.nmrescop[2]) = "" 
                                    THEN "" ELSE " ") +
                                   ENTRY(aux_contapal,crapcop.nmextcop," ").
        END.  /*  Fim DO .. TO  */ 

        ASSIGN 
            tt-relat-cab.nmrescop[1] = FILL(
                " ",15 - INT(LENGTH(tt-relat-cab.nmrescop[1]) / 2)
                ) + tt-relat-cab.nmrescop[1]
            tt-relat-cab.nmrescop[2] = FILL(
                " ",15 - INT(LENGTH(tt-relat-cab.nmrescop[2]) / 2)
                ) + tt-relat-cab.nmrescop[2].

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p
                PERSISTENT SET h-b1wgen0060.
                
        FIND  crapcje WHERE crapcje.cdcooper = par_cdcooper AND 
                            crapcje.nrdconta = crapass.nrdconta AND 
                            crapcje.idseqttl = 1 USE-INDEX crapcje1 NO-ERROR.
        IF AVAILABLE crapcje THEN
          ASSIGN aux_nmconjug = crapcje.nmconjug.

        CASE tt-relat-cab.inpessoa:
            WHEN 1 THEN DO:
                CREATE tt-relat-fis.
                ASSIGN
                    tt-relat-fis.cdagenci = crapass.cdagenci
                    tt-relat-fis.nrdconta = aux_nrdconta
                    tt-relat-fis.nmprimtl = crapass.nmprimtl
                    tt-relat-fis.nrdocptl = crapass.nrdocptl
                    tt-relat-fis.cdoedptl = crapass.cdoedptl
                    tt-relat-fis.cdufdptl = crapass.cdufdptl
                    tt-relat-fis.dtemdptl = crapass.dtemdptl
                    tt-relat-fis.dtnasctl = crapass.dtnasctl
                    tt-relat-fis.dsnacion = crapass.dsnacion
                    tt-relat-fis.nrcadast = (IF  crapass.nrcadast = 0 THEN "0"
                                             ELSE TRIM(STRING(
                                                       STRING(crapass.nrcadast,
                                                             ">>>>>>>9"),
                                                      "xxxx.xxx.x")))
                    tt-relat-fis.nmconjug = aux_nmconjug
                    tt-relat-fis.nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,
                                                          "99999999999"),
                                                          "xxx.xxx.xxx-xx")
                    tt-relat-fis.cdsexotl = IF crapass.cdsexotl = 1 
                                            THEN "M" ELSE "F".

                DO WHILE TRUE:
                    IF  TRIM(tt-relat-fis.nrcadast) BEGINS "." THEN
                        ASSIGN SUBSTR(tt-relat-fis.nrcadast,1,1) = "".
                    ELSE
                        LEAVE.
                END.

                FOR FIRST crapttl FIELDS(nmmaettl nmpaittl cdturnos cdestcvl
                                         cdocpttl cdempres dsnatura cdufnatu)
                                  WHERE crapttl.cdcooper = par_cdcooper AND
                                        crapttl.nrdconta = par_nrdconta AND
                                        crapttl.idseqttl = 1 NO-LOCK:
                    ASSIGN
                        tt-relat-fis.nmmaettl = crapttl.nmmaettl 
                        tt-relat-fis.nmpaittl = crapttl.nmpaittl
                        tt-relat-fis.cdturnos = crapttl.cdturnos
                        tt-relat-fis.dsnatura = crapttl.dsnatura
                        tt-relat-fis.cdufnatu = crapttl.cdufnatu.

                    /* OCUPACAO */
                    DYNAMIC-FUNCTION("BuscaOcupacao" IN h-b1wgen0060,
                                     INPUT crapttl.cdocpttl,
                                    OUTPUT tt-relat-fis.dsocpttl,
                                    OUTPUT par_dscritic).
                    /* EMPRESA */
                    DYNAMIC-FUNCTION("BuscaEmpresa" IN h-b1wgen0060,
                                     INPUT par_cdcooper,
                                     INPUT crapttl.cdempres,
                                    OUTPUT tt-relat-fis.nmempres,
                                    OUTPUT par_dscritic).

                    /* ESTADO CIVIL */
                    DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                                     INPUT crapttl.cdestcvl,
                                     INPUT "dsestcvl",
                                    OUTPUT tt-relat-fis.dsestcvl,
                                    OUTPUT par_dscritic).

                    IF  tt-relat-fis.dsestcvl = "" THEN
                        ASSIGN tt-relat-fis.dsestcvl = "NAO INFORMADO".

                END.

                IF  tt-relat-fis.dsocpttl = "" THEN
                    ASSIGN tt-relat-fis.dsocpttl = "DESCONHEC.".

                IF  tt-relat-fis.nmempres = "" THEN
                    ASSIGN tt-relat-fis.nmempres = "NAO ENCONTRADA".

                FOR FIRST crapenc FIELDS(dsendere nrendere complend nmbairro
                                         nmcidade cdufende nrcepend)
                                  WHERE crapenc.cdcooper = par_cdcooper AND
                                        crapenc.nrdconta = par_nrdconta AND
                                        crapenc.idseqttl = 1            AND
                                        crapenc.cdseqinc = 1       NO-LOCK:
                    ASSIGN
                        tt-relat-fis.dsendere = crapenc.dsendere
                        tt-relat-fis.nrendere = STRING(crapenc.nrendere,
                                                       "zzz,zz9")
                        tt-relat-fis.complend = crapenc.complend
                        tt-relat-fis.nmbairro = crapenc.nmbairro
                        tt-relat-fis.nmcidade = crapenc.nmcidade
                        tt-relat-fis.cdufende = crapenc.cdufende
                        tt-relat-fis.nrcepend = STRING(STRING(crapenc.nrcepend,
                                                       ">>>>>>>9"),
                                                       "xx.xxx.xx9").

                    DO WHILE TRUE:
                        IF  TRIM(tt-relat-fis.nrcepend) BEGINS "." THEN
                            ASSIGN SUBSTR(tt-relat-fis.nrcepend,1,1) = "".
                        ELSE
                            LEAVE.
                    END.
                END.

                /* PAC */
                DYNAMIC-FUNCTION("BuscaPac" IN h-b1wgen0060,
                                 INPUT par_cdcooper,
                                 INPUT tt-relat-fis.cdagenci,
                                 INPUT "nmresage",
                                OUTPUT tt-relat-fis.nmresage,
                                OUTPUT par_dscritic).

            END.
            OTHERWISE DO:
                CREATE tt-relat-jur.
                ASSIGN 
                    tt-relat-jur.cdagenci = crapass.cdagenci
                    tt-relat-jur.nrdconta = aux_nrdconta
                    tt-relat-jur.nmprimtl = crapass.nmprimtl
                    tt-relat-jur.nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,
                                                   "99999999999999"),
                                                   "xx.xxx.xxx/xxxx-xx").

                /* Dados da pessoa juridica */
                FOR FIRST crapjur FIELDS(nmfansia dtiniatv cdrmativ natjurid 
                                         nrinsest cdseteco cdrmativ)
                                  WHERE crapjur.cdcooper = par_cdcooper AND
                                        crapjur.nrdconta = par_nrdconta 
                                        NO-LOCK:
                    ASSIGN 
                        tt-relat-jur.nmfansia = crapjur.nmfansia
                        tt-relat-jur.dtiniatv = crapjur.dtiniatv
                        tt-relat-jur.cdrmativ = crapjur.cdrmativ
                        tt-relat-jur.nrinsest = (IF crapjur.nrinsest <> 0 
                                                 THEN STRING(
                                                     crapjur.nrinsest,
                                                     "zzz,zzz,zzz,zzz,9")
                                                 ELSE "ISENTO").

                    /* NATUREZA JURIDICA */
                    DYNAMIC-FUNCTION("BuscaNaturezaJuridica" IN h-b1wgen0060,
                                      INPUT crapjur.natjurid,
                                      INPUT "rsnatjur",
                                     OUTPUT tt-relat-jur.rsnatjur,
                                     OUTPUT par_dscritic).

                    /* RAMO DE ATIVIDADE */
                    DYNAMIC-FUNCTION("BuscaRamoAtividade" IN h-b1wgen0060,
                                     INPUT crapjur.cdseteco,
                                     INPUT crapjur.cdrmativ,
                                    OUTPUT tt-relat-jur.dsrmativ,
                                    OUTPUT par_dscritic).
                END.

                IF  tt-relat-jur.rsnatjur = "" THEN
                    ASSIGN tt-relat-jur.rsnatjur = "Nao cadastrado".

                IF  tt-relat-jur.dsrmativ = "" THEN
                    ASSIGN tt-relat-jur.dsrmativ = "NAO CADASTRADO".
    
                /* Endereco */
                FOR FIRST crapenc FIELDS(dsendere nrendere complend nmbairro
                                         nmcidade cdufende nrcepend)
                                  WHERE crapenc.cdcooper = par_cdcooper AND
                                        crapenc.nrdconta = par_nrdconta AND
                                        crapenc.idseqttl = 1            AND
                                        crapenc.cdseqinc = 1       NO-LOCK:
                    ASSIGN
                        tt-relat-jur.dsendere = crapenc.dsendere
                        tt-relat-jur.nrendere = STRING(crapenc.nrendere,
                                                       "zzz,zz9")
                        tt-relat-jur.complend = crapenc.complend
                        tt-relat-jur.nmbairro = crapenc.nmbairro
                        tt-relat-jur.nmcidade = crapenc.nmcidade
                        tt-relat-jur.cdufende = crapenc.cdufende
                        tt-relat-jur.nrcepend = STRING(STRING(crapenc.nrcepend,
                                                       ">>>>>>>9"),
                                                       "xx.xxx.xx9").
                    DO WHILE TRUE:
                        IF  TRIM(tt-relat-jur.nrcepend) BEGINS "." THEN
                            ASSIGN SUBSTR(tt-relat-jur.nrcepend,1,1) = "".
                        ELSE
                            LEAVE.
                    END.
                END.

                /* Telefone e DDD */
                FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                                  WHERE craptfc.cdcooper = par_cdcooper AND
                                        craptfc.nrdconta = par_nrdconta AND
                                        craptfc.idseqttl = 1 NO-LOCK:

                    ASSIGN 
                        tt-relat-jur.nrdddtfc = craptfc.nrdddtfc
                        tt-relat-jur.nrtelefo = craptfc.nrtelefo.
                END.

                /* PAC */
                DYNAMIC-FUNCTION("BuscaPac" IN h-b1wgen0060,
                                 INPUT par_cdcooper,
                                 INPUT tt-relat-jur.cdagenci,
                                 INPUT "nmresage",
                                OUTPUT tt-relat-jur.nmresage,
                                OUTPUT par_dscritic).

                /* Representantes */
                FOR EACH crapavt FIELDS(dsproftl nrcpfcgc nrdctato nmdavali)
                                 WHERE crapavt.cdcooper = par_cdcooper    AND
                                       crapavt.tpctrato = 6 /*juridica*/  AND
                                       crapavt.nrdconta = par_nrdconta NO-LOCK:

                    CREATE tt-relat-rep.
                    ASSIGN 
                        tt-relat-rep.dsproftl = crapavt.dsproftl
                        tt-relat-rep.nrcpfcgc = STRING(STRING
                                                       (crapavt.nrcpfcgc,
                                                        "99999999999"),
                                                       "XXX.XXX.XXX-XX")
                        tt-relat-rep.nrdconta = aux_nrdconta.

                    IF  crapavt.nrdctato <> 0 THEN
                        DO:
                           FOR FIRST crabass FIELDS(nmprimtl)
                               WHERE crabass.cdcooper = par_cdcooper   AND
                                     crabass.nrdconta = crapavt.nrdctato 
                                     NO-LOCK:
                           END.

                           IF  AVAILABLE crabass THEN
                               ASSIGN tt-relat-rep.nmdavali = crabass.nmprimtl.
                           ELSE
                               ASSIGN tt-relat-rep.nmdavali = "NAO ENCONTRADO".
                        END.
                    ELSE
                        ASSIGN tt-relat-rep.nmdavali = crapavt.nmdavali.
                END.
            END.
        END CASE.

        ASSIGN aux_returnvl = "OK".

        LEAVE Impressao.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  VALID-HANDLE(h-b1wgen9999) THEN
        DELETE OBJECT h-b1wgen9999.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Impressao */

/* ------------------------------------------------------------------------ */
/*               BUSCA OS DADOS DOS PROCURADORES DO ASSOCIADO               */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Procurador :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapavt.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DEC                                     NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabavt FOR crapavt.

    ASSIGN par_dscritic = ""
           par_cdcritic = 0
           aux_returnvl = "NOK".

    Procurador: DO ON ERROR UNDO Procurador, LEAVE Procurador:
        EMPTY TEMP-TABLE tt-crapavt.

        IF  par_cddopcao = "C" THEN
            DO:
               FOR EACH crabavt WHERE crabavt.cdcooper = par_cdcooper AND
                                      crabavt.tpctrato = 6 /*jur*/    AND
                                      crabavt.nrdconta = par_nrdconta NO-LOCK:
    
                   IF  par_nrdrowid <> ? AND 
                       (ROWID(crabavt) <> par_nrdrowid) THEN
                       NEXT.
    
                   CREATE tt-crapavt.
                   BUFFER-COPY crabavt TO tt-crapavt.

                   ASSIGN tt-crapavt.rowidavt = ROWID(crabavt)
                          tt-crapavt.cddctato = (IF  crabavt.nrdctato = 0 THEN 
                                                     "0"
                                                 ELSE 
                                                     TRIM(STRING(STRING
                                                           (crabavt.nrdctato,
                                                            ">>>>>999"),
                                                           "XXXX.XXX.X")))
                          tt-crapavt.cdcpfcgc = STRING(STRING(tt-crapavt.nrcpfcgc,
                                                          "99999999999"),
                                                       "xxx.xxx.xxx-xx")
                          tt-crapavt.dsvalida = IF crabavt.dtvalida = 12/31/9999
                                                THEN "INDETERMI." 
                                                ELSE STRING(crabavt.dtvalida,
                                                           "99/99/9999") NO-ERROR.
    
                   IF  ERROR-STATUS:ERROR THEN
                       DO:
                          ASSIGN par_dscritic = {&GET-MSG}.
                          UNDO Procurador, LEAVE Procurador.
                       END.
    
                    DO WHILE TRUE:
                        IF  tt-crapavt.cddctato BEGINS "." THEN
                            ASSIGN SUBSTR(tt-crapavt.cddctato,1,1) = "".
                        ELSE
                            LEAVE.
                    END.
    
                   /* Se for associado, pega os dados da crapass */
                   IF  tt-crapavt.nrdctato <> 0 THEN
                       DO:
                          FOR FIRST crabass FIELDS(nmprimtl nrcpfcgc nrdocptl 
                                                   tpdocptl cdoedptl cdufdptl 
                                                   dtemdptl)
                              WHERE crabass.cdcooper = par_cdcooper  AND
                                    crabass.nrdconta = tt-crapavt.nrdctato 
                                    NO-LOCK:
    
                              ASSIGN 
                                  tt-crapavt.nmdavali = crabass.nmprimtl
                                  tt-crapavt.nrcpfcgc = crabass.nrcpfcgc
                                  tt-crapavt.tpdocava = crabass.tpdocptl
                                  tt-crapavt.nrdocava = crabass.nrdocptl
                                  tt-crapavt.cdoeddoc = crabass.cdoedptl
                                  tt-crapavt.cdufddoc = crabass.cdufdptl
                                  tt-crapavt.dtemddoc = crabass.dtemdptl
                                  tt-crapavt.cdcpfcgc = STRING(
                                      STRING(crabass.nrcpfcgc,"99999999999"),
                                      "xxx.xxx.xxx-xx") NO-ERROR.
    
                              IF  ERROR-STATUS:ERROR THEN
                                  DO:
                                     ASSIGN par_dscritic = {&GET-MSG}.
                                     UNDO Procurador, LEAVE Procurador.
                                  END.
                          END.
                       END.
               END.
    
               /* se informou o rowid deve obrigatoriamente retornar 
                  registro valido */
               IF  par_nrdrowid <> ? AND 
                   NOT TEMP-TABLE tt-crapavt:HAS-RECORDS THEN
                   DO:
                      ASSIGN par_dscritic = "Cadastro do Representante/" + 
                                            "Procurador nao foi encontrado.".
                      LEAVE Procurador.
                   END.
            END.
        ELSE 
            DO:
               IF  par_nrdctato <> 0 THEN
                   DO:
                      FOR FIRST crabass FIELDS(nmprimtl nrcpfcgc nrdocptl 
                                               tpdocptl cdoedptl cdufdptl 
                                               dtemdptl nrdconta inpessoa)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdctato NO-LOCK:
    
                          IF  crabass.inpessoa <> 1 THEN
                              DO:
                                 ASSIGN par_cdcritic = 833.
                                 LEAVE Procurador.
                              END.
    
                          CREATE tt-crapavt.
                          ASSIGN 
                              tt-crapavt.cddctato = (IF  crabass.nrdconta = 0 
                                                     THEN "0"
                                                     ELSE TRIM(STRING(STRING
                                                          (crabass.nrdconta,
                                                           ">>>>>999"),
                                                           "XXXX.XXX.X")))
                              tt-crapavt.nrdctato = crabass.nrdconta
                              tt-crapavt.nmdavali = crabass.nmprimtl
                              tt-crapavt.nrcpfcgc = crabass.nrcpfcgc
                              tt-crapavt.tpdocava = crabass.tpdocptl
                              tt-crapavt.nrdocava = crabass.nrdocptl
                              tt-crapavt.cdoeddoc = crabass.cdoedptl
                              tt-crapavt.cdufddoc = crabass.cdufdptl
                              tt-crapavt.dtemddoc = crabass.dtemdptl
                              tt-crapavt.cdcpfcgc = STRING(STRING
                                                     (tt-crapavt.nrcpfcgc,
                                                      "99999999999"),
                                                           "xxx.xxx.xxx-xx") 
                              aux_nrcpfcgc        = crabass.nrcpfcgc NO-ERROR.
    
                          IF  ERROR-STATUS:ERROR THEN
                              DO:
                                 ASSIGN par_dscritic = {&GET-MSG}.
                                 UNDO Procurador, LEAVE Procurador.
                              END.
    
                          DO WHILE TRUE:
                              IF  tt-crapavt.cddctato BEGINS "." THEN
                                  ASSIGN SUBSTR(tt-crapavt.cddctato,1,1) = "".
                              ELSE
                                  LEAVE.
                          END.
                      END.
    
                      IF  NOT AVAILABLE crabass THEN
                          DO:
                             ASSIGN par_cdcritic = 9.
                             UNDO Procurador, LEAVE Procurador.
                          END.
    
                   END.
               ELSE
               IF  par_nrcpfcto <> 0 THEN
                   DO:
                      ASSIGN aux_nrcpfcgc = par_nrcpfcto.

                      FOR EACH crabass FIELDS(nmprimtl nrcpfcgc nrdocptl 
                                              tpdocptl cdoedptl cdufdptl 
                                              dtemdptl nrdconta inpessoa)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrcpfcgc = par_nrcpfcto NO-LOCK,
                          FIRST craptip FIELDS(cdtipcta dstipcta)
                          WHERE craptip.cdcooper = crabass.cdcooper AND
                                craptip.cdtipcta = crabass.cdtipcta NO-LOCK:
    
                          IF  crabass.inpessoa <> 1 THEN
                              DO:
                                 ASSIGN par_cdcritic = 833.
                                 LEAVE Procurador.
                              END.
    
                          CREATE tt-crapavt.
    
                          ASSIGN 
                              tt-crapavt.cddctato = (IF  crabass.nrdconta = 0 
                                                     THEN "0"
                                                     ELSE TRIM(STRING(STRING
                                                          (crabass.nrdconta,
                                                           ">>>>>999"),
                                                           "XXXX.XXX.X")))
                              tt-crapavt.nrdctato = crabass.nrdconta
                              tt-crapavt.nmdavali = crabass.nmprimtl
                              tt-crapavt.nrcpfcgc = crabass.nrcpfcgc
                              tt-crapavt.tpdocava = crabass.tpdocptl
                              tt-crapavt.nrdocava = crabass.nrdocptl
                              tt-crapavt.cdoeddoc = crabass.cdoedptl
                              tt-crapavt.cdufddoc = crabass.cdufdptl
                              tt-crapavt.dtemddoc = crabass.dtemdptl
                              tt-crapavt.cdcpfcgc = STRING(STRING
                                                     (tt-crapavt.nrcpfcgc,
                                                      "99999999999"),
                                                           "xxx.xxx.xxx-xx") 
                              tt-crapavt.dstipcta = STRING(craptip.cdtipcta) 
                                                    + "-" + craptip.dstipcta
                              aux_nrcpfcgc        = crabass.nrcpfcgc NO-ERROR.
    
                          IF  ERROR-STATUS:ERROR THEN
                              DO:
                                 ASSIGN par_dscritic = {&GET-MSG}.
                                 UNDO Procurador, LEAVE Procurador.
                              END.
    
                          DO WHILE TRUE:
                              IF  tt-crapavt.cddctato BEGINS "." THEN
                                  ASSIGN SUBSTR(tt-crapavt.cddctato,1,1) = "".
                              ELSE
                                  LEAVE.
                          END.
                      END.
                   END.
    
               /* Verifica se o procurador ja foi cadastrado */
               IF  CAN-FIND(crapavt WHERE
                            crapavt.cdcooper = par_cdcooper AND
                            crapavt.tpctrato = 6 /* jur */  AND
                            crapavt.nrdconta = par_nrdconta AND
                            crapavt.nrctremp = 0            AND
                            crapavt.nrcpfcgc = aux_nrcpfcgc) AND
                   par_cddopcao = "I" AND aux_nrcpfcgc <> 0 THEN
                   DO:
                      ASSIGN par_dscritic = "Procurador ja cadastrado " +
                                            "para o associado.".
                      UNDO Procurador, LEAVE Procurador.
                   END.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Procurador.
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Procurador */

/*........................ PROCEDURES INTERNAS/PRIVADAS ....................*/

/* ------------------------------------------------------------------------ */
/*            CRIA A TEMP-TABLE DE ALERTAS DA CONTA DO ASSOCIADO            */
/* ------------------------------------------------------------------------ */
PROCEDURE Cria_Alerta PRIVATE :

    DEF  INPUT PARAM par_cdalerta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsalerta AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_qtdpausa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpalerta AS CHAR                           NO-UNDO.

    DEF BUFFER btt-alertas FOR tt-alertas.

    DO ON ERROR UNDO, LEAVE:

        IF  par_cdalerta = 0 THEN
            DO:
               FIND LAST btt-alertas NO-ERROR.

               IF  AVAILABLE btt-alertas THEN
                   ASSIGN par_cdalerta = btt-alertas.cdalerta + 1.
               ELSE
                   ASSIGN par_cdalerta = 0.
            END.

        CREATE tt-alertas.
        ASSIGN 
            tt-alertas.cdalerta = par_cdalerta
            tt-alertas.dsalerta = par_dsalerta
            tt-alertas.qtdpausa = par_qtdpausa
            tt-alertas.tpalerta = par_tpalerta.
    END.

    RETURN "OK".

END PROCEDURE. /* Cria_Alerta */

/* ------------------------------------------------------------------------ */
/*            EFETUA A BUSCA DE DADOS DO DO CADASTRO DO ASSOCIADO           */
/* ------------------------------------------------------------------------ */
PROCEDURE Pesquisa_Associado PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapass.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabalt FOR crapalt.
    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER crabjur FOR crapjur.
    DEF BUFFER crabenc FOR crapenc.
    DEF BUFFER crabtfc FOR craptfc.

    &SCOPED-DEFINE CAMPOS-ENC nrcepend dsendere nrendere complend~
                              nmbairro nmcidade cdufende nrcxapst
    &SCOPED-DEFINE CAMPOS-TTL tpnacion cdocpttl nmpaittl~
                              nmmaettl dthabmen inhabmen~
                              idseqttl
    &SCOPED-DEFINE CAMPOS-JUR nmfansia nrinsest natjurid dtiniatv~
                              cdseteco cdrmativ

    ASSIGN par_dscritic = ""
           par_cdcritic = 0
           aux_returnvl = "NOK".

    PesquisaAss: DO ON ERROR UNDO PesquisaAss, LEAVE PesquisaAss:

        FIND crabass WHERE crabass.cdcooper = par_cdcooper AND
                           crabass.nrdconta = par_nrdconta 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crabass THEN
            DO:
               IF  par_cddopcao <> "C" THEN
                   ASSIGN par_cdcritic = 9.

               LEAVE PesquisaAss.
            END.

        /* Procura registro de recadastramento */
        FOR LAST crabalt FIELDS(dtaltera)
                         WHERE crabalt.cdcooper = par_cdcooper   AND
                               crabalt.nrdconta = par_nrdconta   AND
                               crabalt.tpaltera = 1 
                               NO-LOCK:
        END.

        CREATE tt-crapass.

        BUFFER-COPY crabass TO tt-crapass 

        ASSIGN tt-crapass.rowidass = ROWID(crabass)
               tt-crapass.cddconta = (IF  crabass.nrdconta = 0 THEN 
                                          "0"
                                      ELSE 
                                          TRIM(STRING(STRING
                                                (crabass.nrdconta,
                                                 ">>>>>999"),
                                                "XXXX.XXX.X")))
               tt-crapass.cdagepac = crabass.cdagenci
               tt-crapass.cdclcnae = crabass.cdclcnae
               tt-crapass.dtaltera = (IF AVAILABLE crabalt 
                                      THEN crabalt.dtaltera ELSE ?) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = {&GET-MSG}.
               LEAVE PesquisaAss.
            END.

        DO WHILE TRUE:

            IF  tt-crapass.cddconta BEGINS "." THEN
                ASSIGN SUBSTR(tt-crapass.cddconta,1,1) = "".
            ELSE
                LEAVE.

        END.

        FOR FIRST crapdat FIELDS(dtmvtoan)
                          WHERE crapdat.cdcooper = par_cdcooper 
                                NO-LOCK:

            ASSIGN tt-crapass.dtmvtoan = crapdat.dtmvtoan.

        END.

        FOR FIRST crapttl FIELDS(dsnatura cdufnatu)
                                  WHERE crapttl.cdcooper = par_cdcooper AND
                                        crapttl.nrdconta = par_nrdconta AND
                                        crapttl.idseqttl = 1 NO-LOCK:

           
            ASSIGN tt-crapass.cdufnatu = crapttl.cdufnatu
                   tt-crapass.dsnatura = crapttl.dsnatura.
        END.

        /* buscar o endereco, 10 = Residencial (PF) 9 = Comercial (PJ) */
        FOR FIRST crabenc FIELDS({&CAMPOS-ENC} idorigem)
                          WHERE crabenc.cdcooper = tt-crapass.cdcooper AND  
                                crabenc.nrdconta = tt-crapass.nrdconta AND  
                                crabenc.idseqttl = 1                   AND  
                                crabenc.cdseqinc = 1                   AND  
                                crabenc.tpendass = (IF tt-crapass.inpessoa = 1
                                                    THEN 10 ELSE 9) 
                                NO-LOCK:

            BUFFER-COPY crabenc USING {&CAMPOS-ENC} TO tt-crapass.
            
            ASSIGN  tt-crapass.idorigee = crabenc.idorigem.

        END.

        /* Buscar o email */
        FOR FIRST crapcem FIELDS(dsdemail)
                         WHERE crapcem.cdcooper = par_cdcooper AND
                               crapcem.nrdconta = par_nrdconta AND
                               crapcem.idseqttl = 1 NO-LOCK:
           
            ASSIGN  tt-crapass.rowidcem = ROWID(crapcem)
                    tt-crapass.dsdemail = crapcem.dsdemail.

        END.

        /* Buscar o telefone Residencial */
        FIND FIRST craptfc WHERE craptfc.cdcooper = tt-crapass.cdcooper  AND
                                 craptfc.nrdconta = tt-crapass.nrdconta  AND
                                 craptfc.idseqttl = 1                    AND
                                 craptfc.tptelefo = 1                  
                                 NO-LOCK NO-ERROR.

        IF   AVAIL craptfc   THEN /*  */
             ASSIGN tt-crapass.nrdddres = craptfc.nrdddtfc
                    tt-crapass.nrtelres = craptfc.nrtelefo.

        /* Buscar o telefone Celular */
        FIND FIRST craptfc WHERE craptfc.cdcooper = tt-crapass.cdcooper  AND
                                 craptfc.nrdconta = tt-crapass.nrdconta  AND
                                 craptfc.idseqttl = 1                    AND
                                 craptfc.tptelefo = 2                  
                                 NO-LOCK NO-ERROR.
                              
        IF   AVAIL craptfc   THEN
             ASSIGN tt-crapass.nrdddcel = craptfc.nrdddtfc
                    tt-crapass.nrtelcel = craptfc.nrtelefo
                    tt-crapass.cdopetfn = craptfc.cdopetfn.
               
        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        /* Motivo de demissao */
        DYNAMIC-FUNCTION("BuscaMotivoDemi" IN h-b1wgen0060,
                          INPUT tt-crapass.cdcooper,
                          INPUT tt-crapass.cdmotdem,
                         OUTPUT tt-crapass.dsmotdem,
                         OUTPUT par_dscritic).

        IF  tt-crapass.dsmotdem = "NAO CADASTRADO" THEN
            ASSIGN tt-crapass.dsmotdem = "".

        /* PAC */
        DYNAMIC-FUNCTION("BuscaPac" IN h-b1wgen0060,
                          INPUT tt-crapass.cdcooper,
                          INPUT tt-crapass.cdagenci,
                          INPUT "nmresage",
                         OUTPUT tt-crapass.nmresage,
                         OUTPUT par_dscritic).

        IF  tt-crapass.nmresage = "" THEN
            ASSIGN tt-crapass.nmresage = "NAO CADASTRADO".

        /* Situacao CPF/CNPJ */
        DYNAMIC-FUNCTION("BuscaSituacaoCpf" IN h-b1wgen0060,
                          INPUT tt-crapass.cdsitcpf,
                         OUTPUT tt-crapass.dssitcpf,
                         OUTPUT par_dscritic).

        ASSIGN par_dscritic = "".

        CASE tt-crapass.inpessoa:
            WHEN 1 THEN DO:
                ASSIGN tt-crapass.dspessoa = "FISICA".

                FOR FIRST crabttl FIELDS({&CAMPOS-TTL} cdempres)
                                  WHERE crabttl.cdcooper = par_cdcooper AND
                                        crabttl.nrdconta = par_nrdconta AND
                                        crabttl.idseqttl = 1       
                                        NO-LOCK:
                END.

                IF  NOT AVAILABLE crabttl THEN
                    DO:
                       ASSIGN par_dscritic = "Dados do Titular nao foram " + 
                                             "encontrados.".
                       LEAVE PesquisaAss.
                    END.

                BUFFER-COPY crabttl USING {&CAMPOS-TTL} TO tt-crapass 

                ASSIGN tt-crapass.cddempre = crabttl.cdempres 
                       tt-crapass.inhabmen = crabttl.inhabmen NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = {&GET-MSG}.
                       LEAVE PesquisaAss.
                    END.

                IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                    RUN sistema/generico/procedures/b1wgen9999.p 
                        PERSISTENT SET h-b1wgen9999.
             
                RUN idade IN h-b1wgen9999 (INPUT crabass.dtnasctl,
                                           INPUT TODAY,
                                           OUTPUT tt-crapass.nrdeanos,
                                           OUTPUT tt-crapass.nrdmeses,
                                           OUTPUT tt-crapass.dsdidade).
             
                DELETE OBJECT h-b1wgen9999.
                
                /* Atualizamos o codigo do estado civil */
                ASSIGN tt-crapass.cdestcv2 = crabttl.cdestcvl.
                /* Estado civil */
                DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                                  INPUT tt-crapass.cdestcv2,
                                  INPUT "rsestcvl",
                                 /* Alterado para o novo campo */
                                 OUTPUT tt-crapass.dsestcv2,
                                 OUTPUT par_dscritic).

                IF  tt-crapass.dsestcv2 = "" THEN
                    ASSIGN tt-crapass.dsestcv2 = "NAO CADASTRADO".

                /* Tipo da Nacionalidade */
                DYNAMIC-FUNCTION("BuscaTipoNacion" IN h-b1wgen0060,
                                  INPUT tt-crapass.tpnacion,
                                  INPUT "destpnac",
                                 OUTPUT tt-crapass.destpnac,
                                 OUTPUT par_dscritic).

                IF  tt-crapass.destpnac = "" OR
                    tt-crapass.destpnac MATCHES ("*NAO CADASTRAD*") THEN
                    ASSIGN tt-crapass.destpnac = "DESCONHECIDA".

                /* Empresa */
                DYNAMIC-FUNCTION("BuscaEmpresa" IN h-b1wgen0060,
                                  INPUT tt-crapass.cdcooper,
                                  INPUT tt-crapass.cddempre,
                                 OUTPUT tt-crapass.nmresemp,
                                 OUTPUT par_dscritic).

                IF  tt-crapass.nmresemp = "" THEN
                    ASSIGN tt-crapass.nmresemp = "NAO CADASTRADA".

                /* Ocupacao */
                DYNAMIC-FUNCTION("BuscaOcupacao" IN h-b1wgen0060,
                                  INPUT tt-crapass.cdocpttl,
                                 OUTPUT tt-crapass.dsocpttl,
                                 OUTPUT par_dscritic).

                IF  tt-crapass.dsocpttl = "" OR 
                    tt-crapass.dsocpttl MATCHES ("*NAO INFORMAD*") THEN
                    ASSIGN tt-crapass.dsocpttl = "DESCONHEC.".

                /* Buscar o nome do conjuge, caso exista*/
                FOR FIRST crapcje FIELDS(nmconjug)
                                  WHERE crapcje.cdcooper = par_cdcooper AND
                                        crapcje.nrdconta = par_nrdconta AND
                                        crapcje.idseqttl = 1       
                                        NO-LOCK:
                END.

                IF  AVAILABLE crapcje THEN
                    DO:
                       ASSIGN tt-crapass.nmconju = crapcje.nmconjug.
                    END.

                ASSIGN par_dscritic = "".

            END.

            WHEN 2 OR WHEN 3 THEN DO:

                IF  tt-crapass.inpessoa = 3 THEN
                    ASSIGN tt-crapass.dspessoa = "ADMINIST".
                ELSE ASSIGN tt-crapass.dspessoa = "JURIDICA".

                FOR FIRST crabjur FIELDS({&CAMPOS-JUR} nrlicamb)
                                  WHERE crabjur.cdcooper = par_cdcooper AND
                                        crabjur.nrdconta = par_nrdconta 
                                        NO-LOCK:
                END.

                IF  NOT AVAILABLE crabjur THEN
                    DO:
                       ASSIGN par_dscritic = "Dados da Pessoa Juridica nao " + 
                                             "foram encontrados.".
                       LEAVE PesquisaAss.
                    END.

                BUFFER-COPY crabjur USING {&CAMPOS-JUR} TO tt-crapass NO-ERROR.
                ASSIGN  tt-crapass.nrlicamb = crabjur.nrlicamb.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = {&GET-MSG}.
                       LEAVE PesquisaAss.
                    END.

                /* Telefone e DDD */
                FOR FIRST crabtfc FIELDS(nrtelefo nrdddtfc)
                                  WHERE crabtfc.cdcooper = par_cdcooper AND
                                        crabtfc.nrdconta = par_nrdconta AND
                                        crabtfc.idseqttl = 1       
                                        NO-LOCK:
                    ASSIGN tt-crapass.nrtelefo = crabtfc.nrtelefo
                           tt-crapass.nrdddtfc = crabtfc.nrdddtfc.

                END.

                /* Natureza Juridica */
                IF  tt-crapass.natjurid <> 0  THEN
                    DO:
                       DYNAMIC-FUNCTION("BuscaNaturezaJuridica" IN 
                                        h-b1wgen0060,
                                         INPUT tt-crapass.natjurid,
                                         INPUT "rsnatjur",
                                        OUTPUT tt-crapass.rsnatjur,
                                        OUTPUT par_dscritic).

                       IF  tt-crapass.rsnatjur = "" THEN
                           ASSIGN tt-crapass.rsnatjur = "NAO CADASTRADO".
                    END.

                /* Setor Economico */
                IF  tt-crapass.cdseteco <> 0 THEN
                    DO:
                       DYNAMIC-FUNCTION("BuscaSetorEconomico" IN h-b1wgen0060,
                                         INPUT tt-crapass.cdcooper,
                                         INPUT tt-crapass.cdseteco,
                                        OUTPUT tt-crapass.nmseteco,
                                        OUTPUT par_dscritic).
    
                       IF  tt-crapass.nmseteco = "" THEN
                           ASSIGN tt-crapass.nmseteco = "NAO CADASTRADO".
                    END.

                /* Ramo de Atividade */
                DYNAMIC-FUNCTION("BuscaRamoAtividade" IN h-b1wgen0060,
                                 INPUT tt-crapass.cdseteco,
                                 INPUT tt-crapass.cdrmativ,
                                OUTPUT tt-crapass.dsrmativ,
                                OUTPUT par_dscritic).

                IF  tt-crapass.dsrmativ = "" THEN
                    ASSIGN tt-crapass.dsrmativ = "NAO CADASTRADO".

                ASSIGN par_dscritic = "".
            END.
            OTHERWISE DO:
                ASSIGN par_dscritic = "Tipo de pessoa nao previsto, deve ser" +
                                      " 1-Fisica, 2-Juridica ou " +
                                      "0-Administrativa".
            END.
        END CASE.

        IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
            LEAVE PesquisaAss.

        ASSIGN aux_returnvl = "OK".

        LEAVE PesquisaAss.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Pesquisa_Associado */

/* ------------------------------------------------------------------------ */
/*            EFETUA A BUSCA DE ALERTAS DA CONTA DO ASSOCIADO               */
/* ------------------------------------------------------------------------ */
PROCEDURE Procura_Alertas PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-alertas.
        
    DEF VAR aux_cdsitdtl AS INTE                                    NO-UNDO.
    DEF VAR aux_dsalerta AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabtrf FOR craptrf.

    ASSIGN
        par_dscritic = "Erro na pesquisa dos alertas"
        par_cdcritic = 0
        aux_returnvl = "NOK".

    Alertas: DO ON ERROR UNDO Alertas, LEAVE Alertas:

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        /* Verifica se a conta foi transferida */
        FOR FIRST crabtrf FIELDS(nrsconta)
                          WHERE crabtrf.cdcooper = par_cdcooper AND
                                crabtrf.nrdconta = par_nrdconta AND
                                crabtrf.tptransa = 1            AND
                                crabtrf.insittrs = 2        NO-LOCK:

            ASSIGN aux_dsalerta = "Conta transferida para " + 
                                  TRIM(STRING(crabtrf.nrsconta,"zzzz,zzz,9")).
        END.

        ASSIGN aux_cdsitdtl = 0.

        FOR FIRST crabass FIELDS(cdsitdtl)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK:
            ASSIGN aux_cdsitdtl = crabass.cdsitdtl.
        END.

        /* Prejuizo na conta */
        IF  CAN-DO("5,6,7,8",STRING(aux_cdsitdtl)) THEN
            ASSIGN aux_dsalerta = aux_dsalerta + ";" + 
                                  DYNAMIC-FUNCTION("BuscaCritica" IN 
                                                   h-b1wgen0060, INPUT 695).

        /* Titular bloqueado */
        IF  CAN-DO("2,4,6,8",STRING(aux_cdsitdtl)) THEN
            ASSIGN aux_dsalerta = aux_dsalerta + ";" + 
                                  DYNAMIC-FUNCTION("BuscaCritica" IN 
                                                   h-b1wgen0060, INPUT 95).

        DO ON ERROR UNDO, LEAVE:
            
            /* cria a tabela de alertas */
            DO aux_contador = 1 TO NUM-ENTRIES(aux_dsalerta,";"):
                IF  ENTRY(aux_contador,aux_dsalerta,";") = "" THEN
                    NEXT.

                RUN Cria_Alerta
                    ( INPUT aux_contador,
                      INPUT ENTRY(aux_contador,aux_dsalerta,";"),
                      INPUT 0,
                      INPUT IF par_cddopcao = "C" THEN "F" ELSE "I" ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = {&GET-MSG}.
                       UNDO, LEAVE.
                    END.
            END.

            LEAVE.
        END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Alertas.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Procura_Alertas */

/* ------------------------------------------------------------------------ */
/*               VERIFICA SE E POSSIVEL ALTERAR UM ASSOCIADO                */
/*   VERIFICA SE E POSSIVEL ALTERAR A RAZAO SOCIAL-CPF/CNPJ DE DO ASSOCIADO */
/* ------------------------------------------------------------------------ */
PROCEDURE Verifica_Altera PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    DEF BUFFER crabass FOR crapass.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    VerificaA: DO ON ERROR UNDO VerificaA, LEAVE VerificaA:

        FOR FIRST crabass FIELDS(dtelimin inpessoa)
                           WHERE crabass.cdcooper = par_cdcooper AND
                                 crabass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN par_cdcritic = 9.
               LEAVE VerificaA.
            END.

        IF  crabass.dtelimin <> ? THEN
            DO:
               ASSIGN par_cdcritic = 410.
               LEAVE VerificaA.
            END.

        CASE crabass.inpessoa:
            WHEN 1 THEN DO:
                /* Primeiro titular */
                IF  NOT CAN-FIND(crapttl WHERE 
                                 crapttl.cdcooper = par_cdcooper AND
                                 crapttl.nrdconta = par_nrdconta AND
                                 crapttl.idseqttl = 1) THEN
                    DO:
                       ASSIGN par_cdcritic = 821.
                       LEAVE VerificaA.
                    END.
            END.
            OTHERWISE DO:
                /* Dados da pessoa juridica */
                IF  NOT CAN-FIND(crapjur WHERE 
                                 crapjur.cdcooper = par_cdcooper AND
                                 crapjur.nrdconta = par_nrdconta) THEN
                    DO:
                       ASSIGN par_dscritic = "Cadastro da pessoa juridica " +
                                             " nao foi encontrado.".
                       LEAVE VerificaA.
                    END.
            END.
        END CASE.

        ASSIGN aux_returnvl = "OK".

        LEAVE VerificaA.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Verifica_Altera */

/* ------------------------------------------------------------------------ */
/*               VERIFICA SE E POSSIVEL CONSULTAR UM ASSOCIADO              */
/* ------------------------------------------------------------------------ */
PROCEDURE Verifica_Consulta PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    DEF BUFFER crabass FOR crapass.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    VerificaC: DO ON ERROR UNDO VerificaC, LEAVE VerificaC:

        /* dados iniciais do associado */
        FOR FIRST crabass FIELDS(nmprimtl)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crabass THEN
            LEAVE VerificaC.

        /* Verifica se o associado esta sendo incluso em outro terminal */
        IF  crabass.nmprimtl = ""   THEN
            DO:
               ASSIGN par_dscritic = "Associado sendo incluso em outro " + 
                                     "terminal...".
               UNDO VerificaC, LEAVE VerificaC.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE VerificaC.
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Verifica_Consulta */

/* ------------------------------------------------------------------------ */
/*               VERIFICACOES INICIAIS DA TELA PRINCIPAL                    */
/* ------------------------------------------------------------------------ */
PROCEDURE Verifica_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    Verifica: DO ON ERROR UNDO Verifica, LEAVE Verifica:

        /* matricp.p */
        RUN Verifica_Principal /* PRINCIPAL */
            ( INPUT par_cdcooper,
              INPUT par_nrdconta,
              INPUT par_cddopcao,
             OUTPUT par_cdcritic,
             OUTPUT par_dscritic ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               LEAVE Verifica.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Verifica.

        CASE par_cddopcao:
            WHEN "C" THEN DO:
                /* matricc.p */
                RUN Verifica_Consulta /* CONSULTA */
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       LEAVE Verifica.
                    END.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Verifica.
            END.
            WHEN "A" OR WHEN "X" THEN DO:
                /* matrica.p e matricx.p */
                RUN Verifica_Altera /* ALTERACAO - RAZAO/CPF-CNPJ */
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       LEAVE Verifica.
                    END.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Verifica.
            END.
            WHEN "I" THEN DO:
                /* matrici.p */
                RUN Verifica_Inclui /* INCLUSAO */
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_idorigem,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       LEAVE Verifica.
                    END.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Verifica.
            END.
            WHEN "R" THEN DO:
                /* impmatric.p */
                RUN Verifica_Relatorio /* IMPRESSAO */
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       LEAVE Verifica.
                    END.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Verifica.
            END.
            WHEN "D" THEN DO:
                /* matricd.p */
                RUN Verifica_Desvincula /* DESVINCULA MATRICULA */
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       LEAVE Verifica.
                    END.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Verifica.
            END.
            OTHERWISE.
        END CASE.

        ASSIGN aux_returnvl = "OK".

        LEAVE Verifica.
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Verifica_Dados */

/* ------------------------------------------------------------------------ */
/*             VERIFICA SE E POSSIVEL DESVINCULAR MATRICULA                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Verifica_Desvincula PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER cracass FOR crapass.
    DEF BUFFER crabtrf FOR craptrf.

    ASSIGN par_dscritic = ""
           par_cdcritic = 0
           aux_returnvl = "NOK".

    VerificaD: DO ON ERROR UNDO VerificaD, LEAVE VerificaD:

        FOR FIRST crabass FIELDS(cdcooper nrdconta inmatric nrmatric nrcpfcgc)
                           WHERE crabass.cdcooper = par_cdcooper AND
                                 crabass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN par_cdcritic = 564.
               LEAVE VerificaD.
            END.

        IF  crabass.inmatric <> 2 THEN
            DO:
               ASSIGN par_cdcritic = 809.
               LEAVE VerificaD.
            END.

        FOR FIRST crabtrf FIELDS(tptransa)
                          WHERE crabtrf.cdcooper = par_cdcooper AND
                                crabtrf.nrsconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crabtrf THEN
            DO:
               ASSIGN par_cdcritic = 124.
               LEAVE VerificaD.
            END.

        IF  crabtrf.tptransa <> 2 THEN
            DO:
               ASSIGN par_cdcritic = 810.
               LEAVE VerificaD.
            END.

        IF  CAN-FIND(FIRST cracass WHERE 
                     cracass.cdcooper  = crabass.cdcooper AND
                     cracass.nrmatric  = crabass.nrmatric AND
                     cracass.nrdconta <> crabass.nrdconta AND
                     cracass.cdsitdct  = 1                AND
                     cracass.nrcpfcgc  = crabass.nrcpfcgc) THEN
            DO:
               ASSIGN par_cdcritic = 775.
               LEAVE VerificaD.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE VerificaD.
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Verifica_Desvincula */

/* ------------------------------------------------------------------------ */
/*               VERIFICA SE E POSSIVEL INCLUIR UM ASSOCIADO                */
/* ------------------------------------------------------------------------ */
PROCEDURE Verifica_Inclui:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_lscontas AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
                                   
    DEF BUFFER crabmat FOR crapmat.
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER crabdem FOR crapdem.
    DEF BUFFER crabtrf FOR craptrf.
    DEF BUFFER crabccs FOR crapccs.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    VerificaI: DO ON ERROR UNDO VerificaI, LEAVE VerificaI:

        FOR FIRST crabmat FIELDS(vlcapsub)
                          WHERE crabmat.cdcooper = par_cdcooper NO-LOCK:

            IF  par_cdcooper <> 9 AND crabmat.vlcapsub = 0 THEN
                DO:
                   ASSIGN par_dscritic = "ATENCAO!!!  Passe primeiro pela "   +
                                         "tela ADMISS e ajuste os parametros" +
                                         " da subscricao de capital.".
                   LEAVE VerificaI.
                END.
        END.

        /* Na inclusao pela Web, a conta e' gerada automaticamente */
        /* Entao nao e' necessario validar */
        IF   par_idorigem = 5    AND 
             par_nrdconta = 0    THEN
             DO: 
                 ASSIGN aux_returnvl = "OK".
                 LEAVE VerificaI.      
             END.
                 
        /* associado ja cadastrado */
        IF  CAN-FIND(crabass WHERE crabass.cdcooper = par_cdcooper AND
                                   crabass.nrdconta = par_nrdconta) THEN
            DO:
               ASSIGN par_cdcritic = 46.
               LEAVE VerificaI.
            END.

        /* Verifica se o associado ja possui cadastro de titular */
        IF  CAN-FIND(crabttl WHERE crabttl.cdcooper = par_cdcooper AND
                                   crabttl.nrdconta = par_nrdconta AND
                                   crabttl.idseqttl = 1) THEN
            DO:
               ASSIGN par_cdcritic = 819.
               LEAVE VerificaI.
            END.

        /*  Verifica se o associado ja esta excluido */
        IF  CAN-FIND(crabdem WHERE crabdem.cdcooper = par_cdcooper AND
                                   crabdem.nrdconta = par_nrdconta) THEN
            DO:
               ASSIGN par_cdcritic = 410.
               LEAVE VerificaI.
            END.

        /*  Verifica se ha solicitacao de transferencia para esta conta  */
        IF  CAN-FIND(crabtrf WHERE crabtrf.cdcooper = par_cdcooper AND
                                   crabtrf.nrsconta = par_nrdconta) THEN
            DO:
               ASSIGN par_cdcritic = 122.
               LEAVE VerificaI.
            END.

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        /*  Le tabela com as contas convenio do Banco do Brasil  */
        DYNAMIC-FUNCTION("BuscaCtaCe" IN h-b1wgen0060,
                         INPUT par_cdcooper,
                         INPUT 0,
                        OUTPUT aux_lscontas,
                        OUTPUT par_dscritic).

        /*  Verifica se a conta eh 8544-8  */
        IF  (par_nrdconta = 85448 AND 
             par_cdcooper <> 1    AND    /* viacredi */
             par_cdcooper <> 2)   OR     /* creditextil */
             CAN-DO(aux_lscontas,STRING(par_nrdconta)) THEN
            DO:
               ASSIGN par_dscritic = "Numero de conta NAO permitido.".
               LEAVE VerificaI.
            END.

        /* Verifica se ja existe o numero da conta como conta salario */
        IF  CAN-FIND(crabccs WHERE crabccs.cdcooper = par_cdcooper AND
                                   crabccs.nrdconta = par_nrdconta) THEN
            DO:
               ASSIGN par_dscritic = "Conta ja cadastrada para uma conta " + 
                                     "salario.".
               LEAVE VerificaI.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE VerificaI.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Verifica_Inclui */

/* ------------------------------------------------------------------------ */
/*               VERIFICACOES INICIAIS DA TELA PRINCIPAL                    */
/* ------------------------------------------------------------------------ */
PROCEDURE Verifica_Principal PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_lscontas AS CHAR                                    NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER crabalt FOR crapalt.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    VerificaP: DO ON ERROR UNDO VerificaP, LEAVE VerificaP:

        IF  NOT CAN-FIND(crapcop WHERE crapcop.cdcooper = par_cdcooper) THEN
            DO:
               ASSIGN par_cdcritic = 651.
               LEAVE VerificaP.
            END.

        /* -- INICIO - Logica da tela matricp.p ---------------------------- */
        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        /*  Le tabela com as contas convenio do Banco do Brasil  */
        DYNAMIC-FUNCTION("BuscaCtaCe" IN h-b1wgen0060,
                         INPUT par_cdcooper,
                         INPUT 0,
                        OUTPUT aux_lscontas,
                        OUTPUT par_dscritic).

        IF  aux_lscontas = "" THEN
            DO:
               ASSIGN par_cdcritic = 393.
               LEAVE VerificaP.
            END.
        ELSE
            ASSIGN par_dscritic = "".

        FOR FIRST crapdat FIELDS(inproces)
                          WHERE crapdat.cdcooper = par_cdcooper NO-LOCK:

            IF  crapdat.inproces <> 1 AND par_cddopcao <> "C" THEN
                DO:
                   ASSIGN par_cdcritic = 138. 
                   LEAVE VerificaP.
                END.
        END.

        /* verificacao para opcao 'I' termina aqui */
        IF  par_cddopcao = "I" THEN
            DO:
               ASSIGN aux_returnvl = "OK".
               LEAVE VerificaP.
            END.

        /* verificar o digito da conta informada */
        IF  NOT ValidaDigFun(INPUT par_cdcooper,
                             INPUT 0,
                             INPUT 0,
                             INPUT par_nrdconta) THEN
            DO:
               ASSIGN par_cdcritic = 8.
               LEAVE VerificaP.
            END.

        /* dados iniciais do associado */
        FOR FIRST crabass FIELDS(inpessoa cdtipcta nmprimtl inpessoa
                                 dtdemiss indnivel)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN par_cdcritic = 564.
               LEAVE VerificaP.
            END.

        /* Verifica se o associado esta sendo incluso em outro terminal */
        IF  crabass.nmprimtl = ""   THEN
            DO:
               ASSIGN par_dscritic = "Associado sendo incluso em outro " + 
                                     "terminal...".
               LEAVE VerificaP.
            END.

        /* Verifica se Tipo de Conta Individual e possui mais de um Titular */
        IF  crabass.inpessoa = 1 THEN
            DO:
               FOR LAST crabttl FIELDS(idseqttl) 
                                WHERE crabttl.cdcooper = par_cdcooper AND
                                      crabttl.nrdconta = par_nrdconta AND
                                      crabttl.idseqttl > 1 NO-LOCK:
            
                   IF  CAN-DO("01,02,07,08,09,12,13,18",
                              STRING(crabass.cdtipcta,"99")) THEN
                       DO:
                          RUN Cria_Alerta
                              ( INPUT 0,
                                INPUT "832 - Tipo de conta nao permite MAIS " +
                                      "DE UM TITULAR.",
                                INPUT 3,
                                INPUT "I" ) NO-ERROR.
    
                          IF  ERROR-STATUS:ERROR THEN
                              DO:
                                 ASSIGN par_dscritic = {&GET-MSG}.
                                 LEAVE VerificaP.
                              END.
                       END.
               END.
            END.

        /* Procura registro de recadastramento */
        IF  crabass.dtdemiss = ? AND crabass.indnivel > 1 THEN
            DO:
               IF  NOT CAN-FIND(LAST crabalt WHERE 
                                crabalt.cdcooper = par_cdcooper   AND
                                crabalt.nrdconta = par_nrdconta   AND
                                crabalt.tpaltera = 1) THEN
                   DO:
                      RUN Cria_Alerta
                          ( INPUT 0,
                            INPUT "400 - ATENCAO!! Associado " + 
                                  "nao recadastrado!!",
                            INPUT 3,
                            INPUT "I" ) NO-ERROR.

                      IF  ERROR-STATUS:ERROR THEN
                          DO:
                             ASSIGN par_dscritic = {&GET-MSG}.
                             LEAVE VerificaP.
                          END.
                   END.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE VerificaP.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Verifica_Principal */

/* ------------------------------------------------------------------------ */
/*               VERIFICA SE E POSSIVEL EFETUAR A IMPRESSAO                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Verifica_Relatorio PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabmat FOR crapmat.
    DEF BUFFER crabage FOR crapage.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    VerificaR: DO ON ERROR UNDO VerificaR, LEAVE VerificaR:

        IF  NOT CAN-FIND(FIRST crabmat WHERE 
                         crabmat.cdcooper = par_cdcooper) THEN
            DO:
               ASSIGN par_cdcritic = 194.
               LEAVE VerificaR.
            END.

        FOR FIRST crabass FIELDS(inmatric cdagenci)
                           WHERE crabass.cdcooper = par_cdcooper AND
                                 crabass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN par_cdcritic = 9.
               LEAVE VerificaR.
            END.

        IF  crabass.inmatric <> 1 THEN
            DO:
               ASSIGN par_dscritic = "Impressao nao permitida. Esta e' uma " + 
                                     "conta duplicada.".
               LEAVE VerificaR.
            END.

        IF  NOT CAN-FIND(FIRST crabage WHERE 
                         crabage.cdcooper = par_cdcooper AND
                         crabage.cdagenci = crabass.cdagenci) THEN
            DO:
               ASSIGN par_cdcritic = 15.
               LEAVE VerificaR.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE VerificaR.
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Verifica_Relatorio */

/*........................... FUNCOES INTERNAS/PRIVADAS .....................*/

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ):
/*-----------------------------------------------------------------------------
  Objetivo:  Valida o digita verificador
     Notas:  
-----------------------------------------------------------------------------*/

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_nrdconta AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_vlresult AS LOGICAL     NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    ASSIGN 
        aux_nrdconta = par_nrdconta
        aux_vlresult = TRUE.

    RUN dig_fun IN h-b1wgen9999 
        ( INPUT par_cdcooper,
          INPUT par_cdagenci,
          INPUT par_nrdcaixa,
          INPUT-OUTPUT aux_nrdconta,
         OUTPUT TABLE tt-erro ).
    
    DELETE OBJECT h-b1wgen9999.

    /* verifica se o digito foi informado corretamente */
    IF  RETURN-VALUE <> "OK" THEN
        ASSIGN aux_vlresult = FALSE.

    FIND FIRST tt-erro NO-ERROR.

    IF  AVAILABLE tt-erro THEN
        ASSIGN aux_vlresult = FALSE.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_nrdconta <> par_nrdconta THEN
        ASSIGN aux_vlresult = FALSE.

   RETURN aux_vlresult.
        
END FUNCTION.



PROCEDURE Busca_Dados_Cto:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfprocu AS DEC                            NO-UNDO.
    DEF  INPUT PARAM par_verconta AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nmrotina AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_flgsuces AS LOG                                     NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabttl FOR crapttl.

    DEF VAR aux_retorno  AS CHAR  INIT "NOK"                        NO-UNDO.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        EMPTY TEMP-TABLE tt-erro.

        IF par_verconta = TRUE THEN /*nao pode ser a mesma conta dos ass*/
           IF (par_nrdctato <> 0           AND 
               par_nrdconta <> 0)          AND
               par_cddopcao <> "E"         AND
               par_nrdctato = par_nrdconta THEN
               DO:
                  ASSIGN par_cdcritic = 121.
                  LEAVE Busca.

               END.

        IF par_nrdctato <> 0 THEN
           DO:
              IF CAN-FIND(crabass WHERE 
                          crabass.cdcooper = par_cdcooper  AND
                          crabass.nrdconta = par_nrdctato) THEN
                 DO:
                    IF  par_cddopcao = "A" THEN
                        DO:
                            par_dscritic = "Nao e permitido alterar dados" +
                                          " do associado!".
                            LEAVE Busca.
                        END.


                 END.
           END. 


        /* efetua a busca tanto por nr da conta como por cpf */
        IF par_nrdctato <> 0  THEN
           FOR FIRST crabass FIELDS(inpessoa cdtipcta dtdemiss nrdconta 
                                    cdcooper nrcpfcgc)
                             WHERE crabass.cdcooper = par_cdcooper AND
                                   crabass.nrdconta = par_nrdctato 
                                   NO-LOCK:
           END.
        ELSE
        IF par_nrcpfcto <> 0 THEN 
           FOR FIRST crabass FIELDS(inpessoa cdtipcta dtdemiss nrdconta 
                                    cdcooper nrcpfcgc)
                             WHERE crabass.cdcooper = par_cdcooper AND
                                   crabass.nrcpfcgc = par_nrcpfcto 
                                   NO-LOCK:
           END.


        IF NOT AVAILABLE crabass THEN
           DO: 
              IF par_nrdctato <> 0 THEN
                 ASSIGN par_cdcritic = 9.
              ELSE
                IF (par_nrcpfcto <> 0           AND 
                    par_cpfprocu <> 0)          AND
                    par_nrcpfcto = par_cpfprocu THEN
                    ASSIGN par_dscritic = "CPF do Responsavel deve " +
                                          "ser diferente do CPF "    + 
                                          "Repres./Procurador.".

              LEAVE Busca.

           END.
             
        IF crabass.inpessoa <> 1 THEN
           DO:
              ASSIGN par_cdcritic = 833.
              LEAVE Busca.

           END.

        ASSIGN aux_flgsuces = TRUE.
        
        IF crabass.cdtipcta >= 12 THEN
           FOR EACH crabttl FIELDS(indnivel) 
                            WHERE crabttl.cdcooper = crabass.cdcooper AND
                                  crabttl.nrdconta = crabass.nrdconta 
                                  NO-LOCK:

               IF crabttl.indnivel <> 4 THEN
                  ASSIGN aux_flgsuces = FALSE.

           END.

        IF NOT aux_flgsuces                 AND
           crabass.dtdemiss = ?             AND
           crabass.nrdconta <> par_nrdctato THEN
           DO:
              ASSIGN par_cdcritic = 830.
              LEAVE Busca.

           END.

        CREATE tt-crapcrl.

        ASSIGN tt-crapcrl.cdcooper = crabass.cdcooper
               tt-crapcrl.nrctamen = par_nrdconta
               tt-crapcrl.nrcpfmen = par_cpfprocu
               tt-crapcrl.nrdconta = crabass.nrdconta
               tt-crapcrl.nrcpfcgc = crabass.nrcpfcgc
               tt-crapcrl.idseqmen = par_nrctremp
               tt-crapcrl.cddopcao = par_cddopcao.

        /* 1o. Titular */
        FOR FIRST crabttl FIELDS(nmextttl nrdocttl cdoedttl dtemdttl dtnasttl 
                                 cdsexotl cdestcvl dsnacion dsnatura nmpaittl 
                                 nmmaettl tpdocttl cdufdttl)
                          WHERE crabttl.cdcooper = crabass.cdcooper AND
                                crabttl.nrdconta = crabass.nrdconta AND
                                crabttl.idseqttl = 1 
                                NO-LOCK:

            ASSIGN tt-crapcrl.nmrespon = crabttl.nmextttl
                   tt-crapcrl.nridenti = crabttl.nrdocttl
                   tt-crapcrl.dsorgemi = crabttl.cdoedttl
                   tt-crapcrl.cdufiden = crabttl.cdufdttl
                   tt-crapcrl.dtemiden = crabttl.dtemdttl
                   tt-crapcrl.dtnascin = crabttl.dtnasttl
                   tt-crapcrl.cddosexo = crabttl.cdsexotl
                   tt-crapcrl.cdestciv = crabttl.cdestcvl
                   tt-crapcrl.dsnacion = crabttl.dsnacion
                   tt-crapcrl.dsnatura = crabttl.dsnatura
                   tt-crapcrl.nmpairsp = crabttl.nmpaittl
                   tt-crapcrl.nmmaersp = crabttl.nmmaettl
                   tt-crapcrl.tpdeiden = crabttl.tpdocttl.

            /* validar a idade */
            IF BuscaIdade (crabttl.dtnasttl,par_dtmvtolt) < 18 THEN
               DO:
                  IF par_nrdctato <> 0 THEN
                     DO:
                         ASSIGN par_cdcritic = 585.
                         UNDO Busca, LEAVE Busca.

                     END.
                  ELSE
                     IF par_nrcpfcto <> 0 THEN
                        DO:
                            ASSIGN par_cdcritic = 806.
                            UNDO Busca, LEAVE Busca.

                        END.

               END.
            
        END.

        /* Endereco */
        FOR FIRST crapenc FIELDS(nrcepend dsendere nrendere complend nmbairro 
                                 nmcidade cdufende nrcxapst)
                          WHERE crapenc.cdcooper = crabass.cdcooper AND
                                crapenc.nrdconta = crabass.nrdconta AND
                                crapenc.idseqttl = 1                AND
                                crapenc.cdseqinc = 1                AND
                                crapenc.tpendass = 10 /*Residencial*/ 
                                NO-LOCK:

            ASSIGN tt-crapcrl.nrendres = crapenc.nrendere
                   tt-crapcrl.dscomres = crapenc.complend
                   tt-crapcrl.cdcepres = crapenc.nrcepend
                   tt-crapcrl.dsendres = crapenc.dsendere
                   tt-crapcrl.dsbaires = crapenc.nmbairro
                   tt-crapcrl.dscidres = crapenc.nmcidade
                   tt-crapcrl.dsdufres = crapenc.cdufende
                   tt-crapcrl.nrcxpost = crapenc.nrcxapst.

        END.
        
        /* Estado civil */
        FOR FIRST gnetcvl FIELDS(rsestcvl)
                          WHERE gnetcvl.cdestcvl = tt-crapcrl.cdestciv 
                          NO-LOCK:
        
            ASSIGN tt-crapcrl.dsestcvl = gnetcvl.rsestcvl.

        END.
        
        IF par_nmrotina = "RESPONSAVEL LEGAL" THEN
           DO:
              /* verificar se o resp.legal ja esta cadastrado */
              IF  CAN-FIND(FIRST crapcrl WHERE                              
                                 crapcrl.cdcooper = par_cdcooper  AND 
                                 crapcrl.nrctamen = par_nrdconta  AND       
                                 crapcrl.nrcpfmen = par_cpfprocu  AND
                                 crapcrl.idseqmen = par_nrctremp  AND
                                 crapcrl.nrdconta = par_nrdctato  AND
                                 crapcrl.nrcpfcgc = par_nrcpfcto) AND  
                  par_cddopcao = "I" THEN
                  DO:
                     ASSIGN par_dscritic = "Responsavel legal ja cadastrado.".
                     LEAVE Busca.
              
                  END.

           END.

        LEAVE Busca.

    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_retorno = "OK".

    RETURN aux_retorno.

END PROCEDURE.

FUNCTION BuscaIdade RETURNS INTEGER 
    ( INPUT par_dtnascto AS DATE,
      INPUT par_dtmvtolt AS DATE ):

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_nrdeanos AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrdmeses AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_dsdidade AS CHARACTER   NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    RUN idade IN h-b1wgen9999 (INPUT par_dtnascto,
                               INPUT par_dtmvtolt,
                               OUTPUT aux_nrdeanos,
                               OUTPUT aux_nrdmeses,
                               OUTPUT aux_dsdidade).

    DELETE OBJECT h-b1wgen9999.

    RETURN aux_nrdeanos.

END FUNCTION.

