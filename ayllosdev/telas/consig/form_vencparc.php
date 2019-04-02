<?php
/* **********************************************************************

  Fonte: form_vencparc.php
  Autor: JDB - AMcom
  Data : Fev 2018                      Última Alteração:

  Objetivo  : tabela com datas de vencimento de parcelas

  Alterações: 
  

 ********************************************************************** */

 session_start();
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');
 require_once('../../includes/controla_secao.php');		
 require_once('../../class/xmlfile.php');
 isPostMethod();
?>

<form name="frmVencParc" id="frmVencParc" class="formulario frmVencParc" >
	<fieldset id="fsetVencParc" name="fsetVencParc" style="padding:0px; padding-bottom:10px;">
		<legend> <? echo utf8ToHtml('Vencimentos')?> </legend>
		<br style="clear:both" />
		<table class="tituloRegistros" id="tblVencParc" cellpadding="1" cellspacing="1">
		<thead>		
			<tr id="trCabecalho" name="trCabecalho">
				<th class="header" id="tdTitDe" width="23%"><strong>Dia/M&ecirc;s In&iacute;cio</strong></td>
				<th class="header" id="tdTitAte" width="23%"><strong>Dia/M&ecirc;s Fim</strong></td>
				<th class="header" id="tdTitDtEnvio" width="23%"><strong>Data Envio Arquivo</strong></td>
				<th class="header" id="tdTitDtVencimento" width="23%"><strong>Data Vencimento</strong></td>
				<th class="header" id="tdTitEditar" width="8%"><strong>&nbsp;</strong></td>
			</tr>
		</thead>
		<?php	
			//buscar vencimento parcela
			//incluir vencimento parcela CAMPO CODIGO ENVIAR 0 SE FOR INCLUIR
			$xml  = '';
			$xml .= '<Root>';
			$xml .= '	<Dados>';
			$xml .= '       <cdempres>'.$cdempres.'</cdempres>';// cdempres		
			$xml .= '	</Dados>';
			$xml .= '</Root>';
			
			$xmlResult = mensageria(
				$xml,
				"TELA_CONSIG",
				"BUSCAR_VENC_PARCELA",
				$glbvars["cdcooper"],
				$glbvars["cdagenci"],
				$glbvars["nrdcaixa"],
				$glbvars["idorigem"],
				$glbvars["cdoperad"],
				"</Root>");

			$xmlObj = getObjectXML($xmlResult);
			$ret = ( isset($xmlObj->roottag->tags[0]->tags[0]->tags) ) ? $xmlObj->roottag->tags : array(); 
			$total = ( isset($xmlObj->roottag->tags[0]->attributes["QTREGIST"]) ) ? $xmlObj->roottag->tags[0]->attributes["QTREGIST"] : 0;			
			//print_r($ret);
			for($i=0; $i<$total; $i++){								
				if ($i+1 % 2 == 0){					
					$classLinha = "class= 'odd corParAux'";
				}else{
					$classLinha = "class= 'even corImpar'";
				}				
				$idLinha = "$i";
				echo "<tr ".$classLinha." id='".$idLinha."'>";
				echo "<td> <input type=\"hidden\" id=\"idemprconsigparam_".$i."\" name=\"idemprconsigparam_".$i."\" value=\"".getByTagName($ret[0]->tags[$i]->tags,'IDEMPRCONSIGPARAM')."\" />
					       <input type=\"text\" style=\"text-align:center\" maxlength=5 id=\"dtinclpropostade_".$i."\" name=\"dtinclpropostade_".$i."\" value=\"".getByTagName($ret[0]->tags[$i]->tags,'DTINCLPROPOSTADE')."\" /> </center>
					  </td>";
				echo "<td> <input type=\"text\" style=\"text-align:center\" maxlength=5 id=\"dtinclpropostaate_".$i."\" name=\"dtinclpropostaate_".$i."\" value=\"".getByTagName($ret[0]->tags[$i]->tags,'DTINCLPROPOSTAATE')."\" /></td>";
				echo "<td> <input type=\"text\" style=\"text-align:center\" maxlength=5 id=\"dtenvioarquivo_".$i."\" name=\"dtenvioarquivo_".$i."\" value=\"".getByTagName($ret[0]->tags[$i]->tags,'DTENVIOARQUIVO')."\" /></td>";
				echo "<td> <input type=\"text\" style=\"text-align:center\" maxlength=5 id=\"dtvencimento_".$i."\" name=\"dtvencimento_".$i."\" value=\"".getByTagName($ret[0]->tags[$i]->tags,'DTVENCIMENTO')."\" /></td>";				
				echo "<td align='center'> <a href=\"javascript:Cancelar('".$idLinha."');\" class=\"botao\" id=\"btexcluir_".$i."\" name=\"btexcluir_".$i."\">Excluir</a></td>";				
			
			}
		?>		
<tr class="footer">	
	<td colspan="1" id="tdNovo"><a href="javascript:NovoRegistro();" id="btincluir" name="btincluir" class="botao">Incluir</a></td>
	<td colspan="1" id="tdReplicar"><strong>&nbsp;</strong></td>
	<td colspan="3"><?php echo "<input type='hidden' id='total' name='total' value='$total'>"; ?></td>
</tr>
</table>
	</fieldset>
</form>

<script type="text/javascript">
mascara('<?php echo $total; ?>');
</script>