<?php
    function ChamaServico($url, $method, $arrayHeader, $data){

        $ch = curl_init($url);                                                                      
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);                                                                     
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);                                                                      
        curl_setopt($ch, CURLOPT_HTTPHEADER, $arrayHeader);                                                                                                                                      
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);                                                                  
        $resultXml = curl_exec($ch);

        return $resultXml;
    }
?>