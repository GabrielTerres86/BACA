/* ..........................................................................

   Programa: Fontes/crps000a.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Novembro/2009.                     Ultima atualizacao: 21/02/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Verificar se passaram 7 dias sem recebimento dos arquivos de 
               débito da Brasil Telecom e enviar e

   Alteracoes:  18/07/2012 - Ajuste do format no campo nmrescop (David Kruger).
   
                10/06/2013 - Alteração função enviar_email_completo p/ nova versão (Jean Michel).

                21/02/2014 - Aumento do format de crapcop.nmrescop de 11 para
                             20 (Carlos)
   
............................................................................ */

{ includes/var_online.i }
    
DEFINE VARIABLE h-b1wgen0011 AS HANDLE      NO-UNDO.
DEFINE VARIABLE aux_conteudo AS CHARACTER   NO-UNDO.
    
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

/* Buscar ultimo registro de controle convenio banco do brasil */
FIND LAST gncontr WHERE
          gncontr.cdcooper = crapcop.cdcooper  AND
          gncontr.tpdcontr = 3                 AND   /* Int.Arq.Debito Autom.*/
          gncontr.cdconven = 1 NO-LOCK NO-ERROR.     /* Brasil Telecom */

IF  AVAIL gncontr  THEN
    DO:
        IF  gncontr.dtmvtolt <= (glb_dtmvtolt - 7) THEN
            DO:
                RUN sistema/generico/procedures/b1wgen0011.p 
                    PERSISTENT SET h-b1wgen0011.
    
                IF  NOT VALID-HANDLE (h-b1wgen0011)  THEN
                    DO:
                        UNIX SILENT VALUE("echo "
                                  + STRING(TIME,"HH:MM:SS") + " - "
                                  + "crps000a.p" + "' --> '" 
                                  + "Handle invalido para h-b1wgen0011. " 
                                  + STRING(crapcop.nmrescop, "x(20)") 
                                  + " >> log/proc_batch.log").
                        RETURN.          
                    END.
    
                ASSIGN aux_conteudo =
                         "<b>ATEN&Ccedil;&Atilde;O!</b>\n\n"
                       + "Voc&ecirc; est&aacute; recebendo este "
                       + "e-mail para lhe informar que desde o dia <u>"
                       + STRING(gncontr.dtmvtolt,"99/99/9999").
                ASSIGN aux_conteudo = aux_conteudo
                       + "</u>, a cooperativa <u>" + STRING(crapcop.nmrescop, "x(20)").
                ASSIGN aux_conteudo = aux_conteudo
                       + "</u> n&atilde;o recebe arquivos de d&eacute;bito da "
                       + "Brasil Telecom.\n\n"
                       + "Este e-mail foi enviado pelo processo batch do dia "
                       + STRING(TODAY,"99/99/9999").
                ASSIGN aux_conteudo = aux_conteudo
                       + " ref.: " + STRING(glb_dtmvtolt,"99/99/9999").
                ASSIGN aux_conteudo = aux_conteudo + ".".

                RUN enviar_email_completo IN h-b1wgen0011
                            (INPUT glb_cdcooper,
                             INPUT "crps000",
                             INPUT "CECRED<cecred@cecred.coop.br>",
                             INPUT "rosangela@cecred.coop.br," +
                                   "mirtes@cecred.coop.br,"    +
                                   "margarete@cecred.coop.br,"  +
                                   "suporte.operacional@cecred.coop.br",
                             INPUT "Arquivos de debito Brasil Telecom",
                             INPUT "",
                             INPUT "",
                             INPUT aux_conteudo,
                             INPUT FALSE).
    
                DELETE PROCEDURE h-b1wgen0011.
            END.
    END.

/* ......................................................................... */

