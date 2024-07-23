#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE2.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"  
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥SLDANALI  ∫Autor  ≥				     ∫ Data ≥  03/05/2008 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Programa para consultar saldo em estoque.                  ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ WMS                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function SLDANALI(cVarCod,cVarDes,cVarLoc,dVarDtU,dVarDtI,dVarDtF)           
Local oDlgMain    
Local aArea          := GetArea()
Private cPict        := PesqPict('SB2','B2_QATU')
Private cPict2UM     := PesqPict('SB2','B2_QTSEGUM')
Private cPictD5      := PesqPict('SD5','D5_QUANT')
Private cPictDB      := PesqPict('SDB','DB_QUANT')
Private cPictB1      := PesqPict('SB1','B1_CONV')
Private cLocal       := If(cVarLoc==Nil,cLocal := Space(02),cVarLoc)                             
Private dDtProces    := dDataBase
Private dUltFech     := If(dVarDtU==Nil,dUltFech := CTOD("  /  /  "),dVarDtU)
Private dDataI		 := If(dVarDtI==Nil,dDataI := CTOD("  /  /  "),dVarDtI)
private dDataF		 := If(dVarDtF==Nil,dDataF := CTOD("  /  /  "),dVarDtF)
Private nSldKarLocal := nSldKarLote := nSldKarEnde := 0
Private cProduto     := If(cVarCod==Nil,cProduto := Space(15),cVarCod)
Private cDescr       := If(cVarDes==Nil,cDescr := Space(40),cVarDes)
Private cCrlLot      := ""        
Private cCrlEnd      := ""        
Private c1UM         := ""
Private c2UM         := ""
Private nFatConv     := 0
Private cTipConv     := ""
Private cZona        := ""
Private aBoxSBE   := RetSx3Box(Posicione('SX3',2,'BE_STATUS','X3CBox()'),,,1)
Private aBoxDC3   := RetSx3Box(Posicione('SX3',2,'DC3_EMBDES','X3CBox()'),,,1)
Private aBoxDCF   := RetSx3Box(Posicione('SX3',2,'DCF_STSERV','X3CBox()'),,,1)
Private nDispo := nAtual := nReser := nEmpen := nEnder := 0
Private nCredi := nEstoq := nLiber := nEmpPe := 0
Private nBloqu := nProdu := 0
Private aDetSB8      := {}
Private aDetSBF      := {}
Private aDetSDA      := {}
Private aKarLocal    := {}
Private aKarLote     := {}
Private aKarEnde     := {}                                               
Private aSeqAbast    := {}                                               
Private aZonas       := {}                                               
Private aPedLib      := {}                                               
Private aLotBloq     := {}
Private aEmpenho     := {}
Private aOP          := {}
Private aEmpenOP     := {}
Private aServicos    := {}
Private aPickFixo    := {}
Private lNumLote := SuperGetMV('MV_LOTEUNI', .F., .F.) 

Aadd(aDetSB8   ,{CTOD("  /  /  "),Space(10),Space(06),CTOD("  /  /  "),0,0,0,0,0})
Aadd(aDetSBF   ,{Space(15),Space(10),Space(6),CTOD("  /  /  "),0,0,Space(01),Space(01),Space(01),0,0,0})
AAdd(aSeqAbast ,{Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),0})
AAdd(aPickFixo ,{Space(15),Space(06),Space(06)})
AAdd(aZonas    ,{Space(01),Space(01),Space(01)})
AAdd(aPedLib   ,{Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01)})
AAdd(aLotBloq  ,{Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01)})
AAdd(aEmpenho  ,{Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01)})
Aadd(aEmpenOP,  {CTOD(" /  /  "),Space(13),Space(03),Space(10),0,0,0})
Aadd(aOP,       {CTOD(" /  /  "),Space(13),CTOD(" /  /  "),CTOD(" /  /  "),0,0,0})
Aadd(aDetSDA   ,{CTOD("  /  /  "),Space(10),0,0,0,Space(03),Space(06),Space(03),Space(06),Space(02)})
AAdd(aServicos ,{Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),0,Space(01),Space(01),Space(01)})
AAdd(aKarLocal ,{Space(03),Space(08),Space(03),Space(03),Space(06),Space(01),Space(01),Space(06)})
AAdd(aKarLote  ,{Space(03),Space(08),Space(03),Space(06),Space(06),Space(08),Space(08),Space(01),Space(01),Space(30),Space(01)})
AAdd(aKarEnde  ,{Space(03),Space(08),Space(03),Space(06),Space(15),Space(01),Space(01),Space(01),Space(06),Space(01)})

DEFINE MSDIALOG oDlgMain TITLE "Consulta WMS x Saldos"  OF oMainWnd PIXEL FROM 040,040 TO 650,1091
DEFINE FONT oBold   NAME "Arial" SIZE 0, -12 BOLD
DEFINE FONT oBold2  NAME "Arial" SIZE 0, -40 BOLD

DBSelectArea("SB1")

@ 060,006 FOLDER oFolder OF oDlgMain PROMPT "Saldo","Lote","EndereÁo","Seq.Abast.","Zona Alter.","Ped.Liber.","Lote Bloq.","Empenhos","EndereÁar","ServiÁo","Ord.Prod.","Emp.OP","Kardex","Kardex Lote","Kardex Ender." PIXEL SIZE 515,241
//                                           01       02     03         04           05            06           07          08         09            10        11             12           13            14             15
@ 014,010 SAY "Produto"                                 SIZE 040,10 PIXEL OF oDlgMain FONT oBold 
@ 010,040 MSGET oVar   VAR cProduto Picture "@!"        SIZE 060,10 PIXEL OF oDlgMain F3 "SB1" VALID(GetDescProd())
@ 010,105 MSGET oVar   VAR cDescr   Picture "@!"        SIZE 176,10 PIXEL OF oDlgMain When .F.
@ 032,010 SAY "Local"                                   SIZE 040,10 PIXEL OF oDlgMain FONT oBold 
@ 028,040 MSGET oVar   VAR cLocal Picture "!!"          SIZE 010,10 PIXEL OF oDlgMain VALID(GetDatas()) 
@ 049,010 SAY "Limite"                                  SIZE 070,10 PIXEL OF oDlgMain FONT oBold 
@ 045,040 MSGET oVar   VAR dDtProces Picture "99/99/99" SIZE 040,10 PIXEL OF oDlgMain When .F.

@ 032,095 SAY "1 UM"                                    SIZE 070,10 PIXEL OF oDlgMain FONT oBold
@ 028,114 MSGET oVar   VAR c1UM      Picture "@!"       SIZE 015,10 PIXEL OF oDlgMain When .F.
@ 032,150 SAY "2 UM"                                    SIZE 070,10 PIXEL OF oDlgMain FONT oBold
@ 028,190 MSGET oVar   VAR c2UM      Picture "@!"       SIZE 015,10 PIXEL OF oDlgMain When .F.
@ 032,210 SAY "Fat.Conv."                               SIZE 070,10 PIXEL OF oDlgMain FONT oBold
@ 028,240 MSGET oVar   VAR cTipConv  Picture "!"        SIZE 008,10 PIXEL OF oDlgMain When .F.
@ 028,251 MSGET oVar   VAR nFatConv  Picture cPictB1    SIZE 030,10 PIXEL OF oDlgMain When .F.

@ 014,300 SAY "Ultimo Fechamento"                       SIZE 070,10 PIXEL OF oDlgMain FONT oBold 
@ 010,365 MSGET oVar   VAR dUltFech  Picture "99/99/99" SIZE 040,10 PIXEL OF oDlgMain When .F.
@ 029,300 SAY "Data Inicial"                            SIZE 070,10 PIXEL OF oDlgMain FONT oBold 
@ 025,365 MSGET oVar   VAR dDataI    Picture "99/99/99" SIZE 040,10 PIXEL OF oDlgMain When .F.
@ 044,300 SAY "Data Final"                              SIZE 070,10 PIXEL OF oDlgMain FONT oBold 
@ 040,365 MSGET oVar   VAR dDataF    Picture "99/99/99" SIZE 040,10 PIXEL OF oDlgMain When .F.

@ 049,095 SAY "Lote"                                    SIZE 040,10 PIXEL OF oDlgMain FONT oBold 
@ 045,114 MSGET oVar   VAR cCrlLot   Picture "@!"       SIZE 025,10 PIXEL OF oDlgMain When .F.
@ 049,150 SAY "LocalizaÁ„o"                             SIZE 040,10 PIXEL OF oDlgMain FONT oBold 
@ 045,190 MSGET oVar   VAR cCrlEnd   Picture "@!"       SIZE 015,10 PIXEL OF oDlgMain When .F.
@ 049,210 SAY "Zona"                                    SIZE 040,10 PIXEL OF oDlgMain FONT oBold 
@ 045,240 MSGET oVar   VAR cZona     Picture "@!"       SIZE 041,10 PIXEL OF oDlgMain When .F.

@ 022,015 TO 128, 120 PROMPT "Saldo do Produto"            PIXEL OF oFolder:aDialogs[1]
@ 034,020 SAY "DisponÌvel"                     SIZE 050,10 PIXEL OF oFolder:aDialogs[1] FONT oBold 
@ 030,065 MSGET oSB2  VAR nDispo Picture cPict SIZE 050,10 PIXEL OF oFolder:aDialogs[1] When .F. 
@ 054,020 SAY "Atual"                          SIZE 050,10 PIXEL OF oFolder:aDialogs[1] FONT oBold 
@ 050,065 MSGET oSB2  VAR nAtual Picture cPict SIZE 050,10 PIXEL OF oFolder:aDialogs[1] When .F.
@ 074,020 SAY "Reservado"                      SIZE 050,10 PIXEL OF oFolder:aDialogs[1] FONT oBold 
@ 070,065 MSGET oSB2  VAR nReser Picture cPict SIZE 050,10 PIXEL OF oFolder:aDialogs[1] When .F.
@ 094,020 SAY "Empenhado"                      SIZE 050,10 PIXEL OF oFolder:aDialogs[1] FONT oBold 
@ 090,065 MSGET oSB2  VAR nEmpen Picture cPict SIZE 050,10 PIXEL OF oFolder:aDialogs[1] When .F.
@ 114,020 SAY "A EndereÁar"                    SIZE 050,10 PIXEL OF oFolder:aDialogs[1] FONT oBold 
@ 110,065 MSGET oSB2  VAR nEnder Picture cPict SIZE 050,10 PIXEL OF oFolder:aDialogs[1] When .F.

