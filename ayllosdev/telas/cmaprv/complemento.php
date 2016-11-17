<?
/*!
 * FONTE        : complemento.php
 * CRIAÇÃO      : Rogérius Militão - DB1 Informatica
 * DATA CRIAÇÃO : 29/09/2011 
 * OBJETIVO     : Tela do formulario de complemento
 * --------------
 * ALTERAÇÕES   :
 * 001: [30/11/2012] David (CECRED)  : Validar session
 * 002: [18/01/2013] Daniel (CECRED) : Implantacao novo layout.
 * 003: [27/11/2014] Jorge/Rosangela : Adicioando escape de string "'" em campo dsobscmt. SD 218402
 * 004: [27/05/2015] Douglas (CECRED): Alterar de "Complemento" para "Observação" (Melhoria 18)
 */	 
?>

<?
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	isPostMethod();	
	
	$flag	  = $_POST['flag'];
	$operacao = $_POST['operacao'];
	$cddopcao = $_POST['cddopcao'];
	$insitapv = $_POST['insitapv'];
	$dsobscmt = $_POST['dsobscmt'];
	$dsresapr = "";

	$dsobscmt = str_replace("@@", "\r", $dsobscmt);
	$dsobscmt = str_replace("@@", "\n", $dsobscmt);
	$dsobscmt = str_replace("@@","\r\n", $dsobscmt);
	$dsobscmt = str_replace("@@", "\t", $dsobscmt);
	$dsobscmt = str_replace("@@", "'", $dsobscmt);

	
	if  ($insitapv == 1 )
		$dsresapr = "";
	else if ($insitapv == 2)
		$dsresapr = "NA :";
	else if ($insitapv == 3)
		$dsresapr = "AR :";
	else if ($insitapv == 4)
		$dsresapr = "RF :";
	
	if ( $operacao == 'alterar' ) 
		$observacao = $dsresapr . $dsobscmt;
	else if ( $operacao == 'incluir' )
		$observacao = $dsresapr;
	else if ( $operacao == 'consultar' ) {
		$observacao = $dsobscmt;		
	}

	$observacao = retiraAcentos($observacao);

?>

<table cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0"  >
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('OBSERVAÇÃO') ?></td>
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
										<form name="frmComplemento" id="frmComplemento" class="formulario" onSubmit="return false;" >	

										<input name="flgalter" id="flgalter" type="hidden" value="<? echo $operacao ?>"  />
										
										<label for="cdcmaprv"><? echo utf8ToHtml('Motivo:') ?></label>
										<input name="cdcmaprv" id="cdcmaprv" type="text" onChange="buscaAprovacao(); return false;" />
										<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

										<input name="dscmaprv" id="dscmaprv" type="text"  />
										<br >
										
										<label for="dsobscmt"></label>
										<textarea name="dsobscmt" id="dsobscmt"><?php echo $observacao ?></textarea>
										</form>
										
										<div id="divBotoes" style="padding-bottom:10px">
											<?php if ( $operacao == 'consultar' ) { ?>
											<a href="#" class="botao" id="btVoltar" onClick="<? echo $flag == '1' ? 'mostraOpcoes();' : 'fechaRotina($(\'#divRotina\'));'?> return false;" >Voltar</a>
											<?php } else if ( $operacao == 'incluir' || $operacao == 'alterar' ) { ?>
											<a href="#" class="botao" id="btSalvar" onclick="manterRotina('CO'); return false;">Continuar</a>
											<?php } ?>
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


<script>

highlightObjFocus( $('#frmComplemento') );

</script>