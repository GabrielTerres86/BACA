<?
/*!
 * FONTE        : form_tipo_proprietario.php
 * CRIAÇÃO      : Mateus Zimmermann - Mouts
 * DATA CRIAÇÃO : 02/05/2018
 * OBJETIVO     : Tela para inclusão/alteração do tipo proprietario
 * ALTERAÇÕES   : 
 */	 
?>

<?
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	
	$cddopcao 		= isset($_POST['cddopcao'])       ? $_POST['cddopcao']       : '';
	$dsdopcao 		= $_POST['cddopcao'] == 'A'       ? 'Alterar'                : 'Incluir';
	$cdtipo_dominio = isset($_POST['cdtipo_dominio']) ? $_POST['cdtipo_dominio'] : '';
	$dstipo_dominio = isset($_POST['dstipo_dominio']) ? $_POST['dstipo_dominio'] : '';
	$insituacao     = isset($_POST['insituacao'])     ? $_POST['insituacao']     : '';
	
?>

<table cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('Tipo Proprietário'); ?></td>
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
									<div id="divConteudo">
									<form id="frmTipoProprietario" name="frmTipoProprietario" class="formulario">
									
										<fieldset>
										
										<legend><? echo $dsdopcao ?></legend>
										
										<label for="cdtipo_dominio"><? echo utf8ToHtml('Código:'); ?></label>
										<input id="cdtipo_dominio" name="cdtipo_dominio" type="text" value="<? echo $cdtipo_dominio ?>">

										<label for="insituacao"><? echo utf8ToHtml('Situação'); ?></label>
										<select id="insituacao" name="insituacao">
											<option value="A" <? echo $insituacao == 'A' ? 'selected' : '' ?> >Ativo</option>
											<option value="I" <? echo $insituacao == 'I' ? 'selected' : '' ?> >Inativo</option>
										</select>

										<label for="dstipo_dominio"><? echo utf8ToHtml('Descrição:'); ?></label>
										<input id="dstipo_dominio" name="dstipo_dominio" type="text" value="<? echo $dstipo_dominio ?>">
									
									</form>
									</fieldset>
									
									<div id="divBotoes" style="margin-bottom:10px">
										<a href="#" class="botao" id="btVoltar" onclick="fechaRotina( $('#divRotina')); return false;">Voltar</a>
										<? if( $cddopcao == 'A'){ ?>
											<a href="#" class="botao" id="btSalvar" onclick="manterRotina('AP'); return false;">Concluir</a>
										<? } else { ?>
											<a href="#" class="botao" id="btSalvar" onclick="manterRotina('IP'); return false;">Concluir</a>
										<? } ?>	
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