@ 022,145 TO 128, 250 PROMPT "Pedidos Liberados"           PIXEL OF oFolder:aDialogs[1]
@ 034,150 SAY "Bloq.CrÈdito"                   SIZE 050,10 PIXEL OF oFolder:aDialogs[1] FONT oBold 
@ 030,195 MSGET oSB2  VAR nCredi Picture cPict SIZE 050,10 PIXEL OF oFolder:aDialogs[1] When .F. 
@ 054,150 SAY "Bloq.Estoque"                   SIZE 050,10 PIXEL OF oFolder:aDialogs[1] FONT oBold 
@ 050,195 MSGET oSB2  VAR nEstoq Picture cPict SIZE 050,10 PIXEL OF oFolder:aDialogs[1] When .F.
@ 074,150 SAY "Sem Empenho"                    SIZE 050,10 PIXEL OF oFolder:aDialogs[1] FONT oBold 
@ 070,195 MSGET oSB2  VAR nLiber Picture cPict SIZE 050,10 PIXEL OF oFolder:aDialogs[1] When .F.
@ 094,150 SAY "Com Empenho"                    SIZE 050,10 PIXEL OF oFolder:aDialogs[1] FONT oBold 
@ 090,195 MSGET oSB2  VAR nEmpPe Picture cPict SIZE 050,10 PIXEL OF oFolder:aDialogs[1] When .F.

@ 022,275 TO 128, 380 PROMPT "Empenhos"                    PIXEL OF oFolder:aDialogs[1]
@ 034,280 SAY "Bloqueado"                      SIZE 050,10 PIXEL OF oFolder:aDialogs[1] FONT oBold 
@ 030,325 MSGET oSB2  VAR nBloqu Picture cPict SIZE 050,10 PIXEL OF oFolder:aDialogs[1] When .F. 
@ 054,280 SAY "Ord.ProduÁ„o"                   SIZE 050,10 PIXEL OF oFolder:aDialogs[1] FONT oBold 
@ 050,325 MSGET oSB2  VAR nProdu Picture cPict SIZE 050,10 PIXEL OF oFolder:aDialogs[1] When .F.
@ 074,280 SAY "Pedido Venda"                   SIZE 050,10 PIXEL OF oFolder:aDialogs[1] FONT oBold 
@ 070,325 MSGET oSB2  VAR nEmpPe Picture cPict SIZE 050,10 PIXEL OF oFolder:aDialogs[1] When .F.

@ 135,015 TO 225, 380 PROMPT "Cadastros"                   PIXEL OF oFolder:aDialogs[1]
@ 145,020 BUTTON "Unitizador"           SIZE 70,10 ACTION (DLGA010()) PIXEL OF oFolder:aDialogs[1]
@ 160,020 BUTTON "Normas"               SIZE 70,10 ACTION (DLGA020()) PIXEL OF oFolder:aDialogs[1]
@ 175,020 BUTTON "Zonas de Armazenagem" SIZE 70,10 ACTION (DLGA040()) PIXEL OF oFolder:aDialogs[1]
@ 190,020 BUTTON "Estrutura FÌsica"     SIZE 70,10 ACTION (DLGA050()) PIXEL OF oFolder:aDialogs[1]
@ 205,020 BUTTON "FunÁıes"              SIZE 70,10 ACTION (GPEA030()) PIXEL OF oFolder:aDialogs[1]

@ 145,150 BUTTON "Recurso Humanos"      SIZE 70,10 ACTION (DLGA130()) PIXEL OF oFolder:aDialogs[1]
@ 160,150 BUTTON "Produtos"             SIZE 70,10 ACTION (MATA010()) PIXEL OF oFolder:aDialogs[1]
@ 175,150 BUTTON "Compl.Produtos"       SIZE 70,10 ACTION (MATA180()) PIXEL OF oFolder:aDialogs[1]
@ 190,150 BUTTON "ExceÁıes Atividades"  SIZE 70,10 ACTION (DLGA280()) PIXEL OF oFolder:aDialogs[1]
@ 205,150 BUTTON "EndereÁos"            SIZE 70,10 ACTION (MATA015()) PIXEL OF oFolder:aDialogs[1]

@ 145,280 BUTTON "Seq.Abastecimento"    SIZE 70,10 ACTION (DLGA030()) PIXEL OF oFolder:aDialogs[1]
@ 160,280 BUTTON "ProdutosxZonas Arm."  SIZE 70,10 ACTION (DLGA250()) PIXEL OF oFolder:aDialogs[1]
@ 175,280 BUTTON "TarefasxAtividades"   SIZE 70,10 ACTION (DLGA080()) PIXEL OF oFolder:aDialogs[1]
@ 190,280 BUTTON "ServiÁosxTarefas"     SIZE 70,10 ACTION (DLGA070()) PIXEL OF oFolder:aDialogs[1]
@ 205,280 BUTTON "Regra de ConvocaÁ„o"  SIZE 70,10 ACTION (WMSA350()) PIXEL OF oFolder:aDialogs[1]


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 02
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Saldo por Lote
@ 001,420 BUTTON "Pesquisar" SIZE 30,10 ACTION (fPesquisa("DETSB8",oDetSB8)) PIXEL OF oFolder:aDialogs[2]
@ 010,005 LISTBOX oDetSB8 Var cModelo FIELDS HEADER; 
     "Data","Lote","Sub-Lote","Validade","Saldo","Qtde.Original","Empenho","Qtde.2UM","Empenho 2UM" FIELDSIZES;
     30    ,40    ,30        ,30        ,40     ,40             ,35       ,40        ,40            SIZE 480,215;
     ON DBLCLICK () PIXEL OF oFolder:aDialogs[2]
   	 oDetSB8:SetArray(aDetSB8)
	 oDetSB8:bLine:={ ||{aDetSB8[oDetSB8:nAT,1],aDetSB8[oDetSB8:nAT,2],aDetSB8[oDetSB8:nAT,3],aDetSB8[oDetSB8:nAT,4],aDetSB8[oDetSB8:nAT,5],aDetSB8[oDetSB8:nAT,6],aDetSB8[oDetSB8:nAT,7],aDetSB8[oDetSB8:nAT,8],aDetSB8[oDetSB8:nAT,9]}}
	 oDetSB8:Refresh()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 03
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Saldo Por EndereÁo
@ 001,420 BUTTON "Pesquisar" SIZE 30,10 ACTION (fPesquisa("DETSBF",oDetSBF)) PIXEL OF oFolder:aDialogs[3]
@ 010,005 LISTBOX oDetSBF Var cModelo FIELDS HEADER; 
     "EndereÁo","Lote","Sub-Lote","Validade","Quantidade","Empenho","Tipo Estrutura","Status","Zona","Qtde.2UM","Empenho 2UM","Norma" FIELDSIZES;
      50       ,40    ,30        ,30        ,40          ,35       ,80              ,30      ,30    ,30        ,40           ,20      SIZE 480,215;
     ON DBLCLICK () PIXEL OF oFolder:aDialogs[3]
  	 oDetSBF:SetArray(aDetSBF)
     oDetSBF:bLDblClick := {|| Processa({||fMontaSDB()})} 
	 oDetSBF:bLine:={ ||{aDetSBF[oDetSBF:nAT,1],aDetSBF[oDetSBF:nAT,2],aDetSBF[oDetSBF:nAT,3],aDetSBF[oDetSBF:nAT,4],aDetSBF[oDetSBF:nAT,5],aDetSBF[oDetSBF:nAT,6],aDetSBF[oDetSBF:nAT,7],aDetSBF[oDetSBF:nAT,8],aDetSBF[oDetSBF:nAT,9],aDetSBF[oDetSBF:nAT,10],aDetSBF[oDetSBF:nAT,11],aDetSBF[oDetSBF:nAT,12]}}
	 oDetSBF:Refresh()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 04
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Sequencia de Abastecimento
@ 010,005 LISTBOX oSeqAbast Var cModelo FIELDS HEADER; 
	 "Ordem","Estr.Fisica","Desc.Estr.Fisica","Cod.Norma","Desc.Norma","Tx.Repos.%","Minimo Apanhe","% Apanhe Max","Tp.Sequencia","Unitizadores","Norma" FIELDSIZES;
	  20    ,30           ,30                ,30         ,90          ,40          ,40             ,40            ,55            ,40            ,20      SIZE 480,140;
     ON DBLCLICK () PIXEL OF oFolder:aDialogs[4]
	 oSeqAbast:SetArray(aSeqAbast)
	 oSeqAbast:bLine:={ ||{aSeqAbast[oSeqAbast:nAT,1],aSeqAbast[oSeqAbast:nAT,2],aSeqAbast[oSeqAbast:nAT,3],aSeqAbast[oSeqAbast:nAT,4],aSeqAbast[oSeqAbast:nAT,5],aSeqAbast[oSeqAbast:nAT,6],aSeqAbast[oSeqAbast:nAT,7],aSeqAbast[oSeqAbast:nAT,8],aSeqAbast[oSeqAbast:nAT,9],aSeqAbast[oSeqAbast:nAT,10],aSeqAbast[oSeqAbast:nAT,11]}}
     oSeqAbast:Refresh()

