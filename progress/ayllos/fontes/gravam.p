/* ..........................................................................

   Programa: Fontes/gravam.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/SUPERO
   Data    : Agosto/2013                      Ultima atualizacao: 10/12/2015

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Processar rotinas referentes ao GRAVAMES

   Alteracoes: 06/01/2014 - Alterada critica de "015 - Agencia nao cadastrada."
                            para "962 - PA nao cadastrado". (Reinert)

               29/04/2014 - Alteracao nos parametros das procedures
                            gravames_baixa_manual e gravames_inclusao_manual
                            incluindo o ROWID da BPR para identificar correta-
                            mente a BPR
                            Na Consulta, exibir o campo Justificativa quando
                            Baixa ou Inclusao Manual. (Guilherme/SUPERO)

               13/10/2014 - Opcao "B" permitir Baixa Manual sem informar o nr
                            de Registro. (Guilherme/SUPERO)
               
               21/11/2014 - Ajuste no tamanho da variavél tel_cdagenci, onde 
                            permite aceitar 3 caracteres (FELIPE OLIVEIRA)
                            
               28/01/2015 - Adicionado novo campo crapbpr.dschnovo.
                            Adicionado opcao "J" de bloqueio juridico.
                            Adicionado campo "Bloqueado" em form do gravames.
                            Adicionado opcao "L" de Liberacao Bloqueio Jud.
                            Adicionado opcao "S" de Manut. Bens Substituidos.  
                            (Jorge/Gielow) - SD 221854            
                            
               25/03/2015 - Adicionado opcao H - Historico do contrato.
                            (Jaison/Irlan - SD: 269240)
                            
               08/05/2015 - Ajuste nas opcoes A/S para alterar apenas com 
                            retorno com critica ou quando virou contrato 
                            (crapepr). (Jaison/Gielow - SD: 283450)

               10/12/2015 - Adicionado validacoes para nao digitar caracteres
                            especiais e as letras "Q I O" no campo chassi
                            (Tiago/Gielow SD369691)
                            
               24/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).
               
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0171tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/ayllos/includes/verifica_caracter.i }

DEF STREAM str_1.
DEF STREAM str_2.

DEF        VAR tel_cddopcao AS CHAR   FORMAT "!(1)"                  NO-UNDO.

DEF        VAR tel_cdcooper AS CHAR   FORMAT "x(12)" VIEW-AS COMBO-BOX
           INNER-LINES 11  NO-UNDO.
DEF        VAR tel_nrdconta AS INT    FORMAT "zzzz,zzz,9"            NO-UNDO.
DEF        VAR tel_cdagenci AS INT    FORMAT "zzz9"                    NO-UNDO.
DEF        VAR tel_nrctrpro AS INT    FORMAT "z,zzz,zz9"             NO-UNDO.
DEF        VAR tel_nrgravam AS INT    FORMAT "zzzzzzz9"              NO-UNDO.
DEF        VAR tel_tpcancel AS LOG    FORMAT "Arquivo/Manual"        NO-UNDO.
DEF        VAR tel_dtrefere AS DATE   FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_dsjstbxa AS CHAR                                  NO-UNDO.
DEF        VAR tel_dsjstinc AS CHAR                                  NO-UNDO.
DEF        VAR tel_nrseqlot AS INT    FORMAT "zzz9"                  NO-UNDO.
DEF        VAR tel_idseqbem AS INT    FORMAT "z9"                    NO-UNDO.
DEF        VAR tel_tparquiv AS CHAR        FORMAT "x(12)"
           VIEW-AS COMBO-BOX LIST-ITEMS "INCLUSAO",
                                        "BAIXA",
                                        "CANCELAMENTO",
                                        "TODAS"       INNER-LINES 4  NO-UNDO.
DEF        VAR aux_lsseqbem AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrpospsq AS INT  /* Posicao tela PESQUISA */      NO-UNDO.
DEF        VAR aux_nrposdet AS INT  /* Posicao tela DETALHES */      NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmcooper AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR   FORMAT "!"                     NO-UNDO.
DEF        VAR aux_flgfirst AS LOGI                                  NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_qtctrepr AS INT                                   NO-UNDO.
DEF        VAR aux_qtdebens AS INT                                   NO-UNDO.

DEF        VAR aux_vltotarq AS DECI                                  NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqpdf AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nrdcaixa AS INT     FORMAT "zzz,zz9"              NO-UNDO.


DEF        VAR rel_dsmvtolt AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR rel_mmmvtolt AS CHAR    FORMAT "x(17)"  EXTENT 12
                                    INIT["DE  JANEIRO  DE","DE FEVEREIRO DE",
                                         "DE   MARCO   DE","DE   ABRIL   DE",
                                         "DE   MAIO    DE","DE   JUNHO   DE",
                                         "DE   JULHO   DE","DE   AGOSTO  DE",
                                         "DE  SETEMBRO DE","DE  OUTUBRO  DE",
                                         "DE  NOVEMBRO DE","DE  DEZEMBRO DE"]
                                                                     NO-UNDO.
/* Variaveis para impressao */
DEF        VAR tel_dsimprim AS CHAR  FORMAT "x(8)" INIT "Imprimir"   NO-UNDO.
DEF        VAR tel_dscancel AS CHAR  FORMAT "x(8)" INIT "Cancelar"   NO-UNDO.
DEF        VAR aux_flgescra AS LOGI                                  NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR par_flgrodar AS LOGI                                  NO-UNDO.
DEF        VAR par_flgfirst AS LOGI                                  NO-UNDO.
DEF        VAR par_flgcance AS LOGI                                  NO-UNDO.

DEF VAR h-b1wgen0171 AS HANDLE                                       NO-UNDO.

DEF QUERY q-contratos     FOR tt-contratos     SCROLLING.
DEF QUERY q-bens          FOR tt-bens-zoom     SCROLLING.
DEF QUERY q-qtd-bens      FOR tt-bens-gravames CACHE 0.

DEF QUERY q-contratos-historico FOR tt-contratos     SCROLLING.

DEF BROWSE b-contratos QUERY q-contratos
    DISPLAY nrctrpro   COLUMN-LABEL "Contrato"
            WITH CENTERED 6 DOWN WIDTH 18 TITLE "Contratos".

DEF BROWSE b-contratos-historico QUERY q-contratos-historico
    DISPLAY nrctrpro   COLUMN-LABEL "Contrato"
            WITH CENTERED 6 DOWN WIDTH 18 TITLE "Contratos".

DEF BROWSE b-bens      QUERY q-bens
    DISPLAY tt-bens-zoom.nrgravam   COLUMN-LABEL "GRAVAME"
            WITH CENTERED 6 DOWN WIDTH 15 TITLE "Bens Contrato".


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 3 LABEL "Opcao" AUTO-RETURN
               HELP "Informe a opcao desejada (A, B, C, G, H, I, J, L, M, R, S ou X)."
               VALIDATE(CAN-DO("A,B,C,G,H,I,J,L,M,R,S,X",glb_cddopcao),
                               "014 - Opcao errada.")                        
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_gravam_opcao.


FORM tel_nrdconta AT 1 LABEL "Conta"
                       HELP "Entre com a Conta/DV."
     tel_cdagenci      LABEL "PA"
                       HELP "Entre com o numero do PA"
                       VALIDATE(CAN-FIND(
                           crapage WHERE crapage.cdcooper = glb_cdcooper
                                     AND crapage.cdagenci = INPUT tel_cdagenci),
                                     "962 - PA nao cadastrado.")
     tel_nrctrpro      LABEL "Contrato"
                       HELP "Informe o Contrato de Emprestimo ou pressione <F7>"
     tel_nrgravam      LABEL "Nr. Regis."
                       HELP "Informe o numero de registro ou pressione <F7>"
     WITH ROW aux_nrpospsq COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_gravam_pesq.


FORM tel_tpcancel AT 1 LABEL "Tipo Cancelamento"
                       HELP "Informe o tipo de Cancelamento - Arquivo/Manual (A/M)"
     WITH ROW 6 COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_gravam_cancel.


FORM tel_cdcooper AT 02 LABEL "Cooperativa"         AUTO-RETURN
                        HELP "Selecione a Cooperativa"
     tel_tparquiv AT 33 LABEL "Tipo Arquivo"        AUTO-RETURN
                        HELP "Informe qual tipo de arquivo para gerar"
     WITH ROW aux_nrpospsq COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_gravam_geracao.

FORM tel_cdcooper AT 02 LABEL "Cooperativa"         AUTO-RETURN
                        HELP "Selecione a Cooperativa"
     tel_tparquiv AT 33 LABEL "Tipo Arquivo"        AUTO-RETURN
                        HELP "Informe qual tipo de arquivo para gerar"
     SKIP
     tel_nrseqlot AT 09 LABEL "Lote"                AUTO-RETURN
                        HELP "Informe o numero do lote"
     tel_dtrefere AT 35 LABEL "Referencia"          AUTO-RETUR
                        HELP "Informe a data de referencia de envio"
     WITH ROW aux_nrpospsq COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_gravam_impressao.

FORM tel_cdcooper AT 02 LABEL "Cooperativa"         AUTO-RETURN
                        HELP "Selecione a Cooperativa"
     SKIP
     tel_nrdconta AT 08 LABEL "Conta"               AUTO-RETURN
                        HELP "Entre com a Conta/DV."
     tel_nrctrpro AT 28 LABEL "Contrato"            AUTO-RETURN
                        HELP "Informe o Contrato de Emprestimo ou pressione <F7>"
     WITH ROW aux_nrpospsq COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_gravam_historico.


