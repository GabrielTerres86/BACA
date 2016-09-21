/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps480.p                | pc_crps480                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

*******************************************************************************/





/*..............................................................................

   Programa: fontes/crps480.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Maio/2007                       Ultima atualizacao: 07/06/2013

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Solicitacao: 003.
               Calcular o rendimento mensal e liquido das aplicacoes RDCA e lis-
               tar o resumo mensal.
               Ordem da solicitacao: 9 
               Relatorio 454 e 455.

   Observacoes: No campo craprda.vlsdrdca esta sempre o valor real da aplicacao
                sem provisao e sem rendimentos, todos os resgates foram  
                retirados desse campo
                Deve constar no relatorio os seguintes dados
                -quantidade de titulos ativos = craprda.insaqtot = 0
                -quantidade de titulos aplicados no mes = 
                 craplap.cdhistor = 473 do mes
                -saldo total dos titulos ativos = craprda.vlsdrdca
                -valor total aplicado no mes = craprda.vlsdrdca
                 com month(craprda.dtmvtolt) igual ao mes que roda o mensal
                -valor total dos resgates no mes =  craplap.cdhistor = 475
                 do mes onde craprda.dtvencto <= craplap.dtmvtolt
                -rendimento creditado no mes = craplap.cdhistor = 476 do mes
                -imposto de renda retido na fonte = craplap.cdhistor = 477 
                 do mes
                -valor total da provisao do mes = 474 do mes
                -ajuste da provisao = 463 do mes
                -saques sem rendimento = craplap.cdhistor = 475 do mes 
                 onde craprda.dtvencto e  maior que a data do resgate
                -Historico = 474 provisao rdcpre
                             463 estorno provisao rdcpre
                             529 provisao rdcpos
                             531 estorno provisao rdcpos
   
   Alteracoes: 22/08/2007 - Corrigido tplotmov para 9 (Magui). 

               01/10/2007 - Trabalhar com 4 casas na provisao RDCPOS e
                            RDCPRE (Magui).

               09/11/2007 - Incluida coluna Saldo ajustado que contem
                            as provisoes e reversoes passadas para auxiliar
                            no fechamento contabil (Magui).

               26/12/2007 - Ajustar relatorios p/fechamento contabil 
                            do RDCPRE (Magui).

               26/02/2008 - Incluir parametros no restart (David).
               
               11/03/2008 - Melhorar leitura do craplap para taxas e
                            incluir novos campos no crrl455, rdcpos (Magui).

               25/03/2008 - Incluir crrl477 e crrl478 (David).

               04/01/2008 - Alterar posicao das includes de cabecalho (David).

               07/05/2008 - Corrigir atualizacao do lote (Magui).

               24/07/2008 - Incluido no relatorio crrl455 relacao de Prazo
                            Medio das Aplicacoes, e listagem detalhada 
                            por conta das aplicacoes (somente para Cecred)
                            (Diego).

               01/09/2010 - Armazenar informacoes de aplicacoes na crapbnd.
                            Incluir quadro de prazos no relatorio crrl454.
                            Tarefa 34654 (Henrique).

               14/09/2010 - Incluido prazos entre 1080 e 5400 dias. (Henrique)

               26/11/2010 - Retirar da sol 3 ordem 9 e colocar na sol 83
                            ordem 6.E na CECRED sol 83 e ordem 7 (Magui).

               17/01/2011 - Alterada a coluna Total da Provisão para
                            imprimir corretamente a quantidade de caracteres
                            (Isara - RKAM).

               26/01/2011 - Alimentar crapprb por nrdconta do cooperado
                           (Guilherme) 

               08/02/2011 - Incluir totalizador por conta somente para CECRED 
                            (Isara - RKAM).                          

               10/01/2012 - Melhoria de desempenho (Gabriel)

               01/11/2012 - Nova coluna "Situacao" da aplicacao frame f_detalhe
                            Novo totalizador por Situacao no total por conta
                            (Guilherme/Supero)
                            
               05/03/2013 - Instanciar BO 04 fora do FOR EACH para 
                            diminuir o tempo de processamento (Gabriel).
                                  
               07/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                                  
..............................................................................*/

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps480"
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

RUN STORED-PROCEDURE pc_crps480 aux_handproc = PROC-HANDLE
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
    RETURN.
END.
        
CLOSE STORED-PROCEDURE pc_crps480 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps480.pr_cdcritic WHEN pc_crps480.pr_cdcritic <> ?
       glb_dscritic = pc_crps480.pr_dscritic WHEN pc_crps480.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps480.pr_stprogra = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps480.pr_infimsol = 1 THEN
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
                  
RUN fontes/fimprg.p.

/*............................................................................*/
