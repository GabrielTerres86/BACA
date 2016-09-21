/* ............................................................................

   Programa: Fontes/proepr_ipr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/96.                         Ultima atualizacao: 28/11/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tratamento dos RENDIMENTOS do cooperado e conjuge quando pessoa 
               fisica. Do faturamento quando juridica.

   Alteracoes: 17/06/2009 - Substituida variavel tel_dsdebens por tel_dsrelbem 
                            e variavel tel_vloutras por tel_vldrendi (Elton). 

               07/07/2009 - Cadastrar bens/rendimentos (Gabriel). 
               
               23/11/2009 - Correcao de criacao de crapjfn sem cooperativa 
                            e conta (Gabriel).
                            
               29/06/2010 - Melhorias de propostas de credito.
                            Adaptado para usar BO. (Gabriel).     
                            
               24/11/2011 - Ajuste para a inclusao do campo "Justificativa"
                            (Adriano).
                            
               08/01/2014 - Adicionado espaços para separar a justificativa de 
                            rendimento. (Jorge)
                            
               08/09/2014 - Projeto Automatização de Consultas em Propostas
                            de Crédito (Jonata-RKAM).             
                            
               26/11/2014 - Verificar se o Conjuge tem CPF cadastrado antes
                            de habilitar a consulta automatizada deste.
                            (Jonata-RKAM).             
                                            
               28/11/2014 - Exibir que a consulta do conjuge nao sera efetuada
                            caso o mesmo nao tenha CPF nem Conta (Jonata-RKAM).                                                         
                                                                        
............................................................................. */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0056tt.i }   
{ sistema/generico/includes/b1wgen0069tt.i }     
{ sistema/generico/includes/b1wgen9999tt.i }

{ includes/var_online.i   }
{ includes/var_proposta.i }
  

DEF INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF INPUT PARAM TABLE FOR tt-itens-topico-rating.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-tipo-rendi.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-rendimento.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-faturam.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-crapbem.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-dados-analise.


/* Descricao dos rendimentos, para todos os campos da descricao */
ON LEAVE OF tt-rendimento.tpdrendi IN FRAME f_tel_fis DO:

    FIND tt-tipo-rendi WHERE 
         tt-tipo-rendi.tpdrendi =  INPUT tt-rendimento.tpdrendi[FRAME-INDEX]
         NO-LOCK NO-ERROR.

    IF   AVAIL tt-tipo-rendi   THEN
         ASSIGN tt-rendimento.dsdrendi[FRAME-INDEX] = tt-tipo-rendi.dsdrendi.
    ELSE
         ASSIGN tt-rendimento.dsdrendi[FRAME-INDEX] = "NAO CADASTRADO".
              
    DISPLAY tt-rendimento.dsdrendi[FRAME-INDEX] WITH FRAME f_tel_fis.                    


END.


/* Abrir frame de cadastro de faturmamento pra pessoa juridica */
ON RETURN OF tt-rendimento.vlmedfat IN FRAME f_tel_jur DO:
        
    RUN financeiro_faturamento.
              
    ASSIGN aux_contador = 0
           aux_vlmedfat = 0.

    /* Calcular a media */
    FOR EACH tt-faturam NO-LOCK:

        ASSIGN aux_contador = aux_contador + 1
               aux_vlmedfat = aux_vlmedfat + tt-faturam.vlrftbru.

    END.

    IF   aux_contador > 0  THEN
         ASSIGN tt-rendimento.vlmedfat = aux_vlmedfat / aux_contador.
    ELSE
         ASSIGN tt-rendimento.vlmedfat = 0.

    DISPLAY tt-rendimento.vlmedfat WITH FRAME f_tel_jur.    
  
END.



