/* ..........................................................................
   
   Programa: Fontes/crps414.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Junior
   Data    : Outubro/2004.                   Ultima atualizacao: 07/06/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Gerar informacoes sobre emprestimos, cotas, desconto de cheques,
               aplicacoes, para os relatorios gerenciais.

   Alteracoes: 07/12/2004 - Incluir gravacao de dados no campo vldcotas da
                            tabela gntotpl (Valor de cotas das Cooperativas na
                            CECRED) (Junior).
                            
               16/02/2005 - Buscar o saldo RDCA das Cooperativas na CECRED,
                            para gravar na tabela gntotpl (campo vlrdca30)
                            (Junior).
                            
               14/03/2005 - Buscar o total de cheques descontados por agencia,
                            para gravar na tabela gninfpl (campo vltotdsc)
                            (Junior).
               11/04/2005 - Verificar qdo mensal, obter saldo tabela
                            crapepr(Mirtes).
                            
              05/09/2005 - Gravacao de dados de RDCA30 e RDCA60 por PAC
                           na tabela gninfpl do banco generico (Junior).
                           
              23/09/2005 - Modificado FIND FIRST para FIND na tabela
                           crapcop.cdcooper = glb_cdcooper (Diego).
                           
              17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
              
              04/10/2006 - Alteracao na rotina de soma de desconto de cheques,
                           para considerar os valores por cooperado e nao por
                           PAC (Junior).

              09/08/2007 - Efetuar tratamento para aplicacoes RDC (David).
              
              19/11/2007 - Substituir chamada da include aplicacao.i pela
                           BO b1wgen0004.i. (Sidnei - Precise).

              30/09/2008 - Alimentar o campo gninfpl.vltottit referente ao 
                           desconto de titulos (David).
                           
              13/10/2008 - No total de cotistas, somar apenas as contas com
                           crapass.inmatric = 1 (Junior).
                           
              05/05/2009 - Ajuste na leitura de desconto de titulos(Guilherme).
              
              10/06/2010 - Tratamento para pagamentos feitos atraves de TAA
                           (Elton).

              20/05/2011 - Melhorar performance (Magui).
              
              16/08/2011 - Alterado para rodar em paralelo consigo mesmo,
                           programa crps414_1.p (Evandro).
                           
              14/11/2011 - Aumentada a quantidade de processos paralelos
                          (Evandro).                           
                          
              22/06/2012 - Substituido gncoper por crapcop (Tiago).        
                 
              07/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                           procedure (Andre Santos - SUPERO)
                        
 ............................................................................ */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps414"
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

RUN STORED-PROCEDURE pc_crps414 aux_handproc = PROC-HANDLE
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
        
CLOSE STORED-PROCEDURE pc_crps414 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps414.pr_cdcritic WHEN pc_crps414.pr_cdcritic <> ?
       glb_dscritic = pc_crps414.pr_dscritic WHEN pc_crps414.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps414.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps414.pr_infimsol = 1 THEN
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

/* .......................................................................... */

