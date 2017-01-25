/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps533.p                | BTCH0001.pc_crps533               |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

*******************************************************************************/




/* .............................................................................

   Programa: Fontes/crps533.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Dezembro/2009                   Ultima atualizacao:  11/01/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 1.
               Integrar arquivos CECRED de cheques - Sua Remessa
               Emite relatorio 526 e 564

   Alteracoes: 03/12/2009 - Primeira Versao

               02/03/2010 - Alterar historicos 469 para 524 (Guilherme/Supero)

               16/06/2010 - Acerto Gerais (Ze).

               22/06/2010 - Permitir que o programa rode diferenciadamente para
                            coop 3, lendo todos os arquivos 1*.RET, importar os
                            dados e gerar um relatorio. Quando for outra coop,
                            continuar o funcionamento atual (Guilherme/Supero)

               28/07/2010 - Incluso Validacao para COMPEFORA (Jonatas/Supero)

               06/07/2010 - Alt. de Age. Apresentante p/ Age. Deposito (Ze). 

               23/08/2010 - Ajuste no controle do arquivo integrado (Ze).

               02/09/2010 - Ajuste na Conta onde foi depositado (Ze).

               06/09/2010 - Campos craplcm.cdbanchq, craplcm.cdagechq e 
                            craplcm.cdcmpchq sao usados na devolu. Atualizar
                            com dados do cheque (Magui).

               13/09/2010 - Acerto p/ gerar relatorio no diretorio rlnsv 
                            (Vitor)            

               23/09/2010 - Incluir coluna TD (Tipo de Documento) (Ze).

               01/12/2010 - Substituir alinea 43 por 21 e 49 por 28. (Ze).

               10/12/2010 - Inclusao de Transferencia de PAC quando coop 2
                            (Guilherme/Supero)
                            
               10/01/2011 - Alteracao para criar reg. de devolucao - Migracao
                            de PACs (Ze).
                            
               18/01/2011 - Incluido os e-mails:
                            - fabiano@viacredi.coop.br
                            - moraes@viacredi.coop.br
                            (Adriano).

               18/02/2011 - Alterar alinea para 43 quando ja houve uma 1a vez
                            (Guilherme/Supero)
                            
               25/03/2011 - Acerto para exibir a critica 179 no rel. (Ze).
               
               13/04/2011 - Nao sera permitido a entrada de cheques que estao
                            em custodia ou em desconto de cheques (Adriano).
                            
               03/06/2011 - Alterado destinatário do envio de email na procedure
                            gera_relatorio_203_99; 
                            De: thiago.delfes@viacredi.coop.br
                            Para: brusque@viacredi.coop.br. (Fabricio)
                            
               09/06/2011 - Retirada restrição para os tipos de documentos 75,
                            76,77,90,94 e 95(alerta de roubo), permitindo a 
                            utilizacao das mesmas alineas dos historicos de 
                            contra-ordem (Diego).            

               10/06/2011 - Informar para a Viacredi as contra-ordens das
                            contas migradas atraves do crrl526_99 (Ze).
                            
               07/07/2011 - Nao tarifar devolucao de alinea 31 (Diego).
               
               15/07/2011 - Tratamento p/ cheques das contas transferidas (Ze).
               
               01/08/2011 - Ajuste no tratamento das contas TCO (Ze).
               
               05/08/2011 - Ajuste para nao desprezar reg. qdo ha caracteres
                            em campos numericos - Tarefa 41727 (Ze)
                            
               08/12/2011 - Sustação provisória (André R./Supero).     
               
               23/12/2011 - Retirar Warnings (Gabriel).
               
               30/03/2012 - Criado registro na crapdev para os cheques com
                            cdcritic = 09 ou 108. Usado alinea 37. (Fabricio)
                            
               02/05/2012 - Ajuste na devolucao da alinea 37 (Ze).
               
               18/06/2012 - Alteracao na leitura da craptco (David Kruger).
               
               02/07/2012 - Ajuste na verificacao de cheques em desconto e
                            custodia - Trf. 3820 (Ze).
                            
               04/07/2012 - Retirado email fabiano@viacredi.com.br 
                            do recebimento do relatório (Guilherme Maba).
                            
               06/08/2012 - Adicionado parametro "codigo do programa" a chamada
                            da funcao geradev. (Fabricio)
                            
               08/08/2012 - Enviar email quando houver Cheque VLB no arquivo.
                            (Fabricio)

               22/08/2012 - Adicionado include "verifica_fraude_cheque".
                            (Fabricio/Ze).

               27/08/2012 - Alterado posições do cdtipchq de 52,2 para 148,3 
                            (Lucas R.). 
                            
               27/08/2012 - Validações Projeto TIC (Richard/Supero).
               
               24/10/2012 - Comentar a validacao da TIC (Ze).
               
               18/12/2012 - Retirar comentario da validacao da TIC (Ze).
               
               20/12/2012 - Tratamento para AltoVale (Ze).
               
               11/01/2013 - Tratamento para AltoVale - TIC (Ze).

               18/01/2013 - Ajuste TIC - agencia apresent. e agencia dep. e
                            Ajuste no total do rel. 529_99 (Ze).
                            
               07/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                                
			   11/01/2017 - Adicionado verificação necessária para garantir 
			                que a Viacredi processe os cheques de contas migradas 
                            para da Alto Vale antes de ser gerado o saldo dos 
							cooperados no processo da Alto Vale 
							(Tiago/Elton SD584796).
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps533"
       glb_flgbatch = FALSE
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

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps533 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT INT(STRING(glb_flgresta,"1/0")),
    INPUT glb_nmtelant,
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
    RETURN.
END.
        
CLOSE STORED-PROCEDURE pc_crps533 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps533.pr_cdcritic WHEN pc_crps533.pr_cdcritic <> ?
       glb_dscritic = pc_crps533.pr_dscritic WHEN pc_crps533.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps533.pr_stprogra = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps533.pr_infimsol = 1 THEN
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

        RETURN.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").

/**** Verificação necessária para garantir que a Viacredi processe os cheques de contas migradas 
         para da Alto Vale antes de ser gerado o saldo dos cooperados no processo da Alto Vale ****/
 IF glb_cdcooper = 16 THEN
    DO:
        IF  glb_nmtelant <> "COMPEFORA" THEN
            DO:

                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")                 + 
                                  " - "   + glb_cdprogra + "' --> '"                +
                                  "Aguardando finalização do CRPS533 da Viacredi... "  + 
                                  " >> log/proc_batch.log").

                DO WHILE TRUE:
                    FIND crapprg WHERE crapprg.cdcooper = 1         
                                   AND crapprg.cdprogra = "CRPS533" 
                                   AND crapprg.nmsistem = "CRED"
                                   AND crapprg.inctrprg = 2 NO-LOCK NO-ERROR.

                    IF  AVAIL crapprg THEN
                        DO:
                            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")      + 
                                              " - "   + glb_cdprogra + "' --> '"     +
                                              "Execucao do CRPS533 da Viacredi... OK "  + 
                                              " >> log/proc_batch.log").
                  
                            LEAVE.
                         END.
                    ELSE
                        DO:
                            PAUSE(60) NO-MESSAGE.
                            NEXT.
                        END.
                END. /** WHILE***/
            END.
    END.

                  
RUN fontes/fimprg.p.

/* .......................................................................... */
