<?php
/*!
 * FONTE        : aprova_reprova_pagto.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Mostrar tela de cadastro e alteracao - ESTFOL
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

session_start();
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
isPostMethod();

$cdeftpag   	= (isset($_POST['cdeftpag'])) ? $_POST['cdeftpag'] : '' ;

?>
<table id="telaInicial" id="telaInicial" cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">
			<table cellpadding="0" cellspacing="0" border="0" width="420">
			   <tr>
				    <td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0" >
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? if($cdeftpag==3){echo "Folha de Pagamento - Estouro reprovado"; }else if($cdeftpag==4){echo "Folha de Pagamento - Estouro aprovado";} ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="encerraRotina(true);return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>
					</td>
			   </tr>
			   <tr>
					<td class="tdConteudoTela" align="center">
					  <table width="480" border="0" cellspacing="0" cellpadding="0">
						<tr>
							<td>
								<table border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
									<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold" onClick="acessaOpcaoAba();return false;">Principal</a></td>
									<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
									<td width="1"></td>
								</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
								<div id="divConteudoOpcao">
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
	acessaOpcaoAba();
</script>