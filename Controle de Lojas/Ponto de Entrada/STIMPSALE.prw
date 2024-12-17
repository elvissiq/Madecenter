#INCLUDE "PROTHEUS.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "PARMTYPE.CH"
//-----------------------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc} STIMPSALE
O Ponto de Entrada é executado no momento da importação do orçamento no TOTVS PDV. 
Sua função é receber as informações do orçamento que serão importadas, e retornar se o orçamento pode ou não ser importado.

Também pode ser utilizado para realizar a gravação de campos importados da retaguarda que não são gravados pelo padrão. 

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
