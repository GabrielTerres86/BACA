/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +----------------------------------------+--------------------------------------------------+
  | Rotina Progress                        | Rotina Oracle PLSQL                              |
  +----------------------------------------+--------------------------------------------------+
  | bancosc.i                              | BANC0001.pc_consulta_banco                       |
  | bancosa.i                              | BANC0001.pc_altera_banco                         |
  | bancosi.i                              | BANC0001.pc_inclui_banco                         |
  +----------------------------------------+--------------------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/


/* .............................................................................

   Programa: Fontes/bancos.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Abril/2001                     Ultima Atualizacao: 11/09/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela BANCOS.

   ALTERACAO : 25/07/2005 - Modificado Help na glb_cddopcao (Diego).
   
               20/06/2007 - Adicionado critica para permitir somente os
                            operadores:1, 799, 997 para opcoes A E I(Guilherme).

               23/01/2009 - Retirar permissao do operador 799 e permitir
                            ao 979 (Gabriel).
                            
               11/05/2009 - Alteracao CDOPERAD (Kbase).             
               
               23/02/2010 - Incluir campo nrispbif (David).
               
               17/03/2010 - Incluir campo flgdispb no browse de consulta (David)
               
               24/03/2010 - Alterado para incluir LOG (Sandro-GATI)

               23/06/2010 - Incluir dsdepart COMPE para opcao A,E,I (Ze).
               
               23/06/2010 - Removida a Opção E da tela (Lucas).
               
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               08/04/2015 - Alteração no cadastro/consulta de bancos colocando 
                            o ISPB como chave SD271603 (Vanessa)
                            
               31/07/2015 - Conversão Progress/Oracle, alterado para chamar as
                            novas rotinas do orale: pc_consulta_banco; pc_altera_banco
                            pc_inclui_banco
                            (Jessica - DB1).
                            
               11/09/2015 - Ajuste para correcao da conversao efetuada pela DB1
                            (Adriano).
                                        
                            
............................................................................. */ 

{ includes/var_online.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i}

DEF VAR tel_cdbccxlt AS INTE FORMAT "zz9"                              NO-UNDO.
DEF VAR tel_nrispbif AS INTE FORMAT "99999999"                         NO-UNDO.

DEF VAR tel_nmresbcc AS CHAR FORMAT "x(15)"                            NO-UNDO.
DEF VAR tel_nmextbcc AS CHAR FORMAT "x(35)"                            NO-UNDO.

DEF VAR tel_flgdispb AS CHAR FORMAT "x(3)"                             NO-UNDO.

DEF VAR tel_dtinispb AS DATE FORMAT "99/99/9999"                       NO-UNDO.  

DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.

DEF VAR aux_contador AS INTE FORMAT "z9"                               NO-UNDO.
DEF VAR aux_contalin AS INTE                                           NO-UNDO.


DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.

DEF VAR aux_temassoc AS LOGI                                           NO-UNDO.
DEF VAR aux_pesquisa AS LOGI FORMAT "S/N"                              NO-UNDO.
DEF VAR aux_regexist AS LOGI                                           NO-UNDO.
DEF VAR aux_flgretor AS LOGI                                           NO-UNDO.


/* Variaveis para o XML */ 
DEF VAR xDoc          AS HANDLE                                        NO-UNDO.
DEF VAR xRoot         AS HANDLE                                        NO-UNDO.
DEF VAR xRoot2        AS HANDLE                                        NO-UNDO.
DEF VAR xField        AS HANDLE                                        NO-UNDO.
DEF VAR xText         AS HANDLE                                        NO-UNDO.
DEF VAR aux_cont_raiz AS INTEGER                                       NO-UNDO.
DEF VAR aux_cont      AS INTEGER                                       NO-UNDO.
DEF VAR ponteiro_xml  AS MEMPTR                                        NO-UNDO.
DEF VAR xml_req       AS LONGCHAR                                      NO-UNDO.
                                                                     
DEF VAR log_nrispbif AS INTE FORMAT "99999999"                         NO-UNDO.
DEF VAR log_nmresbcc AS CHAR FORMAT "x(15)"                            NO-UNDO.
DEF VAR log_nmextbcc AS CHAR FORMAT "x(35)"                            NO-UNDO.
DEF VAR log_flgdispb AS CHAR FORMAT "x(3)"                             NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                           NO-UNDO.
DEF VAR par_loginusr AS CHAR                                           NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                           NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                           NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                           NO-UNDO.
DEF VAR par_numipusr AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.

