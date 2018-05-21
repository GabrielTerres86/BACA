/*.......................................................................................

    Programa: b1wgen0063.p
    Autor   : Jose Luis (DB1)
    Data    : Marco/2010                   Ultima atualizacao: 14/03/2018

    Objetivo  : Tranformacao BO tela CONTAS - IMPRESSOES

    Alteracoes: 10/08/2010 - Inclusao de parametro na function 
                "BuscaNaturezaJuridica", INPUT "dsnatjur" - Jose Luis, DB1
                
                06/06/2011 - Criar mais uma linha de endereco quando
                             pessoa juridica (Gabriel)
                             
                16/04/2012 - Ajustes na procedure Busca_Abertura_PF para 
                             utilizar a tabela crapcrl - Resp. Legal (Adriano).
   
                03/07/2013 - Inclusao da table tt-fcad-poder no retorno da
                             Busca_Impressao -> b1wgen0058, inclusao da
                             procedure Imprime_Assinatura (Jean Michel).
                             
                10/09/2013 - Inclusao da impressão de Responsaveis Legais
                             (Jean Michel).                      
                             
                01/10/2013 - Alterado atribuicao do campo tt-ctaassin.nrtelpro
                             para receber dados da craptfc. (Reinert)
                             
                03/10/2013 - Inclusao da procedure busca-procuradores-impressao (Jean Michel)
                
                15/10/2013 - Incluido a procedure busca-lista-titulares (Jean Michel)
                
                29/11/2013 - Ajustar leitura crapttl sem cdcooper (David).
                
                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                
                02/06/2014 - Adicionado numero cpf do procurador em tt-cratpod.
                             (Jorge/Rosangela) - SD 155408

                26/11/2014 - Remoção do Endividamento e dos Bens dos representantes
                             por caracterizar quebra de sigilo bancário 
                             (Douglas - Chamado 194831)
                
                11/08/2015 - Resolvido problema que acontecia caso o responsavel legal
                             nao tivesse conta conforme relatado no chamado 310056. (Kelvin)
                             
                15/10/2015 - Projeto Reformulacao cadastral
                             Eliminado o campo nmdsecao (Tiago Castro - RKAM).
                             
                08/01/2016 - #350828 Criacao da tela PEP (Carlos)

				12/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                 crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
			 		        (Adriano - P339).

                17/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                             PRJ339 - CRM (Odirlei-AMcom)  
				
				07/12/2017 - Realizado ajuste onde o relatório completo para contas menores de idade
							 com dois responsaveis legais sem conta na viacredi não estava abrindo. 
						     SD 802764. (Kelvin)

                14/03/2018 - Comentada verificaçao para exibir a mensagem "Tipo de 
                             conta nao necessita de termo.". PRJ366 (Lombardi).

.......................................................................................*/

/*........+++++..................... DEFINICOES .......................................*/
{ sistema/generico/includes/b1wgen0062tt.i }
{ sistema/generico/includes/b1wgen0063tt.i }
{ sistema/generico/includes/b1wgen0059tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }

DEF STREAM str_1.

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0060 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0052b AS HANDLE                                     NO-UNDO.
DEF VAR aux_dsmesref AS CHAR                                        NO-UNDO.

FUNCTION BuscaPessoa RETURNS INTEGER
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_nrdconta AS INTEGER ) FORWARD.

FUNCTION AlertaTermo RETURNS CHARACTER 
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_nrdconta AS INTEGER ) FORWARD.

