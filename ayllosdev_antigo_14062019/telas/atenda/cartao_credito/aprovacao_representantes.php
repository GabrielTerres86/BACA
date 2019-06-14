
<?php 
    /*!
    * FONTE        : aprovacao_representantes.php
    * CRIAÇÃO      : Amasonas Borges Vieira Junior
    * DATA CRIAÇÃO : abril/2018
    * OBJETIVO     : Carregar tela para solicitar senha do(s) representante(s) de uma determinada conta.
    * --------------
    * ALTERAÇÕES   :
    * --------------
    * 000: [11/04/2018] Amasonas Borges Vieira Junior (SUPERO) : criação do arquivo.
    */

    session_start();
    require_once('../../../includes/config.php');
    require_once('../../../includes/funcoes.php');
    require_once('../../../includes/controla_secao.php');
    require_once('../../../class/xmlfile.php');
    isPostMethod();	

    if(!isset($_POST['nrdconta']) || !isset($_POST['nrctrcrd'])){

        return;
    }
    $nrdconta = $_POST['nrdconta'];
    $nrctrcrd = $_POST['nrctrcrd'];
    $tpacao   = $_POST['tpacao'];
	$esteira  = $_POST['esteira'];
	$cdadmcrd = $_POST['cdadmcrd'];
?>


        <?
            $xml .= "<Root>";
            $xml .= " <Dados>";
            $xml .= "   <nrctrcrd>$nrctrcrd</nrctrcrd>";
            $xml .= "   <nrdconta>$nrdconta</nrdconta>";
            $xml .= " </Dados>";
            $xml .= "</Root>";
            $admresult = mensageria($xml, "ATENDA_CRD", "BUSCAR_ASSINATURA_REPRESENTANTE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			//echo " /* \n $admresult \n */ ";
            $objectResult = simplexml_load_string( $admresult );		
            $podeEnviar = 1;
            $alguemAssinou = false;
            $alguemNaoAssinou = false;
            $idastcjt = null;
            $insitcrd = false;
            $inupgrad = false;
            $temJustificativa = false;
            $dsjustif;
            $cdopesup;
			
            if($tpacao == "verificaAutorizacoes"){

                foreach($objectResult->Dados->representantes->representante as $representante){   
                    if(is_null( $idastcjt)){
                                 $idastcjt = $representante->idastcjt;
                    }
                    if($representante->insitcrd){
                        $insitcrd = $representante->insitcrd;
                    }
					if($representante->inupgrad){
                        $inupgrad = $representante->inupgrad;
                    }
                    if( ($representante->assinou == "S")){
                       $alguemAssinou = true;
                    }else{
                        $alguemNaoAssinou = true;
                    }
					if(isset($representante->dsjustif) && (strlen($representante->dsjustif) > 0))
						$dsjustif = $representante->dsjustif;
					if(isset($representante->cdopesup) && (strlen($representante->cdopesup) > 0))
						$cdopesup = $representante->cdopesup;
					
					if(!$temJustificativa && (isset($representante->dsjustif) && strlen($representante->dsjustif) > 0)){
						$temJustificativa = true;
						
						echo "\n justificativaCartao ='".preg_replace( "/\r|\n/", "", $representante->dsjustif )."' ;\n";
						echo "\n  globalesteira = true; \n";
					}
                }
				  echo "autorizado = false; ";
				
				/*if((strlen($dsjustif) > 0 ) && (!isset($cdopesup) || strlen($cdopesup) ==0 )){
					  // Montar o xml de Requisicao
                    $xml = "<Root>";
                    $xml .= " <Dados>";
                    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
                    $xml .= " </Dados>";
                    $xml .= "</Root>";
                    $xmlResult = mensageria($xml, "ATENDA_CRD", "SUGESTAO_LIMITE_CRD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
                    $xmlObj = getObjectXML($xmlResult);


                    $json_sugestoes = json_decode($xmlObj->roottag->tags[0]->tags[1]->tags[0]->tags[0]->cdata,true);

                    $idacionamento = $json_sugestoes['protocolo'];
                
                    if(isset($idacionamento))
                        echo "protocolo = '$idacionamento';";
                  
					return;
				 }*/




                
                return;
            }
        ?>
    
        <br>
        <p><? echo utf8ToHtml("Selecione o representante desejado e solicite a digitação da senha do TA ou da Internet.") ;?></p>
        <br>
        
        <table class="tituloRegistros">
            <thead>
                <tr>
                    <th style="width: 110px;">Representante</th>
                    <th style="width: 110px;">CPF</th>	
                    <th style="width: 110px;">Validado</th>
                    <th style="width: 110px;">Validar</th>
                    <th class="ordemInicial" style="width: 13px;"></th>
                </tr>		
            </thead>
        </table>
        <div class="divRegistros">
			<table>

                <tbody>
                    <?php 
                        $counter = 0;//idastcjt
                        $idastcjt = null;
                        $alguemAssinou = false;
						$dsjustif;
						$cdopesup;
                        foreach($objectResult->Dados->representantes->representante as $representante){
                            if(is_null( $idastcjt)){
                                 $idastcjt = $representante->idastcjt;
                            }
                            if( $counter % 2 ==0)
                                $style = "even corImpar ";
                            else
                                $style = "odd corPar ";
                            if( ($representante->assinou == "N"))
                                $podeEnviar = 0;
                            else
                                $alguemAssinou = true;
							if(isset($representante->dsjustif) && (strlen($representante->dsjustif) > 0))
								$dsjustif = $representante->dsjustif;
							if(isset($representante->cdopesup) && (strlen($representante->cdopesup) > 0))
								$cdopesup = $representante->cdopesup;
                            $counter++;
                                ?>
                                    <tr style="  " class="<?php echo $style; ?> ">
                                        <td style=" width: 152; "><?php echo  $representante->nome ; ?> </td>
                                        <td style=" width: 152; "><?php echo $representante->nrcpfcgf; ?> </td>
                                        <td style=" width: 152; "> <?php echo $representante->assinou == "N"?  utf8ToHtml("Não"):"Sim"; ?> </td>
                                        <? if( $representante->assinou == "N"){?>
                                            <td style=" "><input type="radio" name="agentPassword" id="agentPassword" value="<?php echo $representante->nrcpfcgf; ?>#<?php echo $representante->nome; ?>#<?php echo $representante->nrdctato; ?>"> </td>
                                        <? } else{?>
                                            <td style=" "> </td>
                                        <? } ?>
                                    </tr>
                                <?
                        }
                        if($alguemAssinou && $idastcjt == "0")
                            $podeEnviar = 1;
                    ?>

                </tbody>
            </table>
        </div>
        <script>

        </script>

        <div id="divBotoes" >
            
            
            <?

                if($podeEnviar)
                {
                    ?>
                        <a href="#" class="botao" id="" onclick="<?echo 'acessaOpcaoAba(\''.count($glbvars["opcoesTela"]).'\',0,\''.$glbvars["opcoesTela"][0].'\');';?>;"> Sair</a>
                        <a href="#" class="botao" id="" onclick="enviarBancoob(' <? echo utf8ToHtml($nrctrcrd) ;?> ');"> <? echo utf8ToHtml("Enviar Solicitação") ;?></a>
							
                    <?
                }else{
                    ?>
                        <a href="#" class="botao" id="" onclick="<?echo 'acessaOpcaoAba(\''.count($glbvars["opcoesTela"]).'\',0,\''.$glbvars["opcoesTela"][0].'\');';?>;"> Sair</a>						
                        <a href="#" class="botao" id="" onclick="validarSenha(<?php echo $nrctrcrd; ?>)" > Validar</a>
                    <?                   
                }
            ?>

        </div>