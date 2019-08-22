/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps010_3.p              | pc_crps010.pc_crps010_3           |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

*******************************************************************************/



/* ..........................................................................

   Programa: Fontes/crps010_3.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Maio/2005.                          Ultima atualizacao: 06/09/2013
  
   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Gerar relatorio 421.

   Alteracoes: 20/06/2005 - Alterado para mostrar no relatorio a quantidade de
                            contas duplicadas (Diego).

               04/07/2005 - Imprimir o relatorio 421 em duplex (Edson).

               27/07/2005 - Alterado glb_nrcopias para 2 (Diego).
                                                                  
               12/08/2005 - Gerar um arquivo detalhado, com as contas de cada
                            motivo, para Leticia - VIACREDI (Evandro).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder             

               18/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)

               21/02/2013 - Alterado o format do label "Quantidade" e do
                            label "Total de saidas de socios do Pac"
                            (Daniele).     
               
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).                      
............................................................................ */

DEF STREAM str_1.  /* Para o arquivo de importacao */
DEF STREAM str_4.  /* Para o relatorio */

{ includes/var_batch.i }

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEF   VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEF   VAR aux_contador AS INT                                        NO-UNDO.
DEF   VAR aux_nmmesref AS CHAR                                       NO-UNDO.

DEF   VAR rel_dsagenci AS CHAR                                       NO-UNDO.
DEF   VAR rel_dsmotdem AS CHAR                                       NO-UNDO.
DEF   VAR rel_nmmesref AS CHAR                                       NO-UNDO.

DEF   VAR rel_qtmotdem AS INT                                        NO-UNDO.
DEF   VAR rel_qtdempac AS INT                                        NO-UNDO.
DEF   VAR rel_qttotmot AS INT   EXTENT 11                            NO-UNDO.
DEF   VAR rel_qttotger AS INT                                        NO-UNDO.
DEF   VAR rel_qttotdup AS INT                                        NO-UNDO.

/* variaveis para includes/cabrel080_1.i */
DEF   VAR rel_nmresemp  AS CHAR FORMAT "x(15)"                       NO-UNDO.
DEF   VAR rel_nmrelato  AS CHAR FORMAT "x(40)" EXTENT 5              NO-UNDO.
DEF   VAR rel_nrmodulo  AS INT  FORMAT "9"                           NO-UNDO.

DEF SHARED TEMP-TABLE w_demitidos
           FIELD cdagenci LIKE crapass.cdagenci
           FIELD nrdconta LIKE crapass.nrdconta
           FIELD cdmotdem LIKE crapass.cdmotdem
           FIELD inmatric LIKE crapass.inmatric
           INDEX w_demitidos1 AS PRIMARY cdagenci nrdconta.

FORM rel_nmmesref LABEL "REFERENCIA"      FORMAT "x(15)"
     WITH NO-BOX NO-LABEL CENTERED SIDE-LABELS FRAME f_referencia.

FORM rel_dsagenci LABEL "PA"   FORMAT "x(20)"
     WITH NO-LABELS SIDE-LABELS COLUMN 15 FRAME f_pac.
     
FORM rel_dsmotdem LABEL "MOTIVO"        FORMAT "x(30)" 
     rel_qtmotdem LABEL "QUANTIDADE"    FORMAT "zzz,zz9"  /*z,zz9*/
     WITH DOWN NO-LABEL COLUMN 20 FRAME f_motivos.
     
FORM rel_qtdempac LABEL "TOTAL DE SAIDAS DE SOCIOS DO PA"  FORMAT "zzz,zz9" /*z,zz9*/
     SKIP(1)
     WITH NO-LABELS SIDE-LABELS COLUMN 20 FRAME f_total_pac.

FORM rel_qttotdup LABEL "CONTAS DUPLICADAS"  FORMAT "z,zz9"
     WITH NO-LABELS SIDE-LABELS COLUMN 37 FRAME f_total_dup.                    

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     RETURN.  /* Retorna para o crps010.p */

ASSIGN glb_cdempres = 11
       rel_qtmotdem = 0
       rel_qtdempac = 0
       rel_qttotdup = 0
       aux_nmmesref = "JANEIRO/,FEVEREIRO/,MARCO/,ABRIL/,MAIO/,JUNHO/,JULHO/," +
                      "AGOSTO/,SETEMBRO/,OUTUBRO/,NOVEMBRO/,DEZEMBRO/"
       rel_nmmesref = ENTRY(MONTH(glb_dtmvtolt),aux_nmmesref) +
                      STRING(YEAR(glb_dtmvtolt),"9999").

OUTPUT STREAM str_4 TO VALUE("rl/crrl421.lst") PAGE-SIZE 84.

/* Arquivo para importacao em EXCEL */
OUTPUT STREAM str_1 TO VALUE("rl/crrl421.txt").

PUT STREAM str_1 "PA;MOTIVO;CONTA/DV" SKIP.

{ includes/cabrel080_4.i }

VIEW STREAM str_4 FRAME f_cabrel080_4.

DISPLAY STREAM str_4 rel_nmmesref WITH FRAME f_referencia.

