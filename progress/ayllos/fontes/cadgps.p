/* ............................................................................

   Programa: Fontes/cadgps.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Julho/2005                        Ultima Atualizacao: 04/10/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Permitir cadastro de Guias da Previdencia.

   ALTERACAO : 16/11/2005 - Alterado para liberar alteracao do campo nome
                            mesmo se possuir conta na cooperativa (Diego).

               18/11/2005 - Efetuar leitura crapcgp com o codigo da
                            cooperativa(Mirtes)

               21/12/2005 - Comentados campos ref. "Caixa Postal" e prefixo
                            "DDD", e alterada leitura da tabela crapttl pela
                            crapass (Diego).

               25/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               19/05/2006 - Modificados campos referente endereco para a
                            estrutura crapenc (Diego).

               27/02/2008 - Reestruturacao da tela;
                          - Inclusao do campo "Tipo de Contribuinte";
                          - Carregar o registro do browse com o ENTER;
                          - Ativacao do campo de debito autorizado;
                            (Evandro).

               14/04/2008 - Mudanca label(Evandro)

               09/06/2008 - Consistencias dos campos identificador, codigo do
                            pagamento e valor (Gabriel).
                          - Consistencias do campo Debito Autorizado (Elton).

               26/06/2008 - Retirado a obrigatoriedade no cpf/cgc. (Rosangela).

               11/07/2008 - Incluida uma transacao para que se grave uma
                            inclusao de GPS logo apos a confirmacao da
                            operacao (Elton).

               18/07/2008 - Alterada critica no campo "Valor" para nao permitir
                            guias com valor menor do que R$ 29,00 (Elton).

               18/08/2008 - Incluido campos "Seq.Ttl no form principal;
                          - Incluido cddpagto nos FINDs da tabela crapcpg;
                          - Incluido opcao "D" para cadastro de Debito
                            Autorizado (Elton).

               29/09/2008 - Verificar se o codigo de pgto existe na crapgps
                            na hora da inclusao (Gabriel).

               10/10/2008 - Alterado para nao permitir alteracao do campo
                            ativo para "Sim" se o seu codigo de pagamento nao
                            estiver habilitado (Gabriel)

               20/04/2009  - Criado log para a tela - procedure proc_crialog
                            (Fernando).

               26/05/2011 - Adaptacao para uso de BO.
                            Inclusão de CEP integrado. (André - DB1)

               21/12/2011 - Corrigido warnings (Tiago).
               
               04/10/2012 - Corrigido Assign duplicado para o campo TEL_NMEXTTTL (Daniel).
               
............................................................................ */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0093tt.i }
{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM &PROC-BUSCA=SIM }

DEF VAR h-b1wgen0093 AS HANDLE                                         NO-UNDO.

DEF NEW SHARED VAR shr_inpessoa AS INTE                                NO-UNDO.
DEF NEW SHARED VAR shr_idseqttl LIKE crapttl.idseqttl                  NO-UNDO.
DEF NEW SHARED VAR shr_nrdconta LIKE crapttl.nrdconta                  NO-UNDO.

DEF VAR tel_cdidenti LIKE crapcgp.cdidenti                             NO-UNDO.
DEF VAR tel_cddpagto LIKE crapcgp.cddpagto                             NO-UNDO.
DEF VAR tel_nrdconta LIKE crapcgp.nrdconta                             NO-UNDO.
DEF VAR tel_tpcontri LIKE crapcgp.tpcontri                             NO-UNDO.
DEF VAR tel_idseqttl LIKE crapcgp.idseqttl                             NO-UNDO.
DEF VAR tel_nmextttl LIKE crapcgp.nmprimtl                             NO-UNDO.
DEF VAR tel_nrcpfcgc LIKE crapcgp.nrcpfcgc                             NO-UNDO.
DEF VAR tel_dsendres LIKE crapcgp.dsendres                             NO-UNDO.
DEF VAR tel_nmbairro AS CHAR               FORMAT "X(40)"              NO-UNDO.
DEF VAR tel_nmcidade AS CHAR               FORMAT "X(25)"              NO-UNDO.
DEF VAR tel_nrcepend LIKE crapcgp.nrcepend                             NO-UNDO.
DEF VAR tel_cdufresd LIKE crapcgp.cdufresd                             NO-UNDO.
DEF VAR tel_nrcxpost LIKE crapcgp.nrcxpost                             NO-UNDO.
DEF VAR tel_nrdddres LIKE crapcgp.nrdddres                             NO-UNDO.
DEF VAR tel_nrfonres LIKE crapcgp.nrfonres FORMAT "x(20)"              NO-UNDO.
DEF VAR tel_flgrgatv LIKE crapcgp.flgrgatv                             NO-UNDO.
DEF VAR tel_flgdbaut LIKE crapcgp.flgdbaut                             NO-UNDO.

/* Adicionais CEP integrado */
DEF VAR tel_nrendres LIKE crapcgp.nrendres                             NO-UNDO.
DEF VAR tel_complend LIKE crapcgp.complend                             NO-UNDO.
DEF VAR tel_nrcxapst LIKE crapcgp.nrcxapst                             NO-UNDO.

