/******************************************************************************
   Programa: fontes/crps618.p
   Sistema : Cobranca - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Rafael
   Data    : janeiro/2012.                     Ultima atualizacao: 29/06/2017

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Buscar confirmacao de registro dos titulos na CIP.
               Registrar titulos na CIP a partir de novembro/2013.
   
   Observacoes: O script /usr/local/cecred/bin/crps618.pl executa este 
                programa para verificar o registro/rejeicao dos titulos 
                na CIP enviados no dia.
                
                Horario de execucao: todos os dias, das 6:00h as 22:00h
                                     a cada 15 minutos.
                                     
   Alteracoes: 27/08/2013 - Alterado busca de registros de titulos utilizando
                            a data do movimento anterior (Rafael).
                            
               21/10/2013 - Incluido parametro novo na prep-retorno-cooperado
                            ref. ao numero de remessa do arquivo (Rafael).
                            
               15/11/2013 - Mudanças no processo de registro dos titulos na 
                            CIP: a partir da liberação de novembro/2013, os
                            titulos gerados serão registrados por este 
                            programa definidos pela CRON. O campo 
                            "crapcob.insitpro" irá utilizar os seguintes 
                            valores:
                            0 -> sacado comum (nao DDA);
                            1 -> sacado a verificar se é DDA;
                            2 -> Enviado a CIP;
                            3 -> Sacado DDA OK;
                            4 -> não haverá mais -> retornar a "zero";
                            
               03/12/2013 - Incluido nome da temp-table tt-remessa-dda nos 
                            campos onde faltavam o nome da tabela. (Rafael)
                            
               30/12/2013 - Ajuste na leitura/gravacao das informacoes dos
                            titulos ref. ao DDA. (Rafael)     
               
               14/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)  
                            
               03/02/2014 - Ajuste Projeto Novo Fator de Vencimento (Daniel).
               
               27/05/2014 - Aumentado o tempo para decurso de prazo de titulos 
                            DDA de 22 para 59 dias (Tiago SD138818).
                            
               17/07/2014 - Alterado forma de gravacao do tipo de multa para
                            garantir a confirmacao do registro na CIP. (Rafael)
                            
               12/02/2014 - Incluido restrição para não enviar cobrança para a cabine 
                            no qual o valor ultrapasse 9.999.999,99, pois a cabine
                            existe essa limitação de valor e apresentará falha não 
                            tratada SD-250064 (Odirlei-AMcom)
                            
               28/04/2015 - Ajustar indicador de alt de valor ref a boletos
                            vencidos DDA para "N" -> Sacado não pode alterar
                            o valor de boleto vencido. (SD 279793 - Rafael)
                            
               29/05/2015 - Concatenar motivo "A4" para titulos DDA no registro
                            de confirmacao de retorno na crapret.
                          - Enviar titulo Cooperativa/EE ao DDA quando já
                            enviado para a PG. (Projeto 219 - Rafael)
                                                        
               31/07/2015 - Ajuste para retirar o caminho absoluto na chamada
                            de fontes
                            (Adriano - SD 314469).
                                                                        
               18/08/2015 - Ajuste na data limite de pagto para boletos do 
                            convenio "EMPRESTIMO" - Projeto 210 (Rafael).
               
               06/10/2016 - Incluido tratamento de crapcco.dsorgarq = ACORDO”,
                            na procedure p_cria_titulo, Projeto 302 (Jean Michel).

               29/06/2017 - Fonte convertido para Oracle - Projeto 340 (Rafael)

			   24/11/2017 - Comentar chamada de fimprg.p para evitar log no proc_batch
                            com critica 145 (SD 801299 AJFink)
 ........................................................................... */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

/**** Executara na CECRED - Rafael ****/
ASSIGN glb_cdprogra = "crps618"
       glb_cdcooper = 3. 

/*ASSIGN glb_cdprogra = "crps618"
       glb_flgbatch = FALSE
       glb_cdoperad = "1"
       glb_cdcritic = 0
       glb_dscritic = "".
       
RUN fontes/iniprg.p.
                                                                        
IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                  " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
    RETURN.
     END.     
*/


UNIX SILENT VALUE("echo " + STRING(TODAY) + " " + 
                            STRING(TIME,"HH:MM:SS") +
                  " - " + glb_cdprogra + "' --> '"  +
                  "Programa iniciado" + " >> log/crps618.log").

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps618 aux_handproc = PROC-HANDLE NO-ERROR
   (INPUT glb_cdcooper, 
    INPUT 0, /* nrdconta */
    OUTPUT 0, 
    OUTPUT "").

IF  ERROR-STATUS:ERROR  THEN DO:
    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + 
                              ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
END.

    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                   " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao executar Stored Procedure: '" +
                      aux_msgerora + "' >> log/crps618.log").
    RETURN.
END.

CLOSE STORED-PROCEDURE pc_crps618 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps618.pr_cdcritic WHEN pc_crps618.pr_cdcritic <> ?
       glb_dscritic = pc_crps618.pr_dscritic WHEN pc_crps618.pr_dscritic <> ?.


IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                       " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                          "'" + glb_dscritic + "'" + " >> log/crps618.log").
        RETURN.
END.
     
UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                           " - " + glb_cdprogra + "' --> '"  +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/crps618.log").
/*                  
RUN fontes/fimprg.p.
*/