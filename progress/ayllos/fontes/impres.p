/* .............................................................................

   Programa: Fontes/impres.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Outubro/96.                        Ultima atualizacao: 11/07/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela IMPRES -- Solicitacao de extratos diversos

   Alteracoes: 20/11/96 - Alterar a mascara do campo nrctremp (Odair).

               10/03/97 - Dar critica quando for solicitado mais de um extrato
                          no dia (Odair).

               27/03/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               23/02/99 - Incluir poupanca programada (Odair)

               16/03/2000 - Tratar tipo de extrato 6 - IR pessoa juridica
                            (Deborah).

               24/04/2002 - Tratar impressao dos cheques depositados (Edson).

               07/10/2004 - Impressao Extrato Conta de Investimento(Mirtes).
               
               18/01/2005 - Impressao Extrado de Capital (Evandro).
               
               21/02/2005 - Aumentada a mascara do campo tel_nraplica(Evandro).
               
               15/04/2005 - Ajuste na consulta (Edson).

               22/06/2005 - Possibilitar pesquisa com mais de 2 meses(Mirtes).
               
               04/07/2005 - Alimentado campo cdcooper da tabela crapext (Diego).

               31/08/2005 - Alterado para digitar tbm data final do extrato 
                            quando o tipo de extrato for 1 (Diego).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               13/02/2006 - Inclusao do parametro glb_cdcooper para chamada
                            da procedure fontes/contratos.p e fontes/poupanca.p
                            fontes/aplicacoes.p - SQLWorks - Andre
                            
               28/05/2007 - Adequacao para as modalidades de aplicacao RDC
                            (Evandro).
               
               24/07/2008 - Habilitado campos "Dt.Inic." e "Dt.Final" para
                            Poupanca Programada (Elton).
            
               19/01/2009 - Incluir tipo extrato tarifas (Gabriel).      
               
               01/10/2009 - Incluir opcao para listar depositos identificados
                            no extrato de conta corrente (David).
                                   
               28/06/2010 - Ajuste na consulta da data inicial - (Vitor).             
               29/07/2010 - Inserido a opcao F7 para pesquisar os 
                            cooperados (Adriano).
                           
               16/11/2010 - Incluida a opcao "Saldo p/Resgate de Apli."
                            (Henrique).
                            
               29/08/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
               
               13/09/2012 - Considerar permissoes do usuario (Gabriel).

               24/09/2012 - Inclusao novo parametro na Valida_Opcao - BO112
                            (Guilherme/Supero)
                            
               15/10/2012 - Incluido novo parametro na Valida_Dados
                            (David Kruger).
               
               29/05/2013 - Retirar a possibilidade do usuario escolher
                            manualmente se deve tarifar ou nao flgtarif
                            (Tiago).                        
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               21/01/2015 - Inclusao do parametro aux_intpextr na chamada da funcao
                            Gera_Impressao para ser usado na pc_gera_impressao_car 
                            servindo para indicar o tipo de extrato a ser gerado.
                            (Carlos Rafael Tanholi - Projeto Captacao) 
                
               11/12/2015 - Ajuster para inclusao de novo relatorio de 
                            extrato de operacoes de credito
                            (Jonathan RKAM - M273).
                
               20/04/2016 - Incluir rm apos impressao dos documentos (Lucas Ranghetti/Rodrigo #399412 )

               11/07/2016 - M325 - Informe de Rendimentos (Guilherme/SUPERO)
                          - Novos parametros na Gera_Impressao
                          - Apenas no AyllosWeb, caracter apenas ajuste dos parametros

............................................................................. */

