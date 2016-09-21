/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps345.p                | pc_crps345                        |
  +---------------------------------+-----------------------------------+
  
   TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 25/MAR/2015 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - IRLAN CHEQUER MAIA  (CECRED)
   - MARCOS MARTINI      (SUPERO)

******************************************************************************/
/* ..........................................................................

   Programa: Fontes/crps345.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson                                                    
   Data    : Junho/2003                        Ultima atualizacao: 13/02/2015
                                                                          
   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 002.
               Lista descontos de cheques do dia (290).

   Alteracoes: 22/04/2004 - Acrescentar mais uma via no rel. 225 (Eduardo).
   
               13/08/2004 - Modificar relatorio para duplex (Ze Eduardo).
               
               30/09/2004 - Gravacao de dados na tabela gninfpl do banco
                            generico, para relatorios gerenciais (Junior).

               28/10/2004 - Colocado novos campos no relatorio: quantidade de
                            cheques e valor medio (Edson).
               
               02/05/2005 - Remover gravacao de dados na tabela gninfpl, para
                            relatorios gerenciais (Junior).

               04/05/2005 - Ajuste de indices da leitura dos borderos (Edson).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               03/10/2005 - Alterado para imprimir apenas uma copia para
                            CredCrea (Diego).
                            
               30/01/2006 - Imprimir uma unica via para CREDIFIESC (Evandro).
               
               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               17/05/2006 - Alterado numero de vias do relatorio para
                            Viacredi (Diego).
               15/08/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero). 
                            
               13/02/2015 - Ajustado estouro de format do numero do bordero (Daniel) 
               
               25/03/2015 - Conversao Progress >> Oracle (Reinert)
............................................................................. */

DEF STREAM str_1.     /*  Para descontos de cheques no dia  */

{ includes/var_batch.i "NEW" }

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.

DEF        VAR rel_qtcheque AS INT                                   NO-UNDO.
DEF        VAR rel_vlborder AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vlliquid AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vldjuros AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vlmedchq AS DECIMAL                               NO-UNDO.

DEF        VAR tot_qtcheque AS INT                                   NO-UNDO.
DEF        VAR tot_vlborder AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vlliquid AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vldjuros AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vlmedchq AS DECIMAL                               NO-UNDO.

DEF        VAR ger_qtcheque AS INT                                   NO-UNDO.
DEF        VAR ger_vlborder AS DECIMAL                               NO-UNDO.
DEF        VAR ger_vlliquid AS DECIMAL                               NO-UNDO.
DEF        VAR ger_vldjuros AS DECIMAL                               NO-UNDO.
DEF        VAR ger_vlmedchq AS DECIMAL                               NO-UNDO.

glb_cdprogra = "crps345".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

FORM "PA"           AT   1
     "CONTA/DV"      AT   8
     "NOME"          AT  17
     "CONTRATO"      AT  54
     "BORDERO"       AT  66
     "QTD."          AT  75
     "VALOR BRUTO"   AT  81
     "VALOR LIQUIDO" AT  93
     "VALOR JUROS"   AT 108
     "VALOR MEDIO"   AT 122
     SKIP(1)
     WITH NO-BOX WIDTH 132 FRAME f_label.

FORM crapbdc.cdagenci AT   1 FORMAT "zz9"
     crapbdc.nrdconta AT   6 FORMAT "zzzz,zzz,9"
     crapass.nmprimtl AT  17 FORMAT "x(35)"
     crapbdc.nrctrlim AT  53 FORMAT "z,zzz,zz9"
     crapbdc.nrborder AT  64 FORMAT "z,zzz,zz9"
     rel_qtcheque     AT  73 FORMAT "zz,zz9"
     rel_vlborder     AT  79 FORMAT "zz,zzz,zz9.99"
     rel_vlliquid     AT  93 FORMAT "zz,zzz,zz9.99"
     rel_vldjuros     AT 107 FORMAT "z,zzz,zz9.99"
     rel_vlmedchq     AT 120 FORMAT "zz,zzz,zz9.99"
     WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABEL WIDTH 132 FRAME f_desconto.

FORM SKIP(1)
     "TOTAL DO PA ==>" AT  17
     tot_qtcheque       AT  73 FORMAT "zz,zz9"
     tot_vlborder       AT  79 FORMAT "zz,zzz,zz9.99"
     tot_vlliquid       AT  93 FORMAT "zz,zzz,zz9.99"
     tot_vldjuros       AT 107 FORMAT "z,zzz,zz9.99"
     tot_vlmedchq       AT 120 FORMAT "zz,zzz,zz9.99"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_totais.