FORM SKIP
     tt-bens-gravames.dtmvtolt  AT  2 FORMAT "99/99/9999" LABEL "Data do Registro  "
     aux_lsseqbem               AT 35 FORMAT "x(10)"      NO-LABEL
     SKIP
     tt-bens-gravames.nrgravam  AT  2 FORMAT "zzzzzzz9"   LABEL "Numero de Registro"
     tt-bens-gravames.dssitgrv  AT 36 FORMAT "x(23)"      LABEL "Situacao "
     SKIP
     tt-bens-gravames.dscatbem  AT  2 FORMAT "x(14)"      LABEL "Categoria         "
     tt-bens-gravames.dsblqjud  AT 36 FORMAT "x(3)"       LABEL "Bloqueado"
     SKIP
     tt-bens-gravames.dsbemfin  AT  2 FORMAT "x(25)"      LABEL "Descricao         "
     tt-bens-gravames.dscorbem  AT  2 FORMAT "x(35)"      LABEL "Cor / Classe      "
     tt-bens-gravames.vlmerbem  AT  2 FORMAT "zzz,zzz,zz9.99"
                                                          LABEL "Valor de mercado  "
     SKIP
     tt-bens-gravames.dschassi  AT  2 FORMAT "x(20)"      LABEL "Chassi/N.Serie    "
     tt-bens-gravames.tpchassi  AT 52 FORMAT "9"          LABEL "Tipo Chassi"
                                             AUTO-RETURN
     SKIP
     tt-bens-gravames.ufdplaca  AT  2 FORMAT "x(2)"       LABEL "UF/Placa          "
                                             AUTO-RETURN
     tt-bens-gravames.nrdplaca        FORMAT "xxx-9999"   NO-LABEL
     tt-bens-gravames.uflicenc  AT 47 FORMAT "X(2)"       LABEL "UF Licenciamento"
     tt-bens-gravames.nrrenava  AT  2 FORMAT "zzz,zzz,zzz,zz9"
                                                          LABEL "RENAVAN           "
     tt-bens-gravames.nranobem  AT 39 FORMAT "z,zz9"      LABEL "Ano Fab"

     tt-bens-gravames.nrmodbem  AT 56 FORMAT "z,zz9"      LABEL "Ano Mod"
     SKIP
     tt-bens-gravames.dscpfbem  AT  2 FORMAT "X(18)"      LABEL "CPF/CNPJ Propr    "
/*      SKIP(1) */
     tt-bens-gravames.vlctrgrv  AT 41 FORMAT "z,zz9,zz9.99" LABEL "Vlr Op"
     tt-bens-gravames.dtoperac  AT 63 FORMAT "99/99/99"   LABEL "Dt Op"

     WITH ROW aux_nrposdet COLUMN 3 SIDE-LABELS OVERLAY  NO-BOX
        FRAME f_gravam_dados.


FORM SKIP
     tt-bens-gravames.dsjstbxa  AT  2 FORMAT "X(52)"
             LABEL "Justificativa da Baixa"
     SKIP
     tel_dsjstbxa               AT  2 FORMAT "X(76)"     NO-LABEL
     WITH ROW 19 COLUMN 3 SIDE-LABELS OVERLAY  NO-BOX
        FRAME f_gravam_justif_baixa.


FORM SKIP
     tt-bens-gravames.dsjstinc  AT  2 FORMAT "X(52)"  LABEL "Justificativa     "
     SKIP
     tel_dsjstinc               AT  2 FORMAT "X(76)"     NO-LABEL
     WITH ROW 19 COLUMN 3 SIDE-LABELS OVERLAY  NO-BOX
        FRAME f_gravam_justif_incl.

FORM b-contratos
    WITH NO-BOX OVERLAY ROW 7 COLUMN 44 WIDTH 18 FRAME f_contratos.

FORM b-contratos-historico
    WITH NO-BOX OVERLAY ROW 7 COLUMN 44 WIDTH 18 FRAME f_contratos_historico.

FORM b-bens
    WITH NO-BOX OVERLAY ROW 7 COLUMN 64 WIDTH 16 FRAME f_bens.


ON RETURN OF tel_cdcooper IN FRAME f_gravam_geracao DO:

    ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE.

    APPLY "GO".
END.

ON RETURN OF tel_cdcooper IN FRAME f_gravam_impressao DO:

    ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE.

    APPLY "GO".
END.

ON RETURN OF tel_cdcooper IN FRAME f_gravam_historico DO:

    ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE.

    APPLY "GO".
END.


ON RETURN OF tel_tparquiv IN FRAME f_gravam_geracao DO:

    ASSIGN tel_tparquiv = tel_tparquiv:SCREEN-VALUE.

    APPLY "GO".

END.

ON RETURN OF tel_tparquiv IN FRAME f_gravam_impressao DO:

    ASSIGN tel_tparquiv = tel_tparquiv:SCREEN-VALUE.

    APPLY "GO".

END.


ON RETURN OF b-contratos IN FRAME f_contratos
   DO:
       IF   AVAILABLE tt-contratos THEN
            DO:
                ASSIGN tel_nrctrpro = tt-contratos.nrctrpro.

                DISPLAY tel_nrctrpro WITH FRAME f_gravam_pesq.
            END.

    HIDE FRAME f_contratos.

    APPLY "GO".
END.


ON RETURN OF b-contratos-historico IN FRAME f_contratos_historico
   DO:
       IF   AVAILABLE tt-contratos THEN
            DO:
                ASSIGN tel_nrctrpro = tt-contratos.nrctrpro.

                DISPLAY tel_nrctrpro WITH FRAME f_gravam_historico.
            END.

    HIDE FRAME f_contratos_historico.

    APPLY "GO".
END.


ON RETURN OF b-bens IN FRAME f_bens
   DO:
       IF   AVAILABLE tt-bens-zoom THEN
            DO:
                ASSIGN tel_nrgravam = tt-bens-zoom.nrgravam
                       tel_idseqbem = tt-bens-zoom.idseqbem.
                
                DISPLAY tel_nrgravam WITH FRAME f_gravam_pesq.
            END.

    HIDE FRAME f_bens.

    APPLY "GO".
END.


/* Busca dados da cooperativa */
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         RETURN.
     END.


ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       .

VIEW FRAME f_moldura.
PAUSE(0).


/*************** CARREGA COOPERATIVAS ***************/
ASSIGN aux_contador = 0.

IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
    RUN sistema/generico/procedures/b1wgen0171.p
        PERSISTENT SET h-b1wgen0171.

RUN carrega-cooperativas IN h-b1wgen0171
                  ( INPUT YES,  /* Lista Coop CECRED ? */ 
                    INPUT YES,  /* Lista item TODAS  ? */ 
                   OUTPUT TABLE tt-erro,
                   OUTPUT TABLE tt-cooper).

IF  VALID-HANDLE(h-b1wgen0171) THEN
    DELETE PROCEDURE h-b1wgen0171.

IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN DO:
    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAIL tt-erro  THEN DO:
        MESSAGE tt-erro.dscritic.
        PAUSE 2 NO-MESSAGE.
        HIDE MESSAGE.
        NEXT.
    END.
END.



FOR EACH tt-cooper NO-LOCK 
   WHERE (tt-cooper.cdcooper = glb_cdcooper AND glb_cdcooper <> 3)
      OR (glb_cdcooper = 3)
    BY tt-cooper.cdcooper:

    IF   aux_contador = 0 THEN
         ASSIGN aux_nmcooper = CAPS(tt-cooper.nmrescop) + "," +
                               STRING(tt-cooper.cdcooper)
                aux_contador = 1.
    ELSE
         ASSIGN aux_nmcooper = aux_nmcooper + "," + CAPS(tt-cooper.nmrescop)
                                             + "," + STRING(tt-cooper.cdcooper)
                aux_contador = aux_contador + 1.
END.

ASSIGN tel_cdcooper:LIST-ITEM-PAIRS IN FRAME f_gravam_geracao   = aux_nmcooper .
ASSIGN tel_cdcooper:LIST-ITEM-PAIRS IN FRAME f_gravam_impressao = aux_nmcooper .
ASSIGN tel_cdcooper:LIST-ITEM-PAIRS IN FRAME f_gravam_historico = aux_nmcooper .
/*************** CARREGA COOPERATIVAS ***************/


