/* .............................................................................

   Programa: Fontes/contas_j.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2006                         Ultima Atualizacao: 25/01/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Cadastramento de pessoa JURIDICA
                                                 
   Alteracoes: 31/08/2007 - Alterado para nao passar parametros na chamada da
                            opcao "Cliente Financeiro" (Elton).
   
               30/01/2009 - Retirada variavel tel_inarqcbr 'Recebe Arq.Cobranca'
                            e email (Gabriel).

               17/07/2009 - Incluido ITEM de BENS (Gabriel).
        
               26/08/2009 - Arrumado nome de rotina FINANCEIRO-INF.ADICIONAIS 
                            (Gabriel)
                        
               15/03/2010 - Adaptado para uso de BO (Jose Luis, DB1)
               
               27/10/2010 - Verifica vigência dos procuradores (Gabriel, DB1)
               
               07/12/2010 - Retirado verifição da vigência dos procuradores.
                            Passada para BO 31. (Gabriel, DB1)
                            
               24/03/2011 - Incluir rotina de DDA (Gabriel)
               
               23/08/2011 - Incluir Participação em outras empresas ref ao 
                            Grupo Economico (Guilherme).
                            
               21/06/2012 - Incluido passagem de parametros para a rotina
                            PROCURADORES.Projeto GP - Socios Menores (Adriano).
               
               05/07/2013 - Incluido opcao de Imunidade tributaria 
                            (Andre Santos - SUPERO)
                            
               24/07/2014 - Projeto Automatização de Consultas em Propostas
                            de Crédito (Jonata-RKAM).
                            
               30/12/2014 - Incluir item novo "LIBERAR/BLOQUEAR". (James)
               
               29/01/2015 - Incluido de opcao Convenio CDC
                            (Andre Santos - SUPERO)
                            
               17/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
                            
               01/09/2015 - Reformulacao cadastral (Tiago Castro-RKAM).
               
               25/01/2016 - #383108 Ajuste das opcoes da tela pois nao estavam
                            aparecendo as opcoes BENS e INF. ADICIONAIS
                            corretamente (Carlos)
.............................................................................*/

{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgen0031tt.i }
{ sistema/generico/includes/b1wgen0051tt.i }
{ sistema/generico/includes/b1wgen0072tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }

DEFINE VARIABLE h-bowgen0051 AS HANDLE      NO-UNDO.
DEFINE VARIABLE aux_permalte AS LOGICAL     NO-UNDO.
DEFINE VARIABLE aux_verrespo AS LOGICAL     NO-UNDO.