{ sistema/generico/includes/b1wgen0112tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_tpextrat AS INT     FORMAT "  z9"                 NO-UNDO.
DEF        VAR tel_inselext AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_nranoref AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF        VAR tel_nrctremp AS INT     FORMAT "zzzz,zz9"             NO-UNDO.
DEF        VAR tel_nraplica AS INT     FORMAT "zzzz,zz9"             NO-UNDO.
DEF        VAR tel_inrelext AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_dtrefere AS DATE    FORMAT "99/99/99"             NO-UNDO.
DEF        VAR tel_dtreffim AS DATE    FORMAT "99/99/99"             NO-UNDO.

DEF        VAR tel_flgemiss AS LOGICAL FORMAT "Agora/Proces"         NO-UNDO.
DEF        VAR tel_flgtarif AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR tel_desextra AS CHAR VIEW-AS SELECTION-LIST INNER-LINES 11
                                    INNER-CHARS 33 LIST-ITEMS 
                                    "1  - Conta Corrente",
                                    "2  - I.R fisica",
                                    "3  - Emprestimo",
                                    "4  - Aplicacao",
                                    "5  - Poupanca Programada",
                                    "6  - I.R juridica",
                                    "7  - Conta Investimento",
                                    "8  - Capital",
                                    "9  - Tarifas",
                                    "10 - Saldo p/Resgate de Apli.", 
                                    "12 - Tarifas Op. de Credito"    NO-UNDO.
DEF        VAR tel_dsrelext AS CHAR VIEW-AS SELECTION-LIST INNER-LINES 4
                                    INNER-CHARS 29 LIST-ITEMS 
                                    "1 - Somente Extrato",
                                    "2 - Cheques",
                                    "3 - Depositos Identificados",
                                    "4 - Todos"                      NO-UNDO.

DEF        VAR aux_flghaext AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgaband AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgcance AS LOGICAL                               NO-UNDO.

DEF        VAR tel_dsextrat AS CHAR    FORMAT "x(04)"                NO-UNDO.

DEF        VAR aux_contaimp AS INT     INIT 1                        NO-UNDO.

DEF        VAR aux_dtrefere AS CHAR    FORMAT "x(08)"                NO-UNDO.

DEF        VAR aux_dtreffim AS CHAR    FORMAT "x(08)"                NO-UNDO.

DEF        VAR aux2_dtrefere AS DATE                                 NO-UNDO.
DEF        VAR aux2_dtreffim AS DATE                                 NO-UNDO.

DEF        VAR aux_flgimpri AS LOGICAL                               NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqpdf AS CHAR                                  NO-UNDO.
DEF        VAR aux_msgretur AS CHAR                                  NO-UNDO.

DEF VAR h-b1wgen0001 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0112 AS HANDLE                                      NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                        NO-UNDO.
DEF VAR aux_dsextrat AS CHAR                                        NO-UNDO.
DEF VAR aux_msgretor AS CHAR                                        NO-UNDO.
DEF VAR aux_nrsequen AS INTE INIT 0                                 NO-UNDO.

DEF BUFFER btt-impres FOR tt-impres.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  5 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C, E ou I)."
                        VALIDATE(CAN-DO("C,E,I",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(1)
     "Conta/dv Tipo Dt.Inic. Dt.Final Trf Lista Sel"  AT  3
     "Contrato Aplicac. Ano  Quando?"                 AT 49
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_impres.

FORM tel_nrdconta AT  1
            HELP "Informe a conta ou <F7> para pesquisar, <F8> para imprimir."
     tel_tpextrat AT 12
            HELP "Informe o tipo de extrato ou tecle <F7> para listar."
     tel_dtrefere AT 17
            HELP "Informe a data INICIAL ou Enter para o mes corrente."
     tel_dtreffim AT 26
            HELP "Informe a data FINAL ou Enter para o mes corrente."
     tel_flgtarif AT 35
            HELP "Informe S para cobrar a tarifa ou N para isentar da tarifa."
     tel_inrelext AT 41 
            HELP "Informe o tipo de impressao ou tecle <F7> para listar."
     tel_inselext AT 46 HELP "Informe a selecao: 1 = Especifico ou 2 = Todos."
     tel_nrctremp AT 49
            HELP "Informe o numero do contrato do emprestimo, F7 para listar."
     tel_nraplica AT 58
            HELP "Informe o numero da aplicacao, F7 para listar."
     tel_nranoref AT 67

     tel_flgemiss AT 72
            HELP "Informe: A = Agora ou P = Processo."
WITH ROW 10 COLUMN 2 OVERLAY NO-BOX NO-LABELS FRAME f_lanctos.

FORM tel_nrdconta AT  1
           HELP "Informe a conta ou <F7> para pesquisar, <F8> para imprimir."
    tel_tpextrat AT 12
           HELP "Informe o tipo de extrato ou tecle <F7> para listar."
    tel_dtrefere AT 17
           HELP "Informe a data INICIAL ou Enter para o mes corrente."
    tel_dtreffim AT 26
           HELP "Informe a data FINAL ou Enter para o mes corrente."
    tel_inrelext AT 41 
           HELP "Informe o tipo de impressao ou tecle <F7> para listar."
    tel_inselext AT 46 HELP "Informe a selecao: 1 = Especifico ou 2 = Todos."
    tel_nrctremp AT 49
           HELP "Informe o numero do contrato do emprestimo, F7 para listar."
    tel_nraplica AT 58
           HELP "Informe o numero da aplicacao, F7 para listar."
    tel_nranoref AT 67

    tel_flgemiss AT 72
           HELP "Informe: A = Agora ou P = Processo."
    WITH ROW 10 COLUMN 2 OVERLAY NO-BOX NO-LABELS FRAME f_lanctos_b.


FORM tt-impres.nrdconta AT  1
     tel_dsextrat       AT 12
     tt-impres.dtrefere AT 17
     tt-impres.dtreffim AT 26
     tel_flgtarif       AT 35
     tel_inrelext       AT 41  
     tt-impres.inselext AT 46
     tt-impres.nrctremp AT 49
     tt-impres.nraplica AT 58
     tt-impres.nranoref AT 67
     tel_flgemiss       AT 72
     WITH ROW 11 COLUMN  2  OVERLAY 10 DOWN NO-LABELS NO-BOX FRAME f_work.

FORM tel_desextra NO-LABEL 
     HELP "Informe o tipo de extrato."   
     WITH ROW 9 COLUMN 18 OVERLAY NO-BOX FRAME f_dsextrat.

FORM tel_dsrelext NO-LABEL 
     HELP "Informe o tipo de impressao."   
     WITH ROW 9 COLUMN 44 OVERLAY NO-BOX FRAME f_dsrelext.

ON RETURN OF tel_desextra DO:

    tel_tpextrat = IF   SUBSTR(tel_desextra:SCREEN-VALUE,1,2) = ?   THEN
                        1
                   ELSE      
                        INTEGER(SUBSTR(tel_desextra:SCREEN-VALUE,1,2)).

    HIDE FRAME f_dsextrat.  
      
    DISPLAY tel_tpextrat WITH FRAME f_lanctos.

    APPLY "GO".     

END.

ON RETURN OF tel_dsrelext DO:

    tel_inrelext = IF   SUBSTR(tel_dsrelext:SCREEN-VALUE,1,1) = ?   THEN
                        1
                   ELSE      
                        INTEGER(SUBSTR(tel_dsrelext:SCREEN-VALUE,1,1)).

    HIDE FRAME f_dsrelext.  
      
    DISPLAY tel_inrelext WITH FRAME f_lanctos.

    APPLY "GO".     

END.

VIEW FRAME f_moldura.

PAUSE 0.

ASSIGN glb_cddopcao = "I"

       glb_cdcritic = 0.

RUN fontes/inicia.p.

DO WHILE TRUE:

    IF  NOT VALID-HANDLE(h-b1wgen0112) THEN
        RUN sistema/generico/procedures/b1wgen0112.p
            PERSISTENT SET h-b1wgen0112.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao WITH FRAME f_impres.

        { includes/acesso.i }

        ASSIGN tel_nrdconta = 0
               tel_dtrefere = ?
               tel_dtreffim = ?
               tel_nranoref = 0
               tel_nrctremp = 0
               tel_nraplica = 0
               tel_tpextrat = 0
               tel_inselext = 0
               tel_flgemiss = TRUE
               tel_flgtarif = TRUE 
               tel_inrelext = 0
               aux_flgimpri = FALSE.

        CLEAR FRAME f_lanctos ALL NO-PAUSE.
        CLEAR FRAME f_work ALL NO-PAUSE.

        IF  glb_cddopcao = "C" THEN
            DO:
                ASSIGN aux_contador = 0
                       aux_flgexist = FALSE.
                   
                RUN Busca_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                EMPTY TEMP-TABLE tt-impres.

            END. /* glb_cddopcao = "C" */
        ELSE
        IF  glb_cddopcao = "E"   THEN
            DO:
                ASSIGN aux_contador = 1.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_nrdconta  tel_tpextrat  WITH FRAME f_lanctos
                    EDITING:
                        READKEY.

                        IF  LASTKEY = KEYCODE("F7") AND
                            FRAME-FIELD = "tel_nrdconta"  THEN
                            DO: 
                                RUN fontes/zoom_associados.p 
                                    ( INPUT glb_cdcooper,
                                     OUTPUT tel_nrdconta).

                                IF  tel_nrdconta > 0 THEN
                                    DO:
                                        DISPLAY tel_nrdconta 
                                                          WITH FRAME f_lanctos.
                                        PAUSE 0.
                                        APPLY "RETURN".
                                    END.
                            END.
                        ELSE
                        IF  LASTKEY = KEYCODE("F7") AND
                            FRAME-FIELD = "tel_tpextrat"  THEN
                            DO:
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    UPDATE tel_desextra WITH FRAME f_dsextrat.
                                    LEAVE. 
                                END.

                                IF  CAN-DO("END-ERROR,GO",
                                    KEYFUNCTION(LASTKEY))   THEN
                                    HIDE FRAME f_dsextrat.
                            END.
                        ELSE
                            APPLY LASTKEY.

                        HIDE MESSAGE NO-PAUSE.

                        IF  GO-PENDING THEN
                            DO:
                                RUN Valida_Dados.

                                IF  RETURN-VALUE <> "OK" THEN
                                    DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &VAR-GERAL=SIM
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                    END.
                            END.

                    END.  /*  Fim do EDITING  */

                    IF  tel_tpextrat = 1 OR    /* CC */
                        tel_tpextrat = 7 THEN  /* CI */
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                            IF  tel_tpextrat = 1  THEN
                                DO:
                                    UPDATE tel_dtrefere tel_dtreffim
                                           tel_inrelext
                                           tel_flgemiss WITH FRAME f_lanctos

                                    EDITING:
                                        READKEY.

                                        IF  FRAME-FIELD = "tel_inrelext" THEN
                                            IF  LASTKEY = KEYCODE("F7") THEN
                                                DO:
                                                    DO WHILE TRUE 
                                                        ON ENDKEY UNDO, LEAVE:
                                                        UPDATE tel_dsrelext
                                                        WITH FRAME f_dsrelext.
                                                        LEAVE. 
                                                    END.
                                                
                                                    IF  CAN-DO("END-ERROR,GO",
                                                        KEYFUNCTION(LASTKEY)) 
                                                        THEN
                                                        HIDE FRAME f_dsrelext.
                                                END.
                                            ELSE
                                                APPLY LASTKEY.
                                        ELSE 
                                            APPLY LASTKEY.

                                        HIDE MESSAGE NO-PAUSE.

                                        IF  GO-PENDING THEN
                                            DO:
                                                RUN Valida_Opcao.

                                                IF  RETURN-VALUE <> "OK" THEN
                                                    DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                                    END.

                                                ASSIGN tel_dtrefere = 
                                                                 aux2_dtrefere
                                                       tel_dtreffim = 
                                                                 aux2_dtreffim.

                                                DISPLAY tel_dtrefere
                                                        tel_dtreffim
                                                    WITH FRAME f_lanctos.
                                                
                                            END.

                                    END. /* Fim do EDITING */
                                END.
                            ELSE
                                UPDATE tel_dtrefere tel_flgemiss
                                    WITH FRAME f_lanctos
                                EDITING:
                                    READKEY.
                                    APPLY LASTKEY.

                                    HIDE MESSAGE NO-PAUSE.

                                    IF  GO-PENDING THEN
                                        DO:
                                            RUN Valida_Opcao.
            
                                            IF  RETURN-VALUE <> "OK" THEN
                                                DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                                END.
                                        END.

                                END. /* Fim do EDITING */

                            LEAVE.
                        END.  /*  Fim do DO WHILE TRUE  */
                    ELSE
                    IF  tel_tpextrat = 2 OR
                        tel_tpextrat = 6 THEN
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                            tel_nranoref:HELP = "Informe o ano de " +
                                                "referencia do IR.".

                            UPDATE tel_nranoref tel_flgemiss
                                WITH FRAME f_lanctos
                            EDITING:
                                READKEY.
                                APPLY LASTKEY.

                                HIDE MESSAGE NO-PAUSE.

                                IF  GO-PENDING THEN
                                    DO:
                                        RUN Valida_Opcao.
        
                                        IF  RETURN-VALUE <> "OK" THEN
                                            DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                            END.
                                    END.

                            END. /* Fim do EDITING */

                            LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */

                    ELSE
                    IF  tel_tpextrat = 3 THEN
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE.
                            
                            UPDATE tel_inselext tel_nrctremp tel_flgemiss
                                WITH FRAME f_lanctos
                            EDITING:
                                READKEY.

                                IF  FRAME-FIELD = "tel_nrctremp" THEN
                                    IF  LASTKEY = KEYCODE("F7")   THEN
                                        DO:
                                            RUN fontes/zoom_emprestimos.p
                                                ( INPUT glb_cdcooper,
                                                  INPUT 0,           
                                                  INPUT 0,           
                                                  INPUT glb_cdoperad,
                                                  INPUT tel_nrdconta,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT glb_dtmvtopr,
                                                  INPUT glb_inproces,
                                                 OUTPUT tel_nrctremp ).

                                            DISPLAY tel_nrctremp 
                                                WITH FRAME f_lanctos.

                                            IF  tel_nrctremp > 0 THEN
                                                APPLY 13.
                                        END.
                                    ELSE
                                        APPLY LASTKEY.
                                ELSE
                                    APPLY LASTKEY.

                                HIDE MESSAGE NO-PAUSE.

                                IF  GO-PENDING THEN
                                    DO:
                                        RUN Valida_Opcao.
        
                                        IF  RETURN-VALUE <> "OK" THEN
                                            DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                            END.
                                    END.

                            END.  /*  Fim do EDITING  */

                            LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */
                    ELSE
                    IF  tel_tpextrat = 4 THEN
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                            UPDATE tel_inselext tel_nraplica tel_flgemiss
                                WITH FRAME f_lanctos
                            EDITING:
                                READKEY.

                                IF  FRAME-FIELD = "tel_nraplica" THEN
                                    IF  LASTKEY = KEYCODE("F7")   THEN
                                        DO:
                                            RUN fontes/zoom_aplicacoes.p
                                                ( INPUT glb_cdcooper,
                                                  INPUT 0,           
                                                  INPUT 0,           
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_nmdatela,
                                                  INPUT tel_nrdconta,
                                                 OUTPUT tel_nraplica ).

                                            DISPLAY tel_nraplica
                                                WITH FRAME f_lanctos.

                                            IF  tel_nraplica > 0 THEN
                                                APPLY 13.
                                        END.
                                    ELSE
                                        APPLY LASTKEY.
                                ELSE
                                    APPLY LASTKEY.

                                HIDE MESSAGE NO-PAUSE.

                                IF  GO-PENDING THEN
                                    DO:
                                        RUN Valida_Opcao.
        
                                        IF  RETURN-VALUE <> "OK" THEN
                                            DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                            END.
                                    END.

                            END.  /*  Fim do EDITING  */

                            LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */
                    ELSE
                    IF  tel_tpextrat = 5 THEN
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                            UPDATE tel_dtrefere tel_dtreffim 
                                   tel_inselext tel_nraplica 
                                   tel_flgemiss WITH FRAME f_lanctos

                            EDITING:
                                READKEY.

                                IF  FRAME-FIELD = "tel_nraplica" THEN
                                    IF  LASTKEY = KEYCODE("F7")   THEN
                                        DO:
                                            RUN fontes/zoom_poupanca.p
                                                ( INPUT glb_cdcooper,
                                                  INPUT 0,
                                                  INPUT 0,
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_nmdatela,
                                                  INPUT 1,
                                                  INPUT tel_nrdconta,
                                                  INPUT 1, /*idseqttl*/
                                                  INPUT glb_dtmvtolt,
                                                  INPUT glb_dtmvtopr,
                                                  INPUT glb_inproces,
                                                  INPUT glb_cdprogra,
                                                 OUTPUT tel_nraplica ).

                                            DISPLAY tel_nraplica
                                                WITH FRAME f_lanctos.

                                            IF  tel_nraplica > 0 THEN
                                                APPLY 13.
                                        END.
                                    ELSE
                                        APPLY LASTKEY.
                                ELSE
                                    APPLY LASTKEY.

                                HIDE MESSAGE NO-PAUSE.

                                IF  GO-PENDING THEN
                                    DO:
                                        RUN Valida_Opcao.
        
                                        IF  RETURN-VALUE <> "OK" THEN
                                            DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                            END.
                                    END.

                            END.  /*  Fim do EDITING  */

                            LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */

                    ELSE
                    IF  tel_tpextrat = 8 THEN  /* Capital */
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                            ASSIGN tel_flgemiss = YES  /* AGORA */
                                   tel_flgtarif = NO.  /* NAO TARIFA */

                            UPDATE tel_dtrefere WITH FRAME f_lanctos
                            EDITING:
                                READKEY.
                                APPLY LASTKEY.

                                HIDE MESSAGE NO-PAUSE.

                                IF  GO-PENDING THEN
                                    DO:
                                        RUN Valida_Opcao.
        
                                        IF  RETURN-VALUE <> "OK" THEN
                                            DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                            END.
                                    END.

                            END. /* Fim do EDITING */

                            LEAVE.

                        END.  /* fim do DO WHILE */
                    ELSE
                    IF  tel_tpextrat = 9 THEN      /* Tarifas */
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                            tel_nranoref:HELP = "Informe o ano de referencia " +
                                                "para o extrato de tarifas.".

                            UPDATE tel_nranoref tel_flgemiss 
                                WITH FRAME f_lanctos
                            EDITING:
                                READKEY.
                                APPLY LASTKEY.

                                HIDE MESSAGE NO-PAUSE.

                                IF  GO-PENDING THEN
                                    DO:
                                        RUN Valida_Opcao.
        
                                        IF  RETURN-VALUE <> "OK" THEN
                                            DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                            END.
                                    END.

                            END. /* Fim do EDITING */

                            LEAVE.

                        END. /* End DO WHILE TRUE */
                    ELSE
                    IF  tel_tpextrat = 10 THEN
                        DO:
                            RUN Valida_Opcao.

                            IF  RETURN-VALUE <> "OK" THEN
                                NEXT.
                        END.

                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                        NEXT.

                    IF  NOT tel_flgemiss THEN
                        DO:
                            RUN Grava_Dados.

                            IF  RETURN-VALUE <> "OK" THEN
                                NEXT.
                        END.

                    FOR FIRST tt-impres WHERE
                          tt-impres.flgemiss = tel_flgemiss  AND
                          tt-impres.nrdconta = tel_nrdconta  AND
                          tt-impres.dtrefere = tel_dtrefere  AND
                          tt-impres.dtreffim = tel_dtreffim  AND
                          tt-impres.nranoref = tel_nranoref  AND
                          tt-impres.nrctremp = tel_nrctremp  AND
                          tt-impres.nraplica = tel_nraplica  AND
                          tt-impres.inrelext = tel_inrelext  AND
                          tt-impres.inselext = tel_inselext  AND
                          tt-impres.tpextrat = tel_tpextrat  AND
                          tt-impres.insitext = 1             AND
                          tt-impres.inisenta = tel_flgtarif NO-LOCK: 
                    END.

                    IF  AVAIL tt-impres THEN
                        DELETE tt-impres.

                    ASSIGN aux_contaimp = aux_contaimp - 1.
                        
                    CLEAR FRAME f_lanctos ALL NO-PAUSE. 
                    
                    RUN Atualizar_Tela.

                    LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */
            END.
        ELSE
        IF  glb_cddopcao = "I"   THEN
            DO aux_contaimp = aux_contaimp TO 10 ON ENDKEY UNDO, LEAVE:
                
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    CLEAR FRAME f_lanctos NO-PAUSE.

                    ASSIGN tel_nrdconta = 0 tel_dtrefere = ? tel_dtreffim = ?
                           tel_nranoref = 0 tel_nrctremp = 0 tel_nraplica = 0
                           tel_tpextrat = 0 tel_inselext = 0 tel_flgemiss = TRUE
                           tel_flgtarif = TRUE tel_inrelext = 0.

                    UPDATE tel_nrdconta  tel_tpextrat  WITH FRAME f_lanctos
                    EDITING:
                        READKEY.
                        
                        IF  LASTKEY = KEYCODE("F8") AND 
                            FRAME-FIELD = "tel_nrdconta" THEN
                            DO:
                                { includes/impres.i }
                            END.     
                        ELSE
                        IF  LASTKEY = KEYCODE("F7") AND
                            FRAME-FIELD = "tel_nrdconta" THEN
                            DO: 
                                RUN fontes/zoom_associados.p 
                                    ( INPUT glb_cdcooper,
                                     OUTPUT tel_nrdconta).

                                IF  tel_nrdconta > 0 THEN
                                    DO:
                                        DISPLAY tel_nrdconta 
                                            WITH FRAME f_lanctos.
                                        PAUSE 0.
                                        APPLY "RETURN".
                                    END.
                            END.
                        ELSE
                        IF  FRAME-FIELD = "tel_tpextrat" THEN
                            IF  LASTKEY = KEYCODE("F7") THEN
                                DO:
                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        UPDATE tel_desextra 
                                            WITH FRAME f_dsextrat.
                                        LEAVE.
                                    END.

                                    IF  CAN-DO("END-ERROR,GO",
                                        KEYFUNCTION(LASTKEY)) THEN
                                        HIDE FRAME f_dsextrat.

                                END.
                            ELSE
                                APPLY LASTKEY.
                        ELSE
                            APPLY LASTKEY.
                        
                        HIDE MESSAGE NO-PAUSE.

                        IF  GO-PENDING THEN
                            DO:
                                RUN Valida_Dados.

                                IF  RETURN-VALUE <> "OK" THEN
                                    DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                    END.
                            END.

                        IF  aux_flgimpri THEN
                            LEAVE.

                    END.  /*  Fim do EDITING  */
                    
                    IF  aux_flgimpri THEN
                        LEAVE.

                    IF  tel_tpextrat = 1   OR    /* CC */
                        tel_tpextrat = 7 THEN    /* CI */
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE.
                            
                            IF  tel_tpextrat = 1  THEN
                                DO:
                                    ASSIGN tel_inrelext = 1.

                                    UPDATE tel_dtrefere tel_dtreffim
                                           tel_inrelext
                                           tel_flgemiss WITH FRAME f_lanctos
                                    EDITING:
                                        READKEY.

                                        IF  FRAME-FIELD = "tel_inrelext"  THEN
                                            IF  LASTKEY = KEYCODE("F7")  THEN
                                                DO:
                                                    DO WHILE TRUE 
                                                        ON ENDKEY UNDO, LEAVE:
                                                        UPDATE tel_dsrelext
                                                        WITH FRAME f_dsrelext.
                                                        LEAVE.
                                                    END.

                                                    IF  CAN-DO("END-ERROR,GO",
                                                        KEYFUNCTION(LASTKEY))
                                                        THEN
                                                        HIDE FRAME f_dsrelext.
                                                END.
                                            ELSE
                                                APPLY LASTKEY.
                                        ELSE 
                                            APPLY LASTKEY.

                                        HIDE MESSAGE NO-PAUSE.

                                        IF  GO-PENDING THEN
                                            DO:
                                                RUN Valida_Opcao.
                
                                                IF  RETURN-VALUE <> "OK" THEN
                                                    DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                                    END.

                                                ASSIGN tel_dtrefere = 
                                                                 aux2_dtrefere
                                                       tel_dtreffim = 
                                                                 aux2_dtreffim.

                                                DISPLAY tel_dtrefere
                                                        tel_dtreffim
                                                    WITH FRAME f_lanctos.
                                            END.

                                    END. /* Fim do EDITING */
                                END.
                            ELSE
                                UPDATE tel_dtrefere tel_flgemiss
                                    WITH FRAME f_lanctos
                                EDITING:
                                    READKEY.
                                    APPLY LASTKEY.

                                    HIDE MESSAGE NO-PAUSE.

                                    IF  GO-PENDING THEN
                                        DO:
                                            RUN Valida_Opcao.
            
                                            IF  RETURN-VALUE <> "OK" THEN
                                                DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                                END.

                                            ASSIGN tel_dtrefere = 
                                                                aux2_dtrefere.

                                            DISPLAY tel_dtrefere
                                                WITH FRAME f_lanctos.

                                        END.

                                END. /* Fim do EDITING */

                            IF  aux_msgretor <> "" THEN
                                DO:
                                    ASSIGN aux_confirma = "N".

                                    MESSAGE aux_msgretor 
                                        UPDATE aux_confirma.

                                    IF  KEYFUNCTION(LASTKEY) = 
                                        "END-ERROR" OR
                                        aux_confirma <> "S" THEN
                                        DO:
                                            ASSIGN glb_cdcritic = 79.
                                            RUN fontes/critic.p.
                                            BELL.
                                            MESSAGE glb_dscritic.
                                            ASSIGN glb_cdcritic = 0.
                                            NEXT.
                                        END.
                                END.

                            LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */
                    ELSE
                    IF  tel_tpextrat = 2 OR
                        tel_tpextrat = 6 THEN
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                            tel_nranoref:HELP = "Informe o ano de " +
                                                "referencia do IR.".

                            UPDATE tel_nranoref tel_flgemiss 
                                WITH FRAME f_lanctos
                            EDITING:
                                READKEY.
                                APPLY LASTKEY.

                                HIDE MESSAGE NO-PAUSE.

                                IF  GO-PENDING THEN
                                    DO:
                                        RUN Valida_Opcao.
        
                                        IF  RETURN-VALUE <> "OK" THEN
                                            DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                            END.
                                    END.

                            END. /* Fim do EDITING */

                            LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */
                    ELSE
                    IF  tel_tpextrat = 3 THEN
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                            UPDATE tel_inselext tel_nrctremp tel_flgemiss
                                WITH FRAME f_lanctos
                            EDITING:
                                READKEY.

                                IF  FRAME-FIELD = "tel_nrctremp" THEN
                                    IF  LASTKEY = KEYCODE("F7")   THEN
                                        DO:
                                            RUN fontes/zoom_emprestimos.p 
                                                ( INPUT glb_cdcooper,
                                                  INPUT 0,           
                                                  INPUT 0,           
                                                  INPUT glb_cdoperad,
                                                  INPUT tel_nrdconta,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT glb_dtmvtopr,
                                                  INPUT glb_inproces,
                                                 OUTPUT tel_nrctremp ).

                                            DISPLAY tel_nrctremp
                                                WITH FRAME f_lanctos.

                                            IF  tel_nrctremp > 0 THEN
                                                APPLY 13.
                                        END.
                                    ELSE
                                        APPLY LASTKEY.
                                ELSE
                                    APPLY LASTKEY.
                                
                                HIDE MESSAGE NO-PAUSE.

                                IF  GO-PENDING THEN
                                    DO:
                                        RUN Valida_Opcao.

                                        IF  RETURN-VALUE <> "OK" THEN
                                            DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                            END.
                                    END.

                            END.  /*  Fim do EDITING  */

                            LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */
                    ELSE
                    IF  tel_tpextrat = 4 THEN
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                            UPDATE tel_inselext tel_nraplica tel_flgemiss
                                WITH FRAME f_lanctos
                            EDITING:
                                READKEY.

                                IF  FRAME-FIELD = "tel_nraplica" THEN
                                    IF  LASTKEY = KEYCODE("F7") THEN
                                        DO:
                                            RUN fontes/zoom_aplicacoes.p
                                                ( INPUT glb_cdcooper,
                                                  INPUT 0,           
                                                  INPUT 0,           
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_nmdatela,
                                                  INPUT tel_nrdconta,
                                                 OUTPUT tel_nraplica ).

                                            DISPLAY tel_nraplica
                                                WITH FRAME f_lanctos.

                                            IF  tel_nraplica > 0 THEN
                                                APPLY 13.
                                        END.
                                    ELSE
                                        APPLY LASTKEY.
                                ELSE
                                    APPLY LASTKEY.

                                HIDE MESSAGE NO-PAUSE.

                                IF  GO-PENDING THEN
                                    DO:
                                        RUN Valida_Opcao.
        
                                        IF  RETURN-VALUE <> "OK" THEN
                                            DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                            END.
                                    END.

                            END.  /*  Fim do EDITING  */

                            LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */
                    ELSE
                    IF  tel_tpextrat = 5 THEN
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                        ASSIGN tel_dtreffim = glb_dtmvtolt.

                        UPDATE tel_dtrefere tel_dtreffim
                               tel_inselext tel_nraplica 
                               tel_flgemiss WITH FRAME f_lanctos
                        EDITING:
                            READKEY.

                            IF  FRAME-FIELD = "tel_nraplica" THEN
                                IF  LASTKEY = KEYCODE("F7") THEN
                                    DO:
                                        RUN fontes/zoom_poupanca.p
                                            ( INPUT glb_cdcooper,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT glb_cdoperad,
                                              INPUT glb_nmdatela,
                                              INPUT 1,
                                              INPUT tel_nrdconta,
                                              INPUT 1, /*idseqttl*/
                                              INPUT glb_dtmvtolt,
                                              INPUT glb_dtmvtopr,
                                              INPUT glb_inproces,
                                              INPUT glb_cdprogra,
                                             OUTPUT tel_nraplica ).

                                        DISPLAY tel_nraplica
                                            WITH FRAME f_lanctos.

                                        IF  tel_nraplica > 0 THEN
                                            APPLY 13.
                                    END.
                                ELSE
                                    APPLY LASTKEY.
                            ELSE
                                APPLY LASTKEY.

                            HIDE MESSAGE NO-PAUSE.

                                IF  GO-PENDING THEN
                                    DO:
                                        RUN Valida_Opcao.
        
                                        IF  RETURN-VALUE <> "OK" THEN
                                            DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                            END.
                                    END.

                        END.  /*  Fim do EDITING  */

                       LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */
                    ELSE
                    IF  tel_tpextrat = 8 THEN  /* Capital */

                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                            ASSIGN tel_flgemiss = YES  /* AGORA */
                                   tel_flgtarif = NO.  /* NAO TARIFA */
    
                            UPDATE tel_dtrefere WITH FRAME f_lanctos
                            EDITING:
                                READKEY.
                                APPLY LASTKEY.

                                HIDE MESSAGE NO-PAUSE.

                                IF  GO-PENDING THEN
                                    DO:
                                        RUN Valida_Opcao.
        
                                        IF  RETURN-VALUE <> "OK" THEN
                                            DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &NOME-FRAME="f_lanctos"
                                            &NOME-CAMPO=aux_nmdcampo }
                                            
                                            END.

                                        ASSIGN tel_dtrefere = aux2_dtrefere.

                                        DISPLAY tel_dtrefere
                                            WITH FRAME f_lanctos.
                                    END.

                            END. /* Fim do EDITING */

                            LEAVE.

                        END.  /* fim do DO WHILE */
                    ELSE
                    IF  tel_tpextrat = 9 THEN /* Tarifas */
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                            tel_nranoref:HELP = "Informe o ano de referencia " +
                                                "para o extrato de tarifas.".

                            UPDATE tel_nranoref tel_flgemiss 
                                WITH FRAME f_lanctos
                            EDITING:
                                READKEY.
                                APPLY LASTKEY.

                                HIDE MESSAGE NO-PAUSE.

                                IF  GO-PENDING THEN
                                    DO:
                                        RUN Valida_Opcao.
        
                                        IF  RETURN-VALUE <> "OK" THEN
                                            DO:
                                    {sistema/generico/includes/foco_campo.i
                                        &NOME-FRAME="f_lanctos"
                                        &NOME-CAMPO=aux_nmdcampo }
                                            END.
                                    END.

                            END. /* Fim do EDITING */

                            LEAVE.

                        END.
                    ELSE
                    IF  tel_tpextrat = 10 THEN
                        DO:
                            RUN Valida_Opcao.

                            IF  RETURN-VALUE <> "OK" THEN
                                NEXT.
                        END.
                    ELSE
                    IF  tel_tpextrat = 12 THEN
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                               tel_nranoref:HELP = "Informe o ano de " +
                                                   "referencia.".
                          
                               UPDATE tel_nranoref
                                      WITH FRAME f_lanctos

                               EDITING:
                                   READKEY.
                                   APPLY LASTKEY.
                          
                                   HIDE MESSAGE NO-PAUSE.
                          
                                   IF  GO-PENDING THEN
                                       DO:
                                           RUN Valida_Opcao.
                                           
                                           IF  RETURN-VALUE <> "OK" THEN
                                               DO:
                                           {sistema/generico/includes/foco_campo.i
                                               &NOME-FRAME="f_lanctos"
                                               &NOME-CAMPO=aux_nmdcampo }
                                               END.
                                       END.
                          
                               END. /* Fim do EDITING */
                          
                               LEAVE.
                          
                            END.  /*  Fim do DO WHILE TRUE  */
                           
                        END.

                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                        NEXT.

                    LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    LEAVE.

                IF  aux_flgimpri THEN
                    LEAVE.

                IF  NOT tel_flgemiss THEN
                    DO:
                        RUN Grava_Dados.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.
                    END.

                CREATE tt-impres.
                ASSIGN aux_nrsequen = aux_nrsequen + 1
                       tt-impres.dtrefere = tel_dtrefere
                       tt-impres.dtreffim = tel_dtreffim
                       tt-impres.inisenta = tel_flgtarif
                       tt-impres.inrelext = tel_inrelext
                       tt-impres.inselext = tel_inselext
                       tt-impres.insitext = 1
                       tt-impres.dsextrat = aux_dsextrat
                       tt-impres.nranoref = tel_nranoref
                       tt-impres.nraplica = tel_nraplica
                       tt-impres.nrctremp = tel_nrctremp
                       tt-impres.nrdconta = tel_nrdconta
                       tt-impres.tpextrat = tel_tpextrat
                       tt-impres.flgemiss = tel_flgemiss
                       tt-impres.nrsequen = aux_nrsequen.
                
                RUN Atualizar_Tela.

                CLEAR FRAME f_lanctos NO-PAUSE.
                
            END.  /*  Fim do DO .. TO  */

        IF  aux_contaimp >= 10 AND glb_cddopcao = "I" THEN
            { includes/impres.i }

        HIDE MESSAGE NO-PAUSE.
        CLEAR FRAME f_lanctos ALL NO-PAUSE.

        IF  NOT aux_flgcance   THEN
            ASSIGN tel_nrdconta = 0
                   tel_dtrefere = ?
                   tel_dtreffim = ?
                   tel_nranoref = 0
                   tel_nrctremp = 0
                   tel_nraplica = 0
                   tel_tpextrat = 0
                   tel_inselext = 0
                   tel_flgemiss = TRUE
                   tel_flgtarif = TRUE 
                   tel_inrelext = 0.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            ASSIGN aux_flghaext = FALSE.

            FOR EACH tt-impres WHERE tt-impres.flgemiss:
                ASSIGN aux_flghaext = TRUE.
                LEAVE.
            END.

            ASSIGN aux_flgaband = FALSE.

            IF  aux_flghaext THEN
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    BELL.
                    MESSAGE "Atencao! Saindo da tela os extratos solicitados"
                            "para Agora serao cancelados!".

                    MESSAGE  COLOR NORMAL "Sair S/N ? "
                    UPDATE aux_flgaband AUTO-RETURN.
                    LEAVE.
                END.

            IF  NOT aux_flgaband AND aux_flghaext THEN
                NEXT.

            RUN fontes/novatela.p.

            IF  glb_nmdatela <> "IMPRES" THEN
                DO:

                    IF  VALID-HANDLE(h-b1wgen0112) THEN
                        DELETE OBJECT h-b1wgen0112.

                    HIDE FRAME f_impres.
                    HIDE FRAME f_impres_b.
                    HIDE FRAME f_lanctos NO-PAUSE.
                    HIDE FRAME f_work.
                    HIDE FRAME f_moldura.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

END.  /*  Fim do DO WHILE TRUE  */

IF  VALID-HANDLE(h-b1wgen0112) THEN
    DELETE OBJECT h-b1wgen0112.

/* ......................................................................... */

PROCEDURE Busca_Dados:
    
    EMPTY TEMP-TABLE tt-impres.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0112) THEN
        RUN sistema/generico/procedures/b1wgen0112.p
            PERSISTENT SET h-b1wgen0112.

    RUN Busca_Dados IN h-b1wgen0112
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT glb_cddopcao,
          INPUT tel_nrdconta,
          INPUT TRUE,
         OUTPUT TABLE tt-impres,
         OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.
    
    RUN Atualizar_Tela.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Valida_Dados:

    EMPTY TEMP-TABLE tt-erro.

    DO WITH FRAME f_lanctos:

        ASSIGN tel_nrdconta
               tel_tpextrat.
    END.

    IF  NOT VALID-HANDLE(h-b1wgen0112) THEN
        RUN sistema/generico/procedures/b1wgen0112.p
            PERSISTENT SET h-b1wgen0112.
    
    RUN Valida_Dados IN h-b1wgen0112
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT tel_nrdconta, 
          INPUT tel_tpextrat,
          INPUT glb_cddopcao,
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.
    
    RETURN "OK".

