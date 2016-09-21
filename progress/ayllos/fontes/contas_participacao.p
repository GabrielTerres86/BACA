/* .............................................................................

   Programa: fontes/contas_participacao.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2011                        Ultima Atualizacao: 08/04/2014

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes a identificacao do
               Associado.

   Alteracoes: 23/10/2012 - Validacoes na tela referente ao CPNJ, chamada
                            da BO9999 (Tiago).
               
               24/06/2013 - Inclusão da opção de poderes (Jean Michel).
               
               08/04/2014 - Ajuste "WHOLE-INDEX" na leitura da cratepa
                            (Adriano).
                            
               05/08/2015 - Projeto 217 - Reformulacao cadastral
                            (Tiago Castro - RKAM).
                            
..............................................................................*/

/*{ sistema/generico/includes/b1wgen0053tt.i }*/
{ sistema/generico/includes/b1wgen0080tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF NEW SHARED  VAR shr_cdnatjur LIKE crapjur.natjurid                 NO-UNDO.
DEF NEW SHARED  VAR shr_rsnatjur AS CHAR               FORMAT "x(15)"  NO-UNDO.
DEF NEW SHARED  VAR shr_dsnatjur AS CHAR               FORMAT "x(50)"  NO-UNDO.
DEF NEW SHARED  VAR shr_cdseteco AS INT                                NO-UNDO.
DEF NEW SHARED  VAR shr_nmseteco AS CHAR               FORMAT "x(20)"  NO-UNDO.
DEF NEW SHARED  VAR shr_cdrmativ AS INT                                NO-UNDO.
DEF NEW SHARED  VAR shr_nmrmativ AS CHAR               FORMAT "x(40)"  NO-UNDO.

DEF VAR tel_restpnac AS CHAR                           FORMAT "x(15)"  NO-UNDO.
DEF VAR tel_dsnatjur AS CHAR                           FORMAT "x(50)"  NO-UNDO.
DEF VAR tel_dsendweb AS CHAR                           FORMAT "x(40)"  NO-UNDO.
DEF VAR tel_cdrmativ AS INT                                            NO-UNDO.
DEF VAR tel_dsrmativ AS CHAR                           FORMAT "X(40)"  NO-UNDO.
DEF VAR tel_cdnatjur LIKE crapjur.natjurid                             NO-UNDO.
DEF VAR tel_qtfilial LIKE crapjur.qtfilial                             NO-UNDO.
DEF VAR tel_qtfuncio LIKE crapjur.qtfuncio                             NO-UNDO.
DEF VAR tel_dtiniatv LIKE crapjur.dtiniatv                             NO-UNDO.
DEF VAR tel_cdseteco LIKE crapjur.cdseteco                             NO-UNDO.
DEF VAR tel_nmseteco AS CHAR                           FORMAT "x(11)"  NO-UNDO.
DEF VAR reg_dsdopcao AS CHAR EXTENT 5 INIT ["Alterar",
                                            "Consultar",
                                            "Excluir",
                                            "Incluir",
                                            "Poderes"]                 NO-UNDO.
DEF VAR reg_cddopcao AS CHAR EXTENT 5 INIT ["A","C","E","I","P"]       NO-UNDO.
DEF VAR reg_contador AS INT           INIT 1                           NO-UNDO.
DEF VAR aux_nrdlinha AS INT                                            NO-UNDO.

DEF VAR tel_nmprimtl LIKE crapass.nmprimtl                             NO-UNDO.

DEF VAR aux_flgsuces AS LOGICAL                                        NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_stsnrcal AS LOGICAL                                        NO-UNDO.

DEF VAR h-b1wgen0053 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0060 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0080 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR tel_nrctasoc LIKE crapavt.nrdctato                             NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_persocio LIKE crapepa.persocio                             NO-UNDO.
DEF VAR tel_persocio LIKE crapepa.persocio                             NO-UNDO.
DEF VAR tel_dtadmiss LIKE crapepa.dtadmiss                             NO-UNDO.
DEF VAR tel_vledvmto LIKE crapepa.vledvmto                             NO-UNDO.


DEFINE TEMP-TABLE cratepa NO-UNDO LIKE tt-crapepa.

DEF QUERY q_procuradores FOR cratepa.

DEF BROWSE b_procuradores QUERY q_procuradores
    DISPLAY cratepa.nrctasoc  COLUMN-LABEL "Conta/dv" FORMAT "zzzz,zz9,9"
            cratepa.nmprimtl  COLUMN-LABEL "Razao Social" FORMAT "x(30)" /* fazer razao social e nao fansia */
            cratepa.cdcpfcgc  COLUMN-LABEL "C.N.P.J."   FORMAT "x(18)"
            cratepa.persocio  COLUMN-LABEL "% Societario" FORMAT "zz9.99"
            WITH 9 DOWN NO-BOX.

FORM b_procuradores
     WITH ROW 9 COLUMN 2 OVERLAY NO-BOX FRAME f_browse.

FORM SKIP(12)
     reg_dsdopcao[1]  AT 15  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2]  AT 28  NO-LABEL FORMAT "x(9)"
     reg_dsdopcao[3]  AT 43  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[4]  AT 56  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[5]  AT 65  NO-LABEL FORMAT "x(7)"
     
     WITH ROW 7 WIDTH 80 OVERLAY SIDE-LABELS 
          TITLE " EMPRESAS PARTICIPANTES " FRAME f_regua.

