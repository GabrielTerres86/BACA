/*.............................................................................

   Programa: Fontes/crps426.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Novembro/2004.                     Ultima atualizacao: 12/11/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tratar arq. de retorno BB - Cadastramento Conta-Integracao.
               Arquivo COO500.
               
   Alteracoes: 06/04/2005 - Gravar os erros no log da tela PRCITG;
                            Mover o relatorio para o diretorio "RLNSV"
                            (Evandro).

               01/07/2005 - Alimentado campo cdcooper das tabelas crapeca,
                            craptrq e crapreq (Diego).

               05/08/2005 - Nao retorna mais o tipo da conta (Ze Eduardo).
                            
                          - Apagar os erros de contas que foram encerradas
                            (Evandro).
                            
               15/08/2005 - Colocado o relatorio 395 na tela IMPREL (Evandro).
               
               23/09/2005 - Acerto geracao crapeca p/2.titular(Mirtes)
               
               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               28/11/2005 - Criar registros na CRAPECA para controle dos 
                            titulares da conta integracao (Evandro).

               28/11/2005 - Cria as requisicoes quando retorna Cta ITG (Ze).
               
               11/01/2006 - Correcao das mensagens para o LOG e envio de e-mail
                            quando houver RECUSA TOTAL (Evandro).

               20/01/2006 - Nao solicitar talao para tipo de conta 17/18
                            (Mirtes)
                            
               17/02/2006 - Acerto na mensagem arquivo processado (Evandro).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.  
                    
               10/04/2006 - Excluido envio de e-mail para
                            marcospaulo@cecred.coop.br (Diego).
                            
               25/10/2006 - Acrescentado envio de email ao B.Brasil com Contas
                            Itg.Abertas (Diego).             
                            
               06/12/2006 - Alterado email andreas.keim.@bb.com.br para
                            age3420@bb.com.br  (Mirtes)
                            
               04/01/2007 - Criar requisicoes somente para tipos conta
                            integracao - 12,13,14,15,17,18 (Evandro).
               
               14/03/2007 - Permitir o processamento de sequencias menores que
                            a sequencia esperada (Evandro).
                            
               22/05/2007 - Retirado envio de email para Andreas
                            (age3420@bb.com.br) (Guilherme).
                            
               09/08/2007 - Retirado envio de e-mail para Suzana@cecred.coop.br
                           (Guilherme)             

               22/10/2007 - Alteracao no FOR EACH crapeca para melhoria de 
                            performance (Julio)
                            
               08/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                            
               09/01/2009 - Mover arquivo err* para diretorio /salvar e enviar
                            email para suporte.operacional@cecred.coop.br
                            (Diego).
                            
               25/09/2009 - Nao cadastrar nova ITG se já possuir (Guilherme).
               
               26/04/2010 - Alterar formato do nrdconta para 8 posicoes (David).
               
               18/06/2010 - Alteracao tamanho SET STREAM e extensao .ret (Vitor).

               20/09/2010 - Inclusao do e-mail cartoes@cecred.coop.br (Adriano).
               
               08/11/2010 - Copia do arquivo COO500 p/ o diretorio  
                           /micros/cooperativa/compel/recepcao/retornos (Vitor).
                           
               31/05/2012 - Alteracao de email suporte para compe - Trf. 46725 
                           (Ze)      
                           
               01/08/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               07/08/2012 - Inclusão de email na rotina enviar_email:
                            cobranca@cecred.coop.br (Lucas R).
                            
               24/08/2012 - Corrigido impressao do str_1 (Tiago).   
               
               04/09/2012 - Excluido arquivo aux_nmarqim2 (Diego).
               
               14/12/2012 - Envio de emails referente ao COO500 para
                            convenios@cecred.coop.br ao inves de
                            compe@cecred.coop.br (Tiago).
               
               15/04/2013 - Retirado e-mail de cobranca na rotina enviar_email
                           (Daniele).                                  
                           
               12/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)
                            
               24/01/2014 - Incluir VALIDATE crapeca,craptrq,crapreq (Lucas R.)

		           07/03/2018 - Ajuste para buscar os tipo de conta integracao 
                            da Package CADA0006 do orcale. PRJ366 (Lombardi).
............................................................................ */

{ sistema/generico/includes/var_oracle.i } 

{ includes/var_batch.i  } 

DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR b1wgen0011 AS HANDLE                                         NO-UNDO.

DEFINE TEMP-TABLE crawarq                                            NO-UNDO
       FIELD nmarquiv  AS CHAR              
       FIELD nrsequen  AS INTEGER
       FIELD qtassoci  AS INTEGER
       INDEX crawarq_1 AS PRIMARY nmarquiv nrsequen.
 
DEFINE TEMP-TABLE tt_tipos_conta
       FIELD inpessoa AS INTEGER
       FIELD cdtipcta AS INTEGER.
 
DEFINE BUFFER crabtab FOR craptab.

DEFINE VARIABLE rel_nmempres AS CHAR    FORMAT "x(15)"               NO-UNDO.
DEFINE VARIABLE rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5      NO-UNDO.
DEFINE VARIABLE rel_nmresemp AS CHAR                                 NO-UNDO.
DEFINE VARIABLE rel_nrmodulo AS INT     FORMAT "9"                   NO-UNDO.
DEFINE VARIABLE rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.


