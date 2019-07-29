/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0126.p
    Autor   : Rogerius Militao (DB1)
    Data    : Dezembro/2011                     Ultima atualizacao: 31/10/2017 

    Objetivo  : Tranformacao BO tela ALTAVA

    Alteracoes: 08/04/2013 - Ajustes realizados:
                             - Incluido a chamada da procedure alerta_fraude
                               dentro da Grava_Dados;
                             - Alimentado o campo tt-avalista.nrcpfcgc
                               na procedure Busca_Avalista quando avalista
                               tiver conta (Adriano).
                             - Adicionada área PARA USO DA DIGITALIZAÇAO na
                               procedure Gera_Impressao (Lucas).
                               
                17/06/2013 - Ajuste na validacao das variaveis par_nmdaval1,
                             par_nmdaval2 dentro da procedure Grava_Dados
                             (Adriano).
                             
                18/06/2013 - Mesmo que for avalista com conta alimentar o campo
                             tt-contrato-avalista.nrcpfcgc = tt-avalista.nrcpfcgc             
                             com o número do cpfcgc da conta do cooperado,
                             e necessario para cadastro restritivo.
                             (Oscar).
                    
                14/08/2013 - Incluido a chamada da procedure 
                             "atualiza_data_manutencao_avalista" dentro da
                             procedure "grava_dados" (James).
                             
                12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)             
                
                16/12/2013 - Alterado valor da variavel tt-avalista.dscpfava
                             de "C.G.C." para "CNPJ", FORM f_termo de 
                             "CPF/CGC\033\105" para "CPF/CNPJ\033\105". 
                             (Reinert)
                             
                25/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                             posicoes (Tiago/Gielow SD137074).  
                             
                06/06/2014 - Incluso tratamento para novos campos avalista
                             (inpessoa e dtnascto), ajuste CYBER (Daniel/Thiago).                        
                             
                10/06/2014 - Troca do campo crapass.nmconjug por crapcje.nmconjug
                             (Chamado 117414) - (Tiago Castro - RKAM).
                             
                11/11/2014 - Enviar o inpessoa para a validacao do avalista
                             (Jonata-RKAM).   
                             
                17/11/2014 - Ajuste na limpeza dos avalistas cooperados
                             (Jonata-RKAM).                        
                             
                05/01/2015 - Ajuste format numero contrato/bordero na area
                             de 'USO DA DIGITALIZACAO'; adequacao ao format
                             pre-definido para nao ocorrer divergencia ao 
                             pesquisar no SmartShare. 
                             (Chamado 181988) - (Fabricio)
                             
                26/01/2015 - (Chamado 245498) Ajuste no delete da crapavl, 
                             durante uma exclusao ou alteracao de fiador,
                             nao era exluido o anterio, deixando sempre o
                             fiador anterior (Tiago Castro - RKAM).
                             
                26/01/2015 - Alterado o formato do campo nrctremp para 8 
                             caracters (Kelvin - 233714)
                         
                25/05/2015 - Incluir cdagenci e cdoperad na criacao dos aditivos
                             (Lucas Ranghetti #288277)
                             
                01/12/2015 - Incluir busca do pa de trabalho na procedure 
                             Cria_Aditivo na gravacao dos aditivos 
                             (Lucas Ranghetti #366888 )
                             
                15/08/2016 - Na PROCEDURE Grava_dados, incluir validacao para 
                             que caso nao exista proposta de emprestimo, continue
                             com o procedimento (Lucas Ranghetti #484366)

			    18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							(Adriano - P339).

                31/10/2017 - Passagem do tpctrato. (Jaison/Marcos Martini - PRJ404)

............................................................................*/

/*............................. DEFINICOES .................................*/

{ sistema/generico/includes/b1wgen0126tt.i }
{ sistema/generico/includes/b1wgen0168tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF STREAM str_1.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.

DEF VAR h-b1wgen0001 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.                                                                     
DEF VAR h-b1wgen0060 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.
DEF VAR aux_nmconjug LIKE crapcje.nmconjug                          NO-UNDO.
DEF VAR aux_nrcpfcjg LIKE crapcje.nrcpfcjg                          NO-UNDO.
DEF VAR aux_vlrencjg AS DECI                                        NO-UNDO.
DEF VAR aux_nrctacjg AS INTE                                        NO-UNDO.
DEF VAR aux_vlrenmes AS DECI                                        NO-UNDO.
DEF VAR aux_vlmedfat AS DECI                                        NO-UNDO.
        
FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ) FORWARD.

/*................................ PROCEDURES ..............................*/
 
/* ------------------------------------------------------------------------ */
/*              BUSCA DOS DADOS ASSOCIADO P/ ALTERAR AVAL/FIADORES          */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

     DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
        
     DEF OUTPUT PARAM par_nrctatos AS INTE                           NO-UNDO.
     DEF OUTPUT PARAM par_nrctremp AS INTE                           NO-UNDO.

     DEF OUTPUT PARAM TABLE FOR tt-infoass.
     DEF OUTPUT PARAM TABLE FOR tt-erro.
     
     DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

     EMPTY TEMP-TABLE tt-infoass.
     EMPTY TEMP-TABLE tt-erro.


     ASSIGN aux_dscritic = ""
            aux_cdcritic = 0
            aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
            aux_dstransa = "Busca dados do associado"
            aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        /* validar o digito da conta */
        IF  NOT ValidaDigFun ( INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_nrdconta ) THEN
            DO:
               ASSIGN aux_cdcritic = 8.
               LEAVE Busca.
            END.

        /* busca dados do associado */
        FOR FIRST crapass FIELDS(nmprimtl)      WHERE  
             crapass.cdcooper = par_cdcooper    AND
             crapass.nrdconta = par_nrdconta    NO-LOCK: END.

        IF   NOT AVAILABLE crapass THEN
             DO:
                 ASSIGN aux_cdcritic = 9.
                 LEAVE Busca.
             END.
        
        CREATE tt-infoass.
        ASSIGN tt-infoass.cdcooper = par_cdcooper 
               tt-infoass.nrdconta = par_nrdconta
               tt-infoass.nmprimtl = crapass.nmprimtl.

        /* dados do emprestimo */
        FOR EACH crapepr FIELDS(nrctremp) WHERE 
                 crapepr.cdcooper = par_cdcooper   AND
                 crapepr.nrdconta = par_nrdconta   NO-LOCK:

            ASSIGN par_nrctatos = par_nrctatos + 1
                   par_nrctremp = crapepr.nrctremp.

        END.  /*  Fim do FOR EACH  --  Leitura dos contratos de altavatimos  */

        IF   par_nrctatos <= 0 THEN
             DO:
                 ASSIGN aux_cdcritic = 355.
                 LEAVE Busca.
             END.                                     

        ASSIGN aux_returnvl = "OK".
        LEAVE Busca.
        
     END. /*  Busca */               

     IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
         aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  AVAIL tt-erro THEN
                 ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE 
                 RUN gera_erro ( INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic ).

             IF  par_flgerlog  THEN
                 RUN proc_gerar_log ( INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT 1,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid ).

             RETURN "NOK".
         END.
     
     RETURN "OK".

END PROCEDURE. /* Busca_Dados */
 

/* ------------------------------------------------------------------------ */
/*  VALIDA OS DADOS DO AVALISTA COM CONTA P/ ALTERAR CONTRATO DE EMPRESTIMO */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Conta:

     DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrctaava AS INTE                           NO-UNDO. /* conta do avalista */
     DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
        
     DEF OUTPUT PARAM TABLE FOR tt-erro.
     
     DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
     DEF VAR aux_nrdeanos AS INTE                                    NO-UNDO. 
     DEF VAR aux_nrdmeses AS INTE                                    NO-UNDO.
     DEF VAR aux_dsdidade AS CHAR                                    NO-UNDO.
     DEF VAR aux_cdgraupr LIKE crapttl.cdgraupr                      NO-UNDO.
     DEF VAR aux_inhabmen LIKE crapttl.inhabmen                      NO-UNDO.

     EMPTY TEMP-TABLE tt-erro.

     ASSIGN aux_dscritic = ""
            aux_cdcritic = 0
            aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
            aux_dstransa = "Valida conta do avalista"
            aux_returnvl = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        
        /* validar o digito da conta */
        IF  NOT ValidaDigFun ( INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_nrctaava ) THEN
            DO:
               ASSIGN aux_cdcritic = 8.
               LEAVE Valida.
            END.

        /* busca dados do associado */
        FOR FIRST crapass FIELDS(nmprimtl)      WHERE  
             crapass.cdcooper = par_cdcooper    AND
             crapass.nrdconta = par_nrctaava    NO-LOCK: END.

        IF   NOT AVAILABLE crapass THEN
             DO:
                 ASSIGN aux_cdcritic = 9.
                 LEAVE Valida.
             END.

        IF  par_nrctaava = par_nrdconta   THEN
            DO:
                RUN sistema/generico/procedures/b1wgen0060.p
                    PERSISTENT SET h-b1wgen0060.

                ASSIGN aux_dscritic = 
                DYNAMIC-FUNCTION("BuscaCritica" IN h-b1wgen0060, INPUT 127) +
                                 " Deve ser diferente do CONTRATANTE.".

                DELETE PROCEDURE h-b1wgen0060.

                LEAVE Valida.
            END.
        
        IF  NOT VALID-HANDLE(h-b1wgen0001) THEN
            RUN sistema/generico/procedures/b1wgen0001.p
                PERSISTENT SET h-b1wgen0001.
    
        IF  VALID-HANDLE(h-b1wgen0001)   THEN
            DO:
                RUN ver_cadastro IN h-b1wgen0001
                              (INPUT  par_cdcooper,
                               INPUT  par_nrctaava,
                               INPUT  par_cdagenci, /* cod-agencia */
                               INPUT  par_nrdcaixa, /* nro-caixa   */
                               INPUT  par_dtmvtolt,
                               INPUT  par_idorigem, /* AYLLOS */
                               OUTPUT TABLE tt-erro).
    
                DELETE PROCEDURE h-b1wgen0001.

                /* Verifica se houve erro */
                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAILABLE tt-erro THEN
                    LEAVE Valida.

            END.

        FIND crapass WHERE 
             crapass.cdcooper = par_cdcooper AND 
             crapass.nrdconta = par_nrctaava NO-LOCK NO-ERROR.

        IF  AVAIL crapass THEN
            DO:
                ASSIGN aux_cdgraupr = 0
                       aux_inhabmen = 0.
                IF crapass.inpessoa = 1 THEN
                DO:
                    FIND crapttl WHERE crapttl.cdcooper = par_cdcooper 
                                   AND crapttl.nrdconta = crapass.nrdconta 
                                   AND crapttl.idseqttl = 2 
                                   NO-LOCK NO-ERROR.
                    IF AVAIL crapttl THEN
                        ASSIGN aux_cdgraupr = 
                               crapttl.cdgraupr
                               aux_inhabmen = 
                               crapttl.inhabmen.
                END.
        
                IF  crapass.inpessoa = 3 THEN
                    DO:
                       ASSIGN aux_cdcritic = 808.
                       LEAVE Valida.
                    END.
        
                IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                    RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.

                RUN idade IN h-b1wgen9999
                    ( INPUT crapass.dtnasctl,
                      INPUT par_dtmvtolt,
                     OUTPUT aux_nrdeanos,
                     OUTPUT aux_nrdmeses,
                     OUTPUT aux_dsdidade).
        
                IF  VALID-HANDLE(h-b1wgen9999)  THEN
                    DELETE PROCEDURE h-b1wgen9999.

                IF  crapass.inpessoa = 1 AND 
                    aux_nrdeanos < 18    AND 
                    aux_inhabmen = 0     THEN
                    DO:
                        ASSIGN aux_cdcritic = 585.
                        LEAVE Valida.
                    END.

        END.

        ASSIGN aux_returnvl = "OK".
        LEAVE Valida.
        
     END. /*  Valida */


     IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
         aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  AVAIL tt-erro THEN
                 ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE 
                 RUN gera_erro ( INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic ).

             IF  par_flgerlog  THEN
                 RUN proc_gerar_log ( INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT 1,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid ).

             RETURN "NOK".
         END.
     
     RETURN "OK".

END PROCEDURE. /* Valida_Dados */


/* ------------------------------------------------------------------------ */
/*            BUSCA DOS DADOS CONTRATO P/ ALTERAR AVAL/FIADORES             */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Contrato:

     DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
        
     DEF OUTPUT PARAM TABLE FOR tt-contrato.
     DEF OUTPUT PARAM TABLE FOR tt-contrato-avalista.
     DEF OUTPUT PARAM TABLE FOR tt-erro.
     
     DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
     DEF VAR aux_cdgraupr AS INTE                                    NO-UNDO.
     DEF VAR aux_nmdaval1 AS CHAR                                    NO-UNDO.
     DEF VAR aux_nmdaval2 AS CHAR                                    NO-UNDO.
    
     EMPTY TEMP-TABLE tt-contrato-avalista.
     EMPTY TEMP-TABLE tt-contrato.
     EMPTY TEMP-TABLE tt-erro.

     ASSIGN aux_nmdaval1 = " "
            aux_nmdaval2 = " "
            aux_dscritic = ""
            aux_cdcritic = 0
            aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
            aux_dstransa = "Busca dados do contrato"
            aux_returnvl = "NOK".


    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        FIND crapepr WHERE crapepr.cdcooper = par_cdcooper    AND
                           crapepr.nrdconta = par_nrdconta    AND
                           crapepr.nrctremp = par_nrctremp
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapepr THEN
            DO:
                ASSIGN aux_cdcritic = 356.
                LEAVE Busca.
            END.

        CREATE tt-contrato.
        ASSIGN tt-contrato.nrctremp = par_nrctremp
               tt-contrato.vlemprst = crapepr.vlemprst 
               tt-contrato.vlpreemp = crapepr.vlpreemp 
               tt-contrato.qtpreemp = crapepr.qtpreemp 
               tt-contrato.nrctaav1 = crapepr.nrctaav1 
               tt-contrato.nrctaav2 = crapepr.nrctaav2.

        /*  Leitura da descricao da linha de credito do emprestimo  */
        FIND craplcr WHERE craplcr.cdcooper = par_cdcooper      AND
                           craplcr.cdlcremp = crapepr.cdlcremp  NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE craplcr THEN
            ASSIGN tt-contrato.dslcremp = STRING(crapepr.cdlcremp,"zzz9") + " - " +
                                          "NAO CADASTRADA!".
        ELSE
            ASSIGN tt-contrato.dslcremp = STRING(craplcr.cdlcremp,"zzz9") + " - " +
                                          craplcr.dslcremp.
        
        /*  Leitura da descricao da finalidade do emprestimo  */
        FIND crapfin WHERE crapfin.cdcooper = par_cdcooper      AND
                           crapfin.cdfinemp = crapepr.cdfinemp  NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE crapfin   THEN
            ASSIGN tt-contrato.dsfinemp = STRING(crapepr.cdfinemp,"zz9") + " - " +
                                          "NAO CADASTRADA!".
        ELSE
            ASSIGN tt-contrato.dsfinemp = STRING(crapfin.cdfinemp,"zz9") + " - " +
                                          crapfin.dsfinemp.
        
        IF  crapepr.nrctaav1 = 0 OR crapepr.nrctaav2 = 0 THEN
            DO:
                FOR EACH crapavt WHERE 
                         crapavt.cdcooper = par_cdcooper        AND
                         crapavt.tpctrato = 1                   AND /* Emprestimo */
                         crapavt.nrdconta = crapepr.nrdconta    AND
                         crapavt.nrctremp = crapepr.nrctremp    NO-LOCK:
                        
                    IF  crapepr.nrctaav1 = 0 AND
                        aux_nmdaval1 = " " THEN
                        DO:
                            CREATE tt-contrato-avalista.
                            ASSIGN tt-contrato-avalista.nrindice    = 1
                                   tt-contrato-avalista.nmdavali    = crapavt.nmdavali 
                                   tt-contrato-avalista.nrcpfcgc    = crapavt.nrcpfcgc
                                   tt-contrato-avalista.tpdocava    = crapavt.tpdocava
                                   tt-contrato-avalista.dscpfava    = crapavt.nrdocava
                                   tt-contrato-avalista.nmcjgava    = crapavt.nmconjug
                                   tt-contrato-avalista.nrcpfcjg    = crapavt.nrcpfcjg
                                   tt-contrato-avalista.tpdoccjg    = crapavt.tpdoccjg 
                                   tt-contrato-avalista.dscfcava    = crapavt.nrdoccjg
                                   tt-contrato-avalista.dsendava[1] = crapavt.dsendres[1]
                                   tt-contrato-avalista.dsendava[2] = crapavt.dsendres[2]
                                   tt-contrato-avalista.nrfonres    = crapavt.nrfonres
                                   tt-contrato-avalista.dsdemail    = crapavt.dsdemail
                                   tt-contrato-avalista.nmcidade    = crapavt.nmcidade
                                   tt-contrato-avalista.cdufende    = crapavt.cdufresd
                                   tt-contrato-avalista.nrcepend    = crapavt.nrcepend
                                   tt-contrato-avalista.nrendere    = crapavt.nrendere
                                   tt-contrato-avalista.nrcxapst    = crapavt.nrcxapst
                                   tt-contrato-avalista.complend    = crapavt.complend
                                   tt-contrato-avalista.inpessoa    = crapavt.inpessoa
                                   tt-contrato-avalista.cdnacion    = crapavt.cdnacion
                                   tt-contrato-avalista.vlrencjg    = crapavt.vlrencjg
                                   tt-contrato-avalista.vlrenmes    = crapavt.vlrenmes
                                   tt-contrato-avalista.dtnascto    = crapavt.dtnascto
                                   aux_nmdaval1                     = crapavt.nmdavali.

                            /* Buscar a Nacionalidade */
                            FOR FIRST crapnac FIELDS(dsnacion)
                                              WHERE crapnac.cdnacion = crapavt.cdnacion
                                                    NO-LOCK:
                                ASSIGN tt-contrato-avalista.dsnacion = crapnac.dsnacion.
                        END.

                        END.
                    ELSE   
                    IF  crapepr.nrctaav2 = 0 AND
                        aux_nmdaval2 = " " THEN
                        DO:
                            CREATE tt-contrato-avalista.
                            ASSIGN tt-contrato-avalista.nrindice    = 2
                                   tt-contrato-avalista.nmdavali    = crapavt.nmdavali 
                                   tt-contrato-avalista.nrcpfcgc    = crapavt.nrcpfcgc
                                   tt-contrato-avalista.tpdocava    = crapavt.tpdocava
                                   tt-contrato-avalista.dscpfava    = crapavt.nrdocava
                                   tt-contrato-avalista.nmcjgava    = crapavt.nmconjug
                                   tt-contrato-avalista.nrcpfcjg    = crapavt.nrcpfcjg
                                   tt-contrato-avalista.tpdoccjg    = crapavt.tpdoccjg 
                                   tt-contrato-avalista.dscfcava    = crapavt.nrdoccjg
                                   tt-contrato-avalista.dsendava[1] = crapavt.dsendres[1]
                                   tt-contrato-avalista.dsendava[2] = crapavt.dsendres[2]
                                   tt-contrato-avalista.nrfonres    = crapavt.nrfonres
                                   tt-contrato-avalista.dsdemail    = crapavt.dsdemail
                                   tt-contrato-avalista.nmcidade    = crapavt.nmcidade
                                   tt-contrato-avalista.cdufende    = crapavt.cdufresd
                                   tt-contrato-avalista.nrcepend    = crapavt.nrcepend
                                   tt-contrato-avalista.nrendere    = crapavt.nrendere
                                   tt-contrato-avalista.nrcxapst    = crapavt.nrcxapst
                                   tt-contrato-avalista.complend    = crapavt.complend
                                   tt-contrato-avalista.inpessoa    = crapavt.inpessoa
                                   tt-contrato-avalista.cdnacion    = crapavt.cdnacion
                                   tt-contrato-avalista.vlrencjg    = crapavt.vlrencjg
                                   tt-contrato-avalista.vlrenmes    = crapavt.vlrenmes
                                   tt-contrato-avalista.dtnascto    = crapavt.dtnascto
                                   aux_nmdaval2                     = crapavt.nmdavali.

                            /* Buscar a Nacionalidade */
                            FOR FIRST crapnac FIELDS(dsnacion)
                                              WHERE crapnac.cdnacion = crapavt.cdnacion
                                                    NO-LOCK:
                                ASSIGN tt-contrato-avalista.dsnacion = crapnac.dsnacion.
                        END.
                        END.

                END. /* FOR EACH crapavt WHERE */
        END. /* IF  crapepr.nrctaav1 OR crapepr.nrctaav2 THEN */

        /* 1 Busca Avalista que tem Conta */
        IF  crapepr.nrctaav1 > 0 THEN
            DO:
                EMPTY TEMP-TABLE tt-avalista.

                RUN Busca_Avalista(  
                    INPUT par_cdcooper,
                    INPUT crapepr.nrctaav1,
                    INPUT 0,
                   OUTPUT TABLE tt-avalista).                
                
                FIND FIRST tt-avalista NO-ERROR.
                IF  AVAIL tt-avalista THEN
                    DO:
                        CREATE tt-contrato-avalista.
                        ASSIGN tt-contrato-avalista.nrindice = 1
                               tt-contrato-avalista.nrctaava = tt-avalista.nrctaava
                               tt-contrato-avalista.nrcpfcgc = tt-avalista.nrcpfcgc
                               tt-contrato-avalista.nmdavali = tt-avalista.nmdavali
                               tt-contrato-avalista.dscpfava = tt-avalista.dscpfava
                               tt-contrato-avalista.nmcjgava = tt-avalista.nmcjgava
                               tt-contrato-avalista.dsendava[1] = tt-avalista.dsendava[1]
                               tt-contrato-avalista.dsendava[2] = tt-avalista.dsendava[2]
                               tt-contrato-avalista.dscfcava = tt-avalista.dscfcava
                               tt-contrato-avalista.nmcidade = tt-avalista.nmcidade
                               tt-contrato-avalista.nrfonres = tt-avalista.nrfonres
                               tt-contrato-avalista.dsdemail = tt-avalista.dsdemail
                               tt-contrato-avalista.cdufende = tt-avalista.cdufende
                               tt-contrato-avalista.nrcepend = tt-avalista.nrcepend 
                               tt-contrato-avalista.nrendere = tt-avalista.nrendere
                               tt-contrato-avalista.nrcxapst = tt-avalista.nrcxapst
                               tt-contrato-avalista.complend = tt-avalista.complend
                               tt-contrato-avalista.inpessoa = tt-avalista.inpessoa
                               tt-contrato-avalista.cdnacion = tt-avalista.cdnacion
                               tt-contrato-avalista.dsnacion = tt-avalista.dsnacion
                               tt-contrato-avalista.nrctacjg = tt-avalista.nrctacjg
                               tt-contrato-avalista.nrcpfcjg = tt-avalista.nrcpfcjg
                               tt-contrato-avalista.vlrencjg = tt-avalista.vlrencjg
                               tt-contrato-avalista.vlrenmes = tt-avalista.vlrenmes
                               tt-contrato-avalista.dtnascto = tt-avalista.dtnascto.
                    END.
            END.

        /* 2 Busca Avalista que tem Conta */
        IF  crapepr.nrctaav2 > 0 THEN
            DO:
                EMPTY TEMP-TABLE tt-avalista.

                RUN Busca_Avalista(  
                    INPUT par_cdcooper,
                    INPUT crapepr.nrctaav2,
                    INPUT 0,
                   OUTPUT TABLE tt-avalista).                
            
                FIND FIRST tt-avalista NO-ERROR.
                IF  AVAIL tt-avalista THEN
                    DO:
                        CREATE tt-contrato-avalista.
                        ASSIGN tt-contrato-avalista.nrindice = 2
                               tt-contrato-avalista.nrctaava = tt-avalista.nrctaava
                               tt-contrato-avalista.nrcpfcgc = tt-avalista.nrcpfcgc
                               tt-contrato-avalista.nmdavali = tt-avalista.nmdavali
                               tt-contrato-avalista.dscpfava = tt-avalista.dscpfava
                               tt-contrato-avalista.nmcjgava = tt-avalista.nmcjgava
                               tt-contrato-avalista.dsendava[1] = tt-avalista.dsendava[1]
                               tt-contrato-avalista.dsendava[2] = tt-avalista.dsendava[2]
                               tt-contrato-avalista.dscfcava = tt-avalista.dscfcava
                               tt-contrato-avalista.nmcidade = tt-avalista.nmcidade
                               tt-contrato-avalista.nrfonres = tt-avalista.nrfonres
                               tt-contrato-avalista.dsdemail = tt-avalista.dsdemail
                               tt-contrato-avalista.cdufende = tt-avalista.cdufende
                               tt-contrato-avalista.nrcepend = tt-avalista.nrcepend 
                               tt-contrato-avalista.nrendere = tt-avalista.nrendere
                               tt-contrato-avalista.nrcxapst = tt-avalista.nrcxapst
                               tt-contrato-avalista.complend = tt-avalista.complend
                               tt-contrato-avalista.inpessoa = tt-avalista.inpessoa
                               tt-contrato-avalista.cdnacion = tt-avalista.cdnacion
                               tt-contrato-avalista.dsnacion = tt-avalista.dsnacion
                               tt-contrato-avalista.nrctacjg = tt-avalista.nrctacjg
                               tt-contrato-avalista.nrcpfcjg = tt-avalista.nrcpfcjg
                               tt-contrato-avalista.vlrencjg = tt-avalista.vlrencjg
                               tt-contrato-avalista.vlrenmes = tt-avalista.vlrenmes
                               tt-contrato-avalista.dtnascto = tt-avalista.dtnascto.
                    END.                                                            
            END.
        
        ASSIGN aux_returnvl = "OK".
        LEAVE Busca.
        
     END. /*  Busca */                                                              

     IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
         aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  AVAIL tt-erro THEN
                 ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE 
                 RUN gera_erro ( INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic ).

             IF  par_flgerlog  THEN
                 RUN proc_gerar_log ( INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT 1,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid ).
     
             RETURN "NOK".
         END.
     
     RETURN "OK".

END PROCEDURE. /* Busca_Contrato */


/* ------------------------------------------------------------------------ */
/*     VALIDACAO DOS DADOS DO AVALISTA P/ ALTERAR CONTRATO DE EMPRESTIMO    */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Avalista:

     DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdcontx AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
     DEF  INPUT PARAM par_idavalis AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrctaava AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nmdavali AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nrcpfava AS DECI                           NO-UNDO.
     DEF  INPUT PARAM par_nrcpfcjg AS DECI                           NO-UNDO.
     DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_cdufresd AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
     DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_dtnascto AS DATE                           NO-UNDO.
     
     DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
     DEF OUTPUT PARAM TABLE FOR tt-erro.
     
     DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

     EMPTY TEMP-TABLE tt-erro.

     ASSIGN aux_dscritic = ""
            aux_cdcritic = 0
            aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
            aux_returnvl = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        
        IF  par_nrctaava > 0 THEN
            DO:
                RUN Valida_Conta 
                    ( INPUT par_cdcooper,   
                      INPUT par_cdagenci,   
                      INPUT par_nrdcaixa,   
                      INPUT par_cdoperad,   
                      INPUT par_nmdatela,   
                      INPUT par_idorigem,   
                      INPUT par_dtmvtolt,   
                      INPUT par_nrdconta,   
                      INPUT par_nrctaava,   
                      INPUT FALSE, /* flgerlog */
                     OUTPUT TABLE tt-erro).
                
                IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN
                    LEAVE Valida.
            END.

        IF par_nrcpfava <> 0 THEN DO:
            IF par_inpessoa <> 1 AND 
               par_inpessoa <> 2 THEN DO:
    
                aux_dscritic = "Tipo Natureza deve ser Informada.".
    
                RUN gera_erro ( INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT 1,            /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic ).
    
                par_nmdcampo = "pro_inpessoa".
                LEAVE Valida.
            END.
        
            IF par_inpessoa = 1 AND
               par_dtnascto = ? THEN DO:
    
                aux_dscritic = "Data de Nascimento deve ser Informada.".
    
                RUN gera_erro ( INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT 1,            /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic ).
    
                 par_nmdcampo = "pro_dtnascto".
                 LEAVE Valida.
            END.
        END.

        IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
            RUN sistema/generico/procedures/b1wgen0024.p 
                PERSISTENT SET h-b1wgen0024.

        RUN valida-avalistas IN h-b1wgen0024 
                                (INPUT par_cdcooper,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT par_nrdconta, /* Conta ATENDA*/
                                 INPUT 999, /* parametro so do EMPRESTIMO */
                                 INPUT 999, /* parametro so do EMPRESTIMO */                                       
                                 INPUT par_nrdcontx, /* Conta 1.aval */
                                 INPUT par_nrcpfcgc, /* CPF 1.aval */
                                 INPUT par_idavalis, /* 1ero./2do. aval */
                                 INPUT par_nrctaava, /* Dados do aval em questao */
                                 INPUT par_nmdavali,
                                 INPUT par_nrcpfava,
                                 INPUT par_nrcpfcjg,
                                 INPUT par_dsendere,
                                 INPUT par_cdufresd,
                                 INPUT par_nrcepend,
                                 INPUT par_inpessoa,
                                OUTPUT par_nmdcampo,
                                OUTPUT TABLE tt-erro).

        IF  VALID-HANDLE(h-b1wgen0024)  THEN
            DELETE PROCEDURE h-b1wgen0024.

        IF   RETURN-VALUE <> "OK"   THEN
             DO: 
                 FIND FIRST tt-erro NO-LOCK NO-ERROR.

                 IF   NOT AVAIL tt-erro   THEN
                      ASSIGN aux_dscritic = "Erro na validaçao dos avalistas".
                  
                 LEAVE Valida.

             END.

        ASSIGN aux_returnvl = "OK".
        LEAVE Valida.
        
     END. /*  Valida */ 

     IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
         aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         DO:            
             ASSIGN aux_dstransa = "Valida dados do avalista".

             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  AVAIL tt-erro THEN
                 ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE 
                 RUN gera_erro ( INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic ).

             IF  par_flgerlog  THEN
                 RUN proc_gerar_log ( INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT 1,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid ).

             RETURN "NOK".
         END.
     
     RETURN "OK".

END PROCEDURE. /* Valida_Avalista */


/* ------------------------------------------------------------------------ */
/*       BUSCA DOS DADOS AVALISTA P/ ALTERAR CONTRATOS DE EMPRESTIMO        */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Avalista:

     DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrctaava AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.

     DEF OUTPUT PARAM TABLE FOR tt-avalista.
     
     DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
     DEF VAR aux_cdgraupr AS INTE                                    NO-UNDO.
	 DEF VAR aux_nrcpfcgc LIKE crapttl.nrcpfcgc                      NO-UNDO.
     
     EMPTY TEMP-TABLE tt-avalista.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        /* Busca o avalista que tem conta */
        IF  par_nrctaava > 0 THEN
            DO:
               CREATE tt-avalista.
               ASSIGN tt-avalista.nrctaava = par_nrctaava.

               FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND
                                  crapass.nrdconta = par_nrctaava  NO-LOCK NO-ERROR.

               IF   AVAIL crapass THEN
                    DO:
                       ASSIGN aux_cdgraupr = 0
                              aux_vlrenmes = 0.
                       
                       IF crapass.inpessoa = 1 THEN
                       DO:
                           FOR FIRST crapttl FIELDS(cdgraupr nrcpfcgc)
										      WHERE crapttl.cdcooper = par_cdcooper AND
                                              crapttl.nrdconta = crapass.nrdconta AND
                                    crapttl.idseqttl = 2 NO-LOCK:

						     ASSIGN aux_cdgraupr = crapttl.cdgraupr
							        aux_nrcpfcgc = crapttl.nrcpfcgc.
						   END.
                               

                          FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                             crapttl.nrdconta = crapass.nrdconta AND
                                             crapttl.idseqttl = 1 
                                             NO-LOCK NO-ERROR.

                          IF   AVAIL crapttl THEN
                               aux_vlrenmes = crapttl.vlsalari     + 
                                              crapttl.vldrendi[1]  + 
                                              crapttl.vldrendi[2]  +
                                              crapttl.vldrendi[3]  +
                                              crapttl.vldrendi[4]  +
                                              crapttl.vldrendi[5]  +
                                              crapttl.vldrendi[6]. 
                               
                       END.

                       IF   crapass.inpessoa = 2 THEN /*Faturamento Avalista PJ*/
                       DO:

                           IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                               RUN sistema/generico/procedures/b1wgen9999.p
                                   PERSISTENT SET h-b1wgen9999.

                           RUN calcula-faturamento IN h-b1wgen9999
                                       (INPUT  par_cdcooper,
                                        INPUT  crapass.cdagenci,
                                        INPUT  0,
                                        INPUT  0,
                                        INPUT  crapass.nrdconta, /*Conta avalista*/
                                        INPUT  "",
                                        OUTPUT aux_vlmedfat).
                   
                           IF  VALID-HANDLE(h-b1wgen9999)  THEN
                               DELETE PROCEDURE h-b1wgen9999.

                           ASSIGN aux_vlrenmes = aux_vlmedfat.
                       END.

                       FIND crapenc WHERE 
                            crapenc.cdcooper = par_cdcooper      AND
                            crapenc.nrdconta = crapass.nrdconta  AND
                            crapenc.idseqttl = 1                 AND
                            crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.
                            
                       FIND FIRST crapcem WHERE crapcem.cdcooper = par_cdcooper     AND
                                                crapcem.nrdconta = crapass.nrdconta AND
                                                crapcem.idseqttl = 1 
                                                NO-LOCK NO-ERROR.

                       FIND FIRST craptfc /* FIELDS(nrdddtfc nrtelefo) */
                                         WHERE craptfc.cdcooper = par_cdcooper     AND
                                               craptfc.nrdconta = crapass.nrdconta AND
                                               craptfc.idseqttl = 1 
                                         NO-LOCK NO-ERROR.
                            
                       /* Limpar o nome do conjuge */
                       ASSIGN aux_nmconjug = ""
                              aux_nrcpfcjg = 0
                              aux_nrctacjg = 0
                              aux_vlrencjg = 0.
                       FIND  crapcje WHERE crapcje.cdcooper = par_cdcooper AND 
                                           crapcje.nrdconta = crapass.nrdconta AND 
                                           crapcje.idseqttl = 1 USE-INDEX crapcje1 NO-ERROR.
                        
                       IF AVAIL crapcje THEN
                       DO:
                           /* Validar se o numero da conta do conjuge é maior que zero
                              busca as informações do nome do primeiro titular da conta de conjuge*/
                           IF crapcje.nrctacje > 0 THEN
                           DO:
                              FIND crapttl WHERE crapttl.cdcooper = crapcje.cdcooper
                                             AND crapttl.nrdconta = crapcje.nrctacje
                                             AND crapttl.idseqttl = 1
                                           NO-LOCK NO-ERROR.
                              /* Se possuir titular carrega o nome */
                              IF AVAIL crapttl THEN
                                  ASSIGN aux_nmconjug = crapttl.nmextttl
                                         aux_nrcpfcjg = crapttl.nrcpfcgc
                                         aux_nrctacjg = crapttl.nrdconta
                                         aux_vlrencjg = crapttl.vlsalari     + 
                                                        crapttl.vldrendi[1]  + 
                                                        crapttl.vldrendi[2]  +
                                                        crapttl.vldrendi[3]  +
                                                        crapttl.vldrendi[4]  +
                                                        crapttl.vldrendi[5]  +
                                                        crapttl.vldrendi[6].
                           END.
                           ELSE
                               /* Se o numero da conta não é maior que zero carrega o nome da crapcje */
                               ASSIGN aux_nmconjug = crapcje.nmconjug
                                      aux_nrcpfcjg = crapcje.nrcpfcjg
                                      aux_nrctacjg = crapcje.nrctacje
                                      aux_vlrencjg = crapcje.vlsalari.
                       END.
                       

                       ASSIGN tt-avalista.nmdavali    = crapass.nmprimtl
                              tt-avalista.nrcpfcgc    = crapass.nrcpfcgc
                              tt-avalista.nmcjgava    = aux_nmconjug
                              tt-avalista.dsendava[1] = crapenc.dsendere
                              tt-avalista.dscfcava    = IF aux_cdgraupr = 1   
                                                THEN
                                                    STRING(aux_nrcpfcgc,
                                                     "99999999999")
                                                ELSE ""
                                                   tt-avalista.dscfcava = STRING(tt-avalista.dscfcava,
                                                               "xxx.xxx.xxx-xx")
                             tt-avalista.dscfcava = IF   tt-avalista.dscfcava <> " "
                                             THEN "C.P.F. " +
                                                  tt-avalista.dscfcava
                                             ELSE
                                                  ""                  
                              tt-avalista.dsendava[2] = TRIM(crapenc.nmbairro)
                              tt-avalista.nmcidade    = TRIM(crapenc.nmcidade)
                              tt-avalista.nrfonres    = STRING(craptfc.nrdddtfc) +
                                                        STRING(craptfc.nrtelefo)
                                                        WHEN AVAIL craptfc
                              tt-avalista.dsdemail    = crapcem.dsdemail
                                                        WHEN AVAIL crapcem
                              tt-avalista.cdufende    = crapenc.cdufende
                              tt-avalista.nrcepend    = crapenc.nrcepend
                              tt-avalista.nrendere    = crapenc.nrendere
                              tt-avalista.nrcxapst    = crapenc.nrcxapst
                              tt-avalista.complend    = crapenc.complend
                              tt-avalista.inpessoa    = crapass.inpessoa
                              tt-avalista.cdnacion    = crapass.cdnacion
                              tt-avalista.nrctacjg    = aux_nrctacjg
                              tt-avalista.nrcpfcjg    = aux_nrcpfcjg
                              tt-avalista.vlrencjg    = aux_vlrencjg
                              tt-avalista.vlrenmes    = aux_vlrenmes                              
                              tt-avalista.dtnascto    = crapass.dtnasctl.

                       IF   crapass.inpessoa = 1 THEN
                            ASSIGN  tt-avalista.dscpfava = STRING(crapass.nrcpfcgc,
                                                          "99999999999")
                                    tt-avalista.dscpfava = STRING(tt-avalista.dscpfava,
                                                          "xxx.xxx.xxx-xx")

                                    tt-avalista.dscpfava = "C.P.F. " +
                                                   tt-avalista.dscpfava.
                       ELSE
                            ASSIGN  tt-avalista.dscpfava = STRING(crapass.nrcpfcgc,
                                                          "99999999999999")
                                    tt-avalista.dscpfava=  STRING(tt-avalista.dscpfava,
                                                          "xx.xxx.xxx/xxxx-xx")

                                    tt-avalista.dscpfava = "CNPJ " +
                                                   tt-avalista.dscpfava.
                    END.
                ELSE
                    DO:
                        ASSIGN tt-avalista.nmdavali = "** Nao cadastrado **"
                               tt-avalista.dsendava = ""
                               tt-avalista.dscpfava = ""
                               tt-avalista.nmcjgava = ""
                               tt-avalista.dscfcava = "".
                    END.


               ASSIGN  tt-avalista.dscpfava = tt-avalista.dscpfava +
                                   FILL(" ",30 - LENGTH(tt-avalista.dscpfava)) +
                                   STRING( par_nrctaava,"zzzz,zzz,9").
            END. /* IF  par_nrctaava > 0 THEN */
        ELSE 
            /* Busca o avalista pelo CPF */
            IF  par_nrcpfcgc > 0 THEN
                DO:
                    FIND LAST crapavt WHERE crapavt.cdcooper = par_cdcooper  AND
                                            crapavt.nrcpfcgc = par_nrcpfcgc  NO-LOCK NO-ERROR.
    
                    IF   AVAIL crapavt THEN 
                         DO:
                            CREATE tt-avalista.
                            ASSIGN tt-avalista.nmdavali    = crapavt.nmdavali 
                                   tt-avalista.nrcpfcgc    = crapavt.nrcpfcgc
                                   tt-avalista.tpdocava    = crapavt.tpdocava
                                   tt-avalista.dscpfava    = crapavt.nrdocava
                                   tt-avalista.nmcjgava    = crapavt.nmconjug
                                   tt-avalista.nrcpfcjg    = crapavt.nrcpfcjg
                                   tt-avalista.tpdoccjg    = crapavt.tpdoccjg 
                                   tt-avalista.dscfcava    = crapavt.nrdoccjg
                                   tt-avalista.dsendava[1] = crapavt.dsendres[1]
                                   tt-avalista.dsendava[2] = crapavt.dsendres[2]
                                   tt-avalista.nrfonres    = crapavt.nrfonres
                                   tt-avalista.dsdemail    = crapavt.dsdemail
                                   tt-avalista.nmcidade    = crapavt.nmcidade
                                   tt-avalista.cdufende    = crapavt.cdufresd
                                   tt-avalista.nrcepend    = crapavt.nrcepend
                                   tt-avalista.nrendere    = crapavt.nrendere
                                   tt-avalista.nrcxapst    = crapavt.nrcxapst
                                   tt-avalista.complend    = crapavt.complend
                                   tt-avalista.inpessoa    = crapavt.inpessoa
                                   tt-avalista.cdnacion    = crapavt.cdnacion
                                   tt-avalista.nrctacjg    = 0
                                   tt-avalista.vlrencjg    = crapavt.vlrencjg
                                   tt-avalista.vlrenmes    = crapavt.vlrenmes
                                   tt-avalista.dtnascto    = crapavt.dtnascto.

                        END. /* IF   AVAIL crapavt THEN  */
                END. /* IF  par_nrcpfcgc > 0 THEN */

        /* Buscar a Nacionalidade */
        FOR FIRST crapnac FIELDS(dsnacion)
                          WHERE crapnac.cdnacion = tt-avalista.cdnacion
                                NO-LOCK:
            ASSIGN tt-avalista.dsnacion = crapnac.dsnacion.
        END.

        LEAVE Busca.
        
     END. /*  Busca */

     RETURN "OK".

END PROCEDURE. /* Busca_Avalista */


/* ------------------------------------------------------------------------ */
/*       GRAVA OS DADOS DO AVALISTA ALTERADO NO CONTRATO DE EMPRESTIMO      */
/* ------------------------------------------------------------------------ */
PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp  AS INTE                           NO-UNDO.
    
    /* 1 Avalista */
    DEF  INPUT PARAM par_nrctaav1  AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_cpfcgc1   AS DECI                           NO-UNDO. 
    DEF  INPUT PARAM par_nmdaval1  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_cpfccg1   AS DECI                           NO-UNDO. 
    DEF  INPUT PARAM par_nmcjgav1  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_tpdoccj1  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dscfcav1  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_tpdocav1  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dscpfav1  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dsenda11  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dsenda12  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nrfonres1 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dsdemail1 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nmcidade1 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_cdufresd1 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nrcepend1 AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nrendere1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complend1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacion1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlrencjg1 AS DECI                           NO-UNDO. 
    DEF  INPUT PARAM par_vlrenmes1 AS DECI                           NO-UNDO. 
    DEF  INPUT PARAM par_dtnascto1 AS DATE                           NO-UNDO.

    /* 2 Avalista */
    DEF  INPUT PARAM par_nrctaav2  AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_cpfcgc2   AS DECI                           NO-UNDO. 
    DEF  INPUT PARAM par_nmdaval2  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_cpfccg2   AS DECI                           NO-UNDO. 
    DEF  INPUT PARAM par_nmcjgav2  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_tpdoccj2  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dscfcav2  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_tpdocav2  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dscpfav2  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dsenda21  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dsenda22  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nrfonres2 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dsdemail2 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nmcidade2 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_cdufresd2 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nrcepend2 AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nrendere2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complend2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacion2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlrencjg2 AS DECI                           NO-UNDO. 
    DEF  INPUT PARAM par_vlrenmes2 AS DECI                           NO-UNDO. 
    DEF  INPUT PARAM par_dtnascto2 AS DATE                           NO-UNDO.

    DEF  INPUT PARAM par_flgerlog  AS LOGICAL                        NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-contrato-imprimir.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrcpfava AS DECI                                     NO-UNDO.
    DEF VAR aux_nmdavali AS CHAR                                     NO-UNDO.
    DEF VAR aux_uladitiv AS INTE                                     NO-UNDO.   
    DEF VAR aux_contador AS INTE                                     NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                     NO-UNDO.
    DEF VAR aux_nrctaav1 AS INTE                                     NO-UNDO.
    DEF VAR aux_nrcpfcg1 AS DECI                                     NO-UNDO.
    DEF VAR aux_nrctaav2 AS INTE                                     NO-UNDO.
    DEF VAR aux_nrcpfcg2 AS DECI                                     NO-UNDO.
    DEF VAR aux_flgaval1 AS LOGICAL                                  NO-UNDO.
    DEF VAR aux_flgaval2 AS LOGICAL                                  NO-UNDO.
    DEF VAR aux_dsrotina AS CHAR                                     NO-UNDO.    
    DEF VAR aux_flgpropo AS LOG                                      NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE                                   NO-UNDO.
    DEF VAR h-b1wgen0168 AS HANDLE                                   NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_flgaval1 = FALSE 
           aux_flgaval2 = FALSE
           aux_nrctaav1 = 0 
           aux_nrcpfcg1 = 0
           aux_nrctaav2 = 0
           aux_nrcpfcg2 = 0
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_returnvl = "NOK"
           aux_dsrotina = ""           
           aux_flgpropo = TRUE.
           

    Grava: DO TRANSACTION ON ERROR UNDO Grava, LEAVE Grava:
        
        /* Busca os antigos avalista para ver teve alteracao */
        RUN Busca_Contrato
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
              INPUT par_cdoperad,
              INPUT par_nmdatela,
              INPUT par_idorigem, 
              INPUT par_dtmvtolt,
              INPUT par_nrdconta,
              INPUT par_nrctremp,
              INPUT FALSE, /* flgerlog */
             OUTPUT TABLE tt-contrato,
             OUTPUT TABLE tt-contrato-avalista,
             OUTPUT TABLE tt-erro).
        
        IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN
            UNDO Grava, LEAVE Grava.
        
        /* Dados do avalista 1 */
        FIND FIRST tt-contrato-avalista 
             WHERE tt-contrato-avalista.nrindice = 1 NO-ERROR.
        
        IF  AVAIL tt-contrato-avalista THEN
            DO:
                ASSIGN  aux_nrctaav1 = tt-contrato-avalista.nrctaava
                        aux_nrcpfcg1 = tt-contrato-avalista.nrcpfcgc.
            END.
        
        /* verifica se a alteracao foi no 1o. avalista */
        IF   (aux_nrctaav1 <> par_nrctaav1 AND 
              par_nrctaav1 <> 0)           OR
             (aux_nrcpfcg1 <> par_cpfcgc1  AND 
              par_cpfcgc1  <> 0)           THEN
              DO:
                  IF   par_nrctaav1 > 0   THEN
                       DO:
                           FIND crapass WHERE 
                                crapass.cdcooper =  par_cdcooper    AND
                                crapass.nrdconta =  par_nrctaav1    
                                NO-LOCK NO-ERROR.

                           ASSIGN aux_nrcpfava = crapass.nrcpfcgc
                                  aux_nmdavali = crapass.nmprimtl.
                       END.
                  ELSE
                       ASSIGN aux_nrcpfava = par_cpfcgc1
                              aux_nmdavali = par_nmdaval1.
                  /**/
                  RUN Cria_Aditivo ( INPUT par_cdcooper,
                                     INPUT par_dtmvtolt,
                                     INPUT par_nrdconta,
                                     INPUT par_nrctremp,
                                     INPUT aux_nrcpfava,
                                     INPUT aux_nmdavali,
                                     INPUT par_cdagenci,
                                     INPUT par_cdoperad,
                                    OUTPUT aux_uladitiv).

                  IF  aux_cdcritic <> 0 THEN
                      UNDO Grava, LEAVE Grava.
                  
                  CREATE tt-contrato-imprimir.
                  ASSIGN tt-contrato-imprimir.nrcpfava = aux_nrcpfava
                         tt-contrato-imprimir.nmdavali = aux_nmdavali
                         tt-contrato-imprimir.uladitiv = aux_uladitiv
                         aux_flgaval1 = TRUE.
                  
              END.
        
        /* Dados do avalista 2 */
        FIND FIRST tt-contrato-avalista WHERE tt-contrato-avalista.nrindice = 2
                                              NO-ERROR.
        
        IF  AVAIL tt-contrato-avalista THEN
            DO:
                ASSIGN  aux_nrctaav2 = tt-contrato-avalista.nrctaava
                        aux_nrcpfcg2 = tt-contrato-avalista.nrcpfcgc.
            END.

        /* verifica se a alteracao foi no 2o. avalista */
        IF   (aux_nrctaav2 <> par_nrctaav2 AND 
              par_nrctaav2 <> 0)           OR 
             (aux_nrcpfcg2 <> par_cpfcgc2  AND 
              par_cpfcgc2  <> 0)           THEN
              DO:
                  IF   par_nrctaav2 > 0   THEN
                       DO:
                           FIND crapass WHERE 
                                crapass.cdcooper = par_cdcooper    AND
                                crapass.nrdconta = par_nrctaav2    
                                NO-LOCK NO-ERROR.

                           ASSIGN aux_nrcpfava = crapass.nrcpfcgc
                                  aux_nmdavali = crapass.nmprimtl.
                       END.
                  ELSE
                       ASSIGN aux_nrcpfava = par_cpfcgc2
                              aux_nmdavali = par_nmdaval2.
                  /**/
                  RUN Cria_Aditivo ( INPUT par_cdcooper,
                                     INPUT par_dtmvtolt,
                                     INPUT par_nrdconta,
                                     INPUT par_nrctremp,
                                     INPUT aux_nrcpfava,
                                     INPUT aux_nmdavali,
                                     INPUT par_cdagenci,
                                     INPUT par_cdoperad,
                                    OUTPUT aux_uladitiv).

                  IF  aux_cdcritic <> 0 THEN
                      UNDO Grava, LEAVE Grava.
                  
                  CREATE tt-contrato-imprimir.
                  ASSIGN tt-contrato-imprimir.nrcpfava = aux_nrcpfava
                         tt-contrato-imprimir.nmdavali = aux_nmdavali
                         tt-contrato-imprimir.uladitiv = aux_uladitiv
                         aux_flgaval2 = TRUE.
                         
              END.                                                    
       
       
          /* Grava os dados do avalista */
       Contador: DO aux_contador = 1 TO 10:
       
          FIND crapepr WHERE crapepr.cdcooper = par_cdcooper  AND
                             crapepr.nrdconta = par_nrdconta  AND
                             crapepr.nrctremp = par_nrctremp
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
          IF  NOT AVAIL crapepr THEN
               DO:
                   IF  LOCKED crapepr   THEN
                       DO:
                           IF  aux_contador = 10 THEN
                               DO:
                                   ASSIGN aux_cdcritic = 77.
                                   LEAVE Contador.
                               END.
                           ELSE
                               DO:
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT Contador.
                               END.
                       END.
                   ELSE
                       DO:
                            
                           ASSIGN aux_cdcritic = 356.                                  
                           LEAVE Contador.
                       END.
               END.
          ELSE
               LEAVE Contador.
       
       END.  /*  Contador  */
       
       IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
           UNDO Grava, LEAVE Grava.        
       

       Contador: DO aux_contador = 1 TO 10:
       
          FIND crawepr WHERE crawepr.cdcooper = par_cdcooper  AND
                             crawepr.nrdconta = par_nrdconta  AND
                             crawepr.nrctremp = par_nrctremp
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
          IF  NOT AVAIL crawepr THEN 
              DO:
                  IF  LOCKED crawepr   THEN
                      DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                  ASSIGN aux_cdcritic = 77.
                                  LEAVE Contador.
                              END.
                          ELSE
                              DO:
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT Contador.
                              END.
                      END.
                  ELSE
                      DO:                          
                          ASSIGN aux_flgpropo = FALSE.
                          LEAVE Contador.
                      END.
              END.
          ELSE
              LEAVE Contador.
       
       END.  /*  Contador  */       
    
       IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
           UNDO Grava, LEAVE Grava.
       
       IF  crapepr.nrctaav1 <> 0 THEN
           DO:
              FOR EACH crapavl WHERE crapavl.cdcooper = par_cdcooper      AND
                                     crapavl.nrdconta = crapepr.nrctaav1  AND
                                     crapavl.nrctravd = crapepr.nrctremp  AND
                                     crapavl.nrctaavd = crapepr.nrdconta  AND 
                                     crapavl.tpctrato = 1
                                     EXCLUSIVE-LOCK:
                  DELETE crapavl.
              END.
           END.
       
       IF  crapepr.nrctaav2 <> 0 THEN
           DO:
              FOR EACH crapavl WHERE crapavl.cdcooper = par_cdcooper      AND
                                     crapavl.nrdconta = crapepr.nrctaav2  AND
                                     crapavl.nrctravd = crapepr.nrctremp  AND
                                     crapavl.nrctaavd = crapepr.nrdconta  AND 
                                     crapavl.tpctrato = 1
                                     EXCLUSIVE-LOCK:
                  DELETE crapavl.
              END.
           END.
       
       /* Atualizacao CRAPEPR */
       ASSIGN crapepr.nrctaav1 = par_nrctaav1
              crapepr.nrctaav2 = par_nrctaav2.
         
       /* Atualizacao CRAPAVL */
       IF  crapepr.nrctaav1 > 0 THEN
           DO:
              CREATE crapavl.              /*  Primeiro avalista  */
              ASSIGN crapavl.tpctrato = 1
                     crapavl.nrdconta = crapepr.nrctaav1
                     crapavl.nrctravd = crapepr.nrctremp
                     crapavl.nrctaavd = crapepr.nrdconta
                     crapavl.cdcooper = par_cdcooper.
              VALIDATE crapavl.
           END.
           
       IF  crapepr.nrctaav2 > 0 THEN
           DO:
              CREATE crapavl.              /*  Segundo avalista  */
              ASSIGN crapavl.tpctrato = 1
                     crapavl.nrdconta = crapepr.nrctaav2
                     crapavl.nrctravd = crapepr.nrctremp
                     crapavl.nrctaavd = crapepr.nrdconta
                     crapavl.cdcooper = par_cdcooper.
              VALIDATE crapavl.
           END.
       
       FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper        AND
                              crapavt.tpctrato = 1                   AND
                              crapavt.nrdconta = crapepr.nrdconta    AND
                              crapavt.nrctremp = crapepr.nrctremp
                              EXCLUSIVE-LOCK:
           DELETE crapavt.
       END.
       
       IF  par_nrctaav1 = 0         AND
           TRIM(par_nmdaval1) <> "" THEN
           DO:
              CREATE crapavt.
              ASSIGN crapavt.dtmvtolt    = par_dtmvtolt
                     crapavt.tpctrato    = 1
                     crapavt.nrdconta    = crapepr.nrdconta
                     crapavt.nrctremp    = crapepr.nrctremp
                     crapavt.nrcpfcgc    = par_cpfcgc1
                     crapavt.nmdavali    = CAPS(par_nmdaval1)
                     crapavt.nrcpfcjg    = par_cpfccg1
                     crapavt.nmconjug    = CAPS(par_nmcjgav1)
                     crapavt.tpdoccjg    = CAPS(par_tpdoccj1)
                     crapavt.nrdoccjg    = CAPS(par_dscfcav1)
                     crapavt.tpdocava    = CAPS(par_tpdocav1)
                     crapavt.nrdocava    = CAPS(par_dscpfav1)
                     crapavt.dsendres[1] = CAPS(par_dsenda11)
                     crapavt.dsendres[2] = CAPS(par_dsenda12)
                     crapavt.nrfonres    = CAPS(par_nrfonres1)
                     crapavt.dsdemail    = CAPS(par_dsdemail1)
                     crapavt.nmcidade    = CAPS(par_nmcidade1)
                     crapavt.cdufresd    = CAPS(par_cdufresd1)
                     crapavt.nrcepend    = par_nrcepend1
                     crapavt.nrendere    = par_nrendere1
                     crapavt.complend    = CAPS(par_complend1)
                     crapavt.nrcxapst    = par_nrcxapst1
                     crapavt.cdcooper    = par_cdcooper
                     crapavt.inpessoa    = par_inpessoa1
                     crapavt.cdnacion    = par_cdnacion1
                     crapavt.vlrencjg    = par_vlrencjg1
                     crapavt.vlrenmes    = par_vlrenmes1
                     crapavt.dtnascto    = par_dtnascto1. 
              VALIDATE crapavt.
           END.
       
       IF  par_nrctaav2 = 0          AND
           TRIM(par_nmdaval2) <> "" THEN
           DO:
              CREATE crapavt.
              ASSIGN crapavt.dtmvtolt    = par_dtmvtolt
                     crapavt.tpctrato    = 1
                     crapavt.nrdconta    = crapepr.nrdconta
                     crapavt.nrctremp    = crapepr.nrctremp
                     crapavt.nrcpfcgc    = par_cpfcgc2
                     crapavt.nmdavali    = CAPS(par_nmdaval2)
                     crapavt.nrcpfcjg    = par_cpfccg2
                     crapavt.nmconjug    = CAPS(par_nmcjgav2)
                     crapavt.tpdoccjg    = CAPS(par_tpdoccj2)
                     crapavt.nrdoccjg    = CAPS(par_dscfcav2)
                     crapavt.tpdocava    = CAPS(par_tpdocav2)
                     crapavt.nrdocava    = CAPS(par_dscpfav2)
                     crapavt.dsendres[1] = CAPS(par_dsenda21)
                     crapavt.dsendres[2] = CAPS(par_dsenda22)
                     crapavt.nrfonres    = CAPS(par_nrfonres2)
                     crapavt.dsdemail    = CAPS(par_dsdemail2)
                     crapavt.nmcidade    = CAPS(par_nmcidade2)
                     crapavt.cdufresd    = CAPS(par_cdufresd2)
                     crapavt.nrcepend    = par_nrcepend2
                     crapavt.nrendere    = par_nrendere2
                     crapavt.complend    = CAPS(par_complend2)
                     crapavt.nrcxapst    = par_nrcxapst2
                     crapavt.cdcooper    = par_cdcooper
                     crapavt.inpessoa    = par_inpessoa2
                     crapavt.cdnacion    = par_cdnacion2
                     crapavt.vlrencjg    = par_vlrencjg2
                     crapavt.vlrenmes    = par_vlrenmes2
                     crapavt.dtnascto    = par_dtnascto2.
              VALIDATE crapavt.
           END.
              
       /* Se achou proposta de emprestimo */
       IF  aux_flgpropo THEN
           DO:
               ASSIGN  crawepr.nrctaav1    = par_nrctaav1
                       crawepr.nrctaav2    = par_nrctaav2
                       crawepr.nmdaval1    = CAPS(par_nmdaval1)
                       crawepr.dscpfav1    = CAPS(par_dscpfav1)
                       crawepr.nmcjgav1    = CAPS(par_nmcjgav1)
                       crawepr.dscfcav1    = CAPS(par_dscfcav1)
               
                       crawepr.dsendav1[1] = CAPS(par_dsenda11) + " " +
                                             STRING(par_nrendere1)
                       crawepr.dsendav1[2] = STRING(CAPS(par_dsenda12) + " - " +
                                                    CAPS(par_nmcidade1) + " - " +
                                             STRING(par_nrcepend1,"99,999,999"))
               
                       crawepr.nmdaval2    = CAPS(par_nmdaval2)
                       crawepr.dscpfav2    = CAPS(par_dscpfav2)
                       crawepr.nmcjgav2    = CAPS(par_nmcjgav2)
                       crawepr.dscfcav2    = CAPS(par_dscfcav2)
                       crawepr.dsendav2[1] = CAPS(par_dsenda21) + " " +
                                             STRING(par_nrendere2)
                       crawepr.dsendav2[2] = STRING(CAPS(par_dsenda22) + " - " +
                                             CAPS(par_nmcidade2) + " - " +
                                             STRING(par_nrcepend2,"99,999,999"))
                       crawepr.cdcooper    = par_cdcooper.
               
               IF  par_nrctaav1 = 0         AND  
                   TRIM(par_nmdaval1) <> "" THEN
                   DO:
                      ASSIGN crawepr.dscpfav1 = " "
                             crawepr.dscfcav1 = " "
                             crawepr.dscpfav1 = TRIM(CAPS(par_tpdocav1)) + " " +
                                                TRIM(CAPS(par_dscpfav1)) + " C.P.F. " +
                                                STRING(par_cpfcgc1).
                      IF  par_cpfccg1 > 0 THEN
                          DO:    
                             ASSIGN crawepr.dscfcav1 =
                                    TRIM(CAPS(par_tpdoccj1)) + " " +
                                    TRIM(CAPS(par_dscfcav1)) + " C.P.F. " +
                                    STRING(par_cpfccg1).
                          END.
                   END.        
               
               IF  par_nrctaav2 = 0         AND  
                   TRIM(par_nmdaval2) <> "" THEN
                   DO:
                      ASSIGN crawepr.dscpfav2 = " "
                             crawepr.dscfcav2 = " "
                             crawepr.dscpfav2 = TRIM(CAPS(par_tpdocav2)) + " " +
                                                TRIM(CAPS(par_dscpfav2)) + " C.P.F. " +
                                                STRING(par_cpfcgc2).
                      IF  par_cpfccg2 > 0 THEN
                          DO:    
                            ASSIGN crawepr.dscfcav2 = TRIM(CAPS(par_tpdoccj2)) + " " +
                                                      TRIM(CAPS(par_dscfcav2)) +
                                                      " C.P.F. " +
                                                      STRING(par_cpfcgc2).
                          END.
                   END.       
           END.
       
       IF par_nrctaav1 > 0     OR 
         (par_nrctaav1 = 0     AND  
          TRIM(par_nmdaval1) <> "") THEN
          DO:
             /*Monta a mensagem da rotina para envio no e-mail*/
             ASSIGN aux_dsrotina = "Inclusao/alteracao "                  +
                                   "do Avalista conta "                   +
                                   STRING(par_nrctaav1,"zzzz,zzz,9")      +
                                   " - CPF/CNPJ "                         +
                                   STRING(par_cpfcgc1)                    +
                                   " na conta "                           +
                                   STRING(par_nrdconta,"zzzz,zzz,9").
             
             IF NOT VALID-HANDLE(h-b1wgen0110) THEN
                RUN sistema/generico/procedures/b1wgen0110.p 
                    PERSISTENT SET h-b1wgen0110.
             
             /*Verifica se o primeiro avalista esta no cadastro restritivo. 
               Se estiver, sera enviado um e-mail informando a situacao*/
             RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                               INPUT 0, /*cdagenci*/
                                               INPUT 0, /*nrdcaixa*/
                                               INPUT par_cdoperad,
                                               INPUT "", /*nmdatela*/
                                               INPUT par_dtmvtolt,
                                               INPUT par_idorigem,
                                               INPUT par_cpfcgc1,
                                               INPUT par_nrctaav1,
                                               INPUT 1, /*idseqttl*/
                                               INPUT FALSE, /*nao bloq. operacao*/
                                               INPUT 32, /*cdoperac*/
                                               INPUT aux_dsrotina,
                                               OUTPUT TABLE tt-erro).

             IF VALID-HANDLE(h-b1wgen0110) THEN
                DELETE PROCEDURE h-b1wgen0110.
            
             IF RETURN-VALUE <> "OK" THEN
                DO:  
                   FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                   IF NOT AVAIL tt-erro THEN
                      DO:
                         ASSIGN aux_dscritic = "Nao foi possivel "    + 
                                               "verificar o "         +
                                               "cadastro restritivo.".
          
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1, /*sequencia*/
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
                         
                      END.
                    
                    UNDO Grava, LEAVE Grava.
                    
                END.
            
        END.
       
       IF par_nrctaav2 > 0     OR 
         (par_nrctaav2 = 0     AND  
          TRIM(par_nmdaval2) <> "") THEN
          DO:
             /*Monta a mensagem da rotina para envio no e-mail*/
             ASSIGN aux_dsrotina = "Inclusao/alteracao "                  +
                                   "do Avalista conta "                   +
                                   STRING(par_nrctaav2,"zzzz,zzz,9")      +
                                   " - CPF/CNPJ "                         +
                                   STRING(par_cpfcgc2)                    +
                                   " na conta "                           +
                                   STRING(par_nrdconta,"zzzz,zzz,9").
             
             IF NOT VALID-HANDLE(h-b1wgen0110) THEN
                RUN sistema/generico/procedures/b1wgen0110.p 
                    PERSISTENT SET h-b1wgen0110.
             
             /*Verifica se o primeiro avalista esta no cadastro restritivo.
               Se estiver, sera enviado um e-mail informando a situacao*/
             RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                               INPUT 0, /*cdagenci*/
                                               INPUT 0, /*nrdcaixa*/
                                               INPUT par_cdoperad,
                                               INPUT "", /*nmdatela*/
                                               INPUT par_dtmvtolt,
                                               INPUT par_idorigem,
                                               INPUT par_cpfcgc2,
                                               INPUT par_nrctaav2,
                                               INPUT 1, /*idseqttl*/
                                               INPUT FALSE, /*nao bloq. operacao*/
                                               INPUT 32, /*cdoperac*/
                                               INPUT aux_dsrotina,
                                               OUTPUT TABLE tt-erro).

             IF VALID-HANDLE(h-b1wgen0110) THEN
                DELETE PROCEDURE h-b1wgen0110.

             IF RETURN-VALUE <> "OK" THEN
                DO:  
                   FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                   IF NOT AVAIL tt-erro THEN
                      DO:
                         ASSIGN aux_dscritic = "Nao foi possivel "    + 
                                               "verificar o "         +
                                               "cadastro restritivo.".
          
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1, /*sequencia*/
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
                         
                      END.
                   
                   UNDO Grava, LEAVE Grava.
                   
                END.

          END.

       /* INICIO - Atualizar os dados da tabela crapcyb (CYBER) */
       IF NOT VALID-HANDLE(h-b1wgen0168) THEN
          RUN sistema/generico/procedures/b1wgen0168.p
              PERSISTENT SET h-b1wgen0168.
                 
       EMPTY TEMP-TABLE tt-crapcyb.

       CREATE tt-crapcyb.
       ASSIGN tt-crapcyb.cdcooper = par_cdcooper
              tt-crapcyb.cdorigem = 3
              tt-crapcyb.nrdconta = par_nrdconta
              tt-crapcyb.nrctremp = par_nrctremp
              tt-crapcyb.dtmanavl = par_dtmvtolt.

       RUN atualiza_data_manutencao_avalista
           IN h-b1wgen0168(INPUT  TABLE tt-crapcyb,
                           OUTPUT aux_cdcritic,
                           OUTPUT aux_dscritic).
                 
       IF VALID-HANDLE(h-b1wgen0168) THEN
          DELETE PROCEDURE(h-b1wgen0168).

       IF RETURN-VALUE <> "OK" THEN
          UNDO Grava, LEAVE Grava.
       /* FIM - Atualizar os dados da tabela crapcyb */

       ASSIGN aux_returnvl = "OK".
       LEAVE Grava.
        
     END. /*  Grava */

     ASSIGN aux_dstransa = "Grava dados do avalista".

     IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
         aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         DO:                       
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  AVAIL tt-erro THEN
                 ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE 
                 RUN gera_erro ( INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic ).

             ASSIGN  aux_returnvl = "NOK".
             
         END.
        
     
     IF  par_flgerlog  THEN
         DO:
             RUN proc_gerar_log ( INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT aux_dscritic,
                                  INPUT aux_dsorigem,
                                  INPUT aux_dstransa,
                                  INPUT (IF aux_returnvl = "OK" THEN TRUE ELSE FALSE),
                                  INPUT 1,
                                  INPUT par_nmdatela,
                                  INPUT par_nrdconta,
                                 OUTPUT aux_nrdrowid ).

             /* gera log dos itens */
             RUN Gera_Log (INPUT aux_flgaval1,  
                           INPUT par_nrctaav1,  
                           INPUT par_cpfcgc1,  
                           INPUT par_nmdaval1,  
                           INPUT par_cpfccg1,   
                           INPUT par_nmcjgav1,  
                           INPUT par_tpdoccj1,  
                           INPUT par_dscfcav1,  
                           INPUT par_tpdocav1,  
                           INPUT par_dscpfav1,  
                           INPUT par_dsenda11,  
                           INPUT par_dsenda12,  
                           INPUT par_nrfonres1, 
                           INPUT par_dsdemail1, 
                           INPUT par_nmcidade1, 
                           INPUT par_cdufresd1, 
                           INPUT par_nrcepend1, 
                           INPUT par_nrendere1, 
                           INPUT par_complend1, 
                           INPUT par_nrcxapst1, 
                           INPUT aux_flgaval2,  
                           INPUT par_nrctaav2,  
                           INPUT par_cpfcgc2,   
                           INPUT par_nmdaval2,  
                           INPUT par_cpfccg2,   
                           INPUT par_nmcjgav2,  
                           INPUT par_tpdoccj2,  
                           INPUT par_dscfcav2,  
                           INPUT par_tpdocav2,  
                           INPUT par_dscpfav2,  
                           INPUT par_dsenda21,  
                           INPUT par_dsenda22,  
                           INPUT par_nrfonres2, 
                           INPUT par_dsdemail2, 
                           INPUT par_nmcidade2, 
                           INPUT par_cdufresd2, 
                           INPUT par_nrcepend2, 
                           INPUT par_nrendere2, 
                           INPUT par_complend2, 
                           INPUT par_nrcxapst2, 
                           INPUT TABLE tt-contrato-avalista).
         END.

     RETURN aux_returnvl.

