/* ..........................................................................

   Programa: Fontes/crps314.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Junior.
   Data    : Julho/2001                          Ultima atualizacao: 22/07/2013

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 002.
               Listar os lotes de contratos de emprestimo.
               Emite relatorio 266.

               24/06/2003 - Dividir em duas listas <= f2000 (Margarete).
               
               16/07/2003 - Alterada o nro de copias do relatorio 266 de 
                            1 para 2 (Julio).

               22/07/2003 - Substituicao do valor fixo de 2000, pela variavel
                            aux_dstextab, no valor max do contrato (Julio).
               
               23/07/2003 - Separacao do relatorio por PAC (Julio)

               12/03/2004 - Listar Lotes Contratos Limite Desconto de Cheques e
                            Lote Borderos(Mirtes).

               19/03/2004 - Nao paginar por Lote(Lancamentos Borderos)(Mirtes)
               
               22/04/2004 - Incluir mais uma faixa (Margarete).
               
               28/05/2004 - Alterado o FORMAT do valor total de emprestimos
                            (Julio)

               10/08/2004 - Imprimir somente borderos de desconto
                            liberados (Margarete).
                            
               28/02/2005 - Controle de quebras a partir da tabela "crapage";
                            Imprimir tambem "Controle de proposta/limite de
                            credito" (Evandro).
                            
               01/03/2005 - Acerto no programa (Ze).
               
               14/03/2005 - Imprimir tambem "LIMITES DE CARTAO DE CREDITO"
                            (Evandro).
                            
               14/04/2005 - Corrigido o FOR EACH da procedure 
                            limite_cartao_cred (Evandro).
                            
               07/06/2005 - Nao gerar mais pedido de impressao para a VIACREDI
                            (Edson).

               28/07/2005 - Alterado para mostrar no relatorio 266  borderos   
                            separados entre > e < de  R$ 2.000,00 (Diego).
                            
               19/09/2005 - Alterado para imprimir relatorio separadamente 
                            para Viacredi (Diego).

               03/10/2005 - Alterado para imprimir apenas uma copia para
                            CredCrea (Diego).

               11/10/2005 - Acerto no relatorio crrl26699 (Diego).

               01/11/2005 - Relacionar Contrato Cartao no PAC do 
                            cooperado(Mirtes)

               23/11/2005 - Alterado numero de vias e formulario para 
                            impressao de relatorio na Viacredi (Diego).

               30/01/2006 - Alterando layout relatorio crrl26699 (Diego).
               
               31/03/2006 - Corrigir nome do relatorio crrl26699 para 
                            crrl266_99, e corrigir rotina de impressao de
                            relatorios por agencia (Junior).
                            
               13/06/2008 - Alterações para melhorias de performance (Julio)

               09/07/2008 - Alterado valor da variavel "aux_dstextb2" no caso
                            de nao receber dados da craptab (Elton).
                            
               14/10/2008 - Incluido tratamento para Desconto de Titulos
                            (Diego).
                            
               08/01/2009 - Efetuado acerto na leitura da tabela craplot, 
                            procedure -> processa_limite_desconto (Diego).

               13/01/2011 - Alterada a posicao das colunas para acomodar o 
                            campo nmprimtl (Kbase - Gilnei)
                            
               14/07/2011 - Sera gerado crrl26699 para demais cooperativas alem
                            da Viacredi (Adriano).             
               
               16/10/2012 - Incluir linha DIGITALIZADOS no frame f_confvist
                            (Lucas R.).
               
               22/07/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
              
.............................................................................*/
   
{includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps314"
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

RUN STORED-PROCEDURE pc_crps314 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps314 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps314.pr_cdcritic WHEN pc_crps314.pr_cdcritic <> ?
       glb_dscritic = pc_crps314.pr_dscritic WHEN pc_crps314.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps314.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps314.pr_infimsol = 1 THEN
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
                  
RUN fontes/fimprg.p.

/* .......................................................................... */