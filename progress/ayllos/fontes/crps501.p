/*..............................................................................
   Programa: fontes/crps501.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Janeiro/2008                    Ultima atualizacao: 03/02/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 035. Gera o relatorio 207.
               Listar arrecadacao de IOF.
               
   Alteracoes: 08/12/2008 - Considerar Desconto de Titulos (Evandro).
                             
               01/01/2009 - Quando virava o ano nao calculava certo
                            aux_dspreapr (Magui).

               25/09/2009 - Precise - Paulo - Alterado programa para gravar
                            em tabela generica total dos impostos quando for
                            cooperativa diferente de 3 (diferenciando total
                            pessoa fisica de juridica). Quando for a Cecred (3)
                            lista relatorio adicional totalizando os impostos
                            de cada cooperativa.

               03/11/2009 - Precise - Guilherme - Correcao da funcao Impostos
                            para processar a tabela crapcop. Correcao de 
                            atribuicao de valores para aux_vlapagar e
                            aux_vlarecol e no aux_vlapagar recebendo o buffer

               01/12/2009 - Alteracao do valor gravado na gnarrec de
                            VlCtaIOF para vlTotIOF (Guilherme/Precise).

               17/12/2009 - Inclusao do PAGE STREAM para quebra de pagina
                            antes da impressao de Impostos e alteracao do nome 
                            da coluna de IR para IOF (Guilherme/Precise).
                            
               25/02/2010 - Totalizar IOF a Pagar e IOF do Periodo (David).
               
               16/03/2011 - Incluido em emp., concedidos e renegociacoes para
                            pessoa fisica (Adriano).
               
               22/06/2012 - Substituido gncoper por crapcop (Tiago).   
               
               01/08/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               22/08/2013 - Incluidos os totais de isenção tributária (Carlos).
               
               13/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
                            
               03/02/2014 - Incluido campos de PNMPO e ajustado LABEL de alguns
                            campos no relatorio 207. (Reinert)          
			   
			   16/01/2018 - Correcao projeto 410 - inclusao dos históricos 2321 e 2323
			                para listar no relatório (Jean / Mout´s).                  
               
..............................................................................*/

{ includes/var_batch.i }

DEF STREAM str_1.

DEF VAR rel_nmempres AS CHAR FORMAT "x(15)"                            NO-UNDO.
DEF VAR rel_nmresemp AS CHAR FORMAT "x(11)"                            NO-UNDO.
DEF VAR rel_nmrelato AS CHAR FORMAT "x(40)" EXTENT 5                   NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR FORMAT "x(15)" EXTENT 5
                             INIT ["DEP. A VISTA   ","CAPITAL        ",
                                   "EMPRESTIMOS    ","DIGITACAO      ",
                                   "GENERICO       "]                  NO-UNDO.
    
DEF VAR rel_nrmodulo AS INT  FORMAT "9"                                NO-UNDO.

DEF VAR fis_vlchqbas AS DECI                                           NO-UNDO.
DEF VAR fis_vlchqiof AS DECI                                           NO-UNDO.
DEF VAR fis_vltitbas AS DECI                                           NO-UNDO.
DEF VAR fis_vltitiof AS DECI                                           NO-UNDO.
DEF VAR fis_vlctabas AS DECI                                           NO-UNDO.
DEF VAR fis_vlctaiof AS DECI                                           NO-UNDO.
DEF VAR fis_vleprbas AS DECI                                           NO-UNDO.
DEF VAR fis_vlepriof AS DECI                                           NO-UNDO.
DEF VAR fis_vleprcon AS DECI                                           NO-UNDO.
DEF VAR fis_vleprren AS DECI                                           NO-UNDO.
DEF VAR fis_vltotbas AS DECI                                           NO-UNDO.
DEF VAR fis_vltotiof AS DECI                                           NO-UNDO.
DEF VAR fis_isnpnmpo AS DECI                                           NO-UNDO.
DEF VAR fis_isnoutro AS DECI                                           NO-UNDO.
DEF VAR fis_vltotpnm AS DECI                                           NO-UNDO.

