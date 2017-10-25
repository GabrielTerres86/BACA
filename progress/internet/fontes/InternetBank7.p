/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank7.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2007                        Ultima atualizacao: 18/08/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Carregar informe de rendimentos do cooperado.
   
   Alteracoes: 03/11/2008 - inclusao widget-pool (Martin)
                            
               06/03/2009 - Inclusao dos novos produtos de captacao
                            RDCPRE e RDCPOS (Magui).
                            
               09/04/2009 - Permitir escolha do ano referente ao IR (David).
               
               21/02/2011 - Retornar dados para restituicao (David).
               
               01/03/2011 - Retornar dados para restituicao na IF 85 (David).
               
               10/02/2012 - Adicioando codigo e descricao de retencao, ajustes 
                            no layout de Informe de Rendimento(Jorge).
                            
               28/02/2012 - Ajustes no valor do campo aux_vlrencot. (Jorge)
               
               15/02/2013 - Adicionado campo relacionado ao credito retorno de
                            sobras (vlsobras). (Jorge)
                            
               11/03/2013 - Ajuste em tratamento quando nao encontrado registro 
                            em crapdir, proc. proc_ir_juridica. (Jorge).
                            
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).

               12/03/2015 - Adicionado "APLICACOES DE RENDA FIXA" na busca das
                            informações do IR de PJ (Douglas - Chamado 263905)

               12/02/2016 - Ajustes no FOR EACH  da craplct pois a funcao
			                YEAR do Progress ocasionava problema quando
							repitida mais de uma vez dentro do where
							(Tiago/Thiago).

               29/06/2016 - M325 - Tributacao de Juros ao Capital
                            Alterado tratamento para cod.retencao 5706 p/ 3277
                            Novos parametros de entrada
                            (Guilherme/SUPERO)


               03/08/2016 - Inclusao de novos historicos de retorno de Sobras 
			                e de sobras na Conta Corrente (Marcos-Supero).
                      
               18/01/2017 - SD595294 - Retorno dos valores pagos em emprestimos
                            (Marcos-Supero)             

               24/03/2017 - SD638033 - Envio dos Rendimentos de Cotas Capital 
			                sem desconto IR (Marcos-Supero)

			   13/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

               18/08/2017 - Incluida validacao de IR para pessoa juridica
                            (Rafael Faria-Supero)
............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.

DEF VAR ant_dtrefere AS DATE                                           NO-UNDO.

DEF VAR ant_vlsdapli AS DECI                                           NO-UNDO.
DEF VAR ant_vlsdccdp AS DECI                                           NO-UNDO.
DEF VAR ant_vlsddvem AS DECI                                           NO-UNDO.
DEF VAR ant_vlttccap AS DECI                                           NO-UNDO.
DEF VAR ant_vlpoupan AS DECI                                           NO-UNDO.
DEF VAR ant_vlfundos AS DECI                                           NO-UNDO.
DEF VAR ant_vlirfcot AS DECI                                           NO-UNDO.
DEF VAR ant_vlprepag AS DECI                                           NO-UNDO.

DEF VAR aux_vlrencot AS DECI                                           NO-UNDO.
DEF VAR aux_vlirfcot AS DECI                                           NO-UNDO.
DEF VAR aux_vlprepag AS DECI                                           NO-UNDO.

DEF VAR aux_dtrefere AS DATE                                           NO-UNDO.

DEF VAR aux_vlsdapli AS DECI                                           NO-UNDO.
DEF VAR aux_vlsdccdp AS DECI                                           NO-UNDO.
DEF VAR aux_vlsddvem AS DECI                                           NO-UNDO.
DEF VAR aux_vlttccap AS DECI                                           NO-UNDO.
DEF VAR aux_vlpoupan AS DECI                                           NO-UNDO.
DEF VAR aux_vlfundos AS DECI                                           NO-UNDO.
DEF VAR aux_vlrendim AS DECI                                           NO-UNDO.
DEF VAR aux_vldjuros AS DECI                                           NO-UNDO.
DEF VAR aux_vldoirrf AS DECI                                           NO-UNDO.
DEF VAR aux_vlcpmfpg AS DECI                                           NO-UNDO.
DEF VAR aux_vlmoefix AS DECI                                           NO-UNDO.

DEF VAR aux_contador AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_cdacesso AS CHAR                                           NO-UNDO.
DEF VAR aux_nmmesref AS CHAR EXTENT 12 
        INIT ["JAN", "FEV","MAR","ABR","MAI","JUN",
              "JUL", "AGO","SET","OUT","NOV","DEZ"]                    NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_nrmesref AS INTE                                           NO-UNDO.
DEF VAR aux_nomedmes AS CHAR                                           NO-UNDO.
DEF VAR aux_vlrdrtrt AS DECI                                           NO-UNDO.
DEF VAR aux_vlrrtirf AS DECI                                           NO-UNDO.
DEF VAR aux_cdretenc AS INTE                                           NO-UNDO.
DEF VAR aux_dsretenc AS CHAR                                           NO-UNDO.
DEF VAR aux_dsre3426 AS CHAR                                           NO-UNDO.
DEF VAR aux_dsre5706 AS CHAR                                           NO-UNDO.
DEF VAR aux_dsre3277 AS CHAR                                           NO-UNDO.
DEF VAR aux_vlrentot AS DECI                                           NO-UNDO.
DEF VAR aux_vlirfont AS DECI                                           NO-UNDO.
DEF VAR aux_vlsobras AS DECI                                           NO-UNDO.
DEF VAR aux_nmsegntl AS CHAR										   NO-UNDO.

/* APLICACOES DE RENDA FIXA */
DEF VAR sol_vlsdapli AS DECI                                           NO-UNDO.
DEF VAR rel_vlrendim AS DECI                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_anorefer AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_tpinform AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrperiod AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

ASSIGN aux_dstransa = "Carregar informe de rendimentos".

IF  par_anorefer < 1995  THEN
    DO:
        ASSIGN aux_dscritic = "Ano referente deve ser maior que 1994."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".     
                             
        RUN proc_geracao_log (INPUT FALSE).
                
        RETURN "NOK".
    END.

