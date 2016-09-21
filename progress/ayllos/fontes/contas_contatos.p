/* .............................................................................

   Programa: Fontes/contas_contatos.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Setembro/2006                   Ultima Atualizacao: 11/04/2011

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes aos contatos do
               Associado pela tela CONTAS (Pessoa Fisica).
               
   Observacao: O campo "crapavt.nrcpfcgc" eh usado para sequencial de inclusao
               de registro (usa incremento de 1).

   Alteracoes: 07/12/2006 - Nao criticar a existencia de pelo menos 1 contato
                            para os demais titulares (Evandro).
                            
               22/01/2007 - Criado campo DEM para mostrar se o contato que eh
                            associado esta demitido (Evandro).

               06/07/2007 - Criticas indnivel somente para tipos de 
                            contas > 7(Mirtes)

               31/07/2007 - Aumentado o tamanho do e-mail para 40 caracteres
                            (Evandro).
                            
               18/05/2010 - Adaptacao para uso de BO (Jose Luis, DB1)
               
               11/04/2011 - Inclusão de CEP integrado. (André - DB1)

..............................................................................*/

{ sistema/generico/includes/b1wgen0073tt.i}
{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/var_internet.i}
{ sistema/generico/includes/gera_log.i}
{ sistema/generico/includes/gera_erro.i}
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

/* Variaveis para a regua de opcoes */
DEF VAR reg_dsdopcao AS CHAR EXTENT 4 INIT ["Alterar",
                                            "Consultar",
                                            "Excluir",
                                            "Incluir"]                 NO-UNDO.
DEF VAR reg_cddopcao AS CHAR EXTENT 4 INIT ["A","C","E","I"]           NO-UNDO.
DEF VAR reg_contador AS INT           INIT 1                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_nrdlinha AS INT                                            NO-UNDO.

DEF VAR tel_nrdctato LIKE crapavt.nrdctato                             NO-UNDO.
DEF VAR tel_cdagenci LIKE crapavt.cdagenci                             NO-UNDO.
DEF VAR tel_nrcepend LIKE crapavt.nrcepend                             NO-UNDO.
DEF VAR tel_dsendere LIKE crapavt.dsendres[1]                          NO-UNDO.
DEF VAR tel_nrendere LIKE crapavt.nrendere                             NO-UNDO.
DEF VAR tel_complend LIKE crapavt.complend                             NO-UNDO.
DEF VAR tel_nmbairro AS CHAR FORMAT "X(40)"                            NO-UNDO.
DEF VAR tel_nmcidade AS CHAR FORMAT "X(25)"                            NO-UNDO.
DEF VAR tel_cdufende AS CHAR FORMAT "x(2)"                             NO-UNDO.
DEF VAR tel_nrcxapst LIKE crapavt.nrcxapst                             NO-UNDO.
DEF VAR tel_nrtelefo LIKE crapavt.nrtelefo                             NO-UNDO.

DEF VAR h-b1wgen0073 AS HANDLE                                         NO-UNDO.

DEF TEMP-TABLE cratavt  NO-UNDO
    FIELD nrdctato LIKE crapavt.nrdctato
    FIELD nmdavali LIKE crapavt.nmdavali
    FIELD nrtelefo LIKE crapavt.nrtelefo
    FIELD dsdemail LIKE crapavt.dsdemail
    FIELD dsdemiss AS LOGICAL FORMAT " S /   "
    FIELD nrdrowid AS ROWID.

DEF QUERY q_contatos FOR cratavt.

DEF BROWSE b_contatos QUERY q_contatos
    DISPLAY cratavt.nrdctato           NO-LABEL
            cratavt.nmdavali           NO-LABEL     FORMAT "x(17)"
            cratavt.nrtelefo           NO-LABEL     FORMAT "x(15)"
            cratavt.dsdemail           NO-LABEL     FORMAT "x(25)"
            cratavt.dsdemiss           NO-LABEL
            WITH 8 DOWN NO-BOX.


