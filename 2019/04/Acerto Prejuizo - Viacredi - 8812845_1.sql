BEGIN
    --
    update crapsld s
       set s.vlsddisp = vlsddisp + 1402.54
     where s.cdcooper = 1
       and s.nrdconta = 8812845;
    -- ------------------------------------
    update crapsda s
       set s.vlsddisp = vlsddisp + 1402.54
     where s.cdcooper = 1
       and s.nrdconta = 8812845
       and s.dtmvtolt = trunc(sysdate) - 1;
    --
    COMMIT;
END;