/* .............................................................................

   Programa: Fontes/lcredic.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/94.                          Ultima atualizacao: 27/05/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela LCREDI.

   Alteracoes: 14/10/94 - Alterado para inclusao de novos parametros para as
                          linhas de credito: taxa minima e maxima e o sinali-
                          zador de linha com saldo devedor.
                          
               20/12/2002 - Incluir campo Valor Tarifa Especial (Junior).

               24/03/2004 - Incluido na tela campo Dias Carencia(Mirtes).

               11/06/2004 - Incluido na tela campos - Valor Maximo Linha e
                                         Valor Maximo Associado (Evandro).

               28/06/2004 - Removido - colocado em comentarios - o campo Valor
                            Maximo Linha - tel_vlmaxdiv (Evandro).
                            
               10/08/2004 - Incluido campo tel_vlmaxasj - Valor Maximo Pessoa
                            Juridica (Evandro).             
                                         
               30/08/2004 - Tratamento para desconto de emprestimo consig.
                            (Julio)

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               17/03/2006 - Excluido campo "Conta ADM" , e acrescentado
                            tel_flgcrcta (Diego).

               28/08/2007 - Adicionado campo cdusolcr(Guilherme).

               24/06/2009 - Incluido campo Operacao (Gabriel). 

               22/07/2009 - Tratar tel_cdusolcr com tipo 2 - EPR/BOLETOS.
                            (Fernando).
               
               16/12/2009 - Alterado campo tel_dsoperac (Elton).  
               
               15/03/2010 - Incluido o campo que ira indicar o tempo que o 
                            emprestimo permanecera na atenda apos sua 
                            liquidacao (Gati -Daniel).   
                
               16/03/2010 - incluido o campo que ira conter a origem do
                            recurso (gati - Daniel)                          

               15/06/2010 - incluido o campo que determina se a impressao da
                            declaracao (Sandro - gati)        
                            
               19/07/2010 - Incluir campo 'Listar na proposta' (Gabriel).    
               
               16/06/2011 - Inclusao do campo craplcr.perjurmo (Adriano). 
               
               23/05/2012 - Adicionado campo de Tarifa IOF (Lucas).
               
               10/10/2012 - Incluir campos de Modalidade e Submodalidade
                            (Gabriel).   
                            
               11/10/2012 - Incluir Campo flgreneg na tela (Lucas R.)
               
               28/05/2013 - Softdesk 66547 Incluir Campo flgrefin na tela 
                            (Carlos)
                            
               29/01/2015 - (Chamado 248647)Inclusao do novo campo de
                            consulta automatizada (Tiago Castro - RKAM).
                            
               24/02/2015 - Novo campo qtrecpro (Jonata-RKAM).     
               
               26/03/2015 - Ajuste no campo inconaut (Jonata-RKAM).   
               
               27/05/2015 - Incluir novo frame Projeto cessao de Credito (James)
............................................................................. */

{ includes/var_online.i }
{ includes/var_lcredi.i }   

FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper   AND
                   craplcr.cdlcremp = tel_cdlcremp   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craplcr   THEN
     DO:
         glb_cdcritic = 363.
         NEXT-PROMPT tel_cdlcremp WITH FRAME f_lcredi.
         NEXT.
     END.

ASSIGN tel_dslcremp = craplcr.dslcremp

       tel_dssitlcr = IF craplcr.flgstlcr THEN "LIBERADA" ELSE "BLOQUEADA"

       tel_nrgrplcr = craplcr.nrgrplcr
       tel_txmensal = craplcr.txmensal
       tel_txdiaria = craplcr.txdiaria * 100
       tel_txjurfix = craplcr.txjurfix
       tel_txjurvar = craplcr.txjurvar
       tel_txpresta = craplcr.txpresta
       tel_qtdcasas = craplcr.qtdcasas
       tel_nrinipre = craplcr.nrinipre
       tel_nrfimpre = craplcr.nrfimpre
       tel_txbaspre = craplcr.txbaspre
       tel_qtcarenc = craplcr.qtcarenc
       tel_flgtarif = craplcr.flgtarif
       tel_flgtaiof = craplcr.flgtaiof
       tel_vltrfesp = craplcr.vltrfesp
       tel_flgcrcta = craplcr.flgcrcta
       tel_vlmaxass = craplcr.vlmaxass
       tel_vlmaxasj = craplcr.vlmaxasj    
       tel_perjurmo = craplcr.perjurmo
       
       tel_txminima = craplcr.txminima
       tel_txmaxima = craplcr.txmaxima

       tel_tpctrato = craplcr.tpctrato
       tel_tpdescto = craplcr.tpdescto
       tel_nrdevias = craplcr.nrdevias
       tel_cdusolcr = craplcr.cdusolcr

       tel_tplcremp = craplcr.tplcremp
       tel_dstipolc = ENTRY(craplcr.tplcremp,aux_dstipolc)

       tel_dssitlcr = IF craplcr.flgsaldo
                         THEN tel_dssitlcr + " COM SALDO"
                         ELSE tel_dssitlcr + " SEM SALDO"

       tel_dsoperac = craplcr.dsoperac
       tel_origrecu = craplcr.dsorgrec
       tel_manterpo = craplcr.nrdialiq
       tel_flgimpde = craplcr.flgimpde
       tel_flglispr = craplcr.flglispr
       tel_flgreneg = craplcr.flgreneg
       tel_flgrefin = craplcr.flgrefin
       tel_qtrecpro = craplcr.qtrecpro
       tel_consaut  = (craplcr.inconaut = 0)
       tel_cdfinemp = 0
       tel_flgdisap = craplcr.flgdisap
       tel_flgcobmu = craplcr.flgcobmu
       tel_flgsegpr = craplcr.flgsegpr
       tel_cdhistor = craplcr.cdhistor
       aux_contador = 0.

