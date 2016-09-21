<?
/*!
 * FONTE        : form_extrato_data.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 30/03/2011 
 * OBJETIVO     : Tela com Data Inicial para Extrato
 * --------------
 * ALTERAÇÕES   :
 * -------------- 
 * 001: [29/08/2011] Marcelo L. Pereira (GATI): alterando listagem do extrato
 * 002: [04/07/2012] Gabriel: Nao mostrar esta tela no emprestimo tipo 1
 * 003: [30/11/2012] David (CECRED) : Validar session
 * 004: [24/05/2013] Lucas R. (CECRED): Incluir camada nas includes "../"
 */
  
?>
 
<?

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");
	isPostMethod();	
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';	
	
?>

<table id="tdNP"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="300">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('EXTRATO') ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'),divRotina);"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 15px 0px 14px 20px;">
									<div id="divConteudoOpcao">
										<form class="formulario" id="frmDataInicial">
											<label for="dtpesqui"><? echo utf8ToHtml('Entre com a Data Inicial:') ?></label>
											<input name="dtpesqui" id="dtpesqui" class="data campo" style="width: 68px;" type="text" value="" />
											<input type="image" name="btnExtrato" id="btnExtrato" onclick="controlaOperacao('<? echo $operacao ?>'); return false;" src="<?php echo $UrlImagens; ?>/botoes/ok.gif">
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
<script type="text/javascript">
$("#dtpesqui","#frmDataInicial").unbind("keypress").bind("keypress",function(e) {	
	if ( e.keyCode == 13 ) {		
		$("#btnExtrato","#frmDataInicial").trigger("click");
		return false;
	}
	
	return true;
});
</script>