DEF VAR tel_dspessoa AS CHAR               FORMAT "x(10)"              NO-UNDO.
DEF VAR tel_nmctadeb AS CHAR               FORMAT "x(30)"              NO-UNDO.
DEF VAR tel_inpessoa LIKE crapcgp.inpessoa                             NO-UNDO.
DEF VAR tel_nrctadeb LIKE crapcgp.nrctadeb                             NO-UNDO.
DEF VAR tel_vlrdinss LIKE crapcgp.vlrdinss                             NO-UNDO.
DEF VAR tel_vloutent LIKE crapcgp.vloutent                             NO-UNDO.
DEF VAR tel_vlrjuros LIKE crapcgp.vlrjuros                             NO-UNDO.
DEF VAR tel_vlrtotal LIKE crapcgp.vlrdinss                             NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR  FORMAT "!(1)"                            NO-UNDO.
DEF VAR aux_msgretor AS CHAR                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_flgexass AS LOGI                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_cddpagto AS INTE                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_flgconti AS LOGI                                           NO-UNDO.
DEF VAR aux_posvalid AS INTE                                           NO-UNDO.

FORM SKIP(1)

    glb_cddopcao    AT 03 LABEL "Opcao" AUTO-RETURN
                    HELP  "Informe a opcao desejada (A, C, D ou I)."
                    VALIDATE(CAN-DO("A,C,D,I",glb_cddopcao),
                                                        "014 - Opcao errada.")
    tel_cdidenti    AT 16 LABEL "Identificador"
                    HELP  "Informe o codigo identificador."

    tel_cddpagto    AT 56 LABEL "Codigo pgto"
                    HELP  "Informe o codigo de pagamento ou 'F7' para listar."
                    VALIDATE(NOT CAN-DO("0000,4995,5096,5037,5045," +
                                        "5053,5061,5070,5088,5096," +
                                        "5100,5118,5126,5134",
                                        tel_cddpagto),
                                        "Codigo do pagamento nao " +
                                        "permitido.")
    SKIP(1)

    tel_tpcontri    AT 03 LABEL "Tipo "  FORMAT "z9"
        HELP "1-Cliente/Outros 2-Propria Coop. 3-Prest. Servicos Propria Coop."
                    VALIDATE(CAN-DO("1,2,3",STRING(tel_tpcontri)),
                                    "513 - Tipo errado.")

    tel_nrdconta    AT 16 LABEL "Conta/dv contribuinte"
                    HELP  "Informe o numero da conta."

    tel_idseqttl    LABEL "Seq.Ttl"
                    HELP  "Informe o titular da conta."
    /************Comentado temporariamente**********
    tel_cdagenci     LABEL "PAC"
                           HELP "Informe o PAC do pagamento da guia."
                           VALIDATE(tel_cdagenci <> 0,
                                    "089 - Agencia devera ser informada.")
    ***********************************************/
    SKIP(1)
    tel_nmextttl    AT 03 LABEL "Contribuinte"
                    HELP  "Informe o nome do contribuinte que apresenta na guia."
    SKIP
    tel_nrcpfcgc    AT 03 LABEL "CPF/CNPJ"
                    HELP  "Informe o numero do CPF ou CNPJ que apresenta na guia."
    SKIP

    tel_nrcepend    AT 03 LABEL "CEP" FORMAT "99999,999"
                    HELP "Informe o CEP ou pressione F7 para pesquisar"
    tel_dsendres    AT 23 LABEL "Endereco"
                    HELP  "Informe o endereco do contribuinte."
    SKIP
    tel_nrendres    AT 03 LABEL "Nro."
                    HELP  "Entre com o numero do endereco"
    tel_complend    AT 23 LABEL "Complemento"
                    HELP  "Informe o complemento do endereco"
    SKIP
    tel_nmbairro    AT 03 LABEL "Bairro"
                    HELP  "Informe o nome do bairro."
    tel_nrcxapst    AT 56 LABEL "Caixa Postal"
                    HELP  "Informe o numero da caixa postal"
    SKIP
    tel_nmcidade    AT 03 LABEL "Cidade"
                    HELP "Informe o nome da cidade."
    tel_cdufresd    AT 40 LABEL "UF"
                    HELP "Informe a sigla do estado."
    tel_nrfonres    AT 50 LABEL "Fone"
                    HELP "Informe o numero do telefone do contribuinte."
    SKIP(1)
    tel_flgrgatv    AT 03 LABEL "Ativo"
                    HELP "Informe (S)im ou (N)ao."
    SKIP(1)
    tel_flgdbaut    AT 03 LABEL "Debito autorizado"
    SKIP(1)
    WITH ROW 4 SIDE-LABELS TITLE glb_tldatela OVERLAY WIDTH 80 FRAME f_cadgps.


FORM
        tel_flgdbaut    LABEL "Debito autorizado"
                    HELP  "Informe (S)im ou (N)ao."
    tel_inpessoa    AT 34 LABEL "Tp.natureza guia"
                    HELP "Informe '1' para Fisica ou '2' para Juridica."
    tel_dspessoa
    SKIP(1)
    tel_nrctadeb    LABEL "Conta/dv para debito"
                    HELP  "Informe o numero da conta para o debito."
    tel_nmctadeb    LABEL "Titular"
    SKIP(1)
    tel_vlrdinss    LABEL "Valor INSS"   FORMAT "zz,zzz,zz9.99"
                    HELP  "Informe o valor base do INSS."
    SKIP
    tel_vloutent    LABEL "Valor outras entidades"
                    HELP  "Informe o valor de outras entidades."
    SKIP
    tel_vlrjuros    LABEL "Valor ATM/Juros/Multa"
                    HELP  "Informe o valor da ATM, juros ou multa."
    SKIP
    tel_vlrtotal    LABEL "Valor total"
    WITH   OVERLAY  SIDE-LABELS ROW 10 CENTERED  WIDTH  74
           NO-LABEL FRAME f_debito.


/* Inclusão de CEP integrado. (André - DB1) */
ON  GO, LEAVE OF tel_nrcepend IN FRAME f_cadgps DO:
    IF  INPUT tel_nrcepend = 0  THEN
        RUN Limpa_Endereco.
END.