DEF VAR jur_vlchqbas AS DECI                                           NO-UNDO.
DEF VAR jur_vlchqiof AS DECI                                           NO-UNDO.
DEF VAR jur_vltitbas AS DECI                                           NO-UNDO.
DEF VAR jur_vltitiof AS DECI                                           NO-UNDO.
DEF VAR jur_vlctabas AS DECI                                           NO-UNDO.
DEF VAR jur_vlctaiof AS DECI                                           NO-UNDO.
DEF VAR jur_vleprcon AS DECI                                           NO-UNDO.
DEF VAR jur_vleprren AS DECI                                           NO-UNDO.
DEF VAR jur_vleprbas AS DECI                                           NO-UNDO.
DEF VAR jur_vlepriof AS DECI                                           NO-UNDO.
DEF VAR jur_vltotbas AS DECI                                           NO-UNDO.
DEF VAR jur_vltotiof AS DECI                                           NO-UNDO.
DEF VAR jur_isnpnmpo AS DECI                                           NO-UNDO.
DEF VAR jur_isnoutro AS DECI                                           NO-UNDO.
DEF VAR jur_vltotpnm AS DECI                                           NO-UNDO.

DEF VAR jur_vliofise AS DECI                                           NO-UNDO.
DEF VAR emp_vliofise AS DECI                                           NO-UNDO.
DEF VAR dti_vliofise AS DECI                                           NO-UNDO.
DEF VAR dch_vliofise AS DECI                                           NO-UNDO.
DEF VAR cco_vliofise AS DECI                                           NO-UNDO.

DEF VAR aux_nmarqrel AS CHAR                                           NO-UNDO.
DEF VAR aux_dsperapu AS CHAR                                           NO-UNDO.

DEF VAR aux_dtrecolh AS DATE                                           NO-UNDO.
DEF VAR aux_dtiniper AS DATE                                           NO-UNDO.

DEF VAR aux_contador AS INTE                                           NO-UNDO.

DEF VAR  rel_nmrescop    AS CHAR FORMAT "x(20)"                        NO-UNDO.
DEF VAR  rel_nrdocnpj    AS CHAR FORMAT "X(20)"                        NO-UNDO.
DEF VAR  aux_vlapagar    AS DEC  FORMAT "zzz,zzz,zz9.99"               NO-UNDO.
DEF VAR  aux_vlarecol    AS DEC  FORMAT "zzz,zzz,zz9.99"               NO-UNDO.
DEF VAR  tot_vlapagar    AS DEC  FORMAT "zzz,zzz,zz9.99"               NO-UNDO.
DEF VAR  tot_vlarecol    AS DEC  FORMAT "zzz,zzz,zz9.99"               NO-UNDO.
DEF VAR  aux_xprimpf     AS INT                                        NO-UNDO.
DEF VAR  aux_xprimpj     AS INT                                        NO-UNDO.
DEF VAR  aux_achou       AS INT                                        NO-UNDO.
DEF VAR  aux_inpessoa    AS INT                                        NO-UNDO.

DEF BUFFER b_gnarrec FOR gnarrec.
DEF BUFFER crabcop FOR crapcop.