DO WHILE TRUE:

    RUN fontes/inicia.p.

    HIDE FRAME f_contratos.
    HIDE FRAME f_contratos_historico.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IF  glb_cdcritic > 0   THEN
            DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               PAUSE 2 NO-MESSAGE.
            END.

        UPDATE glb_cddopcao  WITH FRAME f_gravam_opcao.

        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */


    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "GRAVAM"  THEN DO:

                HIDE  FRAME f_gravam_opcao.
                HIDE  FRAME f_gravam_pesq.
                HIDE  FRAME f_gravam_dados.
                HIDE  FRAME f_gravam_cancel.
                HIDE  FRAME f_gravam_impressao.
                HIDE  FRAME f_gravam_historico.
                HIDE  FRAME f_gravam_justif_baixa.
                HIDE  FRAME f_gravam_justif_incl.
                HIDE  FRAME f_moldura.
                RETURN.
             END.
             ELSE
                NEXT.
    END.


    IF   aux_cddopcao <> glb_cddopcao THEN
         DO:
             { includes/acesso.i }
             aux_cddopcao = glb_cddopcao.
    END.


    EMPTY TEMP-TABLE tt-bens-gravames.
    EMPTY TEMP-TABLE tt-bens-zoom.
    EMPTY TEMP-TABLE tt-contratos.

    ASSIGN tel_dsjstbxa = ""
           tel_dsjstinc = "".

    CASE glb_cddopcao:

        WHEN "A" THEN DO:  /*** ALTERAR ***/

            ASSIGN aux_nrpospsq = 6
                   aux_nrposdet = 8.

            RUN consulta_dados.

            FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper   AND
                               crapepr.nrdconta = tel_nrdconta   AND
                               crapepr.nrctremp = tel_nrctrpro
                               NO-LOCK NO-ERROR.

            FOR EACH tt-bens-gravames NO-LOCK
                WHERE tt-bens-gravames.tpctrpro = 90:
                ASSIGN aux_lsseqbem = "(" +
                                      STRING(tt-bens-gravames.nrseqbem,">9") +
                                      "o Bem )".

                DISP aux_lsseqbem               tt-bens-gravames.dtmvtolt
                     tt-bens-gravames.dssitgrv  tt-bens-gravames.uflicenc
                     tt-bens-gravames.nrgravam  tt-bens-gravames.dscatbem
                     tt-bens-gravames.dsbemfin  tt-bens-gravames.dscorbem
                     tt-bens-gravames.vlmerbem  tt-bens-gravames.dschassi
                     tt-bens-gravames.tpchassi  tt-bens-gravames.ufdplaca
                     tt-bens-gravames.nrdplaca  tt-bens-gravames.nrrenava
                     tt-bens-gravames.nranobem  tt-bens-gravames.nrmodbem
                     tt-bens-gravames.vlctrgrv  tt-bens-gravames.dtoperac
                     tt-bens-gravames.dscpfbem  tt-bens-gravames.dsblqjud
                     WITH FRAME f_gravam_dados.

                /* alteracoes apenas quando for situacao 
                   For contrato efetivado ou
                   3 - Proc. com critica */
                IF NOT AVAIL crapepr AND 
                   tt-bens-gravames.cdsitgrv <> 3 THEN
                DO:
                    IF  aux_qtdebens > 1 AND tel_nrgravam = 0 THEN 
                    DO:
                        IF  tt-bens-gravames.nrseqbem <> aux_qtdebens THEN DO:
                            MESSAGE " Tecle <Enter> para exibir o proximo bem...".
                            WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                            HIDE MESSAGE.
                        END.
                    END.

                    NEXT.
                     
                END.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                    UPDATE tt-bens-gravames.dschassi 
                           tt-bens-gravames.ufdplaca
                           tt-bens-gravames.nrdplaca
                           tt-bens-gravames.nrrenava
                           WITH FRAME f_gravam_dados

                    EDITING:

                       READKEY.
                        
                       IF  FRAME-FIELD = "dschassi"   THEN
                           DO:      
                                IF  NOT fn_caracteres_validos(INPUT KEYFUNCTION(LASTKEY),
                                                              INPUT "",
                                                              INPUT "") THEN
                                    NEXT.
                                ELSE
                                DO: 
                                    IF CAN-DO("AUTOMOVEL,MOTO,CAMINHAO",
                                              tt-bens-gravames.dscatbem) THEN
                                    DO:   
                                        IF LENGTH(tt-bens-gravames.dschassi) > 17 THEN
                                        DO:
                                            ASSIGN tt-bens-gravames.dschassi = 
                                                SUBSTR(tt-bens-gravames.dschassi,1,17).
                                            DISPLAY tt-bens-gravames.dschassi WITH FRAME f_alienacao.
                                        END.          

                                        IF  NOT fn_caracteres_validos(INPUT KEYFUNCTION(LASTKEY),
                                                                      INPUT "",
                                                                      INPUT "Q,I,O") THEN
                                            NEXT.
                                        ELSE
                                        DO:
                                            APPLY LASTKEY.
                                            ASSIGN tt-bens-gravames.dschassi.      
                                        END.                       
                                    END.
                                    ELSE
                                    DO:
                                        APPLY LASTKEY.
                                        ASSIGN tt-bens-gravames.dschassi.
                                    END.
                                END.
                           END.
                       ELSE
                           APPLY LASTKEY.

                    END.  /*  Fim do EDITING  */
                    
                    IF  tt-bens-gravames.dschassi = ""
                    OR  tt-bens-gravames.ufdplaca = ""
                    OR  tt-bens-gravames.nrdplaca = ""
                    OR  tt-bens-gravames.nrrenava = 0 THEN DO:
                        MESSAGE " Campos Chassi, UF, Placa e Renavam devem ser "+
                                "informados! ".
                        PAUSE 2 NO-MESSAGE.
                        HIDE MESSAGE.
                        NEXT.
                    END.
                    
                    ASSIGN aux_confirma = "N".
    
                    MESSAGE "078 - Deseja efetuar a alteracao? (S/N)"
                        UPDATE aux_confirma.
                   
                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                         aux_confirma <> "S" THEN
                         DO:
                             glb_cdcritic = 79.
                             RUN fontes/critic.p.
                             MESSAGE glb_dscritic.
                             glb_cdcritic = 0.
                             PAUSE 3 NO-MESSAGE.
                             NEXT.
                         END.


                    IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
                        RUN sistema/generico/procedures/b1wgen0171.p
                            PERSISTENT SET h-b1wgen0171.
                    
                    RUN gravames_alterar IN h-b1wgen0171
                                      ( INPUT glb_cdcooper,
                                        INPUT glb_cdoperad,
                                        INPUT tel_nrdconta,
                                        INPUT tel_nrctrpro,
                                        INPUT tt-bens-gravames.idseqbem,
                                        INPUT glb_dtmvtolt,
                                        INPUT tt-bens-gravames.dscatbem,
                                        INPUT tt-bens-gravames.dschassi,
                                        INPUT tt-bens-gravames.ufdplaca,
                                        INPUT tt-bens-gravames.nrdplaca,
                                        INPUT tt-bens-gravames.nrrenava, 
                                        INPUT tt-bens-gravames.nranobem,
                                        INPUT tt-bens-gravames.nrmodbem,
                                        INPUT tt-bens-gravames.tpctrpro,
                                        INPUT glb_cddopcao,
                                       OUTPUT TABLE tt-erro).
    
                    IF  VALID-HANDLE(h-b1wgen0171) THEN
                        DELETE PROCEDURE h-b1wgen0171.
    
                    IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                        IF  AVAIL tt-erro  THEN DO:
                            MESSAGE tt-erro.dscritic.
                            PAUSE 2 NO-MESSAGE.
                            HIDE MESSAGE.
                            NEXT.
                        END.
                    END.
                    ELSE DO:
                        MESSAGE REPLACE(REPLACE(aux_lsseqbem,"(",""),")","")
                                "atualizado com sucesso!".
                        PAUSE 2 NO-MESSAGE.
                        HIDE MESSAGE.
                    END.

                    IF  aux_qtdebens > 1
                    AND tel_nrgravam = 0 THEN DO:
                        IF  tt-bens-gravames.nrseqbem <> aux_qtdebens THEN DO:
                            MESSAGE " Tecle <Enter> para exibir o proximo bem...".
                            WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                            HIDE MESSAGE.
                        END.
                    END.
                    
                    LEAVE.

                END. /* Do while true. */
            END. /* For each */
        END.



        WHEN "B" THEN DO: /** BAIXA ***/

            ASSIGN aux_nrpospsq = 6
                   aux_nrposdet = 8.

            RUN consulta_dados.

            FOR EACH tt-bens-gravames NO-LOCK
               WHERE tt-bens-gravames.tpctrpro = 90:
/*             FIND FIRST tt-bens-gravames NO-LOCK NO-ERROR. */
                ASSIGN aux_lsseqbem = "(" +
                                      STRING(tt-bens-gravames.nrseqbem,">9") +
                                      "o Bem )".

                DISP aux_lsseqbem               tt-bens-gravames.dtmvtolt
                     tt-bens-gravames.dssitgrv  tt-bens-gravames.uflicenc
                     tt-bens-gravames.nrgravam  tt-bens-gravames.dscatbem
                     tt-bens-gravames.dsbemfin  tt-bens-gravames.dscorbem
                     tt-bens-gravames.vlmerbem  tt-bens-gravames.dschassi
                     tt-bens-gravames.tpchassi  tt-bens-gravames.ufdplaca
                     tt-bens-gravames.nrdplaca  tt-bens-gravames.nrrenava
                     tt-bens-gravames.nranobem  tt-bens-gravames.nrmodbem
                     tt-bens-gravames.vlctrgrv  tt-bens-gravames.dtoperac
                     tt-bens-gravames.dscpfbem  tt-bens-gravames.dsblqjud
                     WITH FRAME f_gravam_dados.
    
                DO WHILE TRUE:
    
                    UPDATE tt-bens-gravames.dsjstbxa
                           tel_dsjstbxa
                      WITH FRAME f_gravam_justif_baixa.
        
                    ASSIGN tt-bens-gravames.dsjstbxa =
                           tt-bens-gravames.dsjstbxa + " " + tel_dsjstbxa.
        
        
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
                       ASSIGN aux_confirma = "N".
        
                       MESSAGE "078 - Deseja efetuar baixa manual do registro " +
                               "no Gravames?? (S/N)"
                            UPDATE aux_confirma.
                       LEAVE.
        
                    END.  /*  Fim do DO WHILE TRUE  */
        
                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                         aux_confirma <> "S" THEN
                         DO:
                             glb_cdcritic = 79.
                             RUN fontes/critic.p.
                             MESSAGE glb_dscritic.
                             glb_cdcritic = 0.
                             PAUSE 3 NO-MESSAGE.