/*............................. PROCEDURES ..................................*/
PROCEDURE Busca_Impressao:

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
    DEF  INPUT PARAM par_tprelato AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgpreen AS LOG                            NO-UNDO.

    DEF OUTPUT PARAM par_msgalert AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-abert-ident.
    DEF OUTPUT PARAM TABLE FOR tt-abert-psfis.
    DEF OUTPUT PARAM TABLE FOR tt-abert-compf.
    DEF OUTPUT PARAM TABLE FOR tt-abert-decpf.
    DEF OUTPUT PARAM TABLE FOR tt-abert-psjur.
    DEF OUTPUT PARAM TABLE FOR tt-abert-compj.
    DEF OUTPUT PARAM TABLE FOR tt-abert-decpj.
    DEF OUTPUT PARAM TABLE FOR tt-termo-ident.
    DEF OUTPUT PARAM TABLE FOR tt-termo-assin.
    DEF OUTPUT PARAM TABLE FOR tt-termo-asstl.
    DEF OUTPUT PARAM TABLE FOR tt-finan-cabec.
    DEF OUTPUT PARAM TABLE FOR tt-finan-ficha.
    DEF OUTPUT PARAM TABLE FOR tt-fcad.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-telef. 
    DEF OUTPUT PARAM TABLE FOR tt-fcad-email. 
    DEF OUTPUT PARAM TABLE FOR tt-fcad-psfis. 
    DEF OUTPUT PARAM TABLE FOR tt-fcad-filia. 
    DEF OUTPUT PARAM TABLE FOR tt-fcad-comer. 
    DEF OUTPUT PARAM TABLE FOR tt-fcad-cbens. 
    DEF OUTPUT PARAM TABLE FOR tt-fcad-depen. 
    DEF OUTPUT PARAM TABLE FOR tt-fcad-ctato. 
    DEF OUTPUT PARAM TABLE FOR tt-fcad-respl. 
    DEF OUTPUT PARAM TABLE FOR tt-fcad-cjuge.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-psjur. 
    DEF OUTPUT PARAM TABLE FOR tt-fcad-regis. 
    DEF OUTPUT PARAM TABLE FOR tt-fcad-procu. 
    DEF OUTPUT PARAM TABLE FOR tt-fcad-bensp. 
    DEF OUTPUT PARAM TABLE FOR tt-fcad-refer. 

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE h-b1wgen0062 AS HANDLE      NO-UNDO.
    
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados do associado para Impressao"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".
    
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-erro.
        RUN Zera_TempTable.

        ASSIGN aux_dsmesref = "JANEIRO,FEVEREIRO,MARCO,ABRIL," +
                              "MAIO,JUNHO,JULHO,AGOSTO,SETEMBRO," +
                              "OUTUBRO,NOVEMBRO,DEZEMBRO".
        CASE par_tprelato:
            WHEN "COMPLETO" THEN DO:
                IF  NOT VALID-HANDLE(h-b1wgen0062) THEN
                    RUN sistema/generico/procedures/b1wgen0062.p
                        PERSISTENT SET h-b1wgen0062.

                RUN Busca_Impressao IN h-b1wgen0062
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT par_flgerlog,
                      INPUT par_dtmvtolt,
                      OUTPUT TABLE tt-fcad,
                      OUTPUT TABLE tt-fcad-telef,
                      OUTPUT TABLE tt-fcad-email,
                      OUTPUT TABLE tt-fcad-psfis,
                      OUTPUT TABLE tt-fcad-filia,
                      OUTPUT TABLE tt-fcad-comer,
                      OUTPUT TABLE tt-fcad-cbens,
                      OUTPUT TABLE tt-fcad-depen,
                      OUTPUT TABLE tt-fcad-ctato,                      
                      OUTPUT TABLE tt-fcad-respl,
                      OUTPUT TABLE tt-fcad-cjuge,
                      OUTPUT TABLE tt-fcad-psjur,
                      OUTPUT TABLE tt-fcad-regis,
                      OUTPUT TABLE tt-fcad-procu,
                      /*OUTPUT TABLE tt-fcad-bensp,*/
                      OUTPUT TABLE tt-fcad-refer,
                      OUTPUT TABLE tt-fcad-poder,
                      OUTPUT TABLE tt-erro ).

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Busca.
                
                RUN Busca_Abertura
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT par_dtmvtolt,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic,
                     OUTPUT TABLE tt-abert-ident,
                     OUTPUT TABLE tt-abert-psfis,
                     OUTPUT TABLE tt-abert-compf,
                     OUTPUT TABLE tt-abert-decpf,
                     OUTPUT TABLE tt-abert-psjur,
                     OUTPUT TABLE tt-abert-compj,
                     OUTPUT TABLE tt-abert-decpj ).

                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Busca, LEAVE Busca.

                DELETE OBJECT h-b1wgen0062.

                ASSIGN par_msgalert = AlertaTermo(par_cdcooper, par_nrdconta).
                
                IF  par_msgalert = "" THEN
                    DO:
                
                        RUN Busca_Termo
                            ( INPUT par_cdcooper,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                             OUTPUT aux_cdcritic,
                             OUTPUT aux_dscritic,
                             OUTPUT TABLE tt-termo-ident,
                             OUTPUT TABLE tt-termo-assin,
                             OUTPUT TABLE tt-termo-asstl ).
                        
                        IF  RETURN-VALUE <> "OK" THEN
                            UNDO Busca, LEAVE Busca.
                        
                        RUN Atualiza_Crapalt
                            ( INPUT par_cdcooper,
                              INPUT par_nrdconta,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                             OUTPUT aux_cdcritic,
                             OUTPUT aux_dscritic ).
    
                        IF  RETURN-VALUE <> "OK" THEN
                            UNDO Busca, LEAVE Busca.
                    END.

                IF  NOT CAN-FIND(crapjfn WHERE 
                                 crapjfn.cdcooper = par_cdcooper AND
                                 crapjfn.nrdconta = par_nrdconta) AND 
                    par_flgpreen THEN.
                ELSE
                    RUN Busca_Finaceiro
                        ( INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_flgpreen,
                         OUTPUT aux_cdcritic,
                         OUTPUT aux_dscritic,
                         OUTPUT TABLE tt-finan-cabec,
                         OUTPUT TABLE tt-finan-ficha ).
            END.
            WHEN "ABERTURA" THEN DO:
                RUN Busca_Abertura
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT par_dtmvtolt,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic,
                     OUTPUT TABLE tt-abert-ident,
                     OUTPUT TABLE tt-abert-psfis,
                     OUTPUT TABLE tt-abert-compf,
                     OUTPUT TABLE tt-abert-decpf,
                     OUTPUT TABLE tt-abert-psjur,
                     OUTPUT TABLE tt-abert-compj,
                     OUTPUT TABLE tt-abert-decpj ).

                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Busca, LEAVE Busca.
            END.
            WHEN "TERMO" THEN DO:
                RUN Busca_Termo
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT par_dtmvtolt,
                      INPUT par_cdoperad,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic,
                     OUTPUT TABLE tt-termo-ident,
                     OUTPUT TABLE tt-termo-assin,
                     OUTPUT TABLE tt-termo-asstl ).

                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Busca, LEAVE Busca.

                RUN Atualiza_Crapalt
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_dtmvtolt,
                      INPUT par_cdoperad,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ).

                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Busca, LEAVE Busca.

                ASSIGN par_msgalert = AlertaTermo(par_cdcooper, par_nrdconta).
            END.
            WHEN "FINANCEIRO" THEN DO:
                RUN Busca_Finaceiro
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_dtmvtolt,
                      INPUT par_cdoperad,
                      INPUT par_flgpreen,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic,
                     OUTPUT TABLE tt-finan-cabec,
                     OUTPUT TABLE tt-finan-ficha ).
            END.

            WHEN "DECLARACAO_PEP" THEN DO:
                RETURN "OK".
            END.

            OTHERWISE DO:
                ASSIGN aux_dscritic = "Tipo de relatorio nao foi informado".
                LEAVE Busca.
            END.

        END CASE.

        LEAVE Busca.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  VALID-HANDLE(h-b1wgen9999) THEN
        DELETE OBJECT h-b1wgen9999.

    IF  aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE 
        ASSIGN aux_retorno = "OK".

    IF  par_flgerlog THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK"
                                   THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Abertura:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-abert-ident.
    DEF OUTPUT PARAM TABLE FOR tt-abert-psfis.
    DEF OUTPUT PARAM TABLE FOR tt-abert-compf.
    DEF OUTPUT PARAM TABLE FOR tt-abert-decpf.
    DEF OUTPUT PARAM TABLE FOR tt-abert-psjur.
    DEF OUTPUT PARAM TABLE FOR tt-abert-compj.
    DEF OUTPUT PARAM TABLE FOR tt-abert-decpj.

    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabage FOR crapage.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_retorno = "NOK".

    BuscaAbertura: DO ON ERROR UNDO BuscaAbertura, LEAVE BuscaAbertura:

        /* Busca dados da cooperativa */
        FOR FIRST crabcop FIELDS(nmextcop dsendcop nmbairro cdufdcop 
                                 nrdocnpj nmcidade nrendcop)
                          WHERE crabcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crabcop THEN
            DO:
               ASSIGN par_cdcritic = 651.
               LEAVE BuscaAbertura.
            END.

        /* BuscaAbertura dados do cooperado */
        FOR FIRST crabass FIELDS(nrdconta cdagenci nrmatric inpessoa nmprimtl)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN par_cdcritic = 9.
               LEAVE BuscaAbertura.
            END.

        /* BuscaAbertura dados da agencia */
        FOR FIRST crabage FIELDS(cdagenci nmresage)
                          WHERE crabage.cdcooper = par_cdcooper     AND
                                crabage.cdagenci = crabass.cdagenci NO-LOCK:
        END.

        IF  NOT AVAILABLE crabage THEN
            DO:
               ASSIGN par_cdcritic = 15.
               LEAVE BuscaAbertura.
            END.
        
        CREATE tt-abert-ident.
        ASSIGN               
            tt-abert-ident.inpessoa = crabass.inpessoa
            tt-abert-ident.dstitulo = (IF crabass.inpessoa = 1
                                      THEN "PESSOA FISICA"
                                      ELSE "PESSOA JURIDICA")
            tt-abert-ident.nmextcop = crabcop.nmextcop.
        
        IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
            RUN sistema/generico/procedures/b1wgen9999.p
                PERSISTENT SET h-b1wgen9999.

        RUN quebra-str IN h-b1wgen9999
            ( INPUT "PA: " + STRING(crabass.cdagenci,"999") + "-" +
                       STRING(crabage.nmresage,"x(15)") + ","   + "CNPJ/MF " +
                       STRING(STRING(crabcop.nrdocnpj, "99999999999999"),
                                     "xx.xxx.xxx/xxxx-xx") +
                       ", Endereco " + crabcop.dsendcop + ", N. " +
                       STRING(crabcop.nrendcop) +
                       ", Bairro " + crabcop.nmbairro + ", " +
                       crabcop.nmcidade + ", " + crabcop.cdufdcop,
              INPUT 58,
              INPUT 58,
              INPUT 58,
              INPUT 58,
             OUTPUT tt-abert-ident.dslinha1,
             OUTPUT tt-abert-ident.dslinha2,
             OUTPUT tt-abert-ident.dslinha3,
             OUTPUT tt-abert-ident.dslinha4 ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = ERROR-STATUS:GET-MESSAGE(1).
               LEAVE BuscaAbertura.
            END.

        CASE crabass.inpessoa:
            WHEN 1 THEN DO:
                RUN Busca_Abertura_PF
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT par_dtmvtolt,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic,
                     OUTPUT TABLE tt-abert-psfis,
                     OUTPUT TABLE tt-abert-compf,
                     OUTPUT TABLE tt-abert-decpf ).

                IF  RETURN-VALUE <> "OK" THEN
                    UNDO BuscaAbertura, LEAVE BuscaAbertura.
            END.
            OTHERWISE DO:
                RUN Busca_Abertura_PJ
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_dtmvtolt,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic,
                     OUTPUT TABLE tt-abert-psjur,
                     OUTPUT TABLE tt-abert-compj,
                     OUTPUT TABLE tt-abert-decpj ).

                IF  RETURN-VALUE <> "OK" THEN
                    UNDO BuscaAbertura, LEAVE BuscaAbertura.
            END.
        END CASE.
            
        ASSIGN aux_retorno = "OK".
    END.

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Abertura_PF:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-abert-psfis.
    DEF OUTPUT PARAM TABLE FOR tt-abert-compf.
    DEF OUTPUT PARAM TABLE FOR tt-abert-decpf.

    DEF BUFFER crabttl FOR crapttl.

    DEF VAR aux_cdorgexp AS CHAR                                    NO-UNDO.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_retorno = "NOK".

    BuscaAberPf: DO ON ERROR UNDO BuscaAberPf, LEAVE BuscaAberPf:

        FOR FIRST crapass FIELDS(nmprimtl nrdconta)
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN par_cdcritic = 9.
               LEAVE BuscaAberPf.
            END.

        FOR FIRST crapttl FIELDS(nrcpfcgc nrdocttl idorgexp cdufdttl 
                                 idseqttl cdestcvl)
                          WHERE crapttl.cdcooper = par_cdcooper AND
                                crapttl.nrdconta = par_nrdconta AND
                                crapttl.idseqttl = 1 NO-LOCK:
        END.

        IF  NOT AVAILABLE crapttl  THEN
            DO:
               ASSIGN par_dscritic = "Registro de titulares nao encontrado. " +
                                     " Impossivel continuar!".
               LEAVE BuscaAberPf.
            END.

        /* Retornar orgao expedidor */
        IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
            RUN sistema/generico/procedures/b1wgen0052b.p 
                PERSISTENT SET h-b1wgen0052b.

        ASSIGN aux_cdorgexp = "".
        RUN busca_org_expedidor IN h-b1wgen0052b 
                           (INPUT crapttl.idorgexp,
                            OUTPUT aux_cdorgexp,
                            OUTPUT par_cdcritic, 
                            OUTPUT par_dscritic).

        DELETE PROCEDURE h-b1wgen0052b.   

        IF  RETURN-VALUE = "NOK" THEN
        DO:
            ASSIGN aux_cdorgexp = "NAO CADAST.".
        END.
    

        CREATE tt-abert-psfis.
        ASSIGN 
            tt-abert-psfis.nmprimtl = crapass.nmprimtl
            tt-abert-psfis.nrdconta = TRIM(STRING(crapass.nrdconta,
                                                  "zzzz,zzz,9"))
            tt-abert-psfis.nrcpfcgc = STRING(STRING(crapttl.nrcpfcgc,
                                         "99999999999"),"xxx.xxx.xxx-xx")
            tt-abert-psfis.nrdocmto = TRIM(STRING(crapttl.nrdocttl,"x(40)")) +
                                      " " +
                                      TRIM(STRING(aux_cdorgexp,"x(05)")) +
                                      "/" + STRING(crapttl.cdufdttl,"!(02)").
           
        IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
            RUN sistema/generico/procedures/b1wgen9999.p
                PERSISTENT SET h-b1wgen9999.

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p
                PERSISTENT SET h-b1wgen0060.

        DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                         INPUT crapttl.cdestcvl,
                         INPUT "rsestcvl",
                         OUTPUT tt-abert-psfis.dsestcvl,
                         OUTPUT aux_dscritic).

        /* Endereco */
        FOR FIRST crapenc FIELDS(dsendere nrendere nmbairro nmcidade
                                 cdufende nrcepend)
                          WHERE crapenc.cdcooper = par_cdcooper       AND
                                crapenc.nrdconta = par_nrdconta       AND
                                crapenc.idseqttl = crapttl.idseqttl   AND
                                crapenc.tpendass = 10 /*Residencial*/ NO-LOCK:
        END.

        IF  NOT AVAILABLE crapenc THEN
            DO:
               ASSIGN par_dscritic = "Registro de enderecos nao encontrado. " +
                                     " Impossivel continuar!".
               LEAVE BuscaAberPf.
            END.

        RUN quebra-str IN h-b1wgen9999
            ( INPUT crapenc.dsendere + ", N. " + STRING(crapenc.nrendere) +
                    ", Bairro " + crapenc.nmbairro + ", " +
                    TRIM(crapenc.nmcidade) + "/" + crapenc.cdufende 
                    + "  CEP: " + STRING(crapenc.nrcepend,"99999,999"),
              INPUT 61, INPUT 61,
              INPUT 61, INPUT 61,
             OUTPUT tt-abert-psfis.dslinha1,
             OUTPUT tt-abert-psfis.dslinha2,
             OUTPUT tt-abert-psfis.dslinha3,
             OUTPUT tt-abert-psfis.dslinha4 ).


        /* Representante Legal */
        FOR FIRST crapcrl FIELDS(nrdconta nmrespon nrcpfcgc nridenti
                                 idorgexp cdufiden)
                          WHERE crapcrl.cdcooper = par_cdcooper     AND
                                crapcrl.nrctamen = crapass.nrdconta AND
                                crapcrl.idseqmen = 1
                                NO-LOCK:

            IF  crapcrl.nrdconta <> 0   THEN
                DO: 
                   FOR FIRST crabttl FIELDS(nmextttl nrcpfcgc nrdocttl 
                                            idorgexp cdufdttl)
                                     WHERE crabttl.cdcooper = par_cdcooper AND
                                           crabttl.nrdconta = crapcrl.nrdconta
                                           NO-LOCK:
                       
                       
                       /* Retornar orgao expedidor */
                       IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                            RUN sistema/generico/procedures/b1wgen0052b.p 
                                PERSISTENT SET h-b1wgen0052b.

                       ASSIGN aux_cdorgexp = "".
                       RUN busca_org_expedidor IN h-b1wgen0052b 
                                           (INPUT crabttl.idorgexp,
                                            OUTPUT aux_cdorgexp,
                                            OUTPUT par_cdcritic, 
                                            OUTPUT par_dscritic).

                       DELETE PROCEDURE h-b1wgen0052b.   

                       IF  RETURN-VALUE = "NOK" THEN
                       DO:
                           ASSIGN aux_cdorgexp = "NAO CADAST.".
                       END.
                       
                       ASSIGN 
                           tt-abert-psfis.nmrepleg = crabttl.nmextttl
                           tt-abert-psfis.nrcpfrep = STRING(STRING
                                                           (crabttl.nrcpfcgc,
                                                            "99999999999"),
                                                           "xxx.xxx.xxx-xx")
                           tt-abert-psfis.nrdocrep = TRIM(STRING
                                                         (crabttl.nrdocttl,
                                                          "x(40)")) + " " +
                                                    TRIM(STRING(
                                                        aux_cdorgexp,
                                                        "x(05)")) + "/" + 
                                                    STRING(crabttl.cdufdttl,
                                                           "!(02)").
                   END.

                   RELEASE crabttl.

                END.
            ELSE
                DO: 
                
                   /* Retornar orgao expedidor */
                   IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                        RUN sistema/generico/procedures/b1wgen0052b.p 
                            PERSISTENT SET h-b1wgen0052b.

                   ASSIGN aux_cdorgexp = "".
                   RUN busca_org_expedidor IN h-b1wgen0052b 
                                       (INPUT crapcrl.idorgexp,
                                        OUTPUT aux_cdorgexp,
                                        OUTPUT par_cdcritic, 
                                        OUTPUT par_dscritic).

                   DELETE PROCEDURE h-b1wgen0052b.   

                   IF  RETURN-VALUE = "NOK" THEN
                   DO:
                       ASSIGN aux_cdorgexp = "NAO CADAST.".
                   END.
                
                   ASSIGN 
                       tt-abert-psfis.nmrepleg = crapcrl.nmrespon
                       tt-abert-psfis.nrcpfcgc = STRING(STRING
                                                       (crapcrl.nrcpfcgc,
                                                        "99999999999"),
                                                       "xxx.xxx.xxx-xx")
                       tt-abert-psfis.nrdocmto = TRIM(STRING(crapcrl.nridenti,
                                                            "x(40)")) + " " +
                                                TRIM(STRING(aux_cdorgexp,
                                                            "x(05)")) + "/" +
                                                STRING(crapcrl.cdufiden,
                                                       "!(02)").

                END.
        END.

        /* Segundo, Terceiro e Quarto Titular */
        DO aux_contador = 2 TO 4:
            FOR FIRST crabttl FIELDS(nrcpfcgc nmextttl nrdocttl 
                                     idorgexp cdufdttl)
                              WHERE crabttl.cdcooper = par_cdcooper AND
                                    crabttl.nrdconta = par_nrdconta AND
                                    crabttl.idseqttl = aux_contador NO-LOCK:

                CREATE tt-abert-compf.

                CASE aux_contador:
                    WHEN 2 THEN 
                        tt-abert-compf.dstitulo = "2.1.Cooperado(a) Segundo Titular:".
                    WHEN 3 THEN 
                        tt-abert-compf.dstitulo = "2.2.Cooperado(a) Terceiro Titular:".
                    WHEN 4 THEN 
                        tt-abert-compf.dstitulo = "2.3.Cooperado(a) Quarto Titular:".
                END CASE.                 

                /* Retornar orgao expedidor */
                IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                      RUN sistema/generico/procedures/b1wgen0052b.p 
                          PERSISTENT SET h-b1wgen0052b.

                ASSIGN aux_cdorgexp = "".
                RUN busca_org_expedidor IN h-b1wgen0052b 
                                     (INPUT crabttl.idorgexp,
                                      OUTPUT aux_cdorgexp,
                                      OUTPUT par_cdcritic, 
                                      OUTPUT par_dscritic).

                DELETE PROCEDURE h-b1wgen0052b.   

                IF  RETURN-VALUE = "NOK" THEN
                DO:
                     ASSIGN aux_cdorgexp = "NAO CADAST.".
                END.

                ASSIGN 
                    tt-abert-compf.nmprimtl = crabttl.nmextttl
                    tt-abert-compf.nrcpfcgc = STRING(STRING(crabttl.nrcpfcgc,
                                                           "99999999999"),
                                                    "xxx.xxx.xxx-xx")
                    tt-abert-compf.nrdocmto = TRIM(STRING
                                                  (crabttl.nrdocttl,"x(40)"))
                                             + " " +
                                             TRIM(STRING
                                                  (aux_cdorgexp,"x(05)"))
                                             + "/" + 
                                             STRING(crabttl.cdufdttl,"!(02)").
            END.

            RELEASE crabttl.
        END.

        CREATE tt-abert-decpf.

        /* Busca dados da cooperativa */
        FOR FIRST crapcop FIELDS(dsclactr nmcidade nmextcop)
                          WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crapcop THEN
            DO:
               ASSIGN par_cdcritic = 651.
               LEAVE BuscaAberPf.
            END.

        ASSIGN
            tt-abert-decpf.dsclact1 = crapcop.dsclactr[01]
            tt-abert-decpf.dsclact2 = crapcop.dsclactr[02]
            tt-abert-decpf.dsclact3 = crapcop.dsclactr[03]
            tt-abert-decpf.dsclact4 = crapcop.dsclactr[04]
            tt-abert-decpf.dsclact5 = crapcop.dsclactr[05]
            tt-abert-decpf.dsclact6 = crapcop.dsclactr[06]
            tt-abert-decpf.dsmvtolt = CAPS(TRIM(crapcop.nmcidade) + ", "  +
                                     STRING(DAY(par_dtmvtolt),"99") + " DE " +
                                     STRING(ENTRY(MONTH(par_dtmvtolt),
                                            aux_dsmesref),"x(9)") + " DE " +
                                     STRING(YEAR(par_dtmvtolt),"9999") + ".").

        FOR EACH crabttl WHERE crabttl.cdcooper = par_cdcooper    AND
                               crabttl.nrdconta = par_nrdconta
                               NO-LOCK :

            CASE crabttl.idseqttl:
                WHEN 1 THEN
                    ASSIGN
                       tt-abert-decpf.nmextttl = crabttl.nmextttl
                       tt-abert-decpf.nmextcop = crapcop.nmextcop.

                WHEN 2 THEN
                    ASSIGN tt-abert-decpf.nmsgdttl = crabttl.nmextttl.

                WHEN 3 THEN
                    ASSIGN
                       tt-abert-decpf.nmterttl = crabttl.nmextttl
                       tt-abert-decpf.linhater = "_______________" +
                                                 "_______________".

                WHEN 4 THEN
                    ASSIGN tt-abert-decpf.nmqtottl = crabttl.nmextttl.
            END CASE.

        END. /* FIM FOR EACH crabttl*/

        ASSIGN aux_retorno = "OK".
    END.

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Abertura_PJ:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-abert-psjur.
    DEF OUTPUT PARAM TABLE FOR tt-abert-compj.
    DEF OUTPUT PARAM TABLE FOR tt-abert-decpj.

    DEF VAR aux_dslinhax AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdorgexp AS CHAR                                    NO-UNDO.

    DEF BUFFER crabass FOR crapass.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_retorno = "NOK".

    BuscaAberPj: DO ON ERROR UNDO BuscaAberPj, LEAVE BuscaAberPj:

        FOR FIRST crapass FIELDS(nmprimtl nrdconta nrcpfcgc)
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN par_cdcritic = 9.
               LEAVE BuscaAberPj.
            END.
                     
        /* Endereco */
        FOR FIRST crapenc FIELDS(dsendere nrendere nmbairro nmcidade
                                 cdufende nrcepend)
                          WHERE crapenc.cdcooper = par_cdcooper       AND
                                crapenc.nrdconta = par_nrdconta       AND
                                crapenc.idseqttl = 1                  AND
                                crapenc.tpendass = 9 /* Comercial */ NO-LOCK:
        END.
        
        IF  NOT AVAILABLE crapenc THEN
            DO:
               ASSIGN aux_dscritic = "Registro de enderecos nao encontrado!" +
                                     " Impossivel continuar!".
               LEAVE BuscaAberPj.
            END.
                  
        FOR FIRST crapjur FIELDS(natjurid nrinsest)
                          WHERE crapjur.cdcooper = par_cdcooper AND
                                crapjur.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crapjur  THEN
            DO:
               ASSIGN par_dscritic = "Registro de pessoa juridic nao " + 
                                     "encontrado. Impossivel continuar!".
               LEAVE BuscaAberPj.
            END.

        CREATE tt-abert-psjur.
        ASSIGN 
            tt-abert-psjur.nmprimtl = crapass.nmprimtl
            tt-abert-psjur.nrdconta = TRIM(STRING(crapass.nrdconta,
                                                  "zzzz,zzz,9"))
            tt-abert-psjur.nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,
                                                   "99999999999999"),
                                            "xx.xxx.xxx/xxxx-xx")
            tt-abert-psjur.nrinsest = STRING(crapjur.nrinsest,
                                             "999,999,999,999").

        IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
            RUN sistema/generico/procedures/b1wgen9999.p
                PERSISTENT SET h-b1wgen9999.

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p
                PERSISTENT SET h-b1wgen0060.

        RUN quebra-str IN h-b1wgen9999
            ( INPUT (crapenc.dsendere + ", N. " + STRING(crapenc.nrendere) +
                     ", Bairro " + crapenc.nmbairro + ", " +
                     TRIM(crapenc.nmcidade) + "/" + crapenc.cdufende 
                     + "  CEP: " + STRING(crapenc.nrcepend,"99999,999")),
              INPUT 61, INPUT 61,
              INPUT 61, INPUT 61,
             OUTPUT tt-abert-psjur.dslinha1,
             OUTPUT tt-abert-psjur.dslinha2,
             OUTPUT tt-abert-psjur.dslinha3,
             OUTPUT tt-abert-psjur.dslinha4 ).

        DYNAMIC-FUNCTION("BuscaNaturezaJuridica" IN h-b1wgen0060,
                         INPUT crapjur.natjurid,
                         INPUT "dsnatjur",
                         OUTPUT tt-abert-psjur.dsnatjur,
                         OUTPUT aux_dscritic).

        ASSIGN aux_contador = 0.
        /* Qualificacao dos Adminstradores */
        FOR EACH crapavt FIELDS(nrdctato dsproftl nmdavali nrcpfcgc
                                nrdocava idorgexp cdufddoc dsendres
                                nrendere nmbairro nmcidade cdufresd
                                nrcepend)
                         WHERE crapavt.cdcooper = par_cdcooper   AND
                               crapavt.tpctrato = 6 /*juridica*/ AND
                               crapavt.nrdconta = par_nrdconta   NO-LOCK:

            ASSIGN aux_contador = aux_contador + 1.

            CREATE tt-abert-compj.
            ASSIGN 
                tt-abert-compj.dstitulo = "2.2." + 
                                         LEFT-TRIM(STRING(aux_contador,"z9")) +
                                         ".CARGO:".
 
            /* Se for associado, pega os dados da crapass */
            IF  crapavt.nrdctato <> 0 THEN
                DO:
                   FOR FIRST crabass FIELDS(dsproftl nmprimtl nrcpfcgc
                                            nrdocptl idorgexp cdufdptl
                                            nrdconta)
                                     WHERE crabass.cdcooper = par_cdcooper AND
                                           crabass.nrdconta = crapavt.nrdctato
                                           NO-LOCK:
                       
                       /* Retornar orgao expedidor */
                       IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                              RUN sistema/generico/procedures/b1wgen0052b.p 
                                  PERSISTENT SET h-b1wgen0052b.

                       ASSIGN aux_cdorgexp = "".
                       RUN busca_org_expedidor IN h-b1wgen0052b 
                                             (INPUT crabass.idorgexp,
                                              OUTPUT aux_cdorgexp,
                                              OUTPUT par_cdcritic, 
                                              OUTPUT par_dscritic).

                       DELETE PROCEDURE h-b1wgen0052b.   

                       IF  RETURN-VALUE = "NOK" THEN
                       DO:
                             ASSIGN aux_cdorgexp = "NAO CADAST".
                       END.
                       
                       ASSIGN 
                           tt-abert-compj.dsproftl = " " + 
                                                    TRIM(crabass.dsproftl) +
                                                    ", Nome: " + 
                                                    crabass.nmprimtl
                           tt-abert-compj.nrcpfcgc = STRING(STRING
                                                           (crabass.nrcpfcgc,
                                                           "99999999999"),
                                                           "xxx.xxx.xxx-xx")
                           tt-abert-compj.nrdocmto = TRIM(STRING
                                                    (crabass.nrdocptl,"x(40)"))
                                                    + " " + 
                                                    TRIM(STRING
                                                    (aux_cdorgexp,"x(05)"))
                                                    + "/" + 
                                                    STRING(
                                                    crabass.cdufdptl,"!(02)").
                   END.

                   /* Endereco - residencial */
                   FOR FIRST crapenc FIELDS(dsendere nrendere nmbairro
                                            nmcidade cdufende nrcepend)
                                     WHERE crapenc.cdcooper = par_cdcooper AND
                                           crapenc.idseqttl = 1            AND
                                           crapenc.tpendass = 10           AND
                                           crapenc.nrdconta = crabass.nrdconta
                                           NO-LOCK:
                   END.
       
                   IF  NOT AVAILABLE crapenc THEN
                       DO:
                          ASSIGN par_dscritic = "Registro de enderecos nao " +
                                                "encontrado! Impossivel " + 
                                                "continuar!".
                          LEAVE BuscaAberPj.
                       END.
               
                   ASSIGN 
                       aux_dslinhax = crapenc.dsendere + ", Nr. " + 
                                      STRING(crapenc.nrendere) +
                                      ", Bairro " + crapenc.nmbairro + ", " +
                                      TRIM(crapenc.nmcidade) + "/" +
                                      crapenc.cdufende 
                                      + "  CEP: " + 
                                      STRING(crapenc.nrcepend,"99999,999").
                END.
            ELSE
                DO:
                   /* Retornar orgao expedidor */
                   IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                          RUN sistema/generico/procedures/b1wgen0052b.p 
                              PERSISTENT SET h-b1wgen0052b.

                   ASSIGN aux_cdorgexp = "".
                   RUN busca_org_expedidor IN h-b1wgen0052b 
                                         (INPUT crapavt.idorgexp,
                                          OUTPUT aux_cdorgexp,
                                          OUTPUT par_cdcritic, 
                                          OUTPUT par_dscritic).

                   DELETE PROCEDURE h-b1wgen0052b.   

                   IF  RETURN-VALUE = "NOK" THEN
                   DO:
                         ASSIGN aux_cdorgexp = "NAO CADAST.".
                   END.
                   
                   
                   ASSIGN 
                       tt-abert-compj.dsproftl = " " + TRIM(crapavt.dsproftl) +
                                                 ", Nome: " + crapavt.nmdavali
                       tt-abert-compj.nrcpfcgc = STRING(STRING
                                                       (crapavt.nrcpfcgc,
                                                        "99999999999"),
                                                       "xxx.xxx.xxx-xx")
                       tt-abert-compj.nrdocmto = TRIM(STRING
                                                   (crapavt.nrdocava,"x(40)"))
                                                 + " " +
                                                 TRIM(STRING
                                                   (aux_cdorgexp,"x(05)"))
                                                 + "/" +
                                                 STRING
                                                 (crapavt.cdufddoc,"!(02)").

                   ASSIGN 
                       aux_dslinhax = crapavt.dsendres[1] + ", Nr. " + 
                                      STRING(crapavt.nrendere) +
                                      ", Bairro " + crapavt.nmbairro 
                                      + ", " +
                                      TRIM(crapavt.nmcidade) + "/" +
                                      crapavt.cdufresd 
                                      + "  CEP: " + 
                                      STRING(crapavt.nrcepend,"99999,999").
                END.
                
            RUN quebra-str IN h-b1wgen9999
               ( INPUT aux_dslinhax,
                 INPUT 59,
                 INPUT 59,
                 INPUT 59,
                 INPUT 59,
                OUTPUT tt-abert-compj.dslinha1,
                OUTPUT tt-abert-compj.dslinha2,
                OUTPUT tt-abert-compj.dslinha3,
                OUTPUT aux_dslinhax ) NO-ERROR.

        END.

        /* Busca dados da cooperativa */
        FOR FIRST crapcop FIELDS(dsclactr nmextcop)
                          WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crapcop THEN
            DO:
               ASSIGN par_cdcritic = 651.
               LEAVE BuscaAberPj.
            END.
        
        CREATE tt-abert-decpj.
        ASSIGN
            tt-abert-decpj.nmprimtl = crapass.nmprimtl
            tt-abert-decpj.nmextcop = crapcop.nmextcop
            tt-abert-decpj.dsclact1 = crapcop.dsclactr[01]
            tt-abert-decpj.dsclact2 = crapcop.dsclactr[02]
            tt-abert-decpj.dsclact3 = crapcop.dsclactr[03]
            tt-abert-decpj.dsclact4 = crapcop.dsclactr[04]
            tt-abert-decpj.dsclact5 = crapcop.dsclactr[05]
            tt-abert-decpj.dsclact6 = crapcop.dsclactr[06]
            tt-abert-decpj.dsmvtolt = CAPS(TRIM(crapcop.nmcidade) + ", "  +
                                     STRING(DAY(par_dtmvtolt),"99") + " DE " +
                                     STRING(ENTRY(MONTH(par_dtmvtolt),
                                            aux_dsmesref),"x(9)") + " DE " +
                                     STRING(YEAR(par_dtmvtolt),"9999") + ".").

        ASSIGN aux_retorno = "OK".
    END.

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Termo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-termo-ident.
    DEF OUTPUT PARAM TABLE FOR tt-termo-assin.
    DEF OUTPUT PARAM TABLE FOR tt-termo-asstl.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_retorno = "NOK".

    BuscaTermo: DO ON ERROR UNDO BuscaTermo, LEAVE BuscaTermo:

        /* Busca dados da cooperativa */
        FOR FIRST crapcop FIELDS(nmextcop nmrescop nmcidade)
                          WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crapcop THEN
            DO:
               ASSIGN par_cdcritic = 651.
               LEAVE BuscaTermo.
            END.

        /* BuscaTermo dados do cooperado */
        FOR FIRST crapass FIELDS(nrdconta cdagenci inpessoa nmprimtl nrcpfcgc)
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN par_cdcritic = 9.
               LEAVE BuscaTermo.
            END.

        CREATE tt-termo-ident.
        ASSIGN 
            tt-termo-ident.nmextcop = crapcop.nmextcop
            tt-termo-ident.cdagenci = crapass.cdagenci
            tt-termo-ident.nrdconta = TRIM(STRING(crapass.nrdconta,
                                                  "zzzz,zzz,9"))
            tt-termo-ident.nmrescop = crapcop.nmrescop
            tt-termo-ident.dsmvtolt = CAPS(TRIM(crapcop.nmcidade) 
                                           + ", "  +  
                                           STRING(DAY(par_dtmvtolt),"99") 
                                           +  " DE " +
                                           STRING(ENTRY(MONTH(par_dtmvtolt),
                                                        aux_dsmesref),"x(9)") 
                                           + " DE " +
                                           STRING(YEAR(par_dtmvtolt),"9999") 
                                           + ".").

        FOR FIRST crapope FIELDS(nmoperad)
                          WHERE crapope.cdcooper = par_cdcooper AND
                                crapope.cdoperad = par_cdoperad NO-LOCK:
        END.

        IF  NOT AVAILABLE crapope THEN
            DO:
               ASSIGN par_dscritic = "Cadastro de operadores nao encontrado.".
               LEAVE BuscaTermo.
            END.


        CREATE tt-termo-assin.
        ASSIGN 
            tt-termo-assin.nmprimtl = crapass.nmprimtl
            tt-termo-assin.nmoperad = crapope.nmoperad
            tt-termo-assin.nrcpfcgc = IF crapass.inpessoa = 1 THEN
                                      STRING(STRING(crapass.nrcpfcgc,
                                                    "99999999999"),
                                             "xxx.xxx.xxx-xx")
                                      ELSE STRING(STRING(crapass.nrcpfcgc, 
                                                         "99999999999999"),
                                                  "xx.xxx.xxx/xxxx-xx").

        IF  crapass.inpessoa = 1 THEN 
            DO:
               FOR FIRST crapttl FIELDS(nmextttl nrcpfcgc nmextttl)
                                 WHERE crapttl.cdcooper = par_cdcooper AND
                                       crapttl.nrdconta = par_nrdconta AND
                                       crapttl.idseqttl = 2 NO-LOCK:
               END.
    
               IF  AVAILABLE crapttl AND crapttl.nmextttl <> "" THEN
                   DO:
                      CREATE tt-termo-asstl.
                      ASSIGN 
                          tt-termo-asstl.nmprimtl = crapass.nmprimtl 
                          tt-termo-asstl.nmextttl = crapttl.nmextttl
                          tt-termo-asstl.nmoperad = crapope.nmoperad
                          tt-termo-asstl.nrcpfttl = STRING(STRING
                                                           (crapttl.nrcpfcgc,
                                                            "99999999999"),
                                                           "xxx.xxx.xxx-xx")
                          tt-termo-asstl.nrcpfcgc = STRING(STRING
                                                           (crapass.nrcpfcgc,
                                                            "99999999999"),
                                                           "xxx.xxx.xxx-xx").
                   END.
            END.
            
        ASSIGN aux_retorno = "OK".
    END.

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Finaceiro:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgpreen AS LOG                            NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-finan-cabec.
    DEF OUTPUT PARAM TABLE FOR tt-finan-ficha.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_retorno = "NOK".

    BuscaFinan: DO ON ERROR UNDO BuscaFinan, LEAVE BuscaFinan:

        /* Busca dados da cooperativa */
        FOR FIRST crapcop FIELDS(nmextcop nrendcop dsendcop nmcidade nrdocnpj)
                          WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crapcop THEN
            DO:
               ASSIGN par_cdcritic = 651.
               LEAVE BuscaFinan.
            END.

        /* BuscaTermo dados do cooperado */
        FOR FIRST crapass FIELDS(nrdconta cdagenci inpessoa nmprimtl nrcpfcgc)
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN par_cdcritic = 9.
               LEAVE BuscaFinan.
            END.

        IF  crapass.inpessoa <> 2 THEN
            LEAVE BuscaFinan.

        FOR FIRST crapope FIELDS(nmoperad)
                          WHERE crapope.cdcooper = par_cdcooper AND
                                crapope.cdoperad = par_cdoperad NO-LOCK:
        END.

        IF  NOT AVAILABLE crapope THEN
            DO:
               ASSIGN par_dscritic = "Cadastro de operadores nao encontrado.".
               LEAVE BuscaFinan.
            END.

        CREATE tt-finan-cabec.
        ASSIGN 
            tt-finan-cabec.nmextcop = crapcop.nmextcop
            tt-finan-cabec.dsendcop = crapcop.dsendcop           + ", " +
                                      STRING(crapcop.nrendcop,"zz,zz9") + 
                                      " - " + crapcop.nmcidade
            tt-finan-cabec.nrdocnpj = "CNPJ " + STRING(STRING
                                                       (crapcop.nrdocnpj,
                                                        "99999999999999"),
                                                       "xx.xxx.xxx/xxxx-xx").

        FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper AND
                           crapjfn.nrdconta = par_nrdconta 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapjfn AND par_flgpreen THEN
            DO:
               ASSIGN par_dscritic = "Impressao nao permitida. Associado nao" +
                                     " possui cadastro financeiro.".
               UNDO BuscaFinan, LEAVE BuscaFinan.
            END.

        CREATE tt-finan-ficha.

        IF  NOT par_flgpreen THEN
            DO:
               ASSIGN 
                   /* f_fichafin_1 */
                   tt-finan-ficha.nmprimtl = ""
                   tt-finan-ficha.dtultatu = ?
                   tt-finan-ficha.opultatu = ""
                   /* f_fichafin_2 */
                   tt-finan-ficha.dsdtbase = "  /    "
                   tt-finan-ficha.nrcpfcgc = ""
                   /* f_fichafin_3 */
                   tt-finan-ficha.vlcxbcaf = "_______________"
                   tt-finan-ficha.vlctarcb = "_______________"
                   tt-finan-ficha.vlrestoq = "_______________"
                   tt-finan-ficha.vloutatv = "_______________"
                   tt-finan-ficha.vlrimobi = "_______________"
                   tt-finan-ficha.vlfornec = "_______________"
                   tt-finan-ficha.vloutpas = "_______________"
                   tt-finan-ficha.vldivbco = "_______________"
                   /* f_fichafin_4 */
                   tt-finan-ficha.cdbccxlt = "______________"
                   tt-finan-ficha.dstipope = "__________________"
                   tt-finan-ficha.vlropera = "______________"
                   tt-finan-ficha.garantia = "__________________"
                   tt-finan-ficha.dsvencto = "____________"
                   /* f_fichafin_5 */
                   tt-finan-ficha.vlrctbru = "_____________________"
                   tt-finan-ficha.vlctdpad = "_____________________"
                   tt-finan-ficha.vldspfin = "_____________________"
                   tt-finan-ficha.ddprzrec = "__________"
                   tt-finan-ficha.ddprzpag = "__________"
                   /* f_fichafin_5 */
                   tt-finan-ficha.mesanoft = "___/____"
                   tt-finan-ficha.vlrftbru = "______________"
                   /* f_fichafin_7 */
                   tt-finan-ficha.dsinfadi = "".

               LEAVE BuscaFinan.
            END.

        /* f_fichafin_7 */
        DO  aux_contador = 1 TO 5:
            ASSIGN tt-finan-ficha.dsinfadi[aux_contador] = crapjfn.dsinfadi
                                                           [aux_contador].
        END.

        ASSIGN 
            /* f_fichafin_1 */
            tt-finan-ficha.nmprimtl = crapass.nmprimtl + " (" +
                                      TRIM(STRING(par_nrdconta,
                                                  "zzzz,zzz,9")) + ")"
            /* f_fichafin_2 */
            tt-finan-ficha.dsdtbase = STRING(crapjfn.mesdbase,"99") + "/" +
                                      STRING(crapjfn.anodbase,"zzz9") 
            tt-finan-ficha.nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,
                                                    "99999999999999"),
                                             "xx.xxx.xxx/xxxx-xx")
            /* f_fichafin_3 */
            tt-finan-ficha.vlcxbcaf = STRING(crapjfn.vlcxbcaf,
                                             "zzz,zzz,zz9.99-")
            tt-finan-ficha.vlctarcb = STRING(crapjfn.vlctarcb,
                                             "zzz,zzz,zz9.99-")
            tt-finan-ficha.vlrestoq = STRING(crapjfn.vlrestoq,
                                             "zzz,zzz,zz9.99-")
            tt-finan-ficha.vloutatv = STRING(crapjfn.vloutatv,
                                             "zzz,zzz,zz9.99-")
            tt-finan-ficha.vlrimobi = STRING(crapjfn.vlrimobi,
                                             "zzz,zzz,zz9.99-")
            tt-finan-ficha.vlfornec = STRING(crapjfn.vlfornec,
                                             "zzz,zzz,zz9.99-")
            tt-finan-ficha.vloutpas = STRING(crapjfn.vloutpas,
                                             "zzz,zzz,zz9.99-")
            tt-finan-ficha.vldivbco = STRING(crapjfn.vldivbco,
                                             "zzz,zzz,zz9.99-").

        /* f_fichafin_4 */
        DO aux_contador = 1 TO 5:

            IF  crapjfn.cddbanco[aux_contador] <> 0 THEN
                DO:
                    FOR FIRST crapban FIELDS(nmresbcc) 
                        WHERE crapban.cdbccxlt = crapjfn.cddbanco[aux_contador]
                        NO-LOCK:
                            
                    END.

                    IF  AVAILABLE crapban THEN
                      tt-finan-ficha.cdbccxlt[aux_contador] = crapban.nmresbcc.

                END.

            IF  NOT AVAILABLE crapban AND crapjfn.cddbanco[aux_contador] <> 0 
                THEN
                tt-finan-ficha.cdbccxlt[aux_contador] = STRING(
                                crapjfn.cddbanco[aux_contador],"999") + 
                                "-NAO CAD.".

            RELEASE crapban.

            ASSIGN 
                tt-finan-ficha.dstipope[aux_contador] = crapjfn.dstipope
                                                        [aux_contador]
                tt-finan-ficha.garantia[aux_contador] = crapjfn.garantia
                                                        [aux_contador]
                tt-finan-ficha.dsvencto[aux_contador] = crapjfn.dsvencto
                                                        [aux_contador]
                tt-finan-ficha.vlropera[aux_contador] = 
                                   IF  crapjfn.vlropera[aux_contador] <> 0 THEN
                                       STRING(crapjfn.vlropera[aux_contador],
                                                     "zzz,zzz,zz9.99")
                                   ELSE "".

            /* atualizar os campos de historico de alteracao */
            FOR FIRST crapope FIELDS(cdoperad nmoperad)
                              WHERE 
                              crapope.cdcooper = par_cdcooper AND
                              crapope.cdoperad = crapjfn.cdopejfn[aux_contador]
                              NO-LOCK:
            END.

            IF  DATE(crapjfn.dtaltjfn[aux_contador]) <> ? THEN
                DO:
                   tt-finan-ficha.dtultatu[aux_contador] = crapjfn.dtaltjfn
                                                           [aux_contador].
                   IF  NOT AVAILABLE crapope THEN
                       ASSIGN tt-finan-ficha.opultatu[aux_contador] = 
                              TRIM(crapjfn.cdopejfn[aux_contador]) + 
                              " - NAO ENCONTRADO!" + STRING(aux_contador).
                   ELSE
                       ASSIGN tt-finan-ficha.opultatu[aux_contador] = 
                              TRIM(crapope.cdoperad) + " - " + 
                              TRIM(crapope.nmoperad).
                END.
        END.

        /* f_fichafin_5 */
        ASSIGN
            tt-finan-ficha.vlrctbru = STRING(crapjfn.vlrctbru,
                                             "zzzz,zzz,zzz,zz9.99")
            tt-finan-ficha.vlctdpad = STRING(crapjfn.vlctdpad,
                                             "zzzz,zzz,zzz,zz9.99")
            tt-finan-ficha.vldspfin = STRING(crapjfn.vldspfin,
                                             "zzzz,zzz,zzz,zz9.99")
            tt-finan-ficha.ddprzrec = STRING(crapjfn.ddprzrec,"zzzzzzzzz9")
            tt-finan-ficha.ddprzpag = STRING(crapjfn.ddprzpag,"zzzzzzzzz9").

        /* f_fichafin_6 */
        DO  aux_contador = 1 TO 12:
            ASSIGN 
             tt-finan-ficha.mesanoft[aux_contador] = 
                STRING(crapjfn.mesftbru[aux_contador]," zz") + "/" + 
                STRING(crapjfn.anoftbru[aux_contador],"zzzz")
             tt-finan-ficha.vlrftbru[aux_contador] = 
                STRING(crapjfn.vlrftbru[aux_contador],"zzz,zzz,zz9.99").
        END.

        ASSIGN aux_retorno = "OK".
    END.

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Atualiza_CrapAlt:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    FOR FIRST crapass FIELDS(nrdctitg)
                      WHERE crapass.cdcooper = par_cdcooper AND
                            crapass.nrdconta = par_nrdconta NO-LOCK:
    END.

    DO TRANSACTION:
        /*-- Inclusao_crapalt --*/
        FIND crapalt WHERE crapalt.cdcooper = par_cdcooper   AND
                           crapalt.nrdconta = par_nrdconta   AND
                           crapalt.dtaltera = par_dtmvtolt
                           USE-INDEX crapalt1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE crapalt THEN
             IF   LOCKED crapalt THEN
                  DO:
                      ASSIGN par_cdcritic = 341.
                      UNDO, LEAVE.
                  END.
             ELSE
                  DO:
                      CREATE crapalt.
                      ASSIGN crapalt.nrdconta = par_nrdconta
                             crapalt.dtaltera = par_dtmvtolt
                             crapalt.tpaltera = 2
                             crapalt.dsaltera = ""
                             crapalt.cdcooper = par_cdcooper.

                      IF   crapass.nrdctitg <> "" THEN
                           crapalt.flgctitg = 0.
                      ELSE
                           crapalt.flgctitg = 3.
                      
                      VALIDATE crapalt.
                  END.

        IF   NOT CAN-DO(crapalt.dsaltera,"Impressao Termo Adesao")  THEN
             ASSIGN crapalt.dsaltera = crapalt.dsaltera + 
                                       "Impressao Termo Adesao" + ","
                    crapalt.cdoperad = par_cdoperad.
    END.

    IF  par_cdcritic <> 0  THEN
        RETURN "NOK".

    RELEASE crapalt.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Busca_TpRelatorio:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpreen AS LOG                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-tprelato.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Valida dados do associado para Impressao"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.
        
        FOR FIRST crapass FIELDS(nrdconta inpessoa cdtipcta nrdctitg flgctitg)
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Valida.
            END.

        DO aux_contador = 1 TO 7:
            CREATE tt-tprelato.

            CASE aux_contador:
                WHEN 1 THEN DO:
                    ASSIGN tt-tprelato.nmrelato = "COMPLETO"
                           tt-tprelato.msgrelat = AlertaTermo(par_cdcooper, 
                                                              par_nrdconta)
                           tt-tprelato.flgbloqu = NO.
                END.
                WHEN 2 THEN
                    ASSIGN tt-tprelato.nmrelato = "FICHA CADASTRAL".
                WHEN 3 THEN
                    ASSIGN tt-tprelato.nmrelato = "ABERTURA".
                WHEN 4 THEN
                    ASSIGN tt-tprelato.nmrelato = "TERMO"
                           tt-tprelato.msgrelat = AlertaTermo(par_cdcooper, 
                                                              par_nrdconta)
                           tt-tprelato.flgbloqu = (IF tt-tprelato.msgrelat = ""
                                                   THEN NO ELSE YES).
                WHEN 5 THEN DO:
                    ASSIGN tt-tprelato.nmrelato = "FINANCEIRO".

                    IF  NOT CAN-FIND(crapjfn WHERE 
                                     crapjfn.cdcooper = par_cdcooper AND
                                     crapjfn.nrdconta = par_nrdconta) AND 
                        par_flgpreen THEN
                        DO:
                           ASSIGN
                            tt-tprelato.msgrelat = "Impressao nao permitida." +
                                                   " Associado nao possui ca" +
                                                   "dastro financeiro".
                            tt-tprelato.flgbloqu = YES.
                        END.
                END.
                WHEN 6 THEN
                    ASSIGN tt-tprelato.nmrelato = "CARTAO ASSINATURA".
                WHEN 7 THEN DO:
                    ASSIGN tt-tprelato.nmrelato = "DECLARACAO PEP"
                    tt-tprelato.flgbloqu = NO.
                END.

            END CASE.
        END.

        LEAVE Valida.
    END.

    IF  aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE
        ASSIGN aux_retorno = "OK".

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Zera_TempTable.

    EMPTY TEMP-TABLE tt-abert-ident.
    EMPTY TEMP-TABLE tt-abert-psfis.
    EMPTY TEMP-TABLE tt-abert-compf.
    EMPTY TEMP-TABLE tt-abert-decpf.
    EMPTY TEMP-TABLE tt-abert-psjur.
    EMPTY TEMP-TABLE tt-abert-compj.
    EMPTY TEMP-TABLE tt-abert-decpj.
    EMPTY TEMP-TABLE tt-termo-ident.
    EMPTY TEMP-TABLE tt-termo-assin.
    EMPTY TEMP-TABLE tt-termo-asstl.
    EMPTY TEMP-TABLE tt-finan-cabec.
    EMPTY TEMP-TABLE tt-finan-ficha.
    EMPTY TEMP-TABLE tt-fcad.      
    EMPTY TEMP-TABLE tt-fcad-telef.
    EMPTY TEMP-TABLE tt-fcad-email.
    EMPTY TEMP-TABLE tt-fcad-psfis.
    EMPTY TEMP-TABLE tt-fcad-filia.
    EMPTY TEMP-TABLE tt-fcad-comer.
    EMPTY TEMP-TABLE tt-fcad-cbens.
    EMPTY TEMP-TABLE tt-fcad-depen.
    EMPTY TEMP-TABLE tt-fcad-ctato.
    EMPTY TEMP-TABLE tt-fcad-respl.
    EMPTY TEMP-TABLE tt-fcad-cjuge.
    EMPTY TEMP-TABLE tt-fcad-psjur.
    EMPTY TEMP-TABLE tt-fcad-regis.
    EMPTY TEMP-TABLE tt-fcad-procu.
    EMPTY TEMP-TABLE tt-fcad-bensp.
    EMPTY TEMP-TABLE tt-fcad-refer.

