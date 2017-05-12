<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rodolpho Telmo - DB1 Informatica
 * DATA CRIAÇÃO : 09/03/2010 
 * OBJETIVO     : Rotina para validar/incluir/alterar/excluir os dados dos bens da tela de CONTAS
 * ALTERACOES   : 22/08/2011 - Alterações projeto Grupo Econômico (Guilherme).
 *                24/11/2011 - Removido campos de tipo de rendimento e valor de outros rendimentos. (Fabricio)
 *				  04/06/2012 - Ajustes referente ao projeto GP - Sócios Menores (Adriano).
 *                19/02/2015 - Incluir tratamento para representante com cartão, conforme SD 251759 ( Renato - Supero )
 *                28/09/2015 - Chamado 337371 - Correcao na opcao de operadores. (Gabriel-RKAM)
 *                11/01/2016 - Validar exclusão de representante (David)
 *                25/04/2017 - Alterado campo dsnacion para cdnacion. (Projeto 339 - Odirlei-AMcom)
 */
?>
 
<?	
    session_start();
	require_once("../config.php");
	require_once("../funcoes.php");
	require_once("../controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();	
	
	// Recebe a operação que está sendo realizada
	$operacao_proc = (isset($_POST["operacao_proc"])) ? $_POST["operacao_proc"] : "";		
	
	// Guardo os parâmetos do POST em variáveis
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : "";
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrcpfcgc_proc = (isset($_POST["nrcpfcgc_proc"])) ? $_POST["nrcpfcgc_proc"] : "";
	$nrdrowid = (isset($_POST["nrdrowid"])) ? $_POST["nrdrowid"] : "";
	$cdoeddoc = (isset($_POST["cdoeddoc"])) ? $_POST["cdoeddoc"] : "";
	$dtnascto = (isset($_POST["dtnascto"])) ? $_POST["dtnascto"] : "";
	$dtemddoc = (isset($_POST["dtemddoc"])) ? $_POST["dtemddoc"] : "";
	$dtadmsoc = (isset($_POST["dtadmsoc"])) ? $_POST["dtadmsoc"] : "";
	$nrdctato = (isset($_POST["nrdctato"])) ? $_POST["nrdctato"] : "";
	$nmdavali = (isset($_POST["nmdavali"])) ? $_POST["nmdavali"] : "";
	$cdufddoc = (isset($_POST["cdufddoc"])) ? $_POST["cdufddoc"] : "";
	$tpdocava = (isset($_POST["tpdocava"])) ? $_POST["tpdocava"] : "";
	$nrdocava = (isset($_POST["nrdocava"])) ? $_POST["nrdocava"] : "";
	$cdestcvl = (isset($_POST["cdestcvl"])) ? $_POST["cdestcvl"] : "";
	$cdnacion = (isset($_POST["cdnacion"])) ? $_POST["cdnacion"] : "";
	$dsnatura = (isset($_POST["dsnatura"])) ? $_POST["dsnatura"] : "";
	$complend = (isset($_POST["complend"])) ? $_POST["complend"] : "";
	$nmcidade = (isset($_POST["nmcidade"])) ? $_POST["nmcidade"] : "";
	$nmbairro = (isset($_POST["nmbairro"])) ? $_POST["nmbairro"] : "";
	$dsendres = (isset($_POST["dsendres"])) ? $_POST["dsendres"] : "";
	$nmpaicto = (isset($_POST["nmpaicto"])) ? $_POST["nmpaicto"] : "";
	$nmmaecto = (isset($_POST["nmmaecto"])) ? $_POST["nmmaecto"] : "";
	$nrendere = (isset($_POST["nrendere"])) ? $_POST["nrendere"] : "";
	$nrcepend = (isset($_POST["nrcepend"])) ? $_POST["nrcepend"] : "";
	$dsrelbem = (isset($_POST["dsrelbem"])) ? $_POST["dsrelbem"] : "";
	$dsproftl = (isset($_POST["dsproftl"])) ? $_POST["dsproftl"] : "";
	$dtvalida = (isset($_POST["dtvalida"])) ? $_POST["dtvalida"] : "";
	$vledvmto = (isset($_POST["vledvmto"])) ? $_POST["vledvmto"] : "";
	$cdsexcto = (isset($_POST["cdsexcto"])) ? $_POST["cdsexcto"] : "";
	$cdufresd = (isset($_POST["cdufresd"])) ? $_POST["cdufresd"] : "";
	$nrcxapst = (isset($_POST["nrcxapst"])) ? $_POST["nrcxapst"] : "";	
	$dadosXML = (isset($_POST['dadosXML'])) ? $_POST['dadosXML'] : '';
	$camposXML = (isset($_POST['camposXML'])) ? $_POST['camposXML'] : '';
	
	$persocio = (isset($_POST["persocio"])) ? $_POST["persocio"] : "";
	$flgdepec = (isset($_POST["flgdepec"])) ? $_POST["flgdepec"] : "";
	$vloutren = (isset($_POST["vloutren"])) ? $_POST["vloutren"] : "";
	$dsoutren = (isset($_POST["dsoutren"])) ? $_POST["dsoutren"] : "";
	$dthabmen = (isset($_POST["dthabmen"])) ? $_POST["dthabmen"] : "";
	$inhabmen = (isset($_POST["inhabmen"])) ? $_POST["inhabmen"] : "";
	$verrespo = (isset($_POST["verrespo"])) ? $_POST['verrespo'] : "";
	$fltemcrd = (isset($_POST["fltemcrd"])) ? $_POST['fltemcrd'] : "";  // Renato Darosci - 10/02/2015
	$permalte = (isset($_POST["permalte"])) ? $_POST['permalte'] : "";
	$arrayFilhos = (isset($_POST["arrayFilhos"])) 					? $_POST['arrayFilhos'] : "";
	$arrayFilhosAvtMatric = (isset($_POST["arrayFilhosAvtMatric"])) ? $_POST['arrayFilhosAvtMatric'] : "";
	$arrayBensMatric = (isset($_POST["arrayBensMatric"])) 		    ? $_POST['arrayBensMatric'] : "";
	$nmrotina = (isset($_POST["nmrotina"])) 						? $_POST['nmrotina'] : "";
	
	if(in_array($operacao_proc,array('VA','VI'))) validaDados();
		
		
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = "";
	switch($operacao_proc) {
	
		case 'VI': $procedure = 'valida_dados'; $cddopcao = "I";  break;
		case 'VA': $procedure = 'valida_dados'; $cddopcao = "A";  break;
		case 'EV': $procedure = 'valida_dados'; $cddopcao = "E";  break;
		case 'I' : $procedure = 'grava_dados' ; $cddopcao = "I";  break;
		case 'A' : $procedure = 'grava_dados' ; $cddopcao = "A";  break;
		case 'E' : $procedure = 'exclui_dados'; $cddopcao = "E" ; break;
		case 'PI': $procedure = 'valida_dados' ; $cddopcao = "P"; break;
		default: return false;
		
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
		
	if ($nmrotina != "MATRIC" || ($nmrotina == "MATRIC" && $idseqttl != 2)){
				
		// Monta o xml dinâmico de acordo com a operação
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0058.p</Bo>";
		$xml .= "		<Proc>".$procedure."</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xml .= "       <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= '		<idseqttl>0</idseqttl>';
		$xml .= "       <nrcpfcgc>".$nrcpfcgc_proc."</nrcpfcgc>";
		$xml .= "       <cdoeddoc>".$cdoeddoc."</cdoeddoc>";
		$xml .= "       <dtnascto>".$dtnascto."</dtnascto>";
		$xml .= "       <dtemddoc>".$dtemddoc."</dtemddoc>";
		$xml .= "       <dtadmsoc>".$dtadmsoc."</dtadmsoc>";
		$xml .= "       <nrdctato>".$nrdctato."</nrdctato>";
		$xml .= "       <nmdavali>".$nmdavali."</nmdavali>";
		$xml .= "       <cdufddoc>".$cdufddoc."</cdufddoc>";
		$xml .= "       <tpdocava>".$tpdocava."</tpdocava>";
		$xml .= "       <nrdocava>".$nrdocava."</nrdocava>";
		$xml .= "       <cdestcvl>".$cdestcvl."</cdestcvl>";
		$xml .= "       <cdnacion>".$cdnacion."</cdnacion>";
		$xml .= "       <dsnatura>".$dsnatura."</dsnatura>";
		$xml .= "       <complend>".$complend."</complend>";
		$xml .= "       <nmcidade>".$nmcidade."</nmcidade>";
		$xml .= "       <nmbairro>".$nmbairro."</nmbairro>";
		$xml .= "       <dsendres>".$dsendres."</dsendres>";
		$xml .= "       <nmpaicto>".$nmpaicto."</nmpaicto>";
		$xml .= "       <nmmaecto>".$nmmaecto."</nmmaecto>";
		$xml .= "       <nrendere>".$nrendere."</nrendere>";
		$xml .= "       <nrcepend>".$nrcepend."</nrcepend>";
		$xml .= "       <dsrelbem>".$dsrelbem."</dsrelbem>";
		$xml .= "       <dsproftl>".$dsproftl."</dsproftl>";
		$xml .= "       <dtvalida>".$dtvalida."</dtvalida>";
		$xml .= "       <vledvmto>".$vledvmto."</vledvmto>";
		$xml .= "       <cdsexcto>".$cdsexcto."</cdsexcto>";
		$xml .= "       <cdufresd>".$cdufresd."</cdufresd>";
		$xml .= "       <nrcxapst>".$nrcxapst."</nrcxapst>";
		$xml .= "       <cddopcao>".$cddopcao."</cddopcao>";
		$xml .= "       <nrdrowid>".$nrdrowid."</nrdrowid>";
		$xml .= "		<persocio>".$persocio."</persocio>";
		$xml .= "		<flgdepec>".$flgdepec."</flgdepec>";
		$xml .= "		<vloutren>".$vloutren."</vloutren>";
		$xml .= "		<dsoutren>".$dsoutren."</dsoutren>";
		$xml .= retornaXmlFilhos( $camposXML, $dadosXML, 'Bens', 'Itens');
		
		if($procedure == "valida_dados"){ 
		
			$xml .= '		<verrespo>'.$verrespo.'</verrespo>'; 	
			$xml .= '		<permalte>'.$permalte.'</permalte>'; 
			
			/*Procuradores*/		
			foreach ($arrayFilhosAvtMatric as $key => $value) {
		
				$campospc = "";
				$dadosprc = "";
				$contador = 0;
				
				foreach( $value as $chave => $valor ){
					
					$contador++;
					
					if($contador == 1){
						$campospc .= $chave;
						
					}else{
						$campospc .= "|".$chave;
					}
					
					if($contador == 1){
						$dadosprc .= $valor;
						
					}else{
						$dadosprc .= ";".$valor;
					}
					
				}
				
				$xml .= retornaXmlFilhos( $campospc, $dadosprc, 'Procurador', 'Procuradores');
				
			}
			
		}
		
		if($procedure == 'valida_dados' ||
		   $procedure == 'grava_dados'){
		   
			$xml .= '       <dthabmen>'.$dthabmen.'</dthabmen>';
			$xml .= '       <inhabmen>'.$inhabmen.'</inhabmen>';
			$xml .= '       <nmrotina>'.$nmrotina.'</nmrotina>'; /*PROCURADORES*/
			
			/*Resp. Legal*/			
			foreach ($arrayFilhos as $key => $value) {
		
				$campospc = "";
				$dadosprc = "";
				$contador = 0;
				
				foreach( $value as $chave => $valor ){
					
					$contador++;
					
					if($contador == 1){
						$campospc .= $chave;
						
					}else{
						$campospc .= "|".$chave;
					}
					
					if($contador == 1){
						$dadosprc .= $valor;
						
					}else{
						$dadosprc .= ";".$valor;
					}
					
				}
				
				$xml .= retornaXmlFilhos( $campospc, $dadosprc, 'RespLegal', 'Responsavel');
				
			}
			
			/*Bens dos procuradores*/			
			foreach ($arrayBensMatric as $key => $value) {
		
				$campospc = "";
				$dadosprc = "";
				$contador = 0;
				
				foreach( $value as $chave => $valor ){
					
					$contador++;
					
					if($contador == 1){
						$campospc .= $chave;
						
					}else{
						$campospc .= "|".$chave;
					}
					
					if($contador == 1){
						$dadosprc .= $valor;
						
					}else{
						$dadosprc .= ";".$valor;
					}
					
				}
				
				$xml .= retornaXmlFilhos( $campospc, $dadosprc, 'Bens', 'Itens');
				
			}
			
		}
		
		$xml .= "	</Dados>";
		$xml .= "</Root>";
			
		// Executa script para envio do XML e cria objeto para classe de tratamento de XML
		$xmlResult = getDataXML($xml);	
		$xmlObjeto = getObjectXML($xmlResult);
		
		$saida =  ( $operacao_proc == 'EV' || $operacao_proc == 'E' ) ? 'controlaOperacaoProc();' : 'bloqueiaFundo(divRotina);' ;
		
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
			
	}	
		
	if($operacao_proc == "PI"){	
		
		// Data Nascimento
		if (!validaData($GLOBALS['dtnascto'])) exibirErro('error','Data de Nascimento inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtnascto\',\'frmDadosProcuradores\')',false);
		
		// Responsabilidade Legal
		if (($inhabmen != 0)&&($inhabmen != 1)&&($inhabmen != 2)) exibirErro('error','Responsabilidade Legal inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'inhabmen\',\'frmDadosIdentFisica\')',false);
		
		// Somente valida a Data de Emancipação quando a Responsabilidade Legal for 1 (Habilitado)
		if (!validaData($dthabmen) && ($inhabmen == 1)) exibirErro('error','Data de Emancipa&ccedil;&atilde;o inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dthabmen\',\'frmDadosIdentFisica\')',false);

		// Data de emancipação não pode ser preenchida para quando a Responsabilidade legal for 0,2.
		if ($dthabmen != '' && ($inhabmen == 0 || $inhabmen == 2)) exibirErro('error','Data de Emancipa&ccedil;&atilde;o n&atilde;o pode ser preenchida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dthabmen\',\'frmDadosIdentFisica\')',false);
			
		?>  
			nrdeanos_proc = <? echo $xmlObjeto->roottag->tags[0]->attributes["NRDEANOS"]; ?>;
			controlaBotoesProc(aux_dscdaope);
			hideMsgAguardo(); 
			bloqueiaFundo(divRotina);
									
		<?
		
	}else{ 
			
		// Se é Validação
		if(in_array($operacao_proc,array('VI','VA','EV'))) {		
				
			if($nmrotina == "MATRIC" && $idseqttl == 2){
							
				if($operacao_proc == 'VA'){
				
					if ( $msgAlerta != '' ){
					
						exibirErro('inform',$msgAlerta,'Alerta - Ayllos','controlaArrayProc(\'VA\'); bloqueiaFundo(divConfirm);',false);
					
					}else{?>
					
						if(aux_sovalida == true){
						
							aux_sovalida = false;
							abrirRotinaProc('RESPONSAVEL LEGAL','Responsavel Legal','responsavel_legal','responsavel_legal2','AV');
							
						}else{
							
							controlaArrayProc('VA');
							
						}<?						
					}
					
				}else if($operacao_proc == 'VI'){
				
					if ( $msgAlerta != '' ){
					
						exibirErro('inform',$msgAlerta,'Alerta - Ayllos','controlaArrayProc(\'VI\'); bloqueiaFundo(divConfirm);',false);
					
					}else{?>
					
						if(aux_sovalida == true){
						
						   aux_sovalida = false;
						   abrirRotinaProc('RESPONSAVEL LEGAL','Responsavel Legal','responsavel_legal','responsavel_legal2','IV');
						   
						}else{
						
							controlaArrayProc('VI');
						   
						}<?
					}
				}
								
			}else{?>
			
				if(aux_sovalida == true){
				   
				   aux_sovalida = false;
					
				   if('<?echo $operacao_proc;?>' == "VI"){
					
					  abrirRotinaProc('RESPONSAVEL LEGAL','Responsavel Legal','responsavel_legal','responsavel_legal2','IV');
					
			       }else if('<?echo $operacao_proc;?>' == "VA"){
					
					        abrirRotinaProc('RESPONSAVEL LEGAL','Responsavel Legal','responsavel_legal','responsavel_legal2','AV');
					
				   }
					
				}else{
				<?
					
					// Se for exclusão e representante possui cartão - Renato Darosci - 11/02/2015
					if ($operacao_proc == 'EV' && $fltemcrd == 2) {
					  exibirErro('inform','Exclusao nao permitida, pois responsavel possui cartao aprovado/solicitado.','Alerta - Ayllos','controlaOperacaoProc(\'EC\')',false);
					  ?>}<?
					  exit();
					} else {
					  if ( $msgAlerta != '' ) exibirErro('inform',$msgAlerta,'Alerta - Ayllos','bloqueiaFundo(divConfirm)',false);		
					  if($operacao_proc=='VI') exibirConfirmacao('Deseja confirmar inclusão?','Confirmação - Ayllos','controlaOperacaoProc(\'VI\')','bloqueiaFundo(divRotina)',false);	
					  if($operacao_proc=='VA') exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Ayllos','controlaOperacaoProc(\'VA\')','bloqueiaFundo(divRotina)',false);
					  if($operacao_proc=='EV') exibirConfirmacao('Deseja confirmar exclusão?','Confirmação - Ayllos','controlaOperacaoProc(\'E\')','controlaOperacaoProc(\'EC\')',false);
					}
					
					// Se for exclusão e representante possui cartão - Renato Darosci - 11/02/2015
					if ($operacao_proc == 'EV' && $fltemcrd == 1) {
					  exibirErro('inform','ATENCAO: Responsavel possui cartoes ativos.','Alerta - Ayllos','bloqueiaFundo(divConfirm);\$(\"#btnYesConfirm\").focus();',false);
					}
				?>}<?
				
			}
		// Se é Inclusão ou Alteração
		} else {
			
			// Chamar rotina de PODERES na inclusao
			$metodo = ($operacao_proc == 'I') ? "cpfPoderes = '$nrcpfcgc_proc'; controlaOperacaoProc(\"CTP\");" : "controlaOperacaoProc(\"CT\");";
		
			// Verificar se existe "Verificação de Revisão Cadastral"
			if($msgAtCad!='') {
			
				if($operacao_proc=='I') exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0058.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoProc(\"CT\")\')',false);
				if($operacao_proc=='A') exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0058.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoProc(\"CT\")\')',false);
				
			// Se não existe necessidade de Revisão Cadastral
			} else {	
			
				// Chama o controla Operação Finalizando a Inclusão ou Alteração			
			   echo 'exibirMensagens("' . $stringArrayMsg . '");';
			   echo $metodo;
			}
			
			
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
		if (!validaData($GLOBALS['dtemddoc'])) exibirErro('error','Data de Emiss&atilde;o inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtemddoc\',\'frmDadosProcuradores\')',false);
		
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
		
		// Cargo
		if ($GLOBALS['dsproftl']=='') exibirErro('error','Cargo inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dsproftl\',\'frmDadosProcuradores\')',false);		
		
		// Data Admissao somente é obrigatória para SÓCIOS/PROPRIETÁRIOS
		if ( ($GLOBALS['dsproftl'] == 'SOCIO/PROPRIETARIO') ) {
			if (!validaData($GLOBALS['dtadmsoc'])) exibirErro('error','Data de Admiss&atilde;o inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtadmsoc\',\'frmDadosProcuradores\')',false);
			//if (!validaDecimal($GLOBALS['tpdrendi'])) exibirErro('error','Data de Admiss&atilde;o inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtadmsoc\',\'frmDadosProcuradores\')',false);
		}
	}
?>