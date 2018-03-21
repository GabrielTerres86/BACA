<?
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
 * 007: [01/06/2015] Lucas Reinert	 (CECRED) : Alterado para apresentar mensagem de confirmacao de proposta para
 *	   											menores nao emancipados. (Reinert)
 * 008: [15/03/2018] Diego Simas	 (AMcom)  : Alterado para exibir tratativas quando o limite de crédito foi 
 *                                              cancelado de forma automática pelo Ayllos.  
 */	  
?>

<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	

	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','');	
	}	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','');

	$nrdconta = $_POST["nrdconta"];
	$cddopcao = $_POST["cddopcao"];
	$flpropos = $_POST["flpropos"];
	$inconfir = (isset($_POST["inconfir"])) ? $_POST["inconfir"] : 1;	

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','');
	
	
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
	if (strtoupper($xmlObjLimite->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjLimite->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','');
		
	$qtMensagens = count($xmlObjLimite->roottag->tags[1]->tags);	
	$mensagem  	  = $xmlObjLimite->roottag->tags[1]->tags[$qtMensagens - 1]->tags[1]->cdata;
	$inconfir	  = $xmlObjLimite->roottag->tags[1]->tags[$qtMensagens - 1]->tags[0]->cdata;	
	
	if ($inconfir == 2) { ?>
		<script type="text/javascript">		
		hideMsgAguardo();
		showConfirmacao("<? echo $mensagem ?>","Confirma&ccedil;&atilde;o - Ayllos","confirmaInclusaoMenor(<? echo $nrdconta.",'".$cddopcao."',".$flpropos.",".$inconfir ?>);","acessaOpcaoAba(<? echo count($glbvars["opcoesTela"]).",0,'@'"?>);","sim.gif","nao.gif");
		</script>
		<? exit();
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
		
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"controlaOperacao('');",false); 
		}	

		if($autnovlim == 1){
			// MENSAGEM DE INADIMPLÊNCIA
			echo '<script type="text/javascript">';
			echo 'hideMsgAguardo();';
			echo 'showError("inform","Limite de Crédito cancelado por motivo de inadimplência, não é possível realizar a operação!","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
			echo '</script>';
			$travaCamposLimite = 'S';
			// PEDE SENHA COORDENADOR
			echo '<script type="text/javascript">';
			echo 'bloqueiaFundo(divRotina);';
			echo 'hideMsgAguardo();';
			echo 'pedeSenhaCoordenador(2,"continuaLimite();","");';
			echo '</script>';
		}	
	}		

	$nrctrlim = getByTagName($limite,"nrctrpro");
	$vllimite = str_replace(",",".",getByTagName($limite,"vllimpro"));
	$flgimpnp = getByTagName($limite,"flgimpnp");
	$cddlinha = getByTagName($limite,"cddlinha");
	$dsdlinha = getByTagName($limite,"dsdlinha");	
	$nrgarope = getByTagName($limite,"nrgarope"); 
	$nrinfcad = getByTagName($limite,"nrinfcad");
	$nrliquid = getByTagName($limite,"nrliquid");
	$nrpatlvr = getByTagName($limite,"nrpatlvr");
	$nrperger = getByTagName($limite,"nrperger");	
	$nrcpfcjg = getByTagName($limite,"nrcpfcjg");
	$nrctacje = getByTagName($limite,"nrctacje");
	$dtconbir = getByTagName($limite,"dtconbir");
    
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
		$fncImpressao = "acessaOpcaoAba(".count($glbvars["opcoesTela"]).",".$idImpressao.",'".$glbvars["opcoesTela"][$idImpressao]."');";
	} else {
		$fncImpressao = "acessaOpcaoAba(".count($glbvars["opcoesTela"]).",".$idPrincipal.",'".$glbvars["opcoesTela"][$idPrincipal]."');";
	}

	$voltaAvalista  = "lcrShowHideDiv('divDadosRating','divDadosAvalistas');return false"; 
	$metodoAvanca   = "validaDadosRating();";

	if ($cddopcao != 'N') { // Consulta
		$metodoContinue = "controlaOperacao('C_PROTECAO_TIT');";
	}		
	
?>

