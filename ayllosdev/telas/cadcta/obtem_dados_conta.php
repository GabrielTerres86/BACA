<?php
/*!
 * FONTE        : obtem_dados_conta.php
 * CRIAÇÃO      : Mateus Zimmermann (Mateus Zimmermann)
 * DATA CRIAÇÃO : 09/10/2017
 * OBJETIVO     : Capturar dados de conta da tela CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 *
 */ 

session_start();	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");		
require_once("../../includes/controla_secao.php");
require_once("../../class/xmlfile.php");
isPostMethod();		

// Pega opções em que o operador tem permissão
if (isset($glbvars["rotinasTela"])) {
	$rotinasTela = $glbvars["rotinasTela"];
}else{
	exibeErro("Parâmetros incorretos.");
}	

// Se campos necessários para carregar dados não foram informados	
if (!isset($_POST["nrdconta"]))  {
	exibeErro("Parâmetros incorretos.");
}	

$nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
$idseqttl = $_POST["idseqttl"] == "" ? 1 : $_POST["idseqttl"];	
		
// Se conta informada não for um número inteiro válido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inválida.");
}		

// Monta o xml de requisição
$xml  = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0074.p</Bo>';
$xml .= '		<Proc>busca_dados</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
$xml .= '	</Dados>';
$xml .= '</Root>';

// Executa script para envio do XML
$xmlResult = getDataXML($xml);

// Cria objeto para classe de tratamento de XML
$xmlObjeto = getObjectXML($xmlResult);

// Variável que representa o registro
$registro = $xmlObjeto->roottag->tags[0]->tags[0]->tags;

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){
	exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','fechaRotina(divRotina);');
} 

$xml  = "";
$xml .= "<Root>";
$xml .= "  <Dados>";
$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
$xml .= "  </Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "FLGDEVOLU_AUTOM", 'VERIFICA_SIT_DEV_XML', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");
$xmlObjeto1 = getObjectXML($xmlResult);

$flgdevolu_autom = getByTagName($xmlObjeto1->roottag->tags[0]->tags, 'flgdevolu_autom');		

$nmdeacao = "CADCON_CONSULTA_CONTA";

$xml  = "";
$xml .= "<Root>";
$xml .= "  <Dados>";
$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
$xml .= "  </Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "CADCON", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");

$xmlObjeto = simplexml_load_string($xmlResult);

if (isset($xmlObjeto->Erro->Registro->dscritic) && $xmlObjeto->Erro->Registro->dscritic != "") {
	$cdconsul = 0;
	$nmconsul = '';
}

foreach($xmlObjeto->conta as $conta){
	if ($nrdconta == $conta->nrdconta) {
		$cdconsul = $conta->cdconsul;
		$nmconsul = $conta->nmoperad;
	}
}

$cddopcao = ( isset($_POST['cddopcao']) ) ? $_POST['cddopcao'] : 'C';
$nrcpfcgc  = ( isset($_POST['nrcpfcgc']) )  ? $_POST['nrcpfcgc'] : 0;
$cdgraupr = ( isset($_POST['cdgraupr']) )  ? $_POST['cdgraupr'] : '';
$inpessoa = ( isset($_POST['inpessoa']) )  ? $_POST['inpessoa'] : 1;

if($inpessoa == 1){
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0055.p</Bo>';
	$xml .= '		<Proc>busca_dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<cdgraupr>'.$cdgraupr.'</cdgraupr>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
}else{
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0053.p</Bo>";
	$xml .= "		<Proc>busca_dados</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
}

$xmlResult   = getDataXML($xml);	
$xmlObjeto   = getObjectXML($xmlResult);	

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO'){
	exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','fechaRotina(divRotina);',false);	
} 

$identificacao = $xmlObjeto->roottag->tags[0]->tags[0]->tags;

