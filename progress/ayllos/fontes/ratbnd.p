
/*..............................................................................

    Programa: fontes/ratbnd.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : André Santos - Supero
    Data    : Maio/2013                        Ultima atualizacao: 10/17/2014

    Dados referentes ao programa:

    Frequencia: Diario.
    Objetivo  : Efetuar Operacoes do RATING BNDES.
               
    Alteracoes: 12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
                            
                10/07/2014 - Inclusao da include b1wgen0138tt para uso da
                             temp-table tt-grupo ao invés da tt-grupo-economico.
                            (Tiago Castro - RKAM)
                            
..............................................................................*/

{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0024tt.i }
{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen0056tt.i }
{ sistema/generico/includes/b1wgen0059tt.i }
{ sistema/generico/includes/b1wgen0069tt.i }
{ sistema/generico/includes/b1wgen0084tt.i }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/b1wgen0157tt.i }
{ sistema/generico/includes/b1wgen9999tt.i } 
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0138tt.i } 

{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

{ includes/var_online.i }

DEF STREAM str_1.
DEF STREAM str_2.


/* Cabecalho */
DEF VAR rel_nmempres AS CHAR                                     NO-UNDO.
DEF VAR rel_nmresemp AS CHAR  FORMAT "x(15)"                     NO-UNDO.
DEF VAR rel_nmrelato AS CHAR  FORMAT "x(40)" EXTENT 5            NO-UNDO.

DEF VAR rel_nrmodulo AS INT   FORMAT "9"                         NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR  FORMAT "x(15)" EXTENT 5

                        INIT ["DEP. A VISTA   ","CAPITAL        ",
                              "EMPRESTIMOS    ","DIGITACAO      ",
                              "GENERICO       "]                 NO-UNDO.

/* Variaveis para impressao */
DEF VAR tel_dsimprim AS CHAR  FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF VAR tel_dscancel AS CHAR  FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                     NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                     NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                     NO-UNDO.
DEF VAR par_flgrodar AS LOGI                                     NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                     NO-UNDO.
DEF VAR par_flgcance AS LOGI                                     NO-UNDO.

 
 
DEF VAR aux_cddopcao AS CHAR                                         NO-UNDO.
DEF VAR aux_contador AS INT         INIT 0                           NO-UNDO.

DEF VAR tel_nrdconta AS INT        FORMAT "zzzz,zzz,9"               NO-UNDO.
DEF VAR tel_nmprimtl AS CHAR       FORMAT "x(30)"                    NO-UNDO.

DEF VAR tel_nrctrato AS CHAR       FORMAT "x(8)" VIEW-AS COMBO-BOX  
    INNER-LINES 6                                                    NO-UNDO.

DEF VAR aux_nrctrato AS CHAR                                         NO-UNDO.
DEF VAR tel_vlempbnd AS DECI       FORMAT "zzz,zzz,zz9.99"           NO-UNDO.
DEF VAR tel_qtparbnd LIKE crapprp.qtparbnd                           NO-UNDO.


DEF VAR tel_tprelato AS LOGI
   FORMAT "Rating de Operacoes BNDES/Sem Rating Efetivo"             NO-UNDO.
DEF VAR tel_cdagenci AS INT                                          NO-UNDO.
DEF VAR tel_dtrefini AS DATE   FORMAT "99/99/9999"                   NO-UNDO.
DEF VAR tel_dtreffim AS DATE   FORMAT "99/99/9999"                   NO-UNDO.

DEF VAR tel_nrinfcad AS INT                                          NO-UNDO.
DEF VAR tel_nrgarope AS INT                                          NO-UNDO.
DEF VAR tel_nrliquid AS INT                                          NO-UNDO.
DEF VAR tel_nrpatlvr AS INT                                          NO-UNDO.
DEF VAR tel_nrperger AS INT                                          NO-UNDO.

DEF VAR tel_dsinfcad AS CHAR       FORMAT "x(30)"                    NO-UNDO.
DEF VAR tel_dsgarope AS CHAR       FORMAT "x(30)"                    NO-UNDO.
DEF VAR tel_dsliquid AS CHAR       FORMAT "X(30)"                    NO-UNDO.
DEF VAR tel_dspatlvr AS CHAR       FORMAT "x(30)"                    NO-UNDO.
DEF VAR tel_dsperger AS CHAR       FORMAT "x(30)"                    NO-UNDO.
DEF VAR tel_dspatrim AS CHAR                                         NO-UNDO.

DEF VAR tel_cddopcao AS CHAR       FORMAT "!(1)" INIT "T"            NO-UNDO.

DEF VAR aux_insitrat LIKE crapnrc.insitrat                           NO-UNDO.
DEF VAR aux_dssitcrt AS CHAR                                         NO-UNDO.
DEF VAR aux_tprelato AS CHAR                                         NO-UNDO.
DEF VAR par_qtrequis AS INTE                                         NO-UNDO.
DEF VAR par_dsmsgcnt AS CHAR                                         NO-UNDO.
DEF VAR aux_dsoperac AS CHAR                                         NO-UNDO.
DEF VAR aux_cdcritic AS INT                                          NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                         NO-UNDO.
DEF VAR aux_confirma AS LOG     FORMAT "Sim/Nao"                     NO-UNDO.
DEF VAR aux_confirm2 AS CHAR                                         NO-UNDO.
DEF VAR aux_flconfir AS LOGI                                         NO-UNDO.
DEF VAR aux_inconfir AS INT                                          NO-UNDO.
DEF VAR aux_inconfi2 AS INT                                          NO-UNDO.
DEF VAR aux_flgsuces AS LOGI                                         NO-UNDO.
DEF VAR aux_flgvalid AS LOGI                                         NO-UNDO.


DEF VAR aux_qtctarel AS INT FORMAT "zz9"                             NO-UNDO.
DEF VAR aux_dsdrisco AS CHAR                                         NO-UNDO.
DEF VAR aux_dsmsghlp AS CHAR                                         NO-UNDO.



DEF VAR h-b1wgen0002 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen0110 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen0040 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen0043 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen0157 AS HANDLE                                       NO-UNDO.


DEF QUERY  q-contratos FOR tt-ctrbndes SCROLLING.
DEF QUERY  q-relato    FOR tt-relat    SCROLLING.
DEF QUERY  q-craprad   FOR tt-itens-topico-rating SCROLLING.

DEF BROWSE b-craprad QUERY q-craprad  
    DISPLAY  nrseqite COLUMN-LABEL "Seq.Item"
             dsseqite COLUMN-LABEL "Descricao Seq.Item" FORMAT "x(55)"
             WITH CENTERED 5 DOWN TITLE " Itens do rating ".

FORM b-craprad 
     WITH CENTERED NO-BOX OVERLAY ROW 10 COLUMN 
                                       3 WIDTH 70 FRAME f_craprad.


DEF BROWSE b-relato QUERY q-relato
    DISPLAY tt-relat.cdagenci COLUMN-LABEL "PA"        FORMAT "zz9"
            tt-relat.nrdconta COLUMN-LABEL "Conta/dv"   FORMAT "zzzz,zzz,9"
            tt-relat.vlctrbnd COLUMN-LABEL "Valor"      FORMAT "zzz,zzz,zz9.99"
            tt-relat.nrctrato COLUMN-LABEL "Contrato"   FORMAT "zzzz,zz9"
            tt-relat.dtmvtolt COLUMN-LABEL "Data"       FORMAT "99/99/99"
       WITH SCROLLBAR-VERTICAL 5 DOWN WIDTH 52.


FORM b-relato
     HELP "Pressione <ENTER> para Imprimir"
     WITH CENTERED NO-BOX OVERLAY ROW 9 WIDTH 58 FRAME f_brw_relat.


DEF BROWSE b-contratos QUERY q-contratos  
    DISPLAY  tt-ctrbndes.nrctrato COLUMN-LABEL "Nr Contrato"
             WITH CENTERED 5 DOWN TITLE " Contratos ".

FORM b-contratos 
     WITH CENTERED NO-BOX OVERLAY ROW 10 COLUMN 
                                       3 WIDTH 20 FRAME f_contratos.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela 
                                         FRAME f_moldura.

FORM glb_cddopcao AT 03
               LABEL "Opcao" AUTO-RETURN
                HELP "Informe a opcao desejada (I, E, A, C, R)."
            VALIDATE(CAN-DO("I,E,A,C,R",glb_cddopcao),
                            "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_ratbnd_1.


FORM SKIP (1) 
     tt-msg-confirma.dsmensag AT  2 FORMAT "x(70)"
     SKIP (1)
     WITH NO-LABEL OVERLAY CENTERED ROW 10 WIDTH 74 FRAME f_alertas. 


FORM tel_nrdconta AT 02  LABEL "Conta/DV" 
                   HELP  "Entre com o numero da conta/dv do associado."
     tel_nmprimtl AT 25  LABEL "Nome"
     SKIP(1)
     tel_nrctrato AT 02  LABEL "Contrato"
                   HELP  "Numero do Contrato"
     tel_vlempbnd AT 25  LABEL "Valor" 
                   HELP  "Valor da operacao com o BNDES."
     tel_qtparbnd AT 50  LABEL "Qtd. Prestacoes" FORMAT "zzz9"
                   HELP  "Entre com a quantidade de parcelas do contrato BNDES."

     WITH ROW 8 COLUMN 3 SIDE-LABELS OVERLAY NO-BOX FRAME f_ratbnd_info.


FORM tel_tprelato LABEL "Tipo"
     HELP "Informe [R]ating de Operacoes BNDES/[S]em Rating Efetivo"
     WITH ROW 6 COLUMN 14 SIDE-LABELS OVERLAY NO-BOX FRAME f_ratbnd_relat.


FORM tel_cdagenci AT 04 LABEL "PA" FORMAT "zz9"
                  HELP "Informe o PA ou 0 para listar Todos"

     tel_dtrefini AT 17 LABEL "Data"
     HELP "Informe a Data de referencia Inicial ou branco para Todos"

     tel_dtreffim LABEL "a"
     HELP "Informe a Data de referencia Fim ou branco para Todos"

     WITH ROW 8 COLUMN 3 SIDE-LABELS OVERLAY NO-BOX FRAME f_param_rel_sem.


FORM tel_nrdconta AT 02  LABEL "Conta/DV"
                  HELP  "Entre com o numero da conta/dv do associado."
     tel_nmprimtl AT 23  LABEL "Nome"
     SKIP
     tel_cdagenci AT 07  LABEL "PA" FORMAT "zz9"
                  HELP "Informe o PA ou 0 para listar Todos"
     tel_dtrefini AT 23  LABEL "Data"
                  HELP "Informe a Data de referencia Inicial ou branco para Todos"

     tel_dtreffim LABEL "a"
     HELP "Informe a Data de referencia Fim ou branco para Todos"

     WITH ROW 8 COLUMN 3 SIDE-LABELS OVERLAY NO-BOX FRAME f_param_rel_com.


FORM SKIP(1)
     tel_nrinfcad TO 25 LABEL "Inf. cadastrais" FORMAT "zz9"
     HELP "Informe o codigo da informacao ou <F7> para listar."
     VALIDATE (tel_nrinfcad <> 0,
              "375 - O campo deve ser preenchido.")

     tel_dsinfcad AT 27 NO-LABEL                FORMAT "x(51)"
     SKIP

     tel_nrgarope TO 25 LABEL "Garantia"     FORMAT "zz9"
        HELP "Entre com a garantia ou pressione ou <F7> p/ listar."
        VALIDATE((IF glb_cdcooper <> 3 THEN 
                     tel_nrgarope <> 0
                  ELSE 
                     tel_nrgarope = 0),
                 (IF glb_cdcooper <> 3 THEN
                     "375 - O campo deve ser preenchido."
                  ELSE
                     "375 - O campo deve ser zerado."))
     
     tel_dsgarope AT 27 NO-LABEL             FORMAT "x(45)"
     SKIP

     tel_nrliquid TO 25 LABEL "Liquidez"     FORMAT "zz9"
        HELP "Informe a liquidez das garantias ou <F7> para listar."
        VALIDATE (tel_nrliquid <> 0,
                  "375 - O campo deve ser preenchido.")

     tel_dsliquid AT 27 NO-LABEL             FORMAT "x(45)"  
     SKIP(1)

     tel_dspatrim TO 39 NO-LABEL             FORMAT "x(28)"
     tel_nrpatlvr AT 41 NO-LABEL             FORMAT "zz9"
     HELP "Informe o codigo do patrimonio ou <F7> p/ listar."
     VALIDATE((IF glb_cdcooper <> 3 THEN 
                  tel_nrpatlvr <> 0
               ELSE 
                  tel_nrpatlvr = 0),
              (IF glb_cdcooper <> 3 THEN
                  "375 - O campo deve ser preenchido."
               ELSE 
                  "375 - O campo deve ser zerado."))

     tel_dspatlvr AT 45 NO-LABEL             FORMAT "x(30)"
     SKIP

     tel_nrperger AT 2
     LABEL "Percepcao geral com relacao a empresa"     FORMAT "zz9"
     HELP "Informe o codigo da informacao ou <F7> para listar."
     VALIDATE((IF glb_cdcooper <> 3 THEN 
                  tel_nrperger <> 0
               ELSE 
                  tel_nrperger = 0),
              (IF glb_cdcooper <> 3 THEN
                  "375 - O campo deve ser preenchido."
               ELSE
                  "375 - O campo deve ser zerado."))
      
     tel_dsperger AT 45 NO-LABEL             FORMAT "x(20)"

     WITH ROW 12 COLUMN 3 SIDE-LABELS OVERLAY NO-BOX FRAME f_analise_proposta.


FORM tt-relat.inrisctl LABEL "Risco Coop."     AT 09 FORMAT "x(2)" 
     tt-relat.nrnotatl LABEL "Nota"            AT 25 FORMAT "zz9.99"  
     tt-relat.indrisco LABEL "Rating"          AT 44 FORMAT "x(2)" 
     tt-relat.nrnotrat LABEL "Nota"            AT 55 FORMAT "zz9.99"  
     SKIP
     tt-relat.dteftrat LABEL "Efetivacao"      AT 09 FORMAT "99/99/9999"
     tt-relat.nmoperad LABEL "Ope."            AT 32 FORMAT "x(15)"
     WITH CENTERED SIDE-LABELS NO-BOX OVERLAY ROW 18 WIDTH 78 FRAME f_detalhes.



FORM tt-erro.dscritic COLUMN-LABEL "Descricao" FORMAT "x(62)"
    WITH 4 DOWN TITLE COLOR NORMAL " Criticas do Rating " 
           OVERLAY CENTERED ROW 11 WIDTH 64 FRAME f_criticas.

EMPTY TEMP-TABLE tt-grupo.

DEF QUERY q-ge-economico FOR tt-grupo.

DEF BROWSE b-ge-economico QUERY q-ge-economico
    DISPLAY tt-grupo.nrctasoc 
    WITH 3 DOWN WIDTH 15 NO-BOX NO-LABELS OVERLAY.

FORM "Conta"                                      AT 7
     tel_nrdconta
     "pertence a Grupo Economico."
     SKIP
     "Valor ultrapassa limite legal permitido."   AT 7
     SKIP
     "Verifique endividamento total das contas."  AT 7
     SKIP(1)
     "Grupo possui"                               AT 7
     aux_qtctarel
     "Contas Relacionadas:"         
     SKIP                           
     "-------------------------------------"      AT 7
     SKIP
     b-ge-economico                               AT 18
     HELP "Pressione ENTER / F4 ou END para sair."
     WITH ROW 9 CENTERED NO-LABELS OVERLAY WIDTH 55 FRAME f_ge_economico.

DEF QUERY q-ge-epr FOR tt-grupo.

DEF BROWSE b-ge-epr QUERY q-ge-epr
    DISPLAY tt-grupo.nrctasoc 
    WITH 3 DOWN CENTERED WIDTH 15 NO-BOX NO-LABELS OVERLAY.

FORM "Conta"                                  AT 6
     tel_nrdconta
     "pertence a Grupo Economico."
     SKIP
     "Risco Atual do Grupo:"                  AT 6
     tt-grupo.dsdrisgp   
     "."
     SKIP(1)
     "Grupo possui"                           AT 6
     aux_qtctarel
     "Contas Relacionadas:"                   
     SKIP   
     "-------------------------------------"  AT 6
     SKIP
     b-ge-epr                                 AT 18
     HELP "Pressione ENTER / F4 ou END para sair."
     WITH ROW 9 CENTERED NO-LABELS OVERLAY WIDTH 55 FRAME f_ge_epr.




ON ENTRY, VALUE-CHANGED OF b-relato IN FRAME f_brw_relat DO:
   
    IF   NOT AVAILABLE tt-relat   THEN
         RETURN NO-APPLY.


    IF  tel_tprelato THEN
         DO:
             DISPLAY tt-relat.indrisco
                     tt-relat.nrnotrat
                     tt-relat.inrisctl
                     tt-relat.nrnotatl
                     tt-relat.dteftrat 
                     tt-relat.nmoperad
                     WITH FRAME f_detalhes.  
         END.

END.


ON ENTER OF b-relato IN FRAME f_brw_relat DO:

    IF   NOT AVAILABLE tt-relat   THEN
         RETURN NO-APPLY.

    DISABLE b-relato WITH FRAME f_brw_relat.

    IF  tel_tprelato THEN DO: /* Imprime Rating Contrato - Completo */
        RUN fontes/gera_rating.p
                  (INPUT glb_cdcooper,
                   INPUT tt-relat.nrdconta,
                   INPUT 90,
                   INPUT tt-relat.nrctrato,
                   INPUT FALSE).  /* Nao grava */
    END.

    ENABLE b-relato WITH FRAME f_brw_relat.

END.

ON RETURN OF b-relato IN FRAME f_brw_relat DO:
   ENABLE b-relato WITH FRAME f_brw_relat.
   APPLY "GO". 
END.

ON RETURN, ENDKEY OF b-ge-epr IN FRAME f_ge_epr DO:
   
   APPLY "GO".

END. 

ON RETURN, ENDKEY OF b-ge-economico IN FRAME f_ge_economico DO:

   APPLY "GO".

END. 



glb_cddopcao = "C". /* Consultar Rating Proposto */

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).


DO WHILE TRUE:

   ASSIGN tel_nrdconta = 0
          glb_cdcritic = 0
          aux_contador = 0
          aux_nrctrato = ""
          tel_vlempbnd = 0
          tel_qtparbnd = 0

          tel_nmprimtl = ""
          tel_dsinfcad = ""
          tel_dsgarope = ""
          tel_dsliquid = ""
          tel_dspatlvr = ""
          tel_dsperger = ""

          tel_nrinfcad = 0
          tel_nrgarope = 0
          tel_nrliquid = 0
          tel_nrpatlvr = 0
          tel_nrperger = 0
          tel_nrctrato = "".

          /*tel_nrctrato:LIST-ITEMS = "". /* Limpa LIST-ITEMS */*/


   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      HIDE FRAME f_criticas.
      HIDE FRAME f_brw_relat.
      HIDE FRAME f_detalhes.
      HIDE FRAME f_alertas.

      IF   glb_cdcritic > 0   THEN 
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               PAUSE 2 NO-MESSAGE.
           END.

      UPDATE glb_cddopcao  WITH FRAME f_ratbnd_1.

      CLEAR FRAME f_analise_proposta.
      CLEAR FRAME f_ratbnd_info.
      

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */


   IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN DO: /* F4 OU FIM  */
       RUN fontes/novatela.p.
       IF  CAPS(glb_nmdatela) <> "RATBND"  THEN DO:
           HIDE FRAME f_ratbnd_info.
           HIDE FRAME f_moldura.
           HIDE FRAME f_ratbnd_browse.

           HIDE FRAME f_craprad.
           HIDE FRAME f_brw_relat.
           HIDE FRAME f_contratos.
           HIDE FRAME f_ratbnd_relat.
           HIDE FRAME f_param_rel_sem.
           HIDE FRAME f_param_rel_com.
           HIDE FRAME f_analise_proposta.
           HIDE FRAME f_criticas.
           HIDE FRAME f_alertas.
           HIDE FRAME f_ge_economico.
           HIDE FRAME f_ge_epr.

           HIDE MESSAGE NO-PAUSE.
           RETURN.
       END.
       ELSE
           NEXT.
   END.
   
   IF  aux_cddopcao <> glb_cddopcao THEN
       DO:
         { includes/acesso.i }
         aux_cddopcao = glb_cddopcao.
       END.


   CASE glb_cddopcao:

       WHEN "I" THEN DO: /* Incluir Rating Proposto */
            HIDE FRAME f_ratbnd_info.
            HIDE FRAME f_craprad.
            HIDE FRAME f_brw_relat.
            HIDE FRAME f_contratos.
            HIDE FRAME f_ratbnd_relat.
            HIDE FRAME f_param_rel_sem.
            HIDE FRAME f_param_rel_com.
            HIDE FRAME f_analise_proposta.
            HIDE FRAME f_criticas.
            HIDE FRAME f_alertas.
            HIDE FRAME f_ge_economico.
            HIDE FRAME f_ge_epr.
            HIDE FRAME f_ratbnd_browse.
            HIDE MESSAGE NO-PAUSE.
            
            CLEAR FRAME f_ratbnd_2.
            CLEAR FRAME f_ratbnd_info.
            CLEAR FRAME f_analise_proposta.
            CLEAR FRAME f_criticas.
            tel_nrctrato:LIST-ITEMS = "". 
    
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                NEXT.

            EMPTY TEMP-TABLE tt-erro.
            EMPTY TEMP-TABLE tt-msg-confirma.
            EMPTY TEMP-TABLE tt-grupo.


            /* NRDCONTA */
            DO WHILE TRUE:
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN DO:  /* F4 OU FIM */
                    ASSIGN aux_flgvalid = FALSE.
                    NEXT.
                END.

                EMPTY TEMP-TABLE tt-erro.

                /* Informe o nrdconta do Associado */
                UPDATE tel_nrdconta WITH FRAME f_ratbnd_info.

                IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                    RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
    
                RUN dig_fun IN h-b1wgen9999 
                          ( INPUT glb_cdcooper,
                            INPUT glb_cdagenci,
                            INPUT 0,
                            INPUT-OUTPUT tel_nrdconta,
                           OUTPUT TABLE tt-erro ).
                
                IF  VALID-HANDLE(h-b1wgen9999) THEN
                    DELETE PROCEDURE h-b1wgen9999.
    
                IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAIL tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                                ASSIGN tel_nrdconta = 0.
                                PAUSE 2 NO-MESSAGE.
                                CLEAR FRAME f_ratbnd_info NO-PAUSE.
                                NEXT.
                             END.
                END.


                IF  NOT VALID-HANDLE(h-b1wgen0040) THEN
                    RUN sistema/generico/procedures/b1wgen0040.p
                        PERSISTENT SET h-b1wgen0040.
    
                RUN verifica-conta IN h-b1wgen0040
                                   ( INPUT glb_cdcooper,
                                     INPUT glb_cdagenci,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_nmdatela,
                                     INPUT 1,
                                     INPUT tel_nrdconta,
                                     INPUT 0,
                                     INPUT YES,
                                    OUTPUT tel_nmprimtl, 
                                    OUTPUT par_qtrequis, 
                                    OUTPUT par_dsmsgcnt, 
                                    OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0040) THEN
                    DELETE PROCEDURE h-b1wgen0040.

                IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAIL tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                                PAUSE 2 NO-MESSAGE.
                                CLEAR FRAME f_ratbnd_info NO-PAUSE.
                                NEXT.
                            END.
                    END.


                /* Busca dados Cooperado */
                IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                    RUN sistema/generico/procedures/b1wgen0157.p
                        PERSISTENT SET h-b1wgen0157.

                RUN busca_dados_associado IN h-b1wgen0157
                                   ( INPUT glb_cdcooper,
                                     INPUT tel_nrdconta,
                                    OUTPUT TABLE tt-associado,
                                    OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0157) THEN
                    DELETE PROCEDURE h-b1wgen0157.

                IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAIL tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                                PAUSE 2 NO-MESSAGE.
                                CLEAR FRAME f_ratbnd_info NO-PAUSE.
                                NEXT.
                            END.
                    END.

                FIND FIRST tt-associado NO-LOCK NO-ERROR.
                tel_nmprimtl = tt-associado.nmprimtl.

                LEAVE.
            END. /* END do WHILE TRUE nrdconta */
    
            DISPLAY tel_nmprimtl WITH FRAME f_ratbnd_info.



            IF  NOT VALID-HANDLE(h-b1wgen0043) THEN
                RUN sistema/generico/procedures/b1wgen0043.p
                    PERSISTENT SET h-b1wgen0043.
        
            RUN itens_topicos_rating IN h-b1wgen0043
                                   (INPUT glb_cdcooper,
                                   OUTPUT TABLE tt-itens-topico-rating,
                                   OUTPUT TABLE tt-erro).

            IF  VALID-HANDLE(h-b1wgen0043) THEN
                DELETE PROCEDURE h-b1wgen0043.
        
            IF   RETURN-VALUE <> "OK"   THEN
                 DO: 
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                     IF   AVAIL tt-erro   THEN
                          MESSAGE tt-erro.dscritic.
                     ELSE
                          MESSAGE "Erro na busca dos itens/topicos do Rating.".
            
                     PAUSE 2 NO-MESSAGE.
                     RETURN.
                 END.


            /* LOOP dos campos de parametros */
            DO WHILE TRUE:

                EMPTY TEMP-TABLE tt-erro.
                EMPTY TEMP-TABLE tt-msg-confirma.
                EMPTY TEMP-TABLE tt-grupo.
                
                HIDE FRAME f_criticas.
                HIDE FRAME f_alertas.

                UPDATE tel_vlempbnd
                       tel_qtparbnd WITH FRAME f_ratbnd_info.
    
                IF  tt-associado.inpessoa = 1 THEN DO:
                    HIDE tel_nrperger tel_dsperger
                         IN FRAME f_analise_proposta.
                    tel_dspatrim = "        Patr. pessoal livre:".
                END.
                ELSE DO:
                    VIEW tel_nrperger tel_dsperger
                         IN FRAME f_analise_proposta.
                    tel_dspatrim = "Patr. garant./sócios s/onus:".
                END.
    
    
                DISPLAY tel_dspatrim
                        WITH FRAME f_analise_proposta.
    
    
                UPDATE tel_nrinfcad
                       tel_nrgarope 
                       tel_nrliquid
                       tel_nrpatlvr
                       tel_nrperger WHEN tt-associado.inpessoa = 2
                       WITH FRAME f_analise_proposta
                    EDITING:
    
                     READKEY.
    
                     IF   LASTKEY = KEYCODE("F7")   THEN DO:
                         /* Atribuir já os valores modificados */
                          DO WITH FRAME f_analise_proposta:
    
                             ASSIGN tel_nrgarope
                                    tel_nrinfcad
                                    tel_nrliquid
                                    tel_nrpatlvr
                                    tel_nrperger.
                          END.
    
                          IF  FRAME-FIELD = "tel_nrinfcad"   THEN DO:
                              b-craprad:HELP = "Pressione <ENTER> p/ " +
                                               "selecionar as " +
                                               "informacoes cadastrais.".
        
                              IF   tt-associado.inpessoa = 1 THEN
                                   RUN sequencia_rating 
                                            (INPUT 1,
                                             INPUT 4,
                                      INPUT-OUTPUT tel_nrinfcad,
                                      INPUT-OUTPUT tel_dsinfcad).
                              ELSE
                                   RUN sequencia_rating
                                            (INPUT 3,
                                             INPUT 3,
                                      INPUT-OUTPUT tel_nrinfcad,
                                      INPUT-OUTPUT tel_dsinfcad).
        
                              DISPLAY tel_nrinfcad 
                                      tel_dsinfcad
                                      WITH FRAME f_analise_proposta.
                          END.
                          ELSE
                          IF   FRAME-FIELD = "tel_nrgarope"   THEN
                               DO:
                                   b-craprad:HELP =
                                       "Pressione <ENTER> p/ " +
                                       "selecionar a garantia.".
                                       
                                   IF   tt-associado.inpessoa = 1   THEN
                                        RUN sequencia_rating
                                               (INPUT 2,
                                                INPUT 2,
                                         INPUT-OUTPUT tel_nrgarope,
                                         INPUT-OUTPUT tel_dsgarope).
                                   ELSE
                                        RUN sequencia_rating 
                                               (INPUT 4,
                                                INPUT 2,
                                         INPUT-OUTPUT tel_nrgarope,
                                         INPUT-OUTPUT tel_dsgarope).
                  
                                   DISPLAY tel_nrgarope
                                           tel_dsgarope    
                                           WITH FRAME f_analise_proposta.
                          END.
                          ELSE
                          IF   FRAME-FIELD = "tel_nrliquid"   THEN
                               DO:
                                   b-craprad:HELP = "Pressione <ENTER> p/"
                                                    + " selecionar a " +
                                                 "liquidez das garantias.".
                          
                                   IF   tt-associado.inpessoa = 1   THEN
                                        RUN sequencia_rating 
                                               (INPUT 2,
                                                INPUT 3,
                                         INPUT-OUTPUT tel_nrliquid,
                                         INPUT-OUTPUT tel_dsliquid).
                                   ELSE
                                        RUN sequencia_rating
                                               (INPUT 4,
                                                INPUT 3,
                                         INPUT-OUTPUT tel_nrliquid,
                                         INPUT-OUTPUT tel_dsliquid).
                              
                                   DISPLAY tel_nrliquid
                                           tel_dsliquid
                                           WITH FRAME f_analise_proposta.
                          END.
                          ELSE
                          IF   FRAME-FIELD = "tel_nrpatlvr"   THEN
                               DO:
                                   b-craprad:HELP = "Pressione <ENTER> p/"
                                                + " selecionar " +
                                                  "o patrimonio pessoal.".
                                      
                                   IF   tt-associado.inpessoa = 1   THEN
                                        RUN sequencia_rating 
                                               (INPUT 1,
                                                INPUT 8,
                                         INPUT-OUTPUT tel_nrpatlvr,
                                         INPUT-OUTPUT tel_dspatlvr).
                                   ELSE
                                        RUN sequencia_rating
                                               (INPUT 3,
                                                INPUT 9,
                                         INPUT-OUTPUT tel_nrpatlvr,
                                         INPUT-OUTPUT tel_dspatlvr).
                                  
                                   DISPLAY tel_nrpatlvr
                                           tel_dspatlvr
                                           WITH FRAME f_analise_proposta.
                          END.
                          ELSE
                          IF   FRAME-FIELD = "tel_nrperger"   THEN
                               DO:
                                   b-craprad:HELP = "Pressione <ENTER> p/"
                                                  + " selecionar " +
                                                    "a percepcao geral.".
                                    
                                   RUN sequencia_rating 
                                                 (INPUT 3,
                                                  INPUT 11,
                                           INPUT-OUTPUT tel_nrperger,
                                           INPUT-OUTPUT tel_dsperger).
                                    
                                   DISPLAY tel_nrperger
                                           tel_dsperger 
                                           WITH FRAME f_analise_proposta.
                          END.
                          ELSE
                              APPLY LASTKEY.
                     END. /* Fim do F7 */
                     ELSE
                        APPLY LASTKEY.
                    END. /* Fim do Editing */


                /* Validar campos do RATING */
                IF  NOT VALID-HANDLE(h-b1wgen0043) THEN
                    RUN sistema/generico/procedures/b1wgen0043.p
                        PERSISTENT SET h-b1wgen0043.

                IF   NOT VALID-HANDLE(h-b1wgen0043)   THEN
                     DO:
                         MESSAGE "Handle invalido para a BO b1wgen0043.".
                         PAUSE 2 NO-MESSAGE.
                         NEXT.
                     END.
    
                RUN valida-itens-rating IN h-b1wgen0043 
                                (INPUT  glb_cdcooper,
                                 INPUT  0,
                                 INPUT  0,
                                 INPUT  glb_cdoperad,
                                 INPUT  glb_dtmvtolt,
                                 INPUT  tel_nrdconta,
                                 INPUT  tel_nrgarope,
                                 INPUT  tel_nrinfcad,
                                 INPUT  tel_nrliquid,
                                 INPUT  tel_nrpatlvr,
                                 INPUT  tel_nrperger,
                                 INPUT  1, /* Titular */
                                 INPUT  1, /* Ayllos*/
                                 INPUT  glb_nmdatela,
                                 INPUT  FALSE,
                                OUTPUT TABLE tt-erro).
    
                IF  VALID-HANDLE(h-b1wgen0043) THEN
                    DELETE PROCEDURE h-b1wgen0043.
    
                IF   RETURN-VALUE <> "OK"   THEN
                     DO:
                        ASSIGN aux_flgvalid = FALSE.
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                        IF   AVAILABLE tt-erro   THEN
                             MESSAGE tt-erro.dscritic.
                        ELSE
                             MESSAGE "Erro na validacao dos campos do " +
                                     "Rating.".
    
                        PAUSE 2 NO-MESSAGE.
                        NEXT.   
                END.
            
                aux_confirma = FALSE.
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE COLOR NORMAL 
                      "078 - Confirma inclusao da Proposta BNDES? (S/N)"
                      UPDATE aux_confirma.
                    LEAVE.
                END.


                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    NOT aux_confirma THEN DO:
                    BELL.
                    MESSAGE "Operacao nao efetuada.".
                    ASSIGN aux_flgvalid = FALSE.
                    PAUSE 2 NO-MESSAGE.
                    NEXT. /* Continua pedindo os dados */
                END.

            

                ASSIGN aux_inconfir = 2 
                       aux_inconfi2 = 30.

                /* LOOP do valida-rating-bndes */
                DO WHILE TRUE: 

                    IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                        RUN sistema/generico/procedures/b1wgen0157.p
                            PERSISTENT SET h-b1wgen0157.

                    RUN validar-rating-bndes IN h-b1wgen0157
                                        (INPUT glb_cdcooper,
                                         INPUT glb_cdoperad,
                                         INPUT glb_nmdatela,
                                         INPUT glb_inproces,
                                         INPUT 1,   /* Ayllos */ 
                                         INPUT tel_nrdconta,
                                         INPUT tt-associado.inpessoa,
                                         INPUT tt-associado.nrcpfcgc,
                                         INPUT glb_dtmvtolt,
                                         INPUT aux_inconfir,
                                         INPUT aux_inconfi2,
                                         INPUT "I",
                                         /* Parametros da Tela */
                                         INPUT tel_vlempbnd,
                                         INPUT tel_qtparbnd,
                                         INPUT tel_nrinfcad,
                                         INPUT tel_nrgarope,
                                         INPUT tel_nrliquid,
                                         INPUT tel_nrpatlvr,
                                         INPUT tel_nrperger,
                                         INPUT 0,
                                        OUTPUT aux_nrctrato,
                                        OUTPUT aux_dsdrisco,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-msg-confirma,
                                        OUTPUT TABLE tt-grupo).

                    IF  VALID-HANDLE(h-b1wgen0157) THEN
                        DELETE PROCEDURE h-b1wgen0157.
    
                    ASSIGN aux_qtctarel = 0.


                    IF  RETURN-VALUE <> "OK" THEN DO:

                        ASSIGN aux_flgvalid = FALSE.

                        FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.
            
                        /* Atingiu Valor Maximo LEGAL, mostra contas
                          do grupo economico quando existir, e
                          ABORTA operacao */
                        IF  AVAIL tt-msg-confirma   THEN DO: 

                            MESSAGE tt-msg-confirma.dsmensag.
                            
                            ASSIGN aux_qtctarel = 0
                                   aux_flgsuces = FALSE.
            
                            /*Se a conta em questao faz parte de um
                              grupo economico, serao
                              listados as contas que se relacionam
                              com a mesma.*/
                            IF TEMP-TABLE 
                                tt-grupo:HAS-RECORDS
                            AND tt-msg-confirma.inconfir = 3 THEN
                               DO:                           
                                   ASSIGN aux_qtctarel = 0.

                                   FOR EACH tt-grupo
                                       NO-LOCK:
            
                                       ASSIGN aux_qtctarel = 
                                              aux_qtctarel + 1.
            
                                   END.
            
                                   DO WHILE TRUE ON ENDKEY UNDO,
                                      LEAVE:
                                   
                                       DISP tel_nrdconta
                                            aux_qtctarel
                                            WITH FRAME f_ge_economico.
            
                                       OPEN QUERY q-ge-economico 
                                         FOR EACH tt-grupo
                                             NO-LOCK.

                                       UPDATE b-ge-economico
                                         WITH FRAME f_ge_economico.

                                       LEAVE.

                                   END.

                                   CLOSE QUERY q-ge-economico.
                                   HIDE FRAME f_ge_economico. 
                            END. /* END do IF do Grupo Economico */
                        END. /* END do AVAIL tt-msg-confirma */


                        /* Exibe demais erros, aborta operacao */ 
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                           IF   AVAIL tt-erro   THEN
                                MESSAGE tt-erro.dscritic.
                           ELSE
                                MESSAGE 
                                   "Erro na validaçao da proposta.".

                           PAUSE 3 NO-MESSAGE.
                           ASSIGN aux_flgsuces = FALSE.
                           LEAVE.

                        END.

                        LEAVE. /* LEAVE do LOOP validar-rating-bndes */

                    END. /* END do RETURN-VALUE <> "OK" */

                    /* Verifica se atingiu Valor Maximo Utilizado
                       (aux_inconfir = 2), neste caso, necessaria
                       confirmacao para prosseguir com a operacao. 
                    */ 
                    FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.

                    /* Se tem mensagem de confirmacao e foi RETURN "OK" */
                    IF  AVAIL tt-msg-confirma  THEN DO:
                        RUN fontes/confirma.p
                             ( INPUT tt-msg-confirma.dsmensag,
                              OUTPUT aux_confirm2).
            
                        IF  aux_confirm2 <> "S"   THEN DO:
                            ASSIGN aux_flgsuces = FALSE
                                   aux_flgvalid = FALSE.
                            LEAVE.
                            /* LEAVE do LOOP validar-rating-bndes */
                        END.
                        ELSE DO:
                            ASSIGN aux_inconfir = 3
                                    aux_inconfi2 = 30.
                            NEXT.
                            /* NEXT do LOOP do validar-rating-bndes */
                        END.
                    END.
                    ELSE DO:
                        /* Se nao houve criticas com
                           aux_inconfir = 2 e aux_inconfir = 3,
                           mostra contas do grupo economico quando 
                           existir e finaliza operacao */     
                        IF   aux_inconfir = 3 THEN DO:
                             
                             ASSIGN aux_flgsuces = TRUE
                                    aux_flgvalid = TRUE.
                        
                             IF  TEMP-TABLE
                                 tt-grupo:HAS-RECORDS THEN DO:

                                     ASSIGN aux_qtctarel = 0.
                        
                                     FOR EACH tt-grupo
                                         NO-LOCK:
                        
                                         ASSIGN aux_qtctarel = 
                                                aux_qtctarel + 1.
                        
                                     END.
                        
                                     DO WHILE TRUE ON ENDKEY UNDO,
                                        LEAVE:
                                     
                                         DISP tel_nrdconta
                                              aux_qtctarel
                                              WITH FRAME f_ge_economico.
                        
                                         OPEN QUERY q-ge-economico 
                                           FOR EACH tt-grupo
                                               NO-LOCK.
                        
                                         UPDATE b-ge-economico
                                           WITH FRAME f_ge_economico.
                        
                                         LEAVE.
                        
                                     END.
                        
                                     CLOSE QUERY q-ge-economico.
                                     HIDE FRAME f_ge_economico.
                             END. /* END do IF Grupo Economico */

                             LEAVE.
                             /* LEAVE do LOOP validar-rating-bndes */
                        END.
                        ELSE DO:
                        /* Se nao criticou Valor Maximo Utilizado
                           (aux_inconfirm = 2), passa variavel 
                           aux_inconfir = 3 para validar Valor
                           Maximo Legal */ 

                            ASSIGN aux_inconfir = 3.
                            NEXT.
                            /* NEXT do LOOP do validar-rating-bndes */
                        END.
                    END. /* FIM ELSE DO:... tt-msg-confirma */

                    LEAVE.

                END. /* FIM do DO WHILE TRANSACTION do validar-rating-bndes */

                LEAVE.  /* LEAVE do LOOP dos updates */

            END. /* FIM do DO WHILE TRUE dos UPDATES*/



            IF  aux_flgvalid THEN DO:

                ASSIGN aux_flgsuces = FALSE.
    
                DO TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    
                    IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                        RUN sistema/generico/procedures/b1wgen0157.p
                                PERSISTENT SET h-b1wgen0157.
    
                        RUN incluir-rating-bndes IN h-b1wgen0157
                                            (INPUT glb_cdcooper,
                                             INPUT glb_cdoperad,
                                             INPUT glb_nmdatela,
                                             INPUT glb_inproces,
                                             INPUT 1,   /* Ayllos */ 
                                             INPUT tel_nrdconta,
                                             INPUT tt-associado.inpessoa,
                                             INPUT tt-associado.nrcpfcgc,
                                             INPUT glb_dtmvtolt,
                                             INPUT aux_inconfir,
                                             INPUT aux_inconfi2,
                                             /* Parametros da Tela */
                                             INPUT tel_vlempbnd,
                                             INPUT tel_qtparbnd,
                                             INPUT tel_nrinfcad,
                                             INPUT tel_nrgarope,
                                             INPUT tel_nrliquid,
                                             INPUT tel_nrpatlvr,
                                             INPUT tel_nrperger,
                                             INPUT INT(aux_nrctrato),
                                            OUTPUT aux_nrctrato,
                                            OUTPUT aux_dsdrisco,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-msg-confirma,
                                            OUTPUT TABLE tt-grupo).
            
                        IF  VALID-HANDLE(h-b1wgen0157) THEN
                            DELETE PROCEDURE h-b1wgen0157.
    
    
                        IF   RETURN-VALUE <> "OK" THEN DO:
    
                             ASSIGN aux_flgsuces = FALSE.
    
                             FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                             IF   AVAILABLE tt-erro   THEN
                                  MESSAGE tt-erro.dscritic.
                             ELSE
                                  MESSAGE "Erro na validacao dos campos do " +
                                          "Rating.".
        
                             PAUSE 2 NO-MESSAGE.
                             UNDO.
                        END.
                        ELSE 
                            ASSIGN aux_flgsuces = TRUE.
                END. /* FIM do TRANSACTION do incluir-rating-bndes */
            END.


            IF  aux_flgsuces THEN DO:
            
                MESSAGE "RISCO PROPOSTO:"  aux_dsdrisco 
                        ". Contrato: " aux_nrctrato.
                PAUSE.
                
                MESSAGE "Inclusao realizada com sucesso!".
                PAUSE 2 NO-MESSAGE.

                ASSIGN aux_flgsuces = FALSE
                       aux_flgvalid = FALSE.
            END.            

       END. /** END do WHEN "I" **/


       WHEN "E" THEN DO: /* Efetiva Rating Proposto */
            HIDE FRAME f_ratbnd_info.
            HIDE FRAME f_craprad.
            HIDE FRAME f_brw_relat.
            HIDE FRAME f_contratos.
            HIDE FRAME f_ratbnd_relat.
            HIDE FRAME f_param_rel_sem.
            HIDE FRAME f_param_rel_com.
            HIDE FRAME f_analise_proposta.
            HIDE FRAME f_criticas.
            HIDE FRAME f_alertas.
            HIDE FRAME f_ge_economico.
            HIDE FRAME f_ge_epr.
            HIDE FRAME f_ratbnd_browse.
            HIDE MESSAGE NO-PAUSE.

            CLEAR FRAME f_ratbnd_2.
            CLEAR FRAME f_ratbnd_info.
            tel_nrctrato:LIST-ITEMS = "". 

            ASSIGN tel_nrdconta = 0
                   tel_vlempbnd = 0
                   tel_nmprimtl = ""
                   tel_nrctrato = ""
                   glb_cdcritic = 0
                   aux_contador = 0
                   tel_vlempbnd = 0
                   tel_qtparbnd = 0
                   tel_nrinfcad = 0
                   tel_nrgarope = 0
                   tel_nrliquid = 0
                   tel_nrpatlvr = 0
                   tel_nrperger = 0
                   tel_nmprimtl = ""
                   tel_dsinfcad = ""
                   tel_dsgarope = ""
                   tel_dsliquid = ""
                   tel_dspatlvr = ""
                   tel_dsperger = ""
                   tel_nrctrato:SCREEN-VALUE = "". /* Limpa SCREEN-VALUE */
             
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                NEXT.

            DO WHILE TRUE:
                /* Informe o nrdconta do Associado */
                UPDATE tel_nrdconta WITH FRAME f_ratbnd_info.

                ASSIGN INPUT tel_nrdconta.

                IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                    RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
    
                RUN dig_fun IN h-b1wgen9999 
                          ( INPUT glb_cdcooper,
                            INPUT glb_cdagenci,
                            INPUT 0,
                            INPUT-OUTPUT tel_nrdconta,
                           OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen9999) THEN
                    DELETE PROCEDURE h-b1wgen9999.
    
                IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAIL tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                                ASSIGN tel_nrdconta = 0.
                                CLEAR FRAME f_ratbnd_info NO-PAUSE.
                                NEXT.
                             END.
                END.


                IF  NOT VALID-HANDLE(h-b1wgen0040) THEN
                    RUN sistema/generico/procedures/b1wgen0040.p
                        PERSISTENT SET h-b1wgen0040.
    
                RUN verifica-conta IN h-b1wgen0040
                                   ( INPUT glb_cdcooper,
                                     INPUT glb_cdagenci,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_nmdatela,
                                     INPUT 1,
                                     INPUT tel_nrdconta,
                                     INPUT 0,
                                     INPUT YES,
                                    OUTPUT tel_nmprimtl, 
                                    OUTPUT par_qtrequis, 
                                    OUTPUT par_dsmsgcnt, 
                                    OUTPUT TABLE tt-erro ).
    
                IF  VALID-HANDLE(h-b1wgen0040) THEN
                    DELETE PROCEDURE h-b1wgen0040.

                IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAIL tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                                CLEAR FRAME f_ratbnd_info NO-PAUSE.
                                NEXT.
                            END.
                    END.

    
                /* Busca dados Cooperado */
                IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                    RUN sistema/generico/procedures/b1wgen0157.p
                        PERSISTENT SET h-b1wgen0157.
    
                RUN busca_dados_associado IN h-b1wgen0157
                                   ( INPUT glb_cdcooper,
                                     INPUT tel_nrdconta,
                                    OUTPUT TABLE tt-associado,
                                    OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0157) THEN
                    DELETE PROCEDURE h-b1wgen0157.

                IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAIL tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                                CLEAR FRAME f_ratbnd_info NO-PAUSE.
                                NEXT.
                            END.
                    END.

                FIND FIRST tt-associado NO-LOCK NO-ERROR.
                tel_nmprimtl = tt-associado.nmprimtl.

                LEAVE.
            END.

            DISPLAY tel_nmprimtl WITH FRAME f_ratbnd_info.



            /* SELECTION-LIST dos Contratos do Associado Pesquisado */
            IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                RUN sistema/generico/procedures/b1wgen0157.p
                    PERSISTENT SET h-b1wgen0157.

            RUN retorna_contratos_bndes IN h-b1wgen0157
                                (INPUT glb_cdcooper,
                                 INPUT tel_nrdconta,
                                 INPUT glb_cddopcao,
                                OUTPUT TABLE tt-ctrbndes,
                                OUTPUT TABLE tt-erro).

            IF  VALID-HANDLE(h-b1wgen0157) THEN
                DELETE PROCEDURE h-b1wgen0157.

            IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    IF  AVAIL tt-erro  THEN
                        DO:
                            MESSAGE tt-erro.dscritic.
                            CLEAR FRAME f_ratbnd_info NO-PAUSE.
                            NEXT.
                        END.
                END.


            aux_nrctrato = "".
            FOR EACH tt-ctrbndes NO-LOCK:

                IF   aux_contador = 0 THEN
                     ASSIGN aux_nrctrato = STRING(tt-ctrbndes.nrctrato)
                            aux_contador = 1.
                ELSE
                    ASSIGN aux_nrctrato = aux_nrctrato + "," +
                                          STRING(tt-ctrbndes.nrctrato).
                           aux_contador = aux_contador + 1.
            END.



            IF  tt-associado.inpessoa = 1 THEN DO:
                HIDE tel_nrperger tel_dsperger IN FRAME f_analise_proposta.
                tel_dspatrim = "        Patr. pessoal livre:".
            END.
            ELSE DO:
                VIEW tel_nrperger tel_dsperger IN FRAME f_analise_proposta.
                tel_dspatrim = "Patr. garant./sócios s/onus:".
            END.



            ON  RETURN OF tel_nrctrato DO:

                ASSIGN tel_nrctrato = tel_nrctrato:SCREEN-VALUE.

                IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                    RUN sistema/generico/procedures/b1wgen0157.p
                        PERSISTENT SET h-b1wgen0157.

                RUN consultar-rating-bndes IN h-b1wgen0157
                               (INPUT glb_cdcooper,
                                INPUT glb_cdoperad,
                                INPUT glb_nmdatela,
                                INPUT glb_inproces,
                                INPUT glb_dtmvtolt,
                                INPUT tel_nrdconta,
                                INPUT tt-associado.inpessoa,
                                INPUT tt-associado.nrcpfcgc,
                                INPUT glb_cdagenci,
                                INPUT INT(tel_nrctrato),
                                INPUT "E",
                               OUTPUT tel_vlempbnd,
                               OUTPUT tel_qtparbnd,
                               OUTPUT tel_nrinfcad,
                               OUTPUT tel_dsinfcad,
                               OUTPUT tel_nrgarope,
                               OUTPUT tel_dsgarope,
                               OUTPUT tel_nrliquid,
                               OUTPUT tel_dsliquid,
                               OUTPUT tel_nrpatlvr,
                               OUTPUT tel_dspatlvr,
                               OUTPUT tel_nrperger,
                               OUTPUT tel_dsperger,
                               OUTPUT aux_insitrat,
                               OUTPUT aux_dssitcrt,
                               OUTPUT TABLE tt-erro).

                IF  VALID-HANDLE(h-b1wgen0157) THEN
                    DELETE PROCEDURE h-b1wgen0157.

                IF  RETURN-VALUE <> "OK" THEN DO:

                    IF  NOT CAN-FIND(FIRST tt-erro WHERE tt-erro.nrsequen > 1)
                        THEN DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.

                            BELL.
                            IF  AVAILABLE tt-erro  THEN DO:
                                MESSAGE tt-erro.dscritic.
                            END.
                            ELSE
                                MESSAGE "Erro na efetivacao da proposta.".

                            PAUSE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            FIND tt-erro WHERE tt-erro.cdcritic = 830
                                 NO-LOCK NO-ERROR.
                    
                            BELL.
                            /** Faltam dados cadastrais **/
                            IF  AVAILABLE tt-erro  THEN
                                MESSAGE tt-erro.dscritic.
                            ELSE
                                MESSAGE "Erro na efetivacao da proposta.".
                    
                            /** Mostrar todas as criticas para os usuarios **/
                            DOWN 4 WITH FRAME f_criticas.
                            FOR EACH tt-erro WHERE tt-erro.cdcritic <> 830
                                NO-LOCK:
                    
                                DISPLAY tt-erro.dscritic WITH FRAME f_criticas.
                                DOWN WITH FRAME f_criticas.
                    
                            END. /** Fim do FOR EACH tt-erro **/

                            PAUSE.
                            HIDE MESSAGE NO-PAUSE.
                            HIDE FRAME f_criticas.
                            NEXT.
                    END.

                    HIDE FRAME f_criticas.
                    HIDE FRAME f_analise_proposta.
                    HIDE FRAME f_ratbnd_browse.
                    NEXT.
                END.

                APPLY "GO".

            END.

            ASSIGN tel_nrctrato:LIST-ITEMS = aux_nrctrato.

            UPDATE tel_nrctrato WITH FRAME f_ratbnd_info.



            DISPLAY tel_dspatrim
               WITH FRAME f_analise_proposta.

            tel_nrctrato:SCREEN-VALUE = tel_nrctrato.

            DISPLAY tel_nrctrato tel_vlempbnd
                    tel_qtparbnd WITH FRAME f_ratbnd_info.

            DISPLAY tel_nrinfcad tel_dsinfcad
                    tel_nrgarope tel_dsgarope
                    tel_nrliquid tel_dsliquid
                    tel_nrpatlvr tel_dspatlvr
                    tel_nrperger WHEN tt-associado.inpessoa = 2
                    tel_dsperger WHEN tt-associado.inpessoa = 2
               WITH FRAME f_analise_proposta.


            aux_confirma = FALSE.
            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                MESSAGE COLOR NORMAL 
                   "078 - Confirma efetivacao proposta BNDES? (S/N)"
                   UPDATE aux_confirma.
                LEAVE.
            END.
            
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 NOT aux_confirma THEN DO:
                 BELL.
                 MESSAGE "Proposta BNDES nao efetivada!".
                 PAUSE 2 NO-MESSAGE.
                 NEXT.
            END.

            IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                RUN sistema/generico/procedures/b1wgen0157.p
                    PERSISTENT SET h-b1wgen0157.

            RUN efetivar-rating-bndes IN h-b1wgen0157(INPUT glb_cdcooper,
                                                      INPUT glb_cdoperad,
                                                      INPUT glb_nmdatela,
                                                      INPUT glb_inproces,
                                                      INPUT tel_nrdconta,
                                                      INPUT INT(tel_nrctrato),
                                                      INPUT glb_dtmvtolt,
                                                      INPUT glb_dtmvtopr,
                                                     OUTPUT aux_dsdrisco,
                                                     OUTPUT TABLE tt-erro).
            IF  VALID-HANDLE(h-b1wgen0157) THEN
                DELETE PROCEDURE h-b1wgen0157.

            IF  RETURN-VALUE <> "OK" THEN DO:

                IF  NOT CAN-FIND(FIRST tt-erro WHERE tt-erro.nrsequen > 1) THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                        BELL.
                        IF  AVAILABLE tt-erro  THEN
                            MESSAGE tt-erro.dscritic.
                        ELSE
                            MESSAGE "Erro na efetivacao da proposta.".

                        PAUSE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        FIND tt-erro WHERE tt-erro.cdcritic = 830
                             NO-LOCK NO-ERROR.

                        BELL.
                        /** Faltam dados cadastrais **/
                        IF  AVAILABLE tt-erro  THEN
                            MESSAGE tt-erro.dscritic.
                        ELSE
                            MESSAGE "Erro na efetivacao da proposta.".

                        /** Mostrar todas as criticas para os usuarios **/
                        DOWN 4 WITH FRAME f_criticas.
                        FOR EACH tt-erro WHERE tt-erro.cdcritic <> 830 NO-LOCK:
                
                            DISPLAY tt-erro.dscritic WITH FRAME f_criticas.
                            DOWN WITH FRAME f_criticas.
                
                        END. /** Fim do FOR EACH tt-erro **/
                        PAUSE.
                        HIDE FRAME f_criticas.
                        NEXT.
                END.

                HIDE FRAME f_criticas.
                HIDE FRAME f_analise_proposta.
                HIDE FRAME f_ratbnd_browse.
                NEXT.
            END.

            /* Exibe o RISCO na tela */
            MESSAGE "RISCO EFETIVO:" aux_dsdrisco.
            PAUSE.
            MESSAGE "Efetivacao realizada com sucesso!".
            PAUSE 2 NO-MESSAGE.
            NEXT.

       END. /** FIM do WHEN "E" **/
    
    
       WHEN "A" THEN DO: /* Alterar Rating Proposto */
            HIDE FRAME f_ratbnd_info.
            HIDE FRAME f_craprad.
            HIDE FRAME f_brw_relat.
            HIDE FRAME f_contratos.
            HIDE FRAME f_ratbnd_relat.
            HIDE FRAME f_param_rel_sem.
            HIDE FRAME f_param_rel_com.
            HIDE FRAME f_analise_proposta.
            HIDE FRAME f_criticas.
            HIDE FRAME f_alertas.
            HIDE FRAME f_ge_economico.
            HIDE FRAME f_ge_epr.
            HIDE FRAME f_ratbnd_browse.
            HIDE MESSAGE NO-PAUSE.
            
            CLEAR FRAME f_ratbnd_2.
            CLEAR FRAME f_ratbnd_info.
            CLEAR FRAME f_analise_proposta.
            CLEAR FRAME f_criticas.
            tel_nrctrato:LIST-ITEMS = "". 
    
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                NEXT.

            EMPTY TEMP-TABLE tt-erro.
            EMPTY TEMP-TABLE tt-msg-confirma.
            EMPTY TEMP-TABLE tt-grupo.

            DO WHILE TRUE:
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                    NEXT.

                EMPTY TEMP-TABLE tt-erro.

                /* Informe o nrdconta do Associado */
                UPDATE tel_nrdconta WITH FRAME f_ratbnd_info.

                IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                    RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
    
                RUN dig_fun IN h-b1wgen9999 
                          ( INPUT glb_cdcooper,
                            INPUT glb_cdagenci,
                            INPUT 0,
                            INPUT-OUTPUT tel_nrdconta,
                           OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen9999) THEN
                    DELETE PROCEDURE h-b1wgen9999.
    
                IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAIL tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                                ASSIGN tel_nrdconta = 0.
                                PAUSE 2 NO-MESSAGE.
                                CLEAR FRAME f_ratbnd_info NO-PAUSE.
                                NEXT.
                            END.
                END.


                IF  NOT VALID-HANDLE(h-b1wgen0040) THEN
                    RUN sistema/generico/procedures/b1wgen0040.p
                        PERSISTENT SET h-b1wgen0040.
    
                RUN verifica-conta IN h-b1wgen0040
                                   ( INPUT glb_cdcooper,
                                     INPUT glb_cdagenci,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_nmdatela,
                                     INPUT 1,
                                     INPUT tel_nrdconta,
                                     INPUT 0,
                                     INPUT YES,
                                    OUTPUT tel_nmprimtl, 
                                    OUTPUT par_qtrequis, 
                                    OUTPUT par_dsmsgcnt, 
                                    OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0040) THEN
                    DELETE PROCEDURE h-b1wgen0040.

                IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAIL tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                                PAUSE 2 NO-MESSAGE.
                                CLEAR FRAME f_ratbnd_info NO-PAUSE.
                                NEXT.
                            END.
                    END.

    
                /* Busca dados Cooperado */
                IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                    RUN sistema/generico/procedures/b1wgen0157.p
                        PERSISTENT SET h-b1wgen0157.
    
                RUN busca_dados_associado IN h-b1wgen0157
                                   ( INPUT glb_cdcooper,
                                     INPUT tel_nrdconta,
                                    OUTPUT TABLE tt-associado,
                                    OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0157) THEN
                    DELETE PROCEDURE h-b1wgen0157.

                IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAIL tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                                PAUSE 2 NO-MESSAGE.
                                CLEAR FRAME f_ratbnd_info NO-PAUSE.
                                NEXT.
                            END.
                    END.

                FIND FIRST tt-associado NO-LOCK NO-ERROR.
                tel_nmprimtl = tt-associado.nmprimtl.

                LEAVE.
            END. /* END do DO WHILE TRUE tel_nrdconta */


            DISPLAY tel_nmprimtl WITH FRAME f_ratbnd_info.

            IF  NOT VALID-HANDLE(h-b1wgen0043) THEN
                RUN sistema/generico/procedures/b1wgen0043.p
                    PERSISTENT SET h-b1wgen0043.
        
            RUN itens_topicos_rating IN h-b1wgen0043
                                   (INPUT glb_cdcooper,
                                   OUTPUT TABLE tt-itens-topico-rating,
                                   OUTPUT TABLE tt-erro).

            IF  VALID-HANDLE(h-b1wgen0043) THEN
                DELETE PROCEDURE h-b1wgen0043.
        
            IF   RETURN-VALUE <> "OK"   THEN
                 DO: 
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                     IF   AVAIL tt-erro   THEN
                          MESSAGE tt-erro.dscritic.
                     ELSE
                          MESSAGE "Erro na busca dos itens/topicos do Rating.".
            
                     PAUSE 2 NO-MESSAGE.
                     RETURN.
                 END.




            /* SELECTION-LIST dos Contratos do Associado Pesquisado */
            IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                RUN sistema/generico/procedures/b1wgen0157.p
                    PERSISTENT SET h-b1wgen0157.

            RUN retorna_contratos_bndes IN h-b1wgen0157
                                (INPUT glb_cdcooper,
                                 INPUT tel_nrdconta,
                                 INPUT glb_cddopcao,
                                OUTPUT TABLE tt-ctrbndes,
                                OUTPUT TABLE tt-erro).

            IF  VALID-HANDLE(h-b1wgen0157) THEN
                DELETE PROCEDURE h-b1wgen0157.

            IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    IF  AVAIL tt-erro  THEN
                        DO:
                            MESSAGE tt-erro.dscritic.
                            CLEAR FRAME f_ratbnd_info NO-PAUSE.
                            NEXT.
                        END.
                END.


            aux_nrctrato = "".
            FOR EACH tt-ctrbndes NO-LOCK:

                IF   aux_contador = 0 THEN
                     ASSIGN aux_nrctrato = STRING(tt-ctrbndes.nrctrato)
                            aux_contador = 1.
                ELSE
                    ASSIGN aux_nrctrato = aux_nrctrato + "," +
                                          STRING(tt-ctrbndes.nrctrato).
                           aux_contador = aux_contador + 1.
            END.

                              

            ON  RETURN OF tel_nrctrato DO:

                ASSIGN tel_nrctrato = tel_nrctrato:SCREEN-VALUE.

                IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                    RUN sistema/generico/procedures/b1wgen0157.p
                        PERSISTENT SET h-b1wgen0157.

                RUN consultar-rating-bndes IN h-b1wgen0157
                               (INPUT glb_cdcooper,
                                INPUT glb_cdoperad,
                                INPUT glb_nmdatela,
                                INPUT glb_inproces,
                                INPUT glb_dtmvtolt,
                                INPUT tel_nrdconta,
                                INPUT tt-associado.inpessoa,
                                INPUT tt-associado.nrcpfcgc,
                                INPUT glb_cdagenci,
                                INPUT INT(tel_nrctrato),
                                INPUT "A",
                               OUTPUT tel_vlempbnd,
                               OUTPUT tel_qtparbnd,
                               OUTPUT tel_nrinfcad,
                               OUTPUT tel_dsinfcad,
                               OUTPUT tel_nrgarope,
                               OUTPUT tel_dsgarope,
                               OUTPUT tel_nrliquid,
                               OUTPUT tel_dsliquid,
                               OUTPUT tel_nrpatlvr,
                               OUTPUT tel_dspatlvr,
                               OUTPUT tel_nrperger,
                               OUTPUT tel_dsperger,
                               OUTPUT aux_insitrat,
                               OUTPUT aux_dssitcrt, /* Proposto/Efetivo */
                               OUTPUT TABLE tt-erro).

                IF  VALID-HANDLE(h-b1wgen0157) THEN
                    DELETE PROCEDURE h-b1wgen0157.

                IF  RETURN-VALUE <> "OK" THEN DO:

                    IF  NOT CAN-FIND(FIRST tt-erro WHERE tt-erro.nrsequen > 1)
                    THEN DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                            BELL.
                            IF  AVAILABLE tt-erro  THEN DO:
                                MESSAGE tt-erro.dscritic.
                            END.
                            ELSE
                                MESSAGE "Erro na efetivacao da proposta.".

                            PAUSE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            FIND tt-erro WHERE tt-erro.cdcritic = 830
                                 NO-LOCK NO-ERROR.

                            BELL.
                            /** Faltam dados cadastrais **/
                            IF  AVAILABLE tt-erro  THEN
                                MESSAGE tt-erro.dscritic.
                            ELSE
                                MESSAGE "Erro na efetivacao da proposta.".
                    
                            /** Mostrar todas as criticas para os usuarios **/
                            DOWN 4 WITH FRAME f_criticas.
                            FOR EACH tt-erro WHERE tt-erro.cdcritic <> 830
                                  NO-LOCK:
                    
                                DISPLAY tt-erro.dscritic WITH FRAME f_criticas.
                                DOWN WITH FRAME f_criticas.
                    
                            END. /** Fim do FOR EACH tt-erro **/

                            PAUSE.
                            HIDE FRAME f_criticas.
                            NEXT.
                    END.
                    HIDE FRAME f_criticas.
                    NEXT.
                END.

                APPLY "GO".
            END. /* END do ON RETURN tel_nrctrato */


            ASSIGN tel_nrctrato:LIST-ITEMS = aux_nrctrato.
                          
            UPDATE tel_nrctrato WITH FRAME f_ratbnd_info.
            tel_nrctrato:SCREEN-VALUE = tel_nrctrato.

            DISPLAY tel_nrctrato tel_vlempbnd
                    tel_qtparbnd WITH FRAME f_ratbnd_info.

            IF  tt-associado.inpessoa = 1 THEN DO:
                HIDE tel_nrperger tel_dsperger
                     IN FRAME f_analise_proposta.
                tel_dspatrim = "        Patr. pessoal livre:".
            END.
            ELSE DO:
                VIEW tel_nrperger tel_dsperger
                     IN FRAME f_analise_proposta.
                tel_dspatrim = "Patr. garant./sócios s/onus:".
            END.
            DISPLAY tel_dspatrim
                    WITH FRAME f_analise_proposta.

            DISPLAY tel_nrinfcad tel_dsinfcad
                    tel_nrgarope tel_dsgarope
                    tel_nrliquid tel_dsliquid
                    tel_nrpatlvr tel_dspatlvr
                    tel_nrperger WHEN tt-associado.inpessoa = 2
                    tel_dsperger WHEN tt-associado.inpessoa = 2
               WITH FRAME f_analise_proposta.


            /* LOOP dos campos de parametros */
            DO WHILE TRUE:

                EMPTY TEMP-TABLE tt-erro.
                EMPTY TEMP-TABLE tt-msg-confirma.
                EMPTY TEMP-TABLE tt-grupo.
                
                HIDE FRAME f_criticas.
                HIDE FRAME f_alertas.

                UPDATE tel_vlempbnd
                       tel_qtparbnd WITH FRAME f_ratbnd_info.
            
                UPDATE tel_nrinfcad
                       tel_nrgarope 
                       tel_nrliquid
                       tel_nrpatlvr
                       tel_nrperger WHEN tt-associado.inpessoa = 2
                       WITH FRAME f_analise_proposta
                    EDITING:
    
                     READKEY.
    
                     IF   LASTKEY = KEYCODE("F7")   THEN DO:
                         /* Atribuir já os valores modificados */
                          DO WITH FRAME f_analise_proposta:
    
                             ASSIGN tel_nrgarope
                                    tel_nrinfcad
                                    tel_nrliquid
                                    tel_nrpatlvr
                                    tel_nrperger.
                          END.
    
                          IF  FRAME-FIELD = "tel_nrinfcad"   THEN DO:
                              b-craprad:HELP = "Pressione <ENTER> p/ " +
                                               "selecionar as " +
                                               "informacoes cadastrais.".
        
                              IF   tt-associado.inpessoa = 1 THEN
                                   RUN sequencia_rating 
                                            (INPUT 1,
                                             INPUT 4,
                                      INPUT-OUTPUT tel_nrinfcad,
                                      INPUT-OUTPUT tel_dsinfcad).
                              ELSE
                                   RUN sequencia_rating
                                            (INPUT 3,
                                             INPUT 3,
                                      INPUT-OUTPUT tel_nrinfcad,
                                      INPUT-OUTPUT tel_dsinfcad).
        
                              DISPLAY tel_nrinfcad 
                                      tel_dsinfcad
                                      WITH FRAME f_analise_proposta.
                          END.
                          ELSE
                          IF   FRAME-FIELD = "tel_nrgarope"   THEN
                               DO:
                                   b-craprad:HELP =
                                       "Pressione <ENTER> p/ " +
                                       "selecionar a garantia.".
                                       
                                   IF   tt-associado.inpessoa = 1   THEN
                                        RUN sequencia_rating
                                               (INPUT 2,
                                                INPUT 2,
                                         INPUT-OUTPUT tel_nrgarope,
                                         INPUT-OUTPUT tel_dsgarope).
                                   ELSE
                                        RUN sequencia_rating 
                                               (INPUT 4,
                                                INPUT 2,
                                         INPUT-OUTPUT tel_nrgarope,
                                         INPUT-OUTPUT tel_dsgarope).
                  
                                   DISPLAY tel_nrgarope
                                           tel_dsgarope    
                                           WITH FRAME f_analise_proposta.
                          END.
                          ELSE
                          IF   FRAME-FIELD = "tel_nrliquid"   THEN
                               DO:
                                   b-craprad:HELP = "Pressione <ENTER> p/"
                                                    + " selecionar a " +
                                                 "liquidez das garantias.".
                          
                                   IF   tt-associado.inpessoa = 1   THEN
                                        RUN sequencia_rating 
                                               (INPUT 2,
                                                INPUT 3,
                                         INPUT-OUTPUT tel_nrliquid,
                                         INPUT-OUTPUT tel_dsliquid).
                                   ELSE
                                        RUN sequencia_rating
                                               (INPUT 4,
                                                INPUT 3,
                                         INPUT-OUTPUT tel_nrliquid,
                                         INPUT-OUTPUT tel_dsliquid).
                              
                                   DISPLAY tel_nrliquid
                                           tel_dsliquid
                                           WITH FRAME f_analise_proposta.
                          END.
                          ELSE
                          IF   FRAME-FIELD = "tel_nrpatlvr"   THEN
                               DO:
                                   b-craprad:HELP = "Pressione <ENTER> p/"
                                                + " selecionar " +
                                                  "o patrimonio pessoal.".
                                      
                                   IF   tt-associado.inpessoa = 1   THEN
                                        RUN sequencia_rating 
                                               (INPUT 1,
                                                INPUT 8,
                                         INPUT-OUTPUT tel_nrpatlvr,
                                         INPUT-OUTPUT tel_dspatlvr).
                                   ELSE
                                        RUN sequencia_rating
                                               (INPUT 3,
                                                INPUT 9,
                                         INPUT-OUTPUT tel_nrpatlvr,
                                         INPUT-OUTPUT tel_dspatlvr).
                                  
                                   DISPLAY tel_nrpatlvr
                                           tel_dspatlvr
                                           WITH FRAME f_analise_proposta.
                          END.
                          ELSE
                          IF   FRAME-FIELD = "tel_nrperger"   THEN
                               DO:
                                   b-craprad:HELP = "Pressione <ENTER> p/"
                                                  + " selecionar " +
                                                    "a percepcao geral.".
                                    
                                   RUN sequencia_rating 
                                                 (INPUT 3,
                                                  INPUT 11,
                                           INPUT-OUTPUT tel_nrperger,
                                           INPUT-OUTPUT tel_dsperger).
                                    
                                   DISPLAY tel_nrperger
                                           tel_dsperger 
                                           WITH FRAME f_analise_proposta.
                          END.
                          ELSE
                              APPLY LASTKEY.
                     END. /* Fim do F7 */
                     ELSE
                        APPLY LASTKEY.
                    END. /* Fim do Editing */


                /* Validar campos do RATING */
                IF  NOT VALID-HANDLE(h-b1wgen0043) THEN
                    RUN sistema/generico/procedures/b1wgen0043.p
                        PERSISTENT SET h-b1wgen0043.

                IF   NOT VALID-HANDLE(h-b1wgen0043)   THEN
                     DO:
                         MESSAGE "Handle invalido para a BO b1wgen0043.".
                         PAUSE 2 NO-MESSAGE.
                         NEXT.
                     END.
    
                RUN valida-itens-rating IN h-b1wgen0043 
                                (INPUT  glb_cdcooper,
                                 INPUT  0,
                                 INPUT  0,
                                 INPUT  glb_cdoperad,
                                 INPUT  glb_dtmvtolt,
                                 INPUT  tel_nrdconta,
                                 INPUT  tel_nrgarope,
                                 INPUT  tel_nrinfcad,
                                 INPUT  tel_nrliquid,
                                 INPUT  tel_nrpatlvr,
                                 INPUT  tel_nrperger,
                                 INPUT  1, /* Titular */
                                 INPUT  1, /* Ayllos*/
                                 INPUT  glb_nmdatela,
                                 INPUT  FALSE,
                                OUTPUT TABLE tt-erro).
    
                IF  VALID-HANDLE(h-b1wgen0043) THEN
                    DELETE PROCEDURE h-b1wgen0043.
    
                IF   RETURN-VALUE <> "OK"   THEN
                     DO:
                        ASSIGN aux_flgvalid = FALSE.
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                        IF   AVAILABLE tt-erro   THEN
                             MESSAGE tt-erro.dscritic.
                        ELSE
                             MESSAGE "Erro na validacao dos campos do " +
                                     "Rating.".
    
                        PAUSE 2 NO-MESSAGE.
                        NEXT.   
                END.
                

                aux_confirma = FALSE.
                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE COLOR NORMAL 
                       "078 - Confirma alteracao proposta BNDES? (S/N)"
                       UPDATE aux_confirma.
                    LEAVE.
                END.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    NOT aux_confirma THEN DO:
                    BELL.
                    MESSAGE "Alteracao proposta BNDES nao efetuada!".
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
    
    
                ASSIGN aux_inconfir = 2 
                       aux_inconfi2 = 30.
                       
                /* LOOP do valida-rating-bndes */
                DO WHILE TRUE:

                    IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                        RUN sistema/generico/procedures/b1wgen0157.p
                            PERSISTENT SET h-b1wgen0157.

                    RUN validar-rating-bndes IN h-b1wgen0157
                                        (INPUT glb_cdcooper,
                                         INPUT glb_cdoperad,
                                         INPUT glb_nmdatela,
                                         INPUT glb_inproces,
                                         INPUT 1,   /* Ayllos */ 
                                         INPUT tel_nrdconta,
                                         INPUT tt-associado.inpessoa,
                                         INPUT tt-associado.nrcpfcgc,
                                         INPUT glb_dtmvtolt,
                                         INPUT aux_inconfir,
                                         INPUT aux_inconfi2,
                                         INPUT "A",
                                         /* Parametros da Tela */
                                         INPUT tel_vlempbnd,
                                         INPUT tel_qtparbnd,
                                         INPUT tel_nrinfcad,
                                         INPUT tel_nrgarope,
                                         INPUT tel_nrliquid,
                                         INPUT tel_nrpatlvr,
                                         INPUT tel_nrperger,
                                         INPUT INT(tel_nrctrato),
                                        OUTPUT aux_nrctrato,
                                        OUTPUT aux_dsdrisco,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-msg-confirma,
                                        OUTPUT TABLE tt-grupo).
        
                    IF  VALID-HANDLE(h-b1wgen0157) THEN
                        DELETE PROCEDURE h-b1wgen0157.
    
                    ASSIGN aux_qtctarel = 0.

                    IF  RETURN-VALUE <> "OK" THEN DO:

                        ASSIGN aux_flgvalid = FALSE.

                        FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.
            
                        /* Atingiu Valor Maximo LEGAL, mostra contas
                          do grupo economico quando existir, e
                          ABORTA operacao */
                        IF  AVAIL tt-msg-confirma   THEN DO: 

                            MESSAGE tt-msg-confirma.dsmensag.
                            
                            ASSIGN aux_qtctarel = 0
                                   aux_flgsuces = FALSE.
            
                            /*Se a conta em questao faz parte de um
                              grupo economico, serao
                              listados as contas que se relacionam
                              com a mesma.*/
                            IF  TEMP-TABLE 
                                tt-grupo:HAS-RECORDS
                            AND tt-msg-confirma.inconfir = 3 THEN
                               DO:                           
                                   ASSIGN aux_qtctarel = 0.

                                   FOR EACH tt-grupo
                                       NO-LOCK:
            
                                       ASSIGN aux_qtctarel = 
                                              aux_qtctarel + 1.
            
                                   END.
            
                                   DO WHILE TRUE ON ENDKEY UNDO,
                                      LEAVE:
                                   
                                       DISP tel_nrdconta
                                            aux_qtctarel
                                            WITH FRAME f_ge_economico.
            
                                       OPEN QUERY q-ge-economico 
                                         FOR EACH tt-grupo
                                             NO-LOCK.

                                       UPDATE b-ge-economico
                                         WITH FRAME f_ge_economico.

                                       LEAVE.

                                   END.

                                   CLOSE QUERY q-ge-economico.
                                   HIDE FRAME f_ge_economico. 
                            END. /* END do IF do Grupo Economico */
                        END. /* END do AVAIL tt-msg-confirma */


                        /* Exibe demais erros, aborta operacao */ 
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                           IF   AVAIL tt-erro   THEN
                                MESSAGE tt-erro.dscritic.
                           ELSE
                                MESSAGE 
                                   "Erro na validaçao da proposta.".

                           PAUSE 3 NO-MESSAGE.
                           ASSIGN aux_flgsuces = FALSE.
                           LEAVE.

                        END.

                        LEAVE. /* LEAVE do LOOP validar-rating-bndes */

                    END. /* END do RETURN-VALUE <> "OK" */


    
                    /* Verifica se atingiu Valor Maximo Utilizado
                       (aux_inconfir = 2), neste caso, necessaria
                       confirmacao para prosseguir com a operacao. 
                    */ 
                    FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.
            
                    /* Se tem mensagem de confirmacao e foi RETURN "OK" */
                    IF  AVAIL tt-msg-confirma  THEN DO:
                        RUN fontes/confirma.p
                             ( INPUT tt-msg-confirma.dsmensag,
                              OUTPUT aux_confirm2).
            
                        IF  aux_confirm2 <> "S"   THEN DO:
                            ASSIGN aux_flgsuces = FALSE
                                   aux_flgvalid = FALSE.
                            LEAVE.
                            /* LEAVE do LOOP validar-rating-bndes */
                        END.
                        ELSE DO:
                            ASSIGN aux_inconfir = 3
                                    aux_inconfi2 = 30.
                            NEXT.
                            /* NEXT do LOOP do validar-rating-bndes */
                        END.
                    END.
                    ELSE DO:
                        /* Se nao houve criticas com
                           aux_inconfir = 2 e aux_inconfir = 3,
                           mostra contas do grupo economico quando 
                           existir e finaliza operacao */     
                        IF   aux_inconfir = 3 THEN DO:
                             
                             ASSIGN aux_flgsuces = TRUE
                                    aux_flgvalid = TRUE.
                        
                             IF  TEMP-TABLE
                                 tt-grupo:HAS-RECORDS THEN DO:

                                     ASSIGN aux_qtctarel = 0.
                        
                                     FOR EACH tt-grupo
                                         NO-LOCK:
                        
                                         ASSIGN aux_qtctarel = 
                                                aux_qtctarel + 1.
                        
                                     END.
                        
                                     DO WHILE TRUE ON ENDKEY UNDO,
                                        LEAVE:
                                     
                                         DISP tel_nrdconta
                                              aux_qtctarel
                                              WITH FRAME f_ge_economico.
                        
                                         OPEN QUERY q-ge-economico 
                                           FOR EACH tt-grupo
                                               NO-LOCK.
                        
                                         UPDATE b-ge-economico
                                           WITH FRAME f_ge_economico.
                        
                                         LEAVE.
                        
                                     END.
                        
                                     CLOSE QUERY q-ge-economico.
                                     HIDE FRAME f_ge_economico.
                             END. /* END do IF Grupo Economico */

                             LEAVE.
                             /* LEAVE do LOOP validar-rating-bndes */
                        END.
                        ELSE DO:
                        /* Se nao criticou Valor Maximo Utilizado
                           (aux_inconfirm = 2), passa variavel 
                           aux_inconfir = 3 para validar Valor
                           Maximo Legal */ 

                            ASSIGN aux_inconfir = 3.
                            NEXT.
                            /* NEXT do LOOP do validar-rating-bndes */
                        END.
                    END. /* FIM ELSE DO:... tt-msg-confirma */

                    LEAVE.

                END. /* FIM do DO WHILE TRANSACTION do validar-rating-bndes */

                LEAVE.  /* LEAVE do LOOP dos updates */

            END. /* FIM do DO WHILE TRUE dos UPDATES*/


            /* Verifica se efetuou validacao */
            IF  aux_flgvalid THEN DO:

                ASSIGN aux_flgsuces = FALSE.
    
                DO TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    
                    IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                        RUN sistema/generico/procedures/b1wgen0157.p
                                PERSISTENT SET h-b1wgen0157.

                    RUN alterar-rating-bndes IN h-b1wgen0157
                                        (INPUT glb_cdcooper,
                                         INPUT glb_cdoperad,
                                         INPUT glb_nmdatela,
                                         INPUT glb_inproces,
                                         INPUT 1,   /* Ayllos */ 
                                         INPUT tel_nrdconta,
                                         INPUT tt-associado.inpessoa,
                                         INPUT tt-associado.nrcpfcgc,
                                         INPUT glb_dtmvtolt,
                                         INPUT aux_inconfir,
                                         INPUT aux_inconfi2,
                                         /* Parametros da Tela */
                                         INPUT tel_vlempbnd,
                                         INPUT tel_qtparbnd,
                                         INPUT tel_nrinfcad,
                                         INPUT tel_nrgarope,
                                         INPUT tel_nrliquid,
                                         INPUT tel_nrpatlvr,
                                         INPUT tel_nrperger,
                                         INPUT tel_nrctrato,
                                        OUTPUT aux_dsdrisco,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-msg-confirma,
                                        OUTPUT TABLE tt-grupo).
            
                    IF  VALID-HANDLE(h-b1wgen0157) THEN
                        DELETE PROCEDURE h-b1wgen0157.
    
    
                    IF   RETURN-VALUE <> "OK" THEN DO:
    
                         ASSIGN aux_flgsuces = FALSE.
    
                         FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                         IF   AVAILABLE tt-erro   THEN
                              MESSAGE tt-erro.dscritic.
                         ELSE
                              MESSAGE "Erro na validacao dos campos do " +
                                      "Rating.".
        
                         PAUSE 2 NO-MESSAGE.
                         UNDO.
                    END.
                    ELSE 
                        ASSIGN aux_flgsuces = TRUE.
                END. /* FIM do TRANSACTION do incluir-rating-bndes */
            END.


            IF  aux_flgsuces THEN DO:
                MESSAGE "RISCO PROPOSTO:" aux_dsdrisco.
                PAUSE.
                MESSAGE "Alteracao realizada com sucesso!".
                PAUSE 2 NO-MESSAGE.
                aux_flgsuces = FALSE.
            END.            

       END. /** END do WHEN "A" **/


       WHEN "C" THEN DO: /* Consultar Rating Proposto */
            HIDE FRAME f_ratbnd_info.
            HIDE FRAME f_craprad.
            HIDE FRAME f_brw_relat.
            HIDE FRAME f_contratos.
            HIDE FRAME f_ratbnd_relat.
            HIDE FRAME f_param_rel_sem.
            HIDE FRAME f_param_rel_com.
            HIDE FRAME f_analise_proposta.
            HIDE FRAME f_criticas.
            HIDE FRAME f_alertas.
            HIDE FRAME f_ge_economico.
            HIDE FRAME f_ge_epr.
            HIDE FRAME f_ratbnd_browse.
            HIDE MESSAGE NO-PAUSE.

            CLEAR FRAME f_ratbnd_2.
            CLEAR FRAME f_ratbnd_info.
            CLEAR FRAME f_analise_proposta.
            
            tel_nrctrato:LIST-ITEMS = "". 

            ASSIGN tel_nrdconta = 0
                   tel_vlempbnd = 0
                   tel_nmprimtl = ""
                   tel_nrctrato = ""
                   glb_cdcritic = 0
                   aux_contador = 0
                   tel_vlempbnd = 0
                   tel_qtparbnd = 0
                   tel_nrinfcad = 0
                   tel_nrgarope = 0
                   tel_nrliquid = 0
                   tel_nrpatlvr = 0
                   tel_nrperger = 0
                   tel_nmprimtl = ""
                   tel_dsinfcad = ""
                   tel_dsgarope = ""
                   tel_dsliquid = ""
                   tel_dspatlvr = ""
                   tel_dsperger = ""
                   tel_nrctrato:SCREEN-VALUE = "". /* Limpa SCREEN-VALUE */

             
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                NEXT.



            DO WHILE TRUE:
               /* Informe o nrdconta do Associado */
               UPDATE tel_nrdconta WITH FRAME f_ratbnd_info.

               ASSIGN INPUT tel_nrdconta.

               IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                   RUN sistema/generico/procedures/b1wgen9999.p
                       PERSISTENT SET h-b1wgen9999.
    
               RUN dig_fun IN h-b1wgen9999 
                         ( INPUT glb_cdcooper,
                           INPUT glb_cdagenci,
                           INPUT 0,
                           INPUT-OUTPUT tel_nrdconta,
                          OUTPUT TABLE tt-erro ).

               IF  VALID-HANDLE(h-b1wgen9999) THEN
                   DELETE PROCEDURE h-b1wgen9999.
    
               IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                   DO:
                       FIND FIRST tt-erro NO-LOCK NO-ERROR.

                       IF  AVAIL tt-erro  THEN
                           DO:
                               MESSAGE tt-erro.dscritic.
                               ASSIGN tel_nrdconta = 0.
                               CLEAR FRAME f_ratbnd_info NO-PAUSE.
                               NEXT.
                            END.
               END.
    
    
               IF  NOT VALID-HANDLE(h-b1wgen0040) THEN
                   RUN sistema/generico/procedures/b1wgen0040.p
                       PERSISTENT SET h-b1wgen0040.
    
               RUN verifica-conta IN h-b1wgen0040
                                  ( INPUT glb_cdcooper,
                                    INPUT glb_cdagenci,
                                    INPUT 0,
                                    INPUT glb_cdoperad,
                                    INPUT glb_nmdatela,
                                    INPUT 1,
                                    INPUT tel_nrdconta,
                                    INPUT 0,
                                    INPUT YES,
                                   OUTPUT tel_nmprimtl, 
                                   OUTPUT par_qtrequis, 
                                   OUTPUT par_dsmsgcnt, 
                                   OUTPUT TABLE tt-erro ).

               IF  VALID-HANDLE(h-b1wgen0040) THEN
                   DELETE PROCEDURE h-b1wgen0040.

               IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                   DO:
                       FIND FIRST tt-erro NO-LOCK NO-ERROR.

                       IF  AVAIL tt-erro  THEN
                           DO:
                               MESSAGE tt-erro.dscritic.
                               CLEAR FRAME f_ratbnd_info NO-PAUSE.
                               NEXT.
                           END.
                   END.

               /* Busca dados Cooperado */
               IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                   RUN sistema/generico/procedures/b1wgen0157.p
                       PERSISTENT SET h-b1wgen0157.
    
               RUN busca_dados_associado IN h-b1wgen0157
                                  ( INPUT glb_cdcooper,
                                    INPUT tel_nrdconta,
                                   OUTPUT TABLE tt-associado,
                                   OUTPUT TABLE tt-erro ).
    
               IF  VALID-HANDLE(h-b1wgen0157) THEN
                   DELETE PROCEDURE h-b1wgen0157.

               IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                   DO:
                       FIND FIRST tt-erro NO-LOCK NO-ERROR.

                       IF  AVAIL tt-erro  THEN
                           DO:
                               MESSAGE tt-erro.dscritic.
                               CLEAR FRAME f_ratbnd_info NO-PAUSE.
                               NEXT.
                           END.
                   END.

               FIND FIRST tt-associado NO-LOCK NO-ERROR.
               tel_nmprimtl = tt-associado.nmprimtl.

               LEAVE.
            END.

            DISPLAY tel_nmprimtl WITH FRAME f_ratbnd_info.

            /* SELECTION-LIST dos Contratos do Associado Pesquisado */
            IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                RUN sistema/generico/procedures/b1wgen0157.p
                    PERSISTENT SET h-b1wgen0157.

            RUN retorna_contratos_bndes IN h-b1wgen0157
                                (INPUT glb_cdcooper,
                                 INPUT tel_nrdconta,
                                 INPUT glb_cddopcao,
                                OUTPUT TABLE tt-ctrbndes,
                                OUTPUT TABLE tt-erro).

            IF  VALID-HANDLE(h-b1wgen0157) THEN
                DELETE PROCEDURE h-b1wgen0157.
                
            IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    IF  AVAIL tt-erro  THEN
                        DO:
                            MESSAGE tt-erro.dscritic.
                            CLEAR FRAME f_ratbnd_info NO-PAUSE.
                            NEXT.
                        END.
                END.
            aux_nrctrato = "".
            FOR EACH tt-ctrbndes NO-LOCK:

                IF   aux_contador = 0 THEN
                     ASSIGN aux_nrctrato = STRING(tt-ctrbndes.nrctrato)
                            aux_contador = 1.
                ELSE
                    ASSIGN aux_nrctrato = aux_nrctrato + "," +
                                          STRING(tt-ctrbndes.nrctrato).
                           aux_contador = aux_contador + 1.
            END.



            ON  RETURN OF tel_nrctrato DO:

                ASSIGN tel_nrctrato = tel_nrctrato:SCREEN-VALUE.

                IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                    RUN sistema/generico/procedures/b1wgen0157.p
                        PERSISTENT SET h-b1wgen0157.

                RUN consultar-rating-bndes IN h-b1wgen0157
                               (INPUT glb_cdcooper,
                                INPUT glb_cdoperad,
                                INPUT glb_nmdatela,
                                INPUT glb_inproces,
                                INPUT glb_dtmvtolt,
                                INPUT tel_nrdconta,
                                INPUT tt-associado.inpessoa,
                                INPUT tt-associado.nrcpfcgc,
                                INPUT glb_cdagenci,
                                INPUT INT(tel_nrctrato),
                                INPUT "C",
                               OUTPUT tel_vlempbnd,
                               OUTPUT tel_qtparbnd,
                               OUTPUT tel_nrinfcad,
                               OUTPUT tel_dsinfcad,
                               OUTPUT tel_nrgarope,
                               OUTPUT tel_dsgarope,
                               OUTPUT tel_nrliquid,
                               OUTPUT tel_dsliquid,
                               OUTPUT tel_nrpatlvr,
                               OUTPUT tel_dspatlvr,
                               OUTPUT tel_nrperger,
                               OUTPUT tel_dsperger,
                               OUTPUT aux_insitrat,
                               OUTPUT aux_dssitcrt, /* Proposto/Efetivo */
                               OUTPUT TABLE tt-erro).

                IF  VALID-HANDLE(h-b1wgen0157) THEN
                    DELETE PROCEDURE h-b1wgen0157.

                IF  RETURN-VALUE <> "OK" THEN DO:

                    IF  NOT CAN-FIND(FIRST tt-erro WHERE tt-erro.nrsequen > 1)
                    THEN DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                            BELL.
                            IF  AVAILABLE tt-erro  THEN
                                MESSAGE tt-erro.dscritic.
                            ELSE
                                MESSAGE "Erro na efetivacao da proposta.".

                            PAUSE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            FIND tt-erro WHERE tt-erro.cdcritic = 830
                                 NO-LOCK NO-ERROR.

                            BELL.
                            /** Faltam dados cadastrais **/
                            IF  AVAILABLE tt-erro  THEN
                                MESSAGE tt-erro.dscritic.
                            ELSE
                                MESSAGE "Erro na efetivacao da proposta.".
                    
                            /** Mostrar todas as criticas para os usuarios **/
                            DOWN 4 WITH FRAME f_criticas.
                            FOR EACH tt-erro WHERE tt-erro.cdcritic <> 830
                                NO-LOCK:

                                DISPLAY tt-erro.dscritic WITH FRAME f_criticas.
                                DOWN WITH FRAME f_criticas.
                    
                            END. /** Fim do FOR EACH tt-erro **/

                            PAUSE.
                            HIDE FRAME f_criticas.
                            NEXT.
                    END.
                    HIDE MESSAGE NO-PAUSE.
                    HIDE FRAME f_criticas.
                    HIDE FRAME f_analise_proposta.
                    HIDE FRAME f_ratbnd_browse.
                    NEXT.
                END.

                APPLY "GO".
              
            END.

            ASSIGN tel_nrctrato:LIST-ITEMS = aux_nrctrato.
                          
            UPDATE tel_nrctrato WITH FRAME f_ratbnd_info.

            IF  tt-associado.inpessoa = 1 THEN DO:
                HIDE tel_nrperger tel_dsperger IN FRAME f_analise_proposta.
                tel_dspatrim = "        Patr. pessoal livre:".
            END.
            ELSE DO:
                VIEW tel_nrperger tel_dsperger IN FRAME f_analise_proposta.
                tel_dspatrim = "Patr. garant./sócios s/onus:".
            END.

            DISPLAY tel_dspatrim
               WITH FRAME f_analise_proposta.

            tel_nrctrato:SCREEN-VALUE = tel_nrctrato.

            DISPLAY tel_nrctrato tel_vlempbnd
                    tel_qtparbnd WITH FRAME f_ratbnd_info.

            DISPLAY tel_nrinfcad tel_dsinfcad
                    tel_nrgarope tel_dsgarope
                    tel_nrliquid tel_dsliquid
                    tel_nrpatlvr tel_dspatlvr
                    tel_nrperger WHEN tt-associado.inpessoa = 2
                    tel_dsperger WHEN tt-associado.inpessoa = 2
               WITH FRAME f_analise_proposta.

            MESSAGE aux_dssitcrt.

            NEXT.

       END. /* END do WHEN "C" */


       WHEN "R" THEN DO: /* Gerar Relatorio  */
            HIDE FRAME f_ratbnd_info.
            HIDE FRAME f_craprad.
            HIDE FRAME f_brw_relat.
            HIDE FRAME f_contratos.
            HIDE FRAME f_ratbnd_relat.
            HIDE FRAME f_param_rel_sem.
            HIDE FRAME f_param_rel_com.
            HIDE FRAME f_analise_proposta.
            HIDE FRAME f_alertas.
            HIDE FRAME f_criticas.
            HIDE FRAME f_ge_economico.
            HIDE FRAME f_ge_epr.
            HIDE FRAME f_ratbnd_browse.
            HIDE MESSAGE NO-PAUSE.

            CLEAR FRAME f_ratbnd_2.
            CLEAR FRAME f_ratbnd_info.
            CLEAR FRAME f_param_rel_com.
            CLEAR FRAME f_param_rel_sem.

            tel_nrctrato:LIST-ITEMS = "". 

            ASSIGN tel_nrdconta = 0
                   tel_cdagenci = 0
                   tel_dtrefini = ?
                   tel_dtreffim = ?
                   tel_nmprimtl = "".


            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.

            DO WHILE TRUE:

                HIDE FRAME f_param_rel_sem.
                HIDE FRAME f_param_rel_com.
                CLEAR FRAME f_param_rel_com.
                CLEAR FRAME f_param_rel_sem.

                ASSIGN tel_nrdconta = 0
                       tel_cdagenci = 0
                       tel_dtrefini = ?
                       tel_dtreffim = ?
                       tel_nmprimtl = "".
            
                UPDATE tel_tprelato
                  WITH FRAME f_ratbnd_relat.
    
                IF  tel_tprelato THEN DO:  /* EFETIVOS  */
    
                    DO WHILE TRUE:
    
                        UPDATE tel_nrdconta
                          WITH FRAME f_param_rel_com.
    
    
                        IF  tel_nrdconta <> 0 THEN DO:
                            /* Busca dados Cooperado */
                            IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                                RUN sistema/generico/procedures/b1wgen0157.p
                                    PERSISTENT SET h-b1wgen0157.
    
                            RUN busca_dados_associado IN h-b1wgen0157
                                               ( INPUT glb_cdcooper,
                                                 INPUT tel_nrdconta,
                                                OUTPUT TABLE tt-associado,
                                                OUTPUT TABLE tt-erro ).
    
                            IF  VALID-HANDLE(h-b1wgen0157) THEN
                                DELETE PROCEDURE h-b1wgen0157.
    
                            IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                                DO:
                                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                    IF  AVAIL tt-erro  THEN
                                        DO:
                                           MESSAGE tt-erro.dscritic.
                                           CLEAR FRAME f_ratbnd_info NO-PAUSE.
                                           NEXT.
                                    END.
                            END.
    
                            FIND FIRST tt-associado NO-LOCK NO-ERROR.
                            ASSIGN tel_nmprimtl = tt-associado.nmprimtl
                                   tel_cdagenci = tt-associado.cdagenci.
    
                            DISPLAY tel_nmprimtl 
                                    tel_cdagenci WITH FRAME f_param_rel_com.
                            LEAVE.
                        END.
                        ELSE
                            LEAVE.

                    END. /* END do DO WHILE TRUE */

                    IF  tel_nrdconta = 0 THEN
                        UPDATE tel_cdagenci
                               tel_dtrefini  tel_dtreffim
                          WITH FRAME f_param_rel_com.
                    ELSE
                        UPDATE tel_dtrefini  tel_dtreffim
                          WITH FRAME f_param_rel_com.
                END.
                ELSE                   /* PROPOSTOS */
                    UPDATE tel_cdagenci  tel_dtrefini
                           tel_dtreffim
                      WITH FRAME f_param_rel_sem.
    
    
    
                IF  NOT VALID-HANDLE(h-b1wgen0157) THEN
                    RUN sistema/generico/procedures/b1wgen0157.p
                        PERSISTENT SET h-b1wgen0157.
    
    
                IF  tel_tprelato THEN DO: /* EFETIVOS */
    
                    RUN relatorio-bndes-efetivados IN h-b1wgen0157
                                        (INPUT glb_cdcooper,
                                         INPUT tel_nrdconta,
                                         INPUT tel_cdagenci,
                                         INPUT tel_dtrefini,
                                         INPUT tel_dtreffim,
                                         INPUT tel_tprelato,
                                        OUTPUT TABLE tt-relat,
                                        OUTPUT TABLE tt-erro).
    
                    IF  VALID-HANDLE(h-b1wgen0157) THEN
                        DELETE PROCEDURE h-b1wgen0157. 


                    IF  RETURN-VALUE <> "OK" THEN DO:
    
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                        BELL.
                        IF  AVAILABLE tt-erro  THEN DO:
                            MESSAGE tt-erro.dscritic.
                        END.
                        ELSE
                            MESSAGE "Erro na geracao do relatorio!".
                
                        

                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            ASSIGN tel_nrdconta = 0
                                   tel_cdagenci = 0
                                   tel_dtrefini = ?
                                   tel_dtreffim = ?
                                   tel_nmprimtl = "".
                            PAUSE.
                            LEAVE.
                        END.
                        NEXT.
                    END. /* END do RETURN <> "OK" */
    
    
    
                    OPEN QUERY q-relato FOR EACH tt-relat NO-LOCK
                                              BY tt-relat.cdagenci
                                              BY tt-relat.nrdconta
                                              BY tt-relat.nrctrato DESC
                                              BY tt-relat.dtmvtolt.
    
                     DO WHILE TRUE ON ENDKEY UNDO , LEAVE:
    
                        UPDATE b-relato WITH FRAME f_brw_relat.
                        APPLY "ENTER" TO b-relato.
                        LEAVE.
                     END.
                END.
                ELSE DO: /* PROPOSTOS */
                     RUN relatorio-bndes-propostos IN h-b1wgen0157
                                        (INPUT glb_cdcooper,
                                         INPUT tel_nrdconta,
                                         INPUT tel_cdagenci,
                                         INPUT tel_dtrefini,
                                         INPUT tel_dtreffim,
                                         INPUT 1, /* Ayllos Caracter */
                                        OUTPUT aux_nmarqimp,
                                        OUTPUT aux_nmarqpdf,
                                        OUTPUT TABLE tt-relat,
                                        OUTPUT TABLE tt-erro).
                    
                     IF  VALID-HANDLE(h-b1wgen0157) THEN
                         DELETE PROCEDURE h-b1wgen0157. 


                    IF  RETURN-VALUE <> "OK" THEN DO:
    
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                        BELL.
                        IF  AVAILABLE tt-erro  THEN DO:
                            MESSAGE tt-erro.dscritic.
                        END.
                        ELSE
                            MESSAGE "Erro na geracao do relatorio!".
                
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            ASSIGN tel_nrdconta = 0
                                   tel_cdagenci = 0
                                   tel_dtrefini = ?
                                   tel_dtreffim = ?
                                   tel_nmprimtl = "".
                            PAUSE.
                            LEAVE.
                        END.
                        NEXT.
                    END. /* END do RETURN <> "OK" */
    
    
    
                    DO WHILE TRUE ON END-KEY UNDO , LEAVE:
    
                        MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.
                        LEAVE.
                    END.
    
                    HIDE MESSAGE NO-PAUSE.
    
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                        RETURN.
    
                    IF  tel_cddopcao = "T"   THEN DO:
                        RUN fontes/visrel.p (INPUT aux_nmarqimp).   
                    END.         
                    ELSE 
                       IF  tel_cddopcao = "I"   THEN DO:
                           ASSIGN par_flgrodar = TRUE
                                  glb_nmformul = "132col"
                                  glb_nrdevias = 1.
    
                            FIND FIRST crapass
                                 WHERE crapass.cdcooper = glb_cdcooper
                               NO-LOCK NO-ERROR.
                            { includes/impressao.i }
    
                       END.
                    
                    UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2>/dev/null").
                END.
    
                LEAVE.
            END.      

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT. 

            
        END. /* END do WHEN "R" */


    END CASE.

END. /* FIM - DO WHILE TRUE */

/*............................................................................*/

PROCEDURE sequencia_rating:
                                                                      
    DEF INPUT        PARAM par_nrtopico AS INTE                       NO-UNDO.
    DEF INPUT        PARAM par_nritetop AS INTE                       NO-UNDO.
                                                                      
    DEF INPUT-OUTPUT PARAM par_nrseqite AS INTE                       NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_dssequte AS CHAR                       NO-UNDO.
                                                                      
    DEF VAR                aux_nrdindex AS INTE                       NO-UNDO.

    /* Posicionar no Item entrado */
    ON ENTRY OF b-craprad IN FRAME f_craprad DO: 
                    
       FIND tt-itens-topico-rating WHERE 
            tt-itens-topico-rating.nrtopico = par_nrtopico   AND
            tt-itens-topico-rating.nritetop = par_nritetop   AND
            tt-itens-topico-rating.nrseqite = par_nrseqite
            NO-LOCK NO-ERROR.

       IF   AVAIL  tt-itens-topico-rating THEN
            REPOSITION q-craprad TO ROWID ROWID(tt-itens-topico-rating).

    END.

    ON RETURN OF b-craprad IN FRAME f_craprad DO:

        IF   NOT AVAIL tt-itens-topico-rating THEN
             APPLY "GO".

        ASSIGN par_nrseqite = tt-itens-topico-rating.nrseqite.

        /* Tratamento para o Patrimonio livre */
        IF   (par_nrtopico = 1  AND
              par_nritetop = 8) OR
             (par_nrtopico = 3  AND
              par_nritetop = 9)  THEN
              DO:
                  par_dssequte = REPLACE(tt-itens-topico-rating.dsseqite,"..","").

                  APPLY "GO".
                  
                  RETURN.

              END.

        /* Verifica se tem um '.' na descricao   */
        aux_nrdindex = INDEX(tt-itens-topico-rating.dsseqite,".").  
                 
        IF   aux_nrdindex  >= 1  THEN /* Se tem, pegar ate ele */
             par_dssequte = 
                   SUBSTRING(tt-itens-topico-rating.dsseqite,1,aux_nrdindex).             
        ELSE       
             par_dssequte = tt-itens-topico-rating.dsseqite.

        APPLY "GO".

    END.

    OPEN QUERY q-craprad 
        FOR EACH tt-itens-topico-rating WHERE 
                 tt-itens-topico-rating.nrtopico = par_nrtopico   AND
                 tt-itens-topico-rating.nritetop = par_nritetop   NO-LOCK.
                            
    IF   NUM-RESULTS("q-craprad")  = 0  THEN
         RETURN.
          
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
       UPDATE b-craprad 
              WITH FRAME f_craprad.
       LEAVE.
         
    END.
   
    HIDE FRAME f_craprad.    

END PROCEDURE.

/*............................................................................*/



