<?php 

	/****************************************************************
	 Fonte: principal.php                                            
	 Autor: Thaise Medeiros - Envolti                                                  
	 Data : Outubro/2018                 Última Alteração: 
	                                                                 
	 Objetivo  : Mostrar opcao Principal da rotina de Score Comportamental da tela ATENDA                                   
	                                                                 
	 Alter.:  
																   	 
	*****************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta inv&aacute;lida.");
	}
	
	
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "SCORE", "LISTA_SCORE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);fechaRotina(divRotina);');
	}
				
	$scores = $xmlObj->roottag->tags[0]->tags;
	
	
?>
<div id="divScore" class="divRegistros">
	<table class="">
		<thead>
			<tr>
				<th><? echo utf8ToHtml('Modelo'); ?></th>
				<th><? echo utf8ToHtml('Data'); ?></th>
				<th><? echo utf8ToHtml('Classe'); ?></th>
				<th><? echo utf8ToHtml('Pontuação'); ?></th>
				<th><? echo utf8ToHtml('Exclusão Principal'); ?></th>
				<th><? echo utf8ToHtml('Situação'); ?></th>
			</tr>
		</thead>
		<tbody><?
		if(count($scores) == 0){
			?>
			<tr>
				<td colspan="11" style="width: 80px; text-align: center;">
					<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
					<b>N&atilde;o h&aacute; registros para exibir.</b>
				</td>
			</tr>
			<?
		} else{
			foreach($scores as $score){
				?>
				<tr id="<? echo getByTagName($score->tags, 'cdmodelo'); ?>">
					<td>
						<span><? echo getByTagName($score->tags,'dsmodelo_score'); ?></span>
						<? echo getByTagName($score->tags,'dsmodelo_score'); ?>
					</td>
					<td id="dtbase">
						<span><? echo getByTagName($score->tags,'dtbase'); ?></span>
						<? echo getByTagName($score->tags,'dtbase'); ?>
					</td>
					<td>
						<span><? echo getByTagName($score->tags,'dsclasse_score'); ?></span>
						<? echo getByTagName($score->tags,'dsclasse_score'); ?>
					</td>
					<td>
						<span><? echo getByTagName($score->tags,'nrscore_alinhado'); ?></span>
						<? echo getByTagName($score->tags,'nrscore_alinhado'); ?>
					</td>
					<td>
						<span><? echo getByTagName($score->tags,'dsexclusao_principal'); ?></span>
						<? echo getByTagName($score->tags,'dsexclusao_principal'); ?>
					</td>
					<td>
						<span><? echo getByTagName($score->tags,'dssituacao_score'); ?></span>
						<? echo getByTagName($score->tags,'dssituacao_score'); ?>
					</td>
				</tr>
				<?
			}
		}
		?>
		</tbody>
	</table>
</div>

<div id="divBotoes" style="margin-top: 5px; margin-bottom: 10px; text-align: center;">
	<a href="#" class="botao" id="btExclusao"><? echo utf8ToHtml('Exclusões'); ?></a>
	<a href="#" class="botao" id="btVoltar" onClick="encerraRotina(true); return false;">Voltar</a>																				
</div>

<script type="text/javascript">
// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
$("#divConteudoOpcao").css("height","150px");

controlaLayout();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>