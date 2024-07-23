#include "rwmake.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±   
±±ºPrograma  ³AGR159    ºAutor  ³Deco                º Data ³  11/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gerar Arquivo texto SIMP                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR159()
**********************

SetPrvt("CPERG,AREGISTROS,I,J")
SetPrvt("NLINHAS,NARQS,NVALOR,NESTRU")
SetPrvt("NCAMPOS,_Y,XCONTEM,NPOS,NQUANT,NQTD10,NQTD20,NQTD40,NQTD90")
SetPrvt("LFAZ,_X,CALIASATU,CALIASDES,LTEM,CBAIRRO,CCONTA")
SetPrvt("ACAMPOS,ND2QUANT,NPONTO,CARQTRB,CPRODUTO,CINSCR,CCEP,CRESTO1,CRESTO2,CRESTO3,NTOTREG")
SetPrvt("CMMAAAA,CDDMMAAAAi,CDDMMAAAAf,COPERAC,CCOMP,XCERTIFI,CCERTIFI,XCOD,XEMISSAO")

cPerg:= "AGR159"
aRegistros := {}
Aadd(aRegistros,{cPerg,"01","Emissao de       ?","mv_ch1","D",8,0,0,"G","naovazio()","MV_PAR01","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"02","Emissao ate      ?","mv_ch2","D",8,0,0,"G","naovazio()","MV_PAR02","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"03","Data Fech Sld Ini?","mv_ch3","D",8,0,0,"G","naovazio()","MV_PAR03","","","","","","","","","","","","","","","",""})

CriaPerguntas(cPerg,aRegistros)

Pergunte(cPerg,.T.)

Processa( {|| GERAARQ() } )

Return nil

Static Function Geraarq
***********************

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Registros Saida (SD2) para geracao Arquivo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery := ""
cQuery += "SELECT * "
cQuery += "FROM "+RetSqlName("SD2")+" (NOLOCK) "
cQuery += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' "
cQuery += "AND D_E_L_E_T_ = '' AND D2_TIPO = 'N' "
cQuery += "AND D2_EMISSAO >= '"+dtos(mv_par01)+"' AND D2_EMISSAO <= '"+dtos(mv_par02)+"' "
cQuery += "AND (D2_TP = 'CO' OR D2_TP = 'GV') "

If (Select("MSD2") != 0)
	dbSelectArea("MSD2")
	dbCloseArea()
Endif
TCQuery cQuery NEW ALIAS "MSD2"
TCSetField("MSD2","D2_EMISSAO","D",08,0)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Registros Entrada (SD1) para geracao Arquivo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := ""
cQuery += "SELECT * "
cQuery += "FROM "+RetSqlName("SD1")+" (NOLOCK) "
cQuery += "WHERE D1_FILIAL = '"+xFilial("SD1")+"' "
cQuery += "AND D_E_L_E_T_ = '' AND D1_TIPO IN ('D','N') "  
cQuery += "AND D1_DTDIGIT >= '"+dtos(mv_par01)+"' AND D1_DTDIGIT <= '"+dtos(mv_par02)+"' "  //ALERADO D1_EMISSAO PARA D1_DIGIT
cQuery += "AND (D1_TP = 'CO' OR D1_TP = 'GV') "

If (Select("MSD1") != 0)
	dbSelectArea("MSD1")
	dbCloseArea()
Endif
TCQuery cQuery NEW ALIAS "MSD1"
TCSetField("MSD1","D1_DTDIGIT","D",08,0)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Registros Saidas Producao SC2 Feitas manualmente Luis/Base
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := ""
cQuery += "SELECT * "
cQuery += "FROM "+RetSqlName("SC2")+" (NOLOCK) "
cQuery += "WHERE C2_FILIAL = '"+xFilial("SC2")+"' "
cQuery += "AND D_E_L_E_T_ = '' AND C2_PRIOR = '500' "
cQuery += "AND C2_EMISSAO >= '"+dtos(mv_par01)+"' AND C2_EMISSAO <= '"+dtos(mv_par02)+"' "

If (Select("MSC2") != 0)
	dbSelectArea("MSC2")
	dbCloseArea()
Endif
TCQuery cQuery NEW ALIAS "MSC2"
TCSetField("MSC2","C2_EMISSAO","D",08,0)
		   
cMMAAAA    := Substr(Dtos(MV_PAR01),5,2)+Substr(Dtos(MV_PAR01),1,4)
cDDMMAAAAi := Substr(Dtos(MV_PAR01),7,2)+Substr(Dtos(MV_PAR01),5,2)+Substr(Dtos(MV_PAR01),1,4)
cDDMMAAAAf := Substr(Dtos(MV_PAR02),7,2)+Substr(Dtos(MV_PAR02),5,2)+Substr(Dtos(MV_PAR02),1,4)

cDiretorio := 'C:\SIMP\'
cArq       := cDiretorio + cDDMMAAAAi +'-'+ cDDMMAAAAf  + '.TXT'
MakeDir(cDiretorio)

if file(cArq)
   ferase(cArq)
endif

//
// Criacao do arquivo texto informado.                          
//
nHdlArq := MSFcreate(cArq)                     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selecao de Chaves para os arquivos                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(DbSetOrder(1))               // filial+cod+loja
SB9->(DbSetOrder(2))               // filial+data

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracoes de arrays                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru := {}
aadd(aStru,{'SEQ'    ,'N',10,0})
aadd(aStru,{'LIN'    ,'C',198,0})
cArq := CriaTrab(aStru,.t.)
use &cArq alias AGR159 new
Index on SEQ to AGR1591

aStru := {}
aadd(aStru,{'PROOPE' ,'C',09,0})
aadd(aStru,{'QTDEI'  ,'N',14,3}) // Estoque Inicial
aadd(aStru,{'QTDKGI' ,'N',14,3})
aadd(aStru,{'QTDEF'  ,'N',14,3}) // Estoque Final
aadd(aStru,{'QTDKGF' ,'N',14,3})
aadd(aStru,{'QTDES'  ,'N',14,3}) // Total Saidas
aadd(aStru,{'QTDKGS' ,'N',14,3})
aadd(aStru,{'QTDEE'  ,'N',14,3}) // Total Entradas
aadd(aStru,{'QTDKGE' ,'N',14,3})
aadd(aStru,{'QTDETE' ,'N',14,3}) // Total Transferencia Entradas
aadd(aStru,{'QTDKGTE','N',14,3})
aadd(aStru,{'QTDETS' ,'N',14,3}) // Total Transferencia Saidas
aadd(aStru,{'QTDKGTS','N',14,3})
cArq := CriaTrab(aStru,.t.)
use &cArq alias ESTOQUE new
Index on PROOPE to ESTOQUE1

cConta := 0
*
* Extrai Estoque Inicial
*        
DbSelectArea("SB9")
dbSetOrder(2)
DbGotop()
Procregua(Reccount())
DbSeek(xFilial("SB9")+DTOS(MV_PAR03))
While !Eof() .And. xFilial("SB9") == SB9->B9_FILIAL .And. DTOS(SB9->B9_DATA) == DTOS(MV_PAR03)
   
   Incproc()

   cProOpe:= '000000000'
   cQtdKg := 0

   If Alltrim(SB9->B9_COD) == '00004'
      cProOpe := '320101001'
      cQtdKg  := SB9->B9_QINI * 0.7430
   EndIf
   If Alltrim(SB9->B9_COD) == '00005' .or.;
      Alltrim(SB9->B9_COD) == '00014' .or.;
      Alltrim(SB9->B9_COD) == '00032'
      cProOpe := '320102001'
      cQtdKg  := SB9->B9_QINI * 0.7430
   EndIf
   If Alltrim(SB9->B9_COD) == '00006' .or.;
      Alltrim(SB9->B9_COD) == '00024' .or.;
      Alltrim(SB9->B9_COD) == '00034'
      cProOpe := '320102002'
      cQtdKg  := SB9->B9_QINI * 0.7430
   EndIf
   If Alltrim(SB9->B9_COD) == '00007'    .or.;
      Alltrim(SB9->B9_COD) == '00060001' .or.;
      Alltrim(SB9->B9_COD) == '00060002'
      cProOpe := '410102001'
      cQtdKg  := SB9->B9_QINI * 0.8114
   EndIf
   If Alltrim(SB9->B9_COD) == '00008' .or.;  //ALTERADO CFE FABI 20/08/08
      Alltrim(SB9->B9_COD) == '00031' 
//      cProOpe := '420101001'
      cProOpe := '420101004'  // Novo codigo cfe Fabi 15/03/2007
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
   If Alltrim(SB9->B9_COD) == '00103' 
      cProOpe := '820101001'  // Novo codigo cfe Fabi 20/08/2008
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf   
   
//   If Alltrim(SB9->B9_COD) == '00008' .or.;   AQUI !! ALTERADO 20/08/08
//      Alltrim(SB9->B9_COD) == '00103' 
//      cProOpe := '8200101001'  // Novo codigo cfe Fabi 11/04/2008
//      cQtdKg  := SB9->B9_QINI * 0.8480
//   EndIf                            

   If Alltrim(SB9->B9_COD) == '00086' .or.;
		Alltrim(SB9->B9_COD) == '00076'    
      cProOpe := '820101002'  // Novo codigo cfe Fabi 08/08/2007
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
   If Alltrim(SB9->B9_COD) == '00078' .or.;
      Alltrim(SB9->B9_COD) == '00087'      
      cProOpe := '820101009'  // Novo codigo cfe Fabi 08/08/2007
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
   If Alltrim(SB9->B9_COD) == '00097' .or.;
      Alltrim(SB9->B9_COD) == '00096'      
      cProOpe := '820101007'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
/*   If Alltrim(SB9->B9_COD) == '00098' .or.;
      Alltrim(SB9->B9_COD) == '00099'      
      cProOpe := '820101017'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf */  //21/01/09
   If Alltrim(SB9->B9_COD) == '00100' .or.;
      Alltrim(SB9->B9_COD) == '00101'      
      cProOpe := '820101008'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
   If Alltrim(SB9->B9_COD) == '00083'
      cProOpe := '220101005'  // Novo codigo cfe Fabi 10/08/2007
      cQtdKg  := SB9->B9_QINI * 0.7500
   EndIf
   If Alltrim(SB9->B9_COD) == '00095'
      cProOpe := '220101003'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := SB9->B9_QINI * 0.7500
   EndIf
//   If Alltrim(SB9->B9_COD) == '00009' .or.;  ALTERADO FABI 20/08/08
//      Alltrim(SB9->B9_COD) == '00033' 
//      cProOpe := '420101002'
//      cProOpe := '420101005'  // Novo codigo cfe Fabi 15/03/2007
//      cQtdKg  := SB9->B9_QINI * 0.8480
//   EndIf
//   If Alltrim(SB9->B9_COD) == '00023' .or.; ALTERADO FABI 20/08/08
//      Alltrim(SB9->B9_COD) == '00085'
//      cProOpe := '420102001'
//      cProOpe := '420102004'  // Novo codigo cfe Fabi 15/03/2007
//      cQtdKg  := SB9->B9_QINI * 0.8480
//   EndIf
   If Alltrim(SB9->B9_COD) == '00078' 
      cProOpe := '420102002'  // Novo codigo cfe Fabi 12/07/2007
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
   If Alltrim(SB9->B9_COD) == '00019' .or.;
      Alltrim(SB9->B9_COD) == '00074' 
      cProOpe := '420201001'
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
   If Alltrim(SB9->B9_COD) == '00010' .or.;
      Alltrim(SB9->B9_COD) == '00011' .or.;
      Alltrim(SB9->B9_COD) == '00092'
      cProOpe := '510101001'
      cQtdKg  := SB9->B9_QINI * 1.0000
   EndIf
   If Alltrim(SB9->B9_COD) == '00001' .or.;
      Alltrim(SB9->B9_COD) == '00002' .or.;
      Alltrim(SB9->B9_COD) == '00003' .or.;
      Alltrim(SB9->B9_COD) == '00058' .or.;
      Alltrim(SB9->B9_COD) == '00084' .or.;
      Alltrim(SB9->B9_COD) == '00090' .or.;
      Alltrim(SB9->B9_COD) == '00091' 
      cProOpe := '560101001'
      cQtdKg  := SB9->B9_QINI * 1.0000
   EndIf
   If Alltrim(SB9->B9_COD) == '00015' .or.;
      Alltrim(SB9->B9_COD) == '00072' .or.;
      Alltrim(SB9->B9_COD) == '00073' 
      cProOpe := '810101001'
      cQtdKg  := SB9->B9_QINI * 0.8100
   EndIf
   If Alltrim(SB9->B9_COD) == '00013' 
      cProOpe := '810102001'
      cQtdKg  := SB9->B9_QINI  * 0.8100
   EndIf
   If Alltrim(SB9->B9_COD) == '00016' //.Or.;
//		Alltrim(SB9->B9_COD) == '00810002'
      cProOpe := '740101001'
      cQtdKg  := SB9->B9_QINI * 0.7430
   EndIf
   If Alltrim(SB9->B9_COD) == '00017' .Or.;
		Alltrim(SB9->B9_COD) == '00810001' .OR. ;
   	Alltrim(SB9->B9_COD) == '00810002'
      cProOpe := '740101002'
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf

   If cProOpe == '000000000'
   	  Sele SB9 
      DbSkip()
      Loop
   Endif 
   
   cQINI := int(SB9->B9_QINI)
   If cQINI == 0
      cQINI := 1 // Considera qte igual a 1 qdo nao tiver estoque cfe Fabi
   Endif
   SELE ESTOQUE
   If !DbSeek(cProOpe)
      If cQINI <> 0
	      Reclock("ESTOQUE",.T.)
	      ESTOQUE->PROOPE := cProOpe
	      ESTOQUE->QTDEI  := int(cQINI)
	      ESTOQUE->QTDKGI := cQtdKg
	      MsUnlock("ESTOQUE") 
	   Endif   
   Else
      Reclock("ESTOQUE",.F.)
      ESTOQUE->QTDEI  := ESTOQUE->QTDEI  + int(cQINI)
      ESTOQUE->QTDKGI := ESTOQUE->QTDKGI + cQtdKg
      MsUnlock("ESTOQUE") 
   Endif
   
 	Sele SB9 
   DbSkip()

End

Sele ESTOQUE
DbGotop()
Procregua(Reccount())
While !Eof() 
   
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := '1001799935'         // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cOperac := '3010003' // Operacao para estoque inicial
   
   cLinha := cLinha + cOperac   // Operacao
   
   cLinha := cLinha + '1032183' // Cod Instalacao 1
   
   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := ESTOQUE->QTDKGI

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDEI)
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000
   
   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '0' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

   cLinha := cLinha + cMun_ANP // Codigo Municipio
   cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
   cLinha := cLinha + '0000' // Cod do país
   cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
   cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
   cDoc   := '0000000'    
   cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
   cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR03),2)+strzero(month(MV_PAR03),2)+strzero(year(MV_PAR03),4)	
   cLinha := cLinha + cDtEmi // Data da operacao Comercial
   cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
   cProRes := '000000000' // Codigo do Produto/Operacao Resultante
   cRecGLP := '00'    // Recipiente de GLP
	
   cLinhax := ''
   If !Empty(cFisQui1) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif

   Sele ESTOQUE
   DbSkip()

End
*
* Extrai Estoque Final
*        
DbSelectArea("SB9")
dbSetOrder(2)
DbGotop()
Procregua(Reccount())
DbSeek(xFilial("SB9")+DTOS(MV_PAR02))
While !Eof() .And. xFilial("SB9") == SB9->B9_FILIAL .And. DTOS(SB9->B9_DATA) == DTOS(MV_PAR02)
   
   Incproc()

   cProOpe:= '000000000'
   cQtdKg := 0

   If Alltrim(SB9->B9_COD) == '00004'
      cProOpe := '320101001'
      cQtdKg  := SB9->B9_QINI * 0.7430
   EndIf
   If Alltrim(SB9->B9_COD) == '00005' .or.;
      Alltrim(SB9->B9_COD) == '00014' .or.;
      Alltrim(SB9->B9_COD) == '00032'
      cProOpe := '320102001'
      cQtdKg  := SB9->B9_QINI * 0.7430
   EndIf
   If Alltrim(SB9->B9_COD) == '00006' .or.;
      Alltrim(SB9->B9_COD) == '00024' .or.;
      Alltrim(SB9->B9_COD) == '00034'
      cProOpe := '320102002'
      cQtdKg  := SB9->B9_QINI * 0.7430
   EndIf
   If Alltrim(SB9->B9_COD) == '00007'    .or.;
      Alltrim(SB9->B9_COD) == '00060001' .or.;
      Alltrim(SB9->B9_COD) == '00060002'
      cProOpe := '410102001'
      cQtdKg  := SB9->B9_QINI * 0.8114
   EndIf
   If Alltrim(SB9->B9_COD) == '00008' .or.; //ALTERADO CFE FABI 20/08/08
      Alltrim(SB9->B9_COD) == '00031' 
//      cProOpe := '420101001'
      cProOpe := '420101004'  // Novo codigo cfe Fabi 15/03/2007
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
   If Alltrim(SB9->B9_COD) == '00103' 
      cProOpe := '820101001'  // Novo codigo cfe Fabi 20/08/08
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
   
   If Alltrim(SB9->B9_COD) == '00008' 
      cProOpe := '420101004'  // Novo codigo cfe Fabi 11/01/2009
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf

   
   If Alltrim(SB9->B9_COD) == '00103' 
      cProOpe := '820101001'  // Novo codigo cfe Fabi 11/04/2008
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
   If Alltrim(SB9->B9_COD) == '00086'// .or.;
   	Alltrim(SB9->B9_COD) == '00076'    
      cProOpe := '820101002'  // Novo codigo cfe Fabi 08/08/2007
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
   If Alltrim(SB9->B9_COD) == '00078' .or.;
      Alltrim(SB9->B9_COD) == '00087'       
      cProOpe := '820101009'  // Novo codigo cfe Fabi 08/08/2007
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
   If Alltrim(SB9->B9_COD) == '00097' .or.;
      Alltrim(SB9->B9_COD) == '00096'       
      cProOpe := '820101007'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
