//Bibliotecas
#Include 'Protheus.ch'
#Include "TOPCONN.ch"
#Include 'FWMVCDef.ch'

//----------------------------------------------------------------------
/*/{PROTHEUS.DOC} MLJF06
FUNÇÃO MLJF06 - Tela para consulta de Vale Presente
@VERSION PROTHEUS 12
@SINCE 01/10/2024
/*/
//----------------------------------------------------------------------

User Function MLJF06()
  Local aButtons := {{.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.T.,"Fechar"},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,NIl}}

  Private oTabTMP1  := FWTemporaryTable():New("T1")
  Private oTabTMP2  := FWTemporaryTable():New("T2")
  Private aFields1 := {}
  Private aFields2 := {}

  aAdd(aFields1,{"T1_CLIENT","C", FWTamSX3("A1_CGC")[1]    , FWTamSX3("A1_CGC")[2]    , "Código ou CNPJ/CPF" ,"","XSA1",Nil})
  aAdd(aFields1,{"T1_NOMCLI","C", FWTamSX3("A1_NOME")[1]   , FWTamSX3("A1_NOME")[2]   , "Nome Cliente"       ,"","",Nil    })
  aAdd(aFields1,{"T1_TIPO"  ,"C", 1                        , 0                        , "Tipo"               ,"","","C=Credito Correntista;D=Credito Devolucao" })
  
  oTabTMP1:SetFields(aFields1)
  oTabTMP1:AddIndex("01", {"T1_CLIENT"})
  oTabTMP1:Create()

  aAdd(aFields2,{"T2_LEGEND"  ,"C", 50                        , 0                         , "Status"        ,"@BMP","",Nil})
  aAdd(aFields2,{"T2_FILIAL"  ,"C", FWTamSX3("E1_FILIAL")[1]  , FWTamSX3("E1_FILIAL")[2]  , "Cod. Filial"   ,"","",Nil})
  aAdd(aFields2,{"T2_NOMFIL"  ,"C", 50                        , 0                         , "Nome Filial"   ,"","",Nil})
  aAdd(aFields2,{"T2_PREFIXO" ,"C", FWTamSX3("E1_PREFIXO")[1] , FWTamSX3("E1_PREFIXO")[2] , "Prefixo"       ,"","",Nil})
  aAdd(aFields2,{"T2_NUM"     ,"C", FWTamSX3("E1_NUM")[1]     , FWTamSX3("E1_NUM")[2]     , "Num. Credito"  ,"","",Nil})
  aAdd(aFields2,{"T2_VALOR"   ,"N", FWTamSX3("E1_VALOR")[1]   , FWTamSX3("E1_VALOR")[2]   , "Valor"         ,PesqPict("SE1", "E1_VALOR"),"",Nil})
  aAdd(aFields2,{"T2_SALDO"   ,"N", FWTamSX3("E1_SALDO")[1]   , FWTamSX3("E1_SALDO")[2]   , "Saldo"         ,PesqPict("SE1", "E1_SALDO"),"",Nil})
  aAdd(aFields2,{"T2_EMISSAO" ,"D", FWTamSX3("E1_EMISSAO")[1] , FWTamSX3("E1_EMISSAO")[2] , "Emissao"       ,"","",Nil})
  aAdd(aFields2,{"T2_VENCREA" ,"D", FWTamSX3("E1_VENCREA")[1] , FWTamSX3("E1_VENCREA")[2] , "Validade"      ,"","",Nil})
  aAdd(aFields2,{"T2_CODCLI"  ,"C", FWTamSX3("A1_COD")[1]     , FWTamSX3("A1_COD")[2]     , "Cod. Cliente"  ,"","",Nil})
  aAdd(aFields2,{"T2_NOMCLI"  ,"C", FWTamSX3("A1_NOME")[1]    , FWTamSX3("A1_NOME")[2]    , "Nome Cliente"  ,"","",Nil})
  
  oTabTMP2:SetFields(aFields2)
  oTabTMP2:AddIndex("01", {"T2_FILIAL","T2_PREFIXO","T2_NUM"})
  oTabTMP2:Create()

  FWExecView("",'MLJF06',4,,{||.T.},,,aButtons)
  
  oTabTMP1:Delete()
  oTabTMP2:Delete()

