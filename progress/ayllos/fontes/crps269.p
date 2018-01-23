/* ..........................................................................

   Programa: Fontes/crps269.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah 
   Data    : Agosto/1999                       Ultima atualizacao: 05/06/2017
   
   Dados referentes ao programa:

   Frequencia: Semanal,
   Objetivo  : Atende a solicitacao 070.
               Listar os seguros de vida novos, cancelados e alterados.       
               Emite relatorio 218.

   Alteracoes: 07/02/2000 - Gerar pedido de impressao (Deborah).

               31/10/2005 - Acrescentado codigo do PAC ao relatorio (Diego).
               
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               25/04/2008 - Enviar email para Rene e Jose da AddMakler (Diego).
               
               28/01/2009 - Enviar email somente p/ aylloscecred@addmakler.com
                            .br (Gabriel).
                            
               05/07/2011 - Enviar e-mail para jeicy@cecred.coop.br (Henrique)
               
               13/12/2012 - Alteracao no relatorio para mostrar novas informacoes
                           (David Kruger).
                           
               04/03/2013 - Substituido e-mail jeicy@cecred.coop.br 
                            por cecredseguros@cecred.coop.br (Daniele). 
               
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               08/04/2014 - Inclusao dos e-mails elaine.silva@mdsinsure.com e 
                            angelica.silva@mdsinsure.com (Carlos)
                            
               12/06/2014 - Atualizar envio de e-mail para
                                elaine.silva@mdsinsure.com, 
                                pendencia.cecred@mdsinsure.com
                            (Douglas - Chamado 162075)

               04/09/2014 - Atualizar envio de e-mail para
                                emissao.cecred@mdsinsure.com
                            	daniella.ferreira@mdsinsure.com
                            	emissao.cecredseguros@mdsinsure.com
                            	cecredseguros@cecred.coop.br
                            (Douglas - Chamado 194868)
                            
               02/12/2014 - Atualizar envio de e-mail para
                                "sergio.buzzi@mdsinsure.com"                                
                                "emissao.cecredseguros@mdsinsure.com,"
                                "daniella.ferreira@mdsinsure.com"
                                "ariana.barba@mdsinsure.com"
                                "pendencia.cecred@mdsinsure.com"
                                "cecredseguros@cecred.coop.br" 
                                (Felipe - Chamado 228940) 
                                
               06/02/2015 - Alterado para exibir o operador que cancelou o seguro no
                            relatorio crrl618 SD 251771 (Odirlei-Amcom)

               07/04/2015 - Atualizar envio de e-mail para
                        		projetocecred@mdsinsure.com
                        		emissao.cecredseguros@mdsinsure.com
                        		ariana.barba@mdsinsure.com
                        		pendencia.cecredseguros@mdsinsure.com
                        		cecredseguros@cecred.coop.br
                            (Douglas - Chamado 271323)

               07/07/2015 - Remover email ariana.barba@mdsinsure.com
                            (Lucas Ranghetti #297888 )

               25/09/2015 - Substituido os emials do SEGUROS DE VIDA
                            (Tiago/Gielow #332160).
							
			   05/06/2017 - Substituindo emails do seguro, conforme
						    solicitado no chamado 683083. (Kelvin)
							
			   23/01/2017 - Adicionada nova coluna de premio do seguro,
							conforme solicitado no chamado 829811. (Kelvin)
............................................................................. */

DEF STREAM str_1.

{ includes/var_batch.i "NEW" }

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_nmempres     AS CHAR                              NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.

DEF        VAR aux_nmarqimp     AS CHAR                              NO-UNDO.
DEF        VAR rel_dsempres     AS CHAR    FORMAT "x(40)"            NO-UNDO.

DEF        VAR aux_dtiniref     AS DATE FORMAT "99/99/9999"          NO-UNDO.
DEF        VAR aux_dtfimref     AS DATE FORMAT "99/99/9999"          NO-UNDO.