/*                              NEXT. */
                             LEAVE.
                         END.

                    IF  TRIM(tt-bens-gravames.dsjstbxa) = ""  THEN DO:
                        MESSAGE "Justificativa de Baixa deve ser informada!".
                        PAUSE 2 NO-MESSAGE.
                        HIDE MESSAGE.
                        NEXT.
                    END.        
        
                    IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
                        RUN sistema/generico/procedures/b1wgen0171.p
                            PERSISTENT SET h-b1wgen0171.
        
                    RUN gravames_baixa_manual IN h-b1wgen0171
                                      ( INPUT glb_cdcooper,
                                        INPUT tel_nrdconta,
                                        INPUT tel_nrctrpro,
                                        INPUT tt-bens-gravames.rowidbpr,
                                        INPUT tt-bens-gravames.nrgravam,
                                        INPUT glb_dtmvtolt,
                                        INPUT tt-bens-gravames.dsjstbxa,
                                        INPUT glb_cddopcao,
                                       OUTPUT TABLE tt-erro).
        
                    IF  VALID-HANDLE(h-b1wgen0171) THEN
                        DELETE PROCEDURE h-b1wgen0171.
        
                    IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                        IF  AVAIL tt-erro  THEN DO:
                            MESSAGE tt-erro.dscritic.
                            PAUSE 2 NO-MESSAGE.
                            HIDE MESSAGE.
                            NEXT.
                        END.
                    END.
                    ELSE DO:
                        MESSAGE " Registro de Baixa Manual efetuada com sucesso!".
                        PAUSE 2 NO-MESSAGE.
                        HIDE MESSAGE.
                    END.
    
                    LEAVE.
                END.
            END.
        END.



        WHEN "C" THEN DO: /*** CONSULTAR ***/

            ASSIGN aux_nrpospsq = 6
                   aux_nrposdet = 8.

            RUN consulta_dados.

            FOR EACH tt-bens-gravames NO-LOCK
               WHERE tt-bens-gravames.tpctrpro = 90:
                ASSIGN aux_lsseqbem = "(" +
                                      STRING(tt-bens-gravames.nrseqbem,">9") +
                                      "o Bem )".

                DISP aux_lsseqbem               tt-bens-gravames.dtmvtolt
                     tt-bens-gravames.dssitgrv  tt-bens-gravames.uflicenc
                     tt-bens-gravames.nrgravam  tt-bens-gravames.dscatbem
                     tt-bens-gravames.dsbemfin  tt-bens-gravames.dscorbem
                     tt-bens-gravames.vlmerbem  tt-bens-gravames.dschassi
                     tt-bens-gravames.tpchassi  tt-bens-gravames.ufdplaca
                     tt-bens-gravames.nrdplaca  tt-bens-gravames.nrrenava
                     tt-bens-gravames.nranobem  tt-bens-gravames.nrmodbem
                     tt-bens-gravames.vlctrgrv  tt-bens-gravames.dtoperac
                     tt-bens-gravames.dscpfbem  tt-bens-gravames.dsblqjud
                     WITH FRAME f_gravam_dados.

             
                IF  tt-bens-gravames.cdsitgrv = 2
                AND tt-bens-gravames.dsjstinc <> "" THEN DO:
                    ASSIGN tel_dsjstinc = "".
    
                    IF  LENGTH(tt-bens-gravames.dsjstinc) > 52 THEN
                        ASSIGN tel_dsjstinc = SUBSTR(
                                              tt-bens-gravames.dsjstinc,53).

                    DISP tt-bens-gravames.dsjstinc
                         tel_dsjstinc
                      WITH FRAME f_gravam_justif_incl.
    
                    VIEW FRAME f_gravam_justif_incl.
                END.
                    
                IF  tt-bens-gravames.cdsitgrv = 4
                AND tt-bens-gravames.dsjstbxa <> "" THEN DO:
                    ASSIGN tel_dsjstbxa = "".

                    IF  LENGTH(tt-bens-gravames.dsjstbxa) > 52 THEN
                        ASSIGN tel_dsjstbxa = SUBSTR(
                                              tt-bens-gravames.dsjstbxa,53).

                    DISP tt-bens-gravames.dsjstbxa
                         tel_dsjstbxa
                      WITH FRAME f_gravam_justif_baixa.

                    VIEW FRAME f_gravam_justif_baixa.
                END.

                IF  aux_qtdebens > 1
                AND tel_nrgravam = 0 THEN DO:
                    IF  tt-bens-gravames.nrseqbem <> aux_qtdebens THEN DO:
                        MESSAGE " Tecle <Enter> para exibir o proximo bem...".
                        WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                        HIDE MESSAGE.
                    END.
                END.
            END.
        END.



        WHEN "G" THEN DO:  /** GERACAO ARQUIVO **/

            IF  glb_cdcooper <> 3                       OR
               (glb_dsdepart <> "TI"                    AND
                glb_dsdepart <> "PRODUTOS") THEN DO:

                BELL.
                MESSAGE "Operador sem autorizacao para gerar arquivos!".
                NEXT.
            END.

            HIDE FRAME f_gravam_pesq.
            HIDE FRAME f_gravam_dados.

            ASSIGN aux_nrpospsq = 6
                   aux_nrposdet = 8.

            UPDATE tel_cdcooper WITH FRAME f_gravam_geracao.
            UPDATE tel_tparquiv WITH FRAME f_gravam_geracao.

            DO WHILE TRUE:

                IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
                    RUN sistema/generico/procedures/b1wgen0171.p
                        PERSISTENT SET h-b1wgen0171.
    
                MESSAGE "Aguarde... Gerando arquivos...".

                RUN gravames_geracao_arquivo IN h-b1wgen0171
                                  ( INPUT glb_cdcooper,
                                    INPUT tel_cdcooper,
                                    INPUT tel_tparquiv,
                                    INPUT glb_dtmvtolt,
                                   OUTPUT TABLE tt-erro).

                HIDE MESSAGE NO-PAUSE.

                IF  VALID-HANDLE(h-b1wgen0171) THEN
                    DELETE PROCEDURE h-b1wgen0171.

                IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAIL tt-erro  THEN DO:
                        MESSAGE tt-erro.dscritic.
                        PAUSE 2 NO-MESSAGE.
                        HIDE MESSAGE.
                        LEAVE.
                    END.
                END.
                ELSE DO:
                    MESSAGE " Geracao do arquivo de " + tel_tparquiv +
                            " efetuada com sucesso!".
                    PAUSE 2 NO-MESSAGE.
                    HIDE MESSAGE.
                END.

                LEAVE.
            END.
        END.
        
        WHEN "H" THEN DO: /* HISTORICO DO CONTRATO **/

            HIDE FRAME f_gravam_pesq.
            HIDE FRAME f_gravam_dados.

            CLEAR FRAME f_gravam_historico  ALL NO-PAUSE.

            ASSIGN aux_nrpospsq = 6
                   aux_nrposdet = 8.

            UPDATE tel_cdcooper WITH FRAME f_gravam_historico.
            UPDATE tel_nrdconta WITH FRAME f_gravam_historico.

            /* Chama para carregar o F7 do Contrato*/
            ASSIGN aux_flgfirst = TRUE.
            RUN gravam_busca_contratos.
    
            IF  RETURN-VALUE <> "OK" THEN DO:
                MESSAGE " Associado sem Emprestimos tipo Alienacao Fiduciaria!".
                PAUSE 2 NO-MESSAGE.
                HIDE MESSAGE.
                NEXT.
            END.
    
            DO WHILE TRUE:
    
                UPDATE tel_nrctrpro WITH FRAME f_gravam_historico
                EDITING:
                    READKEY.
    
                    IF  LASTKEY = KEYCODE("F7") THEN DO:
                        IF  FRAME-FIELD = "tel_nrctrpro" THEN DO:
                            OPEN QUERY q-contratos-historico FOR EACH tt-contratos.
                            
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                UPDATE b-contratos-historico WITH FRAME f_contratos_historico.
                                LEAVE.
                            END.
    
                            HIDE FRAME f_contratos_historico.
                        END.
                        ELSE
                            APPLY LASTKEY.
                    END.
                    ELSE
                        APPLY LASTKEY.
                END.
    
                /* Chama para Validar o que foi informado */
                ASSIGN aux_flgfirst = FALSE.
                RUN gravam_busca_contratos.
                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.
    
                LEAVE.
            END.

            DO WHILE TRUE:

                IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
                    RUN sistema/generico/procedures/b1wgen0171.p
                        PERSISTENT SET h-b1wgen0171.

                MESSAGE "Aguarde... Gerando historico...".

                RUN gravames_historico IN h-b1wgen0171
                                  ( INPUT glb_cdcooper,
                                    INPUT tel_cdcooper,
                                    INPUT tel_nrdconta,
                                    INPUT tel_nrctrpro,
                                    INPUT glb_dtmvtolt,
                                   OUTPUT aux_nmarquiv).

                HIDE MESSAGE NO-PAUSE.

                IF  VALID-HANDLE(h-b1wgen0171) THEN
                    DELETE PROCEDURE h-b1wgen0171.

                RUN fontes/visrel.p (INPUT aux_nmarquiv).

                UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

                LEAVE.

            END.

        END.

        WHEN "I" THEN DO: /* IMPRESSAO RELATORIO **/

            HIDE FRAME f_gravam_pesq.
            HIDE FRAME f_gravam_dados.

            ASSIGN aux_nrpospsq = 6
                   aux_nrposdet = 8
                   tel_dtrefere = glb_dtmvtolt.

            UPDATE tel_cdcooper WITH FRAME f_gravam_impressao.
            UPDATE tel_tparquiv WITH FRAME f_gravam_impressao.
            UPDATE tel_nrseqlot 
                   tel_dtrefere WITH FRAME f_gravam_impressao.


            DO WHILE TRUE:

                IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
                    RUN sistema/generico/procedures/b1wgen0171.p
                        PERSISTENT SET h-b1wgen0171.
    
                MESSAGE "Aguarde... Gerando relatorio...".

                RUN gravames_impressao_relatorio IN h-b1wgen0171
                                  ( INPUT glb_cdcooper,
                                    INPUT tel_cdcooper,
                                    INPUT tel_tparquiv,
                                    INPUT tel_nrseqlot,
                                    INPUT tel_dtrefere,
                                    INPUT glb_dtmvtolt,
                                    INPUT "1",  /** Caracter **/
                                   OUTPUT aux_nmarquiv,
                                   OUTPUT aux_nmarqpdf,
                                   OUTPUT TABLE tt-erro).
                
                HIDE MESSAGE NO-PAUSE.

                IF  VALID-HANDLE(h-b1wgen0171) THEN
                    DELETE PROCEDURE h-b1wgen0171.
    
                IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                    IF  AVAIL tt-erro  THEN DO:
                        MESSAGE tt-erro.dscritic.
                        PAUSE 2 NO-MESSAGE.
                        HIDE MESSAGE.
                        LEAVE.
                    END.
                END.
                ELSE DO:
                    ASSIGN tel_cddopcao = "T".

                    DO WHILE TRUE ON END-KEY UNDO , LEAVE:

                        MESSAGE "(T)erminal ou (I)mpressora: "
                                UPDATE tel_cddopcao.
                        LEAVE.
                    END.

                    ASSIGN aux_nmarqimp = aux_nmarquiv.
                    
                    IF  tel_cddopcao = "T"   THEN DO:
                        RUN fontes/visrel.p (INPUT aux_nmarqimp).
                    END.
                    ELSE
                       IF  tel_cddopcao = "I"   THEN DO:
                           ASSIGN par_flgrodar = TRUE
                                  glb_nmformul = "234dh"
                                  glb_nrdevias = 1.

                            FIND FIRST crapass
                                 WHERE crapass.cdcooper = glb_cdcooper
                               NO-LOCK NO-ERROR.
                            RUN gera_impressao.

                       END.

                    MESSAGE " Impressao do relatorio" +
                            " foi efetuada!".
                    PAUSE 2 NO-MESSAGE.
                    HIDE MESSAGE.

                    UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

                END.

                LEAVE.
            END.
        END.

        WHEN "J" THEN DO: /*** BLOQUEIO JUDICIAL ***/

            ASSIGN aux_nrpospsq = 6
                   aux_nrposdet = 8.

            RUN consulta_dados.

            FOR EACH tt-bens-gravames NO-LOCK
               WHERE tt-bens-gravames.tpctrpro = 90:
                ASSIGN aux_lsseqbem = "(" +
                                      STRING(tt-bens-gravames.nrseqbem,">9") +
                                      "o Bem )".

                DISP aux_lsseqbem               tt-bens-gravames.dtmvtolt
                     tt-bens-gravames.dssitgrv  tt-bens-gravames.uflicenc
                     tt-bens-gravames.nrgravam  tt-bens-gravames.dscatbem
                     tt-bens-gravames.dsbemfin  tt-bens-gravames.dscorbem
                     tt-bens-gravames.vlmerbem  tt-bens-gravames.dschassi
                     tt-bens-gravames.tpchassi  tt-bens-gravames.ufdplaca
                     tt-bens-gravames.nrdplaca  tt-bens-gravames.nrrenava
                     tt-bens-gravames.nranobem  tt-bens-gravames.nrmodbem
                     tt-bens-gravames.vlctrgrv  tt-bens-gravames.dtoperac
                     tt-bens-gravames.dscpfbem  tt-bens-gravames.dsblqjud
                     WITH FRAME f_gravam_dados.

             
                IF  tt-bens-gravames.cdsitgrv = 2
                AND tt-bens-gravames.dsjstinc <> "" THEN DO:
                    ASSIGN tel_dsjstinc = "".
    
                    IF  LENGTH(tt-bens-gravames.dsjstinc) > 52 THEN
                        ASSIGN tel_dsjstinc = SUBSTR(
                                              tt-bens-gravames.dsjstinc,53).

                    DISP tt-bens-gravames.dsjstinc
                         tel_dsjstinc
                      WITH FRAME f_gravam_justif_incl.
    
                    VIEW FRAME f_gravam_justif_incl.
                END.
                    
                IF  tt-bens-gravames.cdsitgrv = 4
                AND tt-bens-gravames.dsjstbxa <> "" THEN DO:
                    ASSIGN tel_dsjstbxa = "".

                    IF  LENGTH(tt-bens-gravames.dsjstbxa) > 52 THEN
                        ASSIGN tel_dsjstbxa = SUBSTR(
                                              tt-bens-gravames.dsjstbxa,53).

                    DISP tt-bens-gravames.dsjstbxa
                         tel_dsjstbxa
                      WITH FRAME f_gravam_justif_baixa.

                    VIEW FRAME f_gravam_justif_baixa.
                END.
                
                IF tt-bens-gravames.dsblqjud = "NAO" THEN
                DO:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                       ASSIGN aux_confirma = "N".
        
                       MESSAGE "078 - Deseja efetuar o Bloqueio Judicial da " +
                               "alienacao do Gravames? (S/N)"
                            UPDATE aux_confirma.
                       LEAVE.
        
                    END.  /*  Fim do DO WHILE TRUE  */
                    
                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                         aux_confirma <> "S" THEN
                         DO:
                             IF  aux_qtdebens > 1
                             AND tel_nrgravam = 0 THEN DO:
                                 IF  tt-bens-gravames.nrseqbem <> aux_qtdebens THEN DO:
                                     MESSAGE " Tecle <Enter> para exibir o proximo bem...".
                                     WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                                     HIDE MESSAGE.
                                 END.
                             END.
                         END.
                    ELSE
                    DO:
    
                        DO WHILE TRUE:
        
                            IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
                                RUN sistema/generico/procedures/b1wgen0171.p
                                    PERSISTENT SET h-b1wgen0171.
                        
                            MESSAGE "Aguarde... atualizando...".

                            RUN gravames_blqjud IN h-b1wgen0171 
                                              ( INPUT glb_cdcooper,
                                                INPUT glb_cdoperad,
                                                INPUT tel_nrdconta,
                                                INPUT tel_nrctrpro,
                                                INPUT tt-bens-gravames.idseqbem,
                                                INPUT glb_dtmvtolt,
                                                INPUT tt-bens-gravames.dschassi,
                                                INPUT tt-bens-gravames.ufdplaca,
                                                INPUT tt-bens-gravames.nrdplaca,
                                                INPUT tt-bens-gravames.nrrenava,
                                                INPUT glb_cddopcao,
                                                INPUT 1, /* bloquear, 0 - nao bloqueado */
                                               OUTPUT TABLE tt-erro).
                
                            IF  VALID-HANDLE(h-b1wgen0171) THEN
                                DELETE PROCEDURE h-b1wgen0171.
                            
                            PAUSE 0.
                            HIDE MESSAGE.

                            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                                IF  AVAIL tt-erro  THEN DO:
                                    MESSAGE tt-erro.dscritic.
                                    PAUSE 2 NO-MESSAGE.
                                    HIDE MESSAGE.
                                    LEAVE.
                                END.
                            END.
                            ELSE DO:
                                MESSAGE "Bloqueio do bem registrado com sucesso!".
                                PAUSE 2 NO-MESSAGE.
                                HIDE MESSAGE.
                            END.
                            
                            IF  aux_qtdebens > 1
                            AND tel_nrgravam = 0 THEN DO:
                                IF  tt-bens-gravames.nrseqbem <> aux_qtdebens THEN 
                                DO:
                                    MESSAGE " Tecle <Enter> para exibir o " +
                                            "proximo bem...".
                                    WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                                    HIDE MESSAGE.
                                END.
                            END.
                            LEAVE.
                        END.
                    END.
                END.
                ELSE
                DO:
                    IF  aux_qtdebens > 1 AND tel_nrgravam = 0 THEN DO:
                        IF  tt-bens-gravames.nrseqbem <> aux_qtdebens THEN 
                        DO:
                            MESSAGE " Tecle <Enter> para exibir o " +
                                    "proximo bem...".
                            WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                            HIDE MESSAGE.
                        END.
                        ELSE
                        DO:
                            MESSAGE " Bloqueio do bem ja registrado.".
                            WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                            HIDE MESSAGE.
                        END.
                    END.
                    ELSE
                    DO:
                        MESSAGE " Bloqueio do bem ja registrado.".
                        WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                        HIDE MESSAGE.
                    END.
                END.
            END.
        END.

        WHEN "L" THEN DO: /*** LIBERAR BLOQUEIO JUDICIAL ***/

            ASSIGN aux_nrpospsq = 6
                   aux_nrposdet = 8.

            RUN consulta_dados.

            FOR EACH tt-bens-gravames NO-LOCK
               WHERE tt-bens-gravames.tpctrpro = 90:
                ASSIGN aux_lsseqbem = "(" +
                                      STRING(tt-bens-gravames.nrseqbem,">9") +
                                      "o Bem )".

                DISP aux_lsseqbem               tt-bens-gravames.dtmvtolt
                     tt-bens-gravames.dssitgrv  tt-bens-gravames.uflicenc
                     tt-bens-gravames.nrgravam  tt-bens-gravames.dscatbem
                     tt-bens-gravames.dsbemfin  tt-bens-gravames.dscorbem
                     tt-bens-gravames.vlmerbem  tt-bens-gravames.dschassi
                     tt-bens-gravames.tpchassi  tt-bens-gravames.ufdplaca
                     tt-bens-gravames.nrdplaca  tt-bens-gravames.nrrenava
                     tt-bens-gravames.nranobem  tt-bens-gravames.nrmodbem
                     tt-bens-gravames.vlctrgrv  tt-bens-gravames.dtoperac
                     tt-bens-gravames.dscpfbem  tt-bens-gravames.dsblqjud
                     WITH FRAME f_gravam_dados.

             
                IF  tt-bens-gravames.cdsitgrv = 2
                AND tt-bens-gravames.dsjstinc <> "" THEN DO:
                    ASSIGN tel_dsjstinc = "".
    
                    IF  LENGTH(tt-bens-gravames.dsjstinc) > 52 THEN
                        ASSIGN tel_dsjstinc = SUBSTR(
                                              tt-bens-gravames.dsjstinc,53).

                    DISP tt-bens-gravames.dsjstinc
                         tel_dsjstinc
                      WITH FRAME f_gravam_justif_incl.
    
                    VIEW FRAME f_gravam_justif_incl.
                END.
                    
                IF  tt-bens-gravames.cdsitgrv = 4
                AND tt-bens-gravames.dsjstbxa <> "" THEN DO:
                    ASSIGN tel_dsjstbxa = "".

                    IF  LENGTH(tt-bens-gravames.dsjstbxa) > 52 THEN
                        ASSIGN tel_dsjstbxa = SUBSTR(
                                              tt-bens-gravames.dsjstbxa,53).

                    DISP tt-bens-gravames.dsjstbxa
                         tel_dsjstbxa
                      WITH FRAME f_gravam_justif_baixa.

                    VIEW FRAME f_gravam_justif_baixa.
                END.
                
                IF tt-bens-gravames.dsblqjud = "SIM" THEN
                DO:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                       ASSIGN aux_confirma = "N".
        
                       MESSAGE "Deseja Liberar o " +
                               "Bloqueio Judicial da " +
                               "alienacao do Gravames? (S/N)"
                            UPDATE aux_confirma.
                       LEAVE.
        
                    END.  /*  Fim do DO WHILE TRUE  */
                    
                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                         aux_confirma <> "S" THEN
                         DO:
                             IF  aux_qtdebens > 1
                             AND tel_nrgravam = 0 THEN DO:
                                 IF  tt-bens-gravames.nrseqbem <> aux_qtdebens THEN DO:
                                     MESSAGE " Tecle <Enter> para exibir o proximo bem...".
                                     WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                                     HIDE MESSAGE.
                                 END.
                             END.
                         END.
                    ELSE
                    DO:
    
                        DO WHILE TRUE:
        
                            IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
                                RUN sistema/generico/procedures/b1wgen0171.p
                                    PERSISTENT SET h-b1wgen0171.
                
                            MESSAGE "Aguarde... atualizando...".

                            RUN gravames_blqjud IN h-b1wgen0171 
                                              ( INPUT glb_cdcooper,
                                                INPUT glb_cdoperad,
                                                INPUT tel_nrdconta,
                                                INPUT tel_nrctrpro,
                                                INPUT tt-bens-gravames.idseqbem,
                                                INPUT glb_dtmvtolt,
                                                INPUT tt-bens-gravames.dschassi,
                                                INPUT tt-bens-gravames.ufdplaca,
                                                INPUT tt-bens-gravames.nrdplaca,
                                                INPUT tt-bens-gravames.nrrenava,
                                                INPUT glb_cddopcao,
                                                INPUT 0, /* 1 - bloqueado, 0 - nao bloqueado */
                                               OUTPUT TABLE tt-erro).
                
                            IF  VALID-HANDLE(h-b1wgen0171) THEN
                                DELETE PROCEDURE h-b1wgen0171.
                
                            PAUSE 0.
                            HIDE MESSAGE.

                            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                                IF  AVAIL tt-erro  THEN DO:
                                    MESSAGE tt-erro.dscritic.
                                    PAUSE 2 NO-MESSAGE.
                                    HIDE MESSAGE.
                                    LEAVE.
                                END.
                            END.
                            ELSE DO:
                                MESSAGE "Desbloqueio do bem registrado com sucesso!".
                                PAUSE 2 NO-MESSAGE.
                                HIDE MESSAGE.
                            END.
                            
                            IF  aux_qtdebens > 1
                            AND tel_nrgravam = 0 THEN DO:
                                IF  tt-bens-gravames.nrseqbem <> aux_qtdebens THEN 
                                DO:
                                    MESSAGE " Tecle <Enter> para exibir o " +
                                            "proximo bem...".
                                    WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                                    HIDE MESSAGE.
                                END.
                            END.
                            LEAVE.
                        END.
                    END.
                END.
                ELSE
                DO:
                    IF  aux_qtdebens > 1 AND tel_nrgravam = 0 THEN DO:
                        IF  tt-bens-gravames.nrseqbem <> aux_qtdebens THEN 
                        DO:
                            MESSAGE " Tecle <Enter> para exibir o " +
                                    "proximo bem...".
                            WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                            HIDE MESSAGE.
                        END.
                        ELSE
                        DO:
                            MESSAGE " Liberacao do bem ja registrada.".
                            WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                            HIDE MESSAGE.
                        END.
                    END.
                    ELSE
                    DO:
                        MESSAGE " Liberacao do bem ja registrada.".
                        WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                        HIDE MESSAGE.
                    END.
                END.
            END.
        END.

        WHEN "M" THEN DO:   /** INCLUSAO MANUAL ***/

            ASSIGN aux_nrpospsq = 6
                   aux_nrposdet = 8.

            RUN consulta_dados.

            FOR EACH tt-bens-gravames NO-LOCK
               WHERE tt-bens-gravames.tpctrpro = 90:
                ASSIGN tel_dsjstinc = "".
                       aux_lsseqbem = "(" +
                                      STRING(tt-bens-gravames.nrseqbem,">9") +
                                      "o Bem )".

                DISP aux_lsseqbem               tt-bens-gravames.dtmvtolt
                     tt-bens-gravames.dssitgrv  tt-bens-gravames.uflicenc
                     tt-bens-gravames.nrgravam  tt-bens-gravames.dscatbem
                     tt-bens-gravames.dsbemfin  tt-bens-gravames.dscorbem
                     tt-bens-gravames.vlmerbem  tt-bens-gravames.dschassi
                     tt-bens-gravames.tpchassi  tt-bens-gravames.ufdplaca
                     tt-bens-gravames.nrdplaca  tt-bens-gravames.nrrenava
                     tt-bens-gravames.nranobem  tt-bens-gravames.nrmodbem
                     tt-bens-gravames.vlctrgrv  tt-bens-gravames.dtoperac
                     tt-bens-gravames.dscpfbem  tt-bens-gravames.dsblqjud
                     WITH FRAME f_gravam_dados.

                IF  tt-bens-gravames.cdsitgrv = 2
                AND tt-bens-gravames.dsjstinc <> "" THEN DO:
                    ASSIGN tel_dsjstinc = "".
    
                    IF  LENGTH(tt-bens-gravames.dsjstinc) > 52 THEN
                        ASSIGN tel_dsjstinc = SUBSTR(
                                              tt-bens-gravames.dsjstinc,53).

                    DISP tt-bens-gravames.dsjstinc
                         tel_dsjstinc
                      WITH FRAME f_gravam_justif_incl.
    
                    VIEW FRAME f_gravam_justif_incl.
                END.
                    
                IF  tt-bens-gravames.cdsitgrv = 4
                AND tt-bens-gravames.dsjstbxa <> "" THEN DO:
                    ASSIGN tel_dsjstbxa = "".

                    IF  LENGTH(tt-bens-gravames.dsjstbxa) > 52 THEN
                        ASSIGN tel_dsjstbxa = SUBSTR(
                                              tt-bens-gravames.dsjstbxa,53).

                    DISP tt-bens-gravames.dsjstbxa
                         tel_dsjstbxa
                      WITH FRAME f_gravam_justif_baixa.

                    VIEW FRAME f_gravam_justif_baixa.
                END.

                DO WHILE TRUE:
    
                    UPDATE tt-bens-gravames.dtmvtolt
                           tt-bens-gravames.nrgravam
                      WITH FRAME f_gravam_dados.
    
                    UPDATE tt-bens-gravames.dsjstinc
                           tel_dsjstinc
                      WITH FRAME f_gravam_justif_incl.

                    ASSIGN tt-bens-gravames.dsjstinc =
                           tt-bens-gravames.dsjstinc + " " + tel_dsjstinc.

                    
                    IF  tt-bens-gravames.dsjstinc = ""
                    AND tt-bens-gravames.dtmvtolt = ?
                    AND tt-bens-gravames.nrgravam = 0 THEN
                        LEAVE. /** Nao faz inclusao manual, passa pro proximo*/
                    ELSE DO:

                        IF  tt-bens-gravames.dtmvtolt = ? THEN DO:
                            MESSAGE " Data do Registro deve ser informada!".
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.

                        IF  tt-bens-gravames.nrgravam = 0 THEN DO:
                            MESSAGE " Numero do Registro deve ser informado!".
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.

                        IF  tt-bens-gravames.dsjstinc = "" THEN DO:
                            MESSAGE " Justificativa deve ser informada!".
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.
                    END.
        
        
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
                       ASSIGN aux_confirma = "N".
        
                       MESSAGE "078 - Deseja efetuar inclusao manual do " +
                               "registro no Gravames? (S/N)"
                            UPDATE aux_confirma.
                       LEAVE.
        
                    END.  /*  Fim do DO WHILE TRUE  */
        
                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                         aux_confirma <> "S" THEN
                         DO:
                             glb_cdcritic = 79.
                             RUN fontes/critic.p.
                             MESSAGE glb_dscritic.
                             glb_cdcritic = 0.
                             PAUSE 3 NO-MESSAGE.
                             LEAVE.
                         END.
        
        
        
                    IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
                        RUN sistema/generico/procedures/b1wgen0171.p
                            PERSISTENT SET h-b1wgen0171.
        
                    RUN gravames_inclusao_manual IN h-b1wgen0171
                                      ( INPUT glb_cdcooper,
                                        INPUT tel_nrdconta,
                                        INPUT tel_nrctrpro,
                                        INPUT glb_dtmvtolt,
                                        INPUT tt-bens-gravames.rowidbpr,
                                        INPUT tt-bens-gravames.nrgravam,
                                        INPUT tt-bens-gravames.dtmvtolt,
                                        INPUT tt-bens-gravames.dsjstinc,
                                        INPUT glb_cddopcao,
                                       OUTPUT TABLE tt-erro).
        
                    IF  VALID-HANDLE(h-b1wgen0171) THEN
                        DELETE PROCEDURE h-b1wgen0171.
        
                    IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                        IF  AVAIL tt-erro  THEN DO:
                            MESSAGE tt-erro.dscritic.
                            PAUSE 2 NO-MESSAGE.
                            HIDE MESSAGE.
                            NEXT.
                        END.
                    END.
                    ELSE DO:
                        MESSAGE " Inclusao Manual do Registro efetuada com " +
                                "sucesso!".
                        PAUSE 2 NO-MESSAGE.
                        HIDE MESSAGE.
                    END.
    
                    LEAVE.
                END.
            END.
        END.



        WHEN "R" THEN DO: /** PROCESSAMENTO DO RETORNO **/

            IF  glb_cdcooper <> 3                       OR
               (glb_dsdepart <> "TI"                    AND
                glb_dsdepart <> "PRODUTOS") THEN DO:

                BELL.
                MESSAGE "Operador sem autorizacao para " +
                        "processar retorno!".
                NEXT.
            END.

            HIDE FRAME f_gravam_pesq.
            HIDE FRAME f_gravam_dados.

            ASSIGN aux_nrpospsq = 6
                   aux_nrposdet = 8.

            UPDATE tel_cdcooper WITH FRAME f_gravam_geracao.
            UPDATE tel_tparquiv WITH FRAME f_gravam_geracao.

            DO WHILE TRUE:

                IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
                    RUN sistema/generico/procedures/b1wgen0171.p
                        PERSISTENT SET h-b1wgen0171.

                RUN gravames_processamento_retorno IN h-b1wgen0171
                                  ( INPUT glb_cdcooper,
                                    INPUT tel_cdcooper,
                                    INPUT tel_tparquiv,
                                    INPUT ?,
                                    INPUT glb_dtmvtolt,
                                   OUTPUT TABLE tt-erro).
    
                IF  VALID-HANDLE(h-b1wgen0171) THEN
                    DELETE PROCEDURE h-b1wgen0171.
    
                IF  RETURN-VALUE <> "OK" THEN DO:
                    FOR EACH tt-erro NO-LOCK:
                        MESSAGE tt-erro.dscritic.
                        PAUSE 3 NO-MESSAGE.
                        HIDE MESSAGE.
                    END.
                END.
                ELSE DO:
                    MESSAGE " Arquivo(s) de retorno" +
                            " foram integrado(s)!".
                    PAUSE 3 NO-MESSAGE.
                    HIDE MESSAGE.

                    IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN DO:
                        FOR EACH tt-erro NO-LOCK:
                            MESSAGE tt-erro.dscritic.
                            PAUSE 2 NO-MESSAGE.
                            HIDE MESSAGE.
                        END.
                    END.
                END.

                LEAVE.
            END.
        END.

        WHEN "S" THEN DO: /*** MANUTENCAO BENS SUBSTITUIDOS ***/

            ASSIGN aux_nrpospsq = 6
                   aux_nrposdet = 8.

            RUN consulta_dados.

            FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper   AND
                               crapepr.nrdconta = tel_nrdconta   AND
                               crapepr.nrctremp = tel_nrctrpro
                               NO-LOCK NO-ERROR.

            ASSIGN aux_lsseqbem = "".

            FOR EACH tt-bens-gravames NO-LOCK
               WHERE tt-bens-gravames.tpctrpro = 99: /* apenas os substituidos */
                ASSIGN aux_lsseqbem = "(" +
                                      STRING(tt-bens-gravames.nrseqbem,">9") +
                                      "o Bem )".

                DISP aux_lsseqbem               tt-bens-gravames.dtmvtolt
                     tt-bens-gravames.dssitgrv  tt-bens-gravames.uflicenc
                     tt-bens-gravames.nrgravam  tt-bens-gravames.dscatbem
                     tt-bens-gravames.dsbemfin  tt-bens-gravames.dscorbem
                     tt-bens-gravames.vlmerbem  tt-bens-gravames.dschassi
                     tt-bens-gravames.tpchassi  tt-bens-gravames.ufdplaca
                     tt-bens-gravames.nrdplaca  tt-bens-gravames.nrrenava
                     tt-bens-gravames.nranobem  tt-bens-gravames.nrmodbem
                     tt-bens-gravames.vlctrgrv  tt-bens-gravames.dtoperac
                     tt-bens-gravames.dscpfbem  tt-bens-gravames.dsblqjud
                     WITH FRAME f_gravam_dados.

             
                IF  tt-bens-gravames.cdsitgrv = 2
                AND tt-bens-gravames.dsjstinc <> "" THEN DO:
                    ASSIGN tel_dsjstinc = "".
    
                    IF  LENGTH(tt-bens-gravames.dsjstinc) > 52 THEN
                        ASSIGN tel_dsjstinc = SUBSTR(
                                              tt-bens-gravames.dsjstinc,53).

                    DISP tt-bens-gravames.dsjstinc
                         tel_dsjstinc
                      WITH FRAME f_gravam_justif_incl.
    
                    VIEW FRAME f_gravam_justif_incl.
                END.
                    
                IF  tt-bens-gravames.cdsitgrv = 4
                AND tt-bens-gravames.dsjstbxa <> "" THEN DO:
                    ASSIGN tel_dsjstbxa = "".

                    IF  LENGTH(tt-bens-gravames.dsjstbxa) > 52 THEN
                        ASSIGN tel_dsjstbxa = SUBSTR(
                                              tt-bens-gravames.dsjstbxa,53).

                    DISP tt-bens-gravames.dsjstbxa
                         tel_dsjstbxa
                      WITH FRAME f_gravam_justif_baixa.

                    VIEW FRAME f_gravam_justif_baixa.
                END.
                
                /* alteracoes apenas quando for situacao 
                   For contrato efetivado ou
                   3 - Proc. com critica */
                IF NOT AVAIL crapepr AND 
                   tt-bens-gravames.cdsitgrv <> 3 THEN
                DO:
                    IF  aux_qtdebens > 1 AND tel_nrgravam = 0 THEN 
                    DO:
                        IF  tt-bens-gravames.nrseqbem <> aux_qtdebens THEN DO:
                            MESSAGE " Tecle <Enter> para exibir o proximo bem...".
                            WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                            HIDE MESSAGE.
                        END.
                    END.

                    NEXT.
                     
                END.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                    UPDATE tt-bens-gravames.dschassi
                           tt-bens-gravames.ufdplaca
                           tt-bens-gravames.nrdplaca
                           tt-bens-gravames.nrrenava  
                           tt-bens-gravames.nranobem
                           tt-bens-gravames.nrmodbem
                      WITH FRAME f_gravam_dados

                    EDITING:

                       READKEY.
                        
                       IF  FRAME-FIELD = "dschassi"   THEN
                           DO:
                              IF  KEYFUNCTION(LASTKEY) = "o" OR
                                  KEYFUNCTION(LASTKEY) = "O" THEN
                                  NEXT.
                              ELSE
                              DO:
                                  APPLY LASTKEY.
                                  ASSIGN tt-bens-gravames.dschassi.
                                    
                                  IF CAN-DO("AUTOMOVEL,MOTO,CAMINHAO",
                                            tt-bens-gravames.dscatbem) AND
                                     LENGTH(tt-bens-gravames.dschassi) > 17 THEN
                                  DO:
                                      ASSIGN tt-bens-gravames.dschassi = 
                                      SUBSTR(tt-bens-gravames.dschassi,1,17).
                                      DISPLAY tt-bens-gravames.dschassi 
                                      WITH FRAME f_gravam_dados.
                                  END.
                              END.
                           END.
                       ELSE
                           APPLY LASTKEY.

                    END.  /*  Fim do EDITING  */

                    IF  tt-bens-gravames.dschassi = ""
                    OR  tt-bens-gravames.ufdplaca = ""
                    OR  tt-bens-gravames.nrdplaca = ""
                    OR  tt-bens-gravames.nrrenava = 0 THEN DO:
                        MESSAGE " Campos Chassi, UF, Placa e Renavam devem ser "+
                                "informados! ".
                        PAUSE 2 NO-MESSAGE.
                        HIDE MESSAGE.
                        NEXT.
                    END.

                    
                    IF tt-bens-gravames.cdsitgrv = 0 OR 
                       tt-bens-gravames.cdsitgrv = 3 THEN
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                       ASSIGN aux_confirma = "N".
        
                       MESSAGE "Deseja efetuar a alteracao? (S/N)"
                            UPDATE aux_confirma.
                       LEAVE.
        
                    END.  /*  Fim do DO WHILE TRUE  */
                
                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                         aux_confirma <> "S" THEN
                         DO:
                             IF  aux_qtdebens > 1
                             AND tel_nrgravam = 0 THEN DO:
                                 IF  tt-bens-gravames.nrseqbem <> aux_qtdebens THEN DO:
                                     MESSAGE " Tecle <Enter> para exibir o proximo bem...".
                                     WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                                     HIDE MESSAGE.
                                 END.
                             END.
                         END.
                    ELSE
                    DO:
                          
                        IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
                            RUN sistema/generico/procedures/b1wgen0171.p
                                PERSISTENT SET h-b1wgen0171.
            
                        MESSAGE "Aguarde... atualizando...".
                
                        IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
                            RUN sistema/generico/procedures/b1wgen0171.p
                            PERSISTENT SET h-b1wgen0171.
    
                        RUN gravames_alterar IN h-b1wgen0171
                                          ( INPUT glb_cdcooper,
                                            INPUT glb_cdoperad,
                                            INPUT tel_nrdconta,
                                            INPUT tel_nrctrpro,
                                            INPUT tt-bens-gravames.idseqbem,
                                            INPUT glb_dtmvtolt,
                                            INPUT tt-bens-gravames.dscatbem,
                                            INPUT tt-bens-gravames.dschassi,
                                            INPUT tt-bens-gravames.ufdplaca,
                                            INPUT tt-bens-gravames.nrdplaca,
                                            INPUT tt-bens-gravames.nrrenava,
                                            INPUT tt-bens-gravames.nranobem,
                                            INPUT tt-bens-gravames.nrmodbem,
                                            INPUT tt-bens-gravames.tpctrpro,
                                            INPUT glb_cddopcao,
                                           OUTPUT TABLE tt-erro).
        
                        IF  VALID-HANDLE(h-b1wgen0171) THEN
                            DELETE PROCEDURE h-b1wgen0171.
        
                        PAUSE 0.
                        HIDE MESSAGE.

                        IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                            IF  AVAIL tt-erro  THEN DO:
                                MESSAGE tt-erro.dscritic.
                                PAUSE 2 NO-MESSAGE.
                                HIDE MESSAGE.
                                NEXT.
                            END.
                        END.
                        ELSE DO:
                            MESSAGE REPLACE(REPLACE(aux_lsseqbem,"(",""),")","")
                                    "atualizado com sucesso!".
                            PAUSE 2 NO-MESSAGE.
                            HIDE MESSAGE.
                        END.
        
                        IF  aux_qtdebens > 1
                        AND tel_nrgravam = 0 THEN DO:
                            IF  tt-bens-gravames.nrseqbem <> aux_qtdebens THEN DO:
                                MESSAGE " Tecle <Enter> para exibir o proximo bem...".
                                WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                                HIDE MESSAGE.
                            END.
                        END.
                    END.
                
                    IF  aux_qtdebens > 1 AND tel_nrgravam = 0 THEN DO:
                        IF  tt-bens-gravames.nrseqbem <> aux_qtdebens THEN 
                        DO:
                            MESSAGE " Tecle <Enter> para exibir o " +
                                    "proximo bem...".
                            WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                            HIDE MESSAGE.
                        END.
                    END.

                    LEAVE.
                END. /* Do while true */
            END.

            IF aux_lsseqbem = "" THEN
            DO:
                MESSAGE " Nao existe aditivo para este contrato.".
                WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                HIDE MESSAGE.
            END.
        END.


        WHEN "X" THEN DO: /** CANCELAMENTO **/

            ASSIGN aux_nrpospsq = 7
                   aux_nrposdet = 9.

            RUN consulta_dados.

            FOR EACH tt-bens-gravames NO-LOCK
               WHERE tt-bens-gravames.tpctrpro = 90:
                ASSIGN aux_lsseqbem = "(" +
                                      STRING(tt-bens-gravames.nrseqbem,">9") +
                                      "o Bem )".

                DISP aux_lsseqbem               tt-bens-gravames.dtmvtolt
                     tt-bens-gravames.dssitgrv  tt-bens-gravames.uflicenc
                     tt-bens-gravames.nrgravam  tt-bens-gravames.dscatbem
                     tt-bens-gravames.dsbemfin  tt-bens-gravames.dscorbem
                     tt-bens-gravames.vlmerbem  tt-bens-gravames.dschassi
                     tt-bens-gravames.tpchassi  tt-bens-gravames.ufdplaca
                     tt-bens-gravames.nrdplaca  tt-bens-gravames.nrrenava
                     tt-bens-gravames.nranobem  tt-bens-gravames.nrmodbem
                     tt-bens-gravames.vlctrgrv  tt-bens-gravames.dtoperac
                     tt-bens-gravames.dscpfbem  tt-bens-gravames.dsblqjud
                     WITH FRAME f_gravam_dados.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                   ASSIGN aux_confirma = "N".

                   MESSAGE "078 - Deseja cancelar o registro da alienacao " +
                           "no Gravames?? (S/N)"
                        UPDATE aux_confirma.
                   LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                     aux_confirma <> "S" THEN
                     DO:
                         glb_cdcritic = 79.
                         RUN fontes/critic.p.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         PAUSE 3 NO-MESSAGE.
                         NEXT.
                     END.


                 IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
                     RUN sistema/generico/procedures/b1wgen0171.p
                         PERSISTENT SET h-b1wgen0171.

                 RUN gravames_cancelar IN h-b1wgen0171
                                   ( INPUT glb_cdcooper,
                                     INPUT tel_nrdconta,
                                     INPUT tel_nrctrpro,
                                     INPUT tt-bens-gravames.idseqbem,
                                     INPUT glb_dtmvtolt,
                                     INPUT tel_tpcancel,
                                     INPUT glb_cddopcao,
                                    OUTPUT TABLE tt-erro).

                 IF  VALID-HANDLE(h-b1wgen0171) THEN
                     DELETE PROCEDURE h-b1wgen0171.

                 IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.

                     IF  AVAIL tt-erro  THEN DO:
                         MESSAGE tt-erro.dscritic.
                         PAUSE 2 NO-MESSAGE.
                         HIDE MESSAGE.
                         NEXT.
                     END.
                 END.
                 ELSE DO:
                     IF  tel_tpcancel THEN
                         MESSAGE "Solicitacao de Cancelamento " +
                                 "efetuada com sucesso!".
                     ELSE
                         MESSAGE "Registro de alienacao do Gravame " +
                                 "cancelado com sucesso!".
                     PAUSE 2 NO-MESSAGE.
                     HIDE MESSAGE.
                 END.

                 IF  aux_qtdebens > 1
                 AND tel_nrgravam = 0 THEN DO:
                     IF  tt-bens-gravames.nrseqbem <> aux_qtdebens THEN DO:
                         MESSAGE " Tecle <Enter> para exibir o proximo bem...".
                         WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                         HIDE MESSAGE.
                     END.
                 END.
            END.
        END.

    END CASE.
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        APPLY "ERROR".

