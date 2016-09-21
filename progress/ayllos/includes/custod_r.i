/* ..........................................................................

   Programa: Includes/custod_r.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Abril/2000.                      Ultima atualizacao: 16/11/2009

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio de lotes de cheques em custodia digitados no
               dia (233).

   Alteracoes: Alterar nrdolote p/6 posicoes (Margarete/Planner).

               01/02/2001 - Acrescentar o NO-ERROR nos FIND's (Eduardo).

               18/11/2004 - Listar o numero da conta do associado (Edson).

               25/10/2005 - Alterado para mostrar relatorio detalhado se 
                            a flag for verdadeira (Diego).
                            
               24/11/2005 - Acrescentado totalizador Geral no final do
                            relatorio (Diego).
                            
               16/11/2009 - Opcao de imprimir por periodo (GATI - Eder)
........................................................................... */
       IF   FIRST-OF(crawlot.cdagenci)   THEN
            DO:
                IF   LINE-COUNTER(str_1) > 80  THEN
                     DO:
                         PAGE STREAM str_1.
                       
                         DISPLAY STREAM str_1 
                                 par_dtmvtini
                                 par_dtmvtfim
                                 tt-relat-custod.dsdsaldo 
                                 aux_vlchmatb
                                 WITH FRAME f_cab.
                     END.
            END.
   
       CLEAR FRAME f_lotes.
       
       DISPLAY STREAM str_1  
               crawlot.cdagenci  
               crawlot.nrdconta  
               crawlot.nrdolote 
               crawlot.qtchqcop  WHEN crawlot.qtchqcop > 0
               crawlot.vlchqcop  WHEN crawlot.vlchqcop > 0 
               crawlot.qtchqmen  WHEN crawlot.qtchqmen > 0
               crawlot.vlchqmen  WHEN crawlot.vlchqmen > 0
               crawlot.qtchqmai  WHEN crawlot.qtchqmai > 0    
               crawlot.vlchqmai  WHEN crawlot.vlchqmai > 0
               crawlot.qtchqtot 
               crawlot.vlchqtot 
               crawlot.dtlibera 
               crawlot.nmoperad
               WITH FRAME f_lotes.

       IF   par_flgrelat = YES  THEN
            DO:
                IF   LINE-COUNTER(str_1) > 75  THEN
                     PAGE STREAM str_1.
                
                DISPLAY STREAM str_1 WITH FRAME f_titulo.
                                
                FOR EACH crabcst WHERE crabcst.indrelat = crawlot.indrelat AND
                                       crabcst.cdagenci = crawlot.cdagenci AND
                                       crabcst.nrdconta = crawlot.nrdconta AND
                                       crabcst.nrdolote = crawlot.nrdolote
                                       BREAK BY crabcst.nrdolote:
                    
                    DISPLAY STREAM str_1
                                   crabcst.dtlibera
                                   crabcst.cdcmpchq
                                   crabcst.cdbanchq
                                   crabcst.cdagechq
                                   crabcst.nrctachq
                                   crabcst.nrcheque 
                                   crabcst.vlcheque 
                                   crabcst.dsdocmc7 WITH FRAME f_detalhado.

                    DOWN STREAM str_1 WITH FRAME f_detalhado.   
                    
                    IF   LAST-OF(crabcst.nrdolote)  THEN                   
                         DOWN 2 STREAM str_1 WITH FRAME f_detalhado.
                         
                    IF   LINE-COUNTER(str_1) > 80  THEN
                         PAGE STREAM str_1.
                END.
            END.
            
       ASSIGN pac_qtdlotes = pac_qtdlotes + 1
              pac_qtchqcop = pac_qtchqcop + crawlot.qtchqcop
              pac_qtchqmen = pac_qtchqmen + crawlot.qtchqmen 
              pac_qtchqmai = pac_qtchqmai + crawlot.qtchqmai
              pac_qtchqtot = pac_qtchqtot + crawlot.qtchqtot

              pac_vlchqcop = pac_vlchqcop + crawlot.vlchqcop 
              pac_vlchqmen = pac_vlchqmen + crawlot.vlchqmen 
              pac_vlchqmai = pac_vlchqmai + crawlot.vlchqmai
              pac_vlchqtot = pac_vlchqtot + crawlot.vlchqtot.
              

       DOWN STREAM str_1 WITH FRAME f_lotes.                      

       IF   NOT LAST-OF(crawlot.cdagenci)   THEN
            NEXT.   
               
       CLEAR FRAME f_pac.
       
       IF   LINE-COUNTER(str_1) > 72  THEN
            PAGE STREAM str_1.
       
       DISPLAY STREAM str_1 
               pac_qtdlotes  
               pac_qtchqcop WHEN pac_qtchqcop > 0
               pac_vlchqcop WHEN pac_vlchqcop > 0
               pac_qtchqmen WHEN pac_qtchqmen > 0
               pac_vlchqmen WHEN pac_vlchqmen > 0
               pac_qtchqmai WHEN pac_qtchqmai > 0
               pac_vlchqmai WHEN pac_vlchqmai > 0
               pac_qtchqtot  
               pac_vlchqtot
               pac_dsdtraco
               WITH FRAME f_pac.

       ASSIGN aux_geralchq = aux_geralchq +  pac_vlchqtot.

       IF   LINE-COUNTER(str_1) > 80  THEN
            DO:
                PAGE STREAM str_1.
                       
                DISPLAY STREAM str_1 par_dtmvtini
                                     par_dtmvtfim
                                     tt-relat-custod.dsdsaldo 
                                     aux_vlchmatb 
                                     WITH FRAME f_cab.
            END.
       
       ASSIGN pac_qtdlotes = 0
              pac_qtchqcop = 0 
              pac_qtchqmen = 0 
              pac_qtchqmai = 0 
              pac_qtchqtot = 0 

              pac_vlchqcop = 0
              pac_vlchqmen = 0 
              pac_vlchqmai = 0
              pac_vlchqtot = 0.
/* ......................................................................... */
