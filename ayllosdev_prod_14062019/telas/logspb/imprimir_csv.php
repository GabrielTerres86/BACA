<?php
/*
Autor: Bruno Luiz katzjarowski - Mout's;
Data: 12/11/2018
Ultima alteração:

Alterações:
*/ 
ini_set('max_execution_time', 900); //15 minutos
ini_set('memory_limit', '2048M');

session_cache_limiter("private");
session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");		
require_once("../../includes/controla_secao.php");
require_once('includes/utils.php');

// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

require_once('includes/exportar_csv.php');
$parametros = Array(
                "opcao"=> $_POST["aux_cddopcao"],
                "dtmensagem_de"=>  $_POST["textDataDe"],
                "dtmensagem_ate"=> $_POST["textDataAte"],
                "vlmensagem_de"=> $_POST["textValorDe"],
                "vlmensagem_ate"=> $_POST["textValorAte"],
                "intipo"=> $_POST["selTipo"],
                "nrispbif"=> $_POST["selIfContraparte"],
                "inorigem"=> $_POST["selOrigem"],
                "cdcooper"=> $_POST["selCooperativas"],
				"nrdconta"=> $_POST["selContaDv"],
				'nrregist'=> isset($_POST['aux_nrregist']) ? $_POST['aux_nrregist'] : '50',
            );

$retorno = Array(
	"retorno" => '',
	'error' => '',
	);

$retorno['retorno'] = getConsultas($parametros);


$colunas = getColunas($parametros['intipo'],$parametros['opcao']);
$valores = Array();
$valores = Array();

if(isset($retorno['retorno'])){
	$dados = $retorno['retorno']['mensagem']['item'];

	if(!isset($retorno['retorno']['mensagem']['@attributes']["qtregist"])){
		echo "
			<script type='text/javascript'>
				window.close();
			</script>
		";
		exit();
	}
	$qtdRegistros = intval($retorno['retorno']['mensagem']['@attributes']["qtregist"]);

	if($qtdRegistros > 1){
		foreach($dados as $linha){
			$valor = Array();
			foreach($colunas['keys'] as $key){
				if(is_array($linha[$key])){
					$valor[] = '';
				}else
					$valor[] = $linha[$key];
			}
			$valores[] = $valor;
		}
	}else{
		$valor = Array();
		foreach($colunas['keys'] as $key){
			if(is_array($dados[$key])){
				$valor[] = '';
			}else
				$valor[] = $dados[$key];
		}
		$valores[] = $valor;
	}
}

//var_dump($valores);
/* 
 * @param string $fileName
 * @param null   $cabecalho
 * @param null   $valores
 */
writeArchive('csv',$colunas['colunas'],$valores);

function getConsultas($parametros){
	global $glbvars;
	global $retorno;
	global $parametros;

	if($parametros['vlmensagem_de'] != "")
		$parametros['vlmensagem_de'] = str_replace(".","",str_replace(',', '.', $parametros['vlmensagem_de']));
	if($parametros['vlmensagem_ate'] != "")
		$parametros['vlmensagem_ate'] = str_replace(".","",str_replace(',', '.', $parametros['vlmensagem_ate']));

	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<opcao>".$parametros['opcao']."</opcao>";
	$xml .= "		<dtmensagem_de>".$parametros['dtmensagem_de']."</dtmensagem_de>";
	$xml .= "		<dtmensagem_ate>".$parametros['dtmensagem_ate']."</dtmensagem_ate>";
	$xml .= "		<vlmensagem_de>".$parametros['vlmensagem_de']."</vlmensagem_de>";
	$xml .= "		<vlmensagem_ate>".$parametros['vlmensagem_ate']."</vlmensagem_ate>";
	$xml .= "		<nrdconta>".$parametros['nrdconta']."</nrdconta>";
	$xml .= "		<inorigem>".$parametros['inorigem']."</inorigem>";
	$xml .= "		<intipo>".$parametros['intipo']."</intipo>";
	$xml .= "		<cdcooper>".$parametros['cdcooper']."</cdcooper>";
	$xml .= "		<nrispbif>".$parametros['nrispbif']."</nrispbif>";
	$xml .= "		<nrregist>".$parametros['nrregist']."</nrregist>"; //Quantidade de registros
	$xml .= "		<nriniseq>0</nriniseq>"; //Página Atual
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
		

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_LOGSPB", "PC_BUSCAR_MENSAGENS",
	                        $glbvars["cdcooper"], 
	                        $glbvars["cdagenci"], 
							$glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = simplexml_load_string($xmlResult);

	$json = json_encode($xmlObj);
	$jsonReturn = json_decode($json,TRUE);
	tratarErro($xmlObj);

	return $jsonReturn;
}

function tratarErro($xmlObj){
	global $retorno;
	//se ocorreu erro no retorno da proc
	if(property_exists($xmlObj, 'Erro')){
		$codError = $xmlObj->Erro->Registro->cdcritic;		
		if(isset($codError)){
			$retorno['error'] = "showError('error','".$xmlObj->Erro->Registro->dscritic."','Alerta - Aimaro','');";
		}
	}
}
?>