FORM
    SKIP(1) 
    "=> PERIODO DE APURACAO:"              AT 14
    aux_dsperapu FORMAT "x(23)"
    SKIP
    "=> RECOLHIMENTO EM    :"              AT 14
    aux_dtrecolh FORMAT "99/99/9999"
    SKIP(3)
    
    /*---------- PESSOA FISICA ----------*/
    
    "IOF PESSOA FISICA (CODIGO DARF 7893)"      AT 19
    SKIP(1)
    "Emprestimos/Financiamentos: Concedidos ="  AT 3
    fis_vleprcon FORMAT "zzz,zzz,zz9.99"
    SKIP
    "(-) Aliquota Zero/PNMPO ="                 AT 18
    fis_isnpnmpo FORMAT "zzz,zzz,zz9.99"
    SKIP
    "(-) Nao Incidencia/Renegociacoes ="        AT 9
    fis_vleprren FORMAT "zzz,zzz,zz9.99"
    SKIP
    "(-) Nao Incidencia/Outros ="               AT 16
    fis_isnoutro FORMAT "zzz,zzz,zz9.99
    SKIP
    "Base ="                                    AT 37
    fis_vleprbas FORMAT "zzz,zzz,zz9.99"
    SKIP
    "Iof ="                                     AT 38
    fis_vlepriof FORMAT "zzz,zzz,zz9.99"
    SKIP(1)
    "Desconto de Cheques: Base ="               AT 16 
    fis_vlchqbas FORMAT "zzz,zzz,zz9.99"
    SKIP
    "Iof ="                                     AT 38
    fis_vlchqiof FORMAT "zzz,zzz,zz9.99"
    SKIP(1)
    "Desconto de Titulos: Base ="               AT 16 
    fis_vltitbas FORMAT "zzz,zzz,zz9.99"
    SKIP
    "Iof ="                                     AT 38
    fis_vltitiof FORMAT "zzz,zzz,zz9.99"
    SKIP(1)
    "Conta Corrente: Base ="                    AT 21
    fis_vlctabas FORMAT "zzz,zzz,zz9.99"
    SKIP
    "Iof ="                                     AT 38
    fis_vlctaiof FORMAT "zzz,zzz,zz9.99"
    SKIP(1)
    "Estornos: Base ="                          AT 27
             "Iof = "                           AT 38
    SKIP(1)                        
    "TOTAL Pessoa Fisica: Base ="               AT 16
    fis_vltotbas FORMAT "zzz,zzz,zz9.99"
    SKIP
    "Iof a Recolher ="                          AT 27
    fis_vltotiof FORMAT "zzz,zzz,zz9.99"
    SKIP(3)

    /*---------- PESSOA JURIDICA ----------*/
    
    "IOF PESSOA JURIDICA (CODIGO DARF 1150)"    AT 18
    SKIP(1)
    "Emprestimos/Financiamentos: Concedidos ="  AT 3
    jur_vleprcon FORMAT "zzz,zzz,zz9.99"
    SKIP
    "(-) Aliquota Zero/PNMPO ="                 AT 18
    jur_isnpnmpo FORMAT "zzz,zzz,zz9.99"
    SKIP
    "(-) Nao Incidencia/Renegociacoes ="        AT 9
    jur_vleprren FORMAT "zzz,zzz,zz9.99"       
    SKIP
    "(-) Nao Incidencia/Imune ="                AT 17
    emp_vliofise FORMAT "zzz,zzz,zz9.99"       
    SKIP
    "(-) Nao Incidencia/Outros ="               AT 16
    jur_isnoutro FORMAT "zzz,zzz,zz9.99"
    SKIP
    "Base ="                                    AT 37
    jur_vleprbas FORMAT "zzz,zzz,zz9.99"       
    SKIP                                       
    "Iof ="                                     AT 38
    jur_vlepriof FORMAT "zzz,zzz,zz9.99"       
    SKIP                                       
                                                   
    SKIP(1)                                    
    "Desconto de Cheques: Base ="               AT 16 
    jur_vlchqbas FORMAT "zzz,zzz,zz9.99"        
    SKIP                                        
    "(-) Nao Incidencia/Imune ="                AT 17
    dch_vliofise FORMAT "zzz,zzz,zz9.99"       
    SKIP
    "Iof ="                                     AT 38
    jur_vlchqiof FORMAT "zzz,zzz,zz9.99"        
                                               
    SKIP(1)                                    
    "Desconto de Titulos: Base ="               AT 16 
    jur_vltitbas FORMAT "zzz,zzz,zz9.99"       
    SKIP                                       
    "(-) Nao Incidencia/Imune ="                AT 17
    dti_vliofise FORMAT "zzz,zzz,zz9.99"       
    SKIP                                        
    "Iof ="                                     AT 38
    jur_vltitiof FORMAT "zzz,zzz,zz9.99"           
                                               
    SKIP(1)                                    
    "Conta Corrente: Base ="                    AT 21
    jur_vlctabas FORMAT "zzz,zzz,zz9.99"       
    SKIP                                       
    "(-) Nao Incidencia/Imune ="                AT 17
    cco_vliofise FORMAT "zzz,zzz,zz9.99"
    SKIP
    "Iof ="                                     AT 38
    jur_vlctaiof FORMAT "zzz,zzz,zz9.99"       
    
    SKIP(1)
    "Estornos: Base ="                          AT 27
              "Iof = "                          AT 38
    SKIP(1)                                    
    "TOTAL Pessoa Juridica: Base ="             AT 14
    jur_vltotbas FORMAT "zzz,zzz,zz9.99"       
    SKIP                                       
    "(-) TOTAL Nao Incidencia/Imune ="          AT 11
    jur_vliofise FORMAT "zzz,zzz,zz9.99"
    SKIP                                           
    "Iof a Recolher ="                          AT 27
    jur_vltotiof FORMAT "zzz,zzz,zz9.99"           

    SKIP(2)
    WITH NO-BOX NO-LABEL WIDTH 80 FRAME f_dados.
    
