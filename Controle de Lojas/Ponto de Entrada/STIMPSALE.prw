#INCLUDE "PROTHEUS.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "PARMTYPE.CH"
//-----------------------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc} STIMPSALE
O Ponto de Entrada � executado no momento da importa��o do or�amento no TOTVS PDV. 
Sua fun��o � receber as informa��es do or�amento que ser�o importadas, e retornar se o or�amento pode ou n�o ser importado.

Tamb�m pode ser utilizado para realizar a grava��o de campos importados da retaguarda que n�o s�o gravados pelo padr�o. 

@param   	PARAMIXB
@author     Elvis Siqueira
@version    P12
@since      17/12/2024
@return     lRet
/*/
//-----------------------------------------------------------------------------------------------------------------------------------
User Function STIMPSALE()
	Local aArea := FWGetArea()
	Local lRet  := .T.
	//Local aOrcSL1 := PARAMIXB[1] // Dados do SL1 importado
	//Local aOrcSL2 := PARAMIXB[2] // Dados do SL2 importado
	//Local aOrcSL4 := PARAMIXB[3] // Dados do SL4 importado

	Public nL1Credit := 0

	nL1Credit := SL1->L1_CREDITO

	FWRestArea(aArea)

Return lRet
