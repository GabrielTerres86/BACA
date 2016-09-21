/* ...........................................................................

   Programa: Fontes/proepr_org.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jonata(RKAM)
   Data    : Agosto/2014.                     Ultima atualizacao: 22/04/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento dos orgaos de protecao ao credito para a
               proposta de emprestimo da ATENDA.
               Projeto Automatização de Consultas em Propostas de 
               Crédito (Jonata-RKAM). 

   Alteracoes: 26/11/2014 - Aumentar formato do valor das anotacoes 
                           (Jonata-RKAM).
                           
               09/12/2014 - Aumentar o foramto da descricao da informacao
                            cadastral (Jonata-RKAM)            
                            
               22/04/2015 - Consultas automatizadas para o limite de credito
                            (Gabriel-RKAM).             
........................................................................... */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0024tt.i }
{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen0191tt.i }
{ sistema/generico/includes/var_oracle.i   }

{ includes/var_online.i     }
{ includes/var_atenda.i     }
{ includes/var_proepr.i     }


DEF INPUT PARAM par_nrdconta AS INTE                                   NO-UNDO.
DEF INPUT PARAM par_nrctremp AS INTE                                   NO-UNDO.
DEF INPUT PARAM par_iddoaval AS INTE                                   NO-UNDO.
DEF INPUT PARAM par_inpessoa AS INTE                                   NO-UNDO.
DEF INPUT PARAM par_nrctacon AS INTE                                   NO-UNDO.
DEF INPUT PARAM par_nrcpfcon AS DECI                                   NO-UNDO.
DEF INPUT PARAM TABLE FOR tt-itens-topico-rating.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-dados-analise.   
      

DEF VAR aux_nrsequen AS INTE                                           NO-UNDO.
DEF VAR aux_nrconbir AS INTE                                           NO-UNDO.
DEF VAR aux_nrseqdet AS INTE                                           NO-UNDO.
DEF VAR aux_cdbircon AS INTE                                           NO-UNDO.
DEF VAR aux_dsbircon AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_cdmodbir AS INTE                                           NO-UNDO.
DEF VAR aux_dssituac AS CHAR                                           NO-UNDO.
DEF VAR aux_dsretorn AS CHAR                                           NO-UNDO.
DEF VAR aux_dsmodbir AS CHAR                                           NO-UNDO.

DEF VAR tel_nmtitcon AS CHAR                                           NO-UNDO.
DEF VAR tel_dtconbir AS DATE                                           NO-UNDO.
DEF VAR tel_nmtitcab AS CHAR                                           NO-UNDO.
DEF VAR tel_dsnegati AS CHAR EXTENT 99                                 NO-UNDO.
DEF VAR tel_vlnegati AS DECI EXTENT 99                                 NO-UNDO.
DEF VAR tel_dtultneg AS DATE EXTENT 99                                 NO-UNDO.
DEF VAR tel_dsconsul AS CHAR                                           NO-UNDO.
DEF VAR tel_dscpfcgc AS CHAR                                           NO-UNDO.
DEF VAR tel_inreapro AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0043 AS HANDLE                                         NO-UNDO.


FORM SKIP(15)
     WITH OVERLAY CENTERED SIDE-LABELS ROW 5 WIDTH 78 TITLE COLOR NORMAL
           " Orgaos de Protecao ao Credito " FRAME f_orgaos_protecao.

FORM SKIP(1)
     "Dados do Avalista Fiador (" AT 03 
     par_iddoaval              NO-LABEL                 FORMAT "9" 
     "):"
     tel_nmtitcon              NO-LABEL                 FORMAT "x(35)"   
     WITH NO-BOX OVERLAY CENTERED SIDE-LABELS ROW 06 WIDTH 76 
          FRAME f_dados_aval.

FORM tel_nmtitcon LABEL "Consulta Conjuge" AT 03        FORMAT "x(40)"
     WITH NO-BOX OVERLAY CENTERED SIDE-LABELS ROW 07 WIDTH 76 
          FRAME f_dados_conjuge. 

