/* .............................................................................

   Programa: Fontes/proces2.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Julho/2004                      Ultima atualizacao: 03/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a tela PROCES.
               Faz o cancelamento do processo.

   Alteracoes: 27/01/2005 - Incluir solicitacao 73 (Ze Eduardo).
   
               28/06/2005 - Tratar solicitacao 101 (Edson).
   
               10/10/2005 - Remover arquivo diretorio /micros/controle/corvu
                            (Mirtes)

               11/10/2005 - Remover arquivos controle CorVu(Mirtes)  

               11/01/2006 - Deletar solicitacao 102(Mirtes)

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               08/06/2006 - Alteracao no tratamento do crapper, dias fixos no
                            decendio, independente de ser dia util ou nao
                            (Julio)
                            
               14/11/2008 - Exclusao do registro de controle de DIMOF do ano 
                            anterior (Guilherme).                          
                              
               12/05/2009  - Tratar erro na leitura das contas de convenio 
                             no BB (Fernando).
                             
               23/09/2010 - Utilizar o nome do diretorio da cooperativa nos
                            arquivos ".ctr" (Evandro).
                
               11/06/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.) 
                            
               29/06/2012 - Ajuste no ver_ctace.p (Ze).
               
               02/08/2012 - Eliminada solicitacao 71-cartoes (Diego).
               
               18/10/2013 - Eliminar sol 32 (David).
               
               07/11/2013 - Eliminar sol 64 (David).
               
               03/01/2014 - Ajustar delecao da tabela crapmof (David).
               
............................................................................. */

{ includes/var_online.i }

{ includes/var_proces.i }

DEF    VAR aux_nmarqlog   AS CHAR    FORMAT "x(10)"            NO-UNDO.
DEF    VAR aux_lsconta    AS CHAR                              NO-UNDO.
DEF    VAR aux_lsctaret   AS CHAR                              NO-UNDO. 

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

