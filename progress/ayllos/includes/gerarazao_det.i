/* ..........................................................................

   Programa: includes/crpsrazao_det.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003                       Ultima atualizacao: 03/02/2006

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Listar os lancamentos conforme o historico.
   
               {1} -> Tabela de lancamentos
               {2} -> Campo referente ao numero da conta no Banco do Brasil
   
   Alteracoes: 30/03/2004 - Tratar o tipo de contabilizacao por caixa 6 
                            (Edson).                     
                              
               03/02/2006 - Unificacao dos bancos - SQLWorks - Eder
..............................................................................*/

rel_ttlanmto = 0.
 
FOR EACH {1}     WHERE {1}.cdcooper = glb_cdcooper      AND
                       {1}.cdhistor = rel_cdhistor      AND
                       {1}.dtmvtolt = aux_contdata      NO-LOCK, 
    EACH crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                       crapass.nrdconta = {1}.nrdconta  NO-LOCK
                       /*EACH crapass OF {1} NO-LOCK*/
                       BREAK BY {1}.cdagenci: 
     
    ASSIGN rel_dtlanmto = {1}.dtmvtolt
           rel_nrdconta = {1}.nrdconta
           rel_vllancrd = {1}.vllanmto
           rel_vllandeb = {1}.vllanmto
           rel_nrdocmto = {1}.nrdocmto
           rel_ttlanmto = rel_ttlanmto + {1}.vllanmto
           rel_ttlanage = rel_ttlanage + {1}.vllanmto
           rel_cdagenci = {1}.cdagenci.

    IF   NOT aux_histcred  THEN  /* Verifica se o historico e Deb. ou Cred.*/
         DO:
             ASSIGN rel_vllancrd = 0
                    rel_ttdebdia = rel_ttdebdia + {1}.vllanmto.
         END.
    ELSE
         DO:
             ASSIGN rel_vllandeb = 0
                    rel_ttcrddia = rel_ttcrddia + {1}.vllanmto.
         END.
        
    IF   aux_tpctbcxa = 2   THEN
         ASSIGN rel_nrctadeb = aux_cdcxaage[{1}.cdagenci]
                rel_nrctacrd = craphis.nrctacrd.                
    ELSE    
    IF   aux_tpctbcxa = 3   THEN
         ASSIGN rel_nrctadeb = craphis.nrctadeb
                rel_nrctacrd = aux_cdcxaage[{1}.cdagenci].
    ELSE
    IF   (aux_tpctbcxa > 3)   THEN
         DO:
             FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                craptab.nmsistem = "CRED"           AND
                                craptab.tptabela = "CONTAB"         AND
                                craptab.cdempres = 11               AND
                                craptab.cdacesso = STRING({1}.{2})  AND 
                                craptab.tpregist = {1}.cdbccxlt              
                                NO-LOCK NO-ERROR.
         
             IF   aux_tpctbcxa = 4   OR
                  aux_tpctbcxa = 6   THEN
                  DO:
                      IF   AVAILABLE craptab   THEN
                           rel_nrctadeb = INT(craptab.dstextab).
                      rel_nrctacrd = craphis.nrctacrd.
                  END.
             ELSE
                  DO:                
                      IF   AVAILABLE craptab   THEN
                           rel_nrctacrd = INT(craptab.dstextab).
                      rel_nrctadeb = craphis.nrctadeb.                 
                  END.

         END.
    ELSE
         DO:
             rel_nrctadeb = craphis.nrctadeb.
             rel_nrctacrd = craphis.nrctacrd.            
         END.
    
    IF   FIRST-OF({1}.cdagenci)   THEN
         DO:
            { includes/gerarazao_tit.i }
         END.

    { includes/gerarazao_lan.i crapass.nmprimtl }
                        
    IF   LAST-OF({1}.cdagenci)   THEN
         DO: 
             { includes/gerarazao_pac.i }                 
             rel_ttlanage = 0.
         END.        
END.
 
/*............................................................................*/
