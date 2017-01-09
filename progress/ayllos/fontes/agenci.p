/*..............................................................................

   Programa: Fontes/agenci.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes   
   Data    : Fevereiro/2004                    Ultima Atualizacao: 30/11/2016
                        
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Permitir efetuar o cadastramento das agencias dos bancos

   ALTERACAO : 23/05/2005 - Comentados campos referente Cidade, CNPJ e         
                            Situacao(Ativa)  (Diego). 

               22/07/2005 - Modificado Help da glb_cddopcao (Diego).

               28/07/2005 - Excluido campo nrcnpjag no browse da opcao "C"
                            (Diego).
                            
               20/06/2007 - Retirado os comentarios dos campos referentes a
                            Situacao 
                            Adicionado critica para permitir somente os
                            operadores: 1, 997, 799 nas opcoes A E I(Guilherme).
                  
               23/01/2009 - Retirar permissao do operador 799, permitir ao 979 
                            (Gabriel).
                            
               11/05/2009 - Alteracao CDOPERAD (Kbase).             
               
               04/12/2009 - Melhorias referente a COMPE - Tarefa 29111 (David).

               23/06/2010 - Incluir dsdepart COMPE para opcao A,E,I (Ze).
               
               04/02/2013 - Alteracao chamada de procedures na b1wgen0149
                            (David Kruger).
                            
               08/01/2014 - Ajustes para homologacao (Adriano).
                            
               30/11/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
.............................................................................*/

{ includes/var_online.i } 
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0149tt.i }

DEF NEW SHARED VAR shr_inpessoa AS INTE                                NO-UNDO.

DEF VAR tel_cddbanco AS INTE FORMAT "zz9"                              NO-UNDO.
DEF VAR tel_cdageban AS INTE FORMAT "zzz9"                             NO-UNDO.

DEF VAR tel_nmextbcc LIKE crapban.nmextbcc                             NO-UNDO.
DEF VAR tel_dgagenci LIKE crapagb.dgagenci                             NO-UNDO.
DEF VAR tel_nmageban LIKE crapagb.nmageban                             NO-UNDO.
DEF VAR tel_cdsitagb LIKE crapagb.cdsitagb                             NO-UNDO.
DEF VAR tel_nmcidade LIKE crapcaf.nmcidade                             NO-UNDO.
DEF VAR tel_cdufresd LIKE crapcaf.cdufresd                             NO-UNDO.
DEF VAR tel_cdcompen LIKE crapcaf.cdcompen                             NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.

DEF VAR aux_contador AS INTE FORMAT "z9"                               NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
  
DEF VAR h-b1wgen0149 AS HANDLE      NO-UNDO.

DEF QUERY q_agencia FOR tt-agencia.
DEF QUERY q_feriado FOR tt-feriados.

DEF BROWSE b-agencia QUERY q_agencia
    DISP SPACE(1)
         tt-agencia.cddbanco COLUMN-LABEL "Banco"
         SPACE(1)
         tt-agencia.cdageban COLUMN-LABEL "Agencia"
         tt-agencia.dgagenci COLUMN-LABEL "Dg.Ag"   
         SPACE(1)
         tt-agencia.nmageban COLUMN-LABEL "Nome" FORMAT "x(40)"
         SPACE(1)
         tt-agencia.cdsitagb COLUMN-LABEL "Ativa" FORMAT "x(1)"
         WITH 10 DOWN OVERLAY NO-BOX.  

FORM b-agencia HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
     WITH CENTERED OVERLAY ROW 7 FRAME f_lista_agencia.

DEF BROWSE b-feriado QUERY q_feriado
    DISP tt-feriados.dtferiad 
         WITH 3 DOWN OVERLAY NO-LABEL NO-BOX.

FORM WITH ROW 4 TITLE glb_tldatela OVERLAY SIZE 80 BY 18 FRAME f_moldura.

FORM glb_cddopcao LABEL "Opcao" AUTO-RETURN
                  HELP "Entre com a opcao desejada (A, C, E ou I)."
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                            glb_cddopcao = "E" OR glb_cddopcao = "I",
                            "014 - Opcao errada.")
     WITH ROW 6 SIDE-LABELS COLUMN 18 NO-BOX OVERLAY FRAME f_opcao.