FORM tt-dados-analise.nrinfcad AT 03 LABEL "Inf. Cadastrais"  FORMAT "zz9"
       HELP "Informe o codigo da informacao ou <F7> para listar."
       VALIDATE (tt-dados-analise.nrinfcad <> 0,
                 "375 - O campo deve ser preenchido.")
     tt-dados-analise.dsinfcad AT 25 NO-LABEL                 FORMAT "x(50)"
     SKIP
     tt-dados-analise.dtcnsspc AT 03 LABEL "Data da Consulta" FORMAT "99/99/9999"
       HELP "Informe a data de consulta SPC."  
       VALIDATE (tt-dados-analise.dtcnsspc <= glb_dtmvtolt OR
                 tt-dados-analise.dtcnsspc = ?,
                 "013 - Data errada.")
     tel_inreapro              AT 46 LABEL "Reaproveitamento" FORMAT "x(3)"
     SKIP(1)
     tel_dsconsul              AT 25 NO-LABEL                 FORMAT "x(30)"  
     SKIP(1)    
     WITH NO-BOX OVERLAY CENTERED SIDE-LABELS ROW 07 WIDTH 76 
          FRAME f_dados_rating.

FORM tel_dtconbir        AT 03 LABEL "Data da Consulta" FORMAT "99/99/9999"
     tel_inreapro        AT 46 LABEL "Reaproveitamento" FORMAT "x(3)"
     SKIP(1)
     tel_dsconsul        AT 25 NO-LABEL                 FORMAT "x(30)"  
     SKIP(1)
     WITH NO-BOX OVERLAY CENTERED SIDE-LABELS ROW 08 WIDTH 76 FRAME f_consulta.

FORM tel_dsconsul        AT 25 NO-LABEL                 FORMAT "x(30)"  
     SKIP(1)
     WITH NO-BOX OVERLAY CENTERED SIDE-LABELS ROW 10 WIDTH 76 
          FRAME f_consulta_soc.

FORM SKIP
     tt-central-risco.dtdrisco AT 03 LABEL "Consulta Socio"
        HELP "Informe a data da consulta na central de risco."
                                                             FORMAT "99/99/9999"
        VALIDATE(tt-dados-analise.dtdrisco <= glb_dtmvtolt OR
                 tt-dados-analise.dtdrisco = ?,
                 "013 - Data errada.")

     tt-central-risco.qtopescr AT 32 LABEL "Qtd Operacoes"   FORMAT "zzz,zz9"
        HELP "Informe a quantidade de operacoes."
     
     tt-central-risco.qtifoper AT 56 LABEL "Qtd. IF com ope." 
                                                             FORMAT "z9"  
        HELP "Informe a quantidade de IF em que possui operacoes."
     
     SKIP   
     tt-central-risco.vltotsfn AT 03 LABEL "Endividamento" FORMAT "zz,zzz,zz9.99"
        HELP "Valor total do Sistema Financeiro Nacional com a Cooperativa."
     
     tt-central-risco.vlopescr AT 32 LABEL "Vencidas"      FORMAT "z,zzz,zz9.99"
        HELP "Informe o valor das operacoes vencidas."
     
     tt-central-risco.vlrpreju AT 56 LABEL "Prej."         FORMAT "z,zzz,zz9.99"        
        HELP "Informe o valor do prejuizo."
     WITH NO-BOX OVERLAY CENTERED SIDE-LABELS ROW 7 WIDTH 76 FRAME f_bacen.

FORM SKIP(2)
     "Quantidade"       AT 25
     "Valor"            AT 52
     SKIP
     "SPC"              AT 03                   
     tel_dsnegati[99]   AT 25 FORMAT "x(11)"
     tel_vlnegati[99]   AT 45 FORMAT "z,zzz,zz9.99"
     SKIP                     
     "Pefin/Refin"      AT 03 
     tel_dsnegati[98]   AT 25 FORMAT "x(11)"
     tel_vlnegati[98]   AT 45 FORMAT "z,zzz,zz9.99"
     SKIP                     
     "Cheque sem fundo" AT 03 
     tel_dsnegati[06]   AT 25 FORMAT "x(11)"
     tel_vlnegati[06]   AT 45 FORMAT "z,zzz,zz9.99"
     SKIP                     
     "Protesto"         AT 03 
     tel_dsnegati[03]   AT 25 FORMAT "x(11)"
     WITH NO-BOX NO-LABEL OVERLAY CENTERED SIDE-LABELS ROW 10 WIDTH 76 
          FRAME f_anotacoes_spc.