FORM  tel_nrctasoc AT 05 LABEL "Conta/dv" AUTO-RETURN
      tel_nrcpfcgc AT 35 LABEL " C.N.P.J."
                         HELP "Informe o CNPJ da empresa participante"
                         VALIDATE(tel_nrcpfcgc <> ""  AND
                                  tel_nrcpfcgc <> "0",
                                  "375 - O campo deve ser preenchido.")
      SKIP

      SKIP
      tel_nmprimtl     AT  1 LABEL "Razao Social" AUTO-RETURN FORMAT "x(40)"
      tel_nmfatasi     AT  1 LABEL "Nome Fantasia"
                             HELP "Informe o nome fantasia da empresa"
                             VALIDATE(tel_nmfatasi <> "",
                                      "375 - O campo deve ser preenchido.")
      SKIP(1)
      tel_cdnatjur     AT  1 LABEL "Natureza Juridica"   FORMAT "9999"
                             AUTO-RETURN
          HELP "Informe codigo da natureza juridica ou pressione F7 para listar"
                             VALIDATE(tel_cdnatjur <> 0,
                                     "375 - O campo deve ser preenchido.")
      tel_dsnatjur           NO-LABEL                    FORMAT "x(50)"
      SKIP
      tel_qtfilial     AT  6 LABEL "Qtd. Filiais"
                             HELP "Informe a quantidade de filiais da empresa"
      
      tel_qtfuncio     AT 49 LABEL "Qtd. Funcionarios"
                       HELP "Informe a quantidade de funcionarios da empresa"
      SKIP
      tel_dtiniatv     AT  2 LABEL "Inicio Atividade" 
                                   AUTO-RETURN FORMAT "99/99/9999"
                             HELP "Informe o inicio da atividade da empresa"
                             VALIDATE(tel_dtiniatv <> ?,
                                      "013 - Data errada.")
      
      tel_cdseteco     AT 33 LABEL "Setor Economico"  AUTO-RETURN
                       FORMAT "9"
                    HELP "Informe o setor economico ou pressione F7 para listar"
                       VALIDATE(tel_cdseteco <> 0,
                                "375 - O campo deve ser preenchido.")
      
      tel_nmseteco     NO-LABEL FORMAT "x(20)"
      SKIP                       
      tel_cdrmativ     AT  4 LABEL "Ramo Atividade"  FORMAT "zz9"
                       AUTO-RETURN
                     HELP "Informe o ramo atividade ou pressione F7 para listar"
                       VALIDATE(tel_cdrmativ <> 0,
                                "375 - O campo deve ser preenchido.")

      tel_dsrmativ     NO-LABEL FORMAT "x(30)"
      SKIP
      tel_dsendweb     AT  1 LABEL "Endereco na Internet(Site)" 
                             HELP "Informe o endereco da empresa na internet"
      SKIP(1)
      tel_persocio  AT 1   LABEL "% Societ." FORMAT "zz9.99"
                           HELP "Informe o percentual societario"
      tel_dtadmiss  AT 19  LABEL "Admissao"
                           HELP "Entre com a data de admissao do socio na empresa."
                           VALIDATE ((tel_dtadmiss <= glb_dtmvtolt  AND
                                     YEAR(tel_dtadmiss) >= 1000)  OR
                                    tel_dtadmiss = ?,
                                    "013 - Data errada.")
    
      tel_vledvmto AT  40  LABEL "Endividamento"
                          HELP "Entre com o valor do endividamento."
      SKIP(1)
      WITH ROW 8 WIDTH 80 OVERLAY SIDE-LABELS TITLE " DADOS DA EMPRESA "
                 CENTERED FRAME f_dados_juridica.

ON ENTRY OF b_procuradores IN FRAME f_browse DO:

   IF   aux_nrdlinha > 0   THEN
        REPOSITION q_procuradores TO ROW(aux_nrdlinha).

END.

