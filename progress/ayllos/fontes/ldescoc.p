/* .............................................................................

   Programa: Fontes/ldescoc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                         Ultima atualizacao:27/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela LDESCO.

   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
    
               17/09/2008 - Incluir campo Tipo de Desconto (Gabriel).
            
............................................................................. */

{ includes/var_online.i }

{ includes/var_ldesco.i }   /*  Contem as definicoes das variaveis e forms  */

FIND crapldc WHERE crapldc.cdcooper = glb_cdcooper   AND
                   crapldc.cddlinha = tel_cddlinha   AND 
                   crapldc.tpdescto = IF   tel_tpdescto = "C"  THEN 2
                                      ELSE 3 
                   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapldc   THEN
     DO:
         glb_cdcritic = 363.
         NEXT-PROMPT tel_cddlinha WITH FRAME f_ldesco.
         NEXT.
     END.

ASSIGN tel_dsdlinha = crapldc.dsdlinha

       tel_dssitlcr = IF crapldc.flgstlcr THEN "LIBERADA" ELSE "BLOQUEADA"

       tel_txmensal = crapldc.txmensal
       tel_txdiaria = crapldc.txdiaria
       tel_txjurmor = crapldc.txjurmor
       tel_flgtarif = crapldc.flgtarif
       tel_nrdevias = crapldc.nrdevias
       
       tel_dssitlcr = IF crapldc.flgsaldo
                         THEN tel_dssitlcr + " COM SALDO"
                         ELSE tel_dssitlcr + " SEM SALDO"
                      
       tel_tpdescto = IF  crapldc.tpdescto = 2   THEN
                          "C"
                      ELSE
                          "T"
                      
       tel_dsdescto = IF   crapldc.tpdescto = 2   THEN
                           " - Cheques" 
                      ELSE
                      IF   crapldc.tpdescto = 3   THEN
                           " - Titulos"
                      ELSE
                           " - Nao cadastrada.".   

DISPLAY tel_txmensal tel_txdiaria tel_txjurmor tel_dsdlinha 
        tel_flgtarif tel_nrdevias tel_dssitlcr tel_tpdescto 
        tel_dsdescto WITH FRAME f_ldesco.

/* .......................................................................... */