FORM tel_cddbanco LABEL "Banco" AUTO-RETURN 
                  HELP "Entre com o codigo do banco."
     tel_nmextbcc AT 12 NO-LABEL 
     WITH ROW 8 SIDE-LABELS CENTERED NO-BOX OVERLAY FRAME f_banco.

FORM tel_cdageban LABEL "Agencia" AUTO-RETURN  
                  HELP "Entre com o codigo da agencia 0 para todas."
     tel_dgagenci AT 16 LABEL "Dig.Agencia" AUTO-RETURN
                  HELP "Entre com o digito da agencia."
     SKIP
     tel_nmageban LABEL "Nome   " AUTO-RETURN
                  HELP "Entre com o nome da agencia."
                  VALIDATE (tel_nmageban <> " ",
                            "357 - O campo deve ser preenchido.")
     SKIP
     tel_cdsitagb LABEL "Ativa  " AUTO-RETURN FORMAT "!(1)"
                  HELP "Entre com a Situacao da agencia (Ativa)."
                  VALIDATE (tel_cdsitagb = "S" OR tel_cdsitagb = "N", 
                            "513 - Tipo de situacao errado.")
     tel_cdcompen AT 33 LABEL "Cod.Compensacao" AUTO-RETURN
                  HELP "Entre com o codigo da compensacao."
                  VALIDATE (tel_cdcompen > 0,
                            "357 - O campo deve ser preenchido.")
     SKIP
     tel_nmcidade LABEL "Cidade " AUTO-RETURN
                  HELP "Entre com a cidade da agencia."
                  VALIDATE (tel_nmcidade <> " ",
                            "357 - O campo deve ser preenchido.")
     tel_cdufresd LABEL "UF"      AUTO-RETURN
                  HELP "Entre com a UF da agencia."
                  VALIDATE (tel_cdufresd <> " ",
                            "357 - O campo deve ser preenchido.")
     WITH ROW 10 SIDE-LABELS CENTERED NO-BOX OVERLAY FRAME f_agencia.

FORM "Feriados Municipais"
     SKIP(1)
     b-feriado AT 03 HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
     WITH CENTERED OVERLAY NO-BOX WIDTH 21 ROW 15 FRAME f_feriado.


ON RETURN OF b-agencia IN FRAME f_lista_agencia DO:

   ASSIGN tel_cdageban = tt-agencia.cdageban
          tel_dgagenci = tt-agencia.dgagenci
          tel_nmageban = tt-agencia.nmageban
          tel_cdsitagb = tt-agencia.cdsitagb
          tel_cdcompen = tt-agencia.cdcompen
          tel_nmcidade = tt-agencia.nmcidade
          tel_cdufresd = tt-agencia.cdufresd
          aux_nrdrowid = tt-agencia.nrdrowid.
   
   APPLY "END-ERROR".

END.  /** Fim do Return **/


VIEW FRAME f_moldura.
PAUSE(0).

IF NOT VALID-HANDLE (h-b1wgen0149) THEN
   RUN sistema/generico/procedures/b1wgen0149.p PERSISTENT SET h-b1wgen0149.

