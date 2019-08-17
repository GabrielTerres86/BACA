UPDATE crapblj blj
SET blj.cdopddes = 1                             /* operador desbloqueio    */
, blj.dtblqfim = '28/02/2019'                    /* data desbloqueio        */
, blj.nrofides = nroficio                        /* nro oficio desbloqueio  */
, blj.dtenvdes = '28/02/2019'                    /*dt envio resp desbloqueio*/
, blj.dsinfdes = 'Desbloqueio/Falha de sistema'  /*inf adicional desbloqueio*/
, blj.fldestrf = 0                               /*desbloqueio para transf. */
WHERE blj.cdcooper = 9
  AND blj.nrdconta = 67326
  AND nroficio IN ('2019000144134000013', '2019000149541600019')
   AND vlbloque = 0;

COMMIT;
