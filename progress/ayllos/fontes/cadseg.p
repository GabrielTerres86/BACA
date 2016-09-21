/*............................................................................

  Programa: Fontes/cadseg.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Gabriel
  Data    : Abril/2009                         Ultima Atualizacao: 22/01/2014
   
  Dados referentes ao programa:
  
  Frequencia: Diario (on-line).
  Objetivo  : Mostrar a tela CADSEG, cadastro de seguradoras.

  Alteracoes:  14/07/2009 - Alteracao CDOPERAD (Diego).
  
               04/10/2012 - Correção mensagem "Operacao efetuaca com sucesso"
                            a qual estava sendo exibida de forma incorreta
                            (Daniel).
                            
               21/11/2013 - Relizada conversão do fonte, juntamente com criação
                            dos programa b1wgen0181 e xb1wgen0181, para que
                            seja possível acessar as regras de negócio pela WEB.
                            (Oliver-GATI).
                            
               17/01/2014 - Alterado LABEL e HELP da tel_nrcgcseg de CGC para 
                            CNPJ. (Reinert)
                            
               22/01/2014 - Ajuste para validacao e fluxo de dados. (Jorge)
..............................................................................*/

{  includes/var_online.i  }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0181tt.i }

DEF STREAM str_1. 

DEF VAR h-b1wgen0181 AS HANDLE                                        NO-UNDO.

DEF VAR tel_cdsegura LIKE crapcsg.cdsegura                            NO-UNDO.
DEF VAR tel_nmsegura LIKE crapcsg.nmsegura                            NO-UNDO.
DEF VAR tel_nmresseg LIKE crapcsg.nmresseg                            NO-UNDO.
DEF VAR tel_nrcgcseg LIKE crapcsg.nrcgcseg                            NO-UNDO.
DEF VAR tel_dsmsgseg LIKE crapcsg.dsmsgseg                            NO-UNDO.
DEF VAR tel_nrctrato LIKE crapcsg.nrctrato                            NO-UNDO.
DEF VAR tel_nrultpra LIKE crapcsg.nrultpra                            NO-UNDO.
DEF VAR tel_nrlimpra LIKE crapcsg.nrlimpra                            NO-UNDO.
DEF VAR tel_nrultprc LIKE crapcsg.nrultprc                            NO-UNDO.
DEF VAR tel_nrlimprc LIKE crapcsg.nrlimprc                            NO-UNDO.
DEF VAR tel_dsasauto LIKE crapcsg.dsasauto                            NO-UNDO.
DEF VAR tel_cdhstaut LIKE crapcsg.cdhstaut                            NO-UNDO.
DEF VAR tel_cdhstcas LIKE crapcsg.cdhstcas                            NO-UNDO.
DEF VAR tel_flgativo LIKE crapcsg.flgativo                            NO-UNDO.

DEF VAR aux_cddopcao AS   CHAR                                        NO-UNDO.
DEF VAR aux_contador AS   INTE                                        NO-UNDO.
DEF VAR aux_confirma AS   CHAR FORMAT "x(1)"                          NO-UNDO.
DEF VAR aux_nmdcampo AS   CHAR                                        NO-UNDO.
DEF VAR aux_qtregist AS   INTE                                        NO-UNDO.
DEF VAR aux_cdsegura AS   INTE                                        NO-UNDO.


FORM WITH ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela 
     FRAME f_moldura.


