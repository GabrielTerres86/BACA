<?
/*!
 * FONTE        : obtem_dados_avalista.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 03/05/2011
 * OBJETIVO     : Buscar os dados do avalista de modo genérico
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [28/11/2011] David (CECRED) : Não validar permissão. Essa rotina é acionada em várias operações distintas.
 * 002: [22/04/2015] Gabriel (RKAM) : Consultas automatizadas para o limite de credito.
 */
?> 
 
 <?	
	session_start();
	require_once('../config.php');
	require_once('../funcoes.php');		
	require_once('../controla_secao.php');
	require_once('../../class/xmlfile.php');		
	isPostMethod();	
	
	// Se parâmetros necessários não foram informados
	if ( !isset($_POST['nrdconta' ]) || 
	     !isset($_POST['idavalis' ]) || 
		 !isset($_POST['nrctaava' ]) || 
		 !isset($_POST['nrcpfava' ]) ||
		 !isset($_POST['bo'       ]) || 
		 !isset($_POST['procedure']) || 
		 !isset($_POST['nomeForm' ]) ) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

	$bo 		= $_POST['bo'];
	$procedure 	= $_POST['procedure'];
	$nomeForm 	= $_POST['nomeForm'];
	
	$nrdconta 	= $_POST['nrdconta'];
	$idavalis 	= $_POST['idavalis'];
	$nrctaava 	= $_POST['nrctaava'];
	$nrcpfcgc 	= $_POST['nrcpfava'];	
	
	// Validações
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($idavalis)) exibirErro('error','Indicador do avalista inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($nrctaava)) exibirErro('error','Conta/dv do avalista inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($nrcpfcgc)) exibirErro('error','CPF/CNPJ do avalista inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml de requisição
	$xmlGetAvalista  = '';
	$xmlGetAvalista .= '<Root>';
	$xmlGetAvalista .= '	<Cabecalho>';
	$xmlGetAvalista .= '		<Bo>'.$bo.'</Bo>';	
	$xmlGetAvalista .= '		<Proc>'.$procedure.'</Proc>';
	$xmlGetAvalista .= '	</Cabecalho>';
	$xmlGetAvalista .= '	<Dados>';
	$xmlGetAvalista .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xmlGetAvalista .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xmlGetAvalista .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xmlGetAvalista .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xmlGetAvalista .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xmlGetAvalista .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xmlGetAvalista .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xmlGetAvalista .= '		<idseqttl>1</idseqttl>';
	$xmlGetAvalista .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xmlGetAvalista .= '		<nrctaava>'.$nrctaava.'</nrctaava>';
	$xmlGetAvalista .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xmlGetAvalista .= '	</Dados>';
	$xmlGetAvalista .= '</Root>';	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetAvalista);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAvalista = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAvalista->roottag->tags[0]->name) == 'ERRO') {
		exibirErro('error',$xmlObjAvalista->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	} 
	
	$avalista = $xmlObjAvalista->roottag->tags[0]->tags[0]->tags;

	// Verifica se a BO retornou algum avalista e carrega os dados na tela
	if (count($avalista) > 0) {
		
		// Mostrar dados do avalista 
		echo '$("#nrctaav'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'nrctaava').'");';
		echo '$("#nmdaval'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'nmdavali').'");';
        echo '$("#nrcpfav'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'nrcpfcgc').'");';
		echo '$("#tpdocav'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'tpdocava').'");';
		echo '$("#dsdocav'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'nrdocava').'");';
		echo '$("#nmdcjav'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'nmconjug').'");';
		echo '$("#cpfcjav'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'nrcpfcjg').'");';
		echo '$("#tdccjav'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'tpdoccjg').'");';
		echo '$("#doccjav'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'nrdoccjg').'");';
		echo '$("#ende1av'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'dsendre1').'");';
		echo '$("#ende2av'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'dsendre2').'");';
		echo '$("#nrfonav'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'nrfonres').'");';
		echo '$("#emailav'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'dsdemail').'");';
		echo '$("#nmcidav'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'nmcidade').'");';
		echo '$("#cdufava'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'cdufresd').'");';
		echo '$("#nrcepav'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'nrcepend').'");';
		echo '$("#nrender'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'nrendere').'");';
		echo '$("#complen'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'complend').'");';
		echo '$("#nrcxaps'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'nrcxapst').'");';
		echo '$("#inpesso'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'inpessoa').'");';
		echo '$("#vlrenme'.$idavalis.'","#'.$nomeForm.'").val("'.getByTagName($avalista,'vlrenmes').'");';
		echo '$("#nrcpfav'.$idavalis.'","#'.$nomeForm.'").addClassCpfCnpj();';	
		echo '$("#nrctaav'.$idavalis.'","#'.$nomeForm.'").desabilitaCampo();';
		echo '$("#nrctaav'.$idavalis.'","#'.$nomeForm.'").next().removeClass("ativo");';		
	} 	

	echo 'layoutPadrao();';

	echo '$("#nrctaav'.$idavalis.'","#'.$nomeForm.'").trigger("blur");';
	echo '$("#nrcpfav'.$idavalis.'","#'.$nomeForm.'").trigger("blur");';
	echo '$("#cpfcjav'.$idavalis.'","#'.$nomeForm.'").trigger("blur");';
	echo '$("#nrcepav'.$idavalis.'","#'.$nomeForm.'").trigger("blur");';	
	echo '$("#nrender'.$idavalis.'","#'.$nomeForm.'").trigger("blur");';	
	echo '$("#nrcxaps'.$idavalis.'","#'.$nomeForm.'").trigger("blur");';	
	
	echo 'hideMsgAguardo();';
	echo 'bloqueiaFundo(divRotina);';
?>