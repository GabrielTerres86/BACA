/* ............................................................................

   Programa: fontes/crps328.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Junior
   Data    : Setembro/2002.                     Ultima atualizacao: 24/05/2004.

   Dados referentes ao programa:

   Frequencia:
   Objetivo  : Trata os parametros recebidos do MTCLIENT para chamar o programa
               crps329.p que gera o extrato para Internet.

   Alteracoes: 25/11/2002 - Colocado disconnect no banco e mensagem apos a
                            execucao do 329 (Deborah).

               26/09/2003 - Alterado para permitir testes no banco win13
                            para credito e central somente (Junior).
                            
               19/12/2003 - Inclusao de concredi e cecrisacred para testes no
                            banco win13 (Junior).
                            
               24/05/2004 - Mudar crapsin para crapint (Junior).
 .............................................................................*/

DEF         VAR aux_dsparam   AS CHAR        NO-UNDO.
DEF         VAR aux_nmbanco   AS CHAR        NO-UNDO.
DEF         VAR aux_nrdconta  AS INT         NO-UNDO.
DEF         VAR aux_cdsenweb  AS INT         NO-UNDO.
DEF         VAR aux_cdcooper  AS INT         NO-UNDO.
DEF         VAR aux_dssenweb  AS CHAR FORMAT "x(40)" NO-UNDO.
DEF         VAR aux_nmpathdb  AS CHAR        NO-UNDO.

FORM '<?xml version="1.0"?>' SKIP
     '<?xml-stylesheet type="text/xsl" href="viacredi.xsl"?>' SKIP
     '<CECRED>'
     WITH DOWN NO-BOX NO-LABELS WIDTH 80 FRAME f_inicio.

FORM "</CECRED>" 
     WITH DOWN NO-BOX NO-LABELS WIDTH 80 FRAME f_final.

aux_dsparam = SESSION:PARAMETER.

ASSIGN aux_cdcooper = INT(ENTRY(1, aux_dsparam ," "))
       aux_nrdconta = INT(ENTRY(2, aux_dsparam ," "))
       aux_cdsenweb = INT(ENTRY(3, aux_dsparam ," "))
       aux_dssenweb = ENTRY(2, aux_dsparam ,"%").

FIND FIRST crapint NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapint THEN
     DO:
         DISPLAY WITH FRAME f_inicio.
         DOWN WITH FRAME f_inicio.
         DISPLAY 
         "<dsmsgerr>SISTEMA NAO ESTA DISPONIVEL NO MOMENTO-CRAPINT</dsmsgerr>".
    
         DISPLAY WITH FRAME f_final.
         QUIT.
     END.
ELSE
     DO:
         DISPLAY WITH FRAME f_inicio.
         DOWN WITH FRAME f_inicio.

         DISPLAY "<dsmsgerr>" + 
         "ESTA PAGINA FOI ATUALIZADA. LIMPE OS ARQUIVOS TEMPORARIOS DE SEU " +
         "COMPUTADOR. EM CASO DE DUVIDA ENTRE EM CONTATO COM SUA COOPERATIVA."
         + "</dsmsgerr>" WITH WIDTH 200.

         DISPLAY WITH FRAME f_final.
         QUIT.
     END.


