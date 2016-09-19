/* .............................................................................

   Programa: fontes/dsctit_bordero_vt.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2008                       Ultima atualizacao: 02/12/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para visualizar os titulos associados ao bordero.

   Alteracoes: 20/11/2008 - Substituido TODAY por glb_dtmvtolt (Evandro).

               28/04/2009 - Permitir valor negativo no prazo - rel_qtdprazo
                            (Fernando).
                            
               27/08/2012 - Alteração para separar titulos por tipo
                            de cobrança (Lucas).
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

               02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).    

............................................................................. */

DEF INPUT PARAM par_nrborder AS INTE                                NO-UNDO.
DEF INPUT PARAM par_nrdconta AS INTE                                NO-UNDO.

DEF STREAM str_1.

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0030tt.i }

DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                        NO-UNDO.
DEF VAR aux_dsdtraco AS CHAR                                        NO-UNDO.
DEF VAR tel_vltottit AS DECI EXTENT 3                               NO-UNDO.
DEF VAR tel_vltotliq AS DECI EXTENT 3                               NO-UNDO.
DEF VAR tel_qttottit AS INTE EXTENT 3                               NO-UNDO.
DEF VAR tel_qtrestri AS INTE EXTENT 3                               NO-UNDO.
DEF VAR tel_vlmedtit AS DECI EXTENT 3                               NO-UNDO.
DEF VAR aux_extncont AS INTE    INIT 1                              NO-UNDO.

DEF VAR aux_qtdprazo AS INTEGER                                     NO-UNDO.
DEF VAR aux_dscpfcgc AS CHAR                                        NO-UNDO.
DEF VAR aux_qtrestri AS INTEGER                                     NO-UNDO.
DEF VAR aux_dsdpagto AS CHAR                                        NO-UNDO.

DEF VAR tel_dsvisual AS CHAR VIEW-AS EDITOR SIZE 132 BY 15 PFCOLOR 0 NO-UNDO.   
 
DEF VAR h-b1wgen0030 AS HANDLE NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE NO-UNDO.

DEF FRAME f_visualiza
    tel_dsvisual HELP "Pressione <F4> ou <END> para finalizar" 
    WITH SIZE 78 BY 16 ROW 5 COLUMN 2 USE-TEXT NO-BOX NO-LABELS OVERLAY.

FORM "Vencimento  Nosso Numero                Valor   Valor Liquido"  AT  1
     "Prz  Pagador                           CPF/CNPJ"                AT 64
     "Situacao"                                                       AT 123
     SKIP(1)
     WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 132 FRAME f_cab.

FORM tt-tits_do_bordero.dtvencto    FORMAT "99/99/9999"
     tt-tits_do_bordero.nossonum    FORMAT "99999999999999999"   AT 13
     tt-tits_do_bordero.vltitulo    FORMAT "zzz,zzz,zz9.99"      AT 32
     tt-tits_do_bordero.vlliquid    FORMAT "zzz,zzz,zz9.99-"     AT 48
     aux_qtdprazo                   FORMAT "zz9-"                AT 64
     tt-tits_do_bordero.nmsacado    FORMAT "x(32)"               AT 69
     aux_dscpfcgc                   FORMAT "x(18)"               AT 103
     aux_dsdpagto                   FORMAT "x(9)"                AT 123
     WITH NO-BOX WIDTH 132 NO-LABELS DOWN FRAME f_titulos.

FORM SKIP(1)
     tt-tits_do_bordero.flgregis LABEL "Tipo de Cobranca" SKIP(1)
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_tpcobran.

FORM SKIP(1)
     "TOTAL ==>"           AT  1
     tel_qttottit[3]       AT 18  FORMAT "z,zz9" "TITULOS"
     tel_vltottit[3]       AT 32  FORMAT "zzz,zzz,zz9.99"
     tel_vltotliq[3]       AT 48  FORMAT "zzz,zzz,zz9.99-" 
     "    VLR. MEDIO:"
     tel_vlmedtit[3]              FORMAT "zz,zzz,zz9.99"     
     tel_qtrestri[3]       AT 95  FORMAT "z,zz9" "RESTRICAO(OES)"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total.

FORM SKIP (1)
     "TOTAL(S/ REG) ==>"   AT  1
     tel_qttottit[1]       AT 18  FORMAT "z,zz9" "TITULOS"
     tel_vltottit[1]       AT 32  FORMAT "zzz,zzz,zz9.99"
     tel_vltotliq[1]       AT 48  FORMAT "zzz,zzz,zz9.99-" 
     "    VLR. MEDIO:"
     tel_vlmedtit[1]              FORMAT "zz,zzz,zz9.99"     
     tel_qtrestri[1]       AT 95  FORMAT "z,zz9" "RESTRICAO(OES)"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total_sr.

