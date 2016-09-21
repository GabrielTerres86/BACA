/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | includes/crps011.p              | pc_crps011                        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

*******************************************************************************/






/*** Magui: no informe de rendimentos do ano, campo saldo em 31/12/AAAA e           
     alimentado com o campo CRAPDIR.VLSDAPLI. Sendo que aplicacoes RDCPOS
     tera um calculo diferente para o informe de rendimento: 
     his 528(aplicacao feita) + 532(rendimento) - 533(irrf) - 534(resgate).
     ***/
/* .............................................................................

   Programa: Fontes/crps011.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/92.                       Ultima atualizacao: 14/01/2014

   Dados referentes ao programa:

   Frequencia: Anual (Batch)
   Objetivo  : Fazer o ajuste dos saldos anuais no ultimo processo do ano.
               Atende a solicitacao 007 (Anual de atualizacao).
               Alterado para atender a rotina anual de capital.

   Alteracoes: 08/12/94 - Alterado para acumular o total das aplicacaoes RDCA
                          no final do ano (Edson).

               20/03/95 - Alterado para tratar crapcot.qtextmfx e qtandmfx
                          (Deborah).

               21/07/95 - Alterado para alimentar o campo dtmvtolt na crapdir
                          com a data do movimento (Odair).

               18/12/95 - Alterado para utilizar rotina includes/aplicacao.i
                          (Edson).

               01/04/96 - Tratar craprpp (poupanca programada) (Odair).

               22/11/96 - Leitura do RDA calcular o saldo em funcao do tpaplica
                          acumulando no total aplicado o saldo do rdcaII (Odair)

               18/02/98 - Alterado para tratar valores abonados (Deborah).
               
               24/12/98 - Alterado para mover as 12 ocorrencias do vlrenrda
                          do crapcot para o crapdir (Deborah).

               22/01/99 - Alterado para mover e zerar novos campos ref IOF
                          do crapcot(Deborah).

               26/01/99 - Tratar novos campos do crapcot (Deborah).

               16/03/2000 - Tratar vlrentot no crapcot e no crapdir (Deborah).

               09/05/2002 - Calcular o saldo da poupanca programada ate o 
                            final de dezembro lendo os lancamentos apos o
                            aniversario de dezembro (Deborah).

               11/04/2003 - Atualiza crapdir.vlcpmfpg (Margarete).

               28/11/2003 - Atualizar novos campos crapcot para IR (Margarete).
               
               09/01/2004 - Atualizacao campo crapcot.qtippmfx antes da 
                            atualizacao campo crapdir.vlcpmfpg(Mirtes).

               23/06/2004 - Tratar novos campos no crapsld (Edson).
                              
               22/09/2004 - Incluido historicos 496(CI)(Mirtes)
               16/12/2004 - Incluicos campos crapcot.vlirajus/
                                             crapdir.vlirajus(Mirtes)

               28/06/2005 - Alimentado campo cdcooper da tabela crapdir        
                            (Diego).
                             
               06/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                            "fontes/iniprg.p" por causa da "glb_cdcooper"
                            (Evandro).
                            
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               19/06/2007 - Incluido novos campos crapdir.vlirfrdc e
                            crapdir.vlrenrdc (Elton). 
                            
               26/07/2007 - Efetuar leitura das aplicacoes RDC (David).        
                    
               05/02/2009 - Atualizar novo campo crapcot.vlpvardc (David).     
               
               16/11/2010 - Alterada a forma de calculo do saldo de aplicacoes
                            RDCPOS (Henrique).
                            
               14/03/2012 - Atualizar novos campos vlrencot e vlirfcot ref.
                            rendimento sobre o capital (Diego).    
                            
               02/04/2012 - Atualizacao do campo crapdir.vlcapmes com
                            crapcot.vlcapmes e novo calculo para atualizacao 
                            do campo crapcot.vlpvardc (David).
                            
               01/08/2013 - Tratamento para o Bloqueio Judicial (Ze).
               
               14/01/2014 - Inclusao de VALIDATE crapdir (Carlos)

               09/06/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure Oracle convertida (Marcos - SUPERO)

............................................................................. */

{ includes/var_batch.i} 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps011"
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

RUN STORED-PROCEDURE pc_crps011 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps011 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps011.pr_cdcritic WHEN pc_crps011.pr_cdcritic <> ?
       glb_dscritic = pc_crps011.pr_dscritic WHEN pc_crps011.pr_dscritic <> ?
       glb_stprogra = IF pc_crps011.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps011.pr_infimsol = 1 THEN TRUE ELSE FALSE.

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

/* .......................................................................... */


