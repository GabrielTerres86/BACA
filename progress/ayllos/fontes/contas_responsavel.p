/* ............................................................................

   Programa: fontes/contas_responsavel.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Setembro/2006                   Ultima Atualizacao: 24/07/2015
      
   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes aos responsaveis legais
               do Associado pela tela CONTAS (Pessoa Fisica).

   Alteracoes: 15/12/2006 - Acerto na tela (Erro na leitura do crabass) (Ze).
               
               19/12/2006 - Verificar se o crapttl esta completo so se for
                            conta ITG (Magui).
                            
               21/12/2006 - Acerto no programa (Ze).             
               
               09/01/2007 - Permitir que os dados de um associado demitido
                            possam ser alterados;
                          - Permitir que maiores de 18 anos entrem na tela
                            somente para excluir responsaveis (Evandro).
               
               19/03/2007 - Alterado para receber informacoes de endereco
                            somente da tabela crapenc (Elton).
               
               20/05/2008 - Alterada a chamada das Naturalidades (Evandro).
               
               18/05/2010 - Adaptacao para uso de BO (Jose Luis, DB1).
               
               22/09/2010 - Bloqueia edição em conta filha (Gabriel, DB1).
               
               11/04/2011 - Inclusão de CEP integrado. (André - DB1).
               
               16/04/2012 - Ajuste referente ao projeto GP - Socios Menores
                           (Adriano).

               27/05/2014 - Alterado o LIKE do shared "shr_cdestcvl" da
                            crapass para crapttl (Douglas - Chamado 131253)
                            
               24/07/2015 - Reformulacao cadastral (Gabriel-RKAM).             
.............................................................................*/

{ includes/var_online.i }

/*Pelo fato da rotina Resp. Legal estar sendo chamada em outras rotinas,
  na includes/var_contas.i sera dado o "NEW" somente para quando for chamada
  pela rotina "MATRIC" */
{ includes/var_contas.i "NEW" WHEN glb_nmdatela = "MATRIC"}

{ sistema/generico/includes/b1wgen0072tt.i }
{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }


DEF INPUT PARAM par_nmrotina AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapass.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl AS INT                                    NO-UNDO.
DEF INPUT PARAM par_nrcpfcgc LIKE crapass.nrcpfcgc                     NO-UNDO.
DEF INPUT PARAM par_dtdenasc AS DATE                                   NO-UNDO.
DEF INPUT PARAM par_cdhabmen AS INT                                    NO-UNDO.
DEF OUTPUT PARAM par_permalte AS LOG                                   NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-cratcrl.

DEF NEW SHARED  VAR shr_dsnacion AS CHAR   FORMAT "x(15)"              NO-UNDO.
DEF NEW SHARED  VAR shr_cdestcvl LIKE crapttl.cdestcvl                 NO-UNDO.
DEF NEW SHARED  VAR shr_dsestcvl AS CHAR   FORMAT "x(12)"              NO-UNDO.

/* Variaveis para a regua de opcoes */
DEF VAR reg_dsdopcao AS CHAR EXTENT 4 INIT ["Alterar",
                                            "Consultar",
                                            "Excluir",
                                            "Incluir"]                 NO-UNDO.
DEF VAR reg_cddopcao AS CHAR EXTENT 4 INIT ["A","C","E","I"]           NO-UNDO.
DEF VAR reg_contador AS INT           INIT 1                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_nrdlinha AS INT                                            NO-UNDO.
     
DEF VAR tel_nrdctato LIKE crapcrl.nrdconta                             NO-UNDO.
DEF VAR tel_tpdeiden LIKE crapcrl.tpdeiden                             NO-UNDO.
DEF VAR tel_nridenti LIKE crapcrl.nridenti                             NO-UNDO.
DEF VAR tel_dsorgemi AS CHAR FORMAT "x(5)"                             NO-UNDO.
DEF VAR tel_cdufiden LIKE crapcrl.cdufiden                             NO-UNDO.
DEF VAR tel_dtemiden LIKE crapcrl.dtemiden                             NO-UNDO.
                   
DEF VAR tel_dtnascin LIKE crapcrl.dtnascin                             NO-UNDO.
DEF VAR tel_cddosexo AS CHAR   FORMAT "!"                              NO-UNDO.
DEF VAR tel_cdestciv LIKE crapcrl.cdestciv                             NO-UNDO.
DEF VAR tel_dsnacion LIKE crapcrl.dsnacion                             NO-UNDO.
DEF VAR tel_dsnatura LIKE crapcrl.dsnatura                             NO-UNDO.
DEF VAR tel_nmmaersp LIKE crapcrl.nmmaersp                             NO-UNDO.
DEF VAR tel_nmpairsp LIKE crapcrl.nmpairsp                             NO-UNDO.
                   
DEF VAR tel_cdcepres LIKE crapcrl.cdcepres                             NO-UNDO.
DEF VAR tel_dsendres LIKE crapcrl.dsendres                             NO-UNDO.
DEF VAR tel_nrendres LIKE crapcrl.nrendres                             NO-UNDO.
DEF VAR tel_dscomres LIKE crapcrl.dscomres                             NO-UNDO.
DEF VAR tel_dsbaires AS CHAR FORMAT "X(40)"                            NO-UNDO.
DEF VAR tel_dscidres AS CHAR FORMAT "X(25)"                            NO-UNDO.
DEF VAR tel_dsdufres LIKE crapcrl.dsdufres                             NO-UNDO.
DEF VAR tel_nrcxpost LIKE crapcrl.nrcxpost                             NO-UNDO.
DEF VAR tel_cdrlcrsp LIKE crapcrl.cdrlcrsp                             NO-UNDO.
DEF VAR tel_dsrlcrsp AS CHAR                                           NO-UNDO.

DEF VAR aux_menorida AS LOGICAL                                        NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_msgconta AS CHARACTER                                      NO-UNDO.
DEF VAR aux_msgalert AS CHARACTER                                      NO-UNDO.
DEF VAR aux_ctamenrp AS INT                                            NO-UNDO.
DEF VAR aux_cpfmenrp AS DEC                                            NO-UNDO.
DEF VAR aux_seqmenrp AS INT                                            NO-UNDO.
DEF VAR aux_contarsp AS INT                                            NO-UNDO.
DEF VAR aux_cpfcgcrp AS DEC                                            NO-UNDO.
DEF VAR aux_gerabusc AS LOG                                            NO-UNDO.
DEF VAR aux_rowidcrl AS ROWID                                          NO-UNDO.
DEF VAR aux_rowidinc AS ROWID                                          NO-UNDO.
DEF VAR aux_ulregcri AS ROWID                                          NO-UNDO.

DEF VAR h-b1wgen0072 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0060 AS HANDLE                                         NO-UNDO.

DEF QUERY q_responsavel FOR tt-cratcrl.

DEF BROWSE b_responsavel QUERY q_responsavel
    DISPLAY tt-cratcrl.nrdconta                NO-LABEL   FORMAT  "zzzz,zzz,9"
            tt-cratcrl.nmrespon                NO-LABEL   FORMAT "x(32)"
            STRING(STRING(tt-cratcrl.nrcpfcgc,
                         "99999999999"),
                         "xxx.xxx.xxx-xx")     NO-LABEL   FORMAT "x(14)"
            tt-cratcrl.nridenti                NO-LABEL   FORMAT "x(15)"
            WITH 10 DOWN NO-BOX.

FORM SKIP(1)
     "Conta/dv"       AT  5
     "Nome"           AT 14
     "C.P.F."         AT 47
     "Documento"      AT 62
     SKIP(10)
     reg_dsdopcao[1]  AT 15  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2]  AT 28  NO-LABEL FORMAT "x(9)"
     reg_dsdopcao[3]  AT 43  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[4]  AT 56  NO-LABEL FORMAT "x(7)"
     WITH ROW 7 WIDTH 80 OVERLAY SIDE-LABELS 
          TITLE " RESPONSAVEL LEGAL " FRAME f_regua.
 
FORM b_responsavel
     WITH ROW 10 COLUMN 2 OVERLAY NO-BOX FRAME f_browse.
     