@ 158,005 SAY "EndereÁos de Picking Fixo"  SIZE 200,50 PIXEL OF oFolder:aDialogs[4] FONT oBold
@ 165,005 LISTBOX oPickFixo Var cModelo FIELDS HEADER; 
	 "EndereÁo","Zona","Estr.Fisica" FIELDSIZES;
	  40       ,40    ,40            SIZE 480,060;
     ON DBLCLICK () PIXEL OF oFolder:aDialogs[4]
	 oPickFixo:SetArray(aPickFixo)
	 oPickFixo:bLine:={ ||{aPickFixo[oPickFixo:nAT,1],aPickFixo[oPickFixo:nAT,2],aPickFixo[oPickFixo:nAT,3]}}
     oPickFixo:Refresh()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 05
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Zonas Alternativas
@ 010,005 LISTBOX oZonas Var cModelo FIELDS HEADER; 
	 "Ordem","Codigo Zona","DescriÁ„o Zona" FIELDSIZES;
	  40    ,40           ,70               SIZE 480,215;
	 ON DBLCLICK () PIXEL OF oFolder:aDialogs[5]
	 oZonas:SetArray(aZonas)
	 oZonas:bLine:={ ||{aZonas[oZonas:nAT,1],aZonas[oZonas:nAT,2],aZonas[oZonas:nAT,3]}}
     oZonas:Refresh()


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 06
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Pedidos Liberados
@ 001,420 BUTTON "Pesquisar" SIZE 30,10 ACTION (fPesquisa("PEDLIB",oPedLib)) PIXEL OF oFolder:aDialogs[6]
@ 010,005 LISTBOX oPedLib Var cModelo FIELDS HEADER; 
	 "Pedido","Item","Seq.","Cliente","Loja","Lote","LiberaÁ„o","Entrega","Quantidade","Bloq.Credito","Bloq.Estoque","Bloq.WMS","Carga","ServiÁo" FIELDSIZES;
	  30     ,30    ,30    ,30       ,30    ,30    ,30         ,30       ,35          ,35            ,35            ,30        ,30     ,30        SIZE 480,215;
	 ON DBLCLICK () PIXEL OF oFolder:aDialogs[6]
	 oPedLib:SetArray(aPedLib)
	 oPedLib:bLine:={ ||{aPedLib[oPedLib:nAT,1],aPedLib[oPedLib:nAT,2],aPedLib[oPedLib:nAT,3],aPedLib[oPedLib:nAT,4],aPedLib[oPedLib:nAT,5],aPedLib[oPedLib:nAT,6],aPedLib[oPedLib:nAT,7],aPedLib[oPedLib:nAT,8],aPedLib[oPedLib:nAT,9],aPedLib[oPedLib:nAT,10],aPedLib[oPedLib:nAT,11],aPedLib[oPedLib:nAT,12],aPedLib[oPedLib:nAT,13],aPedLib[oPedLib:nAT,14]}}
     oPedLib:Refresh()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 07
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Lotes com Bloqueo.
@ 001,420 BUTTON "Pesquisar" SIZE 30,10 ACTION (fPesquisa("LOTBLOQ",oLotBloq)) PIXEL OF oFolder:aDialogs[7]
@ 010,005 LISTBOX olotBloq Var cModelo FIELDS HEADER; 
	 "Documento","Lote","Validade","EndereÁo","Quantidade","Saldo","Qtde.Orig.","Motivo" FIELDSIZES;
	  35        ,30    ,30        ,30        ,35          ,30     ,30          ,30       SIZE 480,215;
	 ON DBLCLICK () PIXEL OF oFolder:aDialogs[7]
	 olotBloq:SetArray(alotBloq)
	 olotBloq:bLine:={ ||{alotBloq[olotBloq:nAT,1],alotBloq[olotBloq:nAT,2],alotBloq[olotBloq:nAT,3],alotBloq[olotBloq:nAT,4],alotBloq[olotBloq:nAT,5],alotBloq[olotBloq:nAT,6],alotBloq[olotBloq:nAT,7],alotBloq[olotBloq:nAT,8]}}
     olotBloq:Refresh()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 08
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Empenhos
@ 001,420 BUTTON "Pesquisar" SIZE 30,10 ACTION (fPesquisa("EMPENHO",oEmpenho)) PIXEL OF oFolder:aDialogs[8]
@ 010,005 LISTBOX oEmpenho Var cModelo FIELDS HEADER; 
	 "Origem","Pedido","Item","Seq.","Lote","Sub-Lote","EndereÁo","Quantidade","Qtd. 2a UM" FIELDSIZES;
	  30     ,30      ,30    ,30    ,30    ,30        ,30        ,35          ,35           SIZE 480,215;
	 ON DBLCLICK () PIXEL OF oFolder:aDialogs[8]
	 oEmpenho:SetArray(aEmpenho)
	 oEmpenho:bLine:={ ||{aEmpenho[oEmpenho:nAT,1],aEmpenho[oEmpenho:nAT,2],aEmpenho[oEmpenho:nAT,3],aEmpenho[oEmpenho:nAT,4],aEmpenho[oEmpenho:nAT,5],aEmpenho[oEmpenho:nAT,6],aEmpenho[oEmpenho:nAT,7],aEmpenho[oEmpenho:nAT,8],aEmpenho[oEmpenho:nAT,9]}}
     oEmpenho:Refresh()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 09
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Saldo a Enderecar
@ 001,420 BUTTON "Pesquisar" SIZE 30,10 ACTION (fPesquisa("DETSDA",oDetSDA)) PIXEL OF oFolder:aDialogs[9]
@ 010,005 LISTBOX oDetSDA Var cModelo FIELDS HEADER; 
     "Data","Lote","A Classificar","Saldo","Qtde.Original","Origem","Documento","Serie","Clie.For","Loja" FIELDSIZES;
      30   ,40    ,40             ,40     ,40             ,30      ,35         ,20     ,30        ,20     SIZE 480,215;
     ON DBLCLICK () PIXEL OF oFolder:aDialogs[9]
	 oDetSDA:SetArray(aDetSDA)
	 oDetSDA:bLine:={ ||{aDetSDA[oDetSDA:nAT,1],aDetSDA[oDetSDA:nAT,2],aDetSDA[oDetSDA:nAT,3],aDetSDA[oDetSDA:nAT,4],aDetSDA[oDetSDA:nAT,5],aDetSDA[oDetSDA:nAT,6],aDetSDA[oDetSDA:nAT,7],aDetSDA[oDetSDA:nAT,8],aDetSDA[oDetSDA:nAT,9],aDetSDA[oDetSDA:nAT,10]}}
	 oDetSDA:Refresh()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 10
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Servicos
@ 001,420 BUTTON "Pesquisar" SIZE 30,10 ACTION (fPesquisa("SERVICOS",oSERVICOS)) PIXEL OF oFolder:aDialogs[10]
@ 010,005 LISTBOX oServicos Var cModelo FIELDS HEADER; 
	 "ServiÁo","Data","Carga","Documento","Serie","Clie.For","Loja","Qtde.","Origem","Doc.Orig.","Status ServiÁo" FIELDSIZES;
	  30      ,30    ,30     ,35         ,30     ,30        ,20    ,30     ,30      ,30         ,30             SIZE 480,215;
	 ON DBLCLICK () PIXEL OF oFolder:aDialogs[10]
	 oServicos:SetArray(aServicos)
	 oServicos:bLine:={ ||{aServicos[oServicos:nAT,1],aServicos[oServicos:nAT,2],aServicos[oServicos:nAT,3],aServicos[oServicos:nAT,4],aServicos[oServicos:nAT,5],aServicos[oServicos:nAT,6],aServicos[oServicos:nAT,7],aServicos[oServicos:nAT,8],aServicos[oServicos:nAT,9],aServicos[oServicos:nAT,10],aServicos[oServicos:nAT,11]}}
     oServicos:Refresh()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 11
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Ord.ProduÁ„o
@ 001,420 BUTTON "Pesquisar" SIZE 30,10 ACTION (fPesquisa("OP",oOP)) PIXEL OF oFolder:aDialogs[11]
@ 010,005 LISTBOX oOP Var cModelo FIELDS HEADER; 
	 "DT Emissao","Ord.ProduÁ„o","Previsao Ini","DT Entrega","Quantidade","Qtde Produzida","Saldo OP" FIELDSIZES;
	  40         ,40            ,40            ,40          ,40          ,40              ,40         SIZE 480,215;
	 ON DBLCLICK () PIXEL OF oFolder:aDialogs[11]
	 oOP:SetArray(aOP)
	 oOP:bLine:={ ||{aOP[oOP:nAT,1],aOP[oOP:nAT,2],aOP[oOP:nAT,3],aOP[oOP:nAT,4],aOP[oOP:nAT,5],aOP[oOP:nAT,6],aOP[oOP:nAT,7]}}
     oOP:Refresh()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 12
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Empenho OP
@ 001,420 BUTTON "Pesquisar" SIZE 30,10 ACTION (fPesquisa("EMPENOP",oEmpenOP)) PIXEL OF oFolder:aDialogs[12]
@ 010,005 LISTBOX oEmpenOP Var cModelo FIELDS HEADER; 
	 "DT Empenho","Ord.ProduÁ„o","Seq.Estrut.","Lote","Qtd. Empenho","Sal. Empenho","Sld.Emp 2aUM" FIELDSIZES;
	  40         ,40            ,40            ,40   ,40            ,40            ,40             SIZE 480,215;
	 ON DBLCLICK () PIXEL OF oFolder:aDialogs[12]
	 oEmpenOP:SetArray(aEmpenOP)
	 oEmpenOP:bLine:={ ||{aEmpenOP[oEmpenOP:nAT,1],aEmpenOP[oEmpenOP:nAT,2],aEmpenOP[oEmpenOP:nAT,3],aEmpenOP[oEmpenOP:nAT,4],aEmpenOP[oEmpenOP:nAT,5],aEmpenOP[oEmpenOP:nAT,6],aEmpenOP[oEmpenOP:nAT,7]}}
     oEmpenOP:Refresh()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 13
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Kardex - Almoxarifado
@ 003,005 SAY "Saldo Final : "+Trans(nSldKarLocal,cPict) SIZE 200,50 PIXEL OF oFolder:aDialogs[13] FONT oBold
@ 010,005 LISTBOX oKarLocal Var cModelo FIELDS HEADER; 
     "Origem","Data","TES/TM","CFO","Documento","Quantidade","Saldo","Num.Seq." FIELDSIZES;
      25     ,40    ,30      ,20   ,35         ,40          ,40     ,30         SIZE 480,215;
     ON DBLCLICK () PIXEL OF oFolder:aDialogs[13]
	 oKarLocal:SetArray(aKarLocal)
	 oKarLocal:bLine:={ ||{aKarLocal[oKarLocal:nAT,1],aKarLocal[oKarLocal:nAT,2],aKarLocal[oKarLocal:nAT,3],aKarLocal[oKarLocal:nAT,4],aKarLocal[oKarLocal:nAT,5],aKarLocal[oKarLocal:nAT,6],aKarLocal[oKarLocal:nAT,7],aKarLocal[oKarLocal:nAT,8]}}
     oKarLocal:Refresh()
    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 14
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Kardex - Lote
@ 003,005 SAY "Saldo Final : "+Trans(nSldKarLote,cPict) SIZE 200,50 PIXEL OF oFolder:aDialogs[14] FONT oBold
@ 010,005 LISTBOX oKarLote Var cModelo FIELDS HEADER; 
     "Origem","Data","TM","Documento","Lote","Sub-Lote","Validade","Quantidade","Saldo","Num.Seq." FIELDSIZES;
      25     ,30    ,15  ,35         ,40    ,30        ,30        ,40          ,40     ,40         SIZE 480,215;
     ON DBLCLICK () PIXEL OF oFolder:aDialogs[14]
	 oKarLote:SetArray(aKarLote)
	 oKarLote:bLine:={ ||{aKarLote[oKarLote:nAT,1],aKarLote[oKarLote:nAT,2],aKarLote[oKarLote:nAT,3],aKarLote[oKarLote:nAT,4],aKarLote[oKarLote:nAT,5],aKarLote[oKarLote:nAT,6],aKarLote[oKarLote:nAT,7],aKarLote[oKarLote:nAT,8],aKarLote[oKarLote:nAT,9],aKarLote[oKarLote:nAT,10]}}
     oKarLote:Refresh()
    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 15
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Kardex - Localizacao
@ 003,005 SAY "Saldo Final : "+Trans(nSldKarEnde,cPict) SIZE 200,50 PIXEL OF oFolder:aDialogs[15] FONT oBold
@ 010,005 LISTBOX oKarEnde Var cModelo FIELDS HEADER; 
     "Origem","Data","TM","Documento","EndereÁo","Lote","Quantidade","Saldo","Num.Seq." FIELDSIZES;
	  25     ,30    ,15  ,35         ,50           ,40    ,40          ,40     ,40         SIZE 480,215;
	 ON DBLCLICK () PIXEL OF oFolder:aDialogs[15]
     oKarEnde:bLDblClick := {|| Processa({||fPesqNumSeq()})} 
	 oKarEnde:SetArray(aKarEnde)
	 oKarEnde:bLine:={ ||{aKarEnde[oKarEnde:nAT,1],aKarEnde[oKarEnde:nAT,2],aKarEnde[oKarEnde:nAT,3],aKarEnde[oKarEnde:nAT,4],aKarEnde[oKarEnde:nAT,5],aKarEnde[oKarEnde:nAT,6],aKarEnde[oKarEnde:nAT,7],aKarEnde[oKarEnde:nAT,8],aKarEnde[oKarEnde:nAT,9]}}
     oKarEnde:Refresh()
    
    
