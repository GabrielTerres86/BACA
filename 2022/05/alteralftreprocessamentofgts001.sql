begin
      UPDATE gncontr gnc
         SET gnc.cdsitret = 9
       WHERE gnc.dtmvtolt = '09/05/2022'
         AND gnc.cdcooper = 3
         AND gnc.cdconven IN (164,165)
         AND gnc.nrsequen IN (43,44);
         
     COMMIT;
end;
/  