FORM tel_nrdctato AT  1   LABEL " Conta/dv"
           HELP "Informe conta responsavel legal / F7-listar / 0-nao cooperado"
     tel_nrcpfcgc AT 30   LABEL "   C.P.F."
                          HELP "Informe o CPF do responsavel legal" 
                          VALIDATE(tel_nrcpfcgc <> "","375 - O campo deve ser preenchido.")
     SKIP
     tel_nmdavali AT  5  LABEL " Nome" 
                         HELP "Informe o nome do responsavel legal" 
     SKIP
     tel_tpdeiden AT  1  LABEL "Documento"  AUTO-RETURN
                         HELP "Entre com o tipo de documento (CH, CI, CP, CT)"
     tel_nridenti        NO-LABEL           AUTO-RETURN
                         HELP "Informe o documento do responsavel legal"
     tel_dsorgemi AT 31  LABEL "Org.Emi."   AUTO-RETURN
                         HELP "Informe o orgao emissor do documento"
     tel_cdufiden AT 49  LABEL "U.F."       AUTO-RETURN
                         HELP "Informe a Sigla do Estado que emitiu o documento"
     tel_dtemiden AT 58  LABEL "Data Emi."  AUTO-RETURN
                         HELP "Informe a data de emissao do documento" 
     SKIP
     tel_dtnascin AT  1  LABEL "Data Nascimento" AUTO-RETURN
                       HELP "Informe a data de nascimento do responsavel legal"
                                                 FORMAT "99/99/9999"
     tel_cddosexo AT 31  LABEL "Sexo"  HELP "(M)asculino / (F)eminino"
     tel_cdestciv        LABEL "  Estado Civil"
             HELP "Informe o codigo do estado civil ou pressione F7 para listar"
     tel_dsestcvl        NO-LABEL
     tel_dsnacion AT  3  LABEL "Nacionalidade"   AUTO-RETURN
                      HELP "Informe a nacionalidade ou pressione F7 para listar"
     tel_dsnatura AT 42  LABEL "Natural de"      AUTO-RETURN
                       HELP "Informe a naturalidade ou pressione F7 para listar"
     SKIP(1)
     tel_cdcepres AT  4  LABEL "CEP" FORMAT "99999,999"
              HELP "Informe o CEP do endereco ou pressione F7 para pesquisar"
     tel_dsendres AT 22  LABEL "End.Residencial"        AUTO-RETURN
                         HELP "Informe o endereco do responsavel legal" 
     SKIP
     tel_nrendres AT  3  LABEL "Nro."        AUTO-RETURN
                         HELP "Informe o numero da residencia"
     tel_dscomres AT 26  LABEL "Complemento" AUTO-RETURN
                         HELP "Informe o complemento do endereco" 
     SKIP
     tel_dsbaires AT  1  LABEL "Bairro"  AUTO-RETURN
                         HELP "Informe o nome do bairro"
     tel_nrcxpost AT 50  LABEL "Caixa Postal"
                         HELP "Informe o numero da caixa postal"
     SKIP
     tel_dscidres AT 1   LABEL "Cidade"  AUTO-RETURN
                         HELP "Informe o nome da cidade"
     tel_dsdufres AT 50  LABEL "U.F."    AUTO-RETURN 
                         HELP "Informe a Sigla do Estado"
     SKIP 
     "Filiacao:"
     tel_nmmaersp AT 11  LABEL "Mae"
                         HELP "Informe o nome da mae do responsavel legal"
     SKIP
     tel_nmpairsp AT 11  LABEL "Pai"
                         HELP "Informe o nome do pai do responsavel legal"
     SKIP
     tel_cdrlcrsp AT  1 LABEL "Relacionamento com Titular"
                        HELP "Informe o relacionamento ou pressione F7 para pesquisar"
     tel_dsrlcrsp       NO-LABEL
     WITH ROW 8 COLUMN 2 WIDTH 78 OVERLAY SIDE-LABELS NO-BOX 
          FRAME f_responsavel.


/* Inclusão de CEP integrado. (André - DB1) */
ON GO, LEAVE OF tel_cdcepres IN FRAME f_responsavel DO:
    IF  INPUT tel_cdcepres = 0  THEN
        RUN Limpa_Endereco.
END.

ON RETURN OF tel_cdcepres IN FRAME f_responsavel DO:

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT tel_cdcepres.

    IF tel_cdcepres <> 0  THEN 
       DO:
           RUN fontes/zoom_endereco.p (INPUT tel_cdcepres,
                                       OUTPUT TABLE tt-endereco).
    
           FIND FIRST tt-endereco NO-LOCK NO-ERROR.
    
           IF AVAIL tt-endereco THEN
              DO:
                  ASSIGN tel_cdcepres = tt-endereco.nrcepend 
                         tel_dsendres = tt-endereco.dsendere 
                         tel_dsbaires = tt-endereco.nmbairro 
                         tel_dscidres = tt-endereco.nmcidade 
                         tel_dsdufres = tt-endereco.cdufende.
              END.
           ELSE
              DO:
                  IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                     RETURN NO-APPLY.
                      
                  MESSAGE "CEP nao cadastrado.".
                  RUN Limpa_Endereco.
                  RETURN NO-APPLY.

              END.

       END.
    ELSE
        RUN Limpa_Endereco.

    DISPLAY tel_cdcepres  
            tel_dsendres
            tel_dsbaires  
            tel_dscidres
            tel_dsdufres
            WITH FRAME f_responsavel.

    NEXT-PROMPT tel_nrendres WITH FRAME f_responsavel.

END.

ON ENTRY OF b_responsavel IN FRAME f_browse DO:

   IF aux_nrdlinha > 0   THEN
      REPOSITION q_responsavel TO ROW(aux_nrdlinha).

END.

ON ANY-KEY OF b_responsavel IN FRAME f_browse DO:


   HIDE MESSAGE NO-PAUSE.

   IF KEY-FUNCTION(LASTKEY) = "GO"   THEN
      RETURN NO-APPLY.

   IF KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT" AND
      aux_menorida          = YES            AND 
      par_nmrotina <> "PROC_JUR_CONS"        AND 
      par_nmrotina <> "MATRIC_CONS"          THEN
      DO:
          reg_contador = reg_contador + 1.
    
          IF reg_contador > 4   THEN
             reg_contador = 1.
              
          glb_cddopcao = reg_cddopcao[reg_contador].
      END.
   ELSE        
      IF KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT" AND
         aux_menorida          = YES           AND 
         par_nmrotina <> "PROC_JUR_CONS"       AND 
         par_nmrotina <> "MATRIC_CONS"         THEN
         DO:
             reg_contador = reg_contador - 1.
    
             IF reg_contador < 1   THEN
                reg_contador = 4.
                  
             glb_cddopcao = reg_cddopcao[reg_contador].
         END.
      ELSE
         IF KEY-FUNCTION(LASTKEY) = "HELP" THEN
            APPLY LASTKEY.
         ELSE
            IF KEY-FUNCTION(LASTKEY) = "RETURN" THEN
               DO:
                  IF AVAILABLE tt-cratcrl THEN
                     DO:   
                         ASSIGN aux_nrdrowid = tt-cratcrl.nrdrowid
                                aux_rowidcrl = ROWID(tt-cratcrl)
                                aux_nrdlinha = CURRENT-RESULT-ROW("q_responsavel")
                                aux_ctamenrp = tt-cratcrl.nrctamen
                                aux_cpfmenrp = tt-cratcrl.nrcpfmen
                                aux_seqmenrp = tt-cratcrl.idseqmen
                                aux_contarsp = tt-cratcrl.nrdconta
                                aux_cpfcgcrp = tt-cratcrl.nrcpfcgc.
                              
                         /* Desmarca todas as linhas do browse para poder 
                            remarcar*/
                         b_responsavel:DESELECT-ROWS().
                     END.
                  ELSE
                     ASSIGN aux_nrdrowid = ?
                            aux_rowidcrl = ?
                            aux_nrdlinha = 0
                            aux_ctamenrp = 0
                            aux_cpfmenrp = 0
                            aux_seqmenrp = 0
                            aux_contarsp = 0
                            aux_cpfcgcrp = 0.
                            
          
                  ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].
                  
                  APPLY "GO".
               END.
            ELSE
               RETURN.

   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

END.

/* Nao deixa passar pelo CPF sem ser um numero valido */
ON LEAVE OF tel_nrcpfcgc IN FRAME f_responsavel DO:

   ASSIGN INPUT tel_nrcpfcgc.

   IF NOT DYNAMIC-FUNCTION("ValidaCpfCnpj" IN h-b1wgen0060,
                           INPUT tel_nrcpfcgc,
                           OUTPUT glb_dscritic) THEN 
      DO: 
          MESSAGE glb_dscritic.
          NEXT-PROMPT tel_nrcpfcgc WITH FRAME f_responsavel.
          RETURN NO-APPLY.
      END.

   HIDE MESSAGE NO-PAUSE.
END.

/* Atualiza o estado civil */
ON LEAVE, GO OF tel_cdestciv IN FRAME f_responsavel DO:

   /* Estado civil */
   ASSIGN INPUT tel_cdestciv.

   DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                    INPUT tel_cdestciv,
                    INPUT "dsestcvl",
                    OUTPUT tel_dsestcvl,
                    OUTPUT glb_dscritic).

   DISPLAY tel_dsestcvl WITH FRAME f_responsavel.
   
   IF glb_dscritic <> "" THEN
      DO: 
         MESSAGE glb_dscritic.
         NEXT-PROMPT tel_cdestciv WITH FRAME f_responsavel.
         RETURN NO-APPLY.

      END.
END.

  
ASSIGN aux_gerabusc = TRUE.


