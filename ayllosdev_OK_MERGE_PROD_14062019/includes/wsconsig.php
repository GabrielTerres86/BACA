<?php

header('Cache-Control: no-cache, must-revalidate');
header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
 
$format = '';
$action = '';

if (isset($_GET['format'])) {
    $format = $_GET['format'];
    if (!preg_match('/json|xml/',$format)) {
        print "Selecione o formato: json ou xml";
        exit;
    }
}else if (isset($_POST['format'])) {
    $format = $_POST['format'];
    if (!preg_match('/json|xml/',$format)) {
        print "Selecione o formato: json ou xml";
        exit;
	}
}else {
    print "Selecione o formato: json ou xml";
    exit;
}

if (isset($_GET['action'])) {
    $action = $_GET['action'];    
}else if (isset($_POST['action'])) {
    $action = $_POST['action'];   
}else {
    print "Informe a&ccedil;&atilde;o";
    exit;
}

switch ($format){
    case 'json':
		$header = "Content-Type:application/json";
		break;
	case 'xml':
		$header = "Content-Type:text/xml";
		break;    
}

switch ($action){
    case 'teste':
		$output = teste($format);
		break; 
	case 'teste2':
		$output = teste2($format);
		break; 
	case 'simula_fis':
		$output = simula_fis($format);
		break; 
    default:
      print "Informe a&ccedil;&atilde;o";
      break;
  }

header($header);
print $output;

function simula_fis($format)
{	
	$vlparepr = 93.18;
	$vliofepr = 6.24;
	if (isset($_POST['vlparepr'])) {
		$vlparepr = $_POST['vlparepr'];  
	}else{
		if (isset($_GET['vlparepr'])) {
			$vlparepr = $_GET['vlparepr'];  
		}
	}
		
	if (isset($_POST['vliofepr'])) {
		$vliofepr = $_POST['vliofepr'];  
	}else {
		if (isset($_GET['vliofepr'])) {
			$vliofepr = $_GET['vliofepr'];  
		}	
	}
	
	$myObj->vlparepr = $vlparepr;
	$myObj->vliofepr = $vliofepr;
	$myJSON = json_encode($myObj);
	if ($format == "json"){				
		return $myJSON;
	}else if ($format =="xml"){				
		$xml = array2xml(json_decode($myJSON,true), false);
		return $xml;
	}
}

function teste($format){
	$friendlyDate = date("M d, Y");
	$unixTime = time();
	$month = date("M");
	$dayOfWeek = date("l");
	$year = date("Y");
	$returnData = array(
			"friendlyDate" => $friendlyDate,
			"unixTime" => $unixTime,
			"monthNum" => $month,
			"dayOfWeek" => $dayOfWeek,
			"yearNum" => $year
	);
	if ($format == "xml") {
		$xml = new DOMDocument();
		$dateInfoElement = $xml->createElement("dateInformation");
		foreach ($returnData as $key => $value) {
			$xmlNode = $xml->createElement($key,$value);
			$dateInfoElement->appendChild($xmlNode);
		}
		$xml->appendChild($dateInfoElement);
		$output = $xml->saveXML();
		
	} else if ($format == "json") {
		$output = json_encode($returnData);    
	}
	return $output;
}
function teste2($format){
	$myObj->tabelaFIPE->marcaVeiculo->codigo = 'Ford';
	$myObj->tabelaFIPE->modeloVeiculo->codigo = 'Ka';
	$myObj->paginacao->pagina=1;
	$myObj->paginacao->registrosPorPagina=100;
	$myJSON = json_encode($myObj);
	if ($format == "json"){				
		return $myJSON;
	}else if ($format =="xml"){				
		$xml = array2xml(json_decode($myJSON,true), false);
		return $xml;//->asXML();
	}
	
	/*
	echo $myJSON;
	
	$obj = json_decode($myJSON); 	
	echo "marcaVeiculo: $obj->tabelaFIPE->marcaVeiculo->codigo<br>"; 
	echo "modeloVeiculo: $obj->tabelaFIPE->modeloVeiculo->codigo<br>"; 
	echo "pagina: $obj->paginacao->pagina<br>"; 
	echo "registrosPorPagina: $obj->paginacao->registrosPorPagina<br>";
	*/
}

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