@ 010,420 BUTTON "&Processar"   SIZE 36,16 PIXEL ACTION Processa({||fProcessa()})
@ 040,420 BUTTON "&Sair"        SIZE 36,16 PIXEL ACTION oDlgMain:End()

ACTIVATE MSDIALOG oDlgMain CENTERED ON INIT fPreProc(cVarCod)

RestArea(aArea)        

Return(.T.)


Static Function fPreProc(cVarCod)

If cVarCod <> Nil // Foi chamada por outra rotina recebendo parametros
	GetDescProd()
	GetDRefresh()
	Processa({||fProcessa()})  
	GetDRefresh()
EndIf

Return(.T.)


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fProcessa()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
nDispo := nAtual := nReser := nEmpen := nEnder := nCredi := nEstoq := nLiber := nEmpPe := nBloqu := nProdu :=  0

IF Empty(dDataI) .OR. Empty(dDataF)
   MsgStop("Datas de Processamento Invalidas !!!")
   Return
Endif

ProcRegua(12)

DBSelectArea("SB1")
DBSetOrder(1)
DBSeek(xFilial("SB1")+cProduto)

DBSelectArea("SB2")
DBSetOrder(1) 
DBSeek(xFilial("SB2")+cProduto+cLocal)

nAtual := SB2->B2_QATU
nReser := SB2->B2_RESERVA
nEmpen := SB2->B2_QEMP
nEnder := SB2->B2_QACLASS
nDispo := nAtual - nReser - nEmpen - nEnder

IF SB1->B1_RASTRO == "L"  
   fDetaSB8()    // Detalhe do SB8
Endif

IF SB1->B1_LOCALIZ == "S"   
   fDetaSBF()    // Detalhe do SBF
Endif

fSeqAbast()

fZonas()

fPedLiberado()

fLoteBloq()

fEmpenhos()

fOrdemProd()

fEmpenhosOP()

IF SB1->B1_LOCALIZ == "S"   
   fDetaSDA()    // Detalhe SDA
Endif   

fServicos()

fKardLocal()  // Kardex por Almoxarifado

IF SB1->B1_RASTRO == "L"  
   fKardLote()   // Kardex por Lote
Endif
   
IF SB1->B1_LOCALIZ == "S"   
   fKardEnde()   // Kardex por Endereco
Endif

DBSelectArea('SB1')

Return


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function GetDescProd()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local aArea  := GetArea()

DBSelectArea("SB1")
DBSetOrder(1)
IF !Empty(cProduto) .AND. !DBSeek(xFilial("SB1")+cProduto)
   MsgStop("Produto n„o cadastrado !!!")
   Return (.F.)
Endif

cDescr   := SB1->B1_DESC
cCrlLot  := If(SB1->B1_RASTRO ="L","Lote",If(SB1->B1_RASTRO ="S","Sub-Lote","N„o"))
cCrlEnd  := If(SB1->B1_LOCALIZ="S","Sim","N„o")
cLocal   := IF(Empty(cLocal),SB1->B1_LOCPAD,cLocal)
c1UM     := SB1->B1_UM
c2UM     := SB1->B1_SEGUM
nFatConv := SB1->B1_CONV
cTipConv := SB1->B1_TIPCONV

DBSelectArea("SB5")
DBSetOrder(1)
DBSeek(xFilial("SB5")+cProduto)
cZona := SB5->B5_CODZON   

RestArea(aArea)

Return(.T.)


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function GetDatas()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local aArea  := GetArea()

cQuery := "SELECT MAX(B9_DATA) AS B9_DATA FROM "+RETSQLNAME('SB9')+" WHERE B9_FILIAL='"+xFilial("SB9")+"' AND B9_LOCAL='"+cLocal+"' AND D_E_L_E_T_ <> '*' AND B9_COD = '"+cProduto+"' AND B9_DATA < '"+DTOS(dDtProces)+"'"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySB9",.F.,.T.)
TCSETFIELD( "QrySB9","B9_DATA","D")
dUltFech := QrySB9->B9_DATA
DBCloseArea()

dDataI := (dUltFech + 1)
dDataF := dDtProces

RestArea(aArea)
Return(.T.)


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fDetaSB8()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IncProc("Processando Saldo por Lote")

aSize(aDetSB8, 0)

// Movimento do SB8
cQuery := " SELECT B8_DATA,B8_LOTECTL,B8_NUMLOTE,B8_DTVALID,B8_QTDORI,B8_SALDO,B8_EMPENHO,B8_SALDO2,B8_EMPENH2 FROM "+RETSQLNAME("SB8")   
cQuery += " WHERE B8_FILIAL='"+xFilial("SB8")+"' AND B8_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SB8")+".D_E_L_E_T_ <> '*' AND B8_PRODUTO = '"+cProduto+"'"
cQuery += " AND B8_SALDO <> 0 AND B8_DATA <= '"+DTOS(dDataF)+"' ORDER BY B8_LOTECTL,B8_NUMLOTE"   
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySB8",.F.,.T.)
TCSETFIELD( "QrySB8","B8_DATA","D")
TCSETFIELD( "QrySB8","B8_DTVALID","D")
While !Eof() 
  AAdd(aDetSB8,{B8_DATA,B8_LOTECTL,B8_NUMLOTE,B8_DTVALID,B8_SALDO,B8_QTDORI,B8_EMPENHO,B8_SALDO2,B8_EMPENH2})
  DBSkip()
Enddo
DBCloseArea()

IF Len(aDetSB8) == 0  
   Aadd(aDetSB8,{CTOD("  /  /  "),Space(10),Space(06),CTOD("  /  /  "),0,0,0,0,0})
   oDetSB8:nAT := 1
Endif

oDetSB8:Refresh()
   
Return

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fDetaSBF()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IncProc("Processando Saldo por EndereÁo")

