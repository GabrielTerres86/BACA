/* .............................................................................

   Programa: Fontes/crps463.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego   
   Data    : Janeiro/2006                       Ultima atualizacao: 09/09/2013 
      
   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Gerar listagem de associados com mudanca de endereco.
               Atende a solicitacao 87. Ordem 10.  Emite relatorio 436.

   Alteracoes: 17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
   
               19/06/2006 - Modificados campos referente endereco para 
                            a estrutura crapenc (Diego).

               13/07/2006 - Envio de e-mail para rosangela@cecred.coop.br e 
                            makelly@cecred.coop.br; Inclusao do nr. do cartao
                            no relatorio (David).

               17/07/2006 - Incluido no endereco: Bairro,CEP,Cidade,UF (David).
               
               29/01/2007 - Alterado formato dos campos do tipo DATE para
                            "99/99/9999" (Elton).
                            
               05/07/2007 - Retirado envio de email do crrl436 para o email
                            rosangela@cecred.coop.br (Guilherme).
                            
               01/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
               
               11/03/2009 - Retirado envio de e-mail. (Fernando).
               
               03/02/2010 - Incluido FORMAT "x(40)" para nmprimtl (KBASE). 
               
               25/04/2011 - Aumentado formato do bairro e cidade (Gabriel).
               
               12/11/2012 - Retirar matches dos find/for each (Gabriel).
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
............................................................................ */

DEF STREAM str_1.  

{ includes/var_batch.i "NEW" }

DEF   VAR rel_nmempres AS CHAR    FORMAT "x(15)"                    NO-UNDO.
DEF   VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5           NO-UNDO.

DEF   VAR rel_nrmodulo AS INT     FORMAT "9"                        NO-UNDO.
DEF   VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                  INIT ["DEP. A VISTA   ","CAPITAL        ",
                                        "EMPRESTIMOS    ","DIGITACAO      ",
                                        "GENERICO       "]          NO-UNDO.

DEF   VAR aux_nmarqimp AS CHAR                                      NO-UNDO.
DEF   VAR aux_dtultdia AS DATE    FORMAT "99/99/9999"               NO-UNDO.
DEF   VAR aux_dtpridia AS DATE    FORMAT "99/99/9999"               NO-UNDO.
DEF   VAR aux_dsendres AS CHAR    FORMAT "x(120)"                   NO-UNDO.
DEF   VAR aux_rowidalt AS ROWID                                     NO-UNDO.

FORM SKIP(1)
     crapass.cdagenci  LABEL "PA"
     crapass.nrdconta  LABEL "CONTA/DV"
     crapass.nmprimtl  LABEL "NOME" FORMAT  "x(40)" 
     crawcrd.nrcrcard  LABEL "CARTAO"
     crapalt.dtaltera  LABEL "ALTERACAO"
     SKIP
     "ENDERECO:"
     aux_dsendres      NO-LABEL
     WITH DOWN NO-BOX NO-LABEL WIDTH 132 FRAME f_enderecos.

ASSIGN glb_cdprogra = "crps463"
       aux_nmarqimp = "rl/crrl436.lst".

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0   THEN
    QUIT.

{ includes/cabrel132_1.i }

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

ASSIGN aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) +
                                   4) - DAY(DATE(MONTH(glb_dtmvtolt),28,
                                                 YEAR(glb_dtmvtolt)) + 4))
                                                 
       aux_dtpridia = DATE(MONTH(glb_dtmvtolt),1,YEAR(glb_dtmvtolt)).
      
FOR EACH crawcrd WHERE crawcrd.cdcooper = glb_cdcooper AND
                       crawcrd.insitcrd = 4            AND      /* Em uso */ 
                       crawcrd.cdadmcrd = 3            NO-LOCK: /* CECREDVISA */
                        
    ASSIGN aux_rowidalt = ?.

    FOR EACH crapalt WHERE crapalt.cdcooper  = glb_cdcooper     AND
                           crapalt.nrdconta  = crawcrd.nrdconta AND
                           crapalt.dtaltera >= aux_dtpridia     AND
                           crapalt.dtaltera <= aux_dtultdia     NO-LOCK:

        IF   crapalt.dsaltera MATCHES "*end.res.*"   THEN
             ASSIGN aux_rowidalt = ROWID(crapalt).

    END.
   
    IF   aux_rowidalt = ?   THEN 
         NEXT. 

    FIND crapalt WHERE ROWID(crapalt) = aux_rowidalt NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapalt   THEN
         NEXT.

    FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                       crapass.nrdconta = crapalt.nrdconta NO-LOCK NO-ERROR.
    
    FIND crapenc WHERE crapenc.cdcooper = glb_cdcooper      AND
                       crapenc.nrdconta = crapass.nrdconta  AND
                       crapenc.idseqttl = 1                 AND
                       crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.
                       
    ASSIGN aux_dsendres = TRIM(STRING(crapenc.dsendere,"x(32)")) + " " +
                          TRIM(STRING(crapenc.nrendere, "zzz,zzz")). 

    IF   crapenc.nmbairro <> ""   THEN
         ASSIGN aux_dsendres = aux_dsendres + " , BAIRRO: "  + 
                               TRIM(STRING(crapenc.nmbairro,"x(40)")).

    IF   crapenc.nmcidade <> ""   THEN
         ASSIGN aux_dsendres = aux_dsendres + " , CIDADE: " + 
                               TRIM(STRING(crapenc.nmcidade,"x(25)")).
    
    IF   crapenc.cdufende <> ""   THEN
         ASSIGN aux_dsendres = aux_dsendres + " , UF: " + 
                               STRING(crapenc.cdufende).

    IF   crapenc.nrcepend  <> 0   THEN
         ASSIGN aux_dsendres = aux_dsendres + " , CEP: " +
                               STRING(crapenc.nrcepend). 

    DISPLAY STREAM str_1 crapass.cdagenci crapass.nrdconta  
                         crapass.nmprimtl crawcrd.nrcrcard
                         crapalt.dtaltera aux_dsendres     
                         WITH FRAME f_enderecos.
                         
    DOWN STREAM str_1 WITH FRAME f_enderecos.
                         
END.

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrcopias = 1
       glb_nmformul = "132col"
       glb_nmarqimp = "rl/crrl436.lst".
                        
RUN fontes/imprim.p. 

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

/* Move para diretorio converte para utilizar na BO */
UNIX SILENT VALUE 
           ("cp " + aux_nmarqimp + " /usr/coop/" +
            crapcop.dsdircop + "/converte" + 
            " 2> /dev/null").
         
RUN fontes/fimprg.p.

/* .......................................................................... */
