<?php
/*!
 * FONTE        : form_data.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 11/11/2011
 * OBJETIVO     : Formulario data
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Implementação do novo layout, botões (David Kruger).
 * --------------
 */ 
?>


<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>


<?php
	$operacao = $_POST['operacao'];
?>

<table cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0"  >
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">&nbsp;</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina( $('#divUsoGenerico') ); $('#divUsoGenerico').html(''); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divData">

										<form id="frmData" name="frmData" class="formulario" onsubmit="return false;">

											<fieldset>
												<legend></legend>
												
												<label for="dtinicio"><? echo utf8ToHtml('Início:') ?></label>
												<input name="dtinicio" id="dtinicio" type="text" value="" />
												<label for="dtdfinal">Fim:</label>
												<input name="dtdfinal" id="dtdfinal" type="text" value="" />
												<label for="cdsitenv"><? echo utf8ToHtml('Situação:') ?></label>
												<select name="cdsitenv" id="cdsitenv">
												<option value="9">Todos</option>
												<option value="0">Nao Liberado</option>
												<option value="1">Liberado</option>
												<option value="2">Descartado</option>
												<option value="3">Recolhido</option>
												</select>
												
												<label for="dtlimite">Data:</label>
												<input name="dtlimite" id="dtlimite" type="text" value="<?php echo $operacao == 'log' ? $glbvars['dtmvtoan'] : $glbvars['dtmvtolt'] ?>" />
												
											</fieldset>	

										</form>

										<div id="divBotoes">
											<a href="#" class="botao" id="btVoltar" onClick="fechaRotina( $('#divUsoGenerico') ); return false;">Voltar</a>
											<a href="#" class="botao" id="btSalvar" onClick="<?php echo $operacao == 'log' ? "Gera_Log();" : "mostraOpcao('".$operacao."');" ?> return false;">Continuar</a>
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

<script> 
	
	$(document).ready(function(){
		highlightObjFocus($('#frmData'));
	});

</script>