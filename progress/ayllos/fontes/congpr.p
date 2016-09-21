/* ..........................................................................

   Programa: Fontes/congpr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Paulo - Precise
   Data    : Julho/2009.                       Ultima atualizacao: 10/09/2013

   Dados referentes ao programa:

   Frequencia: Diario consulta em tela.
   Objetivo  : consultar produtos/negócios Viacred.

   Alteracoes: 23/09/2009 - Precise - Paulo - criados campos novos de
                            beneficios, seguros, e cartoes
                            
               12/04/2010 - Incluido campos da participacao dos cooperados no
                            arquivo gerado (Elton). 
                                        
               11/05/2010 - Incluido campo de aplicacao dos cooperados
                            crapgpr.qtassrda e percentuais das participacoes
                            (Irlan)
               
               19/05/2010 - Incluido novos campos de logs de acesso
                            (Internet e Cx Eletr.) (qtasunet e qtasucxa)
                            (Irlan)
               
               02/06/2010 - Incluido o campo "Cooperados" em Participacao.
                            (Irlan)
                            
               17/06/2010 - Incluido novos campos(Desc. Cheques, Desc. Ti_
                            tulos, Pagamentos TAA.) (Irlan)
               
               15/07/2010 - Alterado a forma de consulta dos campos qtassoci
                            e qtasscot. Busca informação quando inpessoa = 0.
                            (Irlan)
               
               19/08/2010 - Incluido os campos de Depositos no TAA 
                            qtdepcxa e vldepcxa (Irlan).                
                            
               31/08/2010 - Considerar Transações Cartao Multiplo = 
                            Pagamentos com Cartao + Transferencias c/cartao.
                            Incluido novo campo em Participações: qtchcomp 
                            Quantidade de Cheques Compensados (Irlan). 
                            
               01/09/2010 - Incluido informações de Caixa On-line 
                            qttiponl e qtchconl (Irlan).
                            
               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop
                            na leitura e gravacao dos arquivos (Elton).
                            
               22/06/2011 - Alterado format dos campos Saldo C, Saldo D, para
                            aceitar valores negativos (Adriano).
                            
               13/09/2011 - Alterado header da Cobranca e Incluido informacoes 
                            para Cobranca Registrada, DDA (Adriano).
                            
               04/05/2012 - Criado item de pesquisa "demonstrativo produtos
                            por colaborador". (Fabricio)
                            
               15/05/2012 - Definido extensao para o nome do arquivo 
                            (tel_nmarquiv) em ".txt". Adicionado mensagem de
                            arquivo sendo gerado e arquivo gerado com sucesso
                            para o item "demonstrativo produtos por 
                            colaborador". (Fabricio)
                            
               04/06/2012 - Desconsiderar operador "1 - SUPER USUARIO" na 
                            consulta (Lucas).
                            
               13/06/2012 - Implementado melhorias referente a cartoes 
                            magneticos, (David Kruger).
                            
               14/08/2012 - Inclusão de campos na geração do arquivo excel,
                            ted_pf, valorted_pf, ted_pj, valorted_pj.(Lucas R.)
                            
               19/03/2013 - Incluir valores de transferencia (Gabriel). 
               
               10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).                                        
 ..........................................................................*/

{includes/var_online.i}

DEF STREAM str_1. 

DEF  VAR aux_nrcheque    AS DECIMAL                                   NO-UNDO.
DEF  VAR aux_qtassoci    AS DECIMAL                                   NO-UNDO.
DEF  VAR aux_datini      AS DATE                                      NO-UNDO.
DEF  VAR aux_datfim      AS DATE                                      NO-UNDO.
DEF  VAR aux_linha       AS CHAR                                      NO-UNDO.
DEF  VAR aux_header      AS CHAR                                      NO-UNDO.
DEF  VAR aux_pri         AS INTEGER                                   NO-UNDO.
DEF  VAR aux_nomearq     AS CHAR                                      NO-UNDO.
DEF  VAR aux_qtdatibb    AS INTEGER                                   NO-UNDO.
DEF  VAR aux_vllimcbb    AS DEC                                       NO-UNDO.
DEF  VAR aux_vllimdbb    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtdsaqbb    AS INTEGER                                   NO-UNDO.
DEF  VAR aux_vlrsaqbb    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtdtrsbb    AS INTEGER                                   NO-UNDO.
DEF  VAR aux_vlrtrsbb    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtddebbb    AS INTEGER                                   NO-UNDO.
DEF  VAR aux_vlrdebbb    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtdcrebb    AS INTEGER                                   NO-UNDO.
DEF  VAR aux_vlrcrebb    AS DEC                                       NO-UNDO.
DEF  VAR aux_qttransacoes AS INTEGER                                  NO-UNDO.
DEF  VAR aux_vltransacoes AS DEC                                      NO-UNDO.
DEF  VAR aux_qtdaticv    AS INT                                       NO-UNDO.
DEF  VAR aux_vllimccv    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtdsaqcv    AS INT                                       NO-UNDO.
DEF  VAR aux_vlrsaqcv    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtdcrecv    AS INT                                       NO-UNDO.
DEF  VAR aux_vlrcrecv    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtdanucv    AS INT                                       NO-UNDO.
DEF  VAR aux_vlranucv    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtasqtbb    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtasstbb    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtassqbb    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtassqcv    AS INT                                       NO-UNDO.
DEF  VAR aux_qtasscxa_pf AS INT                                       NO-UNDO.
DEF  VAR aux_qtsaqcxa_pf AS INT                                       NO-UNDO.
DEF  VAR aux_vlsaqcxa_pf AS DEC                                       NO-UNDO.
DEF  VAR aux_qttrscxa_pf AS INT                                       NO-UNDO.
DEF  VAR aux_vltrscxa_pf AS DEC                                       NO-UNDO.
DEF  VAR aux_qtpagcxa_pf AS INT                                       NO-UNDO.
DEF  VAR aux_vlpagcxa_pf AS DEC                                       NO-UNDO.
DEF  VAR aux_qtdepcxa_pf AS INT                                       NO-UNDO.
DEF  VAR aux_vldepcxa_pf AS DEC                                       NO-UNDO.
DEF  VAR aux_qtasscxa_pj AS INT                                       NO-UNDO.
DEF  VAR aux_qtsaqcxa_pj AS INT                                       NO-UNDO.
DEF  VAR aux_vlsaqcxa_pj AS DEC                                       NO-UNDO.
DEF  VAR aux_qttrscxa_pj AS INT                                       NO-UNDO.
DEF  VAR aux_vltrscxa_pj AS DEC                                       NO-UNDO.
DEF  VAR aux_qtpagcxa_pj AS INT                                       NO-UNDO.
DEF  VAR aux_vlpagcxa_pj AS DEC                                       NO-UNDO.
DEF  VAR aux_qtdepcxa_pj AS INT                                       NO-UNDO.
DEF  VAR aux_vldepcxa_pj AS DEC                                       NO-UNDO.

DEF  VAR aux_qtasscob_pf AS INT                                       NO-UNDO.
DEF  VAR aux_qtdcobbb_pf AS INT                                       NO-UNDO.
DEF  VAR aux_vlrcobbb_pf AS DEC                                       NO-UNDO.
DEF  VAR aux_qtcobonl_pf AS INT                                       NO-UNDO.
DEF  VAR aux_vlcobonl_pf AS DEC                                       NO-UNDO.
DEF  VAR aux_qttrfcob_pf AS INT                                       NO-UNDO.
DEF  VAR aux_vltrfcob_pf AS DEC                                       NO-UNDO.

DEF  VAR aux_qtasscob_pj AS INT                                       NO-UNDO.
DEF  VAR aux_qtdcobbb_pj AS INT                                       NO-UNDO.
DEF  VAR aux_vlrcobbb_pj AS DEC                                       NO-UNDO.
DEF  VAR aux_qtcobonl_pj AS INT                                       NO-UNDO.
DEF  VAR aux_vlcobonl_pj AS DEC                                       NO-UNDO.
DEF  VAR aux_qttrfcob_pj AS INT                                       NO-UNDO.
DEF  VAR aux_vltrfcob_pj AS DEC                                       NO-UNDO. 

DEF  VAR aux_qtassnet_pf AS INT                                       NO-UNDO.
DEF  VAR aux_qtextnet_pf AS INT                                       NO-UNDO.
DEF  VAR aux_qtbltnet_pf AS INT                                       NO-UNDO.
DEF  VAR aux_vlbltnet_pf AS DEC                                       NO-UNDO.
DEF  VAR aux_qtpagnet_pf AS INT                                       NO-UNDO.
DEF  VAR aux_vlpagnet_pf AS DEC                                       NO-UNDO.
DEF  VAR aux_qttrsnet_pf AS INT                                       NO-UNDO.
DEF  VAR aux_vltrsnet_pf AS DEC                                       NO-UNDO.
DEF  VAR aux_qttednet_pf AS INT                                       NO-UNDO.
DEF  VAR aux_vltednet_pf AS DEC                                       NO-UNDO.
DEF  VAR aux_qttrinet_pf AS INTE                                      NO-UNDO.
DEF  VAR aux_vltrinet_pf AS DECI                                      NO-UNDO.

DEF  VAR aux_qtassnet_pj AS INT                                       NO-UNDO.  
DEF  VAR aux_qtextnet_pj AS INT                                       NO-UNDO.
DEF  VAR aux_qtbltnet_pj AS INT                                       NO-UNDO.
DEF  VAR aux_vlbltnet_pj AS DEC                                       NO-UNDO.
DEF  VAR aux_qtpagnet_pj AS INT                                       NO-UNDO.
DEF  VAR aux_vlpagnet_pj AS DEC                                       NO-UNDO.
DEF  VAR aux_qttrsnet_pj AS INT                                       NO-UNDO.
DEF  VAR aux_vltrsnet_pj AS DEC                                       NO-UNDO.
DEF  VAR aux_qttednet_pj AS INT                                       NO-UNDO.
DEF  VAR aux_vltednet_pj AS DEC                                       NO-UNDO.
DEF  VAR aux_qttrinet_pj AS INTE                                      NO-UNDO.
DEF  VAR aux_vltrinet_pj AS DECI                                      NO-UNDO.

DEF  VAR aux_qtassvsn    AS INT                                       NO-UNDO.
DEF  VAR aux_qtlanvsn    AS INT                                       NO-UNDO.
DEF  VAR aux_vllanvsn    AS DEC                                       NO-UNDO.

/*Variaves redecard*/
DEF  VAR aux_qtassrcd    AS INT                                       NO-UNDO.
DEF  VAR aux_qtlanrcd    AS INT                                       NO-UNDO.
DEF  VAR aux_vllanrcd    AS DEC                                       NO-UNDO.

DEF  VAR aux_qtassura    AS INT                                       NO-UNDO.
DEF  VAR aux_qtconura    AS INT                                       NO-UNDO.  

DEF  VAR aux_qtfatcnv    AS INT                                       NO-UNDO.
DEF  VAR aux_vlfatcnv    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtdebcnv    AS INT                                       NO-UNDO.
DEF  VAR aux_vldebcnv    AS DEC                                       NO-UNDO.

/* seguro auto */
DEF  VAR aux_qtsegaut    AS INT                                       NO-UNDO.
DEF  VAR aux_vllanaut    AS DEC                                       NO-UNDO.
DEF  VAR aux_vlrecaut    AS DEC                                       NO-UNDO.
DEF  VAR aux_vlrepaut    AS DEC                                       NO-UNDO.

