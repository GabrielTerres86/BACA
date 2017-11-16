/*.............................................................................
 
  Programa: fontes/contas_dda.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED 
  Autor   : Gabriel
  Data    : Marco/2011                         Ultima Atualizacao: 01/12/2014
  
  Dados referentes ao programa:
  
  Frequencia: Diario(On-line)
  Objetivo  : Mostrar a rotina de DDA da tela CONTAS.
  
  Alteracoes: 21/07/2011 - Passar as testemunhas para um fontes separado
                           p/ poder re aproveitar o codigo (Gabriel).
                           
              29/05/2014 - Concatena o numero do servidor no endereco do
                           terminal (Tiago-RKAM).
                                                                             
              01/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                           Cedente por Beneficiário e  Sacado por Pagador 
                           Chamado 229313 (Jean Reddiga - RKAM).    

				25/10/2017 -  Ajustado para especificar adesão de DDA pelo Mobile
							  PRJ356.4 - DDA (Ricardo Linhares)
                           
.............................................................................*/

{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgen0078tt.i }
{ sistema/generico/includes/b1wgen0079tt.i }
{ sistema/generico/includes/var_internet.i }

DEF STREAM str_1. /* Para impressao de titulos */

DEF BUTTON btn_aderir   LABEL "Aderir".
DEF BUTTON btn_encerrar LABEL "Encerrar".
DEF BUTTON btn_imprimir LABEL "Imprimir".

/* Variaveis para a impressao */
DEF VAR par_flgrodar AS LOGI                                           NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                           NO-UNDO.
DEF VAR par_flgcance AS LOGI                                           NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                        NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"          NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"          NO-UNDO.

DEF VAR aux_flgfirst AS LOGI                                           NO-UNDO.
DEF VAR aux_flgchama AS LOGI                                           NO-UNDO.

DEF VAR par_nmdtest1 AS CHAR                                           NO-UNDO.
DEF VAR par_cpftest1 AS DECI                                           NO-UNDO.
DEF VAR par_nmdtest2 AS CHAR                                           NO-UNDO.
DEF VAR par_cpftest2 AS DECI                                           NO-UNDO.

DEF VAR tel_impadesa AS CHAR INIT "Termo de Adesao"                    NO-UNDO.
DEF VAR tel_impexclu AS CHAR INIT "Termo de Exclusao"                  NO-UNDO.
DEF VAR tel_imptitul AS CHAR INIT "Titulos Bloqueados"                 NO-UNDO.

DEF VAR par_qttitulo AS INTE                                           NO-UNDO.
DEF VAR par_flgverif AS LOGI                                           NO-UNDO.
DEF VAR par_nmarqimp AS CHAR                                           NO-UNDO.                                          
DEF VAR par_nmarqpdf AS CHAR                                           NO-UNDO.
       
DEF VAR h-b1wgen0078 AS HANDLE                                         NO-UNDO.


FORM SKIP(1)
     tt-sacado-eletronico.dscpfcgc LABEL "C.P.F./C.N.P.J."   AT 03
     tt-sacado-eletronico.dspessoa LABEL "Tipo de Pessoa"    AT 45
     SKIP                                                    
     tt-sacado-eletronico.nmextttl LABEL "Nome"              AT 03
     SKIP(2)
     tt-sacado-eletronico.flgativo LABEL "Pagador Eletronico" AT 02       
     tt-sacado-eletronico.qtadesao LABEL "Qtde de Adesoes"   AT 05
     SKIP(1)
     tt-sacado-eletronico.dssituac LABEL "Situacao"          AT 12 
     tt-sacado-eletronico.dtsituac LABEL "Data da Situacao"  AT 04 
     SKIP(1)
     tt-sacado-eletronico.dtadesao LABEL "Data da Adesao"    AT 06
     tt-sacado-eletronico.dtexclus LABEL "Data da Exclusao"  AT 04
     SKIP(1)    
     btn_aderir    AT 20 
        HELP "<ENTER> p/ solicitar a inclusão como Pagador eletrônico no DDA."
     btn_encerrar  AT 32
        HELP "<ENTER> p/ solicitar a exclusão do Pagador eletrônico no DDA."
     btn_imprimir  AT 46
        HELP "Pressione <ENTER> para selecionar o termo a imprimir."
     
     WITH CENTERED OVERLAY SIDE-LABELS WIDTH 78 
                    TITLE " DDA (Debito Direto Autorizado) " FRAME f_dda.

