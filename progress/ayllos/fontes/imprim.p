/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/imprim.p                 | gene0002.pc_imprim                |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/



/* .............................................................................

   Programa: Fontes/imprim.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Novembro/91.                        Ultima atualizacao: 08/01/2014

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outro programa.
   Objetivo  : Executar o comando de impressao no UNIX.

   Alteracoes: 28/12/1999 - Tratar tabela de configuracao (Deborah).

               29/12/1999 - Alterado para testar se o arquivo a ser impresso
                            nao esta vazio (Edson).

               06/06/2002 - Colocar os relatorios em folha branca diretamente
                            para a impressora (Deborah).

               14/08/2002 - Mostrar o comando de impressao no crps187 (Deborah)
               
               21/08/2002 - Acerto na escolha do nome da impressora (Deborah).

               07/03/2003 - Passar a creditextil para fila cctextil (Deborah) 
               
               20/03/2003 - Tratar fila da Concredi (Deborah).   
               
               08/09/2003 - Foi adicionado a Data na geracao do log (Fernando).
               
               04/11/2003 - Tratar cecrisacred e credcred (Deborah).
               
               10/11/2003 - Aumentar o tamnaho da glb_nmimpres (Ze Eduardo).
               
               18/03/2004 - Acrescentar a Credifiesc (Ze Eduardo).
               
               25/03/2004 - Padronizar a programa (Ze Eduardo).
               
               26/05/2004 - Incluir formulario timbre e etiquetas para a fila
                            credito. (Ze Eduardo)

               21/07/2005 - Tratamento para geracao de PDF (Julio)

               02/08/2005 - Tratamento para relatorios gerenciais (PDF) (Julio)
               
               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               14/03/2006 - Envio dos relatorios em formato PDF para o
                            servidor Web, para visualizacao em Documentos
                            (Junior).

               16/05/2006 - Efetuar tratamento do campo craprel.inimprel
                            Efetuar impressao(Sim/Nao) (Mirtes)

               26/05/2006 - Inicializar a variavel aux_dsgerenc com "NAO"
                            (Edson).
                            
               30/08/2012 - Tratamento crapcop.nmrescop "x(20)" (Diego).             

               03/01/2014 - Retirado leitura da craptab "FILAIMPRES" (Tiago).
               
               08/01/2014 - Inicializar variavel glb_nmformul se nao estiver
                            parametrizada (David).
                            
............................................................................. */

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3.

{ includes/var_batch.i }

DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsgerenc AS CHAR    INIT "NAO"                    NO-UNDO.
DEF        VAR aux_nrtamarq AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_lsformul AS CHAR    INIT    
"80col,80dcol,132m,132dm,132col,endless,padrao,timbre,etqcorreio,timb132,234dh"
                                                                     NO-UNDO.
                                                                     
DEF        VAR aux_setlinha AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_cdrelato AS INT                                   NO-UNDO.
DEF        VAR aux_tprelato AS INT                                   NO-UNDO.
DEF        VAR aux_nmarqtmp AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR aux_nmarqpdf AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR aux_ingerpdf AS INTE                                  NO-UNDO.
DEF        VAR aux_nmrelato AS CHAR                                  NO-UNDO.
DEF        VAR aux_inimprel AS INTE                                  NO-UNDO.

INPUT STREAM str_1 THROUGH VALUE("wc -c " + glb_nmarqimp + 
                                 " 2> /dev/null") NO-ECHO.
 
DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

   SET STREAM str_1 aux_nrtamarq ^.
   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

IF   aux_nrtamarq = 0   THEN
     RETURN.

/*  Busca dados da cooperativa  */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

IF   INDEX(glb_nmarqimp,"*") > 0 THEN
     DO:
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           "Caracter invalido no nome do relatorio " +
                           glb_nmarqimp + ". VERIFIQUE!" + 
                           " >> log/proc_batch.log").
         RETURN.
     END.


/* Obter Dados para impressao e INTRANET */
/* Se nao utilizar o mtspool, desenvolver rotina especifica */

