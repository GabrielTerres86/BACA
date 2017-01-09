/* --------------------------------------------------------------------------
   
    AUTOR: Diego

 Objetivo: 1 - CRIAR REGISTROS NA NOVA COOPERATIVA A PARTIR DE OUTRA COOP.
           
           2 - EXPORTAR REGISTROS DA TABELA CRAPTAB A PARTIR DE OUTRA 
               COOP. ESTES REGISTROS SERAO IMPORTADOS NA NOVA COOP. ATRAVES 
               DO PROGRAMA fontes/import.p QUE TRATA ALGUMAS PARTICULARIDADES
               DE ALGUMAS CRAPTAB'S. 
               
  Alteracoes: 20/11/2013 - Incluido comando CAPS na atribuicao da variavel 
                           aux_nmrescop (Diego).
                           
              28/02/2014 - Incluso VALIDATE (Daniel).  
              
              22/07/2014 - Adicionadas as estruturas: crapoco e crapmot.
                           (Reinert)
              08/01/2015 -  incluir no programa fontes/nova_coop.p 
                            a criação da tabela craptsg. 
                            Desta forma, quando for criada uma nova cooperativa
                            no sistema será possível visualizar 
                            todos os planos disponíveis na tela ALTSEG.
                            SoftDesk 232489 (Felipe)
 
              05/12/2016 -  Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
 
                         !!!!!!!!!!! ATENCAO !!!!!!!!!!!
                                
  ==> ANTES DE RODAR:
      - DEFINIR DIRETORIO PARA EXPORTACAO DA TABELA CRAPTAB (aux_direxpor) 
      - DEFINIR NOME DA NOVA COOPERATIVA (aux_nmrescop) 
      - DEFINIR CODIGO DA AGENCIA NO BANCO 85 (aux_cdagectl)
      - DEFINIR DIRETORIO DA COOPERATIVA (aux_dsdircop)
    
---------------------------------------------------------------------------- */

def var aux_coop_nova as int                                        no-undo.
def var aux_ult_coop  as int                                        no-undo.
def var aux_nmrescop  as char                                       no-undo.
def var aux_direxpor  as char                                       no-undo.
def var aux_cdagectl  as int                                        no-undo.
def var aux_dsdircop  as char                                       no-undo.
DEF VAR aux_nrctactl  AS INT                                        NO-UNDO.

/***  teste de execucao 
def temp-table crabdat like crapdat.
def temp-table crabprg like crapprg.
def temp-table crabrel like craprel.
def temp-table crabtel like craptel.
def temp-table crabord like crapord.
def temp-table crabhis like craphis.
def temp-table crabthi like crapthi.
def temp-table crabtip like craptip.
def temp-table crabfhs like crapfhs.
def temp-table crabfer like crapfer.
def temp-table crabmfx like crapmfx.
def temp-table crabtor like craptor.
def temp-table crabitr like crapitr.
def temp-table crabsir like crapsir.
def temp-table crabper like crapper.
def temp-table crabemp like crapemp.
def temp-table crabope like crapope.
def temp-table crabnsu like crapnsu.
def temp-table crabcsg like crapcsg.
def temp-table crabsga like crapsga.
def temp-table crabsit like crapsit.
def temp-table b-gnctace like gnctace.
def temp-table b-crapage like crapage.
def temp-table b-crapcop like crapcop.
def temp-table b-crapmat like crapmat.
def temp-table crabtab like craptab.
def temp-table b-crapadc like crapadc.
def temp-table b-craptlc like craptlc.
***/

def buffer crabdat for crapdat.
def buffer crabprg for crapprg.
def buffer crabrel for craprel.
def buffer crabtel for craptel.
def buffer crabord for crapord.
def buffer crabhis for craphis.
def buffer crabthi for crapthi.
def buffer crabtip for craptip.
def buffer crabfhs for crapfhs.
def buffer crabfer for crapfer.
def buffer crabmfx for crapmfx.
def buffer crabtor for craptor.
def buffer crabitr for crapitr.
def buffer crabsir for crapsir.
def buffer crabper for crapper.
def buffer crabemp for crapemp.
def buffer crabope for crapope.
def buffer crabnsu for crapnsu.
def buffer crabcsg for crapcsg.
def buffer crabsga for crapsga.
def buffer crabsit for crapsit.
DEF BUFFER craboco FOR crapoco.
DEF BUFFER crabmot FOR crapmot.
def buffer crabtsg for craptsg.

def buffer b-gnctace for gnctace.
def buffer b-crapage for crapage.
def buffer b-crapcop for crapcop.
def buffer b-crapmat for crapmat.
def buffer crabtab for craptab.
def buffer b-crapadc for crapadc.
def buffer b-craptlc for craptlc.

