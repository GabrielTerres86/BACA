INSERT INTO tbcc_prejuizo_lancamento( dtmvtolt
                                    , cdagenci
                                    , nrdconta
                                    , nrdocmto
                                    , cdhistor
                                    , vllanmto
                                    , dthrtran
                                    , cdoperad
                                    , cdcooper
                                    , cdorigem )
                             VALUES ( TRUNC( SYSDATE )
                                    , 1
                                    , 9343571
                                    , 1
                                    , 2738
                                    , 800
                                    , SYSDATE
                                    , 1
                                    , 1
                                    , 0 );                                          
   
commit;