DEF        VAR tot_qtsegnov     AS INTEGER  FORMAT "zzz,zzz,zz9"         NO-UNDO.
DEF        VAR tot_qtsegcan     AS INTEGER  FORMAT "zzz,zzz,zz9"         NO-UNDO.
DEF        VAR tot_qtsegalt     AS INTEGER  FORMAT "zzz,zzz,zz9"         NO-UNDO.
DEF        VAR tot_qtprenov     AS DECIMAL  FORMAT "zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR tot_qtprecan     AS DECIMAL  FORMAT "zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR tot_qtprealt     AS DECIMAL  FORMAT "zzz,zzz,z99.99"  NO-UNDO.

DEF        VAR aux_regexist     AS LOGICAL                           NO-UNDO.

DEF        VAR b1wgen0011       AS HANDLE                            NO-UNDO.
DEF        VAR aux_nmoperad     AS CHAR FORMAT "X(25)"               NO-UNDO.
DEF        VAR aux_nmopecnl     AS CHAR FORMAT "X(25)"               NO-UNDO.

FORM "PERIODO:" AT 23
     aux_dtiniref FORMAT "99/99/9999" 
     "A"
     aux_dtfimref FORMAT "99/99/9999" 
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_periodo.

FORM "SEGUROS CONTRATADOS:"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_inclusoes.

FORM "SEGUROS CANCELADOS:"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_cancelamentos.

FORM "SEGUROS ALTERADOS:"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_alteracoes.
 
FORM SKIP(1)
     tot_qtsegnov  AT 9 LABEL "QUANTIDADE DE SEGUROS CONTRATADOS"
	 tot_qtprenov  AT 11 LABEL "VALOR TOTAL PREMIOS CONTRATADOS"
	 SKIP(1)
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_totnov.

FORM SKIP(1)
     tot_qtsegcan  AT 10 LABEL "QUANTIDADE DE SEGUROS CANCELADOS"
	 tot_qtprecan  AT 12 LABEL "VALOR TOTAL PREMIOS CANCELADOS"
     SKIP(1)
	 WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_totcan.

FORM SKIP(1)
     tot_qtsegalt  AT 11 LABEL "QUANTIDADE DE SEGUROS ALTERADOS"
	 tot_qtprealt  AT 13 LABEL "VALOR TOTAL PREMIOS ALTERADOS"
     SKIP(1)
	 WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_totalt.

FORM crapass.cdagenci  LABEL "PA" 
     crapseg.nrdconta  LABEL "CONTA/DV"
     crapseg.nrctrseg  LABEL "PROPOSTA"
     crapseg.dtmvtolt  LABEL "INICIO VIGENCIA"
     crapass.nmprimtl  LABEL "TITULAR"         FORMAT "x(38)"
     crapseg.tpplaseg  LABEL "PLANO"
     aux_nmoperad      LABEL "OPERADOR"
	 crapseg.vlpreseg  LABEL "PREMIO"
     WITH DOWN NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_novos.

FORM crapass.cdagenci  LABEL "PA"
     crapseg.nrdconta  LABEL "CONTA/DV"
     crapseg.nrctrseg  LABEL "PROPOSTA"
     crapseg.dtcancel  LABEL "DATA CANC."
     crapass.nmprimtl  LABEL "TITULAR"          FORMAT "x(25)"
     crapseg.tpplaseg  LABEL "PLANO"
     aux_nmoperad      LABEL "OPERADOR"		  	FORMAT "x(20)" 
     aux_nmopecnl      LABEL "OPERADOR CANCEL." FORMAT "x(20)"
	 crapseg.vlpreseg  LABEL "PREMIO"
     WITH DOWN NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_cancel.

FORM crapass.cdagenci  LABEL "PA"
     crapseg.nrdconta  LABEL "CONTA/DV"
     crapseg.nrctrseg  LABEL "PROPOSTA"
     crapseg.dtultalt  LABEL "DATA ALTERACAO"
     crapass.nmprimtl  LABEL "TITULAR"         FORMAT "x(38)"
     crapseg.tpplaseg  LABEL "PLANO"
     aux_nmoperad      LABEL "OPERADOR"
	 crapseg.vlpreseg  LABEL "PREMIO"
     WITH DOWN NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_alter.

glb_cdprogra = "crps269".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

aux_nmarqimp = "rl/crrl218.lst".

{ includes/cabrel132_1.i }          /*  Monta cabecalho do relatorio  */

ASSIGN aux_dtiniref = (glb_dtmvtoan - WEEKDAY(glb_dtmvtoan)) + 1
       aux_dtfimref = glb_dtmvtoan
       aux_regexist = FALSE.

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