ON  RETURN OF tel_nrcepend IN FRAME f_cadgps DO:

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT tel_nrcepend.

    IF  tel_nrcepend <> 0  THEN
        DO:
            RUN fontes/zoom_endereco.p ( INPUT tel_nrcepend,
                                        OUTPUT TABLE tt-endereco ).

            FIND FIRST tt-endereco NO-LOCK NO-ERROR.

            IF  AVAIL tt-endereco THEN
                DO:
                    ASSIGN
                       tel_nrcepend = tt-endereco.nrcepend
                       tel_dsendres = tt-endereco.dsendere
                       tel_nmbairro = tt-endereco.nmbairro
                       tel_nmcidade = tt-endereco.nmcidade
                       tel_cdufresd = tt-endereco.cdufende.
                END.
            ELSE
                DO:
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        RETURN NO-APPLY.

                    MESSAGE "CEP nao cadastrado.".
                    RUN Limpa_Endereco.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
        RUN Limpa_Endereco.

    DISPLAY tel_nrcepend
            tel_dsendres
            tel_nmbairro
            tel_nmcidade
            tel_cdufresd WITH FRAME f_cadgps.

    NEXT-PROMPT tel_nrendres WITH FRAME f_cadgps.

END.


ON  LEAVE OF tel_cdidenti IN FRAME f_cadgps DO:

    IF  glb_cddopcao <> "I" THEN
        DO:
            ASSIGN INPUT tel_cdidenti.

            RUN busca-identif.
        END.
END.


ON  LEAVE OF tel_nrctadeb IN FRAME f_debito DO:

    ASSIGN INPUT tel_nrctadeb.

    RUN busca-pagto-nome IN h-b1wgen0093
        ( INPUT glb_cdcooper,
          INPUT tel_cdidenti,
          INPUT tel_nrctadeb,
         OUTPUT aux_nmprimtl ).

    IF  aux_nmprimtl <> "" THEN
        DO:
            ASSIGN tel_nmctadeb = aux_nmprimtl.
            DISPLAY tel_nmctadeb WITH FRAME f_debito.
        END.
END.

ON  LEAVE OF tel_inpessoa IN FRAME  f_debito DO:

    IF  INPUT tel_inpessoa = 1 THEN
        tel_dspessoa = "- Fisica".
    ELSE
    IF  INPUT tel_inpessoa = 2 THEN
        tel_dspessoa = "- Juridica".

    DISPLAY tel_dspessoa WITH FRAME f_debito.

END.

ASSIGN tel_flgrgatv = YES
       tel_flgdbaut = NO
       glb_cddopcao = "C".

IF  NOT VALID-HANDLE(h-b1wgen0093)  THEN
    RUN sistema/generico/procedures/b1wgen0093.p
        PERSISTENT SET h-b1wgen0093.

RUN fontes/inicia.p.