/*   If Alltrim(SB9->B9_COD) == '00098' .or.;
      Alltrim(SB9->B9_COD) == '00099'       
      cProOpe := '820101017'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf */ //21/01/09
   If Alltrim(SB9->B9_COD) == '00100' .or.;
      Alltrim(SB9->B9_COD) == '00101'       
      cProOpe := '820101008'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
   If Alltrim(SB9->B9_COD) == '00083'
      cProOpe := '220101005'  // Novo codigo cfe Fabi 10/08/2007
      cQtdKg  := SB9->B9_QINI * 0.7500
   EndIf
   If Alltrim(SB9->B9_COD) == '00095'
      cProOpe := '220101003'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := SB9->B9_QINI * 0.7500
   EndIf
//   If Alltrim(SB9->B9_COD) == '00009' .or.; ALTERADO FABI 20/08/08
//      Alltrim(SB9->B9_COD) == '00033' 
//      cProOpe := '420101002'
//      cProOpe := '420101005'  // Novo codigo cfe Fabi 15/03/2007
//      cQtdKg  := SB9->B9_QINI * 0.8480
//   EndIf
//   If Alltrim(SB9->B9_COD) == '00023' .or.;  ALTERADO FABI 20/08/08
//		Alltrim(SB9->B9_COD) == '00085'     
//      cProOpe := '420102001'
//      cProOpe := '420102004'  // Novo codigo cfe Fabi 12/07/2007
//      cQtdKg  := SB9->B9_QINI * 0.8480
//   EndIf
   If Alltrim(SB9->B9_COD) == '00078' 
      cProOpe := '420102002'  // Novo codigo cfe Fabi 15/03/2007
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
   If Alltrim(SB9->B9_COD) == '00019' .or.;
      Alltrim(SB9->B9_COD) == '00074' 
      cProOpe := '420201001'
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf
   If Alltrim(SB9->B9_COD) == '00010' .or.;
      Alltrim(SB9->B9_COD) == '00011' .or.;
      Alltrim(SB9->B9_COD) == '00092' 
      cProOpe := '510101001'
      cQtdKg  := SB9->B9_QINI * 1.0000
   EndIf
   If Alltrim(SB9->B9_COD) == '00001' .or.;
      Alltrim(SB9->B9_COD) == '00002' .or.;
      Alltrim(SB9->B9_COD) == '00003' .or.;
      Alltrim(SB9->B9_COD) == '00058' .or.;
      Alltrim(SB9->B9_COD) == '00084' .or.;
      Alltrim(SB9->B9_COD) == '00090' .or.;
      Alltrim(SB9->B9_COD) == '00091' 
      cProOpe := '560101001'
      cQtdKg  := SB9->B9_QINI * 1.0000
   EndIf
   If Alltrim(SB9->B9_COD) == '00015' .or.;
      Alltrim(SB9->B9_COD) == '00072' .or.;
      Alltrim(SB9->B9_COD) == '00073'
      cProOpe := '810101001'
      cQtdKg  := SB9->B9_QINI * 0.8100
   EndIf
   If Alltrim(SB9->B9_COD) == '00013' 
      cProOpe := '810102001'
      cQtdKg  := SB9->B9_QINI  * 0.8100
   EndIf
   If Alltrim(SB9->B9_COD) == '00016' // .Or.;
//		Alltrim(SB9->B9_COD) == '00810002'
      cProOpe := '740101001'
      cQtdKg  := SB9->B9_QINI * 0.7430
   EndIf
   If Alltrim(SB9->B9_COD) == '00017' .Or.;
		Alltrim(SB9->B9_COD) == '00810001' .OR. ;
   	Alltrim(SB9->B9_COD) == '00810002'
      cProOpe := '740101002'
      cQtdKg  := SB9->B9_QINI * 0.8480
   EndIf

   If cProOpe == '000000000'
   	  Sele SB9 
      DbSkip()
      Loop
   Endif

   cQINI := int(SB9->B9_QINI)
   If cQINI == 0
      cQINI := 1 // Considera qte igual a 1 qdo nao tiver estoque cfe Fabi
   Endif
   
   SELE ESTOQUE
   If !DbSeek(cProOpe)
   	  If cQINI <> 0
	      Reclock("ESTOQUE",.T.)
	      ESTOQUE->PROOPE := cProOpe
	      ESTOQUE->QTDEF  := int(cQINI)
	      ESTOQUE->QTDKGF := cQtdKg
	      MsUnlock("ESTOQUE") 
	   EndIf
   Else
      Reclock("ESTOQUE",.F.)
      ESTOQUE->QTDEF  := ESTOQUE->QTDEF  + int(cQINI)
      ESTOQUE->QTDKGF := ESTOQUE->QTDKGF + cQtdKg
      MsUnlock("ESTOQUE") 
   Endif
   
   Sele SB9 
   DbSkip()

End

Sele ESTOQUE
DbGotop()
Procregua(Reccount())
While !Eof() 
   
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := '1001799935'         // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cOperac := '3020003' // Operacao para estoque final
   
   cLinha := cLinha + cOperac   // Operacao
   
   cLinha := cLinha + '1032183' // Cod Instalacao 1
   
   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := ESTOQUE->QTDKGF
   
   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDEF)
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000
   
   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif

   cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '0' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

   cLinha := cLinha + cMun_ANP // Codigo Municipio
   cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
   cLinha := cLinha + '0000' // Cod do país
   cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
   cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
   cDoc   := '0000000'    
   cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
   cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR02),2)+strzero(month(MV_PAR02),2)+strzero(year(MV_PAR02),4)	
   cLinha := cLinha + cDtEmi // Data da operacao Comercial
   cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
   cProRes := '000000000' // Codigo do Produto/Operacao Resultante
   cRecGLP := '00'    // Recipiente de GLP
	
   cLinhax := ''
   If !Empty(cFisQui1) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif

   Sele ESTOQUE
   DbSkip()

End
*
* Extrai NFs de Saida
*        
sele MSD2
dbgotop()
Procregua(Reccount())
While !eof() 
   
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := '1001799935'         // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   If Alltrim(MSD2->D2_CF) == '5655' .Or. Alltrim(MSD2->D2_CF) == '6655'
      cOperac := '1012001'
   Endif
   If Alltrim(MSD2->D2_CF) == '5656' .Or. Alltrim(MSD2->D2_CF) == '6656'
      cOperac := '1012002'
   Endif
   If Alltrim(MSD2->D2_CF) == '5661' .Or. Alltrim(MSD2->D2_CF) == '6661'
      cOperac := '1012004'
   Endif
   If Alltrim(MSD2->D2_CF) == '5659' .Or. Alltrim(MSD2->D2_CF) == '6659'
      cOperac := '1012999'
   Endif
   
   If cOperac == '0000000'
      Sele MSD2
      DbSkip()
      Loop
   Endif

 
   cLinha := cLinha + cOperac   // Operacao
   
   cLinha := cLinha + '1032183' // Cod Instalacao 1
   
   cInstANP := '0000000'
   DbSelectArea("SA1")
   DbGotop()
   DbSeek(xFilial("SA1")+MSD2->D2_CLIENTE+MSD2->D2_LOJA)
   If !Empty(SA1->A1_INSTANP)
      cInstANP := SA1->A1_INSTANP
      IF Len(Alltrim(SA1->A1_INSTANP)) < 7
         cInstANP := StrZero(val(Alltrim(SA1->A1_INSTANP)),7)
      Endif
   Endif
   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   Sele MSD2

   xCod     := MSD2->D2_COD 
   xEmissao := MSD2->D2_EMISSAO 
   *
   * Esta parte para buscar Certificado cfe Fabi 02/01/2007
   *
	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("SZ0")+" (NOLOCK) "
	cQuery += "WHERE Z0_FILIAL = '"+xFilial("SZ0")+"' "
	cQuery += "AND D_E_L_E_T_ = '' "
	cQuery += "AND Z0_COD = '"+xCod+"' "
	cQuery += "AND Z0_DTINI <= '"+Dtos(xEmissao)+"' "
	cQuery += "AND Z0_DTFIM >= '"+Dtos(xEmissao)+"' "

	If (Select("MSZ0") <> 0)
		dbSelectArea("MSZ0")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "MSZ0"

	xCertifi := Space(1)
	DbSelectArea("MSZ0")
	DbGoTop()
	While !Eof()  
		xCertifi := MSZ0->Z0_CERTIFI
		DbSelectArea("MSZ0")
	   DbSkip()
	EndDo
	cCertifi := Space(1)
	If !Empty(xCERTIFI) 
		cCertifi := Replicate('0',10-Len(Alltrim(xCertifi))) + Alltrim(xCertifi)
	Else
	   cCertifi := Replicate('0',10)
	EndIf

   Sele MSD2

   cProOpe:= '000000000'
   cQtdKg := 0
   If Alltrim(MSD2->D2_COD) == '00004'
      cProOpe := '320101001'
      cQtdKg  := MSD2->D2_QUANT * 0.7430
   EndIf
   If Alltrim(MSD2->D2_COD) == '00005' .or.;
      Alltrim(MSD2->D2_COD) == '00014' .or.;
      Alltrim(MSD2->D2_COD) == '00032'
      cProOpe := '320102001'
      cQtdKg  := MSD2->D2_QUANT * 0.7430
   EndIf
   If Alltrim(MSD2->D2_COD) == '00006' .or.;
      Alltrim(MSD2->D2_COD) == '00024' .or.;
      Alltrim(MSD2->D2_COD) == '00034'
      cProOpe := '320102002'
      cQtdKg  := MSD2->D2_QUANT * 0.7430
   EndIf
   If Alltrim(MSD2->D2_COD) == '00007'    .or.;
      Alltrim(MSD2->D2_COD) == '00060001' .or.;
      Alltrim(MSD2->D2_COD) == '00060002'
      cProOpe := '410102001'
      cQtdKg  := MSD2->D2_QUANT * 0.8114
   EndIf
   If Alltrim(MSD2->D2_COD) == '00008' .or.; //ALTERADO CFE FABI 20/08/08
      Alltrim(MSD2->D2_COD) == '00031' 
//      cProOpe := '420101001'
      cProOpe := '420101004'  // Novo codigo cfe Fabi 15/03/2007
      cQtdKg  := MSD2->D2_QUANT * 0.8480
   EndIf
   If Alltrim(MSD2->D2_COD) == '00103' 
      cProOpe := '820101001'  // Novo codigo cfe Fabi 20/08/08
      cQtdKg  := MSD2->D2_QUANT * 0.8480
   EndIf                    
   
   If Alltrim(MSD2->D2_COD) == '00008'    
      cProOpe := '420101004'  // Novo codigo cfe Fabi 11/04/2008
      cQtdKg  := MSD2->D2_QUANT * 0.8480
   EndIf
   If Alltrim(MSD2->D2_COD) == '00086'.or.;
		Alltrim(MSD2->D2_COD) == '00076'    
      cProOpe := '820101002'  // Novo codigo cfe Fabi 08/08/2007
      cQtdKg  := MSD2->D2_QUANT * 0.8480
   EndIf
   If Alltrim(MSD2->D2_COD) == '00078' .or.;
      Alltrim(MSD2->D2_COD) == '00087'      
      cProOpe := '820101009'  // Novo codigo cfe Fabi 08/08/2007
      cQtdKg  := MSD2->D2_QUANT * 0.8480
   EndIf
   If Alltrim(MSD2->D2_COD) == '00097' .or.;
      Alltrim(MSD2->D2_COD) == '00096'      
      cProOpe := '820101007'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := MSD2->D2_QUANT * 0.8480
   EndIf
/*   If Alltrim(MSD2->D2_COD) == '00098' .or.;
      Alltrim(MSD2->D2_COD) == '00099'      
      cProOpe := '820101017'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := MSD2->D2_QUANT * 0.8480
   EndIf */ //21/01/09
   If Alltrim(MSD2->D2_COD) == '00100' .or.;
      Alltrim(MSD2->D2_COD) == '00101'      
      cProOpe := '820101008'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := MSD2->D2_QUANT * 0.8480
   EndIf
   If Alltrim(MSD2->D2_COD) == '00083'
      cProOpe := '220101005'  // Novo codigo cfe Fabi 10/08/2007
      cQtdKg  := MSD2->D2_QUANT * 0.7500
   EndIf
   If Alltrim(MSD2->D2_COD) == '00095'
      cProOpe := '220101003'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := MSD2->D2_QUANT * 0.7500
   EndIf
//   If Alltrim(MSD2->D2_COD) == '00009' .or.; ALTERADO FABI 20/08/08
//      Alltrim(MSD2->D2_COD) == '00033' 
//      cProOpe := '420101002'
//      cProOpe := '420101005'  // Novo codigo cfe Fabi 15/03/2007
//      cQtdKg  := MSD2->D2_QUANT * 0.8480
//   EndIf
//   If Alltrim(MSD2->D2_COD) == '00023' .or.; ALTERADO FABI 20/08/08
//		Alltrim(MSD2->D2_COD) == '00085'     
//      cProOpe := '420102001'
//      cProOpe := '420102004'  // Novo codigo cfe Fabi 15/03/2007
//      cQtdKg  := MSD2->D2_QUANT * 0.8480
//   EndIf
   If Alltrim(MSD2->D2_COD) == '00078' 
      cProOpe := '420102002'  // Novo codigo cfe Fabi 12/07/2007
      cQtdKg  := MSD2->D2_QUANT * 0.8480
   EndIf
   If Alltrim(MSD2->D2_COD) == '00019' .or.;
      Alltrim(MSD2->D2_COD) == '00074' 
      cProOpe := '420201001'
      cQtdKg  := MSD2->D2_QUANT * 0.8480
   EndIf
   If Alltrim(MSD2->D2_COD) == '00010' .or.;
      Alltrim(MSD2->D2_COD) == '00011' .or.;
      Alltrim(MSD2->D2_COD) == '00092' 
      cProOpe := '510101001'
      cQtdKg  := MSD2->D2_QUANT * 1.0000
   EndIf
   If Alltrim(MSD2->D2_COD) == '00001' .or.;
      Alltrim(MSD2->D2_COD) == '00002' .or.;
      Alltrim(MSD2->D2_COD) == '00003' .or.;
      Alltrim(MSD2->D2_COD) == '00058' .or.;
      Alltrim(MSD2->D2_COD) == '00084' .or.;
      Alltrim(MSD2->D2_COD) == '00090' .or.;
      Alltrim(MSD2->D2_COD) == '00091' 
      cProOpe := '560101001'
      cQtdKg  := MSD2->D2_QUANT * 1.0000
   EndIf
   If Alltrim(MSD2->D2_COD) == '00015' .or.;
      Alltrim(MSD2->D2_COD) == '00072' .or.;
      Alltrim(MSD2->D2_COD) == '00073' 
      cProOpe := '810101001'
      cQtdKg  := MSD2->D2_QUANT * 0.8100
   EndIf
   If Alltrim(MSD2->D2_COD) == '00013' 
      cProOpe := '810102001'
      cQtdKg  := MSD2->D2_QUANT * 0.8100
   EndIf
   If Alltrim(MSD2->D2_COD) == '00016' //.Or.;
//		Alltrim(MSD2->D2_COD) == '00810002'
      cProOpe := '740101001'
      cQtdKg  := MSD2->D2_QUANT * 0.7430
   EndIf
   If Alltrim(MSD2->D2_COD) == '00017' .Or.;
		Alltrim(MSD2->D2_COD) == '00810001' .OR. ;
		Alltrim(MSD2->D2_COD) == '00810002'
      cProOpe := '740101002'
      cQtdKg  := MSD2->D2_QUANT * 0.8480
   EndIf

   If cProOpe == '000000000'
   	  Sele MSD2
      DbSkip()
      Loop
   Endif


   SELE ESTOQUE  // Extrai Total Saidas
   If !DbSeek(cProOpe)
      Reclock("ESTOQUE",.T.)
      ESTOQUE->PROOPE := cProOpe
      ESTOQUE->QTDES  := int(MSD2->D2_QUANT)
      ESTOQUE->QTDKGS := cQtdKg
      MsUnlock("ESTOQUE") 
   Else
      Reclock("ESTOQUE",.F.)
      ESTOQUE->QTDES  := ESTOQUE->QTDES  + int(MSD2->D2_QUANT)
      ESTOQUE->QTDKGS := ESTOQUE->QTDKGS + cQtdKg
      MsUnlock("ESTOQUE") 
   Endif

   SELE MSD2
   
   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(MSD2->D2_QUANT)
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'
   Sele SA1
   If Empty(SA1->A1_INSTANP)
      If SA1->A1_PESSOA == 'J' .or. SA1->A1_PESSOA == 'F'
         cIdent := SA1->A1_CGC
      Endif
      If SA1->A1_PESSOA == 'F'
         cIdent := StrZero(val(Alltrim(SA1->A1_CGC)),14)
      Endif
   Endif
   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000'
   If !Empty(SA1->A1_Mun_ANP)
      cMun_ANP := SA1->A1_Mun_ANP
      IF Len(Alltrim(SA1->A1_Mun_ANP)) < 7
         cMun_ANP := StrZero(val(Alltrim(SA1->A1_Mun_ANP)),7)
      Endif
   Endif
   cAtivida := '00000'  
   If !Empty(SA1->A1_ATIVIDA)
      cAtivida := SA1->A1_ATIVIDA
      IF Len(Alltrim(SA1->A1_ATIVIDA)) < 5
         cAtivida := StrZero(val(Alltrim(SA1->A1_ATIVIDA)),5)
      Endif
   Endif
   If cOperac == '1012002' .And. Alltrim(SA1->A1_TIPO) <> 'F'  // Caso Venda Agente Nao Regulado  e Cliente nao Consumidor Final
      cMun_ANP := '0000000'                                    // nao aparecer atividade e cod cidade cfe Fabi
      cAtivida := '00000'
   Endif
   cLinha := cLinha + cMun_ANP // Codigo Municipio
   cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
   cLinha := cLinha + '0000' // Cod do país
   cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
   cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
   Sele MSD2
   cDoc   := MSD2->D2_DOC
   IF Len(Alltrim(MSD2->D2_DOC)) < 7
      cDoc := StrZero(val(Alltrim(MSD2->D2_DOC)),7)
   Endif
   cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
   cLinha := cLinha + '04' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MSD2->D2_EMISSAO),2)+strzero(month(MSD2->D2_EMISSAO),2)+strzero(year(MSD2->D2_EMISSAO),4)	//AQUI EMISSAO
   cLinha := cLinha + cDtEmi // Data da operacao Comercial
   cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '   '
   cMetodo1 := '   '
   cUnMedi1 := '  '
   cVlCara1 := '          '
   cMassaE1 := '       '
   cFisQui11:= '   '
   cMetodo11:= '   '
   cUnMedi11:= '  '
   cVlCara11:= '          '
   cMassaE11:= '       '
   cFisQui2 := '   '
   cMetodo2 := '   '
   cUnMedi2 := '  '
   cVlCara2 := '          '
   cMassaE2 := '       '
   cFisQui21:= '   '
   cMetodo21:= '   '
   cUnMedi21:= '  '
   cVlCara21:= '          '
   cMassaE21:= '       '
   cFisQui3 := '   '
   cMetodo3 := '   '
   cUnMedi3 := '  '
   cVlCara3 := '          '
   cMassaE3 := '       '
   cFisQui4 := '   '
   cMetodo4 := '   '
   cUnMedi4 := '  '
   cVlCara4 := '          '
   cMassaE4 := '       '
   cFisQui5 := '   '
   cMetodo5 := '   '
   cUnMedi5 := '  '
   cVlCara5 := '          '
   cMassaE5 := '       '
   
   *
   * Cfe Fabi 02/01/2007 somente sera considerar uma linha de caracteristica cfe abaixo
   *
   cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	cVlCara1 := cCertifi // Valor Encontrado da Caracteristica
	If SD2->D2_UM == 'KG' // Caso Seja unidade medida KG cfe Fabi/Batista considera massa igual a qtde vendida 02/01/2007
      cMassaE1 := StrZero(int(MSD2->D2_QUANT),7)  // Massa Especifica do Produto
 	Else
      cMassaE1 := '0000000'    // Massa Especifica do Produto
   Endif
   