END PROCEDURE.

FUNCTION BuscaPessoa RETURNS INTEGER
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_nrdconta AS INTEGER ):

    FOR FIRST crapass FIELDS(inpessoa)
                      WHERE crapass.cdcooper = par_cdcooper AND
                            crapass.nrdconta = par_nrdconta NO-LOCK:
        RETURN crapass.inpessoa.
    END.

    RETURN 0.

END FUNCTION.

FUNCTION AlertaTermo RETURNS CHARACTER
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_nrdconta AS INTEGER ) :

    DEF BUFFER crafass FOR crapass.

    FOR FIRST crafass FIELDS(cdtipcta nrdctitg flgctitg)
                      WHERE crafass.cdcooper = par_cdcooper AND
                            crafass.nrdconta = par_nrdconta NO-LOCK:

    END.
/*
    IF  NOT(CAN-DO("8,9,10,11",STRING(crapass.cdtipcta))      OR
           ((crapass.nrdctitg <> "" AND crapass.flgctitg = 2) OR
            (crapass.nrdctitg = ""  AND crapass.flgctitg = 0))) THEN
        RETURN "Tipo de conta nao necessita de termo.".
  */      
    RETURN "".

END FUNCTION. 

PROCEDURE Imprime_Assinatura:
    
    DEF INPUT  PARAM par_cdcooper  AS INTE                 NO-UNDO.
    DEF INPUT  PARAM par_cdagenci  AS INTE                 NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa  AS INTE                 NO-UNDO.
    DEF INPUT  PARAM par_cdoperad  AS CHAR                 NO-UNDO.
    DEF INPUT  PARAM par_nmdatela  AS CHAR                 NO-UNDO.
    DEF INPUT  PARAM par_idorigem  AS INTE                 NO-UNDO.
    DEF INPUT  PARAM par_cddopcao  AS CHAR                 NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt  AS DATE                 NO-UNDO.
    DEF INPUT  PARAM par_nrdconta  AS INTE                 NO-UNDO.
    DEF INPUT  PARAM par_nrdctato  AS INTE                 NO-UNDO.
    DEF INPUT  PARAM par_idseqttl  AS INTE                 NO-UNDO.
    DEF INPUT  PARAM par_tppessoa  AS INTE                 NO-UNDO.
    DEF INPUT  PARAM par_nrcpfcgc  AS CHAR                 NO-UNDO.
    DEF INPUT  PARAM par_nmendter  AS CHAR                 NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp  AS CHAR                 NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                            

    /* Variaveis*/
    DEF VAR aux_nrdconta AS CHAR FORMAT "x(10)"            NO-UNDO.
    DEF VAR aux_cpfcgcti AS CHAR FORMAT "x(18)"            NO-UNDO.
    DEF VAR aux_nrcpftpr AS CHAR FORMAT "x(20)"            NO-UNDO.
    DEF VAR aux_lstpoder AS CHAR FORMAT "x(250)"           NO-UNDO.
    DEF VAR aux_flgisola AS CHAR FORMAT "x(5)"             NO-UNDO.
    DEF VAR aux_flgconju AS CHAR FORMAT "x(5)"             NO-UNDO.
    DEF VAR aux_tppescpf AS INT                            NO-UNDO.
    DEF VAR aux_stsnrcal AS LOGICAL                        NO-UNDO.
    DEF VAR aux_idseqttl AS CHAR                           NO-UNDO.
    DEF VAR aux_nrseqttl AS INT                            NO-UNDO.
    DEF VAR aux_contpode AS INT                            NO-UNDO.
    DEF VAR aux_dsoutpo1 AS CHAR FORMAT "x(48)"            NO-UNDO.
    DEF VAR aux_dsoutpo2 AS CHAR FORMAT "x(48)"            NO-UNDO.
    DEF VAR aux_dsoutpo3 AS CHAR FORMAT "x(48)"            NO-UNDO.
    DEF VAR aux_dsoutpo4 AS CHAR FORMAT "x(48)"            NO-UNDO.
    DEF VAR aux_dsoutpo5 AS CHAR FORMAT "x(48)"            NO-UNDO.
    DEF VAR aux_dscpoder AS CHAR FORMAT "x(35)"            NO-UNDO.
    DEF VAR aux_contstri AS INT                            NO-UNDO.
    DEF VAR aux_conttitu AS INT                            NO-UNDO.
    DEF VAR aux_contproc AS INT                            NO-UNDO.
    DEF VAR aux_countaux AS INT                            NO-UNDO.
    DEF VAR aux_contattl AS INT                            NO-UNDO.
    DEF VAR aux_contaavt AS INT                            NO-UNDO.
    DEF VAR aux_contacrl AS INT                            NO-UNDO.
    DEF VAR aux_cdagenci AS INT                            NO-UNDO.
    DEF VAR aux_datvenci AS CHAR FORMAT "X(10)"            NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                           NO-UNDO.
    DEF VAR h-b1wgen0058 AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen0024 AS HANDLE                         NO-UNDO. 
    /* Fim Variaveis */
    
    
    FORM
		"=============================================================================================================================" 
        SKIP
		"                                                   REGISTRO DE ASSINATURA                                                    "
        "                                                       Pessoa Fisica                                                         "
        SKIP
		"============================================================================================================================="
		SKIP(3)
		"Filiada:" tt-ctaassin.nmcooper "    PA: " tt-ctaassin.cdagenci " Conta Corrente: " aux_nrdconta " Titular: " aux_idseqttl
		SKIP(1)                   
		"Nome:" tt-ctaassin.nmtitula "  CPF: " aux_nrcpftpr
		SKIP(2)
        "Assinaturas:                                                                                                                 "
        SKIP(2)
        "                   _________________________________________                                                                 "
        SKIP(2)
        "                                                                             _________________________________________       "
        SKIP(2)             
        "                   _________________________________________                                                                 "
        SKIP(2)
		"Observacoes:"
		SKIP(2)
		"_____________________________________________________________________________________________________________________________"
		SKIP(2)
		"_____________________________________________________________________________________________________________________________"
		SKIP(2)
		"_____________________________________________________________________________________________________________________________"
		SKIP(8)
		"                         ___________________________________________             _____/_____/________                        "
		SKIP
        "                               Cadastro e Visto do Funcionario                          Data                                 "
        SKIP
		WITH WIDTH 132 NO-LABEL SIDE-LABELS NO-BOX FRAME f_cartaoasspf.


    FORM 
          "============================================================================================================================="
          SKIP
          "                                                 REGISTRO DE ASSINATURA                                                      "
          SKIP
          "                                             Pessoa Juridica e/ou Procurador                                                 "
          SKIP
          "============================================================================================================================="
          SKIP(2)
          "FILIADA: " tt-ctaassin.nmcooper "             PA: " tt-ctaassin.cdagenci " Conta: " aux_nrdconta
          SKIP
          "CPF/CNPJ: " aux_cpfcgcti " Outorgante(titular da conta ou razao social): " tt-ctaassin.nmtitula
          SKIP
          "CPF: " aux_nrcpftpr "    Outorgado: "  tt-ctaassin.nmprocur
          SKIP
          "Telefone: " tt-ctaassin.nrtelpro " Funcao: " tt-ctaassin.dsfuncao           
          SKIP(2)
          "Assinaturas:                                                                                                                 "
          SKIP(2)
          "                   _________________________________________                                                                 "
          SKIP(2)
          "                                                                             _________________________________________       "
          SKIP(2)             
          "                   _________________________________________                                                                 "
          SKIP(2)
          "Poderes (C= em conjunto, I= isolado)                                                                                         "
          SKIP
          " C     I                                          C     I                                                                    "
          WITH WIDTH 132 NO-LABEL NO-BOX FRAME f_cartaoasspj.
    
    FORM  
          "============================================================================================================================="
          SKIP
          "                                                 Dados do Instrumento de Mandato                                             "
          SKIP
          "============================================================================================================================="
          SKIP(1)
          "Tipo:________________________ Tabeliao:____________________________________ Municipio:___________________________ UF:________"
          SKIP(1)
          "N do Registro:___________ N do Livro:_____ N da Folha:_____ Data do Instrumento:___/___/_____ Prazo do mandato: " aux_datvenci
          SKIP(1)
          "Assina em conjunto com:______________________________________________________________________________________________________"
          SKIP(1)
          "Outros Poderes:"
          SKIP(1)
          aux_dsoutpo1
          SKIP
          aux_dsoutpo2
          SKIP
          aux_dsoutpo3
          SKIP
          aux_dsoutpo4
          SKIP
          aux_dsoutpo5
          SKIP(1)
          "Quaisquer alteracoes relativas ao uso das assinaturas aqui autorizadas serao imediatamente comunicadas, ficando a Cooperativa "
          SKIP
          "inteiramente isenta de responsabilidade pelos prejuizos que possam ocorrer em virtude do nao-cumprimento dessa providencia no "
          SKIP
          "devido tempo.                                                                                                                "
          SKIP(2)
          "         ________________________________________________________  "
          SKIP
          "                     Assinatura do outorgante                      "
          SKIP(1)
          "_____________________________________________________________________________________________________________________________"
          SKIP
          "Abono das firmas lancadas no presente cartao                                                                                 "
          SKIP(3)
          "                             _________________________________________                   Data: ____/____/________            "
          SKIP
          "                                  Cadastro e Visto do Funcionario                                                            "
          WITH WIDTH 132 NO-LABEL NO-BOX FRAME f_cartaoasspj1.
	
    EMPTY TEMP-TABLE tt-ctaassin.
    
    /* Criacao do arquivo */
    IF par_nmendter = ? OR par_nmendter = "" THEN
        RETURN "NOK".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.
    
    UNIX SILENT VALUE("rm /usr/coop/" + crapcop.dsdircop + "/rl/" + par_nmendter + "* 2> /dev/null").
    ASSIGN par_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_nmendter + STRING(TIME) + ".ex"
           aux_nmarquiv = par_nmendter + STRING(TIME) + ".ex".
    

    OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) APPEND PAGED PAGE-SIZE 84.
    
    /* Fim arquivo */

	IF par_tppessoa = 1 THEN
        DO:
           
            CREATE tt-ctaassin.
            
            FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK.
            
            IF NOT AVAILABLE crapcop THEN
               DO:
                    ASSIGN aux_cdcritic = 651.
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
        
                    RETURN "NOK".
               END.
            
            ASSIGN tt-ctaassin.cdcooper = par_cdcooper
                   tt-ctaassin.nmcooper = crapcop.nmrescop
                   tt-ctaassin.drcooper = crapcop.dsdircop.

            

            IF par_nrdconta <> 0 THEN
                DO:
                    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

                    IF NOT AVAILABLE crapass THEN
                        DO:
                            ASSIGN aux_cdcritic = 9.
                    
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                    
                            RETURN "NOK".
                        END.
                
                    ASSIGN tt-ctaassin.cdagenci = crapass.cdagenci
                           tt-ctaassin.nrdconta = par_nrdconta
                           tt-ctaassin.idseqttl = par_idseqttl.
        
                    contadorTtl: DO aux_contattl = 1 TO 10:
                        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                           crapttl.nrdconta = par_nrdconta AND
                                           crapttl.idseqttl = par_idseqttl
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                        
                        IF NOT AVAILABLE crapttl THEN
                            DO:
                                IF LOCKED crapttl  THEN
                                    DO:
                                        IF aux_contattl = 10  THEN
                                            DO:
                                                ASSIGN aux_cdcritic = 341.
                                                LEAVE contadorTtl.
                                             END.
                                          ELSE
                                             NEXT contadorTtl.
                                    END.
                                ELSE
                                    DO:
                                        ASSIGN aux_cdcritic = 12.
                                        LEAVE contadorTtl.
                                    END.
                            END.
                        ELSE
                            ASSIGN crapttl.flgimpri = FALSE
                           tt-ctaassin.nmtitula = crapttl.nmextttl
                           tt-ctaassin.nrcpftit = crapttl.nrcpfcgc.
                    END.
                END.
            ELSE
                DO:
                    FIND crapcrl WHERE crapcrl.cdcooper = par_cdcooper AND
                                       crapcrl.nrdconta = par_nrdconta AND
                                       STRING(crapcrl.nrcpfcgc) = par_nrcpfcgc
                                       NO-LOCK NO-ERROR NO-WAIT.
                        
                        IF AVAILABLE crapcrl THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                  tt-ctaassin.nmtitula = crapcrl.nmrespon
                                  tt-ctaassin.nrcpftit = crapcrl.nrcpfcgc.    
                        END.
                           
                   
                END.
           
            IF aux_cdcritic <> 0 THEN
                DO:

                    IF par_nrdctato <> 0 THEN
                        DO: 
                            contadorCrl: DO aux_contattl = 1 TO 10:
                                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                                   crapttl.nrdconta = par_nrdctato AND
                                                   crapttl.idseqttl = 1
                                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                
                                IF NOT AVAILABLE crapttl THEN
                                    DO:
                                        IF LOCKED crapttl  THEN
                                            DO:
                                                IF aux_contattl = 10  THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 341.
                                                        LEAVE contadorCrl.
                                                     END.
                                                  ELSE
                                                     NEXT contadorCrl.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 12.
                                                LEAVE contadorCrl.
                                            END.
                                    END.
                                ELSE
                                    ASSIGN crapttl.flgimpri = FALSE
                                           aux_cdcritic = 0
                                           tt-ctaassin.nmtitula = crapttl.nmextttl
                                           tt-ctaassin.nrcpftit = crapttl.nrcpfcgc.
                            END.
                        FIND crapcrl WHERE crapcrl.cdcooper = par_cdcooper AND
                                           crapcrl.nrctamen = par_nrdconta AND
                                           crapcrl.nrdconta = par_nrdctato
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                            
                            IF AVAIL crapcrl THEN
                                ASSIGN crapcrl.flgimpri = FALSE.
                        END.
                    ELSE
                        DO:
                            contadorCrl: DO aux_contattl = 1 TO 10:
                                FIND crapcrl WHERE crapcrl.cdcooper = par_cdcooper AND
                                                   crapcrl.nrctamen = par_nrdconta AND
                                                   crapcrl.nrdconta = par_nrdctato
                                                   NO-LOCK NO-ERROR NO-WAIT.
                                
                                IF NOT AVAILABLE crapcrl THEN
                                    DO:
                                        IF LOCKED crapcrl  THEN
                                            DO:
                                                IF aux_contattl = 10  THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 341.
                                                        LEAVE contadorCrl.
                                                     END.
                                                  ELSE
                                                     NEXT contadorCrl.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 12.
                                                LEAVE contadorCrl.
                                            END.
                                    END.
                                ELSE
                                    ASSIGN aux_cdcritic = 0
                                           tt-ctaassin.nmtitula = crapcrl.nmrespon
                                           tt-ctaassin.nrcpftit = crapcrl.nrcpfcgc.
                            END.

                            FIND crapcrl WHERE crapcrl.cdcooper = par_cdcooper AND
                                               crapcrl.nrctamen = par_nrdconta AND
                                               crapcrl.nrdconta = par_nrdctato
                                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                            
                            IF AVAIL crapcrl THEN
                                ASSIGN crapcrl.flgimpri = FALSE.
                        END.
                END.
            
            IF aux_cdcritic <> 0 THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                            
                                    RETURN "NOK".
                END.
            
            RELEASE crapttl.
            
            ASSIGN aux_nrdconta = TRIM(STRING(tt-ctaassin.nrdconta,"zzzz,zzz,9"))
                   aux_nrcpftpr = STRING(STRING(tt-ctaassin.nrcpftit, "99999999999"), "xxx.xxx.xxx-xx").
                
            IF tt-ctaassin.idseqttl = 0 THEN
                aux_idseqttl = "". 
            ELSE
                aux_idseqttl = STRING(tt-ctaassin.idseqttl).


            DISPLAY STREAM str_1 tt-ctaassin.cdagenci aux_nrdconta aux_idseqttl tt-ctaassin.nmcooper tt-ctaassin.nmtitula aux_nrcpftpr WITH FRAME f_cartaoasspf.
            
            PAGE STREAM str_1.
            
        END.
    ELSE
        /* Procurador */
        IF par_tppessoa = 2 THEN
            DO:
                /*VERIFICACAO DE PODERES*/
                FIND FIRST crappod WHERE crappod.cdcooper = par_cdcooper AND
                                   crappod.nrdconta = par_nrdconta AND
                                   crappod.nrcpfpro = DEC(REPLACE(REPLACE(par_nrcpfcgc,"-",""),".","")) NO-LOCK NO-ERROR.
                
                IF NOT AVAILABLE crappod THEN
                    DO:
                
                        FIND FIRST crappod WHERE crappod.cdcooper = par_cdcooper AND
                                   crappod.nrdconta = par_nrdconta AND
                                   crappod.nrctapro = par_nrdctato NO-LOCK NO-ERROR.
                        
                        IF NOT AVAILABLE crappod THEN
                            DO:
                
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Impossivel imprimir Cartao de Assin. Necessario cadastrar poderes".
                    
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                    
                                RETURN "NOK".
                           END.
                    END.
                /**/

                CREATE tt-ctaassin.
                
                IF NOT VALID-HANDLE(h-b1wgen9999) THEN
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                
                IF NOT VALID-HANDLE(h-b1wgen0058) THEN
                   RUN sistema/generico/procedures/b1wgen0058.p
                   PERSISTENT SET h-b1wgen0058.
                
                DYNAMIC-FUNCTION("ListaPoderes" IN h-b1wgen0058, OUTPUT aux_lstpoder).

                FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK.
                
                IF NOT AVAILABLE crapcop THEN
                   DO:
                        ASSIGN aux_cdcritic = 651.
            
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
            
                        RETURN "NOK".
                   END.
    
                ASSIGN tt-ctaassin.cdcooper = par_cdcooper
                       tt-ctaassin.nmcooper = crapcop.nmrescop
                       tt-ctaassin.drcooper = crapcop.dsdircop.
    
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                

                IF NOT AVAILABLE crapass THEN
                   DO:
                         ASSIGN aux_cdcritic = 9.
                        
                         RUN gera_erro (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1,
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
            
                         RETURN "NOK".
                   END.
                
                ASSIGN tt-ctaassin.cdagenci = INT(crapass.cdagenci)
                       tt-ctaassin.nrdconta = INT(par_nrdconta)
                       tt-ctaassin.idseqttl = INT(par_idseqttl)
                       tt-ctaassin.nmtitula = STRING(crapass.nmprimtl)
                       tt-ctaassin.nrcpftit = DEC(crapass.nrcpfcgc). 
              
    
                RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT tt-ctaassin.nrcpftit,
                                                   OUTPUT aux_stsnrcal,
                                                   OUTPUT aux_tppescpf).


                IF aux_tppescpf = 1 THEN
                   ASSIGN aux_cpfcgcti = STRING(STRING(tt-ctaassin.nrcpftit, "99999999999"), "xxx.xxx.xxx-xx").
                ELSE
                   ASSIGN aux_cpfcgcti = STRING((STRING(tt-ctaassin.nrcpftit, "99999999999999")), "xx.xxx.xxx/xxxx-xx").

                   
                /**/
                FIND crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                                   crapavt.nrdconta = par_nrdconta AND
                                   crapavt.nrcpfcgc = DEC(REPLACE(REPLACE(par_nrcpfcgc,"-",""),".","")) AND
                                   crapavt.tpctrato = 6
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                IF NOT AVAILABLE crapavt THEN
                    DO:
                        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                           crapass.nrdconta = par_nrdctato AND
                                           crapass.nrcpfcgc = DEC(REPLACE(REPLACE(par_nrcpfcgc,"-",""),".",""))NO-LOCK NO-ERROR NO-WAIT.
                        
                        IF NOT AVAILABLE crapass THEN
                            DO:
                                ASSIGN aux_cdcritic = 9.
                                
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                                        
                                RETURN "NOK".
                            END.
                        
                        ASSIGN tt-ctaassin.nmprocur = crapass.nmprimtl
                               aux_nrcpftpr         = STRING(STRING(crapass.nrcpfcgc, "99999999999"), "xxx.xxx.xxx-xx")
                               tt-ctaassin.dsfuncao = STRING(crapass.dsproftl).

                        FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                                          WHERE craptfc.cdcooper = par_cdcooper
                                          AND   craptfc.nrdconta = par_nrdctato
                                          AND   craptfc.idseqttl = 1
                                          NO-LOCK:
                            ASSIGN tt-ctaassin.nrtelpro = STRING(craptfc.nrdddtfc, "999") +
                                                          STRING(craptfc.nrtelefo, "zzzzzzzzz9").
                                                
                        END.

                    END.
                 ELSE
                     DO:
                        
                        ASSIGN tt-ctaassin.nmprocur = crapavt.nmdavali
                               aux_nrcpftpr         = STRING(STRING(crapavt.nrcpfcgc, "99999999999"), "xxx.xxx.xxx-xx")
                               tt-ctaassin.nrtelpro = STRING(crapavt.nrfonres, "99 9999-9999")
                               tt-ctaassin.dsfuncao = STRING(crapavt.dsproftl)
                               tt-ctaassin.dtvencim = STRING(crapavt.dtvalida, "99/99/9999")
                               aux_datvenci = tt-ctaassin.dtvencim
                               crapavt.flgimpri     = FALSE.

                        IF crapavt.nmdavali = "" THEN
                            DO:
                                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                                   crapass.nrdconta = par_nrdctato AND
                                                   crapass.nrcpfcgc = DEC(REPLACE(REPLACE(par_nrcpfcgc,"-",""),".","")) NO-LOCK NO-ERROR NO-WAIT. 
                                
                                IF NOT AVAILABLE crapass THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 9.
                                        
                                        RUN gera_erro (INPUT par_cdcooper,
                                                       INPUT par_cdagenci,
                                                       INPUT par_nrdcaixa,
                                                       INPUT 1,
                                                       INPUT aux_cdcritic,
                                                       INPUT-OUTPUT aux_dscritic).
                            
                                        RETURN "NOK".
                                       END.
                                

                                ASSIGN tt-ctaassin.nmprocur = STRING(crapass.nmprimtl).

                                FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                                                  WHERE craptfc.cdcooper = par_cdcooper
                                                  AND   craptfc.nrdconta = par_nrdctato
                                                  AND   craptfc.idseqttl = 1
                                                  NO-LOCK:
                                    ASSIGN tt-ctaassin.nrtelpro = STRING(craptfc.nrdddtfc, "999") +
                                                                  STRING(craptfc.nrtelefo, "zzzzzzzzz9").
                                END.

                                IF tt-ctaassin.dsfuncao = "" THEN
                                   ASSIGN tt-ctaassin.dsfuncao = STRING(crapass.dsproftl).
                            END.
                     END.
                /**/

                RELEASE crapavt.

                ASSIGN aux_nrdconta = TRIM(STRING(tt-ctaassin.nrdconta,"zzzz,zzz,9")).

                DISPLAY STREAM str_1 tt-ctaassin.nmcooper tt-ctaassin.cdagenci aux_nrdconta /*aux_idseqttl*/
                                     aux_cpfcgcti tt-ctaassin.nmtitula
                                     tt-ctaassin.nmprocur aux_nrcpftpr tt-ctaassin.nrtelpro 
                                     tt-ctaassin.dsfuncao WITH FRAME f_cartaoasspj.
                
                ASSIGN aux_contpode = 1.

                FOR EACH crappod WHERE crappod.cdcooper = par_cdcooper AND
                                       crappod.nrdconta = par_nrdconta AND
                                       crappod.nrcpfpro = DEC(REPLACE(REPLACE(par_nrcpfcgc,"-",""), ".", ""))
                                       NO-LOCK:
                    
                    ASSIGN aux_flgconju = ""
                           aux_flgisola = ""
                           aux_dscpoder = "".
    
                    IF crappod.cddpoder <> 9 THEN
                        DO:
                            ASSIGN aux_dscpoder = ENTRY(crappod.cddpoder, aux_lstpoder).
    
                            IF crappod.flgisola = NO THEN
                               aux_flgisola = "NAO".
                            ELSE
                               aux_flgisola = "SIM". 
                                
                            IF crappod.flgconju = NO THEN
                               aux_flgconju = "NAO".
                            ELSE
                               aux_flgconju = "SIM". 
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_dsoutpo1 = ""
                                   aux_dsoutpo2 = ""
                                   aux_dsoutpo3 = ""
                                   aux_dsoutpo4 = ""
                                   aux_dsoutpo5 = "".
    
                            DO aux_contstri = 1 TO NUM-ENTRIES(crappod.dsoutpod,"#"):
                                
                               IF aux_contstri = 1 THEN
                                  aux_dsoutpo1 = ENTRY(aux_contstri,crappod.dsoutpod,"#").
                               ELSE
                                   IF aux_contstri = 2 THEN
                                      aux_dsoutpo2 = ENTRY(aux_contstri,crappod.dsoutpod,"#").
                               ELSE
                                   IF aux_contstri = 3 THEN
                                      aux_dsoutpo3 = ENTRY(aux_contstri,crappod.dsoutpod,"#").
                               ELSE
                                   IF aux_contstri = 4 THEN
                                      aux_dsoutpo4 = ENTRY(aux_contstri,crappod.dsoutpod,"#").
                               ELSE
                                   IF aux_contstri = 5 THEN
                                      aux_dsoutpo5 = ENTRY(aux_contstri,crappod.dsoutpod,"#").
                            END.
                        END.
                            
                    IF aux_contpode = 1 THEN 
                        DO:
                            PUT STREAM str_1 aux_flgconju FORMAT "x(6)" aux_flgisola FORMAT "x(4)" aux_dscpoder FORMAT "x(39)".
                            aux_contpode = 2.
                        END.
                        
                    ELSE
                        DO:
                            PUT STREAM str_1 aux_flgconju FORMAT "x(6)" aux_flgisola FORMAT "x(4)" aux_dscpoder FORMAT "x(39)"  SKIP.
                            aux_contpode = 1.
                        END.                
                END.
                
                DISPLAY STREAM str_1 aux_datvenci aux_dsoutpo1 aux_dsoutpo2 aux_dsoutpo3 aux_dsoutpo4 aux_dsoutpo5 WITH FRAME f_cartaoasspj1.
                
                PAGE STREAM str_1.

                IF  VALID-HANDLE(h-b1wgen9999)  THEN
                    DELETE PROCEDURE h-b1wgen9999.

                IF  VALID-HANDLE(h-b1wgen0058)  THEN
                    DELETE PROCEDURE h-b1wgen0058.

            END.
            /* Fim Procurador */
    ELSE
        /* Todos */
        IF par_tppessoa = 3 THEN
            DO:
/* Imprime Todos Procuradores */
                
                ASSIGN aux_contproc = 0
                       aux_countaux = 0.
                
                EMPTY TEMP-TABLE tt-ctaassin.
                
                FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK.
                            
                IF NOT AVAILABLE crapcop THEN
                   DO:
                        ASSIGN aux_cdcritic = 651.
            
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
            
                        RETURN "NOK".
                   END.
                
                FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                                       crapavt.nrdconta = par_nrdconta AND
                                       crapavt.tpctrato = 6 NO-LOCK:
                   
                    aux_contproc = aux_contproc + 1.
                    
                    /*VERIFICACAO DE PODERES*/

                    FIND FIRST crappod WHERE crappod.cdcooper = par_cdcooper AND
                                             crappod.nrdconta = par_nrdconta AND
                                             crappod.nrcpfpro = crapavt.nrcpfcgc NO-LOCK NO-ERROR.

                    IF NOT AVAILABLE crappod THEN
                        DO:
                            FIND FIRST crappod WHERE crappod.cdcooper = par_cdcooper AND
                                               crappod.nrdconta = par_nrdconta AND
                                               crappod.nrctapro = crapavt.nrdctato NO-LOCK NO-ERROR.
                            
                            IF NOT AVAILABLE crappod THEN
                                DO:
    
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Impossivel imprimir Cartao de Assin. Necessario cadastrar poderes".
                        
                                    RUN gera_erro (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT 1,
                                                   INPUT aux_cdcritic,
                                                   INPUT-OUTPUT aux_dscritic).
                        
                                    RETURN "NOK".
                               END.
                        END.
                    /**/

                    CREATE tt-ctaassin.
                    
                    ASSIGN tt-ctaassin.cdcooper = par_cdcooper
                           tt-ctaassin.nmcooper = crapcop.nmrescop
                           tt-ctaassin.drcooper = crapcop.dsdircop
                           tt-ctaassin.nrdconta = par_nrdconta
                           tt-ctaassin.nrcpfpro = crapavt.nrcpfcgc
                           tt-ctaassin.nrdctapr = crapavt.nrdctato 
                           tt-ctaassin.dtvencim = STRING(crapavt.dtvalida, "99/99/9999").
    
                END.
                
                IF NOT VALID-HANDLE(h-b1wgen9999) THEN
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                
                IF NOT VALID-HANDLE(h-b1wgen0058) THEN
                   RUN sistema/generico/procedures/b1wgen0058.p
                   PERSISTENT SET h-b1wgen0058.
                
                DYNAMIC-FUNCTION("ListaPoderes" IN h-b1wgen0058, OUTPUT aux_lstpoder).
                
                IF aux_contproc > 0 THEN
                    DO:
                            
                        FOR EACH tt-ctaassin NO-LOCK:
                            
                                                    
                           FIND crapavt WHERE crapavt.cdcooper = par_cdcooper          AND
                                              crapavt.nrdconta = par_nrdconta          AND
                                              crapavt.nrdctato = tt-ctaassin.nrdctapr  AND 
                                              crapavt.nrcpfcgc = tt-ctaassin.nrcpfpro  AND
                                              crapavt.tpctrato = 6 EXCLUSIVE-LOCK NO-ERROR.

                            
                            IF NOT AVAILABLE crapavt THEN
                               DO:
                                    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                                       crapass.nrdconta = tt-ctaassin.nrdctapr NO-LOCK NO-ERROR.
                                    
                                    IF NOT AVAILABLE crapass THEN
                                       DO:
                                            ASSIGN aux_cdcritic = 9.
                                            
                                            RUN gera_erro (INPUT par_cdcooper,
                                                           INPUT par_cdagenci,
                                                           INPUT par_nrdcaixa,
                                                           INPUT 1,
                                                           INPUT aux_cdcritic,
                                                           INPUT-OUTPUT aux_dscritic).
                                
                                            RETURN "NOK".
                                       END. 

                                    ASSIGN tt-ctaassin.nmprocur = STRING(crapass.nmprimtl)
                                           aux_nrcpftpr         = STRING(STRING(crapass.nrcpfcgc, "99999999999"), "xxx.xxx.xxx-xx")
                                           tt-ctaassin.dsfuncao = STRING(crapass.dsproftl).

                                    FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                                                      WHERE craptfc.cdcooper = par_cdcooper
                                                      AND   craptfc.nrdconta = tt-ctaassin.nrdctapr
                                                      AND   craptfc.idseqttl = 1
                                                      NO-LOCK:
                                        ASSIGN tt-ctaassin.nrtelpro = STRING(craptfc.nrdddtfc, "999") +
                                                                      STRING(craptfc.nrtelefo, "zzzzzzzzz9").
                                    END.
                               END.
                            
                            ASSIGN tt-ctaassin.nmprocur = STRING(crapavt.nmdavali)
                                   tt-ctaassin.nrtelpro = STRING(crapavt.nrfonres, "99 9999-9999")
                                   tt-ctaassin.dsfuncao = STRING(crapavt.dsproftl)
                                   crapavt.flgimpri     = FALSE.

                            IF crapavt.nmdavali = "" THEN
                                DO:
                                    
                                    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                                       crapass.nrdconta = INT(tt-ctaassin.nrdctapr) AND
                                                       crapass.nrcpfcgc = tt-ctaassin.nrcpfpro NO-LOCK NO-ERROR NO-WAIT. 
                                    
                                    IF NOT AVAILABLE crapass THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 9.
                                            
                                                RUN gera_erro (INPUT par_cdcooper,
                                                               INPUT par_cdagenci,
                                                               INPUT par_nrdcaixa,
                                                               INPUT 1,
                                                               INPUT aux_cdcritic,
                                                               INPUT-OUTPUT aux_dscritic).
                                    
                                                RETURN "NOK".
                                           END.
                                    

                                    ASSIGN tt-ctaassin.nmprocur = STRING(crapass.nmprimtl).

                                    FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                                                      WHERE craptfc.cdcooper = par_cdcooper
                                                      AND   craptfc.nrdconta = tt-ctaassin.nrdctapr
                                                      AND   craptfc.idseqttl = 1
                                                      NO-LOCK:
                                        ASSIGN tt-ctaassin.nrtelpro = STRING(craptfc.nrdddtfc, "999") +
                                                                      STRING(craptfc.nrtelefo, "zzzzzzzzz9").
                                    END.

                                    IF tt-ctaassin.dsfuncao = "" THEN
                                       ASSIGN tt-ctaassin.dsfuncao = STRING(crapass.dsproftl).
                                END.

                            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                               crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                            
                            IF NOT AVAILABLE crapass THEN
                               DO:
                                    ASSIGN aux_cdcritic = 9.
                                    
                                    RUN gera_erro (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT 1,
                                                   INPUT aux_cdcritic,
                                                   INPUT-OUTPUT aux_dscritic).
                        
                                    RETURN "NOK".
                               END.
                              
                            ASSIGN tt-ctaassin.nmtitula = STRING(crapass.nmprimtl)
                                   tt-ctaassin.nrcpftit = crapass.nrcpfcgc
                                   tt-ctaassin.cdagenci = crapass.cdagenci
                                   aux_datvenci = tt-ctaassin.dtvencim.

                        END.
    
                    END.
                    
                    FOR EACH tt-ctaassin NO-LOCK:
                    
                        ASSIGN aux_nrdconta = TRIM(STRING(tt-ctaassin.nrdconta,"zzzz,zzz,9")).
                        
                        /*CPF*/
                        RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT tt-ctaassin.nrcpftit,
                                                           OUTPUT aux_stsnrcal,
                                                           OUTPUT aux_tppescpf).
    
    
                        IF aux_tppescpf = 1 THEN
                           ASSIGN aux_cpfcgcti = STRING(STRING(tt-ctaassin.nrcpftit, "99999999999"), "xxx.xxx.xxx-xx").
                        ELSE
                           ASSIGN aux_cpfcgcti = STRING((STRING(tt-ctaassin.nrcpftit, "99999999999999")), "xx.xxx.xxx/xxxx-xx").
    
    
                        /*CPF*/
                        RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT tt-ctaassin.nrcpfpro,
                                                   OUTPUT aux_stsnrcal,
                                                   OUTPUT aux_tppescpf).
    
    
                        IF aux_tppescpf = 1 THEN
                           ASSIGN aux_nrcpftpr = STRING(STRING(tt-ctaassin.nrcpfpro, "99999999999"), "xxx.xxx.xxx-xx").
                        ELSE
                           ASSIGN aux_nrcpftpr = STRING((STRING(tt-ctaassin.nrcpfpro, "99999999999999")), "xx.xxx.xxx/xxxx-xx").
    
                        DISPLAY STREAM str_1 tt-ctaassin.nmcooper tt-ctaassin.cdagenci aux_nrdconta /*aux_idseqttl*/
                                             aux_cpfcgcti tt-ctaassin.nmtitula
                                             tt-ctaassin.nmprocur aux_nrcpftpr tt-ctaassin.nrtelpro 
                                             tt-ctaassin.dsfuncao WITH FRAME f_cartaoasspj.
    
                        
                        ASSIGN aux_contpode = 1.
    
                        FOR EACH crappod WHERE crappod.cdcooper = par_cdcooper AND
                                               crappod.nrdconta = par_nrdconta AND
                                               crappod.nrcpfpro = DEC(tt-ctaassin.nrcpfpro)
                                               NO-LOCK:
                            
                            ASSIGN aux_flgconju = ""
                                   aux_flgisola = ""
                                   aux_dscpoder = "".
            
                            IF crappod.cddpoder <> 9 THEN
                                DO:
                                    ASSIGN aux_dscpoder = ENTRY(crappod.cddpoder, aux_lstpoder).
            
                                    IF crappod.flgisola = NO THEN
                                       aux_flgisola = "NAO".
                                    ELSE
                                       aux_flgisola = "SIM". 
                                        
                                    IF crappod.flgconju = NO THEN
                                       aux_flgconju = "NAO".
                                    ELSE
                                       aux_flgconju = "SIM". 
                                END.
                            ELSE
                                DO:
                                    ASSIGN aux_dsoutpo1 = ""
                                           aux_dsoutpo2 = ""
                                           aux_dsoutpo3 = ""
                                           aux_dsoutpo4 = ""
                                           aux_dsoutpo5 = "".
            
                                    DO aux_contstri = 1 TO NUM-ENTRIES(crappod.dsoutpod,"#"):
                                        
                                       IF aux_contstri = 1 THEN
                                          aux_dsoutpo1 = ENTRY(aux_contstri,crappod.dsoutpod,"#").
                                       ELSE
                                           IF aux_contstri = 2 THEN
                                              aux_dsoutpo2 = ENTRY(aux_contstri,crappod.dsoutpod,"#").
                                       ELSE
                                           IF aux_contstri = 3 THEN
                                              aux_dsoutpo3 = ENTRY(aux_contstri,crappod.dsoutpod,"#").
                                       ELSE
                                           IF aux_contstri = 4 THEN
                                              aux_dsoutpo4 = ENTRY(aux_contstri,crappod.dsoutpod,"#").
                                       ELSE
                                           IF aux_contstri = 5 THEN
                                              aux_dsoutpo5 = ENTRY(aux_contstri,crappod.dsoutpod,"#").
                                    END.
                                END.
                                    
                            IF aux_contpode = 1 THEN 
                                DO:
                                    PUT STREAM str_1 aux_flgconju FORMAT "x(6)" aux_flgisola FORMAT "x(4)" aux_dscpoder FORMAT "x(39)".
                                    aux_contpode = 2.
                                END.
                                
                            ELSE
                                DO:
                                    PUT STREAM str_1 aux_flgconju FORMAT "x(6)" aux_flgisola FORMAT "x(4)" aux_dscpoder FORMAT "x(39)" SKIP.    
                                    aux_contpode = 1.
                                END.                
                        END.
                        
                        DISPLAY STREAM str_1 aux_datvenci aux_dsoutpo1 aux_dsoutpo2 aux_dsoutpo3 aux_dsoutpo4 aux_dsoutpo5 WITH FRAME f_cartaoasspj1.
                
                        PAGE STREAM str_1.
                        
                    END.
                        
    
                    IF  VALID-HANDLE(h-b1wgen9999)  THEN
                        DELETE PROCEDURE h-b1wgen9999.
    
                    IF  VALID-HANDLE(h-b1wgen0058)  THEN
                        DELETE PROCEDURE h-b1wgen0058.
    
                /* Fim Imprime Todos Procuradores */                
            
                /* Inicio Imprime Todos Titulares */
                     
                ASSIGN aux_conttitu = 0
                       aux_countaux = 0.
    
                FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper AND 
                                       crapttl.nrdconta = par_nrdconta NO-LOCK:
                    
                    aux_conttitu = aux_conttitu + 1.
                                       
                END.
                
                IF aux_conttitu > 0 THEN
                    DO:
                        EMPTY TEMP-TABLE tt-ctaassin.
                        
                        DO aux_countaux = 1 TO aux_conttitu:
                    
                            FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK.
                    
                            IF NOT AVAILABLE crapcop THEN
                               DO:
                                    ASSIGN aux_cdcritic = 651.
                                    
                                    RUN gera_erro (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT 1,
                                                   INPUT aux_cdcritic,
                                                   INPUT-OUTPUT aux_dscritic).
                        
                                    RETURN "NOK".
                               END.
                            
                            CREATE tt-ctaassin.
        
                            ASSIGN tt-ctaassin.cdcooper = par_cdcooper
                                   tt-ctaassin.nmcooper = crapcop.nmrescop
                                   tt-ctaassin.drcooper = crapcop.dsdircop.
                
                            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                               crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                
                            
                            IF NOT AVAILABLE crapass THEN
                               DO:
                                    
                                    ASSIGN aux_cdcritic = 9.
                                    
                                    RUN gera_erro (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT 1,
                                                   INPUT aux_cdcritic,
                                                   INPUT-OUTPUT aux_dscritic).
                        
                                    RETURN "NOK".
                               END.
                
                            ASSIGN tt-ctaassin.cdagenci = crapass.cdagenci.
                            
                            
                            contadorTtl: DO aux_contattl = 1 TO 10:
                                
                                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                                   crapttl.nrdconta = par_nrdconta AND
                                                   crapttl.idseqttl = aux_countaux
                                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                
                                IF NOT AVAILABLE crapttl THEN
                                    DO:
                                        IF LOCKED crapttl  THEN
                                            DO:
                                                IF aux_contattl = 10  THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 341.
                                                        LEAVE contadorTtl.
                                                     END.
                                                  ELSE
                                                     NEXT contadorTtl.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 12.
                                                LEAVE contadorTtl.
                                            END.
                                    END.
                                ELSE
                                    ASSIGN tt-ctaassin.nmtitula = crapttl.nmextttl
                                           tt-ctaassin.nrcpftit = crapttl.nrcpfcgc
                                           tt-ctaassin.nrdconta = par_nrdconta
                                           tt-ctaassin.idseqttl = crapttl.idseqttl
                                           crapttl.flgimpri = FALSE.
                            END.
                            
                        END.
                       
                        IF aux_cdcritic <> 0 THEN
                            DO:
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                                        
                                                RETURN "NOK".
                            END.

                        RELEASE crapttl.

                        /* Resp Legal */
                        
                        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK.
                        
                        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                
                            
                        IF NOT AVAILABLE crapass THEN
                           DO:
                                
                                ASSIGN aux_cdcritic = 9.
                                
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                    
                                RETURN "NOK".
                           END.
                        
                        ASSIGN aux_cdagenci = crapass.cdagenci.

                        FOR EACH crapcrl WHERE crapcrl.cdcooper = par_cdcooper AND
                                               crapcrl.nrctamen = par_nrdconta EXCLUSIVE-LOCK:
                            
                            IF crapcrl.nmrespon = "" THEN
                                DO:
                                    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                                       crapass.nrdconta = crapcrl.nrdconta
                                                       NO-LOCK NO-ERROR NO-WAIT.
                                    
                                    IF AVAIL crapass THEN
                                        DO:
                                            CREATE tt-ctaassin.
                                            ASSIGN tt-ctaassin.nmtitula = crapass.nmprimtl
                                                   tt-ctaassin.nrcpftit = crapass.nrcpfcgc
                                                   tt-ctaassin.nrdconta = par_nrdconta
                                                   tt-ctaassin.idseqttl = 0
                                                   tt-ctaassin.cdcooper = par_cdcooper
                                                   tt-ctaassin.nmcooper = crapcop.nmrescop
                                                   tt-ctaassin.cdagenci = aux_cdagenci.
                                        END.

                                END.
                            ELSE
                                DO:
                                    CREATE tt-ctaassin.
                                    ASSIGN tt-ctaassin.nmtitula = crapcrl.nmrespon
                                           tt-ctaassin.nrcpftit = crapcrl.nrcpfcgc
                                           tt-ctaassin.nrdconta = par_nrdconta
                                           tt-ctaassin.idseqttl = 0
                                           tt-ctaassin.cdcooper = par_cdcooper
                                           tt-ctaassin.nmcooper = crapcop.nmrescop
                                           tt-ctaassin.cdagenci = aux_cdagenci.
                                END.
                            
                            ASSIGN crapcrl.flgimpri = FALSE.

                        END.
                        /* Resp Legal */
                        
                        FOR EACH tt-ctaassin NO-LOCK:
        
                            ASSIGN aux_nrdconta = TRIM(STRING(tt-ctaassin.nrdconta,"zzzz,zzz,9"))
                                   aux_nrcpftpr = STRING(STRING(tt-ctaassin.nrcpftit, "99999999999"), "xxx.xxx.xxx-xx").

                            IF tt-ctaassin.idseqttl = 0 THEN
                                aux_idseqttl = "". 
                            ELSE
                                aux_idseqttl = STRING(tt-ctaassin.idseqttl).
        
                            DISPLAY STREAM str_1 tt-ctaassin.cdagenci aux_nrdconta aux_idseqttl tt-ctaassin.nmcooper tt-ctaassin.nmtitula aux_nrcpftpr WITH FRAME f_cartaoasspf.
                            
                            PAGE STREAM str_1.
        
                        END.
                        
                        EMPTY TEMP-TABLE tt-ctaassin.
    
                    END.
                
                /* Fim Imprime Todos Titulares */
            END.

            FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                                   crapavt.nrdconta = par_nrdconta AND
                                   crapavt.tpctrato = 6 EXCLUSIVE-LOCK:
                ASSIGN crapavt.flgimpri = FALSE.

            END.
            /* Fim Todos */
    
    OUTPUT STREAM str_1 CLOSE.
    
    /* Verifica se o arquivo já existe */
    IF SEARCH(par_nmarqimp) = ? OR par_nmarqimp = ? OR par_nmarqimp = "" THEN
       RETURN "NOK".

    IF par_nmarqimp <> "" THEN
        DO:
            IF  par_idorigem = 5  THEN  /** Ayllos Web **/
                DO:
                    IF NOT VALID-HANDLE(h-b1wgen0024)  THEN
                        DO:
                            RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                            SET h-b1wgen0024.
                        END.
                    
        
                        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                            DO:
                                ASSIGN aux_dscritic = "Handle invalido para BO " +
                                                      "b1wgen0024.".
                                LEAVE.
                            END.
        
                        RUN envia-arquivo-web IN h-b1wgen0024 
                                            ( INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_nmarqimp,
                                             OUTPUT par_nmarqimp,
                                             OUTPUT TABLE tt-erro ).
        
                        IF  VALID-HANDLE(h-b1wgen0024)  THEN
                            DELETE PROCEDURE h-b1wgen0024.
        
                        IF  RETURN-VALUE <> "OK" THEN
                            RETURN "NOK".
                END.

        END.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-titulares-impressao:
    DEF  INPUT PARAM par_cdcooper AS INTE   NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE   NO-UNDO.
    DEF OUTPUT PARAM par_qtregist AS INTE   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapttl.
    
    DEF VAR h-b1wgen0059 AS HANDLE          NO-UNDO.
    
    IF NOT VALID-HANDLE(h-b1wgen0059) THEN
                    RUN sistema/generico/procedures/b1wgen0059.p
                    PERSISTENT SET h-b1wgen0059.
    
    RUN busca-crapttl IN h-b1wgen0059(
                                      INPUT par_cdcooper,
                                      INPUT par_nrdconta,
                                      INPUT 4,
                                      INPUT 1,
                                     OUTPUT par_qtregist,
                                     OUTPUT TABLE tt-crapttl).
    
    IF VALID-HANDLE(h-b1wgen0059)  THEN
        DELETE PROCEDURE h-b1wgen0059.
    
    FOR EACH tt-crapttl NO-LOCK:
        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper        AND
                           crapttl.nrdconta = tt-crapttl.nrdconta AND
                           crapttl.idseqttl = tt-crapttl.idseqttl EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
        IF AVAILABLE crapttl THEN
            crapttl.flgimpri = FALSE.

    END.

    FOR EACH crapcrl WHERE crapcrl.cdcooper = par_cdcooper AND
                           crapcrl.nrctamen = par_nrdconta NO-LOCK:
        
        CREATE tt-crapttl.
        ASSIGN tt-crapttl.idseqttl = 0.
        
        FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.

        ASSIGN tt-crapttl.nmrescop = crapcop.nmrescop.

        IF crapcrl.nrdconta <> 0 THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = crapcrl.nrdconta NO-LOCK.

                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                   crapttl.nrdconta = crapcrl.nrdconta AND 
                                   crapttl.idseqttl = 1 NO-LOCK.
                
                ASSIGN tt-crapttl.nmextttl = crapttl.nmextttl
                       tt-crapttl.nrcpfcgc = crapttl.nrcpfcgc
                       tt-crapttl.nrdconta = crapcrl.nrdconta
                       tt-crapttl.cdagenci = crapass.cdagenci.
            END.
        ELSE
                ASSIGN tt-crapttl.nmextttl = crapcrl.nmrespon
                       tt-crapttl.nrcpfcgc = crapcrl.nrcpfcgc
                       tt-crapttl.nrdconta = ?
                       tt-crapttl.cdagenci = 0. /*Passado 0 conforme pedido do analista Gielow*/
    END.

    FOR EACH crapcrl WHERE crapcrl.cdcooper = par_cdcooper AND
                           crapcrl.nrctamen = par_nrdconta EXCLUSIVE-LOCK:
        
        ASSIGN crapcrl.flgimpri = FALSE.

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Imprime_Cartao_Assinatura:
    DEF  INPUT PARAM par_cdcooper AS INTE   NO-UNDO.

    DEF VAR flg_digitlib AS CHAR NO-UNDO.
    
    
    FIND craptab WHERE  craptab.cdcooper = par_cdcooper    AND
                        craptab.nmsistem = "CRED"          AND
                        craptab.tptabela = "GENERI"        AND
                        craptab.cdempres = 00              AND
                        craptab.cdacesso = "DIGITALIBE"    AND
                        craptab.tpregist = 1  NO-LOCK NO-ERROR.
    
    IF NOT AVAIL craptab THEN
        DO:
            RETURN "NOK".
        END.

    ASSIGN flg_digitlib = ENTRY(1,craptab.dstextab,";").
    
    IF flg_digitlib = "S" THEN
        RETURN "OK".
    ELSE
        RETURN "NOK".