END. /* FIM do DO WHILE TRUE */




/******************************************************************************/

PROCEDURE gravam_efetua_consulta_pa:

    IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
        RUN sistema/generico/procedures/b1wgen0171.p
            PERSISTENT SET h-b1wgen0171.

    RUN gravames_busca_pa_associado IN h-b1wgen0171
                      ( INPUT glb_cdcooper,
                        INPUT tel_nrdconta,
                       OUTPUT tel_cdagenci,
                       OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0171) THEN
        DELETE PROCEDURE h-b1wgen0171.

    IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  AVAIL tt-erro  THEN
               DO:
                   MESSAGE tt-erro.dscritic.
                   PAUSE 2 NO-MESSAGE.
                   HIDE MESSAGE.
                   NEXT.
               END.
       END.

END PROCEDURE.

/*****************************************************************************/

PROCEDURE consulta_dados:

    DO WHILE TRUE:

        EMPTY TEMP-TABLE tt-bens-gravames.
        EMPTY TEMP-TABLE tt-bens-zoom.
        EMPTY TEMP-TABLE tt-contratos.


        ASSIGN tel_nrdconta = 0
               tel_cdagenci = 0
               tel_nrctrpro = 0
               tel_nrgravam = 0
               tel_tpcancel = FALSE.

    /*     CLEAR FRAME f_gravam_dados  ALL NO-PAUSE.        */
    /*     CLEAR FRAME f_gravam_pesq   ALL NO-PAUSE.        */
    /*     CLEAR FRAME f_gravam_cancel ALL NO-PAUSE.        */
    /*     CLEAR FRAME f_gravam_justif_baixa ALL NO-PAUSE. */
    
        HIDE  FRAME f_gravam_dados.
        HIDE  FRAME f_gravam_pesq.
        HIDE  FRAME f_gravam_cancel.
        HIDE  FRAME f_gravam_impressao.
        HIDE  FRAME f_gravam_historico.
        HIDE  FRAME f_gravam_justif_baixa.
        HIDE  FRAME f_gravam_justif_incl.
        HIDE  MESSAGE NO-PAUSE.

        IF  glb_cddopcao = "X" THEN DO:

            DO WHILE TRUE:
                UPDATE tel_tpcancel
                  WITH FRAME f_gravam_cancel.

                LEAVE.
            END.
        END.


        DISPLAY tel_nrdconta tel_cdagenci
                tel_nrctrpro tel_nrgravam
           WITH FRAME f_gravam_pesq.


        DO WHILE TRUE:

            UPDATE tel_nrdconta
              WITH FRAME f_gravam_pesq.

            RUN gravam_efetua_consulta_pa.
            IF  RETURN-VALUE <> "OK" THEN
                NEXT.

            IF  tel_cdagenci <> 0 THEN
                DISPLAY tel_cdagenci
                   WITH FRAME f_gravam_pesq.
            LEAVE.

        END.

        /* Chama para carregar o F7 do Contrato*/
        ASSIGN aux_flgfirst = TRUE.
        RUN gravam_busca_contratos.

        IF  RETURN-VALUE <> "OK" THEN DO:
            MESSAGE " Associado sem Emprestimos tipo Alienacao Fiduciaria!".
            PAUSE 2 NO-MESSAGE.
            HIDE MESSAGE.
            NEXT.
        END.

        DO WHILE TRUE:

            UPDATE tel_nrctrpro WITH FRAME f_gravam_pesq
            EDITING:
                READKEY.

                IF  LASTKEY = KEYCODE("F7") THEN DO:
                    IF  FRAME-FIELD = "tel_nrctrpro" THEN DO:
                        OPEN QUERY q-contratos FOR EACH tt-contratos.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            UPDATE b-contratos WITH FRAME f_contratos.
                            LEAVE.
                        END.

                        HIDE FRAME f_contratos.
                    END.
                    ELSE
                        APPLY LASTKEY.
                END.
                ELSE
                    APPLY LASTKEY.
            END.

            /* Chama para Validar o que foi informado */
            ASSIGN aux_flgfirst = FALSE.
            RUN gravam_busca_contratos.
            IF  RETURN-VALUE <> "OK" THEN
                NEXT.

            LEAVE.
        END.


        /* Carregar o F7 (Zoom) */
        RUN gravam_efetua_consulta (INPUT "Z"). /*Z-Zoom*/

        /** Validar qtde reg. - Se apenas 1 registro, ja mostra na tela **/
        OPEN QUERY q-qtd-bens PRESELECT EACH tt-bens-gravames.

        IF  NUM-RESULTS( "q-qtd-bens" ) = 1 THEN DO:
            FIND FIRST tt-bens-gravames NO-LOCK NO-ERROR.

            ASSIGN tel_nrgravam = tt-bens-gravames.nrgravam.
            DISPLAY tel_nrgravam WITH FRAME f_gravam_pesq.
        end.


        DO WHILE TRUE:

            UPDATE tel_nrgravam WITH FRAME f_gravam_pesq
            EDITING:
                READKEY.

                IF  LASTKEY = KEYCODE("F7") THEN DO:
                    IF  FRAME-FIELD = "tel_nrgravam" THEN DO:
                        OPEN QUERY q-bens FOR EACH tt-bens-zoom.

                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            UPDATE b-bens WITH FRAME f_bens.
                            LEAVE.
                        END.

                        HIDE FRAME f_bens.
                    END.
                    ELSE
                        APPLY LASTKEY.
                END.
                ELSE
                    APPLY LASTKEY.
            END.


            /* Consulta conforme parametros de tela */
            RUN gravam_efetua_consulta (INPUT "T"). /* T-TODOS */


            IF  RETURN-VALUE <> "OK" THEN
                NEXT.

            LEAVE.
        END.

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
            APPLY "ERROR".

        LEAVE.
    END.

