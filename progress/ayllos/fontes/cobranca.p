/*.............................................................................
  
  Programa: fontes/cobranca.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Gabriel
  Data    : Dezembro/2010                  Ultima atualizacao : 24/04/2015
  
  Dados referentes ao programa:
  
  Frequancia: Diario (On-line)
  Objetivo  : Mostrar a rotina COBRANCA da tela ATENDA.
  
  Alteracoes: 19/05/2011 - Informar se eh cobranca registrada (Guilherme).
  
              01/06/2011 - Ver Fabricio.
              
              06/06/2011 - Tratamento para nao permitir valor igual a zero para
                           o campo tt-cadastro-bloqueto.vllbolet. (Fabricio) 
                           
              29/06/2011 - Passar as criticas para a BO 0082 (Gabriel).
              
              21/07/2011 - Impressao para a Cobranca Registrada (Gabriel)
              
              26/09/2011 - Incluido a chamada para a procedure alerta_fraude e
                           quando incluir/alterar um convenio, foi fixado para "SIM"
                           o campo "Utiliza Credito Unificado" para os convenios
                           que forem cobranca registrada (Adriano).
                           
              12/03/2013 - Retirado a chamada para a procedure alerta_fraude.
                           A mesma, foi colocada dentro da procedure 
                           habilita-convenio (Adriano).             
              
              10/05/2013 - Retirado campo de valor maximo do boleto. (Jorge)
              
              05/06/2013 - Projeto Melhorias da Cobranca - alterado include
                           var_cobranca.i. (Rafael)
                           
              08/08/2013 - Mostrar somente convenios ativos no F7. (Rafael)
              
              19/09/2013 - Inclusao do campo logico Convenio Homologado,
                           habilitado apenas para o setor COBRANCA (Carlos)
                           
              10/04/2014 - Inclusao do help "3-CNAB 400" para a opçao 
                           "Recebe arquivo de retorno". (Carlos)
                           
              12/06/2014 - Remoçao da condiçao para considerar Conv. ativos,
                           pois agora vem carregados da BO59 (SD. 165347 - Lunelli)     
                           
              07/08/2014 - Incluir parametros par_nrconven na chamada da rotina
                           fontes/impressao_termo_cobranca.p  (Renato - Supero)
                           
              24/04/2015 - Incluido campos "Cooperado Emite e Expede" e
                           "Cooperativa Emite e Expede", removido opcao de 
                           alteracao e cancelamento de convenio. 
                           (Projeto DP 219 - Reinert)
.............................................................................*/

DEF INPUT PARAM par_nrdconta AS INTE                                 NO-UNDO.
                    
                       
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0082tt.i }         
         
{ includes/var_online.i }
{ includes/var_cobranca.i }


ASSIGN aux_flgfirst = TRUE
       aux_nrdlinha = 0. /* Para LOG na consulta */

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   RUN limpa_tela.
    
   RUN sistema/generico/procedures/b1wgen0082.p PERSISTEN SET h-b1wgen0082.
           
   RUN carrega-convenios-ceb IN h-b1wgen0082
                                 (INPUT glb_cdcooper,
                                  INPUT 0,
                                  INPUT 0,
                                  INPUT glb_cdoperad,
                                  INPUT glb_nmdatela,
                                  INPUT 1, /* Ayllos */
                                  INPUT par_nrdconta,
                                  INPUT 1, /* Tit. */ 
                                  INPUT glb_dtmvtolt,
                                  INPUT aux_flgfirst,
                                 OUTPUT par_msgdpsnh,
                                 OUTPUT TABLE tt-cadastro-bloqueto,
                                 OUTPUT TABLE tt-crapcco,
                                 OUTPUT TABLE tt-titulares,
                                 OUTPUT TABLE tt-emails-titular).

   DELETE PROCEDURE h-b1wgen0082.
   
   ASSIGN aux_flgfirst = FALSE.

   /* Mostra Opcoes */
   DISPLAY tel_dsdopcao           
           WITH FRAME f_cobranca.

   COLOR DISPLAY NORMAL tel_dsdopcao WITH FRAME f_cobranca.   

   /* Destacar opcao em uso */
   COLOR DISPLAY MESSAGE tel_dsdopcao WITH FRAME f_cobranca.
    
   OPEN QUERY q-cadastro-bloqueto FOR EACH tt-cadastro-bloqueto EXCLUSIVE-LOCK.
   
   IF   aux_nrdlinha > 0   THEN
        DO:
             REPOSITION q-cadastro-bloqueto TO ROW aux_nrdlinha.
             ASSIGN aux_nrdlinha = 0.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      /* Selecionar evento e opcao ao mesmo tempo */
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         ENABLE b-cadastro-bloqueto WITH FRAME f_cobranca.
         
         APPLY "ENTRY" TO b-cadastro-bloqueto IN FRAME f_cobranca.
                
         READKEY PAUSE 1.  

         /*HIDE MESSAGE NO-PAUSE.*/

         /* Eventos do browse */
         IF  CAN-DO("CURSOR-UP,CURSOR-DOWN,HOME,PAGE-UP,PAGE-DOWN",
                   KEYFUNCTION(LASTKEY))  THEN
            APPLY KEYFUNCTION(LASTKEY) TO b-cadastro-bloqueto
                                          IN FRAME f_cobranca.
         ELSE
         IF   CAN-DO("GO,RETURN,END-ERROR",KEYFUNCTION(LASTKEY))  THEN
              DO:
                  LEAVE.
              END.

         COLOR DISPLAY MESSAGE tel_dsdopcao WITH FRAME f_cobranca.
                              
      END. /* Fim do DO WHILE TRUE */

      HIDE MESSAGE NO-PAUSE.

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
           LEAVE.

      LEAVE.

   END. /* FIM do DO WHILE TRUE */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        LEAVE.
       
   /* Controle para permissoes de usuarios */
   ASSIGN glb_cddopcao = "C"
          glb_nmrotina = "COBRANCA".

   /* Permissoes */
   { includes/acesso.i }
    /* Consulta */     
   DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

        IF   NOT AVAIL tt-cadastro-bloqueto   THEN
             LEAVE.
            
        ASSIGN aux_nrdlinha = CURRENT-RESULT-ROW("q-cadastro-bloqueto").

        HIDE btn_titular IN FRAME f_habilitacao.

        IF   tt-cadastro-bloqueto.nrcnvceb > 0   THEN
             FRAME f_habilitacao:TITLE =                 