FORM SKIP(3)
     aux_dsperapu FORMAT "x(23)"      AT 13
                  LABEL "PERIODO DE APURACAO" SKIP(1)
     aux_dtrecolh FORMAT "99/99/9999" AT 17
                  LABEL "RECOLHIMENTO EM" SKIP(2)
     "** I.O.F. DOS ASSOCIADOS (PESSOA FISICA) **" AT 10 
     "COD. DARF  7893" AT 57    SKIP(2)
     "COOPERATIVA"     AT 4 
     "CNPJ"            AT 25
     "IOF DO PERIODO"  AT 46
     "IOF A PAGAR"     AT 69    SKIP(2)
     WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f_cons_pf.

FORM SKIP(3)
     aux_dsperapu FORMAT "x(23)"      AT 13
                  LABEL "PERIODO DE APURACAO" SKIP(1)
     aux_dtrecolh FORMAT "99/99/9999" AT 17
                  LABEL "RECOLHIMENTO EM" SKIP(2)
     "** I.O.F.. DOS ASSOCIADOS (PESSOA JURIDICA) **" AT 10 
     "COD. DARF  1150" AT 57    SKIP(2)
     "COOPERATIVA"     AT 4 
     "CNPJ"            AT 25
     "IOF DO PERIODO"  AT 46
     "IOF A PAGAR"     AT 69 SKIP(2)

     WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f_cons_pj.

FORM SKIP
     rel_nmrescop     AT 4  NO-LABEL
     rel_nrdocnpj     AT 25 NO-LABEL
     aux_vlarecol     AT 45 NO-LABEL
     aux_vlapagar     AT 65 NO-LABEL SKIP
     WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f_imposto.

ASSIGN glb_cdprogra = "crps501"
       aux_nmarqrel = "rl/crrl207.lst".

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    RETURN.
  
FIND crabcop WHERE crabcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crabcop  THEN
    DO:
        ASSIGN glb_cdcritic = 651.
        RUN fontes/critic.p.

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> log/proc_batch.log").
        
        RETURN.
    END.

{ includes/cabrel080_1.i }

OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) PAGED PAGE-SIZE 80.

VIEW STREAM str_1 FRAME f_cabrel080_1.

/** Data de inicio da apuracao **/
ASSIGN aux_dtiniper = IF  MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr)  THEN
                          DATE(MONTH(glb_dtmvtolt),21,YEAR(glb_dtmvtolt)) 
                      ELSE                  
                      IF  DAY(glb_dtmvtolt) >= 15  THEN
                          DATE(MONTH(glb_dtmvtolt),11,YEAR(glb_dtmvtolt))
                      ELSE
                          DATE(MONTH(glb_dtmvtolt),1,YEAR(glb_dtmvtolt)).

/** Perido de apuracao do IOF **/
IF  DAY(glb_dtmvtolt) <= 10 AND DAY(glb_dtmvtopr) > 10  THEN
    ASSIGN aux_dsperapu = "01/" + STRING(MONTH(glb_dtmvtolt),"99") + "/" +
                          STRING(YEAR(glb_dtmvtolt),"9999") + " A " +
                          "10/" + 
                          STRING(MONTH(glb_dtmvtolt),"99") + "/" +
                          STRING(YEAR(glb_dtmvtolt),"9999"). 
ELSE
IF  DAY(glb_dtmvtolt) <= 20 AND DAY(glb_dtmvtopr) > 20  THEN
    ASSIGN aux_dsperapu = "11/" + STRING(MONTH(glb_dtmvtolt),"99") + "/" +
                          STRING(YEAR(glb_dtmvtolt),"9999") + " A " +
                          "20/" + 
                          STRING(MONTH(glb_dtmvtolt),"99") + "/" +
                          STRING(YEAR(glb_dtmvtolt),"9999").
ELSE
IF  MONTH(glb_dtmvtopr) <> MONTH(glb_dtmvtolt)  THEN
    ASSIGN aux_dsperapu = "21/" + STRING(MONTH(glb_dtmvtolt),"99") + "/" +
                          STRING(YEAR(glb_dtmvtolt),"9999") + " A " +
                          STRING(DAY(glb_dtultdia)) + "/" +
                          STRING(MONTH(glb_dtultdia),"99") + "/" +
                          STRING(YEAR(glb_dtultdia),"9999").
    
/** Dia do recolhimento **/
ASSIGN aux_dtrecolh = glb_dtmvtolt
       aux_contador = 0.