FORM SKIP(1)
     tel_nrdctato        LABEL "Conta/dv"
          HELP "Informe o numero da conta ou F7 p/listar,ou ZERO(nao cooperado)"
     tel_nmdavali        LABEL "   Nome"
                         HELP "Informe o nome"
                         VALIDATE(tel_nmdavali <> "",
                                  "375 - O campo deve ser preenchido.")
     SKIP(1)
     tel_nrcepend        LABEL "   CEP" FORMAT "99999,999"
          HELP "Informe o Cep do endereco ou pressione F7 para pesquisar"
     tel_dsendere        LABEL "   End.Residencial"
                         HELP "Informe o endereco residencial"
     SKIP
     tel_nrendere        LABEL "  Nro."
                         HELP "Informe o numero do endereco"
     tel_complend        LABEL "         Complemento"
                         HELP "Informe o complemento do endereco" 
     SKIP
     tel_nmbairro        LABEL "Bairro"
                         HELP "Informe o nome do bairro"
     
     tel_nrcxapst        LABEL " Caixa Postal"
                         HELP "Informe o numero da caixa postal"
     SKIP
     tel_nmcidade        LABEL "Cidade"
                         HELP "Informe o nome da cidade"
     tel_cdufende        LABEL "U.F."  AUTO-RETURN
                         VALIDATE(CAN-DO("RS,SC,PR,SP,RJ,ES,MG,MS,MT,GO,DF," +
                                         "BA,PE,PA,PI,MA,RO,RR,AC,AM,TO,AM," +
                                         "CE,SE,AL",tel_cdufende),
                                         "033 - Unidade da federacao errada.")
                         HELP "Informe a Sigla do Estado" 
     SKIP
     tel_nrtelefo        LABEL "Telefones"
                         HELP "Informe o(s) telefone(s) para contato" 
     SKIP
     tel_dsdemail  AT 4  LABEL "E_Mail"
                         HELP "Informe o e_mail para contato"  
     WITH ROW 11 WIDTH 78 OVERLAY SIDE-LABELS NO-BOX CENTERED 
          FRAME f_contatos_fisica.
               
               
FORM "Conta/dv"       AT  5
     "Nome"           AT 14
     "Telefone"       AT 35
     "E_Mail"         AT 51
     "DEM"            AT 74
     SKIP(8)
     reg_dsdopcao[1]  AT 15  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2]  AT 28  NO-LABEL FORMAT "x(9)"
     reg_dsdopcao[3]  AT 43  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[4]  AT 56  NO-LABEL FORMAT "x(7)"
     WITH ROW 10 WIDTH 80 OVERLAY SIDE-LABELS TITLE  
          " CONTATOS (PESSOAIS/COMERCIAIS) " 
          FRAME f_regua.

FORM b_contatos HELP "Pressione ENTER para selecionar / F4 ou END para sair"
     WITH ROW 12 COLUMN 2 OVERLAY NO-BOX FRAME f_browse.

/* Inclusão de CEP integrado. (André - DB1) */
ON GO, LEAVE OF tel_nrcepend IN FRAME f_contatos_fisica DO:
    IF  INPUT tel_nrcepend = 0  THEN
        RUN Limpa_Endereco.
END.

ON RETURN OF tel_nrcepend IN FRAME f_contatos_fisica DO:

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT tel_nrcepend.

    IF  tel_nrcepend <> 0  THEN 
        DO:
            RUN fontes/zoom_endereco.p (INPUT tel_nrcepend,
                                        OUTPUT TABLE tt-endereco).
    
            FIND FIRST tt-endereco NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-endereco THEN
                DO:
                    ASSIGN tel_nrcepend = tt-endereco.nrcepend 
                           tel_dsendere = tt-endereco.dsendere 
                           tel_nmbairro = tt-endereco.nmbairro 
                           tel_nmcidade = tt-endereco.nmcidade 
                           tel_cdufende = tt-endereco.cdufende.
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

    DISPLAY tel_nrcepend  tel_dsendere
            tel_nmbairro  tel_nmcidade
            tel_cdufende
            WITH FRAME f_contatos_fisica.

    NEXT-PROMPT tel_nrendere WITH FRAME f_contatos_fisica.
END.
          
ON ENTRY OF b_contatos IN FRAME f_browse DO:

   IF   aux_nrdlinha > 0   THEN
        REPOSITION q_contatos TO ROW(aux_nrdlinha).

