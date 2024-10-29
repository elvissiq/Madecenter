#INCLUDE "PROTHEUS.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "PARMTYPE.CH"
//------------------------------------------------------------------------------
/*{Protheus.doc} STFinishSale
Possibilitar a gravação de arquivos complementares. O ponto de entrada é 
executado após o fechamento do cupom e da venda.
@param   	PARAMIXB
@author     Elvis Siqueira
@version    P12
@since      29/10/2024
@return     lRet
/*/
//------------------------------------------------------------------------------
User Function STFinishSale()
	Local aArea    := FWGetArea()
	Local cNumOrc  := PARAMIXB[2]

	DBSelectArea("SL1")
	IF SL1->(MSSeek(xFilial('SL1') + cNumOrc))
		
		DBSelectArea("SA1")
		
		IF SA1->(MSSeek(xFilial('SA1') + SL1->L1_CLIENTE + SL1->L1_LOJA))
			RecLock("SL1",.F.)
				SL1->L1_NOMCIL := Pad(AllTrim(SA1->A1_NOME), FWTamSX3("L1_NOMCIL")[1])
			SL1->(MSUnlock())
		EndIF
	
	EndIf

	FWRestArea(aArea)

Return