/*   
   If Alltrim(MSD2->D2_COD) == '00007'    .or.;  // Para Querosene Colocar Zeros cfe Fabi
      Alltrim(MSD2->D2_COD) == '00060001' .or.;
      Alltrim(MSD2->D2_COD) == '00060002'
	  cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	  cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	  cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	  cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
      cMassaE1 := '0000000'    // Massa Especifica do Produto
   Endif

   If Alltrim(MSD2->D2_COD) == '00001' .or.; // Para Oleo Xisto Colocar Zeros cfe Fabi
      Alltrim(MSD2->D2_COD) == '00002' .or.;
      Alltrim(MSD2->D2_COD) == '00003'
	  cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	  cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	  cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	  cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
      cMassaE1 := '0000000'    // Massa Especifica do Produto
   Endif

   If Alltrim(MSD2->D2_COD) == '00010' .or.; // Para Oleo Combustivel 1A Zeros Cfe Fabi 
      Alltrim(MSD2->D2_COD) == '00011' .or.; // Para Oleo Combustivel 2A Zeros Cfe Fabi 
      Alltrim(MSD2->D2_COD) == '00016' .or.; // Para Aditivo Hitec 6421 (Gasolina) Zeros Cfe Fabi
      Alltrim(MSD2->D2_COD) == '00017' .or.; // Para Aditivo Hitec 4130 (Diesel)   Zeros Cfe Fabi
      Alltrim(MSD2->D2_COD) == '00810002' .or.; // Para Aditivo Hitec 6421 (Gasolina) Zeros Cfe Fabi
      Alltrim(MSD2->D2_COD) == '00810001'       // Para Aditivo Hitec 4130 (Diesel)   Zeros Cfe Fabi
	  cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	  cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	  cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	  cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
      cMassaE1 := '0000000'    // Massa Especifica do Produto
   Endif

   If Alltrim(MSD2->D2_COD) == '00031' .or.;
	  Alltrim(MSD2->D2_COD) == '00033' .or.;
	  Alltrim(MSD2->D2_COD) == '00008' .or.;
	  Alltrim(MSD2->D2_COD) == '00009' .or.;
	  Alltrim(MSD2->D2_COD) == '00019' .or.;
	  Alltrim(MSD2->D2_COD) == '00074' .or.;
	  Alltrim(MSD2->D2_COD) == '00023' 

	  cFisQui1 := '004' // Codigo da Caracteristica Fisico-Quimica do produto
	  cMetodo1 := '002' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	  cUnMedi1 := '02'  // Codigo da Unidade de Medida da Caracteristica 
	  cVlCara1 := '0004000000' // Valor Encontrado da Caracteristica
      cMassaE1 := '0040000'    // Massa Especifica do Produto
      
	  cFisQui2 := '025'
	  cMetodo2 := '028'
	  cUnMedi2 := '03'
	  cVlCara2 := '0085210000'
      cMassaE2 := '0000000'

	  cFisQui21:= '025'
	  cMetodo21:= '128'
	  cUnMedi21:= '03'
	  cVlCara21:= '0085210000'
      cMassaE21:= '0000000'
   Endif
   If Alltrim(MSD2->D2_COD) == '00004' .or.;
	  Alltrim(MSD2->D2_COD) == '00034' .or.;
	  Alltrim(MSD2->D2_COD) == '00005' .or.;
	  Alltrim(MSD2->D2_COD) == '00032' .or.;
	  Alltrim(MSD2->D2_COD) == '00006' .or.;
	  Alltrim(MSD2->D2_COD) == '00024' .or.;
	  Alltrim(MSD2->D2_COD) == '00014' 
	  cFisQui1 := '004'
	  cMetodo1 := '002'
	  cUnMedi1 := '02'
	  cVlCara1 := '0075110000'
      cMassaE1 := '0751100'

	  cFisQui11:= '004'
	  cMetodo11:= '096'
	  cUnMedi11:= '02'
	  cVlCara11:= '0075110000'
      cMassaE11:= '0751100'

	  cFisQui2 := '005'
	  cMetodo2 := '004'
	  cUnMedi2 := '03'
	  cVlCara2 := '0005750000'
      cMassaE2 := '0000000'

	  cFisQui3 := '006'
	  cMetodo3 := '004'
	  cUnMedi3 := '03'
	  cVlCara3 := '0007220000'
      cMassaE3 := '0000000'

	  cFisQui4 := '007'
	  cMetodo4 := '004'
	  cUnMedi4 := '03'
	  cVlCara4 := '0015490000'
      cMassaE4 := '0000000'

	  cFisQui5 := '008'
	  cMetodo5 := '004'
	  cUnMedi5 := '03'
	  cVlCara5 := '0020400000'
      cMassaE5 := '0000000'
   Endif
   If Alltrim(MSD2->D2_COD) == '00013' .or.;
	  Alltrim(MSD2->D2_COD) == '00015' .or.;
      Alltrim(MSD2->D2_COD) == '00072' .or.;
      Alltrim(MSD2->D2_COD) == '00073' 	   
	  cFisQui1 := '004'
	  cMetodo1 := '002'
	  cUnMedi1 := '02'
	  cVlCara1 := '0081060000'
      cMassaE1 := '0810600'

	  cFisQui11:= '004'
	  cMetodo11:= '096'
	  cUnMedi11:= '02'
	  cVlCara11:= '0081060000'
      cMassaE11:= '0810600'

	  cFisQui2 := '034'
	  cMetodo2 := '096'
	  cUnMedi2 := '12'
	  cVlCara2 := '0009280000'
      cMassaE2 := '0000000'

	  cFisQui3 := '035'
	  cMetodo3 := '097'
	  cUnMedi3 := '22'
	  cVlCara3 := '0000650000'
      cMassaE3 := '0000000'

	  cFisQui4 := '033'
	  cMetodo4 := '095'
	  cUnMedi4 := '11'
	  cVlCara4 := '0017950000'
      cMassaE4 := '0000000'
   Endif
*/
	
   cProRes := cProOpe // Codigo do Produto/Operacao Resultante
   cRecGLP := '00'    // Recipiente de GLP
	
   cLinhax := ''
   If !Empty(cFisQui1) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui11) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui11 + cMetodo11 + cUnMedi11 + cVlCara11 + cProRes + cMassaE11 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui2) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui2 + cMetodo2 + cUnMedi2 + cVlCara2 + cProRes + cMassaE2 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui21) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui21 + cMetodo21 + cUnMedi21 + cVlCara21 + cProRes + cMassaE21 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui3) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui3 + cMetodo3 + cUnMedi3 + cVlCara3 + cProRes + cMassaE3 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui4) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui4 + cMetodo4 + cUnMedi4 + cVlCara4 + cProRes + cMassaE4 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui5) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui5 + cMetodo5 + cUnMedi5 + cVlCara5 + cProRes + cMassaE5 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif

   *
   * Extrai Saida por Transferencia para outro produto
   *       
   cComp := ''
   SELE SG1
   DbGotop()
   DbSeek(xFilial("SG1")+MSD2->D2_COD,.T.)
   While !Eof() .And. xFilial("SG1") == SG1->G1_FILIAL .And. MSD2->D2_COD == SG1->G1_COD  
	
     If SG1->G1_COMP == '00018' // Corante ignora na composicao pois nao tem cod ANP cfe Fabi
	     DbSkip()
	     Loop
	  Endif

	  cLinha := ''
	  cOperac:= '0000000'

	  cLinha := '1001799935'         // Nr Agente Reg Informante
	  cLinha := cLinha + cMMAAAA              // Mes Referencia

      cOperac := '1022015' // Saidas por Transferencia para outro produto
	   
	  cLinha := cLinha + cOperac   // Operacao
	   
	  cLinha := cLinha + '1032183' // Cod Instalacao 1
	   
	  cInstANP := '0000000'
	  cLinha := cLinha + cInstANP  // Cod Instalacao 2
	
	  Sele MSD2
	      
	  cProOpe:= '000000000'
	  cQtdKg := 0
	  If Alltrim(SG1->G1_COMP) == '00004'
	     cProOpe := '320101001'
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.7430
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00005' .or.;
	     Alltrim(SG1->G1_COMP) == '00014' .or.;
	     Alltrim(SG1->G1_COMP) == '00032'
	     cProOpe := '320102001'
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.7430
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00006' .or.;
	     Alltrim(SG1->G1_COMP) == '00024' .or.;
	     Alltrim(SG1->G1_COMP) == '00034'
	     cProOpe := '320102002'
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.7430
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00007'    .or.;
	     Alltrim(SG1->G1_COMP) == '00060001' .or.;
	     Alltrim(SG1->G1_COMP) == '00060002'
	     cProOpe := '410102001'
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8114
	  EndIf                          
	  If Alltrim(SG1->G1_COMP) == '00008' 
//	     cProOpe := '420101001'
        cProOpe := '420101004'  // Novo codigo cfe Fabi 15/03/2007
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8480
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00103' 
        cProOpe := '820101001'  // Novo codigo cfe Fabi 20/08/08
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8480
	  EndIf	  
	  If Alltrim(SG1->G1_COMP) == '00008' 
        cProOpe := '420101004'  // Novo codigo cfe Fabi 11/04/2008
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8480
	  EndIf
     If Alltrim(SG1->G1_COMP) == '00086' .or.;
		  Alltrim(SG1->G1_COMP) == '00076' 	     
        cProOpe := '820101002'  // Novo codigo cfe Fabi 08/08/2007
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8480
     EndIf
     If Alltrim(SG1->G1_COMP) == '00078' .or.;
        Alltrim(SG1->G1_COMP) == '00087'      
        cProOpe := '820101009'  // Novo codigo cfe Fabi 08/08/2007
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8480
     EndIf
     If Alltrim(SG1->G1_COMP) == '00097' .or.;
        Alltrim(SG1->G1_COMP) == '00096'      
        cProOpe := '820101007'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8480
     EndIf
/*     If Alltrim(SG1->G1_COMP) == '00098' .or.;
        Alltrim(SG1->G1_COMP) == '00099'      
        cProOpe := '820101017'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8480
     EndIf */
     
     If Alltrim(SG1->G1_COMP) == '00100' .or.;
        Alltrim(SG1->G1_COMP) == '00101'      
        cProOpe := '820101008'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8480
     EndIf
     If Alltrim(SG1->G1_COMP) == '00083'
        cProOpe := '220101005'  // Novo codigo cfe Fabi 10/08/2007
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.7500
     EndIf
     If Alltrim(SG1->G1_COMP) == '00095'
        cProOpe := '220101003'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.7500
     EndIf
//	  If Alltrim(SG1->G1_COMP) == '00009' .or.; ALTERADO FABI 20/08/08
//	     Alltrim(SG1->G1_COMP) == '00033' 
//	     cProOpe := '420101002'
//        cProOpe := '420101005'  // Novo codigo cfe Fabi 15/03/2007
//	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8480
//	  EndIf
//	  If Alltrim(SG1->G1_COMP) == '00023' .or.;   ALTERADO FABI 20/08/08
//		  Alltrim(SG1->G1_COMP) == '00085' 		  
//	     cProOpe := '420102001'
//        cProOpe := '420102004'  // Novo codigo cfe Fabi 15/03/2007
//	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8480
//	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00078' 
        cProOpe := '420102002'  // Novo codigo cfe Fabi 12/07/2007
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8480
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00019' .or.;
	     Alltrim(SG1->G1_COMP) == '00074' 
	     cProOpe := '420201001'
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8480
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00010' .or.;
	     Alltrim(SG1->G1_COMP) == '00011' .or.;
	     Alltrim(SG1->G1_COMP) == '00092' 
	     cProOpe := '510101001'
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 1.0000
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00001' .or.;
	     Alltrim(SG1->G1_COMP) == '00002' .or.;
	     Alltrim(SG1->G1_COMP) == '00003' .or.;
	     Alltrim(SG1->G1_COMP) == '00058' .or.;
	     Alltrim(SG1->G1_COMP) == '00084' .or.;
	     Alltrim(SG1->G1_COMP) == '00090' .or.;
	     Alltrim(SG1->G1_COMP) == '00091'       
	     cProOpe := '560101001'
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 1.0000
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00015' .or.;
         Alltrim(SG1->G1_COMP) == '00072' .or.;
         Alltrim(SG1->G1_COMP) == '00073' 	   
	     cProOpe := '810101001'
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8100
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00013' 
	     cProOpe := '810102001'
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8100
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00016' //.Or.;
//	     Alltrim(SG1->G1_COMP) == '00810002'
	     cProOpe := '740101001'
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.7430
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00017' .Or.;
	     Alltrim(SG1->G1_COMP) == '00810001' .OR. ;
	     Alltrim(SG1->G1_COMP) == '00810002'
	     cProOpe := '740101002'
	     cQtdKg  := (MSD2->D2_QUANT * SG1->G1_QUANT) * 0.8480
	  EndIf
	   
	  If cProOpe == '000000000'
	     Sele SG1
	     DbSkip()
	     Loop
	  Endif
	   
	  If Alltrim(MSD2->D2_COD) == '00009' .And.; // Caso Diesel com Aditivo ajusta Qtde da saida do Aditivo
         (Alltrim(SG1->G1_COMP) == '00017' .Or. Alltrim(SG1->G1_COMP) == '00810001' .OR. Alltrim(SG1->G1_COMP) == '00810002') // Aditivo do Oleo Diesel 
         cQtdPro := MSD2->D2_QUANT - cQtdPro     // Calcula valor correspondente ao Aditivo do Diesel
	  ElseIf Alltrim(MSD2->D2_COD) == '00024' .And.; // Caso Gasolina C Aditivada com Aditivo ajusta Qtde da saida do Aditivo
         Alltrim(SG1->G1_COMP) == '00016' //.Or. Alltrim(SG1->G1_COMP) == '00810002') // Aditivo da Gasolina C
         cQtdPro := MSD2->D2_QUANT - cQtdPro         // Calcula valor correspondente ao Aditivo da Gasolina C
	  Else
   	     cQtdPro := Int(MSD2->D2_QUANT * SG1->G1_QUANT)
		 If cQtdPro == 0
		    cQtdPro := Int(MSD2->D2_QUANT * SG1->G1_QUANT * 1000)
		 Endif
	  Endif   

	  SELE ESTOQUE  // Extrai Total Transferencia Saidas
	  If !DbSeek(cProOpe)
	      Reclock("ESTOQUE",.T.)
	      ESTOQUE->PROOPE  := cProOpe
	      ESTOQUE->QTDETS  := int(cQtdPro)
	      ESTOQUE->QTDKGTS := cQtdKg
	      MsUnlock("ESTOQUE") 
	  Else
	      Reclock("ESTOQUE",.F.)
	      ESTOQUE->QTDETS  := ESTOQUE->QTDETS  + int(cQtdPro)
	      ESTOQUE->QTDKGTS := ESTOQUE->QTDKGTS + cQtdKg
	      MsUnlock("ESTOQUE") 
	  Endif
	
   
	  cLinha := cLinha + cProOpe // Cod Prod Operado
	   
	  cLinha  := cLinha + StrZero(cQtdPro,15)       // Qtde produto operado na unidade de medida oficial ANP
	
	  cQtdKgl := int(cQtdKg)
	  cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

      If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
         cQtdKgm := 1
      Endif
	  If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
	     cQtdKgm := 1
	  Endif
	   
	  cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
	   
	  cLinha := cLinha + '0' // Cod Modal Utilizado na Movimentacao 0 = Interno cfe FAbi
	  cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
	   
	  cIdent := '00000000000000'
	  cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
	   
	  cMun_ANP := '0008518'

	  cAtivida := '51519'  

	  cLinha := cLinha + '0000000'  // Codigo Municipio
	  cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
	  cLinha := cLinha + '0000' // Cod do país
	  cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	  cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
		
	  cDoc   := '0000000' // Numero da NF fica zeros por ser transacao interna cfe Fabi
	  cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	  cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 00 == Interna
		
	  cDtEmi := strzero(day(MSD2->D2_EMISSAO),2)+strzero(month(MSD2->D2_EMISSAO),2)+strzero(year(MSD2->D2_EMISSAO),4)	
	  cLinha := cLinha + cDtEmi // Data da operacao Comercial
	  cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
		
	  cFisQui1 := '000' // Cfe Fabi para transferencia sera sempre tudo zero!!  02/01/2007
	  cMetodo1 := '000'
	  cUnMedi1 := '00'
	  cVlCara1 := '0000000000'
	  cMassaE1 := '0000000'