END PROCEDURE.

/*****************************************************************************/

PROCEDURE gravam_busca_contratos:

    DEF VAR aux_cdcooper AS INT NO-UNDO.

    ASSIGN aux_cdcooper = IF   glb_cdcooper = 3
                          THEN INT(tel_cdcooper)
                          ELSE glb_cdcooper.

    IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
        RUN sistema/generico/procedures/b1wgen0171.p
            PERSISTENT SET h-b1wgen0171.

    RUN gravames_busca_valida_contrato IN h-b1wgen0171
                      ( INPUT aux_cdcooper,
                        INPUT tel_nrdconta,
                        INPUT tel_cdagenci,
                        INPUT tel_nrctrpro,
                        INPUT glb_cddopcao,
                        INPUT aux_flgfirst,
                       OUTPUT aux_qtctrepr,
                       OUTPUT TABLE tt-erro,
                       OUTPUT TABLE tt-contratos).

    IF  VALID-HANDLE(h-b1wgen0171) THEN
        DELETE PROCEDURE h-b1wgen0171.

    IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  AVAIL tt-erro  THEN
               DO:
                   MESSAGE tt-erro.dscritic.
                   PAUSE 2 NO-MESSAGE.
                   HIDE MESSAGE.
                   NEXT.
               END.
       END.
       
    