END.

PROCEDURE busca-procuradores-impressao:
    DEF  INPUT PARAM par_cdcooper AS INTE   NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE   NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE   NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE   NO-UNDO.
    DEF OUTPUT PARAM par_qtregist AS INTE   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-cratavt.
    DEF OUTPUT PARAM TABLE FOR tt-cratpod.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen9999 AS HANDLE          NO-UNDO.

    DEF VAR aux_tppescpf AS INT             NO-UNDO.
    DEF VAR aux_stsnrcal AS LOGICAL         NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR            NO-UNDO.
    DEF VAR aux_nrcpfpro AS CHAR            NO-UNDO.

    FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                           crapavt.nrdconta = par_nrdconta AND
                           crapavt.tpctrato = 6 NO-LOCK:
        
        /*VERIFICACAO DE PODERES*/

        FIND FIRST crappod WHERE crappod.cdcooper = par_cdcooper AND
                                 crappod.nrdconta = par_nrdconta AND
                                 crappod.nrcpfpro = crapavt.nrcpfcgc NO-LOCK NO-ERROR.

        IF NOT AVAILABLE crappod THEN
            DO:
                FIND FIRST crappod WHERE crappod.cdcooper = par_cdcooper AND
                                         crappod.nrdconta = par_nrdconta AND
                                         crappod.nrctapro = crapavt.nrdctato NO-LOCK NO-ERROR.
                
                IF NOT AVAILABLE crappod THEN
                    DO:

                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Impossivel imprimir Cartao de Assin. Necessario cadastrar poderes".
            
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
            
                        RETURN "NOK".
                   END.
            END.
        /**/

        CREATE tt-cratavt.

        IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
            RUN sistema/generico/procedures/b1wgen9999.p
                PERSISTENT SET h-b1wgen9999.

        RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT crapavt.nrcpfcgc,
                                           OUTPUT aux_stsnrcal,
                                           OUTPUT aux_tppescpf).


        IF aux_tppescpf = 1 THEN
           ASSIGN aux_nrcpfpro = STRING(STRING(crapavt.nrcpfcgc, "99999999999"), "xxx.xxx.xxx-xx").
        ELSE
           ASSIGN aux_nrcpfpro = STRING((STRING(crapavt.nrcpfcgc, "99999999999999")), "xx.xxx.xxx/xxxx-xx").


        FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.

        IF AVAIL crapcop THEN
            DO:
                ASSIGN tt-cratavt.nmrescop = crapcop.nmrescop.
            END.

        ASSIGN tt-cratavt.nmrescop = crapcop.nmrescop
               tt-cratavt.nrdconta = par_nrdconta
               tt-cratavt.nmprocur = crapavt.nmdavali
               tt-cratavt.dsfuncao = crapavt.dsproftl
               tt-cratavt.nrcpfpro = aux_nrcpfpro
               tt-cratavt.nrdctato = crapavt.nrdctato 
               tt-cratavt.dtvencim = STRING(crapavt.dtvalida, "99/99/9999").

        IF crapavt.nmdavali = "" OR crapavt.dsproftl = "" THEN
            DO:
                FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                         crapass.nrdconta = crapavt.nrdctato NO-LOCK NO-ERROR NO-WAIT.

                IF AVAIL crapass THEN
                    DO:
                        ASSIGN tt-cratavt.nmprocur = crapass.nmprimtl
                               tt-cratavt.dsfuncao = crapass.dsproftl.
                    END.

            END.

        FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                 crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR NO-WAIT.

            IF AVAIL crapass THEN
                DO:
                    RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT crapass.nrcpfcgc,
                                                       OUTPUT aux_stsnrcal,
                                                       OUTPUT aux_tppescpf).


                    IF aux_tppescpf = 1 THEN
                       ASSIGN aux_nrcpfcgc = STRING(STRING(crapass.nrcpfcgc, "99999999999"), "xxx.xxx.xxx-xx").
                    ELSE
                       ASSIGN aux_nrcpfcgc = STRING((STRING(crapass.nrcpfcgc, "99999999999999")), "xx.xxx.xxx/xxxx-xx").
                    
                    ASSIGN tt-cratavt.nmtitula = crapass.nmprimtl
                           tt-cratavt.cdagenci = crapass.cdagenci
                           tt-cratavt.nrcpfcgc = aux_nrcpfcgc.
                END.

        FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo) WHERE craptfc.cdcooper = par_cdcooper AND
                                                          craptfc.nrdconta = crapavt.nrdctato AND
                                                          craptfc.idseqttl = 1 NO-LOCK.
                            
            ASSIGN tt-cratavt.nrtelefo = STRING(craptfc.nrdddtfc, "999") + STRING(craptfc.nrtelefo, "zzzzzzzzz9").
                                                
        END.

        IF VALID-HANDLE(h-b1wgen9999) THEN
            DELETE OBJECT h-b1wgen9999.
        
        FOR EACH crappod WHERE crappod.cdcooper = par_cdcooper AND
                               crappod.nrdconta = par_nrdconta AND
                               crappod.nrcpfpro = crapavt.nrcpfcgc AND
                               crappod.nrctapro = crapavt.nrdctato NO-LOCK:
        
            CREATE tt-cratpod.

            ASSIGN tt-cratpod.codpoder = crappod.cddpoder
                   tt-cratpod.nrdctato = crappod.nrctapro
                   tt-cratpod.dsoutpod = crappod.dsoutpod
                   tt-cratpod.nrcpfcgc = STRING(
                                         STRING(crappod.nrcpfpro,
                                                "99999999999"),
                                                "xxx.xxx.xxx-xx").

            IF crappod.flgconju = YES THEN
                ASSIGN tt-cratpod.flgconju = "SIM".
            ELSE
                ASSIGN tt-cratpod.flgconju = "NAO".

            IF crappod.flgisola = YES THEN
                ASSIGN tt-cratpod.flgisola = "SIM".
            ELSE
                ASSIGN tt-cratpod.flgisola = "NAO".

        END.

    END.
    
    
    FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                           crapavt.nrdconta = par_nrdconta AND
                           crapavt.tpctrato = 6 EXCLUSIVE-LOCK:
        
        ASSIGN crapavt.flgimpri = FALSE.

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-lista-titulares:
    DEF  INPUT PARAM par_cdcooper AS INTE   NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE   NO-UNDO.
    DEF OUTPUT PARAM par_qtregist AS INTE   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapttl.
    
    DEF VAR h-b1wgen0059 AS HANDLE          NO-UNDO.
    
    IF NOT VALID-HANDLE(h-b1wgen0059) THEN
                    RUN sistema/generico/procedures/b1wgen0059.p
                    PERSISTENT SET h-b1wgen0059.
    
    RUN busca-crapttl IN h-b1wgen0059(INPUT par_cdcooper,
                                      INPUT par_nrdconta,
                                      INPUT 4,
                                      INPUT 1,
                                     OUTPUT par_qtregist,
                                     OUTPUT TABLE tt-crapttl).
    
    IF VALID-HANDLE(h-b1wgen0059)  THEN
        DELETE PROCEDURE h-b1wgen0059.
    
    FOR EACH crapcrl WHERE crapcrl.cdcooper = par_cdcooper AND
                           crapcrl.nrctamen = par_nrdconta NO-LOCK:
        
        CREATE tt-crapttl.
        ASSIGN tt-crapttl.idseqttl = 0.
        
        FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.

        ASSIGN tt-crapttl.nmrescop = crapcop.nmrescop.

        

        IF crapcrl.nrdconta <> 0 THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = crapcrl.nrdconta NO-LOCK.

                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                   crapttl.nrdconta = crapcrl.nrdconta AND 
                                   crapttl.idseqttl = 1 NO-LOCK.
                
                ASSIGN tt-crapttl.nmextttl = crapttl.nmextttl
                       tt-crapttl.nrcpfcgc = crapttl.nrcpfcgc
                       tt-crapttl.nrdconta = par_nrdconta
                       tt-crapttl.nrdctato = crapcrl.nrdconta
                       tt-crapttl.cdagenci = crapass.cdagenci.
            END.
        ELSE
                ASSIGN tt-crapttl.nmextttl = crapcrl.nmrespon
                       tt-crapttl.nrcpfcgc = crapcrl.nrcpfcgc
                       tt-crapttl.nrdconta = crapcrl.nrdconta
                       tt-crapttl.cdagenci = 0. /*Passado 0 conforme pedido do analista Gielow*/
    END.

    RETURN "OK".

END PROCEDURE.