END PROCEDURE. /* Grava_Dados */


/* ------------------------------------------------------------------------ */
/*     CRIA O ADITIVO DA ALTERACAO DO AVALISTA NO CONTRATO DE EMPRESTIMO    */
/* ------------------------------------------------------------------------ */
PROCEDURE Cria_Aditivo:
    
    DEF  INPUT PARAM par_cdcooper  AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_dtmvtolt  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta  AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nrctremp  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfavl  AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmdavali  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_cdagenci  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad  AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_uladitiv  AS INTE                           NO-UNDO.

    DEF VAR aux_contador AS INTE                                     NO-UNDO.
    DEF VAR aux_cdagenci AS INTE                                     NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_cdcritic = 0
           par_uladitiv = 0.
           
    Cria: DO TRANSACTION ON ERROR UNDO Cria, LEAVE Cria:

        Contador: DO  aux_contador = 1 TO 10:
    
            FIND LAST crapadt WHERE crapadt.cdcooper = par_cdcooper  AND
                                    crapadt.nrdconta = par_nrdconta  AND
                                    crapadt.nrctremp = par_nrctremp  AND
                                    crapadt.tpctrato = 90 /* Emprestimo/Financiamento */
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF  NOT AVAIL crapadt THEN
                DO:
                    IF  LOCKED crapadt   THEN
                        DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                    ASSIGN aux_cdcritic = 77.
                                    LEAVE Cria.
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT Contador.
                                END.
                        END.
                    ELSE
                        DO:
                            ASSIGN par_uladitiv = 1.
                            LEAVE Contador.
                        END.
                END.
            ELSE
                DO:
                    ASSIGN par_uladitiv = crapadt.nraditiv + 1.
                    LEAVE Contador.
                END.
    
        END.  /*  Contador  */
    
        /* Buscar pa de trabalho do operador */
        FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper AND
                                 crapope.cdoperad = par_cdoperad
                                 NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL crapope THEN
            aux_cdagenci = 0.
        ELSE
            aux_cdagenci = crapope.cdpactra.

        CREATE crapadt.
        ASSIGN crapadt.nrdconta = par_nrdconta
               crapadt.nrctremp = par_nrctremp
               crapadt.nraditiv = par_uladitiv
               crapadt.dtmvtolt = par_dtmvtolt
               crapadt.cdaditiv = 4
               crapadt.cdcooper = par_cdcooper
               crapadt.cdagenci = aux_cdagenci
               crapadt.cdoperad = par_cdoperad
               crapadt.tpctrato = 90. /* Emprestimo/Financiamento */
        VALIDATE crapadt.
           
        CREATE crapadi.
        ASSIGN crapadi.nrdconta = par_nrdconta
               crapadi.nrctremp = par_nrctremp
               crapadi.nraditiv = par_uladitiv
               crapadi.nrsequen = 1
               crapadi.nrcpfcgc = par_nrcpfavl
               crapadi.nmdavali = par_nmdavali
               crapadi.cdcooper = par_cdcooper
               crapadi.tpctrato = 90. /* Emprestimo/Financiamento */
        VALIDATE crapadi.  
        LEAVE Cria.

    END. /* Cria*/

