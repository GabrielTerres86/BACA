/* ..........................................................................

   Programa: Fontes/lislot_1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Agosto/2006                         Ultima atualizacao: 09/11/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LISLOT.

   
   Alteracoes: 04/10/2006 - Substituido crapcop.cdcooper por glb_cdcooper
                            (Elton).

               25/07/2008 - Alterado format do campo documento para nao 
                            estourar (Gabriel).

               05/05/2009 - Criado filtro para o campo Conta (Fernando).
               
               09/02/2010 - Incluidos na tela, campos Total de registros
                            e Total dos valores (GATI - Daniel).
                            
               27/07/2011 - Atribuido para tel_dtinicio o primeiro dia do mes
                            corrente, e, para tel_dttermin, a data em 
                            glb_dtmvtolt. Gerado log da pesquisa realizada. 
                            (Fabricio)
               24/07/2013 - Performance, alteracao de ordem nas clausulas 
                            (Passig - AMCOM)
               
               11/11/2014 - #170798 Aumento de 30 para 31 no numero de dias da
                            divisao dos meses para atender o prazo de 3 meses
                            de consulta. Retornada a versão sem chamada ao fonte
                            b1wgen0184.p pois a versao web nao foi liberada ainda. 
                            VERSAO WEB deste fonte: 020000 (Versão RoundTable)
                            (Carlos)
                            
               21/11/2014 - Ajustes nas labels onde estavam "PAC" para "PA" (Kelvin - SD 224358)
                            
               28/03/2014 - Adaptado para a B1wgen0184.p - Jéssica Laverde (DB1) 
               
               15/04/2015 - Aumentar format do nrdocmto para 25 posicoes    
                            (Lucas Ranghetti #275848)  
                            
               29/06/2015 - Adicionado format no campo valor pois nao estava mais mostrando
                            os valores conforme relatado no chamado 302314. (Kelvin)     
               
               09/11/2015 - Removido as virgulas do numero de documento para aumentar
                            seu format para 31 posicoes conforme solicitado no chamado
                            348989. (Kelvin)
                            
............................................................................. */

{includes/var_online.i}
{ sistema/generico/includes/b1wgen0184tt.i }
{ sistema/generico/includes/var_internet.i }
                                                           
DEF VAR h-b1wgen0184 AS HANDLE                                 NO-UNDO. 

DEF VAR tel_dtinicio AS  DATE FORMAT "99/99/9999"              NO-UNDO.
DEF VAR tel_dttermin AS  DATE FORMAT "99/99/9999"              NO-UNDO.
DEF VAR aux_soma     AS  INTE                                  NO-UNDO.
DEF VAR tot_vllanmto AS  DECI                                  NO-UNDO.
DEF VAR tot_registro AS  INTE                                  NO-UNDO.
DEF VAR aux_dslog    AS  CHAR                                  NO-UNDO.
DEF VAR aux_qtdmeses AS  DECI                                  NO-UNDO.

DEF  VAR tel_tpdopcao AS CHAR FORMAT "x(9)" 
     VIEW-AS COMBO-BOX INNER-LINES 3 
     LIST-ITEMS "COOPERADO", "CAIXA" , "LOTE P/PA"
     INIT "COOPERADO"                                                NO-UNDO.

DEF INPUT PARAM par_cdagenci AS INTE FORMAT "zz9"                NO-UNDO.
DEF INPUT PARAM par_cdhistor AS INTE FORMAT "zzz9"               NO-UNDO.
DEF INPUT PARAM par_nrdconta AS INTE FORMAT "zzzz,zzz,9"         NO-UNDO.
DEF INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.


DEF  VAR aux_qtregist AS INTE                                        NO-UNDO. 
DEF  VAR aux_nmdcampo AS INTE                                        NO-UNDO. 
DEF  VAR aux_nmarqpdf AS CHAR                                        NO-UNDO.
DEF  VAR aux_vllanmto AS DECI                                        NO-UNDO.
DEF  VAR aux_registro AS INTE                                        NO-UNDO.

FORM 
    "Data Inicial:"     AT 5
     tel_dtinicio       HELP "Informe a data inicial da consulta." 
     SPACE(3)
     "Data Final:"  
     tel_dttermin       HELP "Informe a data final da consulta."
     WITH FRAME f_dados overlay ROW 8 NO-LABEL NO-BOX COLUMN 2.