ON ANY-KEY OF b_procuradores IN FRAME f_browse DO:

   IF   KEY-FUNCTION(LASTKEY) = "GO"   THEN
        RETURN NO-APPLY.

   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
        DO:
            reg_contador = reg_contador + 1.
    
            IF   reg_contador > 5   THEN
                 reg_contador = 1.
                
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE        
   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
        DO:
            reg_contador = reg_contador - 1.

            IF   reg_contador < 1   THEN
                 reg_contador = 5.
                 
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "HELP"   THEN
        APPLY LASTKEY.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "RETURN"   THEN
        DO:
           IF   AVAILABLE cratepa   THEN
                DO:
                    ASSIGN aux_nrdrowid = cratepa.nrdrowid
                           aux_nrdlinha = CURRENT-RESULT-ROW("q_procuradores").
                         
                    /* Desmarca todas as linhas do browse para poder remarcar*/
                    b_procuradores:DESELECT-ROWS().
                END.
           ELSE
                ASSIGN aux_nrdrowid = ?
                       aux_nrdlinha = 0.

           ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].

           APPLY "GO".
        END.
   ELSE
        RETURN.
            
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
END.

/* Natureza Juridica */
ON LEAVE OF tel_cdnatjur IN FRAME f_dados_juridica DO:

    ASSIGN INPUT tel_cdnatjur.
    
    IF  NOT DYNAMIC-FUNCTION("BuscaNaturezaJuridica" IN h-b1wgen0060,
                             INPUT tel_cdnatjur,
                             INPUT "dsnatjur",
                             OUTPUT tel_dsnatjur,
                             OUTPUT aux_dscritic) THEN 
        DO:
           MESSAGE aux_dscritic.
           DISPLAY tel_dsnatjur WITH FRAME f_dados_juridica.
           RETURN NO-APPLY.
        END.
    
    DISPLAY tel_dsnatjur WITH FRAME f_dados_juridica.   

END.

/* Setor Economico */  
ON LEAVE OF tel_cdseteco IN FRAME f_dados_juridica DO:

    ASSIGN INPUT tel_cdseteco.

    IF  NOT DYNAMIC-FUNCTION("BuscaSetorEconomico" IN h-b1wgen0060,
                             INPUT glb_cdcooper,
                             INPUT tel_cdseteco,
                             OUTPUT tel_nmseteco,
                             OUTPUT aux_dscritic) THEN
        DO:
           MESSAGE aux_dscritic.
           DISPLAY tel_nmseteco WITH FRAME f_dados_juridica.
           RETURN NO-APPLY.
        END.

    DISPLAY tel_nmseteco WITH FRAME f_dados_juridica.

END.

/* Ramo de Atividades */
ON LEAVE OF tel_cdrmativ IN FRAME f_dados_juridica DO:

    ASSIGN INPUT tel_cdrmativ.

    IF  NOT DYNAMIC-FUNCTION("BuscaRamoAtividade" IN h-b1wgen0060,
                             INPUT tel_cdseteco,
                             INPUT tel_cdrmativ,
                             OUTPUT tel_dsrmativ,
                             OUTPUT aux_dscritic) THEN
        DO:
           MESSAGE aux_dscritic.
           DISPLAY tel_dsrmativ WITH FRAME f_dados_juridica.
           RETURN NO-APPLY.
        END.

    DISPLAY tel_dsrmativ WITH FRAME f_dados_juridica.

END.

aux_flgsuces = FALSE.