END PROCEDURE. /* Cria_Aditivo */

/* ------------------------------------------------------------------------ */
/*      IMPRIMI OS DADOS DO AVALISTA ALTERADOS NO CONTRATO DE EMPRESTIMO    */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Impressao:

     DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO. 
     DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO. 
     DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nmoperad AS CHAR FORMAT "x(20)"            NO-UNDO.   
     DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.   
     DEF  INPUT PARAM par_nrcpfava AS DECI                           NO-UNDO.
     DEF  INPUT PARAM par_nmdavali AS CHAR FORMAT "x(50)"            NO-UNDO.
     DEF  INPUT PARAM par_uladitiv AS INTE FORMAT "z9"               NO-UNDO.
    
     DEF OUTPUT PARAM aux_nmarqimp AS CHAR                           NO-UNDO.
     DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                           NO-UNDO.

     DEF OUTPUT PARAM TABLE FOR tt-erro.
     
     DEF  VAR aux_nmendter AS CHAR                                   NO-UNDO.
     DEF  VAR aux_qtpalavr AS INT                                    NO-UNDO.
     DEF  VAR aux_qtcontpa AS INT                                    NO-UNDO.

     DEF  VAR rel_nrdconta AS DECI                                   NO-UNDO.
     DEF  VAR rel_nrctremp AS DECI                                   NO-UNDO.
     DEF  VAR aux_tpdocged AS INTE                                   NO-UNDO.

     DEF  VAR rel_ddmvtolt AS INT  FORMAT "99"                       NO-UNDO.
     DEF  VAR rel_aamvtolt AS INT  FORMAT "9999"                     NO-UNDO.
     DEF  VAR rel_mmmvtolt AS CHAR FORMAT "x(17)"  EXTENT 12 
                                   INIT["de  Janeiro  de",
                                        "de Fevereiro de",
                                        "de   Marco   de",
                                        "de   Abril   de",
                                        "de   Maio    de",
                                        "de   Junho   de",
                                        "de   Julho   de",
                                        "de   Agosto  de",
                                        "de  Setembro de",
                                        "de  Outubro  de",
                                        "de  Novembro de",
                                        "de  Dezembro de"]           NO-UNDO.
     DEF  VAR rel_nrcpfcgc AS CHAR FORMAT "x(18)"                    NO-UNDO. 
     DEF  VAR rel_dscpfavl AS CHAR FORMAT "x(18)"                    NO-UNDO.
     DEF  VAR rel_nmrescop AS CHAR FORMAT "x(30)" EXTENT 2           NO-UNDO.


     FORM "\022\024\033\120"     /* Reseta impressora */
          "\033\016\033\105ADITIVO CONTRATUAL" AT 20 
          "\022\024\033\120"
          par_uladitiv AT 63
          SKIP
          "\033\016INCLUSAO DE FIADOR/AVALISTA" AT 10
          "\033\016"
          SKIP(2)
          "No contrato de emprestimo n."
          "\033\105" crapepr.nrctremp                 AT 32   "\033\106"
          "firmado em"                                AT 44       
          "\033\105" crapepr.dtmvtolt                 AT 59   "\033\106"
          ",tendo como"                               AT 73
          SKIP(1)
          "partes de um lado a:\033\105" 
          SKIP(1)
          crapcop.nmextcop  
          "\033\106,CNPJ\033\105"
          crapcop.nrdocnpj    
          "\033\106"
          SKIP(1)
          "e de outro o(a) Sr(a).:\033\105"       
          SKIP(1)
          crapass.nmprimtl                            
          "\033\106Conta\033\105"
          crapepr.nrdconta        
          "\033\106 ,"
          SKIP(1)
          "CPF/CNPJ\033\105"
          rel_nrcpfcgc        
          /*SKIP(1)*/
          "\033\106comparece   como  interveniente   garantidor  na"
          SKIP(1)
          "condicao de fiador/avalista o(a) Sr(a).:\033\105"          
          SKIP(1)                 
          par_nmdavali 
          "\033\106,CPF\033\105"                               
          rel_dscpfavl 
          ".\033\106"     
          SKIP(1)     
          "Para garantir o cumprimento das obrigacoes assumidas, no referido"
          "contrato"                                  AT 68
          SKIP(1)
          "comparece igualmente o FIADOR nominado, INTERVENIENTE  GARANTIDOR,"
          "o  qual"                                   AT 69
          SKIP(1)
          "expressamente declara que responsabiliza-se solidariamente, como"
          "principal"                                 AT 67
          SKIP(1)
          "pagador, pelo cumprimento de todas as obrigacoes assumidas  pelo"
          "COOPERADO"                                 AT 67
           SKIP(1)
          "no contrato citado, renunciando expressamente, os beneficios de  ordem"
          "que"                                       AT 73
          SKIP(1)
          "trata o art.827, em conformidade com  o  art.828,  incisos  I  e  II,"
          "e  o"                                      AT 72
          SKIP(1)
          "art.838, do Codigo Civil Brasileiro (lei n.10.406, de 10/01/2002)."
          SKIP(1)      
          "Como garantia adicional o  interveniente  garantidor  subscreve  tambem"
          "as"                                        AT 74
          SKIP(1)
          "notas promissorias correspondentes  as  obrigacoes  assumidas  no"
          "contrato"                                  AT 68
          SKIP(1)
          "principal de emprestimo pessoal."
          SKIP(2)
          "As demais clausulas e condicoes continuam inalteradas."
          WITH NO-BOX NO-LABELS WIDTH 96 COLUMN 6 FRAME f_termo.

     FORM SKIP(2)
          crapcop.nmcidade FORMAT "x(13)"
          crapcop.cdufdcop
          ","
          rel_ddmvtolt
          rel_mmmvtolt[MONTH(par_dtmvtolt)]
          rel_aamvtolt
          "."
          SKIP(2)
          "______________________________"
          "______________________________"  AT 46
          SKIP
          crapass.nmprimtl FORMAT "x(40)"
          rel_nmrescop[1]                   AT 46
          SKIP
          rel_nmrescop[2]                   AT 46
          SKIP(2)
          "______________________________"
          SKIP
          "Interveniente Garantidor"
          SKIP(2)
          "______________________________"
          "______________________________"  AT 46
          SKIP
          "Fiador"
          "Fiador"                          AT 46
          SKIP(2)
          "______________________________"
          "______________________________"  AT 46
          SKIP
          "Testemunha"
          "Testemunha"                      AT 46
          SKIP(2)
          "______________________________"
          SKIP
          par_cdoperad
          "-"
          par_nmoperad     
          WITH NO-BOX NO-LABELS WIDTH 96 COLUMN 6 FRAME f_assinatura.

     FORM "PARA USO DA DIGITALIZACAO"                                    AT  87
          SKIP(1)
          rel_nrdconta                    NO-LABEL FORMAT "zzzz,zzz,9"   AT  87
          rel_nrctremp                    NO-LABEL FORMAT "zz,zzz,zz9"   AT 102 
          aux_tpdocged                    NO-LABEL FORMAT "zz9"          AT 115
          WITH NO-BOX WIDTH 132 COLUMN 9 FRAME f_uso_digitalizacao.

     ASSIGN par_nmdavali = CAPS(par_nmdavali)
            rel_ddmvtolt = DAY(par_dtmvtolt)
            rel_aamvtolt = YEAR(par_dtmvtolt).

    Imprimir: DO ON ERROR UNDO Imprimir, LEAVE Imprimir:

       EMPTY TEMP-TABLE tt-erro.
       
       FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

       ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop +
                             "/rl/" + par_dsiduser.
       
       UNIX SILENT VALUE("rm " + aux_nmendter + "* 2> /dev/null").

       ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
              aux_nmarqimp = aux_nmendter + ".ex"
              aux_nmarqpdf = aux_nmendter + ".pdf".

       OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

       FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND         
                          craptab.nmsistem = "CRED"         AND         
                          craptab.tptabela = "GENERI"       AND         
                          craptab.cdempres = 00             AND         
                          craptab.cdacesso = "DIGITALIZA"   AND
                          craptab.tpregist = 5    /* Contrt. emprestimo/financiamento (GED) */
                          NO-LOCK NO-ERROR NO-WAIT.
                         
       IF  AVAIL craptab THEN
           ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";")).

       /* CPF avalista */
       ASSIGN rel_dscpfavl = STRING(par_nrcpfava,"99999999999")
              rel_dscpfavl = STRING(rel_dscpfavl,"    xxx.xxx.xxx-xx").

       /* fim CPF avalista */

       FIND crapepr WHERE crapepr.cdcooper = par_cdcooper  AND
                          crapepr.nrdconta = par_nrdconta  AND
                          crapepr.nrctremp = par_nrctremp  NO-LOCK NO-ERROR.

       /* FIND crapass OF crapepr NO-LOCK NO-ERROR. */
       FIND crapass WHERE crapass.cdcooper = par_cdcooper      AND
                          crapass.nrdconta = crapepr.nrdconta  NO-LOCK NO-ERROR.

        /* Tratamento de CPF/CGC */
       IF   crapass.inpessoa = 1   THEN
            ASSIGN  rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,"    xxx.xxx.xxx-xx").
       ELSE
            ASSIGN  rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").

       FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

       /*   Divide o crapcop.nmextcop em duas variaveis  */
       ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ") / 2
              rel_nmrescop = "".

       DO aux_qtcontpa = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):
          IF   aux_qtcontpa <= aux_qtpalavr   THEN
               rel_nmrescop[1] = rel_nmrescop[1] +  (IF TRIM(rel_nmrescop[1]) = ""
                                                        THEN "" ELSE " ") +
                                          ENTRY(aux_qtcontpa,crapcop.nmextcop," ").
          ELSE
               rel_nmrescop[2] = rel_nmrescop[2] + (IF TRIM(rel_nmrescop[2]) = ""
                                                    THEN "" ELSE " ") +
                                          ENTRY(aux_qtcontpa,crapcop.nmextcop," ").
       END.  /*  Fim DO .. TO  */ 

       ASSIGN rel_nmrescop[1] = FILL(" ",20 - INT(LENGTH(rel_nmrescop[1]) / 2)) +
                                              rel_nmrescop[1]
              rel_nmrescop[2] = FILL(" ",20 - INT(LENGTH(rel_nmrescop[2]) / 2)) +
                                              rel_nmrescop[2].

       rel_nmrescop[1] = TRIM(rel_nmrescop[1]," ").
       rel_nmrescop[2] = TRIM(rel_nmrescop[2]," ").

       /*  Fim da Rotina  */

       ASSIGN rel_nrdconta = crapepr.nrdconta
              rel_nrctremp = crapepr.nrctremp.

       DISPLAY STREAM str_1
               rel_nrdconta
               rel_nrctremp
               aux_tpdocged
               WITH FRAME f_uso_digitalizacao.

       IF  par_idorigem <> 5  THEN
           DISPLAY STREAM str_1 SKIP(5) WITH FRAME f_skip.

       DISPLAY STREAM str_1
                crapepr.nrctremp   crapepr.dtmvtolt    crapcop.nmextcop   
                crapcop.nrdocnpj   crapass.nmprimtl    crapepr.nrdconta
                rel_nrcpfcgc       par_nmdavali        rel_dscpfavl
                par_uladitiv
                WITH FRAME f_termo.

       DISPLAY STREAM str_1
                crapcop.nmcidade   crapcop.cdufdcop    rel_ddmvtolt
                rel_aamvtolt       rel_mmmvtolt[MONTH(par_dtmvtolt)]
                crapass.nmprimtl   rel_nmrescop[1]     rel_nmrescop[2]
                par_cdoperad       par_nmoperad
                WITH FRAME f_assinatura.

       OUTPUT STREAM str_1 CLOSE.

       ASSIGN aux_returnvl = "OK".
       LEAVE Imprimir.
        
     END. /*  Imprimir */

     IF  par_idorigem = 5  THEN  /** Ayllos Web **/
         DO:
             RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                 SET h-b1wgen0024.

             RUN envia-arquivo-web IN h-b1wgen0024 
                 ( INPUT par_cdcooper,
                   INPUT par_cdagenci,
                   INPUT par_nrdcaixa,
                   INPUT aux_nmarqimp,
                  OUTPUT aux_nmarqpdf,
                  OUTPUT TABLE tt-erro ).
                
             IF  VALID-HANDLE(h-b1wgen0024)  THEN
                 DELETE PROCEDURE h-b1wgen0024.

             IF  RETURN-VALUE <> "OK" THEN
                 ASSIGN aux_returnvl = "NOK".
         END.

     RETURN aux_returnvl.