aSize(aDetSBF, 0)

// Movimento do SBF
cQuery := " SELECT BF_LOCALIZ,BF_LOTECTL,BF_NUMLOTE,BF_QUANT,BF_QTSEGUM,BF_EMPENHO,BF_EMPEN2,BF_ESTFIS,R_E_C_N_O_ AS RECNO FROM "+RETSQLNAME("SBF")
cQuery += " WHERE BF_FILIAL='"+xFilial("SBF")+"' AND BF_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SBF")+".D_E_L_E_T_ <> '*' AND BF_PRODUTO = '"+cProduto+"'"
cQuery += " AND BF_QUANT <> 0 ORDER BY BF_LOCALIZ,BF_LOTECTL"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySBF",.F.,.T.)
While !Eof()                                        
  DBSelectArea("SBE")
  DBSetOrder(1) //BE_FILIAL+BE_LOCAL+BE_LOCALIZ
  DBSeek(xFilial("SBE")+cLocal+QrySBF->BF_LOCALIZ)
  
  cEndStatus := ""
  IF (nSeek := Ascan(aBoxSBE, { |x| x[ 2 ] == SBE->BE_STATUS })) > 0
     cEndStatus := AllTrim( aBoxSBE[ nSeek, 3 ] )
  Endif

  DBSelectArea("DC8")
  DBSetOrder(1) 
  DBSeek(xFilial("DC8")+QrySBF->BF_ESTFIS)
  
  DBSelectArea("DC3")
  DBSetOrder(2) //DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_TPESTR
  DBSeek(xFilial("DC3")+cProduto+cLocal+QrySBF->BF_ESTFIS)
  
  DBSelectArea("DC2")
  DBSetOrder(1) //DC2_FILIAL+DC2_CODNOR
  DBSeek(xFilial("DC2")+DC3->DC3_CODNOR)
  nNorma := DC2_LASTRO*DC2_CAMADA

  DBSelectArea("SB8")
  DBSetOrder(3) //3 B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
  DBSeek(xFilial("SB8")+cProduto+cLocal+QrySBF->BF_LOTECTL+QrySBF->BF_NUMLOTE)
    
  AAdd(aDetSBF,{QrySBF->BF_LOCALIZ,QrySBF->BF_LOTECTL,QrySBF->BF_NUMLOTE,B8_DTVALID,QrySBF->BF_QUANT,QrySBF->BF_EMPENHO,QrySBF->BF_ESTFIS+" - "+Substr(DC8->DC8_DESEST,1,15),cEndStatus,SBE->BE_CODZON,QrySBF->BF_QTSEGUM,QrySBF->BF_EMPEN2,nNorma})

  DBSelectArea("QrySBF")
  DBSkip()
Enddo
DBCloseArea()

IF Len(aDetSBF) == 0
   Aadd(aDetSBF,{Space(15),Space(10),Space(6),CTOD("  /  /  "),0,0,Space(01),Space(01),Space(01),0,0,0})
   oDetSBF:nAT := 1
Endif

oDetSBF:Refresh()

Return

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fSeqAbast()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IncProc("Processando Sequencia de Abastecimento")

aSize(aSeqAbast, 0)
aSize(aPickFixo, 0)

DBSelectArea("DC3")
DBSetOrder(1) //DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_ORDEM
DBSeek(xFilial("DC3")+cProduto+cLocal)
While !Eof() .AND. xFilial("DC3")+cProduto+cLocal == DC3_FILIAL+DC3_CODPRO+DC3_LOCAL
  DBSelectArea("DC2")
  DBSetOrder(1) //DC2_FILIAL+DC2_CODNOR
  DBSeek(xFilial("DC2")+DC3->DC3_CODNOR)
  DBSelectArea("DC8")
  DBSetOrder(1) //DC8_FILIAL+DC8_CODEST
  DBSeek(xFilial("DC8")+DC3->DC3_TPESTR)
  DBSelectArea("DC3")
  cTpSequen := ""
  IF (nSeek := Ascan(aBoxDC3, { |x| x[ 2 ] == DC3->DC3_EMBDES })) > 0
     cTpSequen := AllTrim( aBoxDC3[ nSeek, 3 ] )
  Endif
  AAdd(aSeqAbast,{DC3_ORDEM,DC3_TPESTR,DC8->DC8_DESEST,DC3_CODNOR,DC2->DC2_DESNOR,DC3_PERREP,DC3_QTDUNI,DC3_PERAPM,cTpSequen,DC3_NUNITI,DC2->DC2_LASTRO*DC2->DC2_CAMADA})
  DBSkip()
Enddo

IF Len(aSeqAbast) == 0
   Aadd(aSeqAbast,{Space(02),Space(06),Space(20),Space(06),Space(20),Space(01),Space(01),Space(01),Space(01),Space(01),0})
Endif

DBSelectArea("SBE")
DBSetOrder(10) //BE_FILIAL+BE_CODPRO+BE_LOCAL+BE_LOCALIZ
DBSeek(xFilial("SBE")+cProduto+cLocal)
While !Eof() .AND. xFilial("SBE")+cProduto+cLocal == BE_FILIAL+BE_CODPRO+BE_LOCAL
  AAdd(aPickFixo,{BE_LOCALIZ,BE_CODZON,BE_ESTFIS})
  DBSkip()
Enddo

IF Len(aPickFixo) == 0
   Aadd(aPickFixo,{Space(15),Space(06),Space(06)})
Endif

oSeqAbast:nAT := 1
oPickFixo:nAT := 1

oSeqAbast:Refresh()
oPickFixo:Refresh()
   
Return

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fZonas()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IncProc("Processando Zonas de Alternativas")

aSize(aZonas, 0)

DBSelectArea("DCH")
DBSetOrder(2) //DCH_FILIAL+DCH_CODPRO+DCH_ORDEM+DCH_CODZON
DBSeek(xFilial("DCH")+cProduto)
While !Eof() .AND. xFilial("DCH")+cProduto == DCH_FILIAL+DCH_CODPRO
  DBSelectArea("DC4")
  DBSetOrder(1) //DC4_FILIAL+DC4_CODZON
  DBSeek(xFilial("DC4")+DCH->DCH_CODZON)
  AAdd(aZonas,{DCH->DCH_ORDEM,DCH->DCH_CODZON,DC4->DC4_DESZON})
  DBSelectArea("DCH")
  DBSkip()
Enddo

IF Len(aZonas) == 0
   Aadd(aZonas,{Space(15),Space(10),0,0,Space(01),Space(01),Space(01),0,0,Space(01)})
   oZonas:nAT := 1
Endif

oZonas:Refresh()
   
Return

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fPedLiberado()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IncProc("Processando Pedidos Liberados")

aSize(aPedLib, 0)

nCredi := nEstoq := nLiber := 0

cQuery := " SELECT * FROM "+RETSQLNAME("SC9")
cQuery += " WHERE C9_FILIAL='"+xFilial("SC9")+"' AND C9_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SC9")+".D_E_L_E_T_ <> '*' AND C9_PRODUTO = '"+cProduto+"'"
cQuery += " AND C9_NFISCAL=''"
cQuery += " ORDER BY C9_PEDIDO,C9_ITEM,C9_SEQUEN,C9_PRODUTO"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySC9",.F.,.T.)
TCSETFIELD( "QrySC9","C9_DATALIB","D")
While !Eof()   
  DBSelectArea("SC6")
  DBSetOrder(1) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
  DBSeek(xFilial("SC6")+QrySC9->C9_PEDIDO+QrySC9->C9_ITEM+QrySC9->C9_PRODUTO)
  DBSelectArea("QrySC9")
  AAdd(aPedLib,{C9_PEDIDO,C9_ITEM,C9_SEQUEN,C9_CLIENTE,C9_LOJA,C9_LOTECTL,C9_DATALIB,SC6->C6_ENTREG,C9_QTDLIB,C9_BLCRED,C9_BLEST,C9_BLWMS,C9_CARGA,C9_SERVIC})
  Do Case
    Case !Empty(C9_BLCRED); nCredi += C9_QTDLIB
    Case !Empty(C9_BLEST);  nEstoq += C9_QTDLIB    
    Case Empty(C9_BLCRED) .AND. Empty(C9_BLEST) .AND. C9_BLWMS = "01";  nLiber += C9_QTDLIB        
  EndCase  
  DBSkip()
Enddo
DBCloseArea()

IF Len(aPedLib) == 0
   Aadd(aPedLib,{Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01)})
   oPedLib:nAT := 1
Endif

oPedLib:Refresh()
   
Return


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fLoteBloq()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IncProc("Processando Lote com Bloqueio")

aSize(aLotBloq, 0)

cQuery := " SELECT * FROM "+RETSQLNAME("SDD")
cQuery += " WHERE DD_FILIAL='"+xFilial("SDD")+"' AND DD_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SDD")+".D_E_L_E_T_ <> '*' AND DD_PRODUTO = '"+cProduto+"'"
cQuery += " AND DD_SALDO > 0"
cQuery += " ORDER BY DD_DOC"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySDD",.F.,.T.)
TCSETFIELD( "QrySDD","DD_DTVALID","D")
While !Eof() 
  AAdd(aLotBloq,{DD_DOC,DD_LOTECTL,DD_DTVALID,DD_LOCALIZ,DD_QUANT,DD_SALDO,DD_QTDORIG,Posicione("SX5",1,xFilial("SX5")+"E1"+DD_MOTIVO,"X5DESCRI()")})
  DBSkip()
Enddo
DBCloseArea()

IF Len(aLotBloq) == 0
   Aadd(aLotBloq,{Space(15),Space(10),0,0,Space(01),Space(01),Space(01),0,0,Space(01)})
   oLotBloq:nAT := 1
Endif

oLotBloq:Refresh()
   