update aux_ult_coop    FORMAT "zz9"
                       LABEL "Copiar dados da Cooperativa"
                       HELP "Informe o codigo da cooperativa de ORIGEM"
       SKIP
       aux_coop_nova   FORMAT "zz9"
                       LABEL "Nova Cooperativa"
                       HELP "Informe o codigo da NOVA cooperativa"
       with no-label overlay side-label  frame f_coop_nova .    


assign aux_direxpor = "/usr/coop/sistema/equipe/diego/novacoop/transulcred/" +
                      "craptab_" + string(aux_coop_nova,"99") + ".d"
       aux_nmrescop = "transulcred"               
       aux_cdagectl = 116
       aux_nrctactl = 0
       aux_dsdircop = "transulcred".


   
   DISPLAY  "CRIANDO . . ."  
            SKIP(1) WITH ROW 5 size 30 by 30.

   
   for each crapdat where crapdat.cdcooper = aux_ult_coop no-lock:

       create crabdat.
       buffer-copy crapdat except crapdat.cdcooper TO crabdat.
       assign crabdat.cdcooper = aux_coop_nova.
       VALIDATE crabdat.
       
   end.    

   DISPLAY "crapdat" skip.

   
   for each crapprg where crapprg.cdcooper = aux_ult_coop no-lock:

       create crabprg.
       buffer-copy crapprg except crapprg.cdcooper TO crabprg.
       assign crabprg.cdcooper = aux_coop_nova.
       VALIDATE crabprg.
    
   end.

   DISPLAY "crapprg" skip.


   for each craprel where craprel.cdcooper = aux_ult_coop no-lock:

       create crabrel.
       buffer-copy craprel except craprel.cdcooper TO crabrel.
       assign crabrel.cdcooper = aux_coop_nova.
       VALIDATE crabrel.
       
   end.

   DISPLAY "craprel" skip.


   for each craptsg where craptsg.cdcooper = aux_ult_coop NO-LOCK:
        create crabtsg.
        buffer-copy craptsg except craptsg.cdcooper TO crabtsg.
        assign crabtsg.cdcooper = aux_coop_nova.
   end.


  DISPLAY "craptsg" skip.

   for each craptel where craptel.cdcooper = aux_ult_coop no-lock:

       create crabtel.
       buffer-copy craptel except craptel.cdcooper TO crabtel.
       assign crabtel.cdcooper = aux_coop_nova.
       VALIDATE crabtel.
    
   end.

   DISPLAY "craptel" skip.


   for each crapord where crapord.cdcooper = aux_ult_coop no-lock:

       create crabord.
       buffer-copy crapord except crapord.cdcooper TO crabord.
       assign crabord.cdcooper = aux_coop_nova.
       VALIDATE crabord.
    
   end.

   DISPLAY "crapord" skip.


   for each craphis where craphis.cdcooper = aux_ult_coop no-lock:

       create crabhis.
       buffer-copy craphis except craphis.cdcooper TO crabhis.
       assign crabhis.cdcooper = aux_coop_nova.
       VALIDATE crabhis.
    
   end.

   DISPLAY "craphis" skip.


   for each crapthi where crapthi.cdcooper = aux_ult_coop no-lock:

       create crabthi.
       buffer-copy crapthi except crapthi.cdcooper TO crabthi.
       assign crabthi.cdcooper = aux_coop_nova.
       VALIDATE crabthi.

   end.

   DISPLAY "crapthi" skip.


   for each craptip where craptip.cdcooper = aux_ult_coop no-lock:

       create crabtip.
       buffer-copy craptip except craptip.cdcooper TO crabtip.
       assign crabtip.cdcooper = aux_coop_nova.
       VALIDATE crabtip.

   end.

   DISPLAY "craptip" skip.


   for each crapfhs where crapfhs.cdcooper = aux_ult_coop no-lock:

       create crabfhs.
       buffer-copy crapfhs except crapfhs.cdcooper TO crabfhs.
       assign crabfhs.cdcooper = aux_coop_nova.
       VALIDATE crabfhs.

   end.

   DISPLAY "crapfhs" skip.


   for each crapfer where crapfer.cdcooper = aux_ult_coop no-lock:

       create crabfer.
       buffer-copy crapfer except crapfer.cdcooper TO crabfer.
       assign crabfer.cdcooper = aux_coop_nova.
       VALIDATE crabfer.

   end.
   
   DISPLAY "crapfer" skip.
   
   
   for each crapmfx where crapmfx.cdcooper  = aux_ult_coop  AND
                          crapmfx.tpmoefix <> 6 no-lock:

       create crabmfx.
       buffer-copy crapmfx except crapmfx.cdcooper TO crabmfx.
       assign crabmfx.cdcooper = aux_coop_nova.
       VALIDATE crabmfx.
              
   end.

   DISPLAY "crapmfx" skip.


   for each craptor where craptor.cdcooper = aux_ult_coop no-lock:

       create crabtor.
       buffer-copy craptor except craptor.cdcooper TO crabtor.
       assign crabtor.cdcooper = aux_coop_nova.
       VALIDATE crabtor.
       
   end.

   DISPLAY "craptor" skip.
           


   for each crapitr where crapitr.cdcooper = aux_ult_coop no-lock:

       create crabitr.
       buffer-copy crapitr except crapitr.cdcooper TO crabitr.
       assign crabitr.cdcooper = aux_coop_nova.
       VALIDATE crabitr.
       
   end.

   DISPLAY  "crapitr" skip 
           with row 6 overlay no-box column 18 frame b.


   for each crapsir where crapsir.cdcooper = aux_ult_coop no-lock:

       create crabsir.
       buffer-copy crapsir except crapsir.cdcooper TO crabsir.
       assign crabsir.cdcooper = aux_coop_nova.
       VALIDATE crabsir.
       
   end.

   DISPLAY "crapsir" skip with frame b.


   for each crapper where crapper.cdcooper = aux_ult_coop no-lock:

       create crabper.
       buffer-copy crapper except crapper.cdcooper TO crabper.
       assign crabper.cdcooper = aux_coop_nova.
       VALIDATE crabper.
       
   end.

   DISPLAY "crapper" skip with frame b.

   FOR EACH crapoco WHERE crapoco.cdcooper = aux_ult_coop NO-LOCK:

       CREATE craboco.
       BUFFER-COPY crapoco EXCEPT crapoco.cdcooper TO craboco.
       ASSIGN craboco.cdcooper = aux_coop_nova.
       VALIDATE craboco.

   END.

   DISPLAY "crapoco" skip with frame b.

   FOR EACH crapmot WHERE crapmot.cdcooper = aux_ult_coop NO-LOCK:

       CREATE crabmot.
       BUFFER-COPY crapmot EXCEPT crapmot.cdcooper TO crabmot.
       ASSIGN crabmot.cdcooper = aux_coop_nova.
       VALIDATE crabmot.

   END.

   DISPLAY "crapmot" skip with frame b.

   for each crapemp where crapemp.cdcooper = aux_ult_coop and
                         (crapemp.cdempres = 11 or 
                          crapemp.cdempres = 81 or
                          crapemp.cdempres = 88) no-lock:

       create crabemp.
       buffer-copy crapemp except crapemp.cdcooper TO crabemp.
       assign crabemp.cdcooper = aux_coop_nova.
       VALIDATE crabemp.
   
   end.

   DISPLAY "crapemp" skip with frame b.


   /* Copia todos os operadores da CECRED para nova coop */ 
   for each crapope where crapope.cdcooper = aux_ult_coop and
                         (crapope.cddepart = 2  OR   /* CARTOES               */
                          crapope.cddepart = 4  OR   /* COMPE                 */
                          crapope.cddepart = 6  OR   /* CONTABILIDADE         */
                          crapope.cddepart = 9  OR   /* COORD.PRODUTOS        */
                          crapope.cddepart = 10 OR   /* DESENVOLVIMENTO CECRED*/
                          crapope.cddepart = 11 OR   /* FINANCEIRO            */
                          crapope.cddepart = 12 OR   /* INTERNET              */
                          crapope.cddepart = 20 OR   /* TI                    */
                          crapope.cddepart = 17 OR   /* SISCAIXA              */
                          crapope.cddepart = 14 OR   /* PRODUTOS              */
                          crapope.cddepart =  8 OR   /* COORD.ADM/FINANCEIRO  */
                          crapope.cddepart = 18      /* SUPORTE               */
                          ) no-lock:

       create crabope.
       buffer-copy crapope except crapope.cdcooper TO crabope.
       assign crabope.cdcooper = aux_coop_nova.
       VALIDATE crabope.

   end.

   DISPLAY "crapope" skip with frame b.


   for each crapnsu where crapnsu.cdcooper = aux_ult_coop no-lock:

       create crabnsu.
       buffer-copy crapnsu except crapnsu.cdcooper TO crabnsu.
       assign crabnsu.cdcooper = aux_coop_nova.
       VALIDATE crabnsu.
   
   end.

   DISPLAY "crapnsu" skip with frame b.


   for each crapcsg where crapcsg.cdcooper = aux_ult_coop no-lock:

       create crabcsg.
       buffer-copy crapcsg except crapcsg.cdcooper TO crabcsg.
       assign crabcsg.cdcooper = aux_coop_nova.
       VALIDATE crabcsg.
   end.    

   DISPLAY "crapcsg" skip with frame b.
   
   for each crapsga where crapsga.cdcooper = aux_ult_coop no-lock:

       create crabsga.
       buffer-copy crapsga except crapsga.cdcooper TO crabsga.
       assign crabsga.cdcooper = aux_coop_nova.
       VALIDATE crabsga.
   end.    

   DISPLAY "crapsga" skip with frame b.

   for each crapsit where crapsit.cdcooper = aux_ult_coop no-lock:

       create crabsit.
       buffer-copy crapsit except crapsit.cdcooper TO crabsit.
       assign crabsit.cdcooper = aux_coop_nova.
       VALIDATE crabsit.
   end.    

   DISPLAY "crapsit" skip with frame b.

   for each gnctace where gnctace.cdcooper = aux_ult_coop no-lock:

       create b-gnctace.
       buffer-copy gnctace except gnctace.cdcooper TO b-gnctace.
       assign b-gnctace.cdcooper = aux_coop_nova.
       VALIDATE b-gnctace.
   end.    

   DISPLAY "gnctace" skip with frame b.
   
