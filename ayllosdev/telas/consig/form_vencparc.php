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
		<table class="tituloRegistros" id="tblVencParc" cellpadding="1" cellspacing="1">
		<thead>		
			<tr id="trCabecalho" name="trCabecalho">
				<th class="header" id="tdTitLinha"><strong>Ln</strong></td>
				<th class="header" id="tdTitCod"><strong>Cod.</strong></td>
				<th class="header" id="tdTitDe"><strong>Dia/M&ecirc;s In&iacute;cio</strong></td>
				<th class="header" id="tdTitAte"><strong>Dia/M&ecirc;s Fim</strong></td>
				<th class="header" id="tdTitDtEnvio"><strong>Data Envio Arquivo</strong></td>
				<th class="header" id="tdTitDtVencimento"><strong>Data Vencimento</strong></td>
				<th class="header" id="tdTitEditar"><strong>&nbsp;</strong></td>
				<th class="header" id="tdTitExcluir"><strong>&nbsp;</strong></td>
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
				
				$linha = $i+1;
				if ($linha % 2 == 0){					
					$classLinha = "class= 'odd corPar'";
				}else{
					$classLinha = "class= 'even corImpar'";
				}
				$cod = getByTagName($ret[0]->tags[$i]->tags,'IDEMPRCONSIGPARAM');
				$de = getByTagName($ret[0]->tags[$i]->tags,'DTINCLPROPOSTADE');
				$ate = getByTagName($ret[0]->tags[$i]->tags,'DTINCLPROPOSTAATE');
				$dtEnvio = getByTagName($ret[0]->tags[$i]->tags,'DTENVIOARQUIVO');
				$dtVencimento = getByTagName($ret[0]->tags[$i]->tags,'DTVENCIMENTO');
				$idLinha = "trLinha$i";
				echo "<tr ".$classLinha." id='".$idLinha."'>";
				echo "<td align='center'>".$linha."</td>";
				echo "<td align='center' >$cod</td>";
				echo "<td align='center'>$de</td>";
				echo "<td align='center'>$ate</td>";
				echo "<td align='center'>$dtEnvio</td>";
				echo "<td align='center'>$dtVencimento</td>";
				echo "<td align='center'><a href=\"#\" onclick=\"EditarLinha('$idLinha', '$linha');\"><img src=\"".$UrlImagens."botoes/alterar.gif\" alt=\"Editar\" title=\"Editar\"></a></td>";
				echo "<td align='center'><a href=\"#\" onclick=\"ExcluirLinha('$idLinha', '$cod');\"><img src=\"".$UrlImagens."botoes/excluir.gif\" alt=\"Excluir\" title=\"Excluir\"></a></td>";
			}
		?>
<tr class="footer">	
	<td colspan="6" id="tdNovo"><a href="javascript:NovoRegistro();"><img src="<? echo $UrlImagens; ?>botoes/novo.gif" alt="Nova Linha" title="Nova Linha" /></a></td>
	<!-- <td colspan="2" id="tdLimpar"><a href="javascript:Limpar();"><img src=" echo $UrlImagens; botoes/limpar.gif" alt="Limpar" title="Limpar" /></a></td> -->
	<td colspan="2" ><?php echo "<input type='hidden' id='total' name='total' value='$total'>"; ?></td>
</tr>
</table>
	</fieldset>
</form>
