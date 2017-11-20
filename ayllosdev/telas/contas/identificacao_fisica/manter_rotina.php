<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 24/03/2010 
 * OBJETIVO     : Rotina para validar/alterar os dados da IDENTIFICAÇÃO FÍSICA da tela de CONTAS
  * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [29/03/2010] Rodolpho Telmo (DB1): Criado novo parâmetro "nrctattl" para controle de validação
 * 002:	[21/03/2011] Henrique			 : Incluido campo inpessoa na XML.	
 * 003: [25/04/2012] Adriano			 : Ajsutes referente ao Projeto GP - Sócios Menores (Adriano).
 * 004: [23/08/2013] David               : Incluir campo UF Naturalidade - cdufnatu
 * 005: [27/02/2015] Jaison/Gielow       : Substituicao de caracteres especiais. (SD: 257871)
 * 006: [17/09/2015] Gabriel (RKAM)      : Reformulacao cadastral.
 * 007: [20/04/2017] Adriano             : Ajuste para retirar o uso de campos removidos da tabela crapass, crapttl, crapjur 							
 * 008: [25/04/2017] Odirlei(AMcom)	      : Alterado campo dsnacion para cdnacion. (Projeto 339)
 * 009: [28/08/2017] Lucas Reinert		 : Alterado tipos de documento para utilizarem CI, CN, 
 *										   CH, RE, PP E CT. (PRJ339 - Reinert)
 */
?>
 