Inicio: DO WHILE TRUE ON ENDKEY UNDO Inicio, LEAVE Inicio:

    DISPLAY glb_cddopcao WITH FRAME f_cadgps.

    NEXT-PROMPT tel_cdidenti WITH FRAME f_cadgps.

    Identif: DO WHILE TRUE ON ENDKEY UNDO Identif, LEAVE Identif:

        UPDATE  glb_cddopcao WITH FRAME f_cadgps

        EDITING:
            READKEY.
            APPLY LASTKEY.

            IF  GO-PENDING  THEN
                DO:
                    ASSIGN INPUT glb_cddopcao.

                    RUN valida-autori-deb IN h-b1wgen0093
                        ( INPUT glb_cdcooper,
                          INPUT 0,           
                          INPUT 0,           
                          INPUT tel_nrctadeb,
                          INPUT tel_cdidenti,
                          INPUT tel_inpessoa,
                          INPUT glb_cddopcao,
                          INPUT "DEBITO",
                         OUTPUT aux_nmdcampo,
                         OUTPUT TABLE tt-erro ).
            
                    IF  RETURN-VALUE <> "OK" THEN
                        DO:
                            FIND FIRST tt-erro NO-ERROR.
            
                            IF  AVAILABLE tt-erro THEN
                                DO:
                                    MESSAGE tt-erro.dscritic.
                                    {sistema/generico/includes/foco_campo.i
                                        &VAR-GERAL="sim"
                                        &NOME-FRAME="f_cadgps"
                                        &NOME-CAMPO=aux_nmdcampo }
                                END.
                        END.
                END.

        END.

        UPDATE tel_cdidenti WITH FRAME f_cadgps.

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
            NEXT Inicio.

        LEAVE Identif.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "CADGPS"   THEN
                DO:
                    HIDE FRAME f_cadgps.
                    RETURN.
                END.
            ELSE
                NEXT Inicio.
        END.

    IF  aux_cddopcao <> INPUT glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

    IF  glb_cddopcao = "D" THEN
        DO:
            RUN identificador.
            IF  RETURN-VALUE <> "OK"  THEN
                NEXT.

            RUN carrega_guia.
            IF  RETURN-VALUE <> "OK" THEN
                NEXT.

            PAUSE 0.

            RUN carrega_debito.
            IF  RETURN-VALUE <> "OK" THEN
                NEXT.

            HIDE FRAME f_debito. /* Evita o problema do uso da tecla END */

            UPDATE tel_flgdbaut WITH FRAME f_debito.
            
            IF  aux_msgretor <> "" THEN
                DO:
                    MESSAGE aux_msgretor.
                    NEXT.
                END.

            IF  tel_flgdbaut = YES THEN
                DO:
                    DO  WHILE TRUE:

                        UPDATE tel_inpessoa
                               tel_nrctadeb WITH FRAME f_debito

                        EDITING:
                            READKEY.
                            APPLY LASTKEY.

                            IF  GO-PENDING  THEN
                                DO:
                                    ASSIGN INPUT tel_inpessoa
                                           INPUT tel_nrctadeb.

                                    RUN valida-autori-deb IN h-b1wgen0093
                                        ( INPUT glb_cdcooper,
                                          INPUT 0,           
                                          INPUT 0,           
                                          INPUT tel_nrctadeb,
                                          INPUT tel_cdidenti,
                                          INPUT tel_inpessoa,
                                          INPUT glb_cddopcao,
                                          INPUT "AUTORI",
                                         OUTPUT aux_nmdcampo,
                                         OUTPUT TABLE tt-erro ).

                                    IF  RETURN-VALUE <> "OK" THEN
                                        DO:
                                            FIND FIRST tt-erro NO-ERROR.
                            
                                            IF  AVAILABLE tt-erro THEN
                                                DO:
                                                    MESSAGE tt-erro.dscritic.
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_debito"
                                            &NOME-CAMPO=aux_nmdcampo }
                                                END.
                                        END.
                                END.
                        END.

                        UPDATE tel_vlrdinss
                               tel_vloutent
                               tel_vlrjuros WITH FRAME f_debito
                        EDITING:
                            READKEY.
                            APPLY LASTKEY.

                            IF  GO-PENDING  THEN
                                DO:
                                    RUN valida-valores.
                                    IF  RETURN-VALUE <> "OK" THEN
                                        DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_debito"
                                            &NOME-CAMPO=aux_nmdcampo }
                                        END.
                                END.
                        END.

                        LEAVE.
                    END.  /** Fim do while true **/
                END.
            ELSE
                DO:
                    ASSIGN  tel_inpessoa = 0
                            tel_dspessoa = ""
                            tel_nrctadeb = 0
                            tel_nmctadeb = ""
                            tel_vlrdinss = 0
                            tel_vloutent = 0
                            tel_vlrjuros = 0
                            tel_vlrtotal = 0.

                    DISPLAY tel_inpessoa tel_dspessoa
                            tel_nrctadeb tel_nmctadeb
                            tel_vlrdinss tel_vloutent
                            tel_vlrjuros tel_vlrtotal
                            WITH FRAME f_debito.
                END.

            RUN  confirma.
            IF  aux_confirma = "S"   THEN
                DO:
                    RUN grava-dados.

                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT.

                END.

        END.   /*** Fim opcao "D" ***/
   ELSE
   IF   glb_cddopcao = "I" THEN
        DO:
                        RUN limpa_tela("").

            ASSIGN aux_posvalid = 1.
            RUN valida-ins.
            IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    NEXT-PROMPT tel_cdidenti WITH FRAME f_cadgps.
                    NEXT.
                END.

            ASSIGN tel_cddpagto:HELP = "Informe o codigo de pagamento.".

            UPDATE tel_cddpagto WITH FRAME f_cadgps.

            RUN valida-identificador IN h-b1wgen0093
                ( INPUT glb_cdcooper,
                  INPUT 0,
                  INPUT 0,
                  INPUT tel_cdidenti,
                  INPUT tel_cddpagto,
                 OUTPUT aux_nmdcampo,
                 OUTPUT TABLE tt-erro ).

            IF  RETURN-VALUE = "OK"  THEN
                DO:
                    ASSIGN aux_posvalid = 3.
                    RUN valida-ins.

                    IF  RETURN-VALUE <> "OK" THEN 
                        DO:
                            RUN limpa_tela("BUSCA").
                            NEXT.
                        END.
                END.
                    
            IF  RETURN-VALUE <> "OK" OR 
                TEMP-TABLE tt-erro:HAS-RECORDS THEN
                DO:
                    FIND FIRST tt-erro NO-ERROR.
        
                    IF  AVAILABLE tt-erro THEN 
                        DO:
                            MESSAGE tt-erro.dscritic.
                            RUN limpa_tela("BUSCA").
                            NEXT.
                        END.
                END.

            DO  WHILE TRUE:
          
                UPDATE tel_tpcontri tel_nrdconta WITH FRAME f_cadgps.
          
                RUN verifica-titular.
          
                RUN busca-assoc IN h-b1wgen0093
                    ( INPUT glb_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT tel_nrdconta,
                      INPUT tel_idseqttl,
                      INPUT tel_cdidenti,
                      INPUT tel_cddpagto,
                      INPUT glb_cddopcao,
                      INPUT TRUE,
                     OUTPUT aux_flgexass,
                     OUTPUT aux_msgretor,
                     OUTPUT TABLE tt-erro,
                     OUTPUT TABLE tt-cadgps ).
          
                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        IF  AVAIL tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                            END.
                        NEXT.
                    END.
          
                FIND FIRST tt-cadgps NO-LOCK NO-ERROR.
          
                IF  AVAIL tt-cadgps THEN
                    ASSIGN tel_nmextttl = tt-cadgps.nmextttl
                           tel_nrcpfcgc = tt-cadgps.nrcpfcgc
                           tel_dsendres = tt-cadgps.dsendres
                           tel_nmbairro = tt-cadgps.nmbairro
                           tel_nmcidade = tt-cadgps.nmcidade
                           tel_nrcepend = tt-cadgps.nrcepend
                           tel_cdufresd = tt-cadgps.cdufresd
                           tel_nrfonres = tt-cadgps.nrfonres.
          
                IF  aux_flgexass THEN
                    DO:
                        IF  aux_msgretor <> "" THEN
                            DO:
                                MESSAGE aux_msgretor.
                                NEXT.
                            END.
          
                        DISPLAY tel_nmextttl tel_nrcpfcgc
                                tel_dsendres tel_nmcidade tel_nmbairro
                                tel_nrcepend tel_cdufresd tel_nrfonres
                                tel_nrendres tel_complend tel_nrcxapst
                                WITH FRAME f_cadgps.
          
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                            LEAVE.
                    END.
                ELSE
                IF  tel_nrdconta = 0  THEN
                    DO  WHILE TRUE ON ENDKEY UNDO,LEAVE:
          
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                            LEAVE.
          
                        UPDATE tel_nmextttl tel_nrcpfcgc tel_nrcepend
                               tel_nrendres tel_complend tel_nrcxapst
                               tel_nrfonres WITH FRAME f_cadgps
          
                        EDITING:
          
                            READKEY.
          
                            IF  FRAME-FIELD = "tel_nrcepend" THEN
                                DO:
                                    IF  LASTKEY = KEYCODE("F7") THEN
                                        DO:
                                /* Inclusão de CEP integrado. (André - DB1) */
                                            RUN fontes/zoom_endereco.p
                                                ( INPUT 0,
                                                 OUTPUT TABLE tt-endereco ).
          
                                            FIND FIRST tt-endereco
                                                              NO-LOCK NO-ERROR.
          
                                            IF  AVAIL tt-endereco THEN
                                                DO:
          
                                                    ASSIGN
                                                        tel_nrcepend =
                                                          tt-endereco.nrcepend
                                                        tel_dsendres =
                                                          tt-endereco.dsendere
                                                        tel_nmbairro =
                                                          tt-endereco.nmbairro
                                                        tel_nmcidade =
                                                          tt-endereco.nmcidade
                                                        tel_cdufresd =
                                                          tt-endereco.cdufende.
          
                                                    DISPLAY tel_nrcepend
                                                            tel_dsendres
                                                            tel_nmbairro
                                                            tel_nmcidade
                                                            tel_cdufresd
                                                           WITH FRAME f_cadgps.
          
                                                    IF  KEYFUNCTION(LASTKEY)
                                                        <> "END-ERROR" THEN
                                                        NEXT-PROMPT tel_nrendres
                                                            WITH FRAME f_cadgps.
                                                END.
                                        END.
                                    ELSE
                                        APPLY LASTKEY.
                                END.
                            ELSE
                                APPLY LASTKEY.
          
                            IF  GO-PENDING  THEN
                                DO:
                                    ASSIGN INPUT tel_nrcepend
                                           INPUT tel_dsendres
                                           INPUT tel_nmbairro
                                           INPUT tel_nmcidade
                                           INPUT tel_cdufresd
                                           INPUT tel_nrdconta
                                           INPUT tel_nrcpfcgc.
          
                                    RUN valida-dados IN h-b1wgen0093
                                        ( INPUT glb_cdcooper,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT tel_nrdconta,
                                          INPUT tel_nrcpfcgc,
                                          INPUT tel_nrcepend,
                                          INPUT tel_dsendres,
                                          INPUT tel_nmbairro,
                                          INPUT tel_nmcidade,
                                          INPUT tel_cdufresd,
                                         OUTPUT aux_nmdcampo,
                                         OUTPUT TABLE tt-erro ).
          
                                    IF  RETURN-VALUE = "NOK" THEN
                                        DO:
                                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                            IF  AVAIL tt-erro THEN
                                                DO:
                                                    MESSAGE tt-erro.dscritic.
          
                                          {sistema/generico/includes/foco_campo.i
                                              &NOME-FRAME="f_cadgps"
                                              &NOME-CAMPO=aux_nmdcampo }
                                                END.
                                        END.
                                END.
                        END. /* Fim do Editing */
                        LEAVE.
                    END.
                ELSE
                    DO:
                        MESSAGE aux_msgretor.
                        NEXT.
                    END.
          
                IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"    THEN
                    LEAVE.
          
                RUN  confirma.
                IF  aux_confirma = "S"   THEN
                    DO:
                        RUN grava-dados.
          
                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        RUN limpa_tela("BUSCA").
          
                        LEAVE.
                    END.
          
                RUN limpa_tela("BUSCA").
          
                LEAVE.
            END.

        END.  /* Fim da opcao "I"   **/
    ELSE
        DO:
            RUN identificador.
            IF  RETURN-VALUE <> "OK"  THEN
                NEXT.

            RUN carrega_guia.
            IF  RETURN-VALUE <> "OK" THEN
                NEXT.

             /*** Mostra tela de Debito Automatico ***/
            IF  glb_cddopcao = "C" THEN
                IF  tel_flgdbaut = TRUE   THEN
                    DO:
                        RUN carrega_debito.
                        HIDE FRAME f_debito.
                    END.

            IF  glb_cddopcao = "A"  AND
                glb_cdcritic = 0    THEN
                RUN proc_alterar.
        END.
 
    IF  glb_cdcritic <> 0   THEN
        DO:
            RUN fontes/critic.p.
            MESSAGE glb_dscritic.
            BELL.
            glb_cdcritic = 0.
        END.

