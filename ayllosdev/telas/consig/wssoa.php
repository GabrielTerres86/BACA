<?php

/*!
 * FONTE        : wssoa.php 
 * CRIAÇÃO      : JDB - AMcom
 * DATA CRIAÇÃO : 05/2019
 * OBJETIVO     : Comunicação com SOA x FIS - Integrar empressas consignado com a FIS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 
 */



function chamaServico($data,$Url_SOA, $Auth_SOA){
	$arrayHeader = array("Content-Type:application/json","Accept:application/json","Authorization:".$Auth_SOA);
	$url = $Url_SOA."/osb-soa/TransacaoCreditoRestService/v1/EnviarDadosCadastraisConvenioCredito";
	
	$dataexemplo = '{
	  "convenioCredito" : {
		"conveniado" : {
		  "identificadorReceitaFederal" : "84229889000173",
		  "nomeFantasiaOuAbreviado" : "BRANDILI TEXTIL",
		  "razaoSocialOuNome" : "BRANDILI TEXTIL LTDA",
		  "contaCorrente" : {
			"agencia" : {
			  "codigo" : "0101"
			},
			"banco" : {
			  "codigo" : "85"
			},
			"codigoContaSemDigito" : "2297000"
		  }
		},
		"cooperativa" : {
		  "codigo" : "1"
		},
		"dataContratacao" : "2019-04-23T00:00:00",
		"dataExpiracao" : "2021-04-23T00:00:00",
		"numeroContrato" : "36",
		"tipoConveniada" : {
		  "codigo" : 3
		}
	  },
	  "pessoaContatoEndereco" : {
		"CEP" : 89135000,
		"cidade" : {
		  "descricao" : "APIUNA"
		},
		"nomeBairro" : "CENTRO",
		"numeroLogradouro" : 29,
		"tipoENomeLogradouro" : "RUA QUINTINO BOCAIUVA",
		"UF" : "SC"

	  },
	  "pessoaContatoTelefone" : {
		"numero" : 33532401,
		"DDD" : 46
	  },
	  "pessoaContatoEmail" : {
		"enderecoEletronico" : "rasiela.valencio@brandili.com.br",
		"nomeContato" : "CLAUDIO BURG"
	  },
	  "credito" : {
		"produto" : {
		  "codigo" : "161"
		}
	  },
	  "sistemaTransacao" : {
		"tipoUsuario" : {
		  "codigo" : 1
		}
	  },
	  "interacaoGrafica" : {
		"dataAcaoUsuario" : "2019-04-23T19:26:25"
	  },
	  "listaVencimentos" : {
		"vencimento" : [ {
		  "convenioCredito" : {
			"dataContratacao" : "2019-04-23T00:00:00"
		  },
		  "configuracaoCredito" : {
			"tratamendoDiaNaoUtil" : {
			  "codigo" : 3
			}
		  },
		  "consulta" : {
			"tipoContagemDias" : {
			  "codigo" : 2
			}
		  },
		  "parametroConsignado" : {
			"diaMesVencInicial" : "1900-01-01",
			"diaMesVencFinal" : "1900-01-15",
			"diaMesVencInterface" : "1900-01-25",
			"diaMesVencimento" : "1900-01-20",
			"qtdeVencimentos" : 1
		  }
		},{
		  "convenioCredito" : {
			"dataContratacao" : "2019-04-23T00:00:00"
		  },
		  "configuracaoCredito" : {
			"tratamendoDiaNaoUtil" : {
			  "codigo" : 3
			}
		  },
		  "consulta" : {
			"tipoContagemDias" : {
			  "codigo" : 2
			}
		  },
		  "parametroConsignado" : {
			"diaMesVencInicial" : "1900-01-01",
			"diaMesVencFinal" : "1900-01-15",
			"diaMesVencInterface" : "1900-01-25",
			"diaMesVencimento" : "1900-01-20",
			"qtdeVencimentos" : 1
		  }
		} ]
	  }
	}';
	
	return envServico($url, "POST", $arrayHeader, $data);
}

function envServico($url, $method, $arrayHeader, $data) {
	$ch = curl_init($url);                                                                      
	curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_HTTPHEADER, $arrayHeader);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $data);	
	$result = curl_exec($ch);	
	$GLOBALS["httpcode"] = curl_getinfo($ch, CURLINFO_HTTP_CODE);
	curl_close($ch);
	//echo '<pre>'.htmlentities($result).'</pre>';
	$result = json_decode($result);
	if (isset($result->sistemaTransacao->dataHoraRetorno)){
		if($result->sistemaTransacao->dataHoraRetorno != ""){
			return $result->sistemaTransacao->dataHoraRetorno;
		}
	}
	
	return "ERRO";

}