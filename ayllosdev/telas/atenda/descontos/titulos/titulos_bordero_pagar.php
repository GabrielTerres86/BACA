<?php 

	/************************************************************************
	 Fonte: titulos_bordero_pagar.php                                       
	 Autor: Vitor Shimada Assanuma (GFT)                                                 
	 Data : Maio/2018                Última Alteração: --/--/----
	                                                                  
	 Objetivo  : Fazer o pagamento dos titulos vencidos
	                                                                  	 
	 Alterações: 
	  - 17/09/2018 - Inserção do campo de Acordo (Vitor S. Assanuma - GFT)
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
	
	// Carrega permissões do operador
	include("../../../../includes/carrega_permissoes.php");
	
	setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrborder"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrborder = $_POST["nrborder"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	$xml =  "<Root>";
	$xml .= " <Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<nrborder>".$nrborder."</nrborder>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "BUSCAR_TIT_BORDERO_VENCIDOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getClassXML($xmlResult);
    $root = $xmlObj->roottag;
    // Se ocorrer um erro, mostra crítica
	if ($root->erro){
		exibeErro(htmlentities($root->erro->registro->dscritic));
		exit;
	}
	$dados = $root->dados;
	$quantidade = $dados->getAttribute("QTREGIST");

	//Caso nao possua nenhum titulo vencido exibe mensagem de erro
	if ($quantidade == 0){
		exibeErro("N&atilde;o h&aacute; t&iacute;tulos vencidos neste border&ocirc;, apenas &eacute; poss&iacute;vel resgatar.");
		exit();
	}
	
	// Função para exibir erros na tela atraves de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
?>
<div id="divBorderoTitulosPagar">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Pagamento</th>
					<th>N&#176; Boleto</th>
					<th>Data de Vencimento</th>
					<th>Valor do T&iacute;tulo</th>
					<th>Valor Pago</th>
					<th>Multa</th>
					<th>Juros de Mora</th>
					<th>IOF Atraso</th>
					<th>Valor Atual</th>
					<th>Valor a Pagar</th>
					<th>Em Acordo</th>
				</tr>			
			</thead>
			<tbody>
				<?php foreach($dados->find("inf") as $t) {?>
					<tr>
						<td><input class="pagar-pgto-tit" type="checkbox" value="<?=$t->nrtitulo?>" <?=$t->flacordo->cdata == 1 ? 'hidden' : '' ?>/></td>
						<td><?=$t->nrdocmto?></td>
						<td><?=$t->dtvencto?></td>
						<td><?=formataMoeda($t->vltitulo)?></td>
						<td><?=formataMoeda($t->vlpago)?></td>
						<td><?=formataMoeda($t->vlmulta)?></td>
						<td><?=formataMoeda($t->vlmora)?></td>
						<td><?=formataMoeda($t->vliof)?></td>
						<td><?=formataMoeda($t->vlsldtit)?></td>
						<td><?=formataMoeda($t->vlpagar)?></td>
						<td><?=$t->dsacordo?></td>
					</tr>
				<?php } ?>
			</tbody>
		</table>
	</div>
	<div>
		Exibindo <?=$quantidade?> registros
	</div>
	<div style="text-align: left">
		 <label> <input class="pagar-com-avalista" type="checkbox" value="1" />Pagamento Avalista</label>
	</div>
</div>
<div id="divBotoesTitulosLimite" style="margin-bottom:10px;">
	<input type="button" class="botao" value="Voltar"  onClick="carregaBorderosTitulos(); voltaDiv(3,2,4,'DESCONTO DE TÍTULOS - BORDERÔS'); " />
	<input type="button" class="botao" value="Continuar" onClick="pagarTitulosVencidos();"/>
</div>


<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao3","divOpcoesDaOpcao1;divOpcoesDaOpcao2");

	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - BORDERO - PAGAR");

	formataLayout('divBorderoTitulosPagar');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>