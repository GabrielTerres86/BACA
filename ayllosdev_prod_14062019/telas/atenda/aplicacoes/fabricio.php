var strHTML = "";

strHTML += '<div class="divDados">';	
strHTML += '		<table>';
strHTML += '			<thead>';
strHTML += '				<tr>';
strHTML += '					<th><? echo utf8ToHtml('Data'); ?></th>';
strHTML += '					<th><? echo utf8ToHtml('Hist&oacute;rico');  ?></th>';
strHTML += '					<th><? echo utf8ToHtml('Docmto');  ?></th>';
strHTML += '					<th><? echo utf8ToHtml('Vencto');  ?></th>';
strHTML += '					<th><? echo utf8ToHtml('Sl Resgate');  ?></th>';
strHTML += '					<th><? echo utf8ToHtml('Vl Resgate');  ?></th>';
strHTML += '				</tr>';
strHTML += '			</thead>';
strHTML += '			<tbody>';
							lstAplicacoes = new Array(); 

<?php
	echo "alert('inicio');";
	$nrdconta = $_POST["nrdconta"];
	$sldtotrg = $_POST["slresgat"];
	$vltotrgt = $_POST["vlresgat"];
	$dtresgat = $_POST["dtresgat"];
	$flgctain = $_POST["flgctain"];
	
	// Monta o xml de requisição
	$xmlGetAplicacoes  = "";
	$xmlGetAplicacoes .= "<Root>";
	$xmlGetAplicacoes .= "	<Cabecalho>";
	$xmlGetAplicacoes .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlGetAplicacoes .= "		<Proc>obtem-dados-aplicacoes</Proc>";
	$xmlGetAplicacoes .= "	</Cabecalho>";
	$xmlGetAplicacoes .= "	<Dados>";
	$xmlGetAplicacoes .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetAplicacoes .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetAplicacoes .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetAplicacoes .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetAplicacoes .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetAplicacoes .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xmlGetAplicacoes .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetAplicacoes .= "		<idseqttl>1</idseqttl>";
	$xmlGetAplicacoes .= "		<nraplica>0</nraplica>";
	$xmlGetAplicacoes .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";
	$xmlGetAplicacoes .= "	</Dados>";
	$xmlGetAplicacoes .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetAplicacoes);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAplicacoes = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAplicacoes->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAplicacoes->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
		
	$aplicacoes   = $xmlObjAplicacoes->roottag->tags[0]->tags;	
	$qtAplicacoes = count($aplicacoes);
	
	// Procura indíce da opção "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	if ($idPrincipal === false) {
		$idPrincipal = 0;
	}
		
	selecionaAplicacoes($vltotrgt, "RDCA30");
	
	if ($vltotrgt > 0){
		selecionaAplicacoes($vltotrgt, "RDCA60");
		
		if ($vltotrgt > 0)
			selecionaAplicacoes($vltotrgt, "RDCPOS");
	}
	
	
		
