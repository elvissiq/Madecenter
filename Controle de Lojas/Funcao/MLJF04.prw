#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include "TOPCONN.ch"
#Include 'FWMVCDef.ch'
#Include "FWPrintSetup.ch" 

//-------------------------------------------------------------------------------
/*/{PROTHEUS.DOC} MLJF04
Tela para selecionar o tipo de impressão de orçamento
@VERSION PROTHEUS 12
@SINCE 30/08/2024
/*/
//-------------------------------------------------------------------------------

User Function MLJF04()
  Local oButon   := Nil
  Local oPanel   := Nil
  Local oDialog  := Nil
  Local oFontBtn := TFont():New("Arial", , -14)

  oDialog := FWDialogModal():New()
  oDialog:SetBackground( .T. ) 
  oDialog:SetTitle( 'Imprimir Orçamento' )
  oDialog:SetSize( 100, 150 )
  oDialog:EnableFormBar( .T. )
  oDialog:SetCloseButton( .T. )
  oDialog:SetEscClose( .T. )
  oDialog:CreateDialog()
  oDialog:CreateFormBar()
  oDialog:addCloseButton(Nil, "Fechar")
  oPanel := oDialog:GetPanelMain()
  oButon := TButton():New(015, 003, "Layout Completo", oPanel, {|| U_zROrcComp() }, 065, 020, , oFontBtn, , .T., , , , , , )
  oButon := TButton():New(015, 078, "Layout Simples" , oPanel, {|| U_zROrcSimp() }, 065, 020, , oFontBtn, , .T., , , , , , )
  oDialog:Activate()

Return
