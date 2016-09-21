/* ..........................................................................

   Programa: Fontes/crps535.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme / Precise        
   Data    : Dezembro/2009                   Ultima atualizacao: 02/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Processamento de devolucoes dos depositos em cheques que foram
               devolvidos.
               Emite relatorio 529 e 530.

   Alteracoes: 15/12/2009 - Versao Inicial (Guilherme / Precise)
   
               04/06/2010 - Acertos Gerais (Ze).

               08/06/2010 - Nao ler crapass qdo nao encontrar crapchd (Magui).
               
               15/06/2010 - Nao usar campos de arquivos na procedure
                            pi_cria_generica(Magui).
                            
               16/06/2010 - Acertos Gerais (Ze).       
           
               06/07/2010 - Incluso Validacao para COMPEFORA (Jonatas/Supero)
               
               13/09/2010 - Acerto para geracao do relatorio no diretorio 
                            rlnsv (Vitor)
                            
               10/12/2010 - Incluir Historico 881 - IF Cecred (Ze).
               
               14/01/2011 - Alterado layout do relatorio devido a alteracao 
                            do format do campo nmprimtl (Henrique).
                            
               07/02/2011 - Tratamento de Cheques em Custodia e Contas Trans-
                            ferida - semelhante ao crps360 BB (Ze).
                            
               21/03/2011 - Alterado p/ separar o relatorio 530 por PAC (Vitor)
               
               24/05/2011 - Evitar o duplicates no gncpdev (Ze).
               
               06/06/2011 - Incluido as colunas produto, Lote/Bordero, 
                            Entrada, Liberacao, Nro. Previa (Adriano/Elton).
                            
               07/06/2011 - Para custodia/desconto considerar o PAC do crapcst
                            ou crapcdb (Ze).
                            
               03/08/2011 - Tratamento para LANCHQ (Elton).
               
               25/10/2011 - Incluido coluna "C/ IMAGEM" no relatorio 529
                            (Adriano).
                            
               22/11/2011 - Alterado de NAO para Espacos a inf. da coluna
                            C/Imagem - ate a nova DLL (Ze).
                            
               19/04/2012 - Alteracao de espaco em branco para "NAO" a 
                            informacao da coluna C/Imagem (Elton).
                            
               15/08/2012 - Alterado posigues do gncpdev.cdtipdoc de 52,2 
                            para 148,3 (Lucas R.).
                            
               17/08/2012 - Tratamento cheque VLB (Fabricio).             
               
               20/12/2012 - Adaptacao para Migracao da AltoVale (Ze).
               
               22/04/2013 - Alterar o layout do relatorio 530,reduzido
                            as linhas em branco e inserida tabela no 
                            final da pagina (Daniele).
               
               02/08/2013 - Alterado para pegar o telefone da tabela 
                            craptfc ao invés da crapass (James).

............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }


ASSIGN glb_cdprogra = "crps535"
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

RUN STORED-PROCEDURE pc_crps535 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps535 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps535.pr_cdcritic WHEN pc_crps535.pr_cdcritic <> ?
       glb_dscritic = pc_crps535.pr_dscritic WHEN pc_crps535.pr_dscritic <> ?
       glb_stprogra = IF pc_crps535.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps535.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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

