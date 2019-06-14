<?php
/*
Autor: Bruno Luiz Katzjarowski - Mout's
Data: 01/11/2018
Ultima atualização:

Alterações:
*/


session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");		
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");


/*
NMDEACAO
PC_BUSCAR_FILTROS
	pkg: TELA_LOGSPB
	nmproced: PC_BUSCAR_FILTROS
	parametros: nenhum
	
PC_BUSCAR_MENSAGENS
	pkg: TELA_LOGSPB
	nmproced: PC_BUSCAR_MENSAGENS
	parametros:
		opcao,
		dtmensagem_de,
		dtmensagem_ate,
		vlmensagem_de,
		vlmensagem_ate,
		nrdconta,
		inorigem,
		intipo,
		cdcooper,
		nrispbif

PC_BUSCAR_DETALHES_MSG
	pkg: TELA_LOGSPB
	nmproced: PC_BUSCAR_DETALHES_MSG
	parametros:
		pr_nrseq_mensagem,
		pr_idorigem
*/

$chamada = isset($_POST['chamada']) ? $_POST['chamada'] : "";
$parametros = isset($_POST['parametros']) ? $_POST['parametros'] : '';

if($chamada == "")
    exit();

$retorno = Array(
	"retorno" => '',
	'error' => '',
	'paginacao' => Array(
		'qtregist' => '', //$qtregist = $xmlObjRegistros->roottag->tags[0]->attributes['QTREGIST'];
		'nrregist' => '',
		'nriniseq' => '',
		)
	);


switch($chamada){
    case 'GET_OPCOES':
        $retorno['retorno'] = getOpcoes();
    break;
    case 'GET_CONSULTA':
    	$retorno['retorno'] = getConsultas($parametros);
    break;
    case 'GET_DETALHES_MENSAGEM':
		$retorno['retorno'] = getDetalhesMensagem($parametros);
    break;
}

echo json_encode($retorno); //retorna json


/*
	Retorna detalhes da mensagem
	@return Array $jsonArray;
*/
function getDetalhesMensagem($parametros){
	global $glbvars;
	global $retorno;
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrseq_mensagem>".$parametros['nrseq_mensagem']."</nrseq_mensagem>";
	$xml .= "		<idorigem>".$parametros['idorigem']."</idorigem>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	//pr_nrseq_mensagem,pr_idorigem
			
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_LOGSPB", "PC_BUSCAR_DETALHE_MSG", 
	                        $glbvars["cdcooper"], 
	                        $glbvars["cdagenci"], 
							$glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = simplexml_load_string($xmlResult);

	$json = json_encode($xmlObj);
	$jsonReturn = json_decode($json,TRUE);

	tratarErro($xmlObj);
	return $jsonReturn;
}

/*
'opcao' => string 'C' (length=1)
'dtmensagem_de' => string '' (length=0)
'dtmensagem_ate' => string '' (length=0)
'vlmensagem_de' => string '' (length=0)
'vlmensagem_at' => string '' (length=0)
'intipo' => string 'T' (length=1)
'nrispbif' => string '' (length=0)
'cdcooper' => string '1' (length=1)
*/
function getConsultas(){
	global $glbvars;
	global $retorno;
	global $parametros;

	if($parametros['vlmensagem_de'] != "")
		$parametros['vlmensagem_de'] = str_replace(".","",str_replace(',', '.', $parametros['vlmensagem_de']));
	if($parametros['vlmensagem_ate'] != "")
		$parametros['vlmensagem_ate'] = str_replace(".","",str_replace(',', '.', $parametros['vlmensagem_ate']));

	

	$nrregist = 100; //DEFAULT RETURN;

	if(isset($parametros['paginacao'])){
		$nriniseq = $parametros['paginacao']['nriniseq'];
		if(isset($parametros['paginacao']['acao'])){
			$acao = $parametros['paginacao']['acao'];
			switch ($acao) {
				case 'PROXIMA':
					$nriniseq = $nriniseq +1;
					break;
				case 'VOLTAR':
					$nriniseq = $nriniseq -1;
					if($nriniseq < 0)
						$nriniseq = 0;
					break;
			}
		}
	}else{
		$nriniseq = 0;
	}

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
	$xml .= "       <dsendere>".$parametros['dsendere']."</dsendere>"; //Caso preenchido envia o relatorio csv para o e-mail preenchido
	$xml .= "		<nrregist>".$nrregist."</nrregist>"; //Quantidade de registros
	$xml .= "		<nriniseq>".$nriniseq."</nriniseq>"; //Página Atual
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	

	
	/*
	opcao,
	dtmensagem_de,
	dtmensagem_ate,
	vlmensagem_de,
	vlmensagem_ate,
	nrdconta,
	inorigem,
	intipo,
	cdcooper,
	nrispbif
	*/

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_LOGSPB", "PC_BUSCAR_MENSAGENS",
	                        $glbvars["cdcooper"], 
	                        $glbvars["cdagenci"], 
	                        $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = simplexml_load_string($xmlResult);

	/*
	 'paginacao' => Array(
		'qtregist' => '', //$qtregist = $xmlObjRegistros->roottag->tags[0]->attributes['QTREGIST'];
		'nrregist' => '',
		'nriniseq' => '',
		)
	 */
	

	$json = json_encode($xmlObj);
	$jsonReturn = json_decode($json,TRUE);
	tratarErro($xmlObj);

	$retorno['paginacao']['qtregist'] = $jsonReturn['mensagem']['@attributes']['qtregist'];
	$retorno['paginacao']['nrregist'] = $nrregist;
	$retorno['paginacao']['nriniseq'] = $nriniseq;

	return $jsonReturn;
}

/*
	Atribui à retorno os valores para preenchimento dos comboboxes
	@return Array $jsonArray;
*/
function getOpcoes(){

	global $glbvars;
	global $retorno;

	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
			
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_LOGSPB", "PC_BUSCAR_FILTROS", 
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
			$msg = trim(preg_replace('/\s\s+/', ' ', $xmlObj->Erro->Registro->dscritic));
			$retorno['error'] = "
								 blockBackground(1);
								 hideMsgAguardo();
							     showError('error','".$msg."','Alerta - Aimaro','unblockBackground(1);');";
		}
	}
}


?>