<? 
/*!
 * FONTE        : pesquisa_aprovadores.php
 * CRIACAO      : Andre Clemer - Supero
 * DATA CRIACAO : 24/07/2018
 * OBJETIVO     : Formulario para pesquisar aprovadores
 *
 * ALTERACOES   : 
 *
 */	
?>
<div id="divPesquisa" class="divPesquisa">
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">
				<table border="0" cellpadding="0" cellspacing="0" width="500">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><span class="tituloJanelaPesquisa">Pesquisa de Aprovadores</span></td>
									<td width="12" id="tdTitTela" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a class="fecharPesquisa" onclick="fechaRotina($('#divPesquisa'));exibeRotina($('#divRotina'));blockBackground(parseInt($('#divRotina').css('z-index')));return false;"><img src="<? echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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

													<div id="pesquisaContainer">

														<!-- INICIO DO FORMULARIO -->
														<form name="frmPesquisaAprovadores" id="frmPesquisaAprovadores" class="formulario">
															<input type="hidden" name="cdalcada" id="cdalcada" />
															<input type="hidden" name="nriniseq" id="nriniseq" />
															
															<label for="nmdbusca" style="width:167px">Nome a pesquisar:</label>
															<input type="text" name="nmdbusca" id="nmdbusca" class="campo alphanum" autocomplete="off" />
															<input type="image" src="<? echo $UrlImagens; ?>botoes/iniciar_pesquisa.gif" onClick="PopupAprovadores.onClick_doPesquisar($('#nmdbusca').val(),$('#nmdbusca').val());return false;">
															
															<br clear="both" />
														</form>

														<!-- CABECALHO DO RESULTADO DA CONSULTA -->
														<div id="divCabecalhoPesquisaAprovadores" class="divCabecalhoPesquisa">
															<table>
																<thead>
																	<tr>
																		<td style="width:135px;font-size:11px;">C&oacute;digo</td>  
																		<td style="width:335px;font-size:11px;">Nome</td>
																	</tr>
																</thead>
															</table>
														</div>

														<!-- DIV DO RESULTADO DA CONSULTA -->
														<div id="divResultadoPesquisaAprovadores" class="divResultadoPesquisa"></div>

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