DO WHILE TRUE:

   IF NOT VALID-HANDLE(h-b1wgen0072) THEN
      RUN sistema/generico/procedures/b1wgen0072.p
          PERSISTENT SET h-b1wgen0072.

   IF NOT VALID-HANDLE(h-b1wgen0060) THEN
      RUN sistema/generico/procedures/b1wgen0060.p 
          PERSISTENT SET h-b1wgen0060.

   ASSIGN glb_cddopcao = "C"
          tel_nrdctato = 0
          tel_nrcpfcgc = ""
          aux_nrdrowid = ?
          aux_ctamenrp = 0
          aux_cpfmenrp = 0
          aux_seqmenrp = 0
          aux_contarsp = 0
          aux_cpfcgcrp = 0
          par_permalte = TRUE.
   
   HIDE  FRAME f_regua.
   HIDE  FRAME f_browse.
   HIDE  FRAME f_responsavel.
   CLEAR FRAME f_responsavel.
   
   IF aux_gerabusc = TRUE THEN
      DO:
         IF par_nmrotina = "RESPONSAVEL LEGAL" OR
            par_nmrotina = "IDENTIFICACAO"     OR
           (par_nmrotina = "PROCURADORES"      AND
            glb_nmdatela = "CONTAS")           OR
            par_nmrotina = "PROC_JUR_CONS"     THEN
            DO: 
               EMPTY TEMP-TABLE tt-cratcrl.
                
               RUN Busca_Dados.
                
               ASSIGN aux_gerabusc = FALSE.
            
               IF RETURN-VALUE <> "OK" THEN
                  NEXT.
            
            END.
         ELSE
            IF par_nmrotina = "PROCURADORES" AND
               glb_nmdatela = "MATRIC"       THEN
               DO:
                  RUN Busca_Dados.
                
                  ASSIGN aux_gerabusc = FALSE.
               
                  IF RETURN-VALUE <> "OK" THEN
                     NEXT.
               
               END.
            ELSE
              IF par_nmrotina = "MATRIC"      OR 
                 par_nmrotina = "MATRIC_CONS" THEN
                  DO:
                     RUN Busca_Dados.
                   
                     ASSIGN aux_gerabusc = FALSE.
                  
                     IF RETURN-VALUE <> "OK" THEN
                        NEXT.
                  
                  END.

      END.

   ASSIGN glb_nmrotina = "RESPONSAVEL LEGAL"
          glb_cddopcao = reg_cddopcao[reg_contador]
          glb_cdcritic = 0.
    
   /* Somente a exclusao se for maior de idade */
   IF aux_menorida = NO THEN
      DO:
          ASSIGN reg_contador = 3
                 glb_cddopcao = reg_cddopcao[reg_contador].
          
          DISPLAY reg_dsdopcao[3] WITH FRAME f_regua.
      END.
   ELSE
      IF par_nmrotina = "PROC_JUR_CONS" OR
         par_nmrotina = "MATRIC_CONS"   THEN
         DO:
            ASSIGN reg_contador = 2
                   glb_cddopcao = reg_cddopcao[reg_contador].
            
            DISPLAY reg_dsdopcao[2] WITH FRAME f_regua.

         END.
           ELSE
              DISPLAY reg_dsdopcao WITH FRAME f_regua.

   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
  
   IF par_nmrotina = "PROCURADORES" THEN
      OPEN QUERY q_responsavel 
                 FOR EACH tt-cratcrl WHERE 
                          tt-cratcrl.deletado = FALSE                AND
                          tt-cratcrl.nrctamen = par_nrdconta         AND
                          tt-cratcrl.nrcpfmen = (IF par_nrdconta = 0 THEN 
                                                    par_nrcpfcgc
                                                 ELSE 
                                                    0)
                          NO-LOCK BY tt-cratcrl.nrdconta
                                   BY tt-cratcrl.nrcpfcgc.
   ELSE
      OPEN QUERY q_responsavel 
                 FOR EACH tt-cratcrl WHERE 
                          tt-cratcrl.deletado = FALSE               
                          NO-LOCK BY tt-cratcrl.nrdconta
                                   BY tt-cratcrl.nrcpfcgc.


   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE b_responsavel 
             WITH FRAME f_browse.

      LEAVE.

   END.

   IF KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
      LEAVE.
   
   /* Deixa o browse visivel e marca a linha que tinha sido selecionada */
   VIEW FRAME f_browse.

   IF aux_nrdlinha > 0   THEN
      REPOSITION q_responsavel TO ROW(aux_nrdlinha).        
        
   /*Alteração: Mostra critica se usuario titular em outra conta 
     (Gabriel/DB1)*/
   IF aux_msgconta <> "" AND glb_cddopcao <> "C" THEN
      DO: 
         MESSAGE aux_msgconta. 
         NEXT.
      END.

   { includes/acesso.i }

   IF glb_cddopcao = "I"   THEN
      DO:
         CLEAR FRAME f_responsavel.

         IF par_nmrotina = "PROCURADORES"             AND 
            par_nrdconta <> 0                         THEN
             DO:
                ASSIGN par_permalte = FALSE.

                RUN Valida_Dados.
    
                IF RETURN-VALUE <> "OK" THEN
                   DO:
                      ASSIGN aux_gerabusc = TRUE.
                      NEXT.                     
                   END.
                
             END.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
          
            ASSIGN tel_nrdctato = 0
                   tel_nrcpfcgc = ""
                   aux_nrdrowid = ?.
                   
            UPDATE tel_nrdctato 
                   WITH FRAME f_responsavel
            
            EDITING:

              DO WHILE TRUE:

                 READKEY PAUSE 1.

                 IF LASTKEY = KEYCODE("F7") THEN
                    DO:
                        RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                      OUTPUT tel_nrdctato).

                        IF tel_nrdctato > 0   THEN
                           DO:
                               DISPLAY tel_nrdctato 
                                       WITH FRAME f_responsavel.
                    
                               APPLY "GO".
                           END.
                    END.
                 ELSE
                    APPLY LASTKEY.

                 LEAVE.

              END.  /*  Fim do DO WHILE TRUE  */
            
            END.  /*  Fim do EDITING  */

            HIDE MESSAGE NO-PAUSE.
         
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_nrcpfcgc WHEN tel_nrdctato = 0
                      WITH FRAME f_responsavel.

               LEAVE.

            END.

            IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
               NEXT.
            
            RUN Busca_Dados.
           
            IF RETURN-VALUE <> "OK" THEN
               NEXT.
            
            RUN Atualiza_Tela.
                           
            IF RETURN-VALUE <> "OK" THEN
               DO: 
                   ASSIGN aux_gerabusc = TRUE.
                   NEXT.

               END.
            
            DISPLAY tel_nrcpfcgc    tel_nmdavali    tel_tpdeiden
                    tel_nridenti    tel_dsorgemi    tel_cdufiden
                    tel_dtemiden    tel_dtnascin    tel_cddosexo
                    tel_cdestciv    tel_dsestcvl    tel_dsnacion
                    tel_dsnatura    tel_cdcepres    tel_dsendres
                    tel_nrendres    tel_dscomres    tel_dsbaires
                    tel_dscidres    tel_dsdufres    tel_nrcxpost
                    tel_nmmaersp    tel_nmpairsp    tel_nrdctato
                    tel_cdrlcrsp    tel_dsrlcrsp
                    WITH FRAME f_responsavel.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_nmdavali WHEN tel_nrdctato = 0
                      tel_tpdeiden WHEN tel_nrdctato = 0
                      tel_nridenti WHEN tel_nrdctato = 0
                      tel_dsorgemi WHEN tel_nrdctato = 0
                      tel_cdufiden WHEN tel_nrdctato = 0
                      tel_dtemiden WHEN tel_nrdctato = 0
                      tel_dtnascin WHEN tel_nrdctato = 0
                      tel_cddosexo WHEN tel_nrdctato = 0
                      tel_cdestciv WHEN tel_nrdctato = 0
                      tel_dsnacion WHEN tel_nrdctato = 0
                      tel_dsnatura WHEN tel_nrdctato = 0
                      tel_cdcepres WHEN tel_nrdctato = 0
                      tel_nrendres WHEN tel_nrdctato = 0
                      tel_dscomres WHEN tel_nrdctato = 0
                      tel_nrcxpost WHEN tel_nrdctato = 0
                      tel_nmmaersp WHEN tel_nrdctato = 0
                      tel_nmpairsp WHEN tel_nrdctato = 0
                      tel_cdrlcrsp
                      WITH FRAME f_responsavel
                      
               EDITING:
               
                  READKEY.

                  HIDE MESSAGE NO-PAUSE.
                  
                  IF FRAME-FIELD = "tel_cddosexo"   THEN
                     DO:
                         /* So deixa escrever M ou F */
                         IF NOT CAN-DO("GO,RETURN,TAB,BACK-TAB," +
                            "BACKSPACE,END-ERROR,HELP,CURSOR-UP," +
                            "CURSOR-DOWN,CURSOR-LEFT,CURSOR-RIGHT,M,F",
                            KEY-FUNCTION(LASTKEY))   THEN
                            MESSAGE "Escolha (M)asculino / (F)eminino".
                         ELSE 
                            DO:
                               IF  KEY-FUNCTION(LASTKEY) = 
                                   "BACKSPACE"  THEN
                                   NEXT-PROMPT tel_cddosexo
                                               WITH FRAME f_responsavel.
                                           
                               HIDE MESSAGE NO-PAUSE.
                               APPLY LASTKEY.
                            END.
                     END.
                  ELSE               
                  IF LASTKEY = KEYCODE("F7")  THEN
                     DO:
                         IF  FRAME-FIELD = "tel_cdcepres"  THEN
                             DO:
                             /* Inclusão de CEP integrado. (André - DB1) */
                                 RUN fontes/zoom_endereco.p 
                                               (INPUT 0,
                                                OUTPUT TABLE tt-endereco).
                         
                                 FIND FIRST tt-endereco NO-LOCK NO-ERROR.
                         
                                 IF  AVAIL tt-endereco  THEN
                                     ASSIGN tel_cdcepres = 
                                                     tt-endereco.nrcepend
                                            tel_dsendres = 
                                                     tt-endereco.dsendere
                                            tel_dsbaires =
                                                     tt-endereco.nmbairro
                                            tel_dscidres = 
                                                     tt-endereco.nmcidade
                                            tel_dsdufres = 
                                                     tt-endereco.cdufende.
                                                           
                                 DISPLAY tel_cdcepres  tel_dsendres
                                         tel_dsbaires  tel_dscidres
                                         tel_dsdufres
                                         WITH FRAME f_responsavel.

                                 IF  KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
                                     NEXT-PROMPT tel_nrendres 
                                                 WITH FRAME f_responsavel.

                             END.
                         ELSE
                         IF FRAME-FIELD = "tel_dsnacion"  THEN
                            DO:
                                shr_dsnacion = INPUT tel_dsnacion.
                                RUN fontes/nacion.p.
                                IF shr_dsnacion <> " " THEN
                                   DO:
                                       tel_dsnacion = shr_dsnacion.
                                       DISPLAY tel_dsnacion
                                              WITH FRAME f_responsavel.

                                       NEXT-PROMPT tel_dsnacion
                                              WITH FRAME f_responsavel.

                                   END.
                            END.
                         ELSE
                         IF FRAME-FIELD = "tel_cdestciv"  THEN
                            DO:
                                shr_cdestcvl = INPUT tel_cdestciv.
                                RUN fontes/zoom_estcivil.p.
                                IF   shr_cdestcvl <> 0 THEN
                                     DO:
                                         ASSIGN tel_cdestciv =
                                                        shr_cdestcvl
                                                tel_dsestcvl = 
                                                        shr_dsestcvl.
                                         DISPLAY tel_cdestciv
                                                 tel_dsestcvl
                                                 WITH FRAME f_responsavel.
                                                 
                                         NEXT-PROMPT tel_cdestciv
                                                 WITH FRAME f_responsavel.
                                     END.
                                     
                                PAUSE 0.
                                VIEW FRAME f_regua.
                            END.
                         ELSE    
                         IF FRAME-FIELD = "tel_dsnatura" THEN
                            DO:
                                RUN fontes/natura.p (OUTPUT shr_dsnatura).
                                IF shr_dsnatura <> "" THEN
                                   DO:
                                       tel_dsnatura = shr_dsnatura.

                                       DISPLAY tel_dsnatura
                                               WITH FRAME f_responsavel.

                                       NEXT-PROMPT tel_dsnatura
                                               WITH FRAME f_responsavel.

                                   END.

                            END.
                        ELSE
                        IF  FRAME-FIELD = "tel_cdrlcrsp"   THEN
                            DO:
                                ASSIGN tel_cdrlcrsp = INPUT tel_cdrlcrsp.

                                RUN fontes/zoom_relacionamento.p 
                                                        (INPUT glb_cdcooper,
                                                  INPUT-OUTPUT tel_cdrlcrsp,
                                                  INPUT-OUTPUT tel_dsrlcrsp).

                                DISPLAY tel_cdrlcrsp
                                        tel_dsrlcrsp WITH FRAME f_responsavel.
                            END.

                     END. /* Fim do F7 */
                  ELSE
                     APPLY LASTKEY.

                  IF GO-PENDING THEN
                     DO:
                        RUN Valida_Dados.
               
                        IF RETURN-VALUE <> "OK" THEN
                           DO:
                               IF par_nmrotina = "RESPONSAVEL LEGAL" THEN
                                  ASSIGN aux_gerabusc = TRUE.
                               ELSE
                                  ASSIGN aux_gerabusc = FALSE.

                               /* se ocorreu erro, volta ao campo correto*/
                               {sistema/generico/includes/foco_campo.i 
                                   &VAR-GERAL=SIM 
                                   &NOME-FRAME="f_responsavel"
                                   &NOME-CAMPO=aux_nmdcampo }
                                   
                           END.    

                       RUN Busca_Responsavel (INPUT INPUT tel_cdrlcrsp,
                                              INPUT TRUE).

                       IF   RETURN-VALUE <> "OK"   THEN
                            DO: 
                                NEXT-PROMPT tel_cdrlcrsp 
                                            WITH FRAME f_responsavel.
                                NEXT.
                            END.
                     END.

               END. /* Fim do EDITING */

               /* Se veio da crabttl tira "." e "-" pra fazer a busca */
               ASSIGN tel_nrcpfcgc = REPLACE(tel_nrcpfcgc,".","")
                      tel_nrcpfcgc = REPLACE(tel_nrcpfcgc,"-","").
               
               LEAVE.

            END.

            IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
               NEXT.

            IF par_nmrotina = "RESPONSAVEL LEGAL" THEN
               DO:
                  RUN Valida_Dados.
                  
                  IF RETURN-VALUE <> "OK" THEN
                     DO:
                        ASSIGN aux_gerabusc = TRUE.
                        NEXT.                     

                     END.

               END.
                              
            LEAVE.

         END. /* Fim DO WHILE */

         IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
            NEXT.
         
         ASSIGN tel_nmdavali = CAPS(tel_nmdavali)
                tel_dsorgemi = CAPS(tel_dsorgemi)
                tel_cdufiden = CAPS(tel_cdufiden)
                tel_dsnacion = CAPS(tel_dsnacion)
                tel_dsnatura = CAPS(tel_dsnatura)
                tel_dsendres = CAPS(tel_dsendres)
                tel_dscomres = CAPS(tel_dscomres)
                tel_dsbaires = CAPS(tel_dsbaires)
                tel_dscidres = CAPS(tel_dscidres)
                tel_dsdufres = CAPS(tel_dsdufres)
                tel_nmmaersp = CAPS(tel_nmmaersp)
                tel_nmpairsp = CAPS(tel_nmpairsp).
                  
         DISPLAY tel_nmdavali    
                 tel_dsorgemi    
                 tel_cdufiden
                 tel_dsnacion    
                 tel_dsnatura    
                 tel_dsendres
                 tel_dscomres    
                 tel_dsbaires    
                 tel_dscidres
                 tel_dsdufres    
                 tel_nmmaersp    
                 tel_nmpairsp
                 WITH FRAME f_responsavel.

         IF par_nmrotina = "RESPONSAVEL LEGAL" THEN 
            DO:
                RUN Confirma.
                
                IF aux_confirma <> "S" THEN
                   DO:
                       ASSIGN aux_gerabusc = TRUE.
                       NEXT.
                   END.
                ELSE
                   DO:
                      RUN Grava_Dados.
                
                      ASSIGN aux_gerabusc = TRUE.

                      IF RETURN-VALUE <> "OK" THEN
                         NEXT.

                   END.

            END.
         ELSE
            DO:
               RUN Confirma.
                
               IF aux_confirma <> "S" THEN
                  DO: 
                      FIND tt-cratcrl WHERE ROWID(tt-cratcrl) = aux_rowidinc
                                            NO-LOCK NO-ERROR.

                      IF AVAIL tt-cratcrl THEN
                         DELETE tt-cratcrl.

                      NEXT.
                     
                  END.
               ELSE 
                  DO: 
                     ASSIGN aux_gerabusc = FALSE.

                     IF tel_nrdctato = 0 THEN
                        DO: 
                           CREATE tt-cratcrl.
                           
                           ASSIGN tt-cratcrl.nrdconta = tel_nrdctato
                                  tt-cratcrl.cdcooper = glb_cdcooper   
                                  tt-cratcrl.cddctato = tel_nrdctato 
                                  tt-cratcrl.nrcpfcgc = DEC(REPLACE(REPLACE(
                                                           tel_nrcpfcgc,".",""),"-",""))
                                  tt-cratcrl.nrctamen = par_nrdconta                
                                  tt-cratcrl.nrcpfmen = par_nrcpfcgc
                                  tt-cratcrl.idseqmen = par_idseqttl                
                                  tt-cratcrl.nmrespon = tel_nmdavali                
                                  tt-cratcrl.nridenti = tel_nridenti                
                                  tt-cratcrl.tpdeiden = tel_tpdeiden 
                                  tt-cratcrl.dsorgemi = tel_dsorgemi                
                                  tt-cratcrl.cdufiden = tel_cdufiden                
                                  tt-cratcrl.dtemiden = tel_dtemiden                
                                  tt-cratcrl.dtnascin = tel_dtnascin                
                                  tt-cratcrl.cddosexo = IF tel_cddosexo = "M" THEN 
                                                           1 
                                                        ELSE
                                                           2
                                  tt-cratcrl.cdestciv = tel_cdestciv                
                                  tt-cratcrl.dsnacion = tel_dsnacion                
                                  tt-cratcrl.dsnatura = tel_dsnatura                
                                  tt-cratcrl.cdcepres = tel_cdcepres               
                                  tt-cratcrl.dsendres = tel_dsendres                
                                  tt-cratcrl.nrendres = tel_nrendres                
                                  tt-cratcrl.dscomres = tel_dscomres                
                                  tt-cratcrl.dsbaires = tel_dsbaires                
                                  tt-cratcrl.nrcxpost = tel_nrcxpost                
                                  tt-cratcrl.dscidres = tel_dscidres                
                                  tt-cratcrl.dsdufres = tel_dsdufres
                                  tt-cratcrl.nmpairsp = tel_nmpairsp
                                  tt-cratcrl.nmmaersp = tel_nmmaersp
                                  tt-cratcrl.deletado = FALSE
                                  tt-cratcrl.cddopcao = glb_cddopcao
                                  tt-cratcrl.cdrlcrsp = tel_cdrlcrsp
                                  par_permalte = TRUE
                                  aux_ulregcri = ROWID(tt-cratcrl).
                             
                        END.
                     ELSE
                        ASSIGN tt-cratcrl.cdrlcrsp = tel_cdrlcrsp.

                     RUN Valida_Dados.

                     IF RETURN-VALUE <> "OK" THEN
                        DO:
                           IF tel_nrdctato <> 0 THEN 
                              DO:
                                 FIND tt-cratcrl WHERE 
                                      ROWID(tt-cratcrl) = aux_rowidinc
                                      NO-LOCK NO-ERROR.
                        
                                 IF AVAIL tt-cratcrl THEN
                                    DELETE tt-cratcrl.
                                 
                                 NEXT.

                              END.
                           ELSE
                              DO:
                                 FIND tt-cratcrl WHERE 
                                      ROWID(tt-cratcrl) = aux_ulregcri
                                      NO-LOCK NO-ERROR.
                        
                                 IF AVAIL tt-cratcrl THEN
                                    DELETE tt-cratcrl.
                                 
                                 NEXT.
                           
                              END.


                        END.
                      
                  END. 
                   
            END.                  

      END.
   ELSE
      IF glb_cddopcao = "C" THEN
         DO:
            IF par_nmrotina = "RESPONSAVEL LEGAL" THEN
               DO: 
                  RUN Busca_Dados.
                  
                  IF RETURN-VALUE <> "OK" THEN
                     NEXT.
            
                  RUN Atualiza_Tela.
            
                  IF RETURN-VALUE <> "OK" THEN
                     NEXT.
            
               END.
            ELSE
               DO:    
                  IF aux_nrdrowid <> ? THEN
                     FIND tt-cratcrl WHERE
                                     tt-cratcrl.cdcooper = glb_cdcooper AND
                                     tt-cratcrl.nrctamen = aux_ctamenrp AND
                                     tt-cratcrl.nrcpfmen = aux_cpfmenrp AND
                                     tt-cratcrl.idseqmen = aux_seqmenrp AND
                                     tt-cratcrl.nrdconta = aux_contarsp AND
                                     tt-cratcrl.nrcpfcgc = aux_cpfcgcrp
                                     NO-LOCK NO-ERROR.
                  ELSE           
                     FIND tt-cratcrl WHERE ROWID(tt-cratcrl) = aux_rowidcrl
                                           NO-LOCK NO-ERROR.

            
                  IF NOT AVAIL tt-cratcrl THEN
                     NEXT.
            
                  RUN Atualiza_Tela_tt-cratcrl.
            
                  IF RETURN-VALUE <> "OK" THEN
                     NEXT.
                
               END.
            
            DISPLAY tel_nrdctato    tel_nrcpfcgc    tel_nmdavali
                    tel_tpdeiden    tel_nridenti    tel_dsorgemi
                    tel_cdufiden    tel_dtemiden    tel_dtnascin
                    tel_cddosexo    tel_cdestciv    tel_dsnacion
                    tel_dsnatura    tel_cdcepres    tel_dsendres
                    tel_nrendres    tel_dscomres    tel_dsbaires
                    tel_dscidres    tel_dsdufres    tel_nrcxpost
                    tel_nmmaersp    tel_nmpairsp    tel_dsestcvl
                    tel_cdrlcrsp   
                    WITH FRAME f_responsavel.
                    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               PAUSE.
               LEAVE.

            END.
            
            IF par_nmrotina = "RESPONSAVEL LEGAL" THEN
               ASSIGN aux_gerabusc = TRUE.
            ELSE
               ASSIGN aux_gerabusc = FALSE.

      
         END.
      ELSE
         IF glb_cddopcao = "A" THEN
            DO:
               ASSIGN par_permalte = FALSE.

               IF par_nmrotina = "PROCURADORES" AND 
                  par_nrdconta <> 0            THEN
                  DO:
                     ASSIGN par_permalte = FALSE.
             
                     RUN Valida_Dados.
             
                     IF RETURN-VALUE <> "OK" THEN
                        DO:
                           ASSIGN aux_gerabusc = TRUE.
                           NEXT.     

                        END.
                     
                  END.

               
               IF par_nmrotina = "RESPONSAVEL LEGAL" THEN
                  DO: 
                     RUN Busca_Dados.
                     
                     IF RETURN-VALUE <> "OK" THEN
                        NEXT.
         
                     RUN Atualiza_Tela.
          
                     IF RETURN-VALUE <> "OK" THEN
                        NEXT.
        
                  END.
               ELSE
                  DO:
                     FIND tt-cratcrl WHERE tt-cratcrl.cdcooper = glb_cdcooper AND
                                           tt-cratcrl.nrctamen = aux_ctamenrp AND
                                           tt-cratcrl.nrcpfmen = aux_cpfmenrp AND
                                           tt-cratcrl.idseqmen = aux_seqmenrp AND
                                           tt-cratcrl.nrdconta = aux_contarsp AND
                                           tt-cratcrl.nrcpfcgc = aux_cpfcgcrp
                                           NO-LOCK NO-ERROR.
         
                     IF NOT AVAIL tt-cratcrl THEN
                        NEXT.
         
                     RUN Atualiza_Tela_tt-cratcrl.
         
                     IF RETURN-VALUE <> "OK" THEN
                        NEXT.
                   
                  END.
                  

               DISPLAY tel_nrdctato    tel_nrcpfcgc    tel_nmdavali
                       tel_tpdeiden    tel_nridenti    tel_dsorgemi
                       tel_cdufiden    tel_dtemiden    tel_dtnascin
                       tel_cddosexo    tel_cdestciv    tel_dsnacion
                       tel_dsnatura    tel_cdcepres    tel_dsendres
                       tel_nrendres    tel_dscomres    tel_dsbaires
                       tel_dscidres    tel_dsdufres    tel_nrcxpost
                       tel_nmmaersp    tel_nmpairsp    tel_dsestcvl
                       tel_cdrlcrsp     
                       WITH FRAME f_responsavel.
               
               IF par_nmrotina = "RESPONSAVEL LEGAL" OR 
                  par_nmrotina = "MATRIC"            OR 
                  par_nmrotina = "IDENTIFICACAO"     OR 
                 (par_nmrotina = "PROCURADORES"      AND
                  tel_nrdctato = 0)                  THEN
                  DO:
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     
                         UPDATE tel_nmdavali WHEN tel_nrdctato = 0
                                tel_tpdeiden WHEN tel_nrdctato = 0
                                tel_nridenti WHEN tel_nrdctato = 0
                                tel_dsorgemi WHEN tel_nrdctato = 0
                                tel_cdufiden WHEN tel_nrdctato = 0
                                tel_dtemiden WHEN tel_nrdctato = 0
                                tel_dtnascin WHEN tel_nrdctato = 0
                                tel_cddosexo WHEN tel_nrdctato = 0
                                tel_cdestciv WHEN tel_nrdctato = 0
                                tel_dsnacion WHEN tel_nrdctato = 0
                                tel_dsnatura WHEN tel_nrdctato = 0
                                tel_cdcepres WHEN tel_nrdctato = 0
                                tel_nrendres WHEN tel_nrdctato = 0
                                tel_dscomres WHEN tel_nrdctato = 0
                                tel_nrcxpost WHEN tel_nrdctato = 0
                                tel_nmmaersp WHEN tel_nrdctato = 0
                                tel_nmpairsp WHEN tel_nrdctato = 0
                                tel_cdrlcrsp 
                                WITH FRAME f_responsavel
                     
                         EDITING:
                     
                            READKEY.
                     
                            HIDE MESSAGE NO-PAUSE.
                     
                            IF FRAME-FIELD = "tel_cddosexo"   THEN
                               DO:
                                   /* So deixa escrever M ou F */
                                   IF NOT CAN-DO("GO,RETURN,TAB,BACK-TAB," +
                                      "BACKSPACE,END-ERROR,HELP,CURSOR-UP," +
                                      "CURSOR-DOWN,CURSOR-LEFT,CURSOR-RIGHT,M,F",
                                      KEY-FUNCTION(LASTKEY))   THEN
                                      MESSAGE "Escolha (M)asculino / (F)eminino".
                                   ELSE 
                                      DO:
                                         IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE" THEN
                                             NEXT-PROMPT tel_cddosexo
                                                         WITH FRAME f_responsavel.
                     
                                         HIDE MESSAGE NO-PAUSE.
                                         APPLY LASTKEY.
                                      END.
                               END.
                            ELSE
                            IF LASTKEY = KEYCODE("F7") THEN
                               DO:
                                  IF FRAME-FIELD = "tel_cdcepres"  THEN
                                     DO:
                                        /* Inclusão de CEP integrado. (André - DB1) */
                                        RUN fontes/zoom_endereco.p 
                                                      (INPUT 0,
                                                       OUTPUT TABLE tt-endereco).
                                    
                                        FIND FIRST tt-endereco NO-LOCK NO-ERROR.
                                    
                                        IF AVAIL tt-endereco THEN
                                           ASSIGN tel_cdcepres = tt-endereco.nrcepend
                                                  tel_dsendres = tt-endereco.dsendere
                                                  tel_dsbaires = tt-endereco.nmbairro
                                                  tel_dscidres = tt-endereco.nmcidade
                                                  tel_dsdufres = tt-endereco.cdufende.
                                                                  
                                        DISPLAY tel_cdcepres    
                                                tel_dsendres
                                                tel_dsbaires
                                                tel_dscidres
                                                tel_dsdufres
                                                WITH FRAME f_responsavel.
                     
                                        IF KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
                                           NEXT-PROMPT tel_nrendres 
                                                       WITH FRAME f_responsavel.
                     
                                     END. 
                                 
                                  IF FRAME-FIELD = "tel_dsnacion"  THEN
                                     DO:
                                        shr_dsnacion = INPUT tel_dsnacion.
                                        RUN fontes/nacion.p.
                                        IF   shr_dsnacion <> " " THEN
                                             DO:
                                                 tel_dsnacion = shr_dsnacion.
                     
                                                 DISPLAY tel_dsnacion
                                                         WITH FRAME f_responsavel.
                     
                                                 NEXT-PROMPT tel_dsnacion
                                                             WITH FRAME f_responsavel.
                     
                                             END.
                                     END.
                                  ELSE
                                  IF FRAME-FIELD = "tel_cdestciv"  THEN
                                     DO:
                                        shr_cdestcvl = INPUT tel_cdestciv.
                                        RUN fontes/zoom_estcivil.p.
                                        IF shr_cdestcvl <> 0 THEN
                                           DO:
                                               ASSIGN tel_cdestciv = shr_cdestcvl
                                                      tel_dsestcvl = shr_dsestcvl.
                     
                                               DISPLAY tel_cdestciv
                                                       tel_dsestcvl
                                                       WITH FRAME f_responsavel.
                     
                                               NEXT-PROMPT tel_cdestciv
                                                           WITH FRAME f_responsavel.
                                           END.
                     
                                        PAUSE 0.
                                        VIEW FRAME f_regua.
                     
                                     END.
                                  ELSE    
                                  IF FRAME-FIELD = "tel_dsnatura" THEN
                                     DO:
                                        RUN fontes/natura.p (OUTPUT shr_dsnatura).
                                        IF shr_dsnatura <> "" THEN
                                           DO:
                                               tel_dsnatura = shr_dsnatura.
                     
                                               DISPLAY tel_dsnatura
                                                       WITH FRAME f_responsavel.
                     
                                               NEXT-PROMPT tel_dsnatura
                                                           WITH FRAME f_responsavel.
                     
                                           END.
                     
                                     END.
                                  ELSE
                                  IF  FRAME-FIELD = "tel_cdrlcrsp"   THEN
                                      DO:
                                          ASSIGN tel_cdrlcrsp = INPUT tel_cdrlcrsp.
                                    
                                          RUN fontes/zoom_relacionamento.p 
                                                                  (INPUT glb_cdcooper,
                                                            INPUT-OUTPUT tel_cdrlcrsp,
                                                            INPUT-OUTPUT tel_dsrlcrsp).
                                    
                                          DISPLAY tel_cdrlcrsp
                                                  tel_dsrlcrsp WITH FRAME f_responsavel.
                                      END.
                                  
                     
                               END. /* Fim do F7 */
                            ELSE
                                APPLY LASTKEY.
                     
                            IF GO-PENDING THEN
                               DO:
                                   RUN Valida_Dados.
                     
                                   IF RETURN-VALUE <> "OK" THEN
                                      DO:
                                         
                                         /* se ocorreu erro, volta ao campo correto */
                                         {sistema/generico/includes/foco_campo.i 
                                             &NOME-FRAME="f_responsavel"
                                             &NOME-CAMPO=aux_nmdcampo }
                                      END.

                                   RUN Busca_Responsavel 
                                             (INPUT INPUT tel_cdrlcrsp,
                                              INPUT TRUE).

                                   IF   RETURN-VALUE <> "OK"   THEN
                                        DO: 
                                            NEXT-PROMPT tel_cdrlcrsp 
                                                        WITH FRAME f_responsavel.
                                            NEXT.
                                        END.
                     
                               END.
                     
                         END. /* Fim do EDITING */
                     
                     
                         LEAVE.
                     END.
                                                 
                     IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                        DO:
                            ASSIGN aux_gerabusc = TRUE.
                            NEXT.
                        END.

                  END.
               ELSE 
                  ASSIGN par_permalte = FALSE.
               
               RUN Valida_Dados.
          
               IF RETURN-VALUE <> "OK" THEN
                  NEXT.
                   
               ASSIGN tel_nmdavali = CAPS(tel_nmdavali)
                      tel_dsorgemi = CAPS(tel_dsorgemi)
                      tel_cdufiden = CAPS(tel_cdufiden)
                      tel_dsnacion = CAPS(tel_dsnacion)
                      tel_dsnatura = CAPS(tel_dsnatura)
                      tel_dsendres = CAPS(tel_dsendres)
                      tel_dscomres = CAPS(tel_dscomres)
                      tel_dsbaires = CAPS(tel_dsbaires)
                      tel_dscidres = CAPS(tel_dscidres)
                      tel_dsdufres = CAPS(tel_dsdufres)
                      tel_nmmaersp = CAPS(tel_nmmaersp)
                      tel_nmpairsp = CAPS(tel_nmpairsp).
         
               DISPLAY tel_nmdavali    tel_dsorgemi    tel_cdufiden
                       tel_dsnacion    tel_dsnatura    tel_dsendres
                       tel_dscomres    tel_dsbaires    tel_dscidres
                       tel_dsdufres    tel_nmmaersp    tel_nmpairsp
                       WITH FRAME f_responsavel.
               
         
               IF par_nmrotina = "RESPONSAVEL LEGAL" THEN
                  DO:
                     RUN Confirma.
                    
                     IF aux_confirma <> "S" THEN
                        DO:
                           ASSIGN aux_gerabusc = TRUE.
                           NEXT.
                        END.
                     ELSE
                        DO:
                           RUN Grava_Dados.
         
                           ASSIGN aux_gerabusc = TRUE.
                       
                           IF RETURN-VALUE <> "OK" THEN
                              NEXT.

                        END.

                  END.
               ELSE
                  DO: 
                      RUN Confirma.
                    
                      IF aux_confirma <> "S" THEN
                         NEXT.

                      ASSIGN tt-cratcrl.nrdconta = tel_nrdctato        
                             tt-cratcrl.cdcooper = glb_cdcooper         
                             tt-cratcrl.cddctato = tel_nrdctato        
                             tt-cratcrl.nrcpfcgc = (IF tel_nrdctato = 0 THEN 
                                                       DEC(REPLACE(REPLACE(
                                                       tel_nrcpfcgc,".",""),"-",""))
                                                    ELSE
                                                       0)
                             tt-cratcrl.nrctamen = par_nrdconta        
                             tt-cratcrl.nrcpfmen = (IF par_nrdconta = 0 THEN 
                                                       par_nrcpfcgc        
                                                    ELSE
                                                       0)
                             tt-cratcrl.idseqmen = par_idseqttl        
                             tt-cratcrl.nmrespon = tel_nmdavali        
                             tt-cratcrl.nridenti = tel_nridenti        
                             tt-cratcrl.tpdeiden = tel_tpdeiden        
                             tt-cratcrl.dsorgemi = tel_dsorgemi        
                             tt-cratcrl.cdufiden = tel_cdufiden        
                             tt-cratcrl.dtemiden = tel_dtemiden        
                             tt-cratcrl.dtnascin = tel_dtnascin        
                             tt-cratcrl.cddosexo = IF tel_cddosexo = "M" THEN 
                                                      1
                                                   ELSE 
                                                      2     
                             tt-cratcrl.cdestciv = tel_cdestciv        
                             tt-cratcrl.dsnacion = tel_dsnacion        
                             tt-cratcrl.dsnatura = tel_dsnatura        
                             tt-cratcrl.cdcepres = tel_cdcepres        
                             tt-cratcrl.dsendres = tel_dsendres        
                             tt-cratcrl.nrendres = tel_nrendres        
                             tt-cratcrl.dscomres = tel_dscomres        
                             tt-cratcrl.dsbaires = tel_dsbaires        
                             tt-cratcrl.nrcxpost = tel_nrcxpost        
                             tt-cratcrl.dscidres = tel_dscidres        
                             tt-cratcrl.dsdufres = tel_dsdufres        
                             tt-cratcrl.nmpairsp = tel_nmpairsp        
                             tt-cratcrl.nmmaersp = tel_nmmaersp    
                             tt-cratcrl.cdrlcrsp = tel_cdrlcrsp 
                             tt-cratcrl.deletado = FALSE
                             tt-cratcrl.cddopcao = glb_cddopcao
                             aux_gerabusc = FALSE
                             par_permalte = TRUE.
                      
                  END.
         
            END.
         ELSE
            IF glb_cddopcao = "E" THEN
               DO:
                  IF par_nmrotina = "PROCURADORES" AND 
                     par_nrdconta <> 0             THEN
                     DO:
                        ASSIGN par_permalte = FALSE.
                   
                        RUN Valida_Dados.
                   
                        IF RETURN-VALUE <> "OK" THEN
                           DO:
                              ASSIGN aux_gerabusc = TRUE.
                              NEXT.   

                           END.
                        
                     END.

                  IF par_nmrotina = "RESPONSAVEL LEGAL" THEN
                     DO: 
                        RUN Busca_Dados.
                        
                        IF RETURN-VALUE <> "OK" THEN
                           NEXT.
            
                        RUN Atualiza_Tela.
             
                        IF RETURN-VALUE <> "OK" THEN
                           NEXT.
            
                     END.
                  ELSE
                     DO:
                        FIND tt-cratcrl WHERE 
                                        tt-cratcrl.cdcooper = glb_cdcooper AND
                                        tt-cratcrl.nrctamen = aux_ctamenrp AND
                                        tt-cratcrl.nrcpfmen = aux_cpfmenrp AND
                                        tt-cratcrl.idseqmen = aux_seqmenrp AND
                                        tt-cratcrl.nrdconta = aux_contarsp AND
                                        tt-cratcrl.nrcpfcgc = aux_cpfcgcrp AND
                                        ROWID(tt-cratcrl)   = aux_rowidcrl
                                        NO-LOCK NO-ERROR.
            
                        IF NOT AVAIL tt-cratcrl THEN
                           NEXT.
                        
                        RUN Atualiza_Tela_tt-cratcrl.

                        IF RETURN-VALUE <> "OK" THEN
                           NEXT.
                      
                        
                     END.
                  
                  DISPLAY tel_nrdctato    tel_nrcpfcgc    tel_nmdavali
                          tel_tpdeiden    tel_nridenti    tel_dsorgemi
                          tel_cdufiden    tel_dtemiden    tel_dtnascin
                          tel_cddosexo    tel_cdestciv    tel_dsnacion
                          tel_dsnatura    tel_cdcepres    tel_dsendres
                          tel_nrendres    tel_dscomres    tel_dsbaires
                          tel_dscidres    tel_dsdufres    tel_nrcxpost
                          tel_nmmaersp    tel_nmpairsp    tel_dsestcvl
                          tel_cdrlcrsp    
                          WITH FRAME f_responsavel.
                  
                  IF par_nmrotina = "RESPONSAVEL LEGAL" THEN
                     DO:
                        RUN Valida_Dados.
                     
                        IF RETURN-VALUE <> "OK" THEN
                           NEXT.

                        RUN Confirma.
                     
                        IF aux_confirma <> "S" THEN
                           NEXT.
                        ELSE
                           DO:
                              RUN Grava_Dados.
            
                              ASSIGN aux_gerabusc = TRUE.
            
                              IF RETURN-VALUE <> "OK" THEN
                                 NEXT.
            
                            END.
            
                     END.
                  ELSE
                     IF par_nmrotina = "IDENTIFICACAO" OR
                        par_nmrotina = "MATRIC"        THEN
                        DO: 
                           RUN Confirma.
                        
                           IF aux_confirma <> "S" THEN
                              NEXT.
                           ELSE
                              ASSIGN tt-cratcrl.deletado = TRUE
                                     tt-cratcrl.cddopcao = glb_cddopcao
                                     aux_gerabusc = FALSE 
                                     par_permalte = TRUE.
                         
                        END.
                     ELSE
                        IF par_nmrotina = "PROCURADORES" AND
                           par_nrdconta = 0              THEN
                           DO:
                              RUN Confirma.
                           
                              IF aux_confirma <> "S" THEN
                                 NEXT.
                              ELSE
                                 ASSIGN tt-cratcrl.deletado = TRUE
                                        tt-cratcrl.cddopcao = glb_cddopcao
                                        aux_gerabusc = FALSE 
                                        par_permalte = TRUE.

                           END.

               END.