DO WHILE TRUE:

  IF  NOT VALID-HANDLE(h-bowgen0051) THEN
      RUN sistema/generico/procedures/b1wgen0051.p
          PERSISTENT SET h-bowgen0051.

  RUN Busca-Associado IN h-bowgen0051
      ( INPUT glb_cdcooper,
        INPUT glb_cdagenci,
        INPUT 0,
        INPUT glb_cdoperad,
        INPUT tel_nrdconta,
        INPUT 1,
        INPUT glb_nmdatela,
        INPUT tel_idseqttl,
        INPUT glb_dtmvtolt,
       OUTPUT TABLE tt-mensagens-contas,
       OUTPUT TABLE tt-crapass,
       OUTPUT TABLE tt-crapttl,
       OUTPUT TABLE tt-erro ) NO-ERROR.

  IF  ERROR-STATUS:ERROR THEN
      DO:
         MESSAGE ERROR-STATUS:GET-MESSAGE(1).
         RETURN "NOK".
      END.

  DELETE OBJECT h-bowgen0051.

  IF  RETURN-VALUE <> "OK" THEN
      DO:                      
         FIND FIRST tt-erro NO-ERROR.

         IF  AVAILABLE tt-erro THEN
             DO:
                MESSAGE tt-erro.dscritic.
                PAUSE 3 NO-MESSAGE.
                HIDE MESSAGE NO-PAUSE.
                RETURN "NOK".
             END.
      END.
   
   FIND tt-crapass WHERE tt-crapass.cdcooper = glb_cdcooper AND
                         tt-crapass.nrdconta = tel_nrdconta 
                         NO-LOCK NO-ERROR.

   ASSIGN tel_dspessoa = "JURIDICA"
          tel_nrcpfcgc = STRING(STRING(tt-crapass.nrcpfcgc,"99999999999999"),
                                "xx.xxx.xxx/xxxx-xx")
          tel_dstipcta = CAPS(tt-crapass.dstipcta)
          tel_dssitdct = tt-crapass.dssitdct
          tel_nmfatasi = tt-crapass.nmfansia
          tel_dsdopcao[01] = "IDENTIFICACAO"
          tel_dsdopcao[02] = "REGISTRO"
          tel_dsdopcao[03] = "REPRESENTANTE/PROCURADOR"
          tel_dsdopcao[04] = "PARTICIPACAO EMPRESAS" 
          tel_dsdopcao[05] = "TELEFONES"
          tel_dsdopcao[06] = "E_MAILS"   
          tel_dsdopcao[07] = "REFERENCIAS"
          tel_dsdopcao[08] = "CLIENTE FINANCEIRO"
          tel_dsdopcao[09] = "CONTA CORRENTE"     
          tel_dsdopcao[10] = "ORGAOS PROT. AO CREDITO"
          tel_dsdopcao[12] = "IMPRESSOES"
          tel_dsdopcao[13] = "FICHA CADASTRAL"
          tel_dsdopcao[14] = "ENDERECO"          
          tel_dsdopcao[15] = "BENS"
          tel_dsdopcao[16] = "IMUNIDADE TRIBUTARIA"    
          tel_dsdopcao[17] = "--FINANCEIRO--"
          tel_dsdopcao[18] = "Ativo/Passivo"
          tel_dsdopcao[19] = "Banco"
          tel_dsdopcao[20] = "Resultado"
          tel_dsdopcao[21] = "FATURAMENTO"
          tel_dsdopcao[22] = "INF. ADICIONAL"
          tel_dsdopcao[23] = "DESABILITAR OPERACOES".

   COLOR DISPLAY NORMAL tel_dsdopcao[01]  tel_dsdopcao[02]  tel_dsdopcao[03]  
                        tel_dsdopcao[04]  tel_dsdopcao[05]  tel_dsdopcao[06]
                        tel_dsdopcao[07]  tel_dsdopcao[08]  tel_dsdopcao[09] 
                        tel_dsdopcao[10]  tel_dsdopcao[12]  
                        tel_dsdopcao[13]  tel_dsdopcao[14]  tel_dsdopcao[15]
                        tel_dsdopcao[16]  tel_dsdopcao[17]  tel_dsdopcao[18] 
                        tel_dsdopcao[19]  tel_dsdopcao[20]  tel_dsdopcao[21]
                        tel_dsdopcao[22]  tel_dsdopcao[23]  
                        WITH FRAME f_conta_juridica.

   PAUSE 0.

   ASSIGN tel_dtaltera = tt-crapass.dtaltera.
   
   DISPLAY tt-crapass.cdagenci    @ crapass.cdagenci    
           tel_dsagenci       
           tel_nrdconta   
           tt-crapass.nmprimtl    @ crapass.nmprimtl    
           tt-crapass.inpessoa    @ crapass.inpessoa   
           tel_dspessoa    
           tel_nrcpfcgc        
           tel_idseqttl       
           tt-crapass.cdtipcta    @ crapass.cdtipcta  
           tel_nmfatasi        
           tel_dstipcta       
           tt-crapass.nrdctitg    @ crapass.nrdctitg
           tt-crapass.cdsitdct    @ crapass.cdsitdct    
           tel_dssitdct       
           tt-crapass.nrmatric    @ crapass.nrmatric
           tel_dsdopcao[01]    tel_dsdopcao[02]   tel_dsdopcao[03]
           tel_dsdopcao[04]    tel_dsdopcao[05]   tel_dsdopcao[06]
           tel_dsdopcao[07]    tel_dsdopcao[08]   tel_dsdopcao[09]
           tel_dsdopcao[10]    tel_dsdopcao[12]   
           tel_dsdopcao[13]    tel_dsdopcao[14]   tel_dsdopcao[15]
           tel_dsdopcao[16]    tel_dsdopcao[17]   tel_dsdopcao[18] 
           tel_dsdopcao[19]    tel_dsdopcao[20]   tel_dsdopcao[21]  
           tel_dsdopcao[22]    tel_dsdopcao[23]   
           WITH FRAME f_conta_juridica.  
   
   RUN exibe-mensagens-alerta.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      CHOOSE FIELD tel_dsdopcao[01]   tel_dsdopcao[02]   tel_dsdopcao[03]
                   tel_dsdopcao[04]   tel_dsdopcao[05]   tel_dsdopcao[06]
                   tel_dsdopcao[07]   tel_dsdopcao[08]   tel_dsdopcao[09]
                   tel_dsdopcao[10]   tel_dsdopcao[12]
                   tel_dsdopcao[13]   tel_dsdopcao[14]   tel_dsdopcao[15]
                   tel_dsdopcao[16]   tel_dsdopcao[18]   tel_dsdopcao[19]   
                   tel_dsdopcao[20]   tel_dsdopcao[21]   tel_dsdopcao[22]
                   tel_dsdopcao[23]   
             PAUSE 60 WITH FRAME f_conta_juridica.

      IF   LASTKEY = -1   THEN
           RETURN. /* Volta para tela CONTAS */

      HIDE MESSAGE NO-PAUSE.

      IF   FRAME-VALUE = tel_dsdopcao[1]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "IDENTIFICACAO".
                     
              { includes/acesso.i }
              
              RUN fontes/contas_dados_juridica.p.
           END.    
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[2]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "REGISTRO".
                     
              { includes/acesso.i }
              
              RUN fontes/contas_dados_completo_juridica.p.
           END.   
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[3]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "PROCURADORES".
                     
              { includes/acesso.i }
           
              RUN fontes/contas_procuradores.p
                        (INPUT glb_nmrotina,
                         INPUT tel_nrdconta,
                         INPUT "",
                         INPUT DEC(REPLACE(REPLACE(
                               REPLACE(tel_nrcpfcgc,".",""),"/",""),"-","")),
                         OUTPUT aux_permalte,
                         OUTPUT aux_verrespo,
                         OUTPUT TABLE tt-resp,
                         INPUT-OUTPUT TABLE tt-bens,
                         INPUT-OUTPUT TABLE tt-crapavt).

           END.  
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[4]   THEN
           DO:
               ASSIGN glb_cddopcao = "@"
                      glb_nmrotina = "PARTICIPACAO".
                        
               { includes/acesso.i }         
           
               RUN fontes/contas_participacao.p. 
           END.
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[5]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "TELEFONES".
                     
              { includes/acesso.i }

              RUN fontes/contas_telefones.p.
           END. 
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[6]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "E_MAILS".
                     
              { includes/acesso.i }

              RUN fontes/contas_emails.p.
           END.   
      ELSE  
      IF   FRAME-VALUE = tel_dsdopcao[7]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "REFERENCIAS".
                     
              { includes/acesso.i }

              RUN fontes/contas_contatos_juridica.p.
           END.   
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[8]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "CLIENTE FINANCEIRO".
                     
              { includes/acesso.i }
           
              RUN fontes/conta_sfn.p.
           END.
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[9]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "CONTA CORRENTE".
                     
              { includes/acesso.i }
           
              RUN fontes/contas_corrente.p.

           END. 
      ELSE 
      IF  FRAME-VALUE = tel_dsdopcao[10]   THEN
          DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "ORGAOS PROT. AO CREDITO".

              { includes/acesso.i }

              RUN fontes/protecao_credito.p (INPUT tt-crapass.inpessoa).
          END.
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[12]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "IMPRESSOES".
                     
              { includes/acesso.i }

              RUN fontes/impressoes.p.
           END.   
      ELSE           
      IF   FRAME-VALUE = tel_dsdopcao[13]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "FICHA CADASTRAL".
                     
              { includes/acesso.i }

              RUN fontes/ver_ficha_cadastral.p (TRUE).
           END.
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[14]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "ENDERECO".
                     
              { includes/acesso.i }

              RUN fontes/contas_endereco.p.
           END.  
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[15]   THEN
           DO:
               ASSIGN glb_cddopcao = "@"
                      glb_nmrotina = "BENS".
                        
               { includes/acesso.i }         
           
               RUN fontes/contas_bens.p.            
           END.
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[16]   THEN
           DO:
               ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "IMUNIDADE TRIBUTARIA".
                     
               { includes/acesso.i }

               RUN fontes/contas_imunidade.p
                        (INPUT glb_cdcooper,
                         INPUT DEC(REPLACE(REPLACE(
                               REPLACE(tel_nrcpfcgc,".",""),"/",""),"-","")),
                         INPUT glb_nmdatela).
           END.
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[18]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "FINANCEIRO-ATIVO/PASSIVO".
                     
              { includes/acesso.i }
              
              RUN fontes/contas_financeiro_dados.p.
           END.
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[19]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "FINANCEIRO-BANCO".
                     
              { includes/acesso.i }
              
              RUN fontes/contas_financeiro_bancos.p.
           END.   
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[20]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "FINANCEIRO-RESULTADO".
                     
              { includes/acesso.i }
              
              RUN fontes/contas_financeiro_resultado.p.
           END.   
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[21]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "FINANCEIRO-FATURAMENTO".
                     
              { includes/acesso.i }

              RUN fontes/contas_financeiro_faturamento.p.
           END.   
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[22]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "FINANCEIRO-INF.ADICIONAIS".
                     
              { includes/acesso.i }

              RUN fontes/contas_financeiro_infadicional.p.
           END.
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[15]   THEN
           DO: 
               ASSIGN glb_cddopcao = "@" 
                      glb_nmrotina = "PROTECAO CREDITO".

               { includes/acesso.i }

               RUN fontes/protecao_credito.p.
           
           END.
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[23]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "DESABILITAR OPERACOES".
                     
              { includes/acesso.i }

              RUN fontes/contas_liberar_bloquear.p.
           END.


      glb_nmrotina = "".
      
   END.
   
   IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
        RETURN. /* Volta para tela CONTAS */
END.         

IF  VALID-HANDLE(h-bowgen0051) THEN
    DELETE OBJECT h-bowgen0051.

/*............................................................................*/

PROCEDURE exibe-mensagens-alerta:
    
   FOR EACH tt-mensagens-contas BY tt-mensagens-contas.nrsequen:

       MESSAGE tt-mensagens-contas.dsmensag.

       READKEY.
       IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
           NEXT.
   END.
   
   HIDE MESSAGE NO-PAUSE.

   RETURN "OK".

END PROCEDURE.