Principal: DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF  NOT VALID-HANDLE(h-b1wgen0053) THEN
       RUN sistema/generico/procedures/b1wgen0053.p 
           PERSISTENT SET h-b1wgen0053.

   IF  NOT VALID-HANDLE(h-b1wgen0080) THEN
       RUN sistema/generico/procedures/b1wgen0080.p 
           PERSISTENT SET h-b1wgen0080.

   IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
       RUN sistema/generico/procedures/b1wgen0060.p 
           PERSISTENT SET h-b1wgen0060.

   HIDE  FRAME f_regua.
   HIDE  FRAME f_browse.
   HIDE  FRAME f_procuradores.
   CLEAR FRAME f_procuradores.

   /* Carrega a lista de procuradores/representantes */
   EMPTY TEMP-TABLE cratepa.

   RUN Busca_Dados ( INPUT "C" ).

   IF  RETURN-VALUE <> "OK" THEN
       LEAVE.

   DISPLAY reg_dsdopcao WITH FRAME f_regua.

   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

   OPEN QUERY q_procuradores FOR EACH cratepa 
                                 WHERE cratepa.cdcooper = glb_cdcooper
                                       BY cratepa.nrctasoc
                                        BY cratepa.nrdocsoc.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE b_procuradores WITH FRAME f_browse.
      LEAVE.

   END.                            
   
   IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
        LEAVE.
   
   /* Deixa o browse visivel e marca a linha que tinha sido selecionada */
   VIEW FRAME f_browse.

   { includes/acesso.i }

   EMPTY TEMP-TABLE tt-dados-jur.

   IF  glb_cddopcao = "I"   THEN
   DO:
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              ASSIGN tel_nmprimtl = ""
                     tel_nmfatasi = ""
                     tel_cdnatjur = 0
                     tel_dsnatjur = ""
                     tel_qtfilial = 0
                     tel_qtfuncio = 0
                     tel_dtiniatv = ?
                     tel_cdseteco = 0
                     tel_nmseteco = ""
                     tel_cdrmativ = 0
                     tel_dsrmativ = ""
                     tel_dsendweb = ""
                     tel_persocio = 0
                     tel_dtadmiss = ?
                     tel_nrctasoc = 0
                     tel_nrcpfcgc = ""
                     tel_vledvmto = 0
                     aux_nrdrowid = ?.

             CLEAR FRAME f_dados_juridica.
             
             UPDATE tel_nrctasoc WITH FRAME f_dados_juridica

             EDITING:
               READKEY.
               HIDE MESSAGE NO-PAUSE.

               APPLY LASTKEY.
               IF  GO-PENDING THEN
                   DO:
                      ASSIGN INPUT tel_nrctasoc.
                      IF  tel_nrctasoc <> 0  THEN
                          DO:
                              RUN Busca_Dados ( INPUT glb_cddopcao ).
    
                              IF  RETURN-VALUE <> "OK" THEN
                                  NEXT.
                          END.
                   END.
             END.

             IF  tel_nrctasoc = 0  THEN
                 DO:
                    UPDATE tel_nrcpfcgc WITH FRAME f_dados_juridica

                    EDITING:
                      READKEY.
                      HIDE MESSAGE NO-PAUSE.
                      
                      APPLY LASTKEY.
                      IF  GO-PENDING THEN
                          DO:
                             ASSIGN INPUT tel_nrcpfcgc.
                        
                             RUN sistema/generico/procedures/b1wgen9999.p 
                                            PERSISTENT SET h-b1wgen9999.

                             RUN valida-cpf-cnpj 
                                 IN h-b1wgen9999(INPUT  tel_nrcpfcgc,
                                                 OUTPUT aux_stsnrcal,
                                                 OUTPUT aux_inpessoa).

                             DELETE PROCEDURE h-b1wgen9999.

                             IF  aux_stsnrcal = FALSE OR 
                                 aux_inpessoa <> 2    THEN
                                 DO: 
                                     ASSIGN glb_dscritic = "CPNJ nao eh valido.".
                                     MESSAGE glb_dscritic.
                                     NEXT.
                                 END.
                          END.
                    END.
                    
                    RUN Busca_Dados ( INPUT glb_cddopcao ).

                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT.
                 END.
            
             RUN Atualiza_Tela. 

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
                IF   glb_cdcritic <> 0   THEN
                     DO:
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                     END.

                     UPDATE tel_nmprimtl WHEN tel_nrctasoc = 0 
                            tel_nmfatasi WHEN tel_nrctasoc = 0 
                            tel_cdnatjur WHEN tel_nrctasoc = 0 
                            tel_qtfilial WHEN tel_nrctasoc = 0 
                            tel_qtfuncio WHEN tel_nrctasoc = 0 
                            tel_dtiniatv WHEN tel_nrctasoc = 0 
                            tel_cdseteco WHEN tel_nrctasoc = 0 
                            tel_cdrmativ WHEN tel_nrctasoc = 0 
                            tel_dsendweb WHEN tel_nrctasoc = 0 
                            tel_persocio
                            tel_dtadmiss
                            tel_vledvmto WHEN tel_nrctasoc = 0
                            WITH FRAME f_dados_juridica

                     EDITING:

                         READKEY.
                         HIDE MESSAGE NO-PAUSE.

                         IF   LASTKEY = KEYCODE("F7") THEN
                              DO:
                                  IF   FRAME-FIELD = "tel_cdnatjur"   THEN
                                       DO:
                                           ASSIGN shr_cdnatjur = INPUT tel_cdnatjur.
                                           RUN fontes/zoom_natureza_juridica.p.
                                           IF  shr_cdnatjur <> 0  THEN
                                               DO:
                                                  ASSIGN tel_cdnatjur = shr_cdnatjur
                                                         tel_dsnatjur = shr_dsnatjur.
                                                  DISPLAY tel_cdnatjur tel_dsnatjur
                                                          WITH FRAME f_dados_juridica.
                                                  NEXT-PROMPT tel_cdnatjur
                                                              WITH FRAME f_dados_juridica.
                                                END.
                                       END.
                                  ELSE
                                  IF   FRAME-FIELD = "tel_cdseteco"   THEN
                                       DO:
                                           ASSIGN shr_cdseteco = INPUT tel_cdseteco.
                                           RUN fontes/zoom_setoreconomico.p
                                                                (INPUT glb_cdcooper).
                                           IF  shr_cdseteco <> 0  THEN
                                               DO:
                                                  ASSIGN tel_cdseteco = shr_cdseteco
                                                         tel_nmseteco = shr_nmseteco.
                                                  DISPLAY tel_cdseteco tel_nmseteco
                                                          WITH FRAME f_dados_juridica.
                                                  NEXT-PROMPT tel_cdseteco
                                                              WITH FRAME f_dados_juridica.
                                               END.
                                       END.
                                  ELSE
                                  IF   FRAME-FIELD = "tel_cdrmativ"   THEN
                                       DO:
                                           ASSIGN shr_cdrmativ = INPUT tel_cdrmativ
                                                  tel_cdseteco = INPUT tel_cdseteco.

                                           RUN fontes/zoom_ramo_atividades.p
                                               (INPUT tel_cdseteco).

                                           IF  shr_cdrmativ <> 0  THEN
                                               DO:
                                                  ASSIGN tel_cdrmativ = shr_cdrmativ
                                                         tel_dsrmativ = shr_nmrmativ.
                                                  DISPLAY tel_cdrmativ tel_dsrmativ
                                                         WITH FRAME f_dados_juridica.
                                                  NEXT-PROMPT tel_cdrmativ
                                                              WITH FRAME f_dados_juridica.
                                               END.
                                       END.
                              END. /* Fim do F7 */
                         ELSE
                              APPLY LASTKEY.

                         IF  GO-PENDING THEN
                             DO:
                                DO WITH FRAME f_dados_juridica:
                                    ASSIGN 
                                      INPUT tel_nmprimtl  
                                      INPUT tel_nmfatasi  
                                      INPUT tel_cdnatjur  
                                      INPUT tel_dsnatjur  
                                      INPUT tel_qtfilial  
                                      INPUT tel_qtfuncio  
                                      INPUT tel_dtiniatv  
                                      INPUT tel_cdseteco  
                                      INPUT tel_nmseteco  
                                      INPUT tel_cdrmativ  
                                      INPUT tel_dsrmativ  
                                      INPUT tel_dsendweb  
                                      INPUT tel_persocio
                                      INPUT tel_dtadmiss
                                      INPUT tel_nrctasoc
                                      INPUT tel_nrcpfcgc
                                      INPUT tel_vledvmto
                                      INPUT tel_persocio
                                      INPUT tel_dtadmiss.

                                 END.

                                 RUN Valida_Dados.

                                 IF  RETURN-VALUE <> "OK" THEN
                                     NEXT.

                             END.

                     END.  /*  Fim do EDITING  */

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    NEXT.

                LEAVE.

             END.

             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                  NEXT.

             LEAVE.

          END. /* Fim DO WHILE */

          IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
               NEXT.

          RUN proc_confirma.

          IF   aux_confirma = "S" THEN
               DO:
                  
                  RUN Grava_Dados.
    
                  IF  RETURN-VALUE <> "OK" THEN
                      NEXT.
               END.
   END.
   ELSE
   IF  glb_cddopcao = "C"  AND  aux_nrdrowid <> ?  THEN
   DO:
       FIND FIRST cratepa WHERE cratepa.nrdrowid = aux_nrdrowid NO-ERROR.

       IF  AVAILABLE cratepa THEN
           DO:
               IF  tel_nrcpfcgc = "" THEN
                   ASSIGN tel_nrcpfcgc = cratepa.cdcpfcgc.

               ASSIGN tel_nrctasoc = cratepa.nrctasoc.
           END.

       RUN Atualiza_Tela.

       PAUSE NO-MESSAGE.
   END.
   ELSE
   IF  glb_cddopcao = "A"   AND  aux_nrdrowid <> ?    THEN
   DO:
       FIND FIRST cratepa WHERE cratepa.nrdrowid = aux_nrdrowid NO-ERROR.

       IF  AVAILABLE cratepa THEN
       DO:
           IF  tel_nrcpfcgc = "" THEN
               ASSIGN tel_nrcpfcgc = cratepa.cdcpfcgc.

           ASSIGN tel_nrctasoc = cratepa.nrctasoc.
       END.

       RUN Atualiza_Tela.

       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
          IF   glb_cdcritic <> 0   THEN
               DO:
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE glb_dscritic.
                   glb_cdcritic = 0.
               END.
    
               UPDATE tel_nmprimtl WHEN tel_nrctasoc = 0 
                      tel_nmfatasi WHEN tel_nrctasoc = 0 
                      tel_cdnatjur WHEN tel_nrctasoc = 0 
                      tel_qtfilial WHEN tel_nrctasoc = 0 
                      tel_qtfuncio WHEN tel_nrctasoc = 0 
                      tel_dtiniatv WHEN tel_nrctasoc = 0 
                      tel_cdseteco WHEN tel_nrctasoc = 0 
                      tel_cdrmativ WHEN tel_nrctasoc = 0 
                      tel_dsendweb WHEN tel_nrctasoc = 0 
                      tel_persocio
                      tel_dtadmiss
                      tel_vledvmto WHEN tel_nrctasoc = 0 
                      WITH FRAME f_dados_juridica
    
               EDITING:
    
                   READKEY.
                   HIDE MESSAGE NO-PAUSE.
    
                   IF   LASTKEY = KEYCODE("F7") THEN
                        DO:
                            IF   FRAME-FIELD = "tel_cdnatjur"   THEN
                                 DO:
                                     ASSIGN shr_cdnatjur = INPUT tel_cdnatjur.
                                     RUN fontes/zoom_natureza_juridica.p.
                                     IF  shr_cdnatjur <> 0  THEN
                                         DO:
                                            ASSIGN tel_cdnatjur = shr_cdnatjur
                                                   tel_dsnatjur = shr_dsnatjur.
                                            DISPLAY tel_cdnatjur tel_dsnatjur
                                                    WITH FRAME f_dados_juridica.
                                            NEXT-PROMPT tel_cdnatjur
                                                        WITH FRAME f_dados_juridica.
                                          END.
                                 END.
                            ELSE
                            IF   FRAME-FIELD = "tel_cdseteco"   THEN
                                 DO:
                                     ASSIGN shr_cdseteco = INPUT tel_cdseteco.
                                     RUN fontes/zoom_setoreconomico.p
                                                          (INPUT glb_cdcooper).
                                     IF  shr_cdseteco <> 0  THEN
                                         DO:
                                            ASSIGN tel_cdseteco = shr_cdseteco
                                                   tel_nmseteco = shr_nmseteco.
                                            DISPLAY tel_cdseteco tel_nmseteco
                                                    WITH FRAME f_dados_juridica.
                                            NEXT-PROMPT tel_cdseteco
                                                        WITH FRAME f_dados_juridica.
                                         END.
                                 END.
                            ELSE
                            IF   FRAME-FIELD = "tel_cdrmativ"   THEN
                                 DO:
                                     ASSIGN shr_cdrmativ = INPUT tel_cdrmativ
                                            tel_cdseteco = INPUT tel_cdseteco.
    
                                     RUN fontes/zoom_ramo_atividades.p
                                         (INPUT tel_cdseteco).
    
                                     IF  shr_cdrmativ <> 0  THEN
                                         DO:
                                            ASSIGN tel_cdrmativ = shr_cdrmativ
                                                   tel_dsrmativ = shr_nmrmativ.
                                            DISPLAY tel_cdrmativ tel_dsrmativ
                                                   WITH FRAME f_dados_juridica.
                                            NEXT-PROMPT tel_cdrmativ
                                                        WITH FRAME f_dados_juridica.
                                         END.
                                 END.
                        END. /* Fim do F7 */
                   ELSE
                        APPLY LASTKEY.
    
                   IF  GO-PENDING THEN
                       DO:
                          DO WITH FRAME f_dados_juridica:
                              ASSIGN 
                                INPUT tel_nmprimtl  
                                INPUT tel_nmfatasi  
                                INPUT tel_cdnatjur  
                                INPUT tel_dsnatjur  
                                INPUT tel_qtfilial  
                                INPUT tel_qtfuncio  
                                INPUT tel_dtiniatv  
                                INPUT tel_cdseteco  
                                INPUT tel_nmseteco  
                                INPUT tel_cdrmativ  
                                INPUT tel_dsrmativ  
                                INPUT tel_dsendweb  
                                INPUT tel_persocio
                                INPUT tel_dtadmiss
                                INPUT tel_nrctasoc
                                INPUT tel_nrcpfcgc
                                INPUT tel_vledvmto
                                INPUT tel_persocio
                                INPUT tel_dtadmiss.
    
                           END.
    
                           RUN Valida_Dados.
    
                           IF  RETURN-VALUE <> "OK" THEN
                               NEXT.
    
                       END.
    
               END.  /*  Fim do EDITING  */
    
          IF  RETURN-VALUE <> "OK" THEN
              NEXT.
    
          IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
              NEXT.
    
          LEAVE.
    
       END.
    
       IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
            NEXT.

       RUN proc_confirma.

       IF  RETURN-VALUE <> "OK" THEN
           NEXT.

       IF  aux_confirma = "S" THEN
       DO:
           RUN Grava_Dados.

           IF  RETURN-VALUE <> "OK" THEN
               NEXT.
       END.
   END.
   ELSE
   IF   glb_cddopcao = "E" AND aux_nrdrowid <> ?    THEN
   DO:
       FIND FIRST cratepa WHERE cratepa.nrdrowid = aux_nrdrowid NO-ERROR.

       IF  AVAILABLE cratepa THEN
           DO:
               IF  tel_nrcpfcgc = "" THEN
                   ASSIGN tel_nrcpfcgc = cratepa.cdcpfcgc.

               ASSIGN tel_nrctasoc = cratepa.nrctasoc.
           END.

       RUN Valida_Dados.

       IF  RETURN-VALUE <> "OK" THEN
           NEXT.

       RUN Atualiza_Tela.

       RUN proc_confirma.

       IF  RETURN-VALUE <> "OK" THEN
           NEXT.

       IF  aux_confirma = "S" THEN
           DO:
               RUN Exclui_Dados.

               IF  RETURN-VALUE <> "OK" THEN
                   NEXT.
           END.
       
   END.
       
