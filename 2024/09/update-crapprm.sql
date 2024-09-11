begin
 
UPDATE cecred.crapprm prm
  SET prm.dsvlrprm = null 
WHERE prm.cdcooper in (1,2,3,5,6,7,8,9,10,11,12,13,14,16)
  AND prm.nmsistem = 'CRED'
  AND prm.cdacesso = 'PRM_HCONVE_CRPS387_IN';  

commit;
end;
