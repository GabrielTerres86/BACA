/******************************************************************************
                                   ATENCAO !                                   
             ESTE ARQUIVO APRESENTA ERRO QUANDO UTILIZAR CHECK SYNTAX
   DEVIDO A UM PROBLEMA DO ROUND TABLE QUANDO TENTA COMPILAR UM COMANDO UNIX
   
          O FONTE COMPILA SEM ERROS, O UNICO PROBLEMA EH O CHECK SYNTAX
           QUE ALEM DE ACUSAR O ERRO, IMPEDE QUE A TASK SEJA CONCLUIDA
                     OU O FONTE REMOVIDO DA TASK POR CHECK-IN
    
    PARA CONCLUIR A TASK DEVE-SE COMENTAR O TRECHO DE CODIGO IDENTIFICADO POR
           "INICIO - COMENTAR" ATE "FIM - COMENTAR", ENTAO CONCLUIR A TASK
   E POR FIM ABRIR O FONTE PELO AYLLOS CARACTER E DESCOMENTAR O TRECHO INDICADO
    
******************************************************************************/

/* .............................................................................

   Programa: Fontes/proces1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Julho/2004.                     Ultima atualizacao: 19/11/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para criar a solicitacao da tela PROCES

   Alteracao : 18/11/2004 - Criar solicitacao 97 (Empestimo Consignado)
   
               02/12/2004 - Nao imprimir os lotes dos cashes dispensers
                            (Edson).
                            
               05/01/2005 - Alterada a sol071 para rodar duas vezes por semana
                            (Julio).
                            
               27/01/2005 - Incluir solicitacao 73 (Ze Eduardo).

               16/02/2005 - Criacao de uma solicitacao QUINZENAL (Edson).
               
               09/05/2005 - Mudado parametro na criacao da solicitacao 44;
                            Alimentado o campo cdcooper das tabelas (Evandro).

               13/05/2005 - Alteracao da solicitacao 89, ao inves de rodar 
                            no ultimo dia util da primeira quinzena ira rodar
                            no primeiro dia util da segunda quinzena (Julio)

               01/06/2005 - Remover o arquivo de controle de execucao do
                            noturno do gener (Edson).

               28/06/2005 - Criar solicitacao QUINZENAL e MENSAL de 
                            relatorios (Edson).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               04/10/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapact (Diego).

              10/10/2005 - Criar   arquivo diretorio /micros/controle/corvu
                            (Mirtes)
                            
              01/11/2005 - Somente criar solicitacao 97 se a data de fechamento
                           da folha para a empresa for diferente de zero(Julio)
                           
              08/11/2005 - Controle CTRMVESCEN passou para o crps000 (Magui).
              
              08/12/2005 - Criar solicitacao 102 de 10 em 10 dias (Evandro).     
              24/01/2006 - Criar solicitacao 103 - Anual 
                           (1.o. dia util de fevereiro) (Julio)

              31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
              
              07/02/2006 - Ler a "crapsnh" na criacao da sol. 75 (Evandro).
              
              30/06/2006 - Remover os controles de execucao dos scripts dos
                           processos - Proc*.Ok (Edson).

              12/04/2006 - Remover arquivo de controle ArquivosBB.OK (Edson).

              19/04/2006 - Quando feriado na sexta na gerava sol 58 (Magui).

              11/05/2006 - Gravar arquivo horalimite.par(Mirtes)

              08/06/2006 - Alteracao na definicao das datas de inicio e fim do
                           crapper. Sera sempre de 1 a 10, 11 a 20, 
                           21 ao ultimo dia do mes. Independente de ser dia
                           util ou nao (Julio)

              31/10/2006 - Nao remover arquivo de controle ArquivosBB.OK 
                           (sera feito pelo crps000.p) - (Edson).
                           
              03/01/2007 - Alterada solicitacao 103 para ser gerada no inicio
                           da segunda quinzena de janeiro (Julio).

              08/01/2008 - Gerar sol 35 para Darf IOF (Magui).
              
              01/09/2008 - Alteracao CDEMPRES (Kbase).

              06/10/2008 - Criar sol 64 - Semanal rel.227/516(Mirtes).
               
              14/11/2008 - Criacao crapmof para controle de DIMOF (Guilherme).
              
              22/04/2009 - Criar sol. 64 quando feriado na sexta-feira para 
                           todas as cooperativas (Fernando).
                           
              02/10/2009 - Aumento do numero do lote: 3200 (Diego).
              
              26/01/2009 - Acerto na criacao da sol. 75 (Diego).
              
              20/05/2010 - Cria sol. 64 quando for terceiro dia util antes do 
                           fim do mes (Elton).
                           
              25/05/2010 - Eliminar a criacao do arquivo horalimite.par (Ze).
              
              16/06/2010 - Acrescentar eliminacao do arquivo ROC650 (Ze).
              
              23/09/2010 - Utilizar o nome do diretorio da cooperativa nos
                           arquivos ".ctr" (Evandro).

              24/10/2011 - Criar o arquivo procfer para a Cecred (Ze).
              
              13/02/2012 - Incluir as empresas 9 e 12 para gerar os arquivos
                           de cotas e emprestimos na Cecrisacred (Ze).
                           
              21/05/2012 - substituiçao do FIND craptab para os registros 
                           CONTACONVE pela chamada do fontes ver_ctace.p
                           (Lucas R.)
                           
              02/08/2012 - Eliminada solicitacao 71-cartoes (Diego).
                           
              22/04/2013 - Ajuste da sol. 040 para rodar para crps639 todos os
                           dias (Lucas R.)             
                           
              15/10/2013 - Criar solicitacao 32 (David).
              
              07/11/2013 - Ajustar a criacao da solicitacao 64 (David).
              
              18/06/2014 - Exclusao da solicitacao 29.
                           (Tiago Castro - Tiago RKAM)
                
              26/05/2014 - Nao utilizar mais a tabela CRAPVAR (desativacao da VAR). 
                           (Andrino-RKAM)
                           
              10/11/2014 -  Salvar os Logs de Email/Geração de Relatórios e Jobs
                            Chamado 219726 (André Santos - SUPERO)
                          
              04/03/2015 - Retirado a logica de criacao da solicitacao 97, e colocado
                           dentro do crps415.p (James)
              
              21/05/2015 - Foi adicionado no final dos processos a remocao dos arquivos
                           de logs, das pastas "/usr/coop/[cooperativa]/log/cash",
                           "/usr/coop/[cooperativa]/compbb/salva" e 
                           "/usr/coop/cecred/log/cash/TAA". SD 283892 (Kelvin)

              07/12/2015 - Tratar o arquivo proc_message da mesma forma do 
                           proc_batch, com excecao da postagem na Intranet 
                           (Douglas - Chamado 314652)

			  01/07/2016 - Ajuste para que, ao efetuar os comandos de limpeza de log,
						   se houver algum erro, este, deve ser jogado para o dev/null.
						   (Adriano - SD 469376).

			  13/04/2017 - Validacao do arquivo de log na pasta destino evitando assim a 
						   perda de informacoes com a solicitacao manual do processo. 
						   (Carlos Rafael Tanholi - SD 650409)

			  19/11/2017 - Alterado a geracao da solicitacao 52 para diaria (Jonata - RKAM P364).

............................................................................ */

DEF    VAR aux_dtref072   AS DATE                              NO-UNDO.
DEF    VAR aux_flgvalor   AS LOGICAL                           NO-UNDO.
DEF    VAR aux_nmlogbat   AS CHAR    FORMAT "x(30)"            NO-UNDO.
DEF    VAR aux_nmlogmes   AS CHAR    FORMAT "x(30)"            NO-UNDO.
DEF    VAR aux_nmlogrel   AS CHAR    FORMAT "x(30)"            NO-UNDO.
DEF    VAR aux_nmlogeml   AS CHAR    FORMAT "x(30)"            NO-UNDO.
DEF    VAR aux_nmlogjob   AS CHAR    FORMAT "x(30)"            NO-UNDO.

