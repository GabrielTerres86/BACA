BEGIN
  
  insert into CECRED.TBGEN_CHAVES_CRYPTO (cdacesso, dtinicio_vigencia, dschave_crypto, dsserie_chave)
  values ('PCPS_CHAVE_PUBLICA_AILOS', to_date('14/06/2019','DD/MM/YYYY'), '-----BEGIN PUBLIC KEY-----' || chr(10) 
                                                            || 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAo0qY9MSz+jh05lg1mCj3' || chr(10) 
                                                            || 'qU45uVfDFqiP+HFPHvV0Emr4muZniCiooJxcUgtIqaigNo4Tn2Zqyu/QhseyADkC' || chr(10) 
                                                            || 'aVJiOPd3Hu1kGbLPUHgjKvgCK1LXZxLbP2uGecrbc7/2vTs1U+ASSQbK3Z3p/4l8' || chr(10) 
                                                            || 'sc4zTLGjBK6tTddv/m2lbN/tLUhEv0HjILAHg059iAvIrafHhkxVa70Tqn38m26F' || chr(10) 
                                                            || 'Tb2brLzp9R1gSsI9Z62LuUdrKAu4Q49NguCGvweTVaLLW/5+/wCqso1hPUdsEmkd' || chr(10) 
                                                            || 'f+piSm3tqhnqNTd5T5dM9RCeTjbgV8XbdFsin1lYVxwtImao8GI6s0qxPVI3hTKP' || chr(10) 
                                                            || '2wIDAQAB' || chr(10) 
                                                            || '-----END PUBLIC KEY-----', '5136515F0706D35B');
  
  insert into CECRED.TBGEN_CHAVES_CRYPTO (cdacesso, dtinicio_vigencia, dschave_crypto, dsserie_chave)
  values ('PCPS_CHAVE_PRIVADA_AILOS', to_date('14/06/2019','DD/MM/YYYY'), '-----BEGIN RSA PRIVATE KEY-----' || chr(10) 
                                                            || 'MIIEowIBAAKCAQEAo0qY9MSz+jh05lg1mCj3qU45uVfDFqiP+HFPHvV0Emr4muZn' || chr(10) 
                                                            || 'iCiooJxcUgtIqaigNo4Tn2Zqyu/QhseyADkCaVJiOPd3Hu1kGbLPUHgjKvgCK1LX' || chr(10) 
                                                            || 'ZxLbP2uGecrbc7/2vTs1U+ASSQbK3Z3p/4l8sc4zTLGjBK6tTddv/m2lbN/tLUhE' || chr(10) 
                                                            || 'v0HjILAHg059iAvIrafHhkxVa70Tqn38m26FTb2brLzp9R1gSsI9Z62LuUdrKAu4' || chr(10) 
                                                            || 'Q49NguCGvweTVaLLW/5+/wCqso1hPUdsEmkdf+piSm3tqhnqNTd5T5dM9RCeTjbg' || chr(10) 
                                                            || 'V8XbdFsin1lYVxwtImao8GI6s0qxPVI3hTKP2wIDAQABAoIBAE2ZHabz8zNtsN/l' || chr(10) 
                                                            || '+1Ib5dWnPvc9JZCW+hPuhNMJgedevlWeOIUUDU6F/7ldc2Jsp/ZE/j45xXY7ELV8' || chr(10) 
                                                            || 'ILLKZML4S4UW1Jz14yPzPWHYNZ4tzZoY/BQXeelhh75JEJCpIPA8OtNpIEdj2vQG' || chr(10) 
                                                            || 'HzU4ePFmNCq2H+oRuHnNb4NRR9O8s/zsPEYv8Lt7EhfTAa4gG4j6X8T+o9kltmL0' || chr(10) 
                                                            || 'zXT3duV0mo1I3G50Ymd+YWdn4mk3hi+5Osvv+hssoxnRtnLkIxhLXX7CKWMC1T1H' || chr(10) 
                                                            || 'RqxScjrf8pJM9svORwDved1mweu0iTeRMkWmCBbSGvuuK8Z8Yrs5FaTRJu0X1Rvj' || chr(10) 
                                                            || 'VTSrOUECgYEAzg/OzK51bX28CrSiQdaWfH2ked/qUc0KWse802FJUbxl06bUvM+H' || chr(10) 
                                                            || '3Q++aotL6tXclYDOuMRcoGxakJm/EusjEkNscY5txx3/ztZnXgA/qDRHTRqhZQuc' || chr(10) 
                                                            || 'CYEY1QUiUtDYhTjEXfgmoTF9x1T6ZeqB3tk1RJBZ5xZ0JyjAF04LLacCgYEAyt1K' || chr(10) 
                                                            || 'tFjFK0z5h/7VDqORfp2mgtqspMwPHhVc4AXTkAzgGYx81+2/dbfRtTjDIlvfO6bZ' || chr(10) 
                                                            || 'OIiDUBQqkhKzGEgV7uqNRS+bThFDZMOfxqCFZrgOSn+zNRlJtS11KFxWmhzuvHYX' || chr(10) 
                                                            || '4NAiG1CGRtuOsUjUGRcNnK6f3tbIL5C4Y3yoWq0CgYEArXDMxadKG6CrN++Wawgt' || chr(10) 
                                                            || 'nhc664I2/icxQfvAycKnLe7/Xkib41hiqQTpZ1Bb1AuyIPxMA2Tz+et5xyBBnbDg' || chr(10) 
                                                            || '0iyCCIqzh9eOSxBX7N0Ut4VZRmLV2fENo0pQFmy92SsENA316opGKYM4tSCnqkTa' || chr(10) 
                                                            || 'jzIQDefaZBGYLqW0GWmNKx0CgYBQ66DG+7n6ocPPqakXI8v/s6cd/1hqjDNjjqXz' || chr(10) 
                                                            || 'fp97kIc76bxK7b03mdF+9ltwMzGCu/VeBaZLpR+uEON7xhVprgoYFPtgUqaNZTMw' || chr(10) 
                                                            || 'qgtMhBK/SN0VSzcJnE5lgR/SbcQVTQ4NUTipqJ9HWIE82o4wS+/UFhwTaZ2Ey7eh' || chr(10) 
                                                            || 'h7IoKQKBgHNPKUPhTlspTf6NqewEaQ2luU/E9VdRmyMB08NewXkz2VcbLn9jGedr' || chr(10) 
                                                            || 'A71VsqXntUhDW+bBKZxOvPKkkFcQy7OjgFiOM0l+W3AyElXTXlWrVXuL15Zcz+H9' || chr(10) 
                                                            || 'xegJapOv0PMpMgPGBgBQLIonpBpnnnNhZ+RSquqrFQWcZ5pXvGKe'             || chr(10) 
                                                            || '-----END RSA PRIVATE KEY-----', '5136515F0706D35B');
  
  commit;

END;
