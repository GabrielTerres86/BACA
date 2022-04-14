BEGIN
DBMS_SCHEDULER.set_attribute( name => '"CECRED"."JBBLQJ_TRANSFERENCIA"', attribute => 'repeat_interval', value => 'Freq=DAILY;ByDay=MON, TUE, WED, THU, FRI;ByHour=13;ByMinute=10;BySecond=0');
END;