Return


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fEmpenhos()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//"Origem","Pedido","Item","Seq.","Lote","Sub-Lote","EndereÁo","Quantidade","Qtd. 2a UM"
IncProc("Processando Empenhos")

aSize(aEmpenho, 0)

nEmpPe := 0
nBloqu := 0

cQuery := " SELECT * FROM "+RETSQLNAME("SDC")
cQuery += " WHERE DC_FILIAL='"+xFilial("SDC")+"' AND DC_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SDC")+".D_E_L_E_T_ <> '*' AND DC_PRODUTO = '"+cProduto+"'"
cQuery += " ORDER BY R_E_C_N_O_"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySDC",.F.,.T.)
While !Eof() 
  AAdd(aEmpenho,{DC_ORIGEM,DC_PEDIDO,DC_ITEM,DC_SEQ,DC_LOTECTL,DC_NUMLOTE,DC_LOCALIZ,DC_QUANT,DC_QTSEGUM})
  Do Case
    Case DC_ORIGEM == "SC6"
      nEmpPe += DC_QUANT
    Case DC_ORIGEM == "SDD"
      nBloqu += DC_QUANT
  EndCase
  DBSkip()
Enddo
DBCloseArea()

IF Len(aEmpenho) == 0
   Aadd(aEmpenho,{Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01)})
   oEmpenho:nAT := 1
Endif

oEmpenho:Refresh()
   
Return


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fOrdemProd()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//"DT Emissao","Ord.ProduÁ„o","Previsao Ini","DT Entrega","Quantidade","Qtde Produzida"
IncProc("Processando Ordem Producao")

aSize(aOP, 0)

cQuery := " SELECT * FROM "+RETSQLNAME("SC2")
cQuery += " WHERE C2_FILIAL='"+xFilial("SC2")+"' AND C2_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SC2")+".D_E_L_E_T_ <> '*' AND C2_PRODUTO = '"+cProduto+"'"
cQuery += " AND (C2_QUANT-C2_QUJE) > 0 ORDER BY C2_EMISSAO,C2_NUM,C2_ITEM,C2_SEQUEN"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySC2",.F.,.T.)
TCSETFIELD( "QrySC2","C2_EMISSAO","D")
TCSETFIELD( "QrySC2","C2_DATPRI","D")
TCSETFIELD( "QrySC2","C2_DATPRF","D")
While !Eof() 
  AAdd(aOP,{C2_EMISSAO,C2_NUM+C2_ITEM+C2_SEQUEN,C2_DATPRI,C2_DATPRF,C2_QUANT,C2_QUJE,C2_QUANT-C2_QUJE})
  DBSkip()
Enddo
DBCloseArea()

IF Len(aOP) == 0
   Aadd(aOP,{CTOD(" /  /  "),Space(13),CTOD(" /  /  "),CTOD(" /  /  "),0,0,0})
   oOP:nAT := 1
Endif

oOP:Refresh()
   
Return


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fEmpenhosOP()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//"DT Empenho","Ord.ProduÁ„o","Seq.Estrut.","Lote","Qtd. Empenho","Sal. Empenho","Sld.Emp 2aUM"
IncProc("Processando Empenhos OP")

aSize(aEmpenOP, 0)

nProdu := 0

cQuery := " SELECT * FROM "+RETSQLNAME("SD4")
cQuery += " WHERE D4_FILIAL='"+xFilial("SD4")+"' AND D4_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SD4")+".D_E_L_E_T_ <> '*' AND D4_COD = '"+cProduto+"'"
cQuery += " ORDER BY D4_DATA,D4_OP,D4_TRT"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySD4",.F.,.T.)
TCSETFIELD( "QrySD4","D4_DATA","D")
While !Eof() 
  AAdd(aEmpenOP,{D4_DATA,D4_OP,D4_TRT,D4_LOTECTL,D4_QTDEORI,D4_QUANT,D4_QTSEGUM})
  nProdu += D4_QUANT
  DBSkip()
Enddo
DBCloseArea()

IF Len(aEmpenOP) == 0
   Aadd(aEmpenOP,{CTOD(" /  /  "),Space(13),Space(03),Space(10),0,0,0})
   oEmpenOP:nAT := 1
Endif

oEmpenOP:Refresh()
   
Return


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fDetaSDA()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IncProc("Processando Saldo a Classificar")

aSize(aDetSDA,0)

cQuery := " SELECT DA_DATA,DA_QTDORI,DA_SALDO,DA_LOTECTL,DA_NUMSEQ,DA_ORIGEM,DA_DOC,DA_SERIE,DA_CLIFOR,DA_LOJA,R_E_C_N_O_ AS RECNO FROM "+RETSQLNAME("SDA")
cQuery += " WHERE DA_FILIAL='"+xFilial("SDA")+"' AND DA_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SDA")+".D_E_L_E_T_ <> '*' AND DA_PRODUTO = '"+cProduto+"'"
cQuery += " AND DA_SALDO <> 0 AND DA_DATA <= '"+DTOS(dDataF)+"'"
cQuery += " ORDER BY DA_DATA"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySDA",.F.,.T.)
TCSETFIELD( "QrySDA","DA_DATA","D")
While !Eof() 
  AAdd(aDetSDA,{DA_DATA,DA_LOTECTL,DA_SALDO,0,DA_QTDORI,DA_ORIGEM,DA_DOC,DA_SERIE,DA_CLIFOR,DA_LOJA})
  DBSkip()
Enddo
DBCloseArea()

nSaldo := 0
For I:= 1 To Len(aDetSDA)
   nSaldo += aDetSDA[I,3]
   aDetSDA[I,4] := nSaldo
Next

IF Len(aDetSDA) == 0
   Aadd(aDetSDA ,{CTOD("  /  /  "),Space(10),0,0,0,Space(03),Space(06),Space(03),Space(06),Space(02)})
   oDetSDA:nAT := 1
Endif
  
oDetSDA:Refresh()
   
Return

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fServicos()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//"Carga","Documento","Serie","Clie.For","Loja","Data","ServiÁo","Qtde.","Status Serv."
IncProc("Processando ServiÁos")

aSize(aServicos, 0)

cQuery := " SELECT * FROM "+RETSQLNAME("DCF")
cQuery += " WHERE DCF_FILIAL='"+xFilial("DCF")+"' AND DCF_LOCAL='"+cLocal+"' AND DCF_STSERV <> '3' AND D_E_L_E_T_ <> '*' AND DCF_CODPRO = '"+cProduto+"'"
cQuery += " ORDER BY DCF_DATA,DCF_CARGA,DCF_DOCTO"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QryDCF",.F.,.T.)
TCSETFIELD( "QryDCF","DCF_DATA","D")
While !Eof() 
  cStServ := ""
  IF (nSeek := Ascan(aBoxDCF, { |x| x[ 2 ] == DCF_STSERV })) > 0
     cStServ := AllTrim( aBoxDCF[ nSeek, 3 ] )
  Endif
  AAdd(aServicos,{DCF_SERVIC,DCF_DATA,DCF_CARGA,DCF_DOCTO,DCF_SERIE,DCF_CLIFOR,DCF_LOJA,DCF_QUANT,DCF_ORIGEM,DCF_DOCORI,cStServ})
  DBSkip()
Enddo
DBCloseArea()

IF Len(aServicos) == 0
   Aadd(aServicos,{Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),Space(01),0,Space(01),Space(01),Space(01)})
   oServicos:nAT := 1
Endif

oServicos:Refresh()
   
Return


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fKardLocal()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IncProc("Processando Kardex - Almoxarifado")

aSize(aKarLocal, 0)

DBSelectArea("SB9")
DBSetOrder(1) 
DBSeek(xFilial("SB9")+cProduto+cLocal+DTOS(dUltFech))

// Saldo Inicial
AAdd(aKarLocal,{"SB9",SB9->B9_DATA,Space(3),Space(3),Space(6),SB9->B9_QINI,SB9->B9_QINI,Space(6)})

// Movimento do SD1
cQuery := " SELECT D1_DTDIGIT,D1_TES,D1_CF,D1_DOC,D1_QUANT,D1_NUMSEQ FROM "+RETSQLNAME("SD1")+", "+RETSQLNAME("SF4")
cQuery += " WHERE D1_FILIAL='"+xFilial("SD1")+"' AND D1_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SD1")+".D_E_L_E_T_ <> '*' AND D1_COD = '"+cProduto+"'"
cQuery += " AND D1_ORIGLAN <> 'LF' AND D1_DTDIGIT >= '"+DTOS(dDataI)+"' AND D1_DTDIGIT <= '"+DTOS(dDataF)+"'"                                      
cQuery += " AND "+IF(Empty(xFilial("SF4")),"D1_TES=F4_CODIGO","D1_FILIAL=F4_FILIAL AND D1_TES=F4_CODIGO")+" AND F4_ESTOQUE = 'S' AND "+RETSQLNAME("SF4")+".D_E_L_E_T_ <> '*'"
cQuery += " ORDER BY D1_DTDIGIT,D1_NUMSEQ"  
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySD1",.F.,.T.)
TCSETFIELD( "QrySD1","D1_DTDIGIT","D")
While !Eof() 
  AAdd(aKarLocal,{"SD1",D1_DTDIGIT,D1_TES,D1_CF,D1_DOC,D1_QUANT,0,D1_NUMSEQ})
  DBSkip()
Enddo
DBCloseArea()

