begin
      INSERT INTO cecred.tbprevidencia_conta
        (cdcooper,
         nrdconta,
         dtmvtolt,
         dtadesao,
         cdopeade,
         dtcancel,
         cdopecan,
         insituac)
      VALUES
        (1,
         15496180,
         SYSDATE,
         to_date('22/09/2022 12:47:44', 'dd/mm/yy hh24:mi:ss'),
         null,
         null,
         null,
         1);
         
      INSERT INTO cecred.tbprevidencia_conta
        (cdcooper,
         nrdconta,
         dtmvtolt,
         dtadesao,
         cdopeade,
         dtcancel,
         cdopecan,
         insituac)
      VALUES
        (1,
         15496481,
         SYSDATE,
         to_date('22/09/2022 12:47:44', 'dd/mm/yy hh24:mi:ss'),
         null,
         null,
         null,
         1);  
      INSERT INTO cecred.tbprevidencia_conta
        (cdcooper,
         nrdconta,
         dtmvtolt,
         dtadesao,
         cdopeade,
         dtcancel,
         cdopecan,
         insituac)
      VALUES
        (1,
         11795212,
         SYSDATE,
         to_date('22/09/2022 12:47:44', 'dd/mm/yy hh24:mi:ss'),
         null,
         null,
         null,
         1);          
delete cecred.tbprevidencia_conta where nrdconta = 11789654 and cdcooper=1;     
      INSERT INTO cecred.tbprevidencia_conta
        (cdcooper,
         nrdconta,
         dtmvtolt,
         dtadesao,
         cdopeade,
         dtcancel,
         cdopecan,
         insituac)
      VALUES
        (7,
         461928,
         SYSDATE,
         to_date('04/01/2023 12:00:00', 'dd/mm/yy hh24:mi:ss'),
         null,
         null,
         null,
         1); 
      INSERT INTO cecred.tbprevidencia_conta
        (cdcooper,
         nrdconta,
         dtmvtolt,
         dtadesao,
         cdopeade,
         dtcancel,
         cdopecan,
         insituac)
      VALUES
        (7,
         449121,
         SYSDATE,
         to_date('27/07/2022 12:00:00', 'dd/mm/yy hh24:mi:ss'),
         null,
         null,
         null,
         1);    
      INSERT INTO cecred.tbprevidencia_conta
        (cdcooper,
         nrdconta,
         dtmvtolt,
         dtadesao,
         cdopeade,
         dtcancel,
         cdopecan,
         insituac)
      VALUES
        (7,
         457612,
         SYSDATE,
         to_date('08/11/2022 12:00:00', 'dd/mm/yy hh24:mi:ss'),
         null,
         null,
         null,
         1);                
  commit;
end;
/
