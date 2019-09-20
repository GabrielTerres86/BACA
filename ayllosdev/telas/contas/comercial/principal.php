<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 24/05/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de Comercial da tela de CONTAS 
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1).
 *				  09/12/2011 - Ajuste para inclusao do campo Justificativa (Adriano).
 *			      18/12/2013 - Ajuste em casas flutuantes dos valores dos rendimentos. (Jorge)
 *                18/08/2015 - Reformulacao cadastral (Gabriel-RKAM)
 *                03/12/2015 - Gravar valores dos rendimentos corretamente nas variaveis (Gabriel-RKAM).
 *			      12/01/2016 - Ajuste para pegar corretamento os valores vldrendi, tpdrendi (Adriano - CECRED).
 *                07/06/2016 - Melhoria 195 folha de pagamento (Tiago/Thiago)
 *				  13/07/2016 - Correcao de acesso ao indice MSGALERT do array XML. SD 479874. (Carlos R.)	
 *                01/12/2016 - Definir a não obrigatoriedade do PEP (Tiago/Thiago SD532690)
 *                20/09/2017 - Ajustes para carregar endereço comercial corretamente. PRJ339 - CRM(Odirlei)
 *				  20/09/2017 - Ajuste onde o turno e nivel cargo nao estavam sendos carregados. (PRJ339 - Kelvin) 
 *                21/09/2017 - Ajuste para pegar o tpdrendi e vldrendi na posição correta do xml (Adriano - SD ).
 *                10/10/2017 - Ajuste para chamar fonte principal.php apenas uma vez qnd vem da tela matric. PRJ339 - CRM(Odirlei-AMcom)
 *                05/07/2018 - Ajustado rotina para que nao haja inconsistencia nas informacoes da empresa
 *							   (CODIGO, NOME E CNPJ DA EMPRESA). (INC0018113 - Kelvn)
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();				
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';	
	
	
	// Monta o "cddopcao" de acordo com a operação
	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];
	$cddopcao = ( $operacao == 'CA' || $operacao == 'CAE' ) ? 'A' : 'C';
	$op       = ( $cddopcao == 'C' ) ? '@' : $cddopcao ;
	
    // forçar opecao CA, para carregar o endereço correto na bo75
    $cddopcao = ( $operacao == 'CA' ) ? 'CA' : $cddopcao;
    
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op,false)) <> '') {
		$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'encerraRotina(false);';
		exibirErro('error',$msgError,'Alerta - Aimaro',$metodo,false);
	}
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','fechaRotina(divRotina)',false);

	// Carrega permissões do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);

	// Carregas as opções da Rotina de Bens
	$flgAlterar  = (in_array("A", $glbvars["opcoesTela"]));
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = $_POST['nrdconta'] == '' ?  0  : $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'] == '' ?  0  : $_POST['idseqttl'];
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';
	$cdnatopc = (isset($_POST['cdnatopc'])) ? $_POST['cdnatopc'] : '';
	$cdocpttl = (isset($_POST['cdocpttl'])) ? $_POST['cdocpttl'] : '';
	$tpcttrab = (isset($_POST['tpcttrab'])) ? $_POST['tpcttrab'] : '';
	$cdempres = (isset($_POST['cdempres'])) ? $_POST['cdempres'] : '';	
	$dsproftl = (isset($_POST['dsproftl'])) ? $_POST['dsproftl'] : '';	
	$cdnvlcgo = (isset($_POST['cdnvlcgo'])) ? $_POST['cdnvlcgo'] : '';	
	$cdturnos = (isset($_POST['cdturnos'])) ? $_POST['cdturnos'] : '';	
	$dtadmemp = (isset($_POST['dtadmemp'])) ? $_POST['dtadmemp'] : '';	
	$vlsalari = (isset($_POST['vlsalari'])) ? $_POST['vlsalari'] : '';	
	$nrcadast = (isset($_POST['nrcadast'])) ? $_POST['nrcadast'] : '';
    $tpdrendi = (isset($_POST['tpdrendi'])) ? $_POST['tpdrendi'] : '';
    $vldrendi = (isset($_POST['vldrendi'])) ? $_POST['vldrendi'] : '';
    $tpdrend2 = (isset($_POST['tpdrend2'])) ? $_POST['tpdrend2'] : '';
    $vldrend2 = (isset($_POST['vldrend2'])) ? $_POST['vldrend2'] : '';
    $tpdrend3 = (isset($_POST['tpdrend3'])) ? $_POST['tpdrend3'] : '';
    $vldrend3 = (isset($_POST['vldrend3'])) ? $_POST['vldrend3'] : '';
    $tpdrend4 = (isset($_POST['tpdrend4'])) ? $_POST['tpdrend4'] : '';
    $vldrend4 = (isset($_POST['vldrend4'])) ? $_POST['vldrend4'] : '';
	$inpolexp = (isset($_POST['inpolexp'])) ? $_POST['inpolexp'] : 0;	
	$nmdsecao = (isset($_POST['nmdsecao'])) ? $_POST['nmdsecao'] : '';
	$cooperativa = $glbvars['cdcooper'];
			

	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','fechaRotina(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl n&atilde;o foi informada.','Alerta - Aimaro','fechaRotina(divRotina)',false);
	
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0075.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
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
	$xml .= '		<vlsalari>'.$vlsalari.'</vlsalari>';	
	$xml .= '		<nrcadast>'.$nrcadast.'</nrcadast>';	
	$xml .= '		<tpdrendi>'.$tpdrendi.'</tpdrendi>';	
	$xml .= '		<vldrendi>'.$vldrendi.'</vldrendi>';	
	$xml .= '		<tpdrend2>'.$tpdrend2.'</tpdrend2>';	
	$xml .= '		<vldrend2>'.$vldrend2.'</vldrend2>';	
	$xml .= '		<tpdrend3>'.$tpdrend3.'</tpdrend3>';	
	$xml .= '		<vldrend3>'.$vldrend3.'</vldrend3>';	
	$xml .= '		<tpdrend4>'.$tpdrend4.'</tpdrend4>';	
	$xml .= '		<vldrend4>'.$vldrend4.'</vldrend4>';	
	$xml .= '		<inpolexp>'.$inpolexp.'</inpolexp>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);	
	$xmlObjeto = getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') 
	exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','fechaRotina(divRotina);',false);	


	$comercial = $xmlObjeto->roottag->tags[0]->tags[0]->tags;	
	$msgAlert  = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) : '';
	$cdnvlcgo  = getByTagName($comercial,'cdnvlcgo');
	$cdturnos  = getByTagName($comercial,'cdturnos');	
	$nrdrowid  = getByTagName($comercial,'nrdrowid');
	$tppesemp  = getByTagName($comercial,'tppesemp');
				
	$inpolexp  = getByTagName($comercial,'inpolexp');	
				
	//Verifico se conta é titular em outra conta. Se atributo vier preenchido, muda operação para 'SC' => Somente Consulta
	$msgConta = trim($xmlObjeto->roottag->tags[0]->attributes['MSGCONTA']);
	if( $msgConta != '' ) $operacao = 'SC';
	
	
	/*RENDAS AUTOMATICAS*/
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";	
    $xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";	
    $xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xml .= "		<dtmvtoan>".$glbvars["dtmvtoan"]."</dtmvtoan>";	
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML
    $xmlResult = mensageria($xml, "CONTAS", "BUSCA_LANAUT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");     
    
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
		$edDtrefere = "";
		$edVlrefere = "";
	}else{
		$result = $xmlObjeto->roottag->tags;

		foreach($result as $meses){		
			if( trim(getByTagName($meses->tags,'TotalLancMes')) <> '' ){
				$edDtrefere = getByTagName($meses->tags,'referencia');
				$edVlrefere = getByTagName($meses->tags,'TotalLancMes');
			}
		}
	}
		