do   transaction: 
   
   for each crapage where crapage.cdcooper = aux_ult_coop and
                         (crapage.cdagenci = 1  or   /* PAC Operador MENU */  
                          crapage.cdagenci = 90 or  /* Internet */ 
                          crapage.cdagenci = 91)    /* TAA */ no-lock:

       create b-crapage.
       buffer-copy crapage 
              except crapage.cdcooper crapage.cdagepac  TO b-crapage.
       assign b-crapage.cdcooper = aux_coop_nova
              /* devido importacao do arquivo CAF nas demais coops enquanto nao
                 estiver em producao */
              b-crapage.cdagepac = 0. 
       VALIDATE b-crapage.
   end.    

   DISPLAY "crapage" skip with frame b.
   
   
   find crapcop where crapcop.cdcooper = aux_ult_coop no-lock no-error.
   
   if   avail crapcop  then
        do:
            create b-crapcop.
            buffer-copy crapcop 
            except crapcop.cdcooper crapcop.nmrescop crapcop.cdagectl
                   crapcop.cdagebcb crapcop.dsdircop crapcop.nrctactl
                   TO b-crapcop.
            assign b-crapcop.cdcooper = aux_coop_nova
                   b-crapcop.nmrescop = CAPS(aux_nmrescop)
                   b-crapcop.cdagectl = aux_cdagectl
                   b-crapcop.cdagebcb = 0
                   b-crapcop.nrctactl = aux_nrctactl
                   b-crapcop.dsdircop = aux_dsdircop.
            VALIDATE b-crapcop.
        end.    

   DISPLAY "crapcop" skip with frame b.


   CREATE b-crapmat.
   ASSIGN b-crapmat.cdcooper = aux_coop_nova.
   VALIDATE b-crapmat.
   
   DISPLAY "crapmat" skip with frame b.
   
   /* Criar somente administradora BRADESCO e seus limites */ 
   FIND crapadc WHERE crapadc.cdcooper = aux_ult_coop   AND
                      crapadc.cdadmcrd = 3
                      NO-LOCK NO-ERROR.
                      
   IF   AVAIL crapadc THEN
        DO:
            CREATE b-crapadc.
            BUFFER-COPY crapadc EXCEPT cdcooper TO b-crapadc.
            ASSIGN b-crapadc.cdcooper = aux_coop_nova.   
            VALIDATE b-crapadc.
            
            FOR EACH craptlc WHERE craptlc.cdcooper = aux_ult_coop AND
                                   craptlc.cdadmcrd = crapadc.cdadmcrd
                                   NO-LOCK:

                BUFFER-COPY craptlc EXCEPT cdcooper TO b-craptlc.
                ASSIGN b-craptlc.cdcooper = aux_coop_nova.
            
            END.

            DISPLAY "crapadc" skip with frame b.
            
            DISPLAY "craptlc  OK" skip with frame b.
                                   
        END.


end.  /* transaction */ 
   
   pause.
   
   /**********************************************************************/
   
   DISPLAY  "EXPORTANDO . . ."  SKIP(1) 
            WITH ROW 5   column 35 size 25  by 17   frame c.
      
                      
   output to value (aux_direxpor).
             
   for each craptab  no-lock where
            craptab.cdcooper = aux_ult_coop:

       export craptab.
   end.    

   output close.
                         
   
   DISPLAY "craptab    Ok"  with frame c.
   


 /*..........................................................................*/