FORM SKIP(1)
     "TOTAL(REGIST) ==>"   AT  1
     tel_qttottit[2]       AT 18  FORMAT "z,zz9" "TITULOS"
     tel_vltottit[2]       AT 32  FORMAT "zzz,zzz,zz9.99"
     tel_vltotliq[2]       AT 48  FORMAT "zzz,zzz,zz9.99-" 
     "    VLR. MEDIO:"
     tel_vlmedtit[2]              FORMAT "zz,zzz,zz9.99"     
     tel_qtrestri[2]       AT 95  FORMAT "z,zz9" "RESTRICAO(OES)"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total_cr.

FORM " ===>"
     tt-dsctit_bordero_restricoes.dsrestri FORMAT "x(60)"
     WITH NO-LABELS DOWN FRAME f_restricoes.

FORM aux_dsdtraco FORMAT "x(132)"
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_traco.

/* .......................................................................... */
RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.

IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
    DO:
        MESSAGE "Handle Invalido para b1wgen0030".
        RETURN.
    END.

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex"
       aux_dsdtraco = FILL("-",132).

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp).            

VIEW STREAM str_1 FRAME f_label.
                                             
RUN busca_titulos_bordero IN h-b1wgen0030
                                   (INPUT glb_cdcooper,
                                    INPUT par_nrborder,
                                    INPUT par_nrdconta,
                                    OUTPUT TABLE tt-tits_do_bordero,
                                    OUTPUT TABLE tt-dsctit_bordero_restricoes).
                                    
DELETE PROCEDURE h-b1wgen0030.

FOR EACH tt-tits_do_bordero NO-LOCK
        BREAK BY tt-tits_do_bordero.flgregis DESC:
       
    IF FIRST-OF (tt-tits_do_bordero.flgregis) THEN
                IF tt-tits_do_bordero.flgregis = TRUE THEN
                    ASSIGN aux_extncont = 2.
                ELSE
                    ASSIGN aux_extncont = 1.
        
    ASSIGN tel_vltottit[aux_extncont] = tel_vltottit[aux_extncont] + tt-tits_do_bordero.vltitulo
           tel_vltotliq[aux_extncont] = tel_vltotliq[aux_extncont] + tt-tits_do_bordero.vlliquid
           tel_qttottit[aux_extncont] = tel_qttottit[aux_extncont] + 1.
   
    IF  tt-tits_do_bordero.dtlibbdt <> ?  THEN
        ASSIGN aux_qtdprazo = tt-tits_do_bordero.dtvencto -
                              tt-tits_do_bordero.dtlibbdt.
    ELSE
        ASSIGN aux_qtdprazo = tt-tits_do_bordero.dtvencto - glb_dtmvtolt.

    IF  LENGTH(STRING(tt-tits_do_bordero.nrinssac)) > 11   THEN
        ASSIGN aux_dscpfcgc = STRING(tt-tits_do_bordero.nrinssac,
                                     "99999999999999")
               aux_dscpfcgc = STRING(aux_dscpfcgc,"xx.xxx.xxx/xxxx-xx").
    ELSE
        ASSIGN aux_dscpfcgc = STRING(tt-tits_do_bordero.nrinssac,
                                     "99999999999")
               aux_dscpfcgc = STRING(aux_dscpfcgc,"xxx.xxx.xxx-xx").

    IF FIRST-OF (tt-tits_do_bordero.flgregis) THEN
       DO:
           DISPLAY STREAM str_1 tt-tits_do_bordero.flgregis WITH FRAME f_tpcobran.
           VIEW STREAM str_1 FRAME f_identifica_cab.
       END.
    
    IF  tel_qttottit[aux_extncont] = 1 THEN
        VIEW STREAM str_1 FRAME f_cab.
                
    IF  tt-tits_do_bordero.insittit = 0  THEN
        ASSIGN aux_dsdpagto = "Pendente".
    ELSE
    IF  tt-tits_do_bordero.insittit = 1  THEN
        ASSIGN aux_dsdpagto = "Resgatado".
    ELSE
    IF  tt-tits_do_bordero.insittit = 2  THEN
        ASSIGN aux_dsdpagto = "Pago".
    ELSE
    IF  tt-tits_do_bordero.insittit = 3  THEN
        ASSIGN aux_dsdpagto = "Vencido".
    ELSE
    IF  tt-tits_do_bordero.insittit = 4  THEN
        ASSIGN aux_dsdpagto = "Liberado".
    ELSE
        ASSIGN aux_dsdpagto = "------".
        
    
    DISPLAY STREAM str_1
            tt-tits_do_bordero.dtvencto  tt-tits_do_bordero.nossonum
            tt-tits_do_bordero.vltitulo  tt-tits_do_bordero.vlliquid
            aux_qtdprazo                 tt-tits_do_bordero.nmsacado
            aux_dscpfcgc                 aux_dsdpagto
            WITH FRAME f_titulos.
                
    DOWN STREAM str_1 WITH FRAME f_titulos.

    /*  Leitura das restricoes para o titulo  */
    FOR EACH tt-dsctit_bordero_restricoes  WHERE 
             tt-dsctit_bordero_restricoes.nrdocmto =
             tt-tits_do_bordero.nrdocmto  NO-LOCK:
           
        DISPLAY STREAM str_1 tt-dsctit_bordero_restricoes.dsrestri
                WITH FRAME f_restricoes.

        DOWN STREAM str_1 WITH FRAME f_restricoes.

        ASSIGN tel_qtrestri[aux_extncont] = tel_qtrestri[aux_extncont] + 1.

    END.  /*  Fim do FOR EACH -- Leitura das restricoes  */
           
    DISPLAY STREAM str_1 aux_dsdtraco WITH FRAME f_traco.  

    IF LAST-OF (tt-tits_do_bordero.flgregis) THEN
       DO:
           ASSIGN tel_vlmedtit[aux_extncont] = ROUND(tel_vltottit[aux_extncont] 
                                                                / tel_qttottit[aux_extncont],2).

           IF (aux_extncont = 1) THEN
               DISPLAY STREAM str_1 tel_qttottit[aux_extncont]  tel_qtrestri[aux_extncont]
                                    tel_vltottit[aux_extncont]  tel_vltotliq[aux_extncont]
                                    tel_vlmedtit[aux_extncont]
                                    WITH FRAME f_total_sr.

           IF (aux_extncont = 2) THEN
               DISPLAY STREAM str_1 tel_qttottit[aux_extncont]  tel_qtrestri[aux_extncont]
                                    tel_vltottit[aux_extncont]  tel_vltotliq[aux_extncont]
                                    tel_vlmedtit[aux_extncont]
                                    WITH FRAME f_total_cr.
       END.