END.

IF VALID-HANDLE(h-b1wgen0072) THEN
   DELETE OBJECT h-b1wgen0072.

IF VALID-HANDLE(h-b1wgen0060) THEN
   DELETE OBJECT h-b1wgen0060.

glb_cddopcao = "C".

HIDE FRAME f_regua.
HIDE FRAME f_browse.
HIDE FRAME f_responsavel.

/*.................................PROCEDURES................................*/

PROCEDURE Busca_Dados:
    
    ASSIGN aux_rowidinc = ?.

    RUN Busca_Dados IN h-b1wgen0072
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT par_nrdconta,
          INPUT par_idseqttl,
          INPUT YES,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_nrdctato,
          INPUT DEC(REPLACE(REPLACE(tel_nrcpfcgc,".",""),"-","")),
          INPUT aux_nrdrowid,
          INPUT par_nrcpfcgc,
          INPUT par_nmrotina,
          INPUT par_dtdenasc,
          INPUT par_cdhabmen,
          INPUT TRUE, 
         OUTPUT aux_menorida,
         OUTPUT aux_msgconta,
         OUTPUT TABLE tt-crapcrl,
         OUTPUT TABLE tt-erro) NO-ERROR.

    IF ERROR-STATUS:ERROR THEN
       DO:
          MESSAGE ERROR-STATUS:GET-MESSAGE(1).
          RETURN "NOK".
       END.

    IF RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
          FIND FIRST tt-erro NO-ERROR.

          IF AVAILABLE tt-erro THEN
             DO:
                MESSAGE tt-erro.dscritic.
                RETURN "NOK".

             END.

       END.

     FOR EACH tt-crapcrl:
                  
         IF   tt-crapcrl.cddopcao = "E" THEN
              NEXT.                
 
         FIND FIRST tt-cratcrl WHERE 
                    tt-cratcrl.cdcooper = tt-crapcrl.cdcooper AND
                    tt-cratcrl.nrctamen = tt-crapcrl.nrctamen AND
                    tt-cratcrl.nrcpfmen = tt-crapcrl.nrcpfmen AND
                    tt-cratcrl.idseqmen = tt-crapcrl.idseqmen AND
                    tt-cratcrl.nrdconta = tt-crapcrl.nrdconta AND
                    tt-cratcrl.nrcpfcgc = tt-crapcrl.nrcpfcgc
                    NO-LOCK NO-ERROR.
         
         IF   AVAIL tt-cratcrl THEN
              NEXT.
         
         CREATE tt-cratcrl.             
         BUFFER-COPY tt-crapcrl TO tt-cratcrl.
         ASSIGN aux_rowidinc = ROWID(tt-cratcrl).
                      
    END.

    RETURN "OK". 

