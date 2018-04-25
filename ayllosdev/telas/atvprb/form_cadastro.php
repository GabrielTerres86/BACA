<?php
/*
 * FONTE        : form_cadastro.php
 * CRIAÇÃO      : Marcel Kohls (AMCom)
 * DATA CRIAÇÃO : 15/03/2018
 * OBJETIVO     : formulário para cadastro de ativos problematicos
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

// $nrdconta		= (isset($_POST['nrdconta'])) ? $_POST['nrdconta']  : '0';
// $nrctrato		= (isset($_POST['nrctrato'])) ? $_POST['nrctrato']  : '0';
$nrdconta		= (isset($_POST['nrdconta'])) ? $_POST['nrdconta']  : '';
$nrctremp		= (isset($_POST['nrctremp'])) ? $_POST['nrctremp']  : '';
$cdmotivo		= (isset($_POST['cdmotivo'])) ? $_POST['cdmotivo']  : '';
$dsobserv		= (isset($_POST['dsobserv'])) ? $_POST['dsobserv']  : '';

$tituloForm = (empty($cdmotivo) ?  "Incluir" : "Alterar") . " ativo problem&aacute;tico";
$acaoSalvar = (empty($cdmotivo) ?  "Inclui_Dados" : "Altera_Dados");
?>
<table id="tdImp"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">
			<table border="0" cellpadding="0" cellspacing="0" width="400">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?= $tituloForm ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'));"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
										<form action="" method="post" name="frmCad" id="frmCad" class="formulario" >
											<fieldset>
												<label for="nrdconta" class="rotulo">Conta:</label>
												<input name="nrdconta" id="nrdconta" type="text" class="campo" value="<?php echo formataContaDV($nrdconta) ?>" />
												<a id="btnLupaAssociado"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

												<label for="nrctremp" class="rotulo">Contrato:</label>
												<input name="nrctremp" id="nrctremp" type="text"  class="campo" value="<?= $nrctremp ?>" />

												<label for="flmotivo">Motivo:</label>
												<select id="flmotivo" name="flmotivo">
													<?php
														$tipoLista = "M"; // indica que devem ser listados apenas os motivos manuais
														include("lista_motivos.php");
													?>
												</select>

												<label for="dsobserv" class="rotulo">Observa&ccedil;&atilde;o:</label>
												<input name="dsobserv" id="dsobserv" type="text"  class="campo" value="<?= $dsobserv ?>" maxlength="100"/>
											</fieldset>
										</form>
                    <div id="divBotoes">
                        <a href="#" class="botao" id="btCadVoltar" onClick="fechaRotina($('#divUsoGenerico'));">Voltar</a>
												<a href="#" class="botao" id="btCadSalvar" onClick="salvarCadastro('<?= $acaoSalvar ?>')">Salvar</a>
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
<script type="text/javascript">
	formataCadastro('<?= $acaoSalvar ?>');
	$("#flmotivo").val("<?= $cdmotivo ?>");
</script>