DEF    VAR aux_qtdiautl   AS INTE                              NO-UNDO.
DEF    VAR aux_dtinimes   AS DATE                              NO-UNDO.
DEF    VAR aux_dtcalcul   AS DATE                              NO-UNDO.
DEF    VAR aux_dtcalcu2   AS DATE                              NO-UNDO.
DEF    VAR aux_ultdiame   AS DATE                              NO-UNDO.
DEF    VAR aux_pridiame   AS DATE                              NO-UNDO.

DEF    VAR aux_contdata   AS INTE                              NO-UNDO.

DEF STREAM str_1.  /*  Arquivo controle  - hora limite               */
      
{ includes/var_online.i }
     
{ includes/var_proces.i }

DEF BUFFER crabper FOR crapper.

DEF VAR aux_lshstden AS CHAR                                         NO-UNDO.
DEF VAR aux_lsctaret AS CHAR                                         NO-UNDO.
     
DO WHILE TRUE:

   /* Acessa a tabela com o numero das contas de convenio no BB */

   aux_lscontas = "".

   DO aux_contador = 1 TO 3:

       RUN fontes/ver_ctace.p
          (INPUT glb_cdcooper,
           INPUT aux_contador,
          OUTPUT aux_lsctaret).

           aux_lscontas = aux_lscontas + aux_lsctaret + ",".   

   END.  /*  Fim do DO .. TO  */

   FIND craptab NO-LOCK WHERE 
        craptab.cdcooper = glb_cdcooper   AND
        craptab.nmsistem = "CRED"         AND
        craptab.tptabela = "USUARI"       AND
        craptab.cdempres = 11             AND
        craptab.cdacesso = "HORLIMPROC"  NO-ERROR.
   IF  NOT AVAIL craptab THEN 
       DO:
           glb_cdcritic = 55. 
           RETURN.
       END.

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
                 RETURN.
             END.
   ELSE
        LEAVE.

END.  /*  Fim do DO WHILE TRUE  */
     
/*  Edson - 28/12/2005  */

IF   glb_dtmvtolt = 12/29/2005   THEN
     DO WHILE TRUE:

        FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper AND
                           crapfer.dtferiad = 12/30/2005        
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                            
        IF   NOT AVAILABLE crapfer   THEN
             IF   LOCKED crapfer   THEN
                  DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  LEAVE.
                  
        DELETE crapfer.
        LEAVE.
        
     END.  /*  Fim do DO WHILE TRUE  */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
     
FOR EACH crapsol WHERE crapsol.cdcooper  = glb_cdcooper AND
                     ( crapsol.insitsol  =  2           OR
                       crapsol.nrsolici  = 79           OR
                      (crapsol.nrsolici <=  5)          OR
                      (crapsol.nrsolici  =  7)          OR
                      (crapsol.nrsolici >= 15           AND
                       crapsol.nrsolici <= 18)          OR
                       crapsol.nrsolici  = 28           OR
                      (crapsol.nrsolici >= 34           AND
                       crapsol.nrsolici <= 37)          OR
                      (crapsol.nrsolici >= 39           AND
                       crapsol.nrsolici <= 41)          OR
                       crapsol.nrsolici  = 46           OR
                       crapsol.nrsolici  = 52           OR
                       crapsol.nrsolici  = 53           OR
                       crapsol.nrsolici  = 55           OR
                      (crapsol.nrsolici >= 57           AND
                       crapsol.nrsolici <= 59)          OR
                       crapsol.nrsolici  = 61           OR
                       crapsol.nrsolici  = 64           OR  
                       crapsol.nrsolici  = 67           OR
                       crapsol.nrsolici  = 68           OR
                       crapsol.nrsolici  = 70           OR
                       crapsol.nrsolici  = 72           OR
                       crapsol.nrsolici  = 73           OR
                       crapsol.nrsolici  = 74           OR
                       crapsol.nrsolici  = 76           OR
                       crapsol.nrsolici  = 97           OR
                      (crapsol.nrsolici >= 80           AND
                       crapsol.nrsolici <= 93) )                               
                       EXCLUSIVE-LOCK ON ERROR UNDO, RETRY:

    DELETE crapsol. /*  Elimina as solicitacoes atendidas  */
                    /*  durante o dia e as geradas autom.  */

END.

CREATE crapsol.
ASSIGN crapsol.nrsolici = 001
       crapsol.dtrefere = glb_dtmvtolt
       crapsol.nrseqsol = 01
       crapsol.cdempres = 11
       crapsol.dsparame = " "
       crapsol.insitsol = 1
       crapsol.nrdevias = 1
       crapsol.cdcooper = glb_cdcooper.

CREATE crapsol.
ASSIGN crapsol.nrsolici = 002
       crapsol.dtrefere = glb_dtmvtolt
       crapsol.nrseqsol = 01
       crapsol.cdempres = 11
       crapsol.dsparame = " "
       crapsol.insitsol = 1
       crapsol.nrdevias = 1
       crapsol.cdcooper = glb_cdcooper.

CREATE crapsol.
ASSIGN crapsol.nrsolici = 005
       crapsol.dtrefere = glb_dtmvtolt
       crapsol.nrseqsol = 01
       crapsol.cdempres = 11
       crapsol.dsparame = " "
       crapsol.insitsol = 1
       crapsol.nrdevias = 1
       crapsol.cdcooper = glb_cdcooper.

CREATE crapsol.
ASSIGN crapsol.nrsolici = 032
       crapsol.dtrefere = glb_dtmvtolt
       crapsol.nrseqsol = 01
       crapsol.cdempres = 11
       crapsol.dsparame = " "
       crapsol.insitsol = 1
       crapsol.nrdevias = 1
       crapsol.cdcooper = glb_cdcooper.

/* Cria sol. de baixa de valores */
CREATE crapsol.
ASSIGN crapsol.nrsolici = 052
        crapsol.dtrefere = glb_dtmvtolt
        crapsol.nrseqsol = 01
        crapsol.cdempres = 11
        crapsol.dsparame = ""
        crapsol.insitsol = 1
        crapsol.nrdevias = 1
        crapsol.cdcooper = glb_cdcooper.

CREATE crapsol.
ASSIGN crapsol.nrsolici = 061
       crapsol.dtrefere = glb_dtmvtolt
       crapsol.nrseqsol = 01
       crapsol.cdempres = 11
       crapsol.dsparame = " "
       crapsol.insitsol = 1
       crapsol.nrdevias = 1
       crapsol.cdcooper = glb_cdcooper.

CREATE crapsol.
ASSIGN crapsol.nrsolici = 064
       crapsol.dtrefere = glb_dtmvtolt
       crapsol.nrseqsol = 01
       crapsol.cdempres = 11
       crapsol.dsparame = ""
       crapsol.insitsol = 1
       crapsol.nrdevias = 1
       crapsol.cdcooper = glb_cdcooper.

CREATE crapsol.
ASSIGN crapsol.nrsolici = 076
       crapsol.dtrefere = glb_dtmvtolt
       crapsol.nrseqsol = 01
       crapsol.cdempres = 11
       crapsol.dsparame = " "
       crapsol.insitsol = 1
       crapsol.nrdevias = 1
       crapsol.cdcooper = glb_cdcooper.

CREATE crapsol.
ASSIGN crapsol.nrsolici = 097
       crapsol.dtrefere = glb_dtmvtolt
       crapsol.nrseqsol = 01
       crapsol.cdempres = 11
       crapsol.dsparame = " "
       crapsol.insitsol = 1
       crapsol.nrdevias = 1
       crapsol.cdcooper = glb_cdcooper.

