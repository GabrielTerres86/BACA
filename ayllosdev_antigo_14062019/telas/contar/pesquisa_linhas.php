<? 
/*!
 * FONTE        : pesquisa_linhas.php
 * CRIACAO      : Andre Clemer - Supero
 * DATA CRIACAO : 01/11/2018
 * OBJETIVO     : Formulario para pesquisar linhas de credito
 *
 * ALTERACOES   : 
 *
 */	
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">
			<table border="0" cellpadding="0" cellspacing="0" width="500">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Pesquisa de Linhas de Cr&eacute;dito</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
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
													<form name="frmPesquisaPopup" id="frmPesquisaPopup" class="formulario">
														<label for="cdlcremp" style="width:167px">C&oacute;digo:</label>
														<input type="text" name="cdlcremp" id="cdlcremp" class="campo numerico" autocomplete="off" />
														<a href="#" class="botao" onClick="popup.onClick_Pesquisar('L');return false;">Iniciar Pesquisa</a>
														<br clear="both" />
													</form>

													<!-- CABECALHO DO RESULTADO DA CONSULTA -->
													<div id="divCabecalhoPesquisaPopup" class="divCabecalhoPesquisa">
														<table>
															<thead>
																<tr>
																	<td style="width:135px;font-size:11px;">C&oacute;digo</td>  
																	<td style="width:335px;font-size:11px;">Descri&ccedil;&atilde;o</td>
																</tr>
															</thead>
														</table>
													</div>

													<!-- DIV DO RESULTADO DA CONSULTA -->
													<div id="divResultadoPesquisaPopup" class="divResultadoPesquisa"></div>
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