if ($inpessoa == 1) {

	/*RENDAS AUTOMATICAS*/
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';
	$cdnatopc = (isset($_POST['cdnatopc'])) ? $_POST['cdnatopc'] : '';
	$cdocpttl = (isset($_POST['cdocpttl'])) ? $_POST['cdocpttl'] : '';
	$tpcttrab = (isset($_POST['tpcttrab'])) ? $_POST['tpcttrab'] : '';
	$cdempres = (isset($_POST['cdempres'])) ? $_POST['cdempres'] : '';	
	$dsproftl = (isset($_POST['dsproftl'])) ? $_POST['dsproftl'] : '';	
	$cdnvlcgo = (isset($_POST['cdnvlcgo'])) ? $_POST['cdnvlcgo'] : '';	
	$cdturnos = (isset($_POST['cdturnos'])) ? $_POST['cdturnos'] : '';	
	$dtadmemp = (isset($_POST['dtadmemp'])) ? $_POST['dtadmemp'] : '';	
	$vlsalari = (isset($_POST['vlsalari'])) ? $_POST['vlsalari'] : '';	
	$nrcadast = (isset($_POST['nrcadast'])) ? $_POST['nrcadast'] : '';
	$tpdrendi = (isset($_POST['tpdrendi'])) ? $_POST['tpdrendi'] : '';
	$vldrendi = (isset($_POST['vldrendi'])) ? $_POST['vldrendi'] : '';
	$tpdrend2 = (isset($_POST['tpdrend2'])) ? $_POST['tpdrend2'] : '';
	$vldrend2 = (isset($_POST['vldrend2'])) ? $_POST['vldrend2'] : '';
	$tpdrend3 = (isset($_POST['tpdrend3'])) ? $_POST['tpdrend3'] : '';
	$vldrend3 = (isset($_POST['vldrend3'])) ? $_POST['vldrend3'] : '';
	$tpdrend4 = (isset($_POST['tpdrend4'])) ? $_POST['tpdrend4'] : '';
	$vldrend4 = (isset($_POST['vldrend4'])) ? $_POST['vldrend4'] : '';
	$inpolexp = (isset($_POST['inpolexp'])) ? $_POST['inpolexp'] : 0;	
	$nmdsecao = (isset($_POST['nmdsecao'])) ? $_POST['nmdsecao'] : '';

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0075.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';	
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '		<cdnatopc>'.$cdnatopc.'</cdnatopc>';
	$xml .= '		<cdocpttl>'.$cdocpttl.'</cdocpttl>';
	$xml .= '		<tpcttrab>'.$tpcttrab.'</tpcttrab>';	
	$xml .= '		<nmdsecao>'.$nmdsecao.'</nmdsecao>';
	$xml .= '		<cdempres>'.$cdempres.'</cdempres>';	
	$xml .= '		<dsproftl>'.$dsproftl.'</dsproftl>';	
	$xml .= '		<cdnvlcgo>'.$cdnvlcgo.'</cdnvlcgo>';	
	$xml .= '		<cdturnos>'.$cdturnos.'</cdturnos>';	
	$xml .= '		<dtadmemp>'.$dtadmemp.'</dtadmemp>';	
	$xml .= '		<vlsalari>'.$vlsalari.'</vlsalari>';	
	$xml .= '		<nrcadast>'.$nrcadast.'</nrcadast>';	
	$xml .= '		<tpdrendi>'.$tpdrendi.'</tpdrendi>';	
	$xml .= '		<vldrendi>'.$vldrendi.'</vldrendi>';	
	$xml .= '		<tpdrend2>'.$tpdrend2.'</tpdrend2>';	
	$xml .= '		<vldrend2>'.$vldrend2.'</vldrend2>';	
	$xml .= '		<tpdrend3>'.$tpdrend3.'</tpdrend3>';	
	$xml .= '		<vldrend3>'.$vldrend3.'</vldrend3>';	
	$xml .= '		<tpdrend4>'.$tpdrend4.'</tpdrend4>';	
	$xml .= '		<vldrend4>'.$vldrend4.'</vldrend4>';	
	$xml .= '		<inpolexp>'.$inpolexp.'</inpolexp>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);	
	$xmlObjeto = getObjectXML($xmlResult);	

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO'){
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','fechaRotina(divRotina);',false);	
	}

	$comercial = $xmlObjeto->roottag->tags[0]->tags[0]->tags;

}

// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";	
$xml .= "	<Dados>";
$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";	
$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xml .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
$xml .= "		<dtmvtoan>".$glbvars["dtmvtoan"]."</dtmvtoan>";	
$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
$xml .= "		<inproces>".$glbvars["inproces"]."</inproces>";
$xml .= "	</Dados>";
$xml .= "</Root>";
	
// Executa script para envio do XML
$xmlResult = mensageria($xml, "CONTAS", "BUSCA_LANAUT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");     

// Cria objeto para classe de tratamento de XML
$xmlObjeto = getObjectXML($xmlResult);

if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
	$edDtrefere = "";
	$edVlrefere = "";
}else{
	$result = $xmlObjeto->roottag->tags;

	foreach($result as $meses){		
		if( trim(getByTagName($meses->tags,'TotalLancMes')) <> '' ){
			$edDtrefere = getByTagName($meses->tags,'referencia');
			$edVlrefere = getByTagName($meses->tags,'TotalLancMes');
		}
	}
}

/*INFORMACOES ADICIONAIS*/
// Monta o xml de requisição
$xml  = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0048.p</Bo>';
$xml .= '		<Proc>obtem-informacoes-adicionais</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
$xml .= '	</Dados>';
$xml .= '</Root>';

$xmlResult = getDataXML($xml);
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO'){
	exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','fechaRotina(divRotina);',false);	
} 

$infAdicionais = $xmlObjeto->roottag->tags[0]->tags[0]->tags;

$textareaTags = $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->tags;

//Verifico se conta é titular em outra conta. Se atributo vier preenchido, muda operação para 'SC' => Somente Consulta
$msgConta = trim($xmlObjeto->roottag->tags[0]->attributes['MSGCONTA']);
if( $msgConta != '' ) {
	$operacao = ( $operacao != 'CF' ) ? 'SC' : $operacao;
}

include('form_dados_conta.php');

?>
<script type="text/javascript">
	//Guarda a informacao da agencia original da conta
	var cdageant = '<? echo getByTagName($registro,'cdagepac'); ?>';
	//var menorida = "<? echo $menorida; ?>";

	$('#nmctajur', '#frmCabCadcta').val('<? echo getByTagName($identificacao,'nmctajur'); ?>');

</script>