/* Rendimentos do cooperado */
FIND FIRST tt-rendimento EXCLUSIVE-LOCK NO-ERROR.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   IF   tt-rendimento.inpessoa = 1   THEN  /* Pessoa fisica */
        DO:
            ASSIGN aux_dsjusren[1] = SUBSTR(tt-rendimento.dsjusren,1,60)
                   aux_dsjusren[2] = TRIM(SUBSTR(tt-rendimento.dsjusren,62,60))
                   aux_dsjusren[3] = TRIM(SUBSTR(tt-rendimento.dsjusren,123,40))
                   aux_flgtpren = FALSE
                   aux_renoutro = 0.
                   
           
            DISPLAY tt-rendimento.dsdrendi[1]
                    tt-rendimento.dsdrendi[2]
                    tt-rendimento.dsdrendi[3]
                    tt-rendimento.dsdrendi[4]
                    tt-rendimento.dsdrendi[5]
                    tt-rendimento.dsdrendi[6]
                    tt-rendimento.flgdocje
                    aux_dsjusren[1]
                    aux_dsjusren[2]
                    aux_dsjusren[3]
                    WITH FRAME f_tel_fis. 

            
            UPDATE tt-rendimento.vlsalari     tt-rendimento.vloutras
                   tt-rendimento.tpdrendi[1]  tt-rendimento.vldrendi[1]
                   tt-rendimento.tpdrendi[2]  tt-rendimento.vldrendi[2]
                   tt-rendimento.tpdrendi[3]  tt-rendimento.vldrendi[3]
                   tt-rendimento.tpdrendi[4]  tt-rendimento.vldrendi[4]
                   tt-rendimento.tpdrendi[5]  tt-rendimento.vldrendi[5]
                   tt-rendimento.tpdrendi[6]  tt-rendimento.vldrendi[6]
                   WITH FRAME f_tel_fis
                   
          
            EDITING:
          
             READKEY.
                
             IF   LASTKEY = KEYCODE("F7")    AND 
                  FRAME-FIELD = "tpdrendi"   THEN
                  DO:
                      /* Pegar o indice do array do tipo de rendimento */  
                      ASSIGN aux_indirend = FRAME-INDEX.  

                      RUN zoom_tipo_rendimento 
                          (INPUT-OUTPUT tt-rendimento.tpdrendi[aux_indirend],
                           INPUT-OUTPUT tt-rendimento.dsdrendi[aux_indirend]).

                      DISPLAY tt-rendimento.tpdrendi[aux_indirend] 
                              tt-rendimento.dsdrendi[aux_indirend]
                              WITH FRAME f_tel_fis.      
                  END.
             ELSE 
                  APPLY LASTKEY.
                  
            END. /* Fim do editing */


            IF tt-rendimento.tpdrendi[1] = 6 OR
               tt-rendimento.tpdrendi[2] = 6 OR
               tt-rendimento.tpdrendi[3] = 6 OR
               tt-rendimento.tpdrendi[4] = 6 OR
               tt-rendimento.tpdrendi[5] = 6 OR
               tt-rendimento.tpdrendi[6] = 6 THEN
               aux_flgtpren = TRUE.


            IF   tt-rendimento.flgconju       AND
                 tt-rendimento.nrcpfcjg = 0   AND
                 tt-rendimento.nrctacje = 0   THEN
                 DO:
                     ASSIGN tt-rendimento.inconcje = NO.

                     DISPLAY tt-rendimento.inconcje WITH FRAME f_tel_fis.
                 END.

            UPDATE aux_dsjusren[1]                WHEN aux_flgtpren = TRUE
                   aux_dsjusren[2]                WHEN aux_flgtpren = TRUE
                   aux_dsjusren[3] FORMAT "x(40)" WHEN aux_flgtpren = TRUE
                   tt-rendimento.vlsalcon         WHEN tt-rendimento.flgconju
                   tt-rendimento.nmextemp         WHEN tt-rendimento.flgconju                   
                   tt-rendimento.flgdocje         WHEN tt-rendimento.flgconju
                   tt-rendimento.vlalugue
                   tt-rendimento.inconcje         WHEN tt-rendimento.flgconju AND
                                                    ( tt-rendimento.nrcpfcjg <> 0 OR 
                                                      tt-rendimento.nrctacje <> 0 )
                   WITH FRAME f_tel_fis.

            ASSIGN tt-rendimento.dsjusren = aux_dsjusren[1] + " " +
                                            aux_dsjusren[2] + " " +
                                            aux_dsjusren[3].

            /* Se nao co-responsavel , limpar */
            IF NOT tt-rendimento.flgdocje   THEN
               DO:
                   ASSIGN tt-rendimento.nrctacje = 0
                          tt-rendimento.nrcpfcjg = 0.                   
               END.

            DO aux_contador = 1 TO 6:

               IF tt-rendimento.tpdrendi[aux_contador] = 6 THEN
                  aux_renoutro = aux_renoutro + 1.

            END.

            IF aux_renoutro > 1 THEN
               DO: 
                   MESSAGE "Rendimento (Outros) ja informado.".
                   PAUSE(2) NO-MESSAGE.
                   HIDE MESSAGE NO-PAUSE.
                   NEXT.

               END.
            ELSE
              IF aux_renoutro = 1     AND
                 aux_dsjusren[1] = "" AND
                 aux_dsjusren[2] = "" AND
                 aux_dsjusren[3] = "" THEN
                 DO:
                    MESSAGE "Deve ser informado uma justificativa.".
                    PAUSE(2) NO-MESSAGE.
                    HIDE  MESSAGE NO-PAUSE.
                    NEXT.
                
                 END.


        END. /* Fim pessoa FISICA */
   ELSE
        DO:
            /* Nao editar este campo */
            ASSIGN tt-rendimento.vlmedfat:READ-ONLY = TRUE.
            
            UPDATE tt-rendimento.vlmedfat    
                   tt-rendimento.perfatcl
                   tt-rendimento.vlalugue
                   
                   WITH FRAME f_tel_jur.
        
        END. /* FIM pessoa juridica */
           
   PAUSE 0.

   /* Bens do cooperado */         
   RUN fontes/proposta_bens.p (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT 0, /* Sem CPF */
                               INPUT-OUTPUT TABLE tt-crapbem).
                                                          
   IF   RETURN-VALUE <> "OK"   THEN
        NEXT.
   
   RUN fontes/proposta_analise.p (INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT tt-rendimento.inpessoa,
                                  INPUT TABLE tt-itens-topico-rating,
                                  INPUT-OUTPUT TABLE tt-dados-analise).
                                                                                     
   IF   RETURN-VALUE <> "OK"   THEN
        NEXT.
        
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        NEXT.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_tel_fis.
HIDE FRAME f_tel_jur.


