<?php
/*!
 * FONTE        : contatos_pf.php
 * CRIAÇÃO      : Gabriel (RKAM)
 * DATA CRIAÇÃO : 08/09/2015 
 * OBJETIVO     : Mostra rotina de Contatos PF da tela de CONTAS
 *
 * ALTERACOES   :  13/07/2016 - Correcao da forma de recuperacao da variavel $opcoesTela.SD 479874. Carlos R.
 */	 

	session_start();	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");	
	isPostMethod();	
		
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) exibirErro('error','Parâmetros incorretos.','Alerta - Aimaro','');
	
	$flgcadas = $_POST["flgcadas"] == "" ? '' : $_POST["flgcadas"];

	$vr_opcoes = ( isset($opcoesTela[0]) ) ? $opcoesTela[0] : '';

?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">CONTATOS</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a class="fecharRotina"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<!-- Endereco -->
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick=<? echo "acessaOpcaoAbaDados(3,0,'".$vr_opcoes."');"; ?> class="txtNormalBold">Endere&ccedil;o</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
											<!-- Telefones -->
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq1"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen1"><a href="#" id="linkAba1" onClick=<? echo "acessaOpcaoAbaDados(3,1,'".$vr_opcoes."');"; ?> class="txtNormalBold">Telefones</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir1"></td>
											<td width="1"></td>
											<!-- E-mail -->
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq2"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen2"><a href="#" id="linkAba2" onClick=<? echo "acessaOpcaoAbaDados(6,2,'".$vr_opcoes."');"; ?> class="txtNormalBold">E-mail</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir2"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao"></div>
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
	// Declara os flags para as opções da Rotina de Bens
	var qtOpcoesTela = "<?php echo ( isset($qtOpcoesTela) ) ? $qtOpcoesTela : 0; ?>";
	var flgcadas     = "<?php echo $flgcadas; ?>";
	
	exibeRotina(divRotina);

	acessaOpcaoAbaDados(3,0,"<?php echo $vr_opcoes; ?>");	
</script>