DEFINE VARIABLE aux_dsprogra AS CHAR     FORMAT "x(6)"               NO-UNDO.
DEFINE VARIABLE aux_tpregist AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_cdocorre AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_dscritic AS CHAR     FORMAT "x(50)"              NO-UNDO.

DEFINE VARIABLE aux_cdseqtab AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_nmarquiv AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_nmarqdat AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_setlinha AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_flgfirst AS LOGICAL                              NO-UNDO.
DEFINE VARIABLE aux_contador AS INT                                  NO-UNDO.

DEFINE VARIABLE aux_flaglast AS LOGICAL                              NO-UNDO.

DEFINE VARIABLE log_nmdcampo AS CHAR                                 NO-UNDO.

/* Variaveis para o XML */ 
DEFINE VARIABLE xDoc          AS HANDLE                              NO-UNDO.   
DEFINE VARIABLE xRoot         AS HANDLE                              NO-UNDO.  
DEFINE VARIABLE xRoot2        AS HANDLE                              NO-UNDO.  
DEFINE VARIABLE xField        AS HANDLE                              NO-UNDO. 
DEFINE VARIABLE xText         AS HANDLE                              NO-UNDO. 
DEFINE VARIABLE aux_cont_raiz AS INTEGER                             NO-UNDO. 
DEFINE VARIABLE aux_cont      AS INTEGER                             NO-UNDO. 
DEFINE VARIABLE ponteiro_xml  AS MEMPTR                              NO-UNDO. 
DEFINE VARIABLE aux_tpsconta  AS LONGCHAR                            NO-UNDO.
DEFINE VARIABLE aux_des_erro  AS CHAR                                NO-UNDO.

/* nome do arquivo de log */
DEFINE VARIABLE aux_nmarqlog AS CHAR                                 NO-UNDO.

  FUNCTION f_ver_contaitg RETURN INTEGER(INPUT  par_nrdctitg AS CHAR):
       
    IF   par_nrdctitg = "" THEN
         RETURN 0.
    ELSE
         DO:
             IF   CAN-DO("1,2,3,4,5,6,7,8,9,0",
                         SUBSTR(par_nrdctitg,LENGTH(par_nrdctitg),1)) THEN
                  RETURN INTEGER(STRING(par_nrdctitg,"99999999")).
             ELSE
                  RETURN INTEGER(SUBSTR(STRING(par_nrdctitg,"99999999"),
                                        1,LENGTH(par_nrdctitg) - 1) + "0").
         END.

  END. /* FUNCTION */


ASSIGN glb_cdprogra = "crps426"
       aux_dsprogra = "COO400"
       glb_flgbatch = FALSE
       aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

/* Busca dados da cooperativa */
   
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.

/* Apaga os erros de cadastramento de contas que ja foram encerradas */
FOR EACH crapeca WHERE (crapeca.cdcooper = glb_cdcooper   AND
                        crapeca.tparquiv = 500)           OR
                       (crapeca.cdcooper = glb_cdcooper   AND
                        crapeca.tparquiv = 505)   
                       EXCLUSIVE-LOCK TRANSACTION:

    FIND crapass WHERE crapass.cdcooper  = glb_cdcooper       AND
                       crapass.nrdconta  = crapeca.nrdconta   AND
                       crapass.dtdemiss <> ?                  NO-LOCK NO-ERROR.
                       
    IF   AVAILABLE crapass   THEN
         DELETE crapeca.

END.

EMPTY TEMP-TABLE crawarq.

ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                      "/compel/recepcao/COO500*.ret"  
       aux_flgfirst = TRUE
       aux_contador = 0.

INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
             NO-ECHO.
                                             
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(70)" .

   ASSIGN aux_contador = aux_contador + 1
          aux_nmarqdat = "integra/coo500" + STRING(DAY(glb_dtmvtolt),"99") +
                                            STRING(MONTH(glb_dtmvtolt),"99") +
                                            STRING(YEAR(glb_dtmvtolt),"9999") +
                                            STRING(aux_contador,"999").
   
   UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                     aux_nmarqdat + " 2> /dev/null").

   UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + "/micros/" + 
                     crapcop.dsdircop + "/compel/recepcao/retornos").
   
   UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

   UNIX SILENT VALUE("quoter " + aux_nmarqdat + " > " + 
                      aux_nmarqdat + ".q 2> /dev/null").

   INPUT STREAM str_2 FROM VALUE(aux_nmarqdat + ".q") NO-ECHO.
      
   IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

   CREATE crawarq.
   ASSIGN crawarq.nrsequen = INT(SUBSTR(aux_setlinha,040,05))
          crawarq.nmarquiv = aux_nmarqdat
          aux_flgfirst     = FALSE.

   INPUT STREAM str_2 CLOSE.
                                                       
END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.

IF   aux_flgfirst THEN
     DO:
         glb_cdcritic = 182.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - COO500 - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "NRARQMVITG"  AND
                   craptab.tpregist = 500
                   NO-ERROR NO-WAIT.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 393.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.

         RETURN.
     END.    
                            