IF  crapcop.cdcooper <> 99 THEN 
    DO:
        CREATE crapsol.
        ASSIGN crapsol.nrsolici = 084
               crapsol.dtrefere = glb_dtmvtolt
               crapsol.nrseqsol = 01
               crapsol.cdempres = 11
               crapsol.dsparame = " "
               crapsol.insitsol = 1
               crapsol.nrdevias = 1
               crapsol.cdcooper = glb_cdcooper.
       
        /* - Solicitacao dois novos programas - 362/363 - */
        CREATE crapsol.
        ASSIGN crapsol.nrsolici = 088 
               crapsol.dtrefere = glb_dtmvtolt
               crapsol.nrseqsol = 01
               crapsol.cdempres = 11
               crapsol.dsparame = ""
               crapsol.insitsol = 1
               crapsol.nrdevias = 1
               crapsol.cdcooper = glb_cdcooper.

        /* Cria Solicitacao processo Batch(Noite)-Exceto para cooperativa 3 */
        CREATE crapsol.
        ASSIGN crapsol.nrsolici = 082
               crapsol.dtrefere = glb_dtmvtolt
               crapsol.nrseqsol = 01
               crapsol.cdempres = 11
               crapsol.dsparame = " "
               crapsol.insitsol = 1
               crapsol.nrdevias = 1
               crapsol.cdcooper = glb_cdcooper.

        CREATE crapsol.
        ASSIGN crapsol.nrsolici = 086
               crapsol.dtrefere = glb_dtmvtolt
               crapsol.nrseqsol = 01
               crapsol.cdempres = 11
               crapsol.dsparame = " "
               crapsol.insitsol = 1
               crapsol.nrdevias = 1
               crapsol.cdcooper = glb_cdcooper.

        CREATE crapsol.
        ASSIGN crapsol.nrsolici = 092
               crapsol.dtrefere = glb_dtmvtolt
               crapsol.nrseqsol = 01
               crapsol.cdempres = 11
               crapsol.dsparame = " "
               crapsol.insitsol = 1
               crapsol.nrdevias = 1
               crapsol.cdcooper = glb_cdcooper.
END.


ASSIGN aux_flgencer = FALSE.

/* Solicitacao do decendio (10 em 10 dias) - MAGUI IOF */

      /* primeiro decendio */
IF   (DAY(glb_dtmvtolt) <= 10   AND   DAY(glb_dtmvtopr) > 10)  OR

      /* segundo decendio */
     (DAY(glb_dtmvtolt) <= 20   AND   DAY(glb_dtmvtopr) > 20)  OR
                 
      /* ultimo dia do mes - terceiro decendio */
     (MONTH(glb_dtmvtopr) <> MONTH(glb_dtmvtolt))              THEN
      DO:
          ASSIGN aux_flgencer = TRUE
                 aux_flsoliof = TRUE.
          CREATE crapsol.
          ASSIGN crapsol.nrsolici = 102
                 crapsol.dtrefere = glb_dtmvtolt
                 crapsol.nrseqsol = 01
                 crapsol.cdempres = 11
                 crapsol.dsparame = " "
                 crapsol.insitsol = 1
                 crapsol.nrdevias = 1
                 crapsol.cdcooper = glb_cdcooper.
      END.
                                  
/* Solicitacao da PRIMEIRA QUINZENA ......................................... */

IF   DAY(glb_dtmvtopr) > 15 AND DAY(glb_dtmvtolt) <= 15   THEN
     DO:
         /* Cria solicitacao 74 quando no trimestre para Receita federal */

         IF   CAN-DO("01,04,07,10",STRING(MONTH(glb_dtmvtolt),"99")) THEN
              DO:
                  CREATE crapsol.
                  ASSIGN crapsol.nrsolici = 074
                         crapsol.dtrefere = glb_dtmvtolt
                         crapsol.nrseqsol = 01
                         crapsol.cdempres = 11
                         crapsol.dsparame = " "
                         crapsol.insitsol = 1
                         crapsol.nrdevias = 1
                         crapsol.cdcooper = glb_cdcooper.
              END.

         /* Solicitacao anual, inicio da segunda quinzena de janeiro */
         IF   MONTH(glb_dtmvtolt) = 1   THEN
              DO:
                  CREATE crapsol.
                  ASSIGN crapsol.nrsolici = 103
                         crapsol.dtrefere = glb_dtmvtolt
                         crapsol.nrseqsol = 01
                         crapsol.cdempres = 11
                         crapsol.dsparame = ""
                         crapsol.insitsol = 1
                         crapsol.nrdevias = 1
                         crapsol.cdcooper = glb_cdcooper.
              END.  
     
     END.

/* Solicitacao QUINZENAL / MENSAL (Relatorios) .............................. */

IF  (DAY(glb_dtmvtopr) > 15 AND DAY(glb_dtmvtolt) <= 15)   OR   
     MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr)            THEN
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 101
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = " "
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     END.

/*** Solicitacao MENSAL -> primeiro dia util da segunda quinzena do mes ***/
IF   DAY(glb_dtmvtopr) > 16 AND DAY(glb_dtmvtolt) <= 16 AND     
     crapcop.cdcooper <> 99 THEN                       /*  Exceto CECRED  */
     DO:
         CREATE crapsol.                    /* Cadeira PARALELA */
         ASSIGN crapsol.nrsolici = 089
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     END.    
     
FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper       AND 
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "EXTRAT"           AND
                       craptab.cdempres = 00                 AND
                       craptab.cdacesso = "EXTRDIARIO"       NO-LOCK:

    IF   INT(craptab.dstextab) = 0   THEN
         NEXT.
         
    /*  Gera diariamente solicitacao de emissao de extrao diario  */
    FIND FIRST crapext WHERE crapext.cdcooper = glb_cdcooper          AND 
                             crapext.cdagenci = 1                     AND
                             crapext.nrdconta = INT(craptab.dstextab) AND
                             crapext.dtrefere = glb_dtmvtolt          AND
                             crapext.nrmesref = 0                     AND
                             crapext.nranoref = 0                     AND
                             crapext.nrctremp = 0                     AND
                             crapext.nraplica = 0                     AND
                             crapext.inselext = 0                     AND
                             crapext.tpextrat = 1 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapext   THEN
         DO:
             CREATE crapext.
             ASSIGN crapext.cdagenci = 1
                    crapext.nrdconta = INT(craptab.dstextab)
                    crapext.dtrefere = glb_dtmvtolt
                    crapext.nrmesref = 0
                    crapext.nranoref = 0
                    crapext.nrctremp = 0
                    crapext.nraplica = 0
                    crapext.inselext = 0
                    crapext.tpextrat = 1
                    crapext.cdcooper = glb_cdcooper.
         END.
END.  /*  Fim do FOR EACH - leitura da tabela de extrato diario  */
     
FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND     
                   craptab.nmsistem = "CRED"             AND
                   craptab.tptabela = "GENERI"           AND
                   craptab.cdempres = 11                 AND
                   craptab.cdacesso = "PROCCONVEN"       AND
                   craptab.tpregist = 0                  NO-LOCK NO-ERROR.

