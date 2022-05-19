DECLARE
BEGIN
UPDATE CECRED.tbgen_analise_fraude_param
   SET VLCORTE_ENVIO_TOPAZ = 59
 WHERE cdoperacao = 16;
 
COMMIT;
END;
/