/* sequencia de rotorno esperada */
ASSIGN aux_cdseqtab = INTEGER(SUBSTR(craptab.dstextab,01,05)).
            
/* pre-filtragem dos arquivos */
FOR EACH crawarq NO-LOCK BREAK BY crawarq.nrsequen:
                    
    IF   LAST-OF(crawarq.nrsequen)   THEN
         DO:
            IF   crawarq.nrsequen <= aux_cdseqtab   THEN
                 DO:
                    IF  crawarq.nrsequen = aux_cdseqtab THEN
                        DO:
                           ASSIGN aux_cdseqtab = aux_cdseqtab + 1.
                        END.  
                 END.
            ELSE
                 DO:
                     /* sequencia errada */
                     glb_cdcritic = 476.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - COO500 - " + glb_cdprogra + 
                                       "' --> '"  +
                                       glb_dscritic + " " +
                                       "SEQ.BB " + STRING(crawarq.nrsequen) + 
                                       " " + "SEQ.COOP " + 
                                       STRING(aux_cdseqtab) + " - " +
                                       "salvar/err" + 
                                       SUBSTR(crawarq.nmarquiv,12,29) +
                                       " >> " + aux_nmarqlog).
                     ASSIGN glb_cdcritic = 0
                            aux_nmarquiv = "salvar/err" +
                                           SUBSTR(crawarq.nmarquiv,12,29).

                     /* move o arquivo para o /salvar */
                     UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " +
                                       aux_nmarquiv).

                     /* apaga o arquivo QUOTER */
                     UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q" ).
                    
                     /* E-mail para CENTRAL avisando sobre a ERRO DE SEQ. */
                     
                     UNIX SILENT VALUE
                          ("cp " + aux_nmarquiv + " /usr/coop/" +
                           crapcop.dsdircop + "/converte" +
                           " 2> /dev/null").
                     
                     /* envio de email */ 
                     RUN sistema/generico/procedures/b1wgen0011.p
                         PERSISTENT SET b1wgen0011.
          
                  RUN enviar_email IN b1wgen0011
                                  (INPUT glb_cdcooper,
                                   INPUT glb_cdprogra,
                                   INPUT "convenios@cecred.coop.br," +
                                         "cartoes@cecred.coop.br", 
                                   INPUT '"ERRO DE SEQUENCIA - "' +
                                         '"COO500 - "' +
                                         crapcop.nmrescop,
                                   INPUT SUBSTRING(aux_nmarquiv,8),
                                   INPUT FALSE).

                     DELETE PROCEDURE b1wgen0011.
                     
                     DELETE crawarq.
                     NEXT.
                 END.
         END.
END.
              
/* processar os arquivos que ja foram pre-filtrados */
FOR EACH crawarq NO-LOCK BREAK BY crawarq.nrsequen
                                  BY crawarq.nmarquiv:  

    IF   LAST-OF(crawarq.nrsequen)   THEN
         aux_flaglast = YES.
    ELSE
         aux_flaglast = NO.
    
    RUN proc_processa_arquivo.
    
    IF   glb_cdcritic = 0   THEN
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - COO500 - " + glb_cdprogra + "' --> '"  +
                           "ARQUIVO PROCESSADO COM SUCESSO - " +
                           SUBSTRING(crawarq.nmarquiv,
                                     R-INDEX(crawarq.nmarquiv,"/") + 1) +
                           " >> " + aux_nmarqlog).
END.


RUN p_imprime_aceitos.           /*  Imprime Relatorio com Criticas  */

RUN fontes/fimprg.p.


/* .......................................................................... */