END PROCEDURE. /* Valida_Dados */

PROCEDURE Valida_Opcao:

    EMPTY TEMP-TABLE tt-erro.

    DO WITH FRAME f_lanctos:

        ASSIGN tel_nrdconta
               tel_tpextrat
               tel_dtrefere
               tel_dtreffim
               tel_flgtarif
               tel_nranoref
               tel_inselext
               tel_nrctremp
               tel_nraplica
               tel_flgemiss
               tel_inrelext.
    END.

    IF  NOT VALID-HANDLE(h-b1wgen0112) THEN
        RUN sistema/generico/procedures/b1wgen0112.p
            PERSISTENT SET h-b1wgen0112.
    
    RUN Valida_Opcao IN h-b1wgen0112
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_nrdconta,
          INPUT tel_tpextrat,
          INPUT tel_dtrefere,
          INPUT tel_dtreffim,
          INPUT tel_flgtarif,
          INPUT tel_nranoref,
          INPUT tel_inselext,
          INPUT tel_nrctremp,
          INPUT tel_nraplica,
          INPUT tel_flgemiss,
          INPUT tel_inrelext,
          INPUT 2, /* Relatorio Analitico */
          INPUT TABLE tt-impres,
         OUTPUT aux_nmdcampo,
         OUTPUT aux2_dtrefere,
         OUTPUT aux2_dtreffim,
         OUTPUT aux_dsextrat,
         OUTPUT aux_msgretor,
         OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Valida_Opcao */

