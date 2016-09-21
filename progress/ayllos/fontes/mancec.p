/* .............................................................................

   Programa: Fontes/mancec.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odirlei-AMcom
   Data    : Outubro/2014.                     Ultima atualizacao: 29/10/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Permitir atualizar/inserir e excluir emitentes de cheques(crapcec).
                                       
   Alteracoes: 
............................................................................. */

{ includes/var_online.i }

{ includes/var_lanbdc.i "NEW" }

DEF BUFFER crabcec FOR crapcec.

FORM SKIP(1)
     glb_cddopcao AT 2 LABEL "                Opcao" AUTO-RETURN
                  HELP "Informe a opcao desejada (A, C, E ou I)"
                        VALIDATE(CAN-DO("A,C,E,I",glb_cddopcao),
                                 "014 - Opcao errada.")     
     tel_cdcmpchq AT 2 LABEL "         Comp. Cheque" AUTO-RETURN
                        HELP "Entre com o numero de compensacao do cheque."
                        VALIDATE(tel_cdcmpchq > -1,
                                 "380 - Numero errado.")

     tel_cdbanchq AT 2 LABEL "         Banco Cheque" AUTO-RETURN
                        HELP "Entre com o numero do banco impresso no cheque."
                        VALIDATE(CAN-FIND(crapban WHERE
                                          crapban.cdbccxlt = tel_cdbanchq),
                                          "057 - Banco nao cadastrado.")
                                 
     tel_cdagechq AT 2 LABEL "          Age. cheque" AUTO-RETURN
                        HELP "Entre com o codigo da agencia impresso no cheque."
                        VALIDATE(tel_cdagechq > 0,
                                 "089 - Agencia devera ser informada.")        
                         
     tel_nrctachq AT 2 LABEL "         Conta cheque" AUTO-RETURN
                        HELP "Entre com o numero da conta impresso no cheque."
                        VALIDATE(tel_nrctachq > 0,
                                 "127 - Conta errada.")        
     SKIP(1)                            
     WITH ROW 6 WIDTH 69 SIDE-LABEL NO-LABELS CENTERED OVERLAY 
     TITLE " Consulta do Emitente " FRAME f_cons_cec.


VIEW FRAME f_moldura.
PAUSE(0).
ASSIGN glb_cddopcao = "A".
         