IF   AVAILABLE craptab THEN
     DO:
         aux_dtref072 = DATE(INT(SUBSTR(craptab.dstextab,4,2)),
                             INT(SUBSTR(craptab.dstextab,1,2)),
                             INT(SUBSTR(craptab.dstextab,7,4))).

         IF   (aux_dtref072                  <=  glb_dtmvtolt  AND
              SUBSTR(craptab.dstextab,12,1)  =  "0")           OR
              (MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtoan))     THEN
              DO:

                  CREATE crapsol.
                  ASSIGN aux_nrseqsol = aux_nrseqsol + 1
                         crapsol.nrsolici = 072
                         crapsol.dtrefere = glb_dtmvtolt
                         crapsol.nrseqsol = aux_nrseqsol
                         crapsol.cdempres = 11
                         crapsol.dsparame = IF   MONTH(glb_dtmvtolt) <>
                                                 MONTH(glb_dtmvtoan)
                                            THEN "2"
                                            ELSE "1"
                         crapsol.insitsol = 1
                         crapsol.nrdevias = 1
                         crapsol.cdcooper = glb_cdcooper.

                  IF  crapcop.cdcooper <> 99 THEN 
                      DO:
                         CREATE crapsol.
                         ASSIGN aux_nrseqsol = aux_nrseqsol + 1
                                crapsol.nrsolici = 093
                                crapsol.dtrefere = glb_dtmvtolt
                                crapsol.nrseqsol = aux_nrseqsol
                                crapsol.cdempres = 11
                                crapsol.dsparame = IF   MONTH(glb_dtmvtolt) <>
                                                        MONTH(glb_dtmvtoan)
                                                   THEN "2"
                                                   ELSE "1"
                                crapsol.insitsol = 1
                                crapsol.nrdevias = 1
                                crapsol.cdcooper = glb_cdcooper.
                      END.
              END.
     END.

IF   WEEKDAY(glb_dtmvtolt) <= WEEKDAY(glb_dtmvtoan) THEN
     DO:
         CREATE crapsol.
         ASSIGN aux_nrseqsol = aux_nrseqsol + 1
                crapsol.nrsolici = 070
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = aux_nrseqsol
                crapsol.cdempres = 11
                crapsol.dsparame = " "
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
 
         IF  crapcop.cdcooper <> 99 THEN
             DO:
                CREATE crapsol.
                ASSIGN aux_nrseqsol = aux_nrseqsol + 1
                       crapsol.nrsolici = 091
                       crapsol.dtrefere = glb_dtmvtolt
                       crapsol.nrseqsol = aux_nrseqsol
                       crapsol.cdempres = 11
                       crapsol.dsparame = " "
                       crapsol.insitsol = 1
                       crapsol.nrdevias = 1
                       crapsol.cdcooper = glb_cdcooper.
             END. 
     END.  

/*   Salva relatorios para Auditoria - crps400  */
IF   MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr)   OR
     MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtoan)   THEN
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 073
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = " "
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     END.

IF   MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr)   THEN
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 003
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = " "
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.

         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 004
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = " "
                crapsol.insitsol = 1                    
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.

         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 015
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = " "
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.

         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 018
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = " "
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.

         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 041
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = " "
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.

         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 055
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = " "
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
         
         CREATE crapsol.
         ASSIGN aux_nrseqsol     = aux_nrseqsol + 1
                crapsol.nrsolici = 033
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = aux_nrseqsol
                crapsol.cdempres = 11
                crapsol.dsparame = STRING(glb_dtmvtopr,"99/99/9999") +
                                   " 001 100 008351 1"
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
 
         IF   crapcop.cdcooper <> 99 THEN
              DO:
                  CREATE crapsol.
                  ASSIGN crapsol.nrsolici = 083
                         crapsol.dtrefere = glb_dtmvtolt
                         crapsol.nrseqsol = 01
                         crapsol.cdempres = 11
                         crapsol.dsparame = " "
                         crapsol.insitsol = 1
                         crapsol.nrdevias = 1
                         crapsol.cdcooper = glb_cdcooper.

                  CREATE crapsol.
                  ASSIGN crapsol.nrsolici = 087
                         crapsol.dtrefere = glb_dtmvtolt
                         crapsol.nrseqsol = 01
                         crapsol.cdempres = 11
                         crapsol.dsparame = " "
                         crapsol.insitsol = 1
                         crapsol.nrdevias = 1
                         crapsol.cdcooper = glb_cdcooper.

                  CREATE crapsol.           
                  ASSIGN crapsol.nrsolici = 085
                         crapsol.dtrefere = glb_dtmvtolt
                         crapsol.nrseqsol = 01
                         crapsol.cdempres = 11
                         crapsol.dsparame = " "
                         crapsol.insitsol = 1
                         crapsol.nrdevias = 1
                         crapsol.cdcooper = glb_cdcooper.
        
              END.
        
         IF   NOT CAN-FIND(crapsol WHERE crapsol.cdcooper = glb_cdcooper AND 
                                         crapsol.nrsolici = 009)         THEN
              DO:
                  CREATE crapsol.
                  ASSIGN crapsol.nrsolici = 009
                         crapsol.dtrefere = glb_dtmvtolt
                         crapsol.nrseqsol = 01
                         crapsol.cdempres = 11
                         crapsol.dsparame = " "
                         crapsol.insitsol = 1
                         crapsol.nrdevias = 1
                         crapsol.cdcooper = glb_cdcooper.
              END.

         IF   NOT CAN-FIND(crapsol WHERE crapsol.cdcooper = glb_cdcooper AND 
                                         crapsol.nrsolici = 011)         THEN
              DO:
                  CREATE crapsol.
                  ASSIGN crapsol.nrsolici = 011
                         crapsol.dtrefere = glb_dtmvtolt
                         crapsol.nrseqsol = 01
                         crapsol.cdempres = 11
                         crapsol.dsparame = " "
                         crapsol.insitsol = 1
                         crapsol.nrdevias = 1
                         crapsol.cdcooper = glb_cdcooper.
              END.

         IF   NOT CAN-FIND(crapsol WHERE crapsol.cdcooper = glb_cdcooper AND 
                                         crapsol.nrsolici = 020)         THEN
              DO:
                  CREATE crapsol.
                  ASSIGN crapsol.nrsolici = 020
                         crapsol.dtrefere = glb_dtmvtolt
                         crapsol.nrseqsol = 01
                         crapsol.cdempres = 11
                         crapsol.dsparame = " "
                         crapsol.insitsol = 1
                         crapsol.nrdevias = 1
                         crapsol.cdcooper = glb_cdcooper.
              END.
         
         IF   NOT CAN-FIND(crapsol WHERE crapsol.cdcooper = glb_cdcooper AND 
                                         crapsol.nrsolici = 044)         THEN
              DO:
                  CREATE crapsol.
                  ASSIGN crapsol.nrsolici = 044
                         crapsol.dtrefere = glb_dtmvtolt
                         crapsol.nrseqsol = 01
                         crapsol.cdempres = 11
                         crapsol.dsparame = "4"
                         crapsol.insitsol = 1
                         crapsol.nrdevias = 1
                         crapsol.cdcooper = glb_cdcooper.
              END.

         /*** Sol 96 - extratos trimestral das aplicacoes ***/
         IF   CAN-DO("03,06,09,12",STRING(MONTH(glb_dtmvtolt),"99"))   THEN
              DO:
                  CREATE crapsol.
                  ASSIGN crapsol.nrsolici = 096
                         crapsol.dtrefere = glb_dtmvtolt
                         crapsol.nrseqsol = 01
                         crapsol.cdempres = 11
                         crapsol.dsparame = 
                                 STRING(DATE(INTE(MONTH(glb_dtmvtolt) - 2),01,
                                 YEAR(glb_dtmvtolt)),"99/99/9999") + "," +
                                 STRING(glb_dtmvtolt,"99/99/9999")
                         crapsol.insitsol = 1
                         crapsol.nrdevias = 1
                         crapsol.cdcooper = glb_cdcooper.        
              END.

         /* Verif. se deve solicitar calculo juros sobre o capital sol.26 */
         IF   MONTH(glb_dtmvtolt) = 12   THEN
              DO:
                  FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper AND 
                                     crapsol.nrsolici = 26 NO-LOCK NO-ERROR.
                  
                  IF   NOT AVAILABLE crapsol   THEN                    
                       DO:
                           CREATE crapsol.
                           ASSIGN crapsol.nrsolici = 026
                                  crapsol.dtrefere = glb_dtmvtolt
                                  crapsol.nrseqsol = 01
                                  crapsol.cdempres = 11
                                  crapsol.dsparame = ""
                                  crapsol.insitsol = 1
                                  crapsol.nrdevias = 1
                                  crapsol.cdcooper = glb_cdcooper.
                       END.
              END.

         ASSIGN aux_flgsol46 = TRUE
                aux_flgprior = TRUE.
         
     END.

