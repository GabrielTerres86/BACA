BEGIN
  update crapatr c set c.cdempres=8460113 where c.cdcooper=5 and c.nrdconta in(91952,166820,6556) and c.cdempcon in(113,313) and c.cdsegmto=4;
  COMMIT;
END;  