// Movimento do SD2
cQuery := " SELECT D2_EMISSAO,D2_TES,D2_CF,D2_DOC,D2_QUANT,D2_NUMSEQ FROM "+RETSQLNAME("SD2")+", "+RETSQLNAME("SF4")
cQuery += " WHERE D2_FILIAL='"+xFilial("SD2")+"' AND D2_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SD2")+".D_E_L_E_T_ <> '*' AND D2_COD = '"+cProduto+"'"
cQuery += " AND D2_ORIGLAN <> 'LF' AND D2_EMISSAO >= '"+DTOS(dDataI)+"' AND D2_EMISSAO <= '"+DTOS(dDataF)+"'"
cQuery += " AND "+IF(Empty(xFilial("SF4")),"D2_TES=F4_CODIGO","D2_FILIAL=F4_FILIAL AND D2_TES=F4_CODIGO")+" AND F4_ESTOQUE = 'S' AND "+RETSQLNAME("SF4")+".D_E_L_E_T_ <> '*'"
cQuery += " ORDER BY D2_EMISSAO,D2_NUMSEQ"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySD2",.F.,.T.)
TCSETFIELD( "QrySD2","D2_EMISSAO","D")
While !Eof() 
  AAdd(aKarLocal,{"SD2",D2_EMISSAO,D2_TES,D2_CF,D2_DOC,D2_QUANT,0,D2_NUMSEQ})
  DBSkip()
Enddo    
DBCloseArea()

// Movimento do SD3
cQuery := " SELECT D3_EMISSAO,D3_TM,D3_CF,D3_DOC,D3_QUANT,D3_NUMSEQ,R_E_C_N_O_ AS RECNO FROM "+RETSQLNAME("SD3")
cQuery += " WHERE D3_FILIAL='"+xFilial("SD3")+"' AND D3_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SD3")+".D_E_L_E_T_ <> '*' AND D3_COD = '"+cProduto+"'"
cQuery += " AND D3_ESTORNO=' ' AND D3_EMISSAO >= '"+DTOS(dDataI)+"' AND D3_EMISSAO <= '"+DTOS(dDataF)+"'"
cQuery += " ORDER BY D3_EMISSAO,D3_NUMSEQ"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySD3",.F.,.T.)
TCSETFIELD( "QrySD3","D3_EMISSAO","D")
While !Eof()
  DBSelectArea("SD3")
  DBGoto(QrySD3->RECNO)
  If D3Valido()         
     AAdd(aKarLocal,{"SD3",D3_EMISSAO,D3_TM,D3_CF,D3_DOC,D3_QUANT,0,D3_NUMSEQ})
  Endif              
  DBSelectArea("QrySD3")
  DBSkip()
Enddo 
DBCloseArea()

aSort(aKarLocal,,, { |x,y| y[8] > x[8] } )   

nSldKarLocal := aKarLocal[1,6]
For I:= 2 To Len(aKarLocal)
   nSldKarLocal += IF(aKarLocal[I,3] <= "500",aKarLocal[I,6],aKarLocal[I,6]*-1)
   aKarLocal[I,7] := nSldKarLocal
Next

IF Len(aKarLocal) == 0      
   AAdd(aKarLocal ,{Space(03),Space(08),Space(03),Space(03),Space(06),Space(01),Space(01),Space(06)})
   oKarLocal:nAT := 1
Endif

oKarLocal:Refresh()
   
Return


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fKardLote()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IncProc("Processando Kardex - Lote")

aSize(aKarLote, 0)

// Identifica os Lotes               
cQuery := " SELECT DISTINCT BJ_LOTECTL AS LOTECTL,BJ_NUMLOTE AS NUMLOTE FROM "+RETSQLNAME("SBJ")
cQuery += " WHERE BJ_FILIAL='"+xFilial("SBJ")+"' AND BJ_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SBJ")+".D_E_L_E_T_ <> '*' AND BJ_COD = '"+cProduto+"'"
cQuery += " AND BJ_DATA = '"+DTOS(dUltFech)+"' AND BJ_QINI <> 0"
cQuery += " UNION"
cQuery += " SELECT DISTINCT D5_LOTECTL AS LOTECTL,D5_NUMLOTE AS NUMLOTE FROM "+RETSQLNAME("SD5")
cQuery += " WHERE D5_FILIAL='"+xFilial("SD5")+"' AND D5_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SD5")+".D_E_L_E_T_ <> '*' AND D5_PRODUTO = '"+cProduto+"'"
cQuery += " AND D5_ESTORNO= ' ' AND D5_DATA >= '"+DTOS(dDataI)+"' AND D5_DATA <= '"+DTOS(dDataF)+"'"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QryTRB",.F.,.T.)
While !Eof()
  // Movimento do SBJ
  cQuery := " SELECT BJ_LOTECTL,BJ_NUMLOTE,BJ_DTVALID,SUM(BJ_QINI) AS BJ_QINI FROM "+RETSQLNAME("SBJ")
  cQuery += " WHERE BJ_FILIAL='"+xFilial("SBJ")+"' AND BJ_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SBJ")+".D_E_L_E_T_ <> '*' AND BJ_COD = '"+cProduto+"'"
  cQuery += " AND BJ_DATA = '"+DTOS(dUltFech)+"' AND BJ_LOTECTL  = '"+QryTRB->LOTECTL+"' AND BJ_NUMLOTE  = '"+QryTRB->NUMLOTE+"'"
  cQuery += " GROUP BY BJ_LOTECTL,BJ_NUMLOTE,BJ_DTVALID"
  cQuery := ChangeQuery(cQuery)
  DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySBJ",.F.,.T.)
  TCSETFIELD( "QrySBJ","BJ_DTVALID","D")
  AAdd(aKarLote,{"SBJ"  ,dUltFech ,Space(3),Space(6),QryTRB->LOTECTL,QryTRB->NUMLOTE,BJ_DTVALID,BJ_QINI,0        ,Space(30),QryTRB->LOTECTL+QryTRB->NUMLOTE+"A"+Space(6)})
  AAdd(aKarLote,{"SALDO",dDataF   ,Space(3),Space(6),QryTRB->LOTECTL,QryTRB->NUMLOTE,SPACE(06) ,SPACE(06),0           ,Space(30),QryTRB->LOTECTL+QryTRB->NUMLOTE+"C"+Space(6)})
  AAdd(aKarLote,{"     ",Space(08),Space(3),Space(6),SPACE(06)      ,SPACE(06)      ,SPACE(06) ,SPACE(06),SPACE(06)   ,Space(30),QryTRB->LOTECTL+QryTRB->NUMLOTE+"D"+Space(6)})
  DBCloseArea()
  DBSelectArea("QryTRB")
  DBSkip()
Enddo
DBCloseArea()

// Movimento do SD5
cQuery := " SELECT D5_DATA,D5_ORIGLAN,D5_DOC,D5_LOTECTL,D5_NUMLOTE,D5_DTVALID,D5_QUANT,D5_NUMSEQ FROM "+RETSQLNAME("SD5")
cQuery += " WHERE D5_FILIAL='"+xFilial("SD5")+"' AND D5_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SD5")+".D_E_L_E_T_ <> '*' AND D5_PRODUTO = '"+cProduto+"'"
cQuery += " AND D5_ESTORNO= ' ' AND D5_DATA >= '"+DTOS(dDataI)+"' AND D5_DATA <= '"+DTOS(dDataF)+"'"
cQuery += " ORDER BY D5_DATA,D5_NUMSEQ"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySD5",.F.,.T.)
TCSETFIELD( "QrySD5","D5_DATA","D")
TCSETFIELD( "QrySD5","D5_DTVALID","D")
While !Eof() 
  AAdd(aKarLote,{"SD5",D5_DATA,D5_ORIGLAN,D5_DOC,D5_LOTECTL,D5_NUMLOTE,D5_DTVALID,D5_QUANT,0,D5_NUMSEQ,D5_LOTECTL+D5_NUMLOTE+"B"+D5_NUMSEQ})
  DBSkip()
Enddo
DBCloseArea()

aSort(aKarLote,,, { |x,y| y[11]+y[3] > x[11]+x[3] } )   

nSldKarLote := 0
nSaldo      := 0

For I:= 1 To Len(aKarLote)   
  Do Case
    Case aKarLote[I,1] == "SBJ"
       nSaldo        := aKarLote[I,8]
       aKarLote[I,9] := nSaldo
    Case aKarLote[I,1] == "SD5"
       nSaldo        += IF(aKarLote[I,3] <= "500" .OR. Substr(aKarLote[I,3],1,2) $ 'DE/PR/MA',aKarLote[I,8],aKarLote[I,8]*-1)
       aKarLote[I,9] := nSaldo      
    Case aKarLote[I,1] == "SALDO"
       aKarLote[I,9] := nSaldo
       nSldKarLote   += nSaldo
  EndCase
Next

IF Len(aKarLote) == 0
   AAdd(aKarLote  ,{Space(03),Space(08),Space(03),Space(06),Space(06),Space(08),Space(08),Space(01),Space(01),Space(30),Space(01)})
   oKarLote:nAT := 1
Endif

oKarLote:Refresh()
   
Return

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fKardEnde()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IncProc("Processando Kardex - Endereco")

aSize(aKarEnde, 0)

