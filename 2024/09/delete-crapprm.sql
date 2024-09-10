begin
  
DELETE cecred.crapprm prm
WHERE prm.cdcooper = 1
  AND prm.nmsistem = 'CRED'
  AND prm.cdacesso = 'PRM_HCONVE_CRPS387_IN';

commit;
end;