DO WHILE TRUE:

    ASSIGN aux_dtrecolh = aux_dtrecolh + 1.
    
    IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtrecolh)))               OR
        CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper    AND
                               crapfer.dtferiad = aux_dtrecolh)   THEN
        NEXT.

    ASSIGN aux_contador = aux_contador + 1.
           
    IF  aux_contador = 3  THEN
        LEAVE.

END. /** Fim do DO WHILE TRUE **/

/* Totaliza as isenções de 1-Emp,2-Desc.Tit,3-Desc.Chq,4-C/C */
RUN totalIsencao(INPUT  glb_cdcooper, 
                 INPUT  aux_dtiniper,
                 INPUT  glb_dtmvtolt).

ASSIGN jur_vleprcon = jur_vleprcon + emp_vliofise.

FOR EACH craplcm WHERE craplcm.cdcooper  = glb_cdcooper AND
                       craplcm.dtmvtolt >= aux_dtiniper AND
                       craplcm.dtmvtolt <= glb_dtmvtolt AND
                      (craplcm.cdhistor  = 322          OR  
                       craplcm.cdhistor  = 323          OR
                       craplcm.cdhistor  = 2322        OR					   
                       craplcm.cdhistor  = 324          OR
					   craplcm.cdhistor  = 2318        OR
					   craplcm.cdhistor  = 2320        OR
					   craplcm.cdhistor  = 2321         OR
					   craplcm.cdhistor  = 2323         OR
                       craplcm.cdhistor  = 688)         NO-LOCK
                       USE-INDEX craplcm4:

    FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                       crapass.nrdconta = craplcm.nrdconta NO-LOCK NO-ERROR.
       
    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN glb_cdcritic = 9.
            RUN fontes/critic.p.

            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + glb_cdprogra + "' --> '"  +
                              glb_dscritic + " >> log/proc_batch.log").
        
            RETURN.    

        END.
                                                                            
    IF  craplcm.cdhistor = 322  THEN /** Emprestimos **/
        DO:            
            IF  crapass.inpessoa = 1  THEN                
                ASSIGN fis_vleprcon = fis_vleprcon + 
                                      DECI(SUBSTRING(craplcm.cdpesqbb,15,14))
                       fis_vleprren = fis_vleprren + 
                                      DECI(SUBSTRING(craplcm.cdpesqbb,29,14))
                       fis_vleprbas = fis_vleprbas + 
                                      DECI(SUBSTRING(craplcm.cdpesqbb,1,14))
                       fis_vlepriof = fis_vlepriof + craplcm.vllanmto.
            ELSE           
                ASSIGN jur_vleprcon = jur_vleprcon + 
                                      DECI(SUBSTRING(craplcm.cdpesqbb, 15,14))
                       jur_vleprren = jur_vleprren + 
                                      DECI(SUBSTRING(craplcm.cdpesqbb,29,14))
                       jur_vleprbas = jur_vleprbas + 
                                      DECI(SUBSTRING(craplcm.cdpesqbb,1,14))
                       jur_vlepriof = jur_vlepriof + craplcm.vllanmto.
            END.
    ELSE
    IF  craplcm.cdhistor = 323  
	or  craplcm.cdhistor = 2322
	or  craplcm.cdhistor = 2323 THEN /** Conta Corrente **/
        DO:
            IF  crapass.inpessoa = 1  THEN
                ASSIGN fis_vlctabas = fis_vlctabas + DECI(craplcm.cdpesqbb)
                       fis_vlctaiof = fis_vlctaiof + craplcm.vllanmto.
            ELSE
                ASSIGN jur_vlctabas = jur_vlctabas + DECI(craplcm.cdpesqbb)
                       jur_vlctaiof = jur_vlctaiof + craplcm.vllanmto.
        END.
    ELSE
    IF  craplcm.cdhistor = 324 
    or  craplcm.cdhistor = 2318	THEN /** Desconto de Cheques **/
        DO:
            IF  crapass.inpessoa = 1  THEN
                ASSIGN fis_vlchqbas = fis_vlchqbas + DECI(craplcm.cdpesqbb)
                        fis_vlchqiof = fis_vlchqiof + craplcm.vllanmto.
            ELSE           
                ASSIGN jur_vlchqbas = jur_vlchqbas + DECI(craplcm.cdpesqbb)
                        jur_vlchqiof = jur_vlchqiof + craplcm.vllanmto.    
        END.
    ELSE
    IF  craplcm.cdhistor = 688  
    or  craplcm.cdhistor = 2320	
	or  craplcm.cdhistor = 2321 THEN /** Desconto de Titulos **/
		DO:
		    if craplcm.cdhistor <> 2321 then 
			do:
            IF  crapass.inpessoa = 1  THEN
                ASSIGN fis_vltitbas = fis_vltitbas + 
                                      DEC(SUBSTRING(craplcm.cdpesqbb,
                                          R-INDEX(craplcm.cdpesqbb," ")))
                       fis_vltitiof = fis_vltitiof + craplcm.vllanmto.
            ELSE           
                ASSIGN jur_vltitbas = jur_vltitbas +
                                      DEC(SUBSTRING(craplcm.cdpesqbb,
                                          R-INDEX(craplcm.cdpesqbb," ")))
                       jur_vltitiof = jur_vltitiof + craplcm.vllanmto.
		    end.
			
			if craplcm.cdhistor = 2321 then
			do:
			   find first craptdb where craptdb.cdcooper = craplcm.cdcooper and
			                               craptdb.nrdconta = craplcm.nrdconta and
										   craptdb.insittit = 3                  and
										   craptdb.nrdocmto = dec(craplcm.cdpesqbb) and
										   craptdb.dtdebito = craplcm.dtmvtolt.
               if avail craptdb then										   
			                          
			       if crapass.inpessoa = 1 then
				       assign fis_vltitbas = fis_vltitbas + craptdb.vlliquid
					           fis_vltitiof = fis_vltitiof + craplcm.vllanmto.
			       else
				       assign jur_vltitbas = jur_vltitbas + craptdb.vlliquid 
					           jur_vltitiof = jur_vltitiof + craplcm.vllanmto.			     
			end.
        END.
                                                                              