FOR EACH w_demitidos BREAK BY w_demitidos.cdagenci
                              BY w_demitidos.cdmotdem
                                 BY w_demitidos.nrdconta:
   
    
    /* descricao do PA */
    IF   FIRST-OF(w_demitidos.cdagenci)   THEN
         DO:
            IF   LINE-COUNTER(str_4) > (PAGE-SIZE(str_4) - 5)   THEN
                 DO:
                     PAGE STREAM str_4.

                     DISPLAY STREAM str_4 rel_nmmesref WITH FRAME f_referencia.
                 END.
            
            FIND crapage WHERE crapage.cdcooper = glb_cdcooper          AND
                               crapage.cdagenci = w_demitidos.cdagenci 
                               NO-LOCK NO-ERROR.
                               
            IF   AVAILABLE crapage   THEN
                 rel_dsagenci = STRING(crapage.cdagenci,"z9") + " - " +
                                crapage.nmresage.
            ELSE
                 rel_dsagenci = STRING(crapage.cdagenci,"z9") + " - " +
                                "NAO ENCONTRADA".

            DISPLAY STREAM str_4 rel_dsagenci 
                                 WITH FRAME f_pac.
            
         END.    
                                                                        
    PUT STREAM str_1 w_demitidos.cdagenci FORMAT "zz9" ";"
                     w_demitidos.cdmotdem FORMAT "z9"  ";"
                     w_demitidos.nrdconta FORMAT "zzzz,zzz,9" SKIP.
                   
    IF   w_demitidos.inmatric = 2   THEN
         DO: 
             ASSIGN rel_qttotdup = rel_qttotdup + 1.
         END.
         
    ASSIGN rel_qtmotdem = rel_qtmotdem + 1
           rel_qtdempac = rel_qtdempac + 1.

    /* total por motivo */
    IF   LAST-OF(w_demitidos.cdmotdem)   THEN
         DO:
             RUN fontes/le_motivo_demissao.p (INPUT  glb_cdcooper,
                                              INPUT  w_demitidos.cdmotdem,
                                              OUTPUT rel_dsmotdem,
                                              OUTPUT glb_cdcritic).

             rel_dsmotdem = STRING(w_demitidos.cdmotdem,"z9") + " - " +
                            rel_dsmotdem.
             
             DISPLAY STREAM str_4 rel_dsmotdem 
                                  rel_qtmotdem WITH FRAME f_motivos.
                     
             DOWN STREAM str_4 WITH FRAME f_motivos.
             
             ASSIGN rel_qttotmot[w_demitidos.cdmotdem] = 
                                 rel_qttotmot[w_demitidos.cdmotdem] + 
                                 rel_qtmotdem
                    rel_qtmotdem = 0.
         END.
    
    /* total do PA */
    IF   LAST-OF(w_demitidos.cdagenci)   THEN
         DO:
            DISPLAY STREAM str_4 rel_qtdempac WITH FRAME f_total_pac.
            
            ASSIGN rel_qtdempac = 0.
            
         END.     

END.

/* total geral dos motivos */
PAGE STREAM str_4.

DISPLAY STREAM str_4 rel_nmmesref WITH FRAME f_referencia.

DISPLAY STREAM str_4 "******** TOTAL GERAL POR MOTIVO *********"
               WITH NO-LABELS COLUMN 20 FRAME f_geral.

rel_qttotger = 0.
DO aux_contador = 1 TO 11:

   RUN fontes/le_motivo_demissao.p (INPUT  glb_cdcooper,
                                    INPUT  aux_contador,
                                    OUTPUT rel_dsmotdem,
                                    OUTPUT glb_cdcritic).
   
   rel_dsmotdem = STRING(aux_contador,"z9") + " - " + rel_dsmotdem.

   DISPLAY STREAM str_4 rel_dsmotdem 
                        rel_qttotmot[aux_contador] @ rel_qtmotdem
                        WITH FRAME f_motivos.
                        
   DOWN STREAM str_4 WITH FRAME f_motivos.                        

   rel_qttotger = rel_qttotger + rel_qttotmot[aux_contador].
END.

DISPLAY STREAM str_4 "                         TOTAL" @ rel_dsmotdem
                     rel_qttotger                     @ rel_qtmotdem
                     WITH FRAME f_motivos.

/* Total de Contas duplicadas*/
DISPLAY STREAM str_4
                     rel_qttotdup   WITH FRAME f_total_dup.
                     
OUTPUT STREAM str_1 CLOSE.
OUTPUT STREAM str_4 CLOSE.

/* impressao do relatorio */
ASSIGN glb_nmarqimp = "rl/crrl421.lst"
       glb_nmformul = "80d"
       glb_nrcopias = 2.
           
RUN fontes/imprim.p.

/* Envio do arquivo detalhado via e-mail */
IF   glb_cdcooper = 1    THEN
     DO:
           /* Move para diretorio converte para utilizar na BO */
           UNIX SILENT VALUE 
                      ("cp " + "rl/crrl421.txt" + " /usr/coop/" +
                       crapcop.dsdircop + "/converte" + 
                       " 2> /dev/null").
  
           /* Envia o arquivo por e-mail */
           RUN sistema/generico/procedures/b1wgen0011.p
           PERSISTENT SET b1wgen0011.
             
           RUN enviar_email IN b1wgen0011
                                (INPUT glb_cdcooper,
                                 INPUT glb_cdprogra,
                                 INPUT "viacredi@viacredi.coop.br",
                                 INPUT "RELATORIO 421 - DETALHADO ",
                                 INPUT "crrl421.txt",
                                 INPUT TRUE).
                                   
           DELETE PROCEDURE b1wgen0011.                           
     END.
      
/* .......................................................................... */

