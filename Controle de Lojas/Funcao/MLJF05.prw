#include "Protheus.CH"
#include "FWMVCDef.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{PROTHEUS.DOC} MLJF05
FUNÇÃO MLJF05- Cadastro de Maceneiro
@OWNER Madecenter
@VERSION PROTHEUS 12
@SINCE 12/09/2024
/*/
User Function MLJF05()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription("Maceneiro")
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetMenuDef('MLJF05')
	oBrowse:SetAlias('ZZ1')
	oBrowse:DisableDetails()
	oBrowse:SetFixedBrowse(.T.)
	oBrowse:Activate()

Return oBrowse

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRot := {}
	
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.MLJF05' OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.MLJF05' OPERATION 3 ACCESS 0
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.MLJF05' OPERATION 4 ACCESS 0
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.MLJF05' OPERATION 5 ACCESS 0

Return aRot
//-------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel    := Nil
	Local oStPai   	:= FWFormStruct( 1, 'ZZ1')

	oModel := MPFormModel():New("MLJF05MV" , , , )
	oModel:SetDescription(OemtoAnsi("Motivos de Baixas") )
	oModel:AddFields('ZZ1MASTER',/*cOwner*/,oStPai)
	oModel:SetPrimaryKey( {"ZZ1_FILIAL", "ZZ1_COD"})

Return oModel
//-----------------------------------------------------------------------------------------------------------------------------
//
Static Function ViewDef()
	Local oView     := Nil
	Local oModel    := FWLoadModel('MLJF05')
	Local oStPai   	:= FWFormStruct( 2, 'ZZ1')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_CAB',oStPai,'SZZMASTER')
	oView:CreateHorizontalBox('CABEC',100)
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:EnableTitleView('VIEW_CAB','Maceneiro')

Return oView