FORM SKIP(1) " "
     tel_impadesa FORMAT "x(15)" " " 
     tel_impexclu FORMAT "x(17)" " "
     tel_imptitul FORMAT "x(18)"   " "
     SKIP(1)
     WITH ROW 11 NO-LABELS CENTERED OVERLAY FRAME f_impressao.


ON CHOOSE OF btn_aderir DO:    
    ASSIGN glb_cddopcao = "I".
    APPLY "GO".
END.

ON CHOOSE OF btn_encerrar DO:
    ASSIGN glb_cddopcao = "X".
    APPLY "GO".
END.

ON CHOOSE OF btn_imprimir DO:
    ASSIGN glb_cddopcao = "M".
    APPLY "GO".
END.


ASSIGN aux_flgfirst = TRUE
       aux_flgchama = TRUE.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    IF   aux_flgchama   THEN  /* Se tem que chamar a Procedure */  
         DO:
             ASSIGN aux_flgchama = FALSE.
             
             RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.
         
             RUN consulta-sacado-eletronico IN h-b1wgen0078 
                                             (INPUT glb_cdcooper,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT glb_cdoperad,
                                              INPUT glb_nmdatela,
                                              INPUT 1, /* Ayllos*/
                                              INPUT tel_nrdconta,
                                              INPUT tel_idseqttl,
                                              INPUT glb_dtmvtolt,
                                              INPUT aux_flgfirst,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-sacado-eletronico).
             DELETE PROCEDURE h-b1wgen0078. 

             IF   RETURN-VALUE <> "OK"   THEN
                  DO:
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.
                  
                      IF   AVAIL tt-erro   THEN
                           MESSAGE tt-erro.dscritic.
                      ELSE
                           MESSAGE "Erro na consulta do Pagador eletronico.".
                  
                      RETURN.
                  END.

             ASSIGN aux_flgfirst = FALSE.
         END.
    
    FIND FIRST tt-sacado-eletronico NO-LOCK NO-ERROR.
    
    IF   NOT AVAIL tt-sacado-eletronico   THEN
         RETURN.

    DISPLAY tt-sacado-eletronico.dscpfcgc
            tt-sacado-eletronico.dspessoa
            tt-sacado-eletronico.nmextttl
            tt-sacado-eletronico.flgativo
            tt-sacado-eletronico.dssituac
            tt-sacado-eletronico.dtsituac
            tt-sacado-eletronico.dtadesao
            tt-sacado-eletronico.qtadesao
            tt-sacado-eletronico.dtexclus WITH FRAME f_dda.  

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN glb_nmrotina = "DDA".
                               
        UPDATE btn_aderir   WHEN tt-sacado-eletronico.btnaderi
               btn_encerrar WHEN tt-sacado-eletronico.btnexclu 
               btn_imprimir 
               WITH FRAME f_dda.

        { includes/acesso.i }

        LEAVE.
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
         LEAVE.

    IF   glb_cddopcao = "I"   THEN   /* Aderir */
         DO:
             NEXT-PROMPT btn_aderir WITH FRAME f_dda.

             RUN fontes/confirma.p 
                (INPUT "Confirma a adesão do cooperado ao DDA?",
                 OUTPUT aux_confirma).

             IF   aux_confirma <> "S"   THEN
                  NEXT.

             ASSIGN aux_flgchama = TRUE.

             RUN sistema/generico/procedures/b1wgen0078.p 
                                 PERSISTENT SET h-b1wgen0078.

             RUN aderir-sacado IN h-b1wgen0078 
                                    (INPUT glb_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_nmdatela,
                                     INPUT 1, /* Ayllos */
                                     INPUT tel_nrdconta,
                                     INPUT tel_idseqttl,
                                     INPUT glb_dtmvtolt,
                                     INPUT TRUE,
									 INPUT 0,
                                    OUTPUT TABLE tt-erro).

             DELETE PROCEDURE h-b1wgen0078.

             IF   RETURN-VALUE <> "OK"   THEN
                  DO:
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.

                      IF   AVAIL tt-erro   THEN
                           MESSAGE tt-erro.dscritic.
                      ELSE
                           MESSAGE "Erro na inclusao do Pagador eletronico.".

                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          PAUSE 4 NO-MESSAGE.
                          LEAVE.
                      END.
                      
                      HIDE MESSAGE NO-PAUSE.
                      NEXT.
                  END.

             RUN fontes/confirma.p (INPUT "Deseja imprimir o termo de adesao?",
                                   OUTPUT aux_confirma).

             IF   aux_confirma <> "S"   THEN
                  DO:
                      HIDE MESSAGE NO-PAUSE.
                      NEXT.
                  END.

             RUN testemunhas.

             IF   RETURN-VALUE <> "OK"   THEN
                  NEXT.

             RUN termo-impressao.

         END. /* Fim opcao Inclusao */
    ELSE
    IF   glb_cddopcao = "X"   THEN   /* Encerrar */
         DO:
             NEXT-PROMPT btn_encerrar WITH FRAME f_dda.

             RUN fontes/confirma.p
                  (INPUT "Confirma a exclusão do cooperado ao DDA?",
                  OUTPUT aux_confirma).

             IF   aux_confirma <> "S"   THEN
                  NEXT.

             ASSIGN aux_flgchama = TRUE.

             RUN sistema/generico/procedures/b1wgen0078.p
                 PERSISTENT SET h-b1wgen0078.

             RUN encerrar-sacado-dda IN h-b1wgen0078 
                                        (INPUT glb_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT glb_nmdatela,
                                         INPUT 1, /* Ayllos*/
                                         INPUT tel_nrdconta,
                                         INPUT tel_idseqttl,
                                         INPUT glb_dtmvtolt,
                                         INPUT TRUE,
                                        OUTPUT TABLE tt-erro).

             DELETE PROCEDURE h-b1wgen0078.

             IF   RETURN-VALUE <> "OK"   THEN
                  DO:
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.

                      IF   AVAIL tt-erro   THEN
                           MESSAGE tt-erro.dscritic.
                      ELSE
                           MESSAGE "Erro na exclusao do Pagador.".

                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          PAUSE 4 NO-MESSAGE.
                          LEAVE.
                      END.

                      HIDE MESSAGE NO-PAUSE.
                      NEXT.
                  END.    

             RUN fontes/confirma.p 
                 (INPUT "Deseja imprimir o termo de exclusao?",
                  OUTPUT aux_confirma).

             IF   aux_confirma <> "S"  THEN
                  NEXT.

             RUN testemunhas.

             IF   RETURN-VALUE <> "OK"   THEN
                  NEXT.
             
             RUN termo-exclusao.

         END. /* Fim opcao de Exclusao */
    ELSE
    IF   glb_cddopcao = "M"   THEN  /* Imprimir */
         DO:
             NEXT-PROMPT btn_imprimir WITH FRAME f_dda.

             DISPLAY tel_impadesa                        
                     tel_impexclu                        
                     tel_imptitul WITH FRAME f_impressao.

             DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

                 CHOOSE FIELD tel_impadesa
                              tel_impexclu
                              tel_imptitul WITH FRAME f_impressao.

                 IF   FRAME-FIELD = "tel_impadesa"   THEN
                      DO:
                          RUN testemunhas.

                          IF   RETURN-VALUE <> "OK"   THEN
                               NEXT.

                          RUN termo-impressao.         
                      END.
                 ELSE
                 IF   FRAME-FIELD = "tel_impexclu"   THEN
                      DO:
                          RUN testemunhas.

                          IF   RETURN-VALUE <> "OK"   THEN
                               NEXT.

                          RUN termo-exclusao.
                      END.
                 ELSE
                 IF   FRAME-FIELD = "tel_imptitul"   THEN
                      DO:
                          RUN titulos.
                      END.
                 LEAVE.
             END.  
         END.      /* Fim Opcao Imprimir */
   