END.

ON ANY-KEY OF b_contatos IN FRAME f_browse DO:

   IF   KEY-FUNCTION(LASTKEY) = "GO"   THEN
        RETURN NO-APPLY.

   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
        DO:
            reg_contador = reg_contador + 1.
    
            IF   reg_contador > 4   THEN
                 reg_contador = 1.
                
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE        
   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
        DO:
            reg_contador = reg_contador - 1.

            IF   reg_contador < 1   THEN
                 reg_contador = 4.
                 
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "HELP"   THEN
        APPLY LASTKEY.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "RETURN"   THEN
        DO:
           IF   AVAILABLE cratavt   THEN
                DO:
                    ASSIGN aux_nrdrowid = cratavt.nrdrowid
                           aux_nrdlinha = CURRENT-RESULT-ROW("q_contatos").
                         
                    /* Desmarca todas as linhas do browse para poder remarcar*/
                    b_contatos:DESELECT-ROWS().
                END.
           ELSE
                ASSIGN aux_nrdrowid = ?
                       aux_nrdlinha = 0.
                         
           APPLY "GO".
        END.
   ELSE
        RETURN.
            
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
END.

ASSIGN reg_contador = 2. /* Inicia com a CONSULTA */

DO WHILE TRUE:

   IF  NOT VALID-HANDLE(h-b1wgen0073) THEN
       RUN sistema/generico/procedures/b1wgen0073.p
           PERSISTENT SET h-b1wgen0073.

   ASSIGN glb_cddopcao = "C"
          aux_nrdrowid = ?
          tel_nrdctato = 0.

   RUN Busca_Dados.

   IF  RETURN-VALUE <> "OK" THEN
       NEXT.

   ASSIGN glb_nmrotina = "CONTATOS"
          glb_cddopcao = reg_cddopcao[reg_contador]
          glb_cdcritic = 0.
   
   HIDE  FRAME f_regua.
   HIDE  FRAME f_browse.
   HIDE  FRAME f_contatos_fisica.
   CLEAR FRAME f_contatos_fisica.

   DISPLAY reg_dsdopcao WITH FRAME f_regua.
           
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

   OPEN QUERY q_contatos FOR EACH cratavt NO-LOCK BY cratavt.nrdctato.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE b_contatos WITH FRAME f_browse.
      LEAVE.
   END.
   
   IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
        LEAVE.
   
   /* Deixa o browse visivel e marca a linha que tinha sido selecionada */
   VIEW FRAME f_browse.

   IF   aux_nrdlinha > 0   THEN
        REPOSITION q_contatos TO ROW(aux_nrdlinha).        
        
   { includes/acesso.i }
   
   IF   glb_cddopcao = "I"   THEN
        DO:                         
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
              tel_nrdctato = 0.
              aux_nrdrowid = ?.
              
              UPDATE tel_nrdctato WITH FRAME f_contatos_fisica

              EDITING:

                DO WHILE TRUE:

                   READKEY PAUSE 1.
               
                   IF   LASTKEY = KEYCODE("F7") THEN
                        DO:
                            RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                          OUTPUT tel_nrdctato).

                            IF   tel_nrdctato > 0   THEN
                                 DO:
                                     DISPLAY tel_nrdctato 
                                             WITH FRAME f_contatos_fisica.
                        
                                     PAUSE 0.
                     
                                     APPLY "RETURN".
                                 END.
                        END.
                   ELSE
                        APPLY LASTKEY.

                   LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */
              
              END.  /*  Fim do EDITING  */

              RUN Busca_Dados.

              IF  RETURN-VALUE <> "OK" THEN
                  NEXT.
                
              RUN Atualiza_Tela.

              IF  RETURN-VALUE <> "OK" THEN
                  NEXT.

              DISPLAY tel_nmdavali    tel_nrcepend    tel_dsendere
                      tel_nrendere    tel_complend    tel_nmbairro
                      tel_nmcidade    tel_cdufende    tel_nrcxapst
                      tel_nrtelefo    tel_dsdemail
                      WITH FRAME f_contatos_fisica.
                      
              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              
                 IF   tel_nrdctato = 0   THEN
                      DO:
                          UPDATE tel_nmdavali    tel_nrcepend
                                 tel_nrendere    tel_complend    
                                 tel_nrcxapst
                                 tel_nrtelefo    tel_dsdemail
                                 WITH FRAME f_contatos_fisica

                          EDITING:

                              READKEY.
                              HIDE MESSAGE NO-PAUSE.

                              IF  LASTKEY = KEYCODE("F7")  THEN
                                  DO:
                                  /* Inclusão de CEP integrado. (André - DB1) */
                                      IF  FRAME-FIELD = "tel_nrcepend"  THEN
                                          DO:
                                              RUN fontes/zoom_endereco.p 
                                                   (INPUT 0,
                                                    OUTPUT TABLE tt-endereco).
                                   
                                              FIND FIRST tt-endereco 
                                                         NO-LOCK NO-ERROR.
                    
                                              IF  AVAIL tt-endereco THEN
                                                  ASSIGN tel_nrcepend = 
                                                            tt-endereco.nrcepend
                                                         tel_dsendere = 
                                                            tt-endereco.dsendere
                                                         tel_nmbairro = 
                                                            tt-endereco.nmbairro
                                                         tel_nmcidade =
                                                            tt-endereco.nmcidade
                                                         tel_cdufende = 
                                                            tt-endereco.cdufende.
                                                                        
                                              DISPLAY tel_nrcepend    
                                                      tel_dsendere
                                                      tel_nmbairro
                                                      tel_nmcidade
                                                      tel_cdufende
                                                  WITH FRAME f_contatos_fisica.

                                              IF  KEYFUNCTION(LASTKEY) 
                                                             <> "END-ERROR" THEN
                                                  NEXT-PROMPT tel_nrendere 
                                                   WITH FRAME f_contatos_fisica.
                                          END.
                                  END.
                              ELSE
                                  APPLY LASTKEY.
                          END.

                          RUN Valida_Dados.

                          IF  RETURN-VALUE <> "OK" THEN
                              NEXT.

                          DISPLAY tel_nmdavali    tel_dsendere    tel_complend
                                  tel_nmbairro    tel_nmcidade    
                                  WITH FRAME f_contatos_fisica.
                      END.
                         
                 LEAVE.
              END.
              
              IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
                   NEXT.

              RUN Confirma.

              IF  aux_confirma <> "S" THEN
                  NEXT.
              ELSE
                  DO:
                     RUN Grava_Dados.

                     IF  RETURN-VALUE <> "OK" THEN
                         NEXT.
                  END.
           
              LEAVE.
           END.
        END. /* fim da opcao "I" */
   ELSE
   IF   glb_cddopcao = "C"   AND
        aux_nrdrowid <> ?    THEN
        DO:
           RUN Busca_Dados.
    
           IF  RETURN-VALUE <> "OK" THEN
               NEXT.
    
           RUN Atualiza_Tela.
    
           IF  RETURN-VALUE <> "OK" THEN
               NEXT.
                
            DISPLAY tel_nrdctato    tel_nmdavali    tel_nrcepend
                    tel_dsendere    tel_nrendere    tel_complend
                    tel_nmbairro    tel_nmcidade    tel_cdufende
                    tel_nrcxapst    tel_nrtelefo    tel_dsdemail
                    WITH FRAME f_contatos_fisica.
                   
            PAUSE.
        END. /* fim da opcao "C" */
   ELSE
   IF   glb_cddopcao = "E"   AND
        aux_nrdrowid <> ?    THEN
        DO:
           RUN Busca_Dados.
    
           IF  RETURN-VALUE <> "OK" THEN
               NEXT.

           RUN Atualiza_Tela.
    
           IF  RETURN-VALUE <> "OK" THEN
               NEXT.
    
           DISPLAY tel_nrdctato    tel_nmdavali    tel_nrcepend
                   tel_dsendere    tel_nrendere    tel_complend
                   tel_nmbairro    tel_nmcidade    tel_cdufende
                   tel_nrcxapst    tel_nrtelefo    tel_dsdemail
                   WITH FRAME f_contatos_fisica.

           RUN Confirma.

           IF  aux_confirma <> "S" THEN
               NEXT.
           ELSE
               DO:
                  RUN Grava_Dados.

                  IF  RETURN-VALUE <> "OK" THEN
                      NEXT.
               END.
        END. /* fim da opcao "E" */
   ELSE
   IF   glb_cddopcao = "A"   AND
        aux_nrdrowid <> ?    THEN
        DO:

           RUN Busca_Dados.
    
           IF  RETURN-VALUE <> "OK" THEN
               NEXT.
    
           RUN Atualiza_Tela.
    
           IF  RETURN-VALUE <> "OK" THEN
               NEXT.
    
           DISPLAY tel_nrdctato    tel_nmdavali    tel_nrcepend
                   tel_dsendere    tel_nrendere    tel_complend
                   tel_nmbairro    tel_nmcidade    tel_cdufende
                   tel_nrcxapst    tel_nrtelefo    tel_dsdemail
                   WITH FRAME f_contatos_fisica.
    
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
              UPDATE tel_nmdavali    tel_nrcepend
                     tel_nrendere    tel_complend    
                     tel_nrcxapst
                     tel_nrtelefo    tel_dsdemail
                     WITH FRAME f_contatos_fisica
              EDITING:

                  READKEY.
                  HIDE MESSAGE NO-PAUSE.

                  IF  LASTKEY = KEYCODE("F7")  THEN
                      DO:
                          /* Inclusão de CEP integrado. (André - DB1) */
                          IF  FRAME-FIELD = "tel_nrcepend"  THEN
                              DO:
                                  
                                  RUN fontes/zoom_endereco.p 
                                                    (INPUT 0,
                                                     OUTPUT TABLE tt-endereco).
                       
                                  FIND FIRST tt-endereco 
                                             NO-LOCK NO-ERROR.
        
                                  IF  AVAIL tt-endereco THEN
                                      ASSIGN tel_nrcepend = tt-endereco.nrcepend
                                             tel_dsendere = tt-endereco.dsendere
                                             tel_nmbairro = tt-endereco.nmbairro
                                             tel_nmcidade = tt-endereco.nmcidade
                                             tel_cdufende = tt-endereco.cdufende.
                                                            
                                  DISPLAY tel_nrcepend    
                                          tel_dsendere
                                          tel_nmbairro
                                          tel_nmcidade
                                          tel_cdufende
                                          WITH FRAME f_contatos_fisica.
                                  IF  KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
                                      NEXT-PROMPT tel_nrendere 
                                                  WITH FRAME f_contatos_fisica.
                              END.
                      END.
                  ELSE
                      APPLY LASTKEY.
              END.
                   
              DISPLAY tel_nmdavali    tel_dsendere    tel_complend
                      tel_nmbairro    tel_nmcidade    
                      WITH FRAME f_contatos_fisica.
              
              RUN Valida_Dados.

              IF  RETURN-VALUE <> "OK" THEN
                  NEXT.

              LEAVE.
           END.
           
           IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
                NEXT.
                
           RUN Confirma.
    
           IF  aux_confirma <> "S" THEN
               NEXT.
           ELSE
               DO:
                  RUN Grava_Dados.
    
                  IF  RETURN-VALUE <> "OK" THEN
                      NEXT.
               END.
        END. /* fim da opcao "A" */