FORM glb_cddopcao LABEL "Opcao" AUTO-RETURN
     HELP "Informe a opcao desejada (A,C,E,I)."
     VALIDATE (CAN-DO("A,C,E,I",glb_cddopcao), "014 - Opcao errada.")
     WITH ROW 6 COLUMN 3 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM SKIP
     tel_cdsegura     AT 03 LABEL "Codigo"
     VALIDATE (tel_cdsegura > 0, "Codigo Invalido.")
     HELP "Informe o codigo da seguradora ou pressione <F7> para listar."
          AUTO-RETURN
     tel_nmsegura     AT 25 LABEL "Nome"
     HELP "Informe o nome da seguradora."
     SKIP(1) 
     tel_nmresseg     AT 03 LABEL "Nome resumido"
     HELP "Informe o nome resumido da seguradora."
     tel_flgativo     AT 48
     HELP "Informe se a seguradora esta ativa."
     SKIP(1)
     tel_nrcgcseg     AT 03 LABEL "Numero do CNPJ"
     HELP "Informe o numero do CNPJ da seguradora."
     tel_nrctrato     AT 46
     HELP "Informe o numero de contrato com a seguradora."
     SKIP(1)
     tel_nrultpra     AT 03
     HELP "Informe o numero da ultima proposta para seguro auto utilizado."
     tel_nrlimpra     AT 44 
     HELP "Informe o numero limite para proposta de seguro auto."
     SKIP(1)
     tel_nrultprc     AT 03
     HELP "Informe o ultimo numero de proposta de seguro casa utilizado."
     tel_nrlimprc     AT 44   
     HELP "Informe o numero limite para proposta casa."
     SKIP(1)
     tel_dsasauto     AT 03
     HELP "Informe o nome da assistencia auto."
     SKIP(1)
     WITH ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_cadseg.

FORM SKIP
     tel_cdhstaut[1]  AT 03 LABEL "Historicos Seguro AUTO"
     HELP "Informe o historico do seguro auto."
     tel_cdhstaut[2]  AT 35 
     HELP "Informe o historico do seguro auto."
     tel_cdhstaut[3]  AT 43
     HELP "Informe o historico do seguro auto."
     tel_cdhstaut[4]  AT 51
     HELP "Informe o historico do seguro auto."
     tel_cdhstaut[5]  AT 59
     HELP "Informe o historico do seguro auto."
     SKIP(1)
     tel_cdhstaut[6]  AT 27
     HELP "Informe o historico do seguro auto."
     tel_cdhstaut[7]  AT 35 
     HELP "Informe o historico do seguro auto."
     tel_cdhstaut[8]  AT 43
     HELP "Informe o historico do seguro auto."
     tel_cdhstaut[9]  AT 51
     HELP "Informe o historico do seguro auto."
     tel_cdhstaut[10] AT 59
     HELP "Informe o historico do seguro auto."
     SKIP(1)
     tel_cdhstcas[1]  AT 03 LABEL "Historicos Seguro CASA"
     HELP "Informe o historico do seguro casa."
     tel_cdhstcas[2]  AT 35
     HELP "Informe o historico do seguro casa."
     tel_cdhstcas[3]  AT 43
     HELP "Informe o historico do seguro casa."
     tel_cdhstcas[4]  AT 51
     HELP "Informe o historico do seguro casa."
     tel_cdhstcas[5]  AT 59
     HELP "Informe o historico do seguro casa."
     SKIP(1)
     tel_cdhstcas[6]  AT 27
     HELP "Informe o historico do seguro casa."
     tel_cdhstcas[7]  AT 35
     HELP "Informe o historico do seguro casa."
     tel_cdhstcas[8]  AT 43
     HELP "Informe o historico do seguro casa."
     tel_cdhstcas[9]  AT 51
     HELP "Informe o historico do seguro casa."
     tel_cdhstcas[10] AT 59
     HELP "Informe o historico do seguro casa."
     SKIP(1)
     tel_dsmsgseg     AT 03 LABEL "Mensagem"
     HELP "Informe a mensagem da seguradora."
     SKIP(3)
     WITH NO-LABEL ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_cadseg_2.

VIEW FRAME f_moldura.

PAUSE 0.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic =  0.

