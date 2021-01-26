-- RITM0104914
update craplft l
   set l.dtvencto = trunc(sysdate),
       l.cdhistor = 2515,
       l.insitfat = 1
 where l.progress_recid in (44639347,
                            44641844,
                            44641779,
                            44639619,
                            45474060,
                            45472941,
                            45473373,
                            45478930,
                            45474300,
                            45474675,
                            45480838,
                            45476772,
                            45469038,
                            45474496);
commit;