IF   YEAR(glb_dtmvtolt) <> YEAR(glb_dtmvtopr)   THEN
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 007
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = " "
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     END.

IF   MONTH(glb_dtmvtolt) <> MONTH(crapdat.dtmvtoan)   THEN
     DO:
         /* Cria sol. de emissao resumo HST  */
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 039
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     
         /* Cria sol. de demitidos c/ limite */
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 053
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
        
         IF  crapcop.cdcooper <> 99 THEN
             DO:
             
               CREATE crapsol.
               ASSIGN crapsol.nrsolici = 090
                      crapsol.dtrefere = glb_dtmvtolt
                      crapsol.nrseqsol = 01
                      crapsol.cdempres = 11
                      crapsol.dsparame = ""
                      crapsol.insitsol = 1
                      crapsol.nrdevias = 1
                      crapsol.cdcooper = glb_cdcooper.
             END.    
     
         /* Solicita renovacao de cartoes magneticos  */
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 081
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
        
         /* Primeiro dia util do mes solicita resumo dos debitos IPMF   */
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 036
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.                
     END.

IF   aux_flgsol16   THEN  /* Cria sol.de acompanhamento de talonarios */
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 016
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     END.

/* Cria sol. de pedido de talonarios - sol27 */
IF   WEEKDAY(glb_dtmvtolt) = 2   OR    /* Segunda-feira */
     WEEKDAY(glb_dtmvtolt) = 5   OR
     aux_flgsol27                THEN  /* Quinta-feira */
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 027
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     END.

IF   aux_flgsol28   THEN  /* Cria sol. de baixa de talonarios  */
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 028
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     END.

IF   aux_flgsol29   THEN  /* Cria sol. de emissao de cartoes  */
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 029
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     END.

/*** Cria sol. de emprestimos em atraso ***/
IF   aux_flgsol46   THEN
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 046
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     END.    

/* Cria sol. de emissao de contas incluidas no CCF pelo BB */

IF   aux_flgsol57   THEN 
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 057
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                aux_nrseqsol = aux_nrseqsol + 1
                crapsol.cdcooper = glb_cdcooper.
     END.

IF   aux_flgsol30   THEN  /* Cria sol. de incorp. e calculo retorno */
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 030
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     END.

IF   aux_flgsol80   THEN  /* Solicita central de risco Bacen */
     DO:
         CREATE crapsol.
         ASSIGN aux_nrseqsol     = aux_nrseqsol + 1
                crapsol.nrsolici = 080
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = aux_nrseqsol
                crapsol.cdempres = 11
                crapsol.dsparame = 
                        STRING((glb_dtmvtolt - DAY(glb_dtmvtolt)),"99/99/9999")
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     END.



/*=========================================================Desativado
/*  Encerramento do periodo de apuracao  --  CPMF  */
ASSIGN aux_flgencer = FALSE.

IF   WEEKDAY(glb_dtmvtolt) = 2   THEN
     IF (CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper      AND
                                crapfer.dtferiad = glb_dtmvtolt + 1) AND
         CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper      AND
                                crapfer.dtferiad = glb_dtmvtolt + 2)) OR
        (CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper      AND
                                crapfer.dtferiad = glb_dtmvtolt + 3) AND
         CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper      AND
                                crapfer.dtferiad = glb_dtmvtolt + 4))
         THEN ASSIGN aux_flgencer = TRUE.

IF   WEEKDAY(glb_dtmvtolt) = 3   THEN
     IF   CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper      AND
                                 crapfer.dtferiad = glb_dtmvtolt + 1) OR
          CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper      AND
                                 crapfer.dtferiad = glb_dtmvtolt + 2) OR
          CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper      AND
                                 crapfer.dtferiad = glb_dtmvtolt + 3)
          THEN ASSIGN aux_flgencer = TRUE.

IF   WEEKDAY(glb_dtmvtolt) = 4   THEN
     IF   CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper      AND
                                 crapfer.dtferiad = glb_dtmvtolt + 1) OR
          CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper      AND
                                 crapfer.dtferiad = glb_dtmvtolt + 2)
          THEN 
          .
     ELSE
          ASSIGN aux_flgencer = TRUE.

IF   WEEKDAY(glb_dtmvtolt) = 5   THEN
     IF (CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper      AND
                                crapfer.dtferiad = glb_dtmvtolt - 1)
        AND NOT CAN-FIND(crapper WHERE crapper.cdcooper = glb_cdcooper AND
                                       crapper.dtiniper = glb_dtmvtolt))
            THEN  ASSIGN aux_flgencer = TRUE.

IF WEEKDAY(glb_dtmvtolt) = 6   THEN
   IF ((CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper       AND
                               crapfer.dtferiad = glb_dtmvtolt + 4)  OR
        CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper       AND
                               crapfer.dtferiad = glb_dtmvtolt + 5)) AND
       (CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper       AND
                               crapfer.dtferiad = glb_dtmvtolt + 6)  AND
        CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper       AND
                               crapfer.dtferiad = glb_dtmvtolt + 7))) OR
      ((CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper       AND
                               crapfer.dtferiad = glb_dtmvtolt + 4)  AND
        CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper       AND
                               crapfer.dtferiad = glb_dtmvtolt + 5)) AND
       (CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper       AND
                               crapfer.dtferiad = glb_dtmvtolt + 6)  OR
        CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper       AND
                               crapfer.dtferiad = glb_dtmvtolt + 7)))
        THEN ASSIGN  aux_flgencer = TRUE.

/* Alterado para encerrar o periodo de 28/12/05 a 30/12/2005 pois
   a partir de 2006 a apuracao sera por decendio - Deborah 
   
   Alterado para encerrar o periodo de 02/1/06 a 04/1/20065 pois
   a alteracao acima SOMENTE entrara em vigor a partir de 01/03/2006 - Edson
   */
   
IF   glb_dtmvtolt = 1/4/2006 THEN
     aux_flgencer = TRUE.

IF  glb_dtmvtolt = 02/24/2006 THEN   /* Encerramento especial (Mirtes)*/
    aux_flgencer = TRUE.
===========================================*/

/* ******************************************************** */

FOR EACH crapper WHERE crapper.cdcooper  = glb_cdcooper AND 
                       crapper.dtiniper <= glb_dtmvtolt AND
                       crapper.infimper  = 1            AND
                       aux_flgencer                     EXCLUSIVE-LOCK:
    DO:
        ASSIGN aux_nrdiautl = 0
               aux_dtdebito = glb_dtmvtolt.

        DO WHILE TRUE:

           aux_dtdebito = aux_dtdebito + 1.

           IF   WEEKDAY(aux_dtdebito) = 1   OR
                WEEKDAY(aux_dtdebito) = 7   OR
                CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper AND 
                                       crapfer.dtferiad = aux_dtdebito  )
                THEN NEXT.
           ELSE
                aux_nrdiautl = aux_nrdiautl + 1.

           IF   aux_nrdiautl = 2   THEN
                LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        ASSIGN crapper.dtfimper = IF   crapper.dtiniper = 07/16/2007 THEN
                                       07/31/2007  /* Julio - 31/07/2007 */
                                  ELSE      
                                  IF   DAY(crapper.dtiniper) = 1   THEN
                                       DATE(MONTH(crapper.dtiniper), 10,
                                            YEAR(crapper.dtiniper))
                                  ELSE
                                  IF   DAY(crapper.dtiniper) = 11  THEN
                                       DATE(MONTH(crapper.dtiniper), 20,
                                            YEAR(crapper.dtiniper))
                                  ELSE
                                       glb_dtultdia
               crapper.dtdebito = aux_dtdebito.

    END. /* Fim do DO */