PROCEDURE proc_processa_arquivo:

   DEFINE VARIABLE aux_flgerror AS LOGICAL                            NO-UNDO.
   DEFINE VARIABLE aux_qtregist AS INTEGER                            NO-UNDO.
   DEFINE VARIABLE aux_nrdconta AS INTEGER                            NO-UNDO.
   DEFINE VARIABLE aux_nrdctitg AS INTEGER                            NO-UNDO.
   DEFINE VARIABLE aux_nrdigcta AS CHAR                               NO-UNDO.
   
   ASSIGN aux_flgfirst = FALSE
          glb_cdcritic = 0
          aux_dscritic = "".


   INPUT STREAM str_1 FROM VALUE(crawarq.nmarquiv) NO-ECHO.

   /*   Header do Arquivo   */
    
   IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

   
   IF   SUBSTR(aux_setlinha,01,05) <> "00000" THEN
        glb_cdcritic = 468.
   
   IF   INTEGER(SUBSTR(aux_setlinha,06,04)) <> crapcop.cdageitg THEN
        glb_cdcritic = 134.

   IF   INTEGER(SUBSTR(aux_setlinha,10,08)) <> crapcop.nrctaitg THEN
        glb_cdcritic = 127.

   IF   INTEGER(SUBSTR(aux_setlinha,52,09)) <> crapcop.cdcnvitg THEN
        glb_cdcritic = 563.
    
   IF   glb_cdcritic <> 0 THEN
        DO:
            INPUT STREAM str_1 CLOSE.
            
            RUN fontes/critic.p.
            
            aux_nmarquiv = "salvar/err" + SUBSTR(crawarq.nmarquiv,12,29).
            
            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - COO500 - " + glb_cdprogra + "' --> '" +
                              glb_dscritic + " - " + aux_nmarquiv +
                              " >> " + aux_nmarqlog).
                              
            /* Copia para diretorio converte para utilizar na BO */
            
            UNIX SILENT VALUE ("cp " + aux_nmarquiv + " /usr/coop/" +
                               crapcop.dsdircop + "/converte" +
                               " 2> /dev/null").
                     
            RUN sistema/generico/procedures/b1wgen0011.p
                PERSISTENT SET b1wgen0011.
          
            RUN enviar_email IN b1wgen0011
                               (INPUT glb_cdcooper,
                                INPUT glb_cdprogra,
                                INPUT "convenios@cecred.coop.br," +
                                      "cartoes@cecred.coop.br",
                                INPUT '"ERROS DIVERSOS - "' +
                                      '"COO500 - "' + crapcop.nmrescop,
                                INPUT SUBSTRING(aux_nmarquiv,8),
                                INPUT FALSE).

            DELETE PROCEDURE b1wgen0011.
            
            RETURN.
        END.

   IF   INTEGER(SUBSTR(aux_setlinha,396,03)) <> 1 AND   /*  Recusa Total   */
        INTEGER(SUBSTR(aux_setlinha,396,03)) <> 4 THEN  /*  Recusa Parcial */
        DO:
            ASSIGN aux_cdocorre = INTEGER(SUBSTR(aux_setlinha,396,03)).
            
            /*   Recusa Total do Arquivo  */
            IF   aux_cdocorre = 2   OR
                 aux_cdocorre = 3   OR
                 aux_cdocorre = 5   OR
                 aux_cdocorre = 6   OR
                 aux_cdocorre = 8   THEN
                 RUN p_recusa_total.

            INPUT STREAM str_1 CLOSE.
            
            aux_nmarquiv = "salvar/err" + SUBSTR(crawarq.nmarquiv,12,29).
            
            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").

            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
                
            IF   glb_cdcritic <> 0 THEN
                 DO:
                     RUN fontes/critic.p.
                 
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - COO500 - " + glb_cdprogra + 
                                       "' --> '" +
                                       glb_dscritic +
                                       " - RECUSA TOTAL - " +
                                       crawarq.nmarquiv + 
                                       " >> " + aux_nmarqlog).
                 END.
            ELSE
                 DO:
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - COO500 - " + glb_cdprogra + 
                                       "' --> '" +
                                       "RECUSA TOTAL - " +
                                       crawarq.nmarquiv + 
                                       " >> " + aux_nmarqlog).
                                       
                     glb_cdcritic = 182.                                       
                 END.
                 
            /* Move para diretorio converte para utilizar na BO */
            UNIX SILENT VALUE ("cp " + aux_nmarquiv + " /usr/coop/" +
                               crapcop.dsdircop + "/converte" +
                               " 2> /dev/null").
                     
            RUN sistema/generico/procedures/b1wgen0011.p
                PERSISTENT SET b1wgen0011.
          
            RUN enviar_email IN b1wgen0011
                               (INPUT glb_cdcooper,
                                INPUT glb_cdprogra,
                                INPUT "convenios@cecred.coop.br," +
                                      "cartoes@cecred.coop.br",
                                INPUT '"RECUSA TOTAL - "' +
                                      '"COO500 - "' + 
                                      crapcop.nmrescop,
                                INPUT SUBSTRING(aux_nmarquiv,8),
                                INPUT FALSE).

            DELETE PROCEDURE b1wgen0011.

            RETURN.
        END.         /*   Fim  da  Recusa  Total  */

   
   DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

      IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

      ASSIGN glb_cdcritic = 0
             aux_qtregist = aux_qtregist + 1
             aux_tpregist = INTEGER(SUBSTR(aux_setlinha,11,02)).

      IF   aux_dscritic <> ""   AND
           aux_tpregist = 2     THEN
           NEXT.      
      
      /*  Verifica se eh final do Arquivo  */
       
      IF   INTEGER(SUBSTR(aux_setlinha,1,1)) = 9 THEN
           DO:
               /*   Conferir o total do arquivo   */

               IF   (aux_qtregist + 1) <> 
                    DECIMAL(SUBSTR(aux_setlinha,06,09)) THEN
                    DO:
                        ASSIGN glb_cdcritic = 504.
                         
                        RUN fontes/critic.p.
                        
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - COO500 - " + glb_cdprogra + 
                                          "' --> '" +
                                          glb_dscritic + 
                                          " - ARQUIVO PROCESSADO - " +
                                          aux_nmarquiv +
                                          " >> " + aux_nmarqlog).
                        LEAVE.
                    END.
           END.
      ELSE
      IF   INTEGER(SUBSTR(aux_setlinha,11,02)) = 1 THEN
           DO:
              ASSIGN aux_cdocorre = INTEGER(SUBSTR(aux_setlinha,396,03)).
              
              /* se for 2,3,4 titular */
              IF   INTEGER(SUBSTR(aux_setlinha,111,01)) >= 2 THEN
                   DO:
                       /* se houve erro nesse titular */
                       IF   aux_cdocorre <> 0   THEN
                            DO:
                               ASSIGN aux_nrdconta = 
                                            INT(SUBSTR(aux_setlinha,358,08)).
                       
                               FIND crapass WHERE 
                                    crapass.cdcooper = glb_cdcooper   AND
                                    crapass.nrdconta = aux_nrdconta
                                    NO-LOCK NO-ERROR.

                               /* Se nao tem conta integracao nao interessa o
                                  erro dos outros titulares */
                               IF   crapass.nrdctitg = ""   THEN
                                    NEXT.
                                          
                               IF   aux_cdocorre = 999 THEN
                                    aux_dscritic = SUBSTR(aux_setlinha,399,40).
                               ELSE                            
                                    DO:
                       
                                        { includes/criticas_coo.i }
                                    
                                    END.

                               /* Se encontrar critica 552 NAO gera novas
                                  criticas para nao "atropelar" as
                                  inclusoes/exclusoes */

                               FIND FIRST crapeca WHERE 
                                          crapeca.cdcooper = glb_cdcooper  AND
                                          crapeca.nrdconta =
                                                        crapass.nrdconta   AND
                                          crapeca.tparquiv = 552
                                          NO-LOCK NO-ERROR.
                                                   
                               IF   NOT AVAILABLE crapeca   THEN
                                    DO:
                                       /* Inclusao do titular no BB */
                                       CREATE crapeca.
                                       ASSIGN crapeca.nrdconta =
                                                    crapass.nrdconta
                                              crapeca.dscritic = "EFETUANDO " +
                                                    "INCLUSAO SEG. " +
                                                    "TITULAR"
                                              crapeca.tparquiv = 552
                                              crapeca.cdcooper = glb_cdcooper
                                              crapeca.dtretarq = glb_dtmvtolt
                                              crapeca.idseqttl = 2
                                              crapeca.nrseqarq = 0
                                              crapeca.nrdcampo = 0.
                                       VALIDATE crapeca.
                                    END.
                            END.
                       NEXT. 
                   END.

              IF   aux_cdocorre = 0 THEN          /*  SEM  ERROS  */
                   DO:
                       ASSIGN aux_nrdconta = INT(SUBSTR(aux_setlinha,358,08))
                              aux_nrdctitg = 
                                    f_ver_contaitg(SUBSTR(aux_setlinha,404,08))
                              aux_flgerror = FALSE.
                              
                       DO WHILE TRUE:
                     
                          FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                             crapass.nrdconta = aux_nrdconta
                                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 
                                             
                          IF   NOT AVAILABLE crapass THEN
                               IF   LOCKED crapass THEN
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                               ELSE 
                                    DO:
                                        ASSIGN glb_cdcritic = 009.
                                        RUN fontes/critic.p.
                                        UNIX SILENT VALUE("echo " + 
                                             STRING(TIME,"HH:MM:SS") +
                                             " - COO500 - " + glb_cdprogra + 
                                             "' --> '" +
                                             glb_dscritic + " - " + 
                                             aux_nmarquiv +
                                             " >> " + aux_nmarqlog).
                                        UNIX SILENT VALUE("rm " + 
                                                          crawarq.nmarquiv +
                                                          ".q 2> /dev/null").
                                        LEAVE.
                                    END.

                          LEAVE.
                       
                       END.  /*  Fim do DO WHILE TRUE  */
           
                       IF   glb_cdcritic <> 0 THEN
                            NEXT.

                       /* Se ja possuir conta ITG cadastrada, nao alterar 
                          nada da conta e jogar no LOG */
                       IF  crapass.nrdctitg <> ""  THEN
                           DO:
                               UNIX SILENT VALUE(
                               "echo " + STRING(TIME,"HH:MM:SS") +
                               " - COO500 - " + glb_cdprogra + "' --> '"  +
                               "Conta: " + STRING(crapass.nrdconta) + " ja " +
                               "possui conta ITG cadastrada. ITG vinda do BB" +
                               " " + SUBSTR(aux_setlinha,404,08) +
                               " >> " + aux_nmarqlog).
                               NEXT.
                           END.

                       ASSIGN crapass.flgctitg = 2
                              crapass.dtabcitg = glb_dtmvtolt
                              crapass.nrdctitg = SUBSTR(aux_setlinha,404,08).
                              
                       
                       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                 
                       RUN STORED-PROCEDURE pc_lista_tipo_conta_itg
                       aux_handproc = PROC-HANDLE NO-ERROR (INPUT 1,    /* Flag conta itg */
                                                            INPUT 0,    /* modalidade */
                                                           OUTPUT "",   /* Tipos de conta */
                                                           OUTPUT "",   /* Flag Erro */
                                                           OUTPUT "").  /* Descrição da crítica */
                 
                       CLOSE STORED-PROC pc_lista_tipo_conta_itg
                             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                 
                       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                 
                       ASSIGN aux_tpsconta = ""
                              aux_des_erro = ""
                              aux_dscritic = ""
                              aux_tpsconta = pc_lista_tipo_conta_itg.pr_tiposconta 
                                             WHEN pc_lista_tipo_conta_itg.pr_tiposconta <> ?
                              aux_des_erro = pc_lista_tipo_conta_itg.pr_des_erro 
                                             WHEN pc_lista_tipo_conta_itg.pr_des_erro <> ?
                              aux_dscritic = pc_lista_tipo_conta_itg.pr_dscritic
                                             WHEN pc_lista_tipo_conta_itg.pr_dscritic <> ?.
                 
                       IF aux_des_erro = "NOK"  THEN
                           DO:
                               glb_dscritic = aux_dscritic.
                               UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                                 " - " + glb_cdprogra + "' --> '"  +
                                                 glb_dscritic + " >> " + aux_nmarqlog).
                               NEXT.
                           END.
                       
                       /* Inicializando objetos para leitura do XML */ 
                       CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
                       CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
                       CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
                       CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
                       CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
                       
                       EMPTY TEMP-TABLE tt_tipos_conta.
                       
                       /* Efetuar a leitura do XML*/ 
                       SET-SIZE(ponteiro_xml) = LENGTH(aux_tpsconta) + 1. 
                       PUT-STRING(ponteiro_xml,1) = aux_tpsconta. 
                          
                       IF ponteiro_xml <> ? THEN
                           DO:
                               xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
                               xDoc:GET-DOCUMENT-ELEMENT(xRoot).
                           
                               DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
                           
                                   xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
                           
                                   IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                                    NEXT. 
                           
                                   IF xRoot2:NUM-CHILDREN > 0 THEN
                                     CREATE tt_tipos_conta.
                           
                                   DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                                       
                                       xRoot2:GET-CHILD(xField,aux_cont).
                                           
                                       IF xField:SUBTYPE <> "ELEMENT" THEN 
                                           NEXT. 
                                       
                                       xField:GET-CHILD(xText,1).
                                      
                                       ASSIGN tt_tipos_conta.inpessoa =  INT(xText:NODE-VALUE) WHEN xField:NAME = "inpessoa".
                                       ASSIGN tt_tipos_conta.cdtipcta =  INT(xText:NODE-VALUE) WHEN xField:NAME = "cdtipo_conta".
                                       
                                   END. 
                                   
                               END.
                           
                               SET-SIZE(ponteiro_xml) = 0. 
                           END.
                 
                       DELETE OBJECT xDoc. 
                       DELETE OBJECT xRoot. 
                       DELETE OBJECT xRoot2. 
                       DELETE OBJECT xField. 
                       DELETE OBJECT xText.
                       
                       FIND craptrq WHERE tt_tipos_conta.inpessoa = crapass.inpessoa AND
                                          tt_tipos_conta.cdtipcta = crapass.cdtipcta NO-ERROR NO-WAIT.

                       IF AVAILABLE craptrq THEN
                            NEXT.

                        /*************  CRIA  A  REQUISICAO  *************/
                       
                        DO WHILE TRUE:

                           FIND craptrq WHERE 
                                craptrq.cdcooper = glb_cdcooper       AND
                                craptrq.tprequis = 1                  AND
                                craptrq.cdagelot = crapass.cdagenci   AND
                                craptrq.nrdolote = 10000
                                USE-INDEX craptrq1 NO-ERROR NO-WAIT.

                           IF   NOT AVAILABLE craptrq   THEN
                                IF   LOCKED craptrq   THEN
                                     DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT.
                                     END.
                                ELSE
                                     DO:
                                         CREATE craptrq.
                                         ASSIGN 
                                            craptrq.cdagelot = crapass.cdagenci
                                            craptrq.nrdolote = 10000
                                            craptrq.tprequis = 1
                                            craptrq.cdcooper = glb_cdcooper.
                                     END.

                           LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */

                        CREATE crapreq.
                        ASSIGN crapreq.nrseqdig = craptrq.nrseqdig + 1
                               crapreq.nrdconta = crapass.nrdconta
                               crapreq.cdtipcta = crapass.cdtipcta
                               crapreq.nrdctabb = aux_nrdctitg
                               crapreq.cdagelot = craptrq.cdagelot
                               crapreq.nrdolote = craptrq.nrdolote
                               crapreq.cdagenci = crapass.cdagenci
                               crapreq.nrinichq = 0
                               crapreq.insitreq = 5
                               crapreq.nrfinchq = 0
                               crapreq.dtmvtolt = glb_dtmvtolt
                               crapreq.tprequis = 1
                               crapreq.cdcooper = glb_cdcooper
                               crapreq.qtreqtal = 1

                               craptrq.nrseqdig = crapreq.nrseqdig
                               craptrq.qtinforq = craptrq.qtinforq + 1
                               craptrq.qtcomprq = craptrq.qtcomprq + 1
                               craptrq.qtinfotl = craptrq.qtinfotl + 1
                               craptrq.qtcomptl = craptrq.qtcomptl + 1.

                        VALIDATE craptrq.
                        VALIDATE crapreq.
                   END.
              ELSE                /*   COM  ERROS  */
                   DO:
                       ASSIGN aux_nrdconta = INT(SUBSTR(aux_setlinha,358,08))
                              aux_flgerror = TRUE.

                       DO WHILE TRUE:
                     
                          FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                             crapass.nrdconta = aux_nrdconta
                                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 
                                             
                          IF   NOT AVAILABLE crapass THEN
                               IF   LOCKED crapass THEN
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                               ELSE 
                                    DO:
                                        ASSIGN glb_cdcritic = 009.
                                        RUN fontes/critic.p.
                                        UNIX SILENT VALUE("echo " + 
                                             STRING(TIME,"HH:MM:SS") +
                                             " - COO500 - " + glb_cdprogra + 
                                             "' --> '" +
                                             glb_dscritic + " - " + 
                                             aux_nmarquiv +
                                             " >> " + aux_nmarqlog).
                                        UNIX SILENT VALUE("rm " + 
                                                          crawarq.nmarquiv +
                                                          ".q 2> /dev/null").
                                        LEAVE.
                                    END.

                          ASSIGN crapass.flgctitg = 4.
                                                
                          LEAVE.
                       
                       END.  /*  Fim do DO WHILE TRUE  */
           
                       IF   glb_cdcritic <> 0 THEN
                            NEXT.
                            
                       IF   aux_cdocorre = 999 THEN
                            aux_dscritic = SUBSTR(aux_setlinha,399,40).
                       ELSE                            
                            DO:
                       
                                { includes/criticas_coo.i }
                            
                            END.
                            
                       /* para o caso do mesmo erro duas vezes */
                       FIND crapeca WHERE 
                            crapeca.cdcooper = glb_cdcooper      AND
                            crapeca.tparquiv = 500               AND
                            crapeca.nrdconta = crapass.nrdconta  AND
                            crapeca.nrseqarq = crawarq.nrsequen  AND
                            crapeca.nrdcampo = aux_cdocorre
                            NO-LOCK NO-ERROR.
                                     
                       IF   NOT AVAILABLE crapeca   THEN
                            DO:
                                CREATE crapeca.
                                ASSIGN crapeca.nrdconta = crapass.nrdconta
                                       crapeca.dtretarq = glb_dtmvtolt
                                       crapeca.nrdcampo = aux_cdocorre
                                       crapeca.nrseqarq = crawarq.nrsequen
                                       crapeca.tparquiv = 500
                                       crapeca.idseqttl = 
                                       INT(SUBSTR(aux_setlinha,111,01)) 
                                       crapeca.dscritic = aux_dscritic
                                       crapeca.cdcooper = glb_cdcooper.
                                VALIDATE crapeca.
                            END.
                   END.
           END.
     
   END.  /*   Fim  do DO WHILE TRUE  */

   INPUT STREAM str_1 CLOSE.

   UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
   
   UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar"). 
   
   IF   glb_cdcritic = 0     AND     /* se esta OK */
        aux_flaglast = YES   THEN    /* e eh o ultimo da sequencia */
        DO TRANSACTION:

            ASSIGN SUBSTRING(craptab.dstextab,1,5) = 
                             STRING(crawarq.nrsequen + 1,"99999").

        END.

