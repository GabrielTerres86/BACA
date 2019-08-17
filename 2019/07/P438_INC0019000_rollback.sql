/* INC0019000  -- rollback */
update crawlim lim
      set    insitlim = 1 
            ,insitest = 3 
            ,dtrejeit = null
            ,hrrejeit = 0
            ,cdoperej = ' '
      where  lim.cdcooper = 1
      and    lim.nrdconta = 4035216
      and    lim.nrctrlim = 9782
      and    lim.tpctrlim = 3;
      
commit;