?>


<script type='text/javascript'>
	var tpdrendi = 0;
	var tpdrend2 = 0;
	var tpdrend3 = 0;
	var tpdrend4 = 0;
	var vldrendi = 0;
	var vldrend2 = 0;
	var vldrend3 = 0;
	var vldrend4 = 0;
		 
	tpdrendi = '<? echo str_replace(",",".",getByTagName($comercial[12]->tags,'tpdrendi.1')); ?>';
	tpdrend2 = '<? echo str_replace(",",".",getByTagName($comercial[12]->tags,'tpdrendi.2')); ?>';
	tpdrend3 = '<? echo str_replace(",",".",getByTagName($comercial[12]->tags,'tpdrendi.3')); ?>';
	tpdrend4 = '<? echo str_replace(",",".",getByTagName($comercial[12]->tags,'tpdrendi.4')); ?>';
	
	vldrendi = '<? echo str_replace(",",".",getByTagName($comercial[14]->tags,'vldrendi.1')); ?>';
	vldrend2 = '<? echo str_replace(",",".",getByTagName($comercial[14]->tags,'vldrendi.2')); ?>';
	vldrend3 = '<? echo str_replace(",",".",getByTagName($comercial[14]->tags,'vldrendi.3')); ?>';
	vldrend4 = '<? echo str_replace(",",".",getByTagName($comercial[14]->tags,'vldrendi.4')); ?>';
	
	$('#tpdrendi','#frmDadosComercial').val(<?php echo getByTagName($comercial[12]->tags,'tpdrendi.1'); ?>);
	$('#tpdrend2','#frmDadosComercial').val(<?php echo getByTagName($comercial[12]->tags,'tpdrendi.2'); ?>);
	$('#tpdrend3','#frmDadosComercial').val(<?php echo getByTagName($comercial[12]->tags,'tpdrendi.3'); ?>);
	$('#tpdrend4','#frmDadosComercial').val(<?php echo getByTagName($comercial[12]->tags,'tpdrendi.4'); ?>);

	$('#vldrendi','#frmDadosComercial').val('<?php echo getByTagName($comercial[14]->tags,'vldrendi.1'); ?>');
	$('#vldrend22','#frmDadosComercial').val('<?php echo getByTagName($comercial[14]->tags,'vldrendi.2'); ?>');
	$('#vldrend3','#frmDadosComercial').val('<?php echo getByTagName($comercial[14]->tags,'vldrendi.3'); ?>');
	$('#vldrend4','#frmDadosComercial').val('<?php echo getByTagName($comercial[14]->tags,'vldrendi.4'); ?>');
	
	if('<? echo $cddopcao; ?>' == 'C'){
		otrsrend = parseFloat(vldrendi) + parseFloat(vldrend2) + parseFloat(vldrend3) + parseFloat(vldrend4);
		otrsrend = otrsrend.toFixed(2);
	}
	
	$('#otrsrend','#frmDadosComercial').val(otrsrend.toString().replace(".",","));
	$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
			
</script>
<?php
	include('busca_informacoes_empresa.php');
	include('formulario_comercial.php');
?>
<script type='text/javascript'>
	var msgAlert = '<? echo $msgAlert ?>';
	var msgConta = '<? echo $msgConta ?>';
	var operacao = '<? echo $operacao ?>';
	
	if (inpessoa == 1) {
		var flgAlterar   = '<? echo $flgAlterar;   ?>';
		var flgcadas     = '<? echo $flgcadas;     ?>';
		var cooperativa  = '<? echo $cooperativa;  ?>';
				
		if (flgcadas == 'M' && operacao == '') {
            
            // retirada chamada qnd tela matric pois chamava fonte duas vezes, fazendo com que algumas inf
            // nao fosse carregadas como cdturnos e cdnvlcgo
			//controlaOperacao('CA');
            operacao = 'CA' ;
		}
		
	}
			
	nrdrowid = '<? echo $nrdrowid ?>';
	
		cdturnos = '<? echo $cdturnos ?>';
		cdnvlcgo = '<? echo $cdnvlcgo ?>';
	
		
	controlaLayout(operacao);
	
	if ( msgConta != '' ) { 
		showError('inform',msgConta,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');');
	}else if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');');
	}
	
</script>