DO WHILE TRUE:
   
   RUN fontes/inicia.p.

   IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
        END.
   
   EMPTY TEMP-TABLE tt-crapcsg.
   RELEASE tt-crapcsg.
   
   RUN proc_limpa_tela.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      UPDATE glb_cddopcao WITH FRAME f_opcao.
      LEAVE.
               
   END.

   IF   KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN      /* F4 ou Fim  */
        DO:
            RUN fontes/novatela.p.
                      
            IF   CAPS(glb_nmdatela) <> "CADSEG"   THEN
                 DO:
                     IF  VALID-HANDLE(h-b1wgen0181) THEN
                         DELETE OBJECT h-b1wgen0181.

                     HIDE FRAME f_opcao.
                     RETURN.
                 END.
            NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:                   
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF  glb_cddopcao <> "C"   THEN
       DO:
           FIND FIRST crapope WHERE crapope.cdcooper = glb_cdcooper
                                AND crapope.cdoperad = glb_cdoperad
                                NO-LOCK NO-ERROR.
        
           IF NOT AVAIL crapope THEN
               DO:
                   MESSAGE "Operador nao encontrado".
                   PAUSE 2 NO-MESSAGE.

                   IF  VALID-HANDLE(h-b1wgen0181) THEN
                         DELETE OBJECT h-b1wgen0181.

                   RETURN 'NOK'.
               END.
        
           IF NOT CAN-DO ("TI,PRODUTOS",crapope.dsdepart)  THEN  
               DO:
                   glb_cdcritic = 36.
                   RUN fontes/critic.p.
                   MESSAGE glb_dscritic.
                   PAUSE 2 NO-MESSAGE.
                   glb_cdcritic = 0.
                   
                   IF  VALID-HANDLE(h-b1wgen0181) THEN
                         DELETE OBJECT h-b1wgen0181.

                   RETURN 'NOK'.
               END.
       END.
        
   
   VIEW FRAME f_cadseg.
    
   PAUSE 0.
     

   /* inicio */
   DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
       ASSIGN tel_cdsegura = 0.

       RUN proc_limpa_tela.
       RUN proc_zera_campos.
       EMPTY TEMP-TABLE tt-crapcsg.

       IF glb_cddopcao <> "I" THEN
          UPDATE tel_cdsegura WITH FRAME f_cadseg
        
       EDITING:
        
           READKEY.
        
           HIDE MESSAGE NO-PAUSE.
        
           IF  LASTKEY = KEYCODE("F7") THEN 
               DO:   
                    IF  FRAME-FIELD = "tel_cdsegura"  THEN
                        DO:
                            RUN fontes/zoom_seguradora.p
                                ( INPUT glb_cdcooper,
                                 OUTPUT aux_cdsegura,
                                 OUTPUT TABLE tt-crapcsg ).
                            
                            IF  aux_cdsegura > 0 THEN
                            DO:
                                ASSIGN tel_cdsegura = aux_cdsegura.
                                DISP tel_cdsegura WITH FRAME f_cadseg.
                                LEAVE.
                            END.
                        END.
               END.
            ELSE
               APPLY LASTKEY.
            
       END. /* Fim do UPDATE EDITING */
                
       HIDE FRAME f_crapcsg.
       
       IF   glb_cddopcao = "C"    THEN
            DO:
                
               RUN proc_traz_dados.       /* Traz os dados da seguradora  */
                
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    NEXT.
    
               IF RETURN-VALUE = "NOK" THEN
                   NEXT.
    
               RUN proc_mostra_dados.    /* Mostra na tela os campos */
                
               HIDE MESSAGE NO-PAUSE.
                
               NEXT.
                
           END. /**** Fim da opcao "C" *****/
       ELSE 
       IF   glb_cddopcao = "A"     THEN
            DO:
                RUN proc_traz_dados.
                
                IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                     NEXT.
    
                IF   RETURN-VALUE = "NOK"  THEN    /* Sendo alterada */
                     NEXT.
       
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                    RUN proc_atualiza_dados. /* Atualiza os dados da seguradora */
                 
                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                         LEAVE.
        
                    RUN proc_valida_dados.
                    
                    IF   RETURN-VALUE = "NOK"   THEN
                         NEXT.
        
                    RUN proc_confirma.
                    
                    IF   RETURN-VALUE = "NOK"   THEN
                         LEAVE.
        
                    RUN proc_grava_dados.
        
                    LEAVE.
    
                END.
            END.  /**** Fim da opcao "A"  ****/
       ELSE
       IF   glb_cddopcao = "I"   THEN
            DO:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   
                   IF   glb_cdcritic > 0  THEN
                        DO:
                            RUN fontes/critic.p.
                            MESSAGE glb_dscritic.
                            PAUSE 2 NO-MESSAGE.
                            glb_cdcritic = 0.
                        END.
                   
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      UPDATE tel_cdsegura WITH FRAME f_cadseg.
                      LEAVE.
                   END.
                   
                   IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                      LEAVE.
                   
                   IF  NOT VALID-HANDLE(h-b1wgen0181) THEN
                       RUN sistema/generico/procedures/b1wgen0181.p 
                       PERSISTENT SET h-b1wgen0181.
                   
                   RUN Valida_inclusao_seguradora IN h-b1wgen0181(INPUT glb_cdcooper,
                                                                  INPUT glb_cdagenci,
                                                                  INPUT 0 /*nrdcaixa*/,
                                                                  INPUT glb_cdoperad,
                                                                  INPUT glb_dtmvtolt,
                                                                  INPUT 1 /*idorigem*/,
                                                                  INPUT glb_nmdatela,
                                                                  INPUT glb_cdprogra,
                                                                  INPUT glb_cdbccxlt,
                                                                  INPUT tel_cdsegura,
                                                                  INPUT tel_nmsegura,
                                                                  INPUT tel_nrcgcseg,
                                                                  INPUT tel_dsasauto,
                                   /* apenas codigo seguradora */ INPUT NO, 
                                                                  INPUT glb_cddopcao,
                                                                  OUTPUT aux_nmdcampo,
                                                                  OUTPUT TABLE tt-erro).
                   
                   DELETE OBJECT h-b1wgen0181.
                   
                   IF  RETURN-VALUE <> "OK"   THEN
                       DO:
                   
                           FIND FIRST tt-erro NO-LOCK NO-ERROR.
                           IF AVAIL tt-erro   THEN
                               MESSAGE tt-erro.dscritic.
                           ELSE
                               MESSAGE "Erro na validação da seguradora.".
                               
                           PAUSE.
        
                           NEXT.
                        END.
        


                   RUN proc_atualiza_dados.
                   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        NEXT.
                          
                   RUN proc_valida_dados.
                   IF RETURN-VALUE <> "OK" THEN
                       NEXT.
        
                   RUN proc_confirma.     
                   IF   RETURN-VALUE = "NOK"   THEN
                        NEXT.
        
                   RUN proc_grava_dados.   
                   IF   RETURN-VALUE = "NOK"   THEN
                        NEXT.
        
                   LEAVE.
    
                END.  

            END. /***** Fim da opcao "I" *****/
       ELSE
       IF   glb_cddopcao = "E"   THEN
            DO:
                RUN proc_traz_dados.
                 
                IF   RETURN-VALUE = "NOK"    THEN      /* Sendo alterada */
                     NEXT.
    
                RUN proc_mostra_dados.
                 
                HIDE MESSAGE NO-PAUSE.
                
                IF   RETURN-VALUE = "NOK"   THEN        /* F4 ou FIM */
                     NEXT.
                 
                RUN proc_confirma.
                 
                IF   RETURN-VALUE = "NOK"   THEN    /* Cancelada a operacao */
                     NEXT.
                
                IF NOT VALID-HANDLE(h-b1wgen0181) THEN
                   RUN sistema/generico/procedures/b1wgen0181.p 
                   PERSISTENT SET h-b1wgen0181.
    
                MESSAGE "Aguarde, eliminando dados da seguradora...".
                RUN Elimina_seguradora IN h-b1wgen0181(INPUT glb_cdcooper,
                                                       INPUT glb_cdagenci,
                                                       INPUT 0 /*nrdcaixa*/,
                                                       INPUT glb_cdoperad,
                                                       INPUT glb_dtmvtolt,
                                                       INPUT 1 /*idorigem*/,
                                                       INPUT glb_nmdatela,
                                                       INPUT glb_cdprogra,
                                                       INPUT tel_cdsegura,
                                                       OUTPUT TABLE tt-erro).
                HIDE MESSAGE NO-PAUSE.
                DELETE OBJECT h-b1wgen0181.
    
                IF RETURN-VALUE <> "OK"   THEN
                    DO:
            
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    IF AVAIL tt-erro   THEN
                        MESSAGE tt-erro.dscritic.
                    ELSE
                        MESSAGE "Erro na eliminacao de seguradora.".
                        
                    PAUSE.
                
                    NEXT.
            
                END.
                ELSE
                    DO:
                        MESSAGE "Operacao efetuada com sucesso!".
                        PAUSE 2 NO-MESSAGE.
                        HIDE MESSAGE NO-PAUSE.
                    END.
                     
            END.  /* Fim da Opcao "E"  */
    

       LEAVE.

    END.
   
    IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
       NEXT.

