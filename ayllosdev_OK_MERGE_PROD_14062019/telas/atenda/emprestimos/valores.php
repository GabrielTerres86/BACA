<?
/*!
 * FONTE        : valores.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 15/04/2010 
 * OBJETIVO     : Tela para alteração do valor da proposta de empréstimo.
 * ALTERAÇÕES   : 
 * --------------
 * 000: [20/09/2011] Correções de acentuação - Marcelo L. Pereira (GATI)
 * 001: [05/09/2012] Mudar para layout padrao (Gabriel) 
 * 002: [29/05/2015] Padronizacao das consultas automatizadas (Gabriel-RKAM)
 */
?>
 
<?
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");	
	
	$flmudfai = $_POST["flmudfai"];
?>

<table id="valores"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="228px">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('Alteração Valor');?></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick=<?php echo "acessaOpcaoAba(".count($opcoesTela).",0,'".$opcoesTela[0]."');"; ?> class="txtNormalBold">Principal</a></td>
																																					
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div style="width: 195px; height: 85px;" id="divConteudoValor">
																		
										<form id='frmValor' class="formulario">
											
											<label for="vlemprst" ><? echo utf8ToHtml('Novo valor:') ?></label>
											<input name="vlemprst"  id="vlemprst" type="text" value="" />
											<br />
											
											<label for="vleprori" ><? echo utf8ToHtml('Valor anterior:') ?></label>
											<input name="vleprori" id="vleprori" type="text" value="" />
											<br />
																																
										</form>
										
										<div id="divBotoes">
											<a href="#" class="botao" id="btContinuar" onClick="fechaValores('<? echo $flmudfai; ?>'); return false;">Continuar</a>
											<br />
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
<script type="text/javascript">
	//Insere valor nos campos e formatação
	var vlemprst_1 = $('#vlemprst','#frmValor');
	var vleprori_1 = $('#vleprori','#frmValor');
	
	var rVlemprst_1 = $('label[for="vlemprst"]','#frmValor');
	var rVleprori_1 = $('label[for="vleprori"]','#frmValor');
	
	vlemprst_1.val( arrayProposta['vlemprst'] );
	vleprori_1.val( vleprori );
	
	rVlemprst_1.addClass('rotulo').css('width','85px');
	rVleprori_1.addClass('rotulo').css('width','85px');
	
	vlemprst_1.addClass('moeda').css('width','90px');
	vleprori_1.addClass('moeda').css('width','90px');
	
	vlemprst_1.desabilitaCampo();
	vleprori_1.desabilitaCampo();
	
</script>