END. /* Fim Laco principal */

HIDE FRAME f_dda.


PROCEDURE testemunhas:
    
    RUN fontes/testemunhas.p (INPUT tel_nrdconta,
                             OUTPUT par_nmdtest1,
                             OUTPUT par_cpftest1,
                             OUTPUT par_nmdtest2,
                             OUTPUT par_cpftest2).

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
         RETURN "NOK".

    RETURN "OK".   
    
END PROCEDURE.

PROCEDURE termo-impressao:

    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.

    RUN imprime-termo-adesao IN h-b1wgen0078 (INPUT glb_cdcooper,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT glb_cdoperad,
                                              INPUT glb_nmdatela,
                                              INPUT 1, /** Ayllos **/
                                              INPUT tel_nrdconta,
                                              INPUT par_nmdtest1,
                                              INPUT par_cpftest1,
                                              INPUT par_nmdtest2,
                                              INPUT par_cpftest2,
                                              INPUT aux_nmendter,
                                              INPUT tel_idseqttl,
                                              INPUT glb_dtmvtolt,
                                              INPUT TRUE,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT par_nmarqimp,
                                             OUTPUT par_nmarqpdf).  
    DELETE PROCEDURE h-b1wgen0078.

    IF   RETURN-VALUE <> "OK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   AVAIL tt-erro   THEN
                  MESSAGE tt-erro.dscritic.
             ELSE
                  MESSAGE "Erro na impressao do termo de adesao.".

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                PAUSE 3 NO-MESSAGE.
                LEAVE.
             END.

             HIDE MESSAGE NO-PAUSE.
             RETURN "NOK".
         END.

    /* 2 vias */
    RUN imprimir (INPUT 2).

    RETURN "OK".