END. /* Fim do DO WHILE TRUE */



PROCEDURE proc_traz_dados:
    
    FIND FIRST tt-crapcsg WHERE tt-crapcsg.cdsegura = tel_cdsegura
         NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL tt-crapcsg THEN
    DO:
        EMPTY TEMP-TABLE tt-crapcsg.

        IF  NOT VALID-HANDLE(h-b1wgen0181) THEN
            RUN sistema/generico/procedures/b1wgen0181.p
                PERSISTENT SET h-b1wgen0181.
        
        RUN busca_crapcsg IN h-b1wgen0181
            ( INPUT glb_cdcooper,
              INPUT tel_cdsegura,
              INPUT "",
              INPUT ?,
              INPUT 999999,
              INPUT 1,
             OUTPUT aux_qtregist,
             OUTPUT TABLE tt-crapcsg ).
        
        IF  VALID-HANDLE(h-b1wgen0181)  THEN
            DELETE PROCEDURE h-b1wgen0181.

    END.
      
    FIND FIRST tt-crapcsg WHERE tt-crapcsg.cdcooper = glb_cdcooper
                            AND tt-crapcsg.cdsegura = tel_cdsegura
                            NO-LOCK NO-ERROR.

    IF  NOT AVAIL tt-crapcsg THEN
    DO:
        MESSAGE "Seguradora nao encontrada.".
        RETURN "NOK".
    END.

    DO aux_contador = 1 TO 10:
    
       ASSIGN tel_cdhstaut[aux_contador] = tt-crapcsg.cdhstaut[aux_contador]
              
              tel_cdhstcas[aux_contador] = tt-crapcsg.cdhstcas[aux_contador]. 

    END.
    
    ASSIGN tel_nmsegura = tt-crapcsg.nmsegura
           tel_nmresseg = tt-crapcsg.nmresseg
           tel_flgativo = tt-crapcsg.flgativo
           tel_nrcgcseg = tt-crapcsg.nrcgcseg
           tel_nrctrato = tt-crapcsg.nrctrato
           tel_nrultpra = tt-crapcsg.nrultpra
           tel_nrlimpra = tt-crapcsg.nrlimpra
           tel_nrultprc = tt-crapcsg.nrultprc
           tel_nrlimprc = tt-crapcsg.nrlimprc
           tel_dsasauto = tt-crapcsg.dsasauto
           tel_dsmsgseg = tt-crapcsg.dsmsgseg.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE proc_mostra_dados:

    DO WHILE TRUE:
    
       DISPLAY tel_nmsegura
               tel_nmresseg  tel_flgativo  tel_nrcgcseg  
               tel_nrctrato  tel_nrultpra  tel_nrlimpra  
               tel_nrultprc  tel_nrlimprc  tel_dsasauto  
               WITH FRAME f_cadseg.
               
       MESSAGE "Tecle <Enter> para continuar ou <End> para encerrar.".

       WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                 
       IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
            RETURN "NOK".
            
       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
          DISPLAY tel_cdhstaut[01]  tel_cdhstaut[02]  tel_cdhstaut[03]
                  tel_cdhstaut[04]  tel_cdhstaut[05]  tel_cdhstaut[06]
                  tel_cdhstaut[07]  tel_cdhstaut[08]  tel_cdhstaut[09]
                  tel_cdhstaut[10]  tel_cdhstcas[01]  tel_cdhstcas[02]
                  tel_cdhstcas[03]  tel_cdhstcas[04]  tel_cdhstcas[05]
                  tel_cdhstcas[06]  tel_cdhstcas[07]  tel_cdhstcas[08]
                  tel_cdhstcas[09]  tel_cdhstcas[10]  tel_dsmsgseg
                  WITH FRAME f_cadseg_2.

          MESSAGE "Tecle <Enter> para continuar ou <End> para voltar.".
              
          WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                        
          LEAVE.
               
       END.  /* Fim do DO WHILE TRUE */
    
       IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
            NEXT.
       
       LEAVE.
       
    END. /* Fim do DO WHILE TRUE */

    RETURN "OK".

