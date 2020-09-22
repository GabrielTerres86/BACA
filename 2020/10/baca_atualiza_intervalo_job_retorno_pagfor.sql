BEGIN
  DBMS_SCHEDULER.SET_ATTRIBUTE (
   name         =>  'CECRED.JBCONV_PROC_RETORNO_PAGFOR',
   attribute    =>  'repeat_interval',
   value        =>  'Freq=MINUTELY;Interval=5;ByDay=MON,TUE,WED,THU,FRI;ByHour=8,9,10,11,12,13,14,15,16,17,18,19,20;BySecond=0');
END;
/