IF  par_anorefer < 2016
AND par_tpinform = 1 THEN DO:
    ASSIGN aux_dscritic = "Ano do Informe Trimestral deve ser " +
                          "maior que 2015."
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

    RUN proc_geracao_log (INPUT FALSE).

    RETURN "NOK".
END.

FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop  THEN
    DO:
        ASSIGN aux_dscritic = "Cooperativa nao cadastrada."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".     
                             
        RUN proc_geracao_log (INPUT FALSE).
                
        RETURN "NOK".
    END.

FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                   crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                   
IF  NOT AVAILABLE crapass  THEN
    DO:
        ASSIGN aux_dscritic = "Associado nao cadastrado."                                  
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".   
          
        RUN proc_geracao_log (INPUT FALSE).  
                             
        RETURN "NOK".
    END.

/* Credito Retorno de Sobras */
FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper      AND
                       YEAR(craplct.dtmvtolt) = par_anorefer AND
                       craplct.cdagenci = 1                  AND
                       craplct.cdbccxlt = 100                AND
                       craplct.nrdolote = 8005               AND 
                       craplct.nrdconta = par_nrdconta       AND
                       (craplct.cdhistor = 1940 OR craplct.cdhistor = 2172 OR
					    craplct.cdhistor = 2174 OR craplct.cdhistor = 2173 OR
					    craplct.cdhistor = 1801 OR craplct.cdhistor = 64) 
                       NO-LOCK:
    ASSIGN aux_vlsobras = aux_vlsobras + craplct.vllanmto.
END.

/* Credito Retorno de Sobras em CC */
FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcooper      AND
                       YEAR(craplcm.dtmvtolt) = par_anorefer AND
                       craplcm.cdagenci = 1                  AND
                       craplcm.cdbccxlt = 100                AND
                       craplcm.nrdolote = 8005               AND 
                       craplcm.nrdconta = par_nrdconta       AND
                       (craplcm.cdhistor = 2175 OR craplcm.cdhistor = 2176 OR
					    craplcm.cdhistor = 2177 OR craplcm.cdhistor = 2178 OR
					    craplcm.cdhistor = 2179 OR craplcm.cdhistor = 2189) 
                       NO-LOCK:
    ASSIGN aux_vlsobras = aux_vlsobras + craplcm.vllanmto.
END.

IF  crapass.inpessoa = 1  THEN
    DO: 
        RUN proc_ir_fisica.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                      "</dsmsgerr>".
                                 
                RUN proc_geracao_log (INPUT FALSE).                      
                
                RETURN "NOK".
            END.
    END.
ELSE
IF  crapass.inpessoa = 2  THEN DO:

    IF  par_tpinform = 0 THEN
        RUN proc_ir_juridica.
    ELSE
        RUN proc_ir_juridica_trimestral.

    IF  RETURN-VALUE = "NOK"  THEN DO:
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                      "</dsmsgerr>".
                                 
                RUN proc_geracao_log (INPUT FALSE).                      
                
                RETURN "NOK".
            END.
    END.
                
RUN proc_geracao_log (INPUT TRUE).

RETURN "OK".

/*................................ PROCEDURES ................................*/