END PROCEDURE.


PROCEDURE proc_atualiza_dados:

    DO WHILE TRUE:
    
        UPDATE tel_nmsegura  tel_nmresseg  tel_flgativo  
               tel_nrcgcseg  tel_nrctrato  tel_nrultpra  
               tel_nrlimpra  tel_nrultprc  tel_nrlimprc  
               tel_dsasauto  WITH FRAME f_cadseg.
        
        DO WHILE TRUE:
        
           UPDATE tel_cdhstaut[01]  tel_cdhstaut[02]  tel_cdhstaut[03]
                  tel_cdhstaut[04]  tel_cdhstaut[05]  tel_cdhstaut[06] 
                  tel_cdhstaut[07]  tel_cdhstaut[08]  tel_cdhstaut[09] 
                  tel_cdhstaut[10]  tel_cdhstcas[01]  tel_cdhstcas[02]
                  tel_cdhstcas[03]  tel_cdhstcas[04]  tel_cdhstcas[05]
                  tel_cdhstcas[06]  tel_cdhstcas[07]  tel_cdhstcas[8]
                  tel_cdhstcas[9]   tel_cdhstcas[10]  tel_dsmsgseg
                  WITH FRAME f_cadseg_2.  
           LEAVE.

        END. /* Fim do DO WHILE TRUE */

        LEAVE.

    END. /* Fim do WHILE TRUE */ 

    RETURN "OK".