END. /** Fim do FOR EACH craplcm **/

FOR EACH crapepr WHERE crapepr.cdcooper = glb_cdcooper     AND
                       crapepr.dtmvtolt >= aux_dtiniper    AND
                       crapepr.dtmvtolt <= glb_dtmvtolt
                       NO-LOCK,
    EACH craplcr WHERE craplcr.cdcooper = crapepr.cdcooper AND
                       craplcr.cdlcremp = crapepr.cdlcremp AND
                       craplcr.flgtaiof = FALSE NO-LOCK:
    
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                       crapass.nrdconta = crapepr.nrdconta NO-LOCK NO-ERROR.

    IF  craplcr.dsorgrec MATCHES("*PNMPO*") THEN  
        DO:
            IF  crapass.inpessoa = 1 THEN
                ASSIGN fis_isnpnmpo = fis_isnpnmpo + crapepr.vlemprst
                       fis_vleprcon = fis_vleprcon + crapepr.vlemprst.
            ELSE
                ASSIGN jur_isnpnmpo = jur_isnpnmpo + crapepr.vlemprst
                       jur_vleprcon = jur_vleprcon + crapepr.vlemprst.
        END.
    ELSE   
        DO:
            IF  crapass.inpessoa = 1 THEN
                ASSIGN fis_isnoutro = fis_isnoutro + crapepr.vlemprst 
                       fis_vleprcon = fis_vleprcon + crapepr.vlemprst.
            ELSE
                ASSIGN jur_isnoutro = jur_isnoutro + crapepr.vlemprst
                       jur_vleprcon = jur_vleprcon + crapepr.vlemprst.

        END.
END.

ASSIGN fis_vltotbas = fis_vleprbas + fis_vlchqbas + fis_vltitbas + fis_vlctabas
       fis_vltotiof = fis_vlepriof + fis_vlchqiof + fis_vltitiof + fis_vlctaiof
       jur_vltotbas = jur_vleprbas + jur_vlchqbas + jur_vltitbas + jur_vlctabas
       jur_vltotiof = jur_vlepriof + jur_vlchqiof + jur_vltitiof + jur_vlctaiof.       