/*	   
      If Alltrim(SG1->G1_COMP) == '00007'    .or.;  // Para Querosene Colocar Zeros cfe Fabi
         Alltrim(SG1->G1_COMP) == '00060001' .or.;
         Alltrim(SG1->G1_COMP) == '00060002'
   	     cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	     cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
   	     cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	     cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
         cMassaE1 := '0000000'    // Massa Especifica do Produto
     Endif

     If Alltrim(SG1->G1_COMP) == '00001' .or.; // Para Oleo Xisto Colocar Zeros cfe Fabi
        Alltrim(SG1->G1_COMP) == '00002' .or.;
        Alltrim(SG1->G1_COMP) == '00003'
   	    cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	    cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	    cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
   	    cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
        cMassaE1 := '0000000'    // Massa Especifica do Produto
     Endif

     If Alltrim(SG1->G1_COMP) == '00010' .or.; // Para Oleo Combustivel 1A Zeros Cfe Fabi 
        Alltrim(SG1->G1_COMP) == '00011' .or.; // Para Oleo Combustivel 2A Zeros Cfe Fabi 
        Alltrim(SG1->G1_COMP) == '00016' .or.; // Para Aditivo Hitec 6421 (Gasolina) Zeros Cfe Fabi
        Alltrim(SG1->G1_COMP) == '00017' .or.; // Para Aditivo Hitec 4130 (Diesel)   Zeros Cfe Fabi
        Alltrim(SG1->G1_COMP) == '00810002' .or.; // Para Aditivo Hitec 6421 (Gasolina) Zeros Cfe Fabi
        Alltrim(SG1->G1_COMP) == '00810001'       // Para Aditivo Hitec 4130 (Diesel)   Zeros Cfe Fabi
	    cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	    cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
   	    cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	    cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
        cMassaE1 := '0000000'    // Massa Especifica do Produto
     Endif

	 If Alltrim(SG1->G1_COMP) == '00031' .or.;
		Alltrim(SG1->G1_COMP) == '00033' .or.;
		Alltrim(SG1->G1_COMP) == '00008' .or.;
		Alltrim(SG1->G1_COMP) == '00009' .or.;
		Alltrim(SG1->G1_COMP) == '00019' .or.;
		Alltrim(SG1->G1_COMP) == '00074' .or.;
		Alltrim(SG1->G1_COMP) == '00023' 
	
		cFisQui1 := '004' // Codigo da Caracteristica Fisico-Quimica do produto
		cMetodo1 := '002' // Codigo do Metodo Utilizado para Afericao da Caracteristica
		cUnMedi1 := '02'  // Codigo da Unidade de Medida da Caracteristica 
		cVlCara1 := '0004000000' // Valor Encontrado da Caracteristica
	    cMassaE1 := '0040000'    // Massa Especifica do Produto
	      
	 Endif
	 If Alltrim(SG1->G1_COMP) == '00004' .or.;
		Alltrim(SG1->G1_COMP) == '00034' .or.;
		Alltrim(SG1->G1_COMP) == '00005' .or.;
		Alltrim(SG1->G1_COMP) == '00032' .or.;
		Alltrim(SG1->G1_COMP) == '00006' .or.;
		Alltrim(SG1->G1_COMP) == '00024' .or.;
		Alltrim(SG1->G1_COMP) == '00014' 
		cFisQui1 := '004'
		cMetodo1 := '002'
		cUnMedi1 := '02'
		cVlCara1 := '0075110000'
	    cMassaE1 := '0751100'
	
	 Endif
	 If Alltrim(SG1->G1_COMP) == '00013' .or.;
		Alltrim(SG1->G1_COMP) == '00015' .or.;
		Alltrim(SG1->G1_COMP) == '00072' .or.;
		Alltrim(SG1->G1_COMP) == '00073' 
		cFisQui1 := '004'
		cMetodo1 := '002'
		cUnMedi1 := '02'
		cVlCara1 := '0081060000'
	    cMassaE1 := '0810600'
	
	 Endif
*/		
	 cRecGLP := '00'    // Recipiente de GLP
		
	 cLinhax := ''
	 If !Empty(cFisQui1) 
	    cConta := cConta + 1  // Nr Registro
		cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP
	
		SELE AGR159
	    Reclock("AGR159",.T.)
	    AGR159->SEQ    := cConta
	    AGR159->LIN    := cLinhax
	    MsUnlock("AGR159") 
	 Endif 
      
     cComp := 'S'
            
     Sele SG1
     DbSkip()
	
   End
   *
   * Extrai Recebimento por transferencia de outros produtos
   *                                                        
   If cComp == 'S'
	  cLinha := ''
	  cOperac:= '0000000'
	
	  cLinha := '1001799935'         // Nr Agente Reg Informante
	  cLinha := cLinha + cMMAAAA              // Mes Referencia
	
	  cOperac := '1021004' // Saidas por Transferencia para outro produto
	   
	  cLinha := cLinha + cOperac   // Operacao
	   
	  cLinha := cLinha + '1032183' // Cod Instalacao 1
	   
	  cInstANP := '0000000'
	  cLinha := cLinha + cInstANP  // Cod Instalacao 2
	
	  Sele MSD2
	      
	  cProOpe:= '000000000'
	  cQtdKg := 0
	  If Alltrim(MSD2->D2_COD) == '00004'
	     cProOpe := '320101001'
	     cQtdKg  := MSD2->D2_QUANT  * 0.7430
	  EndIf
	  If Alltrim(MSD2->D2_COD) == '00005' .or.;
	     Alltrim(MSD2->D2_COD) == '00014' .or.;
	     Alltrim(MSD2->D2_COD) == '00032'
	     cProOpe := '320102001'
	     cQtdKg  := MSD2->D2_QUANT  * 0.7430
	  EndIf
	  If Alltrim(MSD2->D2_COD) == '00006' .or.;
	     Alltrim(MSD2->D2_COD) == '00024' .or.;
	     Alltrim(MSD2->D2_COD) == '00034'
	     cProOpe := '320102002'
	     cQtdKg  := MSD2->D2_QUANT  * 0.7430
	  EndIf
	  If Alltrim(MSD2->D2_COD) == '00007'    .or.;
	     Alltrim(MSD2->D2_COD) == '00060001' .or.;
	     Alltrim(MSD2->D2_COD) == '00060002'
	     cProOpe := '410102001'
	     cQtdKg  := MSD2->D2_QUANT  * 0.8114
	  EndIf
	  If Alltrim(MSD2->D2_COD) == '00008' .or.; //ALTERADO CFE FABI 20/08/08
	     Alltrim(MSD2->D2_COD) == '00031' 
//	     cProOpe := '420101001'
        cProOpe := '420101004'  // Novo codigo cfe Fabi 15/03/2007
	     cQtdKg  := MSD2->D2_QUANT  * 0.8480
	  EndIf
 	  If Alltrim(MSD2->D2_COD) == '00103' 
        cProOpe := '820101001'  // Novo codigo cfe Fabi 20/08/2008
	     cQtdKg  := MSD2->D2_QUANT  * 0.8480
	  EndIf
	  If Alltrim(MSD2->D2_COD) == '00008' 
        cProOpe := '420101004'  // Novo codigo cfe Fabi 11/04/2008
	     cQtdKg  := MSD2->D2_QUANT  * 0.8480
	  EndIf
     If Alltrim(MSD2->D2_COD) == '00086' .or.;
		  Alltrim(MSD2->D2_COD) == '00076' 	     
          DBSKIP()
//        cProOpe := '820101002'  // Novo codigo cfe Fabi 08/08/2007
//	     cQtdKg  := MSD2->D2_QUANT  * 0.8480
     EndIf*/
     If Alltrim(MSD2->D2_COD) == '00078' .or.;
        Alltrim(MSD2->D2_COD) == '00087'      
        cProOpe := '820101009'  // Novo codigo cfe Fabi 08/08/2007
	     cQtdKg  := MSD2->D2_QUANT  * 0.8480
     EndIf
     If Alltrim(MSD2->D2_COD) == '00097' .or.;
        Alltrim(MSD2->D2_COD) == '00096'      
        cProOpe := '820101007'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := MSD2->D2_QUANT  * 0.8480
     EndIf
/*     If Alltrim(MSD2->D2_COD) == '00098' .or.;
        Alltrim(MSD2->D2_COD) == '00099'      
        cProOpe := '820101017'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := MSD2->D2_QUANT  * 0.8480
     EndIf */
     If Alltrim(MSD2->D2_COD) == '00100' .or.;
        Alltrim(MSD2->D2_COD) == '00101'      
        cProOpe := '820101008'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := MSD2->D2_QUANT  * 0.8480
     EndIf
     If Alltrim(MSD2->D2_COD) == '00083'
        cProOpe := '220101005'  // Novo codigo cfe Fabi 10/08/2007
	     cQtdKg  := MSD2->D2_QUANT  * 0.7500
     EndIf
     If Alltrim(MSD2->D2_COD) == '00095'
        cProOpe := '220101003'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := MSD2->D2_QUANT  * 0.7500
     EndIf
//	  If Alltrim(MSD2->D2_COD) == '00009' .or.; ALTERADO FABI 20/08/08
//	     Alltrim(MSD2->D2_COD) == '00033' 
//	     cProOpe := '420101002'
//        cProOpe := '420101005'  // Novo codigo cfe Fabi 15/03/2007
//	     cQtdKg  := MSD2->D2_QUANT  * 0.8480
//	  EndIf
//	  If Alltrim(MSD2->D2_COD) == '00023' .or.;  ALTERADO FABI 20/08/08
//		  Alltrim(MSD2->D2_COD) == '00085' 	   
//	     cProOpe := '420102001'
//        cProOpe := '420102004'  // Novo codigo cfe Fabi 15/03/2007
//	     cQtdKg  := MSD2->D2_QUANT  * 0.8480
//	  EndIf
	  If Alltrim(MSD2->D2_COD) == '00078' 
        cProOpe := '420102002'  // Novo codigo cfe Fabi 12/07/2007
	     cQtdKg  := MSD2->D2_QUANT  * 0.8480
	  EndIf
	  If Alltrim(MSD2->D2_COD) == '00019' .or.;
	     Alltrim(MSD2->D2_COD) == '00074' 
	     cProOpe := '420201001'
	     cQtdKg  := MSD2->D2_QUANT  * 0.8480
	  EndIf
	  If Alltrim(MSD2->D2_COD) == '00010' .or.;
	     Alltrim(MSD2->D2_COD) == '00011' .or.;
	     Alltrim(MSD2->D2_COD) == '00092' 
	     cProOpe := '510101001'
	     cQtdKg  := MSD2->D2_QUANT  * 1.0000
	  EndIf
	  If Alltrim(MSD2->D2_COD) == '00001' .or.;
	     Alltrim(MSD2->D2_COD) == '00002' .or.;
	     Alltrim(MSD2->D2_COD) == '00003' .or.;
	     Alltrim(MSD2->D2_COD) == '00058' .or.;
	     Alltrim(MSD2->D2_COD) == '00084' .or.;
	     Alltrim(MSD2->D2_COD) == '00090' .or.;
	     Alltrim(MSD2->D2_COD) == '00091' 
	     cProOpe := '560101001'
	     cQtdKg  := MSD2->D2_QUANT  * 1.0000
	  EndIf
	  If Alltrim(MSD2->D2_COD) == '00015' .or.;
	     Alltrim(MSD2->D2_COD) == '00072' .or.;
	     Alltrim(MSD2->D2_COD) == '00073' 
	     cProOpe := '810101001'
	     cQtdKg  := MSD2->D2_QUANT  * 0.8100
	  EndIf
	  If Alltrim(MSD2->D2_COD) == '00013' 
	     cProOpe := '810102001'
	     cQtdKg  := MSD2->D2_QUANT  * 0.8100
	  EndIf
	  If Alltrim(MSD2->D2_COD) == '00016' //.Or.;
//	     Alltrim(MSD2->D2_COD) == '00810002'
	     cProOpe := '740101001'
	     cQtdKg  := MSD2->D2_QUANT  * 0.7430
	  EndIf
	  If Alltrim(MSD2->D2_COD) == '00017' .Or.;
	     Alltrim(MSD2->D2_COD) == '00810001' .OR. ;
        Alltrim(MSD2->D2_COD)  == '00810002'
	     cProOpe := '740101002'
	     cQtdKg  := MSD2->D2_QUANT  * 0.8480
	  EndIf

	  SELE ESTOQUE  // Extrai Total Transferencia Entradas
	  If !DbSeek(cProOpe)
	     Reclock("ESTOQUE",.T.)
	     ESTOQUE->PROOPE  := cProOpe
	     ESTOQUE->QTDETE  := int(MSD2->D2_QUANT)
	     ESTOQUE->QTDKGTE := cQtdKg
	     MsUnlock("ESTOQUE") 
	  Else
	     Reclock("ESTOQUE",.F.)
	     ESTOQUE->QTDETE  := ESTOQUE->QTDETE  + int(MSD2->D2_QUANT)
	     ESTOQUE->QTDKGTE := ESTOQUE->QTDKGTE + cQtdKg
	     MsUnlock("ESTOQUE") 
	  Endif
	   
	  cLinha := cLinha + cProOpe // Cod Prod Operado
	   
	  cQtdPro := Int(MSD2->D2_QUANT)
	  cLinha  := cLinha + StrZero(cQtdPro,15)
	
	  cQtdKgl := int(cQtdKg)
	  cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000
	                                          
      If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
         cQtdKgm := 1
      Endif
	  If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
	     cQtdKgm := 1
	  Endif
	   
	  cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
	   
	  cLinha := cLinha + '0' // Cod Modal Utilizado na Movimentacao 0 = Interno cfe FAbi
	  cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
	   
	  cIdent := '00000000000000'
	  cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
	   
	  cMun_ANP := '0008518'
	
	  cAtivida := '51519'  
	
	  cLinha := cLinha + '0000000' // Codigo Municipio
	  cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
	  cLinha := cLinha + '0000' // Cod do país
	  cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	  cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
		
	  cDoc   := '0000000' // Numero da NF fica zeros por ser transacao interna cfe Fabi
	  cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	  cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 00 == Interna
		
	  cDtEmi := strzero(day(MSD2->D2_EMISSAO),2)+strzero(month(MSD2->D2_EMISSAO),2)+strzero(year(MSD2->D2_EMISSAO),4)	
	  cLinha := cLinha + cDtEmi // Data da operacao Comercial
	  cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
		
	  cFisQui1 := '000' // Cfe Fabi para transferencia sera tudo zero!! 02/01/2007
	  cMetodo1 := '000'
	  cUnMedi1 := '00'
	  cVlCara1 := '0000000000'
	  cMassaE1 := '0000000'
/*	   
      If Alltrim(MSD2->D2_COD) == '00007'    .or.;  // Para Querosene Colocar Zeros cfe Fabi
         Alltrim(MSD2->D2_COD) == '00060001' .or.;
         Alltrim(MSD2->D2_COD) == '00060002'
   	     cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	     cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	     cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
   	     cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
         cMassaE1 := '0000000'    // Massa Especifica do Produto
      Endif

      If Alltrim(MSD2->D2_COD) == '00001' .or.; // Para Oleo Xisto Colocar Zeros cfe Fabi
         Alltrim(MSD2->D2_COD) == '00002' .or.;
         Alltrim(MSD2->D2_COD) == '00003'
   	     cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	     cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
   	     cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	     cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
         cMassaE1 := '0000000'    // Massa Especifica do Produto
      Endif

      If Alltrim(MSD2->D2_COD) == '00010' .or.; // Para Oleo Combustivel 1A Zeros Cfe Fabi 
         Alltrim(MSD2->D2_COD) == '00011' .or.; // Para Oleo Combustivel 2A Zeros Cfe Fabi 
         Alltrim(MSD2->D2_COD) == '00016' .or.; // Para Aditivo Hitec 6421 (Gasolina) Zeros Cfe Fabi
         Alltrim(MSD2->D2_COD) == '00017' .or.; // Para Aditivo Hitec 4130 (Diesel)   Zeros Cfe Fabi
         Alltrim(MSD2->D2_COD) == '00810002' .or.; // Para Aditivo Hitec 6421 (Gasolina) Zeros Cfe Fabi
         Alltrim(MSD2->D2_COD) == '00810001'       // Para Aditivo Hitec 4130 (Diesel)   Zeros Cfe Fabi
	     cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	     cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
   	     cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	     cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
         cMassaE1 := '0000000'    // Massa Especifica do Produto
      Endif

	  If Alltrim(MSD2->D2_COD) == '00031' .or.;
		 Alltrim(MSD2->D2_COD) == '00033' .or.;
		 Alltrim(MSD2->D2_COD) == '00008' .or.;
		 Alltrim(MSD2->D2_COD) == '00009' .or.;
		 Alltrim(MSD2->D2_COD) == '00019' .or.;
		 Alltrim(MSD2->D2_COD) == '00074' .or.;
		 Alltrim(MSD2->D2_COD) == '00023' 
	
		 cFisQui1 := '004' // Codigo da Caracteristica Fisico-Quimica do produto
		 cMetodo1 := '002' // Codigo do Metodo Utilizado para Afericao da Caracteristica
		 cUnMedi1 := '02'  // Codigo da Unidade de Medida da Caracteristica 
		 cVlCara1 := '0004000000' // Valor Encontrado da Caracteristica
	     cMassaE1 := '0040000'    // Massa Especifica do Produto
	      
	  Endif
	  If Alltrim(MSD2->D2_COD) == '00004' .or.;
		 Alltrim(MSD2->D2_COD) == '00034' .or.;
		 Alltrim(MSD2->D2_COD) == '00005' .or.;
		 Alltrim(MSD2->D2_COD) == '00032' .or.;
		 Alltrim(MSD2->D2_COD) == '00006' .or.;
		 Alltrim(MSD2->D2_COD) == '00024' .or.;
		 Alltrim(MSD2->D2_COD) == '00014' 
		 cFisQui1 := '004'
		 cMetodo1 := '002'
		 cUnMedi1 := '02'
		 cVlCara1 := '0075110000'
	     cMassaE1 := '0751100'
	
	  Endif
	  If Alltrim(MSD2->D2_COD) == '00013' .or.;
		 Alltrim(MSD2->D2_COD) == '00015' .or.;
		 Alltrim(MSD2->D2_COD) == '00072' .or.;
		 Alltrim(MSD2->D2_COD) == '00073' 
		 cFisQui1 := '004'
		 cMetodo1 := '002'
		 cUnMedi1 := '02'
		 cVlCara1 := '0081060000'
	     cMassaE1 := '0810600'
	
	  Endif
*/		
	  cRecGLP := '00'    // Recipiente de GLP
		
	  cLinhax := ''
	  If !Empty(cFisQui1) 
	     cConta := cConta + 1  // Nr Registro
		 cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP
	
		 SELE AGR159
	     Reclock("AGR159",.T.)
	     AGR159->SEQ    := cConta
	     AGR159->LIN    := cLinhax
	     MsUnlock("AGR159") 
	  Endif
   Endif


   sele MSD2
   dbskip()

