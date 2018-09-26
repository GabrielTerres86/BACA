<?
/*!
 * FONTE        : comercial_pg.php
 * CRIAÇÃO      : Gabriel (RKAM)
 * DATA CRIAÇÃO : 01/09/2015 
 * OBJETIVO     : Mostra rotina de Comercial PF da tela de CONTAS
 *
 * ALTERACOES   : 
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

	$opcaoTela = ( isset($opcoesTela) ) ? $opcoesTela[0] : '';

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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">COMERCIAL</td>
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
										<tr style="height:22px;">
											<!-- Comercial -->
											<td width="1px"></td>
											<td align="center" style="background-color: #C6C8CA; border-radius: 3px;" 
												id="imgAbaCen0"><a href="#" id="linkAba0" 
												onClick=<? echo "acessaOpcaoAbaDados(3,0,'".$opcaoTela."');"; ?> 
												class="txtNormalBold">&nbsp; Comercial &nbsp;</a></td>
											<td width="1px"></td>
											<!-- PPE -->
											<td align="center" style="background-color: #C6C8CA; border-radius: 3px;" id="imgAbaCen2">
												<a href="#" 
												   id="linkAba2" 
												   onClick="acessaOpcaoAbaDados(3,2,'<?php echo ($flgcadas == 'M')? 'A' : $opcaoTela; ?>')"
												   class="txtNormalBold">&nbsp; PEP &nbsp;</a>
											</td>
											<td width="1px"></td>
											<!-- Bens -->
											<td align="center" style="background-color: #C6C8CA; border-radius: 3px;" 
												id="imgAbaCen1"><a href="#" id="linkAba1" 
												onClick=<? echo "acessaOpcaoAbaDados(3,1,'".$opcaoTela."');"; ?> 
												class="txtNormalBold">&nbsp; Bens &nbsp; </a></td>
											<td width="1px"></td>	
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
	var qtOpcoesTela = "<? echo ( isset($qtOpcoesTela) ) ? $qtOpcoesTela : 0; ?>";
	var flgcadas     = "<? echo $flgcadas;     ?>";
	
	exibeRotina(divRotina);

	acessaOpcaoAbaDados(3,0,"<? echo $opcaoTela; ?>");
</script>