FORM SKIP(1)                         
     "Quantidade"    AT 28
     "Valor total"   AT 43
     "Data ultima"   AT 57
     SKIP
     "REFIN"                  AT 03
     tel_dsnegati[1] AT 28 FORMAT "x(11)"     
     tel_vlnegati[1] AT 42 FORMAT "z,zzz,zz9.99"  
     tel_dtultneg[1] AT 57 FORMAT "99/99/9999" 
     SKIP           
     "PEFIN"                  AT 03
     tel_dsnegati[2] AT 28 FORMAT "x(11)"
     tel_vlnegati[2] AT 42 FORMAT "z,zzz,zz9.99"
     tel_dtultneg[2] AT 57 FORMAT "99/99/9999" 
     SKIP
     "ACAO JUDICIAL"          AT 03
     tel_dsnegati[4] AT 28 FORMAT "x(11)"     
     tel_vlnegati[4] AT 42 FORMAT "z,zzz,zz9.99"   
     tel_dtultneg[4] AT 57 FORMAT "99/99/9999"
     SKIP
     "PARTICIPACAO FALENCIA." AT 03
     tel_dsnegati[5] AT 28 FORMAT "x(11)"     
     tel_vlnegati[5] AT 42 FORMAT "z,zzz,zz9.99"  
     tel_dtultneg[5] AT 57 FORMAT "99/99/9999" 
     SKIP
     "CHEQUE SEM FUNDO"       AT 03
     tel_dsnegati[6] AT 28 FORMAT "x(11)"     
     tel_vlnegati[6] AT 42 FORMAT "z,zzz,zz9.99"  
     tel_dtultneg[6] AT 57 FORMAT "99/99/9999"    
     SKIP
     "CHEQUE SUST./EXTRAV."   AT 03
     tel_dsnegati[7] AT 28 FORMAT "x(11)"     
     tel_vlnegati[7] AT 42 FORMAT "z,zzz,zz9.99"  
     tel_dtultneg[7] AT 57 FORMAT "99/99/9999"  
     SKIP
     "PROTESTO"               AT 03
     tel_dsnegati[3] AT 28 FORMAT "x(11)"     
     tel_vlnegati[3] AT 42 FORMAT "z,zzz,zz9.99"  
     tel_dtultneg[3] AT 57 FORMAT "99/99/9999"  
     WITH NO-BOX NO-LABEL OVERLAY CENTERED WIDTH 76 ROW 11
          FRAME f_anotacoes_serasa_pf.
         
FORM "Socio da empresa:" AT 03
     tt-crapcbd.dscpfcgc AT 21 LABEL "CPF"  FORMAT "x(16)"
     tt-crapcbd.nmtitcon AT 42 LABEL "Nome" FORMAT "x(25)"
     WITH NO-BOX OVERLAY CENTERED SIDE-LABELS WIDTH 76 FRAME f_socio.

