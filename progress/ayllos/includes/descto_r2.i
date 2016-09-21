/* ............................................................................

   Programa: Includes/descto_r2.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson  
   Data    : Outubro/2003.                       Ultima atualizacao: 23/11/2009

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio de lotes de cheques descontados no dia (308).

   Alteracoes: 23/11/2009 - Estruturacao do programa em BO (GATI - Eder)
............................................................................ */

       IF   FIRST-OF(crawlot.cdagenci)   THEN
            DO:
                IF   LINE-COUNTER(str_1) > 80  THEN
                     DO:
                         PAGE STREAM str_1.
                       
                         DISPLAY STREAM str_1 
                                 par_dtmvtolt 
                                 tt-relat-lotes.dsdsaldo 
                                 tt-relat-lotes.vlchmatb
                                 WITH FRAME f_cab.
                     END.
            END.
   
       CLEAR FRAME f_lotes.
       
       DISPLAY STREAM str_1  
               crawlot.dtmvtolt
               crawlot.cdagenci  
               crawlot.nrdconta  
               crawlot.nrborder
               crawlot.nrdolote 
               crawlot.qtchqcop  WHEN crawlot.qtchqcop > 0
               crawlot.vlchqcop  WHEN crawlot.vlchqcop > 0 
               crawlot.qtchqmen  WHEN crawlot.qtchqmen > 0
               crawlot.vlchqmen  WHEN crawlot.vlchqmen > 0
               crawlot.qtchqmai  WHEN crawlot.qtchqmai > 0    
               crawlot.vlchqmai  WHEN crawlot.vlchqmai > 0
               crawlot.qtchqtot 
               crawlot.vlchqtot 
               crawlot.nmoperad
               WITH FRAME f_lotes.

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

       IF   LINE-COUNTER(str_1) > 80  THEN
            DO:
                PAGE STREAM str_1.
                       
                DISPLAY STREAM str_1 
                        par_dtmvtolt 
                        tt-relat-lotes.dsdsaldo 
                        tt-relat-lotes.vlchmatb
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
