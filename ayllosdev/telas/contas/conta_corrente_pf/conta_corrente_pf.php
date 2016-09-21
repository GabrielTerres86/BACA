<?php
/*!
 * FONTE        : conta_corrente_pf.php
 * CRIAÇÃO      : Gabriel (RKAM)
 * DATA CRIAÇÃO : 08/09/2015 
 * OBJETIVO     : Mostra rotina de Conta Corrente PF da tela de CONTAS
 *
 * ALTERACOES   : 14/07/2016 - Correcao no uso do array de opcoestela indefinido. SD 479874. Carlos R.
 */	 
	session_start();	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");	
	isPostMethod();	
		
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) exibirErro('error','Parâmetros incorretos.','Alerta - Ayllos','');
	
	$flgcadas = $_POST["flgcadas"] == "" ? '' : $_POST["flgcadas"];

	$vr_opcao = ( isset($opcoesTela[0]) ) ? $opcoesTela[0] : '';
	$qtOpcoesTela = ( isset($qtOpcoesTela) ) ? $qtOpcoesTela : 0;
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">CONTA CORRENTE</td>
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
											<!-- Conta corrente -->
											<td width="1px"></td>
											<td align="center" style="background-color: #C6C8CA; border-radius: 5px;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick=<?php echo "acessaOpcaoAbaDados(4,0,'".$vr_opcao."');"; ?> class="txtNormalBold">&nbsp; Conta Corrente &nbsp;</a></td>
											<td width="1px"></td>
											<!-- Cliente Financeiro -->
											<td align="center" style="background-color: #C6C8CA; border-radius: 5px;" id="imgAbaCen1"><a href="#" id="linkAba1" onClick=<?php echo "acessaOpcaoAbaDados(4,1,'".$vr_opcao."');"; ?> class="txtNormalBold">&nbsp; Cliente Financeiro &nbsp;</a></td>
											<td width="1px"></td>
											<!-- Informativos -->
											<td align="center" style="background-color: #C6C8CA; border-radius: 5px;" id="imgAbaCen2"><a href="#" id="linkAba2" onClick=<?php echo "acessaOpcaoAbaDados(4,2,'".$vr_opcao."');"; ?> class="txtNormalBold">&nbsp; Informativos &nbsp;</a></td>
											<td width="1px"></td>
											<!-- Inf. Adicionais -->
											<td align="center" style="background-color: #C6C8CA; border-radius: 5px;" id="imgAbaCen3"><a href="#" id="linkAba3" onClick=<?php echo "acessaOpcaoAbaDados(4,3,'".$vr_opcao."');"; ?> class="txtNormalBold">&nbsp; Informa&ccedil;&otilde;es Adicionais &nbsp;</a></td>
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
	var qtOpcoesTela = "<?php echo $qtOpcoesTela; ?>";
	var flgcadas     = "<?php echo $flgcadas; ?>";
	
	exibeRotina(divRotina);

	acessaOpcaoAbaDados(4,0,"<?php echo $vr_opcao; ?>");
		
</script>
