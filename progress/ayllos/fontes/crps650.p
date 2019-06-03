/* ............................................................................

   Programa: Fontes/crps650.p
   Sistema : MITRA - GERACAO DE ARQUIVO
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : JULHO/2013                      Ultima atualizacao: 08/05/2019
   
   Dados referentes ao programa:

   Frequencia: Diaria.
   Objetivo  : Gerar diariamente para o sistema MITRA as informações
               referentes as aplicações e operações de credito feitas pelas
               singulares na sua conta na central CECRED.
               
   Alteracoes: 29/08/2013 - Valor do campo financeiro_contabil_bruto
                            alterado para receber o mesmo valor que 
                            tt-dados.pu quando o campo nome for "CCB_CDI - RF".
                            (Reinert)
                            
               09/09/2013 - Valor do campo financeiro_contabil_provisao
                            alterado para receber tt-dados.pu * a porcentagem
                            do nivel de risco quando o campo nome for 
                            "CCB_CDI - RF". (Reinert)
                            
               09/09/2014 - Adicionada procedure pc_busca_aplicacoes_car para
                            tratar as aplicacoes de captacao. (Reinert)
                            
               05/05/2015 - Incluida as informações de emprestimos SD266082
                            (Vanessa).
               
               07/04/2016 - Incluida clausula where filtrando por inliquid
                            diferente de 1 ao buscar os contratos para geracao
                            do arquivo. Conforme solicitado pela Jessica, nao
                            devem aparecer contratos liquidados.
                            Chamado 415453 (Heitor - RKAM)

			   17/04/2017 - Adequacao da rotina para uma nova linha de
							credito. Chamado 595673 (Andrey - MOUTS)

               09/10/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)

			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

               11/01/2019 - PJ298.2.2 - Ajustado campos Pos-Fixado (Rafael Faria - Supero)
               
               21/02/2019 - Ajuste realizado para atender a historia 12912 - Teste de antecipaçao da 
                            parcela – arquivo Mitra do projeto 298.2.2 (Nagasava - Supero)

               08/05/2019 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Renato Darosci - SUPERO)
 .......................................................................... */

{includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps650"
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

RUN STORED-PROCEDURE pc_crps650 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,  
                                                    INPUT glb_cdoperad,
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

CLOSE STORED-PROCEDURE pc_crps650 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps650.pr_cdcritic WHEN pc_crps650.pr_cdcritic <> ?
       glb_dscritic = pc_crps650.pr_dscritic WHEN pc_crps650.pr_dscritic <> ?
       glb_stprogra = IF pc_crps650.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps650.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


