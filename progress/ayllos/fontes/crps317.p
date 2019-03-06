/*************************************************************************
    COMENTAR A INCLUDES envia_dados_postmix PARA NAO ENVIAR OS CONVITES 
    PARA A EMPRESA RESPONSAVEL PELA IMPRESSAO.
*************************************************************************/

/*..........................................................................

   Programa: Fontes/crps317.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Dezembro/2001                      Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Listar as cartas de inclusao no CCF.
               Solicitacao: 2
               Ordem: 40
               Relatorio: 269 
               Tipo Documento: 1
               Formulario: CCF-laser.

   Alteracoes:  14/01/2002 - Acrescentar a ordenacao do arquivo (Ze Eduardo).
   
                05/08/2002 - Incluir agencia na secao de extrato (Ze Eduardo).
                
                23/10/2003 - Alterado para mandar somente por CORREIO (Edson).
                
                27/04/2005 - Incluida nova linha com o nro do cadastro do
                             cooperado na empresa (Evandro).

                21/09/2005 - Modificado FIND FIRST para FIND na tabela         
                             crapcop.cdcooper = glb_cdcooper (Diego).
                             
                25/01/2006 - Modificada a data de inclusao para o 1o dia util
                             depois de 11 dias da devolucao (Evandro).
                             
                14/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
                
                19/06/2006 - Modificados campos referente endereco para a 
                             estrutura crapenc (Diego).

                08/11/2006 - Alteracao do formulario de FormExpress para
                             FormPrint (Julio)
                             
                17/04/2007 - Modificado nome do arquivo aux_nmarqdat (Diego).

                30/05/2007 - Chamada do programa 'fontes/gera_formprint.p'
                             para executar a geracao e impressao dos
                             formularios em background (Julio)
                             
                08/10/2007 - Incluido campo com nome do segundo titular no
                             formulario (Diego).                      
                             
                29/04/2008 - Envio de informativo pela PostMix (Diego).

                30/06/2008 - Chamar nova includes "envia_dados_postmix.i"
                             e criar nova variavel (Gabriel).

                14/08/2008 - Alterado para evitar erro no upload (Gabriel).
                
                22/10/2008 - Alterado periodo para inclusao no CCF de 11
                             para 9 dias (Diego).  
                             
                06/02/2009 - Movida definicao da variavel aux_nmdatspt para
                             includes/var_informativos.i (Diego).
                             
                30/09/2009 - Enviar arquivo para impressao na Engecopy das
                             cooperativas 1,2 e 4 (Diego).
                                                                                                                               
                20/04/2010 - Incluir o nome da faixa do CEP na cratext
                             (Gabriel).
                             
                01/06/2010 - Alteração do campo "pkzip25" para "zipcecred.pl" 
                            (Vitor).
                                                                              
                09/08/2010 - Geracao de relatorio listando cooperados inclusos
                             no CCF (Vitor).
                            
                14/06/2011 - Ajuste dos formatos  de cidade e bairro (Gabriel);
                             Incluido informacoes de numero de CEP e do 
                             centralizador do CDD no arquivo de dados (Elton). 
                             
                21/09/2011 - Alimentar campo cratext.cdagenci (Diego).
                
                10/06/2013 - Alteração função enviar_email_completo para
                             nova versão (Jean Michel).
                                            
                26/08/2016 - Realiza envio das cartas para a Engecopy de todas
                             as cooperativas (Elton - SD 494092 ).

				26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).
                             
                20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)
                                            
............................................................................. */

{ includes/var_batch.i "NEW" }

/* chamado oracle - 20/02/2019 - Chamado REQ0039739 */
{ sistema/generico/includes/var_oracle.i }

{ includes/var_informativos.i }

DEF    VAR aux_dsdlinha  AS CHAR   EXTENT 5 FORMAT "x(64)"  NO-UNDO.
DEF    VAR aux_cdsecext  AS INT                             NO-UNDO.
DEF    VAR aux_dtduteis  AS DATE                            NO-UNDO.
DEF    VAR aux_flgfxser  AS LOGICAL                         NO-UNDO.
DEF    VAR aux_nmarqeml  AS CHAR                            NO-UNDO.
DEF    VAR aux_conteudo  AS CHAR                            NO-UNDO.
DEF    VAR aux_flgexist  AS LOGICAL                         NO-UNDO.