END PROCEDURE. /* Gera_Impressao */


/* ........................... PROCEDURE INTERNAS ........................... */
/* ............................... FUNCTIONS ................................ */

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


PROCEDURE Gera_Log:

    /* 1 Avalista */
    DEF  INPUT PARAM par_flgaval1  AS LOGICAL                        NO-UNDO. 
    DEF  INPUT PARAM par_nrctaav1  AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_cpfcgc1   AS DECI                           NO-UNDO. 
    DEF  INPUT PARAM par_nmdaval1  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_cpfccg1   AS DECI                           NO-UNDO. 
    DEF  INPUT PARAM par_nmcjgav1  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_tpdoccj1  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dscfcav1  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_tpdocav1  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dscpfav1  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dsenda11  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dsenda12  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nrfonres1 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dsdemail1 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nmcidade1 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_cdufresd1 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nrcepend1 AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nrendere1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complend1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst1 AS INTE                           NO-UNDO.

    /* 2 Avalista */
    DEF  INPUT PARAM par_flgaval2  AS LOGICAL                        NO-UNDO. 
    DEF  INPUT PARAM par_nrctaav2  AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_cpfcgc2   AS DECI                           NO-UNDO. 
    DEF  INPUT PARAM par_nmdaval2  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_cpfccg2   AS DECI                           NO-UNDO. 
    DEF  INPUT PARAM par_nmcjgav2  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_tpdoccj2  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dscfcav2  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_tpdocav2  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dscpfav2  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dsenda21  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dsenda22  AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nrfonres2 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dsdemail2 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nmcidade2 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_cdufresd2 AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nrcepend2 AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nrendere2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complend2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst2 AS INTE                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-contrato-avalista.

    /* 1 Avalista */
    IF  par_flgaval1 THEN
        DO:       
            /* Dados do avalista 1 antes da alteracao */
            FIND FIRST tt-contrato-avalista WHERE tt-contrato-avalista.nrindice = 1 NO-ERROR.

            /* nrctaava */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nrctaava1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nrctaava) ELSE ""), 
                  INPUT STRING(par_nrctaav1)).

            /* nmdavali */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nmdavali1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nmdavali) ELSE ""), 
                  INPUT STRING(TRIM(CAPS(par_nmdaval1)))).
    
            /* nrcpfcgc */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nrcpfcgc1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nrcpfcgc) ELSE ""), 
                  INPUT STRING(par_cpfcgc1)).
    
            /* tpdocava */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "tpdocava1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.tpdocava) ELSE ""), 
                  INPUT STRING(par_tpdocav1)).
     
            /* dscpfcgc */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "dscpfcgc1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.dscpfava) ELSE ""), 
                  INPUT STRING(TRIM(CAPS(par_dscpfav1)))).
          
            /* nmcjgava */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nmcjgava1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nmcjgava) ELSE ""),
                  INPUT STRING(TRIM(CAPS(par_nmcjgav1)))).
          
            /* nrcpfcjg */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nrcpfcjg1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nrcpfcjg) ELSE ""),
                  INPUT STRING(par_cpfccg1)).
         
            /* tpdoccjg */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "tpdoccjg1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.tpdoccjg) ELSE ""),
                  INPUT STRING(par_tpdoccj1)).

            /* dscfcava */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "dscfcava1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.dscfcava) ELSE ""),
                  INPUT STRING(TRIM(CAPS(par_dscfcav1)))).

            /* nrcepend */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nrcepend1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nrcepend) ELSE ""),
                  INPUT STRING(par_nrcepend1)).

            /* endereco */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "endereco1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.dsendava[1]) ELSE ""),
                  INPUT STRING(TRIM(CAPS(par_dsenda11)))).

            /* nrendere */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nrendere1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nrendere) ELSE ""),
                  INPUT STRING(par_nrendere1)).
            
            /* complend */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "complend1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.complend) ELSE ""),
                  INPUT STRING(TRIM(CAPS(par_complend1)))).

            /* nrcxapst */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nrcxapst1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nrcxapst) ELSE ""),
                  INPUT STRING(par_nrcxapst1)).
          
            /* dsbairro */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "dsbairro1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.dsendava[2]) ELSE ""),
                  INPUT STRING(TRIM(CAPS(par_dsenda12)))).
        
            /* cdufresd */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "cdufresd1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.cdufende) ELSE ""),
                  INPUT STRING(par_cdufresd1)).
           
            /* nmcidade */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nmcidade1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nmcidade) ELSE ""),
                  INPUT STRING(TRIM(CAPS(par_nmcidade1)))).

            /* dsdemail */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "dsdemail1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.dsdemail) ELSE ""),
                  INPUT STRING(TRIM(CAPS(par_dsdemail1)))).

            /* nrfonres */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nrfonres1",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nrfonres) ELSE ""),
                  INPUT STRING(TRIM(CAPS(par_nrfonres1)))).
        END.                                               

    /* 2 Avalista */
    IF  par_flgaval2 THEN                                  
        DO:
            /* Dados do avalista 2 antes da alteracao */
            FIND FIRST tt-contrato-avalista WHERE tt-contrato-avalista.nrindice = 2 NO-ERROR.

            /* nrctaava */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nrctaava2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nrctaava) ELSE ""), 
                  INPUT STRING(par_nrctaav2)).

            /* nmdavali */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nmdavali2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nmdavali) ELSE ""), 
                  INPUT STRING(TRIM(CAPS(par_nmdaval2)))).

            /* nrcpfcgc */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nrcpfcgc2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nrcpfcgc) ELSE ""), 
                  INPUT STRING(par_cpfcgc2)).

            /* tpdocava */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "tpdocava2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.tpdocava) ELSE ""), 
                  INPUT STRING(par_tpdocav2)).

            /* dscpfcgc */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "dscpfcgc2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.dscpfava) ELSE ""), 
                  INPUT STRING(TRIM(CAPS(par_dscpfav2)))).

            /* nmcjgava */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nmcjgava2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nmcjgava) ELSE ""),
                  INPUT STRING(TRIM(CAPS(par_nmcjgav2)))).

            /* nrcpfcjg */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nrcpfcjg2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nrcpfcjg) ELSE ""),
                  INPUT STRING(par_cpfccg2)).

            /* tpdoccjg */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "tpdoccjg2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.tpdoccjg) ELSE ""),
                  INPUT STRING(par_tpdoccj2)).

            /* dscfcava */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "dscfcava2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.dscfcava) ELSE ""),
                  INPUT STRING(TRIM(CAPS(par_dscfcav2)))).

            /* nrcepend */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nrcepend2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nrcepend) ELSE ""),
                  INPUT STRING(par_nrcepend2)).

            /* endereco */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "endereco2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.dsendava[1]) ELSE ""),
                  INPUT STRING(TRIM(CAPS(par_dsenda21)))).

            /* nrendere */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nrendere2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nrendere) ELSE ""),
                  INPUT STRING(par_nrendere2)).

            /* complend */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "complend2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.complend) ELSE ""),
                  INPUT STRING(TRIM(CAPS(par_complend2)))).

            /* nrcxapst */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nrcxapst2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nrcxapst) ELSE ""),
                  INPUT STRING(par_nrcxapst2)).

            /* dsbairro */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "dsbairro2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.dsendava[2]) ELSE ""),
                  INPUT STRING(TRIM(CAPS(par_dsenda22)))).

            /* cdufresd */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "cdufresd2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.cdufende) ELSE ""),
                  INPUT STRING(par_cdufresd2)).

            /* nmcidade */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nmcidade2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nmcidade) ELSE ""),
                  INPUT STRING(par_nmcidade2)).

            /* dsdemail */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "dsdemail2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.dsdemail) ELSE ""),
                  INPUT STRING(TRIM(CAPS(par_dsdemail2)))).

            /* nrfonres */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nrfonres2",
                  INPUT (IF AVAIL tt-contrato-avalista THEN STRING(tt-contrato-avalista.nrfonres) ELSE ""),
                  INPUT STRING(TRIM(CAPS(par_nrfonres2)))).
        END.

END PROCEDURE. /* Gera Log */




