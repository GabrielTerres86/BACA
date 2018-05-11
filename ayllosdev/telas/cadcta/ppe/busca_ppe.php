<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();				
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';	
	$opcao    = (isset($_POST['opcao']))    ? $_POST['opcao']    : '';
	
	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];
	
	// Monta o "cddopcao" de acordo com a operação
	$cddopcao = 'C';
	$op       = '@';


	// Verifica se o número da conta foi informado
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','fechaRotina(divRotina)',false);

	
	setVarSession("opcoesTela",$opcoesTela);

	// Carregas as opções da Rotina de Bens
	$flgAlterar  = (in_array("A", $glbvars["opcoesTela"]));
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = $_POST['nrdconta'] == '' ?  0  : $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'] == '' ?  0  : $_POST['idseqttl'];
	$nomeForm = $_POST['nomeform'] == '' ?  0  : $_POST['nomeform'];
		
	$cooperativa = $glbvars['cdcooper'];
			

	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','fechaRotina(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl n&atilde;o foi informada.','Alerta - Ayllos','fechaRotina(divRotina)',false);
	

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0075.p</Bo>';
	$xml .= '		<Proc>Busca_Dados_PPE</Proc>';
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
	$xml .= '		<nrcadast>'.$nrcadast.'</nrcadast>';
	$xml .= '		<inpolexp>'.$inpolexp.'</inpolexp>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);	
	$xmlObjeto = getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') 
	exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','fechaRotina(divRotina);',false);	
	
	
	$ppe = $xmlObjeto->roottag->tags[0]->tags[0]->tags;	
	$msgAlert  = trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']);	
	
	
	$inpolexp = getByTagName($ppe,'inpolexp');
	echo "<script>$('#".$nomeForm."').append('<input type=\"hidden\" id=\"inpolexp\" name=\"inpolexp\" value=\"".$inpolexp."\" />');</script>";
	
    if ($inpolexp == 2) {
		exibirErro('error','A definição de pessoa exposta politicamente está pendente no cadastro.','Alerta - Ayllos','fechaRotina(divRotina);',true);
	}
	
	$tpexposto        = getByTagName($ppe,'tpexposto');
	$cdocupacao       = getByTagName($ppe,'cdocupacao');
	$cdrelacionamento = getByTagName($ppe,'cdrelacionamento');
	$dtinicio         = getByTagName($ppe,'dtinicio');
	$dttermino        = getByTagName($ppe,'dttermino');
	$nmempresa        = getByTagName($ppe,'nmempresa');
	$nrcnpj_empresa   = getByTagName($ppe,'nrcnpj_empresa');
	$nmpolitico       = getByTagName($ppe,'nmpolitico');
	$nrcpf_politico   = getByTagName($ppe,'nrcpf_politico');	
	$nmextttl         = getByTagName($ppe,'nmextttl');
	$nrcpfcgc         = getByTagName($ppe,'nrcpfcgc');
	$rsdocupa         = getByTagName($ppe,'rsdocupa');
	$dsrelacionamento = getByTagName($ppe,'dsrelacionamento');
	$nrdconta         = getByTagName($ppe,'nrdconta');
	$cidade           = getByTagName($ppe,'cidade');

	echo "<script>$('#".$nomeForm."').append('<input type=\"hidden\" id=\"tpexposto\" name=\"tpexposto\" value=\"".$tpexposto."\" />');";
	echo "$('#".$nomeForm."').append('<input type=\"hidden\" id=\"cdocupacao\" name=\"cdocupacao\" value=\"".$cdocupacao."\" />');";
	echo "$('#".$nomeForm."').append('<input type=\"hidden\" id=\"cdrelacionamento\" name=\"cdrelacionamento\" value=\"".$cdrelacionamento."\" />');";
	echo "$('#".$nomeForm."').append('<input type=\"hidden\" id=\"dtinicio\" name=\"dtinicio\" value=\"".$dtinicio."\" />');";
	echo "$('#".$nomeForm."').append('<input type=\"hidden\" id=\"dttermino\" name=\"dttermino\" value=\"".$dttermino."\" />');";
	echo "$('#".$nomeForm."').append('<input type=\"hidden\" id=\"nmempresa\" name=\"nmempresa\" value=\"".$nmempresa."\" />');";
	echo "$('#".$nomeForm."').append('<input type=\"hidden\" id=\"nrcnpj_empresa\" name=\"nrcnpj_empresa\" value=\"". formatar($nrcnpj_empresa,'cnpj',true) ."\" />');";
	echo "$('#".$nomeForm."').append('<input type=\"hidden\" id=\"nmpolitico\" name=\"nmpolitico\" value=\"".$nmpolitico."\" />');";
	echo "$('#".$nomeForm."').append('<input type=\"hidden\" id=\"nrcpf_politico\" name=\"nrcpf_politico\" value=\"". formatar($nrcpf_politico,'cpf',true) ."\" />');";	
	echo "$('#".$nomeForm."').append('<input type=\"hidden\" id=\"nmextttl\" name=\"nmextttl\" value=\"".$nmextttl."\" />');";
	echo "$('#".$nomeForm."').append('<input type=\"hidden\" id=\"nrcpfcgc\" name=\"nrcpfcgc\" value=\"". formatar($nrcpfcgc,'cpf',true) ."\" />');";
	echo "$('#".$nomeForm."').append('<input type=\"hidden\" id=\"rsocupa\" name=\"rsocupa\" value=\"". $rsdocupa ."\" />');";
	echo "$('#".$nomeForm."').append('<input type=\"hidden\" id=\"cidade\" name=\"cidade\" value=\"". $cidade ."\" />');";
	echo "$('#".$nomeForm."').append('<input type=\"hidden\" id=\"dsrelacionamento\" name=\"dsrelacionamento\" value=\"". $dsrelacionamento ."\" />');</script>";
?>