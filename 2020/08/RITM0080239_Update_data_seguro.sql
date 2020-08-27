UPDATE tbseg_contratos SET DTINICIO_VIGENCIA = TO_DATE('07/12/2019','DD/MM/YYYY'), DTTERMINO_VIGENCIA = TO_DATE('07/12/2020','DD/MM/YYYY')   
                                             where  nrapolice = '1102431177442' and idcontrato = 69547 and cdcooper = 1 and NRDCONTA = 9857389;
UPDATE tbseg_contratos SET indsituacao = 'C'  where nrapolice = '1102431176479' and idcontrato = 69261 and cdcooper = 1 and NRDCONTA = 9857389;
commit;