/* Ler inclusoes */

FOR EACH crapseg WHERE crapseg.cdcooper  = glb_cdcooper  AND
                       crapseg.dtinivig >= aux_dtiniref  AND           
                       crapseg.dtinivig <= aux_dtfimref  AND
                       crapseg.tpseguro = 3              NO-LOCK
                       BY crapseg.dtinivig 
                          BY crapseg.nrctrseg.
    
    IF  NOT aux_regexist          OR
        LINE-COUNTER(str_1) >= 80 THEN
        DO:
            IF   aux_regexist THEN
                 PAGE STREAM str_1.
                 
            DISPLAY STREAM str_1 aux_dtiniref aux_dtfimref WITH FRAME f_periodo.
            VIEW STREAM str_1 FRAME f_inclusoes.
            aux_regexist = TRUE.
        END.
        
    /*FIND crapass OF crapseg NO-LOCK NO-ERROR.*/
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                       crapass.nrdconta = crapseg.nrdconta 
                       NO-LOCK NO-ERROR.

    ASSIGN aux_nmoperad = " ".
    FIND crapope WHERE crapope.cdcooper = crapseg.cdcooper AND
                       crapope.cdoperad = crapseg.cdoperad
                       NO-LOCK NO-ERROR.

    IF   AVAIL crapope THEN
         ASSIGN aux_nmoperad = crapope.nmoperad.
    
    DISPLAY STREAM str_1 crapass.cdagenci crapseg.nrdconta crapseg.nrctrseg 
                         crapseg.dtmvtolt crapass.nmprimtl crapseg.tpplaseg
                         aux_nmoperad crapseg.vlpreseg WITH FRAME f_novos.
    
    DOWN STREAM str_1 WITH FRAME f_novos.
    
    ASSIGN tot_qtsegnov = tot_qtsegnov + 1
		   tot_qtprenov = tot_qtprenov + crapseg.vlpreseg.    
END. /* FOR EACH crapseg */

IF   tot_qtsegnov > 0 THEN
     DO:
         DISPLAY STREAM str_1 tot_qtsegnov tot_qtprenov WITH FRAME f_totnov.

         PAGE STREAM str_1.
     END.
    
/* Ler cancelamentos */

aux_regexist = FALSE.
     
FOR EACH crapseg WHERE crapseg.cdcooper  = glb_cdcooper   AND
                       crapseg.dtcancel >= aux_dtiniref   AND           
                       crapseg.dtcancel <= aux_dtfimref   AND
                       crapseg.tpseguro = 3               NO-LOCK
                       BY crapseg.dtcancel
                          BY crapseg.nrctrseg.
    
    IF  NOT aux_regexist          OR
        LINE-COUNTER(str_1) >= 80 THEN
        DO:
            IF   aux_regexist THEN
                 PAGE STREAM str_1.
                 
            DISPLAY STREAM str_1 aux_dtiniref aux_dtfimref WITH FRAME f_periodo.
            VIEW STREAM str_1 FRAME f_cancelamentos.
            aux_regexist = TRUE.
        END.
 
    /*FIND crapass OF crapseg NO-LOCK NO-ERROR.*/
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.nrdconta = crapseg.nrdconta
                       NO-LOCK NO-ERROR.

    ASSIGN aux_nmoperad = " ".
    FIND crapope WHERE crapope.cdcooper = crapseg.cdcooper AND
                       crapope.cdoperad = crapseg.cdoperad
                       NO-LOCK NO-ERROR.

    IF   AVAIL crapope THEN
         ASSIGN aux_nmoperad = crapope.nmoperad.

    /* buscar nome do operador que cancelou o seguro */
    ASSIGN aux_nmopecnl = " ".
    FIND crapope WHERE crapope.cdcooper = crapseg.cdcooper AND
                       crapope.cdoperad = crapseg.cdopecnl
                       NO-LOCK NO-ERROR.

    IF   AVAIL crapope THEN
         ASSIGN aux_nmopecnl = crapope.nmoperad.
    
    DISPLAY STREAM str_1 crapass.cdagenci crapseg.nrdconta crapseg.nrctrseg
                         crapseg.dtcancel crapass.nmprimtl crapseg.tpplaseg
                         aux_nmoperad aux_nmopecnl crapseg.vlpreseg WITH FRAME f_cancel.
    
    DOWN STREAM str_1 WITH FRAME f_cancel.
    
    ASSIGN tot_qtsegcan = tot_qtsegcan + 1
		   tot_qtprecan = tot_qtprecan + crapseg.vlpreseg.
	
    
