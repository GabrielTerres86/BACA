DECLARE
   vr_dsconteudo VARCHAR2(1000);
BEGIN
   FOR rw_crappco IN (SELECT b.cdcooper
                        FROM cecred.crappat a,
                             cecred.crappco b
                       WHERE a.NMPARTAR = 'LINFIN_IMOBILIARIO'
                         AND a.cdpartar = b.cdpartar) LOOP
                         
       vr_dsconteudo := '';
       IF rw_crappco.cdcooper = 1 THEN
          vr_dsconteudo := '16B,10000,100;161,10000,100;11B,10000,100;110,10000,100;02B,10000,100';
       ELSIF rw_crappco.cdcooper = 2 THEN
          vr_dsconteudo := '16B,10000,100;161,10000,100;11B,10000,100;110,10000,100;02B,10000,100';
       ELSIF rw_crappco.cdcooper = 7 THEN
          vr_dsconteudo := '16B,10000,100;161,10000,100;11B,10000,100;110,10000,100;02B,10000,100';
       ELSIF rw_crappco.cdcooper = 11 THEN
          vr_dsconteudo := '16B,10000,100;161,10000,100;11B,10000,100;110,10000,100;02B,10000,100';
       ELSIF rw_crappco.cdcooper = 16 THEN
          vr_dsconteudo := '16B,10000,100;161,10000,100;11B,10000,100;110,10000,100;02B,10000,100';  
       END IF;
             
       UPDATE cecred.crappco a
          SET a.dsconteu = vr_dsconteudo
        WHERE a.cdpartar = 118;
 
  END LOOP;
                             
  COMMIT;
EXCEPTION
   WHEN OTHERS THEN
   ROLLBACK;
END; 