END.  /*  Fim do FOR EACH  --  crapper  */
     
FOR EACH crapper WHERE crapper.cdcooper = glb_cdcooper NO-LOCK:
    DO:
       IF   crapper.infimper = 1              AND
            crapper.dtfimper <  glb_dtmvtopr  AND
            crapper.dtfimper >= glb_dtmvtolt  THEN
            DO:
                CREATE crabper.
                ASSIGN crabper.dtiniper = crapper.dtfimper + 1
                       aux_flgsol35     = TRUE
                       crabper.cdcooper = glb_cdcooper.
            END.

       IF   crapper.indebito  = 1              AND
            crapper.dtdebito <> ?              AND
            crapper.dtdebito <= glb_dtmvtolt   THEN
            aux_flgsol34 = TRUE.

    END. /* Fim do DO */

END.  /*  Fim do FOR EACH  --  crapper  */

IF   aux_flgsol34   THEN  /* Cria sol. de debito do IPMF */
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 034
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     END.


IF   aux_flgsol35   OR /* Cria sol. de encerramento do periodo */
     aux_flsoliof   THEN  /* Cria sol. de iof */
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 035
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     END.
    
/* Se quinto dia util solicita calculo automatico do VAR */                
IF   DAY(glb_dtmvtolt) < 12   THEN
     DO:
         ASSIGN aux_qtdiautl = 0
                aux_dtinimes = 
                    DATE(MONTH(glb_dtmvtolt),01,YEAR(glb_dtmvtolt)) - 1
                aux_dtcalcul = DATE(MONTH(glb_dtmvtolt),01,YEAR(glb_dtmvtolt)).
        
         DO WHILE aux_dtcalcul <= glb_dtmvtolt:

            IF   CAN-DO("1,7", STRING(WEEKDAY(aux_dtcalcul))) OR
                 CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper    AND 
                                        crapfer.dtferiad = aux_dtcalcul)   THEN
                 DO:
                     aux_dtcalcul = aux_dtcalcul + 1.
                     NEXT.
                 END.
            
            ASSIGN aux_dtcalcul = aux_dtcalcul + 1
                   aux_qtdiautl = aux_qtdiautl + 1.

        END.  /*  Fim do DO WHILE  */
                                
END.

IF   aux_flgsol37   THEN  /*  Cria sol. de emissao das aplicacoes  */
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 037
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     END.
               
ASSIGN aux_dspar040 = "crps074,crps123,crps124,crps261,crps639,".

CREATE crapsol.
ASSIGN crapsol.nrsolici = 040
       crapsol.dtrefere = glb_dtmvtolt
       crapsol.nrseqsol = 01
       crapsol.cdempres = 11
       crapsol.dsparame = aux_dspar040
       crapsol.insitsol = 1
       crapsol.nrdevias = 1
       crapsol.cdcooper = glb_cdcooper.

 
/* Cria sol. de emissao da listagem RDCA nas sextas-feiras */
IF   WEEKDAY(glb_dtmvtolt) = 6   OR 
    (WEEKDAY(glb_dtmvtolt) = 5   AND
     CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper AND
                            crapfer.dtferiad = glb_dtmvtolt + 1))   THEN
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 058
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 2
                crapsol.cdcooper = glb_cdcooper.
     END.
ELSE
DO:      /*** Cria sol. se eh terceiro dia util antes do fim do mes ***/ 
    ASSIGN aux_contador = 0.
    DO  WHILE TRUE:

        IF NOT (CAN-DO("1,7",STRING(WEEKDAY(glb_dtultdia  - aux_contador))) OR
                CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper      AND
                crapfer.dtferiad = glb_dtultdia  - aux_contador))           THEN
                ASSIGN  aux_contdata = aux_contdata + 1.

        IF  aux_contdata = 3 THEN
            LEAVE.

        ASSIGN aux_contador = aux_contador + 1.
    END.
END.

IF   aux_flgsol59   THEN  /* Cria sol. ficha para admitidos   */
     DO:
         CREATE crapsol.
         ASSIGN crapsol.nrsolici = 059
                crapsol.dtrefere = glb_dtmvtolt
                crapsol.nrseqsol = 01
                crapsol.cdempres = 11
                crapsol.dsparame = ""
                crapsol.insitsol = 1
                crapsol.nrdevias = 1
                crapsol.cdcooper = glb_cdcooper.
     END.

/* Cria geracao de avisos automaticos */
FOR EACH crapemp WHERE crapemp.cdcooper = glb_cdcooper NO-LOCK:

    IF   ((crapemp.tpdebcot = 2 OR crapemp.tpdebcot = 3) AND
           crapemp.dtavscot <= glb_dtmvtolt              AND
           crapemp.inavscot = 0)   THEN
         DO:
             CREATE crapsol.
             ASSIGN aux_nrseqsol = aux_nrseqsol + 1
                    crapsol.nrsolici = IF   glb_cdcooper = 5
                                            THEN 069
                                            ELSE 023
                    crapsol.dtrefere = glb_dtmvtolt
                    crapsol.nrseqsol = aux_nrseqsol
                    crapsol.cdempres = crapemp.cdempres
                    crapsol.dsparame = IF glb_cdcooper = 5 AND 
                                          CAN-DO("1,2,3,5,6,7,8,9,12,15",
                                          STRING(crapemp.cdempres)) 
                                          THEN "5 2 1 000000,00 000"
                                          ELSE "2 1 1 000000,00 000"
                    crapsol.insitsol = 1
                    crapsol.nrdevias = 1
                    crapsol.cdcooper = glb_cdcooper.
         END.

    IF   ((crapemp.tpdebemp = 2 OR crapemp.tpdebemp = 3) AND
           crapemp.dtavsemp <= glb_dtmvtolt              AND
           crapemp.inavsemp = 0)                         THEN
         DO:
             CREATE crapsol.
             ASSIGN aux_nrseqsol = aux_nrseqsol + 1
                    crapsol.nrsolici = IF   glb_cdcooper = 5
                                            THEN 094
                                            ELSE 043
                    crapsol.dtrefere = glb_dtmvtolt
                    crapsol.nrseqsol = aux_nrseqsol
                    crapsol.cdempres = crapemp.cdempres
                    crapsol.dsparame = IF glb_cdcooper = 5 AND 
                                          CAN-DO("1,2,3,5,6,7,8,9,12,15",
                                          STRING(crapemp.cdempres)) 
                                          THEN "5 2 1 000000,00 000"
                                          ELSE "2 1 1 000000,00 000"
                    crapsol.insitsol = 1
                    crapsol.nrdevias = 1
                    crapsol.cdcooper = glb_cdcooper.
         END.

    IF   crapemp.tpdebppr  = 2            AND 
         crapemp.dtavsppr <= glb_dtmvtolt AND
         crapemp.inavsppr  = 0            THEN
         DO:
             CREATE crapsol.
             ASSIGN aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,
                                    YEAR(glb_dtmvtolt)) + 4) -
                                    DAY(DATE(MONTH(glb_dtmvtolt),28,
                                    YEAR(glb_dtmvtolt)) + 4))
                    aux_nrseqsol = aux_nrseqsol + 1
                    crapsol.nrsolici = 067
                    crapsol.dtrefere = glb_dtmvtolt
                    crapsol.nrseqsol = aux_nrseqsol
                    crapsol.cdempres = crapemp.cdempres
                    crapsol.dsparame = STRING(aux_dtultdia,"99999999")
                    crapsol.insitsol = 1
                    crapsol.nrdevias = 1
                    crapsol.cdcooper = glb_cdcooper.
         END.

    IF   crapemp.tpdebseg  = 2            AND 
         crapemp.dtavsseg <= glb_dtmvtolt AND
         crapemp.inavsseg  = 0            THEN
         DO:
             CREATE crapsol.
             ASSIGN aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,
                                    YEAR(glb_dtmvtolt)) + 4) -
                                    DAY(DATE(MONTH(glb_dtmvtolt),28,
                                    YEAR(glb_dtmvtolt)) + 4))
                    aux_nrseqsol = aux_nrseqsol + 1
                    crapsol.nrsolici = 068
                    crapsol.dtrefere = glb_dtmvtolt
                    crapsol.nrseqsol = aux_nrseqsol
                    crapsol.cdempres = crapemp.cdempres
                    crapsol.dsparame = STRING(aux_dtultdia,"99999999")
                    crapsol.insitsol = 1
                    crapsol.nrdevias = 1
                    crapsol.cdcooper = glb_cdcooper.
         END.

