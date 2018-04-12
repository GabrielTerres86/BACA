<?php 

	/************************************************************************
	 Fonte: titulos_bordero_resumo.php                                        
	 Autor: Alex Sandro (GFT)
	 Data : 22/03/2018                Última Alteração: 
	                                                                  
	 Objetivo  : Resumo de um novo Bordero

	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");


	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	setVarSession("nmrotina","DSC TITS - BORDERO");

	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
		exit;
	}
	$selecionados = isset($_POST["selecionados"]) ? $_POST["selecionados"] : array();
	if(count($selecionados)==0){
		exibeErro("Selecione ao menos um t&iacute;tulo");
		exit;
	}
	$selecionados = implode($selecionados,",");

	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <nrnosnum>".$selecionados."</nrnosnum>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

 	// CONSULTA DA IBRATAN	
    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","SOLICITA_BIRO_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
		echo "<script>";
       echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);");setTimeout(function(){bloqueiaFundo($(\'#divError\'))},1);';
		echo "</script>";
		// exit;
	}
	
	// LISTA TODOS OS TITULOS SELECIONADOS COM AS CRITICAS E RETORNO DA IBRATAN
	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <nrnosnum>".$selecionados."</nrnosnum>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    // FAZER O INSERT CRAPRDR e CRAPACA
    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","LISTAR_TITULOS_RESUMO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

	$dados = $xmlObj->roottag->tags[0];
    $qtTitulos = $xmlObj->roottag->tags[0]->attributes['QTREGIST'];

    // Se ocorrer um erro, mostra mensagem
    
	if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
		echo "<script>";
       echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);");';
		echo "</script>";
		exit;
	}

	
?>

<div id="divResumoBordero">

	<form id="formPesquisaTitulos" class="formulario">
		<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo $nrdconta; ?>" />
		
		<div id="divTitulos" class="formulario">
			<fieldset>
				<legend>Resumo</legend>
				<div class="divRegistrosTitulos divRegistros">
					<table class="tituloRegistros">
						<thead>
							<tr>
								<th>Conv&ecirc;nio</th>
								<th>Boleto n&ordm;</th>
								<th>Nome Pagador</th>
								<th>Data Vencimento</th>
								<th>Valor do T&iacute;tulo</th>
								<th>Situa&ccedil;&atilde;o</th>
								<th>Restri&ccedil;&atilde;o</th>
							</tr>			
						</thead>
						<tbody>
							<?
						    	foreach($dados->tags AS $t){ ?>
						    		<tr id="titulo_<? echo getByTagName($t->tags,'nrnosnum');?>" onclick="selecionaTituloResumo('<? echo getByTagName($t->tags,'nrnosnum');?>');">
						    			<td><input type='hidden' name='selecionados' value='<? echo getByTagName($t->tags,'nrnosnum');?>'/><? echo getByTagName($t->tags,'nrcnvcob');?></td>
						    			<td><? echo getByTagName($t->tags,'nrdocmto');?></td>
						    			<td><? echo getByTagName($t->tags,'nrinssac').' - '.getByTagName($t->tags,'nmdsacad');?></td>
						    			<td><? echo getByTagName($t->tags,'dtvencto');?></td>
						    			<td><span><? echo converteFloat(getByTagName($t->tags,'vltitulo'));?></span><? echo formataMoeda(getByTagName($t->tags,'vltitulo'));?></td>
						    			<?
							    			$sit = getByTagName($t->tags,'dssituac');
								    		if ($sit=="N") { ?>
									    		<td><img src='../../imagens/icones/sit_ok.png'/></td>
								    		<? }
								    		elseif ($sit=="S") { ?>
									    		<td><img src='../../imagens/icones/sit_er.png'/></td>
								    		<? }
								    		else{ ?>
									    		<td></td>
								    		<? }
								    	?>
						    			<?
							    			$sit = getByTagName($t->tags,'sitibrat');
								    		if ($sit=="N") { ?>
									    		<td><img src='../../imagens/icones/sit_ok.png'/></td>
								    		<? }
								    		elseif ($sit=="S") { ?>
									    		<td><img src='../../imagens/icones/sit_er.png'/></td>
								    		<? }
								    		else{ ?>
									    		<td></td>
								    		<? }
								    	?>
						    		</tr>
						    	<? }
					    	?>
						</tbody>
					</table>
				</div>
			</fieldset>
			
		</div>
	</form>
</div>


<div id="divBotoesTitulosLimite" style="margin-bottom:10px;">
	<input type="button" class="botao" value="Voltar"  onClick="voltaDiv(4,3,5,'DESCONTO DE T&Iacute;TULOS - BORDEROS');return false; " />
	<input type="button" class="botao" value="Remover T&iacute;tulo"  onClick="showConfirmacao('Deseja excluir o t&iacute;tulo do border&ocirc;?','Confirma&ccedil;&atilde;o - Ayllos','removerTituloResumo();','bloqueiaFundo(divRotina);','sim.gif','nao.gif');"/>
	<input type="button" class="botao" value="Ver Detalhes" onClick="mostrarDetalhesPagador();return false;"/>
	<input type="button" class="botao" value="Confirmar Inclus&atilde;o" onClick="showConfirmacao('Confirma inclus&atilde;o do border&ocirc;?','Confirma&ccedil;&atilde;o - Ayllos','confirmarInclusao();','bloqueiaFundo(divRotina);','sim.gif','nao.gif');" />
</div>
<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao4","divOpcoesDaOpcao1;divOpcoesDaOpcao2;divOpcoesDaOpcao3;divOpcoesDaOpcao5");

	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - BORDERO - RESUMO");

	formataLayout('divResumoBordero');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

    var registros = $(".divTitulos","#divResumoBordero");
    var table = registros.find(">table");
    var ordemInicial = new Array();
    table.formataTabela( ordemInicial, arrayLarguraInclusaoBordero, arrayAlinhaInclusaoBordero, '' );


</script>