DEF    VAR b1wgen0011    AS HANDLE                          NO-UNDO.

/* Variaveis cabecalho */                                           
DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"              NO-UNDO.
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"              NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5     NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                  NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5     NO-UNDO.
DEF VAR rel_nmmesref AS CHAR    FORMAT "x(014)"             NO-UNDO.

DEF    TEMP-TABLE cratneg FIELD nrdconta  AS  INT    FORMAT "zzzz,zz9,9"
                          FIELD cdobserv  AS  INT    FORMAT "zzz9"
                          FIELD vlestour  AS  DEC    FORMAT "zzz,zz9.99"
                          FIELD nrdocmto  AS  DEC    FORMAT "zzz,zz9,9"
                          FIELD nrdctabb  AS  DEC    FORMAT "zzzz,zz9,9"
                          FIELD cdagenci  AS  INT    FORMAT "zz9"
                          FIELD cdsecext  AS  INT    FORMAT "zzz"
                          INDEX cratneg1  cdagenci cdsecext nrdconta.

FORM cratneg.nrdconta COLUMN-LABEL "Conta"    FORMAT "zzzz,zzz,9"
     cratneg.nrdocmto COLUMN-LABEL "Cheque"   FORMAT "zz,zzz,zz9"
     cratneg.vlestour COLUMN-LABEL "Valor"    FORMAT "zzz,zzz,zzz,zz9.99"
     cratneg.cdobserv COLUMN-LABEL "Alinea"   FORMAT "zzz9"
     crapass.nmprimtl COLUMN-LABEL "Destinatario(s)"
                                              FORMAT "x(50)"
     aux_dtduteis     COLUMN-LABEL "Inclusao" FORMAT "99/99/9999"
     WITH DOWN COLUMN 1 WIDTH 132 NO-BOX FRAME f_dados.

DEF    STREAM str_1.  /* Para relatorio  */

ASSIGN glb_cdprogra = "crps317".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

ASSIGN aux_nrsequen = 0
       aux_nmarqimp = "rl/crrl269.lst"
       aux_nmarqdat = "arq/" + STRING(glb_cdcooper, "99") + "crrl269_" + 
                      STRING(DAY(glb_dtmvtolt), "99") + 
                      STRING(MONTH(glb_dtmvtolt), "99") + ".dat"
       aux_imlogoin = "laser/imagens/logo_" + TRIM(LC(crapcop.nmrescop)) + 
                      "_interno.pcx"
       aux_imlogoex = "laser/imagens/logo_" + TRIM(LC(crapcop.nmrescop)) + 
                      "_externo.pcx"       
       aux_cdacesso = ""      
       aux_dsdlinha = ""
       aux_flgfxser = FALSE.
         
ASSIGN aux_flgexist = FALSE.

FOR EACH crapneg WHERE crapneg.cdcooper = glb_cdcooper               AND
                       crapneg.dtiniest = glb_dtmvtolt               AND
                       crapneg.cdhisest = 1                          AND
                       CAN-DO("12,13", STRING(crapneg.cdobserv))     
                       USE-INDEX crapneg6 NO-LOCK:
                 
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                       crapass.nrdconta = crapneg.nrdconta NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapass THEN
         DO:
             glb_cdcritic = 410.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               glb_dscritic + " >> log/proc_batch.log").
             glb_cdcritic = 0.
             QUIT.
         END.
         
    CREATE cratneg.
    ASSIGN cratneg.nrdconta = crapneg.nrdconta
           cratneg.cdobserv = crapneg.cdobserv
           cratneg.vlestour = crapneg.vlestour
           cratneg.nrdocmto = crapneg.nrdocmto
           cratneg.nrdctabb = crapneg.nrdctabb
           cratneg.cdagenci = crapass.cdagenci
           cratneg.cdsecext = crapass.cdsecext.
           
    ASSIGN aux_flgexist = TRUE.

END.  /*  Fim  do  for each crapneg  */

IF   aux_flgexist = TRUE  THEN
     DO:
         OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 82.       

         { includes/cabrel132_1.i }
      
         VIEW STREAM str_1 FRAME f_cabrel132_1.
     END.
         
