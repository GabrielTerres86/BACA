<? 
/*!
 * FONTE        : pesquisa_convenios.php
 * CRIACAO      : Andre Clemer - Supero
 * DATA CRIACAO : 31/10/2018
 * OBJETIVO     : Formulario para pesquisar convenios
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Pesquisa de Conv&ecirc;nios</td>
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
														<label for="nrconven" style="width:155px">C&oacute;digo:</label>
														<input type="text" name="nrconven" id="nrconven" class="campo numerico" autocomplete="off" style="width:160px">
														<br clear="both" />
														<label for="flgativo" style="width:155px">Situa&ccedil;&atilde;o:</label>
														<select name="flgativo" id="flgativo" class="campo" style="width:160px">
															<option value="">Ambos</option>
															<option value="1">Ativos</option>
															<option value="0">Inativos</option>
														</select>
														<a href="#" class="botao" onClick="popup.onClick_Pesquisar('C');return false;">Iniciar Pesquisa</a>
													</form>

													<!-- CABECALHO DO RESULTADO DA CONSULTA -->
													<div id="divCabecalhoPesquisaPopup" class="divCabecalhoPesquisa">
														<table>
															<thead>
																<tr>
																	<td style="width:135px;font-size:11px;">C&oacute;digo</td>  
																	<td style="width:335px;font-size:11px;">Origem</td>
																	<td style="width:235px;font-size:11px;">Status</td>
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