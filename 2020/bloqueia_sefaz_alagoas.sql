update crapscn set crapscn.dtencemp = trunc(sysdate) where crapscn.cdempcon = 291 and crapscn.cdsegmto = 5;
commit;
