-- Created on 31/01/2019 by T0032012 
declare 
  vr_dtlibchq_base DATE := '31/01/2019';
  vr_dtlibchq DATE;
begin
  
  FOR rw_craplcm IN (SELECT *
                FROM craplcm l
               WHERE l.cdhistor = 2662
                 AND l.dtmvtolt >= '01/12/2018'
                 AND NOT EXISTS
               (SELECT 1
                        FROM crapdpb dpb
                       WHERE dpb.cdcooper = l.cdcooper 
                         AND dpb.dtmvtolt = l.dtmvtolt 
                         AND dpb.cdagenci = l.cdagenci 
                         AND dpb.cdbccxlt = l.cdbccxlt 
                         AND dpb.nrdolote = l.nrdolote 
                         AND dpb.nrdconta = l.nrdconta 
                         AND dpb.nrdocmto = l.nrdocmto)) LOOP
						 
			 -- Se a data de movimento maior que a data base, usa proximo dia util			 
             IF rw_craplcm.dtmvtolt >=  vr_dtlibchq_base THEN
                vr_dtlibchq := gene0005.fn_valida_dia_util(pr_cdcooper => rw_craplcm.cdcooper, pr_dtmvtolt => rw_craplcm.dtmvtolt+1);
             ELSE
               vr_dtlibchq :=  vr_dtlibchq_base;
             END IF;    
 
             INSERT INTO crapdpb
             (crapdpb.nrdconta
             ,crapdpb.dtliblan
             ,crapdpb.cdhistor
             ,crapdpb.nrdocmto
             ,crapdpb.dtmvtolt
             ,crapdpb.cdagenci
             ,crapdpb.cdbccxlt
             ,crapdpb.nrdolote
             ,crapdpb.vllanmto
             ,crapdpb.inlibera
             ,crapdpb.cdcooper)
             VALUES
             (rw_craplcm.nrdconta
             ,vr_dtlibchq
             ,rw_craplcm.cdhistor
             ,rw_craplcm.nrdocmto
             ,rw_craplcm.dtmvtolt
             ,rw_craplcm.cdagenci
             ,rw_craplcm.cdbccxlt
             ,rw_craplcm.nrdolote
             ,rw_craplcm.vllanmto
             ,1
             ,rw_craplcm.cdcooper);
     END LOOP;      
	 
     COMMIT;
	 
EXCEPTION
 WHEN others THEN
   ROLLBACK;

END;