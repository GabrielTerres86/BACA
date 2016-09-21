/* .............................................................................

   Programa: Fontes/proepr_e.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/96.                         Ultima atualizacao: 01/06/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento das exclusoes das propostas.

   Alteracoes: 10/07/2001 - Aumentar a observacao nas propostas de emprestimos.
                            (Eduardo).
               01/12/2003 - Incluido campo Nivel Risco(Mirtes)

               11/06/2004 - Incluido campo tel_nivcalcu - Risco Calc.(Evandro)

               16/06/2004 - Acessar dados Tabela Avalistas Terceiros(Mirtes)
               
               17/08/2004 - Incluido campos cidade/uf/cep(Evandro).

               26/11/2004 - Excluir aditivos (se existentes) (Mirtes).
               
               29/08/2005 - Interveniente Anuente (Evandro).

               29/09/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapadi e crapadt (Diego).
               
               02/02/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               08/04/2008 - Alterado formato do campo "crawepr.qtpreemp" de 
                            "z9" para "zz9" 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
               
               17/06/2009 - Substituida variavel pro_dsdebens por pro_dsrelbem
                            e variavel pro_vloutras por pro_vldrendi (Elton). 
                          
               06/07/2009 - Cadastro de pessoa fisica e Juridica (Gabriel).
               
               11/12/2009 - Novo campo Qualificaçao da operacao (Gabriel).
               
               21/01/2010 - Alteracoes referente ao projeto CMAPRV 2 (David).
               
               05/03/2010 - Evitar erro no frame da observacao (Gabriel).
               
               18/03/2010 - Utilizar um browse dinamico (Gabriel).
               
               08/07/2010 - Projeto de melhorias de propostas.
                            Adaptacao BO 02 (Gabiel).
                            
               04/07/2011 - Logar chamada das procedures (Gabriel).             
               
               01/06/2015 - Adicionado parametros na chamada da procedure
                            obtem-dados-proposta-emprestimo. (Reinert)

............................................................................ */

DEF INPUT  PARAM par_nrdconta AS INTE                               NO-UNDO.
DEF INPUT  PARAM par_nrctremp AS INTE                               NO-UNDO.          


{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0056tt.i }  
{ sistema/generico/includes/b1wgen0069tt.i }
                                               
{ includes/var_online.i   }
{ includes/var_proepr.i   }
{ includes/var_proposta.i }
{ includes/gg0000.i       }


DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

   /* Verifica se o banco generico ja esta conectado */
   ASSIGN aux_flggener = f_verconexaogener().

   /* Se nao conseguiu se conectar */
   IF   NOT aux_flggener     AND
        NOT f_conectagener() THEN
        RETURN.

   RUN sistema/generico/procedures/b1wgen0002.p PERSISTEN SET h-b1wgen0002.

   RUN obtem-dados-proposta-emprestimo IN h-b1wgen0002 
                                         (INPUT glb_cdcooper,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT glb_cdoperad,
                                          INPUT glb_nmdatela,
                                          INPUT glb_inproces,
                                          INPUT 1, /* Ayllos */
                                          INPUT par_nrdconta,
                                          INPUT 1, /* Tit */ 
                                          INPUT glb_dtmvtolt,
                                          INPUT par_nrctremp,                                          
                                          INPUT "E", /* Exclusao */
                                          INPUT 0,
                                          INPUT TRUE,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-dados-coope,
                                          OUTPUT TABLE tt-dados-assoc,
                                          OUTPUT TABLE tt-tipo-rendi,
                                          OUTPUT TABLE tt-itens-topico-rating,
                                          OUTPUT TABLE tt-proposta-epr,
                                          OUTPUT TABLE tt-crapbem,
                                          OUTPUT TABLE tt-bens-alienacao,
                                          OUTPUT TABLE tt-rendimento,
                                          OUTPUT TABLE tt-faturam,
                                          OUTPUT TABLE tt-dados-analise,
                                          OUTPUT TABLE tt-interv-anuentes,
                                          OUTPUT TABLE tt-hipoteca,
                                          OUTPUT TABLE tt-dados-avais,
                                          OUTPUT TABLE tt-aval-crapbem,
                                          OUTPUT TABLE tt-msg-confirma).
           
   DELETE PROCEDURE h-b1wgen0002.

   /* Se nao estava conectado de antes, desconecta */
   IF   NOT aux_flggener  THEN
        RUN p_desconectagener.

   IF   RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF   AVAIL tt-erro   THEN
                 MESSAGE tt-erro.dscritic.
            ELSE
                 MESSAGE "Erro na busca dos dados da proposta.".

            DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                PAUSE 3 NO-MESSAGE.
                LEAVE.
            END.

            LEAVE.
        END.

   FIND FIRST tt-proposta-epr NO-LOCK NO-ERROR.
   
   DISPLAY tt-proposta-epr.vlemprst  tt-proposta-epr.qtpreemp 
           tt-proposta-epr.nivrisco  tt-proposta-epr.nivcalcu
           tt-proposta-epr.cdlcremp  tt-proposta-epr.cdfinemp 
           tt-proposta-epr.qtdialib  tt-proposta-epr.flgpagto 
           tt-proposta-epr.dtdpagto  tt-proposta-epr.dsctrliq 
           tt-proposta-epr.flgimppr  tt-proposta-epr.flgimpnp
           tt-proposta-epr.vlpreemp  tt-proposta-epr.dslcremp 
           tt-proposta-epr.dsfinemp  tt-proposta-epr.percetop 
           tt-proposta-epr.idquapro  tt-proposta-epr.dsquapro  
           WITH FRAME f_proepr.

   DISPLAY tt-proposta-epr.dsobscmt WITH FRAME f_observ_comite NO-ERROR.

   DISPLAY tt-proposta-epr.dsobserv WITH FRAME f_observacao NO-ERROR.
      
   RUN fontes/confirma.p (INPUT "",
                          OUTPUT aux_confirma).

   IF   aux_confirma <> "S"   THEN
        LEAVE.
              
   RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

   RUN excluir-proposta IN h-b1wgen0002 (INPUT glb_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT glb_nmdatela,
                                         INPUT 1, /*Ayllos*/
                                         INPUT par_nrdconta,
                                         INPUT 1, /* Tit. */
                                         INPUT glb_dtmvtolt,
                                         INPUT par_nrctremp,
                                         INPUT TRUE,
                                         OUTPUT TABLE tt-erro).
   DELETE PROCEDURE h-b1wgen0002.

   IF   RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF   AVAIL tt-erro   THEN
                 MESSAGE tt-erro.dscritic.
            ELSE
                 MESSAGE "Erro na exclusao da proposta de emprestimo.".

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                PAUSE 3 NO-MESSAGE.
                LEAVE.
            END.            

        END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_proepr        NO-PAUSE.
HIDE FRAME f_observ_comite NO-PAUSE.
HIDE FRAME f_observacao    NO-PAUSE.

/* .......................................................................... */

