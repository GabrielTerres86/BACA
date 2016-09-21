<?
/*!
 * FONTE        : aplicacao.php
 * CRIAÇÃO      : Rogérius Militão - DB1 Informatica
 * DATA CRIAÇÃO : 23/08/2011 
 * OBJETIVO     : Tela da tabela de aplicações
 * ALTERAÇÕES   : 30/11/2012 - Alterado botões do tipo tag <input> para
 *					           tag <a> novo layout (Daniel).
 */	 
?>

<?
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	
	$cddopcao = $_POST['cddopcao'];
	$dsdopcao = $_POST['cddopcao'] == 'A' ? 'Alterar' : 'Todas';
	$nrsequen = $_POST['nrsequen'];
	$descapli = $_POST['descapli'];
	$nraplica = $_POST['nraplica'];
	$dtmvtolt = $_POST['dtmvtolt'];
	$tpemiext = $_POST['cddopcao'] == 'A' ? $_POST['tpemiext'] : '0';
	$dsemiext = $_POST['dsemiext'];
	
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('APLICAÇÃO') ?></td>
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
									<form id="frmAplicacao" name="frmAplicacao" class="formulario">
									
									<fieldset>
									
									<legend><? echo $dsdopcao ?></legend>
									
									<label for="nrsequen"><? echo utf8ToHtml('Sequência'); ?></label>
									<input id="nrsequen" name="nrsequen" type="text" value="<? echo $nrsequen ?>">

									<label for="descapli"><? echo utf8ToHtml('Aplicação'); ?></label>
									<input id="descapli" name="descapli" type="text" value="<? echo $descapli ?>">

									<label for="nraplica"><? echo utf8ToHtml('Número'); ?></label>
									<input id="nraplica" name="nraplica" type="text" value="<? echo mascara($nraplica,'#.###.###');  ?>">

									<label for="dtmvtolt"><? echo utf8ToHtml('Data Aplicação'); ?></label>
									<input id="dtmvtolt" name="dtmvtolt" type="text" value="<? echo $dtmvtolt ?>">

									<label for="tpemiext"><? echo utf8ToHtml('Impressão Extrato'); ?></label>
									<select id="tpemiext" name="tpemiext">
									<option value="0" <? echo $tpemiext == '0' ? 'selected' : '' ?> >---</option>
									<option value="1" <? echo $tpemiext == '1' ? 'selected' : '' ?> >1 - Individual </option>
									<option value="2" <? echo $tpemiext == '2' ? 'selected' : '' ?> >2 - Todos Juntos </option>
									<option value="3" <? echo $tpemiext == '3' ? 'selected' : '' ?> >3 - Nao Imprimir</option>
									</select>
									
									
									</form>
									</fieldset>
									
									<div id="divBotoes" style="margin-bottom:10px">
										<a href="#" class="botao" id="btVoltar" onclick="fechaRotina( $('#divRotina')); return false;">Voltar</a>
										<a href="#" class="botao" id="btSalvar" onclick="manterRotina( 'V', $('#tpemiext','#frmAplicacao').val() ); return false;">Continuar</a>
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