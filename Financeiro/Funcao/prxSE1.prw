#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Tbiconn.ch"

/*/{Protheus.doc} prxSE1
Proximo numero da SE1
@type function
@author Elvis Siqueira
@since 09/09/2024
/*/

User Function prxSE1(pPrefixo) As Character
	Local aArea  		As Array
	Local aAreaSE1 		As Array
	Local cQrySE1		As Character
	Local cSeqSE1		As Character
	Local cTRBSE1		As Character

	aArea  		:= FWGetArea()
	cTRBSE1		:= GetNextAlias()
	cSeqSE1 	:= StrZero(1, FWTamSX3('E1_NUM')[1])
	aAreaSE1 	:= SE1->(FWGetArea())

	cQrySE1 := " SELECT MAX(E1_NUM) MAXSE1"
	cQrySE1 += " FROM " + RetSqlName("SE1")
	cQrySE1 += " WHERE D_E_L_E_T_ <> '*'"
	cQrySE1 += " AND E1_PREFIXO = '" + AllTrim(pPrefixo) + "' "

	cQrySE1 := ChangeQuery(cQrySE1)

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQrySE1), cTRBSE1)

	If (cTRBSE1)->(!Eof()) .And. !Empty((cTRBSE1)->(MAXSE1))
		cSeqSE1 := Soma1((cTRBSE1)->(MAXSE1))
	EndIf

	(cTRBSE1)->(DbCloseArea())

    FWRestArea(aAreaSE1)
	FWRestArea(aArea)
	
Return cSeqSE1