END.

IF  VALID-HANDLE(h-b1wgen0073) THEN
    DELETE OBJECT h-b1wgen0073.

HIDE MESSAGE NO-PAUSE.

/*.................................PROCEDURES................................*/

PROCEDURE Busca_Dados:

    RUN Busca_Dados IN h-b1wgen0073
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_nrdctato,
          INPUT aux_nrdrowid,
         OUTPUT TABLE tt-crapavt,
         OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    EMPTY TEMP-TABLE cratavt.

    FOR EACH tt-crapavt:
        CREATE cratavt.
        ASSIGN 
            cratavt.nrdctato = tt-crapavt.nrdctato
            cratavt.nmdavali = tt-crapavt.nmdavali
            cratavt.nrtelefo = tt-crapavt.nrtelefo
            cratavt.dsdemail = tt-crapavt.dsdemail
            cratavt.dsdemiss = tt-crapavt.dsdemiss
            cratavt.nrdrowid = tt-crapavt.nrdrowid.
    END.

    RETURN "OK".
END.

PROCEDURE Valida_Dados:

    RUN Valida_Dados IN h-b1wgen0073
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT aux_nrdrowid,
          INPUT tel_nrdctato,
          INPUT tel_nmdavali,
          INPUT tel_cdufende,
          INPUT tel_nrcepend,
          INPUT tel_dsendere,
          INPUT tel_nmcidade,
          INPUT tel_nrtelefo,
          INPUT tel_dsdemail,
         OUTPUT TABLE tt-erro) .

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

    IF  VALID-HANDLE(h-b1wgen0073) THEN
        DELETE OBJECT h-b1wgen0073.

    RUN sistema/generico/procedures/b1wgen0073.p PERSISTENT SET h-b1wgen0073.

    RUN Grava_Dados IN h-b1wgen0073
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT aux_nrdrowid,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_nrdctato,
          INPUT tel_nmdavali,
          INPUT tel_nrcepend,
          INPUT tel_dsendere,
          INPUT tel_nrendere,
          INPUT tel_complend,
          INPUT tel_nmbairro,
          INPUT tel_nmcidade,
          INPUT tel_cdufende,
          INPUT tel_nrcxapst,
          INPUT tel_nrtelefo,
          INPUT tel_dsdemail,
         OUTPUT aux_tpatlcad,
         OUTPUT aux_msgatcad,
         OUTPUT aux_chavealt,
         OUTPUT TABLE tt-erro) .

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
    RUN proc_altcad (INPUT "b1wgen0073.p").

    DELETE OBJECT h-b1wgen0073.

    IF  RETURN-VALUE <> "OK" THEN
        NEXT.

    RETURN "OK".