function selecionaAplicacoes(@$par_vlrg){
	
	$y = -1;
	$z = 0;
	$aux_data = getByTagName($aplicacoes[0]->tags,"DTMVTOLT");
	$qtdiacar = getByTagName($aplicacoes[0]->tags,"QTDIACAR");
			
	do{
		for($i = 0; $i < $qtAplicacoes; $i++){
			if (getByTagName($aplicacoes[$i]->tags,"DSAPLICA") == "RDCA30"){
				$z += 1;
				if (dataParaTimestamp(getByTagName($aplicacoes[$i]->tags,"DTMVTOLT")) < dataParaTimestamp($aux_data)){
					$aux_data = getByTagName($aplicacoes[$i]->tags,"DTMVTOLT");
					$y = $i;
				} else {
					if (dataParaTimestamp(getByTagName($aplicacoes[$i]->tags,"DTMVTOLT")) == dataParaTimestamp($aux_data)){
						if (getByTagName($aplicacoes[$i]->tags,"QTDIACAR") < $qtdiacar){
							$aux_data = getByTagName($aplicacoes[$i]->tags,"DTMVTOLT");
							$y = $i;
							$qtdiacar = getByTagName($aplicacoes[$i]->tags,"QTDIACAR");
						} else
							$y = $i;
					}
				}
			}
		}
		
		if ($z > 0){
			$flgrgt = "true";
		
			if (getByTagName($aplicacoes[$y]->tags,"DTVENCTO") > $glbvars["dtmvtolt"]){
				if ((getByTagName($aplicacoes[$y]->tags,"DTVENCTO") - $glbvars["dtmvtolt"]) < 10){
					echo 'showConfirmacao("Aplica&ccedil;&atilde;o numero '.getByTagName($aplicacoes[$y]->tags,"NRAPLICA").' vencera em '.getByTagName($aplicacoes[$y]->tags,"DTVENCTO").'. Resgatar?","Confirma&ccedil;&atilde;o - Aimaro","'.$flgrgt = "true"'","'$flgrgt = "false"'","sim.gif","nao.gif");';
				}
			}
			
			if ($flgrgt){
		
				$dtmvtolt = getByTagName($aplicacoes[$i]->tags,"DTMVTOLT");
				$nraplica = getByTagName($aplicacoes[$i]->tags,"NRAPLICA");
				$dshistor = getByTagName($aplicacoes[$i]->tags,"DSHISTOR");
				$nrdocmto = getByTagName($aplicacoes[$i]->tags,"NRDOCMTO");
				$dtvencto = getByTagName($aplicacoes[$i]->tags,"DTVENCTO");
				$indebcre = getByTagName($aplicacoes[$i]->tags,"INDEBCRE");
				$vllanmto = getByTagName($aplicacoes[$i]->tags,"VLLANMTO");
				$sldresga = getByTagName($aplicacoes[$i]->tags,"SLDRESGA");
				$cddresga = getByTagName($aplicacoes[$i]->tags,"CDDRESGA");
				$dtresgat = getByTagName($aplicacoes[$i]->tags,"DTRESGAT");
				$dssitapl = getByTagName($aplicacoes[$i]->tags,"DSSITAPL");
				$txaplmax = getByTagName($aplicacoes[$i]->tags,"TXAPLMAX");
				$txaplmin = getByTagName($aplicacoes[$i]->tags,"TXAPLMIN");
				
				if ($par_vlrg >= $sldresga){
					$vlresgat = $sldresga;
					$par_vlrg -= $vlresgat;
				} else {
					$vlresgat = $par_vlrg;
					$par_vlrg = 0;
				}
					
				?>
			
				<script type="text/javascript">
				objAplica = new Object();						
				objAplica.dtmvtolt = "<?php echo $dtmvtolt; ?>";
				objAplica.nraplica = "<?php echo $nraplica; ?>";
				objAplica.dshistor = "<?php echo $dshistor; ?>";
				objAplica.nrdocmto = "<?php echo $nrdocmto; ?>";
				objAplica.dtvencto = "<?php echo $dtvencto; ?>";
				objAplica.indebcre = "<?php echo $indebcre; ?>";
				objAplica.vllanmto = "<?php echo $vllanmto; ?>";
				objAplica.sldresga = "<?php echo $sldresga; ?>";
				objAplica.cddresga = "<?php echo $cddresga; ?>";
				objAplica.dtresgat = "<?php echo $dtresgat; ?>";
				objAplica.dssitapl = "<?php echo $dssitapl; ?>";
				objAplica.txaplmax = "<?php echo $txaplmax; ?>";
				objAplica.txaplmin = "<?php echo $txaplmin; ?>";
				lstAplicacoes[<?php echo $i; ?>] = objAplica;
				</script>
				
				
				<tr id="trAplicacao<?php echo $i; ?>" style="cursor: pointer; background-color: <?php echo $cor; ?>" onClick="selecionaAplicacao(<?php echo $i; ?>,<?php echo $qtAplicacoes; ?>,'<?php echo $nraplica; ?>');">
					<td><span><?php echo dataParaTimestamp($dtmvtolt); ?></span>
							<?php echo $dtmvtolt; ?>
							<a href="#" id="linkApl<?php echo $i; ?>" style="cursor: default;" onClick="return false;"></a>
					</td>
					<td><span><?php echo $dshistor; ?></span>
							<?php echo $dshistor; ?>
					</td>
					<td><span><?php echo $nrdocmto; ?></span>
							<?php echo $nrdocmto; ?>
					</td>
					<td><span><?php echo dataParaTimestamp($dtvencto); ?></span>
							<?php echo $dtvencto; ?>
					</td>
					<td><span><?php echo str_replace(",",".",$sldresga); ?></span>
							<?php echo number_format(str_replace(",",".",$sldresga),2,",","."); ?>
					</td>
					<td><span><?php echo str_replace(",",".",$sldresga); ?></span>
							<?php echo number_format(str_replace(",",".",$sldresga),2,",","."); ?>
					</td>
					
				</tr>
			
			</tbody>
		</table>
</div>	
	
<?php
				
			}
			
			$z -= 1;
			array_splice($aplicacoes, $y, 1);
		}
		
	} while($z > 0);
}

?>