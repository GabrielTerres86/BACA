<?php
/*
 * FONTE        : novo_limite.php
 * CRIAÇÃO      : David (CECRED)
 * DATA CRIAÇÃO : Março/2008
 * OBJETIVO     : Mostrar opção Novo Limite da rotina de Limite de Crédito da tela ATENDA   
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [15/07/2009] Guilherme       (CECRED) : Título para as telas
 * 000: [13/04/2010] David           (CECRED) : Adaptação para novo RATING
 * 000: [16/09/2010] David           (CECRED) : Ajuste para enviar impressoes via email para o PAC Sede
 * 000: [27/10/2010] David           (CECRED) : Tratamento para projeto de linhas de crédito
 * 001: [27/04/2011] Rodolpho Telmo     (DB1) : Adaptação formulário genérico avalistas e endereço
 * 002: [23/09/2011] Guilherme       (CECRED) : Adaptar para Rating Singulares
 * 003: [09/07/2012] Jorge           (CECRED) : Retirado campo "redirect"
 * 004: [28/08/2012] Lucas R         (CECRED) : Alimentado variavel flgProposta
 * 005: [23/11/2012] Adriano		 (CECRED) : Alterado a função onClick do botao btSalvar na 
											    divDadosAvalistas de validarAvalistas para buscaGrupoEconomico.
 * 006: [06/04/2015] Jonata            (RKAM) :	Consultas automatizadas.							
*  007: [01/06/2015] Lucas Reinert	 (CECRED) : Alterado para apresentar mensagem de confirmacao de proposta para
*												menores nao emancipados. (Reinert)
 * 008: [25/07/2016] Carlos R.		 (CECRED) : Corrigi a forma de recuperacao de dados do XML de retorno. SD 479874.
* 009: [05/12/2017] Lombardi         (CECRED) : Gravação do campo idcobope. Projeto 404
 * 010: [15/03/2018] Diego Simas	 (AMcom)  : Alterado para exibir tratativas quando o limite de crédito foi 
 *                                              cancelado de forma automática pelo Aimaro.  
 * 011: [04/06/2019] Mateus Z  (Mouts) : Alteração para chamar tela de autorização quando alterar valor. PRJ 470 - SM2
 * 012: [31/05/2019] Mateus Z   	 (Mouts)  : PRJ 438 - Ajuste na exibição de criticas relacionadas a cancelamento por
 *                                              motivo de inadimplencia.
 */	  

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	

	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro','');	
	}	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','');

	$nrdconta = $_POST["nrdconta"];
	$cddopcao = $_POST["cddopcao"];
	$flpropos = $_POST["flpropos"];
	$inconfir = (isset($_POST["inconfir"])) ? $_POST["inconfir"] : 1;	

	//bruno - prj 438 - sprint 7 - novo limite
	$inpessoa = $_POST['inpessoa'];

	$metodoContinue = '';

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','');
	
	
	// Monta o xml de requisição
	$xmlGetLimite  = "";
	$xmlGetLimite .= "<Root>";
	$xmlGetLimite .= "	<Cabecalho>";
	$xmlGetLimite .= "		<Bo>b1wgen0019.p</Bo>";
	$xmlGetLimite .= "		<Proc>obtem-limite</Proc>";
	$xmlGetLimite .= "	</Cabecalho>";
	$xmlGetLimite .= "	<Dados>";
	$xmlGetLimite .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetLimite .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetLimite .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetLimite .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetLimite .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetLimite .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetLimite .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetLimite .= "		<idseqttl>1</idseqttl>";
	$xmlGetLimite .= "		<flpropos>".$flpropos."</flpropos>";
	$xmlGetLimite .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetLimite .= "		<inconfir>".$inconfir."</inconfir>";
	$xmlGetLimite .= "	</Dados>";
	$xmlGetLimite .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetLimite);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLimite = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjLimite->roottag->tags[0]->name) && strtoupper($xmlObjLimite->roottag->tags[0]->name) == "ERRO") 
		exibirErro('error',$xmlObjLimite->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
		
	$qtMensagens = count($xmlObjLimite->roottag->tags[1]->tags);	
	$mensagem  	 = ( isset($xmlObjLimite->roottag->tags[1]->tags[$qtMensagens - 1]->tags[1]->cdata) ) ? $xmlObjLimite->roottag->tags[1]->tags[$qtMensagens - 1]->tags[1]->cdata : '';
	$inconfir	 = ( isset($xmlObjLimite->roottag->tags[1]->tags[$qtMensagens - 1]->tags[0]->cdata) ) ? $xmlObjLimite->roottag->tags[1]->tags[$qtMensagens - 1]->tags[0]->cdata : null;	
	
	if ($inconfir == 2) { ?>
		<script type="text/javascript">		
		hideMsgAguardo();
		showConfirmacao("<? echo $mensagem ?>","Confirma&ccedil;&atilde;o - Aimaro","confirmaInclusaoMenor(<? echo $nrdconta.",'".$cddopcao."',".$flpropos.",".$inconfir ?>);","acessaOpcaoAba(<? echo count($glbvars["opcoesTela"]).",0,'@'"?>);","sim.gif","nao.gif");
		</script>
		<?php exit();
	}
	
	$limite = $xmlObjLimite->roottag->tags[0]->tags[0]->tags;
	
	if($cddopcao == 'N'){
		//Verifica se pode ser incluído novo limite
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Dados>";
		$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "ZOOM0001", "CONSISTE_NOVO_LIMITE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
		$xmlObjeto = getObjectXML($xmlResult);	
		
		$param = $xmlObjeto->roottag->tags[0]->tags[0];

		$autnovlim = getByTagName($param->tags,'autoriza');	
		$saldo = getByTagName($param->tags,'saldo');	
		
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',"controlaOperacao('');",false); 
		}	

		if($autnovlim == 1){
			if($saldo > 0){
				// MENSAGEM DE INADIMPLÊNCIA
				$travaCamposLimite = 'S';
				echo '<script type="text/javascript">';
				echo 'hideMsgAguardo();';
				echo 'fechaRotina(divRotina);';
				echo 'bloqueiaFundo(divRotina);';
				echo 'showError(\'error\',\'Limite de Cr&eacute;dito cancelado por motivo de inadimpl&ecirc;ncia, n&atilde;o &eacute; poss&iacute;vel realizar a opera&ccedil;&atilde;o!\',\'Alerta - Aimaro\',\'exibeRotina(divRotina); acessaTela("@")\');';
				echo '</script>';				
				exit;
			}else{			
				$travaCamposLimite = 'S';
				// MENSAGEM DE INADIMPLÊNCIA
				echo '<script type="text/javascript">';
				echo 'hideMsgAguardo();';
				echo 'showError(\'error\',\'Limite de Cr&eacute;dito cancelado por motivo de inadimpl&ecirc;ncia, &eacute; necess&aacute;rio senha do coordenador!\',\'Alerta - Aimaro\',\'\');';
				echo '</script>';				
				// PEDE SENHA COORDENADOR
				echo '<script type="text/javascript">';
				echo 'bloqueiaFundo(divRotina);';
				echo 'hideMsgAguardo();';
				echo 'pedeSenhaCoordenador(2,"continuaLimite();","");';
				echo '</script>';	
			}
		}	
	}		

	// PRJ 438 - Sprint 7 - Tratar para caso o valor for 0(inclusao), mostrar vazio
	$nrctrlim = getByTagName($limite,"nrctrpro") ? getByTagName($limite,"nrctrpro") : '';
	$vllimite = getByTagName($limite,"vllimpro") ? str_replace(",",".",getByTagName($limite,"vllimpro")) : '';
	$flgimpnp = getByTagName($limite,"flgimpnp");
	$cddlinha = getByTagName($limite,"cddlinha") ? getByTagName($limite,"cddlinha") : '';
	$dsdlinha = getByTagName($limite,"dsdlinha");	
	$nrgarope = getByTagName($limite,"nrgarope"); 
	$nrinfcad = getByTagName($limite,"nrinfcad");
	$nrliquid = getByTagName($limite,"nrliquid");
	$nrpatlvr = getByTagName($limite,"nrpatlvr");
	$nrperger = getByTagName($limite,"nrperger");	
	$nrcpfcjg = getByTagName($limite,"nrcpfcjg");
	$nrctacje = getByTagName($limite,"nrctacje");
	$dtconbir = getByTagName($limite,"dtconbir");
	$idcobope = getByTagName($limite,"idcobope");
	// PRJ 438 - Sprint 7 - Novos campos
	$dsdtxfix = getByTagName($limite,"dsdtxfix");
	$vlsalari = 0;
	$vlsalcon = 0;
	$vloutras = 0;
	$vlalugue = 0;
	$nivrisco = getByTagName($limite,"nivrisco");
	$inconcje = getByTagName($limite,"inconcje");
    
	// Verifica se existe uma proposta cadastrada
	$flgProposta = (intval($nrctrlim) > 0 && doubleval($vllimite) > 0) ? true : false;
	
	// Procura indíce da opção "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	if ($idPrincipal === false) {
		$idPrincipal = 0;
	}

	$fncPrincipal = "acessaOpcaoAba(".count($glbvars["opcoesTela"]).",".$idPrincipal.",'".$glbvars["opcoesTela"][$idPrincipal]."');";	

	// Procura indíce da opção "I"
	$idImpressao = array_search("I",$glbvars["opcoesTela"]);
	
	// Se o índice da opção "I" foi encontrado 
	if (!($idImpressao === false)) {
		//bruno - prj 470 - tela autorizacao
		$idImpressao = "'IA'";
		$fncImpressao = "acessaOpcaoAba('','',".$idImpressao.")";
		//$fncImpressao = "acessaOpcaoAba(".count($glbvars["opcoesTela"]).",".$idImpressao.",'".$glbvars["opcoesTela"][$idImpressao]."');";
	} else {
		//bruno - prj 470 - tela autorizacao
		$idImpressao = "'IA'";
		$fncImpressao = "acessaOpcaoAba('','',".$idImpressao.")";
		//$fncImpressao = "acessaOpcaoAba(".count($glbvars["opcoesTela"]).",".$idPrincipal.",'".$glbvars["opcoesTela"][$idPrincipal]."');";
	}


	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <cdacesso>HABILITA_RATING_NOVO</cdacesso>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_PARRAT", "CONSULTA_PARAM_CRAPPRM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjPRM = getObjectXML($xmlResult);

	$habrat = 'N';
	if (strtoupper($xmlObjPRM->roottag->tags[0]->name) == "ERRO") {
		$habrat = 'N';
	} else {
		$habrat = $xmlObjPRM->roottag->tags[0]->tags;
		$habrat = getByTagName($habrat[0]->tags, 'PR_DSVLRPRM');
	}

	if ($glbvars["cdcooper"] == 3 || $habrat == 'N') {
		//bruno - prj 438 - sprint 7 - tela rating
		$voltaAvalista  = "controlaVoltarAvalista(true);"; 
		$metodoAvanca   = "validarDadosRating();"; //bruno - prj 438 - sprint 7 - tela rating
	} else {
		//bruno - prj 438 - sprint 7 - tela rating
		$voltaAvalista  = "controlaVoltarAvalista(false);"; 
		$metodoAvanca   = "validarDadosRating();"; //bruno - prj 438 - sprint 7 - tela rating
	}

	if ($cddopcao != 'N') { // Consulta
		//bruno - prj 438 - sprint 7 - remoção telas
		$metodoContinue = "controlaOperacao('C_COMITE_APROV')"; //"controlaOperacao('C_PROTECAO_TIT');"; //
	}	

	// Monta o xml de requisi??o
	$xmlGetAvalistas  = "";
	$xmlGetAvalistas .= "<Root>";
	$xmlGetAvalistas .= "	<Cabecalho>";
	$xmlGetAvalistas .= "		<Bo>b1wgen0019.p</Bo>";
	$xmlGetAvalistas .= "		<Proc>busca-dados-avalistas</Proc>";
	$xmlGetAvalistas .= "	</Cabecalho>";
	$xmlGetAvalistas .= "	<Dados>";
	$xmlGetAvalistas .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetAvalistas .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetAvalistas .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetAvalistas .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";		
	$xmlGetAvalistas .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetAvalistas .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlGetAvalistas .= "	</Dados>";
	$xmlGetAvalistas .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetAvalistas);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAvalistas = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr?tica
	if (isset($xmlObjAvalistas->roottag->tags[0]->name) && strtoupper($xmlObjAvalistas->roottag->tags[0]->name) == "ERRO"){ 
		exibirErro('error',$xmlObjAvalistas->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','');
	}		
	
	$avalistas = $xmlObjAvalistas->roottag->tags[0]->tags;

?>

<!-- Criando variáveis em javascprit -->
<script type="text/javascript">
	var metodoBlock     = "blockBackground(parseInt($('#divRotina').css('z-index')))";		
	//bruno - prj 438 - sprint 7 - tela rating
	var metodoCancel    = "lcrShowHideDiv('divDadosObservacoes','divFormRating');"; //Metodo voltar para a tela de rating
	var metodoContinue  = "<? echo $metodoContinue; ?>"; //Metodo continuar para a tela de Rating
	var metodoAvanca	= "<? echo $metodoAvanca; ?>"; //Metodo Avançar para a tela de rating
	var metodoSucesso   = "<? echo $fncImpressao; ?>"; //Metodo sucesso para a tela de Rating
	var flgProposta		= "<? echo $flgProposta;  ?>"; //flgProposta
		
		
	var nrgarope        = "<? echo $nrgarope;  ?>";
	var nrinfcad        = "<? echo $nrinfcad;  ?>";		
	var nrliquid        = "<? echo $nrliquid;  ?>";
	var nrpatlvr        = "<? echo $nrpatlvr;  ?>";
	var nrperger        = "<? echo $nrperger;  ?>";	
	
	var nrcpfcjg        = "<? echo $nrcpfcjg;  ?>";
	var nrctacje        = "<? echo $nrctacje;  ?>";
	
	dtconbir            = "<? echo $dtconbir;  ?>";
	
    aux_vllimite_anterior = "<?php echo number_format(str_replace(",",".",$vllimite),2,",","."); ?>";
	
	var aux_rating = {
		nrgarope: "<? echo $nrgarope;  ?>",
		nrinfcad: "<? echo $nrinfcad;  ?>",		
		nrliquid: "<? echo $nrliquid;  ?>",
		nrpatlvr: "<? echo $nrpatlvr;  ?>",
		nrperger: "<? echo $nrperger;  ?>"	
	};

	//bruno - prj - 438 - sprint 7 - tela principal
	var aux_novoLimite = {
		nrctrlim: "<?php echo $nrctrlim ?>",
		vllimite: "<?php echo $vllimite ?>",
		flgimpnp: "<?php echo $flgimpnp ?>",
		cddlinha: "<?php echo $cddlinha ?>",
		dsdlinha: "<?php echo $dsdlinha ?>",	
		nrgarope: "<?php echo $nrgarope ?>", 
		nrinfcad: "<?php echo $nrinfcad ?>",
		nrliquid: "<?php echo $nrliquid ?>",
		nrpatlvr: "<?php echo $nrpatlvr ?>",
		nrperger: "<?php echo $nrperger ?>",	
		nrcpfcjg: "<?php echo $nrcpfcjg ?>",
		nrctacje: "<?php echo $nrctacje ?>",
		dtconbir: "<?php echo $dtconbir ?>",
		idcobope: "<?php echo $idcobope ?>"
	}
		
	if(flgProposta){
		changeAbaPropLabel("Alterar Limite");
	}else{
		changeAbaPropLabel("Novo Limite");
	}
		
	<? if ($cddopcao != 'N') { ?>
		$("input, textarea","#frmNovoLimite").desabilitaCampo();
	<?} ?>
			
	//bruno - prj 438 - tela rating
	getDadosRating();

	var arrayAvalistas = new Array();
	nrAvalistas     = 0;
	contAvalistas   = 1;

	<? 
	for ($i=0; $i<count($avalistas); $i++) {
	    if (getByTagName($avalistas[$i]->tags,'nrctaava') != 0 || getByTagName($avalistas[$i]->tags,'nrcpfcgc') != 0) {
	?>
			var arrayAvalista<? echo $i; ?> = new Object();

			arrayAvalista<? echo $i; ?>['nrctaava'] = '<? echo getByTagName($avalistas[$i]->tags,'nrctaava'); ?>';
			arrayAvalista<? echo $i; ?>['cdnacion'] = '<? echo getByTagName($avalistas[$i]->tags,'cdnacion'); ?>';
			arrayAvalista<? echo $i; ?>['dsnacion'] = '<? echo getByTagName($avalistas[$i]->tags,'dsnacion'); ?>';
			arrayAvalista<? echo $i; ?>['tpdocava'] = '<? echo getByTagName($avalistas[$i]->tags,'tpdocava'); ?>';
			arrayAvalista<? echo $i; ?>['nmconjug'] = '<? echo getByTagName($avalistas[$i]->tags,'nmconjug'); ?>';
			arrayAvalista<? echo $i; ?>['tpdoccjg'] = '<? echo getByTagName($avalistas[$i]->tags,'tpdoccjg'); ?>';
			arrayAvalista<? echo $i; ?>['dsendre1'] = '<? echo getByTagName($avalistas[$i]->tags,'dsendre1'); ?>';
			arrayAvalista<? echo $i; ?>['nrfonres'] = '<? echo getByTagName($avalistas[$i]->tags,'nrfonres'); ?>';
			arrayAvalista<? echo $i; ?>['nmcidade'] = '<? echo getByTagName($avalistas[$i]->tags,'nmcidade'); ?>';
			arrayAvalista<? echo $i; ?>['nrcepend'] = '<? echo getByTagName($avalistas[$i]->tags,'nrcepend'); ?>';
			arrayAvalista<? echo $i; ?>['nmdavali'] = '<? echo getByTagName($avalistas[$i]->tags,'nmdavali'); ?>';
			arrayAvalista<? echo $i; ?>['nrcpfcgc'] = '<? echo getByTagName($avalistas[$i]->tags,'nrcpfcgc'); ?>';
			arrayAvalista<? echo $i; ?>['nrdocava'] = '<? echo getByTagName($avalistas[$i]->tags,'nrdocava'); ?>';
			arrayAvalista<? echo $i; ?>['nrcpfcjg'] = '<? echo getByTagName($avalistas[$i]->tags,'nrcpfcjg'); ?>';
			arrayAvalista<? echo $i; ?>['nrdoccjg'] = '<? echo getByTagName($avalistas[$i]->tags,'nrdoccjg'); ?>';
			arrayAvalista<? echo $i; ?>['dsendre2'] = '<? echo getByTagName($avalistas[$i]->tags,'dsendre2'); ?>';
			arrayAvalista<? echo $i; ?>['dsdemail'] = '<? echo getByTagName($avalistas[$i]->tags,'dsdemail'); ?>';
			arrayAvalista<? echo $i; ?>['cdufresd'] = '<? echo getByTagName($avalistas[$i]->tags,'cdufresd'); ?>';
			arrayAvalista<? echo $i; ?>['vlrenmes'] = '<? echo getByTagName($avalistas[$i]->tags,'vlrenmes'); ?>';
			arrayAvalista<? echo $i; ?>['vledvmto'] = '<? echo getByTagName($avalistas[$i]->tags,'vledvmto'); ?>';
			arrayAvalista<? echo $i; ?>['nrendere'] = '<? echo getByTagName($avalistas[$i]->tags,'nrendere'); ?>';
			arrayAvalista<? echo $i; ?>['complend'] = '<? echo getByTagName($avalistas[$i]->tags,'complend'); ?>';
			arrayAvalista<? echo $i; ?>['nrcxapst'] = '<? echo getByTagName($avalistas[$i]->tags,'nrcxapst'); ?>';
			arrayAvalista<? echo $i; ?>['inpessoa'] = '<? echo getByTagName($avalistas[$i]->tags,'inpessoa'); ?>';
			arrayAvalista<? echo $i; ?>['dtnascto'] = '<? echo getByTagName($avalistas[$i]->tags,'dtnascto'); ?>';
			arrayAvalista<? echo $i; ?>['nrctacjg'] = '<? echo getByTagName($avalistas[$i]->tags,'nrctacjg'); ?>';
			arrayAvalista<? echo $i; ?>['vlrencjg'] = '<? echo getByTagName($avalistas[$i]->tags,'vlrencjg'); ?>';

			arrayAvalistas[<? echo $i; ?>] = arrayAvalista<? echo $i; ?>;

			nrAvalistas++;

	<?	
		}
	}
	?>
			
</script>

<table width="505" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td align="center">			
			<form action="" name="frmNovoLimite" id="frmNovoLimite" method="post" class="formulario condensado" onSubmit="return false;" >
			
				<?php if ($cddopcao == 'A' || $cddopcao == 'R') { ?>
					<div id="divDadosLimite">
						<? include('form_dados_limite_credito.php') ?>
					</div>
				<?php } else { ?>
					<div id="divDadosLimite">
						<? include('form_limite_credito.php') ?>
					</div>
				<?php } ?>
			
				<?php /* PRJ 438 - Sprint 7 - Comentado pois a tela não deve mais ser exibida
			<div id="divDadosRenda">
				<? include('form_dados_renda.php') ?>
			</div>
				*/ ?>
      
      <div id="divUsoGAROPC"></div>
  
      <div id="divFormGAROPC"></div>      
			
      			<div id="divDadosObservacoes">
					<?php include('form_observacoes.php') ?>
				</div>
			
				<div id='divFormRating'> <!-- bruno - prj 438 - sprint 7 - tela rating  -->
					<?php 
						// Variavel que indica se é uma operação para cadastrar nova proposta ou consulta - Utiliza na include rating_busca_dados.php
						$cdOperacao = ($cddopcao == 'N') ? 'I' : 'C';	
						$operacao   = ($flgProposta) ? 'A_PROT_CRED' : 'I_PROT_CRED' ;
						$inprodut   = 3; // Limite de Credito
						include('form_rating.php');
					?>
				</div>
			
				<!-- bruno - prj 438 - sprint 7 - tela demonstracao -->
				<div id='divDemoLimiteCredito'>
					<?php 
						include('form_demo_limite_credito.php');
					?>
			</div>
			
			<div id="divDadosAvalistas">
					<? //include('../../../includes/avalistas/form_avalista.php'); ?>
					<? include('form_avalista.php'); ?>
			</div>
			
			</form>	<!-- FIM frmNovoLimite -->	
			<?
				//bruno - prj 438 - sprint 7 - tela rating
				//include('../../../includes/rating/rating_busca_dados.php');
			?>
			
			
			<form action="<? echo $UrlSite; ?>telas/atenda/limite_credito/imprimir_dados.php" name="frmImprimir" id="frmImprimir" method="post">
				<input type="hidden" name="nrdconta" id="nrdconta" value="">
				<input type="hidden" name="nrctrlim" id="nrctrlim" value="">			
				<input type="hidden" name="idimpres" id="idimpres" value="">
				<input type="hidden" name="flgemail" id="flgemail" value="">
				<input type="hidden" name="flgimpnp" id="flgimpnp" value="">
				<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">		
			</form>		
			
      <div id="divBotoesGAROPC">
        <input type="image" id="btnVoltarGAROPC" name="btnVoltarGAROPC" src="<? echo $UrlImagens; ?>botoes/voltar.gif" />
        <input type="image" id="btnContinuarGAROPC" name="btnContinuarGAROPC" src="<? echo $UrlImagens; ?>botoes/continuar.gif" />
      </div>
			
		</td>
	</tr>			
</table>

<script>

		
	$("#divDadosRenda").css("display","none");
  $("#divFormGAROPC").css("display","none");
  $("#divBotoesGAROPC").css("display", "none");
	$("#divDadosObservacoes").css("display","none");
	$("#divDadosAvalistas").css("display","none");
	//bruno - prj 438 - sprint 7 - novo limite
	$("#divFormRating").css("display","none");
	$("#divDemoLimiteCredito").css("display","none");

	$("#tdTitDivDadosLimite").html("DADOS DO " + strTitRotinaUC);
	$("#divDadosLimite").css("display","block");

  $("#btnVoltarGAROPC","#divBotoesGAROPC").unbind("click").bind("click",function() {
    $("#divUsoGAROPC").empty();
    $("#divFormGAROPC").empty();
    $("#frmNovoLimite").css("width", 515);
		//bruno - prj 438 - sprint 7 - novo limite
		$('#frmGAROPC').remove();
		$("#divDadosLimite").css("display", "block"); 

    $("#divFormGAROPC").css("display", "none");
    $("#divBotoesGAROPC").css("display", "none");
		return false;
	});
  
  $("#btnContinuarGAROPC","#divBotoesGAROPC").unbind("click").bind("click",function() {
		// bruno - prj 438 - sprint 7 - remover telas
		gravarGAROPC('idcobert','frmNovoLimite','lcrShowHideDiv("divDadosObservacoes","divFormGAROPC");$("#divBotoesGAROPC").css("display", "none");$("#frmNovoLimite").css("width", 515);bloqueiaFundo($("#divDadosObservacoes"));');
    return false;
	});

	controlaLayout('<? echo $cddopcao; ?>');
	if(nrAvalistas > 0){
		atualizarCamposTelaAvalistas();
	}

	<? if($travaCamposLimite == 'S'){ ?>
		travaCamposLimite();
	<? } ?>

	setarDadosIdcobertAndObservacao();

	hideMsgAguardo();
	bloqueiaFundo(divRotina);
</script>												

<script>
	function continuaLimite(){
		$("#divDadosRenda").css("display","none");
		$("#divDadosObservacoes").css("display","none");
		$("#divDadosAvalistas").css("display","none");

		$("#tdTitDivDadosLimite").html("DADOS DO " + strTitRotinaUC);
		$("#divDadosLimite").css("display","block");	

		controlaLayout('<? echo $cddopcao; ?>');
		
		hideMsgAguardo();
		bloqueiaFundo(divRotina);		
	}	
</script>