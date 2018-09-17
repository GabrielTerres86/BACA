<?
/*!
 * FONTE        : form_prmdpv.php
 * CRIAÇÃO      : Lucas Moreira
 * DATA CRIAÇÃO : 04/09/2015
 * OBJETIVO     : Formulario para tela PRMDPV
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
	session_cache_limiter("private");
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");


	/*if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], "C")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();
	}*/

	$dsiduser = session_id();

	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';


	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "PRMDPV", "BUSCA_CUSTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error', $msg, 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)', false);
	}
?>

<div id="divPrmdpv" name="divPrmdpv">
	<form id="frmCustoBilhetePorExercicio" name="frmCustoBilhetePorExercicio" class="formulario" onSubmit="return false;">
		<fieldset>
			<legend>Custo Bilhete por Exercício</legend>
				<div id="divCusto" class="divRegistros">
					<table>
						<thead>
							<tr>
								<th>Exercício</th>
								<th>Integral</th>
								<th>Parcelado</th>
							</tr>
						</thead>
						<tbody>
							<? foreach($xmlObjDados->roottag->tags as $registro) {?>
								<tr>
									<td>
										<? echo stringTabela(getByTagName($registro->tags,'exercicio'),10,'maiuscula') ?>
										<input type="hidden" id="hdExercicio" name="hdExercicio" value="<? echo getByTagName($registro->tags,'exercicio') ?>" />
										<input type="hidden" id="hdIntegral" name="hdIntegral" value="<? echo getByTagName($registro->tags,'integral') ?>" />
										<input type="hidden" id="hdParcelado" name="hdParcelado" value="<? echo getByTagName($registro->tags,'parcelado') ?>" />
									</td>
									<td><? echo formataMoeda(stringTabela(getByTagName($registro->tags,'integral'),10,'maiuscula'),2) ?></td>
									<td><? echo formataMoeda(stringTabela(getByTagName($registro->tags,'parcelado'),30,'maiuscula'),2) ?></td>
								</tr>
							<? } ?>
						</tbody>
					</table>
				</div>
		</fieldset>
		
		<div id="divBotoes" style="margin-top:5px; margin-bottom :10px;">
			<a href="#" class="botao" id="btVoltar"  onclick="controlaOperacao('');">Voltar</a>
			<a href="#" class="botao" id="btIncluir" onClick="controlaOperacao('IC');">Incluir</a>
			<a href="#" class="botao" id="btAlterar" onclick="controlaOperacao('AC');">Alterar</a>
			<a href="#" class="botao" id="btExcluir" onClick="controlaOperacao('EC');">Excluir</a>
		</div>
	</form>
</div>