RUN sistema/generico/procedures/b1wgen0191.p PERSISTENT SET h-b1wgen0191.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE 
              ON ERROR  UNDO, LEAVE:

    RUN Busca_Biro_Emp_Lim IN h-b1wgen0191 (INPUT glb_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT 1, /* inprodut */
                                            INPUT par_nrctremp,
                                            INPUT par_nrctacon,
                                            INPUT par_nrcpfcon,
                                           OUTPUT aux_nrconbir,
                                           OUTPUT aux_nrseqdet).

    RUN Busca_Situacao IN h-b1wgen0191 (INPUT aux_nrconbir,
                                        INPUT aux_nrseqdet,
                                       OUTPUT aux_cdbircon,
                                       OUTPUT aux_dsbircon,
                                       OUTPUT aux_cdmodbir,
                                       OUTPUT aux_dssituac,
                                       OUTPUT aux_dsmodbir).

    RUN Consulta_Geral IN h-b1wgen0191 (INPUT aux_nrconbir,
                                        INPUT aux_nrseqdet,
                                       OUTPUT aux_dscritic,
                                       OUTPUT TABLE tt-xml-geral).

    ASSIGN aux_dsretorn = RETURN-VALUE.

    VIEW FRAME f_orgaos_protecao.

    PAUSE 0.

    RUN Busca_Dados_Consultado IN h-b1wgen0191 (INPUT par_inpessoa,
                                                INPUT TABLE tt-xml-geral,
                                               OUTPUT tel_nmtitcon,
                                               OUTPUT tel_dtconbir,
                                               OUTPUT tel_nmtitcab,
                                               OUTPUT tel_dscpfcgc,
                                               OUTPUT tel_inreapro).

    RUN Trata_Anotacoes IN h-b1wgen0191 (INPUT TABLE tt-xml-geral,
                                         OUTPUT tel_dsnegati,
                                         OUTPUT tel_vlnegati,
                                         OUTPUT tel_dtultneg,
                                         OUTPUT TABLE tt-craprpf).

    IF   aux_cdbircon = 1   OR 
         aux_cdbircon = 0   THEN
         DO:
             RUN exibe_spc.            
         END.
    ELSE 
    IF   aux_cdbircon = 2   AND
         par_inpessoa = 1   THEN   
         DO:
             RUN exibe_serasa_pf.
         END.
    ELSE 
    IF   aux_cdbircon = 2   THEN
         DO:
             RUN exibe_serasa_pj.
         END.

    LEAVE.

END.

HIDE FRAME f_orgaos_protecao.
HIDE FRAME f_dados_aval.
HIDE FRAME f_dados_conjuge.
HIDE FRAME f_consulta.
HIDE FRAME f_dados_rating.
HIDE FRAME f_anotacoes_spc.
HIDE FRAME f_anotacoes_serasa_pf.
HIDE FRAME f_socio.

DELETE PROCEDURE h-b1wgen0191.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
     RETURN "NOK".

RETURN "OK".


PROCEDURE exibe_spc:
 
   IF   aux_dsretorn = "OK"   THEN
        DO:
             ASSIGN tel_dsconsul = "Consulta: " + aux_dsbircon + "-" + 
                                   aux_dsmodbir.
        
             DISPLAY tel_dsnegati[99]  
                     tel_vlnegati[99] WHEN tel_dsnegati[99] <> "Nada Consta" 
                     tel_dsnegati[98] 
                     tel_vlnegati[98] WHEN tel_dsnegati[98] <> "Nada Consta" 
                     tel_dsnegati[03]  
                     tel_dsnegati[06]  
                     tel_vlnegati[06] WHEN tel_dsnegati[06] <> "Nada Consta"
                     WITH FRAME f_anotacoes_spc.

             PAUSE 0.
        END.
     
   RUN mostra_dados_iniciais.
                                         
   PAUSE MESSAGE "Pressione <ENTER> p/ continuar - <F4> ou <END> p/ sair.".

END PROCEDURE.

PROCEDURE exibe_serasa_pf:  

   IF   aux_dsretorn = "OK"   THEN
        DO:
            ASSIGN tel_dsconsul = "Consulta: " + aux_dsbircon + "-" + 
                                  aux_dsmodbir.
  
            DISPLAY tel_dsnegati[2] 
                    tel_vlnegati[2] WHEN tel_dsnegati[02] <> "Nada Consta"
                    tel_dtultneg[2]   
                    tel_dsnegati[3]
                    tel_vlnegati[3] WHEN tel_dsnegati[03] <> "Nada Consta"
                    tel_dtultneg[3]   
                    tel_dsnegati[6]
                    tel_vlnegati[6] WHEN tel_dsnegati[06] <> "Nada Consta"
                    tel_dtultneg[6]   
                    tel_dsnegati[1] 
                    tel_vlnegati[1] WHEN tel_dsnegati[01] <> "Nada Consta"
                    tel_dtultneg[1]   
                    tel_dsnegati[4]
                    tel_vlnegati[4] WHEN tel_dsnegati[04] <> "Nada Consta"
                    tel_dtultneg[4]   
                    tel_dsnegati[5] 
                    tel_vlnegati[5] WHEN tel_dsnegati[05] <> "Nada Consta"
                    tel_dtultneg[5]   
                    tel_dsnegati[7]
                    tel_vlnegati[7] WHEN tel_dsnegati[07] <> "Nada Consta"
                    tel_dtultneg[7] 
                    WITH FRAME f_anotacoes_serasa_pf.
        END.

   RUN mostra_dados_iniciais.

   PAUSE MESSAGE "Pressione <ENTER> p/ continuar - <F4> ou <END> p/ sair.".

