/* ........................................................................... 
   
   Programa: Fontes/crps666.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabricio
   Data    : Fevereiro/2014.                    Ultima atualizacao: 08/01/2016 

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Reajustar o valor da prestacao dos planos de cotas capital com
               base no tipo de reajuste cadastrado para o associado.
               Solicitacao : 85.
               Ordem do programa na solicitacao = 5.
               Exclusivo.
   
   Alteracoes: Substituição da tabela crapmfx de leitura da taxa IPCA  
               para a tabela craptxi. 
               (Carlos Rafael Tanholi - Projeto Captacao) 30/09/2014
                
               07/01/2015 -  Substituir a mensagem emitida no log/proc_batch.log
                             quando não encontrar registro crapmfx (craptxi) , 
                             por envio de e-mail SD 238789 (Vanessa)
                             
               29/05/2015 - Correcao na composição de data na leitura da craptxi
                            SD 291975 (Carlos R.)

               08/01/2015 - Alterado procedimento solicitar_envio_email para chamar
                            a rotina convertida na b1wgen0011.p 
                            SD356863 (Odirlei-AMcom)
 ........................................................................... */
{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_contador AS INTE           NO-UNDO.
DEF VAR aux_dtrefere AS DATE           NO-UNDO.
DEF VAR aux_indicmes AS DECI EXTENT 12 NO-UNDO.
DEF VAR aux_dtultcor AS DATE           NO-UNDO.



ASSIGN glb_cdprogra = "crps666".


RUN fontes/iniprg.p.

IF glb_cdcritic > 0 THEN
    RETURN.

/* Busca dados da cooperativa */
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF NOT AVAILABLE crapcop THEN
DO:
    ASSIGN glb_cdcritic = 651.
    RUN fontes/critic.p.
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      glb_dscritic + " >> log/proc_batch.log").
    RETURN.
END.

/* Busca data do sistema */ 
FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF NOT AVAIL crapdat THEN 
DO:
    ASSIGN glb_cdcritic = 1.
    RUN fontes/critic.p.
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      glb_dscritic + " >> log/proc_batch.log").
    RETURN.
END.

ASSIGN aux_contador = -1.

/* Busca ultimas 12 taxas cadastradas ate dois meses atras para atualizar
   planos cadastrados com correcao baseado no IPCA */
DO WHILE aux_contador >= -12:
    
    ASSIGN aux_dtrefere = ADD-INTERVAL(glb_dtmvtolt, aux_contador + (-1), "months").
    
    FIND FIRST craptxi WHERE craptxi.cddindex = 4                          AND
                             MONTH(craptxi.dtiniper) = MONTH(aux_dtrefere) AND
                              YEAR(craptxi.dtiniper) = YEAR(aux_dtrefere)  AND
                             MONTH(craptxi.dtfimper) = MONTH(aux_dtrefere) AND
                              YEAR(craptxi.dtfimper) = YEAR(aux_dtrefere)  
                             NO-LOCK NO-ERROR.

    IF AVAIL craptxi THEN
        ASSIGN aux_indicmes[aux_contador * -1] = craptxi.vlrdtaxa.
    ELSE
    DO:
        ASSIGN glb_cdcritic = 0
               glb_dscritic = "Indice IPCA do mes " + 
                              STRING(MONTH(aux_dtrefere), "99") + "/" +
                              STRING(YEAR(aux_dtrefere), "9999") +
                              " nao foi cadastrado.".

        /* UTILIZACAO DA ROTINA EM ORACLE PL/SQL PARA ENVIO DE E-MAIL */
        RUN envia_email_log (INPUT glb_cdprogra,
                             INPUT "rafael.fagundes@cecred.coop.br, klaus.ulrich@cecred.coop.br ",
                             INPUT "ATENCAO- nao foi possível atualizar o valor dos planos de capital",
                             INPUT glb_dscritic ).

        RUN fontes/fimprg.p.

        RETURN.
    END.

    ASSIGN aux_contador = aux_contador - 1.
END.

/* Busca os planos que devem sofrer correcao de valor */
FOR EACH crappla WHERE crappla.cdcooper = glb_cdcooper AND  
                       crappla.cdtipcor > 0            AND
                       crappla.cdsitpla = 1            AND /* Ativos */ 
                       crappla.flgatupl = TRUE
                       EXCLUSIVE-LOCK TRANSACTION:

    IF crappla.cdtipcor = 1 THEN /* correcao por indice de inflacao - IPCA */
        ASSIGN crappla.vlprepla = crappla.vlprepla + 
                                         (crappla.vlprepla * 
                                            (((1 + (aux_indicmes[1] / 100))  *
                                              (1 + (aux_indicmes[2] / 100))  *
                                              (1 + (aux_indicmes[3] / 100))  *
                                              (1 + (aux_indicmes[4] / 100))  *
                                              (1 + (aux_indicmes[5] / 100))  *
                                              (1 + (aux_indicmes[6] / 100))  *
                                              (1 + (aux_indicmes[7] / 100))  *
                                              (1 + (aux_indicmes[8] / 100))  *
                                              (1 + (aux_indicmes[9] / 100))  *
                                              (1 + (aux_indicmes[10] / 100)) *
                                              (1 + (aux_indicmes[11] / 100)) *
                                              (1 + (aux_indicmes[12] / 100)) 
                                             ) + (-1)
                                            )
                                         ).
    ELSE /* correcao por valor fixo */
        ASSIGN crappla.vlprepla = crappla.vlprepla + crappla.vlcorfix.

    ASSIGN crappla.dtultcor = glb_dtmvtolt
           crappla.flgatupl = FALSE.
END.

RUN fontes/fimprg.p.


/* Solicitacao de envio para o responsavel para monitoracao dos erros */
PROCEDURE envia_email_log:
    DEF INPUT PARAM par_cdprogra AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_destino  AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_assunto  AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_conteudo AS CHAR                    NO-UNDO.
    
    DEF   VAR b1wgen0011   AS HANDLE                        NO-UNDO.
    DEF   VAR aux_dscritic AS CHAR                          NO-UNDO.    
    
    /* envio de email */
    RUN sistema/generico/procedures/b1wgen0011.p
        PERSISTENT SET b1wgen0011.
         
    RUN solicita_email_oracle IN b1wgen0011
                     ( INPUT  glb_cdcooper        /* par_cdcooper         */
                      ,INPUT  par_cdprogra        /* par_cdprogra         */
                      ,INPUT  par_destino         /* par_des_destino      */
                      ,INPUT  par_assunto         /* par_des_assunto      */
                      ,INPUT  par_conteudo        /* par_des_corpo        */
                      ,INPUT  ""                  /* par_des_anexo        */
                      ,INPUT  "S"                 /* par_flg_remove_anex  */
                      ,INPUT  "N"                 /* par_flg_remete_coop  */
                      ,INPUT  ""                  /* par_des_nome_reply   */
                      ,INPUT  ""                  /* par_des_email_reply  */
                      ,INPUT  "S"                 /* par_flg_log_batch    */
                      ,INPUT  "S"                 /* par_flg_enviar       */
                      ,OUTPUT aux_dscritic        /* par_des_erro         */
                       ).
  
    DELETE PROCEDURE b1wgen0011. 
    
    IF aux_dscritic <> "" THEN
    DO:
      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + par_cdprogra + "' --> '"  +
                              "Erro ao rodar: " + 
                              "'" + aux_dscritic + "'" + " >> log/proc_batch.log").
      RETURN.
    END.

END PROCEDURE.