" CONSULTA - COBRANCA (CEB " + STRING(tt-cadastro-bloqueto.nrcnvceb) + ")".
        ELSE
             FRAME f_habilitacao:TITLE =                 
" CONSULTA - COBRANCA ".

        tel_dsarqcbr = ENTRY (tt-cadastro-bloqueto.inarqcbr + 1,aux_dsarqcbr).
                    
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            DISPLAY tt-cadastro-bloqueto.nrconven
                    tt-cadastro-bloqueto.dsorgarq
                    tt-cadastro-bloqueto.dssitceb 
                    tt-cadastro-bloqueto.inarqcbr
                    tel_dsarqcbr
                    tt-cadastro-bloqueto.dsdemail
                    tt-cadastro-bloqueto.flgcruni
                    tt-cadastro-bloqueto.flgcebhm 
                    tt-cadastro-bloqueto.flgregis
                    IF tt-cadastro-bloqueto.flcooexp <> ? THEN STRING(tt-cadastro-bloqueto.flcooexp,"S/N")  ELSE "-"  @ tt-cadastro-bloqueto.flcooexp
                    IF tt-cadastro-bloqueto.flceeexp <> ? THEN STRING(tt-cadastro-bloqueto.flceeexp,"S/N")  ELSE "-"  @ tt-cadastro-bloqueto.flceeexp
                    WITH FRAME f_habilitacao.
            
            tt-cadastro-bloqueto.flgcebhm:VISIBLE IN FRAME f_habilitacao =
                tt-cadastro-bloqueto.dsorgarq = "IMPRESSO PELO SOFTWARE".

            /* Botao de 'Outros Titulares' so se tiver + de 1 Titular */
            /* E se for convenio INTERNET e esta ativa a senha  */
            IF   TEMP-TABLE tt-titulares:HAS-RECORDS        AND 
                 tt-cadastro-bloqueto.dsorgarq = "INTERNET" AND 
                 par_msgdpsnh = ""                          THEN
                 UPDATE btn_titular WITH FRAME f_habilitacao.
            ELSE
                 PAUSE.

            LEAVE.

        END.
        
        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
             LEAVE.

        IF   NOT TEMP-TABLE tt-titulares:HAS-RECORDS      OR 
             tt-cadastro-bloqueto.dsorgarq <> "INTERNET"  OR 
             par_msgdpsnh <> ""                           THEN
             LEAVE.

        OPEN QUERY q-titulares-c FOR EACH tt-titulares NO-LOCK.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            UPDATE b-titulares-c WITH FRAME f_titulares-c.
            LEAVE.
        END.

        HIDE FRAME f_titulares-c.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
             NEXT.

        LEAVE.
   
   END. /* Fim 'Consulta' */   
  
END.  /* Fim do DO WHILE TRUE */ 

RUN limpa_tela.

PROCEDURE limpa_tela:

   CLEAR FRAME f_habilitacao.

   HIDE FRAME f_cobranca.
   HIDE FRAME f_habilitacao.   
   HIDE FRAME f_titulares-c.
  
END PROCEDURE.

/* ......................................................................... */


