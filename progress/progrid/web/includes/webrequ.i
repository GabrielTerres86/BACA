/*------------------------------------------------------------------------------
   Tipo: Procedure interna
   Nome: includes/webreq.i - Vers�o WebSpeed 2.1
  Autor: B&T/Solusoft
 Fun��o: Processo de requisi��o web p/ cadastros simples na web - Vers�o WebSpeed 3.0
  Notas: Este � o procedimento principal onde ter� as requisi��es GET e POST.
         GET - � ativa quando o formul�rio � chamado pela 1a vez
         POST - Ap�s o get somente ocorrer� POST no formul�rio      
         Caso seja necess�rio custimiz�-lo para algum programa espec�fico 
         Favor c�piar este procedimento para dentro do procedure process-web-requeste 
         fa�a l� altera��es necess�rias.
-------------------------------------------------------------------------------*/

ASSIGN opcao          = GET-FIELD("op")
       ponteiro       = GET-VALUE("ponteiro")
       statuspos      = GET-VALUE("statuspos")
       pesquisa       = GET-VALUE("pesq")
       FlagPermissoes = GET-VALUE("permi")
       cabecalho      = AppURL 
       permi          = FlagPermissoes
       msg-erro-aux   = 0.
      
RUN output-header. 

IF REQUEST_METHOD = "POST" THEN
DO WITH FRAME {&FRAME-NAME}:
  RUN dispatch IN THIS-PROCEDURE ('input-fields':U).

  CASE opcao:    
    WHEN "sa" THEN /* salvar */ DO:
      IF statuspos <> "i" THEN DO: /* altera��o */  
        ASSIGN msg-erro = ValidaDados("alteracao").
        FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
        IF NOT AVAILABLE {&FIRST-ENABLED-TABLE} THEN
          IF LOCKED {&FIRST-ENABLED-TABLE} THEN DO:
            ASSIGN msg-erro-aux = 1. /* registro em uso por outro usu�rio */  
            FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
          END.
          ELSE DO: 
            ASSIGN msg-erro-aux = 2. /* registro n�o existe */
            RUN PosicionaNoSeguinte.
          END.
        ELSE DO:
          IF msg-erro = "" THEN DO:
            RUN local-assign-record ("alteracao").    
            ASSIGN msg-erro-aux = 10. /* Solicita��o realizada com sucesso */ 
          END.
          ELSE
            ASSIGN msg-erro-aux = 3. /* erros da valida��o de dados */
        END.     
      END.
      ELSE DO: /* inclus�o */
        ASSIGN msg-erro = ValidaDados("inclusao").
        IF msg-erro = "" THEN DO:
          RUN local-assign-record ("inclusao").    
          ASSIGN ponteiro = STRING(ROWID({&FIRST-ENABLED-TABLE}))
                 statuspos = "?".
          ASSIGN msg-erro-aux = 10. /* Solicita��o realizada com sucesso */
        END.
        ELSE
          ASSIGN msg-erro-aux = 3. /* erros da valida��o de dados */
      END.  
    END. /* salvar */
    
    WHEN "in" THEN /* inclusao */ DO:
      IF statuspos <> "i" THEN DO:
        CLEAR FRAME {&FRAME-NAME}.
        ASSIGN statuspos = "i".
      END.
    END. /* inclusao */
    
    WHEN "ex" THEN /* exclusao */ DO:
      FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
      FIND NEXT {&FIRST-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.
      IF AVAILABLE {&FIRST-ENABLED-TABLE} THEN
        ASSIGN ponteiro-auxiliar = STRING(ROWID({&FIRST-ENABLED-TABLE})).
      ELSE DO:
        FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
        FIND PREV {&FIRST-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.
        IF AVAILABLE {&FIRST-ENABLED-TABLE} THEN
          ASSIGN ponteiro-auxiliar = STRING(ROWID({&FIRST-ENABLED-TABLE})).
        ELSE
          ASSIGN ponteiro-auxiliar = "?".
      END.          
      /*** PROCURA TABELA PARA VALIDAR -> COM NO-LOCK ***/
      FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
      ASSIGN msg-erro = ValidaDados("exclusao").
      /*** PROCURA TABELA PARA EXCLUIR -> COM EXCLUSIVE-LOCK ***/
      FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
      IF NOT AVAILABLE {&FIRST-ENABLED-TABLE} THEN
        IF LOCKED {&FIRST-ENABLED-TABLE} THEN DO:
          ASSIGN msg-erro-aux = 1. /* registro em uso por outro usu�rio */ 
          FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
        END.
        ELSE
          ASSIGN msg-erro-aux = 2. /* registro n�o existe */
      ELSE DO:
        IF msg-erro = "" THEN DO:
          RUN local-delete-record.
          DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN m-erros = m-erros + ERROR-STATUS:GET-MESSAGE(i).
          END.    
          IF m-erros = " " THEN DO:
            IF ponteiro-auxiliar = "?" THEN
              RUN PosicionaNoPrimeiro.
            ELSE DO:
              ASSIGN ponteiro = ponteiro-auxiliar.
              FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
              IF NOT AVAILABLE {&FIRST-ENABLED-TABLE} THEN
                RUN PosicionaNoSeguinte.
            END.   
            ASSIGN msg-erro-aux = 10. /* Solicita��o realizada com sucesso */ 
          END.
          ELSE ASSIGN msg-erro-aux = 4. /* Exclusao rejeitada */ 
        END.
        ELSE do:
          ASSIGN msg-erro-aux = 3. /* erros da valida��o de dados */
        end.  
      END.                            
    END. /* exclusao */
    
    WHEN "pe" THEN /* pesquisar */ DO:   
      FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
      IF NOT AVAILABLE {&FIRST-ENABLED-TABLE} THEN 
        RUN PosicionaNoSeguinte.
    END. /* pesquisar */
    
    WHEN "li" THEN /* listar */ DO:                             
      FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
      IF NOT AVAILABLE {&FIRST-ENABLED-TABLE} THEN 
        RUN PosicionaNoSeguinte.
    END. /* listar */
    
    WHEN "pr" THEN /* primeiro */
      RUN PosicionaNoPrimeiro.
      
    WHEN "ul" THEN /* ultimo */
      RUN PosicionaNoUltimo.
      
    WHEN "an" THEN /* anterior */
      RUN PosicionaNoAnterior.
      
    WHEN "se" THEN do: /* seguinte */
      RUN PosicionaNoSeguinte.
    END.
  END CASE.
  
  if msg-erro-aux = 10 or (opcao <> "sa" and opcao <> "ex" and opcao <> "in") then do.
    RUN dispatch IN THIS-PROCEDURE ('display-fields':U).    
  end.   
  
  RUN dispatch IN THIS-PROCEDURE ('enable-fields':U).
  RUN dispatch IN THIS-PROCEDURE ('output-fields':U).

  CASE msg-erro-aux:
      WHEN 1 THEN do.
        assign
        v-qtdeerro = 1
        v-descricaoerro = 'Registro esta em uso por outro usu�rio.Solicita��o n�o pode ser executada. Espere alguns instantes e tente novamente.'.
        run RodaJavaScript(' top.frames[0].MostraResultado(' + string(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
      END.

      WHEN 2 THEN
        RUN RodaJavaScript(" top.frames[0].MostraMsg('Registro foi exclu�do. Solicita��o n�o pode ser executada.')").
        
      WHEN 3 THEN DO.
        v-qtdeerro = 1.
        v-descricaoerro = msg-erro.
        run RodaJavaScript('top.frames[0].MostraResultado(' + string(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
      END.

      WHEN 4 THEN DO:
        v-qtdeerro = 1.
        v-descricaoerro = m-erros.
        run RodaJavaScript('top.frames[0].MostraResultado(' + string(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
      END.

      WHEN 10 THEN DO:
        run RodaJavaScript('alert("Atualizacao executada com sucesso.")'). 
      END.
  END CASE.     
  RUN RodaJavaScript('top.frames[0].ZeraOp()').   
END.
ELSE /* metodo GET */
DO WITH FRAME {&FRAME-NAME}:
  RUN PermissaoDeAcesso(INPUT ProgramaEmUso, OUTPUT IdentificacaoDaSessao, OUTPUT permi).
  CASE permi:
    WHEN "1" THEN /* get-cookie em usuario-em-uso voltou valor nulo */
      RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').

    WHEN "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ DO: 
      DELETE-COOKIE("cookie-usuario-em-uso",?,?).
      RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').
    END.
    
    WHEN "3" THEN /* usuario nao tem permissao para acessa o programa */
      RUN RodaJavaScript('window.location.href = "' + cabecalho + 'negado"').

    OTHERWISE DO:
      IF GET-VALUE("LinkRowid") <> "" THEN DO:
        FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(GET-VALUE("LinkRowid")) NO-LOCK NO-WAIT NO-ERROR.
        IF AVAILABLE {&FIRST-ENABLED-TABLE} THEN DO:
          ASSIGN ponteiro = STRING(ROWID({&FIRST-ENABLED-TABLE})).
          FIND NEXT {&FIRST-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.
          IF NOT AVAILABLE {&FIRST-ENABLED-TABLE} THEN
            ASSIGN statuspos = "u".
          ELSE DO:
            FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
            FIND PREV {&FIRST-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.
            IF NOT AVAILABLE {&FIRST-ENABLED-TABLE} THEN
              ASSIGN statuspos = "p".        
            ELSE
              ASSIGN statuspos = "?".
          END.
          
          FIND {&FIRST-ENABLED-TABLE} WHERE ROWID({&FIRST-ENABLED-TABLE}) = TO-ROWID(ponteiro) NO-LOCK NO-WAIT NO-ERROR.
        END.  
        ELSE
          ASSIGN ponteiro = "?" statuspos = "?".
      END. 
      ELSE                    
        RUN PosicionaNoPrimeiro.
      
      RUN dispatch IN THIS-PROCEDURE ('display-fields':U).    
      RUN dispatch IN THIS-PROCEDURE ('enable-fields':U).
      RUN dispatch IN THIS-PROCEDURE ('output-fields':U).
      RUN RodaJavaScript('top.frcod.FechaZoom()').
      RUN RodaJavaScript('CarregaPrincipal()').
    END. /* otherwise */                  
  END CASE. 
END. /* get */