END            
*
* Extrai Producao Saidas SC2 Ordens producao manuais Luis/Base
*        
sele MSC2
dbgotop()
Procregua(Reccount())
While !eof() 

   Incproc()
   
   *
   * Extrai Saida por Transferencia para outro produto
   *       
   cComp := ''
   SELE SG1
   DbGotop()
   DbSeek(xFilial("SG1")+MSC2->C2_PRODUTO,.T.)
   While !Eof() .And. xFilial("SG1") == SG1->G1_FILIAL .And. MSC2->C2_PRODUTO == SG1->G1_COD  
	
     If SG1->G1_COMP == '00018' // Corante ignora na composicao pois nao tem cod ANP cfe Fabi
	     DbSkip()
	     Loop
	  Endif

	  cLinha := ''
	  cOperac:= '0000000'

	  cLinha := '1001799935'         // Nr Agente Reg Informante
	  cLinha := cLinha + cMMAAAA              // Mes Referencia

      cOperac := '1022015' // Saidas por Transferencia para outro produto
	   
	  cLinha := cLinha + cOperac   // Operacao
	   
	  cLinha := cLinha + '1032183' // Cod Instalacao 1
	   
	  cInstANP := '0000000'
	  cLinha := cLinha + cInstANP  // Cod Instalacao 2
	
	  Sele MSC2
	      
	  cProOpe:= '000000000'
	  cQtdKg := 0
	  If Alltrim(SG1->G1_COMP) == '00004'
	     cProOpe := '320101001'
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.7430
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00005' .or.;
	     Alltrim(SG1->G1_COMP) == '00014' .or.;
	     Alltrim(SG1->G1_COMP) == '00032'
	     cProOpe := '320102001'
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.7430
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00006' .or.;
	     Alltrim(SG1->G1_COMP) == '00024' .or.;
	     Alltrim(SG1->G1_COMP) == '00034'
	     cProOpe := '320102002'
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.7430
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00007'    .or.;
	     Alltrim(SG1->G1_COMP) == '00060001' .or.;
	     Alltrim(SG1->G1_COMP) == '00060002'
	     cProOpe := '410102001'
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.8114
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00103' 
        cProOpe := '820101001'  // Novo codigo cfe Fabi 20/08/08
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.8480
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00008' 
        cProOpe := '420101004'  // Novo codigo cfe Fabi 11/04/2008
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.8480
	  EndIf
     If Alltrim(SG1->G1_COMP) == '00086'.or.;
		  Alltrim(SG1->G1_COMP) == '00076'     
        cProOpe := '820101002'  // Novo codigo cfe Fabi 08/08/2007
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.8480
     EndIf
     If Alltrim(SG1->G1_COMP) == '00078' .or.;
        Alltrim(SG1->G1_COMP) == '00087'      
        cProOpe := '820101009'  // Novo codigo cfe Fabi 08/08/2007
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.8480
     EndIf
     If Alltrim(SG1->G1_COMP) == '00097' .or.;
        Alltrim(SG1->G1_COMP) == '00096'      
        cProOpe := '820101007'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.8480
     EndIf
/*     If Alltrim(SG1->G1_COMP) == '00098' .or.;
        Alltrim(SG1->G1_COMP) == '00099'      
        cProOpe := '820101017'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.8480
     EndIf */
     If Alltrim(SG1->G1_COMP) == '00100' .or.;
        Alltrim(SG1->G1_COMP) == '00101'      
        cProOpe := '820101008'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.8480
     EndIf
     If Alltrim(SG1->G1_COMP) == '00083'
        cProOpe := '220101005'  // Novo codigo cfe Fabi 10/08/2007
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.7500
     EndIf
     If Alltrim(SG1->G1_COMP) == '00095'
        cProOpe := '220101003'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.7500
     EndIf
//	  If Alltrim(SG1->G1_COMP) == '00009' .or.; ALTERADO FABI 20/08/08
//	     Alltrim(SG1->G1_COMP) == '00033' 
//	     cProOpe := '420101002'
//        cProOpe := '420101005'  // Novo codigo cfe Fabi 15/03/2007
//	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.8480
//	  EndIf
//	  If Alltrim(SG1->G1_COMP) == '00023' .or.; ALTERADO FABI 20/08/08
//	     Alltrim(SG1->G1_COMP) == '00085' 
//	     cProOpe := '420102001'
//        cProOpe := '420102004'  // Novo codigo cfe Fabi 15/03/2007
//	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.8480
//	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00078' 
        cProOpe := '420102002'  // Novo codigo cfe Fabi 12/07/2007
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.8480
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00019' .or.;
	     Alltrim(SG1->G1_COMP) == '00074' 
	     cProOpe := '420201001'
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.8480
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00010' .or.;
	     Alltrim(SG1->G1_COMP) == '00011' .or.;
	     Alltrim(SG1->G1_COMP) == '00092' 
	     cProOpe := '510101001'
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 1.0000
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00001' .or.;
	     Alltrim(SG1->G1_COMP) == '00002' .or.;
	     Alltrim(SG1->G1_COMP) == '00003' .or.;
	     Alltrim(SG1->G1_COMP) == '00058' .or.;
	     Alltrim(SG1->G1_COMP) == '00084' .or.;
	     Alltrim(SG1->G1_COMP) == '00090' .or.;
	     Alltrim(SG1->G1_COMP) == '00091'       
	     cProOpe := '560101001'
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 1.0000
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00015' .or.;
	     Alltrim(SG1->G1_COMP) == '00072' .or.;
	     Alltrim(SG1->G1_COMP) == '00073' 
	     cProOpe := '810101001'
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.8100
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00013' 
	     cProOpe := '810102001'
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.8100
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00016' //.Or.;
//		  Alltrim(SG1->G1_COMP) == '00810002' 
	     cProOpe := '740101001'
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.7430
	  EndIf
	  If Alltrim(SG1->G1_COMP) == '00017' .Or.;
		  Alltrim(SG1->G1_COMP) == '00810001' .OR. ;
	     Alltrim(SG1->G1_COMP) == '00810002'
	     cProOpe := '740101002'
	     cQtdKg  := (MSC2->C2_QUANT * SG1->G1_QUANT) * 0.8480
	  EndIf
	   
	  If cProOpe == '000000000'
	     Sele SG1
	     DbSkip()
	     Loop
	  Endif
	   
	  If Alltrim(MSC2->C2_PRODUTO) == '00009' .And.; // Caso Diesel com Aditivo ajusta Qtde da saida do Aditivo
         (Alltrim(SG1->G1_COMP) == '00017' .Or. Alltrim(SG1->G1_COMP) == '00810001' .OR. Alltrim(SG1->G1_COMP) == '00810002') // Aditivo do Oleo Diesel 
         cQtdPro := MSC2->C2_QUANT - cQtdPro     // Calcula valor correspondente ao Aditivo do Diesel
	  ElseIf Alltrim(MSC2->C2_PRODUTO) == '00024' .And. ; // Caso Gasolina C Aditivada com Aditivo ajusta Qtde da saida do Aditivo
         Alltrim(SG1->G1_COMP) == '00016' //.Or. Alltrim(SG1->G1_COMP) == '00810002') // Aditivo da Gasolina C
         cQtdPro := MSC2->C2_QUANT - cQtdPro         // Calcula valor correspondente ao Aditivo da Gasolina C
	  Else
   	     cQtdPro := Int(MSC2->C2_QUANT * SG1->G1_QUANT)
	     If cQtdPro == 0
		    cQtdPro := Int(MSC2->C2_QUANT * SG1->G1_QUANT * 1000)
		 Endif
	  Endif   

	  SELE ESTOQUE  // Extrai Total Transferencia Saidas
	  If !DbSeek(cProOpe)
	     Reclock("ESTOQUE",.T.)
	     ESTOQUE->PROOPE  := cProOpe
	     ESTOQUE->QTDETS  := int(cQtdPro)
	     ESTOQUE->QTDKGTS := cQtdKg
	     MsUnlock("ESTOQUE") 
	  Else
	     Reclock("ESTOQUE",.F.)
	     ESTOQUE->QTDETS  := ESTOQUE->QTDETS  + int(cQtdPro)
	     ESTOQUE->QTDKGTS := ESTOQUE->QTDKGTS + cQtdKg
	     MsUnlock("ESTOQUE") 
	  Endif
	
   
	  cLinha := cLinha + cProOpe // Cod Prod Operado
	   
	  cLinha  := cLinha + StrZero(cQtdPro,15)       // Qtde produto operado na unidade de medida oficial ANP
	
	  cQtdKgl := int(cQtdKg)
	  cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

      If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
         cQtdKgm := 1
      Endif
	  If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
	     cQtdKgm := 1
	  Endif
	   
	  cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
	   
	  cLinha := cLinha + '0' // Cod Modal Utilizado na Movimentacao 0 = Interno cfe FAbi
	  cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
	   
	  cIdent := '00000000000000'
	  cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
	   
	  cMun_ANP := '0008518'

	  cAtivida := '51519'  

	  cLinha := cLinha + '0000000' // Codigo Municipio
	  cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
	  cLinha := cLinha + '0000' // Cod do país
	  cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	  cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
		
	  cDoc   := '0000000' // Numero da NF fica zeros por ser transacao interna cfe Fabi
	  cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	  cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 00 == Interna
		
	  cDtEmi := strzero(day(MSC2->C2_EMISSAO),2)+strzero(month(MSC2->C2_EMISSAO),2)+strzero(year(MSC2->C2_EMISSAO),4)	
	  cLinha := cLinha + cDtEmi // Data da operacao Comercial
	  cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
		
	  cFisQui1 := '000' // Cfe Fabi Ordens de produçao sera tudo Zero!! 02/01/2007
	  cMetodo1 := '000'
	  cUnMedi1 := '00'
	  cVlCara1 := '0000000000'
	  cMassaE1 := '0000000'
/*	   
      If Alltrim(SG1->G1_COMP) == '00007'    .or.;  // Para Querosene Colocar Zeros cfe Fabi
         Alltrim(SG1->G1_COMP) == '00060001' .or.;
         Alltrim(SG1->G1_COMP) == '00060002'
   	     cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	     cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
   	     cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	     cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
         cMassaE1 := '0000000'    // Massa Especifica do Produto
      Endif

      If Alltrim(SG1->G1_COMP) == '00001' .or.; // Para Oleo Xisto Colocar Zeros cfe Fabi
         Alltrim(SG1->G1_COMP) == '00002' .or.;
         Alltrim(SG1->G1_COMP) == '00003'
   	     cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	     cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	     cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
   	     cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
         cMassaE1 := '0000000'    // Massa Especifica do Produto
      Endif

      If Alltrim(SG1->G1_COMP) == '00010' .or.; // Para Oleo Combustivel 1A Zeros Cfe Fabi 
         Alltrim(SG1->G1_COMP) == '00011' .or.; // Para Oleo Combustivel 2A Zeros Cfe Fabi 
         Alltrim(SG1->G1_COMP) == '00016' .or.; // Para Aditivo Hitec 6421 (Gasolina) Zeros Cfe Fabi
         Alltrim(SG1->G1_COMP) == '00017' .or.; // Para Aditivo Hitec 4130 (Diesel)   Zeros Cfe Fabi
         Alltrim(SG1->G1_COMP) == '00810002' .or.; // Para Aditivo Hitec 6421 (Gasolina) Zeros Cfe Fabi
         Alltrim(SG1->G1_COMP) == '00810001'       // Para Aditivo Hitec 4130 (Diesel)   Zeros Cfe Fabi
	     cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	     cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
   	     cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	     cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
         cMassaE1 := '0000000'    // Massa Especifica do Produto
      Endif

	  If Alltrim(SG1->G1_COMP) == '00031' .or.;
		 Alltrim(SG1->G1_COMP) == '00033' .or.;
		 Alltrim(SG1->G1_COMP) == '00008' .or.;
		 Alltrim(SG1->G1_COMP) == '00009' .or.;
		 Alltrim(SG1->G1_COMP) == '00019' .or.;
		 Alltrim(SG1->G1_COMP) == '00074' .or.;
		 Alltrim(SG1->G1_COMP) == '00023' 
	
		 cFisQui1 := '004' // Codigo da Caracteristica Fisico-Quimica do produto
		 cMetodo1 := '002' // Codigo do Metodo Utilizado para Afericao da Caracteristica
		 cUnMedi1 := '02'  // Codigo da Unidade de Medida da Caracteristica 
		 cVlCara1 := '0004000000' // Valor Encontrado da Caracteristica
	     cMassaE1 := '0040000'    // Massa Especifica do Produto
	      
	  Endif
	  If Alltrim(SG1->G1_COMP) == '00004' .or.;
		 Alltrim(SG1->G1_COMP) == '00034' .or.;
		 Alltrim(SG1->G1_COMP) == '00005' .or.;
		 Alltrim(SG1->G1_COMP) == '00032' .or.;
		 Alltrim(SG1->G1_COMP) == '00006' .or.;
		 Alltrim(SG1->G1_COMP) == '00024' .or.;
		 Alltrim(SG1->G1_COMP) == '00014' 
		 cFisQui1 := '004'
		 cMetodo1 := '002'
		 cUnMedi1 := '02'
		 cVlCara1 := '0075110000'
	     cMassaE1 := '0751100'
	
	  Endif
	  If Alltrim(SG1->G1_COMP) == '00013' .or.;
		 Alltrim(SG1->G1_COMP) == '00015' .or.;
		 Alltrim(SG1->G1_COMP) == '00072' .or.;
		 Alltrim(SG1->G1_COMP) == '00073' 
		 cFisQui1 := '004'
		 cMetodo1 := '002'
		 cUnMedi1 := '02'
		 cVlCara1 := '0081060000'
	     cMassaE1 := '0810600'
	
	  Endif
*/		
	  cRecGLP := '00'    // Recipiente de GLP
		
	  cLinhax := ''
	  If !Empty(cFisQui1) 
	     cConta := cConta + 1  // Nr Registro
		 cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP
	
		 SELE AGR159
	     Reclock("AGR159",.T.)
	     AGR159->SEQ    := cConta
	     AGR159->LIN    := cLinhax
	     MsUnlock("AGR159") 
	  Endif 
      
      cComp := 'S'
            
      Sele SG1
      DbSkip()
	
   End
   *
   * Extrai Recebimento por transferencia (OP manual luis/base) de outro produto (para 00014) cfe Fabi
   *                                                        
   If cComp == 'S'          
   
      cC2_PRODUTO := '00014'
	
	  cLinha := ''
	  cOperac:= '0000000'
	
	  cLinha := '1001799935'         // Nr Agente Reg Informante
	  cLinha := cLinha + cMMAAAA              // Mes Referencia
	
	  cOperac := '1021004' // Saidas por Transferencia para outro produto
	   
	  cLinha := cLinha + cOperac   // Operacao
	   
	  cLinha := cLinha + '1032183' // Cod Instalacao 1
	   
	  cInstANP := '0000000'
	  cLinha := cLinha + cInstANP  // Cod Instalacao 2
	
	  Sele MSC2
	      
	  cProOpe:= '000000000'
	  cQtdKg := 0
	  If Alltrim(cC2_PRODUTO) == '00004'
	     cProOpe := '320101001'
	     cQtdKg  := MSC2->C2_QUANT  * 0.7430
	  EndIf
	  If Alltrim(cC2_PRODUTO) == '00005' .or.;
	     Alltrim(cC2_PRODUTO) == '00014' .or.;
	     Alltrim(cC2_PRODUTO) == '00032'
	     cProOpe := '320102001'
	     cQtdKg  := MSC2->C2_QUANT  * 0.7430
	  EndIf
	  If Alltrim(cC2_PRODUTO) == '00006' .or.;
	     Alltrim(cC2_PRODUTO) == '00024' .or.;
	     Alltrim(cC2_PRODUTO) == '00034'
	     cProOpe := '320102002'
	     cQtdKg  := MSC2->C2_QUANT  * 0.7430
	  EndIf
	  If Alltrim(cC2_PRODUTO) == '00007'    .or.;
	     Alltrim(cC2_PRODUTO) == '00060001' .or.;
	     Alltrim(cC2_PRODUTO) == '00060002'
	     cProOpe := '410102001'
	     cQtdKg  := MSC2->C2_QUANT  * 0.8114
	  EndIf
	  If Alltrim(cC2_PRODUTO) == '00008' .or.; //ALTERADO CFE FABI 20/08/08
	     Alltrim(cC2_PRODUTO) == '00031' 