DEF QUERY q_historico FOR tt-retorno.

DEF BROWSE b_historico QUERY q_historico
    DISPLAY tt-retorno.dtmvtolt     COLUMN-LABEL "Data"
            tt-retorno.cdagenci     COLUMN-LABEL "PA"
            tt-retorno.nrdconta     COLUMN-LABEL "Conta"
            tt-retorno.nmprimtl     COLUMN-LABEL "Titular"   FORMAT "x(25)" 
            tt-retorno.nrdocmto     COLUMN-LABEL "Documento" 
                                    FORMAT "zzzzzzzzzzzzzzzzzzzzzzzzzzzzz9"
            tt-retorno.vllanmto     COLUMN-LABEL "Valor" FORMAT ">>,>>>,>>9.99" 
            WITH WIDTH 78 5 DOWN SCROLLBAR-VERTICAL.

FORM   b_historico  HELP "Use as SETAS para navegar ou <F4> para sair." SKIP
       "Quantidade de Registros:" AT 1
       tot_registro               AT 25 NO-LABEL FORMAT ">>>>>>>>9"
       "Valor Total:"             AT 37
       tot_vllanmto               AT 49 NO-LABEL FORMAT ">>>,>>>,>>9.99"
       WITH  NO-BOX CENTERED OVERLAY ROW 10 FRAME f_historico.

ASSIGN tel_dtinicio = DATE(MONTH(glb_dtmvtolt), 01, YEAR(glb_dtmvtolt))
       tel_dttermin = glb_dtmvtolt.

UPDATE tel_dtinicio tel_dttermin WITH FRAME f_dados.

RUN Busca_Dados.

IF RETURN-VALUE <> "OK" THEN
    NEXT.


OPEN QUERY q_historico
FOR EACH tt-retorno.
ENABLE b_historico WITH FRAME f_historico.
     
QUERY q_historico:GET-FIRST().

HIDE MESSAGE NO-PAUSE.

        
DISPLAY tot_registro 
        tot_vllanmto
WITH  FRAME f_historico.

WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
HIDE FRAME f_historico.

/*........................................................................... */

/* -------------------------------------------------------------------------- */
/*                      EFETUA A PESQUISA DOS HISTORICOS                      */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-retorno.
    EMPTY TEMP-TABLE tt-craplcx.
    EMPTY TEMP-TABLE tt-craplcm.
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Busca_Dados IN h-b1wgen0184
                  (  INPUT glb_cdcooper,
                     INPUT par_cdagenci,
                     INPUT 0,
                     INPUT glb_cdoperad,
                     INPUT glb_nmdatela,
                     INPUT 1, /* idorigem */
                     INPUT glb_dsdepart,
                     INPUT glb_dtmvtolt,
                     INPUT glb_cddopcao,
                     INPUT tel_tpdopcao,
                     INPUT par_cdhistor,
                     INPUT par_nrdconta,
                     INPUT tel_dtinicio,
                     INPUT tel_dttermin,
                     INPUT 0, /* nrregist */
                     INPUT 0, /* nriniseq */
                     INPUT TRUE, /* flgerlog */
                    OUTPUT aux_qtregist,
                    OUTPUT aux_nmdcampo,
                    OUTPUT tot_vllanmto,
                    OUTPUT tot_registro,
                    OUTPUT TABLE tt-lislot,
                    OUTPUT TABLE tt-lislot-aux,
                    OUTPUT TABLE tt-retorno,
                    OUTPUT TABLE tt-craplcx,
                    OUTPUT TABLE tt-craplcx-aux,
                    OUTPUT TABLE tt-craplcm,
                    OUTPUT TABLE tt-craplcm-aux,
                    OUTPUT TABLE tt-erro) NO-ERROR.

    RUN desconecta_handle.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */
/*----------------------------------------------------------------------------*/
PROCEDURE conecta_handle:

    IF  NOT VALID-HANDLE(h-b1wgen0184) THEN
            RUN sistema/generico/procedures/b1wgen0184.p
                PERSISTENT SET h-b1wgen0184.
END PROCEDURE.

PROCEDURE desconecta_handle:

    IF  VALID-HANDLE(h-b1wgen0184) THEN
            DELETE OBJECT h-b1wgen0184.
END PROCEDURE.