END.

IF  VALID-HANDLE(h-b1wgen0053) THEN
    DELETE OBJECT h-b1wgen0053.

IF  VALID-HANDLE(h-b1wgen0080) THEN
    DELETE OBJECT h-b1wgen0080.

IF  VALID-HANDLE(h-b1wgen0060) THEN
    DELETE OBJECT h-b1wgen0060.

HIDE FRAME f_dados_juridica NO-PAUSE.
HIDE FRAME f_regua NO-PAUSE.
HIDE FRAME f_browse NO-PAUSE.
HIDE FRAME f_procuradores NO-PAUSE.
HIDE MESSAGE NO-PAUSE.

glb_cddopcao = "C".

/*...........................................................................*/

PROCEDURE proc_confirma:
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       ASSIGN aux_confirma = "N"
              glb_cdcritic = 78.
       RUN fontes/critic.p.
       BELL.
       glb_cdcritic = 0.
       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
       LEAVE.
    END.  /*  Fim do DO WHILE TRUE  */
                                       
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"    OR
         aux_confirma <> "S"                   THEN
         DO:
             glb_cdcritic = 79.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Atualiza_Tela:

    FIND FIRST cratepa WHERE cratepa.cdcooper = glb_cdcooper AND
                             cratepa.nrdrowid = aux_nrdrowid 
                             NO-ERROR.

    IF  NOT AVAILABLE cratepa THEN
        CREATE cratepa.

    ASSIGN
        tel_nmprimtl = cratepa.nmprimtl
        tel_nmfatasi = cratepa.nmfansia
        tel_nrctasoc = cratepa.nrctasoc
        tel_nrcpfcgc = cratepa.cdcpfcgc
        tel_cdnatjur = cratepa.natjurid
        tel_dsnatjur = cratepa.dsnatjur
        tel_qtfilial = cratepa.qtfilial
        tel_qtfuncio = cratepa.qtfuncio
        tel_dtiniatv = cratepa.dtiniatv
        tel_cdseteco = cratepa.cdseteco
        tel_nmseteco = cratepa.nmseteco
        tel_cdrmativ = cratepa.cdrmativ
        tel_dsrmativ = cratepa.dsrmativ
        tel_vledvmto = cratepa.vledvmto
        tel_persocio = cratepa.persocio
        tel_dtadmiss = cratepa.dtadmiss
        tel_dsendweb = cratepa.dsendweb.

    DISP tel_nrctasoc
         tel_nrcpfcgc  WHEN glb_cddopcao <> "I"
         tel_nmprimtl
         tel_nmfatasi 
         tel_cdnatjur 
         tel_dsnatjur 
         tel_qtfilial 
         tel_qtfuncio 
         tel_dtiniatv 
         tel_cdseteco 
         tel_nmseteco 
         tel_cdrmativ 
         tel_dsrmativ 
         tel_dsendweb 
         tel_persocio 
         tel_dtadmiss 
         tel_vledvmto 
         WITH FRAME f_dados_juridica.

