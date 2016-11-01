<?php
/*!
 * FONTE        : consulta_rfb.php
 * CRIAÇÃO      : Gabriel (RKAM)
 * DATA CRIAÇÃO : 04/09/2015 
 * OBJETIVO     : Mostra rotina de CONSULTA A RECEITA FEDERAL
 *
 * ALTERACOES   :
 */
?>
<?
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../config.php");
	require_once("../funcoes.php");	
	require_once("../controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	$inpessoa = $_POST['inpessoa'];
	$nrcpfcgc = $_POST['nrcpfcgc'];
	$dtnasctl = $_POST['dtnasctl'];
	
?>
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">		
				<table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>	 
									<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"> CONSULTA RFB </td>
									<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina(divRotina);return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
												<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick="" class="txtNormalBold">Principal</a></td>																																						
												<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
												<td width="1"></td>
											</tr>
										</table>
									</td>
								</tr>
								<tr>
									<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
										<div id="divConteudoOpcao">
											<form class="formulario" id="frmRfb" action="#">
											<fieldset>	
											
												<br/>
												<img id="imgCaptcha" name="imgCaptcha" src="" >
												<br/><br/>
												<label for="dscaptch" style="margin-left:100px;">Digite os caracteres acima:</label>
												<input id="dscaptch" name="dscaptch" type="text" maxlength="6" class="campo" style="text-transform: uppercase;" />
												<div id="divBotoes" style="margin-bottom:10px">
													<a href="#" class="botao" id="btnVoltar" onclick="fechaRotina(divRotina); return false;">Voltar</a>
										     		<a href="#" class="botao" id="btConcluir" onclick="efetuarConsulta(false); return false;">Prosseguir</a>														
												</div>												
											</fieldset>
											</form>
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
<?
?>
<script type="text/javascript">

	inpessoa = "<? echo $inpessoa; ?>";
	nrcpfcgc = "<? echo $nrcpfcgc; ?>";
	dtnasctl = "<? echo $dtnasctl; ?>";
	dtmvtolt = "<? echo $glbvars["dtmvtolt"]; ?>";
		
	exibeRotina(divRotina);
	
	hideMsgAguardo();
	
	blockBackground(divRotina);
		
	estadoInicialRfb();

	document.getElementById('btConcluir').style.visibility="hidden";	
	carrregarCaptcha(true);


</script>