DISPLAY STREAM str_1 fis_vleprcon
                     fis_isnpnmpo
                     fis_vleprren
                     fis_isnoutro

                     fis_vltotbas fis_vleprbas fis_vlchqbas fis_vltitbas
                     fis_vlctabas
                     
                     fis_vltotiof fis_vlepriof fis_vlchqiof fis_vltitiof
                     fis_vlctaiof
                     
                     jur_vleprcon
                     jur_isnpnmpo
                     jur_vleprren
                     jur_isnoutro

                     jur_vltotbas jur_vleprbas jur_vlchqbas jur_vltitbas
                     jur_vlctabas
                     
                     jur_vltotiof 
                     jur_vlepriof emp_vliofise
                     jur_vlchqiof dch_vliofise 
                     jur_vltitiof dti_vliofise
                     jur_vlctaiof cco_vliofise
                     jur_vliofise                     
                     aux_dsperapu aux_dtrecolh
                     WITH FRAME f_dados.

   PAGE STREAM str_1.

   /* Popular tabela generica arrecadacao para cooperativos <> de CECRED */
   IF glb_cdcooper <> 3 THEN
       DO:
           /* pessoa fisica */
           FIND FIRST gnarrec 
               WHERE gnarrec.cdcooper = glb_cdcooper 
                 AND gnarrec.dtiniapu = aux_dtiniper
                 AND gnarrec.inpessoa = 1
                 AND gnarrec.tpimpost = 1 EXCLUSIVE-LOCK NO-ERROR.

           IF NOT AVAIL gnarrec THEN
               DO:
                  CREATE gnarrec.
                  ASSIGN gnarrec.cdcooper = glb_cdcooper
                         gnarrec.dtiniapu = aux_dtiniper
                         gnarrec.inpessoa = 1 
                         gnarrec.tpimpost = 1.
                  VALIDATE gnarrec.
               END.
           ASSIGN gnarrec.dtfimapu = glb_dtmvtolt
                  gnarrec.dtrecolh = aux_dtrecolh 
                  gnarrec.vlrecolh = fis_vltotiof
                  gnarrec.vlapagar = fis_vltotiof
                  gnarrec.inapagar = YES.
           
           /* Limite minimo fixado de R$ 10 para recolhimento do periodo */
           IF gnarrec.vlapagar < 10 THEN
              gnarrec.vlapagar = 0.

           /* pessoa juridica */
           FIND FIRST gnarrec 
               WHERE gnarrec.cdcooper = glb_cdcooper 
                 AND gnarrec.dtiniapu = aux_dtiniper
                 AND gnarrec.inpessoa = 2
                 AND gnarrec.tpimpost = 1 EXCLUSIVE-LOCK NO-ERROR.

           IF NOT AVAIL gnarrec THEN
               DO:
                  CREATE gnarrec.
                  ASSIGN gnarrec.cdcooper = glb_cdcooper
                         gnarrec.dtiniapu = aux_dtiniper
                         gnarrec.inpessoa = 2 
                         gnarrec.tpimpost = 1.
                  VALIDATE gnarrec.
               END.
           ASSIGN gnarrec.dtfimapu = glb_dtmvtolt 
                   gnarrec.dtrecolh = aux_dtrecolh 
                   gnarrec.vlrecolh = jur_vltotiof
                   gnarrec.vlapagar = jur_vltotiof
                   gnarrec.inapagar = YES.
           
           /* Limite minimo fixado de R$ 10 para recolhimento do periodo */
           IF gnarrec.vlapagar < 10 THEN
              gnarrec.vlapagar = 0.

       END.
    ELSE
        DO:
            /* Quando CECRED, exibir resumo no relatorio */
            ASSIGN aux_xprimpj = 0
                    aux_xprimpf = 0
                    aux_inpessoa = 1.
            RUN imposto.
            aux_inpessoa = 2.
            RUN imposto.

        END.

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrcopias = 1
        glb_nmformul = "80col"
        glb_nmarqimp = aux_nmarqrel.
                   
RUN fontes/imprim.p.

RUN fontes/fimprg.p.
                     