/********* SISTEMA ANTIGO DE CONSULTA - DESATIVADO EM 26/07/2004     
     DO:
         IF   indeacao <> 0 THEN
              DO:
                  DISPLAY WITH FRAME f_inicio.
                  DOWN WITH FRAME f_inicio.
                  DISPLAY "<dsmsgerr>" + 
                          SISTEMA NAO ESTA DISPONIVEL NO MOMENTO" + 
                          "</dsmsgerr>".
                  DISPLAY WITH FRAME f_final.
                  QUIT.
              END.
         ELSE
              DO:
                 aux_nmbanco = "arquivos/banco.lk".
                 aux_nmbanco = SEARCH(aux_nmbanco).

                 IF   aux_nmbanco = ?  THEN
                      DO:
                          DISPLAY WITH FRAME f_inicio.
                          DOWN WITH FRAME f_inicio.
                          DISPLAY "<dsmsgerr>" +
                                  "SISTEMA NAO ESTA DISPONIVEL NO MOMENTO" +
                                  "</dsmsgerr>".
                          DISPLAY WITH FRAME f_final.
                          QUIT.
                      END.
                 ELSE
                      DO:
                          IF   aux_dssenweb = "testetestetesteteste" THEN
                               DO:

                                   CASE aux_cdcooper:
                                   
                                        WHEN 1 THEN aux_nmpathdb = 
                                         "/win13/credito/antes/arquivos/banco".

                                        WHEN 3 THEN aux_nmpathdb =
                                         "/win13/central/antes/arquivos/banco".

                                        WHEN 4 THEN aux_nmpathdb = 
                                        "/win13/concredi/antes/arquivos/banco".

                                        WHEN 5 THEN aux_nmpathdb = 
                                     "/win13/cecrisacred/antes/arquivos/banco".

                                   END CASE.
                                   
                                   CONNECT VALUE(aux_nmpathdb) NO-ERROR.
                                  
                                   IF   ERROR-STATUS:ERROR   THEN
                                        DO:
                                            DISPLAY WITH FRAME f_inicio.
                                            DOWN WITH FRAME f_inicio.
                                            DISPLAY "<dsmsgerr>" +
                                            "NAO FOI POSSIVEL CONECTAR BD." +
                                            "</dsmsgerr>".
                                            DISPLAY WITH FRAME f_final.
                                            QUIT.
                                   END.
                          
                                   UNIX SILENT VALUE("echo " + STRING(TODAY) + 
                                        " " + STRING(TIME,"HH:MM:SS") +
                                        "' --> '" + "Requisitado: " +  
                                        STRING(aux_cdcooper) +
                                        "/" + STRING(aux_nrdconta) + 
                                        " >> log/internet.log").
                          
                                   RUN teste/fontes/crps329.p
                                      (aux_nrdconta,aux_cdsenweb,aux_dssenweb).

                                   UNIX SILENT VALUE("echo " + STRING(TODAY) + 
                                        " " + STRING(TIME,"HH:MM:SS") +
                                        "' --> '" + " Processado: " +  
                                        STRING(aux_cdcooper) + "/" +
                                        STRING(aux_nrdconta) + 
                                        " >> log/internet.log").

                                   DISCONNECT VALUE(aux_nmpathdb) NO-ERROR.
                               END.   
                          ELSE
                               DO:
                                   CONNECT arquivos/banco NO-ERROR.
                                  
                                   IF   ERROR-STATUS:ERROR   THEN
                                        DO:
                                            DISPLAY WITH FRAME f_inicio.
                                            DOWN WITH FRAME f_inicio.
                                            DISPLAY "<dsmsgerr>" +
                                            "NAO FOI POSSIVEL CONECTAR BD." +
                                            "</dsmsgerr>".
                                            DISPLAY WITH FRAME f_final.
                                            QUIT.
                                   END.
                          
                                   UNIX SILENT VALUE("echo " + STRING(TODAY) + 
                                        " " + STRING(TIME,"HH:MM:SS") +
                                        "' --> '" + "Requisitado: " +  
                                        STRING(aux_cdcooper) +
                                        "/" + STRING(aux_nrdconta) + 
                                        " >> log/internet.log").
                          
                                   RUN fontes/crps329.p
                                       (aux_nrdconta,aux_cdsenweb,aux_dssenweb).

                                   UNIX SILENT VALUE("echo " + STRING(TODAY) + 
                                        " " + STRING(TIME,"HH:MM:SS") +
                                        "' --> '" + " Processado: " +  
                                        STRING(aux_cdcooper) + "/" +
                                        STRING(aux_nrdconta) +  
                                        " >> log/internet.log").

                                   DISCONNECT arquivos/banco NO-ERROR.
                              END.
                      END.
              END.
     END.
     
 SISTEMA ANTIGO DE CONSULTA - DESATIVADO EM 26/07/2004 ***********/
     
/*........................................................................... */