//	     cProOpe := '420101001'
        cProOpe := '420101004'  // Novo codigo cfe Fabi 15/03/2007
	     cQtdKg  := MSC2->C2_QUANT  * 0.8480
	  EndIf
	  If Alltrim(cC2_PRODUTO) == '00103' 
        cProOpe := '820101001'  // Novo codigo cfe Fabi 20/08/08
	     cQtdKg  := MSC2->C2_QUANT  * 0.8480
	  EndIf	  
	  If Alltrim(cC2_PRODUTO) == '00008' 
        cProOpe := '420101004'  // Novo codigo cfe Fabi 11/04/2008
	     cQtdKg  := MSC2->C2_QUANT  * 0.8480
	  EndIf
     If Alltrim(cC2_PRODUTO) == '00086' .or.;
		  Alltrim(cC2_PRODUTO) == '00076'     
        cProOpe := '820101002'  // Novo codigo cfe Fabi 08/08/2007
	     cQtdKg  := MSC2->C2_QUANT  * 0.8480
     EndIf
     If Alltrim(cC2_PRODUTO) == '00078' .or.;
        Alltrim(cC2_PRODUTO) == '00087' 
        cProOpe := '820101009'  // Novo codigo cfe Fabi 08/08/2007
	     cQtdKg  := MSC2->C2_QUANT  * 0.8480
     EndIf
     If Alltrim(cC2_PRODUTO) == '00097' .or.;
        Alltrim(cC2_PRODUTO) == '00096' 
        cProOpe := '820101007'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := MSC2->C2_QUANT  * 0.8480
     EndIf

/*     If Alltrim(cC2_PRODUTO) == '00098' .or.;
        Alltrim(cC2_PRODUTO) == '00099' 
        cProOpe := '820101017'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := MSC2->C2_QUANT  * 0.8480
     EndIf*/
/*     If Alltrim(cC2_PRODUTO) == '00100' .or.;
        Alltrim(cC2_PRODUTO) == '00101' 
        cProOpe := '820101008'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := MSC2->C2_QUANT  * 0.8480
     EndIf */  //ALTERADO 21/01/09
     If Alltrim(cC2_PRODUTO) == '00083'
        cProOpe := '220101005'  // Novo codigo cfe Fabi 10/08/2007
	     cQtdKg  := MSC2->C2_QUANT  * 0.7500
     EndIf
     If Alltrim(cC2_PRODUTO) == '00095'
        cProOpe := '220101003'  // Novo codigo cfe Fabi 22/01/2008
	     cQtdKg  := MSC2->C2_QUANT  * 0.7500
     EndIf
//	  If Alltrim(cC2_PRODUTO) == '00009' .or.; ALTERADO FABI 20/08/08
//	     Alltrim(cC2_PRODUTO) == '00033' 
//	     cProOpe := '420101002'
//        cProOpe := '420101005'  // Novo codigo cfe Fabi 15/03/2007
//	     cQtdKg  := MSC2->C2_QUANT  * 0.8480
//	  EndIf
//	  If Alltrim(cC2_PRODUTO) == '00023' .or.; ALTERADO FABI 20/08/08
//		  Alltrim(cC2_PRODUTO) == '00085' 
//	     cProOpe := '420102001'
//        cProOpe := '420102004'  // Novo codigo cfe Fabi 15/03/2007
//	     cQtdKg  := MSC2->C2_QUANT  * 0.8480
//	  EndIf
	  If Alltrim(cC2_PRODUTO) == '00078' 
        cProOpe := '420102002'  // Novo codigo cfe Fabi 12/07/2007
	     cQtdKg  := MSC2->C2_QUANT  * 0.8480
	  EndIf
	  If Alltrim(cC2_PRODUTO) == '00019' .or.;
	     Alltrim(cC2_PRODUTO) == '00074' 
	     cProOpe := '420201001'
	     cQtdKg  := MSC2->C2_QUANT  * 0.8480
	  EndIf
	  If Alltrim(cC2_PRODUTO) == '00010' .or.;
	     Alltrim(cC2_PRODUTO) == '00011' .or.;
	     Alltrim(cC2_PRODUTO) == '00092' 
	     cProOpe := '510101001'
	     cQtdKg  := MSC2->C2_QUANT  * 1.0000
	  EndIf
	  If Alltrim(cC2_PRODUTO) == '00001' .or.;
	     Alltrim(cC2_PRODUTO) == '00002' .or.;
	     Alltrim(cC2_PRODUTO) == '00003' .or.;
	     Alltrim(cC2_PRODUTO) == '00058' .or.;
	     Alltrim(cC2_PRODUTO) == '00084' .or.;
	     Alltrim(cC2_PRODUTO) == '00090' .or.;
	     Alltrim(cC2_PRODUTO) == '00091'      
	     cProOpe := '560101001'
	     cQtdKg  := MSC2->C2_QUANT  * 1.0000
	  EndIf
	  If Alltrim(cC2_PRODUTO) == '00015' .or.;
	     Alltrim(cC2_PRODUTO) == '00072' .or.;
	     Alltrim(cC2_PRODUTO) == '00073' 
	     cProOpe := '810101001'
	     cQtdKg  := MSC2->C2_QUANT  * 0.8100
	  EndIf
	  If Alltrim(cC2_PRODUTO) == '00013' 
	     cProOpe := '810102001'
	     cQtdKg  := MSC2->C2_QUANT  * 0.8100
	  EndIf
	  If Alltrim(cC2_PRODUTO) == '00016'// .Or.;
//		  Alltrim(cC2_PRODUTO) == '00810002'
	     cProOpe := '740101001'
	     cQtdKg  := MSC2->C2_QUANT  * 0.7430
	  EndIf
	  If Alltrim(cC2_PRODUTO) == '00017' .Or.;
		  Alltrim(cC2_PRODUTO) == '00810001' .OR. ;
		  Alltrim(cC2_PRODUTO) == '00810002'
	     cProOpe := '740101002'
	     cQtdKg  := MSC2->C2_QUANT  * 0.8480
	  EndIf

	  SELE ESTOQUE  // Extrai Total Transferencia Entradas
	  If !DbSeek(cProOpe)
	     Reclock("ESTOQUE",.T.)
	     ESTOQUE->PROOPE  := cProOpe
	     ESTOQUE->QTDETE  := int(MSC2->C2_QUANT)
	     ESTOQUE->QTDKGTE := cQtdKg
	     MsUnlock("ESTOQUE") 
	  Else
	     Reclock("ESTOQUE",.F.)
	     ESTOQUE->QTDETE  := ESTOQUE->QTDETE  + int(MSC2->C2_QUANT)
	     ESTOQUE->QTDKGTE := ESTOQUE->QTDKGTE + cQtdKg
	     MsUnlock("ESTOQUE") 
	  Endif
	   
	  cLinha := cLinha + cProOpe // Cod Prod Operado
	   
	  cQtdPro := Int(MSC2->C2_QUANT)
	  cLinha  := cLinha + StrZero(cQtdPro,15)
	
	  cQtdKgl := int(cQtdKg)
	  cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000
	                                          
      If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
         cQtdKgm := 1
      Endif
	  If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
	     cQtdKgm := 1
	  Endif
	   
	  cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
	   
	  cLinha := cLinha + '0' // Cod Modal Utilizado na Movimentacao 0 = Interno cfe FAbi
	  cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
	   
	  cIdent := '00000000000000'
	  cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
	   
	  cMun_ANP := '0008518'
	
	  cAtivida := '51519'  
	
	  cLinha := cLinha + '0000000' // Codigo Municipio
	  cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
	  cLinha := cLinha + '0000' // Cod do país
	  cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	  cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
		
	  cDoc   := '0000000' // Numero da NF fica zeros por ser transacao interna cfe Fabi
	  cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	  cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 00 == Interna
		
	  cDtEmi := strzero(day(MSC2->C2_EMISSAO),2)+strzero(month(MSC2->C2_EMISSAO),2)+strzero(year(MSC2->C2_EMISSAO),4)	
	  cLinha := cLinha + cDtEmi // Data da operacao Comercial
	  cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
		
	  cFisQui1 := '000' // Cfe Fabi transferencia sera tudo Zero!! 02/01/2007
	  cMetodo1 := '000'
	  cUnMedi1 := '00'
	  cVlCara1 := '0000000000'
	  cMassaE1 := '0000000'
/*	   
      If Alltrim(cC2_PRODUTO) == '00007'    .or.;  // Para Querosene Colocar Zeros cfe Fabi
         Alltrim(cC2_PRODUTO) == '00060001' .or.;
         Alltrim(cC2_PRODUTO) == '00060002'
   	     cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	     cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	     cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
   	     cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
         cMassaE1 := '0000000'    // Massa Especifica do Produto
      Endif

      If Alltrim(cC2_PRODUTO) == '00001' .or.; // Para Oleo Xisto Colocar Zeros cfe Fabi
         Alltrim(cC2_PRODUTO) == '00002' .or.;
         Alltrim(cC2_PRODUTO) == '00003'
   	     cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	     cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
   	     cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	     cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
         cMassaE1 := '0000000'    // Massa Especifica do Produto
      Endif

      If Alltrim(cC2_PRODUTO) == '00010' .or.; // Para Oleo Combustivel 1A Zeros Cfe Fabi 
         Alltrim(cC2_PRODUTO) == '00011' .or.; // Para Oleo Combustivel 2A Zeros Cfe Fabi 
         Alltrim(cC2_PRODUTO) == '00016' .or.; // Para Aditivo Hitec 6421 (Gasolina) Zeros Cfe Fabi
         Alltrim(cC2_PRODUTO) == '00017' .or.; // Para Aditivo Hitec 4130 (Diesel)   Zeros Cfe Fabi
         Alltrim(cC2_PRODUTO) == '00810002' .or.; // Para Aditivo Hitec 6421 (Gasolina) Zeros Cfe Fabi
         Alltrim(cC2_PRODUTO) == '00810001'       // Para Aditivo Hitec 4130 (Diesel)   Zeros Cfe Fabi
	     cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	     cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
   	     cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	     cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
         cMassaE1 := '0000000'    // Massa Especifica do Produto
      Endif

	  If Alltrim(cC2_PRODUTO) == '00031' .or.;
		 Alltrim(cC2_PRODUTO) == '00033' .or.;
		 Alltrim(cC2_PRODUTO) == '00008' .or.;
		 Alltrim(cC2_PRODUTO) == '00009' .or.;
		 Alltrim(cC2_PRODUTO) == '00019' .or.;
		 Alltrim(cC2_PRODUTO) == '00074' 
		 Alltrim(cC2_PRODUTO) == '00023' 
	
		 cFisQui1 := '004' // Codigo da Caracteristica Fisico-Quimica do produto
		 cMetodo1 := '002' // Codigo do Metodo Utilizado para Afericao da Caracteristica
		 cUnMedi1 := '02'  // Codigo da Unidade de Medida da Caracteristica 
		 cVlCara1 := '0004000000' // Valor Encontrado da Caracteristica
	     cMassaE1 := '0040000'    // Massa Especifica do Produto
	      
	  Endif
	  If Alltrim(cC2_PRODUTO) == '00004' .or.;
		 Alltrim(cC2_PRODUTO) == '00034' .or.;
		 Alltrim(cC2_PRODUTO) == '00005' .or.;
		 Alltrim(cC2_PRODUTO) == '00032' .or.;
		 Alltrim(cC2_PRODUTO) == '00006' .or.;
		 Alltrim(cC2_PRODUTO) == '00024' .or.;
		 Alltrim(cC2_PRODUTO) == '00014' 
		 cFisQui1 := '004'
		 cMetodo1 := '002'
		 cUnMedi1 := '02'
		 cVlCara1 := '0075110000'
	     cMassaE1 := '0751100'
	
	  Endif
	  If Alltrim(cC2_PRODUTO) == '00013' .or.;
		 Alltrim(cC2_PRODUTO) == '00015' .or.;
		 Alltrim(cC2_PRODUTO) == '00072' .or.;
		 Alltrim(cC2_PRODUTO) == '00073' 
		 cFisQui1 := '004'
		 cMetodo1 := '002'
		 cUnMedi1 := '02'
		 cVlCara1 := '0081060000'
	     cMassaE1 := '0810600'
	
	  Endif
*/		
	  cRecGLP := '00'    // Recipiente de GLP
		
	  cLinhax := ''
	  If !Empty(cFisQui1) 
	     cConta := cConta + 1  // Nr Registro
		 cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP
	
		 SELE AGR159
	     Reclock("AGR159",.T.)
	     AGR159->SEQ    := cConta
	     AGR159->LIN    := cLinhax
	     MsUnlock("AGR159") 
	  Endif
   Endif

   sele MSC2
   dbskip()

END            
*
* Extrai NFs de Entrada
*        
sele MSD1
dbgotop()
Procregua(Reccount())
While !eof() 
   
   Incproc()
   cLinha := ''
   cOperac:= '0000000'

  
   cLinha := '1001799935'         // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   If Alltrim(MSD1->D1_CF) == '1652' .Or. Alltrim(MSD1->D1_CF) == '2652'
      cOperac := '1011001'
   Endif
   If Alltrim(MSD1->D1_CF) == '1661' .Or. Alltrim(MSD1->D1_CF) == '2661'
      cOperac := '1011004'
   Endif
   If Alltrim(MSD1->D1_CF) == '1662' .Or. Alltrim(MSD1->D1_CF) == '2662'
      cOperac := '1011005'
   Endif
   If Alltrim(MSD1->D1_CF) == '1659' .Or. Alltrim(MSD1->D1_CF) == '2659'
      cOperac := '1011999'
   Endif
   
   If cOperac == '0000000'
      Sele MSD1 
      DbSkip()
      Loop
   Endif
   
   cLinha := cLinha + cOperac   // Operacao
   
   cLinha := cLinha + '1032183' // Cod Instalacao 1
   
   cInstANP := '0000000'
   DbSelectArea("SA2")
   DbGotop()
   DbSeek(xFilial("SA2")+MSD1->D1_FORNECE+MSD1->D1_LOJA)
   If !Empty(SA2->A2_INSTANP)
      cInstANP := SA2->A2_INSTANP
      IF Len(Alltrim(SA2->A2_INSTANP)) < 7
         cInstANP := StrZero(val(Alltrim(SA2->A2_INSTANP)),7)
      Endif
   Endif
   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   Sele MSD1
      
   cProOpe:= '000000000'
   cQtdKg := 0
   If Alltrim(MSD1->D1_COD) == '00004'
      cProOpe := '320101001'
      cQtdKg  := MSD1->D1_QUANT * 0.7430
   EndIf
   If Alltrim(MSD1->D1_COD) == '00005' .or.;
      Alltrim(MSD1->D1_COD) == '00014' .or.;
      Alltrim(MSD1->D1_COD) == '00032'
      cProOpe := '320102001'
      cQtdKg  := MSD1->D1_QUANT * 0.7430
   EndIf
   If Alltrim(MSD1->D1_COD) == '00006' .or.;
      Alltrim(MSD1->D1_COD) == '00024' .or.;
      Alltrim(MSD1->D1_COD) == '00034'
      cProOpe := '320102002'
      cQtdKg  := MSD1->D1_QUANT * 0.7430
   EndIf
   If Alltrim(MSD1->D1_COD) == '00007'    .or.;
      Alltrim(MSD1->D1_COD) == '00060001' .or.;
      Alltrim(MSD1->D1_COD) == '00060002'
      cProOpe := '410102001'
      cQtdKg  := MSD1->D1_QUANT * 0.8114
   EndIf
   If Alltrim(MSD1->D1_COD) == '00008' .or.; //ALTERADO CFE FABI 20/08/08
      Alltrim(MSD1->D1_COD) == '00031' 
//      cProOpe := '420101001'
      cProOpe := '420101004'  // Novo codigo cfe Fabi 15/03/2007
      cQtdKg  := MSD1->D1_QUANT * 0.8480
   EndIf
   If Alltrim(MSD1->D1_COD) == '00103' 
      cProOpe := '820101001'  // Novo codigo cfe Fabi 20/08/08
      cQtdKg  := MSD1->D1_QUANT * 0.8480
   EndIf   
   If Alltrim(MSD1->D1_COD) == '00008' 
      cProOpe := '420101004'  // Novo codigo cfe Fabi 11/04/2008
      cQtdKg  := MSD1->D1_QUANT * 0.8480
   EndIf
   If Alltrim(MSD1->D1_COD) == '00086' .or.;
	   Alltrim(MSD1->D1_COD) == '00076' 
      cProOpe := '820101002'  // Novo codigo cfe Fabi 08/08/2007
      cQtdKg  := MSD1->D1_QUANT * 0.8480
   EndIf
   If Alltrim(MSD1->D1_COD) == '00078' .or.;
      Alltrim(MSD1->D1_COD) == '00087'       
      cProOpe := '820101009'  // Novo codigo cfe Fabi 08/08/2007
      cQtdKg  := MSD1->D1_QUANT * 0.8480
   EndIf
   If Alltrim(MSD1->D1_COD) == '00097' .or.;
      Alltrim(MSD1->D1_COD) == '00096'       
      cProOpe := '820101007'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := MSD1->D1_QUANT * 0.8480
   EndIf
