update crapscn set crapscn.dtencemp = trunc(sysdate) where crapscn.cdempcon = 2 and crapscn.cdsegmto = 5;
commit;