END PROCEDURE.

/*****************************************************************************/

PROCEDURE gravam_efetua_consulta:
    DEF INPUT PARAM par_tpconsul AS CHAR                            NO-UNDO.


    IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
        RUN sistema/generico/procedures/b1wgen0171.p
            PERSISTENT SET h-b1wgen0171.

    RUN gravames_consultar_bens IN h-b1wgen0171
                      ( INPUT glb_cdcooper,
                        INPUT tel_nrdconta,
                        INPUT tel_nrctrpro,
                        INPUT tel_nrgravam,
                        INPUT glb_cddopcao,
                        INPUT par_tpconsul,
                       OUTPUT aux_qtdebens,
                       OUTPUT TABLE tt-erro,
                       OUTPUT TABLE tt-bens-gravames,
                       OUTPUT TABLE tt-bens-zoom).

    IF  VALID-HANDLE(h-b1wgen0171) THEN
        DELETE PROCEDURE h-b1wgen0171.

    IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  AVAIL tt-erro  THEN
               DO:
                   MESSAGE tt-erro.dscritic.
                   PAUSE 2 NO-MESSAGE.
                   HIDE MESSAGE.
                   NEXT.
               END.
       END.

END PROCEDURE.

/*****************************************************************************/

PROCEDURE gera_impressao:

    { includes/impressao.i }

END PROCEDURE.

/*****************************************************************************/