END.

PROCEDURE Valida_Dados:

    DO WITH FRAME f_responsavel:

        ASSIGN INPUT tel_nmdavali
               INPUT tel_tpdeiden
               INPUT tel_nridenti
               INPUT tel_dsorgemi
               INPUT tel_cdufiden
               INPUT tel_dtemiden
               INPUT tel_dtnascin
               INPUT tel_cddosexo
               INPUT tel_cdestciv
               INPUT tel_dsnacion
               INPUT tel_dsnatura
               INPUT tel_cdcepres
               INPUT tel_dsendres
               INPUT tel_nrendres
               INPUT tel_dscomres
               INPUT tel_dsbaires
               INPUT tel_dscidres
               INPUT tel_dsdufres
               INPUT tel_nrcxpost
               INPUT tel_nmmaersp
               INPUT tel_nmpairsp
               INPUT tel_cdrlcrsp.

    END.
    
    RUN Valida_Dados IN h-b1wgen0072
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT par_nrdconta,
          INPUT par_idseqttl,
          INPUT YES,
          INPUT aux_nrdrowid,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_nrdctato,
          INPUT DEC(REPLACE(REPLACE(tel_nrcpfcgc,".",""),"-","")),
          INPUT tel_nmdavali,
          INPUT tel_tpdeiden,
          INPUT tel_nridenti,
          INPUT tel_dsorgemi,
          INPUT tel_cdufiden,
          INPUT tel_dtemiden,
          INPUT tel_dtnascin,
          INPUT (IF tel_cddosexo = "M" THEN 1 ELSE 2),
          INPUT tel_cdestciv,
          INPUT tel_dsnacion,
          INPUT tel_dsnatura,
          INPUT tel_cdcepres,
          INPUT tel_dsendres,
          INPUT tel_dsbaires,
          INPUT tel_dscidres,
          INPUT tel_dsdufres,
          INPUT tel_nmmaersp,
          INPUT NO, /*Flag replica*/
          INPUT par_nrcpfcgc,
          INPUT par_nmrotina,
          INPUT par_dtdenasc,
          INPUT par_cdhabmen,
          INPUT par_permalte,
          INPUT TABLE tt-cratcrl,
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

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