END. /* FOR EACH crapseg */

IF   tot_qtsegcan > 0 THEN
     DO:
         DISPLAY STREAM str_1 tot_qtsegcan tot_qtprecan WITH FRAME f_totcan.
         PAGE STREAM str_1.
     END.
     
/* Ler alteracoes */

aux_regexist = FALSE.
     
FOR EACH crapseg WHERE crapseg.cdcooper  = glb_cdcooper   AND
                       crapseg.dtultalt >= aux_dtiniref   AND           
                       crapseg.dtultalt <= aux_dtfimref   AND
                       crapseg.tpseguro = 3               NO-LOCK
                       BY crapseg.dtultalt
                          BY crapseg.nrctrseg.
    
    IF  NOT aux_regexist          OR
        LINE-COUNTER(str_1) >= 80 THEN
        DO:
            IF   aux_regexist THEN
                 PAGE STREAM str_1.
                 
            DISPLAY STREAM str_1 aux_dtiniref aux_dtfimref WITH FRAME f_periodo.
            VIEW STREAM str_1 FRAME f_alteracoes.
            aux_regexist = TRUE.
        END.
 
    /*FIND crapass OF crapseg NO-LOCK NO-ERROR.*/
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.nrdconta = crapseg.nrdconta
                       NO-LOCK NO-ERROR.

    ASSIGN aux_nmoperad = " ".
    FIND crapope WHERE crapope.cdcooper = crapseg.cdcooper AND
                       crapope.cdoperad = crapseg.cdoperad
                       NO-LOCK NO-ERROR.

    IF   AVAIL crapope THEN
         ASSIGN aux_nmoperad = crapope.nmoperad.
    
    DISPLAY STREAM str_1 crapass.cdagenci crapseg.nrdconta crapseg.nrctrseg 
                         crapseg.dtultalt crapass.nmprimtl crapseg.tpplaseg
                         aux_nmoperad crapseg.vlpreseg WITH FRAME f_alter.
    
    DOWN STREAM str_1 WITH FRAME f_alter.
    
    ASSIGN tot_qtsegalt = tot_qtsegalt + 1
		   tot_qtprealt = tot_qtprealt + crapseg.vlpreseg.
    
END. /* FOR EACH crapseg */

IF   tot_qtsegalt > 0 THEN
     DISPLAY STREAM str_1 tot_qtsegalt tot_qtprealt WITH FRAME f_totalt.

OUTPUT STREAM str_1 CLOSE.

IF   tot_qtsegnov > 0 OR tot_qtsegcan > 0 OR tot_qtsegalt > 0 THEN
     DO:
         ASSIGN glb_nmformul = "132col"
                glb_nmarqimp = aux_nmarqimp
                glb_nrcopias = 2.
                   
         RUN fontes/imprim.p.   
         
         /* Enviar e-mail */ 
         RUN sistema/generico/procedures/b1wgen0011.p
             PERSISTENT SET b1wgen0011.
             
         RUN converte_arquivo IN b1wgen0011
                                (INPUT glb_cdcooper,
                                 INPUT aux_nmarqimp,
                                 INPUT SUBSTRING(aux_nmarqimp,4,7) + ".txt").
                                   
         RUN enviar_email IN b1wgen0011
                            (INPUT glb_cdcooper,
                             INPUT glb_cdprogra,
                             INPUT "cecred.ftpchubb@mdsinsure.com,"         +
                                   "pendencia.cecredseguros@mdsinsure.com," +
                                   "seguros@cecred.coop.br",
                             INPUT "SEGUROS DE VIDA",
                             INPUT SUBSTRING(aux_nmarqimp,4,7) + ".txt",
                             INPUT FALSE).
                                   
         DELETE PROCEDURE b1wgen0011.
     END.

RUN fontes/fimprg.p.

/* .......................................................................... */