ASSIGN aux_dsgerenc = "NAO"
       aux_tprelato = 0 
       aux_ingerpdf = 0
       aux_nmrelato = " "  
       aux_inimprel = 0.

ASSIGN aux_cdrelato = INT(SUBSTRING(glb_nmarqimp, 
                          INDEX(glb_nmarqimp, "crrl") + 4, 3)) NO-ERROR.

IF   NOT ERROR-STATUS:ERROR   THEN
     DO:
      
         FIND craprel WHERE 
              craprel.cdcooper = glb_cdcooper AND
              craprel.cdrelato = aux_cdrelato NO-LOCK NO-ERROR.

         IF   AVAIL craprel   THEN
              DO:
                 ASSIGN aux_ingerpdf = craprel.ingerpdf
                        aux_nmrelato = craprel.nmrelato 
                        aux_inimprel = craprel.inimprel.
                 IF   craprel.tprelato = 2   THEN
                      ASSIGN aux_dsgerenc = "SIM"
                             aux_tprelato = 1.
              END.
      END.        

/*-----------------  GERAR ARQUIVO PARA INTRANET  ------------*/

INPUT STREAM str_2 THROUGH VALUE("ls " + glb_nmarqimp + 
                                 " 2> /dev/null") NO-ECHO.
     
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_2 aux_setlinha WITH WIDTH 60. 
        
   ASSIGN aux_setlinha = TRIM(aux_setlinha).

   IF   aux_ingerpdf = 1 THEN
        DO:
            ASSIGN glb_nmformul = IF glb_nmformul = "" 
                                  THEN "padrao" ELSE glb_nmformul.

            INPUT THROUGH VALUE("basename " + glb_nmarqimp) NO-ECHO.
                
            SET aux_nmarqtmp.
                
            INPUT CLOSE.
                
            INPUT THROUGH VALUE("echo " + aux_nmarqtmp + " | cut -d '.'" +
                                " -f 1") NO-ECHO.
            
            SET aux_nmarqpdf.
                
            INPUT CLOSE.
               
            ASSIGN aux_nmarqtmp = "tmppdf/" + aux_nmarqtmp + ".txt"
                   aux_nmarqpdf = aux_nmarqpdf + ".pdf".
        
            OUTPUT STREAM str_3 TO VALUE (aux_nmarqtmp).
        
            PUT STREAM str_3 crapcop.nmrescop  FORMAT "X(20)"   ";"
                            STRING(YEAR(glb_dtmvtolt),"9999") FORMAT "x(4)" ";"
                            STRING(MONTH(glb_dtmvtolt),"99")  FORMAT "x(2)" ";"
                            STRING(DAY(glb_dtmvtolt),"99")    FORMAT "x(2)" ";"
                            STRING(aux_tprelato,"z9")         FORMAT "x(2)" ";"
                            aux_nmarqpdf ";"
                            CAPS(aux_nmrelato)            FORMAT "x(50)" ";"
                            SKIP.
                         
            OUTPUT STREAM str_3 CLOSE.
             
            /* Cria o arquivo PDF */
                
            UNIX SILENT VALUE("echo script/CriaPDF.sh " +
                              aux_setlinha + " " + aux_dsgerenc + " " + 
                              glb_nmformul + " " +
                              STRING(YEAR(glb_dtmvtolt),"9999") +
                              "_" + STRING(MONTH(glb_dtmvtolt),"99") +
                              "/" + STRING(DAY(glb_dtmvtolt),"99") +
                              " >> log/CriaPDF.log").
             
            UNIX SILENT VALUE("script/CriaPDF.sh " +
                              aux_setlinha + " " + aux_dsgerenc + " " + 
                              glb_nmformul + " " +
                              STRING(YEAR(glb_dtmvtolt),"9999") +
                              "_" + STRING(MONTH(glb_dtmvtolt),"99") +
                              "/" + STRING(DAY(glb_dtmvtolt),"99")).                
        END.
END.

/* .......................................................................... */