PROCEDURE Grava_Dados:

    IF VALID-HANDLE(h-b1wgen0072) THEN
       DELETE OBJECT h-b1wgen0072.

    RUN sistema/generico/procedures/b1wgen0072.p PERSISTENT SET h-b1wgen0072.

    RUN Grava_Dados IN h-b1wgen0072
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT par_nrdconta,
          INPUT par_idseqttl,
          INPUT YES,
          INPUT aux_nrdrowid,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_nrdctato,
          INPUT (IF tel_nrdctato = 0 THEN
                    DEC(REPLACE(REPLACE(tel_nrcpfcgc,".",""),"-",""))
                 ELSE
                    0),
          INPUT tel_nmdavali,
          INPUT tel_tpdeiden,
          INPUT tel_nridenti,
          INPUT tel_dsorgemi,
          INPUT tel_cdufiden,
          INPUT tel_dtemiden,
          INPUT tel_dtnascin,
          INPUT (IF tel_cddosexo = "M" THEN 
                    1 
                 ELSE 
                    2),
          INPUT tel_cdestciv,
          INPUT tel_dsnacion,
          INPUT tel_dsnatura,
          INPUT tel_cdcepres,
          INPUT tel_dsendres,
          INPUT tel_dsbaires,
          INPUT tel_dscidres,
          INPUT tel_nrendres,
          INPUT tel_dsdufres,
          INPUT tel_dscomres,
          INPUT tel_nrcxpost,
          INPUT tel_nmmaersp,
          INPUT tel_nmpairsp,
          INPUT (IF par_nrdconta = 0 THEN 
                    par_nrcpfcgc
                 ELSE
                    0),
          INPUT tel_cdrlcrsp,
          INPUT par_nmrotina,
         OUTPUT aux_msgalert,
         OUTPUT aux_tpatlcad,
         OUTPUT aux_msgatcad, 
         OUTPUT aux_chavealt, 
         OUTPUT TABLE tt-erro) NO-ERROR.                     
                                                             
    IF  ERROR-STATUS:ERROR THEN                              
        DO:                                                  
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    /* verificar se é necessario registrar o crapalt */
    RUN proc_altcad (INPUT "b1wgen0072.p").

    IF  VALID-HANDLE(h-b1wgen0072) THEN
        DELETE OBJECT h-b1wgen0072.
    
    IF  aux_msgalert <> "" THEN
        MESSAGE aux_msgalert.

    IF  RETURN-VALUE <> "OK" THEN
        NEXT.
                 
    RETURN "OK".

