BEGIN
  
  insert into CECRED.TBGEN_CHAVES_CRYPTO (cdacesso, dtinicio_vigencia, dschave_crypto, dsserie_chave)
  values ('PCPS_CHAVE_PUBLICA_AILOS', to_date('11/05/2024','DD/MM/YYYY'), 
                                                               'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0QgQWWErgDCecLg74/JJ' || chr(10) 
                                                            || 'mY4ubE/3HH4NGBh+bUwHacoW6aLlkBTWX90/SamsMXd1GUmhzjzwqZOSyykz36Pr' || chr(10) 
                                                            || '6HGuhs+KPsQsmMxAWl+4i/Hv+eN5BTJc2NhD3E1zUiCfRBt8HzmtscZ3DXke1vJh' || chr(10) 
                                                            || 'Ef6AEzE9QK5Yt89K6rl2Iv1LKJ29gKYNuiiaEFxjKyEySF/1o1A9wIOTSyOOT3bd' || chr(10) 
                                                            || 'BIWF6ptqo8MdmDuiYJflEOCipBNQhyjGXfxv9whElpObkVno4l0kX/Wc/MtO8Mh4' || chr(10) 
                                                            || 'c8knBKN44C8OBE+yPD4hp9tl44TlmiODtANIcx8AN1eT06I2DUU1Z+yo5UO+XfC8' || chr(10) 
                                                            || 'PwIDAQAB' 
                                                            , '11DE24050359EC3C');
  
  insert into CECRED.TBGEN_CHAVES_CRYPTO (cdacesso, dtinicio_vigencia, dschave_crypto, dsserie_chave)
  values ('PCPS_CHAVE_PRIVADA_AILOS', to_date('11/05/2024','DD/MM/YYYY'), 
                                                               'MIIEowIBAAKCAQEA0QgQWWErgDCecLg74/JJmY4ubE/3HH4NGBh+bUwHacoW6aLl' || chr(10) 
                                                            || 'kBTWX90/SamsMXd1GUmhzjzwqZOSyykz36Pr6HGuhs+KPsQsmMxAWl+4i/Hv+eN5' || chr(10) 
                                                            || 'BTJc2NhD3E1zUiCfRBt8HzmtscZ3DXke1vJhEf6AEzE9QK5Yt89K6rl2Iv1LKJ29' || chr(10) 
                                                            || 'gKYNuiiaEFxjKyEySF/1o1A9wIOTSyOOT3bdBIWF6ptqo8MdmDuiYJflEOCipBNQ' || chr(10) 
                                                            || 'hyjGXfxv9whElpObkVno4l0kX/Wc/MtO8Mh4c8knBKN44C8OBE+yPD4hp9tl44Tl' || chr(10) 
                                                            || 'miODtANIcx8AN1eT06I2DUU1Z+yo5UO+XfC8PwIDAQABAoIBAFM+RdyCUOOM+Rvk' || chr(10) 
                                                            || 'kp01WNAZCi3CLqOfIzHMV1TJaU5c14EViRw24CRvJIv+UP+mFfELHK/YHvM5PMVB' || chr(10) 
                                                            || 'VFIkoob/9sPjFKfoUeZLuPkEk6bPo4S9bO1/3+/POD8cbOdw7FwgIe8BdkWMxs6L' || chr(10) 
                                                            || 'xJdPEQ8sbe62tjDy/Yu9tpUBZKWLxtPDJvzNu+vb4Mx0bf4WDb/TCuMXpiA8/lDa' || chr(10) 
                                                            || 'JfHh47HP2hQs8xT1+kgbt5hzzwTYmBoECvn+NczvmBT168BpZBHXta22rlllHXXf' || chr(10) 
                                                            || 'aIBHXcn4M6qkZ3NskfUqCfB06dJBUjZ5S7TUh/nKQOggCCzPj454AzAjqWzwYZqC' || chr(10) 
                                                            || 'fFoE9oECgYEA+FP7xvkvWg8jJA0Nk1ZIl3LjluaTIsyVCTWbCZgSnNin4SmA46NZ' || chr(10) 
                                                            || 'qU0BPcVU/mYAe8TcqdWHkkRcpQsBSoN0LP5ASrjuOWMTjtUiwiWTE7HEtQ3ljDBu' || chr(10) 
                                                            || '7t2kkbbwTZLiqhG9iqkjUNP9KtGLzYpXqQyvD21+Crua21QfDCti6EECgYEA131J' || chr(10) 
                                                            || 'E/xFCGGBnUi7eq0XL8WjB4aeRilogaZqIfsLaBsd5vGgo/9QEROzUZ/yK4JR6jVS' || chr(10) 
                                                            || '1PixUkfFT6i6oMChHAL4vk+bCY0i9immn7BI4g1g5Y/n2zV7x63BX1TZl2SoLd5R' || chr(10) 
                                                            || 't2rm+3FANNrM12MDsx8noaADzxofBv0gqoCehH8CgYEAjIrjjUoMTZkRl1631zJX' || chr(10) 
                                                            || 'JTfFrOrUTTaiBrNLCpQBvLk10k4t/ye9H/9P+4jKQKy0C1hwVsJd1x9Pm6ztzyE0' || chr(10) 
                                                            || 'yB4hfujJEruLHyRrZpvjcJsErD+wMbZbol7YvAtgV1cRZ5Vgw7BUJ3PC7c/ooqxw' || chr(10) 
                                                            || 'TmG6Vi3uzt48l3M1myqW8MECgYB7N3Zr6RoIGskkiIw7L3JMrLP1/7HM6KyLRf72' || chr(10) 
                                                            || 'AziYhLjqb0uturWrrhohGFY/LrtsMqV0hefO5p8aV56vgLYe8EwPdjFumrddDp/q' || chr(10) 
                                                            || 'O8DREVlQqqKnI8Ptf5tMyZXKDZJk9/S97nC5Yh6Wmm360vEwoSXmMzs6VvNa6a6e' || chr(10) 
                                                            || 'EAGUPQKBgCDvin21Z+rdsUcfpSevYqeSmBjupR9viIeKJRCRApgyDOwP3IlgA4d7' || chr(10) 
                                                            || 'd4yJ3QOJSl/aRRoGSlqMzneNShQGyPOYc8xVJGzOUxImnoX4O476JLGjjUS6emcd' || chr(10) 
                                                            || 'x6CNd3lTKFkBR2IEwApy+jCDIZaC5csGqd4Gl7YzttcIB84u/BTh'
                                                            , '11DE24050359EC3C');
  
  commit;

END;
