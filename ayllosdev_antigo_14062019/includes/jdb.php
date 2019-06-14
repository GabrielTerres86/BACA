<?php
/*
	$raw_data = file_get_contents('http://t0032501.ayllosdev.cecred.coop.br/includes/wsconsig.php?format=json&action=simula_fis');
	//print_r($raw_data);
	$obj = json_decode($raw_data); 	
	echo "Valor Parcela: $obj->vlparepr<br>"; 
	echo "IOF: $obj->vliofepr<br>"; 
*/

$myJSON = '{
  "convenioCredito" : {
    "cooperativa" : {
      "codigo" : "12"
    },
    "numeroContrato" : "90000"
  },
  "configuracaoCredito" : {
    "diasCarencia" : 28,
    "financiaIOF" : true,
    "financiaTarifa" : true
  },
  "credito" : {
    "dataPrimeiraParcela" : "2019-06-05",
    "produto" : {
      "codigo" : "161"
    },
    "quantidadeParcelas" : 20,
    "taxaJurosRemuneratorios" : 2.0,
    "tipoJuros" : {
      "codigo" : 1
    },
    "tipoLiberacao" : {
      "codigo" : 1
    },
    "tipoLiquidacao" : {
      "codigo" : 1
    },
    "valorBase" : 500.00
  },
  "tarifa" : {
    "valor" : 5.00
  },
  "sistemaTransacao" : {
  },
  "interacaoGrafica" : {
    "dataAcaoUsuario" : "2019-05-08T17:39:09"
  },
  "parametroConsignado" : {
    "codigoFisTabelaJuros" : "1521"
  }
}';

$xml = array2xml(json_decode($myJSON,true), false);

echo '<pre>', htmlentities($xml), '</pre>';


function array2xml($array, $xml = false){
    if($xml === false){
        $xml = new SimpleXMLElement('<result/>');
    }
    foreach($array as $key => $value){
        if(is_array($value)){
            array2xml($value, $xml->addChild($key));
        } else {
            $xml->addChild($key, $value);
        }
    }
    return $xml->asXML();
}	
?>