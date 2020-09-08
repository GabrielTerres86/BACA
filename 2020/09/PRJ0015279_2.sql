-- Nova URL Motor na Cloud
UPDATE crapprm p
   SET p.dsvlrprm = 'https://ibraflow.capacitor.digital'
 WHERE p.cdacesso = 'HOST_WEBSRV_MOTOR_IBRA';
 
-- Retirar / antes do ibracred-workflow
UPDATE crapprm p
   SET p.dsvlrprm = 'ibracred-workflow/api/process'
 WHERE p.cdacesso = 'URI_WEBSRV_MOTOR_IBRA';

-- Secret Key Cloud
INSERT INTO crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
VALUES
  ('CRED',
   0,
   'SECRET_KEY_CLOUD_MOTOR',
   'Secret Key Acesso Motor Ibratan',
   '7f0b2375eb5d43b5a700e5a18b060492fb7fc16b546f4cc0a71e577ca327586ba106d01d8523444c95e93c7988e1d0b3b27d7a85875d4c758365c6673d39d8e9'); 

-- Access Key Cloud
INSERT INTO crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
VALUES
  ('CRED',
   0,
   'ACCESS_KEY_CLOUD_MOTOR',
   'Access Key Acesso Motor Ibratan',
   'fb70480be4dc4daf9bfe50bd93dda020'); 
   
-- URL para download informação da Ibratan    
INSERT INTO crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
VALUES
  ('CRED',
   0,
   'URL_DOWNLOAD_MOTOR',
   'URL para download informação da Ibratan',
   'https://ibraflow.capacitor.digital/ibracred-workflow/api/process'); 
   
-- Chaves para busca do PDF

-- Secret Key Cloud PDF
INSERT INTO crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
VALUES
  ('CRED',
   0,
   'SECRET_KEY_IBRATAN_PDF',
   'Secret Key Acesso Motor Ibratan',
   'cec0d7baca134e92b0db46e2a17ce561e1241da047b3440da21bc9c038518eab42f9d8df01be4a5a9c82ac2ab657fdfe5f94d254b76d41568bb4df0313ed0263'); 

-- Access Key Cloud PDF
INSERT INTO crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
VALUES
  ('CRED',
   0,
   'ACCESS_KEY_IBRATAN_PDF',
   'Access Key Acesso Motor Ibratan',
   'e1ce4f39c5ad465393c12461e2708496'); 
   
UPDATE crapprm p
   SET p.dsvlrprm = 'curl [header] -k --noproxy ''*'' --max-time 30 -o [local-name] -f [remote-name]'
 WHERE p.cdacesso = 'SCRIPT_DOWNLOAD_PDF_ANL';   
   
COMMIT;      
 