DEF TEMP-TABLE tt-bancos NO-UNDO
    FIELD nmresbcc LIKE crapban.nmresbcc
    FIELD cdbccxlt LIKE crapban.cdbccxlt
    FIELD nrispbif LIKE crapban.nrispbif
    FIELD flgdispb LIKE crapban.flgdispb FORMAT "SIM/NAO".

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE " Manutencao de Bancos " 
                                         FRAME f_moldura.

FORM SKIP(3)
     glb_cddopcao AT 20 AUTO-RETURN LABEL "          Opcao" 
                  HELP "Entre com a opcao desejada (A, C ou I)"
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                            glb_cddopcao = "I",
                            "014 - Opcao errada.")
    WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao.

FORM SKIP(1)
     tel_cdbccxlt AT  30 AUTO-RETURN LABEL "Banco"
                  HELP "Entre com o codigo do banco ou F7 para pesquisar."
     SKIP
      tel_nrispbif AT 24 AUTO-RETURN LABEL "Numero ISPB"
                  HELP "Entre com o numero ISPB do banco  ou F7 para pesquisar."
     SKIP
     tel_nmresbcc AT 21 AUTO-RETURN LABEL "Nome Abreviado"
                  HELP "Entre com o nome abreviado do banco."
     SKIP
     tel_nmextbcc AT 23 AUTO-RETURN LABEL "Nome Extenso"
                  HELP "Entre com o nome completo do banco."
     SKIP
     tel_flgdispb AT 20 AUTO-RETURN LABEL "Operando no SPB"
                  HELP "Informe se o banco esta operando no SPB."
     
     tel_dtinispb AT 43 AUTO-RETURN LABEL "Inicio da Operação"
                  HELP "Informe a Data de Inicio da Operacao no SPB."
     WITH ROW 10 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_bancos.

DEF QUERY  bbancos-q FOR tt-bancos.

DEF BROWSE bbancos-b QUERY bbancos-q
    DISP SPACE(5)
         tt-bancos.nmresbcc COLUMN-LABEL "Nome Abreviado"
         SPACE(3)
         tt-bancos.cdbccxlt COLUMN-LABEL "Banco"
         SPACE(3)
         tt-bancos.nrispbif COLUMN-LABEL "ISPB"
         SPACE(3)
         tt-bancos.flgdispb COLUMN-LABEL "Operando no SPB"
         SPACE(5)
        WITH 9 DOWN OVERLAY.    

DEF FRAME f_bancosc
          bbancos-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7.

 ASSIGN glb_cddopcao = "C".

 RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).


