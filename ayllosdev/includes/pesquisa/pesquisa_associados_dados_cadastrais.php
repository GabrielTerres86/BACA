<?
/*!
 * FONTE        : pesquisa_associados_dados_cadastrais.php
 * CRIAÇÃO      : Luiz Otávio Olinger Momm - AMCOM
 * DATA CRIAÇÃO : 30/01/2019
 * OBJETIVO     : Formulário para pesquisar associados que pode ser chamado de diferentes pontos do sistema pelo nome ou CPFCGC
 
 ALTERACOES     :
*/
?>

<div id="divPesquisaAssociadoDadosCadastrais" class="divPesquisa">
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">
				<table border="0" cellpadding="0" cellspacing="0" width="500">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" style="text-transform: uppercase;" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><span class="tituloJanelaPesquisa">PESQUISA DE ASSOCIADOS POR NOME OU CPF/CNPJ</span></td>
									<td width="12" id="tdTitTela" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a class="fecharPesquisa"><img src="<? echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
													<form name="frmPesquisaAssociadoDadosCadastrais" id="frmPesquisaAssociadoDadosCadastrais" class="formulario">
														<label for="nmdbusca">Nome associado:</label>
														<input type="text" name="nmdbusca" id="nmdbusca" class="campo alphanum" />
														<label for="nrcpfcgc">CPF/CNPJ:&nbsp;</label>
														<input type="text" name="nrcpfcgc" id="nrcpfcgc" class="campo inteiro" maxlength="14" style="width:109;"/>

														<label for="botao"></label>
														<input type="image" src="<? echo $UrlImagens; ?>botoes/iniciar_pesquisa.gif" onClick="pesquisaAssociadoDadosCadastrais();return false;">
														
														<br clear="both" />
													</form>

													<!-- CABEÇALHO DO RESULTADO DA CONSULTA -->
													<div id="divCabecalhoPesquisaAssociadoDadosCadastrais" class="divCabecalhoPesquisa">
														<table>
															<thead>
																<tr>
																	<td style="width:110px;font-size:11px;">CPF/CNPJ</td>
																	<td style="width:300px;font-size:11px;">Associado</td>
																</tr>
															</thead>
														</table>
													</div>

													<!-- DIV DO RESULTADO DA CONSULTA -->
													<div id="divResultadoPesquisaAssociadoDadosCadastrais" class="divResultadoPesquisa">
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
</div>

<script type="text/javascript" charset="utf-8">
$(document).ready(function() {
	$('#divPesquisaAssociadoDadosCadastrais').css('z-index', 110);

	$('label[for="nmdbusca"]', '#frmPesquisaAssociadoDadosCadastrais').css('width', '100px');
	$('#nmdbusca', '#frmPesquisaAssociadoDadosCadastrais').css({'width': '140'});

	$('label[for="nrcpfcgc"]', '#frmPesquisaAssociadoDadosCadastrais').css('width', '80px');
	$('#nrcpfcgc', '#frmPesquisaAssociadoDadosCadastrais').css({'width': '120'});

	$('label[for="botao"]', '#frmPesquisaAssociadoDadosCadastrais').css('width', '100px');
});
</script>