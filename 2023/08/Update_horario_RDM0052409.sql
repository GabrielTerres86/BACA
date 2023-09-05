begin

  update sys.dba_scheduler_jobs set repeat_interval ='Freq=daily;ByDay=MON, TUE, WED, THU, FRI;ByHour=19;ByMinute=30;BySecond=0' where job_name like 'JBDEB_UNICO_HORA04%';
  commit;

end ;
