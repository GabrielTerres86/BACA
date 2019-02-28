/* ............................................................................

   Programa: Fontes/crps392.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Abril/2004.                     Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Trimestral (Batch - Background).
   Objetivo  : Emite: extratos rdca/poup.progr. trimestral na laser (351).
               Solicitacao: 96
               Ordem: 73
               Relatorio: 351
               Tipo Documento: 9
               Formulario: Extrato-trimapl.
                
   Alteracoes: 22/09/2004 -Incluidos historicos 492/493/494/495/496(CI)(Mirtes)

               05/10/2004 - Incluido Conta de Investimento, aumentado o
                            tamanho do campo Nro da Aplicacao e incluidos
                            historicos 482, 484, 485, 486, 487, 488, 489, 
                            490, 491  (Evandro). 
               09/02/2005 - Incluidos historicos 647/648(Conta investimento)
                            (Mirtes)
               22/03/2005 - Retirado Lancamentos Conta Investimento(Mirtes)

               29/04/2005 - Mudado para gerar os arquivos no "rl/";
                            Incluido o nro do dacastro do cooperado na empresa
                            (Evandro).
                            
               31/03/2006 - Concertada clausula OR do FOR EACH, pondo entre
                            parenteses (Diego).

               26/07/2006 - Campo vlslfmes substituido por vlsdextr (Magui).

               01/08/2006 - Incluida verificacao do tpemiext referente aos
                            lancamentos das tabelas craplap e craplpp (David).
                            
               09/04/2007 - Alterado de FormXpress para FormPrint (Diego)
                            
               30/05/2007 - Chamada do programa 'fontes/gera_formprint.p'
                            para executar a geracao e impressao dos
                            formularios em background (Julio)

               22/06/2007 - Alterado para somente verificar as aplicacoes RDCA30
                            e RDCA60 (Elton).
               
               31/10/2007 - Usar nmdsecao a partir do ttl.nmdsecao (Guilherme).
               
               29/05/2008 - alterado para nao emitir extrato poup.prog. qdo 
                            situacao = 5 (resg. pelo vcto) - Rosangela
               
               20/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "for each" da tabela CRAPHIS.
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               06/02/2009 - Movida definicao da variavel aux_nmdatspt para
                            includes/var_informativos.i (Diego).
                            
               03/04/2012 - Substituir nmrescop por dsdircop no 
                            fontes/gera_formprint.p (ZE).

               10/10/2013 - Chamada Stored Procedure do Oracle
                            (Andre Euzebio / Supero)
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)
						   
............................................................................. */

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }


ASSIGN glb_cdprogra = "crps392"
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

RUN STORED-PROCEDURE pc_crps392 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INT(STRING(glb_flgresta,"1/0")),
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

CLOSE STORED-PROCEDURE pc_crps392 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps392.pr_cdcritic WHEN pc_crps392.pr_cdcritic <> ?
       glb_dscritic = pc_crps392.pr_dscritic WHEN pc_crps392.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps392.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps392.pr_infimsol = 1 THEN
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

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS392.P",
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
    INPUT "CRPS392.P",
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