END PROCEDURE.

PROCEDURE exibe_serasa_pj:

   DEF VAR aux_dscpfcgc AS CHAR                                        NO-UNDO.

   RUN Trata_Societarios IN h-b1wgen0191 (INPUT TABLE tt-xml-geral, 
                                          INPUT 1,
                                         OUTPUT TABLE tt-crapcbd).

   RUN Trata_Anotacoes_Pj IN h-b1wgen0191 (INPUT TABLE tt-xml-geral,
                                          OUTPUT TABLE tt-craprpf).

   RUN exibe_serasa_pf.

   IF   NOT aux_dsretorn = "OK"   THEN
        RETURN.

   HIDE FRAME f_consulta.
   HIDE FRAME f_dados_rating.

   IF   par_iddoaval > 0   THEN
        RETURN.

   FOR EACH tt-crapcbd BREAK BY tt-crapcbd.dscpfcgc:
   
       DISPLAY tt-crapcbd.dscpfcgc
               tt-crapcbd.nmtitcon
               WITH FRAME f_socio ROW 06.

       ASSIGN aux_dscpfcgc = REPLACE(tt-crapcbd.dscpfcgc,".","")
              aux_dscpfcgc = REPLACE(aux_dscpfcgc,"/","")
              aux_dscpfcgc = REPLACE(aux_dscpfcgc,"-",""). 

       RUN sistema/generico/procedures/b1wgen0024.p 
           PERSISTENT SET h-b1wgen0024.

       RUN obtem-valores-central-risco IN h-b1wgen0024
                             (INPUT glb_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT glb_cdoperad,
                              INPUT glb_nmdatela,
                              INPUT 1, /* Ayllos */
                              INPUT glb_dtmvtolt,
                              INPUT 4, /* crapvop/crappf */
                              INPUT 0,
                              INPUT 90,
                              INPUT par_nrctremp,
                              INPUT 0,
                              INPUT DECI(aux_dscpfcgc),
                              INPUT FALSE,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-central-risco).

       DELETE PROCEDURE h-b1wgen0024.

       FIND FIRST tt-central-risco NO-ERROR.
    
       IF   NOT AVAIL tt-central-risco   THEN
            CREATE tt-central-risco.
    
       DISPLAY  tt-central-risco.dtdrisco 
                tt-central-risco.qtopescr 
                tt-central-risco.qtifoper 
                tt-central-risco.vltotsfn 
                tt-central-risco.vlopescr 
                tt-central-risco.vlrpreju WITH FRAME f_bacen.
    
       PAUSE 0.
    
       DISPLAY tel_dsconsul WITH FRAME f_consulta_soc.
          
       PAUSE 0.

       CLEAR FRAME f_anotacoes_serasa_pf ALL. 

       ASSIGN tel_dsnegati = ""
              tel_vlnegati = 0 
              tel_dtultneg = ?. 

       FOR EACH tt-craprpf WHERE tt-craprpf.dscpfcgc = tt-crapcbd.dscpfcgc:

            ASSIGN tel_dsnegati[tt-craprpf.innegati] = 
                        tt-craprpf.dsnegati 
                   tel_vlnegati[tt-craprpf.innegati] =
                        tt-craprpf.vlnegati
                   tel_dtultneg[tt-craprpf.innegati] = 
                        tt-craprpf.dtultneg.     

       END.

       DISPLAY SKIP
               tel_dsnegati[2] 
               tel_vlnegati[2] WHEN tel_dsnegati[02] <> "Nada Consta"
               tel_dtultneg[2] 
               tel_dsnegati[3]
               tel_vlnegati[3] WHEN tel_dsnegati[03] <> "Nada Consta" 
               tel_dtultneg[3]
               tel_dsnegati[6] 
               tel_vlnegati[6] WHEN tel_dsnegati[06] <> "Nada Consta"
               tel_dtultneg[6]
               tel_dsnegati[1]
               tel_vlnegati[1] WHEN tel_dsnegati[01] <> "Nada Consta"
               tel_dtultneg[1]
               tel_dsnegati[4] 
               tel_vlnegati[4] WHEN tel_dsnegati[04] <> "Nada Consta"
               tel_dtultneg[4]
               tel_dsnegati[5]
               tel_vlnegati[5] WHEN tel_dsnegati[05] <> "Nada Consta"
               tel_dtultneg[5]
               tel_dsnegati[7] 
               tel_vlnegati[7] WHEN tel_dsnegati[07] <> "Nada Consta"
               tel_dtultneg[7]
               WITH FRAME f_anotacoes_serasa_pf.

       PAUSE MESSAGE "Pressione <ENTER> p/ continuar - <F4> ou <END> p/ sair.".

   END.

