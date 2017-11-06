<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Mostrar opcao Principal da rotina de Impedimentos Desligamento da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 
 * --------------

 */	
?>

<?	
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();	
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
	
	switch( $operacao ) {
		case 'CA': $op = "A"; break;
		case 'AC': $op = "@"; break;
		case ''  : $op = "@"; break;
		default  : $op = "@"; break;
	}
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$op)) <> "") exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	$nrdconta = ( isset($_POST['nrdconta']) ) ? $_POST['nrdconta'] : 0;
	$idseqttl = ( isset($_POST['idseqttl']) ) ? $_POST['idseqttl'] : 0;


	// Monta o xml de requisição
	$xmlBuscaServicos  = "";
	$xmlBuscaServicos .= "<Root>";
	$xmlBuscaServicos .= "   <Dados>";
	$xmlBuscaServicos .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlBuscaServicos .= "   </Dados>";
	$xmlBuscaServicos .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscaServicos, "MATRIC", "SERVICOS_OFERECIDOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		
	// Cria objeto para classe de tratamento de XML
	$xmlObjServicos = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjServicos->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjServicos->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);fechaRotina(divRotina);');
	}
		
	//Pega todos os servicos essenciais
	$regServicosObrigatorios = $xmlObjServicos->roottag->tags[0]->tags[1]->tags;		
	$regServicosOpcionais = $xmlObjServicos->roottag->tags[1]->tags[1]->tags;
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0197.p</Bo>';
	$xml .= '		<Proc>busca_inf_produtos</Proc>';
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
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult   = getDataXML($xml);	
	$xmlObjServicos2   = getObjectXML($xmlResult);	
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjServicos2->roottag->tags[0]->name) == 'ERRO') {
		exibirErro('error',$xmlObjServicos2->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);fechaRotina(divRotina);',false);
	}

	//Pega todos os servicos essenciais
	$regServicos2 = $xmlObjServicos2->roottag->tags[0]->tags[0];

	$xmlEmprestimos .= "<Root>";
	$xmlEmprestimos .= " <Dados>";
	$xmlEmprestimos .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
	$xmlEmprestimos .= "   <nriniseq>1</nriniseq>";
	$xmlEmprestimos .= "   <nrregist>999</nrregist>";
	$xmlEmprestimos .= " </Dados>";
	$xmlEmprestimos .= "</Root>";

	$xmlResultEmprestimos = mensageria($xmlEmprestimos, "TELA_COBEMP", "BUSCA_CONTRATOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjEmprestimos = getObjectXML($xmlResultEmprestimos);
	
	$emprestimos = $xmlObjEmprestimos->roottag->tags[0]->tags;
	
	 foreach ($emprestimos as $r) {
		
		$inprejuz = getByTagName($r->tags, 'inprejuz');
		
		// se esta em prejuizo
		if ($inprejuz == 1){
			$valor_emprestimos += getByTagName($r->tags, 'vlpreemp');
		}else{
			$valor_emprestimos += getByTagName($r->tags, 'vlsdeved');
		}
	}
	
	include('form_impedimentos_desligamento.php');
	
?>
<script type='text/javascript'>
	var operacao = '<? echo $operacao;  ?>';
	controlaLayout(operacao);
</script>