END PROCEDURE.

PROCEDURE p_imprime_aceitos:
   
   DEFINE VARIABLE tot_qtdtotal AS INT                                NO-UNDO.
   DEFINE VARIABLE rel_dsagenci AS CHAR  FORMAT "x(21)"               NO-UNDO.
   DEFINE VARIABLE aux_nmarqimp AS CHAR                               NO-UNDO.
   DEFINE VARIABLE aux_flgfirst AS LOGICAL                            NO-UNDO.
   DEFINE VARIABLE aux_nmprimtl AS CHAR      FORMAT "x(40)"           NO-UNDO.
   DEFINE VARIABLE aux_nrdconta AS INT                                NO-UNDO.
   DEFINE VARIABLE aux_nrdctitg AS CHAR      FORMAT "9.999.999-X"     NO-UNDO.
   DEFINE VARIABLE aux_dtabcitg AS DATE                               NO-UNDO.
   
   FORM rel_dsagenci      AT 01 FORMAT "x(21)"     LABEL "AGENCIA"
        SKIP(1)
        WITH NO-BOX SIDE-LABELS WIDTH 080 FRAME f_agencia.

   FORM aux_nrdconta      AT 05 FORMAT "zzzz,zzz,9"  LABEL "CONTA/DV"
        aux_nmprimtl      AT 19 FORMAT "x(40)"       LABEL "NOME"
        aux_nrdctitg      AT 63 FORMAT "9.999.999-X" LABEL "CONTA INTEGRACAO"
        WITH NO-BOX NO-LABELS DOWN  WIDTH 80 FRAME f_descricao_ace.
        
   FORM aux_nrdconta      AT 05 FORMAT "zzzz,zzz,9"  LABEL "CONTA/DV"
        aux_nmprimtl      AT 19 FORMAT "x(40)"       LABEL "NOME"
        aux_nrdctitg      AT 63 FORMAT "9.999.999-X" LABEL "CONTA INTEGRACAO"
        aux_dtabcitg      AT 83 FORMAT "99/99/9999"  LABEL "DATA DE ABERTURA"
        WITH NO-BOX NO-LABELS DOWN  WIDTH 132 FRAME f_descricao_email.

   FORM SKIP(1)
        "TOTAL DE CONTAS CADASTRADAS ==>"  AT  30
        tot_qtdtotal                       AT  67 FORMAT "zzz,zz9"
        SKIP(2)
        WITH NO-BOX NO-LABELS WIDTH 080 FRAME f_total_ace.

   { includes/cabrel080_1.i }  /*  Monta cabecalho do rel. de aceitos   */

   ASSIGN tot_qtdtotal = 0
          aux_flgfirst = TRUE.
            
   
   FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                          crapass.flgctitg = 2             AND
                          crapass.dtabcitg = glb_dtmvtolt  NO-LOCK 
                          BREAK BY crapass.cdagenci:
   
       IF   FIRST-OF(crapass.cdagenci)  THEN
            DO:
                IF   NOT aux_flgfirst THEN
                     DO:
                         IF   LINE-COUNTER(str_1) >= 82 THEN
                              DO:
                                  PAGE STREAM str_1.

                                  DISPLAY STREAM str_1 rel_dsagenci 
                                                       WITH FRAME f_agencia.
                              END.

                         DISPLAY STREAM str_1 tot_qtdtotal
                                              WITH FRAME f_total_ace.

                         ASSIGN tot_qtdtotal = 0.

                         OUTPUT STREAM str_1 CLOSE.

                         /* se nao estiver rodando no PROCESSO copia relatorio
                            para "/rlnsv" */
                         IF   glb_inproces = 1   THEN
                              UNIX SILENT VALUE("cp " + aux_nmarqimp + 
                                                " rlnsv/" +
                                                SUBSTRING(aux_nmarqimp,
                                                R-INDEX(aux_nmarqimp,"/") + 1,
                                                LENGTH(aux_nmarqimp) - 
                                                R-INDEX(aux_nmarqimp,"/"))).
                     
                     END.
                     
                ASSIGN aux_flgfirst = FALSE
                       aux_nmarqimp = "rl/crrl395_" + 
                                      STRING(crapass.cdagenci,"999") + ".lst".              

                OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
                     
                VIEW STREAM str_1 FRAME f_cabrel080_1.

                FIND crapage WHERE crapage.cdcooper = glb_cdcooper      AND
                                   crapage.cdagenci = crapass.cdagenci
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE crapage   THEN
                     rel_dsagenci = STRING(crapass.cdagenci,"999") + " - " +
                                    FILL("*",15).
                ELSE
                     rel_dsagenci = STRING(crapage.cdagenci,"999") + " - " +
                                    crapage.nmresage.

                DISPLAY STREAM str_1 rel_dsagenci  WITH FRAME f_agencia.

            END.
            
       ASSIGN tot_qtdtotal = tot_qtdtotal + 1
              aux_nrdconta = crapass.nrdconta
              aux_nmprimtl = crapass.nmprimtl
              aux_nrdctitg = crapass.nrdctitg
              aux_dtabcitg = crapass.dtabcitg.
       
       DISPLAY STREAM str_1 aux_nrdconta   aux_nmprimtl   aux_nrdctitg
                            WITH FRAME f_descricao_ace.
                            
       DOWN STREAM str_1 WITH FRAME f_descricao_ace.
       
       IF   LINE-COUNTER(str_1) >= 83   THEN
            DO:
                PAGE STREAM str_1.
        
                DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_agencia.
            END.
   END.

   IF   NOT aux_flgfirst THEN
        DO:
            DISPLAY STREAM str_1 tot_qtdtotal WITH FRAME f_total_ace.

            OUTPUT STREAM str_1 CLOSE.
         END.

