<?
/*!
 * FONTE        : class_webservice_cabal.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Maio/2014
 * OBJETIVO     : Classe responsavel pela comunicacao com o Webservice da Cabal
 *
 *-----------------------------------------------------------------------------------------
 * ATENCAO: CUIDADO AO LIBERAR O FONTE, POIS CONTEM O ENDERECO DE TESTE.
 *	    	ANTES DE LIBERAR O FONTE, ALTERAR PARA PEGAR O ENDERECO DE PRODUCAO.
 *			QUALQUER DUVIDA FALAR COM IRLAN/JAMES/OSCAR
 *-----------------------------------------------------------------------------------------
 *
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
class WebServiceCabal{

	private $SoapClient;
	private $retorno;
	
	public function __destruct(){
		unset($this->SoapClient);
	}
	
	private function newSoapClient(){
		if (!isset($this->SoapClient)){
			try{
				/*
					Endereço de Produção:    https://cabalprod.cecred.coop.br/netservices/http/Credito/WSTrocaSenhaCartaoChip
					Endereço de Homologação: https://cabalhomol.cecred.coop.br/netservices/http/Credito/WSTrocaSenhaCartaoChip											 
				*/
				$this->SoapClient = new SoapClient("https://cabalprod.cecred.coop.br/netservices/http/Credito/WSTrocaSenhaCartaoChip?wsdl");
				$this->SoapClient->__setLocation("https://cabalprod.cecred.coop.br/netservices/http/Credito/WSTrocaSenhaCartaoChip");
			}catch(SoapFault $e){
				exibirErro('error',"N&atilde;o foi poss&iacute;vel estabelecer conex&atilde;o.",'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
				exit();
			}
		}
		return $this->SoapClient;
	}
	
	protected function call($sNomeMetodo,$sNomeRetorno,Array $aParametros){
		$oSoapCliente = $this->newSoapClient();
		try{
			$retorno = $oSoapCliente->$sNomeMetodo(array($sNomeRetorno=>$aParametros));
			if (is_string($retorno)){
				exibirErro('error',"Erro ao retornar o valor. M&eacute;todo: '".$sNomeMetodo."'",'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);							
				exit();				
			}else{
				$this->setRetorno($retorno->return);
			}
		}catch(SoapFault $e){
			exibirErro('error',"N&atilde;o foi poss&iacute;vel estabelecer conex&atilde;o. M&eacute;todo: '".$sNomeMetodo."'",'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
			exit();
		}
	}
	
	protected function setRetorno($retorno){
		$this->retorno = $retorno;	
	}
	
	public function getRetorno(){
		return $this->retorno;
	}
}
?>