/* seguro vida */
DEF  VAR aux_qtsegvid    AS INT                                       NO-UNDO.
DEF  VAR aux_vllanvid    AS DEC                                       NO-UNDO.
DEF  VAR aux_vlrecvid    AS DEC                                       NO-UNDO.
DEF  VAR aux_vlrepvid    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtincvid    AS INT                                       NO-UNDO.
DEF  VAR aux_qtexcvid    AS INT                                       NO-UNDO.

/* seguro residencia */
DEF  VAR aux_qtsegres    AS INT                                       NO-UNDO.
DEF  VAR aux_vllanres    AS DEC                                       NO-UNDO.
DEF  VAR aux_vlrecres    AS DEC                                       NO-UNDO.
DEF  VAR aux_vlrepres    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtincres    AS INT                                       NO-UNDO.
DEF  VAR aux_qtexcres    AS INT                                       NO-UNDO.

/* cartao multiplo e cecred */
DEF VAR tel_tprelato AS CHAR FORMAT "x(38)"
         VIEW-AS COMBO-BOX LIST-ITEMS "Demonstrativo produtos",
                                      "Demonstrativo produtos por colaborador"
                            PFCOLOR 2                                 NO-UNDO.

DEF  VAR tel_dtinicio    AS DATE FORMAT "99/99/9999"                  NO-UNDO.
DEF  VAR tel_dttermin    AS DATE FORMAT "99/99/9999"                  NO-UNDO.
DEF  VAR tel_cdagenci    AS INTE FORMAT "zz9"                         NO-UNDO.
DEF  VAR tel_nmarquiv    AS CHAR  FORMAT "x(25)"                      NO-UNDO.
DEF  VAR tel_nmdireto    AS CHAR  FORMAT "x(20)"                      NO-UNDO.
DEF  VAR aux_nmarqimp    AS CHAR                                      NO-UNDO.
DEF  VAR aux_contalin    AS INT                                       NO-UNDO.
DEF  VAR aux_percenbb    AS DEC                                       NO-UNDO.
DEF  VAR aux_percencv    AS DEC                                       NO-UNDO.

DEF  VAR aux_vlusobbc    AS DEC                                       NO-UNDO.
DEF  VAR aux_vlusobbd    AS DEC                                       NO-UNDO.
DEF  VAR aux_vllimcon    AS DEC                                       NO-UNDO.
DEF  VAR aux_saldoBBC    AS DEC                                       NO-UNDO.
DEF  VAR aux_saldobbd    AS DEC                                       NO-UNDO.

/* beneficio inss */
DEF  VAR aux_qtcoopbe    AS INT                                       NO-UNDO.
DEF  VAR aux_vlcoopbe    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtncoobe    AS INT                                       NO-UNDO.
DEF  VAR aux_vlncoobe    AS DEC                                       NO-UNDO.

DEF  VAR aux_qtasscot    AS INT                                       NO-UNDO.
DEF  VAR aux_qtassdeb    AS INT                                       NO-UNDO.
DEF  VAR aux_qtassrpp    AS INT                                       NO-UNDO.
DEF  VAR aux_qtassepr    AS INT                                       NO-UNDO.
DEF  VAR aux_vltotepr    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtassesp    AS INT                                       NO-UNDO.
DEF  VAR aux_vltotesp    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtassrda    AS INT                                       NO-UNDO.
DEF  VAR aux_percenco    AS DEC                                       NO-UNDO.
DEF  VAR aux_percende    AS DEC                                       NO-UNDO.
DEF  VAR aux_percenrd    AS DEC                                       NO-UNDO.
DEF  VAR aux_percenrp    AS DEC                                       NO-UNDO.
DEF  VAR aux_percenep    AS DEC                                       NO-UNDO.
DEF  VAR aux_percenes    AS DEC                                       NO-UNDO.
DEF  VAR aux_percendc    AS DEC                                       NO-UNDO.
DEF  VAR aux_percendt    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtasunet    AS INT                                       NO-UNDO.
DEF  VAR aux_qtasucxa    AS INT                                       NO-UNDO.
DEF  VAR aux_qtassdch    AS INT                                       NO-UNDO.
DEF  VAR aux_qtassdti    AS INT                                       NO-UNDO.
DEF  VAR aux_qtdescch    AS INT                                       NO-UNDO.
DEF  VAR aux_qtdescti    AS INT                                       NO-UNDO.
DEF  VAR aux_vldescch    AS DEC                                       NO-UNDO.
DEF  VAR aux_vldescti    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtchcomp    AS INT                                       NO-UNDO.

/* Caixa On-line */
DEF  VAR aux_qttiponl    AS INT                                       NO-UNDO.
DEF  VAR aux_qtchconl    AS INT                                       NO-UNDO.
DEF  VAR aux_qttricxa_pf AS INTE                                      NO-UNDO.
DEF  VAR aux_vltricxa_pf AS DECI                                      NO-UNDO.
DEF  VAR aux_qttricxa_pj AS INTE                                      NO-UNDO.
DEF  VAR aux_vltricxa_pj AS DECI                                      NO-UNDO.
/* DDA */
DEF  VAR aux_qtcoodda    AS INT                                       NO-UNDO.
DEF  VAR aux_qtbpgdda    AS INT                                       NO-UNDO.
DEF  VAR aux_vlbpgdda    AS DEC                                       NO-UNDO.

/* Cobranca Registrada */
DEF  VAR aux_qtcpfcbr    AS INT                                       NO-UNDO.
DEF  VAR aux_qtbpfcbb    AS INT                                       NO-UNDO. 
DEF  VAR aux_qtbpfcec    AS INT                                       NO-UNDO.
DEF  VAR aux_qtbpftbb    AS INT                                       NO-UNDO.
DEF  VAR aux_vlbpftbb    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtbpftce    AS DEC                                       NO-UNDO.
DEF  VAR aux_vlbpftce    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtbpflcm    AS INT                                       NO-UNDO.
DEF  VAR aux_vlbpflcm    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtbpflco    AS INT                                       NO-UNDO.
DEF  VAR aux_vlbpflco    AS DEC                                       NO-UNDO.
DEF  VAR aux_vlbpfdda    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtcpjcbr    AS INT                                       NO-UNDO.
DEF  VAR aux_qtcpjcbb    AS INT                                       NO-UNDO.
DEF  VAR aux_qtbpjcec    AS INT                                       NO-UNDO.
DEF  VAR aux_qtbpjtbb    AS INT                                       NO-UNDO.
DEF  VAR aux_vlbpjtbb    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtbpjtce    AS INT                                       NO-UNDO.  
DEF  VAR aux_vlbpjtce    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtbpjlcm    AS INT                                       NO-UNDO.
DEF  VAR aux_vlbpjlcm    AS DEC                                       NO-UNDO.
DEF  VAR aux_qtbpjlco    AS INT                                       NO-UNDO.
DEF  VAR aux_vlbpjlco    AS DEC                                       NO-UNDO.
DEF  VAR aux_vlbpjdda    AS DEC                                       NO-UNDO.

DEF  VAR aux_qtabecon    AS INT                                       NO-UNDO.
DEF  VAR aux_qtplcota    AS INT                                       NO-UNDO.
DEF  VAR aux_qtpoupro    AS INT                                       NO-UNDO.
DEF  VAR aux_qtaplrdc    AS INT                                       NO-UNDO.
DEF  VAR aux_qtlimcre    AS INT                                       NO-UNDO.
DEF  VAR aux_qtdestit    AS INT                                       NO-UNDO.
DEF  VAR aux_qtcarcre    AS INT                                       NO-UNDO.
DEF  VAR aux_qtcobreg    AS INT                                       NO-UNDO.
DEF  VAR aux_qtcobsem    AS INT                                       NO-UNDO.
DEF  VAR aux_qtincdda    AS INT                                       NO-UNDO.

/** Cartao Magnetico  **/
DEF  VAR aux_qttotcrm    AS INT                                       NO-UNDO.
DEF  VAR aux_qtentcrm    AS INT                                       NO-UNDO.         
DEF  VAR aux_qtpagcxa    AS INT                                       NO-UNDO.
DEF  VAR aux_qttrstaa    AS INT                                       NO-UNDO.
DEF  VAR aux_qtassati    AS INT                                       NO-UNDO.
DEF  VAR aux_qtsaqtaa    AS INT                                       NO-UNDO.                                                                      
DEF  VAR aux_vllimcrm    AS DEC                                       NO-UNDO.
DEF  VAR aux_vlmedcrm    AS DEC                                       NO-UNDO.
DEF  VAR aux_vlsaqtaa    AS DEC                                       NO-UNDO.
DEF  VAR aux_mdsaqtaa    AS DEC                                       NO-UNDO.
DEF  VAR aux_vlpagcxa    AS DEC                                       NO-UNDO.
DEF  VAR aux_vltrstaa    AS DEC                                       NO-UNDO.
DEF  VAR aux_qttritaa_pf AS INTE                                      NO-UNDO.
DEF  VAR aux_vltritaa_pf AS DECI                                      NO-UNDO.
DEF  VAR aux_qttritaa_pj AS INTE                                      NO-UNDO.
DEF  VAR aux_vltritaa_pj AS DECI                                      NO-UNDO.

DEF  VAR aux_extensao    AS CHAR INIT ".txt"                          NO-UNDO.

DEF BUFFER b-crapope FOR crapope.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.


VIEW FRAME f_moldura.
PAUSE (0).

FORM 
    "Tipo Relatorio:"   AT 5
     tel_tprelato
     SPACE(2)
    "PA:"
     tel_cdagenci       HELP "Informe o PA ou <0> para TODOS."
     SKIP(1)
    "Data Inicial:"     AT 5
     tel_dtinicio       HELP "Informe a data inicial da consulta." 
     SPACE(3)
     "Data Final:"  
     tel_dttermin       HELP "Informe a data final da consulta."
     SPACE(3)     SKIP(1)
    "Diretorio:   "     AT 5
     tel_nmdireto SKIP(1)      
    "Arquivo:     "         AT 5
     tel_nmarquiv        HELP "Informe o nome do arquivo."
     aux_extensao
     WITH FRAME f_dados overlay ROW 8 NO-LABEL NO-BOX COLUMN 2.

ON RETURN OF tel_tprelato DO:
    APPLY "GO".
END.

DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

    glb_cdprogra = "congpr".
    glb_cddopcao = "C".

    RUN fontes/inicia.p.

    IF   glb_inrestar = 0 THEN
         glb_nrctares = 0.

    FIND crapcop where crapcop.cdcoop = glb_cdcooper NO-LOCK NO-ERROR.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        HIDE aux_extensao IN FRAME f_dados.

        ASSIGN  tel_nmarquiv = "".
        DISPLAY tel_nmarquiv WITH FRAME f_dados.
    
        ASSIGN tel_nmdireto =  "/micros/" + crapcop.dsdircop + "/".
        DISP tel_nmdireto WITH FRAME f_dados.
        UPDATE tel_tprelato WITH FRAME f_dados.

        IF tel_tprelato:SCREEN-VALUE = "Demonstrativo produtos por colaborador" THEN
            UPDATE tel_cdagenci WITH FRAME f_dados.

        UPDATE tel_dtinicio tel_dttermin WITH FRAME f_dados.

        DISPLAY aux_extensao WITH FRAME f_dados.

        UPDATE tel_nmarquiv WITH FRAME f_dados.

        LEAVE.
    END.                               
    
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "CONGPR"   THEN
                 DO:
                     HIDE FRAME f_dados.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   glb_cddopcao <> "C"   THEN
        DO:
            { includes/acesso.i }
        END.


    ASSIGN aux_nomearq = tel_nmdireto + tel_nmarquiv + ".txt".

    OUTPUT STREAM str_1 TO VALUE(aux_nomearq).
    
    ASSIGN aux_contalin = 0.

    IF tel_tprelato:SCREEN-VALUE = "Demonstrativo produtos" THEN
    DO:
        /* BB - Cecred visa caixa eletr - cobrança - internet - visanet - ura */
                                                                       /* BB */
        ASSIGN aux_header = "Cartao Multiplo;Data;Cartoes;Cooperados;Percentual;" +
                    "Limite BB C;Limite Ayllos C; Saldo - C; Limite BB D;" +
                    "Limite Ayllos D; Saldo - D;" + 
                    "Quant. Saques;Total sacado;Quant. Transacoes;" + 
                    "Total Transacoes;Quant. Debitos;" + 
                    "Total Debitos;Faturas;Total Faturas" + ";" +
                    "Coop. Saque;Coop. Transacoes;Coop utiliz. Cartao;" +
     
                    "Cecred Visa;Data;Cartoes;Cooperados;Percentual;" + 
                    "Limite Concedido;Quant.Saques;"+
                    "Total sacado;Qtd Faturas;" +
                    "Faturas;Qtd. Anuidades;Total Anuidade;Coop Saque;" +

                    /* beneficiario inss */
                    "Beneficios Inss;Data;Quant. Coop.;Beneficos Pagos;" + 
                    "Não Cooperados;Beneficios Pagos;" +
                                        
                    "Caixa eletronico;Data;Quant. Coop. PF;Saques PF;Valor;" +
                    "Transf. PF;Valor;" + /* caixa eletronico */
                    "Pagamentos PF;Valor;" +
                    "Depositos PF;Valor;" +
                    "Quant. Coop. PJ;Saques PJ;Valor;Transf. PJ;Valor" + ";" +
                    "Pagamentos PJ;Valor;" +
                    "Depositos PJ;Valor;Transf. Intercoop. PF;Valor;" +
                    "Transf. Intercoop. PJ;Valor;" +

                    "Cobranca;Data;Cooperados PF;Quant. Cred. Compe - PF;Valor;" +
                    "Quant. Cred. Cooperativa PF;Valor;" + 
                    "Quant. Tarifas - PF;Total tarifa  PF;" +  /* cobrança */
                    "Cooperados PJ;Quant. Cred.  Compe - PJ;Valor;" +
                    "Quant. Cred. Cooperativa PJ;Valor;Quant. Tarifas PJ;" +
                    "Total tarifa  PJ;" +
                    
                    "Cobranca Registrada;Data;Cooperados PF emitiram;" +
                    "Quant. Boletos Registrados BB - PF;" +
                    "Quant. Boletos Registrados 085 - PF;" + 
                    "Quant. Tarifas pagas pelo cooperado BB - PF;" +
                    "Total Tarifas BB - PF;" + 
                    "Quant. Tarifas pagas pelo cooperado 085 - PF;" +
                    "Total Tarifas 085 - PF;Quant. Liquidacao Compe - PF;" +
                    "Valor liquidacao Compe - PF;" +
                    "Quant. Liquidacao Cooperativa - PF;" + 
                    "Valor liquidacao Cooperativa - PF;Liquidados DDA - PF;" +
                    "Cooperados PJ;" + "Quant. Registros BB - PJ;" + 
                    "Quant. Registros 085 - PJ;" +
                    "Quant. Tarifas BB - PJ;Total Tarifas BB - PJ;" +
                    "Quant. Tarifas 085 - PJ;" +
                    "Total Tarifas 085 - PJ;Quant. Liquidacao Compe - PJ;" +
                    "Valor liquidacao Compe - PJ;" +
                    "Quant. Liquidacao Coop. - PJ;" + 
                    "Valor liquidacao Coop. - PJ;Liquidados DDA - PJ;" +

                    "DDA - Debito Direto Autorizado;Data;Cooperados com DDA;" +
                    "Quant. Boletos pagos;Valor" + ";" + 

                    "Internet;Data;Cooperados PF;Extrato PF;" +
                    "Emissão boletos PF;Valor dos boletos;Pagamento PF;" + 
                    /* internet */
                    "Valor Pagamentos;Transf.  PF;Valor Transf.;Ted PF;Valor Ted PF;" +
                    "Cooperados PJ;Extrato PJ;" + 
                    "Emissão boletos PJ;Valor dos boletos;Pagamento PJ;" + 
                    "Valor Pagamentos;" + 
                    "Transf.  PJ;Valor Transf.;Ted PJ;Valor Ted PJ" + ";" +
                    "Transf. Intercoop. PF;Valor;Transf. Intercoop. PJ;Valor;" +

                    /* visanet */
                    "Visanet;Data;Cooperados;Quant. Credito;" +
                    "Total dos Creditos" + ";" +

                    /* redecard*/
                    "Redecard;Data;Cooperados;Quant. Credito;" +
                    "Total dos Creditos" + ";" +

                    /* ura */
                    "Ura;Data;Cooperados;Consulta" + ";" + 
                   
                    /* convenios */
                    "Convenios;Data;Quant. Fatura;Valor Fatura;" + 
                    "Quant. Deb. Autom.; Valor Deb. Autom.;". 

        ASSIGN aux_header = aux_header + 
                    /* seguro auto */
                    "Seguro Auto;Data;Quantidade;Total dos Seguros; Receita;" +
                     "Repasse Corretora;"  +

                    /* seguro vida */
                    "Seguro Vida;Data;Quantidade;Total dos Seguros; Receita;" +
                     "Repasse Corretora; Inclusoes; Exclusoes;" +

                    /* seguro residencial */
                    "Seguro Res.;Data;Quantidade;Total dos Seguros; Receita;" +
                     "Repasse Corretora; Inclusoes; Exclusoes;".

        ASSIGN  aux_header = aux_header +  
                         /** Participacao **/
                         "Participacao;" +
                         "Cooperados;"+
                         "Coop. Plano de Cotas;% Coop. Plano de Cotas;" +
                         "Deb. Automatico;% Coop. Deb. Automatico;" + 
                         "Coop. Aplicacao;% Coop. Aplicacao;" +
                         "Coop. Poupanca Programada;% Coop. Poup. Programada;" +
                         "Coop. com Emprestimo;% Coop. com Emprestimo;" + 
                         "Total Emprestado;" + 
                         "Coop. Desconto Cheque;% Coop. Desconto Cheque;" +
                         "Total Cheque Descontados;Valor Cheque Descontados;" + 
                         "Coop. Desconto Titulo;% Coop. Desconto Titulo;" +
                         "Total Titulos Descontados;Valor Titulos Descontados;" +
                         "Coop. Cheque Especial;% Coop. Cheque Especial;" +
                         "Total Cheque Especial Concedido;" +
                         "Total Coop. Acesso Internet;" +
                         "Total Coop. Utilizaram Caixa;" +
                         "Quant. Cheques compensados;" +
                         
                         /** Caixa On-Line **/
                         "Caixa On-Line;" + 
                         "Data;" + 
                         "Cooperados;" + 
                         "Quant. Titulos Pagos;" +
                         "Quant. Cheques Compensados;" + 
                         "Transf. Intercoop. PF;Valor;Transf. Intercoop. PJ;Valor;".

        ASSIGN aux_header = aux_header +
                          /** Cartao Magnetico **/      
                          "Cartao magnetico;" +
                          "Data;" + 
                          "Contas ativas;" +
                          "Total de cartoes;" +
                          "Cartoes entregues;" +
                          "Total limite;" +
                          "Media limite;" +
                          "Total de saques;" +
                          "Media de saques;" +
                          "Quantidade pagamentos;" +
                          "Total de pagamentos;" +
                          "Quantidade transferencias;" +
                          "Total de transferencias;".

        PUT STREAM str_1 aux_header FORMAT "x(4000)" SKIP.

        ASSIGN aux_datini = tel_dtinicio
               aux_datfim = tel_dttermin.

        FOR EACH crapgpr WHERE crapgpr.cdcooper = glb_cdcooper      AND
                               crapgpr.dtrefere >= aux_datini       AND 
                               crapgpr.dtrefere <= aux_datfim
                               NO-LOCK BREAK BY  
                               MONTH (crapgpr.dtrefere):
                
            IF crapgpr.inpessoa = 1 THEN
            DO:
                ASSIGN aux_qtasscxa_pf = aux_qtasscxa_pf + crapgpr.qtasscxa
                       aux_qtsaqcxa_pf = aux_qtsaqcxa_pf + crapgpr.qtsaqcxa  
                       aux_vlsaqcxa_pf = aux_vlsaqcxa_pf + crapgpr.vlsaqcxa
                       aux_qttrscxa_pf = aux_qttrscxa_pf + crapgpr.qttrscxa
                       aux_vltrscxa_pf = aux_vltrscxa_pf + crapgpr.vltrscxa
                       aux_qtpagcxa_pf = aux_qtpagcxa_pf + crapgpr.qtpagcxa
                       aux_vlpagcxa_pf = aux_vlpagcxa_pf + crapgpr.vlpagcxa
                       aux_qtdepcxa_pf = aux_qtdepcxa_pf + crapgpr.qtdepcxa
                       aux_vldepcxa_pf = aux_vldepcxa_pf + crapgpr.vldepcxa
                       aux_qttricxa_pf = aux_qttricxa_pf + crapgpr.qttricxa
                       aux_vltricxa_pf = aux_vltricxa_pf + crapgpr.vltricxa.

                ASSIGN aux_qtasscob_pf = aux_qtasscob_pf + crapgpr.qtasscob
                       aux_qtdcobbb_pf = aux_qtdcobbb_pf + crapgpr.qtdcobbb
                       aux_vlrcobbb_pf = aux_vlrcobbb_pf + crapgpr.vlrcobbb
                       aux_qtcobonl_pf = aux_qtcobonl_pf + crapgpr.qtcobonl
                       aux_vlcobonl_pf = aux_vlcobonl_pf + crapgpr.vlcobonl
                       aux_qttrfcob_pf = aux_qttrfcob_pf + crapgpr.qttrfcob
                       aux_vltrfcob_pf = aux_vltrfcob_pf + crapgpr.vltrfcob.

                ASSIGN aux_qtassnet_pf = aux_qtassnet_pf + crapgpr.qtassnet
                       aux_qtextnet_pf = aux_qtextnet_pf + crapgpr.qtextnet
                       aux_qtbltnet_pf = aux_qtbltnet_pf + crapgpr.qtbltnet
                       aux_vlbltnet_pf = aux_vlbltnet_pf + crapgpr.vlbltnet
                       aux_qtpagnet_pf = aux_qtpagnet_pf + crapgpr.qtpagnet
                       aux_vlpagnet_pf = aux_vlpagnet_pf + crapgpr.vlpagnet
                       aux_qttrsnet_pf = aux_qttrsnet_pf + crapgpr.qttrsnet
                       aux_vltrsnet_pf = aux_vltrsnet_pf + crapgpr.vltrsnet
                       aux_qttednet_pf = aux_qttednet_pf + crapgpr.qttednet
                       aux_vltednet_pf = aux_vltednet_pf + crapgpr.vltednet
                       aux_qttrinet_pf = aux_qttrinet_pf + crapgpr.qttrinet
                       aux_vltrinet_pf = aux_vltrinet_pf + crapgpr.vltrinet.

                ASSIGN aux_qtcpfcbr = aux_qtcpfcbr + crapgpr.qtcpfcbr
                       aux_qtbpfcbb = aux_qtbpfcbb + crapgpr.qtbpfcbb
                       aux_qtbpfcec = aux_qtbpfcec + crapgpr.qtbpfcec
                       aux_qtbpftbb = aux_qtbpftbb + crapgpr.qtbpftbb
                       aux_vlbpftbb = aux_vlbpftbb + crapgpr.vlbpftbb
                       aux_qtbpftce = aux_qtbpftce + crapgpr.qtbpftce
                       aux_vlbpftce = aux_vlbpftce + crapgpr.vlbpftce
                       aux_qtbpflcm = aux_qtbpflcm + crapgpr.qtbpflcm
                       aux_vlbpflcm = aux_vlbpflcm + crapgpr.vlbpflcm
                       aux_qtbpflco = aux_qtbpflco + crapgpr.qtbpflco
                       aux_vlbpflco = aux_vlbpflco + crapgpr.vlbpflco
                       aux_vlbpfdda = aux_vlbpfdda + crapgpr.vlbpfdda.

                ASSIGN aux_qttritaa_pf = aux_qttritaa_pf + crapgpr.qttritaa
                       aux_vltritaa_pf = aux_vltritaa_pf + crapgpr.vltritaa.
            END.

            IF crapgpr.inpessoa = 2 THEN
            DO:
                ASSIGN aux_qtasscxa_pj = aux_qtasscxa_pj + crapgpr.qtasscxa
                       aux_qtsaqcxa_pj = aux_qtsaqcxa_pj + crapgpr.qtsaqcxa
                       aux_vlsaqcxa_pj = aux_vlsaqcxa_pj + crapgpr.vlsaqcxa
                       aux_qttrscxa_pj = aux_qttrscxa_pj + crapgpr.qttrscxa
                       aux_vltrscxa_pj = aux_vltrscxa_pj + crapgpr.vltrscxa
                       aux_qtpagcxa_pj = aux_qtpagcxa_pj + crapgpr.qtpagcxa
                       aux_vlpagcxa_pj = aux_vlpagcxa_pj + crapgpr.vlpagcxa
                       aux_qtdepcxa_pj = aux_qtdepcxa_pj + crapgpr.qtdepcxa
                       aux_vldepcxa_pj = aux_vldepcxa_pj + crapgpr.vldepcxa
                       aux_qttricxa_pj = aux_qttricxa_pj + crapgpr.qttricxa
                       aux_vltricxa_pj = aux_vltricxa_pj + crapgpr.vltricxa.

                ASSIGN aux_qtasscob_pj = aux_qtasscob_pj + crapgpr.qtasscob
                       aux_qtdcobbb_pj = aux_qtdcobbb_pj + crapgpr.qtdcobbb
                       aux_vlrcobbb_pj = aux_vlrcobbb_pj + crapgpr.vlrcobbb
                       aux_qtcobonl_pj = aux_qtcobonl_pj + crapgpr.qtcobonl
                       aux_vlcobonl_pj = aux_vlcobonl_pj + crapgpr.vlcobonl
                       aux_qttrfcob_pj = aux_qttrfcob_pj + crapgpr.qttrfcob
                       aux_vltrfcob_pj = aux_vltrfcob_pj + crapgpr.vltrfcob.

                ASSIGN aux_qtassnet_pj = aux_qtassnet_pj + crapgpr.qtassnet
                       aux_qtextnet_pj = aux_qtextnet_pj + crapgpr.qtextnet
                       aux_qtbltnet_pj = aux_qtbltnet_pj + crapgpr.qtbltnet
                       aux_vlbltnet_pj = aux_vlbltnet_pj + crapgpr.vlbltnet
                       aux_qtpagnet_pj = aux_qtpagnet_pj + crapgpr.qtpagnet
                       aux_vlpagnet_pj = aux_vlpagnet_pj + crapgpr.vlpagnet
                       aux_qttrsnet_pj = aux_qttrsnet_pj + crapgpr.qttrsnet
                       aux_vltrsnet_pj = aux_vltrsnet_pj + crapgpr.vltrsnet
                       aux_qttednet_pj = aux_qttednet_pj + crapgpr.qttednet
                       aux_vltednet_pj = aux_vltednet_pj + crapgpr.vltednet
                       aux_qttrinet_pj = aux_qttrinet_pj + crapgpr.qttrinet
                       aux_vltrinet_pj = aux_vltrinet_pj + crapgpr.vltrinet.

                ASSIGN aux_qtcpjcbr = aux_qtcpjcbr + crapgpr.qtcpjcbr
                       aux_qtcpjcbb = aux_qtcpjcbb + crapgpr.qtcpjcbb
                       aux_qtbpjcec = aux_qtbpjcec + crapgpr.qtbpjcec
                       aux_qtbpjtbb = aux_qtbpjtbb + crapgpr.qtbpjtbb
                       aux_vlbpjtbb = aux_vlbpjtbb + crapgpr.vlbpjtbb
                       aux_qtbpjtce = aux_qtbpjtce + crapgpr.qtbpjtce
                       aux_vlbpjtce = aux_vlbpjtce + crapgpr.vlbpjtce
                       aux_qtbpjlcm = aux_qtbpjlcm + crapgpr.qtbpjlcm
                       aux_vlbpjlcm = aux_vlbpjlcm + crapgpr.vlbpjlcm
                       aux_qtbpjlco = aux_qtbpjlco + crapgpr.qtbpjlco
                       aux_vlbpjlco = aux_vlbpjlco + crapgpr.vlbpjlco
                       aux_vlbpjdda = aux_vlbpjdda + crapgpr.vlbpjdda.

                ASSIGN aux_qttritaa_pj = aux_qttritaa_pj + crapgpr.qttritaa
                       aux_vltritaa_pj = aux_vltritaa_pj + crapgpr.vltritaa.
            END.

            ASSIGN aux_qtdatibb = aux_qtdatibb + crapgpr.qtdatibb
                   aux_vllimcbb = crapgpr.vllimcbb 
                   aux_vllimdbb = crapgpr.vllimdbb
                   aux_qtassqcv = aux_qtassqcv + crapgpr.qtassqcv
                   aux_qtassqbb = aux_qtassqbb + crapgpr.qtassqbb
                   aux_qtasstbb = aux_qtasstbb + crapgpr.qtasstbb
                   aux_qtasqtbb = aux_qtasqtbb + crapgpr.qtasqtbb
                   aux_qtdsaqbb = aux_qtdsaqbb + crapgpr.qtdsaqbb
                   aux_vlrsaqbb = aux_vlrsaqbb + crapgpr.vlrsaqbb
                   aux_qtdtrsbb = aux_qtdtrsbb + crapgpr.qtdtrsbb
                   aux_vlrtrsbb = aux_vlrtrsbb + crapgpr.vlrtrsbb
                   aux_qtddebbb = aux_qtddebbb + crapgpr.qtddebbb
                   aux_vlrdebbb = aux_vlrdebbb + crapgpr.vlrdebbb
                   aux_qtdcrebb = aux_qtdcrebb + crapgpr.qtdcrebb
                   aux_vlrcrebb = aux_vlrcrebb + crapgpr.vlrcrebb
           
                   /* Transacoes = Transfer. com cartao  BB + 
                                                    Pgmtos. com Cartao BB.  */
                   aux_qttransacoes = aux_qtdtrsbb + aux_qtdcrebb 
                   aux_vltransacoes = aux_vlrtrsbb + aux_vlrcrebb
           /* --------------------------------------------------------------- */

                   aux_qtdaticv = aux_qtdaticv + crapgpr.qtdaticv
                       
                   aux_vllimccv = crapgpr.vllimccv
                   aux_qtdsaqcv = aux_qtdsaqcv + crapgpr.qtdsaqcv
                   aux_vlrsaqcv = aux_vlrsaqcv + crapgpr.vlrsaqcv
                        
                   aux_qtdcrecv = aux_qtdcrecv + crapgpr.qtdcrecv
                   aux_vlrcrecv = aux_vlrcrecv + crapgpr.vlrcrecv
                   aux_qtdanucv = aux_qtdanucv + crapgpr.qtdanucv
                        
                   aux_vlranucv = aux_vlranucv + crapgpr.vlranucv
                   aux_qtassvsn = aux_qtassvsn + crapgpr.qtassvsn
                   aux_qtlanvsn = aux_qtlanvsn + crapgpr.qtlanvsn
                   aux_vllanvsn = aux_vllanvsn + crapgpr.vllanvsn

                   aux_qtassrcd = aux_qtassrcd + crapgpr.qtassrcd
                   aux_qtlanrcd = aux_qtlanrcd + crapgpr.qtlanrcd
                   aux_vllanrcd = aux_vllanrcd + crapgpr.vllanrcd

                   aux_qtassura = aux_qtassura + crapgpr.qtassura
                   aux_qtconura = aux_qtconura + crapgpr.qtconura

                   aux_qtfatcnv = aux_qtfatcnv + crapgpr.qtfatcnv
                   aux_vlfatcnv = aux_vlfatcnv + crapgpr.vlfatcnv
                   aux_qtdebcnv = aux_qtdebcnv + crapgpr.qtdebcnv
                   aux_vldebcnv = aux_vldebcnv + crapgpr.vldebcnv

                   /* seguro auto */
                   aux_qtsegaut = aux_qtsegaut + crapgpr.qtsegaut
                   aux_vllanaut = aux_vllanaut + crapgpr.vlsegaut
                   aux_vlrecaut = aux_vlrecaut + crapgpr.vlrecaut
                   aux_vlrepaut = aux_vlrepaut + crapgpr.vlrepaut

                   /* seguro vida */
                   aux_qtsegvid = aux_qtsegvid + crapgpr.qtsegvid
                   aux_vllanvid = aux_vllanvid + crapgpr.vlsegvid
                   aux_vlrecvid = aux_vlrecvid + crapgpr.vlrecvid
                   aux_vlrepvid = aux_vlrepvid + crapgpr.vlrepvid
                   aux_qtincvid = aux_qtincvid + crapgpr.qtincvid
                   aux_qtexcvid = aux_qtexcvid + crapgpr.qtexcvid

                   /* seguro residencia */
                   aux_qtsegres = aux_qtsegres + crapgpr.qtsegres
                   aux_vllanres = aux_vllanres + crapgpr.vlsegres
                   aux_vlrecres = aux_vlrecres + crapgpr.vlrecres
                   aux_vlrepres = aux_vlrepres + crapgpr.vlrepres
                   aux_qtincres = aux_qtincres + crapgpr.qtincres
                   aux_qtexcres = aux_qtexcres + crapgpr.qtexcres

                   /* cartao multiplo */
                   aux_vlusobbc = crapgpr.vlusocbb /* aux_vlusobbc + crapgpr.vlusocbb */
                   aux_vlusobbd = crapgpr.vlusodbb /* aux_vlusobbd + crapgpr.vlusodbb */
           

                   /* beneficiario INSS */
                   aux_qtcoopbe = aux_qtcoopbe + crapgpr.qtasscbe
                   aux_vlcoopbe = aux_vlcoopbe + crapgpr.vlasscbe
                   aux_qtncoobe = aux_qtncoobe + crapgpr.qtnassbe
                   aux_vlncoobe = aux_vlncoobe + crapgpr.vlnassbe

                   /* participacao */
                   aux_qtassdeb = aux_qtassdeb + crapgpr.qtassdeb
                   aux_qtassrpp = aux_qtassrpp + crapgpr.qtassrpp
                   aux_qtassepr = aux_qtassepr + crapgpr.qtassepr
                   aux_vltotepr = aux_vltotepr + crapgpr.vltotepr
                   aux_qtassesp = aux_qtassesp + crapgpr.qtassesp
                   aux_vltotesp = aux_vltotesp + crapgpr.vltotesp
                   aux_qtassrda = aux_qtassrda + crapgpr.qtassrda
                   aux_qtasunet = aux_qtasunet + crapgpr.qtasunet
                   aux_qtasucxa = aux_qtasucxa + crapgpr.qtasucxa
                   aux_qtassdch = aux_qtassdch + crapgpr.qtassdch
                   aux_qtassdti = aux_qtassdti + crapgpr.qtassdti
                   aux_qtdescch = aux_qtdescch + crapgpr.qtdescch
                   aux_qtdescti = aux_qtdescti + crapgpr.qtdescti
                   aux_vldescch = aux_vldescch + crapgpr.vldescch
                   aux_vldescti = aux_vldescti + crapgpr.vldescti
                   aux_qtchcomp = aux_qtchcomp + crapgpr.qtchcomp

                   /* Caixa On-line */
                   aux_qttiponl = aux_qttiponl + crapgpr.qttiponl
                   aux_qtchconl = aux_qtchconl + crapgpr.qtchconl

                   /* DDA */
                   aux_qtcoodda = aux_qtcoodda + crapgpr.qtcoodda
                   aux_qtbpgdda = aux_qtbpgdda + crapgpr.qtbpgdda
                   aux_vlbpgdda = aux_vlbpgdda + crapgpr.vlbpgdda.

                   /* Cartao Magnetico */
            ASSIGN  aux_qtassati = aux_qtassati + crapgpr.qtassati
                    aux_qttotcrm = aux_qttotcrm + crapgpr.qttotcrm
                    aux_qtentcrm = aux_qtentcrm + crapgpr.qtentcrm
                    aux_vllimcrm = aux_vllimcrm + crapgpr.vllimcrm
                    aux_vlsaqtaa = aux_vlsaqtaa + crapgpr.vlsaqtaa
                    aux_qtsaqtaa = aux_qtsaqtaa + crapgpr.qtsaqtaa
                    aux_qtpagcxa = aux_qtpagcxa + crapgpr.qtpagcxa
                    aux_vlpagcxa = aux_vlpagcxa + crapgpr.vlpagcxa
                    aux_qttrstaa = aux_qttrstaa + crapgpr.qttrstaa
                    aux_vltrstaa = aux_vltrstaa + crapgpr.vltrstaa.

            IF  crapgpr.inpessoa = 0 THEN
            DO:
                aux_qtassoci = aux_qtassoci + crapgpr.qtassoci.
                aux_qtasscot = aux_qtasscot + crapgpr.qtasscot.
            END.
        
            IF   LAST-OF(MONTH (crapgpr.dtrefere)) THEN
                 DO:
                    ASSIGN aux_contalin = aux_contalin + 1
                          aux_saldoBBd = aux_vllimdbb - aux_vlusobbd
                          aux_saldobbc = aux_vllimcbb - aux_vlusobbc.

                    IF aux_qttotcrm > 0 THEN
                      aux_vlmedcrm = aux_vllimcrm / aux_qttotcrm.
                    ELSE
                      aux_vlmedcrm = 0.

                    IF aux_qtsaqtaa > 0 THEN
                      aux_mdsaqtaa = aux_vlsaqtaa / aux_qtsaqtaa.
                    ELSE
                      aux_mdsaqtaa = 0.


                    IF  aux_qtassoci = 0 THEN /* Tratar divisão por zero. */
                        DO:
                           ASSIGN  aux_percenbb = 0
                                   aux_percencv = 0
                                   /* Percentuais de Participacoes */
                                   aux_percenco = 0
                                   aux_percende = 0
                                   aux_percenrd = 0
                                   aux_percenrp = 0
                                   aux_percenep = 0
                                   aux_percenes = 0
                                   aux_percendc = 0
                                   aux_percendt = 0.
                        END.
                    ELSE
                       DO:
                           ASSIGN aux_percenbb = aux_qtdatibb / aux_qtassoci * 100
                                  aux_percencv = aux_qtdaticv / aux_qtassoci * 100
                                  /* Percentuais de Participacoes */
                                  aux_percenco = aux_qtasscot / aux_qtassoci * 100
                                  aux_percende = aux_qtassdeb / aux_qtassoci * 100 
                                  aux_percenrd = aux_qtassrda / aux_qtassoci * 100
                                  aux_percenrp = aux_qtassrpp / aux_qtassoci * 100
                                  aux_percenep = aux_qtassepr / aux_qtassoci * 100
                                  aux_percenes = aux_qtassesp / aux_qtassoci * 100
                                  aux_percendc = aux_qtassdch / aux_qtassoci * 100
                                  aux_percendt = aux_qtassdti / aux_qtassoci * 100.
                        END.

                       ASSIGN aux_linha = 
                "Cartao Multiplo;" + STRING(MONTH (crapgpr.dtrefere),"99") + 
               "/" + /* bb */
               STRING(YEAR (crapgpr.dtrefere),"9999") + ";" + 
               STRING(aux_qtdatibb,"99999999") + ";" + /*ativos */
               STRING(aux_qtassoci,"99999999") + ";" +
               REPLACE(STRING(aux_percenbb,"zzz.99"),".",",") + ";" + 
               REPLACE(STRING(aux_vllimcbb,"zzzzzzzz9.99"), ".", ",") + ";" + 
               REPLACE(STRING(aux_vlusobbc,"zzzzzzzz9.99"), ".", ",") + ";" +
               REPLACE(STRING(aux_saldobbc,"-zzzzzzzz9.99"), ".", ",") + ";" +
               REPLACE(STRING(aux_vllimdbb,"zzzzzzzz9.99"), ".", ",") + ";" +
               REPLACE(STRING(aux_vlusobbd,"zzzzzzzz9.99"), ".", ",") + ";" +
               REPLACE(STRING(aux_saldobbd,"-zzzzzzzz9.99"), ".", ",") + ";" +  
               STRING(aux_qtdsaqbb,"999999999") + ";" +
               REPLACE(STRING(aux_vlrsaqbb,"zzzzzzzz9.99"), ".", ",") + ";" +
               STRING(aux_qttransacoes,"999999999") + ";" +
               REPLACE(STRING(aux_vltransacoes,"zzzzzzzz9.99"), ".", ",") + ";" + 
               STRING(aux_qtddebbb,"999999999") + ";" +
               REPLACE(STRING(aux_vlrdebbb,"zzzzzzzz9.99"), ".", ",") + ";" + 
               STRING(aux_qtdcrebb,"999999999") + ";" +
               REPLACE(string(aux_vlrcrebb,"zzzzzzzz9.99"), ".", ",") + ";" +
               STRING(aux_qtassqbb,"999999999") + ";" +
               STRING(aux_qtasstbb,"999999999") + ";" +
               STRING(aux_qtasqtbb,"999999999") + ";" +
                           
               "Cartao Cecred Visa;" + 
               STRING(MONTH (crapgpr.dtrefere),"99") + "/" + 
               /* cecred visa */
               STRING(YEAR (crapgpr.dtrefere),"9999") + ";" + 
               STRING(aux_qtdaticv,"99999999") + ";" + /*ativos */
               STRING(aux_qtassoci,"99999999") + ";" + 
               REPLACE(STRING(aux_percencv,"zzz.99"),".",",") + ";" +
               REPLACE(STRING(aux_vllimccv,"zzzzzzzz9.99"), ".", ",") + ";" + 
               STRING(aux_qtdsaqcv,"999999999") + ";" +
               REPLACE(STRING(aux_vlrsaqcv,"zzzzzzzz9.99"), ".", ",") + ";" +
               STRING(aux_qtdcrecv,"999999999") + ";" +
               REPLACE(STRING(aux_vlrcrecv,"zzzzzzzz9.99"), ".", ",") + ";" + 
               STRING(aux_qtdanucv,"999999999") + ";" +
               REPLACE(STRING(aux_vlranucv,"zzzzzzzz9.99"), ".", ",") + ";" +
               STRING(aux_qtassqcv,"999999999") + ";" +
               
               "Beneficios Inss;" + STRING(MONTH (crapgpr.dtrefere),"99") + 
               "/" +
               STRING(YEAR  (crapgpr.dtrefere),"9999") + ";" +
               STRING(aux_qtcoopbe,"99999999") + ";" + 
               /* coopedados com beneficio */
               REPLACE(STRING(aux_vlcoopbe,"zzzzzzzz9.99"),".",",") + ";" +
               STRING(aux_qtncoobe,"99999999") + ";" + 
               REPLACE(STRING(aux_vlncoobe,"zzzzzzzz9.99"), ".", ",") + ";".

                           
                       ASSIGN aux_linha = aux_linha + 
               "caixa Eletronico;" + STRING(MONTH (crapgpr.dtrefere),"99") + 
               "/" + /* caixa eletronico */
               STRING(YEAR  (crapgpr.dtrefere),"9999") + ";" + 
               STRING(aux_qtasscxa_pf,"99999999") + ";" + /*pf */
               STRING(aux_qtsaqcxa_pf,"99999999") + ";" + 
               REPLACE(STRING(aux_vlsaqcxa_pf,"zzzzzzzz9.99"), ".", ",") + 
               ";" + 
               STRING(aux_qttrscxa_pf,"999999999") + ";" +
               REPLACE(STRING(aux_vltrscxa_pf,"zzzzzzzz9.99"), ".", ",") + 
               ";" +
               STRING(aux_qtpagcxa_pf,"999999999") + ";" +
               REPLACE(STRING(aux_vlpagcxa_pf,"zzzzzzzz9.99"), ".", ",") + 
               ";" +
               STRING(aux_qtdepcxa_pf,"999999999") + ";" +
               REPLACE(STRING(aux_vldepcxa_pf,"zzzzzzzz9.99"), ".", ",") + 
               ";" +
               STRING(aux_qtasscxa_pj,"99999999") + ";" + /* pj */
               STRING(aux_qtsaqcxa_pj,"99999999") + ";" + 
               REPLACE(STRING(aux_vlsaqcxa_pj,"zzzzzzzz9.99"), ".", ",") + 
               ";" + 
               STRING(aux_qttrscxa_pj,"999999999") + ";" +
               REPLACE(STRING(aux_vltrscxa_pj,"zzzzzzzz9.99"), ".", ",") + 
               ";" +
               STRING(aux_qtpagcxa_pj,"999999999") + ";" +
               REPLACE(STRING(aux_vlpagcxa_pj,"zzzzzzzz9.99"), ".", ",") + 
               ";" +
               STRING(aux_qtdepcxa_pj,"999999999") + ";" +
               REPLACE(STRING(aux_vldepcxa_pj,"zzzzzzzz9.99"), ".", ",") + 
               ";" +
               STRING(aux_qttritaa_pf,"999999999") + ";" + 
               REPLACE(STRING(aux_vltritaa_pf,"zzzzzzzz9.99"),".",",") +
               ";" + STRING(aux_qttritaa_pj,"999999999") + ";" + 
               REPLACE(STRING(aux_vltritaa_pj,"zzzzzzzz9.99"),".",",")  + 
               ";" +           

               "Cobranca;" + STRING(MONTH (crapgpr.dtrefere),"99") + "/" + 
               /* cobrança */
               STRING(YEAR  (crapgpr.dtrefere),"9999") + ";" + 
               STRING(aux_qtasscob_pf,"99999999") + ";" + /*pf */
               STRING(aux_qtdcobbb_pf,"99999999") + ";" + 
               REPLACE(STRING(aux_vlrcobbb_pf,"zzzzzzzz9.99"), ".", ",") + 
               ";" + STRING(aux_qtcobonl_pf,"999999999") + ";" +
               REPLACE(STRING(aux_vlcobonl_pf,"zzzzzzzz9.99"), ".", ",") +
               ";" + STRING(aux_qttrfcob_pf,"999999999") + ";" +
               REPLACE(STRING(aux_vltrfcob_pf,"zzzzzzzz9.99"), ".", ",") + 
               ";" + STRING(aux_qtasscob_pj,"99999999") + ";" + /*pj */
               STRING(aux_qtdcobbb_pj,"99999999") + ";" + 
               REPLACE(STRING(aux_vlrcobbb_pj,"zzzzzzzz9.99"), ".", ",") + 
               ";" + STRING(aux_qtcobonl_pj,"999999999") + ";" +
               REPLACE(STRING(aux_vlcobonl_pj,"zzzzzzzz9.99"), ".", ",") + 
               ";" + STRING(aux_qttrfcob_pj,"999999999") + ";" +
               REPLACE(STRING(aux_vltrfcob_pj,"zzzzzzzz9.99"), ".", ",") + 
               ";" + 

               "Cobranca Registrada;" + STRING(MONTH (crapgpr.dtrefere),"99")
               + "/" + STRING(YEAR  (crapgpr.dtrefere),"9999") + ";" + 
               /* Cobranca Registrada */
               STRING(aux_qtcpfcbr,"99999999") + ";" + 
               STRING(aux_qtbpfcbb,"99999999") + ";" + /*pf*/
               STRING(aux_qtbpfcec,"99999999") + ";" + 
               STRING(aux_qtbpftbb,"99999999") + ";" +
               REPLACE(STRING(aux_vlbpftbb,"zzzzzzzz9.99"), ".", ",") + ";" + 
               STRING(aux_qtbpftce,"99999999") + ";" +
               REPLACE(STRING(aux_vlbpftce,"zzzzzzzz9.99"), ".", ",") + ";" + 
               STRING(aux_qtbpflcm,"99999999") + ";" +
               REPLACE(STRING(aux_vlbpflcm,"zzzzzzzz9.99"), ".", ",") + ";" + 
               STRING(aux_qtbpflco,"99999999") + ";" +
               REPLACE(STRING(aux_vlbpflco,"zzzzzzzz9.99"), ".", ",") + ";" + 
               REPLACE(STRING(aux_vlbpfdda,"zzzzzzzz9.99"), ".", ",") + ";" + 
               STRING(aux_qtcpjcbr,"99999999") + ";" + 
               STRING(aux_qtcpjcbb,"99999999") + ";" + /*pj*/
               STRING(aux_qtbpjcec,"99999999") + ";" + 
               STRING(aux_qtbpjtbb,"99999999") + ";" +
               REPLACE(STRING(aux_vlbpjtbb,"zzzzzzzz9.99"), ".", ",") + ";" +
               STRING(aux_qtbpjtce,"99999999") + ";" +
               REPLACE(STRING(aux_vlbpjtce,"zzzzzzzz9.99"), ".", ",") + ";" +
               STRING(aux_qtbpjlcm,"99999999") + ";" +
               REPLACE(STRING(aux_vlbpjlcm,"zzzzzzzz9.99"), ".", ",") + ";" +
               STRING(aux_qtbpjlco,"99999999") + ";" +
               REPLACE(STRING(aux_vlbpjlco,"zzzzzzzz9.99"), ".", ",") + ";" +
               REPLACE(STRING(aux_vlbpjdda,"zzzzzzzz9.99"), ".", ",") + ";" +
               
               "DDA - Debito Direto Autorizado;" + 
               STRING(MONTH (crapgpr.dtrefere),"99") + /* DDA */
               "/" + STRING(YEAR  (crapgpr.dtrefere),"9999") + ";" + 
               STRING(aux_qtcoodda,"99999999") + ";" + 
               STRING(aux_qtbpgdda,"99999999") + ";" + 
               REPLACE(STRING(aux_vlbpgdda,"zzzzzzzz9.99"), ".", ",") + ";" +

               "Internet;" + 
               STRING(MONTH (crapgpr.dtrefere),"99") + "/" + /* internet */
               STRING(YEAR  (crapgpr.dtrefere),"9999") + ";" + 
               STRING(aux_qtassnet_pf,"99999999") + ";" + /*pf */
               STRING(aux_qtextnet_pf,"99999999") + ";" + 
               STRING(aux_qtbltnet_pf,"99999999") + ";" + 
               REPLACE(STRING(aux_vlbltnet_pf,"zzzzzzzz9.99"), ".", ",") + 
               ";" + STRING(aux_qtpagnet_pf,"999999999") + ";" +
               REPLACE(STRING(aux_vlpagnet_pf,"zzzzzzzz9.99"), ".", ",") + 
               ";" + STRING(aux_qttrsnet_pf,"999999999") + ";" +
               REPLACE(STRING(aux_vltrsnet_pf,"zzzzzzzz9.99"), ".", ",") +
               ";" + STRING(aux_qttednet_pf,"999999999") + ";" +
               REPLACE(STRING(aux_vltednet_pf,"zzzzzzzz9.99"), ".", ",") +
               ";" + STRING(aux_qtassnet_pj,"99999999") + ";" + /* pj */
               STRING(aux_qtextnet_pj,"99999999") + ";" + 
               STRING(aux_qtbltnet_pj,"99999999") + ";" + 
               REPLACE(STRING(aux_vlbltnet_pj,"zzzzzzzz9.99"), ".", ",") + 
               ";" + STRING(aux_qtpagnet_pj,"999999999") + ";" +
               REPLACE(STRING(aux_vlpagnet_pj,"zzzzzzzz9.99"), ".", ",") + 
               ";" + STRING(aux_qttrsnet_pj,"999999999") + ";" +
               REPLACE(STRING(aux_vltrsnet_pj,"zzzzzzzz9.99"), ".", ",") +
               ";" + STRING(aux_qttednet_pj,"999999999") + ";" +
               REPLACE(STRING(aux_vltednet_pj,"zzzzzzzz9.99"), ".", ",") +
               ";" +
               STRING(aux_qttrinet_pf,"999999999") + ";" + 
               REPLACE(STRING(aux_vltrinet_pf,"zzzzzzzz9.99"),".",",")  + ";" +
               STRING(aux_qttrinet_pj,"999999999") + ";" + 
               REPLACE(STRING(aux_vltrinet_pj,"zzzzzzzz9.99"),".",",")  +                    
               ";" + "Visanet;" + STRING(MONTH (crapgpr.dtrefere),"99") + 
               "/" + /* visanet */
               STRING(YEAR  (crapgpr.dtrefere),"9999") + ";" + 
               STRING(aux_qtassvsn,"99999999") + ";" + 
               STRING(aux_qtlanvsn,"99999999") + ";" + 
               REPLACE(STRING(aux_vllanvsn,"zzzzzzzz9.99"), ".", ",") + ";" + 
               /* REDECARD */
               "Redecard;" + STRING(MONTH (crapgpr.dtrefere),"99") + "/" + 
               STRING(YEAR  (crapgpr.dtrefere),"9999") + ";" + 
               STRING(aux_qtassrcd,"99999999") + ";" + 
               STRING(aux_qtlanrcd,"99999999") + ";" + 
               REPLACE(STRING(aux_vllanrcd,"zzzzzzzz9.99"), ".", ",") + ";" + 
               "Ura;" + STRING(MONTH (crapgpr.dtrefere),"99") + "/" +
               STRING(YEAR  (crapgpr.dtrefere),"9999") + ";" + 
               STRING(aux_qtassura,"99999999") + ";" + /* ura */
               STRING(aux_qtconura,"99999999") + ";" +

               "Convenios;" + STRING(MONTH (crapgpr.dtrefere),"99") + "/" +
               STRING(YEAR  (crapgpr.dtrefere),"9999") + ";" +
               STRING(aux_qtfatcnv,"99999999") + ";" + 
               REPLACE(STRING(aux_vlfatcnv,"zzzzzzzz9.99"), ".", ",") + ";" + 
               STRING(aux_qtdebcnv,"99999999") + ";" + 
               REPLACE(STRING(aux_vldebcnv,"zzzzzzzz9.99"), ".", ",") + ";".

                       ASSIGN aux_linha = aux_linha +
               "Seguro Auto;" + STRING(MONTH (crapgpr.dtrefere),"99") + "/" +
               STRING(YEAR  (crapgpr.dtrefere),"9999") + ";" +
               STRING(aux_qtsegaut,"99999999") + ";" + 
               REPLACE(STRING(aux_vllanaut,"zzzzzzzz9.99"), ".", ",") + ";" + 
               REPLACE(STRING(aux_vlrecaut,"zzzzzzzz9.99"), ".", ",") + ";" + 
               REPLACE(STRING(aux_vlrepaut,"zzzzzzzz9.99"), ".", ",") + ";" +

               "Seguro Vida;" + STRING(MONTH (crapgpr.dtrefere),"99") + "/" +
               STRING(YEAR  (crapgpr.dtrefere),"9999") + ";" +
               STRING(aux_qtsegvid,"99999999") + ";" + 
               REPLACE(STRING(aux_vllanvid,"zzzzzzzz9.99"), ".", ",") + ";" + 
               REPLACE(STRING(aux_vlrecvid,"zzzzzzzz9.99"), ".", ",") + ";" + 
               REPLACE(STRING(aux_vlrepvid,"zzzzzzzz9.99"), ".", ",") + ";" +
               STRING(aux_qtincvid,"99999999") + ";" + 
               STRING(aux_qtexcvid,"99999999") + ";" + 

               "Seguro Residencial;" + STRING(MONTH (crapgpr.dtrefere),"99") + 
               "/" +
               STRING(YEAR  (crapgpr.dtrefere),"9999") + ";" +
               STRING(aux_qtsegres,"99999999") + ";" + 
               REPLACE(STRING(aux_vllanres,"zzzzzzzz9.99"), ".", ",") + ";" + 
               REPLACE(STRING(aux_vlrecres,"zzzzzzzz9.99"), ".", ",") + ";" + 
               REPLACE(STRING(aux_vlrepres,"zzzzzzzz9.99"), ".", ",") + ";" +
               STRING(aux_qtincres,"99999999") + ";" + 
               STRING(aux_qtexcres,"99999999") + ";".
        
                       ASSIGN aux_linha = aux_linha + 
               "Participacao;" + 
               STRING(aux_qtassoci,"99999999") + ";" +
               STRING(aux_qtasscot,"zzzzz9") + ";" +
               REPLACE(STRING(aux_percenco,"zzzzz.99"),".",",") + ";" +
               STRING(aux_qtassdeb,"zzzzz9")  + ";" + 
               REPLACE(STRING(aux_percende,"zzzzz.99"),".",",") + ";" +
               STRING(aux_qtassrda,"zzzzz9")  + ";" +
               REPLACE(STRING(aux_percenrd,"zzzzz.99"),".",",") + ";" +
               STRING(aux_qtassrpp,"zzzzz9")  + ";" +
               REPLACE(STRING(aux_percenrp,"zzzzz.99"),".",",") + ";" +
               STRING(aux_qtassepr,"zzzzz9")  + ";" +
               REPLACE(STRING(aux_percenep,"zzzzz.99"),".",",") + ";" +
               STRING(aux_vltotepr,"zzzzzzzzz9.99") + ";" +
               
               STRING(aux_qtassdch,"zzzzz9")  + ";" +
               REPLACE(STRING(aux_percendc,"zzzzz.99"),".",",") + ";" +
               STRING(aux_qtdescch,"zzzzz9")  + ";" +
               STRING(aux_vldescch,"zzzzzzzzz9.99") + ";" +
               
               STRING(aux_qtassdti,"zzzzz9")  + ";" +
               REPLACE(STRING(aux_percendt,"zzzzz.99"),".",",") + ";" +
               STRING(aux_qtdescti,"zzzzz9")  + ";" +
               STRING(aux_vldescti,"zzzzzzzzz9.99") + ";" +

               STRING(aux_qtassesp,"zzzzz9")  + ";" +
               REPLACE(STRING(aux_percenes,"zzzzz.99"),".",",") + ";" +
               STRING(aux_vltotesp,"zzzzzzzz9.99")  + ";" +
               STRING(aux_qtasunet,"zzzzz9")  + ";" +
               STRING(aux_qtasucxa,"zzzzz9")  + ";" +
               STRING(aux_qtchcomp,"zzzzz9")  + ";".
                 
                       /** Caixa On-Line **/
                        ASSIGN aux_linha = aux_linha + 
               "Caixa On-Line;" + STRING(MONTH (crapgpr.dtrefere),"99") + 
               "/" + STRING(YEAR  (crapgpr.dtrefere),"9999") + ";" + 
               STRING(aux_qtassoci,"99999999") + ";" +
               STRING(aux_qttiponl,"zzzzz9")  + ";" +
               STRING(aux_qtchconl,"zzzzz9")  + ";" + 
               STRING(aux_qttricxa_pf,"999999999") + ";" + 
               REPLACE(STRING(aux_vltricxa_pf,"zzzzzzzz9.99"),".",",") + ";" +
               STRING(aux_qttricxa_pj,"999999999") + ";" + 
               REPLACE(STRING(aux_vltricxa_pj,"zzzzzzzz9.99"),".",",") + ";".

                      /** Cartao Magnetico **/
               ASSIGN aux_linha = aux_linha + 
                              "Cartao magnetico;" + 
                              STRING(MONTH (crapgpr.dtrefere),"99") + "/" + 
                              STRING(YEAR (crapgpr.dtrefere),"9999") + ";" +
                              STRING(aux_qtassati, "zzzzz9") + ";" +
                              STRING(aux_qttotcrm, "zzzzz9") + ";" +
                              STRING(aux_qtentcrm, "zzzzz9") + ";" +
                              STRING(aux_vllimcrm, "zzzzzzzz9.99") + ";" +
                              STRING(aux_vlmedcrm, "zzzzzzzz9.99") + ";" +
                              STRING(aux_vlsaqtaa, "zzzzzzzz9.99") + ";" +
                              STRING(aux_mdsaqtaa, "zzzzzzzz9.99") + ";" +
                              STRING(aux_qtpagcxa, "zzzzz9") + ";" +
                              STRING(aux_vlpagcxa, "zzzzzzzz9.99") + ";" +
                              STRING(aux_qttrstaa, "zzzzz9") + ";" +
                              STRING(aux_vltrstaa, "zzzzzzzz9.99") + ";".   


               PUT STREAM str_1 aux_linha FORMAT "x(4000)" SKIP.

               ASSIGN aux_qtassoci = 0
                      aux_qtdatibb = 0 /* bb */
                      aux_vllimcbb = 0
                      aux_vllimdbb = 0
                      aux_qtdsaqbb = 0
                      aux_vlrsaqbb = 0
                      aux_qtdtrsbb = 0
                      aux_vlrtrsbb = 0 
                      aux_qtddebbb = 0
                      aux_vlrdebbb = 0 
                      aux_qtdcrebb = 0
                      aux_vlrcrebb = 0
                      aux_qttransacoes = 0
                      aux_vltransacoes = 0
                      aux_qtassqbb = 0
                      aux_qtasstbb = 0
                      aux_qtasqtbb = 0

                      aux_qtdaticv = 0 /* cecred visa */
                      aux_vllimccv = 0
                      aux_qtdsaqcv = 0
                      aux_qtassqcv = 0 /*AQUI*/
                      aux_vlrsaqcv = 0
                      aux_qtdcrecv = 0
                      aux_vlrcrecv = 0 
                      aux_qtdanucv = 0
                      aux_vlranucv = 0

                      aux_qtasscxa_pf = 0 /* caixa eletronico */
                      aux_qtsaqcxa_pf = 0
                      aux_vlsaqcxa_pf = 0
                      aux_qttrscxa_pf = 0
                      aux_vltrscxa_pf = 0
                      aux_qtpagcxa_pf = 0
                      aux_vlpagcxa_pf = 0
                      aux_qtdepcxa_pf = 0
                      aux_vldepcxa_pf = 0

                      aux_qtasscxa_pj = 0
                      aux_qtsaqcxa_pj = 0
                      aux_vlsaqcxa_pj = 0
                      aux_qttrscxa_pj = 0
                      aux_vltrscxa_pj = 0
                      aux_qtpagcxa_pj = 0
                      aux_vlpagcxa_pj = 0 
                      aux_qtdepcxa_pj = 0
                      aux_vldepcxa_pj = 0


                      aux_qtasscob_pf = 0 /* cobranca */
                      aux_qtdcobbb_pf = 0
                      aux_vlrcobbb_pf = 0
                      aux_qtcobonl_pf = 0
                      aux_vlcobonl_pf = 0
                      aux_qttrfcob_pf = 0
                      aux_vltrfcob_pf = 0
                      aux_qtasscob_pj = 0
                      aux_qtdcobbb_pj = 0
                      aux_vlrcobbb_pj = 0
                      aux_qtcobonl_pj = 0
                      aux_vlcobonl_pj = 0
                      aux_qttrfcob_pj = 0
                      aux_vltrfcob_pj = 0
    
                      aux_qtassnet_pf = 0 /* internet */
                      aux_qtextnet_pf = 0
                      aux_qtbltnet_pf = 0
                      aux_vlbltnet_pf = 0
                      aux_qtpagnet_pf = 0
                      aux_vlpagnet_pf = 0
                      aux_qttrsnet_pf = 0
                      aux_vltrsnet_pf = 0
                      aux_qttednet_pf = 0
                      aux_vltednet_pf = 0

                      aux_qtassnet_pj = 0
                      aux_qtextnet_pj = 0
                      aux_qtbltnet_pj = 0
                      aux_vlbltnet_pj = 0
                      aux_qtpagnet_pj = 0
                      aux_vlpagnet_pj = 0
                      aux_qttrsnet_pj = 0
                      aux_vltrsnet_pj = 0
                      aux_qttednet_pj = 0
                      aux_vltednet_pj = 0

                      aux_qtassvsn    = 0 /* visanet */
                      aux_qtlanvsn    = 0
                      aux_vllanvsn    = 0

                      aux_qtassrcd    = 0 /* redecard */
                      aux_qtlanrcd    = 0
                      aux_vllanrcd    = 0

                      aux_qtassura    = 0 /* URA */
                      aux_qtconura    = 0

                      /*convenios */
                      aux_qtfatcnv = 0
                      aux_vlfatcnv = 0
                      aux_qtdebcnv = 0
                      aux_vldebcnv = 0

                      /* seguro auto */
                      aux_qtsegaut = 0
                      aux_vllanaut = 0
                      aux_vlrecaut = 0
                      aux_vlrepaut = 0

                      /* seguro vida */
                      aux_qtsegvid = 0
                      aux_vllanvid = 0
                      aux_vlrecvid = 0
                      aux_vlrepvid = 0
                      aux_qtincvid = 0
                      aux_qtexcvid = 0

                      /* seguro residencia */
                      aux_qtsegres = 0
                      aux_vllanres = 0
                      aux_vlrecres = 0
                      aux_vlrepres = 0
                      aux_qtincres = 0
                      aux_qtexcres = 0

                      /* beneficio inss */
                      aux_qtcoopbe = 0
                      aux_vlcoopbe = 0
                      aux_qtncoobe = 0
                      aux_vlncoobe = 0

                      /* cartoes */
                              aux_percenbb = 0
                              aux_percencv = 0
                              aux_saldoBBC = 0
                              aux_saldobbd = 0
                              aux_vlusobbc = 0
                              aux_vlusobbd = 0
                              aux_vllimcon = 0
            
                              /* participacao */ 
                              aux_qtasscot = 0
                              aux_qtassdeb = 0
                              aux_qtassrpp = 0
                              aux_qtassepr = 0
                              aux_vltotepr = 0
                              aux_qtassesp = 0
                              aux_vltotesp = 0
                              aux_qtassrda = 0
                              aux_qtasunet = 0
                              aux_qtasucxa = 0
                              aux_qtassdch = 0
                              aux_qtassdti = 0
                              aux_qtdescch = 0
                              aux_qtdescti = 0
                              aux_vldescch = 0
                              aux_vldescti = 0
                              aux_qtchcomp = 0
                              aux_percenco = 0
                              aux_percende = 0
                              aux_percenrd = 0
                              aux_percenrp = 0
                              aux_percenep = 0
                              aux_percenes = 0
                              aux_percendc = 0
                              aux_percendt = 0
            
                              /* Caixa On-Line */ 
                              aux_qttiponl = 0
                              aux_qtchconl = 0

                              /* DDA */
                              aux_qtcoodda = 0
                              aux_qtbpgdda = 0
                              aux_vlbpgdda = 0
                           
                              /* Cobranca Registrada*/
                              aux_qtcpfcbr = 0
                              aux_qtbpfcbb = 0
                              aux_qtbpfcec = 0
                              aux_qtbpftbb = 0
                              aux_vlbpftbb = 0
                              aux_qtbpftce = 0
                              aux_vlbpftce = 0
                              aux_qtbpflcm = 0
                              aux_vlbpflcm = 0
                              aux_qtbpflco = 0
                              aux_vlbpflco = 0
                              aux_vlbpfdda = 0
                              aux_qtcpjcbr = 0
                              aux_qtcpjcbb = 0
                              aux_qtbpjcec = 0
                              aux_qtbpjtbb = 0
                              aux_vlbpjtbb = 0
                              aux_qtbpjtce = 0
                              aux_vlbpjtce = 0
                              aux_qtbpjlcm = 0
                              aux_vlbpjlcm = 0
                              aux_qtbpjlco = 0
                              aux_vlbpjlco = 0
                              aux_vlbpjdda = 0.
                       
                       ASSIGN aux_qtassati = 0
                              aux_qttotcrm = 0
                              aux_qtentcrm = 0
                              aux_vllimcrm = 0
                              aux_vlmedcrm = 0
                              aux_vlsaqtaa = 0
                              aux_mdsaqtaa = 0
                              aux_qtpagcxa = 0
                              aux_vlpagcxa = 0
                              aux_qttrstaa = 0
                              aux_vltrstaa = 0.
                              
                   END.
        END.

        OUTPUT STREAM str_1 CLOSE.
        MESSAGE "Foram exportadas " + STRING (aux_contalin) + " linhas!". 
        PAUSE.
    END.
    ELSE
    DO:
        MESSAGE "Aguarde, gerando arquivo...".

        ASSIGN aux_header = crapcop.nmrescop + ";".
        PUT STREAM str_1 aux_header FORMAT "x(12)" SKIP.

        ASSIGN aux_datini = tel_dtinicio
               aux_datfim = tel_dttermin
               aux_header = "Periodo: " + STRING(aux_datini, "99/99/9999") +
                            " a " + STRING(aux_datfim, "99/99/9999") + ";".
        PUT STREAM str_1 aux_header FORMAT "x(33)" SKIP.


        ASSIGN aux_header = "PA;Operador;Nome;Abertura de Conta;"
                          + "Plano de Cotas;Poup.Programada;"
                          + "Aplicacao RDC;Lim.Credito;Lim.Dsct.CHQ;"
                          + "Lim.Dsct.TIT;Cartao Credito;Seguro Res.;"
                          + "Seguro Vida;Cobrança Reg.;Cobrança S/Reg.;DDA;".

        PUT STREAM str_1 aux_header FORMAT "x(226)" SKIP.

        FOR EACH crapope WHERE 
                 crapope.cdcooper = crapcop.cdcooper AND
                 (tel_cdagenci = 0                   OR
                  (crapope.cdagenci = tel_cdagenci   AND
                  tel_cdagenci <> 0))                AND
                 crapope.cdsitope = 1     /*operadores ativos*/
                 NO-LOCK BY crapope.cdagenci:

            /* Desconsiderar operador "1 - SUPER USUARIO" */ 
            IF  crapope.cdoperad = "1" THEN
                NEXT.
            
            /* Abertura de Conta */
            FOR EACH craplgm WHERE craplgm.cdcooper = crapcop.cdcooper AND
                                   craplgm.dttransa >= aux_datini      AND
                                   craplgm.dttransa <= aux_datfim      AND
                                   craplgm.cdoperad = crapope.cdoperad AND
                                   craplgm.dstransa =
                                  "Grava dados do Associado - Opcao[I] Incluir"
                                   NO-LOCK:

                ASSIGN aux_qtabecon = aux_qtabecon + 1.

            END.

            /* Plano de Cotas */
            FOR EACH craplgm WHERE craplgm.cdcooper = crapcop.cdcooper AND
                                   craplgm.dttransa >= aux_datini      AND
                                   craplgm.dttransa <= aux_datfim      AND
                                   craplgm.cdoperad = crapope.cdoperad AND
                                   craplgm.dstransa =
                                   "Cadastrar novo plano de capital"
                                   NO-LOCK:

                ASSIGN aux_qtplcota = aux_qtplcota + 1.

            END.

            /* Poupanca Programada */
            FOR EACH craplgm WHERE craplgm.cdcooper = crapcop.cdcooper AND
                                   craplgm.dttransa >= aux_datini      AND
                                   craplgm.dttransa <= aux_datfim      AND
                                   craplgm.cdoperad = crapope.cdoperad AND
                                   craplgm.dstransa =
                                   "Incluir poupanca programada"
                                   NO-LOCK:

                ASSIGN aux_qtpoupro = aux_qtpoupro + 1. 

            END.

            /* Aplicacao RDC */
            FOR EACH craplgm WHERE craplgm.cdcooper = crapcop.cdcooper AND
                                   craplgm.dttransa >= aux_datini      AND
                                   craplgm.dttransa <= aux_datfim      AND
                                   craplgm.cdoperad = crapope.cdoperad AND
                                   craplgm.dstransa =
                                   "Incluir nova aplicacao"
                                   NO-LOCK:

                ASSIGN aux_qtaplrdc = aux_qtaplrdc + 1.

            END.

            /* Limite de Credito */
            FOR EACH craplgm WHERE craplgm.cdcooper = crapcop.cdcooper AND
                                   craplgm.dttransa >= aux_datini      AND
                                   craplgm.dttransa <= aux_datfim      AND
                                   craplgm.cdoperad = crapope.cdoperad AND
                                   craplgm.dstransa =
                                   "Cadastrar novo limite de credito"
                                   NO-LOCK:

                ASSIGN aux_qtlimcre = aux_qtlimcre + 1.

            END.

           /* Desconto de Cheque - Incluido LOG para esta operacao em 24/04 */ 
            
           FOR EACH craplgm WHERE craplgm.cdcooper = crapcop.cdcooper AND
                                  craplgm.dttransa >= aux_datini      AND
                                  craplgm.dttransa <= aux_datfim      AND
                                  craplgm.cdoperad = crapope.cdoperad AND
                                  craplgm.dstransa MATCHES
                                  "Incluir limite*desconto de cheques."
                                  NO-LOCK:

               ASSIGN aux_qtdescch = aux_qtdescch + 1.

           END.

           /* Desconto de Titulo  */
           FOR EACH craplgm WHERE craplgm.cdcooper = crapcop.cdcooper AND
                                  craplgm.dttransa >= aux_datini      AND
                                  craplgm.dttransa <= aux_datfim      AND
                                  craplgm.cdoperad = crapope.cdoperad AND
                                  craplgm.dstransa MATCHES
                                  "Incluir limite*desconto de titulos."
                                  NO-LOCK:

               ASSIGN aux_qtdestit = aux_qtdestit + 1.

           END.

           /* Cartao de credito */
           FOR EACH craplgm WHERE craplgm.cdcooper = crapcop.cdcooper AND
                                  craplgm.dttransa >= aux_datini      AND
                                  craplgm.dttransa <= aux_datfim      AND
                                  craplgm.cdoperad = crapope.cdoperad AND
                                  craplgm.dstransa =
                                  "Cadastrar novo cartao de credito."
                                  NO-LOCK:

               ASSIGN aux_qtcarcre = aux_qtcarcre + 1.

           END.

           /* Seguro Residencial (Desenvolvido LOG e liberado em 20/03) */
           FOR EACH craplgm WHERE craplgm.cdcooper = crapcop.cdcooper AND
                                  craplgm.dttransa >= aux_datini      AND
                                  craplgm.dttransa <= aux_datfim      AND
                                  craplgm.cdoperad = crapope.cdoperad AND
                                  craplgm.dstransa =
                          "Efetivado o seguro do tipo: SEGURO RESIDENCIAL."
                                  NO-LOCK:

               ASSIGN aux_qtsegres = aux_qtsegres + 1.


           END.

           /* Seguro Vida (Desenvolvido LOG e liberado em 20/03) */
           FOR EACH craplgm WHERE craplgm.cdcooper = crapcop.cdcooper AND
                                  craplgm.dttransa >= aux_datini      AND
                                  craplgm.dttransa <= aux_datfim      AND
                                  craplgm.cdoperad = crapope.cdoperad AND
                                  craplgm.dstransa =
                          "Efetivado o seguro do tipo: SEGURO DE VIDA."
                                  NO-LOCK:

               ASSIGN aux_qtsegvid = aux_qtsegvid + 1.

           END.

           /* Cobranca Registrada/Sem Registro - Estava logando igualmente
              Inclusao e Alteracao =>  "Incluir/Alterar convenio de cobranca.".
              Em 24/04 modificamos o log:
              Inclusao  - "Incluir convenio de cobranca zzzzzzz9 ."
              Alteracao - "Alterar convenio de cobranca zzzzzzz9 ."
           */
           FOR EACH craplgm WHERE craplgm.cdcooper = crapcop.cdcooper AND
                                  craplgm.dttransa >= aux_datini      AND
                                  craplgm.dttransa <= aux_datfim      AND
                                  craplgm.cdoperad = crapope.cdoperad AND
                                  craplgm.dstransa MATCHES
                                  "Incluir convenio de cobranca*."
                                  NO-LOCK:

               /* Verificar o TIPO DE COBRANCA  */
               FIND crapcco WHERE
                    crapcco.cdcooper = crapcop.cdcooper AND
                    crapcco.nrconven = INT(SUBSTRING(craplgm.dstransa,30,8))
                    NO-LOCK NO-ERROR.

               IF AVAIL crapcco THEN
                   IF crapcco.flgregis THEN /* Cobranca com registro*/
                   DO:
                       ASSIGN aux_qtcobreg = aux_qtcobreg + 1.

                   END.
                   ELSE   /* Cobranca sem registro */
                   DO:
                       ASSIGN aux_qtcobsem = aux_qtcobsem + 1.
                   END.
           END.

           /* DDA (Operacao realizada no InternetBank - Operador 996) */
           FOR EACH craplgm WHERE craplgm.cdcooper = crapcop.cdcooper AND
                                  craplgm.dttransa >= aux_datini      AND
                                  craplgm.dttransa <= aux_datfim      AND
                                  craplgm.cdoperad = crapope.cdoperad AND
                                  craplgm.dstransa =
                                  "Efetuar a inclusao do titular no DDA."
                                  NO-LOCK:

               ASSIGN aux_qtincdda = aux_qtincdda + 1.

           END.

           ASSIGN aux_linha = STRING(crapope.cdagenci) + ";" +
                              crapope.cdoperad         + ";" + 
                              crapope.nmoperad         + ";" +
                              STRING(aux_qtabecon)     + ";" + 
                              STRING(aux_qtplcota)     + ";" + 
                              STRING(aux_qtpoupro)     + ";" + 
                              STRING(aux_qtaplrdc)     + ";" + 
                              STRING(aux_qtlimcre)     + ";" + 
                              STRING(aux_qtdescch)     + ";" + 
                              STRING(aux_qtdestit)     + ";" + 
                              STRING(aux_qtcarcre)     + ";" + 
                              STRING(aux_qtsegres)     + ";" + 
                              STRING(aux_qtsegvid)     + ";" + 
                              STRING(aux_qtcobreg)     + ";" + 
                              STRING(aux_qtcobsem)     + ";" + 
                              STRING(aux_qtincdda)     + ";".

           PUT STREAM str_1 aux_linha FORMAT "x(130)" SKIP.

           ASSIGN aux_qtabecon = 0
                  aux_qtplcota = 0
                  aux_qtpoupro = 0 
                  aux_qtaplrdc = 0
                  aux_qtlimcre = 0
                  aux_qtdescch = 0
                  aux_qtdestit = 0
                  aux_qtcarcre = 0
                  aux_qtsegres = 0
                  aux_qtsegvid = 0
                  aux_qtcobreg = 0
                  aux_qtcobsem = 0
                  aux_qtincdda = 0.

        END.

        OUTPUT STREAM str_1 CLOSE.

        HIDE MESSAGE NO-PAUSE.

        MESSAGE "Arquivo gerado com sucesso!".
        PAUSE.

    END.

END.

RUN fontes/fimprg.p.

/* .......................................................................... */