PROCEDURE proc_ir_fisica:

    FOR FIRST crapttl FIELDS(crapttl.nmextttl)
	                   WHERE crapttl.cdcooper = par_cdcooper AND	
							 crapttl.nrdconta = par_nrdconta AND
							 crapttl.idseqttl = 2
							 NO-LOCK:

	   ASSIGN aux_nmsegntl = crapttl.nmextttl.

	END.

    FIND FIRST crapdir WHERE crapdir.cdcooper  = par_cdcooper AND
                             crapdir.nrdconta  = par_nrdconta AND
                        YEAR(crapdir.dtmvtolt) = par_anorefer 
                             USE-INDEX crapdir1 NO-LOCK NO-ERROR.
                   
    IF  NOT AVAILABLE crapdir  THEN
        DO:
            aux_dscritic = "Nao ha dados para imposto de renda referente ao " +
                           "ano de " + STRING(par_anorefer,"9999") + ".".
            RETURN "NOK".
        END.

    ASSIGN aux_cdacesso = "IRENDA" + STRING(YEAR(crapdir.dtmvtolt),"9999").

    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 0            AND
                       craptab.cdacesso = aux_cdacesso AND
                       craptab.tpregist = 1            NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        DO:
            aux_dscritic = "Nao ha dados para imposto de renda referente ao " +
                           "ano de " + STRING(par_anorefer,"9999") + ".".
            RETURN "NOK".
        END.

    FIND FIRST crapsli WHERE crapsli.cdcooper = par_cdcooper AND
                             crapsli.nrdconta = par_nrdconta AND
                             crapsli.dtrefere = DATE(12,31,par_anorefer) 
                             NO-LOCK NO-ERROR.

    ASSIGN aux_vlirfcot = crapdir.vlirfcot
           aux_vlprepag = crapdir.vlprepag
           aux_vlrencot = crapdir.vlrencot
           aux_dtrefere = DATE(12,31,YEAR(crapdir.dtmvtolt))
           aux_vlsdapli = crapdir.vlsdapli + crapdir.vlsdrdpp  
           aux_vlsdccdp = crapdir.vlsdccdp + 
                         (IF AVAILABLE crapsli THEN crapsli.vlsddisp ELSE 0)
           aux_vlsddvem = crapdir.vlsddvem
           aux_vlttccap = crapdir.vlttccap
           aux_vlmoefix = DECIMAL(STRING(SUBSTR(craptab.dstextab,22,15),
                                         "999999,99999999"))
           aux_vlrendim = crapdir.vlrenrda[01] + crapdir.vlrenrda[02] +
                          crapdir.vlrenrda[03] + crapdir.vlrenrda[04] +
                          crapdir.vlrenrda[05] + crapdir.vlrenrda[06] +
                          crapdir.vlrenrda[07] + crapdir.vlrenrda[08] +
                          crapdir.vlrenrda[09] + crapdir.vlrenrda[10] +
                          crapdir.vlrenrda[11] + crapdir.vlrenrda[12] +

                          crapdir.vlrenrdc[01] + crapdir.vlrenrdc[02] +
                          crapdir.vlrenrdc[03] + crapdir.vlrenrdc[04] +
                          crapdir.vlrenrdc[05] + crapdir.vlrenrdc[06] +
                          crapdir.vlrenrdc[07] + crapdir.vlrenrdc[08] +
                          crapdir.vlrenrdc[09] + crapdir.vlrenrdc[10] +
                          crapdir.vlrenrdc[11] + crapdir.vlrenrdc[12] +
                          
                          crapdir.vlrenrpp + crapdir.vlabonpp + 
                          crapdir.vlabonrd + crapdir.vlabiopp +        
                          crapdir.vlabiord  -                          
                          
                          crapdir.vlirabap[1]  - crapdir.vlirabap[2] -
                          crapdir.vlirabap[3]  - crapdir.vlirabap[4] -
                          crapdir.vlirabap[5]  - crapdir.vlirabap[6] -
                          crapdir.vlirabap[7]  - crapdir.vlirabap[8] -
                          crapdir.vlirabap[9]  - crapdir.vlirabap[10] -
                          crapdir.vlirabap[11] - crapdir.vlirabap[12] -
                          
                          crapdir.vlirrdca[1]  - crapdir.vlirrdca[2] -
                          crapdir.vlirrdca[3]  - crapdir.vlirrdca[4] -
                          crapdir.vlirrdca[5]  - crapdir.vlirrdca[6] -
                          crapdir.vlirrdca[7]  - crapdir.vlirrdca[8] -
                          crapdir.vlirrdca[9]  - crapdir.vlirrdca[10] -
                          crapdir.vlirrdca[11] - crapdir.vlirrdca[12] -
                            
                          crapdir.vlirfrdc[01] - crapdir.vlirfrdc[02] -
                          crapdir.vlirfrdc[03] - crapdir.vlirfrdc[04] -
                          crapdir.vlirfrdc[05] - crapdir.vlirfrdc[06] -
                          crapdir.vlirfrdc[07] - crapdir.vlirfrdc[08] -
                          crapdir.vlirfrdc[09] - crapdir.vlirfrdc[10] -
                          crapdir.vlirfrdc[11] - crapdir.vlirfrdc[12] -
                          
                          crapdir.vlrirrpp[1]  - crapdir.vlrirrpp[2] -
                          crapdir.vlrirrpp[3]  - crapdir.vlrirrpp[4] -
                          crapdir.vlrirrpp[5]  - crapdir.vlrirrpp[6] -
                          crapdir.vlrirrpp[7]  - crapdir.vlrirrpp[8] -
                          crapdir.vlrirrpp[9]  - crapdir.vlrirrpp[10] -
                          crapdir.vlrirrpp[11] - crapdir.vlrirrpp[12] -
                          
                          crapdir.vlirajus[1]  - crapdir.vlirajus[2] -
                          crapdir.vlirajus[3]  - crapdir.vlirajus[4] -
                          crapdir.vlirajus[5]  - crapdir.vlirajus[6] -
                          crapdir.vlirajus[7]  - crapdir.vlirajus[8] -
                          crapdir.vlirajus[9]  - crapdir.vlirajus[10] -
                          crapdir.vlirajus[11] - crapdir.vlirajus[12]

           aux_vldoirrf = crapdir.vlirabap[1]  + crapdir.vlirabap[2] +
                          crapdir.vlirabap[3]  + crapdir.vlirabap[4] +
                          crapdir.vlirabap[5]  + crapdir.vlirabap[6] +
                          crapdir.vlirabap[7]  + crapdir.vlirabap[8] +
                          crapdir.vlirabap[9]  + crapdir.vlirabap[10] +
                          crapdir.vlirabap[11] + crapdir.vlirabap[12] +
                          
                          crapdir.vlirrdca[1]  + crapdir.vlirrdca[2] +
                          crapdir.vlirrdca[3]  + crapdir.vlirrdca[4] +
                          crapdir.vlirrdca[5]  + crapdir.vlirrdca[6] +
                          crapdir.vlirrdca[7]  + crapdir.vlirrdca[8] +
                          crapdir.vlirrdca[9]  + crapdir.vlirrdca[10] +
                          crapdir.vlirrdca[11] + crapdir.vlirrdca[12] +
                          
                          crapdir.vlirfrdc[01] + crapdir.vlirfrdc[02] +
                          crapdir.vlirfrdc[03] + crapdir.vlirfrdc[04] +
                          crapdir.vlirfrdc[05] + crapdir.vlirfrdc[06] +
                          crapdir.vlirfrdc[07] + crapdir.vlirfrdc[08] +
                          crapdir.vlirfrdc[09] + crapdir.vlirfrdc[10] +
                          crapdir.vlirfrdc[11] + crapdir.vlirfrdc[12] +

                          crapdir.vlrirrpp[1]  + crapdir.vlrirrpp[2] +
                          crapdir.vlrirrpp[3]  + crapdir.vlrirrpp[4] +
                          crapdir.vlrirrpp[5]  + crapdir.vlrirrpp[6] +
                          crapdir.vlrirrpp[7]  + crapdir.vlrirrpp[8] +
                          crapdir.vlrirrpp[9]  + crapdir.vlrirrpp[10] +
                          crapdir.vlrirrpp[11] + crapdir.vlrirrpp[12] +
                    
                          crapdir.vlirajus[1]  + crapdir.vlirajus[2] +
                          crapdir.vlirajus[3]  + crapdir.vlirajus[4] +
                          crapdir.vlirajus[5]  + crapdir.vlirajus[6] +
                          crapdir.vlirajus[7]  + crapdir.vlirajus[8] +
                          crapdir.vlirajus[9]  + crapdir.vlirajus[10] +
                          crapdir.vlirajus[11] + crapdir.vlirajus[12]

           aux_vldjuros = ROUND(crapdir.qtjaicmf * aux_vlmoefix,2)
           aux_vlcpmfpg = IF par_cdcooper = 6 THEN 0 ELSE crapdir.vlcpmfpg.

    IF  aux_vlrendim <= 0  THEN
        ASSIGN aux_vlrendim = 0
               aux_vldoirrf = 0.
           
    /** Desconsidera o valor da distribuicao de sobras **/
    FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                           craplct.nrdconta = par_nrdconta AND
                           craplct.cdhistor = 421          NO-LOCK:
                                
        aux_vldjuros = aux_vldjuros - ROUND(craplct.qtlanmfx * aux_vlmoefix,2).
             
    END.
         
    IF  aux_vldjuros < 0  THEN
        aux_vldjuros = 0.

    FIND FIRST crapdir WHERE crapdir.cdcooper  = par_cdcooper AND
                             crapdir.nrdconta  = par_nrdconta AND
                        YEAR(crapdir.dtmvtolt) = par_anorefer - 1 
                             USE-INDEX crapdir1 NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapdir  THEN
        ASSIGN ant_dtrefere = DATE(12,31,par_anorefer - 1)
               ant_vlsdapli = 0
               ant_vlsdccdp = 0
               ant_vlsddvem = 0
               ant_vlttccap = 0
               ant_vlirfcot = 0
               ant_vlprepag = 0.
    ELSE
        ASSIGN ant_dtrefere = DATE(12,31,YEAR(crapdir.dtmvtolt))
               ant_vlsdapli = crapdir.vlsdapli + crapdir.vlsdrdpp
               ant_vlsdccdp = crapdir.vlsdccdp
               ant_vlsddvem = crapdir.vlsddvem
               ant_vlttccap = crapdir.vlttccap
               ant_vlirfcot = crapdir.vlirfcot
               ant_vlprepag = crapdir.vlprepag.

    FIND FIRST crapsli WHERE crapsli.cdcooper = par_cdcooper AND
                             crapsli.nrdconta = par_nrdconta AND
                             crapsli.dtrefere = DATE(12,31,par_anorefer - 1) 
                             NO-LOCK NO-ERROR.

    IF  AVAILABLE crapsli  THEN
        ASSIGN ant_vlsdccdp = ant_vlsdccdp + crapsli.vlsddisp.
         
    CREATE xml_operacao.       
    ASSIGN xml_operacao.dslinxml = "<IRFISICA><anorefer>" +
                                   STRING(par_anorefer,"9999") +
                                   "</anorefer><inpessoa>" +
                                   STRING(crapass.inpessoa) +
                                   "</inpessoa><nrdocnpj>" +
                                   STRING(STRING(crapcop.nrdocnpj,
                                     "99999999999999"),"xx.xxx.xxx/xxxx-xx") +
                                   "</nrdocnpj><dsendcop>" + 
                                   crapcop.dsendcop + ", " +
                                   TRIM(STRING(crapcop.nrendcop,"zz,zz9")) + 
                                   " - " + crapcop.nmbairro + " - " +
                                   STRING(STRING(crapcop.nrcepend,
                                          "99999999"),"xxxxx-xxx") +
                                   " - " + crapcop.nmcidade + " - " +
                                   crapcop.cdufdcop + " - TELEFONE: " +
                                   crapcop.nrtelvoz + 
                                   "</dsendcop><nmextcop>" + 
                                   TRIM(crapcop.nmextcop) + 
                                   "</nmextcop><cdagenci>" + 
                                   TRIM(STRING(crapass.cdagenci,"zz9")) +
                                   "</cdagenci><nmsegntl>" + 
                                   TRIM(aux_nmsegntl) + 
                                   "</nmsegntl><nmprimtl>" + 
                                   TRIM(crapass.nmprimtl) + 
                                   "</nmprimtl><nrcpfcgc>" +
                                   STRING(STRING(crapass.nrcpfcgc,
                                          "99999999999"),"xxx.xxx.xxx-xx") + 
                                   "</nrcpfcgc><dtrefant>" + 
                                   TRIM(STRING(ant_dtrefere,"99/99/9999")) + 
                            /*10*/ "</dtrefant><vlaplant>" +
                                   TRIM(STRING(ant_vlsdapli,
                                               "zzz,zzz,zz9.99-")) +
                                   "</vlaplant><vlccdant>" +
                                   TRIM(STRING(ant_vlsdccdp,
                                               "zzz,zzz,zz9.99-")) +
                                   "</vlccdant><vlsddvem>" +
                                   TRIM(STRING(ant_vlsddvem,
                                               "zzz,zzz,zz9.99-")) +
                                   "</vlsddvem><vlccpant>" +
                                   TRIM(STRING(ant_vlttccap,
                                               "zzz,zzz,zz9.99-")) +
                                   "</vlccpant><dtrefsol>" + 
                                   TRIM(STRING(aux_dtrefere,"99/99/9999")) + 
                                   "</dtrefsol><vlaplsol>" +
                                   TRIM(STRING(aux_vlsdapli,
                                               "zzz,zzz,zz9.99-")) +
                                   "</vlaplsol><vlccdsol>" +
                                   TRIM(STRING(aux_vlsdccdp,
                                               "zzz,zzz,zz9.99-")) +
                                   "</vlccdsol><vldvesol>" +
                                   TRIM(STRING(aux_vlsddvem,
                                               "zzz,zzz,zz9.99-")) +
                                   "</vldvesol><vlccpsol>" +
                                   TRIM(STRING(aux_vlttccap,
                                               "zzz,zzz,zz9.99-")) +
                                   "</vlccpsol><vlrendim>" +
                                   TRIM(STRING(aux_vlrendim,
                                               "zzz,zzz,zz9.99-")) +
                            /*20*/ "</vlrendim><vlcpmfpg>" +
                                   TRIM(STRING(aux_vlcpmfpg,
                                               "zzz,zzz,zz9.99-")) +
                                   "</vlcpmfpg><vldjuros>" +
                                   TRIM(STRING(aux_vldjuros,
                                               "zzz,zzz,zz9.99-")) +
                                   "</vldjuros><vldoirrf>" +
                                   TRIM(STRING(aux_vldoirrf,
                                               "zzz,zzz,zz9.99-")) +
                                   "</vldoirrf><cdagebcb>" +
                                   TRIM(STRING(crapcop.cdagebcb,"zzz,zzz,zz9")) +
                                   "</cdagebcb><cdagectl>" +
                                   TRIM(STRING(crapcop.cdagectl,"9999")) + 
                                   "</cdagectl><vlrencot>" +
                                   TRIM(STRING(aux_vlrencot,"zzz,zzz,zz9.99-")) +
                                   "</vlrencot><vlirfcot>" +
                                   TRIM(STRING(aux_vlirfcot,"zzz,zzz,zz9.99-")) +
                                   "</vlirfcot><atirfcot>" +
                                   TRIM(STRING(ant_vlirfcot,"zzz,zzz,zz9.99-")) +
                                   "</atirfcot><vlsobras>" +
                                   TRIM(STRING(aux_vlsobras,"zzz,zzz,zz9.99-")) +
                                   "</vlsobras><vlprepag>" +
                                   TRIM(STRING(aux_vlprepag,"zzz,zzz,zz9.99-")) +
                                   "</vlprepag><atprepag>" +
                                   TRIM(STRING(ant_vlprepag,"zzz,zzz,zz9.99-")) +
                                   "</atprepag></IRFISICA>".          