END.

PROCEDURE Atualiza_Tela:

    FIND FIRST tt-crapavt WHERE tt-crapavt.nrdrowid = aux_nrdrowid NO-ERROR.

    IF  AVAILABLE tt-crapavt THEN DO:
        ASSIGN 
            tel_nrdctato = tt-crapavt.nrdctato
            tel_nmdavali = tt-crapavt.nmdavali   
            tel_nrcepend = tt-crapavt.nrcepend   
            tel_dsendere = tt-crapavt.dsendere
            tel_nrendere = tt-crapavt.nrendere   
            tel_complend = tt-crapavt.complend   
            tel_nmbairro = tt-crapavt.nmbairro
            tel_nmcidade = tt-crapavt.nmcidade   
            tel_cdufende = tt-crapavt.cdufende   
            tel_nrcxapst = tt-crapavt.nrcxapst
            tel_nrtelefo = tt-crapavt.nrtelefo   
            tel_dsdemail = tt-crapavt.dsdemail.
    END.
    ELSE DO:
        ASSIGN 
            tel_nmdavali = ""
            tel_nrcepend = 0
            tel_dsendere = ""
            tel_nrendere = 0
            tel_complend = ""
            tel_nmbairro = ""
            tel_nmcidade = ""
            tel_cdufende = ""
            tel_nrcxapst = 0
            tel_nrtelefo = ""
            tel_dsdemail = "".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE confirma.

   /* Confirma */
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         ASSIGN aux_confirma = "N"
         glb_cdcritic = 78.
         RUN fontes/critic.p.
         glb_cdcritic = 0.
         MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
         LEAVE.
      END.  /*  Fim do DO WHILE TRUE  */
      
     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
          DO:
             glb_cdcritic = 79.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             MESSAGE glb_dscritic.
             PAUSE 2 NO-MESSAGE.
          END. /* Mensagem de confirmacao */
                                
END PROCEDURE.

PROCEDURE Limpa_Endereco:
    ASSIGN tel_nrcepend = 0  
           tel_dsendere = ""  
           tel_nmbairro = "" 
           tel_nmcidade = ""  
           tel_cdufende = ""
           tel_nrendere = 0
           tel_complend = ""
           tel_nrcxapst = 0.

    DISPLAY tel_nrcepend  tel_dsendere
            tel_nmbairro  tel_nmcidade
            tel_cdufende  tel_nrendere
            tel_complend  tel_nrcxapst WITH FRAME f_contatos_fisica.
END PROCEDURE.
