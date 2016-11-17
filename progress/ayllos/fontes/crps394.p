/* ............................................................................

   Programa: fontes/crps394.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro                 
   Data    : Junho/2004                         Ultima atualizacao: 30/06/2014

   Dados referentes ao programa:

   Frequencia: Diario
   Objetivo  : Atende a solicitacao 1
               Emitir relacao de cheques compensados a conferir, separados por 
               P.A.C. (crrl353_PAC).               

   Alteracoes: 23/09/2004 - Modificar para nao imprimir no PAC 1 (Ze Eduardo).
   
               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "for each" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
               
               11/11/2010 - Realizado a inclusao do campo nrdbanco (Adriano).
               
               12/04/2011 - Alterar o campo crapfdc.nrdbanco para 
                            craplcm.cdbccxlt (Ze).
               
               07/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
               
               07/11/2013 - Alterado totalizador de PAs de 99 para 999. 
                            (Guilherme Gielow) 
                            
               30/06/2014 - Adicionado campo cdcoptfn na temp-table w-crapass.
                            (Reinert)                             
             
............................................................................ */

DEF STREAM str_1. /* Relatorio */

{ includes/var_batch.i "NEW" }   

DEF    VAR rel_nmresemp       AS CHAR                           NO-UNDO.
DEF    VAR rel_nmrelato       AS CHAR   EXTENT 5                NO-UNDO.
DEF    VAR rel_nrmodulo       AS INT                            NO-UNDO.
DEF    VAR rel_dsagenci       AS CHAR   FORMAT "x(21)"          NO-UNDO.

DEF    VAR aux_nmarqimp       AS CHAR                           NO-UNDO.
DEF    VAR aux_i-occ          AS INT                            NO-UNDO.
DEF    VAR aux_de-valor       AS DEC                            NO-UNDO.
DEF    VAR aux_vlmaxcom       AS DEC                            NO-UNDO.
DEF    VAR aux_cdagectl       LIKE crapcop.cdagectl EXTENT 99   NO-UNDO.
DEF    VAR aux_dsacolhe       AS CHAR                           NO-UNDO.

DEF TEMP-TABLE w-crapass
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdbanco LIKE craplcm.cdbanchq
    FIELD nrdconta LIKE craplcm.nrdconta
    FIELD nrdocmto LIKE craplcm.nrdocmto
    FIELD vllanmto LIKE craplcm.vllanmto
    FIELD cdcoptfn LIKE craplcm.cdcoptfn
    INDEX ch-agconta  AS UNIQUE PRIMARY
          cdagenci
          nrdbanco
          nrdconta
          nrdocmto.
    

FORM HEADER 
     "PA: "    
     rel_dsagenci FORMAT "x(21)" NO-LABEL
     SKIP(2)
     WITH NO-BOX PAGE-TOP SIDE-LABELS WIDTH 80 FRAME f_agencia.

FORM aux_dsacolhe         AT 8     FORMAT "x(10)"        LABEL "AGE.ACOLHEDORA"
     w-crapass.nrdbanco   AT 23    FORMAT "z,zz9"              LABEL "BANCO"
     w-crapass.nrdconta   AT 29    FORMAT "zzzz,zzz,9"         LABEL "CONTA/DV"
     w-crapass.nrdocmto   AT 40    FORMAT "zz,zzz,zz9"         LABEL "DOCUMENTO"
     w-crapass.vllanmto   AT 51    FORMAT "zzz,zzz,zzz,zz9.99" LABEL "VALOR"     
     WITH NO-BOX DOWN NO-LABELS WIDTH 80 FRAME f_cheqs.

glb_cdprogra = "crps394".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.
  
{ includes/cabrel080_1.i }

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "MAIORESCHQ"   AND
                   craptab.tpregist = 001
                   NO-LOCK NO-ERROR.

IF   AVAILABLE craptab   THEN
     ASSIGN aux_vlmaxcom =  DECIMAL(SUBSTRING(craptab.dstextab,34,15)).
ELSE 
     ASSIGN aux_vlmaxcom = 0.
  
FOR EACH crapcop FIELDS (cdcooper cdagectl) NO-LOCK:

    ASSIGN aux_cdagectl[crapcop.cdcooper] = crapcop.cdagectl.

END.

FOR EACH craphis WHERE craphis.cdcooper = glb_cdcooper      AND
                       craphis.dshistor MATCHES "ch*comp*"  NO-LOCK:
    FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper      AND
                           craplcm.dtmvtolt = glb_dtmvtolt      AND
                           craplcm.dtrefere = glb_dtmvtolt      AND
                           craplcm.cdhistor = craphis.cdhistor  AND
                           craplcm.vllanmto >= aux_vlmaxcom     
                           NO-LOCK USE-INDEX craplcm4,
        
        /*FIRST  crapass OF craplcm NO-LOCK:*/ 
        FIRST  crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                             crapass.nrdconta = craplcm.nrdconta 
                             NO-LOCK:

        CREATE w-crapass.
        ASSIGN w-crapass.cdagenci = crapass.cdagenci
               w-crapass.nrdbanco = craplcm.cdbccxlt 
               w-crapass.nrdconta = craplcm.nrdconta
               w-crapass.nrdocmto = craplcm.nrdocmto
               w-crapass.vllanmto = craplcm.vllanmto
               w-crapass.cdcoptfn = craplcm.cdcoptfn.

    END.     
END.
      
FOR EACH w-crapass NO-LOCK
    BREAK BY w-crapass.cdagenci 
          BY w-crapass.nrdbanco
          BY w-crapass.nrdconta
          BY w-crapass.nrdocmto:
       
       IF FIRST-OF(w-crapass.cdagenci) THEN
          DO:
             
             FIND crapage WHERE crapage.cdcooper = glb_cdcooper       AND
                                crapage.cdagenci = w-crapass.cdagenci
                                NO-LOCK NO-ERROR.
             
             ASSIGN rel_dsagenci = STRING(w-crapass.cdagenci,"zz9") + " - "
                                             + crapage.nmresage
                    aux_nmarqimp = "rl/crrl353_" + 
                             STRING(w-crapass.cdagenci,"999") + ".lst".
             
             OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
             VIEW STREAM str_1 FRAME f_cabrel080_1.
 
             VIEW STREAM str_1 rel_dsagenci FRAME f_agencia.

          END.
          
       IF   w-crapass.cdcoptfn <> 0 THEN
            ASSIGN aux_dsacolhe = STRING(aux_cdagectl[w-crapass.cdcoptfn]).
       ELSE
            ASSIGN aux_dsacolhe = "999-Outras".
       
       DISPLAY STREAM str_1 aux_dsacolhe
                            w-crapass.nrdconta
                            w-crapass.nrdbanco
                            w-crapass.nrdocmto
                            w-crapass.vllanmto
                            WITH FRAME f_cheqs.
       DOWN STREAM str_1 WITH FRAME f_cheqs.
               
       IF LAST-OF(w-crapass.cdagenci) THEN
          DO:
             OUTPUT STREAM str_1 CLOSE.

             ASSIGN glb_nrcopias = 1
                    glb_nmformul = "80col"
                    glb_nmarqimp = aux_nmarqimp.
          END.
END.

RUN fontes/fimprg.p. 
 
/*............................................................................*/
