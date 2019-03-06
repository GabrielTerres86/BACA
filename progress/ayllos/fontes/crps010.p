/* ..........................................................................

   Programa: Fontes/crps010.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/92.                         Ultima atualizacao: 20/02/2019
   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 004 (mensal - relatorios)
               Emite: relatorio geral de atendimento - matriz (014) e
                      resumo mensal do capital (031).

   Alteracoes: 05/07/94 - Alterado literal cruzeiros reais para reais.

               01/08/94 - Alteracoes para o controle do recadastramento.

               30/08/94 - Alterado o layout do resumo mensal do capital,
                          desprezar os associados com data de eliminacao,
                          ler tabela com o valor do capital eliminado (Edson).

               14/03/95 - Alterado para ler a tabela VALORBAIXA somente quando
                          for final de trimestre (Edson).

               21/03/95 - Alterado para na geracao do relatorio 031, listar
                          somente quando for final de trimestre listar capital
                          em moeda fixa, correcao monetaria do exercicio e
                          correcao monetaria do mes. (Odair).

               10/04/95 - Alterado para emitir resumo por agencia da quantida-
                          de de associados e inclusao das rotinas crps010_1.p e
                          crps010_2.p (Edson).

               19/04/95 - Alterado para modificar o label do relatorio geral de
                          atendimento acrescendo os campos vledvmto e
                          dtedvmto  (Odair).

               11/10/95 - Alterado para incluir a data de adimissao na empresa
                          para agencia 14 (Odair).

               27/11/95 - Alterado para incluir a data de admissao na empresa
                          para a agencia 15. (Odair).

               19/11/96 - Alterar a mascara do campo nrctremp (Odair).

               03/04/97 - Alterado a qtd de vias do relatorio 31 (Deborah).

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               18/09/98 - Mudar tratamento de impressao (Deborah).
               
             02/10/2003 - Mudar o formulario para 132dm no crrl014_99 (Ze).

             05/05/2004 - Tratar eliminados (Edson).
             
             08/12/2004 - Incluido campos Data Ult.Prestacao Paga/
                          Ult.Valor Pago/Vlr.Provisao Emprestimo e Nivel
                          (Mirtes/Evandro)
                        - Gerar relatorio 398 (Evandro).
                        
             20/05/2005 - Gerar relatorio 421 (Evandro).           
             
             20/06/2005 - Acrescentado campo inmatric na TEMP-TABLE            
                          w_demitidos (Diego).

             07/07/2005 - Gerar relatorio 426 (Evandro).           
             
             18/08/2005 - Detalhar admitidos de cada PAC no rel 031 (Evandro).
             
             14/02/2006 - Unificacao dos bancos - SQLWorks - Eder
             
             28/03/2006 - Retirar verificacao do crapvia, para copia dos
                          relatorios para o servidor Web (Junior).
                          
             21/11/2006 - Melhoria de performance (Evandro).
             
             07/04/2008 - Alterado o formato do campo "qtpreemp" de "z9" para 
                          "zz9" e da variável "rel_qtprepag" de "z9" para 
                          "zz9".                         
                        - Ajustado posicionamento do campo "qtpreemp" e 
                          variável "rel_qtprepag" nas colunas
                          do form - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
             09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                          glb_cdcooper) no "find" da tabela CRAPHIS. 
                        - Kbase IT Solutions - Paulo Ricardo Maciel.

                        - Incluir relacao dos debitos a serem efetuados de 
                          capital a integralizar no final do relatorio 031
                          (Gabriel).
                          
             16/10/2008 - Incluido campo com valor de Desconto de Titulos no
                          relatorio 398 (Elton).
             
             01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
             
             11/12/2008 - Acerto para o Desconto de Titulos (Evandro).

             11/03/2009 - Alterar formato do campo crapass.vledvmto (Gabriel).
             
             05/05/2009 - Ajustes na leitura de desconto de titulos(Guilherme).
             
             10/06/2010 - Incluido tratamento para pagamento atraves de TAA 
                          (Elton).
                          
             27/04/2012 - Substituido o campo crapepr.qtprepag por 
                          crapepr.qtprecal. (David Kruger).

             06/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                          procedure (Andre Santos - SUPERO)
                          
             05/07/2018 - Projeto Revitalização Sistemas - Rodrigo Andreatta (MOUTs)      
                             
             20/02/2019 - Inclusao de log de fim de execucao do programa 
                          (Belli - Envolti - Chamado REQ0039739)       
                          
............................................................................ */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps010"
       glb_flgbatch = FALSE
       glb_cdcritic = 0
       glb_dscritic = "".

RUN fontes/iniprg.p.
      
IF   glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
    QUIT.
END.
     
ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps010 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT 0,
    INPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps010 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps010.pr_cdcritic WHEN pc_crps010.pr_cdcritic <> ?
       glb_dscritic = pc_crps010.pr_dscritic WHEN pc_crps010.pr_dscritic <> ?
       glb_stprogra = IF pc_crps010.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps010.pr_infimsol = 1 THEN TRUE ELSE FALSE.
        
IF glb_cdcritic <> 0   OR
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

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS010.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 912,
    input "912 - FINALIZADO LEGAL",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS010.P",
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

