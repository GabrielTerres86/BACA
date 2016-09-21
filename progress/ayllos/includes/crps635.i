

/* ..........................................................................

   Programa: Fontes/crps635.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CECRED
   Autor   : Adriano      
   Data    : Marco/2013                     Ultima atualizacao: 08/05/2013 

   Dados referentes ao programa:

   Frequencia: Diario (crps635)/Mensal (crps627).
   Objetivo  : ATUALIZAR RISCO SISBACEN DE ACORDO COM O GE
               

   Alteracoes: 08/05/2013 - Desprezar risco em prejuizo "inindris = 10"
                            (Adriano).
               
............................................................................. */

FOR EACH crapgrp WHERE crapgrp.cdcooper = glb_cdcooper
                       NO-LOCK BREAK BY crapgrp.nrctasoc:

    IF FIRST-OF(crapgrp.nrctasoc) THEN
       DO:
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

             FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper     AND
                                    crapris.nrdconta = crapgrp.nrctasoc AND 
                                    crapris.dtrefere = aux_dtrefere     AND 
                                    crapris.inddocto = 1                AND 
                                    crapris.vldivida > aux_vlr_arrasto  AND
                                    crapris.inindris < 10
                                    EXCLUSIVE-LOCK USE-INDEX crapris1:
                 
                 FOR EACH crapvri WHERE crapvri.cdcooper = crapris.cdcooper AND
                                        crapvri.dtrefere = crapris.dtrefere AND
                                        crapvri.nrdconta = crapris.nrdconta AND
                                        crapvri.innivris = crapris.innivris AND
                                        crapvri.cdmodali = crapris.cdmodali AND
                                        crapvri.nrctremp = crapris.nrctremp AND
                                        crapvri.nrseqctr = crapris.nrseqctr  
                                        EXCLUSIVE-LOCK:
                 
                 
                     ASSIGN crapris.innivris = crapgrp.innivrge
                            crapris.nrdgrupo = crapgrp.nrdgrupo
                            crapvri.innivris = crapris.innivris.
                                
                 
                 END.

             END.

             LEAVE.

          END.

          RELEASE crapris.

       END.

END.


UNIX SILENT VALUE("echo " + " " + STRING(TIME,"HH:MM:SS")        +
                  " - " + glb_cdprogra + "' --> '"               +
                  "Atualizacao dos riscos efetuada com sucesso." + 
                  " >> log/proc_batch.log").

  

/* .......................................................................... */