END PROCEDURE. 

PROCEDURE proc_ir_juridica:
       
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<IRJURIDICA><anorefer>" +
                                   STRING(par_anorefer,"9999") +
                                   "</anorefer><inpessoa>" +
                                   STRING(crapass.inpessoa) +
                                   "</inpessoa><nrdocnpj>" +
                                   STRING(STRING(crapcop.nrdocnpj,
                                          "99999999999999"),
                                          "xx.xxx.xxx/xxxx-xx") +
                                   "</nrdocnpj><dsendcop>" + 
                                   crapcop.dsendcop + ", " +
                                   TRIM(STRING(crapcop.nrendcop,"zz,zz9")) + 
                                   " - " + crapcop.nmbairro + " - " +
                                   STRING(STRING(crapcop.nrcepend,
                                          "99999999"),"xxxxx-xxx") + " - " + 
                                   crapcop.nmcidade + " - " + 
                                   crapcop.cdufdcop + " - TELEFONE: " +
                                   crapcop.nrtelvoz + 
                                   "</dsendcop><nmextcop>" + 
                                   TRIM(crapcop.nmextcop) + 
                                   "</nmextcop><cdagenci>" + 
                                   TRIM(STRING(crapass.cdagenci,"zz9")) +
                                   "</cdagenci><nmsegntl>" + 
                                   TRIM(aux_nmsegntl) + 
                                   "</nmsegntl><nmprimtl>" + 
                                   TRIM(crapass.nmprimtl) + 
                                   "</nmprimtl><nrcpfcgc>" +
                                   STRING(STRING(crapass.nrcpfcgc,
                                         "99999999999999"),
                                         "xx.xxx.xxx/xxxx-xx") + 
                                   "</nrcpfcgc><DADOSIR>".
                     
    /* pegar descricao do codigo retencao 3426 */
    FIND FIRST gnrdirf WHERE gnrdirf.cdretenc = 3426 NO-ERROR.
    IF  NOT AVAILABLE gnrdirf THEN
        DO:
           ASSIGN aux_dscritic = "Problema na consulta da descricao " +
                                 "de retencao. Comunique seu PA.".
           RETURN "NOK".
        END.
    ASSIGN aux_dsre3426 = gnrdirf.dsretenc.

    /* pegar descricao do codigo retencao 5706 */
    FIND FIRST gnrdirf WHERE gnrdirf.cdretenc = 5706 NO-ERROR.
    IF  NOT AVAILABLE gnrdirf THEN
        DO:
            ASSIGN aux_dscritic = "Problema na consulta da descricao " +
                                 "de retencao. Comunique seu PA.".
            RETURN "NOK".
        END.
    ASSIGN aux_dsre5706 = gnrdirf.dsretenc.
    
    /* pegar descricao do codigo retencao 3277 */
    FIND FIRST gnrdirf WHERE gnrdirf.cdretenc = 3277 NO-ERROR.
    IF  NOT AVAILABLE gnrdirf THEN DO:
        ASSIGN aux_dscritic = "Problema na consulta da descricao " +
                              "de retencao. Comunique seu PA.".
        RETURN "NOK".
    END.
    ASSIGN aux_dsre3277 = gnrdirf.dsretenc.

    
    ASSIGN aux_dtrefere = DATE(12,31,par_anorefer).

    /* se for ano vigente */
    IF  par_anorefer = YEAR(par_dtmvtolt)  THEN
        DO:

			ASSIGN aux_cdacesso = "IRENDA" + STRING(par_anorefer,"9999").

			FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
							   craptab.nmsistem = "CRED"       AND
							   craptab.tptabela = "GENERI"     AND
							   craptab.cdempres = 0            AND
							   craptab.cdacesso = aux_cdacesso AND
							   craptab.tpregist = 1            NO-LOCK NO-ERROR.

            ASSIGN aux_nrmesref = MONTH(par_dtmvtolt - DAY(par_dtmvtolt)).
            FIND crapcot WHERE crapcot.cdcooper = par_cdcooper AND
                               crapcot.nrdconta = par_nrdconta 
                               NO-LOCK NO-ERROR.
 
            IF  NOT AVAILABLE crapcot or NOT AVAILABLE craptab THEN
                DO:
                    aux_dscritic = "Nao ha dados para imposto de renda " +
                                   "referente ao ano de " + 
                                   STRING(par_anorefer,"9999") + ".".
                    RETURN "NOK".
                END.
 
            DO aux_contador = 1 TO aux_nrmesref: 
                          
               ASSIGN aux_nomedmes = aux_nmmesref[aux_contador]
                      aux_cdretenc = 3426
                      aux_dsretenc = aux_dsre3426
                      aux_vlrentot = crapcot.vlrentot[aux_contador]
                      aux_vlirfont = (crapcot.vlirrdca[aux_contador] +
                                      crapcot.vlrirrpp[aux_contador] +
                                      crapcot.vlirabap[aux_contador] +
                                      crapcot.vlirajus[aux_contador] +
                                      crapcot.vlirfrdc[aux_contador]).

               /* listar apenas registros que IRRF seja maior q 0 */
               IF aux_vlirfont > 0 THEN
                  DO:
                     IF par_anorefer < 2004 THEN
                        ASSIGN aux_vlirfont = 0.
                     
                     ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml     +
                            "<vlrenmes><nmmesref>"                            +
                            aux_nomedmes                                      +
                            "</nmmesref><cdretenc>"                           +
                            STRING(aux_cdretenc)                              +
                            "</cdretenc><dsretenc>"                           +
                            aux_dsretenc                                      +
                            "</dsretenc><vlrentot>"                           +
                            TRIM(STRING(aux_vlrentot,"zzz,zzz,zz9.99-"))      +
                            "</vlrentot><vlirfont>"                           +
                            TRIM(STRING(aux_vlirfont,"zzz,zzz,zz9.99-"))      +
                            "</vlirfont></vlrenmes>".

                  END.

               ASSIGN aux_vlirfont = 0.

               FOR EACH craplct WHERE
                        craplct.cdcooper = par_cdcooper             AND
                        craplct.nrdconta = crapass.nrdconta         AND
                        YEAR(craplct.dtmvtolt)  = par_anorefer      AND
                        MONTH(craplct.dtmvtolt) = aux_contador      AND
                        CAN-DO("0922,0926",STRING(craplct.cdhistor,"9999"))
                        NO-LOCK:

                   IF  craplct.cdhistor = 926 THEN
                       ASSIGN aux_vlrentot = craplct.vllanmto.
                   ELSE
                       ASSIGN aux_vlirfont = craplct.vllanmto.

               END. /* FOR EACH */


               IF  aux_vlirfont > 0 THEN DO:
                   /* Passou a tratar 3277 ao inves de 5706 */
                   ASSIGN aux_cdretenc = 3277
                          aux_dsretenc = aux_dsre3277.

                   IF  par_anorefer < 2004 THEN
                         ASSIGN aux_vlirfont = 0.
                     
                      ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml     +
                            "<vlrenmes><nmmesref>"                            +
                            aux_nomedmes                                      +
                            "</nmmesref><cdretenc>"                           +
                            STRING(aux_cdretenc)                              +
                            "</cdretenc><dsretenc>"                           +
                            aux_dsretenc                                      +
                            "</dsretenc><vlrentot>"                           +
                            TRIM(STRING(aux_vlrentot,"zzz,zzz,zz9.99-"))      +
                            "</vlrentot><vlirfont>"                           +
                            TRIM(STRING(aux_vlirfont,"zzz,zzz,zz9.99-"))      +
                            "</vlirfont></vlrenmes>".
                   END.
            END. /* do to */
        END. /* se for ano vigente */
    ELSE
        DO:  /* senao for ano vigente */
            
            ASSIGN aux_nrmesref = 12.

            FIND FIRST crapdir WHERE
                       crapdir.cdcooper = par_cdcooper AND
                       crapdir.nrdconta = crapass.nrdconta  AND
                       YEAR(crapdir.dtmvtolt) = par_anorefer
                       USE-INDEX crapdir1 NO-LOCK NO-ERROR.

			ASSIGN aux_cdacesso = "IRENDA" + STRING(par_anorefer,"9999").
			
			FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
							   craptab.nmsistem = "CRED"       AND
							   craptab.tptabela = "GENERI"     AND
							   craptab.cdempres = 0            AND
							   craptab.cdacesso = aux_cdacesso AND
							   craptab.tpregist = 1            NO-LOCK NO-ERROR.

            IF NOT AVAILABLE crapdir or NOT AVAILABLE craptab THEN
               DO:
                   ASSIGN aux_dscritic = "Conta/dv: " + STRING(par_nrdconta) +
                                         " - Nao ha dados para imposto de " +
                                         "renda de " + STRING(par_anorefer).
                   RETURN "NOK".   
                
               END.

            DO  aux_contador = 1 TO aux_nrmesref:

                ASSIGN aux_nomedmes = aux_nmmesref[aux_contador]
                       aux_cdretenc = 3426
                       aux_dsretenc = aux_dsre3426
                       aux_vlrentot = crapdir.vlrentot[aux_contador]
                       aux_vlirfont = crapdir.vlirrdca[aux_contador] +
                                      crapdir.vlrirrpp[aux_contador] +
                                      crapdir.vlirabap[aux_contador] +
                                      crapdir.vlirajus[aux_contador] +
                                      crapdir.vlirfrdc[aux_contador].
                

                IF  aux_vlirfont > 0 THEN DO:

                        IF par_anorefer < 2004 THEN
                           ASSIGN aux_vlirfont = 0.
                        
                        ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml  +
                            "<vlrenmes><nmmesref>"                            +
                            aux_nomedmes                                      +
                            "</nmmesref><cdretenc>"                           +
                            STRING(aux_cdretenc)                              +
                            "</cdretenc><dsretenc>"                           +
                            aux_dsretenc                                      +
                            "</dsretenc><vlrentot>"                           +
                            TRIM(STRING(aux_vlrentot,"zzz,zzz,zz9.99-"))      +
                            "</vlrentot><vlirfont>"                           +
                            TRIM(STRING(aux_vlirfont,"zzz,zzz,zz9.99-"))      +
                            "</vlirfont></vlrenmes>".
                    
                    END.

                ASSIGN aux_vlirfont = 0.

                FOR EACH craplct
                   WHERE craplct.cdcooper        = par_cdcooper
                     AND craplct.nrdconta        = crapass.nrdconta
                     AND YEAR(craplct.dtmvtolt)  = par_anorefer
                     AND MONTH(craplct.dtmvtolt) = aux_contador
                     AND CAN-DO("0922,0926",STRING(craplct.cdhistor,"9999"))
                         NO-LOCK:

                    IF  craplct.cdhistor = 926 THEN
                        ASSIGN aux_vlrentot = craplct.vllanmto.
                    ELSE
                        ASSIGN aux_vlirfont = craplct.vllanmto.

                END. /* FOR EACH */

                IF  aux_vlirfont > 0 THEN DO:

                    IF  par_anorefer >= 2016 THEN DO:
                        /* Ano em que deixou deixou de considerar 5706
                            => Usado agora 3277 */
                        ASSIGN aux_cdretenc = 3277
                               aux_dsretenc = aux_dsre3277.

                        IF  par_anorefer < 2004 THEN
                            ASSIGN aux_vlirfont = 0.

                    END.
                    ELSE DO:
                      ASSIGN aux_cdretenc = 5706
                             aux_dsretenc = aux_dsre5706.
                      
                        IF  par_anorefer < 2004 THEN
                           ASSIGN aux_vlirfont = 0.

                    END. /* FIM DO par_anorefer >= 2016 */

                    ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml  +
                            "<vlrenmes><nmmesref>"                            +
                            aux_nomedmes                                      +
                            "</nmmesref><cdretenc>"                           +
                            STRING(aux_cdretenc)                              +
                            "</cdretenc><dsretenc>"                           +
                            aux_dsretenc                                      +
                            "</dsretenc><vlrentot>"                           +
                            TRIM(STRING(aux_vlrentot,"zzz,zzz,zz9.99-"))      +
                            "</vlrentot><vlirfont>"                           +
                            TRIM(STRING(aux_vlirfont,"zzz,zzz,zz9.99-"))      +
                            "</vlirfont></vlrenmes>".
                   END.
            END. /* DO TO */
            
            /* Rendimentos Liquidos - Aplicacoes de Renda Fixa*/
            ASSIGN rel_vlrendim = crapdir.vlrenrda[01] + crapdir.vlrenrda[02] +
                                  crapdir.vlrenrda[03] + crapdir.vlrenrda[04] +
                                  crapdir.vlrenrda[05] + crapdir.vlrenrda[06] +
                                  crapdir.vlrenrda[07] + crapdir.vlrenrda[08] +
                                  crapdir.vlrenrda[09] + crapdir.vlrenrda[10] +
                                  crapdir.vlrenrda[11] + crapdir.vlrenrda[12] +
                              
                                  crapdir.vlrenrdc[01] + crapdir.vlrenrdc[02] +
                                  crapdir.vlrenrdc[03] + crapdir.vlrenrdc[04] +
                                  crapdir.vlrenrdc[05] + crapdir.vlrenrdc[06] +
                                  crapdir.vlrenrdc[07] + crapdir.vlrenrdc[08] +
                                  crapdir.vlrenrdc[09] + crapdir.vlrenrdc[10] +
                                  crapdir.vlrenrdc[11] + crapdir.vlrenrdc[12] +
                                   
                                  crapdir.vlrenrpp + crapdir.vlabonpp + crapdir.vlabonrd +
                                  crapdir.vlabiopp + crapdir.vlabiord - 
                                   
                                  crapdir.vlirabap[1]  - crapdir.vlirabap[2] -
                                  crapdir.vlirabap[3]  - crapdir.vlirabap[4] -
                                  crapdir.vlirabap[5]  - crapdir.vlirabap[6] -
                                  crapdir.vlirabap[7]  - crapdir.vlirabap[8] -
                                  crapdir.vlirabap[9]  - crapdir.vlirabap[10] -
                                  crapdir.vlirabap[11] - crapdir.vlirabap[12] -
                                   
                                  crapdir.vlirrdca[1]  - crapdir.vlirrdca[2] -
                                  crapdir.vlirrdca[3]  - crapdir.vlirrdca[4] -
                                  crapdir.vlirrdca[5]  - crapdir.vlirrdca[6] -
                                  crapdir.vlirrdca[7]  - crapdir.vlirrdca[8] -
                                  crapdir.vlirrdca[9]  - crapdir.vlirrdca[10] -
                                  crapdir.vlirrdca[11] - crapdir.vlirrdca[12] -
                                   
                                  crapdir.vlirfrdc[01] - crapdir.vlirfrdc[02] -
                                  crapdir.vlirfrdc[03] - crapdir.vlirfrdc[04] -
                                  crapdir.vlirfrdc[05] - crapdir.vlirfrdc[06] -
                                  crapdir.vlirfrdc[07] - crapdir.vlirfrdc[08] -
                                  crapdir.vlirfrdc[09] - crapdir.vlirfrdc[10] -
                                  crapdir.vlirfrdc[11] - crapdir.vlirfrdc[12] -
                                   
                                  crapdir.vlrirrpp[1]  - crapdir.vlrirrpp[2] -
                                  crapdir.vlrirrpp[3]  - crapdir.vlrirrpp[4] -
                                  crapdir.vlrirrpp[5]  - crapdir.vlrirrpp[6] -
                                  crapdir.vlrirrpp[7]  - crapdir.vlrirrpp[8] -
                                  crapdir.vlrirrpp[9]  - crapdir.vlrirrpp[10] -
                                  crapdir.vlrirrpp[11] - crapdir.vlrirrpp[12] -
                            
                                  crapdir.vlirajus[1]  - crapdir.vlirajus[2] -
                                  crapdir.vlirajus[3]  - crapdir.vlirajus[4] -
                                  crapdir.vlirajus[5]  - crapdir.vlirajus[6] -
                                  crapdir.vlirajus[7]  - crapdir.vlirajus[8] -
                                  crapdir.vlirajus[9]  - crapdir.vlirajus[10] -
                                  crapdir.vlirajus[11] - crapdir.vlirajus[12].

            ASSIGN aux_dtrefere = DATE(12,31,YEAR(crapdir.dtmvtolt))
                   aux_vlsdccdp = crapdir.vlsdccdp
                   aux_vlsddvem = crapdir.vlsddvem
                   aux_vlttccap = crapdir.vlttccap
                   aux_cdacesso = "IRENDA" +
                                   STRING(YEAR(crapdir.dtmvtolt),"9999")
                   aux_vlrencot = (crapdir.vlrencot - crapdir.vlirfcot)
                   aux_vlirfcot = crapdir.vlirfcot
                   sol_vlsdapli = crapdir.vlsdapli + crapdir.vlsdrdpp.

            FIND FIRST crapsli WHERE
                       crapsli.cdcooper = par_cdcooper     AND
                       crapsli.nrdconta = crapass.nrdconta AND
                       crapsli.dtrefere = DATE(12,31,par_anorefer)
                       NO-LOCK NO-ERROR.

            IF   AVAILABLE crapsli THEN
                 ASSIGN aux_vlsdccdp = aux_vlsdccdp + crapsli.vlsddisp.
                  
        END. /* fim else nao vigente */
    
    ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml +
           "</DADOSIR><INFOCOMP>".

    ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml +
           "<vlrencot>"                                  + 
           TRIM(STRING(aux_vlrencot,"zzz,zzz,zz9.99-"))  + 
           "</vlrencot>".

    ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml +
           "<icompsol><dtrefsol>"                        + 
           TRIM(STRING(aux_dtrefere,"99/99/9999"))       + 
           "</dtrefsol><vlccdsol>"                       +
           TRIM(STRING(aux_vlsdccdp,"zzz,zzz,zz9.99-"))  +
           "</vlccdsol><vldvesol>"                       +
           TRIM(STRING(aux_vlsddvem,"zzz,zzz,zz9.99-"))  +
           "</vldvesol><vlccpsol>"                       +
           TRIM(STRING(aux_vlttccap,"zzz,zzz,zz9.99-"))  +
           "</vlccpsol><vlsdapli>"                       +
           TRIM(STRING(sol_vlsdapli,"z,zzz,zzz,zz9.99-")) +
           "</vlsdapli></icompsol>".
    
    FIND FIRST crapdir WHERE
               crapdir.cdcooper = par_cdcooper      AND
               crapdir.nrdconta = crapass.nrdconta  AND
               YEAR(crapdir.dtmvtolt) = (par_anorefer - 1)
               USE-INDEX crapdir1 NO-LOCK NO-ERROR.

    IF  AVAIL crapdir THEN
        ASSIGN ant_dtrefere = DATE(12,31,YEAR(crapdir.dtmvtolt))
               ant_vlsdccdp = crapdir.vlsdccdp
               ant_vlsddvem = crapdir.vlsddvem
               ant_vlttccap = crapdir.vlttccap
               ant_vlsdapli = crapdir.vlsdapli + crapdir.vlsdrdpp.
    ELSE
        ASSIGN ant_dtrefere = DATE(12,31,(par_anorefer - 1)).
    
    FIND FIRST crapsli WHERE
               crapsli.cdcooper = par_cdcooper     AND
               crapsli.nrdconta = crapass.nrdconta AND
               crapsli.dtrefere = DATE(12,31,(par_anorefer - 1))
               NO-LOCK NO-ERROR.

    IF   AVAILABLE crapsli THEN
         ASSIGN ant_vlsdccdp = ant_vlsdccdp + crapsli.vlsddisp.
    
    ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml +
           "<icompant>"                                  +
           "<dtrefant>"                                  + 
           TRIM(STRING(ant_dtrefere,"99/99/9999"))       + 
           "</dtrefant><vlccdant>"                       +
           TRIM(STRING(ant_vlsdccdp,"zzz,zzz,zz9.99-"))  +
           "</vlccdant><vldveant>"                       +
           TRIM(STRING(ant_vlsddvem,"zzz,zzz,zz9.99-"))  +
           "</vldveant><vlccpant>"                       +
           TRIM(STRING(ant_vlttccap,"zzz,zzz,zz9.99-"))  +
           "</vlccpant><vlsdapli>"                       +
           TRIM(STRING(ant_vlsdapli,"z,zzz,zzz,zz9.99-")) +
           "</vlsdapli>"                                 +
           "</icompant>".

    ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml +
           "<vlsobras>"                                  +
           TRIM(STRING(aux_vlsobras,"zzz,zzz,zz9.99-"))  +
           "</vlsobras>"                                 +
           "<vlrendim>"                                  +
           TRIM(STRING(rel_vlrendim,"zzz,zzz,zz9.99-"))  +
           "</vlrendim>".

    ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml +
                                   "</INFOCOMP></IRJURIDICA>".
    
    RETURN "OK".
    