END PROCEDURE.


PROCEDURE proc_grava_dados:
    
    IF  NOT VALID-HANDLE(h-b1wgen0181) THEN
        RUN sistema/generico/procedures/b1wgen0181.p 
        PERSISTENT SET h-b1wgen0181.

    MESSAGE "Aguarde, gravando dados da seguradora...".
    RUN Grava_dados_seguradora IN h-b1wgen0181(INPUT glb_cdcooper,
                                               INPUT glb_cdagenci,
                                               INPUT 0 /*nrdcaixa*/,
                                               INPUT glb_cdoperad,
                                               INPUT glb_dtmvtolt,
                                               INPUT 1 /*idorigem*/,
                                               INPUT glb_nmdatela,
                                               INPUT glb_cdprogra,
                                               INPUT glb_cdbccxlt,
                                               INPUT tel_cdsegura,
                                               INPUT tel_nmsegura,
                                               INPUT tel_nmresseg,
                                               INPUT tel_flgativo,
                                               INPUT tel_nrcgcseg,
                                               INPUT tel_nrctrato,
                                               INPUT tel_nrultpra,
                                               INPUT tel_nrlimpra,
                                               INPUT tel_nrultprc,
                                               INPUT tel_nrlimprc,
                                               INPUT tel_dsasauto,
                                               INPUT tel_dsmsgseg,
                                               INPUT tel_cdhstaut,
                                               INPUT tel_cdhstcas,
                                               INPUT glb_cddopcao,
                                               OUTPUT aux_nmdcampo,
                                               OUTPUT TABLE tt-erro).
    HIDE MESSAGE NO-PAUSE.
    DELETE OBJECT h-b1wgen0181.

    IF RETURN-VALUE <> "OK"   THEN
        DO:

        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        IF AVAIL tt-erro   THEN
            MESSAGE tt-erro.dscritic.
        ELSE
            MESSAGE "Erro na gravacao da seguradora.".
            
        PAUSE.
    
        RETURN "NOK".

    END.
    ELSE
        DO:
            MESSAGE "Operacao efetuada com sucesso!".
            PAUSE 2 NO-MESSAGE.
            HIDE MESSAGE NO-PAUSE.
        END.
        
    RETURN "OK".

