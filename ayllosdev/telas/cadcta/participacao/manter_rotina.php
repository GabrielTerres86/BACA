<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : 31/08/2011
 * OBJETIVO     : Rotina para validar/incluir/alterar/excluir os dados da empresas participantes da tela de CONTAS
 * ALTERACOES   : 25/11/2011 - Passado parametro idseqttl = 0, pois, os dados foram gravados com sequencial 0. (Fabricio)
 */
?>
 
<?	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();	
	
	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST["operacao"])) ? $_POST["operacao"] : "";		
	
	// Guardo os parâmetos do POST em variáveis
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nmfatasi = (isset($_POST['nmfatasi'])) ? $_POST['nmfatasi'] : '';
	$nmprimtl = (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '';
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '';
	$nrdctato = (isset($_POST['nrdctato'])) ? $_POST['nrdctato'] : '';
	$cdnatjur = (isset($_POST['cdnatjur'])) ? $_POST['cdnatjur'] : '';
	$qtfilial = (isset($_POST['qtfilial'])) ? $_POST['qtfilial'] : '';
	$qtfuncio = (isset($_POST['qtfuncio'])) ? $_POST['qtfuncio'] : '';
	$dtiniatv = (isset($_POST['dtiniatv'])) ? $_POST['dtiniatv'] : '';
	$cdseteco = (isset($_POST['cdseteco'])) ? $_POST['cdseteco'] : '';
	$cdrmativ = (isset($_POST['cdrmativ'])) ? $_POST['cdrmativ'] : '';
	$dsendweb = (isset($_POST['dsendweb'])) ? $_POST['dsendweb'] : '';
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';
	$camposXML = (isset($_POST['camposXML'])) ? $_POST['camposXML'] : '';
	
	$dtadmsoc = (isset($_POST["dtadmsoc"])) ? $_POST["dtadmsoc"] : "";
	$persocio = (isset($_POST["persocio"])) ? $_POST["persocio"] : "";
	$vledvmto = (isset($_POST["vledvmto"])) ? $_POST["vledvmto"] : "";
	
	if(in_array($operacao,array('VA','VI'))) validaDados();
		
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = "";
	switch($operacao) {
		case 'VI': $procedure = 'valida_dados'; $cddopcao = "I";  break;
		case 'VA': $procedure = 'valida_dados'; $cddopcao = "A";  break;
		case 'EV': $procedure = 'valida_dados'; $cddopcao = "E";  break;
		case 'I' : $procedure = 'grava_dados' ; $cddopcao = "I";  break;
		case 'A' : $procedure = 'grava_dados' ; $cddopcao = "A";  break;
		case 'E' : $procedure = 'exclui_dados'; $cddopcao = "E" ; break;
		default: return false;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0080.p</Bo>";
	$xml .= "		<Proc>".$procedure."</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	//$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<idseqttl>0</idseqttl>';
	$xml .= '       <nmprimtl>'.$nmprimtl.'</nmprimtl>';
	$xml .= '       <nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '       <nrdctato>'.$nrdctato.'</nrdctato>';
	$xml .= '       <nmfatasi>'.$nmfatasi.'</nmfatasi>';
	$xml .= '       <cdnatjur>'.$cdnatjur.'</cdnatjur>';
	$xml .= '       <qtfilial>'.$qtfilial.'</qtfilial>';
	$xml .= '       <qtfuncio>'.$qtfuncio.'</qtfuncio>';
	$xml .= '       <dtiniatv>'.$dtiniatv.'</dtiniatv>';
	$xml .= '       <cdseteco>'.$cdseteco.'</cdseteco>';
	$xml .= '       <cdrmativ>'.$cdrmativ.'</cdrmativ>';
	$xml .= '       <dsendweb>'.$dsendweb.'</dsendweb>';
	$xml .= "       <dtadmsoc>".$dtadmsoc."</dtadmsoc>";
	$xml .= "       <nrdrowid>".$nrdrowid."</nrdrowid>";
	$xml .= "		<persocio>".$persocio."</persocio>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "		<vledvmto>".$vledvmto."</vledvmto>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xml);	
	$xmlObjeto = getObjectXML($xmlResult);
	
	$saida =  ( $operacao == 'EV' || $operacao == 'E' ) ? 'controlaOperacao();' : 'bloqueiaFundo(divRotina);' ;
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$saida,false);	
			
	$msg = Array();
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];	
	$msgAlerta  = $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'];
	
	
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	
	$stringArrayMsg = implode( "|", $msg);
		
	// Verificação da revisão Cadastral
	$msgAtCad = $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'];
	$chaveAlt = $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'];
	$tpAtlCad = $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'];	
	
	// Se é Validação
	if(in_array($operacao,array('VI','VA','EV'))) {		
				
		if ( $msgAlerta != '' ) exibirErro('inform',$msgAlerta,'Alerta - Ayllos','bloqueiaFundo(divConfirm)',false);		
		if($operacao=='VI') exibirConfirmacao('Deseja confirmar inclusão?','Confirmação - Ayllos','controlaOperacao(\'VI\')','bloqueiaFundo(divRotina)',false);	
		if($operacao=='VA') exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Ayllos','controlaOperacao(\'VA\')','bloqueiaFundo(divRotina)',false);
		if($operacao=='EV') exibirConfirmacao('Deseja confirmar exclusão?','Confirmação - Ayllos','controlaOperacao(\'E\')','controlaOperacao(\'EC\')',false);
		
	// Se é Inclusão ou Alteração
	} else {
	
		// Verificar se existe "Verificação de Revisão Cadastral"
		if($msgAtCad!='') {
		
			if($operacao=='I') exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0080.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"CT\")\')',false);
			if($operacao=='A') exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0080.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"CT\")\')',false);
			
		// Se não existe necessidade de Revisão Cadastral
		} else {	
		
			// Chama o controla Operação Finalizando a Inclusão ou Alteração			
		   echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"CT\")\');';
		   
			
		}
	} 
	
	function validaDados() {
		echo '$("input,select","#frmParticipacaoEmpresas").removeClass("campoErro");';		
				
		if ( $GLOBALS['nrcpfcgc'] == '' ) exibirErro('error','CNPJ inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrcpfcgc\',\'frmParticipacaoEmpresas\')',false);

		// Nomes
		if ( $GLOBALS['nmprimtl'] == '' ) exibirErro('error','Raz&atilde;o social deve ser informado.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nmprimtl\',\'frmParticipacaoEmpresas\')',false);
		if ( $GLOBALS['nmfatasi'] == '' ) exibirErro('error','Nome Fantasia deve ser informado.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nmfatasi\',\'frmParticipacaoEmpresas\')',false);
	

		// Dt. Início Atividade
		if (!validaData($GLOBALS['dtiniatv'])) exibirErro('error','Data de In&iacute;cio Atividade inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtiniatv\',\'frmParticipacaoEmpresas\')',false);

		// Natureza Jurídica
		if (!validaInteiro($GLOBALS['cdnatjur'])) exibirErro('error','Natureza Jur&iacute;dica inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdnatjur\',\'frmParticipacaoEmpresas\')',false);
		if ($GLOBALS['cdnatjur'] == 0) exibirErro('error','Natureza Jur&iacute;dica deve ser diferente de zero.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdnatjur\',\'frmParticipacaoEmpresas\')',false);

		// Setor Econômico
		if (!validaInteiro($GLOBALS['cdseteco'])) exibirErro('error','Setor Econ&ocirc;mico inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdseteco\',\'frmParticipacaoEmpresas\')',false);
		if ($GLOBALS['cdseteco'] < 1 || $cdseteco > 4) exibirErro('error','Setor Econ&ocirc;mico inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdseteco\',\'frmParticipacaoEmpresas\')',false);

		// Ramo Atividade
		if (!validaInteiro($GLOBALS['cdrmativ'])) exibirErro('error','Ramo de Atividade inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdrmativ\',\'frmParticipacaoEmpresas\')',false);
		if ($GLOBALS['cdrmativ'] == 0) exibirErro('error','Ramo de Atividade deve ser diferente de zero.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdrmativ\',\'frmParticipacaoEmpresas\')',false);
	}
?>