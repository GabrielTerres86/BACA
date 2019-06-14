<?php
	/*!
	* FONTE        : form_responde_contestacao.php
	* CRIAÇÃO      : Andrey Formigari
	* DATA CRIAÇÃO : Janeiro/2019
	* OBJETIVO     : Mostrar rotina de responder contestação.
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);
	}
	
	$nriniseq = ((isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1);
	$nrregist = ((isset($_POST['nrregist'])) ? $_POST['nrregist'] : 20);
	$nrdocumento = ((isset($_POST['nrdocumento'])) ? $_POST['nrdocumento'] : '');
	$dsempresa = ((isset($_POST['dsempresa'])) ? $_POST['dsempresa'] : '');
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "	<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "	<nrregist>".$nrregist."</nrregist>";
	$xml .= "	<nrdocumento>".$nrdocumento."</nrdocumento>";
	$xml .= "	<dsempresa>".$dsempresa."</dsempresa>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "CADDES", "PESQUISA_DESENVOLVEDOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);

	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','', false);
	}

	$desenvolvedores = $xmlObject->roottag->tags[0]->tags;
	$qtregist = $xmlObject->roottag->tags[0]->attributes['QTREGIST'];
	
	//print_r($xmlObject->roottag->tags[0]);
?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="500">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" style="text-transform: uppercase;" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><span class="tituloJanelaPesquisa">PESQUISA DE DESENVOLVEDORES</span></td>
								<td width="12" id="tdTitTela" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a class="fecharPesquisa" onclick="fechaRotina($('#divUsoGenerico'));"><img src="<? echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<? echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr> 																						
				<tr>
					<td class="tdConteudoTela" align="center">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<table width="100%" border="0" cellpadding="0" cellspacing="0">
										<tr>
											<td align="center">												

												<!-- INICIO DO FORMULARIO -->
												<form name="frmPesquisaDesenvolvedor" id="frmPesquisaDesenvolvedor" class="formulario">														
													
													<label for="dsempresa" style="width: 110px;">Empresa:</label>
													<input type="text" name="dsempresa" id="dsempresa" class="campo" style="width:220px;" value="<?=$dsempresa?>" />
													
													<br clear="both" />
													
													<label for="nrdocumento" style="width: 110px;">CPF/CNPJ:</label>
													<input type="text" name="nrdocumento" id="nrdocumento" class="campo inteiro" maxlength="14" style="width:160px;" value="<?=$nrdocumento?>" />
													
													<br clear="both" />
													
													<label for="botao" style="width: 110px;">&nbsp;</label>
													<input type="image" src="<? echo $UrlImagens; ?>botoes/iniciar_pesquisa.gif" onClick="pesquisaDesenvolvedor(1, 20);return false;">
													
													<br clear="both" />
												</form>																								

												<!-- CABEÇALHO DO RESULTADO DA CONSULTA -->
												<div id="divCabecalhoPesquisaAssociado" class="divCabecalhoPesquisa">
													<table>
														<thead>
															<tr>
																<td style="width:30px;font-size:11px;">Codigo</td>  
																<td style="width:120px;font-size:11px;">CPF/CNPJ</td>
																<td style="width:200px;font-size:11px;">Empresa</td>
															</tr>
														</thead>
													</table>
												</div>

												<!-- DIV DO RESULTADO DA CONSULTA -->
												<div id="divResultadoPesquisaDesenvolvedor" class="divResultadoPesquisa" style="overflow-x: auto;">
													<table width="100%">
														<?php
															foreach ($desenvolvedores as $desenvolvedor) {
																
																$cddesenvolvedor = getByTagName($desenvolvedor->tags,'cddesenvolvedor');
																$dsnome  = getByTagName($desenvolvedor->tags,'dsnome');
																$nrdocumento  = getByTagName($desenvolvedor->tags,'nrdocumento');
																$inpessoa  = getByTagName($desenvolvedor->tags,'inpessoa');
																
																//$nrdocumento = ((!$nrdocumento) ? '' : (($inpessoa == 1) ? formatar($nrdocumento, 'cpf') : formatar($nrdocumento, 'cnpj')));
																
																echo "<tr style=\"cursor: pointer;\" onclick=\"selecionaPesquisaDesenvolvedor($cddesenvolvedor);return false;\">";
																
																echo "<td style=\"width: 43px;padding: 1px 5px;\">$cddesenvolvedor</td>";
																echo "<td style=\"width: 130px;padding: 1px 5px;\">$nrdocumento</td>";
																echo "<td style=\"width: 200px;padding: 1px 5px;\">$dsnome</td>";

																echo "</tr>";
															}
														?>
													</table>
												</div>
												
												<div id="divPesquisaRodape" class="divPesquisaRodape">
													<table>	
														<tr>
															<td>
																<?
																	
																	//
																	if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
																	
																	// Se a paginação não está na primeira, exibe botão voltar
																	if ($nriniseq > 1) { 
																		?> <a class='paginacaoAnt'><<< Anterior</a> <? 
																	} else {
																		?> &nbsp; <?
																	}
																?>
															</td>
															<td>
																<?
																	if (isset($nriniseq)) { 
																		?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
																	}
																?>
															</td>
															<td>
																<?
																	// Se a paginação não está na &uacute;ltima página, exibe botão proximo
																	if ($qtregist > ($nriniseq + $nrregist - 1)) {
																		?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
																	} else {
																		?> &nbsp; <?
																	}
																?>			
															</td>
														</tr>
													</table>
												</div>

											</td>
										</tr>
									</table>																												
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<script type="text/javascript">
	// Esconde mensagem de aguardo
	hideMsgAguardo();
	
	layoutPadrao();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divUsoGenerico").css("z-index")));
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		pesquisaDesenvolvedor(<? echo ($nriniseq - $nrregist) . ',' . $nrregist; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		pesquisaDesenvolvedor(<? echo ($nriniseq + $nrregist) . ',' . $nrregist; ?>);
	});	
	
	$('#divPesquisaRodape').formataRodapePesquisa();
	
	$("#divResultadoPesquisaDesenvolvedor table tr").hover(
	   function() {
		$(this).css({'background': '#f7d3ce'});
	}, function(){
		$(this).css({'background': ''});
	});
	
</script>