END PROCEDURE.

PROCEDURE mostra_dados_iniciais:

   /* Dados do avalista */
   IF   par_iddoaval > 0   THEN
        DO:   
            IF   par_iddoaval = 99   THEN 
                 DISPLAY tel_nmtitcon WITH FRAME f_dados_conjuge.
            ELSE
                 DISPLAY par_iddoaval
                         tel_nmtitcon WITH FRAME f_dados_aval.
           
            PAUSE 0.
           
            DISPLAY tel_dsconsul
                    tel_dtconbir 
                    tel_inreapro WITH FRAME f_consulta. 
           
            PAUSE 0.
        END.
   ELSE  
        DO: 
            FIND FIRST tt-dados-analise NO-ERROR.
       
            /* Dados do titular */
            IF  (NOT glb_cddopcao = "A"        AND 
                 NOT glb_cddopcao = "I")       OR
                 glb_nmrotina = "PRESTACOES"   THEN
                 DO:
                     PAUSE 0.   

                     DISPLAY  tel_dsconsul  
                              tt-dados-analise.dtcnsspc  
                              tel_inreapro
                              tt-dados-analise.nrinfcad 
                              tt-dados-analise.dsinfcad 
                              WITH FRAME f_dados_rating.
                     
                     PAUSE 0.
                 END.
            ELSE 
                 DO:
                     DISPLAY tel_dsconsul
                             tel_inreapro
                             tt-dados-analise.dsinfcad 
                              WITH FRAME f_dados_rating.

                     DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

                        UPDATE tt-dados-analise.nrinfcad 
                               tt-dados-analise.dtcnsspc 
                               WITH FRAME f_dados_rating

                        EDITING:

                            READKEY.
                           
                            IF   FRAME-FIELD = "nrinfcad"  AND
                                 LASTKEY = KEYCODE("F7")   THEN
                                 DO:                                 
                                      IF   par_inpessoa = 1 THEN
                                           RUN sequencia_rating 
                                              (INPUT 1,
                                               INPUT 4,
                                        INPUT-OUTPUT tt-dados-analise.nrinfcad,
                                        INPUT-OUTPUT tt-dados-analise.dsinfcad).
                                      ELSE
                                           RUN sequencia_rating
                                              (INPUT 3,
                                               INPUT 3,
                                        INPUT-OUTPUT tt-dados-analise.nrinfcad,
                                        INPUT-OUTPUT tt-dados-analise.dsinfcad).
                                 
                                      DISPLAY tt-dados-analise.nrinfcad 
                                              tt-dados-analise.dsinfcad
                                              WITH FRAME f_dados_rating.
                                 
                                 END.
                            ELSE
                                 APPLY LASTKEY.
                        END.
                     
                        /* Validar campos do RATING */
                        RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.
                        
                        IF   NOT VALID-HANDLE(h-b1wgen0043)   THEN
                             DO:
                                 MESSAGE "Handle invalido para a BO b1wgen0043.".
                                 PAUSE 2 NO-MESSAGE.
                                 NEXT.
                             END.
                        
                        RUN valida-itens-rating IN h-b1wgen0043 
                                                   (INPUT glb_cdcooper,
                                                    INPUT 0,
                                                    INPUT 0,
                                                    INPUT glb_cdoperad,
                                                    INPUT glb_dtmvtolt,
                                                    INPUT par_nrdconta,
                                                    INPUT tt-dados-analise.nrgarope,
                                                    INPUT tt-dados-analise.nrinfcad,
                                                    INPUT tt-dados-analise.nrliquid,
                                                    INPUT tt-dados-analise.nrpatlvr,
                                                    INPUT tt-dados-analise.nrperger,
                                                    INPUT 1, /* Titular */
                                                    INPUT 1, /* Ayllos*/
                                                    INPUT glb_nmdatela,
                                                    INPUT FALSE,
                                                   OUTPUT TABLE tt-erro).
                     
                        DELETE PROCEDURE h-b1wgen0043.
                       
                        IF   RETURN-VALUE <> "OK"   THEN
                             DO:
                                 FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            
                                 IF   AVAILABLE tt-erro   THEN
                                      MESSAGE tt-erro.dscritic.
                                 ELSE
                                      MESSAGE "Erro na validacao dos campos do Rating.".
                                 
                                 PAUSE 2 NO-MESSAGE.
                                 NEXT.   
                             END.  

                        LEAVE.
                     
                     END.

                 END.
        END.
  
