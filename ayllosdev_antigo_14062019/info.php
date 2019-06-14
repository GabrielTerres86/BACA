<?php
//phpinfo();
/*


$valoresParaSubmeter = array('key1' => 'valor1', 'key2' => 'valor2');
$ch = curl_init("http://servicosinternosint.cecred.coop.br/osb-soa/TransacaoCreditoRestService/v1/EnviarDadosCadastraisConvenioCredito");

curl_setopt($ch, CURLOPT_FOLLOWLOCATION, FALSE);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, $valoresParaSubmeter);
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 1);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 1);
$data = curl_exec($ch);
print_r($data);

$response = json_decode($data, true); // o true indica que você quer o resultado como array

var_dump($response);
*/


$current_script = dirname($_SERVER['SCRIPT_NAME']);
$current_path  = dirname($_SERVER['SCRIPT_FILENAME']);

print_r($_SERVER['DOCUMENT_ROOT']);
echo '<br>';
print_r($current_script);
echo '<br>';
print_r($current_path);

if (!file_exists('../../../../class/xmlfile.php')) {
	require_once ('class/xmlfile.php');
	print_r('1');
}else{
	print_r('11');
}

if (require_once ('../../../../includes/funcoes.php') == FALSE) {
	require_once ('includes/funcoes.php');
	print_r('2');
}

?>