PROCEDURE zoom_tipo_rendimento:

    DEF INPUT-OUTPUT PARAM par_tpdrendi AS INTE                   NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_dstipren AS CHAR                   NO-UNDO.
    

    DEF QUERY q_rendim FOR tt-tipo-rendi.
   
    DEF BROWSE b_rendim QUERY q_rendim
    
    DISPLAY tt-tipo-rendi.tpdrendi COLUMN-LABEL "Codigo"      FORMAT "zz9"
            tt-tipo-rendi.dsdrendi COLUMN-LABEL "Descricao"   FORMAT "x(25)"
            WITH 5 DOWN NO-BOX.
                
    FORM b_rendim HELP "Pressione ENTER para selecionar ou F4 para sair"

         WITH ROW 9 CENTERED TITLE "TIPO DE RENDIMENTO" OVERLAY NO-LABELS 
       
            FRAME f_rendimento.

              
    ON RETURN OF b_rendim DO:

        ASSIGN par_tpdrendi = tt-tipo-rendi.tpdrendi
               par_dstipren = tt-tipo-rendi.dsdrendi.

        APPLY "GO".
    
    END.
    
    OPEN QUERY q_rendim FOR EACH tt-tipo-rendi NO-LOCK.
                                 
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE b_rendim WITH FRAME f_rendimento.
       LEAVE.
    END.
 
    HIDE FRAME f_rendimento.