PROCEDURE Grava_Dados:

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0112) THEN
        RUN sistema/generico/procedures/b1wgen0112.p
            PERSISTENT SET h-b1wgen0112.
    
    RUN Grava_Dados IN h-b1wgen0112
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_nrdconta,
          INPUT tel_tpextrat,
          INPUT tel_dtrefere,
          INPUT tel_dtreffim,
          INPUT tel_flgtarif,
          INPUT tel_nranoref,
          INPUT tel_inselext,
          INPUT tel_nrctremp,
          INPUT tel_nraplica,
          INPUT tel_flgemiss,
          INPUT tel_inrelext,
          INPUT TRUE, /* flgerlog */
         OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    IF  VALID-HANDLE(h-b1wgen0112) THEN
        DELETE OBJECT h-b1wgen0112.
    
    RETURN "OK".

END PROCEDURE. /* Grava_Dados */


PROCEDURE Imprimi_Dados:
    
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpextrat AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtrefere AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtreffim AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgtarif AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM par_inrelext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inselext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nranoref AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgrodar AS LOGICAL                        NO-UNDO.

    DEF  VAR aux_nmendter AS CHAR                                   NO-UNDO.
    DEF  VAR aux_flgescra AS LOGICAL                                NO-UNDO.
    DEF  VAR aux_dscomand AS CHAR                                   NO-UNDO.
    DEF  VAR par_flgfirst AS LOGICAL INIT TRUE                      NO-UNDO.
    DEF  VAR tel_dsimprim AS CHAR                                   NO-UNDO.
    DEF  VAR par_flgcance AS LOGICAL INIT FALSE                     NO-UNDO.
    DEF  VAR tel_dscancel AS CHAR                                   NO-UNDO.
    /* tipo de extrato (1=Simplificado, 2=Detalhado) */
    DEF  VAR aux_intpextr AS INTE INIT 2                            NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    INPUT THROUGH basename `tty` NO-ECHO.
        SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    IF  NOT VALID-HANDLE(h-b1wgen0112) THEN
        RUN sistema/generico/procedures/b1wgen0112.p
            PERSISTENT SET h-b1wgen0112.

    RUN Gera_Impressao IN h-b1wgen0112
        (INPUT glb_cdcooper, 
         INPUT glb_cdagenci, 
         INPUT 0, 
         INPUT 1, 
         INPUT glb_nmdatela, 
         INPUT glb_dtmvtolt, 
         INPUT glb_dtmvtopr, 
         INPUT glb_cdprogra, 
         INPUT glb_inproces, 
         INPUT glb_cdoperad, 
         INPUT aux_nmendter, 
         INPUT par_flgrodar, 
         INPUT par_nrdconta, 
         INPUT 1, 
         INPUT par_tpextrat, 
         INPUT par_dtrefere, 
         INPUT par_dtreffim, 
         INPUT par_flgtarif, 
         INPUT par_inrelext, 
         INPUT par_inselext, 
         INPUT par_nrctremp, 
         INPUT par_nraplica, 
         INPUT par_nranoref, 
         INPUT YES, 
         INPUT aux_intpextr,
         INPUT 0,
         INPUT 1,
        OUTPUT aux_nmarqimp, 
        OUTPUT aux_nmarqpdf, 
        OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0112) THEN
        DELETE OBJECT h-b1wgen0112.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        HIDE MESSAGE NO-PAUSE.
                        MESSAGE tt-erro.dscritic.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                    END.  
                END.
                   
            RETURN "NOK".  
        END. 

    FIND FIRST crapass NO-LOCK NO-ERROR.

    /*  Rotina de impressao  */
    { includes/impressao.i }            
    
    /* Remover o arquivo gerado para impressao */
    IF  TRIM(aux_nmarqimp) <> "" THEN                     
        UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").    
    
    IF  par_flgcance       OR 
        par_tpextrat <> 1  THEN /** Tarifa somente para extrato de C/C **/
        RETURN "OK".

    RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT SET h-b1wgen0001.

    IF  VALID-HANDLE(h-b1wgen0001)  THEN
        DO:         
            RUN gera-tarifa-extrato IN h-b1wgen0001 (INPUT glb_cdcooper, 
                                                     INPUT 0, 
                                                     INPUT 0, 
                                                     INPUT glb_cdoperad,
                                                     INPUT glb_nmdatela,
                                                     INPUT 1, 
                                                     INPUT par_nrdconta, 
                                                     INPUT 1, 
                                                     INPUT par_dtrefere, 
                                                     INPUT glb_inproces, 
                                                     INPUT TRUE,
                                                     INPUT TRUE, 
                                                     INPUT 0,
                                                     INPUT 0,
                                                     INPUT 0,
                                                    OUTPUT TABLE tt-msg-confirma,
                                                    OUTPUT TABLE tt-erro).
        
            DELETE PROCEDURE h-b1wgen0001.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAILABLE tt-erro  THEN
                        glb_dscritic = tt-erro.dscritic.
                    ELSE
                        glb_dscritic = "Nao foi possivel tarifar o extrato.".
            
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        HIDE MESSAGE NO-PAUSE.
                        MESSAGE glb_dscritic.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                    END.  
                END.
        END.

    RETURN "OK".