FOR EACH cratneg USE-INDEX cratneg1 NO-LOCK:
         
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                       crapass.nrdconta = cratneg.nrdconta NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapass THEN
         DO:
             glb_cdcritic = 410.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               glb_dscritic + " >> log/proc_batch.log").
             glb_cdcritic = 0.
             QUIT.
         END.
     
    IF   crapass.cdsecext = 0 THEN
         aux_cdsecext = 999.
    ELSE
         aux_cdsecext = crapass.cdsecext.

    ASSIGN aux_nrsequen = aux_nrsequen + 1.

    RUN p_diasuteis. /******* Para calcular os dias uteis ******/
                       
    IF   NOT aux_flgfxser THEN
         aux_flgfxser = TRUE.
    
    FIND crapenc WHERE crapenc.cdcooper = glb_cdcooper      AND
                       crapenc.nrdconta = crapass.nrdconta  AND
                       crapenc.idseqttl = 1                 AND
                       crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.

    FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper      AND
                       crapttl.nrdconta = crapass.nrdconta  AND
                       crapttl.idseqttl = 2 NO-LOCK NO-ERROR.
    
    /* Faixa do CEP */
    FIND crapcdd WHERE crapcdd.nrcepini <= crapenc.nrcepend AND
                       crapcdd.nrcepfim >= crapenc.nrcepend
                       NO-LOCK NO-ERROR.

    CREATE cratext.
    ASSIGN cratext.cdagenci    = crapass.cdagenci
           cratext.nrdconta    = crapass.nrdconta
           cratext.nmprimtl    = crapass.nmprimtl
           cratext.indespac    = 1 /* CORREIO */
           cratext.nrseqint    = aux_nrsequen
           cratext.dsender1    = IF crapenc.nrendere > 0 THEN
                                    TRIM(crapenc.dsendere) + ", " + 
                                    TRIM(STRING(crapenc.nrendere, "zzz,zz9"))
                                 ELSE
                                    TRIM(crapenc.dsendere)
           cratext.dsender2    = TRIM(STRING(crapenc.nmbairro,"x(15)")) + "   " +
                                 TRIM(STRING(crapenc.nmcidade,"x(15)")) + " - " +
                                 TRIM(crapenc.cdufende)
           cratext.nrcepend    = crapenc.nrcepend 

           cratext.nomedcdd    = crapcdd.nomedcdd WHEN AVAIL crapcdd
           cratext.nrcepcdd  = (STRING(crapcdd.nrcepini,"99,999,999") + " - " +
                   STRING(crapcdd.nrcepfim,"99,999,999")) WHEN AVAIL crapcdd
           cratext.dscentra    = crapcdd.dscentra WHEN AVAIL crapcdd
           
           cratext.complend    = STRING(crapenc.complend,"x(35)")
           cratext.nrdordem    = 1
           cratext.tpdocmto    = 1
           cratext.dtemissa    = glb_dtmvtoan
           cratext.dsintern[1] = STRING(cratext.nmprimtl, "x(43)") +
                                 STRING(cratext.nrdconta, "zzzz,zzz,9")
           cratext.dsintern[2] = IF   AVAIL crapttl THEN
                                      STRING(crapttl.nmextttl, "x(53)")
                                 ELSE FILL("",53)
           cratext.dsintern[3] = STRING(aux_dtduteis, "99/99/9999")
           cratext.dsintern[4] = STRING(cratneg.nrdocmto,"zzz,zz9,9")
           cratext.dsintern[5] = STRING(cratneg.vlestour,"zzz,zz9.99")
           cratext.dsintern[6] = STRING(glb_dtmvtoan, "99/99/9999")
           cratext.dsintern[7] = "#".
           
    DISP STREAM str_1
                cratneg.nrdconta
                cratneg.nrdocmto
                cratneg.vlestour
                cratneg.cdobserv
                crapass.nmprimtl
                aux_dtduteis     WITH FRAME f_dados.

    DOWN STREAM str_1 WITH FRAME f_dados.

    IF AVAIL crapttl  THEN
        DISP STREAM str_1
                    "" @  cratneg.nrdconta
                    "" @ cratneg.nrdocmto
                    "" @ cratneg.vlestour
                    "" @ cratneg.cdobserv
                    crapttl.nmextttl @ crapass.nmprimtl
                     "" @ aux_dtduteis     WITH FRAME f_dados.
      
    DOWN STREAM str_1 WITH FRAME f_dados.
             
