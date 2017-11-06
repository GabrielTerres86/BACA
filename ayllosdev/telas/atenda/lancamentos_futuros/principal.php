<?php 

	/************************************************************************
	    Fonte: principal.php
	    Autor: Guilherme
	    Data : Fevereiro/2008               Ultima Alteracao: 04/11/2017

	    Objetivo  : Listar os Lancamentos Futuros

        Alteracoes:
              30/06/2011 - Alterado para layout padrão (Rogerius - DB1).		
			  
			  21/07/2015 - Exclusao de lancamentos futuros (Tiago)
		
			  27/05/2015 - Inclusao do fldebito. (Jaison/James)

			   04/11/2017 - Ajuste permitir apenas consulta de extrato quando contas demitidas
                           (Jonata - RKAM P364).

	  ************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$sitaucaoDaContaCrm = $_POST["sitaucaoDaContaCrm"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetDadosLAUTOM  = "";
	$xmlGetDadosLAUTOM .= "<Root>";
	$xmlGetDadosLAUTOM .= "	<Cabecalho>";
	$xmlGetDadosLAUTOM .= "		<Bo>b1wgen0003.p</Bo>";
	$xmlGetDadosLAUTOM .= "		<Proc>consulta-lancamento</Proc>";
	$xmlGetDadosLAUTOM .= "	</Cabecalho>";
	$xmlGetDadosLAUTOM .= "	<Dados>";
	$xmlGetDadosLAUTOM .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosLAUTOM .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosLAUTOM .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosLAUTOM .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosLAUTOM .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosLAUTOM .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDadosLAUTOM .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosLAUTOM .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosLAUTOM .= "	</Dados>";
	$xmlGetDadosLAUTOM .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosLAUTOM);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosLAUTOM = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDadosLAUTOM->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosLAUTOM->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Seta a tag de lancamentos para a variavel
	$lancamentos = $xmlObjDadosLAUTOM->roottag->tags[1]->tags;

	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) {
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>


<div class="divRegistros">	
	<table>
		<thead>
			<tr>
                <th>&nbsp;</th>
				<th><? echo utf8ToHtml('Data'); ?></th>
				<th><? echo utf8ToHtml('Hist&oacute;rico');  ?></th>
				<th><? echo utf8ToHtml('Documento');  ?></th>
				<th><? echo utf8ToHtml('D/C');  ?></th>
				<th><? echo utf8ToHtml('Valor');  ?></th>
			</tr>
		</thead>
		<tbody>
			<? 
			for ($i = 0; $i < count($lancamentos); $i++) {				
			?>
				<tr>
                    <td>
                        <span><?php echo dataParaTimestamp($lancamentos[$i]->tags[5]->cdata); ?></span>
                        <?php
                            // Somente exibe se permitir exclusao ou permite debito
                            if (($lancamentos[$i]->tags[8]->cdata && ($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"E",false)) == "") || // Exclusao
                                 $lancamentos[$i]->tags[9]->cdata) { // Debito
                                ?>
                                <input type="checkbox" class="clsCheckbox" onclick="verificaCheckbox();" 
                                    recid="<?php echo $lancamentos[$i]->tags[8]->cdata; ?>" 
                                    dstabela="<?php echo $lancamentos[$i]->tags[6]->cdata; ?>" 
                                    cdhistor="<?php echo $lancamentos[$i]->tags[7]->cdata; ?>" 
                                    fldebito="<?php echo $lancamentos[$i]->tags[9]->cdata; ?>" 
                                    cdagenci="<?php echo $lancamentos[$i]->tags[10]->cdata; ?>" 
                                    cdbccxlt="<?php echo $lancamentos[$i]->tags[11]->cdata; ?>" 
                                    nrdolote="<?php echo $lancamentos[$i]->tags[12]->cdata; ?>" 
                                    nrseqdig="<?php echo $lancamentos[$i]->tags[13]->cdata; ?>" 
                                    dtrefere="<?php echo $lancamentos[$i]->tags[14]->cdata; ?>" 
                                    value="<?php echo converteFloat($lancamentos[$i]->tags[4]->cdata); ?>" />
                                <?php
                            }
                        ?>
                    </td>
					<td>					
						<!-- campos hidden *contem as chaves necessarias para mudar situacao registro lancamentos
						     dados vindo da b1wgen0003.p consulta_lancamentos tt-lancamento_futuro-->
						<input type="hidden" id="gen_dstabela" name="gen_dstabela" value="<?php print_r($lancamentos[$i]->tags[6]->cdata); ?>" /> <!-- generico -->
						<input type="hidden" id="gen_cdhistor" name="gen_cdhistor" value="<?php print_r($lancamentos[$i]->tags[7]->cdata); ?>" /> <!-- generico -->
						<input type="hidden" id="gen_recid" name="gen_recid" value="<?php print_r( trim($lancamentos[$i]->tags[8]->cdata) == '' ? '0' : $lancamentos[$i]->tags[8]->cdata ); ?>" /> <!-- generico -->						
						<!-- fim campos hidden -->
						
					    <span><?php echo dataParaTimestamp($lancamentos[$i]->tags[5]->cdata); ?></span>
							  <?php echo $lancamentos[$i]->tags[5]->cdata;  ?>
					</td>
					<td><span><?php echo $lancamentos[$i]->tags[1]->cdata; ?></span>
							  <?php echo stringTabela($lancamentos[$i]->tags[1]->cdata,'40','maiuscula'); ?>
					</td>
					<td><span><?php echo $lancamentos[$i]->tags[2]->cdata; ?></span>
							  <?php echo $lancamentos[$i]->tags[2]->cdata; ?>
					</td>
					<td><span><?php echo $lancamentos[$i]->tags[3]->cdata; ?></span>
							  <?php echo $lancamentos[$i]->tags[3]->cdata; ?>
					</td>
					<td><span><?php echo str_replace(",",".",$lancamentos[$i]->tags[4]->cdata); ?></span>
							  <?php echo number_format(str_replace(",",".",$lancamentos[$i]->tags[4]->cdata),2,",","."); ?>
					</td>
				</tr>
		<? } ?>	
		</tbody>
	</table>
</div>	
<table width="100%">
    <tr>
        <td align="right">
            <label for="vltotal">Valor Total:</label>
            <input type="text" name="vltotal" id="vltotal" />
        </td>
    </tr>
</table>
<div id="divBotoes">	
	<a href="#" class="botao" id="btVoltar">Voltar</a>
	
	<?php
	   //Projeto CRM: Para a situações de conta abaixo, a tela deve ser apresentada apenas para consulta.
		if(!($sitaucaoDaContaCrm == '2' || 
			 $sitaucaoDaContaCrm == '3' || 
			 $sitaucaoDaContaCrm == '4' || 
			 $sitaucaoDaContaCrm == '5' || 
			 $sitaucaoDaContaCrm == '7' || 
			 $sitaucaoDaContaCrm == '8' || 
			 $sitaucaoDaContaCrm == '9')){ 
	?>			
		<a href="#" class="botao" id="btDebitar">Debitar</a>
		<?php
			// Verifica se o usuario tem opcao de exclusao de lancamentos
			if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"E",false)) == "") {
				?>
				<a href="#" class="botao" id="btExcluir">Excluir</a>
				<?php
			}
		?>
	<?php }
			 ?>
	
	<br />	
</div>
<script type="text/javascript">

// Formata layout
controlaLayout();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

</script>
