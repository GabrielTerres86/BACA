<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 15/09/2010 
 * OBJETIVO     : Rotina para validar/incluir/alterar/excluir os dados dos Procuradores (Pessoal Física)
 *                23/04/2012 - Incluido os parametros dthabmen, inhabmen, nmrotina
 *							   para as procedures valida_dados, grava_Dados (Adriano).
 *                03/09/2015 - Reformulacao cadastral (Gabriel-RKAM)
 *                25/04/2017 - Alterado campo dsnacion para cdnacion. (Projeto 339 - Odirlei-AMcom)
 *                18/10/2017 - Removendo caixa postal. (PRJ339 - Kelvin)
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
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';		
	
	// Guardo os parâmetos do POST em variáveis
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '';
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';
	$cdoeddoc = (isset($_POST['cdoeddoc'])) ? $_POST['cdoeddoc'] : '';
	$dtnascto = (isset($_POST['dtnascto'])) ? $_POST['dtnascto'] : '';
	$dtemddoc = (isset($_POST['dtemddoc'])) ? $_POST['dtemddoc'] : '';
	$nrdctato = (isset($_POST['nrdctato'])) ? $_POST['nrdctato'] : '';
	$nmdavali = (isset($_POST['nmdavali'])) ? $_POST['nmdavali'] : '';
	$cdufddoc = (isset($_POST['cdufddoc'])) ? $_POST['cdufddoc'] : '';
	$tpdocava = (isset($_POST['tpdocava'])) ? $_POST['tpdocava'] : '';
	$nrdocava = (isset($_POST['nrdocava'])) ? $_POST['nrdocava'] : '';
	$cdestcvl = (isset($_POST['cdestcvl'])) ? $_POST['cdestcvl'] : '';
	$cdnacion = (isset($_POST['cdnacion'])) ? $_POST['cdnacion'] : '';
	$dsnatura = (isset($_POST['dsnatura'])) ? $_POST['dsnatura'] : '';
	$complend = (isset($_POST['complend'])) ? $_POST['complend'] : '';
	$nmcidade = (isset($_POST['nmcidade'])) ? $_POST['nmcidade'] : '';
	$nmbairro = (isset($_POST['nmbairro'])) ? $_POST['nmbairro'] : '';
	$dsendres = (isset($_POST['dsendres'])) ? $_POST['dsendres'] : '';
	$nmpaicto = (isset($_POST['nmpaicto'])) ? $_POST['nmpaicto'] : '';
	$nmmaecto = (isset($_POST['nmmaecto'])) ? $_POST['nmmaecto'] : '';
	$nrendere = (isset($_POST['nrendere'])) ? $_POST['nrendere'] : '';
	$nrcepend = (isset($_POST['nrcepend'])) ? $_POST['nrcepend'] : '';
	$dsrelbem = (isset($_POST['dsrelbem'])) ? $_POST['dsrelbem'] : '';
	$dtvalida = (isset($_POST['dtvalida'])) ? $_POST['dtvalida'] : '';
	$vledvmto = (isset($_POST['vledvmto'])) ? $_POST['vledvmto'] : '';
	$cdsexcto = (isset($_POST['cdsexcto'])) ? $_POST['cdsexcto'] : '';
	$cdufresd = (isset($_POST['cdufresd'])) ? $_POST['cdufresd'] : '';	
	$dthabmen = (isset($_POST['dthabmen'])) ? $_POST['dthabmen'] : '';
	$inhabmen = (isset($_POST['inhabmen'])) ? $_POST['inhabmen'] : '';
	$dadosXML = (isset($_POST['dadosXML'])) ? $_POST['dadosXML'] : '';
	$camposXML = (isset($_POST['camposXML'])) ? $_POST['camposXML'] : '';
	
	if(in_array($operacao,array('VA','VI'))) validaDados();
		
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';
	switch($operacao) {
	
		case 'VI': $procedure = 'valida_dados'; $cddopcao = 'I';  break;
		case 'VA': $procedure = 'valida_dados'; $cddopcao = 'A';  break;
		case 'EV': $procedure = 'valida_dados'; $cddopcao = 'E';  break;
		case 'I' : $procedure = 'grava_dados' ; $cddopcao = 'I';  break;
		case 'A' : $procedure = 'grava_dados' ; $cddopcao = 'A';  break;
		case 'E' : $procedure = 'exclui_dados'; $cddopcao = 'E' ; break;
		default: return false;
		
	}
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0058.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '       <nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '       <cdoeddoc>'.$cdoeddoc.'</cdoeddoc>';
	$xml .= '       <dtnascto>'.$dtnascto.'</dtnascto>';
	$xml .= '       <dtemddoc>'.$dtemddoc.'</dtemddoc>';
	$xml .= '       <nrdctato>'.$nrdctato.'</nrdctato>';
	$xml .= '       <nmdavali>'.$nmdavali.'</nmdavali>';
	$xml .= '       <cdufddoc>'.$cdufddoc.'</cdufddoc>';
	$xml .= '       <tpdocava>'.$tpdocava.'</tpdocava>';
	$xml .= '       <nrdocava>'.$nrdocava.'</nrdocava>';
	$xml .= '       <cdestcvl>'.$cdestcvl.'</cdestcvl>';
	$xml .= '       <cdnacion>'.$cdnacion.'</cdnacion>';
	$xml .= '       <dsnatura>'.$dsnatura.'</dsnatura>';
	$xml .= '       <complend>'.$complend.'</complend>';
	$xml .= '       <nmcidade>'.$nmcidade.'</nmcidade>';
	$xml .= '       <nmbairro>'.$nmbairro.'</nmbairro>';
	$xml .= '       <dsendres>'.$dsendres.'</dsendres>';
	$xml .= '       <nmpaicto>'.$nmpaicto.'</nmpaicto>';
	$xml .= '       <nmmaecto>'.$nmmaecto.'</nmmaecto>';
	$xml .= '       <nrendere>'.$nrendere.'</nrendere>';
	$xml .= '       <nrcepend>'.$nrcepend.'</nrcepend>';
	$xml .= '       <dsrelbem>'.$dsrelbem.'</dsrelbem>';
	$xml .= '       <dtvalida>'.$dtvalida.'</dtvalida>';
	$xml .= '       <vledvmto>'.$vledvmto.'</vledvmto>';
	$xml .= '       <cdsexcto>'.$cdsexcto.'</cdsexcto>';
	$xml .= '       <cdufresd>'.$cdufresd.'</cdufresd>';
	$xml .= '       <nrcxapst> 0 </nrcxapst>';
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '       <nrdrowid>'.$nrdrowid.'</nrdrowid>';
		
	if($procedure == 'valida_dados' ||
	   $procedure == 'grava_dados'){
	   
		$xml .= '       <dthabmen>'.$dthabmen.'</dthabmen>';
		$xml .= '       <inhabmen>'.$inhabmen.'</inhabmen>';
		$xml .= '       <nmrotina>PROCURADORES_FISICA</nmrotina>';
	}
	
	$xml .= retornaXmlFilhos( $camposXML, $dadosXML, 'Bens', 'Itens');
	$xml .= '	</Dados>';
	$xml .= '</Root>';
			
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xml);	
	$xmlObjeto = getObjectXML($xmlResult);
	
	
	$saida =  ( $operacao == 'EV' || $operacao == 'E' ) ? 'controlaOperacaoProcuradores();' : 'bloqueiaFundo(divRotina);' ;
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$saida,false);	
			
	$msg = Array();
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];	
	$msgAlerta  = $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'];
	
	
	
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	
	$stringArrayMsg = implode( '|', $msg);
		
	// Verificação da revisão Cadastral
	$msgAtCad = $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'];
	$chaveAlt = $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'];
	$tpAtlCad = $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'];	
	
	// Se é Validação
	if(in_array($operacao,array('VI','VA','EV'))) {		
				
		if ( $msgAlerta != '' ) exibirErro('inform',$msgAlerta,'Alerta - Ayllos','bloqueiaFundo(divConfirm)',false);		
		if($operacao=='VI') exibirConfirmacao('Deseja confirmar inclusão?','Confirmação - Ayllos','controlaOperacaoProcuradores(\'VI\')','bloqueiaFundo(divRotina)',false);	
		if($operacao=='VA') exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Ayllos','controlaOperacaoProcuradores(\'VA\')','bloqueiaFundo(divRotina)',false);
		if($operacao=='EV') exibirConfirmacao('Deseja confirmar exclusão?','Confirmação - Ayllos','controlaOperacaoProcuradores(\'E\')','controlaOperacaoProcuradores(\'EC\')',false);
		
	// Se é Inclusão ou Alteração
	} else {
		
		// Chamar rotina de PODERES na inclusao
		$metodo = ($operacao == 'I') ? "cpfPoderes = '$nrcpfcgc'; controlaOperacaoProcuradores(\"CTP\");" : "controlaOperacaoProcuradores(\"\");";
	
		// Verificar se existe "Verificação de Revisão Cadastral"
		if($msgAtCad!='') {
		
			if($operacao=='I') exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0058.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoProcuradores(\"\")\')',false);
			if($operacao=='A') exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0058.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoProcuradores(\"\")\')',false);
			
		// Se não existe necessidade de Revisão Cadastral
		} else {	
		
			// Chama o controla Operação Finalizando a Inclusão ou Alteração			
		   echo 'exibirMensagens("' . $stringArrayMsg . '");';
		   echo $metodo;
		   
			
		}
	} 
	
	function validaDados(){
		
		echo '$("input,select","#frmDadosProcuradores").removeClass("campoErro");';
	
		//Campo nome do represem.
		if ($GLOBALS['nmdavali']=='') exibirErro('error','Nome inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nmdavali\',\'frmDadosProcuradores\')',false);
				
		// Data Nascimento
		if (!validaData($GLOBALS['dtnascto'])) exibirErro('error','Data de Nascimento inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtnascto\',\'frmDadosProcuradores\')',false);
		
		// Número da conta e o titular são inteiros válidos
		if (!validaInteiro($GLOBALS['nrdctato'])) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
				
		// Tipo de Documento
		if (!in_array($GLOBALS['tpdocava'],array('CH','CI','CP','CT'))) exibirErro('error','Tipo de Documento inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'tpdocava\',\'frmDadosProcuradores\')',false);
		
		// Numero de Documento
		if ($GLOBALS['nrdocava']=='') exibirErro('error','Nr. Documento inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrdocava\',\'frmDadosProcuradores\')',false);
		
		// Orgão Emissor
		if ($GLOBALS['cdoeddoc']=='') exibirErro('error','Org&atilde;o Emissor inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdoeddoc\',\'frmDadosProcuradores\')',false);
		
		// UF Emissor
		if ($GLOBALS['cdufddoc']=='') exibirErro('error','U.F. Emissor inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdufddoc\',\'frmDadosProcuradores\')',false);		
		
		// Data Emissão
		if (!validaData($GLOBALS['dtemddoc'])) exibirErro('error','Data de Emiss&atilde;o inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtemddoc\',\'frmDadosProcuradores\')',false);
		
		// Estado Civil
		if (!validaInteiro($GLOBALS['cdestcvl'])) exibirErro('error','Estado Civil inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdestcvl\',\'frmDadosProcuradores\')',false);
		
		// Sexo 
		if (($GLOBALS['cdsexcto'] != 1)&&($GLOBALS['cdsexcto'] != 2)) exibirErro('error','Sexo inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'sexoMas\',\'frmDadosProcuradores\')',false);
		
		// Nacionalidade
		if ($GLOBALS['cdnacion']=='') exibirErro('error','Nacionalidade inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdnacion\',\'frmDadosProcuradores\')',false);
		
		// Naturalidade
		if ($GLOBALS['dsnatura']=='') exibirErro('error','Naturalidade inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dsnatura\',\'frmDadosProcuradores\')',false);
		
		//CEP
		if ( $GLOBALS['nrcepend'] == '' || $GLOBALS['nrcepend'] == 0 ) exibirErro('error','CEP inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrcepend\',\'frmDadosProcuradores\')',false);

		//End. residencial
		if ($GLOBALS['dsendres']=='') exibirErro('error','End. residencial inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dsendres\',\'frmDadosProcuradores\')',false);
		
		//Numer. residencial
		if (!validaInteiro($GLOBALS['nrendere'])) exibirErro('error','Nr. residencial inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrendere\',\'frmDadosProcuradores\')',false);
				
		//Bairro
		if ($GLOBALS['nmbairro']=='') exibirErro('error','Bairro inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nmbairro\',\'frmDadosProcuradores\')',false);

		// UF Emissor
		if ($GLOBALS['cdufresd']=='') exibirErro('error','U.F. Endere&ccedil;o inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdufresd\',\'frmDadosProcuradores\')',false);		
		
		//Cidade
		if ($GLOBALS['nmcidade']=='') exibirErro('error','Cidade inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nmcidade\',\'frmDadosProcuradores\')',false);
		
		// Filiação Mãe
		if ($GLOBALS['nmmaecto']=='') exibirErro('error','Nome da m&atilde;e inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nmmaecto\',\'frmDadosProcuradores\')',false);		
		
		// Data Vigência
		if (!validaData($GLOBALS['dtvalida'])) exibirErro('error','Data de Vig&ecirc;ncia inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtvalida\',\'frmDadosProcuradores\')',false);
		
	}
?>