END.  /* Fim do FOR EACH crapemp */
/*  Retirado em 02/12/2004
/*  Cria soliticacao de listagem dos lotes do auto-atendimento  */
FOR EACH craptfn WHERE craptfn.cdcooper = glb_cdcooper NO-LOCK:

    CREATE crapsol.
    ASSIGN aux_nrseqsol     = aux_nrseqsol + 1
           crapsol.nrsolici = 033
           crapsol.dtrefere = glb_dtmvtolt
           crapsol.nrseqsol = aux_nrseqsol
           crapsol.cdempres = 11
           crapsol.dsparame = STRING(glb_dtmvtolt,"99/99/9999")      + " " +
                              STRING(craptfn.cdagenci,"999")         + " 100 " +
                              STRING(320000 + craptfn.nrterfin,"999999") + " 1"
           crapsol.insitsol = 1
           crapsol.nrdevias = 1
           crapsol.cdcooper = glb_cdcooper.

END.  /*  Fim do FOR EACH -- craptfn  */
*/

FOR EACH crapact WHERE crapact.cdcooper = glb_cdcooper             AND 
                       crapact.dtalttct = glb_dtmvtolt             AND
                       CAN-DO("5,6",STRING(crapact.cdtctant))      AND
                       NOT CAN-DO("5,6",STRING(crapact.cdtctatu))  NO-LOCK:
                       
    FIND crapsnh WHERE crapsnh.cdcooper = glb_cdcooper       AND
                       crapsnh.nrdconta = crapact.nrdconta   AND
                       crapsnh.tpdsenha = 2                  AND
                       crapsnh.idseqttl = 0 NO-LOCK NO-ERROR.

    IF   AVAILABLE crapsnh THEN
         DO:
             IF   crapsnh.dtemsenh <> ? THEN
                  NEXT.

             FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                                crapass.nrdconta = crapsnh.nrdconta
                                NO-LOCK NO-ERROR.
             
             CREATE crapsol.
             ASSIGN aux_nrseqsol = aux_nrseqsol + 1
                    crapsol.nrsolici = 75
                    crapsol.dtrefere = glb_dtmvtolt
                    crapsol.nrseqsol = aux_nrseqsol
                    crapsol.dsparame = STRING(crapsnh.nrdconta,"99999999") + 
                                       " 1"  
                    crapsol.cdempres = crapass.cdagenci
                    crapsol.insitsol = 1
                    crapsol.cdcooper = glb_cdcooper.
         END.
END.

FOR EACH crapprg WHERE crapprg.cdcooper = glb_cdcooper 
                       EXCLUSIVE-LOCK ON ERROR UNDO, RETRY:
    crapprg.inctrprg = 1.
END.

FOR EACH crapres WHERE crapres.cdcooper = glb_cdcooper
                       EXCLUSIVE-LOCK ON ERROR UNDO, RETRY:
    DELETE crapres.
END.


/* Criar registro para controle da geracao da DIMOF do ano que se inicia */
IF  YEAR(glb_dtmvtolt) <> YEAR(glb_dtmvtoan)  THEN
    DO:
        /* Primeiro semestre do ano */
        CREATE crapmof.
        ASSIGN crapmof.cdcooper = glb_cdcooper
               crapmof.dtiniper = DATE(01,01,YEAR(glb_dtmvtolt))
               crapmof.dtfimper = DATE(06,30,YEAR(glb_dtmvtolt)).
        /* 
          Calcula o ultimo dia util do mes 08, data limite para envio do arquivo
        */
        ASSIGN aux_dtcalcu2 = DATE(08,01,YEAR(glb_dtmvtolt)).
               aux_ultdiame = ((DATE(MONTH(aux_dtcalcu2),28,YEAR(aux_dtcalcu2))
                                +   4) - DAY(DATE(MONTH(aux_dtcalcu2),28,
                                                  YEAR(aux_dtcalcu2)) + 4)).

        DO WHILE TRUE:
           IF   CAN-DO("1,7",STRING(WEEKDAY(aux_ultdiame)))    OR
                CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper    AND
                                       crapfer.dtferiad = aux_ultdiame)   THEN
                DO:
                    aux_ultdiame = aux_ultdiame - 1.
                    NEXT.
                END.
           LEAVE.
        END.  /*  Fim do DO WHILE TRUE  */
               
        ASSIGN crapmof.dtenvpbc = aux_ultdiame.
        /* Fim do calculo do ultima dia util do mes 08 */
        
        ASSIGN crapmof.dtenvarq = ?
               crapmof.flgenvio = FALSE.
        
        /* Segundo semestre do ano */
        CREATE crapmof.
        ASSIGN crapmof.cdcooper = glb_cdcooper
               crapmof.dtiniper = DATE(07,01,YEAR(glb_dtmvtolt))
               crapmof.dtfimper = DATE(12,31,YEAR(glb_dtmvtolt)).
        /* 
          Calcula o ultimo dia util do mes 02 do ano novo, data limite
          para envio do arquivo do segundo semestre do ano que se inicia
        */
        ASSIGN aux_dtcalcu2 = DATE(02,01,YEAR(glb_dtmvtolt) + 1).
               aux_ultdiame = ((DATE(MONTH(aux_dtcalcu2),28,YEAR(aux_dtcalcu2))
                                +   4) - DAY(DATE(MONTH(aux_dtcalcu2),28,
                                                  YEAR(aux_dtcalcu2)) + 4)).

        DO WHILE TRUE:
           IF   CAN-DO("1,7",STRING(WEEKDAY(aux_ultdiame)))    OR
                CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper    AND
                                       crapfer.dtferiad = aux_ultdiame)   THEN
                DO:
                    aux_ultdiame = aux_ultdiame - 1.
                    NEXT.
                END.
           LEAVE.
        END.  /*  Fim do DO WHILE TRUE  */
               
        ASSIGN crapmof.dtenvpbc = aux_ultdiame.
        /* Fim do calculo do ultima dia util do mes 08 */
        
        ASSIGN crapmof.dtenvarq = ?
               crapmof.flgenvio = FALSE.        

    END.

/*-----------------------------*/

ASSIGN crapdat.inproces = 2
       crapdat.inctrfit = 1
       crapdat.cdprgant = "".

UNIX SILENT VALUE("mv arquivos/.proc_sol.ant " +
                     "arquivos/.proc_sol 2> /dev/null").
       
/*----------
UNIX SILENT VALUE("mv arquivos/so_consulta.ant " +
                     "arquivos/so_consulta 2> /dev/null").
----------*/

IF   aux_flgprior  THEN   /* Cria arquivo de controle da prioridade */
     UNIX SILENT VALUE("mv arquivos/priori.ant " +
                       "arquivos/prioridade 2> /dev/null").

UNIX SILENT > arquivos/.fimdig 2> /dev/null.

UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                   " " + STRING(aux_vldaurvs,"9999.99") +
                   " " + STRING(crapcop.cdagebcb,"9999") +
                  " > proc/dataproc " + " 2> /dev/null").