END.   /*  fim da PROCEDURE  */

PROCEDURE p_recusa_total:

     ASSIGN glb_cdcritic = 0.
          
     /* atualiza os associados para serem enviados novamente */
     FOR EACH crapass WHERE crapass.cdcooper  = glb_cdcooper  AND 
                            crapass.cdtipcta >= 8             AND 
                            crapass.cdtipcta <= 18            AND
                            crapass.flgctitg = 1              EXCLUSIVE-LOCK:

         ASSIGN crapass.flgctitg = 0.
     END.

     /* bloqueia a craptab */
     DO WHILE TRUE:

        FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper  AND
                           crabtab.nmsistem = "CRED"        AND
                           crabtab.tptabela = "GENERI"      AND
                           crabtab.cdempres = 00            AND
                           crabtab.cdacesso = "NRARQMVITG"  AND
                           crabtab.tpregist = 400
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE crabtab   THEN
             DO:
                 IF   LOCKED crabtab   THEN
                      DO:
                          glb_cdcritic = 72.
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
             END.          
        ELSE
             glb_cdcritic = 0.

        LEAVE.

     END.  /*  Fim do DO .. TO  */

     IF   glb_cdcritic = 0 THEN 
          DO:
              ASSIGN SUBSTRING(crabtab.dstextab,1,7) =
                               SUBSTR(aux_setlinha,39,05) + " 1"
                     SUBSTRING(craptab.dstextab,1,5) = 
                               STRING(crawarq.nrsequen,"99999"). 
          END.
          
    
END.   /*   Fim da Pro cedure  */

/* .......................................................................... */

