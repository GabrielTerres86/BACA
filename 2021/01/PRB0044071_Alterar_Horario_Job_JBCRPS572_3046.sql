BEGIN
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE(NAME      => 'CECRED.JBCRPS572_3046',
                                   ATTRIBUTE => 'repeat_interval',
                                   VALUE     => 'Freq=DAILY;ByDay=MON,TUE,WED,THU,FRI,SAT,SUN;ByHour=20;ByMinute=00;BySecond=00');
END;
/