END.  /*  Fim do DO WHILE TRUE  */

IF  VALID-HANDLE(h-b1wgen0093)  THEN
    DELETE PROCEDURE h-b1wgen0093.

/* ......................................................................... */

PROCEDURE proc_alterar:

    DO  WHILE TRUE ON ENDKEY UNDO,LEAVE:

        UPDATE tel_tpcontri  tel_nrdconta  WITH FRAME f_cadgps.
        
        RUN verifica-titular.
        
        EMPTY TEMP-TABLE tt-cadgps.
        
        RUN busca-assoc IN h-b1wgen0093
            ( INPUT glb_cdcooper,
              INPUT 0,
              INPUT 0,
              INPUT tel_nrdconta,
              INPUT tel_idseqttl,
              INPUT tel_cdidenti,
              INPUT tel_cddpagto,
              INPUT glb_cddopcao,
              INPUT TRUE,
             OUTPUT aux_flgexass,
             OUTPUT aux_msgretor,
             OUTPUT TABLE tt-erro,
             OUTPUT TABLE tt-cadgps ).
    
        IF  RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF  AVAIL tt-erro  THEN
                    DO:
                        MESSAGE tt-erro.dscritic.
                    END.
                NEXT. 
            END.
        LEAVE.
    END.

    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"    THEN
        RUN limpa_tela("BUSCA").

    FIND FIRST tt-cadgps NO-LOCK NO-ERROR.

    IF  AVAIL tt-cadgps THEN
        ASSIGN tel_nmextttl = tt-cadgps.nmextttl
               tel_nrcpfcgc = tt-cadgps.nrcpfcgc
               tel_dsendres = tt-cadgps.dsendres
               tel_nmbairro = tt-cadgps.nmbairro
               tel_nmcidade = tt-cadgps.nmcidade
               tel_nrcepend = tt-cadgps.nrcepend
               tel_cdufresd = tt-cadgps.cdufresd
               tel_nrendres = tt-cadgps.nrendres
               tel_complend = tt-cadgps.complend
               tel_nrcxapst = tt-cadgps.nrcxapst.
               tel_nrfonres = tt-cadgps.nrfonres.

    IF  aux_flgexass  THEN
        DO:
            IF  aux_msgretor <> "" THEN
                DO:
                    MESSAGE aux_msgretor.
                    LEAVE.
                END.

            DISPLAY tel_nrdconta tel_nmextttl tel_nrcpfcgc
                    tel_dsendres tel_nmcidade tel_nmbairro
                    tel_nrcepend tel_cdufresd tel_nrfonres
                    tel_nrendres tel_complend tel_nrcxapst
                    WITH FRAME f_cadgps.

            DO WHILE TRUE:

                UPDATE tel_flgrgatv WITH FRAME f_cadgps

                EDITING:
                    READKEY.
                    APPLY LASTKEY.

                    IF  GO-PENDING  THEN
                        DO:
                            ASSIGN INPUT tel_flgrgatv.

                            IF tel_flgrgatv THEN
                                DO:
                                    ASSIGN aux_posvalid = 2.
        
                                    RUN valida-ins.
                                    IF  RETURN-VALUE <> "OK" THEN
                                        DO:
                                        {sistema/generico/includes/foco_campo.i
                                              &NOME-FRAME="f_cadgps"
                                              &NOME-CAMPO=aux_nmdcampo }
                                        END.
                                END.
                        END.
                END.
                LEAVE.
            END.

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                LEAVE.

        END.
    ELSE
    IF  tel_nrdconta = 0   THEN
        DO:
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                LEAVE.

            ASSIGN  tel_idseqttl = 0.

            DISPLAY tel_idseqttl WITH FRAME f_cadgps.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_nmextttl tel_nrcpfcgc tel_nrcepend
                       tel_nrendres tel_complend tel_nrcxapst
                       tel_nrfonres tel_flgrgatv WITH FRAME f_cadgps

                EDITING:

                    READKEY.

                    IF  FRAME-FIELD = "tel_nrcepend" THEN
                        DO:
                            IF  LASTKEY = KEYCODE("F7") THEN
                                DO:
                                /* Inclusão de CEP integrado. (André - DB1) */
                                    RUN fontes/zoom_endereco.p
                                        ( INPUT 0,
                                         OUTPUT TABLE tt-endereco ).

                                    FIND FIRST tt-endereco NO-LOCK NO-ERROR.

                                    IF  AVAIL tt-endereco THEN
                                        DO:

                                            ASSIGN tel_nrcepend =
                                                        tt-endereco.nrcepend
                                                   tel_dsendres =
                                                        tt-endereco.dsendere
                                                   tel_nmbairro =
                                                        tt-endereco.nmbairro
                                                   tel_nmcidade =
                                                        tt-endereco.nmcidade
                                                   tel_cdufresd =
                                                        tt-endereco.cdufende.

                                            DISPLAY tel_nrcepend
                                                    tel_dsendres
                                                    tel_nmbairro
                                                    tel_nmcidade
                                                    tel_cdufresd
                                                    WITH FRAME f_cadgps.

                                            IF  KEYFUNCTION(LASTKEY)
                                                <> "END-ERROR" THEN
                                                NEXT-PROMPT tel_nrendres
                                                     WITH FRAME f_cadgps.
                                        END.
                                END.
                            ELSE
                                APPLY LASTKEY.
                        END.
                    ELSE
                        APPLY LASTKEY.

                    IF  GO-PENDING  THEN
                        DO:
                            ASSIGN INPUT tel_nrcepend
                                   INPUT tel_dsendres
                                   INPUT tel_nmbairro
                                   INPUT tel_nmcidade
                                   INPUT tel_cdufresd
                                   INPUT tel_nrdconta
                                   INPUT tel_nrcpfcgc.

                            RUN valida-dados IN h-b1wgen0093
                                ( INPUT glb_cdcooper,
                                  INPUT 0,
                                  INPUT 0,
                                  INPUT tel_nrdconta,
                                  INPUT tel_nrcpfcgc,
                                  INPUT tel_nrcepend,
                                  INPUT tel_dsendres,
                                  INPUT tel_nmbairro,
                                  INPUT tel_nmcidade,
                                  INPUT tel_cdufresd,
                                 OUTPUT aux_nmdcampo,
                                 OUTPUT TABLE tt-erro ).

                            IF  RETURN-VALUE = "OK" THEN
                                DO:
                                    IF  tel_flgrgatv THEN
                                        DO:
                                            ASSIGN aux_posvalid = 2.
                                            RUN valida-ins.
                                            EMPTY TEMP-TABLE tt-erro.
                                        END.
                                END.

                            IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                    IF  AVAIL tt-erro THEN
                                        MESSAGE tt-erro.dscritic.
                                        
                                    {sistema/generico/includes/foco_campo.i
                                        &NOME-FRAME="f_cadgps"
                                        &NOME-CAMPO=aux_nmdcampo }
                                END.
                        END.
                END. /* Fim do Editing */
                
                LEAVE.
            END. /* Fim do DO WHILE TRUE */
        END.
    ELSE
        DO:
            MESSAGE aux_msgretor.
            LEAVE.
        END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        LEAVE.

    RUN confirma.
    IF  aux_confirma = "S"  THEN
        DO:
            RUN grava-dados.

            IF  RETURN-VALUE <> "OK" THEN
                NEXT.

        END.

    RUN limpa_tela("BUSCA").