// Identifica os Enderecos
cQuery := " SELECT DISTINCT BK_LOCALIZ AS LOCALIZ,BK_LOTECTL AS LOTECTL FROM "+RETSQLNAME("SBK")
cQuery += " WHERE BK_FILIAL='"+xFilial("SBK")+"' AND BK_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SBK")+".D_E_L_E_T_ <> '*' AND BK_COD = '"+cProduto+"'"
cQuery += " AND BK_DATA = '"+DTOS(dUltFech)+"' AND BK_QINI <> 0"
cQuery += " UNION"
cQuery += " SELECT DISTINCT DB_LOCALIZ AS LOCALIZ,DB_LOTECTL AS LOTECTL FROM "+RETSQLNAME("SDB")
cQuery += " WHERE DB_FILIAL='"+xFilial("SDB")+"' AND DB_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SDB")+".D_E_L_E_T_ <> '*' AND DB_PRODUTO = '"+cProduto+"'"
cQuery += " AND DB_ESTORNO=' ' AND DB_ATUEST='S' AND DB_DATA >= '"+DTOS(dDataI)+"' AND DB_DATA <= '"+DTOS(dDataF)+"'"
cQuery += " UNION"
cQuery += " SELECT DISTINCT BF_LOCALIZ AS LOCALIZ,BF_LOTECTL AS LOTECTL FROM "+RETSQLNAME("SBF")
cQuery += " WHERE BF_FILIAL='"+xFilial("SBF")+"' AND BF_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SBF")+".D_E_L_E_T_ <> '*' AND BF_PRODUTO = '"+cProduto+"'"
cQuery += " AND BF_QUANT <> 0"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QryTRB",.F.,.T.)
While !Eof()
  // Movimento do SBK
  cQuery := " SELECT BK_LOCALIZ,BK_LOTECTL,SUM(BK_QINI) AS BK_QINI FROM "+RETSQLNAME("SBK")
  cQuery += " WHERE BK_FILIAL='"+xFilial("SBK")+"' AND BK_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SBK")+".D_E_L_E_T_ <> '*' AND BK_COD = '"+cProduto+"'"
  cQuery += " AND BK_DATA = '"+DTOS(dUltFech)+"' AND BK_LOCALIZ  = '"+QryTRB->LOCALIZ+"' AND BK_LOTECTL  = '"+QryTRB->LOTECTL+"'"
  cQuery += " GROUP BY BK_LOCALIZ,BK_LOTECTL"           
  cQuery := ChangeQuery(cQuery)
  DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySBK",.F.,.T.)
  AAdd(aKarEnde,{"SBK"  ,dUltFech ,Space(3),Space(6),QryTRB->LOCALIZ,QryTRB->LOTECTL,BK_QINI  ,0        ,Space(6),QryTRB->LOCALIZ+QryTRB->LOTECTL+"A"+Space(6)})
  AAdd(aKarEnde,{"SALDO",dDataF   ,Space(3),Space(6),QryTRB->LOCALIZ,QryTRB->LOTECTL,SPACE(06),0        ,Space(6),QryTRB->LOCALIZ+QryTRB->LOTECTL+"C"+Space(6)})
  AAdd(aKarEnde,{"     ",Space(08),Space(3),Space(6),SPACE(06)      ,SPACE(06)      ,SPACE(06),SPACE(06),Space(6),QryTRB->LOCALIZ+QryTRB->LOTECTL+"D"+Space(6)})
  DBCloseArea()
  DBSelectArea("QryTRB")
  DBSkip()
Enddo
DBCloseArea()

// Movimento do SDB
cQuery := " SELECT DB_DATA,DB_TM,DB_DOC,DB_LOCALIZ,DB_LOTECTL,DB_QUANT,DB_NUMSEQ FROM "+RETSQLNAME("SDB")
cQuery += " WHERE DB_FILIAL='"+xFilial("SDB")+"' AND DB_LOCAL='"+cLocal+"' AND "+RETSQLNAME("SDB")+".D_E_L_E_T_ <> '*' AND DB_PRODUTO = '"+cProduto+"'"
cQuery += " AND DB_ESTORNO=' ' AND DB_ATUEST='S' AND DB_DATA >= '"+DTOS(dDataI)+"' AND DB_DATA <= '"+DTOS(dDataF)+"'"
cQuery += " ORDER BY DB_DATA,DB_NUMSEQ"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySDB",.F.,.T.)
TCSETFIELD( "QrySDB","DB_DATA","D")
While !Eof() 
  AAdd(aKarEnde,{"SDB",DB_DATA,DB_TM,DB_DOC,DB_LOCALIZ,DB_LOTECTL,DB_QUANT,0,DB_NUMSEQ,DB_LOCALIZ+DB_LOTECTL+"B"+DB_NUMSEQ})
  DBSkip()
Enddo
DBCloseArea()

aSort(aKarEnde,,, { |x,y| y[10]+y[3] > x[10]+x[3] } )   

nSldKarEnde := 0
nSaldo      := 0

For I:= 1 To Len(aKarEnde)   
  Do Case
    Case aKarEnde[I,1] == "SBK"
       nSaldo        := aKarEnde[I,7]
       aKarEnde[I,8] := nSaldo
    Case aKarEnde[I,1] == "SDB"
       nSaldo        += IF(aKarEnde[I,3] <= "500" .OR. Substr(aKarEnde[I,3],1,2) $ 'DE/PR/MA',aKarEnde[I,7],aKarEnde[I,7]*-1)
       aKarEnde[I,8] := nSaldo      
    Case aKarEnde[I,1] == "SALDO"
       aKarEnde[I,8] := nSaldo
       nSldKarEnde   += nSaldo
  EndCase
Next

IF Len(aKarEnde) = 0
   AAdd(aKarEnde  ,{Space(03),Space(08),Space(03),Space(06),Space(15),Space(01),Space(01),Space(01),Space(06),Space(01)})
Endif

oKarEnde:Refresh()
   
Return


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fPesquisa(cOpcao,oBrowse)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local oDlgPesq
Local aArea   := GetArea()
Local cCampos := Space(20)          
Local cSeek   := Space(20)   
Local aCampos := {}

For I:= 1 To Len(oBrowse:AHEADERS)
   IF Valtype(oBrowse:AARRAY[1,I]) = "C" .AND. !UPPER(Alltrim(oBrowse:AHEADERS[I])) $ "STATUS/TM/SERIE/LOJA/CLIE.FOR/ORIGEM/ESTRUTURA/STATUS/ZONA/ITEM/SERVI«O/BLOQ./SEQ."
      AAdd(aCampos,oBrowse:AHEADERS[I])
   Endif   
Next

DBSelectArea("SB1")

DEFINE MSDIALOG oDlgPesq TITLE "Pesquisar no "+cOpcao  OF oDlgPesq PIXEL FROM 010,010 TO 150,265 

@ 010,005 COMBOBOX cCampos ITEMS aCampos       SIZE 100,10 PIXEL OF oDlgPesq 
@ 030,005 MSGET oVar  VAR  cSeek Picture "@!"  SIZE 100,10 PIXEL OF oDlgPesq 
                                                 
@ 050,050 BUTTON "&Pesquisar" SIZE 30,14 PIXEL ACTION (Processa({|| fPesq(cOpcao,cCampos,cSeek)}),oDlgPesq:End())
@ 050,090 BUTTON "&Sair"      SIZE 30,14 PIXEL ACTION oDlgPesq:End()

ACTIVATE MSDIALOG oDlgPesq  CENTERED

RestArea(aArea)

Return

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fPesq(cOpcao,cCampos,cSeek)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Do Case
   Case cOpcao = "DETSB8"
     nSeek := Ascan(oDetSB8:AHEADERS,cCampos)
     IF (nPos := Ascan(aDetSB8, { |x| Alltrim(x[nSeek]) == Alltrim(cSeek) })) > 0
       oDetSB8:nAT := nPos
     Endif      
   Case cOpcao = "DETSBF" 
     nSeek := Ascan(oDetSBF:AHEADERS,cCampos)
     IF (nPos := Ascan(aDetSBF, { |x| Alltrim(x[nSeek]) == Alltrim(cSeek) })) > 0
       oDetSBF:nAT := nPos
     Endif      
   Case cOpcao = "PEDLIB"
     nSeek := Ascan(oPedLib:AHEADERS,cCampos)
     IF (nPos := Ascan(aPedLib, { |x| Alltrim(x[nSeek]) == Alltrim(cSeek) })) > 0
       oPedLib:nAT := nPos
     Endif      
   Case cOpcao = "EMPENHO"
     nSeek := Ascan(oEmpenho:AHEADERS,cCampos)
     IF (nPos := Ascan(aEmpenho, { |x| Alltrim(x[nSeek]) == Alltrim(cSeek) })) > 0
       oEmpenho:nAT := nPos
     Endif      
   Case cOpcao = "OP"
     nSeek := Ascan(oOP:AHEADERS,cCampos)
     IF (nPos := Ascan(aOP, { |x| Alltrim(x[nSeek]) == Alltrim(cSeek) })) > 0
       oOP:nAT := nPos
     Endif      
   Case cOpcao = "EMPENOP"
     nSeek := Ascan(oEmpenOP:AHEADERS,cCampos)
     IF (nPos := Ascan(aEmpenOP, { |x| Alltrim(x[nSeek]) == Alltrim(cSeek) })) > 0
       oEmpenOP:nAT := nPos
     Endif      
   Case cOpcao = "PEDBLOQ"
     nSeek := Ascan(oPedBloq:AHEADERS,cCampos)
     IF (nPos := Ascan(aPedBloq, { |x| Alltrim(x[nSeek]) == Alltrim(cSeek) })) > 0
       oPedBloq:nAT := nPos
     Endif      
   Case cOpcao = "DETSDA"
     nSeek := Ascan(oDetSDA:AHEADERS,cCampos)
     IF (nPos := Ascan(aDetSDA, { |x| Alltrim(x[nSeek]) == Alltrim(cSeek) })) > 0
       oDetSDA:nAT := nPos
     Endif      
   Case cOpcao = "SERVICOS"
     nSeek := Ascan(oServicos:AHEADERS,cCampos)
     IF (nPos := Ascan(aServicos, { |x| Alltrim(x[nSeek]) == Alltrim(cSeek) })) > 0
       oServicos:nAT := nPos
     Endif      
EndCase
Return (nPos)


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fPesqNumSeq()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
cNumSeq :=  aKarEnde[oKarEnde:nAT,09]
For nI:= 1 To Len(aKarEnde)
  IF nI <> oKarEnde:nAT .And. aKarEnde[nI,09] == cNumSeq
     oKarEnde:nAT := nI
     oKarEnde:Refresh()
     Exit
  Endif   
Next
Return