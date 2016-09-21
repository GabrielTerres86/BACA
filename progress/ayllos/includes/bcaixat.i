/* .............................................................................

   Programa: Includes/Bcaixat.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : GATI - DIEGO
   Data    : Abril/2011                  Ultima alteracao: 18/02/2015

   Dados referentes ao programa:

   Objetivo  : Consultar saldo atual dos caixas em tela.
   
   Alteracoes: 31/10/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).

               22/01/2013 - Adicionada coluna PAC no browse bcaixa-t (Daniele).
               
               23/04/2013 - Incluir browse bcofre-t referente ao Projeto de
                            Sangria de Caixa (Lucas R.).
                            
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).
               
               18/02/2015 - Incluir aux_tpcaicof = "TOTAL" (Lucas R. #245838)
............................................................................. */

DEF QUERY bcaixa-t FOR tt_crapbcx
                   FIELDS (nrdcaixa nmoperad).

DEF BROWSE bcaixa-t QUERY bcaixa-t
    DISP tt_crapbcx.cdagenci       COLUMN-LABEL "PA" 
         tt_crapbcx.nrdcaixa       COLUMN-LABEL "Caixa"
         tt_crapbcx.nmoperad       COLUMN-LABEL "Operador"
         tt_crapbcx.vldsdtot       COLUMN-LABEL "Saldo"
         tt_crapbcx.csituaca       COLUMN-LABEL "Situacao"
         WITH 8 DOWN WIDTH 75 OVERLAY.

DEF QUERY bcofre-t FOR tt_crapbcx.

DEF BROWSE bcofre-t QUERY bcofre-t
    DISP tt_crapbcx.cdagenci       COLUMN-LABEL "PA"
         tt_crapbcx.vldsdtot       COLUMN-LABEL "Saldo"
         WITH 8 DOWN WIDTH 25 OVERLAY .

DEF FRAME f_cofre
     bcofre-t  
     tot_saldot AT 2 
     WITH NO-BOX CENTERED SIDE-LABELS OVERLAY.
                                      
DEF FRAME f_saldot
    bcaixa-t            HELP "Use as SETAS para navegar ou F4 para sair" SKIP 
    tot_saldot   AT 25 HELP "Use <TAB> para navegar" 
    WITH NO-BOX CENTERED SIDE-LABELS OVERLAY.

/* Inicio Total da opcao T */
DEF QUERY btotal-t FOR tt_crapbcx.

DEF BROWSE btotal-t QUERY btotal-t
    DISP tt_crapbcx.cdagenci COLUMN-LABEL "PA"
         tt_crapbcx.vltotcof COLUMN-LABEL "Cofre" 
         tt_crapbcx.vltotcai COLUMN-LABEL "Caixa" 
         WITH 8 DOWN WIDTH 40 OVERLAY.

DEF FRAME f_total-t
    btotal-t HELP "Use as SETAS para navegar ou F4 para sair"
    tot_saldot AT 10 HELP "Use <TAB> para navegar" 
    WITH NO-BOX CENTERED SIDE-LABELS OVERLAY.
/* Final Total da opcao T */

/*******total por pa********/
DEF QUERY btotalpa-t FOR tt_crapbcx.

DEF BROWSE btotalpa-t QUERY btotalpa-t
    DISP tt_crapbcx.cdagenci COLUMN-LABEL "PA"
         tt_crapbcx.totcacof COLUMN-LABEL "Saldo(Caixa + Cofre)"
         WITH 8 DOWN WIDTH 30 OVERLAY.

DEF FRAME f_totalpa-t
    btotalpa-t HELP "Use as SETAS para navegar ou F4 para sair"
    tot_saldot AT 8 HELP "Use <TAB> para navegar" 
    WITH NO-BOX CENTERED SIDE-LABELS OVERLAY.
/***************/

IF  aux_tpcaicof = "COFRE" THEN 
    DO: 
         OPEN QUERY bcofre-t FOR EACH tt_crapbcx.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            ENABLE bcofre-t WITH FRAME f_cofre.
            DISPLAY tot_saldot WITH FRAME f_cofre.
            WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
         END.
          
         HIDE FRAME f_cofre.
         
    END.
ELSE IF aux_tpcaicof = "TOTAL" THEN 
    DO:
        IF  tel_cdagenci <> 0 THEN
            DO: 
                OPEN QUERY btotal-t FOR EACH tt_crapbcx.
        
                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:


                    ENABLE btotal-t WITH FRAME f_total-t.
                    DISPLAY tot_saldot WITH FRAME f_total-t.
                    WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
                END.
        
                HIDE FRAME f_total-t.
            END.
        ELSE
            DO:
               OPEN QUERY btotalpa-t FOR EACH tt_crapbcx BY tt_crapbcx.cdagenci.
        
                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    ENABLE btotalpa-t WITH FRAME f_totalpa-t.
                    DISPLAY tot_saldot WITH FRAME f_totalpa-t.
                    WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
                END.
        
                HIDE FRAME f_totalpa-t. 
            END.
    END.
ELSE
    DO:
        OPEN QUERY bcaixa-t FOR EACH tt_crapbcx.
        
            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                ASSIGN glb_dscritic = "".
                ENABLE bcaixa-t    WITH FRAME f_saldot.
                DISPLAY tot_saldot WITH FRAME f_saldot.
                WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
            END.
            
            HIDE FRAME f_saldot.
    END.