END.     /*   Fim do For Each cratneg  */

/* Imprime Formulario */

{ includes/gera_dados_inform.i }

IF   aux_flgfxser THEN
     DO:                    
         UNIX SILENT VALUE("mv " + aux_nmarqdat + " salvar/" +
                           SUBSTRING(aux_nmarqdat, 5)).
                       
         ASSIGN aux_nmarqdat = "salvar/" + SUBSTRING(aux_nmarqdat, 5)
                 aux_nmdatspt = aux_nmarqdat
                 aux_nmarqeml = SUBSTR(aux_nmdatspt,
                                               R-INDEX(aux_nmdatspt,"/") + 1,
                                               LENGTH(aux_nmdatspt)).
                                               
                  RUN sistema/generico/procedures/b1wgen0011.p 
                      PERSISTENT SET b1wgen0011.

                  IF   NOT VALID-HANDLE (b1wgen0011)  THEN
                       DO:
                           UNIX SILENT VALUE("echo "
                                      + STRING(TIME,"HH:MM:SS") + " - "
                                      + glb_cdprogra + "' --> '" 
                                      + "Handle invalido para h-b1wgen0011."
                                      + " >> log/proc_batch.log").
                                      
                           RUN fontes/fimprg.p.           
                           QUIT.          
                       END.
                  
                  RUN converte_arquivo IN b1wgen0011 (INPUT glb_cdcooper,
                                                      INPUT aux_nmdatspt,
                                                      INPUT aux_nmarqeml).
            
                  ASSIGN aux_nmarqeml = SUBSTR(TRIM(aux_nmarqeml),1,
                                               R-INDEX(aux_nmarqeml,".") - 1).
            
                  UNIX SILENT VALUE("zipcecred.pl -silent -add converte/" + 
                                    aux_nmarqeml + ".zip" +
                                    " converte/" + aux_nmarqeml + ".dat").
                                      
                  ASSIGN aux_conteudo = "Em anexo o arquivo(" +
                                        aux_nmarqeml + ".zip) contendo as " +
                                        "cartas da " + crapcop.nmrescop +
                                        ".".
                               
                  RUN enviar_email_completo IN b1wgen0011
                                  (INPUT glb_cdcooper,
                                   INPUT "crps317",
                                   INPUT "cpd@ailos.coop.br",
                                   INPUT "vendas@blucopy.com.br," +
                                         "variaveis@blucopy.com.br",
                                   INPUT "Cartas " + crapcop.nmrescop ,
                                   INPUT "",
                                   INPUT aux_nmarqeml + ".zip",
                                   INPUT aux_conteudo,
                                   INPUT TRUE). 

                  DELETE PROCEDURE b1wgen0011.            
                    
              END.

ASSIGN glb_nmarqimp = "rl/crrl269.lst"
       glb_nrcopias = 1
       glb_nmformul = "132col".
                  
RUN fontes/imprim.p.

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS317.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 912,
    input "912 - FINALIZADO LEGAL",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS317.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 0,
    input "",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }   

RUN fontes/fimprg.p.

/******* Rotina para calcular os proximos 9 dias uteis ******/

PROCEDURE p_diasuteis:

    DEF VAR aux_contador  AS INTEGER   NO-UNDO.

    /* Data de inclusao eh o 1o. dia util depois de 9 dias do estouro */
    ASSIGN aux_dtduteis = glb_dtmvtolt + 9
           aux_contador = 0.
       
    DO WHILE TRUE:

       /* Se nao for feriado nem fim de semana eh +1 dia util */
       IF   NOT(CAN-DO("1,7",STRING(WEEKDAY(aux_dtduteis)))               OR
                CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper AND
                                       crapfer.dtferiad = aux_dtduteis))  THEN
                aux_contador = aux_contador + 1.
            
       IF   aux_contador < 1   THEN
            aux_dtduteis = aux_dtduteis + 1.
       ELSE
            LEAVE.
    END.

END PROCEDURE.

/* .......................................................................... */
