--ritm0024164 corrigir o tipo de pessoa para jurídica (Carlos)
UPDATE craptvl
   SET flgpescr = 2
 WHERE tvl.cdcooper = 2
   AND tvl.nrdconta = 704580
   AND tvl.vldocrcb = 325
   AND tvl.dtmvtolt = '20/04/2016'
   AND tvl.nrdocmto = 61783;
         
UPDATE craptvl
   SET flgpescr = 2
 WHERE tvl.cdcooper = 2
   AND tvl.nrdconta = 704580
   AND tvl.vldocrcb = 440
   AND tvl.dtmvtolt = '27/06/2016'
   AND tvl.nrdocmto = 68036;
   
COMMIT;