END PROCEDURE.


PROCEDURE termo-exclusao:

    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.

    RUN imprime-termo-exclusao IN h-b1wgen0078 (INPUT glb_cdcooper,
                                                INPUT 0,
                                                INPUT 0,
                                                INPUT glb_cdoperad,
                                                INPUT glb_nmdatela,
                                                INPUT 1, /** Ayllos **/
                                                INPUT tel_nrdconta,
                                                INPUT par_nmdtest1,
                                                INPUT par_cpftest1,
                                                INPUT par_nmdtest2,
                                                INPUT par_cpftest2,
                                                INPUT aux_nmendter,
                                                INPUT tel_idseqttl,
                                                INPUT glb_dtmvtolt,
                                                INPUT TRUE,
                                               OUTPUT TABLE tt-erro,
                                               OUTPUT par_nmarqimp,
                                               OUTPUT par_nmarqpdf).  
    DELETE PROCEDURE h-b1wgen0078.        

    IF   RETURN-VALUE <> "OK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   AVAIL tt-erro   THEN
                  MESSAGE tt-erro.dscritic.
             ELSE
                  MESSAGE "Erro na impressao do termo de exclusao.".

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                PAUSE 3 NO-MESSAGE.
                LEAVE.
             END.

             HIDE MESSAGE NO-PAUSE.
             RETURN "NOK".
         END.

    /* 2 vias */
    RUN imprimir (INPUT 2).

    RETURN "OK".

END PROCEDURE.