DO WHILE TRUE:

   CLEAR FRAME f_opcao   NO-PAUSE.
   CLEAR FRAME f_banco   NO-PAUSE.
   HIDE  FRAME f_banco   NO-PAUSE.
   CLEAR FRAME f_agencia NO-PAUSE.
   HIDE  FRAME f_agencia NO-PAUSE.

   ASSIGN glb_cddopcao = "C".

   DISPLAY glb_cddopcao 
           WITH FRAME f_opcao.
   
   RUN fontes/inicia.p.         

   ASSIGN tel_cdageban = 0
          tel_dgagenci = ""
          tel_nmageban = ""
          tel_nmcidade = ""
          tel_cdufresd = ""
          tel_cdcompen = 0
          tel_cdsitagb = "N"
          tel_cddbanco = 0
          tel_nmextbcc = "".

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao 
             WITH FRAME f_opcao.

      LEAVE.

   END. /** Fim do DO WHILE TRUE **/

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN 
      DO:
         RUN fontes/novatela.p.

         IF CAPS(glb_nmdatela) <> "AGENCI"  THEN
            DO:
                HIDE FRAME f_opcao   NO-PAUSE.
                HIDE FRAME f_banco   NO-PAUSE.
                HIDE FRAME f_agencia NO-PAUSE.

                IF VALID-HANDLE (h-b1wgen0149) THEN
                   DELETE PROCEDURE h-b1wgen0149.
                
                RETURN.

            END.
         ELSE
            NEXT.

      END.

   IF aux_cddopcao <> INPUT glb_cddopcao  THEN
      DO:
         { includes/acesso.i }
         ASSIGN aux_cddopcao = INPUT glb_cddopcao.

      END.

   IF CAN-DO("A,E,I",glb_cddopcao)  THEN
      DO:
         IF  glb_cddepart <> 20  AND   /* TI */                    
             glb_cddepart <> 8   AND   /* COORD.ADM/FINANCEIRO */  
             glb_cddepart <> 9   AND   /* COORD.PRODUTOS       */   
             glb_cddepart <> 4   THEN  /* COMPE                */   
            DO:
                ASSIGN glb_cdcritic = 36.
                RUN fontes/critic.p.
                ASSIGN glb_cdcritic = 0.
   
                BELL.
                MESSAGE glb_dscritic.
   
                NEXT.

            END.
            
      END.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      CLEAR FRAME f_agencia NO-PAUSE.
      HIDE FRAME f_agencia NO-PAUSE.

      EMPTY TEMP-TABLE tt-banco.
      EMPTY TEMP-TABLE tt-erro.

      ASSIGN tel_cdageban = 0.

      UPDATE tel_cddbanco 
             WITH FRAME f_banco.
          
      MESSAGE "Consultando o banco. Aguarde...".

      RUN busca-banco IN h-b1wgen0149(INPUT glb_cdcooper,
                                      INPUT glb_cdagenci,
                                      INPUT 0 /* nrdcaixa */,
                                      INPUT glb_cdoperad,
                                      INPUT glb_cddepart,
                                      INPUT glb_nmdatela,
                                      INPUT 1, /* AYLLOS */
                                      INPUT glb_cddopcao,
                                      INPUT tel_cddbanco,
                                      INPUT glb_dtmvtolt,
                                      INPUT 99999, /* nrregist */
                                      INPUT 0, /* nriniseq */    
                                      OUTPUT aux_nmdcampo,
                                      OUTPUT aux_qtregist,
                                      OUTPUT TABLE tt-banco,
                                      OUTPUT TABLE tt-erro).

      HIDE MESSAGE NO-PAUSE.

      IF RETURN-VALUE <> "OK" THEN
         DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
       
            IF AVAIL tt-erro THEN
               MESSAGE tt-erro.dscritic.
            ELSE
              MESSAGE "Nao foi possivel realizar a consulta".
       
            PAUSE(2)NO-MESSAGE.
            HIDE MESSAGE.

            NEXT.
         
         END.

      FIND FIRST tt-banco NO-LOCK NO-ERROR.

      ASSIGN tel_nmextbcc = tt-banco.nmextbcc.
      
      DISPLAY tel_nmextbcc WITH FRAME f_banco.
   
      IF INPUT glb_cddopcao = "A"  THEN
         DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
               CLEAR FRAME f_agencia NO-PAUSE.

               ASSIGN tel_cdageban = 0              
                      tel_dgagenci = ""             
                      tel_nmageban = ""             
                      tel_cdsitagb = "N"             
                      tel_cdcompen = 0              
                      tel_nmcidade = ""             
                      tel_cdufresd = "".            
   
               UPDATE tel_cdageban 
                      WITH FRAME f_agencia.
               
               EMPTY TEMP-TABLE tt-erro.
               EMPTY TEMP-TABLE tt-agencia.  
               EMPTY TEMP-TABLE tt-feriados.

               MESSAGE "Consultando agencia. Aguarde...".
   
               RUN busca-agencia IN h-b1wgen0149(INPUT glb_cdcooper,
                                                 INPUT glb_cdagenci,
                                                 INPUT 0, /*_nrdcaixa*/
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_cddepart,
                                                 INPUT glb_nmdatela,
                                                 INPUT 1, /*ayllos*/ 
                                                 INPUT tel_cdageban,
                                                 INPUT tel_cddbanco,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT glb_cddopcao,
                                                 INPUT 99999, /*nrregist*/
                                                 INPUT 0, /*par_nriniseq*/
                                                 OUTPUT aux_nmdcampo,
                                                 OUTPUT aux_qtregist,
                                                 OUTPUT TABLE tt-agencia,
                                                 OUTPUT TABLE tt-feriados,
                                                 OUTPUT TABLE tt-erro).

               HIDE MESSAGE NO-PAUSE.
                          
               IF RETURN-VALUE <> "OK" THEN
                  DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
                     IF AVAIL tt-erro THEN
                        MESSAGE tt-erro.dscritic.
                     ELSE
                       MESSAGE "Nao foi possivel consultar a agencia.".
               
                     PAUSE(2)NO-MESSAGE.
                     HIDE MESSAGE.
                     NEXT.
                 
                  END.
               
               IF tel_cddbanco <> 0  AND
                  tel_cdageban = 0   THEN
                  DO:
                     IF TEMP-TABLE tt-agencia:HAS-RECORDS THEN
                        DO: 
                           OPEN QUERY q_agencia FOR EACH tt-agencia NO-LOCK.
                         
                           ENABLE b-agencia WITH FRAME f_lista_agencia.
                         
                           PAUSE 0.
                         
                           WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                           
                           IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                              DO: 
                                 HIDE FRAME f_lista_agencia.
                                 CLOSE QUERY q_agencia.
                                 NEXT.
                              
                              END.
                         
                           HIDE FRAME f_lista_agencia.
                           CLOSE QUERY q_agencia.
                           HIDE MESSAGE NO-PAUSE.
                  
                        END. /** Fim da leitura tt-agencia **/
               
                  END.
               ELSE
                  DO:
                     FIND tt-agencia NO-LOCK NO-ERROR.
                     
                     ASSIGN tel_cdageban = tt-agencia.cdageban
                            tel_dgagenci = tt-agencia.dgagenci
                            tel_nmageban = tt-agencia.nmageban
                            tel_cdsitagb = tt-agencia.cdsitagb
                            tel_cdcompen = tt-agencia.cdcompen
                            tel_nmcidade = tt-agencia.nmcidade
                            tel_cdufresd = tt-agencia.cdufresd.

                  END.

               DISP tel_cdageban
                    tel_dgagenci
                    tel_nmageban
                    tel_cdsitagb
                    tel_cdcompen
                    tel_nmcidade
                    tel_cdufresd
                    WITH FRAME f_agencia.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
                  UPDATE tel_dgagenci 
                         tel_nmageban 
                         tel_cdsitagb 
                         WITH FRAME f_agencia.     
   
                   LEAVE.
   
               END.
   
               IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                  NEXT. 

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  ASSIGN aux_confirma = "N"
                         glb_cdcritic = 78.
                  RUN fontes/critic.p.
                  ASSIGN glb_cdcritic = 0.
            
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  
                  LEAVE.
            
               END. /** Fim do DO WHILE TRUE **/
            
              IF KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                 aux_confirma <> "S"                 THEN
                 DO:
                     ASSIGN glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     ASSIGN glb_cdcritic = 0.
            
                     BELL.
                     MESSAGE glb_dscritic.
                     
                     NEXT.
                 END.
            
               MESSAGE "Realizando alteracoes. Aguarde...".

               RUN altera-agencia IN h-b1wgen0149(INPUT glb_cdcooper,
                                                  INPUT glb_cdagenci,
                                                  INPUT 0, /* nrdcaixa */
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_cddepart,
                                                  INPUT glb_nmdatela,
                                                  INPUT 1, /* AYLLOS */
                                                  INPUT glb_cddopcao,
                                                  INPUT tel_cdageban,
                                                  INPUT tel_cddbanco,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT tel_dgagenci,
                                                  INPUT tel_nmageban,
                                                  INPUT tel_cdsitagb,
                                                  OUTPUT aux_nmdcampo,
                                                  OUTPUT TABLE tt-erro).

               HIDE MESSAGE NO-PAUSE.
   
               IF RETURN-VALUE <> "OK" THEN
                  DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
                     IF AVAIL tt-erro THEN
                        MESSAGE tt-erro.dscritic.
                     ELSE
                       MESSAGE "Nao foi possivel realizar a consulta".
               
                      
                     PAUSE(2)NO-MESSAGE.
                     HIDE MESSAGE.

                     NEXT.
                 
                  END.

               MESSAGE "Registro alterado com sucesso!".
               PAUSE(2)NO-MESSAGE.
               HIDE MESSAGE. 
   
               LEAVE.
   
            END. /** Fim do DO WHILE TRUE **/
   
            IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
               NEXT. 
   
   
         END. /** Fim da opcao "A" **/
      ELSE       
      IF INPUT glb_cddopcao = "C"  THEN
         DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_cdageban 
                      WITH FRAME f_agencia.

               EMPTY TEMP-TABLE tt-erro.
               EMPTY TEMP-TABLE tt-agencia.  
               EMPTY TEMP-TABLE tt-feriados.

               MESSAGE "Consultando agencia. Aguarde...".
   
               RUN busca-agencia IN h-b1wgen0149(INPUT glb_cdcooper,
                                                 INPUT glb_cdagenci,
                                                 INPUT 0, /*nrdcaixa*/
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_cddepart,
                                                 INPUT glb_nmdatela,
                                                 INPUT 1, /*idorigem*/ 
                                                 INPUT tel_cdageban,
                                                 INPUT tel_cddbanco,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT glb_cddopcao,
                                                 INPUT 99999, /*nrregist*/
                                                 INPUT 0, /*nriniseq*/
                                                 OUTPUT aux_nmdcampo,
                                                 OUTPUT aux_qtregist,
                                                 OUTPUT TABLE tt-agencia,
                                                 OUTPUT TABLE tt-feriados,
                                                 OUTPUT TABLE tt-erro).

               HIDE MESSAGE NO-PAUSE.
                          
               IF RETURN-VALUE <> "OK" THEN
                  DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
                     IF AVAIL tt-erro THEN
                        MESSAGE tt-erro.dscritic.
                     ELSE
                       MESSAGE "Nao foi possivel realizar a consulta".
               
                     PAUSE(2)NO-MESSAGE.
                     HIDE MESSAGE.
                     NEXT.
                 
                  END.
                  
               IF tel_cddbanco <> 0  AND
                  tel_cdageban = 0   THEN
                  DO:
                     IF TEMP-TABLE tt-agencia:HAS-RECORDS THEN
                        DO: 
                           OPEN QUERY q_agencia FOR EACH tt-agencia NO-LOCK.
                         
                           ENABLE b-agencia WITH FRAME f_lista_agencia.
                         
                           PAUSE 0.
                         
                           WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                           
                           IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                              DO: 
                                 HIDE FRAME f_lista_agencia.
                                 CLOSE QUERY q_agencia.
                                 NEXT.
                              
                              END.
                         
                           HIDE FRAME f_lista_agencia.
                           CLOSE QUERY q_agencia.
                           HIDE MESSAGE NO-PAUSE.
                  
                        END. /** Fim da leitura tt-agencia **/
               
                  END.
               ELSE
                  DO:
                     FIND tt-agencia NO-LOCK NO-ERROR.
                     
                     ASSIGN tel_cdageban = tt-agencia.cdageban
                            tel_dgagenci = tt-agencia.dgagenci
                            tel_nmageban = tt-agencia.nmageban
                            tel_cdsitagb = tt-agencia.cdsitagb
                            tel_cdcompen = tt-agencia.cdcompen
                            tel_nmcidade = tt-agencia.nmcidade
                            tel_cdufresd = tt-agencia.cdufresd
                            aux_nrdrowid = tt-agencia.nrdrowid.

                  END.

               DISP tel_cdageban
                    tel_dgagenci
                    tel_nmageban
                    tel_cdsitagb
                    tel_cdcompen
                    tel_nmcidade
                    tel_cdufresd
                    WITH FRAME f_agencia.

               IF TEMP-TABLE tt-feriados:HAS-RECORDS THEN
                  DO:
                     OPEN QUERY q_feriado 
                          FOR EACH tt-feriados 
                              WHERE tt-feriados.nrdrowid = aux_nrdrowid 
                                    NO-LOCK.
                   
                     ENABLE b-feriado WITH FRAME f_feriado.
                   
                     PAUSE 0.
                     
                     WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                     
                     IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        DO: 
                           HIDE FRAME f_feriado.
                           CLOSE QUERY q_feriado.
                           NEXT.
                        
                        END.
                   
                     HIDE FRAME f_feriado.
                   
                     HIDE MESSAGE NO-PAUSE.

                  END.

               NEXT.
   
            END. /** Fim do DO WHILE TRUE **/
   
            IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
               NEXT. 
            
         END.  /** Fim da opcao "C" **/
      ELSE
      IF INPUT glb_cddopcao = "E"  THEN
         DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               CLEAR FRAME f_agencia NO-PAUSE.

               ASSIGN tel_cdageban = 0              
                      tel_dgagenci = ""             
                      tel_nmageban = ""             
                      tel_cdsitagb = "N"             
                      tel_cdcompen = 0              
                      tel_nmcidade = ""             
                      tel_cdufresd = "".            

               UPDATE tel_cdageban 
                      WITH FRAME f_agencia.

               EMPTY TEMP-TABLE tt-erro.
               EMPTY TEMP-TABLE tt-agencia.  
               EMPTY TEMP-TABLE tt-feriados.

               MESSAGE "Consultando agencia. Aguarde...".
   
               RUN busca-agencia IN h-b1wgen0149(INPUT glb_cdcooper,
                                                 INPUT glb_cdagenci,
                                                 INPUT 0, /*nrdcaixa*/
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_cddepart,
                                                 INPUT glb_nmdatela,
                                                 INPUT 1, /*ayllos*/ 
                                                 INPUT tel_cdageban,
                                                 INPUT tel_cddbanco,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT glb_cddopcao,
                                                 INPUT 99999, /*nrregist*/
                                                 INPUT 0, /*nriniseq*/
                                                 OUTPUT aux_nmdcampo,
                                                 OUTPUT aux_qtregist,
                                                 OUTPUT TABLE tt-agencia,
                                                 OUTPUT TABLE tt-feriados,
                                                 OUTPUT TABLE tt-erro).

               HIDE MESSAGE NO-PAUSE.
                          
               IF RETURN-VALUE <> "OK" THEN
                  DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
                     IF AVAIL tt-erro THEN
                        MESSAGE tt-erro.dscritic.
                     ELSE
                       MESSAGE "Nao foi possivel realizar a consulta".
               
                     PAUSE(2)NO-MESSAGE.
                     HIDE MESSAGE.
                     NEXT.
                 
                  END.
               
               IF tel_cddbanco <> 0  AND
                  tel_cdageban = 0   THEN
                  DO:
                     IF TEMP-TABLE tt-agencia:HAS-RECORDS THEN
                        DO: 
                           OPEN QUERY q_agencia FOR EACH tt-agencia NO-LOCK.
                         
                           ENABLE b-agencia WITH FRAME f_lista_agencia.
                         
                           PAUSE 0.
                         
                           WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                           
                           IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                              DO: 
                                 HIDE FRAME f_lista_agencia.
                                 CLOSE QUERY q_agencia.
                                 NEXT.
                              
                              END.
                         
                           HIDE FRAME f_lista_agencia.
                           CLOSE QUERY q_agencia.
                           HIDE MESSAGE NO-PAUSE.
                  
                        END. /** Fim da leitura tt-agencia **/
               
                  END.
               ELSE
                  DO:
                     FIND tt-agencia NO-LOCK NO-ERROR.
                     
                     ASSIGN tel_cdageban = tt-agencia.cdageban
                            tel_dgagenci = tt-agencia.dgagenci
                            tel_nmageban = tt-agencia.nmageban
                            tel_cdsitagb = tt-agencia.cdsitagb
                            tel_cdcompen = tt-agencia.cdcompen
                            tel_nmcidade = tt-agencia.nmcidade
                            tel_cdufresd = tt-agencia.cdufresd.
                     
                  END.

               DISP tel_cdageban
                    tel_dgagenci
                    tel_nmageban
                    tel_cdsitagb
                    tel_cdcompen
                    tel_nmcidade
                    tel_cdufresd
                    WITH FRAME f_agencia.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  ASSIGN aux_confirma = "N"
                         glb_cdcritic = 78.

                  RUN fontes/critic.p.

                  ASSIGN glb_cdcritic = 0.
            
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  
                  LEAVE.
            
               END. /** Fim do DO WHILE TRUE **/
            
               IF KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                  aux_confirma <> "S"                 THEN
                  DO:
                     ASSIGN glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     ASSIGN glb_cdcritic = 0.
                     BELL.
                     MESSAGE glb_dscritic.
                     NEXT.
                  END.
            
               MESSAGE "Realizando exclusao da agencia. Aguarde...".

               RUN deleta-agencia IN h-b1wgen0149(INPUT glb_cdcooper,
                                                  INPUT glb_cdagenci,
                                                  INPUT 0, /* nrdcaixa */
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_cddepart,
                                                  INPUT glb_nmdatela,
                                                  INPUT 1, /* AYLLOS */
                                                  INPUT glb_cddopcao,
                                                  INPUT tel_cdageban,
                                                  INPUT tel_cddbanco,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT tel_dgagenci,
                                                  INPUT tel_nmageban,
                                                  INPUT tel_cdsitagb,
                                                  OUTPUT aux_nmdcampo,
                                                  OUTPUT TABLE tt-erro).
   
               HIDE MESSAGE NO-PAUSE.

               IF RETURN-VALUE <> "OK" THEN
                  DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
                     IF AVAIL tt-erro THEN
                        MESSAGE tt-erro.dscritic.
                     ELSE
                       MESSAGE "Nao foi possivel realizar a consulta".
               
                     PAUSE(2)NO-MESSAGE.
                     HIDE MESSAGE.
                     NEXT.
                 
                  END.
   
               MESSAGE "Registro excluido com sucesso!".
               PAUSE(2)NO-MESSAGE.
               HIDE MESSAGE. 

               LEAVE.

            END. /** Fim do DO WHILE TRUE **/

         END. /** Fim da Opcao "E" **/
      ELSE
      IF INPUT glb_cddopcao = "I"  THEN
         DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
               CLEAR FRAME f_agencia NO-PAUSE.
               
               ASSIGN tel_cdageban = 0              
                      tel_dgagenci = ""             
                      tel_nmageban = ""             
                      tel_cdsitagb = "N"             
                      tel_cdcompen = 0              
                      tel_nmcidade = ""             
                      tel_cdufresd = "".            
                                                    
               UPDATE tel_cdageban                  
                      WITH FRAME f_agencia.

               EMPTY TEMP-TABLE tt-erro.
               EMPTY TEMP-TABLE tt-agencia.  
               EMPTY TEMP-TABLE tt-feriados.

               MESSAGE "Consultando agencia. Aguarde...".
   
               RUN busca-agencia IN h-b1wgen0149(INPUT glb_cdcooper,
                                                 INPUT glb_cdagenci,
                                                 INPUT 0, /*nrdcaixa*/
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_cddepart,
                                                 INPUT glb_nmdatela,
                                                 INPUT 1, /*ayllos*/
                                                 INPUT tel_cdageban,
                                                 INPUT tel_cddbanco,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT glb_cddopcao,
                                                 INPUT 99999, /*nrregist*/
                                                 INPUT 0, /*nriniseq*/
                                                 OUTPUT aux_nmdcampo,
                                                 OUTPUT aux_qtregist,
                                                 OUTPUT TABLE tt-agencia,
                                                 OUTPUT TABLE tt-feriados,
                                                 OUTPUT TABLE tt-erro).

               HIDE MESSAGE NO-PAUSE.

               IF RETURN-VALUE <> "OK" THEN
                  DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
                     IF AVAIL tt-erro THEN
                        MESSAGE tt-erro.dscritic.
                     ELSE
                       MESSAGE "Nao foi possivel realizar a consulta".
               
                     PAUSE(2)NO-MESSAGE.
                     HIDE MESSAGE.
                     NEXT.
                 
                  END.
               
               IF tel_cddbanco <> 0  AND
                  tel_cdageban = 0   THEN
                  DO:
                     IF TEMP-TABLE tt-agencia:HAS-RECORDS THEN
                        DO: 
                           OPEN QUERY q_agencia FOR EACH tt-agencia NO-LOCK.
                         
                           ENABLE b-agencia WITH FRAME f_lista_agencia.
                         
                           PAUSE 0.
                         
                           WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                           
                           IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                              DO: 
                                 HIDE FRAME f_lista_agencia.
                                 CLOSE QUERY q_agencia.
                                 NEXT.
                              
                              END.
                         
                           HIDE FRAME f_lista_agencia.
                           CLOSE QUERY q_agencia.
                           HIDE MESSAGE NO-PAUSE.
                  
                        END. /** Fim da leitura tt-agencia **/
               
                  END.

               DISP tel_cdageban
                    tel_dgagenci
                    tel_nmageban
                    tel_cdsitagb
                    tel_cdcompen
                    tel_nmcidade
                    tel_cdufresd
                    WITH FRAME f_agencia.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
                  UPDATE tel_dgagenci 
                         tel_nmageban 
                         tel_cdsitagb 
                         WITH FRAME f_agencia.     
   
                  LEAVE.
   
               END.
   
               IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                  NEXT. 

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  ASSIGN aux_confirma = "N"
                         glb_cdcritic = 78.
                  RUN fontes/critic.p.
                  ASSIGN glb_cdcritic = 0.
            
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  
                  LEAVE.
            
               END. /** Fim do DO WHILE TRUE **/
            
              IF KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                 aux_confirma <> "S"                 THEN
                 DO:
                     ASSIGN glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     ASSIGN glb_cdcritic = 0.
            
                     BELL.
                     MESSAGE glb_dscritic.
                     
                     NEXT.
                 END.
            
               MESSAGE "Realizando inclusao da agencia. Aguarde...".

               RUN nova-agencia IN h-b1wgen0149(INPUT glb_cdcooper,
                                                INPUT glb_cdagenci,
                                                INPUT 0, /* nrdcaixa */
                                                INPUT glb_cdoperad,
                                                INPUT glb_cddepart,
                                                INPUT glb_nmdatela,
                                                INPUT 1, /* AYLLOS */
                                                INPUT glb_cddopcao,
                                                INPUT tel_cdageban,
                                                INPUT tel_cddbanco,
                                                INPUT glb_dtmvtolt,
                                                INPUT tel_dgagenci,
                                                INPUT tel_nmageban,
                                                INPUT tel_cdsitagb,
                                                OUTPUT aux_nmdcampo,
                                                OUTPUT TABLE tt-erro).

               HIDE MESSAGE NO-PAUSE.
   
               IF RETURN-VALUE <> "OK" THEN
                  DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
                     IF AVAIL tt-erro THEN
                        MESSAGE tt-erro.dscritic.
                     ELSE
                       MESSAGE "Nao foi possivel realizar a consulta".
               
                     PAUSE(2)NO-MESSAGE.
                     HIDE MESSAGE.
                     NEXT.
                 
                  END.

               MESSAGE "Registro incluido com sucesso!".
               PAUSE(2)NO-MESSAGE.
               HIDE MESSAGE. 
               
               LEAVE.
   
            END. /** Fim do DO WHILE TRUE **/
   
            IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
               NEXT. 

         END.  /** Fim da  opcao "I" **/

      LEAVE.

   END. /* Fim do While true das opcoes */

   IF KEYFUNCTION(LAST-KEY)=  "END-ERROR" THEN
      NEXT.   

END. /** Fim do DO WHILE TRUE **/

IF VALID-HANDLE (h-b1wgen0149) THEN
   DELETE PROCEDURE h-b1wgen0149.

