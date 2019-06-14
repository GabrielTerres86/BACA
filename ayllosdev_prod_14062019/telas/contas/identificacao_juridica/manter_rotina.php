<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 24/03/2010 
 * OBJETIVO     : Rotina para validar/alterar os dados da IDENT. JURÍDICA da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [25/02/2015] Substituicao de caracteres especiais. (Jaison/Gielow - SD: 257871)
 * 001: [23/07/2015] Reformulacao Cadastral (Gabriel/RKAM)
 * 002: [22/06/2016] Removido a validação que não permitia inserir  vazio no campo 
				     de licença ambiental conforme solicitado no chamado 449294. (Kelvin)
 * 003: [10/08/2016] Inclusao de obrigatoriedade do CNAE. (Jaison/Anderson)
 * 004: [30/09/2016] Incluido validacao para Data validade da licenca 'dtvallic' (Tiago/Thiago M310)
 * 005: [13/07/2017] Incluido campo Identificador do Regime tributário 'tpregtrb' (Diogo M410)
 * 006: [18/10/2018] Remoção de caracteres especiais no campo dsendweb. (Douglas/Jefferson - Mouts)
 */
?>
 
<?	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();			
	
	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';	
	
	// Guardo os parâmetos do POST em variáveis
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nmfatasi = (isset($_POST['nmfatasi'])) ? $_POST['nmfatasi'] : '';
	$dtcnscpf = (isset($_POST['dtcnscpf'])) ? $_POST['dtcnscpf'] : '';
	$cdsitcpf = (isset($_POST['cdsitcpf'])) ? $_POST['cdsitcpf'] : '';
	$cdnatjur = (isset($_POST['cdnatjur'])) ? $_POST['cdnatjur'] : '';
	$qtfilial = (isset($_POST['qtfilial'])) ? $_POST['qtfilial'] : '';
	$qtfuncio = (isset($_POST['qtfuncio'])) ? $_POST['qtfuncio'] : '';
	$dtiniatv = (isset($_POST['dtiniatv'])) ? $_POST['dtiniatv'] : '';
	$cdseteco = (isset($_POST['cdseteco'])) ? $_POST['cdseteco'] : '';
	$cdrmativ = (isset($_POST['cdrmativ'])) ? $_POST['cdrmativ'] : '';
	$dsendweb = (isset($_POST['dsendweb'])) ? $_POST['dsendweb'] : '';
	$nmtalttl = (isset($_POST['nmtalttl'])) ? $_POST['nmtalttl'] : '';
	$qtfoltal = (isset($_POST['qtfoltal'])) ? $_POST['qtfoltal'] : '';	
	$dtcadass = (isset($_POST['dtcadass'])) ? $_POST['dtcadass'] : '';
	$cdcnae   = (isset($_POST['cdcnae']))   ? $_POST['cdcnae'] : '';	
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';
	$nrlicamb = (isset($_POST['nrlicamb'])) ? $_POST['nrlicamb'] : '';
	$dtvallic = (isset($_POST['dtvallic'])) ? $_POST['dtvallic'] : '';
	$tpregtrb = (isset($_POST['tpregtrb'])) ? $_POST['tpregtrb'] : '0';
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '';
	$cdnatjurAnt = $cdnatjur;

	$array1 = array("á","à","â","ã","ä","é","è","ê","ë","í","ì","î","ï","ó","ò","ô","õ","ö","ú","ù","û","ü","ç","ñ"
	               ,"Á","À","Â","Ã","Ä","É","È","Ê","Ë","Í","Ì","Î","Ï","Ó","Ò","Ô","Õ","Ö","Ú","Ù","Û","Ü","Ç","Ñ"
				   ,"&","¨","~","^","*","#","%","$","!","?",";",">","<","|","+","=","£","¢","¬","§","`","´","¹","²"
				   ,"³","ª","º","°","\"","'","\\","","→");
	$array2 = array("a","a","a","a","a","e","e","e","e","i","i","i","i","o","o","o","o","o","u","u","u","u","c","n"
                   ,"A","A","A","A","A","E","E","E","E","I","I","I","I","O","O","O","O","O","U","U","U","U","C","N"
				   ,"e"," "," "," "," "," "," "," "," "," ",";"," "," ","|"," "," "," "," "," "," "," "," "," "," "
				   ," "," "," "," "," "," "," ","-","-");

	// limpeza dos caracteres nos campos 
	$nmfatasi = trim(str_replace( $array1, $array2, $nmfatasi));
	$nmtalttl = trim(str_replace( $array1, $array2, $nmtalttl));
	$dsendweb = trim(str_replace( $array1, $array2, $dsendweb));
	
	if( $operacao == 'AV') validaDados();
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';
	switch($operacao) {
		case 'AV': $procedure = 'valida_dados'; break;
		case 'VA': $procedure = 'grava_dados' ; break;
		default: return false;
	}
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'A')) <> "") exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0053.p</Bo>';
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
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '       <idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '       <nmfatasi>'.$nmfatasi.'</nmfatasi>';
	$xml .= '       <dtcnscpf>'.$dtcnscpf.'</dtcnscpf>';
	$xml .= '       <cdsitcpf>'.$cdsitcpf.'</cdsitcpf>';
	$xml .= '       <cdnatjur>'.$cdnatjur.'</cdnatjur>';
	$xml .= '       <qtfilial>'.$qtfilial.'</qtfilial>';
	$xml .= '       <qtfuncio>'.$qtfuncio.'</qtfuncio>';
	$xml .= '       <dtiniatv>'.$dtiniatv.'</dtiniatv>';
	$xml .= '       <cdseteco>'.$cdseteco.'</cdseteco>';
	$xml .= '       <cdrmativ>'.$cdrmativ.'</cdrmativ>';
	$xml .= '       <dsendweb>'.$dsendweb.'</dsendweb>';
	$xml .= '       <nmtalttl>'.$nmtalttl.'</nmtalttl>';
	$xml .= '       <qtfoltal>'.$qtfoltal.'</qtfoltal>';
	$xml .= '       <dtcadass>'.$dtcadass.'</dtcadass>';
	$xml .= '       <cdcnae>'.$cdcnae.'</cdcnae>';
	
	if ($procedure == 'grava_dados') {
		$xml .= '       <nrlicamb>'.$nrlicamb.'</nrlicamb>';
		$xml .= '       <dtvallic>'.$dtvallic.'</dtvallic>';
	    $xml .= '       <tpregtrb>'.$tpregtrb.'</tpregtrb>';
	}
	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
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
	$impDecPJCoop = isset($xmlObjeto->roottag->tags[0]->attributes['IMPDECPJCOOP']) ? $xmlObjeto->roottag->tags[0]->attributes['IMPDECPJCOOP'] : '';
	
	if ($operacao == 'AV') {	

		exibirConfirmacao('Deseja confirmar alteração?' ,'Confirmação - Aimaro','controlaOperacao(\'VA\')','bloqueiaFundo(divRotina)',false);		
		
	} else if ($operacao == 'VA') {	
		
		// Caso a operação não é validar, então já realizou a validação, agora precisa verificar se existe "Verificação de Revisão Cadastral"
		if ($msgAtCad != '') {	

			if ($flgcadas == 'M') {
				echo 'revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0055.p\',\''.$stringArrayMsg.'\',\'\');';
			} else {
				exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0053.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
			}
			
			if ($impDecPJCoop == 'S'){
				echo 'imprimeDeclaracaoPJCooperativa();';					
			}
			
		} else {		
			// Se não é validar, então é alteração, portanto mostrar mensagem de sucesso e retornar para página principal
			echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\');';

		}

		if ($impDecPJCoop == 'S'){
			echo 'imprimeDeclaracaoPJCooperativa();';					
	}
	}

	function validaDados() {
		echo '$("input,select","#frmDadosIdentJuridica").removeClass("campoErro");';		

		// Nome Fantasia GLOBALS
		if ( $GLOBALS['nmfatasi'] == '' ) exibirErro('error','Nome Fantasia deve ser informado.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nmfatasi\',\'frmDadosIdentJuridica\')',false);

		// Regime de tributação - apenas para PJ - não usar validaInteiro pois zero retorna true, e neste caso zero deve retornar false (empty garante isso)
        $inPessoa = (int)substr($GLOBALS['inpessoa'], 0, 1);
 		if (($inPessoa >= 2) && (empty($GLOBALS['tpregtrb']))) exibirErro('error','Faltou informar o Regime tribut&aacute;rio.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'tpregtrb\',\'frmDadosIdentJuridica\')',false);
		//if ( $GLOBALS['nrdocava'] == '' ) exibirErro('error','Nr. do Documento inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nrdocava\',\'frmRespLegal\')',false);

		// Data Consulta CPF
		if (!validaData($GLOBALS['dtcnscpf'])) exibirErro('error','Data da Consulta C.P.F. inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'dtcnscpf\',\'frmDadosIdentJuridica\')',false);	

		// Situação do CPF 
		if (!validaInteiro($GLOBALS['cdsitcpf'])) exibirErro('error','Situa&ccedil;&atilde;o da Consulta do C.P.F. inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdsitcpf\',\'frmDadosIdentJuridica\')',false);
		if ($GLOBALS['cdsitcpf'] < 1 || $GLOBALS['cdsitcpf'] > 4) exibirErro('error','Situa&ccedil;&atilde;o da Consulta do C.P.F. inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdsitcpf\',\'frmDadosIdentJuridica\')',false);				

		// Dt. Início Atividade
		if (!validaData($GLOBALS['dtiniatv'])) exibirErro('error','Data de In&iacute;cio Atividade inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'dtiniatv\',\'frmDadosIdentJuridica\')',false);

		// Natureza Jurídica
		if (!validaInteiro($GLOBALS['cdnatjur'])) exibirErro('error','Natureza Jur&iacute;dica inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdnatjur\',\'frmDadosIdentJuridica\')',false);
		if ($GLOBALS['cdnatjur'] == 0) exibirErro('error','Natureza Jur&iacute;dica deve ser diferente de zero.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdnatjur\',\'frmDadosIdentJuridica\')',false);

		// Setor Econômico
		if (!validaInteiro($GLOBALS['cdseteco'])) exibirErro('error','Setor Econ&ocirc;mico inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdseteco\',\'frmDadosIdentJuridica\')',false);
		if ($GLOBALS['cdseteco'] < 1 || $cdseteco > 4) exibirErro('error','Setor Econ&ocirc;mico inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdseteco\',\'frmDadosIdentJuridica\')',false);

		// Ramo Atividade
		if (!validaInteiro($GLOBALS['cdrmativ'])) exibirErro('error','Ramo de Atividade inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdrmativ\',\'frmDadosIdentJuridica\')',false);
		if ($GLOBALS['cdrmativ'] == 0) exibirErro('error','Ramo de Atividade deve ser diferente de zero.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdrmativ\',\'frmDadosIdentJuridica\')',false);

		// CNAE
        if (!validaInteiro($GLOBALS['cdcnae'])) exibirErro('error','CNAE inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdcnae\',\'frmDadosIdentJuridica\')',false);
		if ($GLOBALS['cdcnae'] == 0) exibirErro('error','CNAE deve ser diferente de zero.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdcnae\',\'frmDadosIdentJuridica\')',false);

		// Nome no Talão
		if ($GLOBALS['nmtalttl']=='') exibirErro('error','Nome Tal&atilde;o deve ser informado.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nmtalttl\',\'frmDadosIdentJuridica\')',false);

		// Qtde. folhas do Talão 
		if (!validaInteiro($GLOBALS['qtfoltal'])) exibirErro('error','Quantidade de Folhas no Tal&atilde;o inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'qtfoltal\',\'frmDadosIdentJuridica\')',false);
		if ($GLOBALS['qtfoltal'] <> 10 && $GLOBALS['qtfoltal'] <> 20) exibirErro('error','Quantidade de Folhas no Tal&atilde;o deve ser 10 ou 20.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'qtfoltal\',\'frmDadosIdentJuridica\')',false);	

		if ( $GLOBALS['nrlicamb'] != '' && $GLOBALS['nrlicamb'] > 0 ){
		  if ( $GLOBALS['dtvallic'] == '' ) {
		    exibirErro('error','Data de validade da licen&ccedil;a deve ser preechida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'dtvallic\',\'frmDadosIdentJuridica\')',false);
		  }
		}
	}
?>