END.

PROCEDURE Atualiza_Tela:

  FIND FIRST tt-crapcrl NO-ERROR.

  IF AVAILABLE tt-crapcrl THEN 
     DO:
         ASSIGN tel_nrdctato = tt-crapcrl.nrdconta
                tel_nrcpfcgc = STRING(STRING(tt-crapcrl.nrcpfcgc,"99999999999"),
                               "xxx.xxx.xxx-xx")
                tel_nmdavali = tt-crapcrl.nmrespon 
                tel_tpdeiden = tt-crapcrl.tpdeiden 
                tel_nridenti = STRING(tt-crapcrl.nridenti) 
                tel_dsorgemi = tt-crapcrl.dsorgemi
                tel_cdufiden = tt-crapcrl.cdufiden
                tel_dtemiden = tt-crapcrl.dtemiden
                tel_dtnascin = tt-crapcrl.dtnascin
                tel_cddosexo = IF tt-crapcrl.cddosexo = 1 THEN 
                                  "M" 
                               ELSE 
                                  "F"
                tel_cdestciv = tt-crapcrl.cdestciv
                tel_dsestcvl = tt-crapcrl.dsestcvl
                tel_dsnacion = tt-crapcrl.dsnacion
                tel_dsnatura = tt-crapcrl.dsnatura
                tel_nmmaersp = tt-crapcrl.nmmaersp
                tel_nmpairsp = tt-crapcrl.nmpairsp
                tel_cdcepres = tt-crapcrl.cdcepres
                tel_dsendres = tt-crapcrl.dsendres
                tel_nrendres = tt-crapcrl.nrendres
                tel_dscomres = tt-crapcrl.dscomres
                tel_dsbaires = tt-crapcrl.dsbaires
                tel_dscidres = tt-crapcrl.dscidres
                tel_dsdufres = tt-crapcrl.dsdufres
                tel_nrcxpost = tt-crapcrl.nrcxpost
                tel_cdrlcrsp = tt-crapcrl.cdrlcrsp.

         RUN Busca_Responsavel (INPUT tel_cdrlcrsp,
                                INPUT FALSE).

     END.
  ELSE 
     DO:
         ASSIGN tel_nmdavali = ""
                tel_tpdeiden = ""
                tel_nridenti = ""
                tel_dsorgemi = ""
                tel_cdufiden = ""
                tel_dtemiden = ?
                tel_dtnascin = ?
                tel_cddosexo = "M"
                tel_cdestciv = 0
                tel_dsestcvl = ""
                tel_dsnacion = ""
                tel_dsnatura = ""
                tel_nmmaersp = ""
                tel_nmpairsp = ""
                tel_cdcepres = 0
                tel_dsendres = ""
                tel_nrendres = 0
                tel_dscomres = ""
                tel_dsbaires = ""
                tel_dscidres = ""
                tel_dsdufres = ""
                tel_nrcxpost = 0
                tel_cdrlcrsp = 0
                tel_dsrlcrsp = "".

     END.


  RETURN "OK".