DO TRANSACTION:

   DO WHILE TRUE:

      FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      IF   NOT AVAILABLE crapdat   THEN
           IF   LOCKED crapdat   THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                DO:
                    glb_cdcritic = 1.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic "--> SISTEMA CANCELADO!".
                    PAUSE MESSAGE
                         "Tecle <entra> para voltar `a tela de identificacao!".
                    BELL.
                    QUIT.
                END.
      ELSE
           LEAVE.
   END.

   IF   crapdat.inproces <> 2   THEN
        DO:
            glb_cdcritic = 141.
            RETURN.                     /* Apos o DO TRANSACTION */
        END.

   DO   WHILE TRUE ON ENDKEY UNDO, LEAVE.

        ASSIGN aux_confirma = "N"
               glb_cdcritic = 78.
        RUN fontes/critic.p.
        BELL.
        MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
        ASSIGN glb_cdcritic = 0.
        LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
        aux_confirma <> "S"   THEN
        DO:
            ASSIGN glb_cdcritic = 79.
            RETURN.                     /* Apos o DO TRANSACTION */
        END.

   /* Acessa a tabela com o numero das contas de convenio no BB */
   ASSIGN aux_lscontas = "".
   DO   aux_contador = 1 TO 3:

        RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                               INPUT aux_contador,
                              OUTPUT aux_lsctaret).

             ASSIGN aux_lscontas = aux_lscontas + aux_lsctaret + ",".
   END.  /*  Fim do DO .. TO  */

   /* Deleta solicitacoes de informes de rendimentos criadas automaticamente */ 
   FOR EACH crapext WHERE crapext.cdcooper = glb_cdcooper AND 
                          crapext.tpextrat = 6            AND 
                          crapext.inselext = 9 EXCLUSIVE-LOCK:
       DELETE crapext.
   END.
        
   FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND 
                          crapsol.dtrefere = glb_dtmvtolt  AND
                         (crapsol.nrsolici >= 82           AND                 
                          crapsol.nrsolici <= 93) EXCLUSIVE-LOCK:
       DELETE crapsol.
   END.
        
   FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                          crapsol.dtrefere = glb_dtmvtolt   AND
                         (crapsol.nrsolici = 1              OR
                          crapsol.nrsolici = 2              OR
                          crapsol.nrsolici = 3              OR
                          crapsol.nrsolici = 4              OR
                          crapsol.nrsolici = 5              OR
                          crapsol.nrsolici = 7              OR
                          crapsol.nrsolici = 15             OR
                          crapsol.nrsolici = 16             OR
                          crapsol.nrsolici = 17             OR
                          crapsol.nrsolici = 18             OR
                          crapsol.nrsolici = 26             OR
                          crapsol.nrsolici = 27             OR
                          crapsol.nrsolici = 28             OR
                          crapsol.nrsolici = 29             OR
                          crapsol.nrsolici = 30             OR
                          crapsol.nrsolici = 32             OR
                          crapsol.nrsolici = 34             OR
                          crapsol.nrsolici = 35             OR
                          crapsol.nrsolici = 36             OR
                          crapsol.nrsolici = 37             OR
                          crapsol.nrsolici = 39             OR
                          crapsol.nrsolici = 40             OR
                          crapsol.nrsolici = 41             OR
                          crapsol.nrsolici = 46             OR
                          crapsol.nrsolici = 52             OR
                          crapsol.nrsolici = 53             OR
                          crapsol.nrsolici = 55             OR
                          crapsol.nrsolici = 57             OR
                          crapsol.nrsolici = 58             OR
                          crapsol.nrsolici = 59             OR
                          crapsol.nrsolici = 61             OR
                          crapsol.nrsolici = 63             OR
                          crapsol.nrsolici = 64             OR
                          crapsol.nrsolici = 69             OR
                          crapsol.nrsolici = 73             OR
                          crapsol.nrsolici = 74             OR
                          crapsol.nrsolici = 76             OR
                          crapsol.nrsolici = 80             OR
                          crapsol.nrsolici = 81             OR
                          crapsol.nrsolici = 94             OR
                          crapsol.nrsolici = 101            OR
                          crapsol.nrsolici = 102            OR
                          crapsol.nrsolici = 103) EXCLUSIVE-LOCK:
       DELETE crapsol.
   END.

   IF   MONTH(glb_dtmvtolt) <> MONTH(crapdat.dtmvtopr)   THEN
        FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND 
                               crapsol.dtrefere = glb_dtmvtolt  AND
                              (crapsol.nrsolici = 09            OR
                               crapsol.nrsolici = 11            OR
                               crapsol.nrsolici = 20            OR
                               crapsol.nrsolici = 44            OR
                               crapsol.nrsolici = 96) EXCLUSIVE-LOCK:
            DELETE crapsol.
        END.

   FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper AND 
                          CAN-DO("23,33,43,65,67,68,70,72,75", 
                                        STRING(nrsolici)) AND 
                         (crapsol.nrseqsol > 999)
                          EXCLUSIVE-LOCK:
       DELETE crapsol.
   END.  /* Fim do FOR EACH crapsol */

   /* Ajuste do encerramento do periodo de apuracao - IPMF */
   FOR EACH crapper WHERE crapper.cdcooper = glb_cdcooper EXCLUSIVE-LOCK:

       IF   crapper.dtiniper >  glb_dtmvtolt   AND
            crapper.dtiniper <= glb_dtmvtopr   THEN
            DELETE crapper.
       ELSE
       IF   crapper.dtfimper >= glb_dtmvtolt   AND
            crapper.dtfimper <  glb_dtmvtopr   AND
            crapper.infimper = 1              THEN
            ASSIGN crapper.dtfimper = ?
                   crapper.dtdebito = ?.

   END.  /*  Fim do FOR EACH  --  crapper  */

   /* Excluir registro de controle da geracao da DIMOF */
   IF  YEAR(glb_dtmvtolt) <> YEAR(glb_dtmvtoan)  THEN
       DO: 
            FOR EACH crapmof WHERE crapmof.cdcooper  = glb_cdcooper AND
                                   crapmof.dtiniper >= DATE(01,01,YEAR(glb_dtmvtolt))
                                   EXCLUSIVE-LOCK:
                DELETE crapmof.
            END.
       END.

   ASSIGN crapdat.inproces = 1
          crapdat.inctrfit = 0
          crapdat.cdprgant = "".
 
   UNIX SILENT VALUE("mv arquivos/.proc_sol " +
                      "arquivos/.proc_sol.ant 2> /dev/null").

   /*---------------
   UNIX SILENT VALUE("mv arquivos/so_consulta " +
                     "arquivos/so_consulta.ant 2> /dev/null").
   ----------------*/

   UNIX SILENT VALUE("mv arquivos/prioridade " +
                     "arquivos/priori.ant 2> /dev/null").

   UNIX SILENT rm arquivos/.fimdig 2> /dev/null.

   UNIX SILENT rm proc/dataproc 2> /dev/null.

   DO   aux_qtdconta = 1 TO 99:

        aux_nrdctabb = INTEGER(ENTRY(aux_qtdconta,aux_lscontas)) NO-ERROR.
        
        IF   aux_nrdctabb = 0 OR ERROR-STATUS:ERROR  THEN
             LEAVE.

        UNIX SILENT VALUE("rm proc/" + STRING(aux_nrdctabb,"99999999") +
                          STRING(glb_dtmvtolt,"99999999") + " 2> /dev/null").

   END.

   /* CorVu */
   IF  glb_cdcooper <> 3 THEN
       DO:
          UNIX SILENT VALUE("rm /micros/controle/corvu/" +
               LC(crapcop.dsdircop) + 
               ".ctr"  + " 2> /dev/null").
          UNIX SILENT VALUE("rm /micros/controle/corvu/mensal.ok" + 
                 " 2> /dev/null").
       END.
   
   UNIX SILENT rm procbak/* 2> /dev/null.

   aux_nmarqlog = "salvar/log" + STRING(DAY(glb_dtmvtoan),"99") + 
                  STRING(MONTH(glb_dtmvtoan),"99") +
                  STRING(YEAR(glb_dtmvtoan),"9999") + ".log".
         
   UNIX SILENT VALUE 
       ("mv " + aux_nmarqlog + " log/proc_batch.log 2> /dev/null" ).
 
   MESSAGE "Processo cancelado!!".

END.  /* Fim da transacao */

/* .......................................................................... */

