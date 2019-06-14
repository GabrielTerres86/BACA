<?
/*!
 * FONTE        : responsavel_legal.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 04/05/2010 
 * OBJETIVO     : Mostra rotina de Reponsavel Legal da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 *				  04/05/2012 - Ajustes referente ao projeto GP - Sócios Menores (Adriano).
 *				  10/10/2014 - Atribuição do nome da Rotina corretamente (Lunelli - SD 198405).
 *                03/09/2015 - Reformulacao cadastral (Gabriel-RKAM).
 */	
?>
 
<?
		
	// Carregas as opções da Rotina de Procuradores/representantes
	$flgAcesso	  = (in_array('@', $glbvars['opcoesTela']));
	$flgConsultar = (in_array('C', $glbvars['opcoesTela']));
	$flgAlterar   = (in_array('A', $glbvars['opcoesTela']));
	$flgIncluir   = (in_array('I', $glbvars['opcoesTela']));
	$flgExcluir   = (in_array('E', $glbvars['opcoesTela']));
	
	$nmdatela = $_POST["nmdatela"];
	$flgcadas = $_POST["flgcadas"];
		
	if ($flgAcesso == '') exibirErro('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de acesso a tela de Responsavel Legal.','Alerta - Aimaro','');
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('RESPONSÁVEL LEGAL'); ?></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick=<?php echo "acessaOpcaoAbaResp(".count($opcoesTela).",0,'".$opcoesTela[0]."');"; ?> class="txtNormalBold">Principal</a></td>
																																					
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divOpcoesDaOpcao2">&nbsp;</div>
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
	
	// Declara os flags para as opções da Rotina de Procuradores
	var flgAlterar   = "<? echo $flgAlterar;   ?>";	
	var flgIncluir   = "<? echo $flgIncluir;   ?>";	
	var flgExcluir   = "<? echo $flgExcluir;   ?>";	
	var flgConsultar = "<? echo $flgConsultar; ?>";
	var nmdatela     = "<? echo $nmdatela;     ?>";
	var flgcadas     = "<? echo $flgcadas;     ?>";
		
	nmrotina = "Responsavel Legal";
	
	// Função que exibe a Rotina
	exibeRotina(divRotina);
		
	<? echo "acessaOpcaoAbaResp(".count($opcoesTela).",0,'".$opcoesTela[0]."');"; ?>
	
</script>