END PROCEDURE.

              
PROCEDURE financeiro_faturamento:

           
   DEF VAR tel_mesftbru AS INT  FORMAT "z9"                       NO-UNDO.
   DEF VAR tel_anoftbru AS INT  FORMAT "zzz9"                     NO-UNDO.
   DEF VAR tel_vlrftbru AS DECI FORMAT "-zzz,zzz,zz9.99"          NO-UNDO.
                                                                  
   DEF VAR aux_nrdlinha AS INT                                    NO-UNDO.
   DEF VAR reg_contador AS INT                   INIT 3           NO-UNDO.
                                                                  
   DEF VAR reg_dsdopcao AS CHAR EXTENT 3 INIT ["Alterar",         
                                               "Excluir",         
                                               "Incluir"]         NO-UNDO.
                                                                  
   DEF VAR aux_nrposext AS INTE                                   NO-UNDO.
   DEF VAR aux_flgregis AS LOGI                                   NO-UNDO. 
                                                                  
   DEF VAR aux_mesftbru AS INTE                                   NO-UNDO.
   DEF VAR aux_anoftbru AS INTE                                   NO-UNDO.
   DEF VAR aux_nrdrowid AS ROWID                                  NO-UNDO.
                                                                  
   DEF QUERY q_valores FOR tt-faturam.                            
    
   DEF BROWSE b_valores QUERY q_valores
       DISPLAY tt-faturam.mesftbru COLUMN-LABEL "Mes"         FORMAT "z9"
               SPACE(5)
               tt-faturam.anoftbru COLUMN-LABEL "Ano"         FORMAT "zzz9"
               SPACE(5)
               tt-faturam.vlrftbru COLUMN-LABEL "Faturamento" 
                                                FORMAT "-zzz,zzz,zz9.99"

               WITH 4 DOWN SCROLLBAR-VERTICAL NO-BOX.
    
   FORM SKIP(8)
        
        reg_dsdopcao[1]  AT 07  NO-LABEL FORMAT "x(7)"
        reg_dsdopcao[2]  AT 22  NO-LABEL FORMAT "x(7)"
        reg_dsdopcao[3]  AT 37  NO-LABEL FORMAT "x(7)"
       
        WITH ROW 8 WIDTH 51 CENTERED OVERLAY SIDE-LABELS TITLE 
             " FATURAMENTO " FRAME f_regua.

   FORM SKIP(1)
        b_valores 
            HELP "Pressione ENTER para selecionar / F4 ou END para sair."
        
        WITH ROW 9 COLUMN 30 CENTERED OVERLAY NO-BOX FRAME f_browse.

   FORM SKIP(2)
        "Mes:"                             AT 17
        tel_mesftbru  NO-LABEL             AT 35
          HELP "Informe o mes do faturamento."
          VALIDATE(tel_mesftbru > 0 AND tel_mesftbru < 13, "013 - Data errada.")
    
        SKIP
        "Ano:"                             AT 17
        tel_anoftbru  NO-LABEL             AT 33
          HELP "Informe o ano do faturamento."
          VALIDATE(tel_anoftbru >= 1000 AND tel_anoftbru <= YEAR(glb_dtmvtolt), 
                 "013 - Data errada.")
        SKIP
        tel_vlrftbru  LABEL "Faturamento"  AT 09
          HELP "Informe o faturamento."

        SKIP(2)
        WITH ROW 9 WIDTH 46 CENTERED SIDE-LABELS OVERLAY NO-BOX 
    
                                                      FRAME f_faturamentos.
  
                                                
   ON ANY-KEY OF b_valores IN FRAME f_browse DO:

      IF   KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
           DO:
               reg_contador = reg_contador + 1.

               IF   reg_contador > 3   THEN
                    reg_contador = 1.
           END.
      ELSE        
      IF   KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
           DO:
               reg_contador = reg_contador - 1.

               IF   reg_contador < 1   THEN
                    reg_contador = 3.
           END.
      ELSE
      IF   KEY-FUNCTION(LASTKEY) = "HELP"   THEN
           APPLY LASTKEY.
      ELSE
      IF   KEY-FUNCTION(LASTKEY) = "RETURN"   THEN
           DO:
               IF   AVAILABLE tt-faturam   THEN
                    DO:
                        ASSIGN aux_nrdlinha = CURRENT-RESULT-ROW("q_valores").
                         
                       b_valores:DESELECT-ROWS().
                    END.
               ELSE
                    aux_nrdlinha = 0.
                         
               APPLY "GO".
           END.
      ELSE
           RETURN.
            
      /* Somente para marcar a opcao escolhida */
      CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

   END.

                                                       
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      DISPLAY reg_dsdopcao[1]  
              reg_dsdopcao[2]
              reg_dsdopcao[3]
              WITH FRAME f_regua.
              
      CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
      
      OPEN QUERY q_valores FOR EACH tt-faturam EXCLUSIVE-LOCK 
                                    BY tt-faturam.anoftbru DESC
                                       BY tt-faturam.mesftbru DESC.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
         UPDATE b_valores WITH FRAME f_browse.
         LEAVE.
        
      END.

      HIDE FRAME f_browse.
      
      IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
           LEAVE.
               
      /* Deixa o browse visivel e marca a linha que tinha sido selecionada */
      VIEW FRAME f_browse.
  
      IF   aux_nrdlinha > 0   THEN
           REPOSITION q_valores TO ROW(aux_nrdlinha).
   
      PAUSE 0.
      
      IF   reg_contador = 1   THEN   /* Alteracao */
           DO:
               IF   NOT AVAILABLE tt-faturam  THEN
                    NEXT.
                    
               ASSIGN tel_mesftbru = tt-faturam.mesftbru
                      tel_anoftbru = tt-faturam.anoftbru
                      tel_vlrftbru = tt-faturam.vlrftbru

                      aux_nrposext = tt-faturam.nrposext
                      aux_flgregis = FALSE
                      aux_nrdrowid = ROWID(tt-faturam).
                      
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                  UPDATE tel_mesftbru
                         tel_anoftbru
                         tel_vlrftbru
                         WITH FRAME f_faturamentos.
               
                  IF  tel_anoftbru =  YEAR(glb_dtmvtolt)     AND
                      tel_mesftbru >  MONTH (glb_dtmvtolt)   THEN
                      DO:
                          MESSAGE "013 - Data errada.".
                          NEXT.
                      END.
                  
                  LEAVE.
                  
               END.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    NEXT.
                
               /* Nao alterar para uma data ja existente */
               FOR EACH tt-faturam NO-LOCK:
                
                   IF   tt-faturam.mesftbru  = tel_mesftbru   AND
                        tt-faturam.anoftbru  = tel_anoftbru   AND
                        tt-faturam.nrposext <> aux_nrposext   THEN
                        DO:
                            MESSAGE "Ja existe um faturamento com este" +
                                    " mes e ano.".
                            PAUSE 2 NO-MESSAGE.
                            aux_flgregis = TRUE.
                            LEAVE.
                        END.
               
               END. 
               
               IF   aux_flgregis   THEN
                    NEXT.
               
               RUN fontes/confirma.p (INPUT "",
                                      OUTPUT aux_confirma).

               IF   aux_confirma <> "S"   THEN
                    NEXT.

               FIND tt-faturam WHERE ROWID(tt-faturam) = aux_nrdrowid
                    EXCLUSIVE-LOCK NO-ERROR.

               IF   AVAIL tt-faturam THEN
                    ASSIGN tt-faturam.mesftbru = tel_mesftbru 
                           tt-faturam.anoftbru = tel_anoftbru
                           tt-faturam.vlrftbru = tel_vlrftbru.
                                  
           END. /* Fim Alteracao */
      ELSE
      IF   reg_contador = 2   THEN   /* Excluir valor */
           DO:
               IF   NOT AVAILABLE tt-faturam   THEN
                    NEXT.
                    
               RUN fontes/confirma.p (INPUT "",
                                      OUTPUT aux_confirma).
                    
               IF   aux_confirma <> "S"  THEN
                    NEXT.
                    
               DELETE tt-faturam.

           END.
      ELSE     /* Incluir novo valor */
           DO:
               ASSIGN tel_mesftbru = 0
                      tel_anoftbru = 0
                      tel_vlrftbru = 0

                      aux_flgregis = FALSE
                      aux_nrposext = 0.
           
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                  UPDATE tel_mesftbru
                         tel_anoftbru
                         tel_vlrftbru
                         WITH FRAME f_faturamentos.
                  
                  IF  tel_anoftbru =  YEAR(glb_dtmvtolt)     AND
                      tel_mesftbru >  MONTH (glb_dtmvtolt)   THEN
                      DO:
                          MESSAGE "013 - Data errada.".
                          NEXT.
                      END.
                  
                  LEAVE.         
                
               END.
                
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    NEXT.

               ASSIGN aux_contador = 0.

               FOR EACH tt-faturam NO-LOCK:
                
                   ASSIGN aux_contador = aux_contador + 1. 

                   /* Nao cadastrar um valor de uma data ja cadastrada */ 
                   IF   tt-faturam.mesftbru = tel_mesftbru   AND
                        tt-faturam.anoftbru = tel_anoftbru   THEN
                        DO:
                            MESSAGE "Ja existe um faturamento com este" +
                                    " mes e ano.".
                            PAUSE 2 NO-MESSAGE.
                            aux_flgregis = TRUE.
                            LEAVE.
                        END.
               
                   /* Menor data em caso de todos estiverem prenchidos */
                   IF   tt-faturam.anoftbru <= aux_anoftbru  THEN
                        ASSIGN aux_anoftbru = tt-faturam.anoftbru. 
               
               END.
               
               IF   aux_flgregis  THEN
                    NEXT.

               /* Cheio, queimar o mais antigo */ 
               IF   aux_contador = 12   THEN 
                    FOR EACH tt-faturam WHERE 
                             tt-faturam.anoftbru = aux_anoftbru NO-LOCK: 
                    
                        /* Menor mes do menor ano */
                        IF   tt-faturam.mesftbru <= aux_mesftbru  THEN
                             ASSIGN aux_mesftbru  = tt-faturam.mesftbru
                                    aux_nrposext  = tt-faturam.nrposext.
                    END. 
        
                    
               RUN fontes/confirma.p (INPUT "",
                                      OUTPUT aux_confirma).
               
               IF   aux_confirma <> "S"   THEN
                    NEXT.

               /* Se esta cheio , pegar o mais antigo e quimar */
               IF   aux_contador = 12   THEN
                    DO:
                        FIND tt-faturam WHERE
                             tt-faturam.nrposext = aux_nrposext
                             EXCLUSIVE-LOCK NO-ERROR.
                    END.
               ELSE
                    DO:
                        CREATE tt-faturam.
                    END.

               ASSIGN tt-faturam.mesftbru = tel_mesftbru
                      tt-faturam.anoftbru = tel_anoftbru
                      tt-faturam.vlrftbru = tel_vlrftbru.

           END. /* Fim inclusao */

   END. /* Fim do DO WHILE TRUE */

   HIDE FRAME f_regua. 

END.
                
 
/* .......................................................................... */