END PROCEDURE.


PROCEDURE confirma:

    /* Confirma */
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        ASSIGN aux_confirma = "N"
               glb_cdcritic = 78.
        RUN fontes/critic.p.
        ASSIGN glb_cdcritic = 0.
        BELL.
        MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
        LEAVE.
    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR  aux_confirma <> "S" THEN
        DO:
            ASSIGN glb_cdcritic = 79.
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 1 NO-MESSAGE.
            CLEAR FRAME f_cadgps.
        END. /* Mensagem de confirmacao */

END PROCEDURE.


PROCEDURE limpa_tela:
    
    DEFINE INPUT PARAM aux_posvalid AS CHAR                            NO-UNDO.

    IF  aux_posvalid = "BUSCA" THEN
        ASSIGN tel_cdidenti = 0.

    ASSIGN  tel_nrdconta = 0
            tel_cddpagto = 0
            tel_tpcontri = 1
            tel_nmextttl = ""
            tel_idseqttl = 0
            tel_nrcpfcgc = 0
            tel_dsendres = ""
            tel_nmcidade = ""
            tel_nmbairro = ""
            tel_nrcepend = 0
            tel_cdufresd = ""
            tel_nrendres = 0
            tel_complend = ""
            tel_nrcxapst = 0
            tel_nrfonres = ""
            tel_flgrgatv = YES
            tel_flgdbaut = NO.

    DISPLAY tel_cdidenti tel_nrdconta tel_cddpagto tel_tpcontri tel_idseqttl
            tel_nmextttl tel_nrcpfcgc tel_dsendres
            tel_nmcidade tel_nmbairro tel_nrcepend tel_cdufresd
            tel_nrfonres tel_flgrgatv tel_flgdbaut
            tel_nrendres tel_complend tel_nrcxapst
            WITH FRAME f_cadgps.

