<?
/*
 * FONTE        : formulario_dda.php
 * CRIAÇÃO      : Gabriel Ramirez
 * DATA CRIAÇÃO : 11/04/2011 
 * OBJETIVO     : Mostrar o form da rotina de DDA da tela de CONTAS 
 * 
 * ALTERACOES   : 03/12/2014 - De acordo com a circula 3.656 do Banco Central,
 *							   substituir nomenclaturas Cedente por Beneficiário e  
 *							   Sacado por Pagador. Chamado 229313 (Jean Reddiga - RKAM)
 */ 
?>

<?
	$flgativo = getByTagName($dda[0]->tags,'flgativo') == "yes" ? "SIM" : "N&Atilde;O";		
?>


 <form name="divConteudoTitular" id="divConteudoTitular" class="formulario" onSubmit="return false;" >

     <fieldset>

		   <legend>Cooperado</legend>
	
		   <table width="100%" border="0" cellspacing="3" cellpadding="0">
			<tr>
				<table width="100%" border="0" cellspacing="3" cellpadding="0">
				   <tr>
						<td width="105" align="right" class="txtNormalBold">C.P.F./C.N.P.J.:&nbsp;</td>
						<td><input name="dscpfcgc" id="dscpfcgc" type="text" class="campoTelaSemBorda" style="width:110px;" value="<? echo getByTagName($dda[0]->tags,'dscpfcgc'); ?>" readonly /></td>
					
						<td width="95" align="right" class="txtNormalBold">Tipo de Pessoa:&nbsp;</td> 
						<td><input name="dspessoa" id="dspessoa" type="text" class="campoTelaSemBorda" style="width:75px;" value="<? echo getByTagName($dda[0]->tags,'dspessoa'); ?>" readonly /></td>	
				   </tr>
				</table>
		    </tr>			   				
		    <tr height="1">
			    <td colspan="2"></td>
		    </tr>
		    <tr>
				<table width="100%" border="0" cellspacing="3" cellpadding="0">
					<tr>
			            <td width="105" align="right" class="txtNormalBold">Nome:&nbsp;</td>
			            <td><input name="nmextttl" id="nmextttl" type="text" class="campoTelaSemBorda" style="width:295px;" value="<? echo getByTagName($dda[0]->tags,'nmextttl'); ?>" readonly /></td>	
					</tr>
				</table>
			</tr>		    	
		   </table>
		
		</fieldset>
		
		<fieldset>
		
		<legend> DDA </legend>
		
		<table width="100%" border="0" cellspacing="3" cellpadding="0">
		<tr>
			<td width="115" align="right" class="txtNormalBold">Pagador eletr&ocirc;nico:&nbsp;</td>
			<td><input name="flgativo" id="flgativo" type="text" class="campoTelaSemBorda" style="width:85px;" value="<? echo $flgativo; ?>" readonly /></td>	
		</tr>
		<tr height="1">
			<td colspan="2"></td>
		</tr>
		<tr height="31">
			<td width="115" align="right" class="txtNormalBold">Qtde de Ades&otilde;es:&nbsp;</td>
            <td><input name="qtadesao" id="qtadesao" type="text" class="campoTelaSemBorda" style="width:65px; text-align:right;" value="<? echo formataNumericos("zz9",getByTagName($dda[0]->tags,'qtadesao'),'.'); ?>" readonly /></td>
		</tr>
		<tr height="1">
			<td colspan="2"></td>
		</tr>		
		<tr height="1">
			<td width="115" align="right" class="txtNormalBold">Situa&ccedil;&atilde;o:&nbsp;</td>
			<td><input name="dssituac" id="dssituac" type="text" class="campoTelaSemBorda" style="width:285px;" value="<? echo getByTagName($dda[0]->tags,'dssituac'); ?>" readonly /></td>	
		</tr>
		<tr height="1">
			<td colspan="2"></td>
		</tr>	
		<tr>
		   <td width="115" align="right" class="txtNormalBold">Data da Situa&ccedil;&atilde;o:&nbsp;</td>
           <td><input name="dtsituac" id="dtsituac" type="text" class="campoTelaSemBorda" style="width:65px;" value="<? echo getByTagName($dda[0]->tags,'dtsituac'); ?>" readonly /></td>		   		
		</tr>
		<tr height="1">
			<td colspan="2"></td>
		</tr>	
		<tr height="1">
			<td colspan="2"></td>
		</tr>
		<tr>
			<td width="115" align="right" class="txtNormalBold">Data da Ades&atilde;o:&nbsp;</td>
            <td><input name="dtadesao" id="dtadesao" type="text" class="campoTelaSemBorda" style="width:65px;" value="<? echo getByTagName($dda[0]->tags,'dtadesao'); ?>" readonly /></td>
		</tr>
		<tr height="1">
			<td colspan="2"></td>
		</tr>
		<tr>
			<td width="115" align="right" class="txtNormalBold">Data da Exclus&atilde;o:&nbsp;</td>
            <td><input name="dtexclus" id="dtexclus" type="text" class="campoTelaSemBorda" style="width:65px;" value="<? echo getByTagName($dda[0]->tags,'dtexclus'); ?>" readonly /></td>
		</tr>
		
	 </table>
	 
	 </fieldset>
	
 </form>
 
 
 <div id="divBotoes">
  
  <? // Permissoes de usuarios 
	$flgIncluir = (in_array('I',$glbvars["opcoesTela"]));
	$flgEncerra = (in_array('X',$glbvars["opcoesTela"]));	
	$flgImprime = (in_array('M',$glbvars["opcoesTela"])); 
  ?>
    
     <td><input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="encerraRotina();"/></td>
 
  <? if (getByTagName($dda[0]->tags,'btnaderi') == "yes" && $flgIncluir == "yes" ) { ?>
	 <td><input type="image" id="btAderir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="ConfirmaAderir()" /></td>
  <? } ?>
  
  <? if (getByTagName($dda[0]->tags,'btnexclu') == "yes" && $flgEncerra == "yes") { ?>
	 <td><input type="image" id="btEncerrar" src="<? echo $UrlImagens; ?>botoes/encerrar.gif" onClick="ConfirmaEncerrar()" /></td>
  <? } ?>
 
  <? if ($flgImprime == "yes") { ?> 
	 <td><input type="image" id="btImprimir" src="<? echo $UrlImagens; ?>botoes/imprimir.gif" onClick="imprimir()" /></td>
  <? } ?>
   				
 </div>
 
 
 <script type="text/javascript">
 
	hideMsgAguardo();
	
	// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
	
	$('#dscpfcgc').focus();
 </script>