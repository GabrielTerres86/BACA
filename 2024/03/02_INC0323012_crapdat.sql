DECLARE

  vr_data_origen  DATE := to_date('09/02/2024', 'DD/MM/RRRR');
  vr_data_destino DATE := to_date('08/02/2024', 'DD/MM/RRRR');

BEGIN
  
  UPDATE cecred.crapdat t
    SET t.dtmvcentral = vr_data_destino
  WHERE t.dtmvcentral = vr_data_origen;
  
 COMMIT;

END;  
