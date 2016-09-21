/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+---------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                   |
  +---------------------------------+---------------------------------------+
  |                                 |                                       |
  |      crps419.p                  |        pc_crps419                     |
  |                                 |                                       | 
  +---------------------------------+---------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - IRLAN CHEQUER MAIA    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/* ..........................................................................
   
   Programa: fontes/crps419.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro/Diego
   Data    : Abril/2006                   Ultima atualizacao: 15/06/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 99.
               Gerar arquivo com LIMITES DE DEBITO dos associados para enviar 
               ao B. Brasil (COO401).

   Alteracoes: 22/05/2006 - Incluido codigo da cooperativa nas leituras das
                            tabelas (Diego).
   
               29/05/2006 - Efetuado acerto limite (Mirtes)
               
               30/06/2006 - Modificado aux_vllimdeb para INTEGER (Diego).
               
               25/07/2006 - Incluida verificacao de bloqueio e mensagem para
                            enviar arquivo (Evandro).
                            
               26/07/2007 - Saldo disponivel do dia - BO(b1wgen0001)(Guilherme).
              
               20/05/2008 - Calcular dia valido para dtlimdeb (Guilherme).
               
               23/06/2010 - Ajustar tt-saldo para o TAA (Magui).

               22/09/2010 - Foi feito a retirada de temp-table e chamado
                            a BO b1wgen0001tt.i (Adriano).
            
               12/01/2011 - Inserido o format de 40 para o campo nmprimtl
                            (Kbase - Gilnei)
                            
               24/04/2012 - Inserido procedure gera_limite_debito_bb
                            (David Kruger).
               
               29/10/2012 - Ajustes para migracao contas Altovale (Tiago).
                            
               04/01/2013 - Incluido condicao (craptco.tpctatrf <> 3) na busca
                            da craptco (Tiago).    
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).      
                            
               16/12/2013 - Ajuste migração Acredi. (Rodrigo)      
               
               27/02/2014 - Incluir tratamento para o limite do debito para o 
                            feriado do carnaval (Lucas R.) 
               
               11/09/2014 - Ajustes devido a migracao Concredi e Credimilsul
                            (Odirlei/Amcom).             
                            
               25/11/2014 - Alterada quantidade de dias limite devido vencimento
                            de contrato BB (Rodrigo).
                            
               26/11/2014 - Tratamento pra incorporação da credimilsul,
                            para permitir apos a incorporacao gerar o arquivo na
                            credimilsul, porem lendo as informações na SCRcred
                            (Odirlei-Amcom)
                            
               28/11/2014 - Retornada quantidade de dias limite devido 
                            prorrogacao do vencimento contrato BB (Rodrigo).
                            
               23/12/2014 - Ajuste para quando for executado pela 15-Credimilsul             
                            buscar a data da nova cooperativa 13-SCrcred(Odirlei-AMcom)
               
               15/06/2015 - Adaptaçao fonte hibrido progress -> Oracle 
                            (Odirlei-AMcom)              
                            
............................................................................ */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }


DEF STREAM str_1.

DEF     VAR aux_nmarqimp AS CHAR      FORMAT "x(50)"                 NO-UNDO.
DEF     VAR aux_nmarqrel AS CHAR      FORMAT "x(50)"                 NO-UNDO.
DEF     VAR aux_nrtextab AS INT                                      NO-UNDO.
DEF     VAR aux_nrregist AS INT                                      NO-UNDO.
DEF     VAR aux_dsdlinha AS CHAR      FORMAT "x(70)"                 NO-UNDO.
DEF     VAR aux_nrdctitg LIKE crapass.nrdctitg                       NO-UNDO.
DEF     VAR aux_digctitg AS CHAR                                     NO-UNDO.
DEF     VAR aux_vltotlim AS INTE                                     NO-UNDO.
DEF     VAR aux_contador AS INT                                      NO-UNDO.
DEF     VAR aux_dtlimdeb AS DATE                                     NO-UNDO.
DEF     VAR aux_vllimdeb AS INT                                      NO-UNDO.
DEF     VAR aux_contdias AS INTE                                     NO-UNDO.
DEF     VAR aux_valortot AS DECI                                     NO-UNDO.
DEF     VAR aux_cdcooper LIKE crapcop.cdcooper                       NO-UNDO.
DEF     VAR aux_nrdconta LIKE crapass.nrdconta                       NO-UNDO.

DEF     VAR aux_data AS DATE                                         NO-UNDO.
/* nome do arquivo de log */
DEF     VAR aux_nmarqlog      AS CHAR                                NO-UNDO.

DEF     VAR rel_nmempres AS CHAR      FORMAT "x(15)"                 NO-UNDO.
DEF     VAR rel_nmresemp AS CHAR      FORMAT "x(15)"                 NO-UNDO.

DEF     VAR rel_nmrelato AS CHAR      FORMAT "x(40)" EXTENT 5        NO-UNDO.
DEF     VAR rel_nrmodulo AS INT       FORMAT "9"                     NO-UNDO.
DEF     VAR rel_nmmodulo AS CHAR      FORMAT "x(15)" EXTENT 5
                            INIT ["DEP. A VISTA   ","CAPITAL        ",
                                  "EMPRESTIMOS    ","DIGITACAO      ",
                                  "GENERICO       "]                 NO-UNDO.

DEF     VAR h-b1wgen0001      AS HANDLE                              NO-UNDO.
DEF     VAR aux_flglau AS INT INIT 0                                 NO-UNDO.


ASSIGN glb_cdprogra = "crps419"
       glb_flgbatch = FALSE
       aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".
 
RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps419 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps419 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps419.pr_cdcritic WHEN pc_crps419.pr_cdcritic <> ?
       glb_dscritic = pc_crps419.pr_dscritic WHEN pc_crps419.pr_dscritic <> ?
       glb_stprogra = IF pc_crps419.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps419.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


/*...........................................................................*/
