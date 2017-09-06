/*.............................................................................

   Programa: Fontes/crps445.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Abril/2004.                     Ultima atualizacao: 01/09/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Gerar planilha Operacoes de Credito -  Utilizado no CORVU
               Solicitacao 2 - Ordem 37.

   Alteracoes: 03/05/2005 - Substituir planilha(arquivo texto) por tabela 
                            CRAPSDV(Mirtes)
               25/05/2005 - Retirada gravacao arq.texto(Mirtes)
               24/02/2006 - Incluidos dados Aplicacao/Poupanca(Mirtes)
               23/05/2006 - Incluidos totais aplicacoes/operacoes de credito
                            (Mirtes)
               19/06/2006 - Ajustes nas leituras para deixa-los mais perfoma-
                            tico (Edson).
               21/06/2006 - Retirada eliminacao de registro da tabela crapsdv
                            (David).
               25/08/2006 - Incluido na tabela crapsdv o campo cdlcremp (Elton).
               
               27/11/2006 - Melhoria da performance (Evandro).
               
               25/06/2007 - Atualicao de novos atributos da tabela crapsda para
                            utilizacao no corvus (Sidnei - Precise):
                            - vltotpar, vlopcdia, qtdevolu, vltotren,
                              vlavaliz e vlavlatr

               09/08/2007 - Efetuar tratamento para aplicacoes RDC (David).

               26/11/2007 - Substituir chamada da include aplicacao.i pela
                            BO b1wgen0004.i e rdca2s pela b1wgen0004a.i
                            (Sidnei - Precise).
                            
               10/12/2007 - Melhorias de Performance (crapfdc, crapneg)(Julio).
               
               31/03/2008 - Colocado em comentario a Transacao de Aplicacoes e
                            a Transacao de Poupanca Programada (Guilherme).

               16/09/2008 - Alterada chave de acesso a tabela crapldc 
                            (Gabriel).
                          - Adaptacao para desconto de titulos (David).
                          
               05/05/2009 - Ajustes na leitura de desconto de titulo(Guilherme)

               18/06/2009 - Ajuste para considerar todos os rendimentos
                            do titular da conta (Gabriel).
                            
               29/07/2009 - Alimentar campos crapsdv.dtpropos e crapsdv.dtefetiv
                            (Diego).

               11/11/2009 - Atribuir Zero para variavel aux_tot_vllimtit e
                            incluir os campos vllimtit e vldestit na atribuicao
                            de valores na tabela CRAPSCD (Guilherme/Precise)
                            
               05/03/2010 - Passado valores para os campos novos da crapsdv 
                            quando o tipo de saldo devedor for emprestimo 
                            (crapsdv.tpdsaldo = 1) (Elton).
               
               24/03/2010 - Retirado delete da tabela crapscd;
                          - Somente utiliza contas menores que 230.000.0 
                            (Elton).
               
               07/05/2010 - Inserido a soma de cheques em custodia por data de
                            liberacao (Irlan).
                            
               10/06/2010 - Tratamento para pagamento feito atraves de TAA 
                            (Elton).

               20/05/2011 - Melhorar performance (Magui).
               
               04/07/2011 - Alterado para executar em paralelo utilizando a 
                            estrutura da crappar separando por cada PAC
                            (Evandro).
                            
               10/08/2011 - Limpar e incluir PID no log da execucao paralela
                            (Evandro).
                            
               14/11/2011 - Aumentada a quantidade de processos paralelos
                            (Evandro).

               07/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                            
               01/09/2017 - Inclusao de log de fim de execucao do programa 
                            (Carlos)
                            
............................................................................. */

/******************************************************************************
    Para restart eh necessario eliminar as tabelas crapscd e crapsdv e 
    rodar novamente
******************************************************************************/

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps445"
       glb_cdcritic = 0
       glb_dscritic = "".
       
RUN fontes/iniprg.p.
                                                                        
IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

    QUIT.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps445 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT INT(STRING(glb_flgresta,"1/0")),
    OUTPUT 0,
    OUTPUT 0,
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
                      aux_msgerora + "' >> log/proc_batch.log").
    QUIT.
END.
        
CLOSE STORED-PROCEDURE pc_crps445 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps445.pr_cdcritic WHEN pc_crps445.pr_cdcritic <> ?
       glb_dscritic = pc_crps445.pr_dscritic WHEN pc_crps445.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps445.pr_stprogra = 1 THEN 
                          TRUE
                      ELSE 
                          FALSE
       glb_infimsol = IF  pc_crps445.pr_infimsol = 1 THEN 
                          TRUE
                      ELSE
                          FALSE. 

IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                          "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

        QUIT.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS445.P",
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

/* .......................................................................... */