DO   aux_qtdconta = 1 TO 99:

     aux_nrdctabb = INTEGER(ENTRY(aux_qtdconta,aux_lscontas)).

     IF   aux_nrdctabb = 0 THEN
          LEAVE.
                 
     UNIX SILENT VALUE(" > proc/" + STRING(aux_nrdctabb,"99999999") +
                    STRING(glb_dtmvtolt,"99999999") + " 2> /dev/null").
                          
END.

UNIX SILENT VALUE("rm procbak/* 2> /dev/null").

UNIX SILENT VALUE("cp proc/* procbak 2> /dev/null").

/***** Salvar os Logs de Email/Geração de Relatórios e Jobs *****/

aux_nmlogbat = "salvar/logd_batch" + STRING(DAY(glb_dtmvtoan),"99") +
               STRING(MONTH(glb_dtmvtoan),"99") +
               STRING(YEAR(glb_dtmvtoan),"9999") + ".log".

aux_nmlogmes = "salvar/logd_message" + STRING(DAY(glb_dtmvtoan),"99") +
               STRING(MONTH(glb_dtmvtoan),"99") +
               STRING(YEAR(glb_dtmvtoan),"9999") + ".log".

aux_nmlogrel = "salvar/log_relato" + STRING(DAY(glb_dtmvtoan),"99") +
               STRING(MONTH(glb_dtmvtoan),"99") +
               STRING(YEAR(glb_dtmvtoan),"9999") + ".log".

aux_nmlogeml = "salvar/log_email" + STRING(DAY(glb_dtmvtoan),"99") +
               STRING(MONTH(glb_dtmvtoan),"99") +
               STRING(YEAR(glb_dtmvtoan),"9999") + ".log".

aux_nmlogjob = "salvar/log_job" + STRING(DAY(glb_dtmvtoan),"99") +
               STRING(MONTH(glb_dtmvtoan),"99") +
               STRING(YEAR(glb_dtmvtoan),"9999") + ".log".

/* CorVu */
IF  glb_cdcooper <> 3  THEN
    DO:
       UNIX SILENT VALUE(" > /micros/controle/corvu/" +
                         LC(crapcop.dsdircop) + ".ctr" 
                         + " 2> /dev/null").

       IF  MONTH(glb_dtmvtopr) <> MONTH(glb_dtmvtolt)   THEN
           DO:
              UNIX SILENT VALUE(" > /micros/controle/corvu/" + "mensal.ok"
                   + " 2> /dev/null").
           END.
    END.
ELSE
    DO:
        RUN cria_procfer_cecred.
    END.
     
/***** Copia os Logs de Email/Geração de Relatórios e Jobs *****/
/***** Valida a nao existencia do arquivo destino para criacao do novo. SD 650409 *****/
IF SEARCH(aux_nmlogbat) = ? THEN
DO:
	UNIX SILENT VALUE ("cp log/proc_batch.log " + aux_nmlogbat + " 2> /dev/null" ).
	UNIX SILENT VALUE ("> log/proc_batch.log 2>/dev/null").
END. 

IF SEARCH(aux_nmlogmes) = ? THEN
DO:
	UNIX SILENT VALUE ("cp log/proc_message.log " + aux_nmlogmes + " 2> /dev/null" ).
	UNIX SILENT VALUE ("> log/proc_message.log 2>/dev/null").
END. 

IF SEARCH(aux_nmlogrel) = ? THEN
DO:
	UNIX SILENT VALUE ("cp log/proc_gerac_relato.log " + aux_nmlogrel + " 2> /dev/null" ).
	UNIX SILENT VALUE ("> log/proc_gerac_relato.log 2>/dev/null").
END. 

IF SEARCH(aux_nmlogeml) = ? THEN
DO:
	UNIX SILENT VALUE ("cp log/proc_envio_email.log " + aux_nmlogeml + " 2> /dev/null" ).
	UNIX SILENT VALUE ("> log/proc_envio_email.log 2>/dev/null").
END. 

IF SEARCH(aux_nmlogjob) = ? THEN
DO:
	UNIX SILENT VALUE ("cp log/proc_job.log " + aux_nmlogjob + " 2> /dev/null" ).
	UNIX SILENT VALUE ("> log/proc_job.log 2>/dev/null").
END. 

UNIX SILENT VALUE ("rm -f /usr/coop/cecred/gener/controles/.proc_noturno_ok " +
                   "2>/dev/null").

/*  Remove controle de execucao dos scripts dos processos ................... */

UNIX SILENT VALUE ("rm -f controles/Proc_*.Ok 2>/dev/null").


/*  Elimina arquivos de Controle da ABBC .................................... */

UNIX SILENT VALUE ("rm -f controles/ArqCompABBC.ok 2>/dev/null").
UNIX SILENT VALUE ("rm -f controles/ArqConcABBC.ok 2>/dev/null").
UNIX SILENT VALUE ("rm -f controles/Processo_ABBC.Ok 2>/dev/null").
UNIX SILENT VALUE ("rm -f controles/ArqfacABBC.ok 2>/dev/null").
UNIX SILENT VALUE ("rm -f controles/ArqrocABBC.ok 2>/dev/null").
UNIX SILENT VALUE ("rm -f controles/Arqroc65ABBC.ok 2>/dev/null").

/* .......................................................................... */



/***************************   INICIO - COMENTAR   ****************************/
/*Elimina arquivos de log*/
UNIX SILENT VALUE ("/usr/bin/find /usr/coop/" + crapcop.dsdircop + "/log/cash/* ! -name . -prune -a -mtime +30 -a -exec rm -f \{\} + 2> /dev/null").
UNIX SILENT VALUE ("/usr/bin/find /usr/coop/" + crapcop.dsdircop + "/compbb/salva/* ! -name . -prune -a -mtime +7 -a -exec rm -f \{\} + 2> /dev/null").

IF glb_cdcooper = 3 THEN
    DO:         
        UNIX SILENT VALUE ("/usr/bin/find /usr/coop/cecred/log/TAA/TAA_autorizador*.log ! -name . -prune -a -mtime +30 -a -exec rm -f \{\} + 2> /dev/null"). 
    END.                                                                                                                                       
/*****************************   FIM - COMENTAR   *****************************/

PROCEDURE cria_procfer_cecred:

  DEF VAR aux_qtdias AS INT                                          NO-UNDO.
  DEF VAR aux_qtcont AS INT                                          NO-UNDO.
  DEF VAR aux_nmarqv AS CHAR                                         NO-UNDO.


  /*  Cria arquivos de controle de fim-de-semana/feriados ............... */
  
  /*  Cria SOMENTE PARA A CECRED, para as demais continua a criar no crps000.p.
      Nao ira criar o procfer para SABADO e DOMINGO. Somente para FERIADOS.
      A CECRED nao executa o processo no sabado e domingo. Na crontab esta
      configurado para segunda a sexta.
      Com isso nao sera mais necessario excluir os arquivos procfer na
      segunda-feira e tera um tratamento correto para os feriados */

  IF   glb_cdcooper = 3 THEN  /* Somente para a CECRED */
       DO:
           ASSIGN aux_qtdias = glb_dtmvtopr - glb_dtmvtolt
                  aux_qtcont = 1.
                                      
           DO WHILE aux_qtcont <= (aux_qtdias - 1):

              IF   WEEKDAY(glb_dtmvtolt + aux_qtcont) <> 7 AND   /* Sabado */
                   WEEKDAY(glb_dtmvtolt + aux_qtcont) <> 1 THEN  /* Domingo */
                   DO:
                       /* Cria o arquivo somente para Feriados */
                       aux_nmarqv = "arquivos/.procfer" + STRING(aux_qtcont).
                       
                       UNIX SILENT VALUE("> " + aux_nmarqv).
                   END.
                   
              aux_qtcont = aux_qtcont + 1.
              
           END.  /*  Fim do DO WHILE  */
       END.

END PROCEDURE.

/* .......................................................................... */


