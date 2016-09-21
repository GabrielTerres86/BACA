/* ..........................................................................

   Programa: Includes/crps120_9.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED           
   Autor   : Deborah/Edson
   Data    : Junho/97.                           Ultima atualizacao: 16/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Fazer leitura de avisos para atender aos programas
               crps120_3.p e crps129.p

   ATENCAO: SEMPRE QUE FOR ALTERADO COMPILE CRPS129 E CRPS120_3.

   Alteracoes: 22/09/97 - Alterado para passar o convenio 10 para peso 2 (Edson)

               14/11/97 - Tratar convenios 18 e 19 peso 2 (Odair)
               
               27/07/2001 - Tratar historico 341 - Seguro de Vida (Junior).
               
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
............................................................................ */

FOR EACH crapavs WHERE
         crapavs.cdcooper = glb_cdcooper   AND
         crapavs.nrdconta = aux_nrdconta   AND
         crapavs.tpdaviso = 1              AND
         crapavs.dtrefere = aux_dtrefere   AND
         crapavs.insitavs = 0
         BY IF CAN-DO(aux_lshstsau,
               STRING(crapavs.cdhistor))  THEN "1"
            ELSE
            IF CAN-DO(aux_lshstfun,                     /*  Convenio 18 e 19  */
               STRING(crapavs.cdhistor))  THEN "2"
            ELSE
            IF CAN-DO(aux_lshstdiv,                     /*  Convenio 10 e 15  */
               STRING(crapavs.cdhistor))  THEN "3"
            ELSE
            IF crapavs.cdhistor = 108   THEN "4"
            ELSE
            IF crapavs.cdhistor = 127   THEN "7"
            ELSE
            IF (crapavs.cdhistor = 160   OR
                crapavs.cdhistor = 175   OR
                crapavs.cdhistor = 199   OR
                crapavs.cdhistor = 341)  THEN "8"
            ELSE "6"
            BY crapavs.cdhistor
               BY crapavs.dtintegr:

/* .......................................................................... */