END PROCEDURE.
/* ......................................................................... */


PROCEDURE Atualizar_Tela:

    CLEAR FRAME f_work ALL NO-PAUSE.

    ASSIGN aux_contador = 0.
    
    FOR EACH tt-impres NO-LOCK:

        ASSIGN aux_contador = aux_contador + 1.

        IF  aux_contador > 10 THEN
            DO: 
                ASSIGN aux_contador = 1.
                PAUSE MESSAGE
                "Tecle <Entra> para continuar ou <Fim> para encerrar".
                CLEAR FRAME f_work ALL NO-PAUSE.
            END.

        ASSIGN tel_dsextrat = tt-impres.dsextrat
               tel_flgemiss = tt-impres.flgemiss
               tel_flgtarif = tt-impres.inisenta
               tel_inrelext = tt-impres.inrelext.

        DISPLAY tt-impres.nrdconta
                tel_dsextrat
                tt-impres.dtrefere WHEN tt-impres.dtrefere <> ?
                tt-impres.dtreffim WHEN tt-impres.dtreffim <> ?
                tt-impres.inselext WHEN tt-impres.inselext > 0 AND
                                        tt-impres.tpextrat > 1
                tt-impres.nrctremp WHEN tt-impres.nrctremp > 0
                tt-impres.nraplica WHEN tt-impres.nraplica > 0
                tt-impres.nranoref WHEN tt-impres.nranoref > 0
                tel_flgemiss
                tel_flgtarif       WHEN tt-impres.tpextrat = 1
                tel_inrelext       WHEN tt-impres.inrelext > 0
                WITH FRAME f_work.

        DOWN WITH FRAME f_work.

    END.  /*  Fim do FOR EACH  */

    PAUSE(0).

    RETURN.

END PROCEDURE.