END PROCEDURE.


PROCEDURE Atualiza_Tela_tt-cratcrl:

    IF AVAIL tt-cratcrl THEN
       DO: 
           ASSIGN tel_nrdctato = tt-cratcrl.nrdconta
                  tel_nrcpfcgc = STRING(STRING(tt-cratcrl.nrcpfcgc,
                                 "99999999999"),
                                 "xxx.xxx.xxx-xx")
                  tel_nmdavali = tt-cratcrl.nmrespon 
                  tel_tpdeiden = tt-cratcrl.tpdeiden 
                  tel_nridenti = STRING(tt-cratcrl.nridenti) 
                  tel_dsorgemi = tt-cratcrl.dsorgemi
                  tel_cdufiden = tt-cratcrl.cdufiden
                  tel_dtemiden = tt-cratcrl.dtemiden
                  tel_dtnascin = tt-cratcrl.dtnascin
                  tel_cddosexo = IF tt-cratcrl.cddosexo = 1 THEN 
                                    "M" 
                                 ELSE 
                                    "F"
                  tel_cdestciv = tt-cratcrl.cdestciv
                  tel_dsestcvl = tt-cratcrl.dsestcvl
                  tel_dsnacion = tt-cratcrl.dsnacion
                  tel_dsnatura = tt-cratcrl.dsnatura
                  tel_nmmaersp = tt-cratcrl.nmmaersp
                  tel_nmpairsp = tt-cratcrl.nmpairsp
                  tel_cdcepres = tt-cratcrl.cdcepres
                  tel_dsendres = tt-cratcrl.dsendres
                  tel_nrendres = tt-cratcrl.nrendres
                  tel_dscomres = tt-cratcrl.dscomres
                  tel_dsbaires = tt-cratcrl.dsbaires
                  tel_dscidres = tt-cratcrl.dscidres
                  tel_dsdufres = tt-cratcrl.dsdufres
                  tel_nrcxpost = tt-cratcrl.nrcxpost
                  tel_cdrlcrsp = tt-cratcrl.cdrlcrsp.

           RUN Busca_Responsavel (INPUT tel_cdrlcrsp,
                                  INPUT FALSE).

        END.
    ELSE 
       DO:
          ASSIGN tel_nmdavali = ""
                 tel_tpdeiden = ""
                 tel_nridenti = ""
                 tel_dsorgemi = ""
                 tel_cdufiden = ""
                 tel_dtemiden = ?
                 tel_dtnascin = ?
                 tel_cddosexo = "M"
                 tel_cdestciv = 0
                 tel_dsestcvl = ""
                 tel_dsnacion = ""
                 tel_dsnatura = ""
                 tel_nmmaersp = ""
                 tel_nmpairsp = ""
                 tel_cdcepres = 0
                 tel_dsendres = ""
                 tel_nrendres = 0
                 tel_dscomres = ""
                 tel_dsbaires = ""
                 tel_dscidres = ""
                 tel_dsdufres = ""
                 tel_nrcxpost = 0
                 tel_cdrlcrsp = 0.

       END.

    RETURN "OK".

END PROCEDURE.



PROCEDURE confirma.
    
   /* Confirma */
   RUN fontes/confirma.p (INPUT "",
                         OUTPUT aux_confirma).
                                
END PROCEDURE.

PROCEDURE Limpa_Endereco:

    ASSIGN tel_cdcepres = 0  
           tel_dsendres = ""  
           tel_dsbaires = "" 
           tel_dscidres = ""  
           tel_dsdufres = ""
           tel_nrendres = 0
           tel_dscomres = ""
           tel_nrcxpost = 0.

    DISPLAY tel_cdcepres  tel_dsendres
            tel_dsbaires  tel_dscidres
            tel_dsdufres  tel_nrendres
            tel_dscomres  tel_nrcxpost 
            WITH FRAME f_responsavel.

END PROCEDURE.

PROCEDURE Busca_Responsavel:

    DEF INPUT PARAM par_cdrlcrsp AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_flgatual AS LOGI                            NO-UNDO.

    RUN BuscaResponsavelLegal IN h-b1wgen0072
                        (INPUT glb_cdcooper,
                         INPUT 0,
                         INPUT 0,
                         INPUT par_cdrlcrsp,
                         INPUT "",
                        OUTPUT TABLE tt-erro,
                        OUTPUT TABLE Relacionamento).

    FIND FIRST Relacionamento WHERE
               Relacionamento.cdrelacionamento = par_cdrlcrsp 
               NO-LOCK NO-ERROR.

    IF   NOT AVAIL Relacionamento   THEN 
         DO: 
             IF   par_flgatual   THEN
                  DO:
                       MESSAGE "Relacionamento invalido.".
                  END.

             ASSIGN tel_dsrlcrsp = "".

             DISPLAY tel_dsrlcrsp WITH FRAME f_responsavel.

             RETURN "NOK".

         END.        

    ASSIGN tel_dsrlcrsp = Relacionamento.dsrelacionamento.

    DISPLAY tel_dsrlcrsp WITH FRAME f_responsavel.

    RETURN "OK".

END PROCEDURE.

/*...........................................................................*/
