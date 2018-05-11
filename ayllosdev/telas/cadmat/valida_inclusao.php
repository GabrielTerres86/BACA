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
	$tpdocptl = isset($_POST['tpdocptl']) ? $_POST['tpdocptl'] : '';
	$nrdocptl = isset($_POST['nrdocptl']) ? $_POST['nrdocptl'] : '';
	$cdsitcpf = isset($_POST['cdsitcpf']) ? $_POST['cdsitcpf'] : '';
	$dtcnscpf = isset($_POST['dtcnscpf']) ? $_POST['dtcnscpf'] : '';
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
	$nrcepend = isset($_POST['nrcepend']) ? $_POST['nrcepend'] : '';
	$dsendere = isset($_POST['dsendere']) ? $_POST['dsendere'] : '';
	$nrendere = isset($_POST['nrendere']) ? $_POST['nrendere'] : '';
	$complend = isset($_POST['complend']) ? $_POST['complend'] : '';
	$nmbairro = isset($_POST['nmbairro']) ? $_POST['nmbairro'] : '';
	$cdufende = isset($_POST['cdufende']) ? $_POST['cdufende'] : '';
	$nmcidade = isset($_POST['nmcidade']) ? $_POST['nmcidade'] : '';
	$cdocpttl = isset($_POST['cdocpttl']) ? $_POST['cdocpttl'] : '';
	$nrcadast = isset($_POST['nrcadast']) ? $_POST['nrcadast'] : '';
	$cdsexotl = isset($_POST['cdsexotl']) ? $_POST['cdsexotl'] : '';
	$nmfansia = isset($_POST['nmfansia']) ? $_POST['nmfansia'] : '';
	$nrdddtfc = isset($_POST['nrdddtfc']) ? $_POST['nrdddtfc'] : '';
	$nrtelefo = isset($_POST['nrtelefo']) ? $_POST['nrtelefo'] : '';
	$nrinsest = isset($_POST['nrinsest']) ? $_POST['nrinsest'] : '';
	$natjurid = isset($_POST['natjurid']) ? $_POST['natjurid'] : '';
	$cdseteco = isset($_POST['cdseteco']) ? $_POST['cdseteco'] : '';
	$cdrmativ = isset($_POST['cdrmativ']) ? $_POST['cdrmativ'] : '';
	$dtiniatv = isset($_POST['dtiniatv']) ? $_POST['dtiniatv'] : '';
	$verrespo = isset($_POST['verrespo']) ? $_POST['verrespo'] : '';
	$permalte = isset($_POST['permalte']) ? $_POST['permalte'] : '';
	
	//CPF Responsabilidade social		
	// if( verificaCpfCnpjBloqueado($glbvars['cdcooper'], $glbvars['cdpactra'], $glbvars['nrdcaixa'], $glbvars['idorigem'], $glbvars['cdoperad'], $inpessoa, $nrcpfcgc )){			
		// exibirErro('error','CPF n&atilde;o autorizado, conforme previsto na Pol&iacute;tica de Responsabilidade Socioambiental do Sistema CECRED.','Alerta - Ayllos','',false);
	// }
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0052.p</Bo>';
	$xml .= '		<Proc>valida_dados</Proc>';
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
	$xml .= '       <inpessoa>'.$inpessoa.'</inpessoa>';
	$xml .= '       <cdagepac>'.$cdagepac.'</cdagepac>';
	$xml .= '       <nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '       <nmprimtl>'.$nmprimtl.'</nmprimtl>';
	$xml .= '       <dtcadass></dtcadass>';
	$xml .= '       <nmsegntl></nmsegntl>';
	$xml .= '       <nmpaittl>'.$nmpaittl.'</nmpaittl>';
	$xml .= '       <nmmaettl>'.$nmmaettl.'</nmmaettl>';
	$xml .= '       <nmconjug>'.$nmconjug.'</nmconjug>';
	$xml .= '       <cdempres>'.$cdempres.'</cdempres>';
	$xml .= '       <cdsexotl>'.$cdsexotl.'</cdsexotl>';
	$xml .= '       <cdsitcpf>'.$cdsitcpf.'</cdsitcpf>';
	$xml .= '       <cdtipcta></cdtipcta>';
	//$xml .= '       <dtcnscpf>'.$dtcnscpf.'</dtcnscpf>';
	$xml .= '       <dtcnscpf>'.$glbvars["dtmvtolt"].'</dtcnscpf>';
	$xml .= '       <dtnasctl>'.$dtnasctl.'</dtnasctl>';
	$xml .= '       <tpnacion>'.$tpnacion.'</tpnacion>';
	$xml .= '       <cdnacion>'.$cdnacion.'</cdnacion>';
	$xml .= '       <dsnatura>'.$dsnatura.'</dsnatura>';
	$xml .= '       <cdufnatu>'.$cdufnatu.'</cdufnatu>';
	$xml .= '       <cdocpttl>'.$cdocpttl.'</cdocpttl>';
	$xml .= '       <cdestcvl>'.$cdestcvl.'</cdestcvl>';
	$xml .= '       <dsproftl></dsproftl>';
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
	$xml .= '       <inmatric></inmatric>';
	$xml .= '       <verrespo>'.$verrespo.'</verrespo>';
	$xml .= '       <permalte>'.$permalte.'</permalte>';
	$xml .= '       <inhabmen>'.$inhabmen.'</inhabmen>';
	$xml .= '       <dthabmen>'.$dthabmen.'</dthabmen>';
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';          
	
	$xmlResult = getDataXML($xml);	
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra mensagem
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		if (trim($xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata) == '375'){ 
			if ($inpessoa == 1){
				if ($cdagepac > 0 && $cdempres > 0){
					$msgErro = "Cadastro incompleto. Favor revisar cadastro no CRM.";
				}else{
					$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
				}
			}else{
				if ($cdagepac > 0){
					$msgErro = "Cadastro incompleto. Favor revisar cadastro no CRM.";
				}else{
					$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
				}				
			}
		}else{
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Cadmat','',false);
	} 
	
	//----------------------------------------------------------------------------------------------------------------------------------
	// Controle de parcelamento	
	//----------------------------------------------------------------------------------------------------------------------------------
	
	$qtparcel = ( isset($xmlObjeto->roottag->tags[0]->attributes['QTPARCEL']) ) ? $xmlObjeto->roottag->tags[0]->attributes['QTPARCEL'] : '';	
	$vlparcel = ( isset($xmlObjeto->roottag->tags[0]->attributes['VLPARCEL']) ) ? $xmlObjeto->roottag->tags[0]->attributes['VLPARCEL'] : '';
	
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
	
	//----------------------------------------------------------------------------------------------------------------------------------
	// Controle das mensagens de confirmações
	//----------------------------------------------------------------------------------------------------------------------------------			
	if ( $qtparcel > 0 ) { 
		echo 'exibirMsgInclusao(\''.$msgAlerta.'\',\''.$msgRetorno.'\',\''.$qtparcel.'\',\''.$vlparcel.'\');';
		return false;	
	}
	
	$nrctanov = ( isset($xmlObjeto->roottag->tags[0]->attributes['NRCTANOV']) ) ? formataContaDVsimples($xmlObjeto->roottag->tags[0]->attributes['NRCTANOV']) : '';
	echo '$("#nrdconta","#frmCab").val("' . $nrctanov . '");';
	echo '$("#nrdconta","#frmCadmat").val("' . $nrctanov . '");';
	echo 'incluirConta()';
	
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