/*   If Alltrim(MSD1->D1_COD) == '00098' .or.;
      Alltrim(MSD1->D1_COD) == '00099'       
      cProOpe := '820101017'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := MSD1->D1_QUANT * 0.8480
   EndIf*/
   If Alltrim(MSD1->D1_COD) == '00100' .or.;
      Alltrim(MSD1->D1_COD) == '00101'       
      cProOpe := '820101008'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := MSD1->D1_QUANT * 0.8480
   EndIf
   If Alltrim(MSD1->D1_COD) == '00083'
      cProOpe := '220101005'  // Novo codigo cfe Fabi 10/08/2007
      cQtdKg  := MSD1->D1_QUANT * 0.7500
   EndIf
   If Alltrim(MSD1->D1_COD) == '00095'
      cProOpe := '220101003'  // Novo codigo cfe Fabi 22/01/2008
      cQtdKg  := MSD1->D1_QUANT * 0.7500
   EndIf
//   If Alltrim(MSD1->D1_COD) == '00009' .or.;  ALTERADO FABI 20/08/08
//      Alltrim(MSD1->D1_COD) == '00033' 
//      cProOpe := '420101002'
//      cProOpe := '420101005'  // Novo codigo cfe Fabi 15/03/2007
//      cQtdKg  := MSD1->D1_QUANT * 0.8480
//   EndIf
//   If Alltrim(MSD1->D1_COD) == '00023' .or.; ALTERADO FABI 20/08/08
//		Alltrim(MSD1->D1_COD) == '00085'    
//      cProOpe := '420102001'
//      cProOpe := '420102004'  // Novo codigo cfe Fabi 15/03/2007
//      cQtdKg  := MSD1->D1_QUANT * 0.8480
//   EndIf
   If Alltrim(MSD1->D1_COD) == '00078' 
      cProOpe := '420102002'  // Novo codigo cfe Fabi 12/07/2007
      cQtdKg  := MSD1->D1_QUANT * 0.8480
   EndIf
   If Alltrim(MSD1->D1_COD) == '00019' .or.;
      Alltrim(MSD1->D1_COD) == '00074' 
      cProOpe := '420201001'
      cQtdKg  := MSD1->D1_QUANT * 0.8480
   EndIf
   If Alltrim(MSD1->D1_COD) == '00010' .or.;
      Alltrim(MSD1->D1_COD) == '00011' .or.;
      Alltrim(MSD1->D1_COD) == '00092' 
      cProOpe := '510101001'
      cQtdKg  := MSD1->D1_QUANT * 1.0000
   EndIf
   If Alltrim(MSD1->D1_COD) == '00001' .or.;
      Alltrim(MSD1->D1_COD) == '00002' .or.;
      Alltrim(MSD1->D1_COD) == '00003' .or.;
      Alltrim(MSD1->D1_COD) == '00058' .or.;
      Alltrim(MSD1->D1_COD) == '00084' .or.;
      Alltrim(MSD1->D1_COD) == '00090' .or.;
      Alltrim(MSD1->D1_COD) == '00091'      
      cProOpe := '560101001'
      cQtdKg  := MSD1->D1_QUANT * 1.0000
   EndIf
   If Alltrim(MSD1->D1_COD) == '00015' .or.;
      Alltrim(MSD1->D1_COD) == '00072' .or.;
      Alltrim(MSD1->D1_COD) == '00073' 
      cProOpe := '810101001'
      cQtdKg  := MSD1->D1_QUANT * 0.8100
   EndIf
   If Alltrim(MSD1->D1_COD) == '00013' 
      cProOpe := '810102001'
      cQtdKg  := MSD1->D1_QUANT * 0.8100
   EndIf
   If Alltrim(MSD1->D1_COD) == '00016' //.Or.;
//	   Alltrim(MSD1->D1_COD) == '00810002'
      cProOpe := '740101001'
      cQtdKg  := MSD1->D1_QUANT * 0.7430
   EndIf
   If Alltrim(MSD1->D1_COD) == '00017' .Or.;
	   Alltrim(MSD1->D1_COD) == '00810001' .OR. ;
 	   Alltrim(MSD1->D1_COD) == '00810002'	   
      cProOpe := '740101002'
      cQtdKg  := MSD1->D1_QUANT * 0.8480
   EndIf
   
   If cProOpe == '000000000'
      Sele MSD1
      DbSkip()
      Loop
   EndIf
   
   SELE ESTOQUE  // Extrai Total Entradas
   If !DbSeek(cProOpe)
      Reclock("ESTOQUE",.T.)
      ESTOQUE->PROOPE := cProOpe
      ESTOQUE->QTDEE  := int(MSD1->D1_QUANT)
      ESTOQUE->QTDKGE := cQtdKg
      MsUnlock("ESTOQUE") 
   Else
      Reclock("ESTOQUE",.F.)
      ESTOQUE->QTDEE  := ESTOQUE->QTDEE  + int(MSD1->D1_QUANT)
      ESTOQUE->QTDKGE := ESTOQUE->QTDKGE + cQtdKg
      MsUnlock("ESTOQUE") 
   Endif

   SELE MSD1

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(MSD1->D1_QUANT)
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'
   Sele SA2
   If Empty(SA2->A2_INSTANP)
      If SA2->A2_TIPO == 'J' .or. SA2->A2_TIPO == 'F'
         cIdent := SA2->A2_CGC
      Endif
      If SA2->A2_TIPO == 'F'
         cIdent := StrZero(val(Alltrim(SA2->A2_CGC)),14)
      Endif
   Endif
   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000'
   If !Empty(SA2->A2_Mun_ANP)
      cMun_ANP := SA2->A2_Mun_ANP
      IF Len(Alltrim(SA2->A2_Mun_ANP)) < 7
         cMun_ANP := StrZero(val(Alltrim(SA2->A2_Mun_ANP)),7)
      Endif
   Endif
   cAtivida := '00000'  
   If !Empty(SA2->A2_ATIVIDA)
      cAtivida := SA2->A2_ATIVIDA
      IF Len(Alltrim(SA2->A2_ATIVIDA)) < 5
         cAtivida := StrZero(val(Alltrim(SA2->A2_ATIVIDA)),5)
      Endif
   Endif
   cLinha := cLinha + cMun_ANP // Codigo Municipio
   cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
   cLinha := cLinha + '0000' // Cod do país
   cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
   cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
   Sele MSD1
   cDoc   := MSD1->D1_DOC
   IF Len(Alltrim(MSD1->D1_DOC)) < 7
      cDoc := StrZero(val(Alltrim(MSD1->D1_DOC)),7)
   Endif
   cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
   cLinha := cLinha + '04' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MSD1->D1_DTDIGIT),2)+strzero(month(MSD1->D1_DTDIGIT),2)+strzero(year(MSD1->D1_DTDIGIT),4)	
   cLinha := cLinha + cDtEmi // Data da operacao Comercial
   cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '   '
   cMetodo1 := '   '
   cUnMedi1 := '  '
   cVlCara1 := '          '
   cMassaE1 := '       '
   cFisQui11:= '   '
   cMetodo11:= '   '
   cUnMedi11:= '  '
   cVlCara11:= '          '
   cMassaE11:= '       '
   cFisQui2 := '   '
   cMetodo2 := '   '
   cUnMedi2 := '  '
   cVlCara2 := '          '
   cMassaE2 := '       '
   cFisQui21:= '   '
   cMetodo21:= '   '
   cUnMedi21:= '  '
   cVlCara21:= '          '
   cMassaE21:= '       '
   cFisQui3 := '   '
   cMetodo3 := '   '
   cUnMedi3 := '  '
   cVlCara3 := '          '
   cMassaE3 := '       '
   cFisQui4 := '   '
   cMetodo4 := '   '
   cUnMedi4 := '  '
   cVlCara4 := '          '
   cMassaE4 := '       '
   cFisQui5 := '   '
   cMetodo5 := '   '
   cUnMedi5 := '  '
   cVlCara5 := '          '
   cMassaE5 := '       '
   
   *
   * Cfe Fabi entradas serao tudo zero!! 02/01/2007
   *
   cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
   cMassaE1 := '0000000'    // Massa Especifica do Produto
/*   
   If Alltrim(MSD1->D1_COD) == '00007'    .or.;  // Para Querosene Colocar Zeros cfe Fabi
      Alltrim(MSD1->D1_COD) == '00060001' .or.;
      Alltrim(MSD1->D1_COD) == '00060002'
	  cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	  cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	  cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	  cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
      cMassaE1 := '0000000'    // Massa Especifica do Produto
   Endif

   If Alltrim(MSD1->D1_COD) == '00001' .or.; // Para Oleo Xisto Colocar Zeros cfe Fabi
      Alltrim(MSD1->D1_COD) == '00002' .or.;
      Alltrim(MSD1->D1_COD) == '00003'
	  cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	  cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	  cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	  cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
      cMassaE1 := '0000000'    // Massa Especifica do Produto
   Endif

   If Alltrim(MSD1->D1_COD) == '00010' .or.; // Para Oleo Combustivel 1A Zeros Cfe Fabi 
      Alltrim(MSD1->D1_COD) == '00011' .or.; // Para Oleo Combustivel 2A Zeros Cfe Fabi 
      Alltrim(MSD1->D1_COD) == '00016' .or.; // Para Aditivo Hitec 6421 (Gasolina) Zeros Cfe Fabi
      Alltrim(MSD1->D1_COD) == '00017' .or.; // Para Aditivo Hitec 4130 (Diesel)   Zeros Cfe Fabi
      Alltrim(MSD1->D1_COD) == '00810002' .or.; // Para Aditivo Hitec 6421 (Gasolina) Zeros Cfe Fabi
      Alltrim(MSD1->D1_COD) == '00810001'       // Para Aditivo Hitec 4130 (Diesel)   Zeros Cfe Fabi
	  cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	  cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	  cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	  cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
      cMassaE1 := '0000000'    // Massa Especifica do Produto
   Endif

   If Alltrim(MSD1->D1_COD) == '00031' .or.;
	  Alltrim(MSD1->D1_COD) == '00033' .or.;
	  Alltrim(MSD1->D1_COD) == '00008' .or.;
	  Alltrim(MSD1->D1_COD) == '00009' .or.;
	  Alltrim(MSD1->D1_COD) == '00019' .or.;
	  Alltrim(MSD1->D1_COD) == '00074' .or.;
	  Alltrim(MSD1->D1_COD) == '00023' 

	  cFisQui1 := '004' // Codigo da Caracteristica Fisico-Quimica do produto
	  cMetodo1 := '002' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	  cUnMedi1 := '02'  // Codigo da Unidade de Medida da Caracteristica 
	  cVlCara1 := '0004000000' // Valor Encontrado da Caracteristica
      cMassaE1 := '0040000'    // Massa Especifica do Produto
   Endif
   If Alltrim(MSD1->D1_COD) == '00004' .or.;
	  Alltrim(MSD1->D1_COD) == '00034' .or.;
	  Alltrim(MSD1->D1_COD) == '00005' .or.;
	  Alltrim(MSD1->D1_COD) == '00032' .or.;
	  Alltrim(MSD1->D1_COD) == '00006' .or.;
	  Alltrim(MSD1->D1_COD) == '00024' .or.;
	  Alltrim(MSD1->D1_COD) == '00014' 
	  cFisQui1 := '004'
	  cMetodo1 := '002'
	  cUnMedi1 := '02'
	  cVlCara1 := '0075110000'
      cMassaE1 := '0751100'
   Endif
   If Alltrim(MSD1->D1_COD) == '00013' .or.;
	  Alltrim(MSD1->D1_COD) == '00015' .or.;
	  Alltrim(MSD1->D1_COD) == '00072' .or.;
	  Alltrim(MSD1->D1_COD) == '00073' 
	  cFisQui1 := '004'
	  cMetodo1 := '002'
	  cUnMedi1 := '02'
	  cVlCara1 := '0081060000'
      cMassaE1 := '0810600'
   Endif
*/	
   cProRes := cProOpe // Codigo do Produto/Operacao Resultante
   cRecGLP := '00'    // Recipiente de GLP
	
   cLinhax := ''
   If !Empty(cFisQui1) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui11) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui11 + cMetodo11 + cUnMedi11 + cVlCara11 + cProRes + cMassaE11 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui2) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui2 + cMetodo2 + cUnMedi2 + cVlCara2 + cProRes + cMassaE2 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui21) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui21 + cMetodo21 + cUnMedi21 + cVlCara21 + cProRes + cMassaE21 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui3) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui3 + cMetodo3 + cUnMedi3 + cVlCara3 + cProRes + cMassaE3 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui4) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui4 + cMetodo4 + cUnMedi4 + cVlCara4 + cProRes + cMassaE4 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui5) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui5 + cMetodo5 + cUnMedi5 + cVlCara5 + cProRes + cMassaE5 + cRecGLP

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif

   sele MSD1
   dbskip()

