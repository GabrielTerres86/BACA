/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps389.p                | pc_crps389                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/    

/* ..........................................................................

   Programa: Fontes/crps389.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2004                      Ultima atualizacao: 25/03/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001.
               Efetuar os debitos do parcelamento da subscricao de capital.
               Emite relatrio 345.

   Alteracoes: 09/06/2004 - Cancelar o debito de subscricao para demitidos no
                            final do mes (Edson).
               
               22/09/2004 - Incluidos historicos 498/500(CI)(Mirtes)
               
               01/07/2005 - Alimentado campo cdcooper das tabelas craprej,
                            craplot, craplcm e craplct (Diego).

               15/07/2005 - Calculo do abono da cpmf deve enxergar a data
                            de inicio, tab_dtiniabo. Usa craplcm.dtrefere
                            com craprda.dtmvtolt para pegar se lancamento com
                            abono ou nao (Margarete).

               11/10/2005 - Alterado para gerar arquivos separados por PAC
                            (Diego).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               17/05/2006 - Alterado numero de vias do relatorio para
                            Viacredi (Diego).
                            
               11/09/2006 - Efetuado acerto para enviar relatorio de todos os
                            PACS a Intranet (Diego).
                            
               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
                            
               21/12/2011 - Aumentado o format do campo cdhistor
                            de "999" para "9999" (Tiago).         
                            
               02/08/2013 - Alterado para pegar o telefone da tabela 
                            craptfc ao invés da crapass (James).
               
               01/10/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               12/11/2013 - Alterado totalizador de PAs de 99 para 999.
                           (Reinert)  
                           
               22/01/2014 - Incluir VALIDATE craprej, craplot, craplcm,
                            craplct (Lucas R.)
                  
               14/05/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andrino - RKAM)
                            
               25/03/2015 - Ajustado para usar RETURN e nao QUIT (Daniel). 

............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps389"
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

RUN STORED-PROCEDURE pc_crps389 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps389 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps389.pr_cdcritic WHEN pc_crps389.pr_cdcritic <> ?
       glb_dscritic = pc_crps389.pr_dscritic WHEN pc_crps389.pr_dscritic <> ?
       glb_stprogra = IF pc_crps389.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps389.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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