PROCEDURE titulos:

    MESSAGE "Aguarde... Verificando situacao do titular...".

    RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.

    RUN verifica-sacado IN h-b1wgen0078 (INPUT glb_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT glb_nmdatela,
                                         INPUT 1, /* Ayllos */
                                         INPUT tel_nrdconta,
                                         INPUT tel_idseqttl,
                                         INPUT TRUE,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT par_flgverif).   
    DELETE PROCEDURE h-b1wgen0078.

    HIDE MESSAGE NO-PAUSE.

    IF   RETURN-VALUE <> "OK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   AVAIL tt-erro   THEN
                  MESSAGE tt-erro.dscritic.
             ELSE
                  MESSAGE "Erro na verificacao do Pagador.".

             RETURN "NOK".
         END.
                        
    IF   par_flgverif   THEN /* O titular ainda é Pagador eletronico */
         DO:            
             MESSAGE "O titular ainda é Pagador eletronico.".
             RETURN "NOK".
         END.  

    MESSAGE "Aguarde... Gerando os titulos...".

    RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.

    RUN lista-grupo-titulos-sacado IN h-b1wgen0078 
                                (INPUT glb_cdcooper,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT glb_cdoperad,
                                 INPUT glb_nmdatela,
                                 INPUT 1, /* Ayllos */
                                 INPUT tel_nrdconta,
                                 INPUT tel_idseqttl,
                                 INPUT ?, 
                                 INPUT ?, 
                                 INPUT 13, /* Situacao */
                                 INPUT 1,  /* Ordem data de vencto. */
                                 INPUT TRUE,
                                OUTPUT par_qttitulo,
                                OUTPUT TABLE tt-grupo-titulos-sacado-dda,
                                OUTPUT TABLE tt-grupo-instr-tit-sacado-dda,
                                OUTPUT TABLE tt-grupo-descto-tit-sacado-dda,
                                OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0078.

    HIDE MESSAGE NO-PAUSE.

    IF   RETURN-VALUE <> "OK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   AVAIL tt-erro   THEN
                  MESSAGE tt-erro.dscritic.
             ELSE
                  MESSAGE "Erro na impressao dos titulos.".

             RETURN "NOK".
         END.
                        
    IF   par_qttitulo = 0   THEN
         DO:
             MESSAGE "Nao foram encontrados titulos bloqueados.".
             RETURN "NOK". 
         END.              

    RUN impressao-titulos.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE impressao-titulos:
    
    DEF VAR aux_nrcodbar AS DECI                                        NO-UNDO.
    DEF VAR aux_dstitulo AS CHAR                                        NO-UNDO.
    DEF VAR aux_vltitulo AS CHAR                                        NO-UNDO.
    DEF VAR aux_qtdiapro AS CHAR                                        NO-UNDO.
    DEF VAR aux_vlrdmora AS CHAR                                        NO-UNDO.
    DEF VAR aux_vlrabati AS CHAR                                        NO-UNDO.


    FORM "RECIBO DO PAGADOR" AT 108
         "\033\017"  /* Letra Menor */
         WITH NO-BOX NO-LABELS WIDTH 135 FRAME f_recibo.

    FORM SKIP(1)
         "\033\016"  /* Letra Maior */ 
         tt-grupo-titulos-sacado-dda.dslindig FORMAT "x(55)" AT 28
         "\024"      /* Fim letra maior */
         "\033\017"  /* Letra Menor */        
         WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_codbarras.

    FORM " ---------------------------------------------------------------------------------------------------------"        
         SKIP
         "\033\105\| Banco Beneficiario" SPACE(52) "| Situacao\033\106" /* Negrito*/
         SKIP
         "|" 
         tt-grupo-titulos-sacado-dda.cdbccced FORMAT "x(3)"  "-" 
         tt-grupo-titulos-sacado-dda.nmbccced FORMAT "x(44)" SPACE(15) "|"
         tt-grupo-titulos-sacado-dda.dssittit FORMAT "x(20)"
         SKIP
        "\033\105\ ---------------------------------------------------------------------------------------------------------\033\106"
         SKIP
         "\033\105\| Beneficiario" SPACE(58) "| CPF/CNPJ do Beneficiario\033\106"
         SKIP
         "|"
         tt-grupo-titulos-sacado-dda.nmcedent FORMAT "x(50)" SPACE(15) "|"
         tt-grupo-titulos-sacado-dda.dsdocced FORMAT "x(30)"
         SKIP 
        "\033\105\ ---------------------------------------------------------------------------------------------------------\033\106"
         SKIP
         "\033\105\| Data de Emissao" SPACE(15) "| Numero do Documento" SPACE(6) 
         "| Especie\033\106"
         SKIP
         "|"
         tt-grupo-titulos-sacado-dda.dtemissa FORMAT "99/99/9999" SPACE(20) "|"
         tt-grupo-titulos-sacado-dda.nrdocmto FORMAT "x(15)"      SPACE(10) "|"
         tt-grupo-titulos-sacado-dda.dsdmoeda FORMAT "x(25)"  
         SKIP
        "\033\105\ ---------------------------------------------------------------------------------------------------------\033\106"
         SKIP
         "\033\105\| Vencimento" SPACE(20) "| Valor do Documento" SPACE(7) 
         "| Dias de Protesto." SPACE(3) "| Nosso Numero\033\106"
         SKIP
         "|"
         tt-grupo-titulos-sacado-dda.dtvencto FORMAT "99/99/9999" SPACE(20) "|"
         aux_vltitulo                         FORMAT "x(12)"      SPACE(13) "|"
         aux_qtdiapro                         FORMAT "x(5)"       SPACE(15) "|"
         tt-grupo-titulos-sacado-dda.nossonum FORMAT "x(23)" 
"\033\105\ ---------------------------------------------------------------------------------------------------------\033\106"
         SKIP
         "\033\105\| Mora Diaria" SPACE(51) "| Multa\033\106"
         SKIP
         "|"
         aux_vlrdmora FORMAT "x(12)" SPACE(50) "|"
         tt-grupo-titulos-sacado-dda.dsdmulta FORMAT "x(30)"
         SKIP
"\033\105\ ---------------------------------------------------------------------------------------------------------\033\106"
         SKIP
         "\033\105\| Valor do Abatimento" SPACE(21) "| Carteira" SPACE(26) 
         "| Titulo Negociado\033\106"
         SKIP
         "|"
         aux_vlrabati FORMAT "x(12)" SPACE(28) "|"
         tt-grupo-titulos-sacado-dda.dscartei FORMAT "x(30)"         SPACE(4)  "|"
         tt-grupo-titulos-sacado-dda.idtitneg FORMAT "x(3)"
         SKIP
"\033\105\ ---------------------------------------------------------------------------------------------------------\033\106"
         SKIP
         "\033\105\| Instrucoes (Texto de responsabilidade do Beneficiario)\033\106"
         WITH NO-BOX COLUMN 18 NO-LABELS WIDTH 132 FRAME f_titulo_1.

    FORM  "|" tt-grupo-instr-tit-sacado-dda.dsdinstr FORMAT "x(125)"
         WITH NO-BOX DOWN COLUMN 18 NO-LABELS WIDTH 132 FRAME f_titulo_2.

    FORM 
"\033\105\ ---------------------------------------------------------------------------------------------------------\033\106"
         SKIP
         "\033\105\| Valor do Desconto\033\106"
         WITH NO-BOX COLUMN 18 WIDTH 132 FRAME f_titulo_3.   

    FORM "|" tt-grupo-descto-tit-sacado-dda.dsdescto FORMAT "x(125)"
         WITH NO-BOX DOWN COLUMN 18 NO-LABELS WIDTH 132 FRAME f_titulo_4.

    FORM 
"\033\105\ ---------------------------------------------------------------------------------------------------------\033\106"
         SKIP
         "\033\105\| Sacado" SPACE(59) "| CPF/CNPJ do Pagador\033\106"
         SKIP
         "|"
         tt-grupo-titulos-sacado-dda.nmdsacad FORMAT "x(50)" SPACE(15) "|" 
         tt-grupo-titulos-sacado-dda.dsdocsac FORMAT "x(30)"
         SKIP
"\033\105\ ---------------------------------------------------------------------------------------------------------\033\106"
         SKIP
         "\033\105\| Pagador Avalista" SPACE(49) "| Documento Pagador\033\106"
         SKIP
         "|"
         tt-grupo-titulos-sacado-dda.nmsacava FORMAT "x(50)" SPACE(15) "|"
         tt-grupo-titulos-sacado-dda.nrdocsav FORMAT "zzzzzzzzzz9"
         SKIP
"\033\105\ ---------------------------------------------------------------------------------------------------------\033\106"
         "\022\033\115"  /* Fim letra menor */
         WITH NO-BOX NO-LABELS COLUMN 18 WIDTH 132 FRAME f_titulo_5.   
         
    FORM "\033\017"  /* Letra Menor */
         "---------------------------------------------------------------------------------------------------------"
         SKIP
         "     Corte na linha pontilhada"
         "\022\033\115"  /* Fim letra menor */
         SKIP(1)
         WITH COLUMN 15 WIDTH 132 FRAME f_corte.


    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.
    
    ASSIGN par_nmarqimp = "rl/" + aux_nmendter. 

    UNIX SILENT VALUE ("rm " + par_nmarqimp + "* 2>/dev/null").
        
    ASSIGN par_nmarqimp = par_nmarqimp + STRING(TIME) + ".ex".
    
    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 82.
    
    FOR EACH tt-grupo-titulos-sacado-dda NO-LOCK:

        ASSIGN aux_vltitulo = 
            TRIM(STRING(tt-grupo-titulos-sacado-dda.vltitulo,"z,zzz,zz9.99"))
            
               aux_qtdiapro = 
            TRIM(STRING(tt-grupo-titulos-sacado-dda.qtdiapro,"z,zz9"))
            
               aux_vlrdmora = 
            TRIM(STRING(tt-grupo-titulos-sacado-dda.vlrdmora,"z,zzz,zz9.99"))

               aux_vlrabati = 
            TRIM(STRING(tt-grupo-titulos-sacado-dda.vlrabati,"z,zzz,zz9.99")).

        VIEW STREAM str_1 FRAME f_recibo.

        DO aux_contador = 1 TO 2:

           IF   aux_contador = 2  THEN
                DISPLAY STREAM str_1 tt-grupo-titulos-sacado-dda.dslindig
                                     WITH FRAME f_codbarras. 

           DISPLAY STREAM str_1 
               tt-grupo-titulos-sacado-dda.cdbccced
               tt-grupo-titulos-sacado-dda.nmbccced
               tt-grupo-titulos-sacado-dda.dssittit
               tt-grupo-titulos-sacado-dda.nmcedent
               tt-grupo-titulos-sacado-dda.dsdocced
               tt-grupo-titulos-sacado-dda.dtemissa 
               tt-grupo-titulos-sacado-dda.nrdocmto
               tt-grupo-titulos-sacado-dda.dsdmoeda
               tt-grupo-titulos-sacado-dda.dtvencto
               aux_vltitulo 
               aux_qtdiapro
               aux_vlrdmora
               tt-grupo-titulos-sacado-dda.nossonum
               tt-grupo-titulos-sacado-dda.dsdmulta
               aux_vlrabati
               tt-grupo-titulos-sacado-dda.dscartei
               tt-grupo-titulos-sacado-dda.idtitneg
               WITH FRAME f_titulo_1.

           /* Instrucoes */
           FOR EACH tt-grupo-instr-tit-sacado-dda WHERE 
                    tt-grupo-instr-tit-sacado-dda.nrorditm = 
                        tt-grupo-titulos-sacado-dda.nrorditm NO-LOCK:
               
               DISPLAY STREAM str_1 tt-grupo-instr-tit-sacado-dda.dsdinstr
                                    WITH FRAME f_titulo_2.
                   
               DOWN WITH FRAME f_titulo_2.
                      
           END.

           VIEW STREAM str_1 FRAME f_titulo_3.

           /* Descontos */
           FOR EACH tt-grupo-descto-tit-sacado-dda WHERE
                    tt-grupo-descto-tit-sacado-dda.nrorditm = 
                        tt-grupo-titulos-sacado-dda.nrorditm NO-LOCK:

               DISPLAY STREAM str_1 tt-grupo-descto-tit-sacado-dda.dsdescto
                                    WITH FRAME f_titulo_4.

               DOWN WITH FRAME f_titulo_4.

           END.

           DISPLAY STREAM str_1 tt-grupo-titulos-sacado-dda.nmdsacad  
                                tt-grupo-titulos-sacado-dda.dsdocsac 
                                tt-grupo-titulos-sacado-dda.nmsacava 
                                tt-grupo-titulos-sacado-dda.nrdocsav 
                                WITH FRAME f_titulo_5.

           VIEW STREAM str_1 FRAME f_corte.
           
        END.

        PAGE STREAM str_1.

    END. /* For each Titulos */
    
    OUTPUT STREAM str_1 CLOSE.
       
    /* 1 via */
    RUN imprimir (INPUT 1).
   
END PROCEDUR.


PROCEDURE imprimir:

    DEF INPUT PARAM par_nrdevias AS INTE                               NO-UNDO.

    ASSIGN glb_nrdevias = par_nrdevias
           aux_nmarqimp = par_nmarqimp
           par_flgrodar = TRUE.

    FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

    { includes/impressao.i }

END PROCEDURE.

/* .......................................................................... */