FIND gnmodal WHERE gnmodal.cdmodali = craplcr.cdmodali NO-LOCK NO-ERROR.

IF   AVAIL gnmodal    THEN 
     ASSIGN tel_cdmodali = gnmodal.cdmodali + "-" + gnmodal.dsmodali.
ELSE
     ASSIGN tel_cdmodali = "".

FIND gnsbmod WHERE gnsbmod.cdmodali = craplcr.cdmodali AND
                   gnsbmod.cdsubmod = craplcr.cdsubmod
                   NO-LOCK NO-ERROR.

IF   AVAIL gnsbmod   THEN
     ASSIGN tel_cdsubmod = gnsbmod.cdsubmod + "-" + gnsbmod.dssubmod.
ELSE
     ASSIGN tel_cdsubmod = "".

/*  Descricao do modelo do contrato  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "CTRATOEMPR"   AND
                   craptab.tpregist = tel_tpctrato   NO-LOCK
                   USE-INDEX craptab1 NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     tel_dsctrato = "NAO CADASTRADO".
ELSE
     tel_dsctrato = craptab.dstextab.

IF   tel_tpdescto = 1   THEN
     tel_dsdescto = "C/C".
ELSE
     tel_dsdescto = "CONSIG. FOLHA".
     
CASE tel_cdusolcr:
     WHEN 0 THEN tel_dsusolcr = "NORMAL".
     WHEN 1 THEN tel_dsusolcr = "MICRO CREDITO".
     WHEN 2 THEN tel_dsusolcr = "EPR/BOLETOS".
END.

DISPLAY tel_dslcremp
        WITH FRAME f_lcredi.

PAUSE 0.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    DISPLAY tel_dsoperac
            tel_tplcremp tel_dstipolc tel_flgtarif tel_vltrfesp tel_flgtaiof
            tel_flgcrcta tel_tpctrato tel_dsctrato tel_nrdevias 
            tel_flgrefin tel_flgreneg
            tel_cdusolcr tel_dssitlcr tel_tpdescto tel_dsdescto tel_dsusolcr 
            tel_origrecu tel_manterpo tel_flgimpde tel_flglispr
            tel_cdmodali tel_cdsubmod 
            WITH FRAME f_lcredi_2.

    MESSAGE "Tecle <Enter> para continuar ou <End> para encerrar.".

    WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
         DO:
             HIDE MESSAGE NO-PAUSE.
             LEAVE.
         END.
                 
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
       DISPLAY tel_txjurfix tel_txjurvar tel_txpresta tel_txmensal tel_txdiaria
               tel_txminima tel_txmaxima tel_perjurmo tel_qtdcasas tel_nrinipre
               tel_nrfimpre tel_txbaspre tel_nrgrplcr tel_qtcarenc tel_vlmaxass 
               tel_vlmaxasj tel_consaut  tel_qtrecpro
               WITH FRAME f_lcredi_3.

       LEAVE.

    END.

    MESSAGE "Tecle <Enter> para continuar ou <End> para encerrar.".

    WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
         DO:
             HIDE MESSAGE NO-PAUSE.
             LEAVE.
         END.
                 
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
       DISPLAY tel_flgdisap
               tel_flgcobmu
               tel_flgsegpr
               tel_cdhistor
               WITH FRAME f_lcredi_4.

       MESSAGE "Tecle <Enter> para continuar ou <End> para voltar.".

       WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
       
       LEAVE.

    END.

    HIDE MESSAGE NO-PAUSE.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
         NEXT.
    
    LEAVE.

END. /* Fim do DO WHILE TRUE */


/* .......................................................................... */




