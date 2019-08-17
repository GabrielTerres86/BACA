/* inc0031107 Update de relatórios para repostagem na intranet (Carlos) */
UPDATE crapslr r
   SET r.dtiniger = ''
      ,r.dtfimger = ''
      ,r.dserrger = ''
      ,r.flgerado = 'N'
 WHERE r.cdrelato IN
       (414, 526, 007, 227, 291, 325, 345, 354, 380, 391, 400, 593, 594)
   AND r.dtmvtolt = '16/01/2019'
   AND r.flimprim = 'S';
COMMIT;