<!-- Criando variáveis em javascprit -->
<script type="text/javascript">
	var metodoBlock     = "blockBackground(parseInt($('#divRotina').css('z-index')))";		
	var metodoCancel    = "lcrShowHideDiv('divDadosObservacoes','divDadosRating');";
	var metodoContinue  = "<? echo $metodoContinue; ?>";
	var metodoAvanca	= "<? echo $metodoAvanca; ?>";
	var metodoSucesso   = "<? echo $fncImpressao; ?>";
	    flgProposta		= "<? echo $flgProposta;  ?>";		
		
	var nrgarope        = "<? echo $nrgarope;  ?>";
	var nrinfcad        = "<? echo $nrinfcad;  ?>";		
	var nrliquid        = "<? echo $nrliquid;  ?>";
	var nrpatlvr        = "<? echo $nrpatlvr;  ?>";
	var nrperger        = "<? echo $nrperger;  ?>";	
	
	var nrcpfcjg        = "<? echo $nrcpfcjg;  ?>";
	var nrctacje        = "<? echo $nrctacje;  ?>";
	
	dtconbir            = "<? echo $dtconbir;  ?>";
				
	if(flgProposta){
		changeAbaPropLabel("Alterar Limite");
	}else{
		changeAbaPropLabel("Novo Limite");
	}
		
	<? if ($cddopcao != 'N') { ?>
		$("input, textarea","#frmNovoLimite").desabilitaCampo();
	<?} ?>
			
</script>

<table width="505" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td align="center">			
			<form action="" name="frmNovoLimite" id="frmNovoLimite" method="post" class="formulario condensado" onSubmit="return false;" >
			
			<div id="divDadosLimite">
				<? include('form_limite_credito.php') ?>
			</div>
			
			
			<div id="divDadosRenda">
				<? include('form_dados_renda.php') ?>
			</div>
			
			<div id="divDadosObservacoes">
				<? include('form_observacoes.php') ?>
			</div>
			
			<div id="divDadosAvalistas">
			    <? include('../../../includes/avalistas/form_avalista.php'); ?>
				<div id="divBotoes">
					<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="<? echo $voltaAvalista; ?>">
					
					<? if ($cddopcao == 'N') { // Se for novo limite ou alteracao  ?>
						<input type="image" id="btCancelar" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="<? echo $fncPrincipal; ?>return false;">	
						<? if ($flgProposta) { // Alteracao ?>
 							<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('A_PROTECAO_AVAL');return false;">	
						<? } else {			   // Inclusao ?>			  
							<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="buscaGrupoEconomico();return false;">	
						<? } ?>
						
					<? } else { // Consulta ?>
						<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('C_PROTECAO_AVAL'); return false;">
					<? } ?>
				
				</div>				
			</div>
			
			</form>			
			<?
				// Variável que indica se é uma operação para cadastrar nova proposta ou consulta - Utiliza na include rating_busca_dados.php
				$cdOperacao = ($cddopcao == 'N') ? 'I' : 'C';	
				$operacao   = ($flgProposta) ? 'A_PROT_CRED' : 'I_PROT_CRED' ;
				$inprodut   = 3; // Limite de Credito
				
				include('../../../includes/rating/rating_busca_dados.php');
			?>
			
			
			<form action="<? echo $UrlSite; ?>telas/atenda/limite_credito/imprimir_dados.php" name="frmImprimir" id="frmImprimir" method="post">
				<input type="hidden" name="nrdconta" id="nrdconta" value="">
				<input type="hidden" name="nrctrlim" id="nrctrlim" value="">			
				<input type="hidden" name="idimpres" id="idimpres" value="">
				<input type="hidden" name="flgemail" id="flgemail" value="">
				<input type="hidden" name="flgimpnp" id="flgimpnp" value="">
				<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">						
			</form>		
			
		</td>
	</tr>			
</table>

<script>

		
	$("#divDadosRenda").css("display","none");
	$("#divDadosObservacoes").css("display","none");
	$("#divDadosAvalistas").css("display","none");

	$("#tdTitDivDadosLimite").html("DADOS DO " + strTitRotinaUC);
	$("#divDadosLimite").css("display","block");	

	// Se for inclusao/alteracao, habilitar avalista
	habilitaAvalista(<? echo ($cddopcao == 'N') ?>);
	
	controlaLayout('<? echo $cddopcao; ?>');

	<? if($travaCamposLimite == 'S'){ ?>
		travaCamposLimite();
	<? } ?>

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

		// Se for inclusao/alteracao, habilitar avalista
		habilitaAvalista(<? echo ($cddopcao == 'N') ?>);
		
		controlaLayout('<? echo $cddopcao; ?>');
		
		hideMsgAguardo();
		bloqueiaFundo(divRotina);		
	}	
</script>