FORM "TOTAL GERAL ==>"  AT  17
     ger_qtcheque       AT  73 FORMAT "zz,zz9"
     ger_vlborder       AT  79 FORMAT "zz,zzz,zz9.99"
     ger_vlliquid       AT  93 FORMAT "zz,zzz,zz9.99"
     ger_vldjuros       AT 107 FORMAT "z,zzz,zz9.99"
     ger_vlmedchq       AT 120 FORMAT "zz,zzz,zz9.99"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_geral.

{ includes/cabrel132_1.i }

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

OUTPUT STREAM str_1 TO rl/crrl290.lst PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

VIEW STREAM str_1 FRAME f_label.

FOR EACH crapbdc WHERE crapbdc.cdcooper = glb_cdcooper  AND
                       crapbdc.dtlibbdc = glb_dtmvtolt  USE-INDEX crapbdc3
                       BREAK BY crapbdc.cdagenci
                                BY crapbdc.nrdconta
                                   BY crapbdc.nrborder:

    ASSIGN rel_vlborder = 0
           rel_vlliquid = 0
           rel_vldjuros = 0
           rel_qtcheque = 0.
           
    FOR EACH crapcdb WHERE crapcdb.cdcooper = glb_cdcooper      AND
                           crapcdb.nrborder = crapbdc.nrborder  AND
                           crapcdb.nrdconta = crapbdc.nrdconta 
                           USE-INDEX crapcdb7 NO-LOCK:
                           
        IF   crapcdb.dtdevolu <> ?   THEN
             NEXT.
           
        ASSIGN rel_qtcheque = rel_qtcheque + 1
               rel_vlborder = rel_vlborder + crapcdb.vlcheque
               rel_vlliquid = rel_vlliquid + crapcdb.vlliquid
               rel_vldjuros = rel_vldjuros + (crapcdb.vlcheque -
                                                      crapcdb.vlliquid).
    
    END.  /*  Fim do FOR EACH -- crapcdb  */
    
    ASSIGN tot_vlborder = tot_vlborder + rel_vlborder
           tot_vlliquid = tot_vlliquid + rel_vlliquid
           tot_vldjuros = tot_vldjuros + rel_vldjuros
           tot_qtcheque = tot_qtcheque + rel_qtcheque
           
           ger_vlborder = ger_vlborder + rel_vlborder
           ger_vlliquid = ger_vlliquid + rel_vlliquid
           ger_vldjuros = ger_vldjuros + rel_vldjuros
           ger_qtcheque = ger_qtcheque + rel_qtcheque.
           
    IF   rel_qtcheque > 0   THEN
         DO:
             rel_vlmedchq = TRUNCATE(rel_vlborder / rel_qtcheque,2).
    
             /* FIND crapass OF crapbdc NO-LOCK NO-ERROR. */
             FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                crapass.nrdconta = crapbdc.nrdconta
                                NO-LOCK NO-ERROR.
    
             DISPLAY STREAM str_1
                     crapbdc.cdagenci  crapbdc.nrdconta  crapass.nmprimtl
                     crapbdc.nrctrlim  crapbdc.nrborder  rel_qtcheque
                     rel_vlborder      rel_vlliquid      rel_vldjuros
                     rel_vlmedchq
                     WITH FRAME f_desconto.

             DOWN STREAM str_1 WITH FRAME f_desconto.
       
             IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                  DO:
                      PAGE STREAM str_1.
                      VIEW STREAM str_1 FRAME f_label.
                  END.
         END.
         
    IF   NOT LAST-OF(crapbdc.cdagenci)   THEN
         NEXT.
    
    IF   tot_qtcheque > 0   THEN
         DO:
             tot_vlmedchq = TRUNCATE(tot_vlborder / tot_qtcheque,2).
    
             DISPLAY STREAM str_1 
                     tot_qtcheque  tot_vlborder  
                     tot_vlliquid  tot_vldjuros
                     tot_vlmedchq
                     WITH FRAME f_totais.
         END.
         
    ASSIGN tot_vlborder = 0        
           tot_vlliquid = 0
           tot_vldjuros = 0
           tot_qtcheque = 0.
    
END.  /*  Fim do FOR EACH  */

ger_vlmedchq = TRUNCATE(ger_vlborder / ger_qtcheque,2).
 
DISPLAY STREAM str_1
        ger_qtcheque ger_vlborder ger_vlliquid ger_vldjuros ger_vlmedchq 
        WITH FRAME f_geral.

OUTPUT STREAM str_1 CLOSE.

IF   glb_cdcooper = 6   OR
     glb_cdcooper = 7   OR
     glb_cdcooper = 1  THEN
     ASSIGN glb_nrcopias = 1.
ELSE
     ASSIGN glb_nrcopias = 3.

ASSIGN glb_nmformul = "132dm"
       glb_nmarqimp = "rl/crrl290.lst".

RUN fontes/imprim.p.

RUN fontes/fimprg.p.

/* .......................................................................... */



