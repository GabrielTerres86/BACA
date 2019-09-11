<?php 

	/***************************************************************************
	 Fonte: titulos_historico.php
	 Autor: Vitor Shimada (GFT)
	 Data : Outubro/2018                 Última Alteração: 

	 Objetivo  : Mostrar opção Títulos da Rotina de Histórico do Desconto de Títulos

	 Alterações: 16/07/2019 - PRJ 438 - Sprint 16 - Incluido botão voltar, para voltar para a tela principal (Mateus Z / Mouts)

	***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	setVarSession("nmrotina","DSC TITS");
	
	require_once("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica se os parêmetros necessários foram informados
	if (!isset($_POST["nrdconta"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];

	/*Verifica se o borderô deve ser utilizado no sistema novo ou no antigo*/
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "     <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "     <tpctrlim>3</tpctrlim>";
	$xml .= "     <nrctrlim>0</nrctrlim>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	$xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","LISTAR_HIST_ALT_LIMITE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getClassXML($xmlResult);
	$root = $xmlObj->roottag;
	// Se ocorrer um erro, mostra crítica
	if ($root->erro){
		exibeErro(htmlentities($root->erro->registro->dscritic));
		exit;
	}
	$dados = $root->dados;

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
?>
<div id="divTitulosUltAlteracoes">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Contrato</th>
					<th>In&iacute;cio</th>
					<th>Fim</th>
					<th>Limite</th>
					<th>Situa&ccedil;&atilde;o</th>
					<th>Data Situa&ccedil;&atilde;o</th>
					<th>Motivo</th>
				</tr>			
			</thead>
			<tbody>
				<?php foreach($dados->find("inf") as $t) {?>
					<tr>
						<td><?=$t->nrctrlim;?></td>
						<td><?=$t->dtinivig;?></td>
						<td><?=$t->dtfimvig;?></td>
						<td><?=$t->vllimite;?></td>
						<td><?=$t->dssitlim;?></td>
						<td><?=$t->dhalteracao;?></td>
						<td><?=$t->dsmotivo;?></td>
					</tr>
				<?php } ?>
			</tbody>
		</table>
	</div>
</div>
<!-- PRJ 438 - Sprint 16 - Incluido botão voltar, para voltar para a tela principal -->
<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onclick="acessaTelaPrincipal();return false;">Voltar</a>
</div>

<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao1","divConteudoOpcao");

	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS");

	formataLayout('divTitulosUltAlteracoes');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>