END PROCEDURE.


PROCEDURE proc_zera_campos:

    ASSIGN tel_cdsegura = 0
           tel_nmsegura = ""
           tel_nmresseg = ""
           tel_nrcgcseg = 0
           tel_nrctrato = 0
           tel_nrultpra = 0
           tel_nrlimpra = 0
           tel_nrultprc = 0
           tel_nrlimprc = 0
           tel_dsasauto = ""
           tel_dsmsgseg = ""
           tel_cdhstaut = 0
           tel_cdhstcas = 0.

    RETURN "OK".

END PROCEDURE.


PROCEDURE proc_confirma:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
       aux_confirma = "N".
       glb_cdcritic = 78.
       RUN fontes/critic.p.
       MESSAGE glb_dscritic UPDATE aux_confirma.
       glb_cdcritic = 0.
       LEAVE.
                                
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
         aux_confirma <> "S"                  THEN
         DO:
             glb_cdcritic = 79.
             RETURN "NOK".
         END.
    
    RETURN "OK".
             
END PROCEDURE.


PROCEDURE proc_limpa_tela:

    HIDE FRAME f_cadseg.
    
    HIDE FRAME f_cadseg_2.
    
    CLEAR FRAME f_cadseg ALL NO-PAUSE.
    
    CLEAR FRAME f_cadseg_2 ALL NO-PAUSE.
    
END PROCEDURE.

PROCEDURE proc_valida_dados:
    
    IF NOT VALID-HANDLE(h-b1wgen0181) THEN
       RUN sistema/generico/procedures/b1wgen0181.p 
       PERSISTENT SET h-b1wgen0181.

    RUN Valida_inclusao_seguradora IN h-b1wgen0181(INPUT glb_cdcooper,
                                                   INPUT glb_cdagenci,
                                                   INPUT 0 /*nrdcaixa*/,
                                                   INPUT glb_cdoperad,
                                                   INPUT glb_dtmvtolt,
                                                   INPUT 1 /*idorigem*/,
                                                   INPUT glb_nmdatela,
                                                   INPUT glb_cdprogra,
                                                   INPUT glb_cdbccxlt,
                                                   INPUT tel_cdsegura,
                                                   INPUT tel_nmsegura,
                                                   INPUT tel_nrcgcseg,
                                                   INPUT tel_dsasauto,
                  /* valida completa seguradora */ INPUT YES, 
                                                   INPUT glb_cddopcao,
                                                   OUTPUT aux_nmdcampo,
                                                   OUTPUT TABLE tt-erro).
    DELETE OBJECT h-b1wgen0181.
    
    IF  RETURN-VALUE <> "OK"   THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
           IF AVAIL tt-erro   THEN
               MESSAGE tt-erro.dscritic.
           ELSE
               MESSAGE "Erro na validação da seguradora.".
            
           PAUSE.
    
           RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/*............................................................................*/