/*............................................................................*/
PROCEDURE imposto:

    ASSIGN tot_vlapagar = 0
           tot_vlarecol = 0.

    /* for each para pegar todas as cooperativas */
    FOR EACH crapcop WHERE cdcooper <> 3 break by cdcooper:

        ASSIGN rel_nmrescop = crapcop.nmrescop
               rel_nrdocnpj = STRING(crapcop.nrdocnpj,"99999999999999")
               rel_nrdocnpj = STRING(rel_nrdocnpj,"xx.xxx.xxx/xxxx-xx").

        FIND FIRST gnarrec 
            WHERE gnarrec.cdcooper = crapcop.cdcooper 
              AND gnarrec.dtiniapu = aux_dtiniper
              AND gnarrec.inpessoa = aux_inpessoa
              AND gnarrec.tpimpost = 1 EXCLUSIVE-LOCK NO-ERROR.

        IF  NOT AVAIL gnarrec  THEN
            NEXT.
        
        ASSIGN aux_vlapagar = gnarrec.vlrecolh
               aux_vlarecol = gnarrec.vlrecolh
               aux_achou = 0.

        /* for each para pegar valores de decendios
           anteriores nao recolhidos */
        FOR EACH b_gnarrec
            WHERE b_gnarrec.cdcooper = crapcop.cdcooper 
              AND b_gnarrec.dtiniapu < aux_dtiniper
              AND b_gnarrec.inpessoa = aux_inpessoa
              AND b_gnarrec.tpimpost = 1
              AND b_gnarrec.inapagar = YES
              NO-LOCK:

              ASSIGN aux_vlapagar = aux_vlapagar + b_gnarrec.vlrecolh
                     aux_achou = 1.

        END.

        /* Limite minimo fixado de R$ 10 para recolhimento do periodo */
        IF  aux_vlapagar >= 10  THEN
            DO:
                ASSIGN gnarrec.vlapagar = aux_vlapagar
                       gnarrec.inapagar = NO.

                IF  aux_achou = 1  THEN
                    DO:

                        FOR EACH b_gnarrec
                           WHERE b_gnarrec.cdcooper = crapcop.cdcooper 
                             AND b_gnarrec.dtiniapu < aux_dtiniper
                             AND b_gnarrec.inpessoa = aux_inpessoa
                             AND b_gnarrec.tpimpost = 1
                             AND b_gnarrec.inapagar = YES EXCLUSIVE-LOCK :

                            ASSIGN b_gnarrec.inapagar = NO.

                        END.
                    END.
            END.
        ELSE
            ASSIGN aux_vlapagar = 0.

        ASSIGN tot_vlapagar = tot_vlapagar + aux_vlapagar
               tot_vlarecol = tot_vlarecol + aux_vlarecol.

        IF  aux_xprimpf = 0 AND aux_inpessoa = 1  THEN
            DO:
                ASSIGN aux_xprimpf = 1.
                DISPLAY STREAM str_1
                        aux_dsperapu  
                        aux_dtrecolh
                  WITH FRAME f_cons_pf.
            END.

        IF  aux_xprimpj = 0 AND aux_inpessoa = 2  THEN
            DO:
                ASSIGN aux_xprimpj = 1.
                DISPLAY STREAM str_1
                        aux_dsperapu  
                        aux_dtrecolh
                  WITH FRAME f_cons_pj.
            END.

        DISPLAY STREAM str_1
                rel_nmrescop
                rel_nrdocnpj
                aux_vlarecol
                aux_vlapagar
                WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f_imposto.

        DOWN STREAM str_1 WITH FRAME f_imposto.

    END.

    DISPLAY STREAM str_1
            ""                   @ rel_nmrescop
            "             TOTAL" @ rel_nrdocnpj
            tot_vlarecol         @ aux_vlarecol
            tot_vlapagar         @ aux_vlapagar
            WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f_imposto.
    
END PROCEDURE.

/*
    Retorna o total de isenções no período e cooperativa informados.
*/
PROCEDURE totalIsencao:
    DEF INPUT PARAM par_cdcooper AS INTE.
    DEF INPUT PARAM par_dtiniper AS DATE.
    DEF INPUT PARAM par_dtmvtolt AS DATE.

    FOR EACH crapvin 
                     WHERE crapvin.cdcooper  = glb_cdcooper     AND
                           crapvin.dtmvtolt >= aux_dtiniper     AND
                           crapvin.dtmvtolt <= glb_dtmvtolt     AND
                           crapvin.cdinsenc < 5 /* 1-Emp,2-Desc.Tit,3-Desc.Chq,4-C/C */
                           NO-LOCK:
        CASE crapvin.cdinsenc:
            WHEN 1 THEN
                ASSIGN emp_vliofise = emp_vliofise + crapvin.vlinsenc.
            WHEN 2 THEN
                ASSIGN dti_vliofise = dti_vliofise + crapvin.vlinsenc.
            WHEN 3 THEN
                ASSIGN dch_vliofise = dch_vliofise + crapvin.vlinsenc.
            WHEN 4 THEN
                ASSIGN cco_vliofise = cco_vliofise + crapvin.vlinsenc.
        END CASE.        
    END.

    ASSIGN jur_vliofise = emp_vliofise + 
                          dti_vliofise + 
                          dch_vliofise + 
                          cco_vliofise.
END PROCEDURE.

/*............................................................................*/
