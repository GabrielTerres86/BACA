/* ..........................................................................

   Programa: Fontes/crps080.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 14/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 043.
               Processar as solicitacoes de geracao dos debitos de emprestimos.
               Emite relatorio 65.

   Alteracoes: 22/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                          quidacao do emprestimo (Edson).

               05/07/94 - Alterado para eliminar o literal "cruzeiros reais".

               06/10/94 - Alterado para gerar arquivo de descontos para a
                          empresa 11 no formato da folha RUBI (Edson).

               25/10/94 - Alterado para gerar os descontos com o codigo da verba
                          utilizada na empresa a que se refere (Edson).

               11/01/95 - Alterado para trocar o codigo da empresa 10 para 1
                          na geracao do arquivo (padrao RUBI) para a HERCO
                          (Edson).

               23/01/95 - Alterado para trocar o codigo da empresa 13 para 10
                          na geracao do arquivo (padrao RUBI) para a Associacao
                          (Deborah).

               04/04/95 - Alterado para registrar no log o aviso para tranmis-
                          sao e gravacao dos arquivos das empresas 1,4,9,20 e
                          99 e copiar os mesmos arquivos para o diretorio salvar
                          (Edson).

               28/04/95 - Alterado para copiar os arquivos gerados para o dire-
                          torio integrar (Edson).

               30/05/95 - Alterado para gerar crapavs para as empresas com
                          tipo de debito igual 2 (Debito em conta) (Edson).

               09/08/95 - Alterado para eliminar a diferenciacao feita na cria-
                          cao do avs para empresa 4 (Odair).

               16/01/96 - Alterado para tratar empresa 9 (Consumo) gravando no
                          formato RUBI com o codigo da empresa = 1 (Odair).

               31/10/96 - Na leitura do EPR, selecionar apenas os que tenham
                          flgpagto como TRUE (Odair).

               19/11/96 - Alterar a mascara do campo nrctremp (Odair).

               24/03/97 - Alterado para incorporar o valor da CPMF a prestacao
                          quando a empresa for LOJAS HERING (Edson).

               16/07/97 - Quando for criar avs verificar tpconven para gerar a
                          crapavs.dtmvtolt (Odair)

               24/07/97 - Atualizar emp.inavsemp (Odair)

               05/08/97 - Na criacao do avs alimentar cdempcnv com o valor do
                          crapsol.cdempres. (Odair).

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               22/01/98 - Alterado para gerar cdsecext para Ceval Jaragua com
                          zeros (Deborah).

               24/03/98 - Cancelada a alteracao anterior (Deborah).

               13/04/98 - Alterado para mostrar a CPMF no relatorio (Deborah).

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               24/03/1999 - Acerto para o dia 25/03/1999 para a empresa 6
                            (Deborah).

               07/05/1999 - Alterado para classificar por conta e nao mais por
                            cadastro da empresa (Deborah).
                            
               26/05/99 - Zerar variaveis de cpmf (Odair).             
               
               31/05/1999 - Tratar CPMF (Deborah).

               17/01/2000 - Tratat tpdebemp = 3 (Deborah).

               28/06/2005 - Alimentado campo cdcooper da tabela crapavs
                            (Diego).
                                
               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               09/03/2012 - Declarada variaveis novas da include lelem.i (Tiago)
               
               01/11/2012 - Tratar so os emprestimos do tipo zero Price TR
                            (Oscar).
               
               14/01/2014 - Inclusao de VALIDATE crapavs (Carlos)
               
               05/05/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                                     
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps080"
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

RUN STORED-PROCEDURE pc_crps080 aux_handproc = PROC-HANDLE NO-ERROR
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

CLOSE STORED-PROCEDURE pc_crps080 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps080.pr_cdcritic WHEN pc_crps080.pr_cdcritic <> ?
       glb_dscritic = pc_crps080.pr_dscritic WHEN pc_crps080.pr_dscritic <> ?
       glb_stprogra = IF pc_crps080.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps080.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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