END.  /*  Fim do FOR EACH  */

IF  tel_qttottit[1] > 0 AND
    tel_qttottit[2] > 0 THEN
    DO:
        ASSIGN tel_qttottit[3] = tel_qttottit[1] + tel_qttottit[2]
               tel_qtrestri[3] = tel_qtrestri[1] + tel_qtrestri[2]
               tel_vltottit[3] = tel_vltottit[1] + tel_vltottit[2]
               tel_vltotliq[3] = tel_vltotliq[1] + tel_vltotliq[2]
               tel_vlmedtit[3] = ROUND(tel_vltottit[3] 
                                                     / tel_qttottit[3],2).
  
        DISPLAY STREAM str_1 tel_qttottit[3]  tel_qtrestri[3]
                             tel_vltottit[3]  tel_vltotliq[3]
                             tel_vlmedtit[3]
                             WITH FRAME f_total.
    END. 

OUTPUT STREAM str_1 CLOSE.

IF  tel_qttottit[1] > 0 OR
    tel_qttottit[2] > 0 THEN
    DO:
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
           ENABLE tel_dsvisual WITH FRAME f_visualiza.
           DISPLAY tel_dsvisual WITH FRAME f_visualiza.
           ASSIGN tel_dsvisual:READ-ONLY IN FRAME f_visualiza = YES.
        
           IF   tel_dsvisual:INSERT-FILE(aux_nmarqimp)   THEN
                DO:
                    ASSIGN tel_dsvisual:CURSOR-LINE IN FRAME f_visualiza = 1.
                    WAIT-FOR GO OF tel_dsvisual IN FRAME f_visualiza.
                END.
        
           LEAVE.
         
        END.  /*  Fim do DO WHILE TRUE  */
    END.
ELSE
    MESSAGE "Bordero sem titulos incluidos.".
    
HIDE FRAME f_visualiza NO-PAUSE.

/* .......................................................................... */