END PROCEDURE.


PROCEDURE verifica-titular:

    ASSIGN aux_posvalid = 4.
    RUN valida-ins.

    IF  aux_flgconti = TRUE THEN
        IF  tel_nrdconta <> 0 AND aux_inpessoa <> 2 THEN
            DO:
                UPDATE tel_idseqttl WITH FRAME f_cadgps.

                IF  tel_idseqttl = 0 THEN
                    DO:

                        ASSIGN  shr_nrdconta = INPUT FRAME f_cadgps
                                               tel_nrdconta
                                shr_idseqttl = INPUT FRAME f_cadgps
                                               tel_idseqttl.

                        RUN fontes/zoom_seq_titulares.p (INPUT glb_cdcooper).

                        IF   shr_idseqttl <> 0 THEN
                            DO:
                                ASSIGN tel_idseqttl = shr_idseqttl.
                                DISPLAY tel_idseqttl WITH FRAME f_cadgps.
                                NEXT-PROMPT tel_idseqttl WITH FRAME f_cadgps.
                            END.
                    END.
            END.
        ELSE
            DO:
                ASSIGN  tel_idseqttl = 0.
                DISPLAY tel_idseqttl WITH FRAME f_cadgps.
            END.

END PROCEDURE.


PROCEDURE carrega_debito:

    RUN busca-deb IN h-b1wgen0093
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT tel_nrdconta,
          INPUT tel_cdidenti,
          INPUT tel_cddpagto,
         OUTPUT aux_msgretor,
         OUTPUT TABLE tt-erro,
         OUTPUT TABLE tt-cadgps ).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RUN limpa_tela("").
                END.
            RETURN "NOK".
        END.

    FIND FIRST tt-cadgps NO-LOCK NO-ERROR.

    IF  AVAIL tt-cadgps THEN
        ASSIGN tel_inpessoa = tt-cadgps.inpessoa
               tel_flgdbaut = tt-cadgps.flgdbaut
               tel_nrctadeb = tt-cadgps.nrctadeb
               tel_vlrdinss = tt-cadgps.vlrdinss
               tel_vloutent = tt-cadgps.vloutent
               tel_vlrjuros = tt-cadgps.vlrjuros
               tel_nmctadeb = ""
               tel_dspessoa = tt-cadgps.dspessoa
               tel_nmctadeb = tt-cadgps.nmctadeb
               tel_vlrtotal = tt-cadgps.vlrtotal.

    DISPLAY  tel_inpessoa  tel_dspessoa
             tel_flgdbaut  tel_nrctadeb
             tel_nmctadeb  tel_vlrdinss
             tel_vloutent  tel_vlrjuros
             tel_vlrtotal  WITH FRAME f_debito.

    IF  glb_cddopcao = "D" THEN
        PAUSE 0.

    RETURN "OK".

END.