/************************************************/
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
      UPDATE glb_cddopcao 
             WITH FRAME f_opcao.

     LEAVE.

   END.
    
   IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN     /*   F4 OU FIM   */
      DO:
         RUN fontes/novatela.p.
         IF CAPS(glb_nmdatela) <> "BANCOS" THEN
            DO:
                HIDE FRAME f_bancos.
                RETURN.
            END.
         ELSE
            NEXT.
      END.

   ASSIGN glb_cddopcao = INPUT FRAME f_opcao glb_cddopcao
          tel_nmresbcc = ""
          tel_nmextbcc = ""
          tel_flgdispb = ""
          tel_dtinispb = ?
          tel_cdbccxlt = 0
          tel_nrispbif = 0. 

   CLEAR FRAME f_bancos NO-PAUSE.
   HIDE FRAME f_bancosc.
   CLEAR FRAME f_bancosc NO-PAUSE.

   IF aux_cddopcao <> glb_cddopcao  THEN
      DO:
          { includes/acesso.i }
          aux_cddopcao = glb_cddopcao.
      END.
   
   IF CAN-DO("A,I",glb_cddopcao)  THEN
      DO:
          IF  glb_dsdepart <> "TI"                    AND
              glb_dsdepart <> "COORD.ADM/FINANCEIRO"  AND
              glb_dsdepart <> "COORD.PRODUTOS"        AND
              glb_dsdepart <> "FINANCEIRO"            AND
              glb_dsdepart <> "COMPE"                 THEN 
              DO:
                  ASSIGN glb_cdcritic = 36.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  ASSIGN glb_cdcritic = 0.
                  NEXT.
              END.
      END.  

   atuBank:
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
      UPDATE tel_cdbccxlt  
             WITH FRAME f_bancos

        EDITING:
   
            READKEY PAUSE 1.
   
            APPLY LASTKEY.
                 
            /* Se precionado o F7 abre o zoom correspondente */
            IF LASTKEY = KEYCODE("F7")  THEN
               DO:
                   RUN Pesquisa_Banco.
   
                   IF  RETURN-VALUE <> "OK" THEN
                       NEXT atuBank. 
                   
                   OPEN QUERY bbancos-q 
                        FOR EACH tt-bancos /*WHERE crapban.cdbccxlt <> 0 */
                                         NO-LOCK BY tt-bancos.nmresbcc.

                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      
                      HIDE FRAME f_bancos. 
                      ENABLE bbancos-b 
                             WITH FRAME f_bancosc.
                      
                      WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.   
                      LEAVE.
      
                   END. /** Fim do DO WHILE TRUE **/ 

                   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
                      DO: 
                         HIDE FRAME f_bancosc.
                         NEXT atuBank.
                      END.
                   
               END.
             
        END. /* Fim do EDITING */
     
      LEAVE atuBank.
      
   END. /*** DO WHILE TRUE ***/

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
      DO: 
         HIDE FRAME f_bancosc.
         NEXT.
      END.

   IF tel_cdbccxlt = 0 THEN
      DO:  
         atuISPB:
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
            UPDATE tel_nrispbif WITH FRAME f_bancos
                
              EDITING:
            
                 READKEY PAUSE 1.
                    
                 APPLY LASTKEY.

                 /* Se precionado o F7 abre o zoom correspondente */
                 IF LASTKEY = KEYCODE("F7")  THEN
                    DO:
                       RUN Pesquisa_Banco.
   
                       IF  RETURN-VALUE <> "OK" THEN
                           NEXT atuISPB.

                       OPEN QUERY bbancos-q 
                            FOR EACH tt-bancos /*WHERE crapban.cdbccxlt <> 0 */
                                     NO-LOCK BY tt-bancos.nmresbcc.
                       
                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          
                          HIDE FRAME f_bancos. 

                          ENABLE bbancos-b 
                                 WITH FRAME f_bancosc.

                          WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
                          LEAVE.
            
                       END. /** Fim do DO WHILE TRUE **/ 

                       IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /*F4 OU FIM */
                          DO:
                             HIDE FRAME f_bancosc.
                             NEXT atuISPB.

                          END.
                      
                    END.
                
              END. /* Fim do EDITING */ 

            LEAVE atuISPB.

         END. /*** DO WHILE TRUE ***/  
            
      END.

   IF glb_cddopcao = "C" OR 
      glb_cddopcao = "A" THEN
      DO:
         EMPTY TEMP-TABLE tt-erro.

         { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
         
         MESSAGE "Aguarde...Consultando o banco.".

         /* Efetuar a chamada da rotina Oracle */ 
         RUN STORED-PROCEDURE pc_consulta_banco_car
             aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*codigo da cooperativa*/   
                                                 INPUT 0, /*codigo da agencia*/                  
                                                 INPUT 0, /*Numero do caixa*/                    
                                                 INPUT 1, /*idorigem*/                           
                                                 INPUT glb_cdoperad, /*codigo do operador*/      
                                                 INPUT glb_nmdatela, /*nome da tela*/            
                                                 INPUT glb_dtmvtolt, /*data do movimento*/       
                                                 INPUT tel_cdbccxlt, /*codigo do banco*/             
                                                 INPUT tel_nrispbif, /*Numero do ispbif*/        
                                                 INPUT glb_cddopcao, /*codigo da opcao*/         
                                                OUTPUT tel_nmresbcc, /*nome do banco abreviado*/                            
                                                OUTPUT tel_nmextbcc, /*nome do banco extenso*/                            
                                                OUTPUT tel_nrispbif, /*numero ispb aux*/                            
                                                OUTPUT tel_cdbccxlt, /*cod do banco aux*/                            
                                                OUTPUT tel_flgdispb, /*operando no SPB*/                            
                                                OUTPUT tel_dtinispb, /*data de inicio*/                                                                                        
                                                OUTPUT aux_nmdcampo, /*Nome do Campo*/           
                                                OUTPUT "", /*Saida OK/NOK*/                      
                                                OUTPUT ?, /*Tabela clob*/                        
                                                OUTPUT 0, /*Codigo da critica*/                  
                                                OUTPUT ""). /*Descricao da critica*/             
         
         HIDE MESSAGE NO-PAUSE.

         /* Fechar o procedimento para buscarmos o resultado */ 
         CLOSE STORED-PROC pc_consulta_banco_car
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
         
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
         
         /* Busca possíveis erros */ 
         ASSIGN glb_cdcritic = 0
                glb_dscritic = ""
                tel_nmresbcc = "" 
                tel_nmextbcc = ""
                tel_nrispbif = 0
                tel_cdbccxlt = 0
                tel_flgdispb = ""
                tel_dtinispb = ?
                glb_cdcritic = pc_consulta_banco_car.pr_cdcritic 
                               WHEN pc_consulta_banco_car.pr_cdcritic <> ?
                glb_dscritic = pc_consulta_banco_car.pr_dscritic 
                               WHEN pc_consulta_banco_car.pr_dscritic <> ?
                tel_nmresbcc = pc_consulta_banco_car.pr_nmresbcc 
                               WHEN pc_consulta_banco_car.pr_nmresbcc <> ?
                tel_nmextbcc = pc_consulta_banco_car.pr_nmextbcc 
                               WHEN pc_consulta_banco_car.pr_nmextbcc <> ?
                tel_nrispbif = pc_consulta_banco_car.pr_auxnrisp 
                               WHEN pc_consulta_banco_car.pr_auxnrisp <> ?
                tel_cdbccxlt = pc_consulta_banco_car.pr_auxcdbcc 
                               WHEN pc_consulta_banco_car.pr_auxcdbcc <> ?
                tel_flgdispb = pc_consulta_banco_car.pr_flgdispb 
                               WHEN pc_consulta_banco_car.pr_flgdispb <> ?
                tel_dtinispb = pc_consulta_banco_car.pr_dtinispb 
                               WHEN pc_consulta_banco_car.pr_dtinispb <> ?.
           
         IF glb_cdcritic <> 0  OR
            glb_dscritic <> "" THEN
            DO: 
               RUN gera_erro (INPUT glb_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT 1,          /** Sequencia **/
                              INPUT glb_cdcritic,
                              INPUT-OUTPUT glb_dscritic).
      
               MESSAGE glb_dscritic.
               PAUSE 3 NO-MESSAGE.
               NEXT.                  
            
            END.

         DISPLAY tel_nmresbcc 
                 tel_nmextbcc
                 tel_nrispbif 
                 tel_cdbccxlt 
                 tel_flgdispb 
                 tel_dtinispb 
                 WITH FRAME f_bancos.

         IF glb_cddopcao = "A" THEN
            DO:
               ASSIGN tel_cdbccxlt
                      tel_nrispbif.

               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  UPDATE tel_nmresbcc 
                         tel_nmextbcc 
                         tel_flgdispb 
                         tel_dtinispb
                         WITH FRAME f_bancos.

                  LEAVE.

               END.
               
               IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /*F4 OU FIM */
                  NEXT.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  ASSIGN aux_confirma = "N"
                         glb_cdcritic = 78.

                  RUN fontes/critic.p.
                  ASSIGN glb_cdcritic = 0.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  LEAVE.

               END.
    
               IF KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                  aux_confirma <> "S"                 THEN
                  DO:
                      ASSIGN glb_cdcritic = 79.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      ASSIGN glb_cdcritic = 0.
                      NEXT.
                  END.
            
               MESSAGE "Aguarde... Efetuando alteracao.".

               /* Efetuar a chamada da rotina Oracle */ 
               RUN STORED-PROCEDURE pc_altera_banco_car
                   aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*codigo da cooperativa*/       
                                                       INPUT 0, /*codigo da agencia*/                      
                                                       INPUT 0, /*Numero do caixa*/                        
                                                       INPUT 1, /*idorigem*/                               
                                                       INPUT glb_cdoperad, /*codigo do operador*/          
                                                       INPUT glb_nmdatela, /*nome da tela*/                
                                                       INPUT glb_dtmvtolt, /*data do movimento*/           
                                                       INPUT tel_cdbccxlt, /*codigo do banco*/             
                                                       INPUT tel_nrispbif, /*Numero do ispbif*/            
                                                       INPUT glb_cddopcao, /*codigo da opcao*/             
                                                       INPUT tel_nmresbcc, /*nome do banco abreviado*/                           
                                                       INPUT tel_nmextbcc, /*nome do banco extenso*/                                                                            
                                                       INPUT tel_flgdispb, /*Operando no SPB*/                           
                                                       INPUT tel_dtinispb, /*data de inicio*/                                                                                     
                                                      OUTPUT aux_nmdcampo, /*Nome do Campo*/               
                                                      OUTPUT "", /*Saida OK/NOK*/                          
                                                      OUTPUT ?, /*Tabela clob*/                            
                                                      OUTPUT 0, /*Codigo da critica*/                      
                                                      OUTPUT ""). /*Descricao da critica*/
                                  
               HIDE MESSAGE NO-PAUSE.

               /* Fechar o procedimento para buscarmos o resultado */ 
               CLOSE STORED-PROC pc_altera_banco_car
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
               
               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
               
               /* Busca possíveis erros */ 
               ASSIGN glb_cdcritic = 0
                      glb_dscritic = ""
                      glb_cdcritic = pc_altera_banco_car.pr_cdcritic 
                                     WHEN pc_altera_banco_car.pr_cdcritic <> ?
                      glb_dscritic = pc_altera_banco_car.pr_dscritic 
                                     WHEN pc_altera_banco_car.pr_dscritic <> ?.

               IF glb_cdcritic <> 0  OR
                  glb_dscritic <> "" THEN
                  DO:
                     RUN gera_erro (INPUT glb_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT 1,          /** Sequencia **/
                                    INPUT glb_cdcritic,
                                    INPUT-OUTPUT glb_dscritic).
            
                     MESSAGE glb_dscritic.
                     PAUSE 3 NO-MESSAGE.
                     NEXT.
                  
                  END.
                  
            END.

      END. 

   ELSE
   IF glb_cddopcao = "I"  THEN
      DO:
         EMPTY TEMP-TABLE tt-erro.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            UPDATE tel_nrispbif 
                   tel_nmresbcc 
                   tel_nmextbcc 
                   tel_flgdispb 
                   tel_dtinispb  
                   WITH FRAME f_bancos.

            LEAVE.

         END.

         IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            NEXT.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            ASSIGN aux_confirma = "N"
                   glb_cdcritic = 78.
         
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.
            BELL.
            MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
            LEAVE.
         
         END.
         
         IF KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
            aux_confirma <> "S"                 THEN
            DO:
                ASSIGN glb_cdcritic = 79.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                ASSIGN glb_cdcritic = 0.
                NEXT.
            END.
         
         { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

         MESSAGE "Aguarde...Efetuando inclusao".

         /* Efetuar a chamada da rotina Oracle */ 
         RUN STORED-PROCEDURE pc_inclui_banco_car
             aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*codigo da cooperativa*/   
                                                 INPUT 0, /*codigo da agencia*/                  
                                                 INPUT 0, /*Numero do caixa*/                    
                                                 INPUT 1, /*idorigem*/                           
                                                 INPUT glb_cdoperad, /*codigo do operador*/      
                                                 INPUT glb_nmdatela, /*nome da tela*/            
                                                 INPUT glb_dtmvtolt, /*data do movimento*/       
                                                 INPUT tel_cdbccxlt, /*codigo do banco*/           
                                                 INPUT tel_nrispbif, /*Numero do ispbif*/        
                                                 INPUT glb_cddopcao, /*codigo da opcao*/         
                                                 INPUT tel_nmresbcc, /*nome do banco abreviado*/                            
                                                 INPUT tel_nmextbcc, /*nome do banco extenso*/                                                                             
                                                 INPUT tel_flgdispb, /*Operando no SPB*/                            
                                                 INPUT tel_dtinispb, /*data de inicio*/                                                                                      
                                                OUTPUT aux_nmdcampo, /*Nome do Campo*/           
                                                OUTPUT "", /*Saida OK/NOK*/                      
                                                OUTPUT ?, /*Tabela clob*/                        
                                                OUTPUT 0, /*Codigo da critica*/                  
                                                OUTPUT ""). /*Descricao da critica*/             
                            
         HIDE MESSAGE NO-PAUSE.

         /* Fechar o procedimento para buscarmos o resultado */ 
         CLOSE STORED-PROC pc_inclui_banco_car
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
         
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
         
         /* Busca possíveis erros */ 
         ASSIGN glb_cdcritic = 0
                glb_dscritic = ""
                glb_cdcritic = pc_inclui_banco_car.pr_cdcritic 
                               WHEN pc_inclui_banco_car.pr_cdcritic <> ?
                glb_dscritic = pc_inclui_banco_car.pr_dscritic 
                               WHEN pc_inclui_banco_car.pr_dscritic <> ?.
                
         IF glb_cdcritic <> 0  OR
            glb_dscritic <> "" THEN
            DO:
               RUN gera_erro (INPUT glb_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT 1,          /** Sequencia **/
                              INPUT glb_cdcritic,
                              INPUT-OUTPUT glb_dscritic).
               
               MESSAGE glb_dscritic.
               PAUSE 3 NO-MESSAGE.
               NEXT.
            
            END.
         
      END.
   /***  Desabilitar a opcao *** 
   ELSE
   IF  glb_cddopcao = "E"  THEN
       DO:
           { includes/bancose.i }
       END.
   *****************************/    

 END. /*** DO WHILE TRUE ***/

 PROCEDURE Pesquisa_Banco:

    EMPTY TEMP-TABLE tt-bancos.
    EMPTY TEMP-TABLE tt-erro.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    MESSAGE "Aguarde...Consultando informacoes.".

    /* Efetuar a chamada da rotina Oracle */ 
    RUN STORED-PROCEDURE pc_pesquisa_banco_car
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*codigo da cooperativa*/
                                            INPUT 0, /*codigo da agencia*/                
                                            INPUT 0, /*Numero do caixa*/                  
                                            INPUT 1, /*idorigem*/                              
                                            INPUT glb_cdoperad, /*codigo do operador*/    
                                            INPUT glb_nmdatela, /*nome da tela*/                                            
                                           OUTPUT aux_nmdcampo, /*Nome do Campo*/         
                                           OUTPUT "", /*Saida OK/NOK*/                    
                                           OUTPUT ?, /*Tabela Bancos*/                    
                                           OUTPUT 0, /*Codigo da critica*/                
                                           OUTPUT ""). /*Descricao da critica*/           
    
    HIDE MESSAGE NO-PAUSE.

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_pesquisa_banco_car
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    HIDE MESSAGE NO-PAUSE.
    
    /* Busca possíveis erros */ 
    ASSIGN glb_cdcritic = 0
           glb_dscritic = ""
           glb_cdcritic = pc_pesquisa_banco_car.pr_cdcritic 
                          WHEN pc_pesquisa_banco_car.pr_cdcritic <> ?
           glb_dscritic = pc_pesquisa_banco_car.pr_dscritic 
                          WHEN pc_pesquisa_banco_car.pr_dscritic <> ?.

    IF glb_cdcritic <> 0  OR
       glb_dscritic <> "" THEN
       DO: 
          RUN gera_erro (INPUT glb_cdcooper,
                         INPUT 0,
                         INPUT 0,
                         INPUT 1,          /** Sequencia **/
                         INPUT glb_cdcritic,
                         INPUT-OUTPUT glb_dscritic).

          MESSAGE glb_dscritic.          
          PAUSE 3 NO-MESSAGE.
          RETURN "NOK".
       
       END.
    
    EMPTY TEMP-TABLE tt-bancos.
    
    /*Leitura do XML de retorno da proc e criacao dos registros na tt-contras
    para visualizacao dos registros na tela */
    
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_pesquisa_banco_car.pr_clob_ret.
    
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */
     
    IF ponteiro_xml <> ? THEN
       DO:   
          xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
          xDoc:GET-DOCUMENT-ELEMENT(xRoot).
          
          DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
             
             xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
     
             IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 
           
             IF xRoot2:NUM-CHILDREN > 0 THEN
                DO:
                    CREATE tt-bancos.
                END.
     
             DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
               
                xRoot2:GET-CHILD(xField,aux_cont).
                  
                IF xField:SUBTYPE <> "ELEMENT" THEN 
                   NEXT. 
                
                xField:GET-CHILD(xText,1).

                ASSIGN tt-bancos.nmresbcc = xText:NODE-VALUE WHEN xField:NAME = "nmresbcc".
                ASSIGN tt-bancos.cdbccxlt = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdbccxlt".
                ASSIGN tt-bancos.nrispbif = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrispbif".

                
                IF xField:NAME = "flgdispb" THEN 
                   DO:
                      CASE xText:NODE-VALUE:
                          WHEN "0" THEN ASSIGN tt-bancos.flgdispb = NO.
                          WHEN "1" THEN ASSIGN tt-bancos.flgdispb = YES.
                          OTHERWISE ASSIGN tt-bancos.flgdispb = NO.
                      END CASE.
                   END.
                
             END. 
            
          END.
     
          SET-SIZE(ponteiro_xml) = 0. 
  
       END.
     
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
   
    HIDE MESSAGE NO-PAUSE.
    
    RETURN "OK".

END PROCEDURE. /* Pesquisa_Banco */
    


/* .......................................................................... */





















