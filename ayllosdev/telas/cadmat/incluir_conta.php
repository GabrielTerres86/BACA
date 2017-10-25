<?php
/*!
 * FONTE        : valida_inclusao.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 11/10/2017
 * OBJETIVO     : Rotina para validar a inclusao de contas na tela CADMAT
 * --------------
 * ALTERAÇÕES	: 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	// Recebendo as variáveis
	$nrcpfcgc = isset($_POST['nrcpfcgc']) ? $_POST['nrcpfcgc'] : '';
	$nrdconta = isset($_POST['nrdconta']) ? $_POST['nrdconta'] : '';
	$inpessoa = isset($_POST['inpessoa']) ? $_POST['inpessoa'] : '';
	$nmprimtl = isset($_POST['nmprimtl']) ? $_POST['nmprimtl'] : '';
	$cdagepac = isset($_POST['cdagepac']) ? $_POST['cdagepac'] : '';
	$cdempres = isset($_POST['cdempres']) ? $_POST['cdempres'] : '';
	$inmatric = isset($_POST['inmatric']) ? $_POST['inmatric'] : '';
	$tpdocptl = isset($_POST['tpdocptl']) ? $_POST['tpdocptl'] : '';
	$nrdocptl = isset($_POST['nrdocptl']) ? $_POST['nrdocptl'] : '';
	$nmttlrfb = isset($_POST['nmttlrfb']) ? $_POST['nmttlrfb'] : '';
	$cdsitcpf = isset($_POST['cdsitcpf']) ? $_POST['cdsitcpf'] : '';
	$dtcnscpf = isset($_POST['dtcnscpf']) ? $_POST['dtcnscpf'] : '';
	$dsdemail = isset($_POST['dsdemail']) ? $_POST['dsdemail'] : '';
	$dsnacion = isset($_POST['dsnacion']) ? $_POST['dsnacion'] : '';
	$inhabmen = isset($_POST['inhabmen']) ? $_POST['inhabmen'] : '';
	$dthabmen = isset($_POST['dthabmen']) ? $_POST['dthabmen'] : '';
	$cdestcvl = isset($_POST['cdestcvl']) ? $_POST['cdestcvl'] : '';
	$tpnacion = isset($_POST['tpnacion']) ? $_POST['tpnacion'] : '';
	$cdnacion = isset($_POST['cdnacion']) ? $_POST['cdnacion'] : '';
	$cdoedptl = isset($_POST['cdoedptl']) ? $_POST['cdoedptl'] : '';
	$cdufdptl = isset($_POST['cdufdptl']) ? $_POST['cdufdptl'] : '';
	$dtemdptl = isset($_POST['dtemdptl']) ? $_POST['dtemdptl'] : '';
	$dtnasctl = isset($_POST['dtnasctl']) ? $_POST['dtnasctl'] : '';
	$nmconjug = isset($_POST['nmconjug']) ? $_POST['nmconjug'] : '';
	$nmmaettl = isset($_POST['nmmaettl']) ? $_POST['nmmaettl'] : '';
	$nmpaittl = isset($_POST['nmpaittl']) ? $_POST['nmpaittl'] : '';
	$dsnatura = isset($_POST['dsnatura']) ? $_POST['dsnatura'] : '';
	$cdufnatu = isset($_POST['cdufnatu']) ? $_POST['cdufnatu'] : '';
	$nrdddres = isset($_POST['nrdddres']) ? $_POST['nrdddres'] : '';
	$nrtelres = isset($_POST['nrtelres']) ? $_POST['nrtelres'] : '';
	$cdopetfn = isset($_POST['cdopetfn']) ? $_POST['cdopetfn'] : '';
	$nrdddcel = isset($_POST['nrdddcel']) ? $_POST['nrdddcel'] : '';
	$nrtelcel = isset($_POST['nrtelcel']) ? $_POST['nrtelcel'] : '';
	$nrcepend = isset($_POST['nrcepend']) ? $_POST['nrcepend'] : '';
	$dsendere = isset($_POST['dsendere']) ? $_POST['dsendere'] : '';
	$nrendere = isset($_POST['nrendere']) ? $_POST['nrendere'] : '';
	$complend = isset($_POST['complend']) ? $_POST['complend'] : '';
	$nmbairro = isset($_POST['nmbairro']) ? $_POST['nmbairro'] : '';
	$cdufende = isset($_POST['cdufende']) ? $_POST['cdufende'] : '';
	$nmcidade = isset($_POST['nmcidade']) ? $_POST['nmcidade'] : '';
	$idorigee = isset($_POST['idorigee']) ? $_POST['idorigee'] : '';
	$cdocpttl = isset($_POST['cdocpttl']) ? $_POST['cdocpttl'] : '';
	$nrcadast = isset($_POST['nrcadast']) ? $_POST['nrcadast'] : '';
	$cdsexotl = isset($_POST['cdsexotl']) ? $_POST['cdsexotl'] : '';
	$idorgexp = isset($_POST['idorgexp']) ? $_POST['idorgexp'] : '';
	$nmfansia = isset($_POST['nmfansia']) ? $_POST['nmfansia'] : '';
	$nrdddtfc = isset($_POST['nrdddtfc']) ? $_POST['nrdddtfc'] : '';
	$nrtelefo = isset($_POST['nrtelefo']) ? $_POST['nrtelefo'] : '';
	$nrinsest = isset($_POST['nrinsest']) ? $_POST['nrinsest'] : '';
	$nrlicamb = isset($_POST['nrlicamb']) ? $_POST['nrlicamb'] : '';
	$natjurid = isset($_POST['natjurid']) ? $_POST['natjurid'] : '';
	$cdseteco = isset($_POST['cdseteco']) ? $_POST['cdseteco'] : '';
	$cdrmativ = isset($_POST['cdrmativ']) ? $_POST['cdrmativ'] : '';
	$cdcnae   = isset($_POST['cdcnae']) ? $_POST['cdcnae'] : '';
	$dtiniatv = isset($_POST['dtiniatv']) ? $_POST['dtiniatv'] : '';
	$dtdebito = isset($_POST['dtdebito']) ? $_POST['dtdebito'] : '';
	$qtparcel = isset($_POST['qtparcel']) ? $_POST['qtparcel'] : '';
	$vlparcel = isset($_POST['vlparcel']) ? $_POST['vlparcel'] : '';
	$hrinicad = isset($_POST['hrinicad']) ? $_POST['hrinicad'] : '';
	
	//CPF Responsabilidade social		
	// if( verificaCpfCnpjBloqueado($glbvars['cdcooper'], $glbvars['cdpactra'], $glbvars['nrdcaixa'], $glbvars['idorigem'], $glbvars['cdoperad'], $inpessoa, $nrcpfcgc )){			
		// exibirErro('error','CPF n&atilde;o autorizado, conforme previsto na Pol&iacute;tica de Responsabilidade Socioambiental do Sistema CECRED.','Alerta - Ayllos','',false);
	// }
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0052.p</Bo>';
	$xml .= '		<Proc>grava_dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdpactra'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '       <idseqttl>1</idseqttl>';
	$xml .= '       <flgerlog>false</flgerlog>';
	$xml .= '       <cddopcao>I</cddopcao>';
	$xml .= '       <dtmvtolt>'.$glbvars["dtmvtolt"].'</dtmvtolt>';
	$xml .= '       <dtmvtoan>'.$glbvars["dtmvtoan"].'</dtmvtoan>';
	$xml .= '       <rowidass></rowidass>';
	$xml .= '       <inpessoa>'.$inpessoa.'</inpessoa>';
	$xml .= '       <cdagepac>'.$cdagepac.'</cdagepac>';
	$xml .= '       <nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '       <nmprimtl>'.$nmprimtl.'</nmprimtl>';
	$xml .= '       <nmpaittl>'.$nmpaittl.'</nmpaittl>';
	$xml .= '       <nmmaettl>'.$nmmaettl.'</nmmaettl>';
	$xml .= '       <nmconjug>'.$nmconjug.'</nmconjug>';
	$xml .= '       <cdempres>'.$cdempres.'</cdempres>';
	$xml .= '       <cdsexotl>'.$cdsexotl.'</cdsexotl>';
	$xml .= '       <cdsitcpf>'.$cdsitcpf.'</cdsitcpf>';
	$xml .= '       <dtcnscpf>'.$glbvars["dtmvtolt"].'</dtcnscpf>';
	$xml .= '       <dtnasctl>'.$dtnasctl.'</dtnasctl>';
	$xml .= '       <tpnacion>'.$tpnacion.'</tpnacion>';
	$xml .= '       <cdnacion>'.$cdnacion.'</cdnacion>';
	$xml .= '       <dsnatura>'.$dsnatura.'</dsnatura>';
	$xml .= '       <cdufnatu>'.$cdufnatu.'</cdufnatu>';
	$xml .= '       <cdocpttl>'.$cdocpttl.'</cdocpttl>';
	$xml .= '       <rowidcem></rowidcem>';
	$xml .= '       <dsdemail>'.$dsdemail.'</dsdemail>';
	$xml .= '       <nrdddres>'.$nrdddres.'</nrdddres>';
	$xml .= '       <nrtelres>'.$nrtelres.'</nrtelres>';
	$xml .= '       <nrdddcel>'.$nrdddcel.'</nrdddcel>';
	$xml .= '       <nrtelcel>'.$nrtelcel.'</nrtelcel>';
	$xml .= '       <cdopetfn>'.$cdopetfn.'</cdopetfn>';
	$xml .= '       <cdcnae>'.$cdcnae.'</cdcnae>';
	$xml .= '       <cdestcvl>'.$cdestcvl.'</cdestcvl>';
	$xml .= '       <dsproftl></dsproftl>';
	$xml .= '       <nmdsecao></nmdsecao>';
	$xml .= '       <nrcadast>'.$nrcadast.'</nrcadast>';
	$xml .= '       <tpdocptl>'.$tpdocptl.'</tpdocptl>';
	$xml .= '       <nrdocptl>'.$nrdocptl.'</nrdocptl>';
	$xml .= '       <cdoedptl>'.$cdoedptl.'</cdoedptl>';
	$xml .= '       <cdufdptl>'.$cdufdptl.'</cdufdptl>';
	$xml .= '       <dtemdptl>'.$dtemdptl.'</dtemdptl>';
	$xml .= '       <dtdemiss></dtdemiss>';
	$xml .= '       <cdmotdem></cdmotdem>';
	$xml .= '       <cdufende>'.$cdufende.'</cdufende>';
	$xml .= '       <dsendere>'.$dsendere.'</dsendere>';
	$xml .= '       <nrendere>'.$nrendere.'</nrendere>';
	$xml .= '       <nmbairro>'.$nmbairro.'</nmbairro>';
	$xml .= '       <nmcidade>'.$nmcidade.'</nmcidade>';
	$xml .= '       <complend>'.$complend.'</complend>';
	$xml .= '       <nrcepend>'.$nrcepend.'</nrcepend>';
	$xml .= '       <nrcxapst></nrcxapst>';
	$xml .= '       <dtiniatv>'.$dtiniatv.'</dtiniatv>';
	$xml .= '       <natjurid>'.$natjurid.'</natjurid>';
	$xml .= '       <nmfansia>'.$nmfansia.'</nmfansia>';
	$xml .= '       <nrinsest>'.$nrinsest.'</nrinsest>';
	$xml .= '       <cdseteco>'.$cdseteco.'</cdseteco>';
	$xml .= '       <cdrmativ>'.$cdrmativ.'</cdrmativ>';
	$xml .= '       <nrdddtfc>'.$nrdddtfc.'</nrdddtfc>';
	$xml .= '       <nrtelefo>'.$nrtelefo.'</nrtelefo>';
	$xml .= '       <dtdebito>'.$dtdebito.'</dtdebito>';
	$xml .= '       <qtparcel>'.$qtparcel.'</qtparcel>';
	$xml .= '       <vlparcel>'.$vlparcel.'</vlparcel>';
	$xml .= '       <inhabmen>'.$inhabmen.'</inhabmen>';
	$xml .= '       <dthabmen>'.$dthabmen.'</dthabmen>';
	$xml .= '       <nmttlrfb>'.$nmttlrfb.'</nmttlrfb>';
	$xml .= '       <inconfrb></inconfrb>';
	$xml .= '       <hrinicad>'.$hrinicad.'</hrinicad>';
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';          
	
	$xmlResult = getDataXML($xml);	
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra mensagem
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Cadmat','',false);
	} 
		
	//----------------------------------------------------------------------------------------------------------------------------------
	// Controle de alertas e retornos
	//----------------------------------------------------------------------------------------------------------------------------------
	$msg 		= Array();
	$msgRetorno = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRETOR']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'] : '';	
	$msgAlertas = ( isset($xmlObjeto->roottag->tags[1]->tags) ) ? $xmlObjeto->roottag->tags[1]->tags : array();	
	
	$msgAlertArray = Array();
	foreach( $msgAlertas as $alerta){
		$msgAlertArray[getByTagName($alerta->tags,'cdalerta')] = getByTagName($alerta->tags,'dsalerta');
	}
	
	$msgAlerta = implode( "|", $msgAlertArray);	
		
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	
	$stringArrayMsg = implode( "|", $msg);
	
	setVarSession("CRM_NRDCONTA",$nrdconta);
	$metodo = ($inpessoa == 1) ? "verificaRelatorio();" : "abrirProcuradores();";
	echo "exibirMensagens('" . $stringArrayMsg . "','" . $metodo . "')";
	
	// Verificar se nao é um CPF ou CNPJ bloqueado por responsabilidade social
	function verificaCpfCnpjBloqueado($cdcooper, $cdagenci, $nrdcaixa, $idorigem, $cdoperad, $inpessoa, $nrcpfcgc){
		
		// Monta o xml de requisição
		
		$xml  		= "";
		$xml 	   .= "<Root>";
		$xml 	   .= " <Dados>";
		$xml       .=		"<inpessoa>".$inpessoa."</inpessoa>";
		$xml       .=		"<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
		$xml 	   .= " </Dados>";
		$xml 	   .= "</Root>";		
		
		$xmlResult = mensageria($xml, "COCNPJ", "VERIFICA_CNPJ", $cdcooper, $cdagenci, $nrdcaixa, $idorigem, $cdoperad, "</Root>");		
		$xmlObjeto = getObjectXML($xmlResult);

		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes["NMDCAMPO"];

			if(empty ($nmdcampo)){ 
				$nmdcampo = "nrcpfcgc";
			}
			
			exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','focaCampoErro(\''.$nmdcampo.'\',\'frmFisico\');',false);		
						
		} else {
			
			/*aqui manda msg pra tela*/
			$bloqueado = $xmlObjeto->roottag->tags[0]->cdata;
			
			if($bloqueado == 'SIM'){
				return true;
			}else{
				return false;
			}
			

		}
		
		return false;
	}
?>