/*..............................................................................

   Programa: b1craplcm.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2007                    Ultima atualizacao: 12/06/2018

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Tratar INCLUSAO na tabela craplcm.

   Alteracoes: 17/12/2013 - Adicionado validate para tabela craplcm (Tiago).
            
               07/12/2015 - Adicionada verifica��o pelo index craplcm1 (Lunelli SD 327199).

			   31/05/2016 - Adicionado tratamento de erro para quando estourar
			               chave da CRAPLCM##3 retornar critica corretamente
						   (Tiago/Elton SD391162);
         
               12/06/2018 - P450 - Chamada da rotina para consistir lan�amento em conta corrente(LANC0001) na tabela CRAPLCM  - Jos� Carvalho(AMcom)
..............................................................................*/
{ sistema/generico/includes/b1wgen0200tt.i }

DEF TEMP-TABLE cratlcm NO-UNDO LIKE craplcm.

/* Vari�veis de uso da BO 200 */
DEF VAR h-b1wgen0200         AS HANDLE                              NO-UNDO.
DEF VAR aux_incrineg         AS INT                                 NO-UNDO.
DEF VAR aux_cdcritic         AS INT                                 NO-UNDO.
DEF VAR aux_dscritic         AS CHAR                                NO-UNDO.


PROCEDURE inclui-registro:
    DEF INPUT  PARAM TABLE         FOR cratlcm.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST cratlcm EXCLUSIVE-LOCK.
    
    /* Verifica se o lancamento ja foi cadastrado (craplcm1) */
    FIND craplcm WHERE craplcm.cdcooper = cratlcm.cdcooper   AND
                       craplcm.dtmvtolt = cratlcm.dtmvtolt   AND
                       craplcm.cdagenci = cratlcm.cdagenci   AND
                       craplcm.cdbccxlt = cratlcm.cdbccxlt   AND
                       craplcm.nrdolote = cratlcm.nrdolote   AND
                       craplcm.nrdctabb = cratlcm.nrdctabb   AND
                       craplcm.nrdocmto = cratlcm.nrdocmto
                       NO-LOCK NO-ERROR.

    IF   AVAILABLE craplcm   THEN
         DO:
             par_dscritic = "Lancamento ja cadastrado (01).".
             RETURN "NOK".
         END.

    /* Verifica se o lancamento ja foi cadastrado (craplcm3) */
    FIND craplcm WHERE craplcm.cdcooper = cratlcm.cdcooper   AND
                       craplcm.dtmvtolt = cratlcm.dtmvtolt   AND
                       craplcm.cdagenci = cratlcm.cdagenci   AND
                       craplcm.cdbccxlt = cratlcm.cdbccxlt   AND
                       craplcm.nrdolote = cratlcm.nrdolote   AND
                       craplcm.nrseqdig = cratlcm.nrseqdig
                       NO-LOCK NO-ERROR.

    IF   AVAILABLE craplcm   THEN
         DO:
             par_dscritic = "Lancamento ja cadastrado (02).".
             RETURN "NOK".                             
         END.
         
          /* BLOCO DA INSER�AO DA CRAPLCM */
          IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
            RUN sistema/generico/procedures/b1wgen0200.p 
              PERSISTENT SET h-b1wgen0200.

          RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
            (INPUT cratlcm.dtmvtolt            /* par_dtmvtolt */
            ,INPUT cratlcm.cdagenci            /* par_cdagenci */
            ,INPUT cratlcm.cdbccxlt            /* par_cdbccxlt */
            ,INPUT cratlcm.nrdolote            /* par_nrdolote */
            ,INPUT cratlcm.nrdconta            /* par_nrdconta */
            ,INPUT cratlcm.nrdocmto            /* par_nrdocmto */
            ,INPUT cratlcm.cdhistor            /* par_cdhistor */
            ,INPUT cratlcm.nrseqdig            /* par_nrseqdig */
            ,INPUT cratlcm.vllanmto            /* par_vllanmto */
            ,INPUT cratlcm.nrdctabb            /* par_nrdctabb */
            ,INPUT cratlcm.cdpesqbb            /* par_cdpesqbb */
            ,INPUT cratlcm.vldoipmf            /* par_vldoipmf */
            ,INPUT cratlcm.nrautdoc            /* par_nrautdoc */
            ,INPUT cratlcm.nrsequni            /* par_nrsequni */
            ,INPUT cratlcm.cdbanchq            /* par_cdbanchq */
            ,INPUT cratlcm.cdcmpchq            /* par_cdcmpchq */
            ,INPUT cratlcm.cdagechq            /* par_cdagechq */
            ,INPUT cratlcm.nrctachq            /* par_nrctachq */
            ,INPUT cratlcm.nrlotchq            /* par_nrlotchq */
            ,INPUT cratlcm.sqlotchq            /* par_sqlotchq */
            ,INPUT cratlcm.dtrefere            /* par_dtrefere */
            ,INPUT cratlcm.hrtransa            /* par_hrtransa */
            ,INPUT cratlcm.cdoperad            /* par_cdoperad */
            ,INPUT cratlcm.dsidenti            /* par_dsidenti */
            ,INPUT cratlcm.cdcooper            /* par_cdcooper */
            ,INPUT cratlcm.nrdctitg            /* par_nrdctitg */
            ,INPUT cratlcm.dscedent            /* par_dscedent */
            ,INPUT cratlcm.cdcoptfn            /* par_cdcoptfn */
            ,INPUT cratlcm.cdagetfn            /* par_cdagetfn */
            ,INPUT cratlcm.nrterfin            /* par_nrterfin */
            ,INPUT cratlcm.nrparepr            /* par_nrparepr */
            ,INPUT cratlcm.nrseqava            /* par_nrseqava */
            ,INPUT cratlcm.nraplica            /* par_nraplica */
            ,INPUT cratlcm.cdorigem            /* par_cdorigem */
            ,INPUT cratlcm.idlautom            /* par_idlautom */
            /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
            ,INPUT 0                              /* Processa lote                                 */
            ,INPUT 0                              /* Tipo de lote a movimentar                     */
            /* CAMPOS DE SA�DA                                                                     */                                            
            ,OUTPUT TABLE tt-ret-lancto           /* Collection que cont�m o retorno do lan�amento */
            ,OUTPUT aux_incrineg                  /* Indicador de cr�tica de neg�cio               */
            ,OUTPUT aux_cdcritic                  /* C�digo da cr�tica                             */
            ,OUTPUT aux_dscritic).                /* Descri�ao da cr�tica                          */
  
            IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
              DO:  
                IF aux_incrineg > 0 THEN
					par_dscritic = "N�o foi poss�vel efetuar o lan�amento de d�bito.".
				ELSE
					par_dscritic = "Transferencia nao efetivada, tente novamente (03).".

				RETURN "NOK".
              END.   
              
            IF  VALID-HANDLE(h-b1wgen0200) THEN
                DELETE PROCEDURE h-b1wgen0200.

      /*Bloco para tratamento de erro do create da lcm try catch*/
      CATCH eSysError AS Progress.Lang.SysError:
      /*eSysError:GetMessage(1) Pegar a mensagem de erro do sistema*/
      /*Definindo minha propria critica*/
      par_dscritic = "Transferencia nao efetivada, tente novamente (03).".
      RETURN "NOK".
    END CATCH.

END PROCEDURE. /* inclui-registro */

PROCEDURE exclui-registro:
    DEF INPUT  PARAM TABLE         FOR cratlcm.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST cratlcm EXCLUSIVE-LOCK.
    
    /* Verifica se o lancamento existe */
    FIND craplcm WHERE craplcm.cdcooper = cratlcm.cdcooper   AND
                       craplcm.dtmvtolt = cratlcm.dtmvtolt   AND
                       craplcm.cdagenci = cratlcm.cdagenci   AND
                       craplcm.cdbccxlt = cratlcm.cdbccxlt   AND
                       craplcm.nrdolote = cratlcm.nrdolote   AND
                       craplcm.nrseqdig = cratlcm.nrseqdig
                       EXCLUSIVE-LOCK NO-ERROR.

    IF   NOT AVAILABLE craplcm   THEN
         DO:
             par_dscritic = "Lancamento nao cadastrado.".
             RETURN "NOK".
         END.

    /* Cria o registro */
    DELETE craplcm.
    
END PROCEDURE. /* exclui-registro */


/*............................................................................*/
