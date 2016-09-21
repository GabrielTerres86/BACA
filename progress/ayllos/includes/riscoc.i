/* .............................................................................

   Programa: Fontes/riscoc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete                       Ultima Alteracao: 22/10/2008
   Data    : Junho/2001

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela RISCO.

   Alteracoes: 18/09/2002 - Nao esta zerando totais (Margarete).
   
               09/04/2003 - Mostrar pessoas fisicas na Concredi (Deborah).
               
               17/11/2003 - Alt. p/para gravar conforme layout Docto 3020,
                            gravando tambem inddocto 0(Docto 3010) (Mirtes).
                            
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               22/10/2008 - Incluir prejuizo a +48M ate 60M (Magui).
               
               09/07/2014 - Troca do inddocto = 0 (3010) para inddocto = 1
                            (3040) - (Marcos-Supero) 
               
............................................................................. */
 ASSIGN aux_vldivida = 0  
        aux_rsvec180 = 0 
        aux_rsvec360 = 0
        aux_rsvec999 = 0
        aux_rsdiv060 = 0 
        aux_rsdiv180 = 0
        aux_rsdiv360 = 0
        aux_rsdiv999 = 0 
        aux_rsprjano = 0 
        aux_rsprjaan = 0
        aux_rsprjant = 0.

 ASSIGN tel_ttvec180 = 0
        tel_ttvec360 = 0
        tel_ttvec999 = 0.

FOR EACH crapvri WHERE crapvri.cdcooper  = glb_cdcooper  AND
                       crapvri.dtrefere  = tel_dtrefere  NO-LOCK:

    FIND crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                       crapass.nrdconta = crapvri.nrdconta  NO-LOCK NO-ERROR.
    
    IF   glb_cdcooper = 4 THEN
         .
    ELSE
         IF   NOT AVAIL crapass OR
              crapass.inpessoa <> 2 THEN
              NEXT.

    RUN soma_valores.

END.          
                   
ASSIGN tel_ttvec180 =  aux_rsvec180
       tel_ttvec360 =  aux_rsvec360
       tel_ttvec999 =  aux_rsvec999.
       
DISPLAY tel_ttvec180 tel_ttvec360 tel_ttvec999
        WITH FRAME f_total.
          
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   HIDE MESSAGE NO-PAUSE.
   OPEN QUERY bcrapris-q 
        FOR EACH  crapris WHERE crapris.cdcooper = glb_cdcooper     AND
                                crapris.dtrefere = tel_dtrefere     AND
                                crapris.inddocto = 1                AND
                              ((crapris.inpessoa = 2                AND 
                                glb_cdcooper    <> 4)               OR
                               (glb_cdcooper     = 4))              NO-LOCK,
             
             /*EACH crapass OF crapris NO-LOCK.*/
            EACH crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                               crapass.nrdconta = crapris.nrdconta  NO-LOCK.
         
            ENABLE bcrapris-b WITH FRAME f_lancamentos.

            WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
              
END.

/* .......................................................................... */