Return

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
  Local oModel
  Local oStrTMP1 := fnM01TMP('1')
  Local oStrTMP2 := fnM01TMP('2')

  oStrTMP1:AddTrigger("T1_CLIENT", "T1_NOMCLI" ,{||.T.},{|oStrTMP1| fBusNCli(oStrTMP1) })
  oStrTMP1:AddTrigger("T1_CLIENT", "T1_TIPO"   ,{||.T.},{|| "C" })

  oModel := MPFormModel():New('MLJF06M',/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
  oModel:AddFields('T1MASTER',/*cOwner*/,oStrTMP1,/*bPre*/,/*bPos*/,/*bLoad*/)
  oModel:AddGrid('T2DETAIL', 'T1MASTER', oStrTMP2,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)

  oModel:SetPrimaryKey({})
  oModel:SetDescription("Historico Cliente")
  oModel:GetModel('T1MASTER'):SetDescription('Dados do Cliente')
  oModel:GetModel('T2DETAIL'):SetDescription('Creditos Correntista')

  oModel:AddCalc( 'CALCTMP2',  'T1MASTER', 'T2DETAIL', 'T2_VALOR', 'VALOR', 'SUM' , { || .T. },,'Valor')
  oModel:AddCalc( 'CALCTMP2',  'T1MASTER', 'T2DETAIL', 'T2_SALDO', 'SALDO', 'SUM' , { || .T. },,'Saldo')

  oStrTMP1:SetProperty("T1_NOMCLI", MODEL_FIELD_WHEN, {||.F.})

Return oModel

//-----------------------------------------
/*/ fnM01TMP
  Estrutura dos Parâmetros.								  
/*/
//-----------------------------------------
Static Function fnM01TMP(cTab)
  Local oStruct := FWFormModelStruct():New()
  Local cField := "aFields"+cTab
  Local nId  

  oStruct:AddTable("T"+cTab,{},"Tabela "+cTab)

  For nId := 1 To Len(&(cField))

    oStruct:AddField(&(cField)[nId][5]; 
                    ,&(cField)[nId][5]; 
                    ,&(cField)[nId][1]; 
                    ,&(cField)[nId][2];
                    ,&(cField)[nId][3];
                    ,&(cField)[nId][4];
                    ,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  Next nId

Return oStruct

//-----------------------------------------
/*/ fBusNCli
  Retorna o Nome do Cliente.								  
/*/
//-----------------------------------------
Static Function fBusNCli(oStrTMP1)
  Local cRet := ""
  Local _cAlias := GetNextAlias()
  
  cQry := " SELECT SA1.A1_NOME "
  cQry += " FROM "+RetSQLName("SA1")+" SA1 "
  cQry += " WHERE SA1.D_E_L_E_T_ <> '*' "
  cQry += " 	AND ( SA1.A1_COD = '"+AllTrim(oStrTMP1:GetValue("T1_CLIENT"))+"' OR SA1.A1_CGC = '"+AllTrim(oStrTMP1:GetValue("T1_CLIENT"))+"' ) "
  cQry := ChangeQuery(cQry)
  TCQuery cQry ALIAS (_cAlias) NEW
  
  IF !(_cAlias)->(EOF())
      cRet := Alltrim((_cAlias)->A1_NOME)
  Endif

  (_cAlias)->(DBCloseArea())

Return cRet

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
Local oView 
Local oModel   := FWLoadModel('MLJF06')
Local oStrTMP1 := fnV01TMP('1')
Local oStrTMP2 := fnV01TMP('2')
Local oStrCalc := FWCalcStruct(oModel:GetModel('CALCTMP2'))

  oView := FWFormView():New()
  oView:SetModel(oModel)
  oView:SetProgressBar(.T.)
  oView:AddField('VIEW_TMP',oStrTMP1,'T1MASTER')
  oView:AddGrid('VIEW_TMP2',oStrTMP2,'T2DETAIL')
  oView:AddField('VIEW_CALC',oStrCalc,'CALCTMP2')
    
  oView:CreateHorizontalBox('CABEC',020)
  oView:CreateHorizontalBox('GRID',070)
  oView:CreateHorizontalBox('CALC',010)
    
  oView:SetOwnerView('VIEW_TMP','CABEC')
  oView:SetOwnerView('VIEW_TMP2','GRID')
  oView:SetOwnerView('VIEW_CALC','CALC')
    
  oView:EnableTitleView('VIEW_TMP','Cliente')
  oView:EnableTitleView('VIEW_TMP2','Créditos Correntista')
    
  oView:SetViewProperty("VIEW_TMP2", "SETCSS", {"QTableView { selection-background-color: #CD853F; selection-color: #000000; }"} )
  oView:SetViewProperty("VIEW_TMP2", "GRIDSEEK",   {.T.})
  oView:SetViewProperty("VIEW_TMP2", "GRIDFILTER", {.T.})

  oView:AddUserButton( 'Consultar', 'NOTE',;
                       {|oView| FWMsgRun(, {|| fConsulta(oView) }, "Aguarde...", "Consultando Créditos")},;
                        /*cToolTip  | Comentário do botão*/,;
                        /*nShortCut | Codigo da Tecla para criação de Tecla de Atalho*/,;
                        /*aOptions  | */,;
                        /*lShowBar */ .T.)
    
  oView:AddUserButton( 'Orçamento', 'NOTE',;
                       {|| FWMsgRun(, {|| fOrcamento() }, "Aguarde...", "Abrindo Orçamento") },;
                        /*cToolTip  | Comentário do botão*/,;
                        /*nShortCut | Codigo da Tecla para criação de Tecla de Atalho*/,;
                        /*aOptions  | */,;
                        /*lShowBar */ .T.)
    
  oView:SetViewAction("ASKONCANCELSHOW",{|| .F.}) // Tirar a mensagem do final "Há Alterações não..."

Return oView

//-------------------------------------------------------------------
/*/ Função fnV01TMP()
  Estrutura do cabeçalho (View)	
/*/
//-------------------------------------------------------------------
Static Function fnV01TMP(cTab)
  Local oViewTMP := FWFormViewStruct():New() 
  Local cField := "aFields"+cTab
  Local cCampLib := "T1_CLIENT/T1_TIPO"
  Local lLibEdit := .F.
  Local aCombo := {}
  Local nId
  
  For nId := 1 To Len(&(cField))

    lLibEdit := IIF(&(cField)[nId][1] $ (cCampLib),.T.,.F.)
    If ValType(&(cField)[nId][8]) == "C"
      aCombo := StrTokArr(&(cField)[nId][8],";")
    EndIF 

    oViewTMP:AddField(&(cField)[nId][1],;       // 01 = Nome do Campo
                        StrZero(nId,2),;        // 02 = Ordem
                        &(cField)[nId][5],;     // 03 = Título do campo
                        &(cField)[nId][5],;     // 04 = Descrição do campo
                        Nil,;                   // 05 = Array com Help
                        &(cField)[nId][2],;     // 06 = Tipo do campo
                        &(cField)[nId][6],;     // 07 = Picture
                        Nil,;                   // 08 = Bloco de PictTre Var
                        &(cField)[nId][7],;     // 09 = Consulta F3
                        lLibEdit,;              // 10 = Indica se o campo é alterável
                        Nil,;                   // 11 = Pasta do Campo
                        Nil,;                   // 12 = Agrupamnento do campo
                        aCombo,;                // 13 = Lista de valores permitido do campo (Combo)
                        Nil,;                   // 14 = Tamanho máximo da opção do combo
                        Nil,;                   // 15 = Inicializador de Browse
                        .F.,;                   // 16 = Indica se o campo é virtual (.T. ou .F.)
                        Nil,;                   // 17 = Picture Variavel
                        Nil)                    // 18 = Indica pulo de linha após o campo (.T. ou .F.)
  Next nId

Return oViewTMP

/*---------------------------------------------------------------------*
 | Func:  fConsulta                                                    |
 | Desc:  Realiza consulta na TMP2 para trazer os Vales Créditos        |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fConsulta(oView)
    Local oModel := FWModelActive() 
    Local oModelTMP1 := oModel:GetModel("T1MASTER")
    Local oModelTMP2 := oModel:GetModel("T2DETAIL")
    Local _cAlias    := GetNextAlias()
    Local cQry       := ""
    Local nLinQry    := 0

    oModel:GetModel('CALCTMP2'):LoadValue("VALOR", 0)
    oModel:GetModel('CALCTMP2'):LoadValue("SALDO", 0)

    oView:Refresh()

    cQry := " SELECT * "
    cQry += " FROM "+RetSQLName("SE1")+" SE1 "
    cQry += " INNER JOIN SYS_COMPANY SM0 ON SM0.M0_CODFIL = SE1.E1_FILIAL "
    cQry += " INNER JOIN "+RetSQLName("SA1")+" SA1 ON SA1.A1_COD = SE1.E1_CLIENTE "
    cQry += " WHERE SE1.D_E_L_E_T_ <> '*' "
    If oModelTMP1:GetValue("T1_TIPO") == "C" 
      cQry += " 	AND SE1.E1_ORIGEM = 'STIPOSMA' "
    Else
      cQry += " 	AND SE1.E1_ORIGEM <> 'STIPOSMA' "
    EndIF 
    cQry += " 	AND SE1.E1_TIPO   = 'NCC' "
    cQry += " 	AND SM0.D_E_L_E_T_ <> '*' "
    cQry += " 	AND SA1.D_E_L_E_T_ <> '*' "
    cQry += " 	AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
    cQry += " 	AND ( SA1.A1_COD = '"+AllTrim(oModelTMP1:GetValue("T1_CLIENT"))+"' OR SA1.A1_CGC = '"+AllTrim(oModelTMP1:GetValue("T1_CLIENT"))+"' ) "
    cQry := ChangeQuery(cQry)
    TCQuery cQry ALIAS (_cAlias) NEW

    oModelTMP2:ClearData(.T.)

    While (_cAlias)->(!Eof())
        
        nLinQry++
        IF nLinQry > 1
            oModelTMP2:AddLine()
        EndIF 

        Do Case
          Case (_cAlias)->E1_VALOR == (_cAlias)->E1_SALDO
            oModelTMP2:LoadValue("T2_LEGEND", "BR_VERDE"    )
          Case Empty((_cAlias)->E1_SALDO)
            oModelTMP2:LoadValue("T2_LEGEND", "BR_VERMELHO" )
          Case (_cAlias)->E1_SALDO < (_cAlias)->E1_VALOR
            oModelTMP2:LoadValue("T2_LEGEND", "BR_AZUL"     )
        EndCase

        oModelTMP2:LoadValue("T2_FILIAL"  , (_cAlias)->E1_FILIAL        )
        oModelTMP2:LoadValue("T2_NOMFIL"  , (_cAlias)->M0_FILIAL        )
        oModelTMP2:LoadValue("T2_PREFIXO" , (_cAlias)->E1_PREFIXO       )
        oModelTMP2:LoadValue("T2_NUM"     , (_cAlias)->E1_NUM           )
        oModelTMP2:LoadValue("T2_VALOR"   , (_cAlias)->E1_VALOR         )
        oModelTMP2:LoadValue("T2_SALDO"   , (_cAlias)->E1_SALDO         )
        oModelTMP2:LoadValue("T2_EMISSAO" , STOD((_cAlias)->E1_EMISSAO) )
        oModelTMP2:LoadValue("T2_VENCREA" , STOD((_cAlias)->E1_VENCREA) )
        oModelTMP2:LoadValue("T2_CODCLI"  , (_cAlias)->A1_COD           )
        oModelTMP2:LoadValue("T2_NOMCLI"  , (_cAlias)->A1_NOME          )
        
        oView:Refresh('VIEW_TMP2')
    
    (_cAlias)->(DBSkip()) 
    EndDo
    
    (_cAlias)->(DBCloseArea())

    oModelTMP2:GoLine(1)
    oView:Refresh('VIEW_TMP2')
    oView:SetNoDeleteLine('VIEW_TMP2')
    //oView:SetNoInsertLine('VIEW_TMP2')
    
Return

/*---------------------------------------------------------------------*
 | Func:  fOrcamento                                                   |
 | Desc:  Visualiza o Orcamento corresponde ao Vale Presente           |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fOrcamento()
  Local aArea    := FWGetArea()
  Local aAreaSL1 := SL1->(FWGetArea())
  Local oModel := FWModelActive() 
  Local oModelTMP1 := oModel:GetModel("T1MASTER")
  Local cChave := ""

  IF oModelTMP1:GetValue("T1_TIPO") == "C" 
    cChave := T2->T2_PREFIXO + T2->T2_NUM
  Else
    DBSelectArea("SD1")
    SD1->(DBSetOrder(1))
    IF SD1->(MSSeek(xFilial("SD1") + T2->T2_NUM + T2->T2_PREFIXO ))
      cChave := SD1->D1_SERIORI + SD1->D1_NFORI
    EndIF 
  EndIF 

  If !Empty(cChave)
    DBSelectArea("SL1")
    SL1->(DBSetOrder(2))   
    IF SL1->(MSSeek(xFilial("SL1") + cChave ))
      Lj7Venda("SL1", Recno(), 2)
    Else
      SL1->(DBSetOrder(11))
      IF SL1->(MSSeek(xFilial("SL1") + cChave ))
        Lj7Venda("SL1", Recno(), 2)
      Else
        FWAlertInfo("Nenhum orçamento encontrado para esse crédito.","Consulta Orçamento")
      EndIF
    EndIF
  Else
    FWAlertInfo("Nenhum orçamento encontrado para esse crédito.","Consulta Orçamento")
  EndIF

  FWRestArea(aAreaSL1)
  FWRestArea(aArea)

Return
