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
         10876286,
         SYSDATE,
         to_date('05/11/2019 10:00:00', 'dd/mm/yy hh24:mi:ss'),
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
         14644983,
         SYSDATE,
         to_date('21/03/2023 10:00:00', 'dd/mm/yy hh24:mi:ss'),
         null,
         null,
         null,
         1);       
commit; 
end;