DO WHILE TRUE:
  
  RUN fontes/inicia.p.  
  
  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
    /* caso no while iniciou com critica
       mostrar a critica na tela*/
    IF   glb_cdcritic > 0  OR 
         glb_dscritic <> " " THEN
      DO:
          IF   glb_cdcritic > 0  THEN
              RUN fontes/critic.p.
          BELL.
          MESSAGE glb_dscritic.

          ASSIGN glb_cdcritic = 0.
                 glb_dscritic = " ".
      END.
    
    UPDATE glb_cddopcao WITH FRAME f_cons_cec.  
    ASSIGN tel_nmemichq = ""
           tel_nrcpfchq = 0.
    
    DISPLAY tel_nmemichq tel_nrcpfchq WITH FRAME f_emitente.

  
    /* validar opcao */
    IF   CAN-DO("A,C,E,I",glb_cddopcao)   THEN
      DO:
        /* solicitar preenchimento das informacoes*/
        UPDATE tel_cdcmpchq tel_cdbanchq tel_cdagechq tel_nrctachq
          WITH FRAME f_cons_cec.
      END.    
      
      /*buscar emissor já cadastrado*/
      FIND FIRST crapcec 
        WHERE crapcec.cdcooper = glb_cdcooper
          AND crapcec.cdcmpchq = tel_cdcmpchq
          AND crapcec.cdbanchq = tel_cdbanchq
          AND crapcec.cdagechq = tel_cdagechq
          AND crapcec.nrctachq = tel_nrctachq
          NO-LOCK NO-ERROR.
      
      DISPLAY tel_nmemichq WITH FRAME f_emitente.
      
      /* se nao localizou emissor e a opcao é diferente 
         de inserir deve gerar critica */
      IF  NOT AVAILABLE crapcec AND
          glb_cddopcao <> "I" THEN
        DO:
          glb_dscritic = 'Emitente de cheque nao encontrado!'.
          BELL.
          MESSAGE glb_dscritic.
          glb_cdcritic = 0.
          NEXT.
        END.
        
      /* se localizou emissor e a opcao é  
         de inserir deve gerar critica */  
      IF AVAILABLE crapcec THEN
        IF glb_cddopcao = "I" THEN
          DO:
            /*exibir informacoes localizadas e gerar critica*/
            ASSIGN tel_nmemichq = crapcec.nmcheque
                   tel_nrcpfchq = crapcec.nrcpfcgc.
            DISPLAY tel_nmemichq tel_nrcpfchq WITH FRAME f_emitente.
            
            glb_dscritic = 'Emitente já cadastrado.'.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
          END.  
        ELSE
          DO:            
            ASSIGN tel_nmemichq = crapcec.nmcheque
                   tel_nrcpfchq = crapcec.nrcpfcgc.
          END.
         
      /* se é opcao inserir chamar rotina
         para inserir, mesma utilizada pela 
         tela lanbdc.p*/
      IF glb_cddopcao = "I" THEN
        RUN pede_dados.
        
      IF glb_cddopcao = "A" THEN  
        DO:
          
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
            /* caso no while iniciou com critica
               mostrar a critica na tela*/
            IF   glb_cdcritic > 0  OR 
                 glb_dscritic <> " " THEN
            DO:
                IF   glb_cdcritic > 0  THEN
                    RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
        
                ASSIGN glb_cdcritic = 0.
                       glb_dscritic = " ".
            END.
             
            /* se for atualizaçao habilitar campo para preenchimento*/
            UPDATE tel_nmemichq tel_nrcpfchq WITH FRAME f_emitente.
            /*validar preenchimento das informaçoes*/
            IF   TRIM(tel_nmemichq) = ""   THEN
              DO:
                  glb_cdcritic = 375.
                  NEXT-PROMPT tel_nmemichq WITH FRAME f_emitente.
                  NEXT.
              END.

            IF   tel_nrcpfchq = 0   THEN
              DO:
                  glb_cdcritic = 375.
                  NEXT-PROMPT tel_nrcpfchq WITH FRAME f_emitente.
                  NEXT.
              END.


            RUN valida_nome (INPUT  tel_nmemichq,
                             INPUT  tel_nrcpfchq,
                             OUTPUT glb_dscritic ).

            IF  RETURN-VALUE = "NOK" THEN
            DO:
                NEXT-PROMPT tel_nmemichq WITH FRAME f_emitente.
                NEXT.
            END.

            /* validar CPF/CNPJ*/
            glb_nrcalcul = tel_nrcpfchq.

            IF   LENGTH(STRING(tel_nrcpfchq)) > 11   THEN
              RUN fontes/cgcfun.p.
            ELSE
              DO:
                  RUN fontes/cpffun.p.

                  IF   NOT glb_stsnrcal   THEN
                       RUN fontes/cgcfun.p.
              END.

            IF   NOT glb_stsnrcal THEN
              DO:
                  glb_cdcritic = 27.
                  NEXT.
              END.
            
            /* Solicitar confirmaçao para atualizaçao*/
            aux_confirma = "N".
            BELL.
            MESSAGE COLOR NORMAL "Confirma alteraçao do Cedente de cheque?" 
            UPDATE aux_confirma.
            
            IF KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
              aux_confirma <> "S" THEN
              LEAVE.
            
            /* lockar registro para alteraçao*/
             FIND crabcec 
            WHERE ROWID(crabcec) = ROWID(crapcec)
             EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                           
             /* testar se está em lock*/
             IF  LOCKED crabcec   THEN
               DO:
                 glb_dscritic = 'Registro está sendo alterado, tente novamente.'.
                 BELL.
                 MESSAGE glb_dscritic.
                 glb_cdcritic = 0.
                 NEXT.
               END.
             
             /*atualizar cedente */
             ASSIGN crabcec.nmcheque = tel_nmemichq 
                    crabcec.nrcpfcgc = tel_nrcpfchq. 
             RELEASE crabcec.
             
             LEAVE.
           END.
           /* se foi pressionado f4 para sair, ou respondeu nao*/
           IF KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
              aux_confirma <> "S" THEN
             NEXT.
        END.
      
      /*se for consulta apenas exibir*/
      IF glb_cddopcao = "C" THEN  
        DISPLAY tel_nmemichq tel_nrcpfchq WITH FRAME f_emitente.
        
      IF glb_cddopcao = "E" THEN  
        DO:
          DISPLAY tel_nmemichq tel_nrcpfchq WITH FRAME f_emitente.  
          
          BELL.
          HIDE MESSAGE NO-PAUSE.
          MESSAGE COLOR NORMAL "Consultando cheques custodiados...".
          /* se for exclusao verificar se o cedente esta sendo usado*/
          FIND FIRST crapcst 
               WHERE crapcst.cdcooper = glb_cdcooper
                 AND crapcst.cdcmpchq = tel_cdcmpchq
                 AND crapcst.cdbanchq = tel_cdbanchq
                 AND crapcst.cdagechq = tel_cdagechq
                 AND crapcst.nrctachq = tel_nrctachq 
                  NO-LOCK NO-ERROR.
                    
          IF AVAILABLE crapcst THEN
          DO:
            glb_dscritic = "Emitente possui cheques em custodia!". 
            HIDE MESSAGE NO-PAUSE.
            NEXT.
          END.

          BELL.
          HIDE MESSAGE NO-PAUSE.
          MESSAGE "Consultando cheques descontados...".
          FIND FIRST crapcdb 
               WHERE crapcdb.cdcooper = glb_cdcooper
                 AND crapcdb.cdcmpchq = tel_cdcmpchq
                 AND crapcdb.cdbanchq = tel_cdbanchq
                 AND crapcdb.cdagechq = tel_cdagechq
                 AND crapcdb.nrctachq = tel_nrctachq 
                  NO-LOCK NO-ERROR.
          
          IF AVAILABLE crapcdb THEN
          DO:
            glb_dscritic = "Emitente possui cheques em desconto!". 
            HIDE MESSAGE NO-PAUSE.
            NEXT.
          END.
          
          /* solicitar confirmaçao da exclusao */
          aux_confirma = "N".
          BELL.
          MESSAGE "Confirma exclusao do Cedente de cheque?" 
          UPDATE aux_confirma.
          
          IF KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
            aux_confirma <> "S" THEN
            NEXT.
          /* lockar registro para exclusao*/  
           FIND crabcec 
          WHERE ROWID(crabcec) = ROWID(crapcec)
           EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                         
           /* testar se está em lock*/
           IF  LOCKED crabcec   THEN
             DO:
               glb_dscritic = 'Registro está sendo alterado, tente novamente.'.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               NEXT.
             END.
           
           /* excluir registro */
           DELETE crabcec. 
           ASSIGN tel_nmemichq = ""
                  tel_nrcpfchq = 0.
           DISPLAY tel_nmemichq tel_nrcpfchq WITH FRAME f_emitente.
           
           LEAVE.          
        END.
        
    LEAVE.
  END.  
  
  IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN 
      DO:
          RUN fontes/novatela.p.
          
          IF  CAPS(glb_nmdatela) <> "MANCEC"  THEN
              DO:
                  HIDE FRAME f_emitente NO-PAUSE.
                  HIDE FRAME f_cons_cec NO-PAUSE.
                  RETURN.
              END.
          ELSE
              NEXT.
      END.
  
END. 

/* .......................................................................... */

{ includes/proc_lanbdc.i }

/* .......................................................................... */