END PROCEDURE.

PROCEDURE sequencia_rating:
                                                                      
    DEF INPUT        PARAM par_nrtopico AS INTE                       NO-UNDO.
    DEF INPUT        PARAM par_nritetop AS INTE                       NO-UNDO.
                                                                      
    DEF INPUT-OUTPUT PARAM par_nrseqite AS INTE                       NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_dssequte AS CHAR                       NO-UNDO.
                                                                      
    DEF QUERY  q-craprad FOR tt-itens-topico-rating SCROLLING.

    DEF BROWSE b-craprad QUERY q-craprad  
        DISPLAY nrseqite COLUMN-LABEL "Seq.Item"
                dsseqite COLUMN-LABEL "Descricao Seq.Item" FORMAT "x(55)"
                WITH CENTERED 5 DOWN TITLE " Itens do rating ".

    FORM b-craprad 
        HELP "Pressione <ENTER> p/ selecionar as informacoes cadastrais."
     WITH CENTERED NO-BOX OVERLAY ROW 10 COLUMN 3 WIDTH 70 FRAME f_craprad.


    /* Posicionar no Item entrado */
    ON ENTRY OF b-craprad IN FRAME f_craprad DO: 
                    
       FIND tt-itens-topico-rating WHERE 
            tt-itens-topico-rating.nrtopico = par_nrtopico   AND
            tt-itens-topico-rating.nritetop = par_nritetop   AND
            tt-itens-topico-rating.nrseqite = par_nrseqite
            NO-LOCK NO-ERROR.

       IF   AVAIL  tt-itens-topico-rating THEN
            REPOSITION q-craprad TO ROWID ROWID(tt-itens-topico-rating).

    END.

    ON RETURN OF b-craprad IN FRAME f_craprad DO:

        IF   NOT AVAIL tt-itens-topico-rating THEN
             APPLY "GO".

        ASSIGN par_nrseqite = tt-itens-topico-rating.nrseqite
               par_dssequte = tt-itens-topico-rating.dsseqite.

        APPLY "GO".

    END.

    OPEN QUERY q-craprad 
        FOR EACH tt-itens-topico-rating WHERE 
                 tt-itens-topico-rating.nrtopico = par_nrtopico   AND
                 tt-itens-topico-rating.nritetop = par_nritetop   NO-LOCK.
                            
    IF   NUM-RESULTS("q-craprad")  = 0  THEN
         RETURN.
          
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
       UPDATE b-craprad 
              WITH FRAME f_craprad.
       LEAVE.
         
    END.
   
    HIDE FRAME f_craprad.    

END PROCEDURE.




/* ......................................................................... */