<?	
    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	// Recebendo as variáveis
	$inpessoa = 1;
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';     
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';     
	$cdgraupr = (isset($_POST['cdgraupr'])) ? $_POST['cdgraupr'] : '';     
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '';     
	$nmextttl = (isset($_POST['nmextttl'])) ? $_POST['nmextttl'] : '';     
	$cdsitcpf = (isset($_POST['cdsitcpf'])) ? $_POST['cdsitcpf'] : '';     
	$dtcnscpf = (isset($_POST['dtcnscpf'])) ? $_POST['dtcnscpf'] : '';     
	$tpdocttl = (isset($_POST['tpdocttl'])) ? $_POST['tpdocttl'] : '';     
	$nrdocttl = (isset($_POST['nrdocttl'])) ? $_POST['nrdocttl'] : '';     
	$cdoedttl = (isset($_POST['cdoedttl'])) ? $_POST['cdoedttl'] : '';     
	$cdufdttl = (isset($_POST['cdufdttl'])) ? $_POST['cdufdttl'] : '';     
	$dtemdttl = (isset($_POST['dtemdttl'])) ? $_POST['dtemdttl'] : '';     
	$cdnacion = (isset($_POST['cdnacion'])) ? $_POST['cdnacion'] : '';     
	$tpnacion = (isset($_POST['tpnacion'])) ? $_POST['tpnacion'] : '';     
	$dtnasttl = (isset($_POST['dtnasttl'])) ? $_POST['dtnasttl'] : '';     
	$dsnatura = (isset($_POST['dsnatura'])) ? $_POST['dsnatura'] : '';     
	$cdufnatu = (isset($_POST['cdufnatu'])) ? $_POST['cdufnatu'] : '';     
	$cdsexotl = (isset($_POST['cdsexotl'])) ? $_POST['cdsexotl'] : '';     
	$inhabmen = (isset($_POST['inhabmen'])) ? $_POST['inhabmen'] : '';     
	$dthabmen = (isset($_POST['dthabmen'])) ? $_POST['dthabmen'] : '';     
	$cdestcvl = (isset($_POST['cdestcvl'])) ? $_POST['cdestcvl'] : '';     
	$grescola = (isset($_POST['grescola'])) ? $_POST['grescola'] : '';     
	$cdfrmttl = (isset($_POST['cdfrmttl'])) ? $_POST['cdfrmttl'] : '';     
	$nmcertif = (isset($_POST['nmcertif'])) ? $_POST['nmcertif'] : '';     
	$nmtalttl = (isset($_POST['nmtalttl'])) ? $_POST['nmtalttl'] : '';     
	$qtfoltal = (isset($_POST['qtfoltal'])) ? $_POST['qtfoltal'] : '';     
	$nrctattl = (isset($_POST['nrctattl'])) ? $_POST['nrctattl'] : '';
	$cdnatopc = (isset($_POST['cdnatopc'])) ? $_POST['cdnatopc'] : '';
	$cdocpttl = (isset($_POST['cdocpttl'])) ? $_POST['cdocpttl'] : '';
	$tpcttrab = (isset($_POST['tpcttrab'])) ? $_POST['tpcttrab'] : '';	
	$nmextemp = (isset($_POST['nmextemp'])) ? $_POST['nmextemp'] : '';	
	$nrcpfemp = (isset($_POST['nrcpfemp'])) ? $_POST['nrcpfemp'] : '';	
	$dsproftl = (isset($_POST['dsproftl'])) ? $_POST['dsproftl'] : '';	
	$cdnvlcgo = (isset($_POST['cdnvlcgo'])) ? $_POST['cdnvlcgo'] : '';	
	$cdturnos = (isset($_POST['cdturnos'])) ? $_POST['cdturnos'] : '';	
	$dtadmemp = (isset($_POST['dtadmemp'])) ? $_POST['dtadmemp'] : '';	
	$vlsalari = (isset($_POST['vlsalari'])) ? $_POST['vlsalari'] : '';
	$verrespo = (isset($_POST['verrespo'])) ? $_POST['verrespo'] : '';
	$permalte = (isset($_POST['permalte'])) ? $_POST['permalte'] : '';
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';
	$flgContinuar = (isset($_POST['flgContinuar'])) ? $_POST['flgContinuar'] : '';
	$arrayFilhos  = (isset($_POST['arrayFilhos'])) ? $_POST['arrayFilhos'] : '';


    $array1 = array("á","à","â","ã","ä","é","è","ê","ë","í","ì","î","ï","ó","ò","ô","õ","ö","ú","ù","û","ü","ç","ñ"
	               ,"Á","À","Â","Ã","Ä","É","È","Ê","Ë","Í","Ì","Î","Ï","Ó","Ò","Ô","Õ","Ö","Ú","Ù","Û","Ü","Ç","Ñ"
				   ,"&","¨","~","^","*","#","%","$","!","?",";",">","<","|","+","=","£","¢","¬","§","`","´","¹","²"
				   ,"³","ª","º","°","\"","'","\\","","→");
	$array2 = array("a","a","a","a","a","e","e","e","e","i","i","i","i","o","o","o","o","o","u","u","u","u","c","n"
                   ,"A","A","A","A","A","E","E","E","E","I","I","I","I","O","O","O","O","O","U","U","U","U","C","N"
				   ,"e"," "," "," "," "," "," "," "," "," ",";"," "," ","|"," "," "," "," "," "," "," "," "," "," "
				   ," "," "," "," "," "," "," ","-","-");

	// limpeza dos caracteres nos campos 
	$nmtalttl = trim(str_replace( $array1, $array2, $nmtalttl));
	
	if(in_array($operacao,array('AV','IV','VI','VA'))) validaDados();      
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';	
	switch($operacao) {
		case 'IV': $procedure = 'valida_dados'; $cddopcao = 'I'; break;
		case 'AV': $procedure = 'valida_dados'; $cddopcao = 'A'; break;
		case 'VI': $procedure = 'grava_dados' ; $cddopcao = 'I'; break;
		case 'VA': $procedure = 'grava_dados' ; $cddopcao = 'A'; break;
		case 'PI': $procedure = 'valida_dados' ; $cddopcao = 'PI'; break;
		default: return false;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0055.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
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
	$xml .= '       <cdgraupr>'.$cdgraupr.'</cdgraupr>';
	$xml .= '       <nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '       <nmextttl>'.$nmextttl.'</nmextttl>';
	$xml .= '       <cdsitcpf>'.$cdsitcpf.'</cdsitcpf>';
	$xml .= '       <dtcnscpf>'.$dtcnscpf.'</dtcnscpf>';
	$xml .= '       <tpdocttl>'.$tpdocttl.'</tpdocttl>';
	$xml .= '       <nrdocttl>'.$nrdocttl.'</nrdocttl>';
	$xml .= '       <cdoedttl>'.$cdoedttl.'</cdoedttl>';
	$xml .= '       <cdufdttl>'.$cdufdttl.'</cdufdttl>';
	$xml .= '       <dtemdttl>'.$dtemdttl.'</dtemdttl>';
	$xml .= '       <tpnacion>'.$tpnacion.'</tpnacion>';
	$xml .= '       <cdnacion>'.$cdnacion.'</cdnacion>';
	$xml .= '       <dtnasttl>'.$dtnasttl.'</dtnasttl>';
	$xml .= '       <dsnatura>'.$dsnatura.'</dsnatura>';
	$xml .= '       <cdufnatu>'.$cdufnatu.'</cdufnatu>';
	$xml .= '       <cdsexotl>'.$cdsexotl.'</cdsexotl>';
	$xml .= '       <inhabmen>'.$inhabmen.'</inhabmen>';
	$xml .= '       <dthabmen>'.$dthabmen.'</dthabmen>';
	$xml .= '       <cdestcvl>'.$cdestcvl.'</cdestcvl>';
	$xml .= '       <grescola>'.$grescola.'</grescola>';
	$xml .= '       <cdfrmttl>'.$cdfrmttl.'</cdfrmttl>';
	$xml .= '       <nmcertif>'.$nmcertif.'</nmcertif>';
	$xml .= '       <nmtalttl>'.$nmtalttl.'</nmtalttl>';
	$xml .= '       <qtfoltal>'.$qtfoltal.'</qtfoltal>';
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<nrctattl>'.$nrctattl.'</nrctattl>';	
	$xml .= '		<cdnatopc>'.$cdnatopc.'</cdnatopc>';
	$xml .= '		<cdocpttl>'.$cdocpttl.'</cdocpttl>';
	$xml .= '		<tpcttrab>'.$tpcttrab.'</tpcttrab>';
	$xml .= '		<nmextemp>'.$nmextemp.'</nmextemp>';
	$xml .= '		<nrcpfemp>'.$nrcpfemp.'</nrcpfemp>';
	$xml .= '		<dsproftl>'.$dsproftl.'</dsproftl>';
	$xml .= '		<cdnvlcgo>'.$cdnvlcgo.'</cdnvlcgo>';
	$xml .= '		<cdturnos>'.$cdturnos.'</cdturnos>';
	$xml .= '		<dtadmemp>'.$dtadmemp.'</dtadmemp>';
	$xml .= '		<vlsalari>'.$vlsalari.'</vlsalari>';
    $xml .= '		<inpessoa>'.$inpessoa.'</inpessoa>'; 	
	
	if($procedure == "valida_dados"){ 
		$xml .= '		<verrespo>'.$verrespo.'</verrespo>'; 	
		$xml .= '		<permalte>'.$permalte.'</permalte>'; 
	}
	
	if($procedure == "grava_dados" || $procedure == "valida_dados"){ 

		$count = count($arrayFilhos);
		
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
		
	}
	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);	
	$xmlObjeto = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
		
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
	
		
	if($operacao == "PI"){
			
		// Data Nascimento
		if (!validaData($GLOBALS['dtnasttl'])) exibirErro('error','Data de Nascimento inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtnasttl\',\'frmDadosIdentFisica\')',false);			
		
		// Responsabilidade Legal
		if (($GLOBALS['inhabmen'] != 0)&&($GLOBALS['inhabmen'] != 1)&&($GLOBALS['inhabmen'] != 2)) exibirErro('error','Responsabilidade Legal inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'inhabmen\',\'frmDadosIdentFisica\')',false);
		
		// Somente valida a Data de Emancipação quando a Responsabilidade Legal for 1 (Habilitado)
		if (!validaData($GLOBALS['dthabmen']) && ($GLOBALS['inhabmen'] == 1)) exibirErro('error','Data de Emancipa&ccedil;&atilde;o inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dthabmen\',\'frmDadosIdentFisica\')',false);

		// Data de emancipação não pode ser preenchida para quando a Responsabilidade legal for 0,2.
		if ($GLOBALS['dthabmen'] != '' && ($GLOBALS['inhabmen'] == 0 || $GLOBALS['inhabmen'] == 2)) exibirErro('error','Data de Emancipa&ccedil;&atilde;o n&atilde;o pode ser preenchida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dthabmen\',\'frmDadosIdentFisica\')',false);
			
		
		?>
		
		nrdeanos = <? echo $xmlObjeto->roottag->tags[0]->attributes["NRDEANOS"]; ?>;
		operacao = aux_operacao;
//controlaBotoes();		
		hideMsgAguardo(); 
		bloqueiaFundo(divRotina);
		<?
					
	}else{	
	
		// Se é Validação
		if(in_array($operacao,array('IV','AV'))) {
					
					echo 'hideMsgAguardo();';
					if($operacao=='IV') exibirConfirmacao('Deseja confirmar inclusão?' ,'Confirmação - Ayllos','controlaOperacao(\'VI\');','bloqueiaFundo(divRotina)',false);		
					if($operacao=='AV') exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Ayllos','controlaOperacao(\'VA\');','bloqueiaFundo(divRotina)',false);				
				
		// Se é Inclusão ou Alteração
		} else {
		
			// Verificar se existe "Verificação de Revisão Cadastral"
			if($msgAtCad!='') {		

				if ($flgcadas == 'M') {
					echo 'revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0055.p\',\''.$stringArrayMsg.'\',\'\');';
				} else {
					
					if ($flgContinuar == 'true') {
						exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0055.p\',\''.$stringArrayMsg.'\',\'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'',false);								
					} else {
						if($operacao == 'VI') exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0055.p\',\''.$stringArrayMsg.'\',\'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FI\")\')',false);								
						if($operacao == 'VA') exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0055.p\',\''.$stringArrayMsg.'\',\'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FA\")\')',false);								
					}
				}
				
			// Se não existe necessidade de Revisão Cadastral
			} else {	
			
				if ($flgcadas != 'M') {
										
					// Chama o controla Operação Finalizando a Inclusão ou Alteração
					if ($flgContinuar == 'true') {
						echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'\');';
					} else {
						if($operacao=='VI') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FI\")\');' ;
						if($operacao=='VA') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FA\")\');';
					}
				}
				
			}
		} 

	}
	
	function validaDados() {
			
		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input,select","#frmDadosIdentFisica").removeClass("campoErro");';
		
		// Número da conta e o titular são inteiros válidos
		if (!validaInteiro($GLOBALS['nrdconta'])) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);				
		
		/*!
		 * ALTERAÇÃO : 001
		 * OBJETIVO  : Existem casos que não pode realizar validação. 
		 *             Quando o titular vem de outra conta, não validar, em caso contrário validar.
		 */
		if ( (( $GLOBALS['nrctattl'] == 0 ) || ( $GLOBALS['nrctattl'] == $GLOBALS['nrdconta'] )) && ( $GLOBALS['idseqttl'] == 1 ) ) {
									
			// Nome Titular
			if ($GLOBALS['nmextttl']=='') exibirErro('error','Nome Titular deve ser informado.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nmextttl\',\'frmDadosIdentFisica\')',false);
			
			// Situação do CPF
			// if (!validaInteiro($GLOBALS['cdsitcpf'])) exibirErro('error','Situa&ccedil;&atilde;o da Consulta do C.P.F. inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdsitcpf\',\'frmDadosIdentFisica\')',false);
			// if ($GLOBALS['cdsitcpf'] < 1 || $GLOBALS['cdsitcpf'] > 5) exibirErro('error','Situa&ccedil;&atilde;o da Consulta do C.P.F. inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdsitcpf\',\'frmDadosIdentFisica\'))',false);		
			
			// Data da Consulta do CPF
			if (!validaData($GLOBALS['dtcnscpf'])) exibirErro('error','Data da Consulta do C.P.F. inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtcnscpf\',\'frmDadosIdentFisica\')',false);
			
			// Tipo de Documento
			if (!in_array($GLOBALS['tpdocttl'],array('CI','CN','CH','RE','PP','CT'))) exibirErro('error','Tipo de Documento inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'tpdocttl\',\'frmDadosIdentFisica\')',false);
			
			// Numero de Documento
			if ($GLOBALS['nrdocttl']=='') exibirErro('error','Nr. Documento inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrdocttl\',\'frmDadosIdentFisica\')',false);
			
			// Orgão Emissor
			if ($GLOBALS['cdoedttl']=='') exibirErro('error','Org&atilde;o Emissor inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdoedttl\',\'frmDadosIdentFisica\')',false);
			
			// UF Emissor
			if ($GLOBALS['cdufdttl']=='') exibirErro('error','U.F. Emissor inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdufdttl\',\'frmDadosIdentFisica\')',false);		
			
			// Data Emissão
			if (!validaData($GLOBALS['dtemdttl'])) exibirErro('error','Data de Emiss&atilde;o do C.P.F. inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtemdttl\',\'frmDadosIdentFisica\')',false);
			
			// Tipo Nacionalidade
			if (!validaInteiro($GLOBALS['tpnacion'])) exibirErro('error','Tipo Nacionalidade inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'tpnacion\',\'frmDadosIdentFisica\')',false);
			if ($GLOBALS['tpnacion'] == 0) exibirErro('error','Tipo Nacionalidade deve ser diferente de zero.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'tpnacion\',\'frmDadosIdentFisica\')',false);
			
			// Nacionalidade
			if ($GLOBALS['cdnacion']=='') exibirErro('error','Nacionalidade inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdnacion\',\'frmDadosIdentFisica\')',false);
            if ($GLOBALS['cdnacion'] == 0) exibirErro('error','Nacionalidade deve ser diferente de zero.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdnacion\',\'frmDadosIdentFisica\')',false);
			
			// Sexo 
			if (($GLOBALS['cdsexotl'] != 1)&&($GLOBALS['cdsexotl'] != 2)) exibirErro('error','Sexo inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdsexotl\',\'frmDadosIdentFisica\')',false);			
			
			// Naturalidade
			if ($GLOBALS['dsnatura']=='') exibirErro('error','Naturalidade inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dsnatura\',\'frmDadosIdentFisica\')',false);
			
			// UF Naturalidade
			if ($GLOBALS['cdufnatu'] == '' ) exibirErro('error','UF de naturalidade deve ser selecionada.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdufnatu\',\'frmDadosIdentFisica\');',false);
			
			// Data Nascimento
			if (!validaData($GLOBALS['dtnasttl'])) exibirErro('error','Data de Nascimento inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtnasttl\',\'frmDadosIdentFisica\')',false);			
			
			// Responsabilidade Legal
			if (($GLOBALS['inhabmen'] != 0)&&($GLOBALS['inhabmen'] != 1)&&($GLOBALS['inhabmen'] != 2)) exibirErro('error','Responsabilidade Legal inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'inhabmen\',\'frmDadosIdentFisica\')',false);
			
			// Somente valida a Data de Emancipação quando a Responsabilidade Legal for 1 (Habilitado)
			if (!validaData($GLOBALS['dthabmen']) && ($GLOBALS['inhabmen'] == 1)) exibirErro('error','Data de Emancipa&ccedil;&atilde;o inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dthabmen\',\'frmDadosIdentFisica\')',false);

			// Data de emancipação não pode ser preenchida para quando a Responsabilidade legal for 0,2.
			if ($GLOBALS['dthabmen'] != '' && ($GLOBALS['inhabmen'] == 0 || $GLOBALS['inhabmen'] == 2)) exibirErro('error','Data de Emancipa&ccedil;&atilde;o n&atilde;o pode ser preenchida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dthabmen\',\'frmDadosIdentFisica\')',false);
																															
			// Estado Civil
			if (!validaInteiro($GLOBALS['cdestcvl'])) exibirErro('error','Estado Civil inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdestcvl\',\'frmDadosIdentFisica\')',false);
			if ($GLOBALS['cdestcvl'] == 0) exibirErro('error','Estado Civil deve ser diferente de zero.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdestcvl\',\'frmDadosIdentFisica\')',false);
					
			// Valida Nome Talão
			if ($GLOBALS['nmtalttl']=='') exibirErro('error','Nome Tal&atilde;o deve ser informado.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nmtalttl\',\'frmDadosIdentFisica\')',false);
			
			// Valida se qtde. folhas do talão é um inteiro
			if ($GLOBALS['idseqttl'] == 1  && !validaInteiro($GLOBALS['qtfoltal'])) exibirErro('error','Quantidade de Folhas no Tal&atilde;o inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'qtfoltal\',\'frmDadosIdentFisica\')',false);
			if ($GLOBALS['idseqttl'] == 1  && $GLOBALS['qtfoltal'] <> 10 && $GLOBALS['qtfoltal'] <> 20) exibirErro('error','Quantidade de Folhas no Tal&atilde;o deve ser 10 ou 20.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'qtfoltal\',\'frmDadosIdentFisica\')',false);	
		}		
	}	
?>