PROCEDURE valida-valores:

    DO WITH FRAME f_debito:
        ASSIGN INPUT tel_vlrdinss
               INPUT tel_vloutent
               INPUT tel_vlrjuros.
    END.

    RUN valida-valores IN h-b1wgen0093
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT tel_cddpagto,
          INPUT tel_vlrdinss,
          INPUT tel_vlrjuros,
          INPUT tel_vloutent,
          INPUT glb_nmrescop,
         OUTPUT aux_nmdcampo,
         OUTPUT tel_vlrtotal,
         OUTPUT TABLE tt-erro ).

    DISPLAY tel_vlrtotal WITH FRAME f_debito.

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                END.
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE identificador:

    RUN valida-identificador IN h-b1wgen0093
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT tel_cdidenti,
          INPUT tel_cddpagto,
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-erro ).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE carrega_guia:
    EMPTY TEMP-TABLE tt-cadgps.

    RUN busca-assoc IN h-b1wgen0093
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT tel_nrdconta,
          INPUT tel_idseqttl,
          INPUT tel_cdidenti,
          INPUT tel_cddpagto,
          INPUT glb_cddopcao,
          INPUT FALSE,
         OUTPUT aux_flgexass,
         OUTPUT aux_msgretor,
         OUTPUT TABLE tt-erro,
         OUTPUT TABLE tt-cadgps ).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RUN limpa_tela("").
                END.
            RETURN "NOK".
        END.

    FIND FIRST tt-cadgps NO-LOCK NO-ERROR.

    IF  AVAIL tt-cadgps THEN
        DO:
            ASSIGN tel_cddpagto = tt-cadgps.cddpagto
                   tel_tpcontri = tt-cadgps.tpcontri
                   tel_nrdconta = tt-cadgps.nrdconta
                   tel_idseqttl = tt-cadgps.idseqttl
                   tel_nmextttl = tt-cadgps.nmextttl
                   tel_flgrgatv = tt-cadgps.flgrgatv
                   tel_flgdbaut = tt-cadgps.flgdbaut
                   tel_nrcpfcgc = tt-cadgps.nrcpfcgc
                   tel_dsendres = tt-cadgps.dsendres
                   tel_nmbairro = tt-cadgps.nmbairro
                   tel_nmcidade = tt-cadgps.nmcidade
                   tel_nrcepend = tt-cadgps.nrcepend
                   tel_cdufresd = tt-cadgps.cdufresd
                   tel_nrfonres = tt-cadgps.nrfonres
                   tel_nrendres = tt-cadgps.nrendres
                   tel_complend = tt-cadgps.complend
                   tel_nrcxapst = tt-cadgps.nrcxapst.
        END.

    DISPLAY tel_cdidenti tel_cddpagto tel_nrdconta tel_idseqttl
            tel_nmextttl tel_nrcpfcgc tel_dsendres
            tel_nmbairro tel_nmcidade tel_nrcepend tel_cdufresd
            tel_nrfonres tel_flgrgatv tel_flgdbaut tel_tpcontri
            tel_nrendres tel_complend tel_nrcxapst
            WITH FRAME f_cadgps.

    RETURN "OK".

END PROCEDURE. /* Fim carrega_guia */


PROCEDURE valida-ins:

    RUN valida-ins IN h-b1wgen0093
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT tel_nrdconta,
          INPUT tel_cdidenti,
          INPUT tel_cddpagto,
          INPUT aux_posvalid,
         OUTPUT aux_inpessoa,
         OUTPUT aux_flgconti,
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-erro ).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE grava-dados:

    RUN grava-dados IN h-b1wgen0093
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,          
          INPUT glb_dtmvtolt, 
          INPUT glb_cddopcao, 
          INPUT tel_cdidenti, 
          INPUT tel_cddpagto, 
          INPUT tel_inpessoa, 
          INPUT tel_vlrdinss, 
          INPUT tel_flgdbaut, 
          INPUT tel_nrctadeb, 
          INPUT tel_vloutent, 
          INPUT tel_vlrjuros, 
          INPUT tel_vlrtotal, 
          INPUT tel_tpcontri, 
          INPUT tel_flgrgatv, 
          INPUT tel_dsendres, 
          INPUT tel_nmbairro, 
          INPUT tel_nmcidade, 
          INPUT tel_nrcepend, 
          INPUT tel_cdufresd, 
          INPUT tel_nrendres, 
          INPUT tel_complend, 
          INPUT tel_nrcxapst, 
          INPUT tel_nrfonres, 
          INPUT tel_nmextttl, 
          INPUT tel_nrcpfcgc, 
         OUTPUT TABLE tt-erro ). 

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN "NOK".
                END.
        END.

    RETURN "OK".
END.

PROCEDURE Limpa_Endereco:

    ASSIGN tel_nrcepend = 0
           tel_dsendres = ""
           tel_nmbairro = ""
           tel_nmcidade = ""
           tel_cdufresd = ""
           tel_nrendres = 0
           tel_complend = ""
           tel_nrcxapst = 0.

    DISPLAY tel_nrcepend tel_dsendres tel_nmbairro tel_nmcidade
            tel_cdufresd tel_nrendres tel_complend tel_nrcxapst
            WITH FRAME f_cadgps.

END PROCEDURE.


PROCEDURE busca-identif:

    RUN fontes/zoom_guias.p
        ( INPUT glb_cdcooper,
          INPUT-OUTPUT tel_cdidenti,
         OUTPUT tel_cddpagto ).

    IF  tel_cdidenti <> 0 AND tel_cddpagto <> 0 THEN
        DISPLAY tel_cdidenti tel_cddpagto WITH FRAME f_cadgps.

    RETURN "OK".

END PROCEDURE.