END PROCEDURE. 

PROCEDURE proc_ir_juridica_trimestral:

    DEF VAR aux_mesinici AS INTE                                    NO-UNDO.
    DEF VAR aux_xmlopera AS CHAR                                    NO-UNDO.


    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_gera_impextir_pj_trim_car
       aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,   /* Código da Cooperativa */
                                            INPUT 90,             /* Codigo da Agencia */
                                            INPUT 900,            /* Numero do Caixa */
                                            INPUT 3,              /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                            INPUT "InternetBank", /* Nome da Tela */
                                            INPUT par_dtmvtolt,   /* Data de Movimento */
                                            INPUT 1,              /* Inproces */
                                            INPUT "InternetBank", /* Codigo do Programa */
                                            INPUT "1",            /* Código do Operador */
                                            INPUT STRING(etime),  /* pr_dsiduser */
                                            INPUT par_nrdconta,   /* Número da Conta */
                                            INPUT par_anorefer,   /* Ano de Referencia */
                                            INPUT 6,              /* Tipo de Extrato 6-PJ */
                                            INPUT par_nrperiod,   /* Trimestre de Referencia */
                                            INPUT 0,              /* flgrodar - Flag Executar */
                                            INPUT 1,              /* flgerlog - Escreve erro Log */
                                           OUTPUT "",             /* XML em TEXTO - pr_dstexto */
                                           OUTPUT "",             /* MSG ERRO pr_dsmsgerr */
                                           OUTPUT "",             /* pr_nmarqimp */
                                           OUTPUT "",             /* pr_nmarqpdf */
                                           OUTPUT "").            /* Descrição Erro pr_des_reto */

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_gera_impextir_pj_trim_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    /* Busca possíveis erros */ 
    ASSIGN aux_dscritic = ""
           aux_xmlopera = pc_gera_impextir_pj_trim_car.pr_dstexto 
                          WHEN pc_gera_impextir_pj_trim_car.pr_dstexto <> ?
           aux_dscritic = pc_gera_impextir_pj_trim_car.pr_dsmsgerr 
                          WHEN pc_gera_impextir_pj_trim_car.pr_dsmsgerr <> ? .

    IF aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".   
      
        RUN proc_geracao_log (INPUT FALSE).  
    
        RETURN "NOK".
        
    END.    

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<root>" + aux_xmlopera + "</root>".
    
END PROCEDURE. /*proc_ir_juridica_trimestral*/


PROCEDURE proc_geracao_log:

    DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
        SET h-b1wgen0014.
        
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                          INPUT "996",
                                          INPUT aux_dscritic,
                                          INPUT "INTERNET",
                                          INPUT aux_dstransa,
                                          INPUT TODAY,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT "INTERNETBANK",
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).
                                                            
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE. 

/*............................................................................*/
