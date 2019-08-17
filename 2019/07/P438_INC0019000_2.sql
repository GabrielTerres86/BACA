/* INC0019000 */

update crawlim lim
      set    insitlim = 3 -- cancelado
            ,insitest = 3 -- analise finalizada
            ,dtrejeit = trunc(sysdate)
            ,hrrejeit = to_char(sysdate,'SSSSS')
            ,cdoperej = 1
      where  lim.cdcooper = 1
      and    lim.nrdconta = 4035216
      and    lim.nrctrlim = 9782
      and    lim.tpctrlim = 3;
      
commit;

commit;