END            
*
* Extrai Total Saidas e Entradas , Total Transferencia saidas e Transferencia Entradas 
* e Reg. Inventario caso diferencas (Inicial + (Entrada + Transf. Entradas) - (Saida + Transf. Saidas) = Final)
*
Sele ESTOQUE
DbGotop()
Procregua(Reccount())
While !Eof() 
   *
   * Reg. Inventario caso diferencas (Inicial + (Entrada + Transf. Entradas) - (Saida + Transf. Saidas) = Final)
   *                
   cTotEnt   := ''
   nQTDEINS  := 0
   nQTDKGINS := 0
   nQTDEINE  := 0
   nQTDKGINE := 0
   nQTDEIN   := (ESTOQUE->QTDEI + (ESTOQUE->QTDEE + ESTOQUE->QTDETE)  - (ESTOQUE->QTDES + ESTOQUE->QTDETS)) - ESTOQUE->QTDEF
   nQTDKGIN  := (ESTOQUE->QTDKGI + (ESTOQUE->QTDKGE + ESTOQUE->QTDKGTE) - (ESTOQUE->QTDKGS + ESTOQUE->QTDKGTS)) - ESTOQUE->QTDKGF
   
   If nQTDEIN < 0 // Antes de Extrair o registro de saida inventario Extrai Total Entradas
	   *
	   * Total Entradas
	   *
	   cTotEnt := 'S'
	   Incproc()
	   cLinha := Space(01)
	   cOperac:= '0000000'
	
	  
	   cLinha := '1001799935'         // Nr Agente Reg Informante
	   cLinha := cLinha + cMMAAAA              // Mes Referencia
	   
	   cOperac := '1011998' // Operacao para Total Entradas Comerciais Nacionais
	   
	   cLinha := cLinha + cOperac   // Operacao
	   
	   cLinha := cLinha + '1032183' // Cod Instalacao 1
	   
	   cInstANP := '0000000'  // Cod Instalacao 2
	
	   cLinha := cLinha + cInstANP  // Cod Instalacao 2
	
	   cProOpe:= ESTOQUE->PROOPE
	   cQtdKg := ESTOQUE->QTDKGE
	
	   cLinha := cLinha + cProOpe // Cod Prod Operado
	   
	   cQtdPro := Int(ESTOQUE->QTDEE)
	   cLinha  := cLinha + StrZero(cQtdPro,15)
	
	   cQtdKgl := int(cQtdKg)
	   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000
	
	   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   
	   cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
	   
	   cLinha := cLinha + '0' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
	   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
	   
	   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao
	
	   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
	   
	   cMun_ANP := '0000000' // Codigo Municipio
	
	   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro
	   
	   cLinha := cLinha + cMun_ANP // Codigo Municipio
	   cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
	   cLinha := cLinha + '0000' // Cod do país
	   cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	   cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
		
	   cDoc   := '0000000'    
	   cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	   cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
		
	   cDtEmi := strzero(day(MV_PAR03),2)+strzero(month(MV_PAR03),2)+strzero(year(MV_PAR03),4)	
	   cLinha := cLinha + cDtEmi // Data da operacao Comercial
	   cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
		
	   cFisQui1 := '000'
	   cMetodo1 := '000'
	   cUnMedi1 := '00'
	   cVlCara1 := '0000000000'
	   cMassaE1 := '0000000'
		
	   cProRes := '000000000' // Codigo do Produto/Operacao Resultante
	   cRecGLP := '00'    // Recipiente de GLP
		
	   cLinhax := ''
	   If !Empty(cFisQui1) .and. cQtdPro > 0
	      cConta := cConta + 1  // Nr Registro
		   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP
	
		   SELE AGR159
	      Reclock("AGR159",.T.)
	      AGR159->SEQ    := cConta
	      AGR159->LIN    := cLinhax
	      MsUnlock("AGR159") 
	   Endif
   Endif   
   *
   * Reg. Inventario para Saida
   *      
   If nQTDEIN > 0 // Qtde inventario maior que zero eh qtdo teve mais entrada que saida, se faz ajuste SAIDA
      If nQTDKGIN < 0
         nQTDKGIN := nQTDKGIN * -1 // Se for qtde negativa torna positiva
      Endif
	   nQTDEINS  := nQTDEIN
	   nQTDKGINS := nQTDKGIN
	   Incproc()
	   cLinha := Space(01)
	   cOperac:= '0000000'
	
	  
	   cLinha := '1001799935'         // Nr Agente Reg Informante
	   cLinha := cLinha + cMMAAAA              // Mes Referencia
	   
	   cOperac := '1022004' // Operacao para Perdas de Processo
	   
	   cLinha := cLinha + cOperac   // Operacao
	   
	   cLinha := cLinha + '1032183' // Cod Instalacao 1
	   
	   cInstANP := '0000000'  // Cod Instalacao 2
	
	   cLinha := cLinha + cInstANP  // Cod Instalacao 2
	
	   cProOpe:= ESTOQUE->PROOPE
	   cQtdKg := nQTDKGIN
	   If cQtdKg < 0 // Se for qtde negativa torna positiva
	      cQtdKg := cQtdKg * -1        
	   Endif
	
	   cLinha := cLinha + cProOpe // Cod Prod Operado
	   
	   cQtdPro := Int(nQTDEIN)
	   cLinha  := cLinha + StrZero(cQtdPro,15)
	
	   cQtdKgl := int(cQtdKg)
	   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

	   If cQtdKgl == 0 .And. cQtdKgm < 0.001 // Caso Quilos e Miligramas zero movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   
	   cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
	   
	   cLinha := cLinha + '0' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
	   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
	   
	   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao
	
	   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
	   
	   cMun_ANP := '0000000' // Codigo Municipio
	
	   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro
	
		cLinha := cLinha + '0000000' // Codigo Municipio
		cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
		cLinha := cLinha + '0000' // Cod do país
		cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
		cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
		
		cDoc   := '0000000'    
		cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
		cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
		
	   cDtEmi := strzero(day(MV_PAR03),2)+strzero(month(MV_PAR03),2)+strzero(year(MV_PAR03),4)	
		cLinha := cLinha + cDtEmi // Data da operacao Comercial
		cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
		
	   cFisQui1 := '000'
	   cMetodo1 := '000'
	   cUnMedi1 := '00'
	   cVlCara1 := '0000000000'
	   cMassaE1 := '0000000'
		
		cProRes := '000000000' // Codigo do Produto/Operacao Resultante
		cRecGLP := '00'    // Recipiente de GLP
		
		cLinhax := ''
		If !Empty(cFisQui1) .and. cQtdPro > 0
	      cConta := cConta + 1  // Nr Registro
		   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP
	
		   SELE AGR159
	      Reclock("AGR159",.T.)
	      AGR159->SEQ    := cConta
	      AGR159->LIN    := cLinhax
	      MsUnlock("AGR159") 
		Endif
	Endif
   If nQTDEIN < 0 // Qtde inventario menor que zero eh qtdo teve mais Saida que Entrada, se faz ajuste ENTRADA
      nQTDEIN  := nQTDEIN  * -1
      If nQTDKGIN < 0
         nQTDKGIN := nQTDKGIN * -1 
      Endif
	   nQTDEINE  := nQTDEIN
	   nQTDKGINE := nQTDKGIN
      
	   Incproc()
	   cLinha := Space(01)
	   cOperac:= '0000000'
	
	  
	   cLinha := '1001799935'         // Nr Agente Reg Informante
	   cLinha := cLinha + cMMAAAA              // Mes Referencia
	   
	   cOperac := '1021001' // Operacao para Sobras de processo
	   
	   cLinha := cLinha + cOperac   // Operacao
	   
	   cLinha := cLinha + '1032183' // Cod Instalacao 1
	   
	   cInstANP := '0000000'  // Cod Instalacao 2
	
	   cLinha := cLinha + cInstANP  // Cod Instalacao 2
	
	   cProOpe:= ESTOQUE->PROOPE
	   cQtdKg := nQTDKGIN        
	   If cQtdKg < 0 // Se for qtde negativa torna positiva
	      cQtdKg := cQtdKg * -1        
	   Endif
	
	   cLinha := cLinha + cProOpe // Cod Prod Operado
	   
	   cQtdPro := Int(nQTDEIN)
	   cLinha  := cLinha + StrZero(cQtdPro,15)
	
	   cQtdKgl := int(cQtdKg)
	   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000
	   
	   If cQtdKgl == 0 .And. cQtdKgm < 0.001 // Caso Quilos e Miligramas zero movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   
	   cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
	   
	   cLinha := cLinha + '0' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
	   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
	   
	   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao
	
	   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
	   
	   cMun_ANP := '0000000' // Codigo Municipio
	
	   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro
	
		cLinha := cLinha + '0000000' // Codigo Municipio
		cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
		cLinha := cLinha + '0000' // Cod do país
		cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
		cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
		
		cDoc   := '0000000'    
		cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
		cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
		
	   cDtEmi := strzero(day(MV_PAR03),2)+strzero(month(MV_PAR03),2)+strzero(year(MV_PAR03),4)	
		cLinha := cLinha + cDtEmi // Data da operacao Comercial
		cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
		
	   cFisQui1 := '000'
	   cMetodo1 := '000'
	   cUnMedi1 := '00'
	   cVlCara1 := '0000000000'
	   cMassaE1 := '0000000'
		
		cProRes := '000000000' // Codigo do Produto/Operacao Resultante
		cRecGLP := '00'    // Recipiente de GLP
		
		cLinhax := ''
		If !Empty(cFisQui1) .and. cQtdPro > 0
	      cConta := cConta + 1  // Nr Registro
		   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP
	
		   SELE AGR159
	      Reclock("AGR159",.T.)
	      AGR159->SEQ    := cConta
	      AGR159->LIN    := cLinhax
	      MsUnlock("AGR159") 
		Endif
	Endif
	If cTotEnt == '' // Caso nao tenha Registro inventario de Saida imprime agora total Entradas
	   *
	   * Total Entradas
	   *
	   Incproc()
	   cLinha := Space(01)
	   cOperac:= '0000000'
	
	  
	   cLinha := '1001799935'         // Nr Agente Reg Informante
	   cLinha := cLinha + cMMAAAA              // Mes Referencia
	   
	   cOperac := '1011998' // Operacao para Total Entradas Comerciais Nacionais
	   
	   cLinha := cLinha + cOperac   // Operacao
	   
	   cLinha := cLinha + '1032183' // Cod Instalacao 1
	   
	   cInstANP := '0000000'  // Cod Instalacao 2
	
	   cLinha := cLinha + cInstANP  // Cod Instalacao 2
	
	   cProOpe:= ESTOQUE->PROOPE
	   cQtdKg := ESTOQUE->QTDKGE
	
	   cLinha := cLinha + cProOpe // Cod Prod Operado
	   
	   cQtdPro := Int(ESTOQUE->QTDEE)
	   cLinha  := cLinha + StrZero(cQtdPro,15)
	
	   cQtdKgl := int(cQtdKg)
	   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000
	
	   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   
	   cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
	   
	   cLinha := cLinha + '0' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
	   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
	   
	   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao
	
	   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
	   
	   cMun_ANP := '0000000' // Codigo Municipio
	
	   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro
	
		cLinha := cLinha + cMun_ANP // Codigo Municipio
		cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
		cLinha := cLinha + '0000' // Cod do país
		cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
		cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
		
		cDoc   := '0000000'    
		cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
		cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
		
	   cDtEmi := strzero(day(MV_PAR03),2)+strzero(month(MV_PAR03),2)+strzero(year(MV_PAR03),4)	
		cLinha := cLinha + cDtEmi // Data da operacao Comercial
		cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
		
	   cFisQui1 := '000'
	   cMetodo1 := '000'
	   cUnMedi1 := '00'
	   cVlCara1 := '0000000000'
	   cMassaE1 := '0000000'
		
		cProRes := '000000000' // Codigo do Produto/Operacao Resultante
		cRecGLP := '00'    // Recipiente de GLP
		
		cLinhax := ''
		If !Empty(cFisQui1) .and. cQtdPro > 0
	      cConta := cConta + 1  // Nr Registro
		   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP
	
		   SELE AGR159
	      Reclock("AGR159",.T.)
	      AGR159->SEQ    := cConta
	      AGR159->LIN    := cLinhax
	      MsUnlock("AGR159") 
		Endif
	Endif
   *
   * Total Saidas
   *
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := '1001799935'         // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cOperac := '1012998' // Operacao para Total Saidas Comerciais Nacionais
   
   cLinha := cLinha + cOperac   // Operacao
   
   cLinha := cLinha + '1032183' // Cod Instalacao 1
   
   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := ESTOQUE->QTDKGS

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDES)
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '0' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

	cLinha := cLinha + cMun_ANP // Codigo Municipio
	cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
	cLinha := cLinha + '0000' // Cod do país
	cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
	cDoc   := '0000000'    
	cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR03),2)+strzero(month(MV_PAR03),2)+strzero(year(MV_PAR03),4)	
	cLinha := cLinha + cDtEmi // Data da operacao Comercial
	cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
	cProRes := '000000000' // Codigo do Produto/Operacao Resultante
	cRecGLP := '00'    // Recipiente de GLP
	
	cLinhax := ''
	If !Empty(cFisQui1) .and. cQtdPro > 0
      cConta := cConta + 1  // Nr Registro
	   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP

	   SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
	Endif
   *
   * Total Transferencia Entradas
   *
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := '1001799935'         // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cOperac := '1021998' // Operacao para Total Entradas Operacionais (Transferencia Entradas)
   
   cLinha := cLinha + cOperac   // Operacao
   
   cLinha := cLinha + '1032183' // Cod Instalacao 1
   
   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := (ESTOQUE->QTDKGTE + nQTDKGINE ) // Soma inventario de entrada caso tenha

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDETE + nQTDEINE) // Soma inventario de entrada caso tenha
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '0' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

	cLinha := cLinha + '0000000' // Codigo Municipio
	cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
	cLinha := cLinha + '0000' // Cod do país
	cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
	cDoc   := '0000000'    
	cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR03),2)+strzero(month(MV_PAR03),2)+strzero(year(MV_PAR03),4)	
	cLinha := cLinha + cDtEmi // Data da operacao Comercial
	cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
	cProRes := '000000000' // Codigo do Produto/Operacao Resultante
	cRecGLP := '00'    // Recipiente de GLP
	
	cLinhax := ''
	If !Empty(cFisQui1) .and. cQtdPro > 0
      cConta := cConta + 1  // Nr Registro
	   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP

	   SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
	Endif
   *
   * Total Transferencia Saidas
   *
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := '1001799935'         // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cOperac := '1022998' // Operacao para Total Saidas Operacionais (Transferencia Saidas)
   
   cLinha := cLinha + cOperac   // Operacao
   
   cLinha := cLinha + '1032183' // Cod Instalacao 1
   
   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := (ESTOQUE->QTDKGTS + nQTDKGINS ) // Soma inventario de saida caso tenha

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDETS + nQTDEINS ) // Soma inventario de saida caso tenha
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '0' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

	cLinha := cLinha + '0000000' // Codigo Municipio
	cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
	cLinha := cLinha + '0000' // Cod do país
	cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
	cDoc   := '0000000'    
	cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR03),2)+strzero(month(MV_PAR03),2)+strzero(year(MV_PAR03),4)	
	cLinha := cLinha + cDtEmi // Data da operacao Comercial
	cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
	cProRes := '000000000' // Codigo do Produto/Operacao Resultante
	cRecGLP := '00'    // Recipiente de GLP
	
	cLinhax := ''
	If !Empty(cFisQui1) .and. cQtdPro > 0
      cConta := cConta + 1  // Nr Registro
	   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP

	   SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
	Endif
   *
   * Total Geral Entradas
   *
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := '1001799935'         // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cOperac := '4011998' // Operacao para Total Geral Entradas
   
   cLinha := cLinha + cOperac   // Operacao
   
   cLinha := cLinha + '1032183' // Cod Instalacao 1
   
   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := ESTOQUE->QTDKGE + ESTOQUE->QTDKGTE + nQTDKGINE  // Soma inventario de entrada caso tenha

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDEE) + Int(ESTOQUE->QTDETE) + int(nQTDEINE ) // Soma inventario de entrada caso tenha
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '0' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

	cLinha := cLinha + cMun_ANP // Codigo Municipio
	cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
	cLinha := cLinha + '0000' // Cod do país
	cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
	cDoc   := '0000000'    
	cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR03),2)+strzero(month(MV_PAR03),2)+strzero(year(MV_PAR03),4)	
	cLinha := cLinha + cDtEmi // Data da operacao Comercial
	cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
	cProRes := '000000000' // Codigo do Produto/Operacao Resultante
	cRecGLP := '00'    // Recipiente de GLP
	
	cLinhax := ''
	If !Empty(cFisQui1) .and. cQtdPro > 0
      cConta := cConta + 1  // Nr Registro
	   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP

	   SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
	Endif
   *
   * Total Geral Saidas
   *
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := '1001799935'         // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cOperac := '4012998' // Operacao para Total Geral Saidas
   
   cLinha := cLinha + cOperac   // Operacao
   
   cLinha := cLinha + '1032183' // Cod Instalacao 1
   
   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := ESTOQUE->QTDKGS + ESTOQUE->QTDKGTS + nQTDKGINS  // Soma inventario de saida caso tenha

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDES) + Int(ESTOQUE->QTDETS) + int(nQTDEINS ) // Soma inventario de saida caso tenha
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '0' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

	cLinha := cLinha + cMun_ANP // Codigo Municipio
	cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
	cLinha := cLinha + '0000' // Cod do país
	cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
	cDoc   := '0000000'    
	cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR03),2)+strzero(month(MV_PAR03),2)+strzero(year(MV_PAR03),4)	
	cLinha := cLinha + cDtEmi // Data da operacao Comercial
	cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
	cProRes := '000000000' // Codigo do Produto/Operacao Resultante
	cRecGLP := '00'    // Recipiente de GLP
	
	cLinhax := ''
	If !Empty(cFisQui1) .and. cQtdPro > 0
      cConta := cConta + 1  // Nr Registro
	   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP

	   SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
	Endif
	
	   
   Sele ESTOQUE
   DbSkip()

End

*
* Gera Registro Controle
*  
cConta := cConta + 1 // Adiciona 1 devido Header ser linha 0
cLinha := '0000000000'+'1001799935'+cMMAAAA+StrZero(cConta,7)
fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)
*
* Gera Registro Movimentacao
*  
SELE AGR159
DbGotop()
While !Eof()
   cLinhax := AGR159->LIN     
   fWrite(nHdlArq,cLinhax+chr(13)+chr(10),len(cLinhax)+2)
   DbSkip()
   Loop
End
FClose(nHdlArq)

*
* Imprimi Relatorio Resumido cfe necessidade Fabi
*
AGR159REL()

sele SA1
dbsetorder(1) ; dbgotop()

SELE MSD2
USE

SELE MSD1
USE

SELE AGR159
USE

SELE ESTOQUE
USE

RETURN


Static Function AGR159REL()
	Limite   := 132
	cString  :="SB2"
	cDesc1   := OemToAnsi("Este programa tem como objetivo, imprimir o relatorio")
	cDesc2   := OemToAnsi("Resumido da Geracao do Arquivo SIMP")
	cDesc3   := ""
	nChar    := 18
	cTamanho := "M"
	
	aReturn  := {OemToAnsi("Zebrado"),1,OemToAnsi("Administracao"),2,2,1,"",1}
	cNomeProg:= "AGR159"
	aLinha   := {}
	nLastKey := 0
	
	Titulo   := "Relatorio Resumido Arquivo SIMP De: " + DTOC(MV_PAR01) + " Ate: " + DTOC(MV_PAR02)
	cCabec1  := "                                            ENTRADAS       TOTAL                        SAIDAS         TOTAL               "
	//				 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	//				           10        20        30        40        50        60        70        80        90        100       110       120       130
	cCabec2  := "PRODUTO    SALDO INICIAL       COMPRAS      PRODUCAO      ENTRADAS        VENDAS      PRODUCAO        SAIDAS    SALDO FINAL"
	cCancel  := "***** CANCELADO PELO OPERADOR *****"
	m_pag    := 1        //Variavel que acumula numero da pagina
	wnrel    := "AGR159" //Nome Default do relatorio em Disco
	
	SetPrint(cString,wnrel,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	RptStatus({|lEnd| AGR159IMP(@lEnd,wnrel,cString)},Titulo)
Return

Static Function AGR159IMP()
	LOCAL nLin     := 99

	Sele ESTOQUE
	DbGotop()
	Procregua(Reccount())
	While !Eof() 
		If nLin > 55
			nLin := Cabec(Titulo,cCabec1,cCabec2,cNomeProg,cTamanho,nChar)
		Endif
		
		nLin++
		@ nLin,000 PSAY Alltrim(ESTOQUE->PROOPE)
		@ nLin,011 PSAY TRANSFORM(ESTOQUE->QTDEI,'@E 999,999,999.99')  // Estoque Inicial
		@ nLin,025 PSAY TRANSFORM(ESTOQUE->QTDEE,'@E 999,999,999.99')  // Compras = Total Entradas 
		@ nLin,039 PSAY TRANSFORM(ESTOQUE->QTDETE,'@E 999,999,999.99') // Producao Entradas = Transf. Entradas
		@ nLin,053 PSAY TRANSFORM((ESTOQUE->QTDEE+ESTOQUE->QTDETE),'@E 999,999,999.99') // Total Entradas
		@ nLin,067 PSAY TRANSFORM(ESTOQUE->QTDES,'@E 999,999,999.99')  // Vendas  = Total Saidas 
		@ nLin,081 PSAY TRANSFORM(ESTOQUE->QTDETS,'@E 999,999,999.99') // Producao Saidas = Transf. Saidas
		@ nLin,095 PSAY TRANSFORM((ESTOQUE->QTDES+ESTOQUE->QTDETS),'@E 999,999,999.99') // Total Saidas
		@ nLin,109 PSAY TRANSFORM(ESTOQUE->QTDEF,'@E 999,999,999.99') // Estoque Final

	   Sele ESTOQUE
   	DbSkip()

	End
	
	Roda(0,"",cTamanho)
	
	Set Filter To
	If aReturn[5] == 1
		Set Printer To
		Commit
		ourspool(wnrel) //Chamada do Spool de Impressao
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool

Return

Static Function CriaPerguntas(cGrupo,aPer)
****************************************** 

LOCAL lRetu := .T.
LOCAL aReg  := {}
 
DbSelectArea("SX1")
If     (FCount() == 41)
       For _l := 1 to Len(aPer)                                   
   	      Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
	                        aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
	                        aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
	                        aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
	                        aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
                            aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","",""})
       Next _l
Elseif (FCount() == 26)
  	   aReg := aPer
Endif
 
DbSelectArea("SX1")
For _l := 1 to Len(aReg)
    If     !dbSeek(cGrupo+StrZero(_l,02,00))
	       RecLock("SX1",.T.)
           For _m := 1 to FCount()
   	           FieldPut(_m,aReg[_l,_m])
	       Next _m
	       MsUnlock("SX1")
	Elseif Alltrim(aReg[_l,3]) <> Alltrim(SX1->X1_PERGUNT)
		   RecLock("SX1",.F.)
		   For _k := 1 to FCount()
		       FieldPut(_k,aReg[_l,_k])
	       Next _k
		   MsUnlock("SX1")
    Endif
Next _l
