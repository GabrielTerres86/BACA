--Update casos já existentes que estavam com 125 posicoes
 
 update crapndb set dstexarq = 'F49843348                 010108448620      201912090000000000116781501.020195436336307.00000001 proc: E009818-20/11/2019 17:08:                     0' where progress_recid =1436522; 
 update crapndb set dstexarq = 'F43705482                 010103771598      201912100000000000203101501.020195416149532.39000001 proc: E009818-14/11/2019 16:50:                     0' where progress_recid =1438094; 
 update crapndb set dstexarq = 'F10939968                 0102900200654116  201912100000000000016813001.020195392677457.90000001 proc: E009818-07/11/2019 16:43:                     0' where progress_recid =1438051; 
  
 commit;