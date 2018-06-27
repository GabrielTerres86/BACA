<?
/*!
 * FONTE        : form_compliance.php
 * CRIAÇÃO      : Mateus Zimmermann - Mouts
 * DATA CRIAÇÃO : 02/05/2018
 * OBJETIVO     : Tela para alteração do compliance
 * ALTERAÇÕES   : 
 */	 
?>

<?
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	
	$nrcpfcgc            = isset($_POST['nrcpfcgc'])            ? $_POST['nrcpfcgc']            : '';
	$inreportavel        = isset($_POST['inreportavel'])        ? $_POST['inreportavel']        : '';
	$cdtipo_declarado    = isset($_POST['cdtipo_declarado'])    ? $_POST['cdtipo_declarado']    : '';
	$dstipo_declarado    = isset($_POST['dstipo_declarado'])    ? $_POST['dstipo_declarado']    : '';
	$cdtipo_proprietario = isset($_POST['cdtipo_proprietario']) ? $_POST['cdtipo_proprietario'] : '';
	$dstipo_proprietario = isset($_POST['dstipo_proprietario']) ? $_POST['dstipo_proprietario'] : '';
	$dsjustificativa     = isset($_POST['dsjustificativa'])     ? $_POST['dsjustificativa']     : '';
	
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Compliance</td>
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
									<form id="frmAlterarCompliance" name="frmAlterarCompliance" class="formulario">
									
										<fieldset>
										
										<legend>Alterar</legend>

										<input name="nrcpfcgc" id="nrcpfcgc" type="hidden" value="<? echo $nrcpfcgc ?>"/>
										<input name="inexige_proprietario" id="inexige_proprietario" type="hidden"/>
										
										<label for="inreportavel"><? echo utf8ToHtml('Reportável:'); ?></label>
										<select id="inreportavel" name="inreportavel">
											<option value="S" <? echo $inreportavel == '' ? 'selected' : '' ?> ></option>
											<option value="S" <? echo $inreportavel == 'SIM' ? 'selected' : '' ?> >Sim</option>
											<option value="N" <? echo $inreportavel == 'NAO' ? 'selected' : '' ?> ><? echo utf8ToHtml('Não'); ?></option>
										</select>
										<br style="clear: both">
								        <label for="cdtipo_declarado">Tipo Declarado:</label>
								        <input name="cdtipo_declarado" id="cdtipo_declarado" type="text" class="pesquisa" value="<? echo $cdtipo_declarado ?>"/>
										<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
								        <input name="dstipo_declarado" id="dstipo_declarado" type="text" value="<? echo $dstipo_declarado ?>"/>

								        <label for="cdtipo_proprietario"><? echo utf8ToHtml('Tipo Proprietário:'); ?></label>
								        <input name="cdtipo_proprietario" id="cdtipo_proprietario" type="text" class="pesquisa" value="<? echo $cdtipo_proprietario ?>"/>        
										<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
								        <input name="dstipo_proprietario" id="dstipo_proprietario" type="text" value="<? echo $dstipo_proprietario ?>"/>

										<label for="dsjustificativa"><? echo utf8ToHtml('Justificativa:'); ?></label>
										<textarea id="dsjustificativa" name="dsjustificativa" type="text"><? echo $dsjustificativa ?></textarea>
									
									</form>
									</fieldset>
									
									<div id="divBotoes" style="margin-bottom:10px">
										<a href="#" class="botao" id="btVoltar" onclick="fechaRotina( $('#divRotina')); return false;">Voltar</a>
										<a href="#" class="botao" id="btSalvar" onclick="manterRotina('AC'); return false;">Concluir</a>
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