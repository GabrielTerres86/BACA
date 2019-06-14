<?php
/*!
 * FONTE        : form_aprovadores.php
 * CRIAÇÃO      : André Clemer
 * DATA CRIAÇÃO : 20/07/2018
 * OBJETIVO     : Formulário de aprovadores
 */


session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

isPostMethod();

$cdalcada = (isset($_POST['cdalcada'])) ? $_POST['cdalcada'] : '';
$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : $glbvars['cdcooper'];
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
$flgregra = (isset($_POST['flgregra'])) ? (int) $_POST['flgregra'] : false;
?>

<script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">
			<table border="0" cellpadding="0" cellspacing="0" width="585">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Aprovadores</td>
								
								<?php if ($flgregra) { ?>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotinaValidaAlcada($('#divRotina'), '<?php echo $cdalcada; ?>'); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<?php } else { ?>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<?php } ?>
								
								
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="tdConteudoTela" align="center">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px 2px 8px;">
									<div id="divConteudoOpcao">
										<?php if ($cddopcao == 'A') { ?>
                                        <form id="frmAprovadores" name="frmAprovadores" class="formulario" style="display:block;">

											<label style="width:260px" for="nmdbusca">Nome a pesquisar:</label>
                                            <input style="margin-left:15px" type="text" id="nmdbusca" name="nmdbusca" class="campo alphanum" autocomplete="off" />
                                            <input type="image" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" onclick="PopupAprovadores.onClick_Pesquisar($('#nmdbusca','#frmAprovadores').val(),'<?php echo $cdalcada; ?>');return false;">

                                            <br style="clear:both" />

                                            <hr style="background-color:#666; height:1px;" />
                                        </form>
										<?php } ?>

										<!-- html será renderizado abaixo -->
										<div id="divGrid">
											<? include('grid_aprovadores.php'); ?>
										</div>

										<div id="divBotoes" style="margin-bottom: 10px;">
											<?php if ($flgregra) { ?>
											<a href="#" class="botao" id="btVoltar" onClick="fechaRotinaValidaAlcada($('#divRotina'), '<?php echo $cdalcada; ?>'); return false;">Voltar</a>
											<?php } else { ?>
											<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); return false;">Voltar</a>
											<?php } ?>
										</div>
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