END PROCEDURE.

PROCEDURE Busca_Dados:

    DEFINE INPUT  PARAMETER par_cddopcao AS CHARACTER   NO-UNDO.

    EMPTY TEMP-TABLE cratepa.
    EMPTY TEMP-TABLE tt-crapepa.

    IF  par_cddopcao = "C" THEN
        ASSIGN 
           tel_nrctasoc = 0
           tel_nrcpfcgc = ""
           aux_nrdrowid = ?.

    RUN Busca_Dados IN h-b1wgen0080
        (INPUT glb_cdcooper,
         INPUT 0,
         INPUT 0,
         INPUT glb_cdoperad,
         INPUT glb_nmdatela,
         INPUT 1,
         INPUT tel_nrdconta,
         INPUT 0,
         INPUT YES,
         INPUT par_cddopcao,
         INPUT tel_nrctasoc,
         INPUT tel_nrcpfcgc,
         INPUT aux_nrdrowid,
        OUTPUT TABLE tt-crapepa,
        OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  BELL.
                  MESSAGE tt-erro.dscritic.
               END.
            ELSE
            DO:
                BELL.
                MESSAGE "Erro ao consultar os dados.".
            END.
            RETURN "NOK".
        END.

    FOR EACH tt-crapepa WHERE tt-crapepa.cdcooper = glb_cdcooper
                              EXCLUSIVE-LOCK:

        FIND cratepa OF tt-crapepa NO-ERROR.
        
        IF  NOT AVAILABLE cratepa THEN
        DO:
            CREATE cratepa.
            BUFFER-COPY tt-crapepa TO cratepa.
        END.
        
        DELETE tt-crapepa.
    END.

   RETURN "OK".

END PROCEDURE.

PROCEDURE Valida_Dados:

    RUN Valida_Dados IN h-b1wgen0080 (INPUT glb_cdcooper,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT glb_cdoperad,  
                                      INPUT glb_nmdatela,
                                      INPUT 1,
                                      INPUT tel_nrdconta,
                                      INPUT 0,
                                      INPUT tel_nrctasoc,
                                      INPUT tel_nrcpfcgc,
                                      INPUT tel_nmfatasi,
                                      INPUT glb_dtmvtolt,
                                      INPUT tel_dtiniatv,
                                      INPUT tel_cdnatjur,
                                      INPUT tel_cdseteco,
                                      INPUT tel_cdrmativ,
                                      INPUT tel_dtadmiss,
                                      INPUT tel_persocio,
                                      INPUT tel_vledvmto,
                                      INPUT glb_cddopcao,
                                     OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" THEN
        DO: 
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
   
            IF  AVAIL tt-erro  THEN
            DO:
                BELL.
                MESSAGE tt-erro.dscritic.
                PAUSE 7 NO-MESSAGE.
            END.
            ELSE
            DO:
                BELL.
                MESSAGE "Erro ao validar os dados.".
                PAUSE 7 NO-MESSAGE.
            END.
        END.

END PROCEDURE.

PROCEDURE Grava_Dados:

    IF  VALID-HANDLE(h-b1wgen0080) THEN
        DELETE OBJECT h-b1wgen0080.

    RUN sistema/generico/procedures/b1wgen0080.p 
        PERSISTENT SET h-b1wgen0080.

    RUN Grava_Dados IN h-b1wgen0080 (INPUT glb_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,  
                                     INPUT glb_nmdatela,
                                     INPUT 1,
                                     INPUT tel_nrdconta,
                                     INPUT 1,
                                     INPUT YES, /* gravar log */
                                     INPUT tel_nrctasoc,
                                     INPUT tel_nrcpfcgc,
                                     INPUT CAPS(tel_nmprimtl),
                                     INPUT CAPS(tel_nmfatasi),
                                     INPUT tel_cdnatjur,
                                     INPUT tel_dtiniatv,
                                     INPUT tel_cdrmativ,
                                     INPUT tel_qtfilial,
                                     INPUT tel_qtfuncio,
                                     INPUT LC(tel_dsendweb),
                                     INPUT tel_cdseteco,
                                     INPUT glb_cddopcao,
                                     INPUT glb_dtmvtolt,
                                     INPUT tel_dtadmiss,
                                     INPUT tel_persocio,
                                     INPUT tel_vledvmto,
                                    OUTPUT aux_tpatlcad,
                                    OUTPUT aux_msgatcad,
                                    OUTPUT aux_chavealt,
                                    OUTPUT TABLE tt-erro).

    HIDE MESSAGE NO-PAUSE.

    DELETE OBJECT h-b1wgen0080.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.
   
    IF  aux_msgatcad <> "" THEN
        MESSAGE aux_msgatcad.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Exclui_Dados:

    RUN Exclui_Dados IN h-b1wgen0080
        (INPUT glb_cdcooper,
         INPUT 0,
         INPUT 0,
         INPUT glb_cdoperad,
         INPUT glb_nmdatela,
         INPUT 1,
         INPUT tel_nrdconta,
         INPUT 0,
         INPUT YES,
         INPUT tel_nrcpfcgc,
        OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    RETURN "OK".

END PROCEDURE.
