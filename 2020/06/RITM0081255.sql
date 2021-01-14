update tbepr_cdc_segmento set FLGATIVO = 0 where cdsegmento in (5,99,12,11);
update tbepr_cdc_subsegmento set FLGATIVO = 0 where cdsubsegmento in (14,39,52,